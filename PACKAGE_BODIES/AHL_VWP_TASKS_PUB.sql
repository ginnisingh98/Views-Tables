--------------------------------------------------------
--  DDL for Package Body AHL_VWP_TASKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_TASKS_PUB" AS
/* $Header: AHLPTSKB.pls 120.0 2008/04/03 06:00:28 jaramana noship $ */

G_PKG_NAME        CONSTANT VARCHAR2(30) := 'AHL_VWP_TASKS_PUB';

-- Declare local functions and procedures
PROCEDURE Validate_And_Prepare_Params(
    p_visit_id         IN            NUMBER,
    p_visit_number     IN            NUMBER,
    p_department_id    IN            NUMBER,
    p_department_code  IN            VARCHAR2,
    p_x_tasks_tbl      IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Tbl_Type);


-------------------------------------------------------------------------------------------
-- Start of Comments
--  Procedure name    : Create_Planned_Tasks
--  Type              : Public
--  Function          : Creates planned tasks and adds them to an existing visit.
--  Pre-reqs          :
--  Parameters        :
--
--  Create_Planned_Tasks Parameters:
--       p_visit_id         IN            NUMBER   := null Not needed if p_visit_number is given
--       p_visit_number     IN            NUMBER   := null Ignored if p_visit_id is given
--       p_department_id    IN            NUMBER   := null Not needed if p_department_code is given
--       p_department_code  IN            VARCHAR2 := null Ignored if p_department_id is given
--       p_x_tasks_tbl      IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Tbl_Type
--                          UNIT_EFFECTIVITY_ID is Mandatory
--                          ATTRIBUTE_CATEGORY  is Optional
--                          ATTRIBUTE1..ATTRIBUTE15 are Optional
--                          All others input attributes are ignored
--                          VISIT_TASK_ID has the return value: Id of the task created for the UE.
--
--  End of Comments
-------------------------------------------------------------------------------------------
PROCEDURE Create_Planned_Tasks (
    p_api_version      IN            NUMBER,
    p_init_msg_list    IN            VARCHAR2 := FND_API.G_FALSE,
    p_commit           IN            VARCHAR2 := FND_API.G_FALSE,
    p_validation_level IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_visit_id         IN            NUMBER   := null, -- Not needed if p_visit_number is given
    p_visit_number     IN            NUMBER   := null, -- Ignored if p_visit_id is given
    p_department_id    IN            NUMBER   := null, -- Not needed if p_department_code is given
    p_department_code  IN            VARCHAR2 := null, -- Ignored if p_department_id is given
    p_x_tasks_tbl      IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Tbl_Type,
    x_return_status    OUT NOCOPY    VARCHAR2,
    x_msg_count        OUT NOCOPY    NUMBER,
    x_msg_data         OUT NOCOPY    VARCHAR2
) IS

--
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Create_Planned_Tasks';
l_full_name    CONSTANT VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

--

BEGIN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure, l_full_name || '.begin', 'At the start of the API.' ||
                       ' p_visit_id = ' || p_visit_id ||
                       ', p_visit_number = ' || p_visit_number ||
                       ', p_department_id = ' || p_department_id ||
                       ', p_department_code = ' || p_department_code ||
                       ', p_x_tasks_tbl.COUNT = ' || p_x_tasks_tbl.COUNT);
    END IF;

    -- Standard start of API savepoint
    SAVEPOINT Create_Planned_Tasks_Pub;

    -- Initialize Procedure return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
    END IF;

    -- Validate the input and prepare for subsequent calls
    -- If there are errors, an exception is raised.
    Validate_And_Prepare_Params(p_visit_id        => p_visit_id,
                                p_visit_number    => p_visit_number,
                                p_department_id   => p_department_id,
                                p_department_code => p_department_code,
                                p_x_tasks_tbl     => p_x_tasks_tbl);

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(FND_LOG.level_statement, l_full_name, 'About to call AHL_VWP_TASKS_PVT.Create_PUP_Tasks.');
    END IF;

    AHL_VWP_TASKS_PVT.Create_PUP_Tasks(p_api_version => 1.0,
                                       p_init_msg_list => Fnd_Api.g_false,
                                       p_commit => Fnd_Api.g_false,
                                       p_validation_level => Fnd_Api.g_valid_level_full,
                                       p_module_type => 'API',
                                       p_x_task_tbl => p_x_tasks_tbl,
                                       x_return_status => x_return_status,
                                       x_msg_count => x_msg_count,
                                       x_msg_data => x_msg_data);

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(FND_LOG.level_statement, l_full_name, 'Returned from AHL_VWP_TASKS_PVT.Create_PUP_Tasks. x_return_status = ' || x_return_status);
    END IF;

    IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(FND_LOG.level_statement, l_full_name, 'For index ' || p_x_tasks_tbl.FIRST ||
                     ' with unit effectivity id ' || p_x_tasks_tbl(p_x_tasks_tbl.FIRST).UNIT_EFFECTIVITY_ID ||
                     ', Visit Task Id = ' || p_x_tasks_tbl(p_x_tasks_tbl.FIRST).VISIT_TASK_ID);
    END IF;

    -- Standard check of p_commit
    IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get
    ( p_count   => x_msg_count,
      p_data    => x_msg_data,
      p_encoded => FND_API.G_FALSE
    );

    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure, l_full_name || '.end', 'End of the API');
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        Rollback to Create_Planned_Tasks_Pub;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        Rollback to Create_Planned_Tasks_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN OTHERS THEN
        Rollback to Create_Planned_Tasks_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Add_Exc_Msg( p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => l_api_name,
                                 p_error_text     => SQLERRM);
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => FND_API.G_FALSE);

END Create_Planned_Tasks;

-- This API validates the input params and raises an exception in case any are invalid
-- It also resets unwanted attributes so that only the attributes needed for creating
-- Planned tasks are retained.

PROCEDURE Validate_And_Prepare_Params(
    p_visit_id         IN            NUMBER,
    p_visit_number     IN            NUMBER,
    p_department_id    IN            NUMBER,
    p_department_code  IN            VARCHAR2,
    p_x_tasks_tbl      IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Tbl_Type
) IS

l_api_name     CONSTANT VARCHAR2(30) := 'Validate_And_Prepare_Params';
l_full_name    CONSTANT VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;
l_visit_id     NUMBER;
l_dept_id      NUMBER;
l_org_id       NUMBER := NULL;
l_valid_flag   BOOLEAN := true;
l_source_rec   AHL_VWP_RULES_PVT.Task_Rec_Type;
l_dest_rec     AHL_VWP_RULES_PVT.Task_Rec_Type;
l_index        NUMBER;
l_temp_num     NUMBER;

CURSOR validate_visit_id_csr(c_visit_id IN NUMBER) IS
 SELECT organization_id FROM ahl_visits_b
 WHERE visit_id = c_visit_id
   AND status_code in ('RELEASED', 'PLANNING', 'PARTIALLY RELEASED');

CURSOR validate_visit_number_csr(c_visit_number IN NUMBER) IS
 SELECT visit_id, organization_id FROM ahl_visits_b
 WHERE visit_number = c_visit_number
   AND status_code in ('RELEASED', 'PLANNING', 'PARTIALLY RELEASED');

CURSOR validate_dept_id_csr(c_dept_id IN NUMBER, c_org_id IN NUMBER) IS
 SELECT department_id FROM bom_departments
 WHERE department_id = c_dept_id
   AND organization_id = c_org_id;

CURSOR validate_dept_code_csr(c_dept_code IN VARCHAR2, c_org_id IN NUMBER) IS
 SELECT department_id FROM bom_departments
 WHERE department_code = c_dept_code
   AND organization_id = c_org_id;

CURSOR check_group_mr_csr(c_ue_id IN NUMBER) IS
  SELECT 1 from AHL_UE_RELATIONSHIPS
  WHERE RELATED_UE_ID = c_ue_id;

BEGIN
  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(FND_LOG.level_procedure, l_full_name || '.begin', 'At the start of the API');
  END IF;
  IF (p_visit_id IS NULL and p_visit_number IS NULL) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_LTP_INVALID_VISIT_NUMBER');
    FND_MSG_PUB.ADD;
    l_valid_flag := false;
  ELSE
    IF (p_visit_id IS NOT NULL) THEN
      -- Validate the visit_id and set l_visit_id
      OPEN validate_visit_id_csr(p_visit_id);
      FETCH validate_visit_id_csr INTO l_org_id;
      IF(validate_visit_id_csr%NOTFOUND) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_VISIT_ID_INVALID');  --@@@@@
        FND_MESSAGE.Set_Token('VISIT_ID', p_visit_id);
        FND_MSG_PUB.ADD;
        l_valid_flag := false;
      ELSE
        l_visit_id := p_visit_id;
      END IF;
      CLOSE validate_visit_id_csr;
    ELSE
      -- Derive the visit_id from the visit_number
      OPEN validate_visit_number_csr(p_visit_number);
      FETCH validate_visit_number_csr INTO l_visit_id, l_org_id;
      IF(validate_visit_number_csr%NOTFOUND) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_LTP_INVALID_VISIT_NUMBER');
        FND_MSG_PUB.ADD;
        l_valid_flag := false;
      END IF;
      CLOSE validate_visit_number_csr;
    END IF;
  END IF;
  IF(NOT l_valid_flag) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_department_id IS NOT NULL) THEN
    IF (l_org_id IS NULL) THEN
      -- Cannot add task since the visit does not have an org
      FND_MESSAGE.Set_Name('AHL', 'AHL_VWP_VISIT_ORG_NOT_SET');  -- @@@@@
      FND_MSG_PUB.ADD;
      l_valid_flag := false;
    ELSE
      -- Validate the department_id and set l_dept_id
      OPEN validate_dept_id_csr(p_department_id, l_org_id);
      FETCH validate_dept_id_csr INTO l_dept_id;
      IF(validate_dept_id_csr%NOTFOUND) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_LTP_DEPT_ID_NOT_EXIST');
        FND_MSG_PUB.ADD;
        l_valid_flag := false;
      END IF;
      CLOSE validate_dept_id_csr;
    END IF;
  ELSIF (p_department_code IS NOT NULL) THEN
    -- Derive the department_id from the dept_code
    OPEN validate_dept_code_csr(p_department_code, l_org_id);
    FETCH validate_dept_code_csr INTO l_dept_id;
    IF(validate_dept_code_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_VWP_DEPT_CODE_INVALID');  --@@@@@
      FND_MESSAGE.Set_Token('DEPT_CODE', p_department_code);
      FND_MSG_PUB.ADD;
      l_valid_flag := false;
    END IF;
    CLOSE validate_dept_code_csr;
  END IF;
  IF(NOT l_valid_flag) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Validate and pre-process the tasks table
  IF (p_x_tasks_tbl.COUNT < 1) THEN
    -- input is NULL
    FND_MESSAGE.Set_Name('AHL', 'AHL_TASKS_TBL_EMPTY');  --@@@@@
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_index := p_x_tasks_tbl.FIRST;
  WHILE (l_index <= p_x_tasks_tbl.LAST) LOOP
    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(FND_LOG.level_statement, l_full_name, 'l_index = ' || l_index ||
                     ', p_x_tasks_tbl(l_index).UNIT_EFFECTIVITY_ID = ' || p_x_tasks_tbl(l_index).UNIT_EFFECTIVITY_ID ||
                     ', p_x_tasks_tbl(l_index).DEPARTMENT_ID = ' || p_x_tasks_tbl(l_index).DEPARTMENT_ID ||
                     ', p_x_tasks_tbl(l_index).DEPT_NAME = ' || p_x_tasks_tbl(l_index).DEPT_NAME);
    END IF;
    -- Validate and copy only relevant fields to l_dest_rec
    IF (p_x_tasks_tbl(l_index).UNIT_EFFECTIVITY_ID IS NULL) THEN
      Fnd_Message.SET_NAME('AHL', 'AHL_VWP_NO_UNIT_EFFECTIVITY');
      Fnd_Msg_Pub.ADD;
      RAISE  FND_API.G_EXC_ERROR;
    ELSE
      OPEN check_group_mr_csr(p_x_tasks_tbl(l_index).UNIT_EFFECTIVITY_ID);
      FETCH check_group_mr_csr INTO l_temp_num;
      IF(check_group_mr_csr%FOUND) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_NO_CHILD_ASSOC_VISIT');
        FND_MSG_PUB.ADD;
        CLOSE check_group_mr_csr;
        RAISE  FND_API.G_EXC_ERROR;
      END IF;
      CLOSE check_group_mr_csr;

      -- Remaining validations of this UE happen at AHL_VWP_PLAN_TASKS_PVT.Create_Planned_Task
      l_dest_rec.UNIT_EFFECTIVITY_ID := p_x_tasks_tbl(l_index).UNIT_EFFECTIVITY_ID;
    END IF;
    IF (p_x_tasks_tbl(l_index).DEPARTMENT_ID IS NULL AND p_x_tasks_tbl(l_index).DEPT_NAME IS NULL) THEN
      l_dest_rec.DEPARTMENT_ID := l_dept_id;
    ELSE
      l_dest_rec.DEPARTMENT_ID := p_x_tasks_tbl(l_index).DEPARTMENT_ID;
      l_dest_rec.DEPT_NAME := p_x_tasks_tbl(l_index).DEPT_NAME;
    END IF;
    l_dest_rec.VISIT_ID           := l_visit_id;
    l_dest_rec.task_type_code     := 'PLANNED';
    l_dest_rec.ATTRIBUTE_CATEGORY := p_x_tasks_tbl(l_index).ATTRIBUTE_CATEGORY;
    l_dest_rec.ATTRIBUTE1         := p_x_tasks_tbl(l_index).ATTRIBUTE1;
    l_dest_rec.ATTRIBUTE2         := p_x_tasks_tbl(l_index).ATTRIBUTE2;
    l_dest_rec.ATTRIBUTE3         := p_x_tasks_tbl(l_index).ATTRIBUTE3;
    l_dest_rec.ATTRIBUTE4         := p_x_tasks_tbl(l_index).ATTRIBUTE4;
    l_dest_rec.ATTRIBUTE5         := p_x_tasks_tbl(l_index).ATTRIBUTE5;
    l_dest_rec.ATTRIBUTE6         := p_x_tasks_tbl(l_index).ATTRIBUTE6;
    l_dest_rec.ATTRIBUTE7         := p_x_tasks_tbl(l_index).ATTRIBUTE7;
    l_dest_rec.ATTRIBUTE8         := p_x_tasks_tbl(l_index).ATTRIBUTE8;
    l_dest_rec.ATTRIBUTE9         := p_x_tasks_tbl(l_index).ATTRIBUTE9;
    l_dest_rec.ATTRIBUTE10        := p_x_tasks_tbl(l_index).ATTRIBUTE10;
    l_dest_rec.ATTRIBUTE11        := p_x_tasks_tbl(l_index).ATTRIBUTE11;
    l_dest_rec.ATTRIBUTE12        := p_x_tasks_tbl(l_index).ATTRIBUTE12;
    l_dest_rec.ATTRIBUTE13        := p_x_tasks_tbl(l_index).ATTRIBUTE13;
    l_dest_rec.ATTRIBUTE14        := p_x_tasks_tbl(l_index).ATTRIBUTE14;
    l_dest_rec.ATTRIBUTE15        := p_x_tasks_tbl(l_index).ATTRIBUTE15;
    p_x_tasks_tbl(l_index) := l_dest_rec;
    l_index := l_index + 1;
  END LOOP;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(FND_LOG.level_procedure, l_full_name || '.end', 'Exiting API - Params validated.');
  END IF;
END Validate_And_Prepare_Params;

End AHL_VWP_TASKS_PUB;

/
