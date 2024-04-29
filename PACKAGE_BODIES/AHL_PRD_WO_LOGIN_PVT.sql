--------------------------------------------------------
--  DDL for Package Body AHL_PRD_WO_LOGIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_WO_LOGIN_PVT" AS
/* $Header: AHLVLGNB.pls 120.8.12010000.3 2009/04/21 01:22:23 sikumar ship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AHL_PRD_WO_Login_PVT';

G_DEBUG_LEVEL       CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_DEBUG_PROC        CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_DEBUG_STMT        CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;

------------------------------
-- Declare Local Procedures --
------------------------------

-- Convert WO Values to IDs.
-- Used by both login and logout procedures.
PROCEDURE ConvertWO_Value_to_IDs (x_return_status       OUT NOCOPY VARCHAR2,
                                  p_employee_num        IN VARCHAR2,
                                  p_workorder_name      IN VARCHAR2,
                                  p_org_code            IN VARCHAR2,
                                  p_x_employee_id       IN OUT NOCOPY NUMBER,
                                  p_x_workorder_id      IN OUT NOCOPY NUMBER,
                                  p_x_operation_seq_num IN OUT NOCOPY NUMBER,
                                  p_x_resource_seq_num  IN OUT NOCOPY NUMBER,
                                  p_x_resource_id       IN OUT NOCOPY NUMBER);

-- Procedure to validate and login user into a workorder.
PROCEDURE Process_WO_Login (x_return_status      OUT NOCOPY VARCHAR2,
                            p_employee_id        IN NUMBER,
                            p_workorder_id       IN NUMBER,
                            p_workorder_name     IN VARCHAR2,
                            p_user_role          IN VARCHAR2);


-- Procedure to validate and login user into a operation.
PROCEDURE Process_OP_Login (x_return_status      OUT NOCOPY VARCHAR2,
                            p_employee_id        IN NUMBER,
                            p_workorder_id       IN NUMBER,
                            p_workorder_name     IN VARCHAR2,
                            p_operation_seq_num  IN NUMBER,
                            p_user_role          IN VARCHAR2);

-- Procedure to validate and login user into a operation-resource.
PROCEDURE Process_RES_Login (x_return_status      OUT NOCOPY VARCHAR2,
                             p_employee_id        IN NUMBER,
                             p_workorder_id       IN NUMBER,
                             p_workorder_name     IN VARCHAR2,
                             p_operation_seq_num  IN NUMBER,
                             p_resource_seq_num   IN NUMBER,
                             p_resource_id        IN NUMBER,
                             p_user_role          IN VARCHAR2);


-- Procedure to validate and logout user from a workorder, operation, operation-resource.
PROCEDURE Process_WO_Logout (x_return_status      OUT NOCOPY VARCHAR2,
                             p_employee_id        IN NUMBER,
                             p_workorder_id       IN NUMBER,
                             p_operation_seq_num  IN NUMBER,
                             p_resource_seq_num   IN NUMBER,
                             p_resource_id        IN NUMBER,
                             p_user_role          IN VARCHAR2);



------------------------------
-- Definition of Procedures --
------------------------------

-- Start of Comments --
--  Procedure name : Workorder_Login
--
--  Parameters  :
--
--
--  Description : This API logs a technician onto a workorder or operation. If the
--                operation sequence number passed to the API is null, then the login
--                is done at the workorder level; if the resource sequence or resource ID is not
--                passed but the workorder and operation is passed, then the login is at operation level.
--                If resource details are passed, then login is at the operation and resource level.
--
PROCEDURE Workorder_Login(p_api_version       IN         NUMBER,
                          p_init_msg_list     IN         VARCHAR2 := FND_API.G_FALSE,
                          p_commit            IN         VARCHAR2 := FND_API.G_FALSE,
                          p_validation_level  IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                          p_module_type       IN         VARCHAR2 := NULL,
                          x_return_status     OUT NOCOPY VARCHAR2,
                          x_msg_count         OUT NOCOPY NUMBER,
                          x_msg_data          OUT NOCOPY VARCHAR2,
                          p_employee_num      IN         NUMBER   := NULL,
                          p_employee_id       IN         NUMBER   := NULL,
                          p_workorder_name    IN         VARCHAR2 := NULL,
                          p_workorder_id      IN         NUMBER   := NULL,
                          p_org_code          IN         VARCHAR2 := NULL,
                          p_operation_seq_num IN         NUMBER   := NULL,
                          p_resource_seq_num  IN         NUMBER   := NULL,
                          p_resource_id       IN         NUMBER   := NULL)

IS


  -- get WO name.
  CURSOR c_wo_name (p_workorder_id IN NUMBER) IS
    SELECT AW.workorder_name
    FROM AHL_WORKORDERS AW
    WHERE AW.WORKORDER_ID = p_workorder_id;

l_api_version        CONSTANT NUMBER       := 1.0;
l_api_name           CONSTANT VARCHAR2(30) := 'Workorder_Login';


l_employee_num       NUMBER;
l_employee_id        NUMBER;
l_workorder_name     ahl_workorders.workorder_name%TYPE;
l_workorder_id       NUMBER;
l_org_code           mtl_parameters.organization_id%TYPE;
l_operation_seq_num  NUMBER;
l_resource_seq_num   NUMBER;
l_resource_id        NUMBER;

l_user_role          VARCHAR2(80);

BEGIN

  -- log debug message.
  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
    fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Login.begin',
                  'At the start of PLSQL procedure' );
  END IF;

  -- Standard call to check for api compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard start of API savepoint
  SAVEPOINT Workorder_Login_Pvt;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Dump Input parameters.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Login.Dump',
                    'p_api_version: ' || p_api_version );

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Login.Dump',
                    'p_init_msg_list:' || p_init_msg_list );

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Login.Dump',
                    'p_commit:' || p_commit );

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Login.Dump',
                    'p_validation_level:' || p_validation_level);

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Login.Dump',
                    'p_module_type:' || p_module_type );

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Login.Dump',
                    'p_employee_num:' || p_employee_num);

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Login.Dump',
                    'p_employee_id:' || p_employee_id);

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Login.Dump',
                    'p_workorder_name:' || p_workorder_name);

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Login.Dump',
                    'p_workorder_id:' || p_workorder_id);

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Login.Dump',
                    'p_org_code:' || p_org_code);

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Login.Dump',
                    'p_operation_seq_num:' || p_operation_seq_num);

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Login.Dump',
                    'p_resource_seq_num:' || p_resource_seq_num);

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Login.Dump',
                    'p_resource_id:' || p_resource_id);
  END IF;

  -- Check if login/logout enabled.
  l_user_role := get_user_role();

  IF (NVL(FND_PROFILE.value('AHL_MANUAL_RES_TXN'),'N') = 'Y') OR
     (l_user_role = AHL_PRD_UTIL_PKG.G_DATA_CLERK) THEN
       FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_AUTOTXN_DSBLD');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Initialize local variables.
  l_employee_num := p_employee_num;
  l_employee_id  := p_employee_id;
  l_workorder_name := p_workorder_name;
  l_workorder_id := p_workorder_id;
  l_org_code := p_org_code;
  l_operation_seq_num := p_operation_seq_num;
  l_resource_seq_num := p_resource_seq_num;
  l_resource_id := p_resource_id;

  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Login',
                    'Before call to ConvertWO_Value_to_IDs' );
  END IF;

  -- Convert Values to IDs.
  ConvertWO_Value_to_IDs (p_employee_num => l_employee_num,
                          p_x_employee_id  => l_employee_id,
                          p_workorder_name => l_workorder_name,
                          p_x_workorder_id   => l_workorder_id,
                          p_org_code   => l_org_code,
                          p_x_operation_seq_num => l_operation_seq_num,
                          p_x_resource_seq_num => l_resource_seq_num,
                          p_x_resource_id  => l_resource_id,
                          x_return_status => x_return_status);

  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Login',
                    'After call to ConvertWO_Value_to_IDs: return status' || x_return_status );
  END IF;

  -- Raise errors if exceptions occur
  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Login',
                    'After call to ConvertWO_Value_to_IDs: return status' || x_return_status );
  END IF;


  -- Validate workorder.
  IF (l_workorder_id IS NULL) THEN
      FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_WO_NULL');
      --FND_MESSAGE.set_token('WO_ID',l_workorder_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  ELSE
      -- get WO number to display error message.
      OPEN c_wo_name(p_workorder_id);
      FETCH c_wo_name INTO l_workorder_name;
      IF (c_wo_name%NOTFOUND) THEN
         CLOSE c_wo_name;
         FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_WO_INVALID');
         FND_MESSAGE.set_token('WO_ID',l_workorder_id);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;

      END IF;

      CLOSE c_wo_name;

  END IF;


  -- If employee ID is NULL then default logged in user.
  IF (p_employee_id IS NULL) THEN
    l_employee_id := AHL_PRD_WO_LOGIN_PVT.Get_Employee_ID();
  ELSE
    l_employee_id := p_employee_id;
  END IF;

  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_RES_Login',
                    'Check Emp and Role:' || l_employee_id || ':' || l_user_role);
  END IF;

  -- process based on input parameters.
  IF (l_resource_id IS NOT NULL OR l_resource_seq_num IS NOT NULL) THEN

       IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
           fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Login',
                        'Processing for Resource login');
       END IF;
       -- Process resource Login
       Process_RES_Login (p_employee_id  => l_employee_id,
                          p_workorder_id   => l_workorder_id,
                          p_workorder_name => l_workorder_name,
                          p_operation_seq_num => l_operation_seq_num,
                          p_resource_seq_num => l_resource_seq_num,
                          p_resource_id  => l_resource_id,
                          p_user_role    => l_user_role,
                          x_return_status => x_return_status);

       IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
            fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Login',
                        'After call to Process_RES_Login: return status' || x_return_status );

       END IF;

  ELSIF (l_operation_seq_num IS NOT NULL) THEN

      -- Process for operation login.

      IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
          fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Login',
                       'Processing for Operation login');
      END IF;

      Process_OP_Login (p_employee_id  => l_employee_id,
                        p_workorder_id   => l_workorder_id,
                        p_workorder_name => l_workorder_name,
                        p_operation_seq_num => l_operation_seq_num,
                        p_user_role    => l_user_role,
                        x_return_status => x_return_status);

      IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
         fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Login',
                      'After call to Process_OP_Login: return status' || x_return_status );
      END IF;


  ELSE
      -- Process for workorder login.

      IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
          fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Login',
                       'Processing for Workorder login');
      END IF;

      Process_WO_Login (p_employee_id  => l_employee_id,
                        p_workorder_id   => l_workorder_id,
                        p_workorder_name => l_workorder_name,
                        p_user_role    => l_user_role,
                        x_return_status => x_return_status);

      IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
          fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Login',
                        'After call to Process_WO_Login: return status' || x_return_status );
      END IF;


  END IF; --l_resource_id IS NOT NULL


  -- Raise errors if exceptions occur
  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
  );

  -- log debug message.
  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
    fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Login.End',
                  'Exiting Procedure' );
  END IF;

--
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Workorder_Login_PVT;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Workorder_Login_PVT;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Workorder_Login_PVT;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Workorder_Login',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);


END Workorder_Login;
---------------------------------------------------------------------------------------------

-- Convert WO Values to IDs.
-- Used by both login and logout procedures.
PROCEDURE ConvertWO_Value_to_IDs (x_return_status       OUT NOCOPY VARCHAR2,
                                  p_employee_num        IN VARCHAR2,
                                  p_workorder_name      IN VARCHAR2,
                                  p_org_code            IN VARCHAR2,
                                  p_x_employee_id       IN OUT NOCOPY NUMBER,
                                  p_x_workorder_id      IN OUT NOCOPY NUMBER,
                                  p_x_operation_seq_num IN OUT NOCOPY NUMBER,
                                  p_x_resource_seq_num  IN OUT NOCOPY NUMBER,
                                  p_x_resource_id       IN OUT NOCOPY NUMBER)

IS

  CURSOR c_get_wo_id (p_workorder_name VARCHAR2,
                      p_org_code       VARCHAR2) IS
  SELECT workorder_id
  FROM AHL_WORKORDERS AWOS, WIP_DISCRETE_JOBS WIP,
       ORG_ORGANIZATION_DEFINITIONS ORG
  WHERE AWOS.WIP_ENTITY_ID = WIP.WIP_ENTITY_ID
    AND AWOS.WORKORDER_NAME = p_workorder_name
    AND WIP.ORGANIZATION_ID = ORG.ORGANIZATION_ID
    AND ORG.ORGANIZATION_CODE = p_org_code;


  l_workorder_id   NUMBER;

BEGIN

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Employee num/ID
  IF (p_x_employee_id IS NULL AND p_employee_num IS NOT NULL) THEN
      p_x_employee_id := AHL_PRD_WO_LOGIN_PVT.Get_Employee_ID(p_employee_num);
  END IF; -- p_x_employee_id IS NULL

  -- Workorder Num/ID
  IF (p_x_workorder_id IS NULL) THEN
     IF (p_workorder_name IS NULL OR p_org_code IS NULL) THEN
           FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_WO_NULL');
           FND_MSG_PUB.ADD;
           x_return_status := FND_API.G_RET_STS_ERROR;
     ELSE
       OPEN c_get_wo_id(p_workorder_name, p_org_code);
       FETCH c_get_wo_id INTO l_workorder_id;
       IF (c_get_wo_id%NOTFOUND) THEN
          FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_WO_INVALID');
          FND_MESSAGE.set_token('WO_NUM', p_workorder_name);
          FND_MESSAGE.set_token('ORG_CODE', p_org_code);
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       ELSE
          p_x_workorder_id := l_workorder_id;
       END IF;
       CLOSE c_get_wo_id;
     END IF; -- p_workorder_name IS NULL

  END IF; -- p_x_workorder_id IS NULL

END ConvertWO_Value_to_IDs;
---------------------------------------------------------------------------------------------
-- Procedure to validate and login user into a operation-resource.
PROCEDURE Process_RES_Login (x_return_status      OUT NOCOPY VARCHAR2,
                            p_employee_id        IN NUMBER,
                            p_workorder_id       IN NUMBER,
                            p_workorder_name     IN VARCHAR2,
                            p_operation_seq_num  IN NUMBER,
                            p_resource_seq_num   IN NUMBER,
                            p_resource_id        IN NUMBER,
                            p_user_role          IN VARCHAR2)

IS

  -- Lock specific WO-operation.
  CURSOR c_lock_wo_oper (p_workorder_id IN NUMBER,
                         p_operation_seq_num IN NUMBER) IS
      SELECT AWO.STATUS_CODE
      FROM AHL_WORKORDER_OPERATIONS AWO
      WHERE AWO.WORKORDER_ID = p_workorder_id
        AND AWO.operation_sequence_num = p_operation_seq_num
      FOR UPDATE OF AWO.object_version_number;

  -- Query to check if an employee is qualified for a resource reqd
  -- for a given operation.
  -- Support for borrowed resources. Bug# 6748783.
  CURSOR c_qualified_req(p_employee_id  IN NUMBER,
                         p_workorder_id IN NUMBER,
                         p_operation_seq_num IN NUMBER,
                         p_resource_id       IN NUMBER,
                         p_resource_seq_num IN NUMBER) IS

    SELECT AOR.OPERATION_RESOURCE_ID, WOR.start_date, WOR.completion_date,
           (select wo1.department_id from wip_operations wo1
            where wo1.wip_entity_id = aw.wip_entity_id
            and wo1.operation_seq_num = p_operation_seq_num) department_id,
           WOR.resource_seq_num
    FROM WIP_OPERATION_RESOURCES WOR,
         AHL_OPERATION_RESOURCES AOR, AHL_WORKORDER_OPERATIONS AWO, AHL_WORKORDERS AW,
         BOM_RESOURCES BRS
    WHERE AW.workorder_id = AWO.workorder_id
      AND WOR.wip_entity_id = AW.wip_entity_id
      AND WOR.RESOURCE_SEQ_NUM = AOR.RESOURCE_SEQUENCE_NUM
      AND WOR.OPERATION_SEQ_NUM = AWO.OPERATION_SEQUENCE_NUM
      AND AWO.operation_sequence_num = p_operation_seq_num
      AND AWO.workorder_operation_id = AOR.workorder_operation_id
      AND WOR.organization_id = BRS.organization_id
      AND WOR.resource_id = AOR.resource_id
      AND WOR.resource_id = BRS.resource_id
      --AND WOR.operation_seq_num = p_operation_seq_num
      AND BRS.resource_type = 2  -- person.
      AND AW.workorder_id = p_workorder_id
      AND WOR.resource_id = nvl(p_resource_id, WOR.resource_id)
      AND WOR.resource_seq_num = nvl(p_resource_seq_num, WOR.resource_seq_num)
      -- qualified.
      AND EXISTS (SELECT 'x'
                  FROM mtl_employees_current_view pf,
                       bom_resource_employees bre,
                       bom_dept_res_instances bdri,
                       wip_operations wo,
                       bom_department_resources bdr
                 WHERE WO.wip_entity_id = AW.wip_entity_id
                   AND WO.operation_seq_num = AWO.operation_sequence_num
                   -- AND WO.department_id = bdri.department_id
                   AND nvl(bdr.share_from_dept_id,WO.department_id) = bdri.department_id
                   AND bdr.department_id = wo.department_id
                   AND bdr.resource_id = WOR.RESOURCE_ID
                   AND WOR.RESOURCE_ID= bdri.resource_id
                   AND bre.instance_id = bdri.instance_id
                   AND bre.resource_id = bdri.resource_id
                   AND bre.organization_id = WOR.organization_id
                   AND bre.person_id = pf.employee_id
                   AND pf.organization_id = bre.organization_id
                   AND bre.person_id = p_employee_id);

  -- Check if assignment exists.
  CURSOR c_assignment_details (p_operation_resource_id IN NUMBER,
                               p_employee_id           IN NUMBER) IS
    SELECT AWAS.Assignment_id, AWAS.object_version_number
    FROM AHL_WORK_ASSIGNMENTS AWAS
    WHERE AWAS.operation_resource_id = p_operation_resource_id
      AND AWAS.employee_id = p_employee_id;

  -- parameters to call Assignment API.
  l_resrc_assign_cre_tbl      AHL_PP_RESRC_ASSIGN_PVT.Resrc_Assign_Tbl_Type;
  l_assignment_rec            AHL_PP_RESRC_ASSIGN_PVT.Resrc_Assign_Rec_Type;
  l_initial_assign_rec        AHL_PP_RESRC_ASSIGN_PVT.Resrc_Assign_Rec_Type;

  l_object_ver_num        NUMBER;
  l_assignment_id         NUMBER;

  l_oper_status  AHL_WORKORDER_OPERATIONS.status_code%TYPE;

  l_operation_resource_id  NUMBER;
  l_sysdate                DATE;
  l_duration               NUMBER;  -- resource reqd duration.

  l_login_allowed_flag  VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

  l_start_date          DATE;
  l_completion_date     DATE;
  l_dept_id             NUMBER;
  l_resource_seq_num    NUMBER;

  i                     NUMBER;
  l_junk                VARCHAR2(1);

BEGIN

  -- log debug message.
  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
    fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_RES_Login.Start',
                  'At the Start of procedure AHL_PRD_WO_LOGIN_PVT.Process_RES_Login');
  END IF;

  -- Dump of input parameters.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_RES_Login.Input_Dump',
                    'p_employee_id:' || p_employee_id);
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_RES_Login.Input_Dump',
                    'p_workorder_id:' || p_workorder_id);
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_RES_Login.Input_Dump',
                    'p_operation_seq_num:' || p_operation_seq_num);
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_RES_Login.Input_Dump',
                    'p_resource_seq_num:' || p_resource_seq_num);
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_RES_Login.Input_Dump',
                    'p_resource_id:' || p_resource_id);
  END IF;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Based on input, lock WO and Operation records.
  IF (p_operation_seq_num IS NOT NULL) THEN
    OPEN c_lock_wo_oper (p_workorder_id, p_operation_seq_num);
    FETCH c_lock_wo_oper INTO l_oper_status;
    IF (c_lock_wo_oper%NOTFOUND) THEN

       CLOSE c_lock_wo_oper;

       -- add error to stack.
       FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_OP_INVALID');
       FND_MESSAGE.SET_TOKEN('OP_NUM', p_operation_seq_num);
       FND_MESSAGE.set_token('WO_NUM' , p_workorder_name);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_lock_wo_oper;

    -- check operation status.
    IF (l_oper_status <> '2') THEN
       -- add error to stack.
       FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_OP_INVALID');
       FND_MESSAGE.SET_TOKEN('OP_NUM', p_operation_seq_num);
       FND_MESSAGE.set_token('WO_NUM' , p_workorder_name);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF; -- p_operation_seq_num IS NOT NULL

  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_RES_Login',
                    'After locking rows');
  END IF;

  -- Call procedure to check if login allowed or not.
  l_login_allowed_flag := Is_Login_Allowed(p_employee_id       => p_employee_id,
                                           p_workorder_id      => p_workorder_id,
                                           p_operation_seq_num => p_operation_seq_num,
                                           p_resource_seq_num  => p_resource_seq_num,
                                           p_resource_id       => p_resource_id,
                                           p_fnd_function_name => p_user_role);

  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_RES_Login',
                    'After call to Is_Login_Allowed procedure:l_login_allowed_flag:' || l_login_allowed_flag);
  END IF;

  -- Error out based on login allowed flag.
  IF (l_login_allowed_flag = FND_API.G_FALSE) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Initialize resource assignment table index.
  i := 1;

  l_initial_assign_rec.login_date := sysdate;

  IF (p_resource_id IS NULL AND p_resource_seq_num IS NULL) THEN
       -- add error to stack.
       FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_RES_NULL');
       FND_MESSAGE.SET_TOKEN('OP_NUM', p_operation_seq_num);
       FND_MESSAGE.set_token('WO_NUM' , p_workorder_name);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
  END IF;


  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_RES_Login',
                    'Start login processing for Operation-Resource');
  END IF;

  -- process for technician and transit tech roles.
  -- Commented out user_role condn to fix bug 5015149.
  --
  --IF (p_user_role = ahl_prd_util_pkg.G_TECH_MYWO) THEN

       -- Create assignment and login record.
       -- login into a specific resource.
       OPEN c_qualified_req(p_employee_id       => p_employee_id,
                            p_workorder_id      => p_workorder_id,
                            p_operation_seq_num => p_operation_seq_num,
                            p_resource_seq_num  => p_resource_seq_num,
                            p_resource_id       => p_resource_id );
       FETCH c_qualified_req INTO l_operation_resource_id, l_start_date, l_completion_date,
                                  l_dept_id, l_resource_seq_num;
       IF (c_qualified_req%FOUND) THEN

           IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
               fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_RES_Login',
                'Processing for..resource:operation:resource_seq:' || p_resource_id || ':' || p_operation_seq_num
                 || ':' || p_resource_seq_num);
           END IF;

           -- check if assignment exists.
           OPEN c_assignment_details(l_operation_resource_id, p_employee_id);
           FETCH c_assignment_details INTO l_assignment_id, l_object_ver_num;
           IF (c_assignment_details%NOTFOUND) THEN

               IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
                  fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_RES_Login',
                      'Assignment not found ..');
               END IF;

                -- Create assignment record.
                l_sysdate  := sysdate;
                l_assignment_rec.workorder_id := p_workorder_id;
                l_assignment_rec.operation_seq_number := p_operation_seq_num;
                l_assignment_rec.resource_seq_number := p_resource_seq_num;
                l_assignment_rec.OPER_RESOURCE_ID := l_operation_resource_id;
                l_assignment_rec.department_id := l_dept_id;
                l_assignment_rec.employee_id := p_employee_id;
                l_assignment_rec.assign_start_date := trunc(l_start_date);
                l_assignment_rec.assign_start_hour := to_number(to_char(l_start_date, 'HH24'));
                l_assignment_rec.assign_start_min := to_number(to_char(l_start_date, 'MI'));
                l_assignment_rec.assign_end_date := trunc(l_completion_date);
                l_assignment_rec.assign_end_hour := to_number(to_char(l_completion_date, 'HH24'));
                l_assignment_rec.assign_end_min := to_number(to_char(l_completion_date,'MI'));

                --l_assignment_rec.login_date := sysdate;
                l_assignment_rec.self_assigned_flag := 'Y';
                l_assignment_rec.operation_flag := 'C';

                l_resrc_assign_cre_tbl(i) := l_assignment_rec;

           ELSE   --c_assignment_details%NOTFOUND

                IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
                     fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_RES_Login',
                         'Assignment found ..');
                END IF;

           END IF; -- c_assignment_details%NOTFOUND
           CLOSE c_assignment_details;

       ELSE   -- c_qualified_req%FOUND

           IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
              fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_RES_Login',
                   'Error - Resource is not found');
           END IF;

           CLOSE c_qualified_req;
           -- add error to stack.
           FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_RES_INVALID');
           FND_MESSAGE.SET_TOKEN('OP_NUM', p_operation_seq_num);
           FND_MESSAGE.set_token('WO_NUM' , p_workorder_name);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;

       END IF; -- c_qualified_req%FOUND
       CLOSE c_qualified_req;

       -- Call Assignment Create API.
       IF (l_resrc_assign_cre_tbl.COUNT > 0) THEN

            IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
                fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_RES_Login',
                     'Before calling Create AHL_PP_RESRC_ASSIGN_PVT.Process_Resrc_Assign:tbl count:' || l_resrc_assign_cre_tbl.count);
            END IF;

            AHL_PP_RESRC_ASSIGN_PVT.Process_Resrc_Assign (
                                      p_api_version        => 1.0,
                                      p_commit             => Fnd_Api.G_FALSE,
                                      p_operation_flag     => 'C',
                                      p_x_resrc_assign_tbl => l_resrc_assign_cre_tbl,
                                      x_return_status    => x_return_status,
                                      x_msg_count        => l_msg_count,
                                      x_msg_data         => l_msg_data);



            IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
                fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_RES_Login',
                     'After calling Create AHL_PP_RESRC_ASSIGN_PVT.Process_Resrc_Assign:x_return_status:' || x_return_status);
            END IF;

            IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;

       END IF; --  l_resrc_assign_cre_tbl.COUNT > 0

--  END IF; -- techinician user role check.

  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_RES_Login',
                     'Inserting into ahl_work_login_times.');
  END IF;

  -- insert login date and time.
  insert into ahl_work_login_times(
                    work_login_time_id,
                    workorder_id,
                    operation_seq_num,
                    resource_seq_num,
                    operation_resource_id,
                    employee_id,
                    login_date,
                    object_version_number,
                    login_level,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_LOGIN)
          values (
                    ahl_work_login_times_s.nextval,
                    p_workorder_id,
                    p_operation_seq_num,
                    p_resource_seq_num,
                    l_operation_resource_id,
                    p_employee_id,
                    sysdate,
                    1,
                    'R',
                    sysdate,
                    fnd_global.user_id,
                    sysdate,
                    fnd_global.user_id,
                    fnd_global.login_id
                 );

  -- log debug message.
  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
    fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_RES_Login.End',
                  'At the End of procedure AHL_PRD_WO_LOGIN_PVT.Process_RES_Login');
  END IF;


END Process_RES_Login;
----------------------------------------------------------------------------------------
-- Procedure to validate and login user into a operation.
PROCEDURE Process_OP_Login (x_return_status      OUT NOCOPY VARCHAR2,
                            p_employee_id        IN NUMBER,
                            p_workorder_id       IN NUMBER,
                            p_workorder_name     IN VARCHAR2,
                            p_operation_seq_num  IN NUMBER,
                            p_user_role          IN VARCHAR2 )

IS


  -- Lock specific WO-operation.
  CURSOR c_lock_wo_oper (p_workorder_id IN NUMBER,
                         p_operation_seq_num IN NUMBER) IS
      SELECT AWO.STATUS_CODE
      FROM AHL_WORKORDER_OPERATIONS AWO
      WHERE AWO.WORKORDER_ID = p_workorder_id
        AND AWO.operation_sequence_num = p_operation_seq_num
      FOR UPDATE OF AWO.object_version_number;

  -- Query to get all qualified resource reqd for an Operation and employee
  -- Fixed query to support borrowed resources.
  CURSOR c_qualified_req_oper(p_employee_id  IN NUMBER,
                              p_workorder_id IN NUMBER,
                              p_operation_seq_num IN NUMBER) IS

    SELECT AOR.OPERATION_RESOURCE_ID, WOR.resource_seq_num, WOR.resource_id,
           WOR.start_date, WOR.completion_date,
           (select wo1.department_id from wip_operations wo1
            where wo1.wip_entity_id = aw.wip_entity_id
                  and wo1.operation_seq_num = p_operation_seq_num) department_id
    FROM WIP_OPERATION_RESOURCES WOR,
         AHL_OPERATION_RESOURCES AOR, AHL_WORKORDER_OPERATIONS AWO, AHL_WORKORDERS AW,
         BOM_RESOURCES BRS
    WHERE AW.workorder_id = AWO.workorder_id
      AND AWO.operation_sequence_num = p_operation_seq_num
      AND WOR.wip_entity_id = AW.wip_entity_id
      AND WOR.RESOURCE_SEQ_NUM = AOR.RESOURCE_SEQUENCE_NUM
      AND WOR.OPERATION_SEQ_NUM = AWO.OPERATION_SEQUENCE_NUM
      AND AWO.workorder_operation_id = AOR.workorder_operation_id
      AND WOR.organization_id = BRS.organization_id
      AND WOR.resource_id = AOR.resource_id
      AND WOR.resource_id = BRS.resource_id
      --AND WOR.operation_seq_num = p_operation_seq_num
      AND BRS.resource_type = 2  -- person.
      AND AW.workorder_id = p_workorder_id
      -- qualified.
      AND EXISTS (SELECT 'x'
                  FROM mtl_employees_current_view pf,
                       bom_resource_employees bre,
                       bom_dept_res_instances bdri,
                       wip_operations wo,
                       bom_department_resources bdr
                 WHERE WO.wip_entity_id = AW.wip_entity_id
                   AND WO.operation_seq_num = AWO.operation_sequence_num
                   --AND WO.department_id = bdri.department_id
                   AND nvl(bdr.share_from_dept_id,WO.department_id) = bdri.department_id
                   AND bdr.department_id = wo.department_id
                   AND bdr.resource_id = WOR.RESOURCE_ID
                   AND WOR.RESOURCE_ID= bdri.resource_id
                   AND bre.instance_id = bdri.instance_id
                   AND bre.resource_id = bdri.resource_id
                   AND bre.organization_id = WOR.organization_id
                   AND bre.person_id = pf.employee_id
                   AND pf.organization_id = bre.organization_id
                   AND bre.person_id = p_employee_id);

  -- Check if assignment exists.
  CURSOR c_assignment_details (p_operation_resource_id IN NUMBER,
                               p_employee_id           IN NUMBER) IS
    SELECT AWAS.Assignment_id, AWAS.object_version_number
    FROM AHL_WORK_ASSIGNMENTS AWAS
    WHERE AWAS.operation_resource_id = p_operation_resource_id
      AND AWAS.employee_id = p_employee_id;


  -- parameters to call Assignment API.
  l_resrc_assign_cre_tbl      AHL_PP_RESRC_ASSIGN_PVT.Resrc_Assign_Tbl_Type;
  l_assignment_rec            AHL_PP_RESRC_ASSIGN_PVT.Resrc_Assign_Rec_Type;
  l_initial_assign_rec        AHL_PP_RESRC_ASSIGN_PVT.Resrc_Assign_Rec_Type;

  l_object_ver_num        NUMBER;
  l_assignment_id         NUMBER;

  l_oper_status  AHL_WORKORDER_OPERATIONS.status_code%TYPE;
  l_wo_status    AHL_WORKORDERS.status_code%TYPE;

  l_operation_resource_id  NUMBER;
  l_sysdate                DATE;
  l_duration               NUMBER;  -- resource reqd duration.

  l_login_allowed_flag  VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

  l_start_date          DATE;
  l_completion_date     DATE;
  l_dept_id             NUMBER;
  l_resource_seq_num    NUMBER;

  i                     NUMBER;

BEGIN

  -- log debug message.
  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
    fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_OP_Login.Start',
                  'At the Start of procedure AHL_PRD_WO_LOGIN_PVT.Process_OP_Login');
  END IF;

  -- Dump of input parameters.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_OP_Login.Input_Dump',
                    'p_employee_id:' || p_employee_id);
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_OP_Login.Input_Dump',
                    'p_workorder_id:' || p_workorder_id);
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_OP_Login.Input_Dump',
                    'p_operation_seq_num:' || p_operation_seq_num);
  END IF;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Based on input, lock WO and Operation records.
  IF (p_operation_seq_num IS NOT NULL) THEN
    OPEN c_lock_wo_oper (p_workorder_id, p_operation_seq_num);
    FETCH c_lock_wo_oper INTO l_oper_status;
    IF (c_lock_wo_oper%NOTFOUND) THEN
       CLOSE c_lock_wo_oper;

       -- add error to stack.
       FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_OP_INVALID');
       FND_MESSAGE.SET_TOKEN('OP_NUM', p_operation_seq_num);
       FND_MESSAGE.set_token('WO_NUM' , p_workorder_name);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_oper_status <> 2) THEN
       CLOSE c_lock_wo_oper;

       -- add error to stack.
       FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_OP_INVALID');
       FND_MESSAGE.SET_TOKEN('OP_NUM', p_operation_seq_num);
       FND_MESSAGE.set_token('WO_NUM' , p_workorder_name);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_lock_wo_oper;

  ELSE

    -- add error to stack.
    FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_OP_NULL');
    FND_MESSAGE.set_token('WO_NUM' , p_workorder_name);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF; -- p_operation_seq_num IS NOT NULL

  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_OP_Login',
                    'After locking rows');
  END IF;

  -- Call procedure to check if login allowed or not.
  l_login_allowed_flag := Is_Login_Allowed(p_employee_id       => p_employee_id,
                                           p_workorder_id      => p_workorder_id,
                                           p_operation_seq_num => p_operation_seq_num,
                                           p_fnd_function_name => p_user_role);

  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_OP_login',
                     'After call to Is_Login_Allowed procedure:l_login_allowed_flag:' || l_login_allowed_flag);
  END IF;

  -- Error out based on login allowed flag.
  IF (l_login_allowed_flag = FND_API.G_FALSE) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Commented out user_role condn to fix bug 5015149.
  --IF (p_user_role = ahl_prd_util_pkg.G_TECH_MYWO) THEN

      -- For creating assignment user needs to be qualified.
      -- Initialize resource assignment table index.
      i := 1;

      l_initial_assign_rec.login_date := sysdate;

      -- initialize login
      -- Create assignments and login records based on login type.
      IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
           fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_OP_Login',
                'Processing for Operation:' || p_operation_seq_num);
      END IF;

      -- Loop through all resources for an operation.
      FOR resrc_oper_rec IN c_qualified_req_oper(p_employee_id, p_workorder_id,
                                                 p_operation_seq_num)
      LOOP
          -- Check if assignment exists.
          OPEN c_assignment_details(resrc_oper_rec.operation_resource_id, p_employee_id);
          FETCH c_assignment_details INTO l_assignment_id, l_object_ver_num;
          IF (c_assignment_details%NOTFOUND) THEN

             IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
                 fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_OP_Login',
                     'Assignment found ..');
             END IF;
              -- Create assignment record.
             l_assignment_rec := l_initial_assign_rec;

             l_assignment_rec.workorder_id := p_workorder_id;
             l_assignment_rec.operation_seq_number := p_operation_seq_num;
             l_assignment_rec.resource_seq_number := resrc_oper_rec.resource_seq_num;
             l_assignment_rec.oper_resource_id := resrc_oper_rec.operation_resource_id;
             l_assignment_rec.department_id := resrc_oper_rec.department_id;
             l_assignment_rec.employee_id := p_employee_id;
             l_assignment_rec.assign_start_date := trunc(resrc_oper_rec.start_date);
             l_assignment_rec.assign_start_hour := to_number(to_char(resrc_oper_rec.start_date, 'HH24'));
             l_assignment_rec.assign_start_min := to_number(to_char(resrc_oper_rec.start_date, 'MI'));
             l_assignment_rec.assign_end_date := trunc(resrc_oper_rec.completion_date);
             l_assignment_rec.assign_end_hour := to_number(to_char(resrc_oper_rec.completion_date, 'HH24'));
             l_assignment_rec.assign_end_min := to_number(to_char(resrc_oper_rec.completion_date,'MI'));

             l_assignment_rec.self_assigned_flag := 'Y';
             l_assignment_rec.operation_flag := 'C';

             l_resrc_assign_cre_tbl(i) := l_assignment_rec;

             i := i + 1;

          ELSE  -- (c_assignment_details%NOTFOUND)

             IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
                fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_OP_Login',
                     'Assignment found..');
             END IF;

          END IF; -- c_assignment_details%NOTFOUND
          CLOSE c_assignment_details;
      END LOOP;  -- resrc_oper_rec.

      -- Call Assignment Create API.
      IF (l_resrc_assign_cre_tbl.COUNT > 0) THEN

            IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
                fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_OP_Login',
                     'Before calling Create AHL_PP_RESRC_ASSIGN_PVT.Process_Resrc_Assign:tbl count:' || l_resrc_assign_cre_tbl.count);
            END IF;

            AHL_PP_RESRC_ASSIGN_PVT.Process_Resrc_Assign (
                                  p_api_version        => 1.0,
                                  p_commit             => Fnd_Api.G_FALSE,
                                  p_operation_flag     => 'C',
                                  p_x_resrc_assign_tbl => l_resrc_assign_cre_tbl,
                                  x_return_status    => x_return_status,
                                  x_msg_count        => l_msg_count,
                                  x_msg_data         => l_msg_data);



            IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
                fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_OP_Login',
                     'After calling Create AHL_PP_RESRC_ASSIGN_PVT.Process_Resrc_Assign:x_return_status:' || x_return_status);
            END IF;

            IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;

      END IF;

--  END IF; -- p_user_role.

  -- insert login date and time.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
         fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_OP_Login',
              'Before inserting into ahl_work_login_times');
  END IF;
  insert into ahl_work_login_times(
          work_login_time_id,
          workorder_id,
          operation_seq_num,
          resource_seq_num,
          operation_resource_id,
          employee_id,
          login_date,
          login_level,
          object_version_number,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN)
  values (
          ahl_work_login_times_s.nextval,
          p_workorder_id,
          p_operation_seq_num,
          null,
          null,
          p_employee_id,
          sysdate,
          1,
          'O',
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          fnd_global.login_id);

  -- log debug message.
  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
    fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_OP_Login.End',
                  'At the End of procedure AHL_PRD_WO_LOGIN_PVT.Process_OP_Login');
  END IF;


END Process_OP_Login;
----------------------------------------------------------------------------------------
-- Procedure to validate and login user into a workorder.
PROCEDURE Process_WO_Login (x_return_status      OUT NOCOPY VARCHAR2,
                            p_employee_id        IN NUMBER,
                            p_workorder_id       IN NUMBER,
                            p_workorder_name     IN VARCHAR2,
                            p_user_role          IN VARCHAR2)
IS


  -- lock workorder.
  CURSOR c_lock_wo (p_workorder_id IN NUMBER) IS
    SELECT AW.STATUS_CODE
    FROM AHL_WORKORDERS AW
    WHERE AW.WORKORDER_ID = p_workorder_id
    FOR UPDATE OF AW.object_version_number;

  -- Lock all operation for a WO.
  CURSOR c_lock_wo_all_ops (p_workorder_id IN NUMBER) IS
      SELECT AWO.STATUS_CODE
      FROM AHL_WORKORDER_OPERATIONS AWO
      WHERE AWO.WORKORDER_ID = p_workorder_id
    FOR UPDATE OF AWO.object_version_number;

  -- Query to get all qualified resources reqd for a WO and employee
  -- across all operations.
  -- Fixed query to support borrowed resources.
  CURSOR c_qualified_req_WO(p_employee_id  IN NUMBER,
                            p_workorder_id IN NUMBER) IS

    SELECT AOR.OPERATION_RESOURCE_ID, WOR.operation_seq_num, WOR.resource_id,
           WOR.resource_seq_num, WOR.start_date, WOR.completion_date,
           (select wo1.department_id from wip_operations wo1
            where wo1.wip_entity_id = aw.wip_entity_id
                  and wo1.operation_seq_num = AWO.operation_sequence_num) department_id
    FROM WIP_OPERATION_RESOURCES WOR,
         AHL_OPERATION_RESOURCES AOR, AHL_WORKORDER_OPERATIONS AWO, AHL_WORKORDERS AW,
         BOM_RESOURCES BRS
    WHERE AW.workorder_id = AWO.workorder_id
      AND WOR.wip_entity_id = AW.wip_entity_id
      AND WOR.RESOURCE_SEQ_NUM = AOR.RESOURCE_SEQUENCE_NUM
      AND WOR.OPERATION_SEQ_NUM = AWO.OPERATION_SEQUENCE_NUM
      AND AWO.workorder_operation_id = AOR.workorder_operation_id
      AND WOR.resource_id = AOR.resource_id
      AND WOR.organization_id = BRS.organization_id
      AND WOR.resource_id = BRS.resource_id
      AND BRS.resource_type = 2  -- person.
      AND AW.workorder_id = p_workorder_id
      -- qualified.
      AND EXISTS (SELECT 'x'
                  FROM mtl_employees_current_view pf,
                       bom_resource_employees bre,
                       bom_dept_res_instances bdri,
                       wip_operations wo,
                       bom_department_resources bdr
                 WHERE WO.wip_entity_id = AW.wip_entity_id
                   AND WO.operation_seq_num = AWO.operation_sequence_num
                   --AND WO.department_id = bdri.department_id
                   AND nvl(bdr.share_from_dept_id,WO.department_id) = bdri.department_id
                   AND bdr.department_id = wo.department_id
                   AND bdr.resource_id = WOR.RESOURCE_ID
                   AND WOR.RESOURCE_ID= bdri.resource_id
                   AND bre.instance_id = bdri.instance_id
                   AND bre.resource_id = bdri.resource_id
                   AND bre.organization_id = WOR.organization_id
                   AND bre.person_id = pf.employee_id
                   AND pf.organization_id = bre.organization_id
                   AND bre.person_id = p_employee_id);

  -- Check if assignment exists.
  CURSOR c_assignment_details (p_operation_resource_id IN NUMBER,
                               p_employee_id           IN NUMBER) IS
    SELECT AWAS.Assignment_id, AWAS.object_version_number
    FROM AHL_WORK_ASSIGNMENTS AWAS
    WHERE AWAS.operation_resource_id = p_operation_resource_id
      AND AWAS.employee_id = p_employee_id;


  -- parameters to call Assignment API.
  l_resrc_assign_cre_tbl      AHL_PP_RESRC_ASSIGN_PVT.Resrc_Assign_Tbl_Type;
  l_assignment_rec            AHL_PP_RESRC_ASSIGN_PVT.Resrc_Assign_Rec_Type;
  l_initial_assign_rec        AHL_PP_RESRC_ASSIGN_PVT.Resrc_Assign_Rec_Type;

  l_object_ver_num        NUMBER;
  l_assignment_id         NUMBER;

  l_wo_status             AHL_WORKORDERS.status_code%TYPE;
  l_oper_status           AHL_WORKORDER_OPERATIONS.status_code%TYPE;

  l_sysdate               DATE;
  l_duration              NUMBER;  -- resource reqd duration.

  l_login_allowed_flag    VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);

  i                       NUMBER;

BEGIN

  -- log debug message.
  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
    fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_WO_Login.Start',
                  'At the Start of procedure AHL_PRD_WO_LOGIN_PVT.Process_WO_Login');
  END IF;

  -- Dump of input parameters.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_WO_Login.Input_Dump',
                    'p_employee_id:' || p_employee_id);
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_WO_Login.Input_Dump',
                    'p_workorder_id:' || p_workorder_id);
  END IF;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Lock WO record.
  OPEN c_lock_wo (p_workorder_id);
  FETCH c_lock_wo INTO l_wo_status;
  IF (c_lock_wo%NOTFOUND) THEN
          FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_WO_INVALID');
      FND_MSG_PUB.ADD;
  END IF;
  CLOSE c_lock_wo;

  -- Lock all operation records.
  OPEN c_lock_wo_all_ops(p_workorder_id);
  FETCH c_lock_wo_all_ops INTO l_oper_status;
  CLOSE c_lock_wo_all_ops;

  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_WO_Login',
                    'After locking rows');
  END IF;

  -- Call procedure to check if login allowed or not.
  l_login_allowed_flag := Is_Login_Allowed(p_employee_id       => p_employee_id,
                                           p_workorder_id      => p_workorder_id,
                                           p_fnd_function_name => p_user_role);

  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_WO_Login',
                    'After call to Is_Login_Allowed procedure:l_login_allowed_flag:' || l_login_allowed_flag);
  END IF;

  -- Error out based on login allowed flag.
  IF (l_login_allowed_flag = FND_API.G_FALSE) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Commented out user_role condn to fix bug 5015149.
  --IF (p_user_role = ahl_prd_util_pkg.G_TECH_MYWO) THEN

      -- to create assignment, user needs to be qualified.
      -- Initialize resource assignment table index.
      i := 1;

      l_initial_assign_rec.login_date := sysdate;

      -- Create assignments and login records.
      IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
         fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_WO_Login',
              'Processing for workorderID:' || p_workorder_id);
      END IF;

      -- login into workorder.
      -- Loop for all operations and all resources for a workorder.
      FOR wo_oper_rec IN c_qualified_req_WO(p_employee_id, p_workorder_id) LOOP
         -- Check if assignment exists.
         OPEN c_assignment_details(wo_oper_rec.operation_resource_id, p_employee_id);
         FETCH c_assignment_details INTO l_assignment_id, l_object_ver_num;
         IF (c_assignment_details%NOTFOUND) THEN

               IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
                  fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_WO_Login',
                       'Assignment not found ..');
               END IF;
                -- Create assignment record.
               l_assignment_rec := l_initial_assign_rec;

               l_assignment_rec.workorder_id := p_workorder_id;
               l_assignment_rec.operation_seq_number := wo_oper_rec.operation_seq_num;
               l_assignment_rec.resource_seq_number := wo_oper_rec.resource_seq_num;
               l_assignment_rec.oper_resource_id := wo_oper_rec.operation_resource_id;
               l_assignment_rec.department_id := wo_oper_rec.department_id;
               l_assignment_rec.employee_id := p_employee_id;
               l_assignment_rec.assign_start_date := trunc(wo_oper_rec.start_date);
               l_assignment_rec.assign_start_hour := to_number(to_char(wo_oper_rec.start_date, 'HH24'));
               l_assignment_rec.assign_start_min := to_number(to_char(wo_oper_rec.start_date, 'MI'));
               l_assignment_rec.assign_end_date := trunc(wo_oper_rec.completion_date);
               l_assignment_rec.assign_end_hour := to_number(to_char(wo_oper_rec.completion_date, 'HH24'));
               l_assignment_rec.assign_end_min := to_number(to_char(wo_oper_rec.completion_date,'MI'));

               l_assignment_rec.self_assigned_flag := 'Y';
               l_assignment_rec.operation_flag := 'C';

               l_resrc_assign_cre_tbl(i) := l_assignment_rec;

               i := i + 1;

         ELSE

               IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
                  fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_WO_Login',
                       'Assignment found ..');
               END IF;

         END IF; -- c_assignment_details%NOTFOUND
         CLOSE c_assignment_details;

      END LOOP;  -- wo_oper_rec

      -- Call Assignment Create API.
      IF (l_resrc_assign_cre_tbl.COUNT > 0) THEN

           IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
               fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_WO_Login',
                    'Before calling Create AHL_PP_RESRC_ASSIGN_PVT.Process_Resrc_Assign:tbl count:' || l_resrc_assign_cre_tbl.count);
           END IF;

           AHL_PP_RESRC_ASSIGN_PVT.Process_Resrc_Assign (
                                 p_api_version        => 1.0,
                                 p_commit             => Fnd_Api.G_FALSE,
                                 p_operation_flag     => 'C',
                                 p_x_resrc_assign_tbl => l_resrc_assign_cre_tbl,
                                 x_return_status    => x_return_status,
                                 x_msg_count        => l_msg_count,
                                 x_msg_data         => l_msg_data);



           IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
               fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_WO_Login',
                    'After calling Create AHL_PP_RESRC_ASSIGN_PVT.Process_Resrc_Assign:x_return_status:' || x_return_status);
           END IF;

           IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;

      END IF; -- l_resrc_assign_cre_tbl.COUNT

--  END IF; -- p_user_role.

  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
     fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_WO_Login',
                 'Before inserting into ahl_work_login_times');
  END IF;

  -- insert login date and time.
  insert into ahl_work_login_times(
              work_login_time_id,
              workorder_id,
              operation_seq_num,
              resource_seq_num,
              operation_resource_id,
              employee_id,
              login_date,
              object_version_number,
              login_level,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_LOGIN)
  values (
              ahl_work_login_times_s.nextval,
              p_workorder_id,
              null,
              null,
              null,
              p_employee_id,
              sysdate,
              1,
              'W',
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              fnd_global.login_id);

  -- log debug message.
  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
    fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_WO_Login.End',
                  'At the End of procedure AHL_PRD_WO_LOGIN_PVT.Process_WO_Login');
  END IF;


END Process_WO_Login;
---------------------------------------------------------------------------------------------

-- Start of Comments --
--  Procedure name : Workorder_Logout
--
--  Parameters  :
--                  p_employee_number     Input Employee Number.
--
--  Description   :
--
--
--
--
PROCEDURE Workorder_Logout( p_api_version        IN         NUMBER,
                            p_init_msg_list      IN         VARCHAR2 := FND_API.G_FALSE,
                            p_commit             IN         VARCHAR2 := FND_API.G_FALSE,
                            p_validation_level   IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                            p_module_type        IN         VARCHAR2 := NULL,
                            x_return_status      OUT NOCOPY VARCHAR2,
                            x_msg_count          OUT NOCOPY NUMBER,
                            x_msg_data           OUT NOCOPY VARCHAR2,
                            p_employee_num       IN         NUMBER   := NULL,
                            p_employee_id        IN         NUMBER   := NULL,
                            p_workorder_name     IN         VARCHAR2 := NULL,
                            p_workorder_id       IN         NUMBER   := NULL,
                            p_org_code           IN         VARCHAR2 := NULL,
                            p_operation_seq_num  IN         NUMBER   := NULL,
                            p_resource_seq_num   IN         NUMBER   := NULL,
                            p_resource_id        IN         NUMBER   := NULL)
IS

  l_api_version        CONSTANT NUMBER       := 1.0;
  l_api_name           CONSTANT VARCHAR2(30) := 'Workorder_Logout';


  l_employee_num       NUMBER;
  l_employee_id        NUMBER;
  l_workorder_name     wip_entities.wip_entity_name%TYPE;
  l_workorder_id       NUMBER;
  l_org_code           mtl_parameters.organization_code%TYPE;
  l_operation_seq_num  wip_operations.operation_seq_num%TYPE;

  l_resource_seq_num   wip_operation_resources.resource_seq_num%TYPE;

  l_resource_id        NUMBER;
  l_user_role          VARCHAR2(80);

BEGIN

  -- log debug message.
  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
    fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Logout.begin',
                  'At the start of PLSQL procedure' );
  END IF;


  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard start of API savepoint
  SAVEPOINT Workorder_Logout_Pvt;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Dump Input parameters.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Logout.Dump',
                    'p_api_version: ' || p_api_version );

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Logout.Dump',
                    'p_init_msg_list:' || p_init_msg_list );

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Logout.Dump',
                    'p_commit:' || p_commit );

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Logout.Dump',
                    'p_validation_level:' || p_validation_level);

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Logout.Dump',
                    'p_module_type:' || p_module_type );

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Logout.Dump',
                    'p_employee_num:' || p_employee_num);

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Logout.Dump',
                    'p_employee_id:' || p_employee_id);

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Logout.Dump',
                    'p_workorder_name:' || p_workorder_name);

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Logout.Dump',
                    'p_workorder_id:' || p_workorder_id);

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Logout.Dump',
                    'p_org_code:' || p_org_code);

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Logout.Dump',
                    'p_operation_seq_num:' || p_operation_seq_num);

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Logout.Dump',
                    'p_resource_seq_num:' || p_resource_seq_num);

      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_Workorder_Logout.Dump',
                    'p_resource_id:' || p_resource_id);
  END IF;


  -- Check if login/logout enabled.
  l_user_role := get_user_role();

  /* THis validation is not needed. Data Clerk can complete WO in which case all users
     should be logged out
  IF (NVL(FND_PROFILE.value('AHL_MANUAL_RES_TXN'),'N') = 'Y') OR
     (l_user_role = AHL_PRD_UTIL_PKG.G_DATA_CLERK) THEN
       FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_AUTOTXN_DSBLD');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
  END IF; */

  -- Initialize local variables.
  l_employee_num := p_employee_num;
  l_employee_id  := p_employee_id;
  l_workorder_name := p_workorder_name;
  l_workorder_id := p_workorder_id;
  l_org_code := p_org_code;
  l_operation_seq_num := p_operation_seq_num;
  l_resource_seq_num := p_resource_seq_num;
  l_resource_id := p_resource_id;

  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Logout',
                    'Before call to ConvertWO_Value_to_IDs' );
  END IF;

  -- Convert Values to IDs.
  ConvertWO_Value_to_IDs (p_employee_num => l_employee_num,
                          p_x_employee_id  => l_employee_id,
                          p_workorder_name => l_workorder_name,
                          p_x_workorder_id   => l_workorder_id,
                          p_org_code   => l_org_code,
                          p_x_operation_seq_num => l_operation_seq_num,
                          p_x_resource_seq_num => l_resource_seq_num,
                          p_x_resource_id  => l_resource_id,
                          x_return_status => x_return_status);

  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Logout',
                    'After call to ConvertWO_Value_to_IDs: return status' || x_return_status );
  END IF;

  -- Raise error if exception occurs
  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- If employee ID and emp num are NULL then default logged in user.
  IF (l_employee_id IS NULL AND l_employee_num IS NULL) THEN
    l_employee_id := AHL_PRD_WO_LOGIN_PVT.Get_Employee_ID();
  END IF;

  -- Check required parameters.
  IF (l_workorder_id IS NULL) THEN
     FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_WO_NULL');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (l_employee_id IS NULL) THEN
     FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_EMPID_NULL');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- debug checkpoint.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_WO_Logout',
                    'Check Emp and Role:' || l_employee_id || ':' || l_user_role);
  END IF;

  -- Process WO Logout
  Process_WO_Logout (p_employee_id  => l_employee_id,
                     p_workorder_id   => l_workorder_id,
                     p_operation_seq_num => l_operation_seq_num,
                     p_resource_seq_num => l_resource_seq_num,
                     p_resource_id  => l_resource_id,
                     p_user_role      => l_user_role,
                     x_return_status => x_return_status);

  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
          fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Logout',
                        'After call to Process_WO_Logout: return status' || x_return_status );
  END IF;


  -- Raise errors if exceptions occur
  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
  );

  -- log debug message.
  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
    fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Logout.End',
                  'Exiting Procedure' );
  END IF;

--
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Workorder_Logout_PVT;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Workorder_Logout_PVT;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Workorder_Logout_PVT;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Workorder_Logout',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);


END Workorder_Logout ;
--------------------------------------------------------------------------------------------
-- Procedure to validate and logout user into a workorder, operation, operation-resource.
PROCEDURE Process_WO_Logout (x_return_status      OUT NOCOPY VARCHAR2,
                             p_employee_id        IN NUMBER,
                             p_workorder_id       IN NUMBER,
                             p_operation_seq_num  IN NUMBER,
                             p_resource_seq_num   IN NUMBER,
                             p_resource_id        IN NUMBER,
                             p_user_role          IN VARCHAR2 )

IS


  -- get login details.
  CURSOR c_emp_login_details(c_employee_id  IN NUMBER,
                             c_workorder_id IN NUMBER) IS
      SELECT WLGN.workorder_id,
             AW.workorder_name,
             AW.wip_entity_id,
             WLGN.operation_seq_num,
             AOR.resource_id,
             WLGN.resource_seq_num,
             WLGN.login_level,
             WLGN.login_date,
             WLGN.work_login_time_id,
             WLGN.object_version_number
      FROM AHL_Operation_Resources AOR, AHL_WORKORDERS AW,
           AHL_WORK_LOGIN_TIMES WLGN
      WHERE WLGN.workorder_id(+) = AW.workorder_id
        AND WLGN.operation_resource_id = AOR.operation_resource_id(+)
        AND WLGN.employee_id(+) = c_employee_id
        AND WLGN.login_date(+) IS NOT NULL
        AND WLGN.logout_date(+) IS NULL --   employee logged in.
        AND AW.workorder_id = c_workorder_id
      FOR UPDATE OF WLGN.logout_date NOWAIT;

  -- lock workorder.
  CURSOR c_lock_wo (p_workorder_id IN NUMBER) IS
    SELECT AW.STATUS_CODE, AW.workorder_name
    FROM AHL_WORKORDERS AW
    WHERE AW.WORKORDER_ID = p_workorder_id
    FOR UPDATE OF AW.object_version_number;

  -- Lock all operations for a WO.
  CURSOR c_lock_wo_all_ops (p_workorder_id IN NUMBER) IS
      SELECT AWO.STATUS_CODE
      FROM AHL_WORKORDER_OPERATIONS AWO
      WHERE AWO.WORKORDER_ID = p_workorder_id
    FOR UPDATE OF AWO.object_version_number;

  -- Lock specific WO-operation.
  CURSOR c_lock_wo_oper (p_workorder_id IN NUMBER,
                         p_operation_seq_num IN NUMBER) IS
      SELECT AWO.STATUS_CODE
      FROM AHL_WORKORDER_OPERATIONS AWO
      WHERE AWO.WORKORDER_ID = p_workorder_id
        AND AWO.operation_sequence_num = p_operation_seq_num
      FOR UPDATE OF AWO.object_version_number;

  -- Query to get all qualified resources reqd for a WO and employee
  -- across all operations.
  -- Adithya added organization_id and department_id to fix bug# 6452479
  -- Support for borrowed resources
  CURSOR c_qualified_req_WO(p_employee_id   IN NUMBER,
                            p_wip_entity_id IN NUMBER) IS
    SELECT WOR.operation_seq_num, WOR.resource_id,
           WOR.resource_seq_num, BRS.unit_of_measure uom_code,
           WO.organization_id, WO.department_id
    FROM wip_operations wo,
         wip_operation_resources WOR,
         bom_resources BRS
    WHERE wo.wip_entity_id = WOR.wip_entity_id
      AND wo.operation_seq_num = WOR.operation_seq_num
      AND WOR.resource_id = BRS.resource_id
      AND BRS.resource_type = 2  -- person.
      AND wo.wip_entity_id = p_wip_entity_id
      AND exists ( SELECT 'x'
                   FROM bom_resource_employees bre,
                        bom_dept_res_instances bdri,
                        bom_department_resources bdr
                   WHERE --WO.department_id = bdri.department_id
                         nvl(bdr.share_from_dept_id, WO.department_id) = bdri.department_id
                     AND bdr.department_id = WO.department_id
                     AND bdr.resource_id = WOR.RESOURCE_ID
                     AND bre.resource_id = WOR.RESOURCE_ID
                     AND bre.instance_id = bdri.instance_id
                     AND bre.resource_id = bdri.resource_id
                     AND bre.person_id = p_employee_id);

  -- Query to get all qualified resources req for an operation and employee
  --Adithya added organization_id and department_id to fix bug# 6452479
  -- Support for borrowed resources. Bug# 6748783.
  CURSOR c_qualified_req_OP(p_employee_id   IN NUMBER,
                            p_wip_entity_id IN NUMBER,
                            p_operation_seq_num IN NUMBER) IS
    SELECT WOR.operation_seq_num, WOR.resource_id,
           WOR.resource_seq_num, BRS.unit_of_measure uom_code,
           WO.organization_id, WO.department_id
    FROM wip_operations wo,
         wip_operation_resources WOR,
         bom_resources BRS
    WHERE wo.wip_entity_id = WOR.wip_entity_id
      AND wo.operation_seq_num = WOR.operation_seq_num
      AND WOR.resource_id = BRS.resource_id
      AND BRS.resource_type = 2  -- person.
      AND wo.wip_entity_id = p_wip_entity_id
      AND wo.operation_seq_num = p_operation_seq_num
      AND exists ( SELECT 'x'
                   FROM bom_resource_employees bre,
                        bom_dept_res_instances bdri,
                        bom_department_resources bdr
                   WHERE --WO.department_id = bdri.department_id
                     nvl(bdr.share_from_dept_id, WO.department_id) = bdri.department_id
                     AND bdr.department_id = WO.department_id
                     AND bdr.resource_id = WOR.RESOURCE_ID
                     AND bre.resource_id = WOR.RESOURCE_ID
                     AND bre.instance_id = bdri.instance_id
                     AND bre.resource_id = bdri.resource_id
                     AND bre.person_id = p_employee_id);

  -- query to get qualified resource req. details for a operation-resrc.
  --Adithya added organization_id and department_id to fix bug# 6452479
  -- Support for borrowed resources. Bug# 6748783.
  CURSOR c_qualified_req_RES(p_employee_id       IN NUMBER,
                             p_wip_entity_id     IN NUMBER,
                             p_operation_seq_num IN NUMBER,
                             p_resource_seq_num  IN NUMBER) IS
    SELECT WOR.operation_seq_num, WOR.resource_id,
           WOR.resource_seq_num, BRS.unit_of_measure uom_code,
           WO.organization_id, WO.department_id
    FROM wip_operations wo,
         wip_operation_resources WOR,
         bom_resources BRS
    WHERE wo.wip_entity_id = WOR.wip_entity_id
      AND wo.operation_seq_num = WOR.operation_seq_num
      AND WOR.resource_id = BRS.resource_id
      AND BRS.resource_type = 2  -- person.
      AND wo.wip_entity_id = p_wip_entity_id
      AND wo.operation_seq_num = p_operation_seq_num
      AND WOR.resource_seq_num = p_resource_seq_num
      AND exists ( SELECT 'x'
                   FROM bom_resource_employees bre,
                        bom_dept_res_instances bdri,
                        bom_department_resources bdr
                   WHERE --WO.department_id = bdri.department_id
                     nvl(bdr.share_from_dept_id, WO.department_id) = bdri.department_id
                     AND bdr.department_id = WO.department_id
                     AND bdr.resource_id = WOR.RESOURCE_ID
                     AND bre.resource_id = WOR.RESOURCE_ID
                     AND bre.instance_id = bdri.instance_id
                     AND bre.resource_id = bdri.resource_id
                     AND bre.person_id = p_employee_id);

  -- Query to get all person resources reqd for a WO
  -- across all operations. (transit tech case).
  CURSOR c_person_req_WO(p_wip_entity_id IN NUMBER) IS
    SELECT WOR.operation_seq_num, WOR.resource_id,
           WOR.resource_seq_num, BRS.unit_of_measure uom_code
    FROM wip_operations wo,
         wip_operation_resources WOR,
         bom_resources BRS
    WHERE wo.wip_entity_id = WOR.wip_entity_id
      AND wo.operation_seq_num = WOR.operation_seq_num
      AND WOR.resource_id = BRS.resource_id
      AND BRS.resource_type = 2  -- person.
      AND wo.wip_entity_id = p_wip_entity_id;

  -- Query to get all person resources req for an operation
  CURSOR c_person_req_OP(p_wip_entity_id     IN NUMBER,
                         p_operation_seq_num IN NUMBER) IS
    SELECT WOR.operation_seq_num, WOR.resource_id,
           WOR.resource_seq_num, BRS.unit_of_measure uom_code
    FROM wip_operations wo,
         wip_operation_resources WOR,
         bom_resources BRS
    WHERE wo.wip_entity_id = WOR.wip_entity_id
      AND wo.operation_seq_num = WOR.operation_seq_num
      AND WOR.resource_id = BRS.resource_id
      AND BRS.resource_type = 2  -- person.
      AND wo.wip_entity_id = p_wip_entity_id
      AND wo.operation_seq_num = p_operation_seq_num;

  -- query to get person resource req. details for a operation-resrc.
  CURSOR c_person_req_RES(p_wip_entity_id     IN NUMBER,
                          p_operation_seq_num IN NUMBER,
                          p_resource_seq_num  IN NUMBER) IS
    SELECT WOR.operation_seq_num, WOR.resource_id,
           WOR.resource_seq_num, BRS.unit_of_measure uom_code
    FROM wip_operations wo,
         wip_operation_resources WOR,
         bom_resources BRS
    WHERE wo.wip_entity_id = WOR.wip_entity_id
      AND wo.operation_seq_num = WOR.operation_seq_num
      AND WOR.resource_id = BRS.resource_id
      AND BRS.resource_type = 2  -- person.
      AND wo.wip_entity_id = p_wip_entity_id
      AND wo.operation_seq_num = p_operation_seq_num
      AND WOR.resource_seq_num = p_resource_seq_num;

/*  -- get resource seq number given resource id.
  CURSOR c_get_resrc_seq(p_wip_entity_id IN NUMBER,
                         p_operation_seq_num  IN NUMBER,
                         p_resource_id        IN NUMBER) IS
    SELECT WOR.resource_seq_num
    FROM   WIP_OPERATION_RESOURCES WOR
    WHERE  WOR.wip_entity_id = p_wip_entity_id
      AND  WOR.operation_seq_num = p_operation_seq_num
      AND  WOR.resource_id = p_resource_id;
*/

  l_wip_entity_id        NUMBER;
  l_login_workorder_id   NUMBER;
  l_resource_id          NUMBER;
  l_operation_seq_num    NUMBER;
  l_resource_seq_num     NUMBER;
  l_workorder_name       ahl_workorders.workorder_name%TYPE;
  l_login_date           DATE;
  l_login_level          ahl_work_login_times.login_level%TYPE;
  l_work_login_time_id   NUMBER;

  i                      NUMBER;
  l_prd_res_txn_tbl      AHL_PRD_RESOURCE_TRANX_PVT.PRD_RESOURCE_TXNS_TBL;
  l_qty                  NUMBER;

  l_return_status        VARCHAR2(1);
  l_msg_data             VARCHAR2(2000);
  l_msg_count            NUMBER;
  l_object_version_number NUMBER;


BEGIN

  -- log debug message.
  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
    fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_WO_Logout.Start',
                  'At the Start of procedure AHL_PRD_WO_LOGIN_PVT.Process_WO_Logout');
  END IF;

  -- Dump of input parameters.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_WO_Logout.Input_Dump',
                     'p_employee_id:' || p_employee_id);
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_WO_Logout.Input_Dump',
                    'p_workorder_id:' || p_workorder_id);
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_WO_Logout.Input_Dump',
                    'p_operation_seq_num:' || p_operation_seq_num);
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_WO_Logout.Input_Dump',
                    'p_resource_seq_num:' || p_resource_seq_num);
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Process_WO_Logout.Input_Dump',
                    'p_resource_id:' || p_resource_id);
  END IF;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- get workorder login details.
  OPEN c_emp_login_details (p_employee_id, p_workorder_id);
  FETCH c_emp_login_details INTO l_login_workorder_id,
                                 l_workorder_name,
                                 l_wip_entity_id,
                                 l_operation_seq_num,
                                 l_resource_id,
                                 l_resource_seq_num,
                                 l_login_level,
                                 l_login_date,
                                 l_work_login_time_id,
                                 l_object_version_number;

  IF (c_emp_login_details%NOTFOUND) THEN
    CLOSE c_emp_login_details;
    FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGNOUT_NOTLOGGEDIN');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Check login WO matches input WO.
  IF (l_login_workorder_id IS NULL) THEN
      -- user is not logged in any workorder.
     FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGNOUT_NOTLOGGEDIN');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_login_workorder_id <> p_workorder_id) THEN
      FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGNOUT_WO_INVALID');
      FND_MESSAGE.set_token('WO_NAME', l_workorder_name);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
          fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Logout',
                       'After check for employee login');
  END IF;

  -- For 'R' and 'O' logins, operation_seq_num is mandatory.
  IF (l_login_level <> 'W' AND p_operation_seq_num IS NULL) THEN
     FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGNOUT_OP_NULL');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  ELSIF (p_operation_seq_num <> l_operation_seq_num) THEN
     FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGNOUT_OP_INVALID');
     FND_MESSAGE.set_token('OP_NUM', p_operation_seq_num);
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
          fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Logout',
                       'After check for operation login');
  END IF;

  -- For 'R' login, resource is mandatory.
  IF (l_login_level = 'R' AND
     p_resource_seq_num IS NULL AND p_resource_id IS NULL) THEN
     FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGNOUT_RES_NULL');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  ELSIF (p_resource_seq_num IS NOT NULL) AND
        (p_resource_seq_num <> nvl(l_resource_seq_num, -1) ) THEN
           FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGNOUT_RES_INVALID');
           FND_MESSAGE.set_token('RES_NUM', p_resource_seq_num);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
  ELSIF (p_resource_id IS NOT NULL) THEN
      IF (p_resource_id <> nvl(l_resource_id,-1)) THEN
         FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGNOUT_RESID_INVALID');
         FND_MESSAGE.set_token('RES_ID', p_resource_id);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
/* jkjain, Bug No 8325834, FP for Bug No 7759348

      ELSE
         -- get resource seq num.
         OPEN c_get_resrc_seq(l_wip_entity_id, l_operation_seq_num, l_resource_id);
         FETCH c_get_resrc_seq INTO l_resource_seq_num;
         IF (c_get_resrc_seq%NOTFOUND) THEN
           CLOSE c_get_resrc_seq;
           FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGNOUT_RES_INVALID');
           FND_MESSAGE.set_token('RES_ID', p_resource_id);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF; -- c_get_resrc_seq
         CLOSE c_get_resrc_seq;
*/
      END IF; -- p_resource_id <> ..
  END IF; -- l_login_level = 'R' ..

  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
          fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Logout',
                       'After check for resource login');
  END IF;

  -- Check Unit locked.
  IF AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => p_workorder_id,
                                     p_ue_id             => null,
                                     p_visit_id          => null,
                                     p_item_instance_id  => null) = FND_API.g_true THEN
     -- Unit is locked, therefore cannot perform resource transactions
     -- and cannot login to the workorder
     FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_UNTLCKD');
     FND_MESSAGE.set_token('WO_NUM' , l_workorder_name);
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
          fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Logout',
                       'After Unit locked check');
  END IF;

  -- Process for posting resource txns.

  -- initialize variables.
  i := 0;

  -- Read user qualified resource requirements to record automatic resource txns.
  -- Operation-resource login case.
  IF (l_login_level = 'R') THEN

     -- debug check point.
     IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
          fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Logout',
                       'processing resource txns for RES login:Emp:WE:OP:RES' || p_employee_id || ':'|| l_wip_entity_id || ':' || l_operation_seq_num || ':' || l_resource_seq_num);
     END IF;

     -- Commented out user_role condn to fix bug 5015149.
     --IF (p_user_role = ahl_prd_util_pkg.G_TECH_MYWO) THEN
          FOR qual_res_rec IN c_qualified_req_RES(p_employee_id, l_wip_entity_id,
                                                  l_operation_seq_num, l_resource_seq_num)
          LOOP
                i := i + 1;

                l_prd_res_txn_tbl(i).workorder_id := p_workorder_id;
                l_prd_res_txn_tbl(i).operation_sequence_num := l_operation_seq_num;
                l_prd_res_txn_tbl(i).resource_sequence_num := l_resource_seq_num;
                l_prd_res_txn_tbl(i).person_id := p_employee_id;
                l_prd_res_txn_tbl(i).qty := 0;
                l_prd_res_txn_tbl(i).uom_code := qual_res_rec.uom_code;
                l_prd_res_txn_tbl(i).resource_id := qual_res_rec.resource_id;
                --l_prd_res_txn_tbl(i).transaction_date := sysdate;
                l_prd_res_txn_tbl(i).end_date := sysdate;
                l_prd_res_txn_tbl(i).DML_operation := 'C';
                --Adithya added to fix bug# 6452479
                l_prd_res_txn_tbl(i).department_id := qual_res_rec.department_id;
                l_prd_res_txn_tbl(i).organization_id := qual_res_rec.organization_id;

          END LOOP; -- qual_res_rec

     /* Commented out to fix bug 5015149.
     ELSE  -- transit tech: apply no qualification.
          FOR person_res_rec IN c_person_req_RES(l_wip_entity_id,
                                                 l_operation_seq_num, l_resource_seq_num)
          LOOP
                i := i + 1;

                l_prd_res_txn_tbl(i).workorder_id := p_workorder_id;
                l_prd_res_txn_tbl(i).operation_sequence_num := l_operation_seq_num;
                l_prd_res_txn_tbl(i).resource_sequence_num := l_resource_seq_num;
                l_prd_res_txn_tbl(i).person_id := p_employee_id;
                l_prd_res_txn_tbl(i).qty := 0;
                l_prd_res_txn_tbl(i).uom_code := person_res_rec.uom_code;
                l_prd_res_txn_tbl(i).resource_id := person_res_rec.resource_id;
                l_prd_res_txn_tbl(i).transaction_date := sysdate;
                l_prd_res_txn_tbl(i).DML_operation := 'C';

         END LOOP;  -- person_res_rec

     END IF; -- l_user_role. */

  END IF;  -- l_login_level = 'R'

  -- Operation login case.
  IF (l_login_level = 'O') THEN

     -- debug check point.
     IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
          fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Logout',
                       'processing resource txns for OP login:Emp:WE:OP:' || p_employee_id || ':'|| l_wip_entity_id || ':' || l_operation_seq_num);
     END IF;

     -- Commented out user_role condn to fix bug 5015149.
     --IF (p_user_role = ahl_prd_util_pkg.G_TECH_MYWO) THEN
          FOR qual_res_rec IN c_qualified_req_OP(p_employee_id, l_wip_entity_id,
                                                 l_operation_seq_num)
          LOOP
                i := i + 1;

                l_prd_res_txn_tbl(i).workorder_id := p_workorder_id;
                l_prd_res_txn_tbl(i).operation_sequence_num := l_operation_seq_num;
                l_prd_res_txn_tbl(i).resource_sequence_num := qual_res_rec.resource_seq_num;
                l_prd_res_txn_tbl(i).person_id := p_employee_id;
                l_prd_res_txn_tbl(i).qty := 0;
                l_prd_res_txn_tbl(i).uom_code := qual_res_rec.uom_code;
                l_prd_res_txn_tbl(i).resource_id := qual_res_rec.resource_id;
                --l_prd_res_txn_tbl(i).transaction_date := sysdate;
                l_prd_res_txn_tbl(i).end_date := sysdate;
                l_prd_res_txn_tbl(i).DML_operation := 'C';
                --Adithya added to fix bug# 6452479
                l_prd_res_txn_tbl(i).department_id := qual_res_rec.department_id;
                l_prd_res_txn_tbl(i).organization_id := qual_res_rec.organization_id;

          END LOOP; -- qual_res_rec

     /* commented out to fix bug 5015149.
     ELSE  -- apply no qual for transit tech.
          FOR person_res_rec IN c_person_req_OP(l_wip_entity_id, l_operation_seq_num)
          LOOP
                i := i + 1;

                l_prd_res_txn_tbl(i).workorder_id := p_workorder_id;
                l_prd_res_txn_tbl(i).operation_sequence_num := l_operation_seq_num;
                l_prd_res_txn_tbl(i).resource_sequence_num := person_res_rec.resource_seq_num;
                l_prd_res_txn_tbl(i).person_id := p_employee_id;
                l_prd_res_txn_tbl(i).qty := 0;
                l_prd_res_txn_tbl(i).uom_code := person_res_rec.uom_code;
                l_prd_res_txn_tbl(i).resource_id := person_res_rec.resource_id;
                l_prd_res_txn_tbl(i).transaction_date := sysdate;
                l_prd_res_txn_tbl(i).DML_operation := 'C';

          END LOOP; -- person_res_rec

     END IF; -- l_user_role. */

  END IF; -- l_login_level = 'O'

  -- Workorder login case.
  IF (l_login_level = 'W') THEN

     -- debug check point.
     IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
          fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Logout',
                       'processing resource txns for WO login:Emp:WE:' || p_employee_id || ':'|| l_wip_entity_id );
     END IF;

     -- Commented out user_role condn to fix bug 5015149.
     --IF (p_user_role = ahl_prd_util_pkg.G_TECH_MYWO) THEN
          FOR qual_res_rec IN c_qualified_req_WO(p_employee_id, l_wip_entity_id)
          LOOP
                i := i + 1;

                l_prd_res_txn_tbl(i).workorder_id := p_workorder_id;
                l_prd_res_txn_tbl(i).operation_sequence_num := qual_res_rec.operation_seq_num;
                l_prd_res_txn_tbl(i).resource_sequence_num := qual_res_rec.resource_seq_num;
                l_prd_res_txn_tbl(i).person_id := p_employee_id;
                l_prd_res_txn_tbl(i).qty := 0;
                l_prd_res_txn_tbl(i).uom_code := qual_res_rec.uom_code;
                l_prd_res_txn_tbl(i).resource_id := qual_res_rec.resource_id;
                --l_prd_res_txn_tbl(i).transaction_date := sysdate;
                l_prd_res_txn_tbl(i).end_date := sysdate;
                l_prd_res_txn_tbl(i).DML_operation := 'C';
                --Adithya added to fix bug# 6452479
                l_prd_res_txn_tbl(i).department_id := qual_res_rec.department_id;
                l_prd_res_txn_tbl(i).organization_id := qual_res_rec.organization_id;

          END LOOP; -- qual_res_rec

     /* commented out to fix bug 5015149.
     ELSE  -- apply no qualification to transit tech.

          FOR person_res_rec IN c_person_req_WO(l_wip_entity_id)
          LOOP
                i := i + 1;

                l_prd_res_txn_tbl(i).workorder_id := p_workorder_id;
                l_prd_res_txn_tbl(i).operation_sequence_num := person_res_rec.operation_seq_num;
                l_prd_res_txn_tbl(i).resource_sequence_num := person_res_rec.resource_seq_num;
                l_prd_res_txn_tbl(i).person_id := p_employee_id;
                l_prd_res_txn_tbl(i).qty := 0;
                l_prd_res_txn_tbl(i).uom_code := person_res_rec.uom_code;
                l_prd_res_txn_tbl(i).resource_id := person_res_rec.resource_id;
                l_prd_res_txn_tbl(i).transaction_date := sysdate;
                l_prd_res_txn_tbl(i).DML_operation := 'C';

          END LOOP; -- person_res_rec

     END IF;  -- l_user_role. */

  END IF; -- l_login_level = 'W'

  -- debug check point.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
       fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Logout',
                    'Count on resource txns table:' || l_prd_res_txn_tbl.count);
  END IF;

  -- Call resource txns api.
  IF (l_prd_res_txn_tbl.COUNT > 0) THEN
       -- Post resource time equally accross all qualifications.
       l_qty := ROUND(((sysdate - l_login_date) * 24) / l_prd_res_txn_tbl.COUNT, 3);

       -- debug check point.
       IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
            fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Logout',
                         'Hours per resource:' || l_qty);
       END IF;

       FOR i IN l_prd_res_txn_tbl.FIRST..l_prd_res_txn_tbl.LAST LOOP
         l_prd_res_txn_tbl(i).qty := l_qty;

         -- debug check point.
         IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
            fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Logout',
                         'Hours per resource:' || l_qty);
         END IF;

       END LOOP;

       AHL_PRD_RESOURCE_TRANX_PVT.Process_Resource_Txns(p_api_version => 1.0,
                                                        p_init_msg_list => FND_API.G_TRUE,
                                                        p_commit => FND_API.G_FALSE,
                                                        x_return_status => l_return_status,
                                                        x_msg_count => l_msg_count,
                                                        x_msg_data => l_msg_data,
                                                        p_x_prd_resrc_txn_tbl => l_prd_res_txn_tbl);

       -- debug check point.
       IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
            fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Workorder_Logout',
                         'After call to resource txns: return status:' || l_return_status);
       END IF;

       -- Raise errors if exceptions occur
       IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

  END IF; -- l_prd_res_txn_tbl.COUNT > 0

  -- update logout time.
  UPDATE ahl_work_login_times
     SET logout_date = sysdate,
         object_version_number = l_object_version_number + 1
  WHERE work_login_time_id = l_work_login_time_id;


END Process_WO_Logout;




-- Start of Comments --
--  Function name : Get_User_Role
--
--  Parameters  :
--                  p_fnd_function_name  Input FND function name.
--
--  Description   : This function is used to retrieve the role associated with the current
--                  user - it could be a Production Tech, Production Data Clerk or
--                  Production Transit Tech.
--

FUNCTION Get_User_Role
RETURN VARCHAR2

IS
  l_user_role  VARCHAR2(30);

BEGIN

   -- log debug message.
   IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
     fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Get_User_Role.Start',
                   'At Start of procedure AHL_PRD_WO_LOGIN_PVT.Get_User_Role');
   END IF;

   IF (FND_FUNCTION.TEST(AHL_PRD_UTIL_PKG.G_TECH_MYWO)) THEN
      -- Technician Role.
      l_user_role := AHL_PRD_UTIL_PKG.G_TECH_MYWO;
   ELSIF (FND_FUNCTION.TEST(AHL_PRD_UTIL_PKG.G_DATA_CLERK)) THEN
      -- Data Clerk Role.
      l_user_role := AHL_PRD_UTIL_PKG.G_DATA_CLERK;
   ELSIF (FND_FUNCTION.TEST(AHL_PRD_UTIL_PKG.G_LINE_TECH)) THEN
      -- Transit Check Role.
      l_user_role := AHL_PRD_UTIL_PKG.G_LINE_TECH;
   END IF;

   -- log debug message.
   IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
     fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Get_User_Role.End',
                   'At End of procedure AHL_PRD_WO_LOGIN_PVT.Get_User_Role');
   END IF;

   RETURN l_user_role;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                   p_procedure_name => 'Get_User_Role',
                                   p_error_text     => SUBSTR(SQLERRM,1,240));
     END IF;
     RETURN NULL;


END Get_User_Role;

--------------------------------------------------------------------------------------------

-- Start of Comments --
--  Function name : Get_Employee_ID
--
--  Parameters  :
--                  p_employee_number     Input Employee Number.
--
--  Description   : This function is used to retrieve the employee ID given an employee number.
--                  If employee number is not passed in, then the logged in user's employee ID
--                  is returned. This function is a helper function for other APIs.
--
--

FUNCTION Get_Employee_ID (p_Employee_Number  IN  VARCHAR2 := NULL)
RETURN VARCHAR2

IS

  -- To get the current logged in user's employee ID.
  CURSOR c_get_current_employee_id (p_user_id IN NUMBER) IS
    SELECT employee_id
    FROM FND_USER
    WHERE USER_ID = p_user_id;

  -- To get the employee ID based on an employee number.
  CURSOR c_get_employee_id (p_employee_number IN VARCHAR2) IS
    SELECT employee_id
    FROM MTL_EMPLOYEES_CURRENT_VIEW
    WHERE employee_num = p_employee_number
      AND rownum < 2;

  l_employee_ID   NUMBER;

BEGIN
   -- Check for NULL value.
   IF (p_employee_number IS NULL) THEN
      OPEN c_get_current_employee_id(FND_GLOBAL.USER_ID);
      FETCH c_get_current_employee_id INTO l_employee_id;
      IF (c_get_current_employee_id%NOTFOUND) THEN
         l_employee_id := NULL;
      END IF;
      CLOSE c_get_current_employee_id;
   ELSE
      -- read employee table to get the ID.
      OPEN c_get_employee_id (p_employee_number);
      FETCH c_get_employee_id INTO l_employee_id;
      IF (c_get_employee_id%NOTFOUND) THEN
         l_employee_id := NULL;
      END IF;
      CLOSE c_get_employee_id;
   END IF;

   RETURN l_employee_id;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                   p_procedure_name => 'Get_Employee_ID',
                                   p_error_text     => SUBSTR(SQLERRM,1,240));
     END IF;
     RETURN NULL;


END Get_Employee_ID;
--------------------------------------------------------------------------------------------

-- Start of Comments --
--  Procedure name : Get_Current_Emp_Login
--
--  Parameters  :
--                  p_employee_id    -  Optional Input Employee Id.
--                  x_return_status  -- Procedure return status.
--                  x_workorder_id   -- Workorder ID employee is logged into.
--                                      only valid id Employee logged into workorder.
--                  x_workorder_number -- Workorder Name.
--                  x_operation_seq_num -- Operation Seq Number
--                                      -- Only valid if Employee logged into an Operation-Resource.
--                  x_resource_id       -- Resource sequence employee is logged into.
--                  x_resource_seq_num  -- Resource Sequence number.
--
--  Description   : This procedure returns the workorder or operation the input employee ID
--                  is currently logged into. If input employee ID is null, then the values are
--                  retrieved for the currently logged in employee.
--


PROCEDURE Get_Current_Emp_Login (x_return_status     OUT NOCOPY VARCHAR2,
                                 x_msg_data          OUT NOCOPY VARCHAR2,
                                 x_msg_count         OUT NOCOPY NUMBER,
                                 p_employee_id       IN NUMBER := NULL,
                                 x_employee_name     OUT NOCOPY VARCHAR2,
                                 x_workorder_id      OUT NOCOPY NUMBER,
                                 x_workorder_number  OUT NOCOPY VARCHAR2,
                                 x_operation_seq_num OUT NOCOPY NUMBER,
                                 x_resource_id       OUT NOCOPY NUMBER,
                                 x_resource_seq_num  OUT NOCOPY NUMBER)

IS

    -- Cursor to check current assignments.
    CURSOR c_emp_login_details(c_employee_id IN NUMBER) IS
      SELECT WLGN.workorder_id,
             AW.workorder_name,
             WLGN.operation_seq_num,
             AOR.resource_id,
             WLGN.resource_seq_num
      FROM AHL_Operation_Resources AOR, AHL_WORKORDERS AW,
           AHL_WORK_LOGIN_TIMES WLGN
      WHERE WLGN.workorder_id = AW.workorder_id
        AND WLGN.operation_resource_id = AOR.operation_resource_id(+)
        AND WLGN.employee_id = c_employee_id
        AND WLGN.logout_date IS NULL;   --   employee logged in.

    -- To get employee name.
    CURSOR get_emp_name (p_employee_id IN NUMBER) IS
      SELECT full_name
      FROM MTL_EMPLOYEES_CURRENT_VIEW
      WHERE employee_id = p_employee_id
        AND rownum < 2;


    l_employee_id        NUMBER;
    l_workorder_id       NUMBER;
    l_operation_seq_num  NUMBER;
    l_resource_id        NUMBER;
    l_count              NUMBER;

    l_resource_seq_num   NUMBER;
    l_workorder_number   ahl_workorders.workorder_name%TYPE;

  BEGIN

    -- log debug message.
    IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Get_Current_Emp_Login.Start',
                    'At Start of procedure AHL_PRD_WO_LOGIN_PVT.Get_Current_Emp_Login');
    END IF;

    -- Dump Input parameters.
    IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Get_Current_Emp_Login.Dump',
                     'p_employee_id: ' || p_employee_id );

    END IF;

    -- Initialize Procedure return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check input parameter for NULL.
    IF (p_employee_id IS NULL) THEN
       l_employee_id := Get_Employee_ID();
    ELSE
       l_employee_id := p_employee_id;
    END IF;

    -- Return error if employee id not found.
    IF (l_employee_id IS NULL) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_PRD_LGN_EMP_NULL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Get login info.
    OPEN c_emp_login_details(l_employee_id);

    FETCH c_emp_login_details INTO x_workorder_id, x_workorder_number,
                                   x_operation_seq_num, x_resource_id,
                                   x_resource_seq_num;
    IF (c_emp_login_details%NOTFOUND) THEN
       -- employee not logged in.
       x_workorder_id := NULL;
       x_workorder_number := NULL;
       x_operation_seq_num := NULL;
       x_resource_id := NULL;
       x_resource_seq_num := NULL;
    END IF; -- c_emp_login_details%NOTFOUND

    CLOSE c_emp_login_details;

    -- get employee name.
    OPEN get_emp_name(l_employee_id);
    FETCH get_emp_name INTO x_employee_name;
    CLOSE get_emp_name;

    -- Dump output parameters.
    IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Get_Current_Emp_Login.Output_Dump',
                     'x_workorder_id:' || x_workorder_id);
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Get_Current_Emp_Login.Output_Dump',
                     'x_workorder_number:' || x_workorder_number);
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Get_Current_Emp_Login.Output_Dump',
                     'x_operation_seq_num:' || x_operation_seq_num);
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Get_Current_Emp_Login.Output_Dump',
                     'x_resource_id:' || x_resource_id);
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Get_Current_Emp_Login.Output_Dump',
                     'x_resource_seq_num:' || x_resource_seq_num);
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Get_Current_Emp_Login.Output_Dump',
                     'x_employee_name:' || x_employee_name);
    END IF;

    -- log debug message.
    IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Get_Current_Emp_Login.End',
                    'At End of procedure AHL_PRD_WO_LOGIN_PVT.Get_Current_Emp_Login');
    END IF;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.count_and_get
          (
              p_count => x_msg_count,
              p_data  => x_msg_data,
              p_encoded => fnd_api.g_false
          );


      WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              fnd_msg_pub.add_exc_msg
              (
                  p_pkg_name       => G_PKG_NAME,
                  p_procedure_name => 'Get_Current_Emp_Login',
                  p_error_text     => SUBSTR(SQLERRM,1,240)
              );
          END IF;
          FND_MSG_PUB.count_and_get
          (
              p_count => x_msg_count,
              p_data  => x_msg_data,
              p_encoded => fnd_api.g_false
          );

  END Get_Current_Emp_Login;

--------------------------------------------------------------------------------------------


-- Start of Comments --
--  Function name : Is_Login_Allowed
--
--  Parameters  :
--                  p_employee_id    --  Optional Input Employee Id.
--                  p_wip_entity_id   --  Mandatory Workorder ID.
--                  p_operation_seq_num -- Mandatory Operation Seq Number
--                  p_resource_seq_num  -- Mandatory Resource ID.
--                  p_fnd_function_name  -- Mandatory fnd_function to identify user role.
--
--  Description   : This function is used to determine if a given technician is
--                  allowed to login to a particular workorder/operation/oper-resource.
--                  User is allowed to login only if value of the profile
--                  'Technician Role: Enable Manual Resource Transactions Mode'
--                  is set to Yes. Login is not allowed for Data Clerk role.
--
--                  This function returns fnd_api.g_false if login is not allowed
--                  and return fnd_api.g_true if login is allowed. Error
--                  messages are added to the message stack.
--
--

FUNCTION Is_Login_Allowed(p_employee_id      IN NUMBER := NULL,
                          p_workorder_id     IN NUMBER,
                          p_operation_seq_num IN NUMBER := NULL,
                          p_resource_seq_num  IN NUMBER := NULL,
                          p_resource_id       IN NUMBER := NULL,
                          p_fnd_function_name IN VARCHAR2)
RETURN VARCHAR2 IS

  -- get WO status.
  CURSOR c_is_wo_valid(p_workorder_id IN NUMBER) IS
    SELECT wo.STATUS_CODE, wo.workorder_name, wo.wip_entity_id, we.organization_id
    FROM AHL_WORKORDERS WO, WIP_ENTITIES WE
    WHERE WO.wip_entity_id = we.wip_entity_id
      AND WORKORDER_ID = p_workorder_id;

  -- validate employee.
  CURSOR c_is_emp_valid (p_employee_id IN NUMBER,
                         p_org_id      IN NUMBER) IS
    SELECT pf.employee_id
    FROM  mtl_employees_current_view pf
    WHERE pf.employee_id = p_employee_id
      AND pf.organization_id = p_org_id;

  /*
  -- Query to check if for a WO and its operations, any requirements exist with no qualification for given employee.
  CURSOR c_unqualified_for_all_ops(p_employee_id   IN NUMBER,
                                   p_wip_entity_id IN NUMBER) IS
    SELECT 'x'
    FROM wip_operations wo
      WHERE wo.wip_entity_id = p_wip_entity_id
      AND not exists ( SELECT 'x'
                       FROM  wip_operation_resources WOR,
                             bom_resources BRS,
                             bom_resource_employees bre,
                             bom_dept_res_instances bdri
                       WHERE wo.operation_seq_num = WOR.operation_seq_num
                         AND WOR.resource_id = BRS.resource_id
                         AND BRS.resource_type = 2  -- person.
                         AND WO.department_id = bdri.department_id
                         AND WOR.RESOURCE_ID= bdri.resource_id
                         AND bre.instance_id = bdri.instance_id
                         AND bre.resource_id = bdri.resource_id
                         AND bre.person_id = p_employee_id);

  */
  -- Query to check if all operations of WO have at least one person resource requirement.
  CURSOR c_check_res_reqd (p_wip_entity_id IN NUMBER) IS
    SELECT 'x'
    FROM WIP_OPERATIONS WO
    WHERE wip_entity_id = p_wip_entity_id
      AND exists ( SELECT 'x'
                   FROM WIP_OPERATION_RESOURCES WOR, BOM_RESOURCES BRS
                   WHERE WOR.wip_entity_id = WO.wip_entity_id
                     AND WOR.operation_seq_num = WO.operation_seq_num
                     AND WOR.resource_id = BRS.resource_id
                     AND BRS.resource_type = 2  -- person.
                     );

  /*
  -- Query to check if employee qualifies for multiple resource requirements within an operation at a WO level.
  CURSOR c_check_res_multiple_wo(p_employee_id   IN NUMBER,
                                 p_wip_entity_id IN NUMBER) IS
    SELECT 'x'
    FROM wip_operations wo,
         wip_operation_resources WOR,
         bom_resources BRS
    WHERE wo.wip_entity_id = WOR.wip_entity_id
      AND wo.operation_seq_num = WOR.operation_seq_num
      AND WOR.resource_id = BRS.resource_id
      AND BRS.resource_type = 2  -- person.
      AND wo.wip_entity_id = p_wip_entity_id
      AND exists ( SELECT 'x'
                   FROM bom_resource_employees bre,
                           bom_dept_res_instances bdri
                   WHERE WO.department_id = bdri.department_id
                     AND WOR.RESOURCE_ID= bdri.resource_id
                     AND bre.instance_id = bdri.instance_id
                     AND bre.resource_id = bdri.resource_id
                     AND bre.person_id = p_employee_id)
    GROUP BY WO.wip_entity_id, WO.Operation_seq_num
    HAVING count(WOR.resource_seq_num) > 1;

  -- Query to check if employee qualifies for multiple resource requirements within an operation.
  CURSOR c_check_res_multiple_op(p_employee_id   IN NUMBER,
                                 p_wip_entity_id IN NUMBER,
                                 p_operation_seq_num IN NUMBER) IS
    SELECT 'x'
    FROM wip_operations wo,
         wip_operation_resources WOR,
         bom_resources BRS
    WHERE wo.wip_entity_id = WOR.wip_entity_id
      AND wo.operation_seq_num = WOR.operation_seq_num
      AND WOR.resource_id = BRS.resource_id
      AND BRS.resource_type = 2  -- person.
      AND wo.wip_entity_id = p_wip_entity_id
      AND wo.operation_seq_num = p_operation_seq_num
      AND exists ( SELECT 'x'
                   FROM bom_resource_employees bre,
                           bom_dept_res_instances bdri
                   WHERE WO.department_id = bdri.department_id
                     AND WOR.RESOURCE_ID= bdri.resource_id
                     AND bre.instance_id = bdri.instance_id
                     AND bre.resource_id = bdri.resource_id
                     AND bre.person_id = p_employee_id)
    GROUP BY WO.wip_entity_id, WO.Operation_seq_num
    HAVING count(WOR.resource_seq_num) > 1;

  */

  -- cursor to validate operation seq.
  -- At least one person resource should exist.
  CURSOR c_is_op_seq_valid(p_workorder_id  IN NUMBER,
                           p_op_seq_num    IN NUMBER,
                           p_wip_entity_id IN NUMBER) IS
  SELECT 'x' -- status_code
  FROM AHL_WORKORDER_OPERATIONS
  WHERE WORKORDER_ID = p_workorder_id
  AND OPERATION_SEQUENCE_NUM = p_op_seq_num
  AND status_code = 2  -- uncomplete
  AND exists ( SELECT 'x'
               FROM wip_operation_resources WOR, bom_resources BRS
               WHERE WOR.wip_entity_id = p_wip_entity_id
                AND WOR.operation_seq_num = p_op_seq_num
                AND WOR.resource_id = BRS.resource_id
                AND BRS.resource_type = 2  -- person.
             );

  -- Query to check if for an operation, given employee is qualified for at least one resource reqd.
  -- Fix for bug# 6748783. Support for borrowed resources.
  CURSOR c_qualified_for_one_res(p_employee_id  IN NUMBER,
                                 p_wip_entity_id IN NUMBER,
                                 p_operation_seq_num  IN NUMBER) IS
    SELECT 'x'
    FROM wip_operations wo
      WHERE wo.wip_entity_id = p_wip_entity_id
      and wo.operation_seq_num = p_operation_seq_num
      AND exists ( SELECT 'x'
                   FROM  wip_operation_resources WOR,
                         bom_resources BRS,
                         bom_resource_employees bre,
                         bom_dept_res_instances bdri,
                         bom_department_resources bdr
                   WHERE WOR.operation_seq_num = wo.operation_seq_num
                     AND WOR.wip_entity_id = wo.wip_entity_id
                     AND WOR.resource_id = BRS.resource_id
                     AND wor.organization_id = brs.organization_id
                     AND BRS.resource_type = 2  -- person.
                     AND brs.resource_id = bre.resource_id
                     AND brs.organization_id = bre.organization_id
                     --AND WO.department_id = bdri.department_id
                     AND nvl(bdr.share_from_dept_id, WO.department_id) = bdri.department_id
                     AND bdr.department_id = WO.department_id
                     AND bdr.resource_id = WOR.RESOURCE_ID
                     AND WOR.RESOURCE_ID= bdri.resource_id
                     AND bre.instance_id = bdri.instance_id
                     AND bre.resource_id = bdri.resource_id
                     AND bre.person_id = p_employee_id);

  -- Query to check if employee does not qualify for a operation-resource req.
  -- Support for borrowed resources. Fix for bug# 6748783
  CURSOR c_qualify_res(p_employee_id  IN NUMBER,
                       p_wip_entity_id IN NUMBER,
                       p_operation_seq_num  IN NUMBER,
                       p_resource_id        IN NUMBER) IS

    SELECT 'x'
    FROM wip_operations wo,
         wip_operation_resources WOR
    WHERE wo.wip_entity_id = WOR.wip_entity_id
      AND wo.operation_seq_num = WOR.operation_seq_num
      AND wo.wip_entity_id = p_wip_entity_id
      AND WOR.operation_seq_num = p_operation_seq_num
      AND WOR.resource_id = p_resource_id
      AND not exists ( SELECT 'x'
                       FROM bom_resource_employees bre,
                            bom_dept_res_instances bdri,
                            bom_department_resources bdr
                       WHERE bre.resource_id = wor.resource_id
                         AND bre.organization_id = wor.organization_id
                         --AND WO.department_id = bdri.department_id
                         AND nvl(bdr.share_from_dept_id, WO.department_id) = bdri.department_id
                         AND bdr.department_id = WO.department_id
                         AND bdr.resource_id = WOR.resource_id
                         AND WOR.RESOURCE_ID= bdri.resource_id
                         AND bre.instance_id = bdri.instance_id
                         AND bre.resource_id = bdri.resource_id
                         AND bre.person_id = p_employee_id);

  -- query to get resource ID id given resource seq num input.
  CURSOR c_get_resrc_id(p_wip_entity_id     IN NUMBER,
                        p_operation_seq_num IN NUMBER,
                        p_resource_seq_num  IN NUMBER) IS
    SELECT resource_id
    FROM WIP_OPERATION_RESOURCES WOR
    WHERE WOR.wip_entity_id = p_wip_entity_id
      AND WOR.operation_seq_num = p_operation_seq_num
      AND WOR.resource_seq_num = p_resource_seq_num;


  -- query to validate resource_id. Resource must be of type 'person'.
  CURSOR c_is_resource_valid(p_resource_id IN NUMBER,
                             p_org_id      IN NUMBER) IS
    SELECT resource_code
    FROM BOM_RESOURCES
    WHERE RESOURCE_ID = p_resource_id
      AND organization_id = p_org_id
      AND resource_type = 2;

  -- query to check if all operations of a WO are uncomplete.
  CURSOR c_workorder_oper(p_workorder_id IN NUMBER) IS
    SELECT 'x'
    FROM AHL_WORKORDER_OPERATIONS
    WHERE workorder_id = p_workorder_id
      AND STATUS_CODE = '1' -- complete.
      AND rownum < 2;

  -- query to get all operations for a workorder.
  CURSOR c_get_workorder_oper (p_wip_entity_id IN NUMBER) IS
    SELECT operation_seq_num
    FROM WIP_OPERATIONS
    WHERE wip_entity_id = p_wip_entity_id;

  l_employee_id    NUMBER;
  l_wo_status      AHL_WORKORDERS.status_code%TYPE;
  l_wo_name        AHL_WORKORDERS.workorder_name%TYPE;
  l_wip_entity_id  NUMBER;
  l_org_id         NUMBER;

  --l_oper_status  AHL_WORKORDER_OPERATIONS.status_code%TYPE;
  l_resource_code BOM_RESOURCES.resource_code%TYPE;

  l_junk         VARCHAR2(1);
  l_return_status  VARCHAR2(1);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);

  l_login_workorder_id  NUMBER;
  l_login_op_seq_num    NUMBER;
  l_login_resource_id   NUMBER;
  l_login_resrc_seq_num NUMBER;
  l_login_wo_name       AHL_WORKORDERS.workorder_name%TYPE;
  l_resource_id         NUMBER;
  l_employee_name       per_people_f.full_name%TYPE;

  l_fnd_function_name   VARCHAR2(100);

BEGIN

  -- log debug message.
  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
     fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Is_Login_Allowed.Start',
                   'At Start of procedure AHL_PRD_WO_LOGIN_PVT.Is_Login_Allowed');
  END IF;

  -- Dump Input parameters.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Is_Login_Allowed.Input_Dump',
                     'p_employee_id:' || p_employee_id);
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Is_Login_Allowed.Input_Dump',
                     'p_workorder_id:' || p_workorder_id);
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Is_Login_Allowed.Input_Dump',
                     'p_operation_seq_num:' || p_operation_seq_num);
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Is_Login_Allowed.Input_Dump',
                     'p_resource_seq_num:' || p_resource_seq_num);
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Is_Login_Allowed.Input_Dump',
                     'p_resource_id:' || p_resource_id);
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Is_Login_Allowed.Input_Dump',
                     'p_fnd_function_name:' || p_fnd_function_name);

  END IF;

  -- Check if login enabled.
  IF (NVL(FND_PROFILE.value('AHL_PRD_MANUAL_RES_TXN'),'N') = 'Y') OR
     (l_fnd_function_name = AHL_PRD_UTIL_PKG.G_DATA_CLERK) THEN
       FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_AUTOTXN_DSBLD');
       FND_MSG_PUB.ADD;
       Return FND_API.G_FALSE;
  END IF;

  -- Debug Checkpoint.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Is_Login_Allowed',
                     'After Login enabled check');
  END IF;

  -- Check required parameters.
  IF p_workorder_id IS NULL THEN
     FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_WO_NULL');
     FND_MSG_PUB.ADD;
     Return FND_API.G_FALSE;
  END IF;

  -- Debug Checkpoint.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Is_Login_Allowed',
                     'After required parameters check');
  END IF;

  -- Validate Workorder.
  OPEN c_is_wo_valid (p_workorder_id);
  FETCH c_is_wo_valid INTO l_wo_status, l_wo_name, l_wip_entity_id, l_org_id;
  IF c_is_wo_valid%NOTFOUND THEN
        CLOSE c_is_wo_valid;
        FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_WO_INVALID');
        FND_MSG_PUB.ADD;
        RETURN FND_API.G_FALSE;
  END IF;
  CLOSE c_is_wo_valid;

  -- Validate WO status.
  IF l_wo_status in ('1','6','7','22','12','4','5') THEN
    FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_WOSTS_INVLD');
    FND_MESSAGE.set_token('WO_NUM' , l_wo_name);
    FND_MSG_PUB.ADD;
    RETURN FND_API.G_FALSE;
  END IF;

  -- Debug Checkpoint.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Is_Login_Allowed',
                     'After validate workorder');
  END IF;

  -- Default employee if input is null.
  IF (p_employee_id IS NULL) THEN
    l_employee_id := Get_Employee_ID();
  ELSE
    -- validate employee_id.
    OPEN c_is_emp_valid(p_employee_id, l_org_id);
    FETCH c_is_emp_valid INTO l_employee_id;
    IF (c_is_emp_valid%NOTFOUND) THEN
      CLOSE c_is_emp_valid;
      FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_EMPID_INVALID');
      FND_MESSAGE.set_token('EMP_ID' , p_employee_id);
      FND_MSG_PUB.ADD;
      RETURN FND_API.G_FALSE;
    END IF;
    CLOSE c_is_emp_valid;
  END IF;

  -- Debug Checkpoint.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Is_Login_Allowed',
                     'After validating workorder and employee');
  END IF;

  -- Check if user already logged in.
  AHL_PRD_WO_LOGIN_PVT.Get_Current_Emp_Login (
              p_employee_id  => l_employee_id,
              x_return_status => l_return_status,
              x_msg_count     => l_msg_count,
              x_msg_data      => l_msg_data,
              x_workorder_id  => l_login_workorder_id,
              x_workorder_number => l_login_wo_name,
              x_operation_seq_num => l_login_op_seq_num,
              x_resource_id       => l_login_resource_id,
              x_resource_seq_num  => l_login_resrc_seq_num,
              x_employee_name     => l_employee_name);

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Check for login WO. If user already logged in, then do not allow login into another WO.
  IF (l_login_workorder_id IS NOT NULL) THEN
     FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_USER_LOGGED_IN');
     FND_MSG_PUB.ADD;
     RETURN FND_API.G_FALSE;
  END IF;

  -- Debug Checkpoint.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Is_Login_Allowed',
                     'After login check successful');
  END IF;

  -- Check Unit locked.
  IF AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => p_workorder_id,
                                     p_ue_id             => null,
                                     p_visit_id          => null,
                                     p_item_instance_id  => null) = FND_API.g_true THEN
     -- Unit is locked, therefore cannot perform resource transactions
     -- and hence cannot login to the workorder
     FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_UNTLCKD');
     FND_MESSAGE.set_token('WO_NUM' , l_wo_name);
     FND_MSG_PUB.ADD;
     RETURN FND_API.G_FALSE;
  END IF;

  IF (p_fnd_function_name IS NULL) THEN
     l_fnd_function_name := get_user_role();
  ELSE
     l_fnd_function_name := p_fnd_function_name;
  END IF;

  IF (l_fnd_function_name IS NULL) THEN
     FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_FUNC_NULL');
     FND_MSG_PUB.ADD;
     Return FND_API.G_FALSE;
  END IF;

  -- Debug Checkpoint.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Is_Login_Allowed',
                     'After unit lock check, user role check.. starting qualification checks for function:' ||
                      l_fnd_function_name);
  END IF;

  -- validate login into workorder/operation/operation-resource.
  IF (p_operation_seq_num IS NULL) THEN

      -- Debug Checkpoint.
      IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
          fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Is_Login_Allowed',
                         'Workorder Login validations');
      END IF;

      -- validate if any operation is complete.
      OPEN c_workorder_oper(p_workorder_id);
      FETCH c_workorder_oper INTO l_junk;
       IF (c_workorder_oper%FOUND) THEN
          CLOSE c_workorder_oper;
          FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_WOOPS_COMPLETE');
          FND_MESSAGE.set_token('WO_NUM' , l_wo_name);
          FND_MSG_PUB.ADD;
          RETURN FND_API.G_FALSE;
       END IF;
      CLOSE c_workorder_oper;

      -- validate WO has at least one 'person' resource reqmt.
      OPEN c_check_res_reqd(l_wip_entity_id);
      FETCH c_check_res_reqd INTO l_junk;
        IF c_check_res_reqd%NOTFOUND THEN
           -- Login at the workorder level will be disabled.
           CLOSE c_check_res_reqd;
           FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_WO_NO_RESREQ');
           FND_MESSAGE.set_token('WO_NUM' , l_wo_name);
           FND_MSG_PUB.ADD;
           RETURN FND_API.G_FALSE;
        END IF; -- c_check_res_reqd.
      CLOSE c_check_res_reqd;

      -- Validate qualification to login into a WO in Technician case.
      -- Commented l_fnd_function_name validation to fix bug# 5015149.
      -- IF (l_fnd_function_name = AHL_PRD_UTIL_PKG.G_TECH_MYWO) THEN
          -- validate user qualifies for at least one resource requirement within each operation.
          FOR operation_rec IN c_get_workorder_oper(l_wip_entity_id) LOOP
             OPEN c_qualified_for_one_res(l_employee_id, l_wip_entity_id, operation_rec.operation_seq_num);
             FETCH c_qualified_for_one_res INTO l_junk;
             IF c_qualified_for_one_res%NOTFOUND THEN
                CLOSE c_qualified_for_one_res;
                FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_WOOPS_NOTQUAL');
                FND_MESSAGE.set_token('WO_NUM' , l_wo_name);
                FND_MSG_PUB.ADD;
                RETURN FND_API.G_FALSE;
             END IF; -- c_qualified_for_one_ops
             CLOSE c_qualified_for_one_res;
          END LOOP; -- operation_rec
      -- END IF; -- l_fnd_function_name = AHL_PRD_UTIL_PKG.G_TECH_MYWO

      /*
      -- If user qualifies for multiple resource requirements within the same operation and
      -- profile 'AHL_ALLOW_MULTI_RESRC_LOGIN' = 'Y then do not allow WO login.
      IF nvl(fnd_profile.value('AHL_ALLOW_MULTI_RESRC_LOGIN'), 'N') = 'Y' THEN
         OPEN c_check_res_multiple_wo(l_employee_id, l_wip_entity_id);
         FETCH c_check_res_multiple_wo INTO l_junk;
         IF (c_check_res_multiple_wo%FOUND) THEN
           -- disable login at WO level.
           CLOSE c_check_res_multiple_wo;
           FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_MULTI_RES_WO');
           FND_MESSAGE.set_token('WO_NUM' , l_wo_name);
           FND_MSG_PUB.ADD;
           RETURN FND_API.G_FALSE;
         END IF;
         CLOSE c_check_res_multiple_wo;
      END IF;
      */

  END IF;  -- operation_seq_num IS NULL

  IF (p_operation_seq_num IS NOT NULL) THEN

      -- Debug Checkpoint.
      IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
          fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Is_Login_Allowed',
                         'Starting Workorder-Operation status validations');
      END IF;

      -- Validate operation seq num.
      -- If operation has no person resource requirements, user cannot login into operation.
      -- operation status should be uncomplete.
      OPEN c_is_op_seq_valid (p_workorder_id, p_operation_seq_num, l_wip_entity_id);
      FETCH c_is_op_seq_valid INTO l_junk;
      IF c_is_op_seq_valid%NOTFOUND THEN
         CLOSE c_is_op_seq_valid;
         FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_OP_INVALID');
         FND_MESSAGE.SET_TOKEN('OP_NUM', p_operation_seq_num);
         FND_MESSAGE.set_token('WO_NUM' , l_wo_name);
         FND_MSG_PUB.ADD;
         RETURN FND_API.G_FALSE;
      END IF; -- c_is_op_seq_valid.
      CLOSE c_is_op_seq_valid;

      -- Check login into Operation or Operation+resource.
      IF (p_resource_id IS NULL AND p_resource_seq_num IS NULL) THEN

          -- Login into operation only.

          -- Debug Checkpoint.
          IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
              fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Is_Login_Allowed',
                             'Workorder-Operation Login qualification validations');
          END IF;


          -- Validate qualification to login into a Operation in Technician case.
          -- Commented l_fnd_function_name validation to fix bug# 5015149.
          -- IF (l_fnd_function_name = AHL_PRD_UTIL_PKG.G_TECH_MYWO) THEN
              -- validate user qualifies for at least one resource requirement for the operation.
              OPEN c_qualified_for_one_res(l_employee_id, l_wip_entity_id, p_operation_seq_num);
              FETCH c_qualified_for_one_res INTO l_junk;
              IF (c_qualified_for_one_res%NOTFOUND) THEN
                 CLOSE c_qualified_for_one_res;
                 FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_OP_NOT_QUAL');
                 FND_MESSAGE.SET_TOKEN('OP_NUM', p_operation_seq_num);
                 FND_MESSAGE.set_token('WO_NUM' , l_wo_name);
                 FND_MSG_PUB.ADD;
                 RETURN FND_API.G_FALSE;
              END IF; -- c_qualified_for_one_res
              CLOSE c_qualified_for_one_res;
          -- END IF; -- l_fnd_function_name = AHL_PRD_UTIL_PKG.G_TECH_MYWO

          /*
          -- If user qualifies for multiple resource requirements within the same operation and
          -- profile 'AHL_ALLOW_MULTI_RESRC_LOGIN' = 'Y then do not allow WO-OP login.
          IF nvl(fnd_profile.value('AHL_ALLOW_MULTI_RESRC_LOGIN'), 'N') = 'Y' THEN
             OPEN c_check_res_multiple_op(l_employee_id, l_wip_entity_id, p_operation_seq_num);
             FETCH c_check_res_multiple_op INTO l_junk;
             IF (c_check_res_multiple_op%FOUND) THEN
                -- disable login at WO level.
                CLOSE c_check_res_multiple_op;
                FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_MULTI_RES_OP');
                FND_MESSAGE.set_token('OP_NUM' , p_operation_seq_num);
                FND_MSG_PUB.ADD;
                RETURN FND_API.G_FALSE;
             END IF;
             CLOSE c_check_res_multiple_op;
          END IF;
          */

      ELSE  -- login into operation + resource.

          -- Debug Checkpoint.
          IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
              fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Is_Login_Allowed',
                             'Starting Workorder-Operation-Resource validations');
          END IF;

          -- Get resource ID if resource seq num is input and resource_id is NULL.
          IF (p_resource_id IS NULL AND p_resource_seq_num IS NOT NULL) THEN
              OPEN c_get_resrc_id(l_wip_entity_id, p_operation_seq_num, p_resource_seq_num);
              FETCH c_get_resrc_id INTO l_resource_id;
              IF (c_get_resrc_id%NOTFOUND) THEN
                CLOSE c_get_resrc_id;
              FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_RESSEQ_INVALID');
              FND_MESSAGE.SET_TOKEN('OP_NUM', p_operation_seq_num);
              FND_MESSAGE.set_token('WO_NUM' , l_wo_name);
              FND_MESSAGE.set_token('RES_NAME' ,p_resource_seq_num);
              FND_MSG_PUB.ADD;
              RETURN FND_API.G_FALSE;
              END IF;
              CLOSE c_get_resrc_id;
          ELSE
              l_resource_id := p_resource_id;
          END IF; -- p_resource_id IS NULL AND ...

          -- Validate Resource ID.
          OPEN c_is_resource_valid(l_resource_id, l_org_id);
          FETCH c_is_resource_valid INTO l_resource_code;
          IF (c_is_resource_valid%NOTFOUND) THEN
            CLOSE c_is_resource_valid;
            FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_RESID_INVALID');
            FND_MESSAGE.SET_TOKEN('OP_NUM', p_operation_seq_num);
            FND_MESSAGE.set_token('WO_NUM' , l_wo_name);
            FND_MESSAGE.set_token('RES_ID' , l_resource_id);
            FND_MSG_PUB.ADD;
            RETURN FND_API.G_FALSE;
          END IF; -- c_is_resource_valid
          CLOSE c_is_resource_valid;

          -- Validate qualification in case of technician.
          -- Commented l_fnd_function_name validation to fix bug# 5015149.
          -- IF (l_fnd_function_name = AHL_PRD_UTIL_PKG.G_TECH_MYWO) THEN
              OPEN c_qualify_res(l_employee_id, l_wip_entity_id, p_operation_seq_num,
                                 l_resource_id);
              FETCH c_qualify_res INTO l_junk;
              IF (c_qualify_res%FOUND) THEN
                 CLOSE c_qualify_res;
                 FND_MESSAGE.set_name('AHL', 'AHL_PRD_LGN_OP_NOTQUAL');
                 FND_MESSAGE.SET_TOKEN('OP_NUM', p_operation_seq_num);
                 FND_MESSAGE.set_token('WO_NUM' , l_wo_name);
                 FND_MESSAGE.set_token('RES_NUM', l_resource_code);
                 FND_MSG_PUB.ADD;
                 RETURN FND_API.G_FALSE;
              END IF;
              CLOSE c_qualify_res;
          -- END IF; -- l_fnd_function_name = AHL_PRD_UTIL_PKG.G_TECH_MYWO

      END IF; -- p_resource_id IS NULL

  END IF; -- operation_seq_num is not null.

  -- Debug Checkpoint.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Is_Login_Allowed',
                     'Successfully completed all qualification validations ...');
  END IF;

  -- log debug message.
  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
     fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.Is_Login_Allowed.End',
                   'At End of procedure AHL_PRD_WO_LOGIN_PVT.Is_Login_Allowed');
  END IF;

  -- Set login allowed flag.
  RETURN FND_API.G_TRUE;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       --x_return_status := FND_API.G_RET_STS_ERROR;

        RETURN FND_API.G_FALSE;

    WHEN OTHERS THEN
        --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            fnd_msg_pub.add_exc_msg
            (
                p_pkg_name       => G_PKG_NAME,
                p_procedure_name => 'Is_Login_Allowed',
                p_error_text     => SUBSTR(SQLERRM,1,240)
            );
        END IF;
        RETURN FND_API.G_FALSE;

END Is_Login_Allowed;


----------------------------------------------------------------------------------------------------
--Wrapper procedure used by Technician workbench, Transit Technician and Data Clerk Search Wo UIs
--This procedure returns whether login is allowed for all workorder_ids passed.
----------------------------------------------------------------------------------------------------
PROCEDURE get_wo_login_info(p_function_name		IN VARCHAR2,
                            p_employee_id	 	IN NUMBER,
                            p_x_wos			IN OUT NOCOPY	WO_TBL_TYPE)
IS

BEGIN


   -- log debug message.
   IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
     fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.get_wo_login_info.Start',
                   'At Start of procedure AHL_PRD_WO_LOGIN_PVT.get_wo_login_info');
   END IF;

   IF p_x_wos.COUNT > 0 THEN
      FOR i IN p_x_wos.FIRST..p_x_wos.LAST
      LOOP
	p_x_wos(i).is_login_allowed := Is_Login_Allowed(
					p_employee_id        =>	p_employee_id,
					p_workorder_id       =>	p_x_wos(i).workorder_id,
					p_fnd_function_name  =>	p_function_name
					);
      END LOOP;
   END IF;

  -- log debug message.
  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
     fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.get_wo_login_info.End',
                   'At End of procedure AHL_PRD_WO_LOGIN_PVT.get_wo_login_info');
  END IF;

END get_wo_login_info;

----------------------------------------------------------------------------------------------------
--Wrapper procedure used by Technician workbench, Transit Technician and Data Clerk Search Wo UIs
--This procedure returns whether login is allowed for all all operations of a workorder passed.
----------------------------------------------------------------------------------------------------
PROCEDURE get_op_res_login_info(p_workorder_id		IN NUMBER,
		                p_employee_id		IN NUMBER,
		                p_function_name		IN VARCHAR2,
		                p_x_op_res		IN OUT NOCOPY	OP_RES_TBL_TYPE)
IS
BEGIN

   -- log debug message.
   IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.get_op_res_login_info.Start',
                    'At Start of procedure AHL_PRD_WO_LOGIN_PVT.get_op_res_login_info');
   END IF;

   IF p_x_op_res.COUNT > 0 AND p_workorder_id IS NOT NULL
   THEN
	FOR i IN p_x_op_res.FIRST..p_x_op_res.LAST
	LOOP
		p_x_op_res(i).is_login_allowed := Is_Login_Allowed(
	 						p_employee_id		=>	p_employee_id,
							p_workorder_id		=>	p_workorder_id,
							p_operation_seq_num	=>	p_x_op_res(i).operation_seq_num,
							p_resource_id		=>	p_x_op_res(i).resource_id,
							p_fnd_function_name		=>	p_function_name
							);
	END LOOP;
   END IF;

   -- log debug message.
   IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PVT.get_op_res_login_info.End',
                   'At End of procedure AHL_PRD_WO_LOGIN_PVT.get_op_res_login_info');
   END IF;

END get_op_res_login_info;

---------------------------------------------------------------------------------------------

-- Start of Comments --
--  Function name : Is_Login_Enabled
--
--  Parameters  :
--                  p_employee_id    --  Optional Input Employee Id.
--                  p_wip_entity_id   --  Mandatory Workorder ID.
--                  p_operation_seq_num -- Mandatory Operation Seq Number
--                  p_resource_seq_num  -- Mandatory Resource ID.
--                  p_fnd_function_name  -- fnd_function to identify user role.
--
--  Description   : This function returns whether user is allowed to login into a
--                  wrokorder/operation-resource
--


FUNCTION Is_Login_Enabled(p_employee_id       IN NUMBER := NULL,
                          p_workorder_id      IN NUMBER,
                          p_operation_seq_num IN NUMBER := NULL,
                          p_resource_seq_num  IN NUMBER := NULL,
                          p_resource_id       IN NUMBER := NULL,
                          p_fnd_function_name IN VARCHAR2 :=NULL) RETURN VARCHAR2 IS

  -- get WO status.
  CURSOR c_is_wo_valid(p_workorder_id IN NUMBER) IS
    SELECT wo.STATUS_CODE, wo.workorder_name, wo.wip_entity_id, we.organization_id
    FROM AHL_WORKORDERS WO, WIP_ENTITIES WE
    WHERE WO.wip_entity_id = we.wip_entity_id
      AND WORKORDER_ID = p_workorder_id;


  -- Query to check if all operations of WO have at least one person resource requirement.
  CURSOR c_check_res_reqd (p_wip_entity_id IN NUMBER) IS
    SELECT 'x'
    FROM WIP_OPERATIONS WO
    WHERE wip_entity_id = p_wip_entity_id
      AND exists ( SELECT 'x'
                   FROM WIP_OPERATION_RESOURCES WOR, BOM_RESOURCES BRS
                   WHERE WOR.wip_entity_id = WO.wip_entity_id
                     AND WOR.operation_seq_num = WO.operation_seq_num
                     AND WOR.resource_id = BRS.resource_id
                     AND BRS.resource_type = 2  -- person.
                     );




  -- cursor to validate operation seq.
  -- At least one person resource should exist.
  CURSOR c_is_op_seq_valid(p_workorder_id  IN NUMBER,
                           p_op_seq_num    IN NUMBER,
                           p_wip_entity_id IN NUMBER) IS
  SELECT 'x' -- status_code
  FROM AHL_WORKORDER_OPERATIONS
  WHERE WORKORDER_ID = p_workorder_id
  AND OPERATION_SEQUENCE_NUM = p_op_seq_num
  AND status_code = 2  -- uncomplete
  AND exists ( SELECT 'x'
               FROM wip_operation_resources WOR, bom_resources BRS
               WHERE WOR.wip_entity_id = p_wip_entity_id
                AND WOR.operation_seq_num = p_op_seq_num
                AND WOR.resource_id = BRS.resource_id
                AND BRS.resource_type = 2  -- person.
             );

  -- Query to check if for an operation, given employee is qualified for at least one resource reqd.
  -- Fix for bug# 6748783. Support for borrowed resources.
  CURSOR c_qualified_for_one_res(p_employee_id  IN NUMBER,
                                 p_wip_entity_id IN NUMBER,
                                 p_operation_seq_num  IN NUMBER) IS
    SELECT 'x'
    FROM wip_operations wo
      WHERE wo.wip_entity_id = p_wip_entity_id
      and wo.operation_seq_num = p_operation_seq_num
      AND exists ( SELECT 'x'
                   FROM  wip_operation_resources WOR,
                         bom_resources BRS,
                         bom_resource_employees bre,
                         bom_dept_res_instances bdri,
                         bom_department_resources bdr
                   WHERE WOR.operation_seq_num = wo.operation_seq_num
                     AND WOR.wip_entity_id = wo.wip_entity_id
                     AND WOR.resource_id = BRS.resource_id
                     AND wor.organization_id = brs.organization_id
                     AND BRS.resource_type = 2  -- person.
                     AND brs.resource_id = bre.resource_id
                     AND brs.organization_id = bre.organization_id
                     --AND WO.department_id = bdri.department_id
                     AND nvl(bdr.share_from_dept_id, WO.department_id) = bdri.department_id
                     AND bdr.department_id = WO.department_id
                     AND bdr.resource_id = WOR.RESOURCE_ID
                     AND WOR.RESOURCE_ID= bdri.resource_id
                     AND bre.instance_id = bdri.instance_id
                     AND bre.resource_id = bdri.resource_id
                     AND bre.person_id = p_employee_id);

  -- Query to check if employee does not qualify for a operation-resource req.
  -- Support for borrowed resources. Fix for bug# 6748783
  CURSOR c_qualify_res(p_employee_id  IN NUMBER,
                       p_wip_entity_id IN NUMBER,
                       p_operation_seq_num  IN NUMBER,
                       p_resource_id        IN NUMBER) IS

    SELECT 'x'
    FROM wip_operations wo,
         wip_operation_resources WOR
    WHERE wo.wip_entity_id = WOR.wip_entity_id
      AND wo.operation_seq_num = WOR.operation_seq_num
      AND wo.wip_entity_id = p_wip_entity_id
      AND WOR.operation_seq_num = p_operation_seq_num
      AND WOR.resource_id = p_resource_id
      AND not exists ( SELECT 'x'
                       FROM bom_resource_employees bre,
                            bom_dept_res_instances bdri,
                            bom_department_resources bdr
                       WHERE bre.resource_id = wor.resource_id
                         AND bre.organization_id = wor.organization_id
                         --AND WO.department_id = bdri.department_id
                         AND nvl(bdr.share_from_dept_id, WO.department_id) = bdri.department_id
                         AND bdr.department_id = WO.department_id
                         AND bdr.resource_id = WOR.resource_id
                         AND WOR.RESOURCE_ID= bdri.resource_id
                         AND bre.instance_id = bdri.instance_id
                         AND bre.resource_id = bdri.resource_id
                         AND bre.person_id = p_employee_id);

  -- query to get resource ID id given resource seq num input.
  CURSOR c_get_resrc_id(p_wip_entity_id     IN NUMBER,
                        p_operation_seq_num IN NUMBER,
                        p_resource_seq_num  IN NUMBER) IS
    SELECT resource_id
    FROM WIP_OPERATION_RESOURCES WOR
    WHERE WOR.wip_entity_id = p_wip_entity_id
      AND WOR.operation_seq_num = p_operation_seq_num
      AND WOR.resource_seq_num = p_resource_seq_num;


  -- query to validate resource_id. Resource must be of type 'person'.
  CURSOR c_is_resource_valid(p_resource_id IN NUMBER,
                             p_org_id      IN NUMBER) IS
    SELECT resource_code
    FROM BOM_RESOURCES
    WHERE RESOURCE_ID = p_resource_id
      AND organization_id = p_org_id
      AND resource_type = 2;

  -- query to check if all operations of a WO are uncomplete.
  CURSOR c_workorder_oper(p_workorder_id IN NUMBER) IS
    SELECT 'x'
    FROM AHL_WORKORDER_OPERATIONS
    WHERE workorder_id = p_workorder_id
      AND STATUS_CODE = '1' -- complete.
      AND rownum < 2;

  -- query to get all operations for a workorder.
  CURSOR c_get_workorder_oper (p_wip_entity_id IN NUMBER) IS
    SELECT operation_seq_num
    FROM WIP_OPERATIONS
    WHERE wip_entity_id = p_wip_entity_id;

  l_employee_id    NUMBER;
  l_wo_status      AHL_WORKORDERS.status_code%TYPE;
  l_wo_name        AHL_WORKORDERS.workorder_name%TYPE;
  l_wip_entity_id  NUMBER;
  l_org_id         NUMBER;

  --l_oper_status  AHL_WORKORDER_OPERATIONS.status_code%TYPE;
  l_resource_code BOM_RESOURCES.resource_code%TYPE;

  l_junk         VARCHAR2(1);
  l_return_status  VARCHAR2(1);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);

  l_login_workorder_id  NUMBER;
  l_login_op_seq_num    NUMBER;
  l_login_resource_id   NUMBER;
  l_login_resrc_seq_num NUMBER;
  l_login_wo_name       AHL_WORKORDERS.workorder_name%TYPE;
  l_resource_id         NUMBER;
  l_employee_name       per_people_f.full_name%TYPE;

  l_fnd_function_name   VARCHAR2(100);

  CURSOR c_emp_login_details(c_employee_id IN NUMBER) IS
    SELECT WLGN.workorder_id,
             WLGN.operation_seq_num,
             AOR.resource_id,
             WLGN.resource_seq_num
      FROM AHL_Operation_Resources AOR, AHL_WORK_LOGIN_TIMES WLGN
      WHERE WLGN.operation_resource_id = AOR.operation_resource_id(+)
        AND WLGN.employee_id = c_employee_id
        AND WLGN.logout_date IS NULL;

BEGIN
  --Return FND_API.G_FALSE;
  -- Check if login enabled.
  IF (NVL(FND_PROFILE.value('AHL_PRD_MANUAL_RES_TXN'),'N') = 'Y') THEN
       Return FND_API.G_FALSE;
  END IF;

  -- Check required parameters.
  IF p_workorder_id IS NULL THEN
     Return FND_API.G_FALSE;
  END IF;
  -- Validate Workorder.
  OPEN c_is_wo_valid (p_workorder_id);
  FETCH c_is_wo_valid INTO l_wo_status, l_wo_name, l_wip_entity_id, l_org_id;
  IF c_is_wo_valid%NOTFOUND THEN
        CLOSE c_is_wo_valid;
        RETURN FND_API.G_FALSE;
  END IF;
  CLOSE c_is_wo_valid;

  -- Validate WO status.
  IF l_wo_status in ('1','6','7','22','12','4','5') THEN
    RETURN FND_API.G_FALSE;
  END IF;

  -- Default employee if input is null.
  IF (p_employee_id IS NULL) THEN
    l_employee_id := Get_Employee_ID();
  END IF;
  IF(l_employee_id IS NULL) THEN
     RETURN FND_API.G_FALSE;
  END IF;


  -- Get login info.
    OPEN c_emp_login_details(l_employee_id);

    FETCH c_emp_login_details INTO l_login_workorder_id,
                                   l_login_op_seq_num, l_login_resource_id,
                                   l_login_resrc_seq_num;
    IF (c_emp_login_details%NOTFOUND) THEN
       -- employee not logged in.
       l_login_workorder_id := NULL;
       l_login_op_seq_num := NULL;
       l_login_resource_id := NULL;
       l_login_resrc_seq_num := NULL;
    END IF; -- c_emp_login_details%NOTFOUND
    CLOSE c_emp_login_details;

  -- Check for login WO. If user already logged in, then do not allow login into another WO.
  IF (l_login_workorder_id IS NOT NULL) THEN
     RETURN FND_API.G_FALSE;
  END IF;


  -- Check Unit locked.
  IF AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => p_workorder_id,
                                     p_ue_id             => null,
                                     p_visit_id          => null,
                                     p_item_instance_id  => null) = FND_API.g_true THEN
     -- Unit is locked, therefore cannot perform resource transactions
     -- and hence cannot login to the workorder
     RETURN FND_API.G_FALSE;
  END IF;


  -- validate login into workorder/operation/operation-resource.
  IF (p_operation_seq_num IS NULL) THEN

      -- validate if any operation is complete.
      OPEN c_workorder_oper(p_workorder_id);
      FETCH c_workorder_oper INTO l_junk;
       IF (c_workorder_oper%FOUND) THEN
          CLOSE c_workorder_oper;
          RETURN FND_API.G_FALSE;
       END IF;
      CLOSE c_workorder_oper;

      -- validate WO has at least one 'person' resource reqmt.
      OPEN c_check_res_reqd(l_wip_entity_id);
      FETCH c_check_res_reqd INTO l_junk;
        IF c_check_res_reqd%NOTFOUND THEN
           -- Login at the workorder level will be disabled.
           CLOSE c_check_res_reqd;
           RETURN FND_API.G_FALSE;
        END IF; -- c_check_res_reqd.
      CLOSE c_check_res_reqd;

      -- Validate qualification to login into a WO in Technician case.
      -- Commented l_fnd_function_name validation to fix bug# 5015149.
      -- IF (l_fnd_function_name = AHL_PRD_UTIL_PKG.G_TECH_MYWO) THEN
          -- validate user qualifies for at least one resource requirement within each operation.
          FOR operation_rec IN c_get_workorder_oper(l_wip_entity_id) LOOP
             OPEN c_qualified_for_one_res(l_employee_id, l_wip_entity_id, operation_rec.operation_seq_num);
             FETCH c_qualified_for_one_res INTO l_junk;
             IF c_qualified_for_one_res%NOTFOUND THEN
                CLOSE c_qualified_for_one_res;
                RETURN FND_API.G_FALSE;
             END IF; -- c_qualified_for_one_ops
             CLOSE c_qualified_for_one_res;
          END LOOP; -- operation_rec
  END IF;  -- operation_seq_num IS NULL

  IF (p_operation_seq_num IS NOT NULL) THEN

      -- Validate operation seq num.
      -- If operation has no person resource requirements, user cannot login into operation.
      -- operation status should be uncomplete.
      OPEN c_is_op_seq_valid (p_workorder_id, p_operation_seq_num, l_wip_entity_id);
      FETCH c_is_op_seq_valid INTO l_junk;
      IF c_is_op_seq_valid%NOTFOUND THEN
         CLOSE c_is_op_seq_valid;
         RETURN FND_API.G_FALSE;
      END IF; -- c_is_op_seq_valid.
      CLOSE c_is_op_seq_valid;

      -- Check login into Operation or Operation+resource.
      IF (p_resource_id IS NULL AND p_resource_seq_num IS NULL) THEN

          -- Login into operation only.
          -- Validate qualification to login into a Operation in Technician case.
          -- Commented l_fnd_function_name validation to fix bug# 5015149.
          -- IF (l_fnd_function_name = AHL_PRD_UTIL_PKG.G_TECH_MYWO) THEN
              -- validate user qualifies for at least one resource requirement for the operation.
              OPEN c_qualified_for_one_res(l_employee_id, l_wip_entity_id, p_operation_seq_num);
              FETCH c_qualified_for_one_res INTO l_junk;
              IF (c_qualified_for_one_res%NOTFOUND) THEN
                 CLOSE c_qualified_for_one_res;
                 RETURN FND_API.G_FALSE;
              END IF; -- c_qualified_for_one_res
              CLOSE c_qualified_for_one_res;
      ELSE  -- login into operation + resource.
          -- Get resource ID if resource seq num is input and resource_id is NULL.
          IF (p_resource_id IS NULL AND p_resource_seq_num IS NOT NULL) THEN
              OPEN c_get_resrc_id(l_wip_entity_id, p_operation_seq_num, p_resource_seq_num);
              FETCH c_get_resrc_id INTO l_resource_id;
              IF (c_get_resrc_id%NOTFOUND) THEN
                CLOSE c_get_resrc_id;
                RETURN FND_API.G_FALSE;
              END IF;
              CLOSE c_get_resrc_id;
          ELSE
              l_resource_id := p_resource_id;
          END IF; -- p_resource_id IS NULL AND ...

          -- Validate Resource ID.
          OPEN c_is_resource_valid(l_resource_id, l_org_id);
          FETCH c_is_resource_valid INTO l_resource_code;
          IF (c_is_resource_valid%NOTFOUND) THEN
            CLOSE c_is_resource_valid;
            RETURN FND_API.G_FALSE;
          END IF; -- c_is_resource_valid
          CLOSE c_is_resource_valid;

          -- Validate qualification in case of technician.
          -- Commented l_fnd_function_name validation to fix bug# 5015149.
          -- IF (l_fnd_function_name = AHL_PRD_UTIL_PKG.G_TECH_MYWO) THEN
              OPEN c_qualify_res(l_employee_id, l_wip_entity_id, p_operation_seq_num,
                                 l_resource_id);
              FETCH c_qualify_res INTO l_junk;
              IF (c_qualify_res%FOUND) THEN
                 CLOSE c_qualify_res;
                 RETURN FND_API.G_FALSE;
              END IF;
              CLOSE c_qualify_res;
          -- END IF; -- l_fnd_function_name = AHL_PRD_UTIL_PKG.G_TECH_MYWO

      END IF; -- p_resource_id IS NULL

  END IF; -- operation_seq_num is not null.
  -- Set login allowed flag.
  RETURN FND_API.G_TRUE;
END Is_Login_Enabled;

---------------------------------------------------------------------------------------------

-- Start of Comments --
--  Function name : Is_Logout_Enabled
--
--  Parameters  :
--                  p_employee_id    --  Optional Input Employee Id.
--                  p_wip_entity_id   --  Mandatory Workorder ID.
--                  p_operation_seq_num -- Mandatory Operation Seq Number
--                  p_resource_seq_num  -- Mandatory Resource ID.
--                  p_fnd_function_name  -- Mandatory fnd_function to identify user role.
--
--  Description   : This function returns whether user is allowed to logout into a
--                  wrokorder/operation-resource
--


FUNCTION Is_Logout_Enabled(p_employee_id       IN NUMBER := NULL,
                          p_workorder_id      IN NUMBER,
                          p_operation_seq_num IN NUMBER := NULL,
                          p_resource_seq_num  IN NUMBER := NULL,
                          p_resource_id       IN NUMBER := NULL,
                          p_fnd_function_name IN VARCHAR2 := NULL)
RETURN VARCHAR2 IS


  l_login_workorder_id  NUMBER;
  l_login_op_seq_num    NUMBER;
  l_login_resource_id   NUMBER;
  l_login_resrc_seq_num NUMBER;
  l_resource_id         NUMBER;
  l_employee_id         NUMBER;

  -- Cursor to check current assignments.
    CURSOR c_emp_login_details(c_employee_id IN NUMBER) IS
    SELECT WLGN.workorder_id,
             WLGN.operation_seq_num,
             AOR.resource_id,
             WLGN.resource_seq_num
      FROM AHL_Operation_Resources AOR, AHL_WORK_LOGIN_TIMES WLGN
      WHERE WLGN.operation_resource_id = AOR.operation_resource_id(+)
        AND WLGN.employee_id = c_employee_id
        AND WLGN.logout_date IS NULL;   --   employee logged in.
BEGIN
    IF (NVL(FND_PROFILE.value('AHL_PRD_MANUAL_RES_TXN'),'N') = 'Y') THEN
       Return FND_API.G_FALSE;
    END IF;

    -- Check required parameters.
    IF p_workorder_id IS NULL THEN
      Return FND_API.G_FALSE;
    END IF;
    IF (p_employee_id IS NULL) THEN
       l_employee_id := Get_Employee_ID();
    ELSE
       l_employee_id := p_employee_id;
    END IF;

     -- Return error if employee id not found.
    IF (l_employee_id IS NULL) THEN
       RETURN FND_API.G_FALSE;
    END IF;

    -- Get login info.
    OPEN c_emp_login_details(l_employee_id);

    FETCH c_emp_login_details INTO l_login_workorder_id,
                                   l_login_op_seq_num, l_login_resource_id,
                                   l_login_resrc_seq_num;
    IF (c_emp_login_details%NOTFOUND) THEN
       -- employee not logged in.
       l_login_workorder_id := NULL;
       l_login_op_seq_num := NULL;
       l_login_resource_id := NULL;
       l_login_resrc_seq_num := NULL;
    END IF; -- c_emp_login_details%NOTFOUND
    CLOSE c_emp_login_details;

  IF(l_login_workorder_id IS NULL) THEN
    RETURN FND_API.G_FALSE;
  ELSIF (l_login_op_seq_num IS NULL AND l_login_workorder_id = p_workorder_id AND p_operation_seq_num IS NULL) THEN
    RETURN FND_API.G_TRUE;
  ELSIF(l_login_op_seq_num IS NOT NULL AND l_login_resrc_seq_num IS NOT NULL)THEN
    IF(l_login_workorder_id = p_workorder_id AND l_login_op_seq_num = p_operation_seq_num
       AND l_login_resrc_seq_num = p_resource_seq_num AND l_login_resource_id = p_resource_id)THEN
       RETURN FND_API.G_TRUE;
    END IF;
  END IF;
   RETURN FND_API.G_FALSE;
END Is_Logout_Enabled;


END AHL_PRD_WO_LOGIN_PVT;

/
