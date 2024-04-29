--------------------------------------------------------
--  DDL for Package Body OE_OE_TOTALS_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_TOTALS_SUMMARY" AS
/* $Header: OEXVTOTB.pls 120.11.12010000.2 2009/02/05 10:35:22 msundara ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'OE_OE_TOTALS_SUMMARY';

--rc pviprana Global table to hold the recurring amounts of an order level modifier grouped by periodicity
G_RECURRING_AMOUNTS_TBL recurring_amounts_tbl_type;

FUNCTION PRICE_ADJUSTMENTS
(
 p_header_id  IN NUMBER
)
RETURN NUMBER

IS
 adjustment_total NUMBER;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN
   adjustment_total:=oe_header_adj_util.get_adj_total(p_header_id);
   RETURN(adjustment_total);

END PRICE_ADJUSTMENTS;


/* function to get adjustment amount for a ORDER level
 * modifier to be applied to a given line */

FUNCTION LINE_PRICE_ADJ_ORDER_MODIFIER
(
 x_header_id IN NUMBER,
 x_line_id IN NUMBER,
 x_list_line_id IN NUMBER
)
RETURN NUMBER

IS
 adj_line_total_order_modifier NUMBER;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

 SELECT   -1 * decode(opa.arithmetic_operator,
                null, 0,
                '%', opa.operand*ool.unit_list_price/100,
                'AMT',opa.operand,
                'NEWPRICE',ool.unit_list_price - opa.operand)
      INTO adj_line_total_order_modifier
      FROM      oe_price_adjustments opa
                        , oe_order_lines_all ool
      WHERE     opa.HEADER_ID = x_header_id
                        and opa.line_id is null
                        and ool.line_id = x_line_id
                        and ool.header_id = x_header_id
                        and opa.list_line_id = x_list_line_id
                        and nvl(opa.applied_flag,'N') = 'Y'
                        and nvl(opa.accrual_flag,'N') = 'N'
                        and list_line_type_code in ('DIS','SUR','PBH');

   RETURN(adj_line_total_order_modifier);

END LINE_PRICE_ADJ_ORDER_MODIFIER;

/* function to get extended adjustment amount for a ORDER level
 * modifier to be applied to a given line */

FUNCTION LINE_EXT_ADJ_ORDER_MODIFIER
(
 x_header_id IN NUMBER,
 x_line_id IN NUMBER,
 x_list_line_id IN NUMBER
)
RETURN NUMBER

IS
 ext_line_tot_order_modifier NUMBER;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

 SELECT   -1 * decode(opa.arithmetic_operator,
                null, 0,
                '%', opa.operand*ool.unit_list_price/100,
                'AMT',opa.operand,
                'NEWPRICE',ool.unit_list_price - opa.operand) * NVL(ool.ordered_quantity,0)
      INTO ext_line_tot_order_modifier
      FROM      oe_price_adjustments opa
                        , oe_order_lines_all ool
      WHERE     opa.HEADER_ID = x_header_id
                        and opa.line_id is null
                        and ool.line_id = x_line_id
                        and ool.header_id = x_header_id
                        and opa.list_line_id = x_list_line_id
                        and nvl(opa.applied_flag,'N') = 'Y'
                        and nvl(opa.accrual_flag,'N') = 'N'
                        and list_line_type_code in ('DIS','SUR','PBH');

   RETURN(ext_line_tot_order_modifier);

END LINE_EXT_ADJ_ORDER_MODIFIER;

/* function get total adjustment amount for a given line */

FUNCTION LINE_PRICE_ADJUSTMENTS
(
 x_line_id  IN NUMBER
)
RETURN NUMBER

IS
 adjustment_line_total NUMBER;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN
   adjustment_line_total:=oe_header_adj_util.get_adj_total(p_line_id => x_line_id);
   RETURN(adjustment_line_total);

END LINE_PRICE_ADJUSTMENTS;

FUNCTION CHARGES
(
 p_header_id  IN NUMBER
)
RETURN NUMBER

IS
l_charge_total   NUMBER;
l_msg_count      NUMBER := 0;
l_msg_data       VARCHAR2(2000):= NULL;
l_return_status  VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  -- Calling the charges API to get the Order Total for charges.

    OE_CHARGE_PVT.Get_Charge_Amount(
				 p_api_version_number => 1.1 ,
				 p_init_msg_list      => FND_API.G_FALSE ,
				 p_header_id          => p_header_id ,
				 p_line_id            => NULL,
				 p_all_charges        => FND_API.G_TRUE ,
				 x_return_status      => l_return_status ,
				 x_msg_count          => l_msg_count ,
				 x_msg_data           => l_msg_data ,
				 x_charge_amount      => l_charge_total
				 );
  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	       RAISE FND_API.G_EXC_ERROR;
  END IF;

  RETURN l_charge_total;

END CHARGES;


/* Chen added */
FUNCTION LINE_CHARGES
(
 p_header_id  IN NUMBER,
 p_line_id    IN NUMBER
)
RETURN NUMBER

IS
l_charge_total   NUMBER;
l_msg_count      NUMBER := 0;
l_msg_data       VARCHAR2(2000):= NULL;
l_return_status  VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  -- Calling the charges API to get the Order Total for charges.

    OE_CHARGE_PVT.Get_Charge_Amount(
				 p_api_version_number => 1.1 ,
				 p_init_msg_list      => FND_API.G_FALSE ,
				 p_header_id          => p_header_id ,
				 p_line_id            => p_line_id,
				 p_all_charges        => FND_API.G_FALSE ,
				 x_return_status      => l_return_status ,
				 x_msg_count          => l_msg_count ,
				 x_msg_data           => l_msg_data ,
				 x_charge_amount      => l_charge_total
				 );
  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	       RAISE FND_API.G_EXC_ERROR;
  END IF;

  RETURN l_charge_total;

END LINE_CHARGES;

FUNCTION TAXES
(
p_header_id  IN NUMBER
)
RETURN NUMBER

IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  RETURN(nvl(G_TAX_VALUE,0));

END TAXES;

FUNCTION ORDER_SUBTOTALS
(
p_header_id  IN NUMBER
)
RETURN NUMBER

IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  RETURN(nvl(G_TOTAL_EXTENDED_PRICE,0));

END ORDER_SUBTOTALS;

FUNCTION LINE_TOTAL
(p_header_id          IN NUMBER,
 p_line_id            IN NUMBER,
 p_line_number        IN NUMBER,
 p_shipment_number    IN NUMBER
 )
RETURN NUMBER

IS
 l_Total NUMBER :=0;

 CURSOR C1(p_header_id NUMBER,p_line_number NUMBER,p_line_id NUMBER) IS
   SELECT NVL(Ordered_Quantity,0)*
		NVL(unit_selling_price,0) Line_details_total,Line_Number,
		Line_Category_Code
   FROM   oe_order_lines_all
   WHERE  header_id=p_header_id
   AND (line_number=p_line_number
   AND NVL(cancelled_flag,'N') ='N'
   OR (top_model_line_id is not null
   AND top_model_line_id=p_line_id
   AND NVL(cancelled_flag,'N') ='N')
   OR (service_reference_line_id is not null
   AND service_reference_line_id=p_line_id
   AND NVL(cancelled_flag,'N') ='N'));

   /* Need to Check for performance with using 'OR'instead of Union */

/* CURSOR C2(line_number      NUMBER,
		 header_id        NUMBER,
		 shipment_number  NUMBER)
 IS
   SELECT NVL(ordered_quantity,0)-NVL(cancelled_quantity,0)*
		NVL(unit_selling_price,0) shipment_total,Line_Number
   FROM   oe_order_lines_all
   WHERE  header_id=header_id
   AND    Line_Number=Line_Number
   AND    Shipment_Number=shipment_number
   AND    cancelled_flag='N'; */

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  FOR Lines IN C1(p_header_id,p_line_number,p_line_id)

  LOOP
    IF lines.line_category_code <> 'RETURN' THEN
      l_Total:=l_Total+lines.line_details_total;
    ELSIF lines.line_category_code='RETURN' THEN
	 l_total:=l_total-lines.line_details_total;
    END IF;
  END LOOP;
   RETURN(l_total);

 EXCEPTION
   WHEN no_data_found THEN
	Null;
   WHEN too_many_rows THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   WHEN others THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END LINE_TOTAL;

/* bug - 1480491 */
FUNCTION SERVICE_TOTAL
(p_header_id          IN NUMBER,
 p_line_number        IN NUMBER,
 p_service_number     IN NUMBER
 )
RETURN NUMBER

IS
 l_Total NUMBER :=0;

 CURSOR C1(p_header_id NUMBER,p_line_number NUMBER,p_service_number NUMBER) IS
   SELECT NVL(Ordered_Quantity,0)*
		NVL(unit_selling_price,0) Line_details_total,Line_Number,
		Line_Category_Code
   FROM   oe_order_lines_all
   WHERE  header_id=p_header_id
   AND line_number=p_line_number
   AND service_number=p_service_number
   AND NVL(cancelled_flag,'N') ='N'
   AND item_type_code = 'SERVICE';

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  FOR Lines IN C1(p_header_id,p_line_number,p_service_number)

  LOOP
    IF lines.line_category_code <> 'RETURN' THEN
      l_Total:=l_Total+lines.line_details_total;
    ELSIF lines.line_category_code='RETURN' THEN
	 l_total:=l_total-lines.line_details_total;
    END IF;
  END LOOP;
   RETURN(l_total);

 EXCEPTION
   WHEN no_data_found THEN
	Null;
   WHEN too_many_rows THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   WHEN others THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END SERVICE_TOTAL;
/* bug - 1480491 */

PROCEDURE GLOBAL_TOTALS(p_header_id IN NUMBER)
IS
Is_fmt            BOOLEAN;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

BEGIN

IF p_header_id IS NOT NULL THEN
   Is_fmt:= OE_ORDER_UTIL.Get_Precision(p_header_id=>p_header_id);
END IF;

IF OE_ORDER_UTIL.G_Precision IS NULL THEN
   OE_ORDER_UTIL.G_Precision:=2;
END IF;

/* changed following SQL for #3970425 */

SELECT SUM(nvl(ROUND(decode(oel.line_category_code,'RETURN',-oel.tax_value,oel.tax_value), OE_ORDER_UTIL.G_Precision),0)),
       SUM(ROUND(nvl(oel.Ordered_Quantity,0) * (oel.unit_selling_price) * (decode(oel.line_category_code,'RETURN',-1,1)),OE_ORDER_UTIL.G_Precision))
INTO   G_TAX_VALUE, G_TOTAL_EXTENDED_PRICE
FROM   oe_order_lines_all oel
WHERE  oel.header_id=p_header_id
AND charge_periodicity_code is NULL  -- added for recurring charges
AND    NVL(oel.cancelled_flag,'N') ='N';

EXCEPTION
WHEN too_many_rows THEN
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add('unexpected error : '||sqlerrm,1);
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
WHEN no_data_found THEN
     IF l_debug_level  > 0 THEN
	oe_debug_pub.add('No Data found'||p_header_id,1) ;
     END IF;
WHEN others THEN
     IF l_debug_level  > 0 THEN
	oe_debug_pub.add('Others unexpected error : '||sqlerrm,1);
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GLOBAL_TOTALS;

FUNCTION CONFIG_TOTALS
(
p_line_id   IN NUMBER
)
RETURN NUMBER
IS
 l_config_total NUMBER;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN
  SELECT SUM(nvl(Ordered_Quantity,0)
	   *(unit_selling_price))
  INTO  l_config_total
  FROM oe_order_lines_all
  WHERE line_id=p_line_id
  AND NVL(cancelled_flag,'N') ='N';

  RETURN(l_config_total);

  EXCEPTION
    WHEN too_many_rows THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN no_data_found THEN
	Null;

    WHEN others THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END CONFIG_TOTALS;

FUNCTION TOTAL_ORDERED_QTY
(
p_header_id   IN NUMBER,
p_line_number IN NUMBER
)
RETURN NUMBER
IS
l_ordered_qty NUMBER :=0;
   CURSOR C1(p_header_id NUMBER,p_line_number NUMBER) IS
   SELECT NVL(Ordered_quantity,0) Qty
   FROM   oe_order_lines_all
   WHERE  header_id=p_header_id
   AND NVL(cancelled_flag,'N') ='N'
   AND line_number=p_line_number
   AND item_type_code in ('STANDARD','MODEL','KIT')
--   And option_number is null
   and line_id = nvl(top_model_line_id,line_id);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  FOR Lines IN C1(p_header_id,p_line_number)
  LOOP
    l_ordered_qty:=l_ordered_qty+lines.qty;
  END LOOP;
   RETURN(l_ordered_qty);
  EXCEPTION
   WHEN no_data_found THEN
	Null;
   WHEN too_many_rows THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   WHEN others THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END TOTAL_ORDERED_QTY;

PROCEDURE ORDER_TOTALS
  (
  p_header_id     IN  NUMBER,
p_subtotal OUT NOCOPY NUMBER,

p_discount OUT NOCOPY NUMBER,

p_charges OUT NOCOPY NUMBER,

p_tax OUT NOCOPY NUMBER

  )
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
                OE_OE_TOTALS_SUMMARY.Global_Totals
                        (
                        p_header_id
                        );
    p_subtotal:=OE_OE_TOTALS_SUMMARY.Order_Subtotals
                        (
                        p_header_id
                        );

    p_discount:=OE_OE_TOTALS_SUMMARY.Price_Adjustments
                        (
                        p_header_id
                        );
    p_charges:=OE_OE_TOTALS_SUMMARY.Charges
                        (
                        p_header_id
                        );
    p_tax:=OE_OE_TOTALS_SUMMARY.Taxes
                        (
                        p_header_id
                        );


END ORDER_TOTALS;


/* The function PRT_ORDER_TOTAL is used by the view ONT_PRT_ORDER_HEADERS_V to calculate the order total */

FUNCTION PRT_ORDER_TOTAL
	(
	p_header_id IN NUMBER
	)
RETURN NUMBER
IS

l_subtotal NUMBER;
l_discount NUMBER;
l_charges NUMBER;
l_tax NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	OE_OE_TOTALS_SUMMARY.Global_Totals(p_header_id);

	l_subtotal:=OE_OE_TOTALS_SUMMARY.Order_Subtotals(p_header_id);

--      performance bug 4060810: disabling this calculation as it is not used
--	l_discount:=OE_OE_TOTALS_SUMMARY.Price_Adjustments(p_header_id);
	l_charges:=OE_OE_TOTALS_SUMMARY.Charges(p_header_id);
	l_tax:=OE_OE_TOTALS_SUMMARY.Taxes(p_header_id);

RETURN (l_subtotal + l_charges + l_tax);

EXCEPTION
	WHEN OTHERS THEN
		RETURN NULL;
END PRT_ORDER_TOTAL;

FUNCTION OUTBOUND_ORDER_TOTAL
(
 p_header_id     IN NUMBER,
 p_to_exclude_commitment        IN VARCHAR2 DEFAULT NULL, -- 4013565
 p_total_type			IN VARCHAR2 DEFAULT NULL,  --4013565
 p_all_lines                    IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER
IS
l_order_total     NUMBER;
l_tax_total       NUMBER;
l_charges         NUMBER;
l_outbound_total  NUMBER;
l_commitment_total NUMBER;
l_chgs_w_line_id   NUMBER := 0;
l_chgs_wo_line_id  NUMBER := 0;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Is_fmt            BOOLEAN;  --5716270
BEGIN

  Is_fmt:= OE_ORDER_UTIL.Get_Precision(p_header_id=>p_header_id); --5716270
  -- bug4013565
  IF OE_ORDER_UTIL.G_Precision IS NULL THEN
     OE_ORDER_UTIL.G_Precision:=2;
  END IF;


  -- added ROUND in someplaces below for 4013565

  -- Select the Tax Total and Outbound Extended Price
  -- p_all_lines 'Y' means to include all lines including all open or closed ones.
  -- Currently this parameter is only set 'Y' when calling from Payments form.

  SELECT
    SUM(ROUND(nvl(ool.tax_value,0), OE_ORDER_UTIL.G_Precision))
  , SUM(ROUND(nvl(ool.Ordered_Quantity,0)
	   *(ool.unit_selling_price), OE_ORDER_UTIL.G_Precision))
  INTO
    l_tax_total
  , l_order_total
  FROM  oe_order_lines_all ool
  WHERE ool.header_id      = p_header_id
  AND   ( (ool.open_flag  = 'Y' AND p_all_lines is null)
        OR nvl(p_all_lines, 'N') = 'Y' )
  AND   ool.line_category_code <> 'RETURN'
  AND   ool.charge_periodicity_code is null -- Added for Recurring Charges
  AND   NOT EXISTS
       (SELECT 'Non Invoiceable Item Line'
        FROM   mtl_system_items mti
        WHERE  mti.inventory_item_id = ool.inventory_item_id
        AND    mti.organization_id   = nvl(ool.ship_from_org_id,
                         oe_sys_parameters.value('MASTER_ORGANIZATION_ID', ool.org_id))
        AND   (mti.invoiceable_item_flag = 'N'
           OR  mti.invoice_enabled_flag  = 'N'));

  IF OE_Commitment_Pvt.Do_Commitment_Sequencing THEN
    -- Select the committment applied amount if Commitment Sequencing "On"
    SELECT SUM(ROUND(nvl(op.commitment_applied_amount,0), OE_ORDER_UTIL.G_Precision))
    INTO   l_commitment_total
    FROM   oe_payments op
    WHERE  op.header_id = p_header_id
    AND    NOT EXISTS
          (SELECT 'Non Invoiceable Item Line'
           FROM   mtl_system_items mti, oe_order_lines_all ool
           WHERE  ool.line_id           = op.line_id
           AND    mti.inventory_item_id = ool.inventory_item_id
           AND    mti.organization_id   = nvl(ool.ship_from_org_id,
                          oe_sys_parameters.value('MASTER_ORGANIZATION_ID', ool.org_id))
           AND   (mti.invoiceable_item_flag = 'N'
              OR  mti.invoice_enabled_flag  = 'N'));
  ELSE
  -- Select the Outbound Extended Price for lines that have committment
  SELECT SUM(ROUND(nvl(ool.Ordered_Quantity,0) *(ool.unit_selling_price), OE_ORDER_UTIL.G_Precision))
  INTO   l_commitment_total
  FROM   oe_order_lines_all ool
  WHERE  ool.header_id      = p_header_id
  AND    ool.commitment_id is not null
  AND   ( (ool.open_flag  = 'Y' AND p_all_lines is null)
        OR nvl(p_all_lines, 'N') = 'Y' )
  AND   ool.charge_periodicity_code is null -- Added for Recurring Charges
  AND    ool.line_category_code <> 'RETURN'
  AND   NOT EXISTS
       (SELECT 'Non Invoiceable Item Line'
        FROM   mtl_system_items mti
        WHERE  mti.inventory_item_id = ool.inventory_item_id
        AND    mti.organization_id   = nvl(ool.ship_from_org_id,
                         oe_sys_parameters.value('MASTER_ORGANIZATION_ID', ool.org_id))
        AND   (mti.invoiceable_item_flag = 'N'
           OR  mti.invoice_enabled_flag  = 'N'));
  END IF;

  -- Select the Outbound Charges Total

     SELECT SUM(
                ROUND(
                      DECODE(P.CREDIT_OR_CHARGE_FLAG,'C',-P.OPERAND,P.OPERAND), OE_ORDER_UTIL.G_Precision
                )
               )
     INTO l_chgs_wo_line_id
     FROM OE_PRICE_ADJUSTMENTS P
     WHERE P.HEADER_ID = p_header_id
     AND   P.LINE_ID IS NULL
     AND   P.LIST_LINE_TYPE_CODE = 'FREIGHT_CHARGE'
     AND   P.APPLIED_FLAG = 'Y'
     --Bug 6072691
     --AND   NVL(P.INVOICED_FLAG, 'N') = 'N';
     AND   ((    NVL(P.INVOICED_FLAG,'N') = 'Y'
             AND NVL(p_total_type,'OTHERS') = 'INV_CHARGES'
            )
            OR
            (    NVL(P.INVOICED_FLAG,'N') <> 'Y'
             AND NVL(p_total_type,'OTHERS') = 'CHARGES'
            )
            OR
            (
             NVL(p_total_type,'OTHERS') NOT IN ('INV_CHARGES','CHARGES')
            )
           );
--bug 	8217014
     SELECT SUM(
                ROUND(
                      DECODE(P.CREDIT_OR_CHARGE_FLAG,'C',
                        DECODE(P.ARITHMETIC_OPERATOR, 'LUMPSUM',
                               DECODE(L.ORDERED_QUANTITY,0,0,-P.OPERAND),
                               (-L.ORDERED_QUANTITY*P.ADJUSTED_AMOUNT)),
                        DECODE(P.ARITHMETIC_OPERATOR, 'LUMPSUM',
                               DECODE(L.ORDERED_QUANTITY,0,0,P.OPERAND),
                               (L.ORDERED_QUANTITY*P.ADJUSTED_AMOUNT))
                             )
                     ,OE_ORDER_UTIL.G_Precision
                     )
              )
     INTO l_chgs_w_line_id
     FROM OE_PRICE_ADJUSTMENTS P,
          OE_ORDER_LINES_ALL L
     WHERE P.HEADER_ID = p_header_id
     AND   P.LINE_ID = L.LINE_ID
     AND   P.LIST_LINE_TYPE_CODE = 'FREIGHT_CHARGE'
     AND   P.APPLIED_FLAG = 'Y'
     AND   L.charge_periodicity_code is null -- Added for Recurring Charges
     AND   L.header_id      = p_header_id
     AND   ( (L.open_flag  = 'Y' AND p_all_lines is null)
           OR nvl(p_all_lines, 'N') = 'Y' )
     AND   L.line_category_code <> 'RETURN'
     AND   NOT EXISTS
          (SELECT 'Non Invoiceable Item Line'
           FROM   MTL_SYSTEM_ITEMS MTI
           WHERE  MTI.INVENTORY_ITEM_ID = L.INVENTORY_ITEM_ID
           AND    MTI.ORGANIZATION_ID   = NVL(L.SHIP_FROM_ORG_ID,
                         oe_sys_parameters.value('MASTER_ORGANIZATION_ID', L.org_id))
           AND   (MTI.INVOICEABLE_ITEM_FLAG = 'N'
              OR  MTI.INVOICE_ENABLED_FLAG  = 'N'))
     --Bug 6072691
     --AND   NVL(P.INVOICED_FLAG, 'N') = 'N';
     AND   ((    NVL(P.INVOICED_FLAG,'N') = 'Y'
             AND NVL(p_total_type,'OTHERS') = 'INV_CHARGES'
            )
            OR
            (    NVL(P.INVOICED_FLAG,'N') <> 'Y'
             AND NVL(p_total_type,'OTHERS') = 'CHARGES'
            )
            OR
            (
             NVL(p_total_type,'OTHERS') NOT IN ('INV_CHARGES','CHARGES')
            )
           );

    l_charges := nvl(l_chgs_wo_line_id,0) + nvl(l_chgs_w_line_id,0);

  IF nvl(p_to_exclude_commitment, 'Y') = 'Y' THEN
    l_outbound_total := nvl(l_order_total, 0) + nvl(l_tax_total, 0)
				+ nvl(l_charges, 0) - nvl(l_commitment_total,0);
  ELSE
    l_outbound_total := nvl(l_order_total, 0) + nvl(l_tax_total, 0)
				+ nvl(l_charges, 0);
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CALCULATING THE TOTAL AMOUNT TO BE AUTHORIZED FOR THIS ORDER ' , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ORDER TOTAL -> '||TO_CHAR ( L_ORDER_TOTAL ) , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'TAX TOTAL -> '||TO_CHAR ( L_TAX_TOTAL ) , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'COMMITMENTS -> '||TO_CHAR ( L_COMMITMENT_TOTAL ) , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OTHER CHARGES -> '||TO_CHAR ( L_CHARGES ) , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AMOUNT TO BE AUTHORIZED => '||TO_CHAR ( L_OUTBOUND_TOTAL ) , 1 ) ;
  END IF;

  -- bug 4013565
  IF p_total_type = 'TAXES' THEN
    RETURN nvl(l_tax_total, 0);
  --Bug 6072691
  ELSIF p_total_type IN('CHARGES','INV_CHARGES') THEN
    RETURN nvl(l_charges, 0);
  ELSIF p_total_type = 'SUBTOTAL' THEN
    RETURN nvl(l_order_total,0);
  ELSE
    RETURN (l_outbound_total);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'FROM OUTBOUND TOTAL OTHERS' ) ;
	 END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END OUTBOUND_ORDER_TOTAL;

FUNCTION OUTBOUND_ORDER_SUBTOTAL
(
 p_header_id     IN NUMBER
) RETURN NUMBER
IS
l_order_subtotal     NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  -- Select the Outbound Extended Price
  BEGIN
    SELECT  SUM(nvl(ool.Ordered_Quantity,0)
 	   *(ool.unit_selling_price))
    INTO   l_order_subtotal
    FROM  oe_order_lines_all ool
    WHERE ool.header_id      = p_header_id
    AND   ool.open_flag      = 'Y'
    AND   ool.charge_periodicity_code is null -- Added for Recurring Charges
    AND   ool.line_category_code <> 'RETURN'
    AND   NOT EXISTS
         (SELECT 'Non Invoiceable Item Line'
          FROM   mtl_system_items mti
          WHERE  mti.inventory_item_id = ool.inventory_item_id
          AND    mti.organization_id   = nvl(ool.ship_from_org_id,
                     oe_sys_parameters.value('MASTER_ORGANIZATION_ID', ool.org_id))
          AND   (mti.invoiceable_item_flag = 'N'
                 OR  mti.invoice_enabled_flag  = 'N'));
  EXCEPTION
    WHEN no_data_found THEN
      l_order_subtotal := 0;
  END;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CALCULATING THE ORDER SUBTOTAL AMOUNT FOR THIS ORDER ' , 1 ) ;
      oe_debug_pub.add(  'ORDER TOTAL -> '||TO_CHAR ( L_ORDER_SUBTOTAL ) , 1 ) ;
  END IF;
  RETURN (nvl(l_order_subtotal,0));

  EXCEPTION
    WHEN OTHERS THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'FROM OUTBOUND SUBTOTAL OTHERS' ) ;
	 END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END OUTBOUND_ORDER_SUBTOTAL;

--------------------------------------------------------------------------------------
--Called by pricing sourcing rules.
--Pricing order amount is always based on sum of unit list price NOT unit selling price
---------------------------------------------------------------------------------------
Function Get_Order_Amount(p_header_id In Number) Return Number
Is
 orders_total      NUMBER;
 returns_total     NUMBER;
 l_order_amount    NUMBER;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_OE_TOTALS_SUMMARY.GET_ORDER_AMOUNT' ) ;
  END IF;

  -- combining 2 SQLs into one for performance
  SELECT SUM(DECODE(line_category_code, 'RETURN', 0, nvl(Ordered_Quantity,0)*(unit_list_price))),
         SUM(DECODE(line_category_code, 'RETURN', nvl(Ordered_Quantity,0)*(unit_list_price),0))
  INTO orders_total, returns_total
  FROM oe_order_lines_all
  WHERE header_id=p_header_id
  AND   charge_periodicity_code is null -- Added for Recurring CHarges
  AND NVL(cancelled_flag,'N') ='N';

  l_order_amount:=NVL(orders_total,0)-NVL(returns_total,0);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' ORDER TOTAL:='||ORDERS_TOTAL ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' RETURN TOTAL:='||RETURNS_TOTAL ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' ORDER AMOUNT:='||L_ORDER_AMOUNT ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LEAVING OE_OE_TOTALS_SUMMARY.GET_ORDER_AMOUNT' ) ;
  END IF;

  return l_order_amount;
  EXCEPTION
    WHEN too_many_rows THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  ' TOO MANY ROWS' ) ;
         END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN no_data_found THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  ' FROM NO DATA FOUND' ) ;
	 END IF;


    WHEN others THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  ' FROM OTHERS' ) ;
	 END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_order_amount;




-- This function is used to calculate the discount percentage for the line
-- items in a sales order. This uses the unit selling price and the unit
-- list price to calculate the discount
-- Input: unit_list_price, unit_selling_price   Output: discount percent
-- Called from: OE_PRN_ORDER_LINES_V view
--

FUNCTION GET_DISCOUNT(p_unit_list_price IN number,p_unit_selling_price IN NUMBER)
RETURN NUMBER IS

l_discount_pct          NUMBER;
l_debug_level CONSTANT  NUMBER := oe_debug_pub.g_debug_level;

BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('ENTER GET_DISCOUNT PROCEDURE');
        oe_debug_pub.add('Unit List Price = '||p_unit_list_price );
        oe_debug_pub.add('Unit Selling Price = '||p_unit_selling_price );
    END IF;

    IF ((p_unit_list_price IS NOT NULL AND p_unit_list_price > 0) AND
        (p_unit_selling_price IS NOT NULL AND p_unit_selling_price > 0) AND
        (p_unit_list_price >= p_unit_selling_price)) THEN
        l_discount_pct := round(((p_unit_list_price-p_unit_selling_price)/p_unit_list_price)*100);

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Discount Percent = '||l_discount_pct);
            oe_debug_pub.add('EXIT GET_DISCOUNT PROCEDURE');
        END IF;
        -- IF l_discount_pct < 1 THEN
        --   RETURN NULL;
        -- ELSE
             RETURN l_discount_pct;
        -- END IF;
    ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('EXIT GET_DISCOUNT PROCEDURE');
        END IF;

        RETURN NULL;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'GET_DISCOUNT: WHEN OTHERS Exception' ) ;
	END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'GET_DISCOUNT'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GET_DISCOUNT;


/* Recurring charges */

PROCEDURE GLOBAL_REC_TOTALS
(
 p_header_id               IN      NUMBER,
 p_charge_periodicity_code IN      VARCHAR2
)
IS

Is_fmt            BOOLEAN;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

BEGIN

IF p_header_id IS NOT NULL THEN
   Is_fmt:= OE_ORDER_UTIL.Get_Precision(p_header_id=>p_header_id);
END IF;

IF OE_ORDER_UTIL.G_Precision IS NULL THEN
   OE_ORDER_UTIL.G_Precision:=2;
END IF;

/* changed following SQL for #3970425 */

SELECT SUM(nvl(ROUND(decode(oel.line_category_code,'RETURN',-oel.tax_value,oel.tax_value), OE_ORDER_UTIL.G_Precision),0)),
       SUM(ROUND(nvl(oel.Ordered_Quantity,0) * (oel.unit_selling_price) * (decode(oel.line_category_code,'RETURN',-1,1)),OE_ORDER_UTIL.G_Precision))
INTO   G_REC_TAX_VALUE, G_REC_TOTAL_EXTENDED_PRICE
FROM   oe_order_lines_all oel
WHERE  oel.header_id=p_header_id
AND nvl(charge_periodicity_code,'ONE') = p_charge_periodicity_code
AND    NVL(oel.cancelled_flag,'N') ='N';

EXCEPTION

WHEN too_many_rows THEN
     oe_debug_pub.add('unexpected error : '||sqlerrm,1);
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
WHEN no_data_found THEN
     IF l_debug_level  > 0 THEN
	oe_debug_pub.add('No Data found'||p_header_id,1) ;
     END IF;
WHEN others THEN
     IF l_debug_level  > 0 THEN
	oe_debug_pub.add('Others unexpected error : '||sqlerrm,1);
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GLOBAL_REC_TOTALS;

FUNCTION Rec_TAXES
(
p_header_id  IN NUMBER
)
RETURN NUMBER

IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  RETURN(nvl(G_REC_TAX_VALUE,0));

END REC_TAXES;

FUNCTION REC_ORDER_SUBTOTALS
(
p_header_id  IN NUMBER
)
RETURN NUMBER

IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  RETURN(nvl(G_REC_TOTAL_EXTENDED_PRICE,0));

END REC_ORDER_SUBTOTALS;

FUNCTION REC_CHARGES
(
 p_header_id  IN NUMBER,
 p_charge_periodicity_code IN VARCHAR2
)
RETURN NUMBER

IS
l_charge_total   NUMBER;
l_msg_count      NUMBER := 0;
l_msg_data       VARCHAR2(2000):= NULL;
l_return_status  VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.ADD('CALLING THE CHARGES API TO GET THE ORDER TOTAL FOR CHARGES',1);
      OE_DEBUG_PUB.ADD('INPUTS PASSED',1);
      OE_DEBUG_PUB.ADD('p_header_id : '||p_header_id,1);
      OE_DEBUG_PUB.ADD('p_charge_periodicity_code : '||p_charge_periodicity_code,1);
    END IF;

    OE_CHARGE_PVT.Get_Rec_Charge_Amount(
				 p_api_version_number => 1.1 ,
				 p_init_msg_list      => FND_API.G_FALSE ,
				 p_header_id          => p_header_id ,
				 p_line_id            => NULL,
				 p_all_charges        => FND_API.G_TRUE ,
				 p_charge_periodicity_code =>p_charge_periodicity_code,
				 x_return_status      => l_return_status ,
				 x_msg_count          => l_msg_count ,
				 x_msg_data           => l_msg_data ,
				 x_charge_amount      => l_charge_total
				 );
  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	       RAISE FND_API.G_EXC_ERROR;
  END IF;

  RETURN l_charge_total;

END REC_CHARGES;

FUNCTION REC_PRICE_ADJUSTMENTS
(
 p_header_id  IN NUMBER,
 p_charge_periodicity_code IN VARCHAR2
)
RETURN NUMBER

IS
 adjustment_total NUMBER;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 p_line_id NUMBER;
 --
BEGIN
   adjustment_total:=oe_header_adj_util.get_rec_adj_total(p_header_id,p_line_id,p_charge_periodicity_code);
   RETURN(adjustment_total);

END REC_PRICE_ADJUSTMENTS;

PROCEDURE REC_ORDER_TOTALS
(
p_header_id                   IN  NUMBER,
p_charge_periodicity_code     IN  VARCHAR2,
x_subtotal                    OUT NOCOPY NUMBER,
x_discount                    OUT NOCOPY NUMBER,
x_charges                     OUT NOCOPY NUMBER,
x_tax                         OUT NOCOPY NUMBER,
x_total                       OUT NOCOPY NUMBER
)
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

 IF l_debug_level > 0 THEN
   OE_DEBUG_PUB.ADD('ENTERING OE_OE_TOTALS_SUMMARY.REC_ORDER_TOTALS',1);
   OE_DEBUG_PUB.ADD('INPUTS TO THE API',1);
   OE_DEBUG_PUB.ADD('p_header_id :'||p_header_id,1);
   OE_DEBUG_PUB.ADD('p_charge_periodicity_code :'||p_charge_periodicity_code,1);
 END IF;

    OE_OE_TOTALS_SUMMARY.Global_Rec_Totals(p_header_id       => p_header_id,
                          p_charge_periodicity_code          => p_charge_periodicity_code);

     x_tax := g_rec_tax_value;
     x_subtotal := g_rec_total_extended_price;

     x_discount:=OE_OE_TOTALS_SUMMARY.Rec_Price_Adjustments
                        (
                        p_header_id,
                        p_charge_periodicity_code
                        );

    x_charges:=OE_OE_TOTALS_SUMMARY.Rec_Charges
                        (
                        p_header_id,
                        p_charge_periodicity_code
                        );

   x_total := x_tax + x_subtotal + x_charges;

 IF l_debug_level > 0 THEN
   OE_DEBUG_PUB.ADD('EXITING OE_OE_TOTALS_SUMMARY.REC_ORDER_TOTALS',1);
 END IF;

END REC_ORDER_TOTALS;


PROCEDURE GET_RECURRING_TOTALS
(
p_header_id       IN  NUMBER,
x_rec_charges_tbl  IN OUT NOCOPY OE_OE_TOTALS_SUMMARY.Rec_Charges_Tbl_Type)
IS
CURSOR C_rec_charge(g_header_id IN NUMBER) IS
        select distinct charge_periodicity_code
        from oe_order_lines_all
        where header_id = g_header_id
        and charge_periodicity_code is not null
        order by charge_periodicity_code;

l_code                 VARCHAR2(3);
i                      NUMBER;
x_tax                  NUMBER;
x_subtotal             NUMBER;
x_charges              NUMBER;
l_debug_level          CONSTANT NUMBER := Oe_Debug_Pub.g_debug_level;

BEGIN

  IF l_debug_level > 0 THEN
    OE_DEBUG_PUB.ADD('ENTERING OE_OE_TOTALS_SUMMARY.GET_RECURRING_TOTALS',1);
    OE_DEBUG_PUB.ADD('INPUTS TO THE API',1);
    OE_DEBUG_PUB.ADD('p_header_id :'||p_header_id,1);
  END IF;

  i := 1;
  OPEN  C_rec_charge(p_header_id);
  LOOP
     FETCH C_rec_charge INTO l_code;
     EXIT WHEN C_rec_charge%NOTFOUND;

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.ADD('INSIDE  LOOP FOR PERIODICITY_CODE :'||l_code,1);
     END IF;

     x_rec_charges_tbl(i).charge_periodicity_code := l_code;
     x_rec_charges_tbl(i).charge_periodicity_meaning := OE_ID_TO_VALUE.Charge_Periodicity(l_code);


     OE_OE_TOTALS_SUMMARY.GLOBAL_Rec_TOTALS
         (
             p_header_id                  => p_header_id,
             p_charge_periodicity_code    => l_code
         );
     x_tax := g_rec_tax_value;
     x_subtotal := g_rec_total_extended_price;

     x_rec_charges_tbl(i).rec_tax := x_tax;
     x_rec_charges_tbl(i).rec_subtotal := x_subtotal;

     x_charges := OE_OE_TOTALS_SUMMARY.ReC_charges(p_header_id       => p_header_id,
                          p_charge_periodicity_code         => l_code);
     x_rec_charges_tbl(i).rec_charges := x_charges;
     x_rec_charges_tbl(i).rec_total := x_subtotal + x_tax + x_charges;

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.ADD('TOTALS  FOR PERIODICITY_CODE :'||l_code,1);
        OE_DEBUG_PUB.ADD('TAX :'||x_tax,1);
        OE_DEBUG_PUB.ADD('SUBTOTAL :'||x_subtotal,1);
        OE_DEBUG_PUB.ADD('CHARGES :'||x_charges,1);
     END IF;

     i := i+1;
  END LOOP;
  CLOSE C_rec_charge;

  IF l_debug_level > 0 THEN
    OE_DEBUG_PUB.ADD('EXITING OE_OE_TOTALS_SUMMARY.GET_RECURRING_TOTALS');
  END IF;

  EXCEPTION

   WHEN NO_DATA_FOUND THEN
     CLOSE C_rec_charge;
     Null;


END Get_Recurring_Totals;

PROCEDURE GET_UI_RECURRING_TOTALS
(
p_header_id       IN  NUMBER,
x_rec_charges_tbl  IN OUT NOCOPY OE_OE_TOTALS_SUMMARY.Rec_Charges_Tbl_Type)
IS
CURSOR C_rec_charge(g_header_id IN NUMBER) IS
        select distinct nvl(charge_periodicity_code,'ONE')
        from oe_order_lines_all
        where header_id = g_header_id
      --  and charge_periodicity_code is not null
        order by nvl(charge_periodicity_code,'ONE');

l_code                 VARCHAR2(3);
i                      NUMBER;
x_tax                  NUMBER;
x_subtotal             NUMBER;
x_charges              NUMBER;
l_debug_level          CONSTANT NUMBER := Oe_Debug_Pub.g_debug_level;

BEGIN

  IF l_debug_level > 0 THEN
    OE_DEBUG_PUB.ADD('ENTERING OE_OE_TOTALS_SUMMARY.GET_RECURRING_TOTALS',1);
    OE_DEBUG_PUB.ADD('INPUTS TO THE API',1);
    OE_DEBUG_PUB.ADD('p_header_id :'||p_header_id,1);
  END IF;

  i := 1;
  OPEN  C_rec_charge(p_header_id);
  LOOP
     FETCH C_rec_charge INTO l_code;
     EXIT WHEN C_rec_charge%NOTFOUND;

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.ADD('INSIDE  LOOP FOR PERIODICITY_CODE :'||l_code,1);
     END IF;

     x_rec_charges_tbl(i).charge_periodicity_code := l_code;
     IF (l_code <> 'ONE') THEN
     x_rec_charges_tbl(i).charge_periodicity_meaning := OE_ID_TO_VALUE.Charge_Periodicity(l_code);
     END IF;

     OE_OE_TOTALS_SUMMARY.GLOBAL_Rec_TOTALS
         (
             p_header_id                  => p_header_id,
             p_charge_periodicity_code    => l_code
         );
     x_tax := nvl(g_rec_tax_value,0);
     x_subtotal := nvl(g_rec_total_extended_price,0);

     x_rec_charges_tbl(i).rec_tax := x_tax;
     x_rec_charges_tbl(i).rec_subtotal := x_subtotal;

     x_charges := OE_OE_TOTALS_SUMMARY.ReC_charges(p_header_id       => p_header_id,
                          p_charge_periodicity_code         => l_code);
     x_rec_charges_tbl(i).rec_charges := x_charges;
     x_rec_charges_tbl(i).rec_total := nvl(x_subtotal,0) + nvl(x_tax,0) + nvl(x_charges,0);

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.ADD('TOTALS  FOR PERIODICITY_CODE :'||l_code,1);
        OE_DEBUG_PUB.ADD('TAX :'||x_tax,1);
        OE_DEBUG_PUB.ADD('SUBTOTAL :'||x_subtotal,1);
        OE_DEBUG_PUB.ADD('CHARGES :'||x_charges,1);
     END IF;

     i := i+1;
  END LOOP;
  CLOSE C_rec_charge;

  IF l_debug_level > 0 THEN
    OE_DEBUG_PUB.ADD('EXITING OE_OE_TOTALS_SUMMARY.GET_RECURRING_TOTALS');
  END IF;

  EXCEPTION

   WHEN NO_DATA_FOUND THEN
     CLOSE C_rec_charge;
     Null;


END Get_UI_Recurring_Totals;

PROCEDURE GET_MODEL_RECURRING_TOTALS
(
p_header_id         IN  NUMBER,
p_line_id           IN  NUMBER,
p_line_number       IN  NUMBER,
x_rec_charges_tbl   IN OUT NOCOPY OE_OE_TOTALS_SUMMARY.Rec_Charges_Tbl_Type
)
IS

CURSOR C_rec_charge(g_header_id IN NUMBER,p_line_number IN NUMBER) IS
        select distinct nvl(charge_periodicity_code,'ONE')
        from oe_order_lines_all
        where header_id = g_header_id
 --       and charge_periodicity_code is not null
        and line_number  = p_line_number
        order by nvl(charge_periodicity_code,'ONE') desc;

CURSOR C_extended(p_header_id IN NUMBER,p_line_Id IN NUMBER,p_line_Number IN NUMBER,p_code IN VARCHAR2) IS
   SELECT NVL(Ordered_Quantity,0)*
                NVL(unit_selling_price,0) Line_details_total,tax_value,line_category_code
   FROM   oe_order_lines_all
   WHERE  header_id=p_header_id
   AND    nvl(charge_periodicity_code,'ONE')=p_code  -- added abghosh
   AND (line_number=p_line_number
   AND NVL(cancelled_flag,'N') ='N'
   OR (top_model_line_id is not null
   AND top_model_line_id=p_line_id
--   AND charge_periodicity_code=p_code    -- commented abghosh
   AND NVL(cancelled_flag,'N') ='N')
   OR (service_reference_line_id is not null
   AND service_reference_line_id=p_line_id
   AND NVL(cancelled_flag,'N') ='N'));

l_code             VARCHAR2(3);
i                  NUMBER;
x_tax              NUMBER;
rec_tax            Number     :=0;
x_subtotal         NUMBER     :=0;
rec_subtotal       Number     :=0;
x_charges          NUMBER     :=0;
x_line_category_code    VARCHAR2(30);
x_tax_total        NUMBER     :=0;
x_total            NUMBER     :=0;
rec_charges        NUMBER     :=0;
l_line_id          NUMBER;
l_debug_level      CONSTANT NUMBER := Oe_Debug_Pub.g_debug_level;

BEGIN

  IF l_debug_level > 0 THEN
    OE_DEBUG_PUB.ADD('ENTERING OE_OE_TOTALS_SUMMARY.GET_MODEL_RECURRING_TOTALS',1);
    OE_DEBUG_PUB.ADD('INPUTS TO THE API',1);
    OE_DEBUG_PUB.ADD('p_heder_id :'||p_header_id,1);
    OE_DEBUG_PUB.ADD('p_line_id_ :'||p_line_id,1);
    OE_DEBUG_PUB.ADD('p_line_number :'||p_line_number,1);
  END IF;

  i := 1;
  OPEN  C_rec_charge(p_header_id,p_line_number);
  LOOP
     FETCH C_rec_charge INTO l_code;
     EXIT WHEN C_rec_charge%NOTFOUND;

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.ADD('INSIDE OUTER LOOP FOR PERIODICITY_CODE :'||l_code,1);
     END IF;

      x_rec_charges_tbl(i).charge_periodicity_code := l_code;
      IF (l_code <> 'ONE') THEN
      x_rec_charges_tbl(i).charge_periodicity_meaning := OE_ID_TO_VALUE.Charge_Periodicity(l_code);
      END IF;
      OPEN  C_extended(p_header_id,p_line_id,p_line_number,l_code);

      LOOP-- inner loop added abghosh

      FETCH c_extended  into x_subtotal,x_tax,x_line_category_code;
      EXIT WHEN C_extended%NOTFOUND;
      IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.ADD('INSIDE INNER LOOP FOR PERIODICITY_CODE :'||l_code,1);
      END IF;
      IF x_line_category_code <> 'RETURN' THEN
        x_total:=x_total+x_subtotal;
        x_tax_total:=x_tax_total+x_tax;
      ELSIF x_line_category_code='RETURN' THEN
        x_total:=x_total-x_subtotal;
        x_tax_total:=x_tax_total-x_tax;
      END IF;

      END LOOP;
      CLOSE C_Extended;

     SELECT SUM(ROUND(
                DECODE(P.CREDIT_OR_CHARGE_FLAG,'C',
                        DECODE(P.ARITHMETIC_OPERATOR, 'LUMPSUM',
                               DECODE(L.ORDERED_QUANTITY,0,0,-P.OPERAND),
                               (-L.ORDERED_QUANTITY* nvl(P.ADJUSTED_AMOUNT,0))),
                        DECODE(P.ARITHMETIC_OPERATOR, 'LUMPSUM',
                               DECODE(L.ORDERED_QUANTITY,0,0,P.OPERAND),
                               (L.ORDERED_QUANTITY* nvl(P.ADJUSTED_AMOUNT,0)))
                       )
                  ,OE_ORDER_UTIL.G_Precision)
                 )
      INTO x_charges
      FROM OE_PRICE_ADJUSTMENTS P,
           OE_ORDER_LINES_ALL L
      WHERE P.HEADER_ID = p_header_id
      AND   P.LINE_ID = L.LINE_ID
      AND   nvl(L.CHARGE_PERIODICITY_CODE,'ONE') = l_code
      AND   P.LIST_LINE_TYPE_CODE = 'FREIGHT_CHARGE'
      AND   P.APPLIED_FLAG = 'Y'
      AND (l.line_number=p_line_number
      AND NVL(l.cancelled_flag,'N') ='N'
      OR (l.top_model_line_id is not null
      AND l.top_model_line_id=p_line_id
      AND NVL(l.cancelled_flag,'N') ='N')
      OR (l.service_reference_line_id is not null
      AND l.service_reference_line_id=p_line_id
      AND NVL(l.cancelled_flag,'N') ='N'));

      rec_tax:=rec_tax+nvl(x_tax_total,0);  -- 3 lines added abghosh summing up
      rec_charges:=rec_charges+nvl(x_charges,0);
      rec_subtotal:=rec_subtotal+x_total;


     x_rec_charges_tbl(i).rec_tax := rec_tax; -- adding in table added abghosh
     x_rec_charges_tbl(i).rec_subtotal := rec_subtotal;
     x_rec_charges_tbl(i).rec_charges := rec_charges;
     x_rec_charges_tbl(i).rec_total := rec_subtotal + rec_tax + rec_charges;

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.ADD('TOTALS  FOR PERIODICITY_CODE :'||l_code,1);
        OE_DEBUG_PUB.ADD('TAX :'||rec_tax,1);
        OE_DEBUG_PUB.ADD('SUBTOTAL :'||rec_subtotal,1);
        OE_DEBUG_PUB.ADD('CHARGES :'||rec_charges,1);
     END IF;

     i:=i+1;  -- increment counter added abghosh


     rec_subtotal:=0;  -- reset after one group of periodicity added abghosh
     rec_charges:=0;
     rec_tax:=0;
     x_total:=0;
     x_tax_total:=0;
     x_charges:=0;

 END LOOP;
CLOSE C_rec_charge;

IF l_debug_level > 0 THEN
    OE_DEBUG_PUB.ADD('EXITING OE_OE_TOTALS_SUMMARY.GET_MODEL_RECURRING_TOTALS',1);
END IF;

END Get_Model_Recurring_Totals;

/* Recurring Charges */

--rc pviprana start
PROCEDURE SET_ADJ_RECURRING_AMOUNTS
   (p_header_id IN NUMBER DEFAULT NULL,
    p_price_adjustment_id IN NUMBER DEFAULT NULL)
IS

CURSOR c_charge_periodicity(p_header_id IN NUMBER) IS
SELECT DISTINCT charge_periodicity_code
FROM oe_order_lines_all
WHERE header_id = p_header_id
AND charge_periodicity_code is not null
ORDER BY charge_periodicity_code;

l_code VARCHAR2(3);
i PLS_INTEGER;
l_header_id NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('ENTERING OE_OE_TOTALS_SUMMARY.SET_ADJ_RECURRING_AMOUNTS');
   END IF;
   IF p_price_adjustment_id IS NULL THEN
      RETURN;
   ELSE
      IF p_header_id IS NULL THEN
	 BEGIN
	    SELECT header_id INTO l_header_id
	    FROM oe_price_adjustments
	    WHERE price_adjustment_id = p_price_adjustment_id;

	    IF l_header_id IS NULL THEN
	       RETURN;
	    END IF;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF l_debug_level > 0 THEN
		  oe_debug_pub.add('Exception while querying for the adjustment record : ' || SQLERRM);
	       END IF;
	       RETURN;
	 END;
      ELSE
        l_header_id := p_header_id;
      END IF;
   END IF;

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('l_header_id : ' || l_header_id);
      oe_debug_pub.add('p_price_adjustment_id : ' || p_price_adjustment_id);
   END IF;

   G_RECURRING_AMOUNTS_TBL.DELETE;
   i := 1;
   OPEN  c_charge_periodicity(l_header_id);
   LOOP
      FETCH c_charge_periodicity INTO l_code;
      EXIT WHEN c_charge_periodicity%NOTFOUND;
      G_RECURRING_AMOUNTS_TBL(i).charge_periodicity_code := l_code;
      G_RECURRING_AMOUNTS_TBL(i).charge_periodicity_meaning := OE_ID_TO_VALUE.Charge_Periodicity(l_code);
      G_RECURRING_AMOUNTS_TBL(i).recurring_amount := OE_HEADER_ADJ_UTIL.Get_Rec_Order_Adj_Total(l_header_id, p_price_adjustment_id, l_code);

      IF l_debug_level > 0 THEN
	 oe_debug_pub.add('***************************************************************');
	 oe_debug_pub.add('charge_periodicity_code : ' || G_RECURRING_AMOUNTS_TBL(i).charge_periodicity_code);
	 oe_debug_pub.add('charge_periodicity_meaning : ' || G_RECURRING_AMOUNTS_TBL(i).charge_periodicity_meaning);
	 oe_debug_pub.add('recurring amount : ' || G_RECURRING_AMOUNTS_TBL(i).recurring_amount);
	 oe_debug_pub.add('***************************************************************');
      END IF;
      i := i+1;
   END LOOP;
   CLOSE c_charge_periodicity;

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('EXITING OE_OE_TOTALS_SUMMARY.SET_ADJ_RECURRING_AMOUNTS');
   END IF;

END SET_ADJ_RECURRING_AMOUNTS;

PROCEDURE GET_ADJ_RECURRING_AMOUNTS
   (x_recurring_amounts_tbl  IN OUT NOCOPY /* file.sql.39 change */ Recurring_Amounts_Tbl_Type)
IS
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('ENTERING OE_OE_TOTALS_SUMMARY.GET_ADJ_RECURRING_AMOUNTS');
   END IF;

   x_recurring_amounts_tbl := G_RECURRING_AMOUNTS_TBL;

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('EXITING OE_OE_TOTALS_SUMMARY.GET_ADJ_RECURRING_AMOUNTS');
   END IF;
END;

--rc pviprana end

--rc preview/print
FUNCTION PRN_REC_SUBTOTALS
(
 p_header_id               IN      NUMBER,
 p_charge_periodicity_code IN      VARCHAR2
)
RETURN NUMBER
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('ENTERING REC_SUBTOTALS FUNCTION');
        oe_debug_pub.add('Header_id = '||p_header_id );
        oe_debug_pub.add('Charge periodicity code = '||p_charge_periodicity_code );
    END IF;

        OE_OE_TOTALS_SUMMARY.GLOBAL_Rec_TOTALS
         (
             p_header_id                  => p_header_id,
             p_charge_periodicity_code    => p_charge_periodicity_code
         );

	RETURN(G_REC_TOTAL_EXTENDED_PRICE);

EXCEPTION
WHEN too_many_rows THEN
     oe_debug_pub.add('unexpected error : '||sqlerrm,1);
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
WHEN no_data_found THEN
     IF l_debug_level  > 0 THEN
	oe_debug_pub.add('No Data found'||p_header_id,1) ;
     END IF;
WHEN others THEN
     IF l_debug_level  > 0 THEN
	oe_debug_pub.add('Others unexpected error : '||sqlerrm,1);
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END PRN_REC_SUBTOTALS;

FUNCTION PRN_REC_TAXES
(
 p_header_id               IN      NUMBER,
 p_charge_periodicity_code IN      VARCHAR2
)
RETURN NUMBER
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('ENTERING REC_SUBTOTALS FUNCTION');
        oe_debug_pub.add('Header_id = '||p_header_id );
        oe_debug_pub.add('Charge periodicity code = '||p_charge_periodicity_code );
    END IF;

        OE_OE_TOTALS_SUMMARY.GLOBAL_Rec_TOTALS
         (
             p_header_id                  => p_header_id,
             p_charge_periodicity_code    => p_charge_periodicity_code
         );

	RETURN(g_rec_tax_value);

EXCEPTION
WHEN too_many_rows THEN
     oe_debug_pub.add('unexpected error : '||sqlerrm,1);
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
WHEN no_data_found THEN
     IF l_debug_level  > 0 THEN
	oe_debug_pub.add('No Data found'||p_header_id,1) ;
     END IF;
WHEN others THEN
     IF l_debug_level  > 0 THEN
	oe_debug_pub.add('Others unexpected error : '||sqlerrm,1);
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END PRN_REC_TAXES;

FUNCTION PRN_REC_TOTALS
(
 p_header_id               IN      NUMBER,
 p_charge_periodicity_code IN      VARCHAR2
)
RETURN NUMBER
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_taxes NUMBER;
l_subtotals NUMBER;
l_charges NUMBER;

BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('ENTERING REC_TOTALS FUNCTION');
        oe_debug_pub.add('Header_id = '||p_header_id );
        oe_debug_pub.add('Charge periodicity code = '||p_charge_periodicity_code );
    END IF;

        OE_OE_TOTALS_SUMMARY.GLOBAL_Rec_TOTALS
         (
             p_header_id                  => p_header_id,
             p_charge_periodicity_code    => p_charge_periodicity_code
         );

	l_taxes:= g_rec_tax_value;
        l_subtotals :=	G_REC_TOTAL_EXTENDED_PRICE;
	l_charges:= OE_OE_TOTALS_SUMMARY.ReC_charges(p_header_id       => p_header_id,
                          p_charge_periodicity_code         => p_charge_periodicity_code );

	RETURN(l_taxes + l_subtotals + l_charges);

EXCEPTION
WHEN too_many_rows THEN
     oe_debug_pub.add('unexpected error : '||sqlerrm,1);
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
WHEN no_data_found THEN
     IF l_debug_level  > 0 THEN
	oe_debug_pub.add('No Data found'||p_header_id,1) ;
     END IF;
WHEN others THEN
     IF l_debug_level  > 0 THEN
	oe_debug_pub.add('Others unexpected error : '||sqlerrm,1);
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END PRN_REC_TOTALS;

END OE_OE_TOTALS_SUMMARY;


/
