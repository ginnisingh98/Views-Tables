--------------------------------------------------------
--  DDL for Package Body OE_DELAYED_REQUESTS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DELAYED_REQUESTS_UTIL" AS
/* $Header: OEXUREQB.pls 120.23.12010000.18 2012/09/14 08:15:27 rahujain ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Delayed_Requests_UTIL';

-- Procedure to validate quota percent total

PROCEDURE Validate_LSC_QUOTA_TOTAL
( x_return_status OUT NOCOPY Varchar2

  , p_line_id     IN NUMBER
  ) IS
l_percent_total Number;

Cursor C_LSC_Quota_Total(p_line_id number) IS
   Select sum(Percent) Per_total
   From oe_sales_credits sc,
	   oe_sales_credit_types sct
   Where line_id = p_line_id
   And sct.sales_credit_type_id = sc.sales_credit_type_id
   And sct.quota_flag = 'Y';

BEGIN

   oe_debug_pub.add('Entering OE_DELAYED_REQUESTS_UTIL.VALIDATE_LSC_QUOTA_TOTAL', 1);

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   OPEN C_LSC_Quota_Total(p_line_id);
   FETCH C_LSC_Quota_Total
   INTO  l_percent_total;
   CLOSE C_LSC_Quota_Total;

-- The Zero percent is added to include functionality which will exclude
-- Salesperson from getting Sales Credit
   IF (l_percent_total <> 100 AND
	  l_percent_total <> 0)THEN
       fnd_message.set_name('ONT','OE_VAL_TTL_LINE_CREDIT');
       FND_MESSAGE.SET_TOKEN('TOTAL',to_char(l_percent_total));
       OE_MSG_PUB.Add;
       x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   oe_debug_pub.add('Exiting OE_DELAYED_REQUESTS_UTIL.VALIDATE_LSC_QUOTA_TOTAL', 1);

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
            ,   'Validate_LSC_QUOTA_TOTAL'
);
        END IF;
END Validate_LSC_QUOTA_TOTAL;

-- Procedure to validate quota percent total
PROCEDURE Validate_HSC_QUOTA_TOTAL
( x_return_status OUT NOCOPY Varchar2

  , p_header_id     IN NUMBER
  ) IS

BEGIN

   oe_debug_pub.add('Entering OE_DELAYED_REQUESTS_UTIL.VALIDATE_HSC_QUOTA_TOTAL', 1);

     OE_Validate_Header_Scredit.Validate_HSC_QUOTA_TOTAL(x_return_status => x_return_status,
                    p_header_id     => p_header_id);

   oe_debug_pub.add('Exiting OE_DELAYED_REQUESTS_UTIL.VALIDATE_HSC_QUOTA_TOTAL', 1);

EXCEPTION

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_HSC_QUOTA_TOTAL:'||SQLERRM
            );
        END IF;
END Validate_HSC_QUOTA_TOTAL;


PROCEDURE DFLT_Hscredit_Primary_Srep
 ( p_header_id     IN Number
  ,p_SalesRep_id    IN Number
,x_return_status OUT NOCOPY Varchar2

   ) IS
l_sales_credits_count   Number;
l_sales_credit_id   Number;

/* Changed the above cursor definition to fix the bug 1822931 */
l_scredit_type_id number;
l_Header_Scredit_rec          OE_Order_PUB.Header_Scredit_Rec_Type;
l_old_Header_Scredit_rec      OE_Order_PUB.Header_Scredit_Rec_Type;
l_Header_Scredit_tbl          OE_Order_PUB.Header_Scredit_Tbl_Type;
l_old_Header_Scredit_tbl      OE_Order_PUB.Header_Scredit_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(30);
x_msg_count                   NUMBER;
x_msg_data                    VARCHAR2(2000);
Begin

    oe_debug_pub.add('Entering OE_DELAYED_REQUESTS_UTIL.DFLT_HSCREDIT_PRIMARY_SREP', 1);
      OE_HEADER_SCREDIT_UTIL.DFLT_Hscredit_Primary_Srep
         ( p_header_id    =>p_header_id
          ,p_SalesRep_id  =>p_SalesRep_id
          ,x_return_status=>x_return_status);
    oe_debug_pub.add('Exiting OE_DELAYED_REQUESTS_UTIL.DFLT_HSCREDIT_PRIMARY_SREP', 1);

EXCEPTION

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'DFLT_Hscredit_Primary_Srep:'||SQLERRM
            );
        END IF;
End DFLT_Hscredit_Primary_Srep;


Procedure Cascade_Service_Scredit
( x_return_status OUT NOCOPY Varchar2

 ,p_request_rec       IN  OE_ORDER_PUB.request_rec_type)
IS
 l_Line_Scredit_tbl      OE_Order_PUB.Line_Scredit_Tbl_Type;
 l_old_Line_Scredit_tbl  OE_Order_PUB.Line_Scredit_Tbl_Type;
 l_control_rec           OE_GLOBALS.Control_Rec_Type;
 l_line_id     NUMBER;
 l_line_id1    NUMBER;
 l_line_set_id NUMBER;
 l_item_type_code VARCHAR2(30);
 l_temp        NUMBER;
 l_service_reference_line_id NUMBER;
 l_inv_item_id number;
 l_temp_inv_item_id number;
 l_count NUMBER := 0;
 l_new_quota_flag  VARCHAR2(1);
 l_old_quota_flag  VARCHAR2(1);
 l_per_total       NUMBER;
 l_new_salesrep_id NUMBER;
 l_old_salesrep_id NUMBER;
 l_new_sales_credit_type_id NUMBER;
 l_old_sales_credit_type_id NUMBER;
 l_new_percent NUMBER;
 l_old_percent NUMBER;
 l_operation   VARCHAR2(30);
 l_sales_credit_type_id NUMBER;
 l_salesrep_id NUMBER;
 l_percent NUMBER;
 l_q_percent NUMBER;
 l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
 l_sales_credit_id NUMBER;
 l_service_type_code VARCHAR2(30);  --Bug 4946843

 CURSOR PARENT IS
 SELECT Line_id, item_type_code,line_set_id,
	   Service_reference_line_id,
	   inventory_item_id,
	   service_reference_type_code --Bug 4946843
 FROM   OE_ORDER_LINES_ALL
 WHERE  Line_id = l_line_id;

 CURSOR MODEL_SERVICES IS
 SELECT /* MOAC_SQL_CHANGE */ line_id, header_id
 FROM   OE_ORDER_LINES
 WHERE  service_reference_line_id
             in (SELECT line_id
                 FROM   oe_order_lines_all
                 WHERE top_model_line_id = l_line_id1)
 AND   line_id <> l_line_id and
 inventory_item_id = l_temp_inv_item_id;


BEGIN

  OE_DEBUG_PUB.Add('Entering OE_DELAYED_REQUESTS_UTIL.Cascade_Service_Scredit',1);
  l_line_id          := p_request_rec.param8;
  l_new_salesrep_id  := p_request_rec.param1;
  l_old_salesrep_id  := p_request_rec.param2;
  l_new_sales_credit_type_id  := p_request_rec.param3;
  l_old_sales_credit_type_id  := p_request_rec.param4;
  l_new_percent  := p_request_rec.param5;
  l_old_percent  := p_request_rec.param6;
  l_operation       := p_request_rec.param7;

  oe_debug_pub.add('l_line_id          :=  ' || p_request_rec.param8,2);
  oe_debug_pub.add('l_new_salesrep_id  :=  ' || p_request_rec.param1,2);
  oe_debug_pub.add('l_old_salesrep_id  := ' || p_request_rec.param2,2);
  oe_debug_pub.add('l_new_sales_credit_type_id  :=' ||  p_request_rec.param3,2);
  oe_debug_pub.add('l_old_sales_credit_type_id  := ' || p_request_rec.param4,2);
  oe_debug_pub.add('l_new_percent  := ' || p_request_rec.param5,2);
  oe_debug_pub.add('l_old_percent  := ' || p_request_rec.param6,2);
  oe_debug_pub.add('l_operation       := ' || p_request_rec.param7,2);

  OPEN PARENT;
  FETCH  PARENT
  INTO  l_line_id,l_item_type_code,l_line_set_id,l_service_reference_line_id,
  l_inv_item_id,l_service_type_code; --Bug 4946843
  CLOSE PARENT;

  IF l_item_type_code = 'SERVICE'
  AND l_service_type_code = 'ORDER' --Bug 4946843
  AND l_service_reference_line_id IS NOT NULL THEN

    l_line_id := l_service_reference_line_id;
    l_temp_inv_item_id := l_inv_item_id;

    OPEN PARENT;
    FETCH PARENT
    INTO  l_line_id1,l_item_type_code,l_line_set_id,l_service_reference_line_id
    ,l_inv_item_id,l_service_type_code; --Bug 4946843
    CLOSE PARENT;

    IF l_item_type_code = 'MODEL' THEN

	  oe_debug_pub.Add('Need to cascade the sales credit');

	FOR I IN MODEL_SERVICES LOOP
      l_temp := 0;
	 -- For create check the existance of the record based on the
	 -- new data and for other operations check based on the old data.


	 IF l_operation = OE_GLOBALS.G_OPR_CREATE  THEN

	    l_sales_credit_type_id := l_new_sales_credit_type_id;
	    l_salesrep_id := l_new_salesrep_id;
	    l_percent := l_new_percent;
	  oe_debug_pub.Add('In l_operation if');
      ELSE
	    l_sales_credit_type_id := l_old_sales_credit_type_id;
	    l_salesrep_id := l_old_salesrep_id;
	    l_percent := l_old_percent;
	 END IF;
      BEGIN
       Select '1', sales_credit_id, nvl(percent,0)
       INTO    l_temp, l_sales_credit_id, l_q_percent
       from  oe_sales_credits
       Where header_id = i.header_id
       AND   line_id = i.line_id
       And   sales_credit_type_id = l_sales_credit_type_id
       AND   salesrep_id          = l_salesrep_id;
--       AND   Percent              = l_percent;

	  oe_debug_pub.Add('l_q_percent  ' || l_q_percent);
	  oe_debug_pub.Add('l_percent  ' || l_percent);
      EXCEPTION

       WHEN NO_DATA_FOUND THEN

         l_temp := 0;

       WHEN TOO_MANY_ROWS THEN

         l_temp := 2;

       WHEN OTHERS THEN

         l_temp := 10;

      END;

	  oe_debug_pub.Add('l_temp: ' || l_temp);
	 --Get Quota flag.

	 BEGIN

	   Select quota_flag
	   Into   l_new_quota_flag
	   From   oe_sales_credit_types
	   Where  sales_credit_type_id = l_new_sales_credit_type_id;

	   IF l_new_sales_credit_type_id <> l_old_sales_credit_type_id THEN

	     Select quota_flag
	     Into   l_old_quota_flag
	     From   oe_sales_credit_types
	     Where  sales_credit_type_id = l_old_sales_credit_type_id;

	   ELSE

		 l_old_quota_flag := l_new_quota_flag;

	   END IF;

      END;

       IF l_temp = 0 THEN -- Only when record not exist for child.
	    IF l_operation = OE_GLOBALS.G_OPR_CREATE THEN

          IF l_new_quota_flag = 'Y' THEN

	       oe_debug_pub.Add(' In create  and quota');
            Select nvl(sum(Percent),0) Per_total
            Into  l_per_total
            From  oe_sales_credits sc,
                  oe_sales_credit_types sct
            Where header_id = i.header_id
            AND   line_id = i.line_id
            And   sct.sales_credit_type_id = sc.sales_credit_type_id
            And   sct.quota_flag = 'Y';

          END IF; -- Quota flag.

	    oe_debug_pub.Add('  L_per_total : ' || nvl(l_per_total,0) || 'End');
	    oe_debug_pub.Add('  L_new_percent :  ' || nvl(l_new_percent,0) || 'End');

         IF (l_per_total + l_new_percent) <= 100
         OR l_new_quota_flag = 'N'  THEN

	       oe_debug_pub.Add('  Populate sales credit ');
              -- Child.service does not have a sales credit and create the
              -- same.
            l_count := l_count + 1;

            l_Line_Scredit_tbl(l_count) := OE_Order_PUB.G_MISS_LINE_SCREDIT_REC;
            l_Line_Scredit_tbl(l_count).Header_id := I.Header_id;
            l_Line_Scredit_tbl(l_count).Line_id   := I.Line_id;
            l_Line_Scredit_tbl(l_count).SalesRep_Id := l_new_salesRep_id;
            l_Line_Scredit_tbl(l_count).Sales_credit_type_id :=
                                               l_new_sales_credit_type_id;
            l_Line_Scredit_tbl(l_count).PERCENT := l_new_percent;
            l_Line_Scredit_tbl(l_count).Operation := OE_GLOBALS.G_OPR_CREATE;

         END IF; -- Check the percent

	   END IF; -- Create.
      ELSIF l_temp = 1
	 AND   l_percent = l_q_percent THEN

         --Sales credir record exists for the child service line.

        IF l_operation = OE_GLOBALS.G_OPR_UPDATE THEN

          oe_msg_pub.add('In Update');

          IF l_new_quota_flag = 'Y' THEN

            Select nvl(sum(Percent),0) Per_total
            Into  l_per_total
            From  oe_sales_credits sc,
                  oe_sales_credit_types sct
            Where header_id = i.header_id
            AND   line_id = i.line_id
            And   sct.sales_credit_type_id = sc.sales_credit_type_id
            And   sct.quota_flag = 'Y';


             IF l_old_quota_flag = 'Y' THEN

			  l_per_total := l_per_total - nvl(l_old_percent,0) +
						  nvl(l_new_percent,0);

		   ELSE

			  l_per_total := l_per_total + nvl(l_new_percent,0);

             END IF;

          END IF; -- Quota flag.

	    oe_debug_pub.Add('  L_per_total : ' || nvl(l_per_total,0) || 'End');
	    oe_debug_pub.Add('  L_new_percent :  ' || nvl(l_new_percent,0) || 'End');


          IF nvl(l_per_total,0)  <= 100
          OR l_new_quota_flag = 'N'  THEN

           l_count := l_count + 1;

		 -- Setup new sales scredit record.
           l_Line_Scredit_tbl(l_count) := OE_Order_PUB.G_MISS_LINE_SCREDIT_REC;
           l_Line_Scredit_tbl(l_count).sales_credit_id := l_sales_credit_id;
           l_Line_Scredit_tbl(l_count).Header_id := I.Header_id;
           l_Line_Scredit_tbl(l_count).Line_id   := I.Line_id;
           l_Line_Scredit_tbl(l_count).SalesRep_Id := l_new_salesRep_id;
           l_Line_Scredit_tbl(l_count).Sales_credit_type_id :=
                                             l_new_sales_credit_type_id;
           l_Line_Scredit_tbl(l_count).PERCENT := l_new_percent;
		 /* Start Audit Trail */
		 l_Line_Scredit_tbl(l_count).change_reason := 'SYSTEM';
		 /* End Audit Trail */
           l_Line_Scredit_tbl(l_count).Operation := OE_GLOBALS.G_OPR_UPDATE;

		END IF; -- Percent.
        ELSIF l_operation = OE_GLOBALS.G_OPR_DELETE
	   AND   l_percent = l_q_percent THEN

           l_count := l_count + 1;
           l_Line_Scredit_tbl(l_count) := OE_Order_PUB.G_MISS_LINE_SCREDIT_REC;
           l_Line_Scredit_tbl(l_count).sales_credit_id := l_sales_credit_id;
           l_Line_Scredit_tbl(l_count).Header_id := I.Header_id;
           l_Line_Scredit_tbl(l_count).Line_id   := I.Line_id;
           l_Line_Scredit_tbl(l_count).Operation := OE_GLOBALS.G_OPR_DELETE;
        END IF; -- operation
      END IF; -- temp
	END LOOP;
    END IF; -- Model.
  END IF; -- Service

 oe_debug_pub.Add('  l_count :  ' || to_char(l_count));
  IF l_count > 0 THEN -- Have some data that need to get cascaded.

   --  Call OE_Order_PVT.Process_order to insert sales credits.
    -- Set recursion mode.
    --   OE_GLOBALS.G_RECURSION_MODE := 'Y';

      OE_ORDER_PVT.Line_Scredits
      (p_validation_level            => FND_API.G_VALID_LEVEL_FULL
      ,p_control_rec                 => l_control_rec
      ,p_x_Line_Scredit_tbl          => l_Line_Scredit_tbl
      ,p_x_old_Line_Scredit_tbl      => l_old_Line_Scredit_tbl
      ,x_return_status               => l_return_status);

    -- Reset recursion mode.
    --   OE_GLOBALS.G_RECURSION_MODE := 'N';

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;

--comment out for notification project
/*       OE_ORDER_PVT.Process_Requests_And_notify
       ( p_process_requests       => FALSE
        ,p_notify                 => TRUE
        ,x_return_status          => l_return_status
        ,p_Line_Scredit_tbl       => l_Line_Scredit_tbl
        ,p_old_Line_Scredit_tbl   => l_old_Line_Scredit_tbl);

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;
*/
       -- Clear Table
       l_Line_Scredit_tbl.DELETE;

  END IF; -- l_count.

  OE_DEBUG_PUB.Add('Exiting OE_DELAYED_REQUESTS_UTIL.Cascade_Service_Scredit',1);
  x_return_status := l_return_status;

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
            ,   'CASCADE_SERVICE_SCREDIT'
            );
        END IF;



END Cascade_Service_Scredit;

PROCEDURE UPDATE_LINK_TO_LINE_ID
( x_return_status OUT NOCOPY Varchar2

                  ,p_top_model_line_id  IN NUMBER
                 )
IS
BEGIN

        null;

END UPDATE_LINK_TO_LINE_ID;

-- Procedure to Check for Duplicate Discounts
PROCEDURE check_duplicate
(p_request_rec	     IN  oe_order_pub.request_rec_type,
x_return_status OUT NOCOPY VARCHAR2)

  IS
l_entity_code	     VARCHAR2(30);
l_entity_id	     NUMBER := NULL;
l_header_id	     NUMBER := NULL;
l_line_id		     NUMBER := NULL;
l_discount_id     	NUMBER := 0;
l_duplicate	     VARCHAR2(30) := NULL;
l_return_status	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

DUPLICATE_DISCOUNT	EXCEPTION;

BEGIN

   oe_debug_pub.add('Entering OE_DELAYED_REQUESTS_UTIL.CHECK_DUPLICATE', 1);

   l_entity_id		:= p_request_rec.entity_id;
   l_entity_code	:= p_request_rec.entity_code;
   l_discount_id	:= To_number(p_request_rec.param1);
   l_header_id		:= To_number(p_request_rec.param2);
   l_line_id		:= To_number(p_request_rec.param3);

   oe_debug_pub.ADD('OEXSRLNB: Check Duplicate. '||
		    ' entity_code = ' || l_entity_code, 2);


   -- Check if same discount has already been applied
   -- before on the header or any line
   IF l_entity_code = OE_GLOBALS.G_ENTITY_HEADER_ADJ THEN

     SELECT  'DUPLICATE_DISCOUNT'
	INTO    l_duplicate
	FROM    oe_price_adjustments
	WHERE   header_id = l_header_id
	AND     discount_id = l_discount_id
	AND     price_adjustment_id <> Nvl(l_entity_id, -1)
	AND     line_id IS NULL;

	IF SQL%rowcount <> 0
	  THEN
	   l_return_status := FND_API.G_RET_STS_ERROR;

	   IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	     THEN

	      fnd_message.set_name('ONT', 'OE_DIS_DUPLICATE_ORD_DISC');
	      OE_MSG_PUB.Add;

	   END IF;

	   RAISE DUPLICATE_DISCOUNT;

	END IF;


    -- Check if same discount has already been applied
    -- before on the line
    ELSIF l_entity_code = OE_GLOBALS.G_ENTITY_LINE_ADJ THEN

      SELECT  'DUPLICATE_DISCOUNT'
	 INTO    l_duplicate
	 FROM    oe_price_adjustments
	 WHERE   header_id = l_header_id
	 AND     discount_id = l_discount_id
	 AND     line_id = l_line_id
	 AND     price_adjustment_id <> Nvl(l_entity_id, -1);

      IF SQL%rowcount <> 0 THEN
	    l_return_status := FND_API.G_RET_STS_ERROR;

	    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	    THEN

	       fnd_message.set_name('ONT', 'OE_DIS_DUPLICATE_LIN_DISC');
	       OE_MSG_PUB.Add;

	    END IF;

	    RAISE DUPLICATE_DISCOUNT;

      END IF;

   END IF;


   x_return_status := l_return_status;

   oe_debug_pub.add('Exiting OE_DELAYED_REQUESTS_UTIL.CHECK_DUPLICATE', 1);

EXCEPTION

   WHEN NO_DATA_FOUND OR DUPLICATE_DISCOUNT
     THEN
      x_return_status := l_return_status;

   WHEN OTHERS
     THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
	 OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'CHECK_DUPLICATE'
            );
      END IF;

END CHECK_DUPLICATE;

--Procedure to Check Fixed price Discounts
PROCEDURE check_fixed_price
(p_request_rec	   IN oe_order_pub.request_rec_type,
x_return_status OUT NOCOPY VARCHAR2)

 IS
l_entity_code	     VARCHAR2(30);
l_entity_id	     NUMBER := NULL;
l_header_id	     NUMBER := NULL;
l_line_id		     NUMBER := NULL;
l_discount_line_id	NUMBER := 0;
l_count		     NUMBER;
l_discount_count	NUMBER;
l_fixed_price	     VARCHAR2(30) := NULL;
l_discount_name     VARCHAR2(30) := NULL;
l_return_status	VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
l_number		     NUMBER := 0;


FIXED_PRICE	EXCEPTION;
FIXED_PRICE_VIOLATE	EXCEPTION;

CURSOR all_adjustments IS
SELECT count(p.price_adjustment_id)
FROM   oe_price_adjustments p
WHERE  p.header_id = l_header_id
AND    (p.line_id = l_line_id
OR      p.line_id IS NULL) ;

CURSOR hdr_line_adjustments IS
SELECT p.line_id
FROM   oe_price_adjustments p
WHERE  p.header_id = l_header_id
AND    p.line_id IS NOT NULL
ORDER by p.line_id;


BEGIN

   oe_debug_pub.add('Entering OE_DELAYED_REQUESTS_UTIL.CHECK_FIXED_PRICE', 1);

   l_entity_id		   := p_request_rec.entity_id;
   l_entity_code	   := p_request_rec.entity_code;
   l_discount_line_id  := To_number(p_request_rec.param1);
   l_header_id		   := To_number(p_request_rec.param2);
   l_line_id		   := To_number(p_request_rec.param3);


   oe_debug_pub.ADD('OEXSRLNB: Check Fixed Price. '||
		    ' entity_code = ' || l_entity_code, 2);

   IF l_entity_code = OE_GLOBALS.G_ENTITY_HEADER_ADJ THEN
      FOR l_hdr_adjustment IN hdr_line_adjustments LOOP

	     l_line_id := l_hdr_adjustment.line_id;
	     l_number := l_number + 1;

	     OPEN  all_adjustments;
	     FETCH all_adjustments INTO l_discount_count;
	     CLOSE all_adjustments;

          SELECT  count(d.name)
	     INTO  l_count
	     FROM  oe_price_adjustments adj,
                oe_discount_lines dln,
	           oe_discounts d
	     WHERE adj.header_id = l_header_id
	     AND   Nvl(adj.line_id, l_line_id) = l_line_id
          AND   d.discount_id = adj.discount_id
	     AND   dln.discount_line_id = adj.discount_line_id
	     AND   dln.price IS NOT NULL
	     AND   ROWNUM = 1;

	     IF l_count <> 0
          AND l_discount_count = 1 THEN
           oe_debug_pub.ADD('OEXSRLNB2: Check Fixed Price. '||
		    ' entity_code = ' || l_entity_code, 2);
	       l_return_status := FND_API.G_RET_STS_ERROR;
	       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	       THEN

	         FND_MESSAGE.SET_NAME('ONT', 'OE_DIS_FIXED_PRICE_HEADER');
	         FND_MESSAGE.SET_TOKEN('NUMBER', to_char(l_number));
	         OE_MSG_PUB.Add;


	       END IF;
	       RAISE FIXED_PRICE_VIOLATE;
	     END IF;
      END LOOP;
   END IF;

   IF l_entity_code = OE_GLOBALS.G_ENTITY_LINE_ADJ THEN

      SELECT  count(adj.price_adjustment_id)
	 INTO    l_count
	 FROM    oe_price_adjustments adj
	 WHERE   adj.header_id = l_header_id
	 AND     Nvl(adj.line_id, l_line_id) = l_line_id
	 AND     exists
		   (SELECT 'fixed_price'
		    FROM   oe_discount_lines dln
		    WHERE  dln.discount_line_id = l_discount_line_id
		    AND    dln.price IS NOT NULL)
	 AND ROWNUM = 1;

      IF l_count <> 0 THEN

	   IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN

	     FND_MESSAGE.SET_NAME('ONT', 'OE_DIS_FIXED_PRICE');
	     OE_MSG_PUB.Add;

	   END IF;

	   RAISE FIXED_PRICE;

      END IF;

	 OPEN all_adjustments;
	 FETCH all_adjustments INTO l_discount_count;
	 CLOSE all_adjustments;


      SELECT  d.name
	 INTO    l_fixed_price
	 FROM    oe_price_adjustments adj,
              oe_discount_lines dln,
	         oe_discounts d
	 WHERE   adj.header_id = l_header_id
	 AND     Nvl(adj.line_id, l_line_id) = l_line_id
      AND     d.discount_id = adj.discount_id
	 AND     dln.discount_line_id = adj.discount_line_id
	 AND     dln.price IS NOT NULL
	 AND     ROWNUM = 1;

       oe_debug_pub.ADD('OEXSRLNB1: Check Fixed Price. '||
		    ' entity_code = ' || l_entity_code, 2);
      IF  SQL%rowcount <> 0
      AND l_discount_count = 1 THEN
         oe_debug_pub.ADD('OEXSRLNB2: Check Fixed Price. '||
		    ' entity_code = ' || l_entity_code, 2);
	    l_return_status := FND_API.G_RET_STS_ERROR;
	    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	    THEN

	      FND_MESSAGE.SET_NAME('ONT', 'OE_DIS_FIXED_PRICE_VIOL');
	      FND_MESSAGE.SET_TOKEN('NAME', l_fixed_price);
	      OE_MSG_PUB.Add;

	    END IF;

	    RAISE FIXED_PRICE_VIOLATE;

      END IF;
   END IF;


   x_return_status := FND_API.G_RET_STS_SUCCESS;

   oe_debug_pub.add('Exiting OE_DELAYED_REQUESTS_UTIL.CHECK_FIXED_PRICE', 1);

EXCEPTION

   WHEN NO_DATA_FOUND OR FIXED_PRICE
     THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   WHEN  FIXED_PRICE_VIOLATE
     THEN
      x_return_status := l_return_status;


   WHEN OTHERS
     THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
	 OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'CHECK_FIXED_PRICE'
            );
      END IF;

END CHECK_FIXED_PRICE;


PROCEDURE check_percentage
(p_request_rec	IN oe_order_pub.request_rec_type,
x_return_status OUT NOCOPY VARCHAR2)

IS
l_control_rec	     OE_GLOBALS.Control_Rec_Type;
l_entity_code	     VARCHAR2(30);
l_entity_id	     NUMBER := NULL;
l_header_id	     NUMBER := NULL;
l_line_id		     NUMBER := NULL;
l_percentage	     NUMBER := 0;
l_percent_total	NUMBER := 0;
l_return_status	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_apply_order_adjs	VARCHAR2(1) :=
                    Nvl(fnd_profile.value('OE_APPLY_ORDER_ADJS_TO_SERVICE'),
				   'N');

percentage_exceeded	EXCEPTION;


CURSOR all_adjustments IS
SELECT  p.price_adjustment_id, Nvl(p.line_id, -1) line_id
  FROM  oe_price_adjustments p,
        oe_order_lines o
 WHERE  p.header_id = l_header_id
  AND   o.header_id = l_header_id
  AND  (p.line_id = o.line_id
   OR   p.line_id IS NULL)
ORDER  BY p.line_id;


CURSOR hdr_adj_total IS
SELECT Nvl(SUM(percent), 0)
  FROM oe_price_adjustments p
 WHERE header_id = l_header_id
   AND  line_id IS NULL;


CURSOR line_adj_total IS
SELECT Nvl(SUM(percent), 0) + l_percent_total
  FROM oe_price_adjustments
 WHERE header_id = l_header_id
   AND  line_id = l_line_id;



CURSOR max_line_adj_total IS
SELECT NVL( MAX(SUM(PERCENT)), 0) + l_percent_total
  FROM OE_PRICE_ADJUSTMENTS P, OE_ORDER_LINES L
 WHERE P.HEADER_ID = l_header_id
   AND P.LINE_ID IS NOT NULL
   AND P.LINE_ID = L.LINE_ID
GROUP BY P.line_id;


BEGIN

   oe_debug_pub.add('Entering OE_DELAYED_REQUESTS_UTIL.CHECK_PERCENTAGE', 1);

   l_entity_code	:= p_request_rec.entity_code;

   oe_debug_pub.ADD('OEXSRLNB: Check Percentage. '||
		    ' entity_code = ' || l_entity_code, 2);


   -- Check if maximum percentage has not been execeded on the
   -- header price adjustment
   IF l_entity_code = OE_GLOBALS.G_ENTITY_HEADER_ADJ
     THEN

      l_header_id	:= p_request_rec.entity_id;

      oe_debug_pub.ADD('OEXSRLNB: check header percentage', 2);

      OPEN hdr_adj_total;
      FETCH hdr_adj_total INTO l_percent_total;
      CLOSE hdr_adj_total;

      OPEN max_line_adj_total;
      FETCH max_line_adj_total INTO l_percent_total;
      CLOSE max_line_adj_total;

      oe_debug_pub.ADD('OEXSRLNB: maximum percentage total = ' ||
		       To_char(l_percent_total), 2);

      IF ( l_percent_total > 100 ) THEN

	    l_return_status := FND_API.G_RET_STS_ERROR;

	    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	    THEN

	      FND_MESSAGE.SET_NAME('ONT','OE_DIS_ADJUSTMENT_TOTAL');
	      FND_MESSAGE.SET_TOKEN('TOTAL', To_char(l_percent_total));
	      OE_MSG_PUB.Add;

	    END IF;

	    RAISE percentage_exceeded;

      END IF;


    -- Check if maximum percentage has not been execeded on the
    -- line price adjustment
    ELSIF l_entity_code = OE_GLOBALS.G_ENTITY_LINE_ADJ THEN

      l_line_id		:= p_request_rec.entity_id;
      l_header_id	:= To_number(p_request_rec.param1);

      oe_debug_pub.ADD('OEXSRLNB: check line percentage', 2);

      OPEN hdr_adj_total;
      FETCH hdr_adj_total INTO l_percent_total;
      CLOSE hdr_adj_total;

      OPEN line_adj_total;
      FETCH line_adj_total INTO l_percent_total;
      CLOSE line_adj_total;

      oe_debug_pub.ADD('OEXSRLNB: line percentage total = ' ||
		       To_char(l_percent_total), 2);


      IF ( l_percent_total > 100 ) THEN

	    l_return_status := FND_API.G_RET_STS_ERROR;

	    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	    THEN

	      FND_MESSAGE.SET_NAME('ONT','OE_DIS_ADJUSTMENT_TOTAL');
	      FND_MESSAGE.SET_TOKEN('TOTAL', To_char(l_percent_total));
	      OE_MSG_PUB.Add;

	    END IF;

	    RAISE percentage_exceeded;

      END IF;


    -- Check all header and line level price adjustments in execess of
    -- maximum allowable price adjustments
    -- This is a call from Order Import

    ELSIF l_entity_code IS NULL
    THEN

      FOR l_adjustment IN all_adjustments LOOP

	 -- How to get header id in this case ????????
	   l_line_id := l_adjustment.line_id;
	   l_entity_id := l_adjustment.price_adjustment_id;

	   IF l_line_id = -1 THEN	-- header level price adjustment

	    OPEN hdr_adj_total;
	    FETCH hdr_adj_total INTO l_percent_total;
	    CLOSE hdr_adj_total;

	    OPEN max_line_adj_total;
	    FETCH max_line_adj_total INTO l_percent_total;
	    CLOSE max_line_adj_total;

	   ELSE			-- line level price adjustment

	    OPEN line_adj_total;
	    FETCH line_adj_total INTO l_percent_total;
	    CLOSE line_adj_total;

	   END IF;

      END LOOP;

   END IF;


      x_return_status := l_return_status;

   oe_debug_pub.add('Exiting OE_DELAYED_REQUESTS_UTIL.CHECK_PERCENTAGE', 1);

EXCEPTION

   WHEN PERCENTAGE_EXCEEDED
     THEN
      x_return_status := l_return_status;


   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	IF line_adj_total%isopen THEN
	   CLOSE line_adj_total;
	END IF;

	IF all_adjustments%isopen THEN
	   CLOSE all_adjustments;
	END IF;

	IF hdr_adj_total%isopen THEN
	   CLOSE hdr_adj_total;
	END IF;

	IF max_line_adj_total%isopen THEN
	   CLOSE max_line_adj_total;
	END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'CHECK_PERCENTAGE'
            );
        END IF;

END check_percentage;

PROCEDURE CREATE_CONFIG_ITEM
( x_return_status OUT NOCOPY Varchar2

                  ,p_top_model_line_id  IN NUMBER
                  ,p_header_id          IN NUMBER
                 )
IS
  l_return_status             VARCHAR2(1);
  l_control_rec               OE_GLOBALS.Control_Rec_Type;
  l_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
  l_old_line_tbl              OE_Order_PUB.Line_Tbl_Type;
  l_line_rec                  OE_Order_PUB.Line_Rec_Type;
  l_api_name                  CONSTANT VARCHAR2(30) := 'Insert_Order';
  l_line_id			     NUMBER;
  l_component_sequence_id	NUMBER;
  l_component_code		     VARCHAR2(1000);
  l_component_item_id		NUMBER;
  l_sort_order			     VARCHAR2(240);
  l_component_quantity		NUMBER;
  l_bom_item_type		     VARCHAR2(30);
  l_top_model_line_id         NUMBER;
  l_config_rec     		     OE_ORDER_PUB.line_rec_type;
  l_select_flag			VARCHAR2(1);
  l_bill_sequence_id		NUMBER;
  l_top_bill_sequence_id	     NUMBER;
  l_option_number		     NUMBER;
  l_request_rec      		OE_Order_Pub.request_rec_type;
  l_request_tbl			OE_Order_Pub.Request_Tbl_Type;
  req_ind			          NUMBER;
BEGIN

   oe_debug_pub.add('Entering OE_DELAYED_REQUESTS_UTIL.CREATE_CONFIG_ITEM', 1);


     oe_debug_pub.add('In procedure Create_Config', 2);

     l_line_rec       := OE_Order_PUB.G_MISS_LINE_REC;


-- Set Control Record

     l_control_rec.controlled_operation := TRUE;
     l_control_rec.default_attributes   := TRUE;
     l_control_rec.change_attributes    := TRUE;
     l_control_rec.validate_entity      := TRUE;
     l_control_rec.write_to_DB          := TRUE;
     l_control_rec.process              := FALSE;


     OE_DEBUG_PUB.ADD('Loading top_model_line_id: ' || p_top_model_line_id, 2);
        l_config_rec :=
    	     OE_Order_Cache.Load_Top_Model_Line (p_top_model_line_id);

     l_line_rec.top_model_line_id   := p_top_model_line_id;
     l_line_rec.header_id           := p_header_id;
     l_line_rec.item_type_code      := OE_GLOBALS.G_ITEM_CONFIG;
     l_line_rec.line_number         := l_config_rec.line_number;
     l_line_rec.shipment_number     := l_config_rec.shipment_number;
     l_line_rec.option_number       := NULL;
--     l_line_rec.component_number := NULL;
     l_line_rec.operation           := OE_GLOBALS.G_OPR_CREATE;

     l_line_tbl(1) := l_line_rec;

    -- Set recursion mode.
    --  OE_GLOBALS.G_RECURSION_MODE := 'Y';

   OE_ORDER_PVT.Lines
        (p_validation_level  => FND_API.G_VALID_LEVEL_FULL
    	   ,p_control_rec       => l_control_rec
        ,p_x_line_tbl        => l_line_tbl
        ,p_x_old_line_tbl    => l_old_line_tbl
	   ,x_return_status     => l_return_status);

    -- Reset recursion mode.
    --  OE_GLOBALS.G_RECURSION_MODE := 'N';

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

--comment out for notification project
/*    OE_ORDER_PVT.Process_Requests_And_notify
    ( p_process_requests       => FALSE
     ,p_notify                 => TRUE
     ,x_return_status          => l_return_status
     ,p_line_tbl               => l_line_tbl
     ,p_old_line_tbl           => l_old_line_tbl);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
*/

     oe_debug_pub.add('Exiting OE_DELAYED_REQUESTS_UTIL.CREATE_CONFIG_ITEM', 1);

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
            ,   'Validate_LSC_QUOTA_TOTAL'
        );
       END IF;
END CREATE_CONFIG_ITEM;

PROCEDURE INS_INCLUDED_ITEMS
( x_return_status OUT NOCOPY Varchar2

                  ,p_line_id            IN NUMBER
                 )
IS
BEGIN

    oe_debug_pub.add('Entering OE_DELAYED_REQUESTS_UTIL.INS_INCLUDED_ITEMS', 1);

    OE_DEBUG_PUB.ADD('Inserting Included Items', 2);

    oe_debug_pub.add('Exiting OE_DELAYED_REQUESTS_UTIL.INS_INCLUDED_ITEMS', 1);
    Null;
END;

PROCEDURE  verify_payment
( x_return_status OUT NOCOPY varchar2

               ,p_header_id          IN  Number
               )
IS
l_return_status     VARCHAR2(30);
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(2000);
BEGIN

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      oe_debug_pub.ADD('Entering delayed request utility for verify payment',1);

	 OE_Verify_Payment_PUB.Verify_Payment
                             ( p_header_id      => p_header_id
                             , p_calling_action => 'UPDATE'
                             , p_delayed_request=> FND_API.G_TRUE
                             , p_msg_count      => l_msg_count
                             , p_msg_data       => l_msg_data
                             , p_return_status  => l_return_status
                             );

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      oe_debug_pub.ADD('Exiting delayed request utility for verify payment',1);

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
            ,   'Verify_Payment'
            );
        END IF;

END Verify_Payment;


/* procedure insert_rma_scredit_adjustment
   To insert sales credit of corresponding RMA lines.
   if sales credit exists on the existing line, delete them first,
   then insert new ones taken from the referenced line.
   Price adjustments has been moved to apply change attributes
*/
Procedure INSERT_RMA_SCREDIT_ADJUSTMENT
(p_line_id       IN  NUMBER
,x_return_status OUT NOCOPY VARCHAR2

)
IS
l_Line_Scredit_tbl 	OE_Order_PUB.Line_Scredit_Tbl_Type;
l_ref_header_id   	NUMBER;
l_ref_line_id   	NUMBER;
l_header_id		NUMBER;
I               	NUMBER := 1;
I1                  NUMBER := 1;
I2                  NUMBER := 1;
l_api_name 		CONSTANT VARCHAR(30) := 'INSERT_RMA_SCREDIT_ADJUSTMENT';
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_old_Line_Scredit_tbl      OE_Order_PUB.Line_Scredit_Tbl_Type;
l_return_status               VARCHAR2(30);
l_count                       NUMBER := 0;
l_split_by                    VARCHAR2(30);
l_src_doc_type_id             NUMBER; -- added for bug 6778016
BEGIN

  OE_DEBUG_PUB.ADD('RMA: In INSERT_RMA_SCREDIT_ADJUSTMENT',1);

  OE_DEBUG_PUB.ADD('RMA: Line Id is '||TO_CHAR(p_line_id),2);

  x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- bug 3317323
  BEGIN
   SELECT header_id, reference_header_id, reference_line_id,split_by
         ,SOURCE_DOCUMENT_TYPE_ID --added source document id as a part of 6778016
     INTO l_header_id,l_ref_header_id, l_ref_line_id, l_split_by
          ,l_src_doc_type_id           --added l_src_doc_type_id as a part of 6778016
     FROM oe_order_lines
    WHERE line_id = p_line_id;
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
      OE_DEBUG_PUB.ADD('Invalid line_id',1);
         RETURN;
  END;
  IF l_split_by = 'SYSTEM' THEN
     RETURN;
  END IF;
 -- bug 3317323

  -- delete the existing Sales Credit on the RMA line
  BEGIN
      OE_Line_Scredit_Util.Lock_Rows
      (p_line_id          => p_line_id
      ,x_line_Scredit_tbl => l_Line_Scredit_tbl
	 ,x_return_status    => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
  EXCEPTION
	 WHEN NO_DATA_FOUND THEN
          OE_DEBUG_PUB.ADD('There are no existing sales credits to delete',1);
		NULL;
  END;

  IF l_Line_Scredit_tbl.COUNT > 0 THEN

    FOR I IN l_Line_Scredit_tbl.FIRST .. l_Line_Scredit_tbl.LAST LOOP

      l_x_Line_Scredit_tbl(I):= l_line_Scredit_tbl(I);
      l_x_Line_Scredit_tbl(I).operation := OE_GLOBALS.G_OPR_DELETE;

    END LOOP;

    -- Clear Table
    l_Line_Scredit_tbl.DELETE;

  END IF; /* end delete existing sales credit */

  -- get new sales credit and insert into RMA

  -- get the reference_id first
 /* moved to the beginning of the procedure to fix bug 3317323
  BEGIN
   SELECT header_id, reference_header_id, reference_line_id
     INTO l_header_id,l_ref_header_id, l_ref_line_id
     FROM oe_order_lines
    WHERE line_id = p_line_id;
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
      OE_DEBUG_PUB.ADD('Invalid line_id',1);
	 RETURN;
  END;
 */

  BEGIN
  OE_Line_Scredit_Util.Query_Rows(p_line_id          => l_ref_line_id
                                 ,x_line_Scredit_tbl => l_Line_Scredit_tbl);
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
	 --RETURN;
      OE_DEBUG_PUB.ADD('There are no Sales credits on the reference line',1);
	 NULL;
  END;

  IF l_Line_Scredit_tbl.COUNT > 0 THEN

    l_count := l_x_line_Scredit_tbl.count;

    FOR I IN l_Line_Scredit_tbl.FIRST .. l_Line_Scredit_tbl.LAST LOOP

      l_x_Line_Scredit_tbl(l_count + I):= l_line_Scredit_tbl(I);
      l_x_Line_Scredit_tbl(l_count + I).operation := OE_GLOBALS.G_OPR_CREATE;
      l_x_Line_Scredit_tbl(l_count + I).header_id := l_header_id;
      l_x_Line_Scredit_tbl(l_count + I).line_id   := p_line_id;
      l_x_Line_Scredit_tbl(l_count + I).sales_credit_id := FND_API.G_MISS_NUM;

    END LOOP;

  END IF; /* end inserting sales credit */

  IF l_x_Line_Scredit_tbl.COUNT > 0 THEN
    --  Call OE_Order_PVT.Process_order to insert sales credits.
    -- Set recursion mode.
    -- OE_GLOBALS.G_RECURSION_MODE := 'Y';

    /* Adding the if condition for bug 6778016/
    /* The control record structure passsed while calling process_order oe_copy_util.copy_order
       has process_partial to true and clear_dependents to false. However, in between as we were
       initializing the control record in to oe_globals.Control_Rec_Type, the values are getting
      changed.This is resulting in some issues. Hence we are resetting these two parametes to the
      initial values passed.
    */
    if l_src_doc_type_id=2 or NOT (OE_GLOBALS.G_UI_FLAG) --2nd condition added for bug 8820838
      then
     OE_DEBUG_PUB.ADD('Order is getting copied, Setting process partial flag to true');
    l_control_rec.controlled_operation:=true;
    l_control_rec.process_partial:=true;
    l_control_rec.clear_dependents:= FALSE;
    end if;                       /*End of changes for bug 6778016*/

    OE_DEBUG_PUB.ADD('Calling OE_ORDER_PVT.Line_Scredits',1);
    OE_ORDER_PVT.Line_Scredits
    (p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,p_control_rec                 => l_control_rec
    ,p_x_Line_Scredit_tbl          => l_x_Line_Scredit_tbl
    ,p_x_old_Line_Scredit_tbl      => l_x_old_Line_Scredit_tbl
    ,x_return_status               => l_return_status);

    OE_DEBUG_PUB.ADD('After Calling OE_ORDER_PVT.Line_Scredits',1);
    -- Reset recursion mode.
    -- OE_GLOBALS.G_RECURSION_MODE := 'N';

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

--comment out for notification project
/*    OE_ORDER_PVT.Process_Requests_And_notify
    ( p_process_requests       => FALSE
     ,p_notify                 => TRUE
     ,x_return_status          => l_return_status
     ,p_Line_Scredit_tbl       => l_x_Line_Scredit_tbl
     ,p_old_Line_Scredit_tbl   => l_x_old_Line_Scredit_tbl);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
*/
    -- Clear Table
    l_Line_Scredit_tbl.DELETE;

  END IF; /* end inserting sales credit */

  oe_debug_pub.add('Exit INSERT_RMA_SCREDIT_ADJUSTMENT',1);
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
            ,   'INSERT_RMA_SCREDIT_ADJUSTMENT'
            );
        END IF;

END INSERT_RMA_SCREDIT_ADJUSTMENT;

/*
Commented out the procedure tax_line as it is not called from
anywhere in the OM code.

-------------------------------------------------------------------
Procedure: TAX_LINE
-------------------------------------------------------------------


PROCEDURE Tax_Line ( x_return_status OUT NOCOPY VARCHAR2
			    , p_line_id          IN   NUMBER
			    )
IS
l_return_status               Varchar2(30):= FND_API.G_RET_STS_SUCCESS;
--l_tax_value                   NUMBER := 0;
l_line_id                     NUMBER := p_line_id;
l_msg_count		          NUMBER := 0;
l_count		               NUMBER := 0;
l_counter		               NUMBER := 0;
l_msg_data		          VARCHAR2(2000);
l_tax_value		          NUMBER := 0;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_tax_code                    VARCHAR2(50);
l_line_rec                    OE_Order_PUB.Line_Rec_Type;
l_old_line_rec                OE_Order_PUB.Line_Rec_Type;
l_line_val_rec                OE_Order_PUB.Line_Val_Rec_Type;
l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_old_line_tbl                OE_Order_PUB.Line_Tbl_Type;
l_Line_Adj_rec                OE_Order_PUB.Line_Adj_Rec_Type;
l_Line_Adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
l_l_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_Line_Adj_val_rec            OE_Order_PUB.Line_Adj_Val_Rec_Type;
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_rec            OE_Order_PUB.Header_Adj_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_rec        OE_Order_PUB.Header_Scredit_Rec_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_rec                  OE_Order_PUB.Line_Rec_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_rec          OE_Order_PUB.Line_Scredit_Rec_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_Action_Request_tbl        OE_Order_PUB.Request_Tbl_Type;
l_x_Lot_Serial_Tbl	          OE_Order_PUB.Lot_Serial_Tbl_Type;
l_x_Header_price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_x_Line_price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
l_tax_rec_out_tbl             OM_TAX_UTIL.om_tax_out_tab_type;
currency_code  varchar2(30) := NULL;
header_org_id  number;
inventory_org_id number;
conversion_rate number;
--serla begin
l_x_Header_Payment_tbl        OE_Order_PUB.Header_Payment_Tbl_Type;
l_x_Line_Payment_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
--serla end
l_header_rec                   OE_Order_PUB.Header_Rec_Type;
BEGIN
       x_return_status  := l_return_status;

    -- Get the Line record
    oe_debug_pub.add('Entering Tax line',1);

    BEGIN

        OE_LINE_UTIL.Query_Row(p_line_id  => l_line_id,
	                          x_line_rec => l_line_rec);
        l_old_line_rec := l_line_rec;

    EXCEPTION
	   WHEN OTHERS THEN
		  RAISE NO_DATA_FOUND;
    END;


    -- Call the procedure to get the Tax on the order line
    oe_order_cache.load_order_header(l_line_rec.header_id);
    l_header_rec := oe_order_cache.g_header_rec;

    OM_TAX_UTIL.TAX_LINE(p_line_rec => l_line_rec,
                         p_header_rec => l_header_Rec,
			 x_tax_value => l_tax_value,
                         x_tax_out_tbl => l_tax_rec_out_tbl,
                         x_return_status => l_return_status );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_line_rec.tax_value := l_tax_value;

    oe_debug_pub.add('After Successfully calculating Tax',2);

    -- Check for existing TAX records in OE_PRICE_ADJUSTMENTS table for the
    -- given line record.
  -- Replace Query_rows with lock rows --
    BEGIN
       OE_Line_Adj_UTIL.Lock_Rows
         ( p_line_id       => l_line_id
          ,x_line_adj_tbl  => l_l_line_adj_tbl
          ,x_return_status => l_return_status);
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;
    EXCEPTION
         WHEN OTHERS THEN
            x_return_status  := FND_API.G_RET_STS_SUCCESS;
    END;

    -- If any TAX records exists, then delete those records.
oe_debug_pub.add('line_adj_tbl count is : ' || l_l_line_adj_tbl.count , 1);

    IF l_l_line_adj_tbl.COUNT > 0 THEN

      FOR I IN 1..l_l_line_adj_tbl.COUNT LOOP
          oe_debug_pub.add('Parent adj Id is '||
                  to_char(l_l_line_adj_tbl(I).parent_adjustment_id),2);
	     IF l_l_line_adj_tbl(I).list_line_type_code = 'TAX'  AND
		   l_l_line_adj_tbl(I).parent_adjustment_id IS NULL
	     THEN
              l_counter := l_counter + 1;
	         l_line_adj_tbl(l_counter) := l_l_line_adj_tbl(I);
          --  Set Operation to delete
              l_Line_Adj_tbl(l_counter).operation := OE_GLOBALS.G_OPR_DELETE;
          END IF;
      END LOOP;
    END IF;

    --  Load IN parameters for Line Adjustment record

oe_debug_pub.add('line tax rec out nocopy table 1: ' || l_tax_rec_out_tbl.count , 1);

    IF  l_tax_rec_out_tbl.COUNT > 0
    THEN
        FOR I IN 1..l_tax_rec_out_tbl.COUNT LOOP

         IF l_tax_rec_out_tbl(I).trx_line_id = l_line_rec.line_id
         THEN

            l_Line_adj_tbl(l_counter+I) := OE_ORDER_PUB.G_MISS_LINE_ADJ_REC;
            l_Line_adj_tbl(l_counter+I).header_id := l_line_rec.header_id;
            l_Line_adj_tbl(l_counter+I).line_id := l_line_rec.line_id;
            l_Line_adj_tbl(l_counter+I).tax_code := l_tax_rec_out_tbl(I).tax_rate_code;
            l_Line_Adj_tbl(l_counter+I).operand := l_tax_rec_out_tbl(I).tax_rate;
            l_Line_Adj_tbl(l_counter+I).adjusted_amount :=
						l_tax_rec_out_tbl(I).tax_amount;
            l_Line_Adj_tbl(l_counter+I).automatic_flag := 'N';
            l_Line_Adj_tbl(l_counter+I).list_line_type_code := 'TAX';
            l_Line_Adj_tbl(l_counter+I).arithmetic_operator := 'AMT';

          --  Set flex attributes to NULL in order to avoid defaulting them.

            l_Line_Adj_tbl(l_counter+I).context     := NULL;
            l_Line_Adj_tbl(l_counter+I).attribute1  := NULL;
            l_Line_Adj_tbl(l_counter+I).attribute2  := NULL;
            l_Line_Adj_tbl(l_counter+I).attribute3  := NULL;
            l_Line_Adj_tbl(l_counter+I).attribute4  := NULL;
            l_Line_Adj_tbl(l_counter+I).attribute5  := NULL;
            l_Line_Adj_tbl(l_counter+I).attribute6  := NULL;
            l_Line_Adj_tbl(l_counter+I).attribute7  := NULL;
            l_Line_Adj_tbl(l_counter+I).attribute8  := NULL;
            l_Line_Adj_tbl(l_counter+I).attribute9  := NULL;
            l_Line_Adj_tbl(l_counter+I).attribute10 := NULL;
            l_Line_Adj_tbl(l_counter+I).attribute11 := NULL;
            l_Line_Adj_tbl(l_counter+I).attribute12 := NULL;
            l_Line_Adj_tbl(l_counter+I).attribute13 := NULL;
            l_Line_Adj_tbl(l_counter+I).attribute14 := NULL;
            l_Line_Adj_tbl(l_counter+I).attribute15 := NULL;

       -- Set other attributes to NULL

            l_Line_Adj_tbl(l_counter+I).OPERATION	                  := NULL;
            l_Line_Adj_tbl(l_counter+I).PERCENT                     := NULL;
            l_Line_Adj_tbl(l_counter+I).DISCOUNT_ID                 := NULL;
            l_Line_Adj_tbl(l_counter+I).DISCOUNT_LINE_ID            := NULL;
            l_Line_Adj_tbl(l_counter+I).request_id                  := NULL;
            l_Line_Adj_tbl(l_counter+I).orig_sys_discount_ref       := NULL;
            l_Line_Adj_tbl(l_counter+I).list_header_id              := NULL;
            l_Line_Adj_tbl(l_counter+I).list_line_id                := NULL;
            l_Line_Adj_tbl(l_counter+I).modifier_mechanism_type_code:= NULL;
            l_Line_Adj_tbl(l_counter+I).modified_from               := NULL;
            l_Line_Adj_tbl(l_counter+I).modified_to                 := NULL;
            l_Line_Adj_tbl(l_counter+I).updated_flag                := NULL;
            l_Line_Adj_tbl(l_counter+I).update_allowed	             := NULL;
            l_Line_Adj_tbl(l_counter+I).applied_flag                := NULL;
            l_Line_Adj_tbl(l_counter+I).change_reason_code          := NULL;
            l_Line_Adj_tbl(l_counter+I).change_reason_text          := NULL;
            l_Line_Adj_tbl(l_counter+I).cost_id                     := NULL;
            l_Line_Adj_tbl(l_counter+I).tax_exempt_flag             := NULL;
            l_Line_Adj_tbl(l_counter+I).tax_exempt_number           := NULL;
            l_Line_Adj_tbl(l_counter+I).tax_exempt_reason_code      := NULL;
            l_Line_Adj_tbl(l_counter+I).parent_adjustment_id        := NULL;
            l_Line_Adj_tbl(l_counter+I).invoiced_flag               := NULL;
            l_Line_Adj_tbl(l_counter+I).estimated_flag              := NULL;
            l_Line_Adj_tbl(l_counter+I).inc_in_sales_performance    := NULL;
            l_Line_Adj_tbl(l_counter+I).split_action_code           := NULL;

          --  Set Operation to Create
            l_Line_Adj_tbl(l_counter+I).operation := OE_GLOBALS.G_OPR_CREATE;

         END IF;

        END LOOP;
    END IF;

    --  Load IN parameters for Line record
    IF NOT OE_GLOBALS.Equal(l_line_rec.tax_value, l_old_line_rec.tax_value)
    THEN
	   -- Start Audit Trail --
	   l_Line_rec.change_reason := 'SYSTEM';
	   -- End Audit Trail --
        l_Line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_Line_rec.operation := OE_GLOBALS.G_OPR_NONE;
    END IF;

    -- Check to see if there are any records needed to be modified.

    IF NOT (OE_GLOBALS.Equal(l_line_rec.operation, OE_GLOBALS.G_OPR_NONE) AND
	       l_line_adj_tbl.COUNT = 0)
    THEN

        --  Populate Line table
        l_Line_tbl(1)     := l_Line_rec;
        l_Old_Line_tbl(1) := l_Old_Line_rec;

        --  Set control flags.
        l_control_rec.controlled_operation := FALSE;

        oe_debug_pub.add('Before calling Process Order API',2);

    -- Set recursion mode.
    --  OE_GLOBALS.G_RECURSION_MODE := 'Y';

        OE_Order_PVT.Process_order
        (   p_api_version_number          => 1.0
        ,   p_init_msg_list               => FND_API.G_FALSE
        ,   x_return_status               => l_return_status
        ,   x_msg_count                   => l_msg_count
        ,   x_msg_data                    => l_msg_data
        ,   p_control_rec                 => l_control_rec
        ,   p_x_header_rec                => l_x_header_rec
        ,   p_x_Header_Adj_tbl            => l_x_Header_Adj_tbl
        ,   p_x_Header_price_Att_tbl      => l_x_Header_price_Att_tbl
        ,   p_x_Header_Adj_Att_tbl        => l_x_Header_Adj_Att_tbl
        ,   p_x_Header_Adj_Assoc_tbl      => l_x_Header_Adj_Assoc_tbl
        ,   p_x_Header_Scredit_tbl        => l_x_Header_Scredit_tbl
--serla begin
        ,   p_x_Header_Payment_tbl          => l_x_Header_Payment_tbl
--serla end
        ,   p_x_line_tbl                  => l_line_tbl
        ,   p_old_Line_tbl                => l_old_Line_tbl
        ,   p_x_Line_Adj_tbl              => l_Line_Adj_tbl
        ,   p_x_Line_price_Att_tbl        => l_x_Line_price_Att_tbl
        ,   p_x_Line_Adj_Att_tbl          => l_x_Line_Adj_Att_tbl
        ,   p_x_Line_Adj_Assoc_tbl        => l_x_Line_Adj_Assoc_tbl
        ,   p_x_Line_Scredit_tbl          => l_x_Line_Scredit_tbl
--serla begin
        ,   p_x_Line_Payment_tbl            => l_x_Line_Payment_tbl
--serla end
        ,   p_x_Lot_Serial_tbl            => l_x_Lot_Serial_tbl
        ,   p_x_action_request_tbl	       => l_x_action_request_tbl
        );

    -- Reset recursion mode.
    -- OE_GLOBALS.G_RECURSION_MODE := 'N';

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        oe_debug_pub.add('After calling Process_order API',2);
    END IF;
    l_tax_rec_out_tbl.delete;
    x_return_status := l_return_status;
    oe_debug_pub.add('Exiting Tax Line',1);
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN NO_DATA_FOUND THEN
       x_return_status  := FND_API.G_RET_STS_SUCCESS;

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Tax Line'
	    );
    	END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Tax_Line;

*/




------------------------------------------------------------------
-- procedure: SPLIT_HOLD
-- Copy's the hold when a line gets split that has an active hold
-----------------------------------------------------------------
PROCEDURE split_hold (p_entity_code         IN   VARCHAR2
                     ,p_entity_id           IN   NUMBER
                     ,p_split_from_line_id  IN   NUMBER
,x_return_status OUT NOCOPY VARCHAR2

                     )
IS
     l_return_status            VARCHAR2(30);
     l_msg_count                NUMBER;
     l_msg_data                 VARCHAR2(2000);

BEGIN

   OE_Debug_PUB.Add('Entering OE_Delayed_Requests_Util.split_Hold',1);
-- call the oe_holds_pub to split the line
   OE_Holds_pvt.split_hold (
                    p_line_id               => p_entity_id
                  , p_split_from_line_id    => p_split_from_line_id
                  , x_return_status         => x_return_status
                  , x_msg_count             => l_msg_count
                  , x_msg_data              => l_msg_data
                  );
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                OE_Debug_PUB.Add('Error in OE_Holds_PUB.split_Holds',2);
                IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                        RAISE FND_API.G_EXC_ERROR;
                ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        END IF; -- if split hold was successful

      OE_Debug_PUB.Add('Exiting OE_Delayed_Requests_Util.split_Hold',2);

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
            ,   'Split_Hold'
            );
        END IF;


END split_hold;

-------------------------------------------------------------------
-- Procedure: EVAL_HOLD_SOURCE
-- Applies or removes holds if a hold source entity is updated
-- on the order or line.
-- Changed(1/3/2000): Moved all the login to the oe_holds_pub.evaluate_holds
-------------------------------------------------------------------

PROCEDURE Eval_Hold_Source(
x_return_status OUT NOCOPY VARCHAR2

			,  p_entity_code	   IN   VARCHAR2
			,  p_entity_id		   IN   NUMBER
			,  p_hold_entity_code  IN   VARCHAR2
			--ER#7479609,  p_hold_entity_id	   IN   NUMBER
			, p_hold_entity_id	 IN   oe_hold_sources_all.hold_entity_id%TYPE  --ER#7479609
			)
IS
     l_return_status     VARCHAR2(30);
     l_msg_count         NUMBER;
     l_msg_data          VARCHAR2(2000);

BEGIN

    OE_Debug_PUB.Add('Entering Eval_Hold_Source', 1);
    Oe_debug_pub.add('Hold entity: '|| p_hold_entity_code ||' '|| p_hold_entity_id,2);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    oe_holds_pub.evaluate_holds ( p_entity_code  => p_entity_code
                                 ,p_entity_id    => p_entity_id
                                 ,p_hold_entity_code    => p_hold_entity_code
                                 ,p_hold_entity_id      => p_hold_entity_id
                                 ,x_return_status       => x_return_status
                                 ,x_msg_count           => l_msg_count
                                 ,x_msg_data            => l_msg_data
                                );



        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	      OE_Debug_PUB.Add('Error in OE_Holds_PUB.evaluate_holds',2);
 	   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
 		RAISE FND_API.G_EXC_ERROR;
 	   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
 		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 	   END IF;
        END IF;

    OE_Debug_PUB.Add('Exiting Eval_Hold_Source', 1);

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
            ,   'Eval_Hold_Source'
            );
        END IF;

END Eval_Hold_Source;

-------------------------------------------------------------------
-- Procedure: APPLY_HOLD
-- Applies holds to an order or line using hold ID, entity code and
-- entity ID
-------------------------------------------------------------------

PROCEDURE Apply_Hold(p_validation_level  IN   NUMBER
                    ,x_request_rec   IN  OUT NOCOPY OE_Order_PUB.Request_Rec_Type
			)
IS
l_header_id		NUMBER DEFAULT NULL;
l_line_id		     NUMBER DEFAULT NULL;
l_hold_source_rec	OE_Holds_PVT.Hold_Source_REC_type;
l_request_rec		OE_Order_PUB.request_rec_type := x_request_rec;
l_return_status	VARCHAR2(30);
l_msg_count		NUMBER := 0;
l_msg_data		VARCHAR2(2000) := NULL;
l_line_rec                    OE_Order_PUB.Line_Rec_Type;
BEGIN

   OE_Debug_PUB.Add('Entering OE_Delayed_Requests_Util.Apply_Hold',1);

   IF l_request_rec.entity_code = OE_Globals.G_ENTITY_HEADER THEN
      -- Indicates Header Level action
      --l_header_id := l_request_rec.entity_id;
      l_hold_source_rec.header_id := l_request_rec.entity_id;
      OE_Debug_PUB.Add('Header ID: '|| l_hold_source_rec.header_id,1);

   ELSIF l_request_rec.entity_code = OE_Globals.G_ENTITY_LINE THEN

	OE_debug_pub.add('Line ID: '|| l_request_rec.entity_id,1);
     BEGIN
      SELECT header_id
        INTO l_header_id
        FROM oe_order_lines
       WHERE line_id = l_request_rec.entity_id;
     OE_debug_pub.add('OEXUREQB:Header ID: '|| l_header_id);


     EXCEPTION
        WHEN OTHERS THEN
            OE_debug_pub.add('OEXUREQB:No header ID for this line');
            RAISE NO_DATA_FOUND;
     END;

      l_hold_source_rec.header_id := l_header_id;
	 l_hold_source_rec.line_id := l_request_rec.entity_id;

   END IF;

   l_hold_source_rec.hold_entity_code 	:= l_request_rec.param2;
   l_hold_source_rec.hold_id		     := l_request_rec.param1;

   -- Since an Order based source and Header is created at the same time, caller
   -- is unable to populate param3 with header_id.  We can user entity_id

   IF ((l_request_rec.entity_code = OE_GLOBALS.G_ENTITY_HEADER) AND
       (l_hold_source_rec.hold_entity_code = 'O')) THEN
       l_hold_source_rec.hold_entity_id := l_request_rec.entity_id;
   ELSIF ((l_request_rec.entity_code = OE_GLOBALS.G_ENTITY_LINE) AND
       (l_hold_source_rec.hold_entity_code = 'O')) THEN
       l_hold_source_rec.hold_entity_id := l_header_id;
   ELSE
       l_hold_source_rec.hold_entity_id	:= l_request_rec.param3;
   END IF;

   l_hold_source_rec.hold_comment 	:= l_request_rec.param4;

   l_hold_source_rec.hold_until_date 	:= l_request_rec.date_param1;

   -- Load Desc Flex
   l_hold_source_rec.context            := l_request_rec.param10;
   l_hold_source_rec.attribute1 	:= l_request_rec.param11;
   l_hold_source_rec.attribute2 	:= l_request_rec.param12;
   l_hold_source_rec.attribute3 	:= l_request_rec.param13;
   l_hold_source_rec.attribute4 	:= l_request_rec.param14;
   l_hold_source_rec.attribute5 	:= l_request_rec.param15;
   l_hold_source_rec.attribute6 	:= l_request_rec.param16;
   l_hold_source_rec.attribute7 	:= l_request_rec.param17;
   l_hold_source_rec.attribute8 	:= l_request_rec.param18;
   l_hold_source_rec.attribute9 	:= l_request_rec.param19;
   l_hold_source_rec.attribute10	:= l_request_rec.param20;
   l_hold_source_rec.attribute11	:= l_request_rec.param21;
   l_hold_source_rec.attribute12 	:= l_request_rec.param22;
   l_hold_source_rec.attribute13	:= l_request_rec.param23;
   l_hold_source_rec.attribute14 	:= l_request_rec.param24;
   l_hold_source_rec.attribute15 	:= l_request_rec.param25;

   l_request_rec.return_status := FND_API.G_RET_STS_SUCCESS;

   -- Changed the following to new signiture 2/24/2000 - ZB
   /*
     OE_Holds_PUB.Apply_Holds
		(   p_api_version		=> 1.0
		,   p_validation_level	=> p_validation_level
		,   p_header_id		=> l_header_id
		,   p_line_id			=> l_line_id
		,   p_hold_source_rec		=> l_hold_source_rec
		,   x_return_status		=> l_return_status
		,   x_msg_count			=> l_msg_count
		,   x_msg_data			=> l_msg_data
		);
	*/
	OE_Holds_PUB.Apply_Holds
		(   p_api_version        => 1.0
		,   p_validation_level   => FND_API.G_VALID_LEVEL_NONE
		,   p_hold_source_rec     => l_hold_source_rec
		,   p_check_authorization_flag => 'Y'    -- bug 8477694
		,   x_return_status      => l_return_status
		,   x_msg_count          => l_msg_count
		,   x_msg_data           => l_msg_data
           );


    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	OE_Debug_PUB.Add('OEXUREQB:Error in OE_Holds_PUB.Apply_Holds',1);
 		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
 			RAISE FND_API.G_EXC_ERROR;
 		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
 			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 		END IF;
    ELSE
    	OE_Debug_PUB.Add('OEXUREQB:Hold applied',1);
    END IF;

    x_request_rec := l_request_rec;

    OE_Debug_PUB.Add('Exiting OE_Delayed_Requests_Util.Apply_Hold',1);
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        l_request_rec.return_status := FND_API.G_RET_STS_ERROR;
        x_request_rec := l_request_rec;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	l_request_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	x_request_rec := l_request_rec;

    WHEN OTHERS THEN

	l_request_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	x_request_rec := l_request_rec;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Apply_Hold'
            );
        END IF;


END Apply_Hold;

-------------------------------------------------------------------
-- Procedure: RELEASE_HOLD
-- Releases hold on an order or line that has a hold source that
-- uses this hold ID, entity code and entity ID.
-------------------------------------------------------------------

PROCEDURE Release_Hold(
                  p_validation_level   IN  NUMBER
                 ,x_request_rec  IN  OUT NOCOPY OE_Order_PUB.Request_Rec_Type
			)
IS
l_header_id		NUMBER DEFAULT NULL;
l_line_id		     NUMBER DEFAULT NULL;
l_hold_id		     NUMBER DEFAULT NULL;
--ER#7479609 l_entity_code		VARCHAR2(1) DEFAULT NULL;
--ER#7479609 l_entity_id		NUMBER DEFAULT NULL;
l_entity_code		oe_hold_sources_all.hold_entity_code%TYPE DEFAULT NULL;  --ER#7479609
l_entity_id		oe_hold_sources_all.hold_entity_id%TYPE DEFAULT NULL;	--ER#7479609
l_request_rec		OE_Order_PUB.request_rec_type := x_request_rec;
l_return_status	VARCHAR2(30);
l_msg_count		NUMBER := 0;
l_msg_data		VARCHAR2(2000) := NULL;

l_hold_release_rec	OE_HOLDS_PVT.Hold_Release_Rec_Type;
l_hold_source_rec   OE_HOLDS_PVT.Hold_Source_Rec_Type;
BEGIN

  OE_Debug_PUB.Add('Entering OE_Delayed_Requests_Util.Release_Hold',1);

   IF l_request_rec.entity_code = OE_Globals.G_ENTITY_HEADER THEN
-- Indicates Header Level action

       l_header_id := l_request_rec.entity_id;
       l_hold_source_rec.header_id := l_header_id; --Bug 5042664
       OE_Debug_PUB.Add('Header ID: '|| l_header_id,1);

   ELSIF l_request_rec.entity_code = OE_Globals.G_ENTITY_LINE THEN

     --l_line_id := l_request_rec.entity_id;
     OE_debug_pub.add('Line ID: '|| l_request_rec.entity_id,1);
     BEGIN
      SELECT header_id
        INTO l_header_id
        FROM oe_order_lines
       WHERE line_id = l_request_rec.entity_id;
     OE_debug_pub.add('OEXUREQB:Header ID: '|| l_header_id);


     EXCEPTION
        WHEN OTHERS THEN
            OE_debug_pub.add('OEXUREQB:No header ID for this line');
            RAISE NO_DATA_FOUND;
     END;

     l_hold_source_rec.header_id := l_header_id;
     l_hold_source_rec.line_id := l_request_rec.entity_id;

   END IF;

   l_request_rec.return_status := FND_API.G_RET_STS_SUCCESS;

   l_hold_id     := l_request_rec.param1;
   l_entity_code := l_request_rec.param2;

   -- Order Import is unable to send Hold Entity Id/Header Id as Param3
   -- Need to modify the code to use header id for hold entity code = 'O'

   IF ((l_request_rec.entity_code = OE_GLOBALS.G_ENTITY_HEADER) AND
       (l_entity_code = 'O')) THEN
     l_entity_id := l_request_rec.entity_id;
   ELSIF ((l_request_rec.entity_code = OE_GLOBALS.G_ENTITY_LINE) AND
       (l_entity_code = 'O')) THEN
     l_entity_id := l_header_id;
   ELSE
     l_entity_id := l_request_rec.param3;
   END IF;

   l_hold_release_rec.release_reason_code := l_request_rec.param4;
   l_hold_release_rec.release_comment     := l_request_rec.param5;

   l_hold_source_rec.hold_id          := l_hold_id;
   l_hold_source_rec.HOLD_ENTITY_CODE := l_entity_code;
   l_hold_source_rec.HOLD_ENTITY_ID   := l_entity_id;


   OE_Debug_PUB.Add('Calling OE_Holds_PUB.Release_Holds',1);
     /*
     OE_Holds_PUB.Release_Holds
		(   p_api_version		=> 1.0
		,   p_validation_level		=> p_validation_level
		,   p_header_id			=> l_header_id
		,   p_line_id			=> l_line_id
		,   p_hold_id		        => l_hold_id
		,   p_entity_code		=> l_entity_code
		,   p_entity_id		        => l_entity_id
		,   p_hold_release_rec		=> l_hold_release_rec
		,   x_return_status		=> l_return_status
		,   x_msg_count			=> l_msg_count
		,   x_msg_data			=> l_msg_data
		);
		*/

	  oe_holds_pvt.Release_Holds(
		  p_hold_source_rec     =>  l_hold_source_rec
		 ,p_hold_release_rec    =>  l_hold_release_rec
		 ,p_check_authorization_flag => 'Y'    -- bug 8477694
	   	 ,x_return_status       =>  l_return_status
	      ,x_msg_count           =>  l_msg_count
	      ,x_msg_data            =>  l_msg_data
										 );
       OE_DEBUG_PUB.Add('x_return_status:' || l_return_status,1);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	OE_Debug_PUB.Add('Error in OE_Holds_PUB.Release_Holds',2);
 		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
 			RAISE FND_API.G_EXC_ERROR;
 		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
 			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 		END IF;
    ELSE
    	OE_Debug_PUB.Add('Hold released',1);
    END IF;

    x_request_rec := l_request_rec;
    OE_Debug_PUB.Add('Exiting OE_Delayed_Requests_Util.Release_Hold',1);
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        l_request_rec.return_status := FND_API.G_RET_STS_ERROR;
        x_request_rec := l_request_rec;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	l_request_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	x_request_rec := l_request_rec;

    WHEN OTHERS THEN

	l_request_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	x_request_rec := l_request_rec;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Release_Hold'
            );
        END IF;


END Release_Hold;


PROCEDURE Split_Set
  (p_request_rec	IN oe_order_pub.request_rec_type,
x_return_status OUT NOCOPY VARCHAR2)

  IS
l_return_status VARCHAR2(30);
x_msg_data varchar2(2000);
x_msg_count number;
l_set_name varchar2(80);
Begin
    l_set_name := p_request_rec.param1 ;
    OE_SET_UTIL.Split_Set
             (p_set_id     => p_request_rec.entity_id,
		    p_set_name  =>  l_set_name,
              x_return_Status  => l_return_status,
              x_msg_count      => x_msg_count,
              x_msg_data       => x_msg_data);
    x_return_status := l_return_status;
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Split_Set'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

End Split_set;

PROCEDURE Insert_Set
  (p_request_rec	IN oe_order_pub.request_rec_type,
x_return_status OUT NOCOPY VARCHAR2)

  IS
l_return_status VARCHAR2(30);
x_msg_data varchar2(2000);
x_msg_count number;
p_set_request oe_order_pub.request_tbl_type;
Begin
    p_set_request(1) := p_request_rec;
    OE_SET_UTIL.Insert_Into_Set
                 (p_set_request_tbl => p_set_request,
                  p_Push_Set_Date => 'N',
                  X_Return_Status  => l_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);
    x_return_status := l_return_status;
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Set'
            );
	END IF;
        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

NULL;

End Insert_Set;


PROCEDURE Book_Order
	( p_validation_level	IN NUMBER
	, p_header_id			IN NUMBER
, x_return_status OUT NOCOPY VARCHAR2

	)
IS
l_msg_count			NUMBER;
l_msg_data			VARCHAR2(2000);
BEGIN

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	OE_Order_Book_Util.Complete_Book_Eligible
			( p_api_version_number	=> 1.0
			, p_header_id			=> p_header_id
			, x_return_status		=> x_return_status
			, x_msg_count			=> l_msg_count
			, x_msg_data			=> l_msg_data);

EXCEPTION
	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF OE_MSG_PUB.Check_Msg_Level
		    (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
		   OE_MSG_PUB.Add_Exc_Msg
				( G_PKG_NAME
				, 'Book_Order'
				);
	END IF;
END Book_Order;

PROCEDURE Get_Ship_Method
        ( p_entity_code                 IN VARCHAR2
        , p_entity_id                   IN NUMBER
        , p_action_code	                IN VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2

        )
IS
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(2000);
  l_header_id                     NUMBER;
  l_action                        VARCHAR2(1);

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_entity_code = OE_Globals.G_ENTITY_HEADER THEN

       l_header_id := p_entity_id;

    ELSIF p_entity_code = OE_Globals.G_ENTITY_LINE THEN

          BEGIN
              SELECT header_id
              INTO   l_header_id
              FROM   oe_order_lines_all
              WHERE  line_id = p_entity_id;
          EXCEPTION
              WHEN OTHERS THEN
                   RAISE;
          END;

     END IF;

      IF OE_SYS_PARAMETERS.Value('FTE_INTEGRATION') = 'Y'
          AND p_action_code = OE_GLOBALS.G_GET_SHIP_METHOD_AND_RATES THEN
            l_action := 'B';
      ELSIF (OE_SYS_PARAMETERS.Value('FTE_INTEGRATION') = 'S'
             OR OE_SYS_PARAMETERS.Value('FTE_INTEGRATION') = 'Y')
             AND p_action_code =  OE_GLOBALS.G_GET_SHIP_METHOD THEN
               l_action := 'C';
      ELSIF (OE_SYS_PARAMETERS.Value('FTE_INTEGRATION') = 'F'
             OR OE_SYS_PARAMETERS.Value('FTE_INTEGRATION') = 'Y')
             AND p_action_code =  OE_GLOBALS.G_GET_FREIGHT_RATES THEN
               l_action := 'R';
      END IF;

     IF l_action IN ('B', 'C', 'R') THEN

       oe_debug_pub.add('calling Process_FTE_Action for Order Import.', 3);

       -- set p_ui_flag to Y since this is called from Action
       -- through Order Import.
       OE_FTE_INTEGRATION_PVT.Process_FTE_Action
       ( p_header_id           => l_header_id
        ,p_line_id             => null
        ,p_ui_flag             => 'Y'
        ,p_action              => l_action
        ,p_call_pricing_for_FR => 'Y'
        ,x_return_status       => x_return_status
        ,x_msg_count           => l_msg_count
        ,x_msg_data            => l_msg_data);
     ELSE
       fnd_message.set_name('ONT','OE_FTE_NOT_ENABLED');
       OE_MSG_PUB.Add;
       oe_debug_pub.add('Unable to process FTE integration either due to FTE is not enabled or action code is invalid.', 3);
       x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     OE_DEBUG_PUB.Add('Return Status fte action: '||x_return_status);

EXCEPTION
        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level
                    (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           OE_MSG_PUB.Add_Exc_Msg
                     ( G_PKG_NAME
                     , 'Get_Ship_Method'
                     );
        END IF;
END Get_Ship_Method;

PROCEDURE Fulfillment_Sets
( p_entity_code                IN VARCHAR2
, p_entity_id                  IN VARCHAR2
, p_action_code                IN VARCHAR2
, p_fulfillment_set_name       IN VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
)
 IS
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_header_id              NUMBER;
  l_set_id                 NUMBER;
  l_action                 VARCHAR2(10);
  --R12.MOAC
  l_selelect_line_tbl     OE_GLOBALS.Selected_Record_Tbl;
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;


       BEGIN
              SELECT header_id
              INTO   l_header_id
              FROM   oe_order_lines_all
              WHERE  line_id = p_entity_id;
          EXCEPTION
              WHEN OTHERS THEN
                   RAISE;
          END;

    IF  p_action_code = OE_GLOBALS.G_ADD_FULFILLMENT_SET THEN
        l_action := 'ADD';
    ELSIF p_action_code = OE_GLOBALS.G_REMOVE_FULFILLMENT_SET THEN
        l_action := 'REMOVE';
    END IF;

    l_selelect_line_tbl(1).id1 := p_entity_id; --R12.MOAC
    OE_DEBUG_PUB.Add(' Before Calling Process Sets',1);

    --R12.MOAC
    OE_SET_UTIL.Process_Sets
    ( p_selected_line_tbl => l_selelect_line_tbl,
      p_record_count      => 1,
      p_set_name          => p_fulfillment_set_name,
      p_set_type          => 'FULFILLMENT',
      p_operation         => l_action,
      p_header_id         => l_header_id,
      x_Set_Id            => l_set_id,
      x_return_status     => x_return_status,
      x_msg_count         => l_msg_count ,
      x_msg_data          => l_msg_data);


    OE_DEBUG_PUB.Add('After Calling Process Sets'||x_return_status,1);


    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

EXCEPTION
        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level
                    (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           OE_MSG_PUB.Add_Exc_Msg
                     ( G_PKG_NAME
                     ,'Fulfillment_Sets'
                     );
        END IF;

END Fulfillment_Sets;



/*----------------------------------------------------------------------
PROCEDURE Update_shipping
-----------------------------------------------------------------------*/
PROCEDURE Update_shipping
( p_update_shipping_tbl     IN  OE_ORDER_PUB.request_tbl_type
, p_line_id                 IN  NUMBER
, p_operation               IN  VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2)

IS
  l_update_shipping_index    NUMBER := 0;
  l_update_lines_tbl         OE_ORDER_PUB.request_tbl_type;
  l_update_lines_index       NUMBER := 0;
BEGIN

  oe_debug_pub.add('Entering UTIL.Update_Shipping'||p_line_id, 1);
  -- bug 4741573
  OE_MSG_PUB.set_msg_context ( p_entity_code => 'LINE'
                              ,p_entity_id   => p_line_id
                              ,p_line_id     => p_line_id );

  l_update_shipping_index := p_update_shipping_tbl.FIRST;

  WHILE l_update_shipping_index IS NOT NULL
  LOOP

    IF  p_update_shipping_tbl(l_update_shipping_index).request_type
                                  = OE_GLOBALS.G_UPDATE_SHIPPING
    THEN

      l_update_lines_index := l_update_lines_index + 1;
      l_update_lines_tbl(l_update_lines_index)
                                  := p_update_shipping_tbl(l_update_shipping_index);

    END IF;

    l_update_shipping_index := p_update_shipping_tbl.NEXT(l_update_shipping_index);

  END LOOP;

  OE_Shipping_Integration_PVT.Update_Shipping_From_OE
  ( p_update_lines_tbl    =>  l_update_lines_tbl,
    x_return_status       =>  x_return_status);


  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

    l_update_shipping_index := p_update_shipping_tbl.FIRST;
    WHILE l_update_shipping_index IS NOT NULL
    LOOP

    IF  p_update_shipping_tbl(l_update_shipping_index).request_type
                                     = OE_GLOBALS.G_UPDATE_SHIPPING
    THEN

      IF  NOT(p_line_id = p_update_shipping_tbl(l_update_shipping_index).entity_id AND
              p_operation
          = p_update_shipping_tbl(l_update_shipping_index).request_unique_key1)
      THEN

        oe_debug_pub.add
        ('deleting req '|| p_update_shipping_tbl(l_update_shipping_index).entity_id);

        OE_Delayed_Requests_PVT.Delete_Request
        (p_entity_code => p_update_shipping_tbl(l_update_shipping_index).entity_code
        ,p_entity_id   => p_update_shipping_tbl(l_update_shipping_index).entity_id
        ,p_request_Type => p_update_shipping_tbl(l_update_shipping_index).request_type
        ,p_request_unique_key1
               => p_update_shipping_tbl(l_update_shipping_index).request_unique_key1
        ,x_return_status => x_return_status);

      END IF;

    END IF;

    l_update_shipping_index := p_update_shipping_tbl.NEXT(l_update_shipping_index);

    END LOOP;
  END IF;

  -- bug 4741573
  OE_MSG_PUB.reset_msg_context('LINE');

  OE_Debug_PUB.Add('Exiting OE_Delayed_Requests_Util.Update_Shipping',1);
EXCEPTION
  WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  IF OE_MSG_PUB.Check_Msg_Level
        (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       OE_MSG_PUB.Add_Exc_Msg
        ( G_PKG_NAME
        , 'Update_Shipping'
        );
  END IF;

END Update_Shipping;


PROCEDURE Ship_Confirmation
(
	p_ship_confirmation_tbl 		IN  OE_ORDER_PUB.request_tbl_type
,	p_line_id					IN  NUMBER
,	p_process_type				IN  VARCHAR2
,	p_process_id				IN  VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2

)
IS
	l_process_id			NUMBER;
	l_shipping_index		NUMBER :=0 ;
BEGIN

    	OE_Debug_PUB.Add('Entering OE_Delayed_Requests_Util.Ship_Confirmation'||p_process_type||p_process_id,1);

	l_process_id     := to_number(p_process_id);
	l_shipping_index := p_ship_confirmation_tbl.First;
	oe_debug_pub.add('P_line_id :'||to_char(p_line_id),2);

    	WHILE	l_shipping_index IS NOT NULL LOOP

oe_debug_pub.add('Request Type : '||p_ship_confirmation_tbl(l_shipping_index).request_type,2);
oe_debug_pub.add('Param1 : '||p_ship_confirmation_tbl(l_shipping_index).param1,2);
		IF p_ship_confirmation_tbl(l_shipping_index).request_type
                                      = OE_GLOBALS.G_SHIP_CONFIRMATION AND
		   p_ship_confirmation_tbl(l_shipping_index).param1 = p_process_id THEN
oe_debug_pub.add('RUnique 1 : '||p_ship_confirmation_tbl(l_shipping_index).request_unique_key1,2);
oe_debug_pub.add('Entity Id : '||to_char(p_ship_confirmation_tbl(l_shipping_index).entity_id),2);
			IF	p_line_id <> p_ship_confirmation_tbl(l_shipping_index).entity_id THEN

				OE_Delayed_Requests_PVT.Delete_Request
				(p_entity_code 	=> p_ship_confirmation_tbl(l_shipping_index).entity_code
                	,p_entity_id     	=> p_ship_confirmation_tbl(l_shipping_index).entity_id
                	,p_request_Type    	=> p_ship_confirmation_tbl(l_shipping_index).request_type
                	,p_request_unique_key1	=> p_ship_confirmation_tbl(l_shipping_index).request_unique_key1
			 	,x_return_status   	=> x_return_status);

			END IF;
		END IF;

		l_shipping_index := p_ship_confirmation_tbl.NEXT(l_shipping_index);

	END LOOP;

	OE_Shipping_Integration_PVT.Process_Ship_Confirm
	(
		p_process_id		=>	l_process_id,
		p_process_type		=>	p_process_type,
		x_return_status	=>	x_return_status
	);
    OE_Debug_PUB.Add('Exiting OE_Delayed_Requests_Util.Ship_Confirmation',1);

EXCEPTION
	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF OE_MSG_PUB.Check_Msg_Level
		    (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
		   OE_MSG_PUB.Add_Exc_Msg
				( G_PKG_NAME
				, 'Ship_Confirmation'
				);
	END IF;
END Ship_Confirmation;


Procedure SPLIT_RESERVATIONS
( p_reserved_line_id   IN  NUMBER
, p_ordered_quantity   IN  NUMBER
, p_reserved_quantity  IN  NUMBER
, x_return_status OUT NOCOPY VARCHAR2)

IS
l_return_status  VARCHAR2(1);
BEGIN

   oe_debug_pub.add('Entering SPLIT_RESERVATIONS',1);

   oe_debug_pub.add('Calling OE_ORDER_SCH_UTIL.SPLIT_RESERVATIONS',1);

   OE_ORDER_SCH_UTIL.SPLIT_RESERVATIONS
	(p_reserved_line_id  => p_reserved_line_id,
      p_ordered_quantity  => p_ordered_quantity,
      p_reserved_quantity => p_reserved_quantity,
      x_return_status     => l_return_status);

   oe_debug_pub.add('After Calling OE_ORDER_SCH_UTIL.SPLIT_RESERVATIONS: '
                                       || l_return_status ,1);

   x_return_status := l_return_status;

END SPLIT_RESERVATIONS;


/*-------------------------------------------------------
Not used at all.
--------------------------------------------------------*/
Procedure COMPLETE_CONFIGURATION
( p_top_model_line_id  IN  NUMBER
, x_return_status OUT NOCOPY VARCHAR2)

IS
l_return_status       VARCHAR2(1);
l_valid_config        VARCHAR2(10);
l_complete_config     VARCHAR2(10);
BEGIN

   oe_config_util.Validate_Configuration
          (p_model_line_id   => p_top_model_line_id,
           p_validate_flag   => 'Y',
           p_complete_flag   => 'Y',
           x_valid_config    => l_valid_config,
           x_complete_config => l_complete_config,
           x_return_status   => l_return_status);

END COMPLETE_CONFIGURATION;


/*---------------------------------------------------
The call to oe_config_util does all the work.
----------------------------------------------------*/
Procedure VALIDATE_CONFIGURATION
( p_top_model_line_id   IN NUMBER
, p_deleted_options_tbl IN OE_Order_PUB.request_tbl_type
, p_updated_options_tbl IN OE_Order_PUB.request_tbl_type
, x_return_status OUT NOCOPY VARCHAR2

)
IS
l_return_status       VARCHAR2(1);
l_complete_flag       VARCHAR2(1):= 'N';
l_valid_config        VARCHAR2(10);
l_complete_config     VARCHAR2(10);

BEGIN
   -- any option added to a booked order,
   -- validate_configuration should check
   -- for valid as well as complete .

   select booked_flag
   into l_complete_flag
   from oe_order_lines
   where line_id = p_top_model_line_id;

   l_complete_flag := nvl(l_complete_flag, 'N');
   oe_debug_pub.add('option added to a booked order? : '||l_complete_flag , 2);

       oe_config_util.Validate_Configuration
            (p_model_line_id       => p_top_model_line_id,
             p_deleted_options_tbl => p_deleted_options_tbl,
             p_updated_options_tbl => p_updated_options_tbl,
             p_validate_flag       => 'Y',
             p_complete_flag       => l_complete_flag,
             x_valid_config        => l_valid_config,
             x_complete_config     => l_complete_config,
             x_return_status       => l_return_status);

             x_return_status   := l_return_status;

   oe_debug_pub.add('leaving ureqb, validate config: '|| l_return_status, 1);

EXCEPTION
   when no_data_found then
      oe_debug_pub.add
      ('no_data_found in OE_Delayed_Req_Util.VALIDATE_CONFIGURATION', 1);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      oe_debug_pub.add
      ('Exception in OE_Delayed_Req_Util.VALIDATE_CONFIGURATION', 1);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END VALIDATE_CONFIGURATION;

Procedure Match_And_Reserve
( p_line_id         IN  NUMBER
, x_return_status OUT NOCOPY VARCHAR2)

IS
BEGIN
  oe_config_util.match_and_reserve
	 (p_line_id       => p_line_id,
       x_return_status => x_return_status);
END;


Procedure Group_Schedule
( p_request_rec     IN   oe_order_pub.request_rec_type
, x_return_status OUT NOCOPY VARCHAR2)

IS
l_group_req_rec    OE_GRP_SCH_UTIL.Sch_Group_Rec_Type;
l_atp_tbl          OE_ATP.ATP_Tbl_Type;
l_line_rec         OE_ORDER_PUB.line_rec_type;
l_return_status    VARCHAR2(1);
BEGIN

  oe_debug_pub.add('Entering OE_Delayed_Requests_UTIL.Group_Schedule',1);

  oe_debug_pub.add('Entity is :' || p_request_rec.param3,2);
  oe_debug_pub.add('Action is :' || p_request_rec.param4,2);

  l_group_req_rec.entity_type               := p_request_rec.param3;
  l_group_req_rec.action                    := p_request_rec.param4;
  l_group_req_rec.line_id                   := p_request_rec.entity_id;
  l_group_req_rec.header_id                 := p_request_rec.param2;
  l_group_req_rec.old_schedule_ship_date    := p_request_rec.date_param1;
  l_group_req_rec.old_schedule_arrival_date := p_request_rec.date_param2;
  l_group_req_rec.old_request_date          := p_request_rec.date_param3;
  l_group_req_rec.old_ship_from_org_id      := p_request_rec.param7;
  l_group_req_rec.old_ship_set_number       := p_request_rec.param9;
  l_group_req_rec.old_arrival_set_number    := p_request_rec.param10;

  OE_LINE_UTIL.Query_Row(p_line_id  => p_request_rec.entity_id
                        ,x_line_rec => l_line_rec);

  IF NVL(p_request_rec.param11,'N') = 'Y' THEN

  oe_debug_pub.add('param 11' || p_request_rec.param11,1);
   l_group_req_rec.old_schedule_ship_date    := l_line_rec.schedule_ship_date;
   l_group_req_rec.old_schedule_arrival_date := l_line_rec.schedule_arrival_date
;
   l_group_req_rec.old_request_date          := l_line_rec.request_date;
   l_group_req_rec.old_ship_set_number       := l_line_rec.ship_set_id;
   l_group_req_rec.old_arrival_set_number    := l_line_rec.arrival_set_id;


  END IF;


  IF l_group_req_rec.entity_type = OE_ORDER_SCH_UTIL.OESCH_ENTITY_ARRIVAL_SET
  THEN
    l_group_req_rec.arrival_set_number    := p_request_rec.param1;
    l_group_req_rec.ship_to_org_id        := l_line_rec.ship_to_org_id;

    IF NOT OE_GLOBALS.Equal(l_line_rec.schedule_arrival_date,
                            l_group_req_rec.old_schedule_arrival_date)
    THEN
       l_group_req_rec.schedule_arrival_date :=
                                     l_line_rec.schedule_arrival_date;
    END IF;

  ELSE
    l_group_req_rec.ship_set_number       := p_request_rec.param1;
    l_group_req_rec.ship_from_org_id      := l_line_rec.ship_from_org_id;
    l_group_req_rec.ship_to_org_id        := l_line_rec.ship_to_org_id;
    l_group_req_rec.freight_carrier       := l_line_rec.shipping_method_code;

    IF NOT OE_GLOBALS.Equal(l_line_rec.schedule_ship_date,
                            l_group_req_rec.old_schedule_ship_date)
    THEN
       l_group_req_rec.schedule_ship_date :=
                                     l_line_rec.schedule_ship_date;
    END IF;

	-- Added this part here. If there is a change in arrival date
	-- we should pass this to group_schedule.

    IF NOT OE_GLOBALS.Equal(l_line_rec.schedule_arrival_date,
                            l_group_req_rec.old_schedule_arrival_date)
    THEN
       l_group_req_rec.schedule_arrival_date :=
                                     l_line_rec.schedule_arrival_date;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_line_rec.request_date,
                            l_group_req_rec.old_request_date)
    THEN
       l_group_req_rec.request_date :=
                                     l_line_rec.request_date;
    END IF;


  END IF;

  oe_debug_pub.add('*********Printing Group Request Attributes***********',2);
  oe_debug_pub.add('Grp Entity    :' || l_group_req_rec.entity_type,2);
  oe_debug_pub.add('Grp Header Id :' || l_group_req_rec.header_id,2);
  oe_debug_pub.add('Line Id       :' || l_group_req_rec.line_id,2);
  oe_debug_pub.add('Grp Action    :' || l_group_req_rec.action,2);
  oe_debug_pub.add('Grp Warehouse :' || l_group_req_rec.ship_from_org_id,2);
  oe_debug_pub.add('Grp Ship to   :' || l_group_req_rec.ship_to_org_id,2);
  oe_debug_pub.add('Group Sh Set# :' || l_group_req_rec.ship_set_number,2);
  oe_debug_pub.add('Group Ar Set# :' || l_group_req_rec.arrival_set_number,2);
  oe_debug_pub.add('Grp Ship Date :' || l_group_req_rec.schedule_ship_date,2);
  oe_debug_pub.add('Grp Ship Meth :' || l_group_req_rec.freight_carrier,2);
  oe_debug_pub.add('Grp Arr Date  :' || l_group_req_rec.schedule_arrival_date,2);
  oe_debug_pub.add('***************************************************',2);

  OE_GRP_SCH_UTIL.Group_Schedule
       (p_group_req_rec    => l_group_req_rec
       ,x_atp_tbl          => l_atp_tbl
       ,x_return_status    => l_return_status);

  -- Set the cascade_flag to TRUE, so that we query the block,
  -- since multiple lines have changed.

  oe_debug_pub.add('Setting G_CASCADING_REQUEST_LOGGED',2);

  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
      OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
  END IF;

  x_return_status := l_return_status;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Group_Schedule'
            );
        END IF;


    WHEN OTHERS THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Group_Schedule'
            );
        END IF;

END Group_Schedule;

Procedure Delink_Config
( p_line_id         IN  NUMBER
, x_return_status OUT NOCOPY VARCHAR2)

IS
BEGIN

  oe_config_util.delink_config_batch
	 (p_line_id       => p_line_id,
       x_return_status => x_return_status);
END;



/* procedure insert_rma_options_included
   to insert options and included items
   for the corresponding RMA lines.
*/
Procedure INSERT_RMA_OPTIONS_INCLUDED
(p_line_id IN NUMBER
,x_return_status OUT NOCOPY VARCHAR2

)
IS

l_number               	     NUMBER := 0;
l_api_name 		          CONSTANT VARCHAR(30) := 'INSERT_RMA_OPTIONS_INCLUDED';
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(30);
l_orig_line_rec               OE_Order_PUB.Line_Rec_Type;
l_reference_line_rec          OE_Order_Pub.Line_Rec_Type;
l_child_line_rec              OE_Order_Pub.Line_Rec_Type;
l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_old_line_tbl                OE_Order_PUB.Line_Tbl_Type;
I             			     NUMBER;
l_line_id                    NUMBER;
l_reference_line_id          NUMBER;
l_top_model_line_id          NUMBER;
l_ato_line_id          	     NUMBER;
l_link_to_line_id          	 NUMBER;
l_header_id          	     NUMBER;
l_fulfillment_set_id         NUMBER := NULL;
l_copy_call                  BOOLEAN;

-- l_component_code             VARCHAR2(2000);
    CURSOR rma_children IS
     SELECT l.header_id, l.line_id, l.ordered_quantity
	 FROM oe_order_lines l,mtl_system_items m
     WHERE l.top_model_line_id = l_top_model_line_id
     AND nvl(l.ato_line_id,1) 	= nvl(l_ato_line_id,nvl(l.ato_line_id,1))
     AND l.link_to_line_id = nvl(l_link_to_line_id,l.link_to_line_id)
	 AND line_id <> l_reference_line_id
     AND l.header_id 	= l_header_id
	 AND l.inventory_item_id = m.inventory_item_id
	 AND nvl(m.returnable_flag,'Y') = 'Y'
     AND nvl(l.cancelled_flag,'N') = 'N'
	 AND m.organization_id =
        OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID')
        ORDER BY LINE_NUMBER , SHIPMENT_NUMBER ,NVL(OPTION_NUMBER, -1),
        NVL(COMPONENT_NUMBER,-1),NVL(SERVICE_NUMBER,-1);

/* Added the order by to fix bug 2226940 */


BEGIN

  OE_DEBUG_PUB.ADD('Entering INSERT_RMA_OPTIONS_INCLUDED',1);

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BEGIN
  -- query the return line and to see if it's a referenced line
  OE_Line_Util.query_row(p_line_id  => p_line_id,
                         x_line_rec => l_orig_line_rec);
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
	RETURN;
  END;

  IF l_orig_line_rec.return_context is NOT NULL THEN

     OE_Line_Util.query_row(p_line_id  => l_orig_line_rec.reference_line_id
                           ,x_line_rec => l_reference_line_rec);

    IF l_reference_line_rec.item_type_code in ('STANDARD','OPTION',
			'INCLUDED','CONFIG','SERVICE') THEN
    		return;
    END IF;

    -- find the partial return proportion, which applies to all the options and included item lines

    l_reference_line_id 	:= l_orig_line_rec.reference_line_id;
    l_header_id 		:= l_reference_line_rec.header_id;

    IF l_orig_line_rec.source_document_type_id = 2 THEN
        l_copy_call := TRUE;
    END IF;

    IF l_reference_line_rec.top_model_line_id = l_reference_line_rec.line_id THEN
		l_top_model_line_id := l_reference_line_rec.line_id;
    ELSIF l_reference_line_rec.ato_line_id = l_reference_line_rec.line_id THEN
		l_ato_line_id := l_reference_line_rec.line_id;
		l_top_model_line_id := l_reference_line_rec.top_model_line_id;
    ELSIF l_reference_line_rec.component_code is NOT NULL THEN
/* commented out nocopy to fix 2410422 */

		/* l_component_code := l_reference_line_rec.component_code||'%'; */
		l_top_model_line_id := l_reference_line_rec.top_model_line_id;
        /* Added to fix 2410422 */
        l_link_to_line_id := l_reference_line_rec.line_id;
    ELSE
	return;
    END IF;


    FOR l_child IN rma_children LOOP
     l_number := l_number + 1;

     l_line_tbl(l_number)  :=  OE_ORDER_PUB.G_MISS_LINE_REC;
     IF l_number = 1 THEN
	  select oe_sets_s.nextval into l_fulfillment_set_id from dual;

       insert into oe_sets
          ( SET_ID, SET_NAME, SET_TYPE, HEADER_ID, SHIP_FROM_ORG_ID,
               SHIP_TO_ORG_ID,SCHEDULE_SHIP_DATE, SCHEDULE_ARRIVAL_DATE,
               FREIGHT_CARRIER_CODE, SHIPPING_METHOD_CODE,
               SHIPMENT_PRIORITY_CODE, SET_STATUS,
               CREATED_BY, CREATION_DATE, UPDATED_BY, UPDATE_DATE,
               UPDATE_LOGIN, INVENTORY_ITEM_ID,ORDERED_QUANTITY_UOM,
               LINE_TYPE_ID,SHIP_TOLERANCE_ABOVE, SHIP_TOLERANCE_BELOW)
       values
          ( l_fulfillment_set_id, to_char(l_fulfillment_set_id),
               'FULFILLMENT_SET',l_orig_line_rec.header_id,
			null,null, null,null,null,
               null,null,null, 0,sysdate,0, sysdate,
               0,null,null,null,null,null
          );

        Insert into oe_line_sets(Line_id, Set_id, SYSTEM_REQUIRED_FLAG)
        Values (p_line_id, l_fulfillment_set_id, 'Y');

	END IF;

     -- If COPY is calling and DFF is to be copied over
     IF OE_ORDER_COPY_UTIL.CALL_DFF_COPY_EXTN_API(l_orig_line_rec.org_id) AND
        l_copy_call
     THEN
         OE_Line_Util.query_row(p_line_id  => l_child.line_id,
                                x_line_rec => l_child_line_rec);

         IF OE_ORDER_COPY_UTIL.G_COPY_REC.line_descflex = FND_API.G_TRUE THEN
         -- Pre populate the DFF info from reference line
             OE_ORDER_COPY_UTIL.copy_line_dff_from_ref
                    (p_ref_line_rec => l_child_line_rec,
                     p_x_line_rec => l_line_tbl(l_number));

         END IF;

         OE_COPY_UTIL_EXT.Copy_Line_DFF(
                               p_copy_rec => OE_ORDER_COPY_UTIL.G_COPY_REC,
                               p_operation =>  'ORDER_TO_RETURN',
                               p_ref_line_rec => l_child_line_rec,
                               p_copy_line_rec => l_line_tbl(l_number));
     END IF;

     oe_debug_pub.add(' line id '|| to_char(l_line_tbl(l_number).line_id), 2);
     oe_debug_pub.add(to_char(l_line_tbl(l_number).ordered_quantity), 2);
     oe_debug_pub.add(to_char(l_child.ordered_quantity), 2);
     oe_debug_pub.add(to_char(l_orig_line_rec.ordered_quantity), 2);
     oe_debug_pub.add(to_char(l_reference_line_rec.ordered_quantity), 2);


     l_line_tbl(l_number).return_context    := 'ORDER';
     l_line_tbl(l_number).return_attribute1 := l_child.header_id;
     l_line_tbl(l_number).return_attribute2 := l_child.line_id;
     l_line_tbl(l_number).ordered_quantity  := ( l_child.ordered_quantity *
     l_orig_line_rec.ordered_quantity)/l_reference_line_rec.ordered_quantity;
     l_line_tbl(l_number).item_type_code    := OE_GLOBALS.G_ITEM_STANDARD;
     l_line_tbl(l_number).operation         := OE_GLOBALS.G_OPR_CREATE;
     l_line_tbl(l_number).header_id         := l_orig_line_rec.header_id;
     l_line_tbl(l_number).line_type_id      := l_orig_line_rec.line_type_id;
     l_line_tbl(l_number).return_reason_code := l_orig_line_rec.return_reason_code;
     -- Added for bug fix 2600923
     l_line_tbl(l_number).calculate_price_flag :=
                                        l_orig_line_rec.calculate_price_flag;
     l_line_tbl(l_number).pricing_date := l_orig_line_rec.pricing_date;

    oe_debug_pub.add(to_char(l_line_tbl(l_number).ordered_quantity), 2);
    oe_debug_pub.add('RMA: Found options : '|| to_char(l_child.line_id), 2);
    END LOOP;

  END IF;

  IF l_number > 0 THEN
    oe_debug_pub.add('RMA: Found options and included item lines', 2);

    --  Set control flags.
    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.default_attributes   := TRUE;
    l_control_rec.change_attributes    := TRUE;
    l_control_rec.clear_dependents     := TRUE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    -- Call OE_Order_PVT.Process_order to insert lines
    -- Set recursion mode.
    --  OE_GLOBALS.G_RECURSION_MODE := 'Y';

	-- Set the global so that delayed request will not be
	-- logged for the child return line
	  OE_GLOBALS.G_RETURN_CHILDREN_MODE := 'Y';

    OE_ORDER_PVT.Lines
    (p_validation_level  => FND_API.G_VALID_LEVEL_FULL
    ,p_control_rec       => l_control_rec
    ,p_x_line_tbl        => l_line_tbl
    ,p_x_old_line_tbl    => l_old_line_tbl
    ,x_return_status     => l_return_status);

    -- Reset recursion mode.
    -- OE_GLOBALS.G_RECURSION_MODE := 'N';

	  OE_GLOBALS.G_RETURN_CHILDREN_MODE := 'N';

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

--comment out for notification project
/*    OE_ORDER_PVT.Process_Requests_And_notify
    ( p_process_requests       => FALSE
     ,p_notify                 => TRUE
     ,x_return_status          => l_return_status
     ,p_line_tbl               => l_line_tbl
     ,p_old_line_tbl           => l_old_line_tbl);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
*/
    I := l_line_tbl.FIRST;
    WHILE I is not NULL LOOP

   	     -- Insert into Fulfillment set
          Insert into oe_line_sets(Line_id, Set_id, SYSTEM_REQUIRED_FLAG)
          Values (l_line_tbl(I).line_id, l_fulfillment_set_id, 'Y');

   		-- Insert RMA Sales Credits and Adjustments
		INSERT_RMA_SCREDIT_ADJUSTMENT
                 ( x_return_status      => l_return_status
                  ,p_line_id            => l_line_tbl(I).line_id
                 );

   		-- Insert RMA Lot and Serial Numbers
		INSERT_RMA_LOT_SERIAL
                 ( x_return_status      => l_return_status
                  ,p_line_id            => l_line_tbl(I).line_id
                 );

   		I := l_line_tbl.NEXT(I);
    END LOOP;

    OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;

  END IF; /* end inserting lines */

  OE_DEBUG_PUB.ADD(' Exiting INSERT_RMA_OPTIONS_INCLUDED',1);
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
            ,   'INSERT_RMA_OPTIONS_INCLUDED'
            );
        END IF;

END INSERT_RMA_OPTIONS_INCLUDED;

/* procedure insert_rma_lot_serial
   to insert lot and serial numbers
   for the corresponding RMA lines.

* Bug7195205 : All serial numbers from referenced header are inserted in case
*              of partial return RMA
*/
Procedure INSERT_RMA_LOT_SERIAL
(p_line_id        IN NUMBER
,x_return_status OUT NOCOPY VARCHAR2

)
IS

l_number               	     NUMBER := 0;
l_api_name 		          CONSTANT VARCHAR(30) := 'INSERT_RMA_LOT_SERIAL';
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_x_lot_serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
l_x_old_lot_serial_tbl        OE_Order_PUB.Lot_Serial_Tbl_Type;
l_return_status               VARCHAR2(30);
l_orig_line_rec               OE_Order_PUB.Line_Rec_Type;
l_reference_line_rec          OE_Order_Pub.Line_Rec_Type;
l_lot_serial_tbl              OE_Order_PUB.Lot_Serial_Tbl_Type;
l_line_id                     NUMBER;
l_inventory_item_id           NUMBER;
l_reference_line_id           NUMBER;
l_lot_control_flag            VARCHAR2(1) := 'N';
l_serial_number_control_flag  VARCHAR2(1) := 'N';
l_count                       NUMBER := 0;
l_serial_number               VARCHAR2(30) := NULL;
l_return_qty                  NUMBER := 0;
l_lot_trxn_qty                NUMBER := 0;
l_return_qty2                 NUMBER := 0; -- INVCONV
l_lot_trxn_qty2               NUMBER := 0; -- INVCONV

l_ship_from_org_id            NUMBER;
/* OPM Bug 2739964 */
l_item_rec         	      OE_ORDER_CACHE.item_rec_type;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

-- Added for 10204440 --
CURSOR control_codes_org(p_ref_org_id NUMBER) IS
SELECT decode(msi.lot_control_code,2,'Y','N'),
       decode(msi.serial_number_control_code,2,'Y',5,'Y',6,'Y','N'),
       primary_uom_code
  FROM mtl_system_items msi
 WHERE msi.inventory_item_id = l_inventory_item_id
   AND msi.organization_id = p_ref_org_id;
-- End of 10204440


CURSOR control_codes IS
SELECT decode(msi.lot_control_code,2,'Y','N'),
       decode(msi.serial_number_control_code,2,'Y',5,'Y',6,'Y','N'),
       primary_uom_code
  FROM mtl_system_items msi
 WHERE msi.inventory_item_id = l_inventory_item_id
   AND msi.organization_id =
              OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID');

-- Now Absolute value of transaction_quantity is selected to fix 1610964.
-- Modified query to take care of over-shipped order lines(Bug # 1643433).
-- Removed the view mtl_transaction_lot_val_v in the below cursor and used the tables involved in the view for bug 5395763
CURSOR lot_numbers is
SELECT u.lot_number,
       ABS(SUM(u.transaction_quantity)) transaction_quantity,
       ABS(SUM(u.secondary_transaction_quantity)) secondary_transaction_quantity -- INVCONV
 FROM  mtl_transaction_lot_numbers u,
       mtl_lot_numbers l,
       mtl_material_transactions m
WHERE  m.transaction_id = u.transaction_id
  AND  u.inventory_item_id = l_inventory_item_id
  AND  m.transaction_source_type_id = 2
  AND  m.trx_source_line_id = l_reference_line_id
  AND  m.ORGANIZATION_ID = l_ship_from_org_id
  AND  m.INVENTORY_ITEM_ID = l_inventory_item_id
  and  u.organization_id=l.organization_id
  and  u.inventory_item_id=l.inventory_item_id
  and  u.lot_number = l.lot_number
GROUP  BY u.lot_number;

-- Added fix for bug 4493305
CURSOR serial_numbers is
SELECT DISTINCT u.serial_number
  FROM mtl_unit_transactions_all_v u,
       mtl_material_transactions m
 WHERE m.transaction_id = u.transaction_id
   AND m.INVENTORY_ITEM_ID = l_inventory_item_id
   AND u.serial_number = NVL(l_serial_number,u.serial_number)
   AND u.inventory_item_id = l_inventory_item_id
   AND m.transaction_source_type_id = 2
   AND m.trx_source_line_id = l_reference_line_id
   AND m.organization_id = l_ship_from_org_id
   AND m.transaction_action_id = 1
   AND m.transaction_type_id = 33;

CURSOR lot_serial_numbers is
SELECT DISTINCT t.lot_number,
        u.serial_number
 FROM mtl_unit_transactions_all_v u,
      mtl_material_transactions m,
      mtl_transaction_lot_val_v t
WHERE u.serial_number = NVL(l_serial_number,u.serial_number)
  AND u.INVENTORY_ITEM_ID = t.inventory_item_id
  AND t.serial_transaction_id = u.transaction_id
  AND t.INVENTORY_ITEM_ID = m.INVENTORY_ITEM_ID
  AND m.transaction_id = t.transaction_id
  AND m.transaction_source_type_id = 2
  AND m.trx_source_line_id = l_reference_line_id
  AND m.ORGANIZATION_ID = l_ship_from_org_id
  AND m.INVENTORY_ITEM_ID = l_inventory_item_id;

-- Added following variables for RMA bug 5288547
  l_need_to_fetch_all  BOOLEAN := FALSE;
  l_primary_uom        VARCHAR2(3);
  l_overship_invoice_basis    varchar2(30) := null;  --bug13850432
  l_count_to_insert NUMBER :=0; --bug13850432

BEGIN

  OE_DEBUG_PUB.ADD(' Entering INSERT_RMA_LOT_SERIAL',1);

  OE_DEBUG_PUB.ADD('RMA: Line Id is '||TO_CHAR(p_line_id),2);

  -- if lot serial numbers exist, delete first


   x_return_status := FND_API.G_RET_STS_SUCCESS;

  BEGIN
     OE_Line_Util.query_row(p_line_id  => p_line_id
                           ,x_line_rec => l_orig_line_rec);
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          Return;
  END;


  oe_debug_pub.add(l_orig_line_rec.return_context,2);
--  IF l_orig_line_rec.return_context is NULL THEN
--    RETURN;
--  END IF;
  IF l_orig_line_rec.return_context = 'SERIAL' THEN
	 l_serial_number := l_orig_line_rec.return_attribute2;
  ELSE
     l_serial_number := NULL;
  END IF;

  BEGIN
      OE_Lot_serial_util.Lock_rows(p_line_id          => p_line_id,
		                      x_lot_serial_tbl => l_lot_serial_tbl,
						  x_return_status    => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

  EXCEPTION
	 WHEN NO_DATA_FOUND THEN
		NULL;
  END;

  IF (l_lot_serial_tbl.count > 0) THEN

    oe_debug_pub.add('RMA: rma_lot_serial.DELETE_ROW', 2);

    FOR I IN l_lot_serial_tbl.FIRST .. l_Lot_Serial_tbl.LAST LOOP

	 l_x_Lot_Serial_tbl(I) := l_Lot_Serial_tbl(I);
      l_x_Lot_Serial_tbl(I).operation := OE_GLOBALS.G_OPR_DELETE;

    END LOOP;

    -- Clear Table
    l_Lot_serial_tbl.DELETE;

  END IF; /* end delete existing lot serial numbers */

  l_reference_line_id  := l_orig_line_rec.reference_line_id;
  IF l_reference_line_id IS NOT NULL AND
	l_reference_line_id <> FND_API.G_MISS_NUM THEN

      OE_DEBUG_PUB.ADD(' There is a reference Line',1);
      OE_Line_Util.query_row(p_line_id  => l_reference_line_id,
                    	x_line_rec => l_reference_line_rec);
      l_inventory_item_id  := l_reference_line_rec.inventory_item_id;
      l_ship_from_org_id   := l_reference_line_rec.ship_from_org_id;
      oe_debug_pub.add(to_char(l_inventory_item_id)||':'||to_char(l_ship_from_org_id),2);

      IF l_ship_from_org_id is NULL
         OR l_ship_from_org_id = FND_API.G_MISS_NUM  THEN  --Added for 10204440

      OPEN control_codes;
      FETCH control_codes INTO l_lot_control_flag,
                               l_serial_number_control_flag,
                               l_primary_uom;
      IF control_codes%notfound THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      CLOSE control_codes;

     --Added for 10204440
     ELSE

       OPEN control_codes_org(l_ship_from_org_id);
        FETCH control_codes_org INTO  l_lot_control_flag,
                                          l_serial_number_control_flag,
                                          l_primary_uom;
        IF control_codes_org%notfound THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        CLOSE control_codes_org;
     END IF;
     --End of 10204440


      -- Added following for RMA bug 5155914

      -- Shipping UOM is always the Primary UOM for an item. If the original order
      -- that shipped out, has non-primary order_quantity_UOM then we should be
      -- fetching all data from the MTL tables for all LOT and Serial numbers that
      -- shipped on the originalorder(Not restrict it by the quantity on the RMA)
      -- It will be left to users to manually edit the data if needed in
      -- oe_lot_serial_numbers table.

      IF l_reference_line_rec.order_quantity_uom <> l_primary_uom THEN
          l_need_to_fetch_all := TRUE;
      END IF;

     --start for bug13850432. If overshipment invoice basis is 'Shipped' then
      --number of serial numbers needs to be insert is shipped quantity on reference outbound line
      --else it is Ordered quantity on reference outbound line
      l_overship_invoice_basis := oe_sys_parameters.value('OE_OVERSHIP_INVOICE_BASIS',NULL);
      IF l_overship_invoice_basis = 'SHIPPED' then
        l_count_to_insert := l_reference_line_rec.shipped_quantity;
        OE_DEBUG_PUB.ADD(' Reference out bound order is overshipped and Shipped qty is'||l_count_to_insert,1);
      ELSE
        l_count_to_insert := l_reference_line_rec.ordered_quantity;
      END IF;
      --end for bug13850432
      IF (l_lot_control_flag = 'Y' and l_serial_number_control_flag <> 'N') THEN

        -- If the Item is LOT and Serial controlled

        FOR l_lot_serial_numbers IN lot_serial_numbers LOOP
          /*
          ** Exit the loop if lot serial qty reaches qty on reference line qty.
          Changed the variable l_orig_line_rec.ordered_quantity in below condition to l_count_to_insert bug 13850432 */
          IF l_return_qty >= l_count_to_insert AND
            NOT l_need_to_fetch_all -- bug 5155914
          THEN
            EXIT;
          ELSE
            l_return_qty := l_return_qty + 1;
          END IF;

          OE_DEBUG_PUB.ADD(' In LOT-SERIAL-NUMBERS cursor',1);
          l_number := l_number + 1;
          l_lot_serial_tbl(l_number) := OE_ORDER_PUB.G_MISS_LOT_SERIAL_REC;
          l_lot_serial_tbl(l_number).lot_number := l_lot_serial_numbers.lot_number;
          l_lot_serial_tbl(l_number).from_serial_number := l_lot_serial_numbers.serial_number;
          l_lot_serial_tbl(l_number).quantity := 1;
        END LOOP;

      ELSIF (l_lot_control_flag = 'Y') THEN

        -- If the Item is just LOT controlled

        FOR l_lot_numbers IN lot_numbers LOOP
          /*
          ** Exit the loop if lot item qty reaches line return qty.
          */
          IF l_return_qty = l_orig_line_rec.ordered_quantity AND
             NOT l_need_to_fetch_all -- bug 5155914
          THEN
            EXIT;
          END IF;

          l_return_qty := l_return_qty + l_lot_numbers.transaction_quantity;
          l_return_qty2 := l_return_qty2 + l_lot_numbers.secondary_transaction_quantity; -- INVCONV

          IF l_return_qty > l_orig_line_rec.ordered_quantity AND
             NOT l_need_to_fetch_all -- bug 5155914
          THEN
            l_lot_trxn_qty := l_orig_line_rec.ordered_quantity - (l_return_qty - l_lot_numbers.transaction_quantity);
            l_return_qty := l_orig_line_rec.ordered_quantity;
            l_lot_trxn_qty2 := l_orig_line_rec.ordered_quantity2 - (l_return_qty2 - l_lot_numbers.secondary_transaction_quantity); -- INVCONV
            l_return_qty2 := l_orig_line_rec.ordered_quantity2; -- INVCONV


          ELSE
            l_lot_trxn_qty := l_lot_numbers.transaction_quantity;
            l_lot_trxn_qty2 := l_lot_numbers.secondary_transaction_quantity; -- INVCONV
          END IF;

          l_number := l_number + 1;
          OE_DEBUG_PUB.ADD(' In LOT-NUMBERS cursor',1);
          l_lot_serial_tbl(l_number) := OE_ORDER_PUB.G_MISS_LOT_SERIAL_REC;
          l_lot_serial_tbl(l_number).lot_number := l_lot_numbers.lot_number;

          -- transaction quantity is negative because of sales order issue
          -- Removed -ve sign to fix 1643433.
          l_lot_serial_tbl(l_number).quantity := l_lot_trxn_qty;
          l_lot_serial_tbl(l_number).quantity2 := l_lot_trxn_qty2; -- INVCONV

        END LOOP;

      ELSIF (l_serial_number_control_flag <> 'N') THEN

        -- If the Item is just Serial controlled

        FOR l_serial_numbers IN serial_numbers LOOP
          /*
          ** Exit the loop if serial item qty reaches line return qty.
          */
          --Bug7195205 : Changed l_orig_line_rec.ordered_quantity
          -- with l_reference_line_rec.ordered_quantity in order to
          -- insert all serial numbers from referenced sales order
          -- in case of partial return of an RMA
          --Changed the variable l_orig_line_rec.ordered_quantity in below condition to l_count_to_insert bug 13850432
          IF l_return_qty >= l_count_to_insert AND
             NOT l_need_to_fetch_all -- bug 5155914
          THEN
            EXIT;
          ELSE
            l_return_qty := l_return_qty + 1;
          END IF;

          l_number := l_number + 1;
          OE_DEBUG_PUB.ADD(' In SERIAL-NUMBERS cursor',1);
          l_lot_serial_tbl(l_number) := OE_ORDER_PUB.G_MISS_LOT_SERIAL_REC;
          l_lot_serial_tbl(l_number).from_serial_number := l_serial_numbers.serial_number;
          l_lot_serial_tbl(l_number).quantity := 1;
        END LOOP;

      END IF;
    END IF;
  -- END IF;-- INVCONV
  IF l_number > 0 THEN
    oe_debug_pub.add('RMA: FOUND LOT/SERIAL NUMBERS FOR THE LINE'||to_char(l_number), 1);

    FOR I IN l_Lot_serial_tbl.FIRST .. l_Lot_serial_tbl.LAST LOOP

	 l_count := l_x_lot_serial_tbl.count;
      l_x_lot_serial_tbl(l_count + I) := l_lot_serial_tbl(I);
      l_x_lot_serial_tbl(l_count + I).operation := OE_GLOBALS.G_OPR_CREATE;
      l_x_lot_serial_tbl(l_count + I).line_id   := l_orig_line_rec.line_id;

    END LOOP;
  END IF; /* end inserting lot serial numbers */

  IF l_x_lot_serial_tbl.count > 0 THEN
    OE_DEBUG_PUB.ADD(' Before calling  OE_ORDER_PVT.Lot_Serials',1);
    --  Call OE_Order_PVT.Process_order to insert lines
    -- Set recursion mode.
    -- OE_GLOBALS.G_RECURSION_MODE := 'Y';

    OE_ORDER_PVT.Lot_Serials
    (p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,p_control_rec                 => l_control_rec
    ,P_x_lot_serial_tbl            => l_x_lot_serial_tbl
    ,p_x_old_lot_serial_tbl        => l_x_old_lot_serial_tbl
    ,x_return_status               => l_return_status);
    -- Reset recursion mode.
    -- OE_GLOBALS.G_RECURSION_MODE := 'N';
    OE_DEBUG_PUB.ADD(' After calling  OE_ORDER_PVT.Lot_Serials',1);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

--comment out for nitification project
/*    OE_ORDER_PVT.Process_Requests_And_notify
    ( p_process_requests     => FALSE
     ,p_notify               => TRUE
     ,x_return_status        => l_return_status
     ,p_lot_serial_tbl       => l_x_lot_serial_tbl
     ,p_old_lot_serial_tbl   => l_x_old_lot_serial_tbl);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
*/

  END IF; /* end calling process order */
    -- Clear Table
    l_Lot_serial_tbl.DELETE;

  OE_DEBUG_PUB.ADD(' Exiting INSERT_RMA_LOT_SERIAL',1);

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
            ,   'INSERT_RMA_LOT_SERIAL'
            );
        END IF;

END INSERT_RMA_LOT_SERIAL;

PROCEDURE Validate_Line_Set(P_line_set_id   IN  NUMBER,
x_return_status OUT NOCOPY VARCHAR2) IS

l_line_tbl             OE_ORDER_PUB.LINE_TBL_TYPE;
l_item_id              NUMBER;
l_order_qty_uom        VARCHAR2(30);
l_line_type_id         NUMBER;
l_ship_tolerance_above NUMBER;
l_ship_tolerance_below NUMBER;
l_project_id           NUMBER;
l_task_id              NUMBER;
l_lin_line_id          NUMBER;  -- Bug 5754554

BEGIN
 oe_debug_pub.add('Entering oe_delayed_requests_util.Validate_Line_Set',1);
 oe_line_util.query_rows(p_line_set_id => p_line_set_id,
                         x_line_tbl    => l_line_tbl);

-- Start for bug 5754554
 IF l_line_tbl.count > 0 THEN
   FOR I IN 1 .. l_line_tbl.count LOOP
     IF l_line_tbl(I).open_flag = 'N' AND l_line_tbl(I).cancelled_flag = 'Y'
THEN
     oe_debug_pub.add(' Line_id '||l_line_tbl(I).line_id||' is canceled. Discarding it from Line Set');
       l_line_tbl.DELETE(I);
     END IF;
   END LOOP;
 END IF;

 IF l_line_tbl.count > 0 THEN
  FOR I IN l_line_tbl.first .. l_line_tbl.last LOOP
   IF l_line_tbl.EXISTS(I) THEN
    l_item_id              := nvl(l_line_tbl(I).inventory_item_id,-99);
    l_order_qty_uom        := nvl(l_line_tbl(I).order_quantity_uom,'-99');
    l_line_type_id         := nvl(l_line_tbl(I).line_type_id,-99) ;
    l_ship_tolerance_above := nvl(l_line_tbl(I).ship_tolerance_above,-99);
    l_ship_tolerance_below := Nvl(l_line_tbl(I).ship_tolerance_below,-99);
    l_task_id              := Nvl(l_line_tbl(I).task_id,-99);
    l_project_id           := Nvl(l_line_tbl(I).project_id,-99);
    l_lin_line_id          := Nvl(l_line_tbl(I).line_id,-99);
   EXIT;
   END IF;
  END LOOP;

/*
    l_item_id              := nvl(l_line_tbl(1).inventory_item_id,-99);
    l_order_qty_uom        := nvl(l_line_tbl(1).order_quantity_uom,'-99');
    l_line_type_id         := nvl(l_line_tbl(1).line_type_id,-99) ;
    l_ship_tolerance_above := nvl(l_line_tbl(1).ship_tolerance_above,-99);
    l_ship_tolerance_below := Nvl(l_line_tbl(1).ship_tolerance_below,-99);
    l_project_id           := Nvl(l_line_tbl(1).project_id,-99);
    l_task_id              := Nvl(l_line_tbl(1).task_id,-99);

            FOR I IN 2 .. l_line_tbl.count  */
            FOR I IN l_line_tbl.first .. l_line_tbl.last
            LOOP
              IF l_line_tbl.EXISTS(I) AND l_line_tbl(I).line_id <> l_lin_line_id
THEN
-- End for bug 5754554

		IF (l_line_tbl(I).inventory_item_id <>
		    l_item_id )  THEN
		    FND_MESSAGE.SET_NAME('ONT','OE_VAL_LINE_SET_ATTR');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME','Item');
              FND_MESSAGE.SET_TOKEN('LINE_NUMBER',
							  to_char(l_line_tbl(I).shipment_number));
              FND_MESSAGE.SET_TOKEN('PARENT_LINE_NUMBER',
							  to_char(l_line_tbl(I).line_number));
         	    OE_MSG_PUB.ADD;
		    RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_line_tbl(I).order_quantity_uom <>
		    l_order_qty_uom )  THEN
		    FND_MESSAGE.SET_NAME('ONT','OE_VAL_LINE_SET_ATTR');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME','Unit of Measure');
              FND_MESSAGE.SET_TOKEN('LINE_NUMBER',
							  to_char(l_line_tbl(I).shipment_number));
              FND_MESSAGE.SET_TOKEN('PARENT_LINE_NUMBER',
							  to_char(l_line_tbl(I).line_number));
         	    OE_MSG_PUB.ADD;
		    RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_line_tbl(I).line_type_id <>
		    l_line_type_id ) THEN
		    FND_MESSAGE.SET_NAME('ONT','OE_VAL_LINE_SET_ATTR');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME','Line Type');
              FND_MESSAGE.SET_TOKEN('LINE_NUMBER',
							  to_char(l_line_tbl(I).shipment_number));
              FND_MESSAGE.SET_TOKEN('PARENT_LINE_NUMBER',
							  to_char(l_line_tbl(I).line_number));
         	    OE_MSG_PUB.ADD;
		    RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_line_tbl(I).ship_tolerance_above <>
		    l_ship_tolerance_above )  THEN
		    FND_MESSAGE.SET_NAME('ONT','OE_VAL_LINE_SET_ATTR');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME','Ship tolerance above');
              FND_MESSAGE.SET_TOKEN('LINE_NUMBER',
							  to_char(l_line_tbl(I).shipment_number));
              FND_MESSAGE.SET_TOKEN('PARENT_LINE_NUMBER',
							  to_char(l_line_tbl(I).line_number));
         	    OE_MSG_PUB.ADD;
		    RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_line_tbl(I).ship_tolerance_below <>
		    l_ship_tolerance_below )  THEN
		    FND_MESSAGE.SET_NAME('ONT','OE_VAL_LINE_SET_ATTR');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME','Ship tolerance below');
              FND_MESSAGE.SET_TOKEN('LINE_NUMBER',
							  to_char(l_line_tbl(I).shipment_number));
              FND_MESSAGE.SET_TOKEN('PARENT_LINE_NUMBER',
							  to_char(l_line_tbl(I).line_number));
         	    OE_MSG_PUB.ADD;
		    RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_line_tbl(I).project_id <>
		    l_project_id ) THEN
		    FND_MESSAGE.SET_NAME('ONT','OE_VAL_LINE_SET_ATTR');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME','Project');
              FND_MESSAGE.SET_TOKEN('LINE_NUMBER',
							  to_char(l_line_tbl(I).shipment_number));
              FND_MESSAGE.SET_TOKEN('PARENT_LINE_NUMBER',
							  to_char(l_line_tbl(I).line_number));
         	    OE_MSG_PUB.ADD;
		    RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_line_tbl(I).Task_id <>
		    l_Task_id ) THEN
		    FND_MESSAGE.SET_NAME('ONT','OE_VAL_LINE_SET_ATTR');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME','Task');
              FND_MESSAGE.SET_TOKEN('LINE_NUMBER',
							  to_char(l_line_tbl(I).shipment_number));
              FND_MESSAGE.SET_TOKEN('PARENT_LINE_NUMBER',
							  to_char(l_line_tbl(I).line_number));
         	    OE_MSG_PUB.ADD;
		    RAISE FND_API.G_EXC_ERROR;
	     END IF;
             END IF; -- For Bug 5754554
	    END LOOP;
 END IF;
 oe_debug_pub.add('Exiting oe_delayed_requests_util.Validate_Line_Set',1);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

		OE_MSG_PUB.reset_msg_context('SPLIT');
			 RAISE;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

			 OE_MSG_PUB.reset_msg_context('SPLIT');
			  RAISE;


     WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
       OE_MSG_PUB.Add_Exc_Msg
               (    G_PKG_NAME ,
                    'Validate Line Set'
               );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_line_Set;

PROCEDURE Process_Adjustments
(p_adjust_tbl	     IN  OE_ORDER_PUB.REQUEST_TBL_TYPE,
x_return_status OUT NOCOPY VARCHAR2)

IS
l_return_status               VARCHAR2(30);
x_msg_data                    VARCHAR2(2000);
x_msg_count                   NUMBER;
l_adj_rec                     OE_ORDER_PUB.LINE_ADJ_REC_TYPE;
l_adj_tbl                     OE_ORDER_PUB.LINE_ADJ_TBL_TYPE;
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
l_x_action_request_tbl	     OE_Order_PUB.Request_Tbl_Type;
l_x_Header_price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_x_Line_price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
l_list_line_type_code         VARCHAR2(30) := NULL;
l_list_line_id                NUMBER;
--serla begin
l_x_Header_Payment_tbl        OE_Order_PUB.Header_Payment_Tbl_Type;
l_x_Line_Payment_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
--serla end
Begin


 oe_debug_pub.add('Entering oe_delayed_requests_util.Process_adjustments',1);
       FOR I IN 1..(p_adjust_tbl.COUNT) LOOP

         oe_debug_pub.add('I in p_adjust_tbl is : ' || I,2);

         oe_debug_pub.add(p_adjust_tbl(I).param3 || ' is there ',2);

         Select list_line_type_code
         Into   l_list_line_type_code
         From   qp_list_lines
         Where  list_line_id = to_number(p_adjust_tbl(I).param3);

         l_adj_rec := Oe_Order_Pub.G_MISS_LINE_ADJ_REC;
         /* l_adj_rec.list_line_type_code := 'DIS'; */
         l_adj_rec.price_adjustment_id := to_number(p_adjust_tbl(I).param1);
         l_adj_rec.list_header_id      := to_number(p_adjust_tbl(I).param2);

         l_adj_rec.list_line_id := to_number(p_adjust_tbl(I).param3);
/*
         l_adj_rec.list_line_id := l_list_line_id;
*/
         l_adj_rec.automatic_flag      := p_adjust_tbl(I).param4;
         l_adj_rec.list_line_type_code := l_list_line_type_code;
         l_adj_rec.arithmetic_operator := '%';
         l_adj_rec.operand   := to_number(p_adjust_tbl(I).param5);
         l_adj_rec.line_id   := p_adjust_tbl(I).entity_id;
         l_adj_rec.header_id := to_number(p_adjust_tbl(I).param7);
         l_adj_rec.operation := p_adjust_tbl(I).param8;

         l_adj_tbl(I) := l_adj_rec;


       END LOOP;

       /* call process order */

    IF (l_adj_tbl.COUNT >= 1) THEN

    -- Set recursion mode.
    --  OE_GLOBALS.G_RECURSION_MODE := 'Y';

    OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_x_header_rec                => l_x_header_rec
    ,   p_x_Header_Adj_tbl            => l_x_Header_Adj_tbl
    ,   p_x_Header_Scredit_tbl        => l_x_Header_Scredit_tbl
--serla begin
        ,   p_x_Header_Payment_tbl          => l_x_Header_Payment_tbl
--serla end
    ,   p_x_line_tbl                  => l_x_line_tbl
    ,   p_x_Line_Adj_tbl              => l_Adj_tbl
    ,   p_x_Line_Scredit_tbl          => l_x_Line_Scredit_tbl
--serla begin
        ,   p_x_Line_Payment_tbl            => l_x_Line_Payment_tbl
--serla end
    ,   p_x_Lot_Serial_tbl            => l_x_Lot_Serial_tbl
    ,   p_x_action_request_tbl	   => l_x_action_request_tbl
    ,   p_x_header_price_att_tbl      => l_x_header_price_att_tbl
    ,   p_x_Header_Adj_att_tbl        => l_x_Header_Adj_att_tbl
    ,   p_x_Header_Adj_Assoc_tbl      => l_x_Header_Adj_Assoc_tbl
    ,   p_x_Line_Price_att_tbl        => l_x_Line_Price_att_tbl
    ,   p_x_Line_Adj_att_tbl          => l_x_Line_Adj_att_tbl
    ,   p_x_Line_Adj_Assoc_tbl        => l_x_Line_Adj_Assoc_tbl
    );


    -- Reset recursion mode.
    --  OE_GLOBALS.G_RECURSION_MODE := 'N';

    oe_debug_pub.add('after process order call ',2);
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        oe_debug_pub.add('error1',2);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        oe_debug_pub.add('error2',2);
        RAISE FND_API.G_EXC_ERROR;
    END IF;

   end if; /* if l_adj_tbl.count >= 1 */

    oe_debug_pub.add('no error in process order ',2);
    x_return_status := l_return_status;
 oe_debug_pub.add('Exiting oe_delayed_requests_util.Process_adjustments',1);


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Adjustments'
            );
	END IF;
        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

NULL;

End Process_Adjustments;

PROCEDURE INSERT_SERVICE_FOR_OPTIONS
(p_serviced_line_id  IN NUMBER
,x_return_status OUT NOCOPY VARCHAR2

)

IS

l_number                      NUMBER := 0;
l_api_name                    CONSTANT VARCHAR(30) := 'INSERT_SERVICE_FOR_OPTIONS';
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               Varchar2(30);
l_orig_line_rec               OE_Order_PUB.Line_Rec_Type;
l_reference_line_rec          OE_Order_Pub.Line_Rec_Type;
l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_old_line_tbl                OE_Order_PUB.Line_Tbl_Type;
l_line_id                     NUMBER;
l_service_reference_line_id   NUMBER;
l_header_id                   NUMBER;
l_line_number                 NUMBER;
l_order_number                NUMBER;
l_shipment_number             NUMBER;
l_option_number               NUMBER;
l_component_number            NUMBER;
x_del_req_ret_status          VARCHAR2(1);


-- For bug 2372098
TYPE Line_Cur_Type IS ref CURSOR;
srv_children line_cur_type;

-- Commented for bug 2372098, this static cursor is replaced
-- with a  cursor variable named srv_children

-- 	CURSOR srv_children IS
-- 	SELECT l.header_id,
-- 		  l.line_id,
-- 		  l.shipment_number,
-- 		  l.line_number,
-- 		  l.option_number,
--                   l.component_number,
-- 		  l.service_txn_reason_code,
-- 		  l.service_txn_comments,
-- 		  l.service_duration,
-- 		  l.service_period,
-- 		  l.service_start_date,
-- 		  l.service_end_date,
-- 		  l.service_coterminate_flag,
-- 		  l.ordered_quantity
--      FROM   oe_order_lines l
--      WHERE  l.top_model_line_id = l_service_reference_line_id
--      AND    l.item_type_code in ('INCLUDED','CLASS','OPTION')
-- 	AND    exists (select null from mtl_system_items mtl where
-- 		  mtl.inventory_item_id = l.inventory_item_id and
-- 		  mtl.serviceable_product_flag = 'Y' and
--               mtl.organization_id=OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID') );
        --lchen added check for organizations to fix bug 2039304

     CURSOR srv_number IS
     SELECT max(l.service_number) service_number
	FROM   oe_order_lines l
     WHERE  l.header_id = l_header_id
     AND    l.line_number   = l_line_number
     AND    l.shipment_number = l_shipment_number
     AND    nvl(l.option_number,0) = nvl(l_option_number,0)
     AND    nvl(l.component_number,0) = nvl(l_component_number,0);

BEGIN

  OE_DEBUG_PUB.ADD('Entering INSERT_SERVICE_FOR_OPTIONS',1);

  IF fnd_profile.value('ONT_CASCADE_SERVICE') = 'N' THEN
    /* 3128684 */
    oe_debug_pub.add('Do not cascade services', 2);
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;
  oe_debug_pub.add('Do cascade services', 2);

  -- query the service line and to see if it's a referenced line
  OE_Line_Util.query_row(p_line_id  => p_serviced_line_id,
					x_line_rec => l_orig_line_rec);

     SELECT /* MOAC_SQL_CHANGE */ h.order_number
     INTO   l_order_number
     FROM   oe_order_headers_all h, oe_order_lines l
     WHERE  h.header_id = l.header_id
     AND    h.header_id = l_orig_line_rec.header_id
	AND    rownum = 1;



  IF l_orig_line_rec.service_reference_type_code is NOT NULL THEN
     OE_Line_Util.query_row(p_line_id  => l_orig_line_rec.service_reference_line_id,
	                       x_line_rec => l_reference_line_rec);
     l_service_reference_line_id := l_orig_line_rec.service_reference_line_id;
	oe_debug_pub.add('JPN: Service Reference Line is' || l_service_reference_line_id,2);

-- For bug 2372098, the cursor variable srv_children would be associated
-- with different queries based on source_type_document_id.

-- * IMPORTANT *
-- If the following SELECT statements are modified, then the definition of
-- t_line_rec in OEXUREQS.pls also needs to be modified, else  fetching
-- records from the cursor variable srv_children into l_child would
-- raise an exception

     IF (l_orig_line_rec.source_document_type_id = 2 ) THEN

	OPEN srv_children FOR
	  SELECT l.header_id,
		  l.line_id,
		  l.shipment_number,
		  l.line_number,
		  l.option_number,
                  l.component_number,
		  l.service_txn_reason_code,
		  l.service_txn_comments,
		  l.service_duration,
		  l.service_period,
		  l.service_start_date,
		  l.service_end_date,
		  l.service_coterminate_flag,
		  l.ordered_quantity
	  FROM   oe_order_lines l
	  WHERE  l.top_model_line_id = l_service_reference_line_id
	  AND    l.item_type_code = 'INCLUDED'
	  AND    exists (select null from mtl_system_items mtl where
		    mtl.inventory_item_id = l.inventory_item_id and
		    mtl.serviceable_product_flag = 'Y' and
			 mtl.organization_id=OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID') );
      ELSE

	OPEN srv_children FOR
	  SELECT l.header_id,
		  l.line_id,
		  l.shipment_number,
		  l.line_number,
		  l.option_number,
                  l.component_number,
		  l.service_txn_reason_code,
		  l.service_txn_comments,
		  l.service_duration,
		  l.service_period,
		  l.service_start_date,
		  l.service_end_date,
		  l.service_coterminate_flag,
		  l.ordered_quantity
	  FROM   oe_order_lines l
	  WHERE  l.top_model_line_id = l_service_reference_line_id
          AND    l.top_model_line_id <> l.line_id     -- For bug 2938790
	  AND    l.item_type_code in ('INCLUDED','CLASS','OPTION', 'KIT') -- For bug 2447402
	  AND    exists (select null from mtl_system_items mtl where
			 mtl.inventory_item_id = l.inventory_item_id and
			 mtl.serviceable_product_flag = 'Y' and
			 mtl.organization_id=OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID') );
     END IF; /* source_type_doc_id = 2 */
-- End 2372098

-- For bug 2372098
-- FOR cannot be used on cursor variables, so adding the following
-- loop to fetch the records.
--    FOR l_child IN srv_children LOOP

     LOOP
	FETCH srv_children INTO l_child;
	EXIT WHEN srv_children%NOTFOUND;

     -- Bug 7717223
     -- Delete the G_CASCADE_OPTIONS_SERVICE delayed request logged for the option/included lines
     -- this is necessary when both G_INSERT_SERVICE and G_CASCADE_OPTIONS_SERVICE requests are logged in the same session
     -- Execution of both will result in duplicate service lines attached to included items

     OE_Delayed_Requests_PVT.Delete_Request
			(p_entity_code   => OE_GLOBALS.G_ENTITY_LINE
                        ,p_entity_id     => l_child.line_id
                        ,p_request_Type  => OE_GLOBALS.G_CASCADE_OPTIONS_SERVICE
                        ,x_return_status => x_del_req_ret_status);

     OE_DEBUG_PUB.ADD('x_del_req_ret_status :'||x_del_req_ret_status);

    --End bug7717223

     l_number := l_number + 1;
     l_line_tbl(l_number) := OE_ORDER_PUB.G_MISS_LINE_REC;
     l_line_tbl(l_number).service_reference_type_code := 'ORDER';
     l_line_tbl(l_number).service_reference_line_id   := l_child.line_id;
-- aksingh change it not right
     l_line_tbl(l_number).service_reference_system_id := l_child.line_id;
     l_line_tbl(l_number).service_txn_reason_code     := l_child.service_txn_reason_code;
     l_line_tbl(l_number).service_txn_comments := l_child.service_txn_comments;
     l_line_tbl(l_number).service_duration     := l_orig_line_rec.service_duration;
     l_line_tbl(l_number).service_period       := l_orig_line_rec.service_period;
     l_line_tbl(l_number).service_start_date   := l_orig_line_rec.service_start_date;
     l_line_tbl(l_number).service_end_date     := l_orig_line_rec.service_end_date;
     l_line_tbl(l_number).service_coterminate_flag := l_orig_line_rec.service_coterminate_flag;
     l_line_tbl(l_number).ordered_quantity   := l_child.ordered_quantity;
     l_line_tbl(l_number).order_quantity_uom := l_orig_line_rec.order_quantity_uom;
     l_line_tbl(l_number).item_identifier_type := 'INT';
     l_line_tbl(l_number).item_type_code := OE_GLOBALS.G_ITEM_SERVICE;
     l_Line_tbl(l_number).operation      := OE_GLOBALS.G_OPR_CREATE;
     l_line_tbl(l_number).header_id      := l_orig_line_rec.header_id;
     l_line_tbl(l_number).inventory_item_id := l_orig_line_rec.inventory_item_id;
     l_line_tbl(l_number).service_reference_line_id := l_child.line_id;
     --l_line_tbl(l_number).top_model_line_id := l_service_reference_line_id;
     --for bug 2545545
     l_line_tbl(l_number).context := l_orig_line_rec.context;
     l_line_tbl(l_number).attribute1 := l_orig_line_rec.attribute1;
     l_line_tbl(l_number).attribute2 := l_orig_line_rec.attribute2;
     l_line_tbl(l_number).attribute3 := l_orig_line_rec.attribute3;
     l_line_tbl(l_number).attribute4 := l_orig_line_rec.attribute4;
     l_line_tbl(l_number).attribute5 := l_orig_line_rec.attribute5;
     l_line_tbl(l_number).attribute6 := l_orig_line_rec.attribute6;
     l_line_tbl(l_number).attribute7 := l_orig_line_rec.attribute7;
     l_line_tbl(l_number).attribute8 := l_orig_line_rec.attribute8;
     l_line_tbl(l_number).attribute9 := l_orig_line_rec.attribute9;
     l_line_tbl(l_number).attribute10 := l_orig_line_rec.attribute10;
     l_line_tbl(l_number).attribute11 := l_orig_line_rec.attribute11;
     l_line_tbl(l_number).attribute12 := l_orig_line_rec.attribute12;
     l_line_tbl(l_number).attribute13 := l_orig_line_rec.attribute13;
     l_line_tbl(l_number).attribute14 := l_orig_line_rec.attribute14;
     l_line_tbl(l_number).attribute15 := l_orig_line_rec.attribute15;
     --end 2545545
     l_header_id   := l_child.header_id;
     l_line_number := l_child.line_number;
     l_shipment_number := l_child.shipment_number;
     l_option_number   := l_child.option_number;
     oe_debug_pub.add('l_number         => ' || to_char(l_number),2);
     oe_debug_pub.add('l_child.header_id=> ' || to_char(l_child.header_id),2);
 --    oe_debug_pub.add('item_type_code   => ' || to_char(l_child.item_type_code),2);
     oe_debug_pub.add('l_child.line_id=> ' || to_char(l_child.line_id),2);
     oe_debug_pub.add('l_child.shipment_number=> ' || to_char(l_child.shipment_number),2);
     oe_debug_pub.add('l_child.option_number=> ' || to_char(l_child.option_number),2);
     oe_debug_pub.add('l_child.component_number=> ' || to_char(l_child.component_number),2);
     oe_debug_pub.add('l_child.service_txn_reason_code=> ' || l_child.service_txn_reason_code,2);
     oe_debug_pub.add('l_orig_line_rec.service_duration => ' || l_orig_line_rec.service_duration,2);
     oe_debug_pub.add('l_orig_line_rec.service_period=> ' || l_orig_line_rec.service_period ,2);
     oe_debug_pub.add('l_orig_line_rec.service_start_date=> ' || l_orig_line_rec.service_start_date,2);
     oe_debug_pub.add('l_orig_line_rec.service_end_date=> ' ||l_orig_line_rec.service_end_date ,2);

--	l_line_tbl(l_number).line_number := l_child.line_number;
--	l_line_tbl(l_number).shipment_number := l_child.shipment_number;
	l_line_tbl(l_number).line_number := l_orig_line_rec.line_number;  -- For bug 2924241
	l_line_tbl(l_number).shipment_number := l_orig_line_rec.shipment_number;
	l_line_tbl(l_number).option_number := l_child.option_number;
	l_line_tbl(l_number).component_number := l_child.component_number;

     FOR l_srv_number IN srv_number LOOP
       oe_debug_pub.add('Inside l_srv_number loop      ',2);
       l_line_tbl(l_number).service_number := l_srv_number.service_number + 1;
     END LOOP;
    END LOOP;

-- for bug 2372098
     IF ( srv_children%ISOPEN ) THEN
	CLOSE srv_children;
     END IF;
-- end 2372098

  END IF;

  IF l_number > 0 THEN
    oe_debug_pub.add('SRV: Found options and included item lines', 1);

    --  Set control flags.
    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.default_attributes   := TRUE;
    l_control_rec.change_attributes    := TRUE;
    l_control_rec.clear_dependents     := TRUE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Call OE_Order_PVT.Process_order to insert lines
    -- Set recursion mode.
    --  OE_GLOBALS.G_RECURSION_MODE := 'Y';

    OE_ORDER_PVT.Lines
    (P_validation_level          => FND_API.G_VALID_LEVEL_FULL
    ,p_control_rec               => l_control_rec
    ,p_x_line_tbl                => l_line_tbl
    ,p_x_old_line_tbl            => l_old_line_tbl
    ,x_return_status             => l_return_status);

    -- Reset recursion mode.
    -- OE_GLOBALS.G_RECURSION_MODE := 'N';

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        oe_debug_pub.add('Inside unexpected error  ',2);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        oe_debug_pub.add('Inside error  ',2);
        RAISE FND_API.G_EXC_ERROR;
    END IF;

--comment out for notification project
/*    OE_ORDER_PVT.Process_Requests_And_notify
    ( p_process_requests       => FALSE
     ,p_notify                 => TRUE
     ,x_return_status          => l_return_status
     ,p_line_tbl               => l_line_tbl
     ,p_old_line_tbl           => l_old_line_tbl);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
*/
    -- Clear Table
	l_line_tbl.DELETE;
   END IF;  /* End inserting lines */
  OE_DEBUG_PUB.ADD('Exiting INSERT_SERVICE_FOR_OPTIONS',1);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        oe_debug_pub.add('Inside exception exe error  ',1);
	   x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        oe_debug_pub.add('Inside exception unexp error  ',1);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

	   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        oe_debug_pub.add('Inside exception other error  ',1);

	   IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	   THEN
		  OE_MSG_PUB.Add_Exc_Msg
		  (   G_PKG_NAME
            ,  'INSERT_SERVICE_FOR_OPTIONS'
            );
        END IF;

END INSERT_SERVICE_FOR_OPTIONS;


/* lchen added procedure CASCADE_SERVICE_FOR_OPTIONS for bug 1761154 */

PROCEDURE CASCADE_SERVICE_FOR_OPTIONS
(p_option_line_id  IN NUMBER
,x_return_status OUT NOCOPY VARCHAR2

)

IS

l_number                      NUMBER := 0;
l_api_name                    CONSTANT VARCHAR(30) := 'CASCADE_SERVICE_FOR_OPTIONS';
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               Varchar2(30);
l_orig_line_rec               OE_Order_PUB.Line_Rec_Type;
--l_reference_line_rec          OE_Order_Pub.Line_Rec_Type;
l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_old_line_tbl                OE_Order_PUB.Line_Tbl_Type;
--l_line_id                     NUMBER;
l_header_id                   NUMBER;
l_line_number                 NUMBER;
l_order_number                NUMBER;
l_shipment_number             NUMBER;
l_option_number               NUMBER;
l_component_number            NUMBER; -- bug 2447402
l_top_model_line_id           NUMBER;


   CURSOR srv_line IS
   SELECT l.header_id,
          l.line_id,
          l.service_txn_reason_code,
          l.service_txn_comments,
          l.service_duration,
          l.service_period,
          l.service_start_date,
	  l.service_end_date,
	  l.service_coterminate_flag,
          l.order_quantity_uom,
          l.inventory_item_id
   FROM oe_order_lines l
   where l.service_reference_line_id=l_top_model_line_id
   and l.item_type_code = 'SERVICE'
   and l.service_reference_type_code = 'ORDER';

     CURSOR srv_number IS
     SELECT max(l.service_number) service_number
	FROM   oe_order_lines l
     WHERE  l.header_id = l_header_id
     AND    l.line_number   = l_line_number
     AND    l.shipment_number = l_shipment_number
     AND    nvl(l.option_number,0) = nvl(l_option_number,0)
     AND    nvl(l.component_number,0) = nvl(l_component_number,0);    --bug 2447402
BEGIN

  OE_DEBUG_PUB.ADD('Entering CASCADE_SERVICE_FOR_OPTIONS',1);

  IF fnd_profile.value('ONT_CASCADE_SERVICE') = 'N' THEN
    /* 3128684 */
    oe_debug_pub.add('Do not cascade services', 2);
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;
  oe_debug_pub.add('Do cascade services', 2);

  -- query the option line
  OE_Line_Util.query_row(p_line_id  => p_option_line_id,
					x_line_rec => l_orig_line_rec);

     SELECT /* MOAC_SQL_CHANGE */ h.order_number
     INTO   l_order_number
     FROM   oe_order_headers_all h, oe_order_lines l
     WHERE  h.header_id = l.header_id
     AND    h.header_id = l_orig_line_rec.header_id
	AND    rownum = 1;


 l_top_model_line_id := l_orig_line_rec.top_model_line_id;
 oe_debug_pub.add('Top Model Line is' || l_top_model_line_id,2);


    FOR l_child IN srv_line LOOP
     l_number := l_number + 1;
     l_line_tbl(l_number) := OE_ORDER_PUB.G_MISS_LINE_REC;
     l_line_tbl(l_number).service_reference_type_code := 'ORDER';
     l_line_tbl(l_number).service_reference_line_id := l_orig_line_rec.line_id;
     l_line_tbl(l_number).service_reference_system_id := l_orig_line_rec.line_id;
     l_line_tbl(l_number).service_txn_reason_code := l_orig_line_rec.service_txn_reason_code;
     l_line_tbl(l_number).service_txn_comments := l_orig_line_rec.service_txn_comments;
     l_line_tbl(l_number).service_duration     := l_child.service_duration;
     l_line_tbl(l_number).service_period       := l_child.service_period;
     l_line_tbl(l_number).service_start_date   := l_child.service_start_date;
     l_line_tbl(l_number).service_end_date     := l_child.service_end_date;
     l_line_tbl(l_number).service_coterminate_flag := l_child.service_coterminate_flag;
     l_line_tbl(l_number).ordered_quantity   := l_orig_line_rec.ordered_quantity;
     l_line_tbl(l_number).order_quantity_uom := l_child.order_quantity_uom;
     l_line_tbl(l_number).item_identifier_type := 'INT';
     l_line_tbl(l_number).item_type_code := OE_GLOBALS.G_ITEM_SERVICE;
     l_Line_tbl(l_number).operation      := OE_GLOBALS.G_OPR_CREATE;
     l_line_tbl(l_number).header_id      := l_child.header_id;
     l_line_tbl(l_number).inventory_item_id := l_child.inventory_item_id;
     --l_line_tbl(l_number).top_model_line_id := l_top_model_line_id;
     l_header_id   := l_orig_line_rec.header_id;
     l_line_number := l_orig_line_rec.line_number;
     l_shipment_number := l_orig_line_rec.shipment_number;
     l_option_number   := l_orig_line_rec.option_number;
     l_component_number   := l_orig_line_rec.component_number; --bug 2447402

     oe_debug_pub.add('l_number         => ' || to_char(l_number),2);
     oe_debug_pub.add('l_orig_line_rec.header_id=> ' || to_char(l_orig_line_rec.header_id),2);
 --    oe_debug_pub.add('item_type_code   => ' || to_char(l_orig_line_rec.item_type_code),2);
     oe_debug_pub.add('l_orig_line_rec.line_id=> ' || to_char(l_orig_line_rec.line_id),2);
     oe_debug_pub.add('l_orig_line_rec.shipment_number=> ' || to_char(l_orig_line_rec.shipment_number),2);
     oe_debug_pub.add('l_orig_line_rec.option_number=> ' || to_char(l_orig_line_rec.option_number),2);
     oe_debug_pub.add('l_orig_line_rec.service_txn_reason_code=> ' || l_orig_line_rec.service_txn_reason_code,2);
     oe_debug_pub.add('l_child.service_duration => ' || l_child.service_duration,2);
     oe_debug_pub.add('l_child.service_period=> ' || l_child.service_period ,2);
     oe_debug_pub.add('l_child.service_start_date=> ' || l_child.service_start_date,2);
     oe_debug_pub.add('l_child.service_end_date=> ' ||l_child.service_end_date ,2);

	l_line_tbl(l_number).shipment_number := l_orig_line_rec.shipment_number;
	l_line_tbl(l_number).option_number := l_orig_line_rec.option_number;
	l_line_tbl(l_number).line_number := l_orig_line_rec.line_number;
	l_line_tbl(l_number).component_number := l_orig_line_rec.component_number; --bug 2447402

     FOR l_srv_number IN srv_number LOOP
       oe_debug_pub.add('Inside l_srv_number loop      ',2);
       l_line_tbl(l_number).service_number := l_srv_number.service_number + 1;
     END LOOP;
    END LOOP;


  IF l_number > 0 THEN
    oe_debug_pub.add('Inside cascade_service_for_options, Found top model service and options lines', 1);

    --  Set control flags.
    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.default_attributes   := TRUE;
    l_control_rec.change_attributes    := TRUE;
    l_control_rec.clear_dependents     := TRUE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Call OE_Order_PVT.Process_order to insert lines
    -- Set recursion mode.
    --  OE_GLOBALS.G_RECURSION_MODE := 'Y';

    OE_ORDER_PVT.Lines
    (P_validation_level          => FND_API.G_VALID_LEVEL_FULL
    ,p_control_rec               => l_control_rec
    ,p_x_line_tbl                => l_line_tbl
    ,p_x_old_line_tbl            => l_old_line_tbl
    ,x_return_status             => l_return_status);

    -- Reset recursion mode.
    -- OE_GLOBALS.G_RECURSION_MODE := 'N';

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        oe_debug_pub.add('Inside unexpected error  ',2);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        oe_debug_pub.add('Inside error  ',2);
        RAISE FND_API.G_EXC_ERROR;
    END IF;

--comment out for notification project
/*    OE_ORDER_PVT.Process_Requests_And_notify
    ( p_process_requests       => FALSE
     ,p_notify                 => TRUE
     ,x_return_status          => l_return_status
     ,p_line_tbl               => l_line_tbl
     ,p_old_line_tbl           => l_old_line_tbl);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
*/
    -- Clear Table
	l_line_tbl.DELETE;
   END IF;  /* End inserting lines */
  OE_DEBUG_PUB.ADD('Exiting CASCADE_SERVICE_FOR_OPTIONS',1);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        oe_debug_pub.add('Inside exception exe error  ',1);
	   x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        oe_debug_pub.add('Inside exception unexp error  ',1);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

	   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        oe_debug_pub.add('Inside exception other error  ',1);

	   IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	   THEN
		  OE_MSG_PUB.Add_Exc_Msg
		  (   G_PKG_NAME
            ,  'CASCADE_SERVICE_FOR_OPTIONS'
            );
         END IF;

END CASCADE_SERVICE_FOR_OPTIONS;


PROCEDURE Apply_Automatic_Attachments
( p_entity_code			IN VARCHAR2
, p_entity_id				IN NUMBER
, p_is_user_action			IN VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2

)
IS
l_attachment_count			NUMBER;
l_msg_count				NUMBER;
l_msg_data				VARCHAR2(2000);
BEGIN

OE_DEBUG_PUB.Add('Enter OE_DELAYED_REQUESTS_UTIL.Apply_Automatic_Attachments', 0.5);   --debug level changed to 0.5 for bug13435459

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	OE_Atchmt_Util.Apply_Automatic_Attachments
			( p_entity_code		=> p_entity_code
			, p_entity_id		=> p_entity_id
			, p_is_user_action	=> p_is_user_action
			, x_attachment_count => l_attachment_count
			, x_return_status	  => x_return_status
			, x_msg_count		  => l_msg_count
			, x_msg_data		  => l_msg_data
			);
     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;

OE_DEBUG_PUB.Add('Exit OE_DELAYED_REQUESTS_UTIL.Apply_Automatic_Attachments', 0.5);  --debug level changed to 0.5 for bug 13435459

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
            ,   'Apply_Automatic_Attachments'
		);
        END IF;
END Apply_Automatic_Attachments;

PROCEDURE Copy_Attachments
( p_entity_code			IN VARCHAR2
, p_from_entity_id			IN NUMBER
, p_to_entity_id			IN NUMBER
, p_manual_attachments_only	IN VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2

)
IS
BEGIN

OE_DEBUG_PUB.Add('Enter OE_DELAYED_REQUESTS_UTIL.Copy_Attachments, manual only'||
		p_manual_attachments_only, 0.5);  --debug level changed to 0.5 for bug13435459

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	OE_Atchmt_Util.Copy_Attachments
			( p_entity_code		=> p_entity_code
			, p_from_entity_id		=> p_from_entity_id
			, p_to_entity_id		=> p_to_entity_id
			, p_manual_attachments_only	=> NVL(p_manual_attachments_only,'N')
			, x_return_status	  => x_return_status
			);
     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;

OE_DEBUG_PUB.Add('Exit OE_DELAYED_REQUESTS_UTIL.Copy_Attachments', 0.5);   --debug level changed to 0.5 for bug13435459

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
            ,   'Copy_Attachments'
		);
        END IF;
END Copy_Attachments;
/*-------------------------------------------------------------------
Procedure: Schedule_Line
Description: This procedure will be called when the delayed request
		   SCHEDULE_LINE is logged. This delayed request is logged
             when new lines are inserted to a SCHEDULE SET. A set being
             a user defined ship or arrival set, or a system defined
             ATO or SMC PTO model. When multiple lines are inserted
             to the same set, this procedure is called once for all the
             lines of the set.
-------------------------------------------------------------------*/
Procedure Schedule_Line
( p_sch_set_tbl     IN  OE_ORDER_PUB.request_tbl_type
, x_return_status OUT NOCOPY VARCHAR2)

IS
l_ship_set_id        NUMBER := null;
l_arrival_set_id     NUMBER := null;
l_request_rec        OE_Order_PUB.request_rec_type;
l_line_rec           OE_ORDER_PUB.line_rec_type;
l_old_line_rec       OE_ORDER_PUB.line_rec_type;
l_out_line_rec       OE_ORDER_PUB.line_rec_type;
l_atp_tbl            OE_ATP.atp_tbl_type;
l_return_status      VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_group_req_rec      OE_GRP_SCH_UTIL.Sch_Group_Rec_Type;
l_group_sch_required BOOLEAN := TRUE;
BEGIN

  oe_debug_pub.add('Entering OE_Delayed_Requests_UTIL.Schedule_Line',1);

  OE_ORDER_SCH_UTIL.OESCH_PERFORM_GRP_SCHEDULING := 'N';

  FOR I in 1..p_sch_set_tbl.count LOOP

      l_request_rec  := p_sch_set_tbl(I);
	 -- Assiging miss rec.
	 l_line_rec     := OE_ORDER_PUB.G_MISS_LINE_REC;

      OE_LINE_UTIL.Lock_Row(p_line_id       => l_request_rec.entity_id,
	                       p_x_line_rec    => l_line_rec,
					   x_return_status => l_return_status);

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

      l_old_line_rec                      :=  l_line_rec;

      l_old_line_rec.schedule_ship_date   :=  null;
      l_old_line_rec.schedule_arrival_date:=  null;

      /* Start Audit Trail */
	 l_line_rec.change_reason := 'SYSTEM';
	 /* End Audit Trail */

      l_line_rec.operation             :=  OE_GLOBALS.G_OPR_UPDATE;

      IF p_sch_set_tbl(I).request_type = OE_GLOBALS.G_SCHEDULE_LINE THEN
          l_line_rec.schedule_action_code  :=
                             OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE;
          l_old_line_rec.ship_set_id           := l_request_rec.param9;
          l_old_line_rec.arrival_set_id        := l_request_rec.param10;
      ELSE

          l_old_line_rec.request_date          := l_request_rec.date_param1;
          l_old_line_rec.schedule_ship_date    := l_request_rec.date_param2;
          l_old_line_rec.schedule_arrival_date := l_request_rec.date_param3;
          l_old_line_rec.ship_from_org_id      := l_request_rec.param7;
          l_old_line_rec.ship_to_org_id        := l_request_rec.param8;
          l_old_line_rec.ship_set_id           := l_request_rec.param9;
          l_old_line_rec.arrival_set_id        := l_request_rec.param10;
      END IF;

      IF (l_line_rec.ato_line_id is not null and
          NOT (l_line_rec.ato_line_id = l_line_rec.line_id and
          l_line_rec.item_type_code IN (OE_GLOBALS.G_ITEM_STANDARD,
                                        OE_GLOBALS.G_ITEM_OPTION,
					OE_GLOBALS.G_ITEM_INCLUDED))) OR --9775352
          nvl(l_line_rec.ship_model_complete_flag,'N') = 'Y'
      THEN
         IF l_request_rec.param3 =
                       OE_ORDER_SCH_UTIL.OESCH_ENTITY_ARRIVAL_SET OR
            l_request_rec.param3 =
                       OE_ORDER_SCH_UTIL.OESCH_ENTITY_SHIP_SET THEN

                IF (l_line_rec.line_id = l_line_rec.ato_line_id OR
                    l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL)
                THEN
                   -- ATO model or SMC Model
                   l_group_sch_required := TRUE;
                ELSE
                   -- The ato or smc pto line is being inserted into a ship
                   -- or arrival set. Check to see if it is the first line
                   -- to go into the set. If it is, then we will need to
                   -- schedule the whole ATO model.
                   BEGIN
                     SELECT ship_set_id,arrival_set_id
                     INTO l_ship_set_id,l_arrival_set_id
                     FROM oe_order_lines_all
                     WHERE line_id = l_line_rec.ato_line_id;
                   EXCEPTION
                     WHEN OTHERS THEN
                       l_ship_set_id    := null;
                       l_arrival_set_id := null;
                   END;

                   IF l_request_rec.param3 =
                         OE_ORDER_SCH_UTIL.OESCH_ENTITY_SHIP_SET
                        AND l_ship_set_id = to_number(l_request_rec.param1)
                   THEN
                     l_group_sch_required := FALSE;
                   ELSIF l_request_rec.param3 =
                     OE_ORDER_SCH_UTIL.OESCH_ENTITY_ARRIVAL_SET
                     AND l_arrival_set_id = to_number(l_request_rec.param1)
                   THEN
                     l_group_sch_required := FALSE;
                   ELSE
                     l_group_sch_required := TRUE;
                   END IF;
                END IF;

         ELSE
           -- Line being inserted to an schedule ATO model
           l_group_sch_required := FALSE;
         END IF;

      ELSE
         -- Line is not an ATO model or option
         l_group_sch_required := FALSE;
      END IF;

      IF l_group_sch_required THEN

         -- If the line being scheduled is a ATO model, or a SMC PTO, we
         -- need to call group scheduling API.

         OE_ORDER_SCH_UTIL.Create_Group_Request
          (  p_line_rec         => l_line_rec
           , p_old_line_rec     => l_old_line_rec
           , x_group_req_rec    => l_group_req_rec
           , x_return_status    => l_return_status
          );

         l_group_req_rec.old_ship_set_number := l_request_rec.param9;
         l_group_req_rec.old_arrival_set_number := l_request_rec.param10;

         -- Set the Entity as ATO or SMC and not ship set.
	 IF l_line_rec.ato_line_id is not null AND
         NOT (l_line_rec.ato_line_id = l_line_rec.line_id AND
	      l_line_rec.item_type_code IN (OE_GLOBALS.G_ITEM_STANDARD,
                                            OE_GLOBALS.G_ITEM_OPTION,
					    OE_GLOBALS.G_ITEM_INCLUDED)) THEN --9775352

            l_group_req_rec.entity_type :=
                      OE_ORDER_SCH_UTIL.OESCH_ENTITY_ATO_CONFIG;
            l_group_req_rec.ship_set_number := l_line_rec.ato_line_id;
         ELSE

            l_group_req_rec.entity_type :=
                      OE_ORDER_SCH_UTIL.OESCH_ENTITY_SMC;
            l_group_req_rec.ship_set_number := l_line_rec.top_model_line_id;
         END IF;

         oe_debug_pub.add('****Printing Group Request Attributes****',2);
         oe_debug_pub.add('Entity    :' || l_group_req_rec.entity_type,2);
         oe_debug_pub.add('Header Id :' || l_group_req_rec.header_id,2);
         oe_debug_pub.add('Line Id   :' || l_group_req_rec.line_id,2);
         oe_debug_pub.add('Action    :' || l_group_req_rec.action,2);
         oe_debug_pub.add('Warehouse :' || l_group_req_rec.ship_from_org_id,2);
         oe_debug_pub.add('Ship to   :' || l_group_req_rec.ship_to_org_id,2);
         oe_debug_pub.add('Sh Set#   :' || l_group_req_rec.ship_set_number,2);
         oe_debug_pub.add('Ar Set#   :' || l_group_req_rec.arrival_set_number,2);
         oe_debug_pub.add('Ship Date :' || l_group_req_rec.schedule_ship_date,2);
         oe_debug_pub.add('Arr Date  :' || l_group_req_rec.schedule_arrival_date,2);
         oe_debug_pub.add('*******************************************',2);

         oe_debug_pub.add('Calling Grp Schedule : ',2);
         OE_GRP_SCH_UTIL.Group_Schedule
           (p_group_req_rec    => l_group_req_rec
           ,x_atp_tbl          => l_atp_tbl
           ,x_return_status    => l_return_status);

         oe_debug_pub.add('After Calling Grp Schedule : || l_return_status',2);

         oe_debug_pub.add('Setting G_CASCADING_REQUEST_LOGGED to TRUE',2);

         IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
             OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
         END IF;

      ELSE

         oe_debug_pub.add('Sch_Line for line : '|| l_line_rec.line_id,2);

         oe_debug_pub.add('Sch_Line for line : '|| l_line_rec.line_id,2);

	    -- We are doing this to retain the copy of l_line_rec.
         l_out_line_rec := l_line_rec;

         OE_ORDER_SCH_UTIL.Schedule_line
            ( p_x_line_rec     => l_out_line_rec
             , p_old_line_rec  => l_old_line_rec
             , p_write_to_db   => FND_API.G_TRUE
             , x_atp_tbl       => l_atp_tbl
             , x_return_status => l_return_status);


         oe_debug_pub.add('After Calling Sch_Line : '|| l_return_status,2);

      END IF;

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN

oe_debug_pub.add('Line Id error out nocopy : ' || l_line_rec.line_id,2);


         IF l_request_rec.param3 =
                       OE_ORDER_SCH_UTIL.OESCH_ENTITY_ARRIVAL_SET OR
            l_request_rec.param3 =
                       OE_ORDER_SCH_UTIL.OESCH_ENTITY_SHIP_SET THEN

            -- Could not schedule the line on the set date. Let's schedule
            -- the whole set to see if we get another date got the whole
            -- set.

            IF fnd_profile.value('ONT_AUTO_PUSH_GRP_DATE') = 'Y' THEN

                oe_debug_pub.add('Auto Push Group Date is Yes',2);

                -- Added this stmt to fix big 1899651.
                l_line_rec.schedule_action_code  :=
                             OE_ORDER_SCH_UTIL.OESCH_ACT_RESCHEDULE;

                OE_ORDER_SCH_UTIL.Create_Group_Request
                 (  p_line_rec         => l_line_rec
                  , p_old_line_rec     => l_old_line_rec
                  , x_group_req_rec    => l_group_req_rec
                  , x_return_status    => l_return_status
                 );

                oe_debug_pub.add('****Printing Group Request Attributes****',2);
                oe_debug_pub.add('Entity    :' ||
                                    l_group_req_rec.entity_type,20);
                oe_debug_pub.add('Header Id :' ||
                                    l_group_req_rec.header_id,2);
                oe_debug_pub.add('Line Id   :' ||
                                    l_group_req_rec.line_id,2);
                oe_debug_pub.add('Action    :' ||
                                    l_group_req_rec.action,2);
                oe_debug_pub.add('Warehouse :' ||
                                    l_group_req_rec.ship_from_org_id,2);
                oe_debug_pub.add('Ship to   :' ||
                                    l_group_req_rec.ship_to_org_id,2);
                oe_debug_pub.add('Sh Set#   :' ||
                                    l_group_req_rec.ship_set_number,2);
                oe_debug_pub.add('Ar Set#   :' ||
                                    l_group_req_rec.arrival_set_number,2);
                oe_debug_pub.add('Ship Date :' ||
                                    l_group_req_rec.schedule_ship_date,2);
                oe_debug_pub.add('Arr Date  :' ||
                                    l_group_req_rec.schedule_arrival_date,2);
                oe_debug_pub.add('****************************************',2);

                OE_ORDER_SCH_UTIL.OESCH_PERFORM_GRP_SCHEDULING := 'Y';

                oe_debug_pub.add('Calling Grp Schedule : ',2);

                OE_GRP_SCH_UTIL.Group_Schedule
                  (p_group_req_rec    => l_group_req_rec
                  ,x_atp_tbl          => l_atp_tbl
                  ,x_return_status    => l_return_status);

                oe_debug_pub.add('After Calling Grp Schedule : ||
                                               l_return_status',1);

                oe_debug_pub.add('Stng G_CASCADING_REQUEST_LOGGED to TRUE',2);

                IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                    OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
                END IF;
            END IF; /* If Auto Push Group Date is Yes */

            -- Scheduling Failed. If the line belongs to a Ship Set or Arrival
            -- Set, then just clear out the scheduling attributes and return a
            -- message that the line schedule failed. We will return a success
            -- since we do not want to fail the line insert due to this.

            IF l_return_status = FND_API.G_RET_STS_ERROR THEN

               fnd_message.set_name('ONT','OE_SCH_SET_INS_FAILED');
               OE_MSG_PUB.Add;

               IF p_sch_set_tbl(I).request_type = OE_GLOBALS.G_SCHEDULE_LINE
               THEN

                 UPDATE OE_ORDER_LINES_ALL
                 SET
                     (SCHEDULE_SHIP_DATE,
                      SCHEDULE_ARRIVAL_DATE,
                      SHIP_FROM_ORG_ID,
                      SHIP_SET_ID,
                      ARRIVAL_SET_ID) =
                     (SELECT null,
                             null,
                             decode(re_source_flag,'Y',ship_from_org_id,null),
                             null,
                             null
                      FROM OE_ORDER_LINES_ALL
                      WHERE line_id=l_line_rec.line_id)
                 WHERE line_id = l_line_rec.line_id;

               ELSE
                 UPDATE OE_ORDER_LINES_ALL
                 SET
                     SCHEDULE_SHIP_DATE    = l_old_line_rec.schedule_ship_date,
                     SCHEDULE_ARRIVAL_DATE = l_old_line_rec.schedule_arrival_date,
                     SHIP_FROM_ORG_ID      = l_old_line_rec.ship_from_org_id,
                     SHIP_SET_ID           = null,
                     ARRIVAL_SET_ID        = null
                 WHERE line_id = l_line_rec.line_id;
               END IF;

               IF l_line_rec.ship_model_complete_flag = 'Y'
               OR (l_line_rec.ato_line_id is not null
               AND  NOT (l_line_rec.ato_line_id = l_line_rec.line_id AND
                         l_line_rec.item_type_code IN
                                               (OE_GLOBALS.G_ITEM_STANDARD,
                                                OE_GLOBALS.G_ITEM_OPTION,
						OE_GLOBALS.G_ITEM_INCLUDED))) --9775352
               THEN
                 -- Line is part of ato model or smc. Cannot insert a
                 -- line without scheduling the same when parent is
                 -- scheduled.

                  -- Bug 2185769
                  oe_debug_pub.add('Before failing the line',1);
                  fnd_message.set_name('ONT','OE_SCH_SET_INS_FAILED');
                  OE_MSG_PUB.Add;

               END IF;

               x_return_status := FND_API.G_RET_STS_SUCCESS;
            END IF; /* l_return_status = error */

         ELSE

            -- Scheduling Failed. If the line belongs to a ATO Model or SMC
            -- PTO, then return an error, since the option cannot be inserted
            -- to a scheduled ATO or SMC PTO if it cannot be scheduled on
            -- the same date as that of the model.

            fnd_message.set_name('ONT','OE_SCH_SET_INS_FAILED');
            OE_MSG_PUB.Add;

            RAISE  FND_API.G_EXC_ERROR;


         END IF;
      END IF; /* If g_ret_status is error */

  END LOOP;
  OE_ORDER_SCH_UTIL.OESCH_PERFORM_GRP_SCHEDULING := 'Y';

  oe_debug_pub.add('Exiting OE_Delayed_Requests_UTIL.Schedule_Line');
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_Line'
            );
        END IF;


    WHEN OTHERS THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_Line'
            );
        END IF;

END Schedule_Line;

PROCEDURE Process_Tax
( p_entity_id_tbl   IN OE_Delayed_Requests_PVT.Entity_Id_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2)

IS
l_return_status               Varchar2(30):= FND_API.G_RET_STS_SUCCESS;
l_tax_value                   NUMBER := 0;
l_msg_count		          NUMBER := 0;
l_tax_count		          NUMBER := 0;
l_tax_index		          NUMBER := 0;
l_count		               NUMBER := 0;
l_index		               NUMBER := 0;
l_counter		               NUMBER := 0;
index1		               NUMBER := 0;
l_msg_data		          VARCHAR2(2000);
l_match_flag		          VARCHAR2(1);
l_header_id		          NUMBER;
l_line_id		               NUMBER;
l_ship_to_org_id              NUMBER;
l_unit_selling_price          NUMBER;
l_price_adjustment_id         NUMBER;
new_tax_value		       NUMBER;
l_tax_rec_out_tbl             OM_TAX_UTIL.om_tax_out_tab_type;
l_tax_classification_code     VARCHAR2(50);
l_tax_rate_id                 NUMBER;
l_Line_Adj_rec                OE_Order_PUB.Line_Adj_Rec_Type;
l_l_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
v_start NUMBER;
v_end NUMBER;
l_tax_date                    DATE;
l_inventory_item_id           NUMBER;
l_inventory_org_id            NUMBER;
l_tax_exempt_flag             VARCHAR2(1);
l_tax_exempt_number           VARCHAR2(80);
l_tax_exempt_reason_code      VARCHAR2(30);
l_invoicing_rule_id           NUMBER;
l_fob_point_code              VARCHAR2(30);
l_ordered_quantity            NUMBER;
l_ship_from_org_id            NUMBER;
l_payment_term_id             NUMBER;
l_salesrep_id                 NUMBER;
l_invoice_to_org_id           NUMBER;
l_line_type_id                NUMBER;
l_request_date                DATE;
l_org_id                      NUMBER;
l_conversion_rate             NUMBER;
l_currency_code               VARCHAR2(30) := NULL;
l_global_attribute5           VARCHAR2(240);
l_global_attribute6           VARCHAR2(240);
l_payment_type_code			VARCHAR2(30);
l_commitment_id			NUMBER;
l_line_category_code	      VARCHAR2(30);
l_booked_flag		      VARCHAR2(1);
l_shipped_quantity		NUMBER;
--for bug 2610630 begin
l_orig_sys_doc_ref            VARCHAR2(50);
l_orig_sys_line_ref           VARCHAR2(50);
l_order_src_id                NUMBER;
--for bug 2610630 end
l_call_credit_checking        VARCHAR2(30);
l_request_ind                  NUMBER;
l_orig_sys_shipment_ref       VARCHAR2(50);
l_change_sequence             VARCHAR2(50);
l_source_document_type_id     NUMBER;
l_source_document_id          NUMBER;
l_source_document_line_id     NUMBER;
l_actual_shipment_date        DATE;
l_schedule_ship_date          DATE;
l_pricing_quantity_uom        oe_order_lines.pricing_quantity_uom%TYPE;
l_order_quantity_uom          oe_order_lines.order_quantity_uom%TYPE;
l_user_item_description       oe_order_lines.user_item_description%TYPE;
l_global_attribute_category   VARCHAR2(30);
l_line_rec                    OE_Order_PUB.Line_Rec_Type;
l_header_rec                  OE_Order_PUB.Header_Rec_Type;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
-- bug 4378531
l_hold_result                 VARCHAR2(30);

l_old_line_tbl                oe_order_pub.line_tbl_type;  -- Bug 8825061
l_line_tbl                    oe_order_pub.line_tbl_type;  -- Bug 8825061
l_global_index                NUMBER;                      -- Bug 8825061
l_last_update_date            oe_order_lines_all.last_update_date%type; --14154549


BEGIN

  IF l_debug_level > 0 THEN
    v_start := DBMS_UTILITY.GET_TIME;
    oe_debug_pub.add('Entering Process_Tax ',0.5);  --debug level 0.5 added for bug13435459
  END IF;
    x_return_status  := l_return_status;

    -- Get All Line records
    l_index := p_entity_id_tbl.FIRST;
    WHILE l_index IS NOT NULL LOOP
	   l_line_id := p_entity_id_tbl(l_index).entity_id;
        Begin  --for bug 2173168
	   SELECT /* MOAC_SQL_CHANGE */ l.header_id,
	       l.tax_value,
	       l.ship_to_org_id,
	       l.unit_selling_price,
               l.tax_date,
               l.inventory_item_id,
               l.tax_exempt_flag,
               l.tax_exempt_number,
               l.tax_exempt_reason_code,
               l.invoicing_rule_id,
               l.fob_point_code,
               l.ordered_quantity,
               l.ship_from_org_id,
               l.payment_term_id,
               l.tax_code,
               l.salesrep_id,
               l.invoice_to_org_id,
               l.line_type_id,
               l.request_date,
               l.org_id,
               h.conversion_rate,
               h.transactional_curr_code,
               l.global_attribute5,
               l.global_attribute6,
               l.commitment_id,
               l.line_category_code,
               l.shipped_quantity,
	       h.payment_type_code,
               h.booked_flag,
               l.orig_sys_document_ref,
               l.orig_sys_line_ref,
               l.order_source_id,
               l.orig_sys_shipment_ref,
               l.change_sequence,
               l.source_document_type_id,
               l.source_document_id,
               l.source_document_line_id,
               l.actual_shipment_date,
               l.schedule_ship_date,
               l.pricing_quantity_uom,
               l.order_quantity_uom,
               l.user_item_description,
               l.global_attribute_category,
			   l.last_update_date --14154549
	   INTO   l_header_id,
	       l_tax_value,
	       l_ship_to_org_id,
	       l_unit_selling_price,
               l_tax_date,
               l_inventory_item_id,
               l_tax_exempt_flag,
               l_tax_exempt_number,
               l_tax_exempt_reason_code,
               l_invoicing_rule_id,
               l_fob_point_code,
               l_ordered_quantity,
               l_ship_from_org_id,
               l_payment_term_id,
               l_tax_classification_code,
               l_salesrep_id,
               l_invoice_to_org_id,
               l_line_type_id,
               l_request_date,
               l_org_id,
               l_conversion_rate,
               l_currency_code,
               l_global_attribute5,
               l_global_attribute6,
               l_commitment_id,
               l_line_category_code,
               l_shipped_quantity,
	       l_payment_type_code,
               l_booked_flag,
               l_orig_sys_doc_ref,
               l_orig_sys_line_ref,
               l_order_src_id,
               l_orig_sys_shipment_ref,
               l_change_sequence,
               l_source_document_type_id,
               l_source_document_id,
               l_source_document_line_id,
               l_actual_shipment_date,
               l_schedule_ship_date,
               l_pricing_quantity_uom,
               l_order_quantity_uom,
               l_user_item_description,
               l_global_attribute_category,
               l_last_update_date	--14154549
	   FROM OE_ORDER_HEADERS h,
		   OE_ORDER_LINES_all l
	   WHERE l.HEADER_ID = h.HEADER_ID
	   AND l.LINE_ID = l_line_id;
  -- incl. 3 parameters l_orig_sys_doc_ref,l_orig_sys_line_ref,l_order_src_id
  -- below to fix bug 2610630 and 2508851

        OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => l_line_id
         ,p_header_id                   => l_header_id
         ,p_line_id                     => l_line_id
         ,p_orig_sys_document_ref       => l_orig_sys_doc_ref
         ,p_orig_sys_document_line_ref  => l_orig_sys_line_ref
         ,p_orig_sys_shipment_ref       => l_orig_sys_shipment_ref
         ,p_change_sequence             => l_change_sequence
         ,p_order_source_id             => l_order_src_id
         ,p_source_document_type_id     => l_source_document_type_id
         ,p_source_document_id          => l_source_document_id
         ,p_source_document_line_id     => l_source_document_line_id
        );


          l_line_rec.line_id                   :=   l_line_id;
          l_line_rec.header_id                 :=   l_header_id;
          l_line_rec.ship_to_org_id            :=   l_ship_to_org_id;
          l_line_rec.invoice_to_org_id         :=   l_invoice_to_org_id;
          l_line_rec.tax_date                  :=   l_tax_date;
          l_line_rec.ordered_quantity          :=   l_ordered_quantity;
          l_line_rec.unit_selling_price        :=   l_unit_selling_price;
          l_line_rec.tax_exempt_number         :=   l_tax_exempt_number;
          l_line_rec.tax_Exempt_reason_code    :=   l_tax_Exempt_reason_code;
          l_line_rec.tax_exempt_flag           :=   l_tax_exempt_flag;
          l_line_rec.inventory_item_id         :=   l_inventory_item_id;
          l_line_rec.ship_from_org_id          :=   l_ship_from_org_id;
          l_line_rec.fob_point_code            :=   l_fob_point_code;
          l_line_rec.tax_code                  :=   l_tax_classification_code;
          l_line_rec.actual_shipment_date      :=   l_actual_shipment_date;
          l_line_rec.schedule_ship_date        :=   l_schedule_ship_date;
          l_line_rec.pricing_quantity_uom      :=   l_pricing_quantity_uom;
          l_line_rec.order_quantity_uom        :=   l_order_quantity_uom;
          l_line_rec.user_item_description     :=   l_user_item_description;
          l_line_rec.global_Attribute_category :=   l_global_Attribute_category;
          l_line_rec.global_Attribute5         :=   l_global_Attribute5;
          l_line_rec.global_attribute6         :=   l_global_attribute6;
          l_line_rec.tax_value                 :=   l_tax_value;
          l_line_rec.line_type_id              :=   l_line_type_id;
          l_line_rec.salesrep_id               :=   l_salesrep_id;
          l_line_rec.request_date              :=   l_request_date;
          l_line_rec.invoicing_rule_id         :=   l_invoicing_rule_id;
          l_line_rec.line_category_code        :=   l_line_category_code;
          l_line_rec.payment_term_id           :=   l_payment_term_id;
          l_line_rec.COMMITMENT_ID             :=   l_commitment_id; --bug6447586

          l_line_rec.org_id := l_org_id;  -- Added for bug 6661500
		  l_line_rec.last_update_date          :=   l_last_update_date; --14154549

          oe_order_cache.load_order_header(l_line_rec.header_id);
          l_header_rec := oe_order_cache.g_header_rec;
         --l_header_Rec.transactional_curr_code  := l_currency_code ;
         --l_header_Rec.org_id                   := l_org_id                  ;
         --l_header_Rec.conversion_rate          := l_conversion_rate         ;


        -- l_inventory_org_id := oe_sys_parameters.value('MASTER_ORGANIZATION_ID',l_org_id);

        l_request_ind := p_entity_id_tbl(l_index).request_ind;
        IF l_debug_level > 0 THEN
          oe_debug_pub.add( 'value count '|| OE_Delayed_Requests_PVT.G_Delayed_Requests.count);
		  oe_debug_pub.add('OEXUREQB 1 l_last_update_date = '||l_last_update_date); --14154549
        END IF;

     /* Bug # 3337661: Corrected IF stmt by using OE_GLOBALS.G_TAX_LINE */
     -- Front Ported for bug 3397062
     if OE_Delayed_Requests_PVT.G_Delayed_Requests.exists(l_request_ind) and OE_Delayed_Requests_PVT.G_Delayed_Requests(l_request_ind).request_type =
     OE_GLOBALS.G_TAX_LINE then

        l_call_credit_checking := OE_Delayed_Requests_PVT.G_Delayed_Requests(l_request_ind).param1;

      end if;

      IF l_debug_level > 0 THEN
       oe_debug_pub.add('OEXUREQB: call_credit_checking is: '||l_call_credit_checking,1);
      END IF;

        l_tax_rec_out_tbl.delete; /* initializing the l_tax_rec_out_tbl */

        OM_TAX_UTIL.TAX_LINE(
	 p_line_rec => l_line_rec,
         p_header_rec => l_header_rec,
         x_tax_value => new_tax_value,
         x_tax_out_tbl => l_tax_rec_out_tbl,
         x_return_status => l_return_status );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

      IF l_debug_level > 0 THEN
        oe_debug_pub.add('After Successfully calculating Tax',2);
        oe_debug_pub.add('Old tax value :'||to_char(l_tax_value),2);
        oe_debug_pub.add('New tax value :'||to_char(new_tax_value),2);
        oe_debug_pub.add('return status : ' || l_return_status, 1);
        oe_debug_pub.add('Tax classification code : '||l_tax_classification_code,1);
      END IF;

	--   IF NVL(new_tax_value,0) <> NVL(l_tax_value,0) THEN
       --changed if condition to fix bug 2198380
      -- if l_return_status = 'N' then tax engine was not called.
      -- Hence, the following check.

      --  Changed the file condition for bug 3367812
    IF l_return_status <> 'N' OR l_tax_classification_code IS NULL  THEN


       if ( (l_tax_value is not null and new_tax_value is not null and
             l_tax_value = new_tax_value) OR
            (l_tax_value is null and new_tax_value is null )
          ) then
         null;
       else
          IF l_debug_level > 0 THEN
            oe_debug_pub.add('Updateing tax value from '||to_char(l_tax_value)|| ' To ' ||to_char(new_tax_value) ,2);
          END IF;
		  UPDATE OE_ORDER_LINES_ALL
		  SET TAX_VALUE = new_tax_value
		  WHERE line_id = l_line_id;

      -- Bug 8825061: Update the global picture given that the line attribute
      -- "tax_value" has undergone an update.
          IF l_debug_level > 0 THEN
            oe_debug_pub.ADD('8825061: Line_ID: ' || l_line_id, 1);
            oe_debug_pub.add('  8825061: New Tax Value: ' || new_tax_value) ;
          END IF; -- check on l_debug_level

          l_old_line_tbl(1)       :=  l_line_rec;
          l_line_tbl(1)           :=  l_line_rec;
          l_line_tbl(1).tax_value :=  new_tax_value;

          IF (Oe_Code_Control.Code_Release_Level >= '110508')
          THEN
            Oe_Order_Util.Update_Global_Picture
            (
              p_Upd_New_Rec_If_Exists   =>  FALSE,
              p_header_id               =>  l_line_rec.header_id,
              p_old_line_rec            =>  l_old_line_tbl(1),
              p_line_rec                =>  l_line_tbl(1),
              p_line_id                 =>  l_line_rec.line_id,
              x_index                   =>  l_global_index,
              x_return_status           =>  l_return_status
            );

            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('8825061: after update global picture, status: '
                                            || l_return_status, 1 ) ;
              oe_debug_pub.add('8825061: global picture index: '
                                            || l_global_index , 1 ) ;
            END IF;

            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE Fnd_Api.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF l_index IS NOT NULL THEN
              Oe_Order_Util.g_line_tbl(l_global_index).tax_value
                                          := l_line_tbl(1).tax_value;
            END IF; -- Check on l_index being non-null

         END IF; -- Check on code release level
      -- Bug 8825061

             -- lkxu, if tax_value changes, log delayed request for commitment.
             -- bug 1768906
             IF OE_Commitment_Pvt.Do_Commitment_Sequencing
               AND l_commitment_id IS NOT NULL  THEN
                 IF l_debug_level > 0 THEN
                   oe_debug_pub.add('Logging delayed request for Commitment when tax value changes.', 2);
                 END IF;
	         OE_Delayed_Requests_Pvt.Log_Request(
	          p_entity_code		   =>	OE_GLOBALS.G_ENTITY_LINE,
	          p_entity_id		   =>	l_line_id,
	          p_requesting_entity_code =>	OE_GLOBALS.G_ENTITY_LINE,
	          p_requesting_entity_id   =>   l_line_id,
	          p_request_type	   =>	OE_GLOBALS.G_CALCULATE_COMMITMENT,
	          x_return_status	   =>	l_return_status);

              END IF;

            -- Do not log Verify Payment Delayed Requests for Return Lines
            --
            IF l_line_category_code <> 'RETURN' THEN
	       -- lkxu, added for bug 1581188
		  -- Logging delayed requests for Verify Payment if tax value
		  -- has increased AND Payment Type Code is Credit Card.
	       IF NVL(new_tax_value,0) > NVL(l_tax_value,0)
                     AND l_commitment_id IS NULL
		     AND l_payment_type_code = 'CREDIT_CARD' THEN

                  -- if it is a prepaid, do not log request after shipping.
                  IF OE_PrePayment_UTIL.is_prepaid_order(l_header_id) = 'N'
                     OR (OE_PrePayment_UTIL.is_prepaid_order(l_header_id) = 'Y'
                         AND l_booked_flag ='Y'
                         AND l_shipped_quantity IS NULL) THEN
                    IF l_debug_level > 0 THEN
            	     oe_debug_pub.ADD('Logging delayed request for Verify Payment for change in tax value',2);
                    END IF;
            	     OE_delayed_requests_Pvt.log_request
                        (p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
                         p_entity_id              => l_header_id,
                         p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                         p_requesting_entity_id   => l_line_id,
                         p_request_type           => OE_GLOBALS.G_VERIFY_PAYMENT,
                         x_return_status          => l_return_status);
                   END IF;

               -- bug 2238438, credit card collection project.
               -- log delayed request for prepaid order even the tax value
               -- decreased, as a refund request might be needed.
               ELSIF NVL(new_tax_value,0) <  NVL(l_tax_value,0)
                   AND l_commitment_id IS NULL
                   AND OE_PrePayment_UTIL.is_prepaid_order(l_header_id) = 'Y'
                   AND l_booked_flag ='Y'
                   AND l_payment_type_code = 'CREDIT_CARD'
                   AND l_shipped_quantity IS NULL THEN
                IF l_debug_level > 0 THEN
            	  oe_debug_pub.ADD('Logging delayed request for Verify Payment for change in tax value for prepaid order',2);
                END IF;
            	OE_delayed_requests_Pvt.log_request
                  (p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
                   p_entity_id              => l_header_id,
                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                   p_requesting_entity_id   => l_line_id,
                   p_request_type           => OE_GLOBALS.G_VERIFY_PAYMENT,
                   x_return_status          => l_return_status);
            END IF;

            -- Start fix for bug# 4378531
            -- end of change for bug 1581188

            -- tbharti, Added for bug 1952363
            -- Tax Value changed, log a delayed request for Verify
            -- Payment if Payment Type Code is not Credit Card.
            -- Fix Bug # 2565813: Added IF condition to check for real change in tax value.
               IF nvl(l_payment_type_code, ' ') <> 'CREDIT_CARD' --bug 2679223
                  AND nvl(l_call_credit_checking, 'Y') <> 'No_Credit_Checking' THEN

	          IF NVL(new_tax_value, 0) >  NVL(l_tax_value, 0) THEN

                     oe_debug_pub.ADD('Logging delayed request for Verify Payment for change in tax value',2);

                     OE_delayed_requests_Pvt.log_request
                      (p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
                       p_entity_id              => l_header_id,
                       p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                       p_requesting_entity_id   => l_line_id,
                       p_request_type           => OE_GLOBALS.G_VERIFY_PAYMENT,
                       x_return_status          => l_return_status);

                  ELSIF NVL(new_tax_value,0) <  NVL(l_tax_value,0) THEN

                    oe_debug_pub.add('CHECKING CREDIT CHECK HOLD FOR HEADER/LINE ID : ' || TO_CHAR (l_header_id) || '/' || TO_CHAR (l_line_id) ) ;

                    OE_HOLDS_PUB.Check_Holds
                      (  p_api_version    => 1.0
                       , p_header_id      => l_header_id
                       , p_line_id        => l_line_id
                       , p_hold_id        => 1
                       , p_entity_code    => 'O'
                       , p_entity_id      => l_header_id
                       , x_result_out     => l_hold_result
                       , x_msg_count      => l_msg_count
                       , x_msg_data       => l_msg_data
                       , x_return_status  => l_return_status
                      );

                    IF ( l_hold_result = FND_API.G_TRUE ) THEN

                       oe_debug_pub.add('Logging delayed request for verify payment for change in tax value and hold exist') ;

            	       OE_delayed_requests_Pvt.log_request
                        (p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
                         p_entity_id              => l_header_id,
                         p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                         p_requesting_entity_id   => l_line_id,
                         p_request_type           => OE_GLOBALS.G_VERIFY_PAYMENT,
                         x_return_status          => l_return_status);
                    END IF;
                  END IF;
               END IF;
            -- End fix for bug# 4378531

            END IF; -- Line Category not RETURN

	   END IF; -- tax value is different

        -- Check for existing TAX records in OE_PRICE_ADJUSTMENTS table for
	   -- the given line record.

        BEGIN

            l_l_line_adj_tbl.delete; /* initializing l_l_line_adj_tbl */

            OE_Line_Adj_UTIL.Lock_Rows
			    ( p_line_id       => l_line_id,
			      x_line_adj_tbl  => l_l_line_adj_tbl,
				 x_return_status => l_return_status);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                   l_l_line_adj_tbl.delete;
                   x_return_status  := FND_API.G_RET_STS_SUCCESS;
        END;

        IF l_tax_rec_out_tbl.count > 0
        THEN
          IF l_debug_level > 0 THEN
            oe_debug_pub.add('Processing the Tax for the Line '||
					    to_char(l_line_id),2);
          END IF;
            -- If any TAX records exists, mark them for delete

            l_tax_index := 0;
            l_tax_count := 0;


            FOR I IN 1..l_tax_rec_out_tbl.COUNT LOOP

              IF l_tax_rec_out_tbl(I).trx_line_id = l_line_id
              THEN

                   l_tax_rate_id := l_tax_rec_out_tbl(I).tax_rate_id;

             l_match_flag := 'N';
             IF l_l_line_adj_tbl.COUNT > 0 THEN
                FOR J IN 1..l_l_line_adj_tbl.COUNT LOOP
                  IF l_debug_level > 0 THEN
                    oe_debug_pub.add('Price adj Id is '||
		          to_char(l_l_line_adj_tbl(J).price_adjustment_id),2);
                  END IF;
				-- Check if there are existing TAX records in adjustments

	               IF l_l_line_adj_tbl(J).list_line_type_code = 'TAX'  AND
		             l_l_line_adj_tbl(J).parent_adjustment_id IS NULL AND
				   l_l_line_adj_tbl(J).tax_rate_id = l_tax_rate_id AND
				   l_l_line_adj_tbl(J).OPERATION <> OE_GLOBALS.G_OPR_UPDATE
	               THEN
				  -- Set the Match flag
                      l_match_flag := 'Y';
               --Added for bug#1947306.Mark the record to avoid it from getting deleted.
                             l_l_line_adj_tbl(J).OPERATION :=OE_GLOBALS.G_OPR_UPDATE;


				  IF NOT OE_GLOBALS.Equal(
				     l_tax_rec_out_tbl(I).tax_amount,
				     l_l_line_adj_tbl(J).adjusted_amount) OR
				     NOT OE_GLOBALS.Equal(l_tax_rec_out_tbl(I).tax_rate,
					l_l_line_adj_tbl(J).operand) THEN
                       IF l_debug_level > 0 THEN
                         oe_debug_pub.add('Updating the Adj record '||
					   to_char(l_l_line_adj_tbl(J).price_adjustment_id),2);
                       END IF;
				      UPDATE OE_PRICE_ADJUSTMENTS
				      SET ADJUSTED_AMOUNT =
						    l_tax_rec_out_tbl(I).tax_amount,
                               OPERAND = l_tax_rec_out_tbl(I).tax_rate,
                               tax_Rate_id = l_tax_rec_out_tbl(I).tax_rate_id,
						 LAST_UPDATE_DATE  = sysdate,
					      LAST_UPDATED_BY   = FND_GLOBAL.USER_ID,
					      LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID

                          WHERE price_adjustment_id =
						    l_l_line_adj_tbl(J).price_adjustment_id;

                          l_l_line_adj_tbl(J).OPERATION :=
										  OE_GLOBALS.G_OPR_UPDATE;
                          l_match_flag := 'Y';
				  END IF;
                               EXIT;       -- If match found then exit from loop .added for bug#1947306
				END IF;
                 END LOOP;
              END IF;
		    IF l_match_flag = 'N' THEN

			   select OE_PRICE_ADJUSTMENTS_S.nextval
			   INTO l_price_adjustment_id
			   FROM DUAL;

                  l_Line_adj_rec.price_adjustment_id := l_price_adjustment_id;
                  l_Line_adj_rec.header_id := l_header_id;
                  l_Line_adj_rec.last_update_date := SYSDATE;
                  l_Line_adj_rec.last_updated_by := FND_GLOBAL.USER_ID;
                  l_Line_adj_rec.last_update_login := FND_GLOBAL.LOGIN_ID;
                  l_Line_adj_rec.creation_date := SYSDATE;
                  l_Line_adj_rec.created_by := FND_GLOBAL.USER_ID;
                  l_Line_adj_rec.line_id := l_line_id;
                  --l_Line_adj_rec.tax_code := l_tax_rate_code;
                  l_Line_adj_rec.tax_rate_id := l_tax_rec_out_tbl(I).tax_rate_id;
                  IF l_debug_level > 0 THEN
                    oe_debug_pub.add('Inserting the Adj record '||
					   to_char(l_line_adj_rec.price_adjustment_id),2);
                  END IF;
                  l_Line_Adj_rec.operand := l_tax_rec_out_tbl(I).tax_rate;
                  l_Line_Adj_rec.adjusted_amount :=
								l_tax_rec_out_tbl(I).tax_amount;
                  l_Line_Adj_rec.automatic_flag := 'N';
                  l_Line_Adj_rec.list_line_type_code := 'TAX';
                  l_Line_Adj_rec.arithmetic_operator := 'AMT';
                  l_Line_Adj_rec.operation := OE_GLOBALS.g_opr_create;
                  OE_LINE_ADJ_UTIL.INSERT_ROW(p_Line_Adj_rec =>
										  l_line_adj_rec);
		    END IF;

             END IF; -- if l_tax_rec_out_tbl(i).trx_line_id
                     -- = l_line_id

            END LOOP; -- For Tax_Rec_Out_Tbl

        END IF; -- l_tax_rec_out_tbl.count > 0

        -- Delete the old Tax Records from oe_price_adjustments if no match
	   -- is found.

--	   IF l_match_flag = 'N' THEN   --  removed for bug# 1947306
          IF l_l_line_adj_tbl.COUNT > 0 THEN
            FOR J IN 1..l_l_line_adj_tbl.COUNT LOOP

	           IF l_l_line_adj_tbl(J).list_line_type_code = 'TAX'  AND
		         l_l_line_adj_tbl(J).parent_adjustment_id IS NULL AND
			    (l_l_line_adj_tbl(J).operation IS NULL
			  	OR l_l_line_adj_tbl(J).operation = FND_API.G_MISS_CHAR)
	           THEN
                     IF l_debug_level > 0 THEN
                       oe_debug_pub.add('Deleting adj Id '||
		                 to_char(l_l_line_adj_tbl(J).price_adjustment_id),2);
                     END IF;
				DELETE FROM OE_PRICE_ADJUSTMENTS
				WHERE PRICE_ADJUSTMENT_ID =
					l_l_line_adj_tbl(J).price_adjustment_id;
                END IF;

            END LOOP;
	     END IF;
--	   END IF; --  removed for bug# 1947306

     END IF; -- if l_return_status <> 'N'

        l_tax_rec_out_tbl.delete;
        l_l_line_adj_tbl.delete;
   exception --bug 2173168
    when no_data_found then
      IF l_debug_level > 0 THEN
        oe_debug_pub.add('In No data found for line id:'||to_char(l_line_id),2);
      END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   end ; -- bug 2173168
    l_index := p_entity_id_tbl.NEXT(l_index);

   END LOOP; -- l_index IS NOT NULL LOOP

    x_return_status := l_return_status;
    IF l_debug_level > 0 THEN
      v_end := DBMS_UTILITY.GET_TIME;
      oe_debug_pub.add('Time Of execution for Process_Tax '||
        to_char((v_end-v_start)/100),1);
    END IF;
    l_tax_rec_out_tbl.delete;
    l_l_line_adj_tbl.delete;

    OE_MSG_PUB.reset_msg_context('LINE');

  IF l_debug_level > 0 THEN
    oe_debug_pub.add('Exiting Process_Tax ',0.5);   --debug level added for bug13435459
  END IF;
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          l_tax_rec_out_tbl.delete;
          l_l_line_adj_tbl.delete;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
          l_tax_rec_out_tbl.delete;
          l_l_line_adj_tbl.delete;
	  x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN NO_DATA_FOUND THEN
          l_tax_rec_out_tbl.delete;
          l_l_line_adj_tbl.delete;
         IF l_debug_level > 0 THEN
	  oe_debug_pub.add('Tax_Order: In No DATA Found',2);
         END IF;
       x_return_status  := FND_API.G_RET_STS_SUCCESS;

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Tax Header'
	    );
    	END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        l_tax_rec_out_tbl.delete;
        l_l_line_adj_tbl.delete;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Process_Tax;

--Added by Mushenoy for the  auto Internal Requisition Creation (ikon) Aug 22 2001
PROCEDURE auto_create_internal_req
(p_ord_header_id  IN NUMBER
,x_return_status OUT NOCOPY VARCHAR2)

IS
/*
**  PROGRAM LOGIC
**--Query Order Header
**--Query Order Line
**--Derive Values not available on the Internal Sales Order
**--Pass the Internal Sales Order Header values to the internal req header record
**--Pass the Internal Sales Order Line values to the internal req Line table
**--Call the Purchasing API and pass the internal req header record and line tables to Create the Internal Req
**--Check return status of the Purchasing API
**--Update the Internal Sales Order with the Req header id, Req line Ids, Req number and line numbers.
**--Check for return status
**--Handle Exceptions
 */
l_int_req_Ret_sts varchar2(1);
l_req_header_rec PO_CREATE_REQUISITION_SV.Header_rec_Type;
l_req_line_tbl PO_CREATE_REQUISITION_SV.Line_Tbl_Type;
l_created_by number;
l_org_id  number;
l_preparer_id number;
l_destination_org_id number;
l_deliver_to_locn_id number;
l_msg_count      number;
l_msg_data       varchar2(2000);
k number := 0;
j number := 0;

Cursor ord_hdr_cur (p_header_id in number) is
SELECT  created_by
       ,org_id
FROM    OE_ORDER_HEADERS
WHERE   header_id = p_header_id;

Cursor ord_line_cur (p_header_id in number) is
SELECT  line_id
        ,order_quantity_uom
        ,ordered_quantity
        ,sold_to_org_id
        ,inventory_item_id
        ,schedule_ship_date
        ,org_id
        ,ship_from_org_id
        ,subinventory
        ,source_document_id
        ,source_document_line_id
        ,item_type_code
FROM    OE_ORDER_LINES
WHERE   header_id = p_header_id;

CURSOR employee_id_cur(p_user_id in number) IS
SELECT employee_id
FROM fnd_user
WHERE user_id = p_user_id;

CURSOR dest_org_locn_cur (p_cust_id in number) is
SELECT b.location_id,
       b.organization_id
FROM hz_party_sites_V a
    ,PO_LOCATION_ASSOCIATIONS b
WHERE a.party_site_use_id =  b.SITE_USE_ID
and b.customer_id = p_cust_id
and primary_per_type = 'Y'
and site_use_type = 'SHIP_TO';

BEGIN

oe_debug_pub.add(' Entering procedure auto_create_internal_req ',2);
x_return_status := FND_API.G_RET_STS_SUCCESS;
--Query Order Header
OPEN ord_hdr_cur(p_ord_header_id);
FETCH ord_hdr_cur into l_created_by,l_org_id;
CLOSE ord_hdr_cur;
oe_debug_pub.add('auto_create_internal_req after hdr query ',2);
--Derive Values not available on the Internal Sales Order
   --Derive the Preparer_id
    BEGIN
        OPEN employee_id_cur(l_created_by);
        FETCH employee_id_cur into l_preparer_id;
        CLOSE employee_id_cur;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
      	 --This is a required field however PO will handle the error if these Fields are null
        l_preparer_id := null;
        WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

--Pass the Internal Sales Order Header values to the internal req header record
    l_req_header_rec.preparer_id := l_preparer_id;
    l_req_header_rec.summary_flag := 'N';
    l_req_header_rec.enabled_flag := 'Y';
    l_req_header_rec.authorization_status := 'APPROVED';
    l_req_header_rec.type_lookup_code   := 'INTERNAL';
    l_req_header_rec.transferred_to_oe_flag := 'Y';
    l_req_header_rec.org_id      := l_org_id;

--Pass the Internal Sales Order Line values to the internal req Line table
       --Here Loop for each Order Line
     FOR Cur_Ord_line in ord_line_cur(p_ord_header_id)
     LOOP
	j := j+1;
     	IF  cur_ord_line.item_type_code <> OE_GLOBALS.G_ITEM_STANDARD THEN
     	fnd_message.set_name('ONT','ONT_ISO_ITEM_TYPE_NOT_STD');
        OE_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
     	END IF;
    	--get the destination organization id and deliver to location id for this order line
        BEGIN
        OPEN dest_org_locn_cur(cur_Ord_line.sold_to_org_id);
        FETCH dest_org_locn_cur INTO l_deliver_to_locn_id,l_destination_org_id;
        CLOSE dest_org_locn_cur;

        EXCEPTION
	WHEN NO_DATA_FOUND THEN
	--This is a required field however PO will handle the error if these Fields are null
        l_destination_org_id := null;
        l_deliver_to_locn_id := null;
        END;

        l_req_line_tbl(j).line_num                 := j;
        l_req_line_tbl(j).source_doc_line_reference:= Cur_Ord_line.line_id;
	l_req_line_tbl(j).uom_code  := Cur_Ord_line.order_quantity_uom;
  	l_req_line_tbl(j).quantity               := Cur_Ord_line.ordered_quantity;
  	l_req_line_tbl(j).deliver_to_location_id := l_deliver_to_locn_id;
        l_req_line_tbl(j).destination_type_code       := 'INVENTORY';
	l_req_line_tbl(j).destination_organization_id := l_destination_org_id;
        l_req_line_tbl(j).destination_subinventory    := Null;
  	l_req_line_tbl(j).to_person_id           := l_preparer_id;
   	l_req_line_tbl(j).source_type_code       := 'INVENTORY';
   	l_req_line_tbl(j).item_id                := Cur_Ord_line.inventory_item_id;
   	l_req_line_tbl(j).need_by_date           := Cur_Ord_line.schedule_ship_date;
	l_req_line_tbl(j).source_organization_id := Cur_Ord_line.ship_from_org_id;
	l_req_line_tbl(j).source_subinventory    := Cur_Ord_line.subinventory;
   	l_req_line_tbl(j).org_id                 := Cur_Ord_line.org_id;
     END LOOP;
	oe_debug_pub.add(' auto_create_internal_req before PO API call ',2);

--Call the PO API and pass the internal req header record and line tables to Create the Internal Req
	BEGIN /* Call to the Purchasing API*/

	PO_CREATE_REQUISITION_SV.process_requisition(px_header_rec   => l_req_header_rec
        	                                    ,px_line_table   => l_req_line_tbl
                	                            ,x_return_status => l_int_req_Ret_sts
                        	                    ,x_msg_count     => l_msg_count
                                	            ,x_msg_data      => l_msg_data );
--Check return status of the Purchasing API
        IF l_int_req_Ret_sts = FND_API.G_RET_STS_UNEXP_ERROR THEN
        oe_debug_pub.add(' PO API call returned unexpected error '||l_msg_data,2);
 	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_int_req_Ret_sts = FND_API.G_RET_STS_ERROR THEN
        oe_debug_pub.add(' PO API call returned error '||l_msg_data,2);
        RAISE FND_API.G_EXC_ERROR;
	END IF;

   	END;/* Call to the Purchasing API*/

--if it returns success Update the Internal Sales Order with the Req header id and Req line Ids
	IF l_int_req_ret_sts = FND_API.G_RET_STS_SUCCESS THEN

--Update the header with the requisition header id
        Update OE_Order_Headers
        set source_document_Id = l_req_header_rec.requisition_header_id
            ,orig_sys_document_ref = l_req_header_rec.segment1
            ,source_document_type_id = OE_GLOBALS.G_ORDER_SOURCE_INTERNAL -- i.e 10  for internal
            ,order_source_id         = OE_GLOBALS.G_ORDER_SOURCE_INTERNAL --i.e 10 for internal
        Where header_id = p_ord_header_id;
        oe_debug_pub.add('auto_create_internal_req after hdr update ',2);
-- Update  the lines with the requisition header and requisition line ids, requisition number and line number

       FOR k in 1..l_req_line_tbl.count
       LOOP
         IF (l_req_line_tbl(k).requisition_line_id is not null) then
                BEGIN
                Update Oe_Order_lines
                Set    source_document_id = l_req_header_rec.requisition_header_id
                       ,source_document_line_id = l_req_line_tbl(k).requisition_line_id
                       ,source_document_type_id = OE_GLOBALS.G_ORDER_SOURCE_INTERNAL -- i.e 10  for internal
                       ,orig_sys_document_ref=  l_req_header_rec.segment1
                       ,orig_sys_line_ref = l_req_line_tbl(k).line_num
                where oe_order_lines.line_id = l_req_line_tbl(k).source_doc_line_reference;
                END;
         END IF;
       END LOOP;
       oe_debug_pub.add('auto_create_internal_req after line update ',2);
       END IF;
--Handle Exceptions
EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
oe_debug_pub.add('auto_create_internal_req: In Unexpected error',2);

WHEN FND_API.G_EXC_ERROR THEN
x_return_status := FND_API.G_RET_STS_ERROR;
oe_debug_pub.add('auto_create_internal_req: In execution error',2);

--WHEN NO_DATA_FOUND THEN
--x_return_status  := FND_API.G_RET_STS_SUCCESS;
--oe_debug_pub.add('auto_create_internal_req: In No DATA Found',2);

WHEN OTHERS THEN
oe_debug_pub.add('auto_create_internal_req: In Other error',2);
	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
    	OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'auto_create_internal_req');
    	END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END auto_create_internal_req;

-------------------------------------------------------------------
-- Procedure: REVERSE_LIMITS
-- Increments promotional limit balance in response to a cancellation
-- or return against the order or line.
-- Introduced for BUG 2013611
-------------------------------------------------------------------

Procedure Reverse_Limits (p_action_code             IN  VARCHAR2,
                          p_cons_price_request_code IN  VARCHAR2,
                          p_orig_ordered_qty        IN  NUMBER,
                          p_amended_qty             IN  NUMBER,
                          p_ret_price_request_code  IN  VARCHAR2,
                          p_returned_qty            IN  NUMBER,
                          p_line_id                 IN  NUMBER,
x_return_status OUT NOCOPY VARCHAR2)

IS
     l_return_status            VARCHAR2(30);
     l_return_message           VARCHAR2(2000);
     l_orig_ordered_qty         NUMBER;

     --bug#7491829
     l_parent_line_id           NUMBER;
     l_header_id                NUMBER;
     --bug#7491829

     l_cons_price_request_code  OE_ORDER_LINES_ALL.price_request_code%TYPE;
     l_ret_price_request_code  OE_ORDER_LINES_ALL.price_request_code%TYPE;

     CURSOR REFERENCED_LINE is
     SELECT return.price_request_code,
            referenced.pricing_quantity,
            referenced.price_request_code
     FROM   OE_ORDER_LINES_ALL return , OE_ORDER_LINES_ALL referenced
     WHERE  return.line_id = p_line_id
            and referenced.line_id = return.reference_line_id;

     --bug #7491829
     CURSOR SPLIT_LINE IS
     SELECT parent.header_id,
            parent.pricing_quantity,
            parent.line_id
     FROM   OE_ORDER_LINES_ALL child, OE_ORDER_LINES_ALL parent
     WHERE  child.line_id = p_line_id
        and parent.line_id = child.split_from_line_id;
     --bug #7491829

BEGIN

    OE_Debug_PUB.Add('Entering OE_Delayed_Requests_Util.Reverse_Limits', 1);
    OE_Debug_PUB.Add('BOTTOM LEVEL before QP call', 1);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- BUG 2670775 Reverse Limits Begin
    -- If Limits processing is not installed, no need to proceed further
    IF NVL(FND_PROFILE.VALUE('QP_LIMITS_INSTALLED'),'N') = 'N' THEN
       oe_debug_pub.add('QP LIMITS NOT installed so no call to QP_UTIL_PUB.Reverse_Limits',1);
       RETURN;
    END IF;
    -- BUG 2670775 Reverse Limits End

    l_cons_price_request_code := p_cons_price_request_code;
    l_orig_ordered_qty := p_orig_ordered_qty;

    IF p_action_code = 'RETURN' THEN
       -- Retrieve price_request_code for the current return line and the one it references
       OPEN REFERENCED_LINE;
       FETCH  REFERENCED_LINE INTO
              l_ret_price_request_code,l_orig_ordered_qty, l_cons_price_request_code;
       CLOSE REFERENCED_LINE;
    END IF;

   --bug #7491829
    IF p_action_code = 'SPLIT_NEW' THEN
       -- Retrieve price_request_code for the current child split line and its parent
       oe_debug_pub.add('Action code : ' || p_action_code);
       OPEN SPLIT_LINE;
       FETCH SPLIT_LINE INTO
             l_header_id, l_orig_ordered_qty, l_parent_line_id;
       CLOSE SPLIT_LINE;
       oe_Debug_pub.add('l_header_id : ' || l_header_id);
       oe_Debug_pub.add('l_orig_ordered_qty : ' || l_orig_ordered_qty);
       oe_Debug_pub.add('l_parent_line_id : ' || l_parent_line_id);

       l_ret_price_request_code := 'ONT-' || l_header_id || '-' || p_line_id;
       l_cons_price_request_code := 'ONT-' || l_header_id || '-' || l_parent_line_id;
       oe_Debug_pub.add('l_ret_price_request_code : ' || l_ret_price_request_code);
       oe_Debug_pub.add('l_cons_price_request_code : ' || l_cons_price_request_code);
    END IF;
    --bug #7491829

    IF p_action_code = 'RETURN' and l_ret_price_request_code is NULL THEN
       OE_Debug_PUB.Add('NO CALL made to QP_UTIL_PUB.Reverse_Limits ', 1);
       OE_DEBUG_PUB.Add('return price_request_code is null so block limits call', 1);
       RETURN;
    END IF;

    --bug#7491829
    IF p_action_code = 'SPLIT_NEW' and l_ret_price_request_code is NULL THEN
       OE_Debug_PUB.Add('NO CALL made to QP_UTIL_PUB.Reverse_Limits ', 1);
       OE_DEBUG_PUB.Add('split line price_request_code is null so block limits call', 1);
    END IF;
    --bug#7491829

    IF l_cons_price_request_code is NULL THEN
       OE_Debug_PUB.Add('NO CALL made to QP_UTIL_PUB.Reverse_Limits ', 1);
       OE_DEBUG_PUB.Add('consuming price_request_code is null so no limit for reversal', 1);
       RETURN;
    END IF;

    OE_Debug_PUB.Add('Call to QP_UTIL_PUB.Reverse_Limits: action_code is  '||p_action_code, 1);
    OE_Debug_PUB.Add('Call to QP_UTIL_PUB.Reverse_Limits: price_request_code is '||l_cons_price_request_code, 1);
    OE_Debug_PUB.Add('Call to QP_UTIL_PUB.Reverse_Limits: orig_ordered_qty is '||l_orig_ordered_qty, 1);
    OE_Debug_PUB.Add('Call to QP_UTIL_PUB.Reverse_Limits: return request code '||l_ret_price_request_code, 1);
    OE_Debug_PUB.Add('Call to QP_UTIL_PUB.Reverse_Limits: return qty          '||p_returned_qty, 1);

    QP_UTIL_PUB.Reverse_Limits (p_action_code                => p_action_code,
                                p_cons_price_request_code    => l_cons_price_request_code,
                                p_orig_ordered_qty           => l_orig_ordered_qty,
                                p_amended_qty                => p_amended_qty,
                                p_ret_price_request_code     => l_ret_price_request_code,
                                p_returned_qty               => p_returned_qty,
                                x_return_status              => l_return_status,
                                x_return_message             => l_return_message
                               );


    OE_Debug_PUB.Add('QP_UTIL_PUB.Reverse_Limits returns status of '|| l_return_status, 1);
    OE_Debug_PUB.Add('QP_UTIL_PUB.Reverse_Limits returns message of '|| l_return_message   , 1);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      OE_Debug_PUB.Add('Error returned by QP_UTIL_PUB.Reverse_Limits',1);
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
 	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
 	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 	END IF;
    END IF;

   --bug 7491829
    IF p_action_code = 'SPLIT_NEW' THEN
       update oe_order_lines_All
       set price_request_code = l_ret_price_request_code
       where line_id = p_line_id;
    END IF;
    --bug 7491829

    OE_Debug_PUB.Add('Exiting OE_Delayed_Requests_Util.Reverse_Limits with status of '|| x_return_status, 1);

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
            ,   'Reverse_Limits'
            );
        END IF;

END Reverse_Limits;

Procedure Process_XML_Delayed_Request (p_request_ind      IN NUMBER,
                                       x_return_status    OUT NOCOPY VARCHAR2)

IS

l_request_rec            OE_ORDER_PUB.REQUEST_REC_TYPE;
l_header_id  		 NUMBER;
l_order_source_id        NUMBER;
l_orig_sys_document_ref  VARCHAR2(50);
l_sold_to_org_id         NUMBER;
l_change_sequence        VARCHAR2(50);
l_org_id                 NUMBER;
l_acknowledgment_type    VARCHAR2(30);
l_flow_status_code       VARCHAR2(30);
l_party_id               NUMBER;
l_party_site_id          NUMBER;
l_order_number           NUMBER;
l_customer_id            NUMBER;
l_return_status		 VARCHAR2(1);
l_line_found             VARCHAR2(1) := 'N';
l_line_ids               VARCHAR2(2000);
l_count                  NUMBER;
l_count_old              NUMBER;
l_itemkey                NUMBER;
l_bulk_line_rec          OE_WSH_BULK_GRP.LINE_REC_TYPE;
i                        PLS_INTEGER := 1;
ctr                      NUMBER;
l_reciever_code          VARCHAR2(1);
l_line_id_tbl            Line_ID_List;
Raise_Event_XML          BOOLEAN := FALSE;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

Begin


l_request_rec := OE_Delayed_Requests_PVT.G_Delayed_Requests(p_request_ind);
l_header_id  		 := l_request_rec.entity_id;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'retrieving key information from base table') ;
      END IF;


SELECT order_source_id, orig_sys_document_ref, sold_to_org_id, change_sequence
INTO l_order_source_id, l_orig_sys_document_ref, l_sold_to_org_id, l_change_sequence
FROM oe_order_headers
WHERE header_id=l_header_id;

/* to fix issue in bug 3478862, now retrieve key information from base table
l_order_source_id        := to_number(l_request_rec.param2);
l_orig_sys_document_ref  := l_request_rec.param3;
l_sold_to_org_id         := to_number(l_request_rec.param4);
l_change_sequence        := l_request_rec.param5;
*/

l_org_id                 := to_number(l_request_rec.param6);
l_acknowledgment_type    := l_request_rec.param7;
l_flow_status_code       := l_request_rec.param8;
l_party_id               := to_number(l_request_rec.param9);
l_party_site_id          := to_number(l_request_rec.param10);
l_customer_id            := to_number(l_request_rec.param11);
l_reciever_code          := l_request_rec.param12;
l_order_number           := to_number(l_request_rec.param13);


      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'l_reciever_code before:' || l_reciever_code ) ;
      END IF;


IF l_reciever_code = FND_API.G_MISS_CHAR OR
   l_reciever_code IS NULL THEN
    l_reciever_code := 'C';
END IF;

-- l_reciever_code has 3 valid values:
-- C => 'generate customer acknowledgment'
-- P => 'raise product-level integration event'
-- B => do both
-- interpret a  passed for acknowledgment_type as signaling a product-level raise event

IF l_acknowledgment_type IS NULL THEN
l_reciever_code           := 'P';
END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'l_reciever_code after:' || l_reciever_code ) ;
      END IF;

   IF l_request_rec.param1 IS NULL THEN
   -- header level request that should acknowledge all lines
   IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RAISING HEADER-LEVEL EVENT TO ACK ALL LINES') ;
   END IF;


 IF l_reciever_code IN ('C', 'B') THEN
  IF l_acknowledgment_type in (OE_ACKNOWLEDGMENT_PUB.G_TRANSACTION_SSO, OE_ACKNOWLEDGMENT_PUB.G_TRANSACTION_CSO) THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SSO or CSO request' ) ;
      END IF;
    OE_Acknowledgment_Pub.Raise_Event_Showso
          (
           p_header_id              => l_header_id,
           p_line_id                => Null,
           p_customer_id            => l_sold_to_org_id,
           p_orig_sys_document_ref  => l_orig_sys_document_ref,
	   p_change_sequence        => l_change_sequence,
           p_itemtype               => OE_ORDER_IMPORT_WF.G_WFI_CONC_PGM,
           p_party_id               => l_party_id,
           p_party_site_id          => l_party_site_id,
           p_transaction_type       => l_acknowledgment_type,
           p_commit_flag            => 'N',
           x_return_status          => l_return_status
          );

  ELSIF l_acknowledgment_type = OE_ACKNOWLEDGMENT_PUB.G_TRANSACTION_POI THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  '3A4 ACK request' ) ;
      END IF;
     Oe_Acknowledgment_Pub.Raise_Event_From_Oeoi(
        p_transaction_type       =>  l_acknowledgment_type,
        p_orig_sys_document_ref  =>  l_orig_sys_document_ref,
        p_request_id             =>  null,
        p_order_imported         =>  'Y',
        p_sold_to_org_id         =>  l_sold_to_org_id,
        p_change_sequence        =>  l_change_sequence,
        p_org_id                 =>  l_org_id,
        p_check_for_delivery     =>  'N',
        x_return_status          =>  l_return_status);


   END IF;
  END IF;



  IF l_reciever_code IN ('P', 'B') THEN
   -- raise integration event
     IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RAISING INTEGRATION EVENT' ) ;
      END IF;
  OE_Acknowledgment_Pub.Raise_Event_XMLInt (
             p_order_source_id        =>  l_order_source_id,
             p_partner_document_num   =>  l_orig_sys_document_ref,
             p_sold_to_org_id         =>  l_sold_to_org_id,
	     p_itemtype               =>  NULL,
             p_itemkey                =>  NULL,
	     p_transaction_type       =>  NULL,
             p_message_text           =>  NULL,
             p_document_num           =>  l_order_number,
             p_change_sequence        =>  l_change_sequence,
             p_org_id                 =>  l_org_id,
             p_header_id              =>  l_header_id,
             p_subscriber_list        =>  'DEFAULT',
             p_line_ids               =>  'ALL',
             x_return_status          =>  l_return_status);

   END IF;


   ELSE       --do seeding of acknowledgment tables for passed header and line information


  IF l_reciever_code IN ('C', 'B') THEN  --start of check for customer ack request
      select OE_XML_MESSAGE_SEQ_S.nextval
      into l_itemkey
      from dual;

      IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'sequence value:  ' || l_itemkey) ;
      end if;


--insert provided header information into table
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SEEDEDING HEADER_ID FOR ACKNOWLEDGMENT => ' || l_header_id ) ;
      END IF;


   Insert Into OE_HEADER_ACKS (header_id, acknowledgment_type, last_ack_code, request_id, sold_to_org_id, change_sequence)
   Values (l_header_id, l_acknowledgment_type, l_flow_status_code, l_itemkey,
           l_sold_to_org_id, l_change_sequence);

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER HEADER INSERT') ;
      END IF;
 END IF;  -- end of check for customer ack request


   l_count := OE_Delayed_Requests_PVT.G_Delayed_Requests.first;

--find and insert lines for that header
   WHILE l_count IS NOT NULL LOOP

   --Check to see if this is a line-level xml request for the same transaction type and header id
     IF OE_Delayed_Requests_PVT.G_Delayed_Requests(l_count).request_type = OE_GLOBALS.G_GENERATE_XML_REQ_LN
        AND OE_Delayed_Requests_PVT.G_Delayed_Requests(l_count).param1 = l_header_id
        AND nvl(OE_Delayed_Requests_PVT.G_Delayed_Requests(l_count).param7, 'INT') = nvl(l_acknowledgment_type, 'INT') THEN

   -- add this line to the lines table for insertion
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LINE_ID FOR ACKNOWLEDGMENT => ' || OE_Delayed_Requests_PVT.G_Delayed_Requests(l_count).entity_id ) ;
      END IF;

      If l_line_found = 'N' then
      --set flag to show that a line has been found
      l_line_found := 'Y';
      End If;

      --extend the length of elements in the nested tables

    IF l_reciever_code IN ('C', 'B') THEN

      l_bulk_line_rec.header_id.extend;
      l_bulk_line_rec.line_id.extend;
      l_bulk_line_rec.xml_transaction_type_code.extend;
      l_bulk_line_rec.last_ack_code.extend;
      l_bulk_line_rec.request_id.extend;
      l_bulk_line_rec.sold_to_org_id.extend;
      l_bulk_line_rec.change_sequence.extend;

      l_bulk_line_rec.header_id(i) := l_header_id;
      l_bulk_line_rec.line_id(i) := OE_Delayed_Requests_PVT.G_Delayed_Requests(l_count).entity_id;
      l_bulk_line_rec.xml_transaction_type_code(i) := l_acknowledgment_type;
      l_bulk_line_rec.last_ack_code(i) := OE_Delayed_Requests_PVT.G_Delayed_Requests(l_count).param8;
      l_bulk_line_rec.request_id(i) := l_itemkey;
      l_bulk_line_rec.sold_to_org_id(i) := to_number(OE_Delayed_Requests_PVT.G_Delayed_Requests(l_count).param4);
      l_bulk_line_rec.change_sequence(i) :=OE_Delayed_Requests_PVT. G_Delayed_Requests(l_count).param5;

      IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'after assignment to bulk record') ;
      end if;

    END IF;

    IF l_reciever_code IN ('P', 'B') THEN
       -- 5738023
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Assigning entity id to line table', 3);
      END IF;
     l_line_id_tbl(i).line_id := OE_Delayed_Requests_PVT.G_Delayed_Requests(l_count).entity_id;
    END IF;

      i := i + 1;


      l_count_old := l_count;
      l_count := OE_Delayed_Requests_PVT.G_Delayed_Requests.Next(l_count);

      -- Processing has been done, so delete line-level request now
      OE_Delayed_Requests_PVT.G_Delayed_Requests.Delete(l_count_old);

      ELSE
      l_count := OE_Delayed_Requests_PVT.G_Delayed_Requests.Next(l_count);
      END IF;

   END LOOP;

  IF l_reciever_code IN ('C', 'B') THEN
   IF l_line_found = 'Y' THEN
   --only do line insert if lines were found

   --bulk insert the lines into the lines table
   ctr := l_bulk_line_rec.line_id.count;


    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'LINE COUNT:' || ctr) ;
       oe_debug_pub.add(  'BEFORE BULK INSERT OF LINES') ;
   END IF;

   FORALL j IN 1..ctr
        INSERT INTO OE_LINE_ACKS
            (header_id
            ,line_id
            ,acknowledgment_type
            ,last_ack_code
            ,request_id
            ,sold_to_org_id
            ,change_sequence)
        VALUES
            (l_bulk_line_rec.header_id(j)
            ,l_bulk_line_rec.line_id(j)
            ,l_acknowledgment_type
            ,l_bulk_line_rec.last_ack_code(j)
            ,l_bulk_line_rec.request_id(j)
            ,l_bulk_line_rec.sold_to_org_id(j)
            ,l_bulk_line_rec.change_sequence(j)
            );

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'AFTER BULK INSERT OF LINES') ;
   END IF;

  END IF;  --end of l_line_found conditional
END IF;

   IF l_reciever_code IN ('C', 'B') THEN
     IF l_acknowledgment_type IN (OE_ACKNOWLEDGMENT_PUB.G_TRANSACTION_SSO, OE_ACKNOWLEDGMENT_PUB.G_TRANSACTION_CSO) THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SSO or CSO request' ) ;
      END IF;

       OE_Acknowledgment_Pub.Raise_Event_Showso
          (
           p_header_id              => l_header_id,
           p_line_id                => Null,
           p_customer_id            => l_sold_to_org_id,
           p_orig_sys_document_ref  => l_orig_sys_document_ref,
	   p_change_sequence        => l_change_sequence,
           p_itemtype               => Null,
           p_itemkey                => l_itemkey,
           p_party_id                => l_party_id,
           p_party_site_id           => l_party_site_id,
           p_transaction_type       => l_acknowledgment_type,
           x_return_status          => l_return_status
          );


   ELSIF l_acknowledgment_type = OE_ACKNOWLEDGMENT_PUB.G_TRANSACTION_POI THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  '3A4 ACK request' ) ;
      END IF;
     Oe_Acknowledgment_Pub.Raise_Event_From_Oeoi(
        p_transaction_type       =>  l_acknowledgment_type,
        p_orig_sys_document_ref  =>  l_orig_sys_document_ref,
        p_request_id             =>  null,
        p_order_imported         =>  'Y',
        p_sold_to_org_id         =>  l_sold_to_org_id,
        p_change_sequence        =>  l_change_sequence,
        p_org_id                 =>  l_org_id,
        p_start_from_flow        =>  OE_ORDER_IMPORT_WF.G_WFI_PROC,
        p_check_for_delivery     =>  'N',
        x_return_status          =>  l_return_status);

   END IF;

END IF;


 IF l_reciever_code IN ('P', 'B') THEN
   IF l_line_id_tbl.COUNT > 0 THEN  --5939693
 --    FOR I IN  l_line_id_tbl.FIRST..l_line_id_tbl.LAST  LOOP Commented for bug 5939693
    i := l_line_id_tbl.FIRST;
     WHILE i IS NOT NULL LOOP
        IF ((length(l_line_ids) + 2 * length(l_line_id_tbl(i).line_id)) > 2000 ) THEN
            Raise_Event_XML := TRUE;
        ELSE
         IF l_line_ids IS NULL THEN
            l_line_ids := l_line_id_tbl(i).line_id;
         ELSE
            l_line_ids := l_line_ids || ':' ||  l_line_id_tbl(i).line_id;
         END IF;
             IF I = l_line_id_tbl.LAST THEN
                Raise_Event_XML := TRUE;
             END IF;
       END IF;
  IF Raise_Event_XML THEN
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'Raising Event with line id '|| l_line_id_tbl(i).line_id, 3);
        oe_debug_pub.add(  'Line_ids:' || l_line_ids, 3);
     END IF;

   -- raise integration event
    OE_Acknowledgment_Pub.Raise_Event_XMLInt (
             p_order_source_id        =>  l_order_source_id,
             p_partner_document_num   =>  l_orig_sys_document_ref,
             p_sold_to_org_id         =>  l_sold_to_org_id,
	     p_itemtype               =>  NULL,
             p_itemkey                =>  NULL,
	     p_transaction_type       =>  NULL,
             p_message_text           =>  NULL,
             p_document_num           =>  l_order_number,
             p_change_sequence        =>  l_change_sequence,
             p_org_id                 =>  l_org_id,
             p_header_id              =>  l_header_id,
             p_subscriber_list        =>  'DEFAULT',
             p_line_ids               =>  l_line_ids,
             x_return_status          =>  l_return_status);


      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'line ids: ' || l_line_ids ) ;
      END IF;
         l_line_ids := NULL;
         Raise_Event_XML := FALSE;

   END IF;
   i:=l_line_id_tbl.NEXT(i);
 END LOOP;

-- Added for bug #6726949
/* Below code is needed for this new regression bug
   ------------------------------------------------ */
ELSE -- l_line_id_tbl.COUNT is 0
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(' Raising XML Event for Order Header');
    END IF;
    l_line_ids := NULL;
    OE_Acknowledgment_Pub.Raise_Event_XMLInt (
             p_order_source_id        =>  l_order_source_id,
             p_partner_document_num   =>  l_orig_sys_document_ref,
             p_sold_to_org_id         =>  l_sold_to_org_id,
             p_itemtype               =>  NULL,
             p_itemkey                =>  NULL,
             p_transaction_type       =>  NULL,
             p_message_text           =>  NULL,
             p_document_num           =>  l_order_number,
             p_change_sequence        =>  l_change_sequence,
             p_org_id                 =>  l_org_id,
             p_header_id              =>  l_header_id,
             p_subscriber_list        =>  'DEFAULT',
             p_line_ids               =>  l_line_ids,
             x_return_status          =>  l_return_status);
/* Changes Ends for this new regression bug
   ---------------------------------------- */

 END IF;
 END IF;
END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF l_debug_level  > 0 THEN
      OE_Debug_PUB.Add('ERROR RETURNED BY RAISE_EVENT FOR: ' || l_acknowledgment_type);
      END IF;
    END IF;


     x_return_status := l_return_status;






Exception
When others then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'IN OTHERS EXCEPTION:' || SQLERRM) ;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
End Process_XML_Delayed_Request;


/* 7576948: IR ISO Change Management project Start */
/*
Procedure Name : Update_Requisition_Info
Input Params   : P_Header_id - Primary key of the order header
                 P_Line_id - Primary key of the order line. This parameter
                             will be null for order header cancellation
                 P_Requisition_Header_id - Primary key of the requisition
                                           header
                 P_Requisition_Line_id - Primary key of the requisition line
                 p_Line_ids - String variable containing line_ids delimited
                              by comma ?Q,?R. Will be populated only if it is
                              a partial order cancellation
                 p_num_records - Number of total order line records cancelled
                                 while processing partial order cancellation
                 P_Quantity_Change - It will denote net change in order quantity
                                     with respective single requisition line.
                                     If it is greater than 0 then it is an
                                     increment in the quantity, while if it is
                                     less than 0 then it is a decrement in the
                                     ordered quantity. If it is 0 then it
                                     indicates there is no change in ordered
                                     quantity value
                 P_New_Schedule_Ship_Date - It will denote the change in
                                            Schedule Ship Date
                 P_Cancel_Order - It will denote whether internal sales order
                                  is cancelled or not. If it is cancelled then
                                  respective Purchasing api will be called to
                                  trigger the requisition header cancellation.
Output Params  : X_Return_Status - The return status of the API
                                   (Expected/Unexpected/Success)
Brief Description : This program unit is added for IR ISO Change
                    management project, so as to trigger the new
                    program unit OE_Process_Requisition_Pvt.Updat
                    e_Internal_Requisition introduced as part of
                    this project, and responsible for calling several
                    Purchasing APIs based on the action performed
                    on the internal sales order header/line.

                    Possible actions can be:
                       Header Level FULL Cancellation
                       Header Level PARTIAL Cancellation
                       Line Level Cancellation
                       Line Ordered Quantity update
                       Line Schedule Ship/Arrival Date update
                       Line Ordered Quantity and Schedule Ship/Arrival
                       Date update

-- For details on IR ISO CMS project, please refer to FOL >
-- OM Development > OM GM > 12.1.1 > TDD > IR_ISO_CMS_TDD.doc
*/

Procedure Update_Requisition_Info -- Package Body
( p_header_id              IN NUMBER    -- Param5 or Entity id
, p_line_id                IN NUMBER   -- Entity id
, P_Line_ids               IN VARCHAR2 -- Long_Param1
, P_num_records            IN NUMBER   -- Param6
, P_Requisition_Header_id  IN NUMBER    -- Param3
, P_Requisition_Line_id    IN NUMBER DEFAULT NULL   -- Param4
, P_Quantity_Change        IN NUMBER DEFAULT NULL   -- Param1
, P_Quantity2_Change       IN NUMBER DEFAULT NULL --Bug 14211120
, P_New_Schedule_Ship_Date IN DATE -- Date_Param1
, P_Cancel_order           IN BOOLEAN -- Param2
, x_return_status OUT NOCOPY varchar2
)
IS
--
l_return_status       VARCHAR2(30);
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(2000);
l_new_ord_quantity    NUMBER;
l_cancel_line         BOOLEAN := FALSE;
l_New_Schedule_Ship_Date DATE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level > 0 THEN
    oe_debug_pub.ADD('Entering delayed request utility for Update_Requisition_Info',1);
    oe_debug_pub.ADD(' Header id '||p_header_id,5);
    oe_debug_pub.ADD(' Line id '||p_line_id,5);
    oe_debug_pub.ADD(' Number of shipment Lines updated '||p_num_records,5);
    oe_debug_pub.ADD(' Req Header id '||p_requisition_header_id,5);
    oe_debug_pub.ADD(' Req Line id '||p_requisition_line_id,5);
    oe_debug_pub.ADD(' Quantity Change '||p_quantity_change,5);
    oe_debug_pub.ADD(' New Schedule Ship Date '||p_new_schedule_ship_date,5);
    IF p_cancel_order THEN
      oe_debug_pub.ADD(' Order Level Cancellation',5);
   ELSE
      oe_debug_pub.ADD(' Not an Order Level Cancellation',5);
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_New_Schedule_Ship_Date := p_New_Schedule_Ship_Date;

  IF NOT p_Cancel_Order THEN
    IF p_line_id IS NULL THEN
      IF l_debug_level > 0 THEN
        oe_debug_pub.add(' Invalid processing since Line_id is null for non-order header cancellation',1);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    Begin
      select nvl(ordered_quantity,0)
      into   l_new_ord_quantity
      from   oe_order_lines_all
      where  line_id = p_line_id;
    End;
    IF l_new_ord_quantity = 0 THEN
      IF l_debug_level > 0 THEN
       oe_debug_pub.ADD(' Line is cancelled, cancel the Requisition Line',5);
      END IF;
      l_cancel_line := TRUE;
    END IF;
  END IF; -- Not P_Cancel_Order

  OE_Process_Requisition_Pvt.Update_Internal_Requisition
  ( P_Header_id               => p_header_id
  , P_Line_id                 => p_line_id
  , p_line_ids                => p_line_ids
  , p_num_records             => p_num_records
  , P_Req_Header_id           => P_Requisition_Header_id
  , P_Req_Line_id             => P_Requisition_Line_id
  , P_Quantity_Change         => P_Quantity_Change
  , P_Quantity2_Change        => P_Quantity2_Change --Bug 14211120
  , P_New_Schedule_Ship_Date  => l_New_Schedule_Ship_Date
  , P_Cancel_Order            => P_Cancel_order
  , P_Cancel_line             => l_cancel_line
  , X_msg_count               => l_msg_count
  , X_msg_data                => l_msg_data
  , X_return_status           => l_return_status
  );

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  X_return_status := l_return_status;

  IF l_debug_level > 0 THEN
    oe_debug_pub.ADD('Exiting delayed request utility for Update_Requisition_Info',1);
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Update_Requisition_Info'
      );
    END IF;
END Update_Requisition_Info;


/* ============================= */
/* IR ISO Change Management Ends */


-- This new procedure is added for DOO Pre Exploded Kit ER 9339742
PROCEDURE Process_Pre_Exploded_Kits
( p_top_model_line_id IN         NUMBER
, p_explosion_date    IN         DATE
, x_return_status     OUT NOCOPY VARCHAR2
) IS
--
l_return_status VARCHAR2(30);
--
l_debug_level   CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add(' Entering OE_Delayed_Requests_Util.Process_Pre_Exploded_Kits',1);
    oe_debug_pub.add(' Top Model Line_id is : '||p_top_model_line_id,5);
    oe_debug_pub.add(' Explosion Date is : '||p_explosion_date,5);
  end if;

  OE_Config_Util.Process_Pre_Exploded_Kits
  ( p_top_model_line_id => p_top_model_line_id
  , p_explosion_date    => p_explosion_date
  , x_return_status     => l_return_status);

  x_return_status := l_return_status;

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  if l_debug_level > 0 then
    oe_debug_pub.add(' Exiting OE_Delayed_Requests_Util.Process_Pre_Exploded_Kits',1);
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Process_Pre_Exploded_Kits'
      );
    END IF;
END Process_Pre_Exploded_Kits;
-- End DOO Pre Exploded Kit ER 9339742

END OE_Delayed_Requests_UTIL;

/
