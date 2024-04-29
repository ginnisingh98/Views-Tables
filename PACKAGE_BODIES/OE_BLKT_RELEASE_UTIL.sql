--------------------------------------------------------
--  DDL for Package Body OE_BLKT_RELEASE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BLKT_RELEASE_UTIL" AS
/* $Header: OEXUBRLB.pls 120.6.12010000.3 2009/09/24 09:00:56 smanian ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Blkt_Release_Util';
G_BINARY_LIMIT CONSTANT NUMBER := OE_GLOBALS.G_BINARY_LIMIT; --bug8465849

---------------------------------------------------------------------------
-- LOCAL FUNCTION Get_Line_Number
-- Used to set line_number token in error messages
---------------------------------------------------------------------------
FUNCTION Get_Line_Number
  (p_line_id              IN NUMBER
  ) RETURN NUMBER
IS
  l_line_number       NUMBER;
BEGIN

  SELECT LINE_NUMBER
    INTO l_line_number
    FROM OE_ORDER_LINES
   WHERE LINE_ID = p_line_id;

  RETURN l_line_number;

EXCEPTION
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
           (G_PKG_NAME
            ,'Get_Line_Number'
            );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Line_Number;

---------------------------------------------------------------------------
-- LOCAL FUNCTION Get_Shipment_Number
-- Used to set shipment_number token in error messages
---------------------------------------------------------------------------
FUNCTION Get_Shipment_Number
  (p_line_id              IN NUMBER
  ) RETURN NUMBER
IS
  l_shipment_number       NUMBER;
BEGIN

  SELECT SHIPMENT_NUMBER
    INTO l_shipment_number
    FROM OE_ORDER_LINES
   WHERE LINE_ID = p_line_id;

  RETURN l_shipment_number;

EXCEPTION
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
           (G_PKG_NAME
            ,'Get_Shipment_Number'
            );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Shipment_Number;

---------------------------------------------------------------------------
-- PUBLIC FUNCTION Convert_Amount
-- Also called from OEXVFULB.pls
-- Converts amounts from one currency to another
-- If there is no direct conversion rate available between the FROM and
-- TO currencies, currency triangulation approach is used =>
--    First, converts from FROM currency to Set of Books (SOB) currency
--    Next, converts above converted amount from SOB currency to TO currency
---------------------------------------------------------------------------
FUNCTION Convert_Amount
  (p_from_currency       IN VARCHAR2
  ,p_to_currency         IN VARCHAR2
  ,p_conversion_date     IN DATE
  ,p_conversion_type     IN VARCHAR2
  ,p_amount              IN NUMBER
  ) RETURN NUMBER
IS
  l_amount       NUMBER;
  No_Conversion_Rate       EXCEPTION;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     BEGIN
       if l_debug_level > 0 then
       OE_DEBUG_PUB.ADD('Convert from '||p_from_currency||
                         ' to '||p_to_currency||' Amount :'||p_amount);
       end if;
       l_amount := gl_currency_api.convert_closest_amount_sql
          (x_from_currency     => p_from_currency
          ,x_to_currency       => p_to_currency
          ,x_conversion_date   => p_conversion_date
          ,x_conversion_type   => p_conversion_type
          ,x_user_rate         => NULL
          ,x_amount            => p_amount
          ,x_max_roll_days     => -1
          );
       if l_debug_level > 0 then
       OE_DEBUG_PUB.ADD('Converted amount 1 :'||l_amount);
       end if;

       IF l_amount < 0 THEN
          RAISE No_Conversion_Rate;
       END IF;

     EXCEPTION
       WHEN No_Conversion_Rate THEN
         DECLARE
           l_sob_rec                OE_Order_Cache.Set_Of_Books_Rec_Type;
         BEGIN

           l_sob_rec := OE_Order_Cache.Load_Set_Of_Books;

           if l_debug_level > 0 then
           OE_DEBUG_PUB.ADD('SOB Currency :'||l_sob_rec.currency_code);
           end if;

           IF l_sob_rec.currency_code <> p_to_currency THEN

           l_amount := gl_currency_api.convert_closest_amount_sql
               (x_from_currency     => p_from_currency
               ,x_to_currency       => l_sob_rec.currency_code
               ,x_conversion_date   => p_conversion_date
               ,x_conversion_type   => p_conversion_type
               ,x_user_rate         => NULL
               ,x_amount            => p_amount
               ,x_max_roll_days     => -1
               );
           if l_debug_level > 0 then
             OE_DEBUG_PUB.ADD('Converted amount 2 :'||l_amount);
           end if;

           IF l_amount < 0 THEN
              RAISE No_Conversion_Rate;
           END IF;

           l_amount := gl_currency_api.convert_closest_amount_sql
               (x_from_currency     => l_sob_rec.currency_code
               ,x_to_currency       => p_to_currency
               ,x_conversion_date   => p_conversion_date
               ,x_conversion_type   => p_conversion_type
               ,x_user_rate         => NULL
               ,x_amount            => l_amount
               ,x_max_roll_days     => -1
               );
           if l_debug_level > 0 then
             OE_DEBUG_PUB.ADD('Converted amount 3 :'||l_amount);
           end if;

           IF l_amount < 0 THEN
              RAISE No_Conversion_Rate;
           END IF;

           ELSE

              RAISE No_Conversion_Rate;

           END IF; -- Convert to SOB currency, if <> blanket currency

         END;
     END;

     RETURN l_amount;

EXCEPTION
  WHEN No_Conversion_Rate THEN
    if l_debug_level > 0 then
       oe_debug_pub.add('no rate found in either blanket or sob currency');
    end if;
    FND_MESSAGE.SET_NAME('ONT','OE_BL_MISSING_CONV_RATE');
    FND_MESSAGE.SET_TOKEN('BLANKET_CURRENCY',p_to_currency);
    OE_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
           (G_PKG_NAME
            ,'Convert_Amount'
            );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Convert_Amount;

---------------------------------------------------------------------------
-- LOCAL PROCEDURE Cache_Blanket
---------------------------------------------------------------------------
PROCEDURE Cache_Blanket
  (p_blanket_number            IN NUMBER
  ,p_blanket_line_number       IN NUMBER
  ,p_lock                      IN VARCHAR2 DEFAULT 'Y'
  ,x_blanket_line_id           IN OUT NOCOPY NUMBER
  ,x_blanket_header_id         IN OUT NOCOPY NUMBER
  )
IS

  CURSOR c_blanket_line  (p_blanket_line_id NUMBER) IS
  SELECT  L.HEADER_ID
	 ,L.LINE_ID
         ,BL.OVERRIDE_BLANKET_CONTROLS_FLAG
         ,BL.OVERRIDE_RELEASE_CONTROLS_FLAG
         ,nvl(BL.RELEASED_AMOUNT,0)
         ,BL.MIN_RELEASE_AMOUNT
         ,BL.MAX_RELEASE_AMOUNT
         ,BL.BLANKET_LINE_MAX_AMOUNT
         ,BL.BLANKET_MAX_QUANTITY
         ,BL.RELEASED_QUANTITY
         ,BL.FULFILLED_QUANTITY
         ,BL.FULFILLED_AMOUNT
         ,BL.MIN_RELEASE_QUANTITY
         ,BL.MAX_RELEASE_QUANTITY
         ,L.ORDER_QUANTITY_UOM
         ,nvl(BL.RETURNED_QUANTITY,0)
         ,nvl(BL.RETURNED_AMOUNT,0)
         ,'N' -- locked_flag
    FROM OE_BLANKET_LINES L,OE_BLANKET_LINES_EXT BL
   WHERE L.LINE_ID = p_blanket_line_id
     AND L.LINE_ID = BL.LINE_ID
     AND L.SALES_DOCUMENT_TYPE_CODE = 'B';

  CURSOR c_blanket_header (p_blanket_header_id NUMBER)IS
  SELECT  H.HEADER_ID
	 ,BH.OVERRIDE_AMOUNT_FLAG
         ,nvl(BH.RELEASED_AMOUNT,0)
         ,nvl(BH.RETURNED_AMOUNT,0)
         ,nvl(BH.FULFILLED_AMOUNT,0)
         ,BH.BLANKET_MAX_AMOUNT
         ,H.TRANSACTIONAL_CURR_CODE
         ,H.CONVERSION_TYPE_CODE
         ,'N' -- locked_flag
    FROM OE_BLANKET_HEADERS H,OE_BLANKET_HEADERS_EXT BH
   WHERE H.HEADER_ID = p_blanket_header_id
     AND H.ORDER_NUMBER = BH.ORDER_NUMBER
     AND H.SALES_DOCUMENT_TYPE_CODE = 'B';

l_blanket_header_id   NUMBER;
l_blanket_line_id   NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Enter cache blanket');
    oe_debug_pub.add('lock :'||p_lock);
    oe_debug_pub.add('blanket number :'||p_blanket_number);
    oe_debug_pub.add('blanket number :'||p_blanket_line_number);
  end if;

  SELECT line_id
    INTO x_blanket_line_id
    FROM OE_BLANKET_LINES_EXT BL
   WHERE BL.ORDER_NUMBER = p_blanket_number
     AND BL.LINE_NUMBER  = p_blanket_line_number;

 l_blanket_line_id := x_blanket_line_id;
 x_blanket_line_id := MOD(x_blanket_line_id , G_BINARY_LIMIT); --bug8465849


  if l_debug_level > 0 then
     oe_debug_pub.add('blanket line id :'||x_blanket_line_id);
     if g_blkt_line_tbl.exists(x_blanket_line_id) then
        oe_debug_pub.add('locked flag :'|| g_blkt_line_tbl(x_blanket_line_id).locked_flag);
     end if;
  end if;

  --------------------------------------------------------------------
  -- CACHE BLANKET LINE
  --------------------------------------------------------------------

  IF    ( NOT g_blkt_line_tbl.EXISTS(x_blanket_line_id) )
         -- re-query if blanket is to be locked and it was not locked before
     OR (p_lock = 'Y'
         AND nvl(g_blkt_line_tbl(x_blanket_line_id).locked_flag,'N') = 'N'
         )
  THEN

     if l_debug_level > 0 then
        oe_debug_pub.add('query blanket line');
     end if;

     OPEN c_blanket_line(l_blanket_line_id);--bug8465849
     FETCH c_blanket_line INTO
         g_blkt_line_tbl(x_blanket_line_id).header_id
	,g_blkt_line_tbl(x_blanket_line_id).line_id
        ,g_blkt_line_tbl(x_blanket_line_id).override_blanket_controls_flag
        ,g_blkt_line_tbl(x_blanket_line_id).override_release_controls_flag
        ,g_blkt_line_tbl(x_blanket_line_id).released_amount
        ,g_blkt_line_tbl(x_blanket_line_id).min_release_amount
        ,g_blkt_line_tbl(x_blanket_line_id).max_release_amount
        ,g_blkt_line_tbl(x_blanket_line_id).blanket_line_max_amount
        ,g_blkt_line_tbl(x_blanket_line_id).blanket_max_quantity
        ,g_blkt_line_tbl(x_blanket_line_id).released_quantity
        ,g_blkt_line_tbl(x_blanket_line_id).fulfilled_quantity
        ,g_blkt_line_tbl(x_blanket_line_id).fulfilled_amount
        ,g_blkt_line_tbl(x_blanket_line_id).min_release_quantity
        ,g_blkt_line_tbl(x_blanket_line_id).max_release_quantity
        ,g_blkt_line_tbl(x_blanket_line_id).uom
        ,g_blkt_line_tbl(x_blanket_line_id).returned_quantity
        ,g_blkt_line_tbl(x_blanket_line_id).returned_amount
        ,g_blkt_line_tbl(x_blanket_line_id).locked_flag
        ;
     CLOSE c_blanket_line;

  END IF;

  IF p_lock = 'Y'
     AND g_blkt_line_tbl(x_blanket_line_id).locked_flag = 'N'
  THEN
     if l_debug_level > 0 then
        oe_debug_pub.add('lock blanket line');
     end if;
        SELECT 'Y'
         INTO g_blkt_line_tbl(x_blanket_line_id).locked_flag
         FROM oe_blanket_lines_all
        WHERE line_id = l_blanket_line_id --bug8465849
          FOR UPDATE NOWAIT;
  END IF;

  --------------------------------------------------------------------
  -- CACHE BLANKET HEADER
  --------------------------------------------------------------------

  l_blanket_header_id := g_blkt_line_tbl(x_blanket_line_id).header_id;
  x_blanket_header_id := MOD(l_blanket_header_id , G_BINARY_LIMIT); --bug8465849

  IF    ( NOT g_blkt_hdr_tbl.EXISTS(x_blanket_header_id) )
         -- re-query if blanket is to be locked and it was not locked before
     OR (p_lock = 'Y'
         AND nvl(g_blkt_hdr_tbl(x_blanket_header_id).locked_flag,'N') = 'N'
         )
  THEN

     if l_debug_level > 0 then
        oe_debug_pub.add('query blanket header');
     end if;

     OPEN c_blanket_header(l_blanket_header_id);
     FETCH c_blanket_header INTO
         g_blkt_hdr_tbl(x_blanket_header_id).header_id
        ,g_blkt_hdr_tbl(x_blanket_header_id).override_amount_flag
        ,g_blkt_hdr_tbl(x_blanket_header_id).released_amount
        ,g_blkt_hdr_tbl(x_blanket_header_id).returned_amount
        ,g_blkt_hdr_tbl(x_blanket_header_id).fulfilled_amount
        ,g_blkt_hdr_tbl(x_blanket_header_id).blanket_max_amount
        ,g_blkt_hdr_tbl(x_blanket_header_id).currency_code
        ,g_blkt_hdr_tbl(x_blanket_header_id).conversion_type_code
        ,g_blkt_hdr_tbl(x_blanket_header_id).locked_flag
        ;
     CLOSE c_blanket_header;

  END IF;

  IF p_lock = 'Y'
     AND g_blkt_hdr_tbl(x_blanket_header_id).locked_flag = 'N'
  THEN
     if l_debug_level > 0 then
        oe_debug_pub.add('lock blanket header');
     end if;
        SELECT 'Y'
         INTO g_blkt_hdr_tbl(x_blanket_header_id).locked_flag
         FROM oe_blanket_headers_all
        WHERE header_id = l_blanket_header_id --bug8465849
          FOR UPDATE NOWAIT;
  END IF;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exit cache blanket');
  end if;

EXCEPTION
  WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
    FND_MESSAGE.Set_Name('ONT','OE_BL_LOCKED');
    FND_MESSAGE.Set_Token('BLANKET_NUMBER',p_blanket_number);
    OE_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
           (G_PKG_NAME
            ,'Cache_Blanket'
            );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Cache_Blanket;


---------------------------------------------------------------------------
-- PROCEDURE Update_Released_Qty_Amount
---------------------------------------------------------------------------
PROCEDURE Update_Released_Qty_Amount
  (p_line_id                   IN NUMBER
  ,p_line_set_id               IN NUMBER
  ,p_blanket_number            IN NUMBER
  ,p_blanket_line_number       IN NUMBER
  ,p_old_quantity              IN NUMBER
  ,p_quantity                  IN NUMBER
  ,p_old_order_qty_uom         IN VARCHAR2
  ,p_order_qty_uom             IN VARCHAR2
  ,p_old_unit_selling_price    IN NUMBER
  ,p_unit_selling_price        IN NUMBER
  ,p_old_inv_item_id           IN NUMBER
  ,p_inv_item_id               IN NUMBER
  ,p_currency_code             IN VARCHAR2
  ,p_fulfilled_flag            IN VARCHAR2
  ,x_return_status             OUT NOCOPY VARCHAR2
  )
IS

  l_blanket_line_id          NUMBER;
  l_blanket_header_id        NUMBER;

  l_quantity                 NUMBER := 0;
  l_old_quantity             NUMBER := 0;
  l_amount                   NUMBER := 0;
  l_old_amount               NUMBER := 0;
  l_released_amount          NUMBER := 0;
  l_hdr_released_amount      NUMBER := 0;
  l_released_quantity        NUMBER := 0;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  Cache_Blanket(p_blanket_number
              ,p_blanket_line_number
              ,'Y' -- p_lock
              ,l_blanket_line_id
              ,l_blanket_header_id
              );

  --------------------------------------------------------------------
  -- COMPUTE RELEASE QUANTITY IF Blanket UOM Exists
  --------------------------------------------------------------------

  if l_debug_level > 0 then
     oe_debug_pub.add('Blanket UOM:'||g_blkt_line_tbl(l_blanket_line_id).uom);
     oe_debug_pub.add('INITIAL blkt line released qty: '||
                    g_blkt_line_tbl(l_blanket_line_id).released_quantity);
     oe_debug_pub.add('INITIAL blkt line released amt: '||
                    g_blkt_line_tbl(l_blanket_line_id).released_amount);
     oe_debug_pub.add('INITIAL blkt hdr released amt: '||
                    g_blkt_hdr_tbl(l_blanket_header_id).released_amount);
     oe_debug_pub.add('new qty :'||p_quantity);
     oe_debug_pub.add('old qty :'||p_old_quantity);
     oe_debug_pub.add('new SP :'||p_unit_selling_price);
     oe_debug_pub.add('old SP :'||p_old_unit_selling_price);
     oe_debug_pub.add('from uom :'||p_order_qty_uom);
     oe_debug_pub.add('inv item :'||p_inv_item_id);
  end if;

  IF p_order_qty_uom IS NULL THEN
     l_quantity := 0;
  ELSE
     l_quantity := nvl(p_quantity,0);
  END IF;

  IF p_old_order_qty_uom IS NULL THEN
     l_old_quantity := 0;
  ELSE
     l_old_quantity := nvl(p_old_quantity,0);
  END IF;

 l_blanket_line_id   := MOD(l_blanket_line_id,G_BINARY_LIMIT);  --bug8465849
 l_blanket_header_id := MOD(l_blanket_header_id,G_BINARY_LIMIT); --bug8465849

  IF g_blkt_line_tbl(l_blanket_line_id).uom IS NOT NULL THEN

    IF l_quantity > 0
      AND p_order_qty_uom <> g_blkt_line_tbl(l_blanket_line_id).uom
    THEN
         l_quantity := OE_Order_Misc_Util.Convert_UOM
             (p_item_id          => p_inv_item_id
             ,p_from_uom_code    => p_order_qty_uom
             ,p_to_uom_code      => g_blkt_line_tbl(l_blanket_line_id).uom
             ,p_from_qty         => l_quantity
             );
         if l_debug_level > 0 then
            oe_debug_pub.add('conv new qty :'||l_quantity);
         end if;
         IF l_quantity < 0 THEN
           FND_MESSAGE.SET_NAME('ONT','OE_BL_UOM_CONV_FAILED');
           FND_MESSAGE.SET_TOKEN('LINE_NUMBER',Get_Line_Number(p_line_id));
           FND_MESSAGE.SET_TOKEN('BLANKET_UOM',
                                  g_blkt_line_tbl(l_blanket_line_id).uom);
           OE_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
    END IF;

    IF l_old_quantity > 0
      AND p_old_order_qty_uom <> g_blkt_line_tbl(l_blanket_line_id).uom
    THEN
         l_old_quantity := OE_Order_Misc_Util.Convert_UOM
             (p_item_id          => p_old_inv_item_id
             ,p_from_uom_code    => p_old_order_qty_uom
             ,p_to_uom_code      => g_blkt_line_tbl(l_blanket_line_id).uom
             ,p_from_qty         => l_old_quantity
             );
         if l_debug_level > 0 then
            oe_debug_pub.add('conv old qty :'||l_quantity);
         end if;
         IF l_old_quantity < 0 THEN
           FND_MESSAGE.SET_NAME('ONT','OE_BL_UOM_CONV_FAILED');
           FND_MESSAGE.SET_TOKEN('LINE_NUMBER',Get_Line_Number(p_line_id));
           FND_MESSAGE.SET_TOKEN('BLANKET_UOM',
                                  g_blkt_line_tbl(l_blanket_line_id).uom);
           OE_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
    END IF;

    -- INCREMENT Cumulative Released Quantity

    l_released_quantity := nvl(g_blkt_line_tbl(l_blanket_line_id).released_quantity,0)
                        + (l_quantity - l_old_quantity);

  END IF; -- End if blanket uom is not null


  --------------------------------------------------------------------
  -- COMPUTE RELEASE AMOUNT
  --------------------------------------------------------------------

  l_amount := nvl(p_quantity,0) * nvl(p_unit_selling_price,0);
  l_old_amount := nvl(p_old_quantity,0) * nvl(p_old_unit_selling_price,0);

  IF p_currency_code
     <> g_blkt_hdr_tbl(l_blanket_header_id).currency_code
  THEN

     IF g_blkt_hdr_tbl(l_blanket_header_id).conversion_type_code IS NULL THEN
        FND_MESSAGE.SET_NAME('ONT','OE_BL_MISS_CONVERSION_TYPE');
        FND_MESSAGE.SET_TOKEN('BLANKET_NUMBER',p_blanket_number);
        oe_msg_pub.add;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF l_amount <> 0 THEN
        l_amount := Convert_Amount
          (p_from_currency     => p_currency_code
          ,p_to_currency       =>
                  g_blkt_hdr_tbl(l_blanket_header_id).currency_code
          ,p_conversion_date   => sysdate
          ,p_conversion_type   =>
                  g_blkt_hdr_tbl(l_blanket_header_id).conversion_type_code
          ,p_amount            => l_amount
          );
     END IF;

     IF l_old_amount <> 0 THEN
       l_old_amount := Convert_Amount
          (p_from_currency     => p_currency_code
          ,p_to_currency       =>
                  g_blkt_hdr_tbl(l_blanket_header_id).currency_code
          ,p_conversion_date   => sysdate
          ,p_conversion_type   =>
                  g_blkt_hdr_tbl(l_blanket_header_id).conversion_type_code
          ,p_amount            => l_old_amount
          );
     END IF;

  END IF;

  -- INCREMENT Released Amounts

  l_released_amount := g_blkt_line_tbl(l_blanket_line_id).released_amount
                                 + (l_amount - l_old_amount);
  l_hdr_released_amount := g_blkt_hdr_tbl(l_blanket_header_id).released_amount
                     + (l_amount - l_old_amount);

  if l_debug_level > 0 then
     oe_debug_pub.add('curr line amt :'||l_amount);
     oe_debug_pub.add('bl line released qty :'||l_released_quantity);
     oe_debug_pub.add('bl line released amt :'||l_released_amount);
     oe_debug_pub.add('hdr released amt :'||l_hdr_released_amount);
  end if;

  --------------------------------------------------------------------
  -- VALIDATE MIN/MAX IF OVERRIDE NOT ALLOWED
  --------------------------------------------------------------------

  -- (1) Blanket line min/max qty and amount checks
  -- Check not needed for 0 qtys or full cancellations

  IF l_quantity <> 0 THEN

     -- (1a) Check Individual Release Qty/Amount Validations
     --ER 6526974
     --IF g_blkt_line_tbl(l_blanket_line_id).OVERRIDE_RELEASE_CONTROLS_FLAG = 'N'
     --THEN

       -- Qty checks only needed if blanket UOM is not null
       IF g_blkt_line_tbl(l_blanket_line_id).uom IS NOT NULL
          AND (l_quantity <
               nvl(g_blkt_line_tbl(l_blanket_line_id).min_release_quantity,0)
               OR l_quantity >
               nvl(g_blkt_line_tbl(l_blanket_line_id).max_release_quantity
                    ,l_quantity)
               )
       THEN
         -- If shipment line, only a warning is issued. Error status is not set.
         IF p_line_set_id IS NOT NULL THEN
	       IF g_blkt_line_tbl(l_blanket_line_id).OVERRIDE_RELEASE_CONTROLS_FLAG = 'N' THEN
			    FND_MESSAGE.SET_NAME('ONT','OE_BL_MIN_MAX_SHIPMENT_QTY');
			    FND_MESSAGE.SET_TOKEN('LINE_NUMBER',Get_Line_Number(p_line_id));
			    FND_MESSAGE.SET_TOKEN('SHIPMENT_NUMBER'
						 ,Get_Shipment_Number(p_line_id));
			    FND_MESSAGE.SET_TOKEN('BLANKET_UOM',
				g_blkt_line_tbl(l_blanket_line_id).uom);
			    FND_MESSAGE.SET_TOKEN('MINIMUM',
				g_blkt_line_tbl(l_blanket_line_id).min_release_quantity);
			    FND_MESSAGE.SET_TOKEN('MAXIMUM',
				g_blkt_line_tbl(l_blanket_line_id).max_release_quantity);
			    oe_msg_pub.add;
		ELSE
			IF NVL(FND_PROFILE.VALUE('ONT_BSA_MIN_MAX_VIOLATION'),'N') = 'Y' THEN
			    FND_MESSAGE.SET_NAME('ONT','OE_BL_MIN_MAX_SHIPMENT_QTY');
			    FND_MESSAGE.SET_TOKEN('LINE_NUMBER',Get_Line_Number(p_line_id));
			    FND_MESSAGE.SET_TOKEN('SHIPMENT_NUMBER'
						 ,Get_Shipment_Number(p_line_id));
			    FND_MESSAGE.SET_TOKEN('BLANKET_UOM',
				g_blkt_line_tbl(l_blanket_line_id).uom);
			    FND_MESSAGE.SET_TOKEN('MINIMUM',
				g_blkt_line_tbl(l_blanket_line_id).min_release_quantity);
			    FND_MESSAGE.SET_TOKEN('MAXIMUM',
				g_blkt_line_tbl(l_blanket_line_id).max_release_quantity);
			    oe_msg_pub.add;
			END IF;
		 END IF;

         -- For regular lines, raise error.
         ELSE
            IF g_blkt_line_tbl(l_blanket_line_id).OVERRIDE_RELEASE_CONTROLS_FLAG = 'N' THEN
		    FND_MESSAGE.SET_NAME('ONT','OE_BL_MIN_MAX_REL_QTY');
		    FND_MESSAGE.SET_TOKEN('LINE_NUMBER',Get_Line_Number(p_line_id));
		    FND_MESSAGE.SET_TOKEN('BLANKET_UOM',
			g_blkt_line_tbl(l_blanket_line_id).uom);
		    FND_MESSAGE.SET_TOKEN('MINIMUM',
			g_blkt_line_tbl(l_blanket_line_id).min_release_quantity);
		    FND_MESSAGE.SET_TOKEN('MAXIMUM',
			g_blkt_line_tbl(l_blanket_line_id).max_release_quantity);
		    oe_msg_pub.add;
		    x_return_status := FND_API.G_RET_STS_ERROR;

	    ELSE
		IF NVL(FND_PROFILE.VALUE('ONT_BSA_MIN_MAX_VIOLATION'),'N') = 'Y' THEN
		    FND_MESSAGE.SET_NAME('ONT','OE_BL_MIN_MAX_REL_QTY');
		    FND_MESSAGE.SET_TOKEN('LINE_NUMBER',Get_Line_Number(p_line_id));
		    FND_MESSAGE.SET_TOKEN('BLANKET_UOM',
			g_blkt_line_tbl(l_blanket_line_id).uom);
		    FND_MESSAGE.SET_TOKEN('MINIMUM',
			g_blkt_line_tbl(l_blanket_line_id).min_release_quantity);
		    FND_MESSAGE.SET_TOKEN('MAXIMUM',
			g_blkt_line_tbl(l_blanket_line_id).max_release_quantity);
		    oe_msg_pub.add;
		END IF;

	    END IF;


         END IF;
       END IF;

       /* Added this new condition, to check the max and min amount only if the values for
          actual min and max amounts defined as a part of the Sales Agreement only. We need to
          check the condition if the release amount is greater then or not?
          To address this condition, introduced a new condition to check if the Actual MAX/MIN amount
          of a BSA has some value other then Zero. Then only the below condition logic will be
          allowed to trigger. Added based on the bug #4697134. */

     IF nvl(g_blkt_line_tbl(l_blanket_line_id).min_release_amount,0) > 0 or
        nvl(g_blkt_line_tbl(l_blanket_line_id).max_release_amount,l_amount) > 0
     THEN


       IF (l_amount <
           nvl(g_blkt_line_tbl(l_blanket_line_id).min_release_amount,0)
           OR l_amount >
           nvl(g_blkt_line_tbl(l_blanket_line_id).max_release_amount,l_amount)
            )
       THEN
         -- If shipment line, only a warning is issued. Error status is not set.
         IF p_line_set_id IS NOT NULL THEN
           IF g_blkt_line_tbl(l_blanket_line_id).OVERRIDE_RELEASE_CONTROLS_FLAG = 'N' THEN
		    FND_MESSAGE.SET_NAME('ONT','OE_BL_MIN_MAX_SHIPMENT_AMT');
		    FND_MESSAGE.SET_TOKEN('LINE_NUMBER',Get_Line_Number(p_line_id));
		    FND_MESSAGE.SET_TOKEN('SHIPMENT_NUMBER'
					 ,Get_Shipment_Number(p_line_id));
		    FND_MESSAGE.SET_TOKEN('BLANKET_CURRENCY',
			g_blkt_hdr_tbl(l_blanket_header_id).currency_code);
		    FND_MESSAGE.SET_TOKEN('MINIMUM',
			g_blkt_line_tbl(l_blanket_line_id).min_release_amount);
		    FND_MESSAGE.SET_TOKEN('MAXIMUM',
			g_blkt_line_tbl(l_blanket_line_id).max_release_amount);
		    oe_msg_pub.add;
	    ELSE
		IF NVL(FND_PROFILE.VALUE('ONT_BSA_MIN_MAX_VIOLATION'),'N') = 'Y' THEN
		    FND_MESSAGE.SET_NAME('ONT','OE_BL_MIN_MAX_SHIPMENT_AMT');
		    FND_MESSAGE.SET_TOKEN('LINE_NUMBER',Get_Line_Number(p_line_id));
		    FND_MESSAGE.SET_TOKEN('SHIPMENT_NUMBER'
					 ,Get_Shipment_Number(p_line_id));
		    FND_MESSAGE.SET_TOKEN('BLANKET_CURRENCY',
			g_blkt_hdr_tbl(l_blanket_header_id).currency_code);
		    FND_MESSAGE.SET_TOKEN('MINIMUM',
			g_blkt_line_tbl(l_blanket_line_id).min_release_amount);
		    FND_MESSAGE.SET_TOKEN('MAXIMUM',
			g_blkt_line_tbl(l_blanket_line_id).max_release_amount);
		    oe_msg_pub.add;
		END IF;

	    END IF;

         -- For regular lines, raise error.
         ELSE
             IF g_blkt_line_tbl(l_blanket_line_id).OVERRIDE_RELEASE_CONTROLS_FLAG = 'N' THEN
		    FND_MESSAGE.SET_NAME('ONT','OE_BL_MIN_MAX_REL_AMT');
		    FND_MESSAGE.SET_TOKEN('LINE_NUMBER',Get_Line_Number(p_line_id));
		    FND_MESSAGE.SET_TOKEN('BLANKET_CURRENCY',
			g_blkt_hdr_tbl(l_blanket_header_id).currency_code);
		    FND_MESSAGE.SET_TOKEN('MINIMUM',
			g_blkt_line_tbl(l_blanket_line_id).min_release_amount);
		    FND_MESSAGE.SET_TOKEN('MAXIMUM',
			g_blkt_line_tbl(l_blanket_line_id).max_release_amount);
		    oe_msg_pub.add;
		    x_return_status := FND_API.G_RET_STS_ERROR;

	    ELSE
		IF NVL(FND_PROFILE.VALUE('ONT_BSA_MIN_MAX_VIOLATION'),'N') = 'Y' THEN
		   FND_MESSAGE.SET_NAME('ONT','OE_BL_MIN_MAX_REL_AMT');
		    FND_MESSAGE.SET_TOKEN('LINE_NUMBER',Get_Line_Number(p_line_id));
		    FND_MESSAGE.SET_TOKEN('BLANKET_CURRENCY',
			g_blkt_hdr_tbl(l_blanket_header_id).currency_code);
		    FND_MESSAGE.SET_TOKEN('MINIMUM',
			g_blkt_line_tbl(l_blanket_line_id).min_release_amount);
		    FND_MESSAGE.SET_TOKEN('MAXIMUM',
			g_blkt_line_tbl(l_blanket_line_id).max_release_amount);
		    oe_msg_pub.add;
		END IF;

	    END IF;

         END IF;
       END IF;
     END IF;

    --END IF; -- IF blanket line override release control = 'N'

     -- (1b) Check Blanket Qty/Amount (Sum of Released Qty/Amount) Validations
     -- ER 6526974
     --IF g_blkt_line_tbl(l_blanket_line_id).OVERRIDE_BLANKET_CONTROLS_FLAG = 'N'
     --THEN

       -- Qty checks only needed if blanket UOM is not null
       IF g_blkt_line_tbl(l_blanket_line_id).uom IS NOT NULL
          AND l_released_quantity >
          (g_blkt_line_tbl(l_blanket_line_id).blanket_max_quantity
            + g_blkt_line_tbl(l_blanket_line_id).returned_quantity)
       THEN
          IF g_blkt_line_tbl(l_blanket_line_id).OVERRIDE_BLANKET_CONTROLS_FLAG = 'N' THEN
		  FND_MESSAGE.SET_NAME('ONT','OE_BL_LIN_MAX_QTY_EXCEEDED');
		  FND_MESSAGE.SET_TOKEN('BLANKET_NUMBER',p_blanket_number);
		  FND_MESSAGE.SET_TOKEN('BLANKET_LINE_NUMBER',p_blanket_line_number);
		  FND_MESSAGE.SET_TOKEN('BLANKET_UOM',
		      g_blkt_line_tbl(l_blanket_line_id).uom);
		  FND_MESSAGE.SET_TOKEN('MAXIMUM',
		      g_blkt_line_tbl(l_blanket_line_id).blanket_max_quantity);
		  oe_msg_pub.add;
		  x_return_status := FND_API.G_RET_STS_ERROR;
	  ELSE
		IF NVL(FND_PROFILE.VALUE('ONT_BSA_MIN_MAX_VIOLATION'),'N') = 'Y' THEN
		  FND_MESSAGE.SET_NAME('ONT','OE_BL_LIN_MAX_QTY_EXCEEDED');
		  FND_MESSAGE.SET_TOKEN('BLANKET_NUMBER',p_blanket_number);
		  FND_MESSAGE.SET_TOKEN('BLANKET_LINE_NUMBER',p_blanket_line_number);
		  FND_MESSAGE.SET_TOKEN('BLANKET_UOM',
		      g_blkt_line_tbl(l_blanket_line_id).uom);
		  FND_MESSAGE.SET_TOKEN('MAXIMUM',
		      g_blkt_line_tbl(l_blanket_line_id).blanket_max_quantity);
		  oe_msg_pub.add;
		END IF;

	  END IF;

       END IF;

       IF l_released_amount >
          (g_blkt_line_tbl(l_blanket_line_id).blanket_line_max_amount
           + g_blkt_line_tbl(l_blanket_line_id).returned_amount)
       THEN
          IF g_blkt_line_tbl(l_blanket_line_id).OVERRIDE_BLANKET_CONTROLS_FLAG = 'N' THEN
		  FND_MESSAGE.SET_NAME('ONT','OE_BL_LIN_MAX_AMT_EXCEEDED');
		  FND_MESSAGE.SET_TOKEN('BLANKET_NUMBER',p_blanket_number);
		  FND_MESSAGE.SET_TOKEN('BLANKET_LINE_NUMBER',p_blanket_line_number);
		  FND_MESSAGE.SET_TOKEN('BLANKET_CURRENCY',
		      g_blkt_hdr_tbl(l_blanket_header_id).currency_code);
		  FND_MESSAGE.SET_TOKEN('MAXIMUM',
		      g_blkt_line_tbl(l_blanket_line_id).blanket_line_max_amount);
		  oe_msg_pub.add;
		  x_return_status := FND_API.G_RET_STS_ERROR;
	  ELSE
		IF NVL(FND_PROFILE.VALUE('ONT_BSA_MIN_MAX_VIOLATION'),'N') = 'Y' THEN
		  FND_MESSAGE.SET_NAME('ONT','OE_BL_LIN_MAX_AMT_EXCEEDED');
		  FND_MESSAGE.SET_TOKEN('BLANKET_NUMBER',p_blanket_number);
		  FND_MESSAGE.SET_TOKEN('BLANKET_LINE_NUMBER',p_blanket_line_number);
		  FND_MESSAGE.SET_TOKEN('BLANKET_CURRENCY',
		      g_blkt_hdr_tbl(l_blanket_header_id).currency_code);
		  FND_MESSAGE.SET_TOKEN('MAXIMUM',
		      g_blkt_line_tbl(l_blanket_line_id).blanket_line_max_amount);
		  oe_msg_pub.add;
		END IF;

	  END IF;

       END IF;

 -- END IF;  -- IF override blanket control = 'N'

  END IF; -- End of blanket line checks

  -- (2) Blanket header max amount check

  -- ER 6526974
  --IF g_blkt_hdr_tbl(l_blanket_header_id).override_amount_flag = 'N'
     -- Check not needed for 0 amount or full cancellations
  --   AND
  IF l_amount <> 0
  THEN

       IF l_hdr_released_amount >
           (g_blkt_hdr_tbl(l_blanket_header_id).blanket_max_amount
             + g_blkt_hdr_tbl(l_blanket_header_id).returned_amount)
       THEN
	  IF g_blkt_hdr_tbl(l_blanket_header_id).override_amount_flag = 'N' THEN
		  FND_MESSAGE.SET_NAME('ONT','OE_BL_HDR_MAX_AMT_EXCEEDED');
		  FND_MESSAGE.SET_TOKEN('BLANKET_NUMBER',p_blanket_number);
		  FND_MESSAGE.SET_TOKEN('BLANKET_CURRENCY',
		      g_blkt_hdr_tbl(l_blanket_header_id).currency_code);
		  FND_MESSAGE.SET_TOKEN('MAXIMUM',
		      g_blkt_hdr_tbl(l_blanket_header_id).blanket_max_amount);
		  oe_msg_pub.add;
		  x_return_status := FND_API.G_RET_STS_ERROR;
	  ELSE
		IF NVL(FND_PROFILE.VALUE('ONT_BSA_MIN_MAX_VIOLATION'),'N') = 'Y' THEN
		  FND_MESSAGE.SET_NAME('ONT','OE_BL_HDR_MAX_AMT_EXCEEDED');
		  FND_MESSAGE.SET_TOKEN('BLANKET_NUMBER',p_blanket_number);
		  FND_MESSAGE.SET_TOKEN('BLANKET_CURRENCY',
		      g_blkt_hdr_tbl(l_blanket_header_id).currency_code);
		  FND_MESSAGE.SET_TOKEN('MAXIMUM',
		      g_blkt_hdr_tbl(l_blanket_header_id).blanket_max_amount);
		  oe_msg_pub.add;
		END IF;

	  END IF;

       END IF;

  END IF; -- IF blanket header override amount control = 'N'

  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

     -- Update quantity fields on cached blanket records
     IF g_blkt_line_tbl(l_blanket_line_id).uom IS NOT NULL THEN
        g_blkt_line_tbl(l_blanket_line_id).released_quantity
              := l_released_quantity;
        IF p_fulfilled_flag = 'Y' THEN
           g_blkt_line_tbl(l_blanket_line_id).fulfilled_quantity
               := nvl(g_blkt_line_tbl(l_blanket_line_id).fulfilled_quantity,0)
                     + (l_quantity - l_old_quantity);
        END IF;
     END IF;

     -- Update amount fields on cached blanket records
     g_blkt_line_tbl(l_blanket_line_id).released_amount
                     := l_released_amount;
     g_blkt_hdr_tbl(l_blanket_header_id).released_amount
                     := l_hdr_released_amount;
     IF p_fulfilled_flag = 'Y' THEN
        g_blkt_line_tbl(l_blanket_line_id).fulfilled_amount
            := g_blkt_line_tbl(l_blanket_line_id).fulfilled_amount
                     + (l_amount - l_old_amount);
        g_blkt_hdr_tbl(l_blanket_header_id).fulfilled_amount
            := g_blkt_hdr_tbl(l_blanket_header_id).fulfilled_amount
                     + (l_amount - l_old_amount);
     END IF;

  END IF;

  if l_debug_level > 0 then
     oe_debug_pub.add('Final blkt line released qty: '||
                    g_blkt_line_tbl(l_blanket_line_id).released_quantity);
     oe_debug_pub.add('Final blkt line released amt: '||
                    g_blkt_line_tbl(l_blanket_line_id).released_amount);
     oe_debug_pub.add('Final blkt hdr released amt: '||
                    g_blkt_hdr_tbl(l_blanket_header_id).released_amount);
  end if;

  -- End of min-max checks

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
           (G_PKG_NAME
            ,'Update_Released_Qty_Amount'
            );
    END IF;
END Update_Released_Qty_Amount;


---------------------------------------------------------------------------
-- PROCEDURE Update_Blankets
---------------------------------------------------------------------------
PROCEDURE Update_Blankets
  (x_return_status    OUT NOCOPY VARCHAR2
  )
IS
  l_index            NUMBER;
BEGIN

oe_debug_pub.add('Inside update blanket');

  l_index := g_blkt_hdr_tbl.FIRST;
  WHILE l_index IS NOT NULL LOOP

      UPDATE OE_BLANKET_HEADERS_EXT
         SET RELEASED_AMOUNT = g_blkt_hdr_tbl(l_index).released_amount
             ,FULFILLED_AMOUNT = g_blkt_hdr_tbl(l_index).fulfilled_amount
       WHERE ORDER_NUMBER IN (SELECT H.ORDER_NUMBER
                                 FROM OE_BLANKET_HEADERS H
                                 WHERE  H.HEADER_ID = g_blkt_hdr_tbl(l_index).header_id);

      UPDATE OE_BLANKET_HEADERS
         SET LOCK_CONTROL    = LOCK_CONTROL + 1
       WHERE HEADER_ID = g_blkt_hdr_tbl(l_index).header_id;--bug8465849

      l_index :=  g_blkt_hdr_tbl.NEXT(l_index);



  END LOOP;

  l_index := g_blkt_line_tbl.FIRST;
  WHILE l_index IS NOT NULL LOOP

      UPDATE OE_BLANKET_LINES_EXT
         SET RELEASED_AMOUNT = g_blkt_line_tbl(l_index).released_amount
             ,RELEASED_QUANTITY = g_blkt_line_tbl(l_index).released_quantity
             ,FULFILLED_AMOUNT = g_blkt_line_tbl(l_index).fulfilled_amount
             ,FULFILLED_QUANTITY = g_blkt_line_tbl(l_index).fulfilled_quantity
         WHERE  LINE_ID = g_blkt_line_tbl(l_index).line_id;

      UPDATE OE_BLANKET_LINES
         SET LOCK_CONTROL = LOCK_CONTROL + 1
       WHERE LINE_ID =  g_blkt_line_tbl(l_index).line_id;--bug8465849

      l_index :=  g_blkt_line_tbl.NEXT(l_index);




  END LOOP;

oe_debug_pub.add('Leaving update blanket');

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
           (G_PKG_NAME
            ,'Update_Blankets'
            );
    END IF;
END Update_Blankets;


---------------------------------------------------------------------------
-- PROCEDURE Validate_Release_Shipments
-- Validates that sum of quantities/amounts across all shipments that
-- reference the same blanket are within min/max release qty/amount
-- limits on the blanket line.
---------------------------------------------------------------------------
PROCEDURE Validate_Release_Shipments
  (p_line_set_id               IN NUMBER
  ,p_blanket_number            IN NUMBER
  ,p_blanket_line_number       IN NUMBER
  ,p_currency_code             IN VARCHAR2
  ,x_return_status             OUT NOCOPY VARCHAR2
  )
IS

  l_blanket_line_id          NUMBER;
  l_blanket_header_id        NUMBER;

  l_set_quantity             NUMBER := 0;
  l_set_amount               NUMBER := 0;
  l_uom                      VARCHAR2(3);
  l_inv_item_id              NUMBER;
  l_set_line_number          NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

  FUNCTION Get_Set_Line_Number RETURN NUMBER IS
  BEGIN

    SELECT line_number
      INTO l_set_line_number
      FROM OE_ORDER_LINES
     WHERE LINE_SET_ID = p_line_set_id
       AND ROWNUM = 1;

    RETURN l_set_line_number;

  END Get_Set_Line_Number;


BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  Cache_Blanket(p_blanket_number
              ,p_blanket_line_number
              ,'Y' -- p_lock
              ,l_blanket_line_id
              ,l_blanket_header_id
              );

 l_blanket_line_id := MOD(l_blanket_line_id,G_BINARY_LIMIT);
 l_blanket_header_id := MOD(l_blanket_header_id,G_BINARY_LIMIT);
--ER 6526974
-- NO Min/Max Validations need, return
/*  IF nvl(g_blkt_line_tbl(l_blanket_line_id).OVERRIDE_RELEASE_CONTROLS_FLAG
           ,'Y') = 'Y'
  THEN
     RETURN;
  END IF;*/

  SELECT ordered_quantity_uom, inventory_item_id
    INTO l_uom, l_inv_item_id
    FROM OE_SETS
   WHERE set_id = p_line_set_id;

  SELECT SUM(nvl(ordered_quantity,0))
         ,SUM(nvl(ordered_quantity,0) * nvl(unit_selling_price,0))
    INTO l_set_quantity
         ,l_set_amount
    FROM OE_ORDER_LINES
   WHERE line_set_id = p_line_set_id
     AND blanket_number = p_blanket_number
     AND blanket_line_number = p_blanket_line_number;

  if l_debug_level > 0 then
     oe_debug_pub.add('Set Qty :'||l_set_quantity);
     oe_debug_pub.add('Set Amt :'||l_set_amount);
  end if;

  -- Min/Max Qty Validations only if UOM exists on blanket line
  IF g_blkt_line_tbl(l_blanket_line_id).uom IS NOT NULL
     AND l_set_quantity > 0
  THEN

     IF NOT OE_GLOBALS.EQUAL(l_uom,
              g_blkt_line_tbl(l_blanket_line_id).uom)
     THEN

       oe_debug_pub.add('convert uom');
       l_set_quantity := OE_Order_Misc_Util.Convert_UOM
             (p_item_id          => l_inv_item_id
             ,p_from_uom_code    => l_uom
             ,p_to_uom_code      => g_blkt_line_tbl(l_blanket_line_id).uom
             ,p_from_qty         => l_set_quantity
             );
       IF l_set_quantity < 0 THEN
        FND_MESSAGE.SET_NAME('ONT','OE_BL_UOM_CONV_FAILED');
        FND_MESSAGE.SET_TOKEN('LINE_NUMBER',Get_Set_Line_Number);
        FND_MESSAGE.SET_TOKEN('BLANKET_UOM',
                               g_blkt_line_tbl(l_blanket_line_id).uom);
        OE_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
       END IF;

     END IF;

     IF l_set_quantity <
            nvl(g_blkt_line_tbl(l_blanket_line_id).min_release_quantity,0)
          OR l_set_quantity >
             nvl(g_blkt_line_tbl(l_blanket_line_id).max_release_quantity
                                        ,l_set_quantity)
     THEN
       IF g_blkt_line_tbl(l_blanket_line_id).OVERRIDE_RELEASE_CONTROLS_FLAG = 'N' THEN
	       FND_MESSAGE.SET_NAME('ONT','OE_BL_SUM_SPLIT_MIN_MAX_QTY');
	       FND_MESSAGE.SET_TOKEN('LINE_NUMBER',Get_Set_Line_Number);
	       FND_MESSAGE.SET_TOKEN('BLANKET_UOM',
		   g_blkt_line_tbl(l_blanket_line_id).uom);
	       FND_MESSAGE.SET_TOKEN('MINIMUM',
		   g_blkt_line_tbl(l_blanket_line_id).min_release_quantity);
	       FND_MESSAGE.SET_TOKEN('MAXIMUM',
		   g_blkt_line_tbl(l_blanket_line_id).max_release_quantity);
	       oe_msg_pub.add;
	       x_return_status := FND_API.G_RET_STS_ERROR;
	ELSE
		IF  NVL(FND_PROFILE.VALUE('ONT_BSA_MIN_MAX_VIOLATION'),'N') = 'Y' THEN
			FND_MESSAGE.SET_NAME('ONT','OE_BL_SUM_SPLIT_MIN_MAX_QTY');
			FND_MESSAGE.SET_TOKEN('LINE_NUMBER',Get_Set_Line_Number);
			FND_MESSAGE.SET_TOKEN('BLANKET_UOM',
			  g_blkt_line_tbl(l_blanket_line_id).uom);
			FND_MESSAGE.SET_TOKEN('MINIMUM',
				g_blkt_line_tbl(l_blanket_line_id).min_release_quantity);
			FND_MESSAGE.SET_TOKEN('MAXIMUM',
				  g_blkt_line_tbl(l_blanket_line_id).max_release_quantity);
			oe_msg_pub.add;
		END IF;

	END IF;

     END IF;

  END IF;

  oe_debug_pub.add('Amt Checks');
  -- Min/Max Amount Validations
  IF l_set_amount <> 0 THEN

     IF p_currency_code
       <> g_blkt_hdr_tbl(l_blanket_header_id).currency_code
     THEN

       IF g_blkt_hdr_tbl(l_blanket_header_id).conversion_type_code IS NULL THEN
          FND_MESSAGE.SET_NAME('ONT','OE_BL_MISS_CONVERSION_TYPE');
          FND_MESSAGE.SET_TOKEN('BLANKET_NUMBER',p_blanket_number);
          oe_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       l_set_amount := Convert_Amount
          (p_from_currency     => p_currency_code
          ,p_to_currency       =>
                  g_blkt_hdr_tbl(l_blanket_header_id).currency_code
          ,p_conversion_date   => sysdate
          ,p_conversion_type   =>
                  g_blkt_hdr_tbl(l_blanket_header_id).conversion_type_code
          ,p_amount            => l_set_amount
          );

     END IF;

     IF (l_set_amount < nvl(g_blkt_line_tbl(l_blanket_line_id).min_release_amount,0)
       OR l_set_amount > nvl(g_blkt_line_tbl(l_blanket_line_id).max_release_amount
                      ,l_set_amount)
       )
     THEN
      IF g_blkt_line_tbl(l_blanket_line_id).OVERRIDE_RELEASE_CONTROLS_FLAG = 'N' THEN
			FND_MESSAGE.SET_NAME('ONT','OE_BL_SUM_SPLIT_MIN_MAX_AMT');
			FND_MESSAGE.SET_TOKEN('LINE_NUMBER',Get_Set_Line_Number);
			FND_MESSAGE.SET_TOKEN('BLANKET_CURRENCY',
			g_blkt_hdr_tbl(l_blanket_header_id).currency_code);
			FND_MESSAGE.SET_TOKEN('MINIMUM',
			 g_blkt_line_tbl(l_blanket_line_id).min_release_amount);
			FND_MESSAGE.SET_TOKEN('MAXIMUM',
			    g_blkt_line_tbl(l_blanket_line_id).max_release_amount);
			oe_msg_pub.add;
			x_return_status := FND_API.G_RET_STS_ERROR;
       ELSE
		IF  NVL(FND_PROFILE.VALUE('ONT_BSA_MIN_MAX_VIOLATION'),'N') = 'Y' THEN
			FND_MESSAGE.SET_NAME('ONT','OE_BL_SUM_SPLIT_MIN_MAX_AMT');
			FND_MESSAGE.SET_TOKEN('LINE_NUMBER',Get_Set_Line_Number);
			FND_MESSAGE.SET_TOKEN('BLANKET_CURRENCY',
			g_blkt_hdr_tbl(l_blanket_header_id).currency_code);
			FND_MESSAGE.SET_TOKEN('MINIMUM',
			 g_blkt_line_tbl(l_blanket_line_id).min_release_amount);
			FND_MESSAGE.SET_TOKEN('MAXIMUM',
			    g_blkt_line_tbl(l_blanket_line_id).max_release_amount);
			oe_msg_pub.add;
		END IF;
     END IF;

     END IF;

  END IF;


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
           (G_PKG_NAME
            ,'Validate_Release_Shipments'
            );
    END IF;
END Validate_Release_Shipments;

---------------------------------------------------------------------------
-- PROCEDURE Process_Releases
-- This is the main procedure for release validations against controls
-- defined on the blanket orders.
-- 1. First, requests of the type - VALIDATE_RELEASE_SHIPMENTS - are
--    executed. This would validate that sum of quantities/amounts
--    across shipments are within the min/max release qty/amount.
--    NOTE: If there is an error here, the procedure returns with
--    a status of error. No further validations are executed.
-- 2. Next, requests of type - PROCESS_RELEASE - are executed. This
--    would validate that individual order lines are within the min
--    /max release qty/amount. If line is a shipment, only a warning
--    is issued else an error is raised.
--    Also, cumulative qties/amounts across releases for a blanket
--    are also validated that it is within min/max blanket amounts. If
--    there is a validation failure here, an error is raised.
--    Cumulative qties/amounts are updated on cached blanket records:
--    g_blkt_line_tbl,g_blkt_hdr_tbl.
-- 3. If there is a failure in 2, all requests of type PROCESS_RELEASE
--    are re-set to error. The reason being that the accumulation logic
--    should be re-executed for all lines as it would not be known
--    which line caused it to go over the limits.
-- 4. If 2 is successful (all lines pass all blanket validations),
--    Update Blanket Tables with the new cumulative released qties/
--    amounts.
---------------------------------------------------------------------------
PROCEDURE Process_Releases
  (p_request_tbl      IN OUT NOCOPY OE_ORDER_PUB.Request_Tbl_Type
  ,x_return_status    OUT NOCOPY VARCHAR2
  )
IS
 I                       NUMBER;
 J                       NUMBER;
 l_return_status         VARCHAR2(3);
 l_header_id             NUMBER;
 l_qty                   NUMBER;
 l_currency_code         VARCHAR2(15);
 l_hdr_id                NUMBER;
 p_request_tbl_temp      OE_ORDER_PUB.Request_Tbl_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  if l_debug_level > 0 then
     oe_debug_pub.add('ENTER OE_Blanket_Util.Process_Releases, Num Requests :'
                            || p_request_tbl.COUNT);
  end if;

  g_blkt_line_tbl.delete;
  g_blkt_hdr_tbl.delete;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  I := p_request_tbl.FIRST;
  WHILE I IS NOT NULL LOOP

     -- Bug 3007584 - skip requests with null request type
     IF p_request_tbl(I).request_type IS NULL
        OR p_request_tbl(I).request_type <> 'VALIDATE_RELEASE_SHIPMENTS' THEN
        GOTO end_of_loop;
     END IF;

     if l_debug_level > 0 then
        oe_debug_pub.add('VALIDATE_RELEASE_SHIPMENTS, line set id: '
                               ||p_request_tbl(I).entity_id);
     end if;

     Validate_Release_Shipments
            (p_line_set_id         => p_request_tbl(I).entity_id
            ,p_blanket_number      => p_request_tbl(I).request_unique_key1
            ,p_blanket_line_number => p_request_tbl(I).request_unique_key2
            ,p_currency_code       => p_request_tbl(I).param1
            ,x_return_status       => l_return_status
            );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        oe_debug_pub.add('ret sts of error');
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        oe_debug_pub.add('ret sts of unexp error');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;
     END IF;

     p_request_tbl(I).processed := 'Y';

     <<end_of_loop>>

     I := p_request_tbl.NEXT(I);

  END LOOP;

 -- Bug 8745183 Start   Inserting data of p_request_tbl into p_request_tbl_temp whose index is entity_id
  I := p_request_tbl.FIRST;

  WHILE I IS NOT NULL LOOP
	  p_request_tbl_temp(MOD(p_request_tbl(I).entity_id,G_BINARY_LIMIT))  := p_request_tbl(I);
	  I := p_request_tbl.NEXT(I);

  END LOOP;

  -- For the process release code, we will use this p_request_tbl_temp instead of p_request_tbl.
  -- The temp table has requested sorted in ascending order of entity id which will make sure that
  -- requests with request_type = PROCESS RELEASE will get execute in ascending order of their entity id.
  -- Replaced p_request_tbl with p_request_tbl_temp for the following code.
  -- Bug 8745183 End


  I := p_request_tbl_temp.FIRST;
  WHILE I IS NOT NULL LOOP

     -- Bug 3007584 - skip requests with null request type
     IF p_request_tbl_temp(I).request_type IS NULL
        OR p_request_tbl_temp(I).request_type <> 'PROCESS_RELEASE' THEN
        GOTO end_of_loop;
     END IF;

     oe_debug_pub.add('PROCESS_RELEASE, line id: '||p_request_tbl_temp(I).entity_id);

   begin
	     select header_id
	     into l_hdr_id
	     from oe_order_lines
	     where line_id = p_request_tbl_temp(I).entity_id;


     --ER6795052
     OE_MSG_PUB.Set_Msg_Context(
            p_entity_code          => 'LINE'
          , p_entity_id            => p_request_tbl_temp(I).entity_id
	  , p_header_id            => l_hdr_id
	  , p_line_id              => p_request_tbl_temp(I).entity_id );

   Exception
	when others then
	NULL;
    End;
     -- BUG 2746595, currency code is in request_unique_key1 parameter.
     -- This is required as 2 distinct requests need to be logged for
     -- currency updates.

     l_currency_code := p_request_tbl_temp(I).request_unique_key1;

     if l_debug_level > 0 then
        oe_debug_pub.add('header currency :'||l_currency_code);
        oe_debug_pub.add('old blanket num :'||p_request_tbl_temp(I).param1);
        oe_debug_pub.add('new blanket num:'||p_request_tbl_temp(I).param11);
        oe_debug_pub.add('old blanket line num:'||p_request_tbl_temp(I).param2);
        oe_debug_pub.add('new blanket line num:'||p_request_tbl_temp(I).param12);
     end if;

     -- Blanket line remained same but some other field affecting
     -- qty or price was updated
     IF p_request_tbl_temp(I).param1 = p_request_tbl_temp(I).param11
        AND p_request_tbl_temp(I).param2 =  p_request_tbl_temp(I).param12
     THEN

     if l_debug_level > 0 then
        oe_debug_pub.add('Update qty/amt for existing blanket num :'
                          ||p_request_tbl_temp(I).param11);
     end if;

        Update_Released_Qty_Amount
            (p_line_id             => p_request_tbl_temp(I).entity_id
            ,p_blanket_number      => p_request_tbl_temp(I).param11
            ,p_blanket_line_number => p_request_tbl_temp(I).param12
            ,p_old_quantity        => p_request_tbl_temp(I).param3
            ,p_quantity            => p_request_tbl_temp(I).param13
            ,p_old_order_qty_uom   => p_request_tbl_temp(I).param4
            ,p_order_qty_uom       => p_request_tbl_temp(I).param14
            ,p_old_unit_selling_price => p_request_tbl_temp(I).param5
            ,p_unit_selling_price  => p_request_tbl_temp(I).param15
            ,p_old_inv_item_id     => p_request_tbl_temp(I).param6
            ,p_inv_item_id         => p_request_tbl_temp(I).param16
            ,p_currency_code       => l_currency_code
            ,p_fulfilled_flag      => p_request_tbl_temp(I).param8
            ,p_line_set_id         => p_request_tbl_temp(I).param9
            ,x_return_status       => l_return_status
            );

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           oe_debug_pub.add('1. ret sts of error');
           x_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           oe_debug_pub.add('1. ret sts of unexp error');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

     ELSE

        -- Increment qty/amount for new blanket line
        IF p_request_tbl_temp(I).param11 IS NOT NULL THEN

        if l_debug_level > 0 then
          oe_debug_pub.add('Increment qty/amt for new blanket num :'
                          ||p_request_tbl_temp(I).param11);
        end if;

          Update_Released_Qty_Amount
            (p_line_id             => p_request_tbl_temp(I).entity_id
            ,p_blanket_number      => p_request_tbl_temp(I).param11
            ,p_blanket_line_number => p_request_tbl_temp(I).param12
            ,p_old_quantity        => 0
            ,p_quantity            => p_request_tbl_temp(I).param13
            ,p_old_order_qty_uom   => null
            ,p_order_qty_uom       => p_request_tbl_temp(I).param14
            ,p_old_unit_selling_price => 0
            ,p_unit_selling_price  => p_request_tbl_temp(I).param15
            ,p_old_inv_item_id     => null
            ,p_inv_item_id         => p_request_tbl_temp(I).param16
            ,p_currency_code       => l_currency_code
            ,p_fulfilled_flag      => p_request_tbl_temp(I).param8
            ,p_line_set_id         => p_request_tbl_temp(I).param9
            ,x_return_status       => l_return_status
            );

        END IF;

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           oe_debug_pub.add('2. ret sts of error');
           x_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           oe_debug_pub.add('2. ret sts of unexp error');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Decrement qty/amount for old blanket line
        IF p_request_tbl_temp(I).param1 IS NOT NULL THEN

        if l_debug_level > 0 then
           oe_debug_pub.add('Decrement qty/amt for old blanket num :'
                          ||p_request_tbl_temp(I).param1);
        end if;

          Update_Released_Qty_Amount
            (p_line_id             => p_request_tbl_temp(I).entity_id
            ,p_blanket_number      => p_request_tbl_temp(I).param1
            ,p_blanket_line_number => p_request_tbl_temp(I).param2
            ,p_old_quantity        => p_request_tbl_temp(I).param3
            ,p_quantity            => 0
            ,p_old_order_qty_uom   => p_request_tbl_temp(I).param4
            ,p_order_qty_uom       => null
            ,p_old_unit_selling_price => p_request_tbl_temp(I).param5
            ,p_unit_selling_price  => 0
            ,p_old_inv_item_id     => p_request_tbl_temp(I).param6
            ,p_inv_item_id         => null
            ,p_currency_code       => l_currency_code
            ,p_fulfilled_flag      => p_request_tbl_temp(I).param8
            ,p_line_set_id         => p_request_tbl_temp(I).param9
            ,x_return_status       => l_return_status
            );

        END IF;

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           oe_debug_pub.add('3. ret sts of error');
           x_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           oe_debug_pub.add('3. ret sts of unexp error');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

     END IF;

     p_request_tbl_temp(I).processed := 'Y';

--  Bug 8745183 Start

     J := p_request_tbl.FIRST;

     LOOP

     if p_request_tbl(J).entity_id = I
       AND p_request_tbl(J).request_type = 'PROCESS_RELEASE' then

           p_request_tbl(J).processed := 'Y';
     END IF;

     J := p_request_tbl.NEXT(J);

     EXIT WHEN J IS NULL;

     END LOOP;

-- Bug 8745183 End

     <<end_of_loop>>

     I := p_request_tbl_temp.NEXT(I);

	OE_MSG_PUB.Reset_Msg_Context('LINE');
  END LOOP;


  -- Error during updates, mark the requests as NOT processed
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

      if l_debug_level > 0 then
         oe_debug_pub.add('Overall Ret Sts :'||x_return_status);
      end if;

      I := p_request_tbl.FIRST;
      WHILE I IS NOT NULL LOOP
        IF p_request_tbl(I).request_type = 'PROCESS_RELEASE' THEN
           if l_debug_level > 0 then
              oe_debug_pub.add('Set req to NOT processed at index :'||I);
           end if;
           p_request_tbl(I).processed := 'N';
        END IF;
        I := p_request_tbl.NEXT(I);
      END LOOP;

  -- Updates of quantity/amounts was successful!
  -- Update these values on the DB for blanket headers/lines table.
  ELSIF g_blkt_line_tbl.COUNT > 0 THEN

      Update_Blankets(l_return_status);

      -- Only if blankets update is successful,
      -- delete the old order released qty/amount also.
      IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN

         oe_debug_pub.add('delete cache');
         g_bl_order_val_tbl.delete;
         g_bh_order_val_tbl.delete;

      END IF;

  END IF;

  if l_debug_level > 0 then
     oe_debug_pub.add('EXIT OE_Blanket_Util.Process_Releases');
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
           (G_PKG_NAME
            ,'Process_Releases'
            );
    END IF;
END Process_Releases;

-- Sub-procedure, called twice for both old and new blanket
-- reference on the line.
PROCEDURE Populate_Old_Values
(p_blanket_number              IN NUMBER
,p_blanket_line_number         IN NUMBER
,p_line_id                     IN NUMBER
,p_old_quantity                IN NUMBER DEFAULT NULL
,p_old_unit_sp                 IN NUMBER DEFAULT NULL
,p_header_id                   IN NUMBER DEFAULT NULL
)
IS
l_return_status         VARCHAR2(3);
l_header_id                   NUMBER;
l_blanket_header_id           NUMBER;
l_blanket_line_id             NUMBER;
l_old_quantity                NUMBER;
l_old_unit_sp                 NUMBER;
l_old_amount                  NUMBER;
l_rem_bl_line_qty             NUMBER;
l_rem_bl_line_amt             NUMBER;
l_rem_bl_hdr_amt              NUMBER;
l_currency_code         VARCHAR2(15);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    if l_debug_level > 0 then
       oe_debug_pub.add('Enter Populate_Old_Values');
       oe_debug_pub.add('Blanket Num :'||p_blanket_number);
       oe_debug_pub.add('Blanket Line Num :'||p_blanket_line_number);
       oe_debug_pub.add('Line ID :'||p_line_id);
       oe_debug_pub.add('Header ID :'||p_header_id);
       oe_debug_pub.add('Old Qty :'||p_old_quantity);
       oe_debug_pub.add('Old Selling Price :'||p_old_unit_sp);
    end if;

    -- Do not lock when caching old values
    Cache_Blanket
        (p_blanket_number => p_blanket_number
        ,p_blanket_line_number => p_blanket_line_number
        ,p_lock => 'N'
        ,x_blanket_header_id => l_blanket_header_id
        ,x_blanket_line_id => l_blanket_line_id
        );

    l_blanket_header_id := MOD(l_blanket_header_id,G_BINARY_LIMIT);--bug8465849
    l_blanket_line_id := MOD(l_blanket_line_id,G_BINARY_LIMIT);--bug8465849

    -- If not cached already, retrieve the old values
    IF NOT g_bl_order_val_tbl.exists(l_blanket_line_id)THEN

       IF p_header_id IS NULL
          OR p_old_quantity IS NULL
       THEN

          BEGIN
          SELECT HEADER_ID, ORDERED_QUANTITY, UNIT_SELLING_PRICE
            INTO l_header_id, l_old_quantity, l_old_unit_sp
            FROM OE_ORDER_LINES_ALL
           WHERE LINE_ID = p_line_id;
          EXCEPTION
            -- If QP sourcing API is called while the line is still not
            -- saved e.g. when tabbing out of qty field from the UI, no data
            -- found exception will result and it should be handled.
            WHEN NO_DATA_FOUND THEN
              l_old_quantity := 0;
              l_old_unit_sp := 0;
          END;

       END IF;

       IF p_old_quantity IS NOT NULL THEN
          l_old_quantity := p_old_quantity;
       END IF;

       IF p_old_unit_sp IS NOT NULL THEN
          l_old_unit_sp := p_old_unit_sp;
       END IF;

       IF p_header_id IS NOT NULL THEN
          l_header_id := p_header_id;
       END IF;

       -- Bug 3390070
       -- Use l_old_quantity/unit_sp instead of p_old_quantity/unit_sp
       -- Because it was using wrong variables, old amount was not
       -- calculated correctly thus resulting in incorrect values for
       -- blanket amount and blanket line amount accumulations.
       l_old_amount := nvl(l_old_quantity,0) * nvl(l_old_unit_sp,0);

         -- Compute the old qty/amt consumed against this blanket line
         -- from other lines on this order
         SELECT sum(nvl(ordered_quantity,0)),
                sum(nvl(ordered_quantity,0)*nvl(unit_selling_price,0))
           INTO l_rem_bl_line_qty
                ,l_rem_bl_line_amt
           FROM OE_ORDER_LINES_ALL
          WHERE HEADER_ID = l_header_id
            AND BLANKET_NUMBER = p_blanket_number
            AND BLANKET_LINE_NUMBER = p_blanket_line_number
            AND LINE_ID <> p_line_id;

       -- Update old order values on the blanket line cache
       g_bl_order_val_tbl(l_blanket_line_id).order_released_quantity
          := nvl(l_rem_bl_line_qty,0) + l_old_quantity;
       g_bl_order_val_tbl(l_blanket_line_id).order_released_amount
          := nvl(l_rem_bl_line_amt,0) + l_old_amount;

       -- If blanket hdr amt NOT cached already, cache the old values
       IF NOT g_bh_order_val_tbl.exists(l_blanket_header_id)THEN

         -- Compute the old qty/amt consumed against this blanket header
         -- from other lines on this order
         SELECT sum(nvl(ordered_quantity,0)*nvl(unit_selling_price,0))
           INTO l_rem_bl_hdr_amt
           FROM OE_ORDER_LINES_ALL
          WHERE HEADER_ID = l_header_id
            AND BLANKET_NUMBER = p_blanket_number
            AND LINE_ID <> p_line_id;

          -- Update old order values on the blanket header cache
          g_bh_order_val_tbl(l_blanket_header_id).order_released_amount
              := nvl(l_rem_bl_hdr_amt,0) + l_old_amount;

       END IF;

       if l_debug_level > 0 then
          oe_debug_pub.add('order header id :'||l_header_id);
          oe_debug_pub.add('rem bl line qty :'||nvl(l_rem_bl_line_qty,0));
          oe_debug_pub.add('rem bl line amt :'||nvl(l_rem_bl_line_amt,0));
          oe_debug_pub.add('rem bl hdr amt :'||nvl(l_rem_bl_hdr_amt,0));
          oe_debug_pub.add('old qty :'||l_old_quantity);
          oe_debug_pub.add('old amt :'||l_old_amount);
       end if;

    END IF; -- if not cached

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
           (G_PKG_NAME
            ,'Populate_Old_Values'
            );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Populate_Old_Values;

PROCEDURE Cache_Order_Qty_Amt
  (p_request_rec      IN OUT NOCOPY OE_ORDER_PUB.Request_Rec_Type
  ,x_return_status    OUT NOCOPY VARCHAR2
  )
IS
 l_return_status         VARCHAR2(3);
 l_header_id                   NUMBER;
 l_blanket_header_id           NUMBER;
 l_blanket_line_id             NUMBER;
 l_blanket_number              NUMBER;
 l_blanket_line_number         NUMBER;
 l_old_line_quantity           NUMBER;
 l_rem_lines_quantity          NUMBER;
 l_currency_code         VARCHAR2(15);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

BEGIN

  if l_debug_level > 0 then
     oe_debug_pub.add('ENTER OE_Blkt_Release_Util.Cache_Order_Qty_Amt');
  end if;

  x_return_status := fnd_api.g_ret_sts_success;

  -- Blanket reference not updated, some other attribute on line updated
  IF p_request_rec.param1 = p_request_rec.param11
     AND p_request_rec.param2 = p_request_rec.param12
  THEN

     Populate_Old_Values
       (p_blanket_number => p_request_rec.param1
       ,p_blanket_line_number => p_request_rec.param2
       ,p_line_id => p_request_rec.entity_id
       ,p_old_quantity => nvl(p_request_rec.param3,0)
       ,p_old_unit_sp => nvl(p_request_rec.param5,0)
       );

  ELSE

     -- New reference, hence no values were sourced for this blanket
     -- from this line previously.
     IF p_request_rec.param11 IS NOT NULL THEN

     Populate_Old_Values
       (p_blanket_number => p_request_rec.param11
       ,p_blanket_line_number => p_request_rec.param12
       ,p_line_id => p_request_rec.entity_id
       ,p_old_quantity => 0
       ,p_old_unit_sp => 0
       );

     END IF;

     -- Cleared an old blanket reference
     IF p_request_rec.param1 IS NOT NULL THEN

     Populate_Old_Values
       (p_blanket_number => p_request_rec.param1
       ,p_blanket_line_number => p_request_rec.param2
       ,p_line_id => p_request_rec.entity_id
       ,p_old_quantity => nvl(p_request_rec.param3,0)
       ,p_old_unit_sp => nvl(p_request_rec.param5,0)
       );

     END IF;

  END IF;

  if l_debug_level > 0 then
     oe_debug_pub.add('EXIT OE_Blkt_Release_Util.Cache_Order_Qty_Amt');
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
           (G_PKG_NAME
            ,'Cache_Order_Qty_Amt'
            );
    END IF;
END Cache_Order_Qty_Amt;

END;

/
