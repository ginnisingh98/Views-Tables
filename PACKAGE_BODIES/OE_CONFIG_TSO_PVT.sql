--------------------------------------------------------
--  DDL for Package Body OE_CONFIG_TSO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CONFIG_TSO_PVT" AS
/* $Header: OEXVTSOB.pls 120.15.12010000.4 2008/11/14 18:53:55 smusanna ship $ */

G_PKG_NAME         CONSTANT VARCHAR2(30) := 'OE_CONFIG_TSO_PVT';


------------------------------------------------------------------
-- Local Procedures and Function Declarations
------------------------------------------------------------------

Procedure  Create_header
(p_sold_to_org_id IN NUMBER
,x_header_id      OUT NOCOPY NUMBER
,x_return_status  OUT NOCOPY VARCHAR2
,x_msg_count      OUT NOCOPY NUMBER
,x_msg_data       OUT NOCOPY VARCHAR2);

PROCEDURE Create_TSO_Order_Lines
(p_header_id               IN           NUMBER
,p_top_model_line_id       IN           NUMBER
,p_instance_tbl            IN           csi_datastructures_pub.instance_cz_tbl
,x_msg_data                OUT NOCOPY   VARCHAR2
,x_msg_count               OUT NOCOPY   NUMBER
,x_return_status           OUT NOCOPY   VARCHAR2);

PROCEDURE Populate_MACD_action(
  p_header_id           IN  NUMBER
 ,p_instance_tbl        IN  csi_datastructures_pub.instance_cz_tbl
 ,p_x_Line_Tbl          IN  OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
 ,p_Extended_Attrib_Tbl IN  csi_datastructures_pub.ext_attrib_values_tbl
 ,p_macd_action         IN VARCHAR2
-- ,x_config_item_tbl   OUT NOCOPY CZ_API_PUB.config_tbl_type;
-- ,x_config_ext_attr_tbl OUT NOCOPY config_ext_attr_tbl_type
 ,x_msg_data            OUT NOCOPY   VARCHAR2
 ,x_msg_count           OUT NOCOPY   NUMBER
 ,x_return_status       OUT NOCOPY   VARCHAR2);


Procedure IS_Container_Present
(p_header_id                  IN NUMBER
,p_config_instance_hdr_id     IN NUMBER
,p_config_instance_rev_number IN NUMBER
,x_top_model_line_id          OUT NOCOPY NUMBER);

Procedure Validate_action
(p_top_model_line_id  IN  NUMBER
,p_instance_item_id IN  NUMBER
,p_macd_action        IN  VARCHAR2
,x_config_item_id     OUT NOCOPY NUMBER
,x_component_code     OUT NOCOPY VARCHAR2
,x_return_status      OUT NOCOPY VARCHAR2);

Procedure Validate_line_action
(p_line_id IN NUMBER
,P_config_header_id IN NUMBER
,P_config_rev_nbr   IN NUMBER
,P_config_item_id   IN NUMBER
,P_macd_action       IN NUMBER
,x_return_status       OUT NOCOPY VARCHAR2);

Procedure Populate_new_to_old
(p_Instance_Tbl       IN  csi_datastructures_pub.instance_cz_tbl
,x_instance_tbl       OUT NOCOPY csi_datastructures_pub.instance_cz_tbl)
IS

BEGIN

 FOR I IN 1..p_Instance_Tbl.count  LOOP

   x_instance_tbl(I).ITEM_INSTANCE_ID           := p_Instance_Tbl(I).ITEM_INSTANCE_ID;
   x_instance_tbl(I).CONFIG_INSTANCE_HDR_ID     := p_Instance_Tbl(I).CONFIG_INSTANCE_HDR_ID;
   x_instance_tbl(I).CONFIG_INSTANCE_REV_NUMBER := p_Instance_Tbl(I).CONFIG_INSTANCE_REV_NUMBER;
   x_instance_tbl(I).CONFIG_INSTANCE_ITEM_ID    := p_Instance_Tbl(I).CONFIG_INSTANCE_ITEM_ID;
   x_instance_tbl(I).BILL_TO_SITE_USE_ID        := p_Instance_Tbl(I).BILL_TO_SITE_USE_ID;
   x_instance_tbl(I).SHIP_TO_SITE_USE_ID        := p_Instance_Tbl(I).SHIP_TO_SITE_USE_ID;
   x_instance_tbl(I).INSTANCE_NAME              := p_Instance_Tbl(I).INSTANCE_NAME;

 END LOOP;

END Populate_new_to_old;
PROCEDURE Print_Time(p_msg   IN  VARCHAR2);


-----------------------------------------------------------------
-- Name        :   Print_Time
-- Parameters  :   IN  p_msg
--
-- Description :   This Procedure will print Current time along
--                 with the Debug Message Passed as input.
--                 This Procedure will be called from Main
--                 Procedures to print Entering and Leaving Msg
-----------------------------------------------------------------

PROCEDURE Print_Time(p_msg   IN  VARCHAR2)
IS
  l_time    VARCHAR2(100);
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  l_time := to_char (new_time (sysdate, 'PST', 'EST'),
                               'DD-MON-YY HH24:MI:SS');
  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add(p_msg || ': '|| l_time, 1);
  END IF;
END Print_Time;


/*-----------------------------------------------------------------
-- Name        :   Is_Part_of_Container_Model
-- Parameters  :   IN p_line_id
--                 IN p_top_model_line_id
--                 IN p_ato_line_id
--                 IN p_inventory_item_id
--                 OUT x_top_container_model
--                 OUT x_part_of_container

-- Description :   This API determines if an order line is
--                 part of a container model configuration.
--                 Can also be used to determine if input order
--                 line itself is the top-level container model
--
How to use it:

For a top model line
you can pass inv item id -- if the operation is CREATE i.e.
the line is not in database yet, you should only use inv item id
OR
you can pass the line_id, top_model_line_id etc. if available, this is
better for performance.

For a child line
if operation is CREATE i.e.
the line is not in database yet, you should either pass inv item id
of the parent line or pass operation of CREATE and pass top_model_line_id.
you can also pass the parent line's inv item id directly if you have it
in case of operation of CREATE
OR
you can pass the line_id, top_model_line_id etc. if available, this is
better for performance.

--
-- Change Record :
Added p_operation as a parameter and consolidated some code in to
support it.
------------------------------------------------------------------*/

PROCEDURE Is_Part_of_Container_Model
( p_line_id               IN   NUMBER DEFAULT NULL
, p_top_model_line_id     IN   NUMBER DEFAULT NULL
, p_ato_line_id           IN   NUMBER DEFAULT NULL
, p_inventory_item_id     IN   NUMBER DEFAULT NULL
, p_operation             IN   VARCHAR2 DEFAULT NULL
, p_org_id		  IN   NUMBER DEFAULT NULL --Bug 5524710
, x_top_container_model   OUT  NOCOPY VARCHAR2
, x_part_of_container     OUT  NOCOPY VARCHAR2
)
IS
  l_ato_line_id               NUMBER;
  l_bom_item_type             NUMBER;
  l_config_model_type         VARCHAR2(30);
  l_replenish_to_order_flag   VARCHAR2(1);
  l_top_model_line_id         NUMBER;
  l_inventory_item_id         NUMBER;
  l_debug_level               CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  Print_Time('Entering OE_CONFIG_TSO_PVT.Is_Part_of_Container_Model..');

  l_top_model_line_id    :=   p_top_model_line_id;
  l_ato_line_id          :=   p_ato_line_id;
  l_inventory_item_id    :=   p_inventory_item_id;
  x_part_of_container    :=   'N';
  x_top_container_model  :=   'N';

  IF l_debug_level > 0 THEN
    OE_DEBUG_PUB.Add('Line Id   : '|| p_line_id ,3);
    OE_DEBUG_PUB.Add('Top Model Line id:'|| l_top_model_line_id,3);
    OE_DEBUG_PUB.Add('ATO Line id: '|| l_ato_line_id,3);
    OE_DEBUG_PUB.Add('operation  : '|| p_operation,3);
    OE_DEBUG_PUB.Add('inv item   : '|| p_inventory_item_id,3);
  END IF;

  --operation is sent in only by OEXLLINB right now
  IF p_operation = OE_GLOBALS.G_OPR_CREATE THEN

    IF l_debug_level > 0 THEN
       OE_DEBUG_PUB.Add('Operation is CREATE',3);
       OE_DEBUG_PUB.Add('Inv Item ID:'||p_inventory_item_id,3);
    END IF;

    IF p_top_model_line_id = p_line_id THEN
       IF p_inventory_item_id is NULL THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    ELSE

      SELECT inventory_item_id
      INTO   l_inventory_item_id
      FROM   oe_order_lines
      WHERE  line_id = p_top_model_line_id;

      IF l_debug_level > 0 THEN
         OE_DEBUG_PUB.Add('Get Parent Item Id for:'||p_inventory_item_id,3);
         OE_DEBUG_PUB.Add('Parent item id is:'||l_inventory_item_id,3);
      END IF;

    END IF;
  ELSIF p_operation = 'UPDATE' OR
        p_operation = 'DELETE' THEN

    IF l_debug_level > 0 THEN
       OE_DEBUG_PUB.Add('Operation is UPDATE/DELETE',3);
       OE_DEBUG_PUB.Add('l_inventory_item_id set to NULL',3);
    END IF;

    l_inventory_item_id := null;

  END IF;


  IF l_inventory_item_id IS NOT NULL THEN

     IF l_debug_level > 0 THEN
	  OE_DEBUG_PUB.Add('Inventory Item id:'||l_inventory_item_id,3);
     END IF;

     SELECT mtl_msi.bom_item_type
	   ,mtl_msi.replenish_to_order_flag
	   ,mtl_msi.config_model_type
     INTO   l_bom_item_type
           ,l_replenish_to_order_flag
	   ,l_config_model_type
     FROM  mtl_system_items mtl_msi
     WHERE mtl_msi.inventory_item_id = l_inventory_item_id
     AND   mtl_msi.organization_id=OE_SYS_PARAMETERS.Value('MASTER_ORGANIZATION_ID',p_org_id); --Bug 5524710

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('BOM Item Type:'||l_bom_item_type,3);
        OE_DEBUG_PUB.Add('Replenish to Order:'||l_replenish_to_order_flag,3);
        OE_DEBUG_PUB.Add('Config Model Type:'||l_config_model_type,3);
     END IF;

     IF l_bom_item_type = 1 AND
        l_replenish_to_order_flag = 'N' AND
        l_config_model_type = 'N' THEN

        IF  p_inventory_item_id = l_inventory_item_id THEN
            x_top_container_model := 'Y';
        END IF;

        x_part_of_container := 'Y';

     END IF;

     IF l_debug_level > 0 THEN
       OE_DEBUG_PUB.Add('Top Container Model?:'||x_top_container_model,3);
       OE_DEBUG_PUB.Add('Part of Container Model?:'||x_part_of_container,3);
     END IF;

     Print_Time ('Exiting OE_CONFIG_TSO_PVT.Is_Part_Of_Container_Model..');

     RETURN;
  END IF;  -- inv item id is not null;

  ------------------- if line_id is to be used -----------------
  IF p_line_id IS NOT NULL THEN

     IF l_debug_level > 0 THEN
	OE_DEBUG_PUB.Add('Line Id:'||p_line_id ,3);
	OE_DEBUG_PUB.Add('Top Model Line id:'||l_top_model_line_id,3);
	OE_DEBUG_PUB.Add('ATO Line id:'||l_ato_line_id,3);
     END IF;

     IF l_top_model_line_id IS NULL OR
	l_ato_line_id IS NULL THEN

	SELECT top_model_line_id,ato_line_id
     	INTO   l_top_model_line_id,l_ato_line_id
	FROM   oe_order_lines
	WHERE  line_id = p_line_id;

        IF l_debug_level > 0 THEN
	   OE_DEBUG_PUB.Add('Top Model Line id:'||l_top_model_line_id,3);
	   OE_DEBUG_PUB.Add('ATO Line id:'||l_ato_line_id,3);
	END IF;

     END IF;

     IF l_top_model_line_id IS NOT NULL AND
	l_ato_line_id IS NULL THEN

	SELECT mtl_msi.config_model_type
        INTO   l_config_model_type
        FROM   mtl_system_items mtl_msi, oe_order_lines oe_l
	WHERE  oe_l.line_id      =  l_top_model_line_id
	AND    oe_l.inventory_item_id =  mtl_msi.inventory_item_id
        AND    mtl_msi.organization_id = OE_SYS_PARAMETERS.Value('MASTER_ORGANIZATION_ID',p_org_id);  --Bug 5524710

        IF l_debug_level > 0 THEN
	   OE_DEBUG_PUB.Add('Model Type:'||l_config_model_type,2);
        END IF;

        IF l_config_model_type = 'N' THEN
           x_part_of_container := 'Y';
           IF l_top_model_line_id = p_line_id THEN
              x_top_container_model := 'Y';
           END IF;
        ELSE
           x_part_of_container := 'N';
        END IF;

        IF l_debug_level > 0 THEN
           OE_DEBUG_PUB.Add('Top Container Model?:'||x_top_container_model,3);
           OE_DEBUG_PUB.Add('Part of Container Model?:'||x_part_of_container,3);
        END IF;
        Print_Time('Exiting OE_CONFIG_TSO_PVT.Is_Part_of_Container_Model..');

	RETURN;

     END IF;

   END IF; --p_line_id is NOT NULL

   IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add('Top Container Model?:'||x_top_container_model,3);
      OE_DEBUG_PUB.Add('Part of Container Model?:'||x_part_of_container,3);
   END IF;
   Print_Time('Exiting OE_CONFIG_TSO_PVT.Is_Part_of_Container_Model..');

EXCEPTION

   WHEN NO_DATA_FOUND THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('No data found in Is_Part_of_Container_Model:'
                         ||sqlerrm, 3);
     END IF;
     RAISE FND_API.G_EXC_ERROR;

   WHEN TOO_MANY_ROWS THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Too Many Rows in Is_Part_of_Container_Model:'
			 ||sqlerrm, 3);
     END IF;
     RAISE FND_API.G_EXC_ERROR;

   WHEN OTHERS THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Other error in Is_Part_Of_Container_Model:'
                         ||sqlerrm,1);
     END IF;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	OE_MSG_PUB.Add_Exc_Msg
	(  G_PKG_NAME
          ,'Is_Part_of_Container_Model' );
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Is_Part_of_Container_Model;



-----------------------------------------------------------------
-- Name        :   Validate_Container_Model
-- Parameters  :   IN p_x_line_rec
--                 IN p_old_line_rec
--                 OUT x_return_status
--
-- Description :  This API is used to validate or restrict
--                certain restrictions for the MACD orders.
--		  It is called from the OE_Validate_Line.Entity
--                during the entity level validation
--
-- Change Record :
------------------------------------------------------------------
PROCEDURE Validate_Container_Model
( p_line_rec           IN             OE_Order_Pub.Line_Rec_Type
, p_old_line_rec       IN             OE_Order_Pub.Line_Rec_Type
, x_return_status      OUT NOCOPY     VARCHAR2
)
IS
  l_delta                        NUMBER;
  l_part_of_container_model      VARCHAR2(1);
  l_return_status                VARCHAR2(1);
  l_top_container_model          VARCHAR2(1);
  l_description                  VARCHAR2(240);
  l_debug_level         CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_config_mode                  NUMBER;
  l_x_return_status              VARCHAR2(1);

  l_ib_trackable_flag            VARCHAR2(1);
BEGIN

  Print_Time('Entering OE_CONFIG_TSO_PVT.Validate_Container_model...');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('Before Calling Is_Part_Of_Container_Model...',3);
  END IF;

  OE_CONFIG_TSO_PVT.Is_Part_Of_Container_Model
  (  p_line_id                 => p_line_rec.line_id
    ,p_top_model_line_id       => p_line_rec.top_model_line_id
    ,p_ato_line_id             => p_line_rec.ato_line_id
    ,p_inventory_item_id       => p_line_rec.inventory_item_id
    ,p_operation               => p_line_rec.operation
    ,x_top_container_model     => l_top_container_model
    ,x_part_of_container       => l_part_of_container_model );

--Abghosh

  IF l_part_of_container_model = 'N'  THEN

     IF p_line_rec.ib_owner='INSTALL_BASE' THEN
        IF l_debug_level > 0 THEN
           OE_DEBUG_PUB.Add('IB validation failed: IB_OWNER',3);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','IB_OWNER');
        OE_MSG_PUB.Add;
     END IF;

     IF p_line_rec.ib_installed_at_location='INSTALL_BASE' THEN
        IF l_debug_level > 0 THEN
           OE_DEBUG_PUB.Add('IB validation failed: INSTALLED_AT_LOCATION',3);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','IB_INSTALLED_AT_LOCATION');
	OE_MSG_PUB.Add;
     END IF;

     IF p_line_rec.ib_current_location='INSTALL_BASE' THEN
        IF l_debug_level > 0 THEN
           OE_DEBUG_PUB.Add('IB validation failed: IB_CURRENT_LOCATION',3);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','IB_CURRENT_LOCATION');
        OE_MSG_PUB.Add;
     END IF;

  END IF;
-- Abghoshend contd

  IF l_part_of_container_model = 'N' THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Not a part of container model, hence RETURNing',3);
     END IF;
     Print_Time ('Exiting OE_CONFIG_TSO_PVT.Validate_Container_Model...');
     RETURN;
  END IF;

 -- Abghosh

  IF l_part_of_container_model='Y'  AND
   (p_line_rec.ib_owner='INSTALL_BASE'    OR
    p_line_rec.ib_installed_at_location='INSTALL_BASE' OR
    p_line_rec.ib_current_location='INSTALL_BASE')  THEN


    OE_CONFIG_TSO_PVT.Get_MACD_Action_Mode
    (  p_line_rec          => p_line_rec
      ,p_check_ibreconfig  => 'Y'
      ,x_config_mode       => l_config_mode
      ,x_return_status     => l_x_return_status );

    IF l_debug_level >0 THEN
       OE_DEBUG_PUB.ADD('l_config_mode='||l_config_mode);
    END IF;

-- Bug 3677344
    IF l_x_return_status= FND_API.G_RET_STS_ERROR THEN
      Raise  FND_API.G_EXC_ERROR ;
    ELSIF l_x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      Raise  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
 -- Bug 3677344
  END IF;

  IF l_config_mode = 1  THEN

     IF p_line_rec.ib_owner='INSTALL_BASE' THEN
        IF l_debug_level > 0 THEN
           OE_DEBUG_PUB.Add('IB validation failed: IB_OWNER');
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name('IB_OWNER'));
        OE_MSG_PUB.Add;
     END IF;

     IF p_line_rec.ib_installed_at_location='INSTALL_BASE' THEN
        IF l_debug_level > 0 THEN
           OE_DEBUG_PUB.Add('IB validation failed: INSTALLED_AT_LOCATION',3);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name('IB_INSTALLED_AT_LOCATION'));
        OE_MSG_PUB.Add;
     END IF;

     IF p_line_rec.ib_current_location='INSTALL_BASE' THEN
        IF l_debug_level > 0 THEN
           OE_DEBUG_PUB.Add('IB validation failed: IB_CURRENT_LOCATION', 3);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name('IB_CURRENT_LOCATION'));
        OE_MSG_PUB.Add;
     END IF;

  END IF;

--Abghosh

  -- Reconfigure of MACD order after booking is not supported.
  -- Reconfiguring can be only for a top model line.
  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('Inv Item Id:'||p_line_rec.inventory_item_id,3);
     OE_DEBUG_PUB.Add('Item:'||p_line_rec.ordered_item,3);
     OE_DEBUG_PUB.Add('Ord Qty (New):'||p_line_rec.ordered_quantity,3);
     OE_DEBUG_PUB.Add('Cancelled Flag:'||p_line_rec.cancelled_flag,3);
     OE_DEBUG_PUB.Add('Cascade Changes:'
                         ||OE_CONFIG_UTIL.Cascade_Changes_Flag,3);
     OE_DEBUG_PUB.Add('VAL_CT_MDL_CHK: No Reconfig of order after booking',3);
     OE_DEBUG_PUB.Add('Booked flag:'||p_line_rec.booked_flag,3);
     OE_DEBUG_PUB.Add('Operation:'||p_line_rec.operation,3);
     OE_DEBUG_PUB.Add('Old Ord Qty:'||p_old_line_rec.ordered_quantity,3);
  END IF;

  IF NVL(p_line_rec.booked_flag,'N') = 'Y' AND
     (p_line_rec.operation=OE_GLOBALS.G_OPR_CREATE OR
     (p_line_rec.operation=OE_GLOBALS.G_OPR_UPDATE AND
     NOT OE_Globals.Equal(p_line_rec.ordered_quantity,
                            p_old_line_rec.ordered_quantity)) OR
     p_line_rec.operation=OE_GLOBALS.G_OPR_DELETE) THEN

     IF ( p_line_rec.cancelled_flag = 'Y' AND p_line_rec.ordered_quantity = 0 AND (OE_CONFIG_UTIL.Cascade_Changes_Flag = 'Y' OR l_top_container_model = 'Y') )
        OR
        ( p_line_rec.ordered_quantity = 0 and nvl(p_line_rec.model_remnant_flag, 'N') = 'Y' )  --OR condition Added for fp bug 5662532
     THEN

      	 IF l_debug_level > 0 THEN
      	    OE_DEBUG_PUB.Add('Note: Booked MACD Order Cancel Allowed',3);
      	 END IF;
     ELSE
        IF p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_INCLUDED THEN
           Null;
        ELSE
           x_return_status := FND_API.G_RET_STS_ERROR;
	       FND_MESSAGE.SET_NAME('ONT','ONT_TSO_BOOKED_ORDER');
	       OE_MSG_PUB.Add;
        END IF;
	 IF l_debug_level > 0 THEN
	    OE_DEBUG_PUB.Add('ERRM: Reconfigure after booking is not supported',3);
         END IF;
     END IF;

  END IF; --booked flag = y

  --Qty of IB trackable item that is part of container model should not
  --other than 1 unless it is cancellation, when qty = 0
  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add ('VAL_CT_MDL_CHK: Ib trackable component value <> 1',3);
  END IF;
  IF (p_line_rec.cancelled_flag = 'Y' AND p_line_rec.ordered_quantity = 0 AND ( OE_CONFIG_UTIL.Cascade_Changes_Flag = 'Y' OR l_top_container_model = 'Y'))
      OR
     ( p_line_rec.ordered_quantity = 0 and nvl(p_line_rec.model_remnant_flag, 'N') = 'Y' )  --OR condition Added for fp:bug 5662532

  THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add ('Note:Cancellation allowed',1);
     END IF;
  ELSE
     IF l_top_container_model = 'Y' AND p_line_rec.ordered_quantity <> 1 THEN -- 7217602

  	SELECT nvl(comms_nl_trackable_flag, 'N')
  	INTO l_ib_trackable_flag
  	FROM mtl_system_items
  	WHERE inventory_item_id = p_line_rec.inventory_item_id
  	AND organization_id = OE_SYS_PARAMETERS.Value('MASTER_ORGANIZATION_ID');

  	IF l_ib_trackable_flag = 'Y' THEN
  	   IF l_debug_level > 0 THEN
  	      OE_DEBUG_PUB.Add ('Item is IB trackable',3);
              OE_DEBUG_PUB.Add('ERRM: IB trackable item Ordered Quantity must be 1 Only',3);
  	   END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.SET_NAME ('ONT','ONT_TSO_ORD_QTY_NOT_ONE');
           OE_MSG_PUB.Add;
  	ELSE
  	   IF l_debug_level > 0 THEN
  	      OE_DEBUG_PUB.Add('Note: Item not IB trackable',3);
	      OE_DEBUG_PUB.Add('This line qty not restricted to 1',3);
  	   END IF;
        END IF;

     END IF; --ord qty > 1
  END IF;

  -- Line type change for components of a container model
  --is not allowed
  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('VAL_CT_MDL_CHK: line type change for components of container',3);
     OE_DEBUG_PUB.Add('New line type:'||p_line_rec.line_type_id,3);
     OE_DEBUG_PUB.Add('Old line type:'||p_old_line_rec.line_type_id,3);
     OE_DEBUG_PUB.Add('New line operation:'||p_line_rec.operation,3);
     OE_DEBUG_PUB.Add('OECFG_VALIDATE_CONFIG Flag:'
                      || OE_CONFIG_PVT.OECFG_VALIDATE_CONFIG,3);
  END IF;

  IF (NOT OE_GLOBALS.EQUAL(p_line_rec.line_type_id
      ,p_old_line_rec.line_type_id)) AND
      p_line_rec.operation  =   OE_GLOBALS.G_OPR_UPDATE AND
      OE_CONFIG_PVT.OECFG_VALIDATE_CONFIG = 'Y' THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MESSAGE.SET_NAME ('ONT','ONT_TSO_NO_LINE_TYPE_CHANGE');
      OE_MSG_PUB.Add;

      IF l_debug_level > 0 THEN
         OE_DEBUG_PUB.Add('ERRM: Line Type Change not allowed for MACD orders',3);
      END IF;

  END IF;

  -- Line below top model of the config can be deleted only if
  -- the line has not changed in CZ
  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('VAL_CT_MDL_CHK: Del of opt items only if no change in CZ',3);
     OE_DEBUG_PUB.Add('New line operation:'||p_line_rec.operation,3);
     OE_DEBUG_PUB.Add('OECFG_VALIDATE_CONFIG Flag:'
                      || OE_CONFIG_PVT.OECFG_VALIDATE_CONFIG,3);
  END IF;

  IF p_line_rec.operation = OE_GLOBALS.G_OPR_DELETE AND
     OE_CONFIG_PVT.OECFG_VALIDATE_CONFIG = 'Y' THEN

     IF NVL(p_line_rec.booked_flag,'N')='N' THEN

	BEGIN

	  SELECT 1
	  INTO   l_delta
          FROM   cz_config_details_v
	  WHERE  config_delta = 0
          AND    config_hdr_id    =  p_line_rec.config_header_id
	  AND    config_rev_nbr   =  p_line_rec.config_rev_nbr
	  AND    config_item_id   =  p_line_rec.configuration_id;

        EXCEPTION

	   WHEN NO_DATA_FOUND THEN
   	     IF l_debug_level > 0 THEN
	        OE_DEBUG_PUB.Add('ERRM: No Data Found when selecting config delta',3);

                SELECT description
                INTO l_description
                FROM cz_config_details_v cz_czv, mtl_system_items mtl_msi
                WHERE cz_czv.inventory_item_id = mtl_msi.inventory_item_id
                AND cz_czv.config_delta <> 0 --implies change
                AND cz_czv.config_hdr_id = p_line_rec.config_header_id
                AND cz_czv.config_rev_nbr = p_line_rec.config_rev_nbr
                AND cz_czv.config_item_id = p_line_rec.configuration_id;
	     END IF;
	     l_delta  := 0;
        END;

        IF l_delta = 0 THEN
           x_return_status:=FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.SET_NAME('ONT','ONT_TSO_DELETE_NOT_ALLOWED');
           FND_MESSAGE.SET_TOKEN('ITEM_DESCRIPTION',l_description);
	   OE_MSG_PUB.Add;
           IF l_debug_level > 0 THEN
              OE_DEBUG_PUB.Add('ERRM: Line changed in CZ, delete not allowed',3);
           END IF;
        END IF;

     END IF; --booked flag = n

  END IF;	--operation=delete


  -- Field sold_to_org_id on the header cannot be updated
  -- once an item instance has been selected on a line.
  -- Also, sold_to_org_id on a line holding a reconfigured
  -- Also item instance cannot be updated
  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('VAL_CT_MDL_CHK: No change in sold_to_org_id allowed',3);
     OE_DEBUG_PUB.Add('New line rec sold to:'||p_line_rec.sold_to_org_id,3);
     OE_DEBUG_PUB.Add('Old line rec sold to:'||p_old_line_rec.sold_to_org_id,3);
     OE_DEBUG_PUB.Add('New line operation:'||p_line_rec.operation,3);
  END IF;
  IF NOT OE_GLOBALS.EQUAL(p_line_rec.sold_to_org_id,
     p_old_line_rec.sold_to_org_id) AND
     p_line_rec.operation=OE_GLOBALS.G_OPR_UPDATE  THEN

     x_return_status := FND_API.G_RET_STS_ERROR;

     FND_MESSAGE.SET_NAME('ONT','ONT_TSO_NO_CUSTOMER_CHANGE');
     OE_MSG_PUB.Add;

     IF l_debug_level > 0 THEN
	OE_DEBUG_PUB.Add('ERRM: Customer Change not allowed for MACD orders',3);
     END IF;

  END IF;

  IF l_debug_level > 0 THEN
     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        OE_DEBUG_PUB.Add('All validations for container model passed',3);
     ELSE
        OE_DEBUG_PUB.Add('ERR:Validations violation for container model',3);
     END IF;
  END IF;

  Print_Time('Exiting OE_CONFIG_TSO_PVT.Validate_Container_Model...');

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Expected Error in Validate_Container_Model:'
                         ||sqlerrm,3);
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Unexpected Error Validate_Container_Model:'
                         ||sqlerrm,3);
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Other error in Validate_Container_Model:'
                          ||sqlerrm,1);
     END IF;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	OE_MSG_PUB.Add_Exc_Msg
        (  G_PKG_NAME
          ,'Validate_Container_Model' );
     END IF;


END Validate_Container_Model;


/*----------------------------------------------------------------
 Name        :   Get_MACD_Action_Mode
 Parameters  :   IN p_top_model_line_id
                 IN p_line_id
                 OUT x_config_mode

 Description :   This procedure is used to detect a new
                 configuration vs a re-configuration.
                 By new configuration we mena when model order
                 line was already configured using Configurator
                 alone without first doing an IB instance search



Change Record:  Change in specifications and logic as per HLD ver 4.9
added p_x_line_rec so that the api can be called during
operation create.

How to use this api:
1) call this api only if the line is part of a container model.

2) pass anyone of the 3 input parameters, we will use different
sqls to and will go in order of,
p_top_model_line_id
p_line_id
p_line_rec

pass p_line_rec if the line is yet not saved in oe_order_lines.

if you pass p_line_id or p_top_model_line_id, api assumes
that the lines are saved in oe_order_lines.

3) if p_check_ibreconfig is passed, pass p_line_rec as well.


4) x_config_mode will be,
1 - new config
2 - re-config as in change made in cz.
3 - re-config only query from ib, no change in cz for this line or
the configuration based on i/p parameter passed.
4 - there are one or more components changed in cz for the top model.
null - incorrect input parameters or products not installed or
exception or top model getting created from ui.

5) from copy_order - call this api with top_model_line_id of the
model that is getting copied and try to avoind calling if
called for one line in that model as it would get same
results for all lines in that model.

6) for ib fields validation send p_line_rec and p_check_ibrconfig
-----------------------------------------------------------------*/

PROCEDURE Get_MACD_Action_Mode
( p_line_rec          IN OE_Order_pub.Line_Rec_Type := null
, p_line_id           IN NUMBER := null
, p_top_model_line_id IN NUMBER := null
, p_check_ibreconfig  IN VARCHAR2 := null
, x_config_mode       OUT NOCOPY NUMBER
, x_return_status     OUT NOCOPY VARCHAR2
)
IS
  l_baseline_rev_nbr     NUMBER(9);
  l_debug_level          CONSTANT  NUMBER := oe_debug_pub.g_debug_level;
  l_status               VARCHAR2(1);
  l_ind                  VARCHAR2(1);
  l_schema               VARCHAR2(30);

BEGIN
  Print_Time('Entering OE_CONFIG_TSO_PVT.Get_MACD_Action_Mode..');

  x_config_mode := null;

  BEGIN

    IF p_top_model_line_id is NOT NULL THEN

      IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('using top_model_line_id ' || p_top_model_line_id, 1);
      END IF;

      SELECT cz_hdr.baseline_rev_nbr
      INTO   l_baseline_rev_nbr
      FROM   cz_config_hdrs cz_hdr, oe_order_lines oe_line,
             cz_config_items czi
      WHERE oe_line.top_model_line_id = p_top_model_line_id
      AND    czi.config_hdr_id     = oe_line.config_header_id
      AND    czi.config_rev_nbr    = oe_line.config_rev_nbr
      AND    czi.config_item_id    = oe_line.configuration_id
      AND    cz_hdr.config_hdr_id  = czi.instance_hdr_id
      AND    cz_hdr.config_rev_nbr = czi.instance_rev_nbr
      AND    cz_hdr.baseline_rev_nbr is not NULL
      AND    rownum = 1;

      IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('top model baseline rev exists', 1);
      END IF;

      x_config_mode := 3;

      BEGIN
        SELECT czi.config_delta
        INTO   l_baseline_rev_nbr
        FROM   cz_config_hdrs cz_hdr, oe_order_lines oe_line,
               cz_config_items czi
        WHERE oe_line.top_model_line_id = p_top_model_line_id
        AND    czi.config_hdr_id     = oe_line.config_header_id
        AND    czi.config_rev_nbr    = oe_line.config_rev_nbr
        AND    czi.config_item_id    = oe_line.configuration_id
        AND    nvl(czi.config_delta, 0) > 0
        AND    cz_hdr.config_hdr_id  = czi.instance_hdr_id
        AND    cz_hdr.config_rev_nbr = czi.instance_rev_nbr
        AND    cz_hdr.baseline_rev_nbr is not NULL
        AND    rownum = 1;

        IF l_debug_level > 0 THEN
          OE_DEBUG_PUB.Add('111 config delta > 0', 1);
        END IF;

        x_config_mode := 4;
      EXCEPTION
        WHEN no_data_found THEN
          IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('no data 111 - no config delta so ib reonfig', 1);
          END IF;
      END;

      IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('top model x_config_mode ' || x_config_mode, 1);
      END IF;
      Print_Time ('Exiting OE_CONFIG_TSO_PVT.Get_MACD_Action_Mode');
      RETURN;

    ELSIF p_line_id is NOT NULL THEN

      IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('using line_id ' || p_line_id, 1);
      END IF;

      SELECT cz_hdr.baseline_rev_nbr
      INTO   l_baseline_rev_nbr
      FROM   cz_config_hdrs cz_hdr, oe_order_lines oe_line,
             cz_config_items czi
      WHERE  oe_line.line_id       = p_line_id
      AND    czi.config_hdr_id     = oe_line.config_header_id
      AND    czi.config_rev_nbr    = oe_line.config_rev_nbr
      AND    czi.config_item_id    = oe_line.configuration_id
      AND    cz_hdr.config_hdr_id  = czi.instance_hdr_id
      AND    cz_hdr.config_rev_nbr = czi.instance_rev_nbr
      AND    cz_hdr.baseline_rev_nbr is NOT NULL;

      x_config_mode := 3;

      BEGIN
        SELECT czi.config_delta
        INTO   l_baseline_rev_nbr
        FROM   oe_order_lines oe_line,
               cz_config_items czi
        WHERE  oe_line.line_id       = p_line_id
        AND    czi.config_hdr_id     = oe_line.config_header_id
        AND    czi.config_rev_nbr    = oe_line.config_rev_nbr
        AND    czi.config_item_id    = oe_line.configuration_id
        AND    nvl(czi.config_delta, 0) > 0;

        x_config_mode := 2;

        IF l_debug_level > 0 THEN
          OE_DEBUG_PUB.Add('222 config delta > 0', 1);
        END IF;
      EXCEPTION
        WHEN no_data_found THEN
          IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('no data 222 - no config delta so ib reonfig', 1);
          END IF;
      END;


      IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('p_line_id x_config_mode ' || x_config_mode, 1);
      END IF;

      Print_Time ('Exiting OE_CONFIG_TSO_PVT.Get_MACD_Action_Mode');
      RETURN;

    ELSIF p_line_rec.line_id is NOT NULL THEN

      IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('using line_rec ' || p_line_rec.line_id, 1);
        OE_DEBUG_PUB.Add('Config Hdr:'||p_line_rec.config_header_id,1);
	OE_DEBUG_PUB.Add('Config Rev:'||p_line_rec.config_rev_nbr,1);
	OE_DEBUG_PUB.Add('Config ID:'||p_line_rec.configuration_id,1);
	OE_DEBUG_PUB.Add('OrdItem:'||p_line_rec.ordered_item,1);
      END IF;

      IF p_line_rec.top_model_line_id is NULL OR
         p_line_rec.config_header_id is NULL OR
         p_line_rec.config_rev_nbr is NULL OR
         p_line_rec.configuration_id is NULL THEN

        IF l_debug_level > 0 THEN
          OE_DEBUG_PUB.Add('ERR: At least one Config keys not present', 1);
        END IF;
	x_return_status := FND_API.G_RET_STS_ERROR;
        x_config_mode := null;
        Print_Time ('Exiting OE_CONFIG_TSO_PVT.Get_MACD_Action_Mode');
        RETURN;
        --RAISE FND_API.G_EXC_ERROR;
      END IF;


      SELECT cz_hdr.baseline_rev_nbr
      INTO   l_baseline_rev_nbr
      FROM   cz_config_hdrs cz_hdr, cz_config_items czi
      WHERE  czi.config_hdr_id     = p_line_rec.config_header_id
      AND    czi.config_rev_nbr    = p_line_rec.config_rev_nbr
      AND    czi.config_item_id    = p_line_rec.configuration_id
      AND    cz_hdr.config_hdr_id  = czi.instance_hdr_id
      AND    cz_hdr.config_rev_nbr = czi.instance_rev_nbr
      AND    cz_hdr.baseline_rev_nbr is NOT NULL;

      IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Baseline 2:'||l_baseline_rev_nbr,2);
      END IF;

      x_config_mode := 3;

      BEGIN
        SELECT  czi.config_delta
        INTO   l_baseline_rev_nbr
	--bug3667985 fix
        --FROM   cz_config_hdrs cz_hdr, cz_config_items czi
	FROM cz_config_items czi
        WHERE  czi.config_hdr_id     = p_line_rec.config_header_id
        AND    czi.config_rev_nbr    = p_line_rec.config_rev_nbr
        AND    czi.config_item_id    = p_line_rec.configuration_id
        AND    nvl(czi.config_delta, 0) > 0;

        x_config_mode := 2;

        IF l_debug_level > 0 THEN
          OE_DEBUG_PUB.Add('333 config delta > 0', 1);
        END IF;
      EXCEPTION
       WHEN no_data_found THEN
          IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('no data 333 - no config delta so ib reonfig', 1);
          END IF;
          x_config_mode := 3;
      END;

      IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('p_line_rec x_config_mode ' || x_config_mode, 1);
      END IF;

      Print_Time ('Exiting OE_CONFIG_TSO_PVT.Get_MACD_Action_Mode');
      RETURN;

    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF l_debug_level > 0 THEN
         OE_DEBUG_PUB.Add('no data Baseline Rev', 2);
      END IF;
      l_baseline_rev_nbr := null;
  END;

  IF l_baseline_rev_nbr IS NULL THEN
    IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add('x_config_mode set to 1=new config using CZ',3);
    END IF;
    x_config_mode := 1;
  END IF;

  Print_Time('Exiting OE_CONFIG_TSO_PVT.Get_MACD_Action_Mode..');

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add('Other error in Get_MACD_Action_Mode:'||sqlerrm,1);
    END IF;

    IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      (  G_PKG_NAME
        ,'Get_MACD_Action_Mode' );
    END IF;

    x_config_mode   := null;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Get_MACD_Action_Mode;


-----------------------------------------------------------------------
-- Name:         Remove_Unchanged_Lines
--
-- Parameters:   IN p_top_model_line_id
--               IN p_line_id
--               IN ato_line_id
--               OUT x_msg_count
--               OUT x_msg_data
--               OUT x_return_status
--
-- Description:  This API is called from Remove_Unchanged_Components
--               and removes all (optional) unchanged lines in CZ
--               for a given top model line
--
-- Change Record:
----------------------------------------------------------------------
PROCEDURE Remove_Unchanged_Lines
( p_top_model_line_id     IN   NUMBER
 ,p_line_id               IN   NUMBER
 ,p_ato_line_id           IN   NUMBER
 ,x_msg_count             OUT NOCOPY  NUMBER
 ,x_msg_data              OUT NOCOPY  VARCHAR2
 ,x_return_status         OUT NOCOPY VARCHAR2
)
IS
  CURSOR C_UNCHANGED_LINES IS
  SELECT oe_ol.line_id
	,oe_ol.config_header_id
	,oe_ol.config_rev_nbr
	,oe_ol.configuration_id
  FROM   oe_order_lines oe_ol
	,cz_config_details_v cz_det
  WHERE  oe_ol.top_model_line_id = p_top_model_line_id
  AND    cz_det.config_delta = 0
  AND    cz_det.config_hdr_id = oe_ol.config_header_id
  AND    cz_det.config_rev_nbr = oe_ol.config_rev_nbr
  AND    cz_det.config_item_id = oe_ol.configuration_id
  AND    oe_ol.line_id <> oe_ol.top_model_line_id
  AND    oe_ol.open_flag = 'Y'
  ORDER BY option_number desc;

  l_line_id                          NUMBER;
  l_config_header_id                 NUMBER;
  l_config_rev_nbr                   NUMBER;
  l_configuration_id                 NUMBER;
  l_cursor_count                     NUMBER;

  l_ato_line_id                      NUMBER;
  l_top_model_line_id                NUMBER;
  l_change_flag                      VARCHAR2(1);
  l_part_of_container                VARCHAR2(1);
  l_top_container_model              VARCHAR2(1);
  l_top_config_header_id             NUMBER;
  l_top_config_rev_nbr               NUMBER;
  l_header_id                        NUMBER;

  l_debug_level            CONSTANT  NUMBER := oe_debug_pub.g_debug_level;
  l_description                      VARCHAR2(240);


BEGIN

  Print_Time('Entering OE_CONFIG_TSO_PVT.Remove_Unchanged_Lines...');

  OE_CONFIG_TSO_PVT.Is_Part_Of_Container_Model
  (  p_line_id              => p_line_id
    ,p_top_model_line_id    => p_top_model_line_id
    ,p_ato_line_id          => p_ato_line_id
    ,p_inventory_item_id    => NULL
    ,x_top_container_model  => l_top_container_model
    ,x_part_of_container    => l_part_of_container  );

  IF l_top_container_model='N' OR l_part_of_container='N' THEN

     IF l_debug_level > 0 THEN
	OE_DEBUG_PUB.Add('Item not eligible for removal of unchanged lines',3);
     END IF;

     x_return_status:=FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;

     SELECT description
     INTO l_description
     FROM oe_order_lines oe_oel, mtl_system_items mtl_msi
     WHERE oe_oel.line_id = p_line_id
     AND oe_oel.inventory_item_id = mtl_msi.inventory_item_id
     AND oe_oel.org_id = mtl_msi.organization_id;

     FND_MESSAGE.SET_NAME('ONT','ONT_TSO_NOT_CONTAINER');
     FND_MESSAGE.SET_TOKEN('ITEM_DESCRIPTION',l_description);
     OE_MSG_PUB.Add;

     Print_Time ('Exiting OE_CONFIG_TSO_PVT.Remove_Unchanged_Lines');
     RETURN;
  END IF;

  --{ bug3611490 starts
  l_cursor_count := 0;
  OPEN C_UNCHANGED_LINES;
  LOOP
  --FOR c_lines IN C_UNCHANGED_LINES LOOP
      FETCH C_UNCHANGED_LINES INTO l_line_id, l_config_header_id
                                  ,l_config_rev_nbr, l_configuration_id;
      EXIT WHEN C_UNCHANGED_LINES%NOTFOUND;

      l_cursor_count := l_cursor_count + 1;
      IF l_debug_level > 0 THEN
	 OE_DEBUG_PUB.Add('Line Id:'|| l_line_id,5);
	 OE_DEBUG_PUB.Add('Config Hdr:'||l_config_header_id,5);
	 OE_DEBUG_PUB.Add('Config Rev Nbr:'||l_config_rev_nbr,5);
	 OE_DEBUG_PUB.Add('Config ID:'||l_configuration_id,5);
      END IF;

      Print_Time('Calling CZ_PUB.Ext_deactivate_item at: ');

      CZ_NETWORK_API_PUB.Ext_Deactivate_Item
      (  p_api_version        => 1.0
	,p_config_hdr_id      => l_config_header_id
	,p_config_rev_nbr     => l_config_rev_nbr
	,p_config_item_id     => l_configuration_id
        ,x_return_status      => x_return_status
        ,x_msg_count          => x_msg_count
        ,x_msg_data           => x_msg_data     );

      Print_Time('Return from CZ_PUB.Ext_Deactivate_item at: ');

      IF l_debug_level > 0 THEN
	 OE_DEBUG_PUB.Add('After Calling CZ_NETWORK_API_PUB.'
			 ||'Ext_Deactivate_Item:'||x_return_status,3);
      END IF;

      IF x_return_status=FND_API.G_RET_STS_ERROR THEN
	 RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status=FND_API.G_RET_STS_UNEXP_ERROR THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

  END LOOP;
  CLOSE C_UNCHANGED_LINES;

  IF l_cursor_count > 0 THEN
     SELECT  config_header_id
            ,config_rev_nbr
            ,header_id
     INTO   l_top_config_header_id
           ,l_top_config_rev_nbr
	   ,l_header_id
     FROM    oe_order_lines oe_l
     WHERE   oe_l.line_id = p_top_model_line_id;

     IF l_debug_level > 0 THEN
	OE_DEBUG_PUB.Add('Unchanged Lines Count:'||l_cursor_count,3);
        OE_DEBUG_PUB.Add('Header Id:'||l_header_id,3);
        OE_DEBUG_PUB.Add('Config Hdr:'||l_top_config_header_id,3);
        OE_DEBUG_PUB.Add('Config Rev Number:'||l_top_config_rev_nbr,3);
     END IF;

     -- Delete/Cancel the Model lines which hold unchanged
     -- MACD components
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Before Calling Process_Config..header_id:'
		      ||l_header_id,3);
     END IF;

     OE_CONFIG_PVT.Process_Config
    (  p_header_id          => l_header_id
      ,p_config_hdr_id      => l_top_config_header_id
      ,p_config_rev_nbr     => l_top_config_rev_nbr
      ,p_top_model_line_id  => p_top_model_line_id
      ,p_ui_flag            => 'Y'
      ,x_change_flag        => l_change_flag
      ,x_msg_count          => x_msg_count
      ,x_msg_data           => x_msg_data
      ,x_return_status      => x_return_status     );

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('After Calling Process_Config..'
		      ||x_return_status,3);
     END IF;

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  ELSE
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add ('Csr Count 0. Skip OE_CONFIG_PVT.Process_Config',1);
     END IF;
  END IF;
  Print_Time('Exiting OE_CONFIG_TSO_PVT.Remove_Unchanged_Lines...');

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     IF l_debug_level > 0 THEN
	OE_DEBUG_PUB.Add('Expected Error in Remove_Unchanged_Lines:'
                          ||sqlerrm, 2);
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Unexpected Error in Remove_unchanged_Lines:'
			 ||sqlerrm, 1);
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Other error in Remove_Unchanged_Lines:'
                         ||sqlerrm,1);
     END IF;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
	   ,'Remove_Unchanged_Lines'
	);
     END IF;

END Remove_Unchanged_Lines;




-----------------------------------------------------------------
-- Name        :   Remove_Unchanged_Components
-- Parameters  :   IN p_line_id
--                 IN p_top_model_line_id
--                 IN p_ato_line_id
--                 OUT x_msg_data
--                 OUT x_msg_count
--                 OUT x_return_status
--
-- Description :   This procedure enables to remove all lines
--                 below the top model of the configuration
--                 that have NOT been changed in configurator
--                 and are optional in the configuration
--
--
-- Change Record :
------------------------------------------------------------------
PROCEDURE Remove_Unchanged_Components
( p_header_id          IN            NUMBER
, p_line_id            IN            NUMBER
, p_top_model_line_id  IN            NUMBER
, p_ato_line_id        IN            NUMBER
, x_msg_data           OUT NOCOPY    VARCHAR2
, x_msg_count          OUT NOCOPY    NUMBER
, x_return_status      OUT NOCOPY    VARCHAR2
)
IS

  CURSOR C_TOP_MODELS IS
  SELECT line_id
        ,ato_line_id
        ,top_model_line_id
  FROM  oe_order_lines
  WHERE header_id = p_header_id
  AND   top_model_line_id IS NOT NULL
  AND   line_id = top_model_line_id;

  l_debug_level            CONSTANT  NUMBER := oe_debug_pub.g_debug_level;

BEGIN

  Print_Time('Entering OE_CONFIG_TSO_PVT.Remove_Unchanged_Components...');
  x_return_status      :=  FND_API.G_RET_STS_SUCCESS;

  --{ bug3611488 starts
  IF p_top_model_line_id IS NOT NULL THEN

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('This call made from Lines Block',3);
	OE_DEBUG_PUB.Add('Calling Remove_Unchanged_Lines with...',3);
	OE_DEBUG_PUB.Add('HeaderID:'||p_header_id,3);
	OE_DEBUG_PUB.Add('LineID:'||p_line_id,3);
	OE_DEBUG_PUB.Add('TopModel:'||p_top_model_line_id,3);
     END IF;

     OE_CONFIG_TSO_PVT.Remove_Unchanged_Lines
     (  p_top_model_line_id  => p_top_model_line_id
       ,p_line_id            => p_line_id
       ,p_ato_line_id        => p_ato_line_id
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       ,x_return_status      => x_return_status   );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF l_debug_level > 0 THEN
	   OE_DEBUG_PUB.Add ('Error in Remove_Unchanged_Lines!',3);
	END IF;
     END IF;

  ELSE --bug3611488 ends }

     IF l_debug_level > 0 THEN
	OE_DEBUG_PUB.Add('This call made from Header block',3);
	OE_DEBUG_PUB.Add('Header ID:'||p_header_id,3);
     END IF;

     FOR c_top_model IN C_TOP_MODELS LOOP

	 IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('Calling Remove_Unchanged_lines with...',3);
	    OE_DEBUG_PUB.Add('Line id:'||c_top_model.line_id,3);
	    OE_DEBUG_PUB.Add('Top Model:'||c_top_model.top_model_line_id,3);
	 END IF;

         OE_CONFIG_TSO_PVT.Remove_Unchanged_Lines
	 (  p_top_model_line_id  => c_top_model.top_model_line_id
	   ,p_line_id            => c_top_model.line_id
	   ,p_ato_line_id        => c_top_model.ato_line_id
           ,x_msg_count          => x_msg_count
	   ,x_msg_data           => x_msg_data
	   ,x_return_status      => x_return_status );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug_level > 0 THEN
               OE_DEBUG_PUB.Add('ERROR during Remove_Unchanged_Lines!',3);
            END IF;
         END IF;

     END LOOP;

  END IF;

  Print_Time('Exiting OE_CONFIG_TSO_PVT.Remove_Unchanged_Components...');

END Remove_Unchanged_Components;




-----------------------------------------------------------------
-- Name        :   populate_tso_order_lines
-- Parameters  :   IN p_top_model_line_id
--                 IN p_instance_tbl
--                 IN p_mode
--                 OUT x_msg_data
--                 OUT x_msg_count
--                 OUT x_return_status
--
-- Description :   This API is used during MACD re-configuration
--                 flows. OM will create order lines for the
--                 selected instances and some more instances
--                 (if returned by CZ) and container model.
--
--
-- Change Record :
------------------------------------------------------------------

PROCEDURE populate_tso_order_lines
( p_header_id           IN           NUMBER
, p_top_model_line_id   IN           NUMBER
, p_instance_tbl        IN           csi_datastructures_pub.instance_cz_tbl
, p_mode                IN           NUMBER
, x_msg_data            OUT NOCOPY   VARCHAR2
, x_msg_count           OUT NOCOPY   NUMBER
, x_return_status       OUT NOCOPY   VARCHAR2
)
IS
  l_model_line_rec                   OE_ORDER_PUB.Line_Rec_Type;
  l_config_model_rec                 CZ_API_PUB.config_model_rec_type;
  l_appl_param_rec                   CZ_API_PUB.appl_param_rec_type;
  l_control_rec                      OE_GLOBALS.Control_Rec_Type;

  l_line_tbl                         OE_ORDER_PUB.Line_Tbl_Type;
  l_old_line_tbl                     OE_ORDER_PUB.Line_Tbl_Type;
  l_config_tbl                       CZ_API_PUB.config_tbl_type;
  l_config_model_tbl                 CZ_API_PUB.config_model_tbl_type;

  l_change_flag                      VARCHAR2(1);
  l_old_behavior                     VARCHAR2(1);
  l_frozen_model_bill                VARCHAR2(1);
  l_top_container_model              VARCHAR2(1);
  l_config_mode                      VARCHAR2(1);
  l_debug_level                      NUMBER; -- := oe_debug_pub.g_debug_level;
  l_header_id                        NUMBER;
  l_model_inv_item_id                NUMBER;
  l_config_header_id                 NUMBER;
  l_config_rev_nbr                   NUMBER;
  l_inventory_item_id                NUMBER;

  l_config_creation_date             DATE;
  l_config_model_lookup_date         DATE;
  l_config_date                      DATE;
  l_config_effective_date            DATE;
  l_instance_tbl                     csi_datastructures_pub.instance_cz_tbl;
BEGIN

  Print_Time ('Entering OE_CONFIG_TSO_PVT.populate_tso_order_lines...');
  l_debug_level := oe_debug_pub.g_debug_level;

  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('Top Model Line id:'||p_top_model_line_id,3);
     OE_DEBUG_PUB.Add('Instance Tbl Count:'||p_instance_tbl.count);
  END IF;


  IF l_debug_level > 0 THEN
     FOR I in p_instance_tbl.first..p_instance_tbl.last LOOP
       OE_DEBUG_PUB.Add
       ('inst hdr : '|| p_instance_tbl(I).config_instance_hdr_id,3);
       OE_DEBUG_PUB.Add
       ('inst rev : '|| p_instance_tbl(I).config_Instance_rev_number);
       OE_DEBUG_PUB.Add
       ('inst item: '|| p_instance_tbl(I).config_instance_item_id);
       OE_DEBUG_PUB.Add
       ('ship to  : '|| p_instance_tbl(I).ship_to_site_use_id);
       OE_DEBUG_PUB.Add
       ('bill to  : '|| p_instance_tbl(I).bill_to_site_use_id);
     END LOOP;
      oe_debug_pub.add('after the loop',2);
  END IF;

  --IF the ship_to_site_use_id and bill_to_site_use_id has NULL value
  --for all records returned by IB, we remember this and pass the
  --G_CONFIG_INTSTANCE_TBL to Process_Config to improve performance
  --l_instance_tbl := p_instance_tbl;
  l_instance_tbl := OE_CONFIG_PVT.G_CONFIG_INSTANCE_TBL;

  FOR I IN 1..p_instance_tbl.COUNT LOOP

      IF p_instance_tbl(I).ship_to_site_use_id IS NOT NULL AND
         p_instance_tbl(I).bill_to_site_use_id IS NOT NULL THEN

         l_instance_tbl := p_instance_tbl;
         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('MACD: Instance table has values',3);
            OE_DEBUG_PUB.Add('Breaking out of loop with table copy',3);
         END IF;
         EXIT; --copied table so break out of loop
      END IF;

  END LOOP;

  oe_debug_pub.add('after the second loop',2);

  IF p_top_model_line_id IS NOT NULL THEN
     BEGIN
       SELECT 'A'
       INTO   l_config_mode
       FROM   oe_order_lines
       WHERE  line_id = p_top_model_line_id
       AND    config_header_id IS NOT NULL;
     EXCEPTION
	WHEN NO_DATA_FOUND THEN
          IF p_top_model_line_id is NULL THEN
            l_config_mode := 'R';
          ELSE
            FND_Message.Set_Name('ONT', 'ONT_CONFIG_USE_CZ_NOT_IB');
            OE_Msg_Pub.add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
     END;
  ELSE
     l_config_mode := 'R';
  END IF;

  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('Config Mode is:'||l_config_mode,3);
  END IF;


  IF p_top_model_line_id IS NOT NULL THEN

     BEGIN
     SELECT creation_date
	   ,header_id
           ,inventory_item_id
     INTO   l_config_creation_date
	   ,l_header_id
           ,l_model_inv_item_id
     FROM   oe_order_lines
     WHERE  line_id = p_top_model_line_id;
     EXCEPTION
        WHEN OTHERS THEN
          oe_debug_pub.add('Other exception in select from oe-order_lines',3);
     END;

     IF l_debug_level > 0 THEN
        oe_debug_pub.add('RMV: After select from order_lines...',3);
        oe_debug_pub.add('RMV: Creat date is '||l_config_creation_date,3);
        OE_DEBUG_PUB.Add('Before calling Get_Config_Effective_Date.',3);
     END IF;

     OE_CONFIG_UTIL.Get_Config_Effective_Date
     (  p_model_line_id         => p_top_model_line_id
       ,x_old_behavior          => l_old_behavior
       ,x_config_effective_date => l_config_date
       ,x_frozen_model_bill     => l_frozen_model_bill    );

     IF l_debug_level > 0 THEN
	OE_DEBUG_PUB.Add('Finished Get_Config_Effective_Date.',3);
        oe_debug_pub.add('Old behav:'||l_old_behavior,3);
        oe_debug_pub.add('Config eff date:'||l_config_date,3);
        oe_debug_pub.add('Frozen:'||l_frozen_model_bill,3);
     END IF;

     IF l_old_behavior = 'N' THEN
        l_config_effective_date    := l_config_date;
        l_config_model_lookup_date := l_config_effective_date;
     ELSE
        l_config_effective_date    := NULL;
        l_config_model_lookup_date := NULL;
     END IF;
  ELSE

    l_config_creation_date := sysdate;

    l_config_effective_date    := null;
    l_config_model_lookup_date := null;
    l_header_id                := p_header_id;
  END IF; ------- top model null


     FOR I IN 1..p_instance_tbl.count LOOP


         l_config_tbl(I).config_hdr_id :=
                                p_instance_tbl(I).config_instance_hdr_id;
         l_config_tbl(I).config_rev_nbr:=
                                p_instance_tbl(I).config_instance_rev_number;

     END LOOP;


     l_appl_param_rec.config_creation_date := l_config_creation_date;
     l_appl_param_rec.config_model_lookup_date
	                                := l_config_model_lookup_date;
     l_appl_param_rec.config_effective_date := l_config_effective_date;
     l_appl_param_rec.calling_application_id
	                           := fnd_profile.value('RESP_APPL_ID');

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Config Create Date: '
			 || l_appl_param_rec.config_creation_date,1);
        OE_DEBUG_PUB.Add('Config Effective Date: '
			 || l_appl_param_rec.config_effective_date,1);
        OE_DEBUG_PUB.Add('Model Lookup Date: '
			 || l_appl_param_rec.config_model_lookup_date,1);
        OE_DEBUG_PUB.Add('appl id: '
			 || l_appl_param_rec.calling_application_id,1);
     END IF;

     --IF p_mode = 1 THEN
     IF l_config_mode = 'R' THEN

        Print_Time('Before Calling CZ_PUB.Generate_Config_trees');

        CZ_NETWORK_API_PUB.Generate_Config_Trees
        (  p_api_version         => 1.0
          ,p_config_tbl          => l_config_tbl
          ,p_tree_copy_mode      => CZ_API_PUB.G_NEW_HEADER_COPY_MODE
          --,p_tree_copy_mode      => CZ_API_PUB.G_NEW_REVISION_COPY_MODE
          ,p_appl_param_rec      => l_appl_param_rec
          ,p_validation_context  => CZ_API_PUB.G_INSTALLED
          ,x_config_model_tbl    => l_config_model_tbl
          ,x_return_status       => x_return_status
          ,x_msg_count           => x_msg_count
          ,x_msg_data            => x_msg_data
        );
        OE_MSG_PUB.Transfer_Msg_Stack;
        Print_Time('After CZ_PUB.Generate_Config_Trees:'||x_return_status);

	IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	   IF l_debug_level >0 THEN
	      OE_DEBUG_PUB.Add('Error in Generate_Config_Trees',2);
	   END IF;
	   RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   IF l_debug_level > 0 THEN
	      OE_DEBUG_PUB.Add('Unexpected Error in Gen_Config_trees',1);
	   END IF;
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        ---------now create model lines -----------------


        FOR I IN 1..l_config_model_tbl.count LOOP
        l_line_tbl(I) :=  OE_Order_PUB.G_MISS_LINE_REC;

            l_line_tbl(I).header_id := l_header_id;
	    l_line_tbl(I).inventory_item_id :=
	                        l_config_model_tbl(I).inventory_item_id;
	    l_line_tbl(I).org_id :=
	                        l_config_model_tbl(I).organization_id;
	    l_line_tbl(I).config_header_id :=
	                        l_config_model_tbl(I).config_hdr_id;
	    l_line_tbl(I).config_rev_nbr :=
	                        l_config_model_tbl(I).config_rev_nbr;
            l_line_tbl(I).configuration_id :=
	                        l_config_model_tbl(I).config_item_id;

            l_line_tbl(I).ordered_quantity := 1;

            IF l_model_inv_item_id = l_line_tbl(I).inventory_item_id THEN
              l_line_tbl(I).operation := 'UPDATE';
              l_line_tbl(I).line_id   :=  p_top_model_line_id;
            ELSE
              l_line_tbl(I).operation := 'CREATE';
            END IF;
        END LOOP;

        IF l_debug_level > 0 THEN
	   OE_DEBUG_PUB.Add('Before Calling OE_CONFIG_PVT.Call_Process_Order',3);
           oe_debug_pub.add('--------------------------------------');
           oe_debug_pub.add('Line_Tbl being pased to Call_Process_Order is...');

           FOR I in 1..l_line_tbl.count LOOP
           oe_debug_pub.add('Row #'||I);
	   oe_debug_pub.add('Hdr id:'||l_line_tbl(I).header_id);
           oe_debug_pub.add('Inv item id:'||l_line_tbl(I).inventory_item_id);
           oe_debug_pub.add('Org:'||l_line_tbl(I).org_id);
	   oe_debug_pub.add('ConfigHdr id:'||l_line_tbl(I).config_header_id);
           oe_debug_pub.add('Config Rev:'||l_line_tbl(I).config_rev_nbr);
           oe_debug_pub.add('ConfID:'||l_line_tbl(I).configuration_id);
	   oe_debug_pub.add('Ord qty:'||l_line_tbl(I).ordered_quantity);
           oe_debug_pub.add('LineID:'||l_line_tbl(I).line_id);
           oe_debug_pub.add('Oper:'||l_line_tbl(I).operation);
           END LOOP;

           oe_debug_pub.add('-------------------------------------');
        END IF;

	OE_CONFIG_PVT.Call_Process_Order
	(  p_line_tbl      => l_line_tbl
	  ,p_control_rec   => l_control_rec
	  ,p_ui_flag       => 'Y'
	  ,x_return_status => x_return_status   );

        IF l_debug_level > 0 THEN
	   OE_DEBUG_PUB.Add('After Calling Process Order:'
		            ||x_return_status,3);
        END IF;

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	   IF l_debug_level > 0 THEN
	      OE_DEBUG_PUB.Add('Error in Process Order.',2);
	   END IF;
	   RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   IF l_debug_level > 0 THEN
	      OE_DEBUG_PUB.Add('Unexpected Error in Process order.',1);
           END IF;
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

	------------------now create child lines-------------------
        FOR I IN 1..l_line_tbl.count LOOP

            IF l_debug_level > 0 THEN
	       OE_DEBUG_PUB.Add('Before calling OE_CONFIG_PVT.Process_Config..',3);
	       OE_DEBUG_PUB.Add('for cfg hdr ' || l_line_tbl(I).config_header_id,3);
	       OE_DEBUG_PUB.Add('for cfg rev '|| l_line_tbl(I).config_rev_nbr,3);
            END IF;

            SELECT line_id
            INTO   l_line_tbl(I).line_id
            FROM   oe_order_lines
            WHERE  header_id = l_line_tbl(I).header_id
            AND    config_header_id = l_line_tbl(I).config_header_id
            AND    config_rev_nbr = l_line_tbl(I).config_rev_nbr;

            MACD_SYSTEM_CALL := 'Y';

	    OE_CONFIG_PVT.Process_Config
	    (  p_header_id         => l_line_tbl(I).header_id
	      ,p_config_hdr_id     => l_line_tbl(I).config_header_id
	      ,p_config_rev_nbr    => l_line_tbl(I).config_rev_nbr
	      ,p_top_model_line_id => l_line_tbl(I).line_id
	      ,p_ui_flag           => 'N'
              ,p_config_instance_tbl => l_instance_tbl
	      ,x_change_flag       => l_change_flag
	      ,x_msg_count         => x_msg_count
	      ,x_msg_data          => x_msg_data
	      ,x_return_status     => x_return_status  );

            MACD_SYSTEM_CALL := 'N';

            IF l_debug_level > 0 THEN
	       OE_DEBUG_PUB.Add('After Calling Process Config..'
			         ||x_return_status,3);
            END IF;

	    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	       IF l_debug_level >0 THEN
	          OE_DEBUG_PUB.Add('Error in Process Config..',2);
	       END IF;
	       RAISE FND_API.G_EXC_ERROR;
	    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	       IF l_debug_level > 0 THEN
	          OE_DEBUG_PUB.Add('Unexpected Error in Process Config..',1);
	       END IF;
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;

        END LOOP;
        Print_Time ('Exiting OE_CONFIG_TSO_PVT.populate_tso_order_lines..');
	RETURN;

     END IF; --ending l_Config_mode = r

     IF l_config_mode = 'A' THEN

        IF l_debug_level > 0 THEN
           OE_DEBUG_PUB.Add('Start Add to container.config mode=A',3);
        END IF;

	BEGIN

	  SELECT config_header_id
	        ,config_rev_nbr
	        ,inventory_item_id
	  INTO   l_config_header_id
		,l_config_rev_nbr
		,l_inventory_item_id
	  FROM   oe_order_lines
	  WHERE  line_id = p_top_model_line_id;

	EXCEPTION
	   WHEN OTHERS THEN
	     IF l_debug_level > 0 THEN
		OE_DEBUG_PUB.Add('Error during select errmsg:'||sqlerrm,1);
	     END IF;
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	END;

	Print_Time('Before Calling CZ_PUB.Add_To_Config_Tree:');

	CZ_NETWORK_API_PUB.Add_To_Config_Tree
        (  p_api_version       => 1.0
	  ,p_inventory_item_id => l_inventory_item_id
	  ,p_organization_id   => OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID')
	  ,p_config_hdr_id     => l_config_header_id
	  ,p_config_rev_nbr    => l_config_rev_nbr
 	  ,p_instance_tbl      => l_config_tbl
	  --,p_tree_copy_mode    => CZ_API_PUB.G_NEW_REVISION_COPY_MODE
          ,p_tree_copy_mode    => CZ_API_PUB.G_NEW_HEADER_COPY_MODE
	  ,p_appl_param_rec    => l_appl_param_rec
	  ,p_validation_context => CZ_API_PUB.G_INSTALLED
	  ,x_config_model_rec  => l_config_model_rec
	  ,x_return_status     => x_return_status
	  ,x_msg_count         => x_msg_count
	  ,x_msg_data          => x_msg_data
	);

	Print_Time('After CZ_PUB.Add_To_Config_Tree:'||x_return_status);

	IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	   IF l_debug_level > 0 THEN
	      OE_DEBUG_PUB.Add ('Error in Add_to_config_tree',2);
	   END IF;
	   RAISE FND_API.G_EXC_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   IF l_debug_level > 0 THEN
	      OE_DEBUG_PUB.Add ('Unexpected Error in Add_to_config_tree',1);
	   END IF;
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	IF l_debug_level > 0 THEN
	   OE_DEBUG_PUB.Add('HeaderID:'||l_config_model_rec.config_hdr_id,3);
	   OE_DEBUG_PUB.Add('Rev Number:'||l_config_model_rec.config_rev_nbr,3);
	   OE_DEBUG_PUB.Add('Before Calling Process_Config',3);
	END IF;

        MACD_SYSTEM_CALL := 'Y';
	OE_CONFIG_PVT.Process_Config
	(  p_header_id         => l_header_id
          ,p_config_hdr_id     => l_config_model_rec.config_hdr_id
          ,p_config_rev_nbr    => l_config_model_rec.config_rev_nbr
          ,p_top_model_line_id => p_top_model_line_id
	  ,p_ui_flag           => 'Y'
          ,p_config_instance_tbl => l_instance_tbl
          ,x_change_flag       => l_change_flag
	  ,x_msg_count         => x_msg_count
	  ,x_msg_data          => x_msg_data
	  ,x_return_status     => x_return_status
        );
        MACD_SYSTEM_CALL := 'N';

	IF l_debug_level > 0 THEN
	   OE_DEBUG_PUB.Add('After Process_Config:'||x_return_status,3);
	END IF;

	IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	   IF l_debug_level > 0 THEN
	      OE_DEBUG_PUB.Add('Error in Process_Config',2);
	   END IF;
	   RAISE FND_API.G_EXC_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   IF l_debug_level > 0 THEN
	      OE_DEBUG_PUB.Add('Unexpected Error in Process_Config',1);
	   END IF;
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

     END IF;  --if l_config_mode = a

     OE_MSG_PUB.Count_And_Get
     (  p_count => x_msg_count
       ,p_data  => x_msg_data );

  Print_Time ('Exiting OE_CONFIG_TSO_PVT.populate_tso_order_lines...');

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     IF l_debug_level > 0 THEN
	OE_DEBUG_PUB.Add('Expected Error in populate_tso_order_lines:'
                          ||sqlerrm, 2);
     END IF;

     oe_debug_pub.add('RMV: 2 Msg count:'||x_msg_count);
     OE_MSG_PUB.Count_And_Get
     (  p_count => x_msg_count
       ,p_data  => x_msg_data );
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Unexpected Error in populate_tso_order_lines'
			 ||sqlerrm, 1);
     END IF;

     x_msg_count := OE_MSG_PUB.COUNT_MSG;
     IF l_debug_level > 0 THEN
        oe_debug_pub.add('RMV: 3 Msg count:'||x_msg_count);
     END IF;

     OE_MSG_PUB.Count_And_Get
     (  p_count => x_msg_count
       ,p_data  => x_msg_data );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF l_debug_level > 0 THEN
        oe_debug_pub.add('RMV: 4 Msg count: '|| sqlerrm );
     END IF;

     x_msg_count := OE_MSG_PUB.COUNT_MSG;
     FOR I in 1..x_msg_count LOOP
         x_msg_data := OE_MSG_PUB.Get(I,'F');
         IF l_debug_level > 0 THEN
            oe_debug_pub.add('Messages from Configurator...');
         END IF;
     END LOOP;

     OE_MSG_PUB.Count_And_Get
     (  p_count => x_msg_count
       ,p_data  => x_msg_data );

     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
	   ,'populate_tso_order_lines'
	);
     END IF;

END populate_tso_order_lines;


Procedure Process_MACD_Order
(p_api_version_number     IN  NUMBER,
 p_caller                 IN  VARCHAR2,
 p_x_header_id            IN  OUT NOCOPY NUMBER,
 p_sold_to_org_id         IN  NUMBER,
 p_MACD_Action            IN  VARCHAR2,
 p_x_line_tbl             IN  OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type,
 p_Instance_Tbl           IN  csi_datastructures_pub.instance_cz_tbl,
 p_Extended_Attrib_Tbl    IN  csi_datastructures_pub.ext_attrib_values_tbl,
 x_container_line_id      OUT NOCOPY NUMBER,
 x_number_of_containers   OUT NOCOPY NUMBER,
 x_return_status          OUT NOCOPY VARCHAR2,
 x_msg_count              OUT NOCOPY VARCHAR2,
 x_msg_data               OUT NOCOPY VARCHAR2)
IS

 l_debug_level    CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 l_perform_action BOOLEAN;
 l_header_id      NUMBER;
 l_instance_tbl   csi_datastructures_pub.instance_cz_tbl;

CURSOR Models is
   SELECT line_id
   FROM   oe_order_lines_all
   WHERE  header_id = p_x_header_id
   AND    open_flag = 'Y'
   AND    top_model_line_id = line_id
   AND    ATO_LINE_ID IS NULL;

BEGIN

  IF l_debug_level > 0 THEN
    oe_debug_pub.add('Entering oe_config_tso_pvt.Process_MACD_Order',1);
    oe_debug_pub.add('p_x_header_id            : ' || p_x_header_id,2);
    oe_debug_pub.add('p_sold_to_org_id         : ' || p_sold_to_org_id,2);
    oe_debug_pub.add('p_MACD_Action            : ' || p_MACD_Action,2);
    oe_debug_pub.add('p_x_line_tbl             : ' || p_x_line_tbl.count,2);
    oe_debug_pub.add('p_Instance_Tbl           : ' || p_Instance_Tbl.count,2);
    oe_debug_pub.add('p_Extended_Attrib_Tbl    : ' || p_Extended_Attrib_Tbl.count,2);
  END IF;
  	-- All validations will be performed here.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_caller = 'P' THEN

       --	p_header_id and p_sold_to_org_id should be mutually exclusive. (Not required for the group call)

       IF  (p_x_header_id is null
       AND p_sold_to_org_id is null)
       OR (p_x_header_id is not null
       AND  p_sold_to_org_id is not null)  THEN
           -- Set retun status and raise an error.
           -- Message should be seeded for this.

           FND_MESSAGE.Set_Name('ONT','ONT_TSO_HEAD_CUST_MISSING');
           x_return_status := FND_API.G_RET_STS_ERROR;
           oe_debug_pub.add('Unable to process since both header and customer is null',1);
       END IF;

      -- p_instance and p_x_line table should be exclusive. (not required for the group call)

       IF  (p_instance_tbl.count > 0
       AND p_x_line_tbl.count > 0)
       OR  (p_instance_tbl.count = 0
       AND p_x_line_tbl.count = 0) THEN

         --Set return status and raise an error
         --Message should be seeded for this.
         -- If no data is passed, raise an error and set the return  status.

           FND_MESSAGE.Set_Name('ONT','ONT_TSO_INS_ORD_MISSING');
           oe_debug_pub.add('Unable to process since both line and instance table are populated',1);
           x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;


       -- All selected instances should belong to same sold_to
       -- Item instance should be passed only once in the instance table (Not required this call CZ can handle this scenario)
       -- IB owner should be same on all the instances.
       -- Fail the call, when different action is passed in p_instance/line table than the p_macd_action.

	   If p_instance_tbl.count > 1 THEN

        For I in 2..p_instance_tbl.count LOOP

	      IF p_instance_tbl(1).sold_to_org_id <> p_instance_tbl(I).sold_to_org_id
	      OR p_instance_tbl(1).IB_OWNER <> p_instance_tbl(I).IB_OWNER
	      OR nvl(p_instance_tbl(I).action,p_macd_action) <> nvl(p_macd_action, p_instance_tbl(I).action)
	      THEN

             FND_MESSAGE.Set_Name('ONT','ONT_TSO_INVALID_DATA_API_CALL');
             x_return_status := FND_API.G_RET_STS_ERROR;
             oe_debug_pub.add('Invalid Datea 2',3);
	        --  Invalid data is passed, do not proceed further. Raise error.
	      ELSE

	        IF p_instance_tbl(I).action is not null then
	           l_perform_action := TRUE;
	        END IF; -- action
	      END IF;
	    END LOOP;


	    If p_instance_tbl(1).action is not null then
	       L_perform_action := TRUE;
	    END IF; -- action
	    IF nvl(p_instance_tbl(1).action,p_macd_action) <> nvl(p_macd_action, p_instance_tbl(1).action) THEN

            FND_MESSAGE.Set_Name('ONT','ONT_TSO_INVALID_DATA_API_CALL');
            x_return_status := FND_API.G_RET_STS_ERROR;
            oe_debug_pub.add('Invalid Datea 3',3);
	        Raise FND_API.G_EXC_ERROR;
	    END IF;

       End IF; -- count

	   -- The following code is for validating line record data.
	   IF p_x_line_tbl.count > 0 THEN

         For I in 1..p_x_line_tbl.count LOOP

	      IF nvl(p_x_line_tbl(I).operation,p_macd_action) <> nvl(p_macd_action, p_x_line_tbl(I).operation)
	      THEN
	        -- Invalid data is passed, do not proceed further. Raise error.
            FND_MESSAGE.Set_Name('ONT','ONT_TSO_INVALID_DATA_API_CALL');
            x_return_status := FND_API.G_RET_STS_ERROR;
            oe_debug_pub.add('Invalid Datea 4',3);
            Raise FND_API.G_EXC_ERROR;
	      ELSE

            IF p_x_line_tbl(I).operation is not null then
	           L_perform_action := TRUE;
	        END IF; -- action

	      END IF;
	     END LOOP;

	   End IF; -- Table count
    END IF; -- Public Validation.


    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       oe_debug_pub.add('Unable to process due to error',2);
       Raise FND_API.G_EXC_ERROR;
    END IF;
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('Main Logic Starts from here',2);
    END IF;
   -- If  p_sold_to_org_id is passed first create an order using the sold to and add the instances passed to the order.
   --   Procedure create_header will be introduced to create header record.*/

	IF p_sold_to_org_id is not null THEN

	   -- If the p_sold_to is passed we will call the below mentioned new API to create header record first and then call CZ API's
       -- to create container models and it's child lines.

        IF l_debug_level > 0 THEN
          oe_debug_pub.add('Before calling Create_header',2);
        END IF;
        Create_header(p_sold_to_org_id => p_sold_to_org_id
			          ,x_header_id     => p_x_header_id
	                  ,x_return_status => x_return_status
	                  ,x_msg_count 	   => x_msg_count
	                  ,x_msg_data 	   => x_msg_data);
        IF l_debug_level > 0 THEN
           oe_debug_pub.add('After  calling Create_header::' || p_x_header_id ||'::' || x_return_status,2);
        END IF;

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF l_debug_level > 0 THEN
              oe_debug_pub.add('Unexpected error in creating Order Header for sold to: ' || p_sold_to_org_id,2);
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
           IF l_debug_level > 0 THEN
              oe_debug_pub.add('Expected error in creating Order Header for sold to: ' || p_sold_to_org_id,2);
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        END IF;


      -- The procedure populate_tso_order_lines will take care of creating model lines and child lines with the given instance table.
      -- We can continue to call this API in this case as the order is getting created in this call.

	  -- The following API will call generate_config_tree procedure to generate the container models. OM creates the models first and then
      -- creates the child lines by looking at the cz_config_details_v.

	  -- populate_tso_order_lines procedure accepts the instance record declared in package oe_install_base_util. But we have mentioned in the FDD to declare a new instance
       -- record. We need evaluate the need for the new record. If the new record is mandatory then the data needs to be populated into local instance table which is based
       --  on the oe_install_base_util's record structure.

           IF l_debug_level > 0 THEN
              oe_debug_pub.add('Before calling populate_tso_order_lines ',2);
           END IF;

       IF p_Instance_Tbl.count > 0 THEN

	    oe_config_tso_pvt.populate_tso_order_lines(
	          p_header_id	       =>  p_x_header_id,
	          p_top_model_line_id  => null,
	          p_instance_tbl	   => p_instance_tbl,
	          p_mode		       => 1,
	          x_msg_count	       => x_msg_count,
	          x_msg_data	       => x_msg_data,
	          x_return_status	   => x_return_status);

           IF l_debug_level > 0 THEN
             oe_debug_pub.add('After calling populate_tso_order_lines ' || x_return_status,2);
           END IF;

          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;

	ELSIF p_x_header_id is not null THEN

/*	If the p_header_id is passed it means that the header already exists in the system and the newely passed data should be inserted into existing order.

	We cannot use the procedure populate_tso_order_lines as that procedure creates container model for the newly passed instances,
    but actually the container may already exists in that order. We need to have the logic to identify the existance of the container
    model for the passed in instance, if the container exists then the instances should be added to the same or else create the new
    container. For example, container "A" was fulfilled and that created instances I1 to I10. First time if the user creates the
    order with instance I1, system should create the container "A" and added the I1 to the same. Later if user picks I4 from IB,
    system should add the I4 to the existing container model instead of creating a new vcontainer recored in that order.

	We will create an API named create_TSO_order_lines procedure to add the lines into existing order.*/

           IF l_debug_level > 0 THEN
              oe_debug_pub.add('Before calling oe_config_tso_pvt.create_tso_order_lines ',2);
           END IF;

	      oe_config_tso_pvt.create_tso_order_lines(
	          p_header_id		    => p_x_header_id,
	          p_top_model_line_id	=> null,
	          p_instance_tbl		=> p_instance_tbl,
	          x_msg_count		    => x_msg_count,
	          x_msg_data		    => x_msg_data,
	          x_return_status		=> x_return_status);

           IF l_debug_level > 0 THEN
              oe_debug_pub.add('After calling oe_config_tso_pvt.create_tso_order_lines ' || x_return_status , 2);
           END IF;


	END IF; -- Sold to org.

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
    END IF;
    --	We are done with TSO line creation logic. Processing logic follows.
	IF p_macd_action is not null
	OR l_perform_action THEN

	  /* If the caller passes an action we need to validate the action. If the lines are created in this call,
      the logic would be based on the p_instance_tbl or else the logic would be based on the lines_tbl passed by the user.
      Or the process will be based on the lines table.*/

      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Before calling populate_tso_order_lines ',2);
      END IF;

       Populate_MACD_action
	   ( p_header_id            => p_x_header_id
	    ,p_instance_tbl         => p_instance_tbl
        ,p_x_line_tbl	        => p_x_line_tbl
        ,p_Extended_Attrib_Tbl	=> p_Extended_Attrib_Tbl
        ,p_macd_action          => p_macd_action
	    ,x_msg_data             => x_msg_data
	    ,x_msg_count            => x_msg_count
	    ,x_return_status        => x_return_status);

      IF l_debug_level > 0 THEN
      oe_debug_pub.add('After calling Populate_MACD_action ' || x_return_status,2);

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
	END IF;  -- action

 END IF;
    -- Populate out variables

     FOR I IN Models LOOP

      Oe_debug_pub.add('Model record ' || I.line_id,2);
      IF x_container_line_id IS NULL THEN
         x_container_line_id := I.line_id;
      END IF;

        x_number_of_containers := nvl(x_number_of_containers,0) + 1;

     END LOOP;

     IF p_x_line_tbl.count = 0 THEN

         oe_line_util.Query_Rows
         (p_header_id        => p_x_header_id
         ,x_line_tbl         => p_x_line_tbl);

     END IF;
    --  Get message count and data

    oe_msg_pub.count_and_get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data);

    IF l_debug_level > 0 THEN
     Oe_debug_pub.add(' Out Values from process macd',2);
     Oe_debug_pub.add('header_id             : ' || p_x_header_id,2);
     Oe_debug_pub.add('Line count            : ' || p_x_line_tbl.count,2);
     Oe_debug_pub.add('x_container_line_id   : ' || x_container_line_id,2);
     Oe_debug_pub.add('x_number_of_container : ' || x_number_of_containers,2);
     Oe_debug_pub.add('Return Status         : ' || x_return_status,2);
     Oe_debug_pub.add('Message count         : ' || x_msg_count,2);
     Oe_debug_pub.add('Message Data          : ' || x_msg_data,2);

     oe_debug_pub.add('Exiting oe_config_tso_pvt.Process_MACD_Order ' || x_return_status,1);
    END IF;
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
    oe_msg_pub.count_and_get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data);

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Expected Error in Process_MACD_Order:'
                         ||sqlerrm,3);
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    oe_msg_pub.count_and_get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data);

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Unexpected Error Process_MACD_Order:'
                         ||sqlerrm,3);
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
    oe_msg_pub.count_and_get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data);

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Other error in Process_MACD_Order:'
                          ||sqlerrm,1);
     END IF;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    OE_MSG_PUB.Add_Exc_Msg
        (  G_PKG_NAME
          ,'Process_MACD_Order' );
     END IF;

END Process_MACD_Order;

/*	The logic of the create_header is given below. This API will accept sold to as a in parameter and creates a header
    using the same by calling headers procedure.*/

Procedure  Create_header
(p_sold_to_org_id IN NUMBER
,x_header_id      OUT NOCOPY NUMBER
,x_return_status  OUT NOCOPY VARCHAR2
,x_msg_count      OUT NOCOPY NUMBER
,x_msg_data       OUT NOCOPY VARCHAR2)
IS
 -- Declare following local variables which are in parameters to the header procedure.
l_header_rec                    OE_Order_PUB.Header_Rec_Type;
l_old_header_rec             OE_Order_PUB.Header_Rec_Type;
l_control_rec                   OE_GLOBALS.Control_Rec_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_TSO_CONFIG_PVT.Create_Header' , 1 ) ;
   END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     --  Use the default control record to call header procedure.
      -- Populate the header record with the input data and an operation.

   l_old_header_rec   :=OE_ORDER_PUB.G_MISS_HEADER_REC;
   l_header_rec       :=OE_ORDER_PUB.G_MISS_HEADER_REC;
   l_header_rec.sold_to_org_id := p_sold_to_org_id;

    --  Set Operation to Create

    l_header_rec.operation := OE_GLOBALS.G_OPR_CREATE;

    --  Call Oe_Order_Pvt.Header
    --  Add debug messages.

    Oe_Order_Pvt.Header
    (    p_validation_level    =>FND_API.G_VALID_LEVEL_NONE
    ,    p_init_msg_list       => FND_API.G_TRUE
    ,    p_control_rec         =>l_control_rec
    ,    p_x_header_rec        =>l_header_rec
    ,    p_x_old_header_rec    =>l_old_header_rec
    ,    x_return_status       =>x_return_status    );

    -- Handle the return status.

    IF x_return_status  = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
    END IF;

    --  Load OUT parameters.

    X_header_id := l_header_rec.header_id;

    --  Get message count and data


    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Expected Error in Create_Header:'
                         ||sqlerrm,3);
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Unexpected Error Create_Header:'
                         ||sqlerrm,3);
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Other error in Create_Header:'
                          ||sqlerrm,1);
     END IF;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    OE_MSG_PUB.Add_Exc_Msg
        (  G_PKG_NAME
          ,'Create_Header' );
     END IF;

END Create_Header;



--The logic of this API would be very similar to the populate_tso_order_lines.
--The main difference here would be we will look for the existance of the container model
--for each instance and if container exists then we will add the instance to the exisiting container
--model rather creating new container model. We will check for the existance of the container model by
--using the component code passed in the instance table.

PROCEDURE Create_TSO_Order_Lines
( p_header_id           	IN           NUMBER
, p_top_model_line_id   	IN           NUMBER
, p_instance_tbl        	IN           csi_datastructures_pub.instance_cz_tbl
, x_msg_data            	OUT NOCOPY   VARCHAR2
, x_msg_count           	OUT NOCOPY   NUMBER
, x_return_status       	OUT NOCOPY   VARCHAR2
)
IS


l_model_inv_item_id                NUMBER;
l_config_header_id                 NUMBER;
l_config_rev_nbr                   NUMBER;
l_top_model_line_id                NUMBER;
J                                  NUMBER;
I                                  NUMBER;

l_instance_tbl                  csi_datastructures_pub.instance_cz_tbl;
l_parent_exists_instance_tbl    csi_datastructures_pub.instance_cz_tbl;
l_no_parent_instance_tbl       csi_datastructures_pub.instance_cz_tbl;
l_Temp_instance_tbl             csi_datastructures_pub.instance_cz_tbl;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
Begin

  --IF the ship_to_site_use_id and bill_to_site_use_id has NULL value
  --for all records returned by IB, we remember this and pass the
  --G_CONFIG_INTSTANCE_TBL to Process_Config to improve performance

   oe_debug_pub.add('Entering Procedure Create_TSO_Order_Lines: ' || l_instance_tbl.count,1);


   l_instance_tbl := p_instance_tbl;
   I := l_instance_tbl.FIRST;

   While I IS NOT NULL LOOP
   BEGIN

    --  Code should be added to identify the existance of the container model record.
    --	Loop through the table, identify the container model item from cz tables and check the existance of the record in
    -- OM table from the given header_id.

	 IS_container_present(
	 p_header_id 		          => p_header_id
	,p_config_instance_hdr_id     => l_instance_tbl(I).config_instance_hdr_id
	,p_config_instance_rev_number => l_instance_tbl(I).config_instance_rev_number
	,x_top_model_line_id 	      => l_top_model_line_id);

     oe_debug_pub.add('After calling IS_container_present: ' || l_top_model_line_id,2);

	-- If the model exists then transfer the instance record to l_parent_exists_instance_tbl and
    -- delete the instance record from l_instance_tbl. Also loop through the l_instance_tbl and transfer
    -- all the instance records that matchs the parent config_hdr and config_rev_nbr.
    -- Delete the records from l_instance_tbl after every transfer. Now we need to add these instances to the existing model.

	IF l_top_model_line_id is not null THEN

       oe_debug_pub.add('Top model is present',3);
	   J := l_instance_tbl.NEXT(I);

	   L_parent_exists_instance_tbl(l_parent_exists_instance_tbl.count + 1) :=	l_instance_tbl(I);

	   While J IS NOT NULL LOOP
       BEGIN

	     IF  l_instance_tbl(J).config_instance_hdr_id = l_instance_tbl(I).config_instance_hdr_id
	     AND l_instance_tbl(J).config_instance_rev_number = l_instance_tbl(I).config_instance_rev_number THEN

	         l_parent_exists_instance_tbl(l_parent_exists_instance_tbl.count + 1) :=
							l_instance_tbl(J);

		   	  l_instance_tbl.DELETE(J);


	     END IF;
         J := l_instance_tbl.NEXT(J);
       END;
	   END LOOP;
	   l_instance_tbl.DELETE(I);

       oe_debug_pub.add('Before calling populate_tso_order_lines to append lines: ' ||
                                               l_parent_exists_instance_tbl.count,3);
	   oe_config_tso_pvt.populate_tso_order_lines(
	          p_header_id		    => p_header_id,
	          p_top_model_line_id	=> l_top_model_line_id,
	          p_instance_tbl		=> l_parent_exists_instance_tbl,
              p_mode                => 1,
	          x_msg_count		    => x_msg_count,
	          x_msg_data		    => x_msg_data,
	          x_return_status		=> x_return_status);

	  -- Handle the return status from the call. Raise an exception accordingly.
       IF x_return_status=FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status=FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

	  -- Delete the parent table and also clear the top model so that we do not carry the value.

	  l_top_model_line_Id := null;
	  l_parent_exists_instance_tbl.delete;
	  Goto End_loop;

	ELSE
	--If the model does not exists then transfer the record to l_no_paranet_instance_tbl and delete the record.

	  --commented for BUG#7376452
	  --The table type being evaluated is l_no_parent_instance_tbl and the conter we use is of l_parent_exists_instance_tbl
	  --so whenever we evaluate for any standard line only the last line is evaluated evrytime as the conter always remains at 0

	  --l_no_parent_instance_tbl(l_parent_exists_instance_tbl.count + 1) := l_instance_tbl(I);
	  l_no_parent_instance_tbl(l_no_parent_instance_tbl.count + 1) := l_instance_tbl(I); --added BUG#7376452

	END IF; -- top model

	<<End_Loop>>

        I := L_instance_tbl.Next(I);
    END;
   END LOOP;

   IF l_no_parent_instance_tbl.count >0 THEN

     -- We will come here only if have instances without parent. Call populate_tso_order_lines to create containers and its chiled lines.
    oe_debug_pub.add('Before calling populate_tso_order_line to create lines: ' ||
                             l_no_parent_instance_tbl.count,2);
	oe_config_tso_pvt.populate_tso_order_lines(
	          p_header_id		=>p_header_id,
	          p_top_model_line_id	=> null,
	          p_instance_tbl		=> l_no_parent_instance_tbl,
              p_mode            => 1,
	          x_msg_count		=>x_msg_count,
	          x_msg_data		=> x_msg_data,
	          x_return_status		=> x_return_status);
	-- Handle the return status from the call. Raise an exception accordingly.
    IF x_return_status=FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status=FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

	l_no_parent_instance_tbl.delete;

   END IF; -- L_no_parent_instance.

   --  Get message count and data
    oe_debug_pub.add('Before exiting Create_TSO_Order_Lines' || x_return_status,2);
       OE_MSG_PUB.Count_And_Get
	    (   p_count                       => x_msg_count
	    ,   p_data                        => x_msg_data
	    );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Expected Error in Create_TSO_Order_Lines:'
                         ||sqlerrm,3);
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Unexpected Error Create_TSO_Order_Lines:'
                         ||sqlerrm,3);
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Other error in Create_TSO_Order_Lines:'
                          ||sqlerrm,1);
     END IF;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    OE_MSG_PUB.Add_Exc_Msg
        (  G_PKG_NAME
          ,'Create_TSO_Order_Lines' );
     END IF;
END Create_TSO_Order_Lines;



/*Procedure   Populate_MACD_action will prepare the config tables for batch validation.
 This API will be called when p_macd_action is passed so the action should be populated
 on the each line before calliing macd batch validate API. We will fetch the config details
 and populate the same in the config tables along with the action. We will validate the
 action and convert the actions to number to call CZ validate. Either instance table or
 line table will be passed to this table along with the extended table. We will also populate
 the data in cz extended table as well. */

PROCEDURE Populate_MACD_action(
  p_header_id           IN  NUMBER
 ,p_instance_tbl        IN  csi_datastructures_pub.instance_cz_tbl
 ,p_x_Line_Tbl	        IN  OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
 ,p_Extended_Attrib_Tbl	IN  csi_datastructures_pub.ext_attrib_values_tbl
 ,p_macd_action         IN VARCHAR2
-- ,x_config_item_tbl	OUT NOCOPY CZ_API_PUB.config_tbl_type;
-- ,x_config_ext_attr_tbl OUT NOCOPY config_ext_attr_tbl_type
 ,x_msg_data            OUT NOCOPY   VARCHAR2
 ,x_msg_count           OUT NOCOPY   NUMBER
 ,x_return_status       OUT NOCOPY   VARCHAR2)

IS

l_instance_tbl                  csi_datastructures_pub.instance_cz_tbl;
l_parent_exists_instance_tbl    csi_datastructures_pub.instance_cz_tbl;
l_no_parent_instance_tbl       csi_datastructures_pub.instance_cz_tbl;
l_config_item_rec 		        CZ_CF_API.config_item_rec_type;
l_config_item_tbl 		        CZ_CF_API.config_item_tbl_type;
l_config_attr_rec  		        CZ_CF_API.config_ext_attr_rec_type;
l_config_attr_tbl  		        CZ_CF_API.config_ext_attr_tbl_type;
l_url              		        VARCHAR2(100);
l_init_msg         		        VARCHAR2(2000);
l_validation_type  		        VARCHAR2(1) := CZ_API_PUB.VALIDATE_ORDER;
l_config_xml_msg   		        CZ_CF_API.CFG_OUTPUT_PIECES;
l_control_rec                   OE_GLOBALS.Control_Rec_Type;
J                               NUMBER;
I                               NUMBER;
l_component_code                VARCHAR2(30);
l_config_item_id                NUMBER;
l_debug_level                   CONSTANT NUMBER := oe_debug_pub.g_debug_level;
L_TOP_MODEL_LINE_ID             NUMBER;
l_top_config_header_id          NUMBER;
l_top_config_rev_nbr            NUMBER;
l_header_id                     NUMBER;
l_change_flag                   VARCHAR2(30);
L_line_tbl                      OE_Order_Pub.Line_Tbl_Type;
l_config_header_id              NUMBER;
l_config_rev_nbr                NUMBER;
l_valid_config                  VARCHAR2(10);
l_complete_config               VARCHAR2(10);
l_xml_str                       LONG := NULL;
Begin

   --IF the ship_to_site_use_id and bill_to_site_use_id has NULL value
   --for all records returned by IB, we remember this and pass the
   --G_CONFIG_INTSTANCE_TBL to Process_Config to improve performance

   oe_debug_pub.add('Entering Populate_macd_action procedure',1);
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF p_instance_tbl.count > 0 THEN

      l_instance_tbl := p_instance_tbl;
      I := l_instance_tbl.FIRST;

   While I IS NOT NULL LOOP
   BEGIN

	 -- Code should be added to identify the existance of the container model record.
	 -- Loop through the table, identify the container model item from cz tables
         -- and check the existance of the record in OM table from the given header_id.

	 IS_container_present(
	 P_header_id 			=> p_header_id
	,p_config_instance_hdr_id 	=> l_instance_tbl(I).config_instance_hdr_id
	,p_config_instance_rev_number 	=> l_instance_tbl(I).config_instance_rev_number
	,x_top_model_line_id 		=> l_top_model_line_id);

    oe_debug_pub.add('After is container: ' || l_top_model_line_id,2);
	-- After identifying the container model, loop through the instance table and
        -- populate the config table for validation.

	IF l_top_model_line_id is not null THEN

	   J := l_instance_tbl.NEXT(I);

	   L_parent_exists_instance_tbl (l_parent_exists_instance_tbl.count + 1) :=	l_instance_tbl(I);

	   -- Instance record will be validated for the given action and see whether the action is
           -- applicable and also system finds the current config_header_id (session header id) so that
           -- can be passed to CZ for the batch validation.

       oe_debug_pub.add('Before  Validate Action' || x_return_status,2);
	   Validate_action
               (p_top_model_line_id    => l_top_model_line_id,
	            p_instance_item_id     => l_instance_tbl(I).config_instance_item_id,
			    p_macd_action          => nvl(p_macd_action,l_instance_tbl(I).action),
			    x_config_item_id       => l_config_item_id,
		 	    x_component_code       => l_component_code,
                x_return_status        => x_return_status);

       oe_debug_pub.add('After Validate Action' || x_return_status,2);
       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
  	   l_config_item_rec.config_item_id := l_config_item_id;
	   l_config_item_rec.component_code := l_component_code;

	   IF nvl(p_macd_action, l_instance_tbl(I).action) = 'UPDATE' THEN
	       l_config_item_rec.operation := CZ_CF_API.bv_operation_update;
	   Elsif nvl(p_macd_action, l_instance_tbl(I).action) = 'DELETE' THEN
	       l_config_item_rec.operation := CZ_CF_API.bv_operation_delete;
	   Elsif nvl(p_macd_action, l_instance_tbl(I).action) = 'DISCONTINUE' THEN
	       l_config_item_rec.operation := CZ_CF_API.bv_operation_delete;
	   End if;


	  l_config_item_rec.instance_name := l_instance_tbl(I).instance_name;
	  l_config_item_tbl(l_config_item_tbl.count+1) := l_config_item_rec;
      oe_debug_pub.add('Before getting the data from P_Extended_Attrib_Tbl: ' ||
                  P_Extended_Attrib_Tbl.count,2);
	  For K in 1..P_Extended_Attrib_Tbl.count Loop
        oe_debug_pub.add('In the ext loop: ' || K,2);
    	    IF P_Extended_Attrib_Tbl(K).parent_tbl_index = I then

		l_config_attr_rec.config_item_id := l_config_item_id;
		l_config_attr_rec.component_code := l_component_code;
		l_config_attr_rec.sequence_nbr := P_Extended_Attrib_Tbl(k).attribute_sequence;
		l_config_attr_rec.attribute_name := P_Extended_Attrib_Tbl(k).attribute_code;
		l_config_attr_rec.attribute_value := P_Extended_Attrib_Tbl(k).attribute_value;
		l_config_attr_tbl(l_config_attr_tbl.count+1) :=  l_config_attr_rec;

 	    END IF; -- index xomparison.

      END LOOP;
      oe_debug_pub.add('Before J loop: ' || J,2);
	    While J IS NOT NULL
	    LOOP

      oe_debug_pub.add('Inside the J loop ' || J,2);
	     IF  l_instance_tbl(J).config_instance_hdr_id = l_instance_tbl(I).config_instance_hdr_id
	     AND l_instance_tbl(J).config_instance_rev_number = l_instance_tbl(I).config_instance_rev_number THEN

	   	l_parent_exists_instance_tbl(l_parent_exists_instance_tbl.count + 1) := l_instance_tbl(J);

        oe_debug_pub.add(' 1 Before Validate Action' || x_return_status,2);
	 	Validate_action
                (p_top_model_line_id  	=> l_top_model_line_id,
                 p_instance_item_id 	=> l_instance_tbl(J).config_instance_item_id,
				 p_macd_action          => nvl(p_macd_action, l_instance_tbl(J).action),
				 x_config_item_id       => l_config_item_id,
			 	 x_component_code    	=> l_component_code,
                 x_return_status        => x_return_status);

       oe_debug_pub.add(' 1 After Validate Action' || x_return_status,2);
       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
		l_config_item_rec.config_item_id := l_config_item_id;
  		l_config_item_rec.component_code := l_component_code;

  		IF nvl(p_macd_action, l_instance_tbl(j).action) = 'UPDATE' THEN
  		   l_config_item_rec.operation := CZ_CF_API.bv_operation_update;
  		ELSIF nvl(p_macd_action, l_instance_tbl(j).action) = 'DELETE' THEN
  		   l_config_item_rec.operation := CZ_CF_API.bv_operation_delete;
	        ELSIF nvl(p_macd_action, l_instance_tbl(j).action) = 'DISCONTINUE' THEN
		   l_config_item_rec.operation := CZ_CF_API.bv_operation_delete;
		End if;

  		l_config_item_rec.instance_name := l_instance_tbl(J).instance_name;
  		l_config_item_tbl(l_config_item_tbl.count+1) := l_config_item_rec;


		-- Populate corresponding extended attributes into cz extented table.
		For K in 1..P_Extended_Attrib_Tbl.count Loop

		  IF P_Extended_Attrib_Tbl(K).parent_tbl_index = J then

		     l_config_attr_rec.config_item_id := l_config_item_id;
	  	     l_config_attr_rec.component_code := l_component_code;
	             l_config_attr_rec.sequence_nbr := P_Extended_Attrib_Tbl(k).attribute_sequence;
                     l_config_attr_rec.attribute_name := P_Extended_Attrib_Tbl(k).attribute_code;
                     l_config_attr_rec.attribute_value := P_Extended_Attrib_Tbl(k).attribute_value;
                     l_config_attr_tbl(l_config_attr_tbl.count+1) :=  l_config_attr_rec;

		  END IF; -- index xomparison.

		END Loop; -- K loop


		l_instance_tbl.DELETE(J);
	    END IF; -- After Mai Loop
        J := l_instance_tbl.NEXT(J);
         oe_debug_pub.add('Processing next instance ' || J);
	  END LOOP; -- J Loop
	  l_instance_tbl.DELETE(I);

	  -- Call macd batch validate API to validate the actions for the given instances.

     oe_debug_pub.add('Before calling the oe_config_util.Create_hdr_xml: ' || l_top_model_line_id,3);

      oe_debug_pub.add('Before calling Create_hdr_xml',1);
      oe_config_util.Create_hdr_xml
      ( p_model_line_id        => l_top_model_line_id ,
        x_xml_hdr              => l_init_msg);


      oe_debug_pub.add('Before calling CZ_CF_API.VALIDATE',2);
	  CZ_CF_API.VALIDATE
    	  (p_api_version         => 1.0
          ,p_config_item_tbl     => l_config_item_tbl
          ,p_config_ext_attr_tbl => l_config_attr_tbl
          ,p_url                 => l_url
          ,p_init_msg            => l_init_msg
          ,p_validation_type     => l_validation_type
          ,x_config_xml_msg      => l_config_xml_msg
          ,x_return_status       => x_return_status
          ,x_msg_count           => x_msg_count
          ,x_msg_data            => x_msg_data);

      OE_MSG_PUB.Transfer_Msg_Stack;
      oe_debug_pub.add('After calling CZ_CF_API.VALIDATE: ' || x_return_status,2);
      oe_debug_pub.add('x_msg_data: ' || x_msg_data,2);

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
	  -- Handle the return status from the call. Raise an exception accordingly.

      -- extract data from xml message.

       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('CALLING PARSE_OUTPUT_XML: ' || l_config_xml_msg.COUNT, 2 );
       END IF;

      IF (l_config_xml_msg.COUNT > 0) THEN

       FOR xmlStr IN l_config_xml_msg.FIRST..l_config_xml_msg.LAST
       LOOP
        l_xml_str := l_xml_str||l_config_xml_msg(xmlStr);
        oe_debug_pub.add(' Row count ' || xmlStr,2);
       END LOOP;

        l_xml_str := UPPER(l_xml_str);

        oe_debug_pub.add(' Out Message '|| l_xml_str,2);
      oe_config_util.Parse_Output_xml
      ( p_xml               => l_xml_str,
        p_line_id           => l_top_model_line_id,
        x_valid_config      => l_valid_config,
        x_complete_config   => l_complete_config,
        x_config_header_id  => l_top_config_header_id,
        x_config_rev_nbr    => l_top_config_rev_nbr,
        x_return_status     => x_return_status );

      END IF;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('AFTER CALLING PARSE_XML: '||x_RETURN_STATUS , 2 );
        END IF;

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
	  -- Need to call the process_config api to synch up the order linesto onfiguration changes resulted due to the batch validation call.
/*
	  Begin

	   Select config_header_id, config_rev_nbr
	   Into l_top_config_header_id, l_top_config_rev_nbr
	   From oe_order_lines_all
	   Where line_id = l_top_model_line_id;

      EXCEPTION
         WHEN OTHERS THEN
          oe_debug_pub.add(' Line  SELECT: '|| SQLERRM , 1 ) ;
          RAISE FND_API.G_EXC_ERROR;
	   -- Exception handler

	  End;
*/
      oe_debug_pub.add('Before calling process config',2);
	  OE_CONFIG_PVT.Process_Config
	   (p_header_id          => l_header_id
	   ,p_config_hdr_id      => l_top_config_header_id
	   ,p_config_rev_nbr     => l_top_config_rev_nbr
	   ,p_top_model_line_id  => l_top_model_line_id
	   ,p_ui_flag            => 'Y'
	   ,x_change_flag        => l_change_flag
	   ,x_msg_count          => x_msg_count
	   ,x_msg_data           => x_msg_data
	   ,x_return_status      => x_return_status);

      oe_debug_pub.add('After calling Process Config: ' || x_return_status,2);
      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
	  -- Delete the parent table and also clear the top model so that we do not carry the value.

	  l_top_model_line_Id := null;
	  l_parent_exists_instance_tbl.delete;
	  Goto End_loop;

	END IF; -- top model


	<<End_Loop>>
	I := L_instance_tbl.Next(I);
     END;
      END LOOP;


   ELSE -- Process the data passed through the lines table.

      --Line table logic

      L_line_tbl := p_x_line_tbl;

      -- Add the logic to call process order so that all the updates are done before processing
      -- any action sent along with the lines table. We will loop through the lines table and adjust
      -- the operation so that process order can take the action on those. We will not pass the discontinue
      -- operation to process order as discontinue is not a valid operation for process order.

      For M in 1..l_line_tbl.count LOOP


       IF nvl(p_macd_action, l_line_tbl(M).operation) in ('DELETE', 'DISCONTINUE') THEN

        -- If the config details are passed on the line record copy the same to local variables.
        -- Or else query the config details for the lines table.

	    l_config_header_id := l_line_tbl(M).config_header_id;
	    l_config_rev_nbr := l_line_tbl(M).config_rev_nbr;
	    l_config_item_id := l_line_tbl(M).configuration_id;

	    IF l_config_header_id is null
	    OR l_config_rev_nbr is null
	    OR L_config_item_id is null THEN

  	      Begin

	       Select config_header_id, config_rev_nbr, configuration_id
	       Into l_config_header_id, l_config_rev_nbr, l_config_item_id
	       From oe_order_lines_all
	       Where line_id = l_line_tbl(M).line_id;

               L_line_tbl(M).config_header_id := l_config_header_id;
               L_line_tbl(M).config_rev_nbr  := l_config_rev_nbr;
               L_line_tbl(M).configuration_id  := l_config_item_id;


	      Exception
            WHEN OTHERS THEN

              Null;

	      End;

        END IF;
	    Validate_line_action
	    (p_line_id          => l_line_tbl(M).line_id,
	     p_config_header_id => l_config_header_id,
	     p_config_rev_nbr   => l_config_rev_nbr,
	     P_config_item_id   => l_config_item_id,
	     P_macd_action      => nvl(p_macd_action, l_line_tbl(M).operation),
  	     x_return_status    => x_return_status);

	     -- Handle the return status and change the operation accordingly.

	     IF x_return_status = 'ERRROR' then

                l_line_tbl(M).operation := 'NONE';

	     ELSIF L_line_tbl(M).operation = 'DISCONTINUE' Then

		         l_line_tbl(M).operation := 'NONE';

	     END IF;


       END IF; -- Delete;
      END LOOP;


     -- After the action validation we will call process order to update any changes passed in.

      OE_CONFIG_PVT.Call_Process_Order
	   (p_line_tbl      => l_line_tbl
       ,p_control_rec   => l_control_rec
       ,x_return_status => x_return_status);


      -- Handle the exception of the process order here. If there were no exception then process the macd action.

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

      I := l_line_tbl.FIRST;

      While I IS NOT NULL
      LOOP

        -- Code should be added to identify the existance of the container model record.
        -- Loop through the table, identify the container model item from cz tables
        -- and check the existance of the record in OM table from the given header_id.

      IS_container_present(
	   P_header_id 		      => p_header_id
	  ,p_config_instance_hdr_id     => l_line_tbl(I).config_header_id
	  ,p_config_instance_rev_number => l_line_tbl(I).config_rev_nbr
	  ,x_top_model_line_id 	      => l_top_model_line_id);

       -- After identifying the container model, loop through the instance table
       -- and populate the config table for validation.

       IF l_top_model_line_id is not null THEN

	     J := l_instance_tbl.NEXT(I);

	     l_parent_exists_instance_tbl (l_parent_exists_instance_tbl.count + 1) :=	l_instance_tbl(I);

          -- base line validation should be performed for the lines.

         Validate_line_action
	    (p_line_id          => l_line_tbl(I).line_id,
	     P_config_header_id => l_line_tbl(I).config_header_id,
	     P_config_rev_nbr   => l_line_tbl(I).config_rev_nbr,
	     P_config_item_id   => l_line_tbl(I).configuration_id,
	     P_macd_action      => nvl(p_macd_action, l_line_tbl(I).operation),
	     X_return_status    => x_return_status);

         oe_debug_pub.add('3  After calling Validate_line_action' || x_return_status,2);
        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
          -- Handle exceptions.

         l_config_item_rec.config_item_id := l_line_tbl(I).configuration_id;
         l_config_item_rec.component_code := l_line_tbl(I).component_code;

         IF nvl(p_macd_action,p_x_line_tbl(J).operation) = 'UPDATE' THEN
            l_config_item_rec.operation := CZ_CF_API.bv_operation_update;
         ELSIF nvl(p_macd_action,p_x_line_tbl(J).operation) = 'DELETE' THEN
            l_config_item_rec.operation := CZ_CF_API.bv_operation_delete;
         ELSIF nvl(p_macd_action,p_x_line_tbl(J).operation) = 'DISCONTINUE' THEN
            l_config_item_rec.operation := CZ_CF_API.bv_operation_delete;
         END IF;

         --l_config_item_rec.instance_name := l_line_tbl(I).instance_name;
         --l_config_item_rec.sequence_nbr := l_line_tbl(I).config_input_sequence;
         l_config_item_tbl(l_config_item_tbl.count+1) := l_config_item_rec;

  	     For K in 1..P_Extended_Attrib_Tbl.count Loop

  	       IF P_Extended_Attrib_Tbl(K).parent_tbl_index = I then

              l_config_attr_rec.config_item_id := l_config_item_id;
	          l_config_attr_rec.component_code := l_component_code;
	          l_config_attr_rec.sequence_nbr := P_Extended_Attrib_Tbl(k).attribute_sequence;
              l_config_attr_rec.attribute_name := P_Extended_Attrib_Tbl(k).attribute_code;
              l_config_attr_rec.attribute_value := P_Extended_Attrib_Tbl(k).attribute_value;
              l_config_attr_tbl(l_config_attr_tbl.count+1) :=  l_config_attr_rec;

 	       END IF; --index xomparison.

         END LOOP;
	     While J IS NOT NULL
	     LOOP

	      IF l_instance_tbl(J).config_instance_hdr_id = l_line_tbl(I).config_header_id
	      AND l_line_tbl(J).config_rev_nbr = l_instance_tbl(I).config_instance_rev_number THEN

	           l_parent_exists_instance_tbl(l_parent_exists_instance_tbl.count + 1) :=
						l_instance_tbl(J);

               Validate_line_action
      	            (p_line_id          => l_line_tbl(j).line_id,
	                 p_config_header_id => l_line_tbl(j).config_header_id,
	                 p_config_rev_nbr   => l_line_tbl(j).config_rev_nbr,
		             p_config_item_id   => l_line_tbl(j).configuration_id,
		             p_macd_action      => nvl(p_macd_action,l_line_tbl(j).operation),
	                 x_return_status	=> x_return_status);
                 oe_debug_pub.add('4  After calling Validate_line_action' || x_return_status,2);
                 IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

	           l_config_item_rec.config_item_id := l_line_tbl(j).configuration_id;
               l_config_item_rec.component_code := L_line_tbl(J).component_code;
               IF nvl(p_macd_action,p_x_line_tbl(J).operation) = 'UPDATE' THEN
                  l_config_item_rec.operation := CZ_CF_API.bv_operation_update;
               ELSIF nvl(p_macd_action,p_x_line_tbl(J).operation) = 'DELETE' THEN
                  l_config_item_rec.operation := CZ_CF_API.bv_operation_delete;
               ELSIF nvl(p_macd_action,p_x_line_tbl(J).operation) = 'DISCONTINUE' THEN
                  l_config_item_rec.operation := CZ_CF_API.bv_operation_delete;
               End if;
               l_config_item_rec.instance_name := l_instance_tbl(J).instance_name;
               l_config_item_tbl(l_config_item_tbl.count+1) := l_config_item_rec;


		        -- Populate corresponding extended attributes into cz extented table.
		       For K in 1..P_Extended_Attrib_Tbl.count Loop

		          IF P_Extended_Attrib_Tbl(K).parent_tbl_index = J then

 			         l_config_attr_rec.config_item_id := l_config_item_id;
	                 l_config_attr_rec.component_code := l_component_code;
	                 l_config_attr_rec.sequence_nbr := P_Extended_Attrib_Tbl(k).attribute_sequence;
                     l_config_attr_rec.attribute_name := P_Extended_Attrib_Tbl(k).attribute_code;
                     l_config_attr_rec.attribute_value := P_Extended_Attrib_Tbl(k).attribute_value;
                     l_config_attr_tbl(l_config_attr_tbl.count+1) :=  l_config_attr_rec;

		          END IF; -- index xomparison.

		       END Loop;

		       l_instance_tbl.DELETE(J);

	      END IF;
           J := l_instance_tbl.NEXT(J);
             oe_debug_pub.add('1 Processing next instance ' || J);
	     END LOOP;
	     l_instance_tbl.DELETE(I);

          oe_debug_pub.add('1 Before calling Create_hdr_xml',1);
          oe_config_util.Create_hdr_xml
          ( p_model_line_id        => l_top_model_line_id ,
            x_xml_hdr              => l_init_msg);
	     -- Call macd batch validate API to validate the actions for the given instances.

	     CZ_CF_API.VALIDATE
    	     (p_api_version          => 1.0
             ,p_config_item_tbl      => l_config_item_tbl
             ,p_config_ext_attr_tbl  => l_config_attr_tbl
             ,p_url                  => l_url
             ,p_init_msg             => l_init_msg
             ,p_validation_type      => l_validation_type
             ,x_config_xml_msg       => l_config_xml_msg
             ,x_return_status        => x_return_status
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data);

          oe_debug_pub.add('2 After calling CZ_CF_API.VALIDATE' || x_return_status,2);
           IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
	    -- Handle the return status from the call. Raise an exception accordingly.

           IF (l_config_xml_msg.COUNT > 0) THEN
               oe_debug_pub.add('2 Count is greater: ' || l_config_xml_msg.COUNT,2);
              FOR xmlStr IN l_config_xml_msg.FIRST..l_config_xml_msg.LAST
              LOOP
                l_xml_str := l_xml_str||l_config_xml_msg(xmlStr);
              END LOOP;

                l_xml_str :=  Upper(l_xml_str);
              oe_config_util.Parse_Output_xml
              ( p_xml               => l_xml_str,
                p_line_id           => l_top_model_line_id,
                x_valid_config      => l_valid_config,
                x_complete_config   => l_complete_config,
                x_config_header_id  => l_top_config_header_id,
                x_config_rev_nbr    => l_top_config_rev_nbr,
                x_return_status     => x_return_status );

          END IF;

          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
	    -- Need to call the process_config api to synch up the order lines to onfiguration changes
        -- resulted due to the batch validation call.
/*
  	    Begin

	     Select config_header_id, config_rev_nbr
	     Into l_top_config_header_id, l_top_config_rev_nbr
	     From oe_order_lines_all
	     Where line_id = l_top_model_line_id;

	    Exception
         When OTHERS THEN
            Null;

	    End;
*/
	   OE_CONFIG_PVT.Process_Config
	    (p_header_id          => l_header_id
	    ,p_config_hdr_id      => l_top_config_header_id
	    ,p_config_rev_nbr     => l_top_config_rev_nbr
	    ,p_top_model_line_id  => l_top_model_line_id
	    ,p_ui_flag            => 'Y'
	    ,x_change_flag        => l_change_flag
	    ,x_msg_count          => x_msg_count
	    ,x_msg_data           => x_msg_data
	    ,x_return_status      => x_return_status     );

       oe_debug_pub.add('After calling Process Config ' || x_return_status,2);

	   -- Delete the parent table and also clear the top model so that we do not carry the value.
       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

	   l_top_model_line_Id := null;
	   l_parent_exists_instance_tbl.delete;

      END IF;

	 END LOOP;

	END IF; -- Main if of p_instance_tbl count.


       --  Get message count and data

	    OE_MSG_PUB.Count_And_Get
	    (   p_count  => x_msg_count
	    ,   p_data   => x_msg_data
	    );
    Oe_debug_pub.add('Before exiting populate macd action : ' || x_return_status,1);
Exception
    WHEN FND_API.G_EXC_ERROR THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Expected Error in Populate_macd_action:'
                         ||sqlerrm,3);
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Unexpected Error Populate_macd_action:'
                         ||sqlerrm,3);
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Other error in Populate_macd_action:'
                          ||sqlerrm,1);
     END IF;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    OE_MSG_PUB.Add_Exc_Msg
        (  G_PKG_NAME
          ,'Populate_macd_action' );
     END IF;


END Populate_macd_action;

-- This procedure verifies the existance of the parent line for the given instance header.
-- If the header is present, system returns the top_model or else top_model would be null.
-- Frist the get the config_hdr and rev for the given instance details and then look for the
-- top model in the given header for the fetched item.

Procedure IS_CONTAINER_PRESENT
(P_header_id 	IN NUMBER
,p_config_instance_hdr_id IN NUMBER
,p_config_instance_rev_number IN NUMBER
,x_top_model_line_id 	OUT NOCOPY NUMBER)

IS

l_item_id Number;
l_config_hdr_id Number;
l_config_rev_nbr Number;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
    oe_debug_pub.add('Entering IS_CONTAINER_PRESENT: ' || p_config_instance_hdr_id,2);
    Begin

/*
    Select  cz.config_hdr_id, cz.config_rev_nbr, substr(cz.component_code, 1,instr(cz.component_code,'-')-1),
            oe.top_model_line_id
    Into    l_config_hdr_id, l_config_rev_nbr,  L_item_id,x_top_model_line_id
    from cz_config_details_v cz, oe_order_lines_all oe
    where cz.instance_hdr_id = p_config_instance_hdr_id
    and   oe.config_header_id = cz.config_hdr_id
    and   oe.config_rev_nbr = cz.config_rev_nbr
    and   oe.top_model_line_id = oe.line_id
    and   oe.header_id  = p_header_id
    and  component_instance_type = 'I'
    and  rownum = 1;
*/

	Select 	config_hdr_id, config_rev_nbr, substr(component_code, 1,instr(component_code,'-')-1)
	Into  	l_config_hdr_id, l_config_rev_nbr,	L_item_id
	from cz_config_details_v
        where instance_hdr_id = p_config_instance_hdr_id
        and instance_rev_nbr = p_config_instance_rev_number
        and component_instance_type = 'I';

    Exception
     WHEN OTHERS THEN
       oe_debug_pub.add('In when Others of cz_config  query',2);
	   Return;

    END;
    oe_debug_pub.add('Top model Present: ' || l_item_id,2);
    IF l_item_id is not null
    THEN

      Begin

     	Select top_model_line_id
	     Into    x_top_model_line_id
	     From oe_order_lines_all
	     Where header_id = p_header_id
--	     And config_header_id = l_config_hdr_id
--	     And config_rev_nbr = l_config_rev_nbr
         AND open_flag = 'Y'
         AND inventory_item_id = l_item_id
	     And top_model_line_id = line_id
         AND rownum = 1;

	  Exception
        WHEN OTHERS THEN
        oe_debug_pub.add('In when Others of oe_order_lines query',2);
        Null;
       --RETURN;
      End;
    END IF;
   oe_debug_pub.add('Exiting IS_Container_Present: ' || x_top_model_line_id,2);
Exception
    WHEN FND_API.G_EXC_ERROR THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Expected Error in IS_Container_Present::'
                         ||sqlerrm,3);
     END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Unexpected Error IS_Container_Present::'
                         ||sqlerrm,3);
     END IF;

   WHEN OTHERS THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Other error in IS_Container_Present::'
                          ||sqlerrm,1);
     END IF;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    OE_MSG_PUB.Add_Exc_Msg
        (  G_PKG_NAME
          ,'Validate Action' );
     END IF;

End IS_Container_Present;


-- This procedure will validate the action passed by the caller against the line.
-- We will fetch the line details corresponding to the instance information.
-- If the validation does not go through then the call will be failed.

Procedure Validate_action
(p_top_model_line_id  IN NUMBER
,P_instance_item_id   IN NUMBER
,P_macd_action        IN VARCHAR2
,x_config_item_id     OUT NOCOPY NUMBER
,x_component_code     OUT NOCOPY VARCHAR2
,x_return_status      OUT NOCOPY VARCHAR2)


IS
L_BASELINE_REV_NBR NUMBER(9);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

     -- In case of DELETE operation on order line with a baseline rev number > 0 , OM will error out.
     -- This is because CZ will not support REVERT action in this phase.

    oe_debug_pub.add('Entering validate action: ' || p_macd_action,2);

    x_return_status := FND_API.G_RET_STS_SUCCESS;


     IF  p_macd_action in ('DELETE', 'DISCONTINUE') then

      Begin

          SELECT cz_hdr.baseline_rev_nbr
          INTO   l_baseline_rev_nbr
          FROM   cz_config_hdrs cz_hdr, oe_order_lines oe_line,
                 cz_config_details_v czv
          WHERE  oe_line.top_model_line_id = p_top_model_line_id
          AND    oe_line.configuration_id = P_instance_item_id
          AND    czv.config_hdr_id     = oe_line.config_header_id
          AND    czv.config_rev_nbr    = oe_line.config_rev_nbr
          AND    czv.config_item_id    = oe_line.configuration_id
          AND    cz_hdr.config_hdr_id  = czv.instance_hdr_id
          AND    cz_hdr.config_rev_nbr = czv.instance_rev_nbr
          AND    cz_hdr.baseline_rev_nbr IS NOT NULL
          AND    rownum = 1;


       oe_debug_pub.add('Base line rev number: ' || l_baseline_rev_nbr,2);

	   IF l_baseline_rev_nbr > 0  AND
	      p_macd_action = 'DELETE'  THEN
            oe_debug_pub.add('Before raising error',2);
	        RAISE  FND_API.G_EXC_ERROR;
	    END IF;

     Exception
        WHEN NO_DATA_FOUND THEN
         IF p_macd_action = 'DISCONTINUE' THEN
            oe_debug_pub.add('Before raising error no data found',2);
            RAISE  FND_API.G_EXC_ERROR;
         END IF;
     End;

    End if;
       BEGIN

         SELECT configuration_id, component_code
          INTO   x_config_item_id, x_component_code
          FROM   oe_order_lines_all oe_line
          WHERE  oe_line.top_model_line_id = p_top_model_line_id
          AND    oe_line.configuration_id = p_instance_item_id
          AND    rownum = 1;

       EXCEPTION

         WHEN OTHERS THEN
          Null;
       END;
   oe_debug_pub.add('component_code ' || x_component_code,1);
   oe_debug_pub.add('Before exiting Validate action' || x_return_status,1);
Exception
    WHEN FND_API.G_EXC_ERROR THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Expected Error in validate_action:'
                         ||sqlerrm,3);
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Unexpected Error validate_action:'
                         ||sqlerrm,3);
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Other error in validate_action:'
                          ||sqlerrm,1);
     END IF;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    OE_MSG_PUB.Add_Exc_Msg
        (  G_PKG_NAME
          ,'Validate Action' );
     END IF;
END Validate_action;


-- This procedure will validate the action passed by the caller against the line.
-- We will fetch the line details corresponding to the instance information.
-- If the validation does not go through then the call will be failed.

Procedure Validate_line_action
(p_line_id IN NUMBER
,P_config_header_id IN NUMBER
,P_config_rev_nbr   IN NUMBER
,P_config_item_id   IN NUMBER
,P_macd_action       IN NUMBER
,x_return_status	   OUT NOCOPY VARCHAR2)

IS
 l_baseline_rev_nbr NUMBER(9);
 l_debug_level    CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  -- This is very similar to validateaction. In case of DELETE operation on order
  -- line with a baseline rev number > 0 , OM will error out.
  -- This is because CZ will not support REVERT action in this phase.

   oe_debug_pub.add('Enetering validate line action ' || p_macd_action,2);
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   If  p_macd_action in ('DELETE', 'DISCONTINUE')  then

	Begin
	      SELECT cz_hdr.baseline_rev_nbr
	      INTO   l_baseline_rev_nbr
	      FROM   cz_config_hdrs cz_hdr, oe_order_lines oe_line,
	             cz_config_details_v czv
	      WHERE oe_line.line_id = p_line_id
	      AND    czv.config_hdr_id     = oe_line.config_header_id
	      AND    czv.config_rev_nbr    = oe_line.config_rev_nbr
	      AND    czv.config_item_id    = oe_line.configuration_id
	      AND    cz_hdr.config_hdr_id  = czv.instance_hdr_id
	      AND    cz_hdr.config_rev_nbr = czv.instance_rev_nbr
	      AND    cz_hdr.baseline_rev_nbr IS NOT NULL
	      AND    rownum = 1;

     oe_debug_pub.add('Base line rev number : ' || l_baseline_rev_nbr,2);
     IF l_baseline_rev_nbr > 0  AND
         p_macd_action = 'DELETE'  THEN
          oe_debug_pub.add('Base line rev number greater than 0',2);
          RAISE  FND_API.G_EXC_ERROR;
    END IF;

      Exception
        WHEN NO_DATA_FOUND THEN
           Null;
	End;

  End if;
    oe_debug_pub.add('Exiting validate_line_action',2);
Exception
    WHEN FND_API.G_EXC_ERROR THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Expected Error in Validate_line_action:'
                         ||sqlerrm,3);
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Unexpected Error Validate_line_action:'
                         ||sqlerrm,3);
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Other error in validate_action:'
                          ||sqlerrm,1);
     END IF;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    OE_MSG_PUB.Add_Exc_Msg
        (  G_PKG_NAME
          ,'Validate_line_action' );
     END IF;
END Validate_line_action;


END OE_CONFIG_TSO_PVT;

/
