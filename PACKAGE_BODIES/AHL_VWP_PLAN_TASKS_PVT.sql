--------------------------------------------------------
--  DDL for Package Body AHL_VWP_PLAN_TASKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_PLAN_TASKS_PVT" AS
/* $Header: AHLVPLNB.pls 120.9.12010000.5 2010/02/19 12:34:21 tchimira ship $ */
-----------------------------------------------------------
-- PACKAGE
--    AHL_VWP_PLAN_TASKS_PVT
--
-- PURPOSE
--    This package is a Private API for Creating VWP Visit Planned Tasks in
--    CMRO.  It contains specification for pl/sql records and tables
--
--    Create_Planned_Task             (see below for specification)
--    Create_Summary_Child_Tasks      (see below for specification)
--    Asso_Inst_Dept_to_Tasks      (see below for specification)
--    Update_Planned_Task             (see below for specification)
--    Delete_Planned_Task             (see below for specification)
--
-- NOTES
--
--
-- HISTORY
-- 12-MAY_2002    Shbhanda      Created.
-- 21-FEB-2003    YAZHOU        Separated from Task package
-- 06-AUG-2003    SHBHANDA      11.5.10 Changes.

-----------------------------------------------------------
--         Define Global CONSTANTS                  -------
-----------------------------------------------------------
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'AHL_VWP_PLAN_TASKS_PVT';
-----------------------------------------------------------------

------------------------------------------------------------------
--  START: Defining local functions and procedures SIGNATURES     --
--------------------------------------------------------------------
--  To Check_Visit_Task_Req_Items
PROCEDURE Check_Visit_Task_Req_Items (
   p_task_rec        IN    AHL_VWP_RULES_PVT.Task_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
);

--  To Check_Visit_Task_UK_Items
PROCEDURE Check_Visit_Task_UK_Items (
   p_task_rec         IN    AHL_VWP_RULES_PVT.Task_Rec_Type,
   p_validation_mode  IN    VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status    OUT NOCOPY   VARCHAR2
);

--  To Check_Task_Items
PROCEDURE Check_Task_Items (
   p_Task_rec        IN  AHL_VWP_RULES_PVT.task_rec_type,
   p_validation_mode IN  VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);

PROCEDURE create_mr_tasks(
   p_ue_id              IN NUMBER,
   p_parent_ue_id       IN NUMBER,
   p_visit_id           IN NUMBER,
   p_department_id      IN NUMBER,
   p_service_request_id IN NUMBER,
   --SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Pass past dates too
   p_past_task_start_date IN    DATE := NULL,
   p_past_task_end_date IN    DATE := NULL,
   -- Added by rnahata for Issue 105 - pass the qty
   p_quantity           IN NUMBER,
   -- SKPATHAK :: Bug 8343599 :: 14-APR-2009
   p_task_start_date IN    DATE := NULL,
   p_type               IN VARCHAR2
);

-- To Validate_Visit_Task
/*
PROCEDURE Validate_Visit_Task (
   p_api_version      IN  NUMBER,
   p_init_msg_list    IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit           IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_Task_rec         IN  AHL_VWP_RULES_PVT.task_rec_type,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2
);
*/
--  To assign Null to missing attributes of visit while creation/updation.
PROCEDURE Default_Missing_Attribs(
   p_x_task_rec IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type
);

--  To associated Service Request Or Serial Number to Tasks
PROCEDURE Asso_Inst_Dept_to_Tasks (
   p_module_type IN   VARCHAR2,
   p_x_task_Rec  IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type
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
         IF  p_x_task_rec.DURATION = Fnd_Api.G_MISS_NUM THEN
            p_x_task_rec.DURATION := NULL;
         ELSE
            p_x_task_rec.DURATION := p_x_task_rec.DURATION;
         END IF;

         IF  p_x_task_rec.PROJECT_TASK_ID = Fnd_Api.G_MISS_NUM THEN
            p_x_task_rec.PROJECT_TASK_ID := NULL;
         ELSE
            p_x_task_rec.PROJECT_TASK_ID := p_x_task_rec.PROJECT_TASK_ID;
         END IF;

         IF  p_x_task_rec.COST_PARENT_ID = Fnd_Api.G_MISS_NUM THEN
            p_x_task_rec.COST_PARENT_ID := NULL;
         ELSE
            p_x_task_rec.COST_PARENT_ID := p_x_task_rec.COST_PARENT_ID;
         END IF;

         IF  p_x_task_rec.MR_ROUTE_ID = Fnd_Api.G_MISS_NUM THEN
            p_x_task_rec.MR_ROUTE_ID := NULL;
         ELSE
            p_x_task_rec.MR_ROUTE_ID := p_x_task_rec.MR_ROUTE_ID;
         END IF;

         IF  p_x_task_rec.MR_ID = Fnd_Api.G_MISS_NUM THEN
            p_x_task_rec.MR_ID := NULL;
         ELSE
            p_x_task_rec.MR_ID := p_x_task_rec.MR_ID;
         END IF;

         IF  p_x_task_rec.UNIT_EFFECTIVITY_ID = Fnd_Api.G_MISS_NUM THEN
            p_x_task_rec.UNIT_EFFECTIVITY_ID := NULL;
         ELSE
            p_x_task_rec.UNIT_EFFECTIVITY_ID := p_x_task_rec.UNIT_EFFECTIVITY_ID;
         END IF;

         IF  p_x_task_rec.START_FROM_HOUR = Fnd_Api.G_MISS_NUM THEN
            p_x_task_rec.START_FROM_HOUR := NULL;
         ELSE
            p_x_task_rec.START_FROM_HOUR := p_x_task_rec.START_FROM_HOUR;
         END IF;

         IF  p_x_task_rec.PRIMARY_VISIT_TASK_ID = Fnd_Api.G_MISS_NUM THEN
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

         IF  p_x_task_rec.attribute_category = Fnd_Api.G_MISS_CHAR THEN
            p_x_task_rec.attribute_category := NULL;
         ELSE
            p_x_task_rec.attribute_category := p_x_task_rec.attribute_category;
         END IF;
         --
         IF  p_x_task_rec.attribute1 = Fnd_Api.G_MISS_CHAR THEN
            p_x_task_rec.attribute1 := NULL;
         ELSE
            p_x_task_rec.attribute1 := p_x_task_rec.attribute1;
         END IF;
         --
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

         IF  p_x_task_rec.STAGE_NAME = Fnd_Api.G_MISS_CHAR THEN
            p_x_task_rec.STAGE_NAME := NULL;
         ELSE
            p_x_task_rec.STAGE_NAME := p_x_task_rec.STAGE_NAME;
         END IF;

END Default_Missing_Attribs;

--------------------------------------------------------------------
-- PROCEDURE
--    Asso_Inst_Dept_to_Tasks
--
--------------------------------------------------------------------
PROCEDURE Asso_Inst_Dept_to_Tasks
(
   p_module_type IN            VARCHAR2,
   p_x_task_Rec  IN OUT NOCOPY AHL_VWP_RULES_PVT.task_rec_type
)
IS
   L_API_NAME  CONSTANT VARCHAR2(30) := 'Asso_Inst_Dept_to_Tasks';
   L_FULL_NAME CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   L_DEBUG     CONSTANT VARCHAR2(90) := 'ahl.plsql.'||L_FULL_NAME;

   -- local variables defined for the procedure
   l_return_status      VARCHAR2(1);
   l_chk_flag           VARCHAR2(1);
   l_msg_data           VARCHAR2(2000);
   l_msg_count          NUMBER;

   -- To find visit related information
   CURSOR c_visit(x_id IN NUMBER) IS
    SELECT * FROM AHL_VISITS_VL
    WHERE VISIT_ID = x_id;
   c_visit_rec  c_visit%ROWTYPE;

BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.begin','At the start of PL SQL procedure ');
  END IF;

  --------------------Value OR ID conversion---------------------------
  --Start API Body
  IF p_module_type = 'JSP' THEN
       p_x_task_Rec.instance_id   := NULL;
       p_x_task_Rec.department_id := NULL;
  END IF;

  OPEN c_visit(p_x_task_Rec.visit_id);
  FETCH c_visit INTO c_visit_rec;
  CLOSE c_visit;

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

        IF NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
          Fnd_Message.SET_NAME('AHL','AHL_VWP_DEPT_NOT_EXISTS');
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        -- Changes for Post 11.5.10 by amagrawa
        AHL_VWP_RULES_PVT.CHECK_DEPARTMENT_SHIFT
            (P_DEPT_ID    => p_x_task_Rec.department_id,
             X_RETURN_STATUS  => l_return_status);

        IF (NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS)  THEN
            Fnd_Message.SET_NAME('AHL','AHL_VWP_NO_DEPT_SHIFT');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;
    ELSE
        p_x_task_Rec.dept_name     := NULL;
        -- Post 11.5.10 Changes by Senthil.
        -- Fixed as per bug # 4073163
        --p_x_task_Rec.department_id := c_visit_rec.department_id;
        p_x_task_Rec.department_id := NULL;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,L_DEBUG,' Dept ID= ' || p_x_task_Rec.department_id);
    END IF;
  ELSE  -- Else of if visit org not exists
    IF (p_x_task_Rec.dept_name IS NOT NULL AND p_x_task_Rec.dept_name <> Fnd_Api.G_MISS_CHAR ) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,L_DEBUG,' NO ORGANIZATION FOR VISIT');
      END IF;
      Fnd_Message.SET_NAME('AHL','AHL_VWP_VISIT_NO_ORG_EXISTS');
      Fnd_Msg_Pub.ADD;
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;
  END IF; -- End of if visit org exists

/*Convert service request number to service request id
  IF (p_x_task_Rec.service_request_number IS NOT NULL AND p_x_task_Rec.service_request_number <> Fnd_Api.G_MISS_CHAR ) THEN
    AHL_VWP_RULES_PVT.Check_SR_Request_Number_Or_Id
         (p_service_id       => Null,
          p_service_number   => p_x_task_Rec.service_request_number,
          x_service_id       => p_x_task_Rec.service_request_id,
          x_return_status    => l_return_status,
          x_error_msg_code   => l_msg_data);

    IF NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
      Fnd_Message.SET_NAME('AHL','AHL_VWP_SERVICE_REQ_NOT_EXISTS');
      Fnd_Msg_Pub.ADD;
      RAISE Fnd_Api.g_exc_error;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,'ahl.plsql.', l_full_name ||': Service ID= ' || p_x_task_Rec.service_request_id);
    END IF;
  ELSE
    p_x_task_Rec.service_request_id     := NULL;
    p_x_task_Rec.service_request_number := NULL;
  END IF;
*/

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.end','At the end of PL SQL procedure ');
  END IF;

END Asso_Inst_Dept_to_Tasks;

PROCEDURE Create_Planned_Task (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2  := 'JSP',
   p_x_task_Rec           IN OUT NOCOPY AHL_VWP_RULES_PVT.task_rec_type,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
)
IS
   L_API_VERSION          CONSTANT NUMBER := 1.0;
   L_API_NAME             CONSTANT VARCHAR2(30) := 'Create_Planned_Task';
   L_FULL_NAME            CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   L_DEBUG                CONSTANT VARCHAR2(90) := 'ahl.plsql.'||L_FULL_NAME;

   -- local variables defined for the procedure
   l_msg_data             VARCHAR2(2000);
   l_return_status        VARCHAR2(1);
   l_check_flag           VARCHAR2(1);

   l_visit_id             NUMBER;
   l_parent_task_id       NUMBER;
   l_temp_parent_task_id  NUMBER;
   l_service_req_id       NUMBER;
   l_department_id        NUMBER;
   l_unit_effectivity_id  NUMBER;
   l_msg_count            NUMBER;
   l_serial_id            NUMBER;
   l_org_id               NUMBER;
   l_item_id              NUMBER;
   l_MR_route_id          NUMBER;
   l_mr_id                NUMBER;
   l_task_id              NUMBER;
   l_parent_mr_id         NUMBER;
   l_header_id            NUMBER;
   l_unit_id              NUMBER;
   l_parent_unit_id       NUMBER;
   l_visit_number         NUMBER;
   l_object_type          VARCHAR2(3);
   l_count                NUMBER;
   l_workflow_process_id  NUMBER;
   l_incident_id          NUMBER;

   --SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Added two local variables
   l_past_task_start_date DATE;
   l_past_task_end_date   DATE;

   -- AnRaj: changed for Fixing Siberian Airlines Bug#5007335
   l_incident_number       CS_INCIDENTS_ALL_B.INCIDENT_NUMBER%TYPE;
   l_object_version_number CS_INCIDENTS_ALL_B.OBJECT_VERSION_NUMBER%TYPE;
   l_incident_status_id    CS_INCIDENTS_ALL_B.INCIDENT_ID%TYPE;
   -- End Of Fix Bug#5007335

   l_status_name       cs_incident_statuses_tl.name%type;
   l_interaction_id    NUMBER;
   l_service_request_rec   CS_SERVICEREQUEST_PUB.service_request_rec_type;
   l_contacts_table        CS_ServiceRequest_PUB.contacts_table;
   l_notes_table           CS_ServiceRequest_PUB.notes_table;

   i  NUMBER:=0;
   k  NUMBER:=0;
   x  NUMBER:=0;
   y  NUMBER:=0;
   l_dummy varchar2(1);

   -- To find on the basis of input unit effectivity the related information
   CURSOR c_info(x_mr_header_id IN NUMBER, x_unit_id IN NUMBER) IS
      SELECT AUEB.CSI_ITEM_INSTANCE_ID
      FROM   AHL_UNIT_EFFECTIVITIES_VL AUEB, CSI_ITEM_INSTANCES CSI
      WHERE  AUEB.CSI_ITEM_INSTANCE_ID = CSI.INSTANCE_ID
      AND    (AUEB.STATUS_CODE IS NULL OR AUEB.STATUS_CODE = 'INIT-DUE')
      AND    AUEB.UNIT_EFFECTIVITY_ID = x_unit_id AND AUEB.MR_HEADER_ID = x_mr_header_id;

   -- To find all Unit Effectvities i.e main root UEId, if any parent UEIds or
   -- any child UEIds under it which acts as SUMMARY TASK
   /* For Bug# 3152532 fix by shbhanda dated 02-Dec-03
      Modified the query to fetch same result Dec 20 2003 sjayacha */
   CURSOR c_relation (x_ue_id IN NUMBER) IS
      SELECT AUR.RELATED_UE_ID "UNIT_ID"
      FROM   AHL_UE_RELATIONSHIPS AUR
      START WITH AUR.UE_ID IN (SELECT AUEB.unit_effectivity_id
                               FROM   AHL_UNIT_EFFECTIVITIES_VL AUEB
                               WHERE  (AUEB.STATUS_CODE IS NULL OR AUEB.STATUS_CODE = 'INIT-DUE')
                               AND    AUEB.unit_effectivity_id = x_ue_id
                              )
      CONNECT BY PRIOR AUR.RELATED_UE_ID = AUR.UE_ID;
     c_relation_rec c_relation%ROWTYPE;

   -- Added by sjayacha for Servie Request Integration
   -- To check whether any child UE exists
   CURSOR c_check_child_ue(p_ue_id IN NUMBER) IS
     SELECT  'X'
     FROM     ahl_ue_relationships AUR, ahl_unit_effectivities_vl AUEB
     WHERE    AUR.ue_id = AUEB.unit_effectivity_id
     AND      (AUEB.status_code IS NULL OR AUEB.status_code = 'INIT-DUE')
     AND      AUR.ue_id = p_ue_id;

   -- To find MR Header Id for any related Sub Unit Effectivity Id
   -- or for main Unit Effectivity Id
   CURSOR c_header (x_unit_id IN NUMBER) IS
      /*SELECT MR_HEADER_ID
      FROM AHL_UNIT_EFFECTIVITIES_VL AUEB
      WHERE (STATUS_CODE IS NULL OR STATUS_CODE IN ('INIT-DUE', 'DEFERRED'))
      AND UNIT_EFFECTIVITY_ID = x_unit_id;*/
      /* For Bug# 3152532 fix by shbhanda dated 02-Dec-03*/
      SELECT   AUEB.MR_HEADER_ID
      FROM     AHL_UNIT_EFFECTIVITIES_VL AUEB, AHL_MR_HEADERS_B AMHB
      WHERE    AUEB.MR_HEADER_ID = AMHB.MR_HEADER_ID
      AND      AMHB.MR_STATUS_CODE = 'COMPLETE'
      AND      AMHB.VERSION_NUMBER IN
                       ( SELECT  MAX(VERSION_NUMBER)
                         FROM    AHL_MR_HEADERS_B
                         WHERE   TITLE = AMHB.TITLE
                         AND     TRUNC(SYSDATE)
                         BETWEEN TRUNC(EFFECTIVE_FROM)
                         AND     TRUNC(NVL(EFFECTIVE_TO,SYSDATE+1))
                         AND     MR_STATUS_CODE = 'COMPLETE'
                       )
      AND      (AUEB.STATUS_CODE IS NULL OR AUEB.STATUS_CODE = 'INIT-DUE')
      AND      AUEB.UNIT_EFFECTIVITY_ID = x_unit_id;
      c_header_rec c_header%ROWTYPE;

   -- Record type for storing all Maintainence Requirement n Unit Effectivity
   TYPE MR_Header_Rec_Type IS RECORD
   (
      Unit_Effect_ID          NUMBER,
      MR_Header_ID            NUMBER
   );

   -- Table type for storing all Maintainence Requirement n Unit Effectivity
   TYPE MR_Header_Tbl_Type IS TABLE OF MR_Header_Rec_Type
   INDEX BY BINARY_INTEGER;

   -- Table type for storing 'MR_Serial_Rec_Type' record datatype
   MR_Header_Tbl    MR_Header_Tbl_Type;
   MR_Serial_Tbl    AHL_VWP_RULES_PVT.MR_Serial_Tbl_Type;

   -- To find visit related information
   CURSOR c_Visit (p_visit_id IN NUMBER) IS
      SELECT Any_Task_Chg_Flag, Visit_Id
      FROM   Ahl_Visits_VL
      WHERE  VISIT_ID = p_visit_id;
   l_visit_csr_rec  c_Visit%ROWTYPE;

   -- To find if this Unit has been planned in other visits already
   CURSOR c_unit (x_unit_id IN NUMBER) IS
      SELECT VISIT_NUMBER
      FROM   AHL_VISITS_B
      WHERE  VISIT_ID IN (  SELECT   DISTINCT VISIT_ID
                            FROM     AHL_VISIT_TASKS_B
                            WHERE    Unit_Effectivity_Id = x_unit_id
                         )
      and    status_code not in ('CANCELLED','DELETED');

   CURSOR c_unit_object_type(p_unit_id IN NUMBER)
   IS
      SELECT   OBJECT_TYPE
      FROM     AHL_UNIT_EFFECTIVITIES_VL
      WHERE    UNIT_EFFECTIVITY_ID =  p_unit_id;

   -- To find the Item Id, Inv Org Id and Serial Number
   CURSOR c_item_info(p_unit_id IN NUMBER) IS
      SELECT   AUEB.CSI_ITEM_INSTANCE_ID,
               AUEB.CS_INCIDENT_ID,
               CSI.INV_MASTER_ORGANIZATION_ID,
               CSI.INVENTORY_ITEM_ID
       FROM    AHL_UNIT_EFFECTIVITIES_VL AUEB, CSI_ITEM_INSTANCES CSI
       WHERE   AUEB.CSI_ITEM_INSTANCE_ID = CSI.INSTANCE_ID
       AND     (AUEB.STATUS_CODE IS NULL OR AUEB.STATUS_CODE = 'INIT-DUE')
       AND     AUEB.UNIT_EFFECTIVITY_ID = p_unit_id ;

   CURSOR c_service_details(P_service_id IN NUMBER)
   IS
      SELECT   INCIDENT_ID,
               INCIDENT_NUMBER,
               OBJECT_VERSION_NUMBER
      FROM     CS_INCIDENTS_ALL_B
      WHERE    INCIDENT_ID=P_service_id;

   -- AnRaj:Changed cursor for issues mentioned in bug#5007335
   CURSOR c_service_status
   IS
      select   incident_status_id,
               name
      from     cs_incident_statuses_tl
     -- where name = 'Planned';
      where    incident_status_id = 52
      and      language = userenv('lang');

/*NR-MR Changes - sowsubra */
CURSOR c_task_for_ue(p_visit_id IN NUMBER, p_ue_id IN NUMBER)
IS
  SELECT  visit_task_id
  FROM    ahl_visit_tasks_b
  WHERE visit_id = p_visit_id
  AND   unit_effectivity_id = p_ue_id
  AND   NVL(status_code,'Y') <> 'DELETED';

/* Cursor added by rnahata for Bug 6939329 */
CURSOR c_task_id_for_ue(c_visit_id IN NUMBER, c_ue_id IN NUMBER) IS
  SELECT visit_task_id
  FROM   ahl_visit_tasks_b
  WHERE  visit_id = c_visit_id
  AND    unit_effectivity_id = c_ue_id
  AND    NVL(status_code, 'PLANNING') <> 'DELETED'
  AND    TASK_TYPE_CODE = 'SUMMARY';

BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Create_Planned_Task;

   -- Debug info.
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_procedure, L_DEBUG||'.begin','At the start of PLSQL procedure');
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

   --SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Populate the values from input record to local variables
   l_past_task_start_date := p_x_task_Rec.past_task_start_date;
   l_past_task_end_date   := p_x_task_Rec.past_task_end_date;


   -- Calling Asso_Inst_Dept_to_Tasks API
   Asso_Inst_Dept_to_Tasks (
     p_module_type    => p_module_type,
     p_x_task_Rec     => p_x_task_Rec
   );

   -- Assigning record attributes in local variables
   l_visit_id             := p_x_task_Rec.visit_id;
   l_service_req_id       := p_x_task_Rec.service_request_id;
   l_department_id        := p_x_task_Rec.department_id;
   l_unit_effectivity_id  := p_x_task_Rec.unit_effectivity_id;

   IF l_department_id = FND_API.g_miss_num THEN
      l_department_id := NULL;
   END IF;

   -- Cursor to retrieve visit info
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_statement, L_DEBUG,'Visit Id: Unit Effe Id ' || l_visit_id || '-' || l_unit_effectivity_id);
    fnd_log.string(fnd_log.level_statement, L_DEBUG ,'Service Req Id: Department Id:' || l_service_req_id || '-' || l_department_id);
   END IF;

   IF l_unit_effectivity_id IS NOT NULL THEN
      OPEN c_unit (l_unit_effectivity_id);
      FETCH c_unit INTO l_visit_number;

      -- If this UE has already been planned in some other Visit
      /*NR-MR Changes - sowsubra */
      /*It is possible to update the SR with more MR's added through backward flow.(Included the
      condition p_module_type <> 'SR')*/
      IF c_unit%FOUND AND p_module_type <> 'SR' THEN
        CLOSE c_unit;
        -- ERROR MESSAGE
        x_return_status := Fnd_Api.g_ret_sts_error;
        Fnd_Message.SET_NAME('AHL','AHL_VWP_UNIT_FOUND');
        Fnd_Message.SET_TOKEN('VISIT_NUMBER', l_visit_number);
        Fnd_Msg_Pub.ADD;
      ELSE -- UE not planned in any other Visit
        CLOSE c_unit;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement, L_DEBUG,'Unit effectivity' || l_unit_effectivity_id);
        END IF;

        -- Get the Object_type code to check whether it is SR or MR.
        OPEN c_unit_object_type (l_unit_effectivity_id);
        FETCH c_unit_object_type INTO l_object_type;
        CLOSE c_unit_object_type;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement,L_DEBUG, 'Before l_object_type check' );
        END IF;

        IF l_object_type = 'MR' THEN
           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(fnd_log.level_statement,L_DEBUG, 'Before calling create_mr_tasks');
              fnd_log.string(fnd_log.level_statement,L_DEBUG, 'ue id              =>' || l_unit_effectivity_id);
              fnd_log.string(fnd_log.level_statement,L_DEBUG, 'parent ue id       =>' || 'null');
              fnd_log.string(fnd_log.level_statement,L_DEBUG, 'visit id           =>' || l_visit_id);
              fnd_log.string(fnd_log.level_statement,L_DEBUG, 'department id      =>' || l_department_id);
              fnd_log.string(fnd_log.level_statement,L_DEBUG, 'service_request id =>' || l_service_req_id);
              fnd_log.string(fnd_log.level_statement,L_DEBUG, 'quantity           =>' || p_x_task_Rec.quantity);
           END IF;

           create_mr_tasks(p_ue_id              => l_unit_effectivity_id,
                           p_parent_ue_id       => null,
                           p_visit_id           => l_visit_id,
                           p_department_id      => l_department_id,
                           p_service_request_id => l_service_req_id,
                           --SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Pass past dates too
                           p_past_task_start_date => l_past_task_start_date,
                           p_past_task_end_date => l_past_task_end_date,
                           -- Added by rnahata for Issue 105 - pass the qty
                           p_quantity           => p_x_task_Rec.quantity,
                           p_type               => 'MR'
                          );

        -- if object type is SR
        ELSIF l_object_type = 'SR' THEN
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'l_object_type = SR');
          END IF;
          -- Get the details of the UE
          OPEN  c_item_info (l_unit_effectivity_id);
          FETCH c_item_info INTO l_serial_id,l_service_req_id,l_org_id,l_item_id;
          CLOSE c_item_info;

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
             fnd_log.string(fnd_log.level_statement,L_DEBUG, 'Before calling AHL_VWP_RULES_PVT.Insert_Tasks');
             fnd_log.string(fnd_log.level_statement,L_DEBUG, 'ue_id              =>' || l_unit_effectivity_id);
             fnd_log.string(fnd_log.level_statement,L_DEBUG, 'parent ue id       =>' || 'null');
             fnd_log.string(fnd_log.level_statement,L_DEBUG, 'visit id           =>' || l_visit_id);
             fnd_log.string(fnd_log.level_statement,L_DEBUG, 'department id      =>' || l_department_id);
             fnd_log.string(fnd_log.level_statement,L_DEBUG, 'service request id =>' || l_service_req_id);
             fnd_log.string(fnd_log.level_statement,L_DEBUG, 'quantity           =>' || p_x_task_Rec.quantity);
          END IF;

          OPEN c_task_for_ue(l_visit_id, l_unit_effectivity_id);
          FETCH c_task_for_ue INTO l_parent_task_id;
          /*NR-MR Changes - sowsubra*/
          --Call Insert_Tasks only if summary task for the SR has not already been created.
          IF c_task_for_ue%NOTFOUND THEN
            AHL_VWP_RULES_PVT.Insert_Tasks
                  (p_visit_id      => l_visit_id,
                   p_unit_id       => l_unit_effectivity_id,
                   p_serial_id     => l_serial_id,
                   p_service_id    => l_service_req_id,
                   p_dept_id       => l_department_id,
                   p_item_id       => l_item_id,
                   p_item_org_id   => l_org_id,
                   p_mr_id         => NULL,
                   p_mr_route_id   => NULL,
                   /* NR-MR Changes - sowsubra - Make the originating workorder as the originating task of NR Summary task*/
                   p_parent_id     => p_x_task_Rec.ORIGINATING_TASK_ID,
                   p_flag          => 'Y',
                   -- Added by rnahata for Issue 105 - pass the qty for summary task created for the SR
                   p_quantity      => p_x_task_Rec.quantity,
                   -- SKPATHAK :: Bug 8343599 :: 14-APR-2009
                   p_task_start_date => p_x_task_Rec.task_start_date,
                   x_task_id       => l_parent_task_id,
                   x_return_status => l_return_status,
                   x_msg_count     => l_msg_count,
                   x_msg_data      => l_msg_data
                   );

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(fnd_log.level_statement,L_DEBUG, 'After AHL_VWP_RULES_PVT.Insert_Tasks for Planned Task');
              fnd_log.string(fnd_log.level_statement,L_DEBUG, 'l_return_status' || l_return_status);
            END IF;

            IF NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
               CLOSE c_task_for_ue; -- NR-MR Changes - sowsubra
               RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
            /*NR-MR Changes - sowsubra*/
          END IF; --c_task_for_ue%NOTFOUND
          CLOSE c_task_for_ue;

          -- Check if any valid child UE exist
          OPEN  c_check_child_ue(l_unit_effectivity_id);
          FETCH c_check_child_ue INTO l_dummy;
          IF c_check_child_ue%FOUND THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string(fnd_log.level_statement,L_DEBUG, 'Before calling create_mr_tasks');
                fnd_log.string(fnd_log.level_statement,L_DEBUG, 'c_check_child_ue%FOUND is TRUE');
                fnd_log.string(fnd_log.level_statement,L_DEBUG, 'ue id =>' || l_unit_effectivity_id);
                fnd_log.string(fnd_log.level_statement,L_DEBUG, 'parent ue id =>' || l_parent_task_id);
                fnd_log.string(fnd_log.level_statement,L_DEBUG, 'visit id =>' || l_visit_id);
                fnd_log.string(fnd_log.level_statement,L_DEBUG, 'department id =>' || l_department_id);
                fnd_log.string(fnd_log.level_statement,L_DEBUG, 'service request id =>' || l_service_req_id);
                fnd_log.string(fnd_log.level_statement,L_DEBUG, 'quantity =>' || p_x_task_Rec.quantity);
	    END IF;
            -- The New API which would recursively create tasks for all the MRs which are the children of the SR
            -- the Task id returned by Insert_Tasks is passed as the parent id here
            create_mr_tasks(p_ue_id                => l_unit_effectivity_id,
                            p_parent_ue_id         => l_parent_task_id,
                            p_visit_id             => l_visit_id,
                            p_department_id        => l_department_id,
                            p_service_request_id   => l_service_req_id,
			    -- TCHIMIRA:: BUG 9390878 :: 19-FEB-2010 :: pass past task dates for SR
			    p_past_task_start_date => p_x_task_Rec.past_task_start_date,
                            p_past_task_end_date => p_x_task_Rec.past_task_end_date,
                            -- Added by rnahata for Issue 105 - pass the qty for SR
                            p_quantity             => p_x_task_Rec.quantity,
                            -- SKPATHAK :: Bug 8343599 :: 14-APR-2009
                            p_task_start_date      =>    p_x_task_Rec.task_start_date,
                            p_type                 => 'SR'
                           );

          ELSE  -- No Child UEs
            -- Create one Summary Task and a Planned Task

            -- NR-MR Changes - sowsubra
            -- Done to allow creation of a task for an instance that has already been removed.
            /***
            IF AHL_VWP_RULES_PVT.instance_in_config_tree(l_visit_id, l_serial_id) = FND_API.G_RET_STS_ERROR THEN
              Fnd_Message.SET_NAME('AHL','AHL_VWP_TASK_SERIAL');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.G_EXC_ERROR;
            END IF; ***/

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
               fnd_log.string(fnd_log.level_statement,L_DEBUG, 'Inside No Child UEs ELSE BLOCK');
               fnd_log.string(fnd_log.level_statement,L_DEBUG, 'Before calling AHL_VWP_RULES_PVT.Insert_Tasks for Planned Task');
            END IF;

            -- Create a Planned Task
            AHL_VWP_RULES_PVT.Insert_Tasks
                  (p_visit_id      => l_visit_id,
                   p_unit_id       => l_unit_effectivity_id,
                   p_serial_id     => l_serial_id,
                   p_service_id    => l_service_req_id,
                   p_dept_id       => l_department_id,
                   p_item_id       => l_item_id,
                   p_item_org_id   => l_org_id,
                   p_mr_id         => null,
                   p_mr_route_id   => NULL,
                   p_parent_id     => l_parent_task_id,
                   p_flag          => 'N',
		   -- TCHIMIRA:: BUG 9390878 :: 19-FEB-2010 :: pass past task dates for SR
                   p_past_task_start_date => p_x_task_Rec.past_task_start_date,
                   p_past_task_end_date => p_x_task_Rec.past_task_end_date,
                   /* Added by rnahata for Issue 105 - pass the qty as 0 for
                   the planned task created when there are no MR's associated to the SR*/
                   p_quantity      => p_x_task_Rec.quantity,
                   -- SKPATHAK :: Bug 8343599 :: 14-APR-2009
                   p_task_start_date => p_x_task_Rec.task_start_date,
                   x_task_id       => l_task_id,
                   x_return_status => l_return_status,
                   x_msg_count     => l_msg_count,
                   x_msg_data      => l_msg_data
                   );

              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string(fnd_log.level_statement,L_DEBUG, 'After AHL_VWP_RULES_PVT.Insert_Tasks for Planned Task - l_return_status : '|| l_return_status);
              END IF;

              IF NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE Fnd_Api.G_EXC_ERROR;
              END IF;
          END IF; -- Child UE Check

          -- Call Service Request package to update the status.
          --CS_SERVICEREQUEST_PUB.Update_ServiceRequest
          OPEN c_service_details(l_service_req_id);
          FETCH c_service_details into l_incident_id,l_incident_number,l_object_version_number;
          CLOSE c_service_details;

          OPEN c_service_status;
          FETCH c_service_status into l_incident_status_id,l_status_name;
          CLOSE c_service_status;

          CS_SERVICEREQUEST_PUB.initialize_rec(l_service_request_rec);

          -- Assign the SR rec values
          l_service_request_rec.status_id        := l_incident_status_id;
          --l_service_request_rec.status_name      := l_status_name;
          /*
          CS_SERVICEREQUEST_PUB.Update_ServiceRequest(
                 p_api_version            => 3.0,
                 p_init_msg_list          => FND_API.G_TRUE,
                 p_commit                 => FND_API.G_FALSE,
                 x_return_status          => x_return_status,
                 x_msg_count              => l_msg_count,
                 x_msg_data               => l_msg_data,
                 p_request_id             => l_incident_id,
                 --p_request_number         => l_incident_number,
                 p_request_number         => NUll,
                 p_audit_comments         => Null,
                 p_object_version_number  => l_object_version_number,
                 p_resp_appl_id           => NULL,
                 p_resp_id                => NULL,
                 p_last_updated_by        => NULL,
                 p_last_update_login      => NULL,
                 p_last_update_date       => NULL,
                 p_service_request_rec    => l_service_request_rec,
                 p_notes                  => l_notes_table,
                 p_contacts               => l_contacts_table,
                 p_called_by_workflow     => NULL,
                 p_workflow_process_id    => NULL,
                 x_workflow_process_id    => l_workflow_process_id,
                 x_interaction_id         => l_interaction_id
               );
            */

          -- Check Error Message stack.
          x_msg_count := FND_MSG_PUB.count_msg;
          IF x_msg_count > 0 THEN
            RAISE  FND_API.G_EXC_ERROR;
          END IF;

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'Before CS_ServiceRequest_PUB.Update_Status ');
          END IF;
          -- anraj changed the api
          CS_ServiceRequest_PUB.Update_Status
              (
               p_api_version => 2.0,
               p_init_msg_list => FND_API.G_TRUE,
               p_commit => FND_API.G_FALSE,
               p_resp_appl_id => NULL,
               p_resp_id => NULL,
               p_user_id => NULL,
               p_login_id => NULL,
               p_status_id => 52,
               p_closed_date => NULL,
               p_audit_comments => NULL,
               p_called_by_workflow => FND_API.G_FALSE,
               p_workflow_process_id => NULL,
               p_comments => NULL,
               p_public_comment_flag => FND_API.G_FALSE,
               p_validate_sr_closure => 'N',
               p_auto_close_child_entities => 'N',
               p_request_id => l_incident_id,
               p_request_number => NULL,
               x_return_status => x_return_status,
               x_msg_count => l_msg_count,
               x_msg_data => l_msg_data,
               p_object_version_number => l_object_version_number,
               p_status => NULL,
               x_interaction_id => l_interaction_id
              );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'After CS_ServiceRequest_PUB.Update_Status -  Return Status - '||x_return_status );
          END IF;

          IF NVL(x_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE Fnd_Api.G_EXC_ERROR;
          ELSE
            Fnd_Msg_Pub.initialize;
          END IF;
        END IF;   -- SR/MR
        /* Added by rnahata for Bug 6939329 */
        OPEN c_task_id_for_ue(l_visit_id, l_unit_effectivity_id);
        FETCH c_task_id_for_ue INTO p_x_task_Rec.visit_task_id;
        CLOSE c_task_id_for_ue;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement, L_DEBUG, 'p_x_task_Rec.visit_task_id = ' || p_x_task_Rec.visit_task_id);
        END IF;
        /* End changes by rnahata for Bug 6939329 */
      END IF; -- c_unit%FOUND
   ELSE -- l_unit_effectivity_id
      Fnd_Message.SET_NAME('AHL','AHL_VWP_NO_UNIT_EFFECTIVITY');
      Fnd_Msg_Pub.ADD;
      RAISE  FND_API.G_EXC_ERROR;
   END IF;  -- End of unit effectivity check

   OPEN C_VISIT(l_visit_id);
   fetch c_visit into l_visit_csr_rec;
   IF C_VISIT%FOUND THEN
      IF l_visit_csr_rec.Any_Task_Chg_Flag='N' THEN
         AHL_VWP_RULES_PVT.update_visit_task_flag(
            p_visit_id      =>l_visit_csr_rec.visit_id,
            p_flag          =>'Y',
            x_return_status =>x_return_status);
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         CLOSE C_VISIT;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   CLOSE C_VISIT;

   ------------------------- finish -------------------------------
   -- Standard call to get message count and if count is 1, get message info
   Fnd_Msg_Pub.count_and_get
   (
      p_encoded => Fnd_Api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
   );

   -- Check Error Message stack.
   x_msg_count := FND_MSG_PUB.count_msg;
   IF x_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
   END IF;

   -- Standard check of p_commit.
   IF Fnd_Api.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.end','At the end of PLSQL procedure');
   END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Create_Planned_Task;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get(
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Create_Planned_Task;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Planned_Task;
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
END Create_Planned_Task;

-------------------------------------------------------------------------
-- PROCEDURE
--    create_mr_tasks
-- AnRaj: Created
-- PURPOSE
--    Seperates the Task creating functionality from Create_Planned_Task
-------------------------------------------------------------------------
PROCEDURE create_mr_tasks(p_ue_id              IN NUMBER,
                          p_parent_ue_id       IN NUMBER,
                          p_visit_id           IN NUMBER,
                          p_department_id      IN NUMBER,
                          p_service_request_id IN NUMBER,
                          --SKPATHAK :: ER: 9147951 :: 11-JAN-2010
                          p_past_task_start_date IN    DATE := NULL,
                          p_past_task_end_date IN    DATE := NULL,
                          -- Added by rnahata for Issue 105
                          p_quantity           IN NUMBER,
                          -- SKPATHAK :: Bug 8343599 :: 14-APR-2009
                          p_task_start_date IN    DATE := NULL,
                          p_type               IN VARCHAR2
                         )
IS
  CURSOR c_header (x_unit_id IN NUMBER) IS
   SELECT aueb.mr_header_id
   FROM   ahl_unit_effectivities_vl aueb, ahl_mr_headers_b amhb
   WHERE  aueb.mr_header_id = amhb.mr_header_id
   AND    amhb.mr_status_code = 'COMPLETE'
   AND    amhb.version_number IN
             (SELECT  MAX(version_number)
              FROM    ahl_mr_headers_b
              WHERE   title = amhb.title
              AND     TRUNC(SYSDATE)
              BETWEEN TRUNC(effective_from)
              AND     TRUNC(NVL(effective_to,SYSDATE+1))
              AND     mr_status_code = 'COMPLETE'
             )
   AND    (aueb.status_code IS NULL OR aueb.status_code = 'INIT-DUE')
   AND    aueb.unit_effectivity_id = x_unit_id;
  c_header_rec c_header%ROWTYPE;
   --SKPATHAK :: Bug 8344789 :: 19-MAY-2009
   --Validate status and version of the MR associated to the SR
   CURSOR c_validate_mr (x_unit_id IN NUMBER) IS
      SELECT   'X'
      FROM     ahl_unit_effectivities_vl aueb, ahl_mr_headers_b amhb
      WHERE    aueb.mr_header_id = amhb.mr_header_id
      AND      aueb.unit_effectivity_id = x_unit_id
      AND      (amhb.version_number NOT IN
                       ( SELECT  MAX(version_number)
                         FROM    ahl_mr_headers_b
                         WHERE   title = amhb.title
                         AND     TRUNC(SYSDATE)
                         BETWEEN TRUNC(effective_from)
                         AND     TRUNC(NVL(effective_to,SYSDATE+1))
                         AND     mr_status_code = 'COMPLETE'
                       )
      OR       (aueb.status_code = 'MR-TERMINATE'));


  -- To find on the basis of input unit effectivity the related information
  CURSOR c_info(x_mr_header_id IN NUMBER, x_unit_id IN NUMBER) IS
   SELECT aueb.csi_item_instance_id
   FROM   ahl_unit_effectivities_vl aueb, csi_item_instances csi
   WHERE  aueb.csi_item_instance_id = csi.instance_id
   AND    (aueb.status_code IS NULL OR aueb.status_code = 'INIT-DUE')
   AND    aueb.unit_effectivity_id = x_unit_id
   AND    aueb.mr_header_id = x_mr_header_id;

  CURSOR c_relation (x_ue_id IN NUMBER) IS
   SELECT aur.related_ue_id
   FROM   ahl_ue_relationships aur,
          ahl_unit_effectivities_vl aueb
   WHERE  aur.ue_id = x_ue_id
   AND    aur.ue_id = aueb.unit_effectivity_id
   AND    (aueb.status_code IS NULL OR aueb.status_code = 'INIT-DUE');
  c_relation_rec c_relation%ROWTYPE;

  /*NR-MR Changes - sowsubra*/
  CURSOR c_task_for_ue(p_visit_id IN NUMBER, p_ue_id IN NUMBER) IS
   SELECT visit_task_id
   FROM   ahl_visit_tasks_b
   WHERE  visit_id = p_visit_id
   AND    unit_effectivity_id = p_ue_id
   AND    NVL(status_code,'Y') <> 'DELETED';
  c_task_for_ue_rec c_task_for_ue%ROWTYPE;

  -- Begin changes by rnahata for Issue 105
  --Cursor to fetch the instance id when effectivity is given
  CURSOR c_get_prev_instance_id (p_unit_effectivity IN NUMBER) IS
   SELECT csi_item_instance_id FROM AHL_UNIT_EFFECTIVITIES_B
   WHERE UNIT_EFFECTIVITY_ID = p_unit_effectivity;

  --Cursor to fetch instance quantity
  CURSOR c_get_instance_qty(p_unit_effectivity IN NUMBER) IS
   SELECT csii.quantity, ue.csi_item_instance_id
   FROM csi_item_instances csii, ahl_unit_effectivities_b ue
   WHERE ue.unit_effectivity_id = p_unit_effectivity
   AND csii.instance_id = ue.csi_item_instance_id;

  l_instance_qty       NUMBER := 0;
  l_instance_id        NUMBER := 0;
  l_prev_instance_id   NUMBER := 0;
  -- End changes by rnahata for Issue 105

  l_mr_header_id       NUMBER;
  l_unit_eff_id        NUMBER;
  l_parent_unit_eff_id NUMBER;
  l_serial_id          NUMBER;
  l_parent_MR_Id       NUMBER;
  l_department_id      NUMBER;
  l_return_status      VARCHAR2(1);
  l_service_request_id NUMBER;
  l_dummy                 VARCHAR2(1);


  L_FULL_NAME          CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || 'CREATE_MR_TASKS';
  L_DEBUG              CONSTANT VARCHAR2(90) := 'ahl.plsql.'||L_FULL_NAME;
  MR_Serial_Tbl        AHL_VWP_RULES_PVT.MR_Serial_Tbl_Type;

BEGIN
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.begin', 'At the start of the procedure..');
      fnd_log.string(fnd_log.level_procedure,L_DEBUG, 'p_ue_id' || p_ue_id);
   END IF;

   l_unit_eff_id        :=    p_ue_id;
   l_service_request_id :=    p_service_request_id;
   l_department_id      :=    p_department_id;
   l_parent_MR_Id       :=    p_parent_ue_id;

   IF p_type = 'MR' THEN
      --SKPATHAK :: Bug 8344789 :: 19-MAY-2009
     OPEN  c_validate_mr (p_ue_id);
     FETCH c_validate_mr INTO l_dummy;
        IF c_validate_mr%FOUND THEN
          CLOSE  c_validate_mr;
          Fnd_Message.SET_NAME('AHL','AHL_VWP_NR_MR_EXPIRED');
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.G_EXC_ERROR;
	END IF;
        CLOSE  c_validate_mr;


      -- Get the MR Header for the UE
      OPEN  c_header (p_ue_id);
      FETCH c_header INTO c_header_rec;
      IF c_header%FOUND THEN
         CLOSE  c_header;
         l_mr_header_id       :=    c_header_rec.MR_Header_Id;

         OPEN  c_info (l_mr_header_id, l_unit_eff_id);
         FETCH c_info INTO l_serial_id;
         CLOSE c_info;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'l_mr_header_id =>' || l_mr_header_id);
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'l_unit_eff_id  =>' ||l_unit_eff_id);
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'l_serial_id    =>' || l_serial_id);
         END IF;

         -- NR-MR Changes - sowsubra
         -- Done to allow creation of a task for an instance that has already been removed.
        /***
         IF AHL_VWP_RULES_PVT.instance_in_config_tree(p_visit_id, l_serial_id) = FND_API.G_RET_STS_ERROR THEN
            Fnd_Message.SET_NAME('AHL','AHL_VWP_TASK_SERIAL');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
         ***/

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'Calling ahl_vwp_rules_pvt.create_tasks_for_mr');
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'p_visit_id       =>' || p_visit_id);
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'p_serial_id      =>' || l_serial_id);
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'p_mr_id          =>' || l_mr_header_id);
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'p_department_id  =>' || l_department_id);
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'p_service_req_id =>' || l_service_request_id);
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'p_x_parent_MR_Id =>' || l_parent_MR_Id);
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'p_service_req_id =>' || l_service_request_id);
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'p_quantity       =>' || p_quantity);
         END IF;

         ahl_vwp_rules_pvt.create_tasks_for_mr(p_visit_id        => p_visit_id,
                                               p_unit_id         => l_unit_eff_id,
                                               p_item_id         => NULL,
                                               p_org_id          => NULL,
                                               p_serial_id       => l_serial_id,
                                               p_mr_id           => l_mr_header_id,
                                               p_department_id   => l_department_id,
                                               p_service_req_id  => l_service_request_id,
                                               --SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Pass past dates too
                                               p_past_task_start_date => p_past_task_start_date,
                                               p_past_task_end_date => p_past_task_end_date,
                                               -- Added by rnahata for Issue 105
                                               p_quantity        => p_quantity,
                                               -- SKPATHAK :: Bug 8343599 :: 14-APR-2009
                                               p_task_start_date => p_task_start_date,
                                               p_x_parent_MR_Id  => l_parent_MR_Id,
                                               x_return_status   => l_return_status
                                             );

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'After ahl_vwp_rules_pvt.create_tasks_for_mr');
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'p_x_parent_MR_Id = ' || l_parent_MR_Id );
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'x_return_status is ' || l_return_status );
         END IF;

         IF NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;

         MR_Serial_Tbl(0).MR_ID     := l_mr_header_id ;
         MR_Serial_Tbl(0).Serial_ID := l_serial_id;
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'Calling AHL_VWP_RULES_PVT.Tech_Dependency');
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'MR_Serial_Tbl(0).MR_ID -->'|| MR_Serial_Tbl(0).MR_ID);
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'MR_Serial_Tbl(0).Serial_ID'|| MR_Serial_Tbl(0).Serial_ID);
         END IF;

         AHL_VWP_RULES_PVT.Tech_Dependency
               (p_visit_id      => p_visit_id,
                p_task_type     => 'PLANNED',
                p_MR_Serial_Tbl => MR_Serial_Tbl,
                x_return_status => l_return_status
               );

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,L_DEBUG, 'After AHL_VWP_RULES_PVT.Tech_Dependency - l_return_status : '||l_return_status);
         END IF;

         IF NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE Fnd_Api.G_EXC_ERROR;
       END IF;
      ELSE
         CLOSE c_header;
      END IF;
   END IF;

   -- Begin changes by rnahata for Issue 105
   -- This part of the code has to be done for both SR as well as MR
   --fetches the instance id for the previous MR
   OPEN c_get_prev_instance_id (l_unit_eff_id);
   FETCH c_get_prev_instance_id INTO l_prev_instance_id;
   CLOSE c_get_prev_instance_id;
   -- End changes by rnahata for Issue 105

   OPEN c_relation (l_unit_eff_id);
      LOOP
         FETCH c_relation INTO c_relation_rec;
         EXIT WHEN c_relation%NOTFOUND;
         /*NR-MR Changes - sowsubra*/
         --Call create_mr_tasks only if tasks for the MR have not already been created.
         OPEN   c_task_for_ue(p_visit_id,c_relation_rec.related_ue_id);
         FETCH  c_task_for_ue INTO c_task_for_ue_rec;
         IF   c_task_for_ue%NOTFOUND THEN
           -- Begin changes by rnahata for Issue 105
           -- get the instance qty for the child MR's
           OPEN c_get_instance_qty (c_relation_rec.related_ue_id);
           FETCH c_get_instance_qty INTO l_instance_qty,l_instance_id;
           CLOSE c_get_instance_qty;

           IF (l_instance_id = l_prev_instance_id) THEN
              l_instance_qty := p_quantity;
           END IF;
           -- End changes by rnahata for Issue 105

           -- Call create_mr_tasks recursively for the next level of UEs
           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(fnd_log.level_statement,L_DEBUG, 'Before calling create_mr_tasks');
              fnd_log.string(fnd_log.level_statement,L_DEBUG, 'ue id               =>' || c_relation_rec.related_ue_id);
              fnd_log.string(fnd_log.level_statement,L_DEBUG, 'parent ue id        =>' || l_parent_MR_Id);
              fnd_log.string(fnd_log.level_statement,L_DEBUG, 'visit id            =>' || p_visit_id);
              fnd_log.string(fnd_log.level_statement,L_DEBUG, 'department id       =>' || l_department_id);
              fnd_log.string(fnd_log.level_statement,L_DEBUG, 'service request id  =>' || l_service_request_id);
              fnd_log.string(fnd_log.level_statement,L_DEBUG, 'quantity            =>' || l_instance_qty);
           END IF;

           create_mr_tasks(p_ue_id              =>  c_relation_rec.related_ue_id,
                           p_parent_ue_id       =>  l_parent_MR_Id,
                           p_visit_id           =>  p_visit_id,
                           p_department_id      =>  l_department_id,
                           p_service_request_id =>  l_service_request_id,
                           --SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Pass past dates too
                           p_past_task_start_date => p_past_task_start_date,
                           p_past_task_end_date => p_past_task_end_date,
                           -- Added by rnahata for Issue 105
                           p_quantity           => l_instance_qty,
                           -- SKPATHAK :: Bug 8343599 :: 14-APR-2009
                           p_task_start_date    =>  p_task_start_date,
                           p_type               => 'MR'
                        );
         /*NR-MR Changes - sowsubra*/
         END IF; --c_task_for_ue%NOTFOUND
         CLOSE c_task_for_ue;
      END LOOP;
   CLOSE c_relation;

END create_mr_tasks;

--------------------------------------------------------------------
-- PROCEDURE
--    Update_Planned_Task
--
-- PURPOSE
--    To update Planned task for the Maintainance visit.
--------------------------------------------------------------------
PROCEDURE Update_Planned_Task (
   p_api_version      IN            NUMBER,
   p_init_msg_list    IN            VARCHAR2  := Fnd_Api.g_false,
   p_commit           IN            VARCHAR2  := Fnd_Api.g_false,
   p_validation_level IN            NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type      IN            VARCHAR2  := 'JSP',
   p_x_task_rec       IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2
)
IS
   L_API_VERSION CONSTANT NUMBER := 1.0;
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Update_Planned_Task';
   L_FULL_NAME   CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   L_DEBUG       CONSTANT VARCHAR2(90) := 'ahl.plsql.'||L_FULL_NAME;

   -- local variables defined for the procedure
   l_task_rec             AHL_VWP_RULES_PVT.Task_Rec_Type := p_x_task_rec;
   l_return_status        VARCHAR2(1);
   l_msg_data             VARCHAR2(2000);
   l_planned_order_flag   VARCHAR2(1);
   l_msg_count            NUMBER;
   l_cost_parent_id       NUMBER;
   l_department_id        NUMBER;

 -- To find visit related information
   CURSOR c_Visit (x_id IN NUMBER) IS
      SELECT * FROM Ahl_Visits_VL
      WHERE  VISIT_ID = x_id;
   c_Visit_rec    c_Visit%ROWTYPE;

   -- To find task related information
   CURSOR c_Task (x_id IN NUMBER) IS
      SELECT * FROM  Ahl_Visit_Tasks_VL
      WHERE  VISIT_TASK_ID = x_id;
   c_Task_rec    c_Task%ROWTYPE;
   c_upd_Task_rec    c_Task%ROWTYPE;

 BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Update_Planned_Task;

   -- Debug info.
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_procedure,L_DEBUG||'.begin','At the start of PLSQL procedure');
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

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_statement,L_DEBUG, 'Visit Id/Task Id  = ' || l_task_rec.visit_id || '-' || l_task_rec.visit_task_id);
     fnd_log.string(fnd_log.level_statement,L_DEBUG,'Inventory Id /org/name =' || l_task_rec.inventory_item_id || '-' || l_task_rec.item_organization_id || '-' || l_task_rec.item_name);
     fnd_log.string(fnd_log.level_statement,L_DEBUG,'Cost Id -- Number=' || l_task_rec.cost_parent_id || '**' || l_task_rec.cost_parent_number );
     fnd_log.string(fnd_log.level_statement,L_DEBUG,'Originating Id/Number=' || l_task_rec.originating_task_id  || '**' || l_task_rec.orginating_task_number);
     fnd_log.string(fnd_log.level_statement,L_DEBUG,'Object version number = ' || l_task_rec.object_version_number);
     fnd_log.string(fnd_log.level_statement,L_DEBUG,'Duration from record = ' || l_task_rec.duration);
     fnd_log.string(fnd_log.level_statement,L_DEBUG,'Visit start from hour/duration=' || '-' || l_task_rec.start_from_hour || '-' || l_task_rec.duration);
     fnd_log.string(fnd_log.level_statement,L_DEBUG,'Task Type code/value=' ||  l_task_rec.task_type_code || '-' || l_task_rec.task_type_value );
     fnd_log.string(fnd_log.level_statement,L_DEBUG,'department_id = ' ||  l_task_rec.department_id );
  END IF;

  ----------- Start defining and validate all LOVs on Create Visit's Task UI Screen---
     --
     -- For DEPARTMENT
     -- Convert department name to department id
     IF (l_task_rec.dept_name IS NOT NULL AND l_task_rec.dept_name <> Fnd_Api.G_MISS_CHAR ) THEN

          AHL_VWP_RULES_PVT.Check_Dept_Desc_Or_Id
                (p_organization_id => c_visit_rec.organization_id,
                 p_dept_name       => l_task_rec.dept_name,
                 p_department_id   => NULL,
                 x_department_id   => l_department_id,
                 x_return_status   => l_return_status,
                 x_error_msg_code  => l_msg_data);

          IF NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS
          THEN
              Fnd_Message.SET_NAME('AHL','AHL_VWP_DEPT_NOT_EXISTS');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.G_EXC_ERROR;
          END IF;

          --Assign the returned value
          l_task_rec.department_id := l_department_id;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           fnd_log.string(fnd_log.level_statement,L_DEBUG,'Dept ID= ' || l_Task_rec.department_id );
           fnd_log.string(fnd_log.level_statement,L_DEBUG,'Cost parent= ' || l_Task_rec.cost_parent_number);
    END IF;

     --
     -- For COST PARENT TASK
     -- Convert cost parent number to id
      IF (l_Task_rec.cost_parent_number IS NOT NULL AND
          l_Task_rec.cost_parent_number <> Fnd_Api.G_MISS_NUM ) THEN

          AHL_VWP_RULES_PVT.Check_Visit_Task_Number_OR_ID
               (p_visit_task_id     => l_Task_rec.cost_parent_id,
                p_visit_task_number => l_Task_rec.cost_parent_number,
                p_visit_id          => l_Task_rec.visit_id,
                x_visit_task_id     => l_cost_parent_id,
                x_return_status     => l_return_status,
                x_error_msg_code    => l_msg_data);

          IF NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS
          THEN
              Fnd_Message.SET_NAME('AHL','AHL_VWP_PARENT_NOT_EXISTS');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.g_exc_error;
          END IF;

           --Assign the returned value
           l_Task_rec.cost_parent_id := l_cost_parent_id;
     END IF;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string(fnd_log.level_statement,L_DEBUG,'Cost parent ID = ' || l_Task_rec.cost_parent_id);
       fnd_log.string(fnd_log.level_statement,L_DEBUG,'Validation: Start -- For COST PARENT ');
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

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement,L_DEBUG,'Validation: End -- For COST PARENT ');
   END IF;

   ----------- End defining and validate all LOVs on Create Visit's Task UI Screen---

   ----------------------- validate ----------------------

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_statement,L_DEBUG,'Validate');
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
       RAISE Fnd_Api.g_exc_error;
   END IF;

-- Post 11.5.10 Changes by Senthil.
   IF(L_task_rec.STAGE_ID IS NOT NULL OR L_task_rec.STAGE_NAME IS NOT NULL) THEN

  AHL_VWP_VISITS_STAGES_PVT.VALIDATE_STAGE_UPDATES(
   P_API_VERSION   => 1.0,
   P_VISIT_ID      => l_Task_rec.visit_id,
   P_VISIT_TASK_ID => l_Task_rec.visit_task_id,
   P_STAGE_NAME    => L_task_rec.STAGE_NAME,
   X_STAGE_ID      => L_task_rec.STAGE_ID,
   X_RETURN_STATUS => l_return_status,
   X_MSG_COUNT     => l_msg_count,
   X_MSG_DATA      => l_msg_data  );

   END IF;

    -- Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 OR NVL(l_return_status,'X') <> Fnd_Api.g_ret_sts_success THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

 -------------------------- update --------------------
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_statement,L_DEBUG,'Update');
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
      X_TASK_TYPE_CODE        => l_task_rec.TASK_TYPE_CODE,
      X_DEPARTMENT_ID         => l_task_rec.DEPARTMENT_ID,
      X_SUMMARY_TASK_FLAG     => 'N',
      X_PRICE_LIST_ID         => c_task_rec.price_list_id,
      X_STATUS_CODE           => c_task_rec.status_code,
      X_ESTIMATED_PRICE       => c_task_rec.estimated_price,
      X_ACTUAL_PRICE          => c_task_rec.actual_price,
      X_ACTUAL_COST           => c_task_rec.actual_cost,
      -- Changes for 11.5.10 by Senthil.
      X_STAGE_ID              => l_task_rec.STAGE_ID,
      -- Added cxcheng POST11510--------------
      --SKPATHAK :: ER: 9147951 :: 11-JAN-2010
      -- Pass past dates too, and if it is null, pass null for all the 4 columns below
      X_START_DATE_TIME       => l_task_rec.PAST_TASK_START_DATE,
      X_END_DATE_TIME         => l_task_rec.PAST_TASK_END_DATE,
      X_PAST_TASK_START_DATE  => l_task_rec.PAST_TASK_START_DATE,
      X_PAST_TASK_END_DATE    => l_task_rec.PAST_TASK_END_DATE,
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
      X_VISIT_TASK_NAME       => l_task_rec.visit_task_name,
      X_DESCRIPTION           => l_task_rec.description,
      X_QUANTITY              => c_task_rec.QUANTITY, -- Added by rnahata for Issue 105
      X_LAST_UPDATE_DATE      => SYSDATE,
      X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
      X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID );

   -- Added cxcheng POST11510--------------
   --Now adjust the times derivation for task
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_VWP_TIMES_PVT.Adjust_Task_Times');
   END IF;

   --SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Call Adjust_Task_Times only if past date is null
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

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_statement,L_DEBUG,'After calling AHL_VWP_TIMES_PVT.Adjust_Task_Times - l_return_status : '||l_return_status);
   END IF;

   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 OR NVL(l_return_status,'X') <> Fnd_Api.g_ret_sts_success THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Assign back to in/out parameter
   p_x_task_rec := l_task_rec;

   -- To Update visit attribute any_task_chg_flag for costing purpose
   -- Looking for changes in 'Start from hour' attributes of task

   IF NVL(l_task_rec.Start_from_hour,-30) <> NVL(c_task_rec.Start_from_hour,-30) OR
      NVL(l_task_rec.STAGE_ID,-30) <> NVL(c_task_rec.STAGE_ID,-30) OR
      NVL(l_task_rec.department_id,-30) <> NVL(c_task_rec.department_id,-30) THEN
        OPEN c_Task(l_Task_rec.visit_task_id);
        FETCH c_Task INTO c_upd_Task_rec;
        CLOSE c_Task;

        IF c_upd_Task_rec.start_date_time IS NOT NULL THEN
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           fnd_log.string(fnd_log.level_statement,L_DEBUG,'Before calling AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials');
          END IF;

          AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials (
              p_api_version        => 1.0,
              p_init_msg_list      => FND_API.g_false,
              p_commit             => FND_API.g_false,
              p_validation_level   => FND_API.g_valid_level_full,
              p_visit_id           => l_task_rec.visit_id,
              p_visit_task_id      => NULL,
              p_org_id             => NULL,
              p_start_date         => NULL,
              p_operation_flag     => 'U',
              x_planned_order_flag => l_planned_order_flag ,
              x_return_status      => l_return_status,
              x_msg_count          => l_msg_count,
              x_msg_data           => l_msg_data );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           fnd_log.string(fnd_log.level_statement,L_DEBUG,'After AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials - l_return_status : '||l_return_status);
           fnd_log.string(fnd_log.level_statement,L_DEBUG,'Planned Order Flag : ' || l_planned_order_flag);
          END IF;

          IF l_return_status <> 'S' THEN
            RAISE Fnd_Api.G_EXC_ERROR;
          END IF;
        END IF;

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
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_procedure,L_DEBUG ||'.end','At the end of PLSQL procedure');
   END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Update_Planned_Task;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Planned_Task;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Planned_Task;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error) THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Update_Planned_Task;

--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Planned_Task
--
-- PURPOSE
--    To delete Planned tasks for the Maintenace visit.
--------------------------------------------------------------------
PROCEDURE Delete_Planned_Task (
   p_api_version      IN  NUMBER,
   p_init_msg_list    IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit           IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type      IN  VARCHAR2  := 'JSP',
   p_visit_task_ID    IN  NUMBER,

   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2
)

IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Delete Planned Task';
   l_full_name   CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_Api_name;
   l_debug       CONSTANT VARCHAR2(90) := 'ahl.plsql.'||L_FULL_NAME;
   -- local variables defined for the procedure
   l_origin_id   NUMBER;

  -- To find all tasks related information
   CURSOR c_Task (x_id IN NUMBER) IS
      SELECT * FROM Ahl_Visit_Tasks_VL
      WHERE Visit_Task_ID = x_id;
      c_task_rec    c_Task%ROWTYPE;
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Delete_Planned_Task;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_procedure,l_debug||'.begin','At the start of PLSQL procedure');
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
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,l_debug,'Task Id' || p_visit_task_ID);
   END IF;

   -- To check if the input taskid exists in task entity.
   OPEN c_Task(p_Visit_Task_ID);
   FETCH c_Task INTO c_task_rec;

   IF c_Task%NOTFOUND THEN
      CLOSE c_Task;
      Fnd_Message.set_name('AHL', 'AHL_VWP_TASK_ID_INVALID');
      FND_MESSAGE.SET_TOKEN('TASK_ID',p_visit_task_id,false);
      Fnd_Msg_Pub.ADD;
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,l_debug,'Invalid Task Id' || p_visit_task_ID);
      END IF;
      RAISE Fnd_Api.g_exc_error;
   ELSE
      CLOSE c_Task;
      -- To find the visit related information
      l_origin_id:= c_task_rec.originating_task_id;

       If l_origin_id is Not Null then
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,l_debug,'Before calling AHL_VWP_TASKS_PVT.Delete_Summary_Task');
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
                x_msg_data         => x_msg_data);

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,l_debug,'After calling AHL_VWP_TASKS_PVT.Delete_Summary_Task : x_return_status - '||x_return_status);
          END IF;

          IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
            RAISE Fnd_Api.G_EXC_ERROR;
          END IF;
       ELSE
              Fnd_Message.SET_NAME('AHL','AHL_VWP_PLANNEDTASKMR');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.G_EXC_ERROR;
       End IF;
   END IF;
   ------------------------End of API Body------------------------------------
   IF Fnd_Api.to_boolean (p_commit) THEN
      COMMIT;
   END IF;

   Fnd_Msg_Pub.count_and_get (
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_procedure,l_debug ||'.end','At the end of PLSQL procedure');
   END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Delete_Planned_Task;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Delete_Planned_Task;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Delete_Planned_Task;
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

END Delete_Planned_Task;

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
   l_api_name    CONSTANT VARCHAR2(30) := 'Check_Task_Items';
   l_full_name   CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_Api_name;
   l_debug       CONSTANT VARCHAR2(90) := 'ahl.plsql.'||L_FULL_NAME;

BEGIN
   --
   -- Validate required items.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,l_debug||'.begin', 'At the start of the procedure..');
      fnd_log.string(fnd_log.level_procedure,l_debug, 'Before Check_Visit_Task_Req_Items');
   END IF;

   Check_Visit_Task_Req_Items (
      p_task_rec        => p_task_rec,
      x_return_status   => x_return_status
   );
   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_statement,l_debug,'After Check_Visit_Task_Req_Items');
   END IF;

   -- Validate uniqueness.
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_statement,l_debug,'Before Check_Visit_Task_UK_Items');
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
    fnd_log.string(fnd_log.level_procedure,l_debug,'After Check_Visit_Task_UK_Items..');
    fnd_log.string(fnd_log.level_procedure,l_debug||'.end','At the end of the procedure');
   END IF;
END Check_Task_Items;

---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Visit_Task_Rec
--
-- PURPOSE
--
---------------------------------------------------------------------
/* It doesn't seem to be used anywhere
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
   p_task_rec       IN  AHL_VWP_RULES_PVT.Task_Rec_Type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
   l_api_name  CONSTANT VARCHAR2(30) := 'Check_Visit_Task_Req_Items';
   l_full_name CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_Api_name;
   l_debug     CONSTANT VARCHAR2(90) := 'ahl.plsql.'||L_FULL_NAME;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_debug,'At the Start of Check_Visit_Task_Req_Items ');
   END IF;

   -- TASK NAME ==== NAME
   IF (p_task_rec.VISIT_TASK_NAME IS NULL OR p_Task_rec.VISIT_TASK_NAME = Fnd_Api.G_MISS_CHAR) THEN
         Fnd_Message.set_name ('AHL', 'AHL_VWP_NAME_MISSING');
         Fnd_Msg_Pub.ADD;
      x_return_status := Fnd_Api.g_ret_sts_error;
      RETURN;
   END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_statement,l_debug,'Inside Validation Start from Hour = ' || p_task_rec.START_FROM_HOUR);
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
   p_task_rec        IN  AHL_VWP_RULES_PVT.Task_Rec_Type,
   p_validation_mode IN  VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_valid_flag         VARCHAR2(1);
   l_api_name  CONSTANT VARCHAR2(30) := 'Check_Visit_Task_Req_Items';
   l_full_name CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_Api_name;
   l_debug     CONSTANT VARCHAR2(90) := 'ahl.plsql.'||L_FULL_NAME;

BEGIN
   x_return_status := Fnd_Api.g_ret_sts_success;
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_procedure,l_debug,'At the Start of Check_Visit_Task_UK_Items ');
   END IF;
   --
   -- For Task, when ID is passed in, we need to
   -- check if this ID is unique.
   IF p_validation_mode = Jtf_Plsql_Api.g_create AND p_task_rec.Visit_Task_ID IS NOT NULL THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,'ahl.plsql.',': = Check_Visit_Task_UK_Items Uniqueness Of ID');
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

END AHL_VWP_PLAN_TASKS_PVT;

/
