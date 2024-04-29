--------------------------------------------------------
--  DDL for Package Body OE_CONFIG_PRICE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CONFIG_PRICE_UTIL" AS
/* $Header: OEXUCFPB.pls 120.0.12010000.3 2009/01/22 11:11:56 srsunkar ship $ */

--  Global constant holding the package name
G_PKG_NAME      CONSTANT    VARCHAR2(30):='Oe_Config_Price_Util';


/*----------------------------------------------------------------------
 PROCEDURE OE_Config_Price_Items:

   get selected options from cz_pricing_structures table.
   For list price, CZ sends to this API qty per unit model.
   For selling price, Configurator sends to this API the actual
   ordered quantity.

   Configurator send to us the config_session_key. This key is what we
   passed to them initially when the configurator form was opened.
   This is of the form top_model_line_id#session_id. We use this key
   to get the top_model_line_id. It is also the primary key for the CZ
   table from which we get the options to price.

   For each option sent in we do the following:
   1. Get inventory_item_id from the item_key.
      item_key in cz_pricing_structures table is concatenation of
      component_code, explosion_type, organization_id, top_item_id.
      These values are separated by ':'.  We will parse the item_key
      to get inventory_item_id(from the component code)
      The order of concatenation is imp, if Configurator changes it,
      there will be bugs.
   2. Create the line records (for new options).

   For a restored configuration, we use the unit_list_price, and
   unit_selling_price from order management tables directly.

   Call price_lines API for all the new options. Update the CZ pricing
   structures table with list price/selling price obtained from the
   pricing API.

Change Record:
 bug fix: if in an existing configuration. qty of options modified,
 selling price will be affected (list price we always get per unit.)
 do not update using old pricing data from oe_order_lines.
 oe_debug_pub.add('updating selling prices of already saved options', 1);

 bug 2211600 : operationis set to CREATE on the line records.

 Recurring Charges: The call to OE_DEFAULT_LINE.Attributes for every child line
 of network model will mean that it affects performance of pricing callback as
 compare d to a regualr PTO or ATO model.
--------------------------------------------------------------------------*/

PROCEDURE OE_Config_Price_Items
(  p_config_session_key      IN  VARCHAR2
  ,p_price_type              IN  VARCHAR2 -- list, selling
  ,x_total_price             OUT NOCOPY NUMBER

 )
IS

  l_header_id                     NUMBER;
  l_top_model_line_id             NUMBER;
  l_index                         NUMBER;
  l_seq_nbr                       NUMBER;
  l_item_key                      VARCHAR2(2000);
  l_price_control_rec             QP_PREQ_GRP.Control_record_type;
  l_total_price                   NUMBER;
  l_model_item_key                VARCHAR2(2000);
  l_config_pricing_error          VARCHAR2(2000);
  l_return_status                 VARCHAR2(1);
  l_line_tbl                      OE_Order_PUB.Line_Tbl_Type;
  l_line_rec                      OE_ORDER_PUB.Line_Rec_Type;
  l_top_line_id_pos               NUMBER;
  l_model_line_rec                OE_Order_Pub.Line_Rec_Type;
  l_defaulted_flag                VARCHAR2(1);
  l_old_line_rec                  OE_Order_Pub.Line_Rec_Type;
  l_pricing_callback_off          VARCHAR2(1);

  l_time_start                    VARCHAR2(100);
  l_time_upd                      VARCHAR2(100);
  l_time_po                       VARCHAR2(100);
  l_time_read                     VARCHAR2(100);
  l_time_bef_price                VARCHAR2(100);
  l_time_price                    VARCHAR2(100);
  l_time_end                      VARCHAR2(100);

  l_bom_item_type                 NUMBER;
  l_pick_components_flag          VARCHAR2(1);
  l_service_item_flag             VARCHAR2(1);
  l_top_container_model           VARCHAR2(1);
  l_part_of_container             VARCHAR2(1);

  CURSOR options_to_be_priced IS
  SELECT cz.item_key, cz.quantity, cz.uom_code
        ,item.bom_item_type, item.service_item_flag
        ,item.pick_components_flag, item.inventory_item_id
        ,cz.seq_nbr
  FROM   CZ_PRICING_STRUCTURES cz
       , MTL_SYSTEM_ITEMS item
  WHERE  cz.item_key_type = cz_prc_callback_util.g_item_key_bom_node
  AND    cz.configurator_session_key = p_config_session_key
  AND    (cz.list_price is null
  OR      cz.selling_price is null)
  AND    item.inventory_item_id = to_number(SUBSTR((SUBSTR( cz.item_key,
                                            1, INSTR(cz.item_key, ':') - 1)),
         INSTR(( SUBSTR( cz.item_key, 1, INSTR(cz.item_key, ':') - 1)),
         '-', -1) + 1 ))
  AND    organization_id =  OE_Sys_Parameters.Value('MASTER_ORGANIZATION_ID');

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  l_pricing_callback_off := FND_PROFILE.VALUE('ONT_BYPASS_PRICING_CALLBACK');

  IF nvl(upper(l_pricing_callback_off), 'N') = 'Y' THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('CONFIGURATOR PRICING CALLBACK TURNED OFF', 1);
    END IF;
    x_total_price := 0;
    RETURN;
  ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('CONFIGURATOR PRICING CALLBACK IS ON', 1);
    END IF;
  END IF;

  l_time_start :=  to_char (new_time (sysdate, 'PST', 'EST'),
  'DD-MON-YY HH24:MI:SS');


  ------------------- parse session_key ----------------------

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING OE_CONFIG_PRICE_ITEMS', 1);
  END IF;

  -- ex => '120000#10000', extract top_model_line_id from session_key

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('CONFIG_SESSION_KEY: '|| P_CONFIG_SESSION_KEY , 1);
  END IF;

  l_top_line_id_pos :=
        INSTR(p_config_session_key, '#' );
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('MODEL END POS: '|| L_TOP_LINE_ID_POS , 1);
  END IF;


  l_top_model_line_id :=  TO_NUMBER(SUBSTR(p_config_session_key, 1,
                                           l_top_line_id_pos - 1 ));

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('L_TOP_MODEL_LINE_ID: ' || L_TOP_MODEL_LINE_ID , 1);
  END IF;


  --------------------- restored configuration ---------------

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('UPDATING LIST PRICES ALREADY SAVED OPTIONS', 1);
    END IF;

    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110508' THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('PRICING CALLBACK: PACK H NEW LOGIC MI', 1);
      END IF;

      UPDATE CZ_PRICING_STRUCTURES cz
      SET cz.list_price    =
      ( SELECT ol.unit_list_price
        FROM   OE_ORDER_LINES ol
        WHERE  ol.top_model_line_id = l_top_model_line_id
        AND    ol.component_code =
               SUBSTR( cz.item_key, 1, INSTR(cz.item_key, ':') - 1)
                        --commented this check as for the first time when pricing call back is done the configuration_id
		        --is not present in OE_ORDER_LINES table hence the query fails and price for the model is not
		        --displayed.
        --AND     ol.configuration_id = cz.config_item_id--bug#7595079
      )
      WHERE cz.configurator_session_key = p_config_session_key;

      UPDATE CZ_PRICING_STRUCTURES cz
      SET cz.selling_price    =
      ( SELECT ol.unit_selling_price
        FROM   OE_ORDER_LINES ol
        WHERE  ol.top_model_line_id = l_top_model_line_id
        AND    ol.ordered_quantity  = cz.quantity -- only if no change in qty
        AND    ol.component_code =
               SUBSTR( cz.item_key, 1, INSTR(cz.item_key, ':') - 1)
                                --commented this check as for the first time when pricing call back is done the configuration_id
			        --is not present in OE_ORDER_LINES table hence the query fails and price for the model is not
			        --displayed.
        --AND     ol.configuration_id = cz.config_item_id--bug#7595079
       )
      WHERE cz.configurator_session_key = p_config_session_key;

    ELSE

      UPDATE CZ_PRICING_STRUCTURES cz
      SET cz.list_price    =
      ( SELECT ol.unit_list_price
        FROM   OE_ORDER_LINES ol
        WHERE  ol.top_model_line_id = l_top_model_line_id
        AND    ol.component_code =
               SUBSTR( cz.item_key, 1, INSTR(cz.item_key, ':') - 1)
      )
      WHERE cz.configurator_session_key = p_config_session_key;

      UPDATE CZ_PRICING_STRUCTURES cz
      SET cz.selling_price    =
      ( SELECT ol.unit_selling_price
        FROM   OE_ORDER_LINES ol
        WHERE  ol.top_model_line_id = l_top_model_line_id
        AND    ol.ordered_quantity  = cz.quantity -- only if no change in qty
        AND    ol.component_code =
               SUBSTR( cz.item_key, 1, INSTR(cz.item_key, ':') - 1))
      WHERE cz.configurator_session_key = p_config_session_key;
  END IF;

  l_time_upd :=  to_char
  (new_time
  (sysdate, 'PST', 'EST'),
  'DD-MON-YY HH24:MI:SS');


  ----------------- read cz table ---------------------------

  -- if ato model continue with model line.
  -- pto, default 1 and continue

   OE_Line_Util.Query_Row(p_line_id  => l_top_model_line_id,
                          x_line_rec => l_model_line_rec);


  IF l_model_line_rec.ato_line_id = l_top_model_line_id THEN
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('THIS IS AN ATO MODEL', 1);
     END IF;
     l_line_rec := l_model_line_rec;
     l_defaulted_flag := 'Y';
  ELSE
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('THIS IS A PTO MODEL', 1);
     END IF;
     l_line_rec := OE_Order_Pub.G_Miss_Line_Rec;
     l_defaulted_flag := 'N';
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('DEFAULTED_FLAG: '|| L_DEFAULTED_FLAG , 1);
  END IF;


  l_index                      := 0;
  l_line_rec.header_id         := l_model_line_rec.header_id;
  l_line_rec.top_model_line_id := l_top_model_line_id;
  l_line_rec.operation         := OE_GLOBALS.G_OPR_CREATE;

  --recurring charges
  IF OE_SYS_PARAMETERS.Value ('RECURRING_CHARGES') = 'Y' THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add ('Recurring Charges System Param ENABLED',1);
	OE_DEBUG_PUB.Add('Top Model Line ID:'||l_top_model_line_id,3);
     END IF;
     OE_CONFIG_TSO_PVT.Is_Part_Of_Container_Model
     (  p_top_model_line_id   =>  l_top_model_line_id
       ,x_top_container_model =>  l_top_container_model
       ,x_part_of_container   =>  l_part_of_container  );
  END IF;

  OPEN options_to_be_priced;
  LOOP

    FETCH options_to_be_priced into
          l_item_key, l_line_rec.ordered_quantity,
          l_line_rec.order_quantity_uom, l_bom_item_type,
          l_service_item_flag, l_pick_components_flag,
          l_line_rec.inventory_item_id, l_seq_nbr;

    EXIT WHEN options_to_be_priced%NOTFOUND;

   IF l_line_rec.inventory_item_id <> l_model_line_rec.inventory_item_id THEN
      l_line_rec.line_id  := -1 - l_seq_nbr; --Bug#2832208
      l_line_rec.component_code
                  := SUBSTR( l_item_key, 1, INSTR(l_item_key, ':') - 1);

      IF l_defaulted_flag = 'Y' AND
         l_part_of_container = 'N' THEN --recurring charges

         IF l_bom_item_type = 2 THEN
            l_line_rec.item_type_code := OE_GLOBALS.G_ITEM_CLASS;
         ELSIF l_bom_item_type = 4 and l_service_item_flag = 'Y' THEN
            l_line_rec.item_type_code := OE_GLOBALS.G_ITEM_SERVICE;
         ELSIF l_bom_item_type = 4 and l_pick_components_flag = 'Y' THEN
            l_line_rec.item_type_code := OE_GLOBALS.G_ITEM_KIT;
         ELSE
            l_line_rec.item_type_code := OE_GLOBALS.G_ITEM_OPTION;
         END IF;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(L_SEQ_NBR||' HDR : '||L_LINE_REC.HEADER_ID,1);
            oe_debug_pub.add('QTY: ' || L_LINE_REC.ORDERED_QUANTITY,1);
            oe_debug_pub.add('UCFPB,ITEM_TYPE: '||L_LINE_REC.ITEM_TYPE_CODE,1);
         END IF;
      ELSE -- not defaulted, pto model, default 1st option
         OE_Default_Line.Attributes
         ( p_x_line_rec           => l_line_rec
          ,p_old_line_rec         => l_old_line_rec );
         l_defaulted_flag := 'Y';
      END IF;

      l_index             := l_index + 1;
      l_line_tbl(l_index) :=  l_line_rec;
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('LINE INDEX: '|| L_INDEX , 1);
         oe_debug_pub.add('COMP: '||L_LINE_TBL(L_INDEX).COMPONENT_CODE , 1);
         oe_debug_pub.add('ITEM: '||L_LINE_TBL(L_INDEX).INVENTORY_ITEM_ID,1);
      END IF;
   ELSE
      l_model_item_key := l_item_key;
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('THIS IS A MODEL LINE', 1);
      END IF;
      l_index                 := l_index + 1;
      l_line_tbl(l_index + 1) := l_model_line_rec;
   END IF; -- inventory item id match


  END LOOP;

  CLOSE options_to_be_priced;

  ----------------------- line rec done ---------------------


  l_time_read :=  to_char
  (new_time
  (sysdate, 'PST', 'EST'),
  'DD-MON-YY HH24:MI:SS');

  IF l_index = 0 THEN -- everything updated
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('RESTORED CONFIG , UPDATE PRICING BUTTOM PRESSED', 1);
    END IF;
    l_total_price  := 0;
    BEGIN
      SELECT sum(selling_price * quantity)
      INTO l_total_price
      FROM cz_pricing_structures
      WHERE configurator_session_key = p_config_session_key;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    x_total_price := l_total_price;

    RETURN;
  END IF;


  l_time_po :=  to_char
  (new_time
  (sysdate, 'PST', 'EST'),
  'DD-MON-YY HH24:MI:SS');

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('DONE WITH PO CALL', 1);
  END IF;

  ---------------------------- price_line --------------------

  -- event PRICE to get only list price.
  -- event LINE to get selling and list.

  IF p_price_type = CZ_Prc_Callback_Util.G_PRC_TYPE_LIST THEN
    l_price_control_rec.pricing_event   := 'PRICE';
  ELSE
    l_price_control_rec.pricing_event   := 'LINE';
  END IF;

  l_price_control_rec.calculate_flag  := QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
  l_price_control_rec.simulation_flag := 'Y';

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('IN CONFIG_PRICE_ITEMS , BEFORE CALL TO PRICE LINE', 1);
  END IF;

  l_time_bef_price :=  to_char
  (new_time
  (sysdate, 'PST', 'EST'),
  'DD-MON-YY HH24:MI:SS');


  OE_Order_Adj_Pvt.Price_Line
  ( p_request_type_code    => 'ONT'
   ,p_control_rec          => l_price_control_Rec
   ,p_write_to_Db          => FALSE
   ,x_line_tbl             => l_line_tbl  -- IN/OUT
   ,x_return_Status        => l_return_status);


  l_time_price :=  to_char
  (new_time
  (sysdate, 'PST', 'EST'),
  'DD-MON-YY HH24:MI:SS');

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('AFTER CALL TO PRICE LINE: '|| L_RETURN_STATUS , 1);
  END IF;

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('AFTER PRICING , TABLE COUNT: '||L_LINE_TBL.COUNT, 1);
  END IF;




  -------------------------- update cz tables ----------------

  -- update cz_pricing_structures with pricing information.

  l_index        := l_line_Tbl.FIRST;

  While l_index is not null
  LOOP

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('INDEX: '|| L_INDEX || ' '|| L_LINE_TBL ( L_INDEX ).INVENTORY_ITEM_ID );
    END IF;

    -- avoid processing for free items
    IF l_line_tbl(l_index).top_model_line_id = l_top_model_line_id
    THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('GG0', 1);
      END IF;
      l_item_key := l_line_tbl(l_index).inventory_item_id;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('GG01', 1);
      END IF;

      -- using msg_data field temporarily to save debug file name.

      UPDATE CZ_PRICING_STRUCTURES
      SET
      LIST_PRICE       =  l_line_tbl(l_index).unit_list_price,
      SELLING_PRICE    =  l_line_Tbl(l_index).unit_selling_price
      WHERE SUBSTR( item_key, 1, INSTR(item_key, ':') - 1)
            =  l_line_tbl(l_index).component_code
      AND seq_nbr = -1 - l_line_tbl(l_index).line_id --Bug#2832208
      AND configurator_session_key = p_config_session_key
      AND item_key_type = cz_prc_callback_util.g_item_key_bom_node;


      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('ITEM: '||L_LINE_TBL ( L_INDEX ).COMPONENT_CODE , 1);
        oe_debug_pub.add
        ('THE LIST PRICE IS '||L_LINE_TBL(L_INDEX ).UNIT_LIST_PRICE , 1);
        oe_debug_pub.add
        ('THE SELL PRICE IS '||L_LINE_TBL(L_INDEX ).UNIT_SELLING_PRICE , 1);
      END IF;

    END IF;

    l_index := l_line_Tbl.NEXT(l_index);

  END LOOP;

  l_total_price  := 0;
  BEGIN
    SELECT sum(selling_price * quantity)
    INTO l_total_price
    FROM cz_pricing_structures
    WHERE configurator_session_key = p_config_session_key;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  x_total_price := l_total_price;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('TOTAL_PRICE: '|| L_TOTAL_PRICE , 1);
  END IF;

  l_time_end :=  to_char
  (new_time
  (sysdate, 'PST', 'EST'),
  'DD-MON-YY HH24:MI:SS');

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(' ' );
    oe_debug_pub.add('TIME AT START OF CALLBACK : ' ||L_TIME_START , 1);
    oe_debug_pub.add('TIME AFTER UPDATE RESTORED : ' ||L_TIME_UPD , 1);
    oe_debug_pub.add('TIME AFTER CZ READ : ' ||L_TIME_READ , 1);
    oe_debug_pub.add('TIME AFTER PROCESS_ORDER : ' ||L_TIME_PO , 1);
    oe_debug_pub.add('TIME BEFORE PRICING API : ' ||L_TIME_BEF_PRICE );
    oe_debug_pub.add('TIME AFTER PRICING API : ' ||L_TIME_PRICE );
    oe_debug_pub.add('TIME AT END OF CALLBACK : ' ||L_TIME_END , 1);
    oe_debug_pub.add('LEAVING OE_CONFIG_PRICE_ITEMS', 1);
  END IF;

EXCEPTION

  WHEN OTHERS THEN

    l_config_pricing_error := OE_Msg_Pub.Get();
    --l_config_pricing_error := 'raising error for testing purpose';

    -- set the error message in the model line field.
    UPDATE CZ_PRICING_STRUCTURES
    SET MSG_DATA   =  l_config_pricing_error
    WHERE configurator_session_key = p_config_session_key
    AND   item_key = l_model_item_key;


   IF l_debug_level  > 0 THEN
     oe_debug_pub.add('TIME AT START OF CALLBACK : ' ||L_TIME_START , 1);
     oe_debug_pub.add('TIME AFTER READ FROM CZ : ' ||L_TIME_READ , 1);
     oe_debug_pub.add('TIME AFTER PROCESS_ORDER : ' ||L_TIME_PO , 1);
     oe_debug_pub.add('TIME AFTER PRICING API : ' ||L_TIME_PRICE );
     oe_debug_pub.add('TIME AT END OF CALLBACK : ' ||L_TIME_END , 1);
     oe_debug_pub.add('OE_CONFIG_PRICE_ITEMS: ' ||SUBSTR (SQLERRM ,1 ,100),1);
     oe_debug_pub.add('OTHERS EXCEPTION IN OE_CONFIG_PRICE_ITEMS', 1);
   END IF;

END OE_Config_Price_Items;

--For Bug# 7695217
PROCEDURE OE_Config_Price_Items_MLS
(  p_config_session_key      IN  VARCHAR2
  ,p_price_type              IN  VARCHAR2 -- list, selling
  ,x_total_price             OUT NOCOPY NUMBER
  ,x_currency_code           OUT NOCOPY VARCHAR2
) IS
   l_currency_code        VARCHAR2(15);
   l_top_line_id_pos      NUMBER;
   l_top_model_line_id    NUMBER;
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add ('Entering OE_CONFIG_PRICE_UTIL.oe_config_price_items_mls - '
                        || p_config_session_key || ' ***** ' || p_price_type);
   END IF;

   l_top_line_id_pos := INSTR(p_config_session_key, '#' );
   l_top_model_line_id := TO_NUMBER(SUBSTR(p_config_session_key,
                                           1, l_top_line_id_pos - 1 ));

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('top_model_line_id - ' || l_top_model_line_id);
   END IF;

   SELECT DISTINCT h.transactional_curr_code
   INTO l_currency_code
   FROM oe_order_lines_all l,
        oe_order_headers_all h
   WHERE h.header_id = l.header_id
         AND l.line_id = l_top_model_line_id;

   IF l_debug_level > 0 THEN
      oe_debug_pub.add ('l_currency_code - ' || l_currency_code);
   END IF;

   x_currency_code := l_currency_code;

   Oe_Config_Price_Items(p_config_session_key => p_config_session_key,
                         p_price_type         => p_price_type,
                         x_total_price        => x_total_price);

   IF l_debug_level > 0 THEN
      oe_debug_pub.add ('Exiting OE_CONFIG_PRICE_UTIL.oe_config_price_items_mls');
   END IF;
EXCEPTION
   WHEN TOO_MANY_ROWS THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add ('Exception OE_CONFIG_PRICE_UTIL.oe_config_price_items_mls - TOO_MANY_ROWS');
      END IF;
   WHEN OTHERS THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add ('Exception OE_CONFIG_PRICE_UTIL.oe_config_price_items_mls - OTHERS');
      END IF;
END OE_Config_Price_Items_MLS;
--End of Bug# 7695217


END OE_CONFIG_PRICE_UTIL;

/
