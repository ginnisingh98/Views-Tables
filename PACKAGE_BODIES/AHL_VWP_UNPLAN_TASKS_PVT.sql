--------------------------------------------------------
--  DDL for Package Body AHL_VWP_UNPLAN_TASKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_UNPLAN_TASKS_PVT" AS
/* $Header: AHLVUPTB.pls 120.6.12010000.5 2010/03/28 10:18:57 manesing ship $ */
-----------------------------------------------------------
-- PACKAGE
--    AHL_VWP_UNPLAN_TASKS_PVT
--
-- PURPOSE
--    This package body is a Private API for VWP Unplanned Tasks in Advanced Services Online.
--    It contains specification for pl/sql records and tables.
--
-- PROCEDURES
--      Create_Unplanned_Task
--      Update_Unplanned_Task
--      Delete_Unplanned_Task
--      Asso_Inst_Dept_SR_To_Tasks
--
-- NOTES
--
-- HISTORY
-- 12-MAY_2002    Shbhanda      Created.
-- 21-FEB-2003    YAZHOU        Separated from Task package
-- 06-AUG-2003    SHBHANDA      11.5.10 Changes
-----------------------------------------------------------------
--   Define Global CONSTANTS                                   --
-----------------------------------------------------------------
G_PKG_NAME   CONSTANT VARCHAR2(30) := 'AHL_VWP_UNPLAN_TASKS_PVT';
-----------------------------------------------------------------

--------------------------------------------------------------------
--  START: Defining local functions and procedures SIGNATURES     --
--------------------------------------------------------------------
-- To Check_Visit_Task_Req_Items
PROCEDURE Check_Visit_Task_Req_Items (
   p_task_rec        IN    AHL_VWP_RULES_PVT.Task_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
);

-- To Check_Visit_Task_UK_Items
PROCEDURE Check_Visit_Task_UK_Items (
   p_task_rec         IN    AHL_VWP_RULES_PVT.Task_Rec_Type,
   p_validation_mode  IN    VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status    OUT NOCOPY   VARCHAR2
);

-- To Check_Task_Items
PROCEDURE Check_Task_Items (
   p_Task_rec        IN  AHL_VWP_RULES_PVT.task_rec_type,
   p_validation_mode IN  VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);

--  To assign Null to missing attributes of visit while creation/updation.
PROCEDURE Default_Missing_Attribs(
   p_x_task_rec         IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type
);

--  To associated Service Request Or Serial Number to Tasks
PROCEDURE Asso_Inst_Dept_SR_to_Tasks (
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_x_task_Rec              IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type,

   x_return_status           OUT  NOCOPY    VARCHAR2,
   x_msg_count               OUT  NOCOPY    NUMBER,
   x_msg_data                OUT  NOCOPY    VARCHAR2
);

--------------------------------------------------------------------
--  END: Defining local functions and procedures SIGNATURES     --
--------------------------------------------------------------------

--------------------------------------------------------------------
-- START: Defining local functions and procedures BODY            --
--------------------------------------------------------------------
--------------------------------------------------------------------
-- PROCEDURE
--    Default_Missing_Attribs
--
-- PURPOSE
--    For all optional fields check if its g_miss_num/g_miss_char/
--    g_miss_date then Null else the value

--------------------------------------------------------------------
PROCEDURE Default_Missing_Attribs
( p_x_task_rec         IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type)
AS
BEGIN
         IF p_x_task_rec.DURATION = Fnd_Api.G_MISS_NUM THEN
            p_x_task_rec.DURATION := NULL;
         ELSE
            p_x_task_rec.DURATION := p_x_task_rec.DURATION;
         END IF;

         IF p_x_task_rec.PROJECT_TASK_ID = Fnd_Api.G_MISS_NUM THEN
            p_x_task_rec.PROJECT_TASK_ID := NULL;
         ELSE
            p_x_task_rec.PROJECT_TASK_ID := p_x_task_rec.PROJECT_TASK_ID;
         END IF;

         IF p_x_task_rec.COST_PARENT_ID = Fnd_Api.G_MISS_NUM THEN
            p_x_task_rec.COST_PARENT_ID := NULL;
         ELSE
            p_x_task_rec.COST_PARENT_ID := p_x_task_rec.COST_PARENT_ID;
         END IF;

         IF p_x_task_rec.MR_ROUTE_ID = Fnd_Api.G_MISS_NUM THEN
            p_x_task_rec.MR_ROUTE_ID := NULL;
         ELSE
            p_x_task_rec.MR_ROUTE_ID := p_x_task_rec.MR_ROUTE_ID;
         END IF;

         IF p_x_task_rec.MR_ID = Fnd_Api.G_MISS_NUM THEN
            p_x_task_rec.MR_ID := NULL;
         ELSE
            p_x_task_rec.MR_ID := p_x_task_rec.MR_ID;
         END IF;

         IF p_x_task_rec.UNIT_EFFECTIVITY_ID = Fnd_Api.G_MISS_NUM THEN
            p_x_task_rec.UNIT_EFFECTIVITY_ID := NULL;
         ELSE
            p_x_task_rec.UNIT_EFFECTIVITY_ID := p_x_task_rec.UNIT_EFFECTIVITY_ID;
         END IF;

         IF p_x_task_rec.START_FROM_HOUR = Fnd_Api.G_MISS_NUM THEN
            p_x_task_rec.START_FROM_HOUR := NULL;
         ELSE
            p_x_task_rec.START_FROM_HOUR := p_x_task_rec.START_FROM_HOUR;
         END IF;

         IF p_x_task_rec.PRIMARY_VISIT_TASK_ID = Fnd_Api.G_MISS_NUM THEN
            p_x_task_rec.PRIMARY_VISIT_TASK_ID := NULL;
         ELSE
            p_x_task_rec.PRIMARY_VISIT_TASK_ID := p_x_task_rec.PRIMARY_VISIT_TASK_ID;
         END IF;

         IF  p_x_task_rec.ORIGINATING_TASK_ID = Fnd_Api.G_MISS_NUM THEN
            p_x_task_rec.ORIGINATING_TASK_ID := NULL;
         ELSE
            p_x_task_rec.ORIGINATING_TASK_ID := p_x_task_rec.ORIGINATING_TASK_ID;
         END IF;

         IF  p_x_task_rec.SERVICE_REQUEST_ID = Fnd_Api.G_MISS_NUM THEN
            p_x_task_rec.SERVICE_REQUEST_ID := NULL;
         ELSE
            p_x_task_rec.SERVICE_REQUEST_ID := p_x_task_rec.SERVICE_REQUEST_ID;
         END IF;

         IF p_x_task_rec.attribute_category = Fnd_Api.G_MISS_CHAR THEN
            p_x_task_rec.attribute_category := NULL;
         ELSE
            p_x_task_rec.attribute_category := p_x_task_rec.attribute_category;
         END IF;

         IF p_x_task_rec.attribute1 = Fnd_Api.G_MISS_CHAR THEN
            p_x_task_rec.attribute1 := NULL;
         ELSE
            p_x_task_rec.attribute1 := p_x_task_rec.attribute1;
         END IF;

         IF  p_x_task_rec.attribute2 = Fnd_Api.G_MISS_CHAR THEN
            p_x_task_rec.attribute2 := NULL;
         ELSE
            p_x_task_rec.attribute2 := p_x_task_rec.attribute2;
         END IF;
         --
         IF  p_x_task_rec.attribute3 = Fnd_Api.G_MISS_CHAR THEN
            p_x_task_rec.attribute3 := NULL;
         ELSE
            p_x_task_rec.attribute3 := p_x_task_rec.attribute3;
         END IF;
         --
         IF  p_x_task_rec.attribute4 = Fnd_Api.G_MISS_CHAR THEN
            p_x_task_rec.attribute4 := NULL;
         ELSE
            p_x_task_rec.attribute4 := p_x_task_rec.attribute4;
         END IF;
         --
         IF  p_x_task_rec.attribute5 = Fnd_Api.G_MISS_CHAR THEN
            p_x_task_rec.attribute5 := NULL;
         ELSE
            p_x_task_rec.attribute5 := p_x_task_rec.attribute5;
         END IF;
         --
         IF  p_x_task_rec.attribute6 = Fnd_Api.G_MISS_CHAR THEN
            p_x_task_rec.attribute6 := NULL;
         ELSE
            p_x_task_rec.attribute6 := p_x_task_rec.attribute6;
         END IF;
         --
         IF  p_x_task_rec.attribute7 = Fnd_Api.G_MISS_CHAR THEN
            p_x_task_rec.attribute7 := NULL;
         ELSE
            p_x_task_rec.attribute7 := p_x_task_rec.attribute7;
         END IF;
         --
         IF  p_x_task_rec.attribute8 = Fnd_Api.G_MISS_CHAR THEN
            p_x_task_rec.attribute8 := NULL;
         ELSE
            p_x_task_rec.attribute8 := p_x_task_rec.attribute8;
         END IF;
         --
         IF  p_x_task_rec.attribute9 = Fnd_Api.G_MISS_CHAR THEN
            p_x_task_rec.attribute9 := NULL;
         ELSE
            p_x_task_rec.attribute9 := p_x_task_rec.attribute9;
         END IF;
         --
         IF  p_x_task_rec.attribute10 = Fnd_Api.G_MISS_CHAR THEN
            p_x_task_rec.attribute10 := NULL;
         ELSE
            p_x_task_rec.attribute10 := p_x_task_rec.attribute10;
         END IF;
         --
         IF  p_x_task_rec.attribute11 = Fnd_Api.G_MISS_CHAR THEN
            p_x_task_rec.attribute11 := NULL;
         ELSE
            p_x_task_rec.attribute11 := p_x_task_rec.attribute11;
         END IF;
         --
         IF  p_x_task_rec.attribute12 = Fnd_Api.G_MISS_CHAR THEN
            p_x_task_rec.attribute12 := NULL;
         ELSE
            p_x_task_rec.attribute12 := p_x_task_rec.attribute12;
         END IF;
         --
         IF  p_x_task_rec.attribute13 = Fnd_Api.G_MISS_CHAR THEN
            p_x_task_rec.attribute13 := NULL;
         ELSE
            p_x_task_rec.attribute13 := p_x_task_rec.attribute13;
         END IF;
         --
         IF  p_x_task_rec.attribute14 = Fnd_Api.G_MISS_CHAR THEN
            p_x_task_rec.attribute14 := NULL;
         ELSE
            p_x_task_rec.attribute14 := p_x_task_rec.attribute14;
         END IF;
         --
         IF  p_x_task_rec.attribute15 = Fnd_Api.G_MISS_CHAR THEN
            p_x_task_rec.attribute15 := NULL;
         ELSE
            p_x_task_rec.attribute15 := p_x_task_rec.attribute15;
         END IF;
       --
         IF  p_x_task_rec.description = Fnd_Api.G_MISS_CHAR THEN
            p_x_task_rec.description := NULL;
         ELSE
            p_x_task_rec.description := p_x_task_rec.description;
         END IF;
END Default_Missing_Attribs;

--------------------------------------------------------------------
-- PROCEDURE
--    Asso_Inst_Dept_SR_To_Tasks
--    Some logic corrections and clean up (indentation, debug messages) done
--    by skpathak on 20-OCT-2008 while fixing bug 7016519
--------------------------------------------------------------------
PROCEDURE Asso_Inst_Dept_SR_To_Tasks (
   p_module_type IN            VARCHAR2,
   p_x_task_Rec  IN OUT NOCOPY AHL_VWP_RULES_PVT.task_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2
)
IS
   L_API_VERSION    CONSTANT NUMBER := 1.0;
   L_API_NAME       CONSTANT VARCHAR2(30) := 'Asso_Inst_Dept_SR_To_Tasks';
   L_FULL_NAME      CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   -- local variables defined for the procedure
   l_return_status  VARCHAR2(1);
   l_item_name      VARCHAR2(40);
   l_msg_data       VARCHAR2(2000);

   x                NUMBER := 0;
   l_msg_count      NUMBER;
   l_instance_id      NUMBER;
   l_item_id        NUMBER;
   l_count          NUMBER;
   l_org_id         NUMBER;

   -- To find out Item and MR Header Id combination exists
   CURSOR c_check(c_item_id IN NUMBER, c_mr_header_id IN NUMBER) IS
    SELECT COUNT(*) FROM Ahl_MR_Items_V
    WHERE Inventory_Item_ID = c_item_id AND MR_HEADER_ID = c_mr_header_id;

   -- To find visit related information
   CURSOR c_visit(c_visit_id IN NUMBER) IS
    SELECT * FROM AHL_VISITS_VL
    WHERE VISIT_ID = c_visit_id;
   c_visit_rec  c_visit%ROWTYPE;

   -- Added by rnahata for Issue 105
   -- To fetch if the instance is serial controlled/non-serial controlled.
   CURSOR c_check_inst_nonserial(c_instance_id IN NUMBER) IS
    SELECT 'X'
    FROM mtl_system_items_b mtl, csi_item_instances csi
    WHERE csi.instance_id = c_instance_id
     AND csi.inventory_item_id = mtl.inventory_item_id
     AND NVL(csi.inv_organization_id, csi.inv_master_organization_id) = mtl.organization_id
     AND mtl.serial_number_control_code = 1;

   l_serial_ctrl     VARCHAR2(2) := NULL;
   l_inst_id         NUMBER := 0 ;

BEGIN

   IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(FND_LOG.level_procedure, l_full_name || '.begin', 'At the start of the API');
   END IF;


------------------------- Start of Body  -------------------------------------
--------------------Value OR ID conversion---------------------------
   --Start API Body
   IF p_module_type = 'JSP'
   THEN
       -- Added by rnahata for Issue 105
       -- Copied the instance id into intermediatory variable for non-serialised items
       l_inst_id                  := p_x_task_Rec.instance_id;
       p_x_task_Rec.instance_id   := NULL;
       p_x_task_Rec.department_id := NULL;
   END IF;

   OPEN c_visit(p_x_task_Rec.visit_id);
   FETCH c_visit INTO c_visit_rec;
   CLOSE c_visit;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, l_full_name, 'tasktype= ' || p_x_task_Rec.task_type_code);

   END IF;
   -- Check item name or item id
   IF (p_x_task_Rec.inventory_item_id IS NOT NULL AND
       p_x_task_Rec.inventory_item_id <> Fnd_Api.G_MISS_NUM) AND
      (p_x_task_Rec.item_organization_id IS NOT NULL AND
       p_x_task_Rec.item_organization_id <> Fnd_Api.G_MISS_NUM) THEN
         AHL_VWP_RULES_PVT.Check_Item_name_Or_Id
            (p_item_id        => p_x_task_Rec.inventory_item_id,
             p_org_id         => p_x_task_Rec.item_organization_id,
             p_item_name      => p_x_task_Rec.item_name,
             x_item_id        => l_item_id,
             x_org_id         => l_org_id,
             x_item_name      => l_item_name,
             x_return_status  => l_return_status,
             x_error_msg_code => l_msg_data);
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, l_full_name, 'item id, item name, orgid: ' || l_item_id || '**' || l_item_name || '**' || l_org_id);
      END IF;
      IF NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS
      THEN
          Fnd_Message.SET_NAME('AHL','AHL_VWP_ITEM_NOT_EXISTS');
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

 -- Changes made by skpathak on 20-OCT-2008 while fixing bug 7016519
 -- Removing incorrect checks

 p_x_task_Rec.item_name := l_item_name;


   ELSE  -- Else of item id and item org id exists or not
      IF p_x_task_Rec.item_name IS NULL OR p_x_task_Rec.item_name = FND_API.g_miss_char THEN
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement, l_full_name, 'Item name missing');
         END IF;
         Fnd_Message.SET_NAME('AHL','AHL_VWP_TSK_ITEM_MISSING');
         Fnd_Msg_Pub.ADD;
         RAISE Fnd_Api.G_EXC_ERROR;
      ELSE
   -- Item name is not null, but at least one of item id and org id is null
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement, l_full_name, 'Check item else condition.');
         END IF;
         Fnd_Message.SET_NAME('AHL','AHL_VWP_ITEM_USE_LOV');
         Fnd_Msg_Pub.ADD;
         RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
   END IF; -- End of itemid and itemorg id check

   --Assign the returned value
   p_x_task_Rec.inventory_item_id := l_item_id;
   p_x_task_Rec.item_organization_id := l_org_id;

   /* Begin fix for Bug 4081044 on Dec 22, 2004 by JR */
   -- This check in Ahl_MR_Items_V for a valid item/MR does not cover all cases
   -- viz. MR/PC and MR/Position. So disabling this check for now.
   -- If a validation is required, then all application cases should also be handled
   /******
       IF l_item_id IS NOT NULL AND p_x_task_Rec.MR_Id IS NOT NULL THEN
           OPEN c_check(l_item_id, p_x_task_Rec.MR_Id);
           FETCH c_check INTO l_count;
           CLOSE c_check;

           IF l_count = 0 OR l_count IS NULL THEN
               x_return_status := Fnd_Api.g_ret_sts_error;
                   Fnd_Message.SET_NAME('AHL','AHL_VWP_ITEM_MR_NOT_MATCH');
                   Fnd_Msg_Pub.ADD;
           END IF;
       END IF;
   ******/
   /* End fix for Bug 4081044 on Dec 22, 2004 by JR */

   -- Begin changes by rnahata for Issue 105
   -- Check if the item is serial/non-serial controlled
   OPEN c_check_inst_nonserial (l_inst_id);
   FETCH c_check_inst_nonserial INTO l_serial_ctrl;
   IF c_check_inst_nonserial%NOTFOUND THEN
      CLOSE c_check_inst_nonserial;
      -- Convert serial number to instance/ serial id
      IF (p_x_task_Rec.serial_number IS NOT NULL AND p_x_task_Rec.serial_number <> Fnd_Api.G_MISS_CHAR) OR
         (p_x_task_Rec.instance_id IS NOT NULL AND p_x_task_Rec.instance_id <> Fnd_Api.G_MISS_CHAR) THEN

         AHL_VWP_RULES_PVT.Check_serial_name_Or_Id
              (p_item_id          => p_x_task_Rec.inventory_item_id,
               p_org_id           => p_x_task_Rec.item_organization_id,
               p_serial_id        => Null,
               p_serial_number    => p_x_task_Rec.serial_number,
               x_serial_id        => l_instance_id,
               x_return_status    => l_return_status,
               x_error_msg_code   => l_msg_data);

         IF NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
            Fnd_Message.SET_NAME('AHL','AHL_VWP_SERIAL_NOT_EXISTS');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
         ELSE
            --Assign the returned value
             p_x_task_Rec.instance_id := l_instance_id;
         END IF;
      ELSE
          -- Neither Serial Number not Instance Id has been passed
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, l_full_name, 'Check serial not found else');
         END IF;
         Fnd_Message.SET_NAME('AHL','AHL_VWP_TSK_SERIAL_MISSING');
         Fnd_Msg_Pub.ADD;
         RAISE Fnd_Api.G_EXC_ERROR;
      END IF; --Serial number not null
   ELSE --non serial controlled item
      p_x_task_Rec.instance_id := l_inst_id;
      CLOSE c_check_inst_nonserial;
   END IF; --non-serial ctrl
   -- End changes by rnahata for Issue 105

   IF c_visit_rec.organization_id IS NOT NULL THEN
      -- Get dept code using dept description
      IF (p_x_task_Rec.dept_name IS NOT NULL AND p_x_task_Rec.dept_name <> Fnd_Api.G_MISS_CHAR ) THEN

         AHL_VWP_RULES_PVT.Check_Dept_Desc_Or_Id
            (p_organization_id  => c_visit_rec.organization_id,
             p_dept_name        => p_x_task_Rec.dept_name,
             p_department_id    => Null,
             x_department_id    => p_x_task_Rec.department_id,
             x_return_status    => l_return_status,
             x_error_msg_code   => l_msg_data);

         IF NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS
         THEN
            Fnd_Message.SET_NAME('AHL','AHL_VWP_DEPT_NOT_EXISTS');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;

         -- Changes for Post 11.5.10 by amagrawa
         Ahl_vwp_rules_pvt.CHECK_DEPARTMENT_SHIFT
           (P_DEPT_ID       => p_x_task_Rec.department_id,
            X_RETURN_STATUS => l_return_status);

         IF (NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS)  THEN
             Fnd_Message.SET_NAME('AHL','AHL_VWP_NO_DEPT_SHIFT');
           Fnd_Msg_Pub.ADD;
               RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
      ELSE
         p_x_task_Rec.dept_name     := NULL;
         -- Post 11.5.10 changes by Senthil
         p_x_task_Rec.department_id := c_visit_rec.department_id;
      END IF;
       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, l_full_name, 'Dept ID= ' || p_x_task_Rec.department_id);
      END IF;
   ELSE  -- Else of if visit org not exists
      IF (p_x_task_Rec.dept_name IS NOT NULL AND p_x_task_Rec.dept_name <> Fnd_Api.G_MISS_CHAR ) THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement, l_full_name, 'NO ORGANIZATION FOR VISIT');
         END IF;
         Fnd_Message.SET_NAME('AHL','AHL_VWP_VISIT_NO_ORG_EXISTS');
         Fnd_Msg_Pub.ADD;
         RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
   END IF; -- End of if visit org exists


   IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
       FND_LOG.string(FND_LOG.level_procedure, l_full_name || '.end', 'At the normal execution end of the procedure');
   END IF;


------------------------- Finish of Body -------------------------------------
END Asso_Inst_Dept_SR_To_Tasks;


--------------------------------------------------------------------
-- PROCEDURE
--    Create_Unplanned_Task
--    Some indentation and debug messages clean up done
--    by skpathak on 20-OCT-2008 while fixing bug 7016519
--
--------------------------------------------------------------------
PROCEDURE Create_Unplanned_Task (
   p_api_version       IN            NUMBER,
   p_init_msg_list     IN            VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN            VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN            NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type       IN            VARCHAR2  := 'JSP',
   p_x_task_Rec        IN OUT NOCOPY AHL_VWP_RULES_PVT.task_rec_type,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
 )
IS
   L_API_VERSION CONSTANT NUMBER := 1.0;
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Create_Unplanned_Task';
   L_FULL_NAME            CONSTANT VARCHAR2(100) := 'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME;

   -- local variables defined for the procedure
   l_return_status        VARCHAR2(1);
   l_msg_data             VARCHAR2(2000);
   l_msg_count            NUMBER;
   l_item_id              NUMBER;
   l_instance_id          NUMBER;
   l_org_id               NUMBER;
   l_mr_header_id         NUMBER;
   l_visit_id             NUMBER;
   l_department_id        NUMBER;
   l_count                NUMBER;
   i                      NUMBER:=0;
   j                      NUMBER:=0;

--  Table type for storing MR Id
   TYPE MR_Tbl IS TABLE OF INTEGER
   INDEX BY BINARY_INTEGER;

--  Defining variables to table types
   MR_Id_tbl    MR_tbl;
   MR_Serial_Tbl    AHL_VWP_RULES_PVT.MR_Serial_Tbl_Type;

-- yazhou 15Nov2005 starts
-- Code clean up

-- To find all child MRs which acts as SUMMARY TASK
 /* For Bug# 3152532 fix by shbhanda dated 02-Dec-03*/
 --Cleaned up cxcheng 4-Aug-04
 --Returns 1 level of child MRs
/* CURSOR get_child_mrs_csr(x_mr_id IN NUMBER) IS
  SELECT REL.RELATED_MR_HEADER_ID
    FROM AHL_MR_HEADERS_B AMHB, AHL_MR_RELATIONSHIPS_APP_V REL
    WHERE REL.MR_HEADER_ID = x_mr_id
     AND REL.RELATED_MR_HEADER_ID = AMHB.MR_HEADER_ID
     AND AMHB.MR_STATUS_CODE = 'COMPLETE'
     AND AMHB.VERSION_NUMBER IN
           ( SELECT VERSION_NUMBER
              FROM   AHL_MR_HEADERS_B
              WHERE  TITLE = AMHB.TITLE
               AND    TRUNC(SYSDATE) BETWEEN TRUNC(nvl(EFFECTIVE_FROM, sysdate-1)) AND
                                           TRUNC(NVL(EFFECTIVE_TO,SYSDATE+1))
                AND   MR_STATUS_CODE = 'COMPLETE');
*/
-- yazhou 15Nov2005 ends

  -- To find visit related information
   CURSOR c_Visit (p_visit_id IN NUMBER) IS
      SELECT Any_Task_Chg_Flag,visit_id
      FROM  Ahl_Visits_VL
      WHERE VISIT_ID = p_visit_id;
      l_visit_csr_rec      c_Visit%ROWTYPE;

-- yazhou 11Nov2005 starts
-- Bug fix#4559475

   -- To find any visit task exists for the retrieve Serial Number and MR_ID and other info
   CURSOR c_MR_Visit (x_id IN NUMBER, x_mr_id IN NUMBER, x_serial_id in NUMBER) IS
     SELECT AMHV.TITLE
        FROM AHL_VISIT_TASKS_B AVTB, AHL_MR_HEADERS_APP_V AMHV
       WHERE AVTB.MR_ID = AMHV.MR_HEADER_ID
       AND AVTB.MR_Id in (select mr_header_id
                            from ahl_mr_headers_b
                           where title in
                           (select title from ahl_mr_headers_b where mr_header_id = x_mr_id))
       AND AVTB.INSTANCE_ID = x_serial_id
       AND AVTB.VISIT_ID = x_id
       AND (AVTB.STATUS_CODE IS NULL OR AVTB.STATUS_CODE not in ('CANCELLED','DELETED'));

-- yazhou 11Nov2005 ends

   c_MR_Visit_rec c_MR_Visit%ROWTYPE;


        l_ue_id NUMBER;
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Create_Unplanned_Task;
   -- Debug info.
     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure, l_full_name || '.begin', 'Entering Procedure');
   END IF;

   IF Fnd_Api.to_boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   IF NOT Fnd_Api.compatible_api_call (
         L_API_VERSION,
         p_api_version,
         L_API_NAME,
         G_PKG_NAME
   ) THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;
   x_return_status := Fnd_Api.g_ret_sts_success;

   -- Calling Asso_Inst_Dept_SR_to_Tasks API
   Asso_Inst_Dept_SR_to_Tasks (
     p_module_type    => p_module_type,
     p_x_task_Rec     => p_x_task_Rec,

     x_return_status  => l_return_status,
     x_msg_count      => l_msg_count,
     x_msg_data       => l_msg_data
   );

   -- Assigning record attributes in local variables
   l_visit_id             := p_x_task_Rec.visit_id;
   l_department_id        := p_x_task_Rec.department_id;
   l_instance_id            := p_x_task_Rec.instance_id;
   l_item_id              := p_x_task_Rec.inventory_item_id;
   l_org_id               := p_x_task_Rec.item_organization_id;
   l_mr_header_id         := p_x_task_Rec.MR_ID;

   IF l_department_id = FND_API.g_miss_num THEN
        l_department_id := NULL;
   END IF;

   IF l_instance_id = FND_API.g_miss_num THEN
      l_instance_id := NULL;
   END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	fnd_log.string(fnd_log.level_statement, l_full_name, 'Visitid , service, dept: ' || l_visit_id || '---' || '---' || l_department_id);
	fnd_log.string(fnd_log.level_statement, l_full_name, 'Serial, Item, Item Org: ' || l_instance_id || '---' ||l_item_id || '---' || l_org_id);
	fnd_log.string(fnd_log.level_statement, l_full_name, 'mr_header:' ||l_mr_header_id );
   END IF;

--B6452310 - sowsubra - commented to allow duplicate MR's in a visit
--Begin Comment out
/***
  OPEN c_MR_Visit (l_visit_id,l_mr_header_id,l_serial_id);
  FETCH c_MR_Visit INTO c_MR_Visit_rec;

  IF c_MR_Visit%FOUND THEN
      -- ERROR MESSAGE
      x_return_status := Fnd_Api.g_ret_sts_error;
          Fnd_Message.SET_NAME('AHL','AHL_VWP_MR_FOUND');
          Fnd_Message.SET_TOKEN('MR_TITLE', c_MR_Visit_rec.Title);
          Fnd_Msg_Pub.ADD;
      CLOSE c_MR_Visit;
***/
--End Comment out

/*  OPEN c_MR_Visit (l_visit_id,l_mr_header_id,l_serial_id);
  FETCH c_MR_Visit INTO l_count;
  CLOSE c_MR_Visit;

  IF l_count > 0 THEN
      -- ERROR MESSAGE
      x_return_status := Fnd_Api.g_ret_sts_error;
          Fnd_Message.SET_NAME('AHL','AHL_VWP_MR_FOUND');
          Fnd_Msg_Pub.ADD;
*/
--B6452310 - sowsubra
--  ELSE
--      CLOSE c_MR_Visit;

-- yazhou 15Nov2005 starts
-- Code clean up
/*
----------------------------------------------------------------------------------------------------------
 -- FOR MAIN MR HEADER ID'S
  -- To store all MR Headers in table datatype
    i := 0;
    MR_Id_Tbl(i):= l_mr_header_id;
    i := i + 1;
    j :=0;
----------------------------------------------------------------------------------------------------------
  --Do breadth 1st iterative fetch of child MRs. This is because we can not
  -- do a join of the MR relationships tree with the connect by clause.
  WHILE (j < i) LOOP
    OPEN get_child_mrs_csr(MR_Id_Tbl(j));
    <<l_inner_loop>>
    LOOP
       --Add new childs to the end of the mr id table
       FETCH get_child_mrs_csr INTO MR_Id_Tbl(i);
       EXIT l_inner_loop WHEN get_child_mrs_csr%NOTFOUND;
       i:=i+1;
    END LOOP l_inner_loop;
    CLOSE get_child_mrs_csr;
    j:=j+1;
  END LOOP;
----------------------------------------------------------------------------------------------------------
*/
-- yazhou 15Nov2005 ends

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, l_full_name, 'About to call AHL_UMP_UNPLANNED_PVT.CREATE_UNIT_EFFECTIVITY with p_mr_header_id = ' || l_mr_header_id || ' and p_instance_id = ' || l_instance_id);
   END IF;

  AHL_UMP_UNPLANNED_PVT.CREATE_UNIT_EFFECTIVITY(
     p_api_version            => 1.0,
     x_return_status          => l_return_status,
     x_msg_count              => l_msg_count,
     x_msg_data               => l_msg_data,
     p_mr_header_id           => l_mr_header_id,
     p_instance_id            => l_instance_id,
     x_orig_ue_id             => l_ue_id);

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, l_full_name, 'Returned from call to AHL_UMP_UNPLANNED_PVT.CREATE_UNIT_EFFECTIVITY. x_return_status = ' || l_return_status || ' and x_orig_ue_id = ' || l_ue_id);
   END IF;

   IF l_msg_count > 0 OR  NVL(l_return_status,'X') <> Fnd_Api.G_RET_STS_SUCCESS THEN
        X_msg_count := l_msg_count;
        X_return_status := Fnd_Api.G_RET_STS_ERROR;
        RAISE Fnd_Api.G_EXC_ERROR;
   END IF;


   p_x_task_Rec.task_type_code :='UNPLANNED';
   p_x_task_Rec.unit_effectivity_id :=l_ue_id;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, l_full_name, 'About to call AHL_VWP_PLAN_TASKS_PVT.CREATE_PLANNED_TASK');
   END IF;

   AHL_VWP_PLAN_TASKS_PVT.CREATE_PLANNED_TASK(
      p_api_version   => 1.0,
      p_x_task_rec    => p_x_task_Rec,
      x_return_status          => l_return_status,
      x_msg_count              => l_msg_count,
      x_msg_data               => l_msg_data);

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, l_full_name, 'Returned from call to AHL_VWP_PLAN_TASKS_PVT.CREATE_PLANNED_TASK. x_return_status = ' || l_return_status || ', p_x_task_rec.VISIT_TASK_ID = ' || p_x_task_rec.VISIT_TASK_ID);
   END IF;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   UPDATE ahl_visit_tasks_b  SET task_type_code = 'UNPLANNED'
   WHERE visit_id = l_visit_id
   AND visit_task_id IN
   (
       SELECT visit_task_id
       FROM  ahl_visit_tasks_b
       WHERE visit_id = l_visit_id
       START WITH mr_id = l_mr_header_id AND originating_task_id IS NULL
       /*B6452310 - sowsubra - after the implementation of same mr added muliple times, assume a planned
       requirement is added followed by an unplanned requirement. Then here all the tasks should not be
       made Unplanned, the newly added tasks for the unplanned requirement should only be made unplanned
       and which can be uniquely identified by the UE id generated.*/
       AND UNIT_EFFECTIVITY_ID = p_x_task_Rec.unit_effectivity_id
       CONNECT BY cost_parent_id = PRIOR visit_task_id
   )
   AND TASK_TYPE_CODE = 'PLANNED';

   OPEN C_VISIT(l_visit_id);
   FETCH c_visit into l_visit_csr_rec;
   IF C_VISIT%FOUND AND l_visit_csr_rec.Any_Task_Chg_Flag='N' THEN
        AHL_VWP_RULES_PVT.update_visit_task_flag(
              p_visit_id         =>l_visit_csr_rec.visit_id,
              p_flag             =>'Y',
              x_return_status    =>x_return_status);
   END IF;
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          CLOSE C_VISIT;
          RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE C_VISIT;
   -- B6452310 - sowsubra
   --  END IF;

   ------------------------- finish -------------------------------
    --
    -- END of API body.
    --
    -- Standard check of p_commit.
   IF Fnd_Api.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
   Fnd_Msg_Pub.count_and_get(
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure, l_full_name ||'.end', 'Exiting procedure');
   END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Create_Unplanned_Task;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get(
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Create_Unplanned_Task;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Unplanned_Task;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
    THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Create_Unplanned_Task;

--------------------------------------------------------------------
-- PROCEDURE
--    Update_Unplanned_Task
--
-- PURPOSE
--    To update Unplanned task for the Maintainance visit.
--------------------------------------------------------------------
PROCEDURE Update_Unplanned_Task (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type       IN  VARCHAR2  := 'JSP',

   p_x_task_rec        IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
)
IS
   L_API_VERSION          CONSTANT NUMBER := 1.0;
   L_API_NAME             CONSTANT VARCHAR2(30) := 'Update_Unplanned_Task';
   L_FULL_NAME            CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   -- local variables defined for the procedure
   l_task_rec             AHL_VWP_RULES_PVT.Task_Rec_Type := p_x_task_rec;
   l_return_status        VARCHAR2(1);
   l_msg_data             VARCHAR2(2000);

   l_msg_count            NUMBER;
   l_count                NUMBER;
   l_cost_parent_id       NUMBER;
   l_department_id        NUMBER;
   l_planned_order_flag VARCHAR2(1);

   -- To find task related information
   CURSOR c_Task (x_id IN NUMBER) IS
      SELECT * FROM  Ahl_Visit_Tasks_VL
      WHERE  VISIT_TASK_ID = x_id;
   c_Task_rec    c_Task%ROWTYPE;
   c_upd_Task_rec    c_Task%ROWTYPE;

   -- To find visit related information
   CURSOR c_Visit (x_id IN NUMBER) IS
      SELECT * FROM Ahl_Visits_VL
      WHERE  VISIT_ID = x_id;
   c_Visit_rec    c_Visit%ROWTYPE;

 BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Update_Unplanned_Task;

   -- Debug info.
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||':*************************Start*************************');
   END IF;

   IF Fnd_Api.to_boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   --  Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME
   ) THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;

------------------------Start of API Body------------------------------------
   OPEN c_Visit(l_Task_rec.visit_id);
   FETCH c_Visit INTO c_Visit_rec;
   CLOSE c_Visit;

   OPEN c_Task(l_Task_rec.visit_task_id);
   FETCH c_Task INTO c_Task_rec;
   CLOSE c_Task;

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||': Visit Id/Task Id  = ' || l_task_rec.visit_id || '-' || l_task_rec.visit_task_id);
    fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||': Inventory Id /org/name =' || l_task_rec.inventory_item_id || '-' || l_task_rec.item_organization_id || '-' || l_task_rec.item_name);
    fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||': Cost Id -- Number=' || l_task_rec.cost_parent_id || '**' || l_task_rec.cost_parent_number );
    fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||': Originating Id/Number=' || l_task_rec.originating_task_id  || '**' || l_task_rec.orginating_task_number);
    fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||': Object version number = ' || l_task_rec.object_version_number);
    fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||': Duration from record = ' || l_task_rec.duration);
    fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||': Visit start from hour/duration=' || '-' || l_task_rec.start_from_hour || '-' || l_task_rec.duration);
    fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||': Task Type code/value=' ||  l_task_rec.task_type_code || '-' || l_task_rec.task_type_value );
    fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||': department_id = ' ||  l_task_rec.department_id );
  END IF;

  ----------- Start defining and validate all LOVs on Create Visit's Task UI Screen---
     --
     -- For DEPARTMENT
     -- Convert department name to department id
     IF (l_task_rec.dept_name IS NOT NULL AND l_task_rec.dept_name <> Fnd_Api.G_MISS_CHAR ) THEN

          AHL_VWP_RULES_PVT.Check_Dept_Desc_Or_Id
                (p_organization_id  => c_visit_rec.organization_id,
                 p_dept_name        => l_task_rec.dept_name,
                 p_department_id    => NULL,
                 x_department_id    => l_department_id,
                 x_return_status    => l_return_status,
                 x_error_msg_code   => l_msg_data);

          IF NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS
          THEN
              Fnd_Message.SET_NAME('AHL','AHL_VWP_DEPT_NOT_EXISTS');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.G_EXC_ERROR;
          END IF;

          --Assign the returned value
          l_task_rec.department_id := l_department_id;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
           fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||': Dept ID= ' || l_Task_rec.department_id );
           fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||': Cost parent= ' || l_Task_rec.cost_parent_number);
  END IF;

     --
     -- For COST PARENT TASK
     -- Convert cost parent number to id
      IF (l_Task_rec.cost_parent_number IS NOT NULL AND
          l_Task_rec.cost_parent_number <> Fnd_Api.G_MISS_NUM ) THEN

          AHL_VWP_RULES_PVT.Check_Visit_Task_Number_OR_ID
               (p_visit_task_id      => l_Task_rec.cost_parent_id,
                p_visit_task_number  => l_Task_rec.cost_parent_number,
                p_visit_id           => l_Task_rec.visit_id,
                x_visit_task_id      => l_cost_parent_id,
                x_return_status      => l_return_status,
                x_error_msg_code     => l_msg_data);

          IF NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS
          THEN
              Fnd_Message.SET_NAME('AHL','AHL_VWP_PARENT_NOT_EXISTS');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.g_exc_error;
          END IF;

           --Assign the returned value
           l_Task_rec.cost_parent_id := l_cost_parent_id;
     END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||': Cost parent ID = ' || l_Task_rec.cost_parent_id);
         fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||': Validation: Start -- For COST PARENT ');
     END IF;

   -- To Check for cost parent task id not forming loop
   IF (l_Task_rec.cost_parent_id IS NOT NULL AND
        l_Task_rec.cost_parent_id <> Fnd_Api.G_MISS_NUM ) THEN

        AHL_VWP_RULES_PVT.Check_Cost_Parent_Loop
            (p_visit_id        => l_Task_rec.visit_id,
             p_visit_task_id   => l_Task_rec.visit_task_id ,
             p_cost_parent_id  => l_Task_rec.cost_parent_id
             );

   END IF;

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||': Validation: End -- For COST PARENT ');
   END IF;

   ----------- End defining and validate all LOVs on Create Visit's Task UI Screen---


   ----------------------- validate ----------------------

       IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||':Validate');
   END IF;

    -- For all optional fields check if its g_miss_num/g_miss_char/g_miss_date
    -- then Null else the value call Default_Missing_Attribs procedure
        Default_Missing_Attribs
        (
        p_x_task_rec             => l_Task_rec
        );

   IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_item THEN
      Check_Task_Items (
         p_task_rec => p_x_task_rec,
         p_validation_mode    => Jtf_Plsql_Api.g_update,
         x_return_status      => l_return_status
      );
      IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;
   END IF;

    -- Check Object version number.
   IF (c_task_rec.object_version_number <> l_task_rec.object_version_number) THEN
       Fnd_Message.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
       Fnd_Msg_Pub.ADD;
       RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

-- Post 11.5.10 Changes by Senthil.
   IF(L_task_rec.STAGE_ID IS NOT NULL OR L_task_rec.STAGE_NAME IS NOT NULL) THEN
  AHL_VWP_VISITS_STAGES_PVT.VALIDATE_STAGE_UPDATES(
   P_API_VERSION      =>  1.0,
   P_VISIT_ID         =>  l_Task_rec.visit_id,
   P_VISIT_TASK_ID    =>  l_Task_rec.visit_task_id,
   P_STAGE_NAME       =>  L_task_rec.STAGE_NAME,
   X_STAGE_ID         =>  L_task_rec.STAGE_ID,
   X_RETURN_STATUS    =>  l_return_status,
   X_MSG_COUNT        =>  l_msg_count,
   X_MSG_DATA         =>  l_msg_data  );

   END IF;

    --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 OR l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

 -------------------------- update --------------------
     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||':Update');
   END IF;

  --Modified by mpothuku to fix LTP forum issue #208 on 04/19/05
  IF( nvl(p_module_type,'XXX') <> 'LTP') THEN
    l_task_rec.originating_task_id := c_task_rec.originating_task_id;
  END IF;
  --End mpothuku

    Ahl_Visit_Tasks_Pkg.UPDATE_ROW (
      X_VISIT_TASK_ID         => l_task_rec.visit_task_id,
      X_VISIT_TASK_NUMBER     => c_task_rec.visit_task_number,
      X_OBJECT_VERSION_NUMBER => l_task_rec.OBJECT_VERSION_NUMBER + 1,
      X_VISIT_ID              => l_task_rec.visit_id,
      X_PROJECT_TASK_ID       => c_task_rec.project_task_id,
      X_COST_PARENT_ID        => l_task_rec.cost_parent_id,
      X_MR_ROUTE_ID           => c_task_rec.mr_route_id,
      X_MR_ID                 => c_task_rec.mr_id,
      X_DURATION              => c_task_rec.duration,
      X_UNIT_EFFECTIVITY_ID   => c_task_rec.unit_effectivity_id,
      X_START_FROM_HOUR       => l_task_rec.start_from_hour,
      X_INVENTORY_ITEM_ID     => c_task_rec.inventory_item_id,
      X_ITEM_ORGANIZATION_ID  => c_task_rec.item_organization_id,
      X_INSTANCE_ID           => c_Task_rec.instance_id,
      X_PRIMARY_VISIT_TASK_ID => c_task_rec.primary_visit_task_id,
      X_ORIGINATING_TASK_ID   => l_task_rec.originating_task_id, --c_task_rec.originating_task_id,
      X_SERVICE_REQUEST_ID    => c_task_rec.service_request_id,
      X_TASK_TYPE_CODE        => l_task_rec.task_type_code,
      X_DEPARTMENT_ID         => l_task_rec.department_id,
      X_SUMMARY_TASK_FLAG     => 'N',
      X_PRICE_LIST_ID         => c_task_rec.price_list_id,
      X_STATUS_CODE           => c_task_rec.status_code,
      X_ESTIMATED_PRICE       => c_task_rec.estimated_price,
      X_ACTUAL_PRICE          => c_task_rec.actual_price,
      X_ACTUAL_COST           => c_task_rec.actual_cost,
-- Changes for 11.5.10 by Senthil.
      X_STAGE_ID              => l_task_rec.STAGE_ID,
   -- Added cxcheng POST11510--------------
      -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010
      -- Pass past dates too for the below 4 columns, and if it is null, pass null for all the 4 columns
      X_START_DATE_TIME       => l_task_rec.PAST_TASK_START_DATE,
      X_END_DATE_TIME         => l_task_rec.PAST_TASK_END_DATE,
      X_PAST_TASK_START_DATE  => l_task_rec.PAST_TASK_START_DATE,
      X_PAST_TASK_END_DATE    => l_task_rec.PAST_TASK_END_DATE,

   -- manisaga commented the attributes loading from c_task_rec and added from
   -- l_task_rec for DFF implementation on 19-Feb-2010  --Start
   /*
      X_ATTRIBUTE_CATEGORY    => c_task_rec.ATTRIBUTE_CATEGORY,
      X_ATTRIBUTE1            => c_task_rec.ATTRIBUTE1,
      X_ATTRIBUTE2            => c_task_rec.ATTRIBUTE2,
      X_ATTRIBUTE3            => c_task_rec.ATTRIBUTE3,
      X_ATTRIBUTE4            => c_task_rec.ATTRIBUTE4,
      X_ATTRIBUTE5            => c_task_rec.ATTRIBUTE5,
      X_ATTRIBUTE6            => c_task_rec.ATTRIBUTE6,
      X_ATTRIBUTE7            => c_task_rec.ATTRIBUTE7,
      X_ATTRIBUTE8            => c_task_rec.ATTRIBUTE8,
      X_ATTRIBUTE9            => c_task_rec.ATTRIBUTE9,
      X_ATTRIBUTE10           => c_task_rec.ATTRIBUTE10,
      X_ATTRIBUTE11           => c_task_rec.ATTRIBUTE11,
      X_ATTRIBUTE12           => c_task_rec.ATTRIBUTE12,
      X_ATTRIBUTE13           => c_task_rec.ATTRIBUTE13,
      X_ATTRIBUTE14           => c_task_rec.ATTRIBUTE14,
      X_ATTRIBUTE15           => c_task_rec.ATTRIBUTE15,
   */
      X_ATTRIBUTE_CATEGORY    => l_task_rec.ATTRIBUTE_CATEGORY,
      X_ATTRIBUTE1            => l_task_rec.ATTRIBUTE1,
      X_ATTRIBUTE2            => l_task_rec.ATTRIBUTE2,
      X_ATTRIBUTE3            => l_task_rec.ATTRIBUTE3,
      X_ATTRIBUTE4            => l_task_rec.ATTRIBUTE4,
      X_ATTRIBUTE5            => l_task_rec.ATTRIBUTE5,
      X_ATTRIBUTE6            => l_task_rec.ATTRIBUTE6,
      X_ATTRIBUTE7            => l_task_rec.ATTRIBUTE7,
      X_ATTRIBUTE8            => l_task_rec.ATTRIBUTE8,
      X_ATTRIBUTE9            => l_task_rec.ATTRIBUTE9,
      X_ATTRIBUTE10           => l_task_rec.ATTRIBUTE10,
      X_ATTRIBUTE11           => l_task_rec.ATTRIBUTE11,
      X_ATTRIBUTE12           => l_task_rec.ATTRIBUTE12,
      X_ATTRIBUTE13           => l_task_rec.ATTRIBUTE13,
      X_ATTRIBUTE14           => l_task_rec.ATTRIBUTE14,
      X_ATTRIBUTE15           => l_task_rec.ATTRIBUTE15,
   -- manisaga commented the attributes loading from c_task_rec and added from
   -- l_task_rec for DFF implementation on 19-Feb-2010  --End

      X_VISIT_TASK_NAME       => l_task_rec.visit_task_name,
      X_DESCRIPTION           => l_task_rec.description,
      X_QUANTITY              => c_task_rec.QUANTITY, -- Added by rnahata for Issue 105
      X_LAST_UPDATE_DATE      => SYSDATE,
      X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
      X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID );


      -- Assign back to in/out parameter
      p_x_task_rec := l_task_rec;

  ------------------------End of API Body------------------------------------
    -- Added cxcheng POST11510--------------
   --Now adjust the times derivation for task

   -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 ::Call Adjust_Task_Times only if past date is null
   IF l_task_rec.PAST_TASK_START_DATE IS NULL THEN
     AHL_VWP_TIMES_PVT.Adjust_Task_Times(p_api_version      => 1.0,
                                         p_init_msg_list    => Fnd_Api.G_FALSE,
                                         p_commit           => Fnd_Api.G_FALSE,
                                         p_validation_level => Fnd_Api.G_VALID_LEVEL_FULL,
                                         x_return_status    => l_return_status,
                                         x_msg_count        => l_msg_count,
                                         x_msg_data         => l_msg_data,
                                         p_task_id          => l_task_rec.visit_task_id);
   END IF;

   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 OR l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;


       -- To Update visit attribute any_task_chg_flag for costing purpose
       -- Looking for changes in 'Start from hour' attributes of task

         IF NVL(l_task_rec.Start_from_hour,-30) <> NVL(c_task_rec.Start_from_hour,-30) OR
            NVL(l_task_rec.STAGE_ID,-30) <> NVL(c_task_rec.STAGE_ID,-30) OR
            NVL(l_task_rec.department_id,-30) <> NVL(c_task_rec.department_id,-30) THEN

       OPEN c_Task(l_Task_rec.visit_task_id);
       FETCH c_Task INTO c_upd_Task_rec;
       CLOSE c_Task;

             IF c_upd_Task_rec.start_date_time IS NOT NULL THEN

         AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials (
              p_api_version         => 1.0,
              p_init_msg_list       => FND_API.g_false,
              p_commit              => FND_API.g_false,
              p_validation_level    => FND_API.g_valid_level_full,
              p_visit_id            => l_task_rec.visit_id,
              p_visit_task_id       => NULL,
              p_org_id              => NULL,
              p_start_date          => NULL,
              p_operation_flag      => 'U',
              x_planned_order_flag  => l_planned_order_flag ,
              x_return_status       => l_return_status,
              x_msg_count           => l_msg_count,
              x_msg_data            => l_msg_data );

          IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||'After AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials');
       fnd_log.string(fnd_log.level_procedure,'ahl.plsql.',l_full_name ||'Planned Order Flag : ' || l_planned_order_flag);
          END IF;

          IF l_return_status <> 'S' THEN
         RAISE Fnd_Api.G_EXC_ERROR;
          END IF;

        END IF; -- Start_date_time check.

          IF c_visit_rec.any_task_chg_flag = 'N' THEN
            AHL_VWP_RULES_PVT.Update_Visit_Task_Flag
                (p_visit_id      => l_task_rec.visit_id,
               p_flag          => 'Y',
                 x_return_status => x_return_status);
          END IF;

          END IF;

   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||':*************************END*************************');
   END IF;


EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Update_Unplanned_Task;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Unplanned_Task;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Unplanned_Task;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
    THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Update_Unplanned_Task;

--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Unplanned_Task
--
-- PURPOSE
-- To delete Unplanned tasks for the Maintenace visit.
-- Modifying the Unplanned tasks for costing by rtadikon
--------------------------------------------------------------------
PROCEDURE Delete_Unplanned_Task (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type       IN  VARCHAR2  := 'JSP',
   p_visit_task_ID     IN  NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
)

IS

   -- local variables defined for the procedure
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Delete Unplanned Task';
   l_full_name   CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_Api_name;
   l_origin_id   NUMBER;
   l_msg_count   NUMBER;

  -- To find all tasks related information
   CURSOR c_Task (x_id IN NUMBER) IS
      SELECT * FROM Ahl_Visit_Tasks_VL
      WHERE Visit_Task_ID = x_id;
      c_task_rec    c_Task%ROWTYPE;

BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Delete_Unplanned_Task;

   -- Check if API is called in debug mode. If yes, enable debug.
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||':*************************START*************************');
   END IF;

   IF Fnd_Api.to_boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   --  Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;

------------------------Start of API Body------------------------------------
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
              fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||':Task Id' || p_visit_task_ID);
      END IF;

   -- To check if the input taskid exists in task entity.

      OPEN c_Task(p_Visit_Task_ID);
      FETCH c_Task INTO c_task_rec;

      IF c_Task%NOTFOUND THEN
    CLOSE c_Task;
    Fnd_Message.set_name('AHL', 'AHL_VWP_TASK_ID_INVALID');
    FND_MESSAGE.SET_TOKEN('TASK_ID',p_visit_task_id,false);
    Fnd_Msg_Pub.ADD;
    RAISE Fnd_Api.g_exc_error;
      ELSE
    CLOSE c_Task;

    l_origin_id:= c_task_rec.originating_task_id;

    IF l_origin_id IS NOT NULL THEN

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', ' Before Call to Delete Summary task ');
      END IF;

      AHL_VWP_TASKS_PVT.Delete_Summary_Task(
      p_api_version      => p_api_version,
      p_init_msg_list    => Fnd_Api.g_false,
      p_commit           => Fnd_Api.g_false,
      p_validation_level => Fnd_Api.g_valid_level_full,
      p_module_type      => NULL,
      p_Visit_Task_Id    => l_origin_id,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data
      );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;

    Else
          Fnd_Message.SET_NAME('AHL','AHL_VWP_UNPLANNEDTASKMR');
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.G_EXC_ERROR;
          --Displays 'Unplanned Task association to Maintenance Requirement is missing.'
    End IF;

     END IF;

     /* Commented by mpothuku on 02/25/05 as this is moved to ahl_vwp_tasks_pvt.Delete_Summary_Task

     AHL_UMP_UNPLANNED_PVT.DELETE_UNIT_EFFECTIVITY(
      P_API_VERSION         => 1.0,
      X_RETURN_STATUS       => x_return_status,
      X_MSG_COUNT           => x_msg_count,
      X_MSG_DATA            => x_msg_data,
      P_UNIT_EFFECTIVITY_ID => c_task_rec.unit_effectivity_id
      );
  */

   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_ERROR;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', ' Error Before Commit---> After Delete Summary task call');
      END IF;

      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;


 ------------------------End of API Body------------------------------------
   IF Fnd_Api.to_boolean (p_commit) THEN
      COMMIT;
   END IF;

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||':*************************END*************************');
   END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Delete_Unplanned_Task;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Delete_Unplanned_Task;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Delete_Unplanned_Task;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
    THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Delete_Unplanned_Task;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Task_Items
--
-- PURPOSE
--
---------------------------------------------------------------------
PROCEDURE Check_Task_Items (
   p_task_rec        IN  AHL_VWP_RULES_PVT.Task_Rec_Type,
   p_validation_mode IN  VARCHAR2 := Jtf_Plsql_Api.g_create,

   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN
   --
   -- Validate required items.

   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_procedure,'ahl.plsql.'||G_PKG_NAME,'Check_Task_Items' || ':Before Check_Visit_Task_Req_Items');
END IF;
   Check_Visit_Task_Req_Items (
      p_task_rec        => p_task_rec,
      x_return_status   => x_return_status
   );
   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', 'Check_Task_Items' || ':After Check_Visit_Task_Req_Items');
   END IF;

   --
   -- Validate uniqueness.
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,'ahl.plsql.'||G_PKG_NAME, 'Check_Task_Items' ||':Before Check_Visit_Task_UK_Items');
   END IF;
   Check_Visit_Task_UK_Items (
      p_task_rec => p_task_rec,
      p_validation_mode    => p_validation_mode,
      x_return_status      => x_return_status
   );
   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_procedure,'ahl.plsql.'||G_PKG_NAME, 'Check_Task_Items' ||':Before Check_Visit_Task_UK_Items');
   END IF;
END Check_Task_Items;

---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Visit_Task_Rec
--
-- PURPOSE
--
---------------------------------------------------------------------
/* Commented
PROCEDURE Complete_Visit_Task_Rec (
   p_task_rec      IN  AHL_VWP_RULES_PVT.Task_Rec_Type,
   x_complete_rec  OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type
)
IS
   CURSOR c_Visit_Task IS
      SELECT   *
      FROM     Ahl_Visit_Tasks_vl
      WHERE    Visit_Task_ID = p_task_rec.Visit_Task_ID;
   --
   -- This is the only exception for using %ROWTYPE.
   -- We are selecting from the VL view, which may
   -- have some denormalized columns as compared to
   -- the base tables.
   l_task_rec    c_Visit_Task%ROWTYPE;
BEGIN
   x_complete_rec := p_task_rec;
   OPEN c_Visit_Task;
   FETCH c_Visit_Task INTO l_task_rec;
   IF c_Visit_Task%NOTFOUND THEN
      CLOSE c_Visit_Task;
         Fnd_Message.set_name('AHL', 'AHL_API_RECORD_NOT_FOUND');
         Fnd_Msg_Pub.ADD;
      RAISE Fnd_Api.g_exc_error;
   END IF;
   CLOSE c_Visit_Task;

END Complete_Visit_Task_Rec;
*/

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Visit_Task_Req_Items
--
-- PURPOSE
--
---------------------------------------------------------------------
PROCEDURE Check_Visit_Task_Req_Items (
   p_task_rec       IN    AHL_VWP_RULES_PVT.Task_Rec_Type,
   x_return_status  OUT   NOCOPY VARCHAR2
)
IS

BEGIN

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_procedure,'ahl.plsql.'||G_PKG_NAME,'Check_Visit_Task_Req_Items: = Start Check_Visit_Task_Req_Items ');
END IF;
   -- TASK NAME ==== NAME
   IF (p_task_rec.VISIT_TASK_NAME IS NULL OR p_Task_rec.VISIT_TASK_NAME = Fnd_Api.G_MISS_CHAR) THEN
         Fnd_Message.set_name ('AHL', 'AHL_VWP_NAME_MISSING');
         Fnd_Msg_Pub.ADD;
      x_return_status := Fnd_Api.g_ret_sts_error;
      RETURN;
   END IF;
IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,'ahl.plsql.'||G_PKG_NAME,'Check_Visit_Task_Req_Items:Inside Validation Start from Hour = ' || p_task_rec.START_FROM_HOUR);
END IF;
   IF (p_task_rec.START_FROM_HOUR IS NOT NULL and p_Task_rec.START_FROM_HOUR <> Fnd_Api.G_MISS_NUM) THEN
     IF p_task_rec.START_FROM_HOUR < 0 OR FLOOR(p_task_rec.START_FROM_HOUR) <> p_task_rec.START_FROM_HOUR THEN
             Fnd_Message.set_name ('AHL', 'AHL_VWP_ONLY_POSITIVE_VALUE');
             Fnd_Msg_Pub.ADD;
             x_return_status := Fnd_Api.g_ret_sts_error;
        RETURN;
     END IF;
   END IF;

END Check_Visit_Task_Req_Items;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Visit_Task_UK_Items
--
-- PURPOSE
--
---------------------------------------------------------------------
PROCEDURE Check_Visit_Task_UK_Items (
   p_task_rec        IN    AHL_VWP_RULES_PVT.Task_Rec_Type,
   p_validation_mode IN    VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status   OUT   NOCOPY VARCHAR2
)
IS
   l_valid_flag   VARCHAR2(1);

BEGIN
   x_return_status := Fnd_Api.g_ret_sts_success;
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_procedure,'ahl.plsql.'||G_PKG_NAME,'Check_Visit_Task_UK_Items: = Start Check_Visit_Task_UK_Items ');
   END IF;
   --
   -- For Task, when ID is passed in, we need to
   -- check if this ID is unique.
   IF p_validation_mode = Jtf_Plsql_Api.g_create AND p_task_rec.Visit_Task_ID IS NOT NULL THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,'ahl.plsql.'||G_PKG_NAME,'Check_Visit_Task_UK_Items : = Check_Visit_Task_UK_Items Uniqueness Of ID');
      END IF;
       -- FOR CREATION
      IF Ahl_Utility_Pvt.check_uniqueness(
          'Ahl_Visit_Tasks_vl',
          'Visit_Task_ID = ' || p_task_rec.Visit_Task_ID
      ) = Fnd_Api.g_false
      THEN
         Fnd_Message.set_name ('AHL', 'AHL_VWP_DUPLICATE_TASK_ID');
         Fnd_Msg_Pub.ADD;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END Check_Visit_Task_UK_Items;

END Ahl_Vwp_Unplan_Tasks_Pvt;

/
