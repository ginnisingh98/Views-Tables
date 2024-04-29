--------------------------------------------------------
--  DDL for Package Body OE_SPLIT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SPLIT_UTIL" AS
/* $Header: OEXUSPLB.pls 120.13.12010000.13 2011/12/20 06:59:58 rmoharan ship $ */
G_PKG_NAME      CONSTANT VARCHAR2(30):='OE_Split_Util';
G_min_model     NUMBER;
G_max_model     NUMBER;
g_over_shipment boolean := false;
g_remnant_only Boolean := FALSE;
g_qry_out_rec   OE_ORDER_PUB.Line_rec_Type := OE_ORDER_PUB.G_MISS_LINE_REC;
G_BINARY_LIMIT         CONSTANT  NUMBER := OE_GLOBALS.G_BINARY_LIMIT; -- 8706868
Procedure Create_Line_Set_For_Options(p_x_line_tbl IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type ) IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTER CREATE LINE SET FOR OPTIONS:' ) ;
END IF;
FOR I in 1..p_x_line_tbl.count LOOP
	IF p_x_line_tbl(I).line_set_id is null AND
	   p_x_line_tbl(I).operation = oe_globals.g_opr_update THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'BEFORE CREATING SET : ' ||P_X_LINE_TBL ( I ) .LINE_ID ) ;
           END IF;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'BEFORE CREATING SET : ' ||P_X_LINE_TBL ( I ) .ITEM_TYPE_CODE ) ;
           END IF;
           Oe_Set_Util.Create_Line_Set(p_x_line_rec => p_x_line_tbl(I));
	END IF;
	FOR J in 1..p_x_line_tbl.count LOOP
   		IF  p_x_line_tbl(J).split_from_line_id = p_x_line_tbl(I).line_id AND
		    p_x_line_tbl(J).operation = oe_globals.g_opr_create THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'ADDING INTO SET:' ) ;
                END IF;
				p_x_line_tbl(J).line_Set_id := p_x_line_tbl(I).line_set_id;
		END IF;
	END LOOP;
END LOOP;
EXCEPTION
     WHEN OTHERS THEN
          IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             OE_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , 'Create_Line_Set_For_Options' );
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Create_Line_Set_For_Options;


Procedure Update_Drop_Ship_Source(p_line_tbl IN OE_ORDER_PUB.Line_Tbl_Type) IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

FOR I in 1..p_line_tbl.count LOOP
    BEGIN
    IF (p_line_tbl(I).operation = oe_globals.g_opr_create AND
        p_line_tbl(I).split_from_line_id IS NOT NULL AND
        p_line_tbl(I).source_type_code = 'EXTERNAL' ) THEN
        UPDATE oe_drop_ship_sources
        SET    line_id = p_line_tbl(I).line_id
        WHERE  line_id = p_line_tbl(I).split_from_line_id;
    END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN
              Null;
              WHEN OTHERS THEN
              NULL;
    END;
END LOOP;
End Update_Drop_Ship_Source;

Procedure Get_Nonprop_Service_lines(p_line_tbl IN OE_ORDER_PUB.Line_Tbl_Type,
                                    x_line_tbl OUT NOCOPY /* file.sql.39 change */ OE_ORDER_PUB.Line_Tbl_Type)
IS
l_ser_line_tbl  OE_ORDER_PUB.Line_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_TBL;
l_ser_line_rec  OE_ORDER_PUB.Line_rec_Type := OE_ORDER_PUB.G_MISS_LINE_rec;
l_line_id       NUMBER;
l_service_count NUMBER := 0;
Cursor Sertbl IS
       SELECT ORDERED_QUANTITY
              , HEADER_ID
              , LINE_ID
       FROM   OE_ORDER_LINES_ALL
       WHERE  SERVICE_REFERENCE_LINE_ID = l_line_id
       AND    ITEM_TYPE_CODE = 'SERVICE'
       AND    SERVICE_REFERENCE_TYPE_CODE = 'ORDER'
       AND    OPEN_FLAG <> 'N'  -- Bug 7555831 and 7555832
       AND    NVL(CANCELLED_FLAG,'N') <> 'Y';
       --
       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
       --
BEGIN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Enter non prop service lines',5);
       OE_DEBUG_PUB.add('#5112495, select service reference type code ORDER only',1);
    END IF;
    x_line_tbl := p_line_tbl;
    FOR I in 1 .. p_line_tbl.count LOOP
	IF  p_line_tbl(I).operation = OE_GLOBALS.G_OPR_UPDATE THEN
	    l_line_id :=  p_line_tbl(I).line_id;
	ELSE
	    l_line_id :=  p_line_tbl(I).split_from_line_id;
	END IF;
        FOR Ser_rec IN Sertbl LOOP
	    l_service_count := l_service_count + 1;
    	    l_ser_line_tbl(l_service_count).line_id := ser_rec.line_id;
      	    oe_line_util.query_row(ser_rec.line_id,x_line_rec => l_ser_line_rec);
	    l_ser_line_tbl(l_service_count) := l_ser_line_rec;
     	    IF  p_line_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE THEN
		l_ser_line_tbl(l_service_count).line_id := fnd_api.g_miss_num;
		l_ser_line_tbl(l_service_count).split_from_line_id := l_ser_line_rec.line_id; --9111247
            END IF;
	    IF  p_line_tbl(I).operation = OE_GLOBALS.G_OPR_UPDATE THEN
		l_ser_line_tbl(l_service_count).split_action_code := 'SPLIT';
		/* Start Audit Trail */
		l_ser_line_tbl(l_service_count).change_reason := 'SYSTEM';
		/* End Audit Trail */
            END IF;
            l_ser_line_tbl(l_service_count).split_by                  := 'SYSTEM';
            l_ser_line_tbl(l_service_count).header_id                 := ser_rec.header_id;
	    l_ser_line_tbl(l_service_count).ordered_quantity          := p_line_tbl(I).ordered_quantity;
	    l_ser_line_tbl(l_service_count).operation                 := p_line_tbl(I).operation;
	    l_ser_line_tbl(l_service_count).service_reference_line_id := p_line_tbl(I).line_id;
	END LOOP;
    END LOOP;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('service lines',5) ;
    END IF;
    FOR I in 1..l_ser_line_tbl.count LOOP
	IF l_debug_level  > 0 THEN
	   oe_debug_pub.add(l_ser_line_tbl(I).item_type_code);
	   oe_debug_pub.add(l_ser_line_tbl(I).operation);
	   oe_debug_pub.add(l_ser_line_tbl(I).service_reference_line_id);
	END IF;
    END LOOP;
    -- Populate Out table
    l_service_count := p_line_tbl.count + 1;
    FOR I in 1..l_ser_line_tbl.count LOOP
     	x_line_tbl(l_service_count) := l_ser_line_tbl(I);
	l_service_count := l_service_count + 1;
    END LOOP;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Exit non service lines',5);
    END IF;
EXCEPTION
     WHEN OTHERS THEN
          IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             OE_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME ,'Get_Non_Service_line' );
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Nonprop_Service_Lines;

/* This is duplicated here since defaulting goes by g_line_rec%view and
has technical dificulties to get the currect shipment number */

FUNCTION Get_Shipment_Number(p_line_rec oe_order_pub.line_rec_type) RETURN NUMBER IS
l_ship_number  NUMBER := NULL;
l_config_rec   OE_ORDER_PUB.line_rec_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

--9534576
l_line_set_id NUMBER ;
l_max_ship_number number ;
l_chk_ship_number NUMBER ;
i                 NUMBER;
CURSOR Models(p_line_set_id NUMBER) IS
       SELECT line_id FROM oe_order_lines_all
       WHERE line_set_id=  p_line_set_id;
--9534576
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN PKG OE_DEFAULT_LINE: FUNCTION GET_SHIPMENT_NUMBER' ) ;
    END IF;
    IF p_line_rec.top_model_line_id IS NULL
    OR p_line_rec.top_model_line_id = FND_API.G_MISS_NUM THEN
       SELECT  NVL(MAX(SHIPMENT_NUMBER)+1,1)
       INTO    l_ship_number
       FROM    OE_ORDER_LINES
       WHERE   HEADER_ID = p_line_rec.header_id
       AND     LINE_NUMBER = p_line_rec.line_number;
       RETURN l_ship_number;

--START 9534576
    ELSIF p_line_rec.model_Remnant_flag='Y'
          AND p_line_rec.top_model_line_id IS NOT NULL
          AND p_line_rec.split_from_line_id IS NOT NULL THEN
    --first get the line set id of the top model line.
    --based on the line set id, get all the line ids. that means get all the model lines,
    -- that are part of the split.
    --now for the option, component, service combination, get the max shipment number.


          SELECT line_set_id
          INTO l_line_set_id
          FROM oe_order_lines
          WHERE line_id=p_line_rec.top_model_line_id;
   if l_line_set_id is null then

	  SELECT  NVL(MAX(SHIPMENT_NUMBER)+1,1)
          INTO    l_ship_number
          FROM    OE_ORDER_LINES
          WHERE   HEADER_ID = p_line_rec.header_id
          AND     LINE_NUMBER = p_line_rec.line_number
	  AND Nvl(option_number,-1)=Nvl(p_line_rec.option_number,-1)
          AND Nvl(component_number,-1)=Nvl(p_line_rec.component_number,-1)
          AND Nvl(service_number,-1)=Nvl(p_line_rec.service_number,-1);

          RETURN l_ship_number;

   else

      FOR i IN models(l_line_set_id) LOOP
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'for the mode line:'|| i.line_id) ;
           END IF;

           SELECT  NVL(MAX(SHIPMENT_NUMBER),-1)
                 INTO l_chk_ship_number
                 FROM oe_order_lines
                 WHERE top_model_line_id=i.line_id
                 AND line_number=p_line_rec.line_number
                 AND Nvl(option_number,-1)=Nvl(p_line_rec.option_number,-1)
                 AND Nvl(component_number,-1)=Nvl(p_line_rec.component_number,-1)
                 AND Nvl(service_number,-1)=Nvl(p_line_rec.service_number,-1);


                 IF Nvl(l_chk_ship_number,-1) > Nvl(l_max_ship_number,-1) THEN

                   IF l_debug_level  > 0 THEN
	             oe_debug_pub.add(  'checking the value of max shipment number'||i.line_id);
        		 oe_debug_pub.add(l_max_ship_number);
       			 oe_debug_pub.add(l_CHK_ship_number);
          	   END IF;
                        l_max_ship_number:= l_chk_ship_number;
                  END IF;
       END LOOP;
         l_ship_number:= l_max_ship_number+1;
         RETURN   l_ship_number;
         oe_debug_pub.add('returned value is:'||l_ship_number);
    end if ;
--9534576

    ELSE
       -- 2605065: We will not use Cache info. Select direct from table.
       SELECT shipment_number
       INTO   l_ship_number
       FROM   oe_order_lines
       WHERE  line_id = p_line_rec.top_model_line_id;
       IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SHIPMENT_NUMBER '||l_ship_number,1 ) ;
       END IF;
       /*
       l_config_rec  := OE_Order_Cache.Load_Top_Model_Line(p_line_rec.top_model_line_id );
       l_ship_number := l_config_rec.shipment_number;
       */
       RETURN l_ship_number;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
         IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            OE_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME ,'Get_Shipment_Number' );
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Shipment_Number;

FUNCTION Check_Complete_Shipment(p_line_tbl IN OE_ORDER_PUB.line_tbl_type,
        						 p_line_id IN number) RETURN VARCHAR2 IS
l_line_id   number;
CURSOR OPTIONTBL IS
       SELECT ORDERED_QUANTITY
              , HEADER_ID
              , LINE_ID
       FROM   OE_ORDER_LINES_ALL
       WHERE  TOP_MODEL_LINE_ID = l_line_id
       AND    LINE_ID <> l_line_id
       AND    NVL(SHIPPABLE_FLAG,'N')='Y';
l_line_tbl OE_ORDER_PUB.line_tbl_type := p_line_tbl;
l_exist    varchar2(1) := 'N';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
	l_line_id := p_line_id;
    FOR optionrec in optiontbl LOOP
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'INTO OPTION TABLE-' ) ;
		END IF;
        l_exist := 'N';
        FOR I in 1 .. l_line_tbl.count LOOP
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'LINE_ID-' ||OPTIONREC.LINE_ID ) ;
			END IF;
            IF optionrec.line_id = l_line_tbl(I).line_id THEN
     		   IF l_debug_level  > 0 THEN
     		       oe_debug_pub.add(  'EQUAL OPTION TABLE-' ) ;
     		   END IF;
               l_exist := 'Y';
               EXIT;
            END IF;
        END LOOP;
        IF l_exist = 'N' THEN
           RETURN l_exist;
        END IF;
    END LOOP;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RESULT-'||L_EXIST ) ;
	END IF;
    RETURN l_exist;
EXCEPTION WHEN OTHERS THEN
          IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,'Check_Complete_Shipment');
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Check_Complete_Shipment;

Procedure Get_Service_lines(p_line_tbl IN OE_ORDER_PUB.Line_Tbl_Type,
         					x_line_tbl OUT NOCOPY /* file.sql.39 change */ OE_ORDER_PUB.Line_Tbl_Type,
					        g_split_line_tbl oe_split_util.split_line_tbl) IS
l_ser_line_tbl  OE_ORDER_PUB.Line_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_TBL;
l_line_id       NUMBER;
l_service_count NUMBER := 1;
l_ser_rec       OE_ORDER_PUB.Line_rec_Type := OE_ORDER_PUB.G_MISS_LINE_REC;
l_query_out_rec OE_ORDER_PUB.Line_rec_Type := OE_ORDER_PUB.G_MISS_LINE_REC;

CURSOR Sertbl IS
       SELECT ORDERED_QUANTITY
              , HEADER_ID
              , LINE_ID
       FROM   OE_ORDER_LINES_ALL
       WHERE  SERVICE_REFERENCE_LINE_ID = l_line_id
       AND    ITEM_TYPE_CODE = 'SERVICE'
       AND    SERVICE_REFERENCE_TYPE_CODE = 'ORDER'
       AND    OPEN_FLAG <> 'N' -- Bug 6710212
       AND    NVL(CANCELLED_FLAG,'N') <> 'Y';
       --
       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
       --
BEGIN
IF l_debug_level  > 0 THEN
   oe_debug_pub.add('Enter get_service_lines()',5);
END IF;
x_line_tbl := p_line_tbl;
l_line_id := g_split_line_tbl(1).line_id;
FOR Ser_rec IN Sertbl LOOP
    oe_line_util.query_row(ser_rec.line_id,x_line_rec => l_ser_rec);
    -- for bug 2035100
    IF p_line_tbl(1).split_by IS NOT NULL THEN
       l_ser_rec.split_by := p_line_tbl(1).split_by;
    END IF;
    -- end 2035100
    l_ser_line_tbl(l_service_count) := l_ser_rec;
    /* Start Audit Trail */
    l_ser_line_tbl(l_service_count).change_reason := 'SYSTEM';
    l_ser_line_tbl(l_service_count).change_comments := 'Split line';
    /* End Audit Trail */
    l_ser_line_tbl(l_service_count).line_id := ser_rec.line_id;
    l_ser_line_tbl(l_service_count).header_id := ser_rec.header_id;
    l_ser_line_tbl(l_service_count).ordered_quantity := g_split_line_tbl(1).quantity;
    l_ser_line_tbl(l_service_count).operation := oe_globals.g_opr_update;
    l_ser_line_tbl(l_service_count).split_action_code := 'SPLIT';
    l_service_count := l_service_count + 1;
    FOR I in 2..g_split_line_tbl.count LOOP
        l_ser_line_tbl(l_service_count) := l_ser_rec;
        l_ser_line_tbl(l_service_count).line_id := fnd_api.g_miss_num;
        l_ser_line_tbl(l_service_count).split_from_line_id := l_ser_rec.line_id;
        l_ser_line_tbl(l_service_count).operation := oe_globals.g_opr_create;
        g_qry_out_rec := l_ser_line_tbl(l_service_count) ;
	OE_Split_Util.Default_Attributes(
         	     p_x_line_rec               =>g_qry_out_rec
           	 ,   p_old_line_rec          => l_ser_line_tbl(l_service_count)
        );
	l_ser_line_tbl(l_service_count) := g_qry_out_rec;
	l_ser_line_tbl(l_service_count).header_id := ser_rec.header_id;
	l_ser_line_tbl(l_service_count).service_reference_line_id := g_split_line_tbl(I).line_id;
	l_ser_line_tbl(l_service_count).ordered_quantity :=	g_split_line_tbl(I).quantity;
	l_ser_line_tbl(l_service_count).operation := oe_globals.g_opr_create;
	l_ser_line_tbl(l_service_count).item_type_code:='SERVICE';
	l_service_count := l_service_count + 1;
    END LOOP;
END LOOP;

-- Populate Out table
l_service_count := p_line_tbl.count + 1;
FOR I in 1..l_ser_line_tbl.count LOOP
    x_line_tbl(l_service_count) := l_ser_line_tbl(I);
    l_service_count := l_service_count + 1;
END LOOP;

FOR I in 1..x_line_tbl.count LOOP
    --While i is not null loop
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Quantity '||x_line_tbl(i).ordered_quantity,5);
       oe_debug_pub.add('Operation '||x_line_tbl(i).operation,5);
       oe_debug_pub.add('Item Type '||x_line_tbl(i).item_type_code,5) ;
       oe_debug_pub.add('Line ID '||x_line_tbl(i).line_id,5);
       oe_debug_pub.add('Split from line ID '||x_line_tbl(i).split_from_line_id,5);
       oe_debug_pub.add('Line set '||x_line_tbl(i).line_set_id,5);
       oe_debug_pub.add(x_line_tbl(i).split_action_code,5);
    END IF;
    --i:= l_line_tbl.next(i);
END LOOP;
IF l_debug_level  > 0 THEN
   oe_debug_pub.add('Exit service lines()',5 ) ;
END IF;
EXCEPTION
     WHEN OTHERS THEN
          IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,'Get_Service_line');
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Service_lines;

Procedure Get_non_Model_Configuration(p_line_tbl IN OE_ORDER_PUB.line_tbl_type,
                                      x_line_tbl OUT NOCOPY /* file.sql.39 change */ OE_ORDER_PUB.line_tbl_type) IS
l_line_id               NUMBER;
l_line_tbl              OE_ORDER_PUB.line_tbl_type := p_line_tbl;
l_reminant_tbl          OE_ORDER_PUB.line_tbl_type;
l_shippable_tbl         OE_ORDER_PUB.line_tbl_type;
l_shipped_tbl           OE_ORDER_PUB.line_tbl_type;
l_temp_tbl              OE_ORDER_PUB.line_tbl_type;
l_ratio                 NUMBER;
l_model_ratio           NUMBER;
l_line_rec              OE_ORDER_PUB.line_rec_type;
l_model_rec             OE_ORDER_PUB.line_rec_type;
l_option_line           OE_ORDER_PUB.line_rec_type;
l_parent_line           OE_ORDER_PUB.line_rec_type;
l_option_line_tbl       OE_ORDER_PUB.line_tbl_type;
l_tbl_count             NUMBER := 0;
l_option_count          NUMBER := 0;
l_original_qty          NUMBER := 0;
l_min_model             NUMBER := 0;
l_temp_min_model        NUMBER := 0;
l_insert_quantity       NUMBER := 0;
l_update_quantity       NUMBER := 0;
option_updated          BOOLEAN := FALSE;
l_exist                 BOOLEAN := FALSE;
l_parent_quantity       NUMBER := 0;
l_Set_id                NUMBER;
l_option_not_updated    BOOLEAN := TRUE;
l_update_line_reqd      BOOLEAN := TRUE;
l_Rem_top_model_line_id NUMBER;
l_actual_shipment_date  Date;
CURSOR OPTIONTBL IS
       SELECT ORDERED_QUANTITY,
              HEADER_ID,
              LINE_ID
       FROM   OE_ORDER_LINES_ALL
       WHERE  TOP_MODEL_LINE_ID = l_line_id
       AND    LINE_ID <> l_line_id
       AND    NVL(CANCELLED_FLAG,'N')<> 'Y'
       ORDER  BY LINE_ID;
       --
       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
       --
BEGIN
IF l_debug_level  > 0 THEN
   oe_debug_pub.add('Entering splitting non-model configuration with following picture ',5);
END IF;
FOR I in 1..p_line_tbl.count LOOP
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('line id            : '||p_line_tbl(i).line_id , 1 ) ;
       oe_debug_pub.add('ordered quantity   : '||p_line_tbl(i).ordered_quantity , 1 ) ;
       oe_debug_pub.add('item type code     : '||p_line_tbl(i).item_type_code , 1 ) ;
       oe_debug_pub.add('operation          : '||p_line_tbl(i).operation , 1 ) ;
       oe_debug_pub.add('shipped quantity   : '||p_line_tbl(i).shipped_quantity , 1 ) ;
       oe_debug_pub.add('model remnant flag : '||p_line_tbl(i).model_remnant_flag , 1 ) ;
       oe_debug_pub.add('top model line id  : '||p_line_tbl(i).top_model_line_id , 1 ) ;
       oe_debug_pub.add('actual shipment on : '||p_line_tbl(i).actual_shipment_date,1);
    END IF;
END LOOP;
x_line_tbl := p_line_tbl;
l_line_id := p_line_tbl(1).top_model_line_id;
oe_line_util.query_row(p_line_id => l_line_id,x_line_rec => l_line_rec);
l_parent_quantity := l_line_rec.ordered_quantity - p_line_tbl(1).ordered_quantity;
l_parent_line := l_line_rec;
-- Get Complete shipped Model if any
-- Form Complete Shipped Model if g_max_model > 0
IF l_debug_level  > 0 THEN
   oe_debug_pub.add('*********  Completing shipped model *************** ',5);
END IF;
IF g_max_model > 0 THEN
   l_parent_line := l_line_rec;
   l_parent_line.ordered_quantity := g_max_model;
   l_parent_line.shipped_quantity := g_max_model;
   l_parent_line.operation := oe_globals.g_opr_update;
   l_parent_line.split_action_code := 'SPLIT';
   l_parent_line.split_by := 'SYSTEM';
   --l_option_count := l_option_count + 1;
   IF l_parent_line.line_set_id IS  NULL THEN
      Oe_Set_Util.Create_Line_Set(p_x_line_rec => l_parent_line);
   END IF;
   l_set_id := l_parent_line.line_set_id;
   l_option_count := l_option_count + 1;
   l_option_line_tbl(l_option_count) := l_parent_line;
   FOR optionrec in optiontbl LOOP
       oe_line_util.query_row(p_line_id => optionrec.line_id, x_line_rec => l_option_line);
       l_model_ratio := l_option_line.ordered_quantity/l_line_rec.ordered_quantity;
       option_updated := FALSE;
       FOR I in 1..P_line_tbl.count LOOP
           IF p_line_tbl(I).line_id = optionrec.line_id THEN
              IF l_debug_level  > 0 THEN
         	 oe_debug_pub.add(  X_LINE_TBL ( I ) .ORDERED_QUANTITY ) ;
              END IF;
              x_line_tbl(I).ordered_quantity := g_max_model * l_model_ratio;
              x_line_tbl(I).operation := oe_globals.g_opr_update;
              x_line_tbl(I).shipped_quantity := x_line_tbl(I).ordered_quantity;
	      option_updated := TRUE;
	      IF l_debug_level  > 0 THEN
		 oe_debug_pub.add(  'ORD QTY' ||X_LINE_TBL ( I ) .ORDERED_QUANTITY ) ;
	      END IF;
	      EXIT;
	   END IF;
        END LOOP;
	IF not option_updated THEN
           l_option_count := l_option_count + 1;
           l_option_line_tbl(l_option_count) := l_option_line;
           l_option_line_tbl(l_option_count).ordered_quantity := g_max_model * l_model_ratio;
           /* Start Audit Trail */
           l_option_line_tbl(l_option_count).change_reason := 'SYSTEM';
           /* End Audit Trail */
           l_option_line_tbl(l_option_count).operation := oe_globals.g_opr_update;
           l_option_line_tbl(l_option_count).split_action_code := 'SPLIT';
           l_option_line_tbl(l_option_count).split_by := 'SYSTEM' ;
           l_option_line_tbl(l_option_count).shipped_quantity := l_option_line_tbl(l_option_count).ordered_quantity;
	END IF; -- Option not updated
	option_updated := false;
   END LOOP;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('After maximum shipped model',5 ) ;
   END IF;
   FOR I in 1..l_option_line_tbl.count LOOP
       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Option table ordered Quantity : '||  l_option_line_tbl ( i ) .ordered_quantity , 1 ) ;
          oe_debug_pub.add('Item Type Code : '||  l_option_line_tbl ( i ) .item_type_code , 1 ) ;
          oe_debug_pub.add('Operation : '||  l_option_line_tbl ( i ) .operation , 1 ) ;
       END IF;
   END LOOP;
END IF; -- g_max_model
-- End Complete Shipped Model
-- Get Complete shippable Model if any
IF l_debug_level > 0 THEN
   oe_debug_pub.add('Completing unshipped model ',1);
END IF;
IF g_min_Model > 0 THEN
   l_parent_line := l_line_rec;
   l_parent_line.ordered_quantity := g_min_model;
   l_parent_line.operation := oe_globals.g_opr_create;
   l_parent_line.split_by := 'SYSTEM';
   l_parent_line.split_from_line_id := l_parent_line.line_id;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Line set id is : '||l_set_id,5) ;
   END IF;
   l_parent_line.line_id := fnd_api.g_miss_num;
   l_parent_line.orig_sys_line_ref :=fnd_api.g_miss_char;  -- Bug5207907
   OE_Split_Util.Default_Attributes
         (p_x_line_rec => l_parent_line,
          p_old_line_rec => l_parent_line );
   IF l_parent_line.line_set_id is null AND l_set_id   IS NULL THEN
      Oe_Set_Util.Create_Line_Set(p_x_line_rec => l_parent_line);
      l_set_id := l_parent_line.line_set_id;
   ELSIF l_set_id is not null then
      l_parent_line.line_set_id := l_set_id;
   END IF;
   l_option_count := l_option_count + 1;
   l_option_line_tbl(l_option_count) := l_parent_line;
   FOR optionrec in optiontbl LOOP
       oe_line_util.query_row(p_line_id => optionrec.line_id, x_line_rec => l_option_line);
       l_model_ratio := l_option_line.ordered_quantity /l_line_rec.ordered_quantity;
       l_option_count := l_option_count + 1;
       l_option_line_tbl(l_option_count) := l_option_line;
       l_option_line_tbl(l_option_count).split_from_line_id := optionrec.line_id;
       l_option_line_tbl(l_option_count).split_by:='SYSTEM';
       l_option_line_tbl(l_option_count).line_id := fnd_api.g_miss_num;
       l_option_line_tbl(l_option_count).operation := oe_globals.g_opr_create;
       l_option_line_tbl(l_option_count).orig_sys_line_ref := fnd_api.g_miss_char;  --Bug5207907
       g_qry_out_rec := l_option_line_tbl(l_option_count) ;
       OE_Split_Util.Default_Attributes
       ( p_x_line_rec   => g_qry_out_rec
        ,p_old_line_rec => l_option_line_tbl(l_option_count)
       );
       l_option_line_tbl(l_option_count) := g_qry_out_rec;
       l_option_line_tbl(l_option_count).top_model_line_id := l_parent_line.line_id;
       IF l_option_line_tbl(l_option_count).ato_line_id IS NOT NULL THEN
          l_option_line_tbl(l_option_count).ato_line_id := l_parent_line.line_id;
       END IF;
       l_option_line_tbl(l_option_count).ordered_quantity := g_min_model * l_model_ratio ;
   END LOOP;
END IF;
IF l_debug_level  > 0 THEN
   oe_debug_pub.add('after get shippable model',5);
END IF;
FOR I in 1..l_option_line_tbl.count LOOP
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Option table ordered Quantity : '||  l_option_line_tbl ( i ) .ordered_quantity , 1 ) ;
       oe_debug_pub.add('Item Type : '||l_option_line_tbl ( i ) .item_type_code , 1 ) ;
       oe_debug_pub.add('Operation : '||l_option_line_tbl ( i ) .operation , 1 ) ;
       oe_debug_pub.add('Line Set ID : '||l_option_line_tbl ( i ) .line_set_id , 1 ) ;
    END IF;
END LOOP;
-- Get Remnant shipped

l_parent_line := l_line_rec;
IF l_debug_level  > 0 THEN
   oe_debug_pub.add('Process completely shipped remnant lines',1);
   oe_debug_pub.add('Parent quantity 1 : ' || L_PARENT_LINE.ORDERED_QUANTITY ) ;
END IF;
l_parent_line.ordered_quantity := l_line_rec.ordered_quantity - g_max_model - g_min_model ;
IF l_debug_level  > 0 THEN
   oe_debug_pub.add('Parent quantity 2 : ' || L_PARENT_LINE.ORDERED_QUANTITY ) ;
END IF;
IF l_parent_line.ordered_quantity > 0 THEN
   IF g_max_model = 0 THEN
      IF l_parent_line.line_set_id is null AND l_set_id IS NULL THEN
           Oe_Set_Util.Create_Line_Set(p_x_line_rec => l_parent_line);
           l_set_id := l_parent_line.line_set_id;
      ELSIF l_set_id is not null then
              l_parent_line.line_set_id := l_set_id;
      END IF;
      l_rem_top_model_line_id :=  l_parent_line.line_id;
      l_parent_line.operation := oe_globals.g_opr_update;
      l_parent_line.split_action_code := 'SPLIT';
      l_parent_line.split_by := 'SYSTEM';
   ELSE -- g_max_model
        l_parent_line.operation := oe_globals.g_opr_create;
        l_parent_line.split_by := 'SYSTEM';
        l_parent_line.split_from_line_id := l_parent_line.line_id;
        l_parent_line.line_id := fnd_api.g_miss_num;
        l_parent_line.config_header_id := NULL;
        l_parent_line.config_rev_nbr := NULL;
        l_parent_line.orig_sys_line_ref := fnd_api.g_miss_char; --Bug5207907
        OE_Split_Util.Default_Attributes
        (p_x_line_rec                    => l_parent_line
         ,p_old_line_rec                => l_parent_line
         );
	l_rem_top_model_line_id :=  l_parent_line.line_id;
        IF l_parent_line.line_set_id is null AND l_set_id   IS NULL THEN
           Oe_Set_Util.Create_Line_Set(p_x_line_rec => l_parent_line);
           l_set_id := l_parent_line.line_set_id;
        ELSIF l_set_id is not null then
              l_parent_line.line_set_id := l_set_id;
        END IF;
        l_parent_line.ordered_quantity :=l_line_rec.ordered_quantity - g_max_model- g_min_model ;
        --l_parent_line.shipped_quantity :=	--l_parent_line.ordered_quantity;
     END IF; -- Gmaxmodel
	 l_parent_line.model_remnant_flag := 'Y';
     --IF l_parent_line.ordered_quantity > 0 THEN
     l_option_count := l_option_count + 1;
     l_option_line_tbl(l_option_count) := l_parent_line;
END IF;
FOR optionrec in optiontbl LOOP
      oe_line_util.query_row(p_line_id => optionrec.line_id,x_line_rec => l_option_line);
      l_model_ratio := l_option_line.ordered_quantity /l_line_rec.ordered_quantity;
      FOR I in 1..P_line_tbl.count LOOP
          l_actual_shipment_date := p_line_tbl(i).actual_shipment_date;
          IF p_line_tbl(I).line_id = optionrec.line_id THEN
	     IF g_max_model = 0 THEN
		IF x_line_tbl(I).ordered_quantity < 0 THEN
		   x_line_tbl(I).ordered_quantity := optionrec.ordered_quantity;
		ELSE
                   x_line_tbl(I).ordered_quantity := p_line_tbl(I).shipped_quantity - g_max_model * l_model_ratio;
		   x_line_tbl(I).shipped_quantity := x_line_tbl(I).ordered_quantity;
		END IF;
	        x_line_tbl(I).model_remnant_flag := 'Y';
	     ELSE -- G_Max_Model
                l_option_line.ordered_quantity :=
	        p_line_tbl(I).shipped_quantity - g_max_model * l_model_ratio;
	        IF l_option_line.ordered_quantity > 0 THEN
                   l_option_count := l_option_count + 1;
                   l_option_line_tbl(l_option_count) := l_option_line;
                   l_option_line_tbl(l_option_count).line_id := fnd_api.g_miss_num;
                   l_option_line_tbl(l_option_count).split_from_line_id := optionrec.line_id;
                   l_option_line_tbl(l_option_count).operation := oe_globals.g_opr_create;
                   l_option_line_tbl(l_option_count).split_by := 'SYSTEM';
		   l_option_line_tbl(l_option_count).orig_sys_line_ref := fnd_api.g_miss_char; --Bug5207907
	           g_qry_out_rec := l_option_line_tbl(l_option_count) ;
                   OE_Split_Util.Default_Attributes
                   ( p_x_line_rec => g_qry_out_rec
                    ,p_old_line_rec => l_option_line_tbl(l_option_count)
                    );
	           l_option_line_tbl(l_option_count) := g_qry_out_rec;
                   l_option_line_tbl(l_option_count).ordered_quantity:=p_line_tbl(I).shipped_quantity - g_max_model * l_model_ratio;
                   l_option_line_tbl(l_option_count).shipped_quantity :=
	           l_option_line_tbl(l_option_count).ordered_quantity;
                   l_option_line_tbl(l_option_count).actual_shipment_date := l_actual_shipment_date;
		   IF l_debug_level  > 0 THEN
		      oe_debug_pub.add('Model Ratio : ' ||l_model_ratio,1);
		      oe_debug_pub.add('Index : ' ||I , 1 ) ;
	              oe_debug_pub.add('Ordered Quantity on remnant : '||x_line_tbl ( i ) .ordered_quantity , 1 ) ;
                      oe_debug_pub.add('actual shipment date : '||l_option_line_tbl(l_option_count).actual_shipment_date,5);
                      oe_debug_pub.add('shipped quantity on remnant : '||l_option_line_tbl( l_option_count ) .ordered_quantity,5);
		   END IF;
	           IF l_rem_top_model_line_id is not null then
                      l_option_line_tbl(l_option_count).top_model_line_id := l_rem_top_model_line_id;
	           ELSE
                      l_option_line_tbl(l_option_count).top_model_line_id := l_parent_line.line_id;
	           END IF;
                   l_option_line_tbl(l_option_count).line_set_id := l_set_id;
                   l_option_line_tbl(l_option_count).model_remnant_flag := 'Y';
                   IF l_option_line_tbl(l_option_count).ato_line_id IS NOT NULL THEN
                      l_option_line_tbl(l_option_count).ato_line_id := l_parent_line.line_id;
	           END IF;
               END IF; -- Ordere qty > 0
            END IF; -- Gmaxmodel
	    EXIT;
         END IF;
     END LOOP;
END LOOP;
-- Get Remanant Unshipped
/*l_parent_line := l_line_rec;
l_parent_line.ordered_quantity :=
l_line_rec.ordered_quantity - p_line_tbl(1).shipped_quantity - g_min_model;
IF l_debug_level > 0 THEN
   oe_debug_pub.add('Parent line ordered quantity ' || l_parent_line.ordered_quantity);
   oe_debug_pub.add('This line ordered quantity ' || l_line_rec.ordered_quantity);
   oe_debug_pub.add('Ordered quantity on the table ' || x_line_tbl(1).ordered_quantity);
END IF;
IF l_parent_line.ordered_quantity <> 0 THEN
   l_parent_line.operation := oe_globals.g_opr_create;
   l_parent_line.split_by := 'SYSTEM';
   l_parent_line.split_from_line_id := l_parent_line.line_id;
   l_parent_line.line_id := fnd_api.g_miss_num;
   l_parent_line.orig_sys_line_ref := fnd_api.g_miss_char; --Bug5207907
   OE_Split_Util.Default_Attributes
       (   p_x_line_rec                    => l_parent_line
       ,   p_old_line_rec                => l_parent_line
       );
   l_parent_line.line_set_id := l_set_id;
   l_rem_top_model_line_id := l_parent_line.line_id;
   l_option_count := l_option_count + 1;
   l_option_line_tbl(l_option_count) := l_parent_line;
   l_option_line_tbl(l_option_count).model_remnant_flag := 'Y';
END IF;*/
FOR optionrec in optiontbl LOOP
    oe_line_util.query_row(p_line_id => optionrec.line_id, x_line_rec => l_option_line);
    l_model_ratio := l_option_line.ordered_quantity / l_line_rec.ordered_quantity;
    option_updated := FALSE;
    l_insert_quantity := 0;
    FOR I in 1..P_line_tbl.count LOOP
        IF p_line_tbl(I).line_id = optionrec.line_id THEN
	   l_insert_quantity := p_line_tbl(I).shipped_quantity;
	   option_updated := true;
     	EXIT;
     	END IF;
    END LOOP;
    IF  l_insert_quantity = 0 AND g_max_model > 0  THEN
	l_insert_quantity := g_max_model *l_model_ratio;
    END IF;
    l_update_quantity := l_option_line.ordered_quantity - g_min_model * l_model_ratio - l_insert_quantity ;
    IF l_debug_level  > 0 THEN
    	   oe_debug_pub.add('Update Quantity : '||l_update_quantity,5) ;
	   oe_debug_pub.add('Option line Ordered Quantity : '||l_option_line.ordered_quantity,5);
    	   oe_debug_pub.add('Ratio : ' || g_min_model * l_model_ratio,5);
	   oe_debug_pub.add('Insert Quantity : ' || l_insert_quantity,5);
    END IF;
    IF l_update_quantity > 0 THEN
	   l_option_count := l_option_count + 1;
	   IF NOT option_updated  AND g_max_model = 0 THEN
	      l_option_line_tbl(l_option_count) := l_option_line;
       	      l_option_line_tbl(l_option_count).operation := oe_globals.g_opr_update;
       	      l_option_line_tbl(l_option_count).split_action_code := 'SPLIT';
       	      l_option_line_tbl(l_option_count).split_by := 'SYSTEM';
       	      l_option_line_tbl(l_option_count).ship_set_id := null;
       	      l_option_line_tbl(l_option_count).arrival_Set_id := null;
	   ELSE
       	      l_option_line_tbl(l_option_count).split_by := 'SYSTEM';
	      l_option_line_tbl(l_option_count) := l_option_line;
              l_option_line_tbl(l_option_count).split_from_line_id := optionrec.line_id;
              l_option_line_tbl(l_option_count).line_id := fnd_api.g_miss_num;
              l_option_line_tbl(l_option_count).operation := oe_globals.g_opr_create;
	      l_option_line_tbl(l_option_count).orig_sys_line_ref := fnd_api.g_miss_char; --Bug5207907
	      g_qry_out_rec := l_option_line_tbl(l_option_count) ;
              OE_Split_Util.Default_Attributes
              ( p_x_line_rec                   => g_qry_out_rec
               ,p_old_line_rec             => l_option_line_tbl(l_option_count)
               );
	      l_option_line_tbl(l_option_count) := g_qry_out_rec;
	      IF l_rem_top_model_line_id IS NOT NULL THEN
                 l_option_line_tbl(l_option_count).top_model_line_id := l_rem_top_model_line_id;
	      ELSE
                 l_option_line_tbl(l_option_count).top_model_line_id := l_parent_line.line_id;
	      END IF;
              /*  Commenting for bug 4941632
              IF  l_option_line_tbl(l_option_count).ato_line_id IS NOT NULL THEN
	          IF  l_rem_top_model_line_id is not null then
                     l_option_line_tbl(l_option_count).ato_line_id := l_rem_top_model_line_id;
	          ELSE
                     l_option_line_tbl(l_option_count).ato_line_id := l_parent_line.line_id;
	          END IF;
              END IF; */
	   END IF; -- Option updated or g max model
           l_option_line_tbl(l_option_count).model_remnant_flag := 'Y';
           l_option_line_tbl(l_option_count).ordered_quantity := l_update_quantity;
     END IF; -- Update Quantity
     option_updated := false;
END LOOP;
IF l_debug_level  > 0 THEN
   oe_debug_pub.add('Out table count : ' || x_line_tbl.count,1) ;
END IF;
l_option_count := x_line_tbl.count + 1;
FOR I in 1..l_option_line_tbl.count LOOP
    x_line_tbl(l_option_count) := l_option_line_tbl(I);
    l_option_count := l_option_count + 1;
END LOOP;
IF l_debug_level  > 0 THEN
   oe_debug_pub.add('Final table picture : ',5);
END IF;
FOR I in 1..x_line_tbl.count LOOP
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('line id            : '||x_line_tbl(i).line_id , 1 ) ;
       oe_debug_pub.add('ordered quantity   : '||x_line_tbl(i).ordered_quantity , 1 ) ;
       oe_debug_pub.add('item type code     : '||x_line_tbl(i).item_type_code , 1 ) ;
       oe_debug_pub.add('operation          : '||x_line_tbl(i).operation , 1 ) ;
       oe_debug_pub.add('line set id        : '||x_line_tbl(i).line_set_id , 1 ) ;
       oe_debug_pub.add('shipped quantity   : '||x_line_tbl(i).shipped_quantity , 1 ) ;
       oe_debug_pub.add('model remnant flag : '||x_line_tbl(i).model_remnant_flag , 1 ) ;
       oe_debug_pub.add('split from line id : '||x_line_tbl(i).split_from_line_id , 1 ) ;
       oe_debug_pub.add('top model line id  : '||x_line_tbl(i).top_model_line_id , 1 ) ;
       oe_debug_pub.add('actual shipment on : '||x_line_tbl(i).actual_shipment_date,1);
    END IF;
END LOOP;
IF l_debug_level > 0 THEN
   OE_DEBUG_PUB.add('Leaving get_non_model_configuration()',5);
END IF;
EXCEPTION
     WHEN OTHERS THEN
          IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,'Get_Non_Model_Configuration' );
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Non_Model_Configuration;

Procedure Get_Model_Configuration(p_line_tbl IN OE_ORDER_PUB.line_tbl_type,
        		    		      x_line_tbl OUT NOCOPY /* file.sql.39 change */ OE_ORDER_PUB.line_tbl_type) IS
l_line_id number;

l_line_tbl                   OE_ORDER_PUB.line_tbl_type := p_line_tbl;
l_reminant_tbl               OE_ORDER_PUB.line_tbl_type;
l_shippable_tbl              OE_ORDER_PUB.line_tbl_type;
l_shipped_tbl                OE_ORDER_PUB.line_tbl_type;
l_temp_tbl                   OE_ORDER_PUB.line_tbl_type;
l_ratio                      number;
l_model_ratio                number;
l_line_rec                   OE_ORDER_PUB.line_rec_type;
l_model_rec                  OE_ORDER_PUB.line_rec_type;
l_option_line                OE_ORDER_PUB.line_rec_type;
l_parent_line                OE_ORDER_PUB.line_rec_type;
l_option_line_tbl            OE_ORDER_PUB.line_tbl_type;
l_tbl_count                  number := 0;
l_option_count               number := 0;
l_original_qty               number := 0;
l_min_model                  number := 0;
l_temp_min_model             number := 0;
l_insert_quantity            number := 0;
l_update_quantity            number := 0;
option_updated               BOOLEAN := FALSE;
l_exist                      BOOLEAN := FALSE;
l_parent_quantity            number := 0;
l_Set_id                     Number;
l_option_not_updated         boolean := TRUE;
l_update_line_reqd           boolean := TRUE;
l_Rem_top_model_line_id      number;
l_Rem_shp_top_model_line_id  number;
l_top_model_line_id          number;

CURSOR Optiontbl IS
       SELECT ORDERED_QUANTITY,
              HEADER_ID,
              LINE_ID
       FROM   OE_ORDER_LINES_ALL
       WHERE  TOP_MODEL_LINE_ID = l_line_id
       AND    LINE_ID <> l_line_id
       AND    NVL(CANCELLED_FLAG,'N') <> 'Y'
       ORDER  BY LINE_ID;
       --
       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
       --
BEGIN
   x_line_tbl := p_line_tbl;
   l_line_id := p_line_tbl(1).line_id;
   oe_line_util.query_row(p_line_id => l_line_id, x_line_rec => l_line_rec);
   l_parent_quantity := l_line_rec.ordered_quantity - p_line_tbl(1).ordered_quantity;
   l_parent_line := l_line_rec;
   -- Get Complete shipped Model if any
   -- Form Complete Shipped Model if g_max_model > 0
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'COMPLETE SHIPPED MODEL' ) ;
   END IF;
   IF  g_max_model > 0 THEN
       l_parent_line := l_line_rec;
       l_parent_line.ordered_quantity := g_max_model;
       l_parent_line.shipped_quantity := g_max_model;
       l_parent_line.operation := oe_globals.g_opr_update;
       l_parent_line.split_action_code := 'SPLIT';
       l_parent_line.split_by := 'SYSTEM';
       --l_option_count := l_option_count + 1;
       IF l_parent_line.line_set_id IS  NULL THEN
          Oe_Set_Util.Create_Line_Set(p_x_line_rec => l_parent_line);
       END IF;
       l_set_id := l_parent_line.line_set_id;
	   x_line_tbl(1) := l_parent_line;
       --l_option_line_tbl(l_option_count) := l_parent_line;
       FOR optionrec IN optiontbl LOOP
 		   oe_line_util.query_row(p_line_id => optionrec.line_id,
                                  x_line_rec => l_option_line);
           l_model_ratio := l_option_line.ordered_quantity / l_line_rec.ordered_quantity;
		   option_updated := FALSE;
     	   FOR I in 1..P_line_tbl.count LOOP
               IF p_line_tbl(I).line_id = optionrec.line_id THEN
                  x_line_tbl(I).ordered_quantity :=  g_max_model * l_model_ratio;
                  x_line_tbl(I).operation := OE_GLOBALS.g_opr_update;
                  x_line_tbl(I).shipped_quantity := x_line_tbl(I).ordered_quantity;
				  option_updated := TRUE;
				  EXIT;
			   END IF;
           END LOOP;
		   IF NOT option_updated THEN
              l_option_count := l_option_count + 1;
              l_option_line_tbl(l_option_count) := l_option_line;
              l_option_line_tbl(l_option_count).ordered_quantity := g_max_model * l_model_ratio;
              /* Start Audit Trail */
              l_option_line_tbl(l_option_count).change_reason := 'SYSTEM';
              /* End Audit Trail */
              l_option_line_tbl(l_option_count).operation := oe_globals.g_opr_update;
              l_option_line_tbl(l_option_count).split_action_code := 'SPLIT';
              l_option_line_tbl(l_option_count).split_by := 'SYSTEM' ;
              l_option_line_tbl(l_option_count).shipped_quantity :=l_option_line_tbl(l_option_count).ordered_quantity;
           END IF; -- Option not updated
     	   option_updated := false;
       END LOOP;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'AFTER MAXIMUM SHIPPED MODEL' ) ;
       END IF;
       FOR I in 1..l_option_line_tbl.count LOOP
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  L_OPTION_LINE_TBL ( I ) .ORDERED_QUANTITY , 1 ) ;
               oe_debug_pub.add(  L_OPTION_LINE_TBL ( I ) .ITEM_TYPE_CODE , 1 ) ;
               oe_debug_pub.add(  L_OPTION_LINE_TBL ( I ) .OPERATION , 1 ) ;
           END IF;
       END LOOP;
   END IF; -- g_max_model
   -- End Complete Shipped Mo
   -- Get  Complete shippable Model if any
   IF g_min_Model > 0 THEN
      l_parent_line := l_line_rec;
      l_parent_line.ordered_quantity := g_min_model;
      l_parent_line.operation := oe_globals.g_opr_create;
      l_parent_line.split_by := 'SYSTEM';
      l_parent_line.split_from_line_id := l_parent_line.line_id;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LINE SET IS-'||L_SET_ID ) ;
      END IF;
      l_parent_line.line_id := fnd_api.g_miss_num;
      l_parent_line.orig_sys_line_ref := fnd_api.g_miss_char; --Bug5207907
      OE_Split_Util.Default_Attributes
      (p_x_line_rec => l_parent_line
       ,p_old_line_rec => l_parent_line );
      IF l_parent_line.line_set_id is null AND l_set_id IS NULL THEN
         Oe_Set_Util.Create_Line_Set(p_x_line_rec => l_parent_line);
         l_set_id := l_parent_line.line_set_id;
	  ELSIF l_set_id is not null then
            l_parent_line.line_set_id := l_set_id;
      END IF;
      l_option_count := l_option_count + 1;
      l_option_line_tbl(l_option_count) := l_parent_line;
      FOR optionrec in optiontbl LOOP
          oe_line_util.query_row(p_line_id => optionrec.line_id,
                                 x_line_rec => l_option_line);
          l_model_ratio :=l_option_line.ordered_quantity / l_line_rec.ordered_quantity;
          l_option_count := l_option_count + 1;
          l_option_line_tbl(l_option_count) := l_option_line;
          l_option_line_tbl(l_option_count).split_from_line_id := optionrec.line_id;
          l_option_line_tbl(l_option_count).line_id := fnd_api.g_miss_num;
          l_option_line_tbl(l_option_count).operation := oe_globals.g_opr_create;
          l_option_line_tbl(l_option_count).orig_sys_line_ref := fnd_api.g_miss_char; --Bug5207907
          g_qry_out_rec := l_option_line_tbl(l_option_count) ;
          OE_Split_Util.Default_Attributes
          (p_x_line_rec                  => g_qry_out_rec
           ,p_old_line_rec             => l_option_line_tbl(l_option_count)
           );
          l_option_line_tbl(l_option_count) := g_qry_out_rec;
          l_option_line_tbl(l_option_count).top_model_line_id := l_parent_line.line_id;
          IF l_option_line_tbl(l_option_count).ato_line_id IS NOT NULL THEN
             l_option_line_tbl(l_option_count).ato_line_id := l_parent_line.line_id;
          END IF;
          l_option_line_tbl(l_option_count).ordered_quantity := g_min_model * l_model_ratio ;
      END LOOP;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'AFTER GET SHIPPABLE MODEL' ) ;
   END IF;
   FOR I in 1..l_option_line_tbl.count LOOP
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ORDERED QUANTITY : '||L_OPTION_LINE_TBL ( I ) .ORDERED_QUANTITY , 1 ) ;
           oe_debug_pub.add(  'ITEM TYPE CODE : '||L_OPTION_LINE_TBL ( I ) .ITEM_TYPE_CODE , 1 ) ;
           oe_debug_pub.add(  'OPERATION : '||L_OPTION_LINE_TBL ( I ) .OPERATION , 1 ) ;
           oe_debug_pub.add(  'LINE SET ID : '||L_OPTION_LINE_TBL ( I ) .LINE_SET_ID , 1 ) ;
       END IF;
   END LOOP;
   -- Get Remanant shipped
   l_parent_line := l_line_rec;
   IF g_max_model = 0 THEN
      IF x_line_tbl(1).ordered_quantity < 0 THEN
	     x_line_tbl(1).ordered_quantity := l_parent_line.ordered_quantity;
      ELSE
         x_line_tbl(1).ordered_quantity := p_line_tbl(1).shipped_quantity - g_max_model ;
         x_line_tbl(1).shipped_quantity := x_line_tbl(1).ordered_quantity;
      END IF;
	  x_line_tbl(1).model_remnant_flag := 'Y';
      IF    l_parent_line.line_set_id is null AND l_set_id   IS NULL THEN
            Oe_Set_Util.Create_Line_Set(p_x_line_rec => l_parent_line);
            l_set_id := l_parent_line.line_set_id;
	  ELSIF l_set_id is not null then
			x_line_tbl(1).line_set_id := l_set_id;
      END IF;
      l_rem_shp_top_model_line_id :=  x_line_tbl(1).line_id;
   ELSE -- Gmaxmodel
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARENT ORDERED QUANTITY : ' || L_PARENT_LINE.ORDERED_QUANTITY ) ;
      END IF;
      l_parent_line.ordered_quantity := p_line_tbl(1).shipped_quantity - g_max_model ;
	  IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(  'PARENT ORDERED QUANTITY : ' || L_PARENT_LINE.ORDERED_QUANTITY ) ;
	  END IF;
	  IF l_parent_line.ordered_quantity > 0 THEN
         l_parent_line.operation := oe_globals.g_opr_create;
         l_parent_line.split_by := 'SYSTEM';
         l_parent_line.split_from_line_id := l_parent_line.line_id;
         l_parent_line.line_id := fnd_api.g_miss_num;
         l_parent_line.config_header_id := NULL;
         l_parent_line.config_rev_nbr := NULL;
 	 l_parent_line.orig_sys_line_ref := fnd_api.g_miss_char; --Bug5207907
         OE_Split_Util.Default_Attributes
         ( p_x_line_rec   => l_parent_line
          ,p_old_line_rec => l_parent_line );
		 l_rem_shp_top_model_line_id :=  l_parent_line.line_id;
         IF l_parent_line.line_set_id is null AND l_set_id   IS NULL THEN
            Oe_Set_Util.Create_Line_Set(p_x_line_rec => l_parent_line);
            l_set_id := l_parent_line.line_set_id;
         ELSIF l_set_id is not null then
               l_parent_line.line_set_id := l_set_id;
         END IF;
         l_parent_line.ordered_quantity := p_line_tbl(1).shipped_quantity - g_max_model ;
         l_parent_line.shipped_quantity := l_parent_line.ordered_quantity;
	     l_parent_line.model_remnant_flag := 'Y';
		 --IF l_parent_line.ordered_quantity > 0 THEN
         l_option_count := l_option_count + 1;
         l_option_line_tbl(l_option_count) := l_parent_line;
   	 END IF;
   END IF; -- Gmaxmodel
   -- Remanant Unshipped Model
   l_parent_line := l_line_rec;
   l_parent_line.ordered_quantity := l_line_rec.ordered_quantity - p_line_tbl(1).shipped_quantity - g_min_model;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Parent line unshipped qty 1 : ' || L_PARENT_LINE.ORDERED_QUANTITY ) ;
       oe_debug_pub.add('This line unshipped qty 2 : ' || L_LINE_REC.ORDERED_QUANTITY ) ;
       oe_debug_pub.add('unshipped qty 3 : ' || X_LINE_TBL ( 1 ) .ORDERED_QUANTITY ) ;
   END IF;
   IF l_parent_line.ordered_quantity > 0 THEN
      l_parent_line.operation := oe_globals.g_opr_create;
      l_parent_line.split_by := 'SYSTEM';
      l_parent_line.split_from_line_id := l_parent_line.line_id;
      l_parent_line.line_id := fnd_api.g_miss_num;
      OE_Split_Util.Default_Attributes
      ( p_x_line_rec   => l_parent_line
       ,p_old_line_rec => l_parent_line
       );
      l_parent_line.line_set_id := l_set_id;
	  l_rem_top_model_line_id := l_parent_line.line_id;
      l_option_count := l_option_count + 1;
      l_option_line_tbl(l_option_count) := l_parent_line;
      l_option_line_tbl(l_option_count).model_remnant_flag := 'Y';
	END IF;
    IF l_rem_shp_top_model_line_id is not null THEN
       l_top_model_line_id := l_rem_shp_top_model_line_id ;
    ELSE
       l_top_model_line_id := l_rem_top_model_line_id ;
	END IF;
    -- Get remanat shipped options
    FOR optionrec in optiontbl LOOP
        oe_line_util.query_row(p_line_id => optionrec.line_id,
                               x_line_rec => l_option_line);
        l_model_ratio := l_option_line.ordered_quantity / l_line_rec.ordered_quantity;
        FOR I in 1..P_line_tbl.count LOOP
            IF  p_line_tbl(I).line_id = optionrec.line_id THEN
                IF  g_max_model = 0 THEN
		    IF  x_line_tbl(I).ordered_quantity < 0 THEN
			x_line_tbl(I).ordered_quantity := optionrec.ordered_quantity;
	            ELSE
                        -- add IF for bug 4590044
                        IF (p_line_tbl(I).shipped_quantity - g_max_model * l_model_ratio) >0 THEN
                            x_line_tbl(I).ordered_quantity :=
                            p_line_tbl(I).shipped_quantity - g_max_model * l_model_ratio;
		            x_line_tbl(I).shipped_quantity := x_line_tbl(I).ordered_quantity;
                        end if;
                    END IF;
		    x_line_tbl(I).top_model_line_id := l_top_model_line_id;
	            x_line_tbl(I).model_remnant_flag := 'Y';
     		ELSE -- G_Max_Model
                    --bug 4590044 :create shipped remanant option line only when ordered_qty > 0
                    IF ( p_line_tbl(I).shipped_quantity-g_max_model * l_model_ratio >0) THEN
                         l_option_count := l_option_count + 1;
                         l_option_line_tbl(l_option_count) := l_option_line;
                         l_option_line_tbl(l_option_count).line_id := fnd_api.g_miss_num;
                         l_option_line_tbl(l_option_count).split_from_line_id := optionrec.line_id;
                         l_option_line_tbl(l_option_count).operation := oe_globals.g_opr_create;
	                 g_qry_out_rec := l_option_line_tbl(l_option_count) ;
                         OE_Split_Util.Default_Attributes
                             (p_x_line_rec                  => g_qry_out_rec
                              ,   p_old_line_rec             => l_option_line_tbl(l_option_count));
	                 l_option_line_tbl(l_option_count) := g_qry_out_rec;
                         l_option_line_tbl(l_option_count).ordered_quantity :=
                         p_line_tbl(I).shipped_quantity-g_max_model * l_model_ratio;
                         l_option_line_tbl(l_option_count).shipped_quantity :=l_option_line_tbl(l_option_count).ordered_quantity;
		         IF l_debug_level  > 0 THEN
		            oe_debug_pub.add(  'RATIO : ' ||L_MODEL_RATIO , 1 ) ;
		            oe_debug_pub.add(  'LOOP COUNTER : ' ||I , 1 ) ;
		            oe_debug_pub.add(  'ORDERED QUANTITY ON REMNANT : ' || X_LINE_TBL ( I ) .ORDERED_QUANTITY , 1 ) ;
		            oe_debug_pub.add(  'ORDERED QUTY 2 : ' || L_OPTION_LINE_TBL ( L_OPTION_COUNT ) .ORDERED_QUANTITY ) ;
		         END IF;
	                 IF l_top_model_line_id is not null then
                            l_option_line_tbl(l_option_count).top_model_line_id :=l_top_model_line_id;
	                 END IF;
                         l_option_line_tbl(l_option_count).model_remnant_flag := 'Y';
                         IF l_option_line_tbl(l_option_count).ato_line_id IS NOT NULL THEN
                            l_option_line_tbl(l_option_count).ato_line_id := l_top_model_line_id;
	                 END IF;
                    END IF; --4590044 end of Order Qut check if greater then Zero?
	        END IF; -- Gmaxmodel
                EXIT;
	    END IF;
        END LOOP;
    END LOOP; --Option rec loop.
    -- Get Remanant Unshipped
    IF  l_rem_top_model_line_id is not null THEN
        l_top_model_line_id := l_rem_top_model_line_id ;
    ELSE
        l_top_model_line_id := l_rem_shp_top_model_line_id ;
    END IF;
    FOR optionrec in optiontbl LOOP
  	oe_line_util.query_row(p_line_id => optionrec.line_id,
                               x_line_rec => l_option_line);
        l_model_ratio := l_option_line.ordered_quantity / l_line_rec.ordered_quantity;
        option_updated := FALSE;
	l_insert_quantity := 0;
        FOR I in 1..P_line_tbl.count LOOP
            IF p_line_tbl(I).line_id = optionrec.line_id THEN
      	       l_insert_quantity := p_line_tbl(I).shipped_quantity;
	       option_updated := true;
     	       EXIT;
            ELSE
               --Add this condition for the bug#4590097
               l_insert_quantity := (g_max_model*l_model_ratio);
	    END IF;
	END LOOP;
	l_update_quantity := l_option_line.ordered_quantity - g_min_model * l_model_ratio - l_insert_quantity ;
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'UPDATE QUANTITY : ' || L_UPDATE_QUANTITY ) ;
	   oe_debug_pub.add(  'OPTION LINE ORDERED QUANTITY : ' || L_OPTION_LINE.ORDERED_QUANTITY ) ;
	   oe_debug_pub.add(  'RATIO : ' || G_MIN_MODEL * L_MODEL_RATIO ) ;
	   oe_debug_pub.add(  'INSERT QUANTITY : ' || L_INSERT_QUANTITY ) ;
	END IF;
	IF l_update_quantity > 0 THEN
	   l_option_count := l_option_count + 1;
           IF NOT option_updated  AND g_max_model = 0 THEN
              l_option_line_tbl(l_option_count) := l_option_line;
       	      l_option_line_tbl(l_option_count).operation := oe_globals.g_opr_update;
       	      l_option_line_tbl(l_option_count).split_action_code := 'SPLIT';
       	      l_option_line_tbl(l_option_count).split_by := 'SYSTEM';
              l_option_line_tbl(l_option_count).ship_set_id := null;
       	      l_option_line_tbl(l_option_count).arrival_Set_id := null;
              l_option_line_tbl(l_option_count).top_model_line_id := l_top_model_line_id;
           ELSE
	      l_option_line_tbl(l_option_count) := l_option_line;
              l_option_line_tbl(l_option_count).split_from_line_id := optionrec.line_id;
              l_option_line_tbl(l_option_count).line_id := fnd_api.g_miss_num;
              l_option_line_tbl(l_option_count).operation := oe_globals.g_opr_create;
  	      l_option_line_tbl(l_option_count).orig_sys_line_ref := fnd_api.g_miss_char; --Bug5207907
	      g_qry_out_rec := l_option_line_tbl(l_option_count) ;
              OE_Split_Util.Default_Attributes
                  (   p_x_line_rec                   => g_qry_out_rec
                   ,   p_old_line_rec             => l_option_line_tbl(l_option_count)
                  );
	              l_option_line_tbl(l_option_count) := g_qry_out_rec;
              if l_top_model_line_id is not null then
                 l_option_line_tbl(l_option_count).top_model_line_id := l_top_model_line_id;
	      end if;
              IF  l_option_line_tbl(l_option_count).ato_line_id IS NOT NULL THEN
	          IF l_top_model_line_id IS NOT NULL THEN
                     l_option_line_tbl(l_option_count).ato_line_id := l_top_model_line_id;
	          END IF;
              END IF;
           END IF; -- Option updated or g max model
           l_option_line_tbl(l_option_count).model_remnant_flag := 'Y';
           l_option_line_tbl(l_option_count).ordered_quantity := l_update_quantity;
        END IF; -- Update Quantity
	option_updated := false;
    END LOOP;
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'COUNT IN X_LINE_TBL' || X_LINE_TBL.COUNT , 1 ) ;
    END IF;
    l_option_count := x_line_tbl.count + 1;
    FOR I in 1..l_option_line_tbl.count LOOP
        x_line_tbl(l_option_count) := l_option_line_tbl(I);
        l_option_count := l_option_count + 1;
    END LOOP;
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'FINAL OUT TABLE' ) ;
    END IF;
    FOR I in 1..x_line_tbl.count LOOP
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LINE ID : '|| X_LINE_TBL ( I ) .LINE_ID ) ;
           oe_debug_pub.add(  'ORDERED QUANTITY : '||X_LINE_TBL ( I ) .ORDERED_QUANTITY ) ;
           oe_debug_pub.add(  'ITEM TYPE CODE : '||X_LINE_TBL ( I ) .ITEM_TYPE_CODE ) ;
     	   oe_debug_pub.add(  'OPERATION : ' ||X_LINE_TBL ( I ) .OPERATION ) ;
           oe_debug_pub.add(  'LINE SET ID : ' || X_LINE_TBL ( I ) .LINE_SET_ID ) ;
           oe_debug_pub.add(  'SHIPPED QUANTITY : '|| X_LINE_TBL ( I ) .SHIPPED_QUANTITY ) ;
           oe_debug_pub.add(  'REMNANT FLAG : '||X_LINE_TBL ( I ) .MODEL_REMNANT_FLAG ) ;
           oe_debug_pub.add(  'SPLIT FROM LINE ID : '||X_LINE_TBL ( I ) .SPLIT_FROM_LINE_ID ) ;
           oe_debug_pub.add(  'TOP MODEL LINE ID : '||X_LINE_TBL ( I ) .TOP_MODEL_LINE_ID ) ;
        END IF;
    END LOOP;
EXCEPTION
     WHEN OTHERS THEN
          IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             OE_MSG_PUB.Add_Exc_Msg
               (    G_PKG_NAME ,
                    'Get_Model_Configuration'
               );
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Model_Configuration;

Procedure Cascade_Proportional_Split(p_line_tbl              IN OE_ORDER_PUB.Line_tbl_type,
                		     Parent_ordered_quantity NUMBER,
				     p_Index                 NUMBER,
			             x_line_tbl              OUT NOCOPY /* file.sql.39 change */ OE_ORDER_PUB.Line_tbl_type,
				     x_line_adj_tbl          OUT NOCOPY /* file.sql.39 change */ OE_ORDER_PUB.Line_adj_tbl_type,
                		     x_line_scredit_tbl      OUT NOCOPY /* file.sql.39 change */ OE_ORDER_PUB.Line_scredit_tbl_type)
IS
l_option_line_tbl        OE_ORDER_PUB.Line_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_TBL;
l_line_out_tbl           OE_ORDER_PUB.Line_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_TBL;
l_line_id                NUMBER;
l_top_model_line_id      NUMBER;
l_set_id                 NUMBER;
TYPE optrec_type is RECORD (
        Ordered_quantity NUMBER,
        header_id        NUMBER,
        Line_id          NUMBER);
optionrec optrec_type;
l_option_count           NUMBER := 1;
l_model_ratio            NUMBER;
l_option_line            OE_ORDER_PUB.line_rec_type;
l_line_adj_tbl           OE_Order_Pub.Line_Adj_tbl_type;
l_line_adj_temp_tbl      OE_Order_Pub.Line_Adj_tbl_type;
l_line_scredit_tbl       OE_Order_Pub.Line_scredit_Tbl_type;
l_line_scredit_temp_tbl  OE_Order_Pub.Line_scredit_Tbl_type;
l_adjustment_count       NUMBER := 0;
l_scredit_count          NUMBER := 0;
l_split_line_tbl         oe_split_util.split_line_tbl;
l_split_count            NUMBER := 0;
l_model_map_tbl          oe_split_util.model_map_tbl;
l_map_count              NUMBER := 0;
L_FOUND                  BOOLEAN; --8706868
Type Optioncur IS REF CURSOR;
Optrec Optioncur;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   x_line_tbl := p_line_tbl;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTER CASCADE SPLITS ' , 1 ) ;
   END IF;
   l_line_id := p_line_tbl(p_index).line_id;
   IF   (p_line_tbl(p_index).line_id = p_line_tbl(p_index).ato_line_id AND p_line_tbl(p_index).item_type_code = 'CLASS') THEN
        OPEN optrec FOR
        SELECT ORDERED_QUANTITY,
               HEADER_ID,
               LINE_ID
        FROM   OE_ORDER_LINES_ALL
        WHERE  ATO_LINE_ID = l_line_id
        AND    LINE_ID <> l_line_id
        AND    NVL(CANCELLED_FLAG,'N')<>'Y'
        ORDER BY LINE_ID;
    ELSE
        OPEN Optrec FOR
        SELECT ORDERED_QUANTITY,
               HEADER_ID,
               LINE_ID
        FROM   OE_ORDER_LINES_ALL
        WHERE  TOP_MODEL_LINE_ID = l_line_id
        AND    LINE_ID <> l_line_id
        AND    NVL(CANCELLED_FLAG,'N') <> 'Y'
        ORDER BY LINE_ID;
   END IF;
   --FOR Optionrec IN Optiontbl
   LOOP
      FETCH Optrec INTO optionrec;
      EXIT WHEN optrec%NOTFOUND;
      l_model_ratio := optionrec.ordered_quantity/ parent_ordered_quantity;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'MODEL RATIO : ' || L_MODEL_RATIO , 1 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ORDERED QUANTITY RATIO : ' || OPTIONREC.ORDERED_QUANTITY , 1 ) ;
      END IF;
      oe_line_util.query_row(p_line_id => optionrec.line_id, x_line_rec => l_option_line);
      l_line_scredit_tbl.delete;
      oe_line_scredit_util.query_rows( p_line_id => optionrec.line_id, x_line_scredit_tbl => l_line_scredit_tbl);
      l_option_line_tbl(l_option_count) := l_option_line;
      l_option_line_tbl(l_option_count).line_id := optionrec.line_id;
      l_option_line_tbl(l_option_count).ordered_quantity := p_line_tbl(p_index).ordered_quantity * l_model_ratio;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RATIO : ' || P_LINE_TBL ( P_INDEX ) .ORDERED_QUANTITY ) ;
	  oe_debug_pub.add(  'REQUEST DATE : ' || P_LINE_TBL ( P_INDEX ) .REQUEST_DATE ) ;
	  oe_debug_pub.add(  'WAREHOUSE ' || P_LINE_TBL ( P_INDEX ) .SHIP_FROM_ORG_ID) ;
          oe_debug_pub.add(  'SHIP TO ' || P_LINE_TBL ( P_INDEX ) .SHIP_TO_ORG_ID) ;

      END IF;
      l_option_line_tbl(l_option_count).operation := oe_globals.g_opr_update;
      l_option_line_tbl(l_option_count).split_action_code := 'SPLIT';
      l_option_line_tbl(l_option_count).split_by :=  p_line_tbl(p_index).split_by;

      /* Populate Line set id if set id is not already populated bug - 2103004 */

      IF ( l_option_line_tbl(l_option_count).line_set_id IS  NULL ) THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'CREATING LINE SETS : ' , 1 ) ;
         END IF;
         Oe_Set_Util.Create_Line_Set(p_x_line_rec => l_option_line_tbl(l_option_count));
      END IF;
      l_set_id := l_option_line_tbl(l_option_count).line_Set_id;
      l_split_count := l_split_count + 1;
      l_split_line_tbl(l_split_count).quantity := l_option_line_tbl(l_option_count).ordered_quantity;
      l_split_line_tbl(l_split_count).line_id := l_option_line_tbl(l_option_count).line_id;
      l_option_count := l_option_count + 1;
      FOR I IN	2 .. g_split_line_tbl.count LOOP
          l_option_line_tbl(l_option_count) := l_option_line;
	      l_option_line_tbl(l_option_count).line_id := fnd_api.g_miss_num;
	      l_option_line_tbl(l_option_count).ordered_quantity := g_split_line_tbl(I).quantity * l_model_ratio;
	      IF l_debug_level  > 0 THEN
	          oe_debug_pub.add(  'RATIO 3 : ' || G_SPLIT_LINE_TBL ( I ) .QUANTITY , 1 ) ;
	      END IF;
	      l_option_line_tbl(l_option_count).operation := oe_globals.g_opr_create;
	      l_option_line_tbl(l_option_count).split_from_line_id := optionrec.line_id;
	      l_option_line_tbl(l_option_count).split_by :=  p_line_tbl(p_index).split_by;
              g_qry_out_rec := l_option_line_tbl(l_option_count) ;
     	      g_qry_out_rec.orig_sys_line_ref :=fnd_api.g_miss_char; --bug5207907
	      OE_Split_Util.Default_Attributes ( p_x_line_rec => g_qry_out_rec
                                            ,p_old_line_rec => l_option_line_tbl(l_option_count));
          l_option_line_tbl(l_option_count) := g_qry_out_rec;

	      l_option_line_tbl(l_option_count).top_model_line_id := g_split_line_tbl(I).line_id;
	      IF  l_option_line_tbl(l_option_count).ato_line_id is not null AND
	          l_option_line_tbl(l_option_count).ato_line_id <>
	          l_option_line_tbl(l_option_count).line_id  THEN
	             l_option_line_tbl(l_option_count).ato_line_id := g_split_line_tbl(I).line_id;
	      END IF;
          l_option_line_tbl(l_option_count).line_Set_id := l_set_id;
	      l_option_line_tbl(l_option_count).config_header_id := NULL;
          l_option_line_tbl(l_option_count).config_rev_nbr := NULL;

          -- WE are splitting a class here hence record ato line id and link to lineid

          l_split_count := l_split_count + 1;
          l_split_line_tbl(l_split_count).quantity := l_option_line_tbl(l_option_count).ordered_quantity;
       	  l_split_line_tbl(l_split_count).line_id := l_option_line_tbl(l_option_count).line_id;
	      l_split_line_tbl(l_split_count).split_from_line_id := l_option_line_tbl(l_option_count).split_from_line_id;
          -- Copy Credits for this option
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'COPYING SALES CREDITS TO NEW OPTION ' , 1 ) ;
          END IF;
          FOR SCRD_REC IN 1..l_line_Scredit_tbl.count LOOP
              l_scredit_count := l_scredit_count + 1;
              l_line_scredit_temp_tbl(l_scredit_count) := l_line_scredit_tbl(SCRD_REC);
              l_line_scredit_temp_tbl(l_scredit_count).sales_credit_id := FND_API.G_MISS_NUM;
              l_line_scredit_temp_tbl(l_scredit_count).Operation := OE_GLOBALS.G_OPR_CREATE;
              l_line_scredit_temp_tbl(l_scredit_count).line_id := l_option_line_tbl(l_option_count).line_id;
          END LOOP;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DONE COPYING SALES CREDITS TO NEW OPTION ' , 1 ) ;
          END IF;
	      l_option_count := l_option_count + 1;
      END LOOP;
      Get_Service_Lines( p_line_tbl => x_line_tbl,
	            	     x_line_tbl => l_line_out_tbl,
		                 g_split_line_tbl => l_split_line_tbl);

      x_line_tbl := l_line_out_tbl; -- Swapping can be fixed,  opportunity to optimize
      l_split_line_tbl.delete;
      l_split_count := 0;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER OPTION PROCESSING' , 1 ) ;
      END IF;
   END LOOP;
CLOSE optrec;
l_option_count := x_line_tbl.count + 1;
FOR I in 1..l_option_line_tbl.count LOOP
    x_line_tbl(l_option_count) := l_option_line_tbl(I);
    l_option_count := l_option_count + 1;
END lOOP;

      -- 8706868 Deriving Link to Line_id for components with CREATE operation
      Begin
	FOR I in 1..x_line_tbl.count LOOP
	L_FOUND := FALSE;
	  IF X_LINE_TBL(I).OPERATION = OE_GLOBALS.G_OPR_CREATE
	     AND X_LINE_TBL(I).LINE_ID <> X_LINE_TBL(I).TOP_MODEL_LINE_ID
	     AND X_LINE_TBL(I).TOP_MODEL_LINE_ID IS NOT NULL THEN
	      FOR J in 1..x_line_tbl.count LOOP
	        IF X_LINE_TBL(J).OPERATION = OE_GLOBALS.G_OPR_UPDATE THEN
		  IF X_LINE_TBL(J).LINE_ID = X_LINE_TBL(I).SPLIT_FROM_LINE_ID THEN
		    FOR K in 1..x_line_tbl.count LOOP
		      IF X_LINE_TBL(J).LINK_TO_LINE_ID = X_LINE_TBL(K).SPLIT_FROM_LINE_ID AND
		        X_LINE_TBL(I).TOP_MODEL_LINE_ID = X_LINE_TBL(K).TOP_MODEL_LINE_ID THEN
		        X_LINE_TBL(I).LINK_TO_LINE_ID := X_LINE_TBL(K).LINE_ID;
			L_FOUND := TRUE;
			EXIT;
		      END IF;
		    END LOOP;
		  END IF;
		END IF;
		IF L_FOUND THEN
		  EXIT;
		END IF;
	      END LOOP;
	  END IF;
	END LOOP;
      End;

      FOR I in 1..x_line_tbl.count LOOP
	      IF l_debug_level  > 0 THEN
	          oe_debug_pub.add(  'QUANTITY : ' || X_LINE_TBL ( I ) .ORDERED_QUANTITY ) ;
	          oe_debug_pub.add(  'OPERATION : ' || X_LINE_TBL ( I ) .OPERATION ) ;
	          oe_debug_pub.add(  'ITEM : ' || X_LINE_TBL ( I ) .ITEM_TYPE_CODE ) ;
	          oe_debug_pub.add(  'LINE : ' || X_LINE_TBL ( I ) .LINE_ID ) ;
	          oe_debug_pub.add(  'LINK TO LINE ID : '|| X_LINE_TBL ( I ) .LINK_TO_LINE_ID );
	          oe_debug_pub.add(  'SPLIT LINE : ' || X_LINE_TBL ( I ) .SPLIT_FROM_LINE_ID ) ;
	          oe_debug_pub.add(  'LINE SET : ' || X_LINE_TBL ( I ) .LINE_SET_ID ) ;
	          oe_debug_pub.add(  X_LINE_TBL ( I ) .SPLIT_ACTION_CODE ) ;
	      END IF;
      END LOOP;

-- Populate Credits into out table
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'POPULATING SALES CREDIT OUT TABLE...' , 1 ) ;
END IF;
IF l_line_scredit_temp_tbl.count > 0 THEN
   l_scredit_count := x_line_scredit_tbl.count + 1;
   FOR I in 1..l_line_scredit_temp_tbl.count LOOP
       x_line_scredit_tbl(l_scredit_count) := l_line_scredit_temp_tbl(I);
       l_scredit_count := l_scredit_count + 1;
   END LOOP;
END IF;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXIT CASCADE PROPORTIONAL SPLIT' , 1 ) ;
END IF;
EXCEPTION
     WHEN OTHERS THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'ERROR IN CASCADE PROPORTIONAL SPLIT ..'||SQLERRM , 1 ) ;
          END IF;
          IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , 'Cascade_Proportional_Split');
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End Cascade_Proportional_Split;

Procedure Default_Attributes
     	  (p_x_line_rec      IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
           ,p_old_line_rec  IN  OE_Order_PUB.Line_Rec_Type
           )
IS
l_line_rec            OE_Order_PUB.Line_Rec_Type := p_x_line_rec;
g_multiple_shipments  VARCHAR2(3);
l_code_level          VARCHAR2(30);
l_shipment_number     NUMBER;
l_order_date_type_code  VARCHAR2(20); -- 8706868
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   fnd_profile.get('ONT_IMP_MULTIPLE_SHIPMENTS', g_multiple_shipments);
   g_multiple_shipments := nvl(g_multiple_shipments, 'NO');
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'G_MULTIPLE_SHIPMENTS = '||G_MULTIPLE_SHIPMENTS , 5 ) ;
   END IF;
   l_code_level := OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'L_CODE_LEVEL = '||L_CODE_LEVEL , 5 ) ;
   END IF;
   IF  oe_split_util.g_sch_recursion = 'FALSE' THEN
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'ENTER DEFAULT ATTRIBUTES FOR SPLIT' ) ;
	       oe_debug_pub.add(  'LINEID:'||P_X_LINE_REC.LINE_ID ) ;
	       oe_debug_pub.add(  'SPLITLINEID:'||P_X_LINE_REC.SPLIT_FROM_LINE_ID ) ;
               oe_debug_pub.add(  'REQUEST DATE FLAG:'||P_X_LINE_REC.SPLIT_REQUEST_DATE ) ;
	       oe_debug_pub.add(  'SHIP FROM FLAG:'||P_X_LINE_REC.SPLIT_SHIP_FROM ) ;
	       oe_debug_pub.add(  'SHIP TO FLAG:'||P_X_LINE_REC.SPLIT_SHIP_TO ) ;
	   END IF;
	   IF (p_x_line_rec.operation = oe_globals.g_opr_create and
	      (p_x_line_rec.split_from_line_id IS NOT NULL AND
 		   p_x_line_rec.split_from_line_id <> FND_API.G_MISS_NUM) AND
		  (p_x_line_rec.line_id IS NULL OR
 		   p_x_line_rec.line_id = FND_API.G_MISS_NUM)) THEN
     		 IF l_debug_level  > 0 THEN
     		     oe_debug_pub.add(  'ENTER INTO DEFAULTING SPLITS' ) ;
     		 END IF;
             oe_line_util.query_row(p_line_id => p_x_line_rec.split_from_line_id,
                                    x_line_rec => l_line_rec);
        	 l_line_rec.line_id := OE_Default_Line.get_Line;
             IF (P_X_LINE_REC.SERVICE_REFERENCE_LINE_ID IS NOT NULL
                 AND P_X_LINE_REC.SERVICE_REFERENCE_LINE_ID <> FND_API.G_MISS_NUM) THEN            --9111247

                  L_LINE_REC.SERVICE_REFERENCE_LINE_ID:=P_X_LINE_REC.SERVICE_REFERENCE_LINE_ID  ;
             END IF ;
             --online changes
             IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110508' AND
                 g_multiple_shipments = 'YES'  THEN
          -- AND nvl(l_line_rec.source_document_type_id,0) <> 10 THEN  --Bug 5435726
          -- Commented the above condition for bug 6712010
		            l_shipment_number := get_shipment_number(l_line_rec);
                    l_line_rec.orig_sys_shipment_ref :=  substr(l_line_rec.orig_sys_shipment_ref,0,instr(l_line_rec.orig_sys_shipment_ref,'.'))||l_shipment_number;
             ELSIF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL < '110508' AND
                   nvl(l_line_rec.source_document_type_id,0) <> 10 THEN --Bug 5435726
                   -- l_line_rec.orig_sys_line_ref := 'OE_ORDER_LINES_ALL'||l_line_rec.line_id;

                    --Changed for bug 4302022
          	      IF (p_x_line_rec.orig_sys_line_ref IS NULL OR
 		          p_x_line_rec.orig_sys_line_ref = FND_API.G_MISS_CHAR) THEN

                          l_line_rec.orig_sys_line_ref := 'OE_ORDER_LINES_ALL'||l_line_rec.line_id;
                       ELSE
                          OE_DEBUG_PUB.add('Orig Sys Line Ref was populated',1);
                          l_line_rec.orig_sys_line_ref := p_x_line_rec.orig_sys_line_ref;
                       END IF;

             ELSIF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110508' AND
                    g_multiple_shipments = 'NO' AND
                    nvl(l_line_rec.source_document_type_id,0) <> 10 THEN --Bug 5435726
                    -- l_line_rec.orig_sys_line_ref := 'OE_ORDER_LINES_ALL'||l_line_rec.line_id;
                    --Changed for bug 4302022
          	      IF (p_x_line_rec.orig_sys_line_ref IS NULL OR
 		          p_x_line_rec.orig_sys_line_ref = FND_API.G_MISS_CHAR) THEN

                          l_line_rec.orig_sys_line_ref := 'OE_ORDER_LINES_ALL'||l_line_rec.line_id;
                       ELSE
                          OE_DEBUG_PUB.add('Orig Sys Line Ref was populated',1);
                          l_line_rec.orig_sys_line_ref := p_x_line_rec.orig_sys_line_ref;
                       END IF;


             END IF;
		     --l_line_rec.shipment_number := get_shipment_number(l_line_rec);
		     IF l_debug_level  > 0 THEN
		         oe_debug_pub.add(  'SHIPMENT_NUMBER:'||L_LINE_REC.SHIPMENT_NUMBER ) ;
		     END IF;
		     l_line_rec.split_from_line_id := p_x_line_rec.split_from_line_id;
		     l_line_rec.ordered_quantity := p_x_line_rec.ordered_quantity;
                     l_line_rec.ordered_quantity2 := p_x_line_rec.ordered_quantity2; -- OPM B1661023 04/02/01
		     l_line_rec.split_by := p_x_line_rec.split_by;
		     -- 8706868

		     IF p_x_line_rec.request_date IS NOT NULL AND
		        p_x_line_rec.request_date <> fnd_api.G_MISS_DATE  AND
			NVL(P_X_LINE_REC.SPLIT_REQUEST_DATE,'N') ='Y' THEN -- 10278858

			IF l_line_rec.schedule_ship_date IS NOT NULL
			   AND NOT OE_GLOBALS.EQUAL(p_x_line_rec.request_date
			                            ,l_line_rec.request_date)
                           AND NVL(OE_SYS_PARAMETERS.value('RESCHEDULE_REQUEST_DATE_FLAG'),'Y') = 'Y' THEN -- 12833832
                           l_order_date_type_code := NVL(oe_schedule_util.Get_Date_Type(l_line_rec.header_id),'SHIP');
                           IF l_order_date_type_code = 'SHIP' THEN
			      -- Its a scheduled line. Reschedule with new date
                              l_line_rec.schedule_ship_date := p_x_line_rec.request_date;
                           ELSE
                              l_line_rec.schedule_arrival_date := p_x_line_rec.request_date;
                           END IF;
                        END IF;

                        l_line_rec.request_date := p_x_line_rec.request_date;
                     END IF;
		     IF p_x_line_rec.ship_from_org_id IS NOT NULL AND
		      p_x_line_rec.ship_from_org_id <> fnd_api.G_MISS_NUM AND
		      NVL(P_X_LINE_REC.SPLIT_SHIP_FROM,'N') = 'Y' THEN --10278858
                        l_line_rec.ship_from_org_id := p_x_line_rec.ship_from_org_id;
                     END IF;
                     IF p_x_line_rec.ship_to_org_id IS NOT NULL AND
		      p_x_line_rec.ship_to_org_id <> fnd_api.G_MISS_NUM AND
		      NVL(P_X_LINE_REC.SPLIT_SHIP_TO,'N') = 'Y' THEN --10278858
                        l_line_rec.ship_to_org_id := p_x_line_rec.ship_to_org_id;
                     END IF;
		     -- 8706868
		     l_line_rec.cancelled_quantity := NULL;
		     l_line_rec.cancelled_quantity2 := NULL; -- INVCONV
		     l_line_rec.shipped_quantity := NULL;
		     l_line_rec.shipping_quantity := NULL;
		     l_line_rec.shipped_quantity2 := NULL; -- B1661023 OPM 04/02/01
		     l_line_rec.shipping_quantity2 := NULL; -- B1661023  OPM 04/02/01
		     l_line_rec.shipping_quantity_uom := NULL;
        	 l_line_rec.actual_shipment_date := NULL;
		     l_line_rec.over_ship_reason_code := NULL;
		     l_line_rec.over_ship_resolved_flag := NULL;
	         --	l_line_rec.reserved_quantity := 0;
     		 l_line_rec.config_header_id := NULL;
		     l_line_rec.config_rev_nbr := NULL;
		     l_line_rec.ship_set_id := NULL;
		     l_line_rec.arrival_set_id := NULL;
             -- fix for bug 2250017
             l_line_rec.fulfilled_quantity := NULL;
             l_line_rec.fulfilled_quantity2 := NULL; -- INVCONV

     		 IF (l_line_rec.Item_Type_Code = 'MODEL' OR
		         l_line_rec.Item_Type_Code = 'CLASS' OR
		         l_line_rec.Item_Type_Code = 'KIT') THEN
		           IF (l_line_rec.top_model_line_id =
			           l_line_rec.split_from_line_id) THEN
		               l_line_rec.top_model_line_id := l_line_rec.line_id;
		                    IF l_line_rec.ato_line_id is not null THEN
		                       l_line_rec.ato_line_id := l_line_rec.line_id;
		                    END IF;
		           END IF;
		     END IF;
             -- Populating ato line id for a standard ato item
    		 IF (l_line_rec.Item_Type_Code = 'STANDARD' AND
		         l_line_rec.ato_line_id IS NOT NULL) THEN
		           l_line_rec.ato_line_id := l_line_rec.line_id;
		     END IF;
             -- The px_line_rec is the image of original line. IF the parent is ato then
             -- child will be ato and ato line id will be populated. This condition is true
             -- for ato under PTO

     	     IF (l_line_rec.Item_Type_Code IN ('OPTION' ,'INCLUDED')AND --9775352
	             p_x_line_rec.split_from_line_id = l_line_rec.ato_line_id ) THEN
		            l_line_rec.ato_line_id := l_line_rec.line_id;
		     END IF;

             -- This code is commented since the scheduling is moved out of splits

         	 /*	IF l_line_rec.schedule_status_code IS NOT NULL THEN
		           l_line_rec.schedule_action_code := OE_ORDER_SCH_UTIL.OESCH_ACT_DEMAND;
		              l_line_rec.schedule_status_code := NULL;
		     END IF;*/
		     oe_line_util.convert_miss_to_null(p_x_line_rec => l_line_rec);
		     l_line_rec.operation := oe_globals.g_opr_create;
		     p_x_line_rec := l_line_rec;
       ELSIF (l_line_rec.line_id IS NOT NULL AND
     		 l_line_rec.line_id <> FND_API.G_MISS_NUM AND
		     l_line_rec.operation = oe_globals.g_opr_create) THEN
			     IF l_debug_level  > 0 THEN
			         oe_debug_pub.add(  'LINE ID :'||P_X_LINE_REC.LINE_ID ) ;
			         oe_debug_pub.add(  'SPLIT FROM LINE ID :'||P_X_LINE_REC.SPLIT_FROM_LINE_ID ) ;
			         oe_debug_pub.add(  'TOP MODEL LINE ID : '||P_X_LINE_REC.TOP_MODEL_LINE_ID ) ;
			     END IF;
			     IF  p_x_line_rec.top_model_line_id = p_x_line_rec.line_id THEN
			         l_line_rec.top_model_line_id  := NULL;
			     END IF;

		         l_line_rec.shipment_number := get_shipment_number(l_line_rec);
		         l_line_rec.top_model_line_id := p_x_line_rec.top_model_line_id;
                 IF  OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110508' AND
                     g_multiple_shipments = 'YES' AND
                     nvl(l_line_rec.source_document_type_id,0) <> 10 THEN --Bug 5435726
                          l_line_rec.orig_sys_shipment_ref :=  substr(p_x_line_rec.orig_sys_shipment_ref,0,instr(p_x_line_rec.orig_sys_shipment_ref,'.'))||l_line_rec.shipment_number;
                 ELSIF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL < '110508' AND
                       nvl(l_line_rec.source_document_type_id,0) <> 10 THEN --Bug 5435726
                    -- l_line_rec.orig_sys_line_ref := 'OE_ORDER_LINES_ALL'||l_line_rec.line_id;
                    --Changed for bug 4302022
          	      IF (p_x_line_rec.orig_sys_line_ref IS NULL OR
 		          p_x_line_rec.orig_sys_line_ref = FND_API.G_MISS_CHAR) THEN

                          l_line_rec.orig_sys_line_ref := 'OE_ORDER_LINES_ALL'||l_line_rec.line_id;
                       ELSE
                          OE_DEBUG_PUB.add('Orig Sys Line Ref was populated',1);
                          l_line_rec.orig_sys_line_ref := p_x_line_rec.orig_sys_line_ref;
                       END IF;
                 ELSIF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110508' AND
                       g_multiple_shipments = 'NO' AND
                       nvl(l_line_rec.source_document_type_id,0) <> 10 THEN --Bug 5435726
                    --  l_line_rec.orig_sys_line_ref := 'OE_ORDER_LINES_ALL'||l_line_rec.line_id;
                       --Changed for bug 4302022
          	      IF (p_x_line_rec.orig_sys_line_ref IS NULL OR
 		          p_x_line_rec.orig_sys_line_ref = FND_API.G_MISS_CHAR) THEN

                          l_line_rec.orig_sys_line_ref := 'OE_ORDER_LINES_ALL'||l_line_rec.line_id;
                       ELSE
                          OE_DEBUG_PUB.add('Orig Sys Line Ref was populated',1);
			  l_line_rec.orig_sys_line_ref := p_x_line_rec.orig_sys_line_ref;
                       END IF;

                 END IF;
		         p_x_line_rec := l_line_rec;
	   END IF;
   END IF;
   EXCEPTION
   WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg
               (    G_PKG_NAME ,
                    'Split_line'
               );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Default_Attributes;

PROCEDURE Split_Line
(p_x_line_rec      IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
 ,p_old_line_rec   IN OE_Order_PUB.Line_Rec_Type
) IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   NULL;
EXCEPTION
  WHEN OTHERS THEN
  IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     OE_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,'Split_line');
  END IF;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Split_Line;

Procedure Check_split_Course(p_x_line_tbl IN OUT NOCOPY OE_Order_Pub.Line_tbl_type,
				             p_x_line_adj_tbl IN OUT NOCOPY	OE_Order_Pub.Line_Adj_tbl_type,
                             p_x_line_scredit_tbl IN OUT NOCOPY	OE_Order_Pub.Line_scredit_Tbl_type)
IS
l_parent_ordered_quantity  NUMBER;
l_child_quantity           NUMBER := 0;
l_line_adj_tbl             OE_ORDER_PUB.Line_Adj_tbl_type;
l_line_tbl                 OE_Order_Pub.Line_tbl_type;
l_line_out_tbl                 OE_Order_Pub.Line_tbl_type;
l_line_rec                 OE_Order_Pub.Line_rec_type;
l_line_adj_temp_tbl        OE_Order_Pub.Line_Adj_tbl_type;
l_line_scredit_tbl         OE_Order_Pub.Line_scredit_Tbl_type;
l_line_scredit_temp_tbl    OE_Order_Pub.Line_scredit_Tbl_type;
l_adjustment_count         NUMBER := 0;
l_scredit_count            NUMBER := 0;
l_Split_line_Tbl           OE_SPLIT_UTIL.Split_line_Tbl;
l_split_count              NUMBER := 0;
l_miss_rec                 OE_Order_Pub.Line_rec_type := oe_order_pub.g_miss_line_rec;
l_sch_tbl                  OE_Order_Pub.Line_tbl_type;
l_sch_count                NUMBER := 0;
last_count                 NUMBER := 0;
l_return_status            VARCHAR2(30);
lfirst                     PLS_INTEGER;
l_order_date_type_code     VARCHAR2(20); -- 8706868
l_sales_order_id           NUMBER; -- 8706868
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTER CHECK SPLIT COURSE' ) ;
   END IF;
   l_line_tbl := p_x_line_tbl;
   IF oe_split_util.g_sch_recursion = 'FALSE' AND NOT g_non_prop_split THEN
      -- Loop Through Lines Table to find Split Action
      -- i := l_line_tbl.First;
      -- This Check is to make sure Split will not process any table
      -- that is not in sesequence. It will fail if there is a gap in the
      -- input table.
      IF l_line_tbl.count <> 0 THEN
		 lfirst := l_line_tbl.First;
	   	 IF lfirst <> 1 THEN
			GOTO END_1;
   		 END IF;
      END IF;
      FOR I IN 1..l_line_tbl.count LOOP
	  --While i is not null Loop

          IF l_debug_level  > 0
          THEN
             oe_debug_pub.add('OUT side the LOOP ORDERED QUANTITY IS => '|| l_line_tbl(I).ordered_quantity
                               || ' Count : '||I);
             oe_debug_pub.add('OUT side the LOOP ORD QTY IS :'|| l_line_tbl(I).ordered_quantity || ' Count : '
                               ||I ||' Operation : '||l_line_tbl(I).operation);
          end if;
    	  IF l_line_tbl(I).split_action_code = 'SPLIT' AND
	     l_line_tbl(I).operation = OE_GLOBALS.G_OPR_UPDATE
          THEN
             /* Added this condition to spuress the spliting of the line with zero quantiy.
                Bug: 3318920
                By: Srini
             */
             IF l_line_tbl(I).ordered_quantity = 0
             THEN
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'ORDERED QUANTITY IS INVALID with UPDATE OPER => '|| l_line_tbl(I).ordered_quantity ) ;
                END IF;
                FND_MESSAGE.SET_NAME('ONT','OE_SPLIT_WITH_ZERO_QTY');
                FND_MESSAGE.SET_TOKEN('QUANTITY',L_line_tbl(I).ordered_quantity);
                OE_MSG_PUB.ADD;
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'SPLIT- NOT ALLOWED TO UPDATE WITH QUANTITY ZERO' ) ;
                END IF;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
    	     oe_line_util.query_row(p_line_id => l_line_tbl(I).line_id,
                                    x_line_rec => l_line_rec);
     	     IF l_debug_level  > 0
             THEN
     	        oe_debug_pub.add(  'ITEM TYPE CODE : '|| L_LINE_REC.ITEM_TYPE_CODE ) ;
     	     END IF;
       	     IF  nvl(L_line_rec.model_remnant_flag,'N') <> 'Y'
             THEN
     		 IF  (L_line_rec.item_type_code <> 'STANDARD' AND
	              L_line_rec.item_type_code <> 'MODEL' AND
		      L_line_rec.Item_type_code <> 'KIT'  AND
		      NOT (nvl(L_line_rec.ato_line_id,-99) = l_line_rec.line_id AND L_line_rec.item_type_code = 'CLASS' ))
		 THEN
     		      IF l_debug_level  > 0 THEN
     			 oe_debug_pub.add(  'ITEM TYPE CODE INVALID => '|| L_LINE_REC.ITEM_TYPE_CODE ) ;
     		      END IF;
             	      FND_MESSAGE.SET_NAME('ONT','OE_INVALID_SPLIT_OPR');
	              FND_MESSAGE.SET_TOKEN('ITEMTYPE',L_line_rec.item_type_code);
              	      OE_MSG_PUB.ADD;
          	      IF l_debug_level  > 0 THEN
          	         oe_debug_pub.add(  'SPLIT- NOT ALLOWED THIS ITEMTYPE' ) ;
          	      END IF;
		         RAISE FND_API.G_EXC_ERROR;
	              END IF;
		 END IF;
                 oe_line_util.query_row(p_line_id  => l_line_tbl(I).line_id,
                                        x_line_rec => l_line_rec);
     		 l_parent_ordered_quantity := l_line_rec.ordered_quantity;
	     	 l_split_count := l_split_count + 1;
		 g_split_line_tbl(l_split_count).line_id := l_line_tbl(I).line_id;
		 g_split_line_tbl(l_split_count).quantity :=	l_line_tbl(I).ordered_quantity;
		 IF ( l_line_rec.line_set_id IS  NULL )
                 THEN
                      --l_line_tbl(I).line_set_id <> FND_API.G_MISS_NUM) THEN
		      IF l_debug_level  > 0 THEN
		         oe_debug_pub.add(  'ENTER CREATE LINE SET:' ) ;
		      END IF;
                      Oe_Set_Util.Create_Line_Set(p_x_line_rec => l_line_rec);
                      l_line_tbl(I).line_set_id := l_line_rec.line_set_id;
         	      oe_lot_serial_util.Set_Line_Set_ID (   p_Line_ID       => l_line_tbl(I).line_id
					                 ,   p_Line_Set_ID   => l_line_tbl(I).line_set_id);
		 ELSE
		      l_line_tbl(I).line_set_id := l_line_rec.line_set_id;
                 END IF;
     		 l_sch_count := l_sch_count + 1;
	       	 l_sch_tbl(l_sch_count) := l_line_tbl(I);
		 --8706868
		 -- Unreserve the line if warehouse being chabged and reservation is there.
		 IF NOT OE_GLOBALS.EQUAL(l_line_rec.ship_from_org_id, l_line_tbl(I).ship_from_org_id) AND
		       l_line_rec.schedule_ship_date is NOT NULL AND
                       NVL(l_line_tbl(I).SPLIT_SHIP_FROM,'N') ='Y' THEN -- 10338643
		       l_sales_order_id := OE_SCHEDULE_UTIL.Get_mtl_sales_order_id(l_line_rec.HEADER_ID);
		       OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => l_sales_order_id
                                           ,p_line_id   => l_line_rec.line_id
                                           ,p_org_id    => l_line_rec.ship_from_org_id
                                           ,p_order_quantity_uom => l_line_rec.order_quantity_uom
                                           ,x_reserved_quantity =>  l_line_rec.reserved_quantity
                                           ,x_reserved_quantity2 => l_line_rec.reserved_quantity2
                                           );
                      IF l_line_rec.reserved_quantity is not null THEN
		         OE_SCHEDULE_UTIL.Unreserve_Line
                                 (p_line_rec              => l_line_rec,
                                  p_quantity_to_unreserve => l_line_rec.reserved_quantity,
                                  p_quantity2_to_unreserve => l_line_rec.reserved_quantity2 , -- INVCONV
                                  x_return_status         => l_return_status);
				  oe_schedule_util.oe_split_rsv_tbl(MOD(l_line_rec.line_id,G_BINARY_LIMIT)).line_id :=l_line_rec.line_id;
                      END IF;

		 END IF;
		 IF l_line_rec.schedule_ship_date is NOT NULL AND
		    NOT OE_GLOBALS.EQUAL(l_line_rec.request_date, l_line_tbl(I).request_date) AND
                    NVL(l_line_tbl(I).SPLIT_REQUEST_DATE,'N') ='Y' AND -- 10338643
                    NVL(OE_SYS_PARAMETERS.value('RESCHEDULE_REQUEST_DATE_FLAG'),'Y') = 'Y'  THEN -- 12833832
		    l_order_date_type_code := NVL(oe_schedule_util.Get_Date_Type(l_line_rec.header_id),'SHIP');
		    IF l_order_date_type_code = 'SHIP' THEN
                       l_sch_tbl(l_sch_count).schedule_ship_date := l_line_tbl(I).request_date;
                    ELSE
                       l_sch_tbl(l_sch_count).schedule_arrival_date := l_line_tbl(I).request_date;
		    END IF;
		 END IF;
		 -- 8706868
     		 l_child_quantity := l_line_tbl(I).ordered_quantity;
	         IF l_debug_level  > 0 THEN
	            oe_debug_pub.add(  'PARENT QUANTITY:'|| L_PARENT_ORDERED_QUANTITY ) ;
		    oe_debug_pub.add(  'CHILD_QUANTITY:'|| L_CHILD_QUANTITY ) ;
	         END IF;
     	         l_line_scredit_tbl.delete;
       		 oe_line_scredit_util.query_rows( p_line_id          => l_line_tbl(I).line_id,
						  x_line_scredit_tbl => l_line_scredit_tbl);
     		 --j := l_line_tbl.First;
	     	 --While j is not null Loop
		 FOR J IN 1..l_Line_Tbl.Count LOOP
                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add('CREATE ORDERED QUANTITY IS INVALID => '|| l_line_tbl(J).ordered_quantity);
                        oe_debug_pub.add('OUT side the LOOP ORD QTY IS :'|| l_line_tbl(J).ordered_quantity || ' Count : '
                                          ||J ||' Operation : '||l_line_tbl(J).operation);
                     END if;
		     IF (l_Line_Tbl(J).split_from_line_id = l_line_tbl(I).Line_Id   AND
		         l_line_tbl(J).operation = OE_GLOBALS.G_OPR_CREATE )
		     THEN
                         /* Added this condition to spuress the spliting of the line with zero quantiy.
                            Bug: 3318920
                            By: Srini
                         */
                         IF l_line_tbl(J).ordered_quantity = 0
                         THEN
                            IF l_debug_level  > 0 THEN
                               oe_debug_pub.add('ORDERED QUANTITY IS INVALID with CREATE OPER=> '
                                                 ||l_line_tbl(J).ordered_quantity ) ;
                            END IF;
                            FND_MESSAGE.SET_NAME('ONT','OE_SPLIT_WITH_ZERO_QTY');
                            FND_MESSAGE.SET_TOKEN('QUANTITY',L_line_tbl(J).ordered_quantity);
                            OE_MSG_PUB.ADD;
                            IF l_debug_level  > 0 THEN
                               oe_debug_pub.add(  'SPLIT- NOT ALLOWED TO CREATE WITH QUANTITY ZERO' ) ;
                            END IF;
                            RAISE FND_API.G_EXC_ERROR;
                         END IF;
	                 g_qry_out_rec := l_line_tbl(J);
		         OE_Split_Util.Default_Attributes (p_x_line_rec    => g_qry_out_rec
                                                          ,p_old_line_rec  => l_line_tbl(J));

 	                 l_line_tbl(J) := g_qry_out_rec;
             		 l_split_count := l_split_count + 1;
			 g_split_line_tbl(l_split_count).split_from_line_id := l_line_tbl(J).split_from_line_id;
			 g_split_line_tbl(l_split_count).quantity :=	l_line_tbl(J).ordered_quantity;
			 g_split_line_tbl(l_split_count).line_id :=	l_line_tbl(J).line_id;
			 l_line_tbl(J).line_set_id := l_line_tbl(I).line_set_id;
			 l_sch_count := l_sch_count + 1;
			 l_sch_tbl(l_sch_count) := l_line_tbl(J);
    			 l_child_quantity := l_child_quantity +	l_line_tbl(J).ordered_quantity;
		         IF l_debug_level  > 0 THEN
		            oe_debug_pub.add(  'CHILD_QUANTITY2:'|| L_CHILD_QUANTITY ) ;
		         END IF;
                	 -- Copy Sales Credits for the new line
           	         FOR SCRD_REC IN 1..L_line_Scredit_tbl.count LOOP
          	             l_scredit_count := l_scredit_count + 1;
			     l_line_scredit_temp_tbl(l_scredit_count):= L_line_scredit_tbl(SCRD_REC);
            		     l_line_scredit_temp_tbl(l_scredit_count).sales_credit_id:= FND_API.G_MISS_NUM;
			     l_line_scredit_temp_tbl(l_scredit_count).Operation := OE_GLOBALS.G_OPR_CREATE;
			     l_line_scredit_temp_tbl(l_scredit_count).line_id := l_line_tbl(J).line_id;
        		 END LOOP;
  		     END IF; -- IF split from line id and operation create
					--j:= l_line_tbl.next(j);
       	         END LOOP; -- Loop for Insert on line table
		 -- Check If quantities sum up to total ordered quantity
        	 IF l_debug_level  > 0 THEN
        	    oe_debug_pub.add(  'PARENT QUANTITY3:'|| L_PARENT_ORDERED_QUANTITY ) ;
		    oe_debug_pub.add(  'CHILD_QUANTITY3:'|| L_CHILD_QUANTITY ) ;
        	 END IF;
		 IF l_parent_ordered_quantity <> l_child_quantity  THEN
		    IF l_debug_level  > 0 THEN
		       oe_debug_pub.add(  'PARENT QUANTITY3:'|| L_PARENT_ORDERED_QUANTITY ) ;
		       oe_debug_pub.add(  'CHILD_QUANTITY3:'|| L_CHILD_QUANTITY ) ;
		    END IF;
                    FND_MESSAGE.SET_NAME('ONT','OE_INVALID_SPLIT_QTY');
             	    OE_MSG_PUB.ADD;
            	    IF l_debug_level  > 0 THEN
            	       oe_debug_pub.add(  'RAJ:SPLIT-QUNATITES NOT EQUAL' ) ;
            	    END IF;
	    	    RAISE FND_API.G_EXC_ERROR;
		 END IF;
		 l_child_quantity := 0;
        	 -- Call service API to get service Lines
		 Get_Service_Lines(p_line_tbl => l_line_tbl,
		                   x_line_tbl => l_line_out_tbl,
				   g_split_line_tbl => g_split_line_tbl);

			l_line_tbl := l_line_out_tbl; -- Swapping can be fixed. Opportunity to optimize

                 -- Call Models API to get all Option/Class lines
		 Last_count := l_line_tbl.count;
    		 IF ((l_line_rec.item_type_code = 'MODEL') OR
		     (l_line_rec.item_type_code = 'KIT') OR
		     (l_line_rec.item_type_code = 'CLASS' AND l_line_rec.ato_line_id = l_line_rec.line_id))
                 THEN
		     IF l_debug_level  > 0 THEN
			oe_debug_pub.add(  'INTO MODEL AND CLASS IF' ) ;
		        oe_debug_pub.add(  'REMNANT FLAG : '||L_LINE_TBL ( I ) .MODEL_REMNANT_FLAG ) ;
		     END IF;
    		     IF (nvl(l_line_rec.model_remnant_flag,'N') <> 'Y') OR
		        (l_line_rec.item_type_code = 'CLASS' AND l_line_rec.ato_line_id = l_line_rec.line_id)
                     THEN
		         IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'BEFORE CALLING CASCADE PROP' ) ;
			 END IF;
         	         Last_count := l_line_tbl.count+1;
		         Cascade_Proportional_split(p_line_tbl => l_line_tbl,
			                            parent_ordered_quantity => l_parent_ordered_quantity,
						    p_index => I,
						    x_line_tbl => l_line_out_tbl,
						    x_line_adj_tbl =>p_x_line_adj_tbl,
						    x_line_scredit_tbl => p_x_line_scredit_tbl);
				l_line_tbl := l_line_out_tbl; -- Swapping can be fixed, opportunity to optimize

                    	 IF  Last_count <> l_line_tbl.count
                         THEN
			     FOR M IN Last_count+1 .. l_line_tbl.count LOOP
			         IF (l_line_tbl(M).item_type_code = 'OPTION' OR
				     l_line_tbl(M).item_type_code = 'CLASS')
                                 THEN
			             l_sch_count := l_sch_count + 1;
			             l_sch_tbl(l_sch_count) := l_line_tbl(M);
			         END IF;
			     END LOOP;
			 END IF;
		     END IF;
		 END IF;
         	 -- Call scheduling
                 -- This call to scheduling is commented to fix splitting of reservations
                 -- issue. The call is moved to post line loop and is in control of scheduling
        		OE_SPLIT_UTIL.G_SPLIT_ACTION := TRUE;
                 /*	OE_ORDER_SCH_UTIL.Split_Scheduling(p_line_tbl => l_sch_tbl,
							   x_line_tbl => l_sch_tbl,
							   x_return_status => l_return_status);
            	        IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			    oe_debug_pub.add('Into split scheduling unexpected failure');
                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
			    oe_debug_pub.add('Into split scheduling expected failure');
                            RAISE FND_API.G_EXC_ERROR;
                 END IF; */
     		 -- Delete split line tbl for this line
	         g_split_line_tbl.delete;
		 l_split_count := 0;
	  END IF; -- Operation Update
          --i:= l_line_tbl.next(i);
      END LOOP ; -- Parent Loop
		l_scredit_count := 0;
        --  Populate  and Sales Credits
    	IF  l_line_scredit_temp_tbl.count > 0 THEN
    		l_scredit_count := p_x_line_scredit_tbl.count + 1;
				FOR I in 1..l_line_scredit_temp_tbl.count LOOP
    				p_x_line_scredit_tbl(l_scredit_count) := l_line_scredit_temp_tbl(I);
					l_scredit_count := l_scredit_count + 1;
				END LOOP;
		END IF;
        NULL;
		FOR G IN 1..l_sch_tbl.count	LOOP
			FOR H in 1..l_line_tbl.count LOOP
			    IF  l_line_tbl(H).line_id = l_sch_tbl(G).line_id THEN
			        l_line_tbl(H) := l_sch_tbl(G);
			        EXIT;
			    END IF;
			END LOOP;
		END LOOP;
		p_X_line_Tbl := l_line_tbl;
		-- Update Drop Ship Sources
		--Update_Drop_Ship_Source(p_line_tbl => X_Line_Tbl);
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SPLIT TABLE PICTURE IS - ' ) ;
		END IF;
		--i:= l_line_tbl.First;
		FOR I in 1..l_line_tbl.count LOOP
		    --While i is not null loop
		    IF l_debug_level  > 0 THEN
		        oe_debug_pub.add(  L_LINE_TBL ( I ) .ORDERED_QUANTITY , 5 ) ;
    		        oe_debug_pub.add(  L_LINE_TBL ( I ) .OPERATION , 5 ) ;
	    	        oe_debug_pub.add(  L_LINE_TBL ( I ) .ITEM_TYPE_CODE , 5 ) ;
		        oe_debug_pub.add(  L_LINE_TBL ( I ) .LINE_ID , 5 ) ;
		        oe_debug_pub.add(  L_LINE_TBL ( I ) .LINE_SET_ID , 5 ) ;
		        oe_debug_pub.add(  L_LINE_TBL ( I ) .SPLIT_ACTION_CODE , 5 ) ;
                        oe_debug_pub.add(  L_LINE_TBL ( I ) .REQUEST_DATE , 5 ) ;
			oe_debug_pub.add(  L_LINE_TBL ( I ) .SHIP_FROM_ORG_ID , 5 ) ;
			oe_debug_pub.add(  'Link To Line id '||L_LINE_TBL ( I ) .LINK_TO_LINE_ID , 5) ;
		    END IF;
		    --i:= l_line_tbl.next(i);
		END LOOP;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'EXIT CHECK SPLIT COURSE' ) ;
		END IF;
	END IF;
	<<END_1>>
	NULL;
EXCEPTION
WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
       OE_MSG_PUB.Add_Exc_Msg
               (    G_PKG_NAME ,
                    'Check_Split_Course'
               );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Check_Split_Course;

Procedure Cascade_non_proportional_Split(p_x_line_tbl    IN OUT NOCOPY	OE_ORDER_PUB.line_tbl_type,
				         x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2) IS
l_line_id                NUMBER;
l_control_rec            OE_GLOBALS.Control_Rec_Type;
l_api_name               CONSTANT VARCHAR2(30)   := 'Cascade Non Proportonal splits';
l_return_status          VARCHAR2(30);
l_old_line_tbl           OE_ORDER_PUB.Line_Tbl_Type;
l_old_Line_Scredit_tbl   OE_Order_PUB.Line_Scredit_Tbl_Type;
l_Line_Scredit_tbl       OE_Order_PUB.Line_Scredit_Tbl_Type;
l_Line_Scredit_temp_tbl  OE_Order_PUB.Line_Scredit_Tbl_Type;
l_line_tbl               OE_ORDER_PUB.line_tbl_type := p_x_line_tbl;
l_line_out_tbl               OE_ORDER_PUB.line_tbl_type;
l_model_ratio            NUMBER;
l_line_rec               OE_ORDER_PUB.line_rec_type;
l_option_line            OE_ORDER_PUB.line_rec_type;
l_tbl_count              NUMBER := 0;
l_min_model              NUMBER := 0;
l_max_ship_model         NUMBER := 0;
l_temp_min_model         NUMBER := 0;
l_temp_max_model         NUMBER := 0;
x_msg_count              NUMBER;
x_msg_data               VARCHAR2(2000);
l_model_flag             VARCHAR2(1) := 'Y';
l_complete_shipment      VARCHAR2(1) ;
l_scredit_count          NUMBER := 0;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;
IF l_debug_level > 0 THEN
   OE_DEBUG_PUB.add('Entering Cascade_Non_Proportional_split() ',1);
   OE_DEBUG_PUB.add('Table count : '||p_x_line_tbl.count,5) ;
END IF;

FOR I in 1 .. l_line_tbl.count LOOP
    IF  l_line_tbl(I).ordered_quantity < 0 THEN
	g_over_shipment := true;
    END IF;
    IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Line id : '||l_line_tbl(i).line_id,5) ;
           oe_debug_pub.add('Operation : ' ||l_line_tbl(i).operation,5) ;
           oe_debug_pub.add('Ordered quantity : '||l_line_tbl(i).ordered_quantity,5) ;
           oe_debug_pub.add('Item type code : ' ||l_line_tbl(i).item_type_code,5) ;
           oe_debug_pub.add('Shipped quantity : '||l_line_tbl(i).shipped_quantity,5) ;
    END IF;
END LOOP;

oe_line_util.query_row(p_line_id => l_line_tbl(1).line_id, x_line_rec => l_line_rec);

IF (l_line_rec.item_type_code = 'MODEL' OR
    l_line_rec.item_type_code = 'KIT') THEN
    IF  l_line_rec.shippable_flag = 'Y' THEN
        l_tbl_count := 1 ;
    ELSE
 	l_tbl_count := 2;
    END IF;
ELSE
    oe_line_util.query_row(p_line_id => l_line_tbl(1).top_model_line_id, x_line_rec => l_line_rec);
    l_model_flag := 'N';
    l_tbl_count := 1;
END IF;

IF NOT g_over_shipment THEN

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Before calling check complete shipment',5) ;
   END IF;
   l_complete_shipment := Check_Complete_shipment( p_line_tbl => l_line_tbl, p_line_id => l_line_rec.line_id );
   IF  (l_model_flag = 'N' AND  nvl(l_line_rec.shippable_flag,'N') = 'Y' ) THEN
	  l_max_ship_model := 0;
   END IF;

   --Begin Added for the bug #3474977
   if l_model_flag = 'N' AND l_line_rec.shippable_flag = 'Y' THEN
      l_complete_shipment := 'N';
   end if;
   --End of the bug fix 3474977
   FOR I in l_tbl_count .. L_Line_tbl.count LOOP
       oe_line_util.query_row(p_line_id => l_line_tbl(I).line_id, x_line_rec => l_option_line);
       l_model_ratio := l_option_line.ordered_quantity/l_line_rec.ordered_quantity;
       l_temp_min_model := Floor(l_line_tbl(I).ordered_quantity/l_model_ratio);
       IF  l_complete_shipment = 'Y' THEN
	   l_temp_max_model :=  Floor(l_line_tbl(I).shipped_quantity/l_model_ratio);
	   IF  I=1 THEN
	       l_max_ship_model := l_temp_max_model;
           ELSE
	       IF  l_temp_max_model < l_max_ship_model THEN
		   l_max_ship_model := l_temp_max_model;
	       END IF;
	   END IF;
       END IF;
       IF  I = 1 THEN
	   l_min_model := l_temp_min_model;
       ELSE
	   IF  l_temp_min_model < l_min_model THEN
	       l_min_model := l_temp_min_model;
	   END IF;
       END IF;
   END LOOP;

END IF;

IF  g_over_shipment THEN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Over shipment true' , 1 ) ;
    END IF;
    l_min_model := 0;
    l_max_ship_model := 0;
END IF;
g_min_model := l_min_model;
g_max_model := l_max_ship_model;
IF l_debug_level  > 0 THEN
   oe_debug_pub.add('Min model : '||l_min_model,5 ) ;
   oe_debug_pub.add('Max shipped model : '||l_max_ship_model,5) ;
END IF;
IF g_min_model = 0 THEN
   g_remnant_only := TRUE;
END IF;
IF  l_model_flag = 'Y' THEN
    Get_Model_Configuration(p_line_tbl => l_line_tbl, x_line_tbl => l_line_out_tbl);
		l_line_tbl := l_line_out_tbl;
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Minimum model : '||l_min_model,5);
       oe_debug_pub.add('Minimum model : '||g_min_model,5);
    END IF;
ELSE
    Get_non_Model_Configuration(p_line_tbl => l_line_tbl, x_line_tbl => l_line_out_tbl);
		l_line_tbl := l_line_out_tbl;
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Minimum model : '|| l_min_model,5);
       oe_debug_pub.add('Minimum model : '|| g_min_model,5);
    END IF;
END IF;
g_remnant_only := FALSE;
-- Call Scheduling
-- This call to scheduling is commented to fix splitting of reservations
-- issue. The call is moved to post line loop and is in control of scheduling
IF l_debug_level  > 0 THEN
   oe_debug_pub.add('Scheduling call has been disabled',5);
END IF;
/*OE_ORDER_SCH_UTIL.Split_Scheduling(p_line_tbl => l_line_tbl,
                                     x_line_tbl => l_line_tbl,
				     x_return_status => l_return_status);*/
FOR I in 1 .. l_line_tbl.count LOOP
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Line ID          : '||l_line_tbl(I).line_id,5);
       oe_debug_pub.add('Operation        : '||l_line_tbl(I).operation,5) ;
       oe_debug_pub.add('Ordered Quantity : '||l_line_tbl(I).ordered_quantity,5) ;
       oe_debug_pub.add('Item Type Code   : '||l_line_tbl(I).item_type_code,5) ;
       oe_debug_pub.add('Remnant Flag     : '||nvl(l_line_tbl(I).model_remnant_flag,'N'),5) ;
    END IF;
    IF  l_line_tbl(I).model_remnant_flag = 'Y' THEN
        l_line_tbl(I).split_by := 'SYSTEM';
        l_line_tbl(I).ship_set_id := NULL;
        l_line_tbl(I).arrival_set_id := NULL;
    END IF;
END LOOP;
-- Get Sales Credits
FOR I in 1 .. l_line_tbl.count LOOP
    IF  l_line_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE THEN
	oe_line_scredit_util.query_rows( p_line_id => l_line_tbl(I).split_from_line_id,
	                                 x_line_scredit_tbl =>  l_line_scredit_temp_tbl);
	l_scredit_count := l_line_scredit_tbl.count + 1;
	FOR Scr IN 1 .. l_line_scredit_temp_tbl.count	LOOP
	    l_line_scredit_tbl(l_scredit_count) :=	l_line_scredit_temp_tbl(Scr);
	    l_line_scredit_tbl(l_scredit_count).operation := OE_GLOBALS.G_OPR_CREATE;
	    l_line_scredit_tbl(l_scredit_count).line_id := l_line_tbl(I).line_id;
	    l_line_scredit_tbl(l_scredit_count).sales_credit_id := fnd_api.g_miss_num;
	END LOOP;
    END IF;
END LOOP;
-- get Service Lines
Get_nonprop_Service_Lines(p_line_tbl => l_line_tbl, x_line_tbl => l_line_out_tbl);

l_line_tbl := l_line_out_tbl; -- Swaping, opportunity for future optimization.

/* Populate line set id for all the option split lines from its parent bug 2103004 */
Create_Line_Set_For_Options(p_x_line_tbl => l_line_tbl);
p_x_line_tbl := l_line_tbl;
g_non_prop_split := TRUE;
OE_CONFIG_PVT.OECFG_VALIDATE_CONFIG := 'N' ;
l_control_rec.process := FALSE;
l_control_rec.controlled_operation := TRUE;
l_control_rec.check_security := FALSE;
l_control_rec.change_attributes := TRUE;
l_control_rec.default_attributes := TRUE;
OE_SPLIT_UTIL.G_SPLIT_ACTION := TRUE;
IF l_debug_level  > 0 THEN
   oe_debug_pub.add('Before calling process order in splits',1) ;
END IF;
oe_order_pvt.Lines
  (   p_validation_level  =>    FND_API.G_VALID_LEVEL_NONE
  ,   p_control_rec       => l_control_rec
  ,   p_x_line_tbl         =>  p_x_line_tbl
  ,   p_x_old_line_tbl    =>  l_old_line_tbl
  ,   x_return_status     => l_return_status
  );
IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Split Line: Process order returns unexpected error : '||sqlerrm,1) ;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Split Line: Process order returns execution error : '||sqlerrm,1) ;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
END IF;

oe_order_pvt.Line_Scredits
  (   p_validation_level  =>    FND_API.G_VALID_LEVEL_NONE
  ,   p_control_rec       => l_control_rec
  ,   p_x_line_Scredit_tbl  =>  l_Line_Scredit_tbl
  ,   p_x_old_line_Scredit_tbl   =>  l_old_line_Scredit_tbl
  ,   x_return_status     => l_return_status
  );
IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
END IF;
OE_Order_PVT.Process_Requests_And_Notify
          ( p_process_requests     => TRUE
          , p_notify               => FALSE    --lchen
          , x_return_status        => l_return_status
          , p_line_tbl             => l_line_tbl
          , p_old_line_tbl         => l_old_line_tbl
          , p_line_scredit_tbl     => l_Line_Scredit_tbl
          , p_old_line_scredit_tbl =>  l_old_line_Scredit_tbl
          );
g_non_prop_split := FALSE;
OE_CONFIG_PVT.OECFG_VALIDATE_CONFIG := 'Y' ;
OE_SPLIT_UTIL.G_SPLIT_ACTION := FALSE;
IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
   RAISE FND_API.G_EXC_ERROR;
END IF;
EXCEPTION
WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
       OE_MSG_PUB.Add_Exc_Msg
               (    G_PKG_NAME ,
                    'Cascade_Non_Proportional_Split'
               );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Cascade_Non_Proportional_Split;

PROCEDURE Record_line_History
(   p_line_rec                      IN  OE_Order_PUB.Line_Rec_Type
)IS
l_return_status  varchar2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
OE_CHG_ORDER_PVT.RecordLineHist
                        (  p_line_id => p_line_rec.line_id
                           ,p_hist_type_code => 'SPLIT'
                           ,p_reason_code => p_line_rec.change_reason
                           ,p_comments => p_line_rec.change_comments
                           ,x_return_status => l_return_status);

IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
END IF;
EXCEPTION
WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
       OE_MSG_PUB.Add_Exc_Msg
               (    G_PKG_NAME ,
                    'Record_Line_History'
               );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
End Record_line_History;


Procedure Add_To_Fulfillment_Set(p_line_rec IN oe_order_pub.line_rec_type) IS
-- 4925992
l_top_model_line_id NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

Cursor C1 is SELECT SET_ID
             FROM   OE_LINE_SETS
             WHERE  LINE_ID = p_line_rec.split_from_line_id;
BEGIN
IF  p_line_rec.split_from_line_id IS NOT NULL THEN
    FOR C1rec IN C1 LOOP
       -- 4925992
       IF p_line_rec.line_id = p_line_rec.top_model_line_id
          AND p_line_rec.operation <> 'CREATE'
       THEN
          l_top_model_line_id := p_line_rec.line_id;
       ELSE
          l_top_model_line_id := NULL;
       END IF;
       oe_set_util.Create_Fulfillment_Set(p_line_id           => p_line_rec.line_id,
                                          p_top_model_line_id => l_top_model_line_id,
                                          p_set_id            => c1rec.set_id);
    END LOOP;
END IF;
EXCEPTION
    WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg
       (G_PKG_NAME,'Add to Fulfillment Set');
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
End Add_To_Fulfillment_Set;

/* Defer Split ER Changes Start */
PROCEDURE Defer_Split
(  Errbuf	                      OUT NOCOPY VARCHAR2
,  retcode	                      OUT NOCOPY VARCHAR2
,  P_line_id                          IN VARCHAR DEFAULT NULL
)
IS

-- Cursor Decleration

 l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
 l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
 l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
 l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
 l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
 l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
 l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
 l_x_Action_Request_tbl        OE_Order_PUB.Request_Tbl_Type;
 l_x_Lot_Serial_Tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
 l_x_Header_price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
 l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
 l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
 l_x_Line_price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type;
 l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type;
 l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
 l_x_Header_Payment_tbl        OE_Order_PUB.Header_Payment_Tbl_Type;
 l_x_Line_Payment_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
 l_control_rec                 OE_GLOBALS.Control_Rec_Type;
 l_debug_level CONSTANT        NUMBER := oe_debug_pub.g_debug_level;
 l_line_conc_rec               OE_Split_Util.Split_Line_Rec_Type;
 l_line_conc_tbl               OE_Split_Util.Split_Line_Tbl_Type;
 l_rec_count                   number;
 l_return_status               VARCHAR2(1);
 l_msg_data                    VARCHAR2(2000);
 l_msg_count                   NUMBER;
 l_msg_total                   NUMBER;
 l_count                       NUMBER := 0;

 l_ord_qty_sum                 NUMBER := 0;
 l_ord_qty2_sum                NUMBER := 0;
 l_line_id                     NUMBER;
 l_orig_ord_qty                NUMBER := 0;
 l_orig_ord_qty2               NUMBER := 0;
 l_process_add_attributes      BOOLEAN :=FALSE;
 l_init_line_id		       NUMBER;
 l_org_id		       Number;
 --10278858
 l_org_request_date            DATE;
 l_org_ship_from_org_id        NUMBER;
 l_org_ship_to_org_id          NUMBER;

  CURSOR c_split_details IS
  SELECT * FROM oe_line_split_details
  WHERE  line_id = l_init_line_id
  AND    request_id = FND_GLOBAL.CONC_REQUEST_ID
  FOR UPDATE NOWAIT;


BEGIN
  oe_debug_pub.add('Entering Procedure OE_Split_Util.Defer_Split', 1);
   l_init_line_id :=to_number(p_line_id);

   select org_id
   into l_org_id
   from oe_order_lines_all
   where line_id=l_init_line_id;

   MO_GLOBAL.set_policy_context('S',l_org_id);
   OE_GLOBALS.Set_Context();


  Retcode := 0;
  Errbuf := NULL;
  OE_MSG_PUB.Initialize;
  l_msg_total := 0;

  BEGIN
  OPEN c_split_details;
  FETCH c_split_details BULK COLLECT
  INTO l_line_conc_tbl;
  CLOSE c_split_details;
  EXCEPTION
  WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
  oe_debug_pub.add('record_lock exception in Oe_Split_Util.Defer_Split',1);
  Retcode := 2;
  errbuf := sqlerrm;
  raise;
  END;

  select count(*) into l_count
  from   oe_line_split_details where line_id = l_init_line_id
  AND    request_id = FND_GLOBAL.CONC_REQUEST_ID;

  IF l_count = 0 THEN
    Fnd_Message.Set_Name('ONT','OE_CANCEL_SPLIT_SUCCESS');
    Fnd_Message.Set_Token('REQUEST_ID',FND_GLOBAL.CONC_REQUEST_ID);
    OE_Msg_Pub.Add;
    FND_FILE.put_line(FND_FILE.output,OE_MSG_PUB.Get(OE_MSG_PUB.G_LAST,FND_API.G_FALSE));
    RETURN;
  END IF;


  IF l_count > 1 THEN

  SELECT sum(ORDERED_QUANTITY), sum(ORDERED_QUANTITY2)
  INTO   l_ord_qty_sum, l_ord_qty2_sum
  FROM   oe_line_split_details
  WHERE  line_id = l_init_line_id
  AND    request_id = FND_GLOBAL.CONC_REQUEST_ID;

  SELECT ordered_quantity, ordered_quantity2
  INTO   l_orig_ord_qty, l_orig_ord_qty2
  FROM   oe_order_lines_all
  WHERE  open_flag = 'Y'
  AND    line_id = l_init_line_id;

  IF l_orig_ord_qty > 0 AND l_ord_qty_sum <> l_orig_ord_qty THEN
    FND_MESSAGE.SET_NAME('ONT','OE_UI_SPLIT_UNEQUAL_QTY');
    OE_MSG_PUB.ADD;
    oe_debug_pub.add('Total shipment quantity must equal original quantity',1);
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_orig_ord_qty2 > 0 AND (l_ord_qty2_sum <> l_orig_ord_qty2) THEN
    FND_MESSAGE.SET_NAME('ONT','OE_UI_SPLIT_UNEQUAL_QTY');
    OE_MSG_PUB.ADD;
    oe_debug_pub.add('Total shipment quantity must equal original quantity',1);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

/* OPEN c_split_details;
  FETCH c_split_details BULK COLLECT --moved this statement to the top.
    INTO l_line_conc_tbl LIMIT 100;
  CLOSE c_split_details;*/

  IF l_line_conc_tbl.count > 0 then
    FOR i IN l_line_conc_tbl.FIRST .. l_line_conc_tbl.LAST LOOP
      IF i = 1 THEN
        IF l_line_conc_tbl(i).line_id IS NOT NULL THEN
          l_line_id := l_line_conc_tbl(i).line_id;
	    IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(' Query Line for Split'||l_line_conc_tbl(i).LINE_ID,3) ;
	    END IF;
          l_x_line_tbl(i).line_id := l_line_conc_tbl(i).line_id;
          OE_Line_Util.Lock_Row
          ( x_return_status         => l_return_status
          , p_x_line_rec            => l_x_line_tbl(i)
          , p_line_id               => l_line_conc_tbl(i).line_id);

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          oe_debug_pub.add('After Query Line for Split',3) ;
	  --10278858
          l_org_request_date  := l_x_line_tbl(i).request_date;
          l_org_ship_from_org_id  := l_x_line_tbl(i).ship_from_org_id;
          l_org_ship_to_org_id  := l_x_line_tbl(i).ship_to_org_id;

        END IF;
	  l_x_line_tbl(i).line_id := l_line_conc_tbl(i).line_id;
        l_x_line_tbl(i).split_action_code := 'SPLIT';
        IF l_line_conc_tbl(i).split_by = 'SCHEDULER' THEN
          l_x_line_tbl(i).split_by := 'SYSTEM';
	  l_x_line_tbl(i).request_id := FND_GLOBAL.CONC_REQUEST_ID;
        ELSE
          l_x_line_tbl(i).split_by := 'USER';
	  l_x_line_tbl(i).request_id := FND_GLOBAL.CONC_REQUEST_ID;
        END IF;
        l_x_line_tbl(i).operation := OE_GLOBALS.G_OPR_UPDATE;
        IF l_debug_level > 0 THEN
          OE_DEBUG_PUB.add('Audit Trail Reason Code being passed as '||
                                                  l_line_conc_tbl(i).change_reason_code,1);
        END IF;
        l_x_line_tbl(i).change_reason := l_line_conc_tbl(i).change_reason_code;
        l_x_line_tbl(i).change_comments := l_line_conc_tbl(i).change_reason_comment;
      ELSE
        IF l_line_id is not null then
          l_x_line_tbl(i).split_from_line_id := l_line_id;
	END IF;
        l_x_line_tbl(i).operation := OE_GLOBALS.G_OPR_CREATE;
        IF l_line_conc_tbl(i).split_by = 'SCHEDULER' THEN
           l_x_line_tbl(i).split_by := 'SYSTEM';
	   l_x_line_tbl(i).request_id := FND_GLOBAL.CONC_REQUEST_ID;
        ELSE
           l_x_line_tbl(i).split_by := 'USER';
	   l_x_line_tbl(i).request_id := FND_GLOBAL.CONC_REQUEST_ID;
        END IF;
      END IF;
      l_x_line_tbl(i).ordered_quantity := l_line_conc_tbl(i).ordered_quantity;
      l_x_line_tbl(i).ordered_quantity2 := l_line_conc_tbl(i).ordered_quantity2;
      --8706868 Start
      IF l_line_conc_tbl(i).ship_to_org_id IS NOT NULL THEN
         IF NVL(l_x_line_tbl(i).ship_to_org_id,-1) <>
                                        NVL(l_line_conc_tbl(i).ship_to_org_id,-1) THEN
            l_x_line_tbl(i).ship_to_org_id := l_line_conc_tbl(i).ship_to_org_id;
	    --10278858
            IF l_x_line_tbl(i).ship_to_org_id <> l_org_ship_to_org_id THEN
               l_x_line_tbl(i).SPLIT_SHIP_TO := 'Y';
            END IF;
            --  l_process_add_attributes := TRUE;
         END IF;
      END IF;

      IF l_line_conc_tbl(i).request_date IS NOT NULL THEN
         IF NVL(l_x_line_tbl(i).request_date,SYSDATE) <>
                                     NVL(l_line_conc_tbl(i).request_date,SYSDATE) THEN
            l_x_line_tbl(i).request_date := l_line_conc_tbl(i).request_date;
	    --10278858
            IF l_x_line_tbl(i).request_date <> l_org_request_date THEN
              l_x_line_tbl(i).SPLIT_REQUEST_DATE := 'Y';
            END IF;
            -- l_process_add_attributes := TRUE;
         END IF;
      END IF;

      IF l_line_conc_tbl(i).ship_from_org_id IS NOT NULL THEN
         IF NVL(l_x_line_tbl(i).ship_from_org_id,-1) <>
                                      NVL(l_line_conc_tbl(i).ship_from_org_id,-1) THEN
           l_x_line_tbl(i).ship_from_org_id := l_line_conc_tbl(i).ship_from_org_id;
           l_x_line_tbl(i).subinventory := null;
	   --10278858
           IF l_x_line_tbl(i).ship_from_org_id <> l_org_ship_from_org_id THEN
              l_x_line_tbl(i).SPLIT_SHIP_FROM := 'Y';
           END IF;
           -- l_process_add_attributes := TRUE;
         END IF;
      END IF;
      --8706868 End
    END LOOP;
    oe_debug_pub.add('From Defer Split - Calling Process Order',1) ;

    Oe_Order_Pvt.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => l_msg_count
    ,   x_msg_data                    => l_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                => l_x_header_rec
    ,   p_x_Header_Adj_tbl            => l_x_Header_Adj_tbl
    ,   p_x_header_price_att_tbl      => l_x_header_price_att_tbl
    ,   p_x_Header_Adj_att_tbl        => l_x_Header_Adj_att_tbl
    ,   p_x_Header_Adj_Assoc_tbl      => l_x_Header_Adj_Assoc_tbl
    ,   p_x_Header_Scredit_tbl        => l_x_Header_Scredit_tbl
    ,   p_x_Header_Payment_tbl        => l_x_Header_Payment_tbl
    ,   p_x_line_tbl                  => l_x_line_tbl
    ,   p_x_Line_Adj_tbl              => l_x_Line_Adj_tbl
    ,   p_x_Line_Price_att_tbl        => l_x_Line_Price_att_tbl
    ,   p_x_Line_Adj_att_tbl          => l_x_Line_Adj_att_tbl
    ,   p_x_Line_Adj_Assoc_tbl        => l_x_Line_Adj_Assoc_tbl
    ,   p_x_Line_Scredit_tbl          => l_x_Line_Scredit_tbl
    ,   p_x_Line_Payment_tbl          => l_x_Line_Payment_tbl
    ,   p_x_action_request_tbl        => l_x_Action_Request_tbl
    ,   p_x_lot_serial_tbl            => l_x_lot_serial_tbl

    );

  END IF;
  oe_debug_pub.add('From Defer Split - After Calling Process Order',1) ;

  l_msg_total := l_msg_total + l_msg_count;

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_x_line_tbl.count > 0 THEN
    l_line_tbl.delete;
   /* 8706868
    FOR i IN l_line_conc_tbl.FIRST .. l_line_conc_tbl.LAST LOOP
      l_line_tbl(i):= OE_ORDER_PUB.G_MISS_LINE_REC;
      IF l_line_conc_tbl(i).ship_to_org_id IS NOT NULL THEN
	IF NVL(l_x_line_tbl(i).ship_to_org_id,-1) <>
                                        NVL(l_line_conc_tbl(i).ship_to_org_id,-1) THEN
          l_line_tbl(i).ship_to_org_id := l_line_conc_tbl(i).ship_to_org_id;
          l_process_add_attributes := TRUE;
        END IF;
      END IF;

      IF l_line_conc_tbl(i).request_date IS NOT NULL THEN
        IF NVL(l_x_line_tbl(i).request_date,SYSDATE) <>
                                     NVL(l_line_conc_tbl(i).request_date,SYSDATE) THEN
          l_line_tbl(i).request_date := l_line_conc_tbl(i).request_date;
          l_process_add_attributes := TRUE;
        END IF;
      END IF;

      l_line_tbl(i).operation := OE_GLOBALS.G_OPR_UPDATE;
      oe_debug_pub.add('Reason code being passed : '||l_line_tbl(i).change_reason,1);

      l_line_tbl(i).change_reason := l_line_conc_tbl(i).change_reason_code;
      l_line_tbl(i).change_comments := l_line_conc_tbl(i).change_reason_comment;
      l_line_tbl(i).split_action_code:= FND_API.G_MISS_CHAR;
      l_line_tbl(i).line_id := l_x_line_tbl(i).line_id;
      l_line_tbl(i).header_id := l_x_line_tbl(i).header_id;

      IF l_line_conc_tbl(i).ship_from_org_id IS NOT NULL THEN
	IF NVL(l_x_line_tbl(i).ship_from_org_id,-1) <>
                                      NVL(l_line_conc_tbl(i).ship_from_org_id,-1) THEN
          l_line_tbl(i).ship_from_org_id := l_line_conc_tbl(i).ship_from_org_id;
          -- ship_from_org_id is changed during split, null out subinventory
          l_line_tbl(i).subinventory := null;
          l_process_add_attributes := TRUE;
        END IF;
      END IF;
    END LOOP;
   */ -- 8706868
    /* Extra loop being handled so as to deal with the service lines */
    -- At this point l_line_tbl contains the order line that was split as well as the
    -- the order lines that are created as a result of the split. Prior to this
    -- modification only these records were being passed to the Process Order API
    -- ( second call ) and there is no code in the Process Order API that would update
    -- the service lines if split attributes are modified in the order lines to which
    -- they refer to.
    -- In order to make the Process Order API handle the service lines, the service
    -- lines are explicitly being bundled with the order lines in the l_line_tbl. The
    -- Following loop takes care of that. The loop is coded taking Models, Standard
    -- items and Kits into consideration
    -- Local variables j, k, l_rec_count have been added. The variables j, k
    -- are used as a loop indices, and l_rec_count is used to work on the l_line_tbl.
    --
    -- l_line_id would contain the line_id of the line to which the service line is
    -- attached to or the top_most_line_id if the line to which its attached to is a
    -- part of a Model.
    -- This is done because splitting happens at the top most level.

    --8706868
    --l_rec_count := l_line_tbl.last + 1;
    l_rec_count :=  1;

    FOR i IN l_x_line_tbl.FIRST .. l_x_line_tbl.LAST LOOP
      IF l_x_line_tbl(i).item_type_code = 'SERVICE' THEN
        l_line_tbl(l_rec_count) := OE_ORDER_PUB.G_MISS_LINE_REC;
        FOR j IN l_x_line_tbl.FIRST .. l_x_line_tbl.LAST LOOP
          IF l_x_line_tbl(i).service_reference_line_id = l_x_line_tbl(j).line_id THEN
            l_line_id := NVL(l_x_line_tbl(j).top_model_line_id,
                                                             l_x_line_tbl(j).line_id);
            EXIT;
          END IF; -- service_Ref_line = line_id
        END LOOP;  -- loop on l_x_line_tbl

        FOR k in l_line_conc_tbl.first .. l_line_conc_tbl.last LOOP
          IF l_line_id = l_x_line_tbl(k).line_id THEN
            IF l_line_conc_tbl(k).ship_to_org_id is not null THEN
              IF NVL(l_x_line_tbl(i).ship_to_org_id,-1) <>
                                        NVL(l_line_conc_tbl(k).ship_to_org_id,-1) THEN
                l_line_tbl(l_rec_count).ship_to_org_id :=
                                                    l_line_conc_tbl(k).ship_to_org_id;
                l_process_add_attributes := TRUE;
              END IF; -- if ship_to_changed
            END IF; -- ship_to not null
            -- Code added for bug 2216899
	    IF l_line_conc_tbl(k).ship_from_org_id is not null THEN
              IF NVL(l_x_line_tbl(i).ship_from_org_id,-1) <>
                                      NVL(l_line_conc_tbl(k).ship_from_org_id,-1) THEN
	        l_line_tbl(l_rec_count).ship_from_org_id :=
                                                  l_line_conc_tbl(k).ship_from_org_id;
	        l_line_tbl(l_rec_count).subinventory := null;
                l_process_add_attributes := TRUE;
              END IF; -- if ship_from_changed
            END IF; -- ship_from not null
	    -- end 2216899
            IF l_line_conc_tbl(k).request_date is not null THEN
              IF NVL(l_x_line_tbl(i).request_date,SYSDATE) <>
                                     NVL(l_line_conc_tbl(k).request_date,SYSDATE) THEN
                l_line_tbl(l_rec_count).request_date :=
                                                      l_line_conc_tbl(k).request_date;
                l_process_add_attributes := TRUE;
              END IF;
            END IF;

            l_line_tbl(l_rec_count).operation := OE_GLOBALS.G_OPR_UPDATE;
            oe_debug_pub.add('Reason code being passed : '||
                                             l_line_tbl(l_rec_count).change_reason,1);
            l_line_tbl(l_rec_count).change_reason :=
                                                l_line_conc_tbl(k).change_reason_code;
            l_line_tbl(l_rec_count).change_comments :=
                                             l_line_conc_tbl(k).change_reason_comment;
            l_line_tbl(l_rec_count).split_action_code := FND_API.G_MISS_CHAR;
            l_line_tbl(l_rec_count).line_id := l_x_line_tbl(i).line_id;
            l_line_tbl(l_rec_count).header_id := l_x_line_tbl(i).header_id;

            l_rec_count := l_rec_count + 1;
            EXIT;
          END IF;  -- if l_line_id matches a line_id in l_line_conc_tbl
        END LOOP;  -- loop on index k
      END IF;  -- If item_type_code = 'SERVICE'
    END LOOP; -- First For Loop
    /* end of 1988144 */
    /* this l_line_tbl is passed to the process Order API */

     l_x_Header_Adj_tbl.DELETE;
     l_x_header_price_att_tbl.DELETE;
     l_x_Header_Adj_att_tbl.DELETE;
     l_x_Header_Adj_Assoc_tbl.DELETE;
     l_x_Header_Scredit_tbl.DELETE;
     l_x_Line_Adj_tbl.DELETE;
     l_x_Line_Price_att_tbl.DELETE;
     l_x_Line_Adj_att_tbl.DELETE;
     l_x_Line_Adj_Assoc_tbl.DELETE;
     l_x_Line_Scredit_tbl.DELETE;
     l_x_lot_serial_tbl.DELETE;

     IF  l_process_add_attributes THEN
     oe_debug_pub.add('calling process_order for service lines from oe_split_util.defer_split',5);
       Oe_Order_Pvt.Process_order
        (   p_api_version_number          => 1.0
        ,   p_init_msg_list               => FND_API.G_TRUE
        ,   x_return_status               => l_return_status
        ,   x_msg_count                   => l_msg_count
        ,   x_msg_data                    => l_msg_data
        ,   p_control_rec                 => l_control_rec
        ,   p_x_line_tbl                  => l_line_tbl
        ,   p_x_header_rec                => l_x_header_rec
        ,   p_x_Header_Adj_tbl            => l_x_Header_Adj_tbl
        ,   p_x_header_price_att_tbl      => l_x_header_price_att_tbl
        ,   p_x_Header_Adj_att_tbl        => l_x_Header_Adj_att_tbl
        ,   p_x_Header_Adj_Assoc_tbl      => l_x_Header_Adj_Assoc_tbl
        ,   p_x_Header_Scredit_tbl        => l_x_Header_Scredit_tbl
        ,   p_x_Header_Payment_tbl        => l_x_Header_Payment_tbl
        ,   p_x_Line_Adj_tbl              => l_x_Line_Adj_tbl
        ,   p_x_Line_Price_att_tbl        => l_x_Line_Price_att_tbl
        ,   p_x_Line_Adj_att_tbl          => l_x_Line_Adj_att_tbl
        ,   p_x_Line_Adj_Assoc_tbl        => l_x_Line_Adj_Assoc_tbl
        ,   p_x_Line_Scredit_tbl          => l_x_Line_Scredit_tbl
        ,   p_x_Line_Payment_tbl          => l_x_Line_Payment_tbl
        ,   p_x_action_request_tbl        => l_x_Action_Request_tbl
        ,   p_x_lot_serial_tbl            => l_x_lot_serial_tbl

        );
     END IF;

     l_msg_total := l_msg_total + l_msg_count;

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

  -- Irrespective of program result, deleting the data from table
  DELETE FROM oe_line_split_details
  WHERE  line_id = l_init_line_id
  AND    request_id = FND_GLOBAL.CONC_REQUEST_ID;

ELSE -- l_count < 2
  Fnd_Message.Set_Name('ONT','OE_CANCEL_SPLIT_SUCCESS');
  Fnd_Message.Set_Token('REQUEST_ID',FND_GLOBAL.CONC_REQUEST_ID);
  OE_Msg_Pub.Add;
  FND_FILE.put_line(FND_FILE.output,OE_MSG_PUB.Get(OE_MSG_PUB.G_LAST,FND_API.G_FALSE));
  RETURN;

END IF;

   --  Get message count and data
   oe_msg_pub.count_and_get
    (   p_count                       => l_msg_count
    ,   p_data                        => l_msg_data
    ); l_msg_total := l_msg_count;

    FND_FILE.put_line(FND_FILE.output,'Please check the debug log for errors');
    IF NVL(FND_PROFILE.VALUE('CONC_REQUEST_ID'), 0) <> 0 THEN
      -- Called from concurrent request
      IF l_msg_total > 0 THEN
        FOR I IN 1 .. l_msg_total LOOP
          l_msg_data := to_char(I)||'. '||OE_MSG_PUB.Get(I,FND_API.G_FALSE);
          FND_FILE.put_line(FND_FILE.output, l_msg_data);
          -- Writing messages into the concurrent request output file
        END LOOP;
        oe_debug_pub.add(' Saving the Messages');
        oe_msg_pub.save_messages(p_request_id => FND_GLOBAL.CONC_REQUEST_ID);
        -- Bug 6964815

      ELSE
        FND_FILE.put_line(FND_FILE.output,' << No Errors or Warnings reported >>');
      END IF;
    END IF;
    COMMIT;
  oe_debug_pub.add('Exiting Procedure OE_Split_Util.Defer_Split', 1);

EXCEPTION
  WHEN OTHERS THEN
    retcode := 2;
    oe_debug_pub.add('Inside the exception block of oe_split_util.defer_split',5);
    IF NVL(FND_PROFILE.VALUE('CONC_REQUEST_ID'), 0) <> 0 THEN
      -- Called from concurrent request */
      IF l_msg_total > 0 THEN
        FOR I IN 1 .. l_msg_total LOOP
          l_msg_data := to_char(I)||'. '||OE_MSG_PUB.Get(I,FND_API.G_FALSE);
          FND_FILE.put_line(FND_FILE.output, l_msg_data);
          -- Writing messages into the concurrent request output file
        END LOOP;
        oe_msg_pub.save_messages(p_request_id => FND_GLOBAL.CONC_REQUEST_ID);
        -- Bug 6964815
      END IF;
    END IF;

    IF sqlcode <> 0 THEN
      errbuf := sqlerrm;
    ELSE
      errbuf := 'Concurrent program did not finish successfully. See error messages and log file for more details';
    END IF;
    ROLLBACK;
    -- Irrespective of program result, deleting the data from table
    DELETE FROM oe_line_split_details
    WHERE  line_id = l_init_line_id
    AND    request_id = FND_GLOBAL.CONC_REQUEST_ID;
    COMMIT;
END Defer_Split;

PROCEDURE Bulk_Insert (p_line_conc_tbl IN Split_Line_Tbl_Type) is

begin
       oe_debug_pub.add('entering oe_split_util.bulk_insert');

         FORALL j IN p_line_conc_tbl.FIRST .. p_line_conc_tbl.LAST
                INSERT INTO OE_LINE_SPLIT_DETAILS
                VALUES p_line_conc_tbl(j);

exception
WHEN OTHERS THEN
 oe_debug_pub.add('failed in bulk insert API'||sqlerrm);
 raise;
end Bulk_Insert;

 /* Defer Split ER Changes END */

END OE_Split_Util;

/
