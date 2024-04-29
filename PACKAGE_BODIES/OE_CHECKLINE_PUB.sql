--------------------------------------------------------
--  DDL for Package Body OE_CHECKLINE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CHECKLINE_PUB" AS
/*  $Header: OEXCHKLB.pls 120.0 2005/05/31 23:40:38 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'OE_CheckLine_PUB';
inv_num       VARCHAR2(40);

Procedure Is_Line_Frozen( p_application_id               IN NUMBER,
                          p_entity_short_name            in VARCHAR2,
                          p_validation_entity_short_name in VARCHAR2,
                          p_validation_tmplt_short_name in VARCHAR2,
                          p_record_set_tmplt_short_name in VARCHAR2,
                          p_scope in VARCHAR2,
p_result OUT NOCOPY NUMBER ) IS


l_header_id NUMBER ;
l_line_frozen PLS_INTEGER := 0;
l_line_entity Boolean := FALSE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   --Fix perfomance bug 2017397, this code is being remove by having a return.
   --The check is being handled in OEXOEADJ.pld.
   --It doesn't make sense to check all the lines repeatly for line level contraints fired.
   --it is very costly.
   p_result := 0;
   Return;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_CHECKLINE_PUB' ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'VALIDATION ENTITY NAME:'||P_VALIDATION_ENTITY_SHORT_NAME ) ;
   END IF;

   IF p_validation_entity_short_name = 'HEADER_ADJ' THEN
      l_header_id := oe_header_adj_security.g_record.header_id;
   ELSIF p_validation_entity_short_name = 'LINE_ADJ' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ENTITY_SHORT_NAME'||P_VALIDATION_ENTITY_SHORT_NAME ) ;
      END IF;
      l_header_id := oe_line_adj_security.g_record.header_id;
      l_line_entity := TRUE;
   Else
      p_result := 0;
      Return;
   END IF;

   IF l_header_id IS NULL OR
      l_header_id = FND_API.G_MISS_NUM
   THEN
      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  ' HEADER ID IS NULL' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING OE_CHECKLINE_PUB' ) ;
      END IF;
      p_result := 0;
      return;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'L_HEADER_ID:'||L_HEADER_ID ) ;
   END IF;


      If nvl(oe_line_adj_security.g_record.list_line_type_code,'x') = 'FREIGHT_CHARGE'
         or nvl(oe_header_adj_security.g_record.list_line_type_code,'x') = 'FREIGHT_CHARGE'
      Then
         p_result := 0;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  ' THE ORDER LEVEL ADJUSTMENT IS FREIGHT_CHARGE' ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'EXITING OE_CHECKLINE_PUB' ) ;
         END IF;
         Return;
      End If;


      If nvl(oe_line_security.g_record.item_type_code,'x') in ('INCLUDED','CONFIG') then
         p_result := 0;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  ' THE ITEM IS INCLUDED , NO ADJUSTMENT CHECK IS NEEDED' ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'EXITING OE_CHECKLINE_PUB' ) ;
         END IF;
         Return;
      End If;

   Begin
   Select 1
   Into   l_line_frozen
   From dual
   Where exists
   (Select 'x'
    From   OE_ORDER_LINES
    WHERE  HEADER_ID = l_header_id
	   AND calculate_price_flag IN ('P','N')
           AND cancelled_flag = 'N'
    );

   Exception
   WHEN NO_DATA_FOUND Then
     p_result := 0;
     Return;
   When Others Then
     p_result := 0;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  ' OTHER EXCEPTION OCCURED IN OE_CHECKLINE_PUB:'||SQLERRM ) ;
     END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING OE_CHECKLINE_PUB' ) ;
      END IF;
     Return;
   End;


      --For the freight change, we do not restrict order level freight because it
      --it not prorate across lines.


      IF l_line_frozen = 1 AND
                          (l_line_entity = FALSE
                           OR
                           (l_line_entity = TRUE
                            AND oe_line_adj_security.g_record.modifier_level_code = 'ORDER'
                            )
                           ) THEN

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'HAS AT LEAST ONE LINE WITH ''N'' OR ''P'' CALCULATE_PRICE_FLAG' ) ;
         END IF;
         p_result := 1;
      ELSE
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  ' NO FROZEN LINE , RETURNING 0' ) ;
         END IF;
         p_result := 0;
      END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LEAVING OE_CHECKLINE_PUB' ) ;
    END IF;
END Is_Line_Frozen;

END OE_CheckLine_Pub;

/
