--------------------------------------------------------
--  DDL for Package Body AHL_VWP_TASKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_TASKS_PVT" AS
/* $Header: AHLVTSKB.pls 120.16.12010000.8 2010/03/28 10:15:55 manesing ship $ */
-----------------------------------------------------------
-- PACKAGE
--    Ahl_Vwp_Tasks_Pvt
--
-- PURPOSE
--    This package body is a Private API for managing VWP Tasks procedures
--    in Complex Maintainance, Repair and Overhauling(CMRO).
--    It defines global constants, various local functions and procedures.
--
-- PROCEDURES
--      Check_Task_Items          --      Complete_Visit_Task_Rec
--      Check_Visit_Task_Req_Items--      Check_Visit_Task_UK_Items
--      Validate_Visit_Task       --      Default_Missing_Attribs

--      Create_Task               --      Update_Task
--      Create_Summary_Task       --      Update_Summary_Task
--      Create_Unassociated_Task  --      Update_Unassociated_Task
--      Update_Tasks_in_Production

--      Delete_Task               --      Get_Task_Details
--      Delete_Summary_Task       --      Delete_Unassociated_Task
--
-- NOTES
--
--
-- HISTORY
-- 12-MAY-2002    Shbhanda      Created.
-- 06-AUG-2003    SHBHANDA      11.5.10 Changes.
--
-- 21-AUG-2003    RTADIKON      Changes to reflect VWP/Costing Changes.
-- 13-Sep-2004    SJAYACHA      Commented call to update_project as this
--                               needs to be done before deleting the Visit.
-- 02-NOV-2007    RBHAVSAR      Added PROCEDURE level logs when entering and exiting a procedure.
--                              Returned the status before returning from the procedure.
--                              Replaced all fnd_log.level_procedure with STATEMENT
--                              level logs and added more STATEMENT level logs at
--                              key decision points.
-- 18-FEB-2010    MANISAGA      Added attribute for DFF enablement and Route_id for navigation
--                              to route page
-----------------------------------------------------------------
--   Define Global CONSTANTS                                   --
-----------------------------------------------------------------
G_PKG_NAME  CONSTANT    VARCHAR2(30):= 'AHL_VWP_TASKS_PVT';
-----------------------------------------------------------------
-- Common constants and variables --
------------------------------------
l_log_current_level   NUMBER   := fnd_log.g_current_runtime_level;
l_log_statement       NUMBER   := fnd_log.level_statement;
l_log_procedure       NUMBER   := fnd_log.level_procedure;
l_log_error           NUMBER   := fnd_log.level_error;
l_log_unexpected      NUMBER   := fnd_log.level_unexpected;
---------------------------------------------------------------------
--   Define Record Types for record structures needed by the APIs  --
---------------------------------------------------------------------
-- NO RECORD TYPES

--------------------------------------------------------------------
-- Define Table Type for Records Structures                       --
--------------------------------------------------------------------
-- NO RECORD TYPES

--------------------------------------------------------------------
--  START: Defining local functions and procedures SIGNATURES     --
--------------------------------------------------------------------
--  To Check_Visit_Task_Req_Items
PROCEDURE Check_Visit_Task_Req_Items (
   p_task_rec        IN         AHL_VWP_RULES_PVT.Task_Rec_Type,
   --Added by rnahata for Issue 105
   p_validation_mode IN         VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);

--  To Check_Visit_Task_UK_Items
PROCEDURE Check_Visit_Task_UK_Items (
   p_task_rec         IN         AHL_VWP_RULES_PVT.Task_Rec_Type,
   p_validation_mode  IN         VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status    OUT NOCOPY VARCHAR2
);

--  To Check_Task_Items
PROCEDURE Check_Task_Items (
   p_Task_rec        IN  AHL_VWP_RULES_PVT.task_rec_type,
   p_validation_mode IN  VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);

-- To Validate_Visit_Task
PROCEDURE Validate_Visit_Task (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_Task_rec          IN  AHL_VWP_RULES_PVT.task_rec_type,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
);

--  To assign Null to missing attributes of visit while creation/updation.
PROCEDURE Default_Missing_Attribs(
 p_x_task_rec IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type
);

-- To Create Unassociated Task
PROCEDURE Create_Unassociated_Task(
   p_api_version      IN            NUMBER,
   p_init_msg_list    IN            VARCHAR2  := Fnd_Api.g_false,
   p_commit           IN            VARCHAR2  := Fnd_Api.g_false,
   p_validation_level IN            NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type      IN            VARCHAR2  := 'JSP',
   p_x_task_Rec       IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2
   );

-- To Create Summary Task
PROCEDURE Create_Summary_Task(
   p_api_version      IN            NUMBER,
   p_init_msg_list    IN            VARCHAR2  := Fnd_Api.g_false,
   p_commit           IN            VARCHAR2  := Fnd_Api.g_false,
   p_validation_level IN            NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type      IN            VARCHAR2  :='JSP',
   p_x_task_Rec       IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2
   );

-- To Delete SR Task
PROCEDURE Delete_SR_Task (
   p_api_version      IN  NUMBER,
   p_init_msg_list    IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit           IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type      IN  VARCHAR2:= 'JSP',
   p_visit_task_ID    IN  NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2
);

-- To Update Summary Task
PROCEDURE Update_Summary_Task(
   p_api_version      IN            NUMBER,
   p_init_msg_list    IN            VARCHAR2  := Fnd_Api.g_false,
   p_commit           IN            VARCHAR2  := Fnd_Api.g_false,
   p_validation_level IN            NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type      IN            VARCHAR2  := 'JSP',
   p_x_task_Rec       IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2
   );

-- To Update Unassociated Task

PROCEDURE Update_Unassociated_Task(
   p_api_version      IN            NUMBER,
   p_init_msg_list    IN            VARCHAR2  := Fnd_Api.g_false,
   p_commit           IN            VARCHAR2  := Fnd_Api.g_false,
   p_validation_level IN            NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type      IN            VARCHAR2  := 'JSP',
   p_x_task_Rec       IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2
   );

-- To Delete Unassociated Task
PROCEDURE Delete_Unassociated_Task (
   p_api_version      IN         NUMBER,
   p_init_msg_list    IN         VARCHAR2  := Fnd_Api.g_false,
   p_commit           IN         VARCHAR2  := Fnd_Api.g_false,
   p_validation_level IN         NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type      IN         VARCHAR2  := 'JSP',
   p_Visit_Task_Id    IN         NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2
   );

PROCEDURE Get_WorkOrder_Attribs(
  p_x_prd_workorder_rec   IN OUT NOCOPY AHL_PRD_WORKORDER_PVT.prd_workorder_rec
  );

PROCEDURE Update_Tasks_in_Planning(
  p_api_version      IN            NUMBER  := 1.0,
  p_init_msg_list    IN            VARCHAR2:= FND_API.G_FALSE,
  p_commit           IN            VARCHAR2:= FND_API.G_FALSE,
  p_validation_level IN            NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_module_type      IN            VARCHAR2:= 'JSP',
  p_x_task_rec       IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2
);

PROCEDURE Update_Tasks_in_Production(
  p_api_version      IN            NUMBER  := 1.0,
  p_init_msg_list    IN            VARCHAR2:=  FND_API.G_FALSE,
  p_commit           IN            VARCHAR2:=  FND_API.G_FALSE,
  p_validation_level IN            NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
  p_module_type      IN            VARCHAR2:=  'JSP',
  p_x_task_rec       IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2
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
-- Start default attributes for workorder
PROCEDURE Get_WorkOrder_Attribs(
  p_x_prd_workorder_rec   IN OUT NOCOPY AHL_PRD_WORKORDER_PVT.prd_workorder_rec
)
AS

CURSOR get_workorder_rec(c_workorder_id NUMBER)
IS
/*SELECT *
FROM   AHL_ALL_WORKORDERS_V
WHERE  workorder_id=c_workorder_id;
*/
-- AnRaj: Changed query for perf issue#1, Bug 4919465
SELECT   WO.OBJECT_VERSION_NUMBER OBJECT_VERSION_NUMBER,
         WO.WORKORDER_NAME JOB_NUMBER,
         WO.ROUTE_ID ROUTE_ID,
         VST.ORGANIZATION_ID ORGANIZATION_ID,
         WIP.FIRM_PLANNED_FLAG FIRM_PLANNED_FLAG,
         WIP.CLASS_CODE CLASS_CODE,
         WIP.OWNING_DEPARTMENT DEPARTMENT_ID ,
         WO.STATUS_CODE JOB_STATUS_CODE,
         WIP.SCHEDULED_START_DATE SCHEDULED_START_DATE,
         WIP.SCHEDULED_COMPLETION_DATE SCHEDULED_END_DATE,
         WO.ACTUAL_START_DATE ACTUAL_START_DATE,
         WO.ACTUAL_END_DATE ACTUAL_END_DATE,
         NVL2( WO.VISIT_TASK_ID,
               nvl(VST.INVENTORY_ITEM_ID, (select inventory_item_id from ahl_visit_tasks_b where visit_id = vst.visit_id and rownum = 1) ),
               VST.INVENTORY_ITEM_ID) INVENTORY_ITEM_ID,
         NVL2( WO.VISIT_TASK_ID,
               nvl (VST.ITEM_INSTANCE_ID, (select instance_id from ahl_visit_tasks_b where visit_id = vst.visit_id and rownum = 1) ),
               VST.ITEM_INSTANCE_ID) ITEM_INSTANCE_ID,
         WO.MASTER_WORKORDER_FLAG MASTER_WORKORDER_FLAG,
         VST.PROJECT_ID PROJECT_ID,
         NVL2( WO.VISIT_TASK_ID,VTS.PROJECT_TASK_ID,TO_NUMBER(NULL)) PROJECT_TASK_ID,
         NVL2( WO.VISIT_TASK_ID,VTS.SERVICE_REQUEST_ID,TO_NUMBER(NULL)) INCIDENT_ID
FROM     AHL_WORKORDERS WO,
         AHL_VISITS_B   VST,
         AHL_VISIT_TASKS_B VTS,
         WIP_DISCRETE_JOBS WIP
WHERE    WIP.WIP_ENTITY_ID=WO.WIP_ENTITY_ID
AND      WO.VISIT_ID = VST.VISIT_ID
AND      WO.VISIT_ID = VTS.VISIT_ID(+)
AND      WO.VISIT_TASK_ID = VTS.VISIT_TASK_ID(+)
AND      WO.STATUS_CODE <> '22'
AND      WORKORDER_ID = c_workorder_id;
l_prd_workorder_rec   get_workorder_rec%ROWTYPE;

L_API_NAME  CONSTANT VARCHAR2(30) := 'Get_WorkOrder_Attribs';
L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
BEGIN
  IF (l_log_procedure >= l_log_current_level) THEN
     fnd_log.string(l_log_procedure,
                    L_DEBUG_KEY ||'.begin',
                    'At the start of PL SQL procedure.' ||
                    ' p_x_prd_workorder_rec.workorder_id : ' || p_x_prd_workorder_rec.workorder_id);
  END IF;
  p_x_prd_workorder_rec.DML_OPERATION := 'U';

  OPEN  get_workorder_rec(p_x_prd_workorder_rec.workorder_id);
  FETCH get_workorder_rec INTO l_prd_workorder_rec;
  IF get_workorder_rec%NOTFOUND THEN
     FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WO_NOT_FOUND');
     FND_MSG_PUB.ADD;
     CLOSE get_workorder_rec;
  END IF;
  CLOSE get_workorder_rec;
  p_x_prd_workorder_rec.OBJECT_VERSION_NUMBER :=l_prd_workorder_rec.OBJECT_VERSION_NUMBER;
  p_x_prd_workorder_rec.JOB_NUMBER            :=l_prd_workorder_rec.JOB_NUMBER;
  p_x_prd_workorder_rec.ROUTE_ID              :=l_prd_workorder_rec.ROUTE_ID;
  p_x_prd_workorder_rec.ORGANIZATION_ID       :=l_prd_workorder_rec.ORGANIZATION_ID;
  p_x_prd_workorder_rec.FIRM_PLANNED_FLAG     :=l_prd_workorder_rec.FIRM_PLANNED_FLAG;
  p_x_prd_workorder_rec.CLASS_CODE            :=l_prd_workorder_rec.CLASS_CODE;
  p_x_prd_workorder_rec.DEPARTMENT_ID         :=l_prd_workorder_rec.DEPARTMENT_ID;
  p_x_prd_workorder_rec.STATUS_CODE           :=l_prd_workorder_rec.job_STATUS_CODE;
  p_x_prd_workorder_rec.SCHEDULED_START_DATE  :=l_prd_workorder_rec.SCHEDULED_START_DATE;
  p_x_prd_workorder_rec.SCHEDULED_END_DATE    :=l_prd_workorder_rec.SCHEDULED_END_DATE;
  p_x_prd_workorder_rec.ACTUAL_START_DATE     :=l_prd_workorder_rec.ACTUAL_START_DATE;
  p_x_prd_workorder_rec.ACTUAL_END_DATE       :=l_prd_workorder_rec.ACTUAL_END_DATE;
  p_x_prd_workorder_rec.INVENTORY_ITEM_ID     :=l_prd_workorder_rec.INVENTORY_ITEM_ID;
  p_x_prd_workorder_rec.ITEM_INSTANCE_ID      :=l_prd_workorder_rec.ITEM_INSTANCE_ID;
  p_x_prd_workorder_rec.MASTER_WORKORDER_FLAG :=l_prd_workorder_rec.MASTER_WORKORDER_FLAG;
  p_x_prd_workorder_rec.PROJECT_ID            :=l_prd_workorder_rec.PROJECT_ID;
  p_x_prd_workorder_rec.PROJECT_TASK_ID       :=l_prd_workorder_rec.PROJECT_TASK_ID;
  p_x_prd_workorder_rec.INCIDENT_ID           :=l_prd_workorder_rec.INCIDENT_ID;

  IF (l_log_procedure >= l_log_current_level) THEN
     fnd_log.string(l_log_procedure,
                    L_DEBUG_KEY ||'.end',
                    'At the end of PL SQL procedure.');
  END IF;
END Get_WorkOrder_Attribs;

-- end of the local procedure to set default attribs.

PROCEDURE Default_Missing_Attribs
( p_x_task_rec         IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type)
AS
  L_API_NAME  CONSTANT VARCHAR2(30) := 'Default_Missing_Attribs';
  L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
BEGIN
         IF (l_log_procedure >= l_log_current_level) THEN
             fnd_log.string(l_log_procedure,
                            L_DEBUG_KEY ||'.begin',
                            'At the start of PL SQL procedure.');
         END IF;
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

         IF p_x_task_rec.ORIGINATING_TASK_ID = Fnd_Api.G_MISS_NUM THEN
            p_x_task_rec.ORIGINATING_TASK_ID := NULL;
         ELSE
            p_x_task_rec.ORIGINATING_TASK_ID := p_x_task_rec.ORIGINATING_TASK_ID;
         END IF;

         IF p_x_task_rec.SERVICE_REQUEST_ID = Fnd_Api.G_MISS_NUM THEN
            p_x_task_rec.SERVICE_REQUEST_ID := NULL;
         ELSE
            p_x_task_rec.SERVICE_REQUEST_ID := p_x_task_rec.SERVICE_REQUEST_ID;
         END IF;

         IF p_x_task_rec.attribute_category = Fnd_Api.G_MISS_CHAR THEN
            p_x_task_rec.attribute_category := NULL;
         ELSE
            p_x_task_rec.attribute_category := p_x_task_rec.attribute_category;
         END IF;
         --
         IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.end',
                      'At the end of PL SQL procedure.');
         END IF;

END Default_Missing_Attribs;

--------------------------------------------------------------------
-- PROCEDURE
--    Get_Task_Details
--
-- PURPOSE
--    To display all task details for the update task UI screen
--------------------------------------------------------------------
PROCEDURE Get_Task_Details (
   p_api_version      IN         NUMBER,
   p_init_msg_list    IN         VARCHAR2 := Fnd_Api.g_false,
   p_commit           IN         VARCHAR2 := Fnd_Api.g_false,
   p_validation_level IN         NUMBER   := Fnd_Api.g_valid_level_full,
   p_module_type      IN         VARCHAR2 :='JSP',
   p_task_id          IN         NUMBER,
   x_task_rec         OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2
)
IS
   L_API_VERSION CONSTANT NUMBER := 1.0;
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Get_Task_Details';
   L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   -- local variables defined for the procedure
   l_task_rec         AHL_VWP_RULES_PVT.Task_Rec_Type := NULL;
   l_zone             VARCHAR2(30);
   l_sub_zone         VARCHAR2(30);
   l_uom              VARCHAR2(30);
   l_route_id         NUMBER;
   l_tol_after        NUMBER;
   l_tol_before       NUMBER;
   l_parent_num       NUMBER;
   l_origin_num       NUMBER;
   l_duration         NUMBER;
   l_proj_task_number NUMBER;
   l_task_start_date  DATE;
   l_task_end_date    DATE;
   l_due_by_date      DATE;
   l_msg_count        NUMBER;

   -- Define local cursors
   -- To find visit related information
   CURSOR c_visit (x_id IN NUMBER) IS
    SELECT * FROM AHL_VISITS_VL
    WHERE VISIT_ID = x_id;
    c_visit_rec c_visit%ROWTYPE;

   -- To find task related information when its for a visit
   /*
   CURSOR c_task (x_T_id IN NUMBER) IS
    SELECT * FROM AHL_SEARCH_VISIT_TASK_V
    WHERE TASK_ID = x_T_id;
   c_task_rec c_task%ROWTYPE;
   */

   CURSOR c_task_type (x_T_id IN NUMBER) IS
      SELECT   TASK_TYPE_CODE,MR_ID
      FROM     ahl_visit_tasks_b
      WHERE    VISIT_TASK_ID = x_T_id;
   c_task_type_rec c_task_type%ROWTYPE;

   CURSOR c_non_summary_task_details(x_T_id IN NUMBER) IS
      SELECT AVTS.VISIT_ID VISIT_ID,
             AVTS.VISIT_NUMBER VISIT_NUMBER,
             AVTS.TEMPLATE_FLAG TEMPLATE_FLAG,
             AVTS.STATUS_CODE VISIT_STATUS_CODE,
             ATSK.VISIT_TASK_ID TASK_ID,
             ATSK.VISIT_TASK_NUMBER TASK_NUMBER,
             ATSKL.VISIT_TASK_NAME TASK_NAME,
             ATSK.INVENTORY_ITEM_ID ITEM_ID,
             MTSB.CONCATENATED_SEGMENTS ITEM_NAME,
             ATSK.ITEM_ORGANIZATION_ID ITEM_ORGANIZATION_ID,
             ATSK.INSTANCE_ID UNIT_ID,
             ATSK.QUANTITY QUANTITY, --Added by rnahata for Issue 105
             CSIS.SERIAL_NUMBER UNIT_NAME,
             CSIS.INSTANCE_NUMBER INSTANCE_NUMBER, --Added by rnahata for Issue 105
             CSIS.UNIT_OF_MEASURE UOM, --Added by rnahata for Issue 105
             ATSK.MR_ROUTE_ID MR_ROUTE_ID,
             AMRH.TITLE MR_NAME,
             ARV.ROUTE_NO ROUTE_NAME,
             ARV.ROUTE_TYPE_CODE ROUTE_TYPE_CODE,
             LKUP4.MEANING ROUTE_TYPE,
             AWO.WORKORDER_ID WORK_ORDER_ID,
             AWO.WORKORDER_NAME WORKORDER_NAME,
             AWO.STATUS_CODE WORKORDER_STATUS,
             LKUP2.MEANING WORKORDER_STATUS_MEANING,
             AWO.ACTUAL_START_DATE WORKORDER_START_DATE,
             AWO.ACTUAL_END_DATE WORKORDER_END_DATE,
             ATSK.SERVICE_REQUEST_ID SERVICE_REQ_ID,
             SR.INCIDENT_NUMBER SERVICE_REQ_NAME,
             ATSK.START_DATE_TIME START_DATE_TIME,
             ATSK.END_DATE_TIME END_DATE_TIME,
             -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Fetch past start and end dates too
             ATSK.PAST_TASK_START_DATE,
             ATSK.PAST_TASK_END_DATE,
             ATSK.TASK_TYPE_CODE TASK_TYPE_CODE,
             LKUP1.MEANING TASK_TYPE_NAME,
             ATSK.STATUS_CODE TASK_STATUS_CODE,
             LKUP3.MEANING TASK_STATUS_NAME,
             ATSK.STAGE_ID STAGE_ID,
             ASTG.STAGE_NUM STAGE_NUM,
             ASTG.STAGE_NAME STAGE_NAME,
             AUEF.DUE_DATE DUE_BY_DATE,
             ATSK.DEPARTMENT_ID DEPARTMENT_ID,
             BDPT.DESCRIPTION DEPARTMENT_NAME,
             ATSK.ORIGINATING_TASK_ID ORIGINATING_TASK_ID,
             ORIGTSK.VISIT_TASK_NUMBER ORIGINATING_TASK_NUMBER,
             ORIGTSK.VISIT_TASK_NAME ORIGINATING_TASK_NAME,
             ATSK.MR_ID MR_ID,
             ATSK.UNIT_EFFECTIVITY_ID UNIT_EFFECTIVITY_ID,
             AMRH.DESCRIPTION  MR_DESCRIPTION,
             --manisaga added all the attributes and ROUTE_ID as part of DFF Enablement 0n 18-Feb-2010--Start
             AMRR.ROUTE_ID,
             ATSK.attribute_category,
             ATSK.Attribute1,
             ATSK.Attribute2,
             ATSK.Attribute3,
             ATSK.Attribute4,
             ATSK.Attribute5,
             ATSK.Attribute6,
             ATSK.Attribute7,
             ATSK.Attribute8,
             ATSK.Attribute9,
             ATSK.Attribute10,
             ATSK.Attribute11,
             ATSK.Attribute12,
             ATSK.Attribute13,
             ATSK.Attribute14,
             ATSK.Attribute15
             --manisaga added all the attributes and ROUTE_ID as part of DFF Enablement 0n 18-Feb-2010--End
      FROM   AHL_VISITS_B AVTS,
             AHL_VISIT_TASKS_B ATSK,
             AHL_VISIT_TASKS_TL ATSKL,
             AHL_VISIT_TASKS_VL ORIGTSK,
             AHL_MR_ROUTES AMRR,
             AHL_MR_HEADERS_VL AMRH,
             AHL_UNIT_EFFECTIVITIES_B AUEF,
             CSI_ITEM_INSTANCES CSIS,
             CS_INCIDENTS_ALL_B SR,
             BOM_DEPARTMENTS BDPT,
             FND_LOOKUP_VALUES LKUP1,
             FND_LOOKUP_VALUES LKUP2,
             FND_LOOKUP_VALUES LKUP3,
             FND_LOOKUP_VALUES LKUP4,
             AHL_VWP_STAGES_VL ASTG,
             MTL_SYSTEM_ITEMS_B_KFV MTSB,
             AHL_ROUTES_B ARV,
             AHL_WORKORDERS AWO
      WHERE  ATSK.INSTANCE_ID = CSIS.INSTANCE_ID (+)
      AND    ATSK.ORIGINATING_TASK_ID = ORIGTSK.VISIT_TASK_ID(+)
      AND    ATSK.MR_ROUTE_ID = AMRR.MR_ROUTE_ID (+)
      AND    AMRR.MR_HEADER_ID= AMRH.MR_HEADER_ID (+)
      AND    AMRR.ROUTE_ID = ARV.ROUTE_ID (+)
      AND    LKUP4.LOOKUP_TYPE (+) = 'AHL_ROUTE_TYPE'
      AND    LKUP4.LOOKUP_CODE (+) = ARV.ROUTE_TYPE_CODE
      AND    LKUP4.LANGUAGE (+) = userenv('LANG')
      AND    ATSK.SERVICE_REQUEST_ID=SR.INCIDENT_ID (+)
      AND    ATSK.UNIT_EFFECTIVITY_ID=AUEF.UNIT_EFFECTIVITY_ID(+)
      AND    ATSK. INVENTORY_ITEM_ID = MTSB.INVENTORY_ITEM_ID(+)
      AND    ATSK. ITEM_ORGANIZATION_ID = MTSB.ORGANIZATION_ID(+)
      AND    LKUP1.LOOKUP_TYPE(+) = 'AHL_VWP_TASK_TYPE'
      AND    LKUP1.LANGUAGE (+) = userenv('LANG')
      AND    LKUP1.LOOKUP_CODE(+) = ATSK.TASK_TYPE_CODE
      AND    LKUP3.LOOKUP_TYPE(+) = 'AHL_VWP_TASK_STATUS'
      AND    LKUP3.LOOKUP_CODE(+) = ATSK.STATUS_CODE
      AND    LKUP3.LANGUAGE (+) = userenv('LANG')
      AND    AVTS.VISIT_ID = ATSK.VISIT_ID
      AND    AVTS.TEMPLATE_FLAG = 'N'
      AND    ATSK.DEPARTMENT_ID = BDPT.DEPARTMENT_ID(+)
      AND    ATSK.VISIT_TASK_ID = AWO.VISIT_TASK_ID(+)
      AND    NVL(ATSK.STATUS_CODE,'X') <> 'DELETED'
      AND    ATSK.TASK_TYPE_CODE <> 'SUMMARY'
      AND    LKUP2.LOOKUP_TYPE(+) = 'AHL_JOB_STATUS'
      AND    LKUP2.LOOKUP_CODE(+) = AWO.STATUS_CODE
      AND    LKUP2.LANGUAGE (+) = userenv('LANG')
      AND    ATSK.STAGE_ID = ASTG.STAGE_ID(+)
      AND    ATSK.VISIT_TASK_ID = ATSKL.VISIT_TASK_ID
      AND    ATSKL.LANGUAGE(+) = USERENV('LANG')
      AND    ATSK.VISIT_TASK_ID = x_T_id;

      c_task_rec c_non_summary_task_details%ROWTYPE;

    CURSOR c_mr_task_details (x_T_id IN NUMBER) IS
         SELECT   AVTS.VISIT_ID VISIT_ID,
                  AVTS.VISIT_NUMBER VISIT_NUMBER,
                  AVTS.TEMPLATE_FLAG TEMPLATE_FLAG,
                  AVTS.STATUS_CODE VISIT_STATUS_CODE,
                  ATSK.VISIT_TASK_ID TASK_ID,
                  ATSK.VISIT_TASK_NUMBER TASK_NUMBER,
                  ATSKL.VISIT_TASK_NAME TASK_NAME,
                  ATSK.INVENTORY_ITEM_ID ITEM_ID,
                  MTSB.CONCATENATED_SEGMENTS ITEM_NAME,
                  ATSK.ITEM_ORGANIZATION_ID ITEM_ORGANIZATION_ID,
                  ATSK.INSTANCE_ID UNIT_ID,
                  ATSK.QUANTITY QUANTITY, --Added by rnahata for Issue 105
                  CSIS.SERIAL_NUMBER UNIT_NAME,
                  CSIS.INSTANCE_NUMBER INSTANCE_NUMBER, --Added by rnahata for Issue 105
                  CSIS.UNIT_OF_MEASURE UOM, --Added by rnahata for Issue 105
                  ATSK.MR_ROUTE_ID MR_ROUTE_ID,
                  AMRH.TITLE MR_NAME,
                  to_char(NULL) ROUTE_NAME,
                  to_char(NULL) ROUTE_TYPE_CODE,
                  to_char(NULL) ROUTE_TYPE,
                  AWO.WORKORDER_ID WORK_ORDER_ID,
                  AWO.WORKORDER_NAME WORKORDER_NAME,
                  AWO.STATUS_CODE WORKORDER_STATUS,
                  LKUP2.MEANING WORKORDER_STATUS_MEANING,
                  AWO.ACTUAL_START_DATE WORKORDER_START_DATE,
                  AWO.ACTUAL_END_DATE WORKORDER_END_DATE,
                  ATSK.SERVICE_REQUEST_ID SERVICE_REQ_ID,
                  SR.INCIDENT_NUMBER SERVICE_REQ_NAME,
                  ATSK.START_DATE_TIME START_DATE_TIME,
                  ATSK.END_DATE_TIME END_DATE_TIME,
                  -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010  :: Fetch past start and end dates too
                  ATSK.PAST_TASK_START_DATE,
                  ATSK.PAST_TASK_END_DATE,
                  ATSK.TASK_TYPE_CODE TASK_TYPE_CODE,
                  LKUP1.MEANING TASK_TYPE_NAME,
                  ATSK.STATUS_CODE TASK_STATUS_CODE,
                  LKUP3.MEANING TASK_STATUS_NAME,
                  ATSK.STAGE_ID STAGE_ID,
                  ASTG.STAGE_NUM STAGE_NUM,
                  ASTG.STAGE_NAME STAGE_NAME,
                  AUEF.DUE_DATE DUE_BY_DATE,
                  ATSK.DEPARTMENT_ID,
                  BDPT.DESCRIPTION DEPARTMENT_NAME,
                  ATSK.ORIGINATING_TASK_ID ORIGINATING_TASK_ID,
                  ORIGTSK.VISIT_TASK_NUMBER ORIGINATING_TASK_NUMBER,
                  ORIGTSK.VISIT_TASK_NAME ORIGINATING_TASK_NAME,
                  ATSK.MR_ID MR_ID,
                  ATSK.UNIT_EFFECTIVITY_ID UNIT_EFFECTIVITY_ID,
                  AMRH.DESCRIPTION MR_DESCRIPTION,
                  --manisaga added all the attributes and ROUTE_ID as part of DFF Enablement 0n 18-Feb-2010--Start
                  to_number(NULL) ROUTE_ID,
                  ATSK.attribute_category,
                  ATSK.Attribute1,
                  ATSK.Attribute2,
                  ATSK.Attribute3,
                  ATSK.Attribute4,
                  ATSK.Attribute5,
                  ATSK.Attribute6,
                  ATSK.Attribute7,
                  ATSK.Attribute8,
                  ATSK.Attribute9,
                  ATSK.Attribute10,
                  ATSK.Attribute11,
                  ATSK.Attribute12,
                  ATSK.Attribute13,
                  ATSK.Attribute14,
                  ATSK.Attribute15
                  --manisaga added all the attributes and ROUTE_ID as part of DFF Enablement 0n 18-Feb-2010--End
         FROM     AHL_VISITS_B AVTS,
                  AHL_VISIT_TASKS_B ATSK,
                  AHL_VISIT_TASKS_TL ATSKL,
                  AHL_VISIT_TASKS_VL ORIGTSK,
                  AHL_MR_HEADERS_VL AMRH,
                  AHL_UNIT_EFFECTIVITIES_B AUEF,
                  CSI_ITEM_INSTANCES CSIS,
                  CS_INCIDENTS_ALL_B SR,
                  AHL_VWP_STAGES_VL ASTG,
                  BOM_DEPARTMENTS BDPT,
                  FND_LOOKUP_VALUES LKUP1,
                  FND_LOOKUP_VALUES LKUP2,
                  FND_LOOKUP_VALUES LKUP3,
                  MTL_SYSTEM_ITEMS_B_KFV MTSB,
                  AHL_WORKORDERS AWO
         WHERE    ATSK.INSTANCE_ID = CSIS.INSTANCE_ID (+)
         AND      ATSK.ORIGINATING_TASK_ID = ORIGTSK.VISIT_TASK_ID(+)
         AND      ATSK.SERVICE_REQUEST_ID = SR.INCIDENT_ID(+)
         AND      ATSK.UNIT_EFFECTIVITY_ID = AUEF.UNIT_EFFECTIVITY_ID(+)
         AND      ATSK.INVENTORY_ITEM_ID = MTSB.INVENTORY_ITEM_ID(+)
         AND      ATSK.ITEM_ORGANIZATION_ID = MTSB.ORGANIZATION_ID(+)
         AND      LKUP1.LOOKUP_TYPE(+) = 'AHL_VWP_TASK_TYPE'
         AND      LKUP1.LOOKUP_CODE(+) = ATSK.TASK_TYPE_CODE
         AND      LKUP1.LANGUAGE (+) = userenv('LANG')
         AND      LKUP3.LOOKUP_TYPE(+) = 'AHL_VWP_TASK_STATUS'
         AND      LKUP3.LOOKUP_CODE(+) = ATSK.STATUS_CODE
         AND      LKUP3.LANGUAGE (+) = userenv('LANG')
         AND      AVTS.VISIT_ID = ATSK.VISIT_ID
         AND      AVTS.TEMPLATE_FLAG = 'N'
         AND      ATSK.DEPARTMENT_ID = BDPT.DEPARTMENT_ID(+)
         AND      ATSK.VISIT_TASK_ID = AWO.VISIT_TASK_ID(+)
         AND      ATSK.MR_ID IS NOT NULL
         AND      NVL(ATSK.STATUS_CODE,'X') <> 'DELETED'
         AND      ATSK.TASK_TYPE_CODE = 'SUMMARY'
         AND      AMRH.MR_HEADER_ID = ATSK.MR_ID
         AND      LKUP2.LOOKUP_TYPE(+) = 'AHL_JOB_STATUS'
         AND      LKUP2.LOOKUP_CODE(+) = AWO.STATUS_CODE
         AND      LKUP2.LANGUAGE (+) = userenv('LANG')
         AND      ATSK.STAGE_ID = ASTG.STAGE_ID(+)
         AND      ATSK.VISIT_TASK_ID = ATSKL.VISIT_TASK_ID
         AND      ATSKL.LANGUAGE(+) = USERENV('LANG')
         AND      ATSK.VISIT_TASK_ID = x_T_id;

   CURSOR  c_sr_task_details (x_T_id IN NUMBER) IS
         SELECT   AVTS.VISIT_ID VISIT_ID,
                  AVTS.VISIT_NUMBER VISIT_NUMBER,
                  AVTS.TEMPLATE_FLAG TEMPLATE_FLAG,
                  AVTS.STATUS_CODE VISIT_STATUS_CODE,
                  ATSK.VISIT_TASK_ID TASK_ID,
                  ATSK.VISIT_TASK_NUMBER TASK_NUMBER,
                  ATSK.VISIT_TASK_NAME TASK_NAME,
                  ATSK.INVENTORY_ITEM_ID ITEM_ID,
                  MTSB.CONCATENATED_SEGMENTS ITEM_NAME,
                  ATSK.ITEM_ORGANIZATION_ID ITEM_ORGANIZATION_ID,
                  ATSK.INSTANCE_ID UNIT_ID,
                  ATSK.QUANTITY QUANTITY, --Added by rnahata for Issue 105
                  CSIS.SERIAL_NUMBER UNIT_NAME,
                  CSIS.INSTANCE_NUMBER INSTANCE_NUMBER, --Added by rnahata for Issue 105
                  CSIS.UNIT_OF_MEASURE UOM, --Added by rnahata for Issue 105
                  to_number(null) MR_ROUTE_ID,
                  to_char(NULL) MR_NAME,
                  to_char(NULL) ROUTE_NAME,
                  to_char(NULL) ROUTE_TYPE_CODE,
                  to_char(NULL) ROUTE_TYPE,
                  AWO.WORKORDER_ID WORK_ORDER_ID,
                  AWO.WORKORDER_NAME WORKORDER_NAME,
                  AWO.STATUS_CODE WORKORDER_STATUS,
                  LKUP3.MEANING WORKORDER_STATUS_MEANING,
                  AWO.ACTUAL_START_DATE WORKORDER_START_DATE,
                  AWO.ACTUAL_END_DATE WORKORDER_END_DATE,
                  ATSK.SERVICE_REQUEST_ID SERVICE_REQ_ID,
                  SR.INCIDENT_NUMBER SERVICE_REQ_NAME,
                  ATSK.START_DATE_TIME START_DATE_TIME,
                  ATSK.END_DATE_TIME END_DATE_TIME,
                  -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010  :: Fetch past start and end dates too
                  ATSK.PAST_TASK_START_DATE,
                  ATSK.PAST_TASK_END_DATE,
                  ATSK.TASK_TYPE_CODE TASK_TYPE_CODE,
                  LKUP1.MEANING TASK_TYPE_NAME,
                  ATSK.STATUS_CODE TASK_STATUS_CODE,
                  LKUP2.MEANING TASK_STATUS_NAME,
                  ATSK.STAGE_ID STAGE_ID,
                  ASTG.STAGE_NUM STAGE_NUM,
                  ASTG.STAGE_NAME STAGE_NAME,
                  to_date(NULL) DUE_BY_DATE,
                  ATSK.DEPARTMENT_ID DEPARTMENT_ID,
                  BDPT.DESCRIPTION DEPARTMENT_NAME,
                  ATSK.ORIGINATING_TASK_ID ORIGINATING_TASK_ID,
                  ORIGTSK.VISIT_TASK_NUMBER ORIGINATING_TASK_NUMBER,
                  ORIGTSK.VISIT_TASK_NAME ORIGINATING_TASK_NAME,
                  to_number(null) MR_ID,
                  ATSK.UNIT_EFFECTIVITY_ID UNIT_EFFECTIVITY_ID,
                  to_char(NULL) MR_DESCRIPTION,
                  --manisaga added all the attributes and ROUTE_ID as part of DFF Enablement 0n 18-Feb-2010--Start
                  to_number(NULL) ROUTE_ID,
                  ATSK.attribute_category,
                  ATSK.Attribute1,
                  ATSK.Attribute2,
                  ATSK.Attribute3,
                  ATSK.Attribute4,
                  ATSK.Attribute5,
                  ATSK.Attribute6,
                  ATSK.Attribute7,
                  ATSK.Attribute8,
                  ATSK.Attribute9,
                  ATSK.Attribute10,
                  ATSK.Attribute11,
                  ATSK.Attribute12,
                  ATSK.Attribute13,
                  ATSK.Attribute14,
                  ATSK.Attribute15
                  --manisaga added all the attributes and ROUTE_ID as part of DFF Enablement 0n 18-Feb-2010--End
         FROM     AHL_VISITS_VL AVTS,
                  AHL_VISIT_TASKS_VL ATSK,
                  AHL_VISIT_TASKS_VL ORIGTSK,
                  CSI_ITEM_INSTANCES CSIS,
                  CS_INCIDENTS_ALL_B SR,
                  AHL_VWP_STAGES_VL ASTG,
                  BOM_DEPARTMENTS BDPT,
                  FND_LOOKUP_VALUES_VL LKUP1,
                  FND_LOOKUP_VALUES_VL LKUP2,
                  FND_LOOKUP_VALUES_VL LKUP3,
                  MTL_SYSTEM_ITEMS_B_KFV MTSB,
                  AHL_WORKORDERS AWO
         WHERE    ATSK.INSTANCE_ID = CSIS.INSTANCE_ID (+)
         AND      ATSK.ORIGINATING_TASK_ID = ORIGTSK.VISIT_TASK_ID(+)
         AND      ATSK.SERVICE_REQUEST_ID = SR.INCIDENT_ID(+)
         AND      ATSK.INVENTORY_ITEM_ID = MTSB.INVENTORY_ITEM_ID(+)
         AND      ATSK.ITEM_ORGANIZATION_ID = MTSB.ORGANIZATION_ID(+)
         AND      ATSK.VISIT_TASK_ID = AWO.VISIT_TASK_ID(+)
         AND      LKUP1.LOOKUP_TYPE(+) = 'AHL_VWP_TASK_TYPE'
         AND      LKUP1.LOOKUP_CODE(+) = ATSK.TASK_TYPE_CODE
         AND      LKUP2.LOOKUP_TYPE(+) = 'AHL_VWP_TASK_STATUS'
         AND      LKUP2.LOOKUP_CODE(+) = ATSK.STATUS_CODE
         AND      LKUP3.LOOKUP_TYPE(+) = 'AHL_JOB_STATUS'
         AND      LKUP3.LOOKUP_CODE(+) = AWO.STATUS_CODE
         AND      AVTS.VISIT_ID = ATSK.VISIT_ID
         AND      AVTS.TEMPLATE_FLAG = 'N'
         AND      ATSK.DEPARTMENT_ID = BDPT.DEPARTMENT_ID(+)
         AND      ATSK.MR_ID IS NULL
         AND      NVL(ATSK.STATUS_CODE,'X') <> 'DELETED'
         AND      ATSK.TASK_TYPE_CODE = 'SUMMARY'
         AND      ATSK.STAGE_ID = ASTG.STAGE_ID(+)
         AND      ATSK.VISIT_TASK_ID = x_T_id;

  -- To find all task related information which is not in visit/template search views
    CURSOR c_task_data(p_task_id IN NUMBER) IS
      SELECT T1.*, T2.TEMPLATE_FLAG, T2.ORGANIZATION_ID
      FROM AHL_VISIT_TASKS_VL T1, AHL_VISITS_VL T2
      WHERE T1.visit_task_id = p_task_id
      AND T1.VISIT_ID = T2.VISIT_ID;
      c_task_data_rec c_task_data%ROWTYPE;

  -- To find task's unit effectivity related information
    CURSOR c_unit_effectivity (p_ue_id IN NUMBER) IS
      SELECT MR_Interval_Id, Due_Date FROM AHL_UNIT_EFFECTIVITIES_VL
      WHERE (STATUS_CODE IS NULL OR STATUS_CODE IN ('INIT-DUE', 'DEFERRED'))
      AND UNIT_EFFECTIVITY_ID = p_ue_id;
      c_unit_effectivity_rec c_unit_effectivity%ROWTYPE;

 -- To find task's route related information
    CURSOR c_zone (p_route_id IN NUMBER) IS
      /*
      SELECT ZONE_CODE, SUB_ZONE_CODE, TIME_SPAN FROM AHL_ROUTES_V
      WHERE ROUTE_ID = p_route_id;
      */
      /*
      Modified by rnahata for Bug 6447221 / 6512871
      Removed timespan fron cursor, since task duration will be calculated
      based on route time span as well as resource requirements
      */
      -- AnRaj: Changed query for perf issue#4, Bug 4919465
      SELECT   ZONE_CODE, SUB_ZONE_CODE
      FROM     AHL_ROUTES_APP_V
      WHERE    ROUTE_ID = p_route_id;

 -- To find task's route related information
    CURSOR c_route (p_mr_route_id IN NUMBER) IS
     SELECT A.ROUTE_ID
      FROM AHL_MR_ROUTES A, AHL_MR_HEADERS_APP_V B
      WHERE A.MR_HEADER_ID=B.MR_HEADER_ID
      AND A.MR_ROUTE_ID = p_mr_route_id;

 -- To find task's unit effectivity tolerance related information
    CURSOR c_tolerance (p_interval_id IN NUMBER) IS
      SELECT Tolerance_Before, Tolerance_After
      FROM Ahl_MR_Intervals_APP_V WHERE MR_Interval_Id=p_interval_id;
      c_tolerance_rec c_tolerance%ROWTYPE;

 -- To find task's unit effectivity unit of measure related information
 /*   CURSOR c_unitofmeasure (l_tol_before IN NUMBER, l_tol_after IN NUMBER) IS
      SELECT UOM.Unit_of_Measure
      FROM MTL_Units_Of_Measure_vl UOM, CS_Counters C, Ahl_MR_Intervals_APP_V MRI
      WHERE UOM.Uom_Code = C.Uom_Code AND C.Counter_Id = MRI.Counter_Id AND
      Tolerance_Before = l_tol_before AND Tolerance_After = l_tol_after;
*/
-- AnRaj: Changed query for perf issue#5, Bug 4919465
   CURSOR c_unitofmeasure (p_interval_id IN NUMBER) IS
      SELECT   UOM.Unit_of_Measure
      FROM     MTL_Units_Of_Measure UOM,
               csi_counter_template_b C,
               AHL_MR_INTERVALS MRI
      WHERE    UOM.Uom_Code = C.Uom_Code
      AND      C.Counter_Id = MRI.Counter_Id
      AND      MR_INTERVAL_ID =  p_interval_id;
   c_unitofmeasure_rec c_unitofmeasure%ROWTYPE;

 -- To find task number for cost_parent_id and originating task id
   CURSOR c_number(x_id IN NUMBER) IS
     SELECT Visit_Task_Number FROM Ahl_Visit_Tasks_B
     WHERE Visit_Task_Id = x_id;

 -- To find project task nubmer for project's task
   CURSOR c_proj_task (x_id IN NUMBER) IS
     SELECT TASK_NUMBER FROM PA_TASKS WHERE TASK_ID = x_id;

 -- Added by Senthil for 11.5.10 enhancements.
   CURSOR c_workorders (p_visit_id IN NUMBER, p_visit_task_id IN NUMBER)
   IS
   SELECT
/*  scheduled_start_date,
    scheduled_end_date
    FROM
    ahl_workorders_v
    WHERE visit_id = p_visit_id
    AND visit_task_id = p_visit_task_id;
*/
-- AnRaj: Changed query for perf issue#2, Bug 4919465
         wdj.scheduled_start_date scheduled_start_date,
         wdj.scheduled_completion_date  scheduled_end_date
FROM     wip_discrete_jobs wdj,
         ahl_workorders wo
WHERE    wdj.wip_entity_id = wo.wip_entity_id
AND      visit_id = p_visit_id
AND      visit_task_id = p_visit_task_id;

BEGIN
  IF (l_log_procedure >= l_log_current_level) THEN
     fnd_log.string(l_log_procedure,
                    L_DEBUG_KEY ||'.begin',
                    'At the start of PL SQL procedure.' ||
                    ', p_task_id = ' || p_task_id);
  END IF;

  -- Standard start of API savepoint
  SAVEPOINT Get_Task_Details;

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
   ------------------------Cursor------------------------------------

      -- Cursor for task related information in search task view
      /*
      OPEN c_task(p_task_id);
      FETCH c_task INTO c_task_rec;
      CLOSE c_task;
      */

      OPEN c_task_type(p_task_id);
      FETCH c_task_type INTO c_task_type_rec;
      CLOSE c_task_type;

      IF c_task_type_rec.task_type_code <> 'SUMMARY' THEN
         OPEN  c_non_summary_task_details(p_task_id);
         FETCH c_non_summary_task_details INTO c_task_rec;
         CLOSE c_non_summary_task_details;
      ELSIF c_task_type_rec.task_type_code = 'SUMMARY' AND c_task_type_rec.mr_id  IS NOT NULL THEN
         OPEN  c_mr_task_details(p_task_id);
         FETCH c_mr_task_details INTO c_task_rec;
         CLOSE c_mr_task_details;
      ELSIF c_task_type_rec.task_type_code = 'SUMMARY' AND c_task_type_rec.mr_id  IS NULL THEN
         OPEN  c_sr_task_details(p_task_id);
         FETCH c_sr_task_details INTO c_task_rec;
         CLOSE c_sr_task_details;
      END IF;

      -- Cursor for task related information not in search task view
      OPEN c_task_data(p_task_id);
      FETCH c_task_data INTO c_task_data_rec;
      CLOSE c_task_data;

      -- Cursor to find visit information
      OPEN c_visit (c_task_data_rec.visit_id);
      FETCH c_visit INTO c_visit_rec;
      CLOSE c_visit;

      -- For Debug Messages
      IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         ': task id = ' || p_task_id ||
                         ': version, task name, task number = ' || c_task_data_rec.object_version_number || '---' || c_task_rec.task_name || '---' || c_task_rec.task_number ||
                         ': item id, org id, itemname = ' || c_task_rec.item_id || '-' || c_task_rec.item_organization_id || '-' || c_task_rec.item_name ||
                         ': mr_routeid, route_name, mr_name= ' || c_task_rec.mr_route_id || '-' || c_task_rec.route_name || '-' || c_task_rec.mr_name ||
                         ': serial number = ' || c_task_rec.unit_name ||
                         ': instance = ' || c_task_rec.instance_number ||
                         ': quantity = ' || c_task_rec.quantity ||
                         ': uom = ' || c_task_rec.uom ||
                         ': servicenubmer, starthour, = ' || c_task_rec.service_req_name || '-' || c_task_data_rec.start_from_hour ||
                         ': l_duration = ' || l_duration ||
                         ': costid, originatingid = ' || c_task_data_rec.cost_parent_id  || '-' || c_task_data_rec.originating_task_id ||
                         ': task type code, value = ' || c_task_rec.task_type_code || '-' || c_task_rec.task_type_name ||
                         ': department_id  = ' || c_task_data_rec.department_id);
      END IF;

      -- Check the Task Type code
      -- For PLANNED in case then get required data for Unit Effectivity
      IF c_task_rec.TASK_TYPE_CODE = 'PLANNED' THEN
           OPEN c_unit_effectivity(c_task_data_rec.unit_effectivity_id);
           FETCH c_unit_effectivity INTO c_unit_effectivity_rec;
           CLOSE c_unit_effectivity;

           OPEN c_tolerance (c_unit_effectivity_rec.mr_interval_id);
           FETCH c_tolerance INTO c_tolerance_rec;
           CLOSE c_tolerance;

           OPEN c_unitofmeasure (c_unit_effectivity_rec.mr_interval_id);
           FETCH c_unitofmeasure INTO c_unitofmeasure_rec;
           CLOSE c_unitofmeasure;

           l_tol_after   := c_tolerance_rec.tolerance_after ;
           l_tol_before  := c_tolerance_rec.tolerance_before;
           l_due_by_date := TRUNC(c_unit_effectivity_rec.due_date) ;
           l_uom         := c_unitofmeasure_rec.unit_of_measure ;
      ELSE
           l_tol_after   := NULL ;
           l_tol_before  := NULL ;
           l_due_by_date := NULL ;
           l_uom         := NULL ;
      END IF;

      IF c_task_rec.TASK_TYPE_CODE = 'PLANNED' OR c_task_rec.TASK_TYPE_CODE = 'UNPLANNED' THEN
           OPEN c_route(c_task_rec.mr_route_id);
           FETCH c_route INTO l_route_id;
           CLOSE c_route;

           OPEN c_zone(l_route_id);
           FETCH c_zone INTO l_zone, l_sub_zone ;
           CLOSE c_zone;
           /*
           Added by rnahata for Bug 6447221 / 6512871
           Task duration will be calculated based on route time span as well as resource requirements
           */
           l_duration := AHL_VWP_TIMES_PVT.Get_task_duration(c_task_rec.quantity,l_route_id);
       ELSE
            l_zone             := NULL;
            l_sub_zone         := NULL;
            l_duration         := c_task_data_rec.duration;
       END IF;

  -- For finding visit task number for originating task id
  IF c_task_data_rec.originating_task_id IS NOT NULL AND c_task_data_rec.originating_task_id <> Fnd_Api.g_miss_num THEN
       OPEN c_number(c_task_data_rec.originating_task_id);
       FETCH c_number INTO l_origin_num;
       CLOSE c_number;
  ELSE
     l_origin_num := NULL;
  END IF;

  -- For finding visit task number for cost parent id
  IF c_task_data_rec.cost_parent_id IS NOT NULL AND c_task_data_rec.cost_parent_id <> Fnd_Api.g_miss_num THEN
       OPEN c_number(c_task_data_rec.cost_parent_id);
       FETCH c_number INTO l_parent_num;
       CLOSE c_number;
  ELSE
      l_parent_num := NULL;
  END IF;

  -- Added by Senthil for 11.5.10 Changes
  IF ( upper(c_task_rec.visit_status_code) = 'PLANNING' or
       (upper(c_task_rec.visit_status_code) = 'PARTIALLY RELEASED' and upper(c_task_rec.task_status_code) = 'PLANNING')) THEN
        --Fetch directly from visit task record
         l_task_start_date := c_task_rec.START_DATE_TIME;
         l_task_end_date := c_task_rec.END_DATE_TIME;

  ELSE
        --Fetch from the workorder
  OPEN c_workorders(c_task_rec.visit_id,p_task_id);
  FETCH c_workorders INTO l_task_start_date,l_task_end_date;
  CLOSE c_workorders;

  -- Added by sowsubra on July 24, 2007 for B6032334
  OPEN c_proj_task(c_task_data_rec.project_task_id);
  FETCH c_proj_task INTO l_proj_task_number;
  CLOSE c_proj_task;
  -- End Changes by sowsubra on July 24, 2007 for B6032334

  END IF;

     -- For Debug Messages
     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'l_origin_num = ' ||  l_origin_num ||
                        'l_parent_num = ' || l_parent_num ||
                        'l_task_start_date = ' || l_task_start_date ||
                        'l_task_end_date = '|| l_task_end_date ||
                        'l_proj_task_number = ' || l_proj_task_number );
     END IF;

        -- For assigning all values of visit to output record type
        l_task_rec.visit_id               :=  c_task_rec.visit_id ;
        l_task_rec.template_flag          :=  c_task_rec.template_flag ;
        l_task_rec.visit_task_id          :=  c_task_rec.task_id ;
        l_task_rec.visit_task_number      :=  c_task_rec.task_number ;
        l_task_rec.visit_task_name        :=  c_task_rec.task_name ;
        l_task_rec.object_version_number  :=  c_task_data_rec.object_version_number ;
        l_task_rec.duration               :=  l_duration ;
        l_task_rec.inventory_item_id      :=  c_task_rec.item_id ;
        l_task_rec.item_organization_id   :=  c_task_rec.item_organization_id ;
        l_task_rec.item_name              :=  c_task_rec.item_name ;
        l_task_rec.department_id          :=  c_task_rec.department_id ;
        l_task_rec.dept_name              :=  c_task_rec.department_name;
        l_task_rec.serial_number          :=  c_task_rec.unit_name ;
        l_task_rec.mr_route_id            :=  c_task_rec.mr_route_id ;
        l_task_rec.route_number           :=  c_task_rec.route_name ;
        l_task_rec.mr_title               :=  c_task_rec.mr_name ;
        l_task_rec.mr_id                  :=  c_task_rec.mr_id;
        l_task_rec.zone_name              :=  l_zone;
        l_task_rec.sub_zone_name          :=  l_sub_zone;
        l_task_rec.tolerance_after        :=  l_tol_after;
        l_task_rec.tolerance_before       :=  l_tol_before;
        l_task_rec.tolerance_UOM          :=  l_uom;
        l_task_rec.service_request_number :=  c_task_rec.service_req_name;
        l_task_rec.start_from_hour        :=  c_task_data_rec.start_from_hour;
        l_task_rec.cost_parent_number     :=  l_parent_num ;
        l_task_rec.orginating_task_number :=  l_origin_num ;
        l_task_rec.task_type_code         :=  c_task_rec.task_type_code ;
        l_task_rec.task_type_value        :=  c_task_rec.task_type_name;
        l_task_rec.due_by_date            :=  l_due_by_date;
        --Post 11.5.10 Changed by cxcheng
        l_task_rec.task_start_date        :=  l_task_start_date ;
        l_task_rec.task_end_date          :=  l_task_end_date ;
        -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Populate the past date details into the out param
        l_task_rec.past_task_start_date   :=  c_task_rec.past_task_start_date;
        l_task_rec.past_task_end_date     :=  c_task_rec.past_task_end_date;
        l_task_rec.description            :=  c_task_data_rec.description ;
        l_task_rec.project_task_id        :=  c_task_data_rec.project_task_id ;
        l_task_rec.project_task_number    :=  l_proj_task_number ;
        l_task_rec.WO_Name                :=  c_task_rec.workorder_name ;
        l_task_rec.WO_Status              :=  c_task_rec.workorder_status_meaning ;
        l_task_rec.WO_Start_Date          :=  c_task_rec.workorder_start_date ;
        l_task_rec.WO_End_Date            :=  c_task_rec.workorder_end_date ;
        -- Post 11.5.10 Changes by Senthil.
        l_task_rec.STAGE_ID               :=   c_task_rec.STAGE_ID;
        l_task_rec.STAGE_NAME             :=   c_task_rec.STAGE_NAME;
        l_task_rec.TASK_TYPE_CODE         :=   c_task_rec.TASK_TYPE_CODE;
        l_task_rec.TASK_TYPE_VALUE        :=   c_task_rec.TASK_TYPE_NAME;
        l_task_rec.TASK_STATUS_CODE       :=   c_task_rec.TASK_STATUS_CODE;
        l_task_rec.TASK_STATUS_VALUE      :=   c_task_rec.TASK_STATUS_NAME;
        l_task_rec.instance_id            :=   c_task_data_rec.instance_id;
        -- Begin changes by rnahata for Issue 105
        l_task_rec.quantity               :=   c_task_rec.quantity;
        l_task_rec.UOM                    :=   c_task_rec.uom;
        l_task_rec.Instance_number        :=   c_task_rec.instance_number;
        -- End changes by rnahata for Issue 105

        --manisaga assigned all the attributes from c_task_rec to output record and ROUTE_ID as part of DFF Enablement 0n 18-Feb-2010--Start
        l_task_rec.attribute_category   :=   c_task_rec.attribute_category;
        l_task_rec.attribute1           :=   c_task_rec.attribute1;
        l_task_rec.attribute2           :=   c_task_rec.attribute2;
        l_task_rec.attribute3           :=   c_task_rec.attribute3;
        l_task_rec.attribute4           :=   c_task_rec.attribute4;
        l_task_rec.attribute5           :=   c_task_rec.attribute5;
        l_task_rec.attribute6           :=   c_task_rec.attribute6;
        l_task_rec.attribute7           :=   c_task_rec.attribute7;
        l_task_rec.attribute8           :=   c_task_rec.attribute8;
        l_task_rec.attribute9           :=   c_task_rec.attribute9;
        l_task_rec.attribute10          :=   c_task_rec.attribute10;
        l_task_rec.attribute11          :=   c_task_rec.attribute11;
        l_task_rec.attribute12          :=   c_task_rec.attribute12;
        l_task_rec.attribute13          :=   c_task_rec.attribute13;
        l_task_rec.attribute14          :=   c_task_rec.attribute14;
        l_task_rec.attribute15          :=   c_task_rec.attribute15;
        l_task_rec.route_id             :=   c_task_rec.route_id;
        --manisaga assigned all the attributes from c_task_rec to output record and ROUTE_ID as part of DFF Enablement 0n 18-Feb-2010--End

        x_task_rec := l_task_rec;

   ------------------------End of API Body------------------------------------
    -- Standard call to get message count and if count is 1, get message info
       /* Fnd_Msg_Pub.Count_And_Get
        ( p_count => x_msg_count,
          p_data  => x_msg_data,
          p_encoded => Fnd_Api.g_false); */

     --Standard check to count messages
     l_msg_count := Fnd_Msg_Pub.count_msg;

     IF l_msg_count > 0  THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
     END IF;

    -- Debug info.
     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || x_return_status);
     END IF;
EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
   x_return_status := Fnd_Api.G_RET_STS_ERROR;
   ROLLBACK TO Get_Task_Details;
   Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => Fnd_Api.g_false);
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Get_Task_Details;
   Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => Fnd_Api.g_false);
 WHEN OTHERS THEN
      ROLLBACK TO Get_Task_Details;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
    THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data  );
END Get_Task_Details;

--------------------------------------------------------------------
-- PROCEDURE
--    Create_Task
-- PURPOSE
--    To create all types of tasks i.e Unassociated/Summary/Unplanned/Planned
--------------------------------------------------------------------
PROCEDURE Create_Task (
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
  -- Define local variables
  L_API_VERSION CONSTANT NUMBER := 1.0;
  L_API_NAME    CONSTANT VARCHAR2(30) := 'CREATE TASK';
  L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);
  l_return_status        VARCHAR2(1);
  l_task_rec             AHL_VWP_RULES_PVT.Task_Rec_Type := p_x_task_rec;

     -- To find visit related information
   CURSOR c_visit(x_id IN NUMBER) IS
       SELECT * FROM AHL_VISITS_VL
       WHERE VISIT_ID = x_id;
   c_visit_rec c_visit%ROWTYPE;
BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure.');
   END IF;

   --------------------- initialize -----------------------
   SAVEPOINT Create_Task;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_boolean(p_init_msg_list)
   THEN
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

  --------------------Start of API Body-----------------------------------
  -------------------Cursor values------------------------------------
   OPEN c_visit(l_task_rec.visit_id);
   FETCH c_visit INTO c_visit_rec;
   CLOSE c_visit;

   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'Visit Id = ' || c_visit_rec.visit_id ||
                      ', Status Code = ' || c_visit_rec.status_code);
   END IF;

   -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: STARTS
   IF (l_task_rec.PAST_TASK_START_DATE IS NOT NULL
      AND l_task_rec.PAST_TASK_START_DATE <> Fnd_Api.G_MISS_DATE) THEN
       IF (l_task_rec.PAST_TASK_END_DATE IS NULL
          OR l_task_rec.PAST_TASK_START_DATE = Fnd_Api.G_MISS_DATE) THEN
          -- if start date is entered but not end date, throw error
        Fnd_Message.SET_NAME('AHL','AHL_VWP_PAST_TASK_DATE_MAND');
        Fnd_Msg_Pub.ADD;
        RAISE FND_API.G_EXC_ERROR;
       END IF;
       IF (l_task_rec.PAST_TASK_START_DATE >= SYSDATE) THEN
         -- Throw error if start date is not in past
         Fnd_Message.SET_NAME('AHL','AHL_VWP_TASK_PAST_ST_DATE_INV');
         Fnd_Msg_Pub.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       IF (l_task_rec.PAST_TASK_START_DATE < NVL(c_visit_rec.START_DATE_TIME, l_task_rec.PAST_TASK_START_DATE)) THEN
           -- Throw error if past task start date is before the visit start date
           Fnd_Message.SET_NAME('AHL','AHL_VWP_TASK_START_DATE_INVLD');
           Fnd_Msg_Pub.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       IF (l_task_rec.PAST_TASK_START_DATE > l_task_rec.PAST_TASK_END_DATE) THEN
           -- Throw error if past task start date is after the past task end date
           Fnd_Message.SET_NAME('AHL','AHL_VWP_PAST_TASK_DATE_INVLD');
           Fnd_Msg_Pub.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       IF (l_task_rec.PAST_TASK_END_DATE > NVL(c_visit_rec.CLOSE_DATE_TIME,l_task_rec.PAST_TASK_END_DATE)) THEN
          -- Throw error if visit ends before the task
          Fnd_Message.SET_NAME('AHL','AHL_VWP_TASK_END_DATE_INVLD');
          Fnd_Msg_Pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- SKPATHAK :: Bug #9402556 :: 24-FEB-2010 :: Added call to Validate_Past_Task_Dates
       -- Validate past dates against visit stages, task hierarchy and cost parent hierarchy
       AHL_VWP_RULES_PVT.Validate_Past_Task_Dates ( p_task_rec => l_Task_rec,
                                                    x_return_status => l_return_status);
       IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
         IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Returned success from AHL_VWP_RULES_PVT.Validate_Past_Task_Dates');
         END IF;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSE
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

   ELSE -- PAST_TASK_START_DATE is null
       -- SKPATHAK :: Bug #9402279 :: 24-FEB-2010
       -- Changed the condition from l_task_rec.PAST_TASK_START_DATE <> Fnd_Api.G_MISS_DATE
       -- to l_task_rec.PAST_TASK_END_DATE <> Fnd_Api.G_MISS_DATE
       IF (l_task_rec.PAST_TASK_END_DATE IS NOT NULL
          AND l_task_rec.PAST_TASK_END_DATE <> Fnd_Api.G_MISS_DATE) THEN
        Fnd_Message.SET_NAME('AHL','AHL_VWP_PAST_TASK_DATE_MAND');
        Fnd_Msg_Pub.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;
     l_task_rec.PAST_TASK_START_DATE := NULL;
     l_task_rec.PAST_TASK_END_DATE := NULL;
   END IF;
   -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: END


   IF c_visit_rec.status_code IN ('CLOSED','CANCELLED') THEN
      Fnd_Message.SET_NAME('AHL','AHL_VWP_NOT_USE_VISIT');
      Fnd_Msg_Pub.ADD;
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSE
      IF l_task_rec.task_type_code = 'SUMMARY' THEN
         IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Before Calling to Create_Summary_Task, TASK TYPE = ' || l_task_rec.task_type_code);
         END IF;
         Create_Summary_Task
          (
            p_api_version      => l_api_version,
            p_init_msg_list    => p_init_msg_list,
            p_commit           => Fnd_Api.g_false,
            p_validation_level => p_validation_level,
            p_module_type      => p_module_type,
            p_x_task_rec       => l_task_rec,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data
          );

         IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'After Calling Create_Summary_Task' ||
                            ', TASK ID =  ' || l_task_rec.visit_task_id ||
                            ', TASK NUMBER = ' || l_task_rec.visit_task_number ||
                            ', Return Status = ' || l_return_status );
         END IF;
         -- set OUT value
         p_x_task_rec.Visit_Task_ID := l_task_rec.Visit_Task_ID;
         p_x_task_rec.Visit_Task_Number := l_task_rec.Visit_Task_Number;
      ELSIF l_task_rec.task_type_code = 'PLANNED' THEN
         -- Call AHL_VWP_PLAN_TASKS_PVT
         IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Before Calling to AHL_VWP_PLAN_TASKS_PVT.Create_Planned_Task, TASK TYPE = ' || l_task_rec.task_type_code);
         END IF;
         AHL_VWP_PLAN_TASKS_PVT.Create_Planned_Task (
            p_api_version      => l_api_version,
            p_init_msg_list    => p_init_msg_list,
            p_commit           => Fnd_Api.g_false,
            p_validation_level => p_validation_level,
            p_module_type      => p_module_type,
            p_x_task_rec       => l_task_rec,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data
         );
         IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'After Calling AHL_VWP_PLAN_TASKS_PVT.Create_Planned_Task' ||
                            ', TASK ID =  ' || l_task_rec.visit_task_id ||
                            ', TASK NUMBER = ' || l_task_rec.visit_task_number ||
                            ', Return Status = ' || l_return_status );
         END IF;
      ELSIF l_task_rec.task_type_code = 'UNPLANNED' THEN
         -- Call AHL_VWP_UNPLAN_TASKS_PVT
         IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Before Calling AHL_VWP_UNPLAN_TASKS_PVT.Create_Unplanned_Task, TASK TYPE = ' || l_task_rec.task_type_code);
         END IF;
         AHL_VWP_UNPLAN_TASKS_PVT.Create_Unplanned_Task (
            p_api_version      => l_api_version,
            p_init_msg_list    => p_init_msg_list,
            p_commit           => Fnd_Api.g_false,
            p_validation_level => p_validation_level,
            p_module_type      => p_module_type,
            p_x_task_rec       => l_task_rec,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data
         );
         IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'After Calling AHL_VWP_UNPLAN_TASKS_PVT.Create_Unplanned_Task' ||
                            ', TASK ID =  ' || l_task_rec.visit_task_id ||
                            ', TASK NUMBER = ' || l_task_rec.visit_task_number ||
                            ', Return Status = ' || l_return_status );
         END IF;
      ELSE
         IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Before Calling Create_Unassociated_Task, TASK TYPE = ' || l_task_rec.task_type_code);
         END IF;
         Create_Unassociated_Task
         (
            p_api_version      => l_api_version,
            p_init_msg_list    => p_init_msg_list,
            p_commit           => Fnd_Api.g_false,
            p_validation_level => p_validation_level,
            p_module_type      => p_module_type,
            p_x_task_rec       => l_task_rec,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data
          );
         -- set OUT value
         p_x_task_rec.Visit_Task_ID := l_task_rec.Visit_Task_ID;
         p_x_task_rec.Visit_Task_Number := l_task_rec.Visit_Task_Number;
         IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'After Calling Create_Unassociated_Task' ||
                            'Task Id =  ' || l_task_rec.visit_task_id ||
                            'Task Number = ' || l_task_rec.visit_task_number ||
                            'Return Status = ' || l_return_status );
         END IF;
      END IF;  -- task type code check
   END IF; -- Visit check

-- post 115.10 changes start

   IF c_visit_rec.STATUS_CODE = 'RELEASED' THEN
      UPDATE AHL_VISITS_B
        SET  STATUS_CODE = 'PARTIALLY RELEASED',
             OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1
        WHERE VISIT_ID =c_visit_rec.VISIT_ID ;
    END IF;

-- post 115.10 changes end

    --------------------End of API Body-------------------------------------
   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 OR l_return_status <> Fnd_Api.g_ret_sts_success THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Create_Task;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get(
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Create_Task;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Task;
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
END Create_Task;

--------------------------------------------------------------------
-- PROCEDURE
--    Create_Unassociated_Task
-- PURPOSE
--    To create Unassociated Task for the maintainance visit
--------------------------------------------------------------------
PROCEDURE Create_Unassociated_Task (
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
   L_API_NAME    CONSTANT VARCHAR2(30) := 'CREATE UNASSOCIATED TASK';
   L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   -- Local variables defined for the procedure
   l_task_rec            AHL_VWP_RULES_PVT.Task_Rec_Type := p_x_task_rec;
   l_msg_data            VARCHAR2(2000);
   l_item_name           VARCHAR2(40);
   l_rowid               VARCHAR2(30);
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_item_id             NUMBER;
   l_serial_id           NUMBER;
   l_task_number         NUMBER;
   l_org_id              NUMBER;
   l_visit_task_id       NUMBER;
   l_service_id          NUMBER;
   l_cost_parent_id      NUMBER;
   l_originating_task_id NUMBER;
   l_department_id       NUMBER;

  -- To find visit related information
   CURSOR c_visit(x_id IN NUMBER) IS
    SELECT * FROM AHL_VISITS_VL
    WHERE VISIT_ID = x_id;
   c_visit_rec c_visit%ROWTYPE;

  -- To find Item ID and Item OrgID for Instance Id
  -- while creating unassociated task for a non-routine job
    CURSOR c_Serial (p_serial_id IN NUMBER) IS
     SELECT Inventory_Item_Id, Inv_Master_Organization_Id
     FROM CSI_ITEM_INSTANCES
     WHERE Instance_Id  = p_serial_id;

   -- Begin changes by rnahata for Issue 105
   --Cursor to fetch instance id when instance number is passed
   -- jaramana on Feb 14, 2008
   -- Changed data type to VARCHAR2
   CURSOR c_get_instance_id(p_instance_number IN VARCHAR2) IS
    SELECT instance_id FROM csi_item_instances csii
    WHERE instance_number = p_instance_number;

   --Cursor to fetch instance quantity
   CURSOR c_get_instance_qty(p_instance_id IN NUMBER) IS
    SELECT quantity FROM csi_item_instances csii
    WHERE instance_id = p_instance_id;

    l_instance_qty             NUMBER := 0;
   -- End changes by rnahata for Issue 105

BEGIN
  --------------------Start of API Body-----------------------------------
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure.' ||
                     'Module Type = ' || p_module_type );
   END IF;

   SAVEPOINT Create_Unassociated_Task;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_boolean(p_init_msg_list)
   THEN
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

  --------------------Value OR ID conversion---------------------------
   --Start API Body
   IF p_module_type = 'JSP' THEN
      --l_Task_rec.instance_id       := NULL;
      l_Task_rec.cost_parent_id      := NULL;
      l_Task_rec.originating_task_id := NULL;
      l_Task_rec.department_id       := NULL;
   END IF;

  -------------------Cursor values------------------------------------
   OPEN c_visit(l_task_rec.visit_id);
   FETCH c_visit INTO c_visit_rec;
   CLOSE c_visit;

   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'Visit Id = ' || l_task_rec.visit_id || ', Status Code = ' || c_visit_rec.status_code );
   END IF;

   IF c_visit_rec.status_code IN ('CLOSED','CANCELLED') THEN
       Fnd_Message.SET_NAME('AHL','AHL_VWP_NOT_USE_VISIT');
       Fnd_Msg_Pub.ADD;
       RAISE Fnd_Api.G_EXC_ERROR;
   /*
   Commented to fix bug # 4029318
   ELSIF c_visit_rec.status_code = 'RELEASED' OR c_visit_rec.status_code = 'PARTIALLY RELEASED' THEN
   Added the below condition for the call from Production for SR creation
   */
   ELSIF p_module_type = 'SR' THEN

      IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'Inside status code check = ' || c_visit_rec.status_code ||
                         ', Instance ID = ' || l_Task_rec.instance_id );
      END IF;

      OPEN c_serial(l_Task_rec.instance_id);
      FETCH c_serial INTO l_item_id, l_org_id;
      CLOSE c_serial;

      --Assign the returned value
      l_Task_rec.inventory_item_id := l_item_id;
      l_Task_rec.item_organization_id := l_org_id;
   ELSE
      -- Visit in planning status --
      IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'Before Convert Item Item ID= ' || l_Task_rec.inventory_item_id ||
                         ', Item Org ID= ' || l_Task_rec.item_organization_id ||
                         ', Item Name= ' || l_Task_rec.item_name );
      END IF;
      -- Post 11.5.10 Changes by Senthil.
      AHL_VWP_VISITS_STAGES_PVT.Check_Stage_Name_Or_Id(
       P_VISIT_ID         =>  l_Task_rec.visit_id,
       P_STAGE_NAME       =>  L_task_rec.STAGE_NAME,
       X_STAGE_ID         =>  L_task_rec.STAGE_ID,
       X_RETURN_STATUS    =>  l_return_status,
       x_error_msg_code   =>  l_msg_data  );

     IF NVL(l_return_status,'x') <> Fnd_Api.g_ret_sts_success THEN
              Fnd_Message.SET_NAME('AHL','AHL_VWP_STAGE_NOT_EXISTS');
              Fnd_Msg_Pub.ADD;
         RAISE Fnd_Api.G_EXC_ERROR;
     END IF;
     --
     -- For ITEM
     -- Convert item name to item id
      IF (l_Task_rec.inventory_item_id IS NOT NULL AND
          l_Task_rec.inventory_item_id <> Fnd_Api.G_MISS_NUM) AND
         (l_Task_rec.item_organization_id IS NOT NULL AND
          l_Task_rec.item_organization_id <> Fnd_Api.G_MISS_NUM) THEN

         AHL_VWP_RULES_PVT.Check_Item_Name_Or_Id
            (p_item_id       => l_Task_rec.inventory_item_id,
             p_org_id        => l_Task_rec.item_organization_id,
             p_item_name     => l_Task_rec.item_name,
             x_item_id       => l_item_id,
             x_org_id        => l_org_id,
             x_item_name     => l_item_name,
             x_return_status    => l_return_status,
             x_error_msg_code   => l_msg_data);

         IF NVL(l_return_status,'x') <> Fnd_Api.g_ret_sts_success THEN
            Fnd_Message.SET_NAME('AHL','AHL_VWP_ITEM_NOT_EXISTS');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;

         IF UPPER(l_Task_rec.item_name) <> UPPER(l_item_name) THEN
            IF (l_log_statement >= l_log_current_level) THEN
                fnd_log.string(l_log_statement,
                               L_DEBUG_KEY,
                               ': Compare item name');
            END IF;

            Fnd_Message.SET_NAME('AHL','AHL_VWP_ITEM_USE_LOV');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
      ELSE
         IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            ': Check item else loop');
         END IF;
         Fnd_Message.SET_NAME('AHL','AHL_VWP_ITEM_USE_LOV');
         Fnd_Msg_Pub.ADD;
         RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

      --Assign the returned value
      l_Task_rec.inventory_item_id := l_item_id;
      l_Task_rec.item_organization_id := l_org_id;

      IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         ': Item ID= ' || l_Task_rec.inventory_item_id ||
                         ': Item Org ID= ' || l_Task_rec.item_organization_id ||
                         ': Item Name= ' || l_Task_rec.item_name ||
                         ': Serial Number= ' || l_Task_rec.serial_number );
      END IF;

   END IF; -- End of status_code check

   ----------- Start defining and validate all LOVs on Create Visit's Task UI Screen---
   --
   -- For DEPARTMENT
   -- Convert department name to department id
   IF (l_task_rec.dept_name IS NOT NULL AND l_task_rec.dept_name <> Fnd_Api.G_MISS_CHAR ) THEN

        IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Calling AHL_VWP_RULES_PVT.Check_Dept_Desc_Or_Id');
        END IF;

        AHL_VWP_RULES_PVT.Check_Dept_Desc_Or_Id
              (p_organization_id => c_visit_rec.organization_id,
               p_dept_name       => l_task_rec.dept_name,
               p_department_id   => NULL,
               x_department_id   => l_department_id,
               x_return_status   => l_return_status,
               x_error_msg_code  => l_msg_data);

        IF NVL(l_return_status,'x') <> Fnd_Api.g_ret_sts_success
        THEN
            Fnd_Message.SET_NAME('AHL','AHL_VWP_DEPT_NOT_EXISTS');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        -- Changes for Post 11.5.10 by amagrawa
        Ahl_vwp_rules_pvt.CHECK_DEPARTMENT_SHIFT
          ( P_DEPT_ID       => l_department_id,
            X_RETURN_STATUS => l_return_status);

        IF (NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS)  THEN
            Fnd_Message.SET_NAME('AHL','AHL_VWP_NO_DEPT_SHIFT');
          Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.G_EXC_ERROR;
        END IF;
        --Assign the returned value
        l_task_rec.department_id := l_department_id;
     END IF;

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                          ': Dept ID= ' || l_Task_rec.department_id );
     END IF;

     -- For SERIAL NUMBER
     -- Convert serial number to instance/ serial id
     IF (l_Task_rec.serial_number IS NOT NULL AND
        l_Task_rec.serial_number <> Fnd_Api.G_MISS_CHAR) THEN
        IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           ': AHL_VWP_RULES_PVT.Check_Serial_Name_Or_Id ' );
        END IF;
        AHL_VWP_RULES_PVT.Check_Serial_Name_Or_Id
             (p_item_id        => l_Task_rec.inventory_item_id,
              p_org_id         => l_Task_rec.item_organization_id,
              p_serial_id      => l_Task_rec.instance_id,
              p_serial_number  => l_Task_rec.serial_number,
              x_serial_id      => l_serial_id,
              x_return_status  => l_return_status,
              x_error_msg_code => l_msg_data);

        IF NVL(l_return_status,'x') <> Fnd_Api.g_ret_sts_success THEN
           Fnd_Message.SET_NAME('AHL','AHL_VWP_SERIAL_NOT_EXISTS');
           Fnd_Msg_Pub.ADD;
           RAISE Fnd_Api.G_EXC_ERROR;
        ELSE
           --Assign the returned value
           l_Task_rec.instance_id := l_serial_id;

           IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              ': Before UC Check Serial ID= ' || l_Task_rec.instance_id ||
                              ': Before UC Item ID= ' || l_Task_rec.inventory_item_id ||
                              ': Before UC Item Org ID= ' || l_Task_rec.item_organization_id );
           END IF;
           /* sowsubra - start
           --BEGIN: jeli added for bug 3777720
           IF (AHL_VWP_RULES_PVT.instance_in_config_tree(l_task_rec.visit_id, l_task_rec.instance_id)
            = FND_API.G_RET_STS_ERROR) THEN
           --END: jeli added for bug 3777720
               Fnd_Message.SET_NAME('AHL','AHL_VWP_TASK_SERIAL');
               Fnd_Msg_Pub.ADD;
               RAISE Fnd_Api.G_EXC_ERROR;
           END IF;
           sowsubra - end */
        END IF;
     END IF;

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        ': Serial ID= ' || l_Task_rec.instance_id ||
                        ': Service Number= ' || l_Task_rec.service_request_number );
         -- Additional debug statement added by jaramana on Feb 14, 2008
         fnd_log.string(l_log_statement, L_DEBUG_KEY,
                        'l_task_rec.instance_number = ' || l_Task_rec.instance_number ||
                        ', l_task_rec.quantity = ' || l_Task_rec.quantity);
     END IF;

     -- Begin changes by rnahata for Issue 105
     IF (l_Task_rec.instance_id IS NULL) THEN
        OPEN c_get_instance_id (l_Task_rec.instance_number);
        FETCH c_get_instance_id INTO l_Task_rec.instance_id;
        CLOSE c_get_instance_id;
     END IF;

     OPEN c_get_instance_qty(l_Task_rec.instance_id);
     FETCH c_get_instance_qty INTO l_instance_qty;
     CLOSE c_get_instance_qty;

     IF (l_Task_rec.QUANTITY is null) THEN
       Fnd_Message.SET_NAME('AHL','AHL_TASK_QTY_NULL');
       Fnd_Msg_Pub.ADD;
       RAISE Fnd_Api.G_EXC_ERROR;
     END IF;

     IF (l_Task_rec.QUANTITY <= 0) THEN
       Fnd_Message.SET_NAME('AHL','AHL_POSITIVE_TSK_QTY');
       Fnd_Msg_Pub.ADD;
       RAISE Fnd_Api.G_EXC_ERROR;
     END IF;

     IF (l_Task_rec.QUANTITY > l_instance_qty ) THEN
       Fnd_Message.SET_NAME('AHL','AHL_INCORRECT_TSK_QTY');
       Fnd_Msg_Pub.ADD;
       RAISE Fnd_Api.G_EXC_ERROR;
     END IF;
     -- End changes by rnahata for Issue 105

     -- For COST PARENT TASK
     -- Convert cost parent number to id
     IF (l_Task_rec.cost_parent_number IS NOT NULL AND
        l_Task_rec.cost_parent_number <> Fnd_Api.G_MISS_NUM ) THEN
        IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Calling AHL_VWP_RULES_PVT.Check_Visit_Task_Number_OR_ID ' );
        END IF;
        AHL_VWP_RULES_PVT.Check_Visit_Task_Number_OR_ID
             (p_visit_task_id     => l_Task_rec.cost_parent_id,
              p_visit_task_number => l_Task_rec.cost_parent_number,
              p_visit_id          => l_Task_rec.visit_id,
              x_visit_task_id     => l_cost_parent_id,
              x_return_status     => l_return_status,
              x_error_msg_code    => l_msg_data);

        IF NVL(l_return_status,'x') <> Fnd_Api.g_ret_sts_success
        THEN
            Fnd_Message.SET_NAME('AHL','AHL_VWP_PARENT_NOT_EXISTS');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.g_exc_error;
        END IF;

        --Assign the returned value
        l_Task_rec.cost_parent_id := l_cost_parent_id;
     END IF;

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        ': Cost parent ID = ' || l_Task_rec.cost_parent_id);
     END IF;

     -- To Check for cost parent task id not forming loop
     IF (l_Task_rec.cost_parent_id IS NOT NULL AND
        l_Task_rec.cost_parent_id <> Fnd_Api.G_MISS_NUM ) THEN

        IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Calling AHL_VWP_RULES_PVT.Check_Cost_Parent_Loop ' );
        END IF;
        AHL_VWP_RULES_PVT.Check_Cost_Parent_Loop
            (p_visit_id        => l_Task_rec.visit_id,
             p_visit_task_id   => l_Task_rec.visit_task_id ,
             p_cost_parent_id  => l_Task_rec.cost_parent_id
            );
     END IF;

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        ': Originating Number = ' || l_Task_rec.orginating_task_number);
     END IF;

     -- For ORIGINATING TASK
     -- Convert originating task number to id
     IF (l_Task_rec.orginating_task_number IS NOT NULL AND
        l_Task_rec.orginating_task_number <> Fnd_Api.G_MISS_NUM ) THEN
        IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Calling AHL_VWP_RULES_PVT.Check_Visit_Task_Number_OR_ID ' );
        END IF;
        AHL_VWP_RULES_PVT.Check_Visit_Task_Number_OR_ID
             (p_visit_task_id     => l_Task_rec.originating_task_id,
              p_visit_task_number => l_Task_rec.orginating_task_number,
              p_visit_id          => l_Task_rec.visit_id,
              x_visit_task_id     => l_originating_task_id,
              x_return_status     => l_return_status,
              x_error_msg_code    => l_msg_data);

        IF NVL(l_return_status,'x') <> Fnd_Api.g_ret_sts_success
        THEN
            Fnd_Message.SET_NAME('AHL','AHL_VWP_ORIGINATING_NOT_EXISTS');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.g_exc_error;
        END IF;
        --Assign the returned value
        l_Task_rec.originating_task_id := l_originating_task_id;
     END IF;

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        ': Originating Task ID= ' || l_Task_rec.originating_task_id);
     END IF;

     -- To Check for originating task id not forming loop
     IF (l_Task_rec.originating_task_id IS NOT NULL AND
         l_Task_rec.originating_task_id <> Fnd_Api.G_MISS_NUM ) THEN

        AHL_VWP_RULES_PVT.Check_Origin_Task_Loop
            (p_visit_id            => l_Task_rec.visit_id ,
             p_visit_task_id       => l_Task_rec.visit_task_id ,
             p_originating_task_id => l_Task_rec.originating_task_id
            );

     END IF;
    ----------- End defining and validate all LOVs on Create Visit's Task UI Screen---

    ----------------------------------------------  Validate ----------------------------------------------
    -- IF c_visit_rec.status_code = 'PLANNING' THEN
    --Added the below condition for the call from Production for SR creation
    IF p_module_type <> 'SR' THEN
       IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          ': :ValidateCalling Validate_Visit_Task ');
       END IF;
       Validate_Visit_Task (
          p_api_version      => l_api_version,
          p_init_msg_list    => p_init_msg_list,
          p_commit           => Fnd_Api.g_false,
          p_validation_level => p_validation_level,
          p_task_rec         => l_task_rec,
          x_return_status    => l_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data
       );

       IF l_return_status = Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
       ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
       END IF;
    END IF;
/*   ELSE   Commented to fix bug # 4029318 Senthil
     -- TASK NAME ==== NAME
     IF (l_task_rec.visit_task_name IS NULL OR l_task_rec.visit_task_name = Fnd_Api.G_MISS_CHAR) THEN
        Fnd_Message.set_name ('AHL', 'AHL_VWP_NAME_MISSING');
        Fnd_Msg_Pub.ADD;
        RAISE Fnd_Api.g_exc_error;
     END IF;
     END IF;
*/
     l_Visit_Task_ID := AHL_VWP_RULES_PVT.Get_Visit_Task_Id();
     l_task_rec.visit_task_ID := l_Visit_Task_ID;

     -- Check for the Visit Number.
     l_task_number := AHL_VWP_RULES_PVT.Get_Visit_Task_Number(l_task_rec.visit_id);
     l_task_rec.visit_task_number := l_task_number;

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        ': Task ID= ' || l_Task_rec.visit_task_id ||
                        ': Task number= ' || l_Task_rec.visit_task_number);
     END IF;

     ----------------------- check miss_num/miss_char/miss_date-----------------------
     -- For all optional fields check if its g_miss_num/g_miss_char/g_miss_date
     -- then Null else the value call Default_Missing_Attribs procedure
     Default_Missing_Attribs
     (
     p_x_task_rec             => l_Task_rec
     );

   -------------------------- Insert --------------------------
   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'Before Calling Ahl_Visit_Tasks_Pkg.Insert_Row');
   END IF;

   -- Invoke the table handler to create a record
   Ahl_Visit_Tasks_Pkg.Insert_Row (
      X_ROWID                 => l_rowid,
      X_VISIT_TASK_ID         => l_task_rec.visit_task_id,
      X_VISIT_TASK_NUMBER     => l_task_rec.visit_task_number,
      X_OBJECT_VERSION_NUMBER => 1,
      X_VISIT_ID              => l_task_rec.visit_id,
      X_PROJECT_TASK_ID       => NULL, --l_task_rec.project_task_id,
      X_COST_PARENT_ID        => l_task_rec.cost_parent_id,
      X_MR_ROUTE_ID           => NULL,
      X_MR_ID                 => NULL,
      X_DURATION              => l_task_rec.duration,
      X_UNIT_EFFECTIVITY_ID   => l_task_rec.unit_effectivity_id,
      X_START_FROM_HOUR       => l_task_rec.start_from_hour,
      X_INVENTORY_ITEM_ID     => l_task_rec.inventory_item_id,
      X_ITEM_ORGANIZATION_ID  => l_task_rec.item_organization_id,
      X_INSTANCE_ID           => l_task_rec.instance_id,
      X_PRIMARY_VISIT_TASK_ID => NULL, --l_task_rec.primary_visit_task_id,
      X_ORIGINATING_TASK_ID   => l_task_rec.originating_task_id,
      X_SERVICE_REQUEST_ID    => l_task_rec.service_request_id,
      X_TASK_TYPE_CODE        => l_task_rec.task_type_code,
      X_DEPARTMENT_ID         => l_task_rec.department_id,
      X_SUMMARY_TASK_FLAG     => 'N',
      X_PRICE_LIST_ID         => NULL,
      X_STATUS_CODE           => 'PLANNING',
      X_ESTIMATED_PRICE       => NULL,
      X_ACTUAL_PRICE          => NULL,
      X_ACTUAL_COST           => NULL,
      --  Post 11.5.10 Changes by Senthil.
      X_STAGE_ID              => l_task_rec.STAGE_ID,
      -- Added cxcheng POST11510--------------
      -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010
      -- Pass past dates for the below 4 coloumns, and if it is null, pass null for all the 4 columns
      X_START_DATE_TIME       => l_task_rec.PAST_TASK_START_DATE,
      X_END_DATE_TIME         => l_task_rec.PAST_TASK_END_DATE,
      X_PAST_TASK_START_DATE  => l_task_rec.PAST_TASK_START_DATE,
      X_PAST_TASK_END_DATE    => l_task_rec.PAST_TASK_END_DATE,
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
      X_VISIT_TASK_NAME       => l_task_rec.visit_task_name,
      X_DESCRIPTION           => l_task_rec.description,
      X_QUANTITY              => l_Task_rec.quantity, -- Added by rnahata for Issue 105
      X_CREATION_DATE         => SYSDATE,
      X_CREATED_BY            => Fnd_Global.USER_ID,
      X_LAST_UPDATE_DATE      => SYSDATE,
      X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
      X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID );

   ------------------------- finish -------------------------------

   -- Added cxcheng POST11510--------------
   --Now adjust the times derivation for task
   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'Before Calling AHL_VWP_TIMES_PVT.Adjust_Task_Times' );
   END IF;

   -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Call Adjust_Task_Times only if past date is null
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

   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'After Calling AHL_VWP_TIMES_PVT.Adjust_Task_Times, Return Status = '|| l_return_status );
   END IF;

   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   -- set OUT value
   p_x_task_rec.Visit_Task_ID := l_task_rec.Visit_Task_ID;
   --TCHIMIRA::BUG 9303368 :: 02-02-2010::Fetch the regenerated visit task number from DB using visit task ID
   --p_x_task_rec.Visit_Task_Number := l_task_rec.Visit_Task_Number;
   select VISIT_TASK_NUMBER INTO p_x_task_rec.Visit_Task_Number from AHL_VISIT_TASKS_B where VISIT_TASK_ID = p_x_task_rec.Visit_Task_ID;

   IF (c_visit_rec.Any_Task_Chg_Flag = 'N') THEN

      AHL_VWP_RULES_PVT.update_visit_task_flag(
        p_visit_id         =>c_visit_rec.visit_id,
        p_flag             =>'Y',
        x_return_status    =>x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      ': After Insert ' || 'Task ID= ' || p_x_Task_rec.visit_task_id ||
                      ', Task Number= ' || p_x_Task_rec.visit_task_number);
   END IF;

   -- Calling  projects api to create project task for the newly added service request
   IF (l_task_rec.Visit_Task_ID IS NOT NULL AND p_module_type = 'SR' )THEN
      IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'Before Calling AHL_VWP_PROJ_PROD_PVT.Add_Task_to_Project ' ||
                         'Visit Task Id = ' ||  l_task_rec.Visit_Task_ID);
      END IF;

      AHL_VWP_PROJ_PROD_PVT.Add_Task_to_Project(
          p_api_version      => l_api_version,
          p_init_msg_list    => p_init_msg_list,
          p_commit           => Fnd_Api.g_false,
          p_validation_level => p_validation_level,
          p_module_type      => p_module_type,
          p_visit_task_id    => l_task_rec.Visit_Task_ID,
          x_return_status    => l_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'After Calling AHL_VWP_PROJ_PROD_PVT.Add_Task_to_Project, Return Status = ' ||l_return_status );
      END IF;
   END IF;

  ---------------------------End of API Body---------------------------------------
    --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Create_Unassociated_Task;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get(
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Create_Unassociated_Task;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Create_Unassociated_Task;
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

END Create_Unassociated_Task;

--------------------------------------------------------------------
-- PROCEDURE
--    Create_Summary_Task
-- PURPOSE
--    To create Summary Task for the maintainance visit
--------------------------------------------------------------------
PROCEDURE Create_Summary_Task (
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
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Create_Summary_Task';
   L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   -- Local variables defined for the procedure
   l_task_rec            AHL_VWP_RULES_PVT.Task_Rec_Type := p_x_task_rec;
   l_msg_data            VARCHAR2(2000);
   l_item_name           VARCHAR2(40);
   l_rowid               VARCHAR2(30);
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_item_id             NUMBER;
   l_serial_id           NUMBER;
   l_task_number         NUMBER;
   l_org_id              NUMBER;
   l_visit_task_id       NUMBER;
   l_service_id          NUMBER;
   l_cost_parent_id      NUMBER;
   l_originating_task_id NUMBER;
   l_department_id       NUMBER;

  -- To find visit related information
   CURSOR c_visit(x_id IN NUMBER) IS
       SELECT * FROM AHL_VISITS_VL
       WHERE VISIT_ID = x_id;
   c_visit_rec c_visit%ROWTYPE;

   -- bug fix #4181411
   -- yazhou 17-Feb-2005
   CURSOR get_task_inst_dtls(c_visit_id IN NUMBER) IS
   SELECT inventory_item_id,item_organization_id
   FROM ahl_visit_tasks_b
   WHERE visit_id = c_visit_id
   AND nvl(status_code,'x') <> 'DELETED'
   AND ROWNUM = 1;

   get_task_inst_rec  get_task_inst_dtls%ROWTYPE;

BEGIN
   --------------------Start of API Body-----------------------------------
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure.');
   END IF;

   SAVEPOINT Create_Summary_Task;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_boolean(p_init_msg_list)
   THEN
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

  --------------------Value OR ID conversion---------------------------
   --Start API Body
   IF p_module_type = 'JSP'
   THEN
       l_Task_rec.instance_id          := NULL;
       l_Task_rec.cost_parent_id       := NULL;
       l_Task_rec.originating_task_id  := NULL;
       l_Task_rec.department_id        := NULL;
   END IF;

  -------------------Cursor values------------------------------------
   OPEN c_visit(l_task_rec.visit_id);
   FETCH c_visit INTO c_visit_rec;
   CLOSE c_visit;

   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      ': Visit Id = ' || l_task_rec.visit_id ||
                      ': Status Code ' || c_visit_rec.status_code);
   END IF;

   IF c_visit_rec.status_code IN ('CLOSED','CANCELLED') THEN
      Fnd_Message.SET_NAME('AHL','AHL_VWP_NOT_USE_VISIT');
      Fnd_Msg_Pub.ADD;
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSE
      ----------- Start defining and validate all LOVs on Create Visit's Task UI Screen---
      --
      -- For DEPARTMENT
      -- Convert department name to department id
      IF (l_task_rec.dept_name IS NOT NULL AND l_task_rec.dept_name <> Fnd_Api.G_MISS_CHAR ) THEN
         IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Calling AHL_VWP_RULES_PVT.Check_Dept_Desc_Or_Id ');
         END IF;
         AHL_VWP_RULES_PVT.Check_Dept_Desc_Or_Id
               (p_organization_id  => c_visit_rec.organization_id,
                p_dept_name        => l_task_rec.dept_name,
                p_department_id    => NULL,
                x_department_id    => l_department_id,
                x_return_status    => l_return_status,
                x_error_msg_code   => l_msg_data);

         IF NVL(l_return_status,'x') <> Fnd_Api.g_ret_sts_success
         THEN
             Fnd_Message.SET_NAME('AHL','AHL_VWP_DEPT_NOT_EXISTS');
             Fnd_Msg_Pub.ADD;
             RAISE Fnd_Api.G_EXC_ERROR;
         END IF;

         -- Changes for Post 11.5.10 by amagrawa
         Ahl_vwp_rules_pvt.CHECK_DEPARTMENT_SHIFT
           ( P_DEPT_ID    => l_department_id,
             X_RETURN_STATUS  => l_return_status);

         IF (NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS)  THEN
             Fnd_Message.SET_NAME('AHL','AHL_VWP_NO_DEPT_SHIFT');
           Fnd_Msg_Pub.ADD;
               RAISE Fnd_Api.G_EXC_ERROR;
         END IF;

         --Assign the returned value
         l_task_rec.department_id := l_department_id;
      END IF;

      IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         ': Dept ID= ' || l_Task_rec.department_id ||
                         ': Before Convert Item Item ID= ' || l_Task_rec.inventory_item_id ||
                         ', Org ID= ' || l_Task_rec.item_organization_id ||
                         ', Item Name= ' || l_Task_rec.item_name );
      END IF;

      --
      -- For ITEM
      -- Convert item name to item id

      IF (l_Task_rec.inventory_item_id IS NOT NULL AND
           l_Task_rec.inventory_item_id <> Fnd_Api.G_MISS_NUM) AND
           (l_Task_rec.item_organization_id IS NOT NULL AND
            l_Task_rec.item_organization_id <> Fnd_Api.G_MISS_NUM) THEN

          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             'Calling AHL_VWP_RULES_PVT.Check_Item_Name_Or_Id ' );
          END IF;
          AHL_VWP_RULES_PVT.Check_Item_Name_Or_Id
             (p_item_id        => l_Task_rec.inventory_item_id,
              p_org_id         => l_Task_rec.item_organization_id,
              p_item_name      => l_Task_rec.item_name,
              x_item_id        => l_item_id,
              x_org_id         => l_org_id,
              x_item_name      => l_item_name,
              x_return_status  => l_return_status,
              x_error_msg_code => l_msg_data);

          IF NVL(l_return_status,'x') <> Fnd_Api.g_ret_sts_success
          THEN
              Fnd_Message.SET_NAME('AHL','AHL_VWP_ITEM_NOT_EXISTS');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.G_EXC_ERROR;
          END IF;

          IF UPPER(l_Task_rec.item_name) <> UPPER(l_item_name) THEN
              Fnd_Message.SET_NAME('AHL','AHL_VWP_ITEM_USE_LOV');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.G_EXC_ERROR;
          END IF;

          --Assign the returned value
          l_Task_rec.inventory_item_id := l_item_id;
          l_Task_rec.item_organization_id := l_org_id;

          /* Commented as Item is not mandatory for Summary Task
             Post 11.5.10 Changes done by Senthil.
             ELSE
                Fnd_Message.SET_NAME('AHL','AHL_VWP_ITEM_USE_LOV');
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
          */

   ELSE
      -- bug fix #4181411
      -- yazhou 17-Feb-2005
      IF (c_visit_rec.inventory_item_id IS NOT NULL AND
           c_visit_rec.inventory_item_id <> Fnd_Api.G_MISS_NUM) AND
           (c_visit_rec.item_organization_id IS NOT NULL AND
            c_visit_rec.item_organization_id <> Fnd_Api.G_MISS_NUM) THEN

          l_Task_rec.inventory_item_id :=  c_visit_rec.inventory_item_id;
          l_Task_rec.item_organization_id := c_visit_rec.item_organization_id;
      ELSE

         OPEN get_task_inst_dtls(l_task_rec.visit_id);
         FETCH get_task_inst_dtls INTO get_task_inst_rec;
         IF get_task_inst_dtls%NOTFOUND THEN
            Fnd_Message.SET_NAME('AHL','AHL_VWP_SUM_TASK_ITEM');
            Fnd_Msg_Pub.ADD;
            CLOSE get_task_inst_dtls;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;

         l_Task_rec.inventory_item_id :=  get_task_inst_rec.inventory_item_id;
         l_Task_rec.item_organization_id := get_task_inst_rec.item_organization_id;

         CLOSE get_task_inst_dtls;

      END IF;

   END IF;

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Item ID= ' || l_Task_rec.inventory_item_id ||
                        ', Item Org ID= ' || l_Task_rec.item_organization_id ||
                        ', Item Name= ' || l_Task_rec.item_name ||
                        ', Serial Number= ' || l_Task_rec.serial_number);
     END IF;

     -- For SERIAL NUMBER
     -- Convert serial number to instance/ serial id
      IF (l_Task_rec.serial_number IS NOT NULL AND
              l_Task_rec.serial_number <> Fnd_Api.G_MISS_CHAR) THEN

              AHL_VWP_RULES_PVT.Check_Serial_Name_Or_Id
                   (p_item_id        => l_Task_rec.inventory_item_id,
                    p_org_id         => l_Task_rec.item_organization_id,
                    p_serial_id      => l_Task_rec.instance_id,
                    p_serial_number  => l_Task_rec.serial_number,
                    x_serial_id      => l_serial_id,
                    x_return_status  => l_return_status,
                    x_error_msg_code => l_msg_data);

          IF NVL(l_return_status,'x') <> Fnd_Api.g_ret_sts_success THEN
             Fnd_Message.SET_NAME('AHL','AHL_VWP_SERIAL_NOT_EXISTS');
             Fnd_Msg_Pub.ADD;
             RAISE Fnd_Api.G_EXC_ERROR;
          ELSE
             --Assign the returned value
             l_Task_rec.instance_id := l_serial_id;

             IF (l_log_statement >= l_log_current_level) THEN
                fnd_log.string(l_log_statement,
                                     L_DEBUG_KEY,
                                     ': Before UC Check Serial ID= ' || l_Task_rec.instance_id ||
                                     ', Item ID= ' || l_Task_rec.inventory_item_id ||
                                     ', Org ID= ' || l_Task_rec.item_organization_id);
              END IF;
              /* sowsubra - start
              --BEGIN: jeli added for bug 3777720
              IF (AHL_VWP_RULES_PVT.instance_in_config_tree(l_task_rec.visit_id, l_task_rec.instance_id) = FND_API.G_RET_STS_ERROR) THEN
              --END: jeli added for bug 3777720
                  Fnd_Message.SET_NAME('AHL','AHL_VWP_TASK_SERIAL');
                  Fnd_Msg_Pub.ADD;
                  RAISE Fnd_Api.G_EXC_ERROR;
              END IF;
              sowsubra - end */
           END IF;
        END IF;

        IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           ': Serial ID= ' || l_Task_rec.instance_id ||
                           ': Cost parent= ' || l_Task_rec.cost_parent_number);
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

          IF NVL(l_return_status,'x') <> Fnd_Api.g_ret_sts_success
          THEN
              Fnd_Message.SET_NAME('AHL','AHL_VWP_PARENT_NOT_EXISTS');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.g_exc_error;
          END IF;

           --Assign the returned value
           l_Task_rec.cost_parent_id := l_cost_parent_id;
     END IF;

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        ': Cost parent ID = ' || l_Task_rec.cost_parent_id);
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

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        ': Originating Number = ' || l_Task_rec.orginating_task_number);
     END IF;

     --
     -- For ORIGINATING TASK
     -- Convert originating task number to id
      IF (l_Task_rec.orginating_task_number IS NOT NULL AND
          l_Task_rec.orginating_task_number <> Fnd_Api.G_MISS_NUM ) THEN

          AHL_VWP_RULES_PVT.Check_Visit_Task_Number_OR_ID
               (p_visit_task_id      => l_Task_rec.originating_task_id,
                p_visit_task_number  => l_Task_rec.orginating_task_number,
                p_visit_id           => l_Task_rec.visit_id,
                x_visit_task_id      => l_originating_task_id,
                x_return_status      => l_return_status,
                x_error_msg_code     => l_msg_data);

          IF NVL(l_return_status,'x') <> Fnd_Api.g_ret_sts_success
          THEN
              Fnd_Message.SET_NAME('AHL','AHL_VWP_ORIGINATING_NOT_EXISTS');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.g_exc_error;
          END IF;

          --Assign the returned value
          l_Task_rec.originating_task_id := l_originating_task_id;
     END IF;

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        ': Originating Task ID= ' || l_Task_rec.originating_task_id);
     END IF;

   -- To Check for originating task id not forming loop
    IF (l_Task_rec.originating_task_id IS NOT NULL AND
        l_Task_rec.originating_task_id <> Fnd_Api.G_MISS_NUM ) THEN

        AHL_VWP_RULES_PVT.Check_Origin_Task_Loop
            (p_visit_id             => l_Task_rec.visit_id ,
             p_visit_task_id        => l_Task_rec.visit_task_id ,
             p_originating_task_id  => l_Task_rec.originating_task_id
             );

    END IF;
    ----------- End defining and validate all LOVs on Create Visit's Task UI Screen---

    ----------------------------------------------  Validate ----------------------------------------------

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Before Calling Validate_Visit_Task');
     END IF;

       Validate_Visit_Task (
          p_api_version        => l_api_version,
          p_init_msg_list      => p_init_msg_list,
          p_commit             => Fnd_Api.g_false,
          p_validation_level   => p_validation_level,
          p_task_rec           => l_task_rec,
          x_return_status      => l_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data
       );

       IF l_return_status = Fnd_Api.g_ret_sts_error THEN
          RAISE Fnd_Api.g_exc_error;
       ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
       END IF;

       -- Check for the ID.
       IF l_task_rec.Visit_Task_ID = Fnd_Api.g_miss_num OR l_task_rec.Visit_Task_ID IS NULL THEN
          -- Check for the ID.
          l_Visit_Task_ID := AHL_VWP_RULES_PVT.Get_Visit_Task_Id();
          l_task_rec.visit_task_ID := l_Visit_Task_ID;

          -- Check for the Visit Number.
          l_task_number := AHL_VWP_RULES_PVT.Get_Visit_Task_Number(l_task_rec.visit_id);
          l_task_rec.visit_task_number := l_task_number;

          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             ': Task ID= ' || l_Task_rec.visit_task_id ||
                             ': Task number= ' || l_Task_rec.visit_task_number);
          END IF;

       END IF;

   ----------------------- Check miss_num/miss_char/miss_date-----------------------
    -- For all optional fields check if its g_miss_num/g_miss_char/g_miss_date
    -- then Null else the value call Default_Missing_Attribs procedure
        Default_Missing_Attribs
        (p_x_task_rec => l_Task_rec);

   -------------------------- Insert ------------------------------------------------

    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                       'Before Calling Ahl_Visit_Tasks_Pkg.Insert_Row' );
    END IF;

   -- Invoke the table handler to create a record
   Ahl_Visit_Tasks_Pkg.Insert_Row (
      X_ROWID                 => l_rowid,
      X_VISIT_TASK_ID         => l_task_rec.visit_task_id,
      X_VISIT_TASK_NUMBER     => l_task_rec.visit_task_number,
      X_OBJECT_VERSION_NUMBER => 1,
      X_VISIT_ID              => l_task_rec.visit_id,
      X_PROJECT_TASK_ID       => NULL, --l_task_rec.project_task_id,
      X_COST_PARENT_ID        => l_task_rec.cost_parent_id,
      X_MR_ROUTE_ID           => NULL,
      X_MR_ID                 => NULL,
      X_DURATION              => NULL,
      X_UNIT_EFFECTIVITY_ID   => NULL,
      X_START_FROM_HOUR       => NULL,
      X_INVENTORY_ITEM_ID     => l_task_rec.inventory_item_id,
      X_ITEM_ORGANIZATION_ID  => l_task_rec.item_organization_id,
      X_INSTANCE_ID           => l_task_rec.instance_id,
      X_PRIMARY_VISIT_TASK_ID => NULL, --l_task_rec.primary_visit_task_id,
      X_ORIGINATING_TASK_ID   => l_task_rec.originating_task_id,
      X_SERVICE_REQUEST_ID    => l_task_rec.service_request_id,
      X_TASK_TYPE_CODE        => l_task_rec.task_type_code,
      X_DEPARTMENT_ID         => l_task_rec.department_id,
      X_SUMMARY_TASK_FLAG     => 'Y',
      X_PRICE_LIST_ID         => NULL,
      X_STATUS_CODE           => 'PLANNING',
      X_ESTIMATED_PRICE       => NULL,
      X_ACTUAL_PRICE          => NULL,
      X_ACTUAL_COST           => NULL,
      --  Post 11.5.10 Changes by Senthil.
      X_STAGE_ID              =>  l_task_rec.STAGE_ID,
      -- Added cxcheng POST11510--------------
   -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Pass past dates too
      X_START_DATE_TIME       => NULL,
      X_END_DATE_TIME         => NULL,
      X_PAST_TASK_START_DATE  => NULL,
      X_PAST_TASK_END_DATE    => NULL,
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
      X_VISIT_TASK_NAME       => l_task_rec.visit_task_name,
      X_DESCRIPTION           => l_task_rec.description,
      -- Added by rnahata for Issue 105 - Qty is zero for manully created summary tasks
      X_QUANTITY              => 0,
      X_CREATION_DATE         => SYSDATE,
      X_CREATED_BY            => Fnd_Global.USER_ID,
      X_LAST_UPDATE_DATE      => SYSDATE,
      X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
      X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID );

    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                       'After Calling Ahl_Visit_Tasks_Pkg.Insert_Row' );
    END IF;

   ------------------------- finish -------------------------------
   -- Added cxcheng POST11510--------------
   --Now adjust the times derivation for task
   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'Before Calling AHL_VWP_TIMES_PVT.Adjust_Task_Times' );
   END IF;

   AHL_VWP_TIMES_PVT.Adjust_Task_Times(p_api_version => 1.0,
                                    p_init_msg_list => Fnd_Api.G_FALSE,
                                    p_commit        => Fnd_Api.G_FALSE,
                                    p_validation_level      => Fnd_Api.G_VALID_LEVEL_FULL,
                                    x_return_status      => l_return_status,
                                    x_msg_count          => l_msg_count,
                                    x_msg_data           => l_msg_data,
                                    p_task_id            => l_task_rec.visit_task_id);

   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'After Calling AHL_VWP_TIMES_PVT.Adjust_Task_Times, Return Status = '|| l_return_status );
   END IF;

   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

     -- set OUT value
     p_x_task_rec.Visit_Task_ID := l_task_rec.Visit_Task_ID;
     --TCHIMIRA::BUG 9246386 :: 02-02-2010::Fetch the regenerated visit task number from DB using visit task ID
     --p_x_task_rec.Visit_Task_Number := l_task_rec.Visit_Task_Number;
     select VISIT_TASK_NUMBER INTO p_x_task_rec.Visit_Task_Number from AHL_VISIT_TASKS_B where VISIT_TASK_ID = p_x_task_rec.Visit_Task_ID;

       IF c_visit_rec.Any_Task_Chg_Flag='N' THEN
         AHL_VWP_RULES_PVT.update_visit_task_flag(
         p_visit_id         =>c_visit_rec.visit_id,
         p_flag             =>'Y',
         x_return_status    =>x_return_status);
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF;

    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                       ': After Insert ' || 'Task ID= ' || p_x_Task_rec.visit_task_id ||
                       ': After Insert ' || 'Task Number= ' || p_x_Task_rec.visit_task_number);
    END IF;

END IF; -- Check for visit status code in case if closed or any other

  ---------------------------End of API Body---------------------------------------
    --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Create_Summary_Task;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get(
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Create_Summary_Task;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Summary_Task;
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
END Create_Summary_Task;

--------------------------------------------------------------------
-- PROCEDURE
--    Update_Task
--
-- PURPOSE
--  To update all types of tasks i.e Unassociated/Summary/Unplanned/Planned Tasks.
--------------------------------------------------------------------
PROCEDURE Update_Task (
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
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Update_Task';
   L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   -- local variables defined for the procedure
   l_task_rec             AHL_VWP_RULES_PVT.Task_Rec_Type := p_x_task_rec;
   l_msg_data             VARCHAR2(2000);
   l_return_status        VARCHAR2(1);
   l_msg_count            NUMBER;
   l_visit_end_date       DATE;

   -- To find task related information
   CURSOR c_Task (x_id IN NUMBER) IS
      SELECT * FROM  Ahl_Visit_Tasks_VL
      WHERE  VISIT_TASK_ID = x_id;
   c_Task_rec    c_Task%ROWTYPE;

    -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010
    -- get the start date and planned end date of the visit
    CURSOR c_Visit (x_id IN NUMBER) IS
    SELECT start_date_time, close_date_time FROM  ahl_visits_b
    WHERE  VISIT_ID = x_id;
    c_visit_rec    c_Visit%ROWTYPE;


 BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure.');
   END IF;

   --------------------- initialize -----------------------
   SAVEPOINT Update_Task;

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
 --------------------Start of API Body-----------------------------------

 -------------------Cursor values------------------------------------

   OPEN c_Task(l_Task_rec.visit_task_id);
   FETCH c_Task INTO c_Task_rec;
   CLOSE c_Task;

   -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: STARTS
   OPEN c_Visit(l_Task_rec.visit_id);
   FETCH c_Visit INTO c_visit_rec;
   CLOSE c_Visit;

   ---------------------------------------------- Start----------------------------------------------------------

   IF c_Task_rec.status_code = 'RELEASED' THEN
     l_task_rec.PAST_TASK_START_DATE := c_Task_rec.PAST_TASK_START_DATE;
     l_task_rec.PAST_TASK_END_DATE   := c_Task_rec.PAST_TASK_END_DATE;
   END IF;


   IF (l_task_rec.PAST_TASK_START_DATE IS NOT NULL
      AND l_task_rec.PAST_TASK_START_DATE <> Fnd_Api.G_MISS_DATE) THEN
       IF (l_task_rec.PAST_TASK_END_DATE IS NULL
          OR l_task_rec.PAST_TASK_START_DATE = Fnd_Api.G_MISS_DATE) THEN
          -- if start date is entered but not end date, throw error
        Fnd_Message.SET_NAME('AHL','AHL_VWP_PAST_TASK_DATE_MAND');
        Fnd_Msg_Pub.ADD;
        RAISE FND_API.G_EXC_ERROR;
       END IF;
       IF (l_Task_rec.PAST_TASK_START_DATE >= SYSDATE) THEN
         -- Throw error if start date is not in past
         Fnd_Message.SET_NAME('AHL','AHL_VWP_TASK_PAST_ST_DATE_INV');
         Fnd_Msg_Pub.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       IF (l_task_rec.PAST_TASK_START_DATE < NVL(c_visit_rec.START_DATE_TIME, l_task_rec.PAST_TASK_START_DATE)) THEN
           -- Throw error if past task start date is before the visit start date
           Fnd_Message.SET_NAME('AHL','AHL_VWP_TASK_START_DATE_INVLD');
           Fnd_Msg_Pub.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       IF (l_task_rec.PAST_TASK_START_DATE > l_task_rec.PAST_TASK_END_DATE) THEN
           -- Throw error if past task start date is after the past task end date
           Fnd_Message.SET_NAME('AHL','AHL_VWP_PAST_TASK_DATE_INVLD');
           Fnd_Msg_Pub.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       IF (l_Task_rec.PAST_TASK_END_DATE > NVL(c_visit_rec.CLOSE_DATE_TIME, l_Task_rec.PAST_TASK_END_DATE)) THEN
          -- Throw error if visit ends before the task
          Fnd_Message.SET_NAME('AHL','AHL_VWP_TASK_END_DATE_INVLD');
          Fnd_Msg_Pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Validate past dates against visit stages, task hierarchy and cost parent hierarchy
       AHL_VWP_RULES_PVT.Validate_Past_Task_Dates ( p_task_rec => l_Task_rec,
                                                    x_return_status => l_return_status);
       IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
         IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Returned success from AHL_VWP_RULES_PVT.Validate_Past_Task_Dates');
         END IF;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSE
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
   ELSE -- PAST_TASK_START_DATE is null
     -- SKPATHAK :: Bug #9402279 :: 24-FEB-2010
     -- Changed the condition from l_task_rec.PAST_TASK_START_DATE <> Fnd_Api.G_MISS_DATE
     -- to l_task_rec.PAST_TASK_END_DATE <> Fnd_Api.G_MISS_DATE
     IF (l_Task_rec.PAST_TASK_END_DATE IS NOT NULL
         AND l_Task_rec.PAST_TASK_END_DATE <> Fnd_Api.G_MISS_DATE) THEN
       Fnd_Message.SET_NAME('AHL','AHL_VWP_PAST_TASK_DATE_MAND');
       Fnd_Msg_Pub.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     -- If the earlier value of past task date is not null, cannot nullify the past date now
     IF c_Task_rec.PAST_TASK_START_DATE IS NOT NULL THEN
       Fnd_Message.SET_NAME('AHL','AHL_VWP_TASK_DATE_NOT_NULL');
       Fnd_Msg_Pub.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     l_Task_rec.PAST_TASK_START_DATE := NULL;
     l_Task_rec.PAST_TASK_END_DATE := NULL;
   END IF;
   -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: END


   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'Status Code = ' || c_Task_rec.status_code);
   END IF;

   IF c_Task_rec.status_code = 'RELEASED' THEN
     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Before calling Update_Tasks_in_Production');
     END IF;

    Update_Tasks_in_Production
      (p_api_version      => l_api_version,
       p_init_msg_list    => p_init_msg_list,
       p_commit           => Fnd_Api.g_false,
       p_validation_level => p_validation_level,
       p_module_type      => p_module_type,
       p_x_task_rec       => l_task_rec,
       x_return_status    => l_return_status,
       x_msg_count        => l_msg_count,
       x_msg_data         => l_msg_data
       );
     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'After calling Update_Tasks_in_Production, Return Status = ' || l_return_status);
     END IF;

   ELSE
        IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Before calling Update_Tasks_in_Planning');
        END IF;
        Update_Tasks_in_Planning
        (p_api_version      => l_api_version,
         p_init_msg_list    => p_init_msg_list,
         p_commit           => Fnd_Api.g_false,
         p_validation_level => p_validation_level,
         p_module_type      => p_module_type,
         p_x_task_rec       => l_task_rec,
         x_return_status    => l_return_status,
         x_msg_count        => l_msg_count,
         x_msg_data         => l_msg_data
          );
        IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'After calling Update_Tasks_in_Planning,Return Status = '|| l_return_status);
        END IF;
   END IF;

   -- Added to raise errors after calling respective API's
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

------------------------End of API Body------------------------------------
   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.end',
                      'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Update_Task;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Task;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Task;
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
END Update_Task;

--------------------------------------------------------------------
-- PROCEDURE
--    Update_Tasks_in_Planning
--
-- PURPOSE
--    To update visit task when in planning status
--------------------------------------------------------------------

PROCEDURE Update_Tasks_in_Planning(
  p_api_version      IN            NUMBER  := 1.0,
  p_init_msg_list    IN            VARCHAR2:= FND_API.G_FALSE,
  p_commit           IN            VARCHAR2:= FND_API.G_FALSE,
  p_validation_level IN            NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_module_type      IN            VARCHAR2:= 'JSP',
  p_x_task_rec       IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2

) IS
   L_API_VERSION CONSTANT NUMBER := 1.0;
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Update_Tasks_in_Planning';
   L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   l_return_status        VARCHAR2(1);
   l_msg_data             VARCHAR2(2000);
   l_msg_count            NUMBER;
   l_count                NUMBER;
   l_workorder_rec        AHL_PRD_WORKORDER_PVT.prd_workorder_rec;
   l_workoper_tbl         AHL_PRD_WORKORDER_PVT.prd_workoper_tbl;

-- To find visit related information
CURSOR c_Visit (p_visit_id IN NUMBER) IS
 SELECT ROW_ID                ,
        VISIT_ID              ,
        VISIT_NUMBER          ,
        OBJECT_VERSION_NUMBER ,
        LAST_UPDATE_DATE      ,
        LAST_UPDATED_BY       ,
        CREATION_DATE         ,
        CREATED_BY            ,
        LAST_UPDATE_LOGIN     ,
        ORGANIZATION_ID       ,
        DEPARTMENT_ID         ,
        STATUS_CODE           ,
        START_DATE_TIME       ,
        VISIT_TYPE_CODE       ,
        SIMULATION_PLAN_ID    ,
        ITEM_INSTANCE_ID      ,
        ITEM_ORGANIZATION_ID  ,
        INVENTORY_ITEM_ID     ,
        ASSO_PRIMARY_VISIT_ID ,
        SIMULATION_DELETE_FLAG,
        TEMPLATE_FLAG         ,
        OUT_OF_SYNC_FLAG      ,
        PROJECT_FLAG          ,
        PROJECT_ID            ,
        VISIT_NAME            ,
        DESCRIPTION           ,
        SERVICE_REQUEST_ID    ,
        SPACE_CATEGORY_CODE   ,
        CLOSE_DATE_TIME       ,
        SCHEDULE_DESIGNATOR   ,
        PRICE_LIST_ID         ,
        ESTIMATED_PRICE       ,
        ACTUAL_PRICE          ,
        OUTSIDE_PARTY_FLAG    ,
        ANY_TASK_CHG_FLAG     ,
        ATTRIBUTE_CATEGORY    ,
        ATTRIBUTE1            ,
        ATTRIBUTE2            ,
        ATTRIBUTE3            ,
        ATTRIBUTE4            ,
        ATTRIBUTE5            ,
        ATTRIBUTE6            ,
        ATTRIBUTE7            ,
        ATTRIBUTE8            ,
        ATTRIBUTE9            ,
        ATTRIBUTE10           ,
        ATTRIBUTE11           ,
        ATTRIBUTE12           ,
        ATTRIBUTE13           ,
        ATTRIBUTE14           ,
        ATTRIBUTE15
   FROM Ahl_Visits_VL
   WHERE VISIT_ID = p_visit_id;

  l_Visit_rec c_Visit%ROWTYPE;
  l_Task_rec  AHL_VWP_RULES_PVT.Task_Rec_Type default p_x_task_rec;

    Cursor c_visit_task_det(p_visit_task_id in number)
      is
      Select ROW_ID        ,
    VISIT_TASK_ID          ,
    VISIT_TASK_NUMBER      ,
    OBJECT_VERSION_NUMBER  ,
    CREATION_DATE          ,
    CREATED_BY             ,
    LAST_UPDATE_DATE       ,
    LAST_UPDATED_BY        ,
    LAST_UPDATE_LOGIN      ,
    VISIT_ID               ,
    PROJECT_TASK_ID        ,
    COST_PARENT_ID         ,
    MR_ROUTE_ID            ,
    MR_ID                  ,
    DURATION               ,
    UNIT_EFFECTIVITY_ID    ,
    VISIT_TASK_NAME        ,
    DESCRIPTION            ,
    START_FROM_HOUR        ,
    INVENTORY_ITEM_ID      ,
    ITEM_ORGANIZATION_ID   ,
    INSTANCE_ID            ,
    PRIMARY_VISIT_TASK_ID  ,
    SUMMARY_TASK_FLAG      ,
    ORIGINATING_TASK_ID    ,
    SECURITY_GROUP_ID      ,
    SERVICE_REQUEST_ID     ,
    TASK_TYPE_CODE         ,
    DEPARTMENT_ID          ,
    PRICE_LIST_ID          ,
    STATUS_CODE            ,
    ACTUAL_COST            ,
    ESTIMATED_PRICE        ,
    ACTUAL_PRICE           ,
    ATTRIBUTE_CATEGORY     ,
    ATTRIBUTE1             ,
    ATTRIBUTE2             ,
    ATTRIBUTE3             ,
    ATTRIBUTE4             ,
    ATTRIBUTE5             ,
    ATTRIBUTE6             ,
    ATTRIBUTE7             ,
    ATTRIBUTE8             ,
    ATTRIBUTE9             ,
    ATTRIBUTE10            ,
    ATTRIBUTE11            ,
    ATTRIBUTE12            ,
    ATTRIBUTE13            ,
    ATTRIBUTE14            ,
    ATTRIBUTE15            ,
    QUANTITY               , --Added by rnahata for Issue 105
    STAGE_ID
    from ahl_visit_tasks_vl
    where visit_task_id = p_visit_task_id;

 l_old_Task_rec   c_visit_task_det%rowtype;

       -- To find if WIP job is created for the Visit
    CURSOR c_job(x_id IN NUMBER) IS
     SELECT COUNT(*) FROM AHL_WORKORDERS
     WHERE VISIT_ID = x_id
     AND MASTER_WORKORDER_FLAG = 'Y'
     AND STATUS_CODE = 17;

    CURSOR c_Task_WO(x_task_id IN NUMBER) IS
     SELECT * FROM AHL_WORKORDERS
     WHERE VISIT_TASK_ID = x_task_id
     AND STATUS_CODE = 17;
     l_task_workrec c_Task_WO%ROWTYPE;

  -- To find all tasks under this current visit related information
    CURSOR c_all_Task (x_id IN NUMBER) IS
     SELECT *
     FROM Ahl_Visit_Tasks_VL
     WHERE VISIT_TASK_ID = x_id;
    l_all_Task_rec c_all_Task%ROWTYPE;

    l_workrec AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_REC;

BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.begin',
                      'At the start of PL SQL procedure.' ||
                      'Visit ID ' || l_task_rec.visit_id ||
                      'Visit Task ID ' || l_Task_rec.visit_task_id);
   END IF;

   --------------------- initialize -----------------------
   SAVEPOINT Update_Tasks_in_Planning;

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

  OPEN c_visit(l_task_rec.visit_id);
  FETCH c_visit INTO l_visit_rec;
  CLOSE c_visit;

  OPEN c_visit_task_det(l_Task_rec.visit_task_id);
  FETCH c_visit_task_det INTO l_old_Task_rec;
  CLOSE c_visit_task_det;

  IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Task type code = ' || l_old_Task_rec.task_type_code);
  END IF;

  IF (l_old_Task_rec.task_type_code <>  'SUMMARY'
           AND l_Task_rec.stage_name IS NOT NULL) THEN

    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                       ' Call AHL_VWP_VISITS_STAGES_PVT.VALIDATE_STAGE_UPDATES ');
    END IF;
    AHL_VWP_VISITS_STAGES_PVT.VALIDATE_STAGE_UPDATES(
     P_API_VERSION      =>  1.0,
     P_VISIT_ID         =>  l_Task_rec.visit_id,
     P_VISIT_TASK_ID    =>  l_Task_rec.visit_task_id,
     P_STAGE_NAME       =>  L_task_rec.STAGE_NAME,
     X_STAGE_ID         =>  L_task_rec.STAGE_ID,
     X_RETURN_STATUS    =>  l_return_status,
     X_MSG_COUNT        =>  l_msg_count,
     X_MSG_DATA         =>  l_msg_data  );

         IF l_msg_count > 0 OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
              x_msg_count := l_msg_count;
             x_return_status := Fnd_Api.G_RET_STS_ERROR;
              RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
END IF;

            -- Code added to make sure that department name to id conversion takes place
            -- Irrespective of above API Being Called.
      IF (l_task_rec.dept_name IS NOT NULL AND l_task_rec.dept_name <> Fnd_Api.G_MISS_CHAR ) THEN
      AHL_VWP_RULES_PVT.Check_Dept_Desc_Or_Id
      (p_organization_id  => l_visit_rec.organization_id,
       p_dept_name        => l_task_rec.dept_name,
       p_department_id    => NULL,
       x_department_id    => l_task_rec.department_id,
       x_return_status    => l_return_status,
       x_error_msg_code   => l_msg_data);

          IF (NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS)  THEN
    Fnd_Message.SET_NAME('AHL','AHL_VWP_DEPT_NOT_EXISTS');
    Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
          END IF;

          -- Changes for Post 11.5.10 by cxcheng
          Ahl_vwp_rules_pvt.CHECK_DEPARTMENT_SHIFT
            ( P_DEPT_ID    => l_task_rec.department_id,
                X_RETURN_STATUS  => l_return_status);

          IF (NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS)  THEN
              Fnd_Message.SET_NAME('AHL','AHL_VWP_NO_DEPT_SHIFT');
            Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
          END IF;
        ELSE
          l_task_rec.department_id := NULL;
      END IF;

           IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                             ' In Update task... ' ||
                             ' l_task_rec.department_id '|| l_task_rec.department_id ||
                             ' l_old_Task_rec.department_id'|| l_old_Task_rec.department_id);
           END IF;

       -- If Task DEPARTMENT is changed after price/cost is estimated,

       IF (NVL(l_task_rec.department_id, -999 ) <> NVL(l_old_Task_rec.department_id, -999)) THEN

    -- If Task DEPARTMENT is changed after price/cost is estimated,
    -- the prices associated to Visit and all the Tasks in the visit will be cleared up
             OPEN c_job(l_visit_rec.visit_id);
             FETCH c_job INTO l_count;
             CLOSE c_job;

      IF l_count > 0 THEN
          -- To update visit's prices
          UPDATE AHL_VISITS_B
        SET ACTUAL_PRICE = NULL, ESTIMATED_PRICE = NULL,
        OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
          WHERE VISIT_ID = l_visit_rec.visit_id;

          IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            ' After Update Price for Visit');
          END IF;

          -- To update all tasks prices of tasks under this visit
          OPEN c_all_task(l_visit_rec.visit_id);
          LOOP
             FETCH c_all_task INTO l_all_task_rec;
             EXIT WHEN c_all_task%NOTFOUND;
         -- Tasks found for visit
         -- To set prices to NULL in case if the visit's department is changed
        UPDATE AHL_VISIT_TASKS_B
          SET ACTUAL_PRICE = NULL, ESTIMATED_PRICE = NULL,
              OBJECT_VERSION_NUMBER = l_all_task_rec.object_version_number + 1
        WHERE VISIT_TASK_ID = l_all_task_rec.visit_task_id;
          END LOOP;
          CLOSE c_all_task;

          IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            ' After Update Price for all Tasks');
          END IF;

      END IF;

        -- TASK DEPARTMENT UPDATED THEN
        -- Wip job for the current task to be updated with new department
        OPEN  c_Task_WO(l_Task_rec.visit_task_id);
        FETCH c_Task_WO INTO l_task_workrec;
        IF c_Task_WO%FOUND THEN
           l_workorder_rec.WORKORDER_ID              := l_task_workrec.workorder_id;
           l_workorder_rec.OBJECT_VERSION_NUMBER     := l_task_workrec.object_version_number;
           IF l_Task_rec.department_id is NULL THEN
               l_workorder_rec.DEPARTMENT_ID    := l_visit_rec.department_id;
           ELSE
               l_workorder_rec.DEPARTMENT_ID    := l_Task_rec.department_id;
           END IF;
           CLOSE c_Task_WO;

           IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'Before Calling AHL_PRD_WORKORDER_PVT.update_job');
           END IF;
           AHL_PRD_WORKORDER_PVT.update_job
            (p_api_version          =>1.0,
             p_init_msg_list        =>fnd_api.g_false,
             p_commit               =>fnd_api.g_false,
             p_validation_level     =>p_validation_level,
             p_default              =>fnd_api.g_false,
             p_module_type          =>'API',
             x_return_status        =>x_return_status,
             x_msg_count            =>x_msg_count,
             x_msg_data             =>x_msg_data,
             p_wip_load_flag        =>'Y',
             p_x_prd_workorder_rec  =>l_workorder_rec,
             P_X_PRD_WORKOPER_TBL   =>l_workoper_tbl
            );

           IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'After Calling AHL_PRD_WORKORDER_PVT.update_job, Return Status = ' || x_return_status);
           END IF;

           IF l_return_status <> Fnd_Api.g_ret_sts_success THEN
             RAISE Fnd_Api.G_EXC_ERROR;
           END IF;

           END IF;
           CLOSE c_Task_wO;

        END IF; -- Check for Dept change

       IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          ': After calling update task for costing changes');
       END IF;

    IF l_task_rec.task_type_code = 'SUMMARY' THEN
       IF (l_log_statement >= l_log_current_level)THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Before Calling Update_Summary_Task, TASK TYPE = ' || l_task_rec.task_type_code);
       END IF;

                Update_Summary_Task
                (
                 p_api_version      => l_api_version,
                 p_init_msg_list    => p_init_msg_list,
                 p_commit           => Fnd_Api.g_false,
                 p_validation_level => p_validation_level,
                 p_module_type      => p_module_type,
                 p_x_task_rec       => l_task_rec,
                 x_return_status    => l_return_status,
                 x_msg_count        => l_msg_count,
                 x_msg_data         => l_msg_data
               );
       IF (l_log_statement >= l_log_current_level)THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'After Calling Update_Summary_Task, Return Status = ' || l_return_status);
       END IF;
    ELSIF l_task_rec.task_type_code = 'PLANNED' THEN
         -- Call AHL_VWP_PLAN_TASKS_PVT

         IF (l_log_statement >= l_log_current_level)THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Calling Update_Planned_Task, TASK TYPE = ' || l_task_rec.task_type_code);
         END IF;

                AHL_VWP_PLAN_TASKS_PVT.Update_Planned_Task
                (
                 p_api_version      => l_api_version,
                 p_init_msg_list    => p_init_msg_list,
                 p_commit           => Fnd_Api.g_false,
                 p_validation_level => p_validation_level,
                 p_module_type      => p_module_type,
                 p_x_task_rec       => l_task_rec,
                 x_return_status    => l_return_status,
                 x_msg_count        => l_msg_count,
                 x_msg_data         => l_msg_data
               );
   ELSIF l_task_rec.task_type_code = 'UNPLANNED' THEN
         -- Call AHL_VWP_UNPLAN_TASKS_PVT
         IF (l_log_statement >= l_log_current_level)THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Calling Update_Unplanned_Task, TASK TYPE = ' || l_task_rec.task_type_code);
         END IF;

         AHL_VWP_UNPLAN_TASKS_PVT.Update_Unplanned_Task
         (p_api_version      => l_api_version,
          p_init_msg_list    => p_init_msg_list,
          p_commit           => Fnd_Api.g_false,
          p_validation_level => p_validation_level,
          p_module_type      => p_module_type,
          p_x_task_rec       => l_task_rec,
          x_return_status    => l_return_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data
         );
   ELSIF l_task_rec.task_type_code = 'UNASSOCIATED' THEN
         -- Call AHL_VWP_UNPLAN_TASKS_PVT
         IF (l_log_statement >= l_log_current_level)THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Before Calling Update_Unassociated_Task');
         END IF;

         Update_Unassociated_Task
         (p_api_version      => l_api_version,
          p_init_msg_list    => p_init_msg_list,
          p_commit           => Fnd_Api.g_false,
          p_validation_level => p_validation_level,
          p_module_type      => p_module_type,
          p_x_task_rec       => l_task_rec,
          x_return_status    => l_return_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data
         );

         IF (l_log_statement >= l_log_current_level)THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                             'After Calling Update_Unassociated_Task, Return Status = ' ||l_return_status );
         END IF;
   END IF;

   -- Added to raise errors after calling respective API's
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

        --------------------------------------------------------------------------
        ----                     START   11.5.10 CHANGES FOR COSTING          ----
        --------------------------------------------------------------------------

       -- Conversion is done to make sure that the number to id conversion takes place
       -- Irrespective of above Update API Calls.
       -- Convert cost parent number to id
       IF (p_x_task_rec.cost_parent_number IS NOT NULL AND
      p_x_task_rec.cost_parent_number <> Fnd_Api.G_MISS_NUM ) THEN

      IF (l_log_statement >= l_log_current_level)THEN
                fnd_log.string(l_log_statement,
                               L_DEBUG_KEY,
                               'Calling AHL_VWP_RULES_PVT.Check_Visit_Task_Number_OR_ID ');
      END IF;

      AHL_VWP_RULES_PVT.Check_Visit_Task_Number_OR_ID
      (p_visit_task_id     => p_x_task_rec.cost_parent_id,
       p_visit_task_number => p_x_task_rec.cost_parent_number,
       p_visit_id          => p_x_task_rec.visit_id,
       x_visit_task_id     => p_x_task_rec.cost_parent_id,
       x_return_status     => l_return_status,
       x_error_msg_code    => l_msg_data);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;
         ELSE
           p_x_task_rec.cost_parent_id := null;
       END IF;

        -- Updating Cost Parent should update the any_task_chg_flag
        IF (NVL(p_x_task_rec.cost_parent_id, -999 ) <> NVL(l_old_Task_rec.cost_parent_id, -999)) THEN
         IF l_visit_rec.any_task_chg_flag = 'N' THEN
            IF (l_log_statement >= l_log_current_level)THEN
                fnd_log.string(l_log_statement,
                               L_DEBUG_KEY,
                               'Before Calling AHL_VWP_RULES_PVT.Update_Visit_Task_Flag ' ||
                               'Any_task_chg_flag = ' ||l_visit_rec.any_task_chg_flag);
            END IF;

            AHL_VWP_RULES_PVT.Update_Visit_Task_Flag
               (p_visit_id      => l_old_Task_rec.visit_id,
                p_flag          => 'Y',
                x_return_status => x_return_status);

            IF (l_log_statement >= l_log_current_level)THEN
                fnd_log.string(l_log_statement,
                               L_DEBUG_KEY,
                               'After Calling AHL_VWP_RULES_PVT.Update_Visit_Task_Flag, Return Status = ' ||x_return_status);
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;
        END IF; -- for cost_parent_id check

        --------------------------------------------------------------------------
        ----                  END   11.5.10 CHANGES FOR COSTING               ----
        --------------------------------------------------------------------------

------------------------End of API Body------------------------------------
   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Update_Tasks_in_Planning;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Tasks_in_Planning;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Tasks_in_Planning;
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

END Update_Tasks_in_Planning;

--------------------------------------------------------------------
-- PROCEDURE
--    Update_Tasks_in_Production
--
-- PURPOSE
--    To update visit task which are relaesed
--------------------------------------------------------------------

PROCEDURE Update_Tasks_in_Production(
  p_api_version      IN            NUMBER  := 1.0,
  p_init_msg_list    IN            VARCHAR2:=  FND_API.G_FALSE,
  p_commit           IN            VARCHAR2:=  FND_API.G_FALSE,
  p_validation_level IN            NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
  p_module_type      IN            VARCHAR2:=  'JSP',
  p_x_task_rec       IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2

) IS

   L_API_VERSION CONSTANT NUMBER := 1.0;
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Update_Tasks_in_Production';
   L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   l_Task_rec             AHL_VWP_RULES_PVT.Task_Rec_Type default p_x_task_rec;

   Cursor c_visit_task_det(p_visit_task_id in number)
   is
   Select ROW_ID                 ,
  VISIT_TASK_ID          ,
  VISIT_TASK_NUMBER      ,
  OBJECT_VERSION_NUMBER  ,
  CREATION_DATE          ,
  CREATED_BY             ,
  LAST_UPDATE_DATE       ,
  LAST_UPDATED_BY        ,
  LAST_UPDATE_LOGIN      ,
  VISIT_ID               ,
  PROJECT_TASK_ID        ,
  COST_PARENT_ID         ,
  MR_ROUTE_ID            ,
  MR_ID                  ,
  DURATION               ,
  UNIT_EFFECTIVITY_ID    ,
  VISIT_TASK_NAME        ,
  DESCRIPTION            ,
  START_FROM_HOUR        ,
  -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Fetch past dates too
  PAST_TASK_START_DATE   ,
  PAST_TASK_END_DATE     ,
  INVENTORY_ITEM_ID      ,
  ITEM_ORGANIZATION_ID   ,
  INSTANCE_ID            ,
  PRIMARY_VISIT_TASK_ID  ,
  SUMMARY_TASK_FLAG      ,
  ORIGINATING_TASK_ID    ,
  SECURITY_GROUP_ID      ,
  SERVICE_REQUEST_ID     ,
  TASK_TYPE_CODE         ,
  DEPARTMENT_ID          ,
  PRICE_LIST_ID          ,
  STATUS_CODE            ,
  ACTUAL_COST            ,
  ESTIMATED_PRICE        ,
  ACTUAL_PRICE           ,
  ATTRIBUTE_CATEGORY     ,
  ATTRIBUTE1             ,
  ATTRIBUTE2             ,
  ATTRIBUTE3             ,
  ATTRIBUTE4             ,
  ATTRIBUTE5             ,
  ATTRIBUTE6             ,
  ATTRIBUTE7             ,
  ATTRIBUTE8             ,
  ATTRIBUTE9             ,
  ATTRIBUTE10            ,
  ATTRIBUTE11            ,
  ATTRIBUTE12            ,
  ATTRIBUTE13            ,
  ATTRIBUTE14            ,
  ATTRIBUTE15            ,
  QUANTITY               , --Added by rnahata for Issue 105
  STAGE_ID
 from ahl_visit_tasks_vl
 where visit_task_id = p_visit_task_id;

 l_old_Task_rec   c_visit_task_det%rowtype;

 Cursor c_any_task_flg(p_visit_id in number)
 is
 Select any_task_chg_flag
 from   ahl_visits_b
 where visit_id = p_visit_id;

 l_any_task_chg_flag ahl_visits_b.any_task_chg_flag%type;

   l_return_status        VARCHAR2(1);
   l_cost_parent_id       NUMBER;
   l_msg_data             VARCHAR2(2000);
   l_msg_count          NUMBER;

BEGIN

   IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.begin',
                      'At the start of PL SQL procedure.' ||
                      'Visit Task Id = ' || l_Task_rec.visit_task_id );
   END IF;

   --------------------- initialize -----------------------
   SAVEPOINT Update_Tasks_in_Production;

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

  OPEN c_visit_task_det(l_Task_rec.visit_task_id);
  FETCH c_visit_task_det INTO l_old_Task_rec;
  CLOSE c_visit_task_det;

  IF (l_Task_rec.cost_parent_number IS NOT NULL AND
            l_Task_rec.cost_parent_number <> Fnd_Api.G_MISS_NUM ) THEN

            AHL_VWP_RULES_PVT.Check_Visit_Task_Number_OR_ID
                 (p_visit_task_id      => l_Task_rec.cost_parent_id,
                  p_visit_task_number  => l_Task_rec.cost_parent_number,
                  p_visit_id           => l_Task_rec.visit_id,
                  x_visit_task_id      => l_cost_parent_id,
                  x_return_status      => l_return_status,
                  x_error_msg_code     => l_msg_data);

            IF NVL(l_return_status,'x') <> Fnd_Api.g_ret_sts_success
            THEN
            Fnd_Message.SET_NAME('AHL','AHL_VWP_PARENT_NOT_EXISTS');
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.g_exc_error;
            END IF;
             --Assign the returned value
             l_Task_rec.cost_parent_id := l_cost_parent_id;
   ELSE
             l_Task_rec.cost_parent_id := NULL;
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

    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                      'Before Calling Ahl_Visit_Tasks_Pkg.UPDATE_ROW');
    END IF;

    Ahl_Visit_Tasks_Pkg.UPDATE_ROW (
      X_VISIT_TASK_ID         => l_task_rec.visit_task_id,
      X_VISIT_TASK_NUMBER     => l_old_Task_rec.visit_task_number,
      X_OBJECT_VERSION_NUMBER => l_task_rec.OBJECT_VERSION_NUMBER + 1,
      X_VISIT_ID              => l_old_Task_rec.visit_id,
      X_PROJECT_TASK_ID       => l_old_Task_rec.project_task_id,
      X_COST_PARENT_ID        => l_task_rec.cost_parent_id,
      X_MR_ROUTE_ID           => l_old_Task_rec.mr_route_id,
      X_MR_ID                 => l_old_Task_rec.mr_id,
      X_DURATION              => l_task_rec.duration,
      X_UNIT_EFFECTIVITY_ID   => l_old_Task_rec.unit_effectivity_id,
      X_START_FROM_HOUR       => l_task_rec.start_from_hour,
      X_INVENTORY_ITEM_ID     => l_old_Task_rec.inventory_item_id,
      X_ITEM_ORGANIZATION_ID  => l_old_Task_rec.item_organization_id,
      X_INSTANCE_ID           => l_Task_rec.instance_id,
      X_PRIMARY_VISIT_TASK_ID => l_old_Task_rec.primary_visit_task_id,
      X_ORIGINATING_TASK_ID   => l_task_rec.originating_task_id,
      X_SERVICE_REQUEST_ID    => l_task_rec.service_request_id,
      X_TASK_TYPE_CODE        => l_task_rec.task_type_code,
      X_DEPARTMENT_ID         => l_task_rec.department_id,
      X_SUMMARY_TASK_FLAG     => 'N',
      X_PRICE_LIST_ID         => l_old_Task_rec.price_list_id,
      X_STATUS_CODE           => l_old_Task_rec.status_code,
      X_ESTIMATED_PRICE       => l_old_Task_rec.estimated_price,
      X_ACTUAL_PRICE          => l_old_Task_rec.actual_price,
      X_ACTUAL_COST           => l_old_Task_rec.actual_cost,
--  Post 11.5.10 Changes by Senthil.
      X_STAGE_ID              => l_Task_rec.stage_id,
   -- Added cxcheng POST11510--------------
   -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010
   -- Pass past dates too, and if it is null, pass null for all the 4 columns below
      X_START_DATE_TIME       => l_old_Task_rec.PAST_TASK_START_DATE,
      X_END_DATE_TIME         => l_old_Task_rec.PAST_TASK_END_DATE,
      X_PAST_TASK_START_DATE  => l_old_Task_rec.PAST_TASK_START_DATE,
      X_PAST_TASK_END_DATE    => l_old_Task_rec.PAST_TASK_END_DATE,
   -- manisaga commented the attribute from from l_old_task_rec and and added from
   -- l_task_rec for DFF implementation on 19-Feb-2010  --- Start
   /*
      X_ATTRIBUTE_CATEGORY    => l_old_Task_rec.ATTRIBUTE_CATEGORY,
      X_ATTRIBUTE1            => l_old_Task_rec.ATTRIBUTE1,
      X_ATTRIBUTE2            => l_old_Task_rec.ATTRIBUTE2,
      X_ATTRIBUTE3            => l_old_Task_rec.ATTRIBUTE3,
      X_ATTRIBUTE4            => l_old_Task_rec.ATTRIBUTE4,
      X_ATTRIBUTE5            => l_old_Task_rec.ATTRIBUTE5,
      X_ATTRIBUTE6            => l_old_Task_rec.ATTRIBUTE6,
      X_ATTRIBUTE7            => l_old_Task_rec.ATTRIBUTE7,
      X_ATTRIBUTE8            => l_old_Task_rec.ATTRIBUTE8,
      X_ATTRIBUTE9            => l_old_Task_rec.ATTRIBUTE9,
      X_ATTRIBUTE10           => l_old_Task_rec.ATTRIBUTE10,
      X_ATTRIBUTE11           => l_old_Task_rec.ATTRIBUTE11,
      X_ATTRIBUTE12           => l_old_Task_rec.ATTRIBUTE12,
      X_ATTRIBUTE13           => l_old_Task_rec.ATTRIBUTE13,
      X_ATTRIBUTE14           => l_old_Task_rec.ATTRIBUTE14,
      X_ATTRIBUTE15           => l_old_Task_rec.ATTRIBUTE15,
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
   -- manisaga commented the attribute from from l_old_task_rec and and added from
   -- l_task_rec for DFF implementation on 19-Feb-2010  --- End

      X_VISIT_TASK_NAME       => l_task_rec.visit_task_name,
      X_DESCRIPTION           => l_task_rec.description,
      X_QUANTITY              => l_old_Task_rec.quantity, -- Added by rnahata for Issue 105
      X_LAST_UPDATE_DATE      => SYSDATE,
      X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
      X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID );

    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                      'After Calling Ahl_Visit_Tasks_Pkg.UPDATE_ROW');
    END IF;

   -- Added cxcheng POST11510--------------
   --Now adjust the times derivation for task
   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                     'Before Calling AHL_VWP_TIMES_PVT.Adjust_Task_Times');
   END IF;

   -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Call Adjust_Task_Times only if past date is null
   IF l_old_Task_rec.PAST_TASK_START_DATE IS NULL THEN
     AHL_VWP_TIMES_PVT.Adjust_Task_Times(p_api_version      => 1.0,
                                         p_init_msg_list    => Fnd_Api.G_FALSE,
                                         p_commit           => Fnd_Api.G_FALSE,
                                         p_validation_level => Fnd_Api.G_VALID_LEVEL_FULL,
                                         x_return_status    => l_return_status,
                                         x_msg_count        => l_msg_count,
                                         x_msg_data         => l_msg_data,
                                         p_task_id          => l_task_rec.visit_task_id);
   END IF;

   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                     'After Calling AHL_VWP_TIMES_PVT.Adjust_Task_Times, Return Status = '|| l_return_status );
   END IF;

   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

IF NVL(l_task_rec.cost_parent_id,-30) <> NVL(l_old_Task_rec.cost_parent_id,-30)
THEN
  OPEN c_any_task_flg(l_old_Task_rec.visit_id);
  FETCH c_any_task_flg INTO l_any_task_chg_flag;
  CLOSE c_any_task_flg;

  IF l_any_task_chg_flag = 'N' THEN
          AHL_VWP_RULES_PVT.Update_Visit_Task_Flag
    (p_visit_id      => l_old_Task_rec.visit_id,
     p_flag          => 'Y',
     x_return_status => x_return_status);
  END IF;
END IF;

   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Update_Tasks_in_Production;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Tasks_in_Production;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Tasks_in_Production;
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
END Update_Tasks_in_Production;

--------------------------------------------------------------------
-- PROCEDURE
--    Update_Unassociated_Task
--
-- PURPOSE
--    To update Unassociated task for the Maintainance visit.
--------------------------------------------------------------------
PROCEDURE Update_Unassociated_Task (
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
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Update_Unassociated_Task';
   L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   -- local variables defined for the procedure
   l_task_rec             AHL_VWP_RULES_PVT.Task_Rec_Type := p_x_task_rec;
   l_return_status        VARCHAR2(1);
   l_msg_data             VARCHAR2(2000);
   l_msg_count            NUMBER;
   l_serial_ID            NUMBER;
   l_cost_parent_id       NUMBER;
   l_originating_task_id  NUMBER;
   l_department_id        NUMBER;
   l_planned_order_flag   VARCHAR2(1);

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
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure.');
   END IF;

   --------------------- initialize -----------------------
   SAVEPOINT Update_Unassociated_Task;

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

   ---------------------------------------------- Start----------------------------------------------------------
   OPEN c_Visit(l_Task_rec.visit_id);
   FETCH c_Visit INTO c_Visit_rec;
   CLOSE c_Visit;

   OPEN c_Task(l_Task_rec.visit_task_id);
   FETCH c_Task INTO c_Task_rec;
   CLOSE c_Task;

   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      ': Visit Id/Task Id  = ' || l_task_rec.visit_id || '-' || l_task_rec.visit_task_id ||
                      ': Inventory Id /org/name =' || l_task_rec.inventory_item_id || '-' || l_task_rec.item_organization_id || '-' || l_task_rec.item_name ||
                      ': Cost Id -- Number=' || l_task_rec.cost_parent_id || '**' || l_task_rec.cost_parent_number ||
                      ': Originating Id/Number=' || l_task_rec.originating_task_id  || '**' || l_task_rec.orginating_task_number ||
                      ': Object version number = ' || l_task_rec.object_version_number ||
                      ': Duration from record = ' || l_task_rec.duration ||
                      ': Visit start from hour/duration=' || '-' || l_task_rec.start_from_hour || '-' || l_task_rec.duration ||
                      ': Task Type code/value=' ||  l_task_rec.task_type_code || '-' || l_task_rec.task_type_value ||
                      ': department_id = ' ||  l_task_rec.department_id );
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

          IF NVL(l_return_status,'x') <> Fnd_Api.g_ret_sts_success
          THEN
              Fnd_Message.SET_NAME('AHL','AHL_VWP_DEPT_NOT_EXISTS');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.G_EXC_ERROR;
          END IF;

          --Assign the returned value
          l_task_rec.department_id := l_department_id;

    END IF;

    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                       ': Dept ID= ' || l_Task_rec.department_id ||
                       ': Serial Number= ' || l_Task_rec.serial_number);

    END IF;
     --
     -- For SERIAL NUMBER
     -- Convert serial number to instance/ serial id
      IF (l_Task_rec.serial_number IS NOT NULL AND
              l_Task_rec.serial_number <> Fnd_Api.G_MISS_CHAR) THEN

              IF (l_log_statement >= l_log_current_level) THEN
                  fnd_log.string(l_log_statement,
                                 L_DEBUG_KEY,
                                 ' Calling  AHL_VWP_RULES_PVT.Check_Serial_Name_Or_Id' );
              END IF;

              AHL_VWP_RULES_PVT.Check_Serial_Name_Or_Id
                   (p_item_id          => l_Task_rec.inventory_item_id,
                    p_org_id           => l_Task_rec.item_organization_id,
                    p_serial_id        => l_Task_rec.instance_id,
                    p_serial_number    => l_Task_rec.serial_number,
                    x_serial_id        => l_serial_id,
                    x_return_status    => l_return_status,
                    x_error_msg_code   => l_msg_data);

          IF NVL(l_return_status,'x') <> Fnd_Api.g_ret_sts_success THEN
                    Fnd_Message.SET_NAME('AHL','AHL_VWP_SERIAL_NOT_EXISTS');
                    Fnd_Msg_Pub.ADD;
                    RAISE Fnd_Api.G_EXC_ERROR;
          ELSE

              --Assign the returned value
              l_Task_rec.instance_id := l_serial_id;

              IF (l_log_statement >= l_log_current_level) THEN
                  fnd_log.string(l_log_statement,
                                 L_DEBUG_KEY,
                                 ': Before UC Check Serial ID= ' || l_Task_rec.instance_id ||
                                 ': Before UC Item ID= ' || l_Task_rec.inventory_item_id ||
                                 ': Before UC Item Org ID= ' || l_Task_rec.item_organization_id);
              END IF;
              /* sowsubra - start
              IF c_Visit_rec.item_instance_id IS NOT NULL THEN

                      --BEGIN: jeli added for bug 3777720
                      IF (AHL_VWP_RULES_PVT.instance_in_config_tree(l_task_rec.visit_id, l_task_rec.instance_id) = FND_API.G_RET_STS_ERROR) THEN
                     --END: jeli added for bug 3777720
                        Fnd_Message.SET_NAME('AHL','AHL_VWP_TASK_SERIAL');
                        Fnd_Msg_Pub.ADD;
                        RAISE Fnd_Api.G_EXC_ERROR;
                      END IF;
              END IF;
              sowsubra - end */
          END IF;

        END IF;

        IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           ': Serial ID= ' || l_Task_rec.instance_id ||
                           ': Cost parent= ' || l_Task_rec.cost_parent_number);
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

          IF NVL(l_return_status,'x') <> Fnd_Api.g_ret_sts_success
          THEN
              Fnd_Message.SET_NAME('AHL','AHL_VWP_PARENT_NOT_EXISTS');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.g_exc_error;
          END IF;

           --Assign the returned value
           l_Task_rec.cost_parent_id := l_cost_parent_id;
     END IF;

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        ': Cost parent ID = ' || l_Task_rec.cost_parent_id ||
                        ': Validation: Start -- For COST PARENT ');
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

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        ': Validation: End -- For COST PARENT ' ||
                        ': Originating Number = ' || l_Task_rec.orginating_task_number);
     END IF;

     --
     -- For ORIGINATING TASK
     -- Convert originating task number to id
      IF (l_Task_rec.orginating_task_number IS NOT NULL AND
          l_Task_rec.orginating_task_number <> Fnd_Api.G_MISS_NUM ) THEN

          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             ' Calling AHL_VWP_RULES_PVT.Check_Visit_Task_Number_OR_ID');
          END IF;

          AHL_VWP_RULES_PVT.Check_Visit_Task_Number_OR_ID
               (p_visit_task_id      => l_Task_rec.originating_task_id,
                p_visit_task_number  => l_Task_rec.orginating_task_number,
                p_visit_id           => l_Task_rec.visit_id,
                x_visit_task_id      => l_originating_task_id,
                x_return_status      => l_return_status,
                x_error_msg_code     => l_msg_data);

          IF NVL(l_return_status,'x') <> Fnd_Api.g_ret_sts_success
          THEN
              Fnd_Message.SET_NAME('AHL','AHL_VWP_ORIGINATING_NOT_EXISTS');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.g_exc_error;
          END IF;

          --Assign the returned value
          l_Task_rec.originating_task_id := l_originating_task_id;
     END IF;

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        ': Originating Task ID= ' || l_Task_rec.originating_task_id ||
                        ': Validation: Start -- For ORIGINATING TASK');
     END IF;

   -- To Check for originating task id not forming loop
    IF (l_Task_rec.originating_task_id IS NOT NULL AND
        l_Task_rec.originating_task_id <> Fnd_Api.G_MISS_NUM ) THEN

        AHL_VWP_RULES_PVT.Check_Origin_Task_Loop
            (p_visit_id             => l_Task_rec.visit_id ,
             p_visit_task_id        => l_Task_rec.visit_task_id ,
             p_originating_task_id  => l_Task_rec.originating_task_id
             );
    END IF;

    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                       ': Validation: End -- For ORIGINATING TASK');
    END IF;

    ----------- End defining and validate all LOVs on Create Visit's Task UI Screen---

   ----------------------- validate ----------------------
    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                      ':Validate ');
    END IF;

  -- For all optional fields check if its g_miss_num/g_miss_char/g_miss_date
  -- then Null else the value call Default_Missing_Attribs procedure
        Default_Missing_Attribs
        (
        p_x_task_rec             => l_Task_rec
        );

-- Post 11.5.10 Changes by Senthil.
   IF(L_task_rec.STAGE_ID IS NOT NULL OR L_task_rec.STAGE_NAME IS NOT NULL) THEN
      IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                        'Before Calling AHL_VWP_VISITS_STAGES_PVT.VALIDATE_STAGE_UPDATES');
      END IF;
      AHL_VWP_VISITS_STAGES_PVT.VALIDATE_STAGE_UPDATES(
      P_API_VERSION      =>  1.0,
      P_VISIT_ID         =>  l_Task_rec.visit_id,
      P_VISIT_TASK_ID    =>  l_Task_rec.visit_task_id,
      P_STAGE_NAME       =>  L_task_rec.STAGE_NAME,
      X_STAGE_ID         =>  L_task_rec.STAGE_ID,
      X_RETURN_STATUS    =>  l_return_status,
      X_MSG_COUNT        =>  l_msg_count,
      X_MSG_DATA         =>  l_msg_data  );
      IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                        'After Calling AHL_VWP_VISITS_STAGES_PVT.VALIDATE_STAGE_UPDATES, Return Status = ' || l_return_status );
      END IF;

   END IF;

   IF l_msg_count > 0 OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

-- post 11.5.10 changes by Senthil end

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

    --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

 -------------------------- update --------------------
    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                       'Before Calling Ahl_Visit_Tasks_Pkg.UPDATE_ROW');
    END IF;

    Ahl_Visit_Tasks_Pkg.UPDATE_ROW (
      X_VISIT_TASK_ID         => l_task_rec.visit_task_id,
      X_VISIT_TASK_NUMBER     => c_task_rec.visit_task_number,
      X_OBJECT_VERSION_NUMBER => l_task_rec.OBJECT_VERSION_NUMBER + 1,
      X_VISIT_ID              => l_task_rec.visit_id,
      X_PROJECT_TASK_ID       => c_task_rec.project_task_id,
      X_COST_PARENT_ID        => l_task_rec.cost_parent_id,
      X_MR_ROUTE_ID           => c_task_rec.mr_route_id,
      X_MR_ID                 => c_task_rec.mr_id,
      X_DURATION              => l_task_rec.duration,
      X_UNIT_EFFECTIVITY_ID   => c_task_rec.unit_effectivity_id,
      X_START_FROM_HOUR       => l_task_rec.start_from_hour,
      X_INVENTORY_ITEM_ID     => c_task_rec.inventory_item_id,
      X_ITEM_ORGANIZATION_ID  => c_task_rec.item_organization_id,
      X_INSTANCE_ID           => l_Task_rec.instance_id,
      X_PRIMARY_VISIT_TASK_ID => c_task_rec.primary_visit_task_id,
      X_ORIGINATING_TASK_ID   => l_task_rec.originating_task_id,
      X_SERVICE_REQUEST_ID    => l_task_rec.service_request_id,
      X_TASK_TYPE_CODE        => l_task_rec.task_type_code,
      X_DEPARTMENT_ID         => l_task_rec.department_id,
      X_SUMMARY_TASK_FLAG     => 'N',
      X_PRICE_LIST_ID         => c_task_rec.price_list_id,
      X_STATUS_CODE           => c_task_rec.status_code,
      X_ESTIMATED_PRICE       => c_task_rec.estimated_price,
      X_ACTUAL_PRICE          => c_task_rec.actual_price,
      X_ACTUAL_COST           => c_task_rec.actual_cost,
--  Post 11.5.10 Changes by Senthil.
      X_STAGE_ID              =>  l_task_rec.STAGE_ID,
  -- Added cxcheng POST11510--------------
  -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010
  -- Pass past dates too, and if it is null, pass null for all the 4 columns below
      X_START_DATE_TIME       => l_task_rec.PAST_TASK_START_DATE,
      X_END_DATE_TIME         => l_task_rec.PAST_TASK_END_DATE,
      X_PAST_TASK_START_DATE  => l_task_rec.PAST_TASK_START_DATE,
      X_PAST_TASK_END_DATE    => l_task_rec.PAST_TASK_END_DATE,
  --  manisaga commented the attribute from c_task_rec and added attributes from
  --  l_tasc_rec for DFF implementation on 19-Feb-2010  -- Start
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
  --  manisaga commented the attribute from c_task_rec and added attributes from
  --  l_tasc_rec for DFF implementation on 19-Feb-2010  -- End

      X_VISIT_TASK_NAME       => l_task_rec.visit_task_name,
      X_DESCRIPTION           => l_task_rec.description,
      X_QUANTITY              => c_task_rec.quantity, -- Added by rnahata for Issue 105
      X_LAST_UPDATE_DATE      => SYSDATE,
      X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
      X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID );

    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                       'After Calling Ahl_Visit_Tasks_Pkg.UPDATE_ROW');
    END IF;

   -- Added cxcheng POST11510--------------
   --Now adjust the times derivation for task
   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'Before Calling AHL_VWP_TIMES_PVT.Adjust_Task_Times');
   END IF;

   -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Call Adjust_Task_Times only if past date is null
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

   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'After Calling AHL_VWP_TIMES_PVT.Adjust_Task_Times, Return Status = ' || l_return_status);
   END IF;

   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

    IF  NVL(l_task_rec.Duration, -10) <> NVL(c_task_rec.Duration, -10) OR
      NVL(l_task_rec.start_from_hour, -20) <> NVL(c_task_rec.start_from_hour, -20) OR
      NVL(l_task_rec.department_id, -20) <> NVL(c_task_rec.department_id, -20)   OR
      NVL(l_task_rec.stage_id, -20) <> NVL(c_task_rec.stage_id, -20)
    THEN

       OPEN c_Task(l_Task_rec.visit_task_id);
       FETCH c_Task INTO c_upd_Task_rec;
       CLOSE c_Task;

       IF c_upd_Task_rec.start_date_time IS NOT NULL THEN

         IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Before Calling AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials');
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

          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             'After Calling AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials' ||
                             'Planned Order Flag : ' || l_planned_order_flag ||
                             'Return Status = ' || l_return_status );
          END IF;

          IF l_return_status <> 'S' THEN
            RAISE Fnd_Api.G_EXC_ERROR;
          END IF;

        END IF; -- Start_date_time check.

        IF c_visit_rec.any_task_chg_flag = 'N' THEN
           AHL_VWP_RULES_PVT.Update_Visit_Task_Flag
               (p_visit_id      => l_task_rec.visit_id,
          p_flag          =>  'Y',
                x_return_status => x_return_status);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
    END IF;

   -------------------- finish --------------------------

   ------------------------End of API Body------------------------------------
   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Update_Unassociated_Task;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Unassociated_Task;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Unassociated_Task;
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
END Update_Unassociated_Task;

--------------------------------------------------------------------
-- PROCEDURE
--    Update_Summary_Task
--
-- PURPOSE
--    To update Summary task for the Maintainance visit.
--------------------------------------------------------------------
PROCEDURE Update_Summary_Task (
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
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Update_Summary_Task';
   L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   -- local variables defined for the procedure
   l_task_rec             AHL_VWP_RULES_PVT.Task_Rec_Type := p_x_task_rec;
   l_return_status        VARCHAR2(1);
   l_msg_data             VARCHAR2(2000);

   l_msg_count            NUMBER;
   l_serial_ID            NUMBER;
   l_cost_parent_id       NUMBER;
   l_originating_task_id  NUMBER;
   l_department_id        NUMBER;

   -- To find task related information
   CURSOR c_Task (x_id IN NUMBER) IS
      SELECT * FROM  Ahl_Visit_Tasks_VL
      WHERE  VISIT_TASK_ID = x_id;
   c_Task_rec    c_Task%ROWTYPE;

   -- To find visit related information
   CURSOR c_Visit (x_id IN NUMBER) IS
      SELECT * FROM Ahl_Visits_VL
      WHERE  VISIT_ID = x_id;
   c_Visit_rec    c_Visit%ROWTYPE;

 BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure.');
   END IF;
   --------------------- initialize -----------------------
   SAVEPOINT Update_Summary_Task;

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

   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      ': Visit Id/Task Id  = ' || l_task_rec.visit_id || '-' || l_task_rec.visit_task_id ||
                      ': Inventory Id /org/name =' || l_task_rec.inventory_item_id || '-' || l_task_rec.item_organization_id || '-' || l_task_rec.item_name ||
                      ': Cost Id -- Number=' || l_task_rec.cost_parent_id || '**' || l_task_rec.cost_parent_number ||
                      ': Originating Id/Number=' || l_task_rec.originating_task_id  || '**' || l_task_rec.orginating_task_number ||
                      ': Object version number = ' || l_task_rec.object_version_number ||
                      ': Duration from record = ' || l_task_rec.duration ||
                      ': Visit start from hour/duration=' || '-' || l_task_rec.start_from_hour || '-' || l_task_rec.duration ||
                      ': Task Type code/value=' ||  l_task_rec.task_type_code || '-' || l_task_rec.task_type_value ||
                      ': department_id = ' ||  l_task_rec.department_id );
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

          IF NVL(l_return_status,'x') <> Fnd_Api.g_ret_sts_success
          THEN
              Fnd_Message.SET_NAME('AHL','AHL_VWP_DEPT_NOT_EXISTS');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.G_EXC_ERROR;
          END IF;

          --Assign the returned value
          l_task_rec.department_id := l_department_id;
    END IF;

    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                       ': Dept ID= ' || l_Task_rec.department_id );
    END IF;

    -- Called only when updating serial number for manually created summary task
    -- which are without MR i.e MR_Id in cursor record c_task_rec will be Null
    IF c_Task_rec.MR_Id IS NULL THEN

      IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         ': Serial Number= ' || l_Task_rec.serial_number);
      END IF;

     --
     -- For SERIAL NUMBER
     -- Convert serial number to instance/ serial id
      IF (l_Task_rec.serial_number IS NOT NULL AND
          l_Task_rec.serial_number <> Fnd_Api.G_MISS_CHAR) THEN

              AHL_VWP_RULES_PVT.Check_Serial_Name_Or_Id
                   (p_item_id          => l_Task_rec.inventory_item_id,
                    p_org_id           => l_Task_rec.item_organization_id,
                    p_serial_id        => l_Task_rec.instance_id,
                    p_serial_number    => l_Task_rec.serial_number,
                    x_serial_id        => l_serial_id,
                    x_return_status    => l_return_status,
                    x_error_msg_code   => l_msg_data);

          IF NVL(l_return_status,'x') <> Fnd_Api.g_ret_sts_success THEN
                    Fnd_Message.SET_NAME('AHL','AHL_VWP_SERIAL_NOT_EXISTS');
                    Fnd_Msg_Pub.ADD;
                    RAISE Fnd_Api.G_EXC_ERROR;
          ELSE

              --Assign the returned value
              l_Task_rec.instance_id := l_serial_id;

              IF (l_log_statement >= l_log_current_level) THEN
                  fnd_log.string(l_log_statement,
                                 L_DEBUG_KEY,
                                 ': Before UC Check Serial ID= ' || l_Task_rec.instance_id ||
                                 ': Before UC Item ID= ' || l_Task_rec.inventory_item_id ||
                                 ': Before UC Item Org ID= ' || l_Task_rec.item_organization_id);
              END IF;
              /* sowsubra - start
              --BEGIN: jeli added for bug 3777720
              IF (AHL_VWP_RULES_PVT.instance_in_config_tree(l_task_rec.visit_id, l_task_rec.instance_id) = FND_API.G_RET_STS_ERROR) THEN
              --END: jeli added for bug 3777720
                  Fnd_Message.SET_NAME('AHL','AHL_VWP_TASK_SERIAL');
                  Fnd_Msg_Pub.ADD;
                  RAISE Fnd_Api.G_EXC_ERROR;
              END IF;
              sowsubra - end */

          END IF; -- End of l_return_status success check

        END IF; -- End of l_Task_rec.serial_number Null check

        IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           ': Serial ID= ' || l_Task_rec.instance_id);
        END IF;

    ELSE
        l_Task_rec.instance_id := c_Task_rec.instance_id;
    END IF; -- End of c_Task_rec.MR_Id Null check

    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                       ': Cost parent= ' || l_Task_rec.cost_parent_number);
    END IF;

     --
     -- For COST PARENT TASK
     -- Convert cost parent number to id
      IF (l_Task_rec.cost_parent_number IS NOT NULL AND
          l_Task_rec.cost_parent_number <> Fnd_Api.G_MISS_NUM ) THEN

          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             ' Calling AHL_VWP_RULES_PVT.Check_Visit_Task_Number_OR_ID');
          END IF;

          AHL_VWP_RULES_PVT.Check_Visit_Task_Number_OR_ID
               (p_visit_task_id      => l_Task_rec.cost_parent_id,
                p_visit_task_number  => l_Task_rec.cost_parent_number,
                p_visit_id           => l_Task_rec.visit_id,
                x_visit_task_id      => l_cost_parent_id,
                x_return_status      => l_return_status,
                x_error_msg_code     => l_msg_data);

          IF NVL(l_return_status,'x') <> Fnd_Api.g_ret_sts_success
          THEN
              Fnd_Message.SET_NAME('AHL','AHL_VWP_PARENT_NOT_EXISTS');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.g_exc_error;
          END IF;

           --Assign the returned value
           l_Task_rec.cost_parent_id := l_cost_parent_id;
     ELSE
           l_Task_rec.cost_parent_id := NULL;
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

   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      ': Cost parent ID = ' || l_Task_rec.cost_parent_id);
   END IF;

   IF c_Task_rec.MR_Id IS NULL THEN
     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        ': Originating Number = ' || l_Task_rec.orginating_task_number);
     END IF;

     --
     -- For ORIGINATING TASK
     -- Convert originating task number to id
      IF (l_Task_rec.orginating_task_number IS NOT NULL AND
          l_Task_rec.orginating_task_number <> Fnd_Api.G_MISS_NUM ) THEN

          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             ' Calling AHL_VWP_RULES_PVT.Check_Visit_Task_Number_OR_ID');
          END IF;

          AHL_VWP_RULES_PVT.Check_Visit_Task_Number_OR_ID
               (p_visit_task_id      => l_Task_rec.originating_task_id,
                p_visit_task_number  => l_Task_rec.orginating_task_number,
                p_visit_id           => l_Task_rec.visit_id,
                x_visit_task_id      => l_originating_task_id,
                x_return_status      => l_return_status,
                x_error_msg_code     => l_msg_data);

          IF NVL(l_return_status,'x') <> Fnd_Api.g_ret_sts_success
          THEN
              Fnd_Message.SET_NAME('AHL','AHL_VWP_ORIGINATING_NOT_EXISTS');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.g_exc_error;
          END IF;

          --Assign the returned value
          l_Task_rec.originating_task_id := l_originating_task_id;
     ELSE
          l_Task_rec.originating_task_id := NULL;
     END IF;

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        ': Originating Task ID= ' || l_Task_rec.originating_task_id);
     END IF;

        -- To Check for originating task id not forming loop
     IF (l_Task_rec.originating_task_id IS NOT NULL AND
        l_Task_rec.originating_task_id <> Fnd_Api.G_MISS_NUM ) THEN

        AHL_VWP_RULES_PVT.Check_Origin_Task_Loop
            (p_visit_id             => l_Task_rec.visit_id ,
             p_visit_task_id        => l_Task_rec.visit_task_id ,
             p_originating_task_id  => l_Task_rec.originating_task_id
            );

     END IF;

  ELSE
     l_Task_rec.originating_task_id := c_Task_rec.originating_task_id;
  END IF;

   ----------- End defining and validate all LOVs on Create Visit's Task UI Screen---

   ----------------------- validate ----------------------

   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      ':Validate');
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

    --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

 -------------------------- update --------------------
   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'Before Calling Ahl_Visit_Tasks_Pkg.UPDATE_ROW');
   END IF;

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
      X_INSTANCE_ID           => l_Task_rec.instance_id,
      X_PRIMARY_VISIT_TASK_ID => c_task_rec.primary_visit_task_id,
      X_ORIGINATING_TASK_ID   => l_task_rec.originating_task_id,
      X_SERVICE_REQUEST_ID    => c_task_rec.service_request_id,
      X_TASK_TYPE_CODE        => l_task_rec.task_type_code,
      X_DEPARTMENT_ID         => l_task_rec.department_id,
      X_SUMMARY_TASK_FLAG     => 'N',
      X_PRICE_LIST_ID         => c_task_rec.price_list_id,
      X_STATUS_CODE           => c_task_rec.status_code,
      X_ESTIMATED_PRICE       => c_task_rec.estimated_price,
      X_ACTUAL_PRICE          => c_task_rec.actual_price,
      X_ACTUAL_COST           => c_task_rec.actual_cost,
--  Post 11.5.10 Changes by Senthil.
      X_STAGE_ID              =>  l_task_rec.STAGE_ID,
       -- Added cxcheng POST11510--------------
   -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Pass past dates too
      X_START_DATE_TIME       => NULL,
      X_END_DATE_TIME         => NULL,
      X_PAST_TASK_START_DATE  => NULL,
      X_PAST_TASK_END_DATE    => NULL,
   -- manisaga removed attributes addition from c_task_rec and added from
   -- l_task_rec for DFF implementation on 19-Feb-2010  -- Start
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
   -- manisaga removed attributes addition from c_task_rec and added from
   -- l_task_rec for DFF implementation on 19-Feb-2010  -- End

      X_VISIT_TASK_NAME       => l_task_rec.visit_task_name,
      X_DESCRIPTION           => l_task_rec.description,
      -- Added by rnahata for Issue 105 - qty is zero for manually created summary tasks
      X_QUANTITY              => 0,
      X_LAST_UPDATE_DATE      => SYSDATE,
      X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
      X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID );

   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'After Calling Ahl_Visit_Tasks_Pkg.UPDATE_ROW');
   END IF;

------------------------End of API Body------------------------------------
   -- Added cxcheng POST11510--------------
   --Now adjust the times derivation for task
   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'Before calling AHL_VWP_TIMES_PVT.Adjust_Task_Times');
   END IF;
   AHL_VWP_TIMES_PVT.Adjust_Task_Times(p_api_version      => 1.0,
                                       p_init_msg_list    => Fnd_Api.G_FALSE,
                                       p_commit           => Fnd_Api.G_FALSE,
                                       p_validation_level => Fnd_Api.G_VALID_LEVEL_FULL,
                                       x_return_status    => l_return_status,
                                       x_msg_count        => l_msg_count,
                                       x_msg_data         => l_msg_data,
                                       p_task_id          =>l_task_rec.visit_task_id);
   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'After Calling AHL_VWP_TIMES_PVT.Adjust_Task_Times, Return Status = ' || l_return_status);
   END IF;

    --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Update_Summary_Task;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Summary_Task;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Summary_Task;
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
END Update_Summary_Task;

--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Task
--
-- PURPOSE
--    To delete all types of tasks i.e Unassociated/Summary/Planned/Unplanned tasks.
--------------------------------------------------------------------
PROCEDURE Delete_Task (
   p_api_version      IN  NUMBER,
   p_init_msg_list    IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit           IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type      IN  VARCHAR2  := 'JSP',
   p_Visit_Task_Id    IN  NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2
)
IS
   L_API_VERSION CONSTANT NUMBER := 1.0;
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Delete_Task';
   L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   -- local variables defined for the procedure
   l_msg_data             VARCHAR2(2000);
   l_return_status        VARCHAR2(1);
   l_interaction_id       NUMBER;
   l_msg_count            NUMBER;

   -- To find task related information
   CURSOR c_Task (x_id IN NUMBER) IS
      SELECT * FROM  Ahl_Visit_Tasks_VL
      WHERE  VISIT_TASK_ID = x_id;
   c_Task_rec    c_Task%ROWTYPE;

   -- To find visit related information
   CURSOR c_Visit (x_id IN NUMBER) IS
      SELECT * FROM Ahl_Visits_VL
      WHERE  VISIT_ID = x_id;
   c_Visit_rec    c_Visit%ROWTYPE;

   CURSOR c_sr_ovn(c_sr_id IN NUMBER) IS
      SELECT object_version_number, incident_number
      FROM cs_incidents_all_b
      WHERE INCIDENT_ID = c_sr_id;
   c_sr_ovn_rec c_sr_ovn%ROWTYPE;

-- post 11.5.10
-- yazhou start

  CURSOR c_visit_task_exists(p_visit_id IN NUMBER)
  IS
    SELECT 'x'
    FROM   ahl_visit_tasks_b
    WHERE  visit_id = p_visit_id
    AND  STATUS_CODE = 'PLANNING';

-- yazhou end
-- amagrawa start
CURSOR c_get_wo_details(x_id IN NUMBER)
 IS
 SELECT
        scheduled_start_date,
        SCHEDULED_COMPLETION_DATE
 FROM   wip_discrete_jobs WHERE wip_entity_id =
        (
         SELECT
         wip_entity_id
         FROM ahl_workorders
         WHERE
           master_workorder_flag = 'Y' AND
           visit_task_id IS null AND
           status_code not in (22,7) and
           visit_id=x_id
          );
   c_get_wo_details_rec  c_get_wo_details%ROWTYPE;
-- amagrawa end

   l_dummy VARCHAR2(1);

   l_planned_order_flag VARCHAR2(1);

 BEGIN

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure.');
   END IF;
   --------------------- initialize -----------------------
   SAVEPOINT Delete_Task;

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
 --------------------Start of API Body-----------------------------------

 -------------------Cursor values------------------------------------
   OPEN c_Task(p_visit_task_id);
   FETCH c_Task INTO c_Task_rec;
   CLOSE c_Task;

   OPEN c_visit(c_task_rec.visit_id);
   FETCH c_visit INTO c_visit_rec;
   CLOSE c_visit;

   OPEN c_sr_ovn(c_task_rec.service_request_id);
   FETCH c_sr_ovn into c_sr_ovn_rec;
   CLOSE c_sr_ovn;

   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      ': Visit Id = ' || c_visit_rec.visit_id ||
                      ': Status Code ' || c_visit_rec.status_code ||
                      ': Visit Id = ' || c_task_rec.visit_task_id);
   END IF;

   ---------------------------------------------- Start----------------------------------------------------------

   IF c_visit_rec.status_code IN ('CLOSED','CANCELLED') THEN
       Fnd_Message.SET_NAME('AHL','AHL_VWP_NOT_USE_VISIT');
       Fnd_Msg_Pub.ADD;
       RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF c_task_rec.status_code = 'PLANNING' THEN
        IF c_task_rec.task_type_code = 'SUMMARY' THEN

         IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                           'Before Calling Delete_Summary_Task');
         END IF;
         Delete_Summary_Task
          ( p_api_version      => l_api_version,
            p_init_msg_list    => p_init_msg_list,
            p_commit           => Fnd_Api.g_false,
            p_validation_level => p_validation_level,
            p_module_type      => p_module_type,
            p_visit_task_id    => p_visit_task_id,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data
          );

         IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                           'After Calling Delete_Summary_Task, Return Status = ' || l_return_status );
         END IF;

       ELSIF c_task_rec.task_type_code = 'PLANNED' THEN

          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                            'Before Calling AHL_VWP_PLAN_TASKS_PVT.Delete_Planned_Task');
          END IF;
          AHL_VWP_PLAN_TASKS_PVT.Delete_Planned_Task
          ( p_api_version      => l_api_version,
            p_init_msg_list    => p_init_msg_list,
            p_commit           => Fnd_Api.g_false,
            p_validation_level => p_validation_level,
            p_module_type      => p_module_type,
            p_visit_task_id    => p_visit_task_id,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data
          );

          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                            'After Calling AHL_VWP_PLAN_TASKS_PVT.Delete_Planned_Task, Return Status = ' || l_return_status);
          END IF;

       ELSIF c_task_rec.task_type_code = 'UNPLANNED' THEN

          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                            'Before Calling AHL_VWP_UNPLAN_TASKS_PVT.Delete_Unplanned_Task');
          END IF;
          AHL_VWP_UNPLAN_TASKS_PVT.Delete_Unplanned_Task
          ( p_api_version      => l_api_version,
            p_init_msg_list    => p_init_msg_list,
            p_commit           => Fnd_Api.g_false,
            p_validation_level => p_validation_level,
            p_module_type      => p_module_type,
            p_visit_task_id    => p_visit_task_id,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data
          );

          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                            'After Calling AHL_VWP_UNPLAN_TASKS_PVT.Delete_Unplanned_Task, Return Status = ' || l_return_status );
          END IF;

       ELSE

         IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                           'Before Calling Delete_Unassociated_Task');
         END IF;
         Delete_Unassociated_Task
         (p_api_version      => l_api_version,
          p_init_msg_list    => p_init_msg_list,
          p_commit           => Fnd_Api.g_false,
          p_validation_level => p_validation_level,
          p_module_type      => p_module_type,
          p_visit_task_id    => p_visit_task_id,
          x_return_status    => l_return_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data
          );
          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             'After Calling Delete_Unassociated_Task, Return Status = ' || l_return_status);
          END IF;

    END IF;

   l_msg_count := Fnd_Msg_Pub.count_msg;

    IF l_msg_count > 0 OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

  -- Added cxcheng POST11510--------------
   --Now adjust the times derivation for entire visit task could delete at
   --MR level

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Before Calling AHL_VWP_TIMES_PVT.calculate_Task_Times');
     END IF;

     AHL_VWP_TIMES_PVT.calculate_Task_Times(p_api_version      => 1.0,
                                            p_init_msg_list    => Fnd_Api.G_FALSE,
                                            p_commit           => Fnd_Api.G_FALSE,
                                            p_validation_level => Fnd_Api.G_VALID_LEVEL_FULL,
                                            x_return_status    => l_return_status,
                                            x_msg_count        => l_msg_count,
                                            x_msg_data         => l_msg_data,
                                            p_visit_id         => c_task_rec.visit_id);

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'After Calling AHL_VWP_TIMES_PVT.calculate_Task_Times, Return Status = ' || l_return_status);
     END IF;

  IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Before Calling AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials');
  END IF;

  /* Operation flag changed to 'U' From 'R' by mpothuku on 02/07/05 */
  AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials
    (p_api_version        => p_api_version,
     p_init_msg_list      => Fnd_Api.G_FALSE,
     p_commit             => Fnd_Api.G_FALSE,
     p_visit_id           => c_task_rec.visit_id,
     p_visit_task_id      => NULL,
     p_org_id             => NULL,
     p_start_date         => NULL,
     p_operation_flag     => 'U',
     x_planned_order_flag => l_planned_order_flag ,
     x_return_status      => l_return_status,
     x_msg_count          => l_msg_count,
     x_msg_data           => l_msg_data);

  IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'After Calling AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials, Return Status =  ' || l_return_status);
  END IF;

  IF l_msg_count > 0 OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
    x_msg_count := l_msg_count;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

        -- post 11.5.10
        --yazhou start
        -- If visit is in partially released status
        -- and after this task is deleted, no other task is in Planning status
        -- then set the visit status to RELEASED
        IF c_visit_rec.status_code = 'PARTIALLY RELEASED' THEN
        -- yazhou end

           OPEN c_visit_task_exists(c_visit_rec.visit_id);
           FETCH c_visit_task_exists INTO l_dummy;
           OPEN c_get_wo_details(c_task_rec.visit_id);
           FETCH c_get_wo_details into c_get_wo_details_rec;

           IF (c_visit_task_exists%NOTFOUND and
           c_visit_rec.start_date_time = c_get_wo_details_rec.scheduled_start_date and
           c_visit_rec.close_date_time = c_get_wo_details_rec.scheduled_completion_date)
           THEN
               UPDATE ahl_visits_b
                 SET status_code = 'RELEASED',
                     object_version_number = object_version_number + 1
                WHERE visit_id = c_visit_rec.visit_id;
           END IF;
           CLOSE c_visit_task_exists;
           CLOSE c_get_wo_details;

    -- post 11.5.10
    -- yazhou start

        END IF;

-- yazhou end

-- yazhou 29-Jun-2006 starts
-- bug#5359943
-- Pass p_status_id as 1 (OPEN)

    -- If SR Id of task is not null
    -- then update the status of the SR to OPEN
    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                       'Service Request Id = ' || c_task_rec.service_request_id);
    END IF;
    IF c_task_rec.service_request_id IS NOT NULL THEN
      IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'Before Calling CS_ServiceRequest_PUB.Update_Status');
      END IF;

      CS_ServiceRequest_PUB.Update_Status
      (
        p_api_version => 2.0,
        p_init_msg_list => p_init_msg_list,
        p_commit => FND_API.G_FALSE,
        p_resp_appl_id => NULL,
        p_resp_id => NULL,
        p_user_id => NULL,
        p_login_id => NULL,
        p_status_id => 1,   --OPEN
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
--      p_status => 'OPEN',
        x_interaction_id => l_interaction_id
      );
-- yazhou 29-Jun-2006 ends

        IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'After Calling CS_ServiceRequest_PUB.Update_Status, Return Status = ' || l_return_status);
        END IF;

  l_msg_count := Fnd_Msg_Pub.count_msg;

      IF l_msg_count > 0 OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
          x_msg_count := l_msg_count;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
     END IF;

END IF;

  -- Bug fix #4187213
  -- yazhou 16-Feb-2005
    IF c_visit_rec.Any_Task_Chg_Flag='N' THEN
     AHL_VWP_RULES_PVT.update_visit_task_flag(
    p_visit_id         =>c_visit_rec.visit_id,
    p_flag             =>'Y',
    x_return_status    =>x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  ------------------------End of API Body------------------------------------

   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Delete_Task;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Delete_Task;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Task;
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
END Delete_Task;

--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Unassociated_Task
--
-- PURPOSE
--    To delete Unassociated tasks for the Maintenace visit.
--------------------------------------------------------------------

PROCEDURE Delete_Unassociated_Task (
   p_api_version      IN         NUMBER,
   p_init_msg_list    IN         VARCHAR2  := Fnd_Api.g_false,
   p_commit           IN         VARCHAR2  := Fnd_Api.g_false,
   p_validation_level IN         NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type      IN         VARCHAR2  := 'JSP',
   p_visit_task_ID    IN         NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2
)

IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Delete_Unassociated_Task';
   L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   -- local variables defined for the procedure
   l_visit_id             NUMBER;
   l_task_id              NUMBER;
   x_task_id              NUMBER;
   l_est_price            NUMBER;
   l_act_price            NUMBER;
   l_count                NUMBER;
   l_msg_count            NUMBER;
   l_msg_data             VARCHAR2(2000);
   l_return_status        VARCHAR2(1);

  -- To find all tasks related information
   CURSOR c_Task (x_id IN NUMBER) IS
      SELECT * FROM Ahl_Visit_Tasks_VL
      WHERE Visit_Task_ID = x_id;
      c_task_rec    c_Task%ROWTYPE;

  -- To find visit related information
   CURSOR c_Visit (x_id IN NUMBER) IS
      SELECT *
      FROM  Ahl_Visits_VL
      WHERE VISIT_ID = x_id;
      c_visit_rec      c_Visit%ROWTYPE;

  -- To find any task which have primary visit task id as deleted task id
    --CURSOR c_primary (x_visit_id IN NUMBER, x_task_id IN NUMBER) IS
  CURSOR c_primary (x_task_id IN NUMBER) IS
      SELECT Visit_Task_Id, Object_Version_Number,visit_id
      FROM  Ahl_Visit_Tasks_VL
      WHERE --VISIT_ID = x_visit_id AND
    PRIMARY_VISIT_TASK_ID = x_task_id
      AND status_code <> 'DELETED';
     c_primary_rec     c_primary%ROWTYPE;

 -- To find any task links for a deleted task
    CURSOR c_links (x_id IN NUMBER) IS
      SELECT COUNT(*) FROM Ahl_Task_Links L ,Ahl_Visit_Tasks_B T
      WHERE (T.VISIT_TASK_ID = L.VISIT_TASK_ID OR T.VISIT_TASK_ID = L.PARENT_TASK_ID)
      AND T.VISIT_TASK_ID = x_id;

    -- To find if WIP job is created for the Visit
    CURSOR c_wo_exist(x_task_id IN NUMBER)
    IS
    select 'X' from ahl_workorders
                  where VISIT_TASK_ID=x_task_id;

    -- To find if WIP job is created for the Visit
    CURSOR c_workorders(x_task_id IN NUMBER)
    IS
    SELECT * FROM AHL_WORKORDERS
    WHERE VISIT_TASK_ID=x_task_id
    AND STATUS_CODE<>'22' AND STATUS_CODE<> '7';

    l_workrec           c_workorders%ROWTYPE;
    l_workorder_rec     AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_REC;
    l_workoper_tbl      AHL_PRD_WORKORDER_PVT.PRD_WORKOPER_TBL;
    l_wip_load_flag     VARCHAR2(1):= 'Y';
    l_workorder_present VARCHAR2(1);

BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.begin',
                      'At the start of PL SQL procedure.');
   END IF;

   --------------------- initialize -----------------------
   SAVEPOINT Delete_Unassociated_Task;

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
   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      ':Task Id' || p_visit_task_ID);
   END IF;

   -- To check if the input taskid exists in task entity.
   OPEN c_Task(p_Visit_Task_ID);
   FETCH c_Task INTO c_task_rec;

   IF c_Task%NOTFOUND THEN
      CLOSE c_Task;
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
             Fnd_Message.set_name('AHL', 'AHL_API_RECORD_NOT_FOUND');
             Fnd_Msg_Pub.ADD;
      END IF;
      RAISE Fnd_Api.g_exc_error;
   END IF;
   CLOSE c_Task;

      -- To find the visit related information
      OPEN c_Visit(c_task_rec.visit_id);
      FETCH c_Visit INTO c_visit_rec;
      CLOSE c_Visit;

      OPEN  c_workorders(c_task_rec.visit_task_id);
      FETCH c_workorders INTO l_workrec;

      IF c_workorders%FOUND THEN

        IF l_workrec.status_code='17' THEN
            l_workorder_rec.workorder_id:=l_workrec.workorder_id;
            l_workorder_rec.visit_task_id:=p_visit_task_id;

            Get_WorkOrder_Attribs(
              p_x_prd_workorder_rec => l_workorder_rec
            );

            l_msg_count := FND_MSG_PUB.count_msg;
             IF l_msg_count > 0 THEN
                x_msg_count := l_msg_count;
                x_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
             END IF;

            l_workorder_rec.wip_entity_id := null;
            l_workorder_rec.STATUS_CODE:='22'; --Deleted Status Refer DLD to Verify.

            IF (l_log_statement >= l_log_current_level) THEN
                fnd_log.string(l_log_statement,
                               L_DEBUG_KEY,
                               'Before Calling AHL_PRD_WORKORDER_PVT.update_job');
            END IF;
            AHL_PRD_WORKORDER_PVT.update_job
            (
             p_api_version         => 1.0,
             p_init_msg_list       => fnd_api.g_false,
             p_commit              => fnd_api.g_false,
             p_validation_level    => p_validation_level,
             p_default             => fnd_api.g_false,
             p_module_type         => NULL,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             p_wip_load_flag       => 'Y',
             p_x_prd_workorder_rec => l_workorder_rec,
             p_x_prd_workoper_tbl  => l_workoper_tbl
             );

             IF (l_log_statement >= l_log_current_level) THEN
                 fnd_log.string(l_log_statement,
                                L_DEBUG_KEY,
                                'After Calling AHL_PRD_WORKORDER_PVT.update_job, Return Status = ' || x_return_status);
             END IF;

             l_msg_count := FND_MSG_PUB.count_msg;
             IF l_msg_count > 0 OR NVL(x_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
                x_msg_count := l_msg_count;
                x_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
             END IF;

        ELSE
        -- if status is not draft
              Fnd_Message.set_name ('AHL', 'AHL_VWP_TSK_CANNOT_DEL');
              Fnd_Msg_Pub.ADD;
              RAISE FND_API.G_EXC_ERROR;
        END IF; -- End of Job Status
        CLOSE c_workorders;

      ELSE

         CLOSE c_workorders;

      END IF; -- End of check if the job is for the task

      OPEN  c_wo_exist(c_task_rec.visit_task_id);
      FETCH c_wo_exist INTO l_workorder_present;

      IF c_wo_exist%FOUND THEN
         l_workorder_present :='Y';
      ELSE
         l_workorder_present :='N';
      END IF;
      CLOSE c_wo_exist;

            l_visit_id := c_task_rec.visit_id;
            l_task_id  := p_Visit_Task_ID;

         --To update all tasks which have the deleting task as cost or originating task
            AHL_VWP_RULES_PVT.Update_Cost_Origin_Task
                (p_visit_task_id  =>l_task_Id,
                 x_return_status  =>x_return_status
                );

                IF NVL(x_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
                   x_msg_count := l_msg_count;
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   RAISE FND_API.G_EXC_ERROR;
                END IF;

            -- To find if task deleted from a visit in the Primary Plan,
            -- then any task associated to it in a simulation visit must have the association removed.
            --OPEN c_primary (l_visit_id, l_task_id);
      IF(c_visit_rec.ASSO_PRIMARY_VISIT_ID is null) THEN
        OPEN c_primary (l_task_id);
        LOOP
          FETCH c_primary INTO c_primary_rec;
          EXIT WHEN c_primary%NOTFOUND;
          IF c_primary_rec.visit_task_id IS NOT NULL THEN
            UPDATE AHL_VISIT_TASKS_B SET PRIMARY_VISIT_TASK_ID = NULL,
            OBJECT_VERSION_NUMBER = c_primary_rec.object_version_number + 1
            WHERE --VISIT_ID = l_visit_id AND
            VISIT_TASK_ID = c_primary_rec.visit_task_id;
            IF (l_log_statement >= l_log_current_level) THEN
                fnd_log.string(l_log_statement,
                               L_DEBUG_KEY,
                               'Updated AHL_VISIT_TASKS_B for Visit Task Id =  ' || c_primary_rec.visit_task_id);
            END IF;
          END IF;
        END LOOP;
        CLOSE c_primary;
      END IF;

            -- To find if a task deleted has associated Children Tasks, tasks that define it as a parent,
            -- the association must be removed.
            OPEN c_links (l_task_id);
            FETCH c_links INTO l_count;
                IF l_count > 0 THEN
                    DELETE Ahl_Task_Links
                    WHERE VISIT_TASK_ID = l_task_id
           OR PARENT_TASK_ID = l_task_id;
                END IF;
            CLOSE c_links;

            IF (l_log_statement >= l_log_current_level) THEN
                fnd_log.string(l_log_statement,
                               L_DEBUG_KEY,
                               'Project Task Id = ' || c_task_rec.PROJECT_TASK_ID);
            END IF;

            -- When a visit's task is deleted than the related projects's task is also deleted
            IF c_task_rec.PROJECT_TASK_ID IS NOT NULL THEN

                IF (l_log_statement >= l_log_current_level) THEN
                    fnd_log.string(l_log_statement,
                                   L_DEBUG_KEY,
                                   'Before Calling AHL_VWP_PROJ_PROD_PVT.Delete_Task_to_Project');
                END IF;
                AHL_VWP_PROJ_PROD_PVT.Delete_Task_to_Project(
                     /*p_api_version    => l_api_version,
                     p_init_msg_list    => p_init_msg_list,
                     p_commit           => Fnd_Api.g_false,
                     p_validation_level => p_validation_level,
                     p_module_type      => p_module_type,*/
                     p_visit_task_id    => c_task_rec.Visit_Task_ID,
                     x_return_status    => l_return_status);
                     /*x_msg_count      => x_msg_count,
                     x_msg_data         => x_msg_data);*/

                l_msg_count := FND_MSG_PUB.count_msg;
                IF l_msg_count > 0 OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
                       x_msg_count := l_msg_count;
                       x_return_status := FND_API.G_RET_STS_ERROR;
                       RAISE FND_API.G_EXC_ERROR;
                END IF;
           END IF;

        IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Value of l_workorder_present = ' || l_workorder_present);
        END IF;

        IF l_workorder_present = 'N' THEN

                     -- Delete task translation (AHL_VISIT_TASKS_TL) table data
                        DELETE FROM Ahl_Visit_Tasks_TL
                        WHERE  Visit_Task_ID = l_task_id;

                         IF (SQL%NOTFOUND) THEN
                            IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
                                Fnd_Message.set_name ('AHL', 'AHL_API_RECORD_NOT_FOUND');
                                Fnd_Msg_Pub.ADD;
                            END IF;
                            RAISE Fnd_Api.g_exc_error;
                         END IF;

                       -- Delete task base (AHL_VISIT_TASKS_B) table data
                         DELETE FROM Ahl_Visit_Tasks_B
                         WHERE  Visit_Task_ID = l_task_id;

                         IF (SQL%NOTFOUND) THEN
                                Fnd_Message.set_name ('AHL', 'AHL_API_RECORD_NOT_FOUND');
                                Fnd_Msg_Pub.ADD;
                            RAISE Fnd_Api.g_exc_error;
                        END IF;

       ELSE
                                UPDATE AHL_VISIT_TASKS_B
                                    SET STATUS_CODE='DELETED',UNIT_EFFECTIVITY_ID=NULL,
                                        OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
                                WHERE VISIT_TASK_ID=l_task_id;

                                IF (l_log_statement >= l_log_current_level) THEN
                                    fnd_log.string(l_log_statement,
                                                   L_DEBUG_KEY,
                                                   'Updation of the status to DELETED');
                                END IF;

       END IF; -- End of l_workorder_present flag check

 ------------------------End of API Body------------------------------------
   IF Fnd_Api.to_boolean (p_commit) THEN
      COMMIT;
   END IF;

   Fnd_Msg_Pub.count_and_get (
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Delete_Unassociated_Task;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Delete_Unassociated_Task;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Unassociated_Task;
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
END Delete_Unassociated_Task;

--------------------------------------------------------------------
-- PROCEDURE
--    Delete_SR_Task
--
-- PURPOSE
-- Added for VWP Post 11.5.10 enhancements
--    To delete SR tasks for the Maintenace visit.
--------------------------------------------------------------------

PROCEDURE Delete_SR_Task (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type       IN  VARCHAR2:= 'JSP',
   p_visit_task_ID     IN  NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Delete SR Task';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   -- local variables defined for the procedure
   l_orgin_id    NUMBER;
   l_visit_id    NUMBER;
   l_mr_id       NUMBER;
   l_task_id     NUMBER;
   l_cost_id     NUMBER;
   l_est_price   NUMBER;
   l_act_price   NUMBER;
   l_count       NUMBER;
   l_msg_count   NUMBER;

    l_workorder_rec         AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_REC;
    l_workoper_tbl          AHL_PRD_WORKORDER_PVT.PRD_WORKOPER_TBL;

   l_return_status     VARCHAR2(1);
   l_workorder_present VARCHAR2(1) := 'N';
   l_planned_order_flag VARCHAR2(1);

  -- To find all tasks related information
   CURSOR c_Task (x_id IN NUMBER) IS
      SELECT *
      FROM Ahl_Visit_Tasks_VL
      WHERE Visit_Task_ID = x_id;
      c_task_rec    c_Task%ROWTYPE;

  -- To find visit related information
   CURSOR c_Visit (x_id IN NUMBER) IS
      SELECT *
      FROM  Ahl_Visits_VL
      WHERE VISIT_ID = x_id;
      c_visit_rec      c_Visit%ROWTYPE;

  -- To find any task which have primary visit task id as deleted task id
    --CURSOR c_primary (x_visit_id IN NUMBER, x_task_id IN NUMBER) IS
  CURSOR c_primary (x_task_id IN NUMBER) IS
      SELECT Visit_Task_Id, Object_Version_Number
      FROM  Ahl_Visit_Tasks_VL
      WHERE --VISIT_ID = x_visit_id AND
    PRIMARY_VISIT_TASK_ID = x_task_id
      AND   STATUS_CODE <> 'DELETED';
     c_primary_rec     c_primary%ROWTYPE;

  -- To find any task links for a deleted task
    CURSOR c_links (x_id IN NUMBER) IS
      SELECT COUNT(*) FROM Ahl_Task_Links L ,Ahl_Visit_Tasks_B T
      WHERE (T.VISIT_TASK_ID = L.VISIT_TASK_ID
      OR T.VISIT_TASK_ID = L.PARENT_TASK_ID)
      AND T.VISIT_TASK_ID = x_id;

 -- To find if WIP job is created for the Visit
    CURSOR c_workorders(x_task_id IN NUMBER) IS
      SELECT * FROM AHL_WORKORDERS
      WHERE VISIT_TASK_ID=x_task_id
      AND STATUS_CODE<>'22' AND STATUS_CODE<> '7';
       c_workrec      c_workorders%ROWTYPE;

    CURSOR c_SR_tasks(c_visit_id NUMBER, c_sr_id NUMBER)
    IS
    SELECT visit_task_id
    FROM ahl_visit_tasks_b
    WHERE visit_id = c_visit_id
    START WITH originating_task_id IS NULL
    AND SERVICE_REQUEST_ID = c_sr_id
    CONNECT BY PRIOR visit_task_id = originating_task_id
      order by visit_task_id desc;

BEGIN
  IF (l_log_procedure >= l_log_current_level) THEN
     fnd_log.string(l_log_procedure,
                    L_DEBUG_KEY ||'.begin',
                    'At the start of PL SQL procedure.');
  END IF;

  SAVEPOINT Delete_SR_Task;

        IF Fnd_Api.to_boolean (p_init_msg_list) THEN
                Fnd_Msg_Pub.initialize;
        END IF;

   --  Initialize API return status to success

        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.compatible_api_call(L_api_version,p_api_version,
         l_api_name, G_PKG_NAME)
        THEN
                RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;

   ------------------------Start of API Body------------------------------------
   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      ':Task Id' || p_visit_task_ID);
   END IF;

   -- To check if the input taskid exists in task entity.
   OPEN c_Task(p_Visit_Task_ID);
   FETCH c_Task INTO c_task_rec;

   IF c_Task%NOTFOUND THEN
      CLOSE c_Task;

      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error)
      THEN
             Fnd_Message.set_name('AHL', 'AHL_API_RECORD_NOT_FOUND');
             Fnd_Msg_Pub.ADD;
      END IF;
      RAISE Fnd_Api.g_exc_error;
   ELSE
        l_orgin_id   :=c_task_rec.ORIGINATING_TASK_ID;
        l_cost_id    :=c_task_rec.cost_parent_id;
        l_visit_id   :=c_task_rec.visit_id;
        l_mr_id      :=c_task_rec.MR_ID;
        l_act_price  :=c_task_rec.actual_price;
        l_est_price  :=c_task_rec.estimated_price;

        CLOSE c_Task;

      -- To find the visit related information
      OPEN c_Visit(c_task_rec.visit_id);
      FETCH c_Visit INTO c_visit_rec;
      CLOSE c_Visit;

      IF c_task_rec.service_request_id IS NOT NULL THEN

      OPEN c_SR_tasks(c_task_rec.visit_id,c_task_rec.service_request_id);
      LOOP
      FETCH c_SR_tasks INTO l_task_id;
      EXIT WHEN c_SR_tasks%NOTFOUND;

                    OPEN c_workorders(l_task_id);
                    FETCH c_workorders INTO c_workrec;

                    IF C_WORKORDERS%FOUND THEN
                        IF (l_log_statement >= l_log_current_level) THEN
                            fnd_log.string(l_log_statement,
                                           L_DEBUG_KEY,
                                           'Check Workorder Status = ' || c_workrec.status_code);
                        END IF;
                        IF c_workrec.status_code<>'17'
                        THEN
                             -- ADD THIS MESSAGE TO SEED115
                             Fnd_Message.set_name ('AHL', 'AHL_VWP_TSK_CANNOT_DEL');
               FND_MESSAGE.SET_TOKEN('Task_Number',c_task_rec.visit_task_number);
                             Fnd_Msg_Pub.ADD;
                             CLOSE c_workorders;
                             CLOSE c_SR_tasks;
                             RAISE fnd_Api.g_exc_error;
                             -- IF STATUS IS NOT DRAFT RAISE ERROR.
                        ELSIF c_workrec.status_code='17'
                        THEN

                            l_workorder_present :='Y';
                            l_workorder_rec.workorder_id:=c_workrec.workorder_id;
                            l_workorder_rec.visit_task_id:=l_task_id;
                            Get_WorkOrder_Attribs
                            (
                             p_x_prd_workorder_rec =>l_workorder_rec
                            );

                            l_msg_count := FND_MSG_PUB.count_msg;

                            IF l_msg_count > 0 THEN
                                CLOSE c_workorders;
                                CLOSE c_SR_tasks;
                                x_msg_count := l_msg_count;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                RAISE FND_API.G_EXC_ERROR;
                            END IF;
                            l_workorder_rec.wip_entity_id := null;
                            l_workorder_rec.STATUS_CODE:='22'; --Deleted Status Refer DLD to Verify.

                            IF (l_log_statement >= l_log_current_level) THEN
                                fnd_log.string(l_log_statement,
                                               L_DEBUG_KEY,
                                               'Before Calling AHL_PRD_WORKORDER_PVT.update_job');
                            END IF;

                            AHL_PRD_WORKORDER_PVT.update_job
                            (
                                p_api_version          =>1.0,
                                p_init_msg_list        =>fnd_api.g_false,
                                p_commit               =>fnd_api.g_false,
                                p_validation_level     =>p_validation_level,
                                p_default              =>fnd_api.g_false,
                                p_module_type          =>NULL,

                                x_return_status        =>x_return_status,
                                x_msg_count            =>x_msg_count,
                                x_msg_data             =>x_msg_data,

                                p_wip_load_flag        =>'Y',
                                p_x_prd_workorder_rec  =>l_workorder_rec,
                                p_x_prd_workoper_tbl   =>l_workoper_tbl
                            );

                            IF (l_log_statement >= l_log_current_level) THEN
                                fnd_log.string(l_log_statement,
                                               L_DEBUG_KEY,
                                               'After Calling AHL_PRD_WORKORDER_PVT.update_job, Return Status = ' || x_return_status);
                            END IF;

                                l_msg_count := FND_MSG_PUB.count_msg;
                            IF l_msg_count > 0 OR NVL(x_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
                             CLOSE c_workorders;
                             CLOSE c_SR_tasks;
                                x_msg_count := l_msg_count;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                RAISE FND_API.G_EXC_ERROR;
                            END IF;

                     END IF; -- End of If c_workrec.status_code<>'17' check

                   END IF; -- End of if c_workorders%found check

                  CLOSE c_workorders;

                IF (l_log_statement >= l_log_current_level) THEN
                    fnd_log.string(l_log_statement,
                                   L_DEBUG_KEY,
                                   ' Calling Update_Cost_Origin_Task, task id : '||l_task_ID );
                END IF;

                -- To update all tasks which have the deleting task as cost or originating task
                        AHL_VWP_RULES_PVT.Update_Cost_Origin_Task
                        (
                        p_visit_task_id    =>l_task_ID,
                        x_return_status    =>x_return_status
                        );

        IF FND_MSG_PUB.count_msg>0 or NVL(x_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
          CLOSE c_SR_tasks;
          RAISE Fnd_Api.g_exc_error;
        END IF;

        IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Check for Primary Visit');
        END IF;

        --OPEN c_primary (l_visit_id, l_task_id);
        IF(c_visit_rec.ASSO_PRIMARY_VISIT_ID is null) THEN
          OPEN c_primary (l_task_id);
          LOOP
            FETCH c_primary INTO c_primary_rec;
            EXIT WHEN c_primary%NOTFOUND;
            IF c_primary_rec.visit_task_id IS NOT NULL
            THEN
              UPDATE AHL_VISIT_TASKS_B
                SET PRIMARY_VISIT_TASK_ID = NULL,
                OBJECT_VERSION_NUMBER = c_primary_rec.object_version_number + 1
              WHERE --VISIT_ID = l_visit_id AND
              VISIT_TASK_ID = c_primary_rec.visit_task_id;
            END IF;
          END LOOP;
          CLOSE c_primary;
          END IF;

        IF c_task_rec.PROJECT_TASK_ID IS NOT NULL THEN
           IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Before Calling AHL_VWP_PROJ_PROD_PVT.Delete_Task_to_Project');
           END IF;

           AHL_VWP_PROJ_PROD_PVT.Delete_Task_to_Project(
/*           p_api_version      => l_api_version,
           p_init_msg_list    => p_init_msg_list,
           p_commit           => Fnd_Api.g_false,
           p_validation_level => p_validation_level,
           p_module_type      => p_module_type,*/
           p_visit_task_id    => l_task_id,
           x_return_status    => l_return_status);
           /*x_msg_count        => x_msg_count,
           x_msg_data         => x_msg_data);*/

           IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'After Calling AHL_VWP_PROJ_PROD_PVT.Delete_Task_to_Project, Return Status = ' || l_return_status);
           END IF;

           IF (fnd_msg_pub.count_msg > 0) OR
              NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
              CLOSE c_SR_tasks;
              RAISE Fnd_Api.g_exc_error;
           END IF;

      END IF;

          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                            'Before deleting from AHL_TASK_LINKS table');
          END IF;

          OPEN c_links (l_task_id);
          FETCH c_links INTO l_count;
          IF l_count > 0 THEN
             DELETE Ahl_Task_Links
             WHERE VISIT_TASK_ID = l_task_id
             OR PARENT_TASK_ID = l_task_id;
          END IF;
          CLOSE c_links;

          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                            'Before updating task status to DELETED');
          END IF;

          --IF NVL(l_workorder_present,'X') ='Y' THEN
          IF  c_task_rec.service_request_id IS NOT NULL THEN
          UPDATE AHL_VISIT_TASKS_B
              SET STATUS_CODE='DELETED',UNIT_EFFECTIVITY_ID=NULL,
            OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
          WHERE VISIT_TASK_ID=l_task_id;
                                ELSE
              DELETE FROM Ahl_Visit_Tasks_TL
          WHERE  Visit_Task_ID = l_task_id;

          IF (SQL%NOTFOUND) THEN
            IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error)
            THEN
              Fnd_Message.set_name ('AHL', 'AHL_API_RECORD_NOT_FOUND');
              Fnd_Msg_Pub.ADD;
            END IF;
             CLOSE c_SR_tasks;
            RAISE Fnd_Api.g_exc_error;
          END IF;

             -- Delete task base (AHL_VISIT_TASKS_B) table data

          IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            ':Delete from base task table');
          END IF;

          DELETE FROM Ahl_Visit_Tasks_B
          WHERE  Visit_Task_ID = l_task_id;

          IF (SQL%NOTFOUND) THEN
            IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error)
            THEN
              Fnd_Message.set_name ('AHL', 'AHL_API_RECORD_NOT_FOUND');
              Fnd_Msg_Pub.ADD;
            END IF;
             CLOSE c_SR_tasks;
            RAISE Fnd_Api.g_exc_error;
          END IF;
                                END IF;

                                IF NVL(c_visit_rec.actual_price,0) <> 0
                                    OR NVL(c_visit_rec.estimated_price,0) <> 0
                                THEN

                                    IF (l_log_statement >= l_log_current_level) THEN
                                        fnd_log.string(l_log_statement,
                                        L_DEBUG_KEY,
                                        'Before updating visit price by deducting task price');
                                    END IF;

                                    l_act_price:= NVL(c_visit_rec.actual_price,0)    -   NVL(l_act_price,0);
                                    l_est_price:= NVL(c_visit_rec.estimated_price,0) -   NVL(l_est_price,0);

                                    UPDATE ahl_visits_b
                                        SET actual_price=l_act_price,
                                            estimated_price=l_est_price,
                                            OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
                                    WHERE visit_id=l_visit_id;
                                END IF;

          END LOOP;  -- End of c_SR_task Loop
                CLOSE c_SR_tasks;

    END IF;  --End of if c_task_rec.service_request is not null check

  END IF;  -- Task Null Check

  IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status);
  END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Delete_SR_Task;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Delete_SR_Task;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_SR_Task;
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
END Delete_SR_Task;

--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Summary_Task
--
-- PURPOSE
--    To delete Summary tasks for the Maintenace visit.
--------------------------------------------------------------------
PROCEDURE Delete_Summary_Task (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type       IN  VARCHAR2:= 'JSP',
   p_visit_task_ID     IN  NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
)
IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Delete Summary Task';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   -- local variables defined for the procedure
   l_origin_id   NUMBER;
   l_visit_id    NUMBER;
   l_mr_id       NUMBER;
   l_task_id     NUMBER;
   l_cost_id     NUMBER;
   l_est_price   NUMBER;
   l_act_price   NUMBER;
   l_count       NUMBER;
   l_msg_count   NUMBER;
   l_dummy       VARCHAR2(1);

   l_workorder_rec         AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_REC;
   l_workoper_tbl          AHL_PRD_WORKORDER_PVT.PRD_WORKOPER_TBL;

   l_return_status       VARCHAR2(1);
   l_workorder_present   VARCHAR2(1) := 'N';
   l_planned_order_flag  VARCHAR2(1);
   l_task_type       VARCHAR2(80);
   l_unit_effectivity_id NUMBER;

  -- To find all tasks related information
   CURSOR c_Task (x_id IN NUMBER) IS
      SELECT *
      FROM Ahl_Visit_Tasks_VL
      WHERE Visit_Task_ID = x_id;
      c_task_rec    c_Task%ROWTYPE;
    l_task_rec    c_Task%ROWTYPE;
  -- To find visit related information
   CURSOR c_Visit (x_id IN NUMBER) IS
      SELECT *
      FROM  Ahl_Visits_VL
      WHERE VISIT_ID = x_id;
      c_visit_rec      c_Visit%ROWTYPE;

  -- To find any task which have primary visit task id as deleted task id
    --CURSOR c_primary (x_visit_id IN NUMBER, x_task_id IN NUMBER) IS
  CURSOR c_primary (x_task_id IN NUMBER) IS
      SELECT Visit_Task_Id, Object_Version_Number
      FROM  Ahl_Visit_Tasks_VL
      WHERE --VISIT_ID = x_visit_id AND
    PRIMARY_VISIT_TASK_ID = x_task_id
      AND STATUS_CODE <> 'DELETED';
     c_primary_rec     c_primary%ROWTYPE;

  -- To find any task links for a deleted task
    CURSOR c_links (x_id IN NUMBER) IS
      SELECT COUNT(*) FROM Ahl_Task_Links L ,Ahl_Visit_Tasks_B T
      WHERE (T.VISIT_TASK_ID = L.VISIT_TASK_ID
      OR T.VISIT_TASK_ID = L.PARENT_TASK_ID)
      AND T.VISIT_TASK_ID = x_id;

 -- To find if WIP job is created for the Visit
    CURSOR c_workorders(x_task_id IN NUMBER) IS
      SELECT * FROM AHL_WORKORDERS
      WHERE VISIT_TASK_ID=x_task_id
      AND STATUS_CODE <> '22' AND STATUS_CODE <> '7';
       c_workrec      c_workorders%ROWTYPE;

    -- yazhou 11Nov2005 starts
    -- Bug fix#4508169

    --Dup-MR ER#6338208 - sowsubra
    CURSOR c_all_tasks(c_visit_id NUMBER, c_task_id NUMBER) IS
    SELECT visit_task_id
    FROM ahl_visit_tasks_b
    WHERE visit_id = c_visit_id
    AND  STATUS_CODE <> 'DELETED'
    START WITH visit_task_id = c_task_id
    CONNECT BY PRIOR visit_task_id = originating_task_id
    order by visit_task_id desc;

    -- yazhou 11Nov2005 ends

--Added by mpothuku on 02/03/05
--To check if the unplanned tasks UE is associated with any other visits other than itself before its deletion.
  CURSOR check_unplanned_ue_assoc(c_ue_id IN NUMBER) IS
  SELECT 'X' from ahl_visit_tasks_b where unit_effectivity_id = c_ue_id and
      status_code <> 'DELETED';
BEGIN
  IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure.');
  END IF;

   --------------------- initialize -----------------------
   SAVEPOINT Delete_Summary_Task;
   -- Check if API is called in debug mode. If yes, enable debug.

    IF Fnd_Api.to_boolean (p_init_msg_list) THEN
                Fnd_Msg_Pub.initialize;
        END IF;

   --  Initialize API return status to success

        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.compatible_api_call(L_api_version,p_api_version,
         l_api_name, G_PKG_NAME)
        THEN
                RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;

   ------------------------Start of API Body------------------------------------

   IF (l_log_statement >= l_log_current_level)THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      ':Task Id' || p_visit_task_ID);
   END IF;

   -- To check if the input taskid exists in task entity.
   OPEN c_Task(p_Visit_Task_Id);
   FETCH c_Task INTO c_task_rec;

   IF c_Task%NOTFOUND THEN
      CLOSE c_Task;

      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error)
      THEN
             Fnd_Message.set_name('AHL', 'AHL_API_RECORD_NOT_FOUND');
             Fnd_Msg_Pub.ADD;
      END IF;
      RAISE Fnd_Api.g_exc_error;

    END IF; -- End of if c_task%notfound then check
    CLOSE c_Task;

        l_origin_id   :=c_task_rec.ORIGINATING_TASK_ID;
        l_cost_id    :=c_task_rec.cost_parent_id;
        l_visit_id   :=c_task_rec.visit_id;
        l_mr_id      :=c_task_rec.MR_ID;
        l_act_price  :=c_task_rec.actual_price;
        l_est_price  :=c_task_rec.estimated_price;
        l_task_id    := p_Visit_Task_Id;

   IF (l_log_statement >= l_log_current_level)THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      ':Visit Id' || l_visit_id);
   END IF;

   IF l_origin_id is not null THEN
         IF (l_log_statement >= l_log_current_level)THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Before Calling Delete_Summary_Task' );
         END IF;
         Delete_Summary_Task(
                p_api_version          =>p_api_version,
                p_init_msg_list        =>Fnd_Api.g_false,
                p_commit               =>Fnd_Api.g_false,
                p_validation_level     =>Fnd_Api.g_valid_level_full,
                p_module_type          =>NULL,
                p_Visit_Task_Id        =>l_origin_id,
                x_return_status        =>x_return_status,
                x_msg_count            =>x_msg_count,
                x_msg_data             =>x_msg_data);

         IF (l_log_statement >= l_log_current_level)THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'After Calling Delete_Summary_Task, Return Status = ' || x_return_status);
         END IF;

                IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
                  RAISE Fnd_Api.G_EXC_ERROR;
                END IF;
   Else
      -- To find the visit related information
      OPEN c_Visit(c_task_rec.visit_id);
      FETCH c_Visit INTO c_visit_rec;
      CLOSE c_Visit;

      IF  (c_visit_rec.status_code <> 'PLANNING' and c_visit_rec.status_code <> 'PARTIALLY RELEASED')
      THEN
            Fnd_Message.set_name ('AHL', 'AHL_VWP_PLANNING_OPER');
            Fnd_Msg_Pub.ADD;
            RAISE fnd_Api.g_exc_error;
      END IF;

    l_unit_effectivity_id := null;
    l_task_type := null;

      IF c_task_rec.mr_id IS NOT NULL THEN

        -- yazhou 11Nov2005 starts
        -- Bug fix#4508169
        --Dup-MR ER#6338208 - sowsubra
        /*The cursor was fetching all the tasks, which had the same mr id. With this enhacement since
        we have multiple MR's associated to the same visit where each of it may either be already
        pushed to production or still needs to be pushed.  Since the cursor returns all the tasks
        regardless whether or not they have been pushed to production, the cursor leads in throwing an
        error to the user not allowing them to delete the second occurrence of the MR which is not been
        pushed to production. Hence modified the cursor to take visit_id and the MR task_id that is
        being deleted.*/

        OPEN c_all_tasks(c_task_rec.visit_id,p_visit_task_ID);
        -- yazhou 11Nov2005 ends
        LOOP
          FETCH c_all_tasks INTO l_task_id;
          EXIT WHEN c_all_tasks%NOTFOUND;

          OPEN c_workorders(l_task_id);
          FETCH c_workorders INTO c_workrec;

          IF c_workorders%found THEN

            IF (l_log_statement >= l_log_current_level)THEN
                fnd_log.string(l_log_statement,
                               L_DEBUG_KEY,
                               'Check Workorder Status = ' || c_workrec.status_code);
            END IF;

            IF c_workrec.status_code<>'17'
            THEN
               -- ADD THIS MESSAGE TO SEED115
               Fnd_Message.set_name ('AHL', 'AHL_VWP_TSK_CANNOT_DEL');
               FND_MESSAGE.SET_TOKEN('Task_Number',c_task_rec.visit_task_number);
               Fnd_Msg_Pub.ADD;
               CLOSE c_workorders;
               CLOSE c_all_tasks;
               RAISE fnd_Api.g_exc_error;
            -- IF STATUS IS NOT DRAFT RAISE ERROR.
            ELSIF c_workrec.status_code='17' THEN
                l_workorder_present :='Y';
                l_workorder_rec.workorder_id:=c_workrec.workorder_id;
                l_workorder_rec.visit_task_id:=l_task_id;
                Get_WorkOrder_Attribs
                (
                 p_x_prd_workorder_rec =>l_workorder_rec
                );

                l_msg_count := FND_MSG_PUB.count_msg;

                IF l_msg_count > 0 THEN
                  x_msg_count := l_msg_count;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  CLOSE c_workorders;
                  CLOSE c_all_tasks;
                  RAISE FND_API.G_EXC_ERROR;
                END IF;

                l_workorder_rec.wip_entity_id := null;
                l_workorder_rec.STATUS_CODE:='22'; --Deleted Status Refer DLD to Verify.

                IF (l_log_statement >= l_log_current_level)THEN
                    fnd_log.string(l_log_statement,
                                   L_DEBUG_KEY,
                                   'Before Calling AHL_PRD_WORKORDER_PVT.update_job ');
                END IF;

                AHL_PRD_WORKORDER_PVT.update_job
                (
                p_api_version         =>1.0,
                p_init_msg_list       =>fnd_api.g_false,
                p_commit              =>fnd_api.g_false,
                p_validation_level    =>p_validation_level,
                p_default             =>fnd_api.g_false,
                p_module_type         =>NULL,
                x_return_status       =>x_return_status,
                x_msg_count           =>x_msg_count,
                x_msg_data            =>x_msg_data,
                p_wip_load_flag       =>'Y',
                p_x_prd_workorder_rec =>l_workorder_rec,
                p_x_prd_workoper_tbl  =>l_workoper_tbl
                );

                IF (l_log_statement >= l_log_current_level)THEN
                    fnd_log.string(l_log_statement,
                                   L_DEBUG_KEY,
                                   'After Calling AHL_PRD_WORKORDER_PVT.update_job, Return Status =  ' || x_return_status );
                END IF;

            l_msg_count := FND_MSG_PUB.count_msg;
            IF l_msg_count > 0 OR NVL(x_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
              x_msg_count := l_msg_count;
              x_return_status := FND_API.G_RET_STS_ERROR;
              CLOSE c_workorders;
              CLOSE c_all_tasks;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF; -- End of If c_workrec.status_code<>'17' check
      END IF; -- End of if c_workorders%found check
      CLOSE c_workorders;

      IF (l_log_statement >= l_log_current_level)THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         ' Calling AHL_VWP_RULES_PVT.Update_Cost_Origin_Task');
      END IF;

      -- To update all tasks which have the deleting task as cost or originating task
      AHL_VWP_RULES_PVT.Update_Cost_Origin_Task
      (
      p_visit_task_id    =>l_task_ID,
      x_return_status    =>x_return_status
      );

      IF NVL(x_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        CLOSE c_all_tasks;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_log_statement >= l_log_current_level)THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'Check for Primary Visit');
      END IF;

      /* mpothuku changed on 02/08/05 */
      --OPEN c_primary (l_visit_id, l_task_id);
      IF(c_visit_rec.ASSO_PRIMARY_VISIT_ID is null) THEN
        OPEN c_primary (l_task_id);
        LOOP
          FETCH c_primary INTO c_primary_rec;
          EXIT WHEN c_primary%NOTFOUND;
          IF c_primary_rec.visit_task_id IS NOT NULL
          THEN
            UPDATE AHL_VISIT_TASKS_B
              SET PRIMARY_VISIT_TASK_ID = NULL,
              OBJECT_VERSION_NUMBER = c_primary_rec.object_version_number + 1
            WHERE --VISIT_ID = l_visit_id
            VISIT_TASK_ID = c_primary_rec.visit_task_id;
          END IF;
        END LOOP;
        CLOSE c_primary;
      END IF;

      IF c_task_rec.PROJECT_TASK_ID IS NOT NULL THEN

           IF (l_log_statement >= l_log_current_level)THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                             ' Calling AHL_VWP_PROJ_PROD_PVT.Delete_Task_to_Project API');
           END IF;

           AHL_VWP_PROJ_PROD_PVT.Delete_Task_to_Project(
           /* p_api_version      => l_api_version,
              p_init_msg_list    => p_init_msg_list,
              p_commit           => Fnd_Api.g_false,
              p_validation_level => p_validation_level,
              p_module_type      => p_module_type,*/
              p_visit_task_id    => l_task_id,
              x_return_status    => l_return_status);
           /* x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);*/

        IF (fnd_msg_pub.count_msg > 0) OR NVL(x_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          CLOSE c_all_tasks;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF;

        IF (l_log_statement >= l_log_current_level)THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Before deleting from AHL_TASK_LINKS table');
        END IF;

        OPEN c_links (l_task_id);
        FETCH c_links INTO l_count;
        IF l_count > 0 THEN
            DELETE Ahl_Task_Links
            WHERE VISIT_TASK_ID = l_task_id
            OR PARENT_TASK_ID = l_task_id;
        END IF;
        CLOSE c_links;

        IF (l_log_statement >= l_log_current_level)THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Before updating task status to DELETED');
        END IF;

        --IF NVL(l_workorder_present,'X') ='Y' THEN
        IF c_task_rec.mr_id IS NOT NULL OR c_task_rec.service_request_id IS NOT NULL THEN
          /* Change by mpothuku on 02/03/05 to delete the unit effectivities for Unplanned tasks after removing the association */
          IF (l_task_type IS NULL) THEN
            OPEN c_task(l_task_id);
            FETCH c_task INTO l_task_rec;
            CLOSE c_task;
            IF(l_task_rec.TASK_TYPE_CODE <> 'SUMMARY') THEN
            /*  Find out if the UE is associated with any other Active Visits
              Ideally if any are found they should be Simulation Visits only */
                l_task_type := l_task_rec.TASK_TYPE_CODE;
                l_unit_effectivity_id := l_task_rec.UNIT_EFFECTIVITY_ID;
            END IF;
          END IF;
          UPDATE AHL_VISIT_TASKS_B
            SET STATUS_CODE='DELETED',UNIT_EFFECTIVITY_ID=NULL,
            OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
          WHERE VISIT_TASK_ID=l_task_id;
        ELSE

          IF (l_log_statement >= l_log_current_level)THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                            'Before DELETE');
          END IF;
          DELETE FROM Ahl_Visit_Tasks_TL WHERE  Visit_Task_ID = l_task_id;
          IF (SQL%NOTFOUND) THEN
            IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error)
            THEN
              Fnd_Message.set_name ('AHL', 'AHL_API_RECORD_NOT_FOUND');
              Fnd_Msg_Pub.ADD;
            END IF;
            CLOSE c_all_tasks;
            RAISE Fnd_Api.g_exc_error;
          END IF;

           -- Delete task base (AHL_VISIT_TASKS_B) table data
          IF (l_log_statement >= l_log_current_level)THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            ':Delete from base task table');
          END IF;

          DELETE FROM Ahl_Visit_Tasks_B
          WHERE  Visit_Task_ID = l_task_id;

          IF (SQL%NOTFOUND) THEN
            IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error)
            THEN
              Fnd_Message.set_name ('AHL', 'AHL_API_RECORD_NOT_FOUND');
              Fnd_Msg_Pub.ADD;
            END IF;
            CLOSE c_all_tasks;
            RAISE Fnd_Api.g_exc_error;
          END IF;
        END IF;

        IF NVL(c_visit_rec.actual_price,0) <> 0
          OR NVL(c_visit_rec.estimated_price,0) <> 0
        THEN

          IF (l_log_statement >= l_log_current_level)THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Before updating visit price by deducting task price');
          END IF;

          l_act_price:= NVL(c_visit_rec.actual_price,0)    -   NVL(l_act_price,0);
          l_est_price:= NVL(c_visit_rec.estimated_price,0) -   NVL(l_est_price,0);

          UPDATE ahl_visits_b
            SET actual_price=l_act_price,
              estimated_price=l_est_price,
              OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
          WHERE visit_id=l_visit_id;
        END IF;

        END LOOP;  -- End of c_all_task Loop
        CLOSE c_all_tasks;

    --Added by mpothuku on 02/07/05. After the collection of the UE, delete it.
    IF(l_task_type = 'UNPLANNED') THEN
      OPEN check_unplanned_ue_assoc(l_unit_effectivity_id);
      FETCH check_unplanned_ue_assoc INTO l_dummy;
      IF (check_unplanned_ue_assoc%NOTFOUND) THEN
        CLOSE check_unplanned_ue_assoc;

        IF (l_log_statement >= l_log_current_level)THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Before DELETE_UNIT_EFFECTIVITY');
        END IF;

        AHL_UMP_UNPLANNED_PVT.DELETE_UNIT_EFFECTIVITY
        (
          P_API_VERSION         => p_api_version,
          p_init_msg_list       => FND_API.G_FALSE,
          p_commit              => FND_API.G_FALSE,

          X_RETURN_STATUS       => l_return_status,
          X_MSG_COUNT           => l_msg_count,
          X_MSG_DATA            => x_msg_data,
          P_UNIT_EFFECTIVITY_ID => l_unit_effectivity_id
        );
        IF (l_log_statement >= l_log_current_level)THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'After DELETE_UNIT_EFFECTIVITY');
        END IF;
        IF (l_msg_count > 0) OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
        CLOSE check_unplanned_ue_assoc;
      END IF;
    END IF;
       ----------TO DELETE SR TASKS-------

       ELSIF c_task_rec.mr_id IS NULL AND c_task_rec.unit_effectivity_id is not null
       THEN
            IF (l_log_statement >= l_log_current_level)THEN
                   fnd_log.string(l_log_statement,
                                  L_DEBUG_KEY,
                                  'Before Delete_SR_Task');
            END IF;
            Delete_SR_Task(
                   p_api_version       => p_api_version,
                   p_init_msg_list     => p_init_msg_list,
                   p_commit            => Fnd_Api.g_false,
                   p_validation_level  => p_validation_level,
                   p_module_type       => p_module_type,
                   p_visit_task_ID     => p_visit_task_ID,
                   x_return_status     => x_return_status,
                   x_msg_count         => x_msg_count,
                   x_msg_data          => x_msg_data
                );
           IF (l_log_statement >= l_log_current_level)THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'After Delete_SR_Task');
           END IF;
           IF (fnd_msg_pub.count_msg > 0 ) THEN

                             IF (l_log_statement >= l_log_current_level)THEN
                                 fnd_log.string(l_log_statement,
                                 L_DEBUG_KEY,
                                 'Error raised in  Delete_SR_Task');
                             END IF;
                             RAISE Fnd_Api.G_EXC_ERROR;
           END IF;

      ----------TO DELETE MANUALLY CREATED SUMMARY TASKS-------
      ELSIF L_MR_ID IS NULL
      THEN

         l_visit_id := c_task_rec.visit_id;
         l_task_id  := p_Visit_Task_Id;

         IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Before AHL_VWP_RULES_PVT.Update_Cost_Origin_Task Call');
         END IF;

         -- To update all tasks which have the deleting task as cost or originating task
         AHL_VWP_RULES_PVT.Update_Cost_Origin_Task
         (
         p_visit_task_id    =>l_task_ID,
         x_return_status    =>x_return_status
         );

         IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Check for primary Visit');
         END IF;
         --OPEN c_primary (l_visit_id, l_task_id);
         IF (c_visit_rec.ASSO_PRIMARY_VISIT_ID is null) THEN
            OPEN c_primary (l_task_id);
            LOOP
            FETCH c_primary INTO c_primary_rec;
            EXIT WHEN c_primary%NOTFOUND;
            IF c_primary_rec.visit_task_id IS NOT NULL THEN
               UPDATE AHL_VISIT_TASKS_B
               SET PRIMARY_VISIT_TASK_ID = NULL,
                   OBJECT_VERSION_NUMBER = c_primary_rec.object_version_number + 1
               WHERE --VISIT_ID = l_visit_id AND
               VISIT_TASK_ID = c_primary_rec.visit_task_id;
            END IF;
            END LOOP;
            CLOSE c_primary;
         END IF;
         IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Before deletion from Ahl_Task_Links table');
         END IF;
         OPEN c_links (l_task_id);
         FETCH c_links INTO l_count;
              IF l_count > 0 THEN
                      DELETE Ahl_Task_Links
                      WHERE VISIT_TASK_ID = l_task_id
                      OR PARENT_TASK_ID = l_task_id;
              END IF;
         CLOSE c_links;

         IF c_task_rec.PROJECT_TASK_ID IS NOT NULL
         THEN
            IF (l_log_statement >= l_log_current_level) THEN
                fnd_log.string(l_log_statement,
                               L_DEBUG_KEY,
                               ' Calling AHL_VWP_PROJ_PROD_PVT.Delete_Task_to_Project');
            END IF;
            AHL_VWP_PROJ_PROD_PVT.Delete_Task_to_Project
            (
             /* p_api_version      => l_api_version,
                p_init_msg_list    => p_init_msg_list,
                p_commit           => Fnd_Api.g_false,
                p_validation_level => p_validation_level,
                p_module_type      => p_module_type,*/
                p_visit_task_id    => l_task_id,
                x_return_status    => l_return_status);
             /* x_msg_count        => x_msg_count,
                x_msg_data         => x_msg_data);*/

            IF l_return_status <> Fnd_Api.g_ret_sts_success THEN
               x_return_status := Fnd_Api.g_ret_sts_error;
               RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- Update Task status to 'DELETED'
            UPDATE AHL_VISIT_TASKS_B
            SET STATUS_CODE='DELETED',UNIT_EFFECTIVITY_ID=NULL,
                OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
            WHERE VISIT_TASK_ID=l_task_id;
         ELSE

            DELETE FROM Ahl_Visit_Tasks_TL
            WHERE  Visit_Task_ID = l_task_id;

            IF (SQL%NOTFOUND) THEN
               Fnd_Message.set_name ('AHL', 'AHL_API_RECORD_NOT_FOUND');
               Fnd_Msg_Pub.ADD;
               RAISE Fnd_Api.g_exc_error;
            END IF;

            -- Delete task base (AHL_VISIT_TASKS_B) table data
            IF (l_log_statement >= l_log_current_level) THEN
                fnd_log.string(l_log_statement,
                               L_DEBUG_KEY,
                               ':Delete from base task table');
            END IF;

            DELETE FROM Ahl_Visit_Tasks_B
            WHERE  Visit_Task_ID = l_task_id;

            IF (SQL%NOTFOUND) THEN
               Fnd_Message.set_name ('AHL', 'AHL_API_RECORD_NOT_FOUND');
               Fnd_Msg_Pub.ADD;
               RAISE Fnd_Api.g_exc_error;
            END IF;

            END IF;

            -- Removed call to AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials
            -- for mannually created summary task.

       END IF;  --End of if c_task_rec.mr_id is not null check
   END IF; --l_origin_id is null check

------------------------End of API Body------------------------------------
   IF Fnd_Api.to_boolean (p_commit) THEN
      COMMIT;
   END IF;

   Fnd_Msg_Pub.count_and_get (
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Delete_Summary_Task;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Delete_Summary_Task;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Summary_Task;
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
END Delete_Summary_Task;

--------------------------------------------------------------------
-- PROCEDURE
--    Search_Task
--
--------------------------------------------------------------------
PROCEDURE Search_Task (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2  := 'JSP',
   p_visit_id             IN  NUMBER,

   p_x_srch_task_tbl      IN OUT NOCOPY Srch_Task_Tbl_Type,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
  )
IS

   L_API_VERSION          CONSTANT NUMBER := 1.0;
   L_API_NAME             CONSTANT VARCHAR2(30) := 'Search_Task';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   -- Local variables defined for the procedure
   l_tasks_tbl            Srch_Task_Tbl_Type := p_x_srch_task_tbl;
   l_task_type_code       VARCHAR2(80);
   l_msg_count            NUMBER;
   l_count                NUMBER;
   x                      NUMBER:=0;
   z                      NUMBER:=0;

-- To find the task's related visit information
   CURSOR c_visit (x_id IN NUMBER) IS
    SELECT * FROM AHL_VISITS_VL
    WHERE VISIT_ID = x_id;
    c_visit_rec c_visit%ROWTYPE;

  -- To find task type code, start, end time of a task
  --POST 11.5.10 cxcheng change --------------
   CURSOR get_task_times_csr (p_task_id IN NUMBER) IS
    SELECT task_type_code, start_date_time, end_date_time
    FROM AHL_VISIT_TASKS_B
    WHERE VISIT_TASK_ID = p_task_id;

BEGIN
    --------------------- initialize -----------------------
   SAVEPOINT Search_Task;

   IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.begin',
                      'At the start of PL SQL procedure.');
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_boolean(p_init_msg_list)
   THEN
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
  ---------------------------Start of Body-------------------------------------
    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                       ': Visit Id ' || p_visit_id);
    END IF;
    OPEN c_visit (p_visit_id);
    FETCH c_visit INTO c_visit_rec;
    CLOSE c_visit;

    IF (c_visit_rec.START_DATE_TIME IS NOT NULL
        AND c_visit_rec.START_DATE_TIME <> Fnd_Api.G_MISS_DATE
        AND c_visit_rec.DEPARTMENT_ID IS NOT NULL
        AND c_visit_rec.DEPARTMENT_ID <> FND_API.G_MISS_NUM) THEN

        IF l_tasks_tbl.COUNT > 0 THEN
           x := l_tasks_tbl.FIRST;
           LOOP
              OPEN get_task_times_csr(l_tasks_tbl(x).TASK_ID);
              FETCH get_task_times_csr INTO l_task_type_code,
                                 l_tasks_tbl(x).TASK_START_TIME,
                                 l_tasks_tbl(x).TASK_END_TIME  ;
              CLOSE get_task_times_csr;

              EXIT WHEN x = l_tasks_tbl.LAST ;
              x := l_tasks_tbl.NEXT(x);
           END LOOP;
        END IF;
        p_x_srch_task_tbl := l_tasks_tbl;
     ELSE
        IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           ': Either Visit Start End Time Missing' || c_visit_rec.START_DATE_TIME ||
                           ': Or Visit Department Missing' || c_visit_rec.DEPARTMENT_ID ||
                           ': Or Department Shift for a Dept Missing' || l_count);
        END IF;
        IF l_tasks_tbl.COUNT > 0 THEN
                z := l_tasks_tbl.FIRST;
                LOOP
                  l_tasks_tbl(z).TASK_START_TIME := NULL;
                  l_tasks_tbl(z).TASK_END_TIME   := NULL;
                  EXIT WHEN z = l_tasks_tbl.LAST ;
                  z :=l_tasks_tbl.NEXT(z);
                END LOOP;
        END IF;
        p_x_srch_task_tbl := l_tasks_tbl;
     END IF;

     IF l_tasks_tbl.COUNT > 0 THEN
        X := l_tasks_tbl.FIRST;
        LOOP
           IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'Value of Task Id : ' || l_tasks_tbl(X).Task_Id ||
                              'Value of Start Date : ' || TO_CHAR(l_tasks_tbl(X).TASK_START_TIME, 'MM/DD/YY HH24:MI:SS') ||
                              'Value of End Date : ' || TO_CHAR(l_tasks_tbl(X).TASK_END_TIME, 'MM/DD/YY HH24:MI:SS'));
           END IF;

           EXIT WHEN X = l_tasks_tbl.LAST ;
           X := l_tasks_tbl.NEXT(X);
        END LOOP;
     END IF;

---------------------------End of Body---------------------------------------
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

  --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Search_Task;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get(
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Search_Task;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Search_Task;
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
END Search_Task;

--------------------------------------------------------------------
-- PROCEDURE
--   Validate_Visit_Task
--
-- PURPOSE
--
--------------------------------------------------------------------
PROCEDURE Validate_Visit_Task (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_task_rec          IN  AHL_VWP_RULES_PVT.Task_Rec_Type,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
)
IS
   L_API_VERSION       CONSTANT NUMBER := 1.0;
   L_API_NAME          CONSTANT VARCHAR2(30) := 'Validate_Visit_Task';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   l_return_status     VARCHAR2(1);
BEGIN
   --------------------- initialize -----------------------

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure.');
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

   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      ':Check items1');
   END IF;

   IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_item THEN
      Check_Task_Items (
         p_task_rec           => p_task_rec,
         p_validation_mode    => Jtf_Plsql_Api.g_create,
         x_return_status      => l_return_status
      );
      IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;
   END IF;

   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      ':Check items2');
   END IF;

 -------------------- finish --------------------------
  -- Standard call to get message count and if count is 1, get message info
   Fnd_Msg_Pub.count_and_get (
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || l_return_status);
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
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
    THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Validate_Visit_Task;

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
   L_API_NAME  CONSTANT VARCHAR2(30) := 'Check_Task_Items';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
BEGIN
   --
   IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.begin',
                      'At the start of PL SQL procedure.');
   END IF;
   x_return_status := Fnd_Api.g_ret_sts_success;
   -- Validate required items.

   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'Check_Task_Items:Before Check_Visit_Task_Req_Items');
   END IF;

   Check_Visit_Task_Req_Items (
      p_task_rec        => p_task_rec,
      /* Added by rnahata for Issue 105 - serial number validation should be performed only at
      the time of creation of tasks as once created serial number cannot be edited.*/
      p_validation_mode => p_validation_mode,
      x_return_status   => x_return_status
   );
   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;

   --
   -- Validate uniqueness.

   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'Check_Task_Items:Before Check_Visit_Task_UK_Items');
   END IF;
   Check_Visit_Task_UK_Items (
      p_task_rec => p_task_rec,
      p_validation_mode    => p_validation_mode,
      x_return_status      => x_return_status
   );

   IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.begin',
                      'At the end of PL SQL procedure. Return Status ' ||x_return_status);
   END IF;

END Check_Task_Items;

---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Visit_Task_Rec
--
-- PURPOSE
--
---------------------------------------------------------------------
/*
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
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name('AHL', 'AHL_API_RECORD_NOT_FOUND');
         Fnd_Msg_Pub.ADD;
      END IF;
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
   p_task_rec        IN         AHL_VWP_RULES_PVT.Task_Rec_Type,
   -- Added by rnahata for Issue 105 - validation mode parameter
   p_validation_mode IN         VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   L_API_NAME  CONSTANT VARCHAR2(30) := 'Check_Visit_Task_Req_Items';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

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
BEGIN

  IF (l_log_procedure >= l_log_current_level) THEN
     fnd_log.string(l_log_procedure,
                    L_DEBUG_KEY ||'.begin',
                    'At the start of PL SQL procedure.');
  END IF;

  x_return_status := Fnd_Api.g_ret_sts_success;

  -- TASK NAME ==== NAME
  IF (p_task_rec.VISIT_TASK_NAME IS NULL OR p_Task_rec.VISIT_TASK_NAME = Fnd_Api.G_MISS_CHAR) THEN
     Fnd_Message.set_name ('AHL', 'AHL_VWP_NAME_MISSING');
     Fnd_Msg_Pub.ADD;
     x_return_status := Fnd_Api.g_ret_sts_error;
  END IF;

   IF UPPER(p_task_rec.TASK_TYPE_CODE) = 'UNASSOCIATED' THEN

      -- ITEM ==== INVENTORY_ITEM_ID
      IF (p_Task_rec.item_name IS NULL OR p_Task_rec.item_name = Fnd_Api.G_MISS_CHAR ) THEN
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
             Fnd_Message.set_name ('AHL', 'AHL_VWP_ITEM_MISSING');
             Fnd_Msg_Pub.ADD;
          END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;

      -- TASK DURATION ==== DURATION
      IF (p_task_rec.DURATION IS NULL OR p_Task_rec.DURATION = Fnd_Api.G_MISS_NUM) THEN
        Fnd_Message.set_name ('AHL', 'AHL_VWP_DURATION_MISSING');
        Fnd_Msg_Pub.ADD;
        x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;

      IF (p_task_rec.DURATION IS NOT NULL AND p_Task_rec.DURATION <> Fnd_Api.G_MISS_NUM) THEN
        IF p_task_rec.DURATION < 0 OR FLOOR(p_task_rec.DURATION) <> p_task_rec.DURATION THEN
          Fnd_Message.set_name ('AHL', 'AHL_VWP_ONLY_POSITIVE_VALUE');
          Fnd_Msg_Pub.ADD;
          x_return_status := Fnd_Api.g_ret_sts_error;
        END IF;
      END IF;

      IF ( p_validation_mode = Jtf_Plsql_Api.g_create ) THEN
         -- Begin changes by rnahata for Issue 105
         -- Check if the serial number is present only for serialised instances.
         OPEN c_check_inst_nonserial (p_task_rec.instance_id);
         FETCH c_check_inst_nonserial INTO l_serial_ctrl;
         IF c_check_inst_nonserial%NOTFOUND THEN
            IF (p_Task_rec.SERIAL_NUMBER IS NULL OR p_Task_rec.SERIAL_NUMBER = Fnd_Api.G_MISS_CHAR) THEN
               Fnd_Message.set_name ('AHL', 'AHL_VWP_SERIAL_MISSING');
               Fnd_Msg_Pub.ADD;
               x_return_status := Fnd_Api.g_ret_sts_error;
            END IF;
         ELSE
            IF (p_Task_rec.SERIAL_NUMBER IS NOT NULL) THEN
               Fnd_Message.set_name ('AHL', 'AHL_VWP_SERIAL_NOT_NEEDED');
               Fnd_Msg_Pub.ADD;
               x_return_status := Fnd_Api.g_ret_sts_error;
            END IF;
         END IF;
         CLOSE c_check_inst_nonserial;
         -- End changes by rnahata for Issue 105
      END IF;

   END IF;

   IF (p_task_rec.START_FROM_HOUR IS NOT NULL AND p_Task_rec.START_FROM_HOUR <> Fnd_Api.G_MISS_NUM) THEN
      IF p_task_rec.START_FROM_HOUR < 0 OR FLOOR(p_task_rec.START_FROM_HOUR) <> p_task_rec.START_FROM_HOUR THEN
             Fnd_Message.set_name ('AHL', 'AHL_VWP_ONLY_POSITIVE_VALUE');
             Fnd_Msg_Pub.ADD;
             x_return_status := Fnd_Api.g_ret_sts_error;
         END IF;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || x_return_status);
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
   L_API_NAME  CONSTANT VARCHAR2(30) := 'Check_Visit_Task_UK_Items';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
BEGIN
   x_return_status := Fnd_Api.g_ret_sts_success;

  IF (l_log_procedure >= l_log_current_level) THEN
     fnd_log.string(l_log_procedure,
                    L_DEBUG_KEY ||'.begin',
                    'At the start of PL SQL procedure.');
  END IF;
  --
  -- For Task, when ID is passed in, we need to
  -- check if this ID is unique.

  IF p_validation_mode = Jtf_Plsql_Api.g_create
     AND p_task_rec.Visit_Task_ID IS NOT NULL
  THEN

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        ': = Check_Visit_Task_UK_Items Uniqueness Of ID');
     END IF;

     -- FOR CREATION
     IF Ahl_Utility_Pvt.check_uniqueness(
         'Ahl_Visit_Tasks_vl',
       'Visit_Task_ID = ' || p_task_rec.Visit_Task_ID
     ) = Fnd_Api.g_false
     THEN
        IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
           Fnd_Message.set_name ('AHL', 'AHL_VWP_DUPLICATE_TASK_ID');
           Fnd_Msg_Pub.ADD;
        END IF;
        x_return_status := Fnd_Api.g_ret_sts_error;
        RETURN;
     END IF;
  END IF;

  IF (l_log_procedure >= l_log_current_level) THEN
     fnd_log.string(l_log_procedure,
                    L_DEBUG_KEY ||'.end',
                    'At the end of PL SQL procedure. Return Status = ' || x_return_status);
  END IF;
END Check_Visit_Task_UK_Items;

--------------------------------------------------------------------
-- PROCEDURE
--    Create_PUP_Tasks
-- PURPOSE
--    To create all types of tasks i.e Unassociated/Summary/Unplanned/Planned
--------------------------------------------------------------------
PROCEDURE Create_PUP_Tasks (
   p_api_version      IN            NUMBER,
   p_init_msg_list    IN            VARCHAR2  := Fnd_Api.g_false,
   p_commit           IN            VARCHAR2  := Fnd_Api.g_false,
   p_validation_level IN            NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type      IN            VARCHAR2  := 'JSP',
   p_x_task_tbl       IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Tbl_Type,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2
)
IS
   -- Define local variables
   L_API_VERSION   CONSTANT NUMBER := 1.0;
   L_API_NAME      CONSTANT VARCHAR2(30) := 'CREATE PUP TASKS';
   L_DEBUG_KEY     CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);
   l_return_status          VARCHAR2(1);
   l_task_tbl               AHL_VWP_RULES_PVT.Task_Tbl_Type := p_x_task_tbl;
   -- Begin changes by rnahata for Issue 105
   l_instance_qty           NUMBER := 0;
   l_instance_id            NUMBER := 0;
   -- End changes by rnahata for Issue 105

   -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010
   -- Flag to decide if call to AHL_VWP_TIMES_PVT.Calculate_Task_Times is needed
   l_past_dates_flag  VARCHAR(1):= 'N' ;

   -- To find visit related information
   CURSOR c_visit(x_id IN NUMBER) IS
    SELECT * FROM AHL_VISITS_VL
    WHERE VISIT_ID = x_id;
   c_visit_rec c_visit%ROWTYPE;

   -- Begin changes by rnahata for Issue 105
   --To fetch instance quantity
   CURSOR c_get_instance_qty(p_instance_id IN NUMBER) IS
    SELECT quantity FROM csi_item_instances csii
    WHERE instance_id = p_instance_id;

   --To fetch instance id for 'Planned' MRs
   CURSOR c_get_instance_id (p_unit_effectivity IN NUMBER) IS
    SELECT csi_item_instance_id FROM AHL_UNIT_EFFECTIVITIES_VL
    WHERE UNIT_EFFECTIVITY_ID = p_unit_effectivity;
   -- End changes by rnahata for Issue 105

BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Create_PUP_Tasks;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure.');
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_boolean(p_init_msg_list)
   THEN
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

  --------------------Start of API Body-----------------------------------
  -------------------Cursor values------------------------------------
   -- if table has no data then return as there is nothing to input
   IF l_task_tbl.count = 0
   THEN
      RETURN;
   END IF;

   OPEN c_visit(l_task_tbl(1).visit_id);
   FETCH c_visit INTO c_visit_rec;
   CLOSE c_visit;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     ': Visit Id = ' || c_visit_rec.visit_id ||
                     ': Status Code ' || c_visit_rec.status_code );
   END IF;

   IF c_visit_rec.status_code IN ('CLOSED','CANCELLED') THEN
      Fnd_Message.SET_NAME('AHL','AHL_VWP_NOT_USE_VISIT');
      Fnd_Msg_Pub.ADD;
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSE
      FOR i IN p_x_task_tbl.first .. p_x_task_tbl.last
      LOOP
        -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: STARTS
        IF (l_task_tbl(i).PAST_TASK_START_DATE IS NOT NULL
           AND l_task_tbl(i).PAST_TASK_START_DATE <> Fnd_Api.G_MISS_DATE) THEN
            IF (l_task_tbl(i).PAST_TASK_END_DATE IS NULL
               OR l_task_tbl(i).PAST_TASK_START_DATE = Fnd_Api.G_MISS_DATE) THEN
                -- if start date is entered but not end date, throw error
             Fnd_Message.SET_NAME('AHL','AHL_VWP_PAST_TASK_DATE_MAND');
             Fnd_Msg_Pub.ADD;
             RAISE FND_API.G_EXC_ERROR;
            END IF;
            -- If both past task start and end dates are non-null
            l_past_dates_flag := 'Y';
            IF (l_task_tbl(i).PAST_TASK_START_DATE >= SYSDATE) THEN
              -- Throw error if start date is not in past
              Fnd_Message.SET_NAME('AHL','AHL_VWP_TASK_PAST_ST_DATE_INV');
              Fnd_Msg_Pub.ADD;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF (l_task_tbl(i).PAST_TASK_START_DATE < NVL(c_visit_rec.START_DATE_TIME, l_task_tbl(i).PAST_TASK_START_DATE)) THEN
                -- Throw error if past task start date is before the visit start date
                Fnd_Message.SET_NAME('AHL','AHL_VWP_TASK_START_DATE_INVLD');
                Fnd_Msg_Pub.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF (l_task_tbl(i).PAST_TASK_START_DATE > l_task_tbl(i).PAST_TASK_END_DATE) THEN
                -- Throw error if past task start date is after the past task end date
                Fnd_Message.SET_NAME('AHL','AHL_VWP_PAST_TASK_DATE_INVLD');
                Fnd_Msg_Pub.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF (l_task_tbl(i).PAST_TASK_END_DATE > NVL(c_visit_rec.CLOSE_DATE_TIME, l_task_tbl(i).PAST_TASK_END_DATE)) THEN
               -- Throw error if visit ends before the task
               Fnd_Message.SET_NAME('AHL','AHL_VWP_TASK_END_DATE_INVLD');
               Fnd_Msg_Pub.ADD;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
        ELSE -- PAST_TASK_START_DATE is null
            -- SKPATHAK :: Bug #9402279 :: 24-FEB-2010 :: Replaced l_task_tbl(1) with l_task_tbl(i)
            -- Also changed the condition from l_task_tbl(i).PAST_TASK_START_DATE <> Fnd_Api.G_MISS_DATE
            -- to l_task_tbl(i).PAST_TASK_END_DATE <> Fnd_Api.G_MISS_DATE
            IF (l_task_tbl(i).PAST_TASK_END_DATE IS NOT NULL
               AND l_task_tbl(i).PAST_TASK_END_DATE <> Fnd_Api.G_MISS_DATE) THEN
             Fnd_Message.SET_NAME('AHL','AHL_VWP_PAST_TASK_DATE_MAND');
             Fnd_Msg_Pub.ADD;
             RAISE FND_API.G_EXC_ERROR;
            END IF;
          l_task_tbl(i).PAST_TASK_START_DATE := NULL;
          l_task_tbl(i).PAST_TASK_END_DATE := NULL;
        END IF;
        -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: END


          IF l_task_tbl(i).task_type_code = 'PLANNED' THEN
             -- Begin changes by rnahata for Issue 105
             OPEN c_get_instance_id (p_x_task_tbl(i).unit_effectivity_id);
             FETCH c_get_instance_id INTO l_instance_id;
             CLOSE c_get_instance_id;

             OPEN c_get_instance_qty(l_instance_id);
             FETCH c_get_instance_qty INTO l_instance_qty;
             CLOSE c_get_instance_qty;

             IF (l_task_tbl(i).QUANTITY is null) THEN
                l_task_tbl(i).QUANTITY := l_instance_qty;
             ELSE
                IF (l_task_tbl(i).QUANTITY > l_instance_qty ) THEN
                   Fnd_Message.SET_NAME('AHL','AHL_INCORRECT_TSK_QTY');
                   Fnd_Msg_Pub.ADD;
                   RAISE Fnd_Api.G_EXC_ERROR;
                END IF;
             END IF;
             -- End changes by rnahata for Issue 105

             -- Call AHL_VWP_PLAN_TASKS_PVT
             IF (l_log_statement >= l_log_current_level) THEN
                 fnd_log.string(l_log_statement,
                                L_DEBUG_KEY,
                                'Before calling Create_Planned_Task, TASK TYPE = ' || l_task_tbl(i).task_type_code ||
                                ', l_task_tbl(i).task_start_date = ' || l_task_tbl(i).task_start_date);
             END IF;

       -- SKPATHAK :: Bug 8343599 :: 14_APR-2009
       -- Check if the user entered task start date is between the visit start and end dates
       IF (l_task_tbl(i).task_start_date < c_visit_rec.START_DATE_TIME OR
           l_task_tbl(i).task_start_date > c_visit_rec.CLOSE_DATE_TIME) THEN
         FND_MESSAGE.SET_NAME ('AHL', 'AHL_VWP_TSK_START_DATE_INVLD');
         FND_MESSAGE.SET_TOKEN('DATE', l_task_tbl(i).task_start_date);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;

             AHL_VWP_PLAN_TASKS_PVT.Create_Planned_Task (
                p_api_version             => l_api_version,
                p_init_msg_list           => p_init_msg_list,
                p_commit                  => FND_API.G_FALSE,
                p_validation_level        => p_validation_level,
                p_module_type             => p_module_type,
                p_x_task_rec              => l_task_tbl(i),
                x_return_status           => l_return_status,
                x_msg_count               => l_msg_count,
                x_msg_data                => l_msg_data
             );

             IF (l_log_statement >= l_log_current_level) THEN
                 fnd_log.string(l_log_statement,
                                L_DEBUG_KEY,
                                'After calling Create_Planned_Task, Return Status = ' ||
                                l_return_status);
             END IF;
             l_msg_count := Fnd_Msg_Pub.count_msg;

             IF l_msg_count > 0 OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
                x_msg_count := l_msg_count;
                x_return_status := Fnd_Api.G_RET_STS_ERROR;
                RAISE Fnd_Api.G_EXC_ERROR;
             END IF;

          ELSIF l_task_tbl(i).task_type_code = 'UNPLANNED' THEN
             -- Begin changes by rnahata for Issue 105
             OPEN c_get_instance_qty(l_task_tbl(i).instance_id);
             FETCH c_get_instance_qty INTO l_instance_qty;
             CLOSE c_get_instance_qty;

             IF (l_task_tbl(i).QUANTITY is null) THEN
                Fnd_Message.SET_NAME('AHL','AHL_TASK_QTY_NULL');
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
             END IF;

             IF (l_task_tbl(i).QUANTITY <= 0 ) THEN
                Fnd_Message.SET_NAME('AHL','AHL_POSITIVE_TSK_QTY');
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
             END IF;

             IF (l_task_tbl(i).QUANTITY > l_instance_qty ) THEN
                Fnd_Message.SET_NAME('AHL','AHL_INCORRECT_TSK_QTY');
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
             END IF;
             -- End changes by rnahata for Issue 105

             -- Call AHL_VWP_UNPLAN_TASKS_PVT
             IF (l_log_statement >= l_log_current_level) THEN
                 fnd_log.string(l_log_statement,
                                L_DEBUG_KEY,
                                'Before Calling Create_Unplanned_Task,  TASK TYPE = ' || l_task_tbl(i).task_type_code);
             END IF;

             AHL_VWP_UNPLAN_TASKS_PVT.Create_Unplanned_Task (
                p_api_version             => l_api_version,
                p_init_msg_list           => p_init_msg_list,
                p_commit                  => FND_API.G_FALSE,
                p_validation_level        => p_validation_level,
                p_module_type             => p_module_type,
                p_x_task_rec              => l_task_tbl(i),
                x_return_status           => l_return_status,
                x_msg_count               => l_msg_count,
                x_msg_data                => l_msg_data
             );

             IF (l_log_statement >= l_log_current_level) THEN
                 fnd_log.string(l_log_statement,
                                L_DEBUG_KEY,
                                'After Calling Create_Unplanned_Task, Return Status = ' || l_return_status );
             END IF;

             l_msg_count := Fnd_Msg_Pub.count_msg;

             IF l_msg_count > 0 OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
                x_msg_count := l_msg_count;
                x_return_status := Fnd_Api.G_RET_STS_ERROR;
                RAISE Fnd_Api.G_EXC_ERROR;
             END IF;
          END IF;
      END LOOP;
   END IF;

   -- SKPATHAK :: Bug 8343599 :: 14_APR-2009 :: Begin
   -- Skip calling AHL_VWP_TIMES_PVT.Calculate_Task_Times if
   -- the user has entered task start date for Non Routine
   -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Added one more condition (l_past_dates_flag = 'N')
   IF (p_module_type <> 'SR' OR l_task_tbl(1).task_start_date IS NULL) AND (l_past_dates_flag = 'N') THEN
    IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'Before Calling AHL_VWP_TIMES_PVT.Calculate_Task_Times');
    END IF;
    AHL_VWP_TIMES_PVT.Calculate_Task_Times(p_api_version => 1.0,
                      p_init_msg_list => Fnd_Api.G_FALSE,
                      p_commit        => Fnd_Api.G_FALSE,
                      p_validation_level      => Fnd_Api.G_VALID_LEVEL_FULL,
                      x_return_status      => l_return_status,
                      x_msg_count          => l_msg_count,
                      x_msg_data           => l_msg_data,
                      p_visit_id            => c_visit_rec.VISIT_ID);

    IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'After Calling AHL_VWP_TIMES_PVT.Calculate_Task_Times. Return Status = ' || l_return_status );
    END IF;

    IF NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;
   END IF;
   -- SKPATHAK :: Bug 8343599 :: 14_APR-2009 :: End

   IF c_visit_rec.STATUS_CODE = 'RELEASED' THEN
      UPDATE AHL_VISITS_B
      SET  STATUS_CODE = 'PARTIALLY RELEASED',
           OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1
      WHERE VISIT_ID =c_visit_rec.VISIT_ID ;
   END IF;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Successful updation of the status');
   END IF;
    p_x_task_tbl:=l_task_tbl; --Added by rnahata for Bug 6939329
    --------------------End of API Body-------------------------------------
   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Create_PUP_Tasks;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get(
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Create_PUP_Tasks;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_PUP_Tasks;
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
END Create_PUP_Tasks;

-------------------------------------------------------------------
--  Procedure name    : Associate_Default_MRs
--  Type              : Private
--  Function          : To create Unassociated/Summary/Non-Routine task for a visit
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--      p_visit_rec                     IN      AHL_VWP_VISITS_PVT.Visit_Rec_Type,
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--    Purpose:
--         To associate default MR's during Transit Check Visit creation.
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------
PROCEDURE associate_default_mrs (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2  := 'JSP',
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,
   p_visit_rec            IN  AHL_VWP_VISITS_PVT.Visit_Rec_Type
) AS

  -- Define local variables
   L_API_VERSION          CONSTANT NUMBER := 1.0;
   L_API_NAME             CONSTANT VARCHAR2(30) := 'ASSOCIATE_DEFAULT_MRS';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_return_status         VARCHAR2(1);
  l_instance_id           NUMBER;

  J NUMBER;

  CURSOR c_get_Item_Instance(p_visit_id NUMBER) IS
  SELECT ITEM_INSTANCE_ID
   FROM  ahl_visits_b
  WHERE  visit_id = p_visit_id;

  CURSOR c_get_visit_applicable_mrs IS
  SELECT distinct mr_header_id
   FROM  ahl_applicable_mrs;

  -- Begin changes by rnahata for Issue 105
  --Cursor to fetch instance quantity
  CURSOR c_get_instance_qty(p_instance_id IN NUMBER) IS
  SELECT quantity FROM csi_item_instances csii
   WHERE instance_id = p_instance_id;

  l_instance_qty   NUMBER := 0;
  -- End changes by rnahata for Issue 105

  l_Task_tbl       AHL_VWP_RULES_PVT.Task_Tbl_Type;

BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT associate_default_mrs;

    -- Check if API is called in debug mode. If yes, enable debug.
   IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.begin',
                      'At the start of PL SQL procedure.');
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_boolean(p_init_msg_list)
   THEN
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

  --------------------Start of API Body-----------------------------------

  IF p_visit_rec.visit_type_code IS NOT NULL
     AND p_visit_rec.visit_id IS NOT NULL THEN
  OPEN   c_get_Item_Instance(p_visit_rec.visit_id);
  FETCH c_get_Item_Instance INTO l_instance_id;
  CLOSE c_get_Item_Instance;

  IF l_instance_id IS NOT NULL THEN

    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                       ' Before calling AHL_FMP_PVT.GET_VISIT_APPLICABLE_MRS, l_instance_id = ' || l_instance_id);
    END IF;
    AHL_FMP_PVT.GET_VISIT_APPLICABLE_MRS(
      P_API_VERSION             => 1.0,
      X_RETURN_STATUS        => L_RETURN_STATUS,
      X_MSG_COUNT            => L_MSG_COUNT,
      X_MSG_DATA             => L_MSG_DATA,
      P_ITEM_INSTANCE_ID     => l_instance_id,
      P_VISIT_TYPE_CODE      => p_visit_rec.visit_type_code);
      --X_APPLICABLE_MR_TBL    => l_mr_item_instance_tbl);

    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                       'After calling AHL_FMP_PVT.GET_VISIT_APPLICABLE_MRS. Return status =  ' || L_RETURN_STATUS || ', l_instance_id = ' || l_instance_id);
    END IF;

    l_msg_count := Fnd_Msg_Pub.count_msg;

    IF l_msg_count > 0 OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
       x_msg_count := l_msg_count;
       x_return_status := Fnd_Api.G_RET_STS_ERROR;
       RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    -- Begin changes by rnahata for Issue 105
    OPEN c_get_instance_qty(l_instance_id);
    FETCH c_get_instance_qty INTO l_instance_qty;
    CLOSE c_get_instance_qty;
    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                       'Richa -- l_instance_id = ' || l_instance_id || ', l_instance_qty = ' || l_instance_qty);
    END IF;
    -- End changes by rnahata for Issue 105

    J := 0;
    FOR I in c_get_visit_applicable_mrs
    LOOP
         J := J+1;
         l_task_tbl(J).mr_id := I.mr_header_id;
         -- Begin changes by rnahata for Issue 105
         l_task_tbl(J).instance_id := l_instance_id;
         l_task_tbl(J).quantity := l_instance_qty;
         -- End changes by rnahata for Issue 105
         l_task_tbl(J).visit_id := p_visit_rec.visit_id;
         l_task_tbl(J).task_type_code := 'UNPLANNED';
         l_task_tbl(J).dept_name := p_visit_rec.dept_name;
         l_task_tbl(J).department_id := p_visit_rec.department_id;
         l_task_tbl(J).inventory_item_id := p_visit_rec.inventory_item_id;
         l_task_tbl(J).item_organization_id := p_visit_rec.item_organization_id;
         l_task_tbl(J).item_name      := p_visit_rec.item_name;
         l_task_tbl(J).serial_number  := p_visit_rec.serial_number;
         END LOOP;

         IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            ' Calling AHL_VWP_TASKS_PVT.CREATE_PUP_TASKS ');
         END IF;
         AHL_VWP_TASKS_PVT.CREATE_PUP_TASKS(
            p_api_version   => 1.0,
            p_module_type   => p_module_type,
            p_x_task_tbl    => l_task_tbl,
            x_return_status => l_return_status,
            x_msg_count     => l_msg_count,
            x_msg_data      => l_msg_data);

     l_msg_count := Fnd_Msg_Pub.count_msg;

     IF l_msg_count > 0 OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
        x_msg_count := l_msg_count;
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
        RAISE Fnd_Api.G_EXC_ERROR;
     END IF;

        END IF;  -- Instance ID is not null.

      END IF;  -- Visit id and Visit type is not null.
  --------------------End of API Body-------------------------------------
   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO associate_default_mrs;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get(
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO associate_default_mrs;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO associate_default_mrs;
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
END associate_default_mrs;
END AHL_VWP_TASKS_PVT;

/
