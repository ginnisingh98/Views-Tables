--------------------------------------------------------
--  DDL for Package Body OE_FREIGHT_RATING_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_FREIGHT_RATING_UTIL" AS
/* $Header: OEXUFRRB.pls 120.1.12010000.3 2009/06/26 12:14:44 nitagarw ship $ */

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_FREIGHT_RATING_UTIL';
G_BINARY_LIMIT CONSTANT NUMBER := OE_GLOBALS.G_BINARY_LIMIT; -- Added for bug 8636027

FUNCTION IS_FREIGHT_RATING_AVAILABLE RETURN BOOLEAN IS
l_code_release varchar2(30) := NULL;
l_enable_freight_rating varchar2(1) := NULL;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OEXUFRRB: IN IS_FREIGHT_RATING_AVAILABLE' ) ;
   END IF;

   l_code_release := OE_CODE_CONTROL.Get_Code_Release_Level;

   IF l_code_release < '110509' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LESS THAN PACK I' , 3 ) ;
      END IF;
      Return False;
   END IF;

-- Check whether FTE is Installed. If not Exit

    IF G_FTE_INSTALLED IS NULL THEN
       G_FTE_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(716);
    END IF;

    IF G_FTE_INSTALLED = 'N' THEN
       --FND_MESSAGE.Set_Name('ONT','ONT_FTE_NOT_INSTALLED');
       --OE_MSG_PUB.Add;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'FTE IS NOT INSTALLED!' , 3 ) ;
       END IF;
       RETURN False;
    END IF;

  l_enable_freight_rating := nvl(OE_Sys_Parameters.Value('FTE_INTEGRATION'), 'N');

   IF  l_enable_freight_rating in ('N', 'S') THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ENABLE_FREIGHT_RATING IS NO ' , 3 ) ;
       END IF;
       Return False;
   END IF;


   Return True;

   EXCEPTION

      WHEN OTHERS THEN

        Return False;

END;

 FUNCTION Get_Cost_Amount
 (   p_cost_type_code                IN  VARCHAR2
 )RETURN VARCHAR2 IS
 l_api_version_number          CONSTANT NUMBER := 1.0;
 l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Cost_Amount';
 l_line_rec                    OE_Order_PUB.Line_Rec_Type;
 l_cost_amount                 NUMBER := 0.0;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
 BEGIN

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'OEXUFRRB:INSIDE GET COST AMOUNT FOR' || P_COST_TYPE_CODE , 1 ) ;
 END IF;

    -- Get the Line record from the Global Record
    l_line_rec := OE_ORDER_PUB.G_LINE;

    -- Validate the Line_id.

    IF l_line_rec.line_id is NULL OR l_line_rec.line_id = FND_API.G_MISS_NUM
    THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'L_LINE_REC.LINE_ID IS NULL OR L_LINE_REC.LINE_ID IS FND_API.G_MISS_NUM' ) ;
            oe_debug_pub.add(  'EXITING CHARGES' ) ;
        END IF;
        RETURN NULL;
    END IF;

    -- Check for values of cost_type_code

    IF p_cost_type_code is NULL OR p_cost_type_code = FND_API.G_MISS_CHAR THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'P_COST_TYPE_CODE IS NULL OR P_COST_TYPE_CODE IS FND_API.G_MISS_CHAR' ) ;
           oe_debug_pub.add(  'EXITING CHARGES' ) ;
       END IF;
       RETURN NULL;
    END IF;

    -- Check for Pricing Quantity

  /*
    IF l_line_rec.pricing_quantity IS NULL OR
	  l_line_rec.pricing_quantity = FND_API.G_MISS_NUM OR
	  l_line_rec.pricing_quantity <= 0 THEN
          oe_debug_pub.add('l_line_rec.pricing_quantity = FND_API.G_MISS_NUM OR _line_rec.pricing_quantity <= 0');
          oe_debug_pub.add('exiting charges');
	  RETURN NULL;
    END IF;
  */

    -- Check whether the line is shippable and has got shipped

    IF l_line_rec.shippable_flag = 'Y' THEN
        IF l_line_rec.shipped_quantity > 0 THEN

       -- Cost records are stored in OE_PRICE_ADJUSTMENTS table with
	  -- list_line_type_code = 'COST'
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LINE IS SHIPPABLE AND IS SHIPPED' , 3 ) ;
          END IF;
          SELECT NVL(SUM(ADJUSTED_AMOUNT),0)
	  INTO l_cost_amount
	  FROM OE_PRICE_ADJUSTMENTS
	  WHERE LINE_ID = l_line_rec.line_id
	  AND LIST_LINE_TYPE_CODE = 'COST'
	  AND CHARGE_TYPE_CODE = p_cost_type_code
          AND nvl(ESTIMATED_FLAG, 'N') <> 'Y';

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'AFTER GETTING COST AMOUNT ' || TO_CHAR ( L_COST_AMOUNT ) , 3 ) ;
 END IF;

          RETURN FND_NUMBER.NUMBER_TO_CANONICAL(l_cost_amount);
       ELSE
          SELECT NVL(SUM(ADJUSTED_AMOUNT),0)
	  INTO l_cost_amount
	  FROM OE_PRICE_ADJUSTMENTS
	  WHERE LINE_ID = l_line_rec.line_id
	  AND LIST_LINE_TYPE_CODE = 'COST'
	  AND CHARGE_TYPE_CODE = p_cost_type_code
          AND ESTIMATED_FLAG = 'Y';

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'AFTER GETTING ESTIMATED COST AMOUNT ' || TO_CHAR ( L_COST_AMOUNT ) , 3 ) ;
 END IF;

          RETURN FND_NUMBER.NUMBER_TO_CANONICAL(l_cost_amount);
       END IF;
    ELSE
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'LINE NOT SHIPPABLE OR IS NOT SHIPPED' , 3 ) ;
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
	   RETURN FND_NUMBER.NUMBER_TO_CANONICAL(0);

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

FUNCTION Get_List_Line_Type_Code
(   p_key	IN NUMBER)
RETURN VARCHAR2
IS

l_list_line_type_code	VARCHAR2(30);
l_list_line_type_code_rec   List_Line_Type_Code_Rec_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_FREIGHT_RATING_UTIL.GET_LIST_LINE_TYPE_CODE' , 1 ) ;
    END IF;

    IF 	p_key IS NOT NULL THEN

        IF g_list_line_type_code_tbl.Exists(MOD(p_key,G_BINARY_LIMIT)) THEN       -- Bug 8636027

         l_list_line_type_code
            := g_list_line_type_code_tbl(MOD(p_key,G_BINARY_LIMIT)).list_line_type_code;            -- Bug 8636027

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'LIST LINE TYPE CODE FOR HEADER: ' || P_KEY ||' IS: ' || L_LIST_LINE_TYPE_CODE , 3 ) ;
            END IF;

        ELSE

           BEGIN
           SELECT  list_line_type_code
           INTO   l_list_line_type_code
           FROM   oe_price_adjustments
           WHERE  header_id = p_key
           AND    list_header_id = p_key * (-1)
           AND    list_line_type_code = 'OM_CALLED_FREIGHT_RATES'
           AND    rownum = 1;

           EXCEPTION WHEN NO_DATA_FOUND THEN
             l_list_line_type_code := NULL;
           END;

           IF l_list_line_type_code IS NOT NULL THEN
             l_list_line_type_code_rec.list_line_type_code
                 := l_list_line_type_code;
             g_list_line_type_code_tbl(MOD(p_key,G_BINARY_LIMIT))              -- Bug 8636027
                 := l_list_line_type_code_rec;

                         IF l_debug_level  > 0 THEN
                             oe_debug_pub.add(  'LOADING LIST LINE TYPE CODE FOR HEADER: ' || P_KEY ||' IS: ' || L_LIST_LINE_TYPE_CODE , 3 ) ;
                         END IF;
           END IF;

        END IF;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_FREIGHT_RATING_UTIL.GET_LIST_LINE_TYPE_CODE' , 1 ) ;
    END IF;

    RETURN l_list_line_type_code;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Get_List_Line_Type_Code'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_List_Line_Type_Code;

 FUNCTION Get_Estimated_Cost_Amount
 (   p_cost_type_code                IN  VARCHAR2
 )RETURN VARCHAR2 IS
 l_api_version_number          CONSTANT NUMBER := 1.0;
 l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Cost_Amount';
 l_line_rec                    OE_Order_PUB.Line_Rec_Type;
 l_cost_amount                 NUMBER := 0.0;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
 BEGIN

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'OEXUFRRB:INSIDE get_estimated_cost_amount FOR' || P_COST_TYPE_CODE , 1 ) ;
 END IF;

    -- Get the Line record from the Global Record
    l_line_rec := OE_ORDER_PUB.G_LINE;

    -- Validate the Line_id.

    IF l_line_rec.line_id is NULL OR l_line_rec.line_id = FND_API.G_MISS_NUM
    THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'L_LINE_REC.LINE_ID IS NULL OR L_LINE_REC.LINE_ID IS FND_API.G_MISS_NUM' ) ;
            oe_debug_pub.add(  'EXITING CHARGES' ) ;
        END IF;
        RETURN NULL;
    END IF;

    -- Check for values of cost_type_code

    IF p_cost_type_code is NULL OR p_cost_type_code = FND_API.G_MISS_CHAR THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'P_COST_TYPE_CODE IS NULL OR P_COST_TYPE_CODE IS FND_API.G_MISS_CHAR' ) ;
           oe_debug_pub.add(  'EXITING CHARGES' ) ;
       END IF;
       RETURN NULL;
    END IF;

    -- Check for Pricing Quantity

  /*
    IF l_line_rec.pricing_quantity IS NULL OR
	  l_line_rec.pricing_quantity = FND_API.G_MISS_NUM OR
	  l_line_rec.pricing_quantity <= 0 THEN
          oe_debug_pub.add('l_line_rec.pricing_quantity = FND_API.G_MISS_NUM OR _line_rec.pricing_quantity <= 0');
          oe_debug_pub.add('exiting charges');
	  RETURN NULL;
    END IF;
  */

    -- Check whether the line is shippable and has got shipped

    IF l_line_rec.shippable_flag = 'Y' THEN
          SELECT NVL(SUM(ADJUSTED_AMOUNT),0)
	  INTO l_cost_amount
	  FROM OE_PRICE_ADJUSTMENTS
	  WHERE LINE_ID = l_line_rec.line_id
	  AND LIST_LINE_TYPE_CODE = 'COST'
	  AND CHARGE_TYPE_CODE = p_cost_type_code
          AND ESTIMATED_FLAG = 'Y';

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'AFTER GETTING ESTIMATED COST AMOUNT ' || TO_CHAR ( L_COST_AMOUNT ) , 3 ) ;
 END IF;

          RETURN FND_NUMBER.NUMBER_TO_CANONICAL(l_cost_amount);
    ELSE
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'LINE NOT SHIPPABLE ' , 3 ) ;
           END IF;
	   RETURN FND_NUMBER.NUMBER_TO_CANONICAL(0);

    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LEAVING CHARGES' ) ;
    END IF;
 EXCEPTION

    WHEN NO_DATA_FOUND THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'NO COST INFORMATION FOUND IN OE_PRICE_ADJUSTMENTS' ) ;
           END IF;
	   RETURN FND_NUMBER.NUMBER_TO_CANONICAL(0);

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
 END Get_Estimated_Cost_Amount;

PROCEDURE Create_Dummy_Adjustment(p_header_id in number) IS
l_price_adjustment_id number := -1;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF p_header_id is not null THEN

    select oe_price_adjustments_s.nextval
    into   l_price_adjustment_id
    from   dual;

    INSERT INTO oe_price_adjustments
           (PRICE_ADJUSTMENT_ID
           ,HEADER_ID
           ,LINE_ID
           ,PRICING_PHASE_ID
           ,LIST_LINE_TYPE_CODE
           ,LIST_HEADER_ID
           ,LIST_LINE_ID
           ,ADJUSTED_AMOUNT
           ,AUTOMATIC_FLAG
           ,UPDATED_FLAG
           ,APPLIED_FLAG
           ,CREATION_DATE
           ,CREATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           )
    VALUES
          (l_price_adjustment_id
           ,p_header_id
           ,NULL
           ,-1
           ,'OM_CALLED_FREIGHT_RATES'
           ,-1*p_header_id
           ,NULL
           ,-1
           ,'N'
           ,'Y'
           ,NULL
           ,sysdate
           ,1
           ,sysdate
           ,1
          );

  END IF;


END Create_Dummy_Adjustment;

-- Added as part of bug 6955343
FUNCTION Get_Estimated_Cost_Amount_Ns
 (   p_cost_type_code                IN  VARCHAR2
 )RETURN VARCHAR2 IS
  l_api_version_number          CONSTANT NUMBER := 1.0;
  l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Estimated_Cost_Amount_Ns';
  l_line_rec                    OE_Order_PUB.Line_Rec_Type;
  l_cost_amount                 NUMBER := 0.0;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
  BEGIN

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OEXUFRRB: Inside Procedure Get_Estimated_Cost_Amount_Ns');
      oe_debug_pub.add('p_cost_type_code  : ' || P_COST_TYPE_CODE , 1 ) ;
   END IF;
   -- Get the Line record from the Global Record
   l_line_rec := OE_ORDER_PUB.G_LINE;

   -- Validate the Line_id.

   IF l_line_rec.line_id is NULL OR l_line_rec.line_id = FND_API.G_MISS_NUM
   THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'L_LINE_REC.LINE_ID IS NULL OR L_LINE_REC.LINE_ID IS FND_API.G_MISS_NUM' ) ;
         oe_debug_pub.add(  'EXITING CHARGES' ) ;
      END IF;
      RETURN NULL;
   END IF;

   -- Check for values of cost_type_code

   IF p_cost_type_code is NULL OR p_cost_type_code = FND_API.G_MISS_CHAR THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'P_COST_TYPE_CODE IS NULL OR P_COST_TYPE_CODE IS FND_API.G_MISS_CHAR' ) ;
         oe_debug_pub.add(  'EXITING CHARGES' ) ;
      END IF;
      RETURN NULL;
   END IF;

   SELECT NVL(SUM(ADJUSTED_AMOUNT),0)
   INTO l_cost_amount
   FROM OE_PRICE_ADJUSTMENTS
   WHERE LINE_ID = l_line_rec.line_id
   AND LIST_LINE_TYPE_CODE = 'COST'
   AND CHARGE_TYPE_CODE = p_cost_type_code
   AND ESTIMATED_FLAG = 'Y';

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER GETTING ESTIMATED COST AMOUNT ' || TO_CHAR ( L_COST_AMOUNT ) , 3 ) ;
   END IF;
   RETURN FND_NUMBER.NUMBER_TO_CANONICAL(l_cost_amount);
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LEAVING CHARGES' ) ;
   END IF;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'NO COST INFORMATION FOUND IN OE_PRICE_ADJUSTMENTS' ) ;
      END IF;
      RETURN FND_NUMBER.NUMBER_TO_CANONICAL(0);
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
END Get_Estimated_Cost_Amount_ns;

END OE_FREIGHT_RATING_util;

/
