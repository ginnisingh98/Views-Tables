--------------------------------------------------------
--  DDL for Package Body OE_TOTALS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_TOTALS_GRP" AS
/* $Header: OEXGTOTB.pls 120.2 2005/10/26 17:39:07 lkxu noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Totals_GRP';


--  Start of Comments
--  API name    Get_Order_Total
--  Type        Group
--  Function: The API to return Order/Line totals for (Line amount/Tax /Charges)
--  For Order level total, the Header_id should be passed in and Line_id
--  should be null. For line level totals, both should be passed in with values.
--
--  Pre-reqs
--
--  Parameters
--              p_header_id                     IN  NUMBER
--              p_line_id                       IN  NUMBER
--              p_total_type                    IN  NUMBER possible values are
--                                      ('ALL','LINES','CHARGES','TAXES')
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

FUNCTION Get_Order_Total
(   p_header_id                     IN  NUMBER
,   p_line_id                       IN  NUMBER
,   p_total_type                    IN  VARCHAR2 := 'ALL'
) RETURN NUMBER
IS
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Order_Total';
l_return_status               VARCHAR2(1);
l_charge_amount               NUMBER := 0;
l_line_amount                 NUMBER := 0;
l_tax_amount                  NUMBER := 0;
l_msg_count                   NUMBER;
l_msg_data                    VARCHAR2(240);

BEGIN

    IF p_header_id is NULL OR p_header_id = FND_API.G_MISS_NUM THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_CONFIG_PARAMETER_REQUIRED');
            FND_MESSAGE.SET_TOKEN('PARAMETER','Header_Id');
            OE_MSG_PUB.Add;

        END IF;
        RAISE FND_API.G_EXC_ERROR;

    END IF;

    IF p_total_type is NULL OR p_total_type = FND_API.G_MISS_CHAR THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_CONFIG_PARAMETER_REQUIRED');
            FND_MESSAGE.SET_TOKEN('PARAMETER','Total_Type');
            OE_MSG_PUB.Add;

        END IF;
        RAISE FND_API.G_EXC_ERROR;

    END IF;

    -- For Order Level Totals
    IF p_line_id IS NULL OR p_line_id = FND_API.G_MISS_NUM THEN

        OE_OE_TOTALS_SUMMARY.GLOBAL_TOTALS(p_header_id);
        IF p_total_type = 'ALL' THEN

            RETURN(OE_OE_TOTALS_SUMMARY.ORDER_SUBTOTALS( p_header_id ) +
                          OE_OE_TOTALS_SUMMARY.Charges ( p_header_id ) +
                          OE_OE_TOTALS_SUMMARY.Taxes ( p_header_id ));

        ELSIF p_total_type = 'LINES' THEN

            RETURN(OE_OE_TOTALS_SUMMARY.ORDER_SUBTOTALS( p_header_id ));

        ELSIF p_total_type = 'TAXES' THEN

            RETURN(OE_OE_TOTALS_SUMMARY.Taxes ( p_header_id ));

        ELSIF p_total_type = 'CHARGES' THEN

            RETURN(OE_OE_TOTALS_SUMMARY.Charges ( p_header_id ));
        ELSE

		  RETURN 0;
        END IF;

    ELSE -- For Line level totals
    BEGIN -- Bug#3277021
        IF p_total_type IN ('ALL','LINES','TAXES') THEN
            SELECT DECODE(line_category_code,'RETURN',-1,1)*
                   NVL(unit_selling_price,0)*
                   NVL(Ordered_Quantity,0),
                   DECODE(line_category_code,'RETURN',-1,1)*
                   NVL(tax_value,0)
            INTO   l_line_amount,
                   l_tax_amount
            FROM   oe_order_lines_all
            WHERE  line_id = p_line_id
            AND    NVL(cancelled_flag,'N')='N';
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_line_amount := 0;
            l_tax_amount  := 0;
    END;
        IF p_total_type IN ('CHARGES','ALL')  THEN
            OE_CHARGE_PVT.GET_CHARGE_AMOUNT(
                         p_api_version_number => 1.0
                       , p_header_id => p_header_id
                       , p_line_id => p_line_id
                       , p_all_charges => FND_API.G_FALSE
                       , x_return_status => l_return_status
                       , x_msg_count => l_msg_count
                       , x_msg_data => l_msg_data
                       , x_charge_amount => l_charge_amount
                      );
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

        END IF;
        IF p_total_type = 'ALL' THEN
            RETURN (l_line_amount + l_tax_amount + l_charge_amount);
        ELSIF p_total_type = 'LINES' THEN
            return l_line_amount;
        ELSIF p_total_type = 'TAXES' THEN
            return l_tax_amount;
        ELSIF p_total_type = 'CHARGES' THEN
            return l_charge_amount;
        ELSE
            return 0;
        END IF;

    END IF;
EXCEPTION

    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Order_Total;

FUNCTION Get_Rec_Order_Total
(   p_header_id                     IN  NUMBER
,   p_line_id                       IN  NUMBER
,   p_charge_periodicity_code       IN  VARCHAR2
,   p_total_type                    IN  VARCHAR2 := 'ALL'
) RETURN NUMBER
IS
l_return_status               VARCHAR2(1);
l_charge_amount               NUMBER := 0;
l_line_amount                 NUMBER := 0;
l_tax_amount                  NUMBER := 0;
l_msg_count                   NUMBER;
l_msg_data                    VARCHAR2(240);

BEGIN

    IF p_header_id is NULL OR p_header_id = FND_API.G_MISS_NUM THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_CONFIG_PARAMETER_REQUIRED');
            FND_MESSAGE.SET_TOKEN('PARAMETER','Header_Id');
            OE_MSG_PUB.Add;

        END IF;
        RAISE FND_API.G_EXC_ERROR;

    END IF;

    IF p_total_type is NULL OR p_total_type = FND_API.G_MISS_CHAR THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_CONFIG_PARAMETER_REQUIRED');
            FND_MESSAGE.SET_TOKEN('PARAMETER','Total_Type');
            OE_MSG_PUB.Add;

        END IF;
        RAISE FND_API.G_EXC_ERROR;

    END IF;

    -- For Order Level Totals
    IF p_line_id IS NULL OR p_line_id = FND_API.G_MISS_NUM THEN

        OE_OE_TOTALS_SUMMARY.GLOBAL_REC_TOTALS(p_header_id,p_charge_periodicity_code);
        IF p_total_type = 'ALL' THEN

            RETURN(OE_OE_TOTALS_SUMMARY.REC_ORDER_SUBTOTALS( p_header_id ) +
                          OE_OE_TOTALS_SUMMARY.REC_Charges ( p_header_id,p_charge_periodicity_code ) +
                          OE_OE_TOTALS_SUMMARY.REC_Taxes ( p_header_id ));

        ELSIF p_total_type = 'LINES' THEN

            RETURN(OE_OE_TOTALS_SUMMARY.REC_ORDER_SUBTOTALS( p_header_id ));

        ELSIF p_total_type = 'TAXES' THEN

            RETURN(OE_OE_TOTALS_SUMMARY.REC_Taxes ( p_header_id ));

        ELSIF p_total_type = 'CHARGES' THEN

            RETURN(OE_OE_TOTALS_SUMMARY.REC_Charges ( p_header_id,p_charge_periodicity_code ));
        ELSE

		  RETURN 0;
        END IF;

    ELSE -- For Line level totals
    BEGIN -- Bug#3277021
        IF p_total_type IN ('ALL','LINES','TAXES') THEN
            SELECT DECODE(line_category_code,'RETURN',-1,1)*
                   NVL(unit_selling_price,0)*
                   NVL(Ordered_Quantity,0),
                   DECODE(line_category_code,'RETURN',-1,1)*
                   NVL(tax_value,0)
            INTO   l_line_amount,
                   l_tax_amount
            FROM   oe_order_lines_all
            WHERE  line_id = p_line_id
            AND    NVL(cancelled_flag,'N')='N';
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_line_amount := 0;
            l_tax_amount  := 0;
    END;
        IF p_total_type IN ('CHARGES','ALL')  THEN
            OE_CHARGE_PVT.GET_CHARGE_AMOUNT(
                         p_api_version_number => 1.0
                       , p_header_id => p_header_id
                       , p_line_id => p_line_id
                       , p_all_charges => FND_API.G_FALSE
                       , x_return_status => l_return_status
                       , x_msg_count => l_msg_count
                       , x_msg_data => l_msg_data
                       , x_charge_amount => l_charge_amount
                      );
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

        END IF;
        IF p_total_type = 'ALL' THEN
            RETURN (l_line_amount + l_tax_amount + l_charge_amount);
        ELSIF p_total_type = 'LINES' THEN
            return l_line_amount;
        ELSIF p_total_type = 'TAXES' THEN
            return l_tax_amount;
        ELSIF p_total_type = 'CHARGES' THEN
            return l_charge_amount;
        ELSE
            return 0;
        END IF;

    END IF;
EXCEPTION

    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Rec_Order_Total;

PROCEDURE GET_RECURRING_TOTALS
(
p_header_id       IN  NUMBER,
x_rec_charges_tbl  IN OUT NOCOPY OE_OE_TOTALS_SUMMARY.Rec_Charges_Tbl_Type)
IS
 BEGIN
     OE_OE_TOTALS_SUMMARY.GET_RECURRING_TOTALS(
        p_header_id=>p_header_id,
        x_rec_charges_tbl=>x_rec_charges_tbl
        );
  EXCEPTION

    WHEN OTHERS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

 END GET_RECURRING_TOTALS;

--Pay Now Pay Later project
--group API which returns the pay now portion of an order or an order line. The pay now portion is broken up into subtotal, tax, charges and pay now total.
--Either line_id or header_id needs to be passed to the api
--p_total_type could take any of the values 'ALL', 'LINES', 'TAXES' or 'CHARGES'.
--Default value of p_total_type is NULL to avoid GCSS warnings. NULL would be treated as 'ALL'.
FUNCTION Get_PayNow_Total
( p_header_id    IN  NUMBER
, p_line_id      IN  NUMBER
, p_total_type   IN  VARCHAR2 := NULL
) RETURN NUMBER
IS
CURSOR lines_cur(p_header_id IN NUMBER) IS
SELECT 	 line_id
       , payment_term_id
FROM	 oe_order_lines_all
WHERE	 header_id = p_header_id;

l_api_name                      CONSTANT VARCHAR2(30):= 'Get_PayNow_Total';
l_pay_now_total_detail_tbl      AR_VIEW_TERM_GRP.amounts_table;
l_pay_now_total_summary_rec	AR_VIEW_TERM_GRP.summary_amounts_rec;
l_line_tbl                      oe_order_pub.line_tbl_type;
i                               pls_integer;
l_line_id			NUMBER;
l_header_id			NUMBER;
l_currency_code			VARCHAR2(15);
l_msg_count          		NUMBER := 0 ;
l_msg_data           		VARCHAR2(2000) := NULL ;
l_return_status      		VARCHAR2(30) := NULL ;
l_org_id			NUMBER;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('ENTERING OE_TOTALS_GRP.GET_PAYNOW_TOTAL');
   END IF;
   l_return_status := FND_API.G_RET_STS_SUCCESS;


   IF (p_header_id is NULL OR p_header_id = FND_API.G_MISS_NUM) AND
      (p_line_id is NULL OR p_line_id = FND_API.G_MISS_NUM) THEN
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add('Both header_id and line_id are either null or FND_API.G_MISS_NUM... Returning from the function');
      END IF;
      RETURN 0;
   END IF;

   IF p_header_id IS NOT NULL AND p_header_id <> FND_API.G_MISS_NUM THEN
     OE_Order_Cache.load_order_header(p_header_id);
     l_org_id := OE_Order_Cache.g_header_rec.org_id;

   ELSE
     BEGIN
       SELECT org_id
       INTO   l_org_id
       FROM   oe_order_lines_all
       WHERE  line_id = p_line_id;
     EXCEPTION WHEN NO_DATA_FOUND THEN
       null;
     END;
   END IF;


   IF OE_Prepayment_Util.Get_Installment_Options(l_org_id)
      <> 'ENABLE_PAY_NOW' THEN
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add('Installment Options is not ENABLE_PAY_NOW... Returning from the function');
      END IF;
      RETURN 0;
   END IF;

   IF p_line_id IS NOT NULL AND
      p_line_id <> FND_API.G_MISS_NUM THEN
      -- this is for line payment
      SELECT line_id
	    ,header_id
	    ,payment_term_id
      INTO   l_line_tbl(1).line_id
	    ,l_line_tbl(1).header_id
	    ,l_line_tbl(1).payment_term_id
      FROM   oe_order_lines_all
      WHERE  line_id=p_line_id;
   ELSE
      -- this is for header payment
      i := 1;
      FOR c_line_rec in lines_cur(p_header_id) LOOP
	 l_line_tbl(i).header_id := p_header_id;
	 l_line_tbl(i).line_id := c_line_rec.line_id;
	 l_line_tbl(i).payment_term_id := c_line_rec.payment_term_id;
	 i := i + 1;
      END LOOP;

   END IF;

   -- populate information to pl/sql table in order to call API to get Pay Now portion
   i := l_line_tbl.First;
   OE_Order_Cache.load_order_header(l_line_tbl(i).header_id);
   l_currency_code := OE_Order_Cache.g_header_rec.transactional_curr_code;
   WHILE i IS NOT NULL LOOP

      l_pay_now_total_detail_tbl(i).line_id := l_line_tbl(i).line_id;
      l_pay_now_total_detail_tbl(i).term_id := l_line_tbl(i).payment_term_id;
      l_line_id := l_line_tbl(i).line_id;
      l_header_id := l_line_tbl(i).header_id;

      l_pay_now_total_detail_tbl(i).line_amount :=
	 OE_Verify_Payment_PUB.Get_Line_Total
	      (p_line_id               => l_line_id
	      ,p_header_id          => l_header_id
	      ,p_currency_code  => l_currency_code
	      ,p_level                  => NULL
	      ,p_amount_type	    => 'SUBTOTAL'
	      );
      l_pay_now_total_detail_tbl(i).tax_amount :=
	 OE_Verify_Payment_PUB.Get_Line_Total
	      (p_line_id               => l_line_id
	      ,p_header_id          => l_header_id
	      ,p_currency_code  => l_currency_code
	      ,p_level                  => NULL
	      ,p_amount_type	    => 'TAX'
	      );
      l_pay_now_total_detail_tbl(i).freight_amount :=
	 OE_Verify_Payment_PUB.Get_Line_Total
	      (p_line_id               => l_line_id
	      ,p_header_id          => l_header_id
	      ,p_currency_code  => l_currency_code
	      ,p_level                  => NULL
	      ,p_amount_type	    => 'CHARGES'
	      );

      i := l_line_tbl.Next(i);
   END LOOP;


   i := l_pay_now_total_detail_tbl.count + 1;
   -- append header level charges to the detail line table
   IF p_line_id IS NULL OR
      p_line_id = FND_API.G_MISS_NUM THEN
      l_pay_now_total_detail_tbl(i).line_id := null;
      l_pay_now_total_detail_tbl(i).line_amount :=0;
      l_pay_now_total_detail_tbl(i).tax_amount :=0;
      l_pay_now_total_detail_tbl(i).freight_amount :=
	       OE_VERIFY_PAYMENT_PUB.Outbound_Order_Total
		  (p_header_id => p_header_id
		  ,p_total_type => 'HEADER_CHARGES'
		  );
      l_pay_now_total_detail_tbl(i).Term_id := OE_Order_Cache.g_header_rec.payment_term_id;
   END IF;

      -- calling AR API to get pay now total
     MO_GLOBAL.set_policy_context('S',l_org_id);
      AR_VIEW_TERM_GRP.pay_now_amounts
	 (p_api_version         => 1.0
	 ,p_init_msg_list       => FND_API.G_TRUE
	 ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
	 ,p_currency_code       => l_currency_code
	 ,p_amounts_tbl         => l_pay_now_total_detail_tbl
	 ,x_pay_now_summary_rec => l_pay_now_total_summary_rec
	 ,x_return_status       => l_return_status
	 ,x_msg_count           => l_msg_count
	 ,x_msg_data            => l_msg_data
	 );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 IF l_msg_count = 1 THEN
	    IF l_debug_level  > 0 THEN
	       oe_debug_pub.add('Error message after calling AR_VIEW_TERM_GRP.pay_now_amounts API: '||l_msg_data , 3 ) ;
	    END IF;
	    oe_msg_pub.add_text(p_message_text => l_msg_data);
	 ELSIF ( FND_MSG_PUB.Count_Msg > 0 ) THEN
	    arp_util.enable_debug;
	    FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
	       l_msg_data := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
	       IF l_debug_level  > 0 THEN
		  oe_debug_pub.add(  L_MSG_DATA , 3 ) ;
	       END IF;
	       oe_msg_pub.add_text(p_message_text => l_msg_data);
	    END LOOP;
	 END IF;
      END IF;

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	 RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

  IF l_debug_level > 0 THEN
      oe_debug_pub.add('TOTAL AMOUNT -> ' ||nvl(l_pay_now_total_summary_rec.total_amount, 0));
      oe_debug_pub.add('LINE AMOUNT -> ' ||nvl(l_pay_now_total_summary_rec.line_amount, 0));
      oe_debug_pub.add('TAX AMOUNT -> ' ||nvl(l_pay_now_total_summary_rec.tax_amount, 0));
      oe_debug_pub.add('FREIGHT AMOUNT -> ' ||nvl(l_pay_now_total_summary_rec.freight_amount, 0));
      oe_debug_pub.add('EXITING OE_TOTALS_GRP.GET_PAYNOW_TOTAL');
  END IF;

  IF p_total_type IS NULL OR
     p_total_type = 'ALL' THEN
     RETURN nvl(l_pay_now_total_summary_rec.total_amount, 0);
  ELSIF p_total_type = 'LINES' THEN
     RETURN nvl(l_pay_now_total_summary_rec.line_amount, 0);
  ELSIF p_total_type = 'TAXES' THEN
     RETURN nvl(l_pay_now_total_summary_rec.tax_amount, 0);
  ELSIF p_total_type = 'CHARGES' THEN
     RETURN nvl(l_pay_now_total_summary_rec.freight_amount, 0);
  ELSE
     RETURN 0;
  END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 0;

   WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
	 OE_DEBUG_PUB.ADD('Unexpected Error in Get_PayNow_Total API: '||SUBSTR(SQLERRM,1,300) ) ;
      END IF;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            OE_MSG_PUB.Add_Exc_Msg
                          (G_PKG_NAME
                          ,l_api_name
                          );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_PayNow_Total;

END OE_Totals_GRP;

/
