--------------------------------------------------------
--  DDL for Package Body AHL_VWP_VISITS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_VISITS_PUB" AS
/* $Header: AHLPVSTB.pls 120.0.12010000.3 2009/04/08 10:11:04 skpathak noship $ */

G_PKG_NAME        CONSTANT VARCHAR2(30) := 'AHL_VWP_VISITS_PUB';

-- Declare local functions and procedures
PROCEDURE Validate_And_Prepare_Params(
    p_x_visit_rec IN OUT NOCOPY AHL_VWP_VISITS_PVT.Visit_Rec_Type);


-------------------------------------------------------------------------------------------
-- Start of Comments
--  Procedure name    : Create_Visit
--  Type              : Public
--  Function          : Creates a visit.
--  Pre-reqs          :
--  Parameters        :
--
--  Create_Visit Parameters:
--       p_x_visit_rec      IN OUT NOCOPY AHL_VWP_VISITS_PVT.Visit_Rec_Type
--          Description of some key attributes in p_x_visit_rec:
--                          VISIT_NAME             VARCHAR2(80)   Mandatory
--                          DESCRIPTION            VARCHAR2(4000) Optional
--                          ORGANIZATION_ID        NUMBER         Optional
--                          ORG_NAME               VARCHAR2(240)  Optional
--                          DEPARTMENT_ID          NUMBER         Optional
--                          DEPT_NAME              VARCHAR2(240)  Optional
--                          SERVICE_REQUEST_ID     NUMBER         Optional
--                          SERVICE_REQUEST_NUMBER VARCHAR2(240)  Optional
--                          START_DATE             DATE           Mandatory for transit visits.
--                          START_HOUR             NUMBER         Optional
--                          START_MIN              NUMBER         Optional
--                          PLAN_END_DATE          DATE           Optional
--                          PLAN_END_HOUR          NUMBER         Optional
--                          PLAN_END_MIN           NUMBER         Optional
--                          VISIT_TYPE_CODE        VARCHAR2(30)   Optional
--                          VISIT_TYPE_NAME        VARCHAR2(80)   Optional
--                          UNIT_HEADER_ID         NUMBER         Optional
--                          UNIT_NAME              VARCHAR2(80)   Optional
--                          PROJ_TEMPLATE_ID       NUMBER         Optional
--                          PROJ_TEMPLATE_NAME     VARCHAR2(30)   Optional
--                          PRIORITY_CODE          VARCHAR2(30)   Optional
--                          PRIORITY_VALUE         VARCHAR2(80)   Optional
--                          UNIT_SCHEDULE_ID       NUMBER         Mandatory for transit visits.
--                          VISIT_CREATE_TYPE      VARCHAR2(30)   Can be null, PRODUCTION_UNRELEASED or PRODUCTION_RELEASED
--                          ATTRIBUTE_CATEGORY     VARCHAR2(240)  Optional
--                          ATTRIBUTE1..ATTRIBUTE15 are Optional
--                          Most other input attributes are ignored
--                          VISIT_ID has the return value: Id of the visit created.
--
--  End of Comments
-------------------------------------------------------------------------------------------
PROCEDURE Create_Visit (
    p_api_version      IN            NUMBER,
    p_init_msg_list    IN            VARCHAR2 := FND_API.G_FALSE,
    p_commit           IN            VARCHAR2 := FND_API.G_FALSE,
    p_validation_level IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_x_visit_rec      IN OUT NOCOPY AHL_VWP_VISITS_PVT.Visit_Rec_Type,
    x_return_status    OUT NOCOPY    VARCHAR2,
    x_msg_count        OUT NOCOPY    NUMBER,
    x_msg_data         OUT NOCOPY    VARCHAR2
) IS

--
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Create_Visit';
l_full_name    CONSTANT VARCHAR2(99) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;
l_Visit_tbl    AHL_VWP_VISITS_PVT.Visit_Tbl_Type ;

--

BEGIN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure, l_full_name || '.begin', 'At the start of the API.');
    END IF;

    -- Standard start of API savepoint
    SAVEPOINT Create_Visit_Pub;

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
    Validate_And_Prepare_Params(p_x_visit_rec => p_x_visit_rec);

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(FND_LOG.level_statement, l_full_name, 'About to call AHL_VWP_VISITS_PVT.Create_Visit.');
    END IF;
    l_Visit_tbl(1) := p_x_visit_rec;

    AHL_VWP_VISITS_PVT.Process_Visit(p_api_version      => 1.0,
                                     p_init_msg_list    => Fnd_Api.g_false,
                                     p_commit           => Fnd_Api.g_false,
                                     p_validation_level => Fnd_Api.g_valid_level_full,
                                     p_module_type      => 'API',
                                     p_x_Visit_tbl      => l_Visit_tbl,
                                     x_return_status    => x_return_status,
                                     x_msg_count        => x_msg_count,
                                     x_msg_data         => x_msg_data);

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(FND_LOG.level_statement, l_full_name, 'Returned from AHL_VWP_VISITS_PVT.Create_Visit. x_return_status = ' || x_return_status);
    END IF;

    IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    p_x_visit_rec.VISIT_ID := l_Visit_tbl(1).VISIT_ID;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(FND_LOG.level_statement, l_full_name, 'Visit created successfully with name ' ||
                     p_x_visit_rec.VISIT_NAME || ' and id ' || p_x_visit_rec.VISIT_ID);
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
        Rollback to Create_Visit_Pub;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        Rollback to Create_Visit_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN OTHERS THEN
        Rollback to Create_Visit_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Add_Exc_Msg( p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => l_api_name,
                                 p_error_text     => SQLERRM);
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => FND_API.G_FALSE);

END Create_Visit;
--------------------------------------------------------------------------------------
-- This API validates the input params and raises an exception in case any are invalid
-- It also resets unwanted attributes so that only the attributes needed for creating
-- a visit are retained.
--
PROCEDURE Validate_And_Prepare_Params(
    p_x_visit_rec IN OUT NOCOPY AHL_VWP_VISITS_PVT.Visit_Rec_Type
) IS

l_api_name         CONSTANT VARCHAR2(30) := 'Validate_And_Prepare_Params';
l_full_name        CONSTANT VARCHAR2(99) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

l_return_status    VARCHAR2(1);
l_msg_data         VARCHAR2(2000);
l_valid_flag       BOOLEAN := true;
l_organization_id  NUMBER;
l_service_id       NUMBER;
l_temp_code        VARCHAR2(30);

CURSOR get_unit_name_csr(c_uc_header_id IN NUMBER) IS
 SELECT name FROM ahl_unit_config_headers
 WHERE unit_config_header_id = c_uc_header_id;

CURSOR get_unit_id_csr(c_uc_name IN VARCHAR2) IS
 SELECT unit_config_header_id FROM ahl_unit_config_headers
 WHERE name = c_uc_name;

CURSOR get_proj_template_name_csr(c_proj_template_id IN NUMBER) IS
 SELECT name FROM pa_projects
 WHERE project_id = c_proj_template_id
   AND template_flag = 'Y';

BEGIN
  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(FND_LOG.level_procedure, l_full_name || '.begin', 'At the start of the API');
  END IF;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(FND_LOG.level_statement, l_full_name, 'Values of important attributes in p_x_visit_rec: ' ||
      'operation_flag = ' || p_x_visit_rec.operation_flag ||
      ', organization_id = ' || p_x_visit_rec.organization_id ||
      ', department_id = ' || p_x_visit_rec.department_id ||
      ', service_request_id = ' || p_x_visit_rec.service_request_id ||
      ', visit_type_code = ' || p_x_visit_rec.visit_type_code ||
      ', unit_header_id = ' || p_x_visit_rec.unit_header_id ||
      ', unit_name = ' || p_x_visit_rec.unit_name ||
      ', proj_template_id = ' || p_x_visit_rec.proj_template_id ||
      ', priority_code = ' || p_x_visit_rec.priority_code);
  END IF;

  -- Nullify unwanted/system defaulted attributes
  p_x_visit_rec.VISIT_ID := null;
  p_x_visit_rec.VISIT_NUMBER := null;
  p_x_visit_rec.OBJECT_VERSION_NUMBER := null;
  p_x_visit_rec.LAST_UPDATE_DATE := null;
  p_x_visit_rec.LAST_UPDATED_BY := null;
  p_x_visit_rec.CREATION_DATE := null;
  p_x_visit_rec.CREATED_BY := null;
  p_x_visit_rec.LAST_UPDATE_LOGIN := null;
  p_x_visit_rec.SPACE_CATEGORY_CODE := null;
  p_x_visit_rec.SPACE_CATEGORY_NAME := null;
  p_x_visit_rec.END_DATE := null;
  p_x_visit_rec.DUE_BY_DATE := null;
  p_x_visit_rec.STATUS_CODE := null;
  p_x_visit_rec.STATUS_NAME := null;
  p_x_visit_rec.SIMULATION_PLAN_ID := null;
  p_x_visit_rec.SIMULATION_PLAN_NAME := null;
  p_x_visit_rec.ASSO_PRIMARY_VISIT_ID := null;
  p_x_visit_rec.ITEM_INSTANCE_ID := null;
  p_x_visit_rec.SERIAL_NUMBER := null;
  p_x_visit_rec.INVENTORY_ITEM_ID := null;
  p_x_visit_rec.ITEM_ORGANIZATION_ID := null;
  p_x_visit_rec.ITEM_NAME := null;
  p_x_visit_rec.SIMULATION_DELETE_FLAG := null;
  p_x_visit_rec.TEMPLATE_FLAG := null;
  p_x_visit_rec.OUT_OF_SYNC_FLAG := null;
  p_x_visit_rec.PROJECT_FLAG := null;
  p_x_visit_rec.PROJECT_FLAG_CODE := null;
  p_x_visit_rec.PROJECT_ID := null;
  p_x_visit_rec.PROJECT_NUMBER := null;
  p_x_visit_rec.DURATION := null;
  p_x_visit_rec.FLIGHT_NUMBER := null;

  -- Ensure that the Operation flag is valid.
  IF p_x_visit_rec.operation_flag IS NULL THEN
    p_x_visit_rec.operation_flag := 'I';
  END IF;
  IF (p_x_visit_rec.operation_flag <> 'I' AND p_x_visit_rec.operation_flag <> 'i') THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_COM_INVALID_DML_REC');
    FND_MESSAGE.Set_Token('FIELD', p_x_visit_rec.operation_flag);
    FND_MSG_PUB.ADD;
    l_valid_flag := false;
  END IF;

  -- VISIT_NAME mandatory validation done in PVT package methods

  -- Organization (ORGANIZATION_ID, ORG_NAME)
  -- If organization_id is passed, reset org_name and validate organization_id
  -- If only org_name is passed, the validation and value to id conversion are done in PVT package methods
  IF (p_x_visit_rec.organization_id IS NOT NULL) THEN
    p_x_visit_rec.org_name := NULL;
    AHL_VWP_RULES_PVT.Check_Org_Name_Or_Id
               (p_organization_id => p_x_visit_rec.organization_id,
                p_org_name        => null,
                x_organization_id => l_organization_id,
                x_return_status   => l_return_status,
                x_error_msg_code  => l_msg_data);

    IF (NVL(l_return_status,'x') <> 'S') THEN
      Fnd_Message.SET_NAME('AHL', 'AHL_APPR_ORG_NT_EXISTS');
      FND_MESSAGE.Set_Token('ORGID', p_x_visit_rec.organization_id);
      Fnd_Msg_Pub.ADD;
      l_valid_flag := false;
    END IF;
  END IF;

  -- Department validation done in PVT package methods

  -- Service Request (SERVICE_REQUEST_ID, SERVICE_REQUEST_NUMBER)
  -- If service_request_id is passed, reset service_request_number and validate service_request_id
  -- If only service_request_number is passed, the validation and value to id conversion are done in PVT package methods
  IF (p_x_visit_rec.service_request_id IS NOT NULL) THEN
    p_x_visit_rec.service_request_number := NULL;
    AHL_VWP_RULES_PVT.Check_SR_Request_Number_Or_Id
               (p_service_id      => p_x_visit_rec.service_request_id,
                p_service_number  => null,
                x_service_id      => l_service_id,
                x_return_status   => l_return_status,
                x_error_msg_code  => l_msg_data);

    IF (NVL(l_return_status,'x') <> 'S') THEN
      Fnd_Message.SET_NAME('AHL', 'AHL_VWP_SERVICE_REQ_NOT_EXISTS');
      Fnd_Msg_Pub.ADD;
      l_valid_flag := false;
    END IF;
  END IF;

  -- Visit Type (VISIT_TYPE_CODE, VISIT_TYPE_NAME)
  -- If visit_type_code is passed, reset visit_type_name and validate visit_type_code
  -- If only visit_type_name is passed, the validation and value to id conversion are done in PVT package methods
  IF (p_x_visit_rec.visit_type_code IS NOT NULL) THEN
    p_x_visit_rec.visit_type_name := NULL;
    AHL_VWP_RULES_PVT.Check_Lookup_Name_Or_Id
               (p_lookup_type   => 'AHL_PLANNING_VISIT_TYPE',
                p_lookup_code   => p_x_visit_rec.visit_type_code,
                p_meaning       => null,
                p_check_id_flag => 'Y',
                x_lookup_code   => l_temp_code,
                x_return_status => l_return_status);

    IF (NVL(l_return_status,'x') <> 'S') THEN
      Fnd_Message.SET_NAME('AHL', 'AHL_VWP_TYPE_CODE_NOT_EXISTS');
      Fnd_Msg_Pub.ADD;
      l_valid_flag := false;
    END IF;
  END IF;

  -- Unit (UNIT_HEADER_ID, UNIT_NAME)
  IF (p_x_visit_rec.unit_header_id IS NOT NULL) THEN
    -- Use unit_header_id to populate unit_name since the PVT package methods need it
    OPEN get_unit_name_csr(c_uc_header_id => p_x_visit_rec.unit_header_id);
    FETCH get_unit_name_csr INTO p_x_visit_rec.unit_name;
    --SKPATHAK :: Bug 8216902 ::     :: Validation for unit_header_id added
    IF get_unit_name_csr%NOTFOUND THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(FND_LOG.level_statement, l_full_name, 'Unit does not exist..');
      END IF;
      Fnd_Message.Set_Name('AHL','AHL_UC_API_PARAMETER_INVALID');
      Fnd_Message.Set_Token('NAME', 'UNIT_HEADER_ID');
      Fnd_Message.Set_Token('VALUE', p_x_visit_rec.unit_header_id);
      Fnd_Msg_Pub.ADD;
      CLOSE get_unit_name_csr;
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;
    CLOSE get_unit_name_csr;

  ELSIF (p_x_visit_rec.unit_name IS NOT NULL) THEN
    -- Use unit_name to populate the unit_header_id
    OPEN get_unit_id_csr(c_uc_name => p_x_visit_rec.unit_name);
    FETCH get_unit_id_csr INTO p_x_visit_rec.unit_header_id;
    CLOSE get_unit_id_csr;
  END IF;

  -- Project Template (PROJ_TEMPLATE_ID, PROJ_TEMPLATE_NAME)
  IF (p_x_visit_rec.proj_template_id IS NOT NULL) THEN
    -- Use proj_template_id to populate proj_template_name since the PVT package methods need it
    OPEN get_proj_template_name_csr(c_proj_template_id => p_x_visit_rec.proj_template_id);
    FETCH get_proj_template_name_csr INTO p_x_visit_rec.proj_template_name;
    CLOSE get_proj_template_name_csr;
  END IF;

  -- Priority (PRIORITY_CODE, PRIORITY_VALUE)
  -- If priority_code is passed, reset priority_value and validate priority_code
  -- If only priority_value is passed, the validation and value to id conversion are done in PVT package methods
  IF (p_x_visit_rec.priority_code IS NOT NULL) THEN
    p_x_visit_rec.priority_value := NULL;
    AHL_VWP_RULES_PVT.Check_Lookup_Name_Or_Id
               (p_lookup_type   => 'AHL_VWP_VISIT_PRIORITY',
                p_lookup_code   => p_x_visit_rec.priority_code,
                p_meaning       => null,
                p_check_id_flag => 'Y',
                x_lookup_code   => l_temp_code,
                x_return_status => l_return_status);

    IF (NVL(l_return_status,'x') <> 'S') THEN
      Fnd_Message.SET_NAME('AHL', 'AHL_VWP_PRI_NOT_EXISTS');
      Fnd_Msg_Pub.ADD;
      l_valid_flag := false;
    END IF;
  END IF;

  IF(NOT l_valid_flag) THEN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(FND_LOG.level_procedure, l_full_name || '.end', 'Faced validation errors. Exiting with execution exception.');
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(FND_LOG.level_procedure, l_full_name || '.end', 'Exiting API - Params validated.');
  END IF;
END Validate_And_Prepare_Params;

End AHL_VWP_VISITS_PUB;

/
