--------------------------------------------------------
--  DDL for Package Body INV_TXN_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TXN_VALIDATIONS" AS
/* $Header: INVMWAVB.pls 120.8.12010000.3 2011/09/29 03:17:23 pdong ship $ */


        g_pkg_name CONSTANT VARCHAR2(30) := 'INV_Txn_Validations';


PROCEDURE mdebug(msg in varchar2)
  IS
     l_msg VARCHAR2(5100);
     l_ts VARCHAR2(30);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   select to_char(sysdate,'MM/DD/YYYY HH:MM:SS') INTO l_ts from dual;
   l_msg:=l_ts||'  '||msg;


   IF (l_debug = 1) THEN
      inv_mobile_helper_functions.tracelog
     (p_err_msg => l_msg,
      p_module => 'inv_txn_validations',
      p_level => 4);
   END IF;
   null;
END;



   PROCEDURE VALIDATE_ITEM(x_Inventory_Item_Id            OUT NOCOPY NUMBER,
            x_Description                  OUT NOCOPY VARCHAR2,
            x_Revision_Qty_Control_Code    OUT NOCOPY NUMBER,
            x_Lot_Control_Code             OUT NOCOPY NUMBER,
            x_Serial_Number_Control_Code   OUT NOCOPY NUMBER,
            x_Restrict_Locators_Code       OUT NOCOPY NUMBER,
            x_Location_Control_Code         OUT NOCOPY NUMBER,
            x_Restrict_Subinventories_Code OUT NOCOPY NUMBER,
            x_Message                      OUT NOCOPY VARCHAR2,
            x_Status                       OUT NOCOPY VARCHAR2,
            p_Organization_Id              IN  NUMBER,
            p_Concatenated_Segments        IN  VARCHAR2)

   IS

   l_Item_Info   t_Item_Out;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN

   Select inventory_item_id,
               description,
          Revision_qty_control_code,
          lot_control_code,
               serial_number_control_code,
          restrict_locators_code,
          location_control_code,
          restrict_subinventories_code
   INTO l_Item_Info
   FROM MTL_SYSTEM_ITEMS_KFV
   WHERE concatenated_segments = p_Concatenated_Segments and
         organization_id = p_Organization_Id and
         mtl_transactions_enabled_flag = 'Y';

   x_Inventory_Item_Id         := l_Item_Info.Inventory_Item_Id;
   x_Description         := l_Item_Info.Description;
   x_Revision_Qty_Control_Code := l_Item_Info.Revision_Qty_Control_Code;
   x_Lot_Control_Code          := l_Item_Info.Lot_Control_Code;
   x_Serial_Number_Control_Code:= l_Item_Info.Serial_Number_Control_Code;
   x_Restrict_Locators_Code    := l_Item_Info.Restrict_Locators_Code;
   x_Location_Control_Code      := l_Item_Info.Location_Control_Code;
   x_Restrict_Subinventories_Code:=l_Item_Info.Restrict_Subinventories_Code;

   x_Message := 'Item: '|| p_Concatenated_Segments;
   x_Status := 'C';
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
      x_Message := 'Not a Valid Item';
      x_Inventory_Item_Id  := NULL;
      x_Description                   := NULL;
      x_Revision_Qty_Control_Code     := NULL;
      x_Lot_Control_Code              := NULL;
      x_Serial_Number_Control_Code    := NULL;
      x_Restrict_Locators_Code        := NULL;
      x_Location_Control_Code          := NULL;
      x_Restrict_Subinventories_Code  := NULL;
      x_Status                        := 'E';
   END;


   PROCEDURE VALIDATE_SERIAL(x_Current_Locator_Id           OUT NOCOPY NUMBER,
            x_Concatenated_Segments          OUT NOCOPY VARCHAR2, --Locator Name
            x_Current_Subinventory_Code      OUT NOCOPY VARCHAR2,
            x_Revision              OUT NOCOPY VARCHAR2,
            x_Lot_Number          OUT NOCOPY VARCHAR2,
            x_Expiration_Date                OUT NOCOPY DATE,
            x_Message                         OUT NOCOPY VARCHAR2,
            x_Status                          OUT NOCOPY VARCHAR2,
            p_Inventory_Item_Id               IN  NUMBER,
            p_Current_Organization_Id         IN  NUMBER,
            p_Serial_Number         IN  VARCHAR2)

   IS

   l_SN_Info t_SN_Out;
   l_curr_stat NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN

   Select current_locator_id,
               current_subinventory_code,
          revision,
          lot_number
          INTO l_SN_Info
   FROM MTL_SERIAL_NUMBERS
   WHERE inventory_item_id = p_Inventory_Item_Id and
         current_organization_id = p_Current_Organization_Id and
         serial_number = p_Serial_Number;

   x_Current_Locator_Id        := l_SN_Info.Current_Locator_Id;
   x_Current_Subinventory_Code := l_SN_Info.Current_Subinventory_Code;
   x_Revision                  := l_SN_Info.Revision;
   x_Lot_Number                := l_SN_Info.Lot_Number;
   x_Expiration_Date := NULL;
   x_Concatenated_Segments := NULL;

   IF x_Lot_Number IS NOT NULL THEN
   SELECT expiration_date INTO x_Expiration_Date
   FROM mtl_lot_numbers
   WHERE lot_number = x_Lot_Number AND
         inventory_item_id = p_Inventory_Item_Id AND
         organization_id = p_Current_Organization_Id;
   END IF;


   IF x_Current_Locator_Id IS NOT NULL  THEN
   SELECT concatenated_segments INTO x_Concatenated_Segments
   FROM mtl_item_locations_kfv
   WHERE inventory_location_id = x_Current_Locator_Id AND
         organization_id = p_Current_Organization_Id;

   END IF;

   SELECT current_status INTO l_curr_stat
   FROM mtl_serial_numbers
   WHERE inventory_item_id = p_Inventory_Item_Id AND
         current_organization_id = p_Current_Organization_Id AND
         serial_number = p_Serial_Number;

   IF l_curr_stat = 1 THEN
   x_Message := 'SN Not In Use';
   END IF;


   IF l_curr_stat = 4 THEN
   x_Message := 'Issued Out of Stores';
   END IF;

   IF l_curr_stat = 5 THEN
   x_Message := 'SN In Intransit';
   END IF;


   x_Status := 'C';

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
      x_Message := 'Not a Valid SN.  Item Id is '||p_Inventory_Item_Id||', organization_id is '||p_Current_Organization_Id||', SN is '||p_Serial_Number;

      x_Current_Locator_Id  := NULL;
      x_Current_Subinventory_Code     := NULL;
      x_Revision                      := NULL;
      x_Lot_Number                    := NULL;
      x_Expiration_Date               := NULL;
      x_Concatenated_Segments         := NULL; --Locator
      x_Status                        := 'E';
   END VALIDATE_SERIAL;

-- This does not use cost group id
-- Bug 5125915 Added variables demand_source_header and demand_source_line
PROCEDURE GET_AVAILABLE_QUANTITY(
             x_return_status OUT NOCOPY VARCHAR2,
             p_tree_mode IN NUMBER,
             p_organization_id IN NUMBER,
             p_inventory_item_id IN NUMBER,
             p_is_revision_control IN VARCHAR2,
             p_is_lot_control IN VARCHAR2,
             p_is_serial_control  IN VARCHAR2,
             p_demand_source_header_id IN NUMBER DEFAULT -9999,
             p_demand_source_line_id IN NUMBER DEFAULT -9999,
             p_revision IN VARCHAR2,
             p_lot_number IN VARCHAR2,
             p_lot_expiration_date IN  DATE,
             p_subinventory_code IN  VARCHAR2,
             p_locator_id IN NUMBER,
             p_source_type_id IN NUMBER,
             x_qoh   OUT NOCOPY NUMBER,
             x_att   OUT NOCOPY NUMBER
             )
     IS
     l_sqoh   NUMBER; -- inv converge
     l_satt   NUMBER; -- inv converge
     l_grade_code VARCHAR2(150); -- inv converge

BEGIN

      GET_AVAILABLE_QUANTITY(
              x_return_status        =>     x_return_status
             ,p_tree_mode            =>     p_tree_mode
             ,p_organization_id      =>     p_organization_id
             ,p_inventory_item_id    =>     p_inventory_item_id
             ,p_is_revision_control  =>     p_is_revision_control
             ,p_is_lot_control       =>     p_is_lot_control
             ,p_is_serial_control    =>     p_is_serial_control
             ,p_demand_source_header_id =>  p_demand_source_header_id
             ,p_demand_source_line_id=>     p_demand_source_line_id
             ,p_revision             =>     p_revision
             ,p_lot_number           =>     p_lot_number
             ,p_grade_code           =>     l_grade_code
             ,p_lot_expiration_date  =>     p_lot_expiration_date
             ,p_subinventory_code    =>     p_subinventory_code
             ,p_locator_id           =>     p_locator_id
             ,p_source_type_id       =>     p_source_type_id
             ,x_qoh                  =>     x_qoh
             ,x_att                  =>     x_att
             ,x_sqoh                 =>     l_sqoh
             ,x_satt                 =>     l_satt
             );

END GET_AVAILABLE_QUANTITY;



-- Bug# 3952081
-- New Overloaded Version of the previous procedure for OPM convergence
-- Additionally returns secondary qoh, secondary att
-- Additionally takes grade_code as an input param.
-- Bug 5125915 Added variables demand_source_header and demand_source_line

PROCEDURE GET_AVAILABLE_QUANTITY(
             x_return_status        OUT NOCOPY VARCHAR2,
             p_tree_mode            IN  NUMBER,
             p_organization_id      IN  NUMBER,
             p_inventory_item_id    IN  NUMBER,
             p_is_revision_control  IN  VARCHAR2,
             p_is_lot_control       IN  VARCHAR2,
             p_is_serial_control    IN  VARCHAR2,
             p_demand_source_header_id IN NUMBER DEFAULT -9999,
             p_demand_source_line_id IN NUMBER DEFAULT -9999,
             p_revision             IN  VARCHAR2,
             p_lot_number           IN  VARCHAR2,
             p_grade_code           IN  VARCHAR2,         -- inv converge
             p_lot_expiration_date  IN  DATE,
             p_subinventory_code    IN  VARCHAR2,
             p_locator_id           IN  NUMBER,
             p_source_type_id       IN  NUMBER,
             x_qoh                  OUT NOCOPY NUMBER,
             x_att                  OUT NOCOPY NUMBER,
             x_sqoh                 OUT NOCOPY NUMBER,   -- inv converge
             x_satt                 OUT NOCOPY NUMBER    -- inv converge
             )

     IS
     l_msg_count VARCHAR2(100);
     l_msg_data VARCHAR2(1000);
     l_rqoh NUMBER;
     l_qr NUMBER;
     l_qs NUMBER;
     l_atr NUMBER;
     l_is_revision_control BOOLEAN := FALSE;
     l_is_lot_control BOOLEAN := FALSE;
     l_is_serial_control BOOLEAN := FALSE;
     l_tree_mode NUMBER;
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     -- Bug# 3952081
     l_srqoh NUMBER;
     l_sqr NUMBER;
     l_sqs NUMBER;
     l_satr NUMBER;
     l_demand_source_header_id NUMBER ;
     l_demand_source_line_id NUMBER ;
BEGIN
   inv_quantity_tree_pub.clear_quantity_cache;
   IF p_is_revision_control = 'true' THEN
      l_is_revision_control := TRUE;
   END IF;

   IF p_is_lot_control = 'true' THEN
      l_is_lot_control := TRUE;
   END IF;

   IF p_is_serial_control = 'true' THEN
      l_is_serial_control := TRUE;
   END IF;

   IF p_demand_source_header_id IS NULL THEN
      l_demand_source_header_id := -9999 ;
   ELSE
      l_demand_source_header_id := p_demand_source_header_id ;
   END IF ;

   IF p_demand_source_line_id IS NULL THEN
      l_demand_source_line_id := -9999 ;
   ELSE
      l_demand_source_line_id := p_demand_source_line_id ;
   END IF ;

   IF p_tree_mode IS NULL THEN
      l_tree_mode := INV_Quantity_Tree_PUB.g_loose_only_mode;
    ELSE l_tree_mode := p_tree_mode;
   END IF ;

    inv_quantity_tree_pub.query_quantities
     (  p_api_version_number     =>   1.0
      , p_init_msg_lst         =>   fnd_api.g_false
      , x_return_status        =>   x_return_status
      , x_msg_count            =>   l_msg_count
      , x_msg_data             =>   l_msg_data
      , p_organization_id      =>   p_organization_id
      , p_inventory_item_id    =>   p_inventory_item_id
      , p_tree_mode            =>   l_tree_mode
      , p_is_revision_control  =>   l_is_revision_control
      , p_is_lot_control       =>   l_is_lot_control
      , p_is_serial_control    =>   l_is_serial_control
      , p_demand_source_type_id=>   p_source_type_id
      , p_demand_source_header_id =>l_demand_source_header_id
      , p_demand_source_line_id   =>l_demand_source_line_id
      , p_revision             =>   p_revision
      , p_lot_number           =>   p_lot_number
      , p_lot_expiration_date  =>   NULL --for bug# 2219136
      , p_grade_code           =>   p_grade_code
      , p_subinventory_code    =>   p_subinventory_code
      , p_locator_id           =>   p_locator_id
      , x_qoh                  =>   x_qoh
      , x_rqoh                 =>   l_rqoh
      , x_qr                   =>   l_qr
      , x_qs                   =>   l_qs
      , x_att                  =>   x_att
      , x_atr                  =>   l_atr
      , x_sqoh                 =>   x_sqoh
      , x_srqoh                =>   l_srqoh
      , x_sqr                  =>   l_sqr
      , x_sqs                  =>   l_sqs
      , x_satt                 =>   x_satt
      , x_satr                 =>   l_satr
  );
 IF (l_debug = 1) THEN
    mdebug('@'||l_msg_data||'@');
 END IF;

END get_available_quantity;



-- This uses cost group id
PROCEDURE GET_AVAILABLE_QUANTITY(
             x_return_status OUT NOCOPY VARCHAR2,
             p_tree_mode IN NUMBER,
             p_organization_id IN NUMBER,
             p_inventory_item_id IN NUMBER,
             p_is_revision_control IN VARCHAR2,
             p_is_lot_control IN VARCHAR2,
             p_is_serial_control  IN VARCHAR2,
             p_revision IN VARCHAR2,
             p_lot_number IN VARCHAR2,
             p_lot_expiration_date IN  DATE,
             p_subinventory_code IN  VARCHAR2,
             p_locator_id IN NUMBER,
             p_source_type_id IN NUMBER,
             p_cost_group_id IN NUMBER,
             x_qoh   OUT NOCOPY NUMBER,
             x_att   OUT NOCOPY NUMBER
             )
     IS
     l_sqoh   NUMBER; -- inv converge
     l_satt   NUMBER; -- inv converge
     l_grade_code VARCHAR2(150); -- inv converge

BEGIN

      GET_AVAILABLE_QUANTITY(
              x_return_status        =>     x_return_status
             ,p_tree_mode            =>     p_tree_mode
             ,p_organization_id      =>     p_organization_id
             ,p_inventory_item_id    =>     p_inventory_item_id
             ,p_is_revision_control  =>     p_is_revision_control
             ,p_is_lot_control       =>     p_is_lot_control
             ,p_is_serial_control    =>     p_is_serial_control
             ,p_revision             =>     p_revision
             ,p_lot_number           =>     p_lot_number
             ,p_grade_code           =>     l_grade_code
             ,p_lot_expiration_date  =>     p_lot_expiration_date
             ,p_subinventory_code    =>     p_subinventory_code
             ,p_locator_id           =>     p_locator_id
             ,p_source_type_id       =>     p_source_type_id
             ,p_cost_group_id        =>     p_cost_group_id
             ,x_qoh                  =>     x_qoh
             ,x_att                  =>     x_att
             ,x_sqoh                 =>     l_sqoh
             ,x_satt                 =>     l_satt
             );



END GET_AVAILABLE_QUANTITY;


-- Bug# 3952081
-- New Overloaded Version of the previous procedure for OPM convergence
-- Additionally returns secondary qoh, secondary att
-- Additionally takes grade_code as an input param.
PROCEDURE GET_AVAILABLE_QUANTITY(
             x_return_status        OUT NOCOPY VARCHAR2,
             p_tree_mode            IN  NUMBER,
             p_organization_id      IN  NUMBER,
             p_inventory_item_id    IN  NUMBER,
             p_is_revision_control  IN  VARCHAR2,
             p_is_lot_control       IN  VARCHAR2,
             p_is_serial_control    IN  VARCHAR2,
             p_revision             IN  VARCHAR2,
             p_lot_number           IN  VARCHAR2,
             p_grade_code           IN  VARCHAR2,         -- inv converge
             p_lot_expiration_date  IN  DATE,
             p_subinventory_code    IN  VARCHAR2,
             p_locator_id           IN  NUMBER,
             p_source_type_id       IN  NUMBER,
             p_cost_group_id        IN  NUMBER,
             x_qoh                  OUT NOCOPY NUMBER,
             x_att                  OUT NOCOPY NUMBER,
             x_sqoh                 OUT NOCOPY NUMBER,   -- inv converge
             x_satt                 OUT NOCOPY NUMBER    -- inv converge
             )
     IS
     l_msg_count VARCHAR2(100);
     l_msg_data VARCHAR2(1000);
     l_rqoh NUMBER;
     l_qr NUMBER;
     l_qs NUMBER;
     l_atr NUMBER;
     l_is_revision_control BOOLEAN := FALSE;
     l_is_lot_control BOOLEAN := FALSE;
     l_is_serial_control BOOLEAN := FALSE;
     l_tree_mode NUMBER;

     l_srqoh NUMBER;
     l_sqr NUMBER;
     l_sqs NUMBER;
     l_satr NUMBER;
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   inv_quantity_tree_pub.clear_quantity_cache;
   IF p_is_revision_control = 'true' THEN
      l_is_revision_control := TRUE;
   END IF;

   IF p_is_lot_control = 'true' THEN
      l_is_lot_control := TRUE;
   END IF;

   IF p_is_serial_control = 'true' THEN
      l_is_serial_control := TRUE;
   END IF;
   IF p_tree_mode IS NULL THEN
      l_tree_mode := INV_Quantity_Tree_PUB.g_loose_only_mode;
    ELSE l_tree_mode := p_tree_mode;
   END IF ;
 inv_quantity_tree_pub.query_quantities(
        p_api_version_number     =>   1.0
      , p_init_msg_lst         =>   fnd_api.g_false
      , x_return_status        =>   x_return_status
      , x_msg_count            =>   l_msg_count
      , x_msg_data             =>   l_msg_data
      , p_organization_id      =>   p_organization_id
      , p_inventory_item_id    =>   p_inventory_item_id
      , p_tree_mode            =>   l_tree_mode
      , p_is_revision_control  =>   l_is_revision_control
      , p_is_lot_control       =>   l_is_lot_control
      , p_is_serial_control    =>   l_is_serial_control
      , p_demand_source_type_id=>   p_source_type_id
      , p_revision             =>   p_revision
      , p_lot_number           =>   p_lot_number
      , p_lot_expiration_date  =>   NULL --for bug# 2219136
      , p_grade_code           =>   p_grade_code
      , p_subinventory_code    =>   p_subinventory_code
      , p_locator_id           =>   p_locator_id
      , p_cost_group_id        =>   p_cost_group_id
      , x_qoh                  =>   x_qoh
      , x_rqoh                 =>   l_rqoh
      , x_qr                   =>   l_qr
      , x_qs                   =>   l_qs
      , x_att                  =>   x_att
      , x_atr                  =>   l_atr
      , x_sqoh                 =>   x_sqoh
      , x_srqoh                =>   l_srqoh
      , x_sqr                  =>   l_sqr
      , x_sqs                  =>   l_sqs
      , x_satt                 =>   x_satt
      , x_satr                 =>   l_satr
  );
 IF (l_debug = 1) THEN
    mdebug('@'||l_msg_data||'@');
 END IF;

END get_available_quantity;



-- Bug# 2358224
-- Overloaded version of the previous procedure
-- passing in the to/transfer subinventory
-- This uses cost group id and transfer subinventory
PROCEDURE GET_AVAILABLE_QUANTITY(
             x_return_status OUT NOCOPY VARCHAR2,
             p_tree_mode IN NUMBER,
             p_organization_id IN NUMBER,
             p_inventory_item_id IN NUMBER,
             p_is_revision_control IN VARCHAR2,
             p_is_lot_control IN VARCHAR2,
             p_is_serial_control  IN VARCHAR2,
             p_revision IN VARCHAR2,
             p_lot_number IN VARCHAR2,
             p_lot_expiration_date IN  DATE,
             p_subinventory_code IN  VARCHAR2,
             p_locator_id IN NUMBER,
             p_source_type_id IN NUMBER,
             p_cost_group_id IN NUMBER,
             p_to_subinventory_code IN VARCHAR2,
             x_qoh   OUT NOCOPY NUMBER,
             x_att   OUT NOCOPY NUMBER
             )
     IS
     l_sqoh   NUMBER; -- inv converge
     l_satt   NUMBER; -- inv converge
     l_grade_code VARCHAR2(150); -- inv converge

BEGIN

GET_AVAILABLE_QUANTITY(
               x_return_status        =>       x_return_status
             , p_tree_mode            =>       p_tree_mode
             , p_organization_id      =>       p_organization_id
             , p_inventory_item_id    =>       p_inventory_item_id
             , p_is_revision_control  =>       p_is_revision_control
             , p_is_lot_control       =>       p_is_lot_control
             , p_is_serial_control    =>       p_is_serial_control
             , p_revision             =>       p_revision
             , p_lot_number           =>       p_lot_number
             , p_grade_code           =>       l_grade_code
             , p_lot_expiration_date  =>       p_lot_expiration_date
             , p_subinventory_code    =>       p_subinventory_code
             , p_locator_id           =>       p_locator_id
             , p_source_type_id       =>       p_source_type_id
             , p_cost_group_id        =>       p_cost_group_id
             , p_to_subinventory_code =>       p_to_subinventory_code
             , x_qoh                  =>       x_qoh
             , x_att                  =>       x_att
             , x_sqoh                 =>       l_sqoh
             , x_satt                 =>       l_satt
             );

END GET_AVAILABLE_QUANTITY;

-- Bug# 11812327
-- Overloaded the procedure GET_AVAILABLE_QUANTITY
-- return the Available Quantity on Hand,onhand qty,available transaction qty.
PROCEDURE GET_AVAILABLE_QUANTITY(
				 x_return_status OUT NOCOPY VARCHAR2,
				 p_tree_mode IN NUMBER,
				 p_organization_id IN NUMBER,
				 p_inventory_item_id IN NUMBER,
				 p_is_revision_control IN VARCHAR2,
				 p_is_lot_control IN VARCHAR2,
				 p_is_serial_control  IN VARCHAR2,
				 p_revision IN VARCHAR2,
				 p_lot_number IN VARCHAR2,
				 p_lot_expiration_date IN  DATE,
				 p_subinventory_code IN  VARCHAR2,
				 p_locator_id IN NUMBER,
				 p_source_type_id IN NUMBER,
				 p_cost_group_id IN NUMBER,
				 p_to_subinventory_code IN VARCHAR2,
				 x_qoh   OUT NOCOPY NUMBER,
				 x_att   OUT NOCOPY NUMBER,
                                 x_tqoh  OUT NOCOPY NUMBER
				 )
      IS
      l_qoh1     NUMBER;
      l_atpp1    NUMBER;
      l_pqoh     NUMBER;

BEGIN

--call the procedure
      GET_AVAILABLE_QUANTITY(
				 x_return_status       => x_return_status,
				 p_tree_mode           => p_tree_mode,
				 p_organization_id     => p_organization_id,
				 p_inventory_item_id   => p_inventory_item_id,
				 p_is_revision_control => p_is_revision_control,
				 p_is_lot_control      => p_is_lot_control,
				 p_is_serial_control   => p_is_serial_control,
				 p_revision            => p_revision,
				 p_lot_number          => p_lot_number,
				 p_lot_expiration_date => p_lot_expiration_date,
				 p_subinventory_code   => p_subinventory_code,
				 p_locator_id          => p_locator_id,
				 p_source_type_id      => p_source_type_id,
				 x_qoh                 => x_qoh,
				 x_att                 => x_att,
                                 x_pqoh                => l_pqoh,
                                 x_tqoh                => x_tqoh,
                                 x_atpp1               => l_atpp1,
                                 x_qoh1                => l_qoh1,
                                 p_cost_group_id       => p_cost_group_id,
                                 p_transfer_subinventory => p_to_subinventory_code
				 );

END GET_AVAILABLE_QUANTITY;

-- Bug# 3952081
-- New Overloaded Version of the previous procedure for OPM convergence
-- Additionally returns secondary qoh, secondary att
-- Additionally takes grade_code as an input param.
PROCEDURE GET_AVAILABLE_QUANTITY(
             x_return_status        OUT NOCOPY VARCHAR2,
             p_tree_mode            IN NUMBER,
             p_organization_id      IN NUMBER,
             p_inventory_item_id    IN NUMBER,
             p_is_revision_control  IN VARCHAR2,
             p_is_lot_control       IN VARCHAR2,
             p_is_serial_control    IN VARCHAR2,
             p_revision             IN VARCHAR2,
             p_lot_number           IN VARCHAR2,
             p_grade_code           IN VARCHAR2,         -- inv converge
             p_lot_expiration_date  IN DATE,
             p_subinventory_code    IN VARCHAR2,
             p_locator_id           IN NUMBER,
             p_source_type_id       IN NUMBER,
             p_cost_group_id        IN NUMBER,
             p_to_subinventory_code IN VARCHAR2,
             x_qoh                  OUT NOCOPY NUMBER,
             x_att                  OUT NOCOPY NUMBER,
             x_sqoh                 OUT NOCOPY NUMBER,   -- inv converge
             x_satt                 OUT NOCOPY NUMBER    -- inv converge
             )
     IS
     l_msg_count VARCHAR2(100);
     l_msg_data VARCHAR2(1000);
     l_rqoh NUMBER;
     l_qr NUMBER;
     l_qs NUMBER;
     l_atr NUMBER;
     l_is_revision_control BOOLEAN := FALSE;
     l_is_lot_control BOOLEAN := FALSE;
     l_is_serial_control BOOLEAN := FALSE;
     l_tree_mode NUMBER;

     l_srqoh NUMBER;
     l_sqr NUMBER;
     l_sqs NUMBER;
     l_satr NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   inv_quantity_tree_pub.clear_quantity_cache;
   IF p_is_revision_control = 'true' THEN
      l_is_revision_control := TRUE;
   END IF;

   IF p_is_lot_control = 'true' THEN
      l_is_lot_control := TRUE;
   END IF;

   IF p_is_serial_control = 'true' THEN
      l_is_serial_control := TRUE;
   END IF;

   IF p_tree_mode IS NULL THEN
      l_tree_mode := INV_Quantity_Tree_PUB.g_loose_only_mode;
    ELSE l_tree_mode := p_tree_mode;
   END IF ;

   inv_quantity_tree_pub.query_quantities(
   p_api_version_number          =>   1.0                    ,
   p_init_msg_lst                =>   fnd_api.g_false        ,
   x_return_status               =>   x_return_status        ,
   x_msg_count                   =>   l_msg_count            ,
   x_msg_data                    =>   l_msg_data             ,
   p_organization_id             =>   p_organization_id      ,
   p_inventory_item_id           =>   p_inventory_item_id    ,
   p_tree_mode                   =>   l_tree_mode            ,
   p_is_revision_control         =>   l_is_revision_control  ,
   p_is_lot_control              =>   l_is_lot_control       ,
   p_is_serial_control           =>   l_is_serial_control    ,
   p_demand_source_type_id       =>   p_source_type_id       ,
   p_revision                    =>   p_revision             ,
   p_lot_number                  =>   p_lot_number           ,
   p_lot_expiration_date         =>   NULL                   ,
   p_grade_code                  =>   p_grade_code           ,
   p_subinventory_code           =>   p_subinventory_code    ,
   p_locator_id                  =>   p_locator_id           ,
   p_cost_group_id               =>   p_cost_group_id        ,
   p_transfer_subinventory_code  =>   p_to_subinventory_code ,
   x_qoh                         =>   x_qoh                  ,
   x_rqoh                        =>   l_rqoh                 ,
   x_qr                          =>   l_qr                   ,
   x_qs                          =>   l_qs                   ,
   x_att                         =>   x_att                  ,
   x_atr                         =>   l_atr                  ,
   x_sqoh                        =>   x_sqoh                 ,
   x_srqoh                       =>   l_srqoh                ,
   x_sqr                         =>   l_sqr                  ,
   x_sqs                         =>   l_sqs                  ,
   x_satt                        =>   x_satt                 ,
   x_satr                        =>   l_satr
   );
   IF (l_debug = 1) THEN
      mdebug('@'||l_msg_data||'@');
   END IF;

END GET_AVAILABLE_QUANTITY;




/* This Overloaded Procedure Calls INV_QUANTITY_TREE_PVT to return pqoh
*/

 PROCEDURE GET_AVAILABLE_QUANTITY(
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 p_tree_mode IN NUMBER,
                                 p_organization_id IN NUMBER,
                                 p_inventory_item_id IN NUMBER,
                                 p_is_revision_control IN VARCHAR2,
                                 p_is_lot_control IN VARCHAR2,
                                 p_is_serial_control  IN VARCHAR2,
                                 p_revision IN VARCHAR2,
                                 p_lot_number IN VARCHAR2,
                                 p_lot_expiration_date IN  DATE,
                                 p_subinventory_code IN  VARCHAR2,
                                 p_locator_id IN NUMBER,
                                 p_source_type_id IN NUMBER,
                                 x_qoh    OUT NOCOPY NUMBER,
                                 x_att    OUT NOCOPY NUMBER,
                                 x_pqoh   OUT NOCOPY NUMBER,
                                 x_tqoh   OUT NOCOPY NUMBER,
                                 x_atpp1  OUT NOCOPY NUMBER,
                                 x_qoh1   OUT NOCOPY NUMBER
                 )
     IS
     l_sqoh NUMBER;
     l_satt NUMBER;
     l_spqoh NUMBER;
     l_stqoh NUMBER;
     l_satpp1 NUMBER;
     l_sqoh1 NUMBER;
     l_grade_code VARCHAR2(150); -- inv converge

BEGIN

   GET_AVAILABLE_QUANTITY(
              x_return_status        =>    x_return_status
            , p_tree_mode            =>    p_tree_mode
            , p_organization_id      =>    p_organization_id
            , p_inventory_item_id    =>    p_inventory_item_id
            , p_is_revision_control  =>    p_is_revision_control
            , p_is_lot_control       =>    p_is_lot_control
            , p_is_serial_control    =>    p_is_serial_control
            , p_revision             =>    p_revision
            , p_lot_number           =>    p_lot_number
            , p_grade_code           =>    l_grade_code
            , p_lot_expiration_date  =>    p_lot_expiration_date
            , p_subinventory_code    =>    p_subinventory_code
            , p_locator_id           =>    p_locator_id
            , p_source_type_id       =>    p_source_type_id
            , x_qoh                  =>    x_qoh
            , x_att                  =>    x_att
            , x_pqoh                 =>    x_pqoh
            , x_tqoh                 =>    x_tqoh
            , x_atpp1                =>    x_atpp1
            , x_qoh1                 =>    x_qoh1
            , x_sqoh                 =>    l_sqoh
            , x_satt                 =>    l_satt
            , x_spqoh                =>    l_spqoh
            , x_stqoh                =>    l_stqoh
            , x_satpp1               =>    l_satpp1
            , x_sqoh1                =>    l_sqoh1
            );

END GET_AVAILABLE_QUANTITY;



-- Bug# 3952081
-- New Overloaded Version of the previous procedure for OPM convergence
-- Additionally returns secondary qoh, secondary att
-- Additionally takes grade_code as an input param.
PROCEDURE GET_AVAILABLE_QUANTITY(
            x_return_status        OUT NOCOPY VARCHAR2,
            p_tree_mode            IN  NUMBER,
            p_organization_id      IN  NUMBER,
            p_inventory_item_id    IN  NUMBER,
            p_is_revision_control  IN  VARCHAR2,
            p_is_lot_control       IN  VARCHAR2,
            p_is_serial_control    IN  VARCHAR2,
            p_revision             IN  VARCHAR2,
            p_lot_number           IN  VARCHAR2,
            p_grade_code           IN  VARCHAR2,
            p_lot_expiration_date  IN  DATE,
            p_subinventory_code    IN  VARCHAR2,
            p_locator_id           IN  NUMBER,
            p_source_type_id       IN  NUMBER,
            x_qoh                  OUT NOCOPY NUMBER,
            x_att                  OUT NOCOPY NUMBER,
            x_pqoh                 OUT NOCOPY NUMBER,
            x_tqoh                 OUT NOCOPY NUMBER,
            x_atpp1                OUT NOCOPY NUMBER,
            x_qoh1                 OUT NOCOPY NUMBER,
            x_sqoh                  OUT NOCOPY NUMBER,
            x_satt                  OUT NOCOPY NUMBER,
            x_spqoh                 OUT NOCOPY NUMBER,
            x_stqoh                 OUT NOCOPY NUMBER,
            x_satpp1                OUT NOCOPY NUMBER,
            x_sqoh1                 OUT NOCOPY NUMBER
            )
   IS
     l_msg_count VARCHAR2(100);
     l_msg_data VARCHAR2(1000);
     l_is_revision_control BOOLEAN := FALSE;
     l_is_lot_control BOOLEAN := FALSE;
     l_is_serial_control BOOLEAN := FALSE;
     l_tree_mode NUMBER;
     l_api_version_number       CONSTANT NUMBER       := 1.0;
     l_api_name      CONSTANT VARCHAR2(30) := 'Get_Avaliable_Quantity';
     l_return_status            VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_tree_id                  INTEGER;
     l_rqoh     NUMBER;
     l_qr       NUMBER;
     l_qs       NUMBER;
     l_atr      NUMBER;
     l_pqoh     NUMBER;

     l_srqoh     NUMBER;
     l_sqr       NUMBER;
     l_sqs       NUMBER;
     l_satr      NUMBER;
     l_spqoh     NUMBER;

     x_msg_count VARCHAR2(100);
     x_msg_data  VARCHAR2(1000);
     p_api_version_number number;
     p_init_msg_lst VARCHAR2(30);
     l_asset_sub_only BOOLEAN := FALSE;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
        inv_quantity_tree_pvt.clear_quantity_cache;

  IF p_is_revision_control = 'true' THEN
      l_is_revision_control := TRUE;
   END IF;

   IF p_is_lot_control = 'true' THEN
      l_is_lot_control := TRUE;
   END IF;

   IF p_is_serial_control = 'true' THEN
      l_is_serial_control := TRUE;
   END IF;
   IF p_tree_mode IS NULL THEN
      l_tree_mode := INV_Quantity_Tree_PUB.g_loose_only_mode;
    ELSE l_tree_mode := p_tree_mode;
   END IF ;


   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

INV_QUANTITY_TREE_PVT.create_tree
  (   p_api_version_number       => 1.0
   ,  p_init_msg_lst             => fnd_api.g_false
   ,  x_return_status            => l_return_status
   ,  x_msg_count                => x_msg_count
   ,  x_msg_data                 => x_msg_data
   ,  p_organization_id          => p_organization_id
   ,  p_inventory_item_id        => p_inventory_item_id
   ,  p_tree_mode                => p_tree_mode
   ,  p_is_revision_control      => l_is_revision_control
   ,  p_is_lot_control           => l_is_lot_control
   ,  p_is_serial_control        => l_is_serial_control
   ,  p_asset_sub_only           => l_asset_sub_only
   ,  p_include_suggestion       => FALSE
   ,  p_demand_source_type_id    => -9999
   ,  p_demand_source_header_id  => -9999
   ,  p_demand_source_line_id    => -9999
   ,  p_demand_source_name       => NULL
   ,  p_demand_source_delivery   => NULL
   ,  p_lot_expiration_date      => NULL
   ,  p_grade_code               => NULL
   ,  x_tree_id                  => l_tree_id
   ,  p_onhand_source            => 3 --g_all_subs
   ,  p_exclusive                => 0 --g_non_exclusive
   ,  p_pick_release             => 0 --g_pick_release_no
) ;


   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

INV_QUANTITY_TREE_PVT.query_tree
  (   p_api_version_number   => 1.0
   ,  p_init_msg_lst         => fnd_api.g_false
   ,  x_return_status        => l_return_status
   ,  x_msg_count            => x_msg_count
   ,  x_msg_data             => x_msg_data
   ,  p_tree_id              => l_tree_id
   ,  p_revision             => p_revision
   ,  p_lot_number           => p_lot_number
   --,  p_grade_code           => p_grade_code
   ,  p_subinventory_code    => p_subinventory_code
   ,  p_locator_id           => p_locator_id
   ,  x_qoh                  => x_qoh
   ,  x_rqoh                 => l_rqoh
   ,  x_pqoh                 => x_pqoh
   ,  x_qr                   => l_qr
   ,  x_qs                   => l_qs
   ,  x_att                  => x_att
   ,  x_atr                  => l_atr
   ,  x_sqoh                 => x_sqoh
   ,  x_srqoh                => l_srqoh
   ,  x_spqoh                => x_spqoh
   ,  x_sqr                  => l_sqr
   ,  x_sqs                  => l_sqs
   ,  x_satt                 => x_satt
   ,  x_satr                 => l_satr
  );


   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

-- This query_tree quaries qoh and att at Item level,
-- so we are passing null for p_subinventory_code and p_locator_id

INV_QUANTITY_TREE_PVT.query_tree
  (   p_api_version_number   => 1.0
   ,  p_init_msg_lst         => fnd_api.g_false
   ,  x_return_status        => l_return_status
   ,  x_msg_count            => x_msg_count
   ,  x_msg_data             => x_msg_data
   ,  p_tree_id              => l_tree_id
   ,  p_revision             => p_revision
   ,  p_lot_number           => p_lot_number
   --,  p_grade_code           => p_grade_code
   ,  p_subinventory_code    => NULL
   ,  p_locator_id           => NULL
   ,  x_qoh                  => x_qoh1
   ,  x_rqoh                 => l_rqoh
   ,  x_pqoh                 => l_pqoh
   ,  x_qr                   => l_qr
   ,  x_qs                   => l_qs
   ,  x_att                  => x_atpp1
   ,  x_atr                  => l_atr
   ,  x_sqoh                 => x_sqoh1
   ,  x_srqoh                => l_srqoh
   ,  x_spqoh                => l_spqoh
   ,  x_sqr                  => l_sqr
   ,  x_sqs                  => l_sqs
   ,  x_satt                 => x_satpp1
   ,  x_satr                 => l_satr
  );


   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

INV_QUANTITY_TREE_PVT.get_total_qoh
   (  x_return_status        => l_return_status
   ,  x_msg_count            => x_msg_count
   ,  x_msg_data             => x_msg_data
   ,  p_tree_id              => l_tree_id
   ,  p_revision             => p_revision
   ,  p_lot_number           => p_lot_number
   --,  p_grade_code           => p_grade_code
   ,  p_subinventory_code    => p_subinventory_code
   ,  p_locator_id           => p_locator_id
   ,  p_cost_group_id        => NULL
   ,  x_tqoh                 => x_tqoh
   ,  x_stqoh                => x_stqoh
  );


   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := l_return_status;

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN

           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );


END get_available_quantity;



/* This Overloaded Procedure Calls INV_QUANTITY_TREE_PVT to return pqoh.
--This procedure takes in the cost group
*/

 PROCEDURE GET_AVAILABLE_QUANTITY
  (x_return_status OUT NOCOPY VARCHAR2,
   p_tree_mode IN NUMBER,
   p_organization_id IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_is_revision_control IN VARCHAR2,
   p_is_lot_control IN VARCHAR2,
   p_is_serial_control  IN VARCHAR2,
   p_revision IN VARCHAR2,
   p_lot_number IN VARCHAR2,
   p_lot_expiration_date IN  DATE,
   p_subinventory_code IN  VARCHAR2,
   p_locator_id IN NUMBER,
   p_source_type_id IN NUMBER,
   x_qoh    OUT NOCOPY NUMBER,
   x_att    OUT NOCOPY NUMBER,
   x_pqoh   OUT NOCOPY NUMBER,
   x_tqoh   OUT NOCOPY NUMBER,
   x_atpp1  OUT NOCOPY NUMBER,
   x_qoh1   OUT NOCOPY NUMBER,
   p_cost_group_id  IN NUMBER,
   p_transfer_subinventory IN VARCHAR2)

 IS
     l_sqoh NUMBER;
     l_satt NUMBER;
     l_spqoh NUMBER;
     l_stqoh NUMBER;
     l_satpp1 NUMBER;
     l_sqoh1 NUMBER;
     l_grade_code VARCHAR2(150); -- inv converge

BEGIN

   GET_AVAILABLE_QUANTITY(
              x_return_status        =>    x_return_status
            , p_tree_mode            =>    p_tree_mode
            , p_organization_id      =>    p_organization_id
            , p_inventory_item_id    =>    p_inventory_item_id
            , p_is_revision_control  =>    p_is_revision_control
            , p_is_lot_control       =>    p_is_lot_control
            , p_is_serial_control    =>    p_is_serial_control
            , p_revision             =>    p_revision
            , p_lot_number           =>    p_lot_number
            , p_grade_code           =>    l_grade_code
            , p_lot_expiration_date  =>    p_lot_expiration_date
            , p_subinventory_code    =>    p_subinventory_code
            , p_locator_id           =>    p_locator_id
            , p_source_type_id       =>    p_source_type_id
            , x_qoh                  =>    x_qoh
            , x_att                  =>    x_att
            , x_pqoh                 =>    x_pqoh
            , x_tqoh                 =>    x_tqoh
            , x_atpp1                =>    x_atpp1
            , x_qoh1                 =>    x_qoh1
            , x_sqoh                 =>    l_sqoh
            , x_satt                 =>    l_satt
            , x_spqoh                =>    l_spqoh
            , x_stqoh                =>    l_stqoh
            , x_satpp1               =>    l_satpp1
            , x_sqoh1                =>    l_sqoh1
            , p_cost_group_id        =>    p_cost_group_id
            , p_transfer_subinventory=>    p_transfer_subinventory
            );

END GET_AVAILABLE_QUANTITY;


-- Bug# 3952081
-- New Overloaded Version of the previous procedure for OPM convergence
-- Additionally returns secondary qoh, secondary att
-- Additionally takes grade_code as an input param.
PROCEDURE GET_AVAILABLE_QUANTITY(
            x_return_status         OUT NOCOPY VARCHAR2,
            p_tree_mode             IN  NUMBER,
            p_organization_id       IN  NUMBER,
            p_inventory_item_id     IN  NUMBER,
            p_is_revision_control   IN  VARCHAR2,
            p_is_lot_control        IN  VARCHAR2,
            p_is_serial_control     IN  VARCHAR2,
            p_revision              IN  VARCHAR2,
            p_lot_number            IN  VARCHAR2,
            p_grade_code            IN  VARCHAR2,
            p_lot_expiration_date   IN  DATE,
            p_subinventory_code     IN  VARCHAR2,
            p_locator_id            IN  NUMBER,
            p_source_type_id        IN  NUMBER,
            x_qoh                   OUT NOCOPY NUMBER,
            x_att                   OUT NOCOPY NUMBER,
            x_pqoh                  OUT NOCOPY NUMBER,
            x_tqoh                  OUT NOCOPY NUMBER,
            x_atpp1                 OUT NOCOPY NUMBER,
            x_qoh1                  OUT NOCOPY NUMBER,
            x_sqoh                   OUT NOCOPY NUMBER,
            x_satt                   OUT NOCOPY NUMBER,
            x_spqoh                  OUT NOCOPY NUMBER,
            x_stqoh                  OUT NOCOPY NUMBER,
            x_satpp1                 OUT NOCOPY NUMBER,
            x_sqoh1                  OUT NOCOPY NUMBER,
            p_cost_group_id         IN  NUMBER,
            p_transfer_subinventory IN  VARCHAR2
            )
   IS
     l_msg_count VARCHAR2(100);
     l_msg_data VARCHAR2(1000);
     l_is_revision_control BOOLEAN := FALSE;
     l_is_lot_control BOOLEAN := FALSE;
     l_is_serial_control BOOLEAN := FALSE;
     l_tree_mode NUMBER;
     l_api_version_number       CONSTANT NUMBER       := 1.0;
     l_api_name      CONSTANT VARCHAR2(30) := 'Get_Avaliable_Quantity';
     l_return_status            VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_tree_id                  INTEGER;
     l_rqoh     NUMBER;
     l_qr       NUMBER;
     l_qs       NUMBER;
     l_atr      NUMBER;
     l_pqoh     NUMBER;

     l_srqoh     NUMBER;
     l_sqr       NUMBER;
     l_sqs       NUMBER;
     l_satr      NUMBER;
     l_spqoh     NUMBER;

     x_msg_count VARCHAR2(100);
     x_msg_data  VARCHAR2(1000);
     p_api_version_number number;
     p_init_msg_lst VARCHAR2(30);
     l_asset_sub_only BOOLEAN := FALSE;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
        inv_quantity_tree_pvt.clear_quantity_cache;

  IF p_is_revision_control = 'true' THEN
      l_is_revision_control := TRUE;
   END IF;

   IF p_is_lot_control = 'true' THEN
      l_is_lot_control := TRUE;
   END IF;

   IF p_is_serial_control = 'true' THEN
      l_is_serial_control := TRUE;
   END IF;
   IF p_tree_mode IS NULL THEN
      l_tree_mode := INV_Quantity_Tree_PUB.g_loose_only_mode;
    ELSE l_tree_mode := p_tree_mode;
   END IF ;


   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

INV_QUANTITY_TREE_PVT.create_tree
  (   p_api_version_number       => 1.0
   ,  p_init_msg_lst             => fnd_api.g_false
   ,  x_return_status            => l_return_status
   ,  x_msg_count                => x_msg_count
   ,  x_msg_data                 => x_msg_data
   ,  p_organization_id          => p_organization_id
   ,  p_inventory_item_id        => p_inventory_item_id
   ,  p_tree_mode                => p_tree_mode
   ,  p_is_revision_control      => l_is_revision_control
   ,  p_is_lot_control           => l_is_lot_control
   ,  p_is_serial_control        => l_is_serial_control
   ,  p_asset_sub_only           => l_asset_sub_only
   ,  p_include_suggestion       => FALSE
   ,  p_demand_source_type_id    => -9999
   ,  p_demand_source_header_id  => -9999
   ,  p_demand_source_line_id    => -9999
   ,  p_demand_source_name       => NULL
   ,  p_demand_source_delivery   => NULL
   ,  p_lot_expiration_date      => NULL
   ,  p_grade_code               => NULL
   ,  x_tree_id                  => l_tree_id
   ,  p_onhand_source            => 3 --g_all_subs
   ,  p_exclusive                => 0 --g_non_exclusive
   ,  p_pick_release             => 0 --g_pick_release_no
) ;


   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

INV_QUANTITY_TREE_PVT.query_tree
  (   p_api_version_number   => 1.0
   ,  p_init_msg_lst         => fnd_api.g_false
   ,  x_return_status        => l_return_status
   ,  x_msg_count            => x_msg_count
   ,  x_msg_data             => x_msg_data
   ,  p_tree_id              => l_tree_id
   ,  p_revision             => p_revision
   ,  p_lot_number           => p_lot_number
   ,  p_subinventory_code    => p_subinventory_code
   ,  p_locator_id           => p_locator_id
   ,  x_qoh                  => x_qoh
   ,  x_rqoh                 => l_rqoh
   ,  x_pqoh                 => x_pqoh
   ,  x_qr                   => l_qr
   ,  x_qs                   => l_qs
   ,  x_att                  => x_att
   ,  x_atr                  => l_atr
   ,  x_sqoh                  => x_sqoh
   ,  x_srqoh                 => l_srqoh
   ,  x_spqoh                 => x_spqoh
   ,  x_sqr                   => l_sqr
   ,  x_sqs                   => l_sqs
   ,  x_satt                  => x_satt
   ,  x_satr                  => l_satr
   ,  p_cost_group_id        => p_cost_group_id
   ,  p_transfer_subinventory_code=> p_transfer_subinventory);


   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

-- This query_tree quaries qoh and att at Item level,
-- so we are passing null for p_subinventory_code and p_locator_id

INV_QUANTITY_TREE_PVT.query_tree
  (   p_api_version_number   => 1.0
   ,  p_init_msg_lst         => fnd_api.g_false
   ,  x_return_status        => l_return_status
   ,  x_msg_count            => x_msg_count
   ,  x_msg_data             => x_msg_data
   ,  p_tree_id              => l_tree_id
   ,  p_revision             => p_revision
   ,  p_lot_number           => p_lot_number
   --,  p_grade_code           => p_grade_code
   ,  p_subinventory_code    => NULL
   ,  p_locator_id           => NULL
   ,  x_qoh                  => x_qoh1
   ,  x_rqoh                 => l_rqoh
   ,  x_pqoh                 => l_pqoh
   ,  x_qr                   => l_qr
   ,  x_qs                   => l_qs
   ,  x_att                  => x_atpp1
   ,  x_atr                  => l_atr
   ,  x_sqoh                  => x_sqoh1
   ,  x_srqoh                 => l_srqoh
   ,  x_spqoh                 => l_spqoh
   ,  x_sqr                   => l_sqr
   ,  x_sqs                   => l_sqs
   ,  x_satt                  => x_satpp1
   ,  x_satr                  => l_satr
   ,  p_cost_group_id        => p_cost_group_id);


   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

INV_QUANTITY_TREE_PVT.get_total_qoh
   (  x_return_status        => l_return_status
   ,  x_msg_count            => x_msg_count
   ,  x_msg_data             => x_msg_data
   ,  p_tree_id              => l_tree_id
   ,  p_revision             => p_revision
   ,  p_lot_number           => p_lot_number
   --,  p_grade_code           => p_grade_code
   ,  p_subinventory_code    => p_subinventory_code
   ,  p_locator_id           => p_locator_id
   ,  p_cost_group_id        => p_cost_group_id
   ,  x_tqoh                 => x_tqoh
   ,  x_stqoh                => x_stqoh
  );


   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := l_return_status;

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN

           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );


 END get_available_quantity;



/* CHECK_LOOSE_QUANTITY returns a 'true' string (p_ok_to_process)
   if there is sufficient loose (unpacked) quantity at a location
   to complete the transaction, 'false' otherwise. */

PROCEDURE CHECK_LOOSE_QUANTITY(
            p_api_version_number    IN   NUMBER
                              , p_init_msg_lst          IN   VARCHAR2 DEFAULT fnd_api.g_false
               , x_return_status         OUT  NOCOPY VARCHAR2
               , x_msg_count             OUT  NOCOPY NUMBER
               , x_msg_data              OUT  NOCOPY VARCHAR2
               , p_organization_id       IN   NUMBER
                              , p_inventory_item_id     IN   NUMBER
                              , p_is_revision_control   IN   VARCHAR2
                              , p_is_lot_control        IN   VARCHAR2
                              , p_is_serial_control     IN   VARCHAR2
                              , p_revision              IN   VARCHAR2
                              , p_lot_number            IN   VARCHAR2
               , p_transaction_quantity  IN   NUMBER
               , p_transaction_uom       IN   VARCHAR2
                              , p_subinventory_code     IN   VARCHAR2
                              , p_locator_id            IN   NUMBER
               , p_transaction_temp_id   IN   NUMBER
               , p_ok_to_process         OUT  NOCOPY VARCHAR2
                              , p_transfer_subinventory IN   VARCHAR2
     )

  IS
     l_att         NUMBER;
     l_qoh         NUMBER;
     l_rqoh        NUMBER;
     l_qr          NUMBER;
     l_qs          NUMBER;
     l_atr         NUMBER;
     l_lot_exp_dt  DATE;
     l_moq         NUMBER;
     l_avail_qty   NUMBER;
     l_uom_rate    NUMBER;
     l_txn_qty     NUMBER;

     l_ok_to_process  VARCHAR2(5);

     l_is_revision_control  BOOLEAN := FALSE;
     l_is_lot_control       BOOLEAN := FALSE;
     l_is_serial_control    BOOLEAN := FALSE;
     l_cost_group_id      mtl_material_transactions_temp.cost_group_id%type;
     l_primary_uom_code   mtl_material_transactions_temp.item_primary_uom_code%type;
     l_inv_rcpt_code      mtl_parameters.negative_inv_receipt_code%type;

     l_api_version_number       CONSTANT NUMBER       := 1.0;
     l_api_name                 CONSTANT VARCHAR2(30) := 'Check_Looose_Quantity';
     l_return_status            VARCHAR2(1)           := fnd_api.g_ret_sts_success;

     l_transaction_source_type_id NUMBER;
     l_new_qoh NUMBER;
     l_new_att NUMBER;
     l_new_pqoh NUMBER;
     l_new_tqoh NUMBER;
     l_new_atpp1 NUMBER;
     l_new_qoh1 NUMBER;

     l_suggested_sub_code VARCHAR2(30);
     l_suggested_loc_id   NUMBER;
     l_cgcnt              NUMBER;

     CURSOR c_org IS
     SELECT negative_inv_receipt_code
       FROM mtl_parameters
      WHERE organization_id = p_organization_id;

     CURSOR c_lot_exp IS
     SELECT expiration_date
       FROM mtl_lot_numbers
      WHERE inventory_item_id = p_inventory_item_id
   AND organization_id   = p_organization_id
   AND lot_number        = p_lot_number;

     CURSOR c_mmtt IS
     SELECT cost_group_id,transaction_source_type_id, subinventory_code, locator_id
       FROM mtl_material_transactions_temp
      WHERE transaction_temp_id = p_transaction_temp_id;

     CURSOR c_item IS
     SELECT primary_uom_code
       FROM mtl_system_items
      WHERE inventory_item_id = p_inventory_item_id
   AND organization_id   = p_organization_id;

     CURSOR c_moq(x_cost_group_id number)  IS
     select count(*)
       from mtl_onhand_quantities_detail
      -- Bug 2687570, use MOQD instead of MOQ because consigned stock is not visible in MOQ
      where organization_id = p_organization_id
        and inventory_item_id = p_inventory_item_id
        and subinventory_code = p_subinventory_code
        and locator_id = p_locator_id
        and nvl(lot_number, '###') = nvl(p_lot_number, nvl(lot_number,'###'))
        and containerized_flag =2
        and cost_group_id <> x_cost_group_id;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
      mdebug ('Start check_loose_quantity.');
   END IF;

   inv_quantity_tree_pub.clear_quantity_cache;

   -- Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   IF (l_debug = 1) THEN
      mdebug ('Done checking if compatible api call.');
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   p_ok_to_process := 'false';

   --
   -- Initialize variables
   --
   IF p_is_revision_control = 'true' THEN
      l_is_revision_control := TRUE;
   END IF;

   IF p_is_serial_control = 'true' THEN
      l_is_serial_control := TRUE;
   END IF;
   IF (l_debug = 1) THEN
      mdebug ('Done initializing variables.');
   END IF;

   --
   -- Find the lot expiration date if
   -- the item is lot controlled.
   --
   IF p_is_lot_control = 'true' THEN
      l_is_lot_control := TRUE;
      OPEN c_lot_exp;
      FETCH c_lot_exp INTO l_lot_exp_dt;
      CLOSE c_lot_exp;
   END IF;

   -- Find the cost group id being transacted
   OPEN c_mmtt;
   FETCH c_mmtt
     INTO
     l_cost_group_id, l_transaction_source_type_id,
     l_suggested_sub_code, l_suggested_loc_id;
   CLOSE c_mmtt;
   IF (l_debug = 1) THEN
      mdebug ('Cost group id from mmtt: '||l_cost_group_id);
   END IF;

   -- Find the primary UOM code for the item
   OPEN c_item;
   FETCH c_item INTO l_primary_uom_code;
   CLOSE c_item;
   IF (l_debug = 1) THEN
      mdebug ('Primary UOM for this item: '||l_primary_uom_code);
   END IF;

   -- Find if -ve inventory balances are allowed for this org
   OPEN c_org;
   FETCH c_org INTO l_inv_rcpt_code;
   CLOSE c_org;
   IF (l_debug = 1) THEN
      mdebug ('-ve inv rcpt code is: '||l_inv_rcpt_code);
   END IF;

   -- Translate picked qty/uom into primary uom qty
   inv_convert.inv_um_conversion(
              from_unit  => p_transaction_uom
            , to_unit    => l_primary_uom_code
            , item_id    => p_inventory_item_id
            , uom_rate   => l_uom_rate
            );
   l_txn_qty := p_transaction_quantity * l_uom_rate;
   IF (l_debug = 1) THEN
      mdebug ('Transaction qty in primary units: '||l_txn_qty);
   END IF;

   if l_cost_group_id is not null then
     OPEN c_moq(l_cost_group_id);
     FETCH c_moq INTO l_cgcnt;
     CLOSE c_moq;
     IF (l_debug = 1) THEN
        mdebug ('count for different cost group than the allocated: '||l_cgcnt);
     END IF;
     if l_cgcnt >=1 then
        p_ok_to_process := 'costgroup';
        x_return_status := l_return_status;
        x_msg_count:= 0;
        x_msg_data := null;
        return;
     end if;
   end if;


   inv_txn_validations.get_available_quantity
     (x_return_status       => l_return_status,
      p_tree_mode           => INV_Quantity_Tree_PUB.g_loose_only_mode,
      p_organization_id     => p_organization_id,
      p_inventory_item_id   => p_inventory_item_id,
      p_is_revision_control => p_is_revision_control,
      p_is_lot_control      => p_is_lot_control,
      p_is_serial_control   => p_is_serial_control ,
      p_revision            => p_revision,
      p_lot_number          => p_lot_number ,
      p_lot_expiration_date => l_lot_exp_dt,
      p_subinventory_code   => p_subinventory_code,
      p_locator_id          => p_locator_id,
      p_source_type_id      => l_transaction_source_type_id,
      x_qoh                 => l_new_qoh,
      x_att                 => l_new_att,
      x_pqoh                => l_new_pqoh,
      x_tqoh                => l_new_tqoh,
      x_atpp1               => l_new_atpp1,
      x_qoh1                => l_new_qoh1,
      p_cost_group_id       => l_cost_group_id,
      p_transfer_subinventory => p_transfer_subinventory);

   IF (l_debug = 1) THEN
      mdebug(l_new_qoh || '   ' || l_new_att || '   ' || l_new_pqoh || '   ' || l_new_tqoh || '   ' || l_new_atpp1 || '   ' || l_new_qoh1);
   END IF;

   -- If org allows negative inventory balances
   --
   IF l_inv_rcpt_code = 1 THEN

      IF (l_debug = 1) THEN
         mdebug('org allows negative inventory balances');
      END IF;

      p_ok_to_process := 'true';

      IF (l_new_att < l_txn_qty) THEN

    IF l_suggested_sub_code   <> p_subinventory_code OR
      l_suggested_loc_id     <> p_locator_id THEN

       IF (l_debug = 1) THEN
          mdebug('suggested sub/loc are different from the actual sub/loc');
       END IF;

       IF (least(nvl(l_new_att, 0), nvl(l_new_tqoh - l_new_pqoh,0)) >= l_txn_qty) THEN

          p_ok_to_process := 'true';

        ELSE
          /*
          Bug #2075166.
       When negative inventory is allowed for the organization
       Change the ok_to_process flag to warning in order that
       a warning message id displayed instead of error.
       */
       p_ok_to_process := 'warning';
          IF (l_debug = 1) THEN
             mdebug('Driving inventory negative. Throw a warning');
          END IF;

       END IF;

     ELSE

       IF (l_debug = 1) THEN
          mdebug('suggested sub/loc are same as the actual sub/loc');
       END IF;

       IF (least((nvl(l_new_att,0) + l_txn_qty), nvl(l_new_tqoh - l_new_pqoh,0)) >= l_txn_qty) THEN

          p_ok_to_process := 'true';

        ELSE
        /*
          Bug #2075166.
       When negative inventory is allowed for the organization
       Change the ok_to_process flag to warning in order that
       a warning message id displayed instead of error.
       */
       p_ok_to_process := 'warning';
          IF (l_debug = 1) THEN
             mdebug('Driving inventory negative. Throw a warning');
          END IF;
          --p_ok_to_process := 'false';
          --mdebug('Cannot drive inventory negative when reservations exist');
       END IF;

    END IF;

      END IF;

      x_return_status := l_return_status; /* Success */
      return;
   END IF;

   --
   -- Org does not allow negative inventory balances
   -- so continue.
   IF (l_debug = 1) THEN
      mdebug('org does not allow negative inventory balances');
   END IF;

   IF (l_new_att < l_txn_qty) THEN

      IF (l_debug = 1) THEN
         mdebug('l_new_att < l_txn_qty');
      END IF;

      IF l_suggested_sub_code   <> p_subinventory_code OR
    l_suggested_loc_id     <> p_locator_id THEN

    IF (l_debug = 1) THEN
       mdebug('suggested sub/loc are different from the actual sub/loc');
    END IF;

    IF (least(nvl(l_new_att, 0), nvl(l_new_tqoh - l_new_pqoh,0)) >= l_txn_qty) THEN

       p_ok_to_process := 'true';

     ELSE

       p_ok_to_process := 'false';

    END IF;

       ELSE

    IF (l_debug = 1) THEN
       mdebug('suggested sub/loc are the same as the actual sub/loc');
    END IF;

    IF (least((nvl(l_new_att,0) + l_txn_qty), nvl(l_new_tqoh - l_new_pqoh,0)) >= l_txn_qty) THEN

       p_ok_to_process := 'true';

     ELSE

       p_ok_to_process := 'false';

    END IF;

      END IF;

    ELSE

      p_ok_to_process := 'true';
   END IF;

   x_return_status := l_return_status;

EXCEPTION
    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
        IF (l_debug = 1) THEN
           mdebug ('@'||x_msg_data||'@');
        END IF;

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
        IF (l_debug = 1) THEN
           mdebug ('@'||x_msg_data||'@');
        END IF;

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
        IF (l_debug = 1) THEN
           mdebug ('@'||x_msg_data||'@');
        END IF;

END check_loose_quantity;


PROCEDURE CHECK_WMS_INSTALL (
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_msg_count OUT NOCOPY NUMBER,
                               p_msg_data OUT NOCOPY VARCHAR2,
                               p_org IN NUMBER
                              )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
  IF wms_install.check_install(x_return_status,
                                   p_msg_count,
                                   p_msg_data,
                                   p_org) THEN
     x_return_status := 'Y';
  ELSE
     x_return_status := 'N';
  END IF;

END check_WMS_install;



FUNCTION check_lpn_reservation(p_lpn_id     IN NUMBER,
                               p_org_id     IN NUMBER,
                               x_return_msg  OUT NOCOPY VARCHAR2)
  RETURN  VARCHAR2

  IS
      l_lpn_id   NUMBER;
      l_cnt      NUMBER :=0 ;
      x_return VARCHAR2(1)  := 'Y';

      CURSOR  c_lpn_content IS
          select lpn_id
          from   wms_license_plate_numbers
          where  outermost_lpn_id = p_lpn_id
          and    organization_id = p_org_id;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
       OPEN c_lpn_content;
       LOOP
              FETCH  c_lpn_content INTO  l_lpn_id;
              EXIT WHEN  c_lpn_content%NOTFOUND;


         select count(*)
         into  l_cnt
         from mtl_reservations
         where lpn_id = l_lpn_id
         and organization_id = p_org_id;

         if l_cnt >= 1 then
             IF (l_debug = 1) THEN
                mdebug ('lpn '||l_lpn_id||' is reserved.');
             END IF;
        x_return := 'N';
        fnd_message.set_name('INV', 'INV_LPN_RESERVED');
        x_return_msg := fnd_message.get;
        RETURN  x_return;
         end if;

       END LOOP;
       CLOSE  c_lpn_content;
       x_return_msg := 'SUCCESS';
       RETURN x_return;
       EXCEPTION
            WHEN OTHERS THEN
                   IF (l_debug = 1) THEN
                      mdebug ('Other exception raised in check_lpn_reservation');
                   END IF;
                   x_return := 'N';
                   x_return_msg := 'OTHER ERROR';
            RETURN  x_return;
END check_lpn_reservation;



FUNCTION check_lpn_allocation(p_lpn_id  IN NUMBER,
                              p_org_id  IN NUMBER,
                              x_return_msg  OUT NOCOPY VARCHAR2)
  RETURN  VARCHAR2

  IS
      l_lpn_id   NUMBER;
      l_cnt      NUMBER :=0 ;
      x_return   VARCHAR2(1)  := 'Y';

      CURSOR  c_lpn_content IS
        select lpn_id
        from   wms_license_plate_numbers
        where  outermost_lpn_id = p_lpn_id
        and    organization_id = p_org_id;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
     OPEN c_lpn_content;
     LOOP
        FETCH  c_lpn_content INTO  l_lpn_id;
        EXIT WHEN  c_lpn_content%NOTFOUND;

        select count(*)
        into  l_cnt
        from mtl_material_transactions_temp
        where allocated_lpn_id = l_lpn_id
        and organization_id = p_org_id;

        if l_cnt >=1 then
            IF (l_debug = 1) THEN
               mdebug ('lpn '||l_lpn_id||' is allocated.');
            END IF;
            x_return := 'N';
            fnd_message.set_name('INV', 'INV_LPN_ALLOCATED');
            x_return_msg := fnd_message.get;
            RETURN  x_return;
        end if;
     END LOOP;
     CLOSE  c_lpn_content;
     x_return_msg := 'SUCCESS';
     RETURN x_return;
     EXCEPTION
        WHEN OTHERS THEN
            IF (l_debug = 1) THEN
               mdebug ('Other exception raised in check_lpn_allocation');
            END IF;
            x_return := 'N';
            x_return_msg := 'OTHER ERROR';
            RETURN  x_return;
END check_lpn_allocation;


FUNCTION check_lpn_serial_allocation(p_lpn_id       IN NUMBER,
                                     p_org_id       IN NUMBER,
                                     x_return_msg  OUT NOCOPY VARCHAR2)
  RETURN  VARCHAR2

  IS
      l_lpn_id                 NUMBER;
      l_cnt                    NUMBER:= 0;
      l_inventory_item_id      NUMBER;
      l_serial_number          VARCHAR2(30);
      x_return                 VARCHAR2(1)  := 'Y';

      CURSOR  c_lpn_content IS
        select lpn_id
        from   wms_license_plate_numbers
        where  outermost_lpn_id = p_lpn_id
        and    organization_id = p_org_id;

      CURSOR  c_lpn_serial(p_lpnid NUMBER)  IS
        select  serial_number, inventory_item_id
        from    mtl_serial_numbers
        where   lpn_id = p_lpnid
        and     current_organization_id = p_org_id;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
     OPEN c_lpn_content;
     LOOP
        FETCH  c_lpn_content INTO  l_lpn_id;
        EXIT WHEN  c_lpn_content%NOTFOUND;

        OPEN  c_lpn_serial(l_lpn_id);
        LOOP
            FETCH  c_lpn_serial INTO  l_serial_number, l_inventory_item_id;
            EXIT WHEN c_lpn_serial%NOTFOUND;

            begin
          select 1
          into   l_cnt
          from mtl_serial_numbers_temp msnt,
          mtl_transaction_lots_temp  mtlt,
          mtl_material_transactions_temp  mmtt
          where mmtt.organization_id = p_org_id
          and   mmtt.inventory_item_id = l_inventory_item_id
          and   mmtt.transaction_temp_id = mtlt.transaction_temp_id(+)
          and   l_serial_number between msnt.fm_serial_number and nvl(msnt.to_serial_number,msnt.fm_serial_number)
          and   msnt.transaction_temp_id = nvl(mtlt.serial_transaction_temp_id, mmtt.transaction_temp_id);

          if l_cnt = 1 then
              IF (l_debug = 1) THEN
                 mdebug ('serial no: '||l_serial_number||' in lpn '||l_lpn_id||' is allocated.');
              END IF;
         x_return := 'N';
         fnd_message.set_name('INV', 'INV_SERIAL_ALLOCATED');
         x_return_msg := fnd_message.get;
         RETURN  x_return;
                    end if;
       exception
          when no_data_found then
             l_cnt := 0;
          when OTHERS then
             x_return := 'N';
        x_return_msg := 'OTHER ERROR';
                  RETURN  x_return;
            end;
        END LOOP;
        CLOSE c_lpn_serial;
     END LOOP;
     CLOSE  c_lpn_content;
     x_return_msg := 'SUCCESS';
     RETURN x_return;
EXCEPTION
     WHEN OTHERS THEN
           IF (l_debug = 1) THEN
              mdebug ('Other exception raised in check_serial_allocation');
           END IF;
           x_return := 'N';
           x_return_msg := 'OTHER ERROR';
           RETURN  x_return;
END check_lpn_serial_allocation;


FUNCTION check_item_serial_allocation(p_item_id       IN NUMBER,
                                      p_org_id        IN NUMBER,
                                      p_serial_number IN VARCHAR2,
                                      x_return_msg    OUT NOCOPY VARCHAR2)
  RETURN  VARCHAR2

  IS
      l_cnt          NUMBER:= 0;
      x_return       VARCHAR2(1)  := 'Y';

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

     select 1
     into  l_cnt
     from mtl_serial_numbers_temp         msnt,
      mtl_transaction_lots_temp       mtlt,
      mtl_material_transactions_temp  mmtt
     where mmtt.organization_id = p_org_id
       and mmtt.inventory_item_id = p_item_id
       and mmtt.transaction_temp_id = mtlt.transaction_temp_id(+)
       and p_serial_number between msnt.fm_serial_number and nvl(msnt.to_serial_number,msnt.fm_serial_number)
       and msnt.transaction_temp_id = nvl(mtlt.serial_transaction_temp_id, mmtt.transaction_temp_id);

       if l_cnt = 1 then
      x_return := 'N';
      fnd_message.set_name('INV', 'INV_SERIAL_ALLOCATED');
      x_return_msg := fnd_message.get;
      RETURN  x_return;
       end if;

exception
       when no_data_found then
     l_cnt := 0;
     x_return_msg := 'SUCCESS';
     RETURN x_return;
       WHEN OTHERS THEN
          IF (l_debug = 1) THEN
             mdebug ('Other exception raised in check_item_serial_allocation');
          END IF;
     x_return := 'N';
     x_return_msg := 'OTHER ERROR';
     RETURN  x_return;
END check_item_serial_allocation;



FUNCTION validate_lpn_status_quantity(
                                      p_lpn_id IN NUMBER,
                                      p_orgid IN NUMBER,
                                      p_to_org_id IN NUMBER,
                                      p_wms_installed IN VARCHAR2,
                                      p_transaction_type_id IN NUMBER,
                       p_source_type_id IN NUMBER,
                       x_return_msg OUT NOCOPY VARCHAR2
                                     )
   RETURN VARCHAR2
   IS
     x_return VARCHAR2(1);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
     x_return := inv_ui_item_sub_loc_lovs.vaildate_lpn_status(
                                                              p_lpn_id,
                                                              p_orgid,
                                                              p_to_org_id,
                                                              p_wms_installed,
                                                              p_transaction_type_id
                                                             );
     /*
        x_return_msg is set to 'VALIDATE_LPN_STATUS_FAILED' to indicate to the calling
        java code that 'vaildate_lpn_status' has failed.
     */
     if ( x_return = 'N' ) then
        x_return_msg := 'VALIDATE_LPN_STATUS_FAILED';
        return x_return;
     end if;

     -- check if lpn/any inner lpn  is allocated
     x_return := check_lpn_allocation(p_lpn_id, p_orgid, x_return_msg );

     if ( x_return = 'N' ) then
        x_return_msg := 'VALIDATE_LPN_ALLOC_FAILED';
        return  x_return;
     end if;

     -- check if any serial number in lpn/any inner lpn is allocated
     x_return := check_lpn_serial_allocation(p_lpn_id, p_orgid, x_return_msg);
     if (x_return = 'N' ) then
         x_return_msg := 'VALIDATE_LPN_SERIAL_ALLOC_FAILED';
         return  x_return;
     end if;

    --Bug#4446248.Check if any pending transactions are there for this LPN/inner LPNs.
         --Adding this code in both forms of validate_lpn_status_quantity
     x_return := check_lpn_pending_txns(p_lpn_id, p_orgid, x_return_msg);
     if (x_return = 'N' ) then
         x_return_msg := 'VALIDATE_LPN_PENDING_TXNS_FAILED';
         return  x_return;
     end if;

     return check_lpn_quantity( p_lpn_id, p_orgid, p_source_type_id, p_transaction_type_id, x_return_msg);

END validate_lpn_status_quantity;


-- Bug# 2358224
-- Overloaded version of the previous function passing in
-- the to/transfer subinventory.  The only difference is
-- that it calls check_lpn_quantity passing in the
-- to/transfer subinventory input parameter
FUNCTION validate_lpn_status_quantity(
                                      p_lpn_id                IN  NUMBER,
                                      p_orgid                 IN  NUMBER,
                                      p_to_org_id             IN  NUMBER,
                                      p_wms_installed         IN  VARCHAR2,
                                      p_transaction_type_id   IN  NUMBER,
                       p_source_type_id        IN  NUMBER,
                  p_to_subinventory_code  IN  VARCHAR2,
                       x_return_msg            OUT NOCOPY VARCHAR2
                                     )
   RETURN VARCHAR2
   IS
     x_return VARCHAR2(1);
     l_count NUMBER;
     l_action_id NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    /** Bug 2403417 - add a check of the lpn context. If the lpn Context is "Picked"
   and transaction is subtransfer, return error INV_LPN_DELIVERY_ASSOC
     **/

     if( p_source_type_id = INV_GLOBALS.G_SourceType_Inventory ) then
   select transaction_action_id
   into l_action_id
   From mtl_transaction_types
   where transaction_type_id = p_transaction_Type_id
   And transaction_Source_Type_id = p_source_type_id;

        if( l_action_id = INV_GLOBALS.G_Action_Subxfr ) then
            select count(wdd.delivery_detail_id)
            into l_count
            From wsh_delivery_details wdd, wms_license_plate_numbers wlpn
            WHere wdd.lpn_id = wlpn.lpn_id
            and wlpn.lpn_context = wms_Container_pub.LPN_Context_Picked
            and wlpn.lpn_id = p_lpn_id
	    and wdd.released_status = 'X';  -- For LPN reuse ER : 6845650

            if( l_count > 0 ) then
          x_return := 'N';
               x_return_msg := 'INV_LPN_DELIVERY_ASSOC';
          return x_return;
            end if;
        end if;
     end if;
     /** End changes for bug 2403417 **/

     --Bug 5512205 Commented out the call to inv_ui_item_sub_loc_lovs.vaildate_lpn_status as the LPN statuses are already validated
     --while populating the LPN LOV in the Sub Xfer Page.
     /*
     x_return := inv_ui_item_sub_loc_lovs.vaildate_lpn_status(
                                                              p_lpn_id,
                                                              p_orgid,
                                                              p_to_org_id,
                                                              p_wms_installed,
                                                              p_transaction_type_id
                                                             );*/
     /*
        x_return_msg is set to 'VALIDATE_LPN_STATUS_FAILED' to indicate to the calling
        java code that 'vaildate_lpn_status' has failed.
     */
     /*
     if ( x_return = 'N' ) then
        x_return_msg := 'VALIDATE_LPN_STATUS_FAILED';
        return x_return;
     end if;
     */
     --End Bug 5512205

     -- check if lpn/any inner lpn  is allocated
     x_return := check_lpn_allocation(p_lpn_id, p_orgid, x_return_msg );

     if ( x_return = 'N' ) then
        x_return_msg := 'VALIDATE_LPN_ALLOC_FAILED';
        return  x_return;
     end if;

     -- check if any serial number in lpn/any inner lpn is allocated
     x_return := check_lpn_serial_allocation(p_lpn_id, p_orgid, x_return_msg);
     if (x_return = 'N' ) then
         x_return_msg := 'VALIDATE_LPN_SERIAL_ALLOC_FAILED';
         return  x_return;
     end if;

    --Bug#4446248.Check if any pending transactions are there for this LPN/inner LPNs.
         --Adding this code in both forms of validate_lpn_status_quantity
     x_return := check_lpn_pending_txns(p_lpn_id, p_orgid, x_return_msg);
     if (x_return = 'N' ) then
         x_return_msg := 'VALIDATE_LPN_PENDING_TXNS_FAILED';
         return  x_return;
     end if;

     return check_lpn_quantity( p_lpn_id, p_orgid, p_source_type_id,p_transaction_type_id,p_to_subinventory_code, x_return_msg);

END validate_lpn_status_quantity;



FUNCTION validate_lpn_status_quantity2(
                                      p_lpn_id IN NUMBER,
                                      p_orgid IN NUMBER,
                                      p_to_org_id IN NUMBER,
                                      p_wms_installed IN VARCHAR2,
                                      p_transaction_type_id IN NUMBER,
                       p_source_type_id IN NUMBER,
                       x_return_msg OUT NOCOPY VARCHAR2
                                     )
   RETURN VARCHAR2
   IS
     x_return VARCHAR2(1);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
     x_return := inv_ui_item_sub_loc_lovs.vaildate_lpn_status(
                                                              p_lpn_id,
                                                              p_orgid,
                                                              p_to_org_id,
                                                              p_wms_installed,
                                                              p_transaction_type_id
                                                             );
     /*
        x_return_msg is set to 'VALIDATE_LPN_STATUS_FAILED' to indicate to the calling
        java code that 'vaildate_lpn_status' has failed.
     */
     if ( x_return = 'N' ) then
        x_return_msg := 'VALIDATE_LPN_STATUS_FAILED';
        return x_return;
     end if;

     -- check if lpn/any inner lpn  is reserveded
     x_return := check_lpn_reservation(p_lpn_id, p_orgid, x_return_msg );

     if ( x_return = 'N' ) then
        x_return_msg := 'VALIDATE_LPN_RSV_FAILED';
        return  x_return;
     end if;

     -- check if lpn/any inner lpn  is allocated;
     x_return := check_lpn_allocation(p_lpn_id, p_orgid, x_return_msg );

     if ( x_return = 'N' ) then
         x_return_msg := 'VALIDATE_LPN_ALLOC_FAILED';
         return  x_return;
     end if;

     -- check if any serial number in lpn/any inner lpn is allocated
     x_return := check_lpn_serial_allocation(p_lpn_id, p_orgid, x_return_msg);
     if (x_return = 'N' ) then
          x_return_msg := 'VALIDATE_LPN_SERIAL_ALLOC_FAILED';
          return  x_return;
     end if;

     return check_lpn_quantity( p_lpn_id, p_orgid, p_source_type_id, p_transaction_type_id,x_return_msg);

END validate_lpn_status_quantity2;



-- returns Y for success and N for not

FUNCTION orgxfer_lpn_check(
                                      p_lpn_id IN NUMBER,
                                      p_orgid IN NUMBER,
                                      p_to_org_id IN NUMBER,
                                      p_wms_installed IN VARCHAR2,
                                      p_transaction_type_id IN NUMBER,
                                      p_source_type_id IN NUMBER,
                                      x_return_msg OUT NOCOPY VARCHAR2
                                     )
   RETURN VARCHAR2
   IS
     x_return VARCHAR2(1);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

     --check the toorg
     x_return := INV_UI_ITEM_SUB_LOC_LOVS.validate_lpn_for_toorg(p_lpn_id, p_to_org_id, p_orgid, p_transaction_type_id);
     if (x_return <> 'Y') then
        x_return_msg := 'INVALID_TO_ORG';
        return x_return;
     end if;

     --check the status
     x_return := inv_ui_item_sub_loc_lovs.vaildate_lpn_status( p_lpn_id,
                                                              p_orgid,
                                                              p_to_org_id,
                                                              p_wms_installed,
                                                              p_transaction_type_id);
     if ( x_return <> 'Y' ) then
        x_return_msg := 'INVALID_STATUS';
        return x_return;
     end if;

     -- check if lpn/any inner lpn  is reserveded;
     x_return := check_lpn_reservation(p_lpn_id, p_orgid, x_return_msg);

     if ( x_return = 'N' ) then
        x_return_msg := 'VALIDATE_LPN_RSV_FAILED';
        return  x_return;
     end if;

     -- check if lpn/any inner lpn  is allocated;
     x_return := check_lpn_allocation(p_lpn_id, p_orgid, x_return_msg);

     if ( x_return = 'N' ) then
        x_return_msg := 'VALIDATE_LPN_ALLOC_FAILED';
        return  x_return;
     end if;

     -- check if any serial number in lpn/any inner lpn is allocated
     x_return := check_lpn_serial_allocation(p_lpn_id, p_orgid, x_return_msg);
     if (x_return = 'N' ) then
         x_return_msg := 'VALIDATE_LPN_SERIAL_ALLOC_FAILED';
         return  x_return;
     end if;

     --check quantity
      x_return := check_lpn_quantity( p_lpn_id, p_orgid, p_source_type_id, p_transaction_type_id,x_return_msg);
      if ( x_return <> 'Y' ) then
        return x_return;
      end if;

      return x_return;

END orgxfer_lpn_check;


FUNCTION check_lpn_quantity(p_lpn_id IN NUMBER,
             p_organization_id IN NUMBER,
             p_source_type_id IN NUMBER,
             p_transaction_type_id  IN NUMBER,
             x_return_msg OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2

  IS
     l_msg_count VARCHAR2(100);
     l_msg_data VARCHAR2(1000);
     l_rqoh NUMBER;
     l_qr NUMBER;
     l_qs NUMBER;
     l_atr NUMBER;
     x_return VARCHAR2(1);
     l_return_status VARCHAR2(1);
     l_is_revision_control BOOLEAN := FALSE;
     l_is_lot_control BOOLEAN := FALSE;
     l_is_serial_control BOOLEAN := FALSE;
     l_item_id NUMBER;
     l_revision VARCHAR2(3);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
     l_lot_number VARCHAR2(80);
     l_subinventory_code VARCHAR2(10);
     l_locator_id NUMBER ;
     l_revison_control_code NUMBER;
     l_serial_number_control_code NUMBER;
     l_lot_control_code NUMBER ;
     l_att NUMBER;
     l_qoh NUMBER;
     --l_sum NUMBER;
     l_parent_lpn_id  NUMBER;
     l_lpn_context NUMBER ;
     l_updt_qoh     NUMBER;
     l_tree_mode  INTEGER := INV_Quantity_Tree_PUB.g_transaction_mode;

     TYPE l_rec IS RECORD (
            inventory_item_id NUMBER,
            parent_lpn_id     NUMBER,
            --sumqty NUMBER,
            revision VARCHAR2(3),
            lpn_context NUMBER ,
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
            lot_number VARCHAR2(80));

     l_record l_rec;

     CURSOR l_item_cursor IS
   SELECT wlc.inventory_item_id,
          wlc.parent_lpn_id,      -- lpn reservation change
          --SUM(wlc.quantity) sumqty,   lpn reservation change
          wlc.revision,
          wlpn.lpn_context, wlc.lot_number
     FROM wms_lpn_contents wlc,
          wms_license_plate_numbers wlpn
     WHERE wlpn.outermost_lpn_id =  p_lpn_id
     AND wlpn.organization_id = p_organization_id
     AND wlc.parent_lpn_id = wlpn.lpn_id
     GROUP BY wlc.parent_lpn_id, wlc.inventory_item_id, wlc.revision, wlpn.lpn_context,wlc.lot_number ;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   /* Assuming p_lpn_id CAN NOT BE NULL   */
   x_return :='Y';
   x_return_msg :='';

   /* if transaction is subxfe ormo subxfer we should conside reserved qty. since reserved qty can be subxfered*/
   if p_transaction_type_id in (2,64) then
      l_tree_mode := INV_Quantity_Tree_PUB.g_no_lpn_rsvs_mode;
   end if;

   -- Clearing the quantity cache
   inv_quantity_tree_pub.clear_quantity_cache;

-- OPTIMIZED BELOW FOR PERFORMANCE MXGUPTA JUNE 4 2001
--   SELECT DISTINCT wlpn.subinventory_code, wlpn.locator_id
--     INTO l_subinventory_code, l_locator_id
--     FROM wms_lpn_contents wlc,
--          wms_license_plate_numbers wlpn
--     WHERE wlpn.organization_id = p_organization_id
--     AND wlpn.outermost_lpn_id =  p_lpn_id
--     AND wlc.parent_lpn_id = wlpn.lpn_id;

   SELECT DISTINCT subinventory_code, locator_id
     INTO l_subinventory_code, l_locator_id
     FROM wms_license_plate_numbers
     WHERE organization_id = p_organization_id
     AND lpn_id = p_lpn_id;

   OPEN l_item_cursor;

   LOOP
      fetch l_item_cursor into l_record;
      exit when l_item_cursor%notfound;

      l_item_id := l_record.inventory_item_id;
      l_revision := l_record.revision;
      l_parent_lpn_id := l_record.parent_lpn_id;
      --l_sum := l_record.sumqty;
      l_lpn_context := l_record.lpn_context;
      l_lot_number := l_record.lot_number;

      IF l_lpn_context NOT IN (1) THEN
    x_return := 'N';
    fnd_message.set_name('INV', 'INV_NOT_INVENTORY');
    x_return_msg := fnd_message.get;
       RETURN x_return;
      END IF ;

      SELECT revision_qty_control_code ,
   serial_number_control_code,
   lot_control_code
        INTO l_revison_control_code,
   l_serial_number_control_code,
   l_lot_control_code
   FROM mtl_system_items
   WHERE inventory_item_id = l_item_id
   AND organization_id = p_organization_id;

      l_is_revision_control := FALSE;
      l_is_lot_control := FALSE;
      l_is_serial_control := FALSE;

      IF l_revison_control_code = 2 THEN
    l_is_revision_control := TRUE;
      END IF;
      IF l_lot_control_code = 2 THEN
    l_is_lot_control := TRUE;
      END IF;

      IF l_serial_number_control_code IN (2,5,6) THEN
    l_is_serial_control := TRUE;
      END IF;

      inv_quantity_tree_pub.query_quantities
   (  p_api_version_number      =>   1.0
      , p_init_msg_lst          =>   fnd_api.g_false
      , x_return_status         =>   l_return_status
      , x_msg_count             =>   l_msg_count
      , x_msg_data              =>   l_msg_data
      , p_organization_id       =>   p_organization_id
      , p_inventory_item_id     =>   l_item_id
      , p_tree_mode             =>   l_tree_mode
      , p_is_revision_control   =>   l_is_revision_control
      , p_is_lot_control        =>   l_is_lot_control
      , p_is_serial_control     =>   l_is_serial_control
      , p_demand_source_type_id =>   p_source_type_id
      , p_revision              =>   l_revision
      , p_lot_number            =>   l_lot_number
      , p_subinventory_code     =>   l_subinventory_code
      , p_locator_id            =>   l_locator_id
      , x_qoh                   =>   l_qoh
      , x_rqoh         =>   l_rqoh
      , x_qr           =>   l_qr
      , x_qs           =>   l_qs
      , x_att          =>   l_att
      , x_atr          =>   l_atr
      , p_lpn_id                =>   l_parent_lpn_id           --added for lpn reservation
   );

      IF (l_return_status = 'S') THEN
    --IF (l_sum < l_att OR l_sum = l_att) THEN    LPN reservation change
    IF  (l_qoh = l_att) THEN
       x_return := 'Y';
       x_return_msg :='SUCCESS';
    ELSE
       x_return := 'F';
       FND_MESSAGE.set_name('INV', 'INV_LPN_QTY_ERR');
       x_return_msg :=fnd_message.get;
       RETURN x_return;
    END IF ;
      ELSE
    x_return :='F';
    FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
    FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
    x_return_msg := fnd_message.get;
    RETURN x_return;
      END IF ;
      l_updt_qoh := - l_qoh;
       /*need to update qty tree    */
      inv_quantity_tree_pub.update_quantities
                  (  p_api_version_number    =>   1.0
         , p_init_msg_lst          =>   fnd_api.g_false
         , x_return_status         =>   l_return_status
         , x_msg_count             =>   l_msg_count
         , x_msg_data              =>   l_msg_data
         , p_organization_id       =>   p_organization_id
         , p_inventory_item_id     =>   l_item_id
         , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
         , p_is_revision_control   =>   l_is_revision_control
         , p_is_lot_control        =>   l_is_lot_control
         , p_is_serial_control     =>   l_is_serial_control
         , p_demand_source_type_id =>   p_source_type_id
         , p_revision              =>   l_revision
         , p_lot_number            =>   l_lot_number
         , p_subinventory_code     =>   l_subinventory_code
         , p_locator_id            =>   l_locator_id
         , p_primary_quantity      =>   l_updt_qoh
         , p_quantity_type         =>   inv_quantity_tree_pvt.g_qoh
         , x_qoh                   =>   l_qoh
         , x_rqoh         =>   l_rqoh
         , x_qr           =>   l_qr
         , x_qs           =>   l_qs
         , x_att          =>   l_att
         , x_atr          =>   l_atr
         , p_lpn_id                =>   l_parent_lpn_id           --added for lpn reservation
   );

   END LOOP ;
   CLOSE l_item_cursor;
   RETURN x_return;
   EXCEPTION
                WHEN NO_DATA_FOUND THEN
                x_return_msg := 'NO_DATA_FOUND';
                x_return :='F';
                RETURN x_return;
END check_lpn_quantity;


-- Bug# 2358224
-- Overloaded version of the previous function passing in
-- the to/transfer subinventory.  This is the same as the
-- previous call with the only difference being that the
-- call to inv_quantity_tree_pub.query_quantities passes
-- the p_transfer_subinventory_code input parameter


-- Bug # 2433095 -- Changes to LPN reservations ported to the ovreloaded
-- function. Transaction_type id is also being passed to check for the sub
-- and move order transfer

FUNCTION check_lpn_quantity(p_lpn_id                IN  NUMBER,
             p_organization_id       IN  NUMBER,
             p_source_type_id        IN  NUMBER,
             p_transaction_type_id  IN NUMBER,
             p_to_subinventory_code  IN  VARCHAR2,
             x_return_msg            OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2

  IS
     l_msg_count VARCHAR2(100);
     l_msg_data VARCHAR2(1000);
     l_rqoh NUMBER;
     l_qr NUMBER;
     l_qs NUMBER;
     l_atr NUMBER;
     x_return VARCHAR2(1);
     l_return_status VARCHAR2(1);
     l_is_revision_control BOOLEAN := FALSE;
     l_is_lot_control BOOLEAN := FALSE;
     l_is_serial_control BOOLEAN := FALSE;
     l_item_id NUMBER;
     l_revision VARCHAR2(3);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
     l_lot_number VARCHAR2(80);
     l_subinventory_code VARCHAR2(10);
     l_locator_id NUMBER;
     l_revison_control_code NUMBER;
     l_serial_number_control_code NUMBER;
     l_lot_control_code NUMBER;
     l_att NUMBER;
     l_qoh NUMBER;
    -- l_sum NUMBER;
     l_parent_lpn_id  NUMBER;
     l_lpn_context NUMBER ;
     l_updt_qoh     NUMBER;
     l_tree_mode  INTEGER := INV_Quantity_Tree_PUB.g_transaction_mode;

     TYPE l_rec IS RECORD (
            inventory_item_id NUMBER,
            parent_lpn_id     NUMBER,
            --sumqty NUMBER,
            revision VARCHAR2(3),
            lpn_context NUMBER ,
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
            lot_number VARCHAR2(80));

     l_record l_rec;

     CURSOR l_item_cursor IS
   SELECT wlc.inventory_item_id,
          wlc.parent_lpn_id,   -- lpn reservation change
        --  SUM(wlc.quantity) sumqty,
          wlc.revision,
          wlpn.lpn_context, wlc.lot_number
     FROM wms_lpn_contents wlc,
          wms_license_plate_numbers wlpn
     WHERE wlpn.outermost_lpn_id =  p_lpn_id
     AND wlpn.organization_id = p_organization_id
     AND wlc.parent_lpn_id = wlpn.lpn_id
     GROUP BY wlc.parent_lpn_id, wlc.inventory_item_id, wlc.revision, wlpn.lpn_context,wlc.lot_number ;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
      /* Assuming p_lpn_id CAN NOT BE NULL   */
   x_return :='Y';
   x_return_msg :='';

   IF (l_debug = 1) THEN
      mdebug ('Inside the overloaded function');
   END IF;

 /* if transaction is subxfe ormo subxfer we should conside reserved qty. since reserved qty can be subxfered*/
   if p_transaction_type_id in (2,64) then
      l_tree_mode := INV_Quantity_Tree_PUB.g_no_lpn_rsvs_mode;
   end if;

   -- Clearing the quantity cache
   inv_quantity_tree_pub.clear_quantity_cache;

-- OPTIMIZED BELOW FOR PERFORMANCE MXGUPTA JUNE 4 2001
--   SELECT DISTINCT wlpn.subinventory_code, wlpn.locator_id
--     INTO l_subinventory_code, l_locator_id
--     FROM wms_lpn_contents wlc,
--          wms_license_plate_numbers wlpn
--     WHERE wlpn.organization_id = p_organization_id
--     AND wlpn.outermost_lpn_id =  p_lpn_id
   --     AND wlc.parent_lpn_id = wlpn.lpn_id;

     --mdebug ('l Tree mode' || l_tree_mode);

   SELECT DISTINCT subinventory_code, locator_id
     INTO l_subinventory_code, l_locator_id
     FROM wms_license_plate_numbers
     WHERE organization_id = p_organization_id
     AND lpn_id = p_lpn_id;

   OPEN l_item_cursor;

   LOOP

      fetch l_item_cursor into l_record;
      exit when l_item_cursor%notfound;

      l_item_id := l_record.inventory_item_id;
      l_revision := l_record.revision;
      l_parent_lpn_id := l_record.parent_lpn_id;
      --l_sum := l_record.sumqty;
      l_lpn_context := l_record.lpn_context;
      l_lot_number := l_record.lot_number;

      IF l_lpn_context NOT IN (1) THEN
    x_return := 'N';
    fnd_message.set_name('INV', 'INV_NOT_INVENTORY');
    x_return_msg := fnd_message.get;
       RETURN x_return;
      END IF ;

      SELECT revision_qty_control_code ,
   serial_number_control_code,
   lot_control_code
   INTO l_revison_control_code,
   l_serial_number_control_code,
   l_lot_control_code
   FROM mtl_system_items
   WHERE inventory_item_id = l_item_id
   AND organization_id = p_organization_id;

      l_is_revision_control := FALSE;
      l_is_lot_control := FALSE;
      l_is_serial_control := FALSE;

      IF l_revison_control_code = 2 THEN
    l_is_revision_control := TRUE;
      END IF;
      IF l_lot_control_code = 2 THEN
    l_is_lot_control := TRUE;
      END IF;

      IF l_serial_number_control_code IN (2,5,6) THEN
    l_is_serial_control := TRUE;
      END IF;

      inv_quantity_tree_pub.query_quantities
   (  p_api_version_number            =>   1.0
      , p_init_msg_lst                =>   fnd_api.g_false
      , x_return_status               =>   l_return_status
      , x_msg_count                   =>   l_msg_count
      , x_msg_data                    =>   l_msg_data
      , p_organization_id             =>   p_organization_id
      , p_inventory_item_id           =>   l_item_id
      , p_tree_mode                   =>   l_tree_mode
      , p_is_revision_control         =>   l_is_revision_control
      , p_is_lot_control              =>   l_is_lot_control
      , p_is_serial_control           =>   l_is_serial_control
      , p_demand_source_type_id       =>   p_source_type_id
      , p_revision                    =>   l_revision
      , p_lot_number                  =>   l_lot_number
      , p_subinventory_code           =>   l_subinventory_code
      , p_locator_id                  =>   l_locator_id
      , p_transfer_subinventory_code  =>   p_to_subinventory_code
      , x_qoh                         =>   l_qoh
      , x_rqoh               =>   l_rqoh
      , x_qr                 =>   l_qr
      , x_qs                 =>   l_qs
      , x_att                =>   l_att
      , x_atr                =>   l_atr
      , p_lpn_id                =>   l_parent_lpn_id           --added for lpn reservation
   );

      --mdebug (' The qty' || l_qoh || ' l att ' || l_att);

      IF (l_return_status = 'S') THEN
    -- IF (l_sum < l_att OR l_sum = l_att) THEN -- LPN reservation change
     IF  (l_qoh = l_att) THEN
       x_return := 'Y';
       x_return_msg :='SUCCESS';
     ELSE
       x_return := 'F';
       FND_MESSAGE.set_name('INV', 'INV_LPN_QTY_ERR');
       x_return_msg :=fnd_message.get;
       RETURN x_return;
    END IF ;
       ELSE
    x_return :='F';
    FND_MESSAGE.set_name('INV', 'INV-INVALID_QUANTITY_TYPE');
    FND_MESSAGE.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
    x_return_msg := fnd_message.get;
    RETURN x_return;
      END IF ;

      -- Added for lpn reservations
      l_updt_qoh := - l_qoh;

      --mdebug (' l_updt_qoh ' ||  l_updt_qoh|| ' l qoh ' || l_qoh);

       /*need to update qty tree    */
      inv_quantity_tree_pub.update_quantities
                  (  p_api_version_number    =>   1.0
         , p_init_msg_lst          =>   fnd_api.g_false
         , x_return_status         =>   l_return_status
         , x_msg_count             =>   l_msg_count
         , x_msg_data              =>   l_msg_data
         , p_organization_id       =>   p_organization_id
         , p_inventory_item_id     =>   l_item_id
         , p_tree_mode             =>   INV_Quantity_Tree_PUB.g_transaction_mode
         , p_is_revision_control   =>   l_is_revision_control
         , p_is_lot_control        =>   l_is_lot_control
         , p_is_serial_control     =>   l_is_serial_control
         , p_demand_source_type_id =>   p_source_type_id
         , p_revision              =>   l_revision
         , p_lot_number            =>   l_lot_number
         , p_subinventory_code     =>   l_subinventory_code
         , p_locator_id            =>   l_locator_id
         , p_primary_quantity      =>   l_updt_qoh
         , p_quantity_type         =>   inv_quantity_tree_pvt.g_qoh
         , x_qoh                   =>   l_qoh
         , x_rqoh         =>   l_rqoh
         , x_qr           =>   l_qr
         , x_qs           =>   l_qs
         , x_att          =>   l_att
              , x_atr           =>   l_atr
              , p_transfer_subinventory_code  => p_to_subinventory_code
              , p_lpn_id                =>   l_parent_lpn_id           --added for lpn reservation
   );

   END LOOP ;
   CLOSE l_item_cursor;
   RETURN x_return;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_msg := 'NO_DATA_FOUND';
      x_return :='F';
      RETURN x_return;


END check_lpn_quantity;



-- Gets the immediate quantity of an item in an LPN.
FUNCTION get_immediate_lpn_item_qty(p_lpn_id IN NUMBER,
                                    p_organization_id IN NUMBER,
                                    p_source_type_id IN NUMBER,
                                    p_inventory_item_id IN NUMBER,
                        p_revision IN VARCHAR2,
                     p_locator_id IN NUMBER,
                     p_subinventory_code IN VARCHAR2,
                     p_lot_number IN VARCHAR2,
                     p_is_revision_control IN VARCHAR2,
                     p_is_serial_control IN VARCHAR2,
                     p_is_lot_control IN VARCHAR2,
                     x_transactable_qty OUT NOCOPY NUMBER,
                     x_qoh OUT NOCOPY NUMBER,
                     x_lpn_onhand OUT NOCOPY NUMBER,
                     x_return_msg OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
     l_msg_count VARCHAR2(100);
     l_msg_data VARCHAR2(1000);
     l_rqoh NUMBER;
     l_qr NUMBER;
     l_qs NUMBER;
     l_atr NUMBER;
     l_att NUMBER;
     l_lpn_context NUMBER ;
     l_return_status VARCHAR2(1);
     x_return VARCHAR2(1);
     l_is_revision_control BOOLEAN := FALSE;
     l_is_serial_control BOOLEAN := FALSE;
     l_is_lot_control BOOLEAN := FALSE ;
     l_lpn_context NUMBER;
     l_mod varchar2(20) := 'get_lpn_available';
     l_tree_mode  NUMBER := INV_Quantity_Tree_PUB.g_transaction_mode;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   x_return := 'Y';
   x_return_msg :='';

   -- Clearing the quantity cache
   inv_quantity_tree_pub.clear_quantity_cache;

   IF Upper(p_is_revision_control) = 'TRUE' THEN
      l_is_revision_control := TRUE;
    ELSE
      l_is_revision_control := FALSE;
   END IF;

   IF Upper(p_is_serial_control) = 'TRUE' THEN
      l_is_serial_control := TRUE;
    ELSE
      l_is_serial_control := FALSE;
   END IF ;

   IF Upper(p_is_lot_control) = 'TRUE' THEN
      l_is_lot_control := TRUE;
    ELSE
      l_is_lot_control := FALSE;
   END IF ;

   IF (p_inventory_item_id IS NULL) THEN
      x_return := 'N';
      fnd_message.set_name('INV', 'INV_INT_ITMCODE');
      x_return_msg := fnd_message.get;
      RETURN x_return;
   END IF ;

   IF (p_lpn_id is NOT NULL AND p_lpn_id <> 0)
    THEN
      l_tree_mode := INV_Quantity_Tree_PUB.g_transaction_mode;   --lpn reservation
      /* comment out for lpn reservation  ??? how can we get immediate lpn item quantity by calling
      quantity tree API using new tree mode ?????
      SELECT SUM(quantity)
   INTO x_lpn_onhand
   FROM wms_lpn_contents
   WHERE parent_lpn_id = p_lpn_id
   AND inventory_item_id = p_inventory_item_id
   AND organization_id = p_organization_id
   AND (p_lot_number IS NULL OR lot_number = p_lot_number)
        AND (p_revision IS NULL OR revision = p_revision);

      IF x_lpn_onhand is NULL
   THEN
    x_return := 'N';
    fnd_message.set_name('INV', 'INV_LPN_INVALID');
    x_return_msg := fnd_message.get;
    RETURN x_return;
      END IF;*/
    ELSE
      l_tree_mode := INV_Quantity_Tree_PUB.g_loose_only_mode;
    END IF;

/* Bug 4108760, Commenting the changes done for bug 3246658.
 * Issue in bug 3246658 is solved by bug 3295705.
 * Passing p_lot_expiration_date as sysdate restrict only non
 * expired lots for lot transactions. As per functionality,
 * user should be able to perform lot transactions in expired lots
 */
/*Bug# 3246658: pass p_lot_expiration_date as sysdate so that for lot controlled items
 *with user defined shelf life the build_query does not return FALSE
 */
    inv_quantity_tree_pub.query_quantities
        (p_api_version_number    =>   1.0
       , p_init_msg_lst          =>   fnd_api.g_false
       , x_return_status         =>   l_return_status
       , x_msg_count             =>   l_msg_count
       , x_msg_data              =>   l_msg_data
       , p_organization_id       =>   p_organization_id
       , p_inventory_item_id     =>   p_inventory_item_id
       , p_tree_mode             =>   l_tree_mode
       , p_is_revision_control   =>   l_is_revision_control
       , p_is_lot_control        =>   l_is_lot_control
       , p_is_serial_control     =>   l_is_serial_control
       , p_demand_source_type_id =>   p_source_type_id
       , p_lot_expiration_date   =>   null   --sysdate --bug3246658 --bug4108760
       , p_revision              =>   p_revision
       , p_lot_number            =>   p_lot_number
       , p_subinventory_code     =>   p_subinventory_code
       , p_locator_id            =>   p_locator_id
       , x_qoh                   =>   x_qoh
       , x_rqoh       =>   l_rqoh
       , x_qr              =>   l_qr
       , x_qs              =>   l_qs
       , x_att                   =>   x_transactable_qty
       , x_atr             =>   l_atr
       , p_lpn_id                =>   p_lpn_id     -- lpn reservation
      );


    IF (l_return_status = 'S') THEN
       IF (p_lpn_id IS NOT NULL AND p_lpn_id <> 0) THEN
           x_lpn_onhand := x_qoh;
     /*IF (l_att >= x_lpn_onhand) THEN
        x_transactable_qty := x_lpn_onhand;
        x_return := 'Y';
        x_return_msg :='SUCCESS';
        RETURN x_return;
      ELSE
        x_transactable_qty :=l_att;
        x_return := 'Y';
        x_return_msg :='SUCCESS';
        RETURN x_return;
     END IF ;*/
        ELSE
     --x_transactable_qty :=l_att;
     x_return := 'Y';
     x_return_msg :='SUCCESS';
     RETURN x_return;
       END IF ;
     ELSE
       x_return :='F';
       FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
       FND_MESSAGE.set_token('ROUTINE','INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
       x_return_msg := fnd_message.get;
       RETURN x_return;
    END IF ;

    RETURN x_return;

END get_immediate_lpn_item_qty;


-- Gets the immediate quantity of an item in an LPN.
-- Overloaded function with the following new output parameters (INVCONV):
--    x_transactable_sec_qty OUT NOCOPY NUMBER,
--    x_sqoh OUT NOCOPY NUMBER,
---   x_lpn_sec_onhand OUT NOCOPY NUMBER,

FUNCTION get_immediate_lpn_item_qty(p_lpn_id IN NUMBER,
                                    p_organization_id IN NUMBER,
                                    p_source_type_id IN NUMBER,
                                    p_inventory_item_id IN NUMBER,
                        p_revision IN VARCHAR2,
                     p_locator_id IN NUMBER,
                     p_subinventory_code IN VARCHAR2,
                     p_lot_number IN VARCHAR2,
                     p_is_revision_control IN VARCHAR2,
                     p_is_serial_control IN VARCHAR2,
                     p_is_lot_control IN VARCHAR2,
                     x_transactable_qty OUT NOCOPY NUMBER,
                     x_qoh OUT NOCOPY NUMBER,
                     x_lpn_onhand OUT NOCOPY NUMBER,
                     x_transactable_sec_qty OUT NOCOPY NUMBER,
                     x_sqoh OUT NOCOPY NUMBER,
                     x_lpn_sec_onhand OUT NOCOPY NUMBER,
                     x_return_msg OUT NOCOPY VARCHAR2)

  RETURN VARCHAR2
  IS
     l_msg_count VARCHAR2(100);
     l_msg_data VARCHAR2(1000);

     l_srqoh NUMBER;
     l_sqr NUMBER;
     l_sqs NUMBER;
     l_satr NUMBER;

     l_rqoh NUMBER;
     l_qr NUMBER;
     l_qs NUMBER;
     l_atr NUMBER;

     l_att NUMBER;
     l_lpn_context NUMBER ;
     l_return_status VARCHAR2(1);
     x_return VARCHAR2(1);
     l_is_revision_control BOOLEAN := FALSE;
     l_is_serial_control BOOLEAN := FALSE;
     l_is_lot_control BOOLEAN := FALSE ;
     l_lpn_context NUMBER;
     l_mod varchar2(20) := 'get_lpn_available';
     l_tree_mode  NUMBER := INV_Quantity_Tree_PUB.g_transaction_mode;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   x_return := 'Y';
   x_return_msg :='';

   -- Clearing the quantity cache
   inv_quantity_tree_pub.clear_quantity_cache;

   IF Upper(p_is_revision_control) = 'TRUE' THEN
      l_is_revision_control := TRUE;
    ELSE
      l_is_revision_control := FALSE;
   END IF;

   IF Upper(p_is_serial_control) = 'TRUE' THEN
      l_is_serial_control := TRUE;
    ELSE
      l_is_serial_control := FALSE;
   END IF ;

   IF Upper(p_is_lot_control) = 'TRUE' THEN
      l_is_lot_control := TRUE;
    ELSE
      l_is_lot_control := FALSE;
   END IF ;

   IF (p_inventory_item_id IS NULL) THEN
      x_return := 'N';
      fnd_message.set_name('INV', 'INV_INT_ITMCODE');
      x_return_msg := fnd_message.get;
      RETURN x_return;
   END IF ;

   IF (p_lpn_id is NOT NULL AND p_lpn_id <> 0)
    THEN
      l_tree_mode := INV_Quantity_Tree_PUB.g_transaction_mode;   --lpn reservation
      /* comment out for lpn reservation  ??? how can we get immediate lpn item quantity by calling
      quantity tree API using new tree mode ?????
      SELECT SUM(quantity)
   INTO x_lpn_onhand
   FROM wms_lpn_contents
   WHERE parent_lpn_id = p_lpn_id
   AND inventory_item_id = p_inventory_item_id
   AND organization_id = p_organization_id
   AND (p_lot_number IS NULL OR lot_number = p_lot_number)
        AND (p_revision IS NULL OR revision = p_revision);

      IF x_lpn_onhand is NULL
   THEN
    x_return := 'N';
    fnd_message.set_name('INV', 'INV_LPN_INVALID');
    x_return_msg := fnd_message.get;
    RETURN x_return;
      END IF;*/
    ELSE
      l_tree_mode := INV_Quantity_Tree_PUB.g_loose_only_mode;
    END IF;

/* Bug 4108760, Commenting the changes done for bug 3246658.
 * Issue in bug 3246658 is solved by bug 3295705.
 * Passing p_lot_expiration_date as sysdate restrict only non
 * expired lots for lot transactions. As per functionality,
 * user should be able to perform lot transactions in expired lots
 */
/*Bug# 3246658: pass p_lot_expiration_date as sysdate so that for lot controlled items
 *with user defined shelf life the build_query does not return FALSE
 */
    inv_quantity_tree_pub.query_quantities
        (p_api_version_number    =>   1.0
       , p_init_msg_lst          =>   fnd_api.g_false
       , x_return_status         =>   l_return_status
       , x_msg_count             =>   l_msg_count
       , x_msg_data              =>   l_msg_data
       , p_organization_id       =>   p_organization_id
       , p_inventory_item_id     =>   p_inventory_item_id
       , p_tree_mode             =>   l_tree_mode
       , p_is_revision_control   =>   l_is_revision_control
       , p_is_lot_control        =>   l_is_lot_control
       , p_is_serial_control     =>   l_is_serial_control
       , p_grade_code            =>   NULL
       , p_demand_source_type_id =>   p_source_type_id
       , p_lot_expiration_date   =>   null      --sysdate --bug3246658 --bug 4108760
       , p_revision              =>   p_revision
       , p_lot_number            =>   p_lot_number
       , p_subinventory_code     =>   p_subinventory_code
       , p_locator_id            =>   p_locator_id
       , x_qoh                   =>   x_qoh
       , x_rqoh       =>   l_rqoh
       , x_qr              =>   l_qr
       , x_qs              =>   l_qs
       , x_att                   =>   x_transactable_qty
       , x_atr             =>   l_atr
       , x_sqoh                  =>   x_sqoh
       , x_srqoh                 =>   l_srqoh
       , x_sqr                   =>   l_sqr
       , x_sqs                   =>   l_sqs
       , x_satt                  =>   x_transactable_sec_qty
       , x_satr                  =>   l_satr
       , p_lpn_id                =>   p_lpn_id     -- lpn reservation
      );


    IF (l_return_status = 'S') THEN
       IF (p_lpn_id IS NOT NULL AND p_lpn_id <> 0) THEN
           x_lpn_onhand := x_qoh;
           -- INVCONV start
           x_lpn_sec_onhand := x_sqoh;
           -- INVCONV end
     /*IF (l_att >= x_lpn_onhand) THEN
        x_transactable_qty := x_lpn_onhand;
        x_return := 'Y';
        x_return_msg :='SUCCESS';
        RETURN x_return;
      ELSE
        x_transactable_qty :=l_att;
        x_return := 'Y';
        x_return_msg :='SUCCESS';
        RETURN x_return;
     END IF ;*/
        ELSE
     --x_transactable_qty :=l_att;
     x_return := 'Y';
     x_return_msg :='SUCCESS';
     RETURN x_return;
       END IF ;
     ELSE
       x_return :='F';
       FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
       FND_MESSAGE.set_token('ROUTINE','INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
       x_return_msg := fnd_message.get;
       RETURN x_return;
    END IF ;

    RETURN x_return;

END get_immediate_lpn_item_qty;

FUNCTION get_unpacksplit_lpn_item_qty(p_lpn_id IN NUMBER,
                                    p_organization_id IN NUMBER,
                                    p_source_type_id IN NUMBER,
                                    p_inventory_item_id IN NUMBER,
                        p_revision IN VARCHAR2,
                     p_locator_id IN NUMBER,
                     p_subinventory_code IN VARCHAR2,
                     p_lot_number IN VARCHAR2,
                     p_is_revision_control IN VARCHAR2,
                     p_is_serial_control IN VARCHAR2,
                     p_is_lot_control IN VARCHAR2,
                     p_transfer_subinventory_code IN VARCHAR2,
                     p_transfer_locator_id        IN NUMBER,
                     x_transactable_qty OUT NOCOPY NUMBER,
                     x_qoh OUT NOCOPY NUMBER,
                     x_lpn_onhand OUT NOCOPY NUMBER,
                     x_return_msg OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
     l_msg_count VARCHAR2(100);
     l_msg_data VARCHAR2(1000);
     l_rqoh NUMBER;
     l_qr NUMBER;
     l_qs NUMBER;
     l_atr NUMBER;
     l_att NUMBER;
     l_lpn_context NUMBER ;
     l_return_status VARCHAR2(1);
     x_return VARCHAR2(1);
     l_is_revision_control BOOLEAN := FALSE;
     l_is_serial_control BOOLEAN := FALSE;
     l_is_lot_control BOOLEAN := FALSE ;
     l_lpn_context NUMBER;
     l_mod varchar2(20) := 'get_lpn_available';
     l_tree_mode  NUMBER := INV_Quantity_Tree_PUB.g_transaction_mode;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   x_return := 'Y';
   x_return_msg :='';

   -- Clearing the quantity cache
   inv_quantity_tree_pub.clear_quantity_cache;

   IF Upper(p_is_revision_control) = 'TRUE' THEN
      l_is_revision_control := TRUE;
    ELSE
      l_is_revision_control := FALSE;
   END IF;

   IF Upper(p_is_serial_control) = 'TRUE' THEN
      l_is_serial_control := TRUE;
    ELSE
      l_is_serial_control := FALSE;
   END IF ;

   IF Upper(p_is_lot_control) = 'TRUE' THEN
      l_is_lot_control := TRUE;
    ELSE
      l_is_lot_control := FALSE;
   END IF ;

   IF (p_inventory_item_id IS NULL) THEN
      x_return := 'N';
      fnd_message.set_name('INV', 'INV_INT_ITMCODE');
      x_return_msg := fnd_message.get;
      RETURN x_return;
   END IF ;

   IF (p_lpn_id is NOT NULL AND p_lpn_id <> 0)
    THEN
      l_tree_mode := INV_Quantity_Tree_PUB.g_transaction_mode;   --lpn reservation
      /* comment out for lpn reservation  ??? how can we get immediate lpn item quantity by calling
      quantity tree API using new tree mode ?????
      SELECT SUM(quantity)
   INTO x_lpn_onhand
   FROM wms_lpn_contents
   WHERE parent_lpn_id = p_lpn_id
   AND inventory_item_id = p_inventory_item_id
   AND organization_id = p_organization_id
   AND (p_lot_number IS NULL OR lot_number = p_lot_number)
        AND (p_revision IS NULL OR revision = p_revision);

      IF x_lpn_onhand is NULL
   THEN
    x_return := 'N';
    fnd_message.set_name('INV', 'INV_LPN_INVALID');
    x_return_msg := fnd_message.get;
    RETURN x_return;
      END IF;*/
    ELSE
      l_tree_mode := INV_Quantity_Tree_PUB.g_loose_only_mode;
    END IF;

    inv_quantity_tree_pub.query_quantities
        (p_api_version_number    =>   1.0
       , p_init_msg_lst          =>   fnd_api.g_false
       , x_return_status         =>   l_return_status
       , x_msg_count             =>   l_msg_count
       , x_msg_data              =>   l_msg_data
       , p_organization_id       =>   p_organization_id
       , p_inventory_item_id     =>   p_inventory_item_id
       , p_tree_mode             =>   l_tree_mode
       , p_is_revision_control   =>   l_is_revision_control
       , p_is_lot_control        =>   l_is_lot_control
       , p_is_serial_control     =>   l_is_serial_control
       , p_demand_source_type_id =>   p_source_type_id
       , p_revision              =>   p_revision
       , p_lot_number            =>   p_lot_number
       , p_subinventory_code     =>   p_subinventory_code
       , p_locator_id            =>   p_locator_id
       , x_qoh                   =>   x_qoh
       , x_rqoh       =>   l_rqoh
       , x_qr              =>   l_qr
       , x_qs              =>   l_qs
       , x_att                   =>   x_transactable_qty
       , x_atr             =>   l_atr
       , p_transfer_subinventory_code => p_transfer_subinventory_code
       , p_lpn_id                =>   p_lpn_id     -- lpn reservation
       , p_transfer_locator_id   =>   p_transfer_locator_id
      );


    IF (l_return_status = 'S') THEN
       IF (p_lpn_id IS NOT NULL AND p_lpn_id <> 0) THEN
           x_lpn_onhand := x_qoh;
     /*IF (l_att >= x_lpn_onhand) THEN
        x_transactable_qty := x_lpn_onhand;
        x_return := 'Y';
        x_return_msg :='SUCCESS';
        RETURN x_return;
      ELSE
        x_transactable_qty :=l_att;
        x_return := 'Y';
        x_return_msg :='SUCCESS';
        RETURN x_return;
     END IF ;*/
        ELSE
     --x_transactable_qty :=l_att;
     x_return := 'Y';
     x_return_msg :='SUCCESS';
     RETURN x_return;
       END IF ;
     ELSE
       x_return :='F';
       FND_MESSAGE.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
       FND_MESSAGE.set_token('ROUTINE','INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
       x_return_msg := fnd_message.get;
       RETURN x_return;
    END IF ;

    RETURN x_return;

END get_unpacksplit_lpn_item_qty;



FUNCTION  CHECK_SERIAL_UNPACKSPLIT( p_lpn_id     IN  NUMBER
                                   ,p_org_id     IN  NUMBER
                                   ,p_item_id    IN  NUMBER
                                   ,p_rev        IN  VARCHAR2
                                   ,p_lot        IN  VARCHAR2
                                   ,p_serial     IN  VARCHAR2)
RETURN VARCHAR2
IS
x_return              VARCHAR2(1);
l_transaction_temp_id number := 0;
l_allocated_lpn       number := 0;
l_serial_exist        number := 0;
cursor  c_mmtt(p_org_id number,
              p_item_id number,
              p_rev     varchar2) is
     select transaction_temp_id, allocated_lpn_id
     from mtl_material_transactions_temp
     where organization_id = p_org_id
     and   inventory_item_id = p_item_id
     and   nvl(revision,'@@@')  = nvl(p_rev, nvl(revision,'@@@'));
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  x_return := 'Y';
  IF (l_debug = 1) THEN
     mdebug('check_serial_unpacksplit:  lpn_id'||p_lpn_id||' orgid:'||p_org_id||' itemid:'||p_item_id||' rev:'||p_rev||' lot:'||p_lot||' serial:'||p_serial);
  END IF;
  open c_mmtt(p_org_id,p_item_id, p_rev);
  Loop
         FETCH  c_mmtt INTO  l_transaction_temp_id, l_allocated_lpn;
         EXIT WHEN  c_mmtt%NOTFOUND;

         if p_lot is null then
             begin
         select 1
         into  l_serial_exist
         from  mtl_serial_numbers_temp
         where transaction_temp_id = l_transaction_temp_id
         and p_serial between fm_serial_number and nvl(to_serial_number, fm_serial_number);
             exception
                 when others then
                    l_serial_exist := 0;
             end;
         else
             begin
         select  1
         into    l_serial_exist
         from mtl_transaction_lots_temp  mtlt,
         mtl_serial_numbers_temp   msnt
         where  mtlt.transaction_temp_id = l_transaction_temp_id
         and    mtlt.lot_number = p_lot
         and    msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
         and    p_serial between msnt.fm_serial_number and nvl(msnt.to_serial_number, msnt.fm_serial_number);
        exception
            when others then
                l_serial_exist := 0;
             end;

         end if;
         IF (l_debug = 1) THEN
            mdebug('check_serial_unpacksplit: l_transaction_temp_id:'||l_transaction_temp_id||' l_allocated_lpn:'||l_allocated_lpn);
         END IF;
         if (l_serial_exist > 0) and (l_allocated_lpn is not null) then
                x_return := 'N';
                return x_return;
         end if;
  End loop;
  close c_mmtt;
  return x_return;
END  CHECK_SERIAL_UNPACKSPLIT;



--"Returns"
PROCEDURE GET_RETURN_LOT_QUANTITIES(
         x_lot_qty  OUT NOCOPY t_genref
   ,     p_org_id   IN  NUMBER
   ,     p_lpn_id   IN  NUMBER
   ,     p_item_id  IN  NUMBER
   ,     p_revision IN  VARCHAR2
   ,     p_uom      IN  VARCHAR2)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
   --BugFix 3701796 SQL sum function changed to primary quantity
   OPEN x_lot_qty FOR
     select lot_number,
     SUM(inv_decimals_pub.get_primary_quantity(p_org_id,inventory_item_id,uom_code,Nvl(quantity,0))) primary_quantity
     from   wms_lpn_contents
     where  inventory_item_id = p_item_id
     and    parent_lpn_id = p_lpn_id
     and   ((revision = p_revision and p_revision is not null) or
       (p_revision is null and revision is null))
         and   source_name in ('RETURN TO VENDOR',
                'RETURN TO CUSTOMER',
                'RETURN TO RECEIVING')
         and   organization_id = p_org_id
         group by lot_number;

END GET_RETURN_LOT_QUANTITIES;

PROCEDURE GET_RETURN_TOTAL_QTY(
         x_tot_qty  OUT NOCOPY t_genref
   ,     p_org_id   IN  NUMBER
   ,     p_lpn_id   IN  NUMBER
   ,     p_item_id  IN  NUMBER
   ,     p_revision IN  VARCHAR2
   ,     p_uom      IN  VARCHAR2)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
      OPEN x_tot_qty FOR
        select sum(quantity)
        from   wms_lpn_contents
        where  inventory_item_id = p_item_id
        and    parent_lpn_id = p_lpn_id
        and    ((revision = p_revision and p_revision is not null) or
                (p_revision is null and revision is null))
        and    source_name in ('RETURN TO VENDOR',
                               'RETURN TO CUSTOMER',
                               'RETURN TO RECEIVING')
        and   organization_id = p_org_id;
END GET_RETURN_TOTAL_QTY;


-----------------------------------------------------------------------------
--Bug 2765395
PROCEDURE get_valid_to_locs(
    x_locators               OUT    NOCOPY t_genref
  , p_transaction_action_id  IN     NUMBER
  , p_to_organization_id     IN     NUMBER
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  ) IS
    l_org                    NUMBER;
    l_restrict_locators_code NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
   IF (l_debug = 1) THEN
       inv_log_util.trace('get_valid_to_locs Starting ', 'process_serial_subxfr');
    END IF;
    IF p_transaction_action_id IN (3, 21) THEN
      l_org  := p_to_organization_id;
      SELECT restrict_locators_code
        INTO l_restrict_locators_code
        FROM mtl_system_items
       WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = l_org;
    ELSE
      l_org                     := p_organization_id;
      l_restrict_locators_code  := p_restrict_locators_code;
    END IF;
    IF (l_debug = 1) THEN
       inv_log_util.trace('get_valid_to_locs ::Fetch Locators ', 'process_serial_subxfr');
    END IF;
    IF l_restrict_locators_code = 1 THEN --Locators restricted to predefined list
      OPEN x_locators FOR
        SELECT   a.inventory_location_id
               , a.concatenated_segments
               , a.description
            FROM mtl_item_locations_kfv a, mtl_secondary_locators b
           WHERE b.organization_id = l_org
             AND b.inventory_item_id = p_inventory_item_id
             AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
             AND b.subinventory_code = p_subinventory_code
             AND a.inventory_location_id = b.secondary_locator
             AND a.concatenated_segments LIKE (p_concatenated_segments||'%')
             AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, l_org, p_inventory_item_id, p_subinventory_code, a.inventory_location_id, NULL, NULL, 'L') = 'Y'
        ORDER BY a.concatenated_segments;
    ELSE --Locators not restricted
      OPEN x_locators FOR
        SELECT   inventory_location_id
               , concatenated_segments
               , description
            FROM mtl_item_locations_kfv
           WHERE organization_id   = l_org
             AND subinventory_code = p_subinventory_code
             AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
             AND concatenated_segments LIKE (p_concatenated_segments||'%')
             AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, l_org, p_inventory_item_id, p_subinventory_code, inventory_location_id, NULL, NULL, 'L') = 'Y'
        ORDER BY concatenated_segments;
    END IF;
  END get_valid_to_locs;


  PROCEDURE get_valid_prj_to_locs(
    x_locators               OUT    NOCOPY t_genref
  , p_transaction_action_id  IN     NUMBER
  , p_to_organization_id     IN     NUMBER
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER
  ) IS
    l_org                    NUMBER;
    l_restrict_locators_code NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
  IF (l_debug = 1) THEN
       inv_log_util.trace('get_valid_prj_to_locs ::Starting  ', 'process_serial_subxfr');
    END IF;
    IF p_transaction_action_id IN (3, 21) THEN
      l_org  := p_to_organization_id;

      SELECT restrict_locators_code
        INTO l_restrict_locators_code
        FROM mtl_system_items
       WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = l_org;
    ELSE
      l_org                     := p_organization_id;
      l_restrict_locators_code  := p_restrict_locators_code;
    END IF;
        IF (l_debug = 1) THEN
       inv_log_util.trace('get_valid_prj_to_locs ::Fetching Locators  ', 'process_serial_subxfr');
    END IF;
      IF l_restrict_locators_code= 1 THEN --Locators restricted to predefined list
      OPEN x_locators FOR
        SELECT   a.inventory_location_id
               , inv_project.get_locsegs(a.inventory_location_id,l_org)
               , NVL(a.description, -1)
            FROM mtl_item_locations a, mtl_secondary_locators b
           WHERE b.organization_id = l_org
             AND b.inventory_item_id = p_inventory_item_id
             AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
             AND b.subinventory_code = p_subinventory_code
             AND a.inventory_location_id = b.secondary_locator
             AND inv_project.get_locsegs(a.inventory_location_id, l_org) LIKE (p_concatenated_segments||'%')
             AND NVL(a.project_id, -1) = NVL(p_project_id, -1)
             AND NVL(a.task_id, -1) = NVL(p_task_id, -1)
             AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, l_org, p_inventory_item_id, p_subinventory_code, a.inventory_location_id, NULL, NULL, 'L') = 'Y'
        ORDER BY 2;
    ELSE --Locators not restricted
      OPEN x_locators FOR
        SELECT   inventory_location_id
               , inv_project.get_locsegs(inventory_location_id, l_org)
               , description
            FROM mtl_item_locations
           WHERE organization_id = l_org
             AND subinventory_code = p_subinventory_code
             AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
             AND inv_project.get_locsegs(inventory_location_id, l_org) LIKE (p_concatenated_segments||'%')
             AND NVL(project_id, -1) = NVL(p_project_id, -1)
             AND NVL(task_id, -1) = NVL(p_task_id, -1)
             AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, l_org, p_inventory_item_id, p_subinventory_code, inventory_location_id, NULL, NULL, 'L') = 'Y'
        ORDER BY 2;
    END IF;
  END get_valid_prj_to_locs;
-------------------------------------------------------------------------------



--"Returns"

-- This procedure validates the serial number, to sub and to loc for a
-- serial triggered sub transfer. It also updates the quantity tree. It
-- sets the GROUP mark ID of the serial number to a non null value. It also
-- inserts into MMTT, MTLT and MSNT tables for the sub transfer transaction
PROCEDURE process_serial_subxfr(p_organization_id       IN  NUMBER,
            p_serial_number         IN  VARCHAR2,
            p_inventory_item_id     IN  NUMBER,
            p_inventory_item        IN  VARCHAR2,
            --I Development  Bug 2634570
            p_project_id      IN  NUMBER,
            p_task_id      IN  NUMBER,

            p_revision              IN  VARCHAR2,
            p_primary_uom_code      IN  VARCHAR2,
            p_subinventory_code     IN  VARCHAR2,
            p_locator_id            IN  NUMBER,
            p_locator               IN  VARCHAR2,
            p_to_subinventory_code  IN  VARCHAR2,
            p_to_locator            IN  VARCHAR2,
            p_to_locator_id         IN  NUMBER,
            p_reason_id             IN  NUMBER,
            p_lot_number            IN  VARCHAR2,
            p_wms_installed         IN  VARCHAR2,
            p_transaction_action_id IN  NUMBER,
            p_transaction_type_id   IN  VARCHAR2,
            p_source_type_id        IN  NUMBER,
            p_user_id               IN  NUMBER,
            p_transaction_header_id IN  NUMBER,
            p_restrict_sub_code     IN  NUMBER,
            p_restrict_loc_code     IN  NUMBER,
            p_from_sub_asset_inv    IN  NUMBER,
            p_serial_control_code   IN  NUMBER,
            p_process_serial        IN  VARCHAR2,
            x_serial_processed      OUT NOCOPY VARCHAR2,
            x_transaction_header_id OUT NOCOPY NUMBER,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_return_msg            OUT NOCOPY VARCHAR2)
  IS
     l_is_revision_control BOOLEAN;
     l_is_lot_control      BOOLEAN;

     l_tree_mode           NUMBER := inv_quantity_tree_pub.g_transaction_mode;
     l_quantity_type       NUMBER := inv_quantity_tree_pvt.g_qoh;
     l_onhand_source       NUMBER := inv_quantity_tree_pvt.g_all_subs;
     l_qoh                 NUMBER;
     l_rqoh                NUMBER;
     l_qr                  NUMBER;
     l_qs                  NUMBER;
     l_att                 NUMBER;
     l_atr                 NUMBER;

     l_transaction_temp_id          NUMBER;
     l_serial_transaction_temp_id   NUMBER;
     l_proc_msg              VARCHAR2(240);
     l_return_code           NUMBER;

     l_status_allowed        VARCHAR2(1) := 'N';
     l_msg_count             NUMBER;
     l_msg_data              VARCHAR2(240);
     /** R12 Enhanced reservations project **/
     l_reservation_id NUMBER;
     l_group_mark_id NUMBER;
     /** End - R12 Enhanced reservations project **/

     TYPE t_refcur IS ref CURSOR;
     l_ref_cur               t_refcur;

     l_to_subinventory_code  VARCHAR2(10);
     l_locator_type          NUMBER;
     l_to_locator_id         NUMBER;
     l_to_locator            mtl_item_locations_kfv.concatenated_segments%TYPE;
     l_description           mtl_secondary_inventories.description%TYPE;
     l_asset_inventory       mtl_secondary_inventories.asset_inventory%TYPE;
     l_lpn_controlled_flag   mtl_secondary_inventories.lpn_controlled_flag%TYPE;
     l_enable_locator_alias  mtl_secondary_inventories.enable_locator_alias%TYPE;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_serial_processed := 'NO'; -- No processing has been done

   IF p_subinventory_code = p_to_subinventory_code
     AND Nvl(p_locator_id, -1) = Nvl(p_to_locator_id, -1) THEN
      fnd_message.set_name('INV', 'INV_NOT_SAME_LOC');

      IF p_locator_id IS NOT NULL THEN
    x_serial_processed := 'TOLOC';
       ELSE
    x_serial_processed := 'TOSUB';
      END IF;

      x_return_msg := fnd_message.get;
      RETURN;
   END IF;

   -- Check if the serial number is available to be transacted for this transaction
   l_status_allowed := inv_material_status_grp.is_status_applicable
                                   (p_wms_installed         => p_wms_installed,
                p_trx_status_enabled    => NULL,
                p_trx_type_id           => p_transaction_type_id,
                p_lot_status_enabled    => NULL,
                p_serial_status_enabled => NULL,
                p_organization_id       => p_organization_id,
                p_inventory_item_id     => p_inventory_item_id,
                p_sub_code              => p_subinventory_code,
                p_locator_id            => p_locator_id,
                p_lot_number            => p_lot_number,
                p_serial_number         => p_serial_number,
                p_object_type           => 'A');

   IF (l_debug = 1) THEN
      inv_log_util.trace('Status Allowed: ' || l_status_allowed, 'process_serial_subxfr');
   END IF;
   IF l_status_allowed <> 'Y' THEN
      fnd_message.set_name('INV', 'INV_TRX_SER_NA_DUE_MS');
      fnd_message.set_token('TOKEN1', p_serial_number);
      fnd_message.set_token('TOKEN2', p_inventory_item);
      x_serial_processed := 'SERIAL';
      x_return_msg := fnd_message.get;
      RETURN;
   END IF;

   inv_ui_item_sub_loc_lovs.get_to_sub(x_to_sub                        => l_ref_cur,
                   p_organization_id               => p_organization_id,
                   p_inventory_item_id             => p_inventory_item_id,
                   p_from_Secondary_Name           => p_subinventory_code,
                   p_restrict_subinventories_code  => p_restrict_sub_code,
                   p_secondary_inventory_name      => p_to_subinventory_code,
                   p_from_sub_asset_inventory      => p_from_sub_asset_inv,
                   p_transaction_action_id         => p_transaction_action_id,
                   p_To_Organization_Id            => p_organization_id,
                   p_serial_number_control_code    => p_serial_control_code,
                   p_transaction_type_id           => p_transaction_type_id,
                   p_wms_installed                 => p_wms_installed);

   LOOP
      FETCH l_ref_cur INTO
   l_to_subinventory_code,
   l_locator_type,
   l_description,
   l_asset_inventory,
   l_lpn_controlled_flag,
   l_enable_locator_alias;
      EXIT WHEN l_ref_cur%notfound OR l_to_subinventory_code = p_to_subinventory_code;
   END LOOP;

   CLOSE l_ref_cur;

   IF (l_debug = 1) THEN
      inv_log_util.trace('l_to_subinventory_code: ' || l_to_subinventory_code, 'process_serial_subxfr');
   END IF;

   IF p_to_subinventory_code <> Nvl(l_to_subinventory_code, '@@@') THEN
      fnd_message.set_name('INV', 'INV_INVALID_SUB');
      x_serial_processed := 'TOSUB';
      x_return_msg := fnd_message.get;
      RETURN;
   END IF;


   IF p_to_locator_id IS NOT NULL THEN
   --I Development Bug 2634570
       IF  p_project_id IS NOT NULL  THEN
      -- inv_ui_item_sub_loc_lovs.GET_VALID_PRJ_TO_LOCS(x_Locators  => l_ref_cur,
      --Bug 2765395
       GET_VALID_PRJ_TO_LOCS(x_Locators  => l_ref_cur,
             p_transaction_action_id  => p_transaction_action_id,
             p_to_organization_id     => p_organization_id,
             p_organization_id        => p_organization_id,
             p_subinventory_code      => p_to_subinventory_code,
             p_restrict_locators_code => p_restrict_loc_code,
             p_inventory_item_id      => p_inventory_item_id,
             p_concatenated_segments  => p_to_locator,
             p_transaction_type_id    => p_transaction_type_id,
             p_wms_installed          => p_wms_installed,
             p_project_id       => p_project_id,
             p_task_id       => p_task_id      );
      ELSE
         --inv_ui_item_sub_loc_lovs.get_valid_to_locs(x_Locators  => l_ref_cur,
         --Bug 2765395
         GET_VALID_TO_LOCS(x_Locators => l_ref_cur,
                   p_transaction_action_id  => p_transaction_action_id,
                   p_to_organization_id     => p_organization_id,
                   p_organization_id        => p_organization_id,
                   p_subinventory_code      => p_to_subinventory_code,
                   p_restrict_locators_code => p_restrict_loc_code,
                   p_inventory_item_id      => p_inventory_item_id,
                   p_concatenated_segments  => p_to_locator,
                   p_transaction_type_id    => p_transaction_type_id,
                   p_wms_installed          => p_wms_installed);


      LOOP
    FETCH l_ref_cur INTO
      l_to_locator_id,
      l_to_locator,
      l_description;
    EXIT WHEN l_ref_cur%notfound OR l_to_locator_id = p_to_locator_id;
      END LOOP;

      CLOSE l_ref_cur;

      IF (l_debug = 1) THEN
         inv_log_util.trace('p_to_locator: ' || p_to_locator, 'process_serial_subxfr');
         inv_log_util.trace('p_to_locator_id: ' || p_to_locator_id, 'process_serial_subxfr');
         inv_log_util.trace('l_to_locator: ' || l_to_locator, 'process_serial_subxfr');
         inv_log_util.trace('l_to_locator_id: ' || l_to_locator_id, 'process_serial_subxfr');
      END IF;

      IF p_to_locator_id <> Nvl(l_to_locator_id, -1) THEN
    fnd_message.set_name('INV', 'INV_INT_LOCCODE');
    x_serial_processed := 'TOLOC';
    x_return_msg := fnd_message.get;
    RETURN;
      END IF;
   END IF;
   -- End of the newly added loop I Development Bug 2634570
   END IF;

   IF  p_process_serial = 'Y' THEN
      IF p_lot_number IS NOT NULL THEN
    l_is_lot_control := TRUE;
       ELSE
    l_is_lot_control := FALSE;
      END IF;

      IF p_revision IS NOT NULL THEN
    l_is_revision_control := TRUE;
       ELSE
    l_is_revision_control := FALSE;
      END IF;

      -- Query the quantity tree for available to transact quantity
      inv_quantity_tree_pub.query_quantities
   (p_api_version_number    =>   1.0,
    p_init_msg_lst          =>   fnd_api.g_false,
    x_return_status         =>   x_return_status,
    x_msg_count             =>   l_msg_count,
    x_msg_data              =>   l_msg_data,
    p_organization_id       =>   p_organization_id,
    p_inventory_item_id     =>   p_inventory_item_id,
    p_tree_mode             =>   l_tree_mode,
    p_is_revision_control   =>   l_is_revision_control,
    p_is_lot_control        =>   l_is_lot_control,
    p_is_serial_control     =>   TRUE,
    p_demand_source_type_id =>   p_source_type_id,
    p_revision              =>   p_revision,
    p_lot_number            =>   p_lot_number,
    p_subinventory_code     =>   p_subinventory_code,
    p_locator_id            =>   p_locator_id,
    p_transfer_subinventory_code => p_to_subinventory_code,
    x_qoh                   =>   l_qoh,
    x_rqoh         =>   l_rqoh,
    x_qr             =>   l_qr,
    x_qs             =>   l_qs,
    x_att               =>   l_att,
    x_atr               =>   l_atr);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
    FND_MESSAGE.set_name('INV', 'INV_ERR_CREATETREE');
    FND_MESSAGE.set_token('ROUTINE','INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
    x_return_msg := fnd_message.get;
    RETURN;
      END IF;
      IF (l_debug = 1) THEN
         inv_log_util.trace('ATT: ' || l_att, 'process_serial_subxfr');
      END IF;

      /** R12 Enhanced reservations project **/
      BEGIN
    SELECT reservation_id, group_mark_id INTO l_reservation_id,
      l_group_mark_id FROM mtl_serial_numbers WHERE
      serial_number = p_serial_number AND inventory_item_id = p_inventory_item_id;
      EXCEPTION
    WHEN no_data_found THEN
       IF (l_debug = 1) THEN
          inv_log_util.trace('Serial is not reserved', 'process_serial_subxfr');
       END IF;
      END;
      /** end - R12 Enhanced reservations project **/

      IF l_reservation_id IS NOT NULL AND l_reservation_id > 0 THEN
    l_att := l_att + 1; -- allow reserved serials to be processed.
      END IF;

      IF l_att > 0 THEN
    -- Update the quantity tree so that the serial transaction is
    -- reflected in the available quantity
    inv_quantity_tree_pub.update_quantities
      (p_api_version_number      => 1.0,
       p_init_msg_lst            => fnd_api.g_false,
       x_return_status           => x_return_status,
       x_msg_count               => l_msg_count,
       x_msg_data                => l_msg_data,
       p_organization_id           => p_organization_id,
       p_inventory_item_id         => p_inventory_item_id,
       p_tree_mode                 => l_tree_mode,
       p_is_revision_control       => l_is_revision_control,
       p_is_lot_control            => l_is_lot_control,
       p_is_serial_control         => TRUE,
       p_demand_source_type_id     => p_source_type_id,
       p_revision                => p_revision,
       p_lot_number              => p_lot_number,
       p_subinventory_code         => p_subinventory_code,
       p_locator_id              => p_locator_id,
       p_primary_quantity        => -1,
       p_quantity_type           => l_quantity_type,
       p_onhand_source     => l_onhand_source,
       x_qoh                     => l_qoh,
       x_rqoh                    => l_rqoh,
       x_qr                      => l_qr,
       x_qs                      => l_qs,
       x_att                     => l_att,
       x_atr                     => l_atr);

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
       FND_MESSAGE.set_name('INV', 'INV_ERR_CREATETREE');
       FND_MESSAGE.set_token('ROUTINE','INV_QUANTITY_TREE_PUB.UPDATE_QUANTITIES');
       x_return_msg := fnd_message.get;
       RETURN;
    END IF;
    IF (l_debug = 1) THEN
       inv_log_util.trace('ATT in source: ' || l_att, 'process_serial_subxfr');
    END IF;

    inv_quantity_tree_pub.update_quantities
      (p_api_version_number      => 1.0,
       p_init_msg_lst            => fnd_api.g_false,
       x_return_status           => x_return_status,
       x_msg_count               => l_msg_count,
       x_msg_data                => l_msg_data,
       p_organization_id           => p_organization_id,
       p_inventory_item_id         => p_inventory_item_id,
       p_tree_mode                 => l_tree_mode,
       p_is_revision_control       => l_is_revision_control,
       p_is_lot_control            => l_is_lot_control,
       p_is_serial_control         => TRUE,
       p_demand_source_type_id     => p_source_type_id,
       p_revision                => p_revision,
       p_lot_number              => p_lot_number,
       p_subinventory_code         => p_to_subinventory_code,
       p_locator_id              => p_to_locator_id,
       p_primary_quantity        => 1,
       p_quantity_type           => l_quantity_type,
       p_onhand_source     => l_onhand_source,
       x_qoh                     => l_qoh,
       x_rqoh                    => l_rqoh,
       x_qr                      => l_qr,
       x_qs                      => l_qs,
       x_att                     => l_att,
       x_atr                     => l_atr);

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
       FND_MESSAGE.set_name('INV', 'INV_ERR_CREATETREE');
       FND_MESSAGE.set_token('ROUTINE','INV_QUANTITY_TREE_PUB.UPDATE_QUANTITIES');
       x_return_msg := fnd_message.get;
       RETURN;
    END IF;

    IF (l_debug = 1) THEN
       inv_log_util.trace('ATT in dest: ' || l_att, 'process_serial_subxfr');
    END IF;

    -- Update the group mark ID on the serial record so that it is not
    -- available in the LOV any more
    /** R12 Enhanced reservation project **/
    -- update only if is not reserved. Otherwise it would have been
    -- marked already
    IF l_group_mark_id IS NULL OR l_group_mark_id < 0 then
       update mtl_serial_numbers
         set group_mark_id = 1
         where inventory_item_id = p_inventory_item_id
         and serial_number = p_serial_number;
    END IF;
    /** End - R12 Enhanced reservation project **/

    IF (l_debug = 1) THEN
       inv_log_util.trace('Updated Serial ' || p_serial_number || ' Item ID ' || p_inventory_item_id, 'process_serial_subxfr');
    END IF;

    IF p_transaction_header_id IS NULL THEN
       SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
         INTO x_transaction_header_id
         FROM dual;
     ELSE
       x_transaction_header_id := p_transaction_header_id;
    END IF;

    IF (l_debug = 1) THEN
       inv_log_util.trace('Calling Insert MMTT', 'process_serial_subxfr');
    END IF;

    -- Insert record into MMTT
      --I Development Bug 2634570
      -- Added two paramters to call the procedure insert_line_trx
    BEGIN
       l_return_code :=
         inv_trx_util_pub.insert_line_trx
         (p_trx_hdr_id       => x_transaction_header_id,
          p_item_id          => p_inventory_item_id,
           p_project_id   => p_project_id,
          p_task_id    => p_task_id,
          p_revision         => p_revision,
          p_org_id           => p_organization_id,
          p_trx_action_id    => p_transaction_action_id,
          p_subinv_code      => p_subinventory_code,
          p_tosubinv_code    => p_to_subinventory_code,
          p_locator_id       => p_locator_id,
          p_tolocator_id     => p_to_locator_id,
          p_xfr_org_id       => p_organization_id,
          p_trx_type_id      => p_transaction_type_id,
          p_trx_src_type_id  => p_source_type_id,
          p_trx_qty          => 1,
          p_pri_qty          => 1,
          p_uom              => p_primary_uom_code,
          p_date             => Sysdate,
          p_reason_id        => p_reason_id,
          p_user_id          => p_user_id,
          x_trx_tmp_id       => l_transaction_temp_id,
          x_proc_msg         => l_proc_msg);
    EXCEPTION
       WHEN OTHERS THEN
          IF (l_debug = 1) THEN
             inv_log_util.trace('SQL Error while inserting MTTT: ' || Sqlerrm, 'process_serial_subxfr');
          END IF;
    END;


    IF l_return_code = 0 THEN
       IF (l_debug = 1) THEN
          inv_log_util.trace('Inserted MMTT record', 'process_serial_subxfr');
          inv_log_util.trace('Temp ID = ' || l_transaction_temp_id, 'process_serial_subxfr');
          inv_log_util.trace('Header ID = ' || x_transaction_header_id, 'process_serial_subxfr');
       END IF;
     ELSE
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       IF (l_debug = 1) THEN
          inv_log_util.trace(l_proc_msg, 'process_serial_subxfr');
       END IF;
       RETURN;
    END IF;

    -- Insert record into MTLT
    IF p_lot_number IS NOT NULL THEN
     l_return_code :=
       inv_trx_util_pub.insert_lot_trx
       (p_trx_tmp_id          => l_transaction_temp_id,
        p_user_id             => p_user_id,
        p_lot_number          => p_lot_number,
        p_trx_qty             => 1,
        p_pri_qty             => 1,
        x_ser_trx_id          => l_serial_transaction_temp_id,
        x_proc_msg            => l_proc_msg);

   IF l_return_code = 0 THEN
            l_transaction_temp_id := l_serial_transaction_temp_id;
       IF (l_debug = 1) THEN
          inv_log_util.trace('Inserted MTLT record', 'process_serial_subxfr');
          inv_log_util.trace('Serial Temp ID = ' || l_serial_transaction_temp_id, 'process_serial_subxfr');
          inv_log_util.trace('Serial Temp ID = ' || l_transaction_temp_id, 'process_serial_subxfr');
       END IF;
     ELSE
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       IF (l_debug = 1) THEN
          inv_log_util.trace(l_proc_msg, 'process_serial_subxfr');
       END IF;
       RETURN;
    END IF;
--Bug 2779646
     END IF;

    -- Insert record into MSNT
    l_return_code :=
      inv_trx_util_pub.insert_ser_trx
      (p_trx_tmp_id          => l_transaction_temp_id,
       p_user_id             => p_user_id,
       p_fm_ser_num          => p_serial_number,
       p_to_ser_num          => p_serial_number,
       x_proc_msg            => l_proc_msg);

    IF l_return_code = 0 THEN
       IF (l_debug = 1) THEN
          inv_log_util.trace('Inserted MSNT record', 'process_serial_subxfr');
          inv_log_util.trace('Serial Temp ID = ' || l_transaction_temp_id, 'process_serial_subxfr');
       END IF;
     ELSE
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       IF (l_debug = 1) THEN
          inv_log_util.trace(l_proc_msg, 'process_serial_subxfr');
       END IF;
       RETURN;
    END IF;

    x_serial_processed := 'YES';

       ELSE -- att < 0
    FND_MESSAGE.set_name('INV', 'INV_SERIAL_EXCEED_AVAILABLE');
    x_return_msg := fnd_message.get;
    RETURN;
      END IF;

   END IF;
END process_serial_subxfr;





PROCEDURE check_loose_and_packed_qty
  (p_api_version_number      IN   NUMBER
   , p_init_msg_lst          IN   VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status         OUT  NOCOPY VARCHAR2
   , x_msg_count             OUT  NOCOPY NUMBER
   , x_msg_data              OUT  NOCOPY VARCHAR2
   , p_organization_id       IN   NUMBER
   , p_inventory_item_id     IN   NUMBER
   , p_is_revision_control   IN   VARCHAR2
   , p_is_lot_control        IN   VARCHAR2
   , p_is_serial_control     IN   VARCHAR2
   , p_revision              IN   VARCHAR2
   , p_lot_number            IN   VARCHAR2
   , p_transaction_quantity  IN   NUMBER
   , p_transaction_uom       IN   VARCHAR2
   , p_subinventory_code     IN   VARCHAR2
   , p_locator_id            IN   NUMBER
   , p_transaction_temp_id   IN   NUMBER
   , p_ok_to_process         OUT  NOCOPY VARCHAR2
   , p_transfer_subinventory IN   VARCHAR2
   )
  IS
     l_att         NUMBER;
     l_qoh         NUMBER;
     l_rqoh        NUMBER;
     l_qr          NUMBER;
     l_qs          NUMBER;
     l_atr         NUMBER;
     l_lot_exp_dt  DATE;
     l_moq         NUMBER;
     l_avail_qty   NUMBER;
     l_uom_rate    NUMBER;
     l_txn_qty     NUMBER;

     l_ok_to_process  VARCHAR2(5);

     l_is_revision_control  BOOLEAN := FALSE;
     l_is_lot_control       BOOLEAN := FALSE;
     l_is_serial_control    BOOLEAN := FALSE;

     l_cost_group_id      mtl_material_transactions_temp.cost_group_id%type;
     l_primary_uom_code   mtl_material_transactions_temp.item_primary_uom_code%type;
     l_inv_rcpt_code      mtl_parameters.negative_inv_receipt_code%type;

     l_api_version_number       CONSTANT NUMBER       := 1.0;
     l_api_name                 CONSTANT VARCHAR2(30) := 'Check_Looose_and_packed_Qty';
     l_return_status            VARCHAR2(1)           := fnd_api.g_ret_sts_success;

     l_transaction_source_type_id NUMBER;
     l_new_qoh NUMBER;
     l_new_att NUMBER;
     l_new_pqoh NUMBER;
     l_new_tqoh NUMBER;
     l_new_atpp1 NUMBER;
     l_new_qoh1 NUMBER;

     l_suggested_sub_code VARCHAR2(30);
     l_suggested_loc_id   NUMBER;

     CURSOR c_org IS
     SELECT negative_inv_receipt_code
       FROM mtl_parameters
      WHERE organization_id = p_organization_id;

     CURSOR c_lot_exp IS
     SELECT expiration_date
       FROM mtl_lot_numbers
      WHERE inventory_item_id = p_inventory_item_id
   AND organization_id   = p_organization_id
   AND lot_number        = p_lot_number;

     CURSOR c_mmtt IS
     SELECT cost_group_id,transaction_source_type_id, subinventory_code, locator_id
       FROM mtl_material_transactions_temp
      WHERE transaction_temp_id = p_transaction_temp_id;

     CURSOR c_item IS
     SELECT primary_uom_code
       FROM mtl_system_items
      WHERE inventory_item_id = p_inventory_item_id
   AND organization_id   = p_organization_id;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
      mdebug ('Start check_loose_and_packed_qty.');
   END IF;

   inv_quantity_tree_pub.clear_quantity_cache;

   -- Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   IF (l_debug = 1) THEN
      mdebug ('Done checking if compatible api call.');
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   p_ok_to_process := 'false';

   --
   -- Initialize variables
   --
   IF p_is_revision_control = 'true' THEN
      l_is_revision_control := TRUE;
   END IF;

   IF p_is_serial_control = 'true' THEN
      l_is_serial_control := TRUE;
   END IF;
   IF (l_debug = 1) THEN
      mdebug ('Done initializing variables.');
   END IF;

   --
   -- Find the lot expiration date if
   -- the item is lot controlled.
   --
   IF p_is_lot_control = 'true' THEN
      l_is_lot_control := TRUE;
      OPEN c_lot_exp;
      FETCH c_lot_exp INTO l_lot_exp_dt;
      CLOSE c_lot_exp;
   END IF;

   -- Find the cost group id being transacted
   OPEN c_mmtt;
   FETCH c_mmtt
     INTO
     l_cost_group_id, l_transaction_source_type_id,
     l_suggested_sub_code, l_suggested_loc_id;
   CLOSE c_mmtt;
   IF (l_debug = 1) THEN
      mdebug ('Cost group id from mmtt: '||l_cost_group_id);
   END IF;

   -- Find the primary UOM code for the item
   OPEN c_item;
   FETCH c_item INTO l_primary_uom_code;
   CLOSE c_item;
   IF (l_debug = 1) THEN
      mdebug ('Primary UOM for this item: '||l_primary_uom_code);
   END IF;

   -- Find if -ve inventory balances are allowed for this org
   OPEN c_org;
   FETCH c_org INTO l_inv_rcpt_code;
   CLOSE c_org;
   IF (l_debug = 1) THEN
      mdebug ('-ve inv rcpt code is: '||l_inv_rcpt_code);
   END IF;

   -- Translate picked qty/uom into primary uom qty
   inv_convert.inv_um_conversion(
              from_unit  => p_transaction_uom
            , to_unit    => l_primary_uom_code
            , item_id    => p_inventory_item_id
            , uom_rate   => l_uom_rate
            );
   l_txn_qty := p_transaction_quantity * l_uom_rate;
   IF (l_debug = 1) THEN
      mdebug ('Transaction qty in primary units: '||l_txn_qty);
   END IF;

   inv_txn_validations.get_available_quantity
     (x_return_status       => l_return_status,
      p_tree_mode           => INV_Quantity_Tree_PUB.g_transaction_mode,
      p_organization_id     => p_organization_id,
      p_inventory_item_id   => p_inventory_item_id,
      p_is_revision_control => p_is_revision_control,
      p_is_lot_control      => p_is_lot_control,
      p_is_serial_control   => p_is_serial_control ,
      p_revision            => p_revision,
      p_lot_number          => p_lot_number ,
      p_lot_expiration_date => l_lot_exp_dt,
      p_subinventory_code   => p_subinventory_code,
      p_locator_id          => p_locator_id,
      p_source_type_id      => l_transaction_source_type_id,
      x_qoh                 => l_new_qoh,
      x_att                 => l_new_att,
      x_pqoh                => l_new_pqoh,
      x_tqoh                => l_new_tqoh,
      x_atpp1               => l_new_atpp1,
      x_qoh1                => l_new_qoh1,
      p_cost_group_id       => l_cost_group_id,
      p_transfer_subinventory => p_transfer_subinventory);


   IF (l_debug = 1) THEN
      mdebug(l_new_qoh || '   ' || l_new_att || '   ' || l_new_pqoh || '   ' || l_new_tqoh || '   ' || l_new_atpp1 || '   ' || l_new_qoh1);
   END IF;

   -- If org allows negative inventory balances
   --
   IF l_inv_rcpt_code = 1 THEN

      IF (l_debug = 1) THEN
         mdebug('org allows negative inventory balances');
      END IF;

      p_ok_to_process := 'true';

      IF (l_new_att < l_txn_qty) THEN

    IF l_suggested_sub_code   <> p_subinventory_code OR
      l_suggested_loc_id     <> p_locator_id THEN

       IF (l_debug = 1) THEN
          mdebug('suggested sub/loc are different from the actual sub/loc');
       END IF;

       IF (least(nvl(l_new_att, 0), nvl(l_new_tqoh,0)) >= l_txn_qty) THEN

          p_ok_to_process := 'true';

        ELSE
          /*
          Bug #2075166.
       When negative inventory is allowed for the organization
       Change the ok_to_process flag to warning in order that
       a warning message id displayed instead of error.
       */
       p_ok_to_process := 'warning';
          IF (l_debug = 1) THEN
             mdebug('Driving inventory negative. Throw a warning');
          END IF;

       END IF;

     ELSE

       IF (l_debug = 1) THEN
          mdebug('suggested sub/loc are same as the actual sub/loc');
       END IF;

       IF (least((nvl(l_new_att,0) + l_txn_qty), nvl(l_new_tqoh,0)) >= l_txn_qty) THEN

          p_ok_to_process := 'true';

        ELSE
          /*
          Bug #2075166.
       When negative inventory is allowed for the organization
       Change the ok_to_process flag to warning in order that
       a warning message id displayed instead of error.
       */
       p_ok_to_process := 'warning';
          IF (l_debug = 1) THEN
             mdebug('Driving inventory negative. Throw a warning');
          END IF;
          --p_ok_to_process := 'false';
          --mdebug('Cannot drive inventory negative when reservations exist');
       END IF;

    END IF;

      END IF;

      x_return_status := l_return_status; /* Success */
      return;
   END IF;

   --
   -- Org does not allow negative inventory balances
   -- so continue.
   IF (l_debug = 1) THEN
      mdebug('org does not allow negative inventory balances');
   END IF;

   IF (l_new_att < l_txn_qty) THEN

      IF (l_debug = 1) THEN
         mdebug('l_new_att < l_txn_qty');
      END IF;

      IF l_suggested_sub_code   <> p_subinventory_code OR
   l_suggested_loc_id     <> p_locator_id THEN

    IF (l_debug = 1) THEN
       mdebug('suggested sub/loc are different from the actual sub/loc');
    END IF;

    IF (least(nvl(l_new_att, 0), nvl(l_new_tqoh,0)) >= l_txn_qty) THEN

       p_ok_to_process := 'true';

     ELSE

       p_ok_to_process := 'false';

    END IF;

       ELSE

    IF (l_debug = 1) THEN
       mdebug('suggested sub/loc are the same as the actual sub/loc');
    END IF;

    IF (least((nvl(l_new_att,0) + l_txn_qty), nvl(l_new_tqoh,0)) >= l_txn_qty) THEN

       p_ok_to_process := 'true';

     ELSE

       p_ok_to_process := 'false';

    END IF;

      END IF;

    ELSE

      p_ok_to_process := 'true';
   END IF;

END check_loose_and_packed_qty;

/* Bug 4194323 Added Overloaded Procedure to get available quantity
    when Demand Information is provided as part of WIP Enhancement 4163405  */
PROCEDURE GET_AVBL_TO_TRANSACT_QTY(
             x_return_status OUT NOCOPY VARCHAR2,
             p_organization_id IN NUMBER,
             p_inventory_item_id IN NUMBER,
                                 p_is_revision_control IN VARCHAR2,
                                 p_is_lot_control IN VARCHAR2,
                                 p_is_serial_control  IN VARCHAR2,
             p_demand_source_type_id IN NUMBER,
             p_demand_source_header_id IN NUMBER,
             p_demand_source_line_id IN NUMBER,
             p_revision IN VARCHAR2,
             p_lot_number IN VARCHAR2,
             p_lot_expiration_date IN  DATE,
             p_subinventory_code IN  VARCHAR2,
             p_locator_id IN NUMBER,
             x_att  OUT NOCOPY NUMBER
             )
      IS
     l_msg_count VARCHAR2(100);
     l_msg_data VARCHAR2(1000);
     l_qoh NUMBER := 0 ;
     l_rqoh NUMBER := 0 ;
     l_qr NUMBER := 0 ;
     l_qs NUMBER := 0 ;
     l_att NUMBER := 0 ;
     l_atr NUMBER := 0 ;
     l_is_revision_control BOOLEAN := FALSE;
     l_is_lot_control BOOLEAN := FALSE;
     l_is_serial_control BOOLEAN := FALSE;
     l_return_status  VARCHAR2(1) :=  fnd_api.g_ret_sts_success;
     p_init_msg_lst VARCHAR2(30);
     l_api_name   CONSTANT VARCHAR2(30) := 'Get_Avbl_To_Transact_Qty';
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 BEGIN
  IF (l_debug = 1) THEN
      mdebug ('Inside get_avbl_to_transact_qty');
  END IF;

-- checking for all the item controls
  IF p_is_revision_control = 'true' THEN
      l_is_revision_control := TRUE;
   END IF;

   IF p_is_lot_control = 'true' THEN
      l_is_lot_control := TRUE;
   END IF;

   IF p_is_serial_control = 'true' THEN
      l_is_serial_control := TRUE;
   END IF;

    --  Initialize message list.
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   --  Clearing any cache if existent
   inv_quantity_tree_grp.clear_quantity_cache ;

-- this call will provide reserved quantity for all but the demand source specified
   inv_quantity_tree_pub.query_quantities
     (  p_api_version_number     =>   1.0
      , p_init_msg_lst         =>   fnd_api.g_false
      , x_return_status        =>   l_return_status
      , x_msg_count            =>   l_msg_count
      , x_msg_data             =>   l_msg_data
      , p_organization_id      =>   p_organization_id
      , p_inventory_item_id    =>   p_inventory_item_id
      , p_tree_mode            =>   inv_quantity_tree_pub.g_transaction_mode
      , p_is_revision_control  =>   l_is_revision_control
      , p_is_lot_control       =>   l_is_lot_control
      , p_is_serial_control    =>   l_is_serial_control
      , p_demand_source_type_id =>  p_demand_source_type_id
      , p_demand_source_header_id => p_demand_source_header_id
      , p_demand_source_line_id =>p_demand_source_line_id
      , p_revision             =>  p_revision
      , p_lot_number           =>   p_lot_number
      , p_lot_expiration_date  =>   p_lot_expiration_date
      , p_subinventory_code    =>   p_subinventory_code
      , p_locator_id           =>    p_locator_id
      , x_qoh               =>   l_qoh
      , x_rqoh      =>   l_rqoh
      , x_qr        =>   l_qr
      , x_qs                 =>   l_qs
      , x_att                 =>   l_att
      , x_atr                 =>   l_atr
        );

  IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

  x_att := l_att ;

  IF (l_debug = 1) THEN
   mdebug ('Quantity Available for Demand Source Header : ' || p_demand_source_header_id ||
          ' Demand Source Line : '|| p_demand_source_line_id || ' is : '|| x_att );
   mdebug('@'||l_msg_data||'@');
  END IF;

  x_return_status := l_return_status;

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => l_msg_count
           , p_data  => l_msg_data
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => l_msg_count
           , p_data   => l_msg_data
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN

           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => l_msg_count
           , p_data   => l_msg_data
            );

END GET_AVBL_TO_TRANSACT_QTY  ;

--Bug#4446248.Added the following function to check any pending transaction
--for the LPN.
FUNCTION check_lpn_pending_txns( p_lpn_id IN NUMBER,
                  p_org_id IN NUMBER,
                  x_return_msg OUT NOCOPY VARCHAR2)
 RETURN VARCHAR2
  IS
      l_lpn_id   NUMBER;
      l_count      NUMBER :=0 ;
      x_return   VARCHAR2(1)  := 'Y';

      CURSOR  c_lpn_content IS
        select lpn_id
        from   wms_license_plate_numbers
        where  outermost_lpn_id = p_lpn_id
        and    organization_id = p_org_id;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
     OPEN c_lpn_content;
     LOOP
        FETCH  c_lpn_content INTO  l_lpn_id;
        EXIT WHEN  c_lpn_content%NOTFOUND;

        select count(1)
        into  l_count
        from mtl_material_transactions_temp mmtt
        where (mmtt.lpn_id = l_lpn_id or mmtt.content_lpn_id = l_lpn_id)
        and mmtt.organization_id = p_org_id;

        if l_count > 0  then
            CLOSE  c_lpn_content;
            IF (l_debug = 1) THEN
               mdebug ('lpn '||l_lpn_id||' has some pending transactions to be completed.');
            END IF;
            x_return := 'N';
            fnd_message.set_name('INV', 'INV_PENDING_TXNS_EXISTS');
            x_return_msg := fnd_message.get;
            RETURN  x_return;
        end if;
     END LOOP;
     CLOSE  c_lpn_content;
     x_return_msg := 'SUCCESS';
     RETURN x_return;
     EXCEPTION
        WHEN OTHERS THEN
            IF (l_debug = 1) THEN
               mdebug ('Other exception raised in check_lpn_pending_txns');
            END IF;
            x_return := 'N';
            x_return_msg := 'OTHER ERROR';
            RETURN  x_return;
END check_lpn_pending_txns; --End of fix for bug#4446248

END INV_TXN_VALIDATIONS;

/
