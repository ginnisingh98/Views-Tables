--------------------------------------------------------
--  DDL for Package Body AHL_LTP_MATRL_AVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_LTP_MATRL_AVAL_PVT" AS
/* $Header: AHLVMTAB.pls 120.7.12010000.4 2009/10/12 19:24:15 jaramana ship $ */
--
G_PKG_NAME  VARCHAR2(30)  := 'AHL_LTP_MATRL_AVAL_PVT';
G_DEBUG     VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;
------------------------------------
-- Common constants and variables --
------------------------------------
l_log_current_level     NUMBER      := fnd_log.g_current_runtime_level;
l_log_statement         NUMBER      := fnd_log.level_statement;
l_log_procedure         NUMBER      := fnd_log.level_procedure;
l_log_error             NUMBER      := fnd_log.level_error;
l_log_unexpected        NUMBER      := fnd_log.level_unexpected;
-----------------------------------------------------------------------
--
-- PACKAGE
--    AHL_LTP_MATRL_AVAL_PVT
--
-- PURPOSE
--    This package is used to derive requested materials for an item which is associated
--    to visit task. It calls ATP to check material availabilty
--
-- NOTES
--
--
-- HISTORY
-- 23-Apr-2002    ssurapan      Created.
--
--  Procedure name    : Check_Availability
--  Type        : Private
--  Function    : This procedure calls ATP to check inventory item is available
--                for Routine jobs derived requested quantity and task start date
--  Pre-reqs    :
--  Parameters  :
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--
--  Check_Material_Aval Parameters :
--        p_calling_module             IN         NUMBER  ,
--        p_inventory_item_id          IN         NUMBER , Required
--        p_quantity_required          IN         NUMBER,   Required
--        p_organization_id            IN         NUMBER,   Required
--        p_uom                        IN         VARCHAR2, Required
--        p_requested_date             IN         DATE, Required
--

PROCEDURE Check_Availability (
   p_calling_module       IN         NUMBER ,
   p_inventory_item_id    IN         NUMBER ,
   p_item_description     IN         VARCHAR2,
   p_quantity_required    IN         NUMBER,
   p_organization_id      IN         NUMBER,
   p_uom                  IN         VARCHAR2,
   p_requested_date       IN         DATE, --Modified by rnahata for Issue 105
   p_schedule_material_id IN         NUMBER,
   x_available_qty        OUT NOCOPY NUMBER,
   x_available_date       OUT NOCOPY DATE,
   x_error_code           OUT NOCOPY NUMBER,
   x_error_message        OUT NOCOPY VARCHAR2,
   x_return_status        OUT NOCOPY VARCHAR2
)
IS
   CURSOR Error_Message_Cur(c_error_code IN NUMBER) IS
    SELECT meaning
    FROM mfg_lookups
    WHERE lookup_type = 'MTL_DEMAND_INTERFACE_ERRORS'
     AND lookup_code = c_error_code;

   CURSOR Instance_Id_Cur IS
    SELECT instance_id
    FROM  MRP_AP_APPS_INSTANCES;

   L_API_NAME    CONSTANT VARCHAR2(30)  := 'CHECK_AVAILABILITY';
   L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   L_API_VERSION CONSTANT NUMBER        := 1.0;

   l_atp_table            Mrp_Atp_Pub.ATP_Rec_Typ;
   l_instance_id          INTEGER;
   l_session_id           NUMBER;
   x_atp_table            Mrp_Atp_Pub.ATP_Rec_Typ;
   x_atp_supply_demand    Mrp_Atp_Pub.ATP_Supply_Demand_Typ;
   x_atp_period           Mrp_Atp_Pub.ATP_Period_Typ;
   x_atp_details          Mrp_Atp_Pub.ATP_Details_Typ;
   l_uom_code             VARCHAR2(10);
   l_calling_module       NUMBER;
   l_need_by_date         DATE;
   l_return_status        VARCHAR2(1);
   l_msg_data             VARCHAR2(200);
   l_msg_count            NUMBER;
   l_msg_index_out        NUMBER;
   l_identifier           NUMBER := p_schedule_material_id;
   x_req_date_quantity    NUMBER;
   l_error_message        VARCHAR2(80);
   l_error_code           VARCHAR2(10);
   i                      pls_integer;
BEGIN

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Inventory item ID : ' || p_inventory_item_id);
   END IF;

  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT check_availability;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      l_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --

   -- Get Session ID
   SELECT MRP_ATP_SCHEDULE_TEMP_S.NEXTVAL
          INTO l_session_id FROM DUAL;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Session Id : '||l_session_id);
   END IF;

   --Get instance Id
   --Check for Instance Exists
   OPEN Instance_Id_Cur;
   FETCH Instance_Id_Cur INTO l_instance_id;
   IF Instance_Id_Cur%NOTFOUND THEN
      FND_MESSAGE.Set_Name( 'AHL','AHL_LTP_ATP_INS_ENABLE' );
      FND_MSG_PUB.add;
      CLOSE Instance_Id_Cur;
      RAISE  FND_API.G_EXC_ERROR;
   END IF;
   CLOSE Instance_Id_Cur;
   --
   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Instance Id : '||l_instance_id ||
                     ', Identifier : '||l_identifier);
   END IF;
   -- Extend array size

   MSC_ATP_GLOBAL.Extend_ATP(l_atp_table, x_return_status);

   --Assign values to input record
   l_atp_table.Inventory_Item_Id       := Mrp_Atp_Pub.number_arr(p_inventory_item_id);
   l_atp_table.Source_Organization_Id  := Mrp_Atp_Pub.number_arr(p_organization_id);
   l_atp_table.Identifier              := Mrp_Atp_Pub.number_arr(l_identifier);
   l_atp_table.Instance_Id             := MRP_ATP_PUB.number_arr(l_instance_id) ; --223);
   l_atp_table.Calling_Module          := Mrp_Atp_Pub.number_arr(p_calling_module);
   l_atp_table.Customer_Id             := Mrp_Atp_Pub.number_arr(NULL);
   l_atp_table.Customer_Site_Id        := Mrp_Atp_Pub.number_arr(NULL);
   l_atp_table.Destination_Time_Zone   := Mrp_Atp_Pub.char30_arr(NULL);
   l_atp_table.Quantity_Ordered        := Mrp_Atp_Pub.number_arr(p_quantity_required);
   l_atp_table.Quantity_UOM            := Mrp_Atp_Pub.char3_arr(p_uom);
   -- Changed by jaramana on 12-OCT-2009 for bug 8910249
   l_atp_table.Requested_Ship_Date     := Mrp_Atp_Pub.date_arr(p_requested_date);
   l_atp_table.Requested_Arrival_Date  := Mrp_Atp_Pub.date_arr(null);
   l_atp_table.Latest_Acceptable_Date  := MRP_ATP_PUB.date_arr(null);
   l_atp_table.Delivery_Lead_Time      := Mrp_Atp_Pub.number_arr(NULL);
   l_atp_table.Freight_Carrier         := Mrp_Atp_Pub.char30_arr(NULL);
   l_atp_table.Ship_Method             := Mrp_Atp_Pub.char30_arr(NULL);
   l_atp_table.Demand_Class            := Mrp_Atp_Pub.char30_arr(NULL);
   l_atp_table.Ship_Set_Name           := Mrp_Atp_Pub.char30_arr(NULL);
   l_atp_table.Arrival_Set_Name        := Mrp_Atp_Pub.char30_arr(NULL);
   l_atp_table.Override_Flag           := Mrp_Atp_Pub.char1_arr(NULL);
   l_atp_table.Action                  := Mrp_Atp_Pub.number_arr(100);
   --SKPATHAK :: Bug 8392521 :: 02-APR-2009 :: Changed date_arr(sysdate) to date_arr(NULL)
   l_atp_table.Ship_Date               := Mrp_Atp_Pub.date_arr(NULL);
   l_atp_table.Available_Quantity      := Mrp_Atp_Pub.number_arr(NULL);
   l_atp_table.Requested_Date_Quantity := Mrp_Atp_Pub.number_arr(NULL);
   l_atp_table.Group_Ship_Date         := Mrp_Atp_Pub.date_arr(NULL);
   l_atp_table.Vendor_Id               := Mrp_Atp_Pub.number_arr(NULL);
   l_atp_table.Vendor_Site_Id          := Mrp_Atp_Pub.number_arr(NULL);
   l_atp_table.Insert_Flag             := Mrp_Atp_Pub.number_arr(NULL);
   l_atp_table.Error_Code              := Mrp_Atp_Pub.number_arr(NULL);
   l_atp_table.Message                 := Mrp_Atp_Pub.char2000_arr(NULL);

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Inventory Item Id : '||l_atp_table.Inventory_Item_Id(1));
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Requested Date : '||l_atp_table.Requested_ship_Date(1));
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Calling Module : '||l_atp_table.Calling_Module(1));
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Organization Id : '||l_atp_table.Source_Organization_id(1));
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Quantity Ordered : '||l_atp_table.Quantity_Ordered(1));
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Action : '||l_atp_table.Action(1));
   END IF;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Before calling Mrp Atp Pub.Call_ATP');
   END IF;

   -- call atp module
   Mrp_Atp_Pub.Call_ATP
                (l_session_id,
                 l_atp_table,
                 x_atp_table,
                 x_atp_supply_demand,
                 x_atp_period,
                 x_atp_details,
                 l_return_status,
                 l_msg_data,
                 l_msg_count);

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'After calling Mrp Atp Pub.Call_ATP. Return Status : '|| l_return_status);
   END IF;

   -- Check Error Message stack.
   IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   MSC_ATP_GLOBAL.Extend_ATP(x_atp_table, x_return_status);

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Inventory Item Id : '||x_atp_table.Inventory_Item_Id(1));
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Organization Id : '||x_atp_table.Source_Organization_Id(1));
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Organization Code : '||x_atp_table.Source_Organization_code(1));
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Quantity Ordered : '||x_atp_table.Quantity_Ordered(1));
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Requested Ship Date : '||x_atp_table.Requested_Ship_Date(1));
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Requested Arrival Date : '||x_atp_table.Requested_arrival_Date(1));
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Arrival Date : '||x_atp_table.Arrival_Date(1));
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Available Quantity : '||x_atp_table.Available_Quantity(1));
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Requested Date Quantity : '||x_atp_table.Requested_Date_Quantity(1));
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Error Code : '||x_atp_table.Error_Code(1));
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Pub Message : '||x_atp_table.Message(1));
   END IF;

   IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

      MSC_ATP_GLOBAL.Extend_ATP(x_atp_table, l_return_status);

      x_available_date := to_char(x_atp_table.Ship_Date(1));
      --
      MSC_ATP_GLOBAL.Extend_ATP(x_atp_table, l_return_status);

      IF x_atp_table.Error_code(1) IN (0,52,53) THEN

         MSC_ATP_GLOBAL.Extend_ATP(l_atp_table, x_return_status);

         x_available_qty := trunc(x_atp_table.Available_Quantity(1));
         x_error_code := x_atp_table.Error_code(1);

         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                          'After Calling Mrp Atp Pub. Error Code = ' || x_error_code ||
                          ', Available Quantity : '||x_available_qty);
         END IF;

         --Get from mfg lookups
         OPEN Error_Message_Cur(x_error_code);
         FETCH Error_Message_Cur INTO x_error_message;
         CLOSE Error_Message_Cur;

         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'After Calling Mrp Atp Pub Error Message : '||x_error_message);
         END IF;
      ELSE
         MSC_ATP_GLOBAL.Extend_ATP(x_atp_table, l_return_status);

         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'After calling MSC EXTEND');
         END IF;

         MSC_ATP_GLOBAL.Extend_ATP(l_atp_table, x_return_status);
         x_error_code := x_atp_table.Error_code(1);

         x_available_qty := trunc(x_atp_table.Available_Quantity(1));

         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'After ERROR CODE : '||x_error_code);
         END IF;
         --Get from mfg lookups
         OPEN Error_Message_Cur(x_error_code);
         FETCH Error_Message_Cur INTO x_error_message;
         CLOSE Error_Message_Cur;

         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Interface Error Message from mfg lookups : '||x_error_message);

         END IF;
      --
      END IF;--Error code
   END IF;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Derived from Mrp Atp Pub Available Quantity : '||x_available_qty);
   END IF;

   -- Check Error Message stack.
   IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO check_availability;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count   => l_msg_count,
                               p_data    => l_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO check_availability;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count   => l_msg_count,
                               p_data    => l_msg_data);

 WHEN OTHERS THEN
    ROLLBACK TO check_availability;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name       =>  'AHL_LTP_MATRL_AVAL_PVT',
                            p_procedure_name =>  'CHECK_AVAILABILITY',
                            p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => l_msg_data);

END Check_Availability;

--  Procedure name    : Check_Material_Aval
--  Type        : Private
--  Function    : This procedure calls ATP to check inventory item is available
--                for Routine jobs derived requested quantity and task start date
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Check_Material_Aval Parameters :
--        p_x_material_avl_tbl      IN  OUT NOCOPY Material_Availability_Tbl,Required
--         List of item attributes associated to visit task
--
PROCEDURE Check_Material_Aval (
   p_api_version        IN     NUMBER,
   p_init_msg_list      IN     VARCHAR2  := FND_API.g_false,
   p_commit             IN     VARCHAR2  := FND_API.g_false,
   p_validation_level   IN     NUMBER    := FND_API.g_valid_level_full,
   p_module_type        IN     VARCHAR2  := 'JSP',
   p_x_material_avl_tbl IN OUT NOCOPY ahl_ltp_matrl_aval_pub.Material_Availability_Tbl,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
)
IS
  -- Check for visit is scheduled
 CURSOR Check_Sch_Visit_cur (c_visit_id IN NUMBER) IS
   SELECT 1 FROM ahl_visits_b
   WHERE visit_id = c_visit_id
   AND (organization_id IS NULL
   OR department_id IS NULL
      OR  start_date_time IS NULL);

 CURSOR Schedule_Matrl_cur (C_SCH_MAT_ID IN NUMBER) IS
   --Added by sowsubra - status needs be fetched
   SELECT scheduled_material_id,uom,status,
          organization_id,visit_task_id
   FROM ahl_schedule_materials
   WHERE scheduled_material_id = C_SCH_MAT_ID;

 CURSOR Item_Des_cur(c_item_id IN NUMBER, c_org_id  IN NUMBER) IS
   SELECT CONCATENATED_SEGMENTS
   FROM mtl_system_items_kfv
   WHERE inventory_item_id = c_item_id
   AND organization_id = c_org_id;

 l_api_name    CONSTANT VARCHAR2(30) := 'CHECK_MATERIAL_AVAL';
 L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
 l_api_version CONSTANT NUMBER       := 1.0;
 l_return_status        VARCHAR2(1);
 l_msg_data             VARCHAR2(2000);
 l_msg_count            NUMBER;
 l_dummy                NUMBER;
 l_available_quantity   NUMBER;
 l_available_date       DATE;
 l_Schedule_Matrl_Rec   Schedule_Matrl_cur%ROWTYPE;
 l_error_code           NUMBER;
 l_error_message        VARCHAR2(2000);

BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure.');
   END IF;
-- dbms_output.put_line( 'start private API:');

  --------------------Initialize ----------------------------------
   -- Standard Start of API savepoint
   SAVEPOINT check_material_aval;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF (l_log_statement >= l_log_current_level)THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Request for Check Material Availability for Viist item ID : ' ||
                          p_x_material_avl_tbl(1).visit_id);
   END IF;

   --Validation for schedule visit
   OPEN Check_Sch_Visit_cur(p_x_material_avl_tbl(1).visit_id);
   FETCH Check_Sch_Visit_cur INTO l_dummy;
   IF Check_Sch_Visit_cur%FOUND THEN
      Fnd_Message.SET_NAME('AHL','AHL_VISIT_UNSCHEDULED');
      Fnd_Msg_Pub.ADD;
      CLOSE Check_Sch_Visit_cur;
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;
   CLOSE Check_Sch_Visit_cur;
   --
   IF (l_log_statement >= l_log_current_level)THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Request for Check Material Availability for Material Records : ' ||
                          p_x_material_avl_tbl.COUNT);
   END IF;
   --
   IF p_x_material_avl_tbl.COUNT > 0 THEN
      FOR i IN  p_x_material_avl_tbl.FIRST..p_x_material_avl_tbl.LAST
      LOOP
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Check Material Availability for Inventory Item Id : ' ||
                           p_x_material_avl_tbl(i).inventory_item_id ||
                           ', Schedule Material Id : ' ||
                           p_x_material_avl_tbl(i).schedule_material_id);
         END IF;
         --Check for schedule mat rec
         OPEN Schedule_Matrl_cur(p_x_material_avl_tbl(i).schedule_material_id);
         FETCH Schedule_Matrl_cur INTO l_Schedule_Matrl_Rec;
         IF Schedule_Matrl_cur%NOTFOUND THEN
            Fnd_Message.SET_NAME('AHL','AHL_LTP_ORG_ID_NOT_EXISTS');
            Fnd_Msg_Pub.ADD;
            CLOSE Schedule_Matrl_cur;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
         CLOSE Schedule_Matrl_cur;

         --Added by sowsubra - starts
         IF l_Schedule_Matrl_Rec.status = 'IN-SERVICE' THEN
              Fnd_Message.SET_NAME('AHL','AHL_MAT_STS_INSERVICE');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
         --Added by sowsubra - ends

         --Get Item description
         OPEN Item_Des_Cur(p_x_material_avl_tbl(i).inventory_item_id,
                           l_Schedule_Matrl_Rec.organization_id);
         FETCH Item_Des_Cur INTO p_x_material_avl_tbl(i).item;
         CLOSE Item_Des_Cur;

         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Before calling Check Availability');
         END IF;

         Check_Availability (
               p_calling_module    => 867, --fnd_global.prog_appl_id,
               p_inventory_item_id => p_x_material_avl_tbl(i).inventory_item_id ,
               p_item_description  => p_x_material_avl_tbl(i).item,
               p_quantity_required => p_x_material_avl_tbl(i).quantity,
               p_organization_id   => l_Schedule_Matrl_Rec.organization_id,
               p_uom               => l_Schedule_Matrl_Rec.uom,
               p_requested_date    => p_x_material_avl_tbl(i).req_arrival_date,
               p_schedule_material_id  => p_x_material_avl_tbl(i).schedule_material_id,
               x_available_qty     => l_available_quantity,
               x_available_date    => l_available_date,
               x_error_code        => l_error_code,
               x_error_message     => l_error_message,
               x_return_status     => l_return_status);
         --
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'After calling Check Availability, Return Status : '|| l_return_status);
         END IF;

         -- Check Error Message stack.
         IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_count := FND_MSG_PUB.count_msg;
            IF l_msg_count > 0 THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;
         --Assign derived values
         p_x_material_avl_tbl(i).quantity_available:= l_available_quantity;
         --SKPATHAK :: Bug 8392521 :: 02-APR-2009
	 --Pass the ship_date returned by ATP (as l_available_date) unconditionally to the out param of PVT API
         p_x_material_avl_tbl(i).scheduled_date:= l_available_date;

         -- anraj : commented these lines of code
         /*p_x_material_avl_tbl(i).inventory_item_id := p_x_material_avl_tbl(i).inventory_item_id;
         p_x_material_avl_tbl(i).quantity          := p_x_material_avl_tbl(i).quantity;
         p_x_material_avl_tbl(i).visit_task_id     := p_x_material_avl_tbl(i).visit_task_id;
         p_x_material_avl_tbl(i).task_name         := p_x_material_avl_tbl(i).task_name;
         p_x_material_avl_tbl(i).req_arrival_date  := p_x_material_avl_tbl(i).req_arrival_date;
         p_x_material_avl_tbl(i).uom               := p_x_material_avl_tbl(i).uom;
         */
         p_x_material_avl_tbl(i).error_code        := l_error_code;
         p_x_material_avl_tbl(i).error_message     := l_error_message;
         --
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Inventory Item Id : ' || p_x_material_avl_tbl(i).inventory_item_id);
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Quantity Available : ' || p_x_material_avl_tbl(i).quantity_available);
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Quantity Required : ' || p_x_material_avl_tbl(i).quantity);
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Visit Task Id: ' || p_x_material_avl_tbl(i).visit_task_id);
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Error Code: ' || l_error_code);
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Error Message: ' || l_error_message);
         END IF;
      END LOOP;
   END IF;

   -- Check Error Message stack.
   IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO check_material_aval;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => l_msg_data);

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO check_material_aval;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => l_msg_data);

WHEN OTHERS THEN
    ROLLBACK TO check_material_aval;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_MATRL_AVAL_PVT',
                            p_procedure_name  =>  'CHECK_MATERIAL_AVAL',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => l_msg_data);

END Check_Material_Aval;

--
--  Procedure name    : Get_Visit_Task_Materials
--  Type        : Private
--  Function    : This procedure derives material information associated to scheduled
--                visit, which are defined at Route Operation level
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Get_Visit_Task_Materials :
--           p_visit_id                 IN   NUMBER,Required
--           x_task_req_matrl_tbl       OUT NOCOPY Task_Req_Matrl_Tbl,
--
PROCEDURE Get_Visit_Task_Materials (
   p_api_version        IN         NUMBER,
   p_init_msg_list      IN         VARCHAR2 := FND_API.g_false,
   p_validation_level   IN         NUMBER   := FND_API.g_valid_level_full,
   p_visit_id           IN         NUMBER,
   x_task_req_matrl_tbl OUT NOCOPY ahl_ltp_matrl_aval_pub.task_req_matrl_tbl,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2)
 IS
  --
  -- changed the select statement to add one more column
  CURSOR Visit_Task_Matrl_Cur(C_VISIT_ID IN NUMBER) IS
   SELECT schedule_material_id,
          object_version_number,
          visit_id,
          visit_task_id,
          visit_task_name,
          inventory_item_id,
          item_number,  --Modified by rnahata for ER 6391157, ahl_visit_task_matrl_v definition changed
          requested_quantity,
          requested_date,
          scheduled_date,
          scheduled_quantity,
          uom,
          sales_order_line_id,
          task_status_code,
          meaning
   FROM ahl_visit_task_matrl_v, FND_LOOKUP_VALUES_VL
   WHERE visit_id = C_VISIT_ID
   --SKPATHAK :: Bug 8429732 :: 17-APR-2009
   --Commented out the condition (requested_quantity <> 0)
   /* AND (requested_quantity <> 0) */
    AND NVL(mat_status,'X') <> 'IN-SERVICE' --Added by sowsubra
    AND LOOKUP_TYPE(+) = 'AHL_VWP_TASK_STATUS'
    AND LOOKUP_code = task_status_code;
  c_Visit_Task_Matrl_Rec    Visit_Task_Matrl_Cur%ROWTYPE;

  --Standard local variables
  l_api_name    CONSTANT VARCHAR2(30)  := 'Get_Visit_Task_Materials';
  L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
  l_api_version CONSTANT NUMBER       := 1.0;
  l_return_status        VARCHAR2(1);
  l_msg_data             VARCHAR2(2000);
  l_msg_count            NUMBER;
  --
  i NUMBER;
 BEGIN

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Visit Id = ' || p_visit_id);
   END IF;
   -- Standard Start of API savepoint
   SAVEPOINT Get_Visit_Task_Materials;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      l_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   IF p_visit_id IS NOT NULL THEN
      --
      OPEN Visit_Task_Matrl_Cur(p_visit_id);
      i := 0;
      LOOP
         FETCH Visit_Task_Matrl_Cur INTO c_Visit_Task_Matrl_Rec;
         EXIT WHEN Visit_Task_Matrl_Cur%NOTFOUND;
         --
         x_task_req_matrl_tbl(i).schedule_material_id  := c_Visit_Task_Matrl_Rec.schedule_material_id;
         x_task_req_matrl_tbl(i).object_version_number := c_Visit_Task_Matrl_Rec.object_version_number;
         x_task_req_matrl_tbl(i).visit_task_id         := c_Visit_Task_Matrl_Rec.visit_task_id;
         x_task_req_matrl_tbl(i).task_name             := c_Visit_Task_Matrl_Rec.visit_task_name;
         -- anraj : added columns TASK_STATUS_CODE and TASK_STATUS_MEANING , for Material Availabilty UI
         x_task_req_matrl_tbl(i).task_status_code      := c_Visit_Task_Matrl_Rec.task_status_code;
         x_task_req_matrl_tbl(i).task_status_meaning   := c_Visit_Task_Matrl_Rec.meaning;
         x_task_req_matrl_tbl(i).inventory_item_id     := c_Visit_Task_Matrl_Rec.inventory_item_id;
         x_task_req_matrl_tbl(i).item                  := c_Visit_Task_Matrl_Rec.item_number;
         x_task_req_matrl_tbl(i).req_arrival_date      := c_Visit_Task_Matrl_Rec.requested_date;
         x_task_req_matrl_tbl(i).uom_code              := c_Visit_Task_Matrl_Rec.uom;
         x_task_req_matrl_tbl(i).planned_order         := c_Visit_Task_Matrl_Rec.sales_order_line_id;
         x_task_req_matrl_tbl(i).quantity              := c_Visit_Task_Matrl_Rec.requested_quantity;
         x_task_req_matrl_tbl(i).scheduled_date        := c_Visit_Task_Matrl_Rec.scheduled_date;
         i := i + 1;
      END LOOP;
      CLOSE Visit_Task_Matrl_Cur;
   END IF;

   -- Check Error Message stack.
   IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;

 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_Visit_Task_Materials;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                 p_count => l_msg_count,
                                 p_data  => l_msg_data);
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Get_Visit_Task_Materials;
      X_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                 p_count => l_msg_count,
                                 p_data  => l_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO Get_Visit_Task_Materials;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_MATRL_AVAL_PVT',
                               p_procedure_name  =>  'GET_VISIT_TASK_MATERIALS',
                               p_error_text      => SUBSTR(SQLERRM,1,240));
      END IF;
      FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                 p_count => l_msg_count,
                                 p_data  => l_msg_data);
END Get_Visit_Task_Materials;
--
PROCEDURE Extend_ATP
      (p_atp_table  IN OUT NOCOPY  MRP_ATP_PUB.ATP_Rec_Typ,
       x_return_status OUT  NOCOPY VARCHAR2)
  IS

  L_API_NAME     CONSTANT VARCHAR2(30)  := 'Extend_ATP';
  L_DEBUG_KEY    CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

BEGIN
    IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.begin',
                      'At the start of PL SQL procedure.');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --
    p_atp_table.Row_Id.Extend;
    P_ATP_TABLE.INSTANCE_ID.EXTEND;
    P_ATP_TABLE.INVENTORY_ITEM_ID.EXTEND;
    P_ATP_TABLE.INVENTORY_ITEM_NAME.EXTEND;
    P_ATP_TABLE.SOURCE_ORGANIZATION_ID.EXTEND;
    p_atp_table.Source_Organization_Code.Extend;
    p_atp_table.Organization_Id.Extend;
    P_ATP_TABLE.IDENTIFIER.EXTEND;
    p_atp_table.Scenario_Id.Extend;
    P_ATP_TABLE.DEMAND_SOURCE_TYPE.EXTEND;
    P_ATP_TABLE.CALLING_MODULE.EXTEND;
    p_atp_table.Customer_Id.Extend;
    p_atp_table.Customer_Site_Id.Extend;
    p_atp_table.Destination_Time_Zone.Extend;
    P_ATP_TABLE.QUANTITY_ORDERED.EXTEND;
    P_ATP_TABLE.QUANTITY_UOM.EXTEND;
    P_ATP_TABLE.REQUESTED_SHIP_DATE.EXTEND;
    p_atp_table.Requested_Arrival_Date.Extend;
    p_atp_table.Earliest_Acceptable_Date.Extend;
    p_atp_table.Latest_Acceptable_Date.Extend;
    p_atp_table.Delivery_Lead_Time.Extend;
    p_atp_table.Freight_Carrier.Extend;
    p_atp_table.Ship_Method.Extend;
    p_atp_table.Demand_Class.Extend;
    p_atp_table.Ship_Set_Name.Extend;
    p_atp_table.Arrival_Set_Name.Extend;
    p_atp_table.Override_Flag.Extend;
    P_ATP_TABLE.ACTION.EXTEND;
    p_atp_table.Ship_Date.Extend;
    p_atp_table.Available_Quantity.Extend;
    P_ATP_TABLE.ORDER_NUMBER.EXTEND;
    p_atp_table.Requested_Date_Quantity.Extend;
    p_atp_table.Group_Ship_Date.Extend;
    p_atp_table.Group_Arrival_Date.Extend;
    p_atp_table.Vendor_Id.Extend;
    p_atp_table.Vendor_Name.Extend;
    p_atp_table.Vendor_Site_Id.Extend;
    p_atp_table.Vendor_Site_Name.Extend;
    p_atp_table.Insert_Flag.Extend;
    p_atp_table.OE_Flag.Extend;
    p_atp_table.Error_Code.Extend;
    p_atp_table.Message.Extend;
    p_atp_table.req_item_req_date_qty.extend;
    p_atp_table.req_item_available_date.extend;
    p_atp_table.req_item_available_date_qty.extend;

    IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.end',
                      'At the end of PL SQL procedure. Return Status = ' || x_return_status);
    END IF;

 END Extend_ATP;
--
-- Start of Comments --
--  Procedure name    : Call_ATP
--  Type        : Public
--  Function    : This procedure calls ATP to schedule planned materials
--                for Routine jobs derived requested quantity and task start date
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Schedule_Planned_Matrls Parameters :
--        p_x_planned_matrls_tbl      IN  OUT NOCOPY Planned_Matrls_Tbl,Required
--         List of item attributes associated to visit task
--
PROCEDURE Call_ATP (
   p_api_version         IN      NUMBER,
   p_init_msg_list       IN      VARCHAR2  := FND_API.g_false,
   p_validation_level    IN      NUMBER    := FND_API.g_valid_level_full,
   p_x_planned_matrl_tbl IN  OUT NOCOPY AHL_LTP_MATRL_AVAL_PUB.Planned_Matrl_Tbl,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2)
IS

  CURSOR Error_Message_Cur(c_error_code IN NUMBER)
  IS
   SELECT meaning
     FROM mfg_lookups
    WHERE lookup_type = 'MTL_DEMAND_INTERFACE_ERRORS'
  AND lookup_code = C_Error_Code;

   CURSOR Planned_Order_Cur(c_sch_mat_id IN NUMBER) IS
   -- yazhou 12-May-2006 starts
   -- Bug fix#5223772
   /*
    -- Changed for fixing perf bug:4919540
    select  DECODE( SIGN( trunc(scheduled_date) - trunc(requested_date)),1,scheduled_date,null) scheduled_date,
            scheduled_quantity
    from    ahl_schedule_materials asmt,
            AHL_VISIT_TASKS_B tsk
    where   TSK.VISIT_ID = ASMT.VISIT_ID
    AND     TSK.VISIT_TASK_ID = ASMT.VISIT_TASK_ID
    AND     NVL(ASMT.STATUS,' ') <> 'DELETED'
    AND     NVL(TSK.STATUS_CODE,'X') <> 'DELETED'
    AND     scheduled_material_id = c_sch_mat_id;
   */
    SELECT scheduled_date ,
           status, --Added by sowsubra
           scheduled_quantity
    FROM ahl_schedule_materials asmt,
         AHL_VISIT_TASKS_B tsk
    WHERE TSK.VISIT_ID = ASMT.VISIT_ID
     AND TSK.VISIT_TASK_ID = ASMT.VISIT_TASK_ID
     AND NVL(ASMT.STATUS,' ') <> 'DELETED'
     AND NVL(TSK.STATUS_CODE,'X') <> 'DELETED'
     AND scheduled_material_id = c_sch_mat_id
     AND scheduled_date is not null
     AND scheduled_date >= requested_date;
   --yazhou 12-May-2006 ends

   CURSOR Order_Number_Cur(c_visit_task_id IN NUMBER) IS
    SELECT visit_number||visit_task_number Order_Number
    FROM ahl_visit_tasks_v
    WHERE visit_task_id = c_visit_task_id;

  CURSOR Instance_Id_Cur IS
   SELECT instance_id
   FROM  MRP_AP_APPS_INSTANCES;

  --Standard local variables
  l_api_name    CONSTANT VARCHAR2(30) := 'CALL_ATP';
  L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
  l_api_version CONSTANT NUMBER       := 1.0;
  l_return_status        VARCHAR2(1);
  l_msg_data             VARCHAR2(2000);
  l_msg_count            NUMBER;
  --Varibales to call mrp atp pub
  l_session_id           NUMBER;
  l_instance_id          NUMBER;
  l_atp_table            Mrp_Atp_Pub.ATP_Rec_Typ;
  x_atp_table            Mrp_Atp_Pub.ATP_Rec_Typ;
  x_atp_supply_demand    Mrp_Atp_Pub.ATP_Supply_Demand_Typ;
  x_atp_period           Mrp_Atp_Pub.ATP_Period_Typ;
  x_atp_details          Mrp_Atp_Pub.ATP_Details_Typ;
  l_temp_atp_table       AHL_LTP_MATRL_AVAL_PUB.Planned_Matrl_Tbl;
  l_error_msg            VARCHAR2(2000);
  l_error_message        VARCHAR2(80);
  l_planned_matrl_tbl    AHL_LTP_MATRL_AVAL_PUB.Planned_Matrl_Tbl := p_x_planned_matrl_tbl;
  l_scheduled_date       DATE;
  l_scheduled_quantity   NUMBER;
  l_Planned_Order_Rec    Planned_Order_Cur%ROWTYPE;
  --Required to capture available quantity and scheduled quanity
  l_temp_planned_table   AHL_LTP_MATRL_AVAL_PUB.Planned_Matrl_Tbl;
  l_order_number         NUMBER;

BEGIN

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Number of Records : ' || l_planned_matrl_tbl.COUNT);
   END IF;
   -- Standard Start of API savepoint
   SAVEPOINT Call_ATP;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      l_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Get session id
   SELECT MRP_ATP_SCHEDULE_TEMP_S.NEXTVAL
          INTO l_session_id FROM DUAL;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Session Id : '||l_session_id);
   END IF;

   --Get instance Id
   --Check for Instance Id
   OPEN Instance_Id_Cur;
   FETCH Instance_Id_Cur INTO l_instance_id;
   IF Instance_Id_Cur%NOTFOUND THEN
      FND_MESSAGE.Set_Name( 'AHL','AHL_LTP_ATP_INS_ENABLE' );
      FND_MSG_PUB.add;
      CLOSE Instance_Id_Cur;
      RAISE  FND_API.G_EXC_ERROR;
   END IF;
   --
   CLOSE Instance_Id_Cur;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Instance Id : '||l_instance_id);
   END IF;

   -- Loop through all the records
   FOR i IN l_planned_matrl_tbl.FIRST .. l_planned_matrl_tbl.LAST
   LOOP
   --
      IF l_planned_matrl_tbl.EXISTS(i) THEN
         --Call extend Atp
         MSC_ATP_GLOBAL.Extend_ATP(l_atp_table, x_return_status);
         --
         l_atp_table.inventory_item_id(i)   := l_planned_matrl_tbl(i).inventory_item_id;
         l_atp_table.inventory_item_name(i) := l_planned_matrl_tbl(i).item_description;
         l_atp_table.instance_id(i)         := l_instance_id;
         l_atp_table.source_organization_id(i) := l_planned_matrl_tbl(i).organization_id;
         l_atp_table.identifier(i)          := l_planned_matrl_tbl(i).schedule_material_id;
         l_atp_table.demand_source_type(i)  := 100;
         l_atp_table.quantity_ordered(i)    := l_planned_matrl_tbl(i).required_quantity;
         l_atp_table.quantity_UOM(i)        := l_planned_matrl_tbl(i).primary_uom_code;
         l_atp_table.requested_ship_date(i) := l_planned_matrl_tbl(i).requested_date;
         --VERFY WEATHER SCHEDULING OR RESCHEDULING
         OPEN Planned_Order_Cur(l_planned_matrl_tbl(i).schedule_material_id);
         FETCH Planned_Order_Cur into l_Planned_Order_Rec;
         IF Planned_Order_Cur%NOTFOUND THEN
            l_atp_table.action(i) := 110;--Scheduling
         ELSE
            l_atp_table.action(i) := 120;--Rescheduling
            l_atp_table.Old_Source_Organization_Id(i) := l_planned_matrl_tbl(i).organization_id;--Rescheduling
         END IF;
         CLOSE Planned_Order_Cur;

         --Added by sowsubra - start
          IF l_Planned_Order_Rec.status = 'IN-SERVICE' THEN
            Fnd_Message.SET_NAME('AHL','AHL_MAT_STS_INSERVICE');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
          END IF;
         --Added by sowsubra - end

         --Get Concatenated visit number, task number
         OPEN Order_Number_Cur(l_planned_matrl_tbl(i).visit_task_id);
         FETCH Order_Number_Cur INTO l_order_number;
         CLOSE Order_Number_Cur;
         --Assign to atp record
         l_atp_table.order_number(i)        := l_order_number;
         l_atp_table.calling_module(i)      := 867; --fnd_global.prog_appl_id;
         --
         IF (l_log_statement >= l_log_current_level)THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Inventory Item Id : '||l_atp_table.inventory_item_id(i) ||'-'||i);
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Inventory Item Name : '||l_atp_table.inventory_item_name(i));
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Instance Id : '||l_atp_table.instance_id(i));
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Organization Id : '||l_atp_table.source_organization_id(i));
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Identifier : '||l_atp_table.identifier(i));
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Demand Source Type : '||l_atp_table.demand_source_type(i));
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                          'Quantity Ordered : '||l_atp_table.quantity_ordered(i));
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Quantity UOM : '||l_atp_table.quantity_uom(i));
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Requested Ship Date : '||l_atp_table.requested_ship_date(i));
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Action : '||l_atp_table.action(i));
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Order Number : '||l_atp_table.order_number(i));
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Requested Date Quantity : '||l_atp_table.requested_date_quantity(i));
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Calling Module : '||l_atp_table.Calling_module(i));
         END IF;
      END IF;
   END LOOP;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Before calling Mrp Atp Pub.Call_ATP. Calling Module count: '||
                     l_atp_table.Calling_module.count);
   END IF;

   -- Call ATP to Schedule
   MRP_ATP_PUB.CALL_ATP(l_session_id,
                        l_atp_table,
                        x_atp_table,
                        x_atp_supply_demand,
                        x_atp_period,
                        x_atp_details,
                        x_return_status,
                        x_msg_data,
                        x_msg_count);

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'After calling Mrp Atp Pub.Call_ATP. Return Status : '|| x_return_status);
   END IF;

   -- Check Error Message stack.
   IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   --Check for error code
   IF x_atp_table.Error_Code.COUNT > 0 THEN
      FOR i IN x_atp_table.Error_Code.FIRST .. x_atp_table.Error_Code.LAST
      LOOP
         MSC_ATP_GLOBAL.Extend_ATP(x_atp_table, x_return_status);
         IF (x_atp_table.Error_Code.EXISTS(i) AND x_atp_table.error_code(i) <> 0) THEN
            IF (l_log_statement >= l_log_current_level)THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                             'x_atp_table.error_code(i) : '||x_atp_table.error_code(i));
            END IF;
            MSC_ATP_GLOBAL.Extend_ATP(x_atp_table, x_return_status);

            --SKPATHAK :: Bug 8392521 :: 02-APR-2009
            --Update ahl_schedule_materials table with the ship_date even if the error is not zero
            IF (x_atp_table.ship_date(i) IS NOT NULL)THEN
            UPDATE ahl_schedule_materials
            SET scheduled_date = x_atp_table.ship_date(i),
            object_version_number = object_version_number + 1
            WHERE scheduled_material_id = x_atp_table.identifier(i);
            END IF;

            l_temp_atp_table(i).schedule_material_id := x_atp_table.identifier(i);
            l_temp_atp_table(i).item_description := x_atp_table.inventory_item_name(i);
            l_temp_atp_table(i).error_code    := x_atp_table.error_code(i);
            l_temp_atp_table(i).quantity_available := trunc(x_atp_table.available_quantity(i));
            l_temp_atp_table(i).item_description := x_atp_table.inventory_item_name(i);
            --Get error message
            OPEN Error_Message_Cur(l_temp_atp_table(i).error_code);
            FETCH Error_Message_Cur INTO l_temp_atp_table(i).error_message;
            CLOSE Error_Message_Cur;
         ELSE
            --Error code is zero update the record
            MSC_ATP_GLOBAL.Extend_ATP(x_atp_table, x_return_status);

            IF (l_log_statement >= l_log_current_level)THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'x_atp_table.identifier(i) : '|| x_atp_table.identifier(i));
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'x_atp_table.available_quantity(i) : '|| x_atp_table.available_quantity(i));
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'x_atp_table.requested_date_quantity(i) : '|| trunc(x_atp_table.requested_date_quantity(i)));
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'x_atp_table.ship_date(i) : '|| x_atp_table.ship_date(i));
            END IF;
            --Assign out parameter
            l_temp_atp_table(i).schedule_material_id := x_atp_table.identifier(i);
            l_temp_atp_table(i).quantity_available := trunc(x_atp_table.available_quantity(i));
            -- l_temp_atp_table(i).scheduled_quantity := trunc(x_atp_table.requested_date_quantity(i));
            l_temp_atp_table(i).error_code    := x_atp_table.error_code(i);
            l_temp_atp_table(i).error_message := 'Successfully Scheduled';
            l_temp_atp_table(i).item_description := x_atp_table.inventory_item_name(i);

            --yazhou 12-May-2006 starts
            --Bug fix #5223772
            UPDATE ahl_schedule_materials
            SET scheduled_date = x_atp_table.ship_date(i),
                scheduled_quantity = l_planned_matrl_tbl(i).required_quantity,
                object_version_number = object_version_number + 1
            WHERE scheduled_material_id = x_atp_table.identifier(i);
            --yazhou 12-May-2006 ends
         END IF;
      END LOOP;
   END IF;
   -- Assign to out parameter
   IF l_temp_atp_table.COUNT > 0 THEN
      FOR i IN l_temp_atp_table.FIRST..l_temp_atp_table.LAST
      LOOP
         IF (l_log_statement >= l_log_current_level)THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Before assign out parameter, Sch Mat ID: '||
                           l_temp_atp_table(i).schedule_material_id ||
                           ', Quantity Available: '||
                           l_temp_atp_table(i).quantity_available ||
                           ', Scheduled Quantity : '||
                           l_temp_atp_table(i).scheduled_date ||
                           ', Error Code : '||
                           l_temp_atp_table(i).error_code ||
                           ', Error Message : '||
                           l_temp_atp_table(i).error_message);
          END IF;
          --

          --SKPATHAK :: Bug 8392521 :: 02-APR-2009 :: Included the scheduled_date in the out param
          p_x_planned_matrl_tbl(i).scheduled_date := x_atp_table.ship_date(i);
          p_x_planned_matrl_tbl(i).schedule_material_id := l_temp_atp_table(i).schedule_material_id;
          p_x_planned_matrl_tbl(i).quantity_available := l_temp_atp_table(i).quantity_available;
          -- p_x_planned_matrl_tbl(i).scheduled_quantity := l_temp_atp_table(i).scheduled_quantity;
          p_x_planned_matrl_tbl(i).error_code := l_temp_atp_table(i).error_code;
          p_x_planned_matrl_tbl(i).error_message := 'For Item '||l_temp_atp_table(i).item_description||', '||l_temp_atp_table(i).error_message;
          p_x_planned_matrl_tbl(i).item_description := l_temp_atp_table(i).item_description;
      END LOOP;
   END IF;

   -- Check Error Message stack.
   IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
       l_msg_count := FND_MSG_PUB.count_msg;
       IF l_msg_count > 0 THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
   END IF;
   --Need to fix error messages

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;
 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Call_ATP;
       X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                  p_count => l_msg_count,
                                  p_data  => l_msg_data);

    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Call_ATP;
       X_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                  p_count => l_msg_count,
                                  p_data  => l_msg_data);

    WHEN OTHERS THEN
       ROLLBACK TO Call_ATP;
       X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_MATRL_AVAL_PVT',
                               p_procedure_name  =>  'CALL_ATP',
                               p_error_text      => SUBSTR(SQLERRM,1,240));
       END IF;
       FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                  p_count => l_msg_count,
                                  p_data  => l_msg_data);

 END Call_ATP;

-- Start of Comments --
--  Procedure name    : Schedule_Planned_Mtrls
--  Type        : Public
--  Function    : This procedure calls ATP to schedule planned materials
--                for Routine jobs derived requested quantity and task start date
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Schedule_Planned_Matrls Parameters :
--        p_x_planned_matrls_tbl      IN  OUT NOCOPY Planned_Matrls_Tbl,Required
--         List of item attributes associated to visit task
--
PROCEDURE Schedule_Planned_Matrls (
   p_api_version         IN     NUMBER,
   p_init_msg_list       IN     VARCHAR2  := FND_API.g_false,
   p_commit              IN     VARCHAR2  := FND_API.g_false,
   p_validation_level    IN     NUMBER    := FND_API.g_valid_level_full,
   p_x_planned_matrl_tbl IN OUT NOCOPY AHL_LTP_MATRL_AVAL_PUB.Planned_Matrl_Tbl,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2)
IS
 CURSOR Sch_Material_Cur (c_sch_mat_id IN NUMBER) IS
  SELECT schm.inventory_item_id,
         schm.organization_id,
         schm.uom,
         schm.requested_date,
         schm.status mat_status, --Added by sowsubra
         avtm.item_number --Modified by rnahata for ER 6391157, ahl_visit_task_matrl_v definition changed
  FROM ahl_schedule_materials schm,
       ahl_visit_task_matrl_v avtm
  WHERE schm.scheduled_material_id = avtm.schedule_material_id
   AND avtm.schedule_material_id = c_sch_mat_id;

 -- anraj modified by adding two more columns task status code and meaning
 CURSOR Planned_Material_Cur (c_sch_mat_id IN NUMBER) IS
 SELECT visit_id,
        visit_task_id,
        visit_task_name,
        requested_quantity,
        scheduled_date,
        scheduled_quantity,
        item_number, --Modified by rnahata for ER 6391157, ahl_visit_task_matrl_v definition changed
        object_version_number,
        inventory_item_id,
        uom,
        requested_date,
        task_status_code,
        meaning
 FROM ahl_visit_task_matrl_v,FND_LOOKUP_VALUES_VL
 WHERE schedule_material_id = c_sch_mat_id
  AND LOOKUP_TYPE(+) = 'AHL_VWP_TASK_STATUS'
  AND   LOOKUP_code = task_status_code;

  --Standard local variables
  l_api_name     CONSTANT VARCHAR2(30)  := 'Schedule_Planned_Matrls';
  L_DEBUG_KEY    CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
  l_api_version  CONSTANT NUMBER        := 1.0;
  l_return_status         VARCHAR2(1);
  l_msg_data              VARCHAR2(2000);
  l_msg_count             NUMBER;

  l_planned_matrl_tbl  AHL_LTP_MATRL_AVAL_PUB.Planned_Matrl_Tbl := p_x_planned_matrl_tbl;
  l_Sch_Material_Rec  Sch_Material_Cur%ROWTYPE;
  l_Planned_Material_Rec  Planned_Material_Cur%ROWTYPE;
  l_temp_planned_matrl_tbl  AHL_LTP_MATRL_AVAL_PUB.Planned_Matrl_Tbl;
  j NUMBER := 1;
BEGIN

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Number of Records : ' || l_planned_matrl_tbl.COUNT);
   END IF;
   -- Standard Start of API savepoint
   SAVEPOINT schedule_planned_matrls;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      l_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   IF l_planned_matrl_tbl.COUNT > 0 THEN
      FOR i IN l_planned_matrl_tbl.FIRST..l_planned_matrl_tbl.LAST
      LOOP
         --Get schedule materil details
         IF l_planned_matrl_tbl(i).schedule_material_id IS NOT NULL THEN
            OPEN Sch_Material_Cur(l_planned_matrl_tbl(i).schedule_material_id);
            FETCH Sch_Material_Cur INTO l_planned_matrl_tbl(i).inventory_item_id,
                                        l_planned_matrl_tbl(i).organization_id,
                                        l_planned_matrl_tbl(i).primary_uom_code,
                                        l_planned_matrl_tbl(i).requested_date,
                                        l_planned_matrl_tbl(i).mat_status, --Added by sowsubra
                                        l_planned_matrl_tbl(i).item_description;
            CLOSE Sch_Material_Cur;
         END IF;

         --Added by sowsubra - starts
         IF l_planned_matrl_tbl(i).mat_status = 'IN-SERVICE' THEN
          Fnd_Message.SET_NAME('AHL','AHL_MAT_STS_INSERVICE');
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
         --Added by sowsubra - ends
      END LOOP;
   END IF;

   --Assign values  start from index value 1
   IF l_planned_matrl_tbl.COUNT > 0 THEN
      FOR i IN l_planned_matrl_tbl.FIRST..l_planned_matrl_tbl.LAST
      LOOP
         l_temp_planned_matrl_tbl(j).inventory_item_id := l_planned_matrl_tbl(i).inventory_item_id;
         l_temp_planned_matrl_tbl(j).visit_id := l_planned_matrl_tbl(i).visit_id;
         l_temp_planned_matrl_tbl(j).visit_task_id := l_planned_matrl_tbl(i).visit_task_id;
         l_temp_planned_matrl_tbl(j).schedule_material_id := l_planned_matrl_tbl(i).schedule_material_id;
         l_temp_planned_matrl_tbl(j).item_description := l_planned_matrl_tbl(i).item_description;
         l_temp_planned_matrl_tbl(j).organization_id := l_planned_matrl_tbl(i).organization_id;
         l_temp_planned_matrl_tbl(j).primary_uom_code := l_planned_matrl_tbl(i).primary_uom_code;
         l_temp_planned_matrl_tbl(j).requested_date := l_planned_matrl_tbl(i).requested_date;
         l_temp_planned_matrl_tbl(j).required_quantity := l_planned_matrl_tbl(i).required_quantity;
         j := j + 1;
      END LOOP;
   END IF;

   --
   IF l_temp_planned_matrl_tbl.COUNT > 0 THEN
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Before calling Call ATP');
      END IF;

      -- Call local procedure which calls atp Api
      Call_ATP
        (p_api_version         => p_api_version,
         p_init_msg_list       => p_init_msg_list,
         p_validation_level    => p_validation_level,
         p_x_planned_matrl_tbl => l_temp_planned_matrl_tbl,
         x_return_status       => l_return_status,
         x_msg_count           => l_msg_count,
         x_msg_data            => l_msg_data);
   END IF;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'After calling Call ATP. Return Status : '|| l_return_status ||
                     ', Returned Final Records : '||l_temp_planned_matrl_tbl.COUNT);
   END IF;

   -- Check Error Message stack.
   IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
       l_msg_count := FND_MSG_PUB.count_msg;
       IF l_msg_count > 0 THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
   END IF;

   --Assign out parameter
   IF l_temp_planned_matrl_tbl.COUNT > 0 THEN
      FOR i IN l_temp_planned_matrl_tbl.FIRST..l_temp_planned_matrl_tbl.LAST
      LOOP
      --
      --Get schedule materil details
      IF l_temp_planned_matrl_tbl(i).schedule_material_id IS NOT NULL THEN
         OPEN Planned_Material_Cur(l_planned_matrl_tbl(i).schedule_material_id);
         FETCH Planned_Material_Cur INTO l_Planned_Material_Rec;
         CLOSE Planned_Material_Cur;
         --
         p_x_planned_matrl_tbl(i).schedule_material_id :=  l_temp_planned_matrl_tbl(i).schedule_material_id;
         p_x_planned_matrl_tbl(i).object_version_number := l_Planned_Material_Rec.object_version_number;
         p_x_planned_matrl_tbl(i).inventory_item_id     := l_Planned_Material_Rec.inventory_item_id;

         --Modified by rnahata for ER 6391157, ahl_visit_task_matrl_v definition changed
         p_x_planned_matrl_tbl(i).item_description      := l_Planned_Material_Rec.item_number;

         p_x_planned_matrl_tbl(i).visit_id              := l_Planned_Material_Rec.visit_id;
         p_x_planned_matrl_tbl(i).visit_task_id         := l_Planned_Material_Rec.visit_task_id;
         p_x_planned_matrl_tbl(i).task_name             := l_Planned_Material_Rec.visit_task_name;

         -- anraj added fot the Material Availability UI
         p_x_planned_matrl_tbl(i).task_status_code      := l_Planned_Material_Rec.task_status_code;
         p_x_planned_matrl_tbl(i).task_status_meaning   := l_Planned_Material_Rec.meaning;

         --SKPATHAK :: Bug 8392521 :: 02-APR-2009 :: Included the scheduled_date in the out param
         p_x_planned_matrl_tbl(i).scheduled_date        := l_temp_planned_matrl_tbl(i).scheduled_date;
         p_x_planned_matrl_tbl(i).requested_date        := l_Planned_Material_Rec.requested_date;
         p_x_planned_matrl_tbl(i).required_quantity     := l_Planned_Material_Rec.requested_quantity;
         p_x_planned_matrl_tbl(i).quantity_available    := l_temp_planned_matrl_tbl(i).quantity_available;
         -- p_x_planned_matrl_tbl(i).scheduled_quantity    := l_Planned_Material_Rec.scheduled_quantity;
         p_x_planned_matrl_tbl(i).primary_uom           := l_Planned_Material_Rec.uom;
         p_x_planned_matrl_tbl(i).error_code            := l_temp_planned_matrl_tbl(i).error_code;
         p_x_planned_matrl_tbl(i).error_message         := l_temp_planned_matrl_tbl(i).error_message;

         IF (l_log_statement >= l_log_current_level)THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'After Assign, Sch Mat Id : ' || p_x_planned_matrl_tbl(i).schedule_material_id ||
                           ', Quantity Available : ' || p_x_planned_matrl_tbl(i).quantity_available ||
                           ', Scheduled Quantity : ' || p_x_planned_matrl_tbl(i).scheduled_date ||
                           ', Error Code : ' || p_x_planned_matrl_tbl(i).error_code ||
                           ', Error Message : ' || p_x_planned_matrl_tbl(i).error_message);
        END IF;
     END IF;
  END LOOP;
 END IF;

   -- Standard check of p_commit
   IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;

 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Schedule_Planned_Matrls;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                 p_count => l_msg_count,
                                 p_data  => l_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Schedule_Planned_Matrls;
      X_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                 p_count => l_msg_count,
                                 p_data  => l_msg_data);

   WHEN OTHERS THEN
      ROLLBACK TO Schedule_Planned_Matrls;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         fnd_msg_pub.add_exc_msg(p_pkg_name       =>  'AHL_LTP_MATRL_AVAL_PVT',
                                 p_procedure_name =>  'SCHEDULE_PLANNED_MATRLS',
                                 p_error_text     => SUBSTR(SQLERRM,1,240));
      END IF;
      FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                 p_count => l_msg_count,
                                 p_data  => l_msg_data);

 END Schedule_Planned_Matrls;
--
-- Start of Comments --
--  Procedure name    : Schedule_All_Materials
--  Type        : Public
--  Function    : This procedure calls ATP to schedule planned materials for a visit
--                for Routine jobs derived requested quantity and task start date
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Schedule_All_Materials Parameters :
--        p_visit_id                    IN       Number,Required
--         List of item attributes associated to visit task
--
PROCEDURE Schedule_All_Materials (
   p_api_version       IN     NUMBER,
   p_init_msg_list     IN     VARCHAR2 := FND_API.g_false,
   p_commit            IN     VARCHAR2 := FND_API.g_false,
   p_validation_level  IN     NUMBER   := FND_API.g_valid_level_full,
   p_visit_id          IN     NUMBER,
   x_planned_matrl_tbl    OUT NOCOPY AHL_LTP_MATRL_AVAL_PUB.Planned_Matrl_Tbl,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2)
 IS

-- yazhou 03-JUL-2006 starts
-- bug fix#5303378

CURSOR Get_Visit_Task_Matrl_Cur (C_VISIT_ID IN NUMBER) IS
 SELECT schm.scheduled_material_id,
        schm.organization_id,
        schm.visit_id,
        schm.visit_task_id,
        schm.material_request_type,
        schm.uom,
        schm.inventory_item_id,
        schm.requested_date,
        schm.requested_quantity,
        mtl.concatenated_segments
 FROM ahl_schedule_materials schm,
      mtl_system_items_vl mtl
 WHERE schm.inventory_item_id = mtl.inventory_item_id
  AND schm.organization_id = mtl.organization_id
  --SKPATHAK :: Bug 8429732 :: 17-APR-2009
  --Commented out the condition (requested_quantity <> 0)
  /*AND schm.requested_quantity <> 0*/
  AND NVL(schm.status, 'X') <> 'IN-SERVICE' --Added by sowsubra for Issue 105
  AND schm.visit_id = C_VISIT_ID;
-- yazhou 03-JUL-2006 ends

  --Standard local variables
  l_api_name      CONSTANT VARCHAR2(30)  := 'Schedule_All_Materials';
  L_DEBUG_KEY     CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
  l_api_version   CONSTANT NUMBER        := 1.0;
  l_return_status          VARCHAR2(1);
  l_msg_data               VARCHAR2(2000);
  l_msg_count              NUMBER;
  --
  l_planned_matrl_tbl     AHL_LTP_MATRL_AVAL_PUB.Planned_Matrl_Tbl;
  l_Visit_Task_Matrl_Rec  Get_Visit_Task_Matrl_Cur%ROWTYPE;
  i NUMBER;
 BEGIN

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Visit Id = ' || p_visit_id);
   END IF;
   -- Standard Start of API savepoint
   SAVEPOINT Schedule_All_Materials;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      l_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF p_visit_id IS NOT NULL THEN
      OPEN Get_Visit_Task_Matrl_Cur(p_visit_id);
      i := 1;
      LOOP
         FETCH Get_Visit_Task_Matrl_Cur INTO l_Visit_Task_Matrl_Rec;
         EXIT WHEN Get_Visit_Task_Matrl_Cur%NOTFOUND;
         --Assign to table
         l_planned_matrl_tbl(i).visit_id             := l_Visit_Task_Matrl_Rec.visit_id;
         l_planned_matrl_tbl(i).visit_task_id        := l_Visit_Task_Matrl_Rec.visit_task_id;
         l_planned_matrl_tbl(i).schedule_material_id := l_Visit_Task_Matrl_Rec.scheduled_material_id;
         l_planned_matrl_tbl(i).inventory_item_id    := l_Visit_Task_Matrl_Rec.inventory_item_id;
         l_planned_matrl_tbl(i).item_description     := l_Visit_Task_Matrl_Rec.concatenated_segments;
         l_planned_matrl_tbl(i).organization_id      := l_Visit_Task_Matrl_Rec.organization_id;
         l_planned_matrl_tbl(i).primary_uom_code     := l_Visit_Task_Matrl_Rec.uom;
         l_planned_matrl_tbl(i).requested_date       := l_Visit_Task_Matrl_Rec.requested_date;
         l_planned_matrl_tbl(i).required_quantity    := l_Visit_Task_Matrl_Rec.requested_quantity;
         i := i + 1;
      END LOOP;
      CLOSE Get_Visit_Task_Matrl_Cur;
   END IF; --Visit not null

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Before calling Call ATP No of Records'||l_planned_matrl_tbl.COUNT);
   END IF;

   IF l_planned_matrl_tbl.COUNT > 0 THEN
      -- Call local procedure which calls atp Api
      schedule_planned_matrls
        (p_api_version         => p_api_version,
         p_init_msg_list       => p_init_msg_list,
         p_validation_level    => p_validation_level,
         p_x_planned_matrl_tbl => l_Planned_Matrl_Tbl,
         x_return_status       => l_return_status,
         x_msg_count           => l_msg_count,
         x_msg_data            => l_msg_data);
   END IF;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'After calling Call ATP, Return Status : '|| l_return_status);
   END IF;

   -- Check Error Message stack.
   IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
       l_msg_count := FND_MSG_PUB.count_msg;
       IF l_msg_count > 0 THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
   END IF;
   --Assign to out variable
   IF l_Planned_Matrl_Tbl.COUNT > 0 THEN
      FOR i IN l_Planned_Matrl_Tbl.FIRST..l_Planned_Matrl_Tbl.LAST
      LOOP
         x_planned_matrl_tbl(i).schedule_material_id  := l_Planned_Matrl_Tbl(i).schedule_material_id;
         x_Planned_Matrl_Tbl(i).object_version_number := l_Planned_Matrl_Tbl(i).object_version_number;
         x_Planned_Matrl_Tbl(i).inventory_item_id     := l_Planned_Matrl_Tbl(i).inventory_item_id;
         x_Planned_Matrl_Tbl(i).item_description      := l_Planned_Matrl_Tbl(i).item_description;
         x_Planned_Matrl_Tbl(i).visit_id              := l_Planned_Matrl_Tbl(i).visit_id;
         x_Planned_Matrl_Tbl(i).visit_task_id         := l_Planned_Matrl_Tbl(i).visit_task_id;
         x_Planned_Matrl_Tbl(i).task_name             := l_Planned_Matrl_Tbl(i).task_name;
         -- anraj added
         x_Planned_Matrl_Tbl(i).task_status_code      := l_Planned_Matrl_Tbl(i).task_status_code;
         x_Planned_Matrl_Tbl(i).task_status_meaning   := l_Planned_Matrl_Tbl(i).task_status_meaning;

         --SKPATHAK :: Bug 8392521 :: 02-APR-2009 :: Included the scheduled_date in the out param
         x_Planned_Matrl_Tbl(i).scheduled_date        := l_Planned_Matrl_Tbl(i).scheduled_date;
         x_Planned_Matrl_Tbl(i).requested_date        := l_Planned_Matrl_Tbl(i).requested_date;
         x_Planned_Matrl_Tbl(i).required_quantity     := l_Planned_Matrl_Tbl(i).required_quantity;
         x_Planned_Matrl_Tbl(i).quantity_available    := l_Planned_Matrl_Tbl(i).quantity_available;
         -- x_Planned_Matrl_Tbl(i).scheduled_quantity := l_Planned_Matrl_Tbl(i).scheduled_quantity;
         x_Planned_Matrl_Tbl(i).primary_uom           := l_Planned_Matrl_Tbl(i).primary_uom;
         x_Planned_Matrl_Tbl(i).error_code            := l_Planned_Matrl_Tbl(i).error_code;
         x_Planned_Matrl_Tbl(i).error_message         := l_Planned_Matrl_Tbl(i).error_message;

         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'After Assign, Sch Mat Id : ' || x_planned_matrl_tbl(i).schedule_material_id ||
                           ', Quantity Available : ' || x_planned_matrl_tbl(i).quantity_available ||
                           ', Scheduled Quantity : ' || x_planned_matrl_tbl(i).scheduled_date ||
                           ', Error Code : ' || x_planned_matrl_tbl(i).error_code ||
                           ', Error Message : ' || x_planned_matrl_tbl(i).error_message);
         END IF;
      END LOOP;
   END IF;
   -- Standard check of p_commit
   IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;

 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Schedule_All_Materials;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                 p_count => l_msg_count,
                                 p_data  => l_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Schedule_All_Materials;
      X_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                 p_count => l_msg_count,
                                 p_data  => l_msg_data);

   WHEN OTHERS THEN
      ROLLBACK TO Schedule_All_Materials;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
      fnd_msg_pub.add_exc_msg(p_pkg_name        => 'AHL_LTP_MATRL_AVAL_PVT',
                              p_procedure_name  => 'SCHEDULE_ALL_MATERIALS',
                              p_error_text      => SUBSTR(SQLERRM,1,240));
      END IF;
      FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                 p_count => l_msg_count,
                                 p_data  => l_msg_data);

 END Schedule_All_Materials;

END AHL_LTP_MATRL_AVAL_PVT;

/
