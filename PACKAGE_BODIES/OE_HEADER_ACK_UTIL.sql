--------------------------------------------------------
--  DDL for Package Body OE_HEADER_ACK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_HEADER_ACK_UTIL" AS
/* $Header: OEXUHAKB.pls 120.4 2005/12/15 03:06:43 akyadav noship $ */


--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_HEADER_ACK_UTIL';

-- { Start GET_ACK_CODE
FUNCTION GET_ACK_CODE (p_order_source_id   NUMBER   := 6,
                       p_reject_order      VARCHAR2 := 'N',
                       p_transaction_type  VARCHAR2 := NULL,
                       p_booked_flag       VARCHAR2 := NULL,
		       p_header_id         NUMBER DEFAULT NULL)
RETURN VARCHAR
IS
  l_ack_code  Varchar2(30);
  l_hold_id   NUMBER;
BEGIN
  oe_debug_pub.add('Entering function GET_ACK_CODE');
  oe_debug_pub.add('p_reject_order = '||p_reject_order);
  oe_debug_pub.add('p_order_source_id = '||p_order_source_id);
  If p_reject_order    = 'N' Then
     If p_order_source_id = 20 Then
        If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' THEN
           If nvl(FND_PROFILE.VALUE('ONT_XML_ACCEPT_STATE'), 'ENTERED') = 'ENTERED' Then
              Return '0';
           Elsif nvl(p_booked_flag, 'N') = 'N' AND p_transaction_type = OE_Acknowledgment_Pub.G_TRANSACTION_POI Then
              oe_debug_pub.add('return Pending');
              Return '3'; -- pending
           Else
              oe_debug_pub.add('return Accepted - code is 0, post-110510');
              Return '0';
           End If;
        Else
           oe_debug_pub.add('return Accepted - code is 0, pre-110510');
           Return '0';
        End If;
     Else
        BEGIN
         SELECT order_hold_id
         INTO  l_hold_id
         FROM OE_ORDER_HOLDS
         WHERE header_id = p_header_id
         AND hold_release_id IS NULL ;
         oe_debug_pub.add('Hold Applied on this order is :'|| l_hold_id, 3);

         Return 'AH' ;

       EXCEPTION
        WHEN NO_DATA_FOUND
       THEN
         oe_debug_pub.add('No Holds found ', 3);
	 oe_debug_pub.add( 'Header id'||p_header_id);
         Return 'AT' ;

       WHEN TOO_MANY_ROWS
       THEN
        oe_debug_pub.add('Many Holds Applied on this order ', 3);
        Return 'AH' ;
	END ;
     End If;
  Elsif p_reject_order = 'Y' Then
     If p_order_source_id = 20 Then
        oe_debug_pub.add('return Rejected - code is 2');
        Return '2';
     Else
        oe_debug_pub.add('return RJ');
        Return 'RJ';
     End If;
  Else
    oe_debug_pub.add('return Null in else');
    Return Null;
  End If;
END GET_ACK_CODE;
-- End GET_ACK_CODE }

PROCEDURE Insert_Row
(   p_header_rec              IN  OE_Order_Pub.Header_Rec_Type
,   p_header_val_rec          IN  OE_Order_Pub.Header_Val_Rec_Type
,   p_old_header_rec          IN  OE_Order_Pub.Header_Rec_Type
,   p_old_header_val_rec      IN  OE_Order_Pub.Header_Val_Rec_Type
,   p_reject_order            IN  VARCHAR2
,   p_ack_type                IN  VARCHAR2 := NULL
,   x_return_status	      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_header_rec                  OE_Order_Pub.Header_Rec_Type;
l_header_val_rec              OE_Order_Pub.Header_Val_Rec_Type;

l_count			      NUMBER;

BEGIN
    IF p_reject_order = 'N' THEN
       oe_debug_pub.add('before copying header acknowledgment reject N',3);
       l_header_rec      :=  p_header_rec;
       l_header_val_rec  :=  p_header_val_rec;
    ELSE
       oe_debug_pub.add('before copying header acknowledgment reject else',3);
       l_header_rec      :=  p_old_header_rec;
       l_header_val_rec  :=  p_old_header_val_rec;
    END IF;

    OE_Header_Util.Convert_Miss_To_Null (l_header_rec);

     oe_debug_pub.add('First Ack Code is :'||l_header_rec.FIRST_ACK_CODE);
     oe_debug_pub.add('First Ack Code is :'||p_header_rec.FIRST_ACK_CODE);
     oe_debug_pub.add('Order Source Id :'|| l_header_rec.order_source_id);
     oe_debug_pub.add('p_ack_type :'|| p_ack_type);
    IF nvl(l_header_rec.FIRST_ACK_CODE, ' ') = ' ' THEN -- It is 855
          -- Commented as part of 3A4 Change
	  -- l_header_rec.FIRST_ACK_CODE := 'AT';	-- RJ for rejected
          If p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_POA then
            l_header_rec.FIRST_ACK_CODE :=
            Get_Ack_Code(p_order_source_id => l_header_rec.order_source_id,
                         p_reject_order    => p_reject_order);
          Elsif p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_CPO then
            l_header_rec.FIRST_ACK_CODE :=
            Get_Ack_Code(p_order_source_id => l_header_rec.order_source_id,
                         p_reject_order    => p_reject_order);
          -- 3A6 related
          Elsif p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_SSO then
            If l_header_rec.last_ack_code IS NULL Then
               l_header_rec.FIRST_ACK_CODE := 'OPEN';
            Else
               l_header_rec.FIRST_ACK_CODE := l_header_rec.last_ack_code;
            End if;
          Elsif p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_CSO then
            If l_header_rec.last_ack_code IS NULL Then
               l_header_rec.FIRST_ACK_CODE := 'OPEN';
            Else
               l_header_rec.FIRST_ACK_CODE := l_header_rec.last_ack_code;
            End if;
	  Elsif  p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_POI then
            l_header_rec.FIRST_ACK_CODE :=
            Get_Ack_Code(p_order_source_id => l_header_rec.order_source_id,
                         p_reject_order    => p_reject_order,
                         p_booked_flag     => l_header_rec.booked_flag,
                         p_transaction_type => oe_acknowledgment_pub.G_TRANSACTION_POI
                         );
          Elsif  p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_CHO then
              l_header_rec.FIRST_ACK_CODE :=
              Get_Ack_Code(p_order_source_id => l_header_rec.order_source_id,
                           p_reject_order    => p_reject_order);
          Elsif l_header_rec.ORDER_SOURCE_ID <> 20 Then  -- so that we still handle 855
	      l_header_rec.FIRST_ACK_CODE :=
              Get_Ack_Code(p_order_source_id => l_header_rec.order_source_id,
                           p_reject_order    => p_reject_order,
			   p_header_id       => l_header_rec.header_id);
	  End if;
	  l_header_rec.FIRST_ACK_DATE := '';
	  l_header_rec.LAST_ACK_CODE  := '';
	  l_header_rec.LAST_ACK_DATE  := '';
    ELSE
      oe_debug_pub.add('trans is 865 :putting first_ack_date');
      oe_debug_pub.add('First Ack Date  :'|| to_char(p_old_header_rec.FIRST_ACK_DATE));
          l_header_rec.FIRST_ACK_DATE := p_header_rec.FIRST_ACK_DATE;
          -- Commented as part of 3A4 Change
	  -- l_header_rec.LAST_ACK_CODE  := 'AT';	-- RJ for rejected
          l_header_rec.LAST_ACK_CODE :=
            Get_Ack_Code(p_order_source_id => l_header_rec.order_source_id,
                         p_reject_order    => p_reject_order,
			 p_header_id       => l_header_rec.header_id);
          if l_header_rec.LAST_ACK_CODE = 'AT' then
             l_header_rec.LAST_ACK_CODE := 'AC';  -- for 865, header ack code for accept should be
			                          -- AC i.e. Acknowledge - With Detail and Changes
          end if;
	  l_header_rec.LAST_ACK_DATE  := '';
    END IF;

    BEGIN


if p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_SSO
   OR p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_CSO
then

   SELECT count(*) INTO l_count
            FROM OE_HEADER_ACKS
           WHERE header_id = l_header_rec.header_id
             AND acknowledgment_flag Is Null
             -- Change this condition once a type is inserted for POAO/POCAO
             AND nvl(acknowledgment_type,'ALL') = nvl(p_ack_type,'ALL')
             AND  nvl(sold_to_org_id, FND_API.G_MISS_NUM)
               =  nvl(l_header_rec.sold_to_org_id, FND_API.G_MISS_NUM)
	     AND  nvl(sold_to_org, FND_API.G_MISS_CHAR)
               =  nvl(l_header_val_rec.sold_to_org, FND_API.G_MISS_CHAR)
             AND  nvl(change_sequence, FND_API.G_MISS_CHAR)
               =  nvl(l_header_rec.change_sequence, FND_API.G_MISS_CHAR)
             AND request_id = l_header_rec.request_id;
else
          SELECT count(*) INTO l_count
            FROM OE_HEADER_ACKS
           WHERE header_id = l_header_rec.header_id
             AND acknowledgment_flag Is Null
             -- Change this condition once a type is inserted for POAO/POCAO
             AND nvl(acknowledgment_type,'ALL') = nvl(p_ack_type,'ALL')
             AND  nvl(sold_to_org_id, FND_API.G_MISS_NUM)
               =  nvl(l_header_rec.sold_to_org_id, FND_API.G_MISS_NUM)
	     AND  nvl(sold_to_org, FND_API.G_MISS_CHAR)
               =  nvl(l_header_val_rec.sold_to_org, FND_API.G_MISS_CHAR)
             AND  nvl(change_sequence, FND_API.G_MISS_CHAR)
               =  nvl(l_header_rec.change_sequence, FND_API.G_MISS_CHAR);

end if;
          IF l_count > 0 THEN
             OE_Header_Ack_Util.Delete_Row (p_header_id => l_header_rec.header_id,
                                            p_ack_type  => p_ack_type,
                                            p_sold_to_org_id  => l_header_rec.sold_to_org_id,
					    p_sold_to_org     => l_header_val_rec.sold_to_org,
                                            p_change_sequence => l_header_rec.change_sequence,
                                            p_request_id => l_header_rec.request_id);
             oe_debug_pub.add('Count is > 0, Calling Delete Row',3);
             oe_debug_pub.add('Count is ' || l_count);
	  ELSE
             oe_debug_pub.add('Count <= 0 for header_id, attempting delete by doc ref');
             OE_Header_Ack_Util.Delete_Row (p_header_id => NULL,
                                            p_ack_type  => p_ack_type,

                                            p_orig_sys_document_ref => l_header_rec.orig_sys_document_ref,
					    p_sold_to_org_id  => l_header_rec.sold_to_org_id,
				            p_sold_to_org     => l_header_val_rec.sold_to_org,
                                            p_change_sequence => l_header_rec.change_sequence,
                                            p_request_id => l_header_rec.request_id
                                            );
          END IF;


          EXCEPTION WHEN OTHERS THEN
       oe_debug_pub.add('Others exception is select from o_header_acks',3);
    END;


     oe_debug_pub.add('Source = '||l_header_rec.order_source_id);
     oe_debug_pub.add('Ref = '||l_header_rec.orig_sys_document_ref);
     oe_debug_pub.add('Headerid = '||l_header_rec.header_id);
     oe_debug_pub.add('First Ack Code = '|| l_header_rec.first_ack_code,1);
    IF  (    l_header_rec.order_source_id            <> FND_API.G_MISS_NUM
    AND  nvl(l_header_rec.order_source_id,0)         <> 0
    AND      l_header_rec.orig_sys_document_ref      <> FND_API.G_MISS_CHAR
    AND  nvl(l_header_rec.orig_sys_document_ref,' ') <> ' ')

     OR     (l_header_rec.header_id                  <> FND_API.G_MISS_NUM
    AND  nvl(l_header_rec.header_id,0)               <> 0)
    THEN
        oe_debug_pub.add('inserting header ack record for'||
' source id: ' ||to_char(l_header_rec.order_source_id)||
', ref: '      ||l_header_rec.orig_sys_document_ref||
', header id: '||to_char(l_header_rec.header_id));

/* Added substr for some of the values being inserted in the table. This is done to fix the bug 2237470 */
/*Bug2403389 : Reverted the changes made for Bug2237470 */
--Added end customer fields for bug 4034441
    	INSERT INTO OE_HEADER_ACKS
    	(ACCOUNTING_RULE
     	,ACCOUNTING_RULE_ID
     	,ACCOUNTING_RULE_DURATION
     	,ACKNOWLEDGMENT_FLAG
     	,AGREEMENT
     	,AGREEMENT_ID
     	,AGREEMENT_NAME
     	,ATTRIBUTE1
     	,ATTRIBUTE2
     	,ATTRIBUTE3
     	,ATTRIBUTE4
     	,ATTRIBUTE5
     	,ATTRIBUTE6
     	,ATTRIBUTE7
     	,ATTRIBUTE8
     	,ATTRIBUTE9
     	,ATTRIBUTE10
     	,ATTRIBUTE11
     	,ATTRIBUTE12
     	,ATTRIBUTE13
     	,ATTRIBUTE14
     	,ATTRIBUTE15
     	,ATTRIBUTE16      --For bug 2184255
     	,ATTRIBUTE17
     	,ATTRIBUTE18
     	,ATTRIBUTE19
     	,ATTRIBUTE20
     	,FIRST_ACK_CODE
     	,LAST_ACK_CODE
     	,FIRST_ACK_DATE
     	,LAST_ACK_DATE
     	,BUYER_SELLER_FLAG
     	,BOOKED_FLAG
     	,CANCELLED_FLAG
--      ,CLOSED_FLAG
     	,CHANGE_DATE
     	,CHANGE_SEQUENCE
     	,CONTEXT
     	,CONVERSION_RATE
     	,CONVERSION_RATE_DATE
     	,CONVERSION_TYPE
     	,CONVERSION_TYPE_CODE
     	,CREATED_BY
     	,CREATION_DATE
     	,CUST_PO_NUMBER
--        ,CUSTOMER_ID
      ,CUSTOMER_NAME
        ,CUSTOMER_NUMBER
--      ,DELIVER_TO_CONTACT
     	,DELIVER_TO_CONTACT_ID
      ,DELIVER_TO_CUSTOMER
      ,DELIVER_TO_CUSTOMER_NUMBER
--      ,DELIVER_TO_ORG
     	,DELIVER_TO_ORG_ID
--      ,DEMAND_CLASS
     	,DEMAND_CLASS_CODE
     	,EARLIEST_SCHEDULE_LIMIT
--      ,ERROR_FLAG
     	,EXPIRATION_DATE
     	,FOB_POINT
     	,FOB_POINT_CODE
     	,FREIGHT_CARRIER_CODE
     	,FREIGHT_TERMS
     	,FREIGHT_TERMS_CODE
     	,GLOBAL_ATTRIBUTE_CATEGORY
     	,GLOBAL_ATTRIBUTE1
     	,GLOBAL_ATTRIBUTE10
     	,GLOBAL_ATTRIBUTE11
     	,GLOBAL_ATTRIBUTE12
     	,GLOBAL_ATTRIBUTE13
     	,GLOBAL_ATTRIBUTE14
     	,GLOBAL_ATTRIBUTE15
     	,GLOBAL_ATTRIBUTE16
     	,GLOBAL_ATTRIBUTE17
     	,GLOBAL_ATTRIBUTE18
     	,GLOBAL_ATTRIBUTE19
     	,GLOBAL_ATTRIBUTE2
     	,GLOBAL_ATTRIBUTE20
     	,GLOBAL_ATTRIBUTE3
     	,GLOBAL_ATTRIBUTE4
     	,GLOBAL_ATTRIBUTE5
     	,GLOBAL_ATTRIBUTE6
     	,GLOBAL_ATTRIBUTE7
     	,GLOBAL_ATTRIBUTE8
     	,GLOBAL_ATTRIBUTE9
        ,TP_CONTEXT
        ,TP_ATTRIBUTE1
        ,TP_ATTRIBUTE2
        ,TP_ATTRIBUTE3
        ,TP_ATTRIBUTE4
        ,TP_ATTRIBUTE5
        ,TP_ATTRIBUTE6
        ,TP_ATTRIBUTE7
        ,TP_ATTRIBUTE8
        ,TP_ATTRIBUTE9
        ,TP_ATTRIBUTE10
        ,TP_ATTRIBUTE11
        ,TP_ATTRIBUTE12
        ,TP_ATTRIBUTE13
        ,TP_ATTRIBUTE14
        ,TP_ATTRIBUTE15
     	,HEADER_ID
--      ,HEADER_PO_CONTEXT
--      ,INTERFACE_STATUS
     	,INVOICE_ADDRESS_1
     	,INVOICE_ADDRESS_2
     	,INVOICE_ADDRESS_3
     	,INVOICE_ADDRESS_4
      ,INVOICE_CITY
      ,INVOICE_COUNTRY
      ,INVOICE_COUNTY
      ,INVOICE_POSTAL_CODE
      ,INVOICE_PROVINCE_INT
--      ,INVOICE_SITE
      ,INVOICE_SITE_CODE
      ,INVOICE_STATE
--      ,INVOICE_TO_CONTACT
      ,INVOICE_TO_CONTACT_FIRST_NAME
     	,INVOICE_TO_CONTACT_ID
      ,INVOICE_TO_CONTACT_LAST_NAME
     	,INVOICE_TO_ORG
     	,INVOICE_TO_ORG_ID
--      ,INVOICE_TOLERANCE_ABOVE
--      ,INVOICE_TOLERANCE_BELOW
     	,INVOICING_RULE
     	,INVOICING_RULE_ID
     	,LAST_UPDATE_DATE
     	,LAST_UPDATE_LOGIN
     	,LAST_UPDATED_BY
     	,LATEST_SCHEDULE_LIMIT
     	,OPEN_FLAG
--      ,OPERATION_CODE
     	,ORDER_DATE_TYPE_CODE
     	,ORDER_NUMBER
     	,ORDER_SOURCE
     	,ORDER_SOURCE_ID
     	,ORDER_TYPE
     	,ORDER_TYPE_ID
--      ,ORDERED_BY_CONTACT_FIRST_NAME
--      ,ORDERED_BY_CONTACT_LAST_NAME
     	,ORDERED_DATE
     	,ORG_ID
     	,ORIG_SYS_DOCUMENT_REF
        ,PACKING_INSTRUCTIONS
     	,PARTIAL_SHIPMENTS_ALLOWED
     	,PAYMENT_TERM
     	,PAYMENT_TERM_ID
--      ,PO_ATTRIBUTE_1
--      ,PO_ATTRIBUTE_2
--      ,PO_ATTRIBUTE_3
--      ,PO_ATTRIBUTE_4
--      ,PO_ATTRIBUTE_5
--      ,PO_ATTRIBUTE_6
--      ,PO_ATTRIBUTE_7
--      ,PO_ATTRIBUTE_8
--      ,PO_ATTRIBUTE_9
--      ,PO_ATTRIBUTE_10
--      ,PO_ATTRIBUTE_11
--      ,PO_ATTRIBUTE_12
--      ,PO_ATTRIBUTE_13
--      ,PO_ATTRIBUTE_14
--      ,PO_ATTRIBUTE_15
--      ,PO_REVISION_DATE
     	,PRICE_LIST
     	,PRICE_LIST_ID
     	,PRICING_DATE
     	,PROGRAM
     	,PROGRAM_APPLICATION
     	,PROGRAM_APPLICATION_ID
     	,PROGRAM_ID
     	,PROGRAM_UPDATE_DATE
--      ,RELATED_PO_NUMBER
--      ,REMAINDER_ORDERS_ALLOWED
     	,REQUEST_DATE
     	,REQUEST_ID
     	,RETURN_REASON_CODE
     	,SALESREP
     	,SALESREP_ID
     	,SHIP_FROM_ORG
     	,SHIP_FROM_ORG_ID
     	,SHIP_TO_ADDRESS_1
     	,SHIP_TO_ADDRESS_2
     	,SHIP_TO_ADDRESS_3
     	,SHIP_TO_ADDRESS_4
      ,SHIP_TO_CITY
    	,SHIP_TO_CONTACT
      ,SHIP_TO_CONTACT_FIRST_NAME
     	,SHIP_TO_CONTACT_ID
      ,SHIP_TO_CONTACT_LAST_NAME
      ,SHIP_TO_COUNTRY
      ,SHIP_TO_COUNTY
      ,SHIP_TO_CUSTOMER
--      ,SHIP_TO_CUSTOMER_NUMBER
     	,SHIP_TO_ORG
     	,SHIP_TO_ORG_ID
      ,SHIP_TO_POSTAL_CODE
      ,SHIP_TO_PROVINCE
--      ,SHIP_TO_SITE_INT
      ,SHIP_TO_STATE
     	,SHIP_TOLERANCE_ABOVE
     	,SHIP_TOLERANCE_BELOW
--      ,SHIPMENT_PRIORITY
     	,SHIPMENT_PRIORITY_CODE
--      ,SHIPMENT_PRIORITY_CODE_INT
        ,SHIPPING_INSTRUCTIONS
--      ,SHIPPING_METHOD
     	,SHIPPING_METHOD_CODE
     	,SOLD_FROM_ORG
     	,SOLD_FROM_ORG_ID
     	,SOLD_TO_CONTACT
     	,SOLD_TO_CONTACT_ID
     	,SOLD_TO_ORG
     	,SOLD_TO_ORG_ID
     	,SOURCE_DOCUMENT_ID
     	,SOURCE_DOCUMENT_TYPE_ID
--      ,SUBMISSION_DATETIME
     	,TAX_EXEMPT_FLAG
     	,TAX_EXEMPT_NUMBER
     	,TAX_EXEMPT_REASON
     	,TAX_EXEMPT_REASON_CODE
     	,TAX_POINT
     	,TAX_POINT_CODE
--      ,TRANSACTIONAL_CURR
     	,TRANSACTIONAL_CURR_CODE
     	,VERSION_NUMBER
        ,ship_to_edi_location_code
        ,sold_to_edi_location_code
        ,BILL_TO_EDI_LOCATION_CODE
        ,Customer_payment_term
        ,SOLD_TO_ADDRESS1
        ,SOLD_TO_ADDRESS2
        ,SOLD_TO_ADDRESS3
        ,SOLD_TO_ADDRESS4
        ,SOLD_TO_CITY
        ,SOLD_TO_POSTAL_CODE
        ,SOLD_TO_COUNTRY
        ,SOLD_TO_STATE
        ,SOLD_TO_COUNTY
        ,SOLD_TO_PROVINCE
        ,SOLD_TO_CONTACT_LAST_NAME
        ,SOLD_TO_CONTACT_FIRST_NAME
        ,ORDER_CATEGORY_CODE
        ,ship_from_edi_location_code
        ,SHIP_FROM_ADDRESS_1
        ,SHIP_FROM_ADDRESS_2
        ,SHIP_FROM_ADDRESS_3
        ,SHIP_FROM_CITY
        ,SHIP_FROM_POSTAL_CODE
        ,SHIP_FROM_COUNTRY
        ,SHIP_FROM_REGION1
        ,SHIP_FROM_REGION2
        ,SHIP_FROM_REGION3
        ,SHIP_FROM_ADDRESS_ID
        ,SOLD_TO_ADDRESS_ID
        ,SHIP_TO_ADDRESS_ID
        ,INVOICE_ADDRESS_ID
        ,SHIP_TO_ADDRESS_CODE
        ,xml_message_id
        ,acknowledgment_type
        ,blanket_number -- For Blanket Ack chnages
        ,sold_to_site_use_id
	,sold_to_location_address1
	,sold_to_location_address2
	,sold_to_location_address3
	,sold_to_location_address4
	,sold_to_location_city
	,sold_to_location_postal_code
	,sold_to_location_country
	,sold_to_location_state
	,sold_to_location_county
	,sold_to_location_province
     -- start of additional quoting columns
        ,transaction_phase_code
        ,quote_number
        ,quote_date
        ,sales_document_name
        ,user_status_code
     -- end of additional quoting columns
     -- { Distributer Order related change
        ,end_customer_id
        ,end_customer_contact_id
        ,end_customer_site_use_id
        ,ib_owner
        ,ib_current_location
        ,ib_installed_at_location
     -- Distributer Order related change }
       ,end_customer_name
        ,end_customer_number
        ,end_customer_contact
        ,end_customer_address1
        ,end_customer_address2
        ,end_customer_address3
        ,end_customer_address4
        ,end_customer_city
        ,end_customer_state
        ,end_customer_postal_code
        ,end_customer_country
	,INVOICE_CUSTOMER  -- for bug 4489065

     	)
     	VALUES
     	(
       	l_header_val_rec.ACCOUNTING_RULE
     	, l_header_rec.ACCOUNTING_RULE_ID	--number
     	, l_header_rec.ACCOUNTING_RULE_DURATION	--number
     	,''					-- acknowledgment_flag
     	, l_header_val_rec.AGREEMENT
     	, l_header_rec.AGREEMENT_ID		--number
     	,''					--AGREEMENT_NAME
     	, l_header_rec.ATTRIBUTE1
     	, l_header_rec.ATTRIBUTE2
     	, l_header_rec.ATTRIBUTE3
     	, l_header_rec.ATTRIBUTE4
     	, l_header_rec.ATTRIBUTE5
     	, l_header_rec.ATTRIBUTE6
     	, l_header_rec.ATTRIBUTE7
     	, l_header_rec.ATTRIBUTE8
     	, l_header_rec.ATTRIBUTE9
     	, l_header_rec.ATTRIBUTE10
     	, l_header_rec.ATTRIBUTE11
     	, l_header_rec.ATTRIBUTE12
     	, l_header_rec.ATTRIBUTE13
     	, l_header_rec.ATTRIBUTE14
     	, l_header_rec.ATTRIBUTE15
     	, l_header_rec.ATTRIBUTE16  -- for bug 2184255
     	, l_header_rec.ATTRIBUTE17
     	, l_header_rec.ATTRIBUTE18
     	, l_header_rec.ATTRIBUTE19
     	, l_header_rec.ATTRIBUTE20
     	, l_header_rec.FIRST_ACK_CODE
     	, l_header_rec.LAST_ACK_CODE
     	, l_header_rec.FIRST_ACK_DATE
     	, l_header_rec.LAST_ACK_DATE
     	, 'B'		-- BUYER_SELLER_FLAG
     	, l_header_rec.BOOKED_FLAG
     	, l_header_rec.CANCELLED_FLAG
     	, ''		-- CHANGE_DATE
     	, l_header_rec.CHANGE_SEQUENCE
     	, l_header_rec.CONTEXT
     	, l_header_rec.CONVERSION_RATE		--number
     	, l_header_rec.CONVERSION_RATE_DATE
     	, l_header_val_rec.CONVERSION_TYPE
     	, l_header_rec.CONVERSION_TYPE_CODE
     	, l_header_rec.CREATED_BY		-- number
     	, l_header_rec.CREATION_DATE
     	, l_header_rec.CUST_PO_NUMBER
        , l_header_val_rec.SOLD_TO_ORG  -- For bug 2701018
        , l_header_val_rec.CUSTOMER_NUMBER
     	, l_header_rec.DELIVER_TO_CONTACT_ID--number
        , l_header_val_rec.DELIVER_TO_CUSTOMER_NAME
        , l_header_val_rec.DELIVER_TO_CUSTOMER_NUMBER
     	, l_header_rec.DELIVER_TO_ORG_ID-- number
     	, l_header_rec.DEMAND_CLASS_CODE
     	, l_header_rec.EARLIEST_SCHEDULE_LIMIT
     	, l_header_rec.EXPIRATION_DATE
     	, l_header_val_rec.FOB_POINT
     	, l_header_rec.FOB_POINT_CODE
     	, l_header_rec.FREIGHT_CARRIER_CODE
     	, l_header_val_rec.FREIGHT_TERMS
     	, l_header_rec.FREIGHT_TERMS_CODE
     	, l_header_rec.GLOBAL_ATTRIBUTE_CATEGORY
     	, l_header_rec.GLOBAL_ATTRIBUTE1
     	, l_header_rec.GLOBAL_ATTRIBUTE10
     	, l_header_rec.GLOBAL_ATTRIBUTE11
     	, l_header_rec.GLOBAL_ATTRIBUTE12
     	, l_header_rec.GLOBAL_ATTRIBUTE13
     	, l_header_rec.GLOBAL_ATTRIBUTE14
     	, l_header_rec.GLOBAL_ATTRIBUTE15
     	, l_header_rec.GLOBAL_ATTRIBUTE16
     	, l_header_rec.GLOBAL_ATTRIBUTE17
     	, l_header_rec.GLOBAL_ATTRIBUTE18
     	, l_header_rec.GLOBAL_ATTRIBUTE19
     	, l_header_rec.GLOBAL_ATTRIBUTE2
     	, l_header_rec.GLOBAL_ATTRIBUTE20
     	, l_header_rec.GLOBAL_ATTRIBUTE3
     	, l_header_rec.GLOBAL_ATTRIBUTE4
     	, l_header_rec.GLOBAL_ATTRIBUTE5
     	, l_header_rec.GLOBAL_ATTRIBUTE6
     	, l_header_rec.GLOBAL_ATTRIBUTE7
     	, l_header_rec.GLOBAL_ATTRIBUTE8
     	, l_header_rec.GLOBAL_ATTRIBUTE9
        , l_header_rec.TP_CONTEXT
        , l_header_rec.TP_ATTRIBUTE1
        , l_header_rec.TP_ATTRIBUTE2
        , l_header_rec.TP_ATTRIBUTE3
        , l_header_rec.TP_ATTRIBUTE4
        , l_header_rec.TP_ATTRIBUTE5
        , l_header_rec.TP_ATTRIBUTE6
        , l_header_rec.TP_ATTRIBUTE7
        , l_header_rec.TP_ATTRIBUTE8
        , l_header_rec.TP_ATTRIBUTE9
        , l_header_rec.TP_ATTRIBUTE10
        , l_header_rec.TP_ATTRIBUTE11
        , l_header_rec.TP_ATTRIBUTE12
        , l_header_rec.TP_ATTRIBUTE13
        , l_header_rec.TP_ATTRIBUTE14
        , l_header_rec.TP_ATTRIBUTE15
     	, l_header_rec.HEADER_ID--number
     	, l_header_val_rec.INVOICE_TO_ADDRESS1
     	, l_header_val_rec.INVOICE_TO_ADDRESS2
     	, l_header_val_rec.INVOICE_TO_ADDRESS3
     	, l_header_val_rec.INVOICE_TO_ADDRESS4
        , l_header_val_rec.invoice_to_city
        , l_header_val_rec.invoice_to_country
        , l_header_val_rec.invoice_to_county
        , l_header_val_rec.invoice_to_zip
        , l_header_val_rec.invoice_to_province
        , l_header_val_rec.invoice_to_location
        , l_header_val_rec.invoice_to_state
        , l_header_val_rec.invoice_to_contact_first_name
     	, l_header_rec.INVOICE_TO_CONTACT_ID--number
        , l_header_val_rec.invoice_to_contact_last_name
     	, l_header_val_rec.INVOICE_TO_ORG--number
     	, l_header_rec.INVOICE_TO_ORG_ID--number
     	, l_header_val_rec.INVOICING_RULE
     	, l_header_rec.INVOICING_RULE_ID-- number
     	, l_header_rec.LAST_UPDATE_DATE
     	, l_header_rec.LAST_UPDATE_LOGIN-- number
     	, l_header_rec.LAST_UPDATED_BY-- number
     	, l_header_rec.LATEST_SCHEDULE_LIMIT
     	, l_header_rec.OPEN_FLAG
     	, l_header_rec.ORDER_DATE_TYPE_CODE
     	, l_header_rec.ORDER_NUMBER-- number
     	, l_header_val_rec.ORDER_SOURCE
     	, l_header_rec.ORDER_SOURCE_ID-- number
     	, l_header_val_rec.ORDER_TYPE
     	, l_header_rec.ORDER_TYPE_ID-- number
     	, l_header_rec.ORDERED_DATE
     	, l_header_rec.ORG_ID-- number
     	, l_header_rec.ORIG_SYS_DOCUMENT_REF
        , l_header_rec.PACKING_INSTRUCTIONS
     	, l_header_rec.PARTIAL_SHIPMENTS_ALLOWED
     	, l_header_val_rec.PAYMENT_TERM
     	, l_header_rec.PAYMENT_TERM_ID-- number
     	, l_header_val_rec.PRICE_LIST
     	, l_header_rec.PRICE_LIST_ID-- number
     	, l_header_rec.PRICING_DATE
     	, ''		-- PROGRAM
     	, ''		-- PROGRAM_APPLICATION
     	, l_header_rec.PROGRAM_APPLICATION_ID	-- number
     	, l_header_rec.PROGRAM_ID		-- number
     	, l_header_rec.PROGRAM_UPDATE_DATE
     	, l_header_rec.REQUEST_DATE
     	, l_header_rec.REQUEST_ID		-- number
     	, l_header_rec.RETURN_REASON_CODE
     	, l_header_val_rec.SALESREP
     	, l_header_rec.SALESREP_ID		-- number
     	, l_header_val_rec.SHIP_FROM_ORG
     	, l_header_rec.SHIP_FROM_ORG_ID		-- number
     	, l_header_val_rec.SHIP_TO_ADDRESS1
     	, l_header_val_rec.SHIP_TO_ADDRESS2
     	, l_header_val_rec.SHIP_TO_ADDRESS3
     	, l_header_val_rec.SHIP_TO_ADDRESS4
        , l_header_val_rec.ship_to_city
     	, l_header_val_rec.SHIP_TO_CONTACT
        , l_header_val_rec.SHIP_TO_CONTACT_FIRST_NAME
     	, l_header_rec.SHIP_TO_CONTACT_ID	-- number
        , l_header_val_rec.SHIP_TO_CONTACT_LAST_NAME
        , l_header_val_rec.ship_to_country
        , l_header_val_rec.ship_to_county
        , l_header_val_rec.ship_to_customer_name
     	, l_header_val_rec.SHIP_TO_ORG
     	, l_header_rec.SHIP_TO_ORG_ID		-- number
        , l_header_val_rec.ship_to_zip
        , l_header_val_rec.ship_to_province
        , l_header_val_rec.ship_to_state
     	, l_header_rec.SHIP_TOLERANCE_ABOVE	-- number
     	, l_header_rec.SHIP_TOLERANCE_BELOW	-- number
     	, l_header_rec.SHIPMENT_PRIORITY_CODE
        , l_header_rec.SHIPPING_INSTRUCTIONS
     	, l_header_rec.SHIPPING_METHOD_CODE
     	, ''		-- SOLD_FROM_ORG
     	, '' 		-- SOLD_FROM_ORG_ID
     	, l_header_val_rec.SOLD_TO_CONTACT
     	, l_header_rec.SOLD_TO_CONTACT_ID	-- number
     	, l_header_val_rec.SOLD_TO_ORG
     	, l_header_rec.SOLD_TO_ORG_ID		-- number
     	, l_header_rec.SOURCE_DOCUMENT_ID	-- number
     	, l_header_rec.SOURCE_DOCUMENT_TYPE_ID	-- number
     	, l_header_rec.TAX_EXEMPT_FLAG
     	, l_header_rec.TAX_EXEMPT_NUMBER
     	, l_header_val_rec.TAX_EXEMPT_REASON
     	, l_header_rec.TAX_EXEMPT_REASON_CODE
     	, l_header_val_rec.TAX_POINT
     	, l_header_rec.TAX_POINT_CODE
     	, l_header_rec.TRANSACTIONAL_CURR_CODE
     	, l_header_rec.VERSION_NUMBER 		-- number
        , l_header_rec.SHIP_TO_EDI_LOCATION_CODE
        , l_header_rec.SOLD_TO_EDI_LOCATION_CODE
        , l_header_rec.BILL_TO_EDI_LOCATION_CODE
        , l_header_val_rec.CUSTOMER_PAYMENT_TERM
        , l_header_val_rec.SOLD_TO_ADDRESS1
        , l_header_val_rec.SOLD_TO_ADDRESS2
        , l_header_val_rec.SOLD_TO_ADDRESS3
        , l_header_val_rec.SOLD_TO_ADDRESS4
        , l_header_val_rec.SOLD_TO_CITY
        , l_header_val_rec.SOLD_TO_ZIP
        , l_header_val_rec.SOLD_TO_COUNTRY
        , l_header_val_rec.SOLD_TO_STATE
        , l_header_val_rec.SOLD_TO_COUNTY
        , l_header_val_rec.SOLD_TO_PROVINCE
        , l_header_val_rec.SOLD_TO_CONTACT_LAST_NAME
        , l_header_val_rec.SOLD_TO_CONTACT_FIRST_NAME
        , l_header_rec.ORDER_CATEGORY_CODE
        , l_header_rec.ship_from_edi_location_code
        , l_header_val_rec.SHIP_FROM_ADDRESS1
        , l_header_val_rec.SHIP_FROM_ADDRESS2
        , l_header_val_rec.SHIP_FROM_ADDRESS3
        , l_header_val_rec.SHIP_FROM_CITY
        , l_header_val_rec.SHIP_FROM_POSTAL_CODE
        , l_header_val_rec.SHIP_FROM_COUNTRY
        , l_header_val_rec.SHIP_FROM_REGION1
        , l_header_val_rec.SHIP_FROM_REGION2
        , l_header_val_rec.SHIP_FROM_REGION3
        , l_header_rec.SHIP_FROM_ADDRESS_ID
        , l_header_rec.SOLD_TO_ADDRESS_ID
        , l_header_rec.SHIP_TO_ADDRESS_ID
        , l_header_rec.INVOICE_ADDRESS_ID
        , l_header_val_rec.SHIP_TO_LOCATION
        , l_header_rec.xml_message_id
        , p_ack_type
        , l_header_rec.blanket_number
	, l_header_rec.sold_to_site_use_id
	, l_header_val_rec.sold_to_location_address1
	, l_header_val_rec.sold_to_location_address2
	, l_header_val_rec.sold_to_location_address3
	, l_header_val_rec.sold_to_location_address4
	, l_header_val_rec.sold_to_location_city
	, l_header_val_rec.sold_to_location_postal
	, l_header_val_rec.sold_to_location_country
	, l_header_val_rec.sold_to_location_state
	, l_header_val_rec.sold_to_location_county
	, l_header_val_rec.sold_to_location_province
         -- start of additional quoting columns
        , l_header_rec.transaction_phase_code
        , l_header_rec.quote_number
        , l_header_rec.quote_date
        , l_header_rec.sales_document_name
        , l_header_rec.user_status_code
         -- end of additional quoting columns
         -- { Distributer Order related change
        , l_header_rec.end_customer_id
        , l_header_rec.end_customer_contact_id
        , l_header_rec.end_customer_site_use_id
        , l_header_rec.ib_owner
        , l_header_rec.ib_current_location
        , l_header_rec.ib_installed_at_location
         -- Distributer Order related change }
        ,l_header_val_rec.end_customer_name
        ,l_header_val_rec.end_customer_number
        ,l_header_val_rec.end_customer_contact
        ,l_header_val_rec.end_customer_site_address1
        ,l_header_val_rec.end_customer_site_address2
        ,l_header_val_rec.end_customer_site_address3
        ,l_header_val_rec.end_customer_site_address4
        ,l_header_val_rec.end_customer_site_city
        ,l_header_val_rec.end_customer_site_state
        ,l_header_val_rec.end_customer_site_postal_code
        ,l_header_val_rec.end_customer_site_country
	,l_header_val_rec.invoice_to_customer_name -- for bug 4489065
	);
    ELSE
        oe_debug_pub.add('Incomplete data for inserting header ack rec');
    END IF;

oe_debug_pub.add('after inserting header acknowledgment record');

EXCEPTION

WHEN OTHERS THEN
     oe_debug_pub.Add('Encountered Others Error Exception in OE_Header_Ack_Util.Insert_Row: '||sqlerrm);

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'OE_Header_Ack_Util.Insert_Row');
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Insert_Row;


Procedure Insert_Row
 (p_header_rec          In    OE_Order_Pub.Header_Rec_Type,
  x_ack_type            Out Nocopy  Varchar2,
  x_return_status       Out Nocopy  Varchar2
 )
Is

  l_header_rec          OE_Order_Pub.Header_Rec_Type := p_header_rec;
  l_count               Number;
  l_debug_level         CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_ack_type            Varchar2(3);

Begin

  If nvl(l_header_rec.FIRST_ACK_CODE, ' ') = ' ' Then
    -- Trans is 855
    oe_debug_pub.add('trans is 855');
    l_header_rec.First_Ack_Code :=
     Get_Ack_Code(p_order_source_id => l_header_rec.order_source_id,
                  p_reject_order    => 'N',
		  p_header_id       => l_header_rec.header_id);

    l_header_rec.FIRST_ACK_DATE := Null;
    l_header_rec.LAST_ACK_CODE  := Null;
    l_header_rec.LAST_ACK_DATE  := Null;
    --l_ack_type                  := '855'; for bug4730258
    x_ack_type                  := '855';
  Else
    -- Trans is 865
    oe_debug_pub.add('trans is 865');
    l_header_rec.Last_Ack_Code :=
     Get_Ack_Code(p_order_source_id => l_header_rec.order_source_id,
                  p_reject_order    => 'N',
		  p_header_id       => l_header_rec.header_id);
    If l_header_rec.Last_Ack_Code = 'AT' Then
      l_header_rec.Last_Ack_Code  := 'AC';
    End If;
    l_header_rec.Last_Ack_Date := Null;
    --l_ack_type                  := '865'; for bug4730258
    x_ack_type                  := '865';

  End If;

  Begin
    Select count(*)
    Into   l_count
    From   Oe_Header_Acks
    Where  header_id                  = l_header_rec.header_id
    And    nvl(change_sequence,'ALL') = nvl(l_header_rec.change_sequence,'ALL')
    And    nvl(acknowledgment_type,'ALL') = nvl(l_ack_type,'ALL')
    And    acknowledgment_flag Is Null;

    If l_count > 0 Then
      oe_debug_pub.add('unacknowledged ack present, call delete');
      --Commented code to delete records from oe_line_acks for bug 4730258
      Delete From Oe_Header_Acks
      Where  header_id                  = l_header_rec.header_id
      And    nvl(change_sequence,'ALL') = nvl(l_header_rec.change_sequence,'ALL')
     And    nvl(acknowledgment_type,'ALL') = nvl(l_ack_type,'ALL')
      And    acknowledgment_flag Is Null;

    End If;
  Exception
    When Others Then
      Null;
  End;

  IF    (l_header_rec.order_source_id               <> FND_API.G_MISS_NUM
    AND nvl(l_header_rec.order_source_id,0)         <> 0
    AND l_header_rec.orig_sys_document_ref          <> FND_API.G_MISS_CHAR
    AND nvl(l_header_rec.orig_sys_document_ref,' ') <> ' ')
     OR (l_header_rec.header_id                     <> FND_API.G_MISS_NUM
    AND nvl(l_header_rec.header_id,0)               <> 0) Then

    -- Insert data
    Insert
    Into   Oe_Header_Acks
           (ACCOUNTING_RULE_ID
     	   ,ACCOUNTING_RULE_DURATION
     	   ,ACKNOWLEDGMENT_FLAG
     	   ,AGREEMENT_ID
     	   ,AGREEMENT_NAME
     	   ,ATTRIBUTE1
     	   ,ATTRIBUTE2
     	   ,ATTRIBUTE3
     	   ,ATTRIBUTE4
     	   ,ATTRIBUTE5
     	   ,ATTRIBUTE6
     	   ,ATTRIBUTE7
     	   ,ATTRIBUTE8
     	   ,ATTRIBUTE9
     	   ,ATTRIBUTE10
     	   ,ATTRIBUTE11
     	   ,ATTRIBUTE12
     	   ,ATTRIBUTE13
     	   ,ATTRIBUTE14
     	   ,ATTRIBUTE15
     	   ,ATTRIBUTE16      --For bug 2184255
     	   ,ATTRIBUTE17
     	   ,ATTRIBUTE18
     	   ,ATTRIBUTE19
     	   ,ATTRIBUTE20
     	   ,FIRST_ACK_CODE
     	   ,LAST_ACK_CODE
     	   ,FIRST_ACK_DATE
     	   ,LAST_ACK_DATE
     	   ,BUYER_SELLER_FLAG
     	   ,BOOKED_FLAG
     	   ,CANCELLED_FLAG
     	   ,CHANGE_DATE
     	   ,CHANGE_SEQUENCE
     	   ,CONTEXT
     	   ,CONVERSION_RATE
     	   ,CONVERSION_RATE_DATE
     	   ,CONVERSION_TYPE_CODE
     	   ,CREATED_BY
     	   ,CREATION_DATE
     	   ,CUST_PO_NUMBER
     	   ,DELIVER_TO_CONTACT_ID
     	   ,DELIVER_TO_ORG_ID
     	   ,DEMAND_CLASS_CODE
     	   ,EARLIEST_SCHEDULE_LIMIT
     	   ,EXPIRATION_DATE
     	   ,FOB_POINT_CODE
     	   ,FREIGHT_CARRIER_CODE
     	   ,FREIGHT_TERMS_CODE
     	   ,GLOBAL_ATTRIBUTE_CATEGORY
     	   ,GLOBAL_ATTRIBUTE1
     	   ,GLOBAL_ATTRIBUTE10
     	   ,GLOBAL_ATTRIBUTE11
     	   ,GLOBAL_ATTRIBUTE12
     	   ,GLOBAL_ATTRIBUTE13
     	   ,GLOBAL_ATTRIBUTE14
     	   ,GLOBAL_ATTRIBUTE15
     	   ,GLOBAL_ATTRIBUTE16
     	   ,GLOBAL_ATTRIBUTE17
     	   ,GLOBAL_ATTRIBUTE18
     	   ,GLOBAL_ATTRIBUTE19
     	   ,GLOBAL_ATTRIBUTE2
     	   ,GLOBAL_ATTRIBUTE20
     	   ,GLOBAL_ATTRIBUTE3
     	   ,GLOBAL_ATTRIBUTE4
     	   ,GLOBAL_ATTRIBUTE5
     	   ,GLOBAL_ATTRIBUTE6
     	   ,GLOBAL_ATTRIBUTE7
     	   ,GLOBAL_ATTRIBUTE8
     	   ,GLOBAL_ATTRIBUTE9
           ,TP_CONTEXT
           ,TP_ATTRIBUTE1
           ,TP_ATTRIBUTE2
           ,TP_ATTRIBUTE3
           ,TP_ATTRIBUTE4
           ,TP_ATTRIBUTE5
           ,TP_ATTRIBUTE6
           ,TP_ATTRIBUTE7
           ,TP_ATTRIBUTE8
           ,TP_ATTRIBUTE9
           ,TP_ATTRIBUTE10
           ,TP_ATTRIBUTE11
           ,TP_ATTRIBUTE12
           ,TP_ATTRIBUTE13
           ,TP_ATTRIBUTE14
           ,TP_ATTRIBUTE15
     	   ,HEADER_ID
     	   ,INVOICE_TO_CONTACT_ID
     	   ,INVOICE_TO_ORG_ID
     	   ,INVOICING_RULE_ID
     	   ,LAST_UPDATE_DATE
     	   ,LAST_UPDATE_LOGIN
     	   ,LAST_UPDATED_BY
     	   ,LATEST_SCHEDULE_LIMIT
     	   ,OPEN_FLAG
     	   ,ORDER_DATE_TYPE_CODE
     	   ,ORDER_NUMBER
     	   ,ORDER_SOURCE_ID
     	   ,ORDER_TYPE_ID
     	   ,ORDERED_DATE
     	   ,ORG_ID
     	   ,ORIG_SYS_DOCUMENT_REF
           ,PACKING_INSTRUCTIONS
     	   ,PARTIAL_SHIPMENTS_ALLOWED
     	   ,PAYMENT_TERM_ID
     	   ,PRICE_LIST_ID
     	   ,PRICING_DATE
     	   ,PROGRAM
     	   ,PROGRAM_APPLICATION
     	   ,PROGRAM_APPLICATION_ID
     	   ,PROGRAM_ID
     	   ,PROGRAM_UPDATE_DATE
     	   ,REQUEST_DATE
     	   ,REQUEST_ID
     	   ,RETURN_REASON_CODE
     	   ,SALESREP_ID
     	   ,SHIP_FROM_ORG_ID
     	   ,SHIP_TO_CONTACT_ID
     	   ,SHIP_TO_ORG_ID
     	   ,SHIP_TOLERANCE_ABOVE
     	   ,SHIP_TOLERANCE_BELOW
     	   ,SHIPMENT_PRIORITY_CODE
           ,SHIPPING_INSTRUCTIONS
     	   ,SHIPPING_METHOD_CODE
     	   ,SOLD_FROM_ORG
     	   ,SOLD_FROM_ORG_ID
     	   ,SOLD_TO_CONTACT_ID
     	   ,SOLD_TO_ORG_ID
     	   ,SOURCE_DOCUMENT_ID
     	   ,SOURCE_DOCUMENT_TYPE_ID
     	   ,TAX_EXEMPT_FLAG
     	   ,TAX_EXEMPT_NUMBER
     	   ,TAX_EXEMPT_REASON_CODE
     	   ,TAX_POINT_CODE
     	   ,TRANSACTIONAL_CURR_CODE
     	   ,VERSION_NUMBER
           ,ORDER_CATEGORY_CODE
           ,xml_message_id
           ,acknowledgment_type
           ,blanket_number -- For Blanket Ack chnages
	   ,sold_to_site_use_id
         -- start if additional quoting columns
           ,transaction_phase_code
           ,quote_number
           ,quote_date
           ,sales_document_name
           ,user_status_code
         -- end of additional quoting columns
         -- { Distributer Order related change
           ,end_customer_id
           ,end_customer_contact_id
           ,end_customer_site_use_id
           ,ib_owner
           ,ib_current_location
           ,ib_installed_at_location
         -- Distributer Order related change }

     	   )
    Values
     	   ( l_header_rec.ACCOUNTING_RULE_ID	--number
     	   , l_header_rec.ACCOUNTING_RULE_DURATION	--number
     	   ,''					-- acknowledgment_flag
     	   , l_header_rec.AGREEMENT_ID		--number
     	   ,''					--AGREEMENT_NAME
     	   , l_header_rec.ATTRIBUTE1
     	   , l_header_rec.ATTRIBUTE2
     	   , l_header_rec.ATTRIBUTE3
     	   , l_header_rec.ATTRIBUTE4
     	   , l_header_rec.ATTRIBUTE5
     	   , l_header_rec.ATTRIBUTE6
     	   , l_header_rec.ATTRIBUTE7
     	   , l_header_rec.ATTRIBUTE8
     	   , l_header_rec.ATTRIBUTE9
     	   , l_header_rec.ATTRIBUTE10
     	   , l_header_rec.ATTRIBUTE11
     	   , l_header_rec.ATTRIBUTE12
     	   , l_header_rec.ATTRIBUTE13
     	   , l_header_rec.ATTRIBUTE14
     	   , l_header_rec.ATTRIBUTE15
     	   , l_header_rec.ATTRIBUTE16  -- for bug 2184255
     	   , l_header_rec.ATTRIBUTE17
     	   , l_header_rec.ATTRIBUTE18
     	   , l_header_rec.ATTRIBUTE19
     	   , l_header_rec.ATTRIBUTE20
     	   , l_header_rec.FIRST_ACK_CODE
     	   , l_header_rec.LAST_ACK_CODE
     	   , l_header_rec.FIRST_ACK_DATE
     	   , l_header_rec.LAST_ACK_DATE
     	   , 'B'		-- BUYER_SELLER_FLAG
     	   , l_header_rec.BOOKED_FLAG
     	   , l_header_rec.CANCELLED_FLAG
     	   , ''		-- CHANGE_DATE
     	   , l_header_rec.CHANGE_SEQUENCE
     	   , l_header_rec.CONTEXT
     	   , l_header_rec.CONVERSION_RATE		--number
     	   , l_header_rec.CONVERSION_RATE_DATE
     	   , l_header_rec.CONVERSION_TYPE_CODE
     	   , l_header_rec.CREATED_BY		-- number
     	   , l_header_rec.CREATION_DATE
     	   , l_header_rec.CUST_PO_NUMBER
     	   , l_header_rec.DELIVER_TO_CONTACT_ID--number
     	   , l_header_rec.DELIVER_TO_ORG_ID-- number
     	   , l_header_rec.DEMAND_CLASS_CODE
     	   , l_header_rec.EARLIEST_SCHEDULE_LIMIT
     	   , l_header_rec.EXPIRATION_DATE
     	   , l_header_rec.FOB_POINT_CODE
     	   , l_header_rec.FREIGHT_CARRIER_CODE
     	   , l_header_rec.FREIGHT_TERMS_CODE
     	   , l_header_rec.GLOBAL_ATTRIBUTE_CATEGORY
     	   , l_header_rec.GLOBAL_ATTRIBUTE1
     	   , l_header_rec.GLOBAL_ATTRIBUTE10
     	   , l_header_rec.GLOBAL_ATTRIBUTE11
     	   , l_header_rec.GLOBAL_ATTRIBUTE12
     	   , l_header_rec.GLOBAL_ATTRIBUTE13
     	   , l_header_rec.GLOBAL_ATTRIBUTE14
     	   , l_header_rec.GLOBAL_ATTRIBUTE15
     	   , l_header_rec.GLOBAL_ATTRIBUTE16
     	   , l_header_rec.GLOBAL_ATTRIBUTE17
     	   , l_header_rec.GLOBAL_ATTRIBUTE18
     	   , l_header_rec.GLOBAL_ATTRIBUTE19
     	   , l_header_rec.GLOBAL_ATTRIBUTE2
     	   , l_header_rec.GLOBAL_ATTRIBUTE20
     	   , l_header_rec.GLOBAL_ATTRIBUTE3
     	   , l_header_rec.GLOBAL_ATTRIBUTE4
     	   , l_header_rec.GLOBAL_ATTRIBUTE5
     	   , l_header_rec.GLOBAL_ATTRIBUTE6
     	   , l_header_rec.GLOBAL_ATTRIBUTE7
     	   , l_header_rec.GLOBAL_ATTRIBUTE8
     	   , l_header_rec.GLOBAL_ATTRIBUTE9
           , l_header_rec.TP_CONTEXT
           , l_header_rec.TP_ATTRIBUTE1
           , l_header_rec.TP_ATTRIBUTE2
           , l_header_rec.TP_ATTRIBUTE3
           , l_header_rec.TP_ATTRIBUTE4
           , l_header_rec.TP_ATTRIBUTE5
           , l_header_rec.TP_ATTRIBUTE6
           , l_header_rec.TP_ATTRIBUTE7
           , l_header_rec.TP_ATTRIBUTE8
           , l_header_rec.TP_ATTRIBUTE9
           , l_header_rec.TP_ATTRIBUTE10
           , l_header_rec.TP_ATTRIBUTE11
           , l_header_rec.TP_ATTRIBUTE12
           , l_header_rec.TP_ATTRIBUTE13
           , l_header_rec.TP_ATTRIBUTE14
           , l_header_rec.TP_ATTRIBUTE15
     	   , l_header_rec.HEADER_ID--number
     	   , l_header_rec.INVOICE_TO_CONTACT_ID--number
     	   , l_header_rec.INVOICE_TO_ORG_ID--number
     	   , l_header_rec.INVOICING_RULE_ID-- number
     	   , l_header_rec.LAST_UPDATE_DATE
     	   , l_header_rec.LAST_UPDATE_LOGIN-- number
     	   , l_header_rec.LAST_UPDATED_BY-- number
     	   , l_header_rec.LATEST_SCHEDULE_LIMIT
     	   , l_header_rec.OPEN_FLAG
     	   , l_header_rec.ORDER_DATE_TYPE_CODE
     	   , l_header_rec.ORDER_NUMBER-- number
     	   , l_header_rec.ORDER_SOURCE_ID-- number
     	   , l_header_rec.ORDER_TYPE_ID-- number
     	   , l_header_rec.ORDERED_DATE
     	   , l_header_rec.ORG_ID-- number
     	   , l_header_rec.ORIG_SYS_DOCUMENT_REF
           , l_header_rec.PACKING_INSTRUCTIONS
     	   , l_header_rec.PARTIAL_SHIPMENTS_ALLOWED
     	   , l_header_rec.PAYMENT_TERM_ID-- number
     	   , l_header_rec.PRICE_LIST_ID-- number
     	   , l_header_rec.PRICING_DATE
     	   , ''		-- PROGRAM
     	   , ''		-- PROGRAM_APPLICATION
     	   , l_header_rec.PROGRAM_APPLICATION_ID	-- number
     	   , l_header_rec.PROGRAM_ID		-- number
     	   , l_header_rec.PROGRAM_UPDATE_DATE
     	   , l_header_rec.REQUEST_DATE
     	   , l_header_rec.REQUEST_ID		-- number
     	   , l_header_rec.RETURN_REASON_CODE
     	   , l_header_rec.SALESREP_ID		-- number
     	   , l_header_rec.SHIP_FROM_ORG_ID		-- number
     	   , l_header_rec.SHIP_TO_CONTACT_ID	-- number
     	   , l_header_rec.SHIP_TO_ORG_ID		-- number
     	   , l_header_rec.SHIP_TOLERANCE_ABOVE	-- number
     	   , l_header_rec.SHIP_TOLERANCE_BELOW	-- number
     	   , l_header_rec.SHIPMENT_PRIORITY_CODE
           , l_header_rec.SHIPPING_INSTRUCTIONS
     	   , l_header_rec.SHIPPING_METHOD_CODE
     	   , ''		-- SOLD_FROM_ORG
     	   , '' 		-- SOLD_FROM_ORG_ID
     	   , l_header_rec.SOLD_TO_CONTACT_ID	-- number
     	   , l_header_rec.SOLD_TO_ORG_ID		-- number
     	   , l_header_rec.SOURCE_DOCUMENT_ID	-- number
     	   , l_header_rec.SOURCE_DOCUMENT_TYPE_ID	-- number
     	   , l_header_rec.TAX_EXEMPT_FLAG
     	   , l_header_rec.TAX_EXEMPT_NUMBER
     	   , l_header_rec.TAX_EXEMPT_REASON_CODE
     	   , l_header_rec.TAX_POINT_CODE
     	   , l_header_rec.TRANSACTIONAL_CURR_CODE
     	   , l_header_rec.VERSION_NUMBER 		-- number
           , l_header_rec.ORDER_CATEGORY_CODE
           , l_header_rec.xml_message_id
           , l_ack_type
           , l_header_rec.blanket_number
	   , l_header_rec.sold_to_site_use_id
         -- start of additional quoting columns
           , l_header_rec.transaction_phase_code
           , l_header_rec.quote_number
           , l_header_rec.quote_date
           , l_header_rec.sales_document_name
           , l_header_rec.user_status_code
         -- end of additional quoting columns
         -- { Distributer Order related change
           , l_header_rec.end_customer_id
           , l_header_rec.end_customer_contact_id
           , l_header_rec.end_customer_site_use_id
           , l_header_rec.ib_owner
           , l_header_rec.ib_current_location
           , l_header_rec.ib_installed_at_location
         -- Distributer Order related change }
           );

  Else
    If l_debug_level > 0 Then
      Oe_Debug_Pub.Add('No data for Ack');
    End If;
  End If;

Exception

  When Others Then
    If FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) Then
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'OE_Header_Ack_Util.Insert_Row');
    End If;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End Insert_Row;



PROCEDURE Delete_Row
(   p_header_id         IN  NUMBER,
    p_ack_type          IN  Varchar2,
    p_orig_sys_document_ref IN Varchar2,
    p_sold_to_org_id    IN  NUMBER,
    p_sold_to_org       In  Varchar2,
    p_change_sequence   IN  Varchar2,
    p_request_id        IN  NUMBER
)
IS
BEGIN

    If p_header_id Is Not NULL Then
       oe_debug_pub.add('before deleting header acknowledgment ',3);

if p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_SSO
   OR p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_CSO
then

DELETE  FROM OE_HEADER_ACKS
       WHERE   HEADER_ID           = p_header_id
         AND   ACKNOWLEDGMENT_FLAG Is Null
         -- Change this condition once a type is inserted for POAO/POCAO
         AND nvl(acknowledgment_type,'ALL') = nvl(p_ack_type,'ALL')
         AND  nvl(sold_to_org_id, FND_API.G_MISS_NUM)
           =  nvl(p_sold_to_org_id, FND_API.G_MISS_NUM)
	 AND  nvl(sold_to_org, FND_API.G_MISS_CHAR)
           =  nvl(p_sold_to_org, FND_API.G_MISS_CHAR)
         AND  nvl(change_sequence, FND_API.G_MISS_CHAR)
           =  nvl(p_change_sequence, FND_API.G_MISS_CHAR)
         AND request_id = p_request_id;
else

       DELETE  FROM OE_HEADER_ACKS
       WHERE   HEADER_ID           = p_header_id
         AND   ACKNOWLEDGMENT_FLAG Is Null
         -- Change this condition once a type is inserted for POAO/POCAO
         AND nvl(acknowledgment_type,'ALL') = nvl(p_ack_type,'ALL')
         AND  nvl(sold_to_org_id, FND_API.G_MISS_NUM)
           =  nvl(p_sold_to_org_id, FND_API.G_MISS_NUM)
	 AND  nvl(sold_to_org, FND_API.G_MISS_CHAR)
           =  nvl(p_sold_to_org, FND_API.G_MISS_CHAR)
         AND  nvl(change_sequence, FND_API.G_MISS_CHAR)
           =  nvl(p_change_sequence, FND_API.G_MISS_CHAR);
end if;

Elsif p_orig_sys_document_ref Is Not NULL Then
       oe_debug_pub.add('before deleting header acknowledgment by orig_sys_document_Ref ',3);

if p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_SSO
   Or p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_CSO
then
  DELETE  FROM OE_HEADER_ACKS
       WHERE   ORIG_SYS_DOCUMENT_REF    = p_orig_sys_document_ref
          AND  ACKNOWLEDGMENT_TYPE      = p_ack_type -- POI, CPO, etc
         AND  nvl(sold_to_org_id, FND_API.G_MISS_NUM)
           =  nvl(p_sold_to_org_id, FND_API.G_MISS_NUM)
	 AND  nvl(sold_to_org, FND_API.G_MISS_CHAR)
           =  nvl(p_sold_to_org, FND_API.G_MISS_CHAR)
         AND  nvl(change_sequence, FND_API.G_MISS_CHAR)
           =  nvl(p_change_sequence, FND_API.G_MISS_CHAR)
          AND  REQUEST_ID               = p_request_id;


else
  DELETE  FROM OE_HEADER_ACKS
       WHERE   ORIG_SYS_DOCUMENT_REF    = p_orig_sys_document_ref
          AND  ACKNOWLEDGMENT_TYPE      = p_ack_type -- POI, CPO, etc
          AND  nvl(sold_to_org_id, FND_API.G_MISS_NUM)
            =  nvl(p_sold_to_org_id, FND_API.G_MISS_NUM)
  	  AND  nvl(sold_to_org, FND_API.G_MISS_CHAR)
           =  nvl(p_sold_to_org, FND_API.G_MISS_CHAR)
          AND  nvl(change_sequence, FND_API.G_MISS_CHAR)
            =  nvl(p_change_sequence, FND_API.G_MISS_CHAR);


end if;

    Else
       oe_debug_pub.add('not deleting any rows from oe_header_acks ',3);

    End If;

EXCEPTION

    WHEN OTHERS THEN

        oe_debug_pub.Add('Encountered Others Error Exception in OE_Header_Ack_Util.Delete_Row: '||sqlerrm);

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
           FND_MSG_PUB.Add_Exc_Msg
            	(G_PKG_NAME, 'OE_Header_Ack_Util.Delete_Row');
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

END OE_Header_Ack_Util;

/
