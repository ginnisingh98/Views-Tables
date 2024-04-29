--------------------------------------------------------
--  DDL for Package Body AHL_PP_MATERIALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PP_MATERIALS_PVT" AS
/* $Header: AHLVPPMB.pls 120.15.12010000.10 2010/04/07 13:21:55 jkjain ship $*/
--
-----------------------
-- Declare Constants --
-----------------------
G_PKG_NAME  VARCHAR2(30)  := 'AHL_PP_MATERIALS_PVT';
G_DEBUG     VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;

-------------------------------------------------
-- Declare Locally used Record and Table Types --
-------------------------------------------------

------------------------------
-- Declare Local Procedures --
------------------------------

  -- Procedure to get organization ID
PROCEDURE Check_org_name_Or_Id
   (p_organization_id     IN NUMBER,
    p_org_name            IN VARCHAR2,
    x_organization_id     OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_error_msg_code      OUT NOCOPY VARCHAR2
    );
 -- Procedure to get department ID
PROCEDURE Check_dept_desc_Or_Id
   (p_organization_id     IN NUMBER,
    p_org_name            IN VARCHAR2,
    p_department_id       IN NUMBER,
    p_dept_description    IN VARCHAR2,
    x_department_id       OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_error_msg_code      OUT NOCOPY VARCHAR2
     );

 -- Procedure to get visit task ID
PROCEDURE Get_visit_task_Id
   (p_workorder_id        IN NUMBER,
    x_visit_task_id       OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_error_msg_code      OUT NOCOPY VARCHAR2
     );

-- Procedure to get inventory item ID
PROCEDURE Get_inventory_item_Id
   (p_inventory_item_id       IN  NUMBER,
    p_concatenated_segments   IN  VARCHAR2,
    p_organization_id         IN  NUMBER,
    x_inventory_item_id       OUT NOCOPY NUMBER,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_error_msg_code          OUT NOCOPY VARCHAR2
   );

-- Procedure to get visit task details
PROCEDURE Get_visit_task_details
    ( p_visit_task_id       IN NUMBER,
      x_visit_id            OUT NOCOPY NUMBER,
      x_organization_id     OUT NOCOPY NUMBER,
      x_department_id       OUT NOCOPY NUMBER,
      x_project_task_id     OUT NOCOPY NUMBER,
      x_project_id          OUT NOCOPY NUMBER
    );

PROCEDURE Get_workorder_Id
   (p_workorder_id        IN  NUMBER,
    p_job_number          IN VARCHAR2,
    x_workorder_id        OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_error_msg_code      OUT NOCOPY VARCHAR2
   );

PROCEDURE Get_workorder_operation_Id
   (p_workorder_id        IN  NUMBER,
    p_operation_sequence  IN  NUMBER,
    x_workorder_operation_id  OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_error_msg_code      OUT NOCOPY VARCHAR2
   );

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

PROCEDURE get_dff_default_values
(
   p_req_material_rec       IN REQ_MATERIAL_REC_TYPE,
   flex_fields_defaults     OUT NOCOPY dff_default_values_type
);
-------------------------------------
-- End Local Procedures Declaration--
-------------------------------------

PROCEDURE Check_org_name_Or_Id
    (p_organization_id     IN NUMBER,
     p_org_name            IN VARCHAR2,
     x_organization_id     OUT NOCOPY NUMBER,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_error_msg_code      OUT NOCOPY VARCHAR2
     )
   IS
BEGIN
      IF (p_organization_id IS NOT NULL AND
          p_organization_id <> FND_API.G_MISS_NUM)
       THEN
          SELECT organization_id
              INTO x_organization_id
            FROM HR_ALL_ORGANIZATION_UNITS
          WHERE organization_id   = p_organization_id;
      ELSE
          SELECT organization_id
              INTO x_organization_id
            FROM HR_ALL_ORGANIZATION_UNITS
          WHERE NAME  = p_org_name;
      END IF;
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
EXCEPTION
       WHEN NO_DATA_FOUND THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_PP_ORG_ID_NOT_EXISTS';
       WHEN TOO_MANY_ROWS THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_PP_ORG_ID_NOT_EXISTS';
       WHEN OTHERS THEN
         x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
         RAISE;
END Check_org_name_Or_Id;
--
PROCEDURE Check_dept_desc_Or_Id
    (p_organization_id     IN NUMBER,
     p_org_name            IN VARCHAR2,
     p_department_id       IN NUMBER,
     p_dept_description    IN VARCHAR2,
     x_department_id       OUT NOCOPY NUMBER,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_error_msg_code      OUT NOCOPY VARCHAR2
     )
   IS
BEGIN

      IF (p_department_id IS NOT NULL AND
          p_department_id <> FND_API.G_MISS_NUM)
       THEN
          SELECT department_id
             INTO x_department_id
            FROM BOM_DEPARTMENTS
          WHERE organization_id = p_organization_id
            AND department_id   = p_department_id;
     ELSE
      --
          SELECT department_id
             INTO x_department_id
           FROM BOM_DEPARTMENTS
          WHERE organization_id =  p_organization_id
            AND description = p_dept_description;
      END IF;
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
EXCEPTION
       WHEN NO_DATA_FOUND THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_PP_DEPT_ID_NOT_EXIST';
       WHEN TOO_MANY_ROWS THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_PP_DEPT_ID_NOT_EXIST';
       WHEN OTHERS THEN
         x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
         RAISE;
END Check_dept_desc_Or_Id;
--
PROCEDURE Get_visit_task_Id
   (p_workorder_id        IN  NUMBER,
    x_visit_task_id       OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_error_msg_code      OUT NOCOPY VARCHAR2
   ) IS

 BEGIN
    IF (p_workorder_id IS NOT NULL AND
        p_workorder_id <> FND_API.G_MISS_NUM) THEN

        SELECT visit_task_id INTO x_visit_task_id
               FROM AHL_WORKORDERS
            WHERE workorder_id = p_workorder_id;
      END IF;
             x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'XVISITTASK:'|| x_visit_task_id);
   END IF;

EXCEPTION
       WHEN NO_DATA_FOUND THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_PP_TASK_ID_NOT_EXIST';
       WHEN TOO_MANY_ROWS THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_PP_TASK_ID_NOT_EXIST';
       WHEN OTHERS THEN
         x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
         RAISE;
END Get_visit_task_Id;
--
PROCEDURE Get_workorder_Id
   (p_workorder_id        IN  NUMBER,
    p_job_number          IN VARCHAR2,
    x_workorder_id        OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_error_msg_code      OUT NOCOPY VARCHAR2
   ) IS
  --
 BEGIN
   --
    IF p_workorder_id IS NOT NULL THEN
    --
        SELECT workorder_id INTO x_workorder_id
               FROM AHL_WORKORDERS
            WHERE workorder_id = p_workorder_id;
    ELSE
     --
          SELECT workorder_id INTO x_workorder_id
                 FROM AHL_WORKORDERS
                WHERE workorder_name = p_job_number;
      END IF;

             x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'XWOID:'|| x_workorder_id);
    END IF;

EXCEPTION
       WHEN NO_DATA_FOUND THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_PP_WO_ID_NOT_EXIST';
       WHEN TOO_MANY_ROWS THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_PP_WO_ID_NOT_EXIST';
       WHEN OTHERS THEN
         x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
         RAISE;
END Get_workorder_Id;
--
PROCEDURE Get_workorder_operation_Id
   (p_workorder_id        IN  NUMBER,
    p_operation_sequence  IN  NUMBER,
    x_workorder_operation_id  OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_error_msg_code      OUT NOCOPY VARCHAR2
   ) IS

 BEGIN
    IF (p_workorder_id IS NOT NULL AND
         p_operation_sequence IS NOT NULL) THEN
       --
        SELECT workorder_operation_id INTO x_workorder_operation_id
               FROM AHL_WORKORDER_OPERATIONS
            WHERE workorder_id = p_workorder_id
             AND operation_sequence_num = p_operation_sequence;
        --
     END IF;
             x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

EXCEPTION
       WHEN NO_DATA_FOUND THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_PP_WO_OP_ID_NOT_EXIST';
       WHEN TOO_MANY_ROWS THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_PP_WO_OP_ID_NOT_EXIST';
       WHEN OTHERS THEN
         x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
         RAISE;
END Get_workorder_operation_Id;
--
PROCEDURE Get_inventory_item_Id
   (p_inventory_item_id       IN  NUMBER,
    p_concatenated_segments   IN  VARCHAR2,
    p_organization_id         IN  NUMBER,
    x_inventory_item_id       OUT NOCOPY NUMBER,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_error_msg_code          OUT NOCOPY VARCHAR2
   ) IS

 BEGIN
    IF (p_inventory_item_id IS NOT NULL AND
        p_inventory_item_id <> FND_API.G_MISS_NUM) THEN
        --
        SELECT inventory_item_id INTO x_inventory_item_id
        FROM MTL_SYSTEM_ITEMS_KFV
        WHERE inventory_item_id = p_inventory_item_id
        AND organization_id = p_organization_id
        AND inventory_item_flag = 'Y'
        AND stock_enabled_flag = 'Y'
        AND mtl_transactions_enabled_flag = 'Y'
        AND nvl(enabled_flag,'N') = 'Y'
        AND trunc(sysdate) between trunc(nvl(start_date_active, sysdate)) and trunc(nvl(end_date_active, sysdate));
     ELSE
        --
        SELECT inventory_item_id INTO x_inventory_item_id
        FROM MTL_SYSTEM_ITEMS_KFV
        WHERE concatenated_segments = p_concatenated_segments
        AND organization_id = p_organization_id
        AND inventory_item_flag = 'Y'
        AND stock_enabled_flag = 'Y'
        AND mtl_transactions_enabled_flag = 'Y'
        AND nvl(enabled_flag,'N') = 'Y'
        AND trunc(sysdate) between trunc(nvl(start_date_active, sysdate)) and trunc(nvl(end_date_active, sysdate));
     END IF;
             x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

EXCEPTION
       WHEN NO_DATA_FOUND THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_PP_INVALID_ITEM';
       WHEN OTHERS THEN
         x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
         RAISE;
END Get_inventory_item_Id;
--
PROCEDURE Get_visit_task_details
    ( p_visit_task_id       IN  NUMBER,
      x_visit_id            OUT NOCOPY NUMBER,
      x_organization_id     OUT NOCOPY NUMBER,
      x_department_id       OUT NOCOPY NUMBER,
      x_project_task_id     OUT NOCOPY NUMBER,
      x_project_id          OUT NOCOPY NUMBER
    )
 IS
   CURSOR get_visit_task_cur (c_visit_task_id IN NUMBER)
     IS
       SELECT visit_id,
              department_id,project_task_id
         FROM ahl_visit_tasks_b
      WHERE visit_task_id = c_visit_task_id;
  --
  CURSOR get_org_details_cur(c_visit_id IN NUMBER)
  IS
     SELECT organization_id,department_id,
            project_id
        FROM ahl_visits_b
      WHERE visit_id = c_visit_id;
  --
  l_visit_id        NUMBER;
  l_department_id   NUMBER;
  l_vdepartment_id  NUMBER;
  l_project_task_id NUMBER;
  l_project_id      NUMBER;
  l_organization_id NUMBER;
  l_schedule_designator VARCHAR2(10);
  --
 BEGIN
    OPEN get_visit_task_cur(p_visit_task_id);
    FETCH get_visit_task_cur INTO l_visit_id,l_department_id,l_project_task_id;
    CLOSE get_visit_task_cur;
    IF l_visit_id IS NOT NULL THEN
       OPEN get_org_details_cur (l_visit_id);
       FETCH get_org_details_cur INTO l_organization_id, l_vdepartment_id,
                                      l_project_id;
       CLOSE get_org_details_cur;
    END IF;
    --Assign
      x_organization_id := l_organization_id;
      x_department_id   := nvl(l_department_id,l_vdepartment_id);
      x_visit_id        := l_visit_id;
      x_project_task_id := l_project_task_id;
      x_project_id       := l_project_id;
 END Get_visit_task_details;
-- Insert procedure to create record in to schedule materials
PROCEDURE Insert_Row (
  X_SCHEDULED_MATERIAL_ID IN NUMBER,
  X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_INVENTORY_ITEM_ID IN VARCHAR2,
  X_SCHEDULE_DESIGNATOR IN VARCHAR2,
  X_VISIT_ID IN NUMBER,
  X_VISIT_START_DATE IN DATE,
  X_VISIT_TASK_ID IN NUMBER,
  X_ORGANIZATION_ID IN NUMBER,
  X_SCHEDULED_DATE IN DATE,
  X_REQUEST_ID IN NUMBER,
  X_REQUESTED_DATE IN DATE,
  X_SCHEDULED_QUANTITY IN NUMBER,
  X_PROCESS_STATUS IN NUMBER,
  X_ERROR_MESSAGE IN VARCHAR2,
  X_TRANSACTION_ID IN NUMBER,
  X_UOM    IN VARCHAR2,
  X_RT_OPER_MATERIAL_ID IN NUMBER,
  X_OPERATION_CODE IN VARCHAR2,
  X_OPERATION_SEQUENCE IN NUMBER,
  X_ITEM_GROUP_ID IN NUMBER,
  X_REQUESTED_QUANTITY IN NUMBER,
  X_PROGRAM_ID   IN NUMBER,
  X_PROGRAM_UPDATE_DATE  IN DATE,
  X_LAST_UPDATED_DATE IN DATE,
  X_WORKORDER_OPERATION_ID IN NUMBER,
  X_MATERIAL_REQUEST_TYPE IN VARCHAR2,
  X_STATUS  IN VARCHAR2,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2,
  X_ATTRIBUTE1 IN VARCHAR2,
  X_ATTRIBUTE2 IN VARCHAR2,
  X_ATTRIBUTE3 IN VARCHAR2,
  X_ATTRIBUTE4 IN VARCHAR2,
  X_ATTRIBUTE5 IN VARCHAR2,
  X_ATTRIBUTE6 IN VARCHAR2,
  X_ATTRIBUTE7 IN VARCHAR2,
  X_ATTRIBUTE8 IN VARCHAR2,
  X_ATTRIBUTE9 IN VARCHAR2,
  X_ATTRIBUTE10 IN VARCHAR2,
  X_ATTRIBUTE11 IN VARCHAR2,
  X_ATTRIBUTE12 IN VARCHAR2,
  X_ATTRIBUTE13 IN VARCHAR2,
  X_ATTRIBUTE14 IN VARCHAR2,
  X_ATTRIBUTE15 IN VARCHAR2,
  X_CREATION_DATE IN DATE,
  X_CREATED_BY IN NUMBER,
  X_LAST_UPDATE_DATE IN DATE,
  X_LAST_UPDATED_BY IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER
) IS
BEGIN
  INSERT INTO AHL_SCHEDULE_MATERIALS (
    SCHEDULED_MATERIAL_ID,
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
    REQUEST_ID,
    REQUESTED_DATE,
    SCHEDULED_QUANTITY,
    PROCESS_STATUS,
    ERROR_MESSAGE,
    TRANSACTION_ID,
    UOM,
    RT_OPER_MATERIAL_ID,
    OPERATION_CODE,
    OPERATION_SEQUENCE,
    ITEM_GROUP_ID,
    REQUESTED_QUANTITY,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    LAST_UPDATED_DATE,
    WORKORDER_OPERATION_ID,
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
  VALUES(
    X_SCHEDULED_MATERIAL_ID,
    X_OBJECT_VERSION_NUMBER,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_INVENTORY_ITEM_ID,
    X_SCHEDULE_DESIGNATOR,
    X_VISIT_ID,
    X_VISIT_START_DATE,
    X_VISIT_TASK_ID,
    X_ORGANIZATION_ID,
    X_SCHEDULED_DATE,
    X_REQUEST_ID,
    -- AnRaj: truncating Requested Date for Material Requirement based on discussions with PM
    trunc(X_REQUESTED_DATE),
    X_SCHEDULED_QUANTITY,
    X_PROCESS_STATUS,
    X_ERROR_MESSAGE,
    X_TRANSACTION_ID,
    X_UOM,
    X_RT_OPER_MATERIAL_ID,
    X_OPERATION_CODE,
    X_OPERATION_SEQUENCE,
    X_ITEM_GROUP_ID,
    X_REQUESTED_QUANTITY,
    X_PROGRAM_ID,
    X_PROGRAM_UPDATE_DATE,
    X_LAST_UPDATED_DATE,
    X_WORKORDER_OPERATION_ID,
    X_MATERIAL_REQUEST_TYPE,
    X_STATUS,
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
   --
END Insert_Row;
--Update procedure to update record in schedule materials entity
PROCEDURE UPDATE_ROW (
  X_SCHEDULED_MATERIAL_ID IN NUMBER,
  X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_INVENTORY_ITEM_ID IN VARCHAR2,
  X_SCHEDULE_DESIGNATOR IN VARCHAR2,
  X_VISIT_ID IN NUMBER,
  X_VISIT_START_DATE IN DATE,
  X_VISIT_TASK_ID IN NUMBER,
  X_ORGANIZATION_ID IN NUMBER,
  X_SCHEDULED_DATE IN DATE,
  X_REQUEST_ID IN NUMBER,
  X_REQUESTED_DATE IN DATE,
  X_SCHEDULED_QUANTITY IN NUMBER,
  X_PROCESS_STATUS IN NUMBER,
  X_ERROR_MESSAGE IN VARCHAR2,
  X_TRANSACTION_ID IN NUMBER,
  X_UOM    IN VARCHAR2,
  X_RT_OPER_MATERIAL_ID IN NUMBER,
  X_OPERATION_CODE IN VARCHAR2,
  X_OPERATION_SEQUENCE IN NUMBER,
  X_ITEM_GROUP_ID IN NUMBER,
  X_REQUESTED_QUANTITY IN NUMBER,
  X_PROGRAM_ID   IN NUMBER,
  X_PROGRAM_UPDATE_DATE  IN DATE,
  X_LAST_UPDATED_DATE IN DATE,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2,
  X_ATTRIBUTE1 IN VARCHAR2,
  X_ATTRIBUTE2 IN VARCHAR2,
  X_ATTRIBUTE3 IN VARCHAR2,
  X_ATTRIBUTE4 IN VARCHAR2,
  X_ATTRIBUTE5 IN VARCHAR2,
  X_ATTRIBUTE6 IN VARCHAR2,
  X_ATTRIBUTE7 IN VARCHAR2,
  X_ATTRIBUTE8 IN VARCHAR2,
  X_ATTRIBUTE9 IN VARCHAR2,
  X_ATTRIBUTE10 IN VARCHAR2,
  X_ATTRIBUTE11 IN VARCHAR2,
  X_ATTRIBUTE12 IN VARCHAR2,
  X_ATTRIBUTE13 IN VARCHAR2,
  X_ATTRIBUTE14 IN VARCHAR2,
  X_ATTRIBUTE15 IN VARCHAR2,
  X_CREATION_DATE IN DATE,
  X_CREATED_BY IN NUMBER,
  X_LAST_UPDATE_DATE IN DATE,
  X_LAST_UPDATED_BY IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER
) IS
BEGIN
  UPDATE AHL_SCHEDULE_MATERIALS SET
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER + 1,
    INVENTORY_ITEM_ID = X_INVENTORY_ITEM_ID,
    SCHEDULE_DESIGNATOR = X_SCHEDULE_DESIGNATOR,
    VISIT_ID = X_VISIT_ID,
    VISIT_START_DATE = X_VISIT_START_DATE,
    VISIT_TASK_ID = X_VISIT_TASK_ID,
    ORGANIZATION_ID = X_ORGANIZATION_ID,
    SCHEDULED_DATE = X_SCHEDULED_DATE,
    REQUEST_ID = X_REQUEST_ID,
    -- AnRaj: truncating Requested Date for Material Requirement based on discussions with PM
    REQUESTED_DATE = trunc(X_REQUESTED_DATE),
    SCHEDULED_QUANTITY = X_SCHEDULED_QUANTITY,
    PROCESS_STATUS = X_PROCESS_STATUS,
    ERROR_MESSAGE = X_ERROR_MESSAGE,
    TRANSACTION_ID = X_TRANSACTION_ID,
    UOM = X_UOM,
    RT_OPER_MATERIAL_ID = X_RT_OPER_MATERIAL_ID,
    OPERATION_CODE = X_OPERATION_CODE,
    OPERATION_SEQUENCE = X_OPERATION_SEQUENCE,
    ITEM_GROUP_ID = X_ITEM_GROUP_ID,
    REQUESTED_QUANTITY = X_REQUESTED_QUANTITY,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    LAST_UPDATED_DATE = X_LAST_UPDATED_DATE,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
    WHERE SCHEDULED_MATERIAL_ID = X_SCHEDULED_MATERIAL_ID
    AND   OBJECT_VERSION_NUMBER=X_OBJECT_VERSION_NUMBER;
  IF SQL%rowcount=0 THEN
           Fnd_Message.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
           Fnd_Msg_Pub.ADD;
  END IF;
END UPDATE_ROW;
-- Delete procedure to remove record from schedule materials
PROCEDURE DELETE_ROW (
  X_SCHEDULED_MATERIAL_ID IN NUMBER
) IS
BEGIN
  DELETE FROM AHL_SCHEDULE_MATERIALS
  WHERE SCHEDULED_MATERIAL_ID = X_SCHEDULED_MATERIAL_ID;
END DELETE_ROW;
--
-- Start of Comments --
--  Procedure name    : Create_Material_Reqst
--  Type              : Private
--  Function          : Validates Material Information and inserts records into
--                      Schedule Material table for non routine jobs Calls AHL_WIP_JOB_PVT.
--                      update_wip_job api
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_interface_flag                IN      VARCHAR2,
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Create Material Request Parameters:
--       p_x_req_material_tbl     IN OUT NOCOPY Req_Material_Tbl_Type,
--         Contains material information to perform material reservation
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Create_Material_Reqst (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_interface_flag         IN            VARCHAR2   ,
    p_x_req_material_tbl     IN OUT NOCOPY Req_Material_Tbl_Type,
    x_job_return_status         OUT  NOCOPY       VARCHAR2,
    x_return_status             OUT  NOCOPY       VARCHAR2,
    x_msg_count                 OUT  NOCOPY       NUMBER,
    x_msg_data                  OUT  NOCOPY       VARCHAR2
  )

 IS
 --Check for unique constraint
 CURSOR Check_unique_cur(c_item_id      IN NUMBER,
                         c_operation_id IN NUMBER,
                         c_org_id       IN NUMBER,
                         c_sequence_id  IN NUMBER)
  IS
  SELECT 1
   FROM  AHL_SCHEDULE_MATERIALS
 WHERE inventory_item_id = c_item_id
  AND  workorder_operation_id = c_operation_id
  AND  organization_id = c_org_id
  AND  operation_sequence = c_sequence_id
  AND requested_quantity <> 0
  AND status IN ('ACTIVE','IN-SERVICE');
  -- Get job number details
  CURSOR Get_job_number(c_workorder_id IN NUMBER)
    IS
    SELECT workorder_name job_number,
             wip_entity_id
      FROM ahl_workorders
    WHERE workorder_id = c_workorder_id;
   -- Fix for bug# 6594189. Allow for statuses all statuses other than closed,
   -- cancelled, parts hold etc.
   --Check for status
   CURSOR Check_wo_status_cur(c_workorder_id IN NUMBER)
   IS
    SELECT 1 FROM ahl_workorders
     WHERE workorder_id = c_workorder_id
      /*
       AND  (status_code = 3 or
             status_code = 1);
      */
      AND status_code NOT IN ('12','5','6','7','17','22','19');

   --Check for Route item
   CURSOR Get_rt_mat_cur (c_visit_task_id  IN NUMBER,
                          c_rt_oper_mat_id IN NUMBER)
   IS
   SELECT  *
     FROM ahl_schedule_materials
   WHERE rt_oper_material_id = c_rt_oper_mat_id
   AND visit_task_id = c_visit_task_id
   AND requested_quantity <> 0
   AND status IN ('ACTIVE','IN-SERVICE');
  --Check to calidate for dates
  CURSOR Get_sch_dates_cur(c_wo_operation_id IN NUMBER,
                            c_req_date   IN DATE)
   IS
    SELECT 1
      FROM ahl_workorder_operations_v
    WHERE workorder_operation_id = c_wo_operation_id
     AND c_req_date between trunc(scheduled_start_date)
     and trunc(scheduled_end_date) ;
  -- TO Get uom code for meaning
   CURSOR Uom_cur (uom_mean IN VARCHAR2) IS
    SELECT UOM_CODE
      FROM MTL_UNITS_OF_MEASURE
    WHERE UNIT_OF_MEASURE = uom_mean;
   -- Get Primary Uom Code
   CURSOR Primary_Uom_cur (c_item_id IN NUMBER,
                           c_org_id  IN NUMBER) IS
    SELECT primary_uom_code
      FROM MTL_SYSTEM_ITEMS_VL
    WHERE inventory_item_id = c_item_id
      AND organization_id = c_org_id;
   --Get operation sequnece
   CURSOR Get_Operation_Seq_cur(c_operation_id IN NUMBER)
    IS
   SELECT operation_sequence_num
     FROM ahl_workorder_operations
   WHERE workorder_operation_id = c_operation_id;

   -- sracha: added for bug# 6802777.
   -- derive dept. from wip-operations.
   CURSOR get_oper_dept(c_wip_entity_id IN NUMBER,
                        c_oper_seq_num  IN NUMBER)
   IS
   SELECT wo.department_id
   FROM WIP_OPERATIONS WO
   WHERE wo.wip_entity_id = c_wip_entity_id
     AND wo.operation_seq_num = c_oper_seq_num;

 l_api_name        CONSTANT VARCHAR2(30) := 'CREATE_MATERIAL_REQST';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 l_dummy                    NUMBER;
 l_junk                     NUMBER;
 l_return_staus             VARCHAR2(1);
 --
 l_visit_task_id            NUMBER;
 l_inventory_item_id        NUMBER;
 l_visit_id                 NUMBER;
 l_organization_id          NUMBER;
 l_department_id            NUMBER;
 l_project_task_id          NUMBER;
 l_project_id               NUMBER;
 l_schedule_material_id     NUMBER;
 l_schedule_designator      VARCHAR2(10);
 l_workorder_id             NUMBER;
 l_workorder_name           VARCHAR2(80);
 l_wip_entity_id            NUMBER;
 l_workorder_operation_id   NUMBER;
 l_wo_organization_id       NUMBER;
 l_object_version_number    NUMBER;
 l_init_msg_list            VARCHAR2(1) := FND_API.G_TRUE;
 l_Req_Material_Tbl         Req_Material_Tbl_Type;
 l_default                  VARCHAR2(30);
 l_wo_operation_txn_id   NUMBER;
 l_schedule_start_date  DATE;
 l_schedule_end_date    DATE;
 --
 l_record_loaded        VARCHAR2(1);
 l_transaction_id       NUMBER;
 l_module_type          VARCHAR2(10);
 l_material_rec        Get_rt_mat_cur%ROWTYPE;
 j   NUMBER;
 l_mrp_net_flag        NUMBER;

 dff_default_values dff_default_values_type;

 BEGIN
   --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT create_material_reqst;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'enter ahl_pp_materias_pvt. create material  reqst','+PPMRP+');
   AHL_DEBUG_PUB.debug( 'INTERAFCE FALG'||p_interface_flag);
   AHL_DEBUG_PUB.debug( 'Total Number Records:'||p_x_req_material_tbl.COUNT);
   END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(l_init_msg_list)
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
 IF p_x_req_material_tbl.COUNT > 0 THEN
      FOR i IN p_x_req_material_tbl.FIRST..p_x_req_material_tbl.LAST
        LOOP
     -- Value to ID Conversion
     IF G_DEBUG='Y' THEN
     AHL_DEBUG_PUB.debug( 'WOID 1:'||p_x_req_material_tbl(i).workorder_id);
     AHL_DEBUG_PUB.debug( 'OPFLAG 1:'||p_x_req_material_tbl(i).operation_flag);
     AHL_DEBUG_PUB.debug( 'ITEM:'||i||'-'||p_x_req_material_tbl(i).concatenated_segments);

     END IF;

    IF ( ( p_x_req_material_tbl(i).workorder_id IS NOT NULL AND
           p_x_req_material_tbl(i).workorder_id <> FND_API.G_MISS_NUM ) OR
        ( p_x_req_material_tbl(i).job_number IS NOT NULL AND
          p_x_req_material_tbl(i).job_number <> FND_API.G_MISS_CHAR ) )
  THEN
     --
     IF G_DEBUG='Y' THEN
     AHL_DEBUG_PUB.debug( 'WOID 2:'||p_x_req_material_tbl(i).workorder_id);
       END IF;
     --
      Get_workorder_id
             (p_workorder_id      => p_x_req_material_tbl(i).workorder_id,
              p_job_number        => p_x_req_material_tbl(i).job_number,
              x_workorder_id      => l_workorder_id,
              x_return_status     => l_return_status,
              x_error_msg_code    => l_msg_data);

            IF NVL(l_return_status,'x') <> 'S'
            THEN
                Fnd_Message.SET_NAME('AHL','AHL_PP_WO_ORD_NOT_EXISTS');
                Fnd_Msg_Pub.ADD;
            END IF;
     --
     END IF;

     -- rroy
     -- ACL Changes
     --Get Job Number
     OPEN Get_job_number(p_x_req_material_tbl(i).workorder_id);
     FETCH Get_job_number INTO l_workorder_name,l_wip_entity_id;
     CLOSE Get_job_number;

     l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked
                        (
                          p_workorder_id => nvl(p_x_req_material_tbl(i).workorder_id,l_workorder_id),
                          p_ue_id => NULL,
                          p_visit_id => NULL,
                          p_item_instance_id => NULL
                        );
    IF l_return_status = FND_API.G_TRUE THEN
       FND_MESSAGE.Set_Name('AHL', 'AHL_PP_CRT_MTL_UNTLCKD');
       FND_MESSAGE.Set_Token('WO_NAME', l_workorder_name);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- rroy
    -- ACL Changes
    --
    p_x_req_material_tbl(i).workorder_id  := nvl(p_x_req_material_tbl(i).workorder_id,l_workorder_id);
    --Get visit task id
    IF (p_x_req_material_tbl(i).workorder_id IS NOT NULL AND
        p_x_req_material_tbl(i).workorder_id <> Fnd_Api.G_MISS_NUM )
    THEN

          Get_visit_task_Id
             (p_workorder_id      => p_x_req_material_tbl(i).workorder_id,
              x_visit_task_id     => l_visit_task_id,
              x_return_status     => l_return_status,
              x_error_msg_code    => l_msg_data);

            IF NVL(l_return_status,'x') <> 'S'
            THEN
                Fnd_Message.SET_NAME('AHL','AHL_PP_VISIT_TASK_NOT_EXIST');
                Fnd_Msg_Pub.ADD;

            END IF;
    END IF;
    -- Assign
    p_x_req_material_tbl(i).visit_task_id := l_visit_task_id;
    IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'VTID'||p_x_req_material_tbl(i).visit_task_id);
       AHL_DEBUG_PUB.debug( 'Job Number:'||p_x_req_material_tbl(i).job_number);

    END IF;
    -- Validate for organization,department,project_task_id
    Get_visit_task_details
             ( p_visit_task_id       => l_visit_task_id,
               x_visit_id            => l_visit_id,
               x_organization_id     => l_organization_id,
               x_department_id       => l_department_id,
               x_project_task_id     => l_project_task_id,
               x_project_id          => l_project_id
              );
    -- Validate for organization
    IF l_organization_id IS NULL THEN
        Fnd_Message.SET_NAME('AHL','AHL_PP_ORG_ID_NOT_EXISTS');
        Fnd_Msg_Pub.ADD;
    END IF;

    -- rroy
    -- ACL Changes
    /*--Get Job Number
    OPEN Get_job_number(p_x_req_material_tbl(i).workorder_id);
    FETCH Get_job_number INTO l_workorder_name,l_wip_entity_id;
    CLOSE Get_job_number;
    */
    -- rroy
    -- ACL Changes

    --Assign
    p_x_req_material_tbl(i).job_number := l_workorder_name;

    -- Validate for project task
    IF (p_interface_flag = 'Y'OR p_interface_flag IS NULL) THEN
        --Check for workorder status
        --
        OPEN Check_wo_status_cur(p_x_req_material_tbl(i).workorder_id);
        FETCH Check_wo_status_cur INTO l_dummy;
        IF Check_wo_status_cur%NOTFOUND THEN
        --
          Fnd_Message.SET_NAME('AHL','AHL_PP_WO_STATUS_INVALID');
          Fnd_Msg_Pub.ADD;
        END IF;
        --
        CLOSE Check_wo_status_cur;
            --
    END IF;--Condition for interface flag
        --
        p_x_req_material_tbl(i).organization_id := l_organization_id;
        p_x_req_material_tbl(i).department_id   := l_department_id;
        p_x_req_material_tbl(i).visit_id        := l_visit_id;
        p_x_req_material_tbl(i).project_task_id := l_project_task_id;
        p_x_req_material_tbl(i).project_id := l_project_id;
        --

    IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'ORID'||p_x_req_material_tbl(i).organization_id);
       AHL_DEBUG_PUB.debug( 'DEID'||p_x_req_material_tbl(i).department_id);
       AHL_DEBUG_PUB.debug( 'PTID'||p_x_req_material_tbl(i).project_task_id);
       AHL_DEBUG_PUB.debug( 'PJID'||p_x_req_material_tbl(i).project_id);
       AHL_DEBUG_PUB.debug( 'CITEM:'||p_x_req_material_tbl(i).concatenated_segments);
    END IF;
    -- Convert concatenated segments to Item ID
    IF (p_x_req_material_tbl(i).concatenated_segments IS NOT NULL AND
        p_x_req_material_tbl(i).concatenated_segments <> Fnd_Api.G_MISS_CHAR )   OR
       (p_x_req_material_tbl(i).inventory_item_id IS NOT NULL AND
        p_x_req_material_tbl(i).inventory_item_id <> Fnd_Api.G_MISS_NUM) THEN

            Get_inventory_item_Id
                 (p_inventory_item_id     => p_x_req_material_tbl(i).inventory_item_id,
                  p_concatenated_segments => p_x_req_material_tbl(i).concatenated_segments,
                  p_organization_id       => l_organization_id,
                  x_inventory_item_id     => l_inventory_item_id,
                  x_return_status         => l_return_status,
                  x_error_msg_code        => l_msg_data);

            IF NVL(l_return_status,'x') <> 'S'
            THEN
                Fnd_Message.SET_NAME('AHL','AHL_PP_INVALID_ITEM');
                Fnd_Msg_Pub.ADD;
            END IF;
    ELSE
             Fnd_Message.SET_NAME('AHL','AHL_PP_INV_ID_REQUIRED');
             Fnd_Msg_Pub.ADD;

    END IF;

   --Assign the returned value
   p_x_req_material_tbl(i).inventory_item_id := l_inventory_item_id;
   IF G_DEBUG='Y' THEN
     AHL_DEBUG_PUB.debug( 'IVID'||p_x_req_material_tbl(i).requested_quantity);
   END IF;

   -- Validate for Requested Quantity
   IF (p_x_req_material_tbl(i).requested_quantity IS  NULL OR
       p_x_req_material_tbl(i).requested_quantity = FND_API.G_MISS_NUM ) THEN
       Fnd_Message.SET_NAME('AHL','AHL_PP_REQ_QUANTITY_REQUIRED');
       Fnd_Msg_Pub.ADD;
   ELSIF (p_x_req_material_tbl(i).requested_quantity IS NOT NULL AND
          p_x_req_material_tbl(i).requested_quantity <> FND_API.G_MISS_NUM) THEN
         -- Fix for FP bug# 6642084. -- Allow 0 quantity.
         IF p_x_req_material_tbl(i).requested_quantity < 0 THEN
             Fnd_Message.SET_NAME('AHL','AHL_PP_REQ_QUANTITY_INVALID');
             Fnd_Msg_Pub.ADD;
         END IF;
   END IF;
   --

   IF G_DEBUG='Y' THEN
     AHL_DEBUG_PUB.debug( 'RDATE1:'||p_x_req_material_tbl(i).requested_date);
   END IF;
   --
   IF (p_interface_flag = 'Y' OR p_interface_flag is null )THEN

        -- Validate for Requested Date
       IF (p_x_req_material_tbl(i).requested_date IS  NULL OR
           p_x_req_material_tbl(i).requested_date = FND_API.G_MISS_DATE ) THEN
             Fnd_Message.SET_NAME('AHL','AHL_PP_REQ_DATE_REQUIRED');
             Fnd_Msg_Pub.ADD;
        ELSIF (p_x_req_material_tbl(i).requested_date IS NOT NULL AND
              p_x_req_material_tbl(i).requested_date <> FND_API.G_MISS_DATE) THEN
          IF p_x_req_material_tbl(i).requested_date < trunc(SYSDATE) THEN
             Fnd_Message.SET_NAME('AHL','AHL_PP_REQ_DATE_GT_SYSD');
             Fnd_Msg_Pub.ADD;
           END IF;
        END IF;
   END IF;
   --
   IF G_DEBUG='Y' THEN
     AHL_DEBUG_PUB.debug( 'RDATE'||p_x_req_material_tbl(i).requested_date);
     AHL_DEBUG_PUB.debug( 'OSID'||p_x_req_material_tbl(i).operation_sequence);
   END IF;
   --Check for operation sequence
   IF( p_x_req_material_tbl(i).operation_sequence IS NULL OR
       p_x_req_material_tbl(i).operation_sequence = FND_API.G_MISS_NUM)
      THEN
      IF  (p_x_req_material_tbl(i).workorder_operation_id IS  NOT NULL AND
           p_x_req_material_tbl(i).workorder_operation_id <> FND_API.G_MISS_NUM)
          THEN
             --
                   OPEN  Get_Operation_Seq_cur(p_x_req_material_tbl(i).workorder_operation_id);
                   FETCH Get_Operation_Seq_cur INTO p_x_req_material_tbl(i).operation_sequence;
                   IF Get_Operation_Seq_cur%NOTFOUND THEN
               Fnd_Message.SET_NAME('AHL','AHL_PP_OPER_SEQ_REQD');
               Fnd_Msg_Pub.ADD;
                   END IF;
               CLOSE Get_Operation_Seq_cur;
        END IF;
   END IF;
   --
-- dbms_output.put_line( 'after fetch:'||p_x_req_material_tbl(i).operation_sequence);
-- dbms_output.put_line( 'after fetch:'||p_x_req_material_tbl(i).workorder_operation_id);
-- dbms_output.put_line( 'interface flag:'||p_interface_flag);

   -- Check for workorder operation ID
   IF G_DEBUG='Y' THEN
     AHL_DEBUG_PUB.debug('OPID'||p_x_req_material_tbl(i).workorder_operation_id);
   END IF;

   --
   IF  (p_x_req_material_tbl(i).workorder_operation_id IS  NULL OR
        p_x_req_material_tbl(i).workorder_operation_id = FND_API.G_MISS_NUM)
      THEN
       -- Validate for workorder operation
        IF (p_x_req_material_tbl(i).operation_sequence IS NOT NULL AND
         p_x_req_material_tbl(i).operation_sequence <> FND_API.G_MISS_NUM) THEN
         --
           Get_workorder_operation_Id
                (p_workorder_id           => p_x_req_material_tbl(i).workorder_id,
                 p_operation_sequence     => p_x_req_material_tbl(i).operation_sequence,
                 x_workorder_operation_id => l_workorder_operation_id,
                 x_return_status          => l_return_status,
                 x_error_msg_code         => l_msg_data);

            IF NVL(l_return_status,'x') <> 'S'
            THEN
                Fnd_Message.SET_NAME('AHL','AHL_PP_WO_OP_ID_NOT_EXIST');
                Fnd_Msg_Pub.ADD;
                --
            END IF;
         END IF;
   END IF;
   -- Assigns operation id when called from UI
   IF (p_x_req_material_tbl(i).workorder_operation_id <> FND_API.G_MISS_NUM OR
       p_x_req_material_tbl(i).workorder_operation_id IS NULL )
   THEN
     --
     p_x_req_material_tbl(i).workorder_operation_id := NVL(p_x_req_material_tbl(i).workorder_operation_id,l_workorder_operation_id);
   ELSE
     p_x_req_material_tbl(i).workorder_operation_id := l_workorder_operation_id;
   END IF;
    --
   /* sracha: Fix bug#6594189.
    * commented out date validation against workorder scheduled dates.
    * we should allow creation of material requirements irrespective of
    * workorder
    * scheduled dates. Note: This validation is triggered only when creating
    * material requirement.
   IF (
        (
          p_interface_flag = 'Y' or p_interface_flag IS NULL
        )
        AND
        (
          -- Check added by balaji for bug # 4093650
          -- When workorder_operation_id is null or g_miss then date check should not
          -- be performed.
          p_x_req_material_tbl(i).workorder_operation_id IS NOT NULL AND
          p_x_req_material_tbl(i).workorder_operation_id <> FND_API.G_MISS_NUM
        )
     )
   THEN
      --Check for requested date should be in schedule start date schedule end date
      OPEN Get_sch_dates_cur(p_x_req_material_tbl(i).workorder_operation_id,
                           trunc(p_x_req_material_tbl(i).requested_date)) ;
      FETCH Get_sch_dates_cur INTO l_dummy;
      --
      IF Get_sch_dates_cur%NOTFOUND THEN
         Fnd_Message.SET_NAME('AHL','AHL_PP_RE_DATE_SCH_DATE');
         Fnd_Msg_Pub.ADD;
      END IF;
      --
      CLOSE Get_sch_dates_cur;
      --
   END IF;
   */

   IF G_DEBUG='Y' THEN
     AHL_DEBUG_PUB.debug('Local OPID:'||l_workorder_operation_id);
     AHL_DEBUG_PUB.debug('OPID2 :'||p_x_req_material_tbl(i).workorder_operation_id);
   END IF;
   --Check for operation sequence
-- dbms_output.put_line( 'before uinque check:'||p_x_req_material_tbl(i).inventory_item_id);
-- dbms_output.put_line( 'before unique check:'||p_x_req_material_tbl(i).organization_id);
-- dbms_output.put_line( 'before uinque check:'||p_x_req_material_tbl(i).workorder_operation_id);
-- dbms_output.put_line( 'before unique check:'||p_x_req_material_tbl(i).operation_sequence);
-- dbms_output.put_line( 'before unique check:'||p_x_req_material_tbl(i).requested_date);

   --Check for record exists in schedule materials entity
   OPEN Check_unique_cur(p_x_req_material_tbl(i).inventory_item_id,
                         p_x_req_material_tbl(i).workorder_operation_id,
                         p_x_req_material_tbl(i).organization_id,
                         p_x_req_material_tbl(i).operation_sequence);
   FETCH Check_unique_cur INTO l_dummy;
   --
   IF Check_unique_cur%FOUND THEN
        Fnd_Message.SET_NAME('AHL','AHL_MAT_RECORD_EXIST');
        FND_MESSAGE.SET_TOKEN('ITEM',p_x_req_material_tbl(i).concatenated_segments,false);
        Fnd_Msg_Pub.ADD;

   END IF;
   --
   CLOSE Check_unique_cur;
   --
 --dbms_output.put_line( 'before uom conversion:'||p_x_req_material_tbl(i).inventory_item_id);
-- dbms_output.put_line( 'before uom conversion:'||p_x_req_material_tbl(i).organization_id);
-- dbms_output.put_line( 'before uom WO:'||p_x_req_material_tbl(i).workorder_id);

   -- Convert Uom code
   IF (p_x_req_material_tbl(i).UOM_MEANING IS NOT NULL AND p_x_req_material_tbl(i).UOM_MEANING <> FND_API.G_MISS_CHAR)
   THEN
        --
         OPEN Uom_cur(p_x_req_material_tbl(i).UOM_MEANING);
         FETCH Uom_cur INTO p_x_req_material_tbl(i).UOM_CODE;
         CLOSE Uom_cur;
         -- Get the primary UOM
    ELSE
        OPEN Primary_Uom_cur(p_x_req_material_tbl(i).inventory_item_id,
                                 p_x_req_material_tbl(i).organization_id);
            FETCH Primary_Uom_cur INTO p_x_req_material_tbl(i).uom_code;
            CLOSE Primary_Uom_cur;

    END IF;

    -- OGMA issue # 105 - begin
    IF (
         p_x_req_material_tbl(i).REPAIR_ITEM IS NOT NULL AND
         p_x_req_material_tbl(i).REPAIR_ITEM = 'Y'
       )
    THEN
        p_x_req_material_tbl(i).STATUS := 'IN-SERVICE';
    END IF;
    -- OGMA issue # 105 - end

-- dbms_output.put_line( 'after uom conversion UOM:'||p_x_req_material_tbl(i).uom_code);

    -- Standard call to get message count and if count is  get message info.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
         X_msg_count := l_msg_count;
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
END LOOP;
END IF;

-- dbms_output.put_line( 'before wip jobs:'||p_x_req_material_tbl.COUNT);
-- dbms_output.put_line( 'before wip jobs flag:'||p_interface_flag);

-- Calling Wip job api
IF (p_interface_flag = 'Y' OR p_interface_flag IS NULL )THEN
    --
-- dbms_output.put_line( 'inside:'||p_interface_flag);

--    IF G_DEBUG='Y' THEN
--    AHL_DEBUG_PUB.debug('after interface flag yes or null call:'||p_x_req_material_tbl(1).workorder_id);
--    END IF;
       --
-- dbms_output.put_line( 'inside:'||p_interface_flag);

      IF p_x_req_material_tbl.COUNT >0
        THEN
        j := 1;
        FOR i in p_x_req_material_tbl.FIRST..p_x_req_material_tbl.LAST
        LOOP
         --
            OPEN Get_job_number(p_x_req_material_tbl(i).workorder_id);
            FETCH Get_job_number INTO l_workorder_name,l_wip_entity_id;
            CLOSE Get_job_number;
           --
           -- sracha: Fix for FP bug# 6802777.
           -- derive dept. ID for the operation.
           OPEN get_oper_dept(l_wip_entity_id, p_x_req_material_tbl(i).operation_sequence);
           FETCH get_oper_dept INTO l_department_id;
           IF (get_oper_dept%FOUND) THEN
              p_x_req_material_tbl(i).department_id := l_department_id;
           END IF;
           CLOSE get_oper_dept;
           --
           l_req_material_tbl(j).JOB_NUMBER             := l_workorder_name;
           l_req_material_tbl(j).WIP_ENTITY_ID          := l_wip_entity_id;
           l_req_material_tbl(j).WORKORDER_ID           := p_x_req_material_tbl(i).workorder_id;
           l_req_material_tbl(j).OPERATION_SEQUENCE     :=p_x_req_material_tbl(i).operation_sequence;
           l_req_material_tbl(j).INVENTORY_ITEM_ID      :=p_x_req_material_tbl(i).inventory_item_id;
           l_req_material_tbl(j).UOM_CODE               :=p_x_req_material_tbl(i).uom_code;
           l_req_material_tbl(j).ORGANIZATION_ID        :=p_x_req_material_tbl(i).organization_id;
           -- fix for bug# 5549135.
           --l_req_material_tbl(j).MRP_NET_FLAG           :=1;
           l_req_material_tbl(j).MRP_NET_FLAG           :=2;
           l_req_material_tbl(j).QUANTITY_PER_ASSEMBLY  :=p_x_req_material_tbl(i).requested_quantity;
           l_req_material_tbl(j).REQUESTED_QUANTITY     :=p_x_req_material_tbl(i).requested_quantity;
           l_req_material_tbl(j).SUPPLY_TYPE            :=NULL;
           l_req_material_tbl(j).LOCATION               :=NULL;
           l_req_material_tbl(j).SUB_INVENTORY          :=NULL;
           l_req_material_tbl(j).REQUESTED_DATE         :=p_x_req_material_tbl(i).requested_date;
           l_req_material_tbl(j).OPERATION_FLAG         :='C';
           -- sracha: Fix for FP bug# 6802777.
           l_req_material_tbl(j).DEPARTMENT_ID          := p_x_req_material_tbl(i).department_id;
           --
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug('Before Eam job pvt.InentoryItemID:'||l_req_material_tbl(j).INVENTORY_ITEM_ID);
   AHL_DEBUG_PUB.debug('Before Eam job pvt.Quantity:'||l_req_material_tbl(j).REQUESTED_QUANTITY);
   AHL_DEBUG_PUB.debug('Before Eam job pvt.Uom:'||l_req_material_tbl(j).UOM_CODE);
   AHL_DEBUG_PUB.debug('Before Eam job pvt.WorkorderID:'||l_req_material_tbl(j).WORKORDER_ID);
   AHL_DEBUG_PUB.debug('Before Eam job pvt.WipentityID:'||l_req_material_tbl(j).WIP_ENTITY_ID);
   AHL_DEBUG_PUB.debug('Before Eam job pvt.OrganizationID:'||l_req_material_tbl(j).ORGANIZATION_ID);
   AHL_DEBUG_PUB.debug('Before Eam job pvt.Jobmumber:'||l_req_material_tbl(j).JOB_NUMBER);
   AHL_DEBUG_PUB.debug('Before Eam job pvt.OperationSequence:'||l_req_material_tbl(j).OPERATION_SEQUENCE);
   END IF;

--  dbms_output.put_line( 'Before Eam job pvt.InentoryItemID:'||l_req_material_tbl(j).INVENTORY_ITEM_ID);
--  dbms_output.put_line( 'Before Eam job pvt.quantity:'||l_req_material_tbl(j).REQUESTED_QUANTITY);
--  dbms_output.put_line( 'Before Eam job pvt.uom:'||l_req_material_tbl(j).UOM_CODE);
--  dbms_output.put_line( 'Before Eam job pvt.workorderID:'||l_req_material_tbl(j).WORKORDER_ID);
--  dbms_output.put_line( 'Before Eam job pvt.wip entity:'||l_req_material_tbl(j).WIP_ENTITY_ID);
--  dbms_output.put_line( 'Before Eam job pvt.OPERATION SEQ:'||l_req_material_tbl(j).OPERATION_SEQUENCE);
--  dbms_output.put_line( 'Before Eam job pvt.date:'||l_req_material_tbl(j).REQUESTED_DATE);

       j := j+1;
       --
         END LOOP;
       END IF; --Material tbl
       --
-- dbms_output.put_line( 'before wip jobs:');

   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug('before wip job call');
   END IF;
       -- Before Ahl Eam job Call

 AHL_EAM_JOB_PVT.process_material_req
(
  p_api_version        => l_api_version,
  p_init_msg_list      => l_init_msg_list,
  p_commit             => p_commit,
  p_validation_level   => p_validation_level,
  p_default            => l_default,
  p_module_type        => l_module_type,
  x_return_status      => l_return_status,
  x_msg_count          => l_msg_count,
  x_msg_data           => l_msg_data,
  p_material_req_tbl   => l_req_material_tbl);


-- dbms_output.put_line( 'after wip jobs:'||l_return_status);

   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug('after wip job call:'||l_return_status);
   AHL_DEBUG_PUB.debug('after wip job call:'||l_msg_count);
   AHL_DEBUG_PUB.debug('after wip job call:'||l_msg_data);
   END IF;
      --
    l_msg_count := FND_MSG_PUB.count_msg;
    --
     IF l_msg_count > 0 THEN
         X_msg_count := l_msg_count;
         X_msg_data  := l_msg_data;
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

END IF;
--
 IF G_DEBUG='Y' THEN
 AHL_DEBUG_PUB.debug('Before insert status call');
 END IF;
-- dbms_output.put_line( 'after wip jobs:');

 --
IF l_return_status ='S' THEN
   --Change made on Nov 17, 2005 by jeli due to bug 4742895.
   --Ignore messages in stack if return status is S after calls to EAM APIs.
   FND_MSG_PUB.initialize;

-- dbms_output.put_line( 'inside return status success:');

  IF p_x_req_material_tbl.COUNT > 0 THEN
    --
    FOR i IN p_x_req_material_tbl.FIRST..p_x_req_material_tbl.LAST
      LOOP
       --
       IF  (p_x_req_material_tbl(i).schedule_material_id = FND_API.G_MISS_NUM OR
            p_x_req_material_tbl(i).schedule_material_id IS NULL )
       THEN
          -- Thease conditions are required for optional fields
          IF p_x_req_material_tbl(i).visit_start_date = FND_API.G_MISS_DATE
          THEN
           l_Req_Material_Tbl(i).visit_start_date := NULL;
          ELSE
           l_Req_Material_Tbl(i).visit_start_date := p_x_req_material_tbl(i).visit_start_date;
          END IF;
          -- Scheduled Date
          IF p_x_req_material_tbl(i).scheduled_date = FND_API.G_MISS_DATE
          THEN
           l_Req_Material_Tbl(i).scheduled_date := NULL;
          ELSE
           l_Req_Material_Tbl(i).scheduled_date := p_x_req_material_tbl(i).scheduled_date;
          END IF;
          -- Request ID
          IF p_x_req_material_tbl(i).request_id = FND_API.G_MISS_NUM
          THEN
           l_Req_Material_Tbl(i).request_id := NULL;
          ELSE
           l_Req_Material_Tbl(i).request_id := p_x_req_material_tbl(i).request_id;
          END IF;
          --Scheduled quantity
          IF p_x_req_material_tbl(i).scheduled_quantity = FND_API.G_MISS_NUM
          THEN
           l_Req_Material_Tbl(i).scheduled_quantity := NULL;
          ELSE
           l_Req_Material_Tbl(i).scheduled_quantity := p_x_req_material_tbl(i).scheduled_quantity;
          END IF;
          -- Operation Sequence
          IF p_x_req_material_tbl(i).operation_sequence = FND_API.G_MISS_NUM
          THEN
           l_Req_Material_Tbl(i).operation_sequence := NULL;
          ELSE
           l_Req_Material_Tbl(i).operation_sequence := p_x_req_material_tbl(i).operation_sequence;
          END IF;
          -- UOM
          IF p_x_req_material_tbl(i).uom_code = FND_API.G_MISS_CHAR
          THEN
           l_Req_Material_Tbl(i).uom_code := NULL;
          ELSE
           l_Req_Material_Tbl(i).uom_code := p_x_req_material_tbl(i).uom_code;
          END IF;
          -- Status
          IF p_x_req_material_tbl(i).status = FND_API.G_MISS_CHAR
          THEN
           l_Req_Material_Tbl(i).status := NULL;
          ELSE
           l_Req_Material_Tbl(i).status := p_x_req_material_tbl(i).status;
          END IF;
          -- Operation code
          IF p_x_req_material_tbl(i).operation_code = FND_API.G_MISS_CHAR
          THEN
           l_Req_Material_Tbl(i).operation_code := NULL;
          ELSE
           l_Req_Material_Tbl(i).operation_code := p_x_req_material_tbl(i).operation_code;
          END IF;
          -- Transaction ID
          IF p_x_req_material_tbl(i).transaction_id = FND_API.G_MISS_NUM
          THEN
           l_Req_Material_Tbl(i).transaction_id := NULL;
          ELSE
           l_Req_Material_Tbl(i).transaction_id := p_x_req_material_tbl(i).transaction_id;
          END IF;
          -- Rt Oper Material ID
          IF p_x_req_material_tbl(i).rt_oper_material_id = FND_API.G_MISS_NUM
          THEN
           l_Req_Material_Tbl(i).rt_oper_material_id := NULL;
          ELSE
           l_Req_Material_Tbl(i).rt_oper_material_id := p_x_req_material_tbl(i).rt_oper_material_id;
          END IF;
          -- Program ID
          IF p_x_req_material_tbl(i).program_id = FND_API.G_MISS_NUM
          THEN
           l_Req_Material_Tbl(i).program_id := NULL;
          ELSE
           l_Req_Material_Tbl(i).program_id := p_x_req_material_tbl(i).program_id;
          END IF;
          -- Item group ID
          IF p_x_req_material_tbl(i).item_group_id = FND_API.G_MISS_NUM
          THEN
           l_Req_Material_Tbl(i).item_group_id := NULL;
          ELSE
           l_Req_Material_Tbl(i).item_group_id := p_x_req_material_tbl(i).item_group_id;
          END IF;
          -- Program Update Date
          IF p_x_req_material_tbl(i).program_update_date = FND_API.G_MISS_DATE
          THEN
           l_Req_Material_Tbl(i).program_update_date := NULL;
          ELSE
           l_Req_Material_Tbl(i).program_update_date := p_x_req_material_tbl(i).program_update_date;
          END IF;
          -- Last Updated Date
          IF p_x_req_material_tbl(i).last_updated_date = FND_API.G_MISS_DATE
          THEN
           l_Req_Material_Tbl(i).last_updated_date := NULL;
          ELSE
          l_Req_Material_Tbl(i).last_updated_date := p_x_req_material_tbl(i).last_updated_date;
          END IF;

          IF G_DEBUG='Y' THEN
                        AHL_DEBUG_PUB.debug('fetching dff_default_values');
          END IF;

          get_dff_default_values
          (
             p_req_material_rec      => p_x_req_material_tbl(i),
             flex_fields_defaults    =>  dff_default_values
          );
          IF G_DEBUG='Y' THEN
             AHL_DEBUG_PUB.debug('dff_default_values have been fetched');
          END IF;
          -- Attribte Category
          IF p_x_req_material_tbl(i).attribute_category = FND_API.G_MISS_CHAR
          THEN
           l_Req_Material_Tbl(i).attribute_category := NULL;
          ELSIF p_x_req_material_tbl(i).attribute_category IS NULL THEN
           l_Req_Material_Tbl(i).attribute_category := dff_default_values.attribute_category;
          ELSE
           l_Req_Material_Tbl(i).attribute_category := p_x_req_material_tbl(i).attribute_category;
          END IF;
          -- Attribte1
          IF p_x_req_material_tbl(i).attribute1 = FND_API.G_MISS_CHAR
          THEN
           l_Req_Material_Tbl(i).attribute1 := NULL;
          ELSIF p_x_req_material_tbl(i).attribute1 IS NULL THEN
           l_Req_Material_Tbl(i).attribute1 := dff_default_values.attribute1;
          ELSE
           l_Req_Material_Tbl(i).attribute1 := p_x_req_material_tbl(i).attribute1;
          END IF;
          -- Attribte2
          IF p_x_req_material_tbl(i).attribute2 = FND_API.G_MISS_CHAR
          THEN
           l_Req_Material_Tbl(i).attribute2 := NULL;
          ELSIF p_x_req_material_tbl(i).attribute2 IS NULL THEN
           l_Req_Material_Tbl(i).attribute2 := dff_default_values.attribute2;
          ELSE
           l_Req_Material_Tbl(i).attribute2 := p_x_req_material_tbl(i).attribute2;
          END IF;
          -- Attribte3
          IF p_x_req_material_tbl(i).attribute3 = FND_API.G_MISS_CHAR
          THEN
           l_Req_Material_Tbl(i).attribute3 := NULL;
          ELSIF p_x_req_material_tbl(i).attribute3 IS NULL THEN
           l_Req_Material_Tbl(i).attribute3 := dff_default_values.attribute3;
          ELSE
           l_Req_Material_Tbl(i).attribute3 := p_x_req_material_tbl(i).attribute3;
          END IF;
          -- Attribte4
          IF p_x_req_material_tbl(i).attribute4 = FND_API.G_MISS_CHAR
          THEN
           l_Req_Material_Tbl(i).attribute4 := NULL;
          ELSIF p_x_req_material_tbl(i).attribute4 IS NULL THEN
           l_Req_Material_Tbl(i).attribute4 := dff_default_values.attribute4;
          ELSE
           l_Req_Material_Tbl(i).attribute4 := p_x_req_material_tbl(i).attribute4;
          END IF;
          -- Attribte5
          IF p_x_req_material_tbl(i).attribute5 = FND_API.G_MISS_CHAR
          THEN
           l_Req_Material_Tbl(i).attribute5 := NULL;
          ELSIF p_x_req_material_tbl(i).attribute5 IS NULL THEN
           l_Req_Material_Tbl(i).attribute5 := dff_default_values.attribute5;
          ELSE
           l_Req_Material_Tbl(i).attribute5 := p_x_req_material_tbl(i).attribute5;
          END IF;
          -- Attribte6
          IF p_x_req_material_tbl(i).attribute6 = FND_API.G_MISS_CHAR
          THEN
           l_Req_Material_Tbl(i).attribute6 := NULL;
          ELSIF p_x_req_material_tbl(i).attribute6 IS NULL THEN
           l_Req_Material_Tbl(i).attribute6 := dff_default_values.attribute6;
          ELSE
           l_Req_Material_Tbl(i).attribute6 := p_x_req_material_tbl(i).attribute6;
          END IF;
          -- Attribte7
          IF p_x_req_material_tbl(i).attribute7 = FND_API.G_MISS_CHAR
          THEN
           l_Req_Material_Tbl(i).attribute7 := NULL;
          ELSIF p_x_req_material_tbl(i).attribute7 IS NULL THEN
           l_Req_Material_Tbl(i).attribute7 := dff_default_values.attribute7;
          ELSE
           l_Req_Material_Tbl(i).attribute7 := p_x_req_material_tbl(i).attribute7;
          END IF;
          -- Attribte8
          IF p_x_req_material_tbl(i).attribute8 = FND_API.G_MISS_CHAR
          THEN
           l_Req_Material_Tbl(i).attribute8 := NULL;
          ELSIF p_x_req_material_tbl(i).attribute8 IS NULL THEN
           l_Req_Material_Tbl(i).attribute8 := dff_default_values.attribute8;
          ELSE
           l_Req_Material_Tbl(i).attribute8 := p_x_req_material_tbl(i).attribute8;
          END IF;
          -- Attribte9
          IF p_x_req_material_tbl(i).attribute9 = FND_API.G_MISS_CHAR
          THEN
           l_Req_Material_Tbl(i).attribute9 := NULL;
          ELSIF p_x_req_material_tbl(i).attribute9 IS NULL THEN
           l_Req_Material_Tbl(i).attribute9 := dff_default_values.attribute9;
          ELSE
           l_Req_Material_Tbl(i).attribute9 := p_x_req_material_tbl(i).attribute9;
          END IF;
          -- Attribte10
          IF p_x_req_material_tbl(i).attribute10 = FND_API.G_MISS_CHAR
          THEN
           l_Req_Material_Tbl(i).attribute10 := NULL;
          ELSIF p_x_req_material_tbl(i).attribute10 IS NULL THEN
           l_Req_Material_Tbl(i).attribute10 := dff_default_values.attribute10;
          ELSE
           l_Req_Material_Tbl(i).attribute10 := p_x_req_material_tbl(i).attribute10;
          END IF;
          -- Attribte11
          IF p_x_req_material_tbl(i).attribute11 = FND_API.G_MISS_CHAR
          THEN
           l_Req_Material_Tbl(i).attribute11 := NULL;
          ELSIF p_x_req_material_tbl(i).attribute11 IS NULL THEN
           l_Req_Material_Tbl(i).attribute11 := dff_default_values.attribute11;
          ELSE
           l_Req_Material_Tbl(i).attribute11 := p_x_req_material_tbl(i).attribute11;
          END IF;
          -- Attribte12
          IF p_x_req_material_tbl(i).attribute12 = FND_API.G_MISS_CHAR
          THEN
           l_Req_Material_Tbl(i).attribute12 := NULL;
          ELSIF p_x_req_material_tbl(i).attribute12 IS NULL THEN
           l_Req_Material_Tbl(i).attribute12 := dff_default_values.attribute12;
          ELSE
           l_Req_Material_Tbl(i).attribute12 := p_x_req_material_tbl(i).attribute12;
          END IF;
          -- Attribte13
          IF p_x_req_material_tbl(i).attribute13 = FND_API.G_MISS_CHAR
          THEN
           l_Req_Material_Tbl(i).attribute13 := NULL;
          ELSIF p_x_req_material_tbl(i).attribute13 IS NULL THEN
           l_Req_Material_Tbl(i).attribute13 := dff_default_values.attribute13;
          ELSE
           l_Req_Material_Tbl(i).attribute13 := p_x_req_material_tbl(i).attribute13;
          END IF;
          -- Attribte14
          IF p_x_req_material_tbl(i).attribute14 = FND_API.G_MISS_CHAR
          THEN
           l_Req_Material_Tbl(i).attribute14 := NULL;
          ELSIF p_x_req_material_tbl(i).attribute14 IS NULL THEN
           l_Req_Material_Tbl(i).attribute14 := dff_default_values.attribute14;
          ELSE
           l_Req_Material_Tbl(i).attribute14 := p_x_req_material_tbl(i).attribute14;
          END IF;
          -- Attribte15
          IF p_x_req_material_tbl(i).attribute15 = FND_API.G_MISS_CHAR
          THEN
           l_Req_Material_Tbl(i).attribute15 := NULL;
          ELSIF p_x_req_material_tbl(i).attribute15 IS NULL THEN
           l_Req_Material_Tbl(i).attribute15 := dff_default_values.attribute15;
          ELSE
           l_Req_Material_Tbl(i).attribute15 := p_x_req_material_tbl(i).attribute15;
          END IF;
          --
        -- Get Sequence Number for schedule material ID
        SELECT ahl_schedule_materials_s.NEXTVAL
                  INTO l_schedule_material_id FROM DUAL;
        --
        --
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'before interface flag:'||p_x_req_material_tbl(i).rt_oper_material_id);
   AHL_DEBUG_PUB.debug( 'before interface flag:'||p_interface_flag);

   END IF;
        --Check for materials added from route.Already in scheudle material entity
        -- were schedule during LTP process
  IF (p_interface_flag = 'N' or  p_interface_flag = 'n') THEN
   --
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'FLAG=N RTID:'||p_x_req_material_tbl(i).rt_oper_material_id);
   AHL_DEBUG_PUB.debug( 'FLAG=N VTID:'||p_x_req_material_tbl(i).visit_task_id);
   AHL_DEBUG_PUB.debug( 'FLAG=N ITID:'||p_x_req_material_tbl(i).inventory_item_id);
   END IF;
         IF (p_x_req_material_tbl(i).rt_oper_material_id IS NOT NULL AND
             p_x_req_material_tbl(i).rt_oper_material_id <> FND_API.G_MISS_NUM)
             THEN
             --
             OPEN Get_rt_mat_cur (p_x_req_material_tbl(i).visit_task_id,
                                  p_x_req_material_tbl(i).rt_oper_material_id);
             FETCH Get_rt_mat_cur INTO l_material_rec;
             CLOSE Get_rt_mat_cur;
             --
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'Inside MATID:'||l_material_rec.scheduled_material_id);
   AHL_DEBUG_PUB.debug( 'inside VTID:'||l_material_rec.visit_task_id);
   AHL_DEBUG_PUB.debug( 'inside ITID:'||l_material_rec.inventory_item_id);
   AHL_DEBUG_PUB.debug( 'inside DES:'||l_schedule_designator);
   END IF;
       --
       IF ( l_material_rec.scheduled_material_id IS NOT NULL
            --Adithya added for FP Bug# 6366740
            AND p_x_req_material_tbl(i).workorder_operation_id = l_material_rec.workorder_operation_id )
       THEN
          -- UPDATE ahl schedule materials table with operation id, operation sequence
              UPDATE ahl_schedule_materials
                SET workorder_operation_id = p_x_req_material_tbl(i).workorder_operation_id,
                    operation_code     = p_x_req_material_tbl(i).operation_code,
                    operation_sequence = p_x_req_material_tbl(i).operation_sequence,
                    object_version_number =l_material_rec.object_version_number +1
                WHERE scheduled_material_id = l_material_rec.scheduled_material_id;
              --Assign out parameter
    p_x_req_material_tbl(i).schedule_material_id := l_material_rec.scheduled_material_id;
    p_x_req_material_tbl(i).requested_quantity   := l_material_rec.requested_quantity;
    p_x_req_material_tbl(i).requested_date       := l_material_rec.requested_date;
    p_x_req_material_tbl(i).uom_code             := l_material_rec.uom;
    -- fix for bug# 5549135.
    --p_x_req_material_tbl(i).mrp_net_flag         := 1;
    p_x_req_material_tbl(i).mrp_net_flag         := 2;

   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'p_x_req_material_tbl(i).mrp_net_flag:'||p_x_req_material_tbl(i).mrp_net_flag);
   END IF;

  ELSE
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'else flag Mat id:'||l_schedule_material_id);
   END IF;
          -- Create Record in schedule materials
             Insert_Row (
                   X_SCHEDULED_MATERIAL_ID => l_schedule_material_id,
                   X_OBJECT_VERSION_NUMBER => 1,
                   X_INVENTORY_ITEM_ID     => p_x_req_material_tbl(i).inventory_item_id,
                   X_SCHEDULE_DESIGNATOR   => l_schedule_designator,
                   X_VISIT_ID              => l_visit_id,
                   X_VISIT_START_DATE      => l_Req_Material_Tbl(i).visit_start_date,
                   X_VISIT_TASK_ID         => p_x_req_material_tbl(i).visit_task_id,
                   X_ORGANIZATION_ID       => p_x_req_material_tbl(i).organization_id,
                   X_SCHEDULED_DATE        => l_Req_Material_Tbl(i).scheduled_date,
                   X_REQUEST_ID            => l_Req_Material_Tbl(i).request_id,
                   X_REQUESTED_DATE        => p_x_req_material_tbl(i).requested_date,
                   X_SCHEDULED_QUANTITY    => l_Req_Material_Tbl(i).scheduled_quantity,
                   X_PROCESS_STATUS        => null,
                   X_ERROR_MESSAGE         => null,
                   X_TRANSACTION_ID        => l_Req_Material_Tbl(i).transaction_id,
                   X_UOM                   => l_Req_Material_Tbl(i).uom_code,
                   X_RT_OPER_MATERIAL_ID   => l_Req_Material_Tbl(i).rt_oper_material_id,
                   X_OPERATION_CODE        => l_Req_Material_Tbl(i).operation_code,
                   X_OPERATION_SEQUENCE    => l_Req_Material_Tbl(i).operation_sequence,
                   X_ITEM_GROUP_ID         => l_Req_Material_Tbl(i).item_group_id,
                   X_REQUESTED_QUANTITY    => p_x_req_material_tbl(i).requested_quantity,
                   X_PROGRAM_ID            => l_Req_Material_Tbl(i).program_id,
                   X_PROGRAM_UPDATE_DATE   => l_Req_Material_Tbl(i).program_update_date,
                   X_LAST_UPDATED_DATE     => l_Req_Material_Tbl(i).last_updated_date,
                   X_WORKORDER_OPERATION_ID => p_x_req_material_tbl(i).workorder_operation_id,
                   X_MATERIAL_REQUEST_TYPE  => 'UNPLANNED',
                 X_STATUS                 => nvl(l_Req_Material_Tbl(i).status, 'ACTIVE'),
                  X_ATTRIBUTE_CATEGORY    => l_Req_Material_Tbl(i).attribute_category,
                   X_ATTRIBUTE1            => l_Req_Material_Tbl(i).attribute1,
                   X_ATTRIBUTE2            => l_Req_Material_Tbl(i).attribute2,
                   X_ATTRIBUTE3            => l_Req_Material_Tbl(i).attribute3,
                   X_ATTRIBUTE4            => l_Req_Material_Tbl(i).attribute4,
                   X_ATTRIBUTE5            => l_Req_Material_Tbl(i).attribute5,
                   X_ATTRIBUTE6            => l_Req_Material_Tbl(i).attribute6,
                   X_ATTRIBUTE7            => l_Req_Material_Tbl(i).attribute7,
                   X_ATTRIBUTE8            => l_Req_Material_Tbl(i).attribute8,
                   X_ATTRIBUTE9            => l_Req_Material_Tbl(i).attribute9,
                   X_ATTRIBUTE10           => l_Req_Material_Tbl(i).attribute10,
                   X_ATTRIBUTE11           => l_Req_Material_Tbl(i).attribute11,
                   X_ATTRIBUTE12           => l_Req_Material_Tbl(i).attribute12,
                   X_ATTRIBUTE13           => l_Req_Material_Tbl(i).attribute13,
                   X_ATTRIBUTE14           => l_Req_Material_Tbl(i).attribute14,
                   X_ATTRIBUTE15           => l_Req_Material_Tbl(i).attribute15,
                   X_CREATION_DATE         => SYSDATE,
                   X_CREATED_BY            => fnd_global.user_id,
                   X_LAST_UPDATE_DATE      => SYSDATE,
                   X_LAST_UPDATED_BY       => fnd_global.user_id,
                   X_LAST_UPDATE_LOGIN     => fnd_global.login_id
                  );

   --Assign out parameter
   p_x_req_material_tbl(i).schedule_material_id := l_schedule_material_id;
   -- fix for bug# 5549135.
   --p_x_req_material_tbl(i).mrp_net_flag := 1;
   p_x_req_material_tbl(i).mrp_net_flag := 2;
   --
   END IF; --Get_rt_mat_cur

   -- Get Project and Task id
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'schedule material id 5:'||l_schedule_material_id);
   END IF;
 ELSE
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'schedule material id 6:'||l_schedule_material_id);
   END IF;

          -- Create Record in schedule materials
             Insert_Row (
                   X_SCHEDULED_MATERIAL_ID => l_schedule_material_id,
                   X_OBJECT_VERSION_NUMBER => 1,
                   X_INVENTORY_ITEM_ID     => p_x_req_material_tbl(i).inventory_item_id,
                   X_SCHEDULE_DESIGNATOR   => l_schedule_designator,
                   X_VISIT_ID              => l_visit_id,
                   X_VISIT_START_DATE      => l_Req_Material_Tbl(i).visit_start_date,
                   X_VISIT_TASK_ID         => p_x_req_material_tbl(i).visit_task_id,
                   X_ORGANIZATION_ID       => p_x_req_material_tbl(i).organization_id,
                   X_SCHEDULED_DATE        => l_Req_Material_Tbl(i).scheduled_date,
                   X_REQUEST_ID            => l_Req_Material_Tbl(i).request_id,
                   X_REQUESTED_DATE        => p_x_req_material_tbl(i).requested_date,
                   X_SCHEDULED_QUANTITY    => l_Req_Material_Tbl(i).scheduled_quantity,
                   X_PROCESS_STATUS        => null,
                   X_ERROR_MESSAGE         => null,
                   X_TRANSACTION_ID        => l_Req_Material_Tbl(i).transaction_id,
                   X_UOM                   => l_Req_Material_Tbl(i).uom_code,
                   X_RT_OPER_MATERIAL_ID   => l_Req_Material_Tbl(i).rt_oper_material_id,
                   X_OPERATION_CODE        => l_Req_Material_Tbl(i).operation_code,
                   X_OPERATION_SEQUENCE    => l_Req_Material_Tbl(i).operation_sequence,
                   X_ITEM_GROUP_ID         => l_Req_Material_Tbl(i).item_group_id,
                   X_REQUESTED_QUANTITY    => p_x_req_material_tbl(i).requested_quantity,
                   X_PROGRAM_ID            => l_Req_Material_Tbl(i).program_id,
                   X_PROGRAM_UPDATE_DATE   => l_Req_Material_Tbl(i).program_update_date,
                   X_LAST_UPDATED_DATE     => l_Req_Material_Tbl(i).last_updated_date,
                   X_WORKORDER_OPERATION_ID => p_x_req_material_tbl(i).workorder_operation_id,
                   X_MATERIAL_REQUEST_TYPE  => 'UNPLANNED',
                   X_STATUS                 => 'ACTIVE',
                   X_ATTRIBUTE_CATEGORY    => l_Req_Material_Tbl(i).attribute_category,
                   X_ATTRIBUTE1            => l_Req_Material_Tbl(i).attribute1,
                   X_ATTRIBUTE2            => l_Req_Material_Tbl(i).attribute2,
                   X_ATTRIBUTE3            => l_Req_Material_Tbl(i).attribute3,
                   X_ATTRIBUTE4            => l_Req_Material_Tbl(i).attribute4,
                   X_ATTRIBUTE5            => l_Req_Material_Tbl(i).attribute5,
                   X_ATTRIBUTE6            => l_Req_Material_Tbl(i).attribute6,
                   X_ATTRIBUTE7            => l_Req_Material_Tbl(i).attribute7,
                   X_ATTRIBUTE8            => l_Req_Material_Tbl(i).attribute8,
                   X_ATTRIBUTE9            => l_Req_Material_Tbl(i).attribute9,
                   X_ATTRIBUTE10           => l_Req_Material_Tbl(i).attribute10,
                   X_ATTRIBUTE11           => l_Req_Material_Tbl(i).attribute11,
                   X_ATTRIBUTE12           => l_Req_Material_Tbl(i).attribute12,
                   X_ATTRIBUTE13           => l_Req_Material_Tbl(i).attribute13,
                   X_ATTRIBUTE14           => l_Req_Material_Tbl(i).attribute14,
                   X_ATTRIBUTE15           => l_Req_Material_Tbl(i).attribute15,
                   X_CREATION_DATE         => SYSDATE,
                   X_CREATED_BY            => fnd_global.user_id,
                   X_LAST_UPDATE_DATE      => SYSDATE,
                   X_LAST_UPDATED_BY       => fnd_global.user_id,
                   X_LAST_UPDATE_LOGIN     => fnd_global.login_id
                  );

   --Assign out parameter
   --
   p_x_req_material_tbl(i).schedule_material_id := l_schedule_material_id;
   -- fix for bug# 5549135.
   --p_x_req_material_tbl(i).mrp_net_flag := 1;
   p_x_req_material_tbl(i).mrp_net_flag := 2;

   --
   END IF; -- --rt oper id not null
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'after rt oper material id:'||l_schedule_material_id);
   END IF;
   --
   END IF; -- --Interface flag
   --
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'schedule material id:'||l_schedule_material_id);
   END IF;
   --
 END IF; --Material id g_miss_num
   --
   SELECT AHL_WO_OPERATIONS_TXNS_S.NEXTVAL INTO l_wo_operation_txn_id
           FROM DUAL;
   --
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'before calling log record l_wo_operation_txn_id:'||l_wo_operation_txn_id);
   END IF;
      --Create Record in transactions table
       Log_Transaction_Record
           ( p_wo_operation_txn_id    => l_wo_operation_txn_id,
             p_object_version_number  => 1,
             p_last_update_date       => sysdate,
             p_last_updated_by        => fnd_global.user_id,
             p_creation_date          => sysdate,
             p_created_by             => fnd_global.user_id,
             p_last_update_login      => fnd_global.login_id,
             p_load_type_code         => 2,
             p_transaction_type_code  => 1,
             p_workorder_operation_id => p_x_req_material_tbl(i).workorder_operation_id,
             p_schedule_material_id   => p_x_req_material_tbl(i).schedule_material_id,
             p_inventory_item_id      => p_x_req_material_tbl(i).inventory_item_id,
             p_required_quantity      => p_x_req_material_tbl(i).requested_quantity,
             p_date_required          => p_x_req_material_tbl(i).requested_date
            );

   --Call MRP Process
   --
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'before calling MRP l_schedule_designator:'||l_schedule_designator);
   END IF;
 IF  (p_interface_flag IS NULL OR p_interface_flag = 'Y') THEN

          -- Create Record in schedule materials
             Insert_Row (
                   X_SCHEDULED_MATERIAL_ID => l_schedule_material_id,
                   X_OBJECT_VERSION_NUMBER => 1,
                   X_INVENTORY_ITEM_ID     => p_x_req_material_tbl(i).inventory_item_id,
                   X_SCHEDULE_DESIGNATOR   => l_schedule_designator,
                   X_VISIT_ID              => l_visit_id,
                   X_VISIT_START_DATE      => l_Req_Material_Tbl(i).visit_start_date,
                   X_VISIT_TASK_ID         => p_x_req_material_tbl(i).visit_task_id,
                   X_ORGANIZATION_ID       => p_x_req_material_tbl(i).organization_id,
                   X_SCHEDULED_DATE        => l_Req_Material_Tbl(i).scheduled_date,
                   X_REQUEST_ID            => l_Req_Material_Tbl(i).request_id,
                   X_REQUESTED_DATE        => p_x_req_material_tbl(i).requested_date,
                   X_SCHEDULED_QUANTITY    => l_Req_Material_Tbl(i).scheduled_quantity,
                   X_PROCESS_STATUS        => null,
                   X_ERROR_MESSAGE         => null,
                   X_TRANSACTION_ID        => l_Req_Material_Tbl(i).transaction_id,
                   X_UOM                   => l_Req_Material_Tbl(i).uom_code,
                   X_RT_OPER_MATERIAL_ID   => l_Req_Material_Tbl(i).rt_oper_material_id,
                   X_OPERATION_CODE        => l_Req_Material_Tbl(i).operation_code,
                   X_OPERATION_SEQUENCE    => l_Req_Material_Tbl(i).operation_sequence,
                   X_ITEM_GROUP_ID         => l_Req_Material_Tbl(i).item_group_id,
                   X_REQUESTED_QUANTITY    => p_x_req_material_tbl(i).requested_quantity,
                   X_PROGRAM_ID            => l_Req_Material_Tbl(i).program_id,
                   X_PROGRAM_UPDATE_DATE   => l_Req_Material_Tbl(i).program_update_date,
                   X_LAST_UPDATED_DATE     => l_Req_Material_Tbl(i).last_updated_date,
                   X_WORKORDER_OPERATION_ID => p_x_req_material_tbl(i).workorder_operation_id,
                   X_MATERIAL_REQUEST_TYPE  => 'UNPLANNED',
                           X_STATUS                 => nvl(l_Req_Material_Tbl(i).status,'ACTIVE'),
                         X_ATTRIBUTE_CATEGORY    => l_Req_Material_Tbl(i).attribute_category,
                   X_ATTRIBUTE1            => l_Req_Material_Tbl(i).attribute1,
                   X_ATTRIBUTE2            => l_Req_Material_Tbl(i).attribute2,
                   X_ATTRIBUTE3            => l_Req_Material_Tbl(i).attribute3,
                   X_ATTRIBUTE4            => l_Req_Material_Tbl(i).attribute4,
                   X_ATTRIBUTE5            => l_Req_Material_Tbl(i).attribute5,
                   X_ATTRIBUTE6            => l_Req_Material_Tbl(i).attribute6,
                   X_ATTRIBUTE7            => l_Req_Material_Tbl(i).attribute7,
                   X_ATTRIBUTE8            => l_Req_Material_Tbl(i).attribute8,
                   X_ATTRIBUTE9            => l_Req_Material_Tbl(i).attribute9,
                   X_ATTRIBUTE10           => l_Req_Material_Tbl(i).attribute10,
                   X_ATTRIBUTE11           => l_Req_Material_Tbl(i).attribute11,
                   X_ATTRIBUTE12           => l_Req_Material_Tbl(i).attribute12,
                   X_ATTRIBUTE13           => l_Req_Material_Tbl(i).attribute13,
                   X_ATTRIBUTE14           => l_Req_Material_Tbl(i).attribute14,
                   X_ATTRIBUTE15           => l_Req_Material_Tbl(i).attribute15,
                   X_CREATION_DATE         => SYSDATE,
                   X_CREATED_BY            => fnd_global.user_id,
                   X_LAST_UPDATE_DATE      => SYSDATE,
                   X_LAST_UPDATED_BY       => fnd_global.user_id,
                   X_LAST_UPDATE_LOGIN     => fnd_global.login_id
                  );

   --Assign out parameter
   p_x_req_material_tbl(i).schedule_material_id := l_schedule_material_id;
   --
   END IF; -- Interface flag Is null condiiton
   --

   END LOOP;
 END IF; --Count
     --
     X_return_status     := 'S';
     x_job_return_status := 'S';
  ELSE
     x_job_return_status := 'E';
     X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     RAISE Fnd_Api.G_EXC_ERROR;
    END IF; --status condition
    --Call notification API
   --Send Material Notification
    IF X_return_status = 'S' THEN
     --Check for Profile Option value If 'Y' Call
     IF FND_PROFILE.value( 'AHL_MTL_REQ_NOTIFICATION_ENABLED') = 'Y' THEN
      --
    MATERIAL_NOTIFICATION
        (
         p_api_version    => p_api_version,
         p_init_msg_list  => p_init_msg_list,
         p_commit         => p_commit,
         p_validation_level       => p_validation_level,
         p_Req_Material_Tbl       => p_x_req_material_tbl,
         x_return_status          => l_return_status,
         x_msg_count              => l_msg_count,
         x_msg_data               => l_msg_data);
      END IF;
 END IF;
-- dbms_output.put_line( 'end of API:');

   ------------------------End of Body---------------------------------------
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
   Ahl_Debug_Pub.debug( 'End of public api Create Material Reqst','+PPMRP+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_material_reqst;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
      IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'ERROR' );
       AHL_DEBUG_PUB.debug( 'ahl_pp_materials_pvt. Create Material Reqst','+PPMRP+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
      END IF;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_material_reqst;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
      IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_pp_materials_pvt. Create Material Reqst','+PPMRP+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
      END IF;
WHEN OTHERS THEN
    ROLLBACK TO create_material_reqst;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_PP_MATERIALS_PVT',
                            p_procedure_name  =>  'CREATE_MATERIAL_REQST',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
     IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
              x_msg_count, x_msg_data, 'SQL ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_pp_materials_pvt. Create Material Reqst','+PPMRP+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
     END IF;
END Create_Material_Reqst;
--
-- Start of Comments --
--  Procedure name    : Update_Material_Reqst
--  Type              : Private
--  Function          : Updates schedule material table with requested fields, before
--                      it calls Eam Api
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
--  Update Material Request Parameters:
--       p_x_req_material_tbl     IN OUT NOCOPY AHL_PP_MATERIALS_PVT.Req_Material_Tbl_Type,
--         Contains material information to perform material reservation
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Update_Material_Reqst (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := NULL,
    p_x_req_material_tbl     IN OUT NOCOPY AHL_PP_MATERIALS_PVT.Req_Material_Tbl_Type,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2
   )
 IS
 --
 CURSOR Get_Req_Matrl_cur (c_schedule_material_id IN NUMBER)
  IS
   SELECT B.scheduled_material_id,
          B.inventory_item_id,
          B.object_version_number,
          B.requested_date,
          B.organization_id,
          B.visit_id,
          B.visit_task_id,
          B.requested_quantity,
          B.workorder_operation_id,
          B.operation_sequence,
          B.item_group_id,
          B.uom,
          B.rt_oper_material_id,
          -- modified for FP bug# 6802777
          --B.department_id,
          WO.department_id,
          B.workorder_name,
          B.wip_entity_id,
          A.attribute_category,
          A.attribute1,
          A.attribute2,
          A.attribute3,
          A.attribute4,
          A.attribute5,
          A.attribute6,
          A.attribute7,
          A.attribute8,
          A.attribute9,
          A.attribute10,
          A.attribute11,
          A.attribute12,
          A.attribute13,
          A.attribute14,
          A.attribute15,
          A.completed_quantity,
          A.requested_date old_requested_date  -- added to fix bug# 5182334.
FROM AHL_SCHEDULE_MATERIALS A,
     AHL_JOB_OPER_MATERIALS_V B, WIP_OPERATIONS WO
WHERE A.SCHEDULED_MATERIAL_ID = B.SCHEDULED_MATERIAL_ID
  AND B.WIP_ENTITY_ID = WO.WIP_ENTITY_ID
  AND B.OPERATION_SEQUENCE = WO.OPERATION_SEQ_NUM
  AND A.SCHEDULED_MATERIAL_ID = c_schedule_material_id
FOR UPDATE OF A.OBJECT_VERSION_NUMBER;

-- Get transaction log
CURSOR Get_trans_log_cur(c_wo_trans_id IN NUMBER)
  IS
    SELECT inventory_item_id,
             schedule_material_id,
           date_required,
               required_quantity
       FROM ahl_wo_operations_txns
     WHERE wo_operation_txn_id = c_wo_trans_id;
--
--Check for status Released or Unreleased
CURSOR Check_wo_status_cur(c_workorder_id IN NUMBER)
 IS
   SELECT 1
    FROM ahl_workorders
   WHERE workorder_id = c_workorder_id
    AND  (status_code = 3 or
          status_code = 1);
--Get wo transaction id
CURSOR Get_wo_transaction_id(c_sch_material_id IN NUMBER)
 IS
  SELECT max(wo_operation_txn_id)
    FROM ahl_wo_operations_txns
  WHERE schedule_material_id = c_sch_material_id;

            -- rroy
            -- ACL Changes

  -- Get job number details
  CURSOR Get_job_number(c_workorder_id IN NUMBER)
  IS
  SELECT workorder_name
       FROM ahl_workorders
  WHERE workorder_id = c_workorder_id;
            -- rroy
            -- ACL Changes

  -- R12: Serial Reservation changes.
  -- get count on existing reservations.
  CURSOR get_count_resrv_cur (c_item_id       IN NUMBER,
                              c_org_id        IN NUMBER,
                              c_wip_entity_id IN NUMBER,
                              c_oper_seq_num  IN NUMBER) IS
   SELECT nvl(SUM(mrv.primary_reservation_quantity), 0) reserved_quantity
   FROM mtl_reservations MRV
   WHERE MRV.INVENTORY_ITEM_ID = c_item_id
     AND MRV.EXTERNAL_SOURCE_CODE = 'AHL'
     AND MRV.DEMAND_SOURCE_HEADER_ID = c_wip_entity_id
     AND MRV.DEMAND_SOURCE_LINE_ID = c_oper_seq_num;

 --
 l_api_name        CONSTANT VARCHAR2(30) := 'UPDATE_MATERIAL_REQST';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 l_dummy                    NUMBER;
 l_scheduled                VARCHAR2(1);
 --
 l_get_trans_log_rec       get_trans_log_cur%ROWTYPE;
 --
 l_workorder_id              NUMBER;
 l_new_inventory_id          NUMBER;
 l_default                   VARCHAR2(30);
 --
 l_req_material_tbl          Req_Material_Tbl_Type;
 l_object_version_number  NUMBER;
 l_req_material_rec       Get_Req_Matrl_cur%ROWTYPE;
 --
 l_workorder_name     VARCHAR2(80);
 l_wo_organization_id  NUMBER;
 l_wo_transaction_id   NUMBER;
 l_reserved_quantity   NUMBER;

 --
 -- Variables required for wip jobs call
 l_wo_operation_txn_id   NUMBER;
 l_inventory_item_old    NUMBER;
 j  NUMBER;
 --
 BEGIN
   --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT update_material_reqst;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   -- Debug info.
   AHL_DEBUG_PUB.debug( 'enter ahl_pp_materias_pvt. update material  reqst','+PPMRP+');
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
   IF p_x_req_material_tbl.COUNT > 0 THEN
      FOR i IN p_x_req_material_tbl.FIRST..p_x_req_material_tbl.LAST
        LOOP
   IF p_module_type <> 'API' THEN
         -- Value to ID Conversion
    IF ( ( p_x_req_material_tbl(i).workorder_id IS NOT NULL AND
           p_x_req_material_tbl(i).workorder_id <> FND_API.G_MISS_NUM ) OR
        ( p_x_req_material_tbl(i).job_number IS NOT NULL AND
          p_x_req_material_tbl(i).job_number <> FND_API.G_MISS_CHAR ) )
     THEN
     --
     IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug( 'WOID :'||p_x_req_material_tbl(i).workorder_id);
     END IF;
     --
      Get_workorder_id
             (p_workorder_id      => p_x_req_material_tbl(i).workorder_id,
              p_job_number        => p_x_req_material_tbl(i).job_number,
              x_workorder_id      => l_workorder_id,
              x_return_status     => l_return_status,
              x_error_msg_code    => l_msg_data);

            IF NVL(l_return_status,'x') <> 'S'
            THEN
                Fnd_Message.SET_NAME('AHL','AHL_PP_WO_ORD_NOT_EXISTS');
                Fnd_Msg_Pub.ADD;
            END IF;
     --
     ELSE
           Fnd_Message.SET_NAME('AHL','AHL_PP_WO_ORD_REQUIRED');
           Fnd_Msg_Pub.ADD;
     END IF;
     --
     p_x_req_material_tbl(i).workorder_id  := l_workorder_id;

     -- rroy
     -- ACL Changes
     l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(
                             p_workorder_id => p_x_req_material_tbl(i).workorder_id,
                             p_ue_id        => NULL,
                             p_visit_id => NULL,
                             p_item_instance_id => NULL);
     IF l_return_status = FND_API.G_TRUE THEN
       OPEN get_job_number(p_x_req_material_tbl(i).workorder_id);
       FETCH get_job_number INTO l_workorder_name;
       CLOSE get_job_number;
       FND_MESSAGE.Set_Name('AHL', 'AHL_PP_UPD_MTL_UNTLCKD');
       FND_MESSAGE.Set_Token('WO_NAME', l_workorder_name);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     -- rroy
     -- ACL Changes

     --
     IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug( 'WOID 2:'||p_x_req_material_tbl(i).workorder_id);
     END IF;
   END IF; --Module type

   --Get Requirement operation details
      OPEN Get_Req_Matrl_cur(p_x_req_material_tbl(i).schedule_material_id);
      FETCH Get_Req_Matrl_cur INTO l_req_material_rec;
      CLOSE Get_Req_Matrl_cur;
          -- Assign workorder operation id if null
       p_x_req_material_tbl(i).workorder_operation_id := l_req_material_rec.workorder_operation_id;
       p_x_req_material_tbl(i).operation_sequence := l_req_material_rec.operation_sequence;
       p_x_req_material_tbl(i).job_number         := l_req_material_rec.workorder_name;
       p_x_req_material_tbl(i).wip_entity_id      := l_req_material_rec.wip_entity_id;
       p_x_req_material_tbl(i).organization_id    := l_req_material_rec.organization_id;
       p_x_req_material_tbl(i).department_id      := l_req_material_rec.department_id;
       p_x_req_material_tbl(i).inventory_item_id  := l_req_material_rec.inventory_item_id;
       p_x_req_material_tbl(i).visit_id           := l_req_material_rec.visit_id;
       p_x_req_material_tbl(i).visit_task_id      := l_req_material_rec.visit_task_id;

       --pdoki added for Bug 7712916
       p_x_req_material_tbl(i).rt_oper_material_id := l_req_material_rec.rt_oper_material_id;

      IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug( 'INVID :'||p_x_req_material_tbl(i).inventory_item_id);
      END IF;

      -- Validate for Requested Quantity
       IF (p_x_req_material_tbl(i).requested_quantity IS  NULL OR
            p_x_req_material_tbl(i).requested_quantity = FND_API.G_MISS_NUM) THEN
             Fnd_Message.SET_NAME('AHL','AHL_PP_REQ_QUANTITY_REQUIRED');
             Fnd_Msg_Pub.ADD;
        ELSIF (p_x_req_material_tbl(i).requested_quantity IS NOT NULL AND
            p_x_req_material_tbl(i).requested_quantity <> FND_API.G_MISS_NUM) THEN
           IF p_x_req_material_tbl(i).requested_quantity < 0 THEN
             Fnd_Message.SET_NAME('AHL','AHL_PP_REQ_QUANTITY_INVALID');
             Fnd_Msg_Pub.ADD;
           END IF;
           -- added in R12: Serial Reservation project.
           -- If requested quantity changed -
           IF (p_x_req_material_tbl(i).requested_quantity <>
               l_req_material_rec.requested_quantity)
           THEN
              -- check for reservations, if any.
              OPEN get_count_resrv_cur(l_req_material_rec.inventory_item_id,
                                       l_req_material_rec.organization_id,
                                       l_req_material_rec.wip_entity_id,
                                       l_req_material_rec.operation_sequence);
              FETCH get_count_resrv_cur INTO l_reserved_quantity;
              CLOSE get_count_resrv_cur;

              IF (p_x_req_material_tbl(i).requested_quantity < l_reserved_quantity)
              THEN
                Fnd_Message.SET_NAME('AHL','AHL_PP_REQ_RESRV_QTY');
                Fnd_Message.SET_TOKEN('REQ_QTY',p_x_req_material_tbl(i).requested_quantity);
                Fnd_Message.SET_TOKEN('RRV_QTY',l_reserved_quantity);
                Fnd_Msg_Pub.ADD;
              END IF;-- p_x_req_material_tbl(i).requested_quantity <
           END IF; --p_x_req_material_tbl(i).requested_quantity <>
        END IF;
        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'QTY :'||p_x_req_material_tbl(i).requested_quantity);
        END IF;
    IF p_module_type <> 'API' THEN
        -- Validate for Requested Date
       IF (p_x_req_material_tbl(i).requested_date IS  NULL OR
            p_x_req_material_tbl(i).requested_date = FND_API.G_MISS_DATE) THEN
             Fnd_Message.SET_NAME('AHL','AHL_PP_REQ_DATE_REQUIRED');
             Fnd_Msg_Pub.ADD;
       ELSIF (p_x_req_material_tbl(i).requested_date IS NOT NULL AND
            p_x_req_material_tbl(i).requested_date <> FND_API.G_MISS_DATE) THEN
          IF p_x_req_material_tbl(i).requested_date < trunc(SYSDATE) THEN
             Fnd_Message.SET_NAME('AHL','AHL_PP_REQ_DATE_GT_EQ_SYSD');
             Fnd_Msg_Pub.ADD;
           END IF;
       END IF;
       IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'DATE :'||p_x_req_material_tbl(i).requested_date);
       END IF;

       -- Validate for Schedule Material ID
       IF (p_x_req_material_tbl(i).schedule_material_id IS  NULL AND
            p_x_req_material_tbl(i).schedule_material_id = FND_API.G_MISS_NUM) THEN
             Fnd_Message.SET_NAME('AHL','AHL_PP_SCH_MATRL_REQUIRED');
             Fnd_Msg_Pub.ADD;
        END IF;
        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'SCHID :'||p_x_req_material_tbl(i).schedule_material_id);
           AHL_DEBUG_PUB.debug( 'OSID'||p_x_req_material_tbl(i).operation_sequence);
        END IF;
        --Check for workorder status
        OPEN Check_wo_status_cur(p_x_req_material_tbl(i).workorder_id);
        FETCH Check_wo_status_cur INTO l_dummy;
        IF Check_wo_status_cur%NOTFOUND THEN
        --
          Fnd_Message.SET_NAME('AHL','AHL_PP_WO_STATUS_INVALID');
          Fnd_Msg_Pub.ADD;
        END IF;
        --
        CLOSE Check_wo_status_cur;
       --
    ELSE
        p_x_req_material_tbl(i).requested_date := l_req_material_rec.requested_date;

    END IF; --Module type

     --Standard check to count messages
     l_msg_count := Fnd_Msg_Pub.count_msg;

     IF l_msg_count > 0 THEN
        X_msg_count := l_msg_count;
        X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
        RAISE Fnd_Api.G_EXC_ERROR;
     END IF;

   END LOOP; --for loop
  END IF;

  -- Calling Wip job api
  --
  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( 'End of validations');
    AHL_DEBUG_PUB.debug('Before processing updates');
  END IF;
   --

--IF p_module_type <> 'API' THEN

IF p_x_req_material_tbl.COUNT >0
      THEN
         j := 1;
        FOR i in p_x_req_material_tbl.FIRST..p_x_req_material_tbl.LAST
        LOOP
           --Get the latest record
           OPEN Get_wo_transaction_id(p_x_req_material_tbl(i).schedule_material_id);
           FETCH get_wo_transaction_id INTO l_wo_transaction_id;
           CLOSE get_wo_transaction_id;
           --Get the transaction log record from ahl_wo_operation_txns table
           OPEN Get_trans_log_cur(l_wo_transaction_id);
           FETCH Get_trans_log_cur INTO l_get_trans_log_rec;
           CLOSE Get_trans_log_cur;
           --
          OPEN Get_Req_Matrl_cur(p_x_req_material_tbl(i).schedule_material_id);
          FETCH Get_Req_Matrl_cur INTO l_req_material_rec;
          CLOSE Get_Req_Matrl_cur;
           --Check for item id
           IF l_get_trans_log_rec.inventory_item_id <> p_x_req_material_tbl(i).inventory_item_id
            THEN
              l_inventory_item_old := l_get_trans_log_rec.inventory_item_id;
            ELSE
               l_inventory_item_old := p_x_req_material_tbl(i).inventory_item_id;
           END IF;
               -- Assign workorder operation id if null
           p_x_req_material_tbl(i).workorder_operation_id := l_req_material_rec.workorder_operation_id;
           --
           --Call transaction log to create record ahl_wo_operations_txns
      SELECT AHL_WO_OPERATIONS_TXNS_S.NEXTVAL INTO l_wo_operation_txn_id
             FROM DUAL;
      --
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'before calling log record l_wo_operation_txn_id:'||l_wo_operation_txn_id);
   END IF;
             Log_Transaction_Record
               ( p_wo_operation_txn_id    => l_wo_operation_txn_id,
                 p_object_version_number  => 1,
                 p_last_update_date       => sysdate,
                 p_last_updated_by        => fnd_global.user_id,
                 p_creation_date          => sysdate,
                 p_created_by             => fnd_global.user_id,
                 p_last_update_login      => fnd_global.login_id,
                 p_load_type_code         => 2,
                 p_transaction_type_code  => 1,
                 p_workorder_operation_id => p_x_req_material_tbl(i).workorder_operation_id,
                 p_schedule_material_id   => p_x_req_material_tbl(i).schedule_material_id,
                 p_inventory_item_id      => p_x_req_material_tbl(i).inventory_item_id,
                 p_required_quantity      => p_x_req_material_tbl(i).requested_quantity,
                 p_date_required          => p_x_req_material_tbl(i).requested_date
               );
           --Assign to output
           l_req_material_tbl(j).JOB_NUMBER              := p_x_req_material_tbl(i).job_number;
           l_req_material_tbl(j).WIP_ENTITY_ID           := p_x_req_material_tbl(i).wip_entity_id;
           l_req_material_tbl(j).WORKORDER_ID            := p_x_req_material_tbl(i).workorder_id;
           l_req_material_tbl(j).OPERATION_SEQUENCE      := l_req_material_rec.operation_sequence;
           l_req_material_tbl(j).UOM_CODE                := l_req_material_rec.uom;
           l_req_material_tbl(j).INVENTORY_ITEM_ID       := p_x_req_material_tbl(i).inventory_item_id;
           l_req_material_tbl(j).ORGANIZATION_ID         := p_x_req_material_tbl(i).organization_id;
           l_req_material_tbl(j).DEPARTMENT_ID           := p_x_req_material_tbl(i).department_id;
           -- fix for bug# 5549135
           --l_req_material_tbl(j).MRP_NET_FLAG            := 1;
           l_req_material_tbl(j).MRP_NET_FLAG            := 2;
           l_req_material_tbl(j).QUANTITY_PER_ASSEMBLY   := p_x_req_material_tbl(i).requested_quantity;
           l_req_material_tbl(j).REQUESTED_QUANTITY      := p_x_req_material_tbl(i).requested_quantity;
           l_req_material_tbl(j).SUPPLY_TYPE             := NULL;
           l_req_material_tbl(j).LOCATION                := NULL;
           l_req_material_tbl(j).SUB_INVENTORY           := NULL;
           l_req_material_tbl(j).REQUESTED_DATE          := p_x_req_material_tbl(i).requested_date;
           l_req_material_tbl(j).OPERATION_FLAG          := 'U';

           j := j + 1;
              IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.debug('Request Date from DB for sch. Mat ID:1:' || l_req_material_rec.old_requested_date || ':' || p_x_req_material_tbl(i).schedule_material_id);
                  AHL_DEBUG_PUB.debug('Changed Request Date :' || p_x_req_material_tbl(i).requested_date );
              END IF;
          --
         END LOOP;
       END IF; --Material tbl

   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug('beforer wip job record assign');
   END IF;

  IF l_req_material_tbl.COUNT > 0 THEN
       --
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug('before Eam Workorder job call');
   AHL_DEBUG_PUB.debug('before Eam Api jobs call''count :'||l_req_material_tbl.count);

   END IF;
       -- Call wip job api
       --

 AHL_EAM_JOB_PVT.process_material_req
    (
     p_api_version        => l_api_version,
     p_init_msg_list      => p_init_msg_list,
     p_commit             => p_commit,
     p_validation_level   => p_validation_level,
     p_default            => l_default,
     p_module_type        => p_module_type,
     x_return_status      => l_return_status,
     x_msg_count          => l_msg_count,
     x_msg_data           => l_msg_data,
     p_material_req_tbl   => l_req_material_tbl
       );
     --
     END IF; --Eam table count > 0
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug('AHLVPPMB: after wip job call'||l_return_status);
   END IF;
--END IF; --Module type null

IF l_return_status ='S' THEN
   --
   IF p_x_req_material_tbl.COUNT > 0
   THEN
   FOR i IN p_x_req_material_tbl.FIRST..p_x_req_material_tbl.LAST
     LOOP
        OPEN Get_Req_Matrl_cur(p_x_req_material_tbl(i).schedule_material_id);
        FETCH Get_Req_Matrl_cur INTO l_req_material_rec;
        CLOSE Get_Req_Matrl_cur;

        IF p_x_req_material_tbl(i).schedule_material_id IS NOT NULL
          THEN
              --
              -- Added for R12 serial reservations enhancements - ER# 4295982.
              -- If requested date is changed, then call reservations api to change the
              -- requested date in WMS.
              IF G_DEBUG='Y' THEN
                 AHL_DEBUG_PUB.debug('Request Date from DB for sch. Mat ID:2:' || l_req_material_rec.old_requested_date
                                      || ':' || p_x_req_material_tbl(i).schedule_material_id);
                 AHL_DEBUG_PUB.debug('Changed Request Date :' || p_x_req_material_tbl(i).requested_date );
              END IF;

              IF (trunc(p_x_req_material_tbl(i).requested_date) <> trunc(l_req_material_rec.old_requested_date))
              THEN
                  IF G_DEBUG='Y' THEN
                     AHL_DEBUG_PUB.debug('Before Call to Upd RSV ') ;
                  END IF;

                  -- call update reservations api.
                  AHL_RSV_RESERVATIONS_PVT.Update_Reservation(
                           p_api_version      => 1.0,
                           p_init_msg_list    => FND_API.G_FALSE,
                           p_commit           => FND_API.G_FALSE,
                           p_module_type      => NULL,
                           x_return_status    => x_return_status,
                           x_msg_count        => x_msg_count,
                           x_msg_data         => x_msg_data,
                           p_scheduled_material_id => p_x_req_material_tbl(i).schedule_material_id,
                           p_requested_date        => p_x_req_material_tbl(i).requested_date);

                  IF G_DEBUG='Y' THEN
                     AHL_DEBUG_PUB.debug('After Call to Upd RSV- Return Status:' || x_return_status);
                  END IF;

                  -- Raise error if exceptions occur
                  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                     RAISE FND_API.G_EXC_ERROR;
                  END IF;

              END IF; -- p_x_req_material_tbl(i).requested_date <>
              --

              --
              -- The following conditions compare the new record value with old  record
              -- value, if its different then assign the new value else continue

              IF NVL(p_x_req_material_tbl(i).inventory_item_id, 0) <> FND_API.G_MISS_NUM
              THEN
                 l_req_material_rec.inventory_item_id := p_x_req_material_tbl(i).inventory_item_id;
              END IF;
              --
              IF NVL(p_x_req_material_tbl(i).requested_date,sysdate) <> FND_API.G_MISS_DATE
              THEN
                 l_req_material_rec.requested_date := p_x_req_material_tbl(i).requested_date;
              END IF;
              --
              IF NVL(p_x_req_material_tbl(i).requested_quantity, 0) <> FND_API.G_MISS_NUM
              THEN
                 l_req_material_rec.requested_quantity := p_x_req_material_tbl(i).requested_quantity;
              END IF;
              --
              IF NVL(p_x_req_material_tbl(i).organization_id, 0) <> FND_API.G_MISS_NUM
              THEN
                 l_req_material_rec.organization_id := p_x_req_material_tbl(i).organization_id;
              END IF;
              --
              IF NVL(p_x_req_material_tbl(i).visit_id, 0) <> FND_API.G_MISS_NUM
              THEN
                 l_req_material_rec.visit_id := p_x_req_material_tbl(i).visit_id;
              END IF;
              --
              IF NVL(p_x_req_material_tbl(i).visit_task_id, 0) <> FND_API.G_MISS_NUM
              THEN
                 l_req_material_rec.visit_task_id := p_x_req_material_tbl(i).visit_task_id;
              END IF;
              --
              IF NVL(p_x_req_material_tbl(i).item_group_id, 0) <> FND_API.G_MISS_NUM
              THEN
                 l_req_material_rec.item_group_id := p_x_req_material_tbl(i).item_group_id;
              END IF;
              --
              IF NVL(p_x_req_material_tbl(i).rt_oper_material_id, 0) <> FND_API.G_MISS_NUM
              THEN
                 l_req_material_rec.rt_oper_material_id := p_x_req_material_tbl(i).rt_oper_material_id;
              END IF;

              --
              IF p_x_req_material_tbl(i).attribute_category IS NOT NULL AND
                 p_x_req_material_tbl(i).attribute_category <> FND_API.G_MISS_CHAR
              THEN
                 l_req_material_rec.attribute_category := p_x_req_material_tbl(i).attribute_category;
              ELSIF p_x_req_material_tbl(i).attribute_category = FND_API.G_MISS_CHAR THEN
                 l_req_material_rec.attribute_category := NULL;
              END IF;
              --
              IF p_x_req_material_tbl(i).attribute1 IS NOT NULL AND
                 p_x_req_material_tbl(i).attribute1 <> FND_API.G_MISS_CHAR
              THEN
                 l_req_material_rec.attribute1 := p_x_req_material_tbl(i).attribute1;
              ELSIF p_x_req_material_tbl(i).attribute1 = FND_API.G_MISS_CHAR THEN
                 l_req_material_rec.attribute1 := NULL;
              END IF;

              --
              IF p_x_req_material_tbl(i).attribute2 IS NOT NULL AND
                 p_x_req_material_tbl(i).attribute2 <> FND_API.G_MISS_CHAR
              THEN
                 l_req_material_rec.attribute2 := p_x_req_material_tbl(i).attribute2;
              ELSIF p_x_req_material_tbl(i).attribute2 = FND_API.G_MISS_CHAR THEN
                 l_req_material_rec.attribute2 := NULL;
              END IF;
              --
              IF p_x_req_material_tbl(i).attribute3 IS NOT NULL AND
                 p_x_req_material_tbl(i).attribute3 <> FND_API.G_MISS_CHAR
              THEN
                 l_req_material_rec.attribute3 := p_x_req_material_tbl(i).attribute3;
              ELSIF p_x_req_material_tbl(i).attribute3 = FND_API.G_MISS_CHAR THEN
                 l_req_material_rec.attribute3 := NULL;
              END IF;

              --
              IF p_x_req_material_tbl(i).attribute4 IS NOT NULL AND
                 p_x_req_material_tbl(i).attribute4 <> FND_API.G_MISS_CHAR
              THEN
                 l_req_material_rec.attribute4 := p_x_req_material_tbl(i).attribute4;
              ELSIF p_x_req_material_tbl(i).attribute4 = FND_API.G_MISS_CHAR THEN
                 l_req_material_rec.attribute4 := NULL;
              END IF;

              --
              IF p_x_req_material_tbl(i).attribute5 IS NOT NULL AND
                 p_x_req_material_tbl(i).attribute5 <> FND_API.G_MISS_CHAR
              THEN
                 l_req_material_rec.attribute5 := p_x_req_material_tbl(i).attribute5;
              ELSIF p_x_req_material_tbl(i).attribute5 = FND_API.G_MISS_CHAR THEN
                 l_req_material_rec.attribute5 := NULL;
              END IF;

              --
              IF p_x_req_material_tbl(i).attribute6 IS NOT NULL AND
                 p_x_req_material_tbl(i).attribute6 <> FND_API.G_MISS_CHAR
              THEN
                 l_req_material_rec.attribute6 := p_x_req_material_tbl(i).attribute6;
              ELSIF p_x_req_material_tbl(i).attribute6 = FND_API.G_MISS_CHAR THEN
                 l_req_material_rec.attribute6 := NULL;
              END IF;

              --
              IF p_x_req_material_tbl(i).attribute7 IS NOT NULL AND
                 p_x_req_material_tbl(i).attribute7 <> FND_API.G_MISS_CHAR
              THEN
                 l_req_material_rec.attribute7 := p_x_req_material_tbl(i).attribute7;
              ELSIF p_x_req_material_tbl(i).attribute7 = FND_API.G_MISS_CHAR THEN
                 l_req_material_rec.attribute7 := NULL;
              END IF;

              --
              IF p_x_req_material_tbl(i).attribute8 IS NOT NULL AND
                 p_x_req_material_tbl(i).attribute8 <> FND_API.G_MISS_CHAR
              THEN
                 l_req_material_rec.attribute8 := p_x_req_material_tbl(i).attribute8;
              ELSIF p_x_req_material_tbl(i).attribute8 = FND_API.G_MISS_CHAR THEN
                 l_req_material_rec.attribute8 := NULL;
              END IF;

              --
              IF p_x_req_material_tbl(i).attribute9 IS NOT NULL AND
                 p_x_req_material_tbl(i).attribute9 <> FND_API.G_MISS_CHAR
              THEN
                 l_req_material_rec.attribute9 := p_x_req_material_tbl(i).attribute9;
              ELSIF p_x_req_material_tbl(i).attribute9 = FND_API.G_MISS_CHAR THEN
                 l_req_material_rec.attribute9 := NULL;
              END IF;

              --
              IF p_x_req_material_tbl(i).attribute10 IS NOT NULL AND
                 p_x_req_material_tbl(i).attribute10 <> FND_API.G_MISS_CHAR
              THEN
                 l_req_material_rec.attribute10 := p_x_req_material_tbl(i).attribute10;
              ELSIF p_x_req_material_tbl(i).attribute10 = FND_API.G_MISS_CHAR THEN
                 l_req_material_rec.attribute10 := NULL;
              END IF;

              --
              IF p_x_req_material_tbl(i).attribute11 IS NOT NULL AND
                 p_x_req_material_tbl(i).attribute11 <> FND_API.G_MISS_CHAR
              THEN
                 l_req_material_rec.attribute11 := p_x_req_material_tbl(i).attribute11;
              ELSIF p_x_req_material_tbl(i).attribute11 = FND_API.G_MISS_CHAR THEN
                 l_req_material_rec.attribute11 := NULL;
              END IF;

              --
              IF p_x_req_material_tbl(i).attribute12 IS NOT NULL AND
                 p_x_req_material_tbl(i).attribute12 <> FND_API.G_MISS_CHAR
              THEN
                 l_req_material_rec.attribute12 := p_x_req_material_tbl(i).attribute12;
              ELSIF p_x_req_material_tbl(i).attribute12 = FND_API.G_MISS_CHAR THEN
                 l_req_material_rec.attribute12 := NULL;
              END IF;

              --
              IF p_x_req_material_tbl(i).attribute13 IS NOT NULL AND
                 p_x_req_material_tbl(i).attribute13 <> FND_API.G_MISS_CHAR
              THEN
                 l_req_material_rec.attribute13 := p_x_req_material_tbl(i).attribute13;
              ELSIF p_x_req_material_tbl(i).attribute13 = FND_API.G_MISS_CHAR THEN
                 l_req_material_rec.attribute13 := NULL;
              END IF;

              --
              IF p_x_req_material_tbl(i).attribute14 IS NOT NULL AND
                 p_x_req_material_tbl(i).attribute14 <> FND_API.G_MISS_CHAR
              THEN
                 l_req_material_rec.attribute14 := p_x_req_material_tbl(i).attribute14;
              ELSIF p_x_req_material_tbl(i).attribute14 = FND_API.G_MISS_CHAR THEN
                 l_req_material_rec.attribute14 := NULL;
              END IF;

              --
              IF p_x_req_material_tbl(i).attribute15 IS NOT NULL AND
                 p_x_req_material_tbl(i).attribute15 <> FND_API.G_MISS_CHAR
              THEN
                 l_req_material_rec.attribute15 := p_x_req_material_tbl(i).attribute15;
              ELSIF p_x_req_material_tbl(i).attribute15 = FND_API.G_MISS_CHAR THEN
                 l_req_material_rec.attribute15 := NULL;
              END IF;
              --
               --Update schedule material table
                 UPDATE AHL_SCHEDULE_MATERIALS
                 SET inventory_item_id    = l_req_material_rec.inventory_item_id,
                  -- AnRaj: truncating Requested Date for Material Requirement based on discussions with PM
                  requested_date        = trunc(l_req_material_rec.requested_date),
                  requested_quantity   = l_req_material_rec.requested_quantity,
                  object_version_number = l_req_material_rec.object_version_number+1,
                  visit_id              = l_req_material_rec.visit_id,
                  visit_task_id         = l_req_material_rec.visit_task_id,
                  organization_id       = l_req_material_rec.organization_id,
                  item_group_id         = l_req_material_rec.item_group_id,
                  rt_oper_material_id    = l_req_material_rec.rt_oper_material_id,
                  workorder_operation_id = l_req_material_rec.workorder_operation_id,
                  attribute_category    = l_req_material_rec.attribute_category,
                  attribute1            = l_req_material_rec.attribute1,
                  attribute2            = l_req_material_rec.attribute2,
                  attribute3            = l_req_material_rec.attribute3,
                  attribute4            = l_req_material_rec.attribute4,
                  attribute5            = l_req_material_rec.attribute5,
                  attribute6            = l_req_material_rec.attribute6,
                  attribute7            = l_req_material_rec.attribute7,
                  attribute8            = l_req_material_rec.attribute8,
                  attribute9            = l_req_material_rec.attribute9,
                  attribute10           = l_req_material_rec.attribute10,
                  attribute11           = l_req_material_rec.attribute11,
                  attribute12           = l_req_material_rec.attribute12,
                  attribute13           = l_req_material_rec.attribute13,
                  attribute14           = l_req_material_rec.attribute14,
                  attribute15           = l_req_material_rec.attribute15,
                  last_update_date      = sysdate,
                  last_updated_by       = fnd_global.user_id,
                  last_update_login     = fnd_global.login_id
                 WHERE  scheduled_material_id  = p_x_req_material_tbl(i).schedule_material_id;
              --

        END IF; -- p_x_req_material_tbl(i).schedule_material_id
     END LOOP;
   END IF; -- p_x_req_material_tbl.COUNT
   --
ELSE
     X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     RAISE Fnd_Api.G_EXC_ERROR;
END IF;-- Return status

    IF X_return_status = 'S' THEN
     --Check for Profile Option value If 'Y' Call
     IF FND_PROFILE.value( 'AHL_MTL_REQ_NOTIFICATION_ENABLED') = 'Y' THEN

      --Send Materil Notification
      MATERIAL_NOTIFICATION
        (
         p_api_version            => p_api_version,
         p_init_msg_list          => p_init_msg_list,
         p_commit                 => p_commit,
         p_validation_level       => p_validation_level,
         p_Req_Material_Tbl       => p_x_req_material_tbl,
         x_return_status          => l_return_status,
         x_msg_count              => l_msg_count,
         x_msg_data               => l_msg_data);
      END IF;
   END IF;

   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'END OF UPDATE PROCESS');
   END IF;
  --
   ------------------------End of Body---------------------------------------
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   --Change made on Nov 17, 2005 by jeli due to bug 4742895.
   --Ignore messages in stack if return status is S after calls to EAM APIs.
   /*
   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;
   */

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of public api Update Material Reqst','+PPMRP+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_material_reqst;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
       IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'ERROR' );
       AHL_DEBUG_PUB.debug( 'ahl_pp_materials_pvt. Update Material Reqst','+PPMRP+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
       END IF;
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO update_material_reqst;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_pp_materials_pvt. Update Material Reqst','+PPMRP+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
        END IF;
WHEN OTHERS THEN
    ROLLBACK TO update_material_reqst;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_PP_MATERIALS_PVT',
                            p_procedure_name  =>  'UPDATE_MATERIAL_REQST',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
              x_msg_count, x_msg_data, 'SQL ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_pp_materials_pvt. Update Material Reqst','+PPMRP+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
        END IF;
END Update_Material_Reqst;
-- Start of Comments --
--  Procedure name    : Remove_Material_Reqst
--  Type              : Private
--  Function          : Updates schedule material table with request quantity to zero,
--                      Calls Eam APi to remove material request
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
--  Remove Material Request Parameters:
--       p_x_req_material_tbl     IN OUT NOCOPY AHL_PP_MATERIALS_PVT.Req_Material_Tbl_Type,
--         Contains material information to perform material reservation
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
PROCEDURE Remove_Material_Request (
   p_api_version             IN    NUMBER,
   p_init_msg_list           IN    VARCHAR2  := Fnd_Api.g_false,
   p_commit                  IN    VARCHAR2  := Fnd_Api.g_false,
   p_validation_level        IN    NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type             IN    VARCHAR2  := 'JSP',
   p_x_req_material_tbl      IN OUT NOCOPY AHL_PP_MATERIALS_PVT.Req_Material_Tbl_Type,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)
IS
--Get job number
 CURSOR Get_job_details(c_workorder_id IN NUMBER)
    IS
    SELECT workorder_name
      FROM ahl_workorders
    WHERE workorder_id = c_workorder_id;
 -- Bug # 6680137 - begin.
 CURSOR c_get_wo_status(c_workorder_id IN NUMBER)
 IS
 SELECT
      AWO.status_code
 FROM
      AHL_WORKORDERS AWO
 WHERE
      workorder_id = c_workorder_id;
 -- Bug # 6680137 - end
 -- Get schedule material details
  CURSOR Get_Req_Matrl_cur (c_schedule_material_id IN NUMBER)
  IS
  /*
   SELECT B.scheduled_material_id,
          B.inventory_item_id,
          B.object_version_number,
          B.requested_date,
          B.organization_id,
          B.visit_id,
          B.visit_task_id,
          B.requested_quantity,
          B.workorder_operation_id,
          B.operation_sequence,
          B.item_group_id,
              B.uom,
          B.rt_oper_material_id,
              B.department_id,
              B.workorder_name,
              B.wip_entity_id
FROM AHL_SCHEDULE_MATERIALS A,
     AHL_JOB_OPER_MATERIALS_V B
WHERE A.SCHEDULED_MATERIAL_ID = B.SCHEDULED_MATERIAL_ID
  AND A.SCHEDULED_MATERIAL_ID = c_schedule_material_id;
*/
 /*
  * R12 Perf Tuning
  * Balaji modified the query to use only base tables
  * instead of AHL_JOB_OPER_MATERIALS_V. Bug # 4919273
  */
SELECT
  ASML.scheduled_material_id,
  ASML.inventory_item_id,
  ASML.object_version_number,
  wipr.date_required requested_date,
  AVST.organization_id,
  AVST.visit_id,
  ASML.visit_task_id,
  wipr.REQUIRED_QUANTITY requested_quantity,
  ASML.workorder_operation_id,
  wipr.operation_seq_num operation_sequence,
  ASML.item_group_id,
  MSIV.PRIMARY_UNIT_OF_MEASURE uom,
  ASML.rt_oper_material_id,
  AVST.department_id,
  AWOS.workorder_name,
  AWOS.wip_entity_id
FROM
  AHL_WORKORDERS AWOS,
  AHL_SCHEDULE_MATERIALS ASML,
  wip_requirement_operations wipr,
  MTL_SYSTEM_ITEMS_VL MSIV,
  AHL_VISITS_VL AVST,
  AHL_WORKORDER_OPERATIONS AWOP,
  -- added for FP bug# 6802777
  WIP_OPERATIONS WOP
WHERE
  AWOP.WORKORDER_OPERATION_ID = ASML.WORKORDER_OPERATION_ID AND
  AWOS.VISIT_TASK_ID = ASML.VISIT_TASK_ID AND
  ASML.VISIT_ID = AVST.VISIT_ID AND
  awos.wip_entity_id = wipr.wip_entity_id AND
  asml.operation_sequence = wipr.operation_seq_num AND
  asml.inventory_item_id = wipr.inventory_item_id AND
  asml.organization_id = wipr.organization_id AND
  asml.INVENTORY_ITEM_ID = MSIV.INVENTORY_ITEM_ID AND
  ASML.ORGANIZATION_ID = MSIV.ORGANIZATION_ID AND
  wop.wip_entity_id = wipr.wip_entity_id AND
  wop.operation_seq_num = wipr.operation_seq_num AND
  asml.status IN ('ACTIVE', 'IN-SERVICE') AND
  ASML.SCHEDULED_MATERIAL_ID = c_schedule_material_id;

  -- R12: Serial Reservation changes.
  -- get count on existing reservations.
  CURSOR get_count_resrv_cur (c_item_id       IN NUMBER,
                              c_org_id        IN NUMBER,
                              c_wip_entity_id IN NUMBER,
                              c_oper_seq_num  IN NUMBER) IS
   SELECT nvl(SUM(mrv.primary_reservation_quantity), 0) reserved_quantity
   FROM mtl_reservations MRV
   WHERE MRV.INVENTORY_ITEM_ID = c_item_id
     AND MRV.EXTERNAL_SOURCE_CODE = 'AHL'
     AND MRV.DEMAND_SOURCE_HEADER_ID = c_wip_entity_id
     AND MRV.DEMAND_SOURCE_LINE_ID = c_oper_seq_num;

 -- Standard local variable
 l_api_name        CONSTANT VARCHAR2(30) := 'REMOVE_MATERIAL_REQUEST';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(200);
 l_msg_count                NUMBER;
      l_workorder_name           VARCHAR2(80);
 --
 l_object_version_number   NUMBER;
 --
 l_req_material_rec       Req_Material_Rec_Type;
 l_req_material_tbl       Req_Material_Tbl_Type;
 l_material_rec           Get_Req_Matrl_cur%ROWTYPE;
  -- Variables required for wip jobs call
 l_ahl_wip_work_rec      AHL_WIP_JOB_PVT.ahl_wo_rec_type;
 l_ahl_wip_oper_tbl      AHL_WIP_JOB_PVT.ahl_wo_op_tbl_type ;
 l_ahl_wip_rsrc_tbl      AHL_WIP_JOB_PVT.ahl_wo_res_tbl_type;
 l_ahl_wip_mtrl_tbl      AHL_WIP_JOB_PVT.ahl_wo_mtl_tbl_type;
 l_default               VARCHAR2(30);
 j  NUMBER;

 l_reserved_quantity     NUMBER;

 -- Bug # 6680137 - begin
 l_wo_status             VARCHAR2(30);
 -- Bug # 6680137 - end
 BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT remove_material_request;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.enable_debug;
   -- Debug info.
   Ahl_Debug_Pub.debug( 'enter ahl_pp_materials_pvt Remove Material Request ','+MAATP+');
   --
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
   IF p_x_req_material_tbl.COUNT > 0 THEN
      FOR i IN p_x_req_material_tbl.FIRST..p_x_req_material_tbl.LAST
        LOOP
         -- Value to ID Conversion
         --Get visit task id
         IF (p_x_req_material_tbl(i).workorder_id IS NOT NULL AND
             p_x_req_material_tbl(i).workorder_id <> Fnd_Api.G_MISS_NUM )
          THEN
             --
             -- Bug # 6680137 - start
             OPEN Get_job_details(p_x_req_material_tbl(i).workorder_id);
             FETCH Get_job_details INTO l_workorder_name;
             IF Get_job_details%NOTFOUND THEN
                Fnd_Message.SET_NAME('AHL','AHL_PP_WO_ORD_NOT_EXISTS');
                Fnd_Msg_Pub.ADD;
                CLOSE Get_job_details;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
             CLOSE Get_job_details;
             -- Bug # 6680137 - end
             -- Balaji added this validation for Bug # 6680137 - begin.
             -- When work order is in status cancelled, complete no-charge or closed
             -- material deletion should be disallowed.
             OPEN c_get_wo_status(p_x_req_material_tbl(i).workorder_id);
             FETCH c_get_wo_status INTO l_wo_status;
             CLOSE c_get_wo_status;

             IF l_wo_status IN ('7', '5', '12')
             THEN
                  Fnd_Message.SET_NAME('AHL','AHL_PP_WO_STATUS_INVALID');
                  Fnd_Msg_Pub.ADD;
                  RAISE FND_API.G_EXC_ERROR;
             END IF;
             -- Bug # 6680137 - end
         END IF;

         -- rroy
         -- ACL Changes
         l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked
                            (
                              p_workorder_id => p_x_req_material_tbl(i).workorder_id,
                              p_ue_id => NULL,
                              p_visit_id => NULL,
                              p_item_instance_id => NULL);
         IF l_return_status = FND_API.G_TRUE THEN
            FND_MESSAGE.Set_Name('AHL', 'AHL_PP_DEL_MTL_UNTLCKD');
            FND_MESSAGE.Set_Token('WO_NAME', l_workorder_name);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         -- rroy
         -- ACL Changes

         -- Check for Schedule Material ID
         IF (p_x_req_material_tbl(i).schedule_material_id IS  NULL OR
             p_x_req_material_tbl(i).schedule_material_id = FND_API.G_MISS_NUM) THEN
             Fnd_Message.SET_NAME('AHL','AHL_PP_SCH_MATRL_REQUIRED');
             Fnd_Msg_Pub.ADD;
         END IF;
         --
         IF G_DEBUG='Y' THEN
            Ahl_Debug_Pub.debug( 'Obj Number:'||p_x_req_material_tbl(i).object_version_number);
            Ahl_Debug_Pub.debug( 'Sch mat Id:'||p_x_req_material_tbl(i).schedule_material_id);
         END IF;
         -- Check for object version number
         IF (p_x_req_material_tbl(i).object_version_number IS  NOT NULL AND
             p_x_req_material_tbl(i).object_version_number <> FND_API.G_MISS_NUM) THEN
             --
               SELECT object_version_number,requested_quantity INTO l_object_version_number,
                      p_x_req_material_tbl(i).requested_quantity
                     FROM ahl_schedule_materials
                  WHERE scheduled_material_id = p_x_req_material_tbl(i).schedule_material_id
                  FOR UPDATE OF STATUS NOWAIT;
            --
            IF  p_x_req_material_tbl(i).object_version_number <> l_object_version_number  THEN
              Fnd_Message.SET_NAME('AHL','AHL_PP_RECORD_CHANGED');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
            --
         END IF;

         --Standard check to count messages
         l_msg_count := Fnd_Msg_Pub.count_msg;

         IF l_msg_count > 0 THEN
            X_msg_count := l_msg_count;
            X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;

      END LOOP;
   END IF;
   --
   IF G_DEBUG='Y' THEN
    Ahl_Debug_Pub.debug( 'before wip jobs call:');
   END IF;
   --
  IF p_x_req_material_tbl.COUNT >0    THEN
    j := 1;
   FOR i in p_x_req_material_tbl.FIRST..p_x_req_material_tbl.LAST
   LOOP
      --
      OPEN Get_Req_Matrl_cur(p_x_req_material_tbl(i).schedule_material_id);
      FETCH Get_Req_Matrl_cur INTO l_material_rec;
      CLOSE Get_Req_matrl_cur;
      --
      --Assign to output
      l_req_material_tbl(j).JOB_NUMBER              := l_material_rec.workorder_name;
      l_req_material_tbl(j).WIP_ENTITY_ID           := l_material_rec.wip_entity_id;
      l_req_material_tbl(j).WORKORDER_ID            := p_x_req_material_tbl(i).workorder_id;
      l_req_material_tbl(j).OPERATION_SEQUENCE      := l_material_rec.operation_sequence;
      l_req_material_tbl(j).INVENTORY_ITEM_ID       := l_material_rec.inventory_item_id;
      l_req_material_tbl(j).ORGANIZATION_ID         := l_material_rec.organization_id;
      l_req_material_tbl(j).DEPARTMENT_ID           := l_material_rec.department_id;
      -- fix for bug# 5549135
      --l_req_material_tbl(j).MRP_NET_FLAG            := 1;
      l_req_material_tbl(j).MRP_NET_FLAG            := 2;
      l_req_material_tbl(j).QUANTITY_PER_ASSEMBLY   := l_material_rec.requested_quantity;
      l_req_material_tbl(j).REQUESTED_QUANTITY      := l_material_rec.requested_quantity;
      l_req_material_tbl(j).SUPPLY_TYPE             := NULL;
      l_req_material_tbl(j).LOCATION                := NULL;
      l_req_material_tbl(j).SUB_INVENTORY           := NULL;
      l_req_material_tbl(j).REQUESTED_DATE          := l_material_rec.requested_date;
      l_req_material_tbl(j).OPERATION_FLAG          := 'D';
      --
     j := j+1;

         -- Added for R12: Serial Reservation.
         -- check for reservations, if any.
         OPEN get_count_resrv_cur(l_material_rec.inventory_item_id,
                                  l_material_rec.organization_id,
                                  l_material_rec.wip_entity_id,
                                  l_material_rec.operation_sequence);
         FETCH get_count_resrv_cur INTO l_reserved_quantity;
         CLOSE get_count_resrv_cur;

         IF (l_reserved_quantity > 0) THEN
            IF G_DEBUG='Y' THEN
               AHL_DEBUG_PUB.debug('Reserved quantity for sch. material ID:' || p_x_req_material_tbl(i).schedule_material_id || ' is: ' || l_reserved_quantity || 'for INV ID: ' || l_material_rec.inventory_item_id);

               AHL_DEBUG_PUB.debug('Before calling delete reservation api');
            END IF;

            -- delete reservations.
            AHL_RSV_RESERVATIONS_PVT.DELETE_RESERVATION(
                          p_api_version => 1.0,
                          p_init_msg_list => FND_API.G_FALSE,
                          p_commit        => FND_API.G_FALSE,
                          p_module_type   => NULL,
                          x_return_status        => x_return_status,
                          x_msg_count            => x_msg_count,
                          x_msg_data             => x_msg_data,
                          p_scheduled_material_id => p_x_req_material_tbl(i).schedule_material_id);

            IF G_DEBUG='Y' THEN
              AHL_DEBUG_PUB.debug('After calling delete reservation api. Return status:' || x_return_status);
            END IF;

            -- check return status.
            IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

         END IF;

     END LOOP;

    END IF; --Material tbl
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug('beforer Eam wip job call');
   END IF;
   -- Call wip job api
    AHL_EAM_JOB_PVT.process_material_req
       (
        p_api_version        => l_api_version,
        p_init_msg_list      => p_init_msg_list,
        p_commit             => p_commit,
        p_validation_level   => p_validation_level,
        p_default            => l_default,
        p_module_type        => p_module_type,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,
        p_material_req_tbl   => l_req_material_tbl
        );
     --
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug('after wip job call');
   END IF;
 IF l_return_Status = 'S' THEN

     --Remove the records
     IF p_x_req_material_tbl.COUNT > 0 THEN
       FOR i IN p_x_req_material_tbl.FIRST..p_x_req_material_tbl.LAST
       LOOP
       -- If schedule date is not null then update to zero because collection has been done
            IF  p_x_req_material_tbl(i).schedule_material_id IS NOT NULL THEN
            -- Update schedule materials table requested quantity to zero
           UPDATE  AHL_SCHEDULE_MATERIALS
                  SET requested_quantity = 0,
                        status = 'DELETED',
                        object_version_number = p_x_req_material_tbl(i).object_version_number + 1
               WHERE SCHEDULED_MATERIAL_ID = p_x_req_material_tbl(i).schedule_material_id;
            END IF;
              --
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug('after set request quantity to zero');
   END IF;
          --
      END LOOP;
    END IF;
    --
   ELSE
     X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     RAISE Fnd_Api.G_EXC_ERROR;
    --
END IF; --Status
---------------------------End of Body---------------------------------------
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   --Change made on Nov 17, 2005 by jeli due to bug 4742895.
   --Ignore messages in stack if return status is S after calls to EAM APIs.
   /*
   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;
   */
   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of private api Remove Material Request ','+MAMRP+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;

  EXCEPTION
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO remove_material_request;
    X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

        IF G_DEBUG='Y' THEN
        Ahl_Debug_Pub.log_app_messages (
             x_msg_count, x_msg_data, 'ERROR' );
        Ahl_Debug_Pub.debug( 'ahl_pp_materials_pvt. Remove Material Request ','+MAMRP+');
        -- Check if API is called in debug mode. If yes, disable debug.
        Ahl_Debug_Pub.disable_debug;
        END IF;
WHEN Fnd_Api.G_EXC_ERROR THEN
    ROLLBACK TO remove_material_request;
    X_return_status := Fnd_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        IF G_DEBUG='Y' THEN
        -- Debug info.
        Ahl_Debug_Pub.log_app_messages (
             x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        Ahl_Debug_Pub.debug( 'ahl_pp_materials_pvt. Remove Material Request ','+MAMRP+');
        -- Check if API is called in debug mode. If yes, disable debug.
        Ahl_Debug_Pub.disable_debug;
        END IF;
WHEN OTHERS THEN
    ROLLBACK TO remove_material_request;
    X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
    THEN
    Fnd_Msg_Pub.add_exc_msg(p_pkg_name        =>  'AHL_PP_MATERIALS_PVT',
                            p_procedure_name  =>  'REMOVE_MATERIAL_REQUEST',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        IF G_DEBUG='Y' THEN
        -- Debug info.
        Ahl_Debug_Pub.log_app_messages (
             x_msg_count, x_msg_data, 'SQL ERROR' );
        Ahl_Debug_Pub.debug( 'ahl_pp_materials_pvt. Remove Material Request ','+MTMRP+');
        -- Check if API is called in debug mode. If yes, disable debug.
        Ahl_Debug_Pub.disable_debug;
        END IF;
END Remove_Material_Request;


-- Public Procedure Definitions follow --
-----------------------------------------
-- Start of Comments --
--  Procedure name    : Process_Material_Request
--  Type              : Private
--  Function          : Process material reservations through MRP for Routine and Non
--                      Routine jobs based on operation flag
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
--  Process Material Request Parameters:
--       p_x_req_material_tbl     IN OUT NOCOPY AHL_PP_MATERIALS_PVT.Req_Material_Tbl_Type,
--         Contains material information to perform material reservation depending
--         on operation flag
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Process_Material_Request (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := NULL,
    p_x_req_material_tbl     IN OUT NOCOPY AHL_PP_MATERIALS_PVT.Req_Material_Tbl_Type,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2
   )
 IS
 l_api_name        CONSTANT VARCHAR2(30) := 'PROCESS_MATERIAL_REQUEST';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_job_return_status        VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 l_interface_flag           VARCHAR2(1) := NULL;
 l_called_module            VARCHAR2(10) := 'UI';
 l_req_material_tbl         AHL_PP_MATERIALS_PVT.Req_Material_Tbl_Type;
 l_req_cr_material_tbl         AHL_PP_MATERIALS_PVT.Req_Material_Tbl_Type;
 l_req_up_material_tbl         AHL_PP_MATERIALS_PVT.Req_Material_Tbl_Type;
 l_req_re_material_tbl         AHL_PP_MATERIALS_PVT.Req_Material_Tbl_Type;
 l_commit              VARCHAR2(30)  := Fnd_Api.G_FALSE;

 BEGIN
   --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT process_material_request;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   -- Debug info.
   AHL_DEBUG_PUB.debug( 'enter ahl_pp_materias_pvt. process material  request','+PPMRP+');
   --
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
   IF p_x_req_material_tbl.COUNT > 0 THEN
      FOR i IN p_x_req_material_tbl.FIRST..p_x_req_material_tbl.LAST
        LOOP
           IF p_x_req_material_tbl(i).operation_flag = 'C'
            THEN
              --
              l_req_cr_material_tbl(i) := p_x_req_material_tbl(i);
               --
           ELSIF p_x_req_material_tbl(i).operation_flag = 'U'
           THEN

                l_req_up_material_tbl(i) := p_x_req_material_tbl(i);

           ELSIF p_x_req_material_tbl(i).operation_flag = 'D'
           THEN
                   --
                l_req_re_material_tbl(i) := p_x_req_material_tbl(i);
           END IF;
        END LOOP;
    END IF;
    --Call Private API to process
      IF l_req_cr_material_tbl.COUNT > 0 THEN
       -- Call create material request
       Create_Material_Reqst
                             (
                      p_api_version         => p_api_version,
                      p_init_msg_list       => p_init_msg_list,
                      p_commit              => l_commit,
                      p_validation_level    => p_validation_level,
                      p_interface_flag      => l_interface_flag,
                      p_x_req_material_tbl  => l_req_cr_material_tbl,
                      x_job_return_status   => l_job_return_status,
                      x_return_status       => l_return_status,
                      x_msg_count           => l_msg_count,
                      x_msg_data            => l_msg_data
                     ) ;
       IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
            IF l_msg_count > 0 THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;
       END IF;
       FOR i IN l_req_cr_material_tbl.First..l_req_cr_material_tbl.LAST LOOP
                   p_x_req_material_tbl(i).SCHEDULE_MATERIAL_ID := l_req_cr_material_tbl(i).SCHEDULE_MATERIAL_ID;
       END LOOP;
     END IF;
   IF l_req_up_material_tbl.COUNT > 0 THEN
     -- Call Update material request
       Update_Material_Reqst
                       (
                  p_api_version         => p_api_version,
                  p_init_msg_list       => p_init_msg_list,
                  p_commit              => l_commit,
                  p_validation_level    => p_validation_level,
                  p_module_type         => p_module_type,
                  p_x_req_material_tbl  => l_req_up_material_tbl,
                  x_return_status       => l_return_status,
                  x_msg_count           => l_msg_count,
                  x_msg_data            => l_msg_data
                  );

     IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
            IF l_msg_count > 0 THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;
       END IF;
   END IF;
   IF l_req_re_material_tbl.COUNT > 0 THEN
      -- Call Remove material request
        Remove_Material_Request
                      (
                   p_api_version   => p_api_version,
                   p_init_msg_list => p_init_msg_list,
                   p_commit        => l_commit,
                   p_validation_level  => p_validation_level,
                   p_module_type       => p_module_type,
                   p_x_req_material_tbl  => l_req_re_material_tbl,
                   x_return_status       => l_return_status,
                   x_msg_count           => l_msg_count,
                   x_msg_data            => l_msg_data
                   );

     IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
            IF l_msg_count > 0 THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;
       END IF;

      END IF;
   ------------------------End of Body---------------------------------------
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
   Ahl_Debug_Pub.debug( 'End of public api Process Material Request','+PPMRP+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   --
   END IF;
  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO process_material_request;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
       IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'ERROR' );
       AHL_DEBUG_PUB.debug( 'ahl_pp_materials_pvt. Process Material Request','+PPMRP+');
        -- Check if API is called in debug mode. If yes, disable debug.
       AHL_DEBUG_PUB.disable_debug;
       END IF;
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO process_material_request;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_pp_materials_pvt. Process Material Request','+PPMRP+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
            --
        END IF;
WHEN OTHERS THEN
    ROLLBACK TO process_material_request;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_PP_MATERIALS_PVT',
                            p_procedure_name  =>  'PROCESS_MATERIAL_REQUEST',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
              x_msg_count, x_msg_data, 'SQL ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_pp_materials_pvt. Process Material Request','+PPMRP+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
        END IF;
 END Process_Material_Request;
--
-- aps obsoleted
FUNCTION Get_Mrp_Net
 (p_schedule_material_id IN NUMBER,
  p_item_desc    IN VARCHAR2)
RETURN VARCHAR2 IS
 --
 CURSOR Check_material_cur (c_schedule_material_id IN NUMBER)
     IS
  SELECT scheduled_material_id,
         rt_oper_material_id
     FROM ahl_schedule_materials
  WHERE scheduled_material_id = c_schedule_material_id;
 --
 CURSOR Get_item_cur(c_segments IN VARCHAR2)
 IS
   SELECT distinct(inventory_item_id)
     FROM mtl_system_items_kfv
    WHERE concatenated_segments = c_segments;
 --
 l_return    VARCHAR2(1);
 --
 l_inventory_item_id       NUMBER;
 l_rt_oper_material_id     NUMBER;
 l_schedule_material_id    NUMBER;
BEGIN
    --Check for schedule material id
   OPEN Check_material_cur(p_schedule_material_id);
   FETCH Check_material_cur INTO l_schedule_material_id,l_rt_oper_material_id;
   CLOSE Check_material_cur;
   --
   -- Get inventory item
   OPEN Get_item_cur(p_item_desc);
   FETCH Get_item_cur INTO l_inventory_item_id;
   CLOSE Get_item_cur;
   --
   IF l_rt_oper_material_id IS NOT NULL THEN
       l_return := 'N';
    ELSE
      l_return := 'Y';
   END IF;
      RETURN  l_return;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;

END Get_Mrp_Net;
-- aps obsoleted

--
FUNCTION GET_QTY_PER_ASBLY
    (p_schedule_material_id IN NUMBER,
     p_item_desc            IN VARCHAR2 )
  RETURN NUMBER IS
 CURSOR Check_material_cur (c_schedule_material_id IN NUMBER)
     IS
  SELECT scheduled_material_id,
         rt_oper_material_id,requested_quantity
     FROM ahl_schedule_materials
  WHERE scheduled_material_id = c_schedule_material_id;
 --
 CURSOR Get_item_cur(c_segments IN VARCHAR2)
 IS
   SELECT distinct(inventory_item_id)
     FROM mtl_system_items_kfv
    WHERE concatenated_segments = c_segments;
 --
 l_inventory_item_id       NUMBER;
 l_rt_oper_material_id     NUMBER;
 l_schedule_material_id    NUMBER;
 l_requested_quantity      NUMBER;
BEGIN
     --Check for schedule material id
   OPEN Check_material_cur(p_schedule_material_id);
   FETCH Check_material_cur INTO l_schedule_material_id,l_rt_oper_material_id,
                                 l_requested_quantity;
   CLOSE Check_material_cur;
   --
   -- Get inventory item
   OPEN Get_item_cur(p_item_desc);
   FETCH Get_item_cur INTO l_inventory_item_id;
   CLOSE Get_item_cur;
   --
   IF l_schedule_material_id IS NOT NULL THEN
       RETURN l_requested_quantity;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;

END Get_Qty_Per_Asbly;
--
-- Start of Comments --
--  Procedure name    : Log_Transaction_Record
--  Type              : Private
--  Function          : Writes the details about a transaction in the Log Table
--                 AHL_WO_OPERATION_TXNS
--  Pre-reqs    :
--  Parameters  :
--
--  Log_Transaction Parameters:
--      p_trans_type_code               IN      VARCHAR2     Required
--      p_load_type_code                IN      NUMBER       Required
--      p_transaction_type_code         IN      NUMBER       Required
--      p_workorder_operation_id        IN      NUMBER       Default  NULL,
--      p_operation_resource_id         IN      NUMBER       Default  NULL,
--      p_schedule_material_id          IN      NUMBER       Default  NULL,
--      p_bom_resource_id               IN      NUMBER       Default  NULL,
--      p_cost_basis_code               IN      NUMBER       Default  NULL,
--      p_total_required                IN      NUMBER       Default  NULL,
--      p_assigned_units                IN      NUMBER       Default  NULL,
--      p_autocharge_type_code          IN      NUMBER       Default  NULL,
--      p_standard_rate_flag_code       IN      NUMBER       Default  NULL,
--      p_applied_resource_units        IN      NUMBER       Default  NULL,
--      p_applied_resource_value        IN      NUMBER       Default  NULL,
--      p_inventory_item_id             IN      NUMBER       Default  NULL,
--      p_scheduled_quantity            IN      NUMBER       Default  NULL,
--      p_scheduled_date                IN      DATE         Default  NULL,
--      p_mrp_net_flag                  IN      NUMBER       Default  NULL,
--      p_quantity_per_assembly         IN      NUMBER       Default  NULL,
--      p_required_quantity             IN      NUMBER       Default  NULL,
--      p_supply_locator_id             IN      NUMBER       Default  NULL,
--      p_supply_subinventory           IN      NUMBER       Default  NULL,
--      p_date_required                 IN      DATE         Default  NULL,
--      p_operation_type_code           IN      VARCHAR2     Default  NULL,
--      p_sched_start_date              IN      DATE         Default  NULL,
--      p_res_sched_end_date            IN      DATE         Default  NULL,
--      p_op_scheduled_start_date       IN      DATE         Default  NULL,
--      p_op_scheduled_end_date         IN      DATE         Default  NULL,
--      p_op_actual_start_date          IN      DATE         Default  NULL,
--      p_op_actual_end_date            IN      DATE         Default  NULL,
--      p_attribute_category            IN      VARCHAR2     Default  NULL,
--      p_attribute1                    IN      VARCHAR2     Default  NULL
--      p_attribute2                    IN      VARCHAR2     Default  NULL
--      p_attribute3                    IN      VARCHAR2     Default  NULL
--      p_attribute4                    IN      VARCHAR2     Default  NULL
--      p_attribute5                    IN      VARCHAR2     Default  NULL
--      p_attribute6                    IN      VARCHAR2     Default  NULL
--      p_attribute7                    IN      VARCHAR2     Default  NULL
--      p_attribute8                    IN      VARCHAR2     Default  NULL
--      p_attribute9                    IN      VARCHAR2     Default  NULL
--      p_attribute10                   IN      VARCHAR2     Default  NULL
--      p_attribute11                   IN      VARCHAR2     Default  NULL
--      p_attribute12                   IN      VARCHAR2     Default  NULL
--      p_attribute13                   IN      VARCHAR2     Default  NULL
--      p_attribute14                   IN      VARCHAR2     Default  NULL
--      p_attribute15                   IN      VARCHAR2     Default  NULL
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--
PROCEDURE Log_Transaction_Record
    ( p_wo_operation_txn_id      IN   NUMBER,
      p_object_version_number    IN   NUMBER,
      p_last_update_date         IN   DATE,
      p_last_updated_by          IN   NUMBER,
      p_creation_date            IN   DATE,
      p_created_by               IN   NUMBER,
      p_last_update_login        IN   NUMBER,
      p_load_type_code           IN   NUMBER,
      p_transaction_type_code    IN   NUMBER,
      p_workorder_operation_id   IN   NUMBER   := NULL,
      p_operation_resource_id    IN   NUMBER   := NULL,
      p_schedule_material_id     IN   NUMBER   := NULL,
      p_bom_resource_id          IN   NUMBER   := NULL,
      p_cost_basis_code          IN   NUMBER   := NULL,
      p_total_required           IN   NUMBER   := NULL,
      p_assigned_units           IN   NUMBER   := NULL,
      p_autocharge_type_code     IN   NUMBER   := NULL,
      p_standard_rate_flag_code  IN   NUMBER   := NULL,
      p_applied_resource_units   IN   NUMBER   := NULL,
      p_applied_resource_value   IN   NUMBER   := NULL,
      p_inventory_item_id        IN   NUMBER   := NULL,
      p_scheduled_quantity       IN   NUMBER   := NULL,
      p_scheduled_date           IN   DATE     := NULL,
      p_mrp_net_flag             IN   NUMBER   := NULL,
      p_quantity_per_assembly    IN   NUMBER   := NULL,
      p_required_quantity        IN   NUMBER   := NULL,
      p_supply_locator_id        IN   NUMBER   := NULL,
      p_supply_subinventory      IN   NUMBER   := NULL,
      p_date_required            IN   DATE     := NULL,
      p_operation_type_code      IN   VARCHAR2 := NULL,
      p_res_sched_start_date     IN   DATE     := NULL,
      p_res_sched_end_date       IN   DATE     := NULL,
      p_op_scheduled_start_date  IN   DATE     := NULL,
      p_op_scheduled_end_date    IN   DATE     := NULL,
      p_op_actual_start_date     IN   DATE     := NULL,
      p_op_actual_end_date       IN   DATE     := NULL,
      p_attribute_category       IN   VARCHAR2 := NULL,
      p_attribute1               IN   VARCHAR2 := NULL,
      p_attribute2               IN   VARCHAR2 := NULL,
      p_attribute3               IN   VARCHAR2 := NULL,
      p_attribute4               IN   VARCHAR2 := NULL,
      p_attribute5               IN   VARCHAR2 := NULL,
      p_attribute6               IN   VARCHAR2 := NULL,
      p_attribute7               IN   VARCHAR2 := NULL,
      p_attribute8               IN   VARCHAR2 := NULL,
      p_attribute9               IN   VARCHAR2 := NULL,
      p_attribute10              IN   VARCHAR2 := NULL,
      p_attribute11              IN   VARCHAR2 := NULL,
      p_attribute12              IN   VARCHAR2 := NULL,
      p_attribute13              IN   VARCHAR2 := NULL,
      p_attribute14              IN   VARCHAR2 := NULL,
      p_attribute15              IN   VARCHAR2 := NULL)
     IS
BEGIN
   --
   INSERT INTO AHL_WO_OPERATIONS_TXNS
    (  wo_operation_txn_id       ,
       object_version_number     ,
       last_update_date          ,
       last_updated_by           ,
       creation_date             ,
       created_by                ,
       last_update_login         ,
       load_type_code            ,
       transaction_type_code     ,
       workorder_operation_id    ,
       operation_resource_id     ,
       schedule_material_id      ,
       bom_resource_id           ,
       cost_basis_code           ,
       total_required            ,
       assigned_units            ,
       autocharge_type_code      ,
       standard_rate_flag_code   ,
       applied_resource_units    ,
       applied_resource_value    ,
       inventory_item_id         ,
       scheduled_quantity        ,
       scheduled_date            ,
       mrp_net_flag              ,
       quantity_per_assembly     ,
       required_quantity         ,
       supply_locator_id         ,
       supply_subinventory       ,
       date_required             ,
       operation_type_code       ,
       res_sched_start_date      ,
       res_sched_end_date        ,
       op_scheduled_start_date   ,
       op_scheduled_end_date     ,
       op_actual_start_date      ,
       op_actual_end_date        ,
       attribute_category        ,
       attribute1                ,
       attribute2                ,
       attribute3                ,
       attribute4                ,
       attribute5                ,
       attribute6                ,
       attribute7                ,
       attribute8                ,
       attribute9                ,
       attribute10               ,
       attribute11               ,
       attribute12               ,
       attribute13               ,
       attribute14               ,
       attribute15
       )
    VALUES
    (
       p_wo_operation_txn_id       ,
       p_object_version_number     ,
       p_last_update_date          ,
       p_last_updated_by           ,
       p_creation_date             ,
       p_created_by                ,
       p_last_update_login         ,
       p_load_type_code            ,
       p_transaction_type_code     ,
       p_workorder_operation_id    ,
       p_operation_resource_id     ,
       p_schedule_material_id      ,
       p_bom_resource_id           ,
       p_cost_basis_code           ,
       p_total_required            ,
       p_assigned_units            ,
       p_autocharge_type_code      ,
       p_standard_rate_flag_code   ,
       p_applied_resource_units    ,
       p_applied_resource_value    ,
       p_inventory_item_id         ,
       p_scheduled_quantity        ,
       p_scheduled_date            ,
       p_mrp_net_flag              ,
       p_quantity_per_assembly     ,
       p_required_quantity         ,
       p_supply_locator_id         ,
       p_supply_subinventory       ,
       p_date_required             ,
       p_operation_type_code       ,
       p_res_sched_start_date      ,
       p_res_sched_end_date        ,
       p_op_scheduled_start_date   ,
       p_op_scheduled_end_date     ,
       p_op_actual_start_date      ,
       p_op_actual_end_date        ,
       p_attribute_category        ,
       p_attribute1                ,
       p_attribute2                ,
       p_attribute3                ,
       p_attribute4                ,
       p_attribute5                ,
       p_attribute6                ,
       p_attribute7                ,
       p_attribute8                ,
       p_attribute9                ,
       p_attribute10               ,
       p_attribute11               ,
       p_attribute12               ,
       p_attribute13               ,
       p_attribute14               ,
       p_attribute15

    );

END log_transaction_record;
--
function GET_ISSUED_QTY(P_ORG_ID IN NUMBER, P_ITEM_ID IN NUMBER, P_WORKORDER_OP_ID IN NUMBER) RETURN NUMBER
IS
issued NUMBER;
CURSOR Q1(p_org_id NUMBER, p_itme_Id NUMBER,p_wo_op_id in NUMBER) IS
SELECT SUM(QUANTITY) FROM AHL_WORKORDER_MTL_TXNS
WHERE ORGANIZATION_ID = p_org_id
AND INVENTORY_ITEM_ID = p_item_id
AND WORKORDER_OPERATION_ID = p_wo_op_id
AND TRANSACTION_TYPE_ID = 35;
BEGIN


      OPEN Q1(P_ORG_ID,P_ITEM_ID, P_WORKORDER_OP_ID);
      FETCH Q1 INTO issued;
      IF(Q1%NOTFOUND) THEN
            issued := 0;
      END IF;
      CLOSE Q1;

      return issued;
END GET_ISSUED_QTY;

---JKJAIN FP ER # 6436303

    -------------------------------------------------------------------------------------
         -- Function for returning net quantity of material available with
         -- a workorder.
         -- Net Total Quantity = Total Quantity Issued - Total quantity returned
         -- Balaji added this function for OGMA ER # 5948868.
         --------------------------------------------------------------------------------------
         FUNCTION GET_NET_QTY(
                    P_ORG_ID IN NUMBER,
                    P_ITEM_ID IN NUMBER,
                    P_WORKORDER_OP_ID IN NUMBER
                  )
         RETURN NUMBER
         IS

         -- Local variables
         l_issue_qty NUMBER;
         l_rtn_qty NUMBER;
         l_net_qty NUMBER;

         -- Cursors
         -- cursor for getting total issued quantity
         CURSOR c_get_issue_qty(c_org_id NUMBER, c_itme_Id NUMBER,c_wo_op_id in NUMBER)
         IS
         SELECT  SUM(QUANTITY)
         FROM    AHL_WORKORDER_MTL_TXNS
         WHERE   ORGANIZATION_ID        = c_org_id
             AND INVENTORY_ITEM_ID      = c_itme_Id
             AND WORKORDER_OPERATION_ID = c_wo_op_id
             AND TRANSACTION_TYPE_ID    = 35; -- Mtl Issue Txn

         -- cursor for getting total returned quantity
         CURSOR c_get_rtn_qty(c_org_id NUMBER, c_itme_Id NUMBER,c_wo_op_id in NUMBER)
         IS
         SELECT  SUM(QUANTITY)
         FROM    AHL_WORKORDER_MTL_TXNS
         WHERE   ORGANIZATION_ID        = c_org_id
             AND INVENTORY_ITEM_ID      = c_itme_Id
             AND WORKORDER_OPERATION_ID = c_wo_op_id
             AND TRANSACTION_TYPE_ID    = 43; -- Mtl Rtn Txn

         BEGIN

                 OPEN c_get_issue_qty(p_org_id, p_item_id, p_workorder_op_id);
                 FETCH c_get_issue_qty INTO l_issue_qty;
                 CLOSE c_get_issue_qty;

                 IF l_issue_qty IS NULL
                 THEN
                    l_issue_qty := 0;
                 END IF;

                 OPEN c_get_rtn_qty(p_org_id, p_item_id, p_workorder_op_id);
                 FETCH c_get_rtn_qty INTO l_rtn_qty;
                 CLOSE c_get_rtn_qty;

                 IF l_rtn_qty IS NULL
                 THEN
                    l_rtn_qty := 0;
                 END IF;

                 l_net_qty := l_issue_qty - l_rtn_qty;

-- JKJAIN BUG # 7587902
--               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
--                    fnd_log.string
--                        (
--                           fnd_log.level_statement,
--                           'ahl.plsql.AHL_PP_MATERIALS_PVT.GET_NET_QTY',
--                           'l_net_qty -> ' || l_net_qty
--                        );
--               END IF;

                 return l_net_qty;

         END GET_NET_QTY;

--
-- Start of Comments --
--  Procedure name    : Process_Wo_Op_Materials
--  Type        : Private
--  Function    : Procedure to Process Requested materials defined at Route/Operation/Dispostion
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Process_Material Parameters :
--  p_prd_wooperation_tbl    IN       AHL_PRD_WORKORDER_PVT.Prd_Workoper_Tbl,
--  x_req_material_tbl     OUT        Ahl_Pp_Material_Pvt.Req_Material_Tbl_Type,Required
--         List of Required materials for a job
--

PROCEDURE Process_Wo_Op_Materials (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_operation_flag         IN            VARCHAR2,
    p_prd_wooperation_tbl    IN  AHL_PRD_OPERATIONS_PVT.Prd_Operation_Tbl,
    x_req_material_tbl       OUT NOCOPY Req_Material_Tbl_Type,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2)
   IS

CURSOR Sche_Mat_Cur(c_visit_task_id IN NUMBER)
 IS
SELECT ASM.scheduled_material_id,
       ASM.visit_id,visit_task_id,
       ASM.inventory_item_id,
         ASM.organization_id,
         ASM.requested_date,uom,
         ASM.rt_oper_material_id,
       ASM.operation_code,
         ASM.operation_sequence,
         ASM.requested_quantity,
         ASM.workorder_operation_id,
         ASM.position_path_id,
       ASM.relationship_id,
         ASM.mr_route_id,
         ASM.material_request_type,
         ASM.status,
	 -- Bug 8569097
	 ASM.attribute_category,
	 ASM.attribute1,
	 ASM.attribute2,
         ASM.attribute3,
         ASM.attribute4,
         ASM.attribute5,
	 ASM.attribute6,
	 ASM.attribute7,
	 ASM.attribute8,
	 ASM.attribute9,
	 ASM.attribute10,
	 ASM.attribute11,
	 ASM.attribute12,
	 ASM.attribute13,
	 ASM.attribute14,
         ASM.attribute15
 FROM AHL_SCHEDULE_MATERIALS ASM,
      AHL_RT_OPER_MATERIALS ARM
 WHERE ASM.rt_oper_material_id = ARM.RT_OPER_MATERIAL_ID
   AND ASM.visit_task_id = C_VISIT_TASK_ID
   AND ASM.requested_quantity > 0
   AND ASM.STATUS IN ('ACTIVE','IN-SERVICE');
   --
   CURSOR Visit_Task_Cur(c_workorder_id IN NUMBER)
    IS
     SELECT a.visit_id,
          visit_task_id,
          organization_id
        FROM ahl_workorders A,
             ahl_visits_b b
      WHERE workorder_id = c_workorder_id
       AND a.visit_id = b.visit_id;

  CURSOR Material_Detail_Cur (c_operation_id       IN NUMBER,
                              c_operation_sequence IN NUMBER)
   IS
  SELECT Scheduled_material_id
    FROM AHL_SCHEDULE_MATERIALS
      WHERE WORKORDER_OPERATION_ID = c_operation_id
     AND OPERATION_SEQUENCE = c_operation_sequence;

    l_api_name        CONSTANT VARCHAR2(30) := 'PROCESS_WO_OP_MATERIALS';
    l_api_version     CONSTANT NUMBER       := 1.0;
    l_msg_count                NUMBER;
    l_return_status            VARCHAR2(1);
    l_msg_data                 VARCHAR2(2000);
    --
    l_prd_wooperation_tbl   AHL_PRD_OPERATIONS_PVT.Prd_Operation_Tbl := p_prd_wooperation_tbl;
    l_Sche_Mat_Rec          Sche_Mat_Cur%ROWTYPE;
      l_Visit_Task_Rec        Visit_Task_Cur%ROWTYPE;
    l_req_material_tbl      Req_Material_Tbl_Type;
    l_scheduled_material_id NUMBER;
      l_idx NUMBER;

    dff_default_values dff_default_values_type;

    BEGIN

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
                  fnd_log.level_procedure,
                  'ahl.plsql.AHL_PP_MATERIALS_PVT.Process_Wo_Op_Materials',
                  'At the start of PLSQL procedure'
            );
    END IF;
   --------------------Initialize ----------------------------------
   -- Standard Start of API savepoint
   SAVEPOINT Process_Wo_Op_Materials;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(p_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

     --
       IF l_prd_wooperation_tbl.COUNT > 0 THEN
         FOR i IN l_prd_wooperation_tbl.FIRST..l_prd_wooperation_tbl.LAST
         LOOP
           --

              IF (p_operation_flag = 'C' AND
                  l_prd_wooperation_tbl(i).workorder_operation_id IS NOT NULL AND
                l_prd_wooperation_tbl(i).workorder_operation_id <> FND_API.G_MISS_NUM )
               THEN

           --Get visit id, visit task id
           OPEN Visit_Task_Cur(l_prd_wooperation_tbl(i).workorder_id);
           FETCH Visit_Task_Cur INTO l_Visit_Task_Rec;
           CLOSE Visit_Task_Cur;


   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
                  fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                  'Material Requirement for workorder id: ' || l_prd_wooperation_tbl(i).workorder_id
            );
            fnd_log.string
            (
                  fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                  'Material Requirement for workorder operation id: ' || l_prd_wooperation_tbl(i).workorder_operation_id
            );
            fnd_log.string
            (
                  fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                  'Material Requirement for workorder operation seq: ' || l_prd_wooperation_tbl(i).operation_sequence_num
            );

     END IF;
              --Check for one operation sequence exists means materials exist at route only
                    IF (l_prd_wooperation_tbl(i).operation_sequence_num IS NOT NULL AND
                          l_prd_wooperation_tbl(i).operation_sequence_num <> FND_API.G_MISS_NUM)
                         THEN
                         --
                           l_idx := 0;
                           FOR l_Sche_Mat_Rec IN Sche_Mat_Cur(l_Visit_Task_Rec.visit_task_id)
                           LOOP
                             IF (l_Sche_Mat_Rec.operation_sequence IS NULL AND
                                   l_Sche_Mat_Rec.workorder_operation_id IS NULL )THEN

                             l_req_material_tbl(l_idx).workorder_id := l_prd_wooperation_tbl(i).workorder_id;
                             l_req_material_tbl(l_idx).organization_id := l_Visit_Task_Rec.organization_id;
                             l_req_material_tbl(l_idx).workorder_operation_id := l_prd_wooperation_tbl(i).workorder_operation_id;
                             l_req_material_tbl(l_idx).operation_sequence := l_prd_wooperation_tbl(i).operation_sequence_num;
                             l_req_material_tbl(l_idx).inventory_item_id := l_Sche_Mat_Rec.inventory_item_id;
                             l_req_material_tbl(l_idx).schedule_material_id := l_Sche_Mat_Rec.scheduled_material_id;
                             l_req_material_tbl(l_idx).requested_date := l_prd_wooperation_tbl(i).scheduled_start_date;
                             l_req_material_tbl(l_idx).rt_oper_material_id := l_Sche_Mat_Rec.rt_oper_material_id;
                             l_req_material_tbl(l_idx).requested_quantity := l_Sche_Mat_Rec.requested_quantity;
                             l_req_material_tbl(l_idx).uom_code := l_Sche_Mat_Rec.uom;
--  Fix for Bug 8569097
/*                             get_dff_default_values
                             (
                              p_req_material_rec      => l_req_material_tbl(l_idx),
                              flex_fields_defaults    =>  dff_default_values
                             );

                             l_req_material_tbl(l_idx).attribute_category := dff_default_values.attribute_category;
                             l_req_material_tbl(l_idx).attribute1 := dff_default_values.attribute1;
                             l_req_material_tbl(l_idx).attribute2 := dff_default_values.attribute2;
                             l_req_material_tbl(l_idx).attribute3 := dff_default_values.attribute3;
                             l_req_material_tbl(l_idx).attribute4 := dff_default_values.attribute4;
                             l_req_material_tbl(l_idx).attribute5 := dff_default_values.attribute5;
                             l_req_material_tbl(l_idx).attribute6 := dff_default_values.attribute6;
                             l_req_material_tbl(l_idx).attribute7 := dff_default_values.attribute7;
                             l_req_material_tbl(l_idx).attribute8 := dff_default_values.attribute8;
                             l_req_material_tbl(l_idx).attribute9 := dff_default_values.attribute9;
                             l_req_material_tbl(l_idx).attribute10 := dff_default_values.attribute10;
                             l_req_material_tbl(l_idx).attribute11 := dff_default_values.attribute11;
                             l_req_material_tbl(l_idx).attribute12 := dff_default_values.attribute12;
                             l_req_material_tbl(l_idx).attribute13 := dff_default_values.attribute13;
                             l_req_material_tbl(l_idx).attribute14 := dff_default_values.attribute14;
                             l_req_material_tbl(l_idx).attribute15 := dff_default_values.attribute15;
*/
			     l_req_material_tbl(l_idx).attribute_category := l_Sche_Mat_Rec.attribute_category;
 	                     l_req_material_tbl(l_idx).attribute1 := l_Sche_Mat_Rec.attribute1;
 	                     l_req_material_tbl(l_idx).attribute2 := l_Sche_Mat_Rec.attribute2;
 	                     l_req_material_tbl(l_idx).attribute3 := l_Sche_Mat_Rec.attribute3;
 	                     l_req_material_tbl(l_idx).attribute4 := l_Sche_Mat_Rec.attribute4;
 	                     l_req_material_tbl(l_idx).attribute5 := l_Sche_Mat_Rec.attribute5;
 	                     l_req_material_tbl(l_idx).attribute6 := l_Sche_Mat_Rec.attribute6;
 	                     l_req_material_tbl(l_idx).attribute7 := l_Sche_Mat_Rec.attribute7;
 	                     l_req_material_tbl(l_idx).attribute8 := l_Sche_Mat_Rec.attribute8;
 	                     l_req_material_tbl(l_idx).attribute9 := l_Sche_Mat_Rec.attribute9;
 	                     l_req_material_tbl(l_idx).attribute10 := l_Sche_Mat_Rec.attribute10;
 	                     l_req_material_tbl(l_idx).attribute11 := l_Sche_Mat_Rec.attribute11;
 	                     l_req_material_tbl(l_idx).attribute12 := l_Sche_Mat_Rec.attribute12;
 	                     l_req_material_tbl(l_idx).attribute13 := l_Sche_Mat_Rec.attribute13;
 	                     l_req_material_tbl(l_idx).attribute14 := l_Sche_Mat_Rec.attribute14;
 	                     l_req_material_tbl(l_idx).attribute15 := l_Sche_Mat_Rec.attribute15;

                             -- fix for bug# 5549135.
                             --l_req_material_tbl(l_idx).mrp_net_flag := 1;
                             l_req_material_tbl(l_idx).mrp_net_flag := 2;

                       -- Update with workorder operation details
                                 UPDATE ahl_schedule_materials
                                   SET workorder_operation_id = l_prd_wooperation_tbl(i).workorder_operation_id,
                                         operation_sequence = l_prd_wooperation_tbl(i).operation_sequence_num,
                                           -- AnRaj: truncating Requested Date for Material Requirement based on discussions with PM
                                           requested_date   =  trunc(l_prd_wooperation_tbl(i).scheduled_start_date),
                                           organization_id  = l_Visit_Task_Rec.organization_id,
                                           object_version_number = object_version_number + 1,
                             last_update_date      = sysdate,
                             last_updated_by       = fnd_global.user_id,
                             last_update_login     = fnd_global.login_id,
                             ATTRIBUTE_CATEGORY  = l_req_material_tbl(l_idx).attribute_category,
                             ATTRIBUTE1          = l_req_material_tbl(l_idx).attribute1,
                             ATTRIBUTE2          = l_req_material_tbl(l_idx).attribute2,
                             ATTRIBUTE3          = l_req_material_tbl(l_idx).attribute3,
                             ATTRIBUTE4          = l_req_material_tbl(l_idx).attribute4,
                             ATTRIBUTE5          = l_req_material_tbl(l_idx).attribute5,
                             ATTRIBUTE6          = l_req_material_tbl(l_idx).attribute6,
                             ATTRIBUTE7          = l_req_material_tbl(l_idx).attribute7,
                             ATTRIBUTE8          = l_req_material_tbl(l_idx).attribute8,
                             ATTRIBUTE9          = l_req_material_tbl(l_idx).attribute9,
                             ATTRIBUTE10          = l_req_material_tbl(l_idx).attribute10,
                             ATTRIBUTE11          = l_req_material_tbl(l_idx).attribute11,
                             ATTRIBUTE12          = l_req_material_tbl(l_idx).attribute12,
                             ATTRIBUTE13          = l_req_material_tbl(l_idx).attribute13,
                             ATTRIBUTE14          = l_req_material_tbl(l_idx).attribute14,
                             ATTRIBUTE15          = l_req_material_tbl(l_idx).attribute15
                             WHERE scheduled_material_id = l_Sche_Mat_Rec.scheduled_material_id;

                               ELSIF (l_prd_wooperation_tbl(i).operation_sequence_num = l_Sche_Mat_Rec.operation_sequence
                                      AND l_Sche_Mat_Rec.workorder_operation_id IS NULL) THEN

                             l_req_material_tbl(l_idx).workorder_id := l_prd_wooperation_tbl(i).workorder_id;
                             l_req_material_tbl(l_idx).organization_id := l_Visit_Task_Rec.organization_id;
                             l_req_material_tbl(l_idx).workorder_operation_id := l_prd_wooperation_tbl(i).workorder_operation_id;
                             l_req_material_tbl(l_idx).operation_sequence := l_prd_wooperation_tbl(i).operation_sequence_num;
                             l_req_material_tbl(l_idx).inventory_item_id := l_Sche_Mat_Rec.inventory_item_id;
                             l_req_material_tbl(l_idx).schedule_material_id := l_Sche_Mat_Rec.scheduled_material_id;
                             l_req_material_tbl(l_idx).requested_date := l_prd_wooperation_tbl(i).scheduled_start_date;
                             l_req_material_tbl(l_idx).rt_oper_material_id := l_Sche_Mat_Rec.rt_oper_material_id;
                             l_req_material_tbl(l_idx).requested_quantity := l_Sche_Mat_Rec.requested_quantity;
                             l_req_material_tbl(l_idx).uom_code := l_Sche_Mat_Rec.uom;
                             -- fix for bug# 5549135
                             --l_req_material_tbl(l_idx).mrp_net_flag := 1;
                             l_req_material_tbl(l_idx).mrp_net_flag := 2;
--  Fix for Bug 8569097
/*
                             get_dff_default_values
                             (
                              p_req_material_rec      => l_req_material_tbl(l_idx),
                              flex_fields_defaults    =>  dff_default_values
                             );

                             l_req_material_tbl(l_idx).attribute_category := dff_default_values.attribute_category;
                             l_req_material_tbl(l_idx).attribute1 := dff_default_values.attribute1;
                             l_req_material_tbl(l_idx).attribute2 := dff_default_values.attribute2;
                             l_req_material_tbl(l_idx).attribute3 := dff_default_values.attribute3;
                             l_req_material_tbl(l_idx).attribute4 := dff_default_values.attribute4;
                             l_req_material_tbl(l_idx).attribute5 := dff_default_values.attribute5;
                             l_req_material_tbl(l_idx).attribute6 := dff_default_values.attribute6;
                             l_req_material_tbl(l_idx).attribute7 := dff_default_values.attribute7;
                             l_req_material_tbl(l_idx).attribute8 := dff_default_values.attribute8;
                             l_req_material_tbl(l_idx).attribute9 := dff_default_values.attribute9;
                             l_req_material_tbl(l_idx).attribute10 := dff_default_values.attribute10;
                             l_req_material_tbl(l_idx).attribute11 := dff_default_values.attribute11;
                             l_req_material_tbl(l_idx).attribute12 := dff_default_values.attribute12;
                             l_req_material_tbl(l_idx).attribute13 := dff_default_values.attribute13;
                             l_req_material_tbl(l_idx).attribute14 := dff_default_values.attribute14;
                             l_req_material_tbl(l_idx).attribute15 := dff_default_values.attribute15;
*/
			     l_req_material_tbl(l_idx).attribute_category := l_Sche_Mat_Rec.attribute_category;
 	                     l_req_material_tbl(l_idx).attribute1 := l_Sche_Mat_Rec.attribute1;
 	                     l_req_material_tbl(l_idx).attribute2 := l_Sche_Mat_Rec.attribute2;
 	                     l_req_material_tbl(l_idx).attribute3 := l_Sche_Mat_Rec.attribute3;
 	                     l_req_material_tbl(l_idx).attribute4 := l_Sche_Mat_Rec.attribute4;
 	                     l_req_material_tbl(l_idx).attribute5 := l_Sche_Mat_Rec.attribute5;
 	                     l_req_material_tbl(l_idx).attribute6 := l_Sche_Mat_Rec.attribute6;
 	                     l_req_material_tbl(l_idx).attribute7 := l_Sche_Mat_Rec.attribute7;
 	                     l_req_material_tbl(l_idx).attribute8 := l_Sche_Mat_Rec.attribute8;
 	                     l_req_material_tbl(l_idx).attribute9 := l_Sche_Mat_Rec.attribute9;
 	                     l_req_material_tbl(l_idx).attribute10 := l_Sche_Mat_Rec.attribute10;
 	                     l_req_material_tbl(l_idx).attribute11 := l_Sche_Mat_Rec.attribute11;
 	                     l_req_material_tbl(l_idx).attribute12 := l_Sche_Mat_Rec.attribute12;
 	                     l_req_material_tbl(l_idx).attribute13 := l_Sche_Mat_Rec.attribute13;
 	                     l_req_material_tbl(l_idx).attribute14 := l_Sche_Mat_Rec.attribute14;
 	                     l_req_material_tbl(l_idx).attribute15 := l_Sche_Mat_Rec.attribute15;

                       --Update with operation details
                                 UPDATE ahl_schedule_materials
                                   SET workorder_operation_id = l_prd_wooperation_tbl(i).workorder_operation_id,
                                           object_version_number = object_version_number + 1,
                                           -- AnRaj: truncating Requested Date for Material Requirement based on discussions with PM
                                           requested_date   =  trunc(l_prd_wooperation_tbl(i).scheduled_start_date),
                                           organization_id  = l_Visit_Task_Rec.organization_id,
                             last_update_date      = sysdate,
                             last_updated_by       = fnd_global.user_id,
                                   last_update_login     = fnd_global.login_id,
                                           ATTRIBUTE_CATEGORY  = l_req_material_tbl(l_idx).attribute_category,
                                           ATTRIBUTE1          = l_req_material_tbl(l_idx).attribute1,
                                           ATTRIBUTE2          = l_req_material_tbl(l_idx).attribute2,
                                           ATTRIBUTE3          = l_req_material_tbl(l_idx).attribute3,
                                           ATTRIBUTE4          = l_req_material_tbl(l_idx).attribute4,
                                           ATTRIBUTE5          = l_req_material_tbl(l_idx).attribute5,
                                           ATTRIBUTE6          = l_req_material_tbl(l_idx).attribute6,
                                           ATTRIBUTE7          = l_req_material_tbl(l_idx).attribute7,
                                           ATTRIBUTE8          = l_req_material_tbl(l_idx).attribute8,
                                           ATTRIBUTE9          = l_req_material_tbl(l_idx).attribute9,
                                           ATTRIBUTE10          = l_req_material_tbl(l_idx).attribute10,
                                           ATTRIBUTE11          = l_req_material_tbl(l_idx).attribute11,
                                           ATTRIBUTE12          = l_req_material_tbl(l_idx).attribute12,
                                           ATTRIBUTE13          = l_req_material_tbl(l_idx).attribute13,
                                           ATTRIBUTE14          = l_req_material_tbl(l_idx).attribute14,
                                           ATTRIBUTE15          = l_req_material_tbl(l_idx).attribute15
                                  WHERE scheduled_material_id = l_Sche_Mat_Rec.scheduled_material_id;


                               END IF;
                               l_idx := l_idx + 1;
                 END LOOP;

                        END IF; --COUNT
              END IF; --dml operation
         END LOOP;
       END IF;

   --Modified by srin to remove the replave percent check for Bug #4007076
   --Assign the derived values
      IF l_req_material_tbl.COUNT > 0 THEN
         FOR j IN l_req_material_tbl.FIRST..l_req_material_tbl.LAST
         LOOP
         x_req_material_tbl(j).workorder_id := l_req_material_tbl(j).workorder_id;
       x_req_material_tbl(j).organization_id := l_req_material_tbl(j).organization_id;
       x_req_material_tbl(j).workorder_operation_id := l_req_material_tbl(j).workorder_operation_id;
         x_req_material_tbl(j).operation_sequence := l_req_material_tbl(j).operation_sequence;
         x_req_material_tbl(j).inventory_item_id := l_req_material_tbl(j).inventory_item_id;
         x_req_material_tbl(j).schedule_material_id := l_req_material_tbl(j).schedule_material_id;
         x_req_material_tbl(j).requested_date := l_req_material_tbl(j).requested_date;
         x_req_material_tbl(j).rt_oper_material_id := l_req_material_tbl(j).rt_oper_material_id;
         x_req_material_tbl(j).requested_quantity := l_req_material_tbl(j).requested_quantity;
         x_req_material_tbl(j).uom_code   := l_req_material_tbl(j).uom_code;
         x_req_material_tbl(j).mrp_net_flag := l_req_material_tbl(j).mrp_net_flag;
         x_req_material_tbl(j).operation_flag := 'C';

         x_req_material_tbl(j).ATTRIBUTE_CATEGORY  := l_req_material_tbl(j).attribute_category;
         x_req_material_tbl(j).ATTRIBUTE1 := l_req_material_tbl(j).attribute1;
         x_req_material_tbl(j).ATTRIBUTE2 := l_req_material_tbl(j).attribute2;
         x_req_material_tbl(j).ATTRIBUTE3 := l_req_material_tbl(j).attribute3;
         x_req_material_tbl(j).ATTRIBUTE4 := l_req_material_tbl(j).attribute4;
         x_req_material_tbl(j).ATTRIBUTE5 := l_req_material_tbl(j).attribute5;
         x_req_material_tbl(j).ATTRIBUTE6 := l_req_material_tbl(j).attribute6;
         x_req_material_tbl(j).ATTRIBUTE7 := l_req_material_tbl(j).attribute7;
         x_req_material_tbl(j).ATTRIBUTE8 := l_req_material_tbl(j).attribute8;
         x_req_material_tbl(j).ATTRIBUTE9 := l_req_material_tbl(j).attribute9;
         x_req_material_tbl(j).ATTRIBUTE10 := l_req_material_tbl(j).attribute10;
         x_req_material_tbl(j).ATTRIBUTE11 := l_req_material_tbl(j).attribute11;
         x_req_material_tbl(j).ATTRIBUTE12 := l_req_material_tbl(j).attribute12;
         x_req_material_tbl(j).ATTRIBUTE13 := l_req_material_tbl(j).attribute13;
         x_req_material_tbl(j).ATTRIBUTE14 := l_req_material_tbl(j).attribute14;
         x_req_material_tbl(j).ATTRIBUTE15 := l_req_material_tbl(j).attribute15;

       END LOOP;
        END IF;
     --Sync up process to update requested date if changed from original date
       IF l_prd_wooperation_tbl.COUNT > 0 THEN
         FOR i IN l_prd_wooperation_tbl.FIRST..l_prd_wooperation_tbl.LAST
         LOOP
           --
              IF (p_operation_flag = 'S' AND
                  l_prd_wooperation_tbl(i).workorder_operation_id IS NOT NULL AND
                l_prd_wooperation_tbl(i).workorder_operation_id <> FND_API.G_MISS_NUM AND
                   l_prd_wooperation_tbl(i).operation_sequence_num IS NOT NULL AND
                l_prd_wooperation_tbl(i).operation_sequence_num <> FND_API.G_MISS_NUM)
               THEN
                 --
             OPEN Material_Detail_Cur(l_prd_wooperation_tbl(i).workorder_operation_id,
                                            l_prd_wooperation_tbl(i).operation_sequence_num);
                   LOOP
                   FETCH Material_Detail_Cur INTO l_scheduled_material_id;
                   EXIT WHEN Material_Detail_Cur%NOTFOUND;
                   IF l_scheduled_material_id IS NOT NULL THEN
                      --
                        UPDATE ahl_schedule_materials
                          -- AnRaj: truncating Requested Date for Material Requirement based on discussions with PM
                          SET requested_date = trunc(l_prd_wooperation_tbl(i).actual_start_date),
                              object_version_number = object_version_number + 1,
                      last_update_date      = sysdate,
                      last_updated_by       = fnd_global.user_id,
                      last_update_login     = fnd_global.login_id
                        WHERE scheduled_material_id = l_scheduled_material_id;

                    END IF;
                 END LOOP;
                   CLOSE Material_Detail_Cur;
             END IF;
      END LOOP;
       END IF;
   --Debug Info
   IF x_req_material_tbl.count > 0 THEN
   FOR i IN x_req_material_tbl.FIRST..x_req_material_tbl.LAST
   LOOP

   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'x_req_material_tbl(i).workorder_id'||x_req_material_tbl(i).workorder_id);
   AHL_DEBUG_PUB.debug( 'x_req_material_tbl(i).organization_id'||x_req_material_tbl(i).organization_id);
   AHL_DEBUG_PUB.debug( 'x_req_material_tbl(i).workorder_operation_id'||x_req_material_tbl(i).workorder_operation_id);
   AHL_DEBUG_PUB.debug( 'x_req_material_tbl(i).operation_sequence'||x_req_material_tbl(i).operation_sequence);
   AHL_DEBUG_PUB.debug( 'x_req_material_tbl(i).inventory_item_id'||x_req_material_tbl(i).inventory_item_id);
   AHL_DEBUG_PUB.debug( 'x_req_material_tbl(i).requested_date'||x_req_material_tbl(i).requested_date);

   END IF;

   END LOOP;
   END IF;
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'x_req_material_tbl.count'||x_req_material_tbl.count);
   END IF;

   ------------------------End of Body---------------------------------------
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
     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
                  fnd_log.level_procedure,
                  'ahl.plsql.AHL_PP_MATERIALS_PVT.Process_Wo_Op_Materials.end',
                  'At the end of PLSQL procedure'
            );
     END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Process_Wo_Op_Materials;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Process_Wo_Op_Materials;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
WHEN OTHERS THEN
    ROLLBACK TO Process_Wo_Op_Materials;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_PP_MATERIALS_PVT',
                            p_procedure_name  =>  'PROCESS_WO_OP_MATERIALS',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

  END Process_Wo_Op_Materials;

--
-- Start of Comments --
--  Procedure name    : Material_Notification
--  Type        : Private
--  Function    : Procedure to send material Notification when new item has been added
--                or quantity has been changed.
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Process_Material Notification Parameters :
--  p_Req_Material_Tbl          IN         Req_Material_Tbl_Type,
--

PROCEDURE  MATERIAL_NOTIFICATION
(
 p_api_version               IN         NUMBER:=  1.0,
 p_init_msg_list             IN         VARCHAR2,
 p_commit                    IN         VARCHAR2,
 p_validation_level          IN         NUMBER,
 p_Req_Material_Tbl          IN         Req_Material_Tbl_Type,
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2
 )
 IS


 CURSOR  CursorNotify(c_object_type IN VARCHAR2)
 IS
 /*
 SELECT A.APPROVAL_RULE_ID,
          A.APPROVAL_OBJECT_CODE,
            A.STATUS_CODE,
            B.APPROVER_NAME,
            B.APPROVER_SEQUENCE
      FROM AHL_APPROVAL_RULES_B A,AHL_APPROVERS_V B
      WHERE A.APPROVAL_RULE_ID=B.APPROVAL_RULE_ID
      AND A.STATUS_CODE='ACTIVE'
    AND A.APPROVAL_OBJECT_CODE=c_object_type
    ORDER BY  B.APPROVER_SEQUENCE;
 */
 /*
  * R12 Perf Tuning
  * Balaji blown open AHL_APPROVERS_V since it introduces NMV
  * due to Unions in the query. Reference bug # 4919273 and 4919045
  */
 SELECT DISTINCT
       JRREV.USER_NAME APPROVER_NAME
 FROM
       AHL_APPROVERS AA,
       FND_LOOKUP_VALUES_VL FNDA,
       AHL_JTF_RS_EMP_V JRREV,
       AHL_APPROVAL_RULES_B APR
 WHERE
      FNDA.LOOKUP_TYPE = 'AHL_APPROVER_TYPE'
      AND FNDA.LOOKUP_CODE = AA.APPROVER_TYPE_CODE
      AND AA.APPROVER_TYPE_CODE = 'USER'
      AND AA.APPROVER_ID = JRREV.RESOURCE_ID
      AND APR.APPROVAL_RULE_ID = AA.APPROVAL_RULE_ID
      AND APR.APPROVAL_OBJECT_CODE = c_object_type
UNION
 SELECT DISTINCT
      JRRV.ROLE_NAME APPROVER_NAME
 FROM
      AHL_APPROVERS AA,
      FND_LOOKUP_VALUES_VL FNDA,
      JTF_RS_ROLE_RELATIONS_VL JRRV,
      AHL_APPROVAL_RULES_B APR
 WHERE
      FNDA.LOOKUP_TYPE = 'AHL_APPROVER_TYPE'
      AND FNDA.LOOKUP_CODE = AA.APPROVER_TYPE_CODE
      AND AA.APPROVER_TYPE_CODE = 'ROLE'
      AND AA.APPROVER_ID = JRRV.ROLE_ID
      AND APR.APPROVAL_RULE_ID = AA.APPROVAL_RULE_ID
      AND APR.APPROVAL_OBJECT_CODE = c_object_type
UNION
 SELECT DISTINCT
     '' APPROVER_NAME
 FROM
     AHL_APPROVERS AA,
     FND_LOOKUP_VALUES_VL FNDA,
     AHL_APPROVAL_RULES_B APR
 WHERE
     FNDA.LOOKUP_TYPE = 'AHL_APPROVER_TYPE'
     AND FNDA.LOOKUP_CODE = AA.APPROVER_TYPE_CODE
     AND AA.APPROVER_TYPE_CODE = 'ROLE'
     AND AA.APPROVER_ID IS NULL
     AND APR.APPROVAL_RULE_ID = AA.APPROVAL_RULE_ID
     AND APR.APPROVAL_OBJECT_CODE = c_object_type;

   l_rec   CursorNotify%rowtype;

   l_api_name        CONSTANT VARCHAR2(30) := 'MATERIAL_NOTIFICATION';
   l_api_version     CONSTANT NUMBER       := 1.0;
   l_msg_count                NUMBER;
   l_return_status            VARCHAR2(1);
   l_msg_data                 VARCHAR2(2000);
   --
   l_object                       VARCHAR2(30):='PRD_MTL_NTF';
   l_active                       VARCHAR2(50) := 'N';
   l_process_name                 VARCHAR2(50);

   l_item_type                 VARCHAR2(30) := 'AHLGAPP';
   l_message_name              VARCHAR2(200) := 'GEN_STDLN_MESG';
   l_subject                   VARCHAR2(3000);
   l_body                      VARCHAR2(3000) := NULL;
   l_text                      VARCHAR2(3000) := NULL;
   l_send_to_role_name         VARCHAR2(30):= NULL;
   l_send_to_res_id            NUMBER:= NULL;
   l_notif_id                  NUMBER;
   l_notif_id1                 NUMBER;
   l_role_name                 VARCHAR2(100);
   l_display_role_name         VARCHAR2(240);
   l_object_notes              VARCHAR2(400);

   l_Req_Material_Tbl   Req_Material_Tbl_Type := p_Req_Material_Tbl;

  BEGIN

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
                  fnd_log.level_procedure,
                  'ahl.plsql.AHL_PP_MATERIALS_PVT.Material_Notification',
                  'At the start of PLSQL procedure'
            );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT Material_Notification;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_boolean(p_init_msg_list)
    THEN
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

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
                  fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                  'Request for Material Notification for Number of Records : ' || l_Req_Material_Tbl.COUNT
            );

     END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string
              (
               fnd_log.level_procedure,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                  'Before calling Ahl_Utility_Pvt.Get_Wf_Process_Name'
                 );


     END IF;

    --Get workflow status active or not
     Ahl_Utility_Pvt.Get_Wf_Process_Name
                     (
                    p_object       =>l_object,
                    x_active       =>l_active,
                    x_process_name =>l_process_name ,
                    x_item_type    =>l_item_type,
                    x_return_status=>l_return_status,
                    x_msg_count    =>l_msg_count,
                    x_msg_data     =>l_msg_data);


   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string
            (
              fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
              'After calling Ahl_Utility_Pvt.Get_Wf_Process_Name, Return Status : '|| l_return_status
            );
    END IF;

    -- Check Error Message stack.
     IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
       END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
          (
                fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Active flag : '||l_active
          );
   END IF;

    IF l_active = 'Y' THEN
    FOR i IN l_Req_Material_Tbl.FIRST..l_Req_Material_Tbl.LAST
      LOOP
          IF l_Req_Material_Tbl(i).operation_flag = 'C' THEN
         IF l_Req_Material_Tbl(i).concatenated_segments IS NOT NULL THEN

            FND_MESSAGE.SET_NAME('AHL','AHL_PRD_MAT_REQ_ADDED_NTF');
            FND_MESSAGE.set_token('ITEM',l_Req_Material_Tbl(i).concatenated_segments,false);
            l_text := fnd_message.get;
            --Include quantity and date
            FND_MESSAGE.SET_NAME('AHL','AHL_PRD_MAT_REQ_QTY_NTF');
            FND_MESSAGE.set_token('QTY',l_Req_Material_Tbl(i).requested_quantity,false);
            l_body := fnd_message.get;
            l_Req_Material_Tbl(i).notify_text := l_text ||''||l_body
                  ||'; For Workorder:'||l_Req_Material_Tbl(i).job_number
                  || '; Required date:'||l_Req_Material_Tbl(i).requested_date;

         END IF;

            ELSE
            --Update
            FND_MESSAGE.SET_NAME('AHL','AHL_PRD_MAT_REQ_NTF_UPDATE');
            FND_MESSAGE.set_token('ITEM',l_Req_Material_Tbl(i).concatenated_segments,false);
            l_text := fnd_message.get;
            --Include quantity and date
            FND_MESSAGE.SET_NAME('AHL','AHL_PRD_MAT_QTY_NTF_CHG');
            FND_MESSAGE.set_token('QTY',l_Req_Material_Tbl(i).requested_quantity,false);
            l_body := fnd_message.get;
            l_Req_Material_Tbl(i).notify_text := l_text ||''||l_body
                  || ';For Workorder:'||l_Req_Material_Tbl(i).job_number
                  || ';Required date:'||l_Req_Material_Tbl(i).requested_date;
             END IF;
      END LOOP;
      --
        l_body := null;

        FOR i IN l_Req_Material_Tbl.FIRST..l_Req_Material_Tbl.LAST
        LOOP
            IF l_Req_Material_Tbl(i).notify_text IS NOT NULL THEN
          IF l_body is null then
            l_body := l_Req_Material_Tbl(i).notify_text;
              ELSE
              l_body := l_body ||':' ||l_Req_Material_Tbl(i).notify_text;
            END IF;
              END IF;

        END LOOP;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
          (
                fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Number of records : '||l_Req_Material_Tbl.count
          );
    END IF;

          OPEN CursorNotify(l_object);
              FETCH CursorNotify INTO l_rec;
              CLOSE CursorNotify;
          FND_MESSAGE.SET_NAME('AHL','AHL_PRD_MAT_REQ_NTF_CONTENT');
          l_subject := fnd_message.get;

          l_role_name:=l_rec.approver_name;

          l_return_status := FND_API.G_RET_STS_SUCCESS;

          l_notif_id := WF_NOTIFICATION.Send
                          (  role => l_role_name
                            , msg_type => l_item_type
                            , msg_name => l_message_name
                           );

                          WF_NOTIFICATION.SetAttrText(l_notif_id,
                                       'GEN_MSG_SUBJECT',
                                       l_subject);

                           WF_NOTIFICATION.SetAttrText(l_notif_id,
                                       'GEN_MSG_BODY',
                                       l_body);

                           WF_NOTIFICATION.SetAttrText(l_notif_id,
                                       'GEN_MSG_SEND_TO',
                                       l_role_name);

                           WF_NOTIFICATION.Denormalize_Notification(l_notif_id);
     END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
                  fnd_log.level_procedure,
                  'ahl.plsql.AHL_PP_MATERIALS_PVT.Material_Notification.end',
                  'At the end of PLSQL procedure'
            );
     END IF;


EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Material_Notification;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO MATERIAL_NOTIFICATION;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    ROLLBACK TO Material_Notification;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  G_PKG_NAME,
                            p_procedure_name  =>  'MATERIAL_NOTIFICATION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

 END Material_Notification;

PROCEDURE get_dff_default_values
(
   p_req_material_rec       IN REQ_MATERIAL_REC_TYPE,
   flex_fields_defaults     OUT NOCOPY dff_default_values_type
) IS

flexfield fnd_dflex.dflex_r;
flexinfo  fnd_dflex.dflex_dr;
contexts  fnd_dflex.contexts_dr;
i BINARY_INTEGER;
j  BINARY_INTEGER;
segments  fnd_dflex.segments_dr;


BEGIN
  fnd_dflex.get_flexfield('AHL', 'Material Reqmt Flex Field', flexfield, flexinfo);
  IF(p_req_material_rec.ATTRIBUTE_CATEGORY IS NULL)THEN
    flex_fields_defaults.ATTRIBUTE_CATEGORY := flexinfo.default_context_value;
  ELSIF (p_req_material_rec.ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR)THEN
    flex_fields_defaults.ATTRIBUTE_CATEGORY := NULL;
  ELSE
    flex_fields_defaults.ATTRIBUTE_CATEGORY := p_req_material_rec.ATTRIBUTE_CATEGORY;
  END IF;
  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('flex_fields_defaults.ATTRIBUTE_CATEGORY : ' || flex_fields_defaults.ATTRIBUTE_CATEGORY);
  END IF;
  IF(flex_fields_defaults.ATTRIBUTE_CATEGORY IS NOT NULL)THEN
   fnd_dflex.get_contexts(flexfield, contexts);
   FOR j IN 1 .. contexts.ncontexts LOOP
      IF(contexts.is_enabled(j) AND
          (flex_fields_defaults.ATTRIBUTE_CATEGORY = contexts.context_code(j)
           OR contexts.is_global(j))
      ) THEN
        fnd_dflex.get_segments
        (  fnd_dflex.make_context(flexfield,
          contexts.context_code(j)),
          segments,
          TRUE
        );
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
        END IF;
      END LOOP;
      END IF;
   END LOOP;
  END IF;

END get_dff_default_values;

END AHL_PP_MATERIALS_PVT;

/
