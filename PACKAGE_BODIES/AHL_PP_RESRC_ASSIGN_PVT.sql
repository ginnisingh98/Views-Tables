--------------------------------------------------------
--  DDL for Package Body AHL_PP_RESRC_ASSIGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PP_RESRC_ASSIGN_PVT" AS
/* $Header: AHLVASGB.pls 120.10.12010000.2 2010/04/12 09:52:40 snarkhed ship $*/

-- Declare Constants --
-----------------------
G_PKG_NAME  VARCHAR2(30)  := 'AHL_PP_RESRC_ASSIGN_PVT';
G_DEBUG     VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;
-------------------------------------------------
-- Declare Locally used Record and Table Types --
-------------------------------------------------

-------------------------------------------------
-- Declare Local Procedures                    --
-------------------------------------------------

--------------------------------------------------------------------
-- PROCEDURE
--    Check_Lookup_Name_Or_Id
--
-- PURPOSE
--    Converts Lookup Name/Code to ID/Value or Vice versa
--------------------------------------------------------------------
PROCEDURE Check_Lookup_Name_Or_Id
 ( p_lookup_type      IN MFG_LOOKUPS.lookup_type%TYPE,
   p_lookup_code      IN MFG_LOOKUPS.lookup_code%TYPE,
   p_meaning          IN MFG_LOOKUPS.meaning%TYPE,
   p_check_id_flag    IN VARCHAR2,

   x_lookup_code      OUT NOCOPY NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2)
IS
BEGIN
  IF (p_lookup_code IS NOT NULL) THEN
        IF (p_check_id_flag = 'Y') THEN
          SELECT lookup_code INTO x_lookup_code
           FROM MFG_LOOKUPS
          WHERE lookup_type = p_lookup_type
            AND lookup_code = p_lookup_code
            AND SYSDATE BETWEEN start_date_active
            AND NVL(end_date_active,SYSDATE);
        ELSE
           x_lookup_code := p_lookup_code;
        END IF;
  ELSE
        SELECT lookup_code INTO x_lookup_code
           FROM MFG_LOOKUPS
          WHERE lookup_type = p_lookup_type
            AND meaning = p_meaning
            AND SYSDATE BETWEEN start_date_active
            AND NVL(end_date_active,SYSDATE);
  END IF;

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
   WHEN TOO_MANY_ROWS THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
  RAISE;
END;

--------------------------------------------------------------------
-- PROCEDURE
--    Check_Serial_Name_Or_Id
--
-- PURPOSE
--    Converts Serial Name to ID or Vice versa
--------------------------------------------------------------------
PROCEDURE Check_Serial_Name_Or_Id
    (p_serial_id        IN NUMBER,
     p_serial_number    IN VARCHAR2,
     p_workorder_id     IN NUMBER,
     p_resource_id      IN NUMBER,
     p_dept_id          IN NUMBER,
     p_organization_id  IN NUMBER,
     x_instance_id      OUT NOCOPY NUMBER,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_error_msg_code   OUT NOCOPY VARCHAR2
     )
IS
BEGIN
   IF G_DEBUG='Y' THEN
    Ahl_Debug_Pub.debug( ': Inside Check  Serial Number= ' || p_serial_number);
   END IF;

    IF (p_serial_number IS NOT NULL) THEN
          /*SELECT DISTINCT(instance_id)
              INTO x_serial_id
            FROM BOM_DEPT_RES_INSTANCES BDRI, AHL_OPERATION_RESOURCES AOR, AHL_WORKORDERS_V AWO
          WHERE BDRI.resource_id = AOR.resource_id
          AND BDRI.department_id = AWO.department_id
          AND AWO.workorder_id = p_workorder_id
          AND AOR.operation_resource_id = p_oper_resrc_id
          AND BDRI.serial_number  = p_serial_number;*/

          SELECT INSTANCE_ID INTO x_instance_id
            FROM BOM_DEPT_RES_INSTANCES BDRI
          WHERE BDRI.resource_id = p_resource_id
          AND BDRI.serial_number  = p_serial_number
          AND BDRI.department_id in (
                                       SELECT
					  nvl(bdr.SHARE_FROM_DEPT_ID,
					  bdr.department_id)
					FROM
					  bom_departments bd,
					  bom_department_resources bdr
					WHERE
					  bdr.resource_id = p_resource_id and
					  bdr.department_id = bd.department_id and
					  bd.organization_id = p_organization_id
				    );
    END IF;

   IF G_DEBUG='Y' THEN
    Ahl_Debug_Pub.debug(': Inside Check Serial Number = ' || x_instance_id);
   END IF;

    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_PP_SERIAL_NOT_EXISTS';
    WHEN TOO_MANY_ROWS THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_PP_SERIAL_NOT_EXISTS';
    WHEN OTHERS THEN
         x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
RAISE;
END Check_Serial_Name_Or_Id;

--------------------------------------------------------------------
-- PROCEDURE
--    Check_Employee_Number_Or_Id
--
-- PURPOSE
--    Converts Employee Number to ID or Vice versa
--------------------------------------------------------------------
PROCEDURE Check_Employee_Number_Or_Id
    (p_employee_id        IN NUMBER,
     p_employee_number    IN VARCHAR,
     p_workorder_id       IN NUMBER,
     p_oper_resrc_id      IN NUMBER,
     p_resource_id        IN NUMBER,
     p_organization_id    IN NUMBER,
     x_employee_id      OUT NOCOPY NUMBER,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_error_msg_code   OUT NOCOPY VARCHAR2
     )
IS
BEGIN
    IF (p_employee_number IS NOT NULL) THEN
          /*SELECT DISTINCT(PPF.PERSON_ID)
             INTO x_employee_id
          FROM PER_PEOPLE_F PPF, BOM_RESOURCE_EMPLOYEES BRE, AHL_OPERATION_RESOURCES AOR,
               PER_PERSON_TYPES PEPT, AHL_WORKORDERS AWV, AHL_VISITS_B VTB
             WHERE PPF.PERSON_ID = BRE.PERSON_ID AND BRE.RESOURCE_ID = AOR.RESOURCE_ID
           AND AWV.VISIT_ID = VTB.VISIT_ID
           AND BRE.ORGANIZATION_ID = VTB.ORGANIZATION_ID
           AND TRUNC(SYSDATE) BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
           AND NVL(PPF.CURRENT_EMPLOYEE_FLAG, 'X') = 'Y' AND PEPT.PERSON_TYPE_ID = PPF.PERSON_TYPE_ID
           AND PEPT.SYSTEM_PERSON_TYPE   ='EMP' AND AOR.operation_resource_id = p_oper_resrc_id
           AND PPF.EMPLOYEE_NUMBER  = p_employee_number AND AWV.WORKORDER_ID = p_workorder_id;*/

          -- bug# 4553747.
          -- assignments are only allowed for employees in the WOs dept.
          SELECT DISTINCT(PF.employee_id)
             INTO x_employee_id
          FROM
          bom_dept_res_instances bdri,
          wip_operation_resources wor,
          wip_operations wo
          ,ahl_workorders awo, ahl_operation_resources aor
          , mtl_employees_current_view pf
          ,bom_resource_employees bre
          where awo.wip_entity_id = wor.wip_entity_id
          and awo.workorder_id = p_workorder_id
          and aor.operation_resource_id = p_oper_resrc_id
          and wor.resource_seq_num = aor.resource_sequence_num
          and wor.resource_id = aor.resource_id
          and bdri.department_id in (
                                       SELECT
					  nvl(bdr.SHARE_FROM_DEPT_ID,
					  bdr.department_id)
					FROM
					  bom_departments bd,
					  bom_department_resources bdr
					  --ahl_pp_requirement_v aprv
					  --Removed since The view is not being used.
					  --for bug #9031320
					WHERE
					  bdr.resource_id = p_resource_id and
					  bdr.department_id = bd.department_id and
					  bd.organization_id = p_organization_id
				    )
          and bdri.resource_id = wor.resource_id
          and wo.wip_entity_id = wor.wip_entity_id
          and wo.organization_id = wor.organization_id
          and wo.operation_seq_num = wor.operation_seq_num
          and pf.employee_id = bre.person_id
          and pf.organization_id = bre.organization_id
          and bre.instance_id = bdri.instance_id
          and pf.employee_num = p_employee_number;

    END IF;

   IF G_DEBUG='Y' THEN
    Ahl_Debug_Pub.debug(': Inside Check Employee Id= ' || x_Employee_id);
    END IF;

    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_VWP_EMPLOYEE_NOT_EXISTS';
    WHEN TOO_MANY_ROWS THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_VWP_EMPLOYEE_NOT_EXISTS';
    WHEN OTHERS THEN
         x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
RAISE;
END Check_Employee_Number_Or_Id;

--------------------------------------------------------------------
-- PROCEDURE
--    Check_Employee_Name_Or_Id
--
-- PURPOSE
--    Converts Employee Name to ID or Vice versa
--------------------------------------------------------------------
PROCEDURE Check_Employee_Name_Or_Id
    (p_Employee_Id      IN NUMBER,
     p_employee_number  IN VARCHAR2,
     p_workorder_id     IN NUMBER,
     p_oper_resrc_id    IN NUMBER,
     p_resource_id      IN NUMBER,
     p_organization_id  IN NUMBER,
     x_employee_name    OUT NOCOPY VARCHAR2,
     x_employee_id      OUT NOCOPY NUMBER,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_error_msg_code   OUT NOCOPY VARCHAR2
     )
IS
BEGIN

    IF (p_Employee_Number IS NOT NULL) THEN
         /*SELECT PPF.PERSON_ID, PPF.FULL_NAME
             INTO x_employee_id, x_employee_name
           FROM PER_PEOPLE_F PPF,
                BOM_RESOURCE_EMPLOYEES BRE,
                AHL_OPERATION_RESOURCES AOR,
                PER_PERSON_TYPES PEPT,
                AHL_WORKORDERS AWV,
                AHL_VISITS_B VTB
         WHERE PPF.PERSON_ID = BRE.PERSON_ID
           AND BRE.resource_id = AOR.resource_id
           AND TRUNC(SYSDATE) BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
           AND AWV.VISIT_ID = VTB.VISIT_ID
           AND BRE.ORGANIZATION_ID = VTB.ORGANIZATION_ID
           AND NVL(PPF.CURRENT_EMPLOYEE_FLAG, 'X') = 'Y'
           AND PEPT.PERSON_TYPE_ID = PPF.PERSON_TYPE_ID
           AND PEPT.SYSTEM_PERSON_TYPE   ='EMP'
           AND AOR.operation_resource_id = p_oper_resrc_id
           AND PPF.EMPLOYEE_NUMBER  = p_employee_number
           AND AWV.WORKORDER_ID = p_workorder_id;*/

         -- bug# 4553747.
         -- assignments are only allowed for employees in the WOs dept.
         select distinct pf.employee_id, pf.full_name
             INTO x_employee_id, x_employee_name
         from
         bom_dept_res_instances bdri,
         wip_operation_resources wor,
         wip_operations wo
         ,ahl_workorders awo, ahl_operation_resources aor
         , mtl_employees_current_view pf
         ,bom_resource_employees bre
         where awo.wip_entity_id = wor.wip_entity_id
         and awo.workorder_id = p_workorder_id
         and aor.operation_resource_id = p_oper_resrc_id
         and wor.resource_seq_num = aor.resource_sequence_num
         and wor.resource_id = aor.resource_id
         and bdri.department_id in (
                                       SELECT
					  nvl(bdr.SHARE_FROM_DEPT_ID,
					  bdr.department_id)
					FROM
					  bom_departments bd,
					  bom_department_resources bdr
					WHERE
					  bdr.resource_id = p_resource_id and
					  bdr.department_id = bd.department_id and
					  bd.organization_id = p_organization_id
				    )
         and bdri.resource_id = wor.resource_id
         and wo.wip_entity_id = wor.wip_entity_id
         and wo.organization_id = wor.organization_id
         and wo.operation_seq_num = wor.operation_seq_num
         and pf.employee_id = bre.person_id
         and pf.organization_id = bre.organization_id
         and bre.instance_id = bdri.instance_id
         and pf.employee_num = p_employee_number;

    END IF;
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_VWP_EMPLOYEE_NOT_EXISTS';
    WHEN TOO_MANY_ROWS THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_VWP_EMPLOYEE_NOT_EXISTS';
    WHEN OTHERS THEN
         x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
RAISE;
END Check_Employee_Name_Or_Id;

---------------------------------------------------------------------
-- PROCEDURE
--       Insert_Row
---------------------------------------------------------------------
PROCEDURE Insert_Row (
  X_ASSIGNMENT_ID           IN NUMBER,
  X_OBJECT_VERSION_NUMBER   IN NUMBER,
  X_LAST_UPDATE_DATE        IN DATE,
  X_LAST_UPDATED_BY         IN NUMBER,
  X_CREATION_DATE           IN DATE,
  X_CREATED_BY              IN NUMBER,
  X_LAST_UPDATE_LOGIN       IN NUMBER,
  X_OPERATION_RESOURCE_ID   IN NUMBER,
  X_EMPLOYEE_ID             IN NUMBER,
  X_SERIAL_NUMBER           IN VARCHAR2,
  X_INSTANCE_ID             IN NUMBER,
  X_ASSIGN_START_DATE       IN DATE,
  X_ASSIGN_END_DATE         IN DATE,
  X_SELF_ASSIGNED_FLAG      IN VARCHAR2,
  --X_LOGIN_DATE              IN DATE,
  X_ATTRIBUTE_CATEGORY      IN VARCHAR2,
  X_ATTRIBUTE1              IN VARCHAR2,
  X_ATTRIBUTE2              IN VARCHAR2,
  X_ATTRIBUTE3              IN VARCHAR2,
  X_ATTRIBUTE4              IN VARCHAR2,
  X_ATTRIBUTE5              IN VARCHAR2,
  X_ATTRIBUTE6              IN VARCHAR2,
  X_ATTRIBUTE7              IN VARCHAR2,
  X_ATTRIBUTE8              IN VARCHAR2,
  X_ATTRIBUTE9              IN VARCHAR2,
  X_ATTRIBUTE10             IN VARCHAR2,
  X_ATTRIBUTE11             IN VARCHAR2,
  X_ATTRIBUTE12             IN VARCHAR2,
  X_ATTRIBUTE13             IN VARCHAR2,
  X_ATTRIBUTE14             IN VARCHAR2,
  X_ATTRIBUTE15             IN VARCHAR2
)
IS
BEGIN
  INSERT INTO AHL_WORK_ASSIGNMENTS (
    ASSIGNMENT_ID,
    OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    OPERATION_RESOURCE_ID,
    EMPLOYEE_ID,
    SERIAL_NUMBER,
    INSTANCE_ID,
    ASSIGN_START_DATE,
    ASSIGN_END_DATE,
    --LOGIN_DATE,
    SELF_ASSIGNED_FLAG,
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
  VALUES(
    X_ASSIGNMENT_ID,
    X_OBJECT_VERSION_NUMBER,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_OPERATION_RESOURCE_ID,
    X_EMPLOYEE_ID,
    X_SERIAL_NUMBER,
    X_INSTANCE_ID,
    X_ASSIGN_START_DATE,
    X_ASSIGN_END_DATE,
    X_SELF_ASSIGNED_FLAG,
    --X_LOGIN_DATE,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15);

END Insert_Row;

---------------------------------------------------------------------
-- PROCEDURE
--       Update_Row
---------------------------------------------------------------------
PROCEDURE UPDATE_ROW (
  X_ASSIGNMENT_ID           IN NUMBER,
  X_OBJECT_VERSION_NUMBER   IN NUMBER,
  X_OPERATION_RESOURCE_ID   IN NUMBER,
  X_EMPLOYEE_ID             IN NUMBER,
  X_SERIAL_NUMBER           IN VARCHAR2,
  X_INSTANCE_ID             IN NUMBER,
  X_ASSIGN_START_DATE       IN DATE,
  X_ASSIGN_END_DATE         IN DATE,
  X_SELF_ASSIGNED_FLAG      IN VARCHAR2,
  --X_LOGIN_DATE              IN DATE,
  X_ATTRIBUTE_CATEGORY      IN VARCHAR2,
  X_ATTRIBUTE1              IN VARCHAR2,
  X_ATTRIBUTE2              IN VARCHAR2,
  X_ATTRIBUTE3              IN VARCHAR2,
  X_ATTRIBUTE4              IN VARCHAR2,
  X_ATTRIBUTE5              IN VARCHAR2,
  X_ATTRIBUTE6              IN VARCHAR2,
  X_ATTRIBUTE7              IN VARCHAR2,
  X_ATTRIBUTE8              IN VARCHAR2,
  X_ATTRIBUTE9              IN VARCHAR2,
  X_ATTRIBUTE10             IN VARCHAR2,
  X_ATTRIBUTE11             IN VARCHAR2,
  X_ATTRIBUTE12             IN VARCHAR2,
  X_ATTRIBUTE13             IN VARCHAR2,
  X_ATTRIBUTE14             IN VARCHAR2,
  X_ATTRIBUTE15             IN VARCHAR2,
  X_LAST_UPDATE_DATE        IN DATE,
  X_LAST_UPDATED_BY         IN NUMBER,
  X_LAST_UPDATE_LOGIN       IN NUMBER
)
IS

BEGIN
  UPDATE AHL_WORK_ASSIGNMENTS SET
    OBJECT_VERSION_NUMBER           = X_OBJECT_VERSION_NUMBER + 1,
    ASSIGNMENT_ID                   = X_ASSIGNMENT_ID,
    OPERATION_RESOURCE_ID           = X_OPERATION_RESOURCE_ID,
    EMPLOYEE_ID                     = X_EMPLOYEE_ID,
    SERIAL_NUMBER                   = X_SERIAL_NUMBER,
    INSTANCE_ID                     = X_INSTANCE_ID,
    ASSIGN_START_DATE               = X_ASSIGN_START_DATE,
    ASSIGN_END_DATE                 = X_ASSIGN_END_DATE,
    SELF_ASSIGNED_FLAG              = X_SELF_ASSIGNED_FLAG,
    --LOGIN_DATE                      = X_LOGIN_DATE,
    ATTRIBUTE_CATEGORY              = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1                      = X_ATTRIBUTE1,
    ATTRIBUTE2                      = X_ATTRIBUTE2,
    ATTRIBUTE3                      = X_ATTRIBUTE3,
    ATTRIBUTE4                      = X_ATTRIBUTE4,
    ATTRIBUTE5                      = X_ATTRIBUTE5,
    ATTRIBUTE6                      = X_ATTRIBUTE6,
    ATTRIBUTE7                      = X_ATTRIBUTE7,
    ATTRIBUTE8                      = X_ATTRIBUTE8,
    ATTRIBUTE9                      = X_ATTRIBUTE9,
    ATTRIBUTE10                     = X_ATTRIBUTE10,
    ATTRIBUTE11                     = X_ATTRIBUTE11,
    ATTRIBUTE12                     = X_ATTRIBUTE12,
    ATTRIBUTE13                     = X_ATTRIBUTE13,
    ATTRIBUTE14                     = X_ATTRIBUTE14,
    ATTRIBUTE15                     = X_ATTRIBUTE15,
    LAST_UPDATE_DATE                = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY                 = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN               = X_LAST_UPDATE_LOGIN
    WHERE ASSIGNMENT_ID             = X_ASSIGNMENT_ID
    AND OBJECT_VERSION_NUMBER       = X_OBJECT_VERSION_NUMBER;

   IF G_DEBUG='Y' THEN
	      AHL_DEBUG_PUB.debug(' Inside Update Row procedure');
          AHL_DEBUG_PUB.debug(' Assign ID = ' || X_ASSIGNMENT_ID);
          AHL_DEBUG_PUB.debug(' Object version = ' || X_OBJECT_VERSION_NUMBER);
          AHL_DEBUG_PUB.debug(' Assign Start Date = ' || x_assign_start_date);
          AHL_DEBUG_PUB.debug(' Assign End Date = ' || x_assign_end_date);
    END IF;

  /*IF SQL%rowcount = 0 THEN
     Fnd_Message.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
     Fnd_Msg_Pub.ADD;
  END IF;*/
END UPDATE_ROW;

---------------------------------------------------------------------
-- PROCEDURE
--       Delete_Row
---------------------------------------------------------------------
PROCEDURE DELETE_ROW (
  X_ASSIGNMENT_ID IN NUMBER
) IS
BEGIN
  DELETE FROM AHL_WORK_ASSIGNMENTS
  WHERE ASSIGNMENT_ID = X_ASSIGNMENT_ID;
END DELETE_ROW;

---------------------------------------------------------------------
-- PROCEDURE
--       Check_Resrc_Assign_Req_Items
---------------------------------------------------------------------
PROCEDURE Check_Resrc_Assign_Req_Items (
   p_resrc_assign_rec    IN    Resrc_Assign_Rec_Type,
   x_return_status       OUT   NOCOPY VARCHAR2
)
IS
BEGIN
   IF G_DEBUG='Y' THEN
     Ahl_Debug_Pub.debug( ': ASSIGNMENT_ID = ' || p_resrc_assign_rec.ASSIGNMENT_ID);
     Ahl_Debug_Pub.debug( ': OPERATION_SEQ_NUMBER = ' || p_resrc_assign_rec.OPERATION_SEQ_NUMBER);
     Ahl_Debug_Pub.debug( ': RESOURCE_SEQ_NUMBER = ' || p_resrc_assign_rec.RESOURCE_SEQ_NUMBER);
   END IF;

  IF (p_resrc_assign_rec.ASSIGNMENT_ID IS NULL OR p_resrc_assign_rec.ASSIGNMENT_ID = Fnd_Api.G_MISS_NUM) THEN
      -- OPERATION_SEQ_NUMBER
   IF (p_resrc_assign_rec.OPERATION_SEQ_NUMBER IS NULL OR p_resrc_assign_rec.OPERATION_SEQ_NUMBER = Fnd_Api.G_MISS_NUM) THEN
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_PP_OPER_SEQ_MISSING');
         Fnd_Msg_Pub.ADD;
      END IF;
      x_return_status := Fnd_Api.g_ret_sts_error;
      RETURN;
   END IF;

     -- OPERATION_SEQ_NUMBER - Positive
   IF (p_resrc_assign_rec.OPERATION_SEQ_NUMBER IS NOT NULL AND p_resrc_assign_rec.OPERATION_SEQ_NUMBER <> Fnd_Api.G_MISS_NUM) THEN
      IF p_resrc_assign_rec.OPERATION_SEQ_NUMBER < 0 THEN
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
             Fnd_Message.set_name ('AHL', 'AHL_PP_ONLY_POSITIVE_VALUE');
             Fnd_Msg_Pub.ADD;
          END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
          RETURN;
      END IF;
   END IF;

     -- RESOURCE_SEQ_NUMBER
   IF (p_resrc_assign_rec.RESOURCE_SEQ_NUMBER IS NULL OR p_resrc_assign_rec.RESOURCE_SEQ_NUMBER = Fnd_Api.G_MISS_NUM) THEN
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_PP_RESRC_SEQ_MISSING');
         Fnd_Msg_Pub.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      x_return_status := Fnd_Api.g_ret_sts_error;
      RETURN;
   END IF;

     -- RESOURCE_SEQ_NUMBER - Positive
   IF (p_resrc_assign_rec.RESOURCE_SEQ_NUMBER IS NOT NULL AND p_resrc_assign_rec.RESOURCE_SEQ_NUMBER <> Fnd_Api.G_MISS_NUM) THEN
      IF p_resrc_assign_rec.RESOURCE_SEQ_NUMBER < 0 THEN
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
             Fnd_Message.set_name ('AHL', 'AHL_PP_ONLY_POSITIVE_VALUE');
             Fnd_Msg_Pub.ADD;
          END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
          RETURN;
      END IF;
   END IF;
 END IF;
   IF G_DEBUG='Y' THEN
     Ahl_Debug_Pub.debug( ': Resource Type = ' || p_resrc_assign_rec.RESOURCE_TYPE_CODE);
     Ahl_Debug_Pub.debug( ': Employee Name = ' || p_resrc_assign_rec.employee_name);
     Ahl_Debug_Pub.debug( ': EMployee Number = ' || p_resrc_assign_rec.employee_number);
   END IF;

  IF p_resrc_assign_rec.RESOURCE_TYPE_CODE = 2 THEN
      -- EMPLOYEE_NUMBER
      IF G_DEBUG='Y' THEN
        Ahl_Debug_Pub.debug( ': Resource Type 11111= ' || p_resrc_assign_rec.RESOURCE_TYPE_CODE);
      END IF;

      --IF (p_resrc_assign_rec.employee_id IS NULL) THEN
      /*
          IF (p_resrc_assign_rec.EMPLOYEE_NUMBER IS NULL OR p_resrc_assign_rec.EMPLOYEE_NUMBER = Fnd_Api.G_MISS_CHAR) THEN
             IF G_DEBUG='Y' THEN
             Ahl_Debug_Pub.debug( ': Resource Type 22222= ' || p_resrc_assign_rec.RESOURCE_TYPE_CODE);
             END IF;

	     IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
                Fnd_Message.set_name ('AHL', 'AHL_PP_EMP_NUM_MISSING');
                Fnd_Msg_Pub.ADD;
             END IF;
             x_return_status := Fnd_Api.g_ret_sts_error;
             RETURN;
          END IF; */
      --END IF; -- p_resrc_assign_rec.employee_id IS NULL
         IF (p_resrc_assign_rec.EMPLOYEE_ID IS NULL OR p_resrc_assign_rec.EMPLOYEE_ID = Fnd_Api.G_MISS_NUM) THEN
          IF G_DEBUG='Y' THEN
          Ahl_Debug_Pub.debug( ': Resource Type 22222= ' || p_resrc_assign_rec.RESOURCE_TYPE_CODE);
          END IF;

	      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
             Fnd_Message.set_name ('AHL', 'AHL_PP_EMP_NUM_MISSING');
             Fnd_Msg_Pub.ADD;
          END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
          RETURN;
       END IF;
  END IF;  -- p_resrc_assign_rec.RESOURCE_TYPE_CODE

 IF p_resrc_assign_rec.RESOURCE_TYPE_CODE <> 2 THEN
       -- SERIAL NUMBER
       IF (p_resrc_assign_rec.SERIAL_NUMBER IS NULL OR p_resrc_assign_rec.SERIAL_NUMBER = Fnd_Api.G_MISS_CHAR) THEN
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
             Fnd_Message.set_name ('AHL', 'AHL_PP_SERIAL_MISSING');
             Fnd_Msg_Pub.ADD;
          END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
          RETURN;
       END IF;
  END IF;

         -- ASSIGN_START_DATE
   IF (p_resrc_assign_rec.ASSIGN_START_DATE IS NULL OR p_resrc_assign_rec.ASSIGN_START_DATE = Fnd_Api.G_MISS_DATE)THEN
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_PP_ASSIGN_ST_DT_MISSING');
         Fnd_Msg_Pub.ADD;
      END IF;
      x_return_status := Fnd_Api.g_ret_sts_error;
      RETURN;
   END IF;

      -- ASSIGN_END_DATE
   IF (p_resrc_assign_rec.ASSIGN_END_DATE IS NULL OR p_resrc_assign_rec.ASSIGN_END_DATE = Fnd_Api.G_MISS_DATE)THEN
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_PP_ASSIGN_END_DT_MISSING');
         Fnd_Msg_Pub.ADD;
      END IF;
      x_return_status := Fnd_Api.g_ret_sts_error;
      RETURN;
   END IF;
END Check_Resrc_Assign_Req_Items;

--       Check_Resrc_Assign_UK_Items
PROCEDURE Check_Resrc_Assign_UK_Items (
   p_resrc_assign_rec   IN    Resrc_Assign_Rec_Type,
   p_validation_mode    IN    VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status      OUT   NOCOPY VARCHAR2
)
IS
   l_valid_flag   VARCHAR2(1);
BEGIN
   x_return_status := Fnd_Api.g_ret_sts_success;
   --
   -- For Create_Visit, when ID is passed in, we need to
   -- check if this ID is unique.
   RETURN;
END Check_Resrc_Assign_UK_Items;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Resrc_Assign_Items
--
---------------------------------------------------------------------
PROCEDURE Check_Resrc_Assign_Items (
   p_resrc_assign_rec  IN  Resrc_Assign_Rec_Type,
   p_validation_mode   IN  VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status     OUT NOCOPY VARCHAR2
)
IS
BEGIN
   --
   -- Validate required items.
   Check_Resrc_Assign_Req_Items (
      p_resrc_assign_rec    => p_resrc_assign_rec,
      x_return_status       => x_return_status
   );

   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;

   --
   -- Validate uniqueness.
   Check_Resrc_Assign_UK_Items (
      p_resrc_assign_rec    => p_resrc_assign_rec,
      p_validation_mode     => p_validation_mode,
      x_return_status       => x_return_status
   );

   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_Resrc_Assign_Items;

--------------------------------------------------------------------
-- PROCEDURE
--   Validate_Resrc_Assign
--
--------------------------------------------------------------------
PROCEDURE Validate_Resrc_Assign (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_resrc_assign_rec  IN  Resrc_Assign_Rec_Type,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
)
IS
   L_API_VERSION CONSTANT NUMBER := 1.0;
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Validate_Resrc_Assign';
   L_FULL_NAME   CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   l_return_status       VARCHAR2(1);
   l_assign_start_date   DATE;
   l_assign_end_date     DATE;
   l_eff_st_date             DATE;
   l_eff_end_date            DATE;
   l_actual_start_date       DATE;
   l_actual_end_date         DATE;
   l_scheduled_start_date    DATE;
   l_scheduled_end_date      DATE;

   CURSOR c_emp_date(employee_id IN NUMBER) IS
     SELECT EFFECTIVE_START_DATE, EFFECTIVE_END_DATE FROM
       BOM_RESOURCE_EMPLOYEES
     WHERE PERSON_ID = employee_id;
/*
   CURSOR c_job_date(job_id IN NUMBER) IS
     SELECT TO_DATE(SCHEDULED_START_DATE,'DD-MM-YYYY'), TO_DATE(SCHEDULED_END_DATE,'DD-MM-YYYY'),
            TO_DATE(ACTUAL_START_DATE,'DD-MM-YYYY'), TO_DATE(ACTUAL_END_DATE,'DD-MM-YYYY')
     FROM  AHL_WORKORDERS_V
     WHERE workorder_id = job_id;  */
--
/*   CURSOR c_job_date(job_id IN NUMBER) IS
     SELECT TRUNC(SCHEDULED_START_DATE), TRUNC(SCHEDULED_END_DATE),
            TRUNC(ACTUAL_START_DATE), TRUNC(ACTUAL_END_DATE)
     FROM  AHL_WORKORDERS_V
     WHERE workorder_id = job_id;
*/
--Modified by srini for performance reasons
   CURSOR c_job_date(job_id IN NUMBER) IS
     SELECT TRUNC(WIP.SCHEDULED_START_DATE),
            TRUNC(WIP.SCHEDULED_COMPLETION_DATE) SCHEDULED_END_DATE,
            TRUNC(WO.ACTUAL_START_DATE), TRUNC(WO.ACTUAL_END_DATE)
     FROM  AHL_WORKORDERS WO, WIP_DISCRETE_JOBS WIP
     WHERE WO.wip_entity_id = WIP.wip_entity_id
      AND WO.workorder_id = job_id;



BEGIN
   --------------------- initialize -----------------------
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.enable_debug;
   END IF;

   -- Debug info.
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':Start');
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
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':Check items');
   END IF;

   IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_item THEN
      Check_Resrc_Assign_Items (
         p_resrc_assign_rec   => p_resrc_assign_rec,
         p_validation_mode    => Jtf_Plsql_Api.g_create,
         x_return_status      => l_return_status
      );

      IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;
   END IF;

   --
   -- Use local vars to reduce amount of typing.
   IF p_resrc_assign_rec.assign_start_date IS NOT NULL AND p_resrc_assign_rec.assign_start_date <> Fnd_Api.g_miss_date THEN
    	l_assign_start_date := p_resrc_assign_rec.assign_start_date;
   END IF;

   IF p_resrc_assign_rec.assign_end_date IS NOT NULL AND p_resrc_assign_rec.assign_end_date <> Fnd_Api.g_miss_date THEN
			l_assign_end_date := p_resrc_assign_rec.assign_end_date;
   END IF;

   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   --
   -- Validate the active dates.
		IF l_assign_start_date IS NOT NULL AND l_assign_end_date IS NOT NULL THEN

                  ---End date must be greater than or equal to Start Date

		  IF l_assign_start_date > l_assign_end_date THEN
			IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
				Fnd_Message.set_name ('AHL', 'AHL_PP_ASG_FROMDT_GTR_TODT');
				Fnd_Msg_Pub.ADD;
			 END IF;
			 x_return_status := Fnd_Api.g_ret_sts_error;
			 RETURN;
		  END IF;

                  -----Validate Assignment Dates against Job start-end dates

                  OPEN c_job_date(p_resrc_assign_rec.WORKORDER_ID);
                  FETCH c_job_date INTO l_scheduled_start_date,l_scheduled_end_date,l_actual_start_date, l_actual_end_date;
                  CLOSE c_job_date;

            l_assign_start_date := TRUNC(l_assign_start_date);
            l_assign_end_date   := TRUNC(l_assign_end_date);

		  IF l_actual_start_date is not null or l_actual_end_date is not null THEN

		      IF l_actual_start_date is not null and l_assign_start_date < l_actual_start_date THEN

			IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
				Fnd_Message.set_name ('AHL', 'AHL_PP_ASG_EARLY_ACTUAL');
				Fnd_Msg_Pub.ADD;
			 END IF;
			 x_return_status := Fnd_Api.g_ret_sts_error;
			 RETURN;
		      END IF;

		      IF l_actual_end_date is not null and l_assign_end_date > l_actual_end_date THEN

			IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
				Fnd_Message.set_name ('AHL', 'AHL_PP_ASG_LATER_ACTUAL');
				Fnd_Msg_Pub.ADD;
			 END IF;
			 x_return_status := Fnd_Api.g_ret_sts_error;
			 RETURN;
		      END IF;

	          ELSE

         IF l_scheduled_start_date is not null and l_assign_start_date < l_scheduled_start_date THEN

			IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
				Fnd_Message.set_name ('AHL', 'AHL_PP_ASG_EARLY_SCHEDULE');
				Fnd_Msg_Pub.ADD;
			 END IF;
			 x_return_status := Fnd_Api.g_ret_sts_error;
			 RETURN;
         END IF;

         IF l_scheduled_end_date is not null and l_assign_end_date > l_scheduled_end_date THEN

			IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
				Fnd_Message.set_name ('AHL', 'AHL_PP_ASG_LATER_SCHEDULE');
				Fnd_Msg_Pub.ADD;
			 END IF;
			 x_return_status := Fnd_Api.g_ret_sts_error;
			 RETURN;
		      END IF;

		  END IF;


    	END IF;

        IF p_resrc_assign_rec.employee_id IS NOT NULL THEN
          OPEN c_emp_date(p_resrc_assign_rec.employee_id);
          FETCH c_emp_date INTO l_eff_st_date, l_eff_end_date;
          CLOSE c_emp_date;

   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( 'l_assign_start_date'||l_assign_start_date);
       Ahl_Debug_Pub.debug( 'l_eff_st_date'||l_eff_st_date);

   END IF;
/*
          IF trunc(l_assign_start_date) < trunc(l_eff_st_date) THEN
    		 IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
				Fnd_Message.set_name ('AHL', 'AHL_PP_ASG_STDT_GTR_EMP_STDT');
				Fnd_Msg_Pub.ADD;
			 END IF;
			 x_return_status := Fnd_Api.g_ret_sts_error;
			 RETURN;
          END IF;
*/
          IF trunc(l_assign_end_date) > trunc(l_eff_end_date) THEN
   			 IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
				Fnd_Message.set_name ('AHL', 'AHL_PP_EMP_ENDDT_GTR_ASG_ENDDT');
				Fnd_Msg_Pub.ADD;
			 END IF;
			 x_return_status := Fnd_Api.g_ret_sts_error;
			 RETURN;
          END IF;
        END IF;

   -------------------- finish --------------------------
   Fnd_Msg_Pub.count_and_get (
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':End');
   END IF;

   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.disable_debug;
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
END Validate_Resrc_Assign;

----------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Create_Resrc_Assign
--  Type              : Private
--  Function          : Validates Resource Information and inserts records into
--                      Schedule Resource table for non routine jobs and loads record
--                      into MRP_SCHEDULE_INTERFACE table Launches Concurrent Program to
--                      initiate Resource reservation
--                      Updates schedule Resource table with Assignment id
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Create Resource Assignment Parameters:
--       p_x_resrc_assign_tbl     IN OUT NOCOPY AHL_PP_RESRC_ASSIGN_PVT.Resrc_Assign_Tbl_Type,
--         Contains Resource information to perform Resource reservation
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Create_Resrc_Assign (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := NULL,
    p_x_resrc_assign_tbl     IN OUT NOCOPY Resrc_Assign_Tbl_Type,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2
   )
 IS
 -- Check to see schedule Resource id exists
 CURSOR Sch_id_exists (x_id IN NUMBER) IS
   SELECT 1 FROM dual
    WHERE EXISTS (SELECT 1
                  FROM AHL_WORK_ASSIGNMENTS
                  WHERE ASSIGNMENT_ID = x_id);

 /*CURSOR c_oper_resrc (x_id IN NUMBER, x_oper IN NUMBER, x_resrc IN NUMBER) IS
   SELECT requirement_id, operation_id, resource_id FROM AHL_PP_REQUIREMENT_V
    WHERE job_id = x_id
    AND resource_sequence = x_resrc
    AND operation_sequence = x_oper;
		*/
		 --Modified by Srini for performance fix

 CURSOR c_oper_resrc (x_id IN NUMBER, x_oper IN NUMBER, x_resrc IN NUMBER) IS
  SELECT OPR.operation_resource_id requirement_id ,
         WOP.workorder_operation_id operation_id ,
         OPR.resource_id
   FROM ahl_operation_resources OPR,
        ahl_workorder_operations WOP
   WHERE OPR.workorder_operation_id = WOP.workorder_operation_id
     AND WOP.operation_sequence_num = x_oper
     AND OPR.resource_sequence_num = x_resrc
     AND WOP.workorder_id = x_id;


/*
 CURSOR c_resource (x_oper IN NUMBER, x_res IN NUMBER, x_id IN NUMBER) IS
   SELECT RESOURCE_TYPE_CODE FROM
     AHL_PP_REQUIREMENT_V
   WHERE OPERATION_SEQUENCE = x_oper AND RESOURCE_SEQUENCE = x_res
   AND JOB_ID = x_id;
*/
--Modified by Srini for performance fix
 CURSOR c_resource (x_oper IN NUMBER, x_res IN NUMBER, x_id IN NUMBER) IS
  SELECT resource_type resource_type_code
   FROM ahl_operation_resources OPR,
        ahl_workorder_operations WOP,
        bom_resources BOM
   WHERE OPR.workorder_operation_id = WOP.workorder_operation_id
     AND OPR.resource_id = BOM.resource_id
     AND WOP.operation_sequence_num = x_oper
     AND OPR.resource_sequence_num = x_res
     AND WOP.workorder_id = x_id;

/*
 CURSOR c_assign (x_id IN NUMBER, x_oper IN NUMBER, x_resrc IN NUMBER) IS
   SELECT resource_id FROM AHL_PP_REQUIREMENT_V
    WHERE job_id = x_id
    AND resource_sequence = x_resrc
    AND operation_sequence = x_oper;
	*/
	--Modified by Srini for performance fix
 CURSOR c_assign (x_id IN NUMBER, x_oper IN NUMBER, x_resrc IN NUMBER) IS
   SELECT OPR.resource_id
     FROM ahl_workorder_operations WOP,
          ahl_operation_resources OPR
   WHERE WOP.workorder_operation_id = OPR.workorder_operation_id
    AND WOP.operation_sequence_num = x_oper
    AND OPR.resource_sequence_num = x_resrc
    AND WOP.workorder_id = x_id;

/*
 CURSOR c_work (x_id IN NUMBER) IS
   SELECT wip_entity_id, organization_id,
          department_id FROM AHL_Workorders_V
    WHERE workorder_id = x_id;
	*/
 -- fix bug# 6452479. Dept. should default from Operation dept.
 CURSOR c_work (x_id                IN NUMBER,
                x_operation_seq_num IN NUMBER) IS
   SELECT a.wip_entity_id, wo.organization_id,
          wo.department_id
    FROM AHL_Workorders a, wip_operations wo
    WHERE a.wip_entity_id = wo.wip_entity_id
     AND  wo.operation_seq_num = x_operation_seq_num
     AND a.workorder_id = x_id;
 /*
 --Modified by Srini for performance fix
 CURSOR c_work (x_id IN NUMBER) IS
   SELECT wip_entity_id, organization_id,
          department_id
    FROM AHL_Workorders a, ahl_visits_b b
    WHERE a.visit_id = b.visit_id
     AND workorder_id = x_id;
 */
   --
 CURSOR c_instance_cur (c_person_id IN NUMBER,
                        c_resource_id IN NUMBER,
			c_dept_id   IN NUMBER)
  IS
  SELECT a.instance_id
     FROM BOM_DEPT_RES_INSTANCES A, BOM_RESOURCE_EMPLOYEES B
   WHERE A.INSTANCE_ID = B.INSTANCE_ID
   AND B.PERSON_ID = c_person_id
   AND A.RESOURCE_ID = c_resource_id
   AND A.DEPARTMENT_ID in (
   			SELECT
			  nvl(bdr.SHARE_FROM_DEPT_ID,
			  bdr.department_id)
			FROM
			  bom_department_resources bdr
			WHERE
			  bdr.resource_id = c_resource_id and
			  bdr.department_id = c_dept_id
			);

			-- cursor to get the resource req dates
		/*	CURSOR resrc_req_dates(x_id IN NUMBER, x_oper IN NUMBER, x_resrc IN NUMBER) IS
 				SELECT scheduled_start_date, scheduled_end_date
     FROM ahl_workorder_operations WOP,
          ahl_operation_resources OPR
   WHERE WOP.workorder_operation_id = OPR.workorder_operation_id
    AND WOP.operation_sequence_num = x_oper
    AND OPR.resource_sequence_num = x_resrc
    AND WOP.workorder_id = x_id;
  */

  -- Cursor added by Balaji for Bug # 6728602
  -- Cursor fetches the resource requirement start and end date seconds.
  -- This value is passed to EAM to avoid scheduling hierarchy error.
  -- Bug # 6728602 -- start
  CURSOR c_get_res_sec(p_wo_id IN NUMBER, p_op_seq IN NUMBER)
  IS
  SELECT
     TO_CHAR(WOP.FIRST_UNIT_START_DATE, 'ss'),
     TO_CHAR(WOP.LAST_UNIT_COMPLETION_DATE, 'ss')
  FROM
     wip_operations WOP,
     ahl_workorders AWO
  WHERE
        WOP.OPERATION_SEQ_NUM = p_op_seq
    AND WOP.wip_entity_id = AWO.wip_entity_id
    AND AWO.workorder_id = p_wo_id;

    l_st_date_sec VARCHAR2(30);
    l_end_date_sec VARCHAR2(30);
    l_sec          VARCHAR2(30);
  -- Bug # 6728602 -- end
   --
 l_api_name        CONSTANT VARCHAR2(30) := 'CREATE_Resrc_Assign';
 l_api_version     CONSTANT NUMBER       := 1.0;
 L_FULL_NAME       CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

 l_msg_count                NUMBER;
 l_wo_operation_id          NUMBER;
 l_dummy                    NUMBER;
 l_assignment_id            NUMBER;
 l_serial_id                NUMBER;
 l_oper_resrc_id            NUMBER;
 l_resrc_seq_num            NUMBER;
 l_object_version_number    NUMBER;
 l_process_status           NUMBER;
 l_employee_id              NUMBER;
 l_resource_type            NUMBER;
 l_dept_id                  NUMBER;
 l_resource_id              NUMBER;
 l_instance_id              NUMBER;
 l_wip_entity_id            NUMBER;
 l_organization_id          NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 l_error_message            VARCHAR2(120);
 l_employee_name            VARCHAR2(240);

	/*l_res_start_date            DATE;
 l_res_end_date              DATE;
 */

 l_Resrc_Assign_Tbl         Resrc_Assign_Tbl_Type;
 l_Resrc_Assign_Rec         Resrc_Assign_Rec_Type;
 j NUMBER;
 l_default    VARCHAR2(10);

 l_hour                  VARCHAR2(30);
 l_min                   VARCHAR2(30);
 l_date_time             VARCHAR2(30);

BEGIN
   --------------------Initialize ----------------------------------
   -- Standard Start of API savepoint
   SAVEPOINT Create_Resrc_Assign;

   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;

   -- Debug info.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'Enter AHL_PP_RESRC_ASSIGN_PVT. Create_Resrc_Assign','+PPResrc_Assign_Pvt+');
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

   --------------------Start of API Body-----------------------------------
   --------------------Value OR ID conversion------------------------------
        --Start API Body

  IF p_x_resrc_assign_tbl.COUNT > 0 THEN
	 FOR i IN p_x_resrc_assign_tbl.FIRST..p_x_resrc_assign_tbl.LAST LOOP
       --
      IF p_module_type = 'JSP' THEN
         p_x_resrc_assign_tbl(i).instance_id     := NULL;
         p_x_resrc_assign_tbl(i).employee_id      := NULL;
      END IF;

       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'Workorder ID = ' || p_x_resrc_assign_tbl(i).workorder_id);
          AHL_DEBUG_PUB.debug( 'Oper Seq Num = ' || p_x_resrc_assign_tbl(i).operation_seq_number);
          AHL_DEBUG_PUB.debug( 'Resrc Seq Num = ' || p_x_resrc_assign_tbl(i).resource_seq_number);
       END IF;
       --
        IF p_x_resrc_assign_tbl(i).workorder_id IS NOT NULL THEN
           IF p_x_resrc_assign_tbl(i).operation_seq_number IS NOT NULL AND
              p_x_resrc_assign_tbl(i).operation_seq_number <> FND_API.G_MISS_NUM AND
              p_x_resrc_assign_tbl(i).resource_seq_number IS NOT NULL AND
              p_x_resrc_assign_tbl(i).resource_seq_number <> FND_API.G_MISS_NUM THEN
                    OPEN c_oper_resrc(p_x_resrc_assign_tbl(i).workorder_id, p_x_resrc_assign_tbl(i).operation_seq_number,
					                  p_x_resrc_assign_tbl(i).resource_seq_number);
                    FETCH c_oper_resrc INTO l_oper_resrc_id, l_wo_operation_id,l_resource_id;
                            IF c_oper_resrc%NOTFOUND THEN
                                  AHL_DEBUG_PUB.debug(l_full_name || 'c_oper_resrc i.e Cursor not found');
                                  Fnd_Message.SET_NAME('AHL','AHL_PP_RESRC_REQ_NOT_EXISTS');
                                  Fnd_Msg_Pub.ADD;
                                  RAISE Fnd_Api.G_EXC_ERROR;
                            END IF;
                    CLOSE c_oper_resrc;

           END IF; -- Check resrc sequence number
        ELSE
           Fnd_Message.SET_NAME('AHL','AHL_PP_JOB_NOT_EXISTS');
           Fnd_Msg_Pub.ADD;
        END IF; -- Check of work order id

	-- rroy
	-- ACL Changes
	l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => p_x_resrc_assign_tbl(i).workorder_id,
								p_ue_id => NULL,
								p_visit_id => NULL,
								p_item_instance_id => NULL);
	IF l_return_status = FND_API.G_TRUE THEN
           FND_MESSAGE.Set_Name('AHL', 'AHL_PP_CRT_RESASG_UNTLCKD');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
	-- rroy
	-- ACL Changes

        IF G_DEBUG='Y' THEN
         Ahl_Debug_Pub.debug( 'l_oper_resrc_id = ' ||  l_oper_resrc_id);
         Ahl_Debug_Pub.debug( 'l_wo_operation_id = ' || l_wo_operation_id);
         END IF;

        -- For Resource Type
        OPEN c_resource(p_x_resrc_assign_tbl(i).operation_seq_number, p_x_resrc_assign_tbl(i).resource_seq_number,
		                p_x_resrc_assign_tbl(i).workorder_id);
        FETCH c_resource INTO l_resource_type;
        IF c_resource%FOUND THEN
            IF G_DEBUG='Y' THEN
             AHL_DEBUG_PUB.debug(l_full_name || 'c_resource i.e Cursor found');
             END IF;

		     CLOSE c_resource;
            p_x_resrc_assign_tbl(i).resource_type_code := l_resource_type;
        ELSE
            IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.debug(l_full_name || 'c_resource i.e Cursor not found');
            END IF;

		    CLOSE c_resource;
            Fnd_Message.SET_NAME('AHL','AHL_PP_NO_RES_TYPE_FOUND');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

         Ahl_Debug_Pub.debug( 'l_resource_type = ' || l_resource_type);
         Ahl_Debug_Pub.debug( 'p_x_resrc_assign_tbl(i).instance_id = ' || p_x_resrc_assign_tbl(i).instance_id);
         Ahl_Debug_Pub.debug( 'p_x_resrc_assign_tbl(i).serial_number = ' || p_x_resrc_assign_tbl(i).serial_number);

		-- R12
		-- Alignment to resource requirement dates is no longer required since
		-- assignment times can now be entered by the user

		-- to align the assignment dates to the resource req dates
		--Required to check the operation start dates and resource start and end date are same
  /*OPEN resrc_req_dates(p_x_resrc_assign_tbl(i).workorder_id,
																							p_x_resrc_assign_tbl(i).operation_seq_number,
					                  p_x_resrc_assign_tbl(i).resource_seq_number);

		FETCH resrc_req_dates INTO l_res_start_date,l_res_end_date;
  CLOSE resrc_req_dates;
  --Validation is required to include resource timestamp for Requested start date
		-- requested end date
		IF  (TRUNC(p_x_resrc_assign_tbl(i).assign_start_date) = TRUNC(l_res_start_date )
		    AND
			TRUNC(p_x_resrc_assign_tbl(i).assign_end_date) = TRUNC(l_res_start_date ))
		THEN

		     p_x_resrc_assign_tbl(i).assign_start_date := l_res_start_date;
		     p_x_resrc_assign_tbl(i).assign_end_date := l_res_start_date;

		ELSIF (TRUNC(p_x_resrc_assign_tbl(i).assign_start_date) = TRUNC(l_res_end_date)
		     AND
			 TRUNC(p_x_resrc_assign_tbl(i).assign_end_date) = TRUNC(l_res_end_date )) THEN

		     p_x_resrc_assign_tbl(i).assign_start_date := l_res_end_date;
		     p_x_resrc_assign_tbl(i).assign_end_date := l_res_end_date;

        ELSIF (TRUNC(p_x_resrc_assign_tbl(i).assign_start_date) = TRUNC(l_res_start_date )
		    AND
			TRUNC(p_x_resrc_assign_tbl(i).assign_end_date) <> TRUNC(l_res_start_date )) THEN

		     p_x_resrc_assign_tbl(i).assign_start_date := l_res_start_date;

        ELSIF (TRUNC(p_x_resrc_assign_tbl(i).assign_start_date) <> TRUNC(l_res_start_date )
		    AND
			TRUNC(p_x_resrc_assign_tbl(i).assign_end_date) = TRUNC(l_res_end_date )) THEN

		     p_x_resrc_assign_tbl(i).assign_end_date := l_res_end_date;

		END IF;
		*/
		-- Bug # 6728602 -- start
		OPEN c_get_res_sec(
		                  p_x_resrc_assign_tbl(i).workorder_id,
		                  p_x_resrc_assign_tbl(i).operation_seq_number
		                  );
		FETCH c_get_res_sec INTO l_st_date_sec,l_end_date_sec;
		CLOSE c_get_res_sec;
                -- Bug # 6728602 -- end
		-- R12
		-- Take into account the start and end times
		IF p_x_resrc_assign_tbl(i).assign_start_date IS NOT NULL THEN
		  IF p_x_resrc_assign_tbl(i).assign_start_hour IS NULL THEN
		    l_hour := ':00';
		  ELSE
		    l_hour := ':' || p_x_resrc_assign_tbl(i).assign_start_hour;
		  END IF;

		  IF p_x_resrc_assign_tbl(i).assign_start_min IS NULL THEN
		    l_min := ':00';
		  ELSE
		    l_min := ':' || p_x_resrc_assign_tbl(i).assign_start_min;
	  	END IF;

                  -- Bug # 6728602 -- start
                  l_sec := TO_CHAR(p_x_resrc_assign_tbl(i).assign_start_date, 'ss');

		  IF(l_sec = '00') THEN
		      l_sec := ':' ||l_st_date_sec;
		  END IF;

                l_date_time := TO_CHAR(p_x_resrc_assign_tbl(i).assign_start_date, 'DD-MM-YYYY')||' '|| l_hour || l_min || l_sec;
                p_x_resrc_assign_tbl(i).assign_start_date := TO_DATE(l_date_time , 'DD-MM-YYYY :HH24:MI:SS');
                -- Bug # 6728602 -- end
  END IF;

		IF p_x_resrc_assign_tbl(i).assign_end_date IS NOT NULL THEN
		  IF p_x_resrc_assign_tbl(i).assign_end_hour IS NULL THEN
		    l_hour := ':00';
		  ELSE
		    l_hour := ':' || p_x_resrc_assign_tbl(i).assign_end_hour;
		  END IF;

		  IF p_x_resrc_assign_tbl(i).assign_end_min IS NULL THEN
		    l_min := ':00';
		  ELSE
		    l_min := ':' || p_x_resrc_assign_tbl(i).assign_end_min;
		  END IF;

                  -- Bug # 6728602 -- start
                  l_sec := TO_CHAR(p_x_resrc_assign_tbl(i).assign_end_date, 'ss');

    		  IF(l_sec = '00') THEN
    		      l_sec := ':' ||l_end_date_sec;
    		  END IF;

		  l_date_time := TO_CHAR(p_x_resrc_assign_tbl(i).assign_end_date, 'DD-MM-YYYY')||' '|| l_hour || l_min || l_sec;
                  p_x_resrc_assign_tbl(i).assign_end_date := TO_DATE(l_date_time , 'DD-MM-YYYY :HH24:MI:SS');
                  -- Bug # 6728602 -- end
  END IF;


		    --Get org,dept,wip entity id
            OPEN c_work (p_x_resrc_assign_tbl(i).workorder_id,
                         p_x_resrc_assign_tbl(i).operation_seq_number);
            FETCH c_work INTO l_wip_entity_id,l_organization_id,l_dept_id;
            CLOSE c_work;
            --Assign
	        p_x_resrc_assign_tbl(i).wip_entity_id := l_wip_entity_id;
			p_x_resrc_assign_tbl(i).organization_id := l_organization_id;
			p_x_resrc_assign_tbl(i).department_id := l_dept_id;
			p_x_resrc_assign_tbl(i).oper_resource_id := l_oper_resrc_id;

            IF (G_DEBUG = 'Y') THEN
                 AHL_DEBUG_PUB.debug(l_full_name || 'Organization ID:' || p_x_resrc_assign_tbl(i).organization_id);
                 AHL_DEBUG_PUB.debug(l_full_name || 'Dept ID:' || p_x_resrc_assign_tbl(i).department_id);
                 AHL_DEBUG_PUB.debug(l_full_name || 'Serial:' || p_x_resrc_assign_tbl(i).serial_number);
            END IF;

       IF l_resource_type <> 2 THEN
          /*IF ((l_Resrc_Assign_Rec.employee_number IS NOT NULL AND l_Resrc_Assign_Rec.employee_number <> Fnd_Api.G_MISS_CHAR)
              Ot
														(l_Resrc_Assign_Rec.employee_name IS NOT NULL AND l_Resrc_Assign_Rec.employee_name <> Fnd_Api.G_MISS_CHAR))
          THEN
              Fnd_Message.SET_NAME('AHL','AHL_PP_EMPLOYEE_NOT_REQ');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.G_EXC_ERROR;
          END IF;*/

           -- Convert serial number to instance/ serial id
          IF (p_x_resrc_assign_tbl(i).serial_number IS NOT NULL AND
              p_x_resrc_assign_tbl(i).serial_number <> Fnd_Api.G_MISS_CHAR ) THEN

              OPEN c_assign (p_x_resrc_assign_tbl(i).workorder_id, p_x_resrc_assign_tbl(i).operation_seq_number,
			                 p_x_resrc_assign_tbl(i).resource_seq_number);
              FETCH c_assign INTO l_resource_id;
              CLOSE c_assign;
			  --
             Check_Serial_Name_Or_Id
               (p_serial_id        => p_x_resrc_assign_tbl(i).instance_id,
                p_serial_number    => p_x_resrc_assign_tbl(i).serial_number,
                p_workorder_id     => p_x_resrc_assign_tbl(i).workorder_id,
                p_resource_id      => l_resource_id,
                p_dept_id          => l_dept_id,
		p_organization_id  => l_organization_id,
                x_instance_id       => l_instance_id,
                x_return_status    => l_return_status,
                x_error_msg_code   => l_msg_data);

              IF G_DEBUG='Y' THEN
              Ahl_Debug_Pub.debug( l_full_name ||'Status Serial' || l_return_status );
              END IF;

              IF NVL(l_return_status,'x') <> 'S'
              THEN
                  Fnd_Message.SET_NAME('AHL','AHL_PP_SERIAL_NOT_EXISTS');
                  Fnd_Msg_Pub.ADD;
                  RAISE Fnd_Api.G_EXC_ERROR;
              END IF;
         END IF;

         --Assign the returned value
         p_x_resrc_assign_tbl(i).instance_id := l_instance_id;
         p_x_resrc_assign_tbl(i).oper_resource_id := l_oper_resrc_id;

        IF G_DEBUG='Y' THEN
        Ahl_Debug_Pub.debug(': Serial Id After= ' || p_x_resrc_assign_tbl(i).instance_id);
        END IF;

    END IF;
        IF G_DEBUG='Y' THEN
        Ahl_Debug_Pub.debug( ': Employee Name = ' || p_x_resrc_assign_tbl(i).employee_name);
        Ahl_Debug_Pub.debug( ': EMployee Number = ' || p_x_resrc_assign_tbl(i).employee_number);
        END IF;

    IF l_resource_type = 2 THEN
         IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.debug(l_full_name || 'RESOURCE TYPE in Cursor' || l_resource_type);
         END IF;

         /*IF (l_Resrc_Assign_Rec.serial_number IS NOT NULL AND l_Resrc_Assign_Rec.serial_number <> Fnd_Api.G_MISS_CHAR)
         THEN
              Fnd_Message.SET_NAME('AHL','AHL_PP_EMPLOYEE_NOT_REQ');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.G_EXC_ERROR;
         END IF;*/
        IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug(l_full_name || 'RESOURCE TYPE in record -- ' || p_x_resrc_assign_tbl(i).resource_type_code);
        END IF;

        -- For Employee Number
        IF (p_x_resrc_assign_tbl(i).employee_number IS NOT NULL AND p_x_resrc_assign_tbl(i).employee_number <> Fnd_Api.G_MISS_CHAR)
         THEN
              IF G_DEBUG='Y' THEN
             Ahl_Debug_Pub.debug(': Inside EMployee Number = ' || p_x_resrc_assign_tbl(i).employee_number);
			 END IF;

             Check_Employee_Number_Or_Id
                 (p_employee_id      => p_x_resrc_assign_tbl(i).employee_id,
                  p_employee_number  => p_x_resrc_assign_tbl(i).employee_number,
                  p_workorder_id     => p_x_resrc_assign_tbl(i).workorder_id,
                  p_oper_resrc_id    => l_oper_resrc_id,
                  p_resource_id      => l_resource_id,
                  p_organization_id  => l_organization_id,
                  x_employee_id      => p_x_resrc_assign_tbl(i).employee_id,
                  x_return_status    => l_return_status,
                  x_error_msg_code   => l_msg_data
                  );

             IF NVL(l_return_status, 'X') <> 'S'
             THEN
                  Fnd_Message.SET_NAME('AHL','AHL_PP_EMP_NUM_NOT_EXISTS');
                  Fnd_Msg_Pub.ADD;
                  RAISE Fnd_Api.G_EXC_ERROR;
             END IF;

        END IF;

        -- For Employee Name
        IF (p_x_resrc_assign_tbl(i).employee_name IS NOT NULL AND p_x_resrc_assign_tbl(i).employee_name <> Fnd_Api.G_MISS_CHAR)
        THEN
                  IF G_DEBUG='Y' THEN
                     Ahl_Debug_Pub.debug( l_full_name ||': Inside Employee Name = ' || p_x_resrc_assign_tbl(i).employee_name);
                  END IF;
	               Check_Employee_Name_Or_Id
                         (p_employee_id      => l_employee_id,
                          p_employee_number  => p_x_resrc_assign_tbl(i).employee_number,
                          p_workorder_id     => p_x_resrc_assign_tbl(i).workorder_id,
                          p_oper_resrc_id    => l_oper_resrc_id,
			  p_resource_id      => l_resource_id,
			  p_organization_id  => l_organization_id,
                          x_employee_name    => l_employee_name,
                          x_employee_id      => l_employee_id,
                          x_return_status    => l_return_status,
                          x_error_msg_code   => l_msg_data
                          );

                     IF NVL(l_return_status, 'X') <> 'S'
                     THEN
                          Fnd_Message.SET_NAME('AHL','AHL_PP_EMP_NAME_NOT_EXISTS');
                          Fnd_Msg_Pub.ADD;
                          RAISE Fnd_Api.G_EXC_ERROR;
                     END IF;

                     IF p_x_resrc_assign_tbl(i).employee_id <> l_employee_id THEN
                          Fnd_Message.SET_NAME('AHL','AHL_PP_USE_EMP_NAME_LOV');
                          Fnd_Msg_Pub.ADD;
                     END IF;

                     IF p_x_resrc_assign_tbl(i).employee_name <> l_employee_name THEN
                          Fnd_Message.SET_NAME('AHL','AHL_PP_EMP_NAME_NOT_EXISTS');
                          Fnd_Msg_Pub.ADD;
                     END IF;

                     --
                     p_x_resrc_assign_tbl(i).employee_id := l_employee_id;
        END IF;

          -- Get instance id
          IF (p_x_resrc_assign_tbl(i).employee_id IS NOT NULL AND p_x_resrc_assign_tbl(i).employee_id <> Fnd_Api.G_MISS_NUM)
           THEN
		   --
           OPEN c_instance_cur (p_x_resrc_assign_tbl(i).employee_id,
                                l_resource_id, p_x_resrc_assign_tbl(i).department_id);
           FETCH c_instance_cur INTO p_x_resrc_assign_tbl(i).instance_id;
           CLOSE c_instance_cur;
           --
          END IF;
        END IF;

        IF G_DEBUG='Y' THEN
          Ahl_Debug_Pub.debug(l_full_name || ': Instance Id After= ' || p_x_resrc_assign_tbl(i).instance_id);
          Ahl_Debug_Pub.debug(l_full_name || ': Employee Id= ' || p_x_resrc_assign_tbl(i).employee_id);
        END IF;

      -------------------------------- Validate -----------------------------------------
             IF G_DEBUG='Y' THEN
             Ahl_Debug_Pub.debug( l_full_name ||': Before Validate Assignment');
			 END IF;

             Validate_Resrc_Assign (
                  p_api_version        => l_api_version,
                  p_init_msg_list      => p_init_msg_list,
                  p_commit             => p_commit,
                  p_validation_level   => p_validation_level,
                  p_resrc_assign_rec   => p_x_resrc_assign_tbl(i),
                  x_return_status      => l_return_status,
                  x_msg_count          => x_msg_count,
                  x_msg_data           => x_msg_data
             );

  END LOOP;
  END IF;
       --Standard check to count messages
       l_msg_count := Fnd_Msg_Pub.count_msg;

       IF l_msg_count > 0 THEN
          X_msg_count := l_msg_count;
          X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
       END IF;
-- Call Eam Api to create resource assignment in WIP
  IF p_x_resrc_assign_tbl.COUNT > 0 THEN
    j := 1;
    FOR i IN p_x_resrc_assign_tbl.FIRST..p_x_resrc_assign_tbl.LAST
	  LOOP
      --
  IF G_DEBUG='Y' THEN
  Ahl_Debug_Pub.debug ('p_x_resrc_assign_tbl(i).wip_entity_id' ||p_x_resrc_assign_tbl(i).wip_entity_id  );
  Ahl_Debug_Pub.debug ('p_x_resrc_assign_tbl(i).organization_id' ||p_x_resrc_assign_tbl(i).organization_id );
  Ahl_Debug_Pub.debug ('p_x_resrc_assign_tbl(i).operation_seq_number' ||p_x_resrc_assign_tbl(i).operation_seq_number );
  Ahl_Debug_Pub.debug ('p_x_resrc_assign_tbl(i).resource_seq_number' ||p_x_resrc_assign_tbl(i).resource_seq_number );
  Ahl_Debug_Pub.debug ('p_x_resrc_assign_tbl(i).instance_id' ||p_x_resrc_assign_tbl(i).instance_id );
  Ahl_Debug_Pub.debug ('p_x_resrc_assign_tbl(i).serial_number' ||p_x_resrc_assign_tbl(i).serial_number );

  END IF;

	   --
       l_resrc_assign_tbl(j).WIP_ENTITY_ID           := p_x_resrc_assign_tbl(i).wip_entity_id;
       l_resrc_assign_tbl(j).ORGANIZATION_ID         := p_x_resrc_assign_tbl(i).organization_id;
       l_resrc_assign_tbl(j).WORKORDER_ID            := p_x_resrc_assign_tbl(i).workorder_id;
       l_resrc_assign_tbl(j).OPERATION_SEQ_NUMBER    := p_x_resrc_assign_tbl(i).operation_seq_number;
       l_resrc_assign_tbl(j).RESOURCE_SEQ_NUMBER     := p_x_resrc_assign_tbl(i).resource_seq_number;
       l_resrc_assign_tbl(j).INSTANCE_ID             := p_x_resrc_assign_tbl(i).instance_id;
       l_resrc_assign_tbl(j).SERIAL_NUMBER           := p_x_resrc_assign_tbl(i).serial_number;
       l_resrc_assign_tbl(j).ASSIGN_START_DATE       := p_x_resrc_assign_tbl(i).assign_start_date;
       l_resrc_assign_tbl(j).ASSIGN_END_DATE         := p_x_resrc_assign_tbl(i).assign_end_date;
       l_resrc_assign_tbl(j).OPERATION_FLAG          := 'C';

	   j := j + 1;
	   --
	 END LOOP;
	 --
	END IF;
    --Call AHL Eam Job Pvt

    AHL_EAM_JOB_PVT.process_resource_assign
           (
            p_api_version           => l_api_version,
            p_init_msg_list         => p_init_msg_list,
            p_commit                => p_commit,
            p_validation_level      => p_validation_level,
            p_default               => l_default,
            p_module_type           => p_module_type,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data,
            p_resource_assign_tbl   => l_resrc_assign_tbl);

    --
IF l_return_status = 'S' THEN
  IF p_x_resrc_assign_tbl.COUNT > 0 THEN
   FOR i IN p_x_resrc_assign_tbl.FIRST..p_x_resrc_assign_tbl.LAST LOOP
    IF  p_x_resrc_assign_tbl(i).Assignment_id is null or p_x_resrc_assign_tbl(i).Assignment_id = FND_API.G_MISS_NUM
    THEN
          -- These conditions are required for optional fields
          -- Employee Id
          IF p_x_resrc_assign_tbl(i).Employee_id = FND_API.G_MISS_NUM
          THEN
           l_resrc_assign_tbl(i).Employee_id := NULL;
		   ELSE
		   l_resrc_assign_tbl(i).Employee_id := p_x_resrc_assign_tbl(i).Employee_id;
          END IF;

          -- Serial Number
          IF p_x_resrc_assign_tbl(i).Serial_Number = FND_API.G_MISS_CHAR
          THEN
           l_resrc_assign_tbl(i).Serial_Number := NULL;
		   ELSE
		   l_resrc_assign_tbl(i).Serial_Number := p_x_resrc_assign_tbl(i).Serial_Number;
          END IF;
          -- Instance Id
          IF p_x_resrc_assign_tbl(i).Instance_id = FND_API.G_MISS_NUM
          THEN
           l_resrc_assign_tbl(i).Instance_id := NULL;
		   ELSE
           l_resrc_assign_tbl(i).Instance_id := p_x_resrc_assign_tbl(i).Instance_id;
          END IF;
          -- Last Updated Date
          IF p_x_resrc_assign_tbl(i).last_update_login = FND_API.G_MISS_NUM
          THEN
           l_resrc_assign_tbl(i).last_update_login := NULL;
		   ELSE
           l_resrc_assign_tbl(i).last_update_login := p_x_resrc_assign_tbl(i).last_update_login;
          END IF;
          -- Attribute Category
          IF p_x_resrc_assign_tbl(i).attribute_category = FND_API.G_MISS_CHAR
          THEN
           l_resrc_assign_tbl(i).attribute_category := NULL;
		   ELSE
           l_resrc_assign_tbl(i).attribute_category := p_x_resrc_assign_tbl(i).attribute_category;
          END IF;
          -- Attribute1
          IF p_x_resrc_assign_tbl(i).attribute1 = FND_API.G_MISS_CHAR
          THEN
           l_resrc_assign_tbl(i).attribute1 := NULL;
          ELSE
           l_Resrc_Assign_tbl(i).attribute1 := p_x_Resrc_Assign_tbl(i).attribute1;
          END IF;
          -- Attribute2
          IF p_x_resrc_assign_tbl(i).attribute2 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Assign_tbl(i).attribute2 := NULL;
          ELSE
           l_Resrc_Assign_tbl(i).attribute2 := p_x_resrc_assign_tbl(i).attribute2;
          END IF;
          -- Attribute3
          IF p_x_resrc_assign_tbl(i).attribute3 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Assign_tbl(i).attribute3 := NULL;
          ELSE
           l_Resrc_Assign_tbl(i).attribute3 := p_x_resrc_assign_tbl(i).attribute3;
          END IF;
          -- Attribute4
          IF p_x_resrc_assign_tbl(i).attribute4 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Assign_tbl(i).attribute4 := NULL;
          ELSE
           l_Resrc_Assign_tbl(i).attribute4 := p_x_resrc_assign_tbl(i).attribute4;
          END IF;
          -- Attribute5
          IF p_x_resrc_assign_tbl(i).attribute5 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Assign_tbl(i).attribute5 := NULL;
          ELSE
           l_Resrc_Assign_tbl(i).attribute5 := p_x_resrc_assign_tbl(i).attribute5;
          END IF;
          -- Attribute6
          IF p_x_resrc_assign_tbl(i).attribute6 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Assign_tbl(i).attribute6 := NULL;
          ELSE
           l_Resrc_Assign_tbl(i).attribute6 := p_x_resrc_assign_tbl(i).attribute6;
          END IF;
          -- Attribute7
          IF p_x_resrc_assign_tbl(i).attribute7 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Assign_tbl(i).attribute7 := NULL;
          ELSE
           l_Resrc_Assign_tbl(i).attribute7 := p_x_resrc_assign_tbl(i).attribute7;
          END IF;
          -- Attribute8
          IF p_x_resrc_assign_tbl(i).attribute8 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Assign_tbl(i).attribute8 := NULL;
          ELSE
           l_Resrc_Assign_tbl(i).attribute8 := p_x_resrc_assign_tbl(i).attribute8;
          END IF;
          -- Attribute9
          IF p_x_resrc_assign_tbl(i).attribute9 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Assign_tbl(i).attribute9 := NULL;
          ELSE
           l_Resrc_Assign_tbl(i).attribute9 := p_x_resrc_assign_tbl(i).attribute9;
          END IF;
          -- Attribute10
          IF p_x_resrc_assign_tbl(i).attribute10 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Assign_tbl(i).attribute10 := NULL;
          ELSE
           l_Resrc_Assign_tbl(i).attribute10 := p_x_resrc_assign_tbl(i).attribute10;
          END IF;
          -- Attribute11
          IF p_x_resrc_assign_tbl(i).attribute11 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Assign_tbl(i).attribute11 := NULL;
          ELSE
           l_Resrc_Assign_tbl(i).attribute11 := p_x_resrc_assign_tbl(i).attribute11;
          END IF;
          -- Attribute12
          IF p_x_resrc_assign_tbl(i).attribute12 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Assign_tbl(i).attribute12 := NULL;
          ELSE
           l_Resrc_Assign_tbl(i).attribute12 := p_x_resrc_assign_tbl(i).attribute12;
          END IF;
          -- Attribute13
          IF p_x_resrc_assign_tbl(i).attribute13 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Assign_tbl(i).attribute13 := NULL;
          ELSE
           l_Resrc_Assign_tbl(i).attribute13 := p_x_resrc_assign_tbl(i).attribute13;
          END IF;
          -- Attribute14
          IF p_x_resrc_assign_tbl(i).attribute14 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Assign_tbl(i).attribute14 := NULL;
          ELSE
           l_Resrc_Assign_tbl(i).attribute14 := p_x_resrc_assign_tbl(i).attribute14;
          END IF;
          -- Attribute15
          IF p_x_resrc_assign_tbl(i).attribute15 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Assign_tbl(i).attribute15 := NULL;
          ELSE
           l_Resrc_Assign_tbl(i).attribute15 := p_x_resrc_assign_tbl(i).attribute15;
          END IF;

       --Standard check to count messages
       l_msg_count := Fnd_Msg_Pub.count_msg;

       IF l_msg_count > 0 THEN
          X_msg_count := l_msg_count;
          X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
       END IF;

        --
        -- Get Sequence Number for Resource Assignment ID
        SELECT AHL_WORK_ASSIGNMENTS_S.NEXTVAL
                  INTO l_assignment_id FROM DUAL;

        --Check for Record Exists
        OPEN Sch_id_exists(l_assignment_id);
        FETCH Sch_id_exists INTO l_dummy;
        CLOSE Sch_id_exists;
        --
        IF l_dummy IS NOT NULL THEN
           Fnd_Message.SET_NAME('AHL','AHL_PP_SEQUENCE_NO_EXISTS');
           Fnd_Msg_Pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;


          -- Create Record in schedule Resources
             Insert_Row (
                   X_ASSIGNMENT_ID         => l_assignment_id,
                   X_OBJECT_VERSION_NUMBER => 1,
                   X_LAST_UPDATE_DATE      => SYSDATE,
                   X_LAST_UPDATED_BY       => fnd_global.user_id,
                   X_CREATION_DATE         => SYSDATE,
                   X_CREATED_BY            => fnd_global.user_id,
                   X_LAST_UPDATE_LOGIN     => fnd_global.login_id,
                   X_OPERATION_RESOURCE_ID => p_x_resrc_assign_tbl(i).oper_resource_id,
                   X_EMPLOYEE_ID           => l_Resrc_Assign_tbl(i).employee_id,
                   X_SERIAL_NUMBER         => l_Resrc_Assign_tbl(i).serial_number,
                   X_INSTANCE_ID           => l_Resrc_Assign_tbl(i).instance_id,
                   X_ASSIGN_START_DATE     => p_x_resrc_assign_tbl(i).assign_start_date,
                   X_ASSIGN_END_DATE       => p_x_resrc_assign_tbl(i).assign_end_date,
		   X_SELF_ASSIGNED_FLAG    => p_x_resrc_assign_tbl(i).self_assigned_flag,
		   -- X_LOGIN_DATE            => p_x_resrc_assign_tbl(i).login_date,
                   X_ATTRIBUTE_CATEGORY    => l_Resrc_Assign_tbl(i).attribute_category,
                   X_ATTRIBUTE1            => l_Resrc_Assign_tbl(i).attribute1,
                   X_ATTRIBUTE2            => l_Resrc_Assign_tbl(i).attribute2,
                   X_ATTRIBUTE3            => l_Resrc_Assign_tbl(i).attribute3,
                   X_ATTRIBUTE4            => l_Resrc_Assign_tbl(i).attribute4,
                   X_ATTRIBUTE5            => l_Resrc_Assign_tbl(i).attribute5,
                   X_ATTRIBUTE6            => l_Resrc_Assign_tbl(i).attribute6,
                   X_ATTRIBUTE7            => l_Resrc_Assign_tbl(i).attribute7,
                   X_ATTRIBUTE8            => l_Resrc_Assign_tbl(i).attribute8,
                   X_ATTRIBUTE9            => l_Resrc_Assign_tbl(i).attribute9,
                   X_ATTRIBUTE10           => l_Resrc_Assign_tbl(i).attribute10,
                   X_ATTRIBUTE11           => l_Resrc_Assign_tbl(i).attribute11,
                   X_ATTRIBUTE12           => l_Resrc_Assign_tbl(i).attribute12,
                   X_ATTRIBUTE13           => l_Resrc_Assign_tbl(i).attribute13,
                   X_ATTRIBUTE14           => l_Resrc_Assign_tbl(i).attribute14,
                   X_ATTRIBUTE15           => l_Resrc_Assign_tbl(i).attribute15
                  );

               p_x_resrc_assign_tbl(i).ASSIGNMENT_ID :=  l_assignment_id;
               p_x_resrc_assign_tbl(i)               := l_Resrc_Assign_tbl(i);
     END IF;

    END LOOP;
	END IF; -- Count > 0
END IF; -- Return status from Eam Api
   ------------------------End of Body---------------------------------------
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
   -- Debug info
  IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of public api Create Resource Reqst','+PPResrc_Assign_Pvt+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_Resrc_Assign;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

       IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'ERROR' );
        --AHL_DEBUG_PUB.debug( 'ahl_ltp_pp_Resources_pvt. Create Resource Reqst','+PPResrc_Assign_Pvt+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
       END IF;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Resrc_Assign;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_pp_Resources_pvt. Create Resource Reqst','+PPResrc_Assign_Pvt+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
        END IF;

WHEN OTHERS THEN
    ROLLBACK TO Create_Resrc_Assign;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_PP_RESRC_ASSIGN_PVT',
                            p_procedure_name  =>  'CREATE_Resrc_Assign',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
              x_msg_count, x_msg_data, 'SQL ERROR' );
        --AHL_DEBUG_PUB.debug( 'ahl_ltp_pp_Resources_pvt. Create Resource Reqst','+PPResrc_Assign_Pvt+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
        END IF;

END Create_Resrc_Assign;

--------------------------------------------------------------------------------------
--
-- Start of Comments --
--  Procedure name    : Update_Resrc_Assign
--  Type              : Private
--  Function          : Validates Resource Information and modify records into
--                      Schedule Resource table for non routine jobs and loads record
--                      into MRP_SCHEDULE_INTERFACE table Launches Concurrent Program to
--                      initiate Resource reservation
--                      Updates Resource table with Assignment Id
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Update Resource Assignment Parameters:
--       p_x_resrc_assign_tbl     IN OUT NOCOPY AHL_PP_RESRC_ASSIGN_PVT.Resrc_Assign_Tbl_Type,
--         Contains Resource information to perform Resource reservation
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Update_Resrc_Assign (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := NULL,
    p_x_resrc_assign_tbl     IN OUT NOCOPY Resrc_Assign_Tbl_Type,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2
   )
 IS
-- To find all information from AHL_OPERATION_RESOURCES view
  CURSOR c_assign (x_id IN NUMBER) IS
   SELECT * FROM AHL_WORK_ASSIGNMENTS
   WHERE ASSIGNMENT_ID = x_id;
   c_assign_rec c_assign%ROWTYPE;

  /*CURSOR c_resource (x_id IN NUMBER) IS
    SELECT * FROM AHL_PP_ASSIGNMENT_V
    WHERE ASSIGNMENT_ID = x_id;
			*/
			--Modified by Srini for Performance fix
 CURSOR c_resource (x_id IN NUMBER) IS
  SELECT WOA.operation_resource_id requirement_id,
         WOP.workorder_id job_id,
         BOM.resource_type resource_type_code,
         OPR.resource_id
  FROM ahl_operation_resources OPR,
       ahl_work_assignments WOA,
       ahl_workorder_operations WOP,
       bom_resources BOM
  WHERE OPR.operation_resource_id = WOA.operation_resource_id
    AND OPR.workorder_operation_id = WOP.workorder_operation_id
    AND OPR.resource_id = BOM.resource_id
    AND WOA.assignment_id = x_id;

   c_resource_rec c_resource%ROWTYPE;

  /*CURSOR c_assign1 (x_id IN NUMBER, x_oper IN NUMBER, x_resrc IN NUMBER) IS
   SELECT resource_id FROM AHL_PP_REQUIREMENT_V
    WHERE job_id = x_id
    AND resource_sequence = x_resrc
    AND operation_sequence = x_oper;
				*/
				--Modified by Srini for Performance fix
  CURSOR c_assign1 (x_id IN NUMBER, x_oper IN NUMBER, x_resrc IN NUMBER) IS
   SELECT OPR.resource_id
     FROM ahl_workorder_operations WOP,
          ahl_operation_resources OPR
   WHERE WOP.workorder_operation_id = OPR.workorder_operation_id
    AND WOP.operation_sequence_num = x_oper
    AND OPR.resource_sequence_num = x_resrc
    AND WOP.workorder_id = x_id;


  /*CURSOR c_work (x_id IN NUMBER) IS
   SELECT wip_entity_id,organization_id,
         department_id FROM AHL_Workorders_V
    WHERE workorder_id = x_id;
  */
  -- Fix for bug# 6452479.
  -- Get Dept ID from WIP Operations.
  CURSOR c_work (x_id                IN NUMBER,
                x_operation_seq_num IN NUMBER) IS
   SELECT a.wip_entity_id, wo.organization_id,
          wo.department_id
    FROM AHL_Workorders a, wip_operations wo
    WHERE a.wip_entity_id = wo.wip_entity_id
     AND  wo.operation_seq_num = x_operation_seq_num
     AND a.workorder_id = x_id;
  /*
  --Modified by Srini for Performance fix
  CURSOR c_work (x_id IN NUMBER) IS
   SELECT wip_entity_id,organization_id,
         department_id
    FROM AHL_Workorders a, ahl_visits_b b
    WHERE a.visit_id = b.visit_id
     AND workorder_id = x_id;
  */

 CURSOR c_instance_cur (c_person_id IN NUMBER,
                        c_resource_id IN NUMBER,
						c_dept_id   IN NUMBER)
  IS
  SELECT a.instance_id
     FROM BOM_DEPT_RES_INSTANCES A, BOM_RESOURCE_EMPLOYEES B
   WHERE A.INSTANCE_ID = B.INSTANCE_ID
   AND B.PERSON_ID = c_person_id
   AND A.RESOURCE_ID = c_resource_id
   AND A.DEPARTMENT_ID in (
   			SELECT
			  nvl(bdr.SHARE_FROM_DEPT_ID,
			  bdr.department_id)
			FROM
			  bom_department_resources bdr
			WHERE
			  bdr.resource_id = c_resource_id and
			  bdr.department_id = c_dept_id
			);

-- cursor to get the resource req dates
CURSOR resrc_req_dates(x_id IN NUMBER, x_oper IN NUMBER, x_resrc IN NUMBER) IS
SELECT scheduled_start_date, scheduled_end_date
     FROM ahl_workorder_operations WOP,
          ahl_operation_resources OPR
   WHERE WOP.workorder_operation_id = OPR.workorder_operation_id
    AND WOP.operation_sequence_num = x_oper
    AND OPR.resource_sequence_num = x_resrc
    AND WOP.workorder_id = x_id;

  -- Cursor added by Balaji for Bug # 6728602
  -- Cursor fetches the resource requirement start and end date seconds.
  -- This value is passed to EAM to avoid scheduling hierarchy error.
  -- Bug # 6728602 -- start
  CURSOR c_get_res_sec(p_wo_id IN NUMBER, p_op_seq IN NUMBER)
  IS
  SELECT
     TO_CHAR(WOP.FIRST_UNIT_START_DATE, 'ss'),
     TO_CHAR(WOP.LAST_UNIT_COMPLETION_DATE, 'ss')
  FROM
     wip_operations WOP,
     ahl_workorders AWO
  WHERE
        WOP.OPERATION_SEQ_NUM = p_op_seq
    AND WOP.wip_entity_id = AWO.wip_entity_id
    AND AWO.workorder_id = p_wo_id;

    l_st_date_sec VARCHAR2(30);
    l_end_date_sec VARCHAR2(30);
    l_sec          VARCHAR2(30);
  -- Bug # 6728602 -- end

 l_api_name        CONSTANT VARCHAR2(30) := 'Update_Resrc_Assign';
 l_api_version     CONSTANT NUMBER       := 1.0;
 L_FULL_NAME       CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

 l_msg_count                NUMBER;
 l_wo_operation_id          NUMBER;
 l_assignment_id            NUMBER;
 l_serial_id                NUMBER;
 l_resrc_seq_num            NUMBER;
 l_object_version_number    NUMBER;
 l_oper_resrc_id            NUMBER;
 l_process_status           NUMBER;
 l_employee_id              NUMBER;
 l_resource_type            NUMBER;
 l_dept_id                  NUMBER;
 l_resource_id              NUMBER;
 l_instance_id              NUMBER;
 l_wip_entity_id            NUMBER;
 l_organization_id          NUMBER;

 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 l_error_message            VARCHAR2(120);
 l_employee_name            VARCHAR2(240);

 --l_res_start_date            DATE;
 --l_res_end_date              DATE;


 l_Resrc_Assign_Tbl         Resrc_Assign_Tbl_Type;
 l_default  VARCHAR2(10);
 j  NUMBER;

 l_hour                  VARCHAR2(30);
 l_min                   VARCHAR2(30);
 l_date_time             VARCHAR2(30);

 BEGIN
   --------------------Initialize ----------------------------------
   -- Standard Start of API savepoint
   SAVEPOINT Update_Resrc_Assign;

   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'Enter ahl_pp_assign_pvt. Update Resource reqst','+PPResrc_Assign_Pvt+');
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

   --------------------Start of API Body-----------------------------------
   --Start API Body
   --
    IF p_x_resrc_assign_tbl.COUNT > 0 THEN
	  --
	  FOR i IN p_x_resrc_assign_tbl.FIRST..p_x_resrc_assign_tbl.LAST
	   LOOP
	   --
           IF p_module_type = 'JSP'
           THEN
              p_x_resrc_assign_tbl(i).instance_id      := NULL;
              p_x_resrc_assign_tbl(i).employee_id      := NULL;
           END IF;
       --
       IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'Assignment_id' || p_x_resrc_assign_tbl(i).ASSIGNMENT_ID);
       AHL_DEBUG_PUB.debug( 'Workorder ID = ' || p_x_resrc_assign_tbl(i).workorder_id);
       AHL_DEBUG_PUB.debug( 'Oper Seq Num = ' || p_x_resrc_assign_tbl(i).operation_seq_number);
       AHL_DEBUG_PUB.debug( 'Resrc Seq Num = ' || p_x_resrc_assign_tbl(i).resource_seq_number);
       END IF;
       -- For Resource Type
       OPEN c_resource(p_x_resrc_assign_tbl(i).ASSIGNMENT_ID);
       FETCH c_resource INTO c_resource_rec;
       CLOSE c_resource;
       --Assign values
        p_x_resrc_assign_tbl(i).resource_type_code := c_resource_rec.resource_type_code;
        l_resource_type                            := c_resource_rec.resource_type_code;
        p_x_resrc_assign_tbl(i).oper_resource_id   := c_resource_rec.requirement_id;
        p_x_resrc_assign_tbl(i).workorder_id       := c_resource_rec.job_id;

        IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug(l_full_name || 'Operation Resource Id = ' || p_x_resrc_assign_tbl(i).oper_resource_id);
        AHL_DEBUG_PUB.debug(l_full_name || 'Resource Type = ' || l_resource_type);
        END IF;

       OPEN c_work (p_x_resrc_assign_tbl(i).workorder_id,
                    p_x_resrc_assign_tbl(i).operation_seq_number);
       FETCH c_work INTO l_wip_entity_id,l_organization_id,l_dept_id;
       CLOSE c_work;

	-- rroy
	-- ACL Changes

	l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => p_x_resrc_assign_tbl(i).workorder_id,
							p_ue_id => NULL,
							p_visit_id => NULL,
     						        p_item_instance_id => NULL);
	IF l_return_status = FND_API.G_TRUE THEN
  	  FND_MESSAGE.Set_Name('AHL', 'AHL_PP_UPD_RESASG_UNTLCKD');
	  FND_MSG_PUB.ADD;
	  RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- rroy
	-- ACL Changes

       --Assign wip entity id
       p_x_resrc_assign_tbl(i).wip_entity_id := l_wip_entity_id;
       p_x_resrc_assign_tbl(i).organization_id := l_organization_id;
       p_x_resrc_assign_tbl(i).department_id := l_dept_id;

       -- Get Resource id
       OPEN c_assign1 (p_x_resrc_assign_tbl(i).workorder_id,
	                   p_x_resrc_assign_tbl(i).operation_seq_number,
	                   p_x_resrc_assign_tbl(i).resource_seq_number);
       FETCH c_assign1 INTO l_resource_id;
       CLOSE c_assign1;
       --
		-- to align the assignment dates to the resource req dates
		--Required to check the operation start dates and resource start and end date are same
  /*OPEN resrc_req_dates(p_x_resrc_assign_tbl(i).workorder_id,
 			 p_x_resrc_assign_tbl(i).operation_seq_number,
                         p_x_resrc_assign_tbl(i).resource_seq_number);

		FETCH resrc_req_dates INTO l_res_start_date,l_res_end_date;
                CLOSE resrc_req_dates;
  --Validation is required to include resource timestamp for Requested start date
		-- requested end date
		IF  (TRUNC(p_x_resrc_assign_tbl(i).assign_start_date) = TRUNC(l_res_start_date )
		    AND
			TRUNC(p_x_resrc_assign_tbl(i).assign_end_date) = TRUNC(l_res_start_date ))
		THEN

		     p_x_resrc_assign_tbl(i).assign_start_date := l_res_start_date;
		     p_x_resrc_assign_tbl(i).assign_end_date := l_res_start_date;

		ELSIF (TRUNC(p_x_resrc_assign_tbl(i).assign_start_date) = TRUNC(l_res_end_date)
		     AND
			 TRUNC(p_x_resrc_assign_tbl(i).assign_end_date) = TRUNC(l_res_end_date )) THEN

		     p_x_resrc_assign_tbl(i).assign_start_date := l_res_end_date;
		     p_x_resrc_assign_tbl(i).assign_end_date := l_res_end_date;

        ELSIF (TRUNC(p_x_resrc_assign_tbl(i).assign_start_date) = TRUNC(l_res_start_date )
		    AND
			TRUNC(p_x_resrc_assign_tbl(i).assign_end_date) <> TRUNC(l_res_start_date )) THEN

		     p_x_resrc_assign_tbl(i).assign_start_date := l_res_start_date;

        ELSIF (TRUNC(p_x_resrc_assign_tbl(i).assign_start_date) <> TRUNC(l_res_start_date )
		    AND
			TRUNC(p_x_resrc_assign_tbl(i).assign_end_date) = TRUNC(l_res_end_date )) THEN

		     p_x_resrc_assign_tbl(i).assign_end_date := l_res_end_date;

		END IF;
		*/
		-- Bug # 6728602 -- start
		OPEN c_get_res_sec(
		                  p_x_resrc_assign_tbl(i).workorder_id,
		                  p_x_resrc_assign_tbl(i).operation_seq_number
		                  );
		FETCH c_get_res_sec INTO l_st_date_sec,l_end_date_sec;
		CLOSE c_get_res_sec;
		-- Bug # 6728602 -- end;

		-- R12
		-- Take into account the start and end times
		IF p_x_resrc_assign_tbl(i).assign_start_date IS NOT NULL THEN
		  IF p_x_resrc_assign_tbl(i).assign_start_hour IS NULL THEN
		    l_hour := ':00';
		  ELSE
		    l_hour := ':' || p_x_resrc_assign_tbl(i).assign_start_hour;
		  END IF;

		  IF p_x_resrc_assign_tbl(i).assign_start_min IS NULL THEN
		    l_min := ':00';
		  ELSE
		    l_min := ':' || p_x_resrc_assign_tbl(i).assign_start_min;
 	  	  END IF;

                  -- Bug # 6728602 -- start
                  l_sec := TO_CHAR(p_x_resrc_assign_tbl(i).assign_start_date, 'ss');

		  IF(l_sec = '00') THEN
		      l_sec := ':' ||l_st_date_sec;
		  END IF;

                l_date_time := TO_CHAR(p_x_resrc_assign_tbl(i).assign_start_date, 'DD-MM-YYYY')||' '|| l_hour || l_min || l_sec;
                p_x_resrc_assign_tbl(i).assign_start_date := TO_DATE(l_date_time , 'DD-MM-YYYY :HH24:MI:SS');
                -- Bug # 6728602 -- end
               END IF;

	       IF p_x_resrc_assign_tbl(i).assign_end_date IS NOT NULL THEN
		  IF p_x_resrc_assign_tbl(i).assign_end_hour IS NULL THEN
		    l_hour := ':00';
		  ELSE
		    l_hour := ':' || p_x_resrc_assign_tbl(i).assign_end_hour;
		  END IF;

		  IF p_x_resrc_assign_tbl(i).assign_end_min IS NULL THEN
		    l_min := ':00';
		  ELSE
		    l_min := ':' || p_x_resrc_assign_tbl(i).assign_end_min;
		  END IF;
                  -- Bug # 6728602 -- start
                  l_sec := TO_CHAR(p_x_resrc_assign_tbl(i).assign_end_date, 'ss');

    		  IF(l_sec = '00') THEN
    		      l_sec := ':' ||l_end_date_sec;
    		  END IF;

       		  l_date_time := TO_CHAR(p_x_resrc_assign_tbl(i).assign_end_date, 'DD-MM-YYYY')||' '|| l_hour || l_min || l_sec;
                  p_x_resrc_assign_tbl(i).assign_end_date := TO_DATE(l_date_time , 'DD-MM-YYYY :HH24:MI:SS');
                  -- Bug # 6728602 -- end
                END IF;



       IF l_resource_type <> 2 THEN
          -- Convert serial number to instance/ serial id
          IF (p_x_resrc_assign_tbl(i).serial_number IS NOT NULL AND
              p_x_resrc_assign_tbl(i).serial_number <> Fnd_Api.G_MISS_CHAR ) THEN

              OPEN c_assign1 (p_x_resrc_assign_tbl(i).workorder_id,
			                  p_x_resrc_assign_tbl(i).operation_seq_number,
			                  p_x_resrc_assign_tbl(i).resource_seq_number);
              FETCH c_assign1 INTO l_resource_id;
              CLOSE c_assign1;
			  --
             Check_Serial_Name_Or_Id
               (p_serial_id        => p_x_resrc_assign_tbl(i).instance_id,
                p_serial_number    => p_x_resrc_assign_tbl(i).serial_number,
                p_workorder_id     => p_x_resrc_assign_tbl(i).workorder_id,
                p_resource_id      => l_resource_id,
                p_dept_id          => l_dept_id,
                p_organization_id  => l_organization_id,
                x_instance_id      => l_instance_id,
                x_return_status    => l_return_status,
                x_error_msg_code   => l_msg_data);

              IF G_DEBUG='Y' THEN
              Ahl_Debug_Pub.debug( l_full_name ||'Status Serial' || l_return_status );
              END IF;

              IF NVL(l_return_status,'x') <> 'S'
              THEN
                  Fnd_Message.SET_NAME('AHL','AHL_PP_SERIAL_NOT_EXISTS');
                  Fnd_Msg_Pub.ADD;
                  RAISE Fnd_Api.G_EXC_ERROR;
              END IF;
         END IF;

         --Assign the returned value
         p_x_resrc_assign_tbl(i).instance_id := l_instance_id;

        IF G_DEBUG='Y' THEN
        Ahl_Debug_Pub.debug( l_full_name ||': Serial Id After= ' || p_x_resrc_assign_tbl(i).instance_id);
        END IF;

    END IF;
      IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('Resource Type' || p_x_resrc_assign_tbl(i).resource_type_name);
      AHL_DEBUG_PUB.debug('Employee Number' || p_x_resrc_assign_tbl(i).employee_number);
      AHL_DEBUG_PUB.debug('Employee id' || p_x_resrc_assign_tbl(i).employee_id);
      END IF;

    IF l_resource_type = 2 THEN

         -- For Employee Number
         IF p_x_resrc_assign_tbl(i).employee_number IS NOT NULL AND
            p_x_resrc_assign_tbl(i).employee_number <> Fnd_Api.G_MISS_CHAR
         THEN
             Check_Employee_Number_Or_Id
                 (p_employee_id      => p_x_resrc_assign_tbl(i).employee_id,
                  p_employee_number  => p_x_resrc_assign_tbl(i).employee_number,
                  p_workorder_id     => p_x_resrc_assign_tbl(i).workorder_id,
                  p_oper_resrc_id    => p_x_resrc_assign_tbl(i).oper_resource_id,
                  p_resource_id      => l_resource_id,
                  p_organization_id  => l_organization_id,
                  x_employee_id      => p_x_resrc_assign_tbl(i).employee_id,
                  x_return_status    => l_return_status,
                  x_error_msg_code   => l_msg_data
                  );

             IF NVL(l_return_status, 'X') <> 'S'
             THEN
                  Fnd_Message.SET_NAME('AHL','AHL_PP_EMP_NUM_NOT_EXISTS');
                  Fnd_Msg_Pub.ADD;
                  RAISE Fnd_Api.G_EXC_ERROR;
             END IF;

         -- For Employee Name
         IF p_x_resrc_assign_tbl(i).employee_name IS NOT NULL AND
            p_x_resrc_assign_tbl(i).employee_name <> Fnd_Api.G_MISS_CHAR
         THEN
             Check_Employee_Name_Or_Id
                 (p_employee_id      => l_employee_id,
                  p_employee_number  => p_x_resrc_assign_tbl(i).employee_number,
                  p_workorder_id     => p_x_resrc_assign_tbl(i).workorder_id,
                  p_oper_resrc_id    => p_x_resrc_assign_tbl(i).oper_resource_id,
                  p_resource_id      => l_resource_id,
                  p_organization_id  => l_organization_id,
                  x_employee_name    => l_employee_name,
                  x_employee_id      => l_employee_id,
                  x_return_status    => l_return_status,
                  x_error_msg_code   => l_msg_data
                  );

             IF NVL(l_return_status, 'X') <> 'S'
             THEN
                  Fnd_Message.SET_NAME('AHL','AHL_PP_EMP_NAME_NOT_EXISTS');
                  Fnd_Msg_Pub.ADD;
                  RAISE Fnd_Api.G_EXC_ERROR;
             END IF;

             IF p_x_resrc_assign_tbl(i).employee_id <> l_employee_id THEN
                  Fnd_Message.SET_NAME('AHL','AHL_PP_USE_EMP_NAME_LOV');
                  Fnd_Msg_Pub.ADD;
             END IF;

             IF p_x_resrc_assign_tbl(i).employee_name <> l_employee_name THEN
                  Fnd_Message.SET_NAME('AHL','AHL_PP_EMP_NAME_NOT_EXISTS');
                  Fnd_Msg_Pub.ADD;
             END IF;
           END IF;
         END IF;
         --Assign
		 p_x_resrc_assign_tbl(i).employee_id := l_employee_id;
		 --
      IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('Resource id' || l_resource_id);
      AHL_DEBUG_PUB.debug('Department id' || p_x_resrc_assign_tbl(i).department_id);
      AHL_DEBUG_PUB.debug('Employee id' || p_x_resrc_assign_tbl(i).employee_id);
      END IF;

		-- Get instance id
          IF (p_x_resrc_assign_tbl(i).employee_id IS NOT NULL AND p_x_resrc_assign_tbl(i).employee_id <> Fnd_Api.G_MISS_NUM)
           THEN
		   --
           OPEN c_instance_cur (p_x_resrc_assign_tbl(i).employee_id,
                                l_resource_id,
						        p_x_resrc_assign_tbl(i).department_id);
		   FETCH c_instance_cur INTO p_x_resrc_assign_tbl(i).instance_id;
		   CLOSE c_instance_cur;
           --
          END IF;

      END IF;
         -------------------------------- Validate -----------------------------------------

             Validate_Resrc_Assign (
                  p_api_version        => l_api_version,
                  p_init_msg_list      => p_init_msg_list,
                  p_commit             => p_commit,
                  p_validation_level   => p_validation_level,
                  p_resrc_assign_rec   => p_x_resrc_assign_tbl(i),
                  x_return_status      => l_return_status,
                  x_msg_count          => x_msg_count,
                  x_msg_data           => x_msg_data
             );

   END LOOP;
   END IF;

             --Standard check to count messages
           l_msg_count := Fnd_Msg_Pub.count_msg;

           IF l_msg_count > 0 THEN
              X_msg_count := l_msg_count;
              X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
              RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
           END IF;

       --

-- Call Eam Api to create resource assignment in WIP
  IF p_x_resrc_assign_tbl.COUNT > 0 THEN
    j := 1;
    FOR i IN p_x_resrc_assign_tbl.FIRST..p_x_resrc_assign_tbl.LAST
	  LOOP

  IF G_DEBUG='Y' THEN
  Ahl_Debug_Pub.debug ('p_x_resrc_assign_tbl(i).wip_entity_id' ||p_x_resrc_assign_tbl(i).wip_entity_id  );
  Ahl_Debug_Pub.debug ('p_x_resrc_assign_tbl(i).organization_id' ||p_x_resrc_assign_tbl(i).organization_id );
  Ahl_Debug_Pub.debug ('p_x_resrc_assign_tbl(i).operation_seq_number' ||p_x_resrc_assign_tbl(i).operation_seq_number );
  Ahl_Debug_Pub.debug ('p_x_resrc_assign_tbl(i).resource_seq_number' ||p_x_resrc_assign_tbl(i).resource_seq_number );
  Ahl_Debug_Pub.debug ('p_x_resrc_assign_tbl(i).instance_id' ||p_x_resrc_assign_tbl(i).instance_id );
  Ahl_Debug_Pub.debug ('p_x_resrc_assign_tbl(i).serial_number' ||p_x_resrc_assign_tbl(i).serial_number );

  END IF;

	   --
       l_resrc_assign_tbl(j).WIP_ENTITY_ID           := p_x_resrc_assign_tbl(i).wip_entity_id;
       l_resrc_assign_tbl(j).ORGANIZATION_ID         := p_x_resrc_assign_tbl(i).organization_id;
       l_resrc_assign_tbl(j).OPERATION_SEQ_NUMBER    := p_x_resrc_assign_tbl(i).operation_seq_number;
       l_resrc_assign_tbl(j).WORKORDER_ID            := p_x_resrc_assign_tbl(i).workorder_id;
       l_resrc_assign_tbl(j).RESOURCE_SEQ_NUMBER     := p_x_resrc_assign_tbl(i).resource_seq_number;
       l_resrc_assign_tbl(j).INSTANCE_ID             := p_x_resrc_assign_tbl(i).instance_id;
       l_resrc_assign_tbl(j).SERIAL_NUMBER           := p_x_resrc_assign_tbl(i).serial_number;
       l_resrc_assign_tbl(j).ASSIGN_START_DATE       := p_x_resrc_assign_tbl(i).assign_start_date;
       l_resrc_assign_tbl(j).ASSIGN_END_DATE         := p_x_resrc_assign_tbl(i).assign_end_date;
       l_resrc_assign_tbl(j).OPERATION_FLAG          := 'U';

	   j := j + 1;
	   --
	 END LOOP;
	 --
	END IF;
    --Call AHL Eam Job Pvt

    AHL_EAM_JOB_PVT.process_resource_assign
           (
            p_api_version           => l_api_version,
            p_init_msg_list         => p_init_msg_list,
            p_commit                => p_commit,
            p_validation_level      => p_validation_level,
            p_default               => l_default,
            p_module_type           => p_module_type,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data,
            p_resource_assign_tbl   => l_resrc_assign_tbl);

   IF l_return_status = 'S' THEN
	   --
     IF p_x_resrc_assign_tbl.COUNT > 0 THEN
     --
       FOR i IN p_x_resrc_assign_tbl.FIRST..p_x_resrc_assign_tbl.LAST LOOP
	   --
	   --Get Assignment details
           OPEN c_assign(p_x_resrc_assign_tbl(i).ASSIGNMENT_ID);
           FETCH c_assign INTO c_assign_rec;
           CLOSE c_assign;

           IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug(' Record OVN = ' || p_x_resrc_assign_tbl(i).object_version_number);
           AHL_DEBUG_PUB.debug(' Cursor OVN = ' || c_assign_rec.object_version_number);
           END IF;

          -- Check Object version number.
          IF (p_x_resrc_assign_tbl(i).object_version_number <> c_assign_rec.object_version_number) THEN
             AHL_DEBUG_PUB.debug(l_full_name || 'Inside OVN comparison');
             Fnd_Message.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
             Fnd_Msg_Pub.ADD;
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
          END IF;

       IF  p_x_resrc_assign_tbl(i).Assignment_id <> FND_API.G_MISS_NUM THEN
          -- These conditions are required for optional fields
/*
          -- Operation Resource Id
          IF p_x_resrc_assign_tbl(i).Operation_resource_id = FND_API.G_MISS_NUM
          THEN
           p_x_resrc_assign_tbl(i).Operation_resource_id := NULL;
          ELSIF p_x_resrc_assign_tbl(i).Operation_resource_id IS NULL THEN
           p_x_resrc_assign_tbl(i).Operation_resource_id := c_assign_rec.Operation_resource_id;
          END IF;
*/

          -- Employee Id
          IF p_x_resrc_assign_tbl(i).Employee_id = FND_API.G_MISS_NUM
          THEN
           p_x_resrc_assign_tbl(i).Employee_id := NULL;
          ELSIF p_x_resrc_assign_tbl(i).Employee_id IS NULL THEN
           p_x_resrc_assign_tbl(i).Employee_id := c_assign_rec.Employee_id;
          END IF;

          -- Serial Number
          IF p_x_resrc_assign_tbl(i).serial_number = FND_API.G_MISS_CHAR
          THEN
           p_x_resrc_assign_tbl(i).serial_number := NULL;
          ELSIF p_x_resrc_assign_tbl(i).serial_number IS NULL THEN
           p_x_resrc_assign_tbl(i).serial_number := c_assign_rec.serial_number;
          END IF;
          -- Instance Id
          IF p_x_resrc_assign_tbl(i).Instance_id = FND_API.G_MISS_NUM
          THEN
           p_x_resrc_assign_tbl(i).Instance_id := NULL;
          ELSIF p_x_resrc_assign_tbl(i).instance_id IS NULL THEN
           p_x_resrc_assign_tbl(i).Instance_id := c_assign_rec.Instance_id;
          END IF;
          -- Assign start date
          IF p_x_resrc_assign_tbl(i).Assign_start_date = FND_API.G_MISS_DATE
          THEN
           p_x_resrc_assign_tbl(i).Assign_start_date := NULL;
          ELSIF p_x_resrc_assign_tbl(i).assign_start_date IS NULL THEN
           p_x_resrc_assign_tbl(i).Assign_start_date := c_assign_rec.Assign_start_date;
          END IF;

          -- Assign end date
          IF p_x_resrc_assign_tbl(i).Assign_end_date = FND_API.G_MISS_DATE
          THEN
           p_x_resrc_assign_tbl(i).Assign_end_date := NULL;
          ELSIF p_x_resrc_assign_tbl(i).assign_end_date IS NULL THEN
           p_x_resrc_assign_tbl(i).Assign_end_date := c_assign_rec.Assign_end_date;
          END IF;
          -- Attribute Category
          IF p_x_resrc_assign_tbl(i).attribute_category = FND_API.G_MISS_CHAR
          THEN
           p_x_resrc_assign_tbl(i).attribute_category := NULL;
          ELSIF p_x_resrc_assign_tbl(i).attribute_category IS NULL THEN
           p_x_resrc_assign_tbl(i).attribute_category := c_assign_rec.attribute_category;
          END IF;
          -- Attribute1
          IF p_x_resrc_assign_tbl(i).attribute1 = FND_API.G_MISS_CHAR
          THEN
           p_x_resrc_assign_tbl(i).attribute1 := NULL;
          ELSIF p_x_resrc_assign_tbl(i).attribute1 IS NULL THEN
           p_x_resrc_assign_tbl(i).attribute1 := c_assign_rec.attribute1;
          END IF;
          -- Attribute2
          IF p_x_resrc_assign_tbl(i).attribute2 = FND_API.G_MISS_CHAR
          THEN
           p_x_resrc_assign_tbl(i).attribute2 := NULL;
          ELSIF p_x_resrc_assign_tbl(i).attribute2 IS NULL THEN
           p_x_resrc_assign_tbl(i).attribute2 := c_assign_rec.attribute2;
          END IF;
          -- Attribute3
          IF p_x_resrc_assign_tbl(i).attribute3 = FND_API.G_MISS_CHAR
          THEN
           p_x_resrc_assign_tbl(i).attribute3 := NULL;
          ELSIF p_x_resrc_assign_tbl(i).attribute3 IS NULL THEN
           p_x_resrc_assign_tbl(i).attribute3 := c_assign_rec.attribute3;
          END IF;
          -- Attribute4
          IF p_x_resrc_assign_tbl(i).attribute4 = FND_API.G_MISS_CHAR
          THEN
           p_x_resrc_assign_tbl(i).attribute4 := NULL;
          ELSIF p_x_resrc_assign_tbl(i).attribute4 IS NULL THEN
           p_x_resrc_assign_tbl(i).attribute4 := c_assign_rec.attribute4;
          END IF;
          -- Attribute5
          IF p_x_resrc_assign_tbl(i).attribute5 = FND_API.G_MISS_CHAR
          THEN
           p_x_resrc_assign_tbl(i).attribute5 := NULL;
          ELSIF p_x_resrc_assign_tbl(i).attribute5 IS NULL THEN
           p_x_resrc_assign_tbl(i).attribute5 := c_assign_rec.attribute5;
          END IF;
          -- Attribute6
          IF p_x_resrc_assign_tbl(i).attribute6 = FND_API.G_MISS_CHAR
          THEN
           p_x_resrc_assign_tbl(i).attribute6 := NULL;
          ELSIF p_x_resrc_assign_tbl(i).attribute6 IS NULL THEN
           p_x_resrc_assign_tbl(i).attribute6 := c_assign_rec.attribute6;
          END IF;
          -- Attribute7
          IF p_x_resrc_assign_tbl(i).attribute7 = FND_API.G_MISS_CHAR
          THEN
           p_x_resrc_assign_tbl(i).attribute7 := NULL;
          ELSIF p_x_resrc_assign_tbl(i).attribute7 IS NULL THEN
           p_x_resrc_assign_tbl(i).attribute7 := c_assign_rec.attribute7;
          END IF;
          -- Attribute8
          IF p_x_resrc_assign_tbl(i).attribute8 = FND_API.G_MISS_CHAR
          THEN
           p_x_resrc_assign_tbl(i).attribute8 := NULL;
          ELSIF p_x_resrc_assign_tbl(i).attribute8 IS NULL THEN
           p_x_resrc_assign_tbl(i).attribute8 := c_assign_rec.attribute8;
          END IF;
          -- Attribute9
          IF p_x_resrc_assign_tbl(i).attribute9 = FND_API.G_MISS_CHAR
          THEN
           p_x_resrc_assign_tbl(i).attribute9 := NULL;
          ELSIF p_x_resrc_assign_tbl(i).attribute9 IS NULL THEN
           p_x_resrc_assign_tbl(i).attribute9 := c_assign_rec.attribute9;
          END IF;
          -- Attribute10
          IF p_x_resrc_assign_tbl(i).attribute10 = FND_API.G_MISS_CHAR
          THEN
           p_x_resrc_assign_tbl(i).attribute10 := NULL;
          ELSIF p_x_resrc_assign_tbl(i).attribute10 IS NULL THEN
           p_x_resrc_assign_tbl(i).attribute10 := c_assign_rec.attribute10;
          END IF;
          -- Attribute11
          IF p_x_resrc_assign_tbl(i).attribute11 = FND_API.G_MISS_CHAR
          THEN
           p_x_resrc_assign_tbl(i).attribute11 := NULL;
          ELSIF p_x_resrc_assign_tbl(i).attribute11 IS NULL THEN
           p_x_resrc_assign_tbl(i).attribute11 := c_assign_rec.attribute11;
          END IF;
          -- Attribute12
          IF p_x_resrc_assign_tbl(i).attribute12 = FND_API.G_MISS_CHAR
          THEN
           p_x_resrc_assign_tbl(i).attribute12 := NULL;
          ELSIF p_x_resrc_assign_tbl(i).attribute12 IS NULL THEN
           p_x_resrc_assign_tbl(i).attribute12 := c_assign_rec.attribute12;
          END IF;
          -- Attribute13
          IF p_x_resrc_assign_tbl(i).attribute13 = FND_API.G_MISS_CHAR
          THEN
           p_x_resrc_assign_tbl(i).attribute13 := NULL;
          ELSIF p_x_resrc_assign_tbl(i).attribute13 IS NULL THEN
            p_x_resrc_assign_tbl(i).attribute13 := c_assign_rec.attribute13;
          END IF;
          -- Attribute14
          IF p_x_resrc_assign_tbl(i).attribute14 = FND_API.G_MISS_CHAR
          THEN
           p_x_resrc_assign_tbl(i).attribute14 := NULL;
          ELSIF p_x_resrc_assign_tbl(i).attribute14 IS NULL THEN
           p_x_resrc_assign_tbl(i).attribute14 := c_assign_rec.attribute14;
          END IF;
          -- Attribute15
          IF p_x_resrc_assign_tbl(i).attribute15 = FND_API.G_MISS_CHAR
          THEN
           p_x_resrc_assign_tbl(i).attribute15 := NULL;
          ELSIF p_x_resrc_assign_tbl(i).attribute15 IS NULL THEN
           p_x_resrc_assign_tbl(i).attribute15 := c_assign_rec.attribute15;
          END IF;
          -- Self Assigned Flag
          IF p_x_resrc_assign_tbl(i).self_assigned_flag = FND_API.G_MISS_NUM
          THEN
           p_x_resrc_assign_tbl(i).self_assigned_flag := NULL;
          ELSIF p_x_resrc_assign_tbl(i).self_assigned_flag IS NULL THEN
           p_x_resrc_assign_tbl(i).self_assigned_flag := c_assign_rec.self_assigned_flag;
          END IF;
          /*
          -- Login Date
          IF p_x_resrc_assign_tbl(i).login_date = FND_API.G_MISS_DATE
          THEN
           p_x_resrc_assign_tbl(i).login_date := NULL;
          ELSIF p_x_resrc_assign_tbl(i).login_date IS NULL THEN
           p_x_resrc_assign_tbl(i).login_date := c_assign_rec.login_date;
          END IF;
          */

      --Standard check to count messages
       l_msg_count := Fnd_Msg_Pub.count_msg;

       IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
       END IF;

         IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.debug(l_full_name || ' Before calling Update Row procedure');
         END IF;

          -- Create Record in schedule Resources
             Update_Row (
                   X_ASSIGNMENT_ID         => p_x_resrc_assign_tbl(i).Assignment_id,
                   X_OBJECT_VERSION_NUMBER => p_x_resrc_assign_tbl(i).object_version_number,
                   X_OPERATION_RESOURCE_ID => c_assign_rec.Operation_resource_id,
                   X_EMPLOYEE_ID           => p_x_resrc_assign_tbl(i).employee_id,
                   X_SERIAL_NUMBER         => p_x_resrc_assign_tbl(i).serial_number,
                   X_INSTANCE_ID           => p_x_resrc_assign_tbl(i).instance_id,
                   X_ASSIGN_START_DATE     => p_x_resrc_assign_tbl(i).assign_start_date,
                   X_ASSIGN_END_DATE       => p_x_resrc_assign_tbl(i).assign_end_date,
		   X_SELF_ASSIGNED_FLAG    => p_x_resrc_assign_tbl(i).self_assigned_flag,
		   --X_LOGIN_DATE            => p_x_resrc_assign_tbl(i).login_date,
                   X_ATTRIBUTE_CATEGORY    => p_x_resrc_assign_tbl(i).attribute_category,
                   X_ATTRIBUTE1            => p_x_resrc_assign_tbl(i).attribute1,
                   X_ATTRIBUTE2            => p_x_resrc_assign_tbl(i).attribute2,
                   X_ATTRIBUTE3            => p_x_resrc_assign_tbl(i).attribute3,
                   X_ATTRIBUTE4            => p_x_resrc_assign_tbl(i).attribute4,
                   X_ATTRIBUTE5            => p_x_resrc_assign_tbl(i).attribute5,
                   X_ATTRIBUTE6            => p_x_resrc_assign_tbl(i).attribute6,
                   X_ATTRIBUTE7            => p_x_resrc_assign_tbl(i).attribute7,
                   X_ATTRIBUTE8            => p_x_resrc_assign_tbl(i).attribute8,
                   X_ATTRIBUTE9            => p_x_resrc_assign_tbl(i).attribute9,
                   X_ATTRIBUTE10           => p_x_resrc_assign_tbl(i).attribute10,
                   X_ATTRIBUTE11           => p_x_resrc_assign_tbl(i).attribute11,
                   X_ATTRIBUTE12           => p_x_resrc_assign_tbl(i).attribute12,
                   X_ATTRIBUTE13           => p_x_resrc_assign_tbl(i).attribute13,
                   X_ATTRIBUTE14           => p_x_resrc_assign_tbl(i).attribute14,
                   X_ATTRIBUTE15           => p_x_resrc_assign_tbl(i).attribute15,
                   X_LAST_UPDATE_DATE      => SYSDATE,
                   X_LAST_UPDATED_BY       => fnd_global.user_id,
                   X_LAST_UPDATE_LOGIN     => fnd_global.login_id
                  );
          END IF;

          IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug(l_full_name || ' After calling Update Row procedure');
          AHL_DEBUG_PUB.debug(l_full_name || ' Assign Start Date = ' || p_x_resrc_assign_tbl(i).assign_start_date);
          AHL_DEBUG_PUB.debug(l_full_name || ' Assign End Date = ' || p_x_resrc_assign_tbl(i).assign_end_date);
          END IF;
	  END LOOP;
	END IF;

 END IF; -- Return status from Ahl Eam Api
   ------------------------End of Body---------------------------------------
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
   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of public api Update Resource Reqst','+PPResrc_Assign_Pvt+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   --
   END IF;
  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_Resrc_Assign;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
    IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.log_app_messages(x_msg_count, x_msg_data, 'ERROR' );

    -- Check if API is called in debug mode. If yes, disable debug.
    AHL_DEBUG_PUB.disable_debug;
	--
    END IF;
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO update_Resrc_Assign;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
       IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        --AHL_DEBUG_PUB.debug( 'ahl_ltp_pp_Resources_pvt. Update Resource Reqst','+PPResrc_Assign_Pvt+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
       END IF;
WHEN OTHERS THEN
    ROLLBACK TO update_Resrc_Assign;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_PP_RESRC_ASSIGN_PVT',
                            p_procedure_name  =>  'UPDATE_Resrc_Assign',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

       IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
              x_msg_count, x_msg_data, 'SQL ERROR' );
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
       END IF;
END Update_Resrc_Assign;
--
PROCEDURE Remove_Resource_Assignment (
   p_api_version             IN    NUMBER,
   p_init_msg_list           IN    VARCHAR2  := Fnd_Api.g_false,
   p_commit                  IN    VARCHAR2  := Fnd_Api.g_false,
   p_validation_level        IN    NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type             IN    VARCHAR2  := 'JSP',
   p_x_resrc_assign_tbl      IN OUT NOCOPY Resrc_Assign_tbl_Type,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)
IS
 -- Get the current record
 CURSOR get_resrc_assign_cur(c_assign_id IN NUMBER)
   IS
    SELECT * FROM AHL_WORK_ASSIGNMENTS
	WHERE assignment_id = c_assign_id;

 -- Get the workorder details
 /*CURSOR get_resource_details (c_oper_resource_id IN NUMBER)
  IS
   SELECT operation_resource_id,resource_sequence_num,
          operation_sequence_num,resource_id,b.workorder_operation_id,
          c.workorder_id,wip_entity_id,organization_id,department_id
      FROM ahl_operation_resources a, ahl_workorder_operations b, ahl_workorders_v c
   WHERE a.WORKORDER_OPERATION_id = b.workorder_operation_id
     AND b.workorder_id = c.workorder_id
     AND a.operation_resource_id = c_oper_resource_id;
					*/
	--Modified by srini for performance fix
 CURSOR get_resource_details (c_oper_resource_id IN NUMBER)
  IS
   SELECT operation_resource_id,resource_sequence_num,
          operation_sequence_num,resource_id,b.workorder_operation_id,
          c.workorder_id,c.wip_entity_id, d.organization_id,department_id
      FROM ahl_operation_resources a, ahl_workorder_operations b,
           ahl_workorders c , wip_discrete_jobs d, wip_operations e
   WHERE a.WORKORDER_OPERATION_id = b.workorder_operation_id
     AND b.workorder_id = c.workorder_id
     AND c.wip_entity_id = d.wip_entity_id
     AND c.wip_entity_id = e.wip_entity_id
     AND b.operation_sequence_num = e.operation_seq_num
     AND a.operation_resource_id = c_oper_resource_id;


 l_api_name        CONSTANT VARCHAR2(30) := 'REMOVE_Resource_Assignment';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(200);
 l_msg_count                NUMBER;
 l_dummy                NUMBER;
 l_error_message         VARCHAR2(30);
 l_resrc_assign_tbl      Resrc_Assign_tbl_Type;
 l_resrc_assign_rec     get_resrc_assign_cur%ROWTYPE;
 l_resource_details     get_resource_details%ROWTYPE;
 l_default              VARCHAR2(10);
 j NUMBER;
 --
 BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT Remove_Resource_Assignment;

  -- Check if API is called in debug mode. If yes, enable debug.
  IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.enable_debug;
   END IF;
  -- Debug info.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'enter ahl_ltp_reqst_matrl_pvt Remove Resource Assignment ','+MAATP+');
   END IF;
  -- Standard call to check for call compatibility.
   IF Fnd_Api.to_boolean(p_init_msg_list)
   THEN
     Fnd_Msg_Pub.initialize;
   END IF;

   --  Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

 ------------------------Start API Body ---------------------------------

     IF p_x_resrc_assign_tbl.COUNT > 0 THEN
	  --
	   FOR i IN p_x_resrc_assign_tbl.FIRST..p_x_resrc_assign_tbl.LAST
	    LOOP
		   --
		    IF (p_x_resrc_assign_tbl(i).assignment_id IS NOT NULL AND
			    p_x_resrc_assign_tbl(i).assignment_id <> FND_API.G_MISS_NUM) THEN
			  --Get the exisitng record
	          OPEN get_resrc_assign_cur(p_x_resrc_assign_tbl(i).assignment_id);
			  FETCH get_resrc_assign_cur INTO l_resrc_assign_rec;
			  IF get_resrc_assign_cur%NOTFOUND THEN
               Fnd_Message.Set_Name('AHL','AHL_COM_INVALID_RECORD');
               Fnd_Msg_Pub.ADD;
			   CLOSE get_resrc_assign_cur;
               RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
              END IF;
			  --
			  CLOSE get_resrc_assign_cur;
			  END IF;
		      --Check for object version number
			  IF p_x_resrc_assign_tbl(i).object_version_number <> l_resrc_assign_rec.object_version_number
			    THEN
                 Fnd_Message.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
                 Fnd_Msg_Pub.ADD;
               RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
			  END IF;
			  --
			  -- Get Wip entity ,operation resource details
	          OPEN get_resource_details(l_resrc_assign_rec.operation_resource_id);
			  FETCH get_resource_details INTO l_resource_details;
			  CLOSE get_resource_details;
			  --
			  -- Assign to
			  p_x_resrc_assign_tbl(i).operation_seq_number := l_resource_details.operation_sequence_num;
			  p_x_resrc_assign_tbl(i).resource_seq_number := l_resource_details.resource_sequence_num;
			  p_x_resrc_assign_tbl(i).workorder_operation_id := l_resource_details.workorder_operation_id;
			  p_x_resrc_assign_tbl(i).workorder_id := l_resource_details.workorder_id;
			  p_x_resrc_assign_tbl(i).wip_entity_id := l_resource_details.wip_entity_id;
			  p_x_resrc_assign_tbl(i).organization_id := l_resource_details.organization_id;
			  p_x_resrc_assign_tbl(i).instance_id := l_resrc_assign_rec.instance_id;
--			  p_x_resrc_assign_tbl(i).serial_number := l_resrc_assign_rec.serial_number;
			  p_x_resrc_assign_tbl(i).assign_start_date := l_resrc_assign_rec.assign_start_date;
			  p_x_resrc_assign_tbl(i).assign_end_date := l_resrc_assign_rec.assign_end_date;

					-- rroy
					-- ACL Changes
					l_return_status := AHL_PRD_UTIL_PKG.IsDelAsg_Enabled(p_assignment_id => p_x_resrc_assign_tbl(i).assignment_id,
																																																										p_workorder_id => p_x_resrc_assign_tbl(i).workorder_id);
					IF l_return_status = FND_API.G_FALSE THEN
							RAISE FND_API.G_EXC_ERROR;
					END IF;


					-- rroy
					-- ACL Changes
		END LOOP;
     END IF;

           --Standard check to count messages
           l_msg_count := Fnd_Msg_Pub.count_msg;

           IF l_msg_count > 0 THEN
            x_msg_count := l_msg_count;
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
           END IF;


-- Call Eam Api to create resource assignment in WIP
  IF p_x_resrc_assign_tbl.COUNT > 0 THEN
    j := 1;
    FOR i IN p_x_resrc_assign_tbl.FIRST..p_x_resrc_assign_tbl.LAST
	  LOOP
	   --
       l_resrc_assign_tbl(j).WIP_ENTITY_ID           := p_x_resrc_assign_tbl(i).wip_entity_id;
       l_resrc_assign_tbl(j).ORGANIZATION_ID         := p_x_resrc_assign_tbl(i).organization_id;
       l_resrc_assign_tbl(j).WORKORDER_ID            := p_x_resrc_assign_tbl(i).workorder_id;
       l_resrc_assign_tbl(j).OPERATION_SEQ_NUMBER    := p_x_resrc_assign_tbl(i).operation_seq_number;
       l_resrc_assign_tbl(j).RESOURCE_SEQ_NUMBER     := p_x_resrc_assign_tbl(i).resource_seq_number;
       l_resrc_assign_tbl(j).INSTANCE_ID             := p_x_resrc_assign_tbl(i).instance_id;
       l_resrc_assign_tbl(j).SERIAL_NUMBER           := p_x_resrc_assign_tbl(i).serial_number;
       l_resrc_assign_tbl(j).ASSIGN_START_DATE       := p_x_resrc_assign_tbl(i).assign_start_date;
       l_resrc_assign_tbl(j).ASSIGN_END_DATE         := p_x_resrc_assign_tbl(i).assign_end_date;
       l_resrc_assign_tbl(j).OPERATION_FLAG          := 'D';

	   j := j + 1;
	   --
	 END LOOP;
	 --
	END IF;
    --Call AHL Eam Job Pvt

    AHL_EAM_JOB_PVT.process_resource_assign
           (
            p_api_version           => l_api_version,
            p_init_msg_list         => p_init_msg_list,
            p_commit                => p_commit,
            p_validation_level      => p_validation_level,
            p_default               => l_default,
            p_module_type           => p_module_type,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data,
            p_resource_assign_tbl   => l_resrc_assign_tbl);

IF l_return_status = 'S' THEN
     --
      IF p_x_resrc_assign_tbl.count > 0 THEN
	    FOR i IN p_x_resrc_assign_tbl.FIRST..p_x_resrc_assign_tbl.LAST
		 LOOP
		   --
           DELETE FROM AHL_WORK_ASSIGNMENTS
               WHERE ASSIGNMENT_ID = p_x_resrc_assign_tbl(i).assignment_id;
			   --
         END LOOP;
	  END IF;

END IF;
   ---------------------------End of Body---------------------------------------
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
   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of private api Remove Resource Assignment ','+MAMRP+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   --
   END IF;
  EXCEPTION
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Remove_Resource_Assignment;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
     IF G_DEBUG='Y' THEN
        Ahl_Debug_Pub.log_app_messages (
             x_msg_count, x_msg_data, 'ERROR' );
        --Ahl_Debug_Pub.debug( 'ahl_ltp_reqst_matrl_pvt. Remove Resource Assignment ','+MAMRP+');
        -- Check if API is called in debug mode. If yes, disable debug.
        Ahl_Debug_Pub.disable_debug;
     END IF;

WHEN Fnd_Api.G_EXC_ERROR THEN
    ROLLBACK TO remove_Resource_Assignment;
    X_return_status := Fnd_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
     IF G_DEBUG='Y' THEN
        -- Debug info.
        Ahl_Debug_Pub.log_app_messages (
             x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        --Ahl_Debug_Pub.debug( 'ahl_ltp_reqst_matrl_pvt. Remove Resource Assignment ','+MAMRP+');
        -- Check if API is called in debug mode. If yes, disable debug.
        Ahl_Debug_Pub.disable_debug;
      END IF;

WHEN OTHERS THEN
    ROLLBACK TO remove_Resource_Assignment;
    X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
    THEN
    Fnd_Msg_Pub.add_exc_msg(p_pkg_name        =>  'AHL_PP_RESRC_ASSIGN_PVT',
                            p_procedure_name  =>  'REMOVE_Resource_Assignment',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
     IF G_DEBUG='Y' THEN
        -- Debug info.
        Ahl_Debug_Pub.log_app_messages (
             x_msg_count, x_msg_data, 'SQL ERROR' );
        --Ahl_Debug_Pub.debug( 'ahl_ltp_reqst_matrl_pvt. Remove Resource Assignment ','+MTMRP+');
        -- Check if API is called in debug mode. If yes, disable debug.
        Ahl_Debug_Pub.disable_debug;
      END IF;
END Remove_Resource_Assignment;

-----------------------------------------------------------------------------------
-- Public Procedure Definitions follow --
-----------------------------------------
-- Start of Comments --
--  Procedure name    : Process_Resrc_Assign
--  Type              : Private
--  Function          : Process ............................based on operation flag
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Process Resource Assignment Parameters:
--       p_x_resrc_assign_tbl     IN OUT NOCOPY AHL_PP_RESRC_ASSIGN_PVT.Resrc_Assign_Tbl_Type,
--         Contains........................     on operation flag
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Process_Resrc_Assign (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := NULL,
    p_operation_flag         IN            VARCHAR2,
    p_x_resrc_assign_tbl     IN OUT NOCOPY AHL_PP_RESRC_ASSIGN_PVT.Resrc_Assign_Tbl_Type,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2
   )
 IS
 l_api_name        CONSTANT VARCHAR2(30) := 'Process_Resrc_Assign';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 l_resrc_Assign_rec        AHL_PP_RESRC_ASSIGN_PVT.Resrc_Assign_Rec_Type;

 BEGIN
   --------------------Initialize ----------------------------------
   -- Standard Start of API savepoint
   SAVEPOINT Process_Resrc_Assign;

   -- Check if API is called in debug mode. If yes, enable debug.
  IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
 IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'Enter AHL_PP_RESRC_ASSIGN.process_resrc_assign','+PPResrc_Assign_Pvt+');
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

   --------------------Start of API Body-----------------------------------
   IF p_x_resrc_assign_tbl.COUNT > 0 THEN
      --
           IF p_operation_flag = 'C' THEN
              --
              -- Call create Resource Assignment
                 IF G_DEBUG='Y' THEN
		         Ahl_Debug_Pub.debug( 'Start of pvt api for create Resource Assignment','+PPResrc_Assign_Pvt+');
                 END IF;
                 Create_Resrc_Assign (
                      p_api_version         => p_api_version,
                      p_init_msg_list       => p_init_msg_list,
                      p_commit              => p_commit,
                      p_validation_level    => p_validation_level,
                      p_module_type         => p_module_type,
                      p_x_resrc_assign_tbl  => p_x_resrc_assign_tbl,
                      x_return_status       => l_return_status,
                      x_msg_count           => l_msg_count,
                      x_msg_data            => l_msg_data
                     ) ;

              IF G_DEBUG='Y' THEN
                 Ahl_Debug_Pub.debug( 'End of pvt api for create Resource Assignment','+PPResrc_Assign_Pvt+');
               END IF;

           ELSIF p_operation_flag = 'U' THEN
              IF G_DEBUG='Y' THEN
               AHL_DEBUG_PUB.debug( 'after update'||p_operation_flag);
               END IF;
               -- Call Update Resource Assignment
               Update_Resrc_Assign (
                  p_api_version         => p_api_version,
                  p_init_msg_list       => p_init_msg_list,
                  p_commit              => p_commit,
                  p_validation_level    => p_validation_level,
                  p_module_type         => p_module_type,
                  p_x_resrc_assign_tbl  => p_x_resrc_assign_tbl,
                  x_return_status       => l_return_status,
                  x_msg_count           => l_msg_count,
                  x_msg_data            => l_msg_data
                  );

		   ELSIF p_operation_flag = 'D' THEN
                -- Call Remove Resource Assignment
             Remove_Resource_Assignment (
                   p_api_version         => p_api_version,
                   p_init_msg_list       => p_init_msg_list,
                   p_commit              => p_commit,
                   p_validation_level    => p_validation_level,
                   p_module_type         => p_module_type,
                   p_x_resrc_assign_tbl  => p_x_resrc_assign_tbl,
                   x_return_status       => l_return_status,
                   x_msg_count           => l_msg_count,
                   x_msg_data            => l_msg_data
                   );

           END IF;
    END IF;
   ------------------------End of Body---------------------------------------
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;

   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of public api Process Resource Assignment','+PPResrc_Assign_Pvt+');
   END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.disable_debug;
   END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Process_Resrc_Assign;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
      IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'ERROR' );
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
      END IF;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Process_Resrc_Assign;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
     IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
      END IF;
WHEN OTHERS THEN
    ROLLBACK TO Process_Resrc_Assign;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    FND_MSG_PUB.add_exc_msg(p_pkg_name        =>  'AHL_PP_RESRC_ASSIGN_PVT',
                            p_procedure_name  =>  'Process_Resrc_Assign',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
     IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
              x_msg_count, x_msg_data, 'SQL ERROR' );
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
     END IF;
END Process_Resrc_Assign;

END AHL_PP_RESRC_ASSIGN_PVT;

/
