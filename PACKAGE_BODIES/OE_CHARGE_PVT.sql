--------------------------------------------------------
--  DDL for Package Body OE_CHARGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CHARGE_PVT" AS
/* $Header: OEXVCHRB.pls 120.2 2005/11/02 14:45:11 sdatti ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Charge_PVT';

--  Start of Comments
--  API name    Get_Charge_Amount
--
--  Procedure to get charge totals at Order Line or Order Header level
--  If the header_id is passed and line_id is NULL then total for charges at
--  Order Header level is returned
--  If header_id and line_id is passed then total for charges at Order line
--  level is returned.
--
--  Type        Public
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

 PROCEDURE Get_Charge_Amount
  (   p_api_version_number            IN  NUMBER
  ,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
  ,   p_header_id                     IN  NUMBER
  ,   p_line_id                       IN  NUMBER
  ,   p_all_charges                   IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

, x_charge_amount OUT NOCOPY NUMBER

  )
 IS
 l_api_version_number          CONSTANT NUMBER := 1.0;
 l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Charge_Amount';
 l_charge_amount               NUMBER := 0.0;
 l_hdr_charge_amount               NUMBER := 0.0;
 l_line_charge_amount               NUMBER := 0.0;
 Is_fmt                        BOOLEAN;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
 BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check for Header Id

    IF p_header_id is NULL OR p_header_id = FND_API.G_MISS_NUM THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','header');
            OE_MSG_PUB.Add;

        END IF;
        RAISE FND_API.G_EXC_ERROR;

    END IF;

    IF  NVL(p_header_id,-1)<>NVL(OE_ORDER_UTIL.G_Header_id,-10)
    OR  OE_ORDER_UTIL.G_Precision IS NULL THEN
      Is_fmt:=   OE_ORDER_UTIL.Get_Precision(
                p_header_id=>p_header_id
               );
    END IF;

    IF OE_ORDER_UTIL.G_Precision IS NULL THEN
      OE_ORDER_UTIL.G_Precision:=2;
    END IF;



    -- Check the operation whether all charges for the Order are required
    IF p_all_charges = FND_API.G_TRUE THEN
    -- Getting Order Total charge amount.

      -- bug 4060810, improve performance of SQL, with fix for bug 2785662
      SELECT SUM(nvl(ROUND(
              DECODE(P.CREDIT_OR_CHARGE_FLAG,'C',-1,1) *
              DECODE(P.LINE_ID, NULL,
                P.OPERAND,
                DECODE(P.ARITHMETIC_OPERATOR, 'LUMPSUM',
                  DECODE(L.ORDERED_QUANTITY,0,0,NULL,NULL,P.OPERAND),
                  L.ORDERED_QUANTITY* nvl(P.ADJUSTED_AMOUNT,0)))
                 ,OE_ORDER_UTIL.G_Precision),0))
     INTO l_charge_amount
     FROM OE_PRICE_ADJUSTMENTS P,
          OE_ORDER_LINES_ALL L
     WHERE P.HEADER_ID = p_header_id
     AND   P.LINE_ID = L.LINE_ID(+)
     AND   P.LIST_LINE_TYPE_CODE = 'FREIGHT_CHARGE'
     AND   L.charge_periodicity_code(+) IS NULL -- added for recurring charge
     AND   P.APPLIED_FLAG = 'Y';

      /*
        SELECT SUM(CHARGE_AMOUNT)
        INTO l_charge_amount
        FROM OE_CHARGE_LINES_V
        WHERE header_id = p_header_id;
      */


    -- If the line_id is NULL and Header_id is not null then header
    -- level charges are required.

    ELSIF p_line_id is NULL OR p_line_id = FND_API.G_MISS_NUM THEN

    -- Getting Header level charge amount.

      SELECT SUM(ROUND(
                DECODE(P.CREDIT_OR_CHARGE_FLAG,'C',-P.OPERAND,P.OPERAND)
                ,OE_ORDER_UTIL.G_Precision)
                )
      INTO l_charge_amount
      FROM OE_PRICE_ADJUSTMENTS P
      WHERE P.HEADER_ID = p_header_id
      AND   P.LINE_ID IS NULL
      AND   P.LIST_LINE_TYPE_CODE = 'FREIGHT_CHARGE'
      AND   P.APPLIED_FLAG = 'Y';

/*
        SELECT SUM(CHARGE_AMOUNT)
        INTO l_charge_amount
        FROM OE_CHARGE_LINES_V
        WHERE header_id = p_header_id
        AND line_id IS NULL;
*/

    ELSE

    -- Getting Line level charge amount.

   SELECT SUM(ROUND(
                DECODE(P.CREDIT_OR_CHARGE_FLAG,'C', -1, 1) *
                        DECODE(P.ARITHMETIC_OPERATOR, 'LUMPSUM',
                               DECODE(L.ORDERED_QUANTITY,0,0,P.OPERAND),
                               (L.ORDERED_QUANTITY* nvl(P.ADJUSTED_AMOUNT,0)))
                  ,OE_ORDER_UTIL.G_Precision)
                 )
      INTO l_charge_amount
     FROM OE_PRICE_ADJUSTMENTS P,
          OE_ORDER_LINES_ALL L
     WHERE P.HEADER_ID = p_header_id
     AND   P.LINE_ID = p_line_id
     AND   P.LINE_ID = L.LINE_ID
     AND   P.LIST_LINE_TYPE_CODE = 'FREIGHT_CHARGE'
     AND   P.APPLIED_FLAG = 'Y';

/*
        SELECT SUM(CHARGE_AMOUNT)
        INTO l_charge_amount
        FROM OE_CHARGE_LINES_V
        WHERE header_id = p_header_id
        AND line_id = p_line_id;
*/

    END IF;
    IF l_charge_amount IS NULL THEN
	 l_charge_amount := 0.0;
    END IF;
    x_charge_amount := l_charge_amount;
 EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        -- Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count  => x_msg_count
        ,   p_data   => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Charge_Amount'
            );
        END IF;

        -- Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count  => x_msg_count
        ,   p_data   => x_msg_data
        );

 END Get_Charge_Amount;

--  Start of Comments
--  Function name    Get_Cost_Amount
--
--  Function to source the Pricing Attributes for COST_AMOUNTS.
--  (E.g. INSURANCE_COST, HANDLING_COST, DUTY_COST, EXPORT_COST)
--  If the Order line is Shippable and shipping has transferred all costs for
--  this line, then this function takes the cost_type_code as an input and finds
--  the cost amount for this cost_type_code from OE_PRICE_ADJUSTMENTS table.
--
--  Type        Private
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

 FUNCTION Get_Cost_Amount
 (   p_cost_type_code                IN  VARCHAR2
 )RETURN VARCHAR2
 IS
 l_api_version_number          CONSTANT NUMBER := 1.0;
 l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Cost_Amount';
 l_line_rec                    OE_Order_PUB.Line_Rec_Type;
 l_cost_amount                 NUMBER := 0.0;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
 BEGIN

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'CHARGES:INSIDE GET COST AMOUNT FOR' || P_COST_TYPE_CODE , 1 ) ;
 END IF;

    -- Get the Line record from the Global Record
    l_line_rec := OE_ORDER_PUB.G_LINE;

    -- Validate the Line_id.

    IF l_line_rec.line_id is NULL OR l_line_rec.line_id = FND_API.G_MISS_NUM
    THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'L_LINE_REC.LINE_ID IS NULL OR L_LINE_REC.LINE_ID IS FND_API.G_MISS_NUM' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING CHARGES' ) ;
        END IF;
        RETURN NULL;
    END IF;

    -- Check for values of cost_type_code

    IF p_cost_type_code is NULL OR p_cost_type_code = FND_API.G_MISS_CHAR THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'P_COST_TYPE_CODE IS NULL OR P_COST_TYPE_CODE IS FND_API.G_MISS_CHAR' ) ;
       END IF;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'EXITING CHARGES' ) ;
       END IF;
       RETURN NULL;
    END IF;

    -- Check for Pricing Quantity

    IF l_line_rec.pricing_quantity IS NULL OR
	  l_line_rec.pricing_quantity = FND_API.G_MISS_NUM OR
	  l_line_rec.pricing_quantity <= 0 THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'L_LINE_REC.PRICING_QUANTITY = FND_API.G_MISS_NUM OR _LINE_REC.PRICING_QUANTITY <= 0' ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EXITING CHARGES' ) ;
          END IF;
	  RETURN NULL;
    END IF;

    -- Check whether the line is shippable and has got shipped

    IF l_line_rec.shippable_flag = 'Y' AND
	  l_line_rec.shipped_quantity > 0 THEN

       -- Cost records are stored in OE_PRICE_ADJUSTMENTS table with
	  -- list_line_type_code = 'COST'
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LINE IS SHIPPABLE AND IS SHIPPED' ) ;
       END IF;
       SELECT SUM(ADJUSTED_AMOUNT)
	  INTO l_cost_amount
	  FROM OE_PRICE_ADJUSTMENTS_V
	  WHERE LINE_ID = l_line_rec.line_id
	  AND LIST_LINE_TYPE_CODE = 'COST'
	  AND CHARGE_TYPE_CODE = p_cost_type_code;

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'AFTER GETTING COST AMOUNT ' || TO_CHAR ( L_COST_AMOUNT ) , 1 ) ;
 END IF;

       RETURN FND_NUMBER.NUMBER_TO_CANONICAL(l_cost_amount);
    ELSE
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'LINE NOT SHIPPABLE OR IS NOT SHIPPED' ) ;
           END IF;
	   RETURN NULL;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LEAVING CHARGES' ) ;
    END IF;
 EXCEPTION

    WHEN NO_DATA_FOUND THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'NO COST INFORMATION FOUND IN OE_PRICE_ADJUSTMENTS' ) ;
           END IF;
	   RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Cost_Amount'
            );
        END IF;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'UNEXCPETED ERRORS:'||SQLERRM ) ;
           END IF;
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END Get_Cost_Amount;

--  Start of Comments
--  Function name    Get_Cost_Types
--
--  Function to source the Qualifier Attribute FREIGHT_COST_TYPE
--  If the Order line is Shippable and shipping has transferred all costs for
--  this line, then this function finds and returns all cost_type_codes from
--  OE_PRICE_ADJUSTMENTS table where costs are maintained. It returns a table of
--  VARCHAR2 as output.
--
--  Type        Private
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

 FUNCTION Get_Cost_Types
 RETURN QP_Attr_Mapping_PUB.t_MultiRecord
 IS
 l_api_name            CONSTANT VARCHAR2(30):= 'Get_Cost_Types';
 l_cost_tbl            QP_Attr_Mapping_PUB.t_MultiRecord;
 l_cost_type_code      VARCHAR2(30) := NULL;
 l_count               NUMBER := 0;
 l_line_rec            OE_Order_PUB.Line_Rec_Type;
 Cursor C_Get_Cost_Types(p_line_id NUMBER) IS
	SELECT DISTINCT CHARGE_TYPE_CODE
	FROM OE_PRICE_ADJUSTMENTS_V
	WHERE LINE_ID = p_line_id
	AND LIST_LINE_TYPE_CODE = 'COST';
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
 BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INSIDE GET COST TYPE' , 1 ) ;
    END IF;
    -- Get the Line record from the Global Record
    l_line_rec := OE_ORDER_PUB.G_LINE;

    IF l_line_rec.line_id is NULL OR l_line_rec.line_id = FND_API.G_MISS_NUM
    THEN
        RETURN l_cost_tbl;
    END IF;

    IF l_line_rec.shippable_flag = 'Y' AND
	  l_line_rec.shipped_quantity > 0
    THEN
        l_count := 1;
	   OPEN C_Get_Cost_Types(l_line_rec.line_id);
	   LOOP
		  FETCH C_Get_Cost_Types INTO l_cost_tbl(l_count);
		  EXIT WHEN C_Get_Cost_Types%NOTFOUND;
		  l_count := l_count + 1;
        END LOOP;

	   CLOSE C_Get_Cost_Types;

        IF l_cost_tbl.COUNT > 0 THEN
		 l_count := l_cost_tbl.FIRST;
		 WHILE l_count IS NOT NULL LOOP
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'COST TYPES ARE'|| L_COST_TBL ( L_COUNT ) , 3 ) ;
               END IF;
			l_count := l_cost_tbl.NEXT(l_count);
		 END LOOP;
        END IF;

    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER GETTING COST TYPE SUCCESSFULLY' , 1 ) ;
    END IF;

    RETURN l_cost_tbl;

 EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Cost_Types'
            );
        END IF;
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

 END Get_Cost_Types;

--  Start of Comments
--  Function name    Get_Shipped_Status
--
--  This function will be used to source the Qualifier Attribute "SHIPPED_FLAG"
--
--  Type        Private
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

 FUNCTION Get_Shipped_status
 RETURN VARCHAR2
 IS
 l_api_name            CONSTANT VARCHAR2(30):= 'Get_Shipped_Status';
 l_result              VARCHAR2(1) := 'N';
 l_line_rec            OE_Order_PUB.Line_Rec_Type;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
 BEGIN

    -- Get the Line record from the Global Record
    l_line_rec := OE_ORDER_PUB.G_LINE;

    IF l_line_rec.shippable_flag = 'Y'AND
	  l_line_rec.shipped_quantity > 0
    THEN
        l_result := 'Y';
    END IF;
    RETURN l_result;

 EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Shipped_Status'
            );
        END IF;
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END Get_Shipped_Status;

PROCEDURE Check_Duplicate_Line_Charges
(
   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type
 , p_x_line_adj_tbl                IN OUT NOCOPY OE_Order_PUB.Line_Adj_Tbl_Type
 , p_x_line_adj_att_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Tbl_Type
)

IS
l_line_adj_tbl     OE_Order_PUB.Line_Adj_Tbl_Type := p_x_line_adj_tbl;
l_line_adj_att_tbl OE_Order_PUB.Line_Adj_Att_Tbl_Type := p_x_line_adj_att_tbl;
l_line_index       NUMBER := 0;
l_charge_index     NUMBER := 0;
l_tmp_index        NUMBER := 0;
l_att_index        NUMBER := 0;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    l_line_index := p_line_tbl.FIRST;
    WHILE l_line_index IS NOT NULL LOOP

	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'THE LINE RECORD IS ' || TO_CHAR ( L_LINE_INDEX ) ) ;
	     END IF;
	 l_charge_index := l_Line_Adj_Tbl.FIRST;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'THE ADJ LINE RECORD IS ' || TO_CHAR ( L_CHARGE_INDEX ) ) ;
     END IF;

	 WHILE l_charge_index IS NOT NULL LOOP

	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'THE ALL CHARGE TYPE IS ' || L_LINE_ADJ_TBL ( L_CHARGE_INDEX ) .CHARGE_TYPE_CODE ) ;
	     END IF;
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'THE ALL OPERATION IS ' || L_LINE_ADJ_TBL ( L_CHARGE_INDEX ) .OPERATION ) ;
	     END IF;
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'THE ALL ADJUSTED_AMOUNT IS ' ||TO_CHAR ( L_LINE_ADJ_TBL ( L_CHARGE_INDEX ) .ADJUSTED_AMOUNT ) ) ;
	     END IF;
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'THE ALL APPLIED_FLAG IS ' || L_LINE_ADJ_TBL ( L_CHARGE_INDEX ) .APPLIED_FLAG ) ;
	     END IF;
	   IF l_line_adj_tbl(l_charge_index).list_line_type_code = 'FREIGHT_CHARGE'
	   AND NVL(l_line_adj_tbl(l_charge_index).applied_flag,'N') = 'Y'
	   AND l_line_adj_tbl(l_charge_index).operation IN
	       (OE_GLOBALS.G_OPR_UPDATE, OE_GLOBALS.G_OPR_CREATE)
        AND l_line_adj_tbl(l_charge_index).line_id =
		  p_line_tbl(l_line_index).line_id
	   THEN

	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'THE SELECTED CHARGE TYPE IS ' || L_LINE_ADJ_TBL ( L_CHARGE_INDEX ) .CHARGE_TYPE_CODE ) ;
	     END IF;
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'THE SELECTED OPERATION IS ' || L_LINE_ADJ_TBL ( L_CHARGE_INDEX ) .OPERATION ) ;
	     END IF;
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'THE SELECTED ADJUSTED_AMOUNT IS ' ||TO_CHAR ( L_LINE_ADJ_TBL ( L_CHARGE_INDEX ) .ADJUSTED_AMOUNT ) ) ;
	     END IF;
		l_tmp_index := l_line_adj_tbl.FIRST;
		WHILE l_tmp_index IS NOT NULL LOOP

		  IF l_tmp_index <> l_charge_index
		  AND  l_line_adj_tbl(l_tmp_index).operation IN
	          (OE_GLOBALS.G_OPR_UPDATE, OE_GLOBALS.G_OPR_CREATE)
		  AND  l_line_adj_tbl(l_tmp_index).list_line_type_code
			  = 'FREIGHT_CHARGE'
	       AND NVL(l_line_adj_tbl(l_tmp_index).applied_flag,'N') = 'Y'
            AND l_line_adj_tbl(l_charge_index).charge_type_code
			  = l_line_adj_tbl(l_tmp_index).charge_type_code
		  AND NVL(l_line_adj_tbl(l_charge_index).charge_subtype_code,'SUB') =
			 NVL(l_line_adj_tbl(l_tmp_index).charge_subtype_code,'SUB')
            THEN

	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'THE MATCHING CHARGE TYPE IS ' || L_LINE_ADJ_TBL ( L_TMP_INDEX ) .CHARGE_TYPE_CODE ) ;
	     END IF;
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'THE MATCHING OPERATION IS ' || L_LINE_ADJ_TBL ( L_TMP_INDEX ) .OPERATION ) ;
	     END IF;
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'THE MATCHING ADJUSTED_AMOUNT IS ' ||TO_CHAR ( L_LINE_ADJ_TBL ( L_TMP_INDEX ) .ADJUSTED_AMOUNT ) ) ;
	     END IF;
			 IF l_line_adj_tbl(l_tmp_index).adjusted_amount >=
			    l_line_adj_tbl(l_charge_index).adjusted_amount
                THEN
				IF l_line_adj_tbl(l_charge_index).operation =
				   OE_GLOBALS.G_OPR_UPDATE
				THEN
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'THE SELECTED OPERATION IS SET TO DELETE' ) ;
	     END IF;
                        l_line_adj_tbl(l_charge_index).operation :=
					OE_GLOBALS.G_OPR_DELETE;
                    ELSE
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'THE SELECTED OPERATION IS SET TO NONE' ) ;
	     END IF;
                        l_line_adj_tbl(l_charge_index).operation :=
					OE_GLOBALS.G_OPR_NONE;
                    END IF;
				EXIT;
                END IF;

		  END IF;
		  l_tmp_index := l_line_adj_tbl.NEXT(l_tmp_index);

		END LOOP;  /* For local temp loop */

          IF p_x_line_adj_tbl(l_charge_index).operation <>
             l_line_adj_tbl(l_charge_index).operation
		THEN

            l_att_index := l_line_adj_att_tbl.FIRST;
		  WHILE l_att_index IS NOT NULL LOOP

			IF l_line_adj_att_tbl(l_att_index).operation =
			   OE_GLOBALS.G_OPR_UPDATE
			AND l_line_adj_tbl(l_charge_index).price_adjustment_id =
			    l_line_adj_att_tbl(l_att_index).price_adjustment_id
			THEN

                   l_line_adj_att_tbl(l_att_index).operation :=
						OE_GLOBALS.G_OPR_DELETE;

               ELSIF l_line_adj_att_tbl(l_att_index).operation =
				 OE_GLOBALS.G_OPR_CREATE
               AND l_charge_index = l_line_adj_att_tbl(l_att_index).adj_index
			THEN

                   l_line_adj_att_tbl(l_att_index).operation :=
						OE_GLOBALS.G_OPR_NONE;

               END IF;

               l_att_index := l_line_adj_att_tbl.NEXT(l_att_index);
		  END LOOP; /* For Line Adj Att table */

	     END IF;
		IF l_line_adj_tbl(l_charge_index).operation = OE_GLOBALS.G_OPR_NONE
		THEN
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'THE DELETING CHARGE TYPE IS ' || L_LINE_ADJ_TBL ( L_CHARGE_INDEX ) .CHARGE_TYPE_CODE ) ;
	     END IF;
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'THE DELETING OPERATION IS ' || L_LINE_ADJ_TBL ( L_CHARGE_INDEX ) .OPERATION ) ;
	     END IF;
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'THE DELETING ADJUSTED_AMOUNT IS ' ||TO_CHAR ( L_LINE_ADJ_TBL ( L_CHARGE_INDEX ) .ADJUSTED_AMOUNT ) ) ;
	     END IF;
		    l_line_adj_tbl.delete(l_charge_index);
		END IF;

        END IF;
	   l_charge_index := l_Line_Adj_Tbl.NEXT(l_charge_index);

	 END LOOP; /* For Line Adj table */

	 l_line_index := p_Line_Tbl.NEXT(l_line_index);

    END LOOP;   /* For Line Tbl */
    p_x_line_adj_tbl := l_line_adj_tbl;
    p_x_line_adj_att_tbl := l_line_adj_att_tbl;

END Check_Duplicate_Line_Charges;



PROCEDURE Check_Duplicate_Header_Charges
(
   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
 , p_x_Header_adj_tbl              IN OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type
 , p_x_Header_adj_att_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Adj_Att_Tbl_Type
)

IS
l_Header_adj_tbl     OE_Order_PUB.Header_Adj_Tbl_Type := p_x_Header_adj_tbl;
l_Header_adj_att_tbl OE_Order_PUB.Header_Adj_Att_Tbl_Type := p_x_Header_adj_att_tbl;
l_Header_id        NUMBER := 0;
l_charge_index     NUMBER := 0;
l_tmp_index        NUMBER := 0;
l_att_index        NUMBER := 0;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    l_Header_id := p_Header_rec.header_id;

    l_charge_index := l_Header_Adj_Tbl.FIRST;

    WHILE l_charge_index IS NOT NULL LOOP

      IF l_Header_adj_tbl(l_charge_index).list_line_type_code = 'FREIGHT_CHARGE'
	   AND NVL(l_Header_adj_tbl(l_charge_index).applied_flag,'N') = 'Y'
	   AND l_Header_adj_tbl(l_charge_index).operation IN
	       (OE_GLOBALS.G_OPR_UPDATE, OE_GLOBALS.G_OPR_CREATE)
        AND l_Header_adj_tbl(l_charge_index).Header_id = l_header_id
        AND (l_Header_adj_tbl(l_charge_index).line_id IS NULL OR
             l_Header_adj_tbl(l_charge_index).line_id = FND_API.G_MISS_NUM)
	 THEN

		l_tmp_index := l_Header_adj_tbl.FIRST;
		WHILE l_tmp_index IS NOT NULL LOOP

		  IF l_tmp_index <> l_charge_index
		  AND  l_Header_adj_tbl(l_tmp_index).operation IN
	          (OE_GLOBALS.G_OPR_UPDATE, OE_GLOBALS.G_OPR_CREATE)
		  AND  l_Header_adj_tbl(l_tmp_index).list_Line_type_code
			  = 'FREIGHT_CHARGE'
	       AND NVL(l_Header_adj_tbl(l_tmp_index).applied_flag,'N') = 'Y'
            AND l_Header_adj_tbl(l_charge_index).charge_type_code
			  = l_Header_adj_tbl(l_tmp_index).charge_type_code
		  AND NVL(l_Header_adj_tbl(l_charge_index).charge_subtype_code,'SUB')
		      = NVL(l_Header_adj_tbl(l_tmp_index).charge_subtype_code,'SUB')
            THEN

			 IF l_Header_adj_tbl(l_tmp_index).adjusted_amount >=
			    l_Header_adj_tbl(l_charge_index).adjusted_amount
                THEN
				IF l_Header_adj_tbl(l_charge_index).operation =
				   OE_GLOBALS.G_OPR_UPDATE
				THEN
                        l_Header_adj_tbl(l_charge_index).operation :=
					OE_GLOBALS.G_OPR_DELETE;
                    ELSE
                        l_Header_adj_tbl(l_charge_index).operation :=
					OE_GLOBALS.G_OPR_NONE;
                    END IF;
				EXIT;
                END IF;

		  END IF;
		  l_tmp_index := l_Header_adj_tbl.NEXT(l_tmp_index);

		END LOOP;  /* For local temp loop */

          IF p_x_Header_adj_tbl(l_charge_index).operation <>
             l_Header_adj_tbl(l_charge_index).operation
		THEN

            l_att_index := l_Header_adj_att_tbl.FIRST;
		  WHILE l_att_index IS NOT NULL LOOP

			IF l_Header_adj_att_tbl(l_att_index).operation =
			   OE_GLOBALS.G_OPR_UPDATE
			AND l_Header_adj_tbl(l_charge_index).price_adjustment_id =
			    l_Header_adj_att_tbl(l_att_index).price_adjustment_id
			THEN

                   l_Header_adj_att_tbl(l_att_index).operation :=
						OE_GLOBALS.G_OPR_DELETE;

               ELSIF l_Header_adj_att_tbl(l_att_index).operation =
				 OE_GLOBALS.G_OPR_CREATE
               AND l_charge_index = l_Header_adj_att_tbl(l_att_index).adj_index
			THEN

                   l_Header_adj_att_tbl(l_att_index).operation :=
						OE_GLOBALS.G_OPR_NONE;

               END IF;

               l_att_index := l_Header_adj_att_tbl.NEXT(l_att_index);
		  END LOOP; /* For Header Adj Att table */

	     END IF;

        END IF;
	   l_charge_index := l_Header_Adj_Tbl.NEXT(l_charge_index);

    END LOOP; /* For Header Adj table */

    p_x_Header_adj_tbl := l_Header_adj_tbl;
    p_x_Header_adj_att_tbl := l_Header_adj_att_tbl;

END Check_Duplicate_Header_Charges;

-- This procedure will be used in Process Order API to check if any duplicate
-- charges exists on a Order Header or a Line before applying any charge.

PROCEDURE Check_Duplicate_Charges
(
   p_Header_id              IN  NUMBER
 , p_line_id                IN  NUMBER
 , p_charge_type_code       IN  VARCHAR2
 , p_charge_subtype_code    IN  VARCHAR2
, x_duplicate_flag OUT NOCOPY VARCHAR2

  )
IS
l_Line_Adj_Tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_Header_Adj_Tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_duplicate_flag            VARCHAR2(1) := 'N';
l_count                     NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF p_header_id IS NULL OR p_header_id = FND_API.G_MISS_NUM THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','header');
            OE_MSG_PUB.Add;

        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF p_line_id IS NULL OR p_line_id = FND_API.G_MISS_NUM THEN

--        l_Header_Adj_Tbl := OE_Header_Adj_Util.query_rows(
--								 p_header_id => p_header_id);

		OE_Header_Adj_Util.Query_Rows( p_header_id => p_header_id,
								 x_header_adj_tbl => l_header_adj_tbl);
        IF l_Header_Adj_Tbl.COUNT > 0 THEN
            l_count := l_Header_Adj_Tbl.FIRST;
	       WHILE l_count IS NOT NULL LOOP

	         IF l_Header_Adj_Tbl(l_count).charge_type_code = p_charge_type_code
			 AND l_Header_Adj_Tbl(l_count).list_line_type_code =
				'FREIGHT_CHARGE'
	           AND NVL(l_Header_Adj_Tbl(l_count).charge_subtype_code,'SUB') =
		          NVL(p_charge_subtype_code,'SUB')
			 AND l_Header_Adj_Tbl(l_count).applied_flag = 'Y' THEN

                  l_duplicate_flag := 'Y';
		        EXIT;
	         END IF;

	       END LOOP;

        END IF;

    ELSE
--        l_Line_Adj_Tbl := OE_Line_Adj_Util.query_rows( p_line_id => p_line_id);
        OE_Line_Adj_Util.Query_Rows(p_line_id => p_line_id,
							 x_line_adj_tbl => l_line_adj_tbl);

        IF l_Line_Adj_Tbl.COUNT > 0 THEN
            l_count := l_Line_Adj_Tbl.FIRST;
	       WHILE l_count IS NOT NULL LOOP

	           IF l_Line_Adj_Tbl(l_count).charge_type_code = p_charge_type_code
			 AND l_Line_Adj_Tbl(l_count).list_line_type_code =
				'FREIGHT_CHARGE'
	           AND NVL(l_Line_Adj_Tbl(l_count).charge_subtype_code,'SUB') =
		          NVL(p_charge_subtype_code,'SUB')
			 AND l_Header_Adj_Tbl(l_count).applied_flag = 'Y' THEN

                    l_duplicate_flag := 'Y';
		          EXIT;
	           END IF;

	       END LOOP;

        END IF;
    END IF;
    x_duplicate_flag := l_duplicate_flag;
EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_duplicate_flag := l_duplicate_flag;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_Duplicate_Charges'
            );
        END IF;
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Check_Duplicate_Charges;


--  Start of Comments
--  Function name    Get_Line_Weight_Or_Volume
--
--  This function will be used to source the qualifier attributes LINE_WEIGHT
--  and LINE_VOLUME. It will lookup at the following profile options to get the
--  target UOM for weight and volume. QP: Line Volume UOM Code and
--  QP: Line Weight UOM Code. Then the procedure will call the conversion
--  routine to get the values.
--
--  Type        Private
--
--  Pre-reqs
--
--  Parameters
--  p_uom_class    IN   VARCHAR2   possible values are 'WEIGHT' or 'VOLUME'
--
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

FUNCTION Get_Line_Weight_Or_Volume
(   p_uom_class      IN  VARCHAR2)
RETURN VARCHAR2
IS
    l_line_rec            OE_Order_PUB.Line_Rec_Type;
    l_uom_code            VARCHAR2(3);
    l_uom_rate            NUMBER;
    --
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --
BEGIN

    IF p_uom_class NOT IN ('Weight','Volume')
    THEN
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'INVALIDE PARAMETER' || P_UOM_CLASS ) ;
	   END IF;
        RETURN NULL;
    END IF;

    -- Get the Line record from the Global Record
    l_line_rec := OE_ORDER_PUB.G_LINE;

    IF p_uom_class = 'Weight' THEN
	   l_uom_code := FND_PROFILE.VALUE('QP_LINE_WEIGHT_UOM_CODE');
    ELSE
	   l_uom_code := FND_PROFILE.VALUE('QP_LINE_VOLUME_UOM_CODE');
    END IF;

    IF l_uom_code IS NULL THEN
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'NO VALUE SET IN THE PROFILE OPTIONS.' ) ;
	   END IF;
	   RETURN NULL;
    END IF;
    INV_CONVERT.INV_UM_CONVERSION(l_line_rec.order_quantity_uom,
                                  l_uom_code,
						    l_line_rec.inventory_item_id,
						    l_uom_rate);
    IF l_uom_rate > 0 THEN
	  RETURN FND_NUMBER.NUMBER_TO_CANONICAL(TRUNC(l_uom_rate * l_line_rec.ordered_quantity, 2));
    ELSE
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'NO CONVERSION INFORMATION IS AVAILABLE FOR CONVERTING FROM ' || L_LINE_REC.ORDER_QUANTITY_UOM || ' TO ' || L_UOM_CODE ) ;
	   END IF;
        RETURN NULL;
    END IF;
END Get_Line_Weight_Or_Volume;

Procedure Freight_Debug(p_header_name  In Varchar2 default null,
                                          p_list_line_id In Number   default null,
                                          p_line_id      In Number,
                                          p_org_id       In Number)
As
l_list_header_id   Number;
l_list_header_name Varchar2(250);
l_pricing_phase_id Number;
l_list_line_id     Number;
l_line_rec         Oe_Order_Pub.Line_Rec_Type;
l_freeze_override_flag Varchar2(1);
l_cost_type_code   Varchar2(30);
l_cost_amount      Number;
l_pricing_contexts_tbl         QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
l_qualifier_contexts_Tbl      QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
l_found boolean default false;
l_dummy Varchar2(30);
j Number;

Cursor list_line_info1 is
select b.list_header_id,
       b.list_line_id,
       b.list_line_type_code,
       b.start_date_active,
       b.end_date_active,
       b.modifier_level_code,
       b.pricing_phase_id,
       b.incompatibility_grp_code,
       b.price_break_type_code,
       b.operand,
       b.arithmetic_operator,
       b.qualification_ind,
       b.product_precedence
from qp_list_headers_vl a,
     qp_list_lines b
where a.name = p_header_name
and   a.list_header_id = b.list_header_id;

Cursor list_line_info2 is
select b.list_header_id,
       b.list_line_id,
       b.list_line_type_code,
       b.start_date_active,
       b.end_date_active,
       b.modifier_level_code,
       b.pricing_phase_id,
       b.incompatibility_grp_code,
       b.price_break_type_code,
       b.operand,
       b.arithmetic_operator,
       b.qualification_ind,
       b.product_precedence
From qp_list_lines b
where list_line_id = p_list_line_id;

Cursor pricing_attribute_info Is
select  list_line_id
	 , list_header_id
	 , pricing_phase_id
	 , product_attribute_context
	 , product_attribute
	 , product_attr_value
	 , product_uom_code
	 , comparison_operator_code
	 , pricing_attribute_context
	 , pricing_attribute
	 , pricing_attr_value_from
	 , pricing_attr_value_to
	 , attribute_grouping_no
	 , qualification_ind
	 , excluder_flag
from  qp_pricing_attributes
where list_line_id = p_list_line_id;

/*select dl.delivery_id,
       pa.line_id,
       pa.cost_id,
       pa.list_line_type_code,
       pa.adjusted_amount,
       pa.operand
from oe_price_adjustments pa,
    wsh_delivery_details dd,
    wsh_delivery_assignments da,
    wsh_new_deliveries dl
where dl.name = 'delivery_name'
and dl.delivery_id = da.delivery_id
and da.delivery_detail_id = dd.delivery_detail_id
and dd.source_code = 'OE'
and dd.source_line_id = pa.line_id
and pa.list_line_type_code = 'COST'; */

Cursor Other_Cost is
Select CHARGE_TYPE_CODE,Adjusted_amount
From   oe_price_adjustments
Where  line_id = l_line_rec.line_id
and    list_line_type_code = 'COST';

--Type list_line_info_type list_line_info1%rowtype;
l_list_line_info list_line_info1%rowtype;
l_pricing_attribute_info pricing_attribute_info%rowtype;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  --MOAC Changes
  --dbms_application_info.set_client_info(p_org_id);
  mo_global.set_policy_context('S',p_org_id);
  --MOAC Changes

  --Hardcode it for now, need to revisit this later.
  l_cost_type_code := 'FREIGHT';

  If p_list_line_id is null and p_header_name is null Then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PLEASE ENTER PROVIDE MODIFIER HEADER NAME OR LIST LINE ID' ) ;
    END IF;
    Return;
  End If;

  If p_list_line_id is not null and p_header_name is not null Then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PLEASE ENTER EITHER HEADER NAME OR LIST LINE ID. NOT BOTH' ) ;
    END IF;
    Return;
  End If;

  If p_list_line_id is not null Then
    Begin
     Open list_line_info2;
     Fetch list_line_info2 into l_list_line_info;

    Exception When Others Then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  SQLERRM ) ;
     END IF;
    End;
    Close list_line_info2;
  Elsif p_header_name is not null Then
    Begin
     Open list_line_info1;
     Fetch list_line_info1 into l_list_line_info;

     If list_line_info1%ROWCOUNT > 1 Then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'THIS HEADER HAS MULTIPLE MODIFIERS , PLEASE SPECIFY ONE BY JUST PASSING LIST LINE ID' ) ;
      END IF;
      close list_line_info1;
      Return;
     End If;

   Exception When Others Then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  SQLERRM ) ;
     END IF;
   End;
   close list_line_info1;
  End If;

--check if there is data qp_list_header_phases
--if not this is a pricing bug
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'CHECKING FOR PRICING BUG' ) ;
END IF;
  Begin
    Select list_header_id,
           pricing_phase_id
    Into   l_list_header_id,l_pricing_phase_id
    from   qp_list_header_phases
    where  list_header_id = l_list_line_info.list_header_id;
  Exception
    when no_data_found Then
      --check if it has line level qualifier
      Begin
      Select list_line_id into l_dummy
      From   qp_qualifiers
      Where  list_header_id = l_list_line_info.list_header_id
      and    nvl(list_line_id,-1)   = l_list_line_id
      and    rownum = 1;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  ' ORACLE PRICING BUGS.' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  ' PLEASE APPLY PRICING PATCH 1806021 IF THIS IS AN UPGRADE' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  ' OTHERWISE APPLY 1797603' ) ;
      END IF;

      Exception When no_data_found then null;
      End;
    when too_many_rows Then
      Null;
    when others Then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  SQLERRM ) ;
      END IF;
  End;

--check if the freeze_override_flag set to Y
Begin
  select a.freeze_override_flag
  into l_freeze_override_flag
  from qp_pricing_phases a, qp_event_phases b
  where a.pricing_phase_id = b.pricing_phase_id
        and b.pricing_event_code='SHIP'
        and a.pricing_phase_id  =l_list_line_info.pricing_phase_id;

  If l_freeze_override_flag Is Null or l_freeze_override_flag = 'N' Then
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' FREEZE OVERRIDE FLAG FOR SHIP EVENT AND PHASE ID '||L_LIST_LINE_INFO.PRICING_PHASE_ID ||'IS ''N'' OR NULLL' ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' PLEASE CONTACT ORACLE PRICING TO FIX THIS PROBLEM' ) ;
   END IF;
  End If;

Exception when others then
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  SQLERRM||':EVENT PHASES CHECK' ) ;
END IF;
End;

--query line and header record
--Set org?
oe_line_util.query_row(p_line_id,l_line_rec);

If l_line_rec.line_id is null Then
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'INVALID LINE ID OR INCORRECT ORG_ID' ) ;
  END IF;
  Return;
End If;

--testing qp attribute mapping
OE_Order_Pub.G_Line := l_line_rec;

Begin
QP_Attr_Mapping_PUB.Build_Contexts(p_request_type_code => 'ONT',
                                     p_pricing_type	=>	'L',
			             x_price_contexts_result_tbl => l_pricing_contexts_Tbl,
			             x_qual_contexts_result_tbl  => l_qualifier_Contexts_Tbl);

Exception when others then
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'QP ATTRIBUTE MAPPING:'||SQLERRM ) ;
END IF;
End;
OE_Order_Pub.G_Line := NULL;

--Test if attribute mapping sorces required pricing attributes
For i in pricing_attribute_info Loop
  l_found:=false;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CHECK IF ATTRIBUTE MAPPING SOURCES:'||I.PRICING_ATTRIBUTE_CONTEXT||' , '||I.PRICING_ATTRIBUTE||' , '||I.PRICING_ATTR_VALUE_FROM ) ;
  END IF;

  j := l_pricing_contexts_tbl.first;
  While j is not null Loop
    if i.pricing_attribute_context = l_pricing_contexts_tbl(j).context_name
       and i.pricing_attribute =  l_pricing_contexts_tbl(j).attribute_name Then
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  ' THIS ATTRIBUTE IS SOURCED WITH VALUE:'||L_PRICING_CONTEXTS_TBL ( J ) .ATTRIBUTE_VALUE ) ;
       END IF;
       l_found := True;
       exit;
    End If;
  j:= l_pricing_contexts_tbl.next(j);
  End Loop;

  If not l_found Then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' THIS ATTRIBUTE DID NOT GET SOURCED. THE CAUSED COULD BE:' ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' 1. YOU HAVE NOT RUN QP BUILD SOURCING CONCURENT PROGRAM' ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' 2. THE COST RECORD WAS NOT PASSED TO OM' ) ;
    END IF;
  End If;

End Loop;


--check if this is a shippable line
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'CHECKING IF THE LINE IS SHIPPABLE' ) ;
END IF;
If l_line_rec.shippable_flag = 'N' or l_line_rec.shipped_quantity <=  0 Then
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' EITHER THIS LINE IS NOT SHIPPABLE OR HAS NOT BEEN SHIP CONFIRMED' ) ;
  END IF;
End If;


--check if cost record have been inserted into OM
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'CHECKING IF FREIGHT COST HAS BEEN PASSED TO OM' ) ;
END IF;

-- Cost records are stored in OE_PRICE_ADJUSTMENTS table with
-- list_line_type_code = 'COST'
Begin
       SELECT SUM(ADJUSTED_AMOUNT)
	  INTO l_cost_amount
	  FROM OE_PRICE_ADJUSTMENTS_V
	  WHERE LINE_ID = l_line_rec.line_id
	  AND LIST_LINE_TYPE_CODE = 'COST'
	  AND CHARGE_TYPE_CODE = l_cost_type_code;
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  ' COST RECORD INSERTED WITH VALUE:'||L_COST_AMOUNT ) ;
 END IF;
Exception
When No_Data_Found Then
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  ' FREIGHT COST RECORD IS NOT PASSED BY SHIPPING OR YOU HAVE NOT ENTERED THE FREIGHT COST' ) ;
 END IF;
End;

For i in Other_Cost Loop
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' PASSED CHARGE COST TYPE IN OM:'||I.CHARGE_TYPE_CODE ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' COST AMOUNT:'||I.ADJUSTED_AMOUNT ) ;
  END IF;
End Loop;

End;

--Recurring Charges
PROCEDURE Get_Rec_Charge_Amount
  (   p_api_version_number            IN  NUMBER
  ,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
  ,   p_header_id                     IN  NUMBER
  ,   p_line_id                       IN  NUMBER
  ,   p_all_charges                   IN  VARCHAR2 := FND_API.G_FALSE
  ,   p_charge_periodicity_code       IN  VARCHAR2
  ,   x_return_status                 OUT NOCOPY VARCHAR2
  ,   x_msg_count                     OUT NOCOPY NUMBER
  ,   x_msg_data                      OUT NOCOPY VARCHAR2
  ,   x_charge_amount                 OUT NOCOPY NUMBER
  )
 IS
 l_api_version_number          CONSTANT NUMBER := 1.0;
 l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Rec_Charge_Amount';
 l_charge_amount               NUMBER := 0.0;
 l_hdr_charge_amount           NUMBER := 0.0;
 l_line_charge_amount          NUMBER := 0.0;
 Is_fmt                        BOOLEAN;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
 BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check for Header Id

    IF p_header_id is NULL OR p_header_id = FND_API.G_MISS_NUM THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','header');
            OE_MSG_PUB.Add;

        END IF;
        RAISE FND_API.G_EXC_ERROR;

    END IF;

    IF  NVL(p_header_id,-1)<>NVL(OE_ORDER_UTIL.G_Header_id,-10)
    OR  OE_ORDER_UTIL.G_Precision IS NULL THEN
      Is_fmt:=   OE_ORDER_UTIL.Get_Precision(
                p_header_id=>p_header_id
               );
    END IF;

    IF OE_ORDER_UTIL.G_Precision IS NULL THEN
      OE_ORDER_UTIL.G_Precision:=2;
    END IF;

    -- Check the operation whether all charges for the Order are required
    IF p_all_charges = FND_API.G_TRUE THEN
     SELECT SUM(ROUND(
                DECODE(P.CREDIT_OR_CHARGE_FLAG,'C',
                        DECODE(P.ARITHMETIC_OPERATOR, 'LUMPSUM',
                               DECODE(L.ORDERED_QUANTITY,0,0,(-P.OPERAND)),
                               (-L.ORDERED_QUANTITY* nvl(P.ADJUSTED_AMOUNT,0))),
                        DECODE(P.ARITHMETIC_OPERATOR, 'LUMPSUM',
                               DECODE(L.ORDERED_QUANTITY,0,0,P.OPERAND),
                               (L.ORDERED_QUANTITY* nvl(P.ADJUSTED_AMOUNT,0)))
                       )
                  ,OE_ORDER_UTIL.G_Precision)
                 )
      INTO l_charge_amount
      FROM OE_PRICE_ADJUSTMENTS P,
           OE_ORDER_LINES_ALL L
      WHERE P.HEADER_ID = p_header_id
      AND   P.LINE_ID = L.LINE_ID(+)
      AND   nvl(L.CHARGE_PERIODICITY_CODE,'ONE') = p_charge_periodicity_code
      AND   P.LIST_LINE_TYPE_CODE = 'FREIGHT_CHARGE'
      AND   P.APPLIED_FLAG = 'Y';

    END IF;

    IF l_charge_amount IS NULL THEN
	 l_charge_amount := 0.0;
    END IF;
    x_charge_amount := l_charge_amount;
 EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        -- Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count  => x_msg_count
        ,   p_data   => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Charge_Amount'
            );
        END IF;

        -- Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count  => x_msg_count
        ,   p_data   => x_msg_data
        );

END Get_Rec_Charge_Amount;

END OE_Charge_PVT;

/
