--------------------------------------------------------
--  DDL for Package Body OE_FREIGHT_RATING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_FREIGHT_RATING_PVT" AS
/* $Header: OEXVFRRB.pls 120.0.12010000.2 2009/06/26 12:28:41 nitagarw ship $ */

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_FREIGHT_RATING_PVT';
G_BINARY_LIMIT CONSTANT NUMBER := OE_GLOBALS.G_BINARY_LIMIT; -- Added for bug 8636027

PROCEDURE Print_Time(p_msg   IN  VARCHAR2);

PROCEDURE Prepare_Adj_Detail
 (p_header_id              IN   NUMBER
 ,p_line_id                IN   NUMBER
 ,p_adj_index              IN   NUMBER
 ,p_fte_rates_rec          IN   FTE_PROCESS_REQUESTS.Fte_Source_Line_Rates_Rec
 ,x_line_adj_rec           OUT NOCOPY OE_Order_PUB.Line_Adj_Rec_Type

 ,x_return_status          OUT NOCOPY VARCHAR2

);


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
        oe_debug_pub.add(  'ENTERING OE_FREIGHT_RATING_PVT.GET_LIST_LINE_TYPE_CODE' , 1 ) ;
    END IF;

    IF 	p_key IS NOT NULL THEN

        -- list_line_type_code is already cached.
        IF g_list_line_type_code_tbl.Exists(MOD(p_key,G_BINARY_LIMIT)) THEN

         l_list_line_type_code
            := g_list_line_type_code_tbl(MOD(p_key,G_BINARY_LIMIT)).list_line_type_code;

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'LIST LINE TYPE CODE FOR HEADER: ' || P_KEY ||' IS: ' || L_LIST_LINE_TYPE_CODE , 3 ) ;
            END IF;

        ELSE

           BEGIN
           SELECT  list_line_type_code
           INTO   l_list_line_type_code
           FROM   oe_price_adjustments
           WHERE  header_id = p_key
           AND    list_header_id = p_key * (-1);

           EXCEPTION WHEN NO_DATA_FOUND THEN
             l_list_line_type_code := NULL;
           END;

           IF l_list_line_type_code IS NOT NULL THEN
           l_list_line_type_code_rec.list_line_type_code
                 := l_list_line_type_code;
           g_list_line_type_code_tbl(MOD(p_key,G_BINARY_LIMIT))
                 := l_list_line_type_code_rec;

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'LOADING LIST LINE TYPE CODE FOR HEADER: ' || P_KEY ||' IS: ' || L_LIST_LINE_TYPE_CODE , 3 ) ;
            END IF;
           END IF;



        END IF;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_FREIGHT_RATING_PVT.GET_LIST_LINE_TYPE_CODE' , 1 ) ;
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


/*--------------------------------------------------------------+
 | Name        :   Print_Time                                   |
 | Parameters  :   IN  p_msg                                    |
 |                                                              |
 | Description :   This Procedure will print Current time along |
 |                 with the Debug Message Passed as input.      |
 |                 This Procedure will be called from Main      |
 |                 Procedures to print Entering and Leaving Msg |
 +--------------------------------------------------------------*/
PROCEDURE Print_Time(p_msg   IN  VARCHAR2)
IS
  l_time    VARCHAR2(100);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
    l_time := to_char (new_time (sysdate, 'PST', 'EST'),
                                 'DD-MON-YY HH24:MI:SS');
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  P_MSG || ': '|| L_TIME , 1 ) ;
    END IF;
END Print_Time;

PROCEDURE Prepare_Adj_Detail
( p_header_id       IN   NUMBER
 ,p_line_id         IN   NUMBER
 ,p_adj_index       IN   NUMBER
 ,p_fte_rates_rec   IN   FTE_PROCESS_REQUESTS.Fte_Source_Line_Rates_rec
 ,x_line_adj_rec    OUT NOCOPY OE_Order_PUB.Line_Adj_Rec_Type

 ,x_return_status   OUT NOCOPY VARCHAR2

) IS

  l_price_adjustment_id     number := 0;

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING PROCEDURE PREPARE_ADJ_DETAIL.' , 3 ) ;
    END IF;
    x_return_status   := FND_API.G_RET_STS_SUCCESS;

    select oe_price_adjustments_s.nextval into l_price_adjustment_id
    from dual;

                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'PRICE ADJUSTMENT ID IN PREPARE_ADJ_DETAIL IS: ' ||L_PRICE_ADJUSTMENT_ID , 1 ) ;
                      END IF;
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'LINE_ID IN PREPARE_ADJ_DETAIL IS: ' ||P_LINE_ID , 1 ) ;
                      END IF;

    x_line_adj_rec.header_id := p_header_id;
    x_line_adj_rec.line_id := p_line_id;
    x_line_adj_rec.price_adjustment_id := l_price_adjustment_id;
    x_line_adj_rec.creation_date := sysdate;
    x_line_adj_rec.last_update_date := sysdate;
    x_line_adj_rec.created_by := 1;
    x_line_adj_rec.last_updated_by := 1;
    x_line_adj_rec.last_update_login := 1;

    x_line_adj_rec.automatic_flag := 'N';
    x_line_adj_rec.adjusted_amount := p_fte_rates_rec.adjusted_price;
    x_line_adj_rec.charge_type_code := p_fte_rates_rec.cost_type;
    x_line_adj_rec.list_line_type_code := 'COST';
    x_line_adj_rec.estimated_flag := 'Y';
    x_line_adj_rec.source_system_code := 'FTE';

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING PROCEDURE PREPARE_ADJ_DETAIL.' , 3 ) ;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR IN PROCEDURE PREPARE_ADJ_DETAIL: '||SUBSTR ( SQLERRM , 1 , 240 ) , 3 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNEXPECTED ERROR IN PREPRARE_ADJ_DETAIL :'||SQLERRM , 3 ) ;
      END IF;
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Prepare_Adj_Detail');
      END IF;



END Prepare_Adj_Detail;


PROCEDURE Process_FTE_Output
( p_header_id              IN  NUMBER
 ,p_x_fte_source_line_tab  IN  OUT NOCOPY FTE_PROCESS_REQUESTS.Fte_Source_Line_Tab
 ,p_x_line_tbl             IN  OUT NOCOPY OE_ORDER_PUB.line_tbl_type
 ,p_fte_rates_tab          IN  FTE_PROCESS_REQUESTS.Fte_Source_Line_Rates_Tab
 ,p_config_count           IN  NUMBER
 ,p_ui_flag                IN  VARCHAR2
 ,p_call_pricing_for_FR    IN  VARCHAR2
 ,x_return_status          OUT NOCOPY VARCHAR2 )

IS
  l_fte_count    	NUMBER   :=  1;
  l_index          	NUMBER   :=  0;
  l_adj_index      	NUMBER   :=  1;
  l_line_id          	NUMBER;
  l_ato_line_id       	NUMBER;
  l_price_adjustment_id NUMBER;
  l_price_control_rec 	OE_ORDER_PRICE_PVT.control_rec_type;
  l_request_rec        	oe_order_pub.request_rec_type;
  l_line_adj_rec    	OE_Order_PUB.Line_Adj_Rec_Type;
  l_line_adj_tbl 	oe_order_pub.line_adj_tbl_type;
  l_fte_rates_rec      	FTE_PROCESS_REQUESTS.Fte_Source_Line_Rates_rec;
  l_bulk_adj_rec      	Bulk_Line_Adj_Rec_Type;
  l_return_status       VARCHAR2(1);
  I                 	pls_integer;
  J                 	pls_integer;
  k                 	pls_integer;
  l_pricing_event       VARCHAR2(30);
  l_line_id_tbl         Number_Type;

  CURSOR   C_CONFIG_ITEM_PARENTS(p_ato_line_id IN NUMBER) IS
           SELECT  opa.price_adjustment_id,ool.line_id,
                   opa.adjusted_amount, opa.list_line_type_code,
                   opa.charge_type_code
           FROM    oe_order_lines ool
                  ,oe_price_adjustments opa
           WHERE   opa.charge_type_code IN ('FTEPRICE','FTECHARGE')
           AND     ool.line_id = opa.line_id
           AND     ool.item_type_code <> OE_GLOBALS.G_ITEM_CONFIG
           AND     ool.ato_line_id = p_ato_line_id;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  Print_Time('Entering OE_Freight_Rating_PVT.Process_FTE_Output..');

  x_return_status   := FND_API.G_RET_STS_SUCCESS;


  -- delete the old records from previous FTE call.
  DELETE FROM OE_PRICE_ADJUSTMENTS
  WHERE HEADER_ID = P_HEADER_ID
  AND   CHARGE_TYPE_CODE IN ('FTEPRICE','FTECHARGE')
  AND   list_line_type_code = 'COST'
  AND   ESTIMATED_FLAG = 'Y'
  RETURNING line_id bulk collect into l_line_id_tbl;

  k := l_line_id_tbl.FIRST;
  WHILE k is not null LOOP

    OE_LINE_ADJ_UTIL.Register_Changed_Lines
      (p_line_id         => l_line_id_tbl(k),
       p_header_id       => p_header_id,
       p_operation       => OE_GLOBALS.G_OPR_UPDATE);
    k := l_line_id_tbl.NEXT(k);
  END LOOP;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'TOTAL NUMBER OF CONFIG LINES:'||P_CONFIG_COUNT , 3 ) ;
  END IF;

  -- initialize these values for FTE rates.
  l_index := 1;

  -- insert the FTE output to database table.
  I := p_fte_rates_tab.FIRST;
  WHILE I IS NOT NULL LOOP
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  '============ FTE RESULTS ============' , 3 ) ;
    END IF;

                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'SOURCE LINE :'|| P_FTE_RATES_TAB ( I ) .SOURCE_LINE_ID , 3 ) ;
                      END IF;
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'COST TYPE :'|| P_FTE_RATES_TAB ( I ) .COST_TYPE , 3 ) ;
                      END IF;
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'COST SUB TYPE :'|| P_FTE_RATES_TAB ( I ) .COST_SUB_TYPE , 3 ) ;
                      END IF;
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'PRICED QUANTITY :'|| P_FTE_RATES_TAB ( I ) .PRICED_QUANTITY , 3 ) ;
                      END IF;
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'PRICED UOM :'|| P_FTE_RATES_TAB ( I ) .PRICED_UOM , 3 ) ;
                      END IF;
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'UNIT PRICE :'|| P_FTE_RATES_TAB ( I ) .UNIT_PRICE , 3 ) ;
                      END IF;
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'BASE PRICE :'|| P_FTE_RATES_TAB ( I ) .BASE_PRICE , 3 ) ;
                      END IF;
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'ADJUSTED UNIT PRICE :'|| P_FTE_RATES_TAB ( I ) .ADJUSTED_UNIT_PRICE , 3 ) ;
                      END IF;
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'ADJUSTED PRICE :'|| P_FTE_RATES_TAB ( I ) .ADJUSTED_PRICE , 3 ) ;
                      END IF;
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'CURRENCY :'|| P_FTE_RATES_TAB ( I ) .CURRENCY , 3 ) ;
                      END IF;

    Prepare_Adj_Detail
       (p_header_id => p_header_id
       ,p_line_id   => p_fte_rates_tab(I).source_line_id
       ,p_adj_index  => l_adj_index
       ,p_fte_rates_rec => p_fte_rates_tab(I)
       ,x_line_adj_rec  => l_line_adj_rec
       ,x_return_status => x_return_status
       );


    l_line_adj_tbl(l_adj_index) := l_line_adj_rec;

    OE_LINE_ADJ_UTIL.INSERT_ROW(l_line_adj_rec);

    -- to register changed line so that repricing for this line
    -- would happen.
    oe_debug_pub.add('Register changed line: '||p_fte_rates_tab(I).source_line_id,1);
    OE_LINE_ADJ_UTIL.Register_Changed_Lines
      (p_line_id         => p_fte_rates_tab(I).source_line_id,
       p_header_id       => p_header_id,
       p_operation       => OE_GLOBALS.G_OPR_UPDATE);

    l_adj_index :=  l_adj_index  + 1;
    I := p_fte_rates_tab.NEXT(I);

  END LOOP;

  -- cascade the estimated charges from parent lines to config item lines
  -- and insert into database.
  l_adj_index := 1;
  WHILE l_index <= p_config_count LOOP

    l_line_id := p_x_line_tbl(l_index).line_id;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CASCADING ADJUSTMENT LINES TO CONFIG LINES. ' , 3 ) ;
    END IF;

    OPEN C_CONFIG_ITEM_PARENTS(p_x_line_tbl(l_index).ato_line_id);
    FETCH C_CONFIG_ITEM_PARENTS BULK COLLECT INTO
         l_bulk_adj_rec.price_adjustment_id
         ,l_bulk_adj_rec.line_id
         ,l_bulk_adj_rec.adjusted_amount
         ,l_bulk_adj_rec.list_line_type_code
         ,l_bulk_adj_rec.charge_type_code
         ;

    CLOSE C_CONFIG_ITEM_PARENTS;


    FOR i in 1..l_bulk_adj_rec.price_adjustment_id.COUNT LOOP

      l_fte_rates_rec.cost_type := l_bulk_adj_rec.charge_type_code(i);
      l_fte_rates_rec.adjusted_price := l_bulk_adj_rec.adjusted_amount(i);


      Prepare_Adj_Detail
         (p_header_id => p_header_id
         ,p_line_id   => l_line_id
         ,p_adj_index   => l_adj_index
         ,p_fte_rates_rec =>  l_fte_rates_rec
         ,x_line_adj_rec  => l_line_adj_rec
         ,x_return_status => x_return_status
          );

      l_line_adj_tbl(l_adj_index) := l_line_adj_rec;

      -- inserting for the config line
      OE_LINE_ADJ_UTIL.INSERT_ROW(l_line_adj_rec);

      -- register changed line for config item line.
      OE_LINE_ADJ_UTIL.Register_Changed_Lines
      (p_line_id         => l_line_id,
       p_header_id       => p_header_id,
       p_operation       => OE_GLOBALS.G_OPR_UPDATE);

      -- deleting the parents of the config line.
      -- these deleted parent lines have been registered in
      -- previous loop looping through p_fte_rates_tab, so
      -- no need to register changed line again for these lines.
      DELETE FROM oe_price_adjustments
      WHERE price_adjustment_id = l_bulk_adj_rec.price_adjustment_id(i);

      l_adj_index :=  l_adj_index  + 1;

    END LOOP;

    l_index := l_index + 1;

  END LOOP;

  -- for ATO lines, only send config lines to Pricing.
  J := p_x_line_tbl.FIRST;
  WHILE J IS NOT NULL LOOP
    -- delete those non-shippable ATO parent lines
    IF p_x_line_tbl(J).ato_line_id IS NOT NULL
       AND p_x_line_tbl(J).item_type_code <> OE_GLOBALS.G_ITEM_CONFIG THEN
       p_x_line_tbl.delete(J);
    END IF;

    J := p_x_line_tbl.NEXT(J);

  END LOOP;

  -- Calling Pricing Engine to calculate freight charges
  -- if being called from Action button.
   IF NVL(p_ui_flag, 'N') = 'Y' THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CALLING PRICING ENGINE FOR FREIGHT FOR: '||P_HEADER_ID , 1 ) ;
     END IF;

     l_price_control_rec.p_request_type_code:='ONT';
     l_Price_control_rec.p_write_to_db:=TRUE;
     l_price_control_rec.p_honor_price_flag:='Y';
     l_price_control_rec.p_multiple_events:='N';
     l_price_control_rec.p_get_freight_flag:='Y';

     oe_order_price_pvt.price_line
                 (p_Header_id        => p_header_id
                 ,p_Line_id          => null
                 ,px_line_Tbl        => p_x_line_tbl
                 ,p_Control_Rec      => l_price_control_rec
                 ,p_action_code      => 'PRICE_ORDER'
                 ,p_Pricing_Events   => 'BATCH'
                 ,x_Return_Status    => l_return_status
                 );

  END IF;


  -- if this is called from Action button and it is the first time
  -- FTE being called.
  IF NVL(OE_FREIGHT_RATING_UTIL.get_list_line_type_code(p_header_id),'N')
         <> 'OM_CALLED_FREIGHT_RATES' THEN

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



  Print_Time('Entering OE_Freight_Rating_PVT.Process_FTE_Output..');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXPECTED ERROR IN PROCESS FTE OUTPUT' , 1 ) ;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                                                            IF l_debug_level  > 0 THEN
                                                                oe_debug_pub.add(  'UNEXPECTED ERROR IN PROCESS FTE OUTPUT'|| SQLERRM , 2 ) ;
                                                            END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Process_FTE_Output');
        END IF;
END Process_FTE_Output;

END OE_FREIGHT_RATING_PVT;

/
