--------------------------------------------------------
--  DDL for Package Body OE_LINE_ACK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LINE_ACK_UTIL" AS
/* $Header: OEXULAKB.pls 120.10.12010000.2 2009/05/22 07:13:51 smanian ship $ */


--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_LINE_ACK_UTIL';

-- {aksingh 3a4 Start
-- { Start GET_ACK_CODE
FUNCTION GET_ACK_CODE (p_order_source_id   NUMBER   := 6,
                       p_reject_order      VARCHAR2 := 'N',
                       p_transaction_type  VARCHAR2 := NULL,
                       p_booked_flag       VARCHAR2 := NULL)
RETURN VARCHAR
IS
  l_ack_code  Varchar2(30);
BEGIN

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
        Return 'IA'; --Changed AT to IA for bug 4137350
     End If;
  Elsif p_reject_order = 'Y' Then
     If p_order_source_id = 20 Then
        oe_debug_pub.add('return Rejected - code is 2');
        Return '2';
     Else
        Return 'RJ';
     End If;
  Else
    Return Null;
  End If;
END GET_ACK_CODE;
-- End GET_ACK_CODE }
-- End aksingh 3a4 }

PROCEDURE Update_Header_Ack_Code
(   p_header_id         IN  NUMBER,
    p_first_ack_code    IN  VARCHAR2,
    p_last_ack_code     IN  VARCHAR2
)
IS
BEGIN
    oe_debug_pub.add ('Entering Update_Header_Ack_Code with params: header id ' ||
			p_header_id || ', first_ack_code ' || p_first_ack_code
			|| ', last_ack_code ' || p_last_ack_code || '.');
    IF p_first_ack_code IS NOT NULL THEN
       UPDATE oe_header_acks
	SET first_ack_code = p_first_ack_code
	WHERE header_id = p_header_id;
       oe_debug_pub.add ('rows updated: ' || SQL%ROWCOUNT);
    ELSIF p_last_ack_code IS NOT NULL THEN
	UPDATE oe_header_acks
	 SET last_ack_code = p_last_ack_code
	 WHERE header_id = p_header_id;
       oe_debug_pub.add ('rows updated: ' || SQL%ROWCOUNT);
    ELSE
	oe_debug_pub.add ('Bad args passed to update_header_ack_code, no header records updated');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
	oe_debug_pub.add ('When Others in Update_Header_Ack_Code');
END Update_Header_Ack_Code;


PROCEDURE Insert_Row
(   p_line_tbl            IN  OE_Order_Pub.Line_Tbl_Type
,   p_line_val_tbl        IN  OE_Order_Pub.Line_Val_Tbl_Type
,   p_old_line_tbl        IN  OE_Order_Pub.Line_Tbl_Type
,   p_old_line_val_tbl    IN  OE_Order_Pub.Line_Val_Tbl_Type
,   p_buyer_seller_flag   IN  VARCHAR2
,   p_reject_order        IN  VARCHAR2
,   p_ack_type            IN  VARCHAR2 := NULL
,   x_return_status	  OUT NOCOPY VARCHAR2
)
IS
l_line_rec                OE_Order_Pub.Line_Rec_Type;
l_line_val_rec            OE_Order_Pub.Line_Val_Rec_Type;

l_count			  NUMBER;
I   BINARY_INTEGER;
l_error_flag              Varchar2(1);
BEGIN

    l_count := p_line_tbl.COUNT;
    l_count := p_line_val_tbl.COUNT;
     I := p_line_tbl.FIRST;
     WHILE I IS NOT NULL LOOP
     --FOR I IN 1..p_line_tbl.COUNT LOOP

      IF p_reject_order = 'N' THEN
         l_line_rec      :=  p_line_tbl(I);
         OE_Line_Util.Convert_Miss_To_Null (l_line_rec);
       -- {Start of 3A4 change for the reject = 'N'
       If l_line_rec.order_source_id = 20 Then
        If l_line_rec.First_Ack_Code IS NULL Then
          If p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_POA then
            l_line_rec.FIRST_ACK_CODE :=
            Get_Ack_Code(p_order_source_id => l_line_rec.order_source_id,
                         p_reject_order    => p_reject_order);
          Elsif p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_CPO then
            l_line_rec.FIRST_ACK_CODE :=
            Get_Ack_Code(p_order_source_id => l_line_rec.order_source_id,
                         p_reject_order    => p_reject_order);
          -- 3A6 related
          Elsif p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_SSO then
            If l_line_rec.last_ack_code IS NULL Then
               l_line_rec.FIRST_ACK_CODE := 'OPEN';
            Else
               l_line_rec.FIRST_ACK_CODE := l_line_rec.last_ack_code;
            End if;
          Elsif p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_CSO then
            If l_line_rec.last_ack_code IS NULL Then
               l_line_rec.FIRST_ACK_CODE := 'OPEN';
            Else
               l_line_rec.FIRST_ACK_CODE := l_line_rec.last_ack_code;
            End if;
	  -- 3A4 related
	  Elsif  p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_POI then
            l_line_rec.FIRST_ACK_CODE :=
             Get_Ack_Code(p_order_source_id => l_line_rec.order_source_id,
                         p_reject_order    => p_reject_order,
                         p_booked_flag     => l_line_rec.booked_flag,
                         p_transaction_type => oe_acknowledgment_pub.G_TRANSACTION_POI);
          Elsif  p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_CHO then
              l_line_rec.FIRST_ACK_CODE :=
              Get_Ack_Code(p_order_source_id => l_line_rec.order_source_id,
                           p_reject_order    => p_reject_order);

          End if;
	  l_line_rec.FIRST_ACK_DATE := '';
	  l_line_rec.LAST_ACK_CODE  := '';
	  l_line_rec.LAST_ACK_DATE  := '';
        Else
          l_line_rec.LAST_ACK_CODE :=
            Get_Ack_Code(p_order_source_id => l_line_rec.order_source_id,
                         p_reject_order    => p_reject_order);
	  l_line_rec.LAST_ACK_DATE  := '';
        End If;
       Else
         l_line_val_rec  :=  p_line_val_tbl(I);

	  -- Following Check will determine if this is a 855 or 865
	  oe_debug_pub.add('l_line_rec.SCHEDULE_SHIP_DATE :' || l_line_rec.SCHEDULE_SHIP_DATE,1);
          oe_debug_pub.add('l_line_rec.REQUEST_DATE       :' || l_line_rec.REQUEST_DATE, 1);

	 IF (nvl(l_line_rec.FIRST_ACK_CODE, ' ')= ' ' OR
             l_line_rec.FIRST_ACK_CODE = FND_API.G_MISS_CHAR) THEN -- It is 855
	    oe_debug_pub.add('trans is 855 with first_ack_code ' ||nvl(l_line_rec.FIRST_ACK_CODE, 'NULL' ));
	    IF l_line_rec.SCHEDULE_SHIP_DATE is NULL THEN
		oe_debug_pub.add('ack code: schedule ship date is null');
	       l_line_rec.FIRST_ACK_CODE := 'SP';
            END IF;
	    IF l_line_rec.SCHEDULE_SHIP_DATE is NOT NULL
	       AND trunc(l_line_rec.SCHEDULE_SHIP_DATE) <> nvl(trunc(l_line_rec.REQUEST_DATE), FND_API.G_MISS_DATE)
	    THEN
	       oe_debug_pub.add('ack code: date rescheduled');
	       l_line_rec.FIRST_ACK_CODE := 'DR';
            END IF;

           --Added for bug 4771523+bug 4454400 start
            If nvl(l_line_rec.unit_selling_price, FND_API.G_MISS_NUM) <> nvl(p_old_line_tbl(I).unit_selling_price, FND_API.G_MISS_NUM)
            THEN
               l_line_rec.FIRST_ACK_CODE := 'IP';
               oe_debug_pub.add('new unit selling price: ' || l_line_rec.unit_selling_price);
               oe_debug_pub.add('old unit selling price: ' || p_old_line_tbl(I).unit_selling_price);
	       oe_debug_pub.add('ack code: price changed');
            END IF;
            IF OE_ORDER_UTIL.g_line_tbl(I).customer_item_net_price IS NOT NULL
             AND OE_ORDER_UTIL.g_line_tbl(I).customer_item_net_price <> FND_API.G_MISS_NUM THEN

               oe_debug_pub.add(' unit_selling_price in global : '||OE_ORDER_UTIL.g_line_tbl(I).unit_selling_price,5);
               oe_debug_pub.add(' CUSTOMER_ITEM_NET_PRICE in global : '||OE_ORDER_UTIL.g_line_tbl(I).CUSTOMER_ITEM_NET_PRICE,5);

              IF OE_ORDER_UTIL.g_line_tbl(I).customer_item_net_price <> OE_ORDER_UTIL.g_line_tbl(I).unit_selling_price THEN
                l_line_rec.FIRST_ACK_CODE := 'IP';
                oe_debug_pub.add(' ack code: price changed : '||l_line_rec.FIRST_ACK_CODE,5);
              END IF;
               oe_debug_pub.add(' new unit selling price: ' || l_line_rec.unit_selling_price,5);
               oe_debug_pub.add(' old unit selling price: ' || p_old_line_tbl(I).unit_selling_price,5);
            END IF;
            --Added for bug 4771523+bug 4454400 end


	    IF l_line_rec.ORDERED_QUANTITY <> p_old_line_tbl(I).ORDERED_QUANTITY
	    THEN
	       IF l_line_rec.FIRST_ACK_CODE IS NULL or l_line_rec.FIRST_ACK_CODE = FND_API.G_MISS_CHAR Then
	          l_line_rec.FIRST_ACK_CODE := 'IQ';
	       ELSE
		  l_line_rec.FIRST_ACK_CODE := 'IC'; -- item accepted, (multiple) changes made , refer to HLD
	       END IF;
            END IF;
	    -- Add Below Code for Price Change - IP - once New fields are added

	    -- ack code changes introduced to support item relationships
            -- we change the ack code for automatic/manual substitution
	    -- as well as upsell or superseded items or promotional upgrades
	    -- For the remaining relationships, only the header ack code
	    -- is changed since the IS (meaning substitution) ack code is not appropriate
	    -- as new lines were added rather than substituting item on the orig line

            IF l_line_rec.ORIGINAL_INVENTORY_ITEM_ID is NOT NULL THEN
	       IF (l_line_rec.ITEM_RELATIONSHIP_TYPE is NULL
		   OR l_line_rec.ITEM_RELATIONSHIP_TYPE = 2
		   OR l_line_rec.ITEM_RELATIONSHIP_TYPE = 4
		   OR l_line_rec.ITEM_RELATIONSHIP_TYPE = 8
		   OR l_line_rec.ITEM_RELATIONSHIP_TYPE = 14) THEN
		   IF l_line_rec.FIRST_ACK_CODE IS NULL OR l_line_rec.FIRST_ACK_CODE = FND_API.G_MISS_CHAR Then
		      l_line_rec.FIRST_ACK_CODE := 'IS';
		   ELSE l_line_rec.FIRST_ACK_CODE := 'IC'; -- item accepted, (multiple) changes made , refer to HLD
		   END IF;
	       ELSE
		   IF l_line_rec.FIRST_ACK_CODE IS NULL OR l_line_rec.FIRST_ACK_CODE = FND_API.G_MISS_CHAR Then
		      l_line_rec.FIRST_ACK_CODE := 'IA';
		   END IF;
               END IF;
	   END IF;

           IF l_line_rec.SPLIT_FROM_LINE_ID is not NULL  AND
              l_line_rec.split_by = 'SYSTEM' THEN
              l_line_rec.FIRST_ACK_CODE := 'IB';
           END IF;

           /* added the following if condition to fix the bug 2878987 */
            IF l_line_rec.OPEN_FLAG = 'N'  THEN
               l_line_rec.FIRST_ACK_CODE := 'ID';
            END IF;


	    -- If Everything Accepted as it is
            IF l_line_rec.FIRST_ACK_CODE is NULL or l_line_rec.FIRST_ACK_CODE = FND_API.G_MISS_CHAR THEN
	       l_line_rec.FIRST_ACK_CODE := 'IA';
	    ELSIF l_line_rec.FIRST_ACK_CODE is NOT NULL THEN
	       -- the ack code was modified, we should update the header ack code
               Update_Header_Ack_Code (l_line_rec.header_id, 'AC', NULL);

	    END IF;

	    l_line_rec.FIRST_ACK_DATE := '';
	    l_line_rec.LAST_ACK_CODE  := '';
	    l_line_rec.LAST_ACK_DATE  := '';

          ELSE -- it is 865

            IF l_line_rec.changed_lines_pocao = 'N' THEN
               GOTO nextline;
            END IF;

            l_line_rec.FIRST_ACK_DATE := p_old_line_tbl(I).FIRST_ACK_DATE;

	    IF l_line_rec.SCHEDULE_SHIP_DATE is NULL THEN
	       l_line_rec.LAST_ACK_CODE := 'SP';
            END IF;
	    IF l_line_rec.SCHEDULE_SHIP_DATE is NOT NULL
	       AND l_line_rec.SCHEDULE_SHIP_DATE <> nvl(p_old_line_tbl(I).SCHEDULE_SHIP_DATE, FND_API.G_MISS_DATE)
	       AND l_line_rec.SCHEDULE_SHIP_DATE <> nvl(l_line_rec.REQUEST_DATE, FND_API.G_MISS_DATE)
            THEN
	       l_line_rec.LAST_ACK_CODE := 'DR';
            END IF;
           -- Added for bug 4771523 + bug 4454400 start
           If nvl(l_line_rec.unit_selling_price, FND_API.G_MISS_NUM) <> nvl(p_old_line_tbl(I).unit_selling_price, FND_API.G_MISS_NUM)
            THEN
               l_line_rec.LAST_ACK_CODE := 'IP';
               oe_debug_pub.add('new unit selling price: ' || l_line_rec.unit_selling_price);
               oe_debug_pub.add('old unit selling price: ' || p_old_line_tbl(I).unit_selling_price);
	       oe_debug_pub.add('ack code: price changed');
            END IF;

            IF OE_ORDER_UTIL.g_line_tbl(I).customer_item_net_price IS NOT NULL
             AND OE_ORDER_UTIL.g_line_tbl(I).customer_item_net_price <> FND_API.G_MISS_NUM THEN

              oe_debug_pub.add(' unit_selling_price in global : '||OE_ORDER_UTIL.g_line_tbl(I).unit_selling_price,5);
              oe_debug_pub.add(' CUSTOMER_ITEM_NET_PRICE in global : '||OE_ORDER_UTIL.g_line_tbl(I).CUSTOMER_ITEM_NET_PRICE,5);

              IF OE_ORDER_UTIL.g_line_tbl(I).customer_item_net_price <> OE_ORDER_UTIL.g_line_tbl(I).unit_selling_price THEN
                l_line_rec.LAST_ACK_CODE := 'IP';
                oe_debug_pub.add(' ack code: price changed : '||l_line_rec.FIRST_ACK_CODE,5);
              END IF;
               oe_debug_pub.add(' new unit selling price: ' || l_line_rec.unit_selling_price,5);
               oe_debug_pub.add(' old unit selling price: ' || p_old_line_tbl(I).unit_selling_price,5);
            END IF;
	   -- Added for bug 4771523 + bug 4454400 end

	    IF l_line_rec.ORDERED_QUANTITY <> p_old_line_tbl(I).ORDERED_QUANTITY
	    THEN
	       IF l_line_rec.LAST_ACK_CODE IS NULL or l_line_rec.LAST_ACK_CODE = FND_API.G_MISS_CHAR Then
		  l_line_rec.LAST_ACK_CODE := 'IQ';
	       ELSE
                  l_line_rec.LAST_ACK_CODE := 'IC'; -- item accepted, (multiple) changes made , refer to HLD
	       END IF;
            END IF;
	    -- Add Below Code for Price Change - IP - once New fields are added


           IF l_line_rec.SPLIT_FROM_LINE_ID is not NULL AND
              l_line_rec.split_by = 'SYSTEM' THEN
              l_line_rec.LAST_ACK_CODE := 'IB';
           END IF;

            /* added the following if condition to fix the bug 2878987 */
            IF l_line_rec.OPEN_FLAG = 'N'  THEN
               l_line_rec.LAST_ACK_CODE := 'ID';
            END IF;

	    -- If Everything Accepted as it is
            IF l_line_rec.LAST_ACK_CODE is NULL OR l_line_rec.LAST_ACK_CODE = FND_API.G_MISS_CHAR THEN
	       l_line_rec.LAST_ACK_CODE := 'IA';
	    END IF;
	    -- in the case of 865, the header last ack code defaults to AC, so we don't need to change it here
            -- (unlike 855)

	    l_line_rec.LAST_ACK_DATE := '';

          END IF;
        END IF;
        -- End of 3A4 for reject = 'N' }
      ELSE -- p_reject_order = 'Y'

         l_line_rec      :=  p_old_line_tbl(I);
         l_error_flag := 'Y';
         OE_Line_Util.Convert_Miss_To_Null (l_line_rec);
         -- {Start of 3A4 change for the reject = 'Y'
         If l_line_rec.order_source_id = 20 Then
            If l_line_rec.First_Ack_Code IS NULL Then
               l_line_rec.FIRST_ACK_CODE :=
                 Get_Ack_Code(p_order_source_id => l_line_rec.order_source_id,
                              p_reject_order    => p_reject_order);
               l_line_rec.FIRST_ACK_DATE := '';
               l_line_rec.LAST_ACK_CODE  := '';
               l_line_rec.LAST_ACK_DATE  := '';
            Else
              l_line_rec.LAST_ACK_CODE :=
                Get_Ack_Code(p_order_source_id => l_line_rec.order_source_id,
                             p_reject_order    => p_reject_order);
              l_line_rec.LAST_ACK_DATE  := '';
            End If;

         Else
	 IF nvl(l_line_rec.FIRST_ACK_CODE,' ')=' ' THEN -- It is 855
	    l_line_rec.FIRST_ACK_CODE := 'IR';
            oe_debug_pub.add('855 nulling first_ack_date');
	    l_line_rec.FIRST_ACK_DATE := '';
	    l_line_rec.LAST_ACK_CODE  := '';
	    l_line_rec.LAST_ACK_DATE  := '';
         ELSE
	    l_line_rec.LAST_ACK_CODE := 'IR';
	    l_line_rec.LAST_ACK_DATE := '';
         END IF;

        END IF;
        -- End of 3A4 for reject = 'Y' }

       --Value record is not required as record is rejected
       --The above statement is not valid as the rejected record can
       --have the value (when customer send the value data).
       --so, we need to check if the record exists then populate for
       --acknowledgment

       if p_old_line_val_tbl.EXISTS(I) then
         -- uncommented following line, because of the mentioned reason above
         -- bug3429670
         l_line_val_rec  :=  p_old_line_val_tbl(I);
       end if;
      END IF;

    BEGIN

if p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_SSO
   Or p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_CSO
then

          SELECT count(*) INTO l_count
            FROM OE_LINE_ACKS
           WHERE header_id = l_line_rec.header_id
	     AND line_id = l_line_rec.line_id
             AND acknowledgment_flag Is Null
             -- Change this condition once ack type is ins for POAO/POCAO
             AND nvl(acknowledgment_type,'ALL') = nvl(p_ack_type,'ALL')
             AND  nvl(sold_to_org_id, FND_API.G_MISS_NUM)
               =  nvl(l_line_rec.sold_to_org_id, FND_API.G_MISS_NUM)
	     AND  nvl(sold_to_org, FND_API.G_MISS_CHAR)
               =  nvl(l_line_val_rec.sold_to_org, FND_API.G_MISS_CHAR)
             AND  nvl(change_sequence, FND_API.G_MISS_CHAR)
               =  nvl(l_line_rec.change_sequence, FND_API.G_MISS_CHAR)
             AND request_id = l_line_rec.request_id;


else
          SELECT count(*) INTO l_count
            FROM OE_LINE_ACKS
           WHERE header_id = l_line_rec.header_id
             AND line_id = l_line_rec.line_id
             AND acknowledgment_flag Is Null
             -- Change this condition once ack type is ins for POAO/POCAO
             AND nvl(acknowledgment_type,'ALL') = nvl(p_ack_type,'ALL')
             AND  nvl(sold_to_org_id, FND_API.G_MISS_NUM)
               =  nvl(l_line_rec.sold_to_org_id, FND_API.G_MISS_NUM)
	     AND  nvl(sold_to_org, FND_API.G_MISS_CHAR)
               =  nvl(l_line_val_rec.sold_to_org, FND_API.G_MISS_CHAR)
             AND  nvl(change_sequence, FND_API.G_MISS_CHAR)
               =  nvl(l_line_rec.change_sequence, FND_API.G_MISS_CHAR);
end if;
          IF l_count > 0 THEN
             oe_debug_pub.add('l_count > 0, Calling Delete_Row');
             OE_Line_Ack_Util.Delete_Row (p_line_id  => l_line_rec.line_id,
                                          p_ack_type   => p_ack_type,
                                          p_sold_to_org_id => l_line_rec.sold_to_org_id,
					  p_sold_to_org => l_line_val_rec.sold_to_org,
                                          p_change_sequence => l_line_rec.change_sequence,
                                          p_request_id => l_line_rec.request_id,
                                          p_header_id => l_line_rec.header_id);

	  ELSE
              oe_debug_pub.add('l_count <= 0 for line_id, attempting delete by doc ref, line ref and ship ref');
              OE_Line_Ack_Util.Delete_Row (p_line_id  => NULL,
                                           p_ack_type   => p_ack_type,
                                           p_orig_sys_document_ref => l_line_rec.orig_sys_document_ref,
                                           p_orig_sys_line_ref     => l_line_rec.orig_sys_line_ref,
                                           p_orig_sys_shipment_ref => l_line_rec.orig_sys_shipment_ref,
                                          p_sold_to_org_id => l_line_rec.sold_to_org_id,
					   p_sold_to_org   => l_line_val_rec.sold_to_org,
                                          p_change_sequence => l_line_rec.change_sequence,
                                           p_request_id => l_line_rec.request_id,
                                           p_header_id => NULL
);
          END IF;


          EXCEPTION WHEN OTHERS THEN NULL;
    END;



      IF       l_line_rec.order_source_id            <> FND_API.G_MISS_NUM
      -- Changed the following condition to compare -1 instead of 0
      -- as 0 is valid order_source_id
      AND  nvl(l_line_rec.order_source_id,-1)        <> -1
      AND      l_line_rec.orig_sys_document_ref      <> FND_API.G_MISS_CHAR
      AND  nvl(l_line_rec.orig_sys_document_ref,' ') <> ' '
      AND      l_line_rec.orig_sys_line_ref          <> FND_API.G_MISS_CHAR
      AND  nvl(l_line_rec.orig_sys_line_ref,' ')     <> ' '
      -- Commenting the next 2 lines for the bug 2922709 fix
      -- As for the rejected lines line_id can be null
      -- OR      (l_line_rec.line_id                    <> FND_API.G_MISS_NUM
      -- AND  nvl(l_line_rec.line_id,0)                 <> 0)

      THEN

    oe_debug_pub.add('inserting line ack record for'||
' source id: '   ||to_char(l_line_rec.order_source_id)||
', order ref: '  ||l_line_rec.orig_sys_document_ref||
', line ref: '   ||l_line_rec.orig_sys_line_ref||
', line id: '    ||to_char(l_line_rec.line_id)||
', line no: '    ||to_char(l_line_rec.line_number)||
', shipment no: '||to_char(l_line_rec.shipment_number)||
', option no: '  ||to_char(l_line_rec.option_number));

   oe_debug_pub.add('item id = '||l_line_rec.inventory_item_id);
   oe_debug_pub.add('item nm = '||l_line_val_rec.inventory_item);
   oe_debug_pub.add('first_ack_date = '||l_line_rec.first_ack_date);

      IF l_line_rec.split_from_line_id IS NOT NULL
        AND l_line_rec.split_from_line_id <> FND_API.G_MISS_NUM
      THEN
         --bsadri get the split reference
         oe_debug_pub.add('bsadri get the reference for split id :' ||
            l_line_rec.split_from_line_id);
         BEGIN
          SELECT orig_sys_line_ref, orig_sys_shipment_ref
          INTO l_line_rec.split_from_line_ref, l_line_rec.split_from_shipment_ref
          FROM OE_ORDER_LINES
          WHERE line_id = l_line_rec.split_from_line_id;
         EXCEPTION
          WHEN OTHERS THEN
           oe_debug_pub.add('bsadri failed to get the refernce for split line');
         END;
      END IF;
      --added end customer fields for bug 4034441
      INSERT INTO OE_LINE_ACKS
         (
          ACCOUNTING_RULE
         ,ACCOUNTING_RULE_ID
         ,ACCOUNTING_RULE_DURATION
         ,ACKNOWLEDGMENT_FLAG
         ,ACTUAL_ARRIVAL_DATE
         ,ACTUAL_SHIPMENT_DATE
         ,AGREEMENT
         ,AGREEMENT_ID
         ,ARRIVAL_SET_ID
--       ,ARRIVAL_SET_NAME
         ,ATO_LINE_ID
         ,ATTRIBUTE1
         ,ATTRIBUTE10
         ,ATTRIBUTE11
         ,ATTRIBUTE12
         ,ATTRIBUTE13
         ,ATTRIBUTE14
         ,ATTRIBUTE15
         ,ATTRIBUTE16    --For bug 2184255
         ,ATTRIBUTE17
         ,ATTRIBUTE18
         ,ATTRIBUTE19
         ,ATTRIBUTE2
         ,ATTRIBUTE20
         ,ATTRIBUTE3
         ,ATTRIBUTE4
         ,ATTRIBUTE5
         ,ATTRIBUTE6
         ,ATTRIBUTE7
         ,ATTRIBUTE8
         ,ATTRIBUTE9
         ,AUTHORIZED_TO_SHIP_FLAG
         ,BUYER_SELLER_FLAG
         ,BOOKED_FLAG
--       ,CALCULATE_PRICE_FLAG
         ,CANCELLED_FLAG
         ,CANCELLED_QUANTITY
         ,CHANGE_DATE
         ,CHANGE_SEQUENCE
--       ,CLOSED_FLAG
         ,COMPONENT_CODE
         ,COMPONENT_NUMBER
         ,COMPONENT_SEQUENCE_ID
         ,CONFIG_DISPLAY_SEQUENCE
--       ,CONFIG_LINE_REF
         ,CONFIGURATION_ID
         ,TOP_MODEL_LINE_ID
         ,CONTEXT
         ,CREATED_BY
         ,CREATION_DATE
         ,CUST_MODEL_SERIAL_NUMBER
         ,CUST_PO_NUMBER
         ,CUST_PRODUCTION_SEQ_NUM
         ,CUSTOMER_DOCK_CODE
         ,CUSTOMER_ITEM
         ,CUSTOMER_ITEM_ID		-- 11/03
	 ,ORDERED_ITEM
--       ,CUSTOMER_ITEM_REVISION   11/03
         , CUSTOMER_JOB
         ,CUSTOMER_PRODUCTION_LINE
         ,CUSTOMER_TRX_LINE_ID
--       ,DELIVER_TO_CONTACT
         ,DELIVER_TO_CONTACT_ID
         ,DELIVER_TO_ORG
         ,DELIVER_TO_ORG_ID
         ,DELIVERY_LEAD_TIME
         ,DEMAND_BUCKET_TYPE
         ,DEMAND_BUCKET_TYPE_CODE
--       ,DEMAND_CLASS
         ,DEMAND_CLASS_CODE
--       ,DEMAND_STREAM
         ,DEP_PLAN_REQUIRED_FLAG
--       ,DPW_ASSIGNED_FLAG
         ,EARLIEST_ACCEPTABLE_DATE
         ,EXPLOSION_DATE
	 ,FIRST_ACK_CODE
	 ,FIRST_ACK_DATE
         ,FOB_POINT
         ,FOB_POINT_CODE
         ,FREIGHT_CARRIER_CODE
         ,FREIGHT_TERMS
         ,FREIGHT_TERMS_CODE
         ,FULFILLED_QUANTITY
--       ,FULFILLMENT_SET_ID
--       ,FULFILLMENT_SET_NAME
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
         ,HEADER_ID
         ,INDUSTRY_ATTRIBUTE1
         ,INDUSTRY_ATTRIBUTE10
         ,INDUSTRY_ATTRIBUTE11
         ,INDUSTRY_ATTRIBUTE12
         ,INDUSTRY_ATTRIBUTE13
         ,INDUSTRY_ATTRIBUTE14
         ,INDUSTRY_ATTRIBUTE15
         ,INDUSTRY_ATTRIBUTE16
         ,INDUSTRY_ATTRIBUTE17
         ,INDUSTRY_ATTRIBUTE18
         ,INDUSTRY_ATTRIBUTE19
         ,INDUSTRY_ATTRIBUTE2
         ,INDUSTRY_ATTRIBUTE20
         ,INDUSTRY_ATTRIBUTE21
         ,INDUSTRY_ATTRIBUTE22
         ,INDUSTRY_ATTRIBUTE23
         ,INDUSTRY_ATTRIBUTE24
         ,INDUSTRY_ATTRIBUTE25
         ,INDUSTRY_ATTRIBUTE26
         ,INDUSTRY_ATTRIBUTE27
         ,INDUSTRY_ATTRIBUTE28
         ,INDUSTRY_ATTRIBUTE29
         ,INDUSTRY_ATTRIBUTE3
         ,INDUSTRY_ATTRIBUTE30
         ,INDUSTRY_ATTRIBUTE4
         ,INDUSTRY_ATTRIBUTE5
         ,INDUSTRY_ATTRIBUTE6
         ,INDUSTRY_ATTRIBUTE7
         ,INDUSTRY_ATTRIBUTE8
         ,INDUSTRY_ATTRIBUTE9
         ,INDUSTRY_CONTEXT
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
         ,INTMED_SHIP_TO_CONTACT_ID
         ,INTMED_SHIP_TO_ORG_ID
         ,INVENTORY_ITEM
         ,INVENTORY_ITEM_ID
--       ,INVOICE_COMPLETE_FLAG    11/03
--       ,INVOICE_SET_ID
--       ,INVOICE_SET_NAME
--       ,INVOICE_NUMBER
         ,INVOICE_TO_CONTACT
         ,INVOICE_TO_CONTACT_ID
         ,INVOICE_TO_ORG
         ,INVOICE_TO_ORG_ID
--       ,INVOICE_TOLERANCE_ABOVE
--       ,INVOICE_TOLERANCE_BELOW
         ,INVOICING_RULE
         ,INVOICING_RULE_ID
         ,ITEM_INPUT
         ,ITEM_REVISION
         ,ITEM_TYPE_CODE
	 ,LAST_ACK_CODE
	 ,LAST_ACK_DATE
         ,LAST_UPDATE_DATE
         ,LAST_UPDATE_LOGIN
         ,LAST_UPDATED_BY
         ,LATEST_ACCEPTABLE_DATE
         ,LINE_CATEGORY_CODE
         ,LINE_ID
         ,LINE_NUMBER
--       ,LINE_PO_CONTEXT
         ,LINE_TYPE
         ,LINE_TYPE_ID
         ,LINK_TO_LINE_ID
--       ,LINK_TO_LINE_REF
--       ,LOT
         ,MODEL_GROUP_NUMBER
         ,OPEN_FLAG
         ,OPERATION_CODE
         ,OPTION_FLAG
         ,OPTION_NUMBER
         ,ORDER_QUANTITY_UOM
         ,ORDER_SOURCE_ID
         ,ORDERED_QUANTITY
         ,ORG_ID
         ,ORIG_SYS_DOCUMENT_REF
         ,ORIG_SYS_LINE_REF
         ,ORIG_SYS_SHIPMENT_REF
         ,OVER_SHIP_REASON_CODE
         ,OVER_SHIP_RESOLVED_FLAG
         ,PAYMENT_TERM
         ,PAYMENT_TERM_ID
         ,PRICE_LIST
         ,PRICE_LIST_ID
         ,PRICING_ATTRIBUTE1
         ,PRICING_ATTRIBUTE10
         ,PRICING_ATTRIBUTE2
         ,PRICING_ATTRIBUTE3
         ,PRICING_ATTRIBUTE4
         ,PRICING_ATTRIBUTE5
         ,PRICING_ATTRIBUTE6
         ,PRICING_ATTRIBUTE7
         ,PRICING_ATTRIBUTE8
         ,PRICING_ATTRIBUTE9
         ,PRICING_CONTEXT
         ,PRICING_DATE
         ,PRICING_QUANTITY
         ,PRICING_QUANTITY_UOM
--       ,PROGRAM
--       ,PROGRAM_APPLICATION
         ,PROGRAM_APPLICATION_ID
         ,PROGRAM_ID
         ,PROGRAM_UPDATE_DATE
         ,PROJECT
         ,PROJECT_ID
         ,PROMISE_DATE
--       ,REFERENCE_HEADER
         ,REFERENCE_HEADER_ID
--       ,REFERENCE_LINE
         ,REFERENCE_LINE_ID
         ,REFERENCE_TYPE
--       ,RELATED_PO_NUMBER
         ,REQUEST_DATE
         ,REQUEST_ID
         ,RESERVED_QUANTITY
         ,RETURN_ATTRIBUTE1
         ,RETURN_ATTRIBUTE10
         ,RETURN_ATTRIBUTE11
         ,RETURN_ATTRIBUTE12
         ,RETURN_ATTRIBUTE13
         ,RETURN_ATTRIBUTE14
         ,RETURN_ATTRIBUTE15
         ,RETURN_ATTRIBUTE2
         ,RETURN_ATTRIBUTE3
         ,RETURN_ATTRIBUTE4
         ,RETURN_ATTRIBUTE5
         ,RETURN_ATTRIBUTE6
         ,RETURN_ATTRIBUTE7
         ,RETURN_ATTRIBUTE8
         ,RETURN_ATTRIBUTE9
         ,RETURN_CONTEXT
         ,RETURN_REASON_CODE
         ,RLA_SCHEDULE_TYPE_CODE
         ,SALESREP_ID
         ,SALESREP
         ,SCHEDULE_ARRIVAL_DATE
         ,SCHEDULE_SHIP_DATE
--       ,SCHEDULE_ITEM_DETAIL
         ,SCHEDULE_STATUS_CODE
         ,SHIP_FROM_ORG
         ,SHIP_FROM_ORG_ID
         ,SHIP_MODEL_COMPLETE_FLAG
         ,SHIP_SET_ID
--       ,SHIP_SET_NAME
         ,SHIP_TO_ADDRESS1
         ,SHIP_TO_ADDRESS2
         ,SHIP_TO_ADDRESS3
         ,SHIP_TO_ADDRESS4
         ,SHIP_TO_CITY
         ,SHIP_TO_CONTACT
--       ,SHIP_TO_CONTACT_AREA_CODE1
--       ,SHIP_TO_CONTACT_AREA_CODE2
--       ,SHIP_TO_CONTACT_AREA_CODE3
         ,SHIP_TO_CONTACT_FIRST_NAME
         ,SHIP_TO_CONTACT_ID
--       ,SHIP_TO_CONTACT_JOB_TITLE
         ,SHIP_TO_CONTACT_LAST_NAME
         ,SHIP_TO_COUNTRY
         ,SHIP_TO_COUNTY
         ,SHIP_TO_ORG
         ,SHIP_TO_ORG_ID
         ,SHIP_TO_POSTAL_CODE
         ,SHIP_TO_STATE
         ,SHIP_TOLERANCE_ABOVE
         ,SHIP_TOLERANCE_BELOW
         ,SHIPMENT_NUMBER
         ,SHIPMENT_PRIORITY
         ,SHIPMENT_PRIORITY_CODE
         ,SHIPPED_QUANTITY
--       ,SHIPPING_METHOD
         ,SHIPPING_METHOD_CODE
         ,SHIPPING_QUANTITY
         ,SHIPPING_QUANTITY_UOM
--       ,SOLD_FROM_ORG
--       ,SOLD_FROM_ORG_ID
         ,SOLD_TO_ORG
         ,SOLD_TO_ORG_ID
         ,SORT_ORDER
         ,SOURCE_DOCUMENT_ID
         ,SOURCE_DOCUMENT_LINE_ID
         ,SOURCE_DOCUMENT_TYPE_ID
         ,SOURCE_TYPE_CODE
         ,SPLIT_FROM_LINE_ID
--       ,SUBINVENTORY
--       ,SUBMISSION_DATETIME
         ,TASK
         ,TASK_ID
--       ,TAX
         ,TAX_CODE
         ,TAX_DATE
         ,TAX_EXEMPT_FLAG
         ,TAX_EXEMPT_NUMBER
         ,TAX_EXEMPT_REASON
         ,TAX_EXEMPT_REASON_CODE
         ,TAX_POINT
         ,TAX_POINT_CODE
         ,TAX_RATE
         ,TAX_VALUE
         ,UNIT_LIST_PRICE
         ,UNIT_SELLING_PRICE
         ,VEH_CUS_ITEM_CUM_KEY_ID
         ,VISIBLE_DEMAND_FLAG
         ,split_from_line_ref
         ,split_from_shipment_ref
         ,SHIP_TO_EDI_LOCATION_CODE
         ,Service_Txn_Reason_Code
	 ,Service_Txn_Comments
	 ,Service_Duration
	 ,Service_Start_Date
	 ,Service_End_Date
	 ,Service_Coterminate_Flag
	 ,Service_Number
	 ,Service_Period
	 ,Service_Reference_Type_Code
	 ,Service_Reference_Line_Id
	 ,Service_Reference_System_Id
	 ,Credit_Invoice_Line_Id
	 ,Ship_to_Province
	 ,Invoice_Province
	 ,Bill_to_Edi_Location_Code
	 ,Invoice_City
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
         ,SHIP_TO_ADDRESS_ID
         ,SHIP_TO_ADDRESS_CODE
         ,service_reference_line
         ,service_reference_order
         ,service_reference_system
--       ,order_source
         ,customer_line_number
         ,CUSTOMER_ITEM_NET_PRICE --bug#5733732
         ,user_item_description
         ,acknowledgment_type
         ,blanket_number
         ,blanket_line_number
         ,original_inventory_item_id
	 ,original_ordered_item_id
	 ,original_ordered_item
	 ,original_item_identifier_type
         ,item_relationship_type
         ,error_flag
         ,customer_shipment_number
     -- { Distributer Order related change
        ,end_customer_id
        ,end_customer_contact_id
        ,end_customer_site_use_id
        ,ib_owner
        ,ib_current_location
        ,ib_installed_at_location
     -- Distributer Order related change }
        ,charge_periodicity_code
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
)
         VALUES
         (
          l_line_val_rec.ACCOUNTING_RULE
         , l_line_rec.ACCOUNTING_RULE_ID
         , l_line_rec.ACCOUNTING_RULE_DURATION
         , '' 		-- ACKNOWLEDGMENT_FLAG
         , l_line_rec.ACTUAL_ARRIVAL_DATE
         , l_line_rec.ACTUAL_SHIPMENT_DATE
         , l_line_val_rec.AGREEMENT
         , l_line_rec.AGREEMENT_ID
         , l_line_rec.ARRIVAL_SET_ID
--       , l_line_rec.ARRIVAL_SET_NAME
         , l_line_rec.ATO_LINE_ID
         , l_line_rec.ATTRIBUTE1
         , l_line_rec.ATTRIBUTE10
         , l_line_rec.ATTRIBUTE11
         , l_line_rec.ATTRIBUTE12
         , l_line_rec.ATTRIBUTE13
         , l_line_rec.ATTRIBUTE14
         , l_line_rec.ATTRIBUTE15
         , l_line_rec.ATTRIBUTE16    --For bug 2184255
         , l_line_rec.ATTRIBUTE17
         , l_line_rec.ATTRIBUTE18
         , l_line_rec.ATTRIBUTE19
         , l_line_rec.ATTRIBUTE2
         , l_line_rec.ATTRIBUTE20
         , l_line_rec.ATTRIBUTE3
         , l_line_rec.ATTRIBUTE4
         , l_line_rec.ATTRIBUTE5
         , l_line_rec.ATTRIBUTE6
         , l_line_rec.ATTRIBUTE7
         , l_line_rec.ATTRIBUTE8
         , l_line_rec.ATTRIBUTE9
         , l_line_rec.AUTHORIZED_TO_SHIP_FLAG
         , p_buyer_seller_flag
         , l_line_rec.BOOKED_FLAG
--       , l_line_rec.CALCULATE_PRICE_FLAG
         , l_line_rec.CANCELLED_FLAG
         , l_line_rec.CANCELLED_QUANTITY
         , ''	-- CHANGE_DATE
         , l_line_rec.CHANGE_SEQUENCE
--       , l_line_rec.CLOSED_FLAG
         , l_line_rec.COMPONENT_CODE
         , l_line_rec.COMPONENT_NUMBER
         , l_line_rec.COMPONENT_SEQUENCE_ID
         , l_line_rec.CONFIG_DISPLAY_SEQUENCE
--       , l_line_rec.CONFIG_LINE_REF
         , l_line_rec.CONFIGURATION_ID
         , l_line_rec.TOP_MODEL_LINE_ID
         , l_line_rec.CONTEXT
         , l_line_rec.CREATED_BY
         , l_line_rec.CREATION_DATE
         , l_line_rec.CUST_MODEL_SERIAL_NUMBER
         , l_line_rec.CUST_PO_NUMBER
         , l_line_rec.CUST_PRODUCTION_SEQ_NUM
         , l_line_rec.CUSTOMER_DOCK_CODE
         , decode ( l_line_rec.item_identifier_type ,'CUST', l_line_rec.ORDERED_ITEM,NULL) --bug8477822
         , decode ( l_line_rec.item_identifier_type ,'CUST', l_line_rec.ORDERED_ITEM_ID,NULL)  --bug8477822  -- CUSTOMER_ITEM_ID Added for bug 4404309
	 , l_line_rec.ORDERED_ITEM --bug8477822

--       , l_line_rec.CUSTOMER_ITEM_REVISION
         , l_line_rec.CUSTOMER_JOB
         , l_line_rec.CUSTOMER_PRODUCTION_LINE
         , l_line_rec.CUSTOMER_TRX_LINE_ID
--       , l_line_rec.DELIVER_TO_CONTACT
         , l_line_rec.DELIVER_TO_CONTACT_ID
         , l_line_val_rec.DELIVER_TO_ORG
         , l_line_rec.DELIVER_TO_ORG_ID
         , l_line_rec.DELIVERY_LEAD_TIME
         , l_line_val_rec.DEMAND_BUCKET_TYPE
         , l_line_rec.DEMAND_BUCKET_TYPE_CODE
--       , l_line_rec.DEMAND_CLASS
         , l_line_rec.DEMAND_CLASS_CODE
--       , l_line_rec.DEMAND_STREAM
         , l_line_rec.DEP_PLAN_REQUIRED_FLAG
         , l_line_rec.EARLIEST_ACCEPTABLE_DATE
         , l_line_rec.EXPLOSION_DATE
	 , l_line_rec.FIRST_ACK_CODE
	 , l_line_rec.FIRST_ACK_DATE
         , l_line_val_rec.FOB_POINT
         , l_line_rec.FOB_POINT_CODE
         , l_line_rec.FREIGHT_CARRIER_CODE
         , l_line_val_rec.FREIGHT_TERMS
         , l_line_rec.FREIGHT_TERMS_CODE
         , l_line_rec.FULFILLED_QUANTITY
--       , l_line_rec.FULFILLMENT_SET_ID
--       , l_line_rec.FULFILLMENT_SET_NAME
         , l_line_rec.GLOBAL_ATTRIBUTE_CATEGORY
         , l_line_rec.GLOBAL_ATTRIBUTE1
         , l_line_rec.GLOBAL_ATTRIBUTE10
         , l_line_rec.GLOBAL_ATTRIBUTE11
         , l_line_rec.GLOBAL_ATTRIBUTE12
         , l_line_rec.GLOBAL_ATTRIBUTE13
         , l_line_rec.GLOBAL_ATTRIBUTE14
         , l_line_rec.GLOBAL_ATTRIBUTE15
         , l_line_rec.GLOBAL_ATTRIBUTE16
         , l_line_rec.GLOBAL_ATTRIBUTE17
         , l_line_rec.GLOBAL_ATTRIBUTE18
         , l_line_rec.GLOBAL_ATTRIBUTE19
         , l_line_rec.GLOBAL_ATTRIBUTE2
         , l_line_rec.GLOBAL_ATTRIBUTE20
         , l_line_rec.GLOBAL_ATTRIBUTE3
         , l_line_rec.GLOBAL_ATTRIBUTE4
         , l_line_rec.GLOBAL_ATTRIBUTE5
         , l_line_rec.GLOBAL_ATTRIBUTE6
         , l_line_rec.GLOBAL_ATTRIBUTE7
         , l_line_rec.GLOBAL_ATTRIBUTE8
         , l_line_rec.GLOBAL_ATTRIBUTE9
         , l_line_rec.HEADER_ID
         , l_line_rec.INDUSTRY_ATTRIBUTE1
         , l_line_rec.INDUSTRY_ATTRIBUTE10
         , l_line_rec.INDUSTRY_ATTRIBUTE11
         , l_line_rec.INDUSTRY_ATTRIBUTE12
         , l_line_rec.INDUSTRY_ATTRIBUTE13
         , l_line_rec.INDUSTRY_ATTRIBUTE14
         , l_line_rec.INDUSTRY_ATTRIBUTE15
         , l_line_rec.INDUSTRY_ATTRIBUTE16
         , l_line_rec.INDUSTRY_ATTRIBUTE17
         , l_line_rec.INDUSTRY_ATTRIBUTE18
         , l_line_rec.INDUSTRY_ATTRIBUTE19
         , l_line_rec.INDUSTRY_ATTRIBUTE2
         , l_line_rec.INDUSTRY_ATTRIBUTE20
         , l_line_rec.INDUSTRY_ATTRIBUTE21
         , l_line_rec.INDUSTRY_ATTRIBUTE22
         , l_line_rec.INDUSTRY_ATTRIBUTE23
         , l_line_rec.INDUSTRY_ATTRIBUTE24
         , l_line_rec.INDUSTRY_ATTRIBUTE25
         , l_line_rec.INDUSTRY_ATTRIBUTE26
         , l_line_rec.INDUSTRY_ATTRIBUTE27
         , l_line_rec.INDUSTRY_ATTRIBUTE28
         , l_line_rec.INDUSTRY_ATTRIBUTE29
         , l_line_rec.INDUSTRY_ATTRIBUTE3
         , l_line_rec.INDUSTRY_ATTRIBUTE30
         , l_line_rec.INDUSTRY_ATTRIBUTE4
         , l_line_rec.INDUSTRY_ATTRIBUTE5
         , l_line_rec.INDUSTRY_ATTRIBUTE6
         , l_line_rec.INDUSTRY_ATTRIBUTE7
         , l_line_rec.INDUSTRY_ATTRIBUTE8
         , l_line_rec.INDUSTRY_ATTRIBUTE9
         , l_line_rec.INDUSTRY_CONTEXT
         , l_line_rec.TP_CONTEXT
         , l_line_rec.TP_ATTRIBUTE1
         , l_line_rec.TP_ATTRIBUTE2
         , l_line_rec.TP_ATTRIBUTE3
         , l_line_rec.TP_ATTRIBUTE4
         , l_line_rec.TP_ATTRIBUTE5
         , l_line_rec.TP_ATTRIBUTE6
         , l_line_rec.TP_ATTRIBUTE7
         , l_line_rec.TP_ATTRIBUTE8
         , l_line_rec.TP_ATTRIBUTE9
         , l_line_rec.TP_ATTRIBUTE10
         , l_line_rec.TP_ATTRIBUTE11
         , l_line_rec.TP_ATTRIBUTE12
         , l_line_rec.TP_ATTRIBUTE13
         , l_line_rec.TP_ATTRIBUTE14
         , l_line_rec.TP_ATTRIBUTE15
         , l_line_rec.INTERMED_SHIP_TO_CONTACT_ID
         , l_line_rec.INTERMED_SHIP_TO_ORG_ID
         , l_line_val_rec.INVENTORY_ITEM
         , l_line_rec.INVENTORY_ITEM_ID
--       , l_line_rec.INVOICE_COMPLETE_FLAG    11/03
--       , l_line_rec.INVOICE_SET_ID
--       , l_line_rec.INVOICE_SET_NAME
--       , l_line_rec.INVOICE_NUMBER
         , l_line_val_rec.INVOICE_TO_CONTACT
         , l_line_rec.INVOICE_TO_CONTACT_ID
         , l_line_val_rec.INVOICE_TO_ORG
         , l_line_rec.INVOICE_TO_ORG_ID
--       , ???().INVOICE_TOLERANCE_ABOVE
--       , ???().INVOICE_TOLERANCE_BELOW
         , l_line_val_rec.INVOICING_RULE
         , l_line_rec.INVOICING_RULE_ID
         , l_line_rec.ORDERED_ITEM
         , l_line_rec.ITEM_REVISION
         , l_line_rec.item_identifier_type             --ITEM_TYPE_CODE
	 , l_line_rec.LAST_ACK_CODE
	 , l_line_rec.LAST_ACK_DATE
         , l_line_rec.LAST_UPDATE_DATE
         , l_line_rec.LAST_UPDATE_LOGIN
         , l_line_rec.LAST_UPDATED_BY
         , l_line_rec.LATEST_ACCEPTABLE_DATE
         , l_line_rec.LINE_CATEGORY_CODE
         , l_line_rec.LINE_ID
         , l_line_rec.LINE_NUMBER
--       , l_line_rec.LINE_PO_CONTEXT
         , l_line_val_rec.LINE_TYPE
         , l_line_rec.LINE_TYPE_ID
         , l_line_rec.LINK_TO_LINE_ID
--       , l_line_rec.LINK_TO_LINE_REF
--       , ???().LOT
         , l_line_rec.MODEL_GROUP_NUMBER
         , l_line_rec.OPEN_FLAG
         , l_line_rec.OPERATION
         , l_line_rec.OPTION_FLAG
         , l_line_rec.OPTION_NUMBER
         , l_line_rec.ORDER_QUANTITY_UOM
         , l_line_rec.ORDER_SOURCE_ID
         , l_line_rec.ORDERED_QUANTITY
         , l_line_rec.ORG_ID
         , l_line_rec.ORIG_SYS_DOCUMENT_REF
         , l_line_rec.ORIG_SYS_LINE_REF
         , l_line_rec.ORIG_SYS_SHIPMENT_REF
         , l_line_rec.OVER_SHIP_REASON_CODE
         , l_line_rec.OVER_SHIP_RESOLVED_FLAG
         , l_line_val_rec.PAYMENT_TERM
         , l_line_rec.PAYMENT_TERM_ID
         , l_line_val_rec.PRICE_LIST
         , l_line_rec.PRICE_LIST_ID
         , l_line_rec.PRICING_ATTRIBUTE1
         , l_line_rec.PRICING_ATTRIBUTE10
         , l_line_rec.PRICING_ATTRIBUTE2
         , l_line_rec.PRICING_ATTRIBUTE3
         , l_line_rec.PRICING_ATTRIBUTE4
         , l_line_rec.PRICING_ATTRIBUTE5
         , l_line_rec.PRICING_ATTRIBUTE6
         , l_line_rec.PRICING_ATTRIBUTE7
         , l_line_rec.PRICING_ATTRIBUTE8
         , l_line_rec.PRICING_ATTRIBUTE9
         , l_line_rec.PRICING_CONTEXT
         , l_line_rec.PRICING_DATE
         , l_line_rec.PRICING_QUANTITY
         , l_line_rec.PRICING_QUANTITY_UOM
--       , ???().PROGRAM
--       , ???().PROGRAM_APPLICATION
         , l_line_rec.PROGRAM_APPLICATION_ID
         , l_line_rec.PROGRAM_ID
         , l_line_rec.PROGRAM_UPDATE_DATE
         , l_line_val_rec.PROJECT
         , l_line_rec.PROJECT_ID
         , l_line_rec.PROMISE_DATE
--       , l_line_rec.REFERENCE_HEADER
         , l_line_rec.REFERENCE_HEADER_ID
--       , l_line_rec.REFERENCE_LINE
         , l_line_rec.REFERENCE_LINE_ID
         , l_line_rec.REFERENCE_TYPE
         , l_line_rec.REQUEST_DATE
         , l_line_rec.REQUEST_ID
         , l_line_rec.RESERVED_QUANTITY
         , l_line_rec.RETURN_ATTRIBUTE1
         , l_line_rec.RETURN_ATTRIBUTE10
         , l_line_rec.RETURN_ATTRIBUTE11
         , l_line_rec.RETURN_ATTRIBUTE12
         , l_line_rec.RETURN_ATTRIBUTE13
         , l_line_rec.RETURN_ATTRIBUTE14
         , l_line_rec.RETURN_ATTRIBUTE15
         , l_line_rec.RETURN_ATTRIBUTE2
         , l_line_rec.RETURN_ATTRIBUTE3
         , l_line_rec.RETURN_ATTRIBUTE4
         , l_line_rec.RETURN_ATTRIBUTE5
         , l_line_rec.RETURN_ATTRIBUTE6
         , l_line_rec.RETURN_ATTRIBUTE7
         , l_line_rec.RETURN_ATTRIBUTE8
         , l_line_rec.RETURN_ATTRIBUTE9
         , l_line_rec.RETURN_CONTEXT
         , l_line_rec.RETURN_REASON_CODE
         , l_line_rec.RLA_SCHEDULE_TYPE_CODE
         , l_line_rec.SALESREP_ID
         , l_line_val_rec.SALESREP
         , l_line_rec.SCHEDULE_ARRIVAL_DATE
         , l_line_rec.SCHEDULE_SHIP_DATE
--       , l_line_rec.SCHEDULE_ITEM_DETAIL
         , l_line_rec.SCHEDULE_STATUS_CODE
         , l_line_val_rec.SHIP_FROM_ORG
         , l_line_rec.SHIP_FROM_ORG_ID
         , l_line_rec.SHIP_MODEL_COMPLETE_FLAG
         , l_line_rec.SHIP_SET_ID
--       , l_line_rec.SHIP_SET_NAME
         , l_line_val_rec.SHIP_TO_ADDRESS1
         , l_line_val_rec.SHIP_TO_ADDRESS2
         , l_line_val_rec.SHIP_TO_ADDRESS3
         , l_line_val_rec.SHIP_TO_ADDRESS4
       , l_line_val_rec.SHIP_TO_CITY
         , l_line_val_rec.SHIP_TO_CONTACT
--       , l_line_rec.SHIP_TO_CONTACT_AREA_CODE1
--       , l_line_rec.SHIP_TO_CONTACT_AREA_CODE2
--       , l_line_rec.SHIP_TO_CONTACT_AREA_CODE3
       , l_line_val_rec.SHIP_TO_CONTACT_FIRST_NAME
         , l_line_rec.SHIP_TO_CONTACT_ID
--       , l_line_rec.SHIP_TO_CONTACT_JOB_TITLE
       , l_line_val_rec.SHIP_TO_CONTACT_LAST_NAME
       , l_line_val_rec.SHIP_TO_COUNTRY
       , l_line_val_rec.SHIP_TO_COUNTY
         , l_line_val_rec.SHIP_TO_ORG
         , l_line_rec.SHIP_TO_ORG_ID
       , l_line_val_rec.SHIP_TO_zip
       , l_line_val_rec.SHIP_TO_STATE
         , l_line_rec.SHIP_TOLERANCE_ABOVE
         , l_line_rec.SHIP_TOLERANCE_BELOW
         , l_line_rec.SHIPMENT_NUMBER
         , l_line_val_rec.SHIPMENT_PRIORITY
         , l_line_rec.SHIPMENT_PRIORITY_CODE
         , l_line_rec.SHIPPED_QUANTITY
--       , l_line_rec.SHIPPING_METHOD
         , l_line_rec.SHIPPING_METHOD_CODE
         , l_line_rec.SHIPPING_QUANTITY
         , l_line_rec.SHIPPING_QUANTITY_UOM
--       , ???().SOLD_FROM_ORG
--       , ???().SOLD_FROM_ORG_ID
         , l_line_val_rec.SOLD_TO_ORG
         , l_line_rec.SOLD_TO_ORG_ID
         , l_line_rec.SORT_ORDER
         , l_line_rec.SOURCE_DOCUMENT_ID
         , l_line_rec.SOURCE_DOCUMENT_LINE_ID
         , l_line_rec.SOURCE_DOCUMENT_TYPE_ID
         , l_line_rec.SOURCE_TYPE_CODE
         , l_line_rec.SPLIT_FROM_LINE_ID
--       , ???.SUBINVENTORY
--       , ???.SUBMISSION_DATETIME
         , l_line_val_rec.TASK
         , l_line_rec.TASK_ID
--       , l_line_rec.TAX
         , l_line_rec.TAX_CODE
         , l_line_rec.TAX_DATE
         , l_line_rec.TAX_EXEMPT_FLAG
         , l_line_rec.TAX_EXEMPT_NUMBER
         , l_line_val_rec.TAX_EXEMPT_REASON
         , l_line_rec.TAX_EXEMPT_REASON_CODE
         , l_line_val_rec.TAX_POINT
         , l_line_rec.TAX_POINT_CODE
         , l_line_rec.TAX_RATE
         , l_line_rec.TAX_VALUE
         , l_line_rec.UNIT_LIST_PRICE
         , l_line_rec.UNIT_SELLING_PRICE
         , l_line_rec.VEH_CUS_ITEM_CUM_KEY_ID
         , l_line_rec.VISIBLE_DEMAND_FLAG
         , l_line_rec.split_from_line_ref
         , l_line_rec.split_from_shipment_ref
         , l_line_rec.SHIP_TO_EDI_LOCATION_CODE
	 , l_line_rec.Service_Txn_Reason_Code
	 , l_line_rec.Service_Txn_Comments
	 , l_line_rec.Service_Duration
	 , l_line_rec.Service_Start_Date
	 , l_line_rec.Service_End_Date
	 , l_line_rec.Service_Coterminate_Flag
	 , l_line_rec.Service_Number
	 , l_line_rec.Service_Period
	 , l_line_rec.Service_Reference_Type_Code
	 , l_line_rec.Service_Reference_Line_Id
	 , l_line_rec.Service_Reference_System_Id
	 , l_line_rec.Credit_Invoice_Line_Id
	 , l_line_val_rec.Ship_to_Province
	 , l_line_val_rec.Invoice_to_Province
	 , l_line_rec.Bill_to_Edi_Location_Code
	 , l_line_val_rec.Invoice_To_City
         , l_line_rec.ship_from_edi_location_code
         , l_line_val_rec.SHIP_FROM_ADDRESS1
         , l_line_val_rec.SHIP_FROM_ADDRESS2
         , l_line_val_rec.SHIP_FROM_ADDRESS3
         , l_line_val_rec.SHIP_FROM_CITY
         , l_line_val_rec.SHIP_FROM_POSTAL_CODE
         , l_line_val_rec.SHIP_FROM_COUNTRY
        , l_line_val_rec.SHIP_FROM_REGION1
         , l_line_val_rec.SHIP_FROM_REGION2
         , l_line_val_rec.SHIP_FROM_REGION3
         , l_line_rec.SHIP_FROM_ADDRESS_ID
         , l_line_rec.SHIP_TO_ADDRESS_ID
         , l_line_val_rec.SHIP_TO_LOCATION
         , l_line_rec.service_reference_line
         , l_line_rec.service_reference_order
         , l_line_rec.service_reference_system
--         , l_line_val_rec.order_source
         , l_line_rec.customer_line_number
         , l_line_rec.CUSTOMER_ITEM_NET_PRICE --bug#5733732
         , l_line_rec.user_item_description
         , p_ack_type
         , l_line_rec.blanket_number
         , l_line_rec.blanket_line_number
         , l_line_rec.original_inventory_item_id
	 , l_line_rec.original_ordered_item_id
	 , l_line_rec.original_ordered_item
	 , l_line_rec.original_item_identifier_type
         , l_line_rec.item_relationship_type
         , l_error_flag
         , l_line_rec.customer_shipment_number
         -- { Distributer Order related change
        , l_line_rec.end_customer_id
        , l_line_rec.end_customer_contact_id
        , l_line_rec.end_customer_site_use_id
        , l_line_rec.ib_owner
        , l_line_rec.ib_current_location
        , l_line_rec.ib_installed_at_location
         -- Distributer Order related change }
        , l_line_rec.charge_periodicity_code
	,l_line_val_rec.end_customer_name
        ,l_line_val_rec.end_customer_number
        ,l_line_val_rec.end_customer_contact
        ,l_line_val_rec.end_customer_site_address1
        ,l_line_val_rec.end_customer_site_address2
        ,l_line_val_rec.end_customer_site_address3
        ,l_line_val_rec.end_customer_site_address4
        ,l_line_val_rec.end_customer_site_city
        ,l_line_val_rec.end_customer_site_state
        ,l_line_val_rec.end_customer_site_postal_code
        ,l_line_val_rec.end_customer_site_country
         );
      ELSE
        oe_debug_pub.add('Incomplete data for inserting line ack rec');
      END IF;
     <<nextline>>
     I := p_line_tbl.NEXT(I);
     END LOOP;

EXCEPTION

    WHEN OTHERS THEN

        oe_debug_pub.Add('Encountered Others Error Exception in OE_Line_Ack_Util.Insert_Row: '||sqlerrm);

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME, 'OE_Line_Ack_Util.Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;


Procedure Extend_Line_Rec
 (p_line_rec           In Out Nocopy OE_Update_Ack_Util.Line_Rec_Type,
  p_count              In Number)

Is

  l_debug_level        CONSTANT NUMBER := oe_debug_pub.g_debug_level;

Begin
  oe_debug_pub.add('Entering Extend_Line_Rec');

  p_line_rec.line_id.extend(p_count);
  p_line_rec.header_id.extend(p_count);
  p_line_rec.ship_to_org_id.extend(p_count);
  p_line_rec.invoice_to_org_id.extend(p_count);
  p_line_rec.invoice_to_contact_id.extend(p_count);
  p_line_rec.ship_from_org_id.extend(p_count);
  p_line_rec.agreement_id.extend(p_count);
  p_line_rec.price_list_id.extend(p_count);
  p_line_rec.arrival_set_id.extend(p_count);
  p_line_rec.accounting_rule_id.extend(p_count);
  p_line_rec.fulfillment_set_id.extend(p_count);
  p_line_rec.inventory_item.extend(p_count);   --added for bug4309609
  p_line_rec.inventory_item_id.extend(p_count);
  p_line_rec.invoicing_rule_id.extend(p_count);
  p_line_rec.line_type_id.extend(p_count);
  p_line_rec.order_source_id.extend(p_count);
  p_line_rec.payment_term_id.extend(p_count);
  p_line_rec.project_id.extend(p_count);
  p_line_rec.salesrep_id.extend(p_count);
  p_line_rec.ship_set_id.extend(p_count);
  p_line_rec.ship_to_contact_id.extend(p_count);
  p_line_rec.task_id.extend(p_count);
  p_line_rec.fob_point_code.extend(p_count);
  p_line_rec.freight_terms_code.extend(p_count);
  p_line_rec.shipping_method_code.extend(p_count);
  p_line_rec.tax_code.extend(p_count);
  p_line_rec.tax_point_code.extend(p_count);
  p_line_rec.tax_exempt_reason_code.extend(p_count);
  p_line_rec.first_ack_code.extend(p_count);

  p_line_rec.accounting_rule_duration.extend(p_count);
  p_line_rec.actual_arrival_date.extend(p_count);
  p_line_rec.actual_shipment_date.extend(p_count);
  p_line_rec.ato_line_id.extend(p_count);
  p_line_rec.authorized_to_ship_flag.extend(p_count);
  p_line_rec.booked_flag.extend(p_count);
  p_line_rec.cancelled_flag.extend(p_count);
  p_line_rec.cancelled_quantity.extend(p_count);
  p_line_rec.change_sequence.extend(p_count);
  p_line_rec.component_code.extend(p_count);
  p_line_rec.component_number.extend(p_count);
  p_line_rec.component_sequence_id.extend(p_count);
  p_line_rec.config_display_sequence.extend(p_count);
  p_line_rec.configuration_id.extend(p_count);
  p_line_rec.top_model_line_id.extend(p_count);
  p_line_rec.created_by.extend(p_count);
  p_line_rec.creation_date.extend(p_count);
  p_line_rec.cust_model_serial_number.extend(p_count);
  p_line_rec.cust_po_number.extend(p_count);
  p_line_rec.cust_production_seq_num.extend(p_count);
  p_line_rec.customer_dock_code.extend(p_count);
  p_line_rec.ordered_item.extend(p_count);
  p_line_rec.ordered_item_id.extend(p_count); /* Bug # 4761560 */
  p_line_rec.customer_job.extend(p_count);
  p_line_rec.customer_production_line.extend(p_count);
  p_line_rec.customer_trx_line_id.extend(p_count);
  p_line_rec.deliver_to_contact_id.extend(p_count);
  p_line_rec.deliver_to_org_id.extend(p_count);
  p_line_rec.delivery_lead_time.extend(p_count);
  p_line_rec.demand_bucket_type_code.extend(p_count);
  p_line_rec.demand_class_code.extend(p_count);
  p_line_rec.dep_plan_required_flag.extend(p_count);
  p_line_rec.earliest_acceptable_date.extend(p_count);
  p_line_rec.explosion_date.extend(p_count);
  p_line_rec.freight_carrier_code.extend(p_count);
  p_line_rec.fulfilled_quantity.extend(p_count);
  p_line_rec.item_revision.extend(p_count);
  p_line_rec.item_identifier_type.extend(p_count);
  p_line_rec.context.extend(p_count);
  p_line_rec.first_ack_date.extend(p_count);
  p_line_rec.last_ack_code.extend(p_count);
  p_line_rec.last_ack_date.extend(p_count);

  p_line_rec.last_update_date.extend(p_count);
  p_line_rec.last_update_login.extend(p_count);
  p_line_rec.last_updated_by.extend(p_count);
  p_line_rec.latest_acceptable_date.extend(p_count);
  p_line_rec.line_category_code.extend(p_count);
  p_line_rec.line_number.extend(p_count);
  p_line_rec.link_to_line_id.extend(p_count);
  p_line_rec.model_group_number.extend(p_count);
  p_line_rec.open_flag.extend(p_count);
  p_line_rec.operation_code.extend(p_count);
  p_line_rec.option_flag.extend(p_count);
  p_line_rec.option_number.extend(p_count);
  p_line_rec.order_quantity_uom.extend(p_count);
  p_line_rec.ordered_quantity.extend(p_count);
  p_line_rec.org_id.extend(p_count);
  p_line_rec.orig_sys_document_ref.extend(p_count);
  p_line_rec.orig_sys_line_ref.extend(p_count);
  p_line_rec.orig_sys_shipment_ref.extend(p_count);
  p_line_rec.over_ship_reason_code.extend(p_count);
  p_line_rec.over_ship_resolved_flag.extend(p_count);
  p_line_rec.pricing_date.extend(p_count);
  p_line_rec.pricing_quantity.extend(p_count);
  p_line_rec.pricing_quantity_uom.extend(p_count);
  p_line_rec.program_application_id.extend(p_count);
  p_line_rec.program_id.extend(p_count);
  p_line_rec.program_update_date.extend(p_count);
  p_line_rec.promise_date.extend(p_count);
  p_line_rec.reference_header_id.extend(p_count);
  p_line_rec.reference_line_id.extend(p_count);
  p_line_rec.reference_type.extend(p_count);
  p_line_rec.request_date.extend(p_count);
  p_line_rec.request_id.extend(p_count);
  p_line_rec.reserved_quantity.extend(p_count);
  p_line_rec.return_reason_code.extend(p_count);
  p_line_rec.rla_schedule_type_code.extend(p_count);
  p_line_rec.schedule_arrival_date.extend(p_count);
  p_line_rec.schedule_ship_date.extend(p_count);
  p_line_rec.schedule_status_code.extend(p_count);
  p_line_rec.ship_model_complete_flag.extend(p_count);
  p_line_rec.ship_tolerance_above.extend(p_count);
  p_line_rec.ship_tolerance_below.extend(p_count);
  p_line_rec.shipment_number.extend(p_count);
  p_line_rec.shipment_priority_code.extend(p_count);
  p_line_rec.shipped_quantity.extend(p_count);
  p_line_rec.SHIPPING_METHOD_CODE.extend(p_count);
  p_line_rec.SHIPPING_QUANTITY.extend(p_count);
  p_line_rec.SHIPPING_QUANTITY_UOM.extend(p_count);
  p_line_rec.SOLD_TO_ORG_ID.extend(p_count);
  p_line_rec.SORT_ORDER.extend(p_count);
  p_line_rec.SOURCE_DOCUMENT_ID.extend(p_count);
  p_line_rec.SOURCE_DOCUMENT_LINE_ID.extend(p_count);
  p_line_rec.SOURCE_DOCUMENT_TYPE_ID.extend(p_count);
  p_line_rec.SOURCE_TYPE_CODE.extend(p_count);
  p_line_rec.SPLIT_FROM_LINE_ID.extend(p_count);
  p_line_rec.TAX_CODE.extend(p_count);
  p_line_rec.TAX_DATE.extend(p_count);
  p_line_rec.TAX_EXEMPT_FLAG.extend(p_count);
  p_line_rec.TAX_EXEMPT_NUMBER.extend(p_count);
  p_line_rec.TAX_EXEMPT_REASON_CODE.extend(p_count);
  p_line_rec.TAX_POINT_CODE.extend(p_count);
  p_line_rec.TAX_RATE.extend(p_count);
  p_line_rec.TAX_VALUE.extend(p_count);
  p_line_rec.UNIT_LIST_PRICE.extend(p_count);
  p_line_rec.UNIT_SELLING_PRICE.extend(p_count);
  p_line_rec.VEH_CUS_ITEM_CUM_KEY_ID.extend(p_count);
  p_line_rec.VISIBLE_DEMAND_FLAG.extend(p_count);
  p_line_rec.split_from_line_ref.extend(p_count);
  p_line_rec.split_from_shipment_ref.extend(p_count);
  p_line_rec.Service_Txn_Reason_Code.extend(p_count);
  p_line_rec.Service_Txn_Comments.extend(p_count);
  p_line_rec.Service_Duration.extend(p_count);
  p_line_rec.Service_Start_Date.extend(p_count);
  p_line_rec.Service_End_Date.extend(p_count);
  p_line_rec.Service_Coterminate_Flag.extend(p_count);
  p_line_rec.Service_Number.extend(p_count);
  p_line_rec.Service_Period.extend(p_count);
  p_line_rec.Service_Reference_Type_Code.extend(p_count);
  p_line_rec.service_Reference_Line_Id.extend(p_count);
  p_line_rec.Service_Reference_System_Id.extend(p_count);
  p_line_rec.Credit_Invoice_Line_Id.extend(p_count);
  p_line_rec.service_reference_line.extend(p_count);
  p_line_rec.service_reference_order.extend(p_count);
  p_line_rec.service_reference_system.extend(p_count);
  p_line_rec.customer_line_number.extend(p_count);
  p_line_rec.user_item_description.extend(p_count);
  p_line_rec.acknowledgment_type.extend(p_count);
  p_line_rec.blanket_number.extend(p_count);
  p_line_rec.blanket_line_number.extend(p_count);
  p_line_rec.original_inventory_item_id.extend(p_count);
  p_line_rec.original_ordered_item_id.extend(p_count);
  p_line_rec.original_ordered_item.extend(p_count);
  p_line_rec.original_item_identifier_type.extend(p_count);
  p_line_rec.item_relationship_type.extend(p_count);
  p_line_rec.attribute1.extend(p_count);
  p_line_rec.attribute10.extend(p_count);
 p_line_rec.attribute11.extend(p_count);
 p_line_rec.attribute12.extend(p_count);
 p_line_rec.attribute13.extend(p_count);
 p_line_rec.attribute14.extend(p_count);
 p_line_rec.attribute15.extend(p_count);
 p_line_rec.attribute16.extend(p_count);
 p_line_rec.attribute17.extend(p_count);
 p_line_rec.attribute18.extend(p_count);
 p_line_rec.attribute19.extend(p_count);
 p_line_rec.attribute2.extend(p_count);
 p_line_rec.attribute20.extend(p_count);
 p_line_rec.attribute3.extend(p_count);
 p_line_rec.attribute4.extend(p_count);
 p_line_rec.attribute5.extend(p_count);
 p_line_rec.attribute6.extend(p_count);
 p_line_rec.attribute7.extend(p_count);
 p_line_rec.attribute8.extend(p_count);
 p_line_rec.attribute9.extend(p_count);
 p_line_rec.global_attribute1.extend(p_count);
 p_line_rec.global_attribute10.extend(p_count);
 p_line_rec.global_attribute11.extend(p_count);
 p_line_rec.global_attribute12.extend(p_count);
 p_line_rec.global_attribute13.extend(p_count);
 p_line_rec.global_attribute14.extend(p_count);
 p_line_rec.global_attribute15.extend(p_count);
 p_line_rec.global_attribute16.extend(p_count);
 p_line_rec.global_attribute17.extend(p_count);
 p_line_rec.global_attribute18.extend(p_count);
 p_line_rec.global_attribute19.extend(p_count);
 p_line_rec.global_attribute2.extend(p_count);
 p_line_rec.global_attribute20.extend(p_count);
 p_line_rec.global_attribute3.extend(p_count);
 p_line_rec.global_attribute4.extend(p_count);
 p_line_rec.global_attribute5.extend(p_count);
 p_line_rec.global_attribute6.extend(p_count);
 p_line_rec.global_attribute7.extend(p_count);
 p_line_rec.global_attribute8.extend(p_count);
 p_line_rec.global_attribute9.extend(p_count);
 p_line_rec.global_attribute_category.extend(p_count);
 p_line_rec.industry_attribute1.extend(p_count);
 p_line_rec.industry_attribute10.extend(p_count);
 p_line_rec.industry_attribute11.extend(p_count);
 p_line_rec.industry_attribute12.extend(p_count);
 p_line_rec.industry_attribute13.extend(p_count);
 p_line_rec.industry_attribute14.extend(p_count);
 p_line_rec.industry_attribute15.extend(p_count);
 p_line_rec.industry_attribute16.extend(p_count);
 p_line_rec.industry_attribute17.extend(p_count);
 p_line_rec.industry_attribute18.extend(p_count);
 p_line_rec.industry_attribute19.extend(p_count);
 p_line_rec.industry_attribute20.extend(p_count);
 p_line_rec.industry_attribute21.extend(p_count);
 p_line_rec.industry_attribute22.extend(p_count);
 p_line_rec.industry_attribute23.extend(p_count);
 p_line_rec.industry_attribute24.extend(p_count);
 p_line_rec.industry_attribute25.extend(p_count);
 p_line_rec.industry_attribute26.extend(p_count);
 p_line_rec.industry_attribute27.extend(p_count);
 p_line_rec.industry_attribute28.extend(p_count);
 p_line_rec.industry_attribute29.extend(p_count);
 p_line_rec.industry_attribute30.extend(p_count);
 p_line_rec.industry_attribute2.extend(p_count);
 p_line_rec.industry_attribute3.extend(p_count);
 p_line_rec.industry_attribute4.extend(p_count);
 p_line_rec.industry_attribute5.extend(p_count);
 p_line_rec.industry_attribute6.extend(p_count);
 p_line_rec.industry_attribute7.extend(p_count);
 p_line_rec.industry_attribute8.extend(p_count);
 p_line_rec.industry_attribute9.extend(p_count);
 p_line_rec.industry_context.extend(p_count);
 p_line_rec.TP_CONTEXT.extend(p_count);
 p_line_rec.TP_ATTRIBUTE1.extend(p_count);
 p_line_rec.TP_ATTRIBUTE2.extend(p_count);
 p_line_rec.TP_ATTRIBUTE3.extend(p_count);
 p_line_rec.TP_ATTRIBUTE4.extend(p_count);
 p_line_rec.TP_ATTRIBUTE5.extend(p_count);
 p_line_rec.TP_ATTRIBUTE6.extend(p_count);
 p_line_rec.TP_ATTRIBUTE7.extend(p_count);
 p_line_rec.TP_ATTRIBUTE8.extend(p_count);
 p_line_rec.TP_ATTRIBUTE9.extend(p_count);
 p_line_rec.TP_ATTRIBUTE10.extend(p_count);
 p_line_rec.TP_ATTRIBUTE11.extend(p_count);
 p_line_rec.TP_ATTRIBUTE12.extend(p_count);
 p_line_rec.TP_ATTRIBUTE13.extend(p_count);
 p_line_rec.TP_ATTRIBUTE14.extend(p_count);
 p_line_rec.TP_ATTRIBUTE15.extend(p_count);
 p_line_rec.pricing_attribute1.extend(p_count);
 p_line_rec.pricing_attribute10.extend(p_count);
 p_line_rec.pricing_attribute2.extend(p_count);
 p_line_rec.pricing_attribute3.extend(p_count);
 p_line_rec.pricing_attribute4.extend(p_count);
 p_line_rec.pricing_attribute5.extend(p_count);
 p_line_rec.pricing_attribute6.extend(p_count);
 p_line_rec.pricing_attribute7.extend(p_count);
 p_line_rec.pricing_attribute8.extend(p_count);
 p_line_rec.pricing_attribute9.extend(p_count);
 p_line_rec.pricing_context.extend(p_count);
 p_line_rec.return_attribute1.extend(p_count);
 p_line_rec.return_attribute10.extend(p_count);
 p_line_rec.return_attribute11.extend(p_count);
 p_line_rec.return_attribute12.extend(p_count);
 p_line_rec.return_attribute13.extend(p_count);
 p_line_rec.return_attribute14.extend(p_count);
 p_line_rec.return_attribute15.extend(p_count);
 p_line_rec.return_attribute2.extend(p_count);
 p_line_rec.return_attribute3.extend(p_count);
 p_line_rec.return_attribute4.extend(p_count);
 p_line_rec.return_attribute5.extend(p_count);
 p_line_rec.return_attribute6.extend(p_count);
 p_line_rec.return_attribute7.extend(p_count);
 p_line_rec.return_attribute8.extend(p_count);
 p_line_rec.return_attribute9.extend(p_count);
 p_line_rec.return_context.extend(p_count);
 p_line_rec.customer_shipment_number.extend(p_count);
-- { Distributer Order related change
 p_line_rec.end_customer_id.extend(p_count);
 p_line_rec.end_customer_contact_id.extend(p_count);
 p_line_rec.end_customer_site_use_id.extend(p_count);
 p_line_rec.ib_owner.extend(p_count);
 p_line_rec.ib_current_location.extend(p_count);
 p_line_rec.ib_installed_at_location.extend(p_count);
-- Distributer Order related change }
 p_line_rec.charge_periodicity_code.extend(p_count);

  oe_debug_pub.add('Exiting Extend_Line_Rec');

Exception
  When Others Then
    If l_debug_level > 0 Then
      Oe_Debug_Pub.Add('When Others in Extend_Line_Rec');
      Oe_Debug_Pub.Add('Error: '||sqlerrm);
    End If;

End Extend_Line_Rec;


Procedure Insert_Row
( p_line_tbl             In  OE_Order_Pub.Line_Tbl_Type,
  p_old_line_tbl         In  OE_Order_Pub.Line_Tbl_Type,
  x_return_status        Out NOCOPY /* file.sql.39 change */ Varchar2
)

Is

  l_line_tbl            OE_Order_Pub.Line_Tbl_Type := p_line_tbl;
  l_line_acks_rec       OE_Update_Ack_Util.Line_Rec_Type;
  l_count               Number;
  i                     Pls_Integer;
  k                     Pls_Integer := 0;
  l_ack_type            Varchar2(30);
  l_validation_org_id   number; -- bug 4309609
Begin

  l_count     := l_line_tbl.Count;
  i           := l_line_tbl.First;

  While i Is Not Null Loop
    If (nvl(l_line_tbl(i).FIRST_ACK_CODE, ' ')= ' ' OR
        l_line_tbl(i).FIRST_ACK_CODE = FND_API.G_MISS_CHAR) Then
      -- Trans is 855
      --l_ack_type := '855'; for bug4730258
      If l_line_tbl(i).schedule_ship_date Is Null Then
        l_line_tbl(i).first_ack_code := 'SP';
      End If;
      If l_line_tbl(i).schedule_ship_date Is Not Null And
         trunc (l_line_tbl(i).schedule_ship_date) <> nvl(trunc (l_line_tbl(i).Request_date),FND_API.G_MISS_DATE) Then
        l_line_tbl(i).first_ack_code := 'DR';
      End If;
      If l_line_tbl(i).ordered_quantity <> p_old_line_tbl(i).ordered_quantity Then
        If l_line_tbl(i).first_ack_code Is Null Or
           l_line_tbl(i).first_ack_code = FND_API.G_MISS_CHAR Then
          l_line_tbl(i).first_ack_code := 'IQ';
        Else
          l_line_tbl(i).first_ack_code := 'IC';
        End If;
      End If;
      -- Added for bug 4771523 start
      If l_line_tbl(i).unit_selling_price <> p_old_line_tbl(i).unit_selling_price Then
        l_line_tbl(i).first_ack_code := 'IP';
      End If;
      IF OE_ORDER_UTIL.g_line_tbl(I).customer_item_net_price IS NOT NULL
      AND OE_ORDER_UTIL.g_line_tbl(I).customer_item_net_price <> FND_API.G_MISS_NUM THEN
         oe_debug_pub.add(' Global Unit_Selling_Price : '||OE_ORDER_UTIL.g_line_tbl(I).unit_selling_price,5);
         oe_debug_pub.add(' Global CUSTOMER_ITEM_NET_PRICE : '||OE_ORDER_UTIL.g_line_tbl(I).CUSTOMER_ITEM_NET_PRICE,5);
         IF OE_ORDER_UTIL.g_line_tbl(I).customer_item_net_price <> OE_ORDER_UTIL.g_line_tbl(I).unit_selling_price THEN
           l_line_tbl(i).FIRST_ACK_CODE := 'IP';
           oe_debug_pub.add(' ack code: price changed : '||l_line_tbl(i).FIRST_ACK_CODE,5);
         END IF;
         oe_debug_pub.add(' new unit selling price: ' || l_line_tbl(i).unit_selling_price,5);
         oe_debug_pub.add(' old unit selling price: ' || p_old_line_tbl(i).unit_selling_price,5);
      END IF;
      -- Added for bug 4771523 end


      If l_line_tbl(i).ORIGINAL_INVENTORY_ITEM_ID is NOT NULL Then
        If (l_line_tbl(i).ITEM_RELATIONSHIP_TYPE Is Null
          OR l_line_tbl(i).ITEM_RELATIONSHIP_TYPE = 2
          OR l_line_tbl(i).ITEM_RELATIONSHIP_TYPE = 4
          OR l_line_tbl(i).ITEM_RELATIONSHIP_TYPE = 8
          OR l_line_tbl(i).ITEM_RELATIONSHIP_TYPE = 14) Then
          If l_line_tbl(i).FIRST_ACK_CODE Is Null Or
             l_line_tbl(i).FIRST_ACK_CODE = FND_API.G_MISS_CHAR Then
            l_line_tbl(i).FIRST_ACK_CODE := 'IS';
          Else
            l_line_tbl(i).FIRST_ACK_CODE := 'IC';
          End If;
        Else
          If l_line_tbl(i).FIRST_ACK_CODE Is Null Or
             l_line_tbl(i).FIRST_ACK_CODE = FND_API.G_MISS_CHAR Then
            l_line_tbl(i).FIRST_ACK_CODE := 'IA';
          End If;
        End If;
      End If;

      If l_line_tbl(i).SPLIT_FROM_LINE_ID Is Not Null  And
         l_line_tbl(i).split_by = 'SYSTEM' Then
        l_line_tbl(i).FIRST_ACK_CODE := 'IB';
      End If;

      If l_line_tbl(i).OPEN_FLAG = 'N'  Then
        l_line_tbl(i).FIRST_ACK_CODE := 'ID';
      End If;

      If l_line_tbl(i).FIRST_ACK_CODE Is Null Or
         l_line_tbl(i).FIRST_ACK_CODE = FND_API.G_MISS_CHAR Then
        l_line_tbl(i).FIRST_ACK_CODE := 'IA';
      Elsif l_line_tbl(i).FIRST_ACK_CODE Is Not Null Then
        Update_Header_Ack_Code (l_line_tbl(i).header_id, 'AC', NULL);
      End If;
      l_line_tbl(i).FIRST_ACK_DATE := '';
      l_line_tbl(i).LAST_ACK_CODE  := '';
      l_line_tbl(i).LAST_ACK_DATE  := '';

    Else -- 865
      IF l_line_tbl(i).changed_lines_pocao = 'N' THEN
        GOTO nextline;
      End If;
      --l_ack_type := '865'; for bug4730258
      l_line_tbl(i).FIRST_ACK_DATE := p_old_line_tbl(I).FIRST_ACK_DATE;
      If l_line_tbl(i).SCHEDULE_SHIP_DATE Is Null Then
        l_line_tbl(i).LAST_ACK_CODE := 'SP';
      End If;
      If l_line_tbl(i).SCHEDULE_SHIP_DATE Is Not Null And
         l_line_tbl(i).schedule_ship_date <> nvl(p_old_line_tbl(I).schedule_ship_date,FND_API.G_MISS_DATE) And
         l_line_tbl(i).schedule_ship_date <> nvl(l_line_tbl(i).REQUEST_DATE, FND_API.G_MISS_DATE) Then
        l_line_tbl(i).LAST_ACK_CODE := 'DR';
      End If;

      -- Added for bug 4771523
      If l_line_tbl(i).unit_selling_price <> p_old_line_tbl(i).unit_selling_price Then
        l_line_tbl(i).LAST_ACK_CODE := 'IP';
      End If;
      IF OE_ORDER_UTIL.g_line_tbl(I).customer_item_net_price IS NOT NULL
      AND OE_ORDER_UTIL.g_line_tbl(I).customer_item_net_price <> FND_API.G_MISS_NUM THEN
         oe_debug_pub.add(' Global Unit_Selling_Price : '||OE_ORDER_UTIL.g_line_tbl(I).unit_selling_price,5);
         oe_debug_pub.add(' Global CUSTOMER_ITEM_NET_PRICE : '||OE_ORDER_UTIL.g_line_tbl(I).CUSTOMER_ITEM_NET_PRICE,5);
         IF OE_ORDER_UTIL.g_line_tbl(I).customer_item_net_price <> OE_ORDER_UTIL.g_line_tbl(I).unit_selling_price THEN
           l_line_tbl(i).LAST_ACK_CODE := 'IP';
           oe_debug_pub.add(' ack code: price changed : '||l_line_tbl(i).FIRST_ACK_CODE,5);
         END IF;
         oe_debug_pub.add(' new unit selling price: ' || l_line_tbl(i).unit_selling_price,5);
         oe_debug_pub.add(' old unit selling price: ' || p_old_line_tbl(i).unit_selling_price,5);
      END IF;
      -- Added for bug 4771523

      If l_line_tbl(i).ORDERED_QUANTITY <> p_old_line_tbl(I).ORDERED_QUANTITY Then
        If l_line_tbl(i).LAST_ACK_CODE Is Null Or
           l_line_tbl(i).LAST_ACK_CODE = FND_API.G_MISS_CHAR Then
          l_line_tbl(i).LAST_ACK_CODE := 'IQ';
        Else
          l_line_tbl(i).LAST_ACK_CODE := 'IC';
        End If;
      End If;
      If l_line_tbl(i).SPLIT_FROM_LINE_ID Is Not Null And
         l_line_tbl(i).split_by = 'SYSTEM' Then
        l_line_tbl(i).LAST_ACK_CODE := 'IB';
      End If;
      If l_line_tbl(i).OPEN_FLAG = 'N'  Then
        l_line_tbl(i).LAST_ACK_CODE := 'ID';
      End If;

      If l_line_tbl(i).LAST_ACK_CODE Is Null Or
         l_line_tbl(i).LAST_ACK_CODE = FND_API.G_MISS_CHAR Then
        l_line_tbl(i).LAST_ACK_CODE := 'IA';
      End If;

      l_line_tbl(i).LAST_ACK_DATE := '';

    End If;

    If l_line_tbl(i).split_from_line_id Is Not Null And
       l_line_tbl(i).split_from_line_id <> FND_API.G_MISS_NUM Then
         --bsadri get the split reference
       Begin
         Select orig_sys_line_ref, orig_sys_shipment_ref
         Into   l_line_tbl(i).split_from_line_ref, l_line_tbl(i).split_from_shipment_ref
         From   OE_ORDER_LINES
         Where  line_id = l_line_tbl(i).split_from_line_id;
       Exception
         When Others Then
           Null;
       End;
    End If;

    -- Assign to collection
    Extend_Line_Rec
     (p_line_rec      => l_line_acks_rec,
      p_count         => 1);

    k := k +1;
    l_line_acks_rec.line_id(k)                 := l_line_tbl(i).line_id;
    l_line_acks_rec.header_id(k)               := l_line_tbl(i).header_id;

    l_line_acks_rec.ship_to_org_id(k)          := l_line_tbl(i).ship_to_org_id;
    l_line_acks_rec.invoice_to_org_id(k)       := l_line_tbl(i).invoice_to_org_id;
    l_line_acks_rec.invoice_to_contact_id(k)   := l_line_tbl(i).invoice_to_contact_id;
    l_line_acks_rec.ship_from_org_id(k)        := l_line_tbl(i).ship_from_org_id;
    l_line_acks_rec.agreement_id(k)            := l_line_tbl(i).agreement_id;
    l_line_acks_rec.price_list_id(k)           := l_line_tbl(i).price_list_id;
    l_line_acks_rec.arrival_set_id(k)          := l_line_tbl(i).arrival_set_id;
    l_line_acks_rec.accounting_rule_id(k)      := l_line_tbl(i).accounting_rule_id;
    l_line_acks_rec.fulfillment_set_id(k)      := l_line_tbl(i).fulfillment_set_id;
    --Added for bug 4309609 start
    begin
       l_validation_org_id := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID',l_line_tbl(i).org_id);
       SELECT concatenated_segments
           INTO l_line_acks_rec.inventory_item(k)
           FROM mtl_system_items_vl
          WHERE inventory_item_id = l_line_tbl(i).inventory_item_id
            AND organization_id = l_validation_org_id;
    exception
      when others then
           null;
    end ;
    --Added for bug 4309609 end
    l_line_acks_rec.inventory_item_id(k)       := l_line_tbl(i).inventory_item_id;
    l_line_acks_rec.invoicing_rule_id(k)       := l_line_tbl(i).invoicing_rule_id;
    l_line_acks_rec.line_type_id(k)            := l_line_tbl(i).line_type_id;
    l_line_acks_rec.order_source_id(k)         := l_line_tbl(i).order_source_id;
    l_line_acks_rec.payment_term_id(k)         := l_line_tbl(i).payment_term_id;
    l_line_acks_rec.project_id(k)              := l_line_tbl(i).project_id;
    l_line_acks_rec.salesrep_id(k)             := l_line_tbl(i).salesrep_id;
    l_line_acks_rec.ship_set_id(k)             := l_line_tbl(i).ship_set_id;
    l_line_acks_rec.ship_to_contact_id(k)      := l_line_tbl(i).ship_to_contact_id;
    l_line_acks_rec.task_id(k)                 := l_line_tbl(i).task_id;
    l_line_acks_rec.fob_point_code(k)          := l_line_tbl(i).fob_point_code;
    l_line_acks_rec.freight_terms_code(k)      := l_line_tbl(i).freight_terms_code;
    l_line_acks_rec.shipping_method_code(k)    := l_line_tbl(i).shipping_method_code;
    l_line_acks_rec.tax_code(k)                := l_line_tbl(i).tax_code;
    l_line_acks_rec.tax_point_code(k)          := l_line_tbl(i).tax_point_code;
    l_line_acks_rec.tax_exempt_reason_code(k)  := l_line_tbl(i).tax_exempt_reason_code;
    l_line_acks_rec.first_ack_code(k)          := l_line_tbl(i).first_ack_code;

  l_line_acks_rec.accounting_rule_duration(k) := l_line_tbl(i).accounting_rule_duration;
  l_line_acks_rec.actual_arrival_date(k)      := l_line_tbl(i).actual_arrival_date;
--
  l_line_acks_rec.actual_shipment_date(k)     := l_line_tbl(i).actual_shipment_date;
  l_line_acks_rec.ato_line_id(k)              := l_line_tbl(i).ato_line_id;
  l_line_acks_rec.authorized_to_ship_flag(k) := l_line_tbl(i).authorized_to_ship_flag;
  l_line_acks_rec.booked_flag(k) := l_line_tbl(i).booked_flag;
  l_line_acks_rec.cancelled_flag(k) := l_line_tbl(i).cancelled_flag;
  l_line_acks_rec.cancelled_quantity(k) := l_line_tbl(i).cancelled_quantity;
  l_line_acks_rec.change_sequence(k) := l_line_tbl(i).change_sequence;
  l_line_acks_rec.component_code(k) := l_line_tbl(i).component_code;
  l_line_acks_rec.component_number(k) := l_line_tbl(i).component_number;
  l_line_acks_rec.component_sequence_id(k) := l_line_tbl(i).component_sequence_id;
  l_line_acks_rec.config_display_sequence(k) := l_line_tbl(i).config_display_sequence;
  l_line_acks_rec.configuration_id(k) := l_line_tbl(i).configuration_id;
  l_line_acks_rec.top_model_line_id(k) := l_line_tbl(i).top_model_line_id;
  l_line_acks_rec.created_by(k) := l_line_tbl(i).created_by;
  l_line_acks_rec.creation_date(k) := l_line_tbl(i).creation_date;
  l_line_acks_rec.cust_model_serial_number(k) := l_line_tbl(i).cust_model_serial_number;
  l_line_acks_rec.cust_po_number(k) := l_line_tbl(i).cust_po_number;
  l_line_acks_rec.cust_production_seq_num(k) := l_line_tbl(i).cust_production_seq_num;
  l_line_acks_rec.customer_dock_code(k) := l_line_tbl(i).customer_dock_code;
  l_line_acks_rec.ordered_item(k) := l_line_tbl(i).ordered_item;
  l_line_acks_rec.ordered_item_id(k) := l_line_tbl(i).ordered_item_id; /* Bug # 4761560 */
  l_line_acks_rec.customer_job(k) := l_line_tbl(i).customer_job;
--
  l_line_acks_rec.customer_production_line(k) := l_line_tbl(i).customer_production_line;
  l_line_acks_rec.customer_trx_line_id(k) := l_line_tbl(i).customer_trx_line_id;
  l_line_acks_rec.deliver_to_contact_id(k) := l_line_tbl(i).deliver_to_contact_id;
  l_line_acks_rec.deliver_to_org_id(k) := l_line_tbl(i).deliver_to_org_id;
  l_line_acks_rec.delivery_lead_time(k) := l_line_tbl(i).delivery_lead_time;
  l_line_acks_rec.demand_bucket_type_code(k) := l_line_tbl(i).demand_bucket_type_code;
  l_line_acks_rec.demand_class_code(k) := l_line_tbl(i).demand_class_code;
  l_line_acks_rec.dep_plan_required_flag(k) := l_line_tbl(i).dep_plan_required_flag;
  l_line_acks_rec.earliest_acceptable_date(k) := l_line_tbl(i).earliest_acceptable_date;
  l_line_acks_rec.explosion_date(k) := l_line_tbl(i).explosion_date;
  l_line_acks_rec.freight_carrier_code(k) := l_line_tbl(i).freight_carrier_code;
  l_line_acks_rec.fulfilled_quantity(k) := l_line_tbl(i).fulfilled_quantity;
  l_line_acks_rec.item_revision(k) := l_line_tbl(i).item_revision;
  l_line_acks_rec.item_identifier_type(k) := l_line_tbl(i).item_identifier_type;
  l_line_acks_rec.context(k) := l_line_tbl(i).context;
  l_line_acks_rec.first_ack_date(k) := l_line_tbl(i).first_ack_date;
  l_line_acks_rec.last_ack_code(k) := l_line_tbl(i).last_ack_code;
  l_line_acks_rec.last_ack_date(k) := l_line_tbl(i).last_ack_date;

  l_line_acks_rec.last_update_date(k) := l_line_tbl(i).last_update_date;
  l_line_acks_rec.last_update_login(k) := l_line_tbl(i).last_update_login;
  l_line_acks_rec.last_updated_by(k) := l_line_tbl(i).last_updated_by;
  l_line_acks_rec.latest_acceptable_date(k) := l_line_tbl(i).latest_acceptable_date;
  l_line_acks_rec.line_category_code(k) := l_line_tbl(i).line_category_code;
  l_line_acks_rec.line_number(k) := l_line_tbl(i).line_number;
  l_line_acks_rec.link_to_line_id(k) := l_line_tbl(i).link_to_line_id;
  l_line_acks_rec.model_group_number(k) := l_line_tbl(i).model_group_number;
  l_line_acks_rec.open_flag(k) := l_line_tbl(i).open_flag;
  l_line_acks_rec.operation_code(k) := l_line_tbl(i).operation;
  l_line_acks_rec.option_flag(k) := l_line_tbl(i).option_flag;
  l_line_acks_rec.option_number(k) := l_line_tbl(i).option_number;
  l_line_acks_rec.order_quantity_uom(k) := l_line_tbl(i).order_quantity_uom;
  l_line_acks_rec.ordered_quantity(k) := l_line_tbl(i).ordered_quantity;
  l_line_acks_rec.org_id(k) := l_line_tbl(i).org_id;
  l_line_acks_rec.orig_sys_document_ref(k) := l_line_tbl(i).orig_sys_document_ref;
  l_line_acks_rec.orig_sys_line_ref(k) := l_line_tbl(i).orig_sys_line_ref;
  l_line_acks_rec.orig_sys_shipment_ref(k) := l_line_tbl(i).orig_sys_shipment_ref;
--
  l_line_acks_rec.over_ship_reason_code(k) := l_line_tbl(i).over_ship_reason_code;
  l_line_acks_rec.over_ship_resolved_flag(k) := l_line_tbl(i).over_ship_resolved_flag;
  l_line_acks_rec.pricing_date(k) := l_line_tbl(i).pricing_date;
  l_line_acks_rec.pricing_quantity(k) := l_line_tbl(i).pricing_quantity;
  l_line_acks_rec.pricing_quantity_uom(k) := l_line_tbl(i).pricing_quantity_uom;
  l_line_acks_rec.program_application_id(k) := l_line_tbl(i).program_application_id;
  l_line_acks_rec.program_id(k) := l_line_tbl(i).program_id;
  l_line_acks_rec.program_update_date(k) := l_line_tbl(i).program_update_date;
  l_line_acks_rec.promise_date(k) := l_line_tbl(i).promise_date;
  l_line_acks_rec.reference_header_id(k) := l_line_tbl(i).reference_header_id;
  l_line_acks_rec.reference_line_id(k) := l_line_tbl(i).reference_line_id;
  l_line_acks_rec.reference_type(k) := l_line_tbl(i).reference_type;
  l_line_acks_rec.request_date(k) := l_line_tbl(i).request_date;
  l_line_acks_rec.request_id(k) := l_line_tbl(i).request_id;
  l_line_acks_rec.reserved_quantity(k) := l_line_tbl(i).reserved_quantity;
  l_line_acks_rec.return_reason_code(k) := l_line_tbl(i).return_reason_code;
  l_line_acks_rec.rla_schedule_type_code(k) := l_line_tbl(i).rla_schedule_type_code;
  l_line_acks_rec.schedule_arrival_date(k) := l_line_tbl(i).schedule_arrival_date;
  l_line_acks_rec.schedule_ship_date(k) := l_line_tbl(i).schedule_ship_date;
  l_line_acks_rec.schedule_status_code(k) := l_line_tbl(i).schedule_status_code;
  l_line_acks_rec.ship_model_complete_flag(k) := l_line_tbl(i).ship_model_complete_flag;
  l_line_acks_rec.ship_tolerance_above(k) := l_line_tbl(i).ship_tolerance_above;
  l_line_acks_rec.ship_tolerance_below(k) := l_line_tbl(i).ship_tolerance_below;
--
  l_line_acks_rec.shipment_number(k) := l_line_tbl(i).shipment_number;
  l_line_acks_rec.shipment_priority_code(k) := l_line_tbl(i).shipment_priority_code;
  l_line_acks_rec.shipped_quantity(k) := l_line_tbl(i).shipped_quantity;
  l_line_acks_rec.SHIPPING_METHOD_CODE(k) := l_line_tbl(i).SHIPPING_METHOD_CODE;
  l_line_acks_rec.SHIPPING_QUANTITY(k) := l_line_tbl(i).SHIPPING_QUANTITY;
  l_line_acks_rec.SHIPPING_QUANTITY_UOM(k) := l_line_tbl(i).SHIPPING_QUANTITY_UOM;
  l_line_acks_rec.SOLD_TO_ORG_ID(k) := l_line_tbl(i).SOLD_TO_ORG_ID;
  l_line_acks_rec.SORT_ORDER(k) := l_line_tbl(i).SORT_ORDER;
  l_line_acks_rec.SOURCE_DOCUMENT_ID(k) := l_line_tbl(i).SOURCE_DOCUMENT_ID;
  l_line_acks_rec.SOURCE_DOCUMENT_LINE_ID(k) := l_line_tbl(i).SOURCE_DOCUMENT_LINE_ID;
  l_line_acks_rec.SOURCE_DOCUMENT_TYPE_ID(k) := l_line_tbl(i).SOURCE_DOCUMENT_TYPE_ID;
  l_line_acks_rec.SOURCE_TYPE_CODE(k) := l_line_tbl(i).SOURCE_TYPE_CODE;
  l_line_acks_rec.SPLIT_FROM_LINE_ID(k) := l_line_tbl(i).SPLIT_FROM_LINE_ID;
  l_line_acks_rec.TAX_CODE(k) := l_line_tbl(i).TAX_CODE;
  l_line_acks_rec.TAX_DATE(k) := l_line_tbl(i).TAX_DATE;
  l_line_acks_rec.TAX_EXEMPT_FLAG(k) := l_line_tbl(i).TAX_EXEMPT_FLAG;
  l_line_acks_rec.TAX_EXEMPT_NUMBER(k) := l_line_tbl(i).TAX_EXEMPT_NUMBER;
  l_line_acks_rec.TAX_EXEMPT_REASON_CODE(k) := l_line_tbl(i).TAX_EXEMPT_REASON_CODE;
  l_line_acks_rec.TAX_POINT_CODE(k) := l_line_tbl(i).TAX_POINT_CODE;
  l_line_acks_rec.TAX_RATE(k) := l_line_tbl(i).TAX_RATE;
  l_line_acks_rec.TAX_VALUE(k) := l_line_tbl(i).TAX_VALUE;
  l_line_acks_rec.UNIT_LIST_PRICE(k) := l_line_tbl(i).UNIT_LIST_PRICE;
  l_line_acks_rec.UNIT_SELLING_PRICE(k) := l_line_tbl(i).UNIT_SELLING_PRICE;
  l_line_acks_rec.VEH_CUS_ITEM_CUM_KEY_ID(k) := l_line_tbl(i).VEH_CUS_ITEM_CUM_KEY_ID;
  l_line_acks_rec.VISIBLE_DEMAND_FLAG(k) := l_line_tbl(i).VISIBLE_DEMAND_FLAG;
  l_line_acks_rec.split_from_line_ref(k) := l_line_tbl(i).split_from_line_ref;
  l_line_acks_rec.split_from_shipment_ref(k) := l_line_tbl(i).split_from_shipment_ref;
  l_line_acks_rec.Service_Txn_Reason_Code(k) := l_line_tbl(i).Service_Txn_Reason_Code;
  l_line_acks_rec.Service_Txn_Comments(k) := l_line_tbl(i).Service_Txn_Comments;
  l_line_acks_rec.Service_Duration(k) := l_line_tbl(i).Service_Duration;
  l_line_acks_rec.Service_Start_Date(k) := l_line_tbl(i).Service_Start_Date;
  l_line_acks_rec.Service_End_Date(k) := l_line_tbl(i).Service_End_Date;
  l_line_acks_rec.Service_Coterminate_Flag(k) := l_line_tbl(i).Service_Coterminate_Flag;
  l_line_acks_rec.Service_Number(k) := l_line_tbl(i).Service_Number;
  l_line_acks_rec.Service_Period(k) := l_line_tbl(i).Service_Period;
  l_line_acks_rec.Service_Reference_Type_Code(k) := l_line_tbl(i).Service_Reference_Type_Code;
  l_line_acks_rec.service_Reference_Line_Id(k) := l_line_tbl(i).service_Reference_Line_Id;
  l_line_acks_rec.Service_Reference_System_Id(k) := l_line_tbl(i).Service_Reference_System_Id;
  l_line_acks_rec.Credit_Invoice_Line_Id(k) := l_line_tbl(i).Credit_Invoice_Line_Id;
  l_line_acks_rec.service_reference_line(k) := l_line_tbl(i).service_reference_line;
  l_line_acks_rec.service_reference_order(k) := l_line_tbl(i).service_reference_order;
  l_line_acks_rec.service_reference_system(k) := l_line_tbl(i).service_reference_system;
  l_line_acks_rec.customer_line_number(k) := l_line_tbl(i).customer_line_number;

  l_line_acks_rec.user_item_description(k) := l_line_tbl(i).user_item_description;
  --l_line_acks_rec.acknowledgment_type(k) := l_line_tbl(i).acknowledgment_type;
  l_line_acks_rec.blanket_number(k) := l_line_tbl(i).blanket_number;
  l_line_acks_rec.blanket_line_number(k) := l_line_tbl(i).blanket_line_number;
  l_line_acks_rec.original_inventory_item_id(k) := l_line_tbl(i).original_inventory_item_id;
  l_line_acks_rec.original_ordered_item_id(k) := l_line_tbl(i).original_ordered_item_id;
  l_line_acks_rec.original_ordered_item(k) := l_line_tbl(i).original_ordered_item;
  l_line_acks_rec.original_item_identifier_type(k) := l_line_tbl(i).original_item_identifier_type;
  l_line_acks_rec.item_relationship_type(k) := l_line_tbl(i).item_relationship_type;
  l_line_acks_rec.attribute1(k) := l_line_tbl(i).attribute1;
  l_line_acks_rec.attribute10(k) := l_line_tbl(i).attribute10;
 l_line_acks_rec.attribute11(k) := l_line_tbl(i).attribute11;
 l_line_acks_rec.attribute12(k) := l_line_tbl(i).attribute12;
 l_line_acks_rec.attribute13(k) := l_line_tbl(i).attribute13;
 l_line_acks_rec.attribute14(k) := l_line_tbl(i).attribute14;
 l_line_acks_rec.attribute15(k) := l_line_tbl(i).attribute15;
 l_line_acks_rec.attribute16(k) := l_line_tbl(i).attribute16;
 l_line_acks_rec.attribute17(k) := l_line_tbl(i).attribute17;
 l_line_acks_rec.attribute18(k) := l_line_tbl(i).attribute18;
 l_line_acks_rec.attribute19(k) := l_line_tbl(i).attribute19;
 l_line_acks_rec.attribute2(k) := l_line_tbl(i).attribute2;
 l_line_acks_rec.attribute20(k) := l_line_tbl(i).attribute20;
 l_line_acks_rec.attribute3(k) := l_line_tbl(i).attribute3;
 l_line_acks_rec.attribute4(k) := l_line_tbl(i).attribute4;
 l_line_acks_rec.attribute5(k) := l_line_tbl(i).attribute5;
 l_line_acks_rec.attribute6(k) := l_line_tbl(i).attribute6;
 l_line_acks_rec.attribute7(k) := l_line_tbl(i).attribute7;
 l_line_acks_rec.attribute8(k) := l_line_tbl(i).attribute8;
 l_line_acks_rec.attribute9(k) := l_line_tbl(i).attribute9;
 l_line_acks_rec.global_attribute1(k) := l_line_tbl(i).global_attribute1;
 l_line_acks_rec.global_attribute10(k) := l_line_tbl(i).global_attribute10;
 l_line_acks_rec.global_attribute11(k) := l_line_tbl(i).global_attribute11;
 l_line_acks_rec.global_attribute12(k) := l_line_tbl(i).global_attribute12;
 l_line_acks_rec.global_attribute13(k) := l_line_tbl(i).global_attribute13;
 l_line_acks_rec.global_attribute14(k) := l_line_tbl(i).global_attribute14;
 l_line_acks_rec.global_attribute15(k) := l_line_tbl(i).global_attribute15;
 l_line_acks_rec.global_attribute16(k) := l_line_tbl(i).global_attribute16;
 l_line_acks_rec.global_attribute17(k) := l_line_tbl(i).global_attribute17;
 l_line_acks_rec.global_attribute18(k) := l_line_tbl(i).global_attribute18;
 l_line_acks_rec.global_attribute19(k) := l_line_tbl(i).global_attribute19;
 l_line_acks_rec.global_attribute2(k) := l_line_tbl(i).global_attribute2;
 l_line_acks_rec.global_attribute20(k) := l_line_tbl(i).global_attribute20;
 l_line_acks_rec.global_attribute3(k) := l_line_tbl(i).global_attribute3;
 l_line_acks_rec.global_attribute4(k) := l_line_tbl(i).global_attribute4;
 l_line_acks_rec.global_attribute5(k) := l_line_tbl(i).global_attribute5;
 l_line_acks_rec.global_attribute6(k) := l_line_tbl(i).global_attribute6;
 l_line_acks_rec.global_attribute7(k) := l_line_tbl(i).global_attribute7;
 l_line_acks_rec.global_attribute8(k) := l_line_tbl(i).global_attribute8;
 l_line_acks_rec.global_attribute9(k) := l_line_tbl(i).global_attribute9;
 l_line_acks_rec.global_attribute_category(k) := l_line_tbl(i).global_attribute_category;

 l_line_acks_rec.industry_attribute1(k) := l_line_tbl(i).industry_attribute1;
 l_line_acks_rec.industry_attribute10(k) := l_line_tbl(i).industry_attribute10;
 l_line_acks_rec.industry_attribute11(k) := l_line_tbl(i).industry_attribute11;
 l_line_acks_rec.industry_attribute12(k) := l_line_tbl(i).industry_attribute12;
 l_line_acks_rec.industry_attribute13(k) := l_line_tbl(i).industry_attribute13;
 l_line_acks_rec.industry_attribute14(k) := l_line_tbl(i).industry_attribute14;
 l_line_acks_rec.industry_attribute15(k) := l_line_tbl(i).industry_attribute15;
 l_line_acks_rec.industry_attribute16(k) := l_line_tbl(i).industry_attribute16;
 l_line_acks_rec.industry_attribute17(k) := l_line_tbl(i).industry_attribute17;
 l_line_acks_rec.industry_attribute18(k) := l_line_tbl(i).industry_attribute18;
 l_line_acks_rec.industry_attribute19(k) := l_line_tbl(i).industry_attribute19;
 l_line_acks_rec.industry_attribute20(k) := l_line_tbl(i).industry_attribute20;
 l_line_acks_rec.industry_attribute21(k) := l_line_tbl(i).industry_attribute21;
 l_line_acks_rec.industry_attribute22(k) := l_line_tbl(i).industry_attribute22;
 l_line_acks_rec.industry_attribute23(k) := l_line_tbl(i).industry_attribute23;
 l_line_acks_rec.industry_attribute24(k) := l_line_tbl(i).industry_attribute24;
 l_line_acks_rec.industry_attribute25(k) := l_line_tbl(i).industry_attribute25;
 l_line_acks_rec.industry_attribute26(k) := l_line_tbl(i).industry_attribute26;
 l_line_acks_rec.industry_attribute27(k) := l_line_tbl(i).industry_attribute27;
 l_line_acks_rec.industry_attribute28(k) := l_line_tbl(i).industry_attribute28;
 l_line_acks_rec.industry_attribute29(k) := l_line_tbl(i).industry_attribute29;
 l_line_acks_rec.industry_attribute30(k) := l_line_tbl(i).industry_attribute30;
 l_line_acks_rec.industry_attribute2(k) := l_line_tbl(i).industry_attribute2;
 l_line_acks_rec.industry_attribute3(k) := l_line_tbl(i).industry_attribute3;
 l_line_acks_rec.industry_attribute4(k) := l_line_tbl(i).industry_attribute4;
 l_line_acks_rec.industry_attribute5(k) := l_line_tbl(i).industry_attribute5;
 l_line_acks_rec.industry_attribute6(k) := l_line_tbl(i).industry_attribute6;
 l_line_acks_rec.industry_attribute7(k) := l_line_tbl(i).industry_attribute7;
 l_line_acks_rec.industry_attribute8(k) := l_line_tbl(i).industry_attribute8;
 l_line_acks_rec.industry_attribute9(k) := l_line_tbl(i).industry_attribute9;
 l_line_acks_rec.industry_context(k) := l_line_tbl(i).industry_context;
 l_line_acks_rec.TP_CONTEXT(k) := l_line_tbl(i).TP_CONTEXT;
 l_line_acks_rec.TP_ATTRIBUTE1(k) := l_line_tbl(i).TP_ATTRIBUTE1;
 l_line_acks_rec.TP_ATTRIBUTE2(k) := l_line_tbl(i).TP_ATTRIBUTE2;
 l_line_acks_rec.TP_ATTRIBUTE3(k) := l_line_tbl(i).TP_ATTRIBUTE3;
 l_line_acks_rec.TP_ATTRIBUTE4(k) := l_line_tbl(i).TP_ATTRIBUTE4;
 l_line_acks_rec.TP_ATTRIBUTE5(k) := l_line_tbl(i).TP_ATTRIBUTE5;
 l_line_acks_rec.TP_ATTRIBUTE6(k) := l_line_tbl(i).TP_ATTRIBUTE6;
 l_line_acks_rec.TP_ATTRIBUTE7(k) := l_line_tbl(i).TP_ATTRIBUTE7;
 l_line_acks_rec.TP_ATTRIBUTE8(k) := l_line_tbl(i).TP_ATTRIBUTE8;
 l_line_acks_rec.TP_ATTRIBUTE9(k) := l_line_tbl(i).TP_ATTRIBUTE9;
 l_line_acks_rec.TP_ATTRIBUTE10(k) := l_line_tbl(i).TP_ATTRIBUTE10;
 l_line_acks_rec.TP_ATTRIBUTE11(k) := l_line_tbl(i).TP_ATTRIBUTE11;
 l_line_acks_rec.TP_ATTRIBUTE12(k) := l_line_tbl(i).TP_ATTRIBUTE12;
 l_line_acks_rec.TP_ATTRIBUTE13(k) := l_line_tbl(i).TP_ATTRIBUTE13;
 l_line_acks_rec.TP_ATTRIBUTE14(k) := l_line_tbl(i).TP_ATTRIBUTE14;
 l_line_acks_rec.TP_ATTRIBUTE15(k) := l_line_tbl(i).TP_ATTRIBUTE15;
 l_line_acks_rec.pricing_attribute1(k) := l_line_tbl(i).pricing_attribute1;
 l_line_acks_rec.pricing_attribute10(k) := l_line_tbl(i).pricing_attribute10;
 l_line_acks_rec.pricing_attribute2(k) := l_line_tbl(i).pricing_attribute2;
 l_line_acks_rec.pricing_attribute3(k) := l_line_tbl(i).pricing_attribute3;
 l_line_acks_rec.pricing_attribute4(k) := l_line_tbl(i).pricing_attribute4;
 l_line_acks_rec.pricing_attribute5(k) := l_line_tbl(i).pricing_attribute5;
 l_line_acks_rec.pricing_attribute6(k) := l_line_tbl(i).pricing_attribute6;
 l_line_acks_rec.pricing_attribute7(k) := l_line_tbl(i).pricing_attribute7;
 l_line_acks_rec.pricing_attribute8(k) := l_line_tbl(i).pricing_attribute8;
 l_line_acks_rec.pricing_attribute9(k) := l_line_tbl(i).pricing_attribute9;
 l_line_acks_rec.pricing_context(k) := l_line_tbl(i).pricing_context;
 l_line_acks_rec.return_attribute1(k) := l_line_tbl(i).return_attribute1;
 l_line_acks_rec.return_attribute10(k) := l_line_tbl(i).return_attribute10;
 l_line_acks_rec.return_attribute11(k) := l_line_tbl(i).return_attribute11;
 l_line_acks_rec.return_attribute12(k) := l_line_tbl(i).return_attribute12;
 l_line_acks_rec.return_attribute13(k) := l_line_tbl(i).return_attribute13;
 l_line_acks_rec.return_attribute14(k) := l_line_tbl(i).return_attribute14;
 l_line_acks_rec.return_attribute15(k) := l_line_tbl(i).return_attribute15;
 l_line_acks_rec.return_attribute2(k) := l_line_tbl(i).return_attribute2;
 l_line_acks_rec.return_attribute3(k) := l_line_tbl(i).return_attribute3;
 l_line_acks_rec.return_attribute4(k) := l_line_tbl(i).return_attribute4;
 l_line_acks_rec.return_attribute5(k) := l_line_tbl(i).return_attribute5;
 l_line_acks_rec.return_attribute6(k) := l_line_tbl(i).return_attribute6;
 l_line_acks_rec.return_attribute7(k) := l_line_tbl(i).return_attribute7;
 l_line_acks_rec.return_attribute8(k) := l_line_tbl(i).return_attribute8;
 l_line_acks_rec.return_attribute9(k) := l_line_tbl(i).return_attribute9;
 l_line_acks_rec.return_context(k) := l_line_tbl(i).return_context;
 l_line_acks_rec.customer_shipment_number(k) := l_line_tbl(i).customer_shipment_number;
-- { Distributer Order related change
 l_line_acks_rec.end_customer_id(k)  := l_line_tbl(i).end_customer_id;
 l_line_acks_rec.end_customer_contact_id(k) :=  l_line_tbl(i).end_customer_contact_id;
 l_line_acks_rec.end_customer_site_use_id(k) :=  l_line_tbl(i).end_customer_site_use_id;
 l_line_acks_rec.ib_owner(k) :=  l_line_tbl(i).ib_owner;
 l_line_acks_rec.ib_current_location(k) :=  l_line_tbl(i).ib_current_location;
 l_line_acks_rec.ib_installed_at_location(k) :=  l_line_tbl(i).ib_installed_at_location;
-- Distributer Order related change }
 l_line_acks_rec.charge_periodicity_code(k) :=  l_line_tbl(i).charge_periodicity_code;

    <<nextline>>
    Exit When i = l_line_tbl.count;
    i   :=  l_line_tbl.Next(i);

  End Loop;

  If l_count > 0 Then
    --Added for bug4730258 start
     FORALL y in l_line_acks_rec.line_id.First..l_line_acks_rec.line_id.Last
       DELETE  FROM OE_LINE_ACKS
         WHERE   HEADER_ID = l_line_acks_rec.header_id(y)
         AND   LINE_ID 	= l_line_acks_rec.line_id(y)
         AND   ACKNOWLEDGMENT_FLAG is null
         -- Change this condition once a type is inserted for POAO/POCAO
         AND nvl(acknowledgment_type,'ALL') = nvl(l_ack_type,'ALL')
         AND  nvl(change_sequence, FND_API.G_MISS_CHAR)
           =  nvl(l_line_acks_rec.CHANGE_SEQUENCE(y), FND_API.G_MISS_CHAR) ;
     --Added for bug4730258 end
   FORALL j in l_line_acks_rec.line_id.First..l_line_acks_rec.line_id.Last
    Insert Into Oe_Line_Acks
        (
          ACCOUNTING_RULE_ID
         ,ACCOUNTING_RULE_DURATION
         ,ACKNOWLEDGMENT_FLAG
         ,ACTUAL_ARRIVAL_DATE
         ,ACTUAL_SHIPMENT_DATE
         ,AGREEMENT_ID
         ,ARRIVAL_SET_ID
/*
         ,ATO_LINE_ID
*/
         ,ATTRIBUTE1
         ,ATTRIBUTE10
         ,ATTRIBUTE11
         ,ATTRIBUTE12
         ,ATTRIBUTE13
         ,ATTRIBUTE14
         ,ATTRIBUTE15
         ,ATTRIBUTE16    --For bug 2184255
         ,ATTRIBUTE17
         ,ATTRIBUTE18
         ,ATTRIBUTE19
         ,ATTRIBUTE2
         ,ATTRIBUTE20
         ,ATTRIBUTE3
         ,ATTRIBUTE4
         ,ATTRIBUTE5
         ,ATTRIBUTE6
         ,ATTRIBUTE7
         ,ATTRIBUTE8
         ,ATTRIBUTE9
/*
         ,AUTHORIZED_TO_SHIP_FLAG
         ,BUYER_SELLER_FLAG
*/
         ,BOOKED_FLAG
         ,CANCELLED_FLAG
         ,CANCELLED_QUANTITY
         ,CHANGE_DATE
         ,CHANGE_SEQUENCE
         ,COMPONENT_CODE
         ,COMPONENT_NUMBER
         ,COMPONENT_SEQUENCE_ID
         ,CONFIG_DISPLAY_SEQUENCE
         ,CONFIGURATION_ID
         ,TOP_MODEL_LINE_ID
         ,CONTEXT
         ,CREATED_BY
         ,CREATION_DATE
         ,CUST_MODEL_SERIAL_NUMBER
         ,CUST_PO_NUMBER
         ,CUST_PRODUCTION_SEQ_NUM
         ,CUSTOMER_DOCK_CODE
         ,CUSTOMER_ITEM
         ,CUSTOMER_ITEM_ID /* Bug # 4761560 */
         ,CUSTOMER_JOB
         ,CUSTOMER_PRODUCTION_LINE
         ,CUSTOMER_TRX_LINE_ID
         ,DELIVER_TO_CONTACT_ID
         ,DELIVER_TO_ORG_ID
         ,DELIVERY_LEAD_TIME
         ,DEMAND_BUCKET_TYPE_CODE
         ,DEMAND_CLASS_CODE
         ,DEP_PLAN_REQUIRED_FLAG
         ,EARLIEST_ACCEPTABLE_DATE
         ,EXPLOSION_DATE
	 ,FIRST_ACK_CODE
	 ,FIRST_ACK_DATE
         ,FOB_POINT_CODE
         ,FREIGHT_CARRIER_CODE
         ,FREIGHT_TERMS_CODE
         ,FULFILLED_QUANTITY
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
         ,HEADER_ID
         ,INDUSTRY_ATTRIBUTE1
         ,INDUSTRY_ATTRIBUTE10
         ,INDUSTRY_ATTRIBUTE11
         ,INDUSTRY_ATTRIBUTE12
         ,INDUSTRY_ATTRIBUTE13
         ,INDUSTRY_ATTRIBUTE14
         ,INDUSTRY_ATTRIBUTE15
         ,INDUSTRY_ATTRIBUTE16
         ,INDUSTRY_ATTRIBUTE17
         ,INDUSTRY_ATTRIBUTE18
         ,INDUSTRY_ATTRIBUTE19
         ,INDUSTRY_ATTRIBUTE2
         ,INDUSTRY_ATTRIBUTE20
         ,INDUSTRY_ATTRIBUTE21
         ,INDUSTRY_ATTRIBUTE22
         ,INDUSTRY_ATTRIBUTE23
         ,INDUSTRY_ATTRIBUTE24
         ,INDUSTRY_ATTRIBUTE25
         ,INDUSTRY_ATTRIBUTE26
         ,INDUSTRY_ATTRIBUTE27
         ,INDUSTRY_ATTRIBUTE28
         ,INDUSTRY_ATTRIBUTE29
         ,INDUSTRY_ATTRIBUTE3
         ,INDUSTRY_ATTRIBUTE30
         ,INDUSTRY_ATTRIBUTE4
         ,INDUSTRY_ATTRIBUTE5
         ,INDUSTRY_ATTRIBUTE6
         ,INDUSTRY_ATTRIBUTE7
         ,INDUSTRY_ATTRIBUTE8
         ,INDUSTRY_ATTRIBUTE9
         ,INDUSTRY_CONTEXT
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
	 ,INVENTORY_ITEM         --added for bug 4309609
         ,INVENTORY_ITEM_ID
         ,INVOICE_TO_CONTACT_ID
         ,INVOICE_TO_ORG_ID
         ,INVOICING_RULE_ID
         ,ITEM_INPUT
         ,ITEM_REVISION
         ,ITEM_TYPE_CODE
	 ,LAST_ACK_CODE
	 ,LAST_ACK_DATE
         ,LAST_UPDATE_DATE
         ,LAST_UPDATE_LOGIN
         ,LAST_UPDATED_BY
         ,LATEST_ACCEPTABLE_DATE
         ,LINE_CATEGORY_CODE
         ,LINE_ID
         ,LINE_NUMBER
         ,LINE_TYPE_ID
         ,LINK_TO_LINE_ID
         ,MODEL_GROUP_NUMBER
         ,OPEN_FLAG
         ,OPERATION_CODE
         ,OPTION_FLAG
         ,OPTION_NUMBER
         ,ORDER_QUANTITY_UOM
         ,ORDER_SOURCE_ID
         ,ORDERED_QUANTITY
         ,ORG_ID
         ,ORIG_SYS_DOCUMENT_REF
         ,ORIG_SYS_LINE_REF
         ,ORIG_SYS_SHIPMENT_REF
         ,OVER_SHIP_REASON_CODE
         ,OVER_SHIP_RESOLVED_FLAG
         ,PAYMENT_TERM_ID
         ,PRICE_LIST_ID
         ,PRICING_ATTRIBUTE1
         ,PRICING_ATTRIBUTE10
         ,PRICING_ATTRIBUTE2
         ,PRICING_ATTRIBUTE3
         ,PRICING_ATTRIBUTE4
         ,PRICING_ATTRIBUTE5
         ,PRICING_ATTRIBUTE6
         ,PRICING_ATTRIBUTE7
         ,PRICING_ATTRIBUTE8
         ,PRICING_ATTRIBUTE9
         ,PRICING_CONTEXT
         ,PRICING_DATE
         ,PRICING_QUANTITY
         ,PRICING_QUANTITY_UOM
         ,PROGRAM_APPLICATION_ID
         ,PROGRAM_ID
         ,PROGRAM_UPDATE_DATE
         ,PROJECT_ID
         ,PROMISE_DATE
         ,REFERENCE_HEADER_ID
         ,REFERENCE_LINE_ID
         ,REFERENCE_TYPE
         ,REQUEST_DATE
         ,REQUEST_ID
         ,RESERVED_QUANTITY
         ,RETURN_ATTRIBUTE1
         ,RETURN_ATTRIBUTE10
         ,RETURN_ATTRIBUTE11
         ,RETURN_ATTRIBUTE12
         ,RETURN_ATTRIBUTE13
         ,RETURN_ATTRIBUTE14
         ,RETURN_ATTRIBUTE15
         ,RETURN_ATTRIBUTE2
         ,RETURN_ATTRIBUTE3
         ,RETURN_ATTRIBUTE4
         ,RETURN_ATTRIBUTE5
         ,RETURN_ATTRIBUTE6
         ,RETURN_ATTRIBUTE7
         ,RETURN_ATTRIBUTE8
         ,RETURN_ATTRIBUTE9
         ,RETURN_CONTEXT
         ,RETURN_REASON_CODE
         ,RLA_SCHEDULE_TYPE_CODE
         ,SALESREP_ID
         ,SCHEDULE_ARRIVAL_DATE
         ,SCHEDULE_SHIP_DATE
         ,SCHEDULE_STATUS_CODE
         ,SHIP_FROM_ORG_ID
         ,SHIP_MODEL_COMPLETE_FLAG
         ,SHIP_SET_ID
         ,SHIP_TO_CONTACT_ID
         ,SHIP_TO_ORG_ID
         ,SHIP_TOLERANCE_ABOVE
         ,SHIP_TOLERANCE_BELOW
         ,SHIPMENT_NUMBER
         ,SHIPMENT_PRIORITY_CODE
         ,SHIPPED_QUANTITY
         ,SHIPPING_METHOD_CODE
         ,SHIPPING_QUANTITY
         ,SHIPPING_QUANTITY_UOM
         ,SOLD_TO_ORG_ID
         ,SORT_ORDER
         ,SOURCE_DOCUMENT_ID
         ,SOURCE_DOCUMENT_LINE_ID
         ,SOURCE_DOCUMENT_TYPE_ID
         ,SOURCE_TYPE_CODE
         ,SPLIT_FROM_LINE_ID
         ,TASK_ID
         ,TAX_CODE
         ,TAX_DATE
         ,TAX_EXEMPT_FLAG
         ,TAX_EXEMPT_NUMBER
         ,TAX_EXEMPT_REASON_CODE
         ,TAX_POINT_CODE
         ,TAX_RATE
         ,TAX_VALUE
         ,UNIT_LIST_PRICE
         ,UNIT_SELLING_PRICE
         ,VEH_CUS_ITEM_CUM_KEY_ID
         ,VISIBLE_DEMAND_FLAG
         ,split_from_line_ref
         ,split_from_shipment_ref
         ,Service_Txn_Reason_Code
	 ,Service_Txn_Comments
	 ,Service_Duration
	 ,Service_Start_Date
	 ,Service_End_Date
	 ,Service_Coterminate_Flag
	 ,Service_Number
	 ,Service_Period
	 ,Service_Reference_Type_Code
	 ,Service_Reference_Line_Id
	 ,Service_Reference_System_Id
	 ,Credit_Invoice_Line_Id
         ,service_reference_line
         ,service_reference_order
         ,service_reference_system
         ,customer_line_number
         ,user_item_description
         ,acknowledgment_type
         ,blanket_number
         ,blanket_line_number
         ,original_inventory_item_id
	 ,original_ordered_item_id
	 ,original_ordered_item
	 ,original_item_identifier_type
         ,item_relationship_type
         ,customer_shipment_number
     -- { Distributer Order related change
         ,end_customer_id
         ,end_customer_contact_id
         ,end_customer_site_use_id
         ,ib_owner
         ,ib_current_location
         ,ib_installed_at_location
     -- Distributer Order related change }
         ,charge_periodicity_code
       )
    Values
       (
          l_line_acks_rec.ACCOUNTING_RULE_ID(j)
         , l_line_acks_rec.ACCOUNTING_RULE_DURATION(j)
         , '' 		-- ACKNOWLEDGMENT_FLAG
         , l_line_acks_rec.ACTUAL_ARRIVAL_DATE(j)
         , l_line_acks_rec.ACTUAL_SHIPMENT_DATE(j)
         , l_line_acks_rec.AGREEMENT_ID(j)
         , l_line_acks_rec.ARRIVAL_SET_ID(j)
/*
         , l_line_acks_rec.ATO_LINE_ID
*/
         , l_line_acks_rec.ATTRIBUTE1(j)
         , l_line_acks_rec.ATTRIBUTE10(j)
         , l_line_acks_rec.ATTRIBUTE11(j)
         , l_line_acks_rec.ATTRIBUTE12(j)
         , l_line_acks_rec.ATTRIBUTE13(j)
         , l_line_acks_rec.ATTRIBUTE14(j)
         , l_line_acks_rec.ATTRIBUTE15(j)
         , l_line_acks_rec.ATTRIBUTE16(j)    --For bug 2184255
         , l_line_acks_rec.ATTRIBUTE17(j)
         , l_line_acks_rec.ATTRIBUTE18(j)
         , l_line_acks_rec.ATTRIBUTE19(j)
         , l_line_acks_rec.ATTRIBUTE2(j)
         , l_line_acks_rec.ATTRIBUTE20(j)
         , l_line_acks_rec.ATTRIBUTE3(j)
         , l_line_acks_rec.ATTRIBUTE4(j)
         , l_line_acks_rec.ATTRIBUTE5(j)
         , l_line_acks_rec.ATTRIBUTE6(j)
         , l_line_acks_rec.ATTRIBUTE7(j)
         , l_line_acks_rec.ATTRIBUTE8(j)
         , l_line_acks_rec.ATTRIBUTE9(j)
/*
         , l_line_acks_rec.AUTHORIZED_TO_SHIP_FLAG
         , p_buyer_seller_flag
*/
         , l_line_acks_rec.BOOKED_FLAG(j)
         , l_line_acks_rec.CANCELLED_FLAG(j)
         , l_line_acks_rec.CANCELLED_QUANTITY(j)
         , ''	-- CHANGE_DATE
         , l_line_acks_rec.CHANGE_SEQUENCE(j)
         , l_line_acks_rec.COMPONENT_CODE(j)
         , l_line_acks_rec.COMPONENT_NUMBER(j)
         , l_line_acks_rec.COMPONENT_SEQUENCE_ID(j)
         , l_line_acks_rec.CONFIG_DISPLAY_SEQUENCE(j)
         , l_line_acks_rec.CONFIGURATION_ID(j)
         , l_line_acks_rec.TOP_MODEL_LINE_ID(j)
         , l_line_acks_rec.CONTEXT(j)
         , l_line_acks_rec.CREATED_BY(j)
         , l_line_acks_rec.CREATION_DATE(j)
         , l_line_acks_rec.CUST_MODEL_SERIAL_NUMBER(j)
         , l_line_acks_rec.CUST_PO_NUMBER(j)
         , l_line_acks_rec.CUST_PRODUCTION_SEQ_NUM(j)
         , l_line_acks_rec.CUSTOMER_DOCK_CODE(j)
         , l_line_acks_rec.ORDERED_ITEM(j)
         , l_line_acks_rec.ORDERED_ITEM_ID(j) /* Bug # 4761560 */
         , l_line_acks_rec.CUSTOMER_JOB(j)
         , l_line_acks_rec.CUSTOMER_PRODUCTION_LINE(j)
         , l_line_acks_rec.CUSTOMER_TRX_LINE_ID(j)
         , l_line_acks_rec.DELIVER_TO_CONTACT_ID(j)
         , l_line_acks_rec.DELIVER_TO_ORG_ID(j)
         , l_line_acks_rec.DELIVERY_LEAD_TIME(j)
         , l_line_acks_rec.DEMAND_BUCKET_TYPE_CODE(j)
         , l_line_acks_rec.DEMAND_CLASS_CODE(j)
         , l_line_acks_rec.DEP_PLAN_REQUIRED_FLAG(j)
         , l_line_acks_rec.EARLIEST_ACCEPTABLE_DATE(j)
         , l_line_acks_rec.EXPLOSION_DATE(j)
	 , l_line_acks_rec.FIRST_ACK_CODE(j)
	 , l_line_acks_rec.FIRST_ACK_DATE(j)
         , l_line_acks_rec.FOB_POINT_CODE(j)
         , l_line_acks_rec.FREIGHT_CARRIER_CODE(j)
         , l_line_acks_rec.FREIGHT_TERMS_CODE(j)
         , l_line_acks_rec.FULFILLED_QUANTITY(j)
         , l_line_acks_rec.GLOBAL_ATTRIBUTE_CATEGORY(j)
         , l_line_acks_rec.GLOBAL_ATTRIBUTE1(j)
         , l_line_acks_rec.GLOBAL_ATTRIBUTE10(j)
         , l_line_acks_rec.GLOBAL_ATTRIBUTE11(j)
         , l_line_acks_rec.GLOBAL_ATTRIBUTE12(j)
         , l_line_acks_rec.GLOBAL_ATTRIBUTE13(j)
         , l_line_acks_rec.GLOBAL_ATTRIBUTE14(j)
         , l_line_acks_rec.GLOBAL_ATTRIBUTE15(j)
         , l_line_acks_rec.GLOBAL_ATTRIBUTE16(j)
         , l_line_acks_rec.GLOBAL_ATTRIBUTE17(j)
         , l_line_acks_rec.GLOBAL_ATTRIBUTE18(j)
         , l_line_acks_rec.GLOBAL_ATTRIBUTE19(j)
         , l_line_acks_rec.GLOBAL_ATTRIBUTE2(j)
         , l_line_acks_rec.GLOBAL_ATTRIBUTE20(j)
         , l_line_acks_rec.GLOBAL_ATTRIBUTE3(j)
         , l_line_acks_rec.GLOBAL_ATTRIBUTE4(j)
         , l_line_acks_rec.GLOBAL_ATTRIBUTE5(j)
         , l_line_acks_rec.GLOBAL_ATTRIBUTE6(j)
         , l_line_acks_rec.GLOBAL_ATTRIBUTE7(j)
         , l_line_acks_rec.GLOBAL_ATTRIBUTE8(j)
         , l_line_acks_rec.GLOBAL_ATTRIBUTE9(j)
         , l_line_acks_rec.HEADER_ID(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE1(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE10(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE11(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE12(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE13(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE14(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE15(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE16(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE17(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE18(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE19(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE2(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE20(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE21(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE22(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE23(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE24(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE25(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE26(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE27(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE28(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE29(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE3(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE30(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE4(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE5(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE6(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE7(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE8(j)
         , l_line_acks_rec.INDUSTRY_ATTRIBUTE9(j)
         , l_line_acks_rec.INDUSTRY_CONTEXT(j)
         , l_line_acks_rec.TP_CONTEXT(j)
         , l_line_acks_rec.TP_ATTRIBUTE1(j)
         , l_line_acks_rec.TP_ATTRIBUTE2(j)
         , l_line_acks_rec.TP_ATTRIBUTE3(j)
         , l_line_acks_rec.TP_ATTRIBUTE4(j)
         , l_line_acks_rec.TP_ATTRIBUTE5(j)
         , l_line_acks_rec.TP_ATTRIBUTE6(j)
         , l_line_acks_rec.TP_ATTRIBUTE7(j)
         , l_line_acks_rec.TP_ATTRIBUTE8(j)
         , l_line_acks_rec.TP_ATTRIBUTE9(j)
         , l_line_acks_rec.TP_ATTRIBUTE10(j)
         , l_line_acks_rec.TP_ATTRIBUTE11(j)
         , l_line_acks_rec.TP_ATTRIBUTE12(j)
         , l_line_acks_rec.TP_ATTRIBUTE13(j)
         , l_line_acks_rec.TP_ATTRIBUTE14(j)
         , l_line_acks_rec.TP_ATTRIBUTE15(j)
	 , l_line_acks_rec.inventory_item(j)  --added for bug4309609
         , l_line_acks_rec.INVENTORY_ITEM_ID(j)
         , l_line_acks_rec.INVOICE_TO_CONTACT_ID(j)
         , l_line_acks_rec.INVOICE_TO_ORG_ID(j)
         , l_line_acks_rec.INVOICING_RULE_ID(j)
         , l_line_acks_rec.ORDERED_ITEM(j)
         , l_line_acks_rec.ITEM_REVISION(j)
         , l_line_acks_rec.item_identifier_type(j)
	 , l_line_acks_rec.LAST_ACK_CODE(j)
	 , l_line_acks_rec.LAST_ACK_DATE(j)
         , l_line_acks_rec.LAST_UPDATE_DATE(j)
         , l_line_acks_rec.LAST_UPDATE_LOGIN(j)
         , l_line_acks_rec.LAST_UPDATED_BY(j)
         , l_line_acks_rec.LATEST_ACCEPTABLE_DATE(j)
         , l_line_acks_rec.LINE_CATEGORY_CODE(j)
         , l_line_acks_rec.LINE_ID(j)
         , l_line_acks_rec.LINE_NUMBER(j)
         , l_line_acks_rec.LINE_TYPE_ID(j)
         , l_line_acks_rec.LINK_TO_LINE_ID(j)
         , l_line_acks_rec.MODEL_GROUP_NUMBER(j)
         , l_line_acks_rec.OPEN_FLAG(j)
         , l_line_acks_rec.OPERATION_CODE(j)
         , l_line_acks_rec.OPTION_FLAG(j)
         , l_line_acks_rec.OPTION_NUMBER(j)
         , l_line_acks_rec.ORDER_QUANTITY_UOM(j)
         , l_line_acks_rec.ORDER_SOURCE_ID(j)
         , l_line_acks_rec.ORDERED_QUANTITY(j)
         , l_line_acks_rec.ORG_ID(j)
         , l_line_acks_rec.ORIG_SYS_DOCUMENT_REF(j)
         , l_line_acks_rec.ORIG_SYS_LINE_REF(j)
         , l_line_acks_rec.ORIG_SYS_SHIPMENT_REF(j)
         , l_line_acks_rec.OVER_SHIP_REASON_CODE(j)
         , l_line_acks_rec.OVER_SHIP_RESOLVED_FLAG(j)
         , l_line_acks_rec.PAYMENT_TERM_ID(j)
         , l_line_acks_rec.PRICE_LIST_ID(j)
         , l_line_acks_rec.PRICING_ATTRIBUTE1(j)
         , l_line_acks_rec.PRICING_ATTRIBUTE10(j)
         , l_line_acks_rec.PRICING_ATTRIBUTE2(j)
         , l_line_acks_rec.PRICING_ATTRIBUTE3(j)
         , l_line_acks_rec.PRICING_ATTRIBUTE4(j)
         , l_line_acks_rec.PRICING_ATTRIBUTE5(j)
         , l_line_acks_rec.PRICING_ATTRIBUTE6(j)
         , l_line_acks_rec.PRICING_ATTRIBUTE7(j)
         , l_line_acks_rec.PRICING_ATTRIBUTE8(j)
         , l_line_acks_rec.PRICING_ATTRIBUTE9(j)
         , l_line_acks_rec.PRICING_CONTEXT(j)
         , l_line_acks_rec.PRICING_DATE(j)
         , l_line_acks_rec.PRICING_QUANTITY(j)
         , l_line_acks_rec.PRICING_QUANTITY_UOM(j)
         , l_line_acks_rec.PROGRAM_APPLICATION_ID(j)
         , l_line_acks_rec.PROGRAM_ID(j)
         , l_line_acks_rec.PROGRAM_UPDATE_DATE(j)
         , l_line_acks_rec.PROJECT_ID(j)
         , l_line_acks_rec.PROMISE_DATE(j)
         , l_line_acks_rec.REFERENCE_HEADER_ID(j)
         , l_line_acks_rec.REFERENCE_LINE_ID(j)
         , l_line_acks_rec.REFERENCE_TYPE(j)
         , l_line_acks_rec.REQUEST_DATE(j)
         , l_line_acks_rec.REQUEST_ID(j)
         , l_line_acks_rec.RESERVED_QUANTITY(j)
         , l_line_acks_rec.RETURN_ATTRIBUTE1(j)
         , l_line_acks_rec.RETURN_ATTRIBUTE10(j)
         , l_line_acks_rec.RETURN_ATTRIBUTE11(j)
         , l_line_acks_rec.RETURN_ATTRIBUTE12(j)
         , l_line_acks_rec.RETURN_ATTRIBUTE13(j)
         , l_line_acks_rec.RETURN_ATTRIBUTE14(j)
         , l_line_acks_rec.RETURN_ATTRIBUTE15(j)
         , l_line_acks_rec.RETURN_ATTRIBUTE2(j)
         , l_line_acks_rec.RETURN_ATTRIBUTE3(j)
         , l_line_acks_rec.RETURN_ATTRIBUTE4(j)
         , l_line_acks_rec.RETURN_ATTRIBUTE5(j)
         , l_line_acks_rec.RETURN_ATTRIBUTE6(j)
         , l_line_acks_rec.RETURN_ATTRIBUTE7(j)
         , l_line_acks_rec.RETURN_ATTRIBUTE8(j)
         , l_line_acks_rec.RETURN_ATTRIBUTE9(j)
         , l_line_acks_rec.RETURN_CONTEXT(j)
         , l_line_acks_rec.RETURN_REASON_CODE(j)
         , l_line_acks_rec.RLA_SCHEDULE_TYPE_CODE(j)
         , l_line_acks_rec.SALESREP_ID(j)
         , l_line_acks_rec.SCHEDULE_ARRIVAL_DATE(j)
         , l_line_acks_rec.SCHEDULE_SHIP_DATE(j)
         , l_line_acks_rec.SCHEDULE_STATUS_CODE(j)
         , l_line_acks_rec.SHIP_FROM_ORG_ID(j)
         , l_line_acks_rec.SHIP_MODEL_COMPLETE_FLAG(j)
         , l_line_acks_rec.SHIP_SET_ID(j)
         , l_line_acks_rec.SHIP_TO_CONTACT_ID(j)
         , l_line_acks_rec.SHIP_TO_ORG_ID(j)
         , l_line_acks_rec.SHIP_TOLERANCE_ABOVE(j)
         , l_line_acks_rec.SHIP_TOLERANCE_BELOW(j)
         , l_line_acks_rec.SHIPMENT_NUMBER(j)
         , l_line_acks_rec.SHIPMENT_PRIORITY_CODE(j)
         , l_line_acks_rec.SHIPPED_QUANTITY(j)
         , l_line_acks_rec.SHIPPING_METHOD_CODE(j)
         , l_line_acks_rec.SHIPPING_QUANTITY(j)
         , l_line_acks_rec.SHIPPING_QUANTITY_UOM(j)
         , l_line_acks_rec.SOLD_TO_ORG_ID(j)
         , l_line_acks_rec.SORT_ORDER(j)
         , l_line_acks_rec.SOURCE_DOCUMENT_ID(j)
         , l_line_acks_rec.SOURCE_DOCUMENT_LINE_ID(j)
         , l_line_acks_rec.SOURCE_DOCUMENT_TYPE_ID(j)
         , l_line_acks_rec.SOURCE_TYPE_CODE(j)
         , l_line_acks_rec.SPLIT_FROM_LINE_ID(j)
         , l_line_acks_rec.TASK_ID(j)
         , l_line_acks_rec.TAX_CODE(j)
         , l_line_acks_rec.TAX_DATE(j)
         , l_line_acks_rec.TAX_EXEMPT_FLAG(j)
         , l_line_acks_rec.TAX_EXEMPT_NUMBER(j)
         , l_line_acks_rec.TAX_EXEMPT_REASON_CODE(j)
         , l_line_acks_rec.TAX_POINT_CODE(j)
         , l_line_acks_rec.TAX_RATE(j)
         , l_line_acks_rec.TAX_VALUE(j)
         , l_line_acks_rec.UNIT_LIST_PRICE(j)
         , l_line_acks_rec.UNIT_SELLING_PRICE(j)
         , l_line_acks_rec.VEH_CUS_ITEM_CUM_KEY_ID(j)
         , l_line_acks_rec.VISIBLE_DEMAND_FLAG(j)
         , l_line_acks_rec.split_from_line_ref(j)
         , l_line_acks_rec.split_from_shipment_ref(j)
	 , l_line_acks_rec.Service_Txn_Reason_Code(j)
	 , l_line_acks_rec.Service_Txn_Comments(j)
	 , l_line_acks_rec.Service_Duration(j)
	 , l_line_acks_rec.Service_Start_Date(j)
	 , l_line_acks_rec.Service_End_Date(j)
	 , l_line_acks_rec.Service_Coterminate_Flag(j)
	 , l_line_acks_rec.Service_Number(j)
	 , l_line_acks_rec.Service_Period(j)
	 , l_line_acks_rec.Service_Reference_Type_Code(j)
	 , l_line_acks_rec.Service_Reference_Line_Id(j)
	 , l_line_acks_rec.Service_Reference_System_Id(j)
	 , l_line_acks_rec.Credit_Invoice_Line_Id(j)
         , l_line_acks_rec.service_reference_line(j)
         , l_line_acks_rec.service_reference_order(j)
         , l_line_acks_rec.service_reference_system(j)
         , l_line_acks_rec.customer_line_number(j)
         , l_line_acks_rec.user_item_description(j)
         , l_ack_type
         , l_line_acks_rec.blanket_number(j)
         , l_line_acks_rec.blanket_line_number(j)
         , l_line_acks_rec.original_inventory_item_id(j)
	 , l_line_acks_rec.original_ordered_item_id(j)
	 , l_line_acks_rec.original_ordered_item(j)
	 , l_line_acks_rec.original_item_identifier_type(j)
         , l_line_acks_rec.item_relationship_type(j)
         , l_line_acks_rec.customer_shipment_number(j)
         -- { Distributer Order related change
         , l_line_acks_rec.end_customer_id(j)
         , l_line_acks_rec.end_customer_contact_id(j)
         , l_line_acks_rec.end_customer_site_use_id(j)
         , l_line_acks_rec.ib_owner(j)
         , l_line_acks_rec.ib_current_location(j)
         , l_line_acks_rec.ib_installed_at_location(j)
         -- Distributer Order related change }
         , l_line_acks_rec.charge_periodicity_code(j)
        );
  End If;


Exception

  When Others Then
    If FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) Then
      FND_MSG_PUB.Add_Exc_Msg
       (G_PKG_NAME, 'OE_Line_Ack_Util.Insert_Row');
    End If;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


End Insert_Row;


PROCEDURE Delete_Row
(   p_line_id         IN  NUMBER,
    p_ack_type        IN  Varchar2,
    p_orig_sys_document_ref In Varchar2,
    p_orig_sys_line_ref   In Varchar2,
    p_orig_sys_shipment_ref In Varchar2,
    p_sold_to_org_id        In NUMBER,
    p_sold_to_org           In Varchar2,
    p_change_sequence       In Varchar2,
    p_request_id      In  NUMBER,
    p_header_id       In  NUMBER
)
IS
BEGIN

 oe_debug_pub.add('Input Header ID: '|| p_header_id);
 oe_debug_pub.add('Input Line ID: '|| p_line_id);
 oe_debug_pub.add('Input Orig Sys Document Ref: '|| p_orig_sys_document_ref);

   If (p_header_id is not null AND
       p_line_id is not null) Then

--request id is only used in where clause for 3a6

if p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_SSO
   Or p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_CSO
then
       DELETE  FROM OE_LINE_ACKS
       WHERE   HEADER_ID = p_header_id
         AND   LINE_ID   = p_line_id
         AND   ACKNOWLEDGMENT_FLAG is null
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
       DELETE  FROM OE_LINE_ACKS
       WHERE   HEADER_ID = p_header_id
         AND   LINE_ID 	= p_line_id
         AND   ACKNOWLEDGMENT_FLAG is null
         -- Change this condition once a type is inserted for POAO/POCAO
         AND nvl(acknowledgment_type,'ALL') = nvl(p_ack_type,'ALL')
         AND  nvl(sold_to_org_id, FND_API.G_MISS_NUM)
           =  nvl(p_sold_to_org_id, FND_API.G_MISS_NUM)
	 AND  nvl(sold_to_org, FND_API.G_MISS_CHAR)
           =  nvl(p_sold_to_org, FND_API.G_MISS_CHAR)
         AND  nvl(change_sequence, FND_API.G_MISS_CHAR)
           =  nvl(p_change_sequence, FND_API.G_MISS_CHAR);
end if;
       if sql%rowcount > 0 then
          oe_debug_pub.add('Row Deleted from the oe_line_Acks table');
       end If;
   Elsif (p_orig_sys_document_ref is not null) Then
       oe_debug_pub.add('before deleting line acknowledgment by orig_sys_document_Ref, line_ref and shipment_ref ',3);

if p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_SSO
   Or p_ack_type = oe_acknowledgment_pub.G_TRANSACTION_CSO
then

       DELETE  FROM OE_LINE_ACKS
       WHERE   ORIG_SYS_DOCUMENT_REF    = p_orig_sys_document_ref
          AND  ORIG_SYS_LINE_REF        = p_orig_sys_line_ref
          AND  ORIG_SYS_SHIPMENT_REF    = p_orig_sys_shipment_ref
          AND  nvl(ACKNOWLEDGMENT_TYPE, 'ALL')  = nvl(p_ack_type,'ALL')
	  AND  nvl(sold_to_org_id, FND_API.G_MISS_NUM)
            =  nvl(p_sold_to_org_id, FND_API.G_MISS_NUM)
  	  AND  nvl(sold_to_org, FND_API.G_MISS_CHAR)
            =  nvl(p_sold_to_org, FND_API.G_MISS_CHAR)
          AND  nvl(change_sequence, FND_API.G_MISS_CHAR)
            =  nvl(p_change_sequence, FND_API.G_MISS_CHAR)
          AND  REQUEST_ID               = p_request_id;

else

       DELETE  FROM OE_LINE_ACKS
       WHERE   ORIG_SYS_DOCUMENT_REF    = p_orig_sys_document_ref
          AND  ORIG_SYS_LINE_REF        = p_orig_sys_line_ref
          AND  ORIG_SYS_SHIPMENT_REF    = p_orig_sys_shipment_ref
          AND  nvl(ACKNOWLEDGMENT_TYPE, 'ALL')  = nvl(p_ack_type,'ALL')
	  AND  nvl(sold_to_org_id, FND_API.G_MISS_NUM)
            =  nvl(p_sold_to_org_id, FND_API.G_MISS_NUM)
	   AND  nvl(sold_to_org, FND_API.G_MISS_CHAR)
            =  nvl(p_sold_to_org, FND_API.G_MISS_CHAR)
	  AND  nvl(change_sequence, FND_API.G_MISS_CHAR)
            =  nvl(p_change_sequence, FND_API.G_MISS_CHAR);


end if;

       if sql%rowcount > 0 then
          oe_debug_pub.add('Row(s) Deleted from the oe_line_acks table');
       end If;
    Else
       oe_debug_pub.add('not deleting any rows from oe_line_acks ',3);

    End If;


EXCEPTION

    WHEN OTHERS THEN

        oe_debug_pub.Add('Encountered Others Error Exception in OE_Line_Ack_Util.Delete_Row: '||sqlerrm);

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           FND_MSG_PUB.Add_Exc_Msg
            	(G_PKG_NAME, 'OE_Line_Ack_Util.Delete_Row');
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;





END OE_Line_Ack_Util;

/
