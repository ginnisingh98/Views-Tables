--------------------------------------------------------
--  DDL for Package Body AHL_LTP_REQST_MATRL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_LTP_REQST_MATRL_PVT" AS
/* $Header: AHLVRMTB.pls 120.22.12010000.4 2010/04/20 06:38:00 skpathak ship $ */
--
G_PKG_NAME  VARCHAR2(30)  := 'AHL_LTP_REQST_MATRL_PVT';
G_DEBUG     VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;

------------------------------------
-- Common constants and variables --
------------------------------------
l_log_current_level     NUMBER      := fnd_log.g_current_runtime_level;
l_log_statement         NUMBER      := fnd_log.level_statement;
l_log_procedure         NUMBER      := fnd_log.level_procedure;
l_log_error             NUMBER      := fnd_log.level_error;
l_log_unexpected        NUMBER      := fnd_log.level_unexpected;
-----------------------------------------------------------------

--  Definition of private procedure.
--
PROCEDURE Modify_Visit_Reservations (
   p_visit_id                IN    NUMBER,
   x_return_status             OUT NOCOPY VARCHAR2);

-- SKPATHAK :: Bug 8604722 :: 04-MAR-2010 :: START
TYPE dff_default_values_type IS RECORD
(
  ATTRIBUTE_CATEGORY        VARCHAR2(30),
  ATTRIBUTE1                VARCHAR2(150),
  ATTRIBUTE2                VARCHAR2(150),
  ATTRIBUTE3                VARCHAR2(150),
  ATTRIBUTE4                VARCHAR2(150),
  ATTRIBUTE5                VARCHAR2(150),
  ATTRIBUTE6                VARCHAR2(150),
  ATTRIBUTE7                VARCHAR2(150),
  ATTRIBUTE8                VARCHAR2(150),
  ATTRIBUTE9                VARCHAR2(150),
  ATTRIBUTE10               VARCHAR2(150),
  ATTRIBUTE11               VARCHAR2(150),
  ATTRIBUTE12               VARCHAR2(150),
  ATTRIBUTE13               VARCHAR2(150),
  ATTRIBUTE14               VARCHAR2(150),
  ATTRIBUTE15               VARCHAR2(150)
);

PROCEDURE Get_DFF_Default_Values (
   flexfield_name       IN         fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE,
   context_code         IN         VARCHAR2,
   flex_fields_defaults OUT NOCOPY dff_default_values_type);
-- SKPATHAK :: Bug 8604722 :: 04-MAR-2010 :: END

-- PROCEDURE
-- anraj added
Procedure Unschedule_Visit_Materials (
      p_api_version                 IN      NUMBER,
      p_init_msg_list               IN      VARCHAR2  := FND_API.g_false,
      p_commit                      IN      VARCHAR2  := FND_API.g_false,
      p_validation_level            IN      NUMBER    := FND_API.g_valid_level_full,
      p_visit_id                    IN       NUMBER,
      x_return_status               OUT NOCOPY VARCHAR2,
      x_msg_count                   OUT NOCOPY NUMBER,
      x_msg_data                    OUT NOCOPY VARCHAR2
)
IS
   CURSOR c_sch_mat_cur (c_visit_id IN NUMBER)
   IS
      SELECT   scheduled_material_id,
               object_version_number
      FROM     ahl_schedule_materials
      WHERE    visit_id = c_visit_id;

   CURSOR c_visit_task_matrl_cur(c_sch_mat_id IN NUMBER)
   IS
      SELECT   scheduled_date,scheduled_quantity
      FROM     ahl_visit_task_matrl_v
      WHERE    schedule_material_id = c_sch_mat_id;

   l_api_name        CONSTANT VARCHAR2(30) := 'Unschedule_Visit_Materials';
   l_api_version     CONSTANT NUMBER       := 1.0;
   l_msg_count                NUMBER;
   l_return_status            VARCHAR2(1);
   l_msg_data                 VARCHAR2(2000);
   l_dummy                    NUMBER;
   /*l_rowid                    VARCHAR2(30);
   l_organization_id          NUMBER;
   l_department_id            NUMBER;
   l_visit_id                 NUMBER;*/
   l_object_version_number    NUMBER;
   /* l_start_date_time          DATE;
   l_space_assignment_id      NUMBER;
   l_space_version_number     NUMBER;
   l_visit_status_code        VARCHAR2(30);
   l_meaning                  VARCHAR2(80);*/
   l_schedule_material_id     NUMBER;
   l_scheduled_date           DATE;
   l_scheduled_quantity       NUMBER;

   /*_visit_tbl          AHL_VWP_VISITS_PVT.Visit_Tbl_Type;
   i           NUMBER := 0;
   l_visit_name               VARCHAR2(80);
   */
BEGIN
   --------------------Initialize ----------------------------------
   -- Standard Start of API savepoint
   SAVEPOINT unschedule_visit;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'enter AHL_LTP_REQST_MATRL_PVT.Unschedule_Visit_Materials','+SPANT+');
   END IF;
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
   --Check for material scheduling
   OPEN c_sch_mat_cur(p_visit_id);
   LOOP
      FETCH c_sch_mat_cur INTO l_schedule_material_id, l_object_version_number;
      EXIT WHEN c_sch_mat_cur%NOTFOUND;
      IF l_schedule_material_id IS NOT NULL THEN
         --Check for Item scheduled
         OPEN c_visit_task_matrl_cur(l_schedule_material_id);
         FETCH c_visit_task_matrl_cur INTO l_scheduled_date,l_scheduled_quantity;
         IF l_scheduled_date IS NOT NULL THEN
            Fnd_Message.SET_NAME('AHL','AHL_LTP_MRP_SCHEDUl_ITEM');
            Fnd_Msg_Pub.ADD;
            CLOSE c_visit_task_matrl_cur;
            RAISE Fnd_Api.G_EXC_ERROR;
         ELSE
            UPDATE ahl_schedule_materials
            SET requested_quantity = 0,
                   status = 'DELETED',
               object_version_number = l_object_version_number + 1,
               last_update_date      = SYSDATE,
               last_updated_by       = Fnd_Global.user_id,
               last_update_login     = Fnd_Global.login_id
            WHERE scheduled_material_id = l_schedule_material_id;
          --
         END IF;  --Scheduled date
         CLOSE c_visit_task_matrl_cur;
      END IF;-- Scheduled mat id
   END LOOP;
   CLOSE c_sch_mat_cur;

   -- Serial Number reservation Enh.
   -- When a Visit is unscheduled, all the reservations made for the Visit should also be deleted
   AHL_RSV_RESERVATIONS_PVT.DELETE_VISIT_RESERVATIONS(
                  X_RETURN_STATUS => X_RETURN_STATUS,
                  P_VISIT_ID      => p_visit_id);
   IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_statement,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Remove_Visit_Task_Matrls',
         ' After calling AHL_RSV_RESERVATIONS_PVT.DELETE_VISIT_RESERVATIONS ErrorMessage Status : ' || X_RETURN_STATUS
      );
   END IF;

   IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE Fnd_Api.g_exc_error;
   END IF;

   IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO unschedule_visit;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
      IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
         AHL_DEBUG_PUB.debug( 'AHL_LTP_REQST_MATRL_PVT.Unschedule_Visit_Materials','+SPANT+');
         -- Check if API is called in debug mode. If yes, disable debug.
         AHL_DEBUG_PUB.disable_debug;
      END IF;
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO unschedule_visit;
      X_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
      IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
              x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        AHL_DEBUG_PUB.debug( 'AHL_LTP_REQST_MATRL_PVT.Unschedule_Visit_Materials','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
      END IF;
   WHEN OTHERS THEN
      ROLLBACK TO unschedule_visit;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_REQST_MATRL_PVT',
                            p_procedure_name  =>  'Unschedule_Visit_Materials ',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
      END IF;
      FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
      IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'SQL ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_assign_pvt.Unschedule_Visit_Materials','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
    END IF;
END Unschedule_Visit_Materials;



-- PROCEDURE
--    Insert_Planned_Matrls
--
-- PURPOSE
--    Creates record in ahl_schedule_materials
--
-- PARAMETERS
--
-- NOTES

PROCEDURE Insert_Planned_Matrls(
  p_visit_id                   IN       NUMBER,
  p_visit_task_id              IN       NUMBER,
  p_task_start_date            IN       DATE,
  p_inventory_item_id          IN       NUMBER,
  p_requested_quantity         IN       NUMBER,
  p_uom_code                   IN       VARCHAR2,
  p_item_group_id              IN       NUMBER,
  p_rt_oper_material_id        IN       NUMBER,
  p_position_path_id           IN       NUMBER,
  p_relationship_id            IN       NUMBER,
  p_mr_route_id                IN       NUMBER default null,
  p_item_comp_detail_id        IN       NUMBER default null,
  p_inv_master_org_id          IN       NUMBER default null,
  x_return_status              OUT NOCOPY VARCHAR2,
  x_msg_count                  OUT NOCOPY NUMBER,
  x_msg_data                   OUT NOCOPY VARCHAR2
  )
IS
  -- Check for record already exists
  CURSOR check_matrl_cur (c_visit_id          IN NUMBER,
                          c_visit_task_id     IN NUMBER,
                          c_rt_oper_mat_id    IN NUMBER)
    IS
-- yazhou 17-May-2006 starts
-- bug fix#5232544

-- yazhou 03-JUL-2006 starts
-- bug fix#5303378

      SELECT scheduled_material_id
         FROM AHL_SCHEDULE_MATERIALS
       WHERE visit_id = c_visit_id
        AND visit_task_id = c_visit_task_id
--    AND requested_quantity <> 0
        AND NVL(status,'') = 'ACTIVE'
        AND rt_oper_material_id = c_rt_oper_mat_id;

-- yazhou 03-JUL-2006 ends

-- yazhou 17-May-2006 ends

  -- Cursor to get organization and schedule designator
  CURSOR get_org_cur (c_visit_id IN NUMBER)
      IS
    SELECT organization_id
      FROM ahl_visits_b
     WHERE visit_id = c_visit_id;
  --Get priority item from item associations
  CURSOR Get_Prior_Item_Cur(C_ITEM_GROUP_ID IN NUMBER,
                            C_ORG_ID        IN NUMBER)
    IS
   SELECT it.inventory_item_id,
          it.priority,
          it.uom_code,
        it.quantity
     FROM ahl_item_associations_vl it,
         mtl_system_items_vl mt
    WHERE it.inventory_item_id = mt.inventory_item_id
      AND item_group_id = C_ITEM_GROUP_ID
      AND mt.organization_id = C_ORG_ID
      -- Fix for bug # 4109330
      AND it.interchange_type_code in ('1-WAY INTERCHANGEABLE', '2-WAY INTERCHANGEABLE')
    ORDER BY priority;
  --Bug Fix #4104968
  CURSOR get_route_cur (c_visit_task_id IN NUMBER)
      IS
   SELECT route_id
     FROM ahl_mr_routes mr,
          ahl_visit_tasks_b vt
  WHERE mr.mr_route_id = vt.mr_route_id
    AND visit_task_id = c_visit_task_id;
  --Modifed the cursor for Bug #4104968
  -- Cursor to get operation sequence and operation id
  CURSOR get_oper_seq_cur (c_rt_oper_mat_id IN NUMBER,
                           c_route_id       IN NUMBER)
      IS
    SELECT ro.step,
          ro.operation_id,
         ro.concatenated_segments
      FROM ahl_route_operations_v ro,
          ahl_rt_oper_materials rm
     WHERE ro.operation_id = rm.object_id
      AND ro.route_id = c_route_id
       AND rm.rt_oper_material_id = c_rt_oper_mat_id
       AND rm.association_type_code = 'OPERATION';
  -- Inventory item should exists in visit org
   CURSOR Check_item_org (C_ITEM_ID IN NUMBER,
                          C_ORG_ID  IN NUMBER)
     IS
     SELECT inventory_item_id,
            primary_uom_code
       FROM mtl_system_items_vl
     WHERE inventory_item_id = C_ITEM_ID
       AND organization_id = C_ORG_ID;
  --Get quanity from rt oper materisl if null
  CURSOR Quantity_cur (c_rt_oper_mat_id IN NUMBER)
    IS
    SELECT quantity,
           in_service, --B5865210 - sowsubra
           replace_percent,
           association_type_code
      FROM ahl_rt_oper_materials
  WHERE rt_oper_material_id = c_rt_oper_mat_id;

    --Standard local variables
    l_api_name     CONSTANT VARCHAR2(30)   := 'Update_Planned_Materials';
    l_api_version  CONSTANT NUMBER          := 1.0;
    l_msg_data              VARCHAR2(2000);
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_init_msg_list         VARCHAR2(10)  := FND_API.g_false;
    --
    l_schedule_material_id  NUMBER;
    l_dummy                 NUMBER;
    l_organization_id       NUMBER;
    l_operation_id          NUMBER;
    l_inventory_item_id     NUMBER := p_inventory_item_id;
    l_requested_quantity    NUMBER := p_requested_quantity;
    l_inventory_org_item_id NUMBER;
    l_uom_code              VARCHAR2(3) := p_uom_code;
    l_step                  NUMBER;
    l_operation_code        VARCHAR2(80);
    l_prim_uom_code         VARCHAR2(3) := null;
    l_prim_quantity         NUMBER;
    l_replace_percent       NUMBER;
    l_assoc_type_code       VARCHAR2(30);
    l_sched_prim_quantity   NUMBER; -- yazhou 04Aug2005
    l_route_id              NUMBER;
    --
    l_task_type_code        VARCHAR2(30);
    l_material_request_type VARCHAR2(30);
    l_Prior_Item_Rec        Get_Prior_Item_Cur%ROWTYPE;
    l_isInservice           AHL_RT_OPER_MATERIALS.IN_SERVICE%TYPE; --Added by sowsubra for Issue 105
    l_mat_status            AHL_SCHEDULE_MATERIALS.STATUS%TYPE; --Added by sowsubra for Issue 105
    -- SKPATHAK :: Bug 8604722 :: 04-MAR-2010
    l_default_dff_values    dff_default_values_type;


 BEGIN

   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_procedure,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Insert_Planned_Matrls',
         'At the start of PLSQL procedure'
      );
     END IF;
     -- Standard start of API savepoint
     SAVEPOINT Insert_Planned_Matrls;
      -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean( l_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;
     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     --
     IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
         'Request for Create Planned Material for Visit Id : '|| p_visit_id
      );

     END IF;

    --Get the sequence number
    SELECT ahl_schedule_materials_s.nextval INTO l_schedule_material_id
          FROM DUAL;
  --Check for record exists
  OPEN check_matrl_cur(p_visit_id,p_visit_task_id,p_rt_oper_material_id);
  FETCH check_matrl_cur INTO l_dummy;
  CLOSE check_matrl_cur;
  --Get visit Organization
  OPEN get_org_cur(p_visit_id);
  FETCH get_org_cur INTO l_organization_id;
  CLOSE get_org_cur;
  --Get Route id
  OPEN get_route_cur(p_visit_task_id);
  FETCH get_route_cur INTO l_route_id;
  CLOSE get_route_cur;
  --During org change in schedule visits UI
  IF p_inv_master_org_id IS NOT NULL THEN
     l_organization_id := p_inv_master_org_id;
  END IF;
  -- Get operation sequence
   OPEN get_oper_seq_cur(p_rt_oper_material_id,l_route_id);
   FETCH get_oper_seq_cur INTO l_step,l_operation_id,l_operation_code;
   CLOSE get_oper_seq_cur;
  --
  IF ((p_item_comp_detail_id IS NOT NULL AND p_item_group_id IS NOT NULL )
      OR
     (p_item_comp_detail_id IS NULL AND p_item_group_id IS NOT NULL ))THEN
    --Get from item associations
   OPEN Get_Prior_Item_Cur(p_item_group_id,l_organization_id);
   FETCH Get_Prior_Item_Cur INTO l_Prior_Item_rec;
   CLOSE Get_Prior_Item_Cur;
    --Assign returned values
   l_inventory_item_id  := l_prior_Item_rec.inventory_item_id;

   ELSE
     IF (p_position_path_id IS NOT NULL AND p_item_group_id IS NOT NULL ) THEN
    --Get from item associations
   OPEN Get_Prior_Item_Cur(p_item_group_id,l_organization_id);
   FETCH Get_Prior_Item_Cur INTO l_Prior_Item_rec;
   CLOSE Get_Prior_Item_Cur;
    --Assign returned values
   l_inventory_item_id  := l_prior_Item_rec.inventory_item_id;
   END IF;

  END IF;
  --Check for item exists in inventory Ord
  OPEN Check_item_org(l_inventory_item_id,l_organization_id);
  FETCH Check_item_org INTO l_inventory_org_item_id,l_prim_uom_code;
  CLOSE Check_item_org;

  --Check for primayr UOM COde
  IF l_uom_code <> l_prim_uom_code
  THEN

   IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
         'Primary Uom Code : '|| l_prim_uom_code
      );
      fnd_log.string
      (
         l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
         'Source Uom Code : '|| l_uom_code
      );

     END IF;

    -- yazhou 04Aug2005 Starts
    l_prim_quantity := AHL_LTP_MTL_REQ_PVT.Get_Primary_UOM_Qty
                      (l_inventory_item_id, l_uom_code, l_requested_quantity);

     -- Required to check the UOM Conversion exists in mtl_units_of_measure
     IF l_prim_quantity IS NULL THEN
        FND_MESSAGE.Set_Name( 'AHL','AHL_LTP_UOM_CONV_NOT_EXIST' );
        FND_MESSAGE.Set_Token('FUOM', l_uom_code);
        FND_MESSAGE.Set_Token('TUOM', l_prim_uom_code);
        FND_MSG_PUB.add;
        RAISE  FND_API.G_EXC_ERROR;
     END IF;

    l_sched_prim_quantity := l_prim_quantity;

    -- yazhou 04Aug2005 Ends

   --sowsubra
   --changes done to collect inservice material
   OPEN Quantity_cur(p_rt_oper_material_id);
   FETCH Quantity_cur INTO l_requested_quantity,l_isInservice,l_replace_percent,l_assoc_type_code;
   CLOSE Quantity_cur;

    -- For Bug # 4007058
--    IF l_assoc_type_code = 'DISPOSITION' AND NVL(l_replace_percent,0) < 100 THEN
    IF NVL(l_replace_percent,100) < 100 THEN
        l_prim_quantity := 0;
    END IF;

    --Added by sowsubra for Issue 105
    IF NVL(l_isInservice,'N') = 'N' THEN
      l_mat_status := 'ACTIVE';
    ELSE
      l_mat_status := 'IN-SERVICE';
    END IF;

  ELSE

   IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
         'ELSE Primary Uom Code : '|| l_prim_uom_code
      );
      fnd_log.string
      (
         l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
         'ELSE Source Uom Code : '|| l_uom_code
      );
      fnd_log.string
      (
         l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
         'ELSE Requested quantity : '|| l_requested_quantity || ' -'||l_requested_quantity
      );

     END IF;

    -- yazhou 04Aug2005 Starts

     l_sched_prim_quantity := l_requested_quantity;

    --sowsubra
    --changes done to collect inservice material
    OPEN Quantity_cur(p_rt_oper_material_id);
    FETCH Quantity_cur INTO l_requested_quantity,l_isInservice,l_replace_percent,l_assoc_type_code;
    CLOSE Quantity_cur;
    -- else passsed value
    -- For Bug # 4007058
--    IF l_assoc_type_code = 'DISPOSITION' AND NVL(l_replace_percent,0) < 100 THEN
    IF NVL(l_replace_percent,100) < 100 THEN
      l_prim_quantity := 0;
    ELSE
      l_prim_quantity := l_sched_prim_quantity;
    END IF;

    --Added by sowsubra for Issue 105
    IF NVL(l_isInservice,'N') = 'N' THEN
      l_mat_status := 'ACTIVE';
    ELSE
      l_mat_status := 'IN-SERVICE';
    END IF;

    -- yazhou 04Aug2005 Ends

  END IF;

  --Check for visit task type
  SELECT TASK_TYPE_CODE INTO l_task_type_code
         FROM ahl_visit_tasks_vl
    WHERE visit_task_id = p_visit_task_id;
  --From unplanned and Unassociated
   IF l_task_type_code IN ('UNPLANNED','UNASSOCIATED') THEN
      l_material_request_type := 'UNPLANNED';
   ELSE
      l_material_request_type := 'PLANNED';
   END IF;

     IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
         'Before Insert Schedule Materials for Visit Id : '|| p_visit_id
      );
      fnd_log.string
      (
         l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
         'Before Insert Schedule Materials for Visit Task Id : '|| p_visit_task_id
      );
      fnd_log.string
      (
         l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
         'Before Insert Schedule Materials for Schedule Material Id : '|| l_schedule_material_id
      );

     END IF;

  -- SKPATHAK :: Bug 8604722 :: 04-MAR-2010
  -- Get the default Material Requirement DFF values
  Get_DFF_Default_Values(flexfield_name       => 'Material Reqmt Flex Field',
                         context_code         => NULL,
                         flex_fields_defaults => l_default_dff_values);

  --  Insert the record into schedule materials
    IF (l_dummy IS NULL AND l_inventory_org_item_id IS NOT NULL )THEN
    INSERT INTO AHL_SCHEDULE_MATERIALS
       (SCHEDULED_MATERIAL_ID,
        OBJECT_VERSION_NUMBER,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        INVENTORY_ITEM_ID,
        SCHEDULE_DESIGNATOR,
        VISIT_ID,
        VISIT_START_DATE,
        VISIT_TASK_ID,
        ORGANIZATION_ID,
        SCHEDULED_DATE,
        REQUESTED_QUANTITY,
        REQUEST_ID,
        REQUESTED_DATE,
        SCHEDULED_QUANTITY,
        PROCESS_STATUS,
        ERROR_MESSAGE,
        TRANSACTION_ID,
        UOM,
        RT_OPER_MATERIAL_ID,
      OPERATION_CODE,
        ITEM_GROUP_ID,
        OPERATION_SEQUENCE,
        POSITION_PATH_ID,
        RELATIONSHIP_ID,
      MR_ROUTE_ID,
      MATERIAL_REQUEST_TYPE,
      STATUS,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15
      )
       VALUES
        (l_schedule_material_id,
         1,
         SYSDATE,
         fnd_global.user_id,
         SYSDATE,
         fnd_global.user_id,
         fnd_global.login_id,
         l_inventory_item_id,
         NULL,
         p_visit_id,
         NULL,
         p_visit_task_id,
         l_organization_id,
         NULL,
         l_prim_quantity,
         NULL,
         -- AnRaj: truncating Requested Date for Material Requirement based on discussions with PM
         trunc(p_task_start_date),
         l_sched_prim_quantity,  -- yazhou 04Aug2005
         NULL,
         NULL,
         NULL,
         l_uom_code,
         p_rt_oper_material_id,
         l_operation_code,
         p_item_group_id,
         l_step,
         p_position_path_id,
         p_relationship_id,
         p_mr_route_id,
         l_material_request_type,
         l_mat_status, --Added by sowsubra for Issue 105
         -- SKPATHAK :: Bug 8604722 :: 04-MAR-2010 :: START
         l_default_dff_values.ATTRIBUTE_CATEGORY,
         l_default_dff_values.ATTRIBUTE1,
         l_default_dff_values.ATTRIBUTE2,
         l_default_dff_values.ATTRIBUTE3,
         l_default_dff_values.ATTRIBUTE4,
         l_default_dff_values.ATTRIBUTE5,
         l_default_dff_values.ATTRIBUTE6,
         l_default_dff_values.ATTRIBUTE7,
         l_default_dff_values.ATTRIBUTE8,
         l_default_dff_values.ATTRIBUTE9,
         l_default_dff_values.ATTRIBUTE10,
         l_default_dff_values.ATTRIBUTE11,
         l_default_dff_values.ATTRIBUTE12,
         l_default_dff_values.ATTRIBUTE13,
         l_default_dff_values.ATTRIBUTE14,
         l_default_dff_values.ATTRIBUTE15);
         -- SKPATHAK :: Bug 8604722 :: 04-MAR-2010 :: END
      END IF; --Record doesnt exist

    -- Check Error Message stack.
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;

     IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_procedure,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Insert Planned Matrls.end',
         'At the end of PLSQL procedure'
      );
     END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO Insert_Planned_Matrls;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Insert_Planned_Matrls;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Insert_Planned_Matrls;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'INSERT_PLANNED_MATRLS',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);


 END Insert_Planned_Matrls;

-- Start of Comments --
--  Procedure name    : Update_Planned_Materials
--  Type        : Private
--  Function    : This procedure Updates Planned materials information associated to scheduled
--                visit, which are defined at Route Operation and Disposition level
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
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Update_Planned_Materials Parameters :
--       p_planned_materials_tbl          IN   Planned_Materials_Tbl,Required
--
--
PROCEDURE Update_Planned_Materials (
   p_api_version             IN    NUMBER,
   p_init_msg_list           IN    VARCHAR2  := FND_API.g_false,
   p_commit                  IN    VARCHAR2  := FND_API.g_false,
   p_validation_level        IN    NUMBER    := FND_API.g_valid_level_full,
   p_planned_materials_tbl   IN    ahl_ltp_reqst_matrl_pub.Planned_Materials_Tbl,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2)

  IS

   CURSOR Get_Planned_Items_cur (c_sched_mat_id IN NUMBER)
    IS
     SELECT scheduled_material_id,
      object_version_number,
      inventory_item_id,
      requested_quantity,
      visit_task_id,
      organization_id,
      completed_quantity,
      requested_date,
      visit_id
     FROM ahl_schedule_materials
    WHERE scheduled_material_id = c_sched_mat_id;

   CURSOR Get_Inv_Item_cur (c_item_desc IN VARCHAR2,
                            c_org_id    IN NUMBER)
    IS
     SELECT inventory_item_id
     FROM mtl_system_items_vl
    WHERE concatenated_segments = c_item_desc
      AND organization_id = c_org_id;

-- Serial Number Resrvation Change Starts
   CURSOR Get_Visit_Dates_cur (c_visit_id  IN NUMBER)
    IS
     SELECT start_date_time, close_date_time
     FROM ahl_visits_b
    WHERE visit_id = c_visit_id;

-- Serial Number Resrvation Change ends

    --Standard local variables
    l_api_name     CONSTANT   VARCHAR2(30)   := 'Update_Planned_Materials';
    l_api_version CONSTANT NUMBER          := 1.0;
    l_msg_data             VARCHAR2(2000);
    l_return_status        VARCHAR2(1);
    l_msg_count             NUMBER;
    --
   l_planned_materials_tbl   ahl_ltp_reqst_matrl_pub.planned_materials_tbl := p_planned_materials_tbl;
   l_Planned_Items_rec       Get_Planned_Items_cur%ROWTYPE;

    l_rsvd_quantity NUMBER;

-- Serial Number Resrvation Change Starts
   l_visit_start_date  DATE;
   l_visit_end_date    DATE;
-- Serial Number Resrvation Change ends

 BEGIN

   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_procedure,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Update_Planned_Materials',
         'At the start of PLSQL procedure'
      );
     END IF;
     -- Standard start of API savepoint
     SAVEPOINT Update_Planned_Materials;
      -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean( p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;
     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     --
     IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
         'Request for Update Material Number of Records : '|| l_planned_materials_tbl.COUNT
      );

     END IF;

     IF l_planned_materials_tbl.COUNT > 0 THEN
    FOR i IN l_planned_materials_tbl.FIRST..l_planned_materials_tbl.LAST
    LOOP
       --Check for Schedule material Record exists
      IF (l_planned_materials_tbl(i).schedule_material_id IS NOT NULL AND
          l_planned_materials_tbl(i).schedule_material_id <> FND_API.G_MISS_NUM ) THEN
              --
          OPEN Get_Planned_Items_cur(l_planned_materials_tbl(i).schedule_material_id);
          FETCH Get_Planned_Items_cur INTO l_Planned_Items_rec;
              IF Get_Planned_Items_cur%NOTFOUND THEN
                 FND_MESSAGE.set_name( 'AHL','AHL_LTP_SCHE_ID_INVALID' );
                 FND_MSG_PUB.add;
               IF (l_log_error >= l_log_current_level)THEN
                  fnd_log.string
              (
                l_log_error,
                   'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Schedule Material id not found in ahl_schedule_materials table'
                );
               END IF;
               CLOSE Get_Planned_Items_cur;
               RAISE  FND_API.G_EXC_ERROR;
            END IF;
            CLOSE Get_Planned_Items_cur;
        END IF;

        --Check for Record has been modified by someother user
      IF (l_planned_materials_tbl(i).object_version_number IS NOT NULL AND
          l_planned_materials_tbl(i).object_version_number <> FND_API.G_MISS_NUM ) THEN
          --
         IF (l_planned_materials_tbl(i).object_version_number <> l_Planned_Items_rec.object_version_number )
         THEN
                FND_MESSAGE.set_name( 'AHL','AHL_LTP_RECORD_INVALID' );
                FND_MSG_PUB.add;
               IF (l_log_error >= l_log_current_level)THEN
                  fnd_log.string
              (
                l_log_error,
                   'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Schedule Material Record has been modified by someother user'
                );
               END IF;
               RAISE  FND_API.G_EXC_ERROR;
         END IF;
         END IF;
        --Convert item description to item id
      IF (l_planned_materials_tbl(i).item_description IS NOT NULL AND
          l_planned_materials_tbl(i).item_description <> FND_API.G_MISS_CHAR ) THEN
          --
         OPEN Get_Inv_Item_cur(l_planned_materials_tbl(i).item_description,
                             l_planned_items_rec.organization_id);
        FETCH Get_Inv_Item_cur INTO l_planned_materials_tbl(i).inventory_item_id;
          IF Get_Inv_Item_cur%NOTFOUND THEN
                FND_MESSAGE.set_name( 'AHL','AHL_LTP_ITEM_INVALID' );
                FND_MSG_PUB.add;
               IF (l_log_error >= l_log_current_level)THEN
                  fnd_log.string
              (
                l_log_error,
                   'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Inventory Item doesnt exist in Mtl System Items Vl'
                );
               END IF;
               CLOSE Get_Inv_Item_Cur;
            RAISE  FND_API.G_EXC_ERROR;
            END IF;
        CLOSE Get_Inv_Item_cur;
         END IF;

         -- AnRaj: Moved this code down, after the id in l_planned_materials_tbl has been populated
         -- Serial Number Reservation Enhancement Changes Start.
         -- AnRaj: Changed the WHERE and FROM clause adding join with ahl_schedule_materials, for Performance improvement
         IF l_planned_materials_tbl(i).inventory_item_id <> l_Planned_Items_rec.inventory_item_id
         THEN
            SELECT   SUM(MR.PRIMARY_RESERVATION_QUANTITY)
            INTO     l_rsvd_quantity
            FROM     mtl_reservations MR,
                     ahl_schedule_materials SM
            WHERE    MR.DEMAND_SOURCE_LINE_DETAIL = l_planned_materials_tbl(i).schedule_material_id
            AND      MR.external_source_code = 'AHL'
            AND      MR.demand_source_line_detail = SM.scheduled_material_id
            AND      MR.organization_id = SM.organization_id
            AND      MR.requirement_date = SM.requested_date
            AND      MR.inventory_item_id = SM.inventory_item_id;

            -- This is based on   PRIMARY_RESERVATION_QUANTITY is not null in mtl_reservations
            IF l_rsvd_quantity IS NOT NULL THEN
               FND_MESSAGE.set_name( 'AHL','AHL_LTP_ITEM_RSV_EXISTS' );
               -- Cannot change the item required because at least one reservation already exists for this item.
               FND_MSG_PUB.add;
               RAISE  FND_API.G_EXC_ERROR;
            END IF;
         END IF;
         -- Serial Number Reservation Enhancement Changes Ends.

       -- Validation for requested quantity
      IF (l_planned_materials_tbl(i).quantity IS NOT NULL AND
           l_planned_materials_tbl(i).quantity <> FND_API.G_MISS_NUM) THEN

-- yazhou 03-JUL-2006 starts
-- bug fix#5303378
-- Will allow quantity to be changed to zero

            IF  l_planned_materials_tbl(i).quantity < 0 THEN

-- yazhou 03-JUL-2006 ends
              --
              Fnd_message.SET_NAME('AHL','AHL_LTP_QUANTITY_INVALID');
              Fnd_Msg_Pub.ADD;
              RAISE  FND_API.G_EXC_ERROR;
            END IF;

            -- Serial Number Reservation Enhancement Changes Starts.
            -- AnRaj: Changed the WHERE and FROM clause adding join with ahl_schedule_materials, for Performance improvement
            IF NVL(l_planned_materials_tbl(i).quantity,-9) <> NVL(l_Planned_Items_rec.requested_quantity,-99)
            THEN
               SELECT   SUM(MR.PRIMARY_RESERVATION_QUANTITY)
               INTO     l_rsvd_quantity
               FROM     mtl_reservations MR,
                        ahl_schedule_materials SM
               WHERE    MR.DEMAND_SOURCE_LINE_DETAIL = l_planned_materials_tbl(i).schedule_material_id
               AND      MR.external_source_code = 'AHL'
               AND      MR.demand_source_line_detail = SM.scheduled_material_id
               AND      MR.organization_id = SM.organization_id
               AND      MR.requirement_date = SM.requested_date
               AND      MR.inventory_item_id = SM.inventory_item_id;

               IF NVL((NVL(l_rsvd_quantity,0) + nvl(l_Planned_Items_rec.completed_quantity,0)),-9) > NVL(l_planned_materials_tbl(i).quantity,-9)
               THEN
                  Fnd_message.SET_NAME('AHL','AHL_LTP_QTY_EXCEEDS');
                  --Completed quantity plus reserved quantity exceeded scheduled quantity
                  Fnd_Msg_Pub.ADD;
                  RAISE  FND_API.G_EXC_ERROR;
               END IF;
            END IF;
      END IF;
      -- Serial Number Reservation Enhancement Changes Ends.
          -- Validation for requested date
          IF (l_planned_materials_tbl(i).requested_date IS NOT NULL AND
              l_planned_materials_tbl(i).requested_date <> FND_API.G_MISS_DATE) THEN
             IF  l_planned_materials_tbl(i).requested_date < trunc(sysdate) THEN
                --
               Fnd_message.SET_NAME('AHL','AHL_LTP_DATE_INVALID');
               Fnd_Msg_Pub.ADD;
               RAISE  FND_API.G_EXC_ERROR;

             END IF;

          -- Serial Number Reservation Enhancement Changes. Starts
          IF l_planned_materials_tbl(i).requested_date IS NOT NULL
              AND l_Planned_Items_rec.requested_date <> l_planned_materials_tbl(i).requested_date
          THEN

            -- New Required Date has to fall between Visit start date and Visit End Date
            OPEN Get_Visit_Dates_cur(l_planned_items_rec.visit_id);
           FETCH Get_Visit_Dates_cur into l_visit_start_date, l_visit_end_date;
           CLOSE Get_Visit_Dates_cur;

           IF (TRUNC(l_planned_materials_tbl(i).requested_date) < TRUNC(l_visit_start_date)) OR
               (l_visit_end_date is not NULL AND
              (TRUNC(l_planned_materials_tbl(i).requested_date) > TRUNC(l_visit_end_date))) THEN

                Fnd_message.SET_NAME('AHL','AHL_LTP_REQ_DATE_RANGE');
                  Fnd_Msg_Pub.ADD;
                  RAISE  FND_API.G_EXC_ERROR;

              END IF;

            AHL_RSV_RESERVATIONS_PVT.UPDATE_RESERVATION(
            P_API_VERSION               => 1.0,
            /*P_INIT_MSG_LIST
            P_COMMIT
            P_VALIDATION_LEVEL          */
            P_MODULE_TYPE               => NULL,
            X_RETURN_STATUS             => l_return_Status,
            X_MSG_COUNT                 => l_msg_count,
            X_MSG_DATA                  => X_MSG_DATA,
            P_SCHEDULED_MATERIAL_ID     => l_planned_materials_tbl(i).schedule_material_id,
            P_REQUESTED_DATE            => l_planned_materials_tbl(i).requested_date);
           END IF;

          IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_count := FND_MSG_PUB.count_msg;
             RAISE FND_API.G_EXC_ERROR;
           END IF;

-- Serial Number Reservation Enhancement Changes. Ends

        END IF;
         --
    END LOOP;
     END IF;
     -- Check Error Message stack.
     IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF;
     --
     IF l_planned_materials_tbl.COUNT > 0 THEN
    FOR i IN l_planned_materials_tbl.FIRST..l_planned_materials_tbl.LAST
    LOOP
       --
         IF l_planned_materials_tbl(i).schedule_material_id IS NOT NULL THEN
          --
            UPDATE ahl_schedule_materials
              SET inventory_item_id = l_planned_materials_tbl(i).inventory_item_id,
                 requested_quantity = l_planned_materials_tbl(i).quantity,
                -- AnRaj: truncating Requested Date for Material Requirement based on discussions with PM
                requested_date  = trunc(l_planned_materials_tbl(i).requested_date),
                object_version_number = l_planned_materials_tbl(i).object_version_number + 1
            WHERE scheduled_material_id = l_planned_materials_tbl(i).schedule_material_id;
          END IF;
       --
     END LOOP;
     END IF;
     -- Check Error Message stack.
     x_msg_count := FND_MSG_PUB.count_msg;
     IF x_msg_count > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
     END IF;

     -- Standard check of p_commit
     IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
     END IF;

     IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_procedure,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Update Planned Materials.end',
         'At the end of PLSQL procedure'
      );
     END IF;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO Update_Planned_Materials;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Update_Planned_Materials;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Update_Planned_Materials;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Update_Planned_Materials',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

  END Update_Planned_Materials;

--
-- Start of Comments --
--  Procedure name    : Create_Task_Materials
--  Type        : Private
--  Function    : This procedure Created Planned materials information associated to scheduled
--                visit, which are defined at Route Operation and Disposition level
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
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Create_Planned_Materials Parameters :
--       p_visit_id                     IN      NUMBER,Required
--
--
PROCEDURE Create_Task_Materials (
   p_api_version             IN    NUMBER,
   p_init_msg_list           IN    VARCHAR2  := FND_API.g_false,
   p_commit                  IN    VARCHAR2  := FND_API.g_false,
   p_validation_level        IN    NUMBER    := FND_API.g_valid_level_full,
   p_visit_id                IN    NUMBER,
   p_visit_task_id           IN    NUMBER := NULL,
   p_start_time              IN    DATE   := NULL,
   p_org_id                  IN    NUMBER := NULL,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2)

   IS
    --Get visit details
    /*B6271339 - sowsubra - Modified the where clause to filter the records based on visit task id alone*/
    CURSOR Get_Visit_Tasks_cur(c_visit_task_id IN NUMBER) IS
     SELECT vs.visit_id,
            vs.organization_id,
            vt.visit_task_id,
            vt.mr_route_id,
            vt.instance_id,
            vt.start_date_time
     FROM ahl_visits_b vs,
            ahl_visit_tasks_b vt
     WHERE vs.visit_id = vt.visit_id
     AND vt.visit_task_id = C_VISIT_TASK_ID;

    --Get Route details
    /*B6271339 - sowsubra - Modified the cursor to fetch only the route id*/
    CURSOR Get_Routes_cur(c_mr_route_id IN NUMBER)
    IS
     SELECT mr.route_id
     FROM ahl_mr_routes_app_v mr
     WHERE mr.mr_route_id = C_MR_ROUTE_ID;

   CURSOR Visit_Valid_Cur(c_visit_id IN NUMBER)
    IS
    SELECT 1
      FROM ahl_visits_vl
     WHERE visit_id = C_VISIT_ID
      AND (organization_id IS NULL
         OR start_date_time IS NULL);

    --Standard local variables
    l_api_name     CONSTANT   VARCHAR2(30)   := 'Create_Task_Materials';
    l_api_version CONSTANT NUMBER          := 1.0;
    l_msg_data             VARCHAR2(2000);
    l_return_status        VARCHAR2(1);
    l_msg_count             NUMBER;
   l_dummy                 NUMBER;
    --Variables for derieve start times
    l_visit_start_time         DATE := nvl(p_start_time,null);
   --
   l_route_id        NUMBER;
   l_instance_id     NUMBER;
   l_requirement_date DATE;
    l_visit_tasks_rec       Get_visit_tasks_cur%ROWTYPE;
    l_route_mtl_req_tbl     AHL_LTP_MTL_REQ_PVT.Route_Mtl_Req_Tbl_Type;

   BEGIN

   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_procedure,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Create_Task_Materials',
         'At the start of PLSQL procedure'
      );
     END IF;
     -- Standard start of API savepoint
     SAVEPOINT Create_Task_Materials;
      -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean( p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;
     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     --
     IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
         'Request for Create Task Materials for Visit Id : '|| p_visit_id
      );

     END IF;

     --Get visit details
    /*B6271339 - sowsubra - Modified the where clause to filter the records based on visit task id alone*/
    OPEN Get_visit_tasks_cur(p_visit_task_id);
    FETCH Get_visit_tasks_cur INTO l_visit_tasks_rec;
    CLOSE Get_visit_tasks_cur;

    IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_statement,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Create_Task_Materials',
         ' Visit Id: ' || p_visit_id
      );
      fnd_log.string
      (
         l_log_statement,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Create_Task_Materials',
         ' Organization Id: ' || l_visit_tasks_rec.organization_id
      );

     END IF;

     --Check for visit Org, Dept, Start date should be not null
     OPEN Visit_Valid_Cur(p_visit_id);
    FETCH Visit_Valid_Cur INTO l_dummy;
     CLOSE Visit_Valid_Cur;

     -- Derieve task start times
     IF (p_visit_id IS NOT NULL AND p_visit_id <> FND_API.G_MISS_NUM
        AND l_dummy IS NULL) THEN
      -- Derive task start time

   IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_statement,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Create_Task_Materials',
         ' Visit Task Id: ' || l_visit_tasks_rec.visit_task_id
      );
      fnd_log.string
      (
         l_log_statement,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Create_Task_Materials',
         ' Task Start Time: ' || l_visit_tasks_rec.start_date_time
      );
      fnd_log.string
      (
         l_log_statement,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Create_Task_Materials',
         ' Mr Route Id: ' || l_visit_tasks_rec.mr_route_id
      );

    END IF;
   -- Process all the items associated
   IF l_visit_tasks_rec.mr_route_id IS NOT NULL THEN
   -- Retrieve route and instance

     /*B6271339 - sowsubra - Modified the cursor to fetch only the route id*/
     OPEN  Get_Routes_cur(l_visit_tasks_rec.mr_route_id);
     FETCH Get_Routes_cur INTO l_route_id;
     CLOSE Get_Routes_cur;
    --
    IF (l_visit_tasks_rec.start_date_time IS NOT NULL AND TRUNC(l_visit_tasks_rec.start_date_time) < TRUNC(sysdate)
        ) THEN
       l_requirement_date := SYSDATE;
       --
     ELSE
           l_requirement_date := l_visit_tasks_rec.start_date_time;
      END IF;

     IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_statement,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Create_Task_Materials',
         ' Before Calling Get Route Mtl Req, Route Id: ' || l_route_id
      );
      fnd_log.string
      (
         l_log_statement,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Create_Task_Materials',
         ' Before Calling Get Route Mtl Req, Instance Id: ' || l_instance_id
      );

     END IF;

     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string
        (
         l_log_procedure,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
              'Before calling ahl ltp mtl req pvt.Get Route Mtl Req'
           );

     END IF;

     AHL_LTP_MTL_REQ_PVT.Get_Route_Mtl_Req
                (p_api_version       => l_api_version,
                 p_init_msg_list     => p_init_msg_list,
                 p_validation_level  => p_validation_level,
                 x_return_status     => l_return_status,
                 x_msg_count         => l_msg_count,
                 x_msg_data          => l_msg_data,
                 p_route_id          => l_route_id,
                 p_mr_route_id       => l_visit_tasks_rec.mr_route_id,
                 p_item_instance_id  => l_visit_tasks_rec.instance_id, /*B6271339 - sowsubra*/
                 p_requirement_date  => l_requirement_date,
                 p_request_type      => 'PLANNED',
                 x_route_mtl_req_tbl => l_route_mtl_req_tbl);
    END IF; --MR Route not null

    IF (l_log_procedure >= l_log_current_level) THEN
        fnd_log.string
       (
        l_log_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
           'After calling ahl ltp mtl req pvt.Get Route Mtl Req, Return Status : '|| l_return_status
      );
    END IF;
    -- Check Error Message stack.
     IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF;

     IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_statement,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Create_Task_Materials',
         ' After Calling Get Route Mtl Req, l_route_mtl_req_tbl COUNT: ' || l_route_mtl_req_tbl.COUNT
      );

     END IF;
     -- Create planned item in schedule material entity
     IF l_route_mtl_req_tbl.COUNT > 0 THEN
      --Loop through
      FOR i IN l_route_mtl_req_tbl.FIRST..l_route_mtl_req_tbl.LAST
      LOOP
       --Call insert procedure
        Insert_Planned_Matrls(
                 p_visit_id              => p_visit_id,
                 p_visit_task_id         => l_visit_tasks_rec.visit_task_id,
                 p_task_start_date       => l_visit_tasks_rec.start_date_time,
             p_inventory_item_id     => l_route_mtl_req_tbl(i).inventory_item_id,
                 p_requested_quantity    => l_route_mtl_req_tbl(i).quantity,
                 p_uom_code              => l_route_mtl_req_tbl(i).uom_code,
                 p_item_group_id         => l_route_mtl_req_tbl(i).item_group_id,
                 p_rt_oper_material_id   => l_route_mtl_req_tbl(i).rt_oper_material_id,
                 p_position_path_id      => l_route_mtl_req_tbl(i).position_path_id,
                 p_relationship_id       => l_route_mtl_req_tbl(i).relationship_id,
                 p_mr_route_id           => l_visit_tasks_rec.mr_route_id,
                 p_item_comp_detail_id   => l_route_mtl_req_tbl(i).item_comp_detail_id,
                 p_inv_master_org_id     => l_visit_tasks_rec.organization_id,
                 x_return_status         => l_return_status,
                 x_msg_count             => l_msg_count,
                 x_msg_data              => l_msg_data );
                 --
        END LOOP;
      END IF; --l_route_mtl_req_tbl
     END IF;

    IF (l_log_procedure >= l_log_current_level) THEN
        fnd_log.string
       (
        l_log_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
           'After calling Insert Planned Materials, Return Status : '|| l_return_status
      );
    END IF;

    -- Check Error Message stack.
     IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF;


     -- Standard check of p_commit
     IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
     END IF;

     IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_procedure,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Create Task Materials.end',
         'At the end of PLSQL procedure'
      );
     END IF;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO Create_Task_Materials;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Create_Task_Materials;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Create_Task_Materials;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Create_Task_Materials',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);


 END Create_Task_Materials;
--
-- Start of Comments --
--  Procedure name    : Modify_Visit_Task_Matrls
--  Type        : Private
--  Function    : This procedure Created Planned materials information associated to scheduled
--                visit, which are defined at Route Operation and Disposition level
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
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Modify_Visit_Task_Matrls Parameters :
--       p_visit_id                     IN      NUMBER,Required
--
--
PROCEDURE Modify_Visit_Task_Matrls (
   p_api_version             IN    NUMBER,
   p_init_msg_list           IN    VARCHAR2  := FND_API.g_false,
   p_commit                  IN    VARCHAR2  := FND_API.g_false,
   p_validation_level        IN    NUMBER    := FND_API.g_valid_level_full,
   p_visit_id                IN    NUMBER,
   p_visit_task_id           IN    NUMBER := NULL,
   p_start_time              IN    DATE   := NULL,
   p_org_id                  IN    NUMBER := NULL,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2)
  IS

    CURSOR Get_Visit_Tasks_Cur(c_visit_id IN NUMBER)
    IS
     SELECT vs.visit_id,
            vs.organization_id,
            vt.visit_task_id,
          vt.mr_route_id,
          vt.instance_id,
          nvl(vt.start_date_time,vs.start_date_time) start_date_time,
          mr.route_id

       FROM ahl_visits_vl vs,
            ahl_visit_tasks_vl vt,
           ahl_mr_routes_app_v mr
    WHERE vs.visit_id = vt.visit_id
     AND vt.mr_route_id = mr.mr_route_id
     AND vs.visit_id = C_VISIT_ID
         -- Modified by amagrawa based on Enhancement
         AND vt.status_code = 'PLANNING';
    --
    CURSOR Get_Routes_Cur(c_mr_route_id IN NUMBER)
    IS
     SELECT mr.route_id,
            vt.instance_id,
          vt.start_date_time
       FROM ahl_visit_tasks_vl vt,
            ahl_mr_routes_app_v mr
    WHERE vt.mr_route_id = mr.mr_route_id
     AND mr.mr_route_id = C_MR_ROUTE_ID;

-- yazhou 17-May-2006 starts
-- bug fix#5232544

     --Retrieve visit materials
     -- AnRaj: Added the condition for picking up materials for tasks in status DELETED also
     -- for soft deleting materials of deleted tasks from schedule materials table.
     CURSOR Deleted_Items_Cur (c_visit_id IN NUMBER)
    IS
     SELECT asm.visit_id,
            asm.scheduled_material_id scheduled_material_id,
          asm.object_version_number,
          asm.scheduled_quantity,
          asm.scheduled_date
      FROM   ahl_visit_tasks_b tsk,ahl_schedule_materials asm
      WHERE  asm.visit_id = C_VISIT_ID
      AND    asm.visit_task_id = tsk.visit_task_id
      AND    tsk.status_code ='DELETED'
      AND    asm.status <> 'DELETED';


     CURSOR Planned_Items_cur (c_visit_task_id IN NUMBER, c_rt_oper_material_id IN NUMBER)
    IS
      SELECT requested_quantity,
             scheduled_material_id,
             object_version_number
      FROM   ahl_schedule_materials
      WHERE  visit_task_id = c_visit_task_id
      AND    rt_oper_material_id = c_rt_oper_material_id
      AND    NVL(STATUS, 'X') = 'ACTIVE';

     l_Deleted_Items_Rec Deleted_Items_Cur%rowtype;
     l_requested_qty NUMBER;

-- yazhou 17-May-2006 ends

   -- Added to fix the unlogged bug where org id was being incorrectly updated to inventory item's org id
   -- when a task was being deleted.
   l_visit_org_id NUMBER;
   CURSOR Get_Visit_Org_Id_Cur(c_visit_id IN NUMBER)
   IS
      SELECT organization_id
      FROM ahl_visits_b
      WHERE visit_id = C_VISIT_ID
      AND ( organization_id IS NOT NULL
            OR start_date_time IS NOT NULL
            OR department_id IS NOT NULL
          );

    --Standard local variables
    l_api_name     CONSTANT   VARCHAR2(30)   := 'Modify_Visit_Task_Matrls';
    l_api_version CONSTANT NUMBER          := 1.0;
    l_msg_data             VARCHAR2(2000);
    l_return_status        VARCHAR2(1);
    l_msg_count             NUMBER;
   l_dummy                 NUMBER;
    --Variables for derieve start times
    l_visit_start_time         DATE := nvl(p_start_time,null);
    j     NUMBER := 0;
   --
   l_route_id        NUMBER;
   l_instance_id     NUMBER;
    l_visit_tasks_rec       Get_visit_tasks_cur%ROWTYPE;
    l_route_mtl_req_tbl     AHL_LTP_MTL_REQ_PVT.Route_Mtl_Req_Tbl_Type;
   l_Planned_Items_Rec     Planned_Items_cur%ROWTYPE;
    l_requirement_date DATE;

    l_Visit_Task_Route_Tbl        Visit_Task_Route_Tbl_Type;
    i_x     NUMBER;
  BEGIN

   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_procedure,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Modify_Visit_Task_Matrls',
         'At the start of PLSQL procedure'
      );
     END IF;
     -- Standard start of API savepoint
     SAVEPOINT Modify_Visit_Task_Matrls;
      -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean( p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;
     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     --
     IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
         'Request for Modify Visit Task Materials for Visit Id : '|| p_visit_id
      );

     END IF;

-- yazhou 17-May-2006 starts
-- bug fix#5232544
-- Delete all the requirements belong to tasks in DELETED status

      OPEN Deleted_Items_cur(p_visit_id);
     LOOP
        FETCH Deleted_Items_cur INTO l_Deleted_Items_Rec;
        EXIT WHEN Deleted_Items_cur%NOTFOUND;
        --
       IF l_Deleted_Items_Rec.scheduled_material_id IS NOT NULL THEN
            IF (l_log_procedure >= l_log_current_level)THEN
             fnd_log.string
             (
               l_log_procedure,
               'AHL.PLSQL.AHL_LTP_REQST_MATRL_PVT.MODIFY_VISIT_TASK_MATRLS',
               'Updating the status to DELETED for Material Requirement' || l_Deleted_Items_Rec.scheduled_material_id
             );
            END IF;

            UPDATE   ahl_schedule_materials
         SET      requested_quantity =0,
                        status = 'DELETED',
                object_version_number = l_Deleted_Items_Rec.object_version_number + 1
            WHERE    scheduled_material_id = l_Deleted_Items_Rec.scheduled_material_id ;

         END IF;
     END LOOP;
     CLOSE Deleted_Items_cur;

-- yazhou 17-May-2006 ends

   -- AnRaj : Added to fix the unlogged bug where org id was being incorrectly updated to inventory item's org id
   -- when a task was being deleted.
   -- START of Fix
   OPEN Get_Visit_Org_Id_Cur(p_visit_id);
   FETCH Get_Visit_Org_Id_Cur INTO l_visit_org_id;
   CLOSE Get_Visit_Org_Id_Cur;
   -- If the visit does not have a org id, no need to insert the materials again
   IF l_visit_org_id IS NULL THEN
      RETURN;
   ELSE
      IF p_org_id IS NOT NULL THEN
         l_visit_org_id := p_org_id;
      END IF;
   END IF;
   -- END of Fix


     IF (p_visit_id IS NOT NULL AND p_visit_id <> FND_API.G_MISS_NUM) THEN
       --
       OPEN Get_Visit_Tasks_Cur(p_visit_id);
      i_x := 0;
       LOOP
      FETCH Get_Visit_Tasks_Cur INTO l_visit_tasks_rec;
      EXIT WHEN  Get_Visit_Tasks_Cur%NOTFOUND;
       IF l_visit_tasks_rec.route_id IS NOT NULL THEN
        --
      l_Visit_Task_Route_Tbl(i_x).visit_task_id := l_visit_tasks_rec.visit_task_id;
      l_Visit_Task_Route_Tbl(i_x).mr_route_id := l_visit_tasks_rec.mr_route_id;
      l_Visit_Task_Route_Tbl(i_x).route_id := l_visit_tasks_rec.route_id;
      l_Visit_Task_Route_Tbl(i_x).instance_id := l_visit_tasks_rec.instance_id;
      l_Visit_Task_Route_Tbl(i_x).task_start_date := l_visit_tasks_rec.start_date_time;

        i_x := i_x + 1;
         END IF;
       END LOOP;
      CLOSE Get_Visit_Tasks_Cur;
    END IF;

   --
    IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_statement,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Create_Planned_Materials',
         ' After Calling Derive task times, l_Visit_Task_Route_Tbl.COUNT: ' || l_Visit_Task_Route_Tbl.COUNT
      );

     END IF;

   IF l_Visit_Task_Route_Tbl.COUNT > 0 THEN
    FOR i IN l_Visit_Task_Route_Tbl.FIRST..l_Visit_Task_Route_Tbl.LAST
    LOOP

      IF (l_log_statement >= l_log_current_level)THEN
        fnd_log.string
      (
         l_log_statement,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Create_Planned_Materials',
         ' Before Calling Get Route Mtl Req, Route Id: ' || l_Visit_Task_Route_Tbl(i).route_id
      );
      fnd_log.string
      (
         l_log_statement,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Create_Planned_Materials',
         ' Before Calling Get Route Mtl Req, Instance Id: ' || l_Visit_Task_Route_Tbl(i).instance_id
      );
      fnd_log.string
      (
         l_log_statement,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Create_Planned_Materials',
         ' Before Calling Get Route Mtl Req, Task Start Time: ' || l_Visit_Task_Route_Tbl(i).task_start_date
      );

     END IF;

     IF (l_Visit_Task_Route_Tbl(i).task_start_date IS NOT NULL AND
         TRUNC(l_Visit_Task_Route_Tbl(i).task_start_date) < TRUNC(SYSDATE) )
   THEN
        l_requirement_date := sysdate;
     ELSE
        l_requirement_date := l_Visit_Task_Route_Tbl(i).task_start_date;
     END IF;

    IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string
        (
         l_log_procedure,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
              'Before calling ahl ltp mtl req pvt.Get Route Mtl Req'
           );

     END IF;

     --Call to get items
     AHL_LTP_MTL_REQ_PVT.Get_Route_Mtl_Req
                (p_api_version       => l_api_version,
                 p_init_msg_list     => p_init_msg_list,
                 p_validation_level  => p_validation_level,
                 x_return_status     => l_return_status,
                 x_msg_count         => l_msg_count,
                 x_msg_data          => l_msg_data,
                 p_route_id          => l_Visit_Task_Route_Tbl(i).route_id,
                 p_mr_route_id       => l_Visit_Task_Route_Tbl(i).mr_route_id,
                 p_item_instance_id  => l_Visit_Task_Route_Tbl(i).instance_id,
                 p_requirement_date  => l_requirement_date,
                 p_request_type      => 'PLANNED',
                 x_route_mtl_req_tbl => l_route_mtl_req_tbl);
    --
    IF (l_log_procedure >= l_log_current_level) THEN
        fnd_log.string
       (
        l_log_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
           'After calling ahl ltp mtl req pvt.Get Route Mtl Req, Return Status : '|| l_return_status
      );
    END IF;
    -- Check Error Message stack.
     IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF;

     IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_statement,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Create_Planned_Materials',
         ' After Calling Get Route Mtl Req, l_route_mtl_req_tbl COUNT: ' || l_route_mtl_req_tbl.COUNT
      );

     END IF;

   IF l_route_mtl_req_tbl.COUNT > 0 THEN
      --
      FOR j IN l_route_mtl_req_tbl.FIRST..l_route_mtl_req_tbl.LAST
      LOOP

-- yazhou 17-May-2006 starts
-- bug fix#5232544

-- For a given requirement
--  1)use the requested quantity in the existing requirement because it could have been
-- changed by the user from LTP update material requirement UI.
-- 2) Delete the existing requirement before creating the new one

           l_requested_qty := null;

           OPEN Planned_Items_cur(l_Visit_Task_Route_Tbl(i).visit_task_id,l_route_mtl_req_tbl(j).rt_oper_material_id);
           FETCH Planned_Items_cur INTO l_Planned_Items_Rec;

           IF Planned_Items_cur%found THEN

           IF l_Planned_Items_Rec.scheduled_material_id IS NOT NULL THEN
                   IF (l_log_procedure >= l_log_current_level)THEN
                   fnd_log.string
                  (
                    l_log_procedure,
                     'AHL.PLSQL.AHL_LTP_REQST_MATRL_PVT.MODIFY_VISIT_TASK_MATRLS',
                     'Updating the status to DELETED for Material Requirement' || l_Planned_Items_Rec.scheduled_material_id
                       );
                  END IF;

                  -- delete existing requirement for a given rt_oper_material_id and task combination

                  UPDATE   ahl_schedule_materials
            SET      requested_quantity =0,
                           status = 'DELETED',
                   object_version_number = l_Planned_Items_Rec.object_version_number + 1
                  WHERE    scheduled_material_id = l_Planned_Items_Rec.scheduled_material_id ;

                  -- use the requested quantity defined for the existing requirement
                  l_requested_qty := l_Planned_Items_Rec.requested_quantity;

               END IF; -- scheduled_material_id is not null

           ELSE
               -- use the default quantity defined at the route
               l_requested_qty := l_route_mtl_req_tbl(j).quantity;

           END IF; -- planned_item_cur%found

           CLOSE Planned_Items_cur;

           Insert_Planned_Matrls(
                 p_visit_id              => p_visit_id,
                 p_visit_task_id         => l_Visit_Task_Route_Tbl(i).visit_task_id,
                 p_task_start_date       => l_Visit_Task_Route_Tbl(i).task_start_date,
             p_inventory_item_id     => l_route_mtl_req_tbl(j).inventory_item_id,
                 p_requested_quantity    => l_requested_qty,
                 p_uom_code              => l_route_mtl_req_tbl(j).uom_code,
                 p_item_group_id         => l_route_mtl_req_tbl(j).item_group_id,
                 p_rt_oper_material_id   => l_route_mtl_req_tbl(j).rt_oper_material_id,
                 p_position_path_id      => l_route_mtl_req_tbl(j).position_path_id,
                 p_relationship_id       => l_route_mtl_req_tbl(j).relationship_id,
                 p_mr_route_id           => l_Visit_Task_Route_Tbl(i).mr_route_id,
                 p_item_comp_detail_id   => l_route_mtl_req_tbl(j).item_comp_detail_id,
                 -- AnRaj: changed the paramter, for fixing bug where org id was being incorrectly updated
                 p_inv_master_org_id     => l_visit_org_id  ,
                 x_return_status         => l_return_status,
                 x_msg_count             => l_msg_count,
                 x_msg_data              => l_msg_data );

-- yazhou 17-May-2006 ends
                 --
         END LOOP;
      END IF; --l_route_mtl_req_tbl

    IF (l_log_procedure >= l_log_current_level) THEN
        fnd_log.string
       (
        l_log_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
           'After calling Insert Planned Materials, Return Status : '|| l_return_status
      );
    END IF;

    -- Check Error Message stack.
     IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF;
       --
    END LOOP;
   END IF;

   -- Serial Number Reservation Enhancement Changes.
   -- If the date of the visit has changed then all reservation dates also should change accordingly
      Modify_Visit_Reservations (
         p_visit_id    => p_visit_id,
         x_return_status  =>  l_return_status);

          IF (l_log_procedure >= l_log_current_level) THEN
             fnd_log.string
                 (
                  l_log_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
                'After calling Modify_Visit_Reservations, Return Status : '|| l_return_status
                );
          END IF;

      -- Check Error Message stack.
        IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      RAISE FND_API.G_EXC_ERROR;
         END IF;

     -- Check Error Message stack.
     x_msg_count := FND_MSG_PUB.count_msg;
     IF x_msg_count > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
     END IF;

     -- Standard check of p_commit
     IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
     END IF;

     IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_procedure,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Modify Visit Task Matrls.end',
         'At the end of PLSQL procedure'
      );
     END IF;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO Modify_Visit_Task_Matrls;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Modify_Visit_Task_Matrls;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Modify_Visit_Task_Matrls;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Modify_Visit_Task_Matrls',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);


  END Modify_Visit_Task_Matrls;
--
-- Start of Comments --
--  Procedure name    : Unschedule_Visit_task_Items
--  Type        : Private
--  Function    : This procedure Checks any items scheduled
--                which are defined at Route Operation and Disposition level
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--         This will be null.
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Unschedule_Visit_Task_Items Parameters :
--       p_visit_id            IN   NUMBER,        Required
--       p_visit_task_id       IN   NUMBER,        Optional
--

PROCEDURE Unschedule_visit_Task_Items
  (p_api_version            IN    NUMBER,
   p_init_msg_list          IN    VARCHAR2  := Fnd_Api.G_FALSE,
   p_commit                 IN    VARCHAR2  := Fnd_Api.G_FALSE,
   p_visit_id               IN    NUMBER,
   p_visit_task_id          IN    NUMBER   := NULL,
   x_return_status             OUT NOCOPY        VARCHAR2,
   x_msg_count                 OUT NOCOPY        NUMBER,
   x_msg_data                  OUT NOCOPY        VARCHAR2 )
IS
 --
  CURSOR check_items_cur (C_VISIT_ID IN NUMBER)
   IS
-- AnRaj :Changed for fixing performance bug#4919562
 SELECT   ASMT.visit_id,
          ASMT.visit_task_id,
          ASMT.scheduled_material_id schedule_material_id,
          decode(sign( trunc(ASMT.scheduled_date) - trunc(requested_date)), 1, ASMT.scheduled_date, null) SCHEDULED_DATE,
          ASMT.SCHEDULED_QUANTITY
   FROM   AHL_SCHEDULE_MATERIALS ASMT,
          AHL_VISIT_TASKS_B VTSK
  WHERE   ASMT.STATUS <> 'DELETED'
    AND   EXISTS (   Select   1
                     from     AHL_RT_OPER_MATERIALS RTOM
                     where    RTOM.RT_OPER_MATERIAL_ID = ASMT.RT_OPER_MATERIAL_ID)
    AND   VTSK.VISIT_ID = ASMT.VISIT_ID
    AND   VTSK.VISIT_TASK_ID = ASMT.VISIT_TASK_ID
    AND   NVL(VTSK.STATUS_CODE,'X') <> 'DELETED'
    AND   ASMT.VISIT_ID = C_VISIT_ID
    AND   scheduled_date IS NOT NULL;
/*
   SELECT visit_id,visit_task_id,schedule_material_id,
          scheduled_date,scheduled_quantity
    FROM ahl_visit_task_matrl_v
    WHERE visit_id = C_VISIT_ID
     AND scheduled_date IS NOT NULL;
*/
    --
     l_api_name        CONSTANT VARCHAR2(30) := 'UNSCHEDULE_TASK_ITEMS';
     l_api_version     CONSTANT NUMBER       := 1.0;
     l_return_status            VARCHAR2(1);
     l_msg_data                 VARCHAR2(200);
     l_msg_count                NUMBER;
    l_schedule_items_rec  check_items_cur%ROWTYPE;
    l_req_material_rec    ahl_ltp_reqst_matrl_pub.Schedule_Mr_Rec;
    --
BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT Unschedule_Task_Items;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'enter ahl_ltp_reqst_matrl_pvt Unchedule Task Items ','+MAATP+');
   END IF;
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
   ------------------------Start API Body ---------------------------------
   -- Check for any visit task items has been scheduled from MRP
   OPEN check_items_cur(p_visit_id);
   LOOP
   FETCH check_items_cur INTO l_schedule_items_rec;
   EXIT WHEN check_items_cur%NOTFOUND;
      IF (l_schedule_items_rec.visit_id IS NOT NULL AND
         l_schedule_items_rec.visit_task_id IS NOT NULL AND
        p_visit_task_id IS NULL) THEN
        -- Call Unschedule to load record into interface table
        --Assign the values
        l_req_material_rec.schedule_mat_id := l_schedule_items_rec.schedule_material_id;
        --
--          Unschedule_Request (
--             p_req_material_rec    => l_req_material_rec);
        --
     ELSIF (l_schedule_items_rec.visit_id IS NOT NULL AND
            l_schedule_items_rec.visit_task_id IS NOT NULL AND
          l_schedule_items_rec.visit_task_id = p_visit_task_id ) THEN
        --Assign the values
        l_req_material_rec.schedule_mat_id := l_schedule_items_rec.schedule_material_id;
        --
--          Unschedule_Request (
--             p_req_material_rec    => l_req_material_rec);
         --
     END IF;
   END LOOP;
   CLOSE check_items_cur;

---------------------------End of Body---------------------------------------
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of private api Unschedule Task Items ','+MAMRP+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   --
   END IF;
  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Unschedule_Task_Items;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_reqst_matrl_pvt. Unschedule Task Items ','+MAMRP+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
    END IF;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO search_schedule_materials;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
              x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_reqst_matrl_pvt. Unschedule Task Items','+MAMRP+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;

WHEN OTHERS THEN
    ROLLBACK TO Unschedule_Task_Items;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_REQST_MATRL_PVT',
                            p_procedure_name  =>  'UNSCHEDULE_TASK_ITEMS',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'SQL ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_reqst_matrl_pvt. Unschedule Task Items','+MTMRP+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
    END IF;

END Unschedule_visit_Task_Items;
--
-- Start of Comments --
--  Procedure name    : Process_Planned_Materials
--  Type        : Private
--  Function    : This procedure Creates, Updates and Removes Planned materials information associated to scheduled
--                visit, which are defined at Route Operation and Disposition level
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
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Process_Planned_Materials Parameters :
--
--
PROCEDURE Process_Planned_Materials (
   p_api_version             IN    NUMBER,
   p_init_msg_list           IN    VARCHAR2  := FND_API.g_false,
   p_commit                  IN    VARCHAR2  := FND_API.g_false,
   p_validation_level        IN    NUMBER    := FND_API.g_valid_level_full,
   p_visit_id                IN    NUMBER,
   p_visit_task_id           IN    NUMBER   := NULL,
   p_org_id                  IN    NUMBER   := NULL,
   p_start_date              IN    DATE     := NULL,
   p_visit_status            IN    VARCHAR2 := NULL,
   p_operation_flag          IN    VARCHAR2,
   x_planned_order_flag         OUT NOCOPY VARCHAR2 ,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
   ) IS

    --Standard local variables
    l_api_name     CONSTANT   VARCHAR2(30)   := 'Process_Planned_Materials';
    l_api_version CONSTANT NUMBER          := 1.0;
    l_msg_data              VARCHAR2(2000);
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_commit                VARCHAR2(10)  := FND_API.g_false;
    l_planned_order_flag    VARCHAR2(1) := 'N';
    l_assoc_id        NUMBER ;

--priyan begin
    CURSOR get_assoc_primary_id (c_visit_id IN NUMBER)
    IS
   SELECT asso_primary_visit_id
   FROM ahl_visits_b
   WHERE visit_id = c_visit_id;
--priyan end
BEGIN

   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_procedure,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials',
         'At the start of PLSQL procedure'
      );
   END IF;

   -- Standard start of API savepoint
   SAVEPOINT Process_Planned_Materials;
   -- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.To_Boolean( p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Request for Process Task Materials for Visit Id : '|| p_visit_id
      );
      fnd_log.string
      (
         l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
         'Request for Process Task Materials for Visit Task Id : '|| p_visit_task_id
      );
      fnd_log.string
      (
         l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
         'Request for Process Task Materials for Operation Flag : '|| p_operation_flag
      );
   END IF;

--priyan
   OPEN get_assoc_primary_id (p_visit_id);
   FETCH get_assoc_primary_id INTO l_assoc_id;
   CLOSE get_assoc_primary_id;

   --priyan
   -- Added the check l_assoc_id IS NULL
   IF (p_visit_task_id IS NOT NULL AND l_assoc_id IS NULL AND p_visit_task_id <> FND_API.g_miss_num AND p_operation_flag = 'C' ) THEN
   -- if create
      IF (l_log_statement >= l_log_current_level)THEN
         fnd_log.string
         (
            l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Before Calling Create Task Materials for Visit Task Id : '|| p_visit_task_id
         );
         fnd_log.string
         (
            l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Before Calling Create Task Materials for Operation Flag : '|| p_operation_flag
         );
      END IF;

      IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string
         ( l_log_procedure,
           'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
           'Before calling Create Task Materials'
         );
      END IF;

      Create_Task_Materials (
             p_api_version      => l_api_version,
             p_init_msg_list    => p_init_msg_list,
             p_commit           => l_commit,
             p_validation_level  => p_validation_level,
             p_visit_id          => p_visit_id,
             p_visit_task_id     => p_visit_task_id,
             x_return_status     => l_return_status,
             x_msg_count         => l_msg_count,
             x_msg_data          => l_msg_data  );

      IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string
         (
            l_log_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
           'After calling Create Task Materials, Return Status : '|| l_return_status
         );
      END IF;
      -- Check Error Message stack.
      IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
   --priyan
   -- Added the check l_assoc_id IS  NULL
   ELSIF (p_visit_id IS NOT NULL AND l_assoc_id IS NULL AND p_visit_id <> FND_API.g_miss_num AND p_operation_flag = 'U' ) THEN
   -- if update
      IF (l_log_statement >= l_log_current_level)THEN
         fnd_log.string
         (
            l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Request for Visit Org or Start date change for Visit Id : '|| p_visit_id
         );
         fnd_log.string
         (
            l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Request for Visit Org or Start date change for Operation Flag : '|| p_operation_flag
         );
         fnd_log.string
         (
            l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Request for Visit Org or Start date change for Org Id : '|| p_org_id
         );
         fnd_log.string
         (
            l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Request for Visit Org or Start date change for Start date : '|| p_start_date
         );
      END IF;

      IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string
         (
            l_log_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Before calling Modify Visit Task Materials'
          );
      END IF;

      Modify_Visit_Task_Matrls (
             p_api_version      => l_api_version,
             p_init_msg_list    => p_init_msg_list,
             p_commit           => l_commit,
             p_validation_level  => p_validation_level,
             p_visit_id          => p_visit_id,
             p_start_time        => p_start_date,
             p_org_id            => p_org_id,
             x_return_status     => l_return_status,
             x_msg_count         => l_msg_count,
             x_msg_data          => l_msg_data);

      IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string
         (
            l_log_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
            'After calling Create Planned Materials, Return Status : '|| l_return_status
         );
      END IF;
      -- Check Error Message stack.
      IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

   -- anraj added
   ELSIF (p_visit_id IS NOT NULL AND p_visit_id <> FND_API.g_miss_num AND p_operation_flag = 'D') THEN
   -- delete mode called if org or dept or start date is nullified
      Unschedule_Visit_Materials (
             p_api_version      => l_api_version,
             p_init_msg_list    => p_init_msg_list,
             p_commit           => l_commit,
             p_validation_level => p_validation_level,
             p_visit_id          => p_visit_id,
             x_return_status     => l_return_status,
             x_msg_count         => l_msg_count,
             x_msg_data          => l_msg_data);

      -- Check Error Message stack.
      IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
   -- anraj

   ELSIF (p_visit_id IS NOT NULL AND p_visit_id <> FND_API.g_miss_num AND p_operation_flag = 'R'
            AND p_visit_task_id IS NULL) THEN
   -- remove mode , with no task id
      IF (l_log_statement >= l_log_current_level)THEN
         fnd_log.string
         (
            l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Request for Removing visit materials for Visit Id : '|| p_visit_id
         );
         fnd_log.string
         (
            l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Request for Remove visit materials for Operation Flag : '|| p_operation_flag
         );
      END IF;

      IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string
         (
            l_log_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Before calling Remove Visit Task Materials'
         );
      END IF;

      Remove_Visit_Task_Matrls (
             p_api_version      => l_api_version,
             p_init_msg_list    => p_init_msg_list,
             p_commit           => l_commit,
             p_validation_level  => p_validation_level,
             p_visit_id          => p_visit_id,
             x_planned_order_flag => l_planned_order_flag ,
             x_return_status     => l_return_status,
             x_msg_count         => l_msg_count,
             x_msg_data          => l_msg_data);

      IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string
         (
            l_log_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
            'After calling Remove Visit Task Materials, Return Status : '|| l_return_status
         );
      END IF;

      -- Check Error Message stack.
      IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

   ELSIF (p_visit_task_id IS NOT NULL AND p_visit_task_id <> FND_API.g_miss_num AND p_operation_flag = 'R')
   THEN
   -- Remove mode with Task ID
      IF (l_log_statement >= l_log_current_level)THEN
         fnd_log.string
         (
            l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Request for Removing task materials for Visit Task Id : '|| p_visit_task_id
         );
         fnd_log.string
         (
            l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Request for Removing task materials for Operation Flag : '|| p_operation_flag
         );
      END IF;

      IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string
         (
            l_log_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Before calling Remove Visit Task Materials'
         );
      END IF;

      Remove_Visit_Task_Matrls (
             p_api_version      => l_api_version,
             p_init_msg_list    => p_init_msg_list,
             p_commit           => l_commit,
             p_validation_level  => p_validation_level,
             p_visit_id          => p_visit_id,
             p_visit_task_id     => p_visit_task_id,
             x_planned_order_flag => l_planned_order_flag ,
             x_return_status     => l_return_status,
             x_msg_count         => l_msg_count,
             x_msg_data          => l_msg_data);


      IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string
         (
            l_log_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
            'After calling Remove Visit Task Materials, Return Status : '|| l_return_status
         );
      END IF;
      -- Check Error Message stack.
      IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

   ELSIF (p_visit_id IS NOT NULL AND p_visit_id <> FND_API.g_miss_num AND p_visit_status IN ('CLOSED', 'CANCELLED'))
   -- visitis in Closed or Cancelled status
   THEN
      IF (l_log_statement >= l_log_current_level)THEN
         fnd_log.string
         (
            l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Request for Visit Closed or Cancelled Update Unplanned materials for Visit Id : '|| p_visit_id
         );
      END IF;

      IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string
         (
            l_log_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Before calling Update Unplanned Visit Materials'
          );
      END IF;

      Update_Unplanned_Matrls (
             p_api_version      => l_api_version,
             p_init_msg_list    => p_init_msg_list,
             p_commit           => l_commit,
             p_validation_level  => p_validation_level,
             p_visit_id          => p_visit_id,
             x_return_status     => l_return_status,
             x_msg_count         => l_msg_count,
             x_msg_data          => l_msg_data);

      IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string
         (
            l_log_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
            'After calling Update Unplanned Materials, Return Status : '|| l_return_status
         );
      END IF;
      -- Check Error Message stack.
      IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
   END IF;
     -- Standard check of p_commit
     IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
     END IF;

     IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_procedure,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Process Planned Materials.end',
         'At the end of PLSQL procedure'
      );
     END IF;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO Process_Planned_Materials;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Process_Planned_Materials;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Process_Planned_Materials;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Process_Planned_Materials',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);


  END Process_Planned_Materials;
--
-- Start of Comments --
--  Procedure name    : Remove_Visit_Task_Matrls
--  Type        : Private
--  Function    : This procedure Created Planned materials information associated to scheduled
--                visit, which are defined at Route Operation and Disposition level
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
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Create_Planned_Materials Parameters :
--       p_visit_id                     IN      NUMBER,Required
--
--
PROCEDURE Remove_Visit_Task_Matrls (
   p_api_version             IN    NUMBER,
   p_init_msg_list           IN    VARCHAR2  := FND_API.g_false,
   p_commit                  IN    VARCHAR2  := FND_API.g_false,
   p_validation_level        IN    NUMBER    := FND_API.g_valid_level_full,
   p_visit_id                IN    NUMBER,
   p_visit_task_id           IN    NUMBER := NULL,
   x_planned_order_flag        OUT NOCOPY VARCHAR2 ,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2)
IS

   CURSOR visit_task_details_cur (c_visit_id IN NUMBER,
                                  c_visit_task_id IN NUMBER)
   IS
      SELECT   vs.visit_id,
               vs.organization_id,
               vt.visit_task_id
      FROM     ahl_visits_vl vs,
               ahl_visit_tasks_vl vt
      WHERE    vs.visit_id = vt.visit_id
      AND      vs.visit_id = c_visit_id
      AND      vt.visit_task_id = c_visit_task_id;
   --To Retrieve visit task planned materials
   CURSOR visit_task_mtrls_cur (c_visit_task_id IN NUMBER)
   IS
      SELECT   visit_id,
               visit_task_id,
               schedule_material_id,
               object_version_number,
               inventory_item_id,
               scheduled_date,
               scheduled_quantity
      FROM     ahl_visit_task_matrl_v
      WHERE    visit_task_id = c_visit_task_id;

   --Retrieve visit level planned materials
   CURSOR visit_mtrls_cur (c_visit_id IN NUMBER)
   IS
      SELECT   visit_id,
               visit_task_id,
               schedule_material_id,
               object_version_number,
               inventory_item_id,
               scheduled_date,
               scheduled_quantity
      FROM     ahl_visit_task_matrl_v
      WHERE visit_id = c_visit_id;

    --Standard local variables
   l_api_name      CONSTANT   VARCHAR2(30)   := 'Remove_Visit_Task_Matrls';
   l_api_version  CONSTANT NUMBER          := 1.0;
   l_msg_data             VARCHAR2(2000);
   l_return_status        VARCHAR2(1);
   l_msg_count             NUMBER;
   l_visit_task_details_rec   visit_task_details_cur%ROWTYPE;
   l_visit_task_mtrls_rec     visit_task_mtrls_cur%ROWTYPE;
   l_visit_mtrls_rec          visit_mtrls_cur%ROWTYPE;
   l_visit_id       NUMBER := p_visit_id;
   l_visit_task_id  NUMBER := p_visit_task_id;
   l_planned_order_flag   VARCHAR2(1):= 'N';
BEGIN
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_procedure,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Remove_Visit_Task_Matrls',
         'At the start of PLSQL procedure'
      );
   END IF;
     -- Standard start of API savepoint
   SAVEPOINT Remove_Visit_Task_Matrls;
   -- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.To_Boolean( p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
         'Request for Remove Task Materials for Visit Id : '|| l_visit_id
      );
      fnd_log.string
      (
         l_log_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
         'Request for Remove Task Materials for Visit Task Id : '|| l_visit_task_id
      );
   END IF;

   IF ( l_visit_id IS NOT NULL AND l_visit_id <> fnd_api.g_miss_num ) THEN
   --Get details
      OPEN visit_task_details_cur(l_visit_id,l_visit_task_id);
      FETCH visit_task_details_cur INTO l_visit_task_details_rec;
      CLOSE visit_task_details_cur;

      IF (l_log_statement >= l_log_current_level)THEN
        fnd_log.string
         (
         l_log_statement,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Remove_Visit_Task_Matrls',
         ' After visit task details cur, Visit Id: ' || l_visit_id
         );
      END IF;

   --Check for deleting a visit
      IF (l_visit_task_id IS NOT NULL AND l_visit_task_id <> fnd_api.g_miss_num)
      THEN
         IF (l_log_statement >= l_log_current_level)THEN
            fnd_log.string
            (
               l_log_statement,
               'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Remove_Visit_Task_Matrls',
               ' Before Retrieving task materials cur, Visit Task Id: ' || l_visit_task_id
            );
         END IF;
          --Retrieve task materials only
         OPEN visit_task_mtrls_cur(l_visit_task_id);
         LOOP
            FETCH visit_task_mtrls_cur INTO l_visit_task_mtrls_rec;
            EXIT WHEN visit_task_mtrls_cur%NOTFOUND;
            -- update request quanity zero
            IF l_visit_task_mtrls_rec.schedule_material_id IS NOT NULL THEN
               UPDATE   ahl_schedule_materials
               SET      requested_quantity = 0,
                        status = 'DELETED',
                        object_version_number = l_visit_task_mtrls_rec.object_version_number + 1
               WHERE    scheduled_material_id = l_visit_task_mtrls_rec.schedule_material_id;
            END IF; --Schedule material not null
         END LOOP;
         CLOSE visit_task_mtrls_cur;
      ELSE
         IF (l_log_statement >= l_log_current_level)THEN
            fnd_log.string
            (
               l_log_statement,
               'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Remove_Visit_Task_Matrls',
               ' Before Retrieving all visit task materials cur, For Visit Id: ' || l_visit_id
            );
         END IF;

            -- Retrieve all the visit tasks
         OPEN visit_mtrls_cur(l_visit_id);
         LOOP
            FETCH visit_mtrls_cur INTO l_visit_mtrls_rec;
            EXIT WHEN visit_mtrls_cur%NOTFOUND;
            -- update request quanity zero
            IF l_visit_mtrls_rec.schedule_material_id IS NOT NULL THEN
               UPDATE   ahl_schedule_materials
               SET      requested_quantity = 0,
                        status = 'DELETED',
                        object_version_number = l_visit_mtrls_rec.object_version_number + 1
               WHERE    scheduled_material_id = l_visit_mtrls_rec.schedule_material_id;
            END IF; --Schedule material not null
         END LOOP;
         CLOSE visit_mtrls_cur;

         -- Serial Number reservation Enh.
         -- delete all reservations for this visit on organization change
         AHL_RSV_RESERVATIONS_PVT.DELETE_VISIT_RESERVATIONS(
               X_RETURN_STATUS => X_RETURN_STATUS,
               P_VISIT_ID      => p_visit_id);

         IF (l_log_statement >= l_log_current_level)THEN
            fnd_log.string
            (
               l_log_statement,
               'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Remove_Visit_Task_Matrls',
               ' After calling AHL_RSV_RESERVATIONS_PVT.DELETE_VISIT_RESERVATIONS ErrorMessage Status : ' || X_RETURN_STATUS
            );
         END IF;

         IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE Fnd_Api.g_exc_error;
         END IF;
      END IF; --Just task deletion
   END IF;
   x_planned_order_flag := l_planned_order_flag;

  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   -- Standard check of p_commit
   IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
   END IF;

   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_procedure,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Remove Visit Task Matrls.end',
         'At the end of PLSQL procedure'
      );
   END IF;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO Remove_Visit_Task_Matrls;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Remove_Visit_Task_Matrls;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Remove_Visit_Task_Matrls;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'REMOVE_VISIT_TASK_MATRLS',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);


END Remove_Visit_Task_Matrls;
--
-- Start of Comments --
--  Procedure name    : Update_Unplanned_Matrls
--  Type        : Private
--  Function    : This procedure Created Planned materials information associated to scheduled
--                visit, which are defined at Route Operation and Disposition level
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
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Update_Unplanned_Materials Parameters :
--       p_visit_id                     IN      NUMBER,Required
--
--
PROCEDURE Update_Unplanned_Matrls (
   p_api_version             IN    NUMBER,
   p_init_msg_list           IN    VARCHAR2  := FND_API.g_false,
   p_commit                  IN    VARCHAR2  := FND_API.g_false,
   p_validation_level        IN    NUMBER    := FND_API.g_valid_level_full,
   p_visit_id                IN    NUMBER,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2)
IS
   CURSOR visit_mtrls_cur (c_visit_id IN NUMBER)
   IS
   SELECT   visit_id,
            visit_task_id,
            scheduled_material_id,
            object_version_number
   FROM     ahl_schedule_materials
   WHERE    visit_id = c_visit_id
   AND      status = 'ACTIVE';

   --Standard local variables
   l_api_name      CONSTANT   VARCHAR2(30)   := 'Update_Unplanned_Matrls';
   l_api_version  CONSTANT NUMBER          := 1.0;
   l_msg_data             VARCHAR2(2000);
   l_return_status        VARCHAR2(1);
   l_msg_count             NUMBER;
   l_visit_mtrls_rec       visit_mtrls_cur%ROWTYPE;

BEGIN
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_procedure,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Update_Unplanned_Matrls',
         'At the start of PLSQL procedure'
      );
   END IF;

   -- Standard start of API savepoint
   SAVEPOINT Update_Unplanned_Matrls;

   -- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.To_Boolean( p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_statement,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
         'Request for Update Materials for Visit Id : '|| p_visit_id
      );
   END IF;

   --Retrieve all the materials
   OPEN visit_mtrls_cur(p_visit_id);
   LOOP
      FETCH visit_mtrls_cur INTO l_visit_mtrls_rec;
      EXIT WHEN visit_mtrls_cur%NOTFOUND;
      IF l_visit_mtrls_rec.scheduled_material_id IS NOT NULL THEN
         UPDATE   ahl_schedule_materials
         SET      STATUS = 'HISTORY',
                  OBJECT_VERSION_NUMBER = l_visit_mtrls_rec.object_version_number
         WHERE    scheduled_material_id = l_visit_mtrls_rec.scheduled_material_id;
      END IF;
   END LOOP;
   CLOSE visit_mtrls_cur;

   -- Serial Number reservation Enh.
   -- Delete all  the reservations for this visit
   AHL_RSV_RESERVATIONS_PVT.DELETE_VISIT_RESERVATIONS(
                  X_RETURN_STATUS => X_RETURN_STATUS,
                  P_VISIT_ID      => p_visit_id);

   IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_statement,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Remove_Visit_Task_Matrls',
         ' After calling AHL_RSV_RESERVATIONS_PVT.DELETE_VISIT_RESERVATIONS ErrorMessage Status : ' || X_RETURN_STATUS
      );
   END IF;

   IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE Fnd_Api.g_exc_error;
   END IF;

   -- Standard check of p_commit
   IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
   END IF;

   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_procedure,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Update Unplanned Matrls.end',
         'At the end of PLSQL procedure'
      );
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      ROLLBACK TO Update_Unplanned_Matrls;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO Update_Unplanned_Matrls;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO Update_Unplanned_Matrls;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'UPDATE_UNPLANNED_MATRLS',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
      END IF;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
END Update_Unplanned_Matrls;

--
-- Start of Comments --
--  Procedure name    : MODIFY_VISIT_RESERVATIONS
--  Type        : Private
--  Function    : Handles Material reservation incase of change in Visit Organisation.
--              : Added for Serial NUmber Reservation by Senthil.
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--
--  Modify_Visit_Reservations Parameters :
--       p_visit_id                     IN      NUMBER,Required
--
--
PROCEDURE Modify_Visit_Reservations (
   p_visit_id                IN    NUMBER,
   x_return_status             OUT NOCOPY VARCHAR2)

IS
   -- AnRaj: Changed the WHERE clause , for Performance improvement
   CURSOR get_del_mtl_req_csr(c_visit_id IN NUMBER) IS
      SELECT   mat.scheduled_material_id
      FROM     ahl_schedule_materials mat,
               ahl_visit_tasks_b vt
      WHERE    vt.visit_id = c_visit_id
      AND      vt.status_code = 'DELETED'
      AND      vt.visit_task_id = mat.visit_task_id
      AND EXISTS (SELECT   reservation_id
                  FROM     mtl_reservations RSV
                  WHERE    RSV.external_source_code = 'AHL'
                  AND      RSV.demand_source_line_detail = mat.scheduled_material_id
                  AND      RSV.organization_id = mat.organization_id
                  AND      RSV.requirement_date = mat.requested_date
                  AND      RSV.inventory_item_id = mat.inventory_item_id );

   CURSOR get_cur_org_csr(p_visit_id IN NUMBER) IS
      SELECT   organization_id
      FROM     ahl_visits_b
      WHERE    visit_id = p_visit_id;

   CURSOR get_prev_org_csr(p_visit_id IN NUMBER) IS
      SELECT   organization_id
      FROM     mtl_reservations
      WHERE    external_source_code = 'AHL'
      AND      demand_source_header_id in (  SELECT visit_task_id
                                             FROM ahl_visit_tasks_b
                                             WHERE visit_id = p_visit_id);
   --Standard local variables
   l_api_name      CONSTANT   VARCHAR2(30)   := 'Modify_Visit_Reservations';
   l_api_version  CONSTANT NUMBER          := 1.0;
   l_msg_data             VARCHAR2(2000);
   l_return_status        VARCHAR2(1);
   l_msg_count             NUMBER;

   l_cur_org_id  NUMBER;
   l_prev_org_id NUMBER;
   l_org_count   NUMBER;
   l_scheduled_material_id NUMBER;
BEGIN
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_procedure,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Modify_Visit_Reservations.Start',
         'At the end of PLSQL procedure'
      );
   END IF;

   OPEN get_cur_org_csr(p_visit_id) ;
   FETCH get_cur_org_csr into l_cur_org_id;
   CLOSE get_cur_org_csr;


   OPEN get_prev_org_csr (p_visit_id) ;
   FETCH get_prev_org_csr into l_prev_org_id;
   CLOSE get_prev_org_csr;


   SELECT  count(distinct organization_id)
   INTO  l_org_count
   FROM  mtl_reservations
   WHERE external_source_code = 'AHL'
   AND   demand_source_header_id in (  SELECT   visit_task_id
                                       FROM  ahl_visit_tasks_b
                                       WHERE    visit_id = p_visit_id);

   IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_statement,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Modify_Visit_Reservations',
         'l_org_count : '||l_org_count||' l_cur_org_id:'||l_cur_org_id||
         ' l_prev_org_id:'||l_prev_org_id
      );
   END IF;


   IF l_prev_org_id IS NULL THEN
      Return;
   ELSIF l_org_count > 1 THEN
      FND_MESSAGE.set_name('AHL', 'AHL_LTP_MULTI_ORG');
      FND_MSG_PUB.ADD;
      RAISE Fnd_Api.g_exc_error;
   END IF;

   IF l_prev_org_id <> l_cur_org_id THEN
   -- delete all reservations for this visit on organization change
      AHL_RSV_RESERVATIONS_PVT.DELETE_VISIT_RESERVATIONS(
                   X_RETURN_STATUS => X_RETURN_STATUS,
                   P_VISIT_ID      => p_visit_id);

      IF (l_log_statement >= l_log_current_level)THEN
         fnd_log.string
         (
            l_log_statement,
            'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Modify_Visit_Reservations',
            'After calling AHL_RSV_RESERVATIONS_PVT.DELETE_VISIT_RESERVATIONS:X_RETURN_STATUS '||X_RETURN_STATUS
         );
      END IF;

      IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;
   ELSE
      IF (l_log_statement >= l_log_current_level)THEN
         fnd_log.string
         (
            l_log_statement,
            'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Modify_Visit_Reservations',
            'In the else part of check l_prev_org_id <> l_cur_org_id'
         );
      END IF;
      -- Get all the material requirements with reservation created  for deleted tasks
      OPEN get_del_mtl_req_csr (p_visit_id);
      LOOP
         Fetch get_del_mtl_req_csr  into l_scheduled_material_id;
         EXIT WHEN get_del_mtl_req_csr%NOTFOUND;
         -- Delete all the reservations made for this requirement
            AHL_RSV_RESERVATIONS_PVT.Delete_Reservation(
                     p_module_type       => NULL,
                     x_return_status     => l_return_status,
                     x_msg_count         => l_msg_count,
                     x_msg_data          => l_msg_data,
                     p_scheduled_material_id => l_scheduled_material_id
                  );

           IF (l_log_statement >= l_log_current_level)THEN
               fnd_log.string
               (
                  l_log_statement,
                  'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Modify_Visit_Reservations',
                  'After calling AHL_RSV_RESERVATIONS_PVT.Delete_Reservation:l_return_status '||l_return_status
               );
            END IF;
            --    Return status check and throw exception if return status is not success;
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               CLOSE get_del_mtl_req_csr;
               RAISE Fnd_Api.g_exc_error;
            END IF;
      END LOOP; -- For all the material requirements of the deleted tasks
                CLOSE get_del_mtl_req_csr;
      -- Update all the reservations made for this visit with new requested date and scheduled material ID

      AHL_RSV_RESERVATIONS_PVT.Update_Visit_Reservations(
         X_RETURN_STATUS => x_return_status,
         P_VISIT_ID     => p_visit_id);

      IF (l_log_statement >= l_log_current_level)THEN
         fnd_log.string
         (
            l_log_statement,
            'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Modify_Visit_Reservations',
            'After calling AHL_RSV_RESERVATIONS_PVT.Update_Visit_Reservations:x_return_status '||x_return_status
         );
      END IF;

      --    Return status check and throw exception if return status is not success;
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;
   END IF; -- IF l_prev_org_id <> l_cur_org_id

   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         l_log_procedure,
         'ahl.plsql.AHL_LTP_REQST_MATRL_PVT.Modify_Visit_Reservations.end',
         'At the end of PLSQL procedure'
      );
   END IF;
END Modify_Visit_Reservations;

--------------------------------------------------------------------
-- PROCEDURE
--    Update_Material_Reqrs_status
--
-- PURPOSE
--    To update the status of material requirements to 'HISTORY'
--    when the work-order is CANCELLED.
--
-- Bug#6898408   Initial Version      Created by Richa
--------------------------------------------------------------------
PROCEDURE   Update_Material_Reqrs_status
            (  p_api_version        IN          NUMBER,
               p_init_msg_list      IN          VARCHAR2,
               p_commit             IN          VARCHAR2,
               p_validation_level   IN          NUMBER,
               p_module_type        IN          VARCHAR2,
               p_visit_task_id      IN          NUMBER,
               x_return_status      OUT NOCOPY  VARCHAR2,
               x_msg_count          OUT NOCOPY  NUMBER,
               x_msg_data           OUT NOCOPY  VARCHAR2
            )
IS
   -- Declare local variables
   l_api_name      CONSTANT      VARCHAR2(30)      := 'Update_Material_Reqrs_status';
   l_api_version   CONSTANT      NUMBER            := 1.0;
   l_init_msg_list               VARCHAR2(1)       := 'F';
   l_return_status               VARCHAR2(1);
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2(2000);
   L_DEBUG_KEY     CONSTANT      VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   l_sch_material_id             NUMBER            := 0;

BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Update_Material_Reqrs_sts;

  -- Initialize return status to success before any code logic/validation
  x_return_status:= FND_API.G_RET_STS_SUCCESS;

  -- Standard call to check for call compatibility
  IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list = FND_API.G_TRUE
  IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
     FND_MSG_PUB.INITIALIZE;
  END IF;

  -- Log API entry point
  IF (l_log_procedure >= l_log_current_level) THEN
     fnd_log.string(  l_log_procedure,L_DEBUG_KEY ||'.begin','At the start of PL SQL procedure - Task id = '||p_visit_task_id);
  END IF;

  IF (p_visit_task_id IS NULL) THEN
     IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string( l_log_statement,L_DEBUG_KEY,'Task id is null' );
     END IF;
     Fnd_Message.SET_NAME('AHL','AHL_VISIT_TASKID_NULL');
     Fnd_Msg_Pub.ADD;
     RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

  --Update the status of the record to 'HISTORY'
  UPDATE  ahl_Schedule_materials
  SET     STATUS = 'HISTORY',
          OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
          LAST_UPDATE_DATE = sysdate,
          LAST_UPDATED_BY = Fnd_Global.USER_ID,
          LAST_UPDATE_LOGIN = Fnd_Global.LOGIN_ID
  WHERE visit_task_id = p_visit_task_id
  AND STATUS = 'ACTIVE';

  -- Standard check of p_commit
  IF Fnd_Api.To_Boolean (p_commit) THEN
     COMMIT WORK;
  END IF;

  IF (l_log_procedure >= l_log_current_level) THEN
     fnd_log.string(l_log_procedure,
                    L_DEBUG_KEY ||'.end',
                    'No of rows updated - '||SQL%ROWCOUNT);
     fnd_log.string(l_log_procedure,
                    L_DEBUG_KEY ||'.end',
                    'At the end of PL SQL procedure. Return Status =' || x_return_status);
  END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Update_Material_Reqrs_sts;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Material_Reqrs_sts;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN OTHERS THEN
      ROLLBACK TO Update_Material_Reqrs_sts;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data );
END Update_Material_Reqrs_status;

-- -- SKPATHAK :: Bug 8604722 :: 04-MAR-2010 :: Added new procedure
PROCEDURE Get_DFF_Default_Values (
  flexfield_name       IN         fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE,
  context_code         IN         VARCHAR2,
  flex_fields_defaults OUT NOCOPY dff_default_values_type
) IS

  flexfield   fnd_dflex.dflex_r;
  flexinfo    fnd_dflex.dflex_dr;
  contexts    fnd_dflex.contexts_dr;
  i           BINARY_INTEGER;
  j           BINARY_INTEGER;
  segments    fnd_dflex.segments_dr;

  l_api_name  CONSTANT VARCHAR2(30)  := 'Get_DFF_Default_Values';
  L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name;

BEGIN
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure, L_DEBUG_KEY || '.begin', 'Entering Procedure. flexfield_name: ' || flexfield_name);
  END IF;

  fnd_dflex.get_flexfield('AHL', flexfield_name, flexfield, flexinfo);

  IF (context_code IS NULL) THEN
    flex_fields_defaults.ATTRIBUTE_CATEGORY := flexinfo.default_context_value;
  ELSE
    flex_fields_defaults.ATTRIBUTE_CATEGORY := context_code;
  END IF;


  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement, L_DEBUG_KEY, 'flex_fields_defaults.ATTRIBUTE_CATEGORY: ' || flex_fields_defaults.ATTRIBUTE_CATEGORY);
  END IF;

  IF(flex_fields_defaults.ATTRIBUTE_CATEGORY IS NOT NULL)THEN
    -- Get all the contexts
    fnd_dflex.get_contexts(flexfield, contexts);
    -- Find the required Contexts (Just Global or Global+User Selected)
    FOR j IN 1 .. contexts.ncontexts LOOP
      IF(contexts.is_enabled(j) AND (flex_fields_defaults.ATTRIBUTE_CATEGORY = contexts.context_code(j) OR contexts.is_global(j))) THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement, L_DEBUG_KEY, 'Context is enabled. contexts.context_code(j): ' || contexts.context_code(j));
          IF (contexts.is_global(j)) THEN
            fnd_log.string(fnd_log.level_statement, L_DEBUG_KEY, 'Context is global.');
          ELSE
            fnd_log.string(fnd_log.level_statement, L_DEBUG_KEY, 'Context is not global.');
          END IF;
        END IF;
        -- Get Segments for current context
        fnd_dflex.get_segments(fnd_dflex.make_context(flexfield, contexts.context_code(j)), segments, TRUE);
        -- Transfer the default value for each each enabled segment to the OUT parameter
        FOR i IN 1 .. segments.nsegments LOOP
          IF(segments.is_enabled(i)) THEN
            IF(segments.application_column_name(i) = 'ATTRIBUTE1')THEN
              flex_fields_defaults.ATTRIBUTE1 := to_char(segments.default_value(i));
            ELSIF(segments.application_column_name(i) = 'ATTRIBUTE2')THEN
              flex_fields_defaults.ATTRIBUTE2 := to_char(segments.default_value(i));
            ELSIF(segments.application_column_name(i) = 'ATTRIBUTE3')THEN
              flex_fields_defaults.ATTRIBUTE3 := to_char(segments.default_value(i));
            ELSIF(segments.application_column_name(i) = 'ATTRIBUTE4')THEN
              flex_fields_defaults.ATTRIBUTE4 := to_char(segments.default_value(i));
            ELSIF(segments.application_column_name(i) = 'ATTRIBUTE5')THEN
              flex_fields_defaults.ATTRIBUTE5 := to_char(segments.default_value(i));
            ELSIF(segments.application_column_name(i) = 'ATTRIBUTE6')THEN
              flex_fields_defaults.ATTRIBUTE6 := to_char(segments.default_value(i));
            ELSIF(segments.application_column_name(i) = 'ATTRIBUTE7')THEN
              flex_fields_defaults.ATTRIBUTE7 := to_char(segments.default_value(i));
            ELSIF(segments.application_column_name(i) = 'ATTRIBUTE8')THEN
              flex_fields_defaults.ATTRIBUTE8 := to_char(segments.default_value(i));
            ELSIF(segments.application_column_name(i) = 'ATTRIBUTE9')THEN
              flex_fields_defaults.ATTRIBUTE9 := to_char(segments.default_value(i));
            ELSIF(segments.application_column_name(i) = 'ATTRIBUTE10')THEN
              flex_fields_defaults.ATTRIBUTE10 := to_char(segments.default_value(i));
            ELSIF(segments.application_column_name(i) = 'ATTRIBUTE11')THEN
              flex_fields_defaults.ATTRIBUTE11 := to_char(segments.default_value(i));
            ELSIF(segments.application_column_name(i) = 'ATTRIBUTE12')THEN
              flex_fields_defaults.ATTRIBUTE12 := to_char(segments.default_value(i));
            ELSIF(segments.application_column_name(i) = 'ATTRIBUTE13')THEN
              flex_fields_defaults.ATTRIBUTE13 := to_char(segments.default_value(i));
            ELSIF(segments.application_column_name(i) = 'ATTRIBUTE14')THEN
              flex_fields_defaults.ATTRIBUTE14 := to_char(segments.default_value(i));
            ELSIF(segments.application_column_name(i) = 'ATTRIBUTE15')THEN
              flex_fields_defaults.ATTRIBUTE15 := to_char(segments.default_value(i));
            END IF;
          END IF;  -- If Segment(i) is enabled
        END LOOP;  -- Loop on i (all segments)
      END IF;  -- If Context (j) is enabled
    END LOOP;  -- Loop on j (all Contexts)
  END IF;  -- Attribute Category is not null

END Get_DFF_Default_Values;


END AHL_LTP_REQST_MATRL_PVT;

/
