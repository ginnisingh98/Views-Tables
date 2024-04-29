--------------------------------------------------------
--  DDL for Package Body OE_VALIDATE_LOT_SERIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VALIDATE_LOT_SERIAL" AS
/* $Header: OEXLSRLB.pls 120.2.12010000.2 2009/06/01 06:31:23 nshah ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Validate_Lot_Serial';

--  Procedure Entity

PROCEDURE Entity
( x_return_status OUT NOCOPY VARCHAR2

,   p_Lot_Serial_rec                IN  OE_Order_PUB.Lot_Serial_Rec_Type
,   p_old_Lot_Serial_rec            IN  OE_Order_PUB.Lot_Serial_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
--Removed because not used after changes for bug 5155914(validation removal)
--l_ordered_qty                 NUMBER := 0;
--l_total_qty                   NUMBER := 0;
x_prefix                      VARCHAR2(80);
x_quantity                    VARCHAR2(80);
x_from_number                 VARCHAR2(80);
x_to_number                   VARCHAR2(80);
x_error_code                  NUMBER;

-- OPM 3494420
CURSOR c_lines ( p_line_id IN NUMBER ) IS

		SELECT inventory_item_id,  ship_from_org_id, order_quantity_uom, ordered_quantity_uom2
	        FROM OE_ORDER_LINES
	       	WHERE line_id = p_line_id;

CURSOR c_item ( discrete_org_id  IN NUMBER         -- INVCONV
              , discrete_item_id IN NUMBER) IS
       SELECT lot_control_code,
              tracking_quantity_ind,
              secondary_uom_code,
              serial_number_control_code,
              secondary_default_ind
         	FROM mtl_system_items
     		WHERE organization_id   = discrete_org_id
         	AND   inventory_item_id = discrete_item_id;

/*CURSOR c_opm_item ( discrete_org_id  IN NUMBER   INVCONV
                  , discrete_item_id IN NUMBER) IS
       SELECT item_id
       	    , item_no
            , lot_ctl
            --, sublot_ctl INVCONV
            , dualum_ind
            , item_um2
       FROM  ic_item_mst
       WHERE delete_mark = 0
       AND   item_no in (SELECT segment1
         	FROM mtl_system_items
     	WHERE organization_id   = discrete_org_id
          AND   inventory_item_id = discrete_item_id); */

CURSOR c_lot1 ( p_inventory_item_id in number, --  INVCONV 			bug 4099604
		    p_lot_number in varchar2,
		    p_organization_id in number )
		   IS
      Select lot_number
      from mtl_lot_numbers
			where inventory_item_id = p_inventory_item_id
			and lot_number =  p_lot_number
			and organization_id = p_organization_id;

/*CURSOR c_opm_lot1 ( opm_item_id in number, -- OPM 3494420
		    lot_number in varchar2)  IS
                    Select lot_id
			from ic_lots_mst a where a.lot_id <> 0 and a.delete_mark = 0
			and a.item_id = opm_item_id
			and a.lot_no =  lot_number; */

CURSOR c_rcv_parameter ( org_id   IN NUMBER ) IS  -- INVCONV
            SELECT enforce_rma_lot_num
            FROM rcv_parameters
     	    WHERE organization_id   = org_id;

/*CURSOR c_opm_lot2 ( opm_item_id in number, -- OPM 3494420
		    lot_number in varchar2 ) is
		   -- sublot_number in varchar2)  IS --INVCONV
                    Select lot_id
			from ic_lots_mst a where a.lot_id <> 0 and a.delete_mark = 0
			and a.item_id = opm_item_id
			and a.lot_no =  lot_number;
			-- and a.sublot_no = sublot_number;  */ --INVCONV

    l_RMA_LOT_RESTRICT varchar2(1) := 'U'; -- INVCONV
    --l_opm_rma_profile        VARCHAR2(30)   := nvl(fnd_profile.value('GMI_RMA_LOT_RESTRICT'), 'UNRESTRICTED'); -- invconv
    l_ship_from_org_id       NUMBER;
    l_inventory_item_id      NUMBER;
    l_order_quantity_uom     VARCHAR2(3);
    l_ordered_quantity_uom2  VARCHAR2(3);
    --l_item_um2               VARCHAR2(4); -- OPM um  INVCONV
    --l_OPM_UOM                VARCHAR2(4); -- OPM um  INVCONV
    l_status                 VARCHAR2(1);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(240);
    l_lot_ctl                NUMBER(5):= 1; -- INVCONV;  1 =no 2 = yes
    l_serial_number_control_code number(5):= 1;  -- INVCONV
    l_tracking_quantity_ind       VARCHAR2(30); -- INVCONV
    l_secondary_default_ind       VARCHAR2(30); -- INVCONV
    l_secondary_uom_code varchar2(3) := NULL; -- INVCONV
    l_lot_number VARCHAR2(80); -- INVCONV
    l_buffer                  VARCHAR2(2000); -- INVCONV
    TOLERANCE_ERROR EXCEPTION;             -- INVCONV

    --l_sublot_ctl             NUMBER; INVCONV
    --l_dualum_ind             NUMBER; INVCONV
    --l_lot_id                 NUMBER;
    --l_item_no                VARCHAR2(32);
    --l_item_id	   	     NUMBER; INVCONV
    l_return	   	     NUMBER;
    l_quantity               NUMBER;
    l_quantity2               NUMBER;
    --l_item_rec             OE_ORDER_CACHE.item_rec_type;    INVCONV
 -- OPM 3494420

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_VALIDATE_LOT_SERIAL.ENTITY' , 1 ) ;
    END IF;
    --  Check required attributes.

    IF  p_Lot_Serial_rec.lot_serial_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Lot Serial ID');
        OE_MSG_PUB.Add;

    END IF;

    --
    --  Check rest of required attributes here.
    --

    IF  p_Lot_Serial_rec.quantity IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Quantity');
        OE_MSG_PUB.Add;

    END IF;

    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --
    --  Check conditionally required attributes here.
    --


  IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL < '110510' THEN -- OPM new

    IF  p_Lot_Serial_rec.lot_number IS NULL AND
	   p_Lot_Serial_rec.from_serial_number IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Lot Number/From Serial Number');
        OE_MSG_PUB.Add;

    END IF;
 END IF;   -- OPM new

    IF  p_Lot_Serial_rec.quantity > 1 AND
	   p_Lot_Serial_rec.from_serial_number IS NOT NULL AND
	   p_Lot_Serial_rec.to_serial_number IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','To Serial Number');
        OE_MSG_PUB.Add;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'THE QUANTITY IS '||TO_CHAR ( P_LOT_SERIAL_REC.QUANTITY ) , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'THE OLD QUANTITY IS '||TO_CHAR ( P_OLD_LOT_SERIAL_REC.QUANTITY ) , 1 ) ;
    END IF;


    -- We should not validate the quantity field on oe_lot_serial_numbers table as
    -- the UOM on this record may not match the ordered_quantity_UOM. Unless we
    -- start capturing UOMs for the lot_serial records, we should not validate the
    -- quantity totals with ordered_quantity.
    -- Removing the validation for bug 5155914.

    /*

    IF NOT OE_GLOBALS.Equal(p_Lot_Serial_rec.quantity,
					   p_old_Lot_Serial_rec.quantity)
    THEN
	   IF p_Lot_Serial_rec.line_set_id IS NOT NULL THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'QUERYING FOR LINE_SET_ID' , 1 ) ;
    END IF;
	       SELECT NVL(SUM(ORDERED_QUANTITY),0)
	       INTO l_ordered_qty
	       FROM OE_ORDER_LINES
	       WHERE line_set_id = p_Lot_Serial_rec.line_set_id;

	       SELECT NVL(SUM(quantity),0)
	       INTO l_total_qty
	       FROM OE_LOT_SERIAL_NUMBERS
	       WHERE line_set_id = p_Lot_Serial_rec.line_set_id
	       AND lot_serial_id <> p_Lot_Serial_rec.lot_serial_id;
        ELSE
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'QUERYING FOR LINE_ID' , 1 ) ;
    END IF;
	       SELECT NVL(ORDERED_QUANTITY,0)
	       INTO l_ordered_qty
	       FROM OE_ORDER_LINES
	       WHERE line_id = p_Lot_Serial_rec.line_id;

	       SELECT NVL(SUM(quantity),0)
	       INTO l_total_qty
	       FROM OE_LOT_SERIAL_NUMBERS
	       WHERE line_id = p_Lot_Serial_rec.line_id
	       AND lot_serial_id <> p_Lot_Serial_rec.lot_serial_id;

	   END IF;

        IF p_Lot_Serial_rec.quantity > (l_ordered_qty - l_total_qty)
	   THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('ONT','OE_TOO_MANY_LOT_SERIAL');
            OE_MSG_PUB.Add;

        END IF;
    END IF;
    */
    --
    --  Validate attribute dependencies here.
    --
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'QUANTITY IS '||TO_CHAR ( P_LOT_SERIAL_REC.QUANTITY ) , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'FROM IS '||P_LOT_SERIAL_REC.FROM_SERIAL_NUMBER , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'TO IS '||P_LOT_SERIAL_REC.TO_SERIAL_NUMBER , 1 ) ;
    END IF;
    IF  p_Lot_Serial_rec.quantity IS NOT NULL AND
        p_Lot_Serial_rec.from_serial_number IS NOT NULL AND
	  (NOT OE_GLOBALS.Equal(p_Lot_Serial_rec.quantity,
					   p_old_Lot_Serial_rec.quantity) OR
       NOT OE_GLOBALS.Equal(p_Lot_Serial_rec.from_serial_number,
					   p_old_Lot_Serial_rec.from_serial_number) OR
       NOT OE_GLOBALS.Equal(p_Lot_Serial_rec.to_serial_number,
					   p_old_Lot_Serial_rec.to_serial_number))
    THEN
        IF NOT MTL_SERIAL_CHECK.INV_SERIAL_INFO(
                        p_Lot_Serial_rec.from_serial_number,
                        p_Lot_Serial_rec.to_serial_number,
                        x_prefix,
                        x_quantity,
                        x_from_number,
                        x_to_number,
                        x_error_code)
        THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('ONT','OE_NOT_KNOW_QUANTITY');
          OE_MSG_PUB.Add;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN OE_VALIDATE_LOT_SERIAL.ENTITY 2' , 1 ) ;
    END IF;
        ELSE
            IF p_Lot_Serial_rec.quantity <> x_quantity THEN
                l_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.Set_Name('ONT','OE_QUANTITY_MISMATCH');
                OE_MSG_PUB.Add;
    		IF l_debug_level  > 0 THEN
        		oe_debug_pub.add(  'IN OE_VALIDATE_LOT_SERIAL.ENTITY 3' , 1 ) ;
    		END IF;
            END IF;
        END IF;

    END IF;

-- OPM 3494420 start
	If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510'
	and OE_GLOBALS.G_UI_FLAG = FALSE
	 Then

		IF l_debug_level  > 0 THEN
        		oe_debug_pub.add(  'RMA lot serial QUERYING FOR LINE_ID' , 1 ) ; -- INVCONV
    		END IF;

    		begin
    		OPEN c_lines( p_Lot_Serial_rec.line_id );
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

               OPEN c_rcv_parameter( l_ship_from_org_id );

               FETCH c_rcv_parameter
                INTO l_RMA_LOT_RESTRICT
	             ;


               IF c_rcv_parameter%NOTFOUND THEN
									l_RMA_LOT_RESTRICT := 'U';
               END IF;

   	       Close c_rcv_parameter;


               OPEN c_item( l_ship_from_org_id,
                   l_inventory_item_id
                              );
               FETCH c_item
                INTO   l_lot_ctl,
	               l_tracking_quantity_ind,
                       l_secondary_uom_code ,
                       l_serial_number_control_code,
                       l_secondary_default_ind
	               ;


               IF c_item%NOTFOUND THEN
		    l_lot_ctl := 1;
            	    l_tracking_quantity_ind := 'P';
	            l_secondary_uom_code := NULL;
	            l_serial_number_control_code := NULL;
	            l_secondary_default_ind := null;

	       END IF;

	       Close c_item;

         IF l_debug_level  > 0 THEN
       			oe_debug_pub.add(  'IN OE_VALIDATE_LOT_SERIAL.ENTITY - l_secondary_uom_code = ' || l_secondary_uom_code, 1 ) ;
       			oe_debug_pub.add(  'IN OE_VALIDATE_LOT_SERIAL.ENTITY - l_tracking_quantity_ind  = ' || l_tracking_quantity_ind , 1 ) ;
       			oe_debug_pub.add(  'IN OE_VALIDATE_LOT_SERIAL.ENTITY - l_RMA_LOT_RESTRICT = ' || l_RMA_LOT_RESTRICT, 1 ) ;
       			oe_debug_pub.add(  'IN OE_VALIDATE_LOT_SERIAL.ENTITY - l_serial_number_control_code = ' || l_serial_number_control_code, 1 ) ;
       			oe_debug_pub.add(  'IN OE_VALIDATE_LOT_SERIAL.ENTITY - l_secondary_default_ind = ' || l_secondary_default_ind, 1 ) ;
       			oe_debug_pub.add(  'IN OE_VALIDATE_LOT_SERIAL.ENTITY - l_lot_ctl = ' || l_lot_ctl, 1 ) ;
						oe_debug_pub.add(  'IN OE_VALIDATE_LOT_SERIAL.ENTITY - l_ship_from_org_id = ' || l_ship_from_org_id, 1 ) ;
						oe_debug_pub.add(  'IN OE_VALIDATE_LOT_SERIAL.ENTITY - l_inventory_item_id = ' || l_inventory_item_id, 1 ) ;
    		 		oe_debug_pub.add(  'IN OE_VALIDATE_LOT_SERIAL.ENTITY - p_Lot_Serial_rec.lot_number, = ' || p_Lot_Serial_rec.lot_number, 1 ) ;
    		 END IF;


		/*IF oe_line_util.Process_Characteristics INVCONV
  			(l_inventory_item_id,l_ship_from_org_id,l_item_rec)
  	  	Then

			IF l_debug_level  > 0 THEN
        			oe_debug_pub.add(  'OPM RMA - OPM item' , 1 ) ;
    			END IF;

                        begin
    			OPEN c_opm_item( l_ship_from_org_id,
                   			 l_inventory_item_id
                              );
	               FETCH c_opm_item
	                INTO l_item_id,
	                       l_item_no,
		               l_lot_ctl,
		             --  l_sublot_ctl, INVCONV
		               l_dualum_ind,
		               l_item_um2
		                ;

	               IF c_opm_item%NOTFOUND THEN
			l_item_id := 0;
	                l_lot_ctl := 0;
		         l_dualum_ind := NULL;
		        l_item_um2 := NULL;

		       END IF;

		       Close c_opm_item;

    		 	end; */



     -- lot validation
     			IF l_lot_ctl <> 2 and  -- INVCONV
       			( p_Lot_Serial_rec.lot_number <> FND_API.G_MISS_CHAR
       				and p_Lot_Serial_rec.lot_number IS NOT NULL ) then
         			IF l_debug_level  > 0 THEN
	    				 oe_debug_pub.add(  'INVALID LINE LOT SERIALS LOT NUMBER...' ) ;
	 			END IF;
	 			FND_MESSAGE.SET_NAME('INV','INV_NO_LOT_CONTROL');
         			OE_MSG_PUB.Add;
	 			l_return_status := FND_API.G_RET_STS_ERROR;
      			END IF;

     		/*	IF l_sublot_ctl <> 1 and  INVCONV
       			( p_Lot_Serial_rec.sublot_number <> FND_API.G_MISS_CHAR
       			and p_Lot_Serial_rec.sublot_number IS NOT NULL ) then
         			IF l_debug_level  > 0 THEN
	     				oe_debug_pub.add(  'OPM INVALID LINE LOT SERIALS SUBLOT NUMBER...' ) ;
	 			END IF;
	 			FND_MESSAGE.SET_NAME('GMI','IC_SUBLOTNO');
         			OE_MSG_PUB.Add;
	 			l_return_status := FND_API.G_RET_STS_ERROR;
      			END IF; */

		       /* IF l_sublot_ctl = 1 and
		        (  p_Lot_Serial_rec.sublot_number <> FND_API.G_MISS_CHAR
		       	and p_Lot_Serial_rec.sublot_number IS NOT NULL )
		       	and
		        (  p_Lot_Serial_rec.lot_number = FND_API.G_MISS_CHAR
		        or p_Lot_Serial_rec.lot_number IS NULL ) then

		         	IF l_debug_level  > 0 THEN
			     		oe_debug_pub.add(  'OPM INVALID LINE LOT SERIALS NO LOT NUMBER...' ) ;
			 	END IF;
				 FND_MESSAGE.SET_NAME('INV','INV_MISSING_LOT');
		         	OE_MSG_PUB.Add;
			 	l_return_status := FND_API.G_RET_STS_ERROR;
		        END IF; */


		        IF ( l_RMA_LOT_RESTRICT = 'R' OR -- INVCONV
		          l_RMA_LOT_RESTRICT = 'W' )   -- RESTRICTED_WITH_WARNING'  -- INVCONV
		          and l_lot_ctl = 2 -- (YES)     INVCONV
		          and ( p_Lot_Serial_rec.lot_number <> FND_API.G_MISS_CHAR
		                and p_Lot_Serial_rec.lot_number IS NOT NULL )
		          then
		                begin

		                OPEN c_lot1( l_inventory_item_id,
                                          p_Lot_Serial_rec.lot_number,     -- INVCONV
                                          l_ship_from_org_id );


               			FETCH c_lot1 into l_lot_number;  --  l_sublot_number INVCONV ;

               			IF c_lot1%NOTFOUND THEN
                        IF l_debug_level  > 0 THEN
		             							oe_debug_pub.add(  'NO_DATA_FOUND WHEN checking RMA attribute lot number' ) ;
		             				END IF;
		             				FND_MESSAGE.SET_NAME('INV','INV_CHECK_LOT_ENTRY'); -- INVCONV PLSE ENTER A VALID LOT NUMBER
		          					OE_MSG_PUB.Add;
		          					l_return_status := FND_API.G_RET_STS_ERROR;

	       						END IF;


	             		Close c_lot1;



		               /* OPEN c_opm_lot1( l_item_rec.opm_item_id ,
                                          p_Lot_Serial_rec.lot_number );

               			FETCH c_opm_lot1 into l_lot_id;

               			IF c_opm_lot1%NOTFOUND THEN
					IF l_debug_level  > 0 THEN
		             			oe_debug_pub.add(  'NO_DATA_FOUND WHEN checking RMA attribute lot number' ) ;
		             		END IF;
		             		l_lot_id := 0;
		             		FND_MESSAGE.SET_NAME('INV','INV_CHECK_LOT_ENTRY'); -- INVCONV PLSE ENTER A VALID LOT NUMBER
		          		OE_MSG_PUB.Add;
		          		l_return_status := FND_API.G_RET_STS_ERROR;

	       			END IF;

	      			Close c_opm_lot1; */

		           end;

		         END IF; --  IF ( l_RMA_LOT_RESTRICT = 'R' OR -- INVCONV

			/* IF ( l_opm_rma_profile = 'RESTRICTED' OR --INVCONV
		          l_opm_rma_profile = 'RESTRICTED_WITH_WARNING' )
		          -- and l_sublot_ctl = 1 INVCONV
		          and ( p_Lot_Serial_rec.sublot_number <> FND_API.G_MISS_CHAR
		                and p_Lot_Serial_rec.sublot_number IS NOT NULL )
		          then
		              begin
		              OPEN c_opm_lot2( l_item_rec.opm_item_id ,
                                          p_lot_serial_rec.lot_number,
                                          p_lot_serial_rec.sublot_number
                                           );

               			FETCH c_opm_lot2 into l_lot_id;

		               IF c_opm_lot2%NOTFOUND THEN
		            	IF l_debug_level  > 0 THEN
		             			oe_debug_pub.add(  'OPM NO_DATA_FOUND WHEN checking OPM RMA attribute sublot number' ) ;
		             	END IF;
		             	l_lot_id := 0;
		             	FND_MESSAGE.SET_NAME('GMI','IC_SUBLOTNO');
		          	OE_MSG_PUB.Add;
		          	l_return_status := FND_API.G_RET_STS_ERROR;

			       END IF;

	      		      Close c_opm_lot2;
		              end;
	               END IF; -- IF ( l_opm_rma_profile = 'RESTRICTED' OR */


-- validate quantity2
-- added from pre process
		       IF l_debug_level  > 0 THEN
		     		oe_debug_pub.add(  'OE_VALIDATE_LOT_SERIAL.ENTITY - validating QUANTITY2...' ) ;
		       END IF;
		       IF l_tracking_quantity_ind = 'P'  and  --    INVCONV l_dualum_ind < 1 and
		       ( p_lot_serial_rec.quantity2 <> FND_API.G_MISS_NUM
		       and p_lot_serial_rec.quantity2 IS NOT NULL ) then
		         IF l_debug_level  > 0 THEN
			     oe_debug_pub.add(  'INVALID LINE LOT SERIALS QUANTITY2...' ) ; -- INVCONV
			 END IF;
			 FND_MESSAGE.SET_NAME('INV','INV_SECONDARY_QTY_NOT_REQUIRED'); --INVCONV
			 --FND_MESSAGE.SET_TOKEN('ITEM_NO',L_ITEM_NO); INVCONV
			 --FND_MESSAGE.SET_TOKEN('LOT_NO',p_lot_serial_rec.lot_number); INVCONV
			 --FND_MESSAGE.SET_TOKEN('SUBLOT_NO',p_lot_serial_rec.sublot_number); INVCONV
			 OE_MSG_PUB.Add;
			 l_return_status := FND_API.G_RET_STS_ERROR;
		      END IF;

		 	IF l_debug_level  > 0 THEN
			     oe_debug_pub.add(  'OE_VALIDATE_LOT_SERIAL.ENTITY -  validating QUANTITY2 negative ...' ) ;
			END IF;
		/*       If quantity2 is present and negative,  then error */

		  	IF nvl(p_lot_serial_rec.quantity2, 0) < 0 then

		      		FND_MESSAGE.SET_NAME('ONT','SO_PR_NEGATIVE_AMOUNT');
		      		OE_MSG_PUB.Add;
			 	l_return_status := FND_API.G_RET_STS_ERROR;
		      		IF l_debug_level  > 0 THEN
		        		oe_debug_pub.add ('INVALID LINE LOT SERIALS QUANTITY2 - negative....');
		      		END IF;
		      	END IF;
-- added from pre process end


		/* check deviations and defaulting */
		/*  for type 3, check both qty and qty2 are populated */

		        IF l_secondary_default_ind = 'N' then
			--IF  l_dualum_ind = 3 then

				IF l_debug_level  > 0 THEN
			    		 oe_debug_pub.add(  'OE_Validate_Lot_Serial.entity - validating No default dual QUANTITYs...' ) ;
		      		 END IF;
				IF  (NVL(p_Lot_Serial_rec.quantity2,0) = 0 )
          			OR (NVL(p_Lot_Serial_rec.quantity,0 ) = 0 ) THEN
          				FND_MESSAGE.SET_NAME('ONT','OE_BULK_OPM_NULL_QTY');
		      			OE_MSG_PUB.Add;
			 	 	l_return_status := FND_API.G_RET_STS_ERROR;
		      			IF l_debug_level  > 0 THEN
		        			oe_debug_pub.add ('INVALID LINE LOT SERIALS -  one qty is blank for type No Default..');
		      			END IF;
         			END IF;
			END IF; -- IF l_secondary_default_ind = 'N' then

			-- tolerance check for Default and No Default items   (old type 2,3)

			--IF  l_dualum_ind in(2,3)
			IF l_secondary_default_ind in ('N','D')
			and ( p_Lot_Serial_rec.quantity <> FND_API.G_MISS_NUM and
			      NVL(p_Lot_Serial_rec.quantity,0) <> 0 )
			and ( p_Lot_Serial_rec.quantity2 <> FND_API.G_MISS_NUM and
			      NVL(p_Lot_Serial_rec.quantity2,0) <> 0 )
			      then

				l_quantity := p_Lot_Serial_rec.quantity;
				l_quantity2 := p_Lot_Serial_rec.quantity2;
			  l_lot_number := p_Lot_Serial_rec.LOT_NUMBER; -- 4260166 INVCONV


				IF l_debug_level  > 0 THEN
			     		oe_debug_pub.add(  'OE_Validate_Lot_Serial.entity - tolerance check for type Default and No Default  ..' ) ;
		       		END IF;

				/* IF  l_lot_ctl = 2  -- INVCONV PAL bug fix for lot number  -- 4260166
		          	and ( p_Lot_Serial_rec.lot_number <> FND_API.G_MISS_CHAR
		                and p_Lot_Serial_rec.lot_number IS NOT NULL )
		          	then
		          		begin

		                        OPEN c_lot1( l_inventory_item_id,
                                          p_Lot_Serial_rec.lot_number,     -- INVCONV
                                          l_ship_from_org_id );


               				FETCH c_lot1 into l_lot_number;  --  l_sublot_number INVCONV ;

               				IF c_lot1%NOTFOUND THEN

               				  IF l_debug_level  > 0 THEN
			             			oe_debug_pub.add(  'NO_DATA_FOUND for type Default and No default checking lot number' ) ;
			             	 END IF;
                                        END IF;
		                        Close c_lot1;
			                end;

		         	end if; -- IF  l_lot_ctl = 2  -- INVCONV PAL bug fix for lot_number -- 4260166

		     */

				/*   IF l_sublot_ctl = 1 -- INVCONV
			          and ( p_Lot_Serial_rec.sublot_number <> FND_API.G_MISS_CHAR
			                and p_Lot_Serial_rec.sublot_number IS NOT NULL )
			          then
			               begin
		              		OPEN c_opm_lot2( l_item_rec.opm_item_id ,
                                          p_lot_serial_rec.lot_number,
                                          p_lot_serial_rec.sublot_number
                                           );

	               			FETCH c_opm_lot2 into l_lot_id;

			               IF c_opm_lot2%NOTFOUND THEN
			                 IF l_debug_level  > 0 THEN
			             			oe_debug_pub.add(  'OPM NO_DATA_FOUND for type 2,3 tolerance check checking sublot number' ) ;
			             	 END IF;
			             	 l_lot_id := 0;
			               END IF;

		      		      Close c_opm_lot2;
			              end;

				end if; */

			/*-- get opm um from apps um
				GMI_Reservation_Util.Get_OPMUOM_from_AppsUOM
				 (p_Apps_UOM       => l_order_quantity_uom
				 ,x_OPM_UOM        => l_OPM_UOM
				 ,x_return_status  => l_status
				 ,x_msg_count      => l_msg_count
				 ,x_msg_data       => l_msg_data);    	 */

	                     -- check the deviation and error out
			       l_return := INV_CONVERT.Within_Deviation  -- INVCONV
			                       ( p_organization_id   =>
			                                 l_ship_from_org_id
			                       , p_inventory_item_id =>
			                                 l_inventory_item_id
			                       , p_lot_number        => l_lot_number
			                       , p_precision         => 5
			                       , p_quantity          => l_quantity
			                       , p_uom_code1         => l_order_quantity_uom -- INVCONV
			                       , p_quantity2         => l_quantity2
			                       , p_uom_code2         => l_secondary_uom_code );

			      IF l_return = 0
			      	then
			      	    IF l_debug_level  > 0 THEN
			    	  			oe_debug_pub.add('OE_Validate_Lot_Serial.entity - tolerance error 1' ,1);
			    	    END IF;

			    	    l_buffer          := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST, -- INVCONV
			                                         p_encoded => 'F');
			            oe_msg_pub.add_text(p_message_text => l_buffer);
			            IF l_debug_level  > 0 THEN
			              oe_debug_pub.add(l_buffer,1);
			    	    END IF;
			    	    RAISE TOLERANCE_ERROR ;

			     else
			      	    IF l_debug_level  > 0 THEN
			    	  	oe_debug_pub.add('OE_Validate_Lot_Serial.entity - No tolerance error so return ',1);
			    	    END IF;
			    	    x_return_status := 0;
			     	    -- RETURN; INVCONV bug 4099604
			     END IF; -- IF l_return = 0




         			/* check the deviation and error out
      				l_return := GMICVAL.dev_validation(l_item_id
                                     	 ,nvl(l_lot_id, 0)
                                     	 ,l_quantity
                                     	 ,l_OPM_UOM
                                      	,l_quantity2
                                      	,l_item_um2
                                      	,0);

      				IF (l_return = -68 ) THEN
         				l_return_status := FND_API.G_RET_STS_ERROR;
         				FND_MESSAGE.set_name('GMI','IC_DEVIATION_HI_ERR');
         				OE_MSG_PUB.Add;
      				ELSIF(l_return = -69 ) THEN
         				 l_return_status := FND_API.G_RET_STS_ERROR;
         				FND_MESSAGE.set_name('GMI','IC_DEVIATION_LO_ERR');
         				OE_MSG_PUB.Add;
      				END IF;
      				IF l_return <> 0
      				  THEN
      				     l_return_status := FND_API.G_RET_STS_ERROR;

      				END IF;   */

			        IF l_debug_level  > 0 THEN
			     		oe_debug_pub.add(  'OE_Validate_Lot_Serial.entity - after tolerance check for type Default and No default. l_return = ' || l_return  ) ;
		       	        END IF;


			END IF; -- IF l_secondary_default_ind in ('N','D')   invconv IF  l_dualum_ind in (2,3)  then

		-- END IF; -- IF oe_line_util.Process_Characteristics (l_inventory_item_id,l_ship_from_org_id,l_item_rec)  INVCONV

	end if;  -- If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' and OE_GLOBALS.G_UI_FLAG = FALSE Then
-- OPM 3494420 end

    --  Done validating entity

    x_return_status := l_return_status;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_VALIDATE_LOT_SERIAL.ENTITY return status = ' || x_return_status  , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN TOLERANCE_ERROR THEN -- INVCONV
				oe_debug_pub.add('Exception handling: TOLERANCE_ERROR in OE_VALIDATE_LOT_SERIAL.ENTITY', 1);
 				 x_return_status := -1;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;
IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_VALIDATE_LOT_SERIAL.ENTITY return status = ' || x_return_status  , 1 ) ;
    END IF;
END Entity;

--  Procedure Attributes

PROCEDURE Attributes
( x_return_status OUT NOCOPY VARCHAR2

,   p_Lot_Serial_rec                IN  OE_Order_PUB.Lot_Serial_Rec_Type
,   p_old_Lot_Serial_rec            IN  OE_Order_PUB.Lot_Serial_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_REC
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_VALIDATE_LOT_SERIAL.ATTRIBUTES' , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate Lot_Serial attributes

    IF  p_Lot_Serial_rec.created_by IS NOT NULL AND
        (   p_Lot_Serial_rec.created_by <>
            p_old_Lot_Serial_rec.created_by OR
            p_old_Lot_Serial_rec.created_by IS NULL )
    THEN
        IF NOT OE_Validate.Created_By(p_Lot_Serial_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Lot_Serial_rec.creation_date IS NOT NULL AND
        (   p_Lot_Serial_rec.creation_date <>
            p_old_Lot_Serial_rec.creation_date OR
            p_old_Lot_Serial_rec.creation_date IS NULL )
    THEN
        IF NOT OE_Validate.Creation_Date(p_Lot_Serial_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Lot_Serial_rec.from_serial_number IS NOT NULL AND
        (   p_Lot_Serial_rec.from_serial_number <>
            p_old_Lot_Serial_rec.from_serial_number OR
            p_old_Lot_Serial_rec.from_serial_number IS NULL )
    THEN
        IF NOT OE_Validate.From_Serial_Number(p_Lot_Serial_rec.from_serial_number) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Lot_Serial_rec.last_updated_by IS NOT NULL AND
        (   p_Lot_Serial_rec.last_updated_by <>
            p_old_Lot_Serial_rec.last_updated_by OR
            p_old_Lot_Serial_rec.last_updated_by IS NULL )
    THEN
        IF NOT OE_Validate.Last_Updated_By(p_Lot_Serial_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Lot_Serial_rec.last_update_date IS NOT NULL AND
        (   p_Lot_Serial_rec.last_update_date <>
            p_old_Lot_Serial_rec.last_update_date OR
            p_old_Lot_Serial_rec.last_update_date IS NULL )
    THEN
        IF NOT OE_Validate.Last_Update_Date(p_Lot_Serial_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Lot_Serial_rec.last_update_login IS NOT NULL AND
        (   p_Lot_Serial_rec.last_update_login <>
            p_old_Lot_Serial_rec.last_update_login OR
            p_old_Lot_Serial_rec.last_update_login IS NULL )
    THEN
        IF NOT OE_Validate.Last_Update_Login(p_Lot_Serial_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Lot_Serial_rec.line_id IS NOT NULL AND
        (   p_Lot_Serial_rec.line_id <>
            p_old_Lot_Serial_rec.line_id OR
            p_old_Lot_Serial_rec.line_id IS NULL )
    THEN
        IF NOT OE_Validate.Line(p_Lot_Serial_rec.line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Lot_Serial_rec.line_set_id IS NOT NULL AND
        (   p_Lot_Serial_rec.line_set_id <>
            p_old_Lot_Serial_rec.line_set_id OR
            p_old_Lot_Serial_rec.line_set_id IS NULL )
    THEN
        IF NOT OE_Validate.Line_Set(p_Lot_Serial_rec.line_set_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Lot_Serial_rec.lot_number IS NOT NULL AND
        (   p_Lot_Serial_rec.lot_number <>
            p_old_Lot_Serial_rec.lot_number OR
            p_old_Lot_Serial_rec.lot_number IS NULL )
    THEN
        IF NOT OE_Validate.Lot_Number(p_Lot_Serial_rec.lot_number) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    /*IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN

    	IF  p_Lot_Serial_rec.sublot_number IS NOT NULL AND   --OPM 2380194 INVCONV
        	(   p_Lot_Serial_rec.sublot_number <>
            	p_old_Lot_Serial_rec.sublot_number OR
            	p_old_Lot_Serial_rec.sublot_number IS NULL )
    	THEN
        	IF NOT OE_Validate.Sublot_Number(p_Lot_Serial_rec.sublot_number) THEN
            	x_return_status := FND_API.G_RET_STS_ERROR;
        	END IF;
    	END IF;

    END IF; */

    IF  p_Lot_Serial_rec.lot_serial_id IS NOT NULL AND
        (   p_Lot_Serial_rec.lot_serial_id <>
            p_old_Lot_Serial_rec.lot_serial_id OR
            p_old_Lot_Serial_rec.lot_serial_id IS NULL )
    THEN
        IF NOT OE_Validate.Lot_Serial(p_Lot_Serial_rec.lot_serial_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Lot_Serial_rec.quantity IS NOT NULL AND
        (   p_Lot_Serial_rec.quantity <>
            p_old_Lot_Serial_rec.quantity OR
            p_old_Lot_Serial_rec.quantity IS NULL )
    THEN
        IF NOT OE_Validate.Quantity(p_Lot_Serial_rec.quantity) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN

    	IF  p_Lot_Serial_rec.quantity2 IS NOT NULL AND --OPM 2380194
        	(   p_Lot_Serial_rec.quantity2 <>
        	    p_old_Lot_Serial_rec.quantity2 OR
            	    p_old_Lot_Serial_rec.quantity2 IS NULL )
    	THEN

        	IF NOT OE_Validate.Quantity2(p_Lot_Serial_rec.quantity2) THEN
        	        x_return_status := FND_API.G_RET_STS_ERROR;
        	END IF;
    	END IF;

    END IF;

    IF  p_Lot_Serial_rec.to_serial_number IS NOT NULL AND
        (   p_Lot_Serial_rec.to_serial_number <>
            p_old_Lot_Serial_rec.to_serial_number OR
            p_old_Lot_Serial_rec.to_serial_number IS NULL )
    THEN
        IF NOT OE_Validate.To_Serial_Number(p_Lot_Serial_rec.to_serial_number) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  (p_Lot_Serial_rec.attribute1 IS NOT NULL AND
        (   p_Lot_Serial_rec.attribute1 <>
            p_old_Lot_Serial_rec.attribute1 OR
            p_old_Lot_Serial_rec.attribute1 IS NULL ))
    OR  (p_Lot_Serial_rec.attribute10 IS NOT NULL AND
        (   p_Lot_Serial_rec.attribute10 <>
            p_old_Lot_Serial_rec.attribute10 OR
            p_old_Lot_Serial_rec.attribute10 IS NULL ))
    OR  (p_Lot_Serial_rec.attribute11 IS NOT NULL AND
        (   p_Lot_Serial_rec.attribute11 <>
            p_old_Lot_Serial_rec.attribute11 OR
            p_old_Lot_Serial_rec.attribute11 IS NULL ))
    OR  (p_Lot_Serial_rec.attribute12 IS NOT NULL AND
        (   p_Lot_Serial_rec.attribute12 <>
            p_old_Lot_Serial_rec.attribute12 OR
            p_old_Lot_Serial_rec.attribute12 IS NULL ))
    OR  (p_Lot_Serial_rec.attribute13 IS NOT NULL AND
        (   p_Lot_Serial_rec.attribute13 <>
            p_old_Lot_Serial_rec.attribute13 OR
            p_old_Lot_Serial_rec.attribute13 IS NULL ))
    OR  (p_Lot_Serial_rec.attribute14 IS NOT NULL AND
        (   p_Lot_Serial_rec.attribute14 <>
            p_old_Lot_Serial_rec.attribute14 OR
            p_old_Lot_Serial_rec.attribute14 IS NULL ))
    OR  (p_Lot_Serial_rec.attribute15 IS NOT NULL AND
        (   p_Lot_Serial_rec.attribute15 <>
            p_old_Lot_Serial_rec.attribute15 OR
            p_old_Lot_Serial_rec.attribute15 IS NULL ))
    OR  (p_Lot_Serial_rec.attribute2 IS NOT NULL AND
        (   p_Lot_Serial_rec.attribute2 <>
            p_old_Lot_Serial_rec.attribute2 OR
            p_old_Lot_Serial_rec.attribute2 IS NULL ))
    OR  (p_Lot_Serial_rec.attribute3 IS NOT NULL AND
        (   p_Lot_Serial_rec.attribute3 <>
            p_old_Lot_Serial_rec.attribute3 OR
            p_old_Lot_Serial_rec.attribute3 IS NULL ))
    OR  (p_Lot_Serial_rec.attribute4 IS NOT NULL AND
        (   p_Lot_Serial_rec.attribute4 <>
            p_old_Lot_Serial_rec.attribute4 OR
            p_old_Lot_Serial_rec.attribute4 IS NULL ))
    OR  (p_Lot_Serial_rec.attribute5 IS NOT NULL AND
        (   p_Lot_Serial_rec.attribute5 <>
            p_old_Lot_Serial_rec.attribute5 OR
            p_old_Lot_Serial_rec.attribute5 IS NULL ))
    OR  (p_Lot_Serial_rec.attribute6 IS NOT NULL AND
        (   p_Lot_Serial_rec.attribute6 <>
            p_old_Lot_Serial_rec.attribute6 OR
            p_old_Lot_Serial_rec.attribute6 IS NULL ))
    OR  (p_Lot_Serial_rec.attribute7 IS NOT NULL AND
        (   p_Lot_Serial_rec.attribute7 <>
            p_old_Lot_Serial_rec.attribute7 OR
            p_old_Lot_Serial_rec.attribute7 IS NULL ))
    OR  (p_Lot_Serial_rec.attribute8 IS NOT NULL AND
        (   p_Lot_Serial_rec.attribute8 <>
            p_old_Lot_Serial_rec.attribute8 OR
            p_old_Lot_Serial_rec.attribute8 IS NULL ))
    OR  (p_Lot_Serial_rec.attribute9 IS NOT NULL AND
        (   p_Lot_Serial_rec.attribute9 <>
            p_old_Lot_Serial_rec.attribute9 OR
            p_old_Lot_Serial_rec.attribute9 IS NULL ))
    OR  (p_Lot_Serial_rec.context IS NOT NULL AND
        (   p_Lot_Serial_rec.context <>
            p_old_Lot_Serial_rec.context OR
            p_old_Lot_Serial_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_Lot_Serial_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_Lot_Serial_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_Lot_Serial_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_Lot_Serial_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_Lot_Serial_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_Lot_Serial_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_Lot_Serial_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_Lot_Serial_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_Lot_Serial_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_Lot_Serial_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_Lot_Serial_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_Lot_Serial_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_Lot_Serial_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_Lot_Serial_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_Lot_Serial_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_Lot_Serial_rec.context
        );


        --  Validate descriptive flexfield.

        IF NOT OE_Validate.Desc_Flex( 'LOT_SERIAL' ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
*/
    NULL;
    END IF;

    --  Done validating attributes
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_VALIDATE_LOT_SERIAL.ATTRIBUTES' , 1 ) ;
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
            (   G_PKG_NAME
            ,   'Attributes'
            );
        END IF;

END Attributes;

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
( x_return_status OUT NOCOPY VARCHAR2

,   p_Lot_Serial_rec                IN  OE_Order_PUB.Lot_Serial_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    --  Validate entity delete.

    NULL;

    --  Done.

    x_return_status := l_return_status;

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
            (   G_PKG_NAME
            ,   'Entity_Delete'
            );
        END IF;

END Entity_Delete;

PROCEDURE Validate_Lock_Serial_Quantity
( x_return_status OUT NOCOPY VARCHAR2

,   p_x_Lot_Serial_rec              IN  OE_Order_PUB.Lot_Serial_Rec_Type
) IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
NULL;
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
            (   G_PKG_NAME
            ,   'Entity_Delete'
            );
        END IF;

END Validate_Lock_Serial_Quantity;


END OE_Validate_Lot_Serial;

/
