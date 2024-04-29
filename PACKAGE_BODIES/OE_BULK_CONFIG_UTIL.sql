--------------------------------------------------------
--  DDL for Package Body OE_BULK_CONFIG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BULK_CONFIG_UTIL" AS
/* $Header: OEBUCFGB.pls 120.0.12010000.4 2008/11/26 01:55:09 smusanna noship $ */

G_PKG_NAME         CONSTANT     VARCHAR2(30):='OE_BULK_CONFIG_UTIL';


/* -----------------------------------------------------------
--
-- Local procedures
--
--------------------------------------------------------------*/


PROCEDURE Extend_Line_Rec
        (p_count               IN NUMBER
        ,p_line_rec            IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
	,p_config_rec	       IN OUT NOCOPY OE_BULK_CONFIG_UTIL.CONFIG_REC_TYPE
        )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'ENTERING OE_BULK_CONFIG_UTIL.Extend_Line_Rec ') ;
  END IF;

  p_line_rec.ATO_LINE_ID.extend(p_count - p_line_rec.ATO_LINE_ID.count);
  p_line_rec.BOOKED_FLAG.extend(p_count - p_line_rec.BOOKED_FLAG.count);
  p_line_rec.COMPONENT_CODE.extend(p_count - p_line_rec.COMPONENT_CODE.count );
  p_line_rec.COMPONENT_NUMBER.extend(p_count - p_line_rec.COMPONENT_NUMBER.count );
  p_line_rec.COMPONENT_SEQUENCE_ID.extend(p_count - p_line_rec.COMPONENT_SEQUENCE_ID.count );
  p_line_rec.CONFIG_HEADER_ID.extend(p_count - p_line_rec.CONFIG_HEADER_ID.count );
  p_line_rec.CONFIG_REV_NBR.extend(p_count - p_line_rec.CONFIG_REV_NBR.count );
  p_line_rec.CONFIG_DISPLAY_SEQUENCE.extend(p_count - p_line_rec.CONFIG_DISPLAY_SEQUENCE.count );
  p_line_rec.CONFIGURATION_ID.extend(p_count - p_line_rec.CONFIGURATION_ID.count );
  p_line_rec.EXPLOSION_DATE.extend(p_count - p_line_rec.EXPLOSION_DATE.count );
  p_line_rec.HEADER_ID.extend(p_count - p_line_rec.HEADER_ID.count );
  p_line_rec.INVENTORY_ITEM_ID.extend(p_count - p_line_rec.INVENTORY_ITEM_ID.count  );
  p_line_rec.ORDERED_ITEM_ID.extend(p_count - p_line_rec.ORDERED_ITEM_ID.count );
  p_line_rec.ITEM_IDENTIFIER_TYPE.extend(p_count - p_line_rec.ITEM_IDENTIFIER_TYPE.count );
  p_line_rec.ORDERED_ITEM.extend(p_count - p_line_rec.ORDERED_ITEM.count );
  p_line_rec.ITEM_REVISION.extend(p_count - p_line_rec.ITEM_REVISION.count );
  p_line_rec.ITEM_TYPE_CODE.extend(p_count -  p_line_rec.ITEM_TYPE_CODE.count);
  p_line_rec.LINE_CATEGORY_CODE.extend(p_count - p_line_rec.LINE_CATEGORY_CODE.count );
  p_line_rec.LINE_ID.extend(p_count - p_line_rec.LINE_ID.count );
  p_line_rec.LINE_NUMBER.extend(p_count - p_line_rec.LINE_NUMBER.count );
  p_line_rec.LINE_TYPE_ID.extend(p_count - p_line_rec.LINE_TYPE_ID.count );
  p_line_rec.LINK_TO_LINE_ID.extend(p_count - p_line_rec.LINK_TO_LINE_ID.count );
  p_line_rec.OPTION_FLAG.extend(p_count - p_line_rec.OPTION_FLAG.count );
  p_line_rec.OPTION_NUMBER.extend(p_count - p_line_rec.OPTION_NUMBER.count );
  p_line_rec.ORDERED_QUANTITY.extend(p_count - p_line_rec.ORDERED_QUANTITY.count );
  p_line_rec.ORDER_QUANTITY_UOM.extend(p_count - p_line_rec.ORDER_QUANTITY_UOM.count );
  p_line_rec.ORIG_SYS_DOCUMENT_REF.extend(p_count - p_line_rec.ORIG_SYS_DOCUMENT_REF.count );
  p_line_rec.ORIG_SYS_LINE_REF.extend(p_count - p_line_rec.ORIG_SYS_LINE_REF.count );
  p_line_rec.ORIG_SYS_SHIPMENT_REF.extend(p_count - p_line_rec.ORIG_SYS_SHIPMENT_REF.count  );
  p_line_rec.SORT_ORDER.extend(p_count -p_line_rec.SORT_ORDER.count  );
  p_line_rec.TOP_MODEL_LINE_ID.extend(p_count - p_line_rec.TOP_MODEL_LINE_ID.count );
  p_line_rec.TOP_MODEL_LINE_REF.extend(p_count -  p_line_rec.TOP_MODEL_LINE_REF.count );
  p_line_rec.ORDER_SOURCE_ID.extend(p_count - p_line_rec.ORDER_SOURCE_ID.count );
  p_line_rec.LOCK_CONTROL.extend(p_count - p_line_rec.LOCK_CONTROL.count );
  p_line_rec.line_index.extend(p_count - p_line_rec.line_index.count );
  p_line_rec.header_index.extend(p_count - p_line_rec.header_index.count  );
  p_line_rec.Top_Bill_Sequence_Id.extend(p_count - p_line_rec.Top_Bill_Sequence_Id.count );
  p_line_rec.cz_qty_match_flag.extend(p_count - p_line_rec.cz_qty_match_flag.count );

  p_config_rec.high_quantity.extend(p_count - p_config_rec.high_quantity.count);
  p_config_rec.low_quantity.extend(p_count - p_config_rec.low_quantity.count );
  p_config_rec.mutually_exclusive_options.extend(p_count - p_config_rec.mutually_exclusive_options.count );
  p_config_rec.bom_item_type.extend(p_count - p_config_rec.bom_item_type.count );
  p_config_rec.replenish_to_order_flag.extend(p_count - p_config_rec.replenish_to_order_flag.count );

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'EXITING OE_BULK_CONFIG_UTIL.Extend_Line_Rec ') ;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , EXTEND_LINE_REC' ) ;
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Extend_Line_Rec'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Extend_Line_Rec;


PROCEDURE Print_Line_Rec
        (	 p_line_rec  	IN OE_WSH_BULK_GRP.LINE_REC_TYPE
		,p_config_rec	IN OE_BULK_CONFIG_UTIL.CONFIG_REC_TYPE
        )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'ENTERING OE_BULK_CONFIG_UTIL.Print_Line_Rec ') ;
  END IF;


IF l_debug_level  > 0 THEN
    FOR I IN 1..p_line_rec.line_id.count LOOP

  oe_debug_pub.add( '  ===== PRINT LINE_REC LOOP INDEX : I = '|| I  ) ;
  oe_debug_pub.add( '  ATO_LINE_ID = ' || p_line_rec.ATO_LINE_ID(I));
  oe_debug_pub.add( '  BOOKED_FLAG = ' || p_line_rec.BOOKED_FLAG(I));
  oe_debug_pub.add( '  COMPONENT_CODE = ' || p_line_rec.COMPONENT_CODE(I) );
  oe_debug_pub.add( '  COMPONENT_NUMBER = ' || p_line_rec.COMPONENT_NUMBER(I) );
  oe_debug_pub.add( '  COMPONENT_SEQUENCE_ID = ' || p_line_rec.COMPONENT_SEQUENCE_ID(I) );
  oe_debug_pub.add( '  CONFIG_HEADER_ID = ' || p_line_rec.CONFIG_HEADER_ID(I) );
  oe_debug_pub.add( '  CONFIG_REV_NBR = ' || p_line_rec.CONFIG_REV_NBR(I) );
  oe_debug_pub.add( '  CONFIG_DISPLAY_SEQUENCE = ' || p_line_rec.CONFIG_DISPLAY_SEQUENCE(I) );
  oe_debug_pub.add( '  CONFIGURATION_ID = ' || p_line_rec.CONFIGURATION_ID(I) );
  oe_debug_pub.add( '  EXPLOSION_DATE = ' || p_line_rec.EXPLOSION_DATE(I) );
  oe_debug_pub.add( '  HEADER_ID = ' || p_line_rec.HEADER_ID(I) );
  oe_debug_pub.add( '  INVENTORY_ITEM_ID = ' || p_line_rec.INVENTORY_ITEM_ID(I)  );
  oe_debug_pub.add( '  ORDERED_ITEM_ID = ' || p_line_rec.ORDERED_ITEM_ID(I) );
  oe_debug_pub.add( '  ITEM_IDENTIFIER_TYPE = ' || p_line_rec.ITEM_IDENTIFIER_TYPE(I) );
  oe_debug_pub.add( '  ORDERED_ITEM = ' || p_line_rec.ORDERED_ITEM(I) );
  oe_debug_pub.add( '  ITEM_REVISION = ' || p_line_rec.ITEM_REVISION(I) );
  oe_debug_pub.add( '  ITEM_TYPE_CODE = ' ||  p_line_rec.ITEM_TYPE_CODE(I));
  oe_debug_pub.add( '  LINE_CATEGORY_CODE = ' || p_line_rec.LINE_CATEGORY_CODE(I) );
  oe_debug_pub.add( '  LINE_ID = ' || p_line_rec.LINE_ID(I) );
  oe_debug_pub.add( '  LINE_NUMBER = ' || p_line_rec.LINE_NUMBER(I) );
  oe_debug_pub.add( '  LINE_TYPE_ID = ' || p_line_rec.LINE_TYPE_ID(I) );
  oe_debug_pub.add( '  LINK_TO_LINE_ID = ' || p_line_rec.LINK_TO_LINE_ID(I) );
  oe_debug_pub.add( '  OPTION_FLAG = ' || p_line_rec.OPTION_FLAG(I) );
  oe_debug_pub.add( '  OPTION_NUMBER = ' || p_line_rec.OPTION_NUMBER(I) );
  oe_debug_pub.add( '  ORDERED_QUANTITY = ' || p_line_rec.ORDERED_QUANTITY(I) );
  oe_debug_pub.add( '  ORDER_QUANTITY_UOM = ' || p_line_rec.ORDER_QUANTITY_UOM(I) );
  oe_debug_pub.add( '  ORIG_SYS_DOCUMENT_REF = ' || p_line_rec.ORIG_SYS_DOCUMENT_REF(I) );
  oe_debug_pub.add( '  ORIG_SYS_LINE_REF = ' || p_line_rec.ORIG_SYS_LINE_REF(I) );
  oe_debug_pub.add( '  ORIG_SYS_SHIPMENT_REF = ' || p_line_rec.ORIG_SYS_SHIPMENT_REF(I)  );
  oe_debug_pub.add( '  SORT_ORDER = ' || p_line_rec.SORT_ORDER(I)  );
  oe_debug_pub.add( '  TOP_MODEL_LINE_ID = ' || p_line_rec.TOP_MODEL_LINE_ID(I) );
  oe_debug_pub.add( '  TOP_MODEL_LINE_REF = ' ||  p_line_rec.TOP_MODEL_LINE_REF(I) );
  oe_debug_pub.add( '  ORDER_SOURCE_ID = ' || p_line_rec.ORDER_SOURCE_ID(I) );
  oe_debug_pub.add( '  LOCK_CONTROL = ' || p_line_rec.LOCK_CONTROL(I) );
  oe_debug_pub.add( '  line_index = ' || p_line_rec.line_index(I) );
  oe_debug_pub.add( '  header_index = ' || p_line_rec.header_index(I)  );
  oe_debug_pub.add( '  Top_Bill_Sequence_Id = ' || p_line_rec.Top_Bill_Sequence_Id(I) );
  oe_debug_pub.add( '  cz_qty_match_flag = ' || p_line_rec.cz_qty_match_flag(I) );

  IF (I <= p_config_rec.high_quantity.count) THEN
  oe_debug_pub.add( '  high_quantity = ' || p_config_rec.high_quantity(I));
  oe_debug_pub.add( '  low_quantity = ' || p_config_rec.low_quantity(I) );
  oe_debug_pub.add( '  mutually_exclusive_options = ' || p_config_rec.mutually_exclusive_options(I) );
  oe_debug_pub.add( '  bom_item_type = ' || p_config_rec.bom_item_type(I) );
  oe_debug_pub.add( '  replenish_to_order_flag = ' || p_config_rec.replenish_to_order_flag(I) );
  END IF;

    END LOOP;
END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'EXITING OE_BULK_CONFIG_UTIL.Print_Line_Rec ') ;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , PRINT_LINE_REC' ) ;
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Print_Line_Rec'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Print_Line_Rec;

PROCEDURE Print_Line_Rec
        ( p_line_rec  	IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE )
IS

l_config_rec	OE_BULK_CONFIG_UTIL.CONFIG_REC_TYPE;

BEGIN

   Extend_Line_Rec( p_count 	  => p_line_rec.line_id.count,
		    p_line_rec    => p_line_rec,
		    p_config_rec  => l_config_rec);

   Print_Line_Rec( p_line_rec    => p_line_rec,
		   p_config_rec  => l_config_rec);

END Print_Line_Rec;



PROCEDURE Message_From_Cz
(
  p_line_rec 	       IN OE_WSH_BULK_GRP.Line_Rec_Type,
  p_line_index	       IN NUMBER,
  p_valid_config       IN VARCHAR2,
  p_complete_config    IN VARCHAR2,
  p_config_header_id   IN NUMBER,
  p_config_rev_nbr     IN NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2  )
IS

    l_config_header_id                NUMBER := p_config_header_id;
    l_config_rev_nbr                  NUMBER := p_config_rev_nbr;
    l_message_text                    VARCHAR2(2000);
    l_msg                             VARCHAR2(2000);
    l_constraint                      VARCHAR2(16);

    CURSOR messages(p_config_hdr_id NUMBER, p_config_rev_nbr NUMBER) is
    SELECT constraint_type , message
    FROM   cz_config_messages
    WHERE  config_hdr_id =  p_config_hdr_id
    AND    config_rev_nbr = p_config_rev_nbr;

  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'ENTERING OE_BULK_CONFIG_UTIL.Message_From_Cz ') ;
  END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN messages(l_config_header_id, l_config_rev_nbr);

    LOOP
      FETCH messages into l_constraint,l_msg;
      EXIT when messages%notfound;

      OE_BULK_Msg_Pub.Add_Text(l_msg);
      oe_debug_pub.add('msg from spc: '||messages%rowcount , 2);
      oe_debug_pub.add('msg from spc: '|| substr(l_msg, 1, 250) , 3);

    END LOOP;

    CLOSE messages;

    IF nvl(p_valid_config, 'FALSE') = 'FALSE' THEN

      FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_VALIDATION_FAILURE');
      OE_BULK_MSG_PUB.Add;
    END IF;

    IF nvl(p_complete_config, 'FALSE') = 'FALSE'  THEN

      l_message_text := nvl(p_line_rec.ordered_item(p_line_index),
			p_line_rec.inventory_item_id(p_line_index));

      FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_INCOMPLETE_MODEL');
      FND_MESSAGE.SET_TOKEN('MODEL',l_message_text);
      OE_BULK_MSG_PUB.Add;

    END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'EXITING OE_BULK_CONFIG_UTIL.Message_From_Cz ') ;
  END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF messages%ISOPEN THEN
	CLOSE messages;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF l_debug_level > 0 THEN
           OE_Debug_Pub.Add('UNEXPECTED_ERROR IN Message_From_Cz: '|| sqlerrm, 1);
        END IF;

    WHEN OTHERS THEN
        IF messages%ISOPEN THEN
	   CLOSE messages;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Message_From_Cz'
            );
        END IF;

END Message_From_Cz;


PROCEDURE Get_Config_Effective_Date
( p_book_flag		  IN VARCHAR2
 ,x_old_behavior          OUT NOCOPY  VARCHAR2
 ,x_config_effective_date OUT NOCOPY  DATE
 ,x_return_status         OUT NOCOPY VARCHAR2  )
IS

  l_profile             VARCHAR2(10);
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  IF l_debug_level > 0 THEN
    OE_Debug_Pub.Add ('entering Get_Config_Effective_Date ', 3);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_profile := OE_BULK_ORDER_PVT.G_CONFIG_EFFECT_DATE;

  IF  l_profile = '1' OR l_profile IS NULL THEN
    x_old_behavior          := 'Y';
    x_config_effective_date := sysdate;
  ELSIF  l_profile = '2' THEN
    x_old_behavior          := 'N';
    x_config_effective_date := sysdate;
  ELSIF l_profile = '3' THEN
    x_old_behavior          := 'N';
    if nvl(p_book_flag, 'N') = 'Y' then
    	x_config_effective_date := sysdate;
    else
	x_config_effective_date := null;
    end if;
  ELSE
    IF l_debug_level > 0 THEN
      OE_Debug_Pub.Add('System parameter ONT_CONFIG_EFFECTIVITY_DATE has wrong value', 3);
    END IF;
  END IF;

  IF l_debug_level > 0 THEN
    OE_Debug_Pub.Add
    ('exiting Get_Config_Effective_Date '||
      to_char(x_config_effective_date, 'DD-MON-YY HH24:MI:SS'), 3);
    OE_Debug_Pub.Add('sysdate '||to_char(sysdate, 'DD-MON-YY HH24:MI:SS'),3);
  END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF l_debug_level > 0 THEN
           OE_Debug_Pub.Add('UNEXPECTED_ERROR IN Get_Config_Effective_Date: '|| sqlerrm, 1);
        END IF;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Config_Effective_Date'
            );
        END IF;

END Get_Config_Effective_Date;


PROCEDURE Create_hdr_xml
( p_line_rec 	       IN OE_WSH_BULK_GRP.Line_Rec_Type,
  p_line_index	       IN NUMBER,
  x_xml_hdr            OUT NOCOPY VARCHAR2,
  x_return_status      OUT NOCOPY VARCHAR2 )
IS

      TYPE param_name_type IS TABLE OF VARCHAR2(30)
      INDEX BY BINARY_INTEGER;

      TYPE param_value_type IS TABLE OF VARCHAR2(200)
      INDEX BY BINARY_INTEGER;

      param_name  param_name_type;
      param_value param_value_type;

      l_rec_index BINARY_INTEGER;

       -- SPC specific params
      l_database_id                     VARCHAR2(100);
      l_save_config_behavior            VARCHAR2(30):= 'new_revision';
      l_ui_type                         VARCHAR2(30):= null;
      l_msg_behavior                    VARCHAR2(30):= 'brief';

      --ont parameters
      l_context_org_id                  VARCHAR2(80);
      l_inventory_item_id               VARCHAR2(80);
      l_config_header_id                VARCHAR2(80);
      l_config_rev_nbr                  VARCHAR2(80);
      l_model_quantity                  VARCHAR2(80);
      l_pricing_package_name            VARCHAR2(100)
                                        := 'OE_Config_Price_Util';
      l_price_items_proc                VARCHAR2(100)
                                        := 'OE_Config_Price_Items';
      l_configurator_session_key        VARCHAR2(100):= NULL;
      l_session_id                      VARCHAR2(80)
                                        := FND_PROFILE.Value('DB_SESSION_ID');
      l_count                           NUMBER;
      -- message related
      l_xml_hdr                         VARCHAR2(2000):=
                                        '<initialize>';
      l_dummy                           VARCHAR2(500) := NULL;
      l_return_status                   VARCHAR2(1)
                                        := FND_API.G_RET_STS_SUCCESS;

      l_config_effective_date           DATE;
      l_old_behavior                    VARCHAR2(1);
      l_frozen_model_bill               VARCHAR2(1);

      --
      l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
      --
  BEGIN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('ENTERING OE_BULK_CONFIG_UTIL.CREATE_HDR_XML' , 1);
      END IF;

      -- now set the values from model_rec and org_id
      l_context_org_id        := OE_BULK_ORDER_PVT.G_ITEM_ORG;
      l_inventory_item_id     := to_char(p_line_rec.inventory_item_id(p_line_index));
      l_config_header_id      := to_char(p_line_rec.config_header_id(p_line_index));
      l_config_rev_nbr        := to_char(p_line_rec.config_rev_nbr(p_line_index));


      l_model_quantity        := to_char(p_line_rec.ordered_quantity(p_line_index));

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add( ' QTY: ' 	|| L_MODEL_QUANTITY ||
			' CONFIG-HDR: ' || L_CONFIG_HEADER_ID ||
			' CONFIG-REV: ' || L_CONFIG_REV_NBR ||
			' ORG-ID: ' 	|| L_CONTEXT_ORG_ID ||
			' ITEM-ID: ' 	|| L_INVENTORY_ITEM_ID , 2 );
      END IF;

     -- profiles and env. variables.
      l_database_id            := fnd_web_config.database_id;
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('DATABASE_ID: '|| L_DATABASE_ID , 2 );
      END IF;

      -- set param_names

      param_name(1)  := 'database_id';
      param_name(2)  := 'context_org_id';
      param_name(3)  := 'config_creation_date';
      param_name(4)  := 'calling_application_id';
      param_name(5)  := 'responsibility_id';
      param_name(6)  := 'model_id';
      param_name(7)  := 'config_header_id';
      param_name(8)  := 'config_rev_nbr';
      param_name(9)  := 'read_only';
      param_name(10) := 'save_config_behavior';
      param_name(11) := 'ui_type';
      param_name(12) := 'validation_org_id';
      param_name(13) := 'terminate_msg_behavior';
      param_name(14) := 'model_quantity';
      param_name(15) := 'icx_session_ticket';
      param_name(16) := 'client_header';
      param_name(17) := 'client_line';
      param_name(18) := 'sbm_flag';
      param_name(19)  := 'config_effective_date';
      param_name(20)  := 'config_model_lookup_date';
      l_count := 20;

        -- set param values

      param_value(1)  := l_database_id;
      param_value(2)  := l_context_org_id;
      param_value(3)  := to_char(sysdate, 'MM-DD-YYYY-HH24-MI-SS');
      param_value(4)  := OE_BULK_ORDER_PVT.G_RESP_APPL_ID;
      param_value(5)  := OE_BULK_ORDER_PVT.G_RESP_ID;
      param_value(6)  := l_inventory_item_id;
      param_value(7)  := l_config_header_id;
      param_value(8)  := l_config_rev_nbr;
      param_value(9)  := null;
      param_value(10) := l_save_config_behavior;
      param_value(11) := l_ui_type;
      param_value(12) := null;
      param_value(13) := l_msg_behavior;
      param_value(14) := l_model_quantity;
      param_value(15) := cz_cf_api.icx_session_ticket;
      param_value(16) := to_char(p_line_rec.header_id(p_line_index));
      param_value(17) := to_char(p_line_rec.line_id(p_line_index));


      IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110508' THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('UCFGB MI , PACK H NEW LOGIC' , 1);
        END IF;
        param_value(18) := 'TRUE';
      ELSE
        param_value(18) := 'FALSE';
      END IF;

      OE_Bulk_Config_Util.Get_Config_Effective_Date
      ( p_book_flag		=> p_line_rec.booked_flag(p_line_index)
       ,x_old_behavior          => l_old_behavior
       ,x_config_effective_date => l_config_effective_date
       ,x_return_status		=> l_return_status);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

      IF l_old_behavior = 'N' THEN
        param_value(19) := to_char(l_config_effective_date,
                           'MM-DD-YYYY-HH24-MI-SS');
        param_value(20) := param_value(19);
      ELSE
        param_value(19) := null;
        param_value(20) := null;

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('old behavior no dates', 2 );
        END IF;
      END IF;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('INSIDE CREATE_HDR_XML , PARAMETERS ARE SET' , 2 );
      END IF;


      l_rec_index := 1;

      LOOP
         -- ex : <param name="config_header_id">1890</param>

         IF (param_value(l_rec_index) IS NOT NULL) THEN

             l_dummy :=  '<param name=' ||
                         '"' || param_name(l_rec_index) || '"'
                         ||'>'|| param_value(l_rec_index) ||
                         '</param>';

             l_xml_hdr := l_xml_hdr || l_dummy;

          END IF;

          l_dummy := NULL;

          l_rec_index := l_rec_index + 1;
          EXIT WHEN l_rec_index > l_count;

      END LOOP;


      -- add termination tags

      l_xml_hdr := l_xml_hdr || '</initialize>';
      l_xml_hdr := REPLACE(l_xml_hdr, ' ' , '+');

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('1ST PART OF CREATE_HDR_XML IS : '
                         ||SUBSTR ( L_XML_HDR , 1 , 200 ) , 3 );
        oe_debug_pub.add('2ND PART OF CREATE_HDR_XML IS : '
                         ||SUBSTR ( L_XML_HDR , 201 , 200 ) , 3 );
        oe_debug_pub.add('3RD PART OF CREATE_HDR_XML IS : '
                         ||SUBSTR ( L_XML_HDR , 401 , 200 ) , 3 );
        oe_debug_pub.add('4TH PART OF CREATE_HDR_XML IS : '
                         ||SUBSTR ( L_XML_HDR , 601 , 200 ) , 3 );
      END IF;

      x_xml_hdr := l_xml_hdr;

      x_return_status := l_return_status;
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('LENGTH OF INI MSG:' || LENGTH ( L_XML_HDR ) , 3 );
        oe_debug_pub.add('EXITING CREATE_HDR_XML' , 3 );
      END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('UNEXPECTED EXCEPTION IN CREATE_HDR_XML '|| SQLERRM , 1 );
        END IF;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_hdr_xml'
            );
        END IF;

END Create_hdr_xml;



PROCEDURE Send_input_xml
            ( p_line_rec 	    IN OE_WSH_BULK_GRP.Line_Rec_Type,
  	      p_line_index	    IN NUMBER,
	      p_new_config	    IN VARCHAR2,
              p_xml_hdr             IN VARCHAR2,
              x_out_xml_msg         OUT NOCOPY LONG ,
              x_return_status       OUT NOCOPY VARCHAR2,
	      p_batch_validate_time IN OUT NOCOPY NUMBER)
IS
  l_html_pieces              CZ_BATCH_VALIDATE.CFG_OUTPUT_PIECES;
  l_option                   CZ_BATCH_VALIDATE.INPUT_SELECTION;
  l_batch_val_tbl            CZ_BATCH_VALIDATE.CFG_INPUT_LIST;
  l_db_options_tbl       OE_Process_Options_Pvt.SELECTED_OPTIONS_TBL_TYPE;
  -- update / delete options
  l_req_rec                       OE_Order_Pub.Request_Rec_Type;
  l_flag                          VARCHAR2(30) := '0';

  --variable to fetch from cursor Get_Options
  l_validation_status             NUMBER;
  l_sequence                      NUMBER := 0;
  l_url                           VARCHAR2(500):=
                                  FND_PROFILE.Value('CZ_UIMGR_URL');
  l_rec_index BINARY_INTEGER;
  l_xml_hdr                       VARCHAR2(2000);
  l_long_xml                      LONG := NULL;

  I                               NUMBER;
  l_top_model_line_ref            VARCHAR2(50);
  l_top_model_line_id		  NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

  l_start_time                 NUMBER;
  l_end_time                   NUMBER;


  --
 BEGIN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('ENTERING OE_BULK_CONFIG_UTIL.SEND_INPUT_XML' , 1);
        oe_debug_pub.add('UIMANAGER URL: ' || L_URL , 2 );
      END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      l_xml_hdr := p_xml_hdr;
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('LENGTH OF INI MSG: ' || LENGTH ( L_XML_HDR ) , 2 );
      END IF;

      -- If Model line cz_qty_match_flag is Y Then No need to send model
      -- record on l_batch_val_tbl Else Send Model record on l_batch_val_tbl.
      -- (For new configuration, configuration_id will be NULL)

      IF (nvl(p_line_rec.cz_qty_match_flag(p_line_index), 'N') = 'N') THEN

          l_sequence := l_sequence + 1;
          l_option.component_code     := p_line_rec.component_code(p_line_index);
          l_option.quantity           := p_line_rec.ordered_quantity(p_line_index);
          l_option.config_item_id     := p_line_rec.configuration_id(p_line_index);
          l_option.input_seq          := l_sequence;

          l_batch_val_tbl(l_sequence) := l_option;

     END IF;

     -- If p_new_config IS 'N' Then No need to populate l_batch_val_tbl
     -- Else Loop over  (p_line_index +1) to p_end_index on p_line_rec

     IF  p_new_config = 'Y' THEN
     	  I := 1;
          -- l_top_model_line_ref := p_line_rec.top_model_line_ref(p_line_index);

     	  WHILE p_line_index + I <= p_line_rec.line_id.count AND
		p_line_rec.top_model_line_ref(p_line_index + I) =
			p_line_rec.top_model_line_ref(p_line_index) AND
	        p_line_rec.header_id(p_line_index + I) = p_line_rec.header_id(p_line_index) LOOP
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('GET_OPTION : '
                            || p_line_rec.component_code(p_line_index + I) , 2 );
              END IF;

               l_sequence := l_sequence + 1;
               l_option.component_code     := p_line_rec.component_code(p_line_index + I);
               l_option.quantity           := p_line_rec.ordered_quantity(p_line_index + I);
               l_option.config_item_id     := p_line_rec.configuration_id(p_line_index + I);
               l_option.input_seq          := l_sequence;
               l_batch_val_tbl(l_sequence) := l_option;
               I := I + 1;
      	  END LOOP;

      	  IF l_debug_level  > 0 THEN
        	oe_debug_pub.add('OUT OF NEWLY INSERTED OPTIONS LOOP' , 2 );
      	  END IF;
     END IF;

      -- delete previous data.
      IF (l_html_pieces.COUNT <> 0) THEN
         l_html_pieces.DELETE;
      END IF;

      -- Call CZ batch validate API

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('BEFORE CALL CZ_BATCH_VALIDATE.Validate', 1);
      END IF;

      SELECT hsecs INTO l_start_time from v$timer;

      CZ_BATCH_VALIDATE.Validate
      ( config_input_list => l_batch_val_tbl ,
        init_message      => l_xml_hdr ,
        config_messages   => l_html_pieces ,
        validation_status => l_validation_status ,
        URL               => l_url );

      SELECT hsecs INTO l_end_time from v$timer;
      p_batch_validate_time := p_batch_validate_time + (l_end_time-l_start_time)/100;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('AFTER CALL CZ_BATCH_VALIDATE.Validate , STATUS : '
                          ||L_VALIDATION_STATUS , 1);
      END IF;

      IF (l_html_pieces.COUNT <= 0) THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('HTML_PIECES COUNT IS <= 0' , 2 );
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      l_rec_index := l_html_pieces.FIRST;
      LOOP
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(L_REC_INDEX ||': PART OF OUTPUT_MESSAGE: '
            || SUBSTR ( L_HTML_PIECES ( L_REC_INDEX ) , 1 , 100 ) , 2 );
          END IF;

          l_long_xml := l_long_xml || l_html_pieces(l_rec_index);

          EXIT WHEN l_rec_index = l_html_pieces.LAST;
          l_rec_index := l_html_pieces.NEXT(l_rec_index);

      END LOOP;

      -- if everything ok, set out values
      x_out_xml_msg := l_long_xml;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('EXITING OE_BULK_CONFIG_UTIL.SEND_INPUT_XML' , 1);
      END IF;

EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('AN UNEXP ERROR RAISED IN SEND_INPUT_XML: '
                    	|| SUBSTR ( SQLERRM , 1 , 100 ) , 1);
         END IF;

      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Send_input_xml'
            );
         END IF;

END Send_input_xml;


PROCEDURE  Parse_output_xml
               (  p_xml                IN LONG,
                  p_line_index         IN NUMBER,
		  p_line_rec	       IN OE_WSH_BULK_GRP.Line_Rec_Type,
                  x_valid_config       OUT NOCOPY VARCHAR2,
                  x_complete_config    OUT NOCOPY VARCHAR2,
                  x_config_header_id   OUT NOCOPY NUMBER,
                  x_config_rev_nbr     OUT NOCOPY NUMBER,
                  x_return_status      OUT NOCOPY VARCHAR2 )
IS

      l_exit_start_tag                VARCHAR2(20) := '<EXIT>';
      l_exit_end_tag                  VARCHAR2(20) := '</EXIT>';
      l_exit_start_pos                NUMBER;
      l_exit_end_pos                  NUMBER;

      l_valid_config_start_tag          VARCHAR2(30) := '<VALID_CONFIGURATION>';
      l_valid_config_end_tag            VARCHAR2(30) := '</VALID_CONFIGURATION>';
      l_valid_config_start_pos          NUMBER;
      l_valid_config_end_pos            NUMBER;

      l_complete_config_start_tag       VARCHAR2(30) := '<COMPLETE_CONFIGURATION>';
      l_complete_config_end_tag         VARCHAR2(30) := '</COMPLETE_CONFIGURATION>';
      l_complete_config_start_pos       NUMBER;
      l_complete_config_end_pos         NUMBER;

      l_config_header_id_start_tag      VARCHAR2(20) := '<CONFIG_HEADER_ID>';
      l_config_header_id_end_tag        VARCHAR2(20) := '</CONFIG_HEADER_ID>';
      l_config_header_id_start_pos      NUMBER;
      l_config_header_id_end_pos        NUMBER;

      l_config_rev_nbr_start_tag        VARCHAR2(20) := '<CONFIG_REV_NBR>';
      l_config_rev_nbr_end_tag          VARCHAR2(20) := '</CONFIG_REV_NBR>';
      l_config_rev_nbr_start_pos        NUMBER;
      l_config_rev_nbr_end_pos          NUMBER;

      l_message_text_start_tag          VARCHAR2(20) := '<MESSAGE_TEXT>';
      l_message_text_end_tag            VARCHAR2(20) := '</MESSAGE_TEXT>';
      l_message_text_start_pos          NUMBER;
      l_message_text_end_pos            NUMBER;

      l_message_type_start_tag          VARCHAR2(20) := '<MESSAGE_TYPE>';
      l_message_type_end_tag            VARCHAR2(20) := '</MESSAGE_TYPE>';
      l_message_type_start_pos          NUMBER;
      l_message_type_end_pos            NUMBER;

      l_exit                            VARCHAR(20);
      l_config_header_id                NUMBER;
      l_config_rev_nbr                  NUMBER;
      l_message_text                    VARCHAR2(2000);
      l_message_type                    VARCHAR2(200);
      l_list_price                      NUMBER;
      l_selection_line_id               NUMBER;
      l_valid_config                    VARCHAR2(10);
      l_complete_config                 VARCHAR2(10);
      l_header_id                       NUMBER;
      l_return_status                   VARCHAR2(1) :=
                                        FND_API.G_RET_STS_SUCCESS;
      l_return_status_del               VARCHAR2(1);
      l_msg                             VARCHAR2(2000);
      l_constraint                      VARCHAR2(16);
      l_flag                            VARCHAR2(1) := 'N';

      --
      l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
      --
BEGIN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('ENTERING OE_CONGIG_UTIL.PARSE_OUTPUT_XML' , 1);
      END IF;


      l_exit_start_pos := INSTR(p_xml, l_exit_start_tag,1, 1) +
                                length(l_exit_start_tag);

      l_exit_end_pos   := INSTR(p_xml, l_exit_end_tag,1, 1) - 1;

      l_exit           := SUBSTR (p_xml, l_exit_start_pos,
                                  l_exit_end_pos - l_exit_start_pos + 1);

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('L_EXIT: ' || L_EXIT , 3 );
      END IF;

      -- if error go to msg etc.
      IF nvl(l_exit,'ERROR') <> 'ERROR'  THEN

        l_valid_config_start_pos :=
                INSTR(p_xml, l_valid_config_start_tag,1, 1) +
          length(l_valid_config_start_tag);

        l_valid_config_end_pos :=
                INSTR(p_xml, l_valid_config_end_tag,1, 1) - 1;

        l_valid_config := SUBSTR( p_xml, l_valid_config_start_pos,
                                  l_valid_config_end_pos -
                                  l_valid_config_start_pos + 1);

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('GG1: '|| L_VALID_CONFIG , 3 );
        END IF;

        -- ex :- <VALID_CONFIGURATION>abc</VALID_CONFIGURATION>
        -- 1st instr : posin of a(22), 2nd instr gives posn of c(24)
        -- substr gives string starting from
        -- posn a to posn c - posn a + 1(3)

        l_complete_config_start_pos :=
                   INSTR(p_xml, l_complete_config_start_tag,1, 1) +
        length(l_complete_config_start_tag);
        l_complete_config_end_pos :=
                   INSTR(p_xml, l_complete_config_end_tag,1, 1) - 1;

        l_complete_config := SUBSTR( p_xml, l_complete_config_start_pos,
                                     l_complete_config_end_pos -
                                     l_complete_config_start_pos + 1);

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('GG2: '|| L_COMPLETE_CONFIG , 3 );
        END IF;


          IF (nvl(l_valid_config, 'N')  <> 'TRUE') THEN
              IF l_debug_level  > 0 THEN
                oe_debug_pub.add('SPC RETURNED VALID_FLAG AS NULL/FALSE' , 2 );
              END IF;
              l_flag := 'Y';
          END IF ;


          IF (nvl(l_complete_config, 'N') <> 'TRUE' ) THEN
              IF l_debug_level  > 0 THEN
                oe_debug_pub.add('COMPLETE_FLAG AS NULL/FALSE' , 2 );
              END IF;
              l_flag := 'Y';
          END IF;

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('SPC VALID_CONFIG FLAG: ' || L_VALID_CONFIG , 2 );
          oe_debug_pub.add('COMPLETE_CONFIG FLAG: ' || L_COMPLETE_CONFIG , 2 );
        END IF;

      END IF;


      -- parsing message_text and type is not req. I use it for debugging.

      l_message_text_start_pos :=
                 INSTR(p_xml, l_message_text_start_tag,1, 1) +
                       length(l_message_text_start_tag);
      l_message_text_end_pos :=
                 INSTR(p_xml, l_message_text_end_tag,1, 1) - 1;

      l_message_text := SUBSTR( p_xml, l_message_text_start_pos,
                                l_message_text_end_pos -
                                l_message_text_start_pos + 1);

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('GG3: '|| L_MESSAGE_TEXT , 3 );
      END IF;

      l_message_type_start_pos :=
                 INSTR(p_xml, l_message_type_start_tag,1, 1) +
                 length(l_message_type_start_tag);
      l_message_type_end_pos :=
                 INSTR(p_xml, l_message_type_end_tag,1, 1) - 1;

      l_message_type := SUBSTR( p_xml, l_message_type_start_pos,
                                l_message_type_end_pos -
                                l_message_type_start_pos + 1);


      -- get the latest config_header_id, and rev_nbr to get
      -- messages if any.

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('SPC RETURNED MESSAGE_TEXT: '|| L_MESSAGE_TEXT , 2 );
        oe_debug_pub.add('SPC RETURNED MESSAGE_TYPE: '|| L_MESSAGE_TYPE , 2 );
      END IF;


      l_config_header_id_start_pos :=
                       INSTR(p_xml, l_config_header_id_start_tag, 1, 1)+
                       length(l_config_header_id_start_tag);

      l_config_header_id_end_pos :=
                       INSTR(p_xml, l_config_header_id_end_tag, 1, 1) - 1;

      l_config_header_id :=
                       to_number(SUBSTR( p_xml,l_config_header_id_start_pos,
                                         l_config_header_id_end_pos -
                                         l_config_header_id_start_pos + 1));


      l_config_rev_nbr_start_pos :=
                       INSTR(p_xml, l_config_rev_nbr_start_tag, 1, 1)+
                             length(l_config_rev_nbr_start_tag);

      l_config_rev_nbr_end_pos :=
                       INSTR(p_xml, l_config_rev_nbr_end_tag, 1, 1) - 1;

      l_config_rev_nbr :=
                       to_number(SUBSTR( p_xml,l_config_rev_nbr_start_pos,
                                         l_config_rev_nbr_end_pos -
                                         l_config_rev_nbr_start_pos + 1));

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CONFIG_HEADER_ID AS:' || L_CONFIG_HEADER_ID  , 2 );
        oe_debug_pub.add('CONFIG_REV_NBR AS:' || L_CONFIG_REV_NBR , 2 );
      END IF;


      IF (l_flag = 'Y' ) OR
          l_exit is NULL OR
          l_exit = 'ERROR'  THEN

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('GETTING MESSAGES FROM CZ_CONFIG_MESSAGES' , 2 );
          END IF;

          Message_From_Cz
          ( p_line_index        => p_line_index,
	    p_line_rec		=> p_line_rec,
            p_valid_config      => l_valid_config,
            p_complete_config   => l_complete_config,
            p_config_header_id  => l_config_header_id,
            p_config_rev_nbr    => l_config_rev_nbr,
	    x_return_status	=> l_return_status);

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

      END IF;

      IF l_exit is NULL OR
         l_exit = 'ERROR'  THEN

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('SPC RETURNED ERROR , FAIL TRANSACTION' , 2 );
         END IF;

         -- delete the SPC configuration in error
         OE_Config_Pvt.Delete_Config
                        ( p_config_hdr_id   =>  l_config_header_id
                         ,p_config_rev_nbr  =>  l_config_rev_nbr
                         ,x_return_status   =>  l_return_status_del);

         IF l_return_status_del = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSE
             RAISE FND_API.G_EXC_ERROR;
         END IF;

      END IF;


          -- if everything ok, set return values
      x_return_status    := l_return_status;
      x_config_header_id := l_config_header_id;
      x_config_rev_nbr   := l_config_rev_nbr;
      x_complete_config  := nvl(l_complete_config, 'FALSE');
      x_valid_config     := nvl(l_valid_config, 'FALSE');


      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('EXITING OE_BULK_CONFIG_UTIL.PARSE_OUTPUT_XML' , 1);
      END IF;

EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('SPC EXIT TAG IS ERROR' , 1);
         END IF;
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('AN UNEXP ERROR RAISED IN Parse_output_xml: '
                            || SUBSTR ( SQLERRM , 1 , 100 ) , 1);
         END IF;

      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Parse_output_xml'
            );
         END IF;

END Parse_output_xml;



---------------------------------------------------------------------
--
-- PROCEDURE Validate_Config_Attributes
--
---------------------------------------------------------------------

PROCEDURE Validate_Config_Attributes
( p_use_Configurator 	IN VARCHAR2,
  p_line_rec 	    	IN OUT NOCOPY OE_WSH_BULK_GRP.Line_Rec_Type,
  p_line_index		IN NUMBER
)
IS
  l_msg_text                  VARCHAR2(2000);
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

  l_attribute	VARCHAR2(30);

BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'ENTERING OE_BULK_CONFIG_UTIL.Validate_Config_Attributes ') ;
  END IF;

  -- Validate Required Attributes
  IF nvl(p_use_configurator, 'N') = 'Y' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add( 'Using configurator ') ;
      END IF;

      IF p_line_rec.config_header_id(p_line_index) IS NULL AND
	 p_line_rec.config_rev_nbr(p_line_index) IS NOT NULL
      THEN
   	  l_attribute := 'CONFIG_HEADER_ID';
          fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                OE_Order_UTIL.Get_Attribute_Name(l_attribute));
          OE_BULK_MSG_PUB.Add('Y','ERROR');
          RAISE FND_API.G_EXC_ERROR;
      ELSIF p_line_rec.config_header_id(p_line_index) IS NOT NULL AND
	 p_line_rec.config_rev_nbr(p_line_index) IS NULL
      THEN
   	  l_attribute := 'CONFIG_REV_NBR';
          fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                OE_Order_UTIL.Get_Attribute_Name(l_attribute));
          OE_BULK_MSG_PUB.Add('Y','ERROR');
          RAISE FND_API.G_EXC_ERROR;

      ELSIF p_line_rec.config_header_id(p_line_index) IS NOT NULL AND
	 p_line_rec.config_rev_nbr(p_line_index) IS NOT NULL AND
	 p_line_rec.configuration_id(p_line_index) IS NULL AND
         p_line_rec.component_code(p_line_index) IS NULL
      THEN
   	  l_attribute := 'CONFIGURATION_ID';
          fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                OE_Order_UTIL.Get_Attribute_Name(l_attribute));
          OE_BULK_MSG_PUB.Add('Y','ERROR');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF p_line_rec.config_header_id(p_line_index) IS NOT NULL AND
	 p_line_rec.config_rev_nbr(p_line_index) IS NOT NULL AND
         p_line_rec.component_code(p_line_index) IS NULL AND
         p_line_rec.configuration_id(p_line_index) IS NULL
      THEN
   	  l_attribute := 'COMPONENT_CODE';
          fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                OE_Order_UTIL.Get_Attribute_Name(l_attribute));
          OE_BULK_MSG_PUB.Add('Y','ERROR');
          RAISE FND_API.G_EXC_ERROR;

      END IF;

  ELSE -- Configurator is not used

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add( 'Not using configurator ') ;
      END IF;

      IF p_line_rec.config_header_id(p_line_index) IS NOT NULL
      THEN
   	  l_attribute := 'CONFIG_HEADER_ID';
          fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                OE_Order_UTIL.Get_Attribute_Name(l_attribute));
          OE_BULK_MSG_PUB.Add('Y','ERROR');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF p_line_rec.config_rev_nbr(p_line_index) IS NOT NULL
      THEN
   	  l_attribute := 'CONFIG_REV_NBR';
          fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                OE_Order_UTIL.Get_Attribute_Name(l_attribute));
          OE_BULK_MSG_PUB.Add('Y','ERROR');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF p_line_rec.configuration_id(p_line_index) IS NOT NULL
      THEN
   	  l_attribute := 'CONFIGURATION_ID';
          fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                OE_Order_UTIL.Get_Attribute_Name(l_attribute));
          OE_BULK_MSG_PUB.Add('Y','ERROR');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

  END IF; -- Use configurator

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'EXITING OE_BULK_CONFIG_UTIL.Validate_Config_Attributes ') ;
  END IF;

EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
	 p_line_rec.lock_control(p_line_index) := -99;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add('AN EXC ERROR RAISED IN OE_BULK_CONFIG_UTIL.Validate_Config_Attributes', 1);
         END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('AN UNEXP ERROR RAISED IN Validate_Config_Attributes: '
                            || SUBSTR ( SQLERRM , 1 , 100 ) , 1);
         END IF;

      WHEN OTHERS THEN
         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_Config_Attributes'
            );
         END IF;

END Validate_Config_Attributes;


---------------------------------------------------------------------
--
-- PROCEDURE Load_Item_Attributes
--
---------------------------------------------------------------------

PROCEDURE Load_Item_Attributes
(
  p_line_rec 	    	IN OUT NOCOPY OE_WSH_BULK_GRP.Line_Rec_Type,
  p_index		IN NUMBER
)
IS

  l_item_index 			NUMBER;
  l_bom_item_type 	    	NUMBER;
  l_replenish_to_order_flag  	VARCHAR2(1);

  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'ENTERING OE_BULK_CONFIG_UTIL.Load_Item_Attributes ') ;
  END IF;

  -- Load item cache and Get the index
  -- l_index := OE_Bulk_Cache.Load_Item(l_line_rec.inventory_item_id(p_index),
  -- l_line_rec.ship_from_org_id(p_index)); Use l_index to lookup the item attributes
  -- as -> OE_Bulk_Cache.G_Line_Tbl(l_index).$attribute

  l_item_index := OE_BULK_CACHE.Load_item(
		    p_key1 	=> p_line_rec.inventory_item_id(p_index),
		    p_key2	=> p_line_rec.ship_from_org_id(p_index) );

  l_bom_item_type := OE_BULK_CACHE.G_Item_Tbl(l_item_index).bom_item_type;
  l_replenish_to_order_flag := OE_BULK_CACHE.G_Item_Tbl(l_item_index).replenish_to_order_flag;

  -- Check If Top Model Line
  IF ( l_bom_item_type = 1 AND
       p_line_rec.top_model_line_id(p_index) = p_line_rec.line_id(p_index) ) OR
     ( p_line_rec.item_type_code(p_index) = 'MODEL') THEN

      -- For ATO Model set ato_line_id
      IF nvl(l_replenish_to_order_flag, 'N') = 'Y' THEN
          p_line_rec.ato_line_id(p_index) := p_line_rec.line_id(p_index);
      END IF;


  -- Check if ATO model under PTO model
  ELSIF l_bom_item_type = 1   AND
      p_line_rec.top_model_line_id(p_index) <> p_line_rec.line_id(p_index) THEN

      IF nvl(l_replenish_to_order_flag, 'N') = 'Y' THEN
          p_line_rec.item_type_code(p_index) := 'CLASS';
      END IF;

  -- Check if it is a CLASS
  ELSIF l_bom_item_type = 2 THEN
      p_line_rec.item_type_code(p_index) := 'CLASS';

  -- Check if it is an OPTION
  ELSIF l_bom_item_type = 4 THEN
      p_line_rec.item_type_code(p_index) := 'OPTION';

  END IF;

  IF p_line_rec.ordered_item(p_index) is null THEN
      -- Set it from the Item Cache.
      p_line_rec.ordered_item(p_index)
		:= OE_BULK_CACHE.G_Item_Tbl(l_item_index).ordered_item;

  END IF;


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'EXITING OE_BULK_CONFIG_UTIL.Load_Item_Attributes ') ;
  END IF;

EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
          p_line_rec.lock_control(p_index) := -99;
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add('AN EXC ERROR RAISED IN Load_Item_Attributes', 1);
          END IF;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('AN UNEXP ERROR RAISED IN Load_Item_Attributes: '
                            || SUBSTR ( SQLERRM , 1 , 100 ) , 1);
         END IF;

      WHEN OTHERS THEN

         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Load_Item_Attributes'
            );
         END IF;

END Load_Item_Attributes;



---------------------------------------------------------------------
--
-- PROCEDURE Validate_Configuration
--
---------------------------------------------------------------------

PROCEDURE Validate_Configuration(
  p_new_config		IN VARCHAR2
, p_line_rec 		IN OUT NOCOPY OE_WSH_BULK_GRP.Line_Rec_Type
, p_line_index		IN NUMBER
, p_batch_validate_time IN OUT NOCOPY NUMBER
)
IS

  l_book_flag		   VARCHAR2(1);
  l_qty_match_flag	   VARCHAR2(1);
  l_config_header_id       NUMBER := p_line_rec.config_header_id(p_line_index) ;
  l_config_rev_nbr         NUMBER := p_line_rec.config_rev_nbr(p_line_index) ;
  l_valid_config           VARCHAR2(10):= 'true';
  l_complete_config        VARCHAR2(10):= 'true';
  l_exists_flag            VARCHAR2(1) := FND_API.G_TRUE;
  l_complete_flag          VARCHAR2(1) := FND_API.G_TRUE;
  l_valid_flag             VARCHAR2(1) := FND_API.G_TRUE;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

  l_xml_message            LONG   := NULL;
  l_xml_hdr                VARCHAR2(2000);

  I                               NUMBER;
  l_top_model_line_ref            VARCHAR2(50);
  l_top_model_line_id		  NUMBER;

  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;


BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'ENTERING OE_BULK_CONFIG_UTIL.Validate_Configuration ') ;
  END IF;

  l_book_flag := p_line_rec.booked_flag(p_line_index);
  l_qty_match_flag := p_line_rec.cz_qty_match_flag(p_line_index);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'p_new_config = ' || p_new_config ) ;
  END IF;


  -- Set the message context to the top model line.
  oe_bulk_msg_pub.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => p_line_rec.line_id(p_line_index)
         ,p_header_id                   => p_line_rec.header_id(p_line_index)
         ,p_line_id                     => p_line_rec.line_id(p_line_index)
         ,p_orig_sys_document_ref       => p_line_rec.orig_sys_document_ref(p_line_index)
         ,p_orig_sys_document_line_ref  => p_line_rec.orig_sys_line_ref(p_line_index)
         ,p_source_document_id          => NULL
         ,p_source_document_line_id     => NULL
         ,p_order_source_id             => p_line_rec.order_source_id(p_line_index)
         ,p_source_document_type_id     => NULL );


  IF p_new_config = 'N'  AND
     l_book_flag  = 'N'  AND
     l_qty_match_flag = 'Y'
  THEN
      -- We do not need to call Batch Validation API.
      -- Instead call CZ_CONFIG_API_PUB.verify_configuration

      IF l_debug_level  > 0 THEN
         OE_Debug_Pub.Add('Calling CZ_CONFIG_API_PUB.verify_configuration');
      END IF;

      CZ_CONFIG_API_PUB.verify_configuration
      (  p_api_version        => 1.0,
         p_config_hdr_id      => l_config_header_id,
         p_config_rev_nbr     => l_config_rev_nbr,
         x_exists_flag        => l_exists_flag,
         x_valid_flag         => l_valid_flag,
         x_complete_flag      => l_complete_flag,
         x_return_status      => l_return_status,
         x_msg_count          => l_msg_count,
         x_msg_data           => l_msg_data );


      IF l_debug_level  > 0 THEN
          oe_debug_pub.add (' Exists Flag :' ||l_exists_flag,2);
          oe_debug_pub.add (' Valid Flag :'|| l_valid_flag,2);
          oe_debug_pub.add (' Complete Flag :'|| l_complete_flag,2);
          oe_debug_pub.add (' Return Status :'|| l_return_status,2);
          oe_debug_pub.add (' Message Count :'|| l_msg_count,2);
          oe_debug_pub.add (' Message Data  :'|| l_msg_data,2);
      END IF;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF  l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          IF l_exists_flag = FND_API.G_FALSE THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Configuration Does not Exist '|| l_msg_data,2);
              END IF;
              RAISE FND_API.G_EXC_ERROR;
          ELSE
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add  (' Configuration Exists ',2);
             END IF;

             IF l_valid_flag  = FND_API.G_FALSE THEN
                l_valid_config := 'FALSE';
             ELSE
                l_valid_config := 'TRUE';
             END IF;

             IF l_complete_flag = FND_API.G_FALSE THEN
                l_complete_config := 'FALSE';
             ELSE
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Configuration Exists, valid and Complete ',2);
                END IF;
                l_complete_config := 'TRUE';
             END IF;
          END IF; -- if exist flag = false
      END IF; -- if success

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('CALLING Message_From_CZ' , 2 );
      END IF;
      Message_From_CZ(
	 p_line_rec	        => p_line_rec,
         p_line_index   	=> p_line_index,
         p_valid_config  	=> l_valid_config,
         p_complete_config   	=> l_complete_config,
         p_config_header_id  	=> l_config_header_id,
         p_config_rev_nbr    	=> l_config_rev_nbr,
	 x_return_status	=> l_return_status);

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


  ELSE -- call batch val

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CALLING CREATE_HDR_XML' , 2 );
      END IF;
      Create_hdr_xml( p_line_rec  	=> p_line_rec,
                      p_line_index	=> p_line_index,
		      x_xml_hdr		=> l_xml_hdr,
	              x_return_status	=> l_return_status);

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('CALLING SEND_INPUT_XML' , 2 );
      END IF;

      Send_input_xml
            ( p_line_rec 	=> p_line_rec,
  	      p_line_index	=> p_line_index,
	      p_new_config	=> p_new_config,
              p_xml_hdr         => l_xml_hdr,
              x_out_xml_msg     => l_xml_message,
              x_return_status   => l_return_status,
	      p_batch_validate_time => p_batch_validate_time);

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add
              ('AFTER CALLING SEND_INPUT_XML: '||L_RETURN_STATUS , 2 );
      END IF;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_xml_message := UPPER(l_xml_message);

      -- extract data from xml message.
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('CALLING PARSE_OUTPUT_XML' , 2 );
      END IF;

      Parse_Output_xml
      	      ( p_xml               => l_xml_message,
         	p_line_index        => p_line_index,
		p_line_rec	    => p_line_rec,
        	x_valid_config      => l_valid_config,
        	x_complete_config   => l_complete_config,
        	x_config_header_id  => l_config_header_id,
        	x_config_rev_nbr    => l_config_rev_nbr,
        	x_return_status     => l_return_status );

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('AFTER CALLING PARSE_OUTPUT_XML: '||L_RETURN_STATUS , 2 );
      END IF;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_valid_config = 'FALSE' OR l_complete_config = 'FALSE') THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add('ERROR CONFIG' , 2 );
          END IF;
          RAISE FND_API.G_EXC_ERROR;

      END IF;

      -- As a part of the Batch Validation CRN can change for a configuration.
      -- Update CHI, CRN on all lines in that model.

      I := 0;
      -- l_top_model_line_id := p_line_rec.top_model_line_id(p_line_index);

      WHILE p_line_index + I <= p_line_rec.line_id.count AND
 	    p_line_rec.top_model_line_ref(p_line_index + I) =
			p_line_rec.top_model_line_ref(p_line_index) AND
	    p_line_rec.header_id(p_line_index + I) = p_line_rec.header_id(p_line_index) LOOP

          p_line_rec.config_header_id(p_line_index + I ) := l_config_header_id;
          p_line_rec.config_rev_nbr(p_line_index + I ) := l_config_rev_nbr;
	  I := I + 1;
      END LOOP;

  END IF;  -- if skip batch val


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXITING OE_BULK_CONFIG_UTIL.CONFIGURATOR_VALIDATION' , 1);
  END IF;


EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('AN EXC ERROR RAISED IN Validate_Configuration', 1);
     END IF;
     FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_VALIDATION_FAILURE');
     OE_Bulk_Msg_Pub.Add;
     p_line_rec.lock_control(p_line_index) := -99;

  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Others Error, OE_BULK_CONFIG_UTIL.Validate_Configuration');
       oe_debug_pub.add(substr(sqlerrm,1,240));
    END IF;

    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME,
          'Validate_Configuration'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Configuration;



---------------------------------------------------------------------
--
-- PROCEDURE Pre_Process_Configurator
--
---------------------------------------------------------------------

PROCEDURE Pre_Process_Configurator(
  p_batch_id                IN NUMBER
 ,p_validate_only	    IN VARCHAR2
 ,p_use_configurator	    IN VARCHAR2
 ,p_validate_configurations IN VARCHAR2
)
IS

-- Load the model records from the order import interface tables. For importing
-- pre-created configurations, users will specify CRN(config_rev_nbr),
-- CHI(config_header_id) and either CI(configuration_id) or CC (component_code)
-- If p_validate_configuration = Y Then use cursor c_line_config1 that has extra
-- joins to CZ_CONFIG_DETAILS_V Z, OE_ACTIONS_INTERFACE a. These are needed
-- to derive extra attributes that are needed for CZ batch validation API.
-- Else then use cursor c_line_config2
--
CURSOR c_line_config1 IS
   SELECT l.line_id,
	  l.top_model_line_ref,
	  l.config_header_id,
          l.config_rev_nbr,
          nvl(l.configuration_id, z.CONFIG_ITEM_ID) configuration_id,
          l.orig_sys_document_ref,
          l.orig_sys_line_ref,
          l.orig_sys_shipment_ref,
          l.order_source_id,
          l.ordered_quantity,
          l.inventory_item_id,
          h.header_id,
          nvl(h.booked_flag,decode(a.order_source_id,NULL,'N','Y')) booked_flag,
          decode(l.ordered_quantity, nvl(z.quantity, l.ordered_quantity),'Y','N')
					cz_qty_match_flag,
          nvl(l.component_code, z.component_code) component_code
   FROM  OE_HEADERS_IFACE_ALL H,
         OE_LINES_IFACE_ALL L ,
         CZ_CONFIG_DETAILS_V Z,
         OE_ACTIONS_INTERFACE a
   WHERE    h.batch_id = p_batch_id
      AND   h.order_source_id = l.order_source_id
      AND   h.orig_sys_document_ref = l.orig_sys_document_ref
      AND   nvl(h.error_flag,'N') = 'N'
      AND   nvl(l.error_flag,'N') = 'N'
      AND   nvl(l.rejected_flag,'N') = 'N'
      AND   l.item_type_code = 'MODEL'
      AND   l.top_model_line_ref = l.orig_sys_line_ref
      AND   nvl(l.config_header_id,-1) = z.config_hdr_id (+)
      AND   nvl(l.config_rev_nbr, -1) = z.config_rev_nbr(+)
      -- AND   NVL(l.configuration_id,-1) = z.config_item_id(+)
      AND   NVL(l.component_code, '-1') = z.component_code(+)
      AND   a.order_source_id(+) = h.order_source_id
      AND   a.orig_sys_document_ref(+) = h.orig_sys_document_ref
      AND   a.operation_code(+) = 'BOOK_ORDER';


CURSOR c_line_config2 IS
   SELECT l.line_id,
	  h.header_id,
	  l.top_model_line_ref,
	  l.config_header_id,
          l.config_rev_nbr,
          l.configuration_id,
          l.orig_sys_document_ref,
          l.orig_sys_line_ref,
          l.orig_sys_shipment_ref,
          l.order_source_id,
          l.ordered_quantity
   FROM  OE_HEADERS_IFACE_ALL H,
         OE_LINES_IFACE_ALL L
   WHERE  h.batch_id = p_batch_id
      AND   h.order_source_id = l.order_source_id
      AND   h.orig_sys_document_ref = l.orig_sys_document_ref
      AND   nvl(h.error_flag,'N') = 'N'
      AND   nvl(l.error_flag,'N') = 'N'
      AND   nvl(l.rejected_flag,'N') = 'N'
      AND   l.item_type_code = 'MODEL'
      AND   l.top_model_line_ref = l.orig_sys_line_ref;


  l_line_rec 	OE_WSH_BULK_GRP.LINE_REC_TYPE;
  l_config_rec		OE_BULK_CONFIG_UTIL.CONFIG_REC_TYPE;
  I 		NUMBER;

  l_Need_Bom_Explosion 	VARCHAR2(1) := 'N';

  l_order_source_id        NUMBER := -99;
  l_orig_sys_document_ref  VARCHAR2(50) := '-99';

  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

  l_start_time                 NUMBER;
  l_end_time                   NUMBER;
  l_config_validate_time       NUMBER := 0;
  l_batch_validate_time	       NUMBER := 0;


BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'ENTERING OE_BULK_CONFIG_UTIL.Pre_Process_Configurator ') ;
  END IF;

  -- Load the cursor into l_line_rec
  IF nvl(p_validate_configurations, 'N') = 'Y' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add( 'before OPEN c_line_config1 ') ;
      END IF;

      OPEN c_line_config1;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add( 'after OPEN c_line_config1 ') ;
      END IF;

      FETCH c_line_config1 BULK COLLECT INTO
	  l_line_rec.line_id,
	  l_line_rec.top_model_line_ref,
	  l_line_rec.config_header_id,
          l_line_rec.config_rev_nbr,
          l_line_rec.configuration_id,
          l_line_rec.orig_sys_document_ref,
          l_line_rec.orig_sys_line_ref,
          l_line_rec.orig_sys_shipment_ref,
          l_line_rec.order_source_id,
          l_line_rec.ordered_quantity,
          l_line_rec.inventory_item_id,
          l_line_rec.header_id,
          l_line_rec.booked_flag,
          l_line_rec.cz_qty_match_flag,
          l_line_rec.component_code;

      CLOSE c_line_config1;
  ELSE
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add( 'before OPEN c_line_config2 ') ;
      END IF;

      OPEN c_line_config2;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add( 'after OPEN c_line_config2 ') ;
      END IF;

      FETCH c_line_config2 BULK COLLECT INTO
	  l_line_rec.line_id,
	  l_line_rec.header_id,
	  l_line_rec.top_model_line_ref,
 	  l_line_rec.config_header_id,
          l_line_rec.config_rev_nbr,
          l_line_rec.configuration_id,
          l_line_rec.orig_sys_document_ref,
          l_line_rec.orig_sys_line_ref,
          l_line_rec.orig_sys_shipment_ref,
          l_line_rec.order_source_id,
          l_line_rec.ordered_quantity;

     CLOSE c_line_config2;

  END IF; -- p_validate_configurations = 'Y'

  -- Exit procedure if no model line fetched
  IF l_line_rec.config_header_id.count < 1 THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add( 'no model line exists in batch:  '|| p_batch_id) ;
      END IF;
      RETURN;
  END IF;


  Extend_Line_Rec
        (p_count	=> l_line_rec.line_id.count
        ,p_line_rec	=> l_line_rec
	,p_config_rec	=> l_config_rec
        );

  IF l_debug_level  > 0 THEN
     Print_Line_Rec( p_line_rec    => l_line_rec,
		  p_config_rec  => l_config_rec);
  END IF;


  -- Looping over the model lines
  FOR I IN 1..l_line_rec.line_id.count LOOP

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'IN PRE_PROCESS_CONFIGURATOR LOOP INDEX : I = '|| I  ) ;
      END IF;


      -- skip line if order has config error
      IF p_validate_only = 'N' AND
         l_order_source_id = l_line_rec.order_source_id(I) AND
         l_orig_sys_document_ref = l_line_rec.orig_sys_document_ref(I) THEN

         IF l_debug_level > 0 Then
            oe_debug_pub.add('Skip line in Pre_Process_Configurator(): '||l_line_rec.line_id(I));
         END IF;

	 GOTO SKIP_THE_LINE;

      END IF;

      -- Set the message context for errors.
      oe_bulk_msg_pub.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => l_line_rec.line_id(I)
         ,p_header_id                   => l_line_rec.header_id(I)
         ,p_line_id                     => l_line_rec.line_id(I)
         ,p_orig_sys_document_ref       => l_line_rec.orig_sys_document_ref(I)
         ,p_orig_sys_document_line_ref  => l_line_rec.orig_sys_line_ref(I)
         ,p_source_document_id          => NULL
         ,p_source_document_line_id     => NULL
         ,p_order_source_id             => l_line_rec.order_source_id(I)
         ,p_source_document_type_id     => NULL );


      Validate_Config_Attributes(
	 	p_use_Configurator	=> 'Y',
		p_line_rec 		=> l_line_rec,
		p_line_index		=> I
      );


      -- If configuration is pre-created that is the CHI, CNR and CI/CC are not NULL
      IF l_line_rec.config_header_id(I) IS NOT NULL AND
	 l_line_rec.config_rev_nbr(I) IS NOT NULL AND
	 ( l_line_rec.configuration_id(I) IS NOT NULL OR
	   l_line_rec.component_code(I) IS NOT NULL)
      THEN
	  IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'Pre-created configuration' ) ;
      	  END IF;

	  IF nvl(p_validate_configurations, 'N') = 'Y' THEN

              SELECT hsecs INTO l_start_time from v$timer;

	      Validate_Configuration(
			  p_new_config 		=> 'N',
			  p_line_rec 		=> l_line_rec,
			  p_line_index		=> I,
			  p_batch_validate_time => l_batch_validate_time
			);

              SELECT hsecs INTO l_end_time from v$timer;
	      l_config_validate_time := l_config_validate_time + (l_end_time-l_start_time)/100;

	  END IF;

          -- For Top Model record use following cursor to load Model + all child
          -- lines into temp table. This will include missing child lines on
          -- iface(Case when only model line is specified and partial/none child
          -- lines are specified)

	  -- insert missing child lines
          INSERT INTO oe_config_details_tmp
	  (
 		LINE_ID ,
 		TOP_MODEL_LINE_ID,
 		ATO_LINE_ID,
 		LINK_TO_LINE_ID,
 		ORDER_SOURCE_ID,
 		ORIG_SYS_DOCUMENT_REF,
 		ORIG_SYS_LINE_REF ,
 		ORIG_SYS_SHIPMENT_REF ,
 		TOP_MODEL_LINE_REF ,
 		INVENTORY_ITEM_ID,
		--ORDERED_ITEM,
 		UOM_CODE,
 		ORDERED_QUANTITY,
 		COMPONENT_CODE,
 		COMPONENT_SEQUENCE_ID,
 		SORT_ORDER ,
 		CONFIG_HEADER_ID,
 		CONFIG_REV_NBR ,
 		CONFIGURATION_ID,
 		TOP_BILL_SEQUENCE_ID,
 		ITEM_TYPE_CODE,
		LINE_TYPE,
 		CZ_QTY_MATCH_FLAG,
 		HIGH_QUANTITY,
 		LOW_QUANTITY,
 		MUTUALLY_EXCLUSIVE_OPTIONS,
 		BOM_ITEM_TYPE,
 		LOCK_CONTROL,
 		REPLENISH_TO_ORDER_FLAG )
          SELECT
	       oe_order_lines_s.nextval         Line_id,
	       l_line_rec.line_id(I)  		top_model_line_id,
               decode(z.config_item_id, z.ato_config_item_id, oe_order_lines_s.currval,NULL)
 						ato_line_id,
               decode(z.config_item_id, z.ato_config_item_id,l_line_rec.line_id(I),NULL)
						link_to_line_id,
	       l_line_rec.order_source_id(I)	order_source_id,
	       l_line_rec.orig_sys_document_ref(I) orig_sys_document_ref,
	       'OE_ORDER_LINES_ALL'||oe_order_lines_s.currval orig_sys_line_ref,
	       null 				orig_sys_shipment_ref,
	       l_line_rec.orig_sys_line_ref(I) 	top_model_line_ref,
	       z.inventory_item_id,
	       -- NULL 				ordered_item,
 	       z.uom_code,
 	       z.quantity   			ordered_quantity,
	       z.Component_code,
  	       z.Component_sequence_id,
    	       z.Bom_Sort_order,
     	       z.config_hdr_id,
   	       z.Config_rev_nbr,
 	       z.config_item_id  		Configuration_id,
	       null				top_bill_sequence_id,
               null 				item_type_code,
               z.line_type,
    	       'Y'   				cz_qty_match_flag,
 	       null				HIGH_QUANTITY,
 	       null				LOW_QUANTITY,
 	       null				MUTUALLY_EXCLUSIVE_OPTIONS,
 	       null				BOM_ITEM_TYPE,
 	       null				LOCK_CONTROL,
 	       null				REPLENISH_TO_ORDER_FLAG
          FROM   cz_config_details_v z
          WHERE z.config_hdr_id = l_line_rec.config_header_id(I)
               AND   z.config_rev_nbr = l_line_rec.config_rev_nbr(I)
               AND   NOT EXISTS (
                 	Select   l.line_id
                        from     oe_lines_iface_all l
                        WHERE NVL(l.configuration_id, z.config_item_id) = z.config_item_id
                        AND    NVL(l.component_code, z.component_code) = z.component_code
                        AND    l.top_model_line_ref = l_line_rec.ORIG_SYS_LINE_REF(I)
                        AND    l.orig_sys_document_ref = l_line_rec.ORIG_SYS_DOCUMENT_REF(I)
                        AND    l.order_source_id = l_line_rec.ORDER_SOURCE_ID(I));


      	  IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INSERTED '||SQL%ROWCOUNT||' MISSING CHILD TO TMP'||I , 3 ) ;
      	  END IF;

	  -- insert lines from interface table
          INSERT INTO oe_config_details_tmp
	  (
 		LINE_ID ,
 		TOP_MODEL_LINE_ID,
 		ATO_LINE_ID,
 		LINK_TO_LINE_ID,
 		ORDER_SOURCE_ID,
 		ORIG_SYS_DOCUMENT_REF,
 		ORIG_SYS_LINE_REF ,
 		ORIG_SYS_SHIPMENT_REF ,
 		TOP_MODEL_LINE_REF ,
 		INVENTORY_ITEM_ID,
		-- ORDERED_ITEM,
 		UOM_CODE,
 		ORDERED_QUANTITY,
 		COMPONENT_CODE,
 		COMPONENT_SEQUENCE_ID,
 		SORT_ORDER ,
 		CONFIG_HEADER_ID,
 		CONFIG_REV_NBR ,
 		CONFIGURATION_ID,
 		TOP_BILL_SEQUENCE_ID,
 		ITEM_TYPE_CODE,
		LINE_TYPE,
 		CZ_QTY_MATCH_FLAG,
 		HIGH_QUANTITY,
 		LOW_QUANTITY,
 		MUTUALLY_EXCLUSIVE_OPTIONS,
 		BOM_ITEM_TYPE,
 		LOCK_CONTROL,
 		REPLENISH_TO_ORDER_FLAG )
          SELECT
	      l.Line_id,
              l_line_rec.line_id(I) 		top_model_line_id,
              decode(z.config_item_id, z.ato_config_item_id,l.line_id,NULL)
						ato_line_id,
              decode(z.config_item_id, z.ato_config_item_id,l_line_rec.line_id(I),NULL)
						link_to_line_id,
	      l_line_rec.order_source_id(I)	order_source_id,
	      l_line_rec.orig_sys_document_ref(I) orig_sys_document_ref,
	      l_line_rec.orig_sys_line_ref(I)  	orig_sys_line_ref,
	      null 				orig_sys_shipment_ref,
              l.top_model_line_ref,
              z.inventory_item_id,
	      -- l_line_rec.ordered_item(I)	ordered_item,
              z.uom_code,
              z.quantity   			ordered_quantity,
              z.Component_code,
              z.Component_sequence_id,
              z.Bom_Sort_order,
              z.config_hdr_id,
              z.Config_rev_nbr,
              z.config_item_id 			Configuration_id,
	      null				top_bill_sequence_id,
              l.item_type_code,
              z.line_type,
              decode(l.ordered_quantity, z.quantity,'Y','N')
						cz_qty_match_flag,
 	      null				HIGH_QUANTITY,
 	      null				LOW_QUANTITY,
 	      null				MUTUALLY_EXCLUSIVE_OPTIONS,
 	      null				BOM_ITEM_TYPE,
 	      l_line_rec.lock_control(I)        LOCK_CONTROL,
 	      null				REPLENISH_TO_ORDER_FLAG
          FROM   cz_config_details_v z, oe_lines_iface_all l
          WHERE z.config_hdr_id = l_line_rec.config_header_id(I)
              AND     z.config_rev_nbr = l_line_rec.config_rev_nbr(I)
              AND     NVL(l.configuration_id,z.config_item_id) = z.config_item_id
              AND     NVL(l.component_code, z.component_code) = z.component_code
              AND     l.orig_sys_document_ref = l_line_rec.ORIG_SYS_DOCUMENT_REF(I)
              AND     l.order_source_id = l_line_rec.ORDER_SOURCE_ID(I)
              AND     l.top_model_line_ref = l_line_rec.ORIG_SYS_LINE_REF(I) ;

      	  IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INSERTED '||SQL%ROWCOUNT||' LINES TO TMP FROM IFACE '||I , 3 ) ;
      	  END IF;


      ELSE -- new configuration

          -- User is trying to import a new configuration. We will set a flag
	  -- to indicate that we will need to call BOM_Explosion for these lines
	  -- to get component_code and other attributes from BOM.

          l_Need_Bom_Explosion := 'Y';

      END IF;


      <<SKIP_THE_LINE>>

      IF p_validate_only = 'N' AND nvl(l_line_rec.lock_control(I), 0) = -99 THEN
	 l_order_source_id := l_line_rec.order_source_id(I);
         l_orig_sys_document_ref := l_line_rec.orig_sys_document_ref(I);

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SKIP order_source_id: '||l_order_source_id, 3 ) ;
            oe_debug_pub.add(  'SKIP orig_sys_document_ref: '||l_orig_sys_document_ref, 3 ) ;
         END IF;

      END IF;

  END LOOP;  -- loop over the model lines


  FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in config_validate is (sec) '
          || l_config_validate_time );

  FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in batch_validate is (sec) '
          || l_batch_validate_time );


  -- Need to call Pre_Process_Bom for new configuration
  IF l_Need_Bom_Explosion = 'Y' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add( 'Need to call Pre_Process_Bom for new configuration ') ;
      END IF;

      Pre_Process_Bom (
	  p_batch_id                => p_batch_id,
          p_validate_only           => p_validate_only,
 	  p_use_configurator	    => p_use_configurator,
 	  p_validate_configurations => p_validate_configurations
      );

  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'EXITING OE_BULK_CONFIG_UTIL.Pre_Process_Configurator ') ;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('NO DATA FOUND in OE_BULK_CONFIG_UTIL.Pre_Process_Configurator ' , 1);
    END IF;

  WHEN OTHERS THEN

    IF c_line_config1%ISOPEN THEN
	CLOSE c_line_config1;
    ELSIF c_line_config2%ISOPEN THEN
	CLOSE c_line_config2;
    END IF;

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Others Error, OE_BULK_CONFIG_UTIL.Pre_Process_Configurator');
       oe_debug_pub.add(substr(sqlerrm,1,240));
    END IF;

    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME,
          'Pre_Process_Configurator'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pre_Process_Configurator;



---------------------------------------------------------------------
--
-- PROCEDURE Pre_Process_Bom
--
---------------------------------------------------------------------

PROCEDURE Pre_Process_Bom(
  p_batch_id                IN NUMBER
 ,p_validate_only	    IN VARCHAR2
 ,p_use_configurator	    IN VARCHAR2
 ,p_validate_configurations IN VARCHAR2
)
IS


-- Load the line records from the order import interface tables.
-- If p_use_configurator = Y Then this procedure is called from
-- pre_process_Configurator(), load the lines that with new configurations
-- where the CHI, CNR and CI have NULL value, so to use cursor c_line_bom1
-- Else use cursor c_line_bom2

CURSOR c_line_bom1 IS
   Select l.line_id,
          l.Top_model_line_REF,
	  null Top_model_line_id,
          l.Component_code,
          l.Component_sequence_id,
          l.sort_order,
          l.config_header_id,
          l.config_rev_nbr,
          l.configuration_id,
          l.item_type_code,
	  l.order_source_id,
          l.orig_sys_document_ref,
          l.orig_sys_line_ref,
          l.orig_sys_shipment_ref,
          l.ordered_quantity,
          -- l.top_bill_sequence_id,  -- Donot need this column
          l.inventory_item_id,
          l.customer_item_id_type,
          l.customer_item_id,
          l.customer_item_name,
          l.sold_to_org_id,
          l.ship_from_org_id,
          h.header_id,
          nvl(h.booked_flag,decode(a.order_source_id,NULL,'N','Y')) booked_flag,
          'N'   cz_qty_match_flag
   FROM  OE_HEADERS_IFACE_ALL H,
         OE_LINES_IFACE_ALL L,
         OE_ACTIONS_INTERFACE a
   WHERE  h.batch_id = p_batch_id
      AND   h.order_source_id = l.order_source_id
      AND   h.orig_sys_document_ref = l.orig_sys_document_ref
      AND   nvl(h.error_flag,'N') = 'N'
      AND   nvl(l.error_flag,'N') = 'N'
      AND   nvl(l.rejected_flag,'N') = 'N'
      AND   l.top_model_line_ref IS NOT NULL
      AND   l.config_header_id IS NULL
      AND   l.config_rev_nbr IS NULL
      AND   l.configuration_id IS NULL
      AND   a.order_source_id(+) = h.order_source_id
      AND   a.orig_sys_document_ref(+) = h.orig_sys_document_ref
      AND   a.operation_code(+) = 'BOOK_ORDER'
     ORDER BY h.header_id,
	      l.top_model_line_ref,
	      decode(item_type_code,'MODEL',item_type_code,'XXX'),
	      l.component_code;

CURSOR c_line_bom2 IS
    Select  l.line_id,
	  h.header_id,
          l.Top_model_line_REF,
	  null Top_model_line_id,
          l.Component_code,
          l.Component_sequence_id,
          l.sort_order,
          l.config_header_id,
          l.config_rev_nbr,
          l.configuration_id,
          l.item_type_code,
	  l.order_source_id,
          l.orig_sys_document_ref,
          l.orig_sys_line_ref,
          l.orig_sys_shipment_ref,
          l.ordered_quantity,
          -- l.top_bill_sequence_id,
          l.inventory_item_id,
          l.customer_item_id_type,
          l.customer_item_id,
          l.customer_item_name,
          l.sold_to_org_id,
          l.ship_from_org_id
    FROM  OE_HEADERS_IFACE_ALL H,
	  OE_LINES_IFACE_ALL L
    WHERE  h.batch_id = p_batch_id
      AND   h.order_source_id = l.order_source_id
      AND   h.orig_sys_document_ref = l.orig_sys_document_ref
      AND   nvl(h.error_flag,'N') = 'N'
      AND   nvl(l.error_flag,'N') = 'N'
      AND   nvl(l.rejected_flag,'N') = 'N'
      AND   top_model_line_ref IS NOT NULL
    ORDER BY h.header_id,
	     l.top_model_line_ref,
	     decode(item_type_code,'MODEL',item_type_code,'XXX'),
	     l.component_code;

  l_line_rec 		OE_WSH_BULK_GRP.LINE_REC_TYPE;
  l_config_rec		OE_BULK_CONFIG_UTIL.CONFIG_REC_TYPE;
  I 			NUMBER;
  l_curr_model_index	NUMBER;
  l_curr_ato_index	NUMBER;

  l_debug_level 	CONSTANT NUMBER := oe_debug_pub.g_debug_level;

  l_msg_data         	VARCHAR2(2000);
  l_error_code        	VARCHAR2(2000);
  l_return_status    	VARCHAR2(30);

  l_order_source_id        NUMBER := -99;
  l_orig_sys_document_ref  VARCHAR2(50) := '-99';

  l_start_time                 NUMBER;
  l_end_time                   NUMBER;
  l_config_validate_time       NUMBER := 0;
  l_batch_validate_time	       NUMBER := 0;


BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'ENTERING OE_BULK_CONFIG_UTIL.Pre_Process_Bom ', 1) ;
  END IF;

  -----------------------------------------------------------------
  -- Load this cursor into Line Rec (OE_WSH_BULK_GRP.line_rec_type)
  -----------------------------------------------------------------


  IF nvl(p_use_configurator, 'N') = 'Y' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add( 'before OPEN c_line_bom1 ') ;
      END IF;

      OPEN c_line_bom1;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add( 'after OPEN c_line_bom1 ') ;
      END IF;

      FETCH c_line_bom1 BULK COLLECT INTO
	  l_line_rec.line_id,
          l_line_rec.Top_model_line_REF,
          l_line_rec.Top_model_line_id,
          l_line_rec.Component_code,
          l_line_rec.Component_sequence_id,
          l_line_rec.sort_order,
          l_line_rec.config_header_id,
          l_line_rec.config_rev_nbr,
          l_line_rec.configuration_id,
          l_line_rec.item_type_code,
	  l_line_rec.order_source_id,
          l_line_rec.orig_sys_document_ref,
          l_line_rec.orig_sys_line_ref,
          l_line_rec.orig_sys_shipment_ref,
          l_line_rec.ordered_quantity,
          l_line_rec.inventory_item_id,
          l_line_rec.item_identifier_type,
          l_line_rec.ordered_item_id,
          l_line_rec.ordered_item,
          l_line_rec.sold_to_org_id,
          l_line_rec.ship_from_org_id,
          l_line_rec.header_id,
          l_line_rec.booked_flag,
          l_line_rec.cz_qty_match_flag;

      CLOSE c_line_bom1;
  ELSE
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add( 'before OPEN c_line_bom2 ', 3) ;
      END IF;

      OPEN c_line_bom2;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add( 'after OPEN c_line_bom2 ') ;
      END IF;

      FETCH c_line_bom2 BULK COLLECT INTO
	  l_line_rec.line_id,
	  l_line_rec.header_id,
          l_line_rec.Top_model_line_REF,
          l_line_rec.Top_model_line_id,
          l_line_rec.Component_code,
          l_line_rec.Component_sequence_id,
          l_line_rec.sort_order,
          l_line_rec.config_header_id,
          l_line_rec.config_rev_nbr,
          l_line_rec.configuration_id,
          l_line_rec.item_type_code,
	  l_line_rec.order_source_id,
          l_line_rec.orig_sys_document_ref,
          l_line_rec.orig_sys_line_ref,
          l_line_rec.orig_sys_shipment_ref,
          l_line_rec.ordered_quantity,
          l_line_rec.inventory_item_id,
          l_line_rec.item_identifier_type,
          l_line_rec.ordered_item_id,
          l_line_rec.ordered_item,
          l_line_rec.sold_to_org_id,
          l_line_rec.ship_from_org_id;

      CLOSE c_line_bom2;

  END IF;  -- p_use_configurator = 'Y'

  Extend_Line_Rec
        (p_count	=> l_line_rec.line_id.count
        ,p_line_rec	=> l_line_rec
	,p_config_rec	=> l_config_rec
        );

  ------------------------------------------
  -- Start Looping over l_line_rec tables:
  ------------------------------------------
  FOR I IN 1..l_line_rec.line_id.count LOOP

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  ' IN PRE_PROCESS_BOM LOOP INDEX : I = '|| I  ) ;
      END IF;


      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'order_source_id = '|| l_line_rec.order_source_id(I)  ) ;
          oe_debug_pub.add(  'orig_sys_document_ref = '||l_line_rec.orig_sys_document_ref(I)  ) ;

      END IF;


      IF p_validate_only = 'N' AND
         l_order_source_id = l_line_rec.order_source_id(I) AND
         l_orig_sys_document_ref = l_line_rec.orig_sys_document_ref(I) THEN

         IF l_debug_level > 0 Then
            oe_debug_pub.add('Skip line in Pre_Process_Bom(): '||l_line_rec.line_id(I));
         END IF;

	 GOTO SKIP_THE_LINE;

      END IF;

      -- Set the message context for errors.
      oe_bulk_msg_pub.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => l_line_rec.line_id(I)
         ,p_header_id                   => l_line_rec.header_id(I)
         ,p_line_id                     => l_line_rec.line_id(I)
         ,p_orig_sys_document_ref       => l_line_rec.orig_sys_document_ref(I)
         ,p_orig_sys_document_line_ref  => l_line_rec.orig_sys_line_ref(I)
         ,p_source_document_id          => NULL
         ,p_source_document_line_id     => NULL
         ,p_order_source_id             => l_line_rec.order_source_id(I)
         ,p_source_document_type_id     => NULL );

      -- To check for mandatory attributes call Validate_config_attributes
      Validate_Config_Attributes(
	 	p_use_Configurator	=> p_use_Configurator,
		p_line_rec 		=> l_line_rec,
		p_line_index		=> I
      );

      -- Get inventory_item_id if NULL on l_line_rec.
      IF l_line_rec.inventory_item_id(I) IS NULL THEN
	  OE_BULK_PROCESS_LINE.Get_Item_Info(
			p_index => I,
                        p_line_rec => l_line_rec
	  );
      END IF;

      -- IF Model Line then Set top_model_line_id(I) = line_id(I);
      -- Load BOM into bom_explosions table if not there already.
      IF l_line_rec.item_type_code(I) = 'MODEL'  AND
	 l_line_rec.top_model_line_ref(I) = l_line_rec.orig_sys_line_ref(I) THEN

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'MODEL LINE ID = ' || l_line_rec.line_id(I) ) ;
          END IF;

	  l_line_rec.top_model_line_id(I) := l_line_rec.line_id(I);

          OE_Config_UTIL.Explode
          (
	  	p_validation_org 	=> OE_BULK_ORDER_PVT.G_ITEM_ORG,
	  	p_group_id       	=> NULL,
	  	p_session_id     	=> 0,   -- ( null ?)
          	p_levels         	=> 60,  -- (6 ?)
          	p_stdcompflag    	=> OE_Config_Util.OE_BMX_OPTION_COMPS,
	  	p_exp_quantity   	=> l_line_rec.ordered_quantity(I),
          	p_top_item_id    	=> l_line_rec.inventory_item_id(I),
          	p_revdate        	=> sysdate,
	  	p_component_code 	=> l_line_rec.component_code(I),
          	x_msg_data       	=> l_msg_data,
          	x_error_code     	=> l_error_code,
          	x_return_status  	=> l_return_status
          );


          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      	      IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'ERROR in OE_Config_UTIL.Explode' ) ;
              END IF;
              l_line_rec.lock_control(I) := -99;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     	      IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'UNEXPECTED ERROR in OE_Config_UTIL.Explode' ) ;
              END IF;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

	  -- Get the bill_sequence_id for model line.
          SELECT bill_sequence_id,
                 component_code,
                 component_sequence_id,
                 sort_order,
                 primary_uom_code,
                 high_quantity,
                 low_quantity,
                 mutually_exclusive_options,
                 bom_item_type,
                 replenish_to_order_flag
          INTO   l_line_rec.Top_Bill_Sequence_Id(I),
                 l_line_rec.component_code(I),
                 l_line_rec.component_sequence_id(I),
                 l_line_rec.sort_order(I),
                 l_line_rec.order_quantity_uom(I),
                 l_config_rec.high_quantity(I),
                 l_config_rec.low_quantity(I),
                 l_config_rec.mutually_exclusive_options(I),
                 l_config_rec.bom_item_type(I),
                 l_config_rec.replenish_to_order_flag(I)
          FROM 	bom_explosions
          WHERE COMPONENT_ITEM_ID = l_line_rec.inventory_item_id(I)
          AND 	ORGANIZATION_ID = OE_BULK_ORDER_PVT.G_ITEM_ORG
          AND 	PLAN_LEVEL = 0
          AND   nvl(effectivity_date, sysdate) <= sysdate
          AND   nvl(disable_date, sysdate+1)   > sysdate
          AND 	explosion_type = OE_Config_Util.OE_BMX_OPTION_COMPS;


          -- Set curr_model_index = cureent_index
	  l_curr_model_index := I;

	  -- If Top Model is an ATO model (replenish_to_order_flag(I) = Y ) Then
          -- Set curr_ato_line_index = current_index;
          -- Set l_line_rec.ato_line_id(I) = line_id;

	  l_curr_ato_index := null;
	  IF nvl(l_config_rec.replenish_to_order_flag(I), 'N') = 'Y' THEN
	      l_curr_ato_index := I;
	      l_line_rec.ato_line_id(I) := l_line_rec.line_id(I);
	  END IF;


      ELSE -- child line

          -- Use curr_model_index to
          -- Set l_line_rec.top_bill_sequence_id(I) on child lines.
          -- Set l_line_rec.top_model_line_id(I) on child lines.
          -- Use curr_ato_line_index to
          -- Set l_line_rec.ato_line_id(I) on child lines

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'CHILD LINE ID = ' || l_line_rec.line_id(I) ) ;
          END IF;


	  l_line_rec.top_bill_sequence_id(I) :=
	  		l_line_rec.top_bill_sequence_id(l_curr_model_index);
	  l_line_rec.top_model_line_id(I) :=
			l_line_rec.top_model_line_id(l_curr_model_index);

	  IF l_curr_ato_index IS NOT NULL THEN
	      l_line_rec.ato_line_id(I) :=
	    		l_line_rec.line_id(l_curr_ato_index);
	  END IF;

          -- For Child Lines, use following cursor to derive the component_code.
          -- Also get other BOM attributes from BOM_EXPLOSIONS as
   	  BEGIN

          SELECT component_code,
                 component_sequence_id,
                 sort_order,
                 primary_uom_code,
                 high_quantity,
                 low_quantity,
                 mutually_exclusive_options,
                 bom_item_type,
                 replenish_to_order_flag
          INTO   l_line_rec.component_code(I),
                 l_line_rec.component_sequence_id(I),
                 l_line_rec.sort_order(I),
                 l_line_rec.order_quantity_uom(I),
                 l_config_rec.high_quantity(I),
                 l_config_rec.low_quantity(I),
                 l_config_rec.mutually_exclusive_options(I),
                 l_config_rec.bom_item_type(I),
                 l_config_rec.replenish_to_order_flag(I)
          FROM   bom_explosions
          WHERE  component_item_id    = l_line_rec.inventory_item_id(I)
          AND    explosion_type       = OE_Config_Util.OE_BMX_OPTION_COMPS
          AND    top_bill_sequence_id = l_line_rec.top_bill_sequence_id(I)
          AND    plan_level > 0
          AND    nvl(effectivity_date, sysdate) <= sysdate
          AND    nvl(disable_date, sysdate+1)   > sysdate
          AND    organization_id =  OE_BULK_ORDER_PVT.G_ITEM_ORG
          AND    component_code  = NVL(l_line_rec.component_code(I), component_code);

          EXCEPTION
      	      WHEN NO_DATA_FOUND THEN
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add('SELECT COMP_CODE FAILED , NO DATA FOUND ' , 1);
                      oe_debug_pub.add('ITEM: '|| L_LINE_REC.INVENTORY_ITEM_ID(I) , 1);
                  END IF;
                  l_line_rec.lock_control(I) := -99;
                  FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_ITEM_NOT_IN_BILL');
                  FND_MESSAGE.Set_Token('COMPONENT', l_line_rec.inventory_item_id(I));
                  FND_MESSAGE.Set_Token('MODEL', l_line_rec.inventory_item_id(l_curr_model_index));
                  oe_bulk_msg_pub.add;

              WHEN TOO_MANY_ROWS THEN
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add('SELECT COMP_CODE FAILED , TOO_MANY ROWS ' , 1);
                      oe_debug_pub.add('ITEM: '|| L_LINE_REC.INVENTORY_ITEM_ID(I) , 1);
                  END IF;
                  l_line_rec.lock_control(I) := -99;
                  FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_AMBIGUITY');
                  FND_MESSAGE.Set_Token('COMPONENT', l_line_rec.inventory_item_id(I));
                  FND_MESSAGE.Set_Token('MODEL', l_line_rec.inventory_item_id(l_curr_model_index));
                  oe_bulk_msg_pub.add;

              WHEN OTHERS THEN
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add('SELECT COMP_CODE FAILED , OTHERS ' , 1);
                      oe_debug_pub.add('ITEM: '|| L_LINE_REC.INVENTORY_ITEM_ID(I) , 1);
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END;

      END IF; -- IF Model Line

      -- Call Load_Item_Attributes() to load item_type_code and ato_line_id
      Load_Item_Attributes
      (
	  p_line_rec 	=> l_line_rec,
	  p_index	=> I
      );


      -- IF Configurator is used and Current line is a last line in the model
      -- Then We will need to call Batch Validation API to create an instance in CZ.

      IF nvl(p_use_configurator, 'N') = 'Y'  AND
	 (I < l_line_rec.line_id.count AND
	  (l_line_rec.top_model_line_ref(I) <> l_line_rec.top_model_line_ref(I+1) OR
	   l_line_rec.header_id(I) <> l_line_rec.header_id(I+1)) OR
	  I = l_line_rec.line_id.count) THEN


          SELECT hsecs INTO l_start_time from v$timer;

	  Validate_Configuration(
			  p_new_config 		=> 'Y',
			  p_line_rec 		=> l_line_rec,
			  p_line_index		=> l_curr_model_index,
			  p_batch_validate_time => l_batch_validate_time
			);

          SELECT hsecs INTO l_end_time from v$timer;
	  l_config_validate_time := l_config_validate_time + (l_end_time-l_start_time)/100;

      END IF;

      <<SKIP_THE_LINE>>

      IF p_validate_only = 'N' AND nvl(l_line_rec.lock_control(I), 0) = -99 THEN
	 l_order_source_id := l_line_rec.order_source_id(I);
         l_orig_sys_document_ref := l_line_rec.orig_sys_document_ref(I);

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SKIP order_source_id: '||l_order_source_id, 3 ) ;
            oe_debug_pub.add(  'SKIP orig_sys_document_ref: '||l_orig_sys_document_ref, 3 ) ;
         END IF;

      END IF;

  END LOOP;

  FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in config_validate is (sec) '
          || l_config_validate_time );

  FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in batch_validate is (sec) '
          || l_batch_validate_time );

  IF l_debug_level  > 0 THEN
     Print_Line_Rec( p_line_rec    => l_line_rec,
		  p_config_rec  => l_config_rec);
  END IF;

  -----------------------------------------------------------------
  -- Do BULK INSERT of all loaded lines into oe_config_details_tmp.
  -----------------------------------------------------------------

  IF nvl(p_use_configurator, 'N') = 'N' THEN

      FORALL I in 1..l_line_rec.line_id.COUNT
      INSERT INTO oe_config_details_tmp
      (
          LINE_ID ,
 	  TOP_MODEL_LINE_ID,
 	  ATO_LINE_ID,
 	  LINK_TO_LINE_ID,
 	  ORDER_SOURCE_ID,
 	  ORIG_SYS_DOCUMENT_REF,
 	  ORIG_SYS_LINE_REF ,
 	  ORIG_SYS_SHIPMENT_REF ,
 	  TOP_MODEL_LINE_REF ,
 	  INVENTORY_ITEM_ID,
	  ORDERED_ITEM,
 	  UOM_CODE,
 	  ORDERED_QUANTITY,
 	  COMPONENT_CODE,
 	  COMPONENT_SEQUENCE_ID,
 	  SORT_ORDER ,
 	  CONFIG_HEADER_ID,
 	  CONFIG_REV_NBR ,
 	  CONFIGURATION_ID,
 	  TOP_BILL_SEQUENCE_ID,
 	  ITEM_TYPE_CODE,
	  --LINE_TYPE,
 	  --CZ_QTY_MATCH_FLAG,
 	  HIGH_QUANTITY,
 	  LOW_QUANTITY,
 	  MUTUALLY_EXCLUSIVE_OPTIONS,
 	  BOM_ITEM_TYPE,
 	  LOCK_CONTROL,
 	  REPLENISH_TO_ORDER_FLAG
      )
      VALUES
      (
         l_line_rec.line_id(I),
         l_line_rec.top_model_line_id(I),
         l_line_rec.ato_line_id(I),
	 l_line_rec.link_to_line_id(I),
	 l_line_rec.order_source_id(I),
         l_line_rec.orig_sys_document_ref(I),
         l_line_rec.orig_sys_line_ref(I),
         l_line_rec.orig_sys_shipment_ref(I),
         l_line_rec.Top_model_line_REF(I),
	 l_line_rec.inventory_item_id(I),
	 l_line_rec.ordered_item(I),
	 l_line_rec.order_quantity_uom(I),
         l_line_rec.ordered_quantity(I),
         l_line_rec.Component_code(I),
         l_line_rec.Component_sequence_id(I),
         l_line_rec.sort_order(I),
         l_line_rec.config_header_id(I),
         l_line_rec.config_rev_nbr(I),
	 l_line_rec.configuration_id(I),
         l_line_rec.top_bill_sequence_id(I),
         l_line_rec.item_type_code(I),
         l_config_rec.high_quantity(I),
         l_config_rec.low_quantity(I),
         l_config_rec.mutually_exclusive_options(I),
         l_config_rec.bom_item_type(I),
	 l_line_rec.lock_control(I),
         l_config_rec.replenish_to_order_flag(I)
      );

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INSERTED '||SQL%ROWCOUNT||' TO TMP FROM LINE_REC' , 3 ) ;
      END IF;


      -- Insert Missing Classes
      INSERT INTO oe_config_details_tmp
      (
          LINE_ID ,
 	  TOP_MODEL_LINE_ID,
 	  ATO_LINE_ID,
 	  LINK_TO_LINE_ID,
 	  ORDER_SOURCE_ID,
 	  ORIG_SYS_DOCUMENT_REF,
 	  ORIG_SYS_LINE_REF ,
 	  --ORIG_SYS_SHIPMENT_REF ,
 	  TOP_MODEL_LINE_REF ,
 	  INVENTORY_ITEM_ID,
	  ORDERED_ITEM,
 	  UOM_CODE,
 	  ORDERED_QUANTITY,
 	  COMPONENT_CODE,
 	  COMPONENT_SEQUENCE_ID,
 	  SORT_ORDER ,
 	  --CONFIG_HEADER_ID,
 	  --CONFIG_REV_NBR ,
 	  --CONFIGURATION_ID,
 	  TOP_BILL_SEQUENCE_ID,
 	  ITEM_TYPE_CODE,
	  --LINE_TYPE,
 	  --CZ_QTY_MATCH_FLAG,
 	  HIGH_QUANTITY,
 	  LOW_QUANTITY,
 	  MUTUALLY_EXCLUSIVE_OPTIONS,
 	  BOM_ITEM_TYPE,
 	  LOCK_CONTROL,
 	  REPLENISH_TO_ORDER_FLAG
      )
      SELECT
          oe_order_lines_s.nextval Line_id,
          L.top_model_line_id top_model_line_id,
          L.ato_line_id ato_line_id,
          NULL link_to_line_id,
	  l.order_source_id,
          l.orig_sys_document_ref 	orig_sys_document_ref,
          'OE_ORDER_LINES_ALL'||oe_order_lines_s.currval orig_sys_line_ref,
          l.orig_sys_line_ref  		top_model_line_ref,
          b.component_item_id,
	  NULL 				ordered_item,
          b.primary_uom_code,
          b.EXTENDED_QUANTITY * l.ordered_quantity,
          b.Component_code,
          b.Component_sequence_id,
          b.Sort_order,
          l.top_bill_sequence_id,
	  'CLASS' 			item_type_code,
          b.high_quantity,
          b.low_quantity,
          b.mutually_exclusive_options,
          b.bom_item_type,
          null LOCK_CONTROL,
          b.replenish_to_order_flag
      FROM  BOM_EXPLOSIONS b,
	    oe_config_details_tmp L
      WHERE b.top_bill_sequence_id = L.top_bill_sequence_id
      AND   L.item_type_code = 'MODEL'
      AND   L.line_id = L.top_model_line_id
      AND   nvl(L.lock_control, 0) <> -99
      AND   b.explosion_type = OE_Config_Util.OE_BMX_OPTION_COMPS
      AND   b.plan_level > 0
      AND   nvl(b.effectivity_date, sysdate) <=  sysdate
      AND   nvl(b.disable_date, sysdate + 1) > sysdate
      AND   b.component_sequence_id <> b.top_bill_sequence_id  -- Exclude Model Lines
      AND   b.component_code NOT IN (
                 SELECT l2.component_code
                 FROM oe_config_details_tmp l2
                 WHERE l2.top_model_line_id = L.top_model_line_id )
      AND   EXISTS (
                 SELECT l3.line_id
                 FROM 	oe_config_details_tmp l3
                 WHERE
	         instr(l3.component_code, b.component_code, 1) = 1
                 AND    l3.top_model_line_id = L.top_model_line_id
                 AND    l3.item_type_code <> 'MODEL'
		 AND    l3.bom_item_type = 4);

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INSERTED '||SQL%ROWCOUNT||' MISSING CLASSES TO TMP' , 3 ) ;
      END IF;

  ELSE  -- Else If configurator is used Then

      -- We will need to first insert all records from l_line_rec and pull
      -- missing attributes (quantity, line_type, configuration_id ) from
      -- cz_config_details_v for the new instance that just got created in
      -- Batch Validation call.

      FORALL I in 1..l_line_rec.line_id.COUNT
      INSERT INTO oe_config_details_tmp
      (
   	  LINE_ID ,
 	  TOP_MODEL_LINE_ID,
 	  ATO_LINE_ID,
 	  LINK_TO_LINE_ID,
 	  ORDER_SOURCE_ID,
 	  ORIG_SYS_DOCUMENT_REF,
 	  ORIG_SYS_LINE_REF ,
 	  ORIG_SYS_SHIPMENT_REF ,
 	  TOP_MODEL_LINE_REF ,
 	  INVENTORY_ITEM_ID,
 	  UOM_CODE,
 	  ORDERED_QUANTITY,
 	  COMPONENT_CODE,
 	  COMPONENT_SEQUENCE_ID,
 	  SORT_ORDER ,
 	  CONFIG_HEADER_ID,
 	  CONFIG_REV_NBR ,
 	  CONFIGURATION_ID,
 	  --TOP_BILL_SEQUENCE_ID,
 	  ITEM_TYPE_CODE,
	  LINE_TYPE,
 	  --CZ_QTY_MATCH_FLAG,
 	  --HIGH_QUANTITY,
 	  --LOW_QUANTITY,
 	  --MUTUALLY_EXCLUSIVE_OPTIONS,
 	  --BOM_ITEM_TYPE,
 	  LOCK_CONTROL
 	  --REPLENISH_TO_ORDER_FLAG
      )
      SELECT
         l_line_rec.line_id(I),
         l_line_rec.top_model_line_id(I),
         NVL(l_line_rec.ato_line_id(I),
               decode(z.config_item_id, z.ato_config_item_id,
		      l_line_rec.line_id(I),NULL)) ato_line_id,
         NULL link_to_line_id,
	 l_line_rec.order_source_id(I),
         l_line_rec.orig_sys_document_ref(I),
         l_line_rec.orig_sys_line_ref(I),
         l_line_rec.orig_sys_shipment_ref(I),
         l_line_rec.Top_model_line_REF(I),
         z.inventory_item_id,
	 z.uom_code,
         z.quantity,
         l_line_rec.Component_code(I),
         l_line_rec.Component_sequence_id(I),
         z.bom_sort_order, -- l_line_rec.sort_order(I),
         z.config_hdr_id,
         z.config_rev_nbr,
         z.config_item_id,
	 l_line_rec.item_type_code(I),
         z.line_type,
         --high_quantity(I)
         --low_quantity(I)
         --mutually_exclusive_options(I)
         --bom_item_type(I)
	 l_line_rec.lock_control(I)
      FROM CZ_CONFIG_DETAILS_V z
      WHERE z.config_hdr_id = l_line_rec.config_header_id(I)
      AND z.config_rev_nbr = l_line_rec.config_rev_nbr(I)
      AND z.component_code = l_line_rec.component_code(I);

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INSERTED '||SQL%ROWCOUNT||' TO TMP FROM LINE_REC' , 3 ) ;
      END IF;


      -- Insert any new components that are present in CZ but
      -- missing in oe_config_details_tmp.
      INSERT INTO oe_config_details_tmp
      (
   	  LINE_ID ,
 	  TOP_MODEL_LINE_ID,
 	  ATO_LINE_ID,
 	  LINK_TO_LINE_ID,
 	  ORDER_SOURCE_ID,
 	  ORIG_SYS_DOCUMENT_REF,
 	  ORIG_SYS_LINE_REF ,
 	  -- ORIG_SYS_SHIPMENT_REF ,
 	  TOP_MODEL_LINE_REF ,
 	  INVENTORY_ITEM_ID,
 	  UOM_CODE,
 	  ORDERED_QUANTITY,
 	  COMPONENT_CODE,
 	  COMPONENT_SEQUENCE_ID,
 	  SORT_ORDER ,
 	  CONFIG_HEADER_ID,
 	  CONFIG_REV_NBR ,
 	  CONFIGURATION_ID,
 	  TOP_BILL_SEQUENCE_ID,
 	  ITEM_TYPE_CODE,
	  --LINE_TYPE,
 	  --CZ_QTY_MATCH_FLAG,
 	  --HIGH_QUANTITY,
 	  --LOW_QUANTITY,
 	  --MUTUALLY_EXCLUSIVE_OPTIONS,
 	  BOM_ITEM_TYPE,
 	  LOCK_CONTROL
 	  --REPLENISH_TO_ORDER_FLAG
      )
      SELECT
          oe_order_lines_s.nextval Line_id,
          L.top_model_line_id top_model_line_id,
          decode(z.config_item_id, z.ato_config_item_id,
		oe_order_lines_s.currval, NULL) ato_line_id ,
          NULL link_to_line_id,
          L.order_source_id  order_source_id,
          L.orig_sys_document_ref orig_sys_document_ref,
	  'OE_ORDER_LINES_ALL'||oe_order_lines_s.currval orig_sys_line_ref,
          L.orig_sys_line_ref top_model_line_ref,
          z.inventory_item_id,
	  z.uom_code,
	  z.quantity,
          z.Component_code,
          z.Component_sequence_id,
          z.bom_sort_order,
          z.config_hdr_id,
          z.config_rev_nbr,
          z.config_item_id,
          L.top_bill_sequence_id,
	  'CLASS',  -- In new configuration, only CLASS can be missing
          z.bom_item_type,
	  null LOCK_CONTROL
      FROM  CZ_CONFIG_DETAILS_V z,
            oe_config_details_tmp L
      WHERE L.item_type_code = 'MODEL'
      AND   L.line_id = L.top_model_line_id
      AND   nvl(L.lock_control, 0) <> -99
      AND   L.config_header_id = z.config_hdr_id
      AND   L.config_rev_nbr = z.config_rev_nbr
      AND   z.config_item_id NOT IN
                (Select configuration_id
                 FROM oe_config_details_tmp L2
                 WHERE L2.top_model_line_id = L.line_id);

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INSERTED '||SQL%ROWCOUNT||' TO TMP FROM CZ' , 3 ) ;
      END IF;

  END IF; -- Use Configutor


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'EXITING OE_BULK_CONFIG_UTIL.Pre_Process_Bom ', 1) ;
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('NO DATA FOUND in OE_BULK_CONFIG_UTIL.Pre_Process_Bom ' , 1);
    END IF;

  WHEN OTHERS THEN

    IF c_line_bom1%ISOPEN THEN
      CLOSE c_line_bom1;
    ELSIF c_line_bom2%ISOPEN THEN
      CLOSE c_line_bom2;
    END IF;

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Others Error, OE_BULK_CONFIG_UTIL.Pre_Process_Bom');
       oe_debug_pub.add(substr(sqlerrm,1,240));
    END IF;

    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME,
          'Pre_Process_Bom'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pre_Process_Bom;



---------------------------------------------------------------------
--
-- PROCEDURE Pre_Process
--
---------------------------------------------------------------------

PROCEDURE Pre_Process(
  p_batch_id                IN NUMBER
 ,p_validate_only	    IN VARCHAR2
 ,p_use_configurator	    IN VARCHAR2
 ,p_validate_configurations IN VARCHAR2
)
IS

  l_start_time                 NUMBER;
  l_end_time                   NUMBER;

  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'ENTERING OE_BULK_CONFIG_UTIL.Pre_Process ') ;
      oe_debug_pub.add( ' Use Configurator :'|| p_use_configurator );
  END IF;

  IF nvl(p_use_configurator, 'N') = 'Y' THEN

      Pre_Process_Configurator(
		p_batch_id			=> p_batch_id,
                p_validate_only                 => p_validate_only,
 		p_use_configurator		=> p_use_configurator,
 		p_validate_configurations 	=> p_validate_configurations );

      -- Update ato_line_id on the temp table so that we do not need to loop over the
      -- lines later in process_lines. This UPDATE assumes that link_to_line_id and
      -- ato_line_id are already populated on ATO Models or ATOs under PTO cases.
      -- This happens in preprocessing. It will not set ATO_LINE_ID on ATO items under
      -- PTO models. That will be taken care of in Process_Lines.
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add( 'BEFORE update TMP for Config ') ;
      END IF;

      update oe_config_details_tmp L
      set ato_line_id =
	     ( select ato_line_id
               from oe_config_details_tmp L1
               where L1.ato_line_id IS NOT NULL
               AND L1.top_model_line_id = L.top_model_line_id
               AND INSTR(L1.component_code,'-',1,2) = 0
               AND L1.component_code = decode( L1.item_type_code, 'MODEL',
			substr(L.component_code,1, instr(L.component_code,'-',1,1)-1),
			substr(L.component_code,1, instr(L.component_code,'-',1,2)-1))
	       AND ROWNUM = 1 )
      Where line_id <> top_model_line_id
      And ato_line_id is NULL;

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add( 'AFTER update TMP for Config ') ;
      END IF;

  ELSE

      Pre_Process_Bom(
		p_batch_id			=> p_batch_id,
                p_validate_only                 => p_validate_only,
 		p_use_configurator		=> p_use_configurator,
 		p_validate_configurations 	=> p_validate_configurations );



      -- Update ato_line_id on the temp table so that we do not need to loop over
      -- the lines later in process_lines. In this case ATO_LINE_ID will be preset
      -- on all child lines of an ATO_MODEL. We need to take care of the case of
      -- ATO under PTO.  We can assume that bom_item_type and replenish_to_order_flag
      -- are available for all of these lines
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add( 'BEFORE update TMP for Bom ') ;
      END IF;

      UPDATE oe_config_details_tmp  L
      SET    ato_line_id=
              ( SELECT L1.line_id
                FROM   oe_config_details_tmp  L1
                WHERE  L.top_model_line_id = L1.top_model_line_id
                AND  L1.top_model_line_id <> L1.line_id
                AND  L1.bom_item_type = 1
                AND  L1.replenish_to_order_flag = 'Y'
                AND  L1.component_code = SUBSTR( L.component_code, 1, LENGTH( L1.component_code ))
                AND  L1.component_code =
                            ( SELECT MIN( L2.component_code )
                               FROM oe_config_details_tmp  L2
                               WHERE  L2.top_model_line_id = L.top_model_line_id
                               AND L2.component_code = SUBSTR( L.component_code, 1,
                                                     LENGTH( L2.component_code ))
                               AND L2.bom_item_type = 1
                               AND L2.replenish_to_order_flag = 'Y')
                 AND ((SUBSTR(L.component_code, LENGTH(L1.component_code) + 1, 1) = '-' OR
                             SUBSTR(L.component_code, LENGTH(L1.component_code) + 1, 1) is NULL)))
      WHERE  L.top_model_line_id <> line_id
      AND NOT (item_type_code = 'OPTION' AND
                 ato_line_id  = line_id AND
                 ato_line_id is not null)
      AND L.ato_line_id IS NULL;

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add( 'AFTER update TMP for Bom ') ;
      END IF;

  END IF;

  -- Update link_to_line_id on all lines except top model.

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add( 'BEFORE update link_to_line_id ') ;
  END IF;

  update oe_config_details_tmp L
  SET link_to_line_id = (select line_id
                         from oe_config_details_tmp L2
                         where L2.component_code = substr(L.component_code,
					1,instr(L.component_code,'-',-1,1)-1)
			  and L2.top_model_line_id = L.top_model_line_id)
  where line_id <> top_model_line_id
  and link_to_line_id is NULL;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add( 'AFTER update link_to_line_id ') ;
  END IF;

  -- Need to do BOM Validations upfront on TEMP table

  If nvl(p_use_configurator, 'N') = 'N' AND
     nvl(p_validate_configurations, 'N') = 'Y' THEN

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add( 'Calling OE_BULK_VALIDATE.Validate_BOM ') ;
      END IF;

      SELECT hsecs INTO l_start_time from v$timer;

      OE_BULK_VALIDATE.Validate_BOM;

      SELECT hsecs INTO l_end_time from v$timer;
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Validate_BOM is (sec) '
          ||((l_end_time-l_start_time)/100));

  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'EXITING OE_BULK_CONFIG_UTIL.Pre_Process ') ;
  END IF;



EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('NO DATA FOUND in OE_BULK_CONFIG_UTIL.Pre_Process ' , 1);
    END IF;

  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Others Error, OE_BULK_CONFIG_UTIL.Pre_Process');
       oe_debug_pub.add(substr(sqlerrm,1,240));
    END IF;

    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME,
          'Pre_Process'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pre_Process;



PROCEDURE  Delete_Configurations
(  p_error_rec          IN 	OE_BULK_ORDER_PVT.INVALID_HDR_REC_TYPE
  ,x_return_status      OUT NOCOPY VARCHAR2
)
IS

  CURSOR c_configs( p_orig_sys_document_ref VARCHAR2, p_order_source_id NUMBER)
  IS
	select  config_header_id,
		config_rev_nbr,
		orig_sys_document_ref,
		order_source_id
	from OE_CONFIG_DETAILS_TMP
	where orig_sys_document_ref = p_orig_sys_document_ref
	and   order_source_id = p_order_source_id
	and  item_type_code = 'MODEL';

  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

  l_usage_exists   number;
  l_return_value   number := 1;
  l_error_message  varchar2(100);


BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'ENTERING OE_BULK_CONFIG_UTIL.Delete_Configurations ') ;
  END IF;

  -- initialize return status to success
  x_return_status := fnd_api.g_ret_sts_success;

  FOR I IN 1..P_ERROR_REC.header_id.COUNT LOOP

      FOR l_delete_rec IN c_configs(P_ERROR_REC.orig_sys_document_ref(I),
				    P_ERROR_REC.order_source_id(I)) LOOP

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add( 'DOC_REF: ' || l_delete_rec.orig_sys_document_ref ) ;
              oe_debug_pub.add( 'SOURCE: ' || l_delete_rec.order_source_id ) ;
              oe_debug_pub.add( 'CHI: ' || l_delete_rec.config_header_id ) ;
              oe_debug_pub.add( 'CRN: ' || l_delete_rec.config_rev_nbr ) ;
          END IF;

	  /*
          OE_Config_Pvt.Delete_Config
                ( p_config_hdr_id   =>  l_delete_rec.config_header_id
                 ,p_config_rev_nbr  =>  l_delete_rec.config_rev_nbr
                 ,x_return_status   =>  x_return_status);

          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSE
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add( 'CONFIG DELETED WITH SUCCESS' ) ;
          END IF;
	  */

  	  IF l_delete_rec.config_header_id is not null AND
     	     l_delete_rec.config_rev_nbr is not null THEN

     	      CZ_CF_API.Delete_Configuration
                 ( config_hdr_id   => l_delete_rec.config_header_id
                  ,config_rev_nbr  => l_delete_rec.config_rev_nbr
                  ,usage_exists    => l_usage_exists
                  ,error_message   => l_error_message
                  ,return_value    => l_return_value );

             IF l_return_value <> 1 THEN
                OE_BULK_Msg_Pub.Add_text(l_error_message);
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Error from CZ delete: ' ||l_error_message  ) ;
                END IF;
        	x_return_status := FND_API.G_RET_STS_ERROR;
    	     ELSE
        	x_return_status := FND_API.G_RET_STS_SUCCESS;
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add( 'CONFIG DELETED WITH SUCCESS' ) ;
                END IF;

    	     END IF;
  	  ELSE
    	     IF l_debug_level  > 0 THEN
                 oe_debug_pub.add('NOTE : NULL CONFIG_HEADER_ID/CONFIG_REV_NBR PASSED');
             END IF;
          END IF;

      END LOOP;
  END LOOP;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'EXITING OE_BULK_CONFIG_UTIL.Delete_Configurations ') ;
  END IF;


EXCEPTION

  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Others Error, OE_BULK_CONFIG_UTIL.Delete_Configurations');
       oe_debug_pub.add(substr(sqlerrm,1,240));
    END IF;

    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME,
          'Delete_Configurations'
      );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Configurations;



END OE_BULK_CONFIG_UTIL;

/
