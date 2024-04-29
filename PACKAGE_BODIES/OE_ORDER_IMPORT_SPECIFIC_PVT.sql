--------------------------------------------------------
--  DDL for Package Body OE_ORDER_IMPORT_SPECIFIC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_IMPORT_SPECIFIC_PVT" AS
/* $Header: OEXVIMSB.pls 120.13.12010000.8 2012/03/28 09:41:58 vmachett ship $ */

/*
---------------------------------------------------------------
--  Start of Comments
--  API name    OE_ORDER_IMPORT_SPECIFIC_PVT
--  Type        Private
--  Purpose  	Order Import Pre- and Post- Process_Order Processing
--  Function
--  Pre-reqs
--  Parameters
--  Version     Current version = 1.0
--              Initial version = 1.0
--  Notes
--
--  End of Comments
------------------------------------------------------------------
*/


--  Fix for the bug# 1220921
--  List_Line_id
--  Code for PROMOTION/COUPONS/DISCOUNTS/PROMOTION LINES
PROCEDURE List_Line_Id
(   p_modifier_name                 IN  VARCHAR2
 ,  p_list_line_no                  IN  VARCHAR2
 ,  p_version_no                    IN  VARCHAR2
 ,  p_list_line_type_code           IN  VARCHAR2
, p_return_status OUT NOCOPY VARCHAR2

, x_list_header_id OUT NOCOPY NUMBER

, x_list_line_id OUT NOCOPY NUMBER

, x_list_line_no OUT NOCOPY VARCHAR2

, x_type OUT NOCOPY VARCHAR2

)
IS
     l_list_header_id               NUMBER;
     l_list_line_id                 NUMBER;
/* modified the following two lines to fix the bug 2716743 */
     l_type                         VARCHAR2(100);
     --
     l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
     --
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING LIST_LINE_ID OF ORDER IMPORT SPECIFIC' , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'NAME = '||P_MODIFIER_NAME ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'TYPE = '||P_LIST_LINE_TYPE_CODE ) ;
    END IF;
/* modified the following if condition to fix the bug 2716743 */
IF ( (p_list_line_type_code = 'DIS' OR
      p_list_line_type_code = 'FREIGHT_CHARGE' OR
      p_list_line_type_code = 'SUR') and
      p_list_line_no is NOT NULL) THEN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OEXVIMSB->BEFORE SELECT QP_LIST_HEADERS_TL FOR DIS' ) ;
   END IF;
   SELECT  LIST_HEADER_ID
    INTO    l_list_header_id
    FROM    qp_list_headers_tl
    WHERE   NAME = p_modifier_name
      AND   LANGUAGE = userenv('LANG')
      AND   nvl(VERSION_NO, FND_API.G_MISS_CHAR)= nvl(p_version_no, FND_API.G_MISS_CHAR);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXVIMSB->BEFORE SELECT QP_LIST_LINE FOR DIS' ) ;
    END IF;
    SELECT  LIST_LINE_ID
    INTO    l_list_line_id
    FROM    qp_list_lines
    WHERE   LIST_HEADER_ID = l_list_header_id
      AND   LIST_LINE_NO   = p_list_line_no
      AND   LIST_LINE_TYPE_CODE = p_list_line_type_code ;

    l_type := p_list_line_type_code ;
    x_type :=l_type;
    x_list_header_id := l_list_header_id;
    x_list_line_id   := l_list_line_id;

ELSIF (p_list_line_type_code = 'PROMOLINE' and p_list_line_no is NOT NULL) THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXVIMSB->BEFORE SELECT QP_LIST_HEADER_TL FOR PROMOLINE' ) ;
    END IF;
    SELECT LIST_HEADER_ID
    INTO l_list_header_id
    FROM qp_list_headers_tl
    WHERE NAME = p_modifier_name
    AND  LANGUAGE = userenv('LANG')
    AND nvl(VERSION_NO,FND_API.G_MISS_CHAR) = nvl(p_version_no,FND_API.G_MISS_CHAR);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXVIMSB->BEFORE SELECT QP_LIST_LINE FOR PROMOLINE' ) ;
    END IF;
    SELECT LIST_LINE_ID
    INTO l_list_line_id
    FROM qp_list_lines
    WHERE LIST_HEADER_ID = l_list_header_id
    AND LIST_LINE_NO = p_list_line_no
    AND LIST_LINE_TYPE_CODE ='PROMOLINE';

    l_type :='PROMOLINE';
    x_type :=l_type;
    x_list_header_id :=l_list_header_id;
    x_list_line_id   :=l_list_line_id;

ELSE

  --Check if Ct is atleast on Patchset Level H
  If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL < '110508' Then
    Return;
  End If;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXVIMSB-> IN ELSE , SEARCH FOR PROMO/COUPONS' ) ;
     END IF;

     -- { Start of <> 'PROMO'
     --  This condition will be executed when user send list_line_type_code
     --  as 'PROMO' or NULL
     --  If it is PROMO and it does not found error will be raised and
     --  processing will stop
     --  If it is NULL and it does not found, the processing will continue and
     --  will search coupon table
      IF (p_list_line_type_code = 'PROMO' or
         p_list_line_type_code = FND_API.G_MISS_CHAR) Then

       BEGIN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'OEXVIMSB-> PROMO OR MISS_CHAR' ) ;
       END IF;
       SELECT LIST_HEADER_ID
         INTO l_list_header_id
         FROM qp_list_headers_vl
        WHERE name =p_modifier_name
          AND ask_for_flag = 'Y';

        l_type :='PROMO';
        x_type :=l_type;
        x_list_header_id := l_list_header_id;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXVIMSB-> LIST_HEADER_ID ' || L_LIST_HEADER_ID ) ;
        END IF;

       EXCEPTION
        WHEN NO_DATA_FOUND THEN
        l_type :='NODATA';
       END;

     -- This code to exit out of  processing if 'PROMO' was send and
     -- it failed to find any data in previous select
     IF (p_list_line_type_code = 'PROMO' And
        l_type = 'NODATA') THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NOT VALID PROMOTION NAME =' ||P_MODIFIER_NAME ) ;
        END IF;
        FND_MESSAGE.SET_NAME('ONT','OE_INVALID_LIST_NAME');
        FND_MESSAGE.SET_TOKEN('LIST_NAME',p_modifier_name);
        OE_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
        return;
     END IF;

     END IF;
     -- } Start of <> 'PROMO'

     IF (l_type = 'NODATA'  or p_list_line_type_code = 'COUPON' ) THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SEARCH FOR COUPON' ) ;
      END IF;
      BEGIN
       SELECT coupon_id
        INTO l_list_line_id
        FROM qp_coupons
        WHERE coupon_number =p_modifier_name;

        l_type :='COUPON';
        x_type :=l_type;
        x_list_line_id   := l_list_line_id;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXVIMSB-> LIST_LINE_ID ' || L_LIST_LINE_ID ) ;
        END IF;

      EXCEPTION
       WHEN NO_DATA_FOUND THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NOT VALID PROMOTION/COUPON LIST_NAME =' ||P_MODIFIER_NAME ) ;
        END IF;
        FND_MESSAGE.SET_NAME('ONT','OE_INVALID_LIST_NAME');
        FND_MESSAGE.SET_TOKEN('LIST_NAME',p_modifier_name);
        OE_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
      END;
    END IF;
END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXP NO_DATA LIST_LINE_ID OF ORDER IMPORT SPECIFIC' , 1 ) ;
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'NOT VALID PROMOTION NAME =' ||P_MODIFIER_NAME ) ;
          END IF;
          FND_MESSAGE.SET_NAME('ONT','OE_INVALID_LIST_NAME');
          FND_MESSAGE.SET_TOKEN('LIST_NAME',p_modifier_name);
          OE_MSG_PUB.Add;
	  p_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

    WHEN OTHERS THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXP OTHERS LIST_LINE_ID OF ORDER IMPORT SPECIFIC AND SQLERR = ' || SQLERRM , 1 ) ;
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'List_Line_Id'
            ,   sqlerrm
            );
        END IF;

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END List_Line_Id;


--  { Start Create New Cust Info Procedure
--  New Customer ref related record will be passed to this api
--  It will check the not null values and call the OE_INLINE_CUSTOMER_PUB
--  package api to create the required record

PROCEDURE Create_New_Cust_Info
(  p_customer_rec  IN            Customer_Rec_Type,
   p_x_header_rec  IN OUT NOCOPY OE_Order_Pub.Header_Rec_Type,
   p_x_line_rec    IN OUT NOCOPY OE_Order_Pub.Line_Rec_Type,
   p_record_type   IN            Varchar2 Default 'HEADER',
x_return_status OUT NOCOPY Varchar2

)
IS
   l_customer_info_id              Number;
   l_customer_info_number          Varchar2(30);
   l_return_status                 Varchar2(1);
   l_tca_bus_events                varchar2(240);
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING CREATE NEW CUST INFO ' , 1 ) ;
    END IF;

    l_tca_bus_events := fnd_profile.value('HZ_EXECUTE_API_CALLOUTS');

    IF l_tca_bus_events <> 'N' THEN

       fnd_profile.put('HZ_EXECUTE_API_CALLOUTS','N');
       IF l_debug_level  > 0 THEN
          oe_debug_pub.add(' Turned off TCA Business Events. Previous value: '||l_tca_bus_events||
                   'New Value: '|| fnd_profile.value('HZ_EXECUTE_API_CALLOUTS'));
       END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- { Start Check for each column of the record and
    --   For the Not Null value call the Create_Customer_Info
    --   api with relavant parameter.
    If p_customer_rec.orig_sys_customer_ref is Not Null Then
     --{ Start of If for Add customer privilege check
     If  G_ONT_ADD_CUSTOMER = 'Y' Then
       -- This Means New Customer Need to be Added Call The
       -- api with this information and Type should be
       -- 'ACCOUNT' for this call
       OE_INLINE_CUSTOMER_PUB.Create_Customer_Info(
              p_customer_info_ref    => p_customer_rec.orig_sys_customer_ref,
              p_customer_info_type_code => 'ACCOUNT',
              p_usage                => NULL,
              p_orig_sys_document_ref=> p_x_header_rec.orig_sys_document_ref,
              p_orig_sys_line_ref    => p_x_line_rec.orig_sys_line_ref,
              p_order_source_id      => p_x_header_rec.order_source_id,
              p_org_id               => p_x_header_rec.org_id,
              x_customer_info_id     => l_customer_info_id,
              x_customer_info_number => l_customer_info_number,
              x_return_status        => l_return_status);

       If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RETURN ERROR IN CREATE CUSTOMER INFO FOR ACCOUNT' ) ;
          END IF;
          x_return_status  := l_return_status;
       Else
          p_x_header_rec.sold_to_org_id     :=  l_customer_info_id;
          OE_INLINE_CUSTOMER_PUB.G_SOLD_TO_CUST := l_customer_info_id;
          OE_MSG_PUB.set_msg_context(
            p_entity_code                => 'OI_INL_CUSTSUCC'
           ,p_entity_ref                 => null
           ,p_entity_id                  => null
           ,p_header_id                  => null
           ,p_line_id                    => null
           --,p_batch_request_id           => p_x_header_rec.request_id
           ,p_order_source_id            => p_x_header_rec.order_source_id
           ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
           ,p_change_sequence            => null
           ,p_orig_sys_document_line_ref => p_x_line_rec.orig_sys_line_ref
           ,p_orig_sys_shipment_ref      => p_customer_rec.orig_sys_customer_ref
           ,p_source_document_type_id    => null
           ,p_source_document_id         => null
           ,p_source_document_line_id    => null
           ,p_attribute_code             => null
           ,p_constraint_id              => null
          );
	  FND_MESSAGE.SET_NAME('ONT','ONT_OI_INL_REF_ADDED');
          FND_MESSAGE.SET_TOKEN('TYPE', 'Customer');
          FND_MESSAGE.SET_TOKEN('REF',p_customer_rec.orig_sys_customer_ref);
          Oe_Msg_Pub.Add;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'NEW CUST ACC. ID => ' || L_CUSTOMER_INFO_ID ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'NEW CUST ACC. NUM => ' || L_CUSTOMER_INFO_NUMBER ) ;
          END IF;
       End if;
     Else
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CUST DATA PASSED BUT PARAMETER NOT SET' ) ;
      END IF;
      fnd_message.set_name('ONT','ONT_OI_INL_SET_PARAMETER');
      fnd_message.set_token('TYPE', 'Customers');
      oe_msg_pub.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      Return;
     End If;
     -- End for Add customer privilege check}
    End If;
    -- End }

    -- { Start
    If p_customer_rec.orig_ship_address_ref is Not Null Then
       -- This Means New Address Need to be Added Call The
       -- api with this information and Type should be
       -- 'ADDRESS' for this call
       OE_INLINE_CUSTOMER_PUB.Create_Customer_Info(
              p_customer_info_ref    => p_customer_rec.orig_ship_address_ref,
              p_customer_info_type_code => 'ADDRESS',
              p_usage                => 'SHIP_TO',
              p_orig_sys_document_ref=> p_x_header_rec.orig_sys_document_ref,
              p_orig_sys_line_ref    => p_x_line_rec.orig_sys_line_ref,
              p_order_source_id      => p_x_header_rec.order_source_id,
              p_org_id               => p_x_header_rec.org_id,
              x_customer_info_id     => l_customer_info_id,
              x_customer_info_number => l_customer_info_number,
              x_return_status        => l_return_status);

       If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RETURN ERROR IN CREATE CUSTOMER INFO FOR ADDRESS' ) ;
          END IF;
          x_return_status  := l_return_status;
       Else
          If p_record_type = 'HEADER' Then
             p_x_header_rec.ship_to_org_id   :=  l_customer_info_id;
          Else
             p_x_line_rec.ship_to_org_id     :=  l_customer_info_id;
          End If;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'NEW SHIP ADDRESS ID => ' || L_CUSTOMER_INFO_ID ) ;
          END IF;
          OE_MSG_PUB.set_msg_context(
            p_entity_code                => 'OI_INL_CUSTSUCC'
           ,p_entity_ref                 => null
           ,p_entity_id                  => null
           ,p_header_id                  => null
           ,p_line_id                    => null
           --,p_batch_request_id           => p_x_header_rec.request_id
           ,p_order_source_id            => p_x_header_rec.order_source_id
           ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
           ,p_change_sequence            => null
           ,p_orig_sys_document_line_ref => p_x_line_rec.orig_sys_line_ref
           ,p_orig_sys_shipment_ref      => p_customer_rec.orig_ship_address_ref
           ,p_source_document_type_id    => null
           ,p_source_document_id         => null
           ,p_source_document_line_id    => null
           ,p_attribute_code             => null
           ,p_constraint_id              => null
          );
	  FND_MESSAGE.SET_NAME('ONT','ONT_OI_INL_REF_ADDED');
          FND_MESSAGE.SET_TOKEN('TYPE', 'Address');
          FND_MESSAGE.SET_TOKEN('REF',p_customer_rec.orig_ship_address_ref);
          Oe_Msg_Pub.Add;
       End if;
    End If;
    -- End }
    -- { Start
    If p_customer_rec.orig_bill_address_ref is Not Null Then
       -- This Means New Address Need to be Added Call The
       -- api with this information and Type should be
       -- 'ADDRESS' for this call
       OE_INLINE_CUSTOMER_PUB.Create_Customer_Info(
              p_customer_info_ref    => p_customer_rec.orig_bill_address_ref,
              p_customer_info_type_code => 'ADDRESS',
              p_usage                => 'BILL_TO',
              p_orig_sys_document_ref=> p_x_header_rec.orig_sys_document_ref,
              p_orig_sys_line_ref    => p_x_line_rec.orig_sys_line_ref,
              p_order_source_id      => p_x_header_rec.order_source_id,
              p_org_id               => p_x_header_rec.org_id,
              x_customer_info_id     => l_customer_info_id,
              x_customer_info_number => l_customer_info_number,
              x_return_status        => l_return_status);

       If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RETURN ERROR IN CREATE CUSTOMER INFO FOR ADDRESS' ) ;
          END IF;
          x_return_status  := l_return_status;
       Else
          If p_record_type = 'HEADER' Then
             p_x_header_rec.invoice_to_org_id   :=  l_customer_info_id;
          Else
             p_x_line_rec.invoice_to_org_id     :=  l_customer_info_id;
          End If;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'NEW INVOICE ADDRESS ID => ' || L_CUSTOMER_INFO_ID ) ;
          END IF;
          OE_MSG_PUB.set_msg_context(
            p_entity_code                => 'OI_INL_CUSTSUCC'
           ,p_entity_ref                 => null
           ,p_entity_id                  => null
           ,p_header_id                  => null
           ,p_line_id                    => null
           --,p_batch_request_id           => p_x_header_rec.request_id
           ,p_order_source_id            => p_x_header_rec.order_source_id
           ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
           ,p_change_sequence            => null
           ,p_orig_sys_document_line_ref => p_x_line_rec.orig_sys_line_ref
           ,p_orig_sys_shipment_ref      => p_customer_rec.orig_bill_address_ref
           ,p_source_document_type_id    => null
           ,p_source_document_id         => null
           ,p_source_document_line_id    => null
           ,p_attribute_code             => null
           ,p_constraint_id              => null
          );
	  FND_MESSAGE.SET_NAME('ONT','ONT_OI_INL_REF_ADDED');
          FND_MESSAGE.SET_TOKEN('TYPE', 'Address');
          FND_MESSAGE.SET_TOKEN('REF',p_customer_rec.orig_bill_address_ref);
          Oe_Msg_Pub.Add;
       End if;
    End If;
    -- End }
    -- { Start
    If p_customer_rec.orig_deliver_address_ref is Not Null Then
       -- This Means New Address Need to be Added Call The
       -- api with this information and Type should be
       -- 'ADDRESS' for this call
       OE_INLINE_CUSTOMER_PUB.Create_Customer_Info(
              p_customer_info_ref    => p_customer_rec.orig_deliver_address_ref,
              p_customer_info_type_code => 'ADDRESS',
              p_usage                => 'DELIVER_TO',
              p_orig_sys_document_ref=> p_x_header_rec.orig_sys_document_ref,
              p_orig_sys_line_ref    => p_x_line_rec.orig_sys_line_ref,
              p_order_source_id      => p_x_header_rec.order_source_id,
              p_org_id               => p_x_header_rec.org_id,
              x_customer_info_id     => l_customer_info_id,
              x_customer_info_number => l_customer_info_number,
              x_return_status        => l_return_status);

       If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RETURN ERROR IN CREATE CUSTOMER INFO FOR ADDRESS' ) ;
          END IF;
          x_return_status  := l_return_status;
       Else
          If p_record_type = 'HEADER' Then
             p_x_header_rec.deliver_to_org_id   :=  l_customer_info_id;
          Else
             p_x_line_rec.deliver_to_org_id     :=  l_customer_info_id;
          End If;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'NEW DELIVER ADDRESS ID => ' || L_CUSTOMER_INFO_ID ) ;
          END IF;
          OE_MSG_PUB.set_msg_context(
            p_entity_code                => 'OI_INL_CUSTSUCC'
           ,p_entity_ref                 => null
           ,p_entity_id                  => null
           ,p_header_id                  => null
           ,p_line_id                    => null
           --,p_batch_request_id           => p_x_header_rec.request_id
           ,p_order_source_id            => p_x_header_rec.order_source_id
           ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
           ,p_change_sequence            => null
           ,p_orig_sys_document_line_ref => p_x_line_rec.orig_sys_line_ref
           ,p_orig_sys_shipment_ref      => p_customer_rec.orig_deliver_address_ref
           ,p_source_document_type_id    => null
           ,p_source_document_id         => null
           ,p_source_document_line_id    => null
           ,p_attribute_code             => null
           ,p_constraint_id              => null
          );
	  FND_MESSAGE.SET_NAME('ONT','ONT_OI_INL_REF_ADDED');
          FND_MESSAGE.SET_TOKEN('TYPE', 'Address');
          FND_MESSAGE.SET_TOKEN('REF',p_customer_rec.orig_deliver_address_ref);
          Oe_Msg_Pub.Add;
       End if;
    End If;
    -- End }
    -- { Start
    If p_customer_rec.sold_to_contact_ref is Not Null Then
       -- This Means New Address Need to be Added Call The
       -- api with this information and Type should be
       -- 'CONTACT' for this call
       OE_INLINE_CUSTOMER_PUB.Create_Customer_Info(
                 p_customer_info_ref    => p_customer_rec.sold_to_contact_ref,
                 p_customer_info_type_code => 'CONTACT',
                 p_usage                => 'SOLD_TO',
                 p_orig_sys_document_ref=> p_x_header_rec.orig_sys_document_ref,
                 p_orig_sys_line_ref    => p_x_line_rec.orig_sys_line_ref,
                 p_order_source_id      => p_x_header_rec.order_source_id,
                 p_org_id               => p_x_header_rec.org_id,
                 x_customer_info_id     => l_customer_info_id,
                 x_customer_info_number => l_customer_info_number,
                 x_return_status        => l_return_status);

       If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RETURN ERROR IN CREATE CUSTOMER INFO FOR CONTACT' ) ;
          END IF;
          x_return_status  := l_return_status;
       Else
          If p_record_type = 'HEADER' Then
            p_x_header_rec.sold_to_contact_id   :=  l_customer_info_id;
          End If;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'NEW CONTACT ID => ' || L_CUSTOMER_INFO_ID ) ;
          END IF;
          OE_MSG_PUB.set_msg_context(
            p_entity_code                => 'OI_INL_CUSTSUCC'
           ,p_entity_ref                 => null
           ,p_entity_id                  => null
           ,p_header_id                  => null
           ,p_line_id                    => null
           --,p_batch_request_id           => p_x_header_rec.request_id
           ,p_order_source_id            => p_x_header_rec.order_source_id
           ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
           ,p_change_sequence            => null
           ,p_orig_sys_document_line_ref => p_x_line_rec.orig_sys_line_ref
           ,p_orig_sys_shipment_ref      => p_customer_rec.sold_to_contact_ref
           ,p_source_document_type_id    => null
           ,p_source_document_id         => null
           ,p_source_document_line_id    => null
           ,p_attribute_code             => null
           ,p_constraint_id              => null
          );
	  FND_MESSAGE.SET_NAME('ONT','ONT_OI_INL_REF_ADDED');
          FND_MESSAGE.SET_TOKEN('TYPE', 'Contact');
          FND_MESSAGE.SET_TOKEN('REF',p_customer_rec.sold_to_contact_ref);
          Oe_Msg_Pub.Add;
       End if;
    End If;
    -- End }
    -- { Start
    If p_customer_rec.ship_to_contact_ref is Not Null Then
       -- This Means New Address Need to be Added Call The
       -- api with this information and Type should be
       -- 'CONTACT' for this call
       OE_INLINE_CUSTOMER_PUB.Create_Customer_Info(
                 p_customer_info_ref    => p_customer_rec.ship_to_contact_ref,
                 p_customer_info_type_code => 'CONTACT',
                 p_usage                => 'SHIP_TO',
                 p_orig_sys_document_ref=> p_x_header_rec.orig_sys_document_ref,
                 p_orig_sys_line_ref    => p_x_line_rec.orig_sys_line_ref,
                 p_order_source_id      => p_x_header_rec.order_source_id,
                 p_org_id               => p_x_header_rec.org_id,
                 x_customer_info_id     => l_customer_info_id,
                 x_customer_info_number => l_customer_info_number,
                 x_return_status        => l_return_status);

       If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RETURN ERROR IN CREATE CUSTOMER INFO FOR CONTACT' ) ;
          END IF;
          x_return_status  := l_return_status;
       Else
          If p_record_type = 'HEADER' Then
            p_x_header_rec.ship_to_contact_id   :=  l_customer_info_id;
          Else
            p_x_line_rec.ship_to_contact_id     :=  l_customer_info_id;
          End If;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'NEW CONTACT ID => ' || L_CUSTOMER_INFO_ID ) ;
          END IF;
          OE_MSG_PUB.set_msg_context(
            p_entity_code                => 'OI_INL_CUSTSUCC'
           ,p_entity_ref                 => null
           ,p_entity_id                  => null
           ,p_header_id                  => null
           ,p_line_id                    => null
           --,p_batch_request_id           => p_x_header_rec.request_id
           ,p_order_source_id            => p_x_header_rec.order_source_id
           ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
           ,p_change_sequence            => null
           ,p_orig_sys_document_line_ref => p_x_line_rec.orig_sys_line_ref
           ,p_orig_sys_shipment_ref      => p_customer_rec.ship_to_contact_ref
           ,p_source_document_type_id    => null
           ,p_source_document_id         => null
           ,p_source_document_line_id    => null
           ,p_attribute_code             => null
           ,p_constraint_id              => null
          );
	  FND_MESSAGE.SET_NAME('ONT','ONT_OI_INL_REF_ADDED');
          FND_MESSAGE.SET_TOKEN('TYPE', 'Contact');
          FND_MESSAGE.SET_TOKEN('REF',p_customer_rec.ship_to_contact_ref);
          Oe_Msg_Pub.Add;
       End if;
    End If;
    -- End }
    -- { Start
    If p_customer_rec.bill_to_contact_ref is Not Null Then
       -- This Means New Address Need to be Added Call The
       -- api with this information and Type should be
       -- 'CONTACT' for this call
       OE_INLINE_CUSTOMER_PUB.Create_Customer_Info(
                 p_customer_info_ref    => p_customer_rec.bill_to_contact_ref,
                 p_customer_info_type_code => 'CONTACT',
                 p_usage                => 'BILL_TO',
                 p_orig_sys_document_ref=> p_x_header_rec.orig_sys_document_ref,
                 p_orig_sys_line_ref    => p_x_line_rec.orig_sys_line_ref,
                 p_order_source_id      => p_x_header_rec.order_source_id,
                 p_org_id               => p_x_header_rec.org_id,
                 x_customer_info_id     => l_customer_info_id,
                 x_customer_info_number => l_customer_info_number,
                 x_return_status        => l_return_status);

       If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RETURN ERROR IN CREATE CUSTOMER INFO FOR CONTACT' ) ;
          END IF;
          x_return_status  := l_return_status;
       Else
          If p_record_type = 'HEADER' Then
            p_x_header_rec.invoice_to_contact_id   :=  l_customer_info_id;
          Else
            p_x_line_rec.invoice_to_contact_id     :=  l_customer_info_id;
          End If;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'NEW CONTACT ID => ' || L_CUSTOMER_INFO_ID ) ;
          END IF;
          OE_MSG_PUB.set_msg_context(
            p_entity_code                => 'OI_INL_CUSTSUCC'
           ,p_entity_ref                 => null
           ,p_entity_id                  => null
           ,p_header_id                  => null
           ,p_line_id                    => null
           --,p_batch_request_id           => p_x_header_rec.request_id
           ,p_order_source_id            => p_x_header_rec.order_source_id
           ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
           ,p_change_sequence            => null
           ,p_orig_sys_document_line_ref => p_x_line_rec.orig_sys_line_ref
           ,p_orig_sys_shipment_ref      => p_customer_rec.bill_to_contact_ref
           ,p_source_document_type_id    => null
           ,p_source_document_id         => null
           ,p_source_document_line_id    => null
           ,p_attribute_code             => null
           ,p_constraint_id              => null
          );
	  FND_MESSAGE.SET_NAME('ONT','ONT_OI_INL_REF_ADDED');
          FND_MESSAGE.SET_TOKEN('TYPE', 'Contact');
          FND_MESSAGE.SET_TOKEN('REF',p_customer_rec.bill_to_contact_ref);
          Oe_Msg_Pub.Add;
       End if;
    End If;
    -- End }
    -- { Start
    If p_customer_rec.deliver_to_contact_ref is Not Null Then
       -- This Means New Address Need to be Added Call The
       -- api with this information and Type should be
       -- 'CONTACT' for this call
       OE_INLINE_CUSTOMER_PUB.Create_Customer_Info(
                 p_customer_info_ref   => p_customer_rec.deliver_to_contact_ref,
                 p_customer_info_type_code => 'CONTACT',
                 p_usage                => 'DELVER_TO',
                 p_orig_sys_document_ref=> p_x_header_rec.orig_sys_document_ref,
                 p_orig_sys_line_ref    => p_x_line_rec.orig_sys_line_ref,
                 p_order_source_id      => p_x_header_rec.order_source_id,
                 p_org_id               => p_x_header_rec.org_id,
                 x_customer_info_id     => l_customer_info_id,
                 x_customer_info_number => l_customer_info_number,
                 x_return_status        => l_return_status);

       If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RETURN ERROR IN CREATE CUSTOMER INFO FOR CONTACT' ) ;
          END IF;
          x_return_status  := l_return_status;
       Else
          If p_record_type = 'HEADER' Then
            p_x_header_rec.deliver_to_contact_id   :=  l_customer_info_id;
          Else
            p_x_line_rec.deliver_to_contact_id     :=  l_customer_info_id;
          End If;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'NEW CONTACT ID => ' || L_CUSTOMER_INFO_ID ) ;
          END IF;
          OE_MSG_PUB.set_msg_context(
            p_entity_code                => 'OI_INL_CUSTSUCC'
           ,p_entity_ref                 => null
           ,p_entity_id                  => null
           ,p_header_id                  => null
           ,p_line_id                    => null
           --,p_batch_request_id           => p_x_header_rec.request_id
           ,p_order_source_id            => p_x_header_rec.order_source_id
           ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
           ,p_change_sequence            => null
           ,p_orig_sys_document_line_ref => p_x_line_rec.orig_sys_line_ref
           ,p_orig_sys_shipment_ref      => p_customer_rec.deliver_to_contact_ref
           ,p_source_document_type_id    => null
           ,p_source_document_id         => null
           ,p_source_document_line_id    => null
           ,p_attribute_code             => null
           ,p_constraint_id              => null
          );
	  FND_MESSAGE.SET_NAME('ONT','ONT_OI_INL_REF_ADDED');
          FND_MESSAGE.SET_TOKEN('TYPE', 'Contact');
          FND_MESSAGE.SET_TOKEN('REF',p_customer_rec.deliver_to_contact_ref);
          Oe_Msg_Pub.Add;
       End if;
    End If;
    -- End }


    IF l_tca_bus_events <> 'N' THEN --bug 6052896
	 fnd_profile.put('HZ_EXECUTE_API_CALLOUTS',l_tca_bus_events);
    End if;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING PROCEDURE CREATE NEW CUST INFO' ) ;
    END IF;
    -- End Check for each column of the record and }

END Create_New_Cust_Info;
--  End Create New Cust Info Procedure}



PROCEDURE CHECK_DERIVED_FLAGS(
   p_x_header_rec              IN OUT NOCOPY OE_Order_Pub.Header_Rec_Type
  ,p_x_header_adj_tbl          IN OUT NOCOPY OE_Order_Pub.Header_Adj_Tbl_Type
  ,p_x_header_price_att_tbl    IN OUT NOCOPY OE_Order_Pub.Header_Price_Att_Tbl_Type
  ,p_x_header_adj_att_tbl      IN OUT NOCOPY OE_Order_Pub.Header_Adj_Att_Tbl_Type
  ,p_x_header_adj_assoc_tbl    IN OUT NOCOPY OE_Order_Pub.Header_Adj_Assoc_Tbl_Type
  ,p_x_header_scredit_tbl      IN OUT NOCOPY OE_Order_Pub.Header_Scredit_Tbl_Type
  ,p_x_header_payment_tbl      IN OUT NOCOPY OE_Order_Pub.Header_Payment_Tbl_Type
  ,p_x_line_tbl                IN OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
  ,p_x_line_adj_tbl            IN OUT NOCOPY OE_Order_Pub.Line_Adj_Tbl_Type
  ,p_x_line_price_att_tbl      IN OUT NOCOPY OE_Order_Pub.Line_Price_Att_Tbl_Type
  ,p_x_line_adj_att_tbl        IN OUT NOCOPY OE_Order_Pub.Line_Adj_Att_Tbl_Type
  ,p_x_line_adj_assoc_tbl      IN OUT NOCOPY OE_Order_Pub.Line_Adj_Assoc_Tbl_Type
  ,p_x_line_scredit_tbl        IN OUT NOCOPY OE_Order_Pub.Line_Scredit_Tbl_Type
  ,p_x_line_payment_tbl        IN OUT NOCOPY OE_Order_Pub.Line_Payment_Tbl_Type
  ,p_x_lot_serial_tbl          IN OUT NOCOPY OE_Order_Pub.Lot_Serial_Tbl_Type
  ,p_x_reservation_tbl         IN OUT NOCOPY OE_Order_Pub.Reservation_Tbl_Type
  ,p_x_header_val_rec          IN OUT NOCOPY OE_Order_Pub.Header_Val_Rec_Type
  ,p_x_header_adj_val_tbl      IN OUT NOCOPY OE_Order_Pub.Header_Adj_Val_Tbl_Type
  ,p_x_header_scredit_val_tbl  IN OUT NOCOPY OE_Order_Pub.Header_Scredit_Val_Tbl_Type
  ,p_x_header_payment_val_tbl  IN OUT NOCOPY OE_Order_Pub.Header_Payment_Val_Tbl_Type
  ,p_x_line_val_tbl            IN OUT NOCOPY OE_Order_Pub.Line_Val_Tbl_Type
  ,p_x_line_adj_val_tbl        IN OUT NOCOPY OE_Order_Pub.Line_Adj_Val_Tbl_Type
  ,p_x_line_scredit_val_tbl    IN OUT NOCOPY OE_Order_Pub.Line_Scredit_Val_Tbl_Type
  ,p_x_line_payment_val_tbl    IN OUT NOCOPY OE_Order_Pub.Line_Payment_Val_Tbl_Type
  ,p_x_lot_serial_val_tbl      IN OUT NOCOPY OE_Order_Pub.Lot_Serial_Val_Tbl_Type
  ,p_x_reservation_val_tbl     IN OUT NOCOPY OE_Order_Pub.Reservation_Val_Tbl_Type
,p_x_return_status OUT NOCOPY VARCHAR2

 ) IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'INSIDE CHECK_DERIVED_FLAGS' ) ;
  END IF;

/*
 -----------------------------------------------------------
   Set message context
 -----------------------------------------------------------
*/

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT' ) ;
   END IF;
   OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'HEADER'
        ,p_entity_ref                 => null
        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => null
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => null
        ,p_orig_sys_shipment_ref      => null
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

/*
  ----------------------------------------------------------------------
  Check for Header Record
  ----------------------------------------------------------------------
*/

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'VERSION_NUMBER = '||P_X_HEADER_REC.VERSION_NUMBER ) ;
   END IF;
   IF  p_x_header_rec.version_number <> FND_API.G_MISS_NUM
   THEN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN VERSION_NUMBER... ' ) ;
	END IF;
	FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
     FND_MESSAGE.SET_TOKEN('DERIVED_COL','VERSION_NUMBER');
     OE_MSG_PUB.Add;
--	p_x_return_status := FND_API.G_RET_STS_ERROR;
--	p_x_header_rec.version_number := FND_API.G_MISS_NUM;
   END IF;

   IF  p_x_header_rec.EARLIEST_SCHEDULE_LIMIT <> FND_API.G_MISS_NUM
   THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN EARLIEST_SCHEDULE_LIMIT... ' ) ;
     END IF;
	FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
     FND_MESSAGE.SET_TOKEN('DERIVED_COL','EARLIEST_SCHEDULE_LIMIT');
     OE_MSG_PUB.Add;
--	p_x_return_status := FND_API.G_RET_STS_ERROR;
--	p_x_header_rec.EARLIEST_SCHEDULE_LIMIT := FND_API.G_MISS_NUM;
   END IF;

   IF  p_x_header_rec.FREIGHT_CARRIER_CODE <> FND_API.G_MISS_CHAR
   THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN FREIGHT_CARRIER_CODE... ' ) ;
     END IF;
	FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
     FND_MESSAGE.SET_TOKEN('DERIVED_COL','FREIGHT_CARRIER_CODE');
     OE_MSG_PUB.Add;
--	p_x_return_status := FND_API.G_RET_STS_ERROR;
--	p_x_header_rec.FREIGHT_CARRIER_CODE := FND_API.G_MISS_CHAR;
   END IF;

   IF  p_x_header_rec.ORG_ID <> FND_API.G_MISS_NUM
   AND p_x_header_rec.order_source_id <> OE_GLOBALS.G_ORDER_SOURCE_INTERNAL
   THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN ORG_ID... ' ) ;
     END IF;
--	FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--   FND_MESSAGE.SET_TOKEN('DERIVED_COL','ORG_ID');
--   OE_MSG_PUB.Add;
--	p_x_return_status := FND_API.G_RET_STS_ERROR;
--	p_x_header_rec.ORG_ID := FND_API.G_MISS_NUM;
   END IF;

   IF  p_x_header_rec.PARTIAL_SHIPMENTS_ALLOWED <> FND_API.G_MISS_CHAR
   THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN PARTIAL_SHIPMENTS_ALLOWED... ' ) ;
     END IF;
	FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
     FND_MESSAGE.SET_TOKEN('DERIVED_COL','PARTIAL_SHIPMENTS_ALLOWED');
     OE_MSG_PUB.Add;
--	p_x_return_status := FND_API.G_RET_STS_ERROR;
--	p_x_header_rec.ORG_ID := FND_API.G_MISS_CHAR;
   END IF;

   IF  p_x_header_rec.CHANGE_REQUEST_CODE <> FND_API.G_MISS_CHAR
   THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN CHANGE_REQUEST_CODE... ' ) ;
     END IF;
--   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--   FND_MESSAGE.SET_TOKEN('DERIVED_COL','CHANGE_REQUEST_CODE');
--   OE_MSG_PUB.Add;
--	p_x_return_status := FND_API.G_RET_STS_ERROR;
--	p_x_header_rec.CHANGE_REQUEST_CODE := FND_API.G_MISS_CHAR;
   END IF;

   IF  p_x_header_rec.DROP_SHIP_FLAG <> FND_API.G_MISS_CHAR
   THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN DROP_SHIP_FLAG... ' ) ;
     END IF;
--	FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--   FND_MESSAGE.SET_TOKEN('DERIVED_COL','DROP_SHIP_FLAG');
--   OE_MSG_PUB.Add;
--	p_x_return_status := FND_API.G_RET_STS_ERROR;
--	p_x_header_rec.CHANGE_REQUEST_CODE := FND_API.G_MISS_CHAR;
   END IF;

   IF  p_x_header_rec.CREDIT_CARD_APPROVAL_CODE <> FND_API.G_MISS_CHAR
   THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN CREDIT_CARD_APPROVAL_CODE... ' ) ;
     END IF;
--   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--   FND_MESSAGE.SET_TOKEN('DERIVED_COL','CREDIT_CARD_APPROVAL_CODE');
--   OE_MSG_PUB.Add;
--	p_x_return_status := FND_API.G_RET_STS_ERROR;
--	p_x_header_rec.CHANGE_REQUEST_CODE := FND_API.G_MISS_CHAR;
   END IF;

   IF  p_x_header_rec.CREDIT_CARD_APPROVAL_DATE <> FND_API.G_MISS_DATE
   THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN CREDIT_CARD_APPROVAL_DATE... ' ) ;
     END IF;
--   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--   FND_MESSAGE.SET_TOKEN('DERIVED_COL','CREDIT_CARD_APPROVAL_DATE');
--   OE_MSG_PUB.Add;
--	p_x_return_status := FND_API.G_RET_STS_ERROR;
--	p_x_header_rec.CHANGE_REQUEST_CODE := FND_API.G_MISS_DATE;
   END IF;

--added for bug3645778
    oe_debug_pub.add(' in CHECK_DERIVED_FLAGS , operation : '||p_x_header_rec.OPERATION);
    oe_debug_pub.add(' cancelled flag :'||p_x_header_rec.cancelled_flag||'**');
    IF  ( p_x_header_rec.CANCELLED_FLAG='Y'
 		and
         (p_x_header_rec.OPERATION<>OE_GLOBALS.G_OPR_UPDATE))
   THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CANCELLATION IS NOT ALLOWED WHILE CREATING AN ORDER... ' ) ;
     END IF;
     FND_MESSAGE.SET_NAME('ONT','OE_CANCEL_NO_CREATE');
     OE_MSG_PUB.Add;
     p_x_return_status := FND_API.G_RET_STS_ERROR;
     p_x_header_rec.CANCELLED_FLAG := FND_API.G_MISS_CHAR;
   END IF;

--end bug3645778


/*
  ----------------------------------------------------------------------
  Check for Line Record
  ----------------------------------------------------------------------
*/

   FOR I in 1..p_x_line_tbl.count
   LOOP
/* -----------------------------------------------------------
      Set message context for the line
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT FOR THE LINE' ) ;
      END IF;

      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'LINE'
        ,p_entity_ref                 => null
        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => p_x_line_tbl(I).line_id
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => p_x_line_tbl(I).orig_sys_line_ref
        ,p_orig_sys_shipment_ref      => p_x_line_tbl(I).orig_sys_shipment_ref
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

      IF p_x_line_tbl(I).ACTUAL_ARRIVAL_DATE <> FND_API.G_MISS_DATE
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN ACTUAL_ARRIVAL_DATE... ' ) ;
        END IF;
--      FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--      FND_MESSAGE.SET_TOKEN('DERIVED_COL','ACTUAL_ARRIVAL_DATE');
--      OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).ACTUAL_ARRIVAL_DATE := FND_API.G_MISS_DATE;
      END IF;

      IF p_x_line_tbl(I).ATO_LINE_ID <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN ATO_LINE_ID... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--      FND_MESSAGE.SET_TOKEN('DERIVED_COL','ATO_LINE_ID');
--      OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).ATO_LINE_ID := FND_API.G_MISS_NUM;
      END IF;
--for bug 3415653 uncommented the statements which set status to error for cancelled_flag and cancelled_quantity
      IF p_x_line_tbl(I).CANCELLED_FLAG <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN CANCELLED_FLAG... ' ) ;
        END IF;
	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
        FND_MESSAGE.SET_TOKEN('DERIVED_COL','CANCELLED_FLAG');
        OE_MSG_PUB.Add;
	   p_x_return_status := FND_API.G_RET_STS_ERROR;
	   p_x_line_tbl(I).CANCELLED_FLAG := FND_API.G_MISS_CHAR;
      END IF;

      IF p_x_line_tbl(I).CANCELLED_QUANTITY <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN CANCELLED_QUANTITY... ' ) ;
        END IF;
	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
        FND_MESSAGE.SET_TOKEN('DERIVED_COL','CANCELLED_QUANTITY');
        OE_MSG_PUB.Add;
	   p_x_return_status := FND_API.G_RET_STS_ERROR;
	   p_x_line_tbl(I).CANCELLED_QUANTITY := FND_API.G_MISS_NUM;
      END IF;

	 IF p_x_line_tbl(I).COMPONENT_SEQUENCE_ID <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN COMPONENT_SEQUENCE_ID... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--      FND_MESSAGE.SET_TOKEN('DERIVED_COL','COMPONENT_SEQUENCE_ID');
--      OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).COMPONENT_SEQUENCE_ID := FND_API.G_MISS_NUM;
      END IF;

	 IF p_x_line_tbl(I).CREDIT_INVOICE_LINE_ID <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN CREDIT_INVOICE_LINE_ID... ' ) ;
        END IF;
	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
        FND_MESSAGE.SET_TOKEN('DERIVED_COL','CREDIT_INVOICE_LINE_ID');
        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).CREDIT_INVOICE_LINE_ID := FND_API.G_MISS_NUM;
      END IF;

	 IF p_x_line_tbl(I).EXPLOSION_DATE <> FND_API.G_MISS_DATE
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN EXPLOSION_DATE... ' ) ;
        END IF;
	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
        FND_MESSAGE.SET_TOKEN('DERIVED_COL','EXPLOSION_DATE');
        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).EXPLOSION_DATE := FND_API.G_MISS_DATE;
      END IF;

	 IF p_x_line_tbl(I).FULFILLED_QUANTITY <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN FULFILLED_QUANTITY... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--      FND_MESSAGE.SET_TOKEN('DERIVED_COL','FULFILLED_QUANTITY');
--      OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).FULFILLED_QUANTITY := FND_API.G_MISS_NUM;
      END IF;
/*
	 IF  p_x_line_tbl(I).ITEM_TYPE_CODE <> FND_API.G_MISS_CHAR
      AND p_x_header_rec.order_source_id <> OE_GLOBALS.G_ORDER_SOURCE_INTERNAL
      THEN
        oe_debug_pub.add('Cannot populate derived column ITEM_TYPE_CODE... ');
	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
        FND_MESSAGE.SET_TOKEN('DERIVED_COL','ITEM_TYPE_CODE');
        OE_MSG_PUB.Add;
	   p_x_return_status := FND_API.G_RET_STS_ERROR;
	   p_x_line_tbl(I).ITEM_TYPE_CODE := FND_API.G_MISS_CHAR;
      END IF;
*/

	 IF p_x_line_tbl(I).MODEL_GROUP_NUMBER <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN MODEL_GROUP_NUMBER... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','MODEL_GROUP_NUMBER');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).MODEL_GROUP_NUMBER := FND_API.G_MISS_NUM;
      END IF;

	 IF p_x_line_tbl(I).OPTION_NUMBER <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN OPTION_NUMBER... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','OPTION_NUMBER');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).OPTION_NUMBER := FND_API.G_MISS_NUM;
      END IF;

	 IF  p_x_line_tbl(I).ORG_ID <> FND_API.G_MISS_NUM
      AND p_x_header_rec.order_source_id <> OE_GLOBALS.G_ORDER_SOURCE_INTERNAL
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN ORG_ID... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','ORG_ID');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).ORG_ID := FND_API.G_MISS_NUM;
      END IF;

	 IF p_x_line_tbl(I).PRICING_CONTEXT <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN PRICING_CONTEXT... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','PRICING_CONTEXT');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).PRICING_CONTEXT := FND_API.G_MISS_CHAR;
      END IF;

	 IF p_x_line_tbl(I).PRICING_QUANTITY <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN PRICING_QUANTITY... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','PRICING_QUANTITY');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).PRICING_QUANTITY := FND_API.G_MISS_NUM;
      END IF;

	 IF p_x_line_tbl(I).PRICING_QUANTITY_UOM <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN PRICING_QUANTITY_UOM... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','PRICING_QUANTITY_UOM');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).PRICING_QUANTITY_UOM := FND_API.G_MISS_CHAR;
      END IF;

	 IF p_x_line_tbl(I).REFERENCE_TYPE <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN REFERENCE_TYPE... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','REFERENCE_TYPE');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).REFERENCE_TYPE := FND_API.G_MISS_CHAR;
      END IF;

	 IF p_x_line_tbl(I).REFERENCE_HEADER_ID <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN REFERENCE_HEADER_ID... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','REFERENCE_HEADER_ID');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).REFERENCE_HEADER_ID := FND_API.G_MISS_NUM;
      END IF;

	 IF p_x_line_tbl(I).REFERENCE_LINE_ID <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN REFERENCE_LINE_ID... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','REFERENCE_LINE_ID');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).REFERENCE_LINE_ID := FND_API.G_MISS_NUM;
      END IF;

	 IF p_x_line_tbl(I).SCHEDULE_STATUS_CODE <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN SCHEDULE_STATUS_CODE... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','SCHEDULE_STATUS_CODE');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).SCHEDULE_STATUS_CODE := FND_API.G_MISS_CHAR;
      END IF;

	 IF p_x_line_tbl(I).SHIPMENT_NUMBER <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN SHIPMENT_NUMBER... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','SHIPMENT_NUMBER');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).SHIPMENT_NUMBER := FND_API.G_MISS_NUM;
      END IF;

	 IF p_x_line_tbl(I).SHIPPED_QUANTITY <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN SHIPPED_QUANTITY... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','SHIPPED_QUANTITY');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).SHIPPED_QUANTITY := FND_API.G_MISS_NUM;
      END IF;

	 IF p_x_line_tbl(I).SHIPPING_QUANTITY <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN SHIPPING_QUANTITY... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','SHIPPING_QUANTITY');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).SHIPPING_QUANTITY := FND_API.G_MISS_NUM;
      END IF;

	 IF p_x_line_tbl(I).SHIPPING_QUANTITY_UOM <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN SHIPPING_QUANTITY_UOM... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','SHIPPING_QUANTITY_UOM');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).SHIPPING_QUANTITY_UOM := FND_API.G_MISS_CHAR;
      END IF;

	 IF p_x_line_tbl(I).SHIP_MODEL_COMPLETE_FLAG <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN SHIP_MODEL_COMPLETE_FLAG... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','SHIP_MODEL_COMPLETE_FLAG');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).SHIP_MODEL_COMPLETE_FLAG := FND_API.G_MISS_CHAR;
      END IF;

	 IF p_x_line_tbl(I).SORT_ORDER <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN SORT_ORDER... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','SORT_ORDER');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).SORT_ORDER := FND_API.G_MISS_CHAR;
      END IF;

	 IF p_x_line_tbl(I).TAX_VALUE <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN TAX_VALUE... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','TAX_VALUE');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).TAX_VALUE := FND_API.G_MISS_NUM;
      END IF;

	 IF p_x_line_tbl(I).CHANGE_REQUEST_CODE <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN CHANGE_REQUEST_CODE... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','CHANGE_REQUEST_CODE');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).CHANGE_REQUEST_CODE := FND_API.G_MISS_CHAR;
      END IF;

	 IF p_x_line_tbl(I).STATUS_FLAG <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN STATUS_FLAG... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','STATUS_FLAG');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).STATUS_FLAG := FND_API.G_MISS_CHAR;
      END IF;

	 IF p_x_line_tbl(I).DROP_SHIP_FLAG <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN DROP_SHIP_FLAG... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','DROP_SHIP_FLAG');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).DROP_SHIP_FLAG := FND_API.G_MISS_CHAR;
      END IF;

	 IF p_x_line_tbl(I).UNIT_PERCENT_BASE_PRICE <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN UNIT_PERCENT_BASE_PRICE... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','UNIT_PERCENT_BASE_PRICE');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).UNIT_PERCENT_BASE_PRICE := FND_API.G_MISS_NUM;
      END IF;

	 IF p_x_line_tbl(I).SERVICE_NUMBER <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN SERVICE_NUMBER... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','SERVICE_NUMBER');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_tbl(I).SERVICE_NUMBER := FND_API.G_MISS_NUM;
      END IF;

   END LOOP;

/*
  ----------------------------------------------------------------------
  Check for Header Adjustments Record
  ----------------------------------------------------------------------
*/

   FOR I in 1..p_x_header_adj_tbl.count
   LOOP
/* -----------------------------------------------------------
      Set message context for header adjustments
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT FOR HEADER ADJUSTMENTS' ) ;
      END IF;

      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'HEADER_ADJ'
        ,p_entity_ref                 => p_x_header_adj_tbl(I).orig_sys_discount_ref
        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => null
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => null
        ,p_orig_sys_shipment_ref      => null
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING HEADER ADJ DERIVED COLUMNS' ) ;
      END IF;

      IF p_x_header_adj_tbl(I).discount_id <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN DISCOUNT_ID... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','DISCOUNT_ID');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_header_adj_tbl(I).discount_id := FND_API.G_MISS_NUM;
      END IF;

      IF p_x_header_adj_tbl(I).DISCOUNT_LINE_ID <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN DISCOUNT_LINE_ID... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','DISCOUNT_LINE_ID');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_header_adj_tbl(I).DISCOUNT_LINE_ID := FND_API.G_MISS_NUM;
      END IF;

      IF p_x_header_adj_tbl(I).PERCENT <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN PERCENT... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','PERCENT');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_header_adj_tbl(I).PERCENT := FND_API.G_MISS_NUM;
      END IF;

      IF p_x_header_adj_tbl(I).CHANGE_REQUEST_CODE <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN CHANGE_REQUEST_CODE... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','CHANGE_REQUEST_CODE');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_header_adj_tbl(I).CHANGE_REQUEST_CODE := FND_API.G_MISS_CHAR;
      END IF;

      IF p_x_header_adj_tbl(I).STATUS_FLAG <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN STATUS_FLAG... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','STATUS_FLAG');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_header_adj_tbl(I).STATUS_FLAG := FND_API.G_MISS_CHAR;
      END IF;

   END LOOP;



/*
  ----------------------------------------------------------------------
  Check for Header Price Att  Record
  ----------------------------------------------------------------------
*/

   FOR I in 1..p_x_header_price_att_tbl.count
   LOOP
/* -----------------------------------------------------------
      Set message context for header attribute
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT FOR HEADER ATTRIBUTE' ) ;
      END IF;

      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'HEADER_PATTS'
        ,p_entity_ref                 => p_x_header_price_att_tbl(I).orig_sys_atts_ref

        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => null
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => null
        ,p_orig_sys_shipment_ref      => null
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );
----  Derived columns to be found
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING HEADER ATT DERIVED COLUMNS' ) ;
      END IF;

      IF p_x_header_price_att_tbl(I).order_price_attrib_id <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN DISCOUNT_ID... ' ) ;
        END IF;
      END IF;
/*
      IF p_x_header_price_att_tbl(I).ORG_ID <> FND_API.G_MISS_NUM
      THEN
        oe_debug_pub.add('Cannot populate derived column ORG_ID... ');
      END IF;

      IF p_x_header_price_att_tbl(I).PRICING_CONTEXT <> FND_API.G_MISS_CHAR
      THEN
        oe_debug_pub.add('Cannot populate derived column PRICING_CONTEXT ');
      END IF;
*/
      IF p_x_header_price_att_tbl(I).CHANGE_REQUEST_CODE <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN CHANGE_REQUEST_CODE... ' ) ;
        END IF;
      END IF;
/*
      IF p_x_header_price_att_tbl(I).STATUS_FLAG <> FND_API.G_MISS_CHAR
      THEN
        oe_debug_pub.add('Cannot populate derived column STATUS_FLAG... ');
      END IF;
*/
   END LOOP;

/*
  ----------------------------------------------------------------------
  Check for Header Sales Credits Record
  ----------------------------------------------------------------------
*/


   FOR I in 1..p_x_header_scredit_tbl.count
   LOOP
/* -----------------------------------------------------------
      Set message context for header sales credits
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT FOR HEADER SALES CREDITS' ) ;
      END IF;

      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'HEADER_SCREDIT'
        ,p_entity_ref                 => p_x_header_scredit_tbl(I).orig_sys_credit_ref
        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => null
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => null
        ,p_orig_sys_shipment_ref      => null
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING HEADER SALES CREDIT DERIVED COLS' ) ;
      END IF;

      IF p_x_header_scredit_tbl(I).CHANGE_REQUEST_CODE <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN CHANGE_REQUEST_CODE... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','CHANGE_REQUEST_CODE');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_header_scredit_tbl(I).CHANGE_REQUEST_CODE := FND_API.G_MISS_CHAR;
      END IF;

      IF p_x_header_scredit_tbl(I).STATUS_FLAG <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN STATUS_FLAG... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','STATUS_FLAG');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_header_scredit_tbl(I).STATUS_FLAG := FND_API.G_MISS_CHAR;
      END IF;

   END LOOP;


/*
  ----------------------------------------------------------------------
  Check for Header Payment Record -- multiple payments project
  ----------------------------------------------------------------------
*/


   FOR I in 1..p_x_header_payment_tbl.count
   LOOP
/* -----------------------------------------------------------
      Set message context for header payment
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT FOR HEADER PAYMENTS' ) ;
      END IF;

      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'HEADER_PAYMENT'
        ,p_entity_ref                 => p_x_header_payment_tbl(I).orig_sys_payment_ref
        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => null
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => null
        ,p_orig_sys_shipment_ref      => null
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING HEADER PAYMENT DERIVED COLS' ) ;
      END IF;

      IF p_x_header_payment_tbl(I).CHANGE_REQUEST_CODE <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN CHANGE_REQUEST_CODE... ' ) ;
        END IF;
      END IF;

      IF p_x_header_payment_tbl(I).STATUS_FLAG <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN STATUS_FLAG... ' ) ;
        END IF;
      END IF;

   END LOOP;
-- end of multiple payments: header payment

/*
  ----------------------------------------------------------------------
  Check for Lines Discounts/Price Adjustments Record
  ----------------------------------------------------------------------
*/

   FOR I in 1..p_x_line_adj_tbl.count
   LOOP
/* -----------------------------------------------------------
      Set message context for line price adjustments
   -----------------------------------------------------------
*/

      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'LINE_ADJ'
        ,p_entity_ref                 => p_x_line_adj_tbl(I).orig_sys_discount_ref
        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => p_x_line_tbl(p_x_line_adj_tbl(I).line_index).line_id
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => p_x_line_tbl(p_x_line_adj_tbl(I).line_index).orig_sys_line_ref
        ,p_orig_sys_shipment_ref      => p_x_line_tbl(p_x_line_adj_tbl(I).line_index).orig_sys_shipment_ref
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

      IF p_x_line_adj_tbl(I).DISCOUNT_ID <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN DISCOUNT_ID... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','DISCOUNT_ID');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_adj_tbl(I).DISCOUNT_ID := FND_API.G_MISS_NUM;
      END IF;

      IF p_x_line_adj_tbl(I).DISCOUNT_LINE_ID <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN DISCOUNT_LINE_ID... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','DISCOUNT_LINE_ID');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_adj_tbl(I).DISCOUNT_LINE_ID := FND_API.G_MISS_NUM;
      END IF;

      IF p_x_line_adj_tbl(I).PERCENT <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN PERCENT... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','PERCENT');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_adj_tbl(I).PERCENT := FND_API.G_MISS_NUM;
      END IF;

      IF p_x_line_adj_tbl(I).APPLIED_FLAG <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN APPLIED_FLAG... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
 --       FND_MESSAGE.SET_TOKEN('DERIVED_COL','APPLIED_FLAG');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_adj_tbl(I).APPLIED_FLAG := FND_API.G_MISS_CHAR;
      END IF;

      IF p_x_line_adj_tbl(I).ARITHMETIC_OPERATOR <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN ARITHMETIC_OPERATOR... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','ARITHMETIC_OPERATOR');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_adj_tbl(I).ARITHMETIC_OPERATOR := FND_API.G_MISS_CHAR;
      END IF;

   END LOOP;


/*
  ----------------------------------------------------------------------
  Check for Line Price Att  Record
  ----------------------------------------------------------------------
*/

   FOR I in 1..p_x_Line_price_att_tbl.count
   LOOP
/* -----------------------------------------------------------
      Set message context for line attributes
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT FOR LINE ATTRIBUTE' ) ;
      END IF;

      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'LINE_PATTS'
--        ,p_entity_ref                 => p_x_line_price_att_tbl(I).orig_sys_atts_ref

        ,p_entity_id                  => p_x_line_price_att_tbl(I).order_price_attrib_id
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => p_x_line_tbl(p_x_line_price_att_tbl(I).line_index).line_id
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => p_x_line_tbl(p_x_line_price_att_tbl(I).line_index).orig_sys_line_ref
        ,p_orig_sys_shipment_ref      => p_x_line_tbl(p_x_line_price_att_tbl(I).line_index).orig_sys_shipment_ref
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );
----  Derived columns to be found
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING LINE ATT DERIVED COLUMNS' ) ;
      END IF;

      IF p_x_line_price_att_tbl(I).order_price_attrib_id <> FND_API.G_MISS_NUM
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN ATTRIBUTE_ID... ' ) ;
        END IF;
      END IF;
/*
      IF p_x_line_price_att_tbl(I).ORG_ID <> FND_API.G_MISS_NUM
      THEN
        oe_debug_pub.add('Cannot populate derived column ORG_ID ');
      END IF;

      IF p_x_line_price_att_tbl(I).PRICING_CONTEXT <> FND_API.G_MISS_CHAR
      THEN
        oe_debug_pub.add('Cannot populate derived column PERCENT... ');
      END IF;
*/
      IF p_x_line_price_att_tbl(I).CHANGE_REQUEST_CODE <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN CHANGE_REQUEST_CODE... ' ) ;
        END IF;
      END IF;
/*
      IF p_x_line_price_att_tbl(I).STATUS_FLAG <> FND_API.G_MISS_CHAR
      THEN
        oe_debug_pub.add('Cannot populate derived column STATUS_FLAG... ');
      END IF;
*/
   END LOOP;

/*
  ----------------------------------------------------------------------
  Check for Lines Sales Credits Record
  ----------------------------------------------------------------------
*/

   FOR I in 1..p_x_line_scredit_tbl.count
   LOOP
/* -----------------------------------------------------------
      Set message context for line sales credits
   -----------------------------------------------------------
*/
      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'LINE_SCREDIT'
        ,p_entity_ref                 => p_x_line_scredit_tbl(I).orig_sys_credit_ref
        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => p_x_line_tbl(p_x_line_scredit_tbl(I).line_index).line_id
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => p_x_line_tbl(p_x_line_scredit_tbl(I).line_index).orig_sys_line_ref
        ,p_orig_sys_shipment_ref      => p_x_line_tbl(p_x_line_scredit_tbl(I).line_index).orig_sys_shipment_ref
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

      IF p_x_line_scredit_tbl(I).CHANGE_REQUEST_CODE <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN CHANGE_REQUEST_CODE... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','CHANGE_REQUEST_CODE');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_scredit_tbl(I).CHANGE_REQUEST_CODE := FND_API.G_MISS_CHAR;
      END IF;

      IF p_x_line_scredit_tbl(I).STATUS_FLAG <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN STATUS_FLAG... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','STATUS_FLAG');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_line_scredit_tbl(I).STATUS_FLAG := FND_API.G_MISS_CHAR;
      END IF;

   END LOOP;

/*
  ----------------------------------------------------------------------
  Check for Lines Payment Record -- multiple payments
  ----------------------------------------------------------------------
*/

   FOR I in 1..p_x_line_payment_tbl.count
   LOOP
/* -----------------------------------------------------------
      Set message context for line payments
   -----------------------------------------------------------
*/
      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'LINE_PAYMENT'
        ,p_entity_ref                 => p_x_line_payment_tbl(I).orig_sys_payment_ref
        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => p_x_line_tbl(p_x_line_payment_tbl(I).line_index).line_id
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => p_x_line_tbl(p_x_line_payment_tbl(I).line_index).orig_sys_line_ref
        ,p_orig_sys_shipment_ref      => p_x_line_tbl(p_x_line_payment_tbl(I).line_index).orig_sys_shipment_ref
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

      IF p_x_line_payment_tbl(I).CHANGE_REQUEST_CODE <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN CHANGE_REQUEST_CODE... ' ) ;
        END IF;
      END IF;

      IF p_x_line_payment_tbl(I).STATUS_FLAG <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN STATUS_FLAG... ' ) ;
        END IF;
      END IF;

   END LOOP;
-- end of multiple payments

/*
  ----------------------------------------------------------------------
  Check for Lot Serial Record
  ----------------------------------------------------------------------
*/

   FOR I in 1..p_x_lot_serial_tbl.count
   LOOP
/* -----------------------------------------------------------
      Set message context for line lot serials
   -----------------------------------------------------------
*/
      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'LOT_SERIAL'
        ,p_entity_ref                 => p_x_lot_serial_tbl(I).orig_sys_lotserial_ref
        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => p_x_line_tbl(p_x_lot_serial_tbl(I).line_index).line_id
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => p_x_line_tbl(p_x_lot_serial_tbl(I).line_index).orig_sys_line_ref
        ,p_orig_sys_shipment_ref      => p_x_line_tbl(p_x_lot_serial_tbl(I).line_index).orig_sys_shipment_ref
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

      IF p_x_lot_serial_tbl(I).CHANGE_REQUEST_CODE <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN CHANGE_REQUEST_CODE... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','CHANGE_REQUEST_CODE');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_lot_serial_tbl(I).CHANGE_REQUEST_CODE := FND_API.G_MISS_CHAR;
      END IF;

      IF p_x_lot_serial_tbl(I).STATUS_FLAG <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CANNOT POPULATE DERIVED COLUMN STATUS_FLAG... ' ) ;
        END IF;
--	   FND_MESSAGE.SET_NAME('ONT','OE_OIM_DERIVED_COLUMNS');
--        FND_MESSAGE.SET_TOKEN('DERIVED_COL','STATUS_FLAG');
--        OE_MSG_PUB.Add;
--	   p_x_return_status := FND_API.G_RET_STS_ERROR;
--	   p_x_lot_serial_tbl(I).STATUS_FLAG := FND_API.G_MISS_CHAR;
      END IF;

   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
      END IF;
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	   p_x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Check_Derived_Flags');
      END IF;

END CHECK_DERIVED_FLAGS;


/* -----------------------------------------------------------
   Procedure: Pre_Process
   -----------------------------------------------------------
*/
PROCEDURE Pre_Process(
   p_x_header_rec                 IN OUT NOCOPY	OE_Order_Pub.Header_Rec_Type
  ,p_x_header_adj_tbl             IN OUT NOCOPY	OE_Order_Pub.Header_Adj_Tbl_Type
  ,p_x_header_price_att_tbl       IN OUT NOCOPY OE_Order_Pub.Header_Price_Att_Tbl_Type
  ,p_x_header_adj_att_tbl         IN OUT NOCOPY OE_Order_Pub.Header_Adj_Att_Tbl_Type
  ,p_x_header_adj_assoc_tbl      IN OUT NOCOPY OE_Order_Pub.Header_Adj_Assoc_Tbl_Type
  ,p_x_header_scredit_tbl         IN OUT NOCOPY	OE_Order_Pub.Header_Scredit_Tbl_Type
  ,p_x_header_payment_tbl         IN OUT NOCOPY	OE_Order_Pub.Header_Payment_Tbl_Type
  ,p_x_line_tbl                   IN OUT NOCOPY	OE_Order_Pub.Line_Tbl_Type
  ,p_x_line_adj_tbl               IN OUT NOCOPY	OE_Order_Pub.Line_Adj_Tbl_Type
  ,p_x_line_price_att_tbl         IN OUT NOCOPY OE_Order_Pub.Line_Price_Att_Tbl_Type
  ,p_x_line_adj_att_tbl           IN OUT NOCOPY OE_Order_Pub.Line_Adj_Att_Tbl_Type
  ,p_x_line_adj_assoc_tbl         IN OUT NOCOPY OE_Order_Pub.Line_Adj_Assoc_Tbl_Type
  ,p_x_line_scredit_tbl           IN OUT NOCOPY	OE_Order_Pub.Line_Scredit_Tbl_Type
  ,p_x_line_payment_tbl           IN OUT NOCOPY	OE_Order_Pub.Line_Payment_Tbl_Type
  ,p_x_lot_serial_tbl             IN OUT NOCOPY	OE_Order_Pub.Lot_Serial_Tbl_Type
  ,p_x_reservation_tbl            IN OUT NOCOPY	OE_Order_Pub.Reservation_Tbl_Type
  ,p_x_action_request_tbl         IN OUT NOCOPY	OE_Order_Pub.Request_Tbl_Type

  ,p_x_header_val_rec             IN OUT NOCOPY	OE_Order_Pub.Header_Val_Rec_Type
  ,p_x_header_adj_val_tbl         IN OUT NOCOPY	OE_Order_Pub.Header_Adj_Val_Tbl_Type
  ,p_x_header_scredit_val_tbl     IN OUT NOCOPY	OE_Order_Pub.Header_Scredit_Val_Tbl_Type
  ,p_x_header_payment_val_tbl     IN OUT NOCOPY	OE_Order_Pub.Header_Payment_Val_Tbl_Type
  ,p_x_line_val_tbl               IN OUT NOCOPY	OE_Order_Pub.Line_Val_Tbl_Type
  ,p_x_line_adj_val_tbl           IN OUT NOCOPY	OE_Order_Pub.Line_Adj_Val_Tbl_Type
  ,p_x_line_scredit_val_tbl       IN OUT NOCOPY OE_Order_Pub.Line_Scredit_Val_Tbl_Type
  ,p_x_line_payment_val_tbl       IN OUT NOCOPY OE_Order_Pub.Line_Payment_Val_Tbl_Type
  ,p_x_lot_serial_val_tbl         IN OUT NOCOPY	OE_Order_Pub.Lot_Serial_Val_Tbl_Type
  ,p_x_reservation_val_tbl        IN OUT NOCOPY OE_Order_Pub.Reservation_Val_Tbl_Type
  ,p_header_customer_rec          IN            Customer_Rec_Type
  ,p_line_customer_tbl            IN            Customer_Tbl_Type
,p_return_status OUT NOCOPY VARCHAR2

) IS
   l_return_status		        VARCHAR2(1);
   l_d_return_status          VARCHAR2(1);
   l_header_id				NUMBER;
   l_line_id				NUMBER;
   l_order_number			NUMBER;
   l_line_number			NUMBER;
   l_price_adjustment_id      NUMBER;
   l_sales_credit_id          NUMBER;
   l_lot_serial_id            NUMBER;
   l_shipment_number	     NUMBER;
   l_option_number			NUMBER;
   l_payment_number                     NUMBER;
   l_count				NUMBER;
   l_po_dest_org_id           NUMBER;
   l_intransit_time           NUMBER;
   l_new_schedule_ship_date   DATE;
   l_inventory_item_id_int    NUMBER;
   l_inventory_item_id_ord    NUMBER;
   l_inventory_item_id_cust   NUMBER;
   l_inventory_item_id_gen    NUMBER;
   l_price_attrib_id          NUMBER;
   l_c_operation_code         VARCHAR2(30);


   l_c_change_sequence        VARCHAR2(50);
   l_error_code               VARCHAR2(9);
   l_error_flag               VARCHAR2(1);
   l_error_message            VARCHAR2(2000);
   l_ordered_item_id          NUMBER;
   l_ship_from_org_id         NUMBER;
   l_line_count               NUMBER;
   l_counter_memory           NUMBER;
   l_counter                  NUMBER;
   l_rec_found                BOOLEAN;
   e_break                    EXCEPTION;

   l_customer_info_id         Number;
   l_line_customer_rec        Customer_Rec_Type;
   l_line_rec                 OE_Order_Pub.Line_Rec_Type;
l_type                    VARCHAR2(100);
    l_list_header_id          NUMBER;
    l_list_line_id            NUMBER;
    l_list_line_no            VARCHAR2(240);
    l_last_index             BINARY_INTEGER;

    l_header_price_att_tbl   OE_Order_Pub.Header_Price_Att_Tbl_Type;
    l_line_price_att_tbl     OE_Order_Pub.Line_Price_Att_Tbl_Type;

    G_IMPORT_SHIPMENTS        VARCHAR2(3);
    l_address_id              VARCHAR2(2000):= NULL;
    l_cust_id                 NUMBER;
    l_existing_qty            Number;
    l_inventory_id            NUMBER;
    l_customer_key_profile    VARCHAR2(1)   :=  'N';
    l_cso_response_profile    VARCHAR2(1)   :=  'N';
    l_cho_unit_selling_price  NUMBER;

--     l_item_rec             OE_ORDER_CACHE.item_rec_type;   -- OPM bug 3457463 -- INVCONV


l_tracking_quantity_ind       VARCHAR2(30); -- INVCONV
l_secondary_default_ind       VARCHAR2(30); -- INVCONV
l_secondary_uom_code varchar2(3) := NULL; -- INVCONV
l_buffer   VARCHAR2(2000); -- INVCONV
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_org_id NUMBER;

CURSOR c_item ( discrete_org_id  IN NUMBER -- INVCONV
              , discrete_item_id IN NUMBER) IS
       SELECT tracking_quantity_ind,
              secondary_uom_code,
              secondary_default_ind
              FROM mtl_system_items
     		        WHERE organization_id   = discrete_org_id
         		AND   inventory_item_id = discrete_item_id;


--

--
BEGIN

/* -----------------------------------------------------------
   Initialize
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE INITIALIZING RETURN_STATUS' ) ;
   END IF;

   p_return_status := FND_API.G_RET_STS_SUCCESS; /* Init to Success */


   If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
      fnd_profile.get('ONT_INCLUDE_CUST_IN_OI_KEY', l_customer_key_profile);
      l_customer_key_profile := nvl(l_customer_key_profile, 'N');

      fnd_profile.get('ONT_3A7_RESPONSE_REQUIRED', l_cso_response_profile);
      l_cso_response_profile := nvl(l_cso_response_profile, 'N');

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CUSTOMER KEY PROFILE SETTING = '||l_customer_key_profile ) ;
        oe_debug_pub.add(  'CHANGE SO RESPONSE REQUIRED PROFILE SETTING = '||l_cso_response_profile ) ;
      END IF;
   End If;

   -- {Select parameter for add customers functionality
   fnd_profile.get('ONT_ADD_CUSTOMER_OI',G_ONT_ADD_CUSTOMER);
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ONT_ADD_CUSTOMER PROFILE = '||G_ONT_ADD_CUSTOMER ) ;
   END IF;

   fnd_profile.get('ONT_TRANSACTION_PROCESSING',G_ONT_TRANSACTION_PROCESSING);
   G_ONT_TRANSACTION_PROCESSING := nvl(G_ONT_TRANSACTION_PROCESSING,'SYNCHRONOUS');

   fnd_profile.get('ONT_IMP_MULTIPLE_SHIPMENTS', G_IMPORT_SHIPMENTS);
   G_IMPORT_SHIPMENTS := nvl(G_IMPORT_SHIPMENTS, 'NO');

/* -----------------------------------------------------------
   Set message context
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT' ) ;
   END IF;

   OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'HEADER'
        ,p_entity_ref                 => null
        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => null
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => null
        ,p_orig_sys_shipment_ref      => null
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

/* -----------------------------------------------------------
      Validate order source
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING ORDER SOURCE' ) ;
      END IF;

   IF  p_x_header_rec.order_source_id = FND_API.G_MISS_NUM AND
       p_x_header_val_rec.order_source    = FND_API.G_MISS_CHAR
   THEN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ORDER SOURCE MISSING... ' ) ;
	END IF;
	FND_MESSAGE.SET_NAME('ONT','OE_OI_ORDER_SOURCE');
     OE_MSG_PUB.Add;
	p_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

/* -----------------------------------------------------------
      Validate orig sys document ref
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING ORIG_SYS_DOCUMENT_REF' ) ;
      END IF;

      IF p_x_header_rec.orig_sys_document_ref = FND_API.G_MISS_CHAR
      THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'INVALID ORIG_SYS_DOCUMENT_REF... ' ) ;
	 END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_ORIG_SYS_DOCUMENT_REF');
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;



/* -----------------------------------------------------------
   Before Validating change sequence
   -----------------------------------------------------------
*/

 If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE VALIDATING CHANGE SEQUENCE' ) ;
   END IF;

   IF  p_x_header_rec.operation = OE_Globals.G_OPR_UPDATE THEN

     -----------------------------------------------------------
--	Validate change sequence

       -----------------------------------------------------------
    IF p_x_header_rec.force_apply_flag <> 'Y' THEN

       IF l_debug_level  > 0 THEN
oe_debug_pub.add( 'VALIDATING CHANGE SEQUENCE' ) ;

       END IF;

       BEGIN


        SELECT change_sequence
          INTO l_c_change_sequence
          FROM oe_order_headers
         WHERE order_source_id       = p_x_header_rec.order_source_id
           AND orig_sys_document_ref = p_x_header_rec.orig_sys_document_ref
           AND decode(l_customer_key_profile, 'Y',
	       nvl(sold_to_org_id, FND_API.G_MISS_NUM), 1)
             = decode(l_customer_key_profile, 'Y',
	       nvl(p_x_header_rec.sold_to_org_id, FND_API.G_MISS_NUM), 1)
           FOR UPDATE;   --added so that changes cannot be commited out of sequence when run in multiple sessions

IF l_debug_level  > 0 THEN
oe_debug_pub.add('old change_seq:' || l_c_change_sequence) ;
oe_debug_pub.add('new change_seq:' || p_x_header_rec.change_sequence) ;
END IF;


--CODE TO ACTUALLY Validate that incoming change_sequence is higher
--than currently stored change sequence (change_sequence is a varchar field => open issue)

--only do this validation if a change_sequence had been previously stored

if l_c_change_sequence is not null then

  if  (p_x_header_rec.change_sequence > l_c_change_sequence) then

     IF l_debug_level  > 0 THEN
     oe_debug_pub.add('NEW CHANGE SEQ GREATER THAN OLD') ;
     END IF;
  else
            IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ERROR: NEW CHANGE SEQ LESS THAN OR EQUAL TO OLD') ;
        END IF;
        FND_MESSAGE.SET_NAME('ONT','OE_OI_CHANGE_OUT_OF_SEQUENCE');
        OE_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
 end if;

end if;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN NO_DATA_FOUND WHEN VALIDATING CHANGE_SEQUENCE' ) ;
         END IF;
        WHEN OTHERS THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
         END IF;

         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Pre_Process.header_change_sequence_validation');
         END IF;
       END;	  -- header change sequence is not null
    ELSE
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'FORCE APPLY FLAG IS SET, NOT VALIDATING CHANGE_SEQUENCE' ) ;
     END IF;
    END IF;      -- force apply flag not set
   END IF;	-- If header operation code is update

END IF;  --code release >= 110510
 ----added for internal req check so that  correct message context is set later .bug# 11854440,9937537
   IF (p_x_header_rec.order_source_id = OE_GLOBALS.G_ORDER_SOURCE_INTERNAL)
    AND p_x_header_rec.operation IN ('INSERT','CREATE','UPDATE','DELETE')
   THEN
     BEGIN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'BEFORE DERIVING REQ HEADER ID FOR INTERNAL ORDERS' ) ;
       END IF;

       p_x_header_rec.source_document_type_id :=
				OE_GLOBALS.G_ORDER_SOURCE_INTERNAL;

	  -- Following select is removed because of the po tables are
       -- changing to multi-org, and it has been decided that PO
       -- will pass ids columns instead of reference as they are unique
       -- in _all tables and reference column can be derived uniquely
       -- but not the vice-versa

       --  SELECT requisition_header_id
       --	 INTO p_header_rec.source_document_id
       --	 FROM po_requisition_headers
       --  WHERE segment1 = p_header_rec.orig_sys_document_ref;

       --  Re-Assigning the ID to OM ID column
       p_x_header_rec.source_document_id := p_x_header_rec.orig_sys_document_ref;

       --  New Select for Multi-Org to get the reference columns
       SELECT segment1
       INTO   p_x_header_rec.orig_sys_document_ref
       FROM   po_requisition_headers_all
       WHERE  requisition_header_id = p_x_header_rec.source_document_id;

       EXCEPTION
        WHEN OTHERS THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
          END IF;

          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_Msg_Lvl_Unexp_Error) THEN
	     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Pre_Process.Req_Header_Id_derivation');
          END IF;
     END;
   END IF;

/* ---------------------------------------------------------------
	Validate flags which are derived in Process Order Api
   ---------------------------------------------------------------
*/

      --call check_derived_flags
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CALLING CHECK_DERIVED_FLAGS' ) ;
     END IF;
     CHECK_DERIVED_FLAGS(
   	 p_x_header_rec		=> p_x_header_rec
  	,p_x_header_adj_tbl		=> p_x_header_adj_tbl
        ,p_x_header_price_att_tbl =>  p_x_header_price_att_tbl
        ,p_x_header_adj_att_tbl   => p_x_header_adj_att_tbl
        ,p_x_header_adj_assoc_tbl => p_x_header_adj_assoc_tbl
  	,p_x_header_scredit_tbl	=> p_x_header_scredit_tbl
        ,p_x_header_payment_tbl => p_x_header_payment_tbl
  	,p_x_line_tbl			=> p_x_line_tbl
  	,p_x_line_adj_tbl		=> p_x_line_adj_tbl
        ,p_x_line_price_att_tbl        =>p_x_line_price_att_tbl
        ,p_x_line_adj_att_tbl         => p_x_line_adj_att_tbl
        ,p_x_line_adj_assoc_tbl       => p_x_line_adj_assoc_tbl
  	,p_x_line_scredit_tbl	=> p_x_line_scredit_tbl
        ,p_x_line_payment_tbl   => p_x_line_payment_tbl
  	,p_x_lot_serial_tbl		=> p_x_lot_serial_tbl
  	,p_x_reservation_tbl	=> p_x_reservation_tbl
  	,p_x_header_val_rec		=> p_x_header_val_rec
  	,p_x_header_adj_val_tbl	=> p_x_header_adj_val_tbl
  	,p_x_header_scredit_val_tbl	=> p_x_header_scredit_val_tbl
        ,p_x_header_payment_val_tbl     => p_x_header_payment_val_tbl
  	,p_x_line_val_tbl		=> p_x_line_val_tbl
  	,p_x_line_adj_val_tbl		=> p_x_line_adj_val_tbl
  	,p_x_line_scredit_val_tbl	=> p_x_line_scredit_val_tbl
        ,p_x_line_payment_val_tbl       => p_x_line_payment_val_tbl
  	,p_x_lot_serial_val_tbl		=> p_x_lot_serial_val_tbl
  	,p_x_reservation_val_tbl	=> p_x_reservation_val_tbl
  	,p_x_return_status		=> l_d_return_status
	);

	IF l_d_return_status IN (FND_API.G_RET_STS_ERROR,
						FND_API.G_RET_STS_UNEXP_ERROR)
     THEN
	  p_return_status := l_d_return_status;
     END IF;

     -- {Start As at this point we should have the sold_to_org_id
     --  available, either by above call or If Customer_Number or
     --  sold_to_org is passed, that means we should call value_to_id
     --  api here and populate our Glabal variable which will be used
     --  later for creating the relationship.
     If p_x_header_rec.sold_to_org_id Is Null Then
        If p_x_header_val_rec.sold_to_org <> FND_API.G_MISS_CHAR Or
           p_x_header_val_rec.customer_number <> FND_API.G_MISS_CHAR Then
           p_x_header_rec.sold_to_org_id     :=
             oe_value_to_id.sold_to_org(
             p_sold_to_org     => p_x_header_val_rec.sold_to_org,
             p_customer_number => p_x_header_val_rec.customer_number);
             OE_INLINE_CUSTOMER_PUB.G_SOLD_TO_CUST :=
                                  p_x_header_rec.sold_to_org_id;
        End If;
     Else
        OE_INLINE_CUSTOMER_PUB.G_SOLD_TO_CUST :=
                                  p_x_header_rec.sold_to_org_id;
     End If;
     -- End of the value to id call If}

     -- { Start of the Code for the Add Customer Functionality

     -- {Check for order_import_add_customers system parameter
     -- if any ref data is passed and the parameter is set
     -- then call add customers functionality.
     --{Start of If for calling add customers
     If p_header_customer_rec.Orig_Sys_Customer_Ref IS NOT NULL Or
        p_header_customer_rec.Orig_Ship_Address_Ref IS NOT NULL Or
        p_header_customer_rec.Orig_Bill_Address_Ref IS NOT NULL Or
        p_header_customer_rec.Orig_Deliver_Address_Ref IS NOT NULL Or
        p_header_customer_rec.Sold_to_Contact_Ref IS NOT NULL Or
        p_header_customer_rec.Ship_to_Contact_Ref IS NOT NULL Or
        p_header_customer_rec.Bill_to_Contact_Ref IS NOT NULL Or
        p_header_customer_rec.Deliver_to_Contact_Ref IS NOT NULL
     Then
       --{Start of If for checking add customers parameter
       If G_ONT_ADD_CUSTOMER In ('Y','P') Then

       -- What we need to do here is to check for the add customer
       -- related coulmns and if they are null then call the Add Customer
       -- For this New procedure is added into this api which will accept
       -- the customer record structure and read that record and create
       -- data
         l_line_rec      :=    OE_ORDER_PUB.G_MISS_LINE_REC;
         Create_New_Cust_Info(
                 p_customer_rec   => p_header_customer_rec,
                 p_x_header_rec   => p_x_header_rec,
                 p_x_line_rec     => l_line_rec,
                 p_record_type    => 'HEADER',
                 x_return_status  => l_return_status);

         IF  p_return_status NOT IN (FND_API.G_RET_STS_ERROR)
         AND l_return_status     IN (FND_API.G_RET_STS_ERROR,
			          FND_API.G_RET_STS_UNEXP_ERROR)
         THEN
           p_return_status := l_return_status;
         END IF;
       Else
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'REF DATA PASSED BUT PARAMETER NOT SET' ) ;
         END IF;
         fnd_message.set_name('ONT','ONT_OI_INL_SET_PARAMETER');
         fnd_message.set_token('TYPE', 'Customers, Addresses or Contacts');
         oe_msg_pub.add;
         p_return_status := FND_API.G_RET_STS_ERROR;
       End If;
       -- End of If for checking add customers parameter}
     End If;
     -- End of If for calling add customers}
     -- End of the Code for the Add Customer Functionality }


/* -----------------------------------------------------------------------
	If BOOKED_FLAG is set then create a record in  the OE_ACTIONS_INTERFACE
	table. (for compatibility with previous releases)

        bsadri : since the actions cursor is already fetched at this time
        the booked action should not be populated into interface tables, but
        into the plsql table
   -----------------------------------------------------------------------
*/

   IF UPPER(p_x_header_rec.booked_flag) = 'Y'
   THEN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'BOOKED FLAG IS SET' ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'INSERTING RECORD IN ACTIONS TABLE' ) ;
	END IF;
	l_c_operation_code := 'BOOK_ORDER';

     p_x_action_request_tbl(p_x_action_request_tbl.COUNT +1).request_type
               := l_c_operation_code;
     p_x_action_request_tbl(p_x_action_request_tbl.COUNT).entity_code
               := OE_Globals.G_ENTITY_HEADER;
     p_x_header_rec.booked_flag := FND_API.G_MISS_CHAR;

   END IF;

/* -----------------------------------------------------------
   Derive Requisition Header Id for Internal Orders  moving these code to top.bug# 11854440,9937537
p
   -----------------------------------------------------------
*/


/* -----------------------------------------------------------
      Validate header operation code
   -----------------------------------------------------------
*/
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'BEFORE VALIDATING HEADER OPERATION CODE: '|| P_X_HEADER_REC.OPERATION ) ;
					END IF;



   BEGIN
   IF p_x_header_rec.operation IN ('INSERT','CREATE')
   THEN --{
      Begin
       -- Start for the fix of bug  1794206
       IF (p_x_header_rec.order_source_id = OE_GLOBALS.G_ORDER_SOURCE_INTERNAL)
       THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'BEFORE VALIDATING INTERNAL ORDER FOR INSERT OPR' ) ;
         END IF;


         SELECT 1 into l_count
           FROM oe_order_headers
          WHERE order_source_id       = p_x_header_rec.order_source_id
            AND orig_sys_document_ref = p_x_header_rec.orig_sys_document_ref
            AND decode(l_customer_key_profile, 'Y',
	        nvl(sold_to_org_id, FND_API.G_MISS_NUM), 1)
              = decode(l_customer_key_profile, 'Y',
	        nvl(p_x_header_rec.sold_to_org_id, FND_API.G_MISS_NUM), 1)
            AND source_document_id    = p_x_header_rec.source_document_id
            AND rownum                < 2;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'AFTER VALIDATING INTERNAL ORDER FOR INSERT OPR' ) ;
         END IF;
       ELSE
       -- End for the fix of bug  1794206
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'BEFORE VALIDATING EXTERNAL ORDER FOR INSERT OPR' ) ;
         END IF;

         SELECT 1 into l_count
           FROM oe_order_headers
          WHERE order_source_id       = p_x_header_rec.order_source_id
            AND orig_sys_document_ref = p_x_header_rec.orig_sys_document_ref
	    AND decode(l_customer_key_profile, 'Y',
	        nvl(sold_to_org_id, FND_API.G_MISS_NUM), 1)
              = decode(l_customer_key_profile, 'Y',
	        nvl(p_x_header_rec.sold_to_org_id, FND_API.G_MISS_NUM), 1)
            AND rownum                < 2;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'AFTER VALIDATING EXTERNAL ORDER FOR INSERT OPR' ) ;
         END IF;
       END IF;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO INSERT A NEW ORDER WITH THE SAME ORDER SOURCE ID AND ORIG_SYS_DOCUMENT_REF... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      Exception
        When no_data_found then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'VALID ORDER FOR INSERT' ) ;
          END IF;
        When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OTHERS EXCEPTION WHEN TRYING TO INSERT NEW ORDER... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      End;
   --}{
   ELSIF p_x_header_rec.operation IN ('UPDATE','DELETE')
   THEN
      Begin

--change sequence is not used in the WHERE-clause  here because we don't want
--to restrict new order to have the same change sequence as old order

         SELECT header_id, order_number, change_sequence
           INTO l_header_id, l_order_number, l_c_change_sequence
           FROM oe_order_headers
          WHERE order_source_id       = p_x_header_rec.order_source_id
            AND orig_sys_document_ref = p_x_header_rec.orig_sys_document_ref
            AND (sold_to_org_id is NULL OR
		decode(l_customer_key_profile, 'Y',
	 	nvl(sold_to_org_id, FND_API.G_MISS_NUM), 1)
              = decode(l_customer_key_profile, 'Y',
		nvl(p_x_header_rec.sold_to_org_id, FND_API.G_MISS_NUM), 1));

         p_x_header_rec.header_id    := l_header_id;
         p_x_header_rec.order_number := l_order_number;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'HEADER ID: '||TO_CHAR ( P_X_HEADER_REC.HEADER_ID ) ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ORDER NUMBER: '||TO_CHAR ( P_X_HEADER_REC.ORDER_NUMBER ) ) ;
         END IF;
      Exception
        When no_data_found then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO UPDATE OR DELETE AN EXISTING ORDER BUT THAT ORDER DOES NOT EXIST... ' ) ;
          END IF;
          FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
          OE_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
        When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OTHERS EXCEPTION WHEN TRYING TO UPDATE OR DELETE AN EXISTING ORDER ... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      End;
   --}{
   ELSE --IF p_x_header_rec.operation NOT IN ('INSERT','CREATE','UPDATE','DELETE')
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INVALID OPERATION CODE. NOT ONE OF INSERT , CREATE , UPDATE OR DELETE... ' ) ;
      END IF;
      FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
      OE_MSG_PUB.Add;
      p_return_status := FND_API.G_RET_STS_ERROR;

   END IF;  --}

   EXCEPTION
   WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
      END IF;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Pre_Process.header_operation_validation');
      END IF;
   END;

   /* bsadri fill in the IDs for actions if this is an update */
   BEGIN
   IF p_x_header_rec.operation IN ('UPDATE','DELETE') THEN
     FOR b in 1..p_x_action_request_tbl.COUNT
     LOOP--{
        IF p_x_action_request_tbl(b).entity_code = OE_Globals.G_ENTITY_HEADER
        THEN
           p_x_action_request_tbl(b).entity_id := p_x_header_rec.header_id;

/*myerrams, Customer Acceptance, Populating the Action_request table with Header id if Customer Acceptance is enabled.*/
           IF  p_x_action_request_tbl(b).request_type = OE_Globals.G_ACCEPT_FULFILLMENT  OR  p_x_action_request_tbl(b).request_type = OE_Globals.G_REJECT_FULFILLMENT THEN
		  l_org_id := mo_global.get_current_org_id;
	          IF (OE_SYS_PARAMETERS.VALUE('ENABLE_FULFILLMENT_ACCEPTANCE',l_org_id) = 'Y') THEN
			p_x_action_request_tbl(b).param5 := p_x_header_rec.header_id;
		  END IF;
           END IF;
/*myerrams, Customer Acceptance, end*/
        ELSE
           --adjustments for line exit the loop
           raise e_break;
        END IF;
     END LOOP;--}
   END IF;
   EXCEPTION
     WHEN  e_break THEN
       NULL;
   END;
   FOR I in 1..p_x_header_adj_tbl.count
   LOOP
/* -----------------------------------------------------------
      Set message context for header adjustments
   -----------------------------------------------------------
*/
      l_price_adjustment_id := NULL;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT FOR HEADER ADJUSTMENTS' ) ;
      END IF;

      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'HEADER_ADJ'
        ,p_entity_ref                 => p_x_header_adj_tbl(I).orig_sys_discount_ref
        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => null
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => null
        ,p_orig_sys_shipment_ref      => null
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

/* -----------------------------------------------------------
      Validate orig sys discount ref for header
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING ORIG_SYS_DISCOUNT_REF' ) ;
      END IF;

      IF p_x_header_adj_tbl(I).orig_sys_discount_ref = FND_API.G_MISS_CHAR
      THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'INVALID ORIG_SYS_DISCOUNT_REF... ' ) ;
	 END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_ORIG_SYS_DISCOUNT_REF');
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

/* -----------------------------------------------------------
      Validate header adjustments operation code
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING HEADER ADJUSTMENTS OPERATION CODE' ) ;
      END IF;

      IF p_x_header_adj_tbl(I).operation NOT IN ('INSERT','CREATE',
					       'UPDATE','DELETE') OR
        (p_x_header_rec.operation            IN ('INSERT','CREATE') AND
         p_x_header_adj_tbl(I).operation NOT IN ('INSERT','CREATE'))OR
        (p_x_header_rec.operation                IN ('UPDATE') AND
         p_x_header_adj_tbl(I).operation NOT IN ('INSERT','CREATE','UPDATE','DELETE')) OR
        (p_x_header_rec.operation                IN ('DELETE') AND
         p_x_header_adj_tbl(I).operation NOT IN ('DELETE'))
      THEN
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'INVALID HEADER ADJUSTMENTS OPERATION CODE...' ) ;
	   END IF;
	   FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
        OE_MSG_PUB.Add;
	   p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

-- aksingh(10/11/2000) this is in process of being coded
      IF  p_x_header_adj_tbl(I).operation IN ('INSERT', 'CREATE')
      AND p_x_header_rec.operation = 'UPDATE'
      THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NEW ADJUSTMENT FOR THE EXISITNG HEARDER_ID:' || P_X_HEADER_REC.HEADER_ID ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NEW ADJUSTMENT FOR THE EXISITNG HEARDER_ID:' || L_HEADER_ID ) ;
         END IF;
         p_x_header_adj_tbl(I).header_id    := l_header_id;
      Begin

         SELECT 1 into l_count
           FROM oe_price_adjustments
          WHERE header_id              = p_x_header_rec.header_id
            AND line_id                IS NULL
            AND orig_sys_discount_ref  =
                       p_x_header_adj_tbl(I).orig_sys_discount_ref
            AND rownum                < 2;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO INSERT A NEW HDRADJ WITH THE SAME HEADER_ID AND ORIG_SYS_DISCOUNT_REF... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      Exception
        When no_data_found then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'VALID HEADER LEVEL PRICE ADJ FOR INSERT' ) ;
          END IF;
        When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OTHERS EXCEPTION WHEN INSERTING NEW HDR PRICE ADJ... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      End;
      End If; -- Insert, Create operation

      IF  p_x_header_adj_tbl(I).operation IN ('UPDATE','DELETE')
      AND p_x_header_rec.operation IN ('UPDATE','DELETE')
      THEN
      Begin
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'HEADER ID: '||TO_CHAR ( P_X_HEADER_REC.HEADER_ID ) ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'DISCOUNT REF: '||P_X_HEADER_ADJ_TBL ( I ) .ORIG_SYS_DISCOUNT_REF ) ;
         END IF;
         SELECT price_adjustment_id
           INTO l_price_adjustment_id
           FROM oe_price_adjustments
          WHERE header_id             = p_x_header_rec.header_id
            AND line_id               IS NULL
            AND orig_sys_discount_ref =
                p_x_header_adj_tbl(I).orig_sys_discount_ref;

         p_x_header_adj_tbl(I).header_id    := l_header_id;
         p_x_header_adj_tbl(I).price_adjustment_id := l_price_adjustment_id;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'HEADER ID: '||TO_CHAR ( P_X_HEADER_ADJ_TBL ( I ) .HEADER_ID ) ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ADJUST ID: '||TO_CHAR ( P_X_HEADER_ADJ_TBL ( I ) .PRICE_ADJUSTMENT_ID ) ) ;
         END IF;

      Exception
        When no_data_found then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO UPDATE OR DELETE AN EXISTING HDR ADJ BUT THAT DOES NOT EXIST... ' ) ;
          END IF;
          FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
          OE_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
        When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OTHERS EXCEPTION WHEN TRYING TO UPDATE OR DELETE AN EXISTING HDRADJ ... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      End;
      End IF; -- Update and Delete operation

-- aksingh(10/11/2000) this is in process of being coded upto this point

-- Following changes are made to fix the bug# 1220921, It will call the
-- api to get the id(header and line) also the list_line_type code to
-- pass it to process_order as right now it is not possible to call
-- process order to import order without passing the these ids.
-- {
   If   (p_x_header_adj_tbl(I).list_header_id is null
	 or   p_x_header_adj_tbl(I).list_header_id = FND_API.G_MISS_NUM)
      and (p_x_header_adj_tbl(I).list_line_id is null
	 or   p_x_header_adj_tbl(I).list_line_id = FND_API.G_MISS_NUM)
	 then
      list_line_id( p_modifier_name  => p_x_header_adj_val_tbl(I).list_name,
                    p_list_line_no   => p_x_header_adj_tbl(I).list_line_no,
                    p_version_no     => p_x_header_adj_val_tbl(I).version_no,
                 p_list_line_type_code => p_x_header_adj_tbl(I).list_line_type_code,
                    p_return_status  => l_return_status,
                    x_list_header_id => l_list_header_id,
                    x_list_line_id   => l_list_line_id,
                    x_list_line_no   => l_list_line_no,
                    x_type           =>l_type);

       IF l_type NOT IN ('DIS','FREIGHT_CHARGE','PROMOLINE','COUPON','PROMO','SUR') THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OEXVIMSB.PLS -> NOT A VALID DISCOUNT/COUPON TYPE' ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NOT VALID PROMOTION NAME =' ||P_X_HEADER_ADJ_VAL_TBL ( I ) .LIST_NAME ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_INVALID_LIST_NAME');
         FND_MESSAGE.SET_TOKEN('LIST_NAME',p_x_header_adj_val_tbl(I).list_name);
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       IF  (p_return_status NOT IN (FND_API.G_RET_STS_ERROR)
         AND l_return_status     IN (FND_API.G_RET_STS_ERROR,
                                  FND_API.G_RET_STS_UNEXP_ERROR))
      THEN
          p_return_status := l_return_status;
          return;
      END IF;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LIST_LINE_TYPE_CODE = '||L_TYPE ) ;
       END IF;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LIST HEADER ID = '||L_LIST_HEADER_ID ) ;
       END IF;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LIST LINE ID = '||L_LIST_LINE_ID ) ;
       END IF;
      IF l_type In ('DIS','SUR') THEN
        p_x_header_adj_tbl(I).list_header_id :=l_list_header_id;
        p_x_header_adj_tbl(I).list_line_id :=l_list_line_id;
      END IF;

      IF l_type='FREIGHT_CHARGE' THEN
        p_x_header_adj_tbl(I).list_header_id :=l_list_header_id;
        p_x_header_adj_tbl(I).list_line_id :=l_list_line_id;
      END IF;

      IF l_type='PROMOLINE' THEN
         l_header_price_att_tbl(I).pricing_context :='MODLIST';
         l_header_price_att_tbl(I).flex_title :='QP_ATTR_DEFNS_QUALIFIER';
         l_header_price_att_tbl(I).pricing_attribute1 := l_list_header_id;
         l_header_price_att_tbl(I).pricing_attribute2 :=l_list_line_id;
         l_header_price_att_tbl(I).Orig_Sys_Atts_Ref :=p_x_header_adj_tbl(I).Orig_Sys_Discount_Ref;
         l_header_price_att_tbl(I).operation := p_x_header_adj_tbl(I).Operation;
         p_x_header_adj_tbl.delete (I);
         p_x_header_adj_val_tbl.DELETE (I);
      END IF;
      IF l_type = 'COUPON' THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING PRICING_REC FOR COUPON' ) ;
        END IF;
        l_header_price_att_tbl(I).pricing_context :='MODLIST';
        l_header_price_att_tbl(I).flex_title      :='QP_ATTR_DEFNS_QUALIFIER';
        l_header_price_att_tbl(I).pricing_attribute3 :=l_list_line_id;
        l_header_price_att_tbl(I).Orig_Sys_Atts_Ref :=p_x_header_adj_tbl(I).Orig_Sys_Discount_Ref;
        l_header_price_att_tbl(I).operation := p_x_header_adj_tbl(I).Operation;
        p_x_header_adj_tbl.delete (I);
        p_x_header_adj_val_tbl.DELETE (I);
      END IF;

       IF l_type='PROMO' THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SETTING PRICING_REC FOR PROMO' ) ;
         END IF;
         l_header_price_att_tbl(I).pricing_context :='MODLIST';
         l_header_price_att_tbl(I).flex_title    :='QP_ATTR_DEFNS_QUALIFIER';
         l_header_price_att_tbl(I).pricing_attribute1 := l_list_header_id;
         l_header_price_att_tbl(I).Orig_Sys_Atts_Ref :=p_x_header_adj_tbl(I).Orig_Sys_Discount_Ref;
         l_header_price_att_tbl(I).operation := p_x_header_adj_tbl(I).Operation;
         p_x_header_adj_tbl.delete (I);
         p_x_header_adj_val_tbl.DELETE (I);
       END IF;
   end if;
-- } end if

   END LOOP;

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'P_X_HEADER_ATT_TBL.COUNT: '||TO_CHAR ( P_X_HEADER_PRICE_ATT_TBL.COUNT ) , 1 ) ;
END IF;

   FOR I in 1..p_x_header_price_att_tbl.count
   LOOP
/* -----------------------------------------------------------
      Set message context for header atts
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT FOR HEADER ATTS' ) ;
      END IF;

      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'HEADER_PATTS'
        ,p_entity_ref                 => p_x_header_price_att_tbl(I).orig_sys_atts_ref
        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => null
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => null
        ,p_orig_sys_shipment_ref      => null
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

/* -----------------------------------------------------------
      Validate orig sys documentt ref for header
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING ORIG_SYS_ATTS_REF' ) ;
      END IF;

      IF p_x_header_price_att_tbl(I).orig_sys_atts_ref = FND_API.G_MISS_CHAR
      THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'INVALID ORIG_SYS_ATTRIBUTE_REF... ' ) ;
	 END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_ORIG_SYS_ATTS_REF');
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

/* -----------------------------------------------------------
      Validate header atts operation code
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING HEADER ATTS OPERATION CODE' ) ;
      END IF;

      IF p_x_header_price_att_tbl(I).operation NOT IN ('INSERT','CREATE',
					       'UPDATE','DELETE') OR
        (p_x_header_rec.operation            IN ('INSERT','CREATE') AND
         p_x_header_price_att_tbl(I).operation NOT IN ('INSERT','CREATE'))OR
        (p_x_header_rec.operation                IN ('UPDATE') AND
         p_x_header_price_att_tbl(I).operation NOT IN ('INSERT','CREATE','UPDATE','DELETE')) OR
        (p_x_header_rec.operation                IN ('DELETE') AND
         p_x_header_price_att_tbl(I).operation NOT IN ('DELETE'))
      THEN
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'INVALID HEADER ATTRIBUTE OPERATION CODE...' ) ;
	   END IF;
	   FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
        OE_MSG_PUB.Add;
	   p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF  p_x_header_price_att_tbl(I).operation IN ('INSERT', 'CREATE')
      AND p_x_header_rec.operation = 'UPDATE'
      THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NEW ATT FOR THE EXISITNG HEARDER_ID:' || P_X_HEADER_REC.HEADER_ID ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NEW ATT FOR THE EXISITNG HEARDER_ID:' || L_HEADER_ID ) ;
         END IF;
         p_x_header_price_att_tbl(I).header_id    := l_header_id;
      Begin

         SELECT 1 into l_count
           FROM oe_order_price_attribs
          WHERE header_id              = p_x_header_rec.header_id
            AND line_id                IS NULL
            AND orig_sys_atts_ref  =
                       p_x_header_price_att_tbl(I).orig_sys_atts_ref
            AND rownum                < 2;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO INSERT A NEW HDRATT WITH THE SAME HEADER_ID AND ATTRIBUTE ID....' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      Exception
        When no_data_found then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'VALID HEADER LEVEL PRICE ATT FOR INSERT' ) ;
          END IF;
        When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OTHERS EXCEPTION WHEN INSERTING NEW HDR PRICE ATT... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      End;
      End If; -- Insert, Create operation

      IF  p_x_header_price_att_tbl(I).operation IN ('UPDATE','DELETE')
      AND p_x_header_rec.operation IN ('UPDATE','DELETE')
      THEN
      Begin
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'HEADER ID: '||TO_CHAR ( P_X_HEADER_REC.HEADER_ID ) ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ATTRIBUTE REF: '||P_X_HEADER_PRICE_ATT_TBL ( I ) .ORIG_SYS_ATTS_REF ) ;
         END IF;
         SELECT order_price_attrib_id
           INTO l_price_attrib_id
           FROM oe_order_price_attribs
          WHERE header_id             = p_x_header_rec.header_id
            AND line_id               IS NULL
            AND orig_sys_atts_ref =
                p_x_header_price_att_tbl(I).orig_sys_atts_ref;

         p_x_header_price_att_tbl(I).header_id    := l_header_id;
         p_x_header_price_att_tbl(I).order_price_attrib_id := l_price_attrib_id;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'HEADER ID: '||TO_CHAR ( P_X_HEADER_PRICE_ATT_TBL ( I ) .HEADER_ID ) ) ;
         END IF;
--         oe_debug_pub.add('Atttribute id: '||to_char(p_x_header_att_tbl(I).order_price_attrib_id));

      Exception
        When no_data_found then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO UPDATE OR DELETE AN EXISTING HDR ATT BUT THAT DOES NOT EXIST... ' ) ;
          END IF;
          FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
          OE_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
        When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OTHERS EXCEPTION WHEN TRYING TO UPDATE OR DELETE AN EXISTING HDRATT ... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      End;
      End IF; -- Update and Delete operation

   END LOOP;


 l_last_index :=p_x_header_price_att_tbl.LAST;
 IF l_last_index IS NULL THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'SETTING L_LAST_INDEX TO ZERO' ) ;
   END IF;
   l_last_index := 0;
 END IF;
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'L_LAST_INDEX1 = '||L_LAST_INDEX ) ;
 END IF;

 FOR I IN 1..l_header_price_att_tbl.COUNT
LOOP
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CREATING REC IN PRICING_REC' ) ;
   END IF;
   l_last_index := l_last_index+1;
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'L_LAST_INDEX2 = '||L_LAST_INDEX ) ;
 END IF;
   p_x_header_price_att_tbl(l_last_index).pricing_attribute1 := l_header_price_att_tbl(I).pricing_attribute1;
   p_x_header_price_att_tbl(l_last_index).pricing_attribute2 := l_header_price_att_tbl(I).pricing_attribute2;
   p_x_header_price_att_tbl(l_last_index).pricing_attribute3 :=l_header_price_att_tbl(I).pricing_attribute3;
   p_x_header_price_att_tbl(l_last_index).flex_title := l_header_price_att_tbl(I).flex_title;
   p_x_header_price_att_tbl(l_last_index).pricing_context :=l_header_price_att_tbl(I).pricing_context;
   p_x_header_price_att_tbl(l_last_index).Orig_Sys_Atts_Ref :=l_header_price_att_tbl(I).Orig_Sys_Atts_Ref;
   p_x_header_price_att_tbl(l_last_index).Operation :=l_header_price_att_tbl(I).Operation;
END LOOP;



   FOR I in 1..p_x_header_scredit_tbl.count
   LOOP
 /* --------------------------------------------------------
      Set message context for header sales credits
   -----------------------------------------------------------
*/
      l_sales_credit_id := NULL;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT FOR HEADER SALES CREDITS' ) ;
      END IF;

      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'HEADER_SCREDIT'
        ,p_entity_ref                 => p_x_header_scredit_tbl(I).orig_sys_credit_ref
        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => null
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => null
        ,p_orig_sys_shipment_ref      => null
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

/* -----------------------------------------------------------
      Validate orig sys credit ref for header
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING ORIG_SYS_CREDIT_REF' ) ;
      END IF;

      IF p_x_header_scredit_tbl(I).orig_sys_credit_ref = FND_API.G_MISS_CHAR
      THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'INVALID ORIG_SYS_CREDIT_REF... ' ) ;
	 END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_ORIG_SYS_CREDIT_REF');
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

/* -----------------------------------------------------------
      Validate header sales credits operation code
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING HEADER SALES CREDITS OPERATION CODE' ) ;
      END IF;

      IF p_x_header_scredit_tbl(I).operation NOT IN ('INSERT','CREATE',
					           'UPDATE','DELETE') OR
        (p_x_header_rec.operation                IN ('INSERT','CREATE') AND
         p_x_header_scredit_tbl(I).operation NOT IN ('INSERT','CREATE'))OR
        (p_x_header_rec.operation                IN ('UPDATE') AND
         p_x_header_scredit_tbl(I).operation NOT IN ('INSERT','CREATE',
                                    'UPDATE','DELETE')) OR
        (p_x_header_rec.operation                IN ('DELETE') AND
         p_x_header_scredit_tbl(I).operation NOT IN ('DELETE'))
      THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'INVALID HEADER SALES CREDITS OPERATION CODE...' ) ;
	 END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

-- aksingh(10/11/2000) this is in process of being coded
      IF  p_x_header_scredit_tbl(I).operation IN ('INSERT', 'CREATE')
      AND p_x_header_rec.operation = 'UPDATE'
      THEN
      Begin
         p_x_header_scredit_tbl(I).header_id    := l_header_id;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NEW SCREDITS FOR THE EXISITNG HEARDER_ID:' || TO_CHAR ( P_X_HEADER_SCREDIT_TBL ( I ) .HEADER_ID ) ) ;
         END IF;

         SELECT 1 into l_count
           FROM oe_sales_credits
          WHERE header_id           = p_x_header_rec.header_id
            AND line_id             IS NULL
            AND orig_sys_credit_ref =
                   p_x_header_scredit_tbl(I).orig_sys_credit_ref
            AND rownum                < 2;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO INSERT A NEW HDRCREDIT WITH THE SAME HEADER_ID AND ORIG_SYS_CREDIT_REF... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      Exception
        When no_data_found then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'VALID HEADER LEVEL SALES CREDIT FOR INSERT' ) ;
          END IF;
        When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OTHERS EXCEPTION WHEN INSERTING NEW HDR SALES CREDIT... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;

      End;
      END IF; -- Insert, Create Operation

      IF  p_x_header_scredit_tbl(I).operation IN ('UPDATE','DELETE')
      AND p_x_header_rec.operation IN ('UPDATE','DELETE')
      THEN
      Begin
         p_x_header_scredit_tbl(I).header_id    := l_header_id;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'HEADER ID: '||TO_CHAR ( P_X_HEADER_SCREDIT_TBL ( I ) .HEADER_ID ) ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SCREDIT REF: '||P_X_HEADER_SCREDIT_TBL ( I ) .ORIG_SYS_CREDIT_REF ) ;
         END IF;
         SELECT sales_credit_id
           INTO l_sales_credit_id
           FROM oe_sales_credits
          WHERE header_id             = l_header_id
            AND line_id             IS NULL
            AND orig_sys_credit_ref =
                p_x_header_scredit_tbl(I).orig_sys_credit_ref;

         p_x_header_scredit_tbl(I).sales_credit_id := l_sales_credit_id;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'HEADER ID: '||TO_CHAR ( P_X_HEADER_SCREDIT_TBL ( I ) .HEADER_ID ) ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SCREDIT ID: '||TO_CHAR ( P_X_HEADER_SCREDIT_TBL ( I ) .SALES_CREDIT_ID ) ) ;
         END IF;

      Exception
        When no_data_found then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO UPDATE OR DELETE AN EXISTING ORDER BUT THAT ORDER DOES NOT EXIST... ' ) ;
          END IF;
          FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
          OE_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
        When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OTHERS EXCEPTION WHEN TRYING TO UPDATE OR DELETE AN EXISTING HEADER LEVEL SCREDIT ... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      End;
      End IF; -- Update and Delete operation

   END LOOP;

-- multiple payments start

   FOR I in 1..p_x_header_payment_tbl.count
   LOOP
 /* --------------------------------------------------------
      Set message context for header payment
   -----------------------------------------------------------
*/
   --   l_sales_credit_id := NULL;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT FOR HEADER PAYMENTS' ) ;
      END IF;

      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'HEADER_PAYMENT'
        ,p_entity_ref                 => p_x_header_payment_tbl(I).orig_sys_payment_ref
        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => null
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => null
        ,p_orig_sys_shipment_ref      => null
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

/* -----------------------------------------------------------
      Validate orig sys payment ref for header
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING ORIG_SYS_PAYMENT_REF' ) ;
      END IF;

      IF p_x_header_payment_tbl(I).orig_sys_payment_ref = FND_API.G_MISS_CHAR
      THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'INVALID ORIG_SYS_PAYMENT_REF... ' ) ;
	 END IF;
         /* multiple payment: new message */
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_ORIG_SYS_PAYMENT_REF');
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

/* -----------------------------------------------------------
      Validate header payment operation code
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING HEADER PAYMENT OPERATION CODE' ) ;
      END IF;

      IF p_x_header_payment_tbl(I).operation NOT IN ('INSERT','CREATE',
					           'UPDATE','DELETE') OR
        (p_x_header_rec.operation                IN ('INSERT','CREATE') AND
         p_x_header_payment_tbl(I).operation NOT IN ('INSERT','CREATE'))OR
        (p_x_header_rec.operation                IN ('UPDATE') AND
         p_x_header_payment_tbl(I).operation NOT IN ('INSERT','CREATE',
                                    'UPDATE','DELETE')) OR
        (p_x_header_rec.operation                IN ('DELETE') AND
         p_x_header_payment_tbl(I).operation NOT IN ('DELETE'))
      THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'INVALID HEADER PAYMENT OPERATION CODE...' ) ;
	 END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF  p_x_header_payment_tbl(I).operation IN ('INSERT', 'CREATE')
      AND p_x_header_rec.operation = 'UPDATE'
      THEN
      Begin
         p_x_header_payment_tbl(I).header_id    := l_header_id;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NEW PAYMENT FOR THE EXISITNG HEARDER_ID:' || TO_CHAR ( P_X_HEADER_payment_TBL ( I ) .HEADER_ID ) ) ;
         END IF;

         SELECT 1 into l_count
           FROM oe_payments
          WHERE header_id           = p_x_header_rec.header_id
            AND line_id             IS NULL
            AND orig_sys_payment_ref =
                   p_x_header_payment_tbl(I).orig_sys_payment_ref
            AND rownum                < 2;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO INSERT A NEW HDR PAYMENT WITH THE SAME HEADER_ID AND ORIG_SYS_PAYMENT_REF... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      Exception
        When no_data_found then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'VALID HEADER LEVEL PAYMENT FOR INSERT' ) ;
          END IF;
        When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OTHERS EXCEPTION WHEN INSERTING NEW HDR PAYMENT... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;

      End;
      END IF; -- Insert, Create Operation

      IF  p_x_header_payment_tbl(I).operation IN ('UPDATE','DELETE')
      AND p_x_header_rec.operation IN ('UPDATE','DELETE')
      THEN
      Begin
         p_x_header_payment_tbl(I).header_id    := l_header_id;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'HEADER ID: '||TO_CHAR ( P_X_HEADER_payment_TBL ( I ) .HEADER_ID ) ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'payment REF: '||P_X_HEADER_payment_TBL ( I ) .ORIG_SYS_PAYMENT_REF ) ;
         END IF;
         SELECT header_id
           INTO l_header_id
           FROM oe_payments
          WHERE header_id             = l_header_id
            AND line_id             IS NULL
            AND orig_sys_payment_ref =
                p_x_header_payment_tbl(I).orig_sys_payment_ref;

/* can take these 2 out, making sure the correct values */
         p_x_header_payment_tbl(I).header_id := l_header_id;
         p_x_header_payment_tbl(I).line_id := NULL;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'HEADER ID: '||TO_CHAR ( P_X_HEADER_payment_TBL ( I ) .HEADER_ID ) ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'header payment ref: '||P_X_HEADER_payment_TBL ( I ) .orig_sys_payment_ref ) ;
         END IF;

      Exception
        When no_data_found then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO UPDATE OR DELETE AN EXISTING ORDER BUT THAT ORDER DOES NOT EXIST... ' ) ;
          END IF;
          FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
          OE_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
        When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OTHERS EXCEPTION WHEN TRYING TO UPDATE OR DELETE AN EXISTING HEADER LEVEL payment ... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      End;
      End IF; -- Update and Delete operation
   END LOOP; -- header payment
-- aksingh(10/11/2000) this is in process of being coded upto this point

-- end of multiple payments: header payment.

   l_line_count := 0;
   l_counter := 1;
   l_counter_memory := 1;

   FOR I in 1..p_x_line_tbl.count
   LOOP --{
/* -----------------------------------------------------------
      Set message context for the line
   -----------------------------------------------------------
*/
      l_line_id         := NULL;
      l_line_number     := NULL;
      l_shipment_number := NULL;
      l_option_number   := NULL;
      l_price_adjustment_id := NULL;
      l_sales_credit_id := NULL;
      l_error_code      := NULL;
      l_error_flag      := NULL;
      l_error_message   := NULL;
      l_cho_unit_selling_price := NULL;

      IF p_x_line_tbl(I).org_id <> FND_API.G_MISS_NUM then
         l_org_id := p_x_line_tbl(I).org_id;
      ELSIF p_x_header_rec.ORG_ID <> FND_API.G_MISS_NUM then
            l_org_id := p_x_header_rec.org_id;
      ELSE
            l_org_id := mo_global.get_current_org_id;
      END IF;

      l_line_count := l_line_count + 1;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT FOR THE LINE' ) ;
      END IF;

      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'LINE'
        ,p_entity_ref                 => null
        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => p_x_line_tbl(I).line_id
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => p_x_line_tbl(I).orig_sys_line_ref
        ,p_orig_sys_shipment_ref      => p_x_line_tbl(I).orig_sys_shipment_ref
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

/* -----------------------------------------------------------
      Validate orig sys line ref
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING ORIG_SYS_LINE_REF' ) ;
      END IF;

      IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110508' AND
         G_IMPORT_SHIPMENTS = 'YES' THEN
        IF p_x_line_tbl(I).orig_sys_line_ref     = FND_API.G_MISS_CHAR AND
           p_x_line_tbl(I).orig_sys_shipment_ref = FND_API.G_MISS_CHAR
        THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INVALID ORIG_SYS_LINE_REF... ' ) ;
          END IF;
          FND_MESSAGE.SET_NAME('ONT','OE_OI_ORIG_SYS_LINE_REF');
          OE_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      ELSIF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110508' AND
            G_IMPORT_SHIPMENTS = 'NO' THEN
        IF p_x_line_tbl(I).orig_sys_line_ref     = FND_API.G_MISS_CHAR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INVALID ORIG_SYS_LINE_REF... ' ) ;
          END IF;
          FND_MESSAGE.SET_NAME('ONT','OE_OI_ORIG_SYS_LINE_REF');
          OE_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      ELSIF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL < '110508' THEN
        IF p_x_line_tbl(I).orig_sys_line_ref     = FND_API.G_MISS_CHAR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INVALID ORIG_SYS_LINE_REF... ' ) ;
          END IF;
          FND_MESSAGE.SET_NAME('ONT','OE_OI_ORIG_SYS_LINE_REF');
          OE_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

/* -----------------------------------------------------------
      Validate Ordered quantity uom2 (OPM bug 3457463)
   -----------------------------------------------------------
      If this is a process line, load the item details from cache and validate
  -----------------------------------------------------------
*/

   OPEN c_item(   	   p_x_line_tbl(I).ship_from_org_id,
                   p_x_line_tbl(I).inventory_item_id
                    );
               FETCH c_item
                INTO   l_tracking_quantity_ind,
                       l_secondary_uom_code ,
                       l_secondary_default_ind
	               ;


               IF c_item%NOTFOUND THEN
		    l_tracking_quantity_ind := 'P';
	            l_secondary_uom_code := NULL;
	            l_secondary_default_ind := null;

	       END IF;

    Close c_item;



--IF oe_line_util.Process_Characteristics INVCONV
--  (p_x_line_tbl(I).inventory_item_id,p_x_line_tbl(I).ship_from_org_id,l_item_rec) THEN

   IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE VALIDATING ORDERED_QUANTITY_UOM2' ) ;
   END IF;
   /*oe_debug_pub.add('PROCESS ' ) ;
   oe_debug_pub.ADD(' dual ind : '|| l_item_rec.dualum_ind,1);
   oe_debug_pub.ADD(' l_item_rec.opm_item_um2 : '|| l_item_rec.opm_item_um2,1);
   oe_debug_pub.ADD(' ordered_quantity_uom2 : '|| p_x_line_tbl(I).ordered_quantity_uom2,1); */


  --IF l_item_rec.dualum_ind not in (1,2,3) THEN
  IF l_tracking_quantity_ind <> 'PS' then --  INVCONV

    oe_debug_pub.add('Primary and Secondary -  tracking_quantity_ind <> PS', 2);

    IF ( p_x_line_tbl(I).ordered_quantity_uom2 IS NOT NULL
     AND p_x_line_tbl(I).ordered_quantity_uom2 <> FND_API.G_MISS_CHAR ) THEN
      	  --oe_debug_pub.add(  'OPM INVALID ordered_quantity_uom2 - should not be provided... ' ) ;
          FND_MESSAGE.SET_NAME('INV','INV_SECONDARY_UOM_NOT_REQUIRED'); -- INVCONV
          OE_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
          IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'INVALID ORDERED_QUANTITY_UOM2... should not be provided' ) ;
          END IF;

    END IF; --  IF ( p_x_line_tbl(I).ordered_quantity_uom2 <> NULL

  ELSIF l_tracking_quantity_ind = 'PS' then --  INVCONV
	   IF ( (  p_x_line_tbl(I).ordered_quantity_uom2 IS NOT NULL
	   AND p_x_line_tbl(I).ordered_quantity_uom2 <> FND_API.G_MISS_CHAR )
           AND p_x_line_tbl(I).ordered_quantity_uom2 <> l_secondary_uom_code ) THEN -- INVCONV
      	     FND_MESSAGE.SET_NAME('PO','PO_INCORRECT_SECONDARY_UOM');  -- INVCONV
             OE_MSG_PUB.Add;
             p_return_status := FND_API.G_RET_STS_ERROR;
             IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'INVALID ORDERED_QUANTITY_UOM2... does not match mtl_system_items' ) ;
             END IF;

           END IF;   --  IF ( p_x_line_tbl(I).ordered_quantity_uom2 <> NULL
    END IF;  --IF l_tracking_quantity_ind <> 'PS' then --  INVCONV
-- END IF; -- IF oe_line_util.Process_Characteristics invconv


-- OPM END







      -- Validate the quantity sent on the 3a9
     If p_x_line_tbl(I).order_source_id = OE_Acknowledgment_Pub.G_XML_ORDER_SOURCE_ID And
         p_x_line_tbl(I).xml_transaction_type_code = OE_Acknowledgment_Pub.G_TRANSACTION_CPO Then
	If  p_x_line_tbl(I).ordered_quantity < 0 Then
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'INVALID QUANTITY ON 3A9' ) ;
             END IF;
             FND_MESSAGE.SET_NAME('ONT','OE_OI_INVALID_QTY_3A9');
             OE_MSG_PUB.Add;
             p_return_status := FND_API.G_RET_STS_ERROR;
        Else

           Begin
             Select ordered_quantity
             Into l_existing_qty
             From Oe_Order_Lines
             Where orig_sys_document_ref = p_x_line_tbl(I).orig_sys_document_ref
             And order_source_id       = p_x_line_tbl(I).order_source_id
             And orig_sys_line_ref     = p_x_line_tbl(I).orig_sys_line_ref
             And orig_sys_shipment_ref = p_x_line_tbl(I).orig_sys_shipment_ref
             And decode(l_customer_key_profile, 'Y',
		 nvl(sold_to_org_id, FND_API.G_MISS_NUM), 1)
               = decode(l_customer_key_profile, 'Y',
		 nvl(p_x_line_tbl(I).sold_to_org_id, FND_API.G_MISS_NUM), 1);

          If l_existing_qty < p_x_line_tbl(I).ordered_quantity Then
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'INVALID QUANTITY ON 3A9' ) ;
             END IF;
             FND_MESSAGE.SET_NAME('ONT','OE_OI_INVALID_QTY_3A9');
             OE_MSG_PUB.Add;
             p_return_status := FND_API.G_RET_STS_ERROR;
          End If;
          Exception
             When Others Then
           p_return_status := FND_API.G_RET_STS_ERROR;
          End;
        End If;
    End If;

/* -----------------------------------------------------------
      Validate line operation code
   -----------------------------------------------------------
*/
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'BEFORE VALIDATING LINE OPERATION CODE: '|| P_X_LINE_TBL ( I ) .OPERATION ) ;
				END IF;

      IF (p_x_header_rec.operation      IN ('INSERT','CREATE') AND
          p_x_line_tbl(I).operation NOT IN ('INSERT','CREATE'))OR
         (p_x_header_rec.operation      IN ('UPDATE') AND
          p_x_line_tbl(I).operation NOT IN ('INSERT','CREATE','UPDATE','DELETE'))OR
         (p_x_header_rec.operation      IN ('DELETE') AND
          p_x_line_tbl(I).operation NOT IN ('DELETE'))
      THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'INVALID OPERATION CODE. YOU ARE TRYING TO INSERT THE ORDER HEADER BUT NOT THE LINES. IF THE OPERATION ON THE HEADER IS INSERT , IT SHOULD BE INSERT AT THE LINE LEVEL ALSO , NOT UPDATE OR DELETE...' ) ;
	 END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

/* -----------------------------------------------------------
      Derive Requisition Line Id for Internal Orders
   -----------------------------------------------------------
*/
      IF p_x_header_rec.order_source_id = OE_GLOBALS.G_ORDER_SOURCE_INTERNAL
        AND p_x_line_tbl(I).operation IN ('INSERT','CREATE','UPDATE','DELETE')
      THEN
        BEGIN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'BEFORE DERIVING REQ LINE ID FOR INTERNAL ORDERS' ) ;
         END IF;

	    p_x_line_tbl(I).source_document_type_id :=
				OE_GLOBALS.G_ORDER_SOURCE_INTERNAL;
	    p_x_line_tbl(I).source_document_id := p_x_header_rec.source_document_id;
	    p_x_line_tbl(I).orig_sys_document_ref := p_x_header_rec.orig_sys_document_ref;
	    p_x_line_tbl(I).sold_to_org_id := p_x_header_rec.sold_to_org_id;

	  --  SELECT requisition_line_id
	  --  INTO p_line_tbl(I).source_document_line_id
	  --  FROM po_requisition_lines
	  --  WHERE requisition_header_id = p_header_rec.source_document_id
       --  AND line_num = p_line_tbl(I).orig_sys_line_ref;

       --  Re-Assigning the ID to OM ID column
       p_x_line_tbl(I).source_document_line_id := p_x_line_tbl(I).orig_sys_line_ref;

       --  New Select for Multi-Org to get the reference columns

           l_po_dest_org_id := NULL;

           SELECT line_num, destination_organization_id
           INTO   p_x_line_tbl(I).orig_sys_line_ref, l_po_dest_org_id
           FROM   po_requisition_lines_all
           WHERE  requisition_header_id = p_x_header_rec.source_document_id
           AND    requisition_line_id = p_x_line_tbl(I).source_document_line_id;

           l_intransit_time := 0;
           IF l_po_dest_org_id is not null THEN
           BEGIN
              SELECT intransit_time * -1
              INTO   l_intransit_time
              FROM   mtl_interorg_ship_methods
              WHERE  from_organization_id = p_x_line_tbl(I).ship_from_org_id
              AND    to_organization_id = l_po_dest_org_id
              AND    nvl(default_flag,1) = 1;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'IN TRANSIT ' || L_INTRANSIT_TIME ) ;
              END IF;
           EXCEPTION
              WHEN OTHERS THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'IN TRANSIT IS SET TO 0' ) ;
               END IF;
               l_intransit_time := 0;
           END;
           END IF;

           -- Call to MRP package api Date_Offset for getting new
           -- schedule ship date
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'BEFORE CHECKING THE REQUEST_DATE VALUE' ) ;
           END IF;
           -- bug 1727334, do not call if request_date is MISS

           -- This code is going to be here, but it should be removed
           -- later when family pack H or I become mandatory
           -- I am leaving it here so, it will work as it, if customer
           -- does not have PO's patch for not passing the
           -- schedule ship date.
           -- Bug 1606316, fix (see later what fix), this is redundant
           -- as explained above

           IF p_x_line_tbl(I).request_date <> FND_API.G_MISS_DATE
           THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'BEFORE CALL TO DATE OFFSET API' ) ;
             END IF;

           -- bug 1675148, call changed, now passing request_date
           -- previously it was schedule_ship_date(!)
             l_new_schedule_ship_date := mrp_calendar.date_offset
               (arg_org_id => l_po_dest_org_id,
                arg_bucket => 1,
                arg_date   => p_x_line_tbl(I).request_date,
                arg_offset => l_intransit_time
                );
           END IF;

              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'OLD SCHEDULE_SHIP_DATE ' || P_X_LINE_TBL ( I ) .SCHEDULE_SHIP_DATE ) ;
              END IF;
           -- { Start of bug fix 1606316, If condition to check if
           -- schedule_ship_date is not passed by PO means it is
           -- MISS_DATE, do not assign the new found value of
           -- l_new_schedule_ship_date in above call. Which will
           -- be removed once family pack H/I become mandatory
           If p_x_line_tbl(I).schedule_ship_date <> FND_API.G_MISS_DATE Then
              p_x_line_tbl(I).schedule_ship_date :=
              nvl(l_new_schedule_ship_date, p_x_line_tbl(I).schedule_ship_date);
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'NEW SCHEDULE_SHIP_DATE ' || P_X_LINE_TBL ( I ) .SCHEDULE_SHIP_DATE ) ;
              END IF;
           End If;
           -- End of bug fix 1606316, the change is adding of IF, that is it}

        EXCEPTION
        WHEN OTHERS THEN
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
	     END IF;

          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Pre_Process.Req_Line_Id_derivation');
          END IF;
        END;
      END IF;

     -- { Start of the Code for the Add Customer Functionality

     -- {Check for order_import_add_customers system parameter
     -- if any ref data is passed and the parameter is set
     -- then call add customers functionality.
     --{Start of If for calling add customers
     If p_line_customer_tbl(I).Orig_Ship_Address_Ref IS NOT NULL Or
        p_line_customer_tbl(I).Orig_Bill_Address_Ref IS NOT NULL Or
        p_line_customer_tbl(I).Orig_Deliver_Address_Ref IS NOT NULL Or
        p_line_customer_tbl(I).Ship_to_Contact_Ref IS NOT NULL Or
        p_line_customer_tbl(I).Bill_to_Contact_Ref IS NOT NULL Or
        p_line_customer_tbl(I).Deliver_to_Contact_Ref IS NOT NULL
     Then
       --{Start of If for checking add customers parameter
       If G_ONT_ADD_CUSTOMER In ('Y','P') Then
          l_line_rec := p_x_line_tbl(I);
          l_line_customer_rec := p_line_customer_tbl(I);
          Create_New_Cust_Info(
                 p_customer_rec   => l_line_customer_rec,
                 p_x_header_rec   => p_x_header_rec,
                 p_x_line_rec     => l_line_rec,
                 p_record_type    => 'LINE',
                 x_return_status  => l_return_status);

          IF  p_return_status NOT IN (FND_API.G_RET_STS_ERROR)
          AND l_return_status     IN (FND_API.G_RET_STS_ERROR,
			          FND_API.G_RET_STS_UNEXP_ERROR)
          THEN
            p_return_status := l_return_status;
          END IF;
          p_x_line_tbl(I)  := l_line_rec;
       Else
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'REF DATA PASSED BUT PARAMETER NOT SET' ) ;
         END IF;
         fnd_message.set_name('ONT','ONT_OI_INL_SET_PARAMETER');
         fnd_message.set_token('TYPE', 'Customers, Addresses or Contacts');
         oe_msg_pub.add;
         p_return_status := FND_API.G_RET_STS_ERROR;
       End If;
       -- End of If for checking add customers parameter}
     End If;
     -- End of If for calling add customers}

     -- End of the Code for the Add Customer Functionality }

      BEGIN
      IF p_x_line_tbl(I).operation IN ('INSERT','CREATE')
-- aksingh(10/11/2000) this is in process of being coded
      AND p_x_header_rec.operation = 'UPDATE'
      THEN
            p_x_line_tbl(I).header_id    := l_header_id;

         IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110508' AND
            G_IMPORT_SHIPMENTS = 'YES' THEN

            IF (p_x_line_tbl(I).split_from_line_ref IS NOT NULL) AND
               (p_x_line_tbl(I).split_from_line_ref <> FND_API.G_MISS_CHAR) AND
               (p_x_line_tbl(I).split_from_shipment_ref IS NOT NULL) AND
               (p_x_line_tbl(I).split_from_shipment_ref <> FND_API.G_MISS_CHAR)
            THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'SPLIT LINE FOR LINE REFERENCE: '|| P_X_LINE_TBL ( I ) .SPLIT_FROM_LINE_REF ) ;
                END IF;
              l_rec_found := FALSE;
              BEGIN
              FOR Z in 1..p_x_line_tbl.count
               LOOP
                 IF (p_x_line_tbl(Z).orig_sys_line_ref = p_x_line_tbl(I).split_from_line_ref) AND
                    (p_x_line_tbl(Z).orig_sys_shipment_ref = p_x_line_tbl(I).split_from_shipment_ref)
                 THEN
                   l_rec_found := TRUE;
                   p_x_line_tbl(Z).split_action_code := 'SPLIT';
                   p_x_line_tbl(Z).split_by := 'USER';
                   p_x_line_tbl(I).split_from_line_id :=
                       p_x_line_tbl(Z).line_id;
                 END IF;
                 IF l_rec_found THEN
                    raise e_break;
                 END IF;
               END LOOP;
              EXCEPTION
                WHEN e_break THEN
                  NULL;
              END;
              IF NOT l_rec_found THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'BSADRI NO SPLIT FROM FOUND' ) ;
                END IF;
                FND_MESSAGE.SET_NAME('ONT','OE_PC_SPLIT_VIOLATION');
                FND_MESSAGE.SET_TOKEN('OBJECT',
                     p_x_line_tbl(I).split_from_line_ref);
                FND_MESSAGE.SET_TOKEN('REASON',
                     'Could not find the reference line');
                OE_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
            END IF;
           BEGIN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'NEW LINE FOR THE EXISITNG HEARDER_ID:' || TO_CHAR ( P_X_HEADER_REC.HEADER_ID ) ) ;
            END IF;
            SELECT 1 into l_count
            FROM oe_order_lines
            WHERE header_id             = l_header_id
            AND orig_sys_line_ref     = p_x_line_tbl(I).orig_sys_line_ref
            AND orig_sys_shipment_ref = p_x_line_tbl(I).orig_sys_shipment_ref
            AND decode(l_customer_key_profile, 'Y',
                nvl(sold_to_org_id, FND_API.G_MISS_NUM), 1)
              = decode(l_customer_key_profile, 'Y',
		nvl(p_x_line_tbl(I).sold_to_org_id, FND_API.G_MISS_NUM), 1);

-- aksingh(10/11/2000) this is in process of being coded upto here
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO INSERT A NEW LINE WITH THE SAME ORDER SOURCE ID , ORIG_SYS_DOCUMENT_REF AND ORIG_SYS_LINE_REF... ' ) ;
               END IF;
             FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
             OE_MSG_PUB.Add;
             p_return_status := FND_API.G_RET_STS_ERROR;
           Exception
           When no_data_found then
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'VALID ORDER LINE FOR INSERT' ) ;
             END IF;
           When others then
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'OTHERS EXCEPTION WHEN TRYING TO INSERT A NEW LINE... ' ) ;
             END IF;
            FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
            OE_MSG_PUB.Add;
            p_return_status := FND_API.G_RET_STS_ERROR;
          End;
        ELSIF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110508' AND
              G_IMPORT_SHIPMENTS = 'NO' THEN
          IF (p_x_line_tbl(I).split_from_line_ref IS NOT NULL) AND
               (p_x_line_tbl(I).split_from_line_ref <> FND_API.G_MISS_CHAR)
            THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'SPLIT LINE FOR LINE REFERENCE: '|| P_X_LINE_TBL ( I ) .SPLIT_FROM_LINE_REF ) ;
                END IF;
              l_rec_found := FALSE;
              BEGIN
              FOR Z in 1..p_x_line_tbl.count
               LOOP
                 IF (p_x_line_tbl(Z).orig_sys_line_ref = p_x_line_tbl(I).split_from_line_ref) THEN
                   l_rec_found := TRUE;
                   p_x_line_tbl(Z).split_action_code := 'SPLIT';
                   p_x_line_tbl(Z).split_by := 'USER';
                   p_x_line_tbl(I).split_from_line_id :=
                       p_x_line_tbl(Z).line_id;
                 END IF;
                 IF l_rec_found THEN
                    raise e_break;
                 END IF;
               END LOOP;
              EXCEPTION
                WHEN e_break THEN
                  NULL;
              END;
              IF NOT l_rec_found THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'BSADRI NO SPLIT FROM FOUND' ) ;
                END IF;
                FND_MESSAGE.SET_NAME('ONT','OE_PC_SPLIT_VIOLATION');
                FND_MESSAGE.SET_TOKEN('OBJECT',
                     p_x_line_tbl(I).split_from_line_ref);
                FND_MESSAGE.SET_TOKEN('REASON',
                     'Could not find the reference line');
                OE_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
            END IF;
            BEGIN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'NEW LINE FOR THE EXISITNG HEARDER_ID:' || TO_CHAR ( P_X_HEADER_REC.HEADER_ID ) ) ;
            END IF;
            SELECT 1 into l_count
            FROM oe_order_lines
            WHERE header_id             = l_header_id
            AND orig_sys_line_ref     = p_x_line_tbl(I).orig_sys_line_ref
            AND decode(l_customer_key_profile, 'Y',
		nvl(sold_to_org_id, FND_API.G_MISS_NUM), 1)
	      = decode(l_customer_key_profile, 'Y',
		nvl(p_x_line_tbl(I).sold_to_org_id, FND_API.G_MISS_NUM), 1);

-- aksingh(10/11/2000) this is in process of being coded upto here
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO INSERT A NEW LINE WITH THE SAME ORDER SOURCE ID , ORIG_SYS_DOCUMENT_REF AND ORIG_SYS_LINE_REF. .. ' ) ;
               END IF;
             FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
             OE_MSG_PUB.Add;
             p_return_status := FND_API.G_RET_STS_ERROR;
           Exception
           When no_data_found then
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'VALID ORDER LINE FOR INSERT' ) ;
             END IF;
           When others then
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'OTHERS EXCEPTION WHEN TRYING TO INSERT A NEW LINE... ' ) ;
             END IF;
            FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
            OE_MSG_PUB.Add;
            p_return_status := FND_API.G_RET_STS_ERROR;
          End;
         ELSIF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL < '110508' THEN
          IF (p_x_line_tbl(I).split_from_line_ref IS NOT NULL) AND
               (p_x_line_tbl(I).split_from_line_ref <> FND_API.G_MISS_CHAR)
            THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'SPLIT LINE FOR LINE REFERENCE: '|| P_X_LINE_TBL ( I ) .SPLIT_FROM_LINE_REF ) ;
                END IF;
              l_rec_found := FALSE;
              BEGIN
              FOR Z in 1..p_x_line_tbl.count
               LOOP
                 IF (p_x_line_tbl(Z).orig_sys_line_ref = p_x_line_tbl(I).split_from_line_ref) THEN
                   l_rec_found := TRUE;
                   p_x_line_tbl(Z).split_action_code := 'SPLIT';
                   p_x_line_tbl(Z).split_by := 'USER';
                   p_x_line_tbl(I).split_from_line_id :=
                       p_x_line_tbl(Z).line_id;
                 END IF;
                 IF l_rec_found THEN
                    raise e_break;
                 END IF;
               END LOOP;
              EXCEPTION
                WHEN e_break THEN
                  NULL;
              END;
              IF NOT l_rec_found THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'BSADRI NO SPLIT FROM FOUND' ) ;
                END IF;
                FND_MESSAGE.SET_NAME('ONT','OE_PC_SPLIT_VIOLATION');
                FND_MESSAGE.SET_TOKEN('OBJECT',
                     p_x_line_tbl(I).split_from_line_ref);
                FND_MESSAGE.SET_TOKEN('REASON',
                     'Could not find the reference line');
                OE_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
            END IF;
            BEGIN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'NEW LINE FOR THE EXISITNG HEARDER_ID:' || TO_CHAR ( P_X_HEADER_REC.HEADER_ID ) ) ;
            END IF;
            SELECT 1 into l_count
            FROM oe_order_lines
            WHERE header_id             = l_header_id
            AND orig_sys_line_ref     = p_x_line_tbl(I).orig_sys_line_ref;

-- aksingh(10/11/2000) this is in process of being coded upto here
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO INSERT A NEW LINE WITH THE SAME ORDER SOURCE ID , ORIG_SYS_DOCUMENT_REF AND ORIG_SYS_LINE_REF. .. ' ) ;
               END IF;
             FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
             OE_MSG_PUB.Add;
             p_return_status := FND_API.G_RET_STS_ERROR;
           Exception
           When no_data_found then
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'VALID ORDER LINE FOR INSERT' ) ;
             END IF;
           When others then
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'OTHERS EXCEPTION WHEN TRYING TO INSERT A NEW LINE... ' ) ;
             END IF;
            FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
            OE_MSG_PUB.Add;
            p_return_status := FND_API.G_RET_STS_ERROR;
          End;

         END IF;

      ELSIF p_x_line_tbl(I).operation IN ('UPDATE','DELETE')
      AND p_x_header_rec.operation IN ('UPDATE','DELETE')
      THEN


                IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'L_HEADER_ID: ' || l_header_id) ;
              oe_debug_pub.add(  'P_X_LINE_TBL(I).ORIG_SYS_LINE_REF' || p_x_line_tbl(I).orig_sys_line_ref) ;
              oe_debug_pub.add(  'P_X_LINE_TBL(I).ORIG_SYS_SHIPMENT_REF' || p_x_line_tbl(I).orig_sys_shipment_ref);
              oe_debug_pub.add(  'P_X_LINE_TBL(I).SOLD_TO_ORG_ID' || p_x_line_tbl(I).sold_to_org_id);

              END IF;


        IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110508' AND
           G_IMPORT_SHIPMENTS = 'YES' THEN

                IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'G_IMPORT_SHIPMENTS WAS YES ' ) ;
              END IF;

	Begin
              l_c_change_sequence := NULL;

          SELECT line_id, line_number, shipment_number,
                   option_number, change_sequence, unit_selling_price
              INTO l_line_id, l_line_number, l_shipment_number,
                   l_option_number, l_c_change_sequence, l_cho_unit_selling_price
              FROM oe_order_lines
             WHERE header_id          = l_header_id
               AND orig_sys_line_ref  = p_x_line_tbl(I).orig_sys_line_ref
               AND orig_sys_shipment_ref = p_x_line_tbl(I).orig_sys_shipment_ref
               AND (sold_to_org_id is NULL OR
		   decode(l_customer_key_profile, 'Y',
		   nvl(sold_to_org_id, FND_API.G_MISS_NUM), 1)
                 = decode(l_customer_key_profile, 'Y',
		   nvl(p_x_line_tbl(I).sold_to_org_id, FND_API.G_MISS_NUM), 1));

            p_x_line_tbl(I).header_id       := l_header_id;
            p_x_line_tbl(I).line_id         := l_line_id;
            p_x_line_tbl(I).line_number     := l_line_number;
            p_x_line_tbl(I).shipment_number := l_shipment_number;
            p_x_line_tbl(I).option_number   := l_option_number;

         Exception
            When no_data_found then
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO UPDATE OR DELETE AN EXISTING LINE BUT THAT LINE DOES NOT EXIST... ' ) ;
              END IF;
              FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
              OE_MSG_PUB.Add;
              p_return_status := FND_API.G_RET_STS_ERROR;
            When others then
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'OTHERS EXCEPTION WHEN TRYING TO UPDATE OR DELETE AN EXISTING LINE ... ' ) ;
              END IF;
              FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
              OE_MSG_PUB.Add;
              p_return_status := FND_API.G_RET_STS_ERROR;
         End;
       ELSE
          Begin
            l_c_change_sequence := NULL;
            SELECT line_id, line_number, shipment_number,
                   option_number, change_sequence, unit_selling_price
              INTO l_line_id, l_line_number, l_shipment_number,
                   l_option_number, l_c_change_sequence, l_cho_unit_selling_price
              FROM oe_order_lines
             WHERE header_id          = l_header_id
               AND orig_sys_line_ref  = p_x_line_tbl(I).orig_sys_line_ref;

            p_x_line_tbl(I).header_id       := l_header_id;
            p_x_line_tbl(I).line_id         := l_line_id;
            p_x_line_tbl(I).line_number     := l_line_number;
            p_x_line_tbl(I).shipment_number := l_shipment_number;
            p_x_line_tbl(I).option_number   := l_option_number;

         Exception
            When no_data_found then
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO UPDATE OR DELETE AN EXISTING LINE BUT THAT LINE DOES NOT EXIST... ' ) ;
              END IF;
              FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
              OE_MSG_PUB.Add;
              p_return_status := FND_API.G_RET_STS_ERROR;
            When others then
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'OTHERS EXCEPTION WHEN TRYING TO UPDATE OR DELETE AN EXISTING LINE ... ' ) ;
              END IF;
              FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
              OE_MSG_PUB.Add;
              p_return_status := FND_API.G_RET_STS_ERROR;
         End;
       END IF;

        IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
           IF p_x_line_tbl(I).order_source_id = OE_Acknowledgment_Pub.G_XML_ORDER_SOURCE_ID AND
              p_x_line_tbl(I).xml_transaction_type_code = OE_Acknowledgment_Pub.G_TRANSACTION_CHO AND
              l_cso_response_profile = 'Y' AND
              p_x_line_tbl(I).cso_response_flag = 'Y' AND
              p_x_line_tbl(I).customer_item_net_price = FND_API.G_MISS_NUM  THEN

                 p_x_line_tbl(I).customer_item_net_price := l_cho_unit_selling_price;
                 IF l_debug_level > 0 THEN
                    oe_debug_pub.add('3A8 Response Customer_item_net_price ' || p_x_line_tbl(I).customer_item_net_price
                                   || ' Unit Selling Price ' || p_x_line_tbl(I).unit_selling_price);
                 END IF;
           END IF;
        END IF;


      ELSIF p_x_line_tbl(I).operation NOT IN ('INSERT','CREATE','UPDATE','DELETE')
      THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVALID OPERATION CODE. NOT ONE OF INSERT , CREATE , UPDATE OR DELETE... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;

      END IF;

      EXCEPTION
      WHEN OTHERS THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
         END IF;

         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Pre_Process.header_operation_validation');
         END IF;
      END;

/* -----------------------------------------------------------
      Validate item type code
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING ITEM TYPE CODE' ) ;
      END IF;

      IF p_x_line_tbl(I).item_type_code <> FND_API.G_MISS_CHAR AND
         p_x_line_tbl(I).item_type_code NOT IN
       ('STANDARD','MODEL','CLASS','KIT','SERVICE','OPTION','INCLUDED','CONFIG')
      THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'INVALID ITEM TYPE CODE... ' ) ;
	 END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_ITEM_TYPE');
         OE_MSG_PUB.Add;
  	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
   -- { Start of derivation of the sold_to_org_id for Header/Line
   If p_x_header_rec.sold_to_org_id IS NOT NULL AND
      p_x_header_rec.sold_to_org_id <> FND_API.G_MISS_NUM
   Then
      If p_x_line_tbl(I).sold_to_org_id = FND_API.G_MISS_NUM OR
         p_x_line_tbl(I).sold_to_org_id IS NULL
      Then
         p_x_line_tbl(I).sold_to_org_id := p_x_header_rec.sold_to_org_id;
      End If;
   Else
    -- { Start Begin
    Begin
      IF (p_x_line_tbl(I).sold_to_org_id = FND_API.G_MISS_NUM OR
         p_x_line_tbl(I).sold_to_org_id IS NULL) AND
         ((p_x_line_val_tbl(I).sold_to_org <> FND_API.G_MISS_CHAR AND
         p_x_line_val_tbl(I).sold_to_org IS NOT NULL) OR
         (p_x_header_val_rec.customer_number <> FND_API.G_MISS_CHAR AND
         p_x_header_val_rec.customer_number IS NOT NULL) OR
         (p_x_header_val_rec.sold_to_org <> FND_API.G_MISS_CHAR AND
         p_x_header_val_rec.sold_to_org IS NOT NULL))
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'BEFORE CALLING SOLD TO ORG ID' ) ;
        END IF;
        p_x_line_tbl(I).sold_to_org_id := oe_value_to_id.sold_to_org(
                        p_sold_to_org => nvl(p_x_header_val_rec.sold_to_org,
                                         p_x_line_val_tbl(I).sold_to_org),
                    p_customer_number => p_x_header_val_rec.customer_number);
        If p_x_header_rec.sold_to_org_id is NULL OR
           p_x_header_rec.sold_to_org_id = FND_API.G_MISS_NUM Then
           p_x_header_rec.sold_to_org_id := p_x_line_tbl(I).sold_to_org_id;
        End If;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'AFTER SOLDTOORGID '|| P_X_LINE_TBL ( I ) .SOLD_TO_ORG_ID ) ;
        END IF;

        IF (p_x_line_tbl(I).sold_to_org_id = FND_API.G_MISS_NUM OR
           p_x_line_tbl(I).sold_to_org_id IS NULL)
        THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SOLD TO ORG ID IS MISSING , AFTER CALL TO VALUE TO ID' ) ;
        END IF;
          FND_MESSAGE.SET_NAME('ONT','OE_INVALID_CUSTOMER_ID');
          OE_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;
    Exception
      When others then
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'OTHERS EXCEPTION WHEN GETTING SOLD TO ORG ID IN OEXVIMSB... ' ) ;
       END IF;
       FND_MESSAGE.SET_NAME('ONT','OE_INVALID_CUSTOMER_ID');
       OE_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
    End;
    -- End Begin}
   End If;
   -- End of derivation of the sold_to_org_id for Header/Line }

   -- This initialization is done to avoid use of the old value for next
   -- loop
   l_inventory_item_id_int  := NULL;
   l_inventory_item_id_ord  := NULL;
   l_inventory_item_id_cust := NULL;
   l_inventory_item_id_gen  := NULL;
   --bug#4174961
   IF (p_x_line_tbl(I).inventory_item_id <>  FND_API.G_MISS_NUM AND
      p_x_line_tbl(I).inventory_item_id IS NOT NULL)
   THEN
    l_inventory_item_id_int  := p_x_line_tbl(I).inventory_item_id;
   END IF;

-- Aksingh Adding code for the Item Derivation and Cross Referencing
-- { Adding 11/14/2000 Start
   IF (p_x_line_val_tbl(I).inventory_item <> FND_API.G_MISS_CHAR AND
      p_x_line_val_tbl(I).inventory_item IS NOT NULL) AND
      (p_x_line_tbl(I).inventory_item_id =  FND_API.G_MISS_NUM OR
      p_x_line_tbl(I).inventory_item_id IS NULL)
   THEN
      BEGIN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN OEXVIMSB ITEM IDENTIFIER IS INT' ) ;
         END IF;
         SELECT inventory_item_id
         INTO  l_inventory_item_id_int
         FROM  mtl_system_items_vl
         WHERE concatenated_segments = p_x_line_val_tbl(I).inventory_item
         AND   customer_order_enabled_flag = 'Y'
         AND   bom_item_type in (1,2,4)
         AND   organization_id =
               oe_sys_parameters.Value('MASTER_ORGANIZATION_ID',l_org_id);

         p_x_line_tbl(I).inventory_item_id := l_inventory_item_id_int;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN OEXVIMSB ITEM IDENTIFIER IS INT - NO_DATA' ) ;
         END IF;
        When too_many_rows then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN OEXVIMSB ITEM IDENTIFIER IS INT - TOO_MANY' ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'TOO MANY ROWS ERROR: '||SQLERRM ) ;
         END IF;
         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Pre_Process_INT_ITEM');
         END IF;
	   When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN OEXVIMSB ITEM IDENTIFIER IS INT - OTHERS' ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
         END IF;
         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Pre_Process_INT_ITEM');
         END IF;
      END;
    END IF;
--  Adding 11/14/2000 End }

 -- { Get inventory item id for the ordered_item or ordered_item_id
 IF (NVL(p_x_line_tbl(I).item_identifier_type,'INT') IN ('INT','CUST') OR
        p_x_line_tbl(I).item_identifier_type = FND_API.G_MISS_CHAR)
 THEN
   IF (p_x_line_tbl(I).ordered_item <> FND_API.G_MISS_CHAR AND
      p_x_line_tbl(I).ordered_item IS NOT NULL)
   THEN
      BEGIN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN OEXVIMSB ITEM IDENTIFIER IS INT WITH ORDERED_ITEM' ) ;
         END IF;
         SELECT inventory_item_id
         INTO  l_inventory_item_id_ord
         FROM  mtl_system_items_vl
         WHERE concatenated_segments = p_x_line_tbl(I).ordered_item
         AND   customer_order_enabled_flag = 'Y'
         AND   bom_item_type in (1,2,4)
         AND   organization_id =
               oe_sys_parameters.Value('MASTER_ORGANIZATION_ID',l_org_id);

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN OEXVIMSB ITEM IDENTIFIER IS INT - NO_DATA' ) ;
         END IF;
        When too_many_rows then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN OEXVIMSB ITEM IDENTIFIER IS INT - TOO_MANY' ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'TOO MANY ROWS ERROR: '||SQLERRM ) ;
         END IF;
         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Pre_Process_INT_ITEM');
         END IF;
	   When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN OEXVIMSB ITEM IDENTIFIER IS INT - OTHERS' ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
         END IF;
         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Pre_Process_INT_ITEM');
         END IF;
      END;
    ELSIF (p_x_line_tbl(I).ordered_item_id <> FND_API.G_MISS_NUM AND
           p_x_line_tbl(I).ordered_item_id IS NOT NULL)
    THEN
      BEGIN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'IN OEXVIMSB ITEM IDEN IS INT WITH ORDERED_ITEM_ID' ) ;
      END IF;
         SELECT customer_item_number
         INTO  p_x_line_tbl(I).ordered_item
         FROM  mtl_customer_items
         WHERE customer_item_id = p_x_line_tbl(I).ordered_item_id
         AND   inactive_flag    = 'N';

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN OEXVIMSB ITEM IDENTIFIER IS INT - NO_DATA' ) ;
         END IF;
        When too_many_rows then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN OEXVIMSB ITEM IDENTIFIER IS INT - TOO_MANY' ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'TOO MANY ROWS ERROR: '||SQLERRM ) ;
         END IF;
         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Pre_Process_INT_ITEM');
         END IF;
	   When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN OEXVIMSB ITEM IDENTIFIER IS INT - OTHERS' ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
         END IF;
         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Pre_Process_INT_ITEM');
         END IF;
      END;
    END IF;
 END IF;
 -- End of get inventory item id for ordered_item or ordered_item_id }

    -- { Get inventory item id and customer item id for type 'CUST'
    IF (NVL(p_x_line_tbl(I).item_identifier_type, 'CUST') = 'CUST' OR
        p_x_line_tbl(I).item_identifier_type = FND_API.G_MISS_CHAR) AND
       (p_x_line_tbl(I).ordered_Item is NOT NULL AND
       p_x_line_tbl(I).ordered_Item <> FND_API.G_MISS_CHAR  OR
       p_x_line_tbl(I).ordered_Item_id is NOT NULL AND
       p_x_line_tbl(I).ordered_Item_id <> FND_API.G_MISS_NUM)
       THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN OEXVIMSB. ITEM IDENTIFIER IS CUST' ) ;
         END IF;
         IF (p_x_line_tbl(I).sold_to_org_id = FND_API.G_MISS_NUM OR
            p_x_line_tbl(I).sold_to_org_id IS NULL) AND
            ((p_x_line_val_tbl(I).sold_to_org <> FND_API.G_MISS_CHAR AND
            p_x_line_val_tbl(I).sold_to_org IS NOT NULL) OR
            (p_x_header_val_rec.customer_number <> FND_API.G_MISS_CHAR AND
            p_x_header_val_rec.customer_number IS NOT NULL) OR
            (p_x_header_val_rec.sold_to_org <> FND_API.G_MISS_CHAR AND
            p_x_header_val_rec.sold_to_org IS NOT NULL))
         THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'BEFORE CALLING SOLD TO ORG ID' ) ;
           END IF;
           p_x_line_tbl(I).sold_to_org_id := oe_value_to_id.sold_to_org(
                           p_sold_to_org => nvl(p_x_header_val_rec.sold_to_org,
                                            p_x_line_val_tbl(I).sold_to_org),
                       p_customer_number => p_x_header_val_rec.customer_number);
           If p_x_header_rec.sold_to_org_id is NULL OR
              p_x_header_rec.sold_to_org_id = FND_API.G_MISS_NUM Then
              p_x_header_rec.sold_to_org_id := p_x_line_tbl(I).sold_to_org_id;
           End If;

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'AFTER SOLDTOORGID '|| P_X_LINE_TBL ( I ) .SOLD_TO_ORG_ID ) ;
           END IF;
         END IF;
	 -- 6 Lines are deleted from here, check the previous version for details.

	 IF p_x_line_tbl(I).ordered_item_id = FND_API.G_MISS_NUM THEN
            l_ordered_item_id := NULL;
         ELSE
            l_ordered_item_id := p_x_line_tbl(I).ordered_item_id;
         END IF;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVENTORY_ITEM_ID BEFORE CALLING CI_ATTRIBUTE_VALUE ' ||TO_CHAR ( P_X_LINE_TBL ( I ) .INVENTORY_ITEM_ID ) , 1 ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'CUST ITEM ID = '||P_X_LINE_TBL ( I ) .ORDERED_ITEM_ID ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'CUST ITEM ID = '||L_ORDERED_ITEM_ID ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'CUSTOMER_ID AT LINE = '||P_X_LINE_TBL ( I ) .SOLD_TO_ORG_ID ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'CUSTOMER_ID AT HEADER = '||P_X_HEADER_REC.SOLD_TO_ORG_ID ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'CUSTOMER_ITEM_NUMBER = '||P_X_LINE_TBL ( I ) .ORDERED_ITEM ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ORGANIZATION_ID = '||P_X_LINE_TBL ( I ) .SHIP_FROM_ORG_ID ) ;
         END IF;
         -- Fix for bug 1654669 start
         If p_x_line_tbl(I).ship_from_org_id = FND_API.G_MISS_NUM Then
            l_ship_from_org_id := NULL;
         Else
            l_ship_from_org_id := p_x_line_tbl(I).ship_from_org_id;
         End If;
         -- Fix for bug 1654669 end
         -- Fix for 2626323
    IF ((p_x_header_rec.ship_to_org_id IS NOT NULL AND --Bug 5383045
     p_x_header_rec.ship_to_org_id <> FND_API.G_MISS_NUM) AND
    (p_x_line_tbl(I).ship_to_org_id IS NULL OR
     p_x_line_tbl(I).ship_to_org_id =FND_API.G_MISS_NUM))THEN

     p_x_line_tbl(I).ship_to_org_id :=p_x_header_rec.ship_to_org_id;
    END IF;

    IF (p_x_line_tbl(I).ship_to_org_id IS NOT NULL AND
        p_x_line_tbl(I).ship_to_org_id <> FND_API.G_MISS_NUM) THEN
                  SELECT  /* MOAC_SQL_CHANGE */ u.cust_acct_site_id,
                s.cust_account_id
        INTO  l_address_id
              ,l_cust_id
        FROM  HZ_CUST_SITE_USES_ALL u,   --moac
              HZ_CUST_ACCT_SITES s
        WHERE  u.cust_acct_site_id = s.cust_acct_site_id
        AND    u.org_id = s.org_id
        AND    u.site_use_id = p_x_line_tbl(I).ship_to_org_id
        AND    u.site_use_code = 'SHIP_TO';

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SHIP TO ADDRESS:' || L_ADDRESS_ID||' - CUSTOMER:'||TO_CHAR ( L_CUST_ID ) ) ;
        END IF;
       IF l_cust_id <> p_x_line_tbl(I).sold_to_org_id  THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'SOLD-TO CUSTOMER:'||TO_CHAR ( P_X_LINE_TBL ( I ) .SOLD_TO_ORG_ID ) ) ;
          END IF;
          l_address_id := NULL;
        END IF;
     END IF;

        IF (p_x_line_tbl(I).inventory_item_id = FND_API.G_MISS_NUM OR
            p_x_line_tbl(I).inventory_item_id IS NULL)  THEN
             l_inventory_id := NULL;
          ELSE
             l_inventory_id :=  p_x_line_tbl(I).inventory_item_id;
        END IF;

       --Start of bug# 13574394
        IF Nvl(p_x_line_tbl(I).return_reason_code,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR OR
           p_x_line_tbl(I).line_category_code = 'RETURN' OR
           Nvl(p_x_line_tbl(I).return_context,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR OR
           Nvl(p_x_line_tbl(I).return_attribute1,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR OR
           Nvl(p_x_line_tbl(I).return_attribute2, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR OR
           p_x_line_tbl(I).ordered_quantity < 0

        THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'Its a Return Order Line' ) ;
          END IF;
          INV_CUSTOMER_ITEM_GRP.CI_Attribute_Value(
                       Z_Customer_Item_Id => l_ordered_item_id
                     , Z_Customer_Id => p_x_header_rec.sold_to_org_id
                     , Z_Customer_Item_Number => p_x_line_tbl(I).Ordered_Item
                     , Z_Address_Id => l_address_id
                     , Z_Organization_Id => nvl(l_ship_from_org_id, OE_Sys_Parameters.value('MASTER_ORGANIZATION_ID',l_org_id))
                     , Z_Inventory_Item_Id => l_inventory_id
                     , Attribute_Name => 'INVENTORY_ITEM_ID'
                     , Error_Code => l_error_code
                     , Error_Flag => l_error_flag
                     , Error_Message => l_error_message
                     , Attribute_Value => l_inventory_item_id_cust
		     , Z_Line_Category_Code => 'RETURN'
                     );
        ELSE
          OE_DEBUG_PUB.ADD('Its Normal Sales Order Line');
          INV_CUSTOMER_ITEM_GRP.CI_Attribute_Value(
                       Z_Customer_Item_Id => l_ordered_item_id
                     , Z_Customer_Id => p_x_header_rec.sold_to_org_id
                     , Z_Customer_Item_Number => p_x_line_tbl(I).Ordered_Item
                   , Z_Address_Id => l_address_id
                     , Z_Organization_Id => nvl(l_ship_from_org_id, OE_Sys_Parameters.value('MASTER_ORGANIZATION_ID',l_org_id))
                     , Z_Inventory_Item_Id => l_inventory_id
                     , Attribute_Name => 'INVENTORY_ITEM_ID'
                     , Error_Code => l_error_code
                     , Error_Flag => l_error_flag
                     , Error_Message => l_error_message
                     , Attribute_Value => l_inventory_item_id_cust
                     , Z_Line_Category_Code => 'ORDER'
                     );

         END IF;    --End of bug# 13574394



          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INV CUST VAL RET BY INVAPI = '||L_INVENTORY_ITEM_ID_CUST ) ;
          END IF;
          IF l_error_message IS NOT NULL
          THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'CALLED TO THE INV API CI_ATTR_VAL RETURNED ERROR' ) ;
           END IF;
	      FND_MESSAGE.SET_NAME('ONT','OE_INV_CUS_ITEM');
           FND_MESSAGE.SET_TOKEN('ERROR_CODE', l_error_code);
           FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE', l_error_message);
           OE_MSG_PUB.Add;
          END IF;

        --Start of bug# 13574394
        IF Nvl(p_x_line_tbl(I).return_reason_code,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR OR
           p_x_line_tbl(I).line_category_code = 'RETURN' OR
           Nvl(p_x_line_tbl(I).return_context,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR OR
           Nvl(p_x_line_tbl(I).return_attribute1,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR OR
           Nvl(p_x_line_tbl(I).return_attribute2, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR OR
           p_x_line_tbl(I).ordered_quantity < 0
        THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'Its a Return Order Line' ) ;
          END IF;

	  INV_CUSTOMER_ITEM_GRP.CI_Attribute_Value(
                       Z_Customer_Item_Id => l_ordered_item_id
                     , Z_Customer_Id => p_x_header_rec.sold_to_org_id
                     , Z_Customer_Item_Number => p_x_line_tbl(I).Ordered_Item
                   , Z_Address_Id => l_address_id
                     , Z_Organization_Id => nvl(l_ship_from_org_id , OE_Sys_Parameters.value('MASTER_ORGANIZATION_ID',l_org_id))
                     , Z_Inventory_Item_Id => NULL
                     , Attribute_Name => 'CUSTOMER_ITEM_ID'
                     , Error_Code => l_error_code
                     , Error_Flag => l_error_flag
                     , Error_Message => l_error_message
                     , Attribute_Value => p_x_line_tbl(I).ordered_item_id
                     , Z_Line_Category_Code => 'RETURN'
                     );
        ELSE
          OE_DEBUG_PUB.ADD('Its Normal Order Line');
          INV_CUSTOMER_ITEM_GRP.CI_Attribute_Value(
                       Z_Customer_Item_Id => l_ordered_item_id
                     , Z_Customer_Id => p_x_header_rec.sold_to_org_id
                     , Z_Customer_Item_Number => p_x_line_tbl(I).Ordered_Item
                   , Z_Address_Id => l_address_id
                     , Z_Organization_Id => nvl(l_ship_from_org_id , OE_Sys_Parameters.value('MASTER_ORGANIZATION_ID',l_org_id))
                     , Z_Inventory_Item_Id => NULL
                     , Attribute_Name => 'CUSTOMER_ITEM_ID'
                     , Error_Code => l_error_code
                     , Error_Flag => l_error_flag
                     , Error_Message => l_error_message
                     , Attribute_Value => p_x_line_tbl(I).ordered_item_id
                     , Z_Line_Category_Code => 'ORDER'
                     );

    END IF;	--End of bug# 13574394

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ORDRD VAL RET BY INVAPI = '||P_X_LINE_TBL ( I ) .ORDERED_ITEM_ID ) ;
        END IF;
        IF l_error_message IS NOT NULL
        THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'CALLED TO THE INV API CI_ATTR_VAL RETURNED ERROR:' || l_error_message ) ;
           END IF;
           FND_MESSAGE.SET_NAME('ONT','OE_INV_CUS_ITEM');
           FND_MESSAGE.SET_TOKEN('ERROR_CODE', l_error_code);
           FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE', l_error_message);
           OE_MSG_PUB.Add;
        ELSE  --moved assignment of item_identifier_type to ELSE clause to prevent incorrect
              --assignment when a customer item is not found by the inventory API...bug 3683667
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'ASSIGNING ITEM_IDENTIFIER_TYPE AS CUST' ) ;
           END IF;
           p_x_line_tbl(I).item_identifier_type := 'CUST';
        END IF;


        IF l_inventory_item_id_ord IS NOT NULL AND
           l_inventory_item_id_cust IS NOT NULL AND
           l_inventory_item_Id_ord <> l_inventory_item_id_cust
        THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'WARNING: CUST AND INVENTORY ITEM ARE DIFFERENT' ) ;
           END IF;
	      FND_MESSAGE.SET_NAME('ONT','OE_INV_INT_CUS_ITEM_ID');
           FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', l_inventory_item_id_ord);
           FND_MESSAGE.SET_TOKEN('CUST_ITEM_ID', l_inventory_item_id_cust);
           OE_MSG_PUB.Add;
           p_x_line_tbl(I).inventory_item_id := l_inventory_item_id_cust;
        ELSIF l_inventory_item_id_ord IS NOT NULL
        THEN
           p_x_line_tbl(I).inventory_item_id := l_inventory_item_id_ord;
        ELSIF l_inventory_item_id_cust IS NOT NULL
        THEN
           p_x_line_tbl(I).inventory_item_id := l_inventory_item_id_cust;
        END IF;

    END IF; -- CUST

    -- } End of Get inventory item id and customer item id for type 'CUST'

    -- { Get inventory item id for Generice Item
    IF (NVL(p_x_line_tbl(I).item_identifier_type,'INT') NOT IN ('INT','CUST') AND
        p_x_line_tbl(I).item_identifier_type <> FND_API.G_MISS_CHAR) AND
       (p_x_line_tbl(I).ordered_Item is NOT NULL AND
       p_x_line_tbl(I).ordered_Item <> FND_API.G_MISS_CHAR)
    THEN
      BEGIN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'IN OEXVIMSB. ITEM IDENTIFIER IS '||P_X_LINE_TBL ( I ) .ITEM_IDENTIFIER_TYPE ) ;
       END IF;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ORDERED_ITEM_ID: '||P_X_LINE_TBL ( I ) .ORDERED_ITEM_ID ) ;
       END IF;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ORDERED_ITEM: '||P_X_LINE_TBL ( I ) .ORDERED_ITEM ) ;
       END IF;
       SELECT inventory_item_id
       INTO   l_inventory_item_id_gen
       FROM   mtl_cross_references
       WHERE  cross_reference_type = p_x_line_tbl(I).item_identifier_type
         AND  (organization_id =
                         OE_Sys_Parameters.value('MASTER_ORGANIZATION_ID',l_org_id)
         OR   organization_id IS NULL)
         AND  cross_reference = p_x_line_tbl(I).ordered_item
         And  (inventory_item_id =  l_inventory_item_id_int
          OR  l_inventory_item_id_int IS NULL);

       IF l_inventory_item_id_ord IS NOT NULL AND
          l_inventory_item_id_gen IS NOT NULL AND
          l_inventory_item_Id_ord <> l_inventory_item_id_gen
       THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'WARNING: GENERIC AND INVENTORY ITEM ARE DIFFERENT' ) ;
          END IF;
	     FND_MESSAGE.SET_NAME('ONT','OE_INV_INT_CUS_ITEM_ID');
          FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', l_inventory_item_id_ord);
          FND_MESSAGE.SET_TOKEN('CUST_ITEM_ID', l_inventory_item_id_gen);
          OE_MSG_PUB.Add;
          p_x_line_tbl(I).inventory_item_id := l_inventory_item_id_gen;
       ELSIF l_inventory_item_id_ord IS NOT NULL
       THEN
          p_x_line_tbl(I).inventory_item_id := l_inventory_item_id_ord;
       ELSIF l_inventory_item_id_gen IS NOT NULL
       THEN
          p_x_line_tbl(I).inventory_item_id := l_inventory_item_id_gen;
       END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN OEXVIMSB ITEM IDENTIFIER IS GEN - NO_DATA' ) ;
         END IF;
        When too_many_rows then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'TOO MANY ROWS ERROR: '||SQLERRM ) ;
         END IF;
	    FND_MESSAGE.SET_NAME('ONT','OE_NOT_UNIQUE_ITEM');
         FND_MESSAGE.SET_TOKEN('GENERIC_ITEM', p_x_line_tbl(I).ordered_item);
         OE_MSG_PUB.Add;
         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Pre_Process_GEN_ITEM');
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN OEXVIMSB ITEM IDENTIFIER IS GEN - TO_MANY' ) ;
         END IF;
	   When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
         END IF;
         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Pre_Process_GEN_ITEM');
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN OEXVIMSB ITEM IDENTIFIER IS GEN - OTHERS' ) ;
         END IF;
      END;
    END IF;
    -- } End of  Get inventory item id for Generice Item
   /*Added for bug 5088655*/
   IF( l_inventory_item_id_int IS NULL AND
   l_inventory_item_id_ord  IS  NULL AND
   l_inventory_item_id_cust IS  NULL AND
   l_inventory_item_id_gen  IS  NULL )
   and p_x_line_tbl(I).operation in ('CREATE','INSERT') --added for bug 5509598
   and (nvl(p_x_line_tbl(I).split_from_line_ref,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR) THEN  --added for bug 5531063
         p_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

    IF  (p_x_line_tbl(I).inventory_item_id IS NOT NULL
    AND p_x_line_tbl(I).inventory_Item_id <> FND_API.G_MISS_NUM)
    AND (p_x_line_val_tbl(I).inventory_item IS NOT NULL
    AND p_x_line_val_tbl(I).inventory_Item <> FND_API.G_MISS_CHAR)
    THEN
        p_x_line_val_tbl(I).inventory_item := FND_API.G_MISS_CHAR;
    END IF;


-- Aksingh 11/14/2000 End for Cross Reference

/* -----------------------------------------------------------
      Validate calculate price flag
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING CALCULATE PRICE FLAG' ) ;
      END IF;

      IF p_x_line_tbl(I).calculate_price_flag NOT IN ('N','Y','P') AND
	 p_x_line_tbl(I).calculate_price_flag <> FND_API.G_MISS_CHAR	--added for bug#13062903
      THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'INVALID CALCULATE_PRICE FLAG... ' ) ;
	 END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_CALCULATE_PRICE');
         OE_MSG_PUB.Add;
  	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

/* -----------------------------------------------------------
      Check List_Price and Selling_price
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING LIST AND SELLING PRICE' ) ;
      END IF;

      IF p_x_line_tbl(I).calculate_price_flag = 'N' AND
        (p_x_line_tbl(I).unit_list_price    = FND_API.G_MISS_NUM OR
	    p_x_line_tbl(I).unit_selling_price = FND_API.G_MISS_NUM) AND
         p_x_line_tbl(I).Item_Type_Code <> 'INCLUDED'

      THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'LIST PRICE OR SELLING PRICE IS NULL... ' ) ;
	 END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_PRICE');
         OE_MSG_PUB.Add;
  	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

/* -----------------------------------------------------------
      Check Pricing_Qunatity and Pricing_Quantity_Uom and update
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING PRICING QUNATITY AND UOM' ) ;
      END IF;

      IF p_x_line_tbl(I).calculate_price_flag = 'N' AND
        (p_x_line_tbl(I).pricing_quantity    = FND_API.G_MISS_NUM OR
         p_x_line_tbl(I).pricing_quantity    = NULL)
      THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'PRICING QUANTITY IS NULL...RESETTING ' ) ;
         END IF;
         p_x_line_tbl(I).pricing_quantity := p_x_line_tbl(I).ordered_quantity;
         p_x_line_tbl(I).pricing_quantity_uom := p_x_line_tbl(I).order_quantity_uom;
      END IF;

   --------------------------------------------------------------
   -- Importing Service lines for the Order/CUSTOMER PRODUCT context --
   --------------------------------------------------------------

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ITEM_TYPE ' || P_X_LINE_TBL ( I ) .ITEM_TYPE_CODE ) ;
      END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'REF_TYPE ' || P_X_LINE_TBL ( I ) .SERVICE_REFERENCE_TYPE_CODE ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'REF_ORDER ' || P_X_LINE_TBL ( I ) .SERVICE_REFERENCE_ORDER ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'REF_LINE ' || P_X_LINE_TBL ( I ) .SERVICE_REFERENCE_LINE ) ;
	 END IF;
--	 oe_debug_pub.add('ref_order ' || nvl(p_x_line_tbl(I).service_reference_order, FND_API.G_MISS_CHAR));
--	 oe_debug_pub.add('ref_line ' ||  nvl(p_x_line_tbl(I).service_reference_line, FND_API.G_MISS_CHAR));

      IF p_x_line_tbl(I).item_type_code = 'SERVICE' AND
         p_x_line_tbl(I).service_reference_type_code = 'ORDER' AND
         p_x_line_tbl(I).service_reference_order <> FND_API.G_MISS_CHAR AND
         p_x_line_tbl(I).service_reference_line <> FND_API.G_MISS_CHAR
      THEN
         -- Immediate Service
         IF p_x_line_tbl(I).service_reference_order =
            p_x_line_tbl(I).orig_sys_document_ref
         THEN
            -- Populate index for the link
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'LOOPING LINE TABLE OF RECORD TO FIND THE INDEX' ) ;
            END IF;
            FOR J in 1..p_x_line_tbl.count
            LOOP
              IF p_x_line_tbl(J).orig_sys_line_ref =
                 p_x_line_tbl(I).service_reference_line
              THEN
                 p_x_line_tbl(I).service_line_index := J;
                 goto next_line;
              END IF;
            END LOOP;
            -- This condition is for Immediate service being enter during
            -- order update(semi delayed!!)
            BEGIN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'FOR SEMI DELAYED SERVICE GET THE LINE_ID' ) ;
              END IF;
              SELECT line_id
              INTO   p_x_line_tbl(I).service_reference_line_id
              FROM   oe_order_lines ol
              WHERE  ol.header_id = l_header_id
              AND    ol.orig_sys_line_ref =
                     p_x_line_tbl(I).service_reference_line
              AND    decode(l_customer_key_profile, 'Y',
		     nvl(ol.sold_to_org_id, FND_API.G_MISS_NUM), 1)
                =    decode(l_customer_key_profile, 'Y',
		     nvl(p_x_line_tbl(I).sold_to_org_id, FND_API.G_MISS_NUM), 1);
            EXCEPTION
             WHEN NO_DATA_FOUND THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'NOT FOUND LINEID FOR SEMI-DELAYED SERVICE' ) ;
               END IF;
	          FND_MESSAGE.SET_NAME('ONT','OE_NO_SERV_TRANS');
               OE_MSG_PUB.Add;
               p_return_status := FND_API.G_RET_STS_ERROR;
             WHEN OTHERS THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
               END IF;
              IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_Msg_Lvl_Unexp_Error) THEN
  	           p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Pre_Process.Line_id derivation for semi-delayed service');
              END IF;
            END;
         ELSE
          BEGIN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'FOR DELAYED SERVICE GET THE LINE_ID' ) ;
            END IF;
            SELECT line_id
            INTO   p_x_line_tbl(I).service_reference_line_id
            FROM   oe_order_lines ol
            WHERE  ol.order_source_id =
                   p_x_header_rec.order_source_id
            AND    ol.orig_sys_document_ref =
                   p_x_line_tbl(I).service_reference_order
            AND    ol.orig_sys_line_ref =
                   p_x_line_tbl(I).service_reference_line
            AND    decode(l_customer_key_profile, 'Y',
		   nvl(ol.sold_to_org_id, FND_API.G_MISS_NUM), 1)
               =   decode(l_customer_key_profile, 'Y',
        	   nvl(p_x_line_tbl(I).sold_to_org_id, FND_API.G_MISS_NUM), 1);

          EXCEPTION
           WHEN NO_DATA_FOUND THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'NOT FOUND ORDER LINE FOR DELAYED SERVICE' ) ;
             END IF;
	        FND_MESSAGE.SET_NAME('ONT','OE_NO_SERV_TRANS');
             OE_MSG_PUB.Add;
             p_return_status := FND_API.G_RET_STS_ERROR;
           WHEN OTHERS THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
             END IF;
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_Msg_Lvl_Unexp_Error) THEN
	           p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Pre_Process.Line_id derivation for delayed service');
            END IF;
          END;
         END IF;
      ELSIF p_x_line_tbl(I).item_type_code = 'SERVICE' AND
         p_x_line_tbl(I).service_reference_type_code = 'CUSTOMER_PRODUCT' AND
         p_x_line_tbl(I).service_reference_order = FND_API.G_MISS_CHAR AND
      -- second OR condition now removed as service_reference_system cannot be processed without
      -- service_reference_line
        p_x_line_tbl(I).service_reference_line <> FND_API.G_MISS_CHAR
      THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'REF_SYSTEM ' || P_X_LINE_TBL ( I ) .SERVICE_REFERENCE_SYSTEM ) ;
	 END IF;
         -- Assign service reference system to line rec (if populated)
        BEGIN
            p_x_line_tbl(I).service_reference_line_id :=
            to_number(p_x_line_tbl(I).service_reference_line);
          If p_x_line_tbl(I).service_reference_system <> FND_API.G_MISS_CHAR then
            p_x_line_tbl(I).service_reference_system_id :=
            to_number(p_x_line_tbl(I).service_reference_system);
          End If;
        EXCEPTION
           WHEN OTHERS THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
            END IF;
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_Msg_Lvl_Unexp_Error) THEN
	          p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Pre_Process.system_id derivation for delayed service');
            END IF;
        END;
      ELSIF p_x_line_tbl(I).item_type_code = 'SERVICE'
      THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'REQUIRED DATA IS MISSING FOR SERVICE LINE' ) ;
         END IF;
	    FND_MESSAGE.SET_NAME('ONT','OE_NO_SERV_TRANS');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
   <<next_line>>
	null;
    /* bsadri fill in the IDs for actions if this is an update */
    BEGIN
    IF p_x_line_tbl(I).operation IN ('UPDATE','DELETE')
      AND p_x_header_rec.operation IN ('UPDATE','DELETE') THEN
    -- The following condition is added for #1927259
   if (p_x_action_request_tbl.COUNT >0 ) then
      FOR b in l_counter..p_x_action_request_tbl.COUNT
      LOOP--{
         l_counter_memory := l_counter_memory + 1;
         IF p_x_action_request_tbl(b).entity_code = OE_Globals.G_ENTITY_LINE
          AND p_x_action_request_tbl(b).entity_index = l_line_count THEN
            p_x_action_request_tbl(b).entity_id := p_x_line_tbl(I).line_id;
/*myerrams, Customer Acceptance, Populating the Action_request table with Header id if Customer Acceptance is enabled.*/
	    IF  p_x_action_request_tbl(b).request_type = OE_Globals.G_ACCEPT_FULFILLMENT  OR  p_x_action_request_tbl(b).request_type = OE_Globals.G_REJECT_FULFILLMENT THEN
		    IF (OE_SYS_PARAMETERS.VALUE('ENABLE_FULFILLMENT_ACCEPTANCE',l_org_id) = 'Y') THEN
			p_x_action_request_tbl(b).param5 := p_x_line_tbl(I).header_id;
	            END IF;
	    END IF;
/*myerrams, Customer Acceptance, end*/
            IF p_x_action_request_tbl(b).request_type =
                                                OE_Globals.G_LINK_CONFIG
            THEN
              p_x_action_request_tbl(b).param1 :=
                     p_x_line_tbl(I).inventory_item_id;
            END IF;
         END IF;
         IF p_x_action_request_tbl(b).entity_code = OE_Globals.G_ENTITY_LINE
          AND p_x_action_request_tbl(b).entity_index > l_line_count THEN
              raise e_break;
         END IF;
      END LOOP;--}
    end if;
      l_counter := l_counter_memory - 1;
    END IF;
    EXCEPTION
      WHEN e_break THEN
          l_counter := l_counter_memory - 1;
    END;
   END LOOP; --}

   FOR I in 1..p_x_line_adj_tbl.count
   LOOP
/* -----------------------------------------------------------
      Set message context for line price adjustments
   -----------------------------------------------------------
*/
      l_price_adjustment_id := NULL;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT FOR LINE PRICE ADJUSTMENTS' ) ;
      END IF;

      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'LINE_ADJ'
        ,p_entity_ref                 => p_x_line_adj_tbl(I).orig_sys_discount_ref
        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => p_x_line_tbl(p_x_line_adj_tbl(I).line_index).line_id
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => p_x_line_tbl(p_x_line_adj_tbl(I).line_index).orig_sys_line_ref
        ,p_orig_sys_shipment_ref      => p_x_line_tbl(p_x_line_adj_tbl(I).line_index).orig_sys_shipment_ref
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

/* -----------------------------------------------------------
      Validate orig sys discount ref for line
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING ORIG_SYS_DISCOUNT_REF FOR LINE' ) ;
      END IF;

      IF p_x_line_adj_tbl(I).orig_sys_discount_ref = FND_API.G_MISS_CHAR
      THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'INVALID ORIG_SYS_DISCOUNT_REF FOR LINE... ' ) ;
	 END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_ORIG_SYS_DISCOUNT_REF');
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

/* -----------------------------------------------------------
      Validate line adjustments operation code
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING LINE ADJUSTMENTS OPERATION CODE' ) ;
      END IF;

      IF p_x_line_adj_tbl(I).operation NOT IN ('INSERT','CREATE',
					     'UPDATE','DELETE') OR
        (p_x_line_tbl(p_x_line_adj_tbl(I).line_index).operation
			     		 IN ('INSERT','CREATE') AND
         p_x_line_adj_tbl(I).operation NOT IN ('INSERT','CREATE')) OR
        (p_x_line_tbl(p_x_line_adj_tbl(I).line_index).operation
			     		 IN ('UPDATE') AND
         p_x_line_adj_tbl(I).operation NOT IN ('INSERT','CREATE','UPDATE','DELETE')) OR
        (p_x_line_tbl(p_x_line_adj_tbl(I).line_index).operation
			     		 IN ('DELETE') AND
         p_x_line_adj_tbl(I).operation NOT IN ('DELETE'))
      THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'INVALID LINE ADJUSTMENTS OPERATION CODE...' ) ;
	 END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

-- aksingh start on this (10/11/2000) this is in process of being coded
      IF  p_x_line_adj_tbl(I).operation IN ('INSERT', 'CREATE')
      AND p_x_header_rec.operation = 'UPDATE'
      AND p_x_line_tbl(p_x_line_adj_tbl(I).line_index).operation = 'UPDATE'
      THEN
      Begin
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NEW ADJUSTMENT FOR LINE LEVEL , THE EXISITNG HEARDER_ID:' || TO_CHAR ( P_X_HEADER_REC.HEADER_ID ) ) ;
         END IF;
         p_x_line_adj_tbl(I).header_id  := l_header_id;
       /*  Bug #2108967 -- Passing the correct line_id    */
         p_x_line_adj_tbl(I).line_id    := p_x_line_tbl(p_x_line_adj_tbl(I).line_index).line_id;

         SELECT 1 into l_count
           FROM oe_price_adjustments
          WHERE header_id              = p_x_header_rec.header_id
            AND line_id                = l_line_id
            AND orig_sys_discount_ref  =
                       p_x_line_adj_tbl(I).orig_sys_discount_ref
            AND rownum                < 2;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO INSERT A NEW LNADJ WITH THE SAME HEADER_ID , LINE_ID AND ORIG_SYS_DISCOUNT_REF... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      Exception
        When no_data_found then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'VALID LINE LEVEL PRICE ADJ FOR INSERT' ) ;
          END IF;
        When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OTHERS EXCEPTION WHEN INSERTING NEW LINE PRICE ADJ... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      End;
      End IF; -- Insert, Create Operation

      IF  p_x_line_adj_tbl(I).operation IN ('UPDATE','DELETE')
      AND p_x_header_rec.operation IN ('UPDATE','DELETE')
      AND p_x_line_tbl(p_x_line_adj_tbl(I).line_index).operation IN ('UPDATE','DELETE')
      THEN
      Begin
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'HEADER ID: '||TO_CHAR ( P_X_HEADER_REC.HEADER_ID ) ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'LINE ID: '|| L_LINE_ID ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'DISCOUNT REF: '||P_X_LINE_ADJ_TBL ( I ) .ORIG_SYS_DISCOUNT_REF ) ;
         END IF;
         p_x_line_adj_tbl(I).header_id  := l_header_id;
         p_x_line_adj_tbl(I).line_id    := p_x_line_tbl(p_x_line_adj_tbl(I).line_index).line_id;
         SELECT price_adjustment_id
           INTO l_price_adjustment_id
           FROM oe_price_adjustments
          WHERE header_id             = l_header_id
            AND line_id               = p_x_line_adj_tbl(I).line_id
            AND orig_sys_discount_ref =
                p_x_line_adj_tbl(I).orig_sys_discount_ref;

         p_x_line_adj_tbl(I).price_adjustment_id := l_price_adjustment_id;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'HEADER ID: '||TO_CHAR ( P_X_LINE_ADJ_TBL ( I ) .HEADER_ID ) ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ADJUST ID: '||TO_CHAR ( P_X_LINE_ADJ_TBL ( I ) .PRICE_ADJUSTMENT_ID ) ) ;
         END IF;

      Exception
        When no_data_found then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO UPDATE OR DELETE AN EXISTING LINE ADJ BUT THAT DOES NOT EXIST... ' ) ;
          END IF;
          FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
          OE_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
        When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OTHERS EXCEPTION WHEN TRYING TO UPDATE OR DELETE AN EXISTING LINEADJ ... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      End;
      End IF; -- Update and Delete operation

-- aksingh(10/11/2000) this is in process of being coded upto this point

-- Following changes are made to fix the bug# 1220921, It will call the
-- api to get the id(header and line) also the list_line_type code to
-- pass it to process_order as right now it is not possible to call
-- process order to import order without passing the these ids.
-- {

  If   (p_x_line_adj_tbl(I).list_header_id is null
       or  p_x_line_adj_tbl(I).list_header_id = FND_API.G_MISS_NUM)
      and (p_x_line_adj_tbl(I).list_line_id is null
       or  p_x_line_adj_tbl(I).list_line_id = FND_API.G_MISS_NUM)
     then
      list_line_id( p_modifier_name  => p_x_line_adj_val_tbl(I).list_name,
                    p_list_line_no   => p_x_line_adj_tbl(I).list_line_no,
                    p_version_no     => p_x_line_adj_val_tbl(I).version_no,
                    p_list_line_type_code =>p_x_line_adj_tbl(I).list_line_type_code,
                    p_return_status  => l_return_status,
                    x_list_header_id => l_list_header_id,
                    x_list_line_id   => l_list_line_id,
                    x_list_line_no  =>l_list_line_no,
                     x_type         => l_type);

      IF l_type NOT IN ('DIS','FREIGHT_CHARGE','PROMOLINE','COUPON','PROMO','SUR') THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OEXVIMSB.PLS -> NOT A VALID DISCOUNT/COUPON TYPE ( LINE ) ' ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NOT VALID PROMOTION NAME =' ||P_X_HEADER_ADJ_VAL_TBL ( I ) .LIST_NAME ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_INVALID_LIST_NAME');
         FND_MESSAGE.SET_TOKEN('LIST_NAME',p_x_line_adj_val_tbl(I).list_name);
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF  p_return_status NOT IN (FND_API.G_RET_STS_ERROR)
          AND l_return_status     IN (FND_API.G_RET_STS_ERROR,
		          FND_API.G_RET_STS_UNEXP_ERROR)
      THEN
          p_return_status := l_return_status;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LIST_LINE_TYPE_CODE = '||L_TYPE ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LIST HEADER ID = '||L_LIST_HEADER_ID ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LIST LINE ID = '||L_LIST_LINE_ID ) ;
      END IF;
      IF l_type In ('DIS','SUR') THEN
         p_x_line_adj_tbl(I).list_header_id :=l_list_header_id;
         p_x_line_adj_tbl(I).list_line_id :=l_list_line_id;
      END IF;

      IF l_type='FREIGHT_CHARGE' THEN
         p_x_line_adj_tbl(I).list_header_id :=l_list_header_id;
         p_x_line_adj_tbl(I).list_line_id :=l_list_line_id;
      END IF;

      IF l_type='PROMOLINE' THEN
       l_line_price_att_tbl(I).pricing_context :='MODLIST';
       l_line_price_att_tbl(I).flex_title      :='QP_ATTR_DEFNS_QUALIFIER';
       l_line_price_att_tbl(I).Orig_Sys_Atts_Ref :=p_x_line_adj_tbl(I).Orig_Sys_Discount_Ref;
       l_line_price_att_tbl(I).pricing_attribute1 := l_list_header_id;
       l_line_price_att_tbl(I).pricing_attribute2 :=l_list_line_id;
       l_line_price_att_tbl(I).operation := p_x_line_adj_tbl(I).Operation;
       l_line_price_att_tbl(I).line_index := p_x_line_adj_tbl(I).line_index;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LINE_INDEX = '||L_LINE_PRICE_ATT_TBL ( I ) .LINE_INDEX ) ;
       END IF;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LINE_PRICE OPERATION = '||L_LINE_PRICE_ATT_TBL ( I ) .OPERATION ) ;
       END IF;
       p_x_line_adj_tbl.delete (I);
       p_x_line_adj_val_tbl.DELETE (I);
      END IF;
      IF l_type = 'COUPON' THEN
       l_line_price_att_tbl(I).pricing_context :='MODLIST';
       l_line_price_att_tbl(I).flex_title      :='QP_ATTR_DEFNS_QUALIFIER';
       l_line_price_att_tbl(I).pricing_attribute3 :=l_list_line_id;
       l_line_price_att_tbl(I).Orig_Sys_Atts_Ref :=p_x_line_adj_tbl(I).Orig_Sys_Discount_Ref;
       l_line_price_att_tbl(I).operation := p_x_line_adj_tbl(I).Operation;
       l_line_price_att_tbl(I).line_index := p_x_line_adj_tbl(I).line_index;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LINE_INDEX = '||L_LINE_PRICE_ATT_TBL ( I ) .LINE_INDEX ) ;
       END IF;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LINE_PRICE OPERATION = '||L_LINE_PRICE_ATT_TBL ( I ) .OPERATION ) ;
       END IF;
       p_x_line_adj_tbl.delete (I);
       p_x_line_adj_val_tbl.DELETE (I);
      END IF;

      IF l_type='PROMO' THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'IN LINE PROMO' ) ;
       END IF;
       l_line_price_att_tbl(I).pricing_context :='MODLIST';
       l_line_price_att_tbl(I).flex_title    :='QP_ATTR_DEFNS_QUALIFIER';
       l_line_price_att_tbl(I).pricing_attribute1 := l_list_header_id;
       l_line_price_att_tbl(I).Orig_Sys_Atts_Ref :=p_x_line_adj_tbl(I).Orig_Sys_Discount_Ref;
       l_line_price_att_tbl(I).operation := p_x_line_adj_tbl(I).Operation;
       l_line_price_att_tbl(I).line_index := p_x_line_adj_tbl(I).line_index;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LINE_INDEX = '||L_LINE_PRICE_ATT_TBL ( I ) .LINE_INDEX ) ;
       END IF;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LINE_PRICE OPERATION = '||L_LINE_PRICE_ATT_TBL ( I ) .OPERATION ) ;
       END IF;
       p_x_line_adj_tbl.delete (I);
       p_x_line_adj_val_tbl.DELETE (I);
      END IF;
   end if;
-- } end if

   END LOOP;

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'P_X_LINE_PRICE_ATT_TBL.COUNT: '||TO_CHAR ( P_X_LINE_PRICE_ATT_TBL.COUNT ) , 1 ) ;
END IF;
   FOR I in 1..p_x_line_price_att_tbl.count
   LOOP
/* -----------------------------------------------------------
      Set message context for line atts
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT FOR LINE ATTS' ) ;
      END IF;

      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'LINE_PATTS'
--        ,p_entity_ref                 => p_x_line_price_att_tbl(I).orig_sys_atts_ref
        ,p_entity_id                  => p_x_line_price_att_tbl(I).order_price_attrib_id
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => p_x_line_tbl(p_x_line_price_att_tbl(I).line_index).line_id
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => p_x_line_tbl(p_x_line_price_att_tbl(I).line_index).orig_sys_line_ref
        ,p_orig_sys_shipment_ref      => p_x_line_tbl(p_x_line_price_att_tbl(I).line_index).orig_sys_shipment_ref
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

/* -----------------------------------------------------------
      Validate orig sys documentt ref for line
   -----------------------------------------------------------

      oe_debug_pub.add('before validating orig_sys_atts_ref for line');

      IF p_x_line_price_att_tbl(I).orig_sys_atts_ref = FND_API.G_MISS_CHAR
      THEN
	 oe_debug_pub.add('Invalid orig_sys_attribute_ref for line... ');
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_ORIG_SYS_ATT_REF');
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

 -----------------------------------------------------------
      Validate line atts operation code
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING LINE ATTS OPERATION CODE' ) ;
      END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' OPERATION CODE IS :'||P_X_LINE_PRICE_ATT_TBL ( I ) .OPERATION , 1 ) ;
    END IF;
      IF p_x_line_price_att_tbl(I).operation NOT IN ('INSERT','CREATE',
                                             'UPDATE','DELETE') OR
        (p_x_line_tbl(p_x_line_price_att_tbl(I).line_index).operation
                                         IN ('INSERT','CREATE') AND
         p_x_line_price_att_tbl(I).operation NOT IN ('INSERT','CREATE')) OR
        (p_x_line_tbl(p_x_line_price_att_tbl(I).line_index).operation
                                         IN ('UPDATE') AND
         p_x_line_price_att_tbl(I).operation NOT IN ('INSERT','CREATE','UPDATE','DELETE')) OR
        (p_x_line_tbl(p_x_line_price_att_tbl(I).line_index).operation
                                         IN ('DELETE') AND
         p_x_line_price_att_tbl(I).operation NOT IN ('DELETE'))

      THEN
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'INVALID LINE ADJUSTMENTS OPERATION CODE...' ) ;
	   END IF;
	   FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
        OE_MSG_PUB.Add;
	   p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF  p_x_line_price_att_tbl(I).operation IN ('INSERT', 'CREATE')
      AND p_x_header_rec.operation = 'UPDATE'
      AND p_x_line_tbl(p_x_line_price_att_tbl(I).line_index).operation = 'UPDATE'
      THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NEW ATT FOR THE LINE LEVEL , EXISITNG HEARDER_ID:' || P_X_HEADER_REC.HEADER_ID ) ;
         END IF;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'NEW ATT P_X_LINE_PRICE_ATT_TBL:'||TO_CHAR ( P_X_LINE_PRICE_ATT_TBL ( I ) .ORDER_PRICE_ATTRIB_ID ) , 1 ) ;
END IF;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'LINEID :' ||TO_CHAR ( P_X_LINE_TBL ( P_X_LINE_PRICE_ATT_TBL ( I ) .LINE_INDEX ) .LINE_ID ) , 1 ) ;
END IF;
         p_x_line_price_att_tbl(I).header_id    := p_x_header_rec.header_id; --l_header_id;
         p_x_line_price_att_tbl(I).line_id      := p_x_line_tbl(p_x_line_price_att_tbl(I).line_index).line_id;         --l_line_id;
      Begin

         SELECT 1 into l_count
           FROM oe_order_price_attribs
          WHERE header_id              = p_x_header_rec.header_id
            AND line_id                = l_line_id
            AND orig_sys_atts_ref  =
                p_x_line_price_att_tbl(I).orig_sys_atts_ref
            AND rownum                < 2;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO INSERT A NEW HDRATT WITH THE SAME HEADER_ID AND ATTRIBUTE ID....' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      Exception
        When no_data_found then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'VALID LINE LEVEL PRICE ATT FOR INSERT' ) ;
          END IF;
        When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OTHERS EXCEPTION WHEN INSERTING NEW HDR PRICE ATT... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      End;
      End If; -- Insert, Create operation

      IF  p_x_line_price_att_tbl(I).operation IN ('UPDATE','DELETE')
      AND p_x_header_rec.operation IN ('UPDATE','DELETE')
      AND p_x_line_tbl(p_x_line_price_att_tbl(I).line_index).operation IN ('UPDATE','DELETE')
      THEN
      Begin
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'HEADER ID: '||TO_CHAR ( P_X_HEADER_REC.HEADER_ID ) ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'LINE ID: '|| L_LINE_ID ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ATTRIBUTE REF: '||P_X_LINE_PRICE_ATT_TBL ( I ) .ORIG_SYS_ATTS_REF ) ;
         END IF;
         p_x_line_price_att_tbl(I).header_id    := l_header_id;
         p_x_line_price_att_tbl(I).line_id      := l_line_id;

         SELECT order_price_attrib_id
           INTO l_price_attrib_id
           FROM oe_order_price_attribs
          WHERE header_id             = l_header_id
            AND line_id               = l_line_id
            AND orig_sys_atts_ref  =
                p_x_line_price_att_tbl(I).orig_sys_atts_ref;

         p_x_line_price_att_tbl(I).order_price_attrib_id := l_price_attrib_id;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'HEADER ID: '||TO_CHAR ( P_X_LINE_PRICE_ATT_TBL ( I ) .HEADER_ID ) ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ATTRIBUTE ID: '||TO_CHAR ( P_X_LINE_PRICE_ATT_TBL ( I ) .ORDER_PRICE_ATTRIB_ID ) ) ;
         END IF;

      Exception
        When no_data_found then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO UPDATE OR DELETE AN EXISTING HDR ATT BUT THAT DOES NOT EXIST... ' ) ;
          END IF;
          FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
          OE_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
        When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OTHERS EXCEPTION WHEN TRYING TO UPDATE OR DELETE AN EXISTING HDRATT ... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      End;
      End IF; -- Update and Delete operation

   END LOOP;

l_last_index :=p_x_line_price_att_tbl.LAST;
IF l_last_index IS NULL THEN
  l_last_index := 0;
END IF;

    FOR I IN 1..l_line_price_att_tbl.COUNT
    LOOP
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'IN LINE PRICE_REC_TBL LOOP' ) ;
     END IF;
     l_last_index := l_last_index+1;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'L_LAST_INDEX = '||L_LAST_INDEX ) ;
     END IF;
     p_x_line_price_att_tbl(l_last_index).pricing_attribute1 := l_line_price_att_tbl(I).pricing_attribute1;
     p_x_line_price_att_tbl(l_last_index).pricing_attribute3 :=l_line_price_att_tbl(I).pricing_attribute3;
     p_x_line_price_att_tbl(l_last_index).pricing_attribute2 :=l_line_price_att_tbl(I).pricing_attribute2;
     p_x_line_price_att_tbl(l_last_index).flex_title := l_line_price_att_tbl(I).flex_title;
     p_x_line_price_att_tbl(l_last_index).pricing_context :=l_line_price_att_tbl(I).pricing_context;
     p_x_line_price_att_tbl(l_last_index).Orig_Sys_Atts_Ref :=l_line_price_att_tbl(I).Orig_Sys_Atts_Ref;
     p_x_line_price_att_tbl(l_last_index).Operation := l_line_price_att_tbl(I).operation;
     p_x_line_price_att_tbl(l_last_index).line_index := l_line_price_att_tbl(I).line_index;
    END LOOP;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RECORDS IN LINE PRICE ATTL TBL = '||P_X_LINE_PRICE_ATT_TBL.COUNT ) ;
    END IF;


   FOR I in 1..p_x_line_scredit_tbl.count
   LOOP
/* -----------------------------------------------------------
      Set message context for line sales credits
   -----------------------------------------------------------
*/
      l_sales_credit_id := NULL;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT FOR LINE SALES CREDITS' ) ;
      END IF;

      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'LINE_SCREDIT'
        ,p_entity_ref                 => p_x_line_scredit_tbl(I).orig_sys_credit_ref
        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => p_x_line_tbl(p_x_line_scredit_tbl(I).line_index).line_id
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => p_x_line_tbl(p_x_line_scredit_tbl(I).line_index).orig_sys_line_ref
        ,p_orig_sys_shipment_ref      => p_x_line_tbl(p_x_line_scredit_tbl(I).line_index).orig_sys_shipment_ref
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

/* -----------------------------------------------------------
      Validate orig sys credit ref for line
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING ORIG_SYS_CREDIT_REF FOR LINE' ) ;
      END IF;

      IF p_x_line_scredit_tbl(I).orig_sys_credit_ref = FND_API.G_MISS_CHAR
      THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVALID ORIG_SYS_CREDIT_REF FOR LINE... ' ) ;
         END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_ORIG_SYS_CREDIT_REF');
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

/* -----------------------------------------------------------
      Validate line sales credits operation code
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING LINE SALES CREDITS OPERATION CODE' ) ;
      END IF;

      IF p_x_line_scredit_tbl(I).operation NOT IN ('INSERT','CREATE',
				                 'UPDATE','DELETE') OR
        (p_x_line_tbl(p_x_line_scredit_tbl(I).line_index).operation
					     IN ('INSERT','CREATE') AND
         p_x_line_scredit_tbl(I).operation NOT IN ('INSERT','CREATE')) OR
        (p_x_line_tbl(p_x_line_scredit_tbl(I).line_index).operation
					     IN ('UPDATE') AND
         p_x_line_scredit_tbl(I).operation NOT IN ('INSERT','CREATE','UPDATE','DELETE')) OR
        (p_x_line_tbl(p_x_line_scredit_tbl(I).line_index).operation
					     IN ('DELETE') AND
         p_x_line_scredit_tbl(I).operation NOT IN ('DELETE'))
      THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'INVALID LINE SALES CREDITS OPERATION CODE...' ) ;
	 END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

-- aksingh start on this (10/11/2000) this is in process of being coded
      IF  p_x_line_scredit_tbl(I).operation IN ('INSERT', 'CREATE')
      AND p_x_header_rec.operation = 'UPDATE'
      AND p_x_line_tbl(p_x_line_scredit_tbl(I).line_index).operation
					          = 'UPDATE'
      THEN
      Begin
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NEW ADJUSTMENT FOR LINE LEVEL , THE EXISITNG HEARDER_ID:' || TO_CHAR ( P_X_HEADER_REC.HEADER_ID ) ) ;
         END IF;
         p_x_line_scredit_tbl(I).header_id  := l_header_id;
         p_x_line_scredit_tbl(I).line_id    := l_line_id;

         SELECT 1 into l_count
           FROM oe_sales_credits
          WHERE header_id              = p_x_header_rec.header_id
            AND line_id                = l_line_id
            AND orig_sys_credit_ref  =
                       p_x_line_scredit_tbl(I).orig_sys_credit_ref
            AND rownum                < 2;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO INSERT A NEW LNSCREDIT WITH THE SAME HEADER_ID , LINE_ID AND ORIG_SYS_CREDIT_REF... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      Exception
        When no_data_found then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'VALID LINE LEVEL SALES CREDIT FOR INSERT' ) ;
          END IF;
        When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OTHERS EXCEPTION WHEN INSERTING NEW LINE SALES CREDIT... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      End;
      END IF; -- Insert, Update Operation

      IF  p_x_line_scredit_tbl(I).operation IN ('UPDATE','DELETE')
      AND p_x_header_rec.operation IN ('UPDATE','DELETE')
      AND p_x_line_tbl(p_x_line_scredit_tbl(I).line_index).operation IN ('UPDATE','DELETE')
      THEN
      Begin
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'HEADER ID: '||TO_CHAR ( P_X_HEADER_REC.HEADER_ID ) ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'LINE ID: '|| L_LINE_ID ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'CREDIT REF: '||P_X_LINE_SCREDIT_TBL ( I ) .ORIG_SYS_CREDIT_REF ) ;
         END IF;
         p_x_line_scredit_tbl(I).header_id  := l_header_id;
         p_x_line_scredit_tbl(I).line_id    := l_line_id;
         SELECT sales_credit_id
           INTO l_sales_credit_id
           FROM oe_sales_credits
          WHERE header_id             = p_x_header_rec.header_id
            AND line_id               = l_line_id
            AND orig_sys_credit_ref =
                p_x_line_scredit_tbl(I).orig_sys_credit_ref;

         p_x_line_scredit_tbl(I).sales_credit_id := l_sales_credit_id;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'HEADER ID: '||TO_CHAR ( P_X_LINE_SCREDIT_TBL ( I ) .HEADER_ID ) ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ADJUST ID: '||TO_CHAR ( P_X_LINE_SCREDIT_TBL ( I ) .SALES_CREDIT_ID ) ) ;
         END IF;

      Exception
        When no_data_found then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO UPDATE OR DELETE AN EXISTING LINE CREDIT BUT THAT DOES NOT EXIST... ' ) ;
          END IF;
          FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
          OE_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
        When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OTHERS EXCEPTION WHEN TRYING TO UPDATE OR DELETE AN EXISTING LINECRDT ... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      End;
      End IF; -- Update and Delete operation


   END LOOP;

-- multiple payment starts..

   FOR I in 1..p_x_line_payment_tbl.count
   LOOP
/* -----------------------------------------------------------
      Set message context for line PAYMENTs
   -----------------------------------------------------------
*/
--      l_sales_payment_id := NULL;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT FOR LINE PAYMENTS' ) ;
      END IF;

      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'LINE_PAYMENT'
        ,p_entity_ref                 => p_x_line_payment_tbl(I).orig_sys_payment_ref
        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => p_x_line_tbl(p_x_line_payment_tbl(I).line_index).line_id
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => p_x_line_tbl(p_x_line_payment_tbl(I).line_index).orig_sys_line_ref
        ,p_orig_sys_shipment_ref      => p_x_line_tbl(p_x_line_payment_tbl(I).line_index).orig_sys_shipment_ref
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

/* -----------------------------------------------------------
      Validate orig sys payment ref for line
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING ORIG_SYS_PAYMENT_REF FOR LINE' ) ;
      END IF;

      IF p_x_line_payment_tbl(I).orig_sys_payment_ref = FND_API.G_MISS_CHAR
      THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVALID ORIG_SYS_PAYMENT_REF FOR LINE... ' ) ;
         END IF;
         /* multiple payments: new message */
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_ORIG_SYS_payment_REF');
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

/* -----------------------------------------------------------
      Validate line PAYMENTs operation code
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING LINE PAYMENTS OPERATION CODE' ) ;
      END IF;

      IF p_x_line_payment_tbl(I).operation NOT IN ('INSERT','CREATE',
				                 'UPDATE','DELETE') OR
        (p_x_line_tbl(p_x_line_payment_tbl(I).line_index).operation
					     IN ('INSERT','CREATE') AND
         p_x_line_payment_tbl(I).operation NOT IN ('INSERT','CREATE')) OR
        (p_x_line_tbl(p_x_line_payment_tbl(I).line_index).operation
					     IN ('UPDATE') AND
         p_x_line_payment_tbl(I).operation NOT IN ('INSERT','CREATE','UPDATE','DELETE')) OR
        (p_x_line_tbl(p_x_line_payment_tbl(I).line_index).operation
					     IN ('DELETE') AND
         p_x_line_payment_tbl(I).operation NOT IN ('DELETE'))
      THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'INVALID LINE PAYMENTS OPERATION CODE...' ) ;
	 END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF  p_x_line_payment_tbl(I).operation IN ('INSERT', 'CREATE')
      AND p_x_header_rec.operation = 'UPDATE'
      AND p_x_line_tbl(p_x_line_payment_tbl(I).line_index).operation
					          = 'UPDATE'
      THEN
      Begin
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NEW PAYMENT FOR LINE LEVEL , THE EXISITNG HEARDER_ID:' || TO_CHAR ( P_X_HEADER_REC.HEADER_ID ) ) ;
         END IF;
         p_x_line_payment_tbl(I).header_id  := l_header_id;
         p_x_line_payment_tbl(I).line_id    := l_line_id;

         SELECT 1 into l_count
           FROM oe_payments
          WHERE header_id              = p_x_header_rec.header_id
            AND line_id                = l_line_id
            AND orig_sys_payment_ref  =
                       p_x_line_payment_tbl(I).orig_sys_payment_ref
            AND rownum                < 2;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO INSERT A NEW LINE PAYMENT WITH THE SAME HEADER_ID , LINE_ID AND ORIG_SYS_PAYMENT_REF... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      Exception
        When no_data_found then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'VALID LINE LEVEL PAYMENT FOR INSERT' ) ;
          END IF;
        When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OTHERS EXCEPTION WHEN INSERTING NEW LINE PAYMENT... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      End;
      END IF; -- Insert, Update Operation

      IF  p_x_line_payment_tbl(I).operation IN ('UPDATE','DELETE')
      AND p_x_header_rec.operation IN ('UPDATE','DELETE')
      AND p_x_line_tbl(p_x_line_payment_tbl(I).line_index).operation IN ('UPDATE','DELETE')
      THEN
      Begin
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'HEADER ID: '||TO_CHAR ( P_X_HEADER_REC.HEADER_ID ) ) ;
             oe_debug_pub.add(  'LINE ID: '|| L_LINE_ID ) ;
             oe_debug_pub.add(  'PAYMENT REF: '||P_X_LINE_PAYMENT_TBL ( I ) .ORIG_SYS_PAYMENT_REF ) ;
         END IF;
         p_x_line_payment_tbl(I).header_id  := l_header_id;
         p_x_line_payment_tbl(I).line_id    := l_line_id;
         SELECT 1
           INTO l_count
           FROM oe_payments
          WHERE header_id             = p_x_header_rec.header_id
            AND line_id               = l_line_id
            AND orig_sys_payment_ref =
                p_x_line_payment_tbl(I).orig_sys_payment_ref;

      Exception
        When no_data_found then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO UPDATE OR DELETE AN EXISTING LINE PAYMENT BUT THAT DOES NOT EXIST... ' ) ;
          END IF;
          FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
          OE_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
        When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OTHERS EXCEPTION WHEN TRYING TO UPDATE OR DELETE AN EXISTING PAYMENT ... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      End;
      End IF; -- Update and Delete operation

   END LOOP; -- multiple payments for line.

   FOR I in 1..p_x_lot_serial_tbl.count
   LOOP
/* -----------------------------------------------------------
      Set message context for line lot serials
   -----------------------------------------------------------
*/
      l_lot_serial_id := NULL;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT FOR LINE LOT SERIALS' ) ;
      END IF;

      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'LOT_SERIAL'
        ,p_entity_ref                 => p_x_lot_serial_tbl(I).orig_sys_lotserial_ref
        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => p_x_line_tbl(p_x_lot_serial_tbl(I).line_index).line_id
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => p_x_line_tbl(p_x_lot_serial_tbl(I).line_index).orig_sys_line_ref
        ,p_orig_sys_shipment_ref      => p_x_line_tbl(p_x_lot_serial_tbl(I).line_index).orig_sys_shipment_ref
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

/* -----------------------------------------------------------
      Validate orig sys lotserial ref for line
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING ORIG_SYS_LOTSERIAL_REF FOR LINE' ) ;
      END IF;

      IF p_x_lot_serial_tbl(I).orig_sys_lotserial_ref = FND_API.G_MISS_CHAR
      THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVALID ORIG_SYS_LOTSERIAL_REF... ' ) ;
         END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_ORIG_SYS_LOTSERIAL_REF');
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

/* -----------------------------------------------------------
      Validate line lot serials operation code
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING LINE LOT SERIALS OPERATION CODE' ) ;
      END IF;

      IF p_x_lot_serial_tbl(I).operation NOT IN ('INSERT','CREATE',
			                       'UPDATE','DELETE') OR
        (p_x_line_tbl(p_x_lot_serial_tbl(I).line_index).operation
					   IN ('INSERT','CREATE') AND
         p_x_lot_serial_tbl(I).operation NOT IN ('INSERT','CREATE'))
      THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'INVALID LINE LOT SERIALS OPERATION CODE...' ) ;
	 END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

-- aksingh start on this (10/11/2000) this is in process of being coded
      IF  p_x_lot_serial_tbl(I).operation IN ('INSERT', 'CREATE')
      AND p_x_line_tbl(p_x_lot_serial_tbl(I).line_index).operation = 'UPDATE'
      THEN
      Begin
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NEW LOT FOR LINE LEVEL , THE EXISITNG LINE_ID:' || L_LINE_ID ) ;
         END IF;
         p_x_lot_serial_tbl(I).line_id    := l_line_id;

         SELECT 1 into l_count
           FROM oe_lot_serial_numbers
          WHERE line_id                = l_line_id
            AND orig_sys_lotserial_ref  =
                       p_x_lot_serial_tbl(I).orig_sys_lotserial_ref
            AND rownum                < 2;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO INSERT A NEW LOT WITH THE SAME LINE_ID AND ORIG_SYS_DISCOUNT_REF... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      Exception
        When no_data_found then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'VALID LINE LEVEL LOT FOR INSERT' ) ;
          END IF;
        When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OTHERS EXCEPTION WHEN INSERTING NEW LINE LOT... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      End;
      END IF; -- Insert, Create Opearation

      IF  p_x_lot_serial_tbl(I).operation IN ('UPDATE','DELETE')
      AND p_x_line_tbl(p_x_lot_serial_tbl(I).line_index).operation IN ('UPDATE','DELETE')
      THEN
      Begin
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'LINE ID: '|| L_LINE_ID ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'LOT REF: '||P_X_LOT_SERIAL_TBL ( I ) .ORIG_SYS_LOTSERIAL_REF ) ;
         END IF;
         p_x_lot_serial_tbl(I).line_id    := l_line_id;
         SELECT lot_serial_id
           INTO l_lot_serial_id
           FROM oe_lot_serial_numbers
          WHERE line_id               = l_line_id
            AND orig_sys_lotserial_ref =
                p_x_lot_serial_tbl(I).orig_sys_lotserial_ref;

         p_x_lot_serial_tbl(I).lot_serial_id := l_lot_serial_id;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'LOT ID: '||TO_CHAR ( P_X_LOT_SERIAL_TBL ( I ) .LOT_SERIAL_ID ) ) ;
         END IF;

      Exception
        When no_data_found then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INVALID OPERATION CODE. TRYING TO UPDATE OR DELETE AN EXISTING LOT BUT THAT DOES NOT EXIST... ' ) ;
          END IF;
          FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
          OE_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
        When others then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OTHERS EXCEPTION WHEN TRYING TO UPDATE OR DELETE AN EXISTING LOT... ' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      End;
      End IF; -- Update and Delete operation

-- aksingh(10/11/2000) this is in process of being coded upto this point

   END LOOP;


   FOR I in 1..p_x_reservation_tbl.count
   LOOP
/* -----------------------------------------------------------
      Set message context for line reservations
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT FOR LINE RESERVATIONS' ) ;
      END IF;

      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'RESERVATION'
        ,p_entity_ref                 => p_x_reservation_tbl(I).orig_sys_reservation_ref
        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => p_x_line_tbl(p_x_reservation_tbl(I).line_index).line_id
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => p_x_line_tbl(p_x_reservation_tbl(I).line_index).orig_sys_line_ref
        ,p_orig_sys_shipment_ref      => p_x_line_tbl(p_x_reservation_tbl(I).line_index).orig_sys_shipment_ref
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

/* -----------------------------------------------------------
      Validate orig sys reservation ref for line
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING ORIG_SYS_RESERVATION_REF FOR LINE' ) ;
      END IF;

      IF p_x_reservation_tbl(I).orig_sys_reservation_ref = FND_API.G_MISS_CHAR
      THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVALID ORIG_SYS_RESERVATION_REF... ' ) ;
         END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_ORIG_SYS_RESERVATION_REF');
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

/* -----------------------------------------------------------
      Validate reservation details for line
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING RESERVATION DETAILS FOR LINE' ) ;
      END IF;

      IF  p_x_reservation_tbl(I).revision              = FND_API.G_MISS_CHAR
      AND p_x_reservation_tbl(I).lot_number_id         = FND_API.G_MISS_NUM
      AND p_x_reservation_val_tbl(I).lot_number        = FND_API.G_MISS_CHAR
      AND p_x_reservation_tbl(I).subinventory_id       = FND_API.G_MISS_NUM
      AND p_x_reservation_val_tbl(I).subinventory_code = FND_API.G_MISS_CHAR
      AND p_x_reservation_tbl(I).locator_id            = FND_API.G_MISS_NUM
      THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVALID RESERVATION DETAILS... ' ) ;
         END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_RESERVATION_DETAILS');
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

/* -----------------------------------------------------------
      Validate reservation quantity
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING RESERVATION QUANTITY FOR LINE' ) ;
      END IF;

      IF p_x_reservation_tbl(I).quantity = FND_API.G_MISS_NUM OR
         p_x_reservation_tbl(I).quantity = 0 		    OR
         p_x_reservation_tbl(I).quantity < 0
      THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVALID RESERVATION QUANTITY... ' ) ;
         END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_RESERVATION_QUANTITY');
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

/* -----------------------------------------------------------
      Validate reservation operation
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE VALIDATING RESERVATION OPERATION FOR LINE' ) ;
      END IF;

      IF p_x_reservation_tbl(I).operation NOT IN ('INSERT','CREATE',
						'UPDATE','DELETE')
      THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVALID RESERVATION OPERATION... ' ) ;
         END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
         OE_MSG_PUB.Add;
	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

--    Following Line are added to fixed the bug for the duplicate reservation
--    when the auto scheduling is on + within time fence
--    bug# 1537689
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LINE SUNINV: ' || P_X_LINE_TBL ( P_X_RESERVATION_TBL ( I ) .LINE_INDEX ) .SUBINVENTORY ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RESV_REC SUNINV: ' || P_X_RESERVATION_VAL_TBL ( I ) .SUBINVENTORY_CODE ) ;
      END IF;
/*commenting code for bug 1765449
      p_x_line_tbl(p_x_reservation_tbl(I).line_index).subinventory
                     := p_x_reservation_val_tbl(I).subinventory_code;
      oe_debug_pub.add('Line Suninv: ' || p_x_line_tbl(p_x_reservation_tbl(I).line_index).subinventory);
*/
--    end change for bug# 1537689

   END LOOP;


/* -----------------------------------------------------------
   Call Configurations Pre-Processing
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE CALLING CONFIGURATIONS PRE-PROCESSING' ) ;
      END IF;

      OE_ORDER_IMPORT_CONFIG_PVT.Pre_Process(
         p_header_rec                   => p_x_header_rec
        ,p_x_line_tbl                     => p_x_line_tbl
        ,p_return_status                => l_return_status
        );

      IF  p_return_status NOT IN (FND_API.G_RET_STS_ERROR)
      AND l_return_status     IN (FND_API.G_RET_STS_ERROR,
			          FND_API.G_RET_STS_UNEXP_ERROR)
      THEN
          p_return_status := l_return_status;
      END IF;


/* -----------------------------------------------------------
   Call EDI Pre-Process
   -----------------------------------------------------------
*/
   IF p_x_header_rec.order_source_id = OE_Globals.G_ORDER_SOURCE_EDI
   THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE CALLING EDI PRE-PROCESS' ) ;
      END IF;

      OE_EDI_PVT.Pre_Process(
         p_header_rec                   => p_x_header_rec
        ,p_header_adj_tbl               => p_x_header_adj_tbl
        ,p_header_scredit_tbl           => p_x_header_scredit_tbl
        ,p_line_tbl                     => p_x_line_tbl
        ,p_line_adj_tbl                 => p_x_line_adj_tbl
        ,p_line_scredit_tbl             => p_x_line_scredit_tbl
        ,p_lot_serial_tbl               => p_x_lot_serial_tbl

        ,p_header_val_rec               => p_x_header_val_rec
        ,p_header_adj_val_tbl           => p_x_header_adj_val_tbl
        ,p_header_scredit_val_tbl       => p_x_header_scredit_val_tbl
        ,p_line_val_tbl                 => p_x_line_val_tbl
        ,p_line_adj_val_tbl             => p_x_line_adj_val_tbl
        ,p_line_scredit_val_tbl         => p_x_line_scredit_val_tbl
        ,p_lot_serial_val_tbl           => p_x_lot_serial_val_tbl

        ,p_return_status                => l_return_status
        );

      IF  p_return_status NOT IN (FND_API.G_RET_STS_ERROR)
      AND l_return_status     IN (FND_API.G_RET_STS_ERROR,
			          FND_API.G_RET_STS_UNEXP_ERROR)
      THEN
            p_return_status := l_return_status;
      END IF;

   END IF;

  EXCEPTION
   WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
      END IF;
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Pre_Process');
      END IF;

END PRE_PROCESS;


/* -----------------------------------------------------------
   Procedure: Post_Process
   -----------------------------------------------------------
*/
PROCEDURE Post_Process(
   p_x_header_rec                 IN OUT NOCOPY OE_Order_Pub.Header_Rec_Type
  ,p_x_header_adj_tbl             IN OUT NOCOPY OE_Order_Pub.Header_Adj_Tbl_Type
  ,p_x_header_price_att_tbl       IN OUT NOCOPY OE_Order_Pub.Header_Price_Att_Tbl_Type
  ,p_x_header_adj_att_tbl         IN OUT NOCOPY OE_Order_Pub.Header_Adj_Att_Tbl_Type
  ,p_x_header_adj_assoc_tbl      IN OUT NOCOPY OE_Order_Pub.Header_Adj_Assoc_Tbl_Type
  ,p_x_header_scredit_tbl         IN OUT NOCOPY OE_Order_Pub.Header_Scredit_Tbl_Type
  ,p_x_line_tbl			IN OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
  ,p_x_line_adj_tbl		IN OUT NOCOPY OE_Order_Pub.Line_Adj_Tbl_Type
  ,p_x_line_price_att_tbl         IN OUT NOCOPY OE_Order_Pub.Line_Price_Att_Tbl_Type
  ,p_x_line_adj_att_tbl           IN OUT NOCOPY OE_Order_Pub.Line_Adj_Att_Tbl_Type
  ,p_x_line_adj_assoc_tbl         IN OUT NOCOPY OE_Order_Pub.Line_Adj_Assoc_Tbl_Type
  ,p_x_line_scredit_tbl           IN OUT NOCOPY OE_Order_Pub.Line_Scredit_Tbl_Type
  ,p_x_lot_serial_tbl             IN OUT NOCOPY OE_Order_Pub.Lot_Serial_Tbl_Type

  ,p_x_header_val_rec             IN OUT NOCOPY OE_Order_Pub.Header_Val_Rec_Type
  ,p_x_header_adj_val_tbl         IN OUT NOCOPY OE_Order_Pub.Header_Adj_Val_Tbl_Type
  ,p_x_header_scredit_val_tbl     IN OUT NOCOPY OE_Order_Pub.Header_Scredit_Val_Tbl_Type
  ,p_x_line_val_tbl               IN OUT NOCOPY OE_Order_Pub.Line_Val_Tbl_Type
  ,p_x_line_adj_val_tbl           IN OUT NOCOPY OE_Order_Pub.Line_Adj_Val_Tbl_Type
  ,p_x_line_scredit_val_tbl       IN OUT NOCOPY OE_Order_Pub.Line_Scredit_Val_Tbl_Type
  ,p_x_lot_serial_val_tbl         IN OUT NOCOPY OE_Order_Pub.Lot_Serial_Val_Tbl_Type

  ,p_x_header_rec_old             IN OUT NOCOPY OE_Order_Pub.Header_Rec_Type
  ,p_x_header_adj_tbl_old         IN OUT NOCOPY OE_Order_Pub.Header_Adj_Tbl_Type
  ,p_x_header_scredit_tbl_old     IN OUT NOCOPY OE_Order_Pub.Header_Scredit_Tbl_Type
  ,p_x_line_tbl_old		IN OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
  ,p_x_line_adj_tbl_old		IN OUT NOCOPY OE_Order_Pub.Line_Adj_Tbl_Type
  ,p_x_line_price_att_tbl_old     IN OUT NOCOPY OE_Order_Pub.Line_Price_Att_Tbl_Type
  ,p_x_line_scredit_tbl_old       IN OUT NOCOPY OE_Order_Pub.Line_Scredit_Tbl_Type
  ,p_x_lot_serial_tbl_old         IN OUT NOCOPY OE_Order_Pub.Lot_Serial_Tbl_Type

  ,p_x_header_val_rec_old         IN OUT NOCOPY OE_Order_Pub.Header_Val_Rec_Type
  ,p_x_header_adj_val_tbl_old     IN OUT NOCOPY OE_Order_Pub.Header_Adj_Val_Tbl_Type
  ,p_x_header_scredit_val_tbl_old IN OUT NOCOPY OE_Order_Pub.Header_Scredit_Val_Tbl_Type
  ,p_x_line_val_tbl_old           IN OUT NOCOPY OE_Order_Pub.Line_Val_Tbl_Type
  ,p_x_line_adj_val_tbl_old       IN OUT NOCOPY OE_Order_Pub.Line_Adj_Val_Tbl_Type
  ,p_x_line_scredit_val_tbl_old   IN OUT NOCOPY OE_Order_Pub.Line_Scredit_Val_Tbl_Type
  ,p_x_lot_serial_val_tbl_old     IN OUT NOCOPY OE_Order_Pub.Lot_Serial_Val_Tbl_Type

  ,p_x_reservation_tbl     	IN OUT NOCOPY OE_Order_Pub.Reservation_Tbl_Type
  ,p_x_reservation_val_tbl     	IN OUT NOCOPY OE_Order_Pub.Reservation_Val_Tbl_Type

,p_return_status OUT NOCOPY VARCHAR2

) IS
   l_return_status		       VARCHAR2(1);
/* Added the following variable to fix the bug 2355630 */
   l_unit_selling_price   NUMBER;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
/* Added for bug 2734389 */
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);
l_failed_rsv_temp_tbl INV_RESERVATION_GLOBAL.mtl_failed_rsv_tbl_type;
/* finish 2734389 */

BEGIN

/* -----------------------------------------------------------
   Initialize return status
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE INITIALIZING RETURN_STATUS' ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING ORDER IMPORT POST_PROCESS' ) ;
   END IF;

   p_return_status := FND_API.G_RET_STS_SUCCESS; /* Init to Success */


   FOR I in 1..p_x_line_tbl.count
   LOOP
/* -----------------------------------------------------------
      Set message context for the line
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT FOR THE LINE' ) ;
      END IF;

      OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'HEADER'
        ,p_entity_ref                 => null
        ,p_entity_id                  => null
        ,p_header_id                  => p_x_header_rec.header_id
        ,p_line_id                    => null
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_x_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_x_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_x_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => p_x_line_tbl(I).orig_sys_line_ref
        ,p_orig_sys_shipment_ref      => p_x_line_tbl(I).orig_sys_shipment_ref
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

/* -----------------------------------------------------------
      Compare Price
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE COMPARING PRICE' ) ;
      END IF;

/* Added the following code to fix the bug 2355630 */
      l_unit_selling_price := -1;
      oe_debug_pub.add(  'net_price = ' || p_x_line_tbl(I).customer_item_net_price);
      oe_debug_pub.add(  'line_id = ' || p_x_line_tbl(I).line_id);
      IF p_x_line_tbl(I).customer_item_net_price <> FND_API.G_MISS_NUM THEN

         begin
           select unit_selling_price into l_unit_selling_price
           from oe_order_lines
           where line_id = p_x_line_tbl(I).line_id;

        exception
          when others then
            oe_debug_pub.add(  'ex usp = ' || l_unit_selling_price);
        end;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'CUSTOMER_ITEM_NET_PRICE '||TO_CHAR ( P_X_LINE_TBL ( I ) .CUSTOMER_ITEM_NET_PRICE ) ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'UNIT_SELLING_PRICE '||TO_CHAR ( L_UNIT_SELLING_PRICE ) ) ;
         END IF;

      END IF;


      IF p_x_line_tbl(I).customer_item_net_price <> FND_API.G_MISS_NUM AND
         p_x_line_tbl(I).customer_item_net_price <> l_unit_selling_price AND
         l_unit_selling_price <> -1
      THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'WARNING! ITEM PRICE SENT BY THE CUSTOMER IS DIFFERENT FROM THE ONE CALCULATED BY THE SYSTEM... ' ) ;
	 END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_PRICE_WARNING');
	 FND_MESSAGE.SET_TOKEN('CUST_PRICE',p_x_line_tbl(I).customer_item_net_price);
	 FND_MESSAGE.SET_TOKEN('SPLR_PRICE',l_unit_selling_price);
         OE_MSG_PUB.Add;
--	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

/* -----------------------------------------------------------
      Compare Payment Term
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
       oe_debug_pub.add('BEFORE COMPARING PAYMENT TERM' ) ;
       oe_debug_pub.add('cpti ' || p_x_line_tbl(I).customer_payment_term_id);
       IF p_x_line_val_tbl_old.exists(I) THEN --added for bug 4307609
         oe_debug_pub.add('cpt ' || p_x_line_val_tbl_old(I).customer_payment_term);
       end if ;
       oe_debug_pub.add('pti ' || p_x_line_tbl(I).payment_term_id);
      END IF;

      IF (p_x_line_tbl(I).customer_payment_term_id <> FND_API.G_MISS_NUM AND
         p_x_line_tbl(I).customer_payment_term_id <>
         p_x_line_tbl(I).payment_term_id) OR
         (  p_x_line_val_tbl_old.exists(I) -- added for 4307609
	 AND p_x_line_val_tbl_old(I).customer_payment_term <> FND_API.G_MISS_CHAR
         AND
         p_x_line_val_tbl_old(I).customer_payment_term <>
         oe_id_to_value.payment_term(p_x_line_tbl(I).payment_term_id))
      THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'WARNING! CUSTOMER AND SUPPLIER PAYMENT TERMS DIFFERENT... ' ) ;
	 END IF;

	 FND_MESSAGE.SET_NAME('ONT','OE_OI_PAYMENT_TERM_WARNING');
         IF nvl(p_x_line_tbl(I).customer_payment_term_id, FND_API.G_MISS_NUM)
            <> FND_API.G_MISS_NUM Then
            FND_MESSAGE.SET_TOKEN('CUST_TERM',p_x_line_tbl(I).customer_payment_term_id);
	    FND_MESSAGE.SET_TOKEN('SPLR_TERM',p_x_line_tbl(I).payment_term_id);
         ELSIF p_x_line_val_tbl_old.exists(I)  -- added for 4307609
	    AND nvl(p_x_line_val_tbl_old(I).customer_payment_term,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR Then
            FND_MESSAGE.SET_TOKEN('CUST_TERM',p_x_line_val_tbl_old(I).customer_payment_term);
	    FND_MESSAGE.SET_TOKEN('SPLR_TERM',oe_id_to_value.payment_term(p_x_line_tbl(I).payment_term_id));
         END IF;
         OE_MSG_PUB.Add;
--	 p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

   END LOOP;


/* -----------------------------------------------------------
   Inventory Reservations
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE RESERVING INVENTORY' ) ;
   END IF;

      OE_ORDER_IMPORT_RESERVE_PVT.Reserve_Inventory(
         p_header_rec                   => p_x_header_rec
        ,p_line_tbl                     => p_x_line_tbl
        ,p_reservation_tbl              => p_x_reservation_tbl
        ,p_header_val_rec               => p_x_header_val_rec
        ,p_line_val_tbl                 => p_x_line_val_tbl
        ,p_reservation_val_tbl          => p_x_reservation_val_tbl
        ,p_return_status                => l_return_status
        );

      IF  p_return_status NOT IN (FND_API.G_RET_STS_ERROR)
      AND l_return_status     IN (FND_API.G_RET_STS_ERROR,
			          FND_API.G_RET_STS_UNEXP_ERROR)
      THEN
            p_return_status := l_return_status;
      END IF;

/* Added the following if condition to fix the bug 3176286 */
      IF OE_SCHEDULE_UTIL.OESCH_PERFORMED_RESERVATION = 'Y' THEN
/* Added the code for the bug 2734389 */
        oe_debug_pub.add(  'BEFORE CALLING THE INV FOR DO_CHECK_FOR_COMMIT FROM  ORDER IMPORT' , 1 ) ;
    INV_RESERVATION_PVT.Do_Check_For_Commit
        (p_api_version_number  => 1.0
        ,p_init_msg_lst        => FND_API.G_FALSE
        ,x_return_status       => l_return_status
        ,x_msg_count           => l_msg_count
        ,x_msg_data            => l_msg_data
        ,x_failed_rsv_temp_tbl => l_failed_rsv_temp_tbl);
    oe_debug_pub.add(  'AFTER CALLING THE INV FOR DO_CHECK_FOR_COMMIT : ' || L_RETURN_STATUS , 1 ) ;
    IF l_failed_rsv_temp_tbl.count > 0 THEN
      oe_debug_pub.add(  ' THE RESERVATION PROCESS HAS FAILED ' , 1 ) ;
      FND_MESSAGE.SET_NAME('ONT','OE_SCH_RSV_FAILURE');
      OE_MSG_PUB.Add;
    END IF;
    -- Error Handling Start
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      oe_debug_pub.add(  'INSIDE UNEXPECTED ERROR' , 1 ) ;
      OE_MSG_PUB.Transfer_Msg_Stack;
      l_msg_count   := OE_MSG_PUB.COUNT_MSG;

      FOR I IN 1..l_msg_count LOOP
        l_msg_data :=  OE_MSG_PUB.Get(I,'F');
        oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
      END LOOP;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      oe_debug_pub.add(  ' INSIDE EXPECTED ERROR' , 1 ) ;
      OE_MSG_PUB.Transfer_Msg_Stack;
      l_msg_count   := OE_MSG_PUB.COUNT_MSG;

      FOR I IN 1..l_msg_count LOOP
        l_msg_data :=  OE_MSG_PUB.Get(I,'F');
        oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
      END LOOP;
      RAISE FND_API.G_EXC_ERROR;

    END IF;
      --Error Handling End

    OE_SCHEDULE_UTIL.OESCH_PERFORMED_RESERVATION := 'N';

  -- Check for Performed Reservation End
  END IF;
  /* Finish code for 2734389 */

/* -----------------------------------------------------------
   Call EDI Post-Process
   -----------------------------------------------------------
*/

   IF p_x_header_rec.order_source_id = OE_Globals.G_ORDER_SOURCE_EDI
   THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE CALLING EDI POST-PROCESS' ) ;
      END IF;

      OE_EDI_PVT.POST_PROCESS(
         p_header_rec                   => p_x_header_rec
        ,p_header_adj_tbl               => p_x_header_adj_tbl
        ,p_header_scredit_tbl           => p_x_header_scredit_tbl
        ,p_line_tbl                     => p_x_line_tbl
        ,p_line_adj_tbl                 => p_x_line_adj_tbl
        ,p_line_scredit_tbl             => p_x_line_scredit_tbl
        ,p_lot_serial_tbl               => p_x_lot_serial_tbl

        ,p_header_val_rec               => p_x_header_val_rec
        ,p_header_adj_val_tbl           => p_x_header_adj_val_tbl
        ,p_header_scredit_val_tbl       => p_x_header_scredit_val_tbl
        ,p_line_val_tbl                 => p_x_line_val_tbl
        ,p_line_adj_val_tbl             => p_x_line_adj_val_tbl
        ,p_line_scredit_val_tbl         => p_x_line_scredit_val_tbl
        ,p_lot_serial_val_tbl           => p_x_lot_serial_val_tbl

        ,p_return_status                => l_return_status
        );

        IF  p_return_status NOT IN (FND_API.G_RET_STS_ERROR)
        AND l_return_status     IN (FND_API.G_RET_STS_ERROR,
			            FND_API.G_RET_STS_UNEXP_ERROR)
        THEN
              p_return_status := l_return_status;
        END IF;
   END IF;


  EXCEPTION
   WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
      END IF;
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Post_Process');
      END IF;

END POST_PROCESS;


END OE_ORDER_IMPORT_SPECIFIC_PVT;

/
