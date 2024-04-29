--------------------------------------------------------
--  DDL for Package Body OE_DEFAULT_LOT_SERIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEFAULT_LOT_SERIAL" AS
/* $Header: OEXDSRLB.pls 120.0 2005/06/01 01:17:08 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Default_Lot_Serial';

--  Package global used within the package.

g_Lot_Serial_rec              OE_Order_PUB.Lot_Serial_Rec_Type;

--  Get functions.

FUNCTION Get_From_Serial_Number
RETURN VARCHAR2
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    RETURN NULL;

END Get_From_Serial_Number;

FUNCTION Get_Line
RETURN NUMBER
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    RETURN NULL;

END Get_Line;

FUNCTION Get_Line_Set
RETURN NUMBER
IS
l_line_set_id NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    SELECT line_set_id
    INTO l_line_set_id
    FROM OE_ORDER_LINES
    WHERE line_id = g_Lot_Serial_rec.line_id;

    RETURN l_line_set_id;

END Get_Line_Set;

FUNCTION Get_Lot_Number
RETURN VARCHAR2
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    RETURN NULL;

END Get_Lot_Number;


/* FUNCTION Get_SubLot_Number --OPM 2380194 -- INVCONV OBSOLETE
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_SubLot_Number; */



FUNCTION Get_Lot_Serial
RETURN NUMBER
IS
l_lot_serial_id NUMBER:= NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    SELECT OE_LOT_SERIAL_S.NEXTVAL INTO l_lot_serial_id FROM DUAL;
    RETURN l_lot_serial_id;

END Get_Lot_Serial;

FUNCTION Get_Quantity
RETURN NUMBER
IS

-- OPM 3494420

CURSOR c_lines ( p_line_id IN NUMBER ) IS

		SELECT inventory_item_id,  ship_from_org_id, order_quantity_uom, ordered_quantity_uom2
	        FROM OE_ORDER_LINES
	       	WHERE line_id = p_line_id;
/*CURSOR c_opm_item ( discrete_org_id  IN NUMBER -- INVCONV
                  , discrete_item_id IN NUMBER) IS
       SELECT item_id
            , lot_ctl
           -- , sublot_ctl INVCONV
            , dualum_ind
       FROM  ic_item_mst
       WHERE delete_mark = 0
       AND   item_no in (SELECT segment1
         	FROM mtl_system_items
     	WHERE organization_id   = discrete_org_id
          AND   inventory_item_id = discrete_item_id); */

/*CURSOR c_opm_lot1 ( opm_item_id in number, -- OPM 3494420
		    lot_number in varchar2)  IS
                    Select lot_id
			from ic_lots_mst a where a.lot_id <> 0 and a.delete_mark = 0
			and a.item_id = opm_item_id
			and a.lot_no =  lot_number; */


/*CURSOR c_opm_lot2 ( opm_item_id in number, -- OPM 3494420
		    lot_number in varchar2 ) Is
		    -- sublot_number in varchar2)  IS INVCONV
                    Select lot_id
			from ic_lots_mst a where a.lot_id <> 0 and a.delete_mark = 0
			and a.item_id = opm_item_id
			and a.lot_no =  lot_number;
			and a.sublot_no = sublot_number; INVCONV */



  --  l_opm_rma_profile        VARCHAR2(30)   := nvl(fnd_profile.value('GMI_RMA_LOT_RESTRICT'), 'UNRESTRICTED');
    l_ship_from_org_id       NUMBER;
    l_inventory_item_id      NUMBER;
    l_order_quantity_uom     VARCHAR2(3);
    l_ordered_quantity_uom2  VARCHAR2(3);
    l_lot_ctl                NUMBER;
 --   l_sublot_ctl             NUMBER; INVCONV
    --l_dualum_ind             NUMBER; INVCONV
    --l_lot_id                 NUMBER; -- INVCONV
    -- l_item_id	   	     NUMBER; INVCONV
    l_return	   	     NUMBER;
    l_quantity               NUMBER;
    l_quantity2              NUMBER;
    l_item_rec               OE_ORDER_CACHE.item_rec_type;    -- INVCONV
    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
 -- OPM 3494420
UOM_CONVERSION_FAILED  EXCEPTION;             -- INVCONV


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN



--add code for OPM bug 3494420

If ( OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL < '110510'
	OR  OE_GLOBALS.G_UI_FLAG = TRUE )
	Then
		return null;
ELSE
				IF l_debug_level  > 0 THEN
        		oe_debug_pub.add(  'Entering OE_Default_Lot_Serial.Get_Quantity' , 1 ) ;
    		END IF;

    		begin
    		OPEN c_lines( g_Lot_Serial_rec.line_id );
	               FETCH c_lines
	                INTO l_inventory_item_id, l_ship_from_org_id, l_order_quantity_uom, l_ordered_quantity_uom2;

	        	IF c_lines%NOTFOUND THEN
	                	l_inventory_item_id := 0;
	                	l_ship_from_org_id := 0;
	                	l_order_quantity_uom := NULL;
	                	l_ordered_quantity_uom2 := NULL;
					  END IF;
		     close c_lines;
    		 end;

		    IF oe_line_util.dual_uom_control -- INVCONV
  			(l_inventory_item_id,l_ship_from_org_id,l_item_rec)
  	  	Then

				  IF l_debug_level  > 0 THEN
        			oe_debug_pub.add(  'Dual control RMA - get_quantity defaulting ' , 1 ) ;
    			END IF;
    			/* begin
    			OPEN c_opm_item( l_ship_from_org_id,
                   			 l_inventory_item_id
                              );
	               FETCH c_opm_item
	                INTO l_item_id,
		               l_lot_ctl,
		               --l_sublot_ctl, INVCONV
		               l_dualum_ind
		                ;

	               IF c_opm_item%NOTFOUND THEN
			l_item_id := 0;
	                l_lot_ctl := 0;
		        --l_sublot_ctl := 0; INVCONV
		        l_dualum_ind := NULL;

		       END IF;

		       Close c_opm_item;

    		 	end;   */

    	        IF l_item_rec.tracking_quantity_ind = 'PS' and
    	          l_item_rec.secondary_default_ind  = 'N'
    	         THEN      -- INVCONV no default for type 3 - must be supplied.
    	            return null;
    	        END IF;

		/* get quantity2 or check deviation but if type is 3 then quantity2 MUST be supplied */

			-- IF  l_dualum_ind in(1,2) then
			  IF l_item_rec.secondary_default_ind  in ('F','D') then     -- INVCONV
				l_quantity := g_Lot_Serial_rec.quantity;
				l_quantity2 := g_Lot_Serial_rec.quantity2;

    			/*	--IF  l_lot_ctl = 1
    				  IF l_item_rec.lot_control_code = 2
		          	and ( g_Lot_Serial_rec.lot_number <> FND_API.G_MISS_CHAR
		                and g_Lot_Serial_rec.lot_number IS NOT NULL )
		          	then
		          		begin
		               -- 	OPEN c_opm_lot1( l_item_rec.opm_item_id , -- INVCONV TO REVISIT
 											OPEN c_opm_lot1( l_item_rec.inventory_item_id ,
                                          g_Lot_Serial_rec.lot_number );

	               			FETCH c_opm_lot1 into l_lot_id;

	               			IF c_opm_lot1%NOTFOUND THEN
	               				IF l_debug_level  > 0 THEN
			             			oe_debug_pub.add(  'OPM NO_DATA_FOUND for type 3 tolerance check checking lot number' ) ;
			             		END IF;
			             		l_lot_id := 0;
	               			END IF;

		      			Close c_opm_lot1;
			                end;

		         	end if; */

			/*	IF l_sublot_ctl = 1 INVCONV
			          and ( g_Lot_Serial_rec.sublot_number <> FND_API.G_MISS_CHAR
			                and g_Lot_Serial_rec.sublot_number IS NOT NULL )
			          then
			               begin
			               --OPEN c_opm_lot2( l_item_rec.opm_item_id , -- INVCONV TO REVISIT
			               OPEN c_opm_lot1( l_item_rec.inventory_item_id ,
	                                          g_lot_serial_rec.lot_number,
	                                          g_lot_serial_rec.sublot_number
	                                           );

	               		       FETCH c_opm_lot2 into l_lot_id;

			               IF c_opm_lot2%NOTFOUND THEN
			               		IF l_debug_level  > 0 THEN
			             			oe_debug_pub.add(  'OPM NO_DATA_FOUND for type 1,2 tolerance check checking sublot number' ) ;
			             		END IF;
			             		l_lot_id := 0;
			               END IF;

		      		       Close c_opm_lot2;
			               end;

				end if; */

    				  l_quantity := INV_CONVERT.INV_UM_CONVERT(l_inventory_item_id -- INVCONV
       																								,g_Lot_Serial_rec.lot_number -- INVCONV
       																								,l_ship_from_org_id -- INVCONV
                                                      ,5 --NULL
                                                      ,l_quantity2
                                                      ,l_ordered_quantity_uom2
                                                      ,l_order_quantity_uom
                                                      ,NULL -- From uom name
                                                      ,NULL -- To uom name
                                                      );


  					 IF (l_quantity < 0) THEN    -- OPM B1478461 Start
   	 							raise UOM_CONVERSION_FAILED;
  					 END IF;                          -- OPM B1478461 End
  		       return l_quantity;
		         IF l_debug_level  > 0 THEN
		      	  		oe_debug_pub.add ('LOT SERIALS -  returning quantity ....');
		      	 END IF;



    				 /*l_quantity := GMI_Reservation_Util.get_opm_converted_qty( INVCONV
	              			p_apps_item_id    => l_inventory_item_id,
	              			p_organization_id => l_ship_from_org_id,
				        p_apps_from_uom   => l_ordered_quantity_uom2,
				        p_apps_to_uom     => l_order_quantity_uom ,
				        p_original_qty    => l_quantity2,
				        p_lot_id          => nvl(l_lot_id, 0) );

		                 return l_quantity;
		                 IF l_debug_level  > 0 THEN
		        		oe_debug_pub.add ('LOT SERIALS -  returning quantity ....');
		      		 END IF; */

			END IF; -- IF  l_dualum_ind in(1,2) then


		else

		     RETURN NULL;

		END IF; -- IF oe_line_util.dual_uom_control  -- INVCONV

	end if;  -- If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL < '110510' or OE_GLOBALS.G_UI_FLAG = TRUE Then

EXCEPTION

    WHEN UOM_CONVERSION_FAILED THEN -- INVCONV

    FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR'); -- INVCONV
    OE_MSG_PUB.Add;
    l_return_status := FND_API.G_RET_STS_ERROR;

    --RAISE FND_API.G_EXC_ERROR; INVCONV


    WHEN FND_API.G_EXC_ERROR THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'OE_Default_Lot_Serial'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

IF l_debug_level  > 0 THEN
        		oe_debug_pub.add(  'RMA exiting OE_Default_Lot_Serial.Get_Quantity' , 1 ) ;
END IF;


END Get_Quantity;

FUNCTION Get_Quantity2 --OPM 2380194 -- PAL UP TO HERE
RETURN NUMBER
IS
-- OPM 3494420
CURSOR c_lines ( p_line_id IN NUMBER ) IS

		SELECT inventory_item_id,  ship_from_org_id, order_quantity_uom, ordered_quantity_uom2
	        FROM OE_ORDER_LINES
	       	WHERE line_id = p_line_id;

/*CURSOR c_opm_item ( discrete_org_id  IN NUMBER
                  , discrete_item_id IN NUMBER) IS
       SELECT item_id
            , lot_ctl
           --  , sublot_ctl INVCONV
            , dualum_ind
       FROM  ic_item_mst
       WHERE delete_mark = 0
       AND   item_no in (SELECT segment1
         	FROM mtl_system_items
     	WHERE organization_id   = discrete_org_id
          AND   inventory_item_id = discrete_item_id);

CURSOR c_opm_lot1 ( opm_item_id in number, -- OPM 3494420
		    lot_number in varchar2)  IS
                    Select lot_id
			from ic_lots_mst a where a.lot_id <> 0 and a.delete_mark = 0
			and a.item_id = opm_item_id
			and a.lot_no =  lot_number;


CURSOR c_opm_lot2 ( opm_item_id in number, -- OPM 3494420
		    lot_number in varchar2 ) is
		    -- sublot_number in varchar2)  IS INVCONV
                    Select lot_id
			from ic_lots_mst a where a.lot_id <> 0 and a.delete_mark = 0
			and a.item_id = opm_item_id
			and a.lot_no =  lot_number;
			and a.sublot_no = sublot_number;     INVCONV      */

    --l_opm_rma_profile        VARCHAR2(30)   := nvl(fnd_profile.value('GMI_RMA_LOT_RESTRICT'), 'UNRESTRICTED'); INVCONV
    l_ship_from_org_id       NUMBER;
    l_inventory_item_id      NUMBER;
    l_order_quantity_uom     VARCHAR2(3);
    l_ordered_quantity_uom2  VARCHAR2(3);
    --l_lot_ctl                NUMBER;
    --l_sublot_ctl             NUMBER; INVCONV
    --l_dualum_ind             NUMBER;
    --l_lot_id                 NUMBER;
    --l_item_id	   	     NUMBER;
    l_return	   	     NUMBER;
    l_quantity               NUMBER;
    l_quantity2              NUMBER;
    l_item_rec               OE_ORDER_CACHE.item_rec_type;
    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
 -- OPM 3494420
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
UOM_CONVERSION_FAILED  EXCEPTION;             -- INVCONV

BEGIN

--add code for OPM bug 3494420

If ( OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510'
	and OE_GLOBALS.G_UI_FLAG = TRUE )
	Then
		return null;
ELSE
		IF l_debug_level  > 0 THEN
        		oe_debug_pub.add(  'OPM RMA entering OE_Default_Lot_Serial.Get_Quantity2' , 1 ) ;
    		END IF;
    		begin
    		OPEN c_lines( g_Lot_Serial_rec.line_id );
	               FETCH c_lines
	                INTO l_inventory_item_id, l_ship_from_org_id, l_order_quantity_uom, l_ordered_quantity_uom2;

	        	IF c_lines%NOTFOUND THEN
	                	l_inventory_item_id := 0;
	                	l_ship_from_org_id := 0;
	                	l_order_quantity_uom := NULL;
	                	l_ordered_quantity_uom2 := NULL;
			END IF;
		 close c_lines;
    		 end;

    IF oe_line_util.dual_uom_control -- INVCONV
	  			(l_inventory_item_id,l_ship_from_org_id,l_item_rec)
  	  	Then

					IF l_debug_level  > 0 THEN
        			oe_debug_pub.add(  'RMA - get_quantity2 defaulting ' , 1 ) ;
    			END IF;

    			/* begin -- INVCONV
    			OPEN c_opm_item( l_ship_from_org_id,
                   			 l_inventory_item_id
                              );
	               FETCH c_opm_item
	                INTO l_item_id,
		               l_lot_ctl,
		               -- l_sublot_ctl, INVCONV
		               l_dualum_ind
		                ;

	               IF c_opm_item%NOTFOUND THEN
			l_item_id := 0;
	                l_lot_ctl := 0;
		        -- l_sublot_ctl := 0; INVCONV
		        l_dualum_ind := NULL;

		       END IF;
    		 	end; */

    		    	IF l_item_rec.tracking_quantity_ind <> 'PS' or -- INVCONV
    	          l_item_rec.secondary_default_ind  = 'N'
    	         THEN      -- INVCONV -- if not dual controlled then return null
    	            return null;
    	        END IF;

		/* get quantity2 or check deviation but if type is 3 then quantity2 MUST be supplied */

			-- INVCONV IF  l_dualum_ind in(1,2) then
			IF l_item_rec.secondary_default_ind  in ('F','D') then     -- INVCONV
				l_quantity := g_Lot_Serial_rec.quantity;
				l_quantity2 := g_Lot_Serial_rec.quantity2;

    				/* IF  l_lot_ctl = 1
		          	and ( g_Lot_Serial_rec.lot_number <> FND_API.G_MISS_CHAR
		                and g_Lot_Serial_rec.lot_number IS NOT NULL )
		          	then
		                	begin
		                	--OPEN c_opm_lot1( l_item_rec.opm_item_id , -- invconv to revisit

		                	OPEN c_opm_lot1( l_item_rec.inventory_item_id,
                                          g_Lot_Serial_rec.lot_number );

	               			FETCH c_opm_lot1 into l_lot_id;

	               			IF c_opm_lot1%NOTFOUND THEN
	               				IF l_debug_level  > 0 THEN
			             			oe_debug_pub.add(  'OPM NO_DATA_FOUND for type 1,2 tolerance check checking lot number' ) ;
			             		END IF;
			             		l_lot_id := 0;
	               			END IF;

		      			Close c_opm_lot1;
			                end;

		         	end if;    */

				/* IF l_sublot_ctl = 1 -- INVCONV
			          and ( g_Lot_Serial_rec.sublot_number <> FND_API.G_MISS_CHAR
			                and g_Lot_Serial_rec.sublot_number IS NOT NULL )
			          then
			                begin
			               -- OPEN c_opm_lot2( l_item_rec.opm_item_id ,  -- INVCONV TO REVISIT
			               OPEN c_opm_lot2(  l_item_rec.inventory_item_id,
	                                          g_lot_serial_rec.lot_number,
	                                          g_lot_serial_rec.sublot_number
	                                           );

	               		       FETCH c_opm_lot2 into l_lot_id;

			               IF c_opm_lot2%NOTFOUND THEN
			               		IF l_debug_level  > 0 THEN
			             			oe_debug_pub.add(  'OPM NO_DATA_FOUND for type 1,2 tolerance check checking sublot number' ) ;
			             		END IF;
			             		l_lot_id := 0;
			               END IF;

		      		       Close c_opm_lot2;
			               end;

				end if; */

    	        l_quantity2 := INV_CONVERT.INV_UM_CONVERT(l_inventory_item_id -- INVCONV
       																								,g_Lot_Serial_rec.lot_number -- INVCONV
       																								,l_ship_from_org_id -- INVCONV
                                                      ,5 --NULL
                                                      ,l_quantity
                                                      ,l_order_quantity_uom
                                                      ,l_ordered_quantity_uom2
                                                      ,NULL -- From uom name
                                                      ,NULL -- To uom name
                                                      );


  					 IF (l_quantity2 < 0) THEN    -- OPM B1478461 Start
   	 							raise UOM_CONVERSION_FAILED;
  					 END IF;                          -- OPM B1478461 End
  		       return l_quantity2;
		         IF l_debug_level  > 0 THEN
		      	  		oe_debug_pub.add ('LOT SERIALS -  returning quantity2 =  ' || l_quantity2 );
		      	 END IF;


    			/* 	l_quantity2 := GMI_Reservation_Util.get_opm_converted_qty( -- INVCONV
	              			p_apps_item_id    => l_inventory_item_id,
	              			p_organization_id => l_ship_from_org_id,
				        p_apps_from_uom   => l_order_quantity_uom,
				        p_apps_to_uom     => l_ordered_quantity_uom2,
				        p_original_qty    => l_quantity,
				        p_lot_id          => nvl(l_lot_id, 0) );

		                 IF l_debug_level  > 0 THEN
		        		oe_debug_pub.add ('OPM LOT SERIALS -  returning quantity2  = ' || l_quantity2 );
		      		 END IF;

		                 return l_quantity2; */

			END IF; -- IF  l_dualum_ind in(1,2,3) then
	  ELSE  -- OPM 3610319

		   return null;

		END IF; -- IF oe_line_util.dual_uom_control -- INVCONV

	end if;  -- If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' and OE_GLOBALS.G_UI_FLAG = FALSE Then

EXCEPTION
	WHEN UOM_CONVERSION_FAILED THEN -- INVCONV

    FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR'); -- INVCONV
    OE_MSG_PUB.Add;
    l_return_status := FND_API.G_RET_STS_ERROR;

    --RAISE FND_API.G_EXC_ERROR; INVCONV

    WHEN FND_API.G_EXC_ERROR THEN

        l_return_status := FND_API.G_RET_STS_ERROR;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'OE_Default_Lot_Serial'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

IF l_debug_level  > 0 THEN
      	oe_debug_pub.add(  'OPM RMA exiting OE_Default_Lot_Serial.Get_Quantity2' , 1 ) ;
END IF;


END Get_Quantity2;

FUNCTION Get_To_Serial_Number
RETURN VARCHAR2
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    RETURN NULL;

END Get_To_Serial_Number;

PROCEDURE Get_Flex_Lot_Serial
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_Lot_Serial_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_Lot_Serial_rec.attribute1    := NULL;
    END IF;

    IF g_Lot_Serial_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_Lot_Serial_rec.attribute10   := NULL;
    END IF;

    IF g_Lot_Serial_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_Lot_Serial_rec.attribute11   := NULL;
    END IF;

    IF g_Lot_Serial_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_Lot_Serial_rec.attribute12   := NULL;
    END IF;

    IF g_Lot_Serial_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_Lot_Serial_rec.attribute13   := NULL;
    END IF;

    IF g_Lot_Serial_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_Lot_Serial_rec.attribute14   := NULL;
    END IF;

    IF g_Lot_Serial_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_Lot_Serial_rec.attribute15   := NULL;
    END IF;

    IF g_Lot_Serial_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_Lot_Serial_rec.attribute2    := NULL;
    END IF;

    IF g_Lot_Serial_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_Lot_Serial_rec.attribute3    := NULL;
    END IF;

    IF g_Lot_Serial_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_Lot_Serial_rec.attribute4    := NULL;
    END IF;

    IF g_Lot_Serial_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_Lot_Serial_rec.attribute5    := NULL;
    END IF;

    IF g_Lot_Serial_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_Lot_Serial_rec.attribute6    := NULL;
    END IF;

    IF g_Lot_Serial_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_Lot_Serial_rec.attribute7    := NULL;
    END IF;

    IF g_Lot_Serial_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_Lot_Serial_rec.attribute8    := NULL;
    END IF;

    IF g_Lot_Serial_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_Lot_Serial_rec.attribute9    := NULL;
    END IF;

    IF g_Lot_Serial_rec.context = FND_API.G_MISS_CHAR THEN
        g_Lot_Serial_rec.context       := NULL;
    END IF;

END Get_Flex_Lot_Serial;

--  Procedure Attributes

PROCEDURE Attributes
(   p_x_Lot_Serial_rec              IN OUT NOCOPY  OE_Order_PUB.Lot_Serial_Rec_Type
,   p_iteration                     IN  NUMBER := 1
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INSIDE DEFAULTING ATTRIBUTES'||TO_CHAR ( P_X_LOT_SERIAL_REC.QUANTITY ) , 1 ) ;
    END IF;

    --  Check number of iterations.

    IF p_iteration > OE_GLOBALS.G_MAX_DEF_ITERATIONS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_DEF_MAX_ITERATION');
            FND_MSG_PUB.Add;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Initialize g_Lot_Serial_rec

    g_Lot_Serial_rec := p_x_Lot_Serial_rec;


    --  Default missing attributes.

    IF g_Lot_Serial_rec.from_serial_number = FND_API.G_MISS_CHAR THEN

        g_Lot_Serial_rec.from_serial_number := Get_From_Serial_Number;

        IF g_Lot_Serial_rec.from_serial_number IS NOT NULL THEN

            IF OE_Validate.From_Serial_Number(g_Lot_Serial_rec.from_serial_number)
            THEN
                OE_Lot_Serial_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Lot_Serial_Util.G_FROM_SERIAL_NUMBER
                ,   p_x_Lot_Serial_rec              => g_Lot_Serial_rec
                );
            ELSE
                g_Lot_Serial_rec.from_serial_number := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Lot_Serial_rec.line_id = FND_API.G_MISS_NUM THEN

        g_Lot_Serial_rec.line_id := Get_Line;

        IF g_Lot_Serial_rec.line_id IS NOT NULL THEN

            IF OE_Validate.Line(g_Lot_Serial_rec.line_id)
            THEN
                OE_Lot_Serial_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Lot_Serial_Util.G_LINE
                ,   p_x_Lot_Serial_rec              => g_Lot_Serial_rec
                );
            ELSE
                g_Lot_Serial_rec.line_id := NULL;
            END IF;

        END IF;

    END IF;


    IF g_Lot_Serial_rec.line_set_id = FND_API.G_MISS_NUM THEN

        g_Lot_Serial_rec.line_set_id := Get_Line_Set;

        	IF g_Lot_Serial_rec.line_set_id IS NOT NULL THEN
        		IF l_debug_level  > 0 THEN
            			oe_debug_pub.add(  'INSIDE OE_DEFAULT_LOT_SERIAL.ATTRIBUTES g_Lot_Serial_rec.line_set_id IS NOT NULL') ;
            	        end if;

            IF OE_Validate.Line_Set(g_Lot_Serial_rec.line_set_id)
            THEN

                OE_Lot_Serial_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Lot_Serial_Util.G_LINE_SET
                ,   p_x_Lot_Serial_rec              => g_Lot_Serial_rec
                );


            ELSE

               g_Lot_Serial_rec.line_set_id := NULL;
            END IF;

        END IF;

    END IF;


    IF g_Lot_Serial_rec.lot_number = FND_API.G_MISS_CHAR THEN

        g_Lot_Serial_rec.lot_number := Get_Lot_Number;

        IF g_Lot_Serial_rec.lot_number IS NOT NULL THEN

            IF OE_Validate.Lot_Number(g_Lot_Serial_rec.lot_number)
            THEN
                OE_Lot_Serial_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Lot_Serial_Util.G_LOT_NUMBER
                ,   p_x_Lot_Serial_rec              => g_Lot_Serial_rec
                );
            ELSE
                g_Lot_Serial_rec.lot_number := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Lot_Serial_rec.lot_serial_id = FND_API.G_MISS_NUM THEN

        g_Lot_Serial_rec.lot_serial_id := Get_Lot_Serial;

        IF g_Lot_Serial_rec.lot_serial_id IS NOT NULL THEN

            IF OE_Validate.Lot_Serial(g_Lot_Serial_rec.lot_serial_id)
            THEN
                OE_Lot_Serial_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Lot_Serial_Util.G_LOT_SERIAL
                ,   p_x_Lot_Serial_rec              => g_Lot_Serial_rec
                );
            ELSE
                g_Lot_Serial_rec.lot_serial_id := NULL;
            END IF;

        END IF;

    END IF;


     IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'

   	 THEN
   	 /*IF g_Lot_Serial_rec.sublot_number = FND_API.G_MISS_CHAR THEN   --OPM 2380194 INVCONV

        g_Lot_Serial_rec.sublot_number := Get_SubLot_Number;

        IF g_Lot_Serial_rec.sublot_number IS NOT NULL THEN

            	IF OE_Validate.SubLot_Number(g_Lot_Serial_rec.sublot_number) -- OPM change to proc sublot
            	THEN

                	OE_Lot_Serial_Util.Clear_Dependent_Attr
                	(   p_attr_id                     => OE_Lot_Serial_Util.G_SUBLOT_NUMBER
                	,   p_x_Lot_Serial_rec              => g_Lot_Serial_rec
                	);
            	ELSE

               		 g_Lot_Serial_rec.sublot_number := NULL;
            	END IF; --  IF OE_Validate.SubLot_Number(g_Lot_Serial_rec.sublot_number)

        END IF; --  IF g_Lot_Serial_rec.sublot_number IS NOT NULL THEN

    END IF; --   IF g_Lot_Serial_rec.sublot_number = FND_API.G_MISS_CHAR */


    IF g_Lot_Serial_rec.quantity2 = FND_API.G_MISS_NUM
    or g_Lot_Serial_rec.quantity2 is NULL

    THEN --OPM 2380194

        		IF l_debug_level  > 0 THEN
        			oe_debug_pub.add(  'OE_DEFAULT_LOT_SERIAL.ATTRIBUTES g_Lot_Serial_rec.quantity2 = FND_API.G_MISS_NUM' ) ;
    			END IF;
			g_Lot_Serial_rec.quantity2 := Get_Quantity2;

        IF g_Lot_Serial_rec.quantity2 IS NOT NULL THEN
        	IF l_debug_level  > 0 THEN
        			oe_debug_pub.add(  'OE_DEFAULT_LOT_SERIAL.ATTRIBUTES - _Lot_Serial_rec.quantity2 IS NOT NULL' ) ;
    		END IF;

            IF OE_Validate.Quantity2(g_Lot_Serial_rec.quantity2)
            THEN

                OE_Lot_Serial_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Lot_Serial_Util.G_QUANTITY2
                ,   p_x_Lot_Serial_rec              => g_Lot_Serial_rec
                );
            ELSE

                g_Lot_Serial_rec.quantity2 := NULL;
            END IF; -- IF OE_Validate.Quantity2(g_Lot_Serial_rec.quantity2)

        END IF; --  IF g_Lot_Serial_rec.quantity2 IS NOT NULL THEN

    END IF; -- IF g_Lot_Serial_rec.quantity2 = FND_API.G_MISS_NUM THEN --OPM 2380194



   END IF; -- IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'


    IF g_Lot_Serial_rec.quantity = FND_API.G_MISS_NUM THEN

        g_Lot_Serial_rec.quantity := Get_Quantity;

        IF g_Lot_Serial_rec.quantity IS NOT NULL THEN

            IF OE_Validate.Quantity(g_Lot_Serial_rec.quantity)
            THEN
                OE_Lot_Serial_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Lot_Serial_Util.G_QUANTITY
                ,   p_x_Lot_Serial_rec              => g_Lot_Serial_rec
                );
            ELSE
                g_Lot_Serial_rec.quantity := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Lot_Serial_rec.to_serial_number = FND_API.G_MISS_CHAR THEN

        g_Lot_Serial_rec.to_serial_number := Get_To_Serial_Number;

        IF g_Lot_Serial_rec.to_serial_number IS NOT NULL THEN

            IF OE_Validate.To_Serial_Number(g_Lot_Serial_rec.to_serial_number)
            THEN
                OE_Lot_Serial_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Lot_Serial_Util.G_TO_SERIAL_NUMBER
                ,   p_x_Lot_Serial_rec              => g_Lot_Serial_rec
                );
            ELSE
                g_Lot_Serial_rec.to_serial_number := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Lot_Serial_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Lot_Serial;

    END IF;

    IF g_Lot_Serial_rec.created_by = FND_API.G_MISS_NUM THEN

        g_Lot_Serial_rec.created_by := NULL;

    END IF;

    IF g_Lot_Serial_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_Lot_Serial_rec.creation_date := NULL;

    END IF;

    IF g_Lot_Serial_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_Lot_Serial_rec.last_updated_by := NULL;

    END IF;

    IF g_Lot_Serial_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_Lot_Serial_rec.last_update_date := NULL;

    END IF;

    IF g_Lot_Serial_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_Lot_Serial_rec.last_update_login := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_Lot_Serial_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.context = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.created_by = FND_API.G_MISS_NUM
    OR  g_Lot_Serial_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_Lot_Serial_rec.from_serial_number = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_Lot_Serial_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_Lot_Serial_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_Lot_Serial_rec.line_id = FND_API.G_MISS_NUM
    OR  g_Lot_Serial_rec.lot_number = FND_API.G_MISS_CHAR
    --OR  ( g_Lot_Serial_rec.sublot_number = FND_API.G_MISS_CHAR and OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510') --OPM 2380194 INVCONV
    OR  g_Lot_Serial_rec.lot_serial_id = FND_API.G_MISS_NUM
    OR  g_Lot_Serial_rec.quantity = FND_API.G_MISS_NUM
    OR  ( g_Lot_Serial_rec.quantity2 = FND_API.G_MISS_NUM and OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510')     --OPM 2380194
    OR  g_Lot_Serial_rec.to_serial_number = FND_API.G_MISS_CHAR
    OR  g_Lot_Serial_rec.line_set_id = FND_API.G_MISS_NUM
    THEN

        OE_Default_Lot_Serial.Attributes
        (   p_x_Lot_Serial_rec            => g_Lot_Serial_rec
        ,   p_iteration                   => p_iteration + 1
        );

    ELSE

        --  Done defaulting attributes

        p_x_Lot_Serial_rec := g_Lot_Serial_rec;

    END IF;

    /* 1581620 start */

    IF p_x_Lot_Serial_rec.orig_sys_lotserial_ref = FND_API.G_MISS_CHAR THEN
	   p_x_Lot_Serial_rec.orig_sys_lotserial_ref := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.lock_control = FND_API.G_MISS_NUM THEN
	   p_x_Lot_Serial_rec.lock_control := NULL;
    END IF;

    /* 1581620 end */
    /*IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INSIDE DEFAULTING ATTRIBUTES'||TO_CHAR ( P_X_LOT_SERIAL_REC.QUANTITY ) , 1 ) ;
    END IF; */
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXIT OE_DEFAULT_LOT_SERIAL.ATTRIBUTES' ) ;
    END IF;

END Attributes;

END OE_Default_Lot_Serial;

/
