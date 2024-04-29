--------------------------------------------------------
--  DDL for Package Body AHL_VWP_VISITS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_VISITS_PVT" AS
/* $Header: AHLVVSTB.pls 120.20.12010000.13 2010/04/05 06:41:37 tchimira ship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'AHL_VWP_VISITS_PVT';
G_DEBUG        VARCHAR2(1)  := AHL_DEBUG_PUB.is_log_enabled;

------------------------------------
-- Common constants and variables --
------------------------------------
l_log_current_level     NUMBER      := fnd_log.g_current_runtime_level;
l_log_statement         NUMBER      := fnd_log.level_statement;
l_log_procedure         NUMBER      := fnd_log.level_procedure;
l_log_error             NUMBER      := fnd_log.level_error;
l_log_unexpected        NUMBER      := fnd_log.level_unexpected;

-- Added by jaramana on 04-NOV-2009 for bug 9087120
-- Job Statuses
G_JOB_STATUS_UNRELEASED VARCHAR2(1) := '1'; --Unreleased

-- SKPATHAK :: Bug 9115894 :: 23-NOV-2009
G_VALIDATION_EXCEPTION EXCEPTION;
G_VALIDATION_ERROR_STATUS VARCHAR2(1) := 'V';
TYPE G_MESSAGE_STACK_TBL IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;


-----------------------------------------------------------------

---------------------------------------------------------------------
--   Define Record Types for record structures needed by the APIs  --
---------------------------------------------------------------------
-- NO RECORD TYPES *************

--------------------------------------------------------------------
-- Define Table Type for Records Structures                       --
--------------------------------------------------------------------
-- NO TABLE TYPES **************

--------------------------------------------------------------------
--  START: Defining local functions and procedures SIGNATURES     --
--------------------------------------------------------------------
--  To find out the Visit_Id for the AHL_Visits_B and TL tables
FUNCTION Get_Visit_Id
RETURN NUMBER;

--  To find out the Visit_Number for the AHL_Visits_B table
FUNCTION Get_Visit_Number
RETURN NUMBER;

--  To find out the Visit_Task_Number for the AHL_Visit_Tasks_B table
FUNCTION Get_Visit_Task_Number (p_visit_id IN NUMBER)
RETURN NUMBER;

--  To find out Due_by_Date for the visit update screen.
PROCEDURE Get_Due_by_Date(
   p_visit_id         IN    NUMBER,
   x_Due_by_Date      OUT   NOCOPY DATE
);

--  To assign Null to missing attributes of visit while creation/updation.
PROCEDURE Default_Missing_Attribs(
   p_x_visit_rec         IN OUT NOCOPY Visit_Rec_Type
);

--  To validate visit for creation/updation of visit
PROCEDURE Validate_Visit (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_Visit_rec         IN  visit_rec_type,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
);

--   To Check all Visit's Items
PROCEDURE Check_Visit_Items (
   p_Visit_rec       IN  visit_rec_type,
   p_validation_mode IN  VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);

--   To Check all Visit's Required Items
PROCEDURE Check_Visit_Req_Items (
   p_Visit_rec        IN    Visit_Rec_Type,
   x_return_status    OUT   NOCOPY VARCHAR2
);

--   To Check all Visit's Unique items
PROCEDURE Check_Visit_UK_Items (
   p_Visit_rec        IN    Visit_Rec_Type,
   p_validation_mode  IN    VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status    OUT   NOCOPY VARCHAR2
);

--  To Create a Maintenance Visit
PROCEDURE Create_Visit (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2  := 'JSP',
   p_x_visit_rec          IN OUT NOCOPY visit_rec_type,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
  );

--  To Update a Maintenance Visit
PROCEDURE Update_Visit (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2  := 'JSP',
   p_x_Visit_Rec          IN OUT NOCOPY visit_rec_type,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
   );

--  To Delete a Maintenance Visit
PROCEDURE Delete_Visit (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_visit_id             IN  NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
);


-- Transit Check Visit Change
-- yazhou start

PROCEDURE Synchronize_Visit (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2  := NULL,
   p_x_Visit_Rec          IN OUT NOCOPY visit_rec_type,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
   );

-- yazhou end

-- AnRaj added for ACL changes in VWP
-- Bug number 4297066
-------------------------------------------------------------------
--  Procedure name      : check_unit_quarantined
--  Type                : Private
--  Function            : To check whether the Unit is quarantined
--  Parameters          : p_visit_id
--  Parameters          : item_instance_id
----------------------------------------------------------------------
PROCEDURE check_unit_quarantined(
      p_visit_id           IN  NUMBER,
      item_instance_id     IN  NUMBER
  );

-- SKPATHAK :: Bug 9115894 :: 23-NOV-2009 :: START
-- Added this procedure to get the messages from message stack
PROCEDURE Get_Message_Stack (
    x_message_stack_tbl OUT NOCOPY G_MESSAGE_STACK_TBL
 );

-- To put the messages back to message stack
PROCEDURE Set_Message_Stack (
    p_message_stack_tbl IN G_MESSAGE_STACK_TBL
 );
-- SKPATHAK :: Bug 9115894 :: 23-NOV-2009 :: END


--------------------------------------------------------------------
--  END: Defining local functions and procedures SIGNATURES       --
--------------------------------------------------------------------

-- ****************************************************************

--------------------------------------------------------------------
-- START: Defining local functions and procedures BODY            --
--------------------------------------------------------------------

-------------------------------------------------------------------
-- PROCEDURE
--    Get_Due_by_Date
--
-- PURPOSE
--    To find out least due by date among all tasks of a visit
--------------------------------------------------------------------

PROCEDURE Get_Due_by_Date(
   p_visit_id         IN    NUMBER,
   x_due_by_date      OUT  NOCOPY  DATE)
IS
   -- Define local variables
   l_count1 NUMBER;
   l_count2 NUMBER;
   l_date  DATE;

   -- Define local Cursors
   -- To find whether a visit exists
   CURSOR c_visit (x_id IN NUMBER) IS
      SELECT COUNT(*)
      FROM Ahl_Visit_Tasks_B
      WHERE VISIT_ID = x_id
      AND NVL(STATUS_CODE,'X') <> 'DELETED';

   -- To find the total number of tasks for a visit
   CURSOR c_visit_task (x_id IN NUMBER) IS
      SELECT COUNT(*)
      FROM Ahl_Visit_Tasks_B
      WHERE VISIT_ID = x_id
      AND UNIT_EFFECTIVITY_ID IS NOT NULL
      AND NVL(STATUS_CODE,'X') <> 'DELETED';

  -- To find due date for a visit related with tasks
   CURSOR c_due_date (x_id IN NUMBER) IS
     SELECT MIN(T1.due_date)
     FROM ahl_unit_effectivities_vl T1, ahl_visit_tasks_b T2
     WHERE T1.unit_effectivity_id = T2.unit_effectivity_id
     AND T1.due_date IS NOT NULL AND T2.visit_id = x_id;

   L_API_NAME         CONSTANT VARCHAR2(30)  := 'Get_Due_by_Date';
   L_FULL_NAME        CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   L_DEBUG            CONSTANT VARCHAR2(90) := 'ahl.plsql.'||L_FULL_NAME;

BEGIN
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.begin','At the start of PLSQL procedure');
  END IF;

  OPEN c_visit(p_visit_id);
  FETCH c_visit INTO l_count1;
  IF c_visit%FOUND THEN         --Tasks found for visit
    CLOSE c_visit;
    OPEN c_visit_task(p_visit_id);
    FETCH c_visit_task INTO l_count2;
    IF c_visit_task%FOUND THEN  --Tasks found for visit checking for unit_effectivity_id
      CLOSE c_visit_task;
      OPEN c_due_date(p_visit_id);
      FETCH c_due_date INTO x_due_by_date;
      IF c_due_date%FOUND THEN     --Tasks found for visit
        CLOSE c_due_date;
      END IF;
    ELSE
      CLOSE c_visit_task;
    END IF;
  ELSE
    CLOSE c_visit;
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,L_DEBUG,'x_due_by_date - '||x_due_by_date);
    fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.end','At the end of PLSQL procedure');
  END IF;

  RETURN;
END Get_Due_by_Date;

--------------------------------------------------------------------
-- PROCEDURE
--    Default_Missing_Attribs
--
-- PURPOSE
--    For all optional fields check if its g_miss_num/g_miss_char/
--    g_miss_date then Null else the value

--------------------------------------------------------------------
PROCEDURE Default_Missing_Attribs
( p_x_visit_rec         IN OUT NOCOPY Visit_Rec_Type)
AS
BEGIN
  -- Post 11.5.10 Enhancements
  -- Removing defaulting of Visit Name since it is a mandatory field
  /*-- VISIT NAME
  IF  p_x_visit_rec.visit_name = Fnd_Api.G_MISS_char THEN
    p_x_visit_rec.visit_name := NULL;
  ELSE
    p_x_visit_rec.visit_name := p_x_visit_rec.visit_name;
  END IF;
  */

  -- ORGANIZATION ID
  IF  p_x_visit_rec.organization_id = Fnd_Api.G_MISS_NUM THEN
    p_x_visit_rec.organization_id := NULL;
  ELSE
    p_x_visit_rec.organization_id := p_x_visit_rec.organization_id;
  END IF;

  -- DEPARTMENT ID
  IF  p_x_visit_rec.department_id = Fnd_Api.G_MISS_NUM THEN
    p_x_visit_rec.department_id := NULL;
  ELSE
    p_x_visit_rec.department_id := p_x_visit_rec.department_id;
  END IF;

  -- START DATE
  IF  p_x_visit_rec.start_date = Fnd_Api.G_MISS_DATE THEN
    p_x_visit_rec.start_date := NULL;
  ELSE
    p_x_visit_rec.start_date := p_x_visit_rec.start_date;
  END IF;

  -- PLAN END DATE
  IF  p_x_visit_rec.plan_end_date = Fnd_Api.G_MISS_DATE THEN
    p_x_visit_rec.plan_end_date := NULL;
  ELSE
    p_x_visit_rec.plan_end_date := p_x_visit_rec.plan_end_date;
  END IF;

  -- SIMULATION_PLAN_ID
  IF  p_x_visit_rec.SIMULATION_PLAN_ID = Fnd_Api.G_MISS_NUM THEN
    p_x_visit_rec.SIMULATION_PLAN_ID := NULL;
  ELSE
    p_x_visit_rec.SIMULATION_PLAN_ID := p_x_visit_rec.SIMULATION_PLAN_ID;
  END IF;

  -- ITEM_INSTANCE_ID
  IF p_x_visit_rec.ITEM_INSTANCE_ID = Fnd_Api.G_MISS_NUM THEN
        p_x_visit_rec.ITEM_INSTANCE_ID := NULL;
  ELSE
        p_x_visit_rec.ITEM_INSTANCE_ID := p_x_visit_rec.ITEM_INSTANCE_ID;
  END IF;

  -- ASSO_PRIMARY_VISIT_ID
  IF  p_x_visit_rec.ASSO_PRIMARY_VISIT_ID = Fnd_Api.G_MISS_NUM THEN
    p_x_visit_rec.ASSO_PRIMARY_VISIT_ID := NULL;
  ELSE
    p_x_visit_rec.ASSO_PRIMARY_VISIT_ID := p_x_visit_rec.ASSO_PRIMARY_VISIT_ID;
  END IF;

  -- SIMULATION_DELETE_FLAG
  IF  p_x_visit_rec.SIMULATION_DELETE_FLAG  = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.SIMULATION_DELETE_FLAG  := NULL;
  ELSE
    p_x_visit_rec.SIMULATION_DELETE_FLAG  := p_x_visit_rec.SIMULATION_DELETE_FLAG;
  END IF;

  -- OUT_OF_SYNC_FLAG
  IF  p_x_visit_rec.OUT_OF_SYNC_FLAG  = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.OUT_OF_SYNC_FLAG  := NULL;
  ELSE
    p_x_visit_rec.OUT_OF_SYNC_FLAG  := p_x_visit_rec.OUT_OF_SYNC_FLAG;
  END IF;

  -- PROJECT_ID
  IF  p_x_visit_rec.PROJECT_ID = Fnd_Api.G_MISS_NUM THEN
    p_x_visit_rec.PROJECT_ID := NULL;
  ELSE
    p_x_visit_rec.PROJECT_ID := p_x_visit_rec.PROJECT_ID;
  END IF;

  -- space_category_code
  IF  p_x_visit_rec.space_category_code = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.space_category_code := NULL;
  ELSE
    p_x_visit_rec.space_category_code := p_x_visit_rec.space_category_code;
  END IF;

  -- description
  IF  p_x_visit_rec.description = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.description := NULL;
  ELSE
    p_x_visit_rec.description := p_x_visit_rec.description;
  END IF;

  -- Post 11.5.10 Enhancements
  -- Adding priority and project template
  IF  p_x_visit_rec.priority_code = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.priority_code := NULL;
  ELSE
    p_x_visit_rec.priority_code := p_x_visit_rec.priority_code;
  END IF;

  IF  p_x_visit_rec.proj_template_id = Fnd_Api.G_MISS_NUM THEN
    p_x_visit_rec.proj_template_id := NULL;
  ELSE
    p_x_visit_rec.proj_template_id := p_x_visit_rec.proj_template_id;
  END IF;

  -- Post 11.5.10 Enhancements
  -- Adding item id and visit type code.
  -- since these fields are not mandatory in Post 11.5.10
  -- serial number check already exists (item_instance_id)
  -- ITEM ID
  IF  p_x_visit_rec.inventory_item_id = Fnd_Api.G_MISS_NUM THEN
    p_x_visit_rec.inventory_item_id := NULL;
  ELSE
    p_x_visit_rec.inventory_item_id := p_x_visit_rec.inventory_item_id;
  END IF;

  -- VISIT TYPE CODE
  IF  p_x_visit_rec.visit_type_code = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.visit_type_code := NULL;
  ELSE
    p_x_visit_rec.visit_type_code := p_x_visit_rec.visit_type_code;
  END IF;

  IF  p_x_visit_rec.attribute_category = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.attribute_category := NULL;
  ELSE
    p_x_visit_rec.attribute_category := p_x_visit_rec.attribute_category;
  END IF;

  IF  p_x_visit_rec.attribute1 = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.attribute1 := NULL;
  ELSE
    p_x_visit_rec.attribute1 := p_x_visit_rec.attribute1;
  END IF;

  IF  p_x_visit_rec.attribute2 = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.attribute2 := NULL;
  ELSE
    p_x_visit_rec.attribute2 := p_x_visit_rec.attribute2;
  END IF;

  IF  p_x_visit_rec.attribute3 = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.attribute3 := NULL;
  ELSE
    p_x_visit_rec.attribute3 := p_x_visit_rec.attribute3;
  END IF;

  IF  p_x_visit_rec.attribute4 = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.attribute4 := NULL;
  ELSE
    p_x_visit_rec.attribute4 := p_x_visit_rec.attribute4;
  END IF;

  IF  p_x_visit_rec.attribute5 = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.attribute5 := NULL;
  ELSE
    p_x_visit_rec.attribute5 := p_x_visit_rec.attribute5;
  END IF;

  IF  p_x_visit_rec.attribute6 = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.attribute6 := NULL;
  ELSE
    p_x_visit_rec.attribute6 := p_x_visit_rec.attribute6;
  END IF;

  IF  p_x_visit_rec.attribute7 = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.attribute7 := NULL;
  ELSE
    p_x_visit_rec.attribute7 := p_x_visit_rec.attribute7;
  END IF;

  IF  p_x_visit_rec.attribute8 = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.attribute8 := NULL;
  ELSE
    p_x_visit_rec.attribute8 := p_x_visit_rec.attribute8;
  END IF;

  IF  p_x_visit_rec.attribute9 = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.attribute9 := NULL;
  ELSE
    p_x_visit_rec.attribute9 := p_x_visit_rec.attribute9;
  END IF;

  IF  p_x_visit_rec.attribute10 = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.attribute10 := NULL;
  ELSE
    p_x_visit_rec.attribute10 := p_x_visit_rec.attribute10;
  END IF;

  IF  p_x_visit_rec.attribute11 = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.attribute11 := NULL;
  ELSE
    p_x_visit_rec.attribute11 := p_x_visit_rec.attribute11;
  END IF;

  IF  p_x_visit_rec.attribute12 = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.attribute12 := NULL;
  ELSE
    p_x_visit_rec.attribute12 := p_x_visit_rec.attribute12;
  END IF;

  IF  p_x_visit_rec.attribute13 = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.attribute13 := NULL;
  ELSE
    p_x_visit_rec.attribute13 := p_x_visit_rec.attribute13;
  END IF;

  IF  p_x_visit_rec.attribute14 = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.attribute14 := NULL;
  ELSE
    p_x_visit_rec.attribute14 := p_x_visit_rec.attribute14;
  END IF;

  IF  p_x_visit_rec.attribute15 = Fnd_Api.G_MISS_CHAR THEN
    p_x_visit_rec.attribute15 := NULL;
  ELSE
    p_x_visit_rec.attribute15 := p_x_visit_rec.attribute15;
  END IF;

END Default_Missing_Attribs;

--------------------------------------------------------------------
-- FUNCTION
--     Get_Visit_Id
--
--------------------------------------------------------------------
FUNCTION  Get_Visit_Id RETURN NUMBER IS

 -- To find the next id value from visit sequence
 CURSOR c_seq IS
 SELECT Ahl_Visits_B_S.NEXTVAL
 FROM   dual;

 -- To find whether id already exists
 CURSOR c_id_exists (x_id IN NUMBER) IS
 SELECT 1 FROM   Ahl_Visits_VL
 WHERE  Visit_id = x_id;

 L_API_NAME         CONSTANT VARCHAR2(30)   := 'Get_Visit_Id';
 L_FULL_NAME        CONSTANT VARCHAR2(60)   := G_PKG_NAME || '.' || L_API_NAME;
 L_DEBUG            CONSTANT VARCHAR2(90)   := 'ahl.plsql.'||L_FULL_NAME;

 x_Visit_Id NUMBER;
 l_dummy NUMBER;
BEGIN
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.begin','At the start of function');
  END IF;

  LOOP
      -- If the ID is not passed into the API, then
      -- grab a value from the sequence.
      OPEN c_seq;
      FETCH c_seq INTO x_Visit_Id;
      CLOSE c_seq;
      -- Check to be sure that the sequence does not exist.
      OPEN c_id_exists (x_Visit_Id);
      FETCH c_id_exists INTO l_dummy;
      CLOSE c_id_exists;
      -- If the value for the ID already exists, then
      -- l_dummy would be populated with '1', otherwise, it receives NULL.
      EXIT WHEN l_dummy = null ;
  END LOOP;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,L_DEBUG,'New visit id : ' || x_Visit_Id);
    fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.end','At the end of function');
  END IF;

  RETURN x_Visit_Id;

END Get_Visit_Id;

--------------------------------------------------------------------
-- FUNCTION
--    Get_Visit_Number
--
--------------------------------------------------------------------
FUNCTION Get_Visit_Number RETURN NUMBER IS
  x_visit_number NUMBER;

  -- To find maximum visit number among all visits
  CURSOR c_visit_number IS
  SELECT MAX(visit_number)
  FROM Ahl_Visits_B;

  L_API_NAME         CONSTANT VARCHAR2(30)    := 'Get_Visit_Number';
  L_FULL_NAME        CONSTANT VARCHAR2(60)    := G_PKG_NAME || '.' || L_API_NAME;
  L_DEBUG            CONSTANT VARCHAR2(90)    := 'ahl.plsql.'||L_FULL_NAME;
BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.begin','At the start of function');
  END IF;

  -- Check for Visit Number
  OPEN c_visit_number;
  FETCH c_visit_number INTO x_visit_number;
  CLOSE c_visit_number;

  IF x_visit_number IS NOT NULL THEN
    x_visit_number := x_visit_number + 1;
  ELSE
    x_visit_number := 1;
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,L_DEBUG,'New visit number : ' || x_visit_number);
    fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.end','At the end of function');
  END IF;

  RETURN x_visit_number;

END Get_Visit_Number;
--------------------------------------------------------------------
-- FUNCTION
--    Get_Visit_Task_Number
--
--------------------------------------------------------------------
FUNCTION Get_Visit_Task_Number(p_visit_id IN NUMBER)
RETURN NUMBER IS
    x_Visit_Task_Number NUMBER ;

      -- To find maximum visit task nubmer among all tasks for a particular visit
    CURSOR c_task_number IS
      SELECT MAX(visit_task_number)
      FROM Ahl_Visit_Tasks_B
      WHERE Visit_Id = p_visit_id;

   L_API_NAME         CONSTANT VARCHAR2(30)   := 'Get_Visit_Task_Number';
   L_FULL_NAME        CONSTANT VARCHAR2(60)   := G_PKG_NAME || '.' || L_API_NAME;
   L_DEBUG            CONSTANT VARCHAR2(90)   := 'ahl.plsql.'||L_FULL_NAME;

BEGIN
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.begin','At the start of function');
  END IF;

  -- Check for Visit Number
  OPEN c_Task_Number;
  FETCH c_Task_Number INTO x_Visit_Task_Number;
  CLOSE c_Task_Number;

  IF x_Visit_Task_Number IS NOT NULL THEN
    x_Visit_Task_Number := x_Visit_Task_Number + 1;
  ELSE
    x_Visit_Task_Number := 1;
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,L_DEBUG,'Visit Task Number - ' || x_Visit_Task_Number);
    fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.end','At the end of function');
  END IF;

  RETURN x_Visit_Task_Number;
END Get_Visit_Task_Number;
--------------------------------------------------------------------
-- END: Defining local functions and procedures BODY              --
--------------------------------------------------------------------

----------------------------------------------------------------------
-- START: Defining procedures BODY, which are called from UI screen --
----------------------------------------------------------------------

--------------------------------------------------------------------
-- PROCEDURE
--    Process_Visit
--
-- PURPOSE
--    Process Visit Records from front end screen intermediate step
--    between API's and frontend.
--------------------------------------------------------------------
PROCEDURE Process_Visit (
   p_api_version            IN      NUMBER,
   p_init_msg_list          IN      VARCHAR2  := FND_API.g_false,
   p_commit                 IN      VARCHAR2  := FND_API.g_false,
   p_validation_level       IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type            IN      VARCHAR2  := 'JSP',
   p_x_Visit_tbl            IN OUT  NOCOPY Visit_Tbl_Type,
   x_return_status          OUT     NOCOPY VARCHAR2,
   x_msg_count              OUT     NOCOPY NUMBER,
   x_msg_data               OUT     NOCOPY VARCHAR2
)
IS
 -- Define local variables
 l_api_name         CONSTANT VARCHAR2(30) := 'Process_Visit';
 l_api_version      CONSTANT NUMBER       := 1.0;
 L_FULL_NAME        CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
 L_DEBUG            CONSTANT VARCHAR2(90) := 'ahl.plsql.'||L_FULL_NAME;

 l_msg_count                NUMBER;
 l_visit_id                 NUMBER;
 p_visit_id                 NUMBER;

 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 -- Transit Visit Change
 -- yazhou start
 -- SKPATHAK :: Bug 9115894 :: 23-NOV-2009
 l_status_flag   VARCHAR2(1)  := 'S';
 l_init_msg_list VARCHAR2(1)  := FND_API.g_false;
 l_message_stack_tbl G_MESSAGE_STACK_TBL;

 l_visit_status             VARCHAR2(30);

 -- To find out visit status
 CURSOR c_visit_status (x_visit_id IN NUMBER) IS
 SELECT STATUS_CODE FROM AHL_VISITS_B
 WHERE VISIT_ID = x_visit_id;

 -- yazhou end
 --
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT Process_Visit;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.begin','At the start of PLSQL procedure');
  END IF;

  --  Initialize API return status to success
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --------------------Start of API Body-----------------------------------
  IF p_x_Visit_tbl.COUNT > 0 THEN
   FOR i IN p_x_Visit_tbl.first..p_x_Visit_tbl.LAST
   LOOP
    -- For Create
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'p_x_Visit_tbl(i).operation_flag : '||p_x_Visit_tbl(i).operation_flag);
    END IF;

    IF p_x_Visit_tbl(i).operation_flag = 'I' or p_x_Visit_tbl(i).operation_flag = 'i' THEN

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling Create_Visit');
      END IF;

      Create_Visit
           (
            p_api_version             => l_api_version,
            -- Changed by jaramana on 18-NOV-2009 for bug 9115894
            p_init_msg_list           => FND_API.g_false,
            p_commit                  => Fnd_Api.g_false,
            p_validation_level        => p_validation_level,
            p_module_type             => p_module_type,
            p_x_visit_rec             => p_x_Visit_tbl(i),
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data
            );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling Create_Visit - l_return_status : '||l_return_status);
      END IF;

   --For Update
   ELSIF p_x_Visit_tbl(i).operation_flag = 'U' or p_x_Visit_tbl(i).operation_flag = 'u' THEN

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling Update_Visit');
      END IF;

      Update_Visit
           (
            p_api_version             => l_api_version,
            -- Changed by jaramana on 18-NOV-2009 for bug 9115894
            p_init_msg_list           => FND_API.g_false,
            p_commit                  => Fnd_Api.g_false,
            p_validation_level        => p_validation_level,
            p_module_type             => p_module_type,
            p_x_Visit_rec             => p_x_Visit_tbl(i),
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data
          );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling Update_Visit - l_return_status : '||l_return_status);
      END IF;

    --For Delete
   ELSIF p_x_Visit_tbl(i).operation_flag = 'D' or p_x_Visit_tbl(i).operation_flag = 'd' THEN

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling Delete_Visit');
      END IF;

      Delete_Visit
           (
            p_api_version             => l_api_version,
            -- Changed by jaramana on 18-NOV-2009 for bug 9115894
            p_init_msg_list           => FND_API.g_false,
            p_commit                  => Fnd_Api.g_false,
            p_validation_level        => p_validation_level,
            p_Visit_id                => p_x_visit_tbl(i).visit_id,
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data
          );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling Delete_Visit - l_return_status : '||l_return_status);
      END IF;

   -- Transit Visit Change
   -- yazhou start
   -- Will be called from UA
   -- To Synchronize visit with flight schedule change
   ELSIF p_x_Visit_tbl(i).operation_flag = 'S' or p_x_Visit_tbl(i).operation_flag = 's' THEN

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling Synchronize_Visit');
      END IF;

      Synchronize_Visit
           (
            p_api_version             => l_api_version,
            -- Changed by jaramana on 18-NOV-2009 for bug 9115894
            p_init_msg_list           => FND_API.g_false,
            p_commit                  => Fnd_Api.g_false,
            p_validation_level        => p_validation_level,
            p_x_Visit_rec             => p_x_visit_tbl(i),
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data
          );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling Synchronize_Visit - l_return_status : '||l_return_status);
      END IF;

   -- Will be called from UA
   -- Delete the visit if visit is in Planning status
   -- Cancel the visit if visit is in Released or Partially Released status
   ELSIF p_x_Visit_tbl(i).operation_flag = 'X' or p_x_Visit_tbl(i).operation_flag = 'x' THEN

       OPEN c_visit_status(p_x_Visit_tbl(i).visit_id);
       FETCH c_visit_status INTO l_visit_status;
       IF c_visit_status%NOTFOUND THEN
        CLOSE c_visit_status;
        IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
            Fnd_Message.set_name('AHL', 'AHL_API_RECORD_NOT_FOUND');
            Fnd_Msg_Pub.ADD;
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(fnd_log.level_statement,L_DEBUG,'Visit status not found for visit : ' ||p_x_Visit_tbl(i).visit_id );
            END IF;
         END IF;
         RAISE Fnd_Api.g_exc_error;
       ELSE
        CLOSE c_visit_status;
       END IF;

       -- SKPATHAK :: Bug 9115894 :: 23-NOV-2009
       -- If status flag is V, then initialize the message list
       -- and store all the message in the message stack in l_message_stack_tbl
       IF l_status_flag = 'V' THEN
          Get_Message_Stack (x_message_stack_tbl => l_message_stack_tbl);
	  l_init_msg_list := FND_API.g_true;
       ELSE
          l_init_msg_list := FND_API.g_false;
       END IF;

       IF l_visit_status = 'PLANNING' THEN
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG,'l_visit_status : '||l_visit_status);
            fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling Delete_Visit');
          END IF;

          Delete_Visit
           (
            p_api_version             => l_api_version,
            -- Changed by jaramana on 18-NOV-2009 for bug 9115894
            p_init_msg_list           => l_init_msg_list,
            p_commit                  => Fnd_Api.g_false,
            p_validation_level        => p_validation_level,
            p_Visit_id                => p_x_visit_tbl(i).visit_id,
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data
          );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling Delete_Visit - l_return_status : '|| l_return_status);
          END IF;
       ELSIF l_visit_status = 'RELEASED' OR l_visit_status = 'PARTIALLY RELEASED' THEN
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG,'l_visit_status : '||l_visit_status);
            fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling Cancel_Visit');
          END IF;

          Cancel_Visit (
            p_api_version             => l_api_version,
            -- Changed by jaramana on 18-NOV-2009 for bug 9115894
            p_init_msg_list           => l_init_msg_list,
            p_commit                  => Fnd_Api.g_false,
            p_validation_level        => p_validation_level,
            p_module_type             => p_module_type,
            p_visit_id                => p_x_visit_tbl(i).visit_id,
            p_obj_ver_num             => p_x_visit_tbl(i).object_version_number,
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data    );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling Cancel_Visit - l_return_status : '|| l_return_status);
          END IF;
       END IF;
    -- yazhou end
       -- SKPATHAK :: Bug 9115894 :: 23-NOV-2009
       -- If status flag is V, put the stored messages back to the message stack
       IF l_status_flag = 'V' THEN
          Set_Message_Stack (p_message_stack_tbl => l_message_stack_tbl);
       END IF;
    END IF;

    -- SKPATHAK :: Bug 9115894 :: 19-NOV-2009
    -- Populate the return status in l_status_flag. Make sure that the status
    -- priority remains U, then E, then V and then S (which is default)
    -- That is, U should not get overwritten by E or V, and E should not get overwritten by V
    IF l_return_status = 'U' OR l_status_flag = 'U' THEN
       l_status_flag  := 'U';
    ELSIF l_return_status = 'E' OR l_status_flag = 'E' THEN
       l_status_flag  := 'E';
    ELSIF l_return_status = 'V' THEN
       l_status_flag  := 'V';
    END IF;

  END LOOP;
 END IF;

 -- SKPATHAK :: Bug 9115894 :: 19-NOV-2009
 IF (l_status_flag = 'E') THEN
   RAISE Fnd_Api.G_EXC_ERROR;
 ELSIF (l_status_flag = 'U') THEN
   RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
 END IF;


 ------------------------End of API Body---------------------------------------
 --Standard check to count messages
 l_msg_count := Fnd_Msg_Pub.count_msg;

 IF l_msg_count > 0 THEN
   x_msg_count := l_msg_count;
   IF l_status_flag <> 'V' THEN
      -- Unknown messages
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
 END IF;

 -- Proceed to commit if status is 'S' or if there were only validation errors
 --Standard check for commit
 IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
  COMMIT;
 END IF;

 -- Added by jaramana on 18-NOV-2009 for bug 9115894
 -- If validation had failed for any of the visits, return 'V' to the caller
 -- Otherwise X_return_status will already be 'S'
 IF l_status_flag = 'V' THEN
   X_return_status := G_VALIDATION_ERROR_STATUS;
   FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);
 END IF;

 IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure, L_DEBUG||'.end', 'At the end of PLSQL procedure. x_return_status = ' || x_return_status);
 END IF;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Process_Visit;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Process_Visit;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

WHEN OTHERS THEN
    ROLLBACK TO Process_Visit;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_VWP_VISITS_PVT',
                            p_procedure_name  =>  'Process_Visit',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
END Process_Visit;

--------------------------------------------------------------------
-- PROCEDURE
--    Get_Visit_Details
--
-- PURPOSE
--    Get a particular Visit Records with all details
--------------------------------------------------------------------
PROCEDURE Get_Visit_Details (
   p_api_version             IN   NUMBER,
   p_init_msg_list           IN   VARCHAR2  := Fnd_Api.g_false,
   p_commit                  IN   VARCHAR2  := Fnd_Api.g_false,
   p_validation_level        IN   NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type             IN   VARCHAR2  := 'JSP',
   p_visit_id                IN   NUMBER,
   x_Visit_rec               OUT  NOCOPY Visit_Rec_Type,
   x_return_status           OUT  NOCOPY VARCHAR2,
   x_msg_count               OUT  NOCOPY NUMBER,
   x_msg_data                OUT  NOCOPY VARCHAR2
   )
IS
  -- Define local Variables
   L_API_VERSION          CONSTANT NUMBER := 1.0;
   L_API_NAME             CONSTANT VARCHAR2(30) := 'Get_Visit_Details';
   L_FULL_NAME            CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   L_DEBUG                CONSTANT VARCHAR2(90) := G_PKG_NAME || '.' || L_API_NAME;

   l_msg_data             VARCHAR2(2000);
   l_project_flag         VARCHAR2(80);
   l_simulation_plan_name VARCHAR2(80);
   l_unit_name            VARCHAR2(80);
   l_unit_header_id       NUMBER;
   l_hour                 VARCHAR2(30);
   l_hour_close           VARCHAR2(30);
   l_default              VARCHAR2(30);
   l_proj_temp_name       VARCHAR2(30);
   l_return_status        VARCHAR2(1);
   l_valid_flag           VARCHAR2(1);

   l_visit_id             NUMBER:= p_visit_id;
   l_count                NUMBER;
   l_duration             NUMBER;
   l_visit_end_hour       NUMBER;
   l_proj_temp_id         NUMBER;
   l_workorder_id         NUMBER;
   i                      NUMBER;
   x                      NUMBER;

   l_due_date             DATE;
   x_due_by_date          DATE;
   l_visit_end_date       DATE;
   l_minute  NUMBER(2);
   l_minute_close  NUMBER(2);

   l_workorder_name       VARCHAR2(80); -- Added in 11.5.10

   ---Arvind changes for FlightNumber
   l_flight_number        VARCHAR2(30);
   ---End

   -- Define local record datatypes
   l_visit_rec          Visit_Rec_Type;

   -- Define local cursors
   --Arvind changes for FlightNumber
   -- To retreive FlightNumber based on UnitScheduleID
   CURSOR c_flight_number (x_id IN NUMBER) IS
   select flight_number
   from ahl_unit_schedules
   where unit_schedule_id=x_id;
   --end

   -- To find out required search visit details
   -- Fix for ADS bug# 4357001.
   -- Modified query so that Visits retrieved are not OU stripped.
   -- 'View Visit' should show visit details accross OU.
   -- Following query is copied from ahl_search_visits_v without the CLIENT_INFO.
   CURSOR c_visit (x_id IN NUMBER) IS
   --SELECT * FROM AHL_SEARCH_VISITS_V
   --WHERE VISIT_ID = x_id;
   --AnRaj:Changed query, Perf Bug:4919502
/* SELECT AVTS.VISIT_ID , AVTS.VISIT_NUMBER, AVTS.VISIT_NAME,
   AVTS.ORGANIZATION_ID , HROU.NAME ORGANIZATION_NAME, AVTS.DEPARTMENT_ID ,
   BDPT.DESCRIPTION DEPARTMENT_NAME , AVTS.OBJECT_VERSION_NUMBER,
   AVTS.START_DATE_TIME,
   AVTS.STATUS_CODE, FLVT1.MEANING STATUS_MEAN, AVTS.TEMPLATE_FLAG,
   AVTS.ITEM_INSTANCE_ID , CSIS.SERIAL_NUMBER , AVTS.INVENTORY_ITEM_ID ,
   AVTS.ITEM_ORGANIZATION_ID , MTSB.CONCATENATED_SEGMENTS ITEM_DESCRIPTION,
   AVTS.VISIT_TYPE_CODE , FLVT.MEANING VISIT_TYPE_MEAN, AVTS.SIMULATION_PLAN_ID,
   ASPV.SIMULATION_PLAN_NAME, NVL(ASPV.PRIMARY_PLAN_FLAG,'Y') ,
   AVTS.SPACE_CATEGORY_CODE, FLVT2.MEANING SPACE_CATEGORY_MEAN,
   AVTS.SERVICE_REQUEST_ID,
   AVTS.CLOSE_DATE_TIME, CSAB.INCIDENT_NUMBER, UC.NAME UNIT_NAME,
   AVTS.PRIORITY_CODE,
   FLVT3.MEANING PRIORITY_MEAN, AVTS.PROJECT_TEMPLATE_ID,
   PA.NAME PROJECT_TEMPLATE_NAME ,
   AVTS.UNIT_SCHEDULE_ID, AVTS.ASSO_PRIMARY_VISIT_ID
   FROM AHL_VISITS_VL AVTS, AHL_SIMULATION_PLANS_VL ASPV,
   CSI_ITEM_INSTANCES CSIS, HR_ALL_ORGANIZATION_UNITS HROU,
   BOM_DEPARTMENTS BDPT, MTL_SYSTEM_ITEMS_B_KFV MTSB,
   FND_LOOKUP_VALUES_VL FLVT, FND_LOOKUP_VALUES_VL FLVT1,
   FND_LOOKUP_VALUES_VL FLVT2, FND_LOOKUP_VALUES_VL FLVT3,
   PA_PROJECTS_ALL PA, AHL_UNIT_CONFIG_HEADERS UC, CS_INCIDENTS_ALL_B CSAB
   WHERE AVTS.ITEM_INSTANCE_ID = UC.CSI_ITEM_INSTANCE_ID(+)
   AND AVTS.ITEM_INSTANCE_ID = CSIS.INSTANCE_ID(+)
   AND AVTS.ORGANIZATION_ID = HROU.ORGANIZATION_ID(+)
   AND AVTS.DEPARTMENT_ID = BDPT.DEPARTMENT_ID(+)
   AND AVTS.SIMULATION_PLAN_ID = ASPV.SIMULATION_PLAN_ID(+)
   AND AVTS. INVENTORY_ITEM_ID = MTSB.INVENTORY_ITEM_ID(+)
   AND AVTS. ITEM_ORGANIZATION_ID = MTSB.ORGANIZATION_ID(+)
   AND FLVT.LOOKUP_TYPE(+) ='AHL_PLANNING_VISIT_TYPE'
   AND FLVT.LOOKUP_CODE(+) = AVTS.VISIT_TYPE_CODE
   AND FLVT1.LOOKUP_TYPE(+) = 'AHL_VWP_VISIT_STATUS'
   AND FLVT1.LOOKUP_CODE(+) = AVTS.STATUS_CODE
   AND FLVT2.LOOKUP_TYPE(+) = 'AHL_LTP_SPACE_CATEGORY'
   AND FLVT2.LOOKUP_CODE(+) = AVTS.SPACE_CATEGORY_CODE
   AND FLVT3.LOOKUP_TYPE(+) = 'AHL_VWP_VISIT_PRIORITY'
   AND FLVT3.LOOKUP_CODE(+) = AVTS.PRIORITY_CODE
   AND PA.PROJECT_ID(+) = AVTS.PROJECT_TEMPLATE_ID
   AND AVTS.SERVICE_REQUEST_ID = CSAB.INCIDENT_ID(+)
   AND AVTS.TEMPLATE_FLAG = 'N' AND AVTS.STATUS_CODE <> 'DELETED'
   AND UC.active_end_date is null
   AND VISIT_ID = x_id;*/
   -- AnRaj: Replaced HR_ALL_ORGANIZATION_UNITS with HR_ALL_ORGANIZATION_UNITS_TL, Fix for Bug# 5367598
   SELECT  AVTS.VISIT_ID , AVTS.VISIT_NUMBER,
        AVTSTL.VISIT_NAME,AVTS.ORGANIZATION_ID ,
        AVTS.START_DATE_TIME, AVTS.CLOSE_DATE_TIME,AVTS.VISIT_TYPE_CODE ,
        AVTS.DEPARTMENT_ID ,AVTS.STATUS_CODE,AVTS.OBJECT_VERSION_NUMBER,
        HROU.NAME ORGANIZATION_NAME,
        BDPT.DESCRIPTION DEPARTMENT_NAME ,
        FLVT1.MEANING STATUS_MEAN,
        AVTS.TEMPLATE_FLAG,AVTS.ITEM_INSTANCE_ID ,
        AVTS.INVENTORY_ITEM_ID,AVTS.ITEM_ORGANIZATION_ID,
        AVTS.SIMULATION_PLAN_ID,AVTS.SERVICE_REQUEST_ID,
        AVTS.PRIORITY_CODE,AVTS.SPACE_CATEGORY_CODE,
        AVTS.PROJECT_TEMPLATE_ID,AVTS.UNIT_SCHEDULE_ID,AVTS.ASSO_PRIMARY_VISIT_ID,
        CSIS.SERIAL_NUMBER ,
        MTSB.CONCATENATED_SEGMENTS ITEM_DESCRIPTION,
        FLVT.MEANING VISIT_TYPE_MEAN,FLVT3.MEANING
        PRIORITY_MEAN,FLVT2.MEANING SPACE_CATEGORY_MEAN,
        ASPVTL.SIMULATION_PLAN_NAME, NVL(ASPV.PRIMARY_PLAN_FLAG,'Y') ,
        CSAB.INCIDENT_NUMBER, UC.NAME UNIT_NAME,
	-- SKPATHAK :: Bug #8983097 :: 20-OCT-2009
	-- Removed project template from the SELECT, FROM, and WHERE clauses of this cursor
	--PA.NAME PROJECT_TEMPLATE_NAME,
       AVTS.INV_LOCATOR_ID -- Added by sowsubra
  FROM    AHL_VISITS_B AVTS,AHL_VISITS_TL AVTSTL,
        AHL_SIMULATION_PLANS_B ASPV,AHL_SIMULATION_PLANS_TL ASPVTL,
        CSI_ITEM_INSTANCES CSIS, HR_ALL_ORGANIZATION_UNITS_TL HROU,
        BOM_DEPARTMENTS BDPT, MTL_SYSTEM_ITEMS_B_KFV MTSB,
        FND_LOOKUP_VALUES FLVT, FND_LOOKUP_VALUES FLVT1,
        FND_LOOKUP_VALUES FLVT2, FND_LOOKUP_VALUES FLVT3,
	-- SKPATHAK :: Bug #8983097 :: 20-OCT-2009
        --PA_PROJECTS_ALL PA,
        AHL_UNIT_CONFIG_HEADERS UC, CS_INCIDENTS_ALL_B CSAB
  WHERE   AVTS.VISIT_ID = AVTSTL.VISIT_ID
  AND     AVTSTL.LANGUAGE = USERENV('LANG')
  AND     ASPV.SIMULATION_PLAN_ID = ASPVTL.SIMULATION_PLAN_ID(+)
  AND     ASPVTL.LANGUAGE(+) = USERENV('LANG')
  AND     AVTS.ITEM_INSTANCE_ID = UC.CSI_ITEM_INSTANCE_ID(+)
  AND     AVTS.ITEM_INSTANCE_ID = CSIS.INSTANCE_ID(+)
  AND     AVTS.ORGANIZATION_ID = HROU.ORGANIZATION_ID(+)
  AND     HROU.LANGUAGE(+) = USERENV('LANG')
  AND     AVTS.DEPARTMENT_ID = BDPT.DEPARTMENT_ID(+)
  AND     AVTS.SIMULATION_PLAN_ID = ASPV.SIMULATION_PLAN_ID(+)
  AND     AVTS. INVENTORY_ITEM_ID = MTSB.INVENTORY_ITEM_ID(+)
  AND     AVTS. ITEM_ORGANIZATION_ID = MTSB.ORGANIZATION_ID(+)
  AND     FLVT.LOOKUP_TYPE(+) ='AHL_PLANNING_VISIT_TYPE'
  AND     FLVT.LOOKUP_CODE(+) = AVTS.VISIT_TYPE_CODE
  AND     FLVT.LANGUAGE(+) = userenv('LANG')
  AND     FLVT1.LOOKUP_TYPE(+) = 'AHL_VWP_VISIT_STATUS'
  AND     FLVT1.LOOKUP_CODE(+) = AVTS.STATUS_CODE
  AND     FLVT1.LANGUAGE(+) = userenv('LANG')
  AND     FLVT2.LOOKUP_TYPE(+) = 'AHL_LTP_SPACE_CATEGORY'
  AND     FLVT2.LOOKUP_CODE(+) = AVTS.SPACE_CATEGORY_CODE
  AND     FLVT2.LANGUAGE(+) = userenv('LANG')
  AND     FLVT3.LOOKUP_TYPE(+) = 'AHL_VWP_VISIT_PRIORITY'
  AND     FLVT3.LOOKUP_CODE(+) = AVTS.PRIORITY_CODE
  AND     FLVT3.LANGUAGE(+) = userenv('LANG')
  -- SKPATHAK :: Bug #8983097 :: 20-OCT-2009
  --AND     PA.PROJECT_ID = AVTS.PROJECT_TEMPLATE_ID
  AND     AVTS.SERVICE_REQUEST_ID = CSAB.INCIDENT_ID(+)
  AND     AVTS.TEMPLATE_FLAG = 'N'
  AND     AVTS.STATUS_CODE <> 'DELETED'
  AND     UC.active_end_date is null
  AND     AVTS.VISIT_ID = x_id;

  c_visit_rec c_visit%ROWTYPE;

  -- To find out all visit/template details
  CURSOR c_visit_details (x_id IN NUMBER) IS
  SELECT * FROM AHL_VISITS_VL
  WHERE VISIT_ID = x_id;

  visit_rec  c_visit_details%ROWTYPE;

  --TCHIMIRA::P2P CP ER 9151144::02-DEC-2009
  --Cursor to fetch CP related details
  CURSOR c_conc_req_details(x_cp_req_id IN NUMBER) IS
  SELECT FLS.MEANING CP_STATUS_CODE, FLP.MEANING CP_PHASE_CODE, FCR.REQUEST_DATE CP_REQUEST_DATE
  FROM FND_CONCURRENT_REQUESTS FCR, FND_LOOKUPS FLS, FND_LOOKUPS FLP
  WHERE FCR.REQUEST_ID = x_cp_req_id
  AND ((FCR.STATUS_CODE = FLS.LOOKUP_CODE
  AND FLS.LOOKUP_TYPE = 'CP_STATUS_CODE')
  AND  (FCR.PHASE_CODE = FLP.LOOKUP_CODE
  AND  FLP.LOOKUP_TYPE = 'CP_PHASE_CODE'))  ;

  conc_req_rec c_conc_req_details%ROWTYPE;

  -- Cursor to find master workorder name for the given visit
  CURSOR c_workorder_csr (x_id IN NUMBER) IS
  SELECT WORKORDER_NAME, WORKORDER_ID FROM AHL_WORKORDERS
  WHERE MASTER_WORKORDER_FLAG = 'Y' AND VISIT_ID = x_id
  /*B6512777 - sowsubra - there is no task associated with visit master wo, hence included the check below to get the visit master wo name*/
   AND VISIT_TASK_ID IS NULL;

  -- CURSOR added to get the Project Template Name
  -- Post 11.5.10
  -- Fix for ADS bug# 4357001. Changed to use PA_PROJECTS_ALL table.
  CURSOR c_proj_template(p_proj_temp_id IN NUMBER) IS
  SELECT name FROM PA_PROJECTS_ALL
  WHERE project_id = p_proj_temp_id;

  CURSOR c_uc_header(x_instance_id IN NUMBER) IS
  SELECT name, UNIT_CONFIG_HEADER_ID FROM ahl_unit_config_headers
  WHERE CSI_ITEM_INSTANCE_ID = x_instance_id
  AND active_end_date is null;

  /*Added by sowsubra*/
  CURSOR c_get_subinv_loc_dtls(p_inv_locator_id IN NUMBER, p_org_id IN NUMBER) IS
    SELECT SUBINVENTORY_CODE, CONCATENATED_SEGMENTS
    FROM mtl_item_locations_kfv
    WHERE inventory_location_id = p_inv_locator_id;

  l_sub_code         VARCHAR2(10) := NULL;
  l_locator_code     VARCHAR2(240) := NULL;

 BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Get_Visit_Details;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.begin','At the start of PLSQL procedure, p_visit_id -  '||p_visit_id);
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF Fnd_Api.to_boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  -- Standard call to check for call compatibility.
  IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME) THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
  ------------------------------Start of API Body------------------------------------

  ----------------------------------------- Cursor ----------------------------------
  OPEN c_visit_details(p_visit_id);
  FETCH c_visit_details INTO visit_rec;
  CLOSE c_visit_details;

  OPEN c_Visit(p_visit_id);
  FETCH c_visit INTO c_visit_rec;
  CLOSE c_Visit;

  --TCHIMIRA::P2P CP ER 9151144::02-DEC-2009
  OPEN c_conc_req_details(visit_rec.request_id);
  FETCH c_conc_req_details INTO conc_req_rec;
  CLOSE c_conc_req_details;
  ------------------------------------------ Start -----------------------------------
  -- get workorder name and Id added in 11.5.10
  OPEN c_workorder_csr(p_visit_id);
  FETCH c_workorder_csr INTO l_workorder_name, l_workorder_id;
  IF c_workorder_csr%FOUND THEN
    l_visit_rec.job_number := l_workorder_name;
    --l_visit_rec.workorder_id := l_workorder_id;
  END IF;
  CLOSE c_workorder_csr;

  -- To find meaning for fnd_lookups code
  IF (visit_rec.project_flag IS NOT NULL) THEN
      SELECT MEANING INTO l_project_flag
      FROM FND_LOOKUP_VALUES_VL
      WHERE LOOKUP_CODE = visit_rec.project_flag
      AND LOOKUP_TYPE = 'AHL_YES_NO_TYPE';
  END IF;
  ----------------------------------- FOR VISITS --------------------------------------
  IF UPPER(c_visit_rec.template_flag) = 'N' THEN
    -- To find Unit Name on basis of Instance Id
    IF visit_rec.item_instance_id IS NOT NULL THEN
      OPEN c_uc_header(visit_rec.item_instance_id);
      FETCH c_uc_header INTO l_unit_name, l_unit_header_id;
      CLOSE c_uc_header;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'item instance : '|| visit_rec.item_instance_id);
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'l_unit_name : '|| l_unit_name);
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'l_unit_header_id : '|| l_unit_header_id);
      END IF;
    END IF;

    -- To find simulation plan name for the simulation id from LTP view
    IF (visit_rec.simulation_plan_id IS NOT NULL) THEN
      SELECT SIMULATION_PLAN_NAME INTO l_simulation_plan_name
      FROM AHL_SIMULATION_PLANS_VL
      WHERE SIMULATION_PLAN_ID = visit_rec.simulation_plan_id;
    ELSE
      l_simulation_plan_name := NULL;
    END IF;

    -- Post 11.5.10
    -- Reema Start
    -- To check if visit starttime is not null then store time in HH4 format
    IF (c_visit_rec.START_DATE_TIME IS NOT NULL AND c_visit_rec.START_DATE_TIME <> Fnd_Api.G_MISS_DATE) THEN
      l_hour := TO_NUMBER(TO_CHAR(c_visit_rec.START_DATE_TIME , 'HH24'));
      l_minute := TO_NUMBER(TO_CHAR(c_visit_rec.START_DATE_TIME , 'MI'));
    ELSE
      l_hour := NULL;
      c_visit_rec.START_DATE_TIME := NULL;
    END IF;

    -- To check if visit closetime is not null then store time in HH4 format
    IF (visit_rec.CLOSE_DATE_TIME IS NOT NULL AND visit_rec.CLOSE_DATE_TIME <> Fnd_Api.G_MISS_DATE) THEN
      l_hour_close := TO_NUMBER(TO_CHAR(visit_rec.CLOSE_DATE_TIME , 'HH24'));
      l_minute_close := TO_NUMBER(TO_CHAR(c_visit_rec.CLOSE_DATE_TIME , 'MI'));
    ELSE
      l_hour_close := NULL;
      visit_rec.CLOSE_DATE_TIME := Null;
    END IF;

    -- Call local procedure to retrieve Due by Date of the visit
    Get_Due_by_Date(p_visit_id => l_visit_id, x_due_by_date  => l_due_date);

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Due by date : '|| l_due_date);
    END IF;

    -- Derive the visit end date
    IF (c_visit_rec.START_DATE_TIME IS NOT NULL
      AND c_visit_rec.START_DATE_TIME <> Fnd_Api.G_MISS_DATE
      AND c_visit_rec.DEPARTMENT_ID IS NOT NULL
      AND c_visit_rec.DEPARTMENT_ID <> FND_API.G_MISS_NUM) THEN
        l_visit_end_date:= AHL_VWP_TIMES_PVT.get_visit_end_time(p_visit_id);
    END IF;

    -- Post 11.5.10
    -- get the project template name from cursor
    IF visit_rec.project_template_id IS NOT NULL THEN
      OPEN c_proj_template(visit_rec.project_template_id);
      FETCH c_proj_template INTO l_visit_rec.proj_template_name;
      IF c_proj_template%NOTFOUND THEN
        IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
          Fnd_Message.SET_NAME('AHL','AHL_VWP_INVALID_PROTEM');
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.G_EXC_ERROR;
        END IF;
      END IF;
      CLOSE c_proj_template;
    END IF;

    /*Added by sowsubra*/
    IF (c_visit_rec.inv_locator_id IS NOT NULL) THEN
      OPEN c_get_subinv_loc_dtls(c_visit_rec.inv_locator_id,c_visit_rec.organization_id);
      FETCH c_get_subinv_loc_dtls into l_sub_code, l_locator_code;
      CLOSE c_get_subinv_loc_dtls;
    END IF;

    -- Assigning all visits field to visit record attributes meant for display
    l_visit_rec.visit_id              :=  c_visit_rec.visit_id ;
    l_visit_rec.visit_name            :=  c_visit_rec.visit_name ;
    l_visit_rec.visit_number          :=  c_visit_rec.visit_number ;
    l_visit_rec.status_code           :=  c_visit_rec.status_code;
    l_visit_rec.status_name           :=  c_visit_rec.status_mean;
    l_visit_rec.visit_type_code       :=  c_visit_rec.visit_type_code ;
    l_visit_rec.visit_type_name       :=  c_visit_rec.VISIT_TYPE_MEAN ;
    l_visit_rec.object_version_number :=  c_visit_rec.object_version_number ;
    l_visit_rec.inventory_item_id     :=  c_visit_rec.inventory_item_id ;
    l_visit_rec.item_organization_id  :=  c_visit_rec.item_organization_id ;
    l_visit_rec.item_name             :=  c_visit_rec.ITEM_DESCRIPTION ;
    l_visit_rec.unit_name             :=  l_unit_name ;
    l_visit_rec.unit_header_id        :=  l_unit_header_id;
    l_visit_rec.item_instance_id      :=  c_visit_rec.item_instance_id ;
    l_visit_rec.serial_number         :=  c_visit_rec.serial_number ;
    l_visit_rec.service_request_id    :=  c_visit_rec.service_request_id;
    l_visit_rec.service_request_number:=  c_visit_rec.incident_number;
    l_visit_rec.space_category_code   :=  c_visit_rec.space_category_code;
    l_visit_rec.space_category_name   :=  c_visit_rec.space_category_mean;
    l_visit_rec.organization_id       :=  c_visit_rec.organization_id ;
    l_visit_rec.org_name              :=  c_visit_rec.ORGANIZATION_NAME ;
    l_visit_rec.department_id         :=  c_visit_rec.department_id  ;
    l_visit_rec.dept_name             :=  c_visit_rec.DEPARTMENT_NAME ;
    l_visit_rec.start_date            :=  c_visit_rec.START_DATE_TIME;
    l_visit_rec.start_hour            :=  l_hour;
    l_visit_rec.START_MIN             :=  l_minute;
    l_visit_rec.PLAN_END_DATE         :=  visit_rec.CLOSE_DATE_TIME;
    l_visit_rec.PLAN_END_HOUR         :=  l_hour_close;
    l_visit_rec.PLAN_END_MIN         :=  l_minute_close;
    l_visit_rec.project_flag          :=  l_project_flag;
    l_visit_rec.project_flag_code     :=  visit_rec.project_flag;
    l_visit_rec.end_date              :=  l_visit_end_date ;
    l_visit_rec.due_by_date           :=  TRUNC(l_due_date);
    l_visit_rec.duration              :=  NULL ;
    l_visit_rec.simulation_plan_id    :=  visit_rec.simulation_plan_id  ;
    l_visit_rec.simulation_plan_name  :=  l_simulation_plan_name ;
    l_visit_rec.template_flag         :=  c_visit_rec.template_flag ;
    l_visit_rec.description           :=  visit_rec.description ;
    l_visit_rec.last_update_date      :=  visit_rec.last_update_date;
    l_visit_rec.project_id            :=  visit_rec.project_id;
    l_visit_rec.project_number        :=  visit_rec.visit_number;
    l_visit_rec.outside_party_flag    :=  visit_rec.outside_party_flag;
    -- Post 11.5.10
    -- Reema Start
    l_visit_rec.priority_code         := visit_rec.priority_code;
    l_visit_rec.proj_template_id      := visit_rec.project_template_id;
    l_visit_rec.priority_value        := c_visit_rec.priority_mean;
    -- Reema End
    l_visit_rec.unit_schedule_id      := visit_rec.unit_schedule_id;

    /*Added by sowsubra*/
    l_visit_rec.subinventory          := l_sub_code;
    l_visit_rec.LOCATOR_SEGMENT       := l_locator_code;

    -- manisaga for DFF Enablement on 09-Feb-2010   Start
    l_visit_rec.attribute_category    := visit_rec.attribute_category;
    l_visit_rec.attribute1            := visit_rec.attribute1;
    l_visit_rec.attribute2            := visit_rec.attribute2;
    l_visit_rec.attribute3            := visit_rec.attribute3;
    l_visit_rec.attribute4            := visit_rec.attribute4;
    l_visit_rec.attribute5            := visit_rec.attribute5;
    l_visit_rec.attribute6            := visit_rec.attribute6;
    l_visit_rec.attribute7            := visit_rec.attribute7;
    l_visit_rec.attribute8            := visit_rec.attribute8;
    l_visit_rec.attribute9            := visit_rec.attribute9;
    l_visit_rec.attribute10           := visit_rec.attribute10;
    l_visit_rec.attribute11           := visit_rec.attribute11;
    l_visit_rec.attribute12           := visit_rec.attribute12;
    l_visit_rec.attribute13           := visit_rec.attribute13;
    l_visit_rec.attribute14           := visit_rec.attribute14;
    l_visit_rec.attribute15           := visit_rec.attribute15;
    -- manisaga for DFF Enablement on 09-Feb-2010   End


    --TCHIMIRA::P2P CP ER 9151144::02-DEC-2009
    --Assigning all concurrent program fields to visit record attributes meant for display on the update visit UI.
    l_visit_rec.cp_request_id         := visit_rec.request_id;
    l_visit_rec.cp_phase_code         := conc_req_rec.cp_phase_code;
    l_visit_rec.cp_status_code        := conc_req_rec.cp_status_code;
    l_visit_rec.cp_request_date       := conc_req_rec.cp_request_date;

    --Arvind Rupakula -Flight Number changes
    IF (visit_rec.unit_schedule_id IS NOT NULL) THEN
      OPEN c_flight_number(visit_rec.unit_schedule_id);
      FETCH c_flight_number INTO l_flight_number;
      CLOSE c_flight_number;
      l_visit_rec.flight_number         := l_flight_number;
    END IF;
    --End Changes
    x_visit_rec := l_visit_rec;
  END IF;
  ------------------------End of API Body------------------------------------
  -- Standard call to get message count and if count is 1, get message info
  Fnd_Msg_Pub.Count_And_Get
        ( p_count => x_msg_count,
        p_data  => x_msg_data,
        p_encoded => Fnd_Api.g_false);

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.end','At the end of PLSQL procedure');
  END IF;

  RETURN;
EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
   x_return_status := Fnd_Api.G_RET_STS_ERROR;
   ROLLBACK TO Get_Visit_Details;
   Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => Fnd_Api.g_false);

 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Get_Visit_Details;
   Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => Fnd_Api.g_false);

 WHEN OTHERS THEN
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Get_Visit_Details;
    Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => 'Get_Visit_Details',
                             p_error_text     => SQLERRM);
    Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count,
                               p_data    => x_msg_data,
                               p_encoded => Fnd_Api.g_false);
END Get_Visit_Details;

--------------------------------------------------------------------
-- PROCEDURE
--
--
-- PURPOSE
--    To create a Maintainance Visit
--------------------------------------------------------------------
PROCEDURE Create_Visit (
   p_api_version             IN     NUMBER,
   p_init_msg_list           IN     VARCHAR2  := Fnd_Api.g_false,
   p_commit                  IN     VARCHAR2  := Fnd_Api.g_false,
   p_validation_level        IN     NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type             IN     VARCHAR2  := 'JSP',
   p_x_visit_rec             IN OUT NOCOPY Visit_Rec_Type,
   x_return_status           OUT    NOCOPY VARCHAR2,
   x_msg_count               OUT    NOCOPY NUMBER,
   x_msg_data                OUT    NOCOPY VARCHAR2
)
IS
  -- Define local Variables
   L_API_VERSION           CONSTANT NUMBER := 1.0;
   L_API_NAME              CONSTANT VARCHAR2(30) := 'Create Visit';
   L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   L_DEBUG                 CONSTANT VARCHAR2(90) := 'ahl.plsql.'||L_FULL_NAME;

   l_msg_data              VARCHAR2(2000);
   l_unit_name             VARCHAR2(80);
   l_item_name             VARCHAR2(40);
   l_rowid                 VARCHAR2(30);
   l_date                  VARCHAR2(30);
   l_return_status         VARCHAR2(1);

   l_proj_temp_Id          NUMBER;
   l_msg_count             NUMBER;
   l_count                 NUMBER;
   l_dummy                 NUMBER;
   l_organization_id       NUMBER;
   l_department_id         NUMBER;
   l_item_id               NUMBER;
   l_serial_id             NUMBER;
   l_visit_number          NUMBER;
   l_org_id                NUMBER;
   l_simulation_plan_id    NUMBER;
   l_service_id            NUMBER;
   l_date_time             DATE;

   l_time  VARCHAR2(30);
   --TC Changes
   l_release_flag         VARCHAR2(1) := NULL;
   -- Post 11.5.10 Enhancements
   l_priority_code         VARCHAR2(30);
   l_proj_template_id      NUMBER;
   -- Define local record datatypes
   l_Visit_rec             Visit_Rec_Type := p_x_Visit_rec;
   -- Define local Cursors
   -- To find the next id value from visit sequence
   CURSOR c_seq IS
   SELECT Ahl_Visits_B_S.NEXTVAL
   FROM   dual;

   -- To find whether id already exists
   CURSOR c_id_exists (x_id IN NUMBER) IS
   SELECT 1 FROM   Ahl_Visits_VL
   WHERE  Visit_id = x_id;

   -- To find the maximum visit number among all visits
   CURSOR c_visit_number IS
   SELECT MAX(visit_number) FROM Ahl_Visits_B;

   -- Fix for ADS bug# 4357001.
   -- Changed cursor to not use ahl_mtl_items_ou_v and replaced with mtl_system_items_kfv
   -- and added OU stripping so that Master Org does not belong to the current user's OU.
   CURSOR c_unit_det (p_unit_name IN VARCHAR2) IS
/*  SELECT uc.name ,
           csis.serial_number ,
           csis.instance_id,
           mtl.inventory_item_id ,
           mtl.inventory_org_id
    FROM   ahl_mtl_items_ou_v mtl,
           ahl_unit_config_headers uc,
           csi_item_instances csis
    WHERE  uc.name = p_unit_name
    AND uc.csi_item_instance_id=csis.instance_id
    AND AHL_UTIL_UC_PKG.GET_UC_STATUS_CODE(uc.UNIT_CONFIG_HEADER_ID) in ('COMPLETE','INCOMPLETE','DEACTIVATE_QUARANTINE','QUARANTINE')
    AND (uc.active_end_date IS NULL OR uc.active_end_date > SYSDATE)
    AND csis.inventory_item_id = mtl.inventory_item_id
    AND csis.inv_master_organization_id = mtl.inventory_org_id
    AND csis.serial_number IS NOT NULL
    AND csis.ACTIVE_START_DATE <= sysdate AND (csis.ACTIVE_END_DATE >= sysdate OR csis.ACTIVE_END_DATE IS NULL); */

    /*   SELECT uc.name ,
               csis.serial_number ,
           csis.instance_id,
               mtl.inventory_item_id ,
               --mtl.inventory_org_id
               csis.inv_master_organization_id
        FROM   mtl_system_items_kfv mtl,
               ahl_unit_config_headers uc,
               csi_item_instances csis
        WHERE  uc.name = p_unit_name
        AND uc.csi_item_instance_id=csis.instance_id
    AND upper(AHL_UTIL_UC_PKG.GET_UC_STATUS_CODE(uc.UNIT_CONFIG_HEADER_ID))in ('COMPLETE','INCOMPLETE','DEACTIVATE_QUARANTINE','QUARANTINE')
        AND (uc.active_end_date IS NULL OR uc.active_end_date > SYSDATE)
        AND csis.inventory_item_id = mtl.inventory_item_id
        AND csis.inv_master_organization_id = mtl.organization_id
        AND csis.serial_number IS NOT NULL
    AND csis.ACTIVE_START_DATE <= sysdate AND (csis.ACTIVE_END_DATE >= sysdate OR csis.ACTIVE_END_DATE
IS NULL)
    AND csis.inv_master_organization_id IN ( SELECT mp.master_organization_id FROM org_organization_definitions org
        , mtl_parameters mp WHERE org.organization_id = mp.organization_id
    AND NVL(operating_unit, mo_global.get_current_org_id())
    = mo_global.get_current_org_id()); */

   -- AnRaj: Changed for fixing the perf bug 4919502
   SELECT uc.name ,
          csis.serial_number ,
          csis.instance_id,
          mtl.inventory_item_id ,
          csis.inv_master_organization_id
   FROM   mtl_system_items mtl,
          ahl_unit_config_headers uc,
          csi_item_instances csis
   WHERE  uc.name = p_unit_name
   AND    uc.csi_item_instance_id=csis.instance_id
   -- Fix by jaramana on June 27, 2006 for Bug 5360066
   -- AND      upper(AHL_UTIL_UC_PKG.GET_UC_STATUS(uc.UNIT_CONFIG_HEADER_ID))in ('COMPLETE','INCOMPLETE','DEACTIVATE_QUARANTINE','QUARANTINE')
   AND      AHL_UTIL_UC_PKG.GET_UC_STATUS_CODE(uc.UNIT_CONFIG_HEADER_ID)in ('COMPLETE','INCOMPLETE','DEACTIVATE_QUARANTINE','QUARANTINE')
   AND      (uc.active_end_date IS NULL OR uc.active_end_date > SYSDATE)
   AND      csis.inventory_item_id = mtl.inventory_item_id
   AND      csis.inv_master_organization_id = mtl.organization_id
   AND      csis.serial_number IS NOT NULL
   AND      csis.ACTIVE_START_DATE <= sysdate
   AND      (csis.ACTIVE_END_DATE >= sysdate OR csis.ACTIVE_END_DATE IS NULL)
   AND      csis.inv_master_organization_id IN
             (   SELECT mp.master_organization_id
                 FROM   inv_organization_info_v org, mtl_parameters mp
                 WHERE  org.organization_id = mp.organization_id
                 AND    NVL(operating_unit, mo_global.get_current_org_id()) = mo_global.get_current_org_id()
              );

  /*Added by sowsubra*/
  CURSOR c_subinv_validate (p_subinv_code IN VARCHAR2, p_org_id IN VARCHAR2) IS
      SELECT status_id
      FROM mtl_secondary_inventories
      WHERE secondary_inventory_name = p_subinv_code
      AND organization_id = p_org_id;

  /*Added by sowsubra*/
  CURSOR c_loc_validate (p_org_id IN NUMBER, p_subinv_code IN VARCHAR2, p_loc_seg IN VARCHAR2) IS
     -- jaramana on Feb 14, 2008 for bug 6819370
     -- Made segment19 and segment20 refer to base table
     SELECT mil.inventory_location_id
     from mtl_item_locations mil, mtl_item_locations_kfv milk
     where mil.organization_id = p_org_id
     and mil.subinventory_code = p_subinv_code
     and milk.concatenated_segments = p_loc_seg
     and mil.segment19 is NULL
     and mil.segment20 is NULL
     and mil.inventory_location_id = milk.inventory_location_id;

   l_inv_loc_id     NUMBER := 0;
   l_status_id      NUMBER;

BEGIN
  --------------------- Initialize -----------------------
  SAVEPOINT Create_Visit;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.begin','At the start of PLSQL procedure');
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF Fnd_Api.to_boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  -- Standard call to check for call compatibility.
  IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME) THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
  ------------------------Start of API Body------------------------------------

  --------------------Value OR ID conversion---------------------------
  IF p_module_type = 'JSP' THEN
      l_Visit_rec.organization_id       := NULL;
      l_Visit_rec.department_id         := NULL;
      l_Visit_rec.item_instance_id      := NULL;
      l_Visit_rec.service_request_id    := NULL;
  END IF;

  -- For VISIT STATUS
  -- To check visit status by default is Planning if not entered as input
  IF  l_visit_rec.status_code IS NULL OR l_visit_rec.status_code = Fnd_Api.G_MISS_CHAR THEN
    l_Visit_rec.status_code := 'PLANNING';
  END IF;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,L_DEBUG,'Status Code = ' || l_Visit_rec.status_code);
  END IF;

  ----------- Starts defining all Dropdowns on Create Visit UI Screen-------------
  -- For SPACE CATEGORY CODE
  IF l_Visit_rec.space_category_code = Fnd_Api.G_MISS_CHAR THEN
    l_Visit_rec.space_category_code := Null;
  END IF;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,L_DEBUG,'Space Category Code = ' || l_Visit_rec.space_category_code);
  END IF;
  ----------- End defining all Dropdowns on Create Visit UI Screen-------------
  ----------- Start defining and validate all LOVs on Create Visit UI Screen---
  -- For VISIT TYPE
  -- To find Visit Type Code when Visit Type Name has input values
  IF l_Visit_rec.visit_type_name IS NOT NULL AND
    l_Visit_rec.visit_type_name <> Fnd_Api.G_MISS_CHAR THEN

    AHL_VWP_RULES_PVT.Check_Lookup_Name_Or_Id (
          p_lookup_type   => 'AHL_PLANNING_VISIT_TYPE',
          p_lookup_code   => NULL,
          p_meaning       => l_Visit_rec.visit_type_name,
          p_check_id_flag => 'Y',
          x_lookup_code   => l_Visit_rec.visit_type_code,
          x_return_status => l_return_status);

    IF NVL(l_return_status, 'X') <> 'S' THEN
      Fnd_Message.SET_NAME('AHL','AHL_VWP_TYPE_CODE_NOT_EXISTS');
      Fnd_Msg_Pub.ADD;
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;
  END IF;

  IF l_Visit_rec.unit_name IS NOT NULL AND l_Visit_rec.unit_name <> Fnd_Api.G_MISS_CHAR THEN
      OPEN c_unit_det(l_Visit_rec.unit_name);
      FETCH c_unit_det INTO l_Visit_rec.unit_name,l_Visit_rec.serial_number,l_Visit_rec.item_instance_id,
                            l_Visit_rec.inventory_item_id,l_Visit_rec.item_organization_id;
      IF c_unit_det%NOTFOUND THEN
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG,'Unit does not exists..');
          END IF;
          Fnd_Message.SET_NAME('AHL','AHL_VWP_UNIT_NOT_EXISTS');
          Fnd_Msg_Pub.ADD;
          CLOSE c_unit_det;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
      CLOSE c_unit_det;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Serial Id found ' || l_Visit_rec.item_instance_id);
      END IF;
  ELSE
      l_Visit_rec.item_instance_id := NULL;
      l_Visit_rec.inventory_item_id := NULL;
      l_Visit_rec.item_organization_id := NULL;
      l_Visit_rec.serial_number := NULL;
  END IF;

  -- For ORGANIZATION
  -- To Convert Organization Name to Organization Id
  IF (l_Visit_rec.org_name IS NOT NULL AND
      l_Visit_rec.org_name <> Fnd_Api.G_MISS_CHAR) THEN

      AHL_VWP_RULES_PVT.Check_Org_Name_Or_Id
               (p_organization_id  => l_Visit_rec.organization_id,
                p_org_name         => l_Visit_rec.org_name,
                x_organization_id  => l_organization_id,
                x_return_status    => l_return_status,
                x_error_msg_code   => l_msg_data);

      IF NVL(l_return_status,'x') <> 'S' THEN
          Fnd_Message.SET_NAME('AHL','AHL_VWP_ORG_NOT_EXISTS');
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
  END IF;

  IF (l_Visit_rec.org_name IS NOT NULL AND
      l_Visit_rec.org_name <> Fnd_Api.G_MISS_CHAR ) THEN
      --Assign the returned value
      l_Visit_rec.organization_id := l_organization_id;
      /* ELSE
      l_Visit_rec.organization_id := NULL;*/
  END IF;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,L_DEBUG,'Org Name/ID' || l_Visit_rec.org_name || '-' || l_Visit_rec.organization_id );
  END IF;

  -- For DEPARTMENT
  -- To convert Department Name to Department Id
  IF (l_Visit_rec.dept_name IS NOT NULL AND
     l_Visit_rec.dept_name <> Fnd_Api.G_MISS_CHAR ) OR
     (l_Visit_rec.department_id IS NOT NULL AND
     l_Visit_rec.department_id <> Fnd_Api.G_MISS_NUM) THEN

      AHL_VWP_RULES_PVT.Check_Dept_Desc_Or_Id
               (p_organization_id  => l_Visit_rec.organization_id,
                p_dept_name        => l_Visit_rec.dept_name,
                p_department_id    => l_Visit_rec.department_id,
                x_department_id    => l_department_id,
                x_return_status    => l_return_status,
                x_error_msg_code   => l_msg_data);

      IF NVL(l_return_status,'x') <> 'S' THEN
          Fnd_Message.SET_NAME('AHL','AHL_VWP_DEPT_NOT_EXISTS');
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

      AHL_VWP_RULES_PVT.CHECK_DEPARTMENT_SHIFT
               (p_dept_id          => l_department_id,
                x_return_status    => l_return_status);

      IF NVL(l_return_status,'x') <> 'S' THEN
        Fnd_Message.SET_NAME('AHL','AHL_VWP_NO_DEPT_SHIFT');
        Fnd_Msg_Pub.ADD;
        RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
  END IF;

  IF (l_Visit_rec.dept_name IS NOT NULL AND l_Visit_rec.dept_name <> Fnd_Api.G_MISS_CHAR ) THEN
    --Assign the returned value
    l_Visit_rec.department_id := l_department_id;
    /* ELSE
    l_Visit_rec.department_id := NULL;*/
  END IF;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,L_DEBUG,'Dept Id/Name = ' || l_Visit_rec.department_id || ' - ' || l_Visit_rec.dept_name);
  END IF;

  -- For SERVICE REQUEST
  -- To Convert Service Request Number to Service Request Id
  IF (l_Visit_rec.service_request_number IS NOT NULL AND l_Visit_rec.service_request_number <> Fnd_Api.G_MISS_CHAR ) THEN
      AHL_VWP_RULES_PVT.Check_SR_Request_Number_Or_Id
           (p_service_id       => l_Visit_rec.service_request_id,
            p_service_number   => l_Visit_rec.service_request_number,
            x_service_id       => l_service_id,
            x_return_status    => l_return_status,
            x_error_msg_code   => l_msg_data);

      IF NVL(l_return_status,'x') <> 'S' THEN
           Fnd_Message.SET_NAME('AHL','AHL_VWP_SERVICE_REQ_NOT_EXISTS');
           Fnd_Msg_Pub.ADD;
           RAISE Fnd_Api.g_exc_error;
      END IF;

      --Assign the returned value
      l_Visit_rec.service_request_id := l_service_id;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'SR Id/Number = ' || l_Visit_rec.service_request_id || '-' || l_Visit_rec.service_request_number );
      END IF;
   END IF;

   ----------- End defining and validate all LOVs on Create Visit UI Screen---
   -- For VISIT START DATE TIME
   -- Convert time stamp for start date time
   IF l_Visit_rec.START_DATE IS NOT NULL AND l_Visit_rec.START_DATE <> fnd_api.g_miss_date THEN
     IF (l_Visit_rec.START_HOUR IS NOT NULL AND l_visit_rec.START_MIN IS NOT NULL)THEN
        l_date   :=  TO_CHAR(l_Visit_rec.START_DATE, 'DD-MM-YYYY ') || l_Visit_rec.start_hour ||':'|| l_visit_rec.start_min;
        l_Visit_rec.START_DATE :=  TO_DATE(l_date, 'DD-MM-YYYY HH24:MI');
     ELSIF l_Visit_rec.START_HOUR IS NOT NULL THEN
        l_date   :=  TO_CHAR(l_Visit_rec.START_DATE, 'DD-MM-YYYY ') || l_Visit_rec.start_hour || ':00';
        l_Visit_rec.START_DATE :=  TO_DATE(l_date, 'DD-MM-YYYY HH24:MI');
     ELSE
        l_date   :=  TO_CHAR(l_Visit_rec.START_DATE, 'DD-MM-YYYY ') || '00' || ':00';
        l_Visit_rec.START_DATE :=  TO_DATE(l_date, 'DD-MM-YYYY HH24:MI');
     END IF;
   END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,L_DEBUG,'Start Date' || l_Visit_rec.START_DATE);
   END IF;

   --Added by amagrawa for Transit Visit
   -- For VISIT PLANNED END DATE TIME
   -- Convert time stamp for planned end date time
   IF l_Visit_rec.plan_end_date IS NOT NULL AND l_Visit_rec.plan_end_date <> fnd_api.g_miss_date THEN
     IF (l_Visit_rec.plan_end_HOUR IS NOT NULL AND l_visit_rec.plan_end_MIN IS NOT NULL)THEN
        l_date   :=  TO_CHAR(l_Visit_rec.plan_end_date, 'DD-MM-YYYY ') || l_Visit_rec.plan_end_hour || ':'||l_visit_rec.plan_end_min;
        l_Visit_rec.plan_end_date :=  TO_DATE(l_date, 'DD-MM-YYYY HH24:MI');
     ELSIF l_Visit_rec.plan_end_hour IS NOT NULL THEN
        l_date   :=  TO_CHAR(l_Visit_rec.plan_end_date, 'DD-MM-YYYY ') || l_Visit_rec.plan_end_hour || ':00';
        l_Visit_rec.plan_end_date :=  TO_DATE(l_date, 'DD-MM-YYYY HH24:MI');
     ELSE
        l_date   :=  TO_CHAR(l_Visit_rec.plan_end_date, 'DD-MM-YYYY ') || '00' || ':00';
        l_Visit_rec.plan_end_date :=  TO_DATE(l_date, 'DD-MM-YYYY HH24:MI');
     END IF;
   END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,L_DEBUG,'End Date' || l_Visit_rec.plan_end_date);
   END IF;

   -- To validate visit start date should be less than plan end date
   IF l_Visit_rec.START_DATE IS NOT NULL  AND l_Visit_rec.plan_end_date IS NOT NULL THEN
      IF (l_Visit_rec.START_DATE > l_Visit_rec.plan_end_date) THEN
         Fnd_Message.SET_NAME('AHL','AHL_VWP_START_DT_GTR_CLOSE_DT');
         Fnd_Msg_Pub.ADD;
         RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
   END IF;
   -- End of changes by amagrawa
   -- For SIMULATION PLAN
   -- To check whether any primary plan exists in LTP
   IF l_visit_rec.SIMULATION_PLAN_ID = Fnd_Api.G_MISS_NUM THEN
      l_visit_rec.SIMULATION_PLAN_ID := NULL;
   END IF;

   IF (l_Visit_rec.SIMULATION_PLAN_ID IS NULL) THEN
      SELECT SIMULATION_PLAN_ID INTO l_simulation_plan_id
      FROM AHL_SIMULATION_PLANS_VL WHERE primary_plan_flag = 'Y';

      l_Visit_rec.SIMULATION_PLAN_ID := l_simulation_plan_id;

      IF l_simulation_plan_id IS NULL THEN
          Fnd_Message.SET_NAME('AHL','AHL_VWP_PRI_PLN_NOT_EXIST');
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
   END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,L_DEBUG,'Simulation Id' || l_Visit_rec.SIMULATION_PLAN_ID);
   END IF;

   -- Post 11.5.10 Enhancements
   -- For PRIORITY
   IF l_Visit_rec.priority_value IS NOT NULL AND l_Visit_rec.priority_value <> Fnd_Api.G_MISS_CHAR THEN
      AHL_VWP_RULES_PVT.Check_Lookup_Name_Or_Id
            (p_lookup_type  => 'AHL_VWP_VISIT_PRIORITY',
             p_lookup_code  => l_Visit_rec.priority_code,
             p_meaning      => l_Visit_rec.priority_value,
             p_check_id_flag => 'Y',
             x_lookup_code   => l_priority_code,
             x_return_status => l_return_status);

      IF NVL(l_return_status, 'X') <> 'S' THEN
        Fnd_Message.SET_NAME('AHL','AHL_VWP_PRI_NOT_EXISTS');
        Fnd_Msg_Pub.ADD;
        RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
      l_visit_rec.priority_code := l_priority_code;
   END IF;

   -- Post 11.5.10 Enhancements
   -- For PROJECT TEMPLATE
   IF l_visit_rec.proj_template_name IS NOT NULL THEN
      AHL_VWP_RULES_PVT.Check_Project_Template_Or_Id
            ( p_proj_temp_name => l_visit_rec.proj_template_name,
              x_project_id => l_proj_template_id,
              x_return_status => l_return_status,
              x_error_msg_code => l_msg_data);

      IF NVL(l_return_status, 'X') <> 'S' THEN
        Fnd_Message.SET_NAME('AHL','AHL_VWP_INVALID_PROTEM');
        Fnd_Msg_Pub.ADD;
        RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
      l_visit_rec.proj_template_id := l_proj_template_id;
   ELSE
      -- If Project Template Name is null
      -- then use the profile value
      l_visit_rec.proj_template_id := FND_PROFILE.VALUE('AHL_DEFAULT_PA_TEMPLATE_ID');
   END IF;

  /*Added by sowsubra - starts - Issue#86 changes*/
  l_dummy := NULL;

  IF ((l_visit_rec.subinventory IS NOT NULL) AND (l_visit_rec.locator_segment IS NULL)) THEN
           Fnd_Message.SET_NAME('AHL','AHL_VWP_LOCATOR_NULL');
           Fnd_Msg_Pub.ADD;
           RAISE Fnd_Api.G_EXC_ERROR;
  ELSIF ((l_visit_rec.subinventory IS NULL) AND (l_visit_rec.locator_segment IS NOT NULL))THEN
           Fnd_Message.SET_NAME('AHL','AHL_VWP_SUBINVENTORY_NULL');
           Fnd_Msg_Pub.ADD;
           RAISE Fnd_Api.G_EXC_ERROR;
  ELSIF ((l_visit_rec.subinventory IS NOT NULL) AND (l_visit_rec.locator_segment IS NOT NULL)) THEN

         OPEN c_subinv_validate (l_visit_rec.subinventory, l_visit_rec.organization_id);
         FETCH c_subinv_validate INTO l_status_id;
         IF (c_subinv_validate%NOTFOUND) THEN
             CLOSE c_subinv_validate;
             Fnd_Message.SET_NAME('AHL','AHL_VWP_SUBINV_NOT_EXISTS');
             Fnd_Msg_Pub.ADD;
             RAISE Fnd_Api.G_EXC_ERROR;
         ELSE
           IF l_status_id in (NVL(fnd_profile.value('AHL_MTL_MAT_STATUS_UNSERVICABLE'), -1), NVL(fnd_profile.value('AHL_MTL_MAT_STATUS_MRB'), -1)) THEN
             CLOSE c_subinv_validate;
             FND_MESSAGE.SET_NAME('AHL', 'AHL_SUBINVENTORY_NOT_SVC');
             FND_MESSAGE.Set_Token('INV', l_visit_rec.subinventory);
             FND_MSG_PUB.ADD;
             RAISE Fnd_Api.G_EXC_ERROR;
           END IF;
         END IF;
         CLOSE c_subinv_validate;

         l_dummy := NULL;

         OPEN c_loc_validate (l_visit_rec.organization_id, l_visit_rec.subinventory,l_visit_rec.locator_segment );
         FETCH c_loc_validate INTO l_inv_loc_id;
          IF c_loc_validate%NOTFOUND THEN
             Fnd_Message.SET_NAME('AHL','AHL_VWP_PHY_LOCATOR_NOT_EXISTS');
             Fnd_Msg_Pub.ADD;
             CLOSE c_loc_validate;
             RAISE Fnd_Api.G_EXC_ERROR;
          END IF;
         CLOSE c_loc_validate;

         l_visit_rec.inv_locator_id := l_inv_loc_id;
  ELSE
    l_visit_rec.inv_locator_id := NULL;
  END IF;
  /*Added by sowsubra - end - FP Issue#86 changes*/

   -------------------------------- Validate -----------------------------------------
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling Validate_Visit');
   END IF;

   Validate_Visit (
      p_api_version        => l_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_commit             => Fnd_Api.g_false,
      p_validation_level   => p_validation_level,
      p_Visit_rec          => l_Visit_rec,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data
    );

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling Validate_Visit - l_return_status : '||l_return_status);
   END IF;

   -- Check for the ID.
   IF (l_Visit_rec.VISIT_ID = Fnd_Api.g_miss_num OR l_Visit_rec.VISIT_ID IS Null) THEN
     -- If the ID is not passed into the API, then
     -- grab a value from the sequence.
     OPEN c_seq;
     FETCH c_seq INTO l_Visit_rec.VISIT_ID;
     CLOSE c_seq;

     -- Check to be sure that the sequence does not exist.
     OPEN c_id_exists (l_Visit_rec.VISIT_ID);
     FETCH c_id_exists INTO l_dummy;
     CLOSE c_id_exists;

     -- If the value for the ID already exists, then
     -- l_dummy would be populated with '1', otherwise, it receives NULL.
     IF l_dummy IS NOT NULL THEN
       Fnd_Message.SET_NAME('AHL','AHL_VWP_SEQUENCE_NOT_EXISTS');
       Fnd_Msg_Pub.ADD;
     END IF;

     -- For all optional fields check if its g_miss_num/g_miss_char/g_miss_date
     -- then Null else the value call Default_Missing_Attribs procedure
     Default_Missing_Attribs
               ( p_x_visit_rec             => l_Visit_rec );

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'Visit ID : '||l_Visit_rec.VISIT_ID);
    END IF;
   END IF;

   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Check for Visit Number
   OPEN c_visit_number;
   FETCH c_visit_number INTO l_visit_number;
   CLOSE c_visit_number;

   IF l_visit_number IS NOT NULL THEN
      l_visit_number := l_visit_number + 1;
   ELSE
      l_visit_number := 1;
   END IF;

   l_Visit_rec.VISIT_NUMBER := l_visit_number;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'Visit ID =' || l_Visit_rec.VISIT_ID);
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'Visit Number =' || l_Visit_rec.VISIT_NUMBER);
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'Visit Name =' || l_Visit_rec.VISIT_Name);
   END IF;

   -- Transit Check Changes Senthil.
   IF l_Visit_rec.unit_schedule_id IS NOT NULL
      AND  l_Visit_rec.unit_schedule_id <> FND_API.G_MISS_NUM THEN

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_UA_FLIGHT_SCHEDULES_PVT.Validate_Flight_Schedule');
      END IF;

      -- Validate with UMP API
      AHL_UA_FLIGHT_SCHEDULES_PVT.Validate_Flight_Schedule
        (
        P_API_VERSION        => 1.0,
        X_RETURN_STATUS      => l_return_status,
        X_MSG_COUNT          => l_msg_count,
        X_MSG_DATA           => l_msg_data,
        P_UNIT_CONFIG_ID     => l_Visit_rec.unit_header_id,
        P_UNIT_SCHEDULE_ID   => l_Visit_rec.unit_schedule_id
        );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_UA_FLIGHT_SCHEDULES_PVT.Validate_Flight_Schedule - l_return_status : '||l_return_status);
      END IF;

      IF l_msg_count > 0 THEN
        X_msg_count := l_msg_count;
        X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Instance ID is madatory for transit visit
      IF  l_Visit_rec.item_instance_id IS NULL
        OR  l_Visit_rec.item_instance_id = FND_API.G_MISS_NUM THEN
         Fnd_Message.SET_NAME('AHL','AHL_VWP_TC_UNIT_REQ');
         Fnd_Msg_Pub.ADD;
      END IF;

      -- Planned Start Date is madatory for transit visit
      IF  l_visit_rec.START_DATE IS NULL OR  l_visit_rec.START_DATE = FND_API.g_miss_date THEN
         Fnd_Message.SET_NAME('AHL','AHL_VWP_TC_ST_DT_REQ');
         Fnd_Msg_Pub.ADD;
      END IF;

      -- Planned End Date is madatory for transit visit
      /*
      IF p_module_type = 'JSP' AND ( l_visit_rec.PLAN_END_DATE IS NULL
        OR  l_visit_rec.PLAN_END_DATE = FND_API.g_miss_date) THEN
          l_visit_rec.PLAN_END_DATE:= l_visit_rec.START_DATE + (FND_PROFILE.VALUE('AHL_TRANSIT_VISIT_DEFAULT_DURATION')/1440);
      END IF;
      */
   ELSE
      l_Visit_rec.unit_schedule_id := NULL;
   END IF;

   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -------------------------- Insert --------------------------
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling Ahl_Visits_Pkg.Insert_Row');
   END IF;
   -- Invoke the table handler to create a record
   -- Post 11.5.10 Enhancements
   -- Added Priority and Project Template Id
   -- Added Unit Schedule Id.

   Ahl_Visits_Pkg.Insert_Row (
     X_ROWID                 => l_rowid,
     X_VISIT_ID              => l_Visit_rec.VISIT_ID,
     X_VISIT_NUMBER          => l_visit_number,
     X_VISIT_TYPE_CODE       => l_Visit_rec.VISIT_TYPE_CODE,
     X_SIMULATION_PLAN_ID    => l_Visit_rec.SIMULATION_PLAN_ID,
     X_ITEM_INSTANCE_ID      => l_Visit_rec.ITEM_INSTANCE_ID,
     X_INVENTORY_ITEM_ID     => l_Visit_rec.INVENTORY_ITEM_ID,
     X_ITEM_ORGANIZATION_ID  => l_Visit_rec.ITEM_ORGANIZATION_ID,
     X_ASSO_PRIMARY_VISIT_ID => l_Visit_rec.ASSO_PRIMARY_VISIT_ID,
     X_SIMULATION_DELETE_FLAG => 'N',
     X_TEMPLATE_FLAG         => 'N',
     X_OUT_OF_SYNC_FLAG      => l_Visit_rec.OUT_OF_SYNC_FLAG,
     X_PROJECT_FLAG          => 'Y',
     X_PROJECT_ID            => l_Visit_rec.PROJECT_ID,
     X_SERVICE_REQUEST_ID    => l_Visit_rec.SERVICE_REQUEST_ID,
     X_SPACE_CATEGORY_CODE   => l_Visit_rec.SPACE_CATEGORY_CODE,
     X_SCHEDULE_DESIGNATOR   => NULL,
     X_ATTRIBUTE_CATEGORY    => l_Visit_rec.ATTRIBUTE_CATEGORY,
     X_ATTRIBUTE1            => l_Visit_rec.ATTRIBUTE1,
     X_ATTRIBUTE2            => l_Visit_rec.ATTRIBUTE2,
     X_ATTRIBUTE3            => l_Visit_rec.ATTRIBUTE3,
     X_ATTRIBUTE4            => l_Visit_rec.ATTRIBUTE4,
     X_ATTRIBUTE5            => l_Visit_rec.ATTRIBUTE5,
     X_ATTRIBUTE6            => l_Visit_rec.ATTRIBUTE6,
     X_ATTRIBUTE7            => l_Visit_rec.ATTRIBUTE7,
     X_ATTRIBUTE8            => l_Visit_rec.ATTRIBUTE8,
     X_ATTRIBUTE9            => l_Visit_rec.ATTRIBUTE9,
     X_ATTRIBUTE10           => l_Visit_rec.ATTRIBUTE10,
     X_ATTRIBUTE11           => l_Visit_rec.ATTRIBUTE11,
     X_ATTRIBUTE12           => l_Visit_rec.ATTRIBUTE12,
     X_ATTRIBUTE13           => l_Visit_rec.ATTRIBUTE13,
     X_ATTRIBUTE14           => l_Visit_rec.ATTRIBUTE14,
     X_ATTRIBUTE15           => l_Visit_rec.ATTRIBUTE15,
     X_OBJECT_VERSION_NUMBER => 1,
     X_ORGANIZATION_ID       => l_Visit_rec.ORGANIZATION_ID,
     X_DEPARTMENT_ID         => l_Visit_rec.DEPARTMENT_ID,
     X_STATUS_CODE           => l_Visit_rec.STATUS_CODE,
     X_START_DATE_TIME       => l_visit_rec.START_DATE,
     X_CLOSE_DATE_TIME       => l_visit_rec.PLAN_END_DATE,
     X_PRICE_LIST_ID         => NULL,
     X_ESTIMATED_PRICE       => NULL,
     X_ACTUAL_PRICE          => NULL,
     X_OUTSIDE_PARTY_FLAG    => 'N',
     X_ANY_TASK_CHG_FLAG     => 'N',
     X_VISIT_NAME            => l_Visit_rec.VISIT_NAME,
     X_DESCRIPTION           => l_Visit_rec.DESCRIPTION,
     X_CREATION_DATE         => SYSDATE,
     X_CREATED_BY            => Fnd_Global.USER_ID,
     X_LAST_UPDATE_DATE      => SYSDATE,
     X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
     X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID,
     X_PRIORITY_CODE         => l_visit_rec.priority_code,
     X_PROJECT_TEMPLATE_ID   => l_visit_rec.proj_template_id,
     X_UNIT_SCHEDULE_ID      => l_Visit_rec.unit_schedule_id,
     X_INV_LOCATOR_ID        => l_Visit_rec.inv_locator_id /*Added by sowsubra*/
);

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling Ahl_Visits_Pkg.Insert_Row');
   END IF;

   -- set OUT value
   p_x_visit_rec.VISIT_ID := l_Visit_rec.VISIT_ID;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_VWP_VISITS_STAGES_PVT.CREATE_STAGES');
   END IF;

   -----CREATE STAGES IF VISIT HAS BEEN CREATED SUCESSFULLY--------
   AHL_VWP_VISITS_STAGES_PVT.CREATE_STAGES
              ( p_api_version           => p_api_version,
                p_init_msg_list         => p_init_msg_list,
                p_commit                => Fnd_Api.g_false,
                p_validation_level      => p_validation_level,
                p_module_type           => p_module_type,
                p_visit_id              => l_Visit_rec.VISIT_ID,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data
              );

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_VWP_VISITS_STAGES_PVT.CREATE_STAGES - x_return_status : '||x_return_status);
   END IF;

   IF l_Visit_rec.visit_type_code IS NOT NULL
      AND l_Visit_rec.visit_type_code <> FND_API.G_MISS_CHAR THEN

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_VWP_TASKS_PVT.ASSOCIATE_DEFAULT_MRS');
      END IF;

      AHL_VWP_TASKS_PVT.ASSOCIATE_DEFAULT_MRS
      (
        p_api_version           => 1.0,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_visit_rec             => l_Visit_rec
      );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_VWP_TASKS_PVT.ASSOCIATE_DEFAULT_MRS - x_return_status : '||x_return_status);
      END IF;

      --Standard check to count messages
      l_msg_count := Fnd_Msg_Pub.count_msg;

      IF l_msg_count > 0 THEN
        X_msg_count := l_msg_count;
        X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_VWP_TIMES_PVT.Calculate_Task_Times');
   END IF;

   --Now adjust the times derivation for task
   AHL_VWP_TIMES_PVT.Calculate_Task_Times(p_api_version => 1.0,
                                    p_init_msg_list     => Fnd_Api.G_FALSE,
                                    p_commit            => Fnd_Api.G_FALSE,
                                    p_validation_level  => Fnd_Api.G_VALID_LEVEL_FULL,
                                    x_return_status     => l_return_status,
                                    x_msg_count         => l_msg_count,
                                    x_msg_data          => l_msg_data,
                                    p_visit_id          => l_visit_rec.visit_id);

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_VWP_TIMES_PVT.Calculate_Task_Times - l_return_status : '||l_return_status);
   END IF;

   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Added by sjayacha as per Shailaja mail
   IF l_Visit_rec.unit_schedule_id IS NOT NULL
      AND  l_Visit_rec.unit_schedule_id <> FND_API.G_MISS_NUM THEN
        l_date_time := NVL(NVL(l_visit_rec.PLAN_END_DATE,
                               AHL_VWP_TIMES_PVT.get_visit_end_time(l_Visit_rec.visit_id)),
                               l_visit_rec.START_DATE + (FND_PROFILE.VALUE('AHL_TRANSIT_VISIT_DEFAULT_DURATION')/1440));

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement,L_DEBUG,'l_date_time - '||l_date_time);
        END IF;

        UPDATE ahl_visits_b
        SET   close_date_time = l_date_time
        WHERE  visit_id = l_Visit_rec.visit_id ;
   END IF;

   IF l_Visit_rec.visit_create_type IS NOT NULL
   AND l_Visit_rec.visit_create_type <> FND_API.G_MISS_CHAR THEN
      IF l_Visit_rec.visit_create_type = 'PRODUCTION_RELEASED' THEN
          l_release_flag := 'Y';
      ELSIF l_Visit_rec.visit_create_type = 'PRODUCTION_UNRELEASED' THEN
          l_release_flag := 'N';
      END IF;

      IF l_release_flag IS NOT NULL THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_VWP_PROJ_PROD_PVT.Release_Visit');
        END IF;

        AHL_VWP_PROJ_PROD_PVT.Release_Visit (
            p_api_version         => 1.0,
           /*p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
            p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
            p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FU */
            p_module_type         => 'VWP',
            p_visit_id            => l_Visit_rec.VISIT_ID,
            p_release_flag        => l_release_flag,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_VWP_PROJ_PROD_PVT.Release_Visit - x_return_status : '||x_return_status);
        END IF;
      END IF;
   END IF;   -- l_Visit_rec.visit_create_type IS NOT NULL
   ---------------------------End of API Body---------------------------------------
   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.end','At the end of PLSQL procedure');
  END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Create_Visit;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get(
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Create_Visit;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Visit;
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
END Create_Visit;

--------------------------------------------------------------------
-- PROCEDURE
--
--
-- PURPOSE
--    To copy to Visit/Template from a Visit/Template
--------------------------------------------------------------------
PROCEDURE Copy_Visit (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type       IN  VARCHAR2  := 'JSP',
   p_visit_id          IN  NUMBER,
   p_x_visit_rec       IN  OUT NOCOPY Visit_Rec_Type,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
)
IS
 -- Define local Variables
   L_API_VERSION          CONSTANT NUMBER := 1.0;
   L_API_NAME             CONSTANT VARCHAR2(30) := 'Copy_Visit';
   L_FULL_NAME            CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   L_DEBUG                CONSTANT VARCHAR2(90) := 'ahl.plsql.'||L_FULL_NAME;

   l_msg_data              VARCHAR2(2000);
   l_return_status         VARCHAR2(1);
   l_msg_count             NUMBER;

   l_rowid                 VARCHAR2(30);

   l_planned_order_flag    VARCHAR2(1);

   l_visit_id              NUMBER;
   l_visit_number          NUMBER;

   l_price_changed         VARCHAR2(1) := 'N';
   l_actual_price          NUMBER;
   l_estimate_price        NUMBER;

   l_task_department_id    NUMBER;
   l_visit_task_id         NUMBER;
   l_parent_task_id        NUMBER;
   l_new_parent_task_id    NUMBER;
   l_new_task_id           NUMBER;


 -- Define local record datatypes
    l_visit_rec             Visit_Rec_Type := p_x_visit_rec;

 -- Define local Cursors
   -- To find visit related information
   CURSOR c_visit (x_visit_id IN NUMBER) IS
      SELECT * FROM AHL_VISITS_VL
      WHERE VISIT_ID = x_visit_id;
   c_visit_rec c_visit%ROWTYPE;

     -- To find task related information for a visit
     -- Dont copy deleted tasks to new visit.
   CURSOR c_task (x_visit_id IN NUMBER) IS
      SELECT * FROM AHL_VISIT_TASKS_VL
      WHERE VISIT_ID = x_visit_id AND NVL(STATUS_CODE,'X') <> 'DELETED';
   c_task_rec c_task%ROWTYPE;

    -- To find task link related information for a visit
   CURSOR c_visit_task_links(x_visit_id IN NUMBER) IS
     SELECT VISIT_TASK_ID,
            PARENT_TASK_ID,
            --SECURITY_GROUP_ID,
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
     FROM AHL_TASK_LINKS
     WHERE visit_task_id in (  SELECT VISIT_TASK_ID
                    FROM AHL_VISIT_TASKS_B
                    WHERE visit_id = x_visit_id);

    l_task_link_rec c_visit_task_links%ROWTYPE;

    -- To find the coresponding task id in the new visit
   CURSOR c_new_task_ID(x_visit_task_id IN NUMBER, x_new_visit_id IN NUMBER) IS
     SELECT b.VISIT_TASK_ID
     FROM AHL_VISIT_TASKS_B a, AHL_VISIT_TASKS_B b
     WHERE a.visit_task_id = x_visit_task_id
          AND a.visit_task_number = b.visit_task_number
          AND b.visit_id = x_new_visit_id;

BEGIN
  --------------------- Initialize -----------------------
  SAVEPOINT Copy_Visit;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.begin','At the start of PLSQL procedure');
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF Fnd_Api.to_boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  -- Standard call to check for call compatibility.
  IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME) THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
  ------------------------Start of API Body------------------------------------
  -----------------------Value/Id conversions ----------------------
  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,L_DEBUG,'Visit Id - '||p_visit_id);
  END IF;

  OPEN c_visit(p_visit_id);
  FETCH c_visit INTO c_visit_rec;
  IF c_Visit%NOTFOUND THEN
      CLOSE c_Visit;
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
          Fnd_Message.set_name('AHL', 'AHL_API_RECORD_NOT_FOUND');
          Fnd_Msg_Pub.ADD;
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG,'Visit not found for' ||l_visit_rec.visit_id );
          END IF;
      END IF;
      RAISE Fnd_Api.g_exc_error;
  ELSE
    CLOSE c_Visit;
  END IF;

  -- Check if the visit status is deleted.display error message if so. Added in 11.5.10
  IF UPPER(c_visit_rec.status_code) = 'DELETED' THEN
      Fnd_Message.SET_NAME('AHL','AHL_VWP_INVALID_STATUS');
      Fnd_Msg_Pub.ADD;
      RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

  -- org/dept/start date/end date are passed from UA
  -- Null check and org/dept/dates validation is already done from calling API Synchronize_Visit
  -- If organization/Department/Start Date changed then clear up price
  IF l_visit_rec.organization_id <> c_Visit_rec.organization_id
     OR l_visit_rec.department_id <> c_Visit_rec.department_id
     OR l_visit_rec.START_DATE <> c_Visit_rec.START_DATE_TIME THEN
      l_price_changed  := 'Y';
      l_actual_price   := NULL;
      l_estimate_price := NULL;
  ELSE
      l_actual_price   := c_Visit_rec.ACTUAL_PRICE;
      l_estimate_price := c_Visit_rec.ESTIMATED_PRICE;
  END IF;

  -- Get ID and Number for the new visit
  l_visit_id := Get_Visit_Id();
  l_visit_number := Get_Visit_Number();

  -- Create New Visit
  Ahl_Visits_Pkg.Insert_Row (
       X_ROWID                 => l_rowid,
       X_VISIT_ID              => l_Visit_ID,
       X_VISIT_NUMBER          => l_visit_number,
       X_VISIT_TYPE_CODE       => c_Visit_rec.VISIT_TYPE_CODE,
       X_SIMULATION_PLAN_ID    => c_Visit_rec.simulation_plan_id,
       X_ITEM_INSTANCE_ID      => c_Visit_rec.item_instance_id,
       X_INVENTORY_ITEM_ID     => c_visit_rec.INVENTORY_ITEM_ID,
       X_ITEM_ORGANIZATION_ID  => c_Visit_rec.ITEM_ORGANIZATION_ID,
       X_ASSO_PRIMARY_VISIT_ID => c_Visit_rec.asso_primary_visit_id,
       X_SIMULATION_DELETE_FLAG=> 'N',
       X_TEMPLATE_FLAG         => c_Visit_rec.TEMPLATE_FLAG,
       X_OUT_OF_SYNC_FLAG      => NULL,
       X_PROJECT_FLAG          => c_Visit_rec.PROJECT_FLAG,
       X_PROJECT_ID            => NULL,
       X_SERVICE_REQUEST_ID    => c_Visit_rec.SERVICE_REQUEST_ID,
       X_SCHEDULE_DESIGNATOR   => c_Visit_rec.SCHEDULE_DESIGNATOR,
       X_SPACE_CATEGORY_CODE   => c_Visit_rec.SPACE_CATEGORY_CODE,
       X_ATTRIBUTE_CATEGORY    => c_visit_rec.ATTRIBUTE_CATEGORY,
       X_ATTRIBUTE1            => c_visit_rec.ATTRIBUTE1,
       X_ATTRIBUTE2            => c_visit_rec.ATTRIBUTE2,
       X_ATTRIBUTE3            => c_Visit_rec.ATTRIBUTE3,
       X_ATTRIBUTE4            => c_Visit_rec.ATTRIBUTE4,
       X_ATTRIBUTE5            => c_Visit_rec.ATTRIBUTE5,
       X_ATTRIBUTE6            => c_Visit_rec.ATTRIBUTE6,
       X_ATTRIBUTE7            => c_Visit_rec.ATTRIBUTE7,
       X_ATTRIBUTE8            => c_Visit_rec.ATTRIBUTE8,
       X_ATTRIBUTE9            => c_Visit_rec.ATTRIBUTE9,
       X_ATTRIBUTE10           => c_Visit_rec.ATTRIBUTE10,
       X_ATTRIBUTE11           => c_Visit_rec.ATTRIBUTE11,
       X_ATTRIBUTE12           => c_Visit_rec.ATTRIBUTE12,
       X_ATTRIBUTE13           => c_Visit_rec.ATTRIBUTE13,
       X_ATTRIBUTE14           => c_Visit_rec.ATTRIBUTE14,
       X_ATTRIBUTE15           => c_Visit_rec.ATTRIBUTE15,
       X_OBJECT_VERSION_NUMBER => 1,
       X_ORGANIZATION_ID       => l_Visit_rec.ORGANIZATION_ID,
       X_DEPARTMENT_ID         => l_Visit_rec.DEPARTMENT_ID,
       X_STATUS_CODE           => 'PLANNING',
       X_START_DATE_TIME       => l_Visit_rec.START_DATE,
       X_CLOSE_DATE_TIME       => l_Visit_rec.PLAN_END_DATE,
       X_PRICE_LIST_ID         => c_Visit_rec.PRICE_LIST_ID,
       X_ESTIMATED_PRICE       => l_estimate_price,
       X_ACTUAL_PRICE          => l_actual_price,
       X_OUTSIDE_PARTY_FLAG    => c_Visit_rec.OUTSIDE_PARTY_FLAG,
       X_ANY_TASK_CHG_FLAG     => 'N',
       X_VISIT_NAME            => c_Visit_rec.VISIT_NAME,
       X_DESCRIPTION           => c_Visit_rec.DESCRIPTION,
       X_CREATION_DATE         => SYSDATE,
       X_CREATED_BY            => Fnd_Global.USER_ID,
       X_LAST_UPDATE_DATE      => SYSDATE,
       X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
       X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID,
       X_PRIORITY_CODE         => c_Visit_rec.PRIORITY_CODE,
       X_PROJECT_TEMPLATE_ID   => c_Visit_rec.PROJECT_TEMPLATE_ID,
       X_UNIT_SCHEDULE_ID      => c_Visit_rec.UNIT_SCHEDULE_ID,
       X_INV_LOCATOR_ID        => l_Visit_rec.inv_locator_id --Added by sowsubra
       );

  -- Copy Tasks from originating visit
  OPEN c_task(p_visit_id);
  LOOP
    FETCH c_task INTO c_task_rec;
    EXIT WHEN c_task%NOTFOUND;

    c_task_rec.visit_task_id := AHL_VWP_RULES_PVT.Get_Visit_Task_Id();

    -- if visit org/dept/dates are changed, then clear up task price
    IF l_price_changed  = 'Y' THEN
       l_actual_price   := NULL;
       l_estimate_price := NULL;
    ELSE
       l_actual_price   := c_task_rec.ACTUAL_PRICE;
       l_estimate_price := c_task_rec.ESTIMATED_PRICE;
    END IF;

    -- if visit organization changed, then clear up task department
    IF l_visit_rec.organization_id <> c_Visit_rec.organization_id THEN
      l_task_department_id := NULL;
    ELSE
      l_task_department_id := c_task_rec.department_id;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before AHL_VISIT_TASKS_PKG.INSERT_ROW');
    END IF;

    -- Create task in new visit
    AHL_VISIT_TASKS_PKG.INSERT_ROW
        ( X_ROWID                 => l_rowid,
          X_VISIT_TASK_ID         => c_task_rec.visit_task_id,
          X_VISIT_TASK_NUMBER     => c_task_rec.visit_task_number,
          X_OBJECT_VERSION_NUMBER => 1,
          X_VISIT_ID              => l_visit_id,
          X_PROJECT_TASK_ID       => NULL,
          X_COST_PARENT_ID        => c_task_rec.cost_parent_id,
          X_MR_ROUTE_ID           => c_task_rec.MR_ID,
          X_MR_ID                 => c_task_rec.MR_ROUTE_ID,
          X_DURATION              => c_task_rec.duration,
          X_UNIT_EFFECTIVITY_ID   => c_task_rec.UNIT_EFFECTIVITY_ID,
          X_START_FROM_HOUR       => c_task_rec.start_from_hour,
          X_INVENTORY_ITEM_ID     => c_task_rec.inventory_item_id,
          X_ITEM_ORGANIZATION_ID  => c_task_rec.item_organization_id,
          X_INSTANCE_ID           => c_task_rec.instance_id,
          X_PRIMARY_VISIT_TASK_ID => c_task_rec.primary_visit_task_id,
          X_ORIGINATING_TASK_ID   => c_task_rec.originating_task_id,
          X_SERVICE_REQUEST_ID    => c_task_rec.service_request_id,
          X_TASK_TYPE_CODE        => c_task_rec.task_type_code,
          X_DEPARTMENT_ID         => l_task_department_id,
          X_SUMMARY_TASK_FLAG     => c_task_rec.SUMMARY_TASK_FLAG,
          X_PRICE_LIST_ID         => c_task_rec.PRICE_LIST_ID,
          X_STATUS_CODE           => 'PLANNING',
          X_ESTIMATED_PRICE       => l_estimate_price,
          X_ACTUAL_PRICE          => l_actual_price,
          X_ACTUAL_COST           => c_task_rec.ACTUAL_COST,
          X_STAGE_ID              => c_task_rec.STAGE_ID,
          -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010
          -- Pass past dates too, and if it is null, pass null for all the 4 columns below
          X_START_DATE_TIME       => c_task_rec.PAST_TASK_START_DATE,
          X_END_DATE_TIME         => c_task_rec.PAST_TASK_END_DATE,
          X_PAST_TASK_START_DATE  => c_task_rec.PAST_TASK_START_DATE,
          X_PAST_TASK_END_DATE    => c_task_rec.PAST_TASK_END_DATE,
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
          X_VISIT_TASK_NAME       => c_task_rec.visit_task_name,
          X_DESCRIPTION           => c_task_rec.description,
          X_QUANTITY              => c_task_rec.quantity, -- Added by rnahata for Issue 105
          X_CREATION_DATE         => SYSDATE,
          X_CREATED_BY            => Fnd_Global.USER_ID,
          X_LAST_UPDATE_DATE      => SYSDATE,
          X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
          X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID );

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_VISIT_TASKS_PKG.INSERT_ROW ');
    END IF;

    -- Create Planned Material if task type is planned or unplanned
    IF c_task_rec.task_type_code in ('PLANNED','UNPLANNED') THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling  AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials');
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Value of Visit Task ID : ' || c_task_rec.visit_task_id);
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Value of Visit ID : ' || l_visit_id);
      END IF;

      -- To call LTP Process Materials API for APS Integration
      AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials
            ( p_api_version             => 1.0,
              p_init_msg_list           => FND_API.g_false,
              p_commit                  => FND_API.g_false,
              p_validation_level        => FND_API.g_valid_level_full,
              p_visit_id                => l_Visit_Id,
              p_visit_task_id           => c_task_rec.visit_task_id,
              p_org_id                  => NULL,
              p_start_date              => NULL,
              p_operation_flag          => 'C',
              x_planned_order_flag      => l_planned_order_flag ,
              x_return_status           => l_return_status,
              x_msg_count               => l_msg_count,
              x_msg_data                => l_msg_data );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials : l_return_status - '||l_return_status);
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Planned Order Flag : ' || l_planned_order_flag);
      END IF;

      IF l_return_status <> 'S' THEN
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END LOOP;
  CLOSE c_task;

  -- Copy task links from originating visit
  OPEN c_visit_task_links(p_visit_id);
  LOOP
    --FETCH c_visit_task_links INTO l_visit_task_id, l_parent_task_id;
    FETCH c_visit_task_links INTO l_task_link_rec;
    EXIT WHEN c_visit_task_links%NOTFOUND;

    -- Find coresponding task id in new visit
    --OPEN c_new_task_ID(l_visit_task_id,l_visit_id);
    OPEN c_new_task_ID(l_task_link_rec.visit_task_id,l_visit_id);
    FETCH c_new_task_ID INTO l_new_task_id;
    CLOSE c_new_task_ID;

    --OPEN c_new_task_ID(l_parent_task_id,l_visit_id);
    OPEN c_new_task_ID(l_task_link_rec.parent_task_id,l_visit_id);
    FETCH c_new_task_ID INTO l_new_parent_task_id;
    CLOSE c_new_task_ID;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before inserting into AHL_TASK_LINKS');
    END IF;

    -- Create task link
    INSERT INTO AHL_TASK_LINKS
            (   TASK_LINK_ID,
                OBJECT_VERSION_NUMBER,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                VISIT_TASK_ID,
                PARENT_TASK_ID,
                --SECURITY_GROUP_ID,
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
            (
                ahl_task_links_s.nextval,
                1,
                SYSDATE,
                Fnd_Global.USER_ID,
                SYSDATE,
                Fnd_Global.USER_ID,
                Fnd_Global.USER_ID,
                l_new_task_id ,
                l_new_parent_task_id,
                --l_task_link_rec.SECURITY_GROUP_ID,
                l_task_link_rec.ATTRIBUTE_CATEGORY,
                l_task_link_rec.ATTRIBUTE1,
                l_task_link_rec.ATTRIBUTE2,
                l_task_link_rec.ATTRIBUTE3,
                l_task_link_rec.ATTRIBUTE4,
                l_task_link_rec.ATTRIBUTE5,
                l_task_link_rec.ATTRIBUTE6,
                l_task_link_rec.ATTRIBUTE7,
                l_task_link_rec.ATTRIBUTE8,
                l_task_link_rec.ATTRIBUTE9,
                l_task_link_rec.ATTRIBUTE10,
                l_task_link_rec.ATTRIBUTE11,
                l_task_link_rec.ATTRIBUTE12,
                l_task_link_rec.ATTRIBUTE13,
                l_task_link_rec.ATTRIBUTE14,
                l_task_link_rec.ATTRIBUTE15
           );

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'After inserting into AHL_TASK_LINKS');
    END IF;

  END LOOP;
  CLOSE c_visit_task_links;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_VWP_TIMES_PVT.Calculate_Task_Times');
  END IF;

  --Now adjust the times derivation for visit.
  AHL_VWP_TIMES_PVT.Calculate_Task_Times
          (p_api_version      => 1.0,
           p_init_msg_list    => Fnd_Api.G_FALSE,
           p_commit           => Fnd_Api.G_FALSE,
           p_validation_level => Fnd_Api.G_VALID_LEVEL_FULL,
           x_return_status    => l_return_status,
           x_msg_count        => l_msg_count,
           x_msg_data         => l_msg_data,
           p_visit_id         => l_visit_id);

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_VWP_TIMES_PVT.Calculate_Task_Times - l_return_status : '||l_return_status);
  END IF;

  -- Return ID of the new visit
  p_x_Visit_rec.visit_id := l_visit_id;

  ---------------------------End of API Body---------------------------------------
  --Standard check to count messages
  l_msg_count := Fnd_Msg_Pub.count_msg;

  IF l_msg_count > 0 THEN
     X_msg_count := l_msg_count;
     X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Standard check for commit
  IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
    COMMIT;
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.end','At the end of PLSQL procedure');
  END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Copy_Visit;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Copy_Visit;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Copy_Visit;
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
END Copy_Visit;

--------------------------------------------------------------------
-- PROCEDURE
--    Update_Visit
--
-- PURPOSE
--    To update a Maintainance Visit.
--------------------------------------------------------------------
PROCEDURE Update_Visit (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type       IN  VARCHAR2  := 'JSP',
   p_x_visit_rec       IN  OUT NOCOPY Visit_Rec_Type,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
)
IS
   -- Define local Variables
   L_API_VERSION          CONSTANT NUMBER := 1.0;
   L_API_NAME             CONSTANT VARCHAR2(30) := 'Update_Visit';
   L_FULL_NAME            CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   L_DEBUG                CONSTANT VARCHAR2(90) := 'ahl.plsql.'||L_FULL_NAME;

   l_msg_data             VARCHAR2(2000);
   l_return_status        VARCHAR2(1);
   l_msg_count            NUMBER;

   l_planned_order_flag   VARCHAR2(1);


   l_count                NUMBER;
   l_service_id           NUMBER;
   l_organization_id           NUMBER;
   l_department_id           NUMBER;

   l_visit_end_date       DATE; --The visit end date

   l_date_time_end        DATE;
   l_date_time_start      DATE;

   space_changed_flag     VARCHAR2(1):= 'N';

   -- Post 11.5.10 Enhancements
   l_priority_code         VARCHAR2(30);
   l_proj_template_id      NUMBER;

   -- Define local record datatypes
   l_visit_rec            Visit_Rec_Type := p_x_visit_rec;
   l_workorder_rec         AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_REC;
   l_workoper_tbl          AHL_PRD_WORKORDER_PVT.PRD_WORKOPER_TBL;
   l_Space_Assignment_Rec  ahl_ltp_space_assign_pub.Space_Assignment_Rec;
   --TCHIMIRA::P2P CP ER 9151144::09-DEC-2009
   l_phase_code                VARCHAR2(1);


   -- Define local Cursors
   -- To find visit related information
   -- TCHIMIRA :: Bug 8594339 :: 19-NOV-2009
   -- Modified Cursor to acquire a lock on the visit record without waiting
   CURSOR c_Visit(x_id IN NUMBER) IS
   SELECT * FROM   Ahl_Visits_VL
   WHERE  VISIT_ID = x_id
   FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

   c_Visit_rec    c_Visit%ROWTYPE;

   -- To find all tasks under this current visit related information
   CURSOR c_Task (x_id IN NUMBER) IS
   SELECT * FROM Ahl_Visit_Tasks_VL
   WHERE VISIT_ID = x_id
   and NVL(status_code, 'X') not in('DELETED', 'CANCELLED');

   c_Task_rec    c_Task%ROWTYPE;

   -- To find if WIP job in Draft Status is created for the Visit
   CURSOR c_job(x_id IN NUMBER) IS
   SELECT count(*) FROM AHL_WORKORDERS
   WHERE VISIT_ID = x_id
   AND MASTER_WORKORDER_FLAG = 'Y'
   AND STATUS_CODE = 17;

   CURSOR c_Visit_WO(x_id IN NUMBER) IS
   SELECT * FROM AHL_WORKORDERS
   WHERE VISIT_ID = x_id
   AND MASTER_WORKORDER_FLAG = 'Y'
   AND STATUS_CODE = 17;

   l_workrec c_Visit_WO%ROWTYPE;

   CURSOR c_Task_WO(x_task_id IN NUMBER) IS
   SELECT * FROM AHL_WORKORDERS
   WHERE VISIT_TASK_ID = x_task_id
   AND STATUS_CODE = 17;

   l_task_workrec c_Task_WO%ROWTYPE;

  /*Added by sowsubra*/
  CURSOR c_subinv_validate (p_subinv_code IN VARCHAR2, p_org_id IN VARCHAR2) IS
      SELECT status_id
      FROM mtl_secondary_inventories
      WHERE secondary_inventory_name = p_subinv_code
      AND organization_id = p_org_id;

  /*Added by sowsubra*/
  CURSOR c_loc_validate (p_org_id IN NUMBER, p_subinv_code IN VARCHAR2, p_loc_seg IN VARCHAR2) IS
     -- jaramana on Feb 14, 2008 for bug 6819370
     -- Made segment19 and segment20 refer to base table
     SELECT mil.inventory_location_id
     from mtl_item_locations mil, mtl_item_locations_kfv milk
     where mil.organization_id = p_org_id
     and mil.subinventory_code = p_subinv_code
     and milk.concatenated_segments = p_loc_seg
     and mil.segment19 is NULL
     and mil.segment20 is NULL
     and mil.inventory_location_id = milk.inventory_location_id;

    l_inv_loc_id      NUMBER := 0;
    l_dummy           NUMBER := 0;
    l_status_id       NUMBER;

    --TCHIMIRA::P2P CP ER 9151144::09-DEC-2009
    --Cursor to fetch phase
  CURSOR c_conc_req_phase(c_visit_id IN NUMBER) IS
  SELECT FCR.PHASE_CODE
  FROM FND_CONCURRENT_REQUESTS FCR, AHL_VISITS_B AVB
  WHERE FCR.REQUEST_ID = AVB.REQUEST_ID
  AND AVB.VISIT_ID = c_visit_id;

   -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010
   -- Added this cursor to fetch visit task past dates for non-summary tasks
   Cursor get_visit_task_past_dates (c_visit_id IN NUMBER)
   IS
     SELECT MIN(past_task_start_date) past_task_start_date, MAX(past_task_end_date) past_task_end_date
     FROM ahl_visit_tasks_b
     WHERE visit_id = c_visit_id
     AND task_type_code <> 'SUMMARY'
     AND PAST_TASK_START_DATE IS NOT NULL
     AND STATUS_CODE NOT IN ('DELETED','CANCELLED');
     visit_task_past_dates_rec get_visit_task_past_dates%ROWTYPE;



BEGIN

  --------------------- Initialize -----------------------
  SAVEPOINT Update_Visit;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.begin','At the start of PLSQL procedure - Visit Id - '||l_visit_rec.visit_id ||'p_module_tyoe - '|| p_module_type);
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF Fnd_Api.to_boolean(p_init_msg_list) THEN
     Fnd_Msg_Pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  -- Standard call to check for call compatibility.
  IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
  THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ------------------------Start of API Body------------------------------------
  OPEN c_Visit(l_Visit_rec.visit_id);
  FETCH c_Visit INTO c_Visit_rec;
  IF c_Visit%NOTFOUND THEN
     CLOSE c_Visit;
     IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
        Fnd_Message.set_name('AHL', 'AHL_API_RECORD_NOT_FOUND');
        Fnd_Msg_Pub.ADD;
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement,L_DEBUG,'Visit not found for' ||l_visit_rec.visit_id );
        END IF;
     END IF;
     RAISE Fnd_Api.g_exc_error;
  ELSE
      CLOSE c_Visit;
  END IF;

  --TCHIMIRA::P2P CP ER 9151144::09-DEC-2009::BEGIN
  OPEN c_conc_req_phase(l_Visit_rec.visit_id);
  FETCH c_conc_req_phase INTO l_phase_code;
  CLOSE c_conc_req_phase;

  IF(l_phase_code IN('R' , 'P')) THEN
     FND_MESSAGE.Set_Name('AHL','AHL_VWP_CP_P2P_IN_PROGS');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  --TCHIMIRA::P2P CP ER 9151144::09-DEC-2009::END


  -- To validate Object version number.
  IF (c_visit_rec.object_version_number <> l_visit_rec.object_version_number) THEN
     Fnd_Message.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
     Fnd_Msg_Pub.ADD;
     RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --------------------Value OR ID conversion---------------------------
  -- Commented for TC changes by Senthil
  -- Uncommented by yazhou
  IF p_module_type = 'JSP' THEN
    l_Visit_rec.organization_id    := NULL;
    l_Visit_rec.department_id      := NULL;
    l_Visit_rec.item_instance_id   := NULL;
    l_Visit_rec.service_request_id := NULL;
    l_visit_rec.proj_template_id   := NULL;

    IF l_Visit_rec.START_DATE IS NOT NULL AND l_Visit_rec.START_DATE <> fnd_api.g_miss_date THEN
       l_date_time_start := TO_DATE(TO_CHAR(l_visit_rec.START_DATE, 'DD-MM-YYYY ') ||
                            TO_CHAR(NVL(l_visit_rec.START_HOUR,'00')) || ':'||TO_CHAR(NVL(l_visit_rec.START_MIN,'00')),'DD-MM-YYYY HH24:MI');
    ELSE
       l_Visit_rec.START_DATE:= null;
       l_visit_rec.START_HOUR:= null;
       l_date_time_start := null;
    END IF;

    IF l_Visit_rec.PLAN_END_DATE IS NOT NULL AND l_Visit_rec.PLAN_END_DATE <> fnd_api.g_miss_date THEN
       l_date_time_end := TO_DATE(TO_CHAR(l_visit_rec.PLAN_END_DATE, 'DD-MM-YYYY ') ||
                            TO_CHAR(NVL(l_visit_rec.PLAN_END_HOUR,'00')) || ':'|| TO_CHAR(NVL(l_visit_rec.PLAN_END_MIN,'00')) ,'DD-MM-YYYY HH24:MI');
    ELSE
       l_Visit_rec.PLAN_END_DATE:= null;
       l_visit_rec.PLAN_END_HOUR:= null;
       l_date_time_end :=null;
    END IF;
  ELSE
    IF l_Visit_rec.START_DATE IS NOT NULL AND l_Visit_rec.START_DATE <> fnd_api.g_miss_date THEN
        l_date_time_start := l_visit_rec.START_DATE;
    ELSE
        l_Visit_rec.START_DATE:= null;
        l_date_time_start := null;
    END IF;

    IF l_Visit_rec.PLAN_END_DATE IS NOT NULL AND l_Visit_rec.PLAN_END_DATE <> fnd_api.g_miss_date THEN
        l_date_time_end := l_visit_rec.PLAN_END_DATE;
    ELSE
        l_Visit_rec.START_DATE:= null;
        l_date_time_end := null;
    END IF;
  END IF;

  -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: STARTS
  -- Validate that the visit past task start and end dates are withing the visit start and planned end date
  OPEN get_visit_task_past_dates(l_Visit_rec.visit_id);
  FETCH get_visit_task_past_dates INTO visit_task_past_dates_rec;
  CLOSE get_visit_task_past_dates;

  IF l_date_time_start IS NOT NULL THEN
    IF visit_task_past_dates_rec.past_task_start_date < l_date_time_start THEN
      Fnd_Message.SET_NAME('AHL','AHL_VWP_VISIT_START_DATE_INVLD');
      Fnd_Msg_Pub.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;
  IF l_date_time_end IS NOT NULL THEN
    IF visit_task_past_dates_rec.past_task_end_date > l_date_time_end THEN
      Fnd_Message.SET_NAME('AHL','AHL_VWP_VISIT_END_DATE_INVLD');
      Fnd_Msg_Pub.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;
  -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: END

  -------------------- UPDATE FOR VISIT ----------------
  -- Transit Visit change
  -- yazhou start
  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,L_DEBUG,'Status Code = ' || l_Visit_rec.status_code);
  END IF;

  -- not allowed to update if status code is not planning, released or partially released.
  IF c_visit_rec.status_code NOT IN ('PLANNING','RELEASED', 'PARTIALLY RELEASED') THEN
    Fnd_Message.SET_NAME('AHL','AHL_VWP_INVALID_STATUS_NO_EDIT');
    Fnd_Msg_Pub.ADD;
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

  -- Process fields that are only updateable when visit is in Planning status
  IF c_visit_rec.status_code = 'PLANNING' THEN
    ----- Dropdowns on Update Visit UI Screen-------------
    -- For SPACE CATEGORY CODE
    IF l_Visit_rec.space_category_code = Fnd_Api.G_MISS_CHAR THEN
        l_Visit_rec.space_category_code := Null;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'Space Category Code = ' || l_Visit_rec.space_category_code);
    END IF;

    ----------- LOVs on Update Visit UI Screen---
    -- For VISIT TYPE
    -- To find Visit Type Code when Visit Type Name has input values
    IF  l_Visit_rec.visit_type_name IS NOT NULL AND l_Visit_rec.visit_type_name <> Fnd_Api.G_MISS_CHAR THEN
        AHL_VWP_RULES_PVT.Check_Lookup_Name_Or_Id
            ( p_lookup_type  => 'AHL_PLANNING_VISIT_TYPE',
              p_lookup_code  => NULL,
              p_meaning      => l_Visit_rec.visit_type_name,
              p_check_id_flag => 'Y',
              x_lookup_code   => l_Visit_rec.visit_type_code,
              x_return_status => l_return_status
            );

        IF NVL(l_return_status, 'X') <> 'S' THEN
            Fnd_Message.SET_NAME('AHL','AHL_VWP_TYPE_CODE_NOT_EXISTS');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'Visit Type' || l_Visit_rec.visit_type_name || '-' || l_Visit_rec.visit_type_code);
    END IF;

    -- For SERVICE REQUEST
    -- To Convert Service Request Number to Service Request Id
    IF (l_Visit_rec.service_request_number IS NOT NULL AND
        l_Visit_rec.service_request_number <> Fnd_Api.G_MISS_CHAR ) THEN

        AHL_VWP_RULES_PVT.Check_SR_Request_Number_Or_Id
            (   p_service_id       => l_Visit_rec.service_request_id,
                p_service_number   => l_Visit_rec.service_request_number,
                x_service_id       => l_service_id,
                x_return_status    => l_return_status,
                x_error_msg_code   => l_msg_data);

        IF NVL(l_return_status,'x') <> 'S' THEN
            Fnd_Message.SET_NAME('AHL','AHL_VWP_SERVICE_REQ_NOT_EXISTS');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.g_exc_error;
        END IF;

        --Assign the returned value
        l_Visit_rec.service_request_id := l_service_id;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement,L_DEBUG,'SR Id/Number = ' || l_Visit_rec.service_request_id || '-' || l_Visit_rec.service_request_number );
        END IF;
    END IF;
    ----------- End defining and validate all LOVs on Update Visit UI Screen---
    -- For Priority
    -- To Convert Priority Value to Code
    IF l_Visit_rec.priority_value IS NOT NULL AND l_Visit_rec.priority_value <> Fnd_Api.G_MISS_CHAR       THEN
       AHL_VWP_RULES_PVT.Check_Lookup_Name_Or_Id
              (p_lookup_type  => 'AHL_VWP_VISIT_PRIORITY',
               p_lookup_code  => l_Visit_rec.priority_code,
               p_meaning      => l_Visit_rec.priority_value,
               p_check_id_flag => 'Y',
               x_lookup_code   => l_priority_code,
               x_return_status => l_return_status);

       IF NVL(l_return_status, 'X') <> 'S' THEN
          Fnd_Message.SET_NAME('AHL','AHL_VWP_PRI_NOT_EXISTS');
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.G_EXC_ERROR;
       END IF;
       l_visit_rec.priority_code := l_priority_code;
    END IF;

    -- For Organization
    -- To Convert Organization Name to ID
    IF (l_visit_rec.ORG_NAME IS NOT NULL AND l_visit_rec.ORG_NAME <> Fnd_Api.G_MISS_CHAR ) OR
       (l_visit_rec.organization_id IS NOT NULL AND l_visit_rec.organization_id <> Fnd_Api.G_MISS_NUM )
        THEN
            AHL_VWP_RULES_PVT.Check_Org_Name_Or_Id
                  (p_organization_id  => l_visit_rec.organization_id,
                   p_org_name         => l_visit_rec.ORG_NAME,
                   x_organization_id  => l_organization_id,
                   x_return_status    => l_return_status,
                   x_error_msg_code   => l_msg_data);

            IF NVL(l_return_status,'x') <> 'S' THEN
                Fnd_Message.SET_NAME('AHL','AHL_VWP_ORG_NOT_EXISTS');
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            l_visit_rec.organization_id := l_organization_id;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(fnd_log.level_statement,L_DEBUG,'Organization ID' || l_visit_rec.organization_id);
            END IF;
    END IF;

    IF l_visit_rec.organization_id IS NULL OR l_visit_rec.organization_id = Fnd_Api.G_MISS_NUM THEN
      --Assign the department to Null if organization id is null
      l_visit_rec.department_id := NULL;
      l_visit_rec.organization_id:= NULL;
    ELSE
      IF (l_visit_rec.DEPT_NAME IS NOT NULL AND l_visit_rec.DEPT_NAME <> Fnd_Api.G_MISS_CHAR )OR
         (l_visit_rec.department_id IS NOT NULL AND l_visit_rec.department_id <> Fnd_Api.G_MISS_NUM )
         THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(fnd_log.level_statement,L_DEBUG,'Inside Dept Name/ID - '||l_visit_rec.DEPT_NAME ||' - '||l_visit_rec.department_id );
            END IF;

            AHL_VWP_RULES_PVT.Check_Dept_Desc_Or_Id
                    (   p_organization_id  => l_visit_rec.organization_id,
                        p_dept_name        => l_visit_rec.DEPT_NAME,
                        p_department_id    => l_visit_rec.department_id,
                        x_department_id    => l_department_id,
                        x_return_status    => l_return_status,
                        x_error_msg_code   => l_msg_data);

            IF NVL(l_return_status,'x') <> 'S' THEN
              Fnd_Message.SET_NAME('AHL','AHL_VWP_DEPT_NOT_EXISTS');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            l_visit_rec.department_id := l_department_id;
            AHL_VWP_RULES_PVT.CHECK_DEPARTMENT_SHIFT
                   (p_dept_id          => l_visit_rec.department_id,
                    x_return_status    => l_return_status);

            IF NVL(l_return_status,'x') <> 'S' THEN
                Fnd_Message.SET_NAME('AHL','AHL_VWP_NO_DEPT_SHIFT');
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(fnd_log.level_statement,L_DEBUG,'Department ID' || l_visit_rec.department_id);
            END IF;
      ELSE
          l_visit_rec.department_id := NULL;
      END IF ;  --Dept Not Null
    END IF ;  --Org Not Null

    -- For Project Template
    -- To Convert Project Template Name to ID
    IF l_visit_rec.proj_template_name IS NOT NULL THEN
        AHL_VWP_RULES_PVT.Check_Project_Template_Or_Id
                ( p_proj_temp_name => l_visit_rec.proj_template_name,
                  x_project_id => l_proj_template_id,
                  x_return_status => l_return_status,
                  x_error_msg_code => l_msg_data);

        IF NVL(l_return_status, 'X') <> 'S' THEN
            Fnd_Message.SET_NAME('AHL','AHL_VWP_INVALID_PROTEMP');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
    ELSE
        -- If Project Template Name is null
        -- then use the profile value
        l_proj_template_id := FND_PROFILE.VALUE('AHL_DEFAULT_PA_TEMPLATE_ID');
    END IF;

    IF (l_proj_template_id <> c_visit_rec.project_template_id) AND (c_visit_rec.project_id IS NOT NULL) THEN
        -- Project Template cannot be updated if Project has been created for Visit
        Fnd_Message.SET_NAME('AHL','AHL_VWP_PROJ_CRTD');
        Fnd_Msg_Pub.ADD;
        RAISE Fnd_Api.G_EXC_ERROR;
    ELSE
        l_visit_rec.proj_template_id := l_proj_template_id;
    END IF;

  /*BB5854712 - sowsubra - starts*/
  l_dummy := NULL;

  IF ((l_visit_rec.subinventory IS NOT NULL) AND (l_visit_rec.locator_segment IS NULL)) THEN
           Fnd_Message.SET_NAME('AHL','AHL_VWP_LOCATOR_NULL');
           Fnd_Msg_Pub.ADD;
           RAISE Fnd_Api.G_EXC_ERROR;
  ELSIF ((l_visit_rec.subinventory IS NULL) AND (l_visit_rec.locator_segment IS NOT NULL))THEN
           Fnd_Message.SET_NAME('AHL','AHL_VWP_SUBINVENTORY_NULL');
           Fnd_Msg_Pub.ADD;
           RAISE Fnd_Api.G_EXC_ERROR;
  ELSIF ((l_visit_rec.subinventory IS NOT NULL) AND (l_visit_rec.locator_segment IS NOT NULL)) THEN

         OPEN c_subinv_validate (l_visit_rec.subinventory, l_visit_rec.organization_id);
         FETCH c_subinv_validate INTO l_status_id;
         IF c_subinv_validate%NOTFOUND THEN
             CLOSE c_subinv_validate;
             Fnd_Message.SET_NAME('AHL','AHL_VWP_SUBINV_NOT_EXISTS');
             Fnd_Msg_Pub.ADD;
             RAISE Fnd_Api.G_EXC_ERROR;
         ELSE
           IF l_status_id in (NVL(fnd_profile.value('AHL_MTL_MAT_STATUS_UNSERVICABLE'), -1), NVL(fnd_profile.value('AHL_MTL_MAT_STATUS_MRB'), -1)) THEN
             CLOSE c_subinv_validate;
             FND_MESSAGE.SET_NAME('AHL', 'AHL_SUBINVENTORY_NOT_SVC');
             FND_MESSAGE.Set_Token('INV', l_visit_rec.subinventory);
             FND_MSG_PUB.ADD;
             RAISE Fnd_Api.G_EXC_ERROR;
           END IF;
         END IF;
         CLOSE c_subinv_validate;

         l_dummy := NULL;

         OPEN c_loc_validate (l_visit_rec.organization_id, l_visit_rec.subinventory,l_visit_rec.locator_segment );
         FETCH c_loc_validate INTO l_inv_loc_id;
          IF c_loc_validate%NOTFOUND THEN
             Fnd_Message.SET_NAME('AHL','AHL_VWP_PHY_LOCATOR_NOT_EXISTS');
             Fnd_Msg_Pub.ADD;
             CLOSE c_loc_validate;
             RAISE Fnd_Api.G_EXC_ERROR;
          END IF;
         CLOSE c_loc_validate;

         l_visit_rec.inv_locator_id := l_inv_loc_id;

  ELSE
    l_visit_rec.inv_locator_id := null;
  END IF;
  /*BB5854712 - sowsubra - ends*/

  ELSE  -- Visit in Released or Partially Released Status
    l_visit_rec.proj_template_id := c_visit_rec.project_template_id;
    l_visit_rec.priority_code := c_visit_rec.priority_code;
    l_Visit_rec.VISIT_TYPE_CODE :=c_Visit_rec.VISIT_TYPE_CODE;
    l_Visit_rec.SERVICE_REQUEST_ID := c_Visit_rec.SERVICE_REQUEST_ID;
    l_Visit_rec.VISIT_NAME := c_Visit_rec.VISIT_NAME;
    l_Visit_rec.DESCRIPTION  :=   c_Visit_rec.DESCRIPTION;
    l_Visit_rec.ORGANIZATION_ID := c_Visit_rec.ORGANIZATION_ID;
    --Added by tchimira for Bug# 9526695 on 30-MAR-2010
    l_Visit_rec.INV_LOCATOR_ID := c_Visit_rec.INV_LOCATOR_ID;
    -------- R12 changes For Serial Number Reservations Start------------
    -------- AnRaj added condition on 17th June 2005 ------------
    IF p_module_type = 'JSP' THEN
        l_Visit_rec.DEPARTMENT_ID  :=   c_Visit_rec.DEPARTMENT_ID;
    END IF;
    -------- R12 changes For Serial Number Reservations End---------------
  END IF; -- Visit in Planning Status

  -- For Planned Start/End Date
  --- Planned start/end dates are madatory for transit visit
  --- AnRaj added
  --- Planned Start/End Dates are mandatory for visits which are in status Released/Partially Released
  --- as per the updates by Jay and Yan in the CMRO Forum, issue number 169
  IF c_visit_rec.status_code  IN ('RELEASED', 'PARTIALLY RELEASED') THEN
    IF  l_date_time_start IS NULL THEN
      Fnd_Message.SET_NAME('AHL','AHL_VWP_ST_DT_REQ');
      Fnd_Msg_Pub.ADD;
      RAISE FND_Api.G_EXC_ERROR;
    END IF;

    IF  l_date_time_end IS NULL THEN
      Fnd_Message.SET_NAME('AHL','AHL_VWP_END_DT_REQ');
      Fnd_Msg_Pub.ADD;
      RAISE FND_Api.G_EXC_ERROR;
    END IF;
  END IF;

  IF c_Visit_rec.unit_schedule_id IS NOT NULL AND  c_Visit_rec.unit_schedule_id <> FND_API.G_MISS_NUM
  THEN
    -- Planned Start Date is madatory for transit visit
    IF l_date_time_start IS NULL THEN
       Fnd_Message.SET_NAME('AHL','AHL_VWP_TC_ST_DT_REQ');
       Fnd_Msg_Pub.ADD;
       RAISE FND_Api.G_EXC_ERROR;
    END IF;

    -- Planned End Date is madatory for transit visit
    IF l_date_time_end IS NULL THEN
        Fnd_Message.SET_NAME('AHL','AHL_VWP_TC_END_DT_REQ');
        Fnd_Msg_Pub.ADD;
        RAISE FND_Api.G_EXC_ERROR;
    END IF;
  END IF;

  -- To validate visit start date should be less than plan end date
  IF l_date_time_end IS NOT NULL  AND l_date_time_start IS NOT NULL THEN
    IF (l_date_time_start > l_date_time_end) THEN
        Fnd_Message.SET_NAME('AHL','AHL_VWP_START_DT_GTR_CLOSE_DT');
        Fnd_Msg_Pub.ADD;
        RAISE Fnd_Api.G_EXC_ERROR;
    END IF;
  END IF;
  l_visit_rec.STATUS_CODE :=  c_Visit_rec.STATUS_CODE;

  -- If Visit dates are changed for a visit in released status
  -- then visit status needs to be changed to Partially Released
  IF NVL(TO_CHAR(l_date_time_start,'DD-MM-YYYY HH24:MI'),'XXX') <>    NVL(TO_CHAR(c_Visit_rec.START_DATE_TIME,'DD-MM-YYYY HH24:MI'),'XXX')
  OR NVL(TO_CHAR(l_date_time_end,'DD-MM-YYYY HH24:MI'),'XXX') <> NVL(TO_CHAR(c_Visit_rec.CLOSE_DATE_TIME,'DD-MM-YYYY HH24:MI'),'XXX') THEN
    IF c_Visit_rec.STATUS_CODE = 'RELEASED' THEN
        l_visit_rec.STATUS_CODE := 'PARTIALLY RELEASED';
    END IF;
  END IF;

  -- For all optional fields check if its g_miss_num/g_miss_char/g_miss_date
  -- then Null else the value call Default_Missing_Attribs procedure
  Default_Missing_Attribs
        (
          p_x_visit_rec             => l_Visit_rec
        );
  ----------------------- Validate ----------------------
  IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_item THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling Check_Visit_Items');
      END IF;

      Check_Visit_Items (
             p_Visit_rec          => l_visit_rec,
             p_validation_mode    => Jtf_Plsql_Api.g_update,
             x_return_status      => l_return_status
          );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling Check_Visit_Items : l_return_status - '|| l_return_status);
      END IF;

      IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
      END IF;
  END IF;

  -- if organization is changed, then reset all the task department and space changed flag
  -- and cancel all the workorders in production
  IF (NVL(l_visit_rec.organization_id,-777) <> NVL(c_visit_rec.organization_id,-777)) THEN
    -- To set department_id to NULL in case if the visit's organization is changed
    OPEN c_task(l_visit_rec.visit_id);
    LOOP
      FETCH c_task INTO c_task_rec;
      EXIT WHEN c_task%NOTFOUND;
      -- Tasks found for visit
      -- To update department_id to NULL when visit's organization is changed
      UPDATE AHL_VISIT_TASKS_B
      SET DEPARTMENT_ID = NULL,
          OBJECT_VERSION_NUMBER = c_task_rec.object_version_number + 1
      WHERE VISIT_TASK_ID = c_task_rec.visit_task_id
      AND DEPARTMENT_ID IS NOT NULL;
    END LOOP;
    CLOSE c_task;

    SPACE_CHANGED_FLAG := 'Y';
    -- To find out if visit has workorder in production store this info in rec type
    OPEN c_Visit_WO (l_visit_rec.visit_id);
    FETCH c_visit_WO INTO l_workrec;
    IF c_visit_WO%FOUND THEN
      CLOSE c_visit_WO;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_PRD_WORKORDER_PVT.cancel_visit_jobs');
      END IF;

      AHL_PRD_WORKORDER_PVT.cancel_visit_jobs
                   (p_api_version      => 1.0,
                    p_init_msg_list    => FND_API.G_TRUE,
                    p_commit           => FND_API.G_FALSE,
                    p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                    p_default          => FND_API.G_FALSE,
                    p_module_type      => NULL,
                    x_return_status    => l_return_status,
                    x_msg_count        => l_msg_count,
                    x_msg_data         => l_msg_data,
                    p_visit_id         => l_Visit_rec.visit_id,
                    p_unit_effectivity_id => NULL,
                    p_workorder_id        => NULL);

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_PRD_WORKORDER_PVT.cancel_visit_jobs - l_return_status : '||l_return_status);
      END IF;

      IF l_return_status <> 'S' THEN
        RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
    ELSE
      CLOSE c_visit_WO;
    END IF;
  END IF;

  -- if department is changed, then set space changed flag
  --All the wip jobs for this visit to be updated with new department and start/end time;
  IF space_changed_flag <> 'Y' THEN
    IF (NVL(l_visit_rec.department_id,-777) <> NVL(c_visit_rec.department_id,-777)) THEN
        space_changed_flag := 'Y';
        -- cancel all the workorders for the visit if visit department is cleared up.
        IF l_visit_rec.department_id is null and c_visit_rec.department_id is not null THEN
            OPEN c_Visit_WO (l_visit_rec.visit_id);
            FETCH c_visit_WO INTO l_workrec;
            IF c_visit_WO%found THEN
                close c_visit_WO;

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                  fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_PRD_WORKORDER_PVT.cancel_visit_jobs');
                END IF;

                AHL_PRD_WORKORDER_PVT.cancel_visit_jobs
                                 (p_api_version      => 1.0,
                                  p_init_msg_list    => FND_API.G_TRUE,
                                  p_commit           => FND_API.G_FALSE,
                                  p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                                  p_default          => FND_API.G_FALSE,
                                  p_module_type      => NULL,
                                  x_return_status    => l_return_status,
                                  x_msg_count        => l_msg_count,
                                  x_msg_data         => l_msg_data,
                                  p_visit_id         => l_Visit_rec.visit_id,
                                  p_unit_effectivity_id => NULL,
                                  p_workorder_id        => NULL);

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                  fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_PRD_WORKORDER_PVT.cancel_visit_jobs - l_return_status : '||l_return_status);
                END IF;

                IF l_return_status <> 'S' THEN
                  RAISE Fnd_Api.G_EXC_ERROR;
                END IF;
            ELSE
              close c_visit_WO;
            END IF;
        ELSIF l_visit_rec.department_id is not null
        and c_visit_rec.department_id is not null
        and l_visit_rec.department_id <>c_visit_rec.department_id THEN

            l_visit_end_date:= AHL_VWP_TIMES_PVT.get_visit_end_time(l_visit_rec.visit_id);
            -- To find out if visit has workorder in production store this info in rec type
            OPEN c_Visit_WO (l_visit_rec.visit_id);
            FETCH c_visit_WO INTO l_workrec;

            IF c_visit_WO%found THEN
              l_workorder_rec.WORKORDER_ID              := l_workrec.workorder_id;
              l_workorder_rec.OBJECT_VERSION_NUMBER     := l_workrec.object_version_number;
              l_workorder_rec.DEPARTMENT_ID             := l_visit_rec.department_id;
--            l_workorder_rec.SCHEDULED_START_DATE      := l_date_time_start;
--            l_workorder_rec.SCHEDULED_END_DATE        := l_visit_end_date;

              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string(fnd_log.level_statement,L_DEBUG,'VISIT - Before calling AHL_PRD_WORKORDER_PVT.update_job API');
              END IF;

              AHL_PRD_WORKORDER_PVT.update_job
                     (  p_api_version          =>1.0,
                        p_init_msg_list        =>fnd_api.g_false,
                        p_commit               =>fnd_api.g_false,
                        p_validation_level     =>p_validation_level,
                        p_default              =>fnd_api.g_false,
                        p_module_type          =>'API',
                        x_return_status        =>l_return_status,
                        x_msg_count            =>x_msg_count,
                        x_msg_data             =>x_msg_data,
                        p_wip_load_flag        =>'Y',
                        p_x_prd_workorder_rec  =>l_workorder_rec,
                        P_X_PRD_WORKOPER_TBL   =>l_workoper_tbl
                        );

              IF l_return_status <> 'S' THEN
                CLOSE c_visit_WO;
                RAISE Fnd_Api.G_EXC_ERROR;
              END IF;

              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string(fnd_log.level_statement,L_DEBUG,'VISIT - After calling AHL_PRD_WORKORDER_PVT.update_job API - l_return_status : '||l_return_status);
              END IF;
            END IF; -- End of visit workorder found
            CLOSE c_visit_WO;

            -- To find all tasks for the visit so as to update task start and end datetime
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string(fnd_log.level_statement,L_DEBUG,'TASK - To update task start and end date time');
            END IF;

            OPEN c_task(l_visit_rec.visit_id);
            LOOP
              FETCH c_task INTO c_task_rec;
              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                  fnd_log.string(fnd_log.level_statement,L_DEBUG,'TASK - ID = ' || c_task_rec.visit_task_id);
              END IF;

              -- Update workorder for the task only if task is using visit department
              IF c_task_rec.department_id is null OR c_task_rec.department_id = FND_API.g_miss_num THEN
                OPEN  c_Task_WO(c_task_rec.visit_task_id);
                FETCH c_Task_WO into l_task_workrec;

                IF c_Task_WO%found THEN
                  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                      fnd_log.string(fnd_log.level_statement,L_DEBUG,'TASK - Workorder found ');
                  END IF;
                  --Update with new times from table
                  --l_workorder_rec.SCHEDULED_START_DATE  := c_task_rec.START_DATE_TIME;
                  --l_workorder_rec.SCHEDULED_END_DATE    := c_task_rec.END_DATE_TIME;
                  l_workorder_rec.DEPARTMENT_ID             := l_visit_rec.department_id;
                  l_workorder_rec.WORKORDER_ID              := l_task_workrec.workorder_id;
                  l_workorder_rec.OBJECT_VERSION_NUMBER     := l_task_workrec.object_version_number;

                  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                      fnd_log.string(fnd_log.level_statement,L_DEBUG,'TASK - Workorder Id = ' || l_workorder_rec.WORKORDER_ID);
                      fnd_log.string(fnd_log.level_statement,L_DEBUG,'TASK - Before calling AHL_PRD_WORKORDER_PVT.update_job');
                  END IF;

                  AHL_PRD_WORKORDER_PVT.update_job
                          (   p_api_version          =>1.0,
                              p_init_msg_list        =>fnd_api.g_false,
                              p_commit               =>fnd_api.g_false,
                              p_validation_level     =>p_validation_level,
                              p_default              =>fnd_api.g_false,
                              p_module_type          =>'API',
                              x_return_status        =>l_return_status,
                              x_msg_count            =>x_msg_count,
                              x_msg_data             =>x_msg_data,
                              p_wip_load_flag        =>'Y',
                              p_x_prd_workorder_rec  =>l_workorder_rec,
                              P_X_PRD_WORKOPER_TBL   =>l_workoper_tbl
                          );

                  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                      fnd_log.string(fnd_log.level_statement,L_DEBUG,'TASK - After calling AHL_PRD_WORKORDER_PVT.update_job - l_return_status : '||l_return_status);
                  END IF;

                  IF l_return_status <> 'S' THEN
                     CLOSE c_Task_WO;
                     CLOSE c_task;
                     RAISE Fnd_Api.G_EXC_ERROR;
                  END IF;
                END IF;
                CLOSE c_Task_WO;
              END IF;
              EXIT WHEN c_task%NOTFOUND;
            END LOOP;
            CLOSE c_task;
          END IF;
       END IF;
    END IF;

    -- if start date (hour change is not considered) is changed, then set space changed flag
    IF space_changed_flag <> 'Y' THEN
       IF NVL(TO_CHAR(l_date_time_start,'DD-MM-YYYY'),'XXX') <> NVL(TO_CHAR(c_Visit_rec.START_DATE_TIME,'DD-MM-YYYY'),'XXX') THEN
             space_changed_flag := 'Y';

       END IF;
    END IF;
    -------------------------- Update --------------------
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling Ahl_Visits_Pkg.UPDATE_ROW');
    END IF;

    Ahl_Visits_Pkg.UPDATE_ROW (
             X_VISIT_ID              => l_Visit_rec.VISIT_ID,
             X_VISIT_NUMBER          => c_visit_rec.VISIT_NUMBER,
             X_VISIT_TYPE_CODE       => l_Visit_rec.VISIT_TYPE_CODE,
             X_SIMULATION_PLAN_ID    => c_Visit_rec.SIMULATION_PLAN_ID,
             X_ITEM_INSTANCE_ID      => c_Visit_rec.ITEM_INSTANCE_ID,
             X_ITEM_ORGANIZATION_ID  => c_Visit_rec.ITEM_ORGANIZATION_ID,
             X_INVENTORY_ITEM_ID     => c_Visit_rec.INVENTORY_ITEM_ID,
             X_ASSO_PRIMARY_VISIT_ID => c_Visit_rec.ASSO_PRIMARY_VISIT_ID,
             X_SIMULATION_DELETE_FLAG => c_Visit_rec.SIMULATION_DELETE_FLAG,
             X_TEMPLATE_FLAG         => c_Visit_rec.TEMPLATE_FLAG,
             X_OUT_OF_SYNC_FLAG      => c_Visit_rec.OUT_OF_SYNC_FLAG,
             X_PROJECT_FLAG          => 'Y',
             X_PROJECT_ID            => c_Visit_rec.PROJECT_ID,
             X_SERVICE_REQUEST_ID    => l_Visit_rec.SERVICE_REQUEST_ID,
             X_SPACE_CATEGORY_CODE   => l_Visit_rec.SPACE_CATEGORY_CODE,
             X_SCHEDULE_DESIGNATOR   => c_Visit_rec.SCHEDULE_DESIGNATOR,
          -- manisaga chnaged the record from c_Visit_rec to l_Visit_rec
	  -- for dff implementation on 22-Feb-2010  -- Start
             X_ATTRIBUTE_CATEGORY    => l_Visit_rec.ATTRIBUTE_CATEGORY,
             X_ATTRIBUTE1            => l_Visit_rec.ATTRIBUTE1,
             X_ATTRIBUTE2            => l_Visit_rec.ATTRIBUTE2,
             X_ATTRIBUTE3            => l_Visit_rec.ATTRIBUTE3,
             X_ATTRIBUTE4            => l_Visit_rec.ATTRIBUTE4,
             X_ATTRIBUTE5            => l_Visit_rec.ATTRIBUTE5,
             X_ATTRIBUTE6            => l_Visit_rec.ATTRIBUTE6,
             X_ATTRIBUTE7            => l_Visit_rec.ATTRIBUTE7,
             X_ATTRIBUTE8            => l_Visit_rec.ATTRIBUTE8,
             X_ATTRIBUTE9            => l_Visit_rec.ATTRIBUTE9,
             X_ATTRIBUTE10           => l_Visit_rec.ATTRIBUTE10,
             X_ATTRIBUTE11           => l_Visit_rec.ATTRIBUTE11,
             X_ATTRIBUTE12           => l_Visit_rec.ATTRIBUTE12,
             X_ATTRIBUTE13           => l_Visit_rec.ATTRIBUTE13,
             X_ATTRIBUTE14           => l_Visit_rec.ATTRIBUTE14,
             X_ATTRIBUTE15           => l_Visit_rec.ATTRIBUTE15,
	  -- manisaga chnaged the record from c_Visit_rec to l_Visit_rec
	  -- for dff implementation on 22-Feb-2010  -- End
             X_OBJECT_VERSION_NUMBER => l_Visit_rec.OBJECT_VERSION_NUMBER + 1,
             X_ORGANIZATION_ID       => l_Visit_rec.ORGANIZATION_ID,
             X_DEPARTMENT_ID         => l_Visit_rec.DEPARTMENT_ID,
             X_STATUS_CODE           => l_Visit_rec.STATUS_CODE,
             X_START_DATE_TIME       => l_date_time_start,
             X_CLOSE_DATE_TIME       => l_date_time_end,
             X_PRICE_LIST_ID         => c_Visit_rec.PRICE_LIST_ID,
             X_ESTIMATED_PRICE       => c_Visit_rec.ESTIMATED_PRICE,
             X_ACTUAL_PRICE          => c_Visit_rec.ACTUAL_PRICE,
             X_OUTSIDE_PARTY_FLAG    => c_Visit_rec.OUTSIDE_PARTY_FLAG,
             X_ANY_TASK_CHG_FLAG     => c_Visit_rec.ANY_TASK_CHG_FLAG,
             X_VISIT_NAME            => l_Visit_rec.VISIT_NAME,
             X_DESCRIPTION           => l_Visit_rec.DESCRIPTION,
             X_PRIORITY_CODE         => l_visit_rec.PRIORITY_CODE,
             X_PROJECT_TEMPLATE_ID   => l_visit_rec.PROJ_TEMPLATE_ID,
             X_LAST_UPDATE_DATE      => SYSDATE,
             X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
             X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID,
             X_UNIT_SCHEDULE_ID      => c_Visit_rec.unit_schedule_id,
             X_INV_LOCATOR_ID        => l_visit_rec.INV_LOCATOR_ID --Added by sowsubra
             );

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling Ahl_Visits_Pkg.UPDATE_ROW');
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_VWP_TIMES_PVT.Calculate_Task_Times');
    END IF;

    -- Added cxcheng POST11510--------------
    AHL_VWP_TIMES_PVT.Calculate_Task_Times
        ( p_api_version     => 1.0,
          p_init_msg_list   => Fnd_Api.G_FALSE,
          p_commit          => Fnd_Api.G_FALSE,
          p_validation_level=> Fnd_Api.G_VALID_LEVEL_FULL,
          x_return_status   => l_return_status,
          x_msg_count       => l_msg_count,
          x_msg_data        => l_msg_data,
          p_visit_id        => l_visit_rec.visit_id);

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_VWP_TIMES_PVT.Calculate_Task_Times - l_return_status : '||l_return_status);
    END IF;

    IF l_return_status <> 'S' THEN
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    -- To call LTP process to delete or adjust space assignments if space changed flag is set to "Y"
    IF space_changed_flag = 'Y' THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_LTP_SPACE_ASSIGN_PVT.Delete_Space_assignment');
        END IF;

        l_Space_Assignment_Rec.VISIT_ID := l_Visit_rec.VISIT_ID;
        AHL_LTP_SPACE_ASSIGN_PVT.Delete_Space_assignment
            (   p_api_version             => 1.0,
                p_init_msg_list           => FND_API.g_false,
                p_commit                  => FND_API.g_false,
                p_validation_level        => FND_API.g_valid_level_full,
                p_space_assign_rec        => l_Space_Assignment_Rec,
                x_return_status           => l_return_status,
                x_msg_count               => x_msg_count,
                x_msg_data                => x_msg_data
            );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_LTP_SPACE_ASSIGN_PVT.Delete_Space_assignment - l_return_status : '||l_return_status);
        END IF;

        IF l_return_status <> 'S' THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;
    END IF;

    -- If Visit DEPARTMENT or ORGANIZATION or Start Date is changed after price/cost is estimated,
    -- the prices associated to Visit and all the Tasks in the visit will be cleared up
    If space_changed_flag = 'Y' THEN
      OPEN c_job(l_Visit_rec.visit_id);
      FETCH c_job INTO l_count;
      CLOSE c_job;

      IF l_count <> 0 THEN
        -- To update visit's prices
        UPDATE AHL_VISITS_B
        SET ACTUAL_PRICE = NULL,
            ESTIMATED_PRICE = NULL,
            OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
        WHERE VISIT_ID = l_Visit_rec.visit_id;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG,'After updating actual and estimated price for the visit');
        END IF;

        -- To update all tasks prices of tasks under this visit
        OPEN c_task(l_visit_rec.visit_id);
        LOOP
            FETCH c_task INTO c_task_rec;
            EXIT WHEN c_task%NOTFOUND;
            -- Tasks found for visit
            -- To set prices to NULL in case if the visit's department is changed
            UPDATE AHL_VISIT_TASKS_B
            SET ACTUAL_PRICE = NULL,
                ESTIMATED_PRICE = NULL,
                OBJECT_VERSION_NUMBER = c_task_rec.object_version_number + 1
            WHERE VISIT_TASK_ID = c_task_rec.visit_task_id;
        END LOOP;
        CLOSE c_task;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG,'After updating actual and estimated price for all the tasks in the visit');
        END IF;
      END IF;
    END IF;

    -- To call LTP Process Materials API for APS Integration by Shbhanda 04-Dec-03
    -- changed the condition for fixing the issue 144 , in the CMRO Forum
    -- if any of start date,organization, or department is not
    -- is invoked with operation flag 'D'
    -- else if any of them is updated then AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials is invoked with operation flag 'U' as earlier.

    IF (( c_visit_rec.organization_id IS NOT NULL AND c_visit_rec.department_id IS NOT NULL AND
           c_Visit_rec.START_DATE_TIME IS NOT NULL )
           AND ( l_date_time_start IS NULL OR l_date_time_start = Fnd_Api.G_MISS_DATE OR
           l_visit_rec.organization_id IS NULL OR l_visit_rec.organization_id = Fnd_Api.G_MISS_NUM OR
           l_visit_rec.department_id IS NULL OR l_visit_rec.department_id = Fnd_Api.G_MISS_NUM ))
    THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials');
        END IF;

        AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials (
                p_api_version             => 1.0,
                p_init_msg_list           => FND_API.g_false,
                p_commit                  => FND_API.g_false,
                p_validation_level        => FND_API.g_valid_level_full,
                p_visit_id                => l_visit_rec.Visit_Id,
                p_visit_task_id           => NULL,
                p_org_id                  => l_visit_rec.organization_id,
                p_start_date              => l_date_time_start,
                p_operation_flag          => 'D',
                x_planned_order_flag      => l_planned_order_flag ,
                x_return_status           => l_return_status,
                x_msg_count               => x_msg_count,
                x_msg_data                => x_msg_data );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials - l_return_status : '||l_return_status);
        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    ELSIF ( NVL(l_date_time_start,TO_DATE('01-01-1947','DD-MM-YYYY')) <>  NVL(c_Visit_rec.START_DATE_TIME,TO_DATE('01-01-1947','DD-MM-YYYY'))
    OR NVL(l_visit_rec.organization_id,-777) <> NVL(c_visit_rec.organization_id,-777)
    OR NVL(l_visit_rec.department_id,-777) <> NVL(c_visit_rec.department_id,-777))
    AND ( l_date_time_start IS NOT NULL AND l_date_time_start <> Fnd_Api.G_MISS_DATE
    AND l_visit_rec.organization_id IS NOT NULL AND l_visit_rec.organization_id <> Fnd_Api.G_MISS_NUM
    AND l_visit_rec.department_id IS NOT NULL AND l_visit_rec.department_id <> Fnd_Api.G_MISS_NUM )
    THEN
        /*AHL_DEBUG_PUB.Debug( l_full_name ||': VISIT UPDATED - Before calling AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials');
        ELSIF (
        ( l_date_time_start <> c_Visit_rec.START_DATE_TIME)
           OR (l_visit_rec.organization_id <> c_visit_rec.organization_id)
           OR (l_visit_rec.department_id   <> c_visit_rec.department_id)
                      )*/
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials');
        END IF;

        AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials (
                p_api_version             => 1.0,
                p_init_msg_list           => FND_API.g_false,
                p_commit                  => FND_API.g_false,
                p_validation_level        => FND_API.g_valid_level_full,
                p_visit_id                => l_visit_rec.Visit_Id,
                p_visit_task_id           => NULL,
                p_org_id                  => l_visit_rec.organization_id,
                p_start_date              => l_date_time_start,
                p_operation_flag          => 'U',
                x_planned_order_flag      => l_planned_order_flag ,
                x_return_status           => l_return_status,
                x_msg_count               => x_msg_count,
                x_msg_data                => x_msg_data );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials - l_return_status : '||l_return_status);
        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    -- Set any task changed flag to "Y" if start/end date changed
    IF NVL(TO_CHAR(l_date_time_start,'DD-MM-YYYY HH24:MI'),'XXX') <> NVL(TO_CHAR(c_Visit_rec.START_DATE_TIME,'DD-MM-YYYY HH24:MI'),'XXX')
    OR NVL(TO_CHAR(l_date_time_end,'DD-MM-YYYY HH24:MI'),'XXX') <> NVL(TO_CHAR(c_Visit_rec.CLOSE_DATE_TIME,'DD-MM-YYYY HH24:MI'),'XXX') THEN
      AHL_VWP_RULES_PVT.Update_Visit_Task_Flag
            (
              p_visit_id      => l_Visit_rec.visit_id,
              p_flag          => 'Y',
              x_return_status => l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    l_msg_count := Fnd_Msg_Pub.count_msg;
    IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Standard check for commit
    IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.end','At the end of PLSQL procedure');
    END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Update_Visit;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Visit;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Visit;
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
END Update_Visit;
/*--------------------------------------------------------------------
-- PROCEDURE
--  Delete Task
--  Internal procedure for deleting links for the task to be deleted.

--------------------------------------------------------------------

PROCEDURE Delete_Task (
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
    p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
    p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
    p_module_type       IN  VARCHAR2  := Null,
        p_Visit_Task_Id     IN  NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
)
IS
   l_api_version    CONSTANT NUMBER       := 1.0;
   l_api_name       CONSTANT VARCHAR2(30) := 'Delete_Task';
   l_full_name      CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_Api_name;
   l_task_id        NUMBER;
   l_count          NUMBER;

BEGIN
     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME||'.begin',
            'At the start of Delete_Visit -> Delete Task'
        );
     END IF;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME,
            'p_visit_task_id : '||p_Visit_Task_Id
        );

     END IF;

       -- Remove the originating task association of the deleted task
       UPDATE
     AHL_VISIT_TASKS_B
       SET
     ORIGINATING_TASK_ID=NULL,
     OBJECT_VERSION_NUMBER = object_version_number + 1
       WHERE
     ORIGINATING_TASK_ID = p_Visit_Task_Id and NVL(STATUS_CODE,'X') <> 'DELETED';


       -- Remove Cost parent associations for this task
       UPDATE
    AHL_VISIT_TASKS_B
       SET
    COST_PARENT_ID = NULL,
    OBJECT_VERSION_NUMBER = object_version_number + 1
       WHERE
    COST_PARENT_ID = p_Visit_Task_Id AND NVL(STATUS_CODE,'X') <> 'DELETED';


    -- Remove Primary Task Associations in simulation visit for the deleted Task
    UPDATE
       AHL_VISIT_TASKS_B
    SET
       PRIMARY_VISIT_TASK_ID = NULL,
       OBJECT_VERSION_NUMBER = object_version_number + 1
    WHERE
       PRIMARY_VISIT_TASK_ID = p_Visit_Task_Id AND NVL(STATUS_CODE,'X') <> 'DELETED';


    -- Remove task links of the deleted task
    DELETE
       AHL_TASK_LINKS
    WHERE
       VISIT_TASK_ID = p_Visit_Task_Id
       OR
       PARENT_TASK_ID = p_Visit_Task_Id;

    AHL_VWP_PROJ_PROD_PVT.Delete_Task_To_project(
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        p_commit        => Fnd_Api.g_false,
        p_validation_level  => p_validation_level,
        p_module_type       => p_module_type,
        p_visit_task_id     => p_Visit_Task_Id,
        x_return_status     => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data);

    IF NVL(x_return_status, 'X') <> Fnd_Api.G_RET_STS_SUCCESS
    THEN
      -- Method call was not successful, raise error
      Fnd_Message.SET_NAME('AHL','AHL_VWP_PRJ_TASK_FAILED');
      Fnd_Msg_Pub.ADD;
          IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
         fnd_log.string
         (
            fnd_log.level_error,
            'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME,
            'Failed to delete project task association for task '||p_visit_task_id
         );
          END IF;
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME||'.end',
            'At the end of Delete_Visit -> Delete Task'
        );
    END IF;


END Delete_Task;*/
--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Visit
--
-- PURPOSE
--    To delete a Maintainanace Visit.
--------------------------------------------------------------------

PROCEDURE Delete_Visit (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_visit_id          IN  NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
)
IS
 -- Define local Variables
   l_api_version    CONSTANT NUMBER       := 1.0;
   l_api_name       CONSTANT VARCHAR2(30) := 'Delete_Visit';
   l_full_name      CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_Api_name;
   L_DEBUG            CONSTANT VARCHAR2(90) := 'ahl.plsql.'||L_FULL_NAME;

   l_msg_data        VARCHAR2(2000);
   l_return_status   VARCHAR2(1);
   l_msg_count       NUMBER;

   l_default         VARCHAR2(30);
   l_visit_id        NUMBER;
   l_commit          VARCHAR2(1) := 'F';
   l_init_msg_list   VARCHAR2(1) := 'F';

   l_soft_delete_flag   VARCHAR2(1) := 'N';
   l_planned_order_flag VARCHAR2(1);

   -- Define local Cursors
   -- To find visit related information
   CURSOR c_Visit(x_id IN NUMBER) IS
   SELECT * FROM  Ahl_Visits_VL
   WHERE VISIT_ID = x_id;

   l_visit_rec      c_Visit%ROWTYPE;

   -- To find whether the visit has any materials
   CURSOR c_Material(x_visit_id IN NUMBER) IS
/* SELECT 'X' FROM DUAL
   WHERE exists (select 'X' from AHL_SCHEDULE_MATERIALS_V where VISIT_ID = x_visit_id);*/

   -- AnRaj: Changed for fixing the perf bug 4919502
   SELECT 'x' FROM   ahl_schedule_materials
   WHERE  status <> 'DELETED'
   AND    visit_id = x_visit_id;

   c_Material_rec   c_Material%ROWTYPE;

   -- To find Master Workorder associated with the given Visit in production
   CURSOR c_workorder_csr(x_visit_id IN NUMBER) IS
   SELECT workorder_id, object_version_number, status_code
   FROM AHL_WORKORDERS
   WHERE VISIT_ID = x_visit_id
   AND MASTER_WORKORDER_FLAG = 'Y'
   AND VISIT_TASK_ID IS NULL;

   l_workorder_rec c_workorder_csr%ROWTYPE;

   -- To find active Master Workorder associated with the given Visit in production
   CURSOR c_active_workorder(x_visit_id IN NUMBER) IS
   SELECT workorder_id, object_version_number, status_code
   FROM AHL_WORKORDERS
   WHERE VISIT_ID = x_visit_id
   AND MASTER_WORKORDER_FLAG = 'Y'
   AND VISIT_TASK_ID IS NULL
   AND STATUS_CODE not in ('22','7');  -- deleted, cancelled

   l_active_workorder_rec c_active_workorder%ROWTYPE;

   -- cursor for finding all information about the tasks
   CURSOR c_Tasks_csr(x_id IN NUMBER) IS
   -- Merge process for 11.5.10 Bug fix
   SELECT visit_task_id,object_version_number,visit_task_number
   FROM  Ahl_Visit_Tasks_VL
   WHERE VISIT_ID = x_id AND NVL(STATUS_CODE,'X') <> 'DELETED'
   AND ((TASK_TYPE_CODE = 'SUMMARY' AND ORIGINATING_TASK_ID IS NULL)
   OR TASK_TYPE_CODE = 'UNASSOCIATED'
   OR (TASK_TYPE_CODE = 'SUMMARY' AND MR_ID IS NULL));

   l_tasks_rec c_tasks_csr%ROWTYPE;

   -- Local record of Workorder used while calling update job method.
   l_prd_workorder_rec AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_REC;
   l_workorder_tbl AHL_PRD_WORKORDER_PVT.PRD_WORKOPER_TBL;

BEGIN
    --------------------- Initialize -----------------------
    SAVEPOINT Delete_Visit;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.begin','At the start of PLSQL procedure');
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF Fnd_Api.to_boolean(p_init_msg_list) THEN
      Fnd_Msg_Pub.initialize;
    END IF;

    --Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME) THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;
    ------------------------Start of API Body------------------------------------
    ------------------------ Delete ------------------------
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'Visit ID - ' ||p_visit_id );
    END IF;

    OPEN c_Visit(p_visit_id);
    FETCH c_Visit INTO l_Visit_rec;
    IF c_Visit%NOTFOUND THEN
      CLOSE c_Visit;
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
        Fnd_Message.set_name('AHL', 'AHL_API_RECORD_NOT_FOUND');
        Fnd_Msg_Pub.ADD;
        IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement,L_DEBUG,'Record not found for the visit with ID'||p_visit_id);
        END IF;
      END IF;
      RAISE Fnd_Api.g_exc_error;
    END IF;
    CLOSE c_Visit;

    -- Check the status of visit, if 'planning' then only delete
    IF UPPER(l_visit_rec.status_code) <> 'PLANNING' THEN
      Fnd_Message.SET_NAME('AHL','AHL_VWP_STATUS_NOT_DELETE');
      Fnd_Msg_Pub.ADD;
      IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Visit is in invalid status for deletion. Visit ID:  '||p_visit_id);
      END IF;
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    -- To Check if any materials are schedueled for the visit
    OPEN  c_Material(p_visit_id);
    FETCH c_Material INTO c_Material_rec;
    IF c_Material%FOUND THEN
      l_soft_delete_flag := 'Y';

      IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials');
      END IF;

      -- Removing planned materials for the visit
      AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials
                              (p_api_version            => p_api_version,
                               p_init_msg_list          => Fnd_Api.G_FALSE,
                               p_commit                 => Fnd_Api.G_FALSE,
                               p_visit_id               => p_visit_id,
                               p_visit_task_id          => NULL,
                               p_org_id                 => NULL,
                               p_start_date             => NULL,
                               p_operation_flag         => 'R',
                               x_planned_order_flag     => l_planned_order_flag ,
                               x_return_status          => l_return_status,
                               x_msg_count              => x_msg_count,
                               x_msg_data               => x_msg_data);

      IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials - l_return_status : '||l_return_status);
      END IF;

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        CLOSE c_Material;
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
    CLOSE c_Material;

    IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_LTP_SIMUL_PLAN_PVT.delete_simul_visits');
    END IF;
    -- Delete all associated simulated visits if the visit to be deleted is a primary visit
    AHL_LTP_SIMUL_PLAN_PVT.delete_simul_visits
             (p_api_version        => l_api_version,
              p_init_msg_list      => l_init_msg_list,
              p_commit             => l_commit,
              p_validation_level   => p_validation_level,
              p_visit_id           => p_visit_id,
              x_return_status      => l_return_status,
              x_msg_count          => l_msg_count,
              x_msg_data           => l_msg_data);

    IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_LTP_SIMUL_PLAN_PVT.delete_simul_visits  - l_return_status : '||l_return_status);
    END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- Check Error Message stack.
      x_msg_count := FND_MSG_PUB.count_msg;
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string (fnd_log.level_statement,L_DEBUG,'Errors from delete_simul_visits: ' || x_msg_count );
      END IF;
      RAISE Fnd_Api.g_exc_error;
    END IF;

    -- Check for to delete the visit's tasks
    OPEN c_Tasks_csr(p_visit_id);
    LOOP
      FETCH c_Tasks_csr INTO l_tasks_rec;
      EXIT WHEN c_Tasks_csr%NOTFOUND;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string (fnd_log.level_statement,L_DEBUG,'Before calling AHL_VWP_TASKS_PVT.Delete_Task - visit_task_id : '||l_tasks_rec.visit_task_id);
      END IF;

      l_soft_delete_flag := 'Y';  -- If tasks are set only soft delete needs to be done.

      -- Call Delete_Task to remove all the task associations for the deleted task
      AHL_VWP_TASKS_PVT.Delete_Task
            (   p_api_version           => p_api_version,
                p_init_msg_list         => l_init_msg_list,
                p_commit                => l_commit,
                p_validation_level      => p_validation_level,
                p_module_type           => NULL,
                p_visit_task_id         => l_tasks_rec.visit_task_id,
                x_return_status         => l_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data);

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string (fnd_log.level_statement,L_DEBUG,'After calling Delete_Task - l_return_status : '||l_return_status);
      END IF;

      IF NVL(l_return_status, 'X') <> Fnd_Api.G_RET_STS_SUCCESS THEN
          CLOSE c_Tasks_csr;
          Fnd_Message.SET_NAME('AHL','AHL_VWP_TASK_DEL_FAILED');
          Fnd_Message.SET_TOKEN('TASK_NAME',l_tasks_rec.visit_task_number);
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
    END LOOP;
    CLOSE c_Tasks_csr;

    -- 11.5.10 Change starts here
    -- Check if the Visit to be deleted has Master Workorder in production
    OPEN c_workorder_csr(p_visit_id);
    FETCH c_workorder_csr INTO l_workorder_rec;
    -- Master workorder not found
    IF c_workorder_csr%FOUND THEN
      l_soft_delete_flag := 'Y';
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string (fnd_log.level_statement,L_DEBUG,'Visit Has workorder associated with status code '||l_workorder_rec.STATUS_CODE);
      END IF;

      OPEN c_active_workorder(p_visit_id);
      FETCH c_active_workorder INTO l_active_workorder_rec;
      -- Found Active Master workorder, then cancel all visit jobs.
      IF c_active_workorder%FOUND THEN
        -- delete visit master workorder
        l_prd_workorder_rec.workorder_id := l_active_workorder_rec.workorder_id;
        l_prd_workorder_rec.object_version_number := l_active_workorder_rec.object_version_number;
        l_prd_workorder_rec.STATUS_CODE:='22'; --Deleted Status Refer DLD to Verify.

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string (fnd_log.level_statement,L_DEBUG,'before calling AHL_PRD_WORKORDER_PVT.update_job - Workorder Id : '||l_prd_workorder_rec.workorder_id);
        END IF;

        AHL_PRD_WORKORDER_PVT.update_job
                   (  p_api_version          =>1.0,
                      p_init_msg_list        =>fnd_api.g_false,
                      p_commit               =>fnd_api.g_false,
                      p_validation_level     =>p_validation_level,
                      p_default              =>fnd_api.g_false,
                      p_module_type          =>NULL,
                      x_return_status        =>l_return_status,
                      x_msg_count            =>x_msg_count,
                      x_msg_data             =>x_msg_data,
                      p_wip_load_flag        =>'Y',
                      p_x_prd_workorder_rec  =>l_prd_workorder_rec,
                      p_x_prd_workoper_tbl   =>l_workorder_tbl
                   );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string (fnd_log.level_statement,L_DEBUG,'after calling AHL_PRD_WORKORDER_PVT.update_job - l_return_status : '||l_return_status);
        END IF;

        IF NVL(l_return_status, 'X') <> Fnd_Api.G_RET_STS_SUCCESS THEN
           CLOSE c_active_workorder;
           CLOSE c_workorder_csr;
           RAISE Fnd_Api.G_EXC_ERROR;
        END IF;
      END IF;
      CLOSE c_active_workorder;
    END IF;
    CLOSE c_workorder_csr;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string (fnd_log.level_statement,L_DEBUG,'PROJECT_ID : '||l_visit_rec.PROJECT_ID);
    END IF;

    -- Delete or cancel project and project tasks
    IF l_visit_rec.PROJECT_ID IS NOT NULL THEN
      IF l_soft_delete_flag = 'Y' THEN
          -- Update the project status to 'Rejected'
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string (fnd_log.level_statement,L_DEBUG,'before calling AHL_VWP_PROJ_PROD_PVT.Update_project');
        END IF;

        AHL_VWP_PROJ_PROD_PVT.Update_project
              ( p_api_version           => p_api_version,
                p_init_msg_list         => l_init_msg_list,
                p_commit                => l_commit,
                p_validation_level      => p_validation_level,
                p_module_type           => 'DEL',
                p_visit_id              => p_visit_id,
                x_return_status         => l_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data
              );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string (fnd_log.level_statement,L_DEBUG,'after calling AHL_VWP_PROJ_PROD_PVT.Update_project - l_return_status : '||l_return_status);
        END IF;

        IF NVL(l_return_status, 'X') <> Fnd_Api.G_RET_STS_SUCCESS THEN
          Fnd_Message.SET_NAME('AHL','AHL_VWP_PRJ_UPDATE_FAILED'); -- Failed to update job
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.G_EXC_ERROR;
        END IF;
      ELSE
        -- When a visit is hard deleted than the related projects is also deleted
        -- Call Delete_Project local procedure to delete project and its tasks
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string (fnd_log.level_statement,L_DEBUG,'before calling AHL_VWP_PROJ_PROD_PVT.Delete_Project ');
        END IF;

        AHL_VWP_PROJ_PROD_PVT.Delete_Project
            (   p_api_version           => p_api_version,
                p_init_msg_list         => l_init_msg_list,
                p_commit                => l_commit,
                p_validation_level      => p_validation_level,
                p_module_type           => NULL,
                p_visit_id              => p_visit_id,
                x_return_status         => l_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string (fnd_log.level_statement,L_DEBUG,'after calling AHL_VWP_PROJ_PROD_PVT.Delete_Project - l_return_status : '||l_return_status);
        END IF;

        IF NVL(l_return_status, 'X') <> Fnd_Api.G_RET_STS_SUCCESS THEN
          -- Method call was not successful, raise error
          Fnd_Message.SET_NAME('AHL','AHL_VWP_PRJ_DEL_FAILED');
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.G_EXC_ERROR;
        END IF;
      END IF;  -- soft delete flag
    END IF; -- project id not null

    -- delete stages in the case of physical delete
    IF l_soft_delete_flag = 'N' THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string (fnd_log.level_statement,L_DEBUG,'before calling AHL_VWP_VISITS_STAGES_PVT.DELETE_STAGES ');
        END IF;

        AHL_VWP_VISITS_STAGES_PVT.DELETE_STAGES
              ( p_api_version           => p_api_version,
                p_init_msg_list         => l_init_msg_list,
                p_commit                => l_commit,
                p_validation_level      => p_validation_level,
                p_module_type           => NULL,
                p_visit_id              => l_visit_rec.visit_id,
                x_return_status         => l_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data
              );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string (fnd_log.level_statement,L_DEBUG,'after calling AHL_VWP_VISITS_STAGES_PVT.DELETE_STAGES - l_return_status : '||l_return_status );
        END IF;

        IF NVL(l_return_status, 'X') <> Fnd_Api.G_RET_STS_SUCCESS THEN
          RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        DELETE FROM ahl_visit_tasks_b
        WHERE  visit_id = p_visit_id;

        --Delete the visit
        AHL_VISITS_PKG.Delete_Row( x_visit_id => p_visit_id);
    ELSE
       -- Soft Delete
        UPDATE AHL_VISITS_B
        SET STATUS_CODE = 'DELETED',
            SIMULATION_PLAN_ID = NULL,
            OBJECT_VERSION_NUMBER =OBJECT_VERSION_NUMBER + 1
        WHERE VISIT_ID =  l_visit_rec.visit_id;
    END IF; -- soft delete flag
    --------------------------End of API Body---------------------------------------
    --Standard check to count messages
    l_msg_count := Fnd_Msg_Pub.count_msg;

    IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Standard check for commit
    IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.end','At the end of PLSQL procedure');
    END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Delete_Visit;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Delete_Visit;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Visit;
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
END Delete_Visit;
--------------------------------------------------------------------
-- PROCEDURE
--   Validate_Visit
--
--------------------------------------------------------------------
PROCEDURE Validate_Visit (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_Visit_rec         IN  Visit_Rec_Type,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
)
IS
 -- Define local Variables
   L_API_VERSION CONSTANT NUMBER := 1.0;
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Validate_Visit';
   L_FULL_NAME   CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   L_DEBUG       CONSTANT VARCHAR2(90) := 'ahl.plsql.'||L_FULL_NAME;

   l_return_status   VARCHAR2(1);
BEGIN
    --------------------- Initialize -----------------------
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.begin','At the start of PLSQL procedure');
    END IF;

    IF Fnd_Api.to_boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.initialize;
    END IF;

    IF NOT Fnd_Api.compatible_api_call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME
    ) THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
    END IF;
    x_return_status := Fnd_Api.g_ret_sts_success;

    ---------------------- validate ------------------------
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'Calling Check_Visit_Items');
    END IF;

    IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_item THEN
      Check_Visit_Items (
         p_Visit_rec          => p_Visit_rec,
         p_validation_mode    => Jtf_Plsql_Api.g_create,
         x_return_status      => l_return_status
      );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling Check_Visit_Items - l_return_status : '||l_return_status);
      END IF;

      IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;
    END IF;
    -------------------- finish --------------------------
    Fnd_Msg_Pub.count_and_get (
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
    );

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.end','At the end of PLSQL procedure');
    END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error) THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Validate_Visit;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Visit_Items
--
---------------------------------------------------------------------
PROCEDURE Check_Visit_Items (
   p_Visit_rec       IN  Visit_Rec_Type,
   p_validation_mode IN  VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN
   -- Validate required items.
   Check_Visit_Req_Items (
      p_Visit_rec       => p_Visit_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Validate uniqueness.
   Check_Visit_UK_Items (
      p_Visit_rec          => p_Visit_rec,
      p_validation_mode    => p_validation_mode,
      x_return_status      => x_return_status
   );

   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_Visit_Items;

---------------------------------------------------------------------
-- PROCEDURE
--       Check_Visit_Req_Items
---------------------------------------------------------------------
PROCEDURE Check_Visit_Req_Items (
   p_Visit_rec       IN    Visit_Rec_Type,
   x_return_status   OUT   NOCOPY VARCHAR2
)
IS
BEGIN
-- Post 11.5.10 Enhancements
-- Only visit name is mandatory on create/update visit pages
     -- VISIT NAME
   IF (p_Visit_rec.visit_name IS NULL OR p_Visit_rec.visit_name = Fnd_Api.G_MISS_CHAR) THEN
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_VWP_VST_NAME_MISSING');
         Fnd_Msg_Pub.ADD;
      END IF;
      x_return_status := Fnd_Api.g_ret_sts_error;
      RETURN;
   END IF;

/*     -- VISIT TYPE ==== VISIT_TYPE_CODE
   IF (p_Visit_rec.visit_type_code IS NULL OR p_Visit_rec.visit_type_code = Fnd_Api.G_MISS_CHAR)THEN
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_VWP_TYPE_MISSING');
         Fnd_Msg_Pub.ADD;
      END IF;
      x_return_status := Fnd_Api.g_ret_sts_error;
      RETURN;
   END IF;
*/
/*   IF p_Visit_rec.VISIT_ID IS NULL THEN
     -- ITEM ==== INVENTORY_ITEM_ID
      IF (p_Visit_rec.ITEM_NAME IS NULL OR p_Visit_rec.ITEM_NAME = Fnd_Api.G_MISS_CHAR) THEN
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
             Fnd_Message.set_name ('AHL', 'AHL_VWP_ITEM_MISSING');
             Fnd_Msg_Pub.ADD;
          END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
          RETURN;
       END IF;
*/
/*     -- SERIAL NUMBER ==== ITEM_INSTANCE_ID
       IF (p_Visit_rec.SERIAL_NUMBER IS NULL OR p_Visit_rec.SERIAL_NUMBER = Fnd_Api.G_MISS_CHAR) THEN

          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
             Fnd_Message.set_name ('AHL', 'AHL_VWP_SERIAL_MISSING');
             Fnd_Msg_Pub.ADD;
          END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
          RETURN;
       END IF;

    END IF;
*/

END Check_Visit_Req_Items;

---------------------------------------------------------------------
-- PROCEDURE
--       Check_Visit_UK_Items
---------------------------------------------------------------------
PROCEDURE Check_Visit_UK_Items (
   p_Visit_rec       IN    Visit_Rec_Type,
   p_validation_mode IN    VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status   OUT   NOCOPY VARCHAR2
)
IS
   l_valid_flag   VARCHAR2(1);
BEGIN
   x_return_status := Fnd_Api.g_ret_sts_success;
   --
   -- For Create_Visit, when ID is passed in, we need to
   -- check if this ID is unique.
 IF UPPER(p_Visit_rec.operation_flag) <> 'C' THEN

   IF p_validation_mode = Jtf_Plsql_Api.g_create AND p_Visit_rec.VISIT_ID IS NOT NULL
   THEN

      IF Ahl_Utility_Pvt.check_uniqueness(
              'Ahl_Visits_VL',
                'VISIT_ID = ' || p_Visit_rec.VISIT_ID
            ) = Fnd_Api.g_false THEN

         IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
            Fnd_Message.set_name ('AHL', 'AHL_VWP_DUPLICATE_VISIT_ID');
            Fnd_Msg_Pub.ADD;
         END IF;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;

      END IF;
   END IF;
END IF;

   -- check if VISIT NUMBER is UNIQUE
   IF p_validation_mode = Jtf_Plsql_Api.g_create THEN
     IF (p_Visit_rec.VISIT_NUMBER IS NOT NULL) THEN
       l_valid_flag := Ahl_Utility_Pvt.Check_Uniqueness (
         'Ahl_Visits_VL',
         'VISIT_NUMBER = ''' || p_Visit_rec.VISIT_NUMBER || ''''
      );
     END IF;
  ELSE
      IF (p_Visit_rec.VISIT_NUMBER IS NOT NULL) THEN
       l_valid_flag := Ahl_Utility_Pvt.Check_Uniqueness (
         'Ahl_Visits_VL',
         'VISIT_NUMBER = ''' || p_Visit_rec.VISIT_NUMBER ||
         ''' AND VISIT_ID <> ' || p_Visit_rec.VISIT_ID
       );
     END IF;
  END IF;

   IF l_valid_flag = Fnd_Api.g_false THEN
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_VWP_DUPLI_VISIT_NUMBER');
         Fnd_Msg_Pub.ADD;
      END IF;
        x_return_status := Fnd_Api.g_ret_sts_error;
      RETURN;
   END IF;
END Check_Visit_UK_Items;


--------------------------------------------------------------------
-- PROCEDURE
--    Close_Visit
--
-- PURPOSE
--    To check all validations before changing status of a Visit to Close
--------------------------------------------------------------------
PROCEDURE Close_Visit(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type       IN  VARCHAR2  := Null,
   p_visit_id          IN  NUMBER,
   p_x_cost_session_id IN OUT NOCOPY NUMBER,
   p_x_mr_session_id   IN OUT NOCOPY NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
  )
IS
 -- Define local Variables
   L_API_VERSION     CONSTANT NUMBER := 1.0;
   L_API_NAME        CONSTANT VARCHAR2(30) := 'Close Visit';
   L_FULL_NAME       CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   L_DEBUG           CONSTANT VARCHAR2(90) := 'ahl.plsql.'||L_FULL_NAME;

   l_msg_data        VARCHAR2(2000);
   l_status_name     VARCHAR2(80);
   l_status_code     VARCHAR2(30);
   l_chr_date        VARCHAR2(30);
   l_chk_flag        VARCHAR2(1);
   l_return_status   VARCHAR2(1);

   l_min             NUMBER;
   l_hour            NUMBER;
   l_msg_count       NUMBER;
   l_count           NUMBER;
   i                 NUMBER;

   l_Date            DATE;
   l_planned_order_flag VARCHAR2(1);
   G_EXC_ERROR          EXCEPTION;

   l_cost_price_rec   AHL_VWP_VISIT_CST_PR_PVT.Cost_price_rec_type;
   -- Define local Cursors
   -- To find visit related information
   CURSOR c_visit (x_id IN NUMBER) IS
   SELECT * FROM AHL_VISITS_VL
   WHERE VISIT_ID = x_id;
   c_visit_rec c_visit%ROWTYPE;

   -- To find task related information
   CURSOR c_task (x_id IN NUMBER) IS
   SELECT * FROM AHL_VISIT_TASKS_VL
   WHERE VISIT_ID = x_id
   AND NVL(STATUS_CODE,'X') <> 'DELETED';
   c_task_rec c_task%ROWTYPE;

   --yazhou 08Sep2005 starts
  -- 1) To find task id which has its corresponding job in shop floor
  -- and the job is not in complete, cancelled, closed and deferred status
  -- 4--->Complete; 7--->Cancelled; 12 --> Closed; 18 --> Deferred
  -- Filter out all Summary tasks, because Master WO will not have statuses updated
  --If found, then can not close job.
  CURSOR get_open_job_task_csr (p_visit_id IN NUMBER) IS
  SELECT A.VISIT_TASK_ID
  FROM AHL_VISIT_TASKS_VL A, AHL_WORKORDERS B
  WHERE A.VISIT_TASK_ID = B.VISIT_TASK_ID
  AND A.VISIT_ID = p_visit_id
  AND NVL(A.STATUS_CODE,'X') <> 'DELETED'
  -- Balaji added statuses complete_no_charge and deleted to the list of statuses to be
  -- checked for.
  -- COMPELTE_NO_CHARGE - 5, DELETED - 22
  --('4','7','12','18')
  AND B.STATUS_CODE NOT IN ('4','5','7','12','18','22')
  AND A.TASK_TYPE_CODE <> 'SUMMARY';
  --yazhou 08Sep2005 ends

  --yazhou 29Sep2005 starts
  -- bug fix #4614587
  -- 2) Cursor to check that the unit effectivities are updated properly
  -- If there are any which is in wrong status, can not close visit
  -- PLANNED tasks can not be canncelled. UMP enforcing that rule
  CURSOR get_ue_tasks_csr (p_visit_id IN NUMBER) IS
  SELECT UE.unit_effectivity_id
  FROM   ahl_unit_effectivities_b UE, ahl_visit_tasks_b VT
  WHERE  UE.unit_effectivity_id = VT.unit_effectivity_id
  AND  nvl(UE.status_code,'x') NOT IN
    ('ACCOMPLISHED','DEFERRED','TERMINATED','CANCELLED')
  AND  (VT.task_type_code = 'UNPLANNED' OR VT.task_type_code = 'PLANNED')
  AND  VT.visit_id = p_visit_id
  AND NVL(VT.STATUS_CODE,'X') <> 'DELETED';
  --yazhou 29Sep2005 ends

  --Added by Srini
  CURSOR c_wip_entity(c_visit_id IN NUMBER) IS
  SELECT A.visit_task_id,workorder_id,wip_entity_id,a.object_version_number
  FROM ahl_visit_tasks_vl a, ahl_workorders b
  WHERE a.visit_task_id = b.visit_task_id
  AND a.visit_id = C_VISIT_ID
  AND NVL(A.STATUS_CODE,'X') <> 'DELETED'
  AND B.STATUS_CODE <> '7';

  -- Get summary task without mr
  CURSOR c_summ_task (c_visit_id IN NUMBER) IS
  SELECT visit_task_id,object_version_number
  FROM ahl_visit_tasks_vl
  WHERE visit_id = c_visit_id
  AND mr_id IS NULL
  AND task_type_code = 'SUMMARY'
  AND NVL(STATUS_CODE,'X') <> 'DELETED';

  l_wip_entity_rec  c_wip_entity%ROWTYPE;
  l_summ_task_rec   c_summ_task%ROWTYPE;
  l_actual_cost     NUMBER;
  l_estimated_cost  NUMBER;
  l_task_id     NUMBER;
  l_ue_id    NUMBER;

BEGIN
   --------------------- initialize -----------------------
    SAVEPOINT Close_Visit;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.begin','At the start of PLSQL procedure : Visit Id = ' || p_visit_id);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF Fnd_Api.to_boolean(p_init_msg_list) THEN
     Fnd_Msg_Pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME) THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    ------------------------Start of API Body------------------------------------
    OPEN c_visit (p_visit_id);
    FETCH c_visit INTO c_visit_rec;
    CLOSE c_visit;

    -- To check if the unit is quarantined
    -- AnRaj added for R 12.0 ACL changes in VWP, Start
    CHECK_UNIT_QUARANTINED( p_visit_id   => p_visit_id,
                           item_instance_id  => c_visit_rec.Item_Instance_Id);
    -- Check Error Message stack.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE  FND_API.G_EXC_ERROR;
    END IF;

    -- AnRaj added for R 12.0 ACL changes in VWP, End
    IF c_visit_rec.status_code = 'RELEASED' THEN
      l_chk_flag := 'Y';
      --Step 1) Check if there are any workorders which has not been completed/cancelled
      OPEN get_open_job_task_csr(p_visit_id);
      FETCH get_open_job_task_csr INTO l_task_id;
      IF get_open_job_task_csr%FOUND THEN
        l_chk_flag := 'N';
        Fnd_Message.SET_NAME('AHL','AHL_VWP_INVALID_JOB_STATUS');
        Fnd_Msg_Pub.ADD;
        CLOSE get_open_job_task_csr;
        RAISE Fnd_Api.g_exc_error;
      END IF;
      CLOSE get_open_job_task_csr;

      --2) Check that the corresponding UE records are in
      -- 'ACCOMPLISHED','DEFERRED','TERMINATED','CANCELLED'
      OPEN get_ue_tasks_csr(p_visit_id);
      FETCH get_ue_tasks_csr INTO l_ue_id;
      IF get_ue_tasks_csr%FOUND THEN
        l_chk_flag :='N';
        Fnd_Message.SET_NAME('AHL','AHL_VWP_UE_CLOSE_INV');
        Fnd_Msg_Pub.ADD;
        CLOSE get_ue_tasks_csr;
        RAISE Fnd_Api.g_exc_error;
      END IF;
      CLOSE get_ue_tasks_csr;

      --Modified by srini Sep 24/2003
      l_cost_price_rec.visit_id        := c_visit_rec.visit_id;
      l_cost_price_rec.cost_session_id := p_x_cost_session_id;
      l_cost_price_rec.mr_session_id   := p_x_mr_session_id;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Cost visit ID:' || l_cost_price_rec.VISIT_ID);
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Cost Session ID: ' || l_cost_price_rec.COST_SESSION_ID);
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Mr Session ID:' || l_cost_price_rec.MR_SESSION_ID);
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before Calling AHL_VWP_COST_PVT.Calculate_WO_Cost');
      END IF;

      --Call ahl_vwp_cost_pvt.calculate_wo_cost
      AHL_VWP_COST_PVT.Calculate_WO_Cost(
             p_api_version           => p_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => Fnd_Api.g_false,
             p_validation_level      => p_validation_level,
             p_x_cost_price_rec      => l_cost_price_rec,
             x_return_status         => l_return_status);

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'After Calling AHL_VWP_COST_PVT.Calculate_WO_Cost :  l_return_status - '||l_return_status);
      END IF;

      -- Check Error Message stack.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE  FND_API.G_EXC_ERROR;
      END IF;

      --Assign to out paramenter if null
      p_x_cost_session_id := l_cost_price_rec.cost_session_id;
      p_x_mr_session_id   := l_cost_price_rec.mr_session_id;

      OPEN c_wip_entity(c_visit_rec.visit_id);
      LOOP
        FETCH c_wip_entity INTO l_wip_entity_rec;
        EXIT WHEN c_wip_entity%NOTFOUND;

        -- Call ahl_vwp_cost_pvt.get_wo_cost
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement,L_DEBUG,'wip_entity_id - '||l_wip_entity_rec.wip_entity_id||' - '||'Visit task Id - '||l_wip_entity_rec.visit_task_id);
        END IF;

        IF l_wip_entity_rec.wip_entity_id IS NOT NULL THEN

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before Calling AHL_VWP_COST_PVT.Get_WO_Cost for all workorers');
          END IF;

          AHL_VWP_COST_PVT.Get_WO_Cost(
              p_Session_Id     => l_cost_price_rec.mr_session_id,
              p_Id             => l_wip_entity_rec.wip_entity_id,
              p_program_id     => fnd_global.PROG_APPL_ID,
              x_actual_cost    => l_actual_cost,
              x_estimated_cost => l_estimated_cost,
              x_return_status  => l_return_status);

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG,'After Calling AHL_VWP_COST_PVT.Get_WO_Cost :  l_return_status - '||l_return_status);
            fnd_log.string(fnd_log.level_statement,L_DEBUG,'Updating the actual cost of WO to - '||l_actual_cost);
          END IF;

          -- Update with actual cost
          UPDATE ahl_visit_tasks_b
          SET actual_cost = l_actual_cost,
              object_version_number = l_wip_entity_rec.object_version_number + 1
          WHERE visit_task_id = l_wip_entity_rec.visit_task_id;

        END IF;
      END LOOP;
      CLOSE c_wip_entity;

      -- Check Error Message stack.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE  FND_API.G_EXC_ERROR;
      END IF;

      --Check for summary tasks without mr
      OPEN c_summ_task(c_visit_rec.visit_id);
      LOOP
        FETCH c_summ_task INTO l_summ_task_rec;
        EXIT WHEN c_summ_task%NOTFOUND;
        IF l_summ_task_rec.visit_task_id IS NOT NULL THEN

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before Calling AHL_VWP_COST_PVT.Get_WO_Cost for summary tasks without mr - l_summ_task_rec.visit_task_id : '||l_summ_task_rec.visit_task_id);
          END IF;

          AHL_VWP_COST_PVT.Get_WO_Cost(
              p_Session_Id     => l_cost_price_rec.mr_session_id,
              p_Id             => l_summ_task_rec.visit_task_id,
              p_program_id     => fnd_global.PROG_APPL_ID,
              x_actual_cost    => l_actual_cost,
              x_estimated_cost => l_estimated_cost,
              x_return_status  => l_return_status);

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG,'After Calling AHL_VWP_COST_PVT.Get_WO_Cost :  l_return_status - '||l_return_status||' : l_actual_cost - '||l_actual_cost);
          END IF;

          --Update task record with actual cost
          UPDATE ahl_visit_tasks_b
          SET actual_cost = l_actual_cost,
              object_version_number = l_summ_task_rec.object_version_number + 1
          WHERE visit_task_id = l_summ_task_rec.visit_task_id;

      END IF;
     END LOOP;
     CLOSE c_summ_task;

     IF l_chk_flag = 'Y' THEN
      -- yazhou 28Sept2005 starts
      -- bug fix #4626717
      /* Call Update_Project procedure to update project status to CLOSED
      AHL_VWP_PROJ_PROD_PVT.Update_Project (
                p_api_version           => p_api_version,
                p_init_msg_list         => p_init_msg_list,
                p_commit                => Fnd_Api.g_false,
                p_validation_level      => p_validation_level,
                p_module_type           => p_module_type,
                p_visit_id              => p_visit_id,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data);*/

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before Calling AHL_COMPLETIONS_PVT.complete_master_wo');
      END IF;

      x_return_status := AHL_COMPLETIONS_PVT.complete_master_wo
                              (
                                p_visit_id              => p_visit_id,
                                p_workorder_id          => null,
                                p_ue_id                 => null
                              );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'After Calling AHL_COMPLETIONS_PVT.complete_master_wo');
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        -- Check Error Message stack.
        x_msg_count := FND_MSG_PUB.count_msg;
        RAISE Fnd_Api.g_exc_error;
      END IF;
      -- yazhou 28Sept2005 ends

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Updating Visit Status to CLOSED..');
      END IF;

      -- To update visit to CLOSED status
      UPDATE AHL_VISITS_B
      SET STATUS_CODE = 'CLOSED',
          SIMULATION_PLAN_ID = NULL,
          OBJECT_VERSION_NUMBER = c_visit_rec.object_version_number + 1
      WHERE VISIT_ID = p_visit_id;

      -- To update all tasks to CLOSED status
      OPEN c_task(p_visit_id);
      LOOP
        FETCH c_task INTO c_task_rec;
        EXIT WHEN c_task%NOTFOUND;

        UPDATE AHL_VISIT_TASKS_B
        SET STATUS_CODE = 'CLOSED',
            OBJECT_VERSION_NUMBER = c_task_rec.object_version_number + 1
        WHERE VISIT_TASK_ID = c_task_rec.visit_task_id;
      END LOOP;
      CLOSE c_task;

      -- Call Process_Planned_Materials API for APS Integration
      -- Start Code on 17th Feb 2004 by shbhanda
      OPEN c_visit (p_visit_id);
      FETCH c_visit INTO c_visit_rec;
      CLOSE c_visit;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'VISIT STATUS - ' || c_visit_rec.status_code);
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials');
      END IF;

      AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials (
                p_api_version             => 1.0,
                p_init_msg_list           => FND_API.g_false,
                p_commit                  => FND_API.g_false,
                p_validation_level        => FND_API.g_valid_level_full,
                p_visit_id                => p_visit_id,
                p_visit_task_id           => NULL,
                p_org_id                  => NULL,
                p_start_date              => NULL,
                p_visit_status            => c_visit_rec.status_code,
                p_operation_flag          => NULL,
                x_planned_order_flag      => l_planned_order_flag ,
                x_return_status           => x_return_status,
                x_msg_count               => x_msg_count,
                x_msg_data                => x_msg_data );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials : x_return_status - '||x_return_status);
      END IF;

      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
           X_msg_count := l_msg_count;
           X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'l_planned_order_flag - '||l_planned_order_flag);
      END IF;
     -- End Code on 17th Feb 2004 by shbhanda
     END IF;
    ELSE
        Fnd_Message.SET_NAME('AHL','AHL_VWP_STATUS_NOT_RELEASED');
        Fnd_Msg_Pub.ADD;
        RAISE Fnd_Api.g_exc_error;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'Cost Session ID: ' || p_x_cost_session_id);
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'Mr Session ID:' || p_x_mr_session_id);
    END IF;
    ---------------------------End of API Body-------------------------------------

    -- Standard check of p_commit.
    IF Fnd_Api.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    Fnd_Msg_Pub.count_and_get(
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data);

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.end','At the end of PLSQL procedure');
    END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Close_Visit;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Close_Visit;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Close_Visit;
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
END Close_Visit;

--------------------------------------------------------------------
-- PROCEDURE
--    Cancel_Visit
--
-- Post 11.5.10 Reema
-- Transit check changes by shbhanda on Jun 25rd 2004
-- Transit Check chagnes by yazhou Aug-06-2004
--
-- PURPOSE
--    To check all validations before changing status of a Visit to Cancel
--------------------------------------------------------------------
PROCEDURE Cancel_Visit(
   p_api_version       IN  NUMBER    := 1.0,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type       IN  VARCHAR2  := Null,
   p_visit_id          IN  NUMBER,
   p_obj_ver_num       IN  NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2)
IS
 -- Define local Variables
   L_API_VERSION     CONSTANT NUMBER := 1.0;
   L_API_NAME        CONSTANT VARCHAR2(30) := 'Cancel_Visit';
   L_FULL_NAME       CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   L_DEBUG            CONSTANT VARCHAR2(90) := 'ahl.plsql.'||L_FULL_NAME;

   l_chk_project     VARCHAR2(1);
   l_error_flag      VARCHAR2(1) := 'N';

   l_return_status VARCHAR2(1);
   l_msg_count NUMBER;
   l_msg_data  VARCHAR2(2000);

   l_planned_order_flag VARCHAR2(1);
   l_service_request_id   NUMBER;
   l_interaction_id    NUMBER;

   l_dummy             VARCHAR2(1);

   -- SKPATHAK :: Bug 9096318 :: 09-NOV-2009
   -- Added a table type and then an instance of it
   TYPE t_ue_id_tbl       IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   l_ue_id_inst_tbl            t_ue_id_tbl;

  -- Define local Cursors
  -- To find visit related information
   CURSOR c_visit (x_visit_id IN NUMBER) IS
   SELECT * FROM AHL_VISITS_VL
   WHERE VISIT_ID = x_visit_id;
   c_visit_rec c_visit%ROWTYPE;

   -- To find task related information for a visit
   CURSOR c_task (x_visit_id IN NUMBER) IS
   SELECT * FROM AHL_VISIT_TASKS_VL
   WHERE VISIT_ID = x_visit_id
   AND NVL(STATUS_CODE,'X') <> 'DELETED';
   c_task_rec c_task%ROWTYPE;

   -- transit check change
   -- yazhou start
   -- To find all the SRs associated to a visit
   -- Modified by Sjayacha to check if its not null.
   CURSOR c_service_request (x_visit_id IN NUMBER) IS
   SELECT distinct service_request_id FROM AHL_VISIT_TASKS_B
   WHERE VISIT_ID = x_visit_id
   AND service_request_id IS NOT NULL
   AND NVL(STATUS_CODE,'X') <> 'DELETED';

   -- To check if any other active visits have this SR associated
   CURSOR c_check_SR (x_visit_id IN NUMBER, x_sr_id IN NUMBER) IS
   SELECT 'X' FROM DUAL
   WHERE exists ( select a.visit_id
                  from ahl_visits_b a, ahl_visit_tasks_b b
                  where a.visit_id <> x_visit_id
                  and a.visit_id = b.visit_id
                  and b.visit_id <> x_visit_id
                  AND NVL(a.STATUS_CODE,'X') not in ('DELETED','CLOSED')
                  AND b.service_request_id = x_sr_id);

   CURSOR c_sr_ovn(x_sr_id IN NUMBER) IS
   SELECT object_version_number, incident_number
   FROM cs_incidents_all_b
   WHERE INCIDENT_ID = x_sr_id;
   c_sr_ovn_rec c_sr_ovn%ROWTYPE;
   -- yazhou end

   -- Added by jaramana and skpathak on 05-NOV-2009 for Bug 9095324
   -- Get only the top level UEs for all manually planned unit effectivities
   CURSOR c_unplanned_task_UEs(p_visit_id IN NUMBER) IS
   SELECT TSK.UNIT_EFFECTIVITY_ID
    FROM AHL_VISIT_TASKS_B TSK, AHL_UNIT_EFFECTIVITIES_B UE
    WHERE TSK.VISIT_ID            = p_visit_id
     AND TSK.STATUS_CODE         <> 'DELETED'
     AND TSK.TASK_TYPE_CODE      = 'SUMMARY'
     AND TSK.ORIGINATING_TASK_ID IS NULL
     -- Added by jaramana on 08-NOV-2009 for bug 9096318
     -- Delete UEs only with null, INIT-DUE and EXCEPTION status
     AND UE.UNIT_EFFECTIVITY_ID = TSK.UNIT_EFFECTIVITY_ID
     AND NVL(UE.STATUS_CODE, 'OPEN') IN ('OPEN', 'INIT-DUE', 'EXCEPTION')
     AND EXISTS (SELECT 'X'
                 FROM AHL_VISIT_TASKS_B TSKI
                 WHERE TSKI.VISIT_ID            = p_visit_id
                   AND TSKI.STATUS_CODE         <> 'DELETED'
                   AND TSKI.TASK_TYPE_CODE      = 'UNPLANNED'
                   AND TSKI.MR_ID               = TSK.MR_ID);

   -- SKPATHAK :: Bug 9096318 :: 09-NOV-2009
   -- Cursor to fetch the UE ID of all unplanned tasks
   -- For planned tasks, fetch the UE ID only if the status is null, INIT-DUE or EXCEPTION
   CURSOR c_get_ue_id (c_visit_id IN NUMBER) IS
   SELECT AUE.UNIT_EFFECTIVITY_ID
    FROM AHL_UNIT_EFFECTIVITIES_B AUE, AHL_VISIT_TASKS_B AVT
    WHERE AVT.VISIT_ID = c_visit_id
     AND AUE.UNIT_EFFECTIVITY_ID = AVT.UNIT_EFFECTIVITY_ID
     AND (NVL(AUE.STATUS_CODE, 'OPEN') IN ('OPEN', 'INIT-DUE', 'EXCEPTION')
     OR AVT.TASK_TYPE_CODE = 'UNPLANNED');
   get_ue_id_rec c_get_ue_id%ROWTYPE;

   l_ue_id NUMBER;

BEGIN
    --------------------- initialize -----------------------
    SAVEPOINT Cancel_Visit;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.begin','At the start of PLSQL procedure : Visit Id = ' || p_visit_id);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF Fnd_Api.to_boolean(p_init_msg_list) THEN
      Fnd_Msg_Pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT Fnd_Api.COMPATIBLE_API_CALL( l_api_version,
                                        p_api_version,
                                        l_api_name,G_PKG_NAME) THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    ---------------------------Start of API Body-------------------------------------
    OPEN c_visit(p_visit_id);
    FETCH c_visit INTO c_visit_rec;
    CLOSE c_visit;

    IF c_visit_rec.OBJECT_VERSION_NUMBER <> p_obj_ver_num THEN
      Fnd_Message.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
      Fnd_Msg_Pub.ADD;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Changed by jaramana on 05-NOV-2009
    -- Removed the validations added for the bug 9087120
    -- All work order status validation will now be done by AHL_PRD_WORKORDER_PVT.cancel_visit_jobs

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_PRD_WORKORDER_PVT.cancel_visit_jobs');
    END IF;
    -- Added by shbhanda for Transit check changes on 06/25/2004
    -- Code Start
    -- Call Cancel_Visit_Jobs API
    AHL_PRD_WORKORDER_PVT.cancel_visit_jobs
             (p_api_version   => 1.0,
	      -- SKPATHAK :: Bug 9115894 :: 20-NOV-2009 :: pass p_init_msg_list as false not true
              p_init_msg_list => FND_API.G_FALSE,
              p_commit        => FND_API.G_FALSE,
              p_validation_level => FND_API.G_VALID_LEVEL_FULL,
	      -- SKPATHAK :: Bug 9115894 :: 20-NOV-2009 ::  pass p_default as true not false
              p_default       => FND_API.G_TRUE,
              p_module_type   => NULL,
              x_return_status => l_return_status,
              x_msg_count     => l_msg_count,
              x_msg_data      => l_msg_data,
              p_visit_id      => p_visit_id,
              p_unit_effectivity_id => NULL,
              p_workorder_id        => NULL);

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_PRD_WORKORDER_PVT.cancel_visit_jobs - l_return_status : '||l_return_status);
    END IF;
    -- SKPATHAK :: Bug 9115894 :: 13-NOV-2009
    -- If return status is V, same should be carried over to the caller
    IF l_return_status = G_VALIDATION_ERROR_STATUS THEN
      RAISE G_VALIDATION_EXCEPTION;
    END IF;

    -- Check return status.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- SKPATHAK :: Bug 9096318 :: 09-NOV-2009
    -- Store all the fetched UE IDs in the table l_ue_id_inst_tbl
    OPEN c_get_ue_id(p_visit_id);
    FETCH c_get_ue_id BULK COLLECT INTO l_ue_id_inst_tbl;
    CLOSE c_get_ue_id;

    -- Added by jaramana on 05-NOV-2009 for Bug 9095324
    -- For Unplanned Tasks, do a delete of Unit Effectivities when canceling a visit
    OPEN c_unplanned_task_UEs(p_visit_id);
    LOOP
      FETCH c_unplanned_task_UEs INTO l_ue_id;
      EXIT WHEN c_unplanned_task_UEs%NOTFOUND;
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement, L_DEBUG, 'About to call AHL_UMP_UNPLANNED_PVT.DELETE_UNIT_EFFECTIVITY with p_unit_effectivity_id = ' || l_ue_id);
      END IF;
      AHL_UMP_UNPLANNED_PVT.DELETE_UNIT_EFFECTIVITY
        (
          p_api_version         => 1.0,
          p_init_msg_list       => FND_API.G_FALSE,
          p_commit              => FND_API.G_FALSE,
          x_return_status       => l_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            => x_msg_data,
          p_unit_effectivity_id => l_ue_id
        );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement, L_DEBUG, 'Returned from AHL_UMP_UNPLANNED_PVT.DELETE_UNIT_EFFECTIVITY, l_return_status = ' || l_return_status);
      END IF;
      IF ((l_msg_count > 0) OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS) THEN
        CLOSE c_unplanned_task_UEs;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
    CLOSE c_unplanned_task_UEs;

    -- SKPATHAK :: Bug 9096318 :: 09-NOV-2009
    -- Modified this update statement
    -- For all UNPLANNED tasks, nullify the unit effectivity id
    -- For PLANNED tasks, nullify the ue_id only if the status is null, INIT-DUE or EXCEPTION
    IF (l_ue_id_inst_tbl.COUNT > 0) THEN
      FOR i IN l_ue_id_inst_tbl.FIRST..l_ue_id_inst_tbl.LAST LOOP
        UPDATE AHL_VISIT_TASKS_B
        SET UNIT_EFFECTIVITY_ID = NULL,
        OBJECT_VERSION_NUMBER = object_version_number + 1,
        LAST_UPDATE_DATE      = SYSDATE,
        LAST_UPDATED_BY       = Fnd_Global.USER_ID,
        LAST_UPDATE_LOGIN     = Fnd_Global.LOGIN_ID
         WHERE VISIT_ID       = p_visit_id
           AND NVL(UNIT_EFFECTIVITY_ID, -1) = l_ue_id_inst_tbl(i);
       END LOOP;
     END IF;


    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials');
    END IF;

    -- Call AHL_LTP_REQST_MATRL_PVT.Process_Planned_Material
    AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials
                (p_api_version      => 1.0,
                 p_init_msg_list    => FND_API.g_false,
                 p_commit           => FND_API.g_false,
                 p_validation_level => FND_API.g_valid_level_full,
                 p_visit_id         => p_visit_id,
                 p_visit_task_id    => NULL,
                 p_org_id           => NULL,
                 p_start_date       => NULL,
                 p_visit_status     => 'CANCELLED',
                 p_operation_flag   => NULL,
                 x_planned_order_flag => l_planned_order_flag,
                 x_return_status    => l_return_status,
                 x_msg_count        => l_msg_count,
                 x_msg_data         => l_msg_data);

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials - l_return_status : '||l_return_status);
    END IF;

    -- Check return status.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- update task status
    OPEN c_task(p_visit_id);
    LOOP
      FETCH c_task INTO c_task_rec;
      EXIT WHEN c_task%NOTFOUND;
      -- update the task status to cancelled

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,'Updating the task status to CANCELLED for task ID - c_task_rec.visit_task_id : '||c_task_rec.visit_task_id);
      END IF;

      UPDATE AHL_VISIT_TASKS_B
      SET STATUS_CODE = 'CANCELLED',
          OBJECT_VERSION_NUMBER = c_task_rec.object_version_number + 1
      WHERE VISIT_TASK_ID = c_task_rec.visit_task_id;
    END LOOP;
    CLOSE c_task;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'Updating the visit status to CANCELLED..');
    END IF;
    -- update visit status
    UPDATE AHL_VISITS_B
    SET STATUS_CODE = 'CANCELLED',
        OBJECT_VERSION_NUMBER = c_visit_rec.object_version_number + 1
    WHERE VISIT_ID = p_visit_id;

    -- ****** cancelled check has to be added to production api
    -- Check if visit project id is null
    -- if not null then update PA_PROJECTS_ALL and set the
    -- project status code to 'CLOSED'
    IF c_visit_rec.PROJECT_ID IS NOT NULL THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_VWP_PROJ_PROD_PVT.Update_Project');
        END IF;

        AHL_VWP_PROJ_PROD_PVT.Update_Project(
                p_api_version           => p_api_version,
                p_init_msg_list         => p_init_msg_list,
                p_commit                => Fnd_Api.g_false,
                p_validation_level      => p_validation_level,
                p_module_type           => p_module_type,
                p_visit_id              => p_visit_id,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data);
        --The following END IF was commented out by jeli on 07/27/04, otherwise it couldn't pass the compilation.

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_VWP_PROJ_PROD_PVT.Update_Project - x_return_status : '||x_return_status);
        END IF;

        IF NVL(x_return_status, 'X') <> Fnd_Api.G_RET_STS_SUCCESS THEN
          -- Method call was not successful, raise error
          Fnd_Message.SET_NAME('AHL','AHL_VWP_PRJ_UPDATE_FAILED'); -- Failed to update job
          Fnd_Msg_Pub.ADD;
          IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string( fnd_log.level_error,'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME,
                            'Cant update the project to Rejected status');
          END IF;
          RAISE Fnd_Api.G_EXC_ERROR;
        END IF;
    END IF;

    -- transit check change
    -- yazhou start
    -- Set SR status back to OPEN if no other active visit has reference to it
    OPEN c_service_request(p_visit_id);
    LOOP
      FETCH c_service_request INTO l_service_request_id;
      EXIT WHEN c_service_request%NOTFOUND;
      -- Check if any other active visits have reference to this SR
      OPEN c_check_SR(p_visit_id,l_service_request_id);
      FETCH c_check_SR into l_dummy;
      IF c_check_SR %NOTFOUND THEN
        -- Set SR status back to OPEN
        OPEN c_sr_ovn(l_service_request_id);
        FETCH c_sr_ovn into c_sr_ovn_rec;
        CLOSE c_sr_ovn;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling CS_ServiceRequest_PUB.Update_Status - SR Id : '||l_service_request_id);
        END IF;
        -- yazhou 29-Jun-2006 starts
        -- bug#5359943
        -- Pass p_status_id as 1 (OPEN)
        CS_ServiceRequest_PUB.Update_Status
           (    p_api_version => 2.0,
                p_init_msg_list => p_init_msg_list,
                p_commit => FND_API.G_FALSE,
                p_resp_appl_id => NULL,
                p_resp_id => NULL,
                p_user_id => NULL,
                p_login_id => NULL,
                p_status_id => 1,
                p_closed_date => NULL,
                p_audit_comments => NULL,
                p_called_by_workflow => FND_API.G_FALSE,
                p_workflow_process_id => NULL,
                p_comments => NULL,
                p_public_comment_flag => FND_API.G_FALSE,
                p_validate_sr_closure => 'N',
                p_auto_close_child_entities => 'N',
                p_request_id => NULL,
                p_request_number => c_sr_ovn_rec.incident_number,
                x_return_status => l_return_status,
                x_msg_count => l_msg_count,
                x_msg_data => l_msg_data,
                p_object_version_number => c_sr_ovn_rec.object_version_number,
--              p_status => 'OPEN',
                x_interaction_id => l_interaction_id
           );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling CS_ServiceRequest_PUB.Update_Status - l_return_status : '||l_return_status);
        END IF;
        -- yazhou 29-Jun-2006 ends
        -- Check return status.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          CLOSE c_check_SR;
          CLOSE c_service_request;
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          CLOSE c_check_SR;
          CLOSE c_service_request;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
      CLOSE c_check_SR;
    END LOOP;
    CLOSE c_service_request;


    ---------------------------End of API Body-------------------------------------
    -- Standard check of p_commit.

    IF Fnd_Api.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    Fnd_Msg_Pub.count_and_get(
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data);

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.end','At the end of PLSQL procedure');
    END IF;
EXCEPTION
   -- SKPATHAK :: Bug 9115894 :: 13-NOV-2009
   WHEN G_VALIDATION_EXCEPTION THEN
      ROLLBACK TO Cancel_Visit;
      x_return_status := G_VALIDATION_ERROR_STATUS ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Cancel_Visit;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Cancel_Visit;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Cancel_Visit;
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

END Cancel_Visit;

----------------------------------------------------------------------
-- END: Defining procedures BODY, which are called from UI screen --
----------------------------------------------------------------------

-- Transit Visit Change
-- yazhou start

--------------------------------------------------------------------
-- PROCEDURE
--    Synchronize_Visit
--
-- PURPOSE
-- Will be called from UA
-- To Synchronize visit with flight schedule change
--------------------------------------------------------------------
PROCEDURE Synchronize_Visit (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type       IN  VARCHAR2  := NULL,
   p_x_visit_rec       IN  OUT NOCOPY Visit_Rec_Type,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
)
IS
  -- Define local Variables
  L_API_VERSION          CONSTANT NUMBER := 1.0;
  L_API_NAME             CONSTANT VARCHAR2(30) := 'Synchronize_Visit';
  L_FULL_NAME            CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
  L_DEBUG            CONSTANT VARCHAR2(90) := 'ahl.plsql.'||L_FULL_NAME;

  l_msg_data             VARCHAR2(2000);
  l_return_status        VARCHAR2(1);
  l_msg_count            NUMBER;

  l_visit_rec            Visit_Rec_Type := p_x_visit_rec;

  -- Define local Cursors

  -- To find visit related information
  CURSOR c_Visit(x_visit_id IN NUMBER) IS
  SELECT * FROM   Ahl_Visits_VL
  WHERE  VISIT_ID = x_visit_id;

  c_Visit_rec    c_Visit%ROWTYPE;
  l_org_id NUMBER;

BEGIN
    --------------------- Initialize -----------------------
    SAVEPOINT Synchronize_Visit;

    -- Check if API is called in debug mode. If yes, enable debug.
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.begin','At the start of PLSQL procedure : Visit Id - '||l_visit_rec.visit_id);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF Fnd_Api.to_boolean(p_init_msg_list) THEN
        Fnd_Msg_Pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
    THEN
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    ------------------------Start of API Body------------------------------------
    OPEN c_Visit(l_visit_rec.visit_id);
    FETCH c_Visit INTO c_Visit_rec;
    IF c_Visit%NOTFOUND THEN
        CLOSE c_Visit;
        IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
            Fnd_Message.set_name('AHL', 'AHL_API_RECORD_NOT_FOUND');
            Fnd_Msg_Pub.ADD;
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(fnd_log.level_statement,L_DEBUG,'Visit not found for - ' ||l_visit_rec.visit_id );
            END IF;
        END IF;
        RAISE Fnd_Api.g_exc_error;
    ELSE
        CLOSE c_Visit;
    END IF;

    -- Complete Visit Record
    p_x_visit_rec.VISIT_TYPE_CODE       := c_Visit_rec.VISIT_TYPE_CODE;
    p_x_visit_rec.SERVICE_REQUEST_ID    := c_Visit_rec.SERVICE_REQUEST_ID;
    p_x_visit_rec.SPACE_CATEGORY_CODE   := c_Visit_rec.SPACE_CATEGORY_CODE;
    p_x_visit_rec.OBJECT_VERSION_NUMBER := c_Visit_rec.OBJECT_VERSION_NUMBER;
    p_x_visit_rec.VISIT_NAME            := c_Visit_rec.VISIT_NAME;
    p_x_visit_rec.DESCRIPTION           := c_Visit_rec.DESCRIPTION;
    p_x_visit_rec.PRIORITY_CODE         := c_Visit_rec.PRIORITY_CODE;
    p_x_visit_rec.PROJ_TEMPLATE_ID      := c_Visit_rec.PROJECT_TEMPLATE_ID;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,'Visit Status : '||c_Visit_rec.status_code);
    END IF;

    IF c_Visit_rec.status_code = 'PLANNING' THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling Update_Visit');
        END IF;

        Update_Visit
        (
            p_api_version             => l_api_version,
            p_init_msg_list           => p_init_msg_list,
            p_commit                  => Fnd_Api.g_false,
            p_validation_level        => p_validation_level,
            p_module_type             => p_module_type,
            p_x_Visit_rec             => p_x_visit_rec,
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data
        );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling Update_Visit - l_return_status : '||l_return_status);
        END IF;

        IF l_return_status <> 'S' THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSIF c_Visit_rec.status_code = 'RELEASED' OR c_Visit_rec.status_code = 'PARTIALLY RELEASED' THEN
        -------------- R12 changes For Serial Number Reservations Start-------------------
        ---------------AnRaj added on 19th June 2005-------------------
        -- R12: Department is made mandatory
        IF  l_visit_rec.department_id IS NULL OR l_visit_rec.department_id = Fnd_Api.G_MISS_NUM THEN
            Fnd_Message.SET_NAME('AHL','AHL_VWP_RELSD_DEPT_MAND');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        -- R12: Department change does not require to cancel current visit and Create a new visit
        -- R12: Removed the Department change check here
        -- If orgnization changed, then cancel the visit and create a new one.
        IF  l_visit_rec.organization_id IS NOT NULL
            AND l_visit_rec.organization_id <> Fnd_Api.G_MISS_NUM
            AND l_visit_rec.organization_id <> c_Visit_rec.organization_id
        THEN
            -- Validate org/dept/dates
            -- Planned Start Date is madatory for transit visit
            IF  l_visit_rec.START_DATE IS NULL
                OR l_visit_rec.START_DATE = FND_API.g_miss_date
            THEN
                Fnd_Message.SET_NAME('AHL','AHL_VWP_TC_ST_DT_REQ');
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- Planned End Date is madatory for transit visit
            IF  l_visit_rec.PLAN_END_DATE IS NULL
                OR  l_visit_rec.PLAN_END_DATE = FND_API.g_miss_date
            THEN
                Fnd_Message.SET_NAME('AHL','AHL_VWP_TC_END_DT_REQ');
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- Planned End Date must be greater than or equal to Planned Start Date
            IF (l_visit_rec.START_DATE > l_visit_rec.PLAN_END_DATE) THEN
                Fnd_Message.SET_NAME('AHL','AHL_VWP_START_DT_GTR_CLOSE_DT');
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- If visit start date is earlier than SYSDATE then use sysdate to create new visit
            IF (l_visit_rec.START_DATE < SYSDATE ) THEN
               l_visit_rec.START_DATE := SYSDATE;
            END IF;

            -- Organization belongs to user's operating unit
            AHL_VWP_RULES_PVT.Check_Org_Name_Or_Id
              (   p_organization_id  => l_visit_rec.organization_id,
                  p_org_name         => null,
                  x_organization_id  => l_org_id,
                  x_return_status    => l_return_status,
                  x_error_msg_code   => l_msg_data);

            l_visit_rec.organization_id := l_org_id;

            IF NVL(l_return_status,'x') <> 'S' THEN
               Fnd_Message.SET_NAME('AHL','AHL_VWP_ORG_NOT_EXISTS');
               Fnd_Msg_Pub.ADD;
               RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- Department must have shift defined
            AHL_VWP_RULES_PVT.CHECK_DEPARTMENT_SHIFT
               (p_dept_id          => l_visit_rec.department_id,
                x_return_status    => l_return_status);

            IF NVL(l_return_status,'x') <> 'S' THEN
               Fnd_Message.SET_NAME('AHL','AHL_VWP_NO_DEPT_SHIFT');
               Fnd_Msg_Pub.ADD;
               RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling COPY_VISIT');
            END IF;

            COPY_VISIT(
                p_api_version             => l_api_version,
                p_init_msg_list           => p_init_msg_list,
                p_commit                  => Fnd_Api.g_false,
                p_validation_level        => p_validation_level,
                p_module_type             => p_module_type,
                P_VISIT_ID                => c_visit_rec.visit_id,
                p_x_Visit_rec             => l_visit_rec,
                x_return_status           => l_return_status,
                x_msg_count               => l_msg_count,
                x_msg_data                => l_msg_data
                );

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling COPY_VISIT l_return_status - '||l_return_status);
            END IF;

            IF l_return_status <> 'S' THEN
                RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_VWP_PROJ_PROD_PVT.Release_Visit');
            END IF;

            AHL_VWP_PROJ_PROD_PVT.Release_Visit (
                p_api_version          => l_api_version,
                p_visit_id             => l_visit_rec.visit_id,
                p_module_type          => 'VWP',
                p_release_flag         =>  NUll,
                p_orig_visit_id        => c_visit_rec.visit_id,
                X_RETURN_STATUS        => l_return_status,
                X_MSG_COUNT            => l_msg_count,
                X_MSG_DATA             => l_msg_data
            );

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_VWP_PROJ_PROD_PVT.Release_Visit : l_return_status - '||l_return_status);
            END IF;

            IF l_return_status <> 'S' THEN
                RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling Cancel_Visit');
            END IF;

            Cancel_Visit
            (
                  p_Visit_id                => c_visit_rec.visit_id,
                  p_obj_ver_num             => c_visit_rec.object_version_number,
                  x_return_status           => l_return_status,
                  x_msg_count               => l_msg_count,
                  x_msg_data                => l_msg_data
            );

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling Cancel_Visit : l_return_status - '||l_return_status);
            END IF;

            IF l_return_status <> 'S' THEN
                RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
            END IF;
       -- The Organization did not change
       -- Only there is change in the date and time of the visit
       -- R12 OR the department has changed., added the condition
       -- R12 AnRaj
        ELSIF       l_visit_rec.START_DATE IS NOT NULL
                AND l_visit_rec.START_DATE <> FND_API.g_miss_date
                AND l_visit_rec.PLAN_END_DATE IS NOT NULL
                AND l_visit_rec.PLAN_END_DATE <> FND_API.g_miss_date
                AND (   l_visit_rec.START_DATE <> c_Visit_rec.START_DATE_TIME
                        OR l_visit_rec.PLAN_END_DATE <> c_Visit_rec.CLOSE_DATE_TIME
                        OR l_visit_rec.department_id <> c_Visit_rec.department_id
                    )
        THEN
        ------------ R12 changes For Serial Number Reservations End-----------------

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling Update_Visit');
            END IF;

            Update_Visit
            (
                p_api_version             => l_api_version,
                p_init_msg_list           => p_init_msg_list,
                p_commit                  => Fnd_Api.g_false,
                p_validation_level        => p_validation_level,
                p_module_type             => p_module_type,
                p_x_Visit_rec             => p_x_visit_rec,
                x_return_status           => l_return_status,
                x_msg_count               => l_msg_count,
                x_msg_data                => l_msg_data
            );

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling Update_Visit - l_return_status : '||l_return_status);
            END IF;

            IF l_return_status <> 'S' THEN
                RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_PRD_WORKORDER_PVT.RESCHEDULE_VISIT_JOBS');
            END IF;

            AHL_PRD_WORKORDER_PVT.RESCHEDULE_VISIT_JOBS(
                P_API_VERSION                  => l_api_version,
                X_RETURN_STATUS                => l_return_status,
                X_MSG_COUNT                    => l_msg_count,
                X_MSG_DATA                     => l_msg_data,
                P_VISIT_ID                     => c_visit_rec.visit_id,
                p_x_scheduled_start_date       => l_visit_rec.START_DATE,
                p_x_scheduled_end_date         => l_visit_rec.PLAN_END_DATE);

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_PRD_WORKORDER_PVT.RESCHEDULE_VISIT_JOBS - l_return_status : '||l_return_status);
            END IF;

            IF l_return_status <> 'S' THEN
                RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF;

    l_msg_count := Fnd_Msg_Pub.count_msg;

    IF l_msg_count > 0 THEN
        X_msg_count := l_msg_count;
        X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Standard check for commit
    IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
        COMMIT;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.end','At the end of PLSQL procedure');
    END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Synchronize_Visit;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Synchronize_Visit;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Synchronize_Visit;
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
END Synchronize_Visit;

-- yazhou end

---------------------------------------------------------------------
-- pbarman begin
-- procedure to delete the Unit Schedule Id from Visits records
--when the Flight schedule is deleted.
---------------------------------------------------------------------
PROCEDURE DELETE_FLIGHT_ASSOC(
 p_unit_schedule_id      IN NUMBER,
 x_return_status     OUT NOCOPY VARCHAR2
)
IS
BEGIN
    SAVEPOINT delete_flight_assoc;

    -- Initialize return status to success initially
    x_return_status:=FND_API.G_RET_STS_SUCCESS;

    UPDATE AHL_VISITS_B
    SET UNIT_SCHEDULE_ID = NULL
    WHERE UNIT_SCHEDULE_ID =  p_unit_schedule_id ;

 EXCEPTION
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO delete_flight_assoc;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO delete_flight_assoc;
        x_return_status := FND_API.G_RET_STS_ERROR;
     WHEN OTHERS THEN
        ROLLBACK TO delete_flight_assoc;
        x_return_status := FND_API.G_RET_STS_ERROR;
END DELETE_FLIGHT_ASSOC;

-- AnRaj added for R 12.0 ACL changes in VWP
-- Bug number 4297066
-------------------------------------------------------------------
--  Procedure name      : check_unit_quarantined
--  Type                : Private
--  Function            : To check whether the Unit is quarantined
--  Parameters          : item_instance_id
----------------------------------------------------------------------
PROCEDURE check_unit_quarantined(
      p_visit_id           IN  NUMBER,
      item_instance_id     IN  NUMBER
      )
IS
  l_api_name    CONSTANT     VARCHAR2(30)   := 'check_unit_quarantined';
  L_FULL_NAME   CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
  L_DEBUG       CONSTANT VARCHAR2(90) := 'ahl.plsql.'||L_FULL_NAME;

  l_unit_name                VARCHAR2(80);
  l_task_number              NUMBER(15);
  l_instance_id              NUMBER;
  l_quarantined              VARCHAR2(1);

  CURSOR c_get_tasknumbers (x_visit_id IN NUMBER) IS
  SELECT   visit_task_number,instance_id
  FROM  ahl_visit_tasks_vl
  WHERE visit_id = x_visit_id
  AND   NVL(STATUS_CODE,'X') NOT IN ('DELETED','RELEASED')
  AND   TASK_TYPE_CODE <> 'SUMMARY';

BEGIN
    -- log at the begining of the procedure
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.begin','At the start of PLSQL procedure - Visit Id : '||p_visit_id||' - '||'item_instance_id : '||item_instance_id);
    END IF;

   IF item_instance_id IS NOT NULL THEN
   -- If the Visit header has an instance id, check for the corresponding Unit
      l_quarantined := ahl_util_uc_pkg.is_unit_quarantined(null,item_instance_id);
      IF l_quarantined = FND_API.G_TRUE THEN
         l_unit_name := ahl_util_uc_pkg.get_unit_name(item_instance_id);
         Fnd_Message.SET_NAME('AHL','AHL_VWP_CLOSE_HDR_UNIT_QRNT');
         -- The Unit for this Visit (UNIT_NAME-1) is quarantined.
         Fnd_Message.Set_Token('UNIT_NAME',l_unit_name);
         Fnd_Msg_Pub.ADD;
         -- log message
         IF (l_log_statement >= l_log_current_level)THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG,l_unit_name || 'Unit is quarantined, Error message added');
         END IF;  -- log
      END IF;  -- l_quarantined not true
   ELSE -- instance id is null
   -- If the visit does not have a unit at the header , then check for the units of all tasks
      OPEN c_get_tasknumbers (p_visit_id);
      LOOP
         FETCH c_get_tasknumbers INTO l_task_number,l_instance_id;
         EXIT WHEN c_get_tasknumbers%NOTFOUND;
         l_quarantined := ahl_util_uc_pkg.is_unit_quarantined(null,l_instance_id);
         IF l_quarantined = FND_API.G_TRUE THEN
            Fnd_Message.SET_NAME('AHL','AHL_VWP_CLOSE_TSK_UNIT_QRNT');
            -- The Unit for the Task (UNIT_NAME-1) is quarantined.
            Fnd_Message.Set_Token('TASK_NUMBER',l_task_number);
            Fnd_Msg_Pub.ADD;
            -- log message
            IF (l_log_statement >= l_log_current_level)THEN
              fnd_log.string(fnd_log.level_statement,L_DEBUG,l_task_number || 'Unit for this task is quarantined.');
            END IF;  -- log
         END IF;  -- l_quarantined not true
      END LOOP;   --  c_get_tasknumbers
   END IF;

   -- log at the end of the procedure
   IF (l_log_procedure >= l_log_current_level) THEN
    fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.end','At the end of PL SQL procedure');
   END IF;
END check_unit_quarantined;

-- SKPATHAK :: Bug 9115894 :: 23-NOV-2009 :: START
-- Added this procedure to get the messages from message stack and store it in a table
PROCEDURE Get_Message_Stack (
    x_message_stack_tbl OUT NOCOPY G_MESSAGE_STACK_TBL
   )
IS
    l_msg_count NUMBER;
    l_msg_data  VARCHAR2(2000);
    l_msg_index_out NUMBER;

BEGIN

    l_msg_count := Fnd_Msg_Pub.count_msg;
     IF (l_msg_count > 0 ) THEN
        FOR i IN 1..l_msg_count
        LOOP
          fnd_msg_pub.get( p_msg_index => i,
                           p_encoded   => FND_API.G_FALSE,
                           p_data      => l_msg_data,
                           p_msg_index_out => l_msg_index_out);

          x_message_stack_tbl(i)  :=  l_msg_data;
          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,'ahl.plsql.AHL_VWP_VISITS_PVT.Get_Message_Stack',
                             'Error - '||l_msg_data);
          END IF;
        END LOOP;
      END IF;

END Get_Message_Stack;

-- Added this procedure to put the messages stored above back to the message stack
PROCEDURE Set_Message_Stack (
    p_message_stack_tbl IN G_MESSAGE_STACK_TBL
   )
IS
l_token VARCHAR2(2000);

BEGIN

    IF (p_message_stack_tbl.COUNT > 0) THEN
      FOR i IN p_message_stack_tbl.FIRST..p_message_stack_tbl.LAST LOOP
	  FND_MESSAGE.SET_NAME('AHL','AHL_LTP_ATP_ERROR');
	  FND_MESSAGE.SET_TOKEN('ERROR',p_message_stack_tbl(i));
	  FND_MSG_PUB.Add;
      END LOOP;
    END IF;

END Set_Message_Stack;
-- SKPATHAK :: Bug 9115894 :: 23-NOV-2009 :: END


END AHL_VWP_VISITS_PVT;

/
