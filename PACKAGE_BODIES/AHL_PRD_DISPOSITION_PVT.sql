--------------------------------------------------------
--  DDL for Package Body AHL_PRD_DISPOSITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_DISPOSITION_PVT" AS
/* $Header: AHLVDISB.pls 120.15.12010000.2 2008/12/09 01:42:51 jaramana ship $ */



  G_PKG_NAME         CONSTANT  VARCHAR2(30) := 'AHL_PRD_DISPOSITION_PVT';
  G_APP_NAME         CONSTANT  VARCHAR2(3) := 'AHL';
  G_LOG_PREFIX       CONSTANT  VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.';

  g_module_type VARCHAR2(30)  := NULL;

  G_PART_CHANGE_INSTALL  CONSTANT VARCHAR2(1) := 'I';
  G_PART_CHANGE_REMOVE   CONSTANT VARCHAR2(1) := 'R';
  G_PART_CHANGE_SWAP     CONSTANT VARCHAR2(1) := 'S';

  G_WO_RELEASED_STATUS   CONSTANT VARCHAR2(1) := '3';

------------------------
-- Declare Local Functions --
------------------------
--FUNCTION isPositionEmpty(p_path_position_id IN NUMBER)
--RETURN BOOLEAN;

 FUNCTION get_unit_instance_id(p_workorder_id IN NUMBER) RETURN NUMBER;
 FUNCTION workorder_Editable(p_workorder_id IN NUMBER) RETURN BOOLEAN;
 FUNCTION get_root_instance_id(p_instance_id IN NUMBER) RETURN NUMBER;
 FUNCTION get_issued_quantity(p_disposition_id IN NUMBER) RETURN NUMBER;
 -- Added function by rbhavsar on 09/27/2007 for Bug 6411059
 FUNCTION root_node_in_uc_headers(p_instance_id IN NUMBER) RETURN BOOLEAN;

------------------------
-- Declare Procedures --
------------------------
PROCEDURE create_disposition(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_TRUE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := NULL,
    p_x_disposition_rec     IN OUT NOCOPY  AHL_PRD_DISPOSITION_PVT.disposition_rec_type,
    -- Parameter added by jaramana on Oct 9, 2007 for ER 5883257
    p_mr_asso_tbl           IN             AHL_PRD_NONROUTINE_PVT.MR_Association_tbl_type,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2
);

PROCEDURE update_disposition(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_TRUE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := NULL,
    p_x_disposition_rec     IN OUT NOCOPY  AHL_PRD_DISPOSITION_PVT.disposition_rec_type,
    -- Parameter added by jaramana on Oct 9, 2007 for ER 5883257
    p_mr_asso_tbl           IN             AHL_PRD_NONROUTINE_PVT.MR_Association_tbl_type,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2
);

PROCEDURE CREATE_SR(
    p_init_msg_list               IN  VARCHAR2  := FND_API.G_TRUE,
    p_disposition_rec             IN  AHL_PRD_DISPOSITION_PVT.disposition_rec_type,
    -- Parameter added by jaramana on Oct 9, 2007 for ER 5883257
    p_mr_asso_tbl                 IN  AHL_PRD_NONROUTINE_PVT.MR_Association_tbl_type,
    x_primary_sr_id               OUT NOCOPY  NUMBER,
    x_non_routine_workorder_id	OUT NOCOPY  NUMBER,
    x_return_status               OUT NOCOPY  VARCHAR2,
    x_msg_count                   OUT NOCOPY  NUMBER,
    x_msg_data                    OUT NOCOPY  VARCHAR2
);


PROCEDURE Validate_Disposition_Types (
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_disposition_rec     IN  AHL_PRD_DISPOSITION_PVT.disposition_rec_type);

PROCEDURE Calculate_Status (
    p_disposition_Rec     IN  AHL_PRD_DISPOSITION_PVT.disposition_rec_type,
    x_status_code         OUT  NOCOPY   VARCHAR2);

PROCEDURE convert_values_to_ids(p_x_prd_disposition_rec IN OUT NOCOPY AHL_PRD_DISPOSITION_PVT.disposition_rec_type);

PROCEDURE validate_for_create(p_disposition_rec  IN  AHL_PRD_DISPOSITION_PVT.disposition_rec_type);

PROCEDURE derive_columns(p_x_disposition_rec IN OUT NOCOPY  AHL_PRD_DISPOSITION_PVT.disposition_rec_type);

PROCEDURE validate_workorder(p_workorder_id IN NUMBER);

PROCEDURE validate_path_position(p_path_position_id IN NUMBER);

PROCEDURE validate_collection_id(p_collection_id IN NUMBER);

PROCEDURE validate_item(p_inventory_item_id IN NUMBER, p_organization_id IN NUMBER, p_workorder_id IN NUMBER);

PROCEDURE validate_instance(p_instance_id IN NUMBER, p_workorder_id IN NUMBER, p_path_position_id IN NUMBER,
                            p_part_change_id IN NUMBER);

PROCEDURE validate_wo_operation(p_workorder_id IN NUMBER, p_wo_operation_id IN NUMBER);

-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 12-Dec-2007
-- Modified the API to take disposition quantity as an additional IN parameter.
PROCEDURE validate_part_change(p_part_change_id IN NUMBER, p_disp_instance_id IN NUMBER, p_disp_quantity IN NUMBER);

PROCEDURE validate_Item_Control(p_item_id IN NUMBER, p_org_id IN NUMBER,
                                p_serial_number IN VARCHAR2,
                                p_item_rev_number IN VARCHAR2,
                                p_lot_number IN VARCHAR2);

-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 12-Dec-2007
-- The API update_item_location and its use has been commented out. Its functionality will
-- now be handled in the API AHL_PRD_NONROUTINE_PVT.process_nonroutine_job.
/*
 -- Following Procedure and Function added by jaramana on October 8, 2007 for ER 5903256
PROCEDURE update_item_location(p_workorder_id  IN         NUMBER,
                               p_instance_id   IN         NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2);
*/

FUNCTION Get_NonMWO_WIP_Entity_Id(p_workorder_id IN NUMBER) RETURN NUMBER;


------------------------------------------------------------------
----------- BEGIN DEFINITION OF PROCEDURES AND FUNCTIONS ---------
------------------------------------------------------------------
-- Define procedure create_job_dispositions
-- This API is used to get all default dispositions for a job from its related route
-- and then put them into the dispostion entity.
PROCEDURE create_job_dispositions(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_workorder_id          IN  NUMBER)
IS
  l_api_name       CONSTANT   VARCHAR2(30)   := 'create_job_dispositions';
  l_api_version    CONSTANT   NUMBER         := 1.0;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_relationship_id           NUMBER;
  l_children_no               NUMBER;
  l_route_mtl_req_tbl         ahl_ltp_mtl_req_pvt.route_mtl_req_tbl_type;
  l_unit_instance_id          NUMBER;
  l_installed_inst_id         NUMBER;
  l_serial_number             csi_item_instances.serial_number%TYPE;
  l_lot_number                csi_item_instances.lot_number%TYPE;
  l_inv_item_id               NUMBER;
  l_master_org_id             NUMBER;
  l_last_vld_org_id           NUMBER;
  l_disp_org_id               NUMBER;
  l_lowest_unit_inst_id       NUMBER;
  l_mapping_status            VARCHAR2(30);
  l_disposition_id            NUMBER;
  l_disposition_h_id          NUMBER;
  l_dummy_char                VARCHAR2(1);
  l_dummy_rowid               VARCHAR2(100);
  l_dummy_num                 NUMBER;
  i                           NUMBER;
  CURSOR get_job_attrs IS
/*
SELECT route_id,
           item_instance_id,
           scheduled_start_date,
           job_status_code,
           job_number,
           organization_id
      FROM ahl_workorders_v
     WHERE workorder_id = p_workorder_id;
*/
--AnRaj: Changed query, Perf Bug#4908609,Issue#1
select   WO.route_id route_id,
         NVL(VTS.INSTANCE_ID, VST.ITEM_INSTANCE_ID) item_instance_id,
         WDJ.SCHEDULED_START_DATE scheduled_start_date,
         WO.status_code job_status_code,
         WO.workorder_name job_number,
         VST.ORGANIZATION_ID organization_id
from     AHL_WORKORDERS WO,
         WIP_DISCRETE_JOBS WDJ,
         AHL_VISITS_VL VST,
         AHL_VISIT_TASKS_VL VTS
where    WDJ.WIP_ENTITY_ID = WO.WIP_ENTITY_ID and
         WO.VISIT_TASK_ID = VTS.VISIT_TASK_ID and
         VST.VISIT_ID = VTS.VISIT_ID and
         WO.WORKORDER_ID = p_workorder_id;
l_job_attrs get_job_attrs%ROWTYPE;

  CURSOR get_mtl_req_flags(c_rt_oper_material_id NUMBER) IS
    SELECT --'N' include_flag, Once the column include_flag is added, then replace 'N' with it.
           --Refer enhancement bug 3502592
           exclude_flag
      FROM ahl_rt_oper_materials
     WHERE rt_oper_material_id = c_rt_oper_material_id;
     l_mtl_req_flags get_mtl_req_flags%ROWTYPE;
  CURSOR check_item_org(c_inventory_item_id NUMBER, c_organization_id NUMBER) IS
    SELECT 'X'
      FROM mtl_system_items_kfv
     WHERE inventory_item_id = c_inventory_item_id
       AND organization_id = c_organization_id;
  CURSOR check_unit_instance(c_instance_id NUMBER) IS
    SELECT csi_item_instance_id
      FROM ahl_unit_config_headers
     WHERE csi_item_instance_id = c_instance_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  CURSOR get_sub_unit_instance(c_instance_id NUMBER) IS
    SELECT object_id
      FROM csi_ii_relationships
     WHERE object_id IN (SELECT csi_item_instance_id
                           FROM ahl_unit_config_headers
                          WHERE trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE))
START WITH subject_id = c_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY subject_id = PRIOR object_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  CURSOR get_instance_attrs(c_instance_id NUMBER) IS
    SELECT serial_number,
           lot_number,
           inventory_item_id,
           last_vld_organization_id,
           inv_master_organization_id
      FROM csi_item_instances
     WHERE instance_id = c_instance_id;

BEGIN
  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Standard Start of API savepoint
  SAVEPOINT create_job_dispositions;

  --Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   G_LOG_PREFIX||l_api_name||': Begin API',
                   'At the start of the procedure and p_workorder_id ='||p_workorder_id);
  END IF;

  --Validate the input parameter
  OPEN get_job_attrs;
  FETCH get_job_attrs INTO l_job_attrs;
  IF get_job_attrs%NOTFOUND THEN
    --Comment out this check because the p_workoder_id passed should always be valid
    /*
    FND_MESSAGE.set_name('AHL', 'AHL_PRD_DISP_JOB_ID_INVALID');
    FND_MESSAGE.set_token('JOBID', p_workorder_id);
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    CLOSE get_job_attrs;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    */
    CLOSE get_job_attrs;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     G_LOG_PREFIX||l_api_name||': After normal execution',
                     'Returned but nothing done because the job is not in the view and it might be a master workorder!');
    END IF;
    RETURN;
  ELSIF l_job_attrs.job_status_code IN (4, 12) THEN
    --Complete(4) and Closed(12)
    FND_MESSAGE.set_name('AHL', 'AHL_PRD_DISP_JOB_STS_INVALID');
    FND_MESSAGE.set_token('JOB', l_job_attrs.job_number);
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    CLOSE get_job_attrs;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_job_attrs.item_instance_id IS NULL THEN
    FND_MESSAGE.set_name('AHL', 'AHL_PRD_DISP_JOB_INST_NULL');
    FND_MESSAGE.set_token('JOB', l_job_attrs.job_number);
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    CLOSE get_job_attrs;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_job_attrs.route_id IS NULL THEN
    CLOSE get_job_attrs;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     G_LOG_PREFIX||l_api_name||': After normal execution',
                    'Returned but nothing done because there is no route associated to the job');
    END IF;
    RETURN;
  ELSE
    CLOSE get_job_attrs;
  END IF;

  --Call ahl_ltp_mtl_req_pvt.get_route_mtl_req to get the default dispositions for the job

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   G_LOG_PREFIX||l_api_name||': In normal execution',
                   'Just before calling ahl_ltp_mtl_req_pvt.get_route_mtl_req and p_route_id='||
                   l_job_attrs.route_id||' p_item_instance_id='||l_job_attrs.item_instance_id||
                   ' p_requirement_date='||l_job_attrs.scheduled_start_date);
  END IF;
  ahl_ltp_mtl_req_pvt.get_route_mtl_req(
    p_api_version           => 1.0,
    p_init_msg_list         => FND_API.G_FALSE,
    p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
    x_return_status         => l_return_status,
    x_msg_count             => l_msg_count,
    x_msg_data              => l_msg_data,
    p_route_id              => l_job_attrs.route_id,
    p_mr_route_id           => NULL,
    p_item_instance_id      => l_job_attrs.item_instance_id,
    p_requirement_date      => l_job_attrs.scheduled_start_date,
    p_request_type          => 'PLANNED',
    x_route_mtl_req_tbl     => l_route_mtl_req_tbl);

  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  ----dbms_output.put_line('After calling ltp API, the count='||l_route_mtl_req_tbl.COUNT);
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   G_LOG_PREFIX||l_api_name||': In normal execution',
	           'After calling LTP API and x_return_status='||l_return_status||
                   ' The count of the returned records = '||l_route_mtl_req_tbl.COUNT);
  END IF;

  IF l_route_mtl_req_tbl.COUNT > 0 THEN
    FOR i IN l_route_mtl_req_tbl.FIRST..l_route_mtl_req_tbl.LAST LOOP
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       G_LOG_PREFIX||l_api_name||': In normal execution',
                       'In mtl_req_tbl loop and i='||i||' and count = '||l_route_mtl_req_tbl.COUNT);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       G_LOG_PREFIX||l_api_name,
                       'For index ' || i || ', rt_oper_material_id = '||
                       l_route_mtl_req_tbl(i).rt_oper_material_id||', position_path_id = '||
                       l_route_mtl_req_tbl(i).position_path_id||', item_group_id = '||
                       l_route_mtl_req_tbl(i).item_group_id||', inventory_item_id = '||
                       l_route_mtl_req_tbl(i).inventory_item_id);
      END IF;
      OPEN get_mtl_req_flags(l_route_mtl_req_tbl(i).rt_oper_material_id);
      FETCH get_mtl_req_flags INTO l_mtl_req_flags;
      ----dbms_output.put_line('In loop '|| i||' and rt_oper_material_id='||l_route_mtl_req_tbl(i).rt_oper_material_id);
      IF get_mtl_req_flags%NOTFOUND THEN
        FND_MESSAGE.set_name('AHL', 'AHL_PRD_DISP_MTL_REQ_ID_INV');
        FND_MESSAGE.set_token('REQID', l_route_mtl_req_tbl(i).rt_oper_material_id);
        FND_MSG_PUB.add;
        CLOSE get_mtl_req_flags;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      CLOSE get_mtl_req_flags;
      --dbms_output.put_line('Before check flag');
      --Filter out the record which should not be included
      IF (l_mtl_req_flags.exclude_flag = 'Y') THEN
        l_route_mtl_req_tbl.DELETE(i);
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         G_LOG_PREFIX||l_api_name||': In normal execution',
	                 'The disposition record is deleted and i='||i||' because the exclude_flag=Y');
        END IF;
        ----dbms_output.put_line('Yes it is deleted '||i);
      END IF;
      --This default logic is per Jay's requirement
      ----dbms_output.put_line('Before apply Jay''s logic');
      IF l_route_mtl_req_tbl.EXISTS(i) THEN
        l_inv_item_id := l_route_mtl_req_tbl(i).inventory_item_id;
        IF l_route_mtl_req_tbl(i).position_path_id IS NOT NULL THEN
          l_route_mtl_req_tbl(i).item_group_id := NULL;
          l_inv_item_id := NULL;
        ELSIF l_route_mtl_req_tbl(i).item_group_id IS NOT NULL THEN
          l_inv_item_id := NULL;
          -- Added by jaramana on April 26, 2005 to fix the issue
          -- where we are unable to update the Disposition for a Item Group with
          -- a Revision Controlled Item when created from Push To Production
          l_disp_org_id := l_job_attrs.organization_id;
        ELSIF l_route_mtl_req_tbl(i).inventory_item_id IS NOT NULL THEN
          OPEN check_item_org(l_route_mtl_req_tbl(i).inventory_item_id,
                              l_job_attrs.organization_id);
          FETCH check_item_org INTO l_dummy_char;
          IF check_item_org%NOTFOUND THEN
            IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
                             G_LOG_PREFIX||l_api_name||': In normal execution',
			     'inventory_item_id = '||l_route_mtl_req_tbl(i).inventory_item_id||
                             'job_organization_id = '||l_job_attrs.organization_id||
                             'The item does not exist in the organization of the job and this disposition record will be ignored.');
            END IF;
            l_route_mtl_req_tbl.DELETE(i);
          ELSE
            --In this case, the column organization_id in dispositions table will be the same as
            --the job organization_id
            l_disp_org_id := l_job_attrs.organization_id;
          END IF;
          CLOSE check_item_org;
        END IF;
      END IF;
      --When position_path_id is not null, we should derive the instance attributes if
      --the position is not empty
      ----dbms_output.put_line('position_path_id='||l_route_mtl_req_tbl(i).position_path_id);
      IF (l_route_mtl_req_tbl.EXISTS(i) AND
          l_route_mtl_req_tbl(i).position_path_id IS NOT NULL) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         G_LOG_PREFIX||l_api_name||': In normal execution',
	                 'Exists and position_path_id is not null');
        END IF;
        ----dbms_output.put_line('Yes exists');
        --Check the job instance is a unit instance?
        OPEN check_unit_instance(l_job_attrs.item_instance_id);
        FETCH check_unit_instance INTO l_unit_instance_id;
        IF check_unit_instance%NOTFOUND THEN
          CLOSE check_unit_instance;
          --The job instance is not a unit instance but a component instance, then get its
          --lowest unit instance. Assuming the result of the hierarchy query is what we expected
          --that the lowest sub unit instance_id will be the first one to be displayed.
          OPEN get_sub_unit_instance(l_job_attrs.item_instance_id);
          FETCH get_sub_unit_instance INTO l_unit_instance_id;
          IF get_sub_unit_instance%NOTFOUND THEN
            FND_MESSAGE.set_name('AHL', 'AHL_PRD_DISP_JOB_INST_INVALID');
            FND_MESSAGE.set_token('INSTANCE', l_job_attrs.item_instance_id);
            FND_MESSAGE.set_token('JOB', l_job_attrs.job_number);
            FND_MSG_PUB.add;
            CLOSE get_sub_unit_instance;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSE
            CLOSE get_sub_unit_instance;
          END IF;
        ELSE
          CLOSE check_unit_instance;
        END IF;
        --Call Path Position API to get the installed instance if the given unit has a
        --matching path_position_id
        ----dbms_output.put_line('Before calling path API');
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                        G_LOG_PREFIX||l_api_name||': in normal execution',
	                'Before calling mc path position API and p_position_id ='||
                        l_route_mtl_req_tbl(i).position_path_id||' p_csi_item_instance_id='||
                        l_unit_instance_id);
        END IF;
        AHL_MC_PATH_POSITION_PVT.get_pos_instance(
                                 p_api_version          => 1.0,
                                 p_init_msg_list        => FND_API.G_FALSE,
                                 p_commit               => FND_API.G_FALSE,
                                 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
                                 x_return_status        => l_return_status,
                                 x_msg_count            => l_msg_count,
                                 x_msg_data             => l_msg_data,
                                 p_position_id          => l_route_mtl_req_tbl(i).position_path_id,
                                 p_csi_item_instance_id => l_unit_instance_id,
                                 x_item_instance_id     => l_installed_inst_id,
                                 x_lowest_uc_csi_id     => l_lowest_unit_inst_id,
                                 x_mapping_status       => l_mapping_status);

        IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
                         G_LOG_PREFIX||l_api_name||': Within the procedure ',
                         'Returned from call to AHL_MC_PATH_POSITION_PVT.get_pos_instance:' ||
                         ' x_return_status = ' || l_return_status ||
                         ', x_mapping_status = ' || l_mapping_status ||
                         ', x_item_instance_id = ' || l_installed_inst_id ||
                         ', x_lowest_uc_csi_id = ' || l_lowest_unit_inst_id);
        END IF;

        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (l_mapping_status = 'NA') THEN
          FND_MESSAGE.set_name('AHL', 'AHL_PRD_DISP_PATH_POS_INV');
          FND_MESSAGE.set_token('POSITION', l_route_mtl_req_tbl(i).position_path_id);
          FND_MESSAGE.set_token('INSTANCE', l_unit_instance_id);
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          -- Position does not apply to current unit
        ELSIF (l_mapping_status = 'EMPTY') THEN
          l_installed_inst_id := NULL;
          l_serial_number := NULL;
          l_lot_number := NULL;
          l_inv_item_id := NULL;
          l_last_vld_org_id := NULL;
          l_master_org_id := NULL;
          l_disp_org_id := NULL;
        ELSIF (l_mapping_status = 'MATCH') THEN
          OPEN get_instance_attrs(l_installed_inst_id);
          FETCH get_instance_attrs INTO
                l_serial_number,
                l_lot_number,
                l_inv_item_id,
                l_last_vld_org_id,
                l_master_org_id;
          CLOSE get_instance_attrs;
          --Check to see whether the item of the instance exists in the job's organization,
          --if not, then ignore this record
          OPEN check_item_org(l_inv_item_id, l_job_attrs.organization_id);
          FETCH check_item_org INTO l_dummy_char;
          IF check_item_org%NOTFOUND THEN
            IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
                             G_LOG_PREFIX||l_api_name||': In normal execution',
			     'inventory_item_id = '||l_route_mtl_req_tbl(i).inventory_item_id||
                             'instance_id = '||l_installed_inst_id||
                             'job_organization_id = '||l_job_attrs.organization_id||
                             'The item of the instance does not exsit in the organization of the job and this disposition record will be ignored');
            END IF;
            l_route_mtl_req_tbl.DELETE(i);
          ELSE
            --In this case we need to ensure that the organization_id in
            --dispositions table should be derived from the instance's organization
            l_disp_org_id := nvl(l_last_vld_org_id, l_master_org_id);
          END IF;
          CLOSE check_item_org;
        END IF;
      END IF;
      --dbms_output.put_line('Before calling table handler API');
      --Insert the record into the disposition entity table
      IF (l_route_mtl_req_tbl.EXISTS(i)) THEN
        BEGIN
          SELECT ahl_prd_dispositions_b_s.NEXTVAL
          INTO l_disposition_id
          FROM dual;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           G_LOG_PREFIX||l_api_name||': Before calling table handler',
                           'disposition_id = '||l_disposition_id);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           G_LOG_PREFIX||l_api_name||': Before calling table handler',
                           'workorder_id = '||p_workorder_id);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           G_LOG_PREFIX||l_api_name||': Before calling table handler',
                           'path_position_id = '||l_route_mtl_req_tbl(i).position_path_id);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           G_LOG_PREFIX||l_api_name||': Before calling table handler',
                           'inventory_item_id = '||l_route_mtl_req_tbl(i).inventory_item_id);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           G_LOG_PREFIX||l_api_name||': Before calling table handler',
                           'inv_master_org_id = '||l_route_mtl_req_tbl(i).inv_master_org_id);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           G_LOG_PREFIX||l_api_name||': Before calling table handler',
                           'item_group_id= '||l_route_mtl_req_tbl(i).item_group_id);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           G_LOG_PREFIX||l_api_name||': Before calling table handler',
                           'l_installed_inst_id='||l_installed_inst_id);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           G_LOG_PREFIX||l_api_name||': Before calling table handler',
                           'l_serial_number='||l_serial_number);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           G_LOG_PREFIX||l_api_name||': Before calling table handler',
                           'l_lot_number='||l_lot_number);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           G_LOG_PREFIX||l_api_name||': Before calling table handler',
                           'quantity='||l_route_mtl_req_tbl(i).quantity);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           G_LOG_PREFIX||l_api_name||': Before calling table handler',
                           'uom_code='||l_route_mtl_req_tbl(i).uom_code);
          END IF;

          AHL_PRD_DISPOSITIONS_PKG.INSERT_ROW(
            X_ROWID => l_dummy_rowid,
            X_DISPOSITION_ID => l_disposition_id,
            X_OBJECT_VERSION_NUMBER => 1.0,
            X_WORKORDER_ID => p_workorder_id,
            X_PART_CHANGE_ID => NULL,
            X_PATH_POSITION_ID => l_route_mtl_req_tbl(i).position_path_id,
            X_INVENTORY_ITEM_ID => l_inv_item_id,
            X_ORGANIZATION_ID => l_disp_org_id,
            X_ITEM_GROUP_ID => l_route_mtl_req_tbl(i).item_group_id,
            X_CONDITION_ID => NULL,
            X_INSTANCE_ID => l_installed_inst_id,
            X_SERIAL_NUMBER => l_serial_number,
            X_LOT_NUMBER => l_lot_number,
            X_IMMEDIATE_DISPOSITION_CODE => NULL,
            X_SECONDARY_DISPOSITION_CODE => NULL,
            X_STATUS_CODE => NULL,
            X_QUANTITY => l_route_mtl_req_tbl(i).quantity,
            X_UOM => l_route_mtl_req_tbl(i).uom_code,
            X_COLLECTION_ID => NULL,
            X_PRIMARY_SERVICE_REQUEST_ID => NULL,
            X_NON_ROUTINE_WORKORDER_ID => NULL,
            X_WO_OPERATION_ID => NULL,
            X_ITEM_REVISION => NULL,
            --We may need to get the item_revision from ahl_rt_oper_materials later
            X_ATTRIBUTE_CATEGORY => NULL,
            X_ATTRIBUTE1 => NULL,
            X_ATTRIBUTE2 => NULL,
            X_ATTRIBUTE3 => NULL,
            X_ATTRIBUTE4 => NULL,
            X_ATTRIBUTE5 => NULL,
            X_ATTRIBUTE6 => NULL,
            X_ATTRIBUTE7 => NULL,
            X_ATTRIBUTE8 => NULL,
            X_ATTRIBUTE9 => NULL,
            X_ATTRIBUTE10 => NULL,
            X_ATTRIBUTE11 => NULL,
            X_ATTRIBUTE12 => NULL,
            X_ATTRIBUTE13 => NULL,
            X_ATTRIBUTE14 => NULL,
            X_ATTRIBUTE15 => NULL,
            X_COMMENTS => NULL,
            X_CREATION_DATE => SYSDATE,
            X_CREATED_BY => FND_GLOBAL.user_id,
            X_LAST_UPDATE_DATE => SYSDATE,
            X_LAST_UPDATED_BY => FND_GLOBAL.user_id,
            X_LAST_UPDATE_LOGIN => FND_GLOBAL.login_id);

        --Insert the same record into the Disposition History table as well
          SELECT AHL_PRD_DISPOSITIONS_B_H_S.NEXTVAL
            INTO l_disposition_h_id
            FROM dual;
          AHL_PRD_DISPOSITIONS_B_H_PKG.INSERT_ROW(
            X_ROWID => l_dummy_rowid,
            X_DISPOSITION_H_ID => l_disposition_h_id,
            X_DISPOSITION_ID => l_disposition_id,
            X_OBJECT_VERSION_NUMBER => 1.0,
            X_WORKORDER_ID => p_workorder_id,
            X_PART_CHANGE_ID => NULL,
            X_PATH_POSITION_ID => l_route_mtl_req_tbl(i).position_path_id,
            X_INVENTORY_ITEM_ID => l_inv_item_id,
            X_ORGANIZATION_ID => l_disp_org_id,
            X_ITEM_GROUP_ID => l_route_mtl_req_tbl(i).item_group_id,
            X_CONDITION_ID => NULL,
            X_INSTANCE_ID => l_installed_inst_id,
            X_SERIAL_NUMBER => l_serial_number,
            X_LOT_NUMBER => l_lot_number,
            X_IMMEDIATE_DISPOSITION_CODE => NULL,
            X_SECONDARY_DISPOSITION_CODE => NULL,
            X_STATUS_CODE => NULL,
            X_QUANTITY => l_route_mtl_req_tbl(i).quantity,
            X_UOM => l_route_mtl_req_tbl(i).uom_code,
            X_COLLECTION_ID => NULL,
            X_PRIMARY_SERVICE_REQUEST_ID => NULL,
            X_NON_ROUTINE_WORKORDER_ID => NULL,
            X_WO_OPERATION_ID => NULL,
            X_ITEM_REVISION => NULL,
            --We may need to get the item_revision from ahl_rt_oper_materials later
            X_ATTRIBUTE_CATEGORY => NULL,
            X_ATTRIBUTE1 => NULL,
            X_ATTRIBUTE2 => NULL,
            X_ATTRIBUTE3 => NULL,
            X_ATTRIBUTE4 => NULL,
            X_ATTRIBUTE5 => NULL,
            X_ATTRIBUTE6 => NULL,
            X_ATTRIBUTE7 => NULL,
            X_ATTRIBUTE8 => NULL,
            X_ATTRIBUTE9 => NULL,
            X_ATTRIBUTE10 => NULL,
            X_ATTRIBUTE11 => NULL,
            X_ATTRIBUTE12 => NULL,
            X_ATTRIBUTE13 => NULL,
            X_ATTRIBUTE14 => NULL,
            X_ATTRIBUTE15 => NULL,
            X_COMMENTS => NULL,
            X_CREATION_DATE => SYSDATE,
            X_CREATED_BY => FND_GLOBAL.user_id,
            X_LAST_UPDATE_DATE => SYSDATE,
            X_LAST_UPDATED_BY => FND_GLOBAL.user_id,
            X_LAST_UPDATE_LOGIN => FND_GLOBAL.login_id);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN --This +100 is raised explicitly in INSERT_ROW
              FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INSERT_FAILED' );
              FND_MSG_PUB.add;
            WHEN OTHERS THEN
              IF ( SQLCODE = -1 ) THEN --DUP_VAL_ON_INDEX
                FND_MESSAGE.set_name( 'AHL', 'AHL_COM_DUPLICATE_RECORD' );
                FND_MSG_PUB.add;
              ELSE
                RAISE;
              END IF;
        END;
      END IF;
      --To clear the local variable, otherwise it carries the previous one if the current one
      --should be null
      l_installed_inst_id := NULL;
      l_serial_number := NULL;
      l_lot_number := NULL;
      l_master_org_id := NULL;
      l_last_vld_org_id := NULL;
      l_disp_org_id := NULL;
      l_inv_item_id := NULL;
    END LOOP;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   G_LOG_PREFIX||l_api_name||': After normal execution',
                   'At the end of the procedure');
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Perform the Commit (if requested)
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  -- Count and Get messages (optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_job_dispositions;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_job_dispositions;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO create_job_dispositions;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

END create_job_dispositions;

------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : process_disposition
--  Type              : Private
--  Function          : create or update a disposition based on the input from disposition record.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  p_module_type                       IN      VARCHAR2               Required.
--
--      This parameter indicates the front-end form interface. The default value is 'JSP'. If the value
--      is JSP, then this API clears out all id columns and validations are done using the values based
--      on which the Id's are populated.
--
--  process_disposition Parameters:
--
--       p_x_disposition_rec     IN OUT NOCOPY  AHL_PRD_DISPOSITION_PVT.disposition_rec_type    Required
--         Disposition record
--       p_mr_asso_tbl           IN             AHL_PRD_NONROUTINE_PVT.MR_Association_tbl_type  Required
--         Table of MRs associated to the Disposition's Primary NR
--         (Parameter added by jaramana on Oct 9, 2007 for ER 5883257)
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------------------------

PROCEDURE process_disposition(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_TRUE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := NULL,
    p_x_disposition_rec     IN OUT NOCOPY  AHL_PRD_DISPOSITION_PVT.disposition_rec_type,
    -- Parameter added by jaramana on Oct 9, 2007 for ER 5883257
    p_mr_asso_tbl           IN             AHL_PRD_NONROUTINE_PVT.MR_Association_tbl_type,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2) IS


  l_api_version      CONSTANT NUMBER := 1.0;
  l_api_name         CONSTANT VARCHAR2(30) := 'process_disposition';
  l_return_status  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_init_msg_list  VARCHAR2(1)  := FND_API.G_FALSE;
  l_commit         VARCHAR2(1)  := FND_API.G_FALSE;
  L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || 'process_disposition';
  l_prev_err_count      NUMBER;

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT process_disposition_pvt;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

--dbms_output.put_line(SubStr('Begin  Process_Disposition', 1, 255));
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version,l_api_name, G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean( p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
    --dbms_output.put_line(SubStr('Current MSG Count: ' || TO_CHAR(FND_MSG_PUB.count_msg), 1, 255));
  END IF;
  /* Begin Fix for 4071599 on Dec 22, 2004 by JR */
  l_prev_err_count := NVL(FND_MSG_PUB.count_msg,0);
  /* End Fix for 4071599 on Dec 22, 2004 by JR */

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  g_module_type := p_module_type;

  -- Begin Processing HERE

  IF p_x_disposition_rec.operation_flag = G_OP_CREATE THEN
     create_disposition(   p_api_version,
                           l_init_msg_list,
                           l_commit,
                           p_validation_level,
                           p_module_type ,
                           p_x_disposition_rec,
                           p_mr_asso_tbl, -- Parameter added by jaramana on Oct 9, 2007 for ER 5883257
                           x_return_status ,
                           x_msg_count,
                           x_msg_data);

  ELSIF p_x_disposition_rec.operation_flag = G_OP_UPDATE THEN
     update_disposition( p_api_version,
                           l_init_msg_list,
                           l_commit,
                           p_validation_level,
                           p_module_type ,
                           p_x_disposition_rec,
                           p_mr_asso_tbl, -- Parameter added by jaramana on Oct 9, 2007 for ER 5883257
                           x_return_status ,
                           x_msg_count,
                           x_msg_data);

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'After calling update_dispositon- x_msg_data: ' || x_msg_data
                  || ' x_msg_count: ' || x_msg_count);
     END IF;
  END IF;

 -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;


  IF  x_msg_count - l_prev_err_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
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

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
  END IF;
--dbms_output.put_line(SubStr('End  Process_Disposition', 1, 255));

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to process_disposition_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, L_DEBUG_KEY, 'Execution Exception: ' || x_msg_data);
    END IF;
    --dbms_output.put_line(SubStr('Execution Exception', 1, 255));


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to process_disposition_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, 'Unexpected Exception: ' || x_msg_data);
  END IF;
 --dbms_output.put_line(SubStr('Unexpected Exception', 1, 255));

 WHEN OTHERS THEN
    Rollback to process_disposition_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, 'Other Exception: ' || x_msg_data);
    END IF;


    --dbms_output.put_line(SubStr('Other Exception', 1, 255));
END process_disposition;


--------------CREATE_DISPOSITION---------------------------------------------------

PROCEDURE create_disposition(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_TRUE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := NULL,
    p_x_disposition_rec     IN OUT NOCOPY  AHL_PRD_DISPOSITION_PVT.disposition_rec_type,
    -- Parameter added by jaramana on Oct 9, 2007 for ER 5883257
    p_mr_asso_tbl           IN             AHL_PRD_NONROUTINE_PVT.MR_Association_tbl_type,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2
) IS

-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 12-Dec-2007
-- Cursor to check whether the disposition item is serialized or not.
CURSOR chk_non_serialized_csr(p_inventory_item_id NUMBER, p_item_org_id NUMBER) IS
       SELECT 'X'
       FROM   mtl_system_items_b
       WHERE  inventory_item_id          = p_inventory_item_id
       AND    organization_id            = p_item_org_id
       AND    serial_number_control_code = 1;

-- SATHAPLI::FP OGMA Issue# 86 - Automatic Material Return, 27-Dec-2007
-- Cursor to fetch the part change details.
CURSOR part_change_dtls_csr(p_part_change_id IN NUMBER) IS
       SELECT removed_instance_id, part_change_type
       FROM   ahl_part_changes
       WHERE   part_change_id = p_part_change_id;

l_disposition_h_id   NUMBER;
l_dummy_char VARCHAR(30);
l_primary_service_request_id NUMBER;
l_non_routine_workorder_id NUMBER;
l_calculated_status VARCHAR(30);
l_return_status VARCHAR(30);

l_removed_instance_id NUMBER;
l_part_change_type    VARCHAR2(1);
l_ahl_mtltxn_rec      AHL_PRD_MTLTXN_PVT.Ahl_Mtltxn_Rec_Type;
l_dummy               VARCHAR2(1);

l_msg_count NUMBER;
L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || 'create_disposition';

BEGIN



  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  --dbms_output.put_line(SubStr('Begin  Create_Disposition', 1, 255));

   IF (p_module_type = 'JSP') THEN
    IF (p_x_disposition_rec.WORKORDER_ID  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.WORKORDER_ID  := null;
    END IF;
    IF (p_x_disposition_rec.PART_CHANGE_ID  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.PART_CHANGE_ID  := null;
    END IF;
    IF (p_x_disposition_rec.PATH_POSITION_ID  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.PATH_POSITION_ID  := null;
    END IF;
    IF (p_x_disposition_rec.INVENTORY_ITEM_ID  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.INVENTORY_ITEM_ID  := null;
    END IF;
    IF (p_x_disposition_rec.ITEM_GROUP_ID  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.ITEM_GROUP_ID  := null;
    END IF;
    IF (p_x_disposition_rec.CONDITION_ID  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.CONDITION_ID  := null;
    END IF;
    IF (p_x_disposition_rec.INSTANCE_ID  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.INSTANCE_ID  := null;
    END IF;
    IF (p_x_disposition_rec.SERIAL_NUMBER  = FND_API.G_MISS_CHAR) THEN
        p_x_disposition_rec.SERIAL_NUMBER  := null;
    END IF;
    IF (p_x_disposition_rec.LOT_NUMBER  = FND_API.G_MISS_CHAR) THEN
        p_x_disposition_rec.LOT_NUMBER  := null;
    END IF;
    IF (p_x_disposition_rec.IMMEDIATE_DISPOSITION_CODE  = FND_API.G_MISS_CHAR) THEN
        p_x_disposition_rec.IMMEDIATE_DISPOSITION_CODE  := null;
    END IF;
    IF (p_x_disposition_rec.SECONDARY_DISPOSITION_CODE  = FND_API.G_MISS_CHAR) THEN
        p_x_disposition_rec.SECONDARY_DISPOSITION_CODE  := null;
    END IF;
    IF (p_x_disposition_rec.STATUS_CODE  = FND_API.G_MISS_CHAR) THEN
        p_x_disposition_rec.STATUS_CODE  := null;
    END IF;
    IF (p_x_disposition_rec.QUANTITY  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.QUANTITY  := null;
    END IF;
    IF (p_x_disposition_rec.UOM  = FND_API.G_MISS_CHAR) THEN
        p_x_disposition_rec.UOM  := null;
    END IF;
    IF (p_x_disposition_rec.COLLECTION_ID  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.COLLECTION_ID  := null;
    END IF;
    IF (p_x_disposition_rec.PRIMARY_SERVICE_REQUEST_ID  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.PRIMARY_SERVICE_REQUEST_ID  := null;
    END IF;
    IF (p_x_disposition_rec.NON_ROUTINE_WORKORDER_ID  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.NON_ROUTINE_WORKORDER_ID  := null;
    END IF;
    IF (p_x_disposition_rec.WO_OPERATION_ID  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.WO_OPERATION_ID  := null;
    END IF;
    IF (p_x_disposition_rec.ITEM_REVISION  = FND_API.G_MISS_CHAR) THEN
        p_x_disposition_rec.ITEM_REVISION  := null;
    END IF;
  END IF;


  IF p_validation_level = FND_API.G_VALID_LEVEL_FULL  THEN
    convert_values_to_ids(p_x_disposition_rec);
  END IF;
-- Derive Columns from other know columns

  derive_columns(p_x_disposition_rec);

  validate_for_create(p_x_disposition_rec);

  --Validate Disposition Types
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Before validate disposition_type');
  END IF;
   --dbms_output.put_line(SubStr('Before validate disposition type ', 1, 255));
   Validate_Disposition_Types (
      --  p_api_version  =>   p_api_version,
     --   p_init_msg_list =>  p_init_msg_list,
     --   p_commit =>   p_commit,
     --   p_validation_level  => p_validation_level,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data ,
        p_disposition_rec  =>  p_x_disposition_rec);

  --Calculate Status
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Before calculate_status');
  END IF;
   --dbms_output.put_line(SubStr('Before calculate status', 1, 255));
   Calculate_Status (
    p_disposition_Rec   => p_x_disposition_Rec,
    x_status_code       => l_calculated_status);

    p_x_disposition_Rec.status_code := l_calculated_status;

    --prepare for insert
    Select AHL_PRD_DISPOSITIONS_B_S.NEXTVAL into p_x_disposition_rec.disposition_id from dual;
    --setting object version number for create
    p_x_disposition_rec.object_version_number := 1;
    --setting up user/create/update information
    p_x_disposition_rec.created_by := fnd_global.user_id;
    p_x_disposition_rec.creation_date := SYSDATE;
    p_x_disposition_rec.last_updated_by := fnd_global.user_id;
    p_x_disposition_rec.last_update_date := SYSDATE;
    p_x_disposition_rec.last_update_login := fnd_global.login_id ;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Before Insert_Row');
  END IF;
   --dbms_output.put_line(SubStr('Create_Disposition -  Before Insert_Row', 1, 255));
  AHL_PRD_DISPOSITIONS_PKG.INSERT_ROW(
  		x_rowid                => l_dummy_char,
  		x_disposition_id       =>  p_x_disposition_rec.disposition_id,
  		x_object_version_number   =>  p_x_disposition_rec.object_version_number,
  		x_workorder_id         =>  p_x_disposition_rec.workorder_id ,
  		x_part_change_id       =>  p_x_disposition_rec.part_change_id,
  		x_path_position_id     =>  p_x_disposition_rec.path_position_id,
  		x_inventory_item_id    =>  p_x_disposition_rec.inventory_item_id,
  		x_organization_id      =>  p_x_disposition_rec.item_org_id,
  		x_item_group_id        =>  p_x_disposition_rec.item_group_id,
  		x_condition_id         =>  p_x_disposition_rec.condition_id,
  		x_instance_id          =>  p_x_disposition_rec.instance_id,
  		x_serial_number        =>  p_x_disposition_rec.serial_number,
  		x_lot_number           =>  p_x_disposition_rec.lot_number,
  		x_immediate_disposition_code  =>  p_x_disposition_rec.immediate_disposition_code ,
  		x_secondary_disposition_code  =>  p_x_disposition_rec.secondary_disposition_code,
  		x_status_code          =>  p_x_disposition_rec.status_code,
  		x_quantity             =>  p_x_disposition_rec.quantity,
  		x_uom                  =>  p_x_disposition_rec.uom,
  		x_collection_id        =>  p_x_disposition_rec.collection_id,
  		x_primary_service_request_id   =>  p_x_disposition_rec.primary_service_request_id ,
  		x_non_routine_workorder_id     =>  p_x_disposition_rec.non_routine_workorder_id,
  		x_wo_operation_id              => p_x_disposition_rec.wo_operation_id,
  		x_item_revision                => p_x_disposition_rec.item_revision,
  		x_attribute_category   =>  p_x_disposition_rec.attribute_category,
  		x_attribute1           =>  p_x_disposition_rec.attribute1,
  		x_attribute2           =>  p_x_disposition_rec.attribute2,
  		x_attribute3           =>  p_x_disposition_rec.attribute3,
  		x_attribute4           =>  p_x_disposition_rec.attribute4,
  		x_attribute5           =>  p_x_disposition_rec.attribute5,
  		x_attribute6           =>  p_x_disposition_rec.attribute6,
  		x_attribute7           =>  p_x_disposition_rec.attribute7,
  		x_attribute8           =>  p_x_disposition_rec.attribute8,
  		x_attribute9           =>  p_x_disposition_rec.attribute9,
  		x_attribute10          =>  p_x_disposition_rec.attribute10,
  		x_attribute11          =>  p_x_disposition_rec.attribute11,
  		x_attribute12          =>  p_x_disposition_rec.attribute12,
  		x_attribute13          =>  p_x_disposition_rec.attribute13,
  		x_attribute14          =>  p_x_disposition_rec.attribute14,
  		x_attribute15          =>  p_x_disposition_rec.attribute15,
  		x_comments             =>  p_x_disposition_rec.comments,
  		x_creation_date        =>  p_x_disposition_rec.creation_date ,
  		x_created_by           =>  p_x_disposition_rec.created_by,
  		x_last_update_date     =>  p_x_disposition_rec.last_update_date,
  		x_last_updated_by      =>  p_x_disposition_rec.last_updated_by,
  		x_last_update_login    =>  p_x_disposition_rec.last_update_login
  );
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'AfterInsert_Row');
  END IF;

  -- create service request and non-routine job
  -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 12-Dec-2007
  -- Add a check for the create_work_order_option attribute too.
  IF p_x_disposition_rec.primary_service_request_id IS NULL AND p_x_disposition_rec.instance_id IS NOT NULL   --  ITEM is tracked
     AND(p_x_disposition_rec.condition_id = fnd_profile.value('AHL_MTL_MAT_STATUS_UNSERVICABLE') OR
         p_x_disposition_rec.condition_id = fnd_profile.value('AHL_MTL_MAT_STATUS_MRB'))
     AND(p_x_disposition_rec.create_work_order_option <> 'CREATE_SR_NO') THEN

    -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 12-Dec-2007
    -- The option CREATE_WO_NO is not valid for non-serialized items. If chosen, throw an error.
    IF (p_x_disposition_rec.create_work_order_option = 'CREATE_WO_NO') THEN
      OPEN chk_non_serialized_csr(p_x_disposition_rec.inventory_item_id, p_x_disposition_rec.item_org_id);
      FETCH chk_non_serialized_csr INTO l_dummy;
      IF (chk_non_serialized_csr%FOUND) THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DIS_NON_SRL_SR');
        FND_MSG_PUB.ADD;
      END IF;
      CLOSE chk_non_serialized_csr;
    END IF;

    -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    Create_SR (p_init_msg_list => FND_API.G_FALSE,
               p_disposition_rec => p_x_disposition_rec,
               -- Parameter added by jaramana on Oct 9, 2007 for ER 5883257
               p_mr_asso_tbl    => p_mr_asso_tbl,
               x_primary_sr_id => l_primary_service_request_id,
               x_non_routine_workorder_id =>  l_non_routine_workorder_id,
               x_return_status  => x_return_status,
               x_msg_count      => x_msg_count,
               x_msg_data       => x_msg_data);
    --reinitialize message stack and ignore any warning message
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      FND_MSG_PUB.Initialize;
    END IF;

    p_x_disposition_rec.primary_service_request_id := l_primary_service_request_id;
    p_x_disposition_rec.non_routine_workorder_id := l_non_routine_workorder_id;

    --update the just modified field without changing object version number.
    UPDATE AHL_PRD_DISPOSITIONS_B SET primary_service_request_id = p_x_disposition_rec.primary_service_request_id,
                                      non_routine_workorder_id  = p_x_disposition_rec.non_routine_workorder_id,
                                      status_code = p_x_disposition_rec.status_code
                                WHERE disposition_id =  p_x_disposition_rec.disposition_id;
  END IF;

    Select AHL_PRD_DISPOSITIONS_B_H_S.NEXTVAL into l_disposition_h_id from dual;
    AHL_PRD_DISPOSITIONS_B_H_PKG.INSERT_ROW(
  		x_rowid                =>  l_dummy_char,
		x_disposition_h_id     =>  l_disposition_h_id,
  		x_disposition_id       =>  p_x_disposition_rec.disposition_id,
  		x_object_version_number   =>  p_x_disposition_rec.object_version_number,
  		x_workorder_id         =>  p_x_disposition_rec.workorder_id ,
  		x_part_change_id       =>  p_x_disposition_rec.part_change_id,
  		x_path_position_id     =>  p_x_disposition_rec.path_position_id,
  		x_inventory_item_id    =>  p_x_disposition_rec.inventory_item_id,
  		x_organization_id      =>  p_x_disposition_rec.item_org_id,
  		x_item_group_id        =>  p_x_disposition_rec.item_group_id,
  		x_condition_id         =>  p_x_disposition_rec.condition_id,
  		x_instance_id          => p_x_disposition_rec.instance_id,
  		x_serial_number        =>  p_x_disposition_rec.serial_number,
  		x_lot_number           =>  p_x_disposition_rec.lot_number,
  		x_immediate_disposition_code  =>  p_x_disposition_rec.immediate_disposition_code ,
  		x_secondary_disposition_code  =>  p_x_disposition_rec.secondary_disposition_code,
  		x_status_code          =>  p_x_disposition_rec.status_code,
  		x_quantity             =>  p_x_disposition_rec.quantity,
  		x_uom                  =>  p_x_disposition_rec.uom,
  		x_collection_id        =>  p_x_disposition_rec.collection_id,
  		x_primary_service_request_id   =>  p_x_disposition_rec.primary_service_request_id ,
  		x_non_routine_workorder_id     =>  p_x_disposition_rec.non_routine_workorder_id,
  		x_wo_operation_id              => p_x_disposition_rec.wo_operation_id,
  		x_item_revision                => p_x_disposition_rec.item_revision,
  		x_attribute_category   =>  p_x_disposition_rec.attribute_category,
  		x_attribute1           =>  p_x_disposition_rec.attribute1,
  		x_attribute2           =>  p_x_disposition_rec.attribute2,
  		x_attribute3           =>  p_x_disposition_rec.attribute3,
  		x_attribute4           =>  p_x_disposition_rec.attribute4,
  		x_attribute5           =>  p_x_disposition_rec.attribute5,
  		x_attribute6           =>  p_x_disposition_rec.attribute6,
  		x_attribute7           =>  p_x_disposition_rec.attribute7,
  		x_attribute8           =>  p_x_disposition_rec.attribute8,
  		x_attribute9           =>  p_x_disposition_rec.attribute9,
  		x_attribute10          =>  p_x_disposition_rec.attribute10,
  		x_attribute11          =>  p_x_disposition_rec.attribute11,
  		x_attribute12          =>  p_x_disposition_rec.attribute12,
  		x_attribute13          =>  p_x_disposition_rec.attribute13,
  		x_attribute14          =>  p_x_disposition_rec.attribute14,
  		x_attribute15          =>  p_x_disposition_rec.attribute15,
  		x_comments             =>  p_x_disposition_rec.comments,

  		x_creation_date        =>  p_x_disposition_rec.creation_date ,
  		x_created_by           =>  p_x_disposition_rec.created_by,
  		x_last_update_date     =>  p_x_disposition_rec.last_update_date,
  		x_last_updated_by      =>  p_x_disposition_rec.last_updated_by,
  		x_last_update_login    =>  p_x_disposition_rec.last_update_login
  );

  -- SATHAPLI::FP OGMA Issue# 86 - Automatic Material Return, 27-Dec-2007
  -- If the instance was just removed in Serviceable condition return the part to the Visit Locator.
  -- Note that the ReturnTo_Workorder_Locator will return only if the locator is set at the Visit level.
  -- For FP OGMA Issue# 105 - Non-Serialized Item Maintenance, if the instance was removed in 'Inspection'
  -- condition, then it should not be returned to the locator.
  IF (NVL(x_return_status, FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS AND
      p_x_disposition_rec.part_change_id IS NOT NULL AND
      p_x_disposition_rec.condition_id <> NVL(fnd_profile.value('AHL_MTL_MAT_STATUS_UNSERVICABLE'), -1) AND
      p_x_disposition_rec.condition_id <> NVL(fnd_profile.value('AHL_MTL_MAT_STATUS_MRB'), -1) AND
      p_x_disposition_rec.condition_id <> NVL(fnd_profile.value('AHL_MTL_MAT_STATUS_INSPECTION'), -1)) THEN
    OPEN part_change_dtls_csr(p_x_disposition_rec.part_change_id);
    FETCH part_change_dtls_csr INTO l_removed_instance_id, l_part_change_type;
    CLOSE part_change_dtls_csr;
    IF (l_removed_instance_id = p_x_disposition_rec.instance_id AND  -- Removed instance is the Disposition instance
        NVL(l_part_change_type, 'X') IN ('R', 'S')) THEN  -- Removal or Swap
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to call AHL_PRD_PARTS_CHANGE_PVT.ReturnTo_Workorder_Locator with ' ||
                       ' part change id = ' || p_x_disposition_rec.part_change_id ||
                       ' and disposition_id = ' || p_x_disposition_rec.disposition_id);
      END IF;
      AHL_PRD_PARTS_CHANGE_PVT.ReturnTo_Workorder_Locator(p_part_change_id => p_x_disposition_rec.part_change_id,
                                                          p_disposition_id => p_x_disposition_rec.disposition_id,
                                                          x_return_status  => x_return_status,
                                                          x_msg_data       => x_msg_data,
                                                          x_msg_count      => x_msg_count,
                                                          x_ahl_mtltxn_rec => l_ahl_mtltxn_rec);

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Returned from AHL_PRD_PARTS_CHANGE_PVT.ReturnTo_Workorder_Locator: ' ||
                       ' x_return_status = ' || x_return_status);
      END IF;
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END IF;

  -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 12-Dec-2007
  -- If the part is removed in 'Inspection' condition, then move the disposition to Complete status.
  IF (p_x_disposition_rec.condition_id = NVL(fnd_profile.value('AHL_MTL_MAT_STATUS_INSPECTION'), -1) AND
      p_x_disposition_rec.part_change_id IS NOT NULL) THEN
    UPDATE AHL_PRD_DISPOSITIONS_B
    SET    status_code = 'COMPLETE'
    WHERE  disposition_id = p_x_disposition_rec.disposition_id;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'end create_disposition disposition_id:' ||p_x_disposition_rec.disposition_id);
  END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
  END IF;
  --dbms_output.put_line(SubStr('End  Create_Disposition', 1, 255));
END create_disposition;


--------------UPDATE_DISPOSITION---------------------------------------------------

PROCEDURE update_disposition(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_TRUE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := NULL,
    p_x_disposition_rec     IN OUT NOCOPY  AHL_PRD_DISPOSITION_PVT.disposition_rec_type,
    -- Parameter added by jaramana on Oct 9, 2007 for ER 5883257
    p_mr_asso_tbl           IN             AHL_PRD_NONROUTINE_PVT.MR_Association_tbl_type,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2
  ) IS

CURSOR disposition_csr(p_disposition_id IN NUMBER) IS
       SELECT *
--    AnRaj: Changed query, Perf Bug#4908609,Issue#4
--	   FROM ahl_prd_dispositions_v
	   FROM ahl_prd_dispositions_vl
	   WHERE disposition_id = p_disposition_id ;


CURSOR get_organization_csr(p_workorder_id IN NUMBER) IS
      SELECT vi.organization_id from  ahl_workorders wo, ahl_visits_b vi
       WHERE wo.workorder_id = p_workorder_id
	     AND wo.visit_id = vi.visit_id;

CURSOR val_lot_number_csr(p_lot_number IN VARCHAR2, p_inventory_item_id IN NUMBER) IS
       SELECT 'x' FROM mtl_lot_numbers
       WHERE lot_number = p_lot_number
         AND inventory_item_id = p_inventory_item_id
       UNION
       SELECT 'x' FROM csi_item_instances csi
       WHERE lot_number = p_lot_number
         AND inventory_item_id = p_inventory_item_id;

CURSOR val_serial_number_csr(p_serial_number IN VARCHAR2, p_inventory_item_id IN NUMBER) IS
       SELECT 'x' FROM mtl_serial_numbers
       WHERE serial_number = p_serial_number
         AND inventory_item_id = p_inventory_item_id
       UNION
       SELECT 'x' FROM csi_item_instances csi
       WHERE serial_number = p_serial_number
         AND inventory_item_id = p_inventory_item_id;

CURSOR item_revisions_csr (p_revision  IN  VARCHAR2, p_item_id IN NUMBER, p_organization_id IN NUMBER)  IS
       SELECT 'x' FROM   mtl_item_revisions
        WHERE  inventory_item_id = p_item_id
            AND organization_id = p_organization_id
            AND revision = p_revision;

-- Added by jaramana on October 8, 2007 for ER 5903256
CURSOR check_nr_wo_status_csr(p_nr_workorder_id IN NUMBER) IS
       SELECT 'Y'
        FROM AHL_WORKORDERS WO, AHL_VISIT_TASKS_B TSK, AHL_UNIT_EFFECTIVITIES_B UE
        WHERE WO.workorder_id = NVL(p_nr_workorder_id, -1)
          AND TSK.VISIT_TASK_ID = WO.VISIT_TASK_ID
          AND UE.UNIT_EFFECTIVITY_ID = TSK.UNIT_EFFECTIVITY_ID
          AND UE.STATUS_CODE IS NULL;

-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 12-Dec-2007
-- Cursor to check whether the disposition item is serialized or not.
CURSOR chk_non_serialized_csr(p_inventory_item_id NUMBER, p_item_org_id NUMBER) IS
       SELECT 'X'
       FROM   mtl_system_items_b
       WHERE  inventory_item_id          = p_inventory_item_id
       AND    organization_id            = p_item_org_id
       AND    serial_number_control_code = 1;

-- SATHAPLI::FP OGMA Issue# 86 - Automatic Material Return, 27-Dec-2007
-- Cursor to fetch the part change details.
CURSOR part_change_dtls_csr(p_part_change_id IN NUMBER) IS
       SELECT removed_instance_id, part_change_type
       FROM   ahl_part_changes
       WHERE  part_change_id = p_part_change_id;

l_exist VARCHAR(1);

-- SATHAPLI::Bug 7111116, 21-May-2008, fix start
-- Cursor to get the first released non-master workorder id for a given NR summary workorder.
CURSOR get_rel_nonmaster_wo_id_csr(c_nr_wo_id NUMBER) IS
    SELECT workorder_id
    FROM   ahl_workorders
    WHERE  master_workorder_flag = 'N'
    AND    wip_entity_id IN
           (SELECT child_object_id
            FROM   wip_sched_relationships
            START WITH parent_object_id      = (SELECT wip_entity_id FROM ahl_workorders WHERE workorder_id = c_nr_wo_id)
            CONNECT BY parent_object_id      = PRIOR child_object_id
            AND        parent_object_type_id = PRIOR child_object_type_id
            AND        relationship_type     = 1
           )
    AND    status_code           = G_WO_RELEASED_STATUS
    ORDER BY workorder_id;

-- Cursor to get the removed instance id for a given part change id.
CURSOR get_rem_inst_id_csr(c_part_change_id NUMBER) IS
    SELECT removed_instance_id
    FROM   ahl_part_changes
    WHERE  part_change_id = c_part_change_id;
-- SATHAPLI::Bug 7111116, 21-May-2008, fix end

l_disposition_rec     disposition_csr%ROWTYPE;
-- l_disposition_rec  AHL_PRD_DISPOSITION_PVT.disposition_rec_type;
l_primary_service_request_id NUMBER;
l_non_routine_workorder_id NUMBER;
l_calculated_status VARCHAR(30);
l_disposition_h_id NUMBER;
l_dummy_char   VARCHAR2(30);
l_return_status VARCHAR2(30);

l_pos_empty BOOLEAN;
l_assoc_quantity NUMBER;

L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || 'update_disposition';
l_init_msg_list  VARCHAR2(1)  := FND_API.G_FALSE;
l_commit         VARCHAR2(1)  := FND_API.G_FALSE;
l_msg_count NUMBER;
l_plan_id   NUMBER;
l_msg_data  VARCHAR2(2000);

l_removed_instance_id NUMBER;
l_part_change_type    VARCHAR2(1);
l_ahl_mtltxn_rec      AHL_PRD_MTLTXN_PVT.Ahl_Mtltxn_Rec_Type;
l_dummy               VARCHAR(1);

-- SATHAPLI::Bug 7111116, 21-May-2008
l_move_item_ins_tbl   AHL_PRD_PARTS_CHANGE_PVT.move_item_instance_tbl_type;
l_rel_nm_wo_id        NUMBER;
l_primary_sr_created  BOOLEAN := FALSE;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;


  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY || '', 'update Disposition_id' || p_x_disposition_rec.disposition_id );
  END IF;

  --dbms_output.put_line(SubStr('Begin  Update_Disposition', 1, 255));


  OPEN disposition_csr(p_x_disposition_rec.disposition_id);
  FETCH disposition_csr INTO l_disposition_rec;

  IF (disposition_csr%NOTFOUND) THEN
    CLOSE disposition_csr;   --close cursor before raising exeption
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_NOT_FOUND');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE disposition_csr;

  IF(p_x_disposition_rec.OBJECT_VERSION_NUMBER <> l_disposition_rec.OBJECT_VERSION_NUMBER) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_COM_RECORD_CHANGED');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_disposition_rec.status_code = 'TERMINATED' THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_DIS_UPDATE_TERMINATE');        --Cannot update a terminated disposition.
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --Handle JSP module
   --Handle GMiss and merge the updating record with the one from database

  IF (p_module_type = 'JSP') THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Merging data');
    END IF;
    --dbms_output.put_line(SubStr('Update_disp:Merging data', 1, 255));
    IF p_x_disposition_rec.workorder_id IS NULL THEN
	    p_x_disposition_rec.workorder_id := l_disposition_rec.workorder_id;
	ELSIF (p_x_disposition_rec.workorder_id  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.workorder_id  := null;
    END IF;
    IF p_x_disposition_rec.part_change_id IS NULL THEN
	    p_x_disposition_rec.part_change_id := l_disposition_rec.part_change_id;
    ELSIF (p_x_disposition_rec.part_change_id  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.part_change_id  := null;
    END IF;
    IF p_x_disposition_rec.path_position_id IS NULL THEN
	    p_x_disposition_rec.path_position_id := l_disposition_rec.path_position_id;
    ELSIF (p_x_disposition_rec.path_position_id  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.path_position_id  := null;
    END IF;
    IF p_x_disposition_rec.item_org_id IS NULL THEN
	    p_x_disposition_rec.item_org_id := l_disposition_rec.organization_id;
    ELSIF (p_x_disposition_rec.item_org_id  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.item_org_id  := null;
    END IF;
    IF p_x_disposition_rec.inventory_item_id IS NULL THEN
	    p_x_disposition_rec.inventory_item_id := l_disposition_rec.inventory_item_id;
    ELSIF (p_x_disposition_rec.inventory_item_id  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.inventory_item_id  := null;
    END IF;

    IF p_x_disposition_rec.item_group_id IS NULL THEN
	    p_x_disposition_rec.item_group_id := l_disposition_rec.item_group_id;
    ELSIF (p_x_disposition_rec.item_group_id  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.item_group_id  := null;
    END IF;
    IF p_x_disposition_rec.condition_id IS NULL THEN
	    p_x_disposition_rec.condition_id := l_disposition_rec.condition_id;
    ELSIF (p_x_disposition_rec.condition_id  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.condition_id  := null;
    END IF;
    IF p_x_disposition_rec.instance_id IS NULL THEN
	    p_x_disposition_rec.instance_id := l_disposition_rec.instance_id;
    ELSIF (p_x_disposition_rec.instance_id  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.instance_id  := null;
    END IF;
    IF p_x_disposition_rec.serial_number IS NULL THEN
	    p_x_disposition_rec.serial_number := l_disposition_rec.serial_number;
    ELSIF (p_x_disposition_rec.serial_number  = FND_API.G_MISS_CHAR) THEN
        p_x_disposition_rec.serial_number  := null;
    END IF;
    IF p_x_disposition_rec.lot_number IS NULL THEN
	    p_x_disposition_rec.lot_number := l_disposition_rec.lot_number;
    ELSIF (p_x_disposition_rec.lot_number  = FND_API.G_MISS_CHAR) THEN
        p_x_disposition_rec.lot_number  := null;
    END IF;
    IF p_x_disposition_rec.immediate_disposition_code IS NULL THEN
	    p_x_disposition_rec.immediate_disposition_code := l_disposition_rec.immediate_disposition_code;
    ELSIF (p_x_disposition_rec.immediate_disposition_code  = FND_API.G_MISS_CHAR) THEN
        p_x_disposition_rec.immediate_disposition_code  := null;
    END IF;
    IF p_x_disposition_rec.secondary_disposition_code IS NULL THEN
	    p_x_disposition_rec.secondary_disposition_code := l_disposition_rec.secondary_disposition_code;
    ELSIF (p_x_disposition_rec.secondary_disposition_code  = FND_API.G_MISS_CHAR) THEN
        p_x_disposition_rec.secondary_disposition_code  := null;
    END IF;
    IF p_x_disposition_rec.status_code IS NULL THEN
	    p_x_disposition_rec.status_code := l_disposition_rec.status_code;
    ELSIF (p_x_disposition_rec.status_code  = FND_API.G_MISS_CHAR) THEN
        p_x_disposition_rec.status_code  := null;
    END IF;
    IF p_x_disposition_rec.quantity IS NULL THEN
	    p_x_disposition_rec.quantity := l_disposition_rec.quantity;
    ELSIF (p_x_disposition_rec.quantity  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.quantity  := null;
    END IF;
    IF p_x_disposition_rec.uom IS NULL THEN
	    p_x_disposition_rec.uom := l_disposition_rec.uom;
    ELSIF (p_x_disposition_rec.uom  = FND_API.G_MISS_CHAR) THEN
        p_x_disposition_rec.uom  := null;
    END IF;
    IF p_x_disposition_rec.comments IS NULL THEN
	    p_x_disposition_rec.comments := l_disposition_rec.comments;
    ELSIF (p_x_disposition_rec.comments  = FND_API.G_MISS_CHAR) THEN
        p_x_disposition_rec.comments  := null;
    END IF;
    IF p_x_disposition_rec.collection_id IS NULL THEN
	    p_x_disposition_rec.collection_id := l_disposition_rec.collection_id;
    ELSIF (p_x_disposition_rec.collection_id  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.collection_id  := null;
    END IF;
    IF p_x_disposition_rec.primary_service_request_id IS NULL THEN
	    p_x_disposition_rec.primary_service_request_id := l_disposition_rec.primary_service_request_id;
    ELSIF (p_x_disposition_rec.primary_service_request_id  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.primary_service_request_id  := null;
    END IF;
    IF p_x_disposition_rec.non_routine_workorder_id IS NULL THEN
	    p_x_disposition_rec.non_routine_workorder_id := l_disposition_rec.non_routine_workorder_id;
    ELSIF (p_x_disposition_rec.non_routine_workorder_id  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.non_routine_workorder_id  := null;
    END IF;
    IF p_x_disposition_rec.wo_operation_id IS NULL THEN
	    p_x_disposition_rec.wo_operation_id := l_disposition_rec.wo_operation_id;
    ELSIF (p_x_disposition_rec.wo_operation_id  = FND_API.G_MISS_NUM) THEN
        p_x_disposition_rec.wo_operation_id  := null;
    END IF;
    IF p_x_disposition_rec.item_revision IS NULL THEN
	    p_x_disposition_rec.item_revision := l_disposition_rec.item_revision;
    ELSIF (p_x_disposition_rec.item_revision  = FND_API.G_MISS_CHAR) THEN
        p_x_disposition_rec.item_revision  := null;
    END IF;

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'After Merging data');
    END IF;
   --dbms_output.put_line(SubStr('Update_disp:End Merging data', 1, 255));
  END IF;
  --END MERGING DATA

  IF p_validation_level = FND_API.G_VALID_LEVEL_FULL  THEN
    convert_values_to_ids(p_x_disposition_rec);
  END IF;

  --VALIDATE THAT THESE ATTRIBUTE SHOULD NOT BE CHANGED
  --dbms_output.put_line('Start validate for changes..............');
  IF nvl(p_x_disposition_rec.workorder_id, -1) <> nvl(l_disposition_rec.workorder_id, -1) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_WO_ID_CHNG');         --Workorder id Cannot be change
    FND_MSG_PUB.ADD;
  END IF;
  IF l_disposition_rec.part_change_id  IS NOT NULL
     AND nvl (p_x_disposition_rec.part_change_id, -1) <> l_disposition_rec.part_change_id THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_PARTCHG_ID_CHNG');         --Part Change Cannot be change
    FND_MSG_PUB.ADD;
  END IF;

  IF l_disposition_rec.inventory_item_id IS NOT NULL
   AND nvl(p_x_disposition_rec.inventory_item_id, -1) <> l_disposition_rec.inventory_item_id THEN
     --dbms_output.put_line('In Error message AHL_PRD_DIS_ITEM_REV_CHNG');
     FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_ITEM_CHG');         --Item cannot be changed
     FND_MSG_PUB.ADD;
  END IF;

 /* IF nvl (p_x_disposition_rec.item_revision, ' ') <> nvl(l_disposition_rec.item_revision, ' ') THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_ITEM_REV_CHNG');         --ITem Revision Cannot be change
    FND_MSG_PUB.ADD;
  END IF;
  */
  IF nvl(p_x_disposition_rec.item_group_id, -1) <> nvl(l_disposition_rec.item_group_id, -1) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_ITEM_GRP_CHNG');         --Item Group Cannot be change
    FND_MSG_PUB.ADD;
  END IF;
  --IF nvl(p_x_disposition_rec.instance_id, -1) <> nvl(l_disposition_rec.instance_id, -1) THEN
  --Instance can only be changed once (originally it is not changeable at all)
  --Updated by Jerry on 01/26/2005 for fixing bug 4089750
  IF (l_disposition_rec.instance_id IS NOT NULL AND (p_x_disposition_rec.instance_id IS NULL OR
      p_x_disposition_rec.instance_id <> l_disposition_rec.instance_id)) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_INST_CHNG');
    FND_MSG_PUB.ADD;
  ELSIF ((l_disposition_rec.instance_id IS NULL AND
         p_x_disposition_rec.instance_id IS NULL AND
        --    AnRaj: Changed query, Perf Bug#4908609,Issue#4
        -- l_disposition_rec.trackable_flag = 'Y' AND
         (l_disposition_rec.instance_id is not null or l_disposition_rec.path_position_id is not null) AND
         p_x_disposition_rec.status_code <> 'TERMINATED' AND --Added on 03/02/05 when verifying
         l_disposition_rec.part_change_id IS NULL AND        --bug fix 4093642 on SCMTSB2
         p_x_disposition_rec.part_change_id IS NULL) AND     -- Added by rbhavsar on Aug 07, 2007 for FP bug 6318339, base bug 6058419
         (l_disposition_rec.immediate_disposition_code is NULL)) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_INSTANCE_VALUE_REQ');
    FND_MSG_PUB.ADD;
  ELSIF (l_disposition_rec.instance_id IS NULL AND p_x_disposition_rec.instance_id IS NOT NULL) THEN
    BEGIN
      SELECT 'X' INTO l_dummy_char
        FROM csi_item_instances
       WHERE instance_id = p_x_disposition_rec.instance_id
         AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
         AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.set_name(G_APP_NAME,'AHL_PRD_INV_INST_NUM');
        FND_MESSAGE.set_token('INTANCE_NUM', p_x_disposition_rec.instance_number);
        FND_MSG_PUB.ADD;
    END;
  END IF;
  /* Commented out on 02/02/2005 by Jerry for fixing bug 4089750
  IF nvl(p_x_disposition_rec.instance_id, -1) <> nvl(l_disposition_rec.instance_id, -1) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_INST_CHNG');         --Instance Cannot be change
    FND_MSG_PUB.ADD;
  END IF;
  */
  /* Begin Fix for 4075758 on Dec 21. 2004 */
  -- For non-tracked, serial or lot controlled items, the serial
  -- and/or and lot number may be provided during update mode also
  /*****
  IF nvl(p_x_disposition_rec.serial_number, ' ') <> nvl(l_disposition_rec.serial_number, ' ') THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_SERIAL_NUM_CHNG');         --Serial Number Cannot be change
    FND_MSG_PUB.ADD;
  END IF;

  IF nvl(p_x_disposition_rec.lot_number, ' ') <> nvl(l_disposition_rec.lot_number, ' ') THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_LOT_NUM_CHNG');         --Lot Number Cannot be change
    FND_MSG_PUB.ADD;
  END IF;
  ******/
  IF nvl(p_x_disposition_rec.serial_number, ' ') <> nvl(l_disposition_rec.serial_number, nvl(p_x_disposition_rec.serial_number, ' ')) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_SERIAL_NUM_CHNG');         --Serial Number Can be set once
    FND_MSG_PUB.ADD;
  END IF;
  IF nvl(p_x_disposition_rec.serial_number, ' ') <> nvl(l_disposition_rec.serial_number, ' ') THEN
    -- Serial Number has been set: Validate
    OPEN val_serial_number_csr(p_x_disposition_rec.serial_number, p_x_disposition_rec.inventory_item_id);
    FETCH val_serial_number_csr INTO l_exist;
    IF (val_serial_number_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_INV_SERIAL');    -- Invalid serial number and item combination
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE val_serial_number_csr;
  END IF;

  IF nvl(p_x_disposition_rec.lot_number, ' ') <> nvl(l_disposition_rec.lot_number, nvl(p_x_disposition_rec.lot_number, ' ')) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_PRD_DIS_LOT_NUM_CHNG');         --Lot Number Can be set once
    FND_MSG_PUB.ADD;
  END IF;
  IF nvl(p_x_disposition_rec.lot_number, ' ') <> nvl(l_disposition_rec.lot_number, ' ') THEN
    -- Lot Number has been set: Validate
    OPEN val_lot_number_csr(p_x_disposition_rec.lot_number, p_x_disposition_rec.inventory_item_id);
    FETCH val_lot_number_csr INTO l_exist;
    IF (val_lot_number_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_PRD_DIS_INV_LOT');    -- Invalid Lot number and item combination
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE val_lot_number_csr;
  END IF;

 --Item Revision
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Item Revision old: ' || l_disposition_rec.item_revision || ' new: ' || p_x_disposition_rec.item_revision);
	END IF;
 IF nvl(p_x_disposition_rec.item_revision, ' ') <> nvl(l_disposition_rec.item_revision, nvl(p_x_disposition_rec.item_revision, ' ')) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_ITEM_REV_CHNG');         --item revision Number Can be set once
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Item Revision Change old: ' || l_disposition_rec.item_revision || ' new: ' || p_x_disposition_rec.item_revision);
    END IF;
  END IF;
  IF nvl(p_x_disposition_rec.item_revision, ' ') <> nvl(l_disposition_rec.item_revision, ' ') THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Validate item revision: ' || p_x_disposition_rec.item_revision);
    END IF;
	-- item revision Number has been set: Validate
    OPEN item_revisions_csr (p_x_disposition_rec.item_revision, p_x_disposition_rec.inventory_item_id, p_x_disposition_rec.item_org_id);
    FETCH item_revisions_csr INTO l_exist;
    IF (item_revisions_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_INV_ITEM_REV');    -- Invalid serial number and item combination
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE item_revisions_csr;
  END IF;

  /* End Fix for 4075758 on Dec 21. 2004 */

  IF l_disposition_rec.Collection_Id IS NOT NULL
    AND nvl(p_x_disposition_rec.Collection_id, -1) <> nvl(l_disposition_rec.Collection_Id, -1) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_COLLECT_ID_CHNG');         --Workorder Cannot be changed
      FND_MSG_PUB.ADD;
  END IF;
  IF nvl(p_x_disposition_rec.Primary_Service_Request_id , -1) <> nvl(l_disposition_rec.Primary_Service_Request_id , -1) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_SR_ID_CHNG');         --Primary Service Request Cannot be changed
    FND_MSG_PUB.ADD;
  END IF;
  IF nvl(p_x_disposition_rec.Non_Routine_Workorder_id , -1) <> nvl(l_disposition_rec.Non_Routine_Workorder_id , -1) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_NONRTN_WO_CHNG');         --Non Routine Workorder Cannot be changed
    FND_MSG_PUB.ADD;
  END IF;

  IF (l_disposition_rec.UOM IS NOT NULL AND (nvl(p_x_disposition_rec.UOM, 'null') <> l_disposition_rec.UOM)) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_UOM_CHNG');         --UOM Cannot be changed
    FND_MSG_PUB.ADD;
  END IF;


  IF(workorder_editable(p_x_disposition_rec.workorder_id) = FALSE) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_WO_NOT_EDITABLE');       --Cannot Update Disposition Because Workorder is not editable.
    FND_MSG_PUB.ADD;
  END IF;

  --Disposition Status can only be changed to Terminated by the user.
  IF nvl(p_x_disposition_rec.status_code, 'dummy') <> 'TERMINATED' AND nvl(p_x_disposition_rec.status_code, 'dummy') <> nvl(l_disposition_rec.status_code, 'dummy') THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_STATUS_CHNG');         --Disposition Status cannot be changed excepte changed
    FND_MSG_PUB.ADD;
  END IF;

  --if existing item is null and item group is not null then item need to be enter
  IF l_disposition_rec.inventory_item_id IS NULL AND l_disposition_rec.item_group_id IS NOT NULL THEN
    IF p_x_disposition_rec.inventory_item_id IS NOT NULL THEN
        --derive organization
		OPEN get_organization_csr(p_x_disposition_rec.workorder_id);
        FETCH get_organization_csr INTO p_x_disposition_rec.item_org_id;
	    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Derived Org: ' || p_x_disposition_rec.item_org_id);
        END IF;
        --dbms_output.put_line(SubStr('Derived Org: ' || p_x_disposition_rec.item_org_id, 1, 255));
        CLOSE get_organization_csr;

		--dbms_output.put_line(SubStr('Update_disp:allow change item', 1, 255));


	     validate_item(p_x_disposition_rec.inventory_item_id, p_x_disposition_rec.item_org_id, p_x_disposition_rec.workorder_id);

		--start fix Bug#4075758 Item is non-tracked
	    validate_Item_Control(p_x_disposition_rec.inventory_item_id , p_x_disposition_rec.item_org_id,
                                         p_x_disposition_rec.serial_number,
                                          p_x_disposition_rec.item_revision,
										  p_x_disposition_rec.lot_number);
		--end  Bug#4075758
    ELSE
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_ITEM_REQ');         --Item is required
		FND_MSG_PUB.ADD;
    END IF;
  ELSE   --ignore the new organization id change just use the existing one
    p_x_disposition_rec.item_org_id := l_disposition_rec.organization_id;
  END IF;

 --Validate Workorder operation change
  IF(nvl(p_x_disposition_rec.wo_operation_id, -1) <> nvl(l_disposition_rec.wo_operation_id, -1)) THEN
    validate_wo_operation(p_x_disposition_rec.workorder_id, p_x_disposition_rec.wo_operation_id);

  END IF;

  IF p_x_disposition_rec.path_position_id IS NOT NULL AND p_x_disposition_rec.instance_id IS NULL THEN
    l_pos_empty := TRUE;
  END IF;

  --Validate Quantity Change
  IF p_x_disposition_rec.quantity IS NULL AND l_pos_empty <> TRUE THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_QTY_REQ');         --Quantity is required
    FND_MSG_PUB.ADD;
  ELSIF p_x_disposition_rec.quantity <= 0 THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_QTY_LESS_ZERO');         --Invalid Quantity.  Quantity must be greater than zero
    FND_MSG_PUB.ADD;
  ELSIF p_x_disposition_rec.quantity <> l_disposition_rec.quantity THEN
    IF nvl(p_x_disposition_rec.status_code, ' ') = 'COMPLETE' THEN
      FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_PRD_DIS_QTY_CHNG');     -- Quantity cannot be changed
      FND_MSG_PUB.ADD;
    END IF;

   /* Commented out on 02/02/2005 by Jerry for fixing bug 4089750
    IF p_x_disposition_rec.instance_id IS NOT NULL THEN
	  FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_PRD_DIS_QTY_INST_QTY');     -- Quantity cannot be different from instance's quantity
      FND_MSG_PUB.ADD;
    END IF;
   */

    l_assoc_quantity := AHL_PRD_DISP_MTL_TXN_PVT.Calculate_Txned_Qty(p_x_disposition_rec.disposition_id);
    IF (p_x_disposition_rec.quantity < l_assoc_quantity) THEN
	   FND_MESSAGE.set_name(G_APP_NAME, 'AHL_PRD_DIS_LESS_THAN_ASSC_QTY');    -- Quantity cannot be less then material transaction associated quantity
	   FND_MESSAGE.Set_Token('QUANTITY', p_x_disposition_rec.quantity );
	   FND_MESSAGE.Set_Token('ASSC_QTY', l_assoc_quantity );
	   FND_MSG_PUB.ADD;
	END IF;

  END IF;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'end validate changes');
  END IF;
   --dbms_output.put_line(SubStr('Update_disp:End Validate Change', 1, 255));

   -- Validate part_change
   IF(p_x_disposition_rec.part_change_id IS NOT NULL AND l_disposition_rec.part_change_id IS NULL) THEN
          -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 12-Dec-2007
          -- Modified the API to take disposition quantity as an additional IN parameter.
	  validate_part_change(p_x_disposition_rec.part_change_id, p_x_disposition_rec.instance_id, p_x_disposition_rec.quantity);
   END IF;

  --COLLECTION ID
  -- Added by jaramana on March 25, 2005 to fix bug 4243200
  -- First check if a QA PLan is defined in the workorder Org.
  AHL_QA_RESULTS_PVT.get_qa_plan( p_api_version   => 1.0,
                                  p_init_msg_list => FND_API.G_False,
                                  p_commit => FND_API.G_FALSE,
                                  p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                                  p_default => FND_API.G_FALSE,
                                  p_organization_id => p_x_disposition_rec.item_org_id,
                                  p_transaction_number => 2004,  -- MRB_TRANSACTION_NUMBER
                                  p_col_trigger_value => fnd_profile.value('AHL_MRB_DISP_PLAN_TYPE'),
                                  x_return_status => l_return_status,
                                  x_msg_count => l_msg_count,
                                  x_msg_data => l_msg_data,
                                  x_plan_id  => l_plan_id);
/**
  IF p_x_disposition_rec.condition_id = fnd_profile.value('AHL_MTL_MAT_STATUS_MRB') AND p_x_disposition_rec.instance_id IS NOT NULL THEN       -- status is MRB and tracked item
**/
  IF p_x_disposition_rec.condition_id = fnd_profile.value('AHL_MTL_MAT_STATUS_MRB') AND
     p_x_disposition_rec.instance_id IS NOT NULL AND
     l_plan_id IS NOT NULL THEN       -- status is MRB and tracked item and QA plan is defined in Org
    IF p_x_disposition_rec.collection_id IS NULL THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_QA_RESULT_REQ');    --  QA Result Required
      FND_MSG_PUB.ADD;
    ELSE
      validate_collection_id(p_x_disposition_rec.collection_id);
    END IF;
  END IF;
  -- End fix for bug 4243200


  -- SERVICE REQUEST
  IF ((p_x_disposition_rec.instance_id IS NULL
       OR
	   (nvl(p_x_disposition_rec.condition_id, -1) <> fnd_profile.value('AHL_MTL_MAT_STATUS_MRB')
           AND nvl(p_x_disposition_rec.condition_id, -1) <> fnd_profile.value('AHL_MTL_MAT_STATUS_UNSERVICABLE')
	   )
	 )
     AND
	 ( p_x_disposition_rec.summary IS NOT NULL OR p_x_disposition_rec.problem_code IS NOT NULL
	       OR p_x_disposition_rec.severity_id IS NOT NULL
	 )) THEN
	    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_SR_NOT_REQ');      --Non Conformance (SR) information is not required
        FND_MSG_PUB.ADD;
  END IF;

  -- create service request and non-routine job
  -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 12-Dec-2007
  -- Add a check for the create_work_order_option attribute too.
  IF p_x_disposition_rec.primary_service_request_id IS NULL AND p_x_disposition_rec.instance_id IS NOT NULL   -- AND ITEM is  tracked
     AND(p_x_disposition_rec.condition_id = fnd_profile.value('AHL_MTL_MAT_STATUS_UNSERVICABLE') OR
         p_x_disposition_rec.condition_id = fnd_profile.value('AHL_MTL_MAT_STATUS_MRB'))
     AND(p_x_disposition_rec.create_work_order_option <> 'CREATE_SR_NO') THEN
       --dbms_output.put_line(SubStr('Update_Disp Before Create_SR', 1, 255));

       -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 12-Dec-2007
       -- The option CREATE_WO_NO is not valid for non-serialized items. If chosen, throw an error.
       IF (p_x_disposition_rec.create_work_order_option = 'CREATE_WO_NO') THEN
         OPEN chk_non_serialized_csr(p_x_disposition_rec.inventory_item_id, p_x_disposition_rec.item_org_id);
         FETCH chk_non_serialized_csr INTO l_dummy;
         IF (chk_non_serialized_csr%FOUND) THEN
           FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DIS_NON_SRL_SR');
           FND_MSG_PUB.ADD;
         END IF;
         CLOSE chk_non_serialized_csr;
       END IF;

       -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
       l_msg_count := FND_MSG_PUB.count_msg;
       IF l_msg_count > 0 THEN
       x_msg_count := l_msg_count;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       Create_SR (p_init_msg_list            => FND_API.G_FALSE,
                  p_disposition_rec          => p_x_disposition_rec,
                  -- Parameter added by jaramana on Oct 9, 2007 for ER 5883257
                  p_mr_asso_tbl              => p_mr_asso_tbl,
                  x_primary_sr_id            => l_primary_service_request_id,
                  x_non_routine_workorder_id => l_non_routine_workorder_id,
                  x_return_status            => x_return_status,
                  x_msg_count                => x_msg_count,
                  x_msg_data                 => x_msg_data);
       --reinitialize message stack and ignore any warning message
       IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
         FND_MSG_PUB.Initialize;

         -- SATHAPLI::Bug 7111116, 21-May-2008
         -- set the l_primary_sr_created flag to TRUE
         l_primary_sr_created := TRUE;
       END IF;
       p_x_disposition_rec.primary_service_request_id := l_primary_service_request_id;
       p_x_disposition_rec.non_routine_workorder_id := l_non_routine_workorder_id;
  END IF;     --end create SR


  --Validate disposition type
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Before validate_disposition_types');
    END IF;
   --dbms_output.put_line(SubStr('Before validate disposition type', 1, 255));
   Validate_Disposition_Types (
     --   p_api_version  =>   p_api_version,
     --   p_init_msg_list =>  l_init_msg_list,
     --   p_commit =>   l_commit,
     --   p_validation_level  => p_validation_level,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data ,
        p_disposition_rec  =>  p_x_disposition_rec);

  -- Calculate disposition status
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Before calculate_status');
    END IF;
   --dbms_output.put_line(SubStr('Before calculate status'|| p_x_disposition_Rec.status_code, 1, 255));
   Calculate_Status (
    p_disposition_Rec   => p_x_disposition_Rec,
    x_status_code       =>  l_calculated_status);

   p_x_disposition_Rec.status_code := l_calculated_status;
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'After calculate status' || p_x_disposition_Rec.status_code);
    END IF;
   --dbms_output.put_line(SubStr('After calculate status' ||p_x_disposition_Rec.status_code, 1, 255));
  -- setting up object version number
  p_x_disposition_rec.object_version_number := p_x_disposition_rec.object_version_number + 1;
  --setting up user/create/update information
  p_x_disposition_rec.last_updated_by := fnd_global.user_id;
  p_x_disposition_rec.last_update_date := SYSDATE;
  p_x_disposition_rec.last_update_login := fnd_global.login_id;

  -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 12-Dec-2007
  -- If the part is removed in 'Inspection' condition, then move the disposition to Complete status.
  IF (p_x_disposition_rec.condition_id = fnd_profile.value('AHL_MTL_MAT_STATUS_INSPECTION') AND
      p_x_disposition_rec.part_change_id IS NOT NULL ) THEN
    p_x_disposition_rec.status_code := 'COMPLETE';
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Before update_row');
  END IF;
  --dbms_output.put_line(SubStr('Update_disp:Before call Update_Row', 1, 255));
  AHL_PRD_DISPOSITIONS_PKG.UPDATE_ROW(
  		x_disposition_id       =>  p_x_disposition_rec.disposition_id,
  		x_object_version_number   =>  p_x_disposition_rec.object_version_number,
  		x_workorder_id         =>  p_x_disposition_rec.workorder_id ,
  		x_part_change_id       =>  p_x_disposition_rec.part_change_id,
  		x_path_position_id     =>  p_x_disposition_rec.path_position_id,
  		x_inventory_item_id    =>  p_x_disposition_rec.inventory_item_id,
  		x_organization_id      =>  p_x_disposition_rec.item_org_id,
  		x_item_group_id        =>  p_x_disposition_rec.item_group_id,
  		x_condition_id         =>  p_x_disposition_rec.condition_id,
  		x_instance_id          =>  p_x_disposition_rec.instance_id,
  		x_serial_number        =>  p_x_disposition_rec.serial_number,
  		x_lot_number           =>  p_x_disposition_rec.lot_number,
  		x_immediate_disposition_code  =>  p_x_disposition_rec.immediate_disposition_code ,
  		x_secondary_disposition_code  =>  p_x_disposition_rec.secondary_disposition_code,
  		x_status_code          =>  p_x_disposition_rec.status_code,
  		x_quantity             =>  p_x_disposition_rec.quantity,
  		x_uom                  =>  p_x_disposition_rec.uom,
  		x_collection_id        =>  p_x_disposition_rec.collection_id,
  		x_primary_service_request_id   =>  p_x_disposition_rec.primary_service_request_id ,
  		x_non_routine_workorder_id     =>  p_x_disposition_rec.non_routine_workorder_id,
  		x_wo_operation_id              => p_x_disposition_rec.wo_operation_id,
  		x_item_revision                => p_x_disposition_rec.item_revision,
  		x_attribute_category   =>  p_x_disposition_rec.attribute_category,
  		x_attribute1           =>  p_x_disposition_rec.attribute1,
  		x_attribute2           =>  p_x_disposition_rec.attribute2,
  		x_attribute3           =>  p_x_disposition_rec.attribute3,
  		x_attribute4           =>  p_x_disposition_rec.attribute4,
  		x_attribute5           =>  p_x_disposition_rec.attribute5,
  		x_attribute6           =>  p_x_disposition_rec.attribute6,
  		x_attribute7           =>  p_x_disposition_rec.attribute7,
  		x_attribute8           =>  p_x_disposition_rec.attribute8,
  		x_attribute9           =>  p_x_disposition_rec.attribute9,
  		x_attribute10          =>  p_x_disposition_rec.attribute10,
  		x_attribute11          =>  p_x_disposition_rec.attribute11,
  		x_attribute12          =>  p_x_disposition_rec.attribute12,
  		x_attribute13          =>  p_x_disposition_rec.attribute13,
  		x_attribute14          =>  p_x_disposition_rec.attribute14,
  		x_attribute15          =>  p_x_disposition_rec.attribute15,
  		x_comments             =>  p_x_disposition_rec.comments,
  		x_last_update_date     =>  p_x_disposition_rec.last_update_date,
  		x_last_updated_by      =>  p_x_disposition_rec.last_updated_by,
  		x_last_update_login    =>  p_x_disposition_rec.last_update_login
  );

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'After update_row');
  END IF;
  --dbms_output.put_line(SubStr('Update_disp:After call Update_Row', 1, 255));
--dbms_output.put_line(SubStr('Update_disp: l_disposition_rec.creation_date ' || l_disposition_rec.creation_date, 1, 255));
--dbms_output.put_line(SubStr('Update_disp: l_disposition_rec.created_by ' || l_disposition_rec.created_by, 1, 255));


  Select AHL_PRD_DISPOSITIONS_B_H_S.NEXTVAL into l_disposition_h_id from dual;
    --dbms_output.put_line(SubStr('Update_disp:Before insert into history table', 1, 255));

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Before insert into history table');
  END IF;
  AHL_PRD_DISPOSITIONS_B_H_PKG.INSERT_ROW(
  		x_rowid                =>  l_dummy_char,
		x_disposition_h_id     => l_disposition_h_id,
  		x_disposition_id       =>  p_x_disposition_rec.disposition_id,
  		x_object_version_number   => p_x_disposition_rec.object_version_number,
  		x_workorder_id         =>  p_x_disposition_rec.workorder_id ,
  		x_part_change_id       =>   p_x_disposition_rec.part_change_id,
  		x_path_position_id     =>   p_x_disposition_rec.path_position_id,
  		x_inventory_item_id    =>   p_x_disposition_rec.inventory_item_id,
  		x_organization_id      =>  p_x_disposition_rec.item_org_id,
  		x_item_group_id        =>   p_x_disposition_rec.item_group_id,
  		x_condition_id         =>   p_x_disposition_rec.condition_id,
  		x_instance_id          =>   p_x_disposition_rec.instance_id,
  		x_serial_number        =>   p_x_disposition_rec.serial_number,
  		x_lot_number           =>   p_x_disposition_rec.lot_number,
  		x_immediate_disposition_code  =>   p_x_disposition_rec.immediate_disposition_code ,
  		x_secondary_disposition_code  =>   p_x_disposition_rec.secondary_disposition_code,
  		x_status_code          =>   p_x_disposition_rec.status_code,
  		x_quantity             =>    p_x_disposition_rec.quantity,
  		x_uom                  =>    p_x_disposition_rec.uom,
  		x_collection_id        =>    p_x_disposition_rec.collection_id,
  		x_primary_service_request_id   =>    p_x_disposition_rec.primary_service_request_id ,
  		x_non_routine_workorder_id     =>    p_x_disposition_rec.non_routine_workorder_id,
  		x_wo_operation_id              =>   p_x_disposition_rec.wo_operation_id,
  		x_item_revision                =>   p_x_disposition_rec.item_revision,
  		x_attribute_category   =>    p_x_disposition_rec.attribute_category,
  		x_attribute1           =>   p_x_disposition_rec.attribute1,
  		x_attribute2           =>   p_x_disposition_rec.attribute2,
  		x_attribute3           =>   p_x_disposition_rec.attribute3,
  		x_attribute4           =>   p_x_disposition_rec.attribute4,
  		x_attribute5           =>   p_x_disposition_rec.attribute5,
  		x_attribute6           =>   p_x_disposition_rec.attribute6,
  		x_attribute7           =>   p_x_disposition_rec.attribute7,
  		x_attribute8           =>   p_x_disposition_rec.attribute8,
  		x_attribute9           =>   p_x_disposition_rec.attribute9,
  		x_attribute10          =>   p_x_disposition_rec.attribute10,
  		x_attribute11          =>   p_x_disposition_rec.attribute11,
  		x_attribute12          =>   p_x_disposition_rec.attribute12,
  		x_attribute13          =>   p_x_disposition_rec.attribute13,
  		x_attribute14          =>   p_x_disposition_rec.attribute14,
  		x_attribute15          =>   p_x_disposition_rec.attribute15,
  		x_comments             =>   p_x_disposition_rec.comments,
  		x_creation_date        =>   l_disposition_rec.creation_date ,
  		x_created_by           =>   l_disposition_rec.created_by,
  		x_last_update_date     =>  p_x_disposition_rec.last_update_date,
  		x_last_updated_by      =>  p_x_disposition_rec.last_updated_by,
  		x_last_update_login    =>  p_x_disposition_rec.last_update_login
  );

  -- Added by jaramana on October 8, 2007 for ER 5903256
  -- If the instance was just removed and a NR WO was already created
  -- Change the location of the instance to the NR WO.
  l_exist := NULL;
  OPEN check_nr_wo_status_csr(p_x_disposition_rec.non_routine_workorder_id);
  FETCH check_nr_wo_status_csr INTO l_exist;
  CLOSE check_nr_wo_status_csr;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to check if instance location neesd to be changed. ' ||
          ' p_x_disposition_rec.non_routine_workorder_id = ' || p_x_disposition_rec.non_routine_workorder_id ||
          ', l_disposition_rec.part_change_id = ' || l_disposition_rec.part_change_id ||
          ', p_x_disposition_rec.part_change_id = ' || p_x_disposition_rec.part_change_id ||
          ', NR UE with null status exists: ' || NVL(l_exist, 'N'));
  END IF;

-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 12-Dec-2007
-- The API update_item_location and its use has been commented out. Its functionality will
-- now be handled in the API AHL_PRD_NONROUTINE_PVT.process_nonroutine_job.
/*
  IF (NVL(x_return_status, FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS AND
      p_x_disposition_rec.non_routine_workorder_id IS NOT NULL AND
      l_disposition_rec.part_change_id IS NULL AND
      p_x_disposition_rec.part_change_id IS NOT NULL AND
      l_exist IS NOT NULL) THEN
    update_item_location(p_workorder_id  => p_x_disposition_rec.non_routine_workorder_id,
                         p_instance_id   => p_x_disposition_rec.instance_id,
                         x_return_status => x_return_status);
  END IF;
  -- End addition by jaramana on February 21, 2007 for ER 5854667
*/

  -- SATHAPLI::Bug 7111116, 21-May-2008, fix start
  -- If the following two conditions are met, i.e.:
  -- 1) unserviceable removal has happened
  -- 2) there exists a primary NR with released workorder for this disposition
  -- then the removed part should be assigned to the released NR workorder.
  -- This should be done only if the primary SR was not created along with removal in this cycle itself.
  IF (l_disposition_rec.part_change_id IS NULL AND p_x_disposition_rec.part_change_id IS NOT NULL
      AND
      (p_x_disposition_rec.condition_id = fnd_profile.value('AHL_MTL_MAT_STATUS_UNSERVICABLE')
       OR
       p_x_disposition_rec.condition_id = fnd_profile.value('AHL_MTL_MAT_STATUS_MRB')
      )
      AND
      p_x_disposition_rec.non_routine_workorder_id IS NOT NULL
      AND
      NOT l_primary_sr_created)
  THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key,
                         'About to check if the removed instance location needs to be changed.');
      END IF;

      -- get the first released non-master workorder id for the NR summary workorder
      OPEN get_rel_nonmaster_wo_id_csr(p_x_disposition_rec.non_routine_workorder_id);
      FETCH get_rel_nonmaster_wo_id_csr INTO l_rel_nm_wo_id;
      IF (get_rel_nonmaster_wo_id_csr%FOUND) THEN
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key,
              'First released non-master workorder id => '||l_rel_nm_wo_id);
          END IF;

          -- get the removed instance id, which can be different from the disposition instance id for non-serialized items
          OPEN get_rem_inst_id_csr(p_x_disposition_rec.part_change_id);
          FETCH get_rem_inst_id_csr INTO l_removed_instance_id;
          IF (get_rem_inst_id_csr%FOUND) THEN
              -- move the removed part to the released NR workorder
              l_move_item_ins_tbl(1).instance_id       := l_removed_instance_id;
              l_move_item_ins_tbl(1).quantity          := p_x_disposition_rec.quantity;
              l_move_item_ins_tbl(1).from_workorder_id := p_x_disposition_rec.workorder_id;
              l_move_item_ins_tbl(1).to_workorder_id   := l_rel_nm_wo_id;

              IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key,
                  'About to call the API AHL_PRD_PARTS_CHANGE_PVT.move_instance_location with the parameters:'||
                  ' instance_id => '||l_removed_instance_id||
                  ' ,quantity => '||p_x_disposition_rec.quantity||
                  ' ,to_workorder_id => '||l_rel_nm_wo_id);
              END IF;

              -- call the required API
              AHL_PRD_PARTS_CHANGE_PVT.move_instance_location(
                  p_api_version            => 1.0,
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_commit                 => FND_API.G_FALSE,
                  p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
                  p_module_type            => NULL,
                  p_default                => FND_API.G_TRUE,
                  p_move_item_instance_tbl => l_move_item_ins_tbl,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data
              );

              IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key,
                  'Call to the API AHL_PRD_PARTS_CHANGE_PVT.move_instance_location returned with status => '||x_return_status);
              END IF;

              -- check the API call return status
              IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                  CLOSE get_rem_inst_id_csr;
                  CLOSE get_rel_nonmaster_wo_id_csr;
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                  CLOSE get_rem_inst_id_csr;
                  CLOSE get_rel_nonmaster_wo_id_csr;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
          END IF;
          CLOSE get_rem_inst_id_csr;
      END IF;
      CLOSE get_rel_nonmaster_wo_id_csr;
  END IF;
  -- SATHAPLI::Bug 7111116, 21-May-2008, fix end

  -- SATHAPLI::FP OGMA Issue# 86 - Automatic Material Return, 27-Dec-2007
  -- If the instance was just removed in Serviceable condition return the part to the Visit Locator.
  -- Note that the ReturnTo_Workorder_Locator will return only if the locator is set at the Visit level.
  -- For FP OGMA Issue# 105 - Non-Serialized Item Maintenance, if the instance was removed in 'Inspection'
  -- condition, then it should not be returned to the locator.
  IF (NVL(x_return_status, FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS AND
      l_disposition_rec.part_change_id IS NULL AND
      p_x_disposition_rec.part_change_id IS NOT NULL AND
      p_x_disposition_rec.condition_id <> NVL(fnd_profile.value('AHL_MTL_MAT_STATUS_UNSERVICABLE'), -1) AND
      p_x_disposition_rec.condition_id <> NVL(fnd_profile.value('AHL_MTL_MAT_STATUS_MRB'), -1) AND
      p_x_disposition_rec.condition_id <> NVL(fnd_profile.value('AHL_MTL_MAT_STATUS_INSPECTION'), -1)) THEN
    OPEN part_change_dtls_csr(p_x_disposition_rec.part_change_id);
    FETCH part_change_dtls_csr INTO l_removed_instance_id, l_part_change_type;
    CLOSE part_change_dtls_csr;
    IF (l_removed_instance_id = p_x_disposition_rec.instance_id AND  -- Removed instance is the Disposition instance
        NVL(l_part_change_type, 'X') IN ('R', 'S')) THEN  -- Removal or Swap
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to call AHL_PRD_PARTS_CHANGE_PVT.ReturnTo_Workorder_Locator with ' ||
                       ' part change id = ' || p_x_disposition_rec.part_change_id ||
                       ' and disposition_id = ' || p_x_disposition_rec.disposition_id);
      END IF;
      AHL_PRD_PARTS_CHANGE_PVT.ReturnTo_Workorder_Locator(p_part_change_id => p_x_disposition_rec.part_change_id,
                                                          p_disposition_id => p_x_disposition_rec.disposition_id,
                                                          x_return_status  => x_return_status,
                                                          x_msg_data       => x_msg_data,
                                                          x_msg_count      => x_msg_count,
                                                          x_ahl_mtltxn_rec => l_ahl_mtltxn_rec);
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Returned from AHL_PRD_PARTS_CHANGE_PVT.ReturnTo_Workorder_Locator: ' ||
                       ' x_return_status = ' || x_return_status);
      END IF;
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END IF;

 --dbms_output.put_line(SubStr('Update_disp:After insert history', 1, 255));
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'End Procedure');
   END IF;

END UPDATE_DISPOSITION;

------------------------------------------------------------------

PROCEDURE CREATE_SR(
          p_init_msg_list               IN          VARCHAR2 := FND_API.G_TRUE,
          p_disposition_rec	        IN          AHL_PRD_DISPOSITION_PVT.disposition_rec_type,
          -- Parameter added by jaramana on Oct 9, 2007 for ER 5883257
          p_mr_asso_tbl                 IN          AHL_PRD_NONROUTINE_PVT.MR_Association_tbl_type,
          x_primary_sr_id               OUT NOCOPY  NUMBER,
          x_non_routine_workorder_id    OUT NOCOPY  NUMBER,
          x_return_status               OUT NOCOPY  VARCHAR2,
          x_msg_count                   OUT NOCOPY  NUMBER,
          x_msg_data                    OUT NOCOPY  VARCHAR2
          ) IS

 -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 13-Dec-2007
 CURSOR get_rem_inst_id_csr (p_part_change_id NUMBER) IS
     SELECT removed_instance_id
     FROM   ahl_part_changes
     WHERE  part_change_id = p_part_change_id;

 -- Cursor to check whether removed instance is in job or not.
 CURSOR chk_disp_inst_job_csr (p_instance_id NUMBER, p_workorder_id NUMBER) IS
     SELECT 'Y'
     FROM   ahl_workorders awo, csi_item_instances csi
     WHERE  awo.wip_entity_id = csi.wip_job_id
     AND    awo.workorder_id  = p_workorder_id
     AND    csi.instance_id   = p_instance_id;

 l_sr_task_tbl    AHL_PRD_NONROUTINE_PVT.sr_task_tbl_type;
 l_visit_id    NUMBER;

 -- Variable added by jaramana on Oct 9, 2007 for ER 5883257
 l_mr_asso_tbl AHL_PRD_NONROUTINE_PVT.MR_Association_tbl_type := p_mr_asso_tbl;


 L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || 'Create_SR';
 l_msg_index_out NUMBER;

 l_inst_in_job_flag    VARCHAR2(1) := 'N';
 l_removed_instance_id NUMBER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean( p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;
     --dbms_output.put_line('Begin Create SR -----------------------------');
       --dbms_output.put_line('Begin Create SR ');
      -- Populate sr_task_tbl
            l_sr_task_tbl(0).Request_date:= sysdate;
            l_sr_task_tbl(0).Summary := p_disposition_rec.summary;

            -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 13-Dec-2007
            -- NR record instance id should be set conditionally, as given below: -
            -- i.e. if part change occurred, then set it with the removed instance as it can be different for non-serialized items
            --      else, set it with disposition instance
            IF (p_disposition_rec.part_change_id IS NOT NULL) THEN
              OPEN get_rem_inst_id_csr(p_disposition_rec.part_change_id);
              FETCH get_rem_inst_id_csr INTO l_removed_instance_id;
              CLOSE get_rem_inst_id_csr;
              l_sr_task_tbl(0).Instance_id := l_removed_instance_id;
            ELSE
              l_sr_task_tbl(0).Instance_id := p_disposition_rec.instance_id;
            END IF;

            l_sr_task_tbl(0).Problem_code := p_disposition_rec.problem_code;
            l_sr_task_tbl(0).duration := p_disposition_rec.duration;

            SELECT visit_id INTO l_visit_id FROM AHL_WORKORDERS WHERE workorder_id = p_disposition_rec.workorder_id;

            l_sr_task_tbl(0).Visit_id:=	 l_visit_id;
            l_sr_task_tbl(0).Originating_wo_id:= p_disposition_rec.workorder_id;
            l_sr_task_tbl(0).Operation_type	:= 'CREATE' ;
            l_sr_task_tbl(0).Severity_id :=  p_disposition_rec.severity_id;
            l_sr_task_tbl(0).source_program_code := 'AHL_NONROUTINE';

            --data provided for service request to add record to the cs_incident_links table
            l_sr_task_tbl(0).object_id := p_disposition_rec.disposition_id;
            l_sr_task_tbl(0).Object_type := 'AHL_PRD_DISP';
            l_sr_task_tbl(0).link_id  := 6;


            --dbms_output.put_line('l_sr_task_tbl(0).Request_date: '|| l_sr_task_tbl(0).Request_date);
            --dbms_output.put_line('l_sr_task_tbl(0).Summary: '|| l_sr_task_tbl(0).Summary);
            --dbms_output.put_line('l_sr_task_tbl(0).Instance_id: '|| l_sr_task_tbl(0).Instance_id);
            --dbms_output.put_line('l_sr_task_tbl(0).Problem_code: '|| l_sr_task_tbl(0).Problem_code);
            --dbms_output.put_line('l_sr_task_tbl(0).Visit_id: '|| l_sr_task_tbl(0).Visit_id);
            --dbms_output.put_line('l_sr_task_tbl(0).Originating_wo_id: '|| l_sr_task_tbl(0).Originating_wo_id);
            --dbms_output.put_line('l_sr_task_tbl(0).Operation_type: '|| l_sr_task_tbl(0).Operation_type);
            --dbms_output.put_line('l_sr_task_tbl(0).Severity_id: '|| l_sr_task_tbl(0).Severity_id);
           --dbms_output.put_line('l_sr_task_tbl(0).source_program_code: '|| l_sr_task_tbl(0).source_program_code);

		  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
		              '--Request_date: '|| l_sr_task_tbl(0).Request_date
                     || '--Summary: '|| l_sr_task_tbl(0).Summary
                     || '--Instance_id: '|| l_sr_task_tbl(0).Instance_id
                     || '--Problem_code: '|| l_sr_task_tbl(0).Problem_code
                     || '--Visit_id: '|| l_sr_task_tbl(0).Visit_id
                     || '--Originating_wo_id: '|| l_sr_task_tbl(0).Originating_wo_id
                     || '--Operation_type: '|| l_sr_task_tbl(0).Operation_type
                     || '--Severity_id: '|| l_sr_task_tbl(0).Severity_id
                     || '--source_program_code: '|| l_sr_task_tbl(0).source_program_code);

		  END IF;
         --  dbms_output.put_line('l_sr_task_tbl(0).type_id: '|| l_sr_task_tbl(0).type_id);
         --  dbms_output.put_line('l_sr_task_tbl(0).type_name: '|| l_sr_task_tbl(0).type_name);
           --dbms_output.put_line('Before Call process_nonroutine_job --return_status'  || x_return_status);

      -- Added by jaramana on October 9, 2007 for ER 5903318
      IF (p_disposition_rec.CREATE_WORK_ORDER_OPTION = 'CREATE_RELEASE_WO') THEN
         l_sr_task_tbl(0).wo_create_flag := 'Y';
         l_sr_task_tbl(0).wo_release_flag := 'Y';
      ELSIF (p_disposition_rec.CREATE_WORK_ORDER_OPTION = 'CREATE_WO') THEN
         l_sr_task_tbl(0).wo_create_flag := 'Y';
         l_sr_task_tbl(0).wo_release_flag := 'N';
      ELSIF (p_disposition_rec.CREATE_WORK_ORDER_OPTION = 'CREATE_WO_NO') THEN
         l_sr_task_tbl(0).wo_create_flag := 'N';
         l_sr_task_tbl(0).wo_release_flag := 'N';
      END IF;

      -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 13-Dec-2007
      -- Check whether the disposition instance/removed instance is issued to the job or not.
      -- NOTE: the l_sr_task_tbl(0).Instance_id set above can be used here as it is set with all the required checks
      OPEN chk_disp_inst_job_csr (l_sr_task_tbl(0).Instance_id, p_disposition_rec.workorder_id);
      FETCH chk_disp_inst_job_csr INTO l_inst_in_job_flag;
      CLOSE chk_disp_inst_job_csr;

      -- Set the move_qty_to_nr_workorder flag to 'Y' conditionally.
      IF(p_disposition_rec.CREATE_WORK_ORDER_OPTION = 'CREATE_RELEASE_WO' AND l_inst_in_job_flag = 'Y') THEN
        l_sr_task_tbl(0).move_qty_to_nr_workorder := 'Y';
      ELSE
        l_sr_task_tbl(0).move_qty_to_nr_workorder := 'N';
      END IF;

      -- set the NR instance quantity
      l_sr_task_tbl(0).instance_quantity := p_disposition_rec.quantity;

      -- Following two attributes added by jaramana on 18-NOV-2008 for bug 7566597
      l_sr_task_tbl(0).resolution_code    := p_disposition_rec.resolution_code;
      l_sr_task_tbl(0).resolution_meaning := p_disposition_rec.resolution_meaning;

      --Calling Service Request API--
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Before process_nonroutine_job');
      END IF;
      AHL_PRD_NONROUTINE_PVT.process_nonroutine_job (
                                               p_api_version => 1.0,
                                               p_commit =>  Fnd_Api.g_false,
                                               p_module_type => NULL,
                                               x_return_status => x_return_status,
                                               x_msg_count => x_msg_count,
                                               x_msg_data => x_msg_data,
                                               p_x_sr_task_tbl => l_sr_task_tbl,
                                  -- Parameter added by jaramana on Oct 9, 2007 for ER 5883257
                                               p_x_mr_asso_tbl => l_mr_asso_tbl
                                               );

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'After process non_nonroutine_job'
                     || '-- x_return_status = '||x_return_status || '| x_msg_count = '||TO_CHAR(x_msg_count));
    END IF;


    --debuging codes
    --dbms_output.put_line('After Call process_nonroutine_job');
    --dbms_output.put_line(SubStr('x_return_status = '||x_return_status,1,255));
    --dbms_output.put_line(SubStr('x_msg_count = '||TO_CHAR(x_msg_count), 1, 255));
--dbms_output.put_line(SubStr('x_msg_data = '||x_msg_data,1,255));

   FOR i IN 1..x_msg_count LOOP
     FND_MSG_PUB.get (
      p_msg_index      => i,
      p_encoded        => FND_API.G_FALSE,
      p_data           => x_msg_data,
      p_msg_index_out  => l_msg_index_out );
     --dbms_output.put_line(SubStr('x_msg_data = '||x_msg_data,1,255));
    END LOOP;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Incident id: ' ||l_sr_task_tbl(0).incident_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Nonroutine_wo_id: ' ||l_sr_task_tbl(0).Nonroutine_wo_id);
    END IF;
	--dbms_output.put_line('Incident_id: ' || l_sr_task_tbl(0).incident_id);
    --dbms_output.put_line('Nonroutine_wo_id: ' || l_sr_task_tbl(0).Nonroutine_wo_id);


    -- Check return status.
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


   x_primary_sr_id := l_sr_task_tbl(0).incident_id;
   x_non_routine_workorder_id := l_sr_task_tbl(0).Nonroutine_wo_id;

-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 12-Dec-2007
-- The API update_item_location and its use has been commented out. Its functionality will
-- now be handled in the API AHL_PRD_NONROUTINE_PVT.process_nonroutine_job.
/*
  -- Added by jaramana on October 8, 2007 for ER 5903256
  -- Automatically change the location of the removed unserviceable instance to the Non Routine Work Order
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_sr_task_tbl(0).Nonroutine_wo_id: ' || l_sr_task_tbl(0).Nonroutine_wo_id);
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_disposition_rec.part_change_id: ' || p_disposition_rec.part_change_id);
  END IF;
  IF (l_sr_task_tbl(0).Nonroutine_wo_id IS NOT NULL AND
      p_disposition_rec.part_change_id IS NOT NULL) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to call update_item_location.');
    END IF;
    update_item_location(p_workorder_id  => l_sr_task_tbl(0).Nonroutine_wo_id,
                         p_instance_id   => p_disposition_rec.instance_id,
                         x_return_status => x_return_status);
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Returned from update_item_location. x_return_status = ' || x_return_status);
    END IF;
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  -- End changes for ER 5903256
*/

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
   END IF;
	--dbms_output.put_line('End Create SR -----------------------------');
END Create_SR;


--------------DERIVE_COLUMNS---------------------------------------------------
PROCEDURE derive_columns(p_x_disposition_rec IN OUT NOCOPY  AHL_PRD_DISPOSITION_PVT.disposition_rec_type)
IS

CURSOR get_organization_csr(p_workorder_id IN NUMBER) IS
      SELECT vi.organization_id from  ahl_workorders wo, ahl_visits_b vi
       WHERE wo.workorder_id = p_workorder_id
       AND wo.visit_id = vi.visit_id;

CURSOR get_instance_from_serial(p_item_id IN NUMBER, p_serial_num IN  VARCHAR2) IS
         SELECT instance_id FROM CSI_ITEM_INSTANCES
         WHERE inventory_item_id = p_item_id AND serial_number = p_serial_num;

CURSOR get_instance_from_lot(p_item_id IN NUMBER, p_lot_num IN  VARCHAR2) IS
         SELECT instance_id FROM CSI_ITEM_INSTANCES
         WHERE inventory_item_id = p_item_id AND lot_number = p_lot_num;

CURSOR instance_csr(p_instance_id IN NUMBER) IS
         SELECT inventory_item_id,
                quantity,
                unit_of_measure,
                last_vld_organization_id,
                inv_master_organization_id,
                serial_number,
                lot_number,
                inventory_revision
          from csi_item_instances
         WHERE instance_id = p_instance_id;


instance_rec instance_csr%ROWTYPE;

l_unit_instance_id NUMBER;    --instance id of the Unit
l_count NUMBER;

l_position_instance_id NUMBER;
l_derived_path_pos_id NUMBER;
l_derived_org_id NUMBER;
l_dummy_lowest_uc_id NUMBER;
l_dummy_status  VARCHAR(30);

x_return_status VARCHAR2(30);
x_msg_count VARCHAR2(30);
x_msg_data VARCHAR(2000);


L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || 'derive_columns';

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  --dbms_output.put_line(SubStr('Begin Derive Column', 1, 255));


  /* JR: 25-SEP-2004
     When creating a disposition from the Part Change UI,
     for a unit, path_position_id will not be null and
     p_disposition_rec.instance_id will contain the following values:
     Removal: The removed instance id
     Swap:    The swapped out (removed) instance id
     Install: Null
     and for an IB Tree, path_position_id will be null and
     p_disposition_rec.instance_id will contain the following values:
     Removal: The removed instance id
     Swap:    The swapped out (removed) instance id
     Install: The installed instance id
  */
  IF (p_x_disposition_rec.path_position_id IS NOT NULL) THEN
    -- derive instance from path position.
    -- Get the instance in the position only if instance has not been
    -- passed and if this API has NOT been called from Part Change
    IF (p_x_disposition_rec.instance_id IS NULL AND p_x_disposition_rec.part_change_id IS NULL) THEN
      l_unit_instance_id := get_unit_instance_id(p_x_disposition_rec.workorder_id);
      IF l_unit_instance_id IS NOT NULL THEN
        AHL_MC_PATH_POSITION_PVT.Get_Pos_Instance (
            p_api_version            => 1.0,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_position_id            => p_x_disposition_rec.path_position_id,
            p_csi_item_instance_id   => l_unit_instance_id,
            x_item_instance_id       => l_position_instance_id,
            x_lowest_uc_csi_id       => l_dummy_lowest_uc_id,
            x_mapping_status         => l_dummy_status
        );
        p_x_disposition_rec.instance_id := l_position_instance_id;
        -- Check return status.
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,'derived Position Instance_id: ' || p_x_disposition_rec.instance_id);
        END IF;
        --dbms_output.put_line(SubStr('derived Position Instance_id: ' || p_x_disposition_rec.instance_id, 1, 255));
      END IF;
    -- Added by jaramana on June 23, 2006 to fix Bug 5205851
    ELSE
      IF (p_x_disposition_rec.instance_id IS NULL AND p_x_disposition_rec.part_change_id IS NOT NULL) THEN
        -- Disposition being created from Part Change UI for installing to an Empty position
        -- Default the condition of the Disposition to Serviceable if not already set
        IF (p_x_disposition_rec.condition_id IS NULL) THEN
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Defaulting Condition to ' || fnd_profile.value('AHL_MTL_MAT_STATUS_SERVICABLE'));
          END IF;
          p_x_disposition_rec.condition_id := fnd_profile.value('AHL_MTL_MAT_STATUS_SERVICABLE');
          IF (p_x_disposition_rec.condition_id IS NULL) THEN
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Profile AHL_MTL_MAT_STATUS_SERVICABLE not set. Unable to derive Default Condition.');
            END IF;
            -- Raise an Exception
            FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_PRD_SVC_COND_PRF_NOT_SET');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
      END IF;
    END IF;
  -- Following added by jaramana on August 07, 2007 for the bug 6328554 (FP of 5948917)
  ELSE
    -- IB Tree
    IF (p_x_disposition_rec.instance_id IS NOT NULL AND
        p_x_disposition_rec.part_change_id IS NOT NULL AND
        p_x_disposition_rec.condition_id IS NULL) THEN
      -- Install of an Instance to an IB Tree from the Part Change UI with creation of
      -- a new Disposition: Default the condition to Serviceable
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Defaulting Condition to ' || fnd_profile.value('AHL_MTL_MAT_STATUS_SERVICABLE'));
      END IF;
      p_x_disposition_rec.condition_id := fnd_profile.value('AHL_MTL_MAT_STATUS_SERVICABLE');
      IF (p_x_disposition_rec.condition_id IS NULL) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Profile AHL_MTL_MAT_STATUS_SERVICABLE not set. Unable to derive Default Condition.');
        END IF;
        -- Raise an Exception
        FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_PRD_SVC_COND_PRF_NOT_SET');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  -- End addition by jaramana on August 07, 2007 for the bug 6328554 (FP of 5948917)
  END IF;

  --derive instance_id
  IF p_x_disposition_rec.instance_id IS NULL THEN
    --derive  instance_id from item and serial_number
    IF p_x_disposition_rec.inventory_item_id IS NOT NULL AND p_x_disposition_rec.serial_number IS NOT NULL THEN
      OPEN get_instance_from_serial(p_x_disposition_rec.inventory_item_id,
                                    p_x_disposition_rec.serial_number);
      FETCH get_instance_from_serial INTO  p_x_disposition_rec.instance_id;
      CLOSE get_instance_from_serial;
    END IF;
    --from item and lot_number derive instance_id
    IF p_x_disposition_rec.inventory_item_id IS NOT NULL AND p_x_disposition_rec.lot_number IS NOT NULL THEN
      OPEN get_instance_from_lot(p_x_disposition_rec.inventory_item_id,
                                 p_x_disposition_rec.lot_number);
      FETCH get_instance_from_lot INTO  p_x_disposition_rec.instance_id;
      CLOSE get_instance_from_lot;
    END IF;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,'derived instance: ' || p_x_disposition_rec.instance_id);
    END IF;
    --dbms_output.put_line(SubStr('derived instance: ' || p_x_disposition_rec.instance_id, 1, 255));
  END IF;

  -- from INSTANCE derive organization, item, quantity and uom
  IF (p_x_disposition_rec.instance_id IS NOT NULL) THEN
    OPEN instance_csr(p_x_disposition_rec.instance_id);
    FETCH instance_csr INTO instance_rec;
    CLOSE instance_csr;

    l_derived_org_id := nvl(instance_rec.last_vld_organization_id, instance_rec.inv_master_organization_id);  --derive organization from instance
    IF p_x_disposition_rec.inventory_item_id IS NULL THEN
      p_x_disposition_rec.inventory_item_id := instance_rec.inventory_item_id;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,'derived item_id ' || instance_rec.inventory_item_id);
      END IF;
      --dbms_output.put_line(SubStr('derived item_id ' || instance_rec.inventory_item_id, 1, 255));
    END IF;
    IF p_x_disposition_rec.quantity IS NULL THEN
      p_x_disposition_rec.quantity := instance_rec.quantity;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'derived quantity ' || instance_rec.quantity);
      END IF;
      --dbms_output.put_line(SubStr('derived quantity ' || instance_rec.quantity, 1, 255));
    END IF;
    IF p_x_disposition_rec.uom IS NULL THEN
      p_x_disposition_rec.uom := instance_rec.unit_of_measure;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'derived uom ' || instance_rec.unit_of_measure);
      END IF;
      --dbms_output.put_line(SubStr('derived uom ' || instance_rec.unit_of_measure, 1, 255));
    END IF;

    --Jerry added on 10/04/05 for fixing an internal bug found by Shailaja/Vadim
    IF p_x_disposition_rec.serial_number IS NULL THEN
      p_x_disposition_rec.serial_number:= instance_rec.serial_number;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'derived serial_number ' || instance_rec.serial_number);
      END IF;
    END IF;

    IF p_x_disposition_rec.lot_number IS NULL THEN
      p_x_disposition_rec.lot_number:= instance_rec.lot_number;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'derived lot_number ' || instance_rec.lot_number);
      END IF;
    END IF;

    IF p_x_disposition_rec.item_revision IS NULL THEN
      p_x_disposition_rec.item_revision := instance_rec.inventory_revision;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'derived item_revision ' || instance_rec.inventory_revision);
      END IF;
    END IF;
    --Jerry's change finishes here

    --Derive path_position_id
    IF p_x_disposition_rec.path_position_id IS NULL THEN

      -- Updated by rbhavsar on 09/27/2007 for Bug 6411059
      -- START: Added IF statement to check if root node of the instance is in uc headers table
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,' Before calling Map_Instance_To_Pos_ID ' || p_x_disposition_rec.path_position_id ||
                   ' Instance id ' || p_x_disposition_rec.instance_id );
      END IF;

      IF (root_node_in_uc_headers(p_x_disposition_rec.instance_id) = TRUE) THEN
         AHL_MC_PATH_POSITION_PVT.Map_Instance_To_Pos_ID (
           p_api_version           =>  1.0,
           x_return_status         =>  x_return_status,
           x_msg_count             =>  x_msg_count,
           x_msg_data              =>  x_msg_data,
           p_csi_item_instance_id  =>  p_x_disposition_rec.instance_id,
           x_path_position_id      =>  l_derived_path_pos_id);

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         p_x_disposition_rec.path_position_id := l_derived_path_pos_id;
         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'derived path_position_id ' || l_derived_path_pos_id);
         END IF;

      END IF; -- END: Updated by rbhavsar Bug 6411059

      --dbms_output.put_line(SubStr('derived path_position_id ' || l_derived_path_pos_id, 1, 255));
    END IF;  -- path_position_id is null
  END IF;  -- instance_id is not null

  --derive organizationid  for item from workorder only if instance is null
  IF(p_x_disposition_rec.inventory_item_id IS NOT NULL AND p_x_disposition_rec.instance_id IS NULL) THEN
    OPEN get_organization_csr(p_x_disposition_rec.workorder_id);
    FETCH get_organization_csr INTO l_derived_org_id;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Derived Org: ' || p_x_disposition_rec.item_org_id);
    END IF;
    --dbms_output.put_line(SubStr('Derived Org: ' || p_x_disposition_rec.item_org_id, 1, 255));
    CLOSE get_organization_csr;
  END IF;

  --assign derived organization id to disposition record's item_org_id
  --ignore organization id from user's input
  p_x_disposition_rec.item_org_id := l_derived_org_id;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
  --dbms_output.put_line(SubStr('End Derive Column', 1, 255));

END derive_columns;



---------------------------LOCAL VALIDATION PROCEDURES------------------------------------

PROCEDURE validate_for_create(p_disposition_rec IN AHL_PRD_DISPOSITION_PVT.disposition_rec_type)
IS

CURSOR exist_position_csr(p_path_position_id IN NUMBER, p_workorder_id IN NUMBER) IS
       SELECT 'X' FROM ahl_mc_path_positions pos
       WHERE pos.path_position_id = p_path_position_id
       AND EXISTS
           (SELECT pos2.path_pos_common_id FROM ahl_prd_dispositions_b dis, ahl_mc_path_positions pos2
            WHERE dis.path_position_id IS NOT NULL
             AND  dis.path_position_id = pos2.path_position_id
             AND dis.workorder_id =  p_workorder_id
             AND nvl(dis.status_code, 'dummy') NOT IN ('COMPLETE', 'TERMINATED')
             AND pos.path_pos_common_id = pos2.path_pos_common_id);

--Begin Performance Tuning
CURSOR get_wo_instance_id(p_workorder_id IN NUMBER) IS
       SELECT nvl(VTS.INSTANCE_ID,VST.ITEM_INSTANCE_ID)
	   FROM ahl_workorders wo, AHL_VISITS_VL VST, AHL_VISIT_TASKS_VL VTS
       WHERE workorder_id = p_workorder_id
         and  WO.VISIT_TASK_ID=VTS.VISIT_TASK_ID
         AND VST.VISIT_ID=VTS.VISIT_ID;
--End performance Tunning

CURSOR item_in_itemgrp_csr(p_inventory_item_id IN NUMBER, p_item_group_id IN NUMBER) IS
       SELECT 'x' FROM ahl_item_associations_b
       WHERE inventory_item_id = p_Inventory_item_id
         AND item_group_id = p_item_group_id;

-- cursor changed by anraj
-- backend validation to check that while create the Item Group given is of type NON-TRACKED
CURSOR val_item_group_csr(p_item_group_id IN NUMBER) IS
       SELECT 'x' FROM ahl_item_groups_b
	   WHERE item_group_id = p_item_group_id
         AND status_code = 'COMPLETE' AND type_code = 'NON-TRACKED';


/* Begin Fix for 4075758 on Dec 21. 2004 by JR */
  -- For non-tracked items, serial or lot numbers
  -- need to be validated only against MTL tables.
/******
CURSOR val_lot_number_csr(p_lot_number IN VARCHAR2, p_inventory_item_id IN NUMBER) IS
       SELECT 'x' FROM csi_item_instances csi
       WHERE lot_number = p_lot_number
         AND inventory_item_id = p_inventory_item_id;

CURSOR val_serial_number_csr(p_serial_number IN VARCHAR2, p_inventory_item_id IN NUMBER) IS
       SELECT 'x' FROM csi_item_instances csi
       WHERE serial_number = p_serial_number
         AND inventory_item_id = p_inventory_item_id;
******/
CURSOR val_lot_number_csr(p_lot_number IN VARCHAR2, p_inventory_item_id IN NUMBER) IS
       SELECT 'x' FROM mtl_lot_numbers
       WHERE lot_number = p_lot_number
         AND inventory_item_id = p_inventory_item_id
       UNION
       SELECT 'x' FROM csi_item_instances csi
       WHERE lot_number = p_lot_number
         AND inventory_item_id = p_inventory_item_id;

CURSOR val_serial_number_csr(p_serial_number IN VARCHAR2, p_inventory_item_id IN NUMBER) IS
       SELECT 'x' FROM mtl_serial_numbers
       WHERE serial_number = p_serial_number
         AND inventory_item_id = p_inventory_item_id
       UNION
       SELECT 'x' FROM csi_item_instances csi
       WHERE serial_number = p_serial_number
         AND inventory_item_id = p_inventory_item_id;
/* End Fix for 4075758 on Dec 21. 2004 */

CURSOR instance_quantity_csr(p_instance_id IN NUMBER) IS
       SELECT quantity from csi_item_instances WHERE instance_id = p_instance_id;

CURSOR instance_uom_csr(p_instance_id IN NUMBER) IS
       SELECT unit_of_measure from csi_item_instances WHERE instance_id = p_instance_id;

CURSOR item_class_uom_csr(p_uom_code IN VARCHAR2, p_inventory_item_id NUMBER) IS
/*
       SELECT 'X' FROM ahl_item_class_uom_v
       WHERE uom_code = p_uom_code AND inventory_item_id = p_inventory_item_id;
*/
      --AnRaj: Changed query, Perf Bug#4908609,Issue#2
      SELECT   'X'
      from     MTL_UNITS_OF_MEASURE_TL
      where    uom_class = (
                              select   distinct uom.uom_class
                              from     MTL_UNITS_OF_MEASURE_TL uom
                              where    uom.uom_code = (  select   distinct primary_uom_code
                                                         from     mtl_system_items
                                                         where    inventory_item_id = p_inventory_item_id
                                                      )
                           )
      and      uom_code = p_uom_code;

CURSOR val_Collection_id_csr(p_collection_id IN NUMBER) IS
       SELECT 'x' FROM qa_results WHERE collection_id = p_collection_id;

CURSOR get_item_id_csr(p_instance_id IN NUMBER) IS
       SELECT inventory_item_id from csi_item_instances WHERE instance_id = p_instance_id;

CURSOR val_uom_csr(p_uom IN VARCHAR2) IS
       SELECT  'x' FROM mtl_units_of_measure_vl
       WHERE uom_code = p_uom;

CURSOR item_revisions_csr (p_revision  IN  VARCHAR2, p_item_id IN NUMBER, p_organization_id IN NUMBER)  IS
       SELECT 'x' FROM   mtl_item_revisions
        WHERE  inventory_item_id = p_item_id
            AND organization_id = p_organization_id
            AND revision = p_revision;

CURSOR part_change_csr(c_part_change_id IN NUMBER) IS
       SELECT REMOVED_INSTANCE_ID, INSTALLED_INSTANCE_ID, PART_CHANGE_TYPE
       FROM AHL_PART_CHANGES
       WHERE PART_CHANGE_ID = c_part_change_id;

-- Added the following for fixing Bug#:4059944
-- To find whether the Item is IB Trackable
CURSOR item_is_ib_trackable(p_inventory_item_id IN NUMBER) IS
	SELECT NVL(MTL.comms_nl_trackable_flag, 'N')  trackable_flag
	FROM   MTL_SYSTEM_ITEMS_KFV MTL
	WHERE MTL.INVENTORY_ITEM_ID= p_inventory_item_id;

-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 13-Dec-2007
-- Cursor to check whether the disposition item is serialized or not.
CURSOR chk_non_serialized_csr(p_inventory_item_id NUMBER, p_item_org_id NUMBER) IS
	SELECT 'X'
	FROM   mtl_system_items_b
        WHERE  inventory_item_id          = p_inventory_item_id
        AND    organization_id            = p_item_org_id
        AND    serial_number_control_code = 1;

item_is_trackable VARCHAR2(1);

l_serial_control  NUMBER;
l_qty_revision_control NUMBER;
l_lot_control NUMBER;



l_exist VARCHAR(1);
l_quantity NUMBER;
l_uom VARCHAR(3);

l_wo_organization_id NUMBER;

l_unit_instance_id NUMBER;
l_pos_instance_id NUMBER;
l_parent_instance_id NUMBER;
l_dummy_rel_id NUMBER;
l_dummy_lowest_uc_id NUMBER;
l_mapping_status  VARCHAR(30);
l_return_status VARCHAR(30);
l_msg_count  NUMBER;
l_msg_data   VARCHAR(200);

l_wo_instance_id NUMBER;
l_wo_root_instance_id NUMBER;        --Root Instance of workorder instance
l_dis_root_instance_id NUMBER;      --Root Instance of disposition instance.
l_item_id NUMBER;

l_position_empty BOOLEAN := FALSE;

l_pc_rem_instance_id  NUMBER;
l_pc_inst_instance_id NUMBER;
l_pc_type             VARCHAR2(1);

l_plan_id   NUMBER;


L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || 'validate_for_create';
l_dummy          VARCHAR2(1);
l_srl_flag       VARCHAR2(1)            := 'Y';

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  --dbms_output.put_line(SubStr('Begin Validate_For_Create', 1, 255));

  --WORKORDER
  IF (p_disposition_rec.workorder_id IS NULL) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_WO_ID_REQ');       -- Workorder is required to create disposition.
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    validate_workorder(p_disposition_rec.workorder_id);
    IF(workorder_editable(p_disposition_rec.workorder_id) = FALSE) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_PRD_DIS_WO_NOT_EDITABLE');  --Cannot Create Disposition Because Workorder is not editable.
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  IF (p_disposition_rec.path_position_id IS NULL AND p_disposition_rec.inventory_item_id IS NULL) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_PRD_DIS_POS_OR_ITEM_REQ');    --Path Position or Item is required to create a disposition
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_disposition_rec.item_org_id IS NOT NULL AND p_disposition_rec.inventory_item_id IS NULL THEN
    FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_PRD_DIS_CANNOT_ENTER_ORG');    --Cannot enter organization id.
    FND_MSG_PUB.ADD;
  END IF;

  -- Validate Part Change and get details
  IF(p_disposition_rec.part_change_id IS NOT NULL) THEN
    OPEN part_change_csr(p_disposition_rec.part_change_id);
    FETCH part_change_csr INTO l_pc_rem_instance_id,
                               l_pc_inst_instance_id,
                               l_pc_type;
    IF (part_change_csr%NOTFOUND) THEN
      CLOSE part_change_csr;
      FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DIS_INV_PART_CHG_ID');    -- Invalid part change id
      FND_MESSAGE.SET_TOKEN('PART_CHNG_ID', p_disposition_rec.part_change_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE part_change_csr;
  END IF;

  --PATH POSITION VALIDATION  ---------------------------------
  IF (p_disposition_rec.path_position_id IS NOT NULL) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Check Path Position');
    END IF;
    --dbms_output.put_line(SubStr('In Validate_For_Create -- Check Path Position ', 1, 255));
    --Check for valid path_position_id
    validate_path_position(p_disposition_rec.path_position_id);

    -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 13-Dec-2007
    -- Multiple dispositions can be created for non-serialized item/position. So relax the only-one-disposition
    -- restriction for non-serilized item/position.
    OPEN chk_non_serialized_csr(p_disposition_rec.inventory_item_id, p_disposition_rec.item_org_id);
    FETCH chk_non_serialized_csr INTO l_dummy;
    IF (chk_non_serialized_csr%NOTFOUND) THEN
      -- The chk_non_serialized_csr will not fetch results if item id is NULL.
      -- If item id is NULL, then this disposition is being created for empty position.
      -- Check for non-serialized position by calling the API AHL_MC_PATH_POSITION_PVT.Is_Position_Serial_Controlled
      IF (p_disposition_rec.inventory_item_id IS NULL) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                           'Before API AHL_MC_PATH_POSITION_PVT.Is_Position_Serial_Controlled call l_srl_flag => '||l_srl_flag);
        END IF;

        l_srl_flag := AHL_MC_PATH_POSITION_PVT.Is_Position_Serial_Controlled(
                                                                             NULL,
                                                                             p_disposition_rec.path_position_id
                                                                            );

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                           'After API AHL_MC_PATH_POSITION_PVT.Is_Position_Serial_Controlled call l_srl_flag => '||l_srl_flag);
        END IF;
      END IF;

      --If item/position is serialized, then validate that path position does not exist in other dispositions
      IF (l_srl_flag = 'Y') THEN
        OPEN exist_position_csr(p_disposition_rec.path_position_id, p_disposition_rec.workorder_id);
        FETCH exist_position_csr INTO l_exist;
        IF(exist_position_csr%FOUND) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_POS_OTHER');
          FND_MSG_PUB.ADD;
        END IF;
        CLOSE exist_position_csr;
      END IF; -- if l_srl_flag = 'Y'
    END IF; -- if chk_non_serialized_csr%NOTFOUND
    CLOSE chk_non_serialized_csr;

    --Check if workorder's instance is in UC tree
    l_unit_instance_id := get_unit_instance_id(p_disposition_rec.workorder_id);
    IF(l_unit_instance_id IS NULL) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_NOT_UC_NO_POS');    --Workorder's instance does not belong to UC hence path position is not allowed
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_EVENT, L_DEBUG_KEY, 'About to call AHL_MC_PATH_POSITION_PVT.Get_Pos_Instance with ' ||
               ' p_position_id = ' || p_disposition_rec.path_position_id ||
               ', p_csi_item_instance_id = ' || l_unit_instance_id);
    END IF;

    AHL_MC_PATH_POSITION_PVT.Get_Pos_Instance (
      p_api_version           => 1.0,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data,
      p_position_id           => p_disposition_rec.path_position_id,
      p_csi_item_instance_id  => l_unit_instance_id,
      x_item_instance_id      => l_pos_instance_id,
      x_parent_instance_id    => l_parent_instance_id,
      x_relationship_id       => l_dummy_rel_id,
      x_lowest_uc_csi_id      => l_dummy_lowest_uc_id,
      x_mapping_status        => l_mapping_status
    );

    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_EVENT, L_DEBUG_KEY, 'Returned from call to AHL_MC_PATH_POSITION_PVT.Get_Pos_Instance: ' ||
               ' x_return_status ' || l_return_status ||
               ', x_parent_instance_id ' || l_parent_instance_id ||
               ', x_mapping_status = ' || l_mapping_status);
    END IF;
    -- Check return status.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- SATHAPLI:: Bug 6836572, 19-Mar-2008
    -- If the workorder instance is root instance of an installed sub UC, and the sub UC has been removed during parts change, then
    -- the API get_unit_instance_id would return the sub UC's root instance, instead of the top most UC's root instance. This
    -- would result in the API AHL_MC_PATH_POSITION_PVT.Get_Pos_Instance returning x_mapping_status as 'NA'.
    -- To bypass this, we can just check for the part change to have taken place or not. If yes, then we can go ahead with the
    -- Disposition creation.

    IF (l_mapping_status = 'NA') THEN
      -- Check if removal was done or not.
      IF(p_disposition_rec.part_change_id IS NOT NULL) THEN
        -- Ensure that the disposition instance is the same as the removed instance.
        IF (NVL(p_disposition_rec.instance_id, -1) <> l_pc_rem_instance_id) THEN
          FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_INV_INSTANT_ID');
          FND_MESSAGE.SET_TOKEN('INSTANT_ID', p_disposition_rec.instance_id);
          FND_MSG_PUB.ADD;
        END IF;
      ELSE
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_POS_NOT_WO_UC');    --Position is not in the same Unit Configuration as that of workorder instance.
        FND_MSG_PUB.ADD;
      END IF; -- part change check
    ELSIF (l_mapping_status = 'PARENT_EMPTY') THEN
       FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_PARENT_EMPTY');    --Cannot select a position whose parent is empty
       FND_MSG_PUB.ADD;
    ELSIF (l_mapping_status = 'EMPTY') THEN
      -- Check if this create_disposition is called from Part Change
      IF(p_disposition_rec.part_change_id IS NOT NULL) THEN
        IF (l_pc_type = G_PART_CHANGE_REMOVE) THEN
          -- Disposition is for the removed instance
          -- Ensure that the disposition instance is the same as the removed instance
          IF (NVL(p_disposition_rec.instance_id, -1) <> l_pc_rem_instance_id) THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_INV_INSTANT_ID');
            FND_MESSAGE.SET_TOKEN('INSTANT_ID', p_disposition_rec.instance_id);
            FND_MSG_PUB.ADD;
          END IF;
        ELSE
          -- G_PART_CHANGE_INSTALL and G_PART_CHANGE_SWAP are not possible since the position is empty
          -- May have to throw an exception if control come here
          NULL;
        END IF;
      ELSE
        l_position_empty := TRUE;
        IF (p_disposition_rec.instance_id IS NOT NULL) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_PRD_DIS_POS_EMPTY_NO_INST');   --Position is empty cannot enter instance number.
          FND_MSG_PUB.ADD;
        END IF;
        --Check if parent instance of this empty position is in the same tree as workorder instance
        OPEN get_wo_instance_id(p_disposition_rec.workorder_id);
        FETCH get_wo_instance_id INTO l_wo_instance_id;
        CLOSE get_wo_instance_id;
        IF l_parent_instance_id <> l_wo_instance_id THEN  --only need to check when instance is not the same as workorder instance
          --get root instance for workorder instance
          l_wo_root_instance_id := get_root_instance_id(l_wo_instance_id);

          --get root instance for the empty position parent instance
          l_dis_root_instance_id := get_root_instance_id(l_parent_instance_id);

          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_wo_instance_id = ' || l_wo_instance_id ||
               ', l_wo_root_instance_id = ' || l_wo_root_instance_id ||
               ', l_parent_instance_id = ' || l_parent_instance_id ||
               ', l_dis_root_instance_id = ' || l_dis_root_instance_id);
          END IF;

          IF nvl(l_wo_root_instance_id, -1) <> nvl(l_dis_root_instance_id, -1) THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DIS_POS_NOT_WO_UC');   -- Instance is not in the same unit as workorder instance
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
      END IF; -- Part Change
    ELSIF (l_mapping_status = 'MATCH') THEN
      -- Check if this create_disposition is called from Part Change
      IF(p_disposition_rec.part_change_id IS NOT NULL) THEN
        -- Position is not empty and Part Change has already happened
        IF (l_pc_type = G_PART_CHANGE_INSTALL) THEN
          -- Disposition is for the empty position (before the install)
          IF (p_disposition_rec.instance_id IS NOT NULL) THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_INV_INSTANT_ID');
            FND_MESSAGE.SET_TOKEN('INSTANT_ID', p_disposition_rec.instance_id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          l_position_empty := TRUE;
        ELSIF (l_pc_type = G_PART_CHANGE_SWAP) THEN
          -- Disposition is for the instance that was swapped out
          -- Ensure that the disposition instance is the same as the removed instance
          IF (NVL(p_disposition_rec.instance_id, l_pc_rem_instance_id) <> l_pc_rem_instance_id) THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_INV_INSTANT_ID');
            FND_MESSAGE.SET_TOKEN('INSTANT_ID', p_disposition_rec.instance_id);
            FND_MSG_PUB.ADD;
          END IF;
        ELSE
          -- G_PART_CHANGE_REMOVE is not possible since the position is not empty
          -- May have to throw an exception if control come here
          NULL;
        END IF;
      ELSE
        IF(nvl(l_pos_instance_id, -1) <> nvl(p_disposition_rec.instance_id, -1)) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_INST_NO_MATCH');    -- Position's instance and disposition instance do not match
          FND_MESSAGE.Set_Token('POS_INSTANT_ID', l_pos_instance_id);
          FND_MESSAGE.Set_Token('DIS_INSTANT_ID', p_disposition_rec.instance_id);
          FND_MSG_PUB.ADD;
        END IF;
      END IF;  -- Part Change
    END IF;  -- l_mapping_status
  END IF;  -- end path_position

 --ITEM ---------------------------------

 IF(p_disposition_rec.inventory_item_id IS NOT NULL) THEN
    --dbms_output.put_line(SubStr('In Validate_For_Create -- Check ITem  ', 1, 255));
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Check Check Item');
    END IF;
    IF (l_position_empty = TRUE) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_PRD_DIS_POS_EMPTY_NO_ITM');    --Item does not belong to the item group
      FND_MSG_PUB.ADD;
    END IF;

    validate_item(p_disposition_rec.inventory_item_id, p_disposition_rec.item_org_id, p_disposition_rec.workorder_id);

    --item group exist requires item to exist
    IF(p_disposition_rec.item_group_id IS NOT NULL) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Check ITem and item group relation');
      END IF;
      --dbms_output.put_line(SubStr('In Validate_For_Create -- Check ITem and item group relation ', 1, 255));
      OPEN item_in_itemgrp_csr( p_disposition_rec.inventory_item_id, p_disposition_rec.item_group_id);
      FETCH item_in_itemgrp_csr INTO l_exist;
        IF item_in_itemgrp_csr%NOTFOUND THEN
          FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_PRD_DIS_NOT_IN_ITMGRP');    --Item does not belong to the item group
          FND_MSG_PUB.ADD;
        END IF;
      CLOSE item_in_itemgrp_csr;
    END IF;  -- item_group_id is not null

     -- Bug#:4059944
     -- Forcing the user to select an instance if the item is Trackable
     OPEN item_is_ib_trackable (p_disposition_rec.inventory_item_id);
     FETCH item_is_ib_trackable INTO item_is_trackable;
     CLOSE item_is_ib_trackable;
     IF( item_is_trackable ='Y') THEN
        IF (p_disposition_rec.instance_id IS NULL) THEN
        -- validation to force the user to pick an instance if Disposition Item is Trackable in the IB
	   FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_TR_ITEM_INST_MAND');    -- Invalid item group
	   FND_MESSAGE.Set_Token('ITEM_NAME',p_disposition_rec.item_number);
	   FND_MSG_PUB.ADD;
	    END IF;
	 ELSE   --start fix Bug#4075758 Item is non-tracked
	  validate_Item_Control(p_disposition_rec.inventory_item_id , p_disposition_rec.item_org_id,
                                         p_disposition_rec.serial_number,
                                          p_disposition_rec.item_revision,
										  p_disposition_rec.lot_number);
		--end  Bug#4075758

    END IF;
  END IF;  -- item id is not null

  --ITEM GROUP-----------------------------
  IF(p_disposition_rec.item_group_id IS NOT NULL) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Check ITem group ');
    END IF;
     --dbms_output.put_line(SubStr('In Validate_For_Create -- Check ITem Group ', 1, 255));
    OPEN val_item_group_csr(p_disposition_rec.item_group_id);
    FETCH val_item_group_csr INTO l_exist;
      IF (val_item_group_csr%NOTFOUND) THEN
         FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_INV_ITEM_GRP');    -- Invalid item group
        FND_MSG_PUB.ADD;
      END IF;
    CLOSE val_item_group_csr;

    IF(p_disposition_rec.inventory_item_Id IS NULL) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_ITMGRP_REQ_ITM');    --Since item group is present, item number needs to be entered.
      FND_MSG_PUB.ADD;
    END IF;
    --path position id exist then item group must be null
    IF(p_disposition_rec.path_position_id IS NOT NULL)THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_POS_ITMGRP');   -- Can only enter either position or item group but not both.
      FND_MSG_PUB.ADD;
    END IF;
  END IF;  -- item_group_id is not null

  --INSTANCE-----------------------------
  IF(p_disposition_rec.instance_id IS NOT NULL) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Check Instance_id');
    END IF;
    --dbms_output.put_line(SubStr('In Validate_For_Create -- Check Instance Number', 1, 255));
    validate_instance(p_disposition_rec.instance_id,
                      p_disposition_rec.workorder_id,
                      p_disposition_rec.path_position_id,
                      p_disposition_rec.part_change_id);

    IF(p_disposition_rec.inventory_item_id IS NULL) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_ITEM_REQ');    -- Item number is required
      FND_MSG_PUB.ADD;
    ELSE
      OPEN get_item_id_csr(p_disposition_rec.instance_id);
      FETCH get_item_id_csr INTO l_item_id;
      IF l_item_id <> p_disposition_rec.inventory_item_id THEN
         FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_ITEM_NO_MATCH');    -- Item does not match with instance's item.
         FND_MSG_PUB.ADD;
      END IF;
      CLOSE get_item_id_csr;
    END IF;
  END IF;

  --LOT NUMBER----------------------------------
  IF(p_disposition_rec.lot_number IS NOT NULL) THEN
     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Check Lot_number');
      END IF;
    --dbms_output.put_line(SubStr('In Validate_For_Create -- Check Lot Number', 1, 255));
    IF(p_disposition_rec.inventory_item_id IS NULL) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_ITEM_REQ');    -- Item number is required
      FND_MSG_PUB.ADD;
    ELSE
      OPEN val_lot_number_csr(p_disposition_rec.lot_number, p_disposition_rec.inventory_item_id);
      FETCH val_lot_number_csr INTO l_exist;
      IF (val_lot_number_csr%NOTFOUND) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_INV_LOT');    -- Invalid lot_number and item combination
        FND_MSG_PUB.ADD;
      END IF;
      CLOSE val_lot_number_csr;
    END IF;
  END IF;

  --SERIAL NUMBER -----------------------------------
  IF(p_disposition_rec.serial_number IS NOT NULL) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Check Serial_Number');
    END IF;
    --dbms_output.put_line(SubStr('In Validate_For_Create -- Check Serial Number', 1, 255));
    IF(p_disposition_rec.inventory_item_id IS NULL) THEN
      --dbms_output.put_line(SubStr('In Validate_For_Create -- Check Serial Number--check item is null', 1, 255));
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_ITEM_REQ');    -- Item is required
      FND_MSG_PUB.ADD;
    ELSE
      --dbms_output.put_line(SubStr('In Validate_For_Create -- before open val_serial_number_csr', 1, 255));
      OPEN val_serial_number_csr(p_disposition_rec.serial_number, p_disposition_rec.inventory_item_id);
      FETCH val_serial_number_csr INTO l_exist;
      IF (val_serial_number_csr%NOTFOUND) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_INV_SERIAL');    -- Invalid serial number and item combination
        FND_MSG_PUB.ADD;
      END IF;
      CLOSE val_serial_number_csr;
    END IF;
    --dbms_output.put_line(SubStr('In Validate_For_Create --end check serial Number', 1, 255));
  END IF;

  --QUANTITY -----------------------------------
  IF (p_disposition_rec.quantity IS NULL AND l_position_empty = FALSE) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_QTY_REQ');    -- Quantity cannot be null
    FND_MSG_PUB.ADD;
  ELSIF (p_disposition_rec.quantity IS NOT NULL) THEN
    IF p_disposition_rec.quantity <= 0 THEN
       FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_QTY_LESS_ZERO');    -- Quantity must be greater than zero
       FND_MSG_PUB.ADD;
    END IF;
    IF p_disposition_rec.instance_id IS NOT NULL THEN
      OPEN instance_quantity_csr(p_disposition_rec.instance_id);
      FETCH instance_quantity_csr into l_quantity;
      -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 13-Dec-2007
      -- The quantity check should be modified from '<>' to '>'. Subsequently, the error has been modified to
      -- 'Quantity should not be greater than instance quantity'.
      IF (p_disposition_rec.quantity > l_quantity) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_QTY_INST_QTY');    -- Quantity cannot be different from instance's quantity
        FND_MSG_PUB.ADD;
      END IF;
      CLOSE instance_quantity_csr;
    END IF;
  END IF;

  --UOM-------------------------------------------------------------
  IF( p_disposition_rec.uom IS NULL AND l_position_empty = FALSE )THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_UOM_REQ');    -- UOM cannot be null
    FND_MSG_PUB.ADD;
  ELSIF ( p_disposition_rec.uom IS NOT NULL) THEN
    OPEN val_uom_csr(p_disposition_rec.uom);
    FETCH val_uom_csr INTO l_exist;
    IF val_uom_csr%NOTFOUND THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_INV_UOM');    -- Invalid UOM.
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE val_uom_csr;

    IF p_disposition_rec.instance_id IS NOT NULL THEN
      OPEN instance_uom_csr(p_disposition_rec.instance_id);
      FETCH instance_uom_csr INTO l_uom;
      IF (p_disposition_rec.uom <> l_uom) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_INV_INST_UOM');    -- Invalid UOM.  UOM must be the same as instance's UOM.
        FND_MSG_PUB.ADD;
      END IF;
      CLOSE instance_uom_csr;
    END IF;

    IF p_disposition_rec.inventory_item_id IS NOT NULL THEN
      OPEN item_class_uom_csr(p_disposition_rec.uom, p_disposition_rec.inventory_item_id);
      FETCH item_class_uom_csr into l_exist;
      IF item_class_uom_csr%NOTFOUND THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_INV_ITEM_UOM');    -- Invalid UOM.  UOM must belong to the item's primary uom
        FND_MSG_PUB.ADD;
      END IF;
      CLOSE item_class_uom_csr;
    END IF;
  END IF;

  --COLLECTION ID-------------------------------------------------------------
  -- Added by jaramana on March 25, 2005 to fix bug 4243200
  -- First check if a QA Plan is defined in the workorder Org.
  AHL_QA_RESULTS_PVT.get_qa_plan( p_api_version   => 1.0,
                                  p_init_msg_list => FND_API.G_False,
                                  p_commit => FND_API.G_FALSE,
                                  p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                                  p_default => FND_API.G_FALSE,
                                  p_organization_id => p_disposition_rec.item_org_id,
                                  p_transaction_number => 2004,  -- MRB_TRANSACTION_NUMBER
                                  p_col_trigger_value => fnd_profile.value('AHL_MRB_DISP_PLAN_TYPE'),
                                  x_return_status => l_return_status,
                                  x_msg_count => l_msg_count,
                                  x_msg_data => l_msg_data,
                                  x_plan_id  => l_plan_id);
  --IF p_disposition_rec.condition_id = fnd_profile.value('AHL_MTL_MAT_STATUS_MRB') AND p_disposition_rec.instance_id IS NOT NULL THEN
  IF p_disposition_rec.condition_id = fnd_profile.value('AHL_MTL_MAT_STATUS_MRB') AND
     p_disposition_rec.instance_id IS NOT NULL AND
     l_plan_id IS NOT NULL THEN
    IF p_disposition_rec.collection_id IS NULL THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_QA_RESULT_REQ');    --  QA Result Required
      FND_MSG_PUB.ADD;
    ELSE
      validate_collection_id(p_disposition_rec.collection_id);
    END IF;
  END IF;
  -- End fix for bug 4243200

  IF ((p_disposition_rec.instance_id IS NULL  OR
	   (nvl(p_disposition_rec.condition_id, -1) <> fnd_profile.value('AHL_MTL_MAT_STATUS_MRB')
           AND nvl(p_disposition_rec.condition_id, -1) <> fnd_profile.value('AHL_MTL_MAT_STATUS_UNSERVICABLE')
	   )
	 )AND
	 ( p_disposition_rec.summary IS NOT NULL OR p_disposition_rec.problem_code IS NOT NULL
	       OR p_disposition_rec.severity_id IS NOT NULL
	 )) THEN
       FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DIS_SR_NOT_REQ');      --Non Conformance (SR) information is not required
       FND_MSG_PUB.ADD;
  END IF;

  --OPERATION_ID--------------------------------------------------------
  IF (p_disposition_rec.wo_operation_id IS NOT NULL) THEN
    validate_wo_operation(p_disposition_rec.workorder_id, p_disposition_rec.wo_operation_id );
  END IF;

  --validate item revision--------------------------------------------------------
  IF (p_disposition_rec.item_revision IS NOT NULL) THEN
    IF p_disposition_rec.inventory_item_id IS NULL THEN
      FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_PRD_DIS_ITM_REV_REQ_ITM');    --Cannot enter an item revision without entering item
      FND_MSG_PUB.ADD;
    ELSE
      OPEN item_revisions_csr(p_disposition_rec.item_revision, p_disposition_rec.inventory_item_id, p_disposition_rec.item_org_id);
      FETCH item_revisions_csr INTO l_exist;
      IF item_revisions_csr%NOTFOUND THEN
        FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_PRD_DIS_INV_ITEM_REV');    --Invalid item revision
        FND_MSG_PUB.ADD;
      END IF;
      CLOSE item_revisions_csr;
    END IF;
  END IF;

  IF FND_MSG_PUB.count_msg > 0 THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
   END IF;

  --dbms_output.put_line(SubStr('End Validate_For_Create', 1, 255));
END validate_for_create;

--------------------------------------------------------------------------------
PROCEDURE convert_values_to_ids
(
  p_x_prd_disposition_rec IN OUT NOCOPY AHL_PRD_DISPOSITION_PVT.disposition_rec_type
) IS

CURSOR instance_id_csr(p_instance_number IN VARCHAR2) IS
    SELECT instance_id from csi_item_instances
    WHERE instance_number = p_instance_number;

CURSOR item_group_id_csr(p_item_group_name IN VARCHAR2) IS
       SELECT item_group_id from ahl_item_groups_b
	   WHERE name = p_item_group_name AND status_code = 'COMPLETE';

CURSOR item_id_csr(p_item_number IN VARCHAR2) IS
       SELECT inventory_item_id FROM MTL_SYSTEM_ITEMS_KFV
       WHERE concatenated_segments = p_item_number;

CURSOR condition_id_csr(p_condition_meaning IN VARCHAR2) IS
       SELECT status_id FROM mtl_material_statuses_vl
       WHERE status_code = p_condition_meaning;


CURSOR wo_operation_id_csr(p_workorder_id IN NUMBER, p_operation_seq IN NUMBER) IS
       SELECT workorder_operation_id from ahl_workorder_operations
       WHERE workorder_id = p_workorder_id AND operation_sequence_num = p_operation_seq;

CURSOR severity_id_csr(p_severity_name IN VARCHAR2) IS
       SELECT incident_severity_id from cs_incident_severities_vl
	    WHERE name = p_severity_name
              AND incident_subtype = 'INC'
	      AND trunc(sysdate) between trunc(nvl(start_date_active,sysdate))  and  trunc(nvl(end_date_active,sysdate));

CURSOR problem_code_csr(p_problem_meaning IN VARCHAR2) IS
/*
SELECT fl.lookup_code  FROM fnd_lookup_values_vl FL
	   WHERE fl.meaning = p_problem_meaning
	     AND lookup_type = 'REQUEST_PROBLEM_CODE'
         AND trunc(sysdate) BETWEEN trunc(nvl(start_date_active,sysdate)) AND trunc(nvl(end_date_active,sysdate))
		 AND (( NOT EXISTS (SELECT 1 FROM CS_SR_PROB_CODE_MAPPING_V WHERE INCIDENT_TYPE_ID = FND_PROFILE.Value('AHL_PRD_SR_TYPE')
			   AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE_ACTIVE,SYSDATE)) AND TRUNC(NVL(END_DATE_ACTIVE,SYSDATE))) )
					OR ( EXISTS (SELECT 1 FROM CS_SR_PROB_CODE_MAPPING_V MAP WHERE MAP.INCIDENT_TYPE_ID    = FND_PROFILE.Value('AHL_PRD_SR_TYPE')
					            AND MAP.INVENTORY_ITEM_ID IS NULL AND MAP.PROBLEM_CODE = FL.LOOKUP_CODE
							   AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(MAP.START_DATE_ACTIVE,SYSDATE)) AND TRUNC(NVL(MAP.END_DATE_ACTIVE,SYSDATE)))));
*/
--    AnRaj: Changed query, Perf Bug#4908609,Issue#6
SELECT   fl.lookup_code
FROM     fnd_lookup_values_vl FL
WHERE    fl.meaning = p_problem_meaning
AND      lookup_type = 'REQUEST_PROBLEM_CODE'
AND      trunc(sysdate) BETWEEN trunc(nvl(start_date_active,sysdate))
AND      trunc(nvl(end_date_active,sysdate)) ;

L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || 'convert_values_to_ids';
l_instance_id NUMBER;
l_item_group_id NUMBER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  --dbms_output.put_line(SubStr('Begin Convert_val_to_id', 1, 255));
  IF (p_x_prd_disposition_rec.instance_number IS NOT NULL AND  p_x_prd_disposition_rec.instance_number <> FND_API.G_MISS_CHAR) THEN
    OPEN instance_id_csr(p_x_prd_disposition_rec.instance_number);
    FETCH instance_id_csr INTO p_x_prd_disposition_rec.instance_id;
    IF(instance_id_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_INV_INST_NUM');
      FND_MESSAGE.Set_Token('INTANCE_NUM', p_x_prd_disposition_rec.instance_number);
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE instance_id_csr;
  ELSIF(p_x_prd_disposition_rec.instance_number = FND_API.G_MISS_CHAR) THEN
     p_x_prd_disposition_rec.instance_id := NULL;
  END IF;

  IF (p_x_prd_disposition_rec.item_group_name IS NOT NULL AND  p_x_prd_disposition_rec.item_group_name <> FND_API.G_MISS_CHAR) THEN
    OPEN item_group_id_csr(p_x_prd_disposition_rec.item_group_name);
    FETCH item_group_id_csr INTO p_x_prd_disposition_rec.item_group_id;
    IF(item_group_id_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_INV_ITM_GRPNAME');
      FND_MESSAGE.Set_Token('ITEM_GROUP', p_x_prd_disposition_rec.item_group_name);
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE item_group_id_csr;
    ELSIF(p_x_prd_disposition_rec.item_group_name = FND_API.G_MISS_CHAR) THEN
      p_x_prd_disposition_rec.item_group_id := NULL;
    END IF;

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Before convert Item Number: ' ||p_x_prd_disposition_rec.item_number);
   END IF;
   --dbms_output.put_line(SubStr('convert Item Number', 1, 255));
  IF (p_x_prd_disposition_rec.item_number IS NOT NULL AND  p_x_prd_disposition_rec.item_number <> FND_API.G_MISS_CHAR) THEN
    OPEN item_id_csr(p_x_prd_disposition_rec.item_number);
    FETCH item_id_csr INTO p_x_prd_disposition_rec.inventory_item_id;
    IF(item_id_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_INV_ITEM_NUM');
      FND_MESSAGE.Set_Token('ITEM_NUM', p_x_prd_disposition_rec.item_number);
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE item_id_csr;
  ELSIF(p_x_prd_disposition_rec.item_number = FND_API.G_MISS_CHAR) THEN
      p_x_prd_disposition_rec.inventory_item_id := NULL;
  END IF;

  IF (p_x_prd_disposition_rec.operation_sequence IS NOT NULL AND  p_x_prd_disposition_rec.operation_sequence <> FND_API.G_MISS_NUM) THEN
    OPEN wo_operation_id_csr(p_x_prd_disposition_rec.workorder_id, p_x_prd_disposition_rec.operation_sequence);
    FETCH wo_operation_id_csr INTO p_x_prd_disposition_rec.wo_operation_id;
    IF(wo_operation_id_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_INV_OPER_SEQ');
      FND_MESSAGE.Set_Token('OPER_SEQ', p_x_prd_disposition_rec.operation_sequence);
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE wo_operation_id_csr;
  ELSIF(p_x_prd_disposition_rec.operation_sequence = FND_API.G_MISS_NUM) THEN
      p_x_prd_disposition_rec.wo_operation_id := NULL;
  END IF;

  IF (p_x_prd_disposition_rec.condition_meaning IS NOT NULL AND  p_x_prd_disposition_rec.condition_meaning <> FND_API.G_MISS_CHAR) THEN
    OPEN condition_id_csr(p_x_prd_disposition_rec.condition_meaning);
    FETCH condition_id_csr INTO p_x_prd_disposition_rec.condition_id;
    IF(condition_id_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_INV_CONDITION');
      FND_MESSAGE.Set_Token('CONDITION', p_x_prd_disposition_rec.condition_meaning);
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE condition_id_csr;
  ELSIF(p_x_prd_disposition_rec.condition_meaning = FND_API.G_MISS_CHAR) THEN
      p_x_prd_disposition_rec.condition_id := NULL;
  END IF;

  IF (p_x_prd_disposition_rec.severity_name IS NOT NULL AND  p_x_prd_disposition_rec.severity_name <> FND_API.G_MISS_CHAR) THEN
    OPEN severity_id_csr( p_x_prd_disposition_rec.severity_name);
    FETCH severity_id_csr INTO p_x_prd_disposition_rec.severity_id;
    IF(severity_id_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_INV_SEVERITY_NAME');
      FND_MESSAGE.Set_Token('NAME', p_x_prd_disposition_rec.severity_name);
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE severity_id_csr;
  ELSIF(p_x_prd_disposition_rec.severity_name = FND_API.G_MISS_CHAR) THEN
      p_x_prd_disposition_rec.severity_id := NULL;
  END IF;

  IF (p_x_prd_disposition_rec.problem_meaning IS NOT NULL AND  p_x_prd_disposition_rec.problem_meaning <> FND_API.G_MISS_CHAR) THEN
    OPEN problem_code_csr( p_x_prd_disposition_rec.problem_meaning);
    FETCH problem_code_csr INTO p_x_prd_disposition_rec.problem_code;
    IF(problem_code_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_INV_PROBLEM');
      FND_MESSAGE.Set_Token('PROBLEM', p_x_prd_disposition_rec.problem_meaning);
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE problem_code_csr;
   ELSIF(p_x_prd_disposition_rec.problem_meaning = FND_API.G_MISS_CHAR) THEN
      p_x_prd_disposition_rec.problem_code := NULL;
   END IF;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
   END IF;


 --dbms_output.put_line(SubStr('End Convert_val_to_id', 1, 255));

END convert_values_to_ids;






--------------------------------------------------------------------------------
PROCEDURE validate_collection_id(p_collection_id IN NUMBER) IS
  CURSOR val_Collection_id_csr(p_collection_id IN NUMBER) IS
       SELECT 'x' FROM qa_results WHERE collection_id = p_collection_id;

l_exist VARCHAR(1);

BEGIN
  IF p_collection_id IS NOT NULL THEN
    OPEN val_collection_id_csr(p_collection_id);
    FETCH val_collection_id_csr into l_exist;
    IF val_collection_id_csr%NOTFOUND THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_INV_COLLECTION_ID');    --  Invalid collection Id
      FND_MESSAGE.Set_Token('COLL_ID', p_collection_id);
      FND_MSG_PUB.ADD;
    END IF;
  END IF;
END validate_collection_id;


--Validate_workorder----------------------------------------------------
PROCEDURE validate_workorder(p_workorder_id IN NUMBER) IS
  CURSOR workorder_csr(p_workorder_id IN NUMBER) IS
    SELECT 'x' FROM AHL_WORKORDERS
    WHERE workorder_id = p_workorder_id;

l_exist VARCHAR(1);

BEGIN
  OPEN workorder_csr(p_workorder_id);
  FETCH workorder_csr INTO l_exist;
  IF workorder_csr%NOTFOUND THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_INV_WORKORDER_ID');    --  Invalid Workorder Id
    FND_MESSAGE.set_token('WORKORDER_ID', p_workorder_id);
    FND_MSG_PUB.ADD;
    CLOSE workorder_csr;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    CLOSE workorder_csr;
  END IF;

END validate_workorder;


--Validate_Path_Position---------------------------------------------
PROCEDURE validate_path_position(p_path_position_id IN NUMBER) IS
  CURSOR path_position_csr(p_path_position_id IN NUMBER) IS
    SELECT 'x' FROM ahl_mc_path_positions
    WHERE path_position_id = p_path_position_id;

l_exist VARCHAR(1);

BEGIN
  OPEN path_position_csr(p_path_position_id);
  FETCH path_position_csr INTO l_exist;
  IF path_position_csr%NOTFOUND THEN
    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_INV_PATH_POSITION');
    FND_MESSAGE.SET_TOKEN('PATH_POS_ID', p_path_position_id);
    FND_MSG_PUB.ADD;
    CLOSE path_position_csr;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    CLOSE path_position_csr;
  END IF;
END validate_path_position;

--Validate_item---------------------------------------------
PROCEDURE validate_item(p_inventory_item_id IN NUMBER, p_organization_id IN NUMBER, p_workorder_id IN NUMBER) IS

  CURSOR get_wo_organization_csr(p_workorder_id NUMBER) IS
      SELECT vi.organization_id from  ahl_workorders wo, ahl_visits_b vi
       WHERE wo.workorder_id = p_workorder_id
	     AND wo.visit_id = vi.visit_id;

  CURSOR val_item_csr(p_item_id NUMBER, p_organization_id NUMBER) IS
    SELECT 'x' FROM mtl_system_items_kfv
	WHERE inventory_item_id = p_inventory_item_id
	  AND organization_id = p_organization_id;


l_exist VARCHAR(1);
l_wo_organization_id NUMBER;

BEGIN


  OPEN val_item_csr(p_inventory_item_id, p_organization_id);
  FETCH val_item_csr INTO l_exist;
  IF val_item_csr%NOTFOUND THEN
    CLOSE val_item_csr;   --Close cursor before raising exception
    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_INV_ITEM_ID');
	FND_MESSAGE.SET_TOKEN('ITEM_ID', p_inventory_item_id);
	FND_MSG_PUB.ADD;
	RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE val_item_csr;


  OPEN get_wo_organization_csr(p_workorder_id);
  FETCH get_wo_organization_csr INTO l_wo_organization_id;
  CLOSE get_wo_organization_csr;

  IF l_wo_organization_id <> p_organization_id THEN
    -- need to check whether if item is defined in workorder organization
    OPEN val_item_csr(p_inventory_item_id, l_wo_organization_id);
    FETCH val_item_csr INTO l_exist;
    IF val_item_csr%NOTFOUND THEN
      CLOSE val_item_csr;  --close cursor before raise an exception
      FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_ITEM_NOT_IN_WO_ORG');   --Item is not defined in workorder's organization
	  FND_MESSAGE.SET_TOKEN('ITEM_ID', p_inventory_item_id);
	  FND_MSG_PUB.ADD;
	  RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE val_item_csr;
  END IF;

END validate_item;

--validate_Item_Control--------------------------------------
--Check if items is serial control then require serial_number
-- if item is lot control then requires lot_number
-- if item is quantity revision control then requires revision number
PROCEDURE validate_Item_Control(p_item_id IN NUMBER, p_org_id IN NUMBER,
                                          p_serial_number IN VARCHAR2,
                                          p_item_rev_number IN VARCHAR2,
										  p_lot_number IN VARCHAR2) IS


CURSOR item_control_csr(p_item_id IN NUMBER, p_org_id IN NUMBER) IS
  SELECT serial_number_control_code, revision_qty_control_code,  lot_control_code
  FROM MTL_SYSTEM_ITEMS_KFV
  WHERE inventory_item_id = p_item_id
  AND organization_id = p_org_id;

l_item_crl_rec item_control_csr%ROWTYPE;
l_serial_flag  VARCHAR2(1);
l_rev_qty_flag VARCHAR2(1);
l_lot_flag VARCHAR2(1);

BEGIN

  OPEN item_control_csr(p_item_id, p_org_id);
  FETCH item_control_csr INTO l_item_crl_rec;
  IF item_control_csr%FOUND THEN
    IF l_item_crl_rec.lot_control_code = 2 THEN
      l_lot_flag:='Y';
    ELSE
      l_lot_flag:='N';
    END IF;

	IF l_item_crl_rec.revision_qty_control_code = 2 THEN
      l_rev_qty_flag:='Y';
    ELSE
      l_rev_qty_flag:='N';
    END IF;

    IF l_item_crl_rec.serial_number_control_code = 1 THEN
      l_serial_flag:='N';
    ELSE
      l_serial_flag:='Y';
    END IF;
  END IF;
  CLOSE item_control_csr;

  IF l_serial_flag = 'Y' AND p_serial_number IS NULL THEN
    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DIS_SERIAL_REQ');    --Serial Number is required
    FND_MSG_PUB.ADD;
  END IF;

  IF l_rev_qty_flag = 'Y' AND p_item_rev_number IS NULL THEN
    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DIS_ITEM_REV_REQ');    --Item Revision Number is required
    FND_MSG_PUB.ADD;
  END IF;

  IF l_lot_flag = 'Y' AND p_lot_number IS NULL THEN
    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DIS_LOT_NUM_REQ');    --Lot Number is required
    FND_MSG_PUB.ADD;
  END IF;

END validate_Item_Control;




--Validate Instance------------------------------------------------------------

PROCEDURE validate_instance(p_instance_id IN NUMBER, p_workorder_id IN NUMBER, p_path_position_id IN NUMBER, p_part_change_id IN NUMBER) IS

  CURSOR instance_csr(p_instance_id IN NUMBER) IS
    SELECT 'x' from csi_item_instances
    where instance_id = p_instance_id;

  CURSOR instance_in_wip_csr(p_instance_id IN NUMBER, p_workorder_id IN NUMBER) IS
    SELECT 'x' from csi_item_instances csi, ahl_workorders wo
     WHERE instance_id = p_instance_id
       and wo.wip_entity_id = csi.wip_job_id
       and csi.location_type_code NOT IN ('PO','IN-TRANSIT','PROJECT','INVENTORY')
       and trunc(sysdate) between trunc(nvl(csi.active_start_date, sysdate)) and trunc(nvl(csi.active_end_date, sysdate));

  CURSOR instance_in_disp_csr(p_instance_id IN NUMBER, p_workorder_id IN NUMBER) IS
     SELECT 'x' from ahl_prd_dispositions_b WHERE
       workorder_id = p_workorder_id
       and instance_id = p_instance_id
       and nvl(status_code, ' ') NOT IN ('COMPLETE', 'TERMINATED');

--Begin Performance Tuning
CURSOR get_wo_instance_id(p_workorder_id IN NUMBER) IS
     SELECT nvl(VTS.INSTANCE_ID,VST.ITEM_INSTANCE_ID)
       FROM ahl_workorders wo, AHL_VISITS_VL VST, AHL_VISIT_TASKS_VL VTS
       WHERE workorder_id = p_workorder_id
         and  WO.VISIT_TASK_ID=VTS.VISIT_TASK_ID
         AND VST.VISIT_ID=VTS.VISIT_ID;
--End Performance Tuning

-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 13-Dec-2007
-- Cursor to check whether the disposition item is serialized or not.
CURSOR chk_non_serialized_csr(p_instance_id NUMBER) IS
     SELECT 'X'
     FROM   mtl_system_items_b mtl, csi_item_instances csi
     WHERE  csi.instance_id                                              = p_instance_id
     AND    csi.inventory_item_id                                        = mtl.inventory_item_id
     AND    NVL(csi.inv_organization_id, csi.inv_master_organization_id) = mtl.organization_id
     AND    mtl.serial_number_control_code                               = 1;

l_wo_instance_id NUMBER;
l_wo_root_instance_id NUMBER;        --Root Instance of workorder instance
l_dis_root_instance_id NUMBER;      --Root Instance of disposition instance.
l_exist VARCHAR(1);
L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || 'validate_instance' ;

-- Added by jaramana on August 7, 2007 to support IB Trees
l_unit_config_id   NUMBER;
l_unit_config_name ahl_unit_config_headers.name%TYPE;
l_return_status    VARCHAR2(1);
l_dummy            VARCHAR2(1);

BEGIN

  OPEN instance_csr(p_instance_id);
  FETCH instance_csr INTO l_exist;
  IF instance_csr%NOTFOUND THEN
    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_INV_INSTANT_ID');
    FND_MESSAGE.SET_TOKEN('INSTANT_ID', p_instance_id);
    FND_MSG_PUB.ADD;
  END IF;
  CLOSE instance_csr;

  -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 13-Dec-2007
  -- Multiple dispositions for the same instance/position are allowed for non-serialized items.
  OPEN chk_non_serialized_csr(p_instance_id);
  FETCH chk_non_serialized_csr INTO l_dummy;
  IF (chk_non_serialized_csr%NOTFOUND) THEN
    OPEN instance_in_disp_csr(p_instance_id, p_workorder_id);
    FETCH instance_in_disp_csr INTO l_exist;
    IF instance_in_disp_csr%FOUND THEN
      -- Added by jaramana on August 7, 2007 to support IB Trees
      -- Allow duplicate instances for IB Trees when created from Part Change
      AHL_PRD_PARTS_CHANGE_PVT.Get_Unit_Config_Information(p_item_instance_id => NULL,
                                                           p_workorder_id     => p_workorder_id,
                                                           x_unit_config_id   => l_unit_config_id,
                                                           x_unit_config_name => l_unit_config_name,
                                                           x_return_status    => l_return_status);
      IF (l_unit_config_name IS NULL AND p_part_change_id IS NOT NULL) THEN
        -- IB Tree, Disposition created from Part Change UI: Allow duplicates
        NULL;
      ELSE
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DIS_INST_IN_DISP');    --Instance already exist in another not-completed or not-terminated disposition.
        FND_MSG_PUB.ADD;
      END IF;
      -- End changes by jaramana on August 7, 2007 to support IB Trees
    END IF;
    CLOSE instance_in_disp_csr;
  END IF;
  CLOSE chk_non_serialized_csr;

  IF p_path_position_id IS NOT NULL THEN
    IF p_part_change_id IS NOT NULL THEN
      -- Called from Part Change UI
      -- Part Change (Removal or Swap) has already occurred
      -- Cannot verify if the disposition instance is in the same unit as the workorder
      -- since the disposition instance has already been removed
      NULL;
    ELSE
      --path position exists then need to check if the instance is in the same tree as workorder instance
      --Get Workorder Instance Id
      OPEN get_wo_instance_id(p_workorder_id);
      FETCH get_wo_instance_id INTO l_wo_instance_id;
      CLOSE get_wo_instance_id;

      IF l_wo_instance_id <> p_instance_id THEN
        --get root instance for workorder instance
        l_wo_root_instance_id := get_root_instance_id(l_wo_instance_id);

        --get root instance for disposition instance
        l_dis_root_instance_id := get_root_instance_id(p_instance_id);

        IF nvl(l_wo_root_instance_id, -1) <> nvl(l_dis_root_instance_id, -1) THEN
          --dbms_output.put_line(' before throw the error root instance are not the same');
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_wo_instance_id:' || l_wo_instance_id);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_wo_root_instance_id:' || l_wo_root_instance_id);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_dis_root_instance_id:' || l_dis_root_instance_id);
          END IF;
          FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DIS_INST_IN_UC');   -- Instance is not in the same unit as workorder instance
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;  -- Root Instances are not the same
      END IF;  -- l_wo_instance_id <> p_instance_id
    END IF;  -- p_part_change_id is null
  ELSE    --then it is a stand alone instance need to check if instance is issued to the job
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Stand alone instance');
    END IF;
    -- Following lines commented out by jaramana on August 8, 2007
    -- In the case of IB Tree, it does not make sense to force the instance to be in the job.
    -- The instance may be currently installed on the IB Tree and creation of Disposition should be
    -- be allowed for it (1. From Part Change, the Installation Disposition is created after
    -- the instance is installed on the IB Tree. 2. While creating a disposition for removing,
    -- the instance is still on the IB Tree which may not have been issued to the job)
    /***
    OPEN instance_in_wip_csr(p_instance_id, p_workorder_id);
    FETCH instance_in_wip_csr INTO l_exist;
    IF instance_in_wip_csr%NOTFOUND THEN
      CLOSE instance_in_wip_csr;
      FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_INST_NOT_ISSUED');   -- Instance is not issued to the job
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE instance_in_wip_csr;
    ***/
  END IF;

  --dbms_output.put_line(SubStr('end validate_instance ', 1, 255));
END validate_instance;

-----validate workorder operation--------------------------------------

PROCEDURE validate_wo_operation(p_workorder_id IN NUMBER, p_wo_operation_id IN NUMBER) IS

CURSOR val_wo_operation_csr(p_workorder_id IN NUMBER, p_wo_operation_id IN NUMBER) IS
       SELECT 'x' FROM ahl_workorder_operations
       WHERE workorder_operation_id = p_wo_operation_id
         AND workorder_id = p_workorder_id;

l_exist VARCHAR(1);

BEGIN
  OPEN val_wo_operation_csr(p_workorder_id, p_wo_operation_id);
  FETCH val_wo_operation_csr INTO l_exist;
  IF val_wo_operation_csr%NOTFOUND THEN
    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_INV_OPERATION');    --Invalid operation id.
    FND_MESSAGE.SET_TOKEN('OPER_ID', p_wo_operation_id);
    FND_MSG_PUB.ADD;
  END IF;
  CLOSE val_wo_operation_csr;

END validate_wo_operation;

-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 13-Dec-2007
-- Modified the API to accept the instance quantity, and modified the validations to accommodate: -
-- 1) non-serialized items
-- 2) disposition for empty positions
PROCEDURE validate_part_change(p_part_change_id IN NUMBER, p_disp_instance_id IN NUMBER, p_disp_quantity IN NUMBER) IS

  -- Begin Changes made by jaramana on August 07, 2007 for the bug 6328554 (FP of 5948917)
  CURSOR part_change_csr IS
    SELECT removed_instance_id, installed_instance_id, NVL(part_change_type, 'X'), quantity
    FROM ahl_part_changes
    WHERE part_change_id = p_part_change_id;

  -- Cursor to get the disposition instance details.
  CURSOR get_inst_dtls_csr(c_instance_id IN NUMBER) IS
    SELECT SERIAL_NUMBER, INVENTORY_ITEM_ID, QUANTITY
    FROM CSI_ITEM_INSTANCES
    WHERE INSTANCE_ID = c_instance_id;

  l_removed_instance_id   NUMBER;
  l_installed_instance_id NUMBER;
  l_part_change_type      VARCHAR2(1);
  l_disp_inst_dtls        get_inst_dtls_csr%ROWTYPE;
  l_rem_inst_dtls         get_inst_dtls_csr%ROWTYPE;
  l_part_change_quantity  NUMBER;
  L_DEBUG_KEY             CONSTANT VARCHAR2(150) := G_LOG_PREFIX || 'validate_part_change';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   L_DEBUG_KEY || '.begin ',
                   'At the start of the procedure.' ||
                   ' ,p_part_change_id  = ' || p_part_change_id ||
                   ' ,p_disp_instance_id = ' || p_disp_instance_id ||
                   ' ,p_disp_quantity = ' || p_disp_quantity );
  END IF;

  -- If the disposition is not for an empty position, then get the disposition instance details.
  IF p_disp_instance_id IS NOT NULL THEN
    OPEN get_inst_dtls_csr(p_disp_instance_id);
    FETCH get_inst_dtls_csr INTO l_disp_inst_dtls;
    CLOSE get_inst_dtls_csr;
  END IF;

  OPEN part_change_csr;
  FETCH part_change_csr INTO l_removed_instance_id, l_installed_instance_id, l_part_change_type, l_part_change_quantity;
  IF part_change_csr%NOTFOUND THEN
    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DIS_INV_PART_CHG_ID');    -- Invalid part change id
    FND_MESSAGE.SET_TOKEN('PART_CHNG_ID', p_part_change_id);
    FND_MSG_PUB.ADD;
  ELSIF (l_part_change_type IN ('R', 'S')) THEN  -- Remove or Swap
    -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 13-Dec-2007
    -- Compare instances only if it is serialized.
    IF (l_disp_inst_dtls.SERIAL_NUMBER IS NOT NULL) THEN
      IF (NVL(p_disp_instance_id, -1) <> nvl(l_removed_instance_id, -1)) THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DIS_INV_REMOVE_INST');   -- Removed instance in part change is not the same as disposition instance
        FND_MESSAGE.SET_TOKEN('REMOVED_INST', l_removed_instance_id);
        FND_MESSAGE.SET_TOKEN('DISP_INST', p_disp_instance_id);
        FND_MSG_PUB.ADD;
      END IF;
    ELSE
      -- Non-serialized: Removed instance can be different from the Disposition Instance.
      -- Compare only item and quantity.
      IF (NVL(p_disp_instance_id, -1) <> nvl(l_removed_instance_id, -1)) THEN
        -- Get the removed instance details.
        OPEN get_inst_dtls_csr(l_removed_instance_id);
        FETCH get_inst_dtls_csr INTO l_rem_inst_dtls;
        CLOSE get_inst_dtls_csr;

        IF (l_disp_inst_dtls.inventory_item_id <> l_rem_inst_dtls.inventory_item_id OR
            nvl(p_disp_quantity,l_part_change_quantity) <> l_part_change_quantity) THEN
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'validate part change non serial item' ||
                           ', l_disp_inst_dtls.inventory_item_i ' || l_disp_inst_dtls.inventory_item_id ||
                           ', l_rem_inst_dtls.inventory_item_id ' || l_rem_inst_dtls.inventory_item_id  ||
                           ', p_disp_instance_id ' || p_disp_instance_id ||
                           ', p_removed_instance_id ' || l_removed_instance_id ||
                           ', p_disp_quantity ' || p_disp_quantity ||
                           ', l_part_change_quantity ' || l_part_change_quantity);
          END IF;

          -- The Message AHL_PRD_DIS_INV_REMOVE_INST is not accurate in this case, but is probably ok
          FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DIS_INV_REMOVE_INST');   -- Removed instance in part change is not the same as disposition instance
          FND_MESSAGE.SET_TOKEN('REMOVED_INST', l_removed_instance_id);
          FND_MESSAGE.SET_TOKEN('DISP_INST', p_disp_instance_id);
          FND_MSG_PUB.ADD;
        END IF;  -- Item and Quantity Mismatch
      END IF;  -- Instances are different
    END IF;  -- Disp Instance's Serial Number is null or not
  ELSE
    -- Changed since the disposition instance will always
    -- (even after installation) be null for a disposition created against an empty position
    -- IF (NVL(p_disp_instance_id, nvl(l_installed_instance_id, -1)) <> nvl(l_installed_instance_id, -1)) THEN
    IF p_disp_instance_id IS NOT NULL AND l_installed_instance_id IS NOT NULL AND p_disp_instance_id <> l_installed_instance_id THEN
      FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DIS_INV_INSTALL_INST');   -- Installed instance in part change is not the same as disposition instance
      FND_MESSAGE.SET_TOKEN('INSTALLED_INST', l_installed_instance_id);
      FND_MESSAGE.SET_TOKEN('DISP_INST', p_disp_instance_id);
      FND_MSG_PUB.ADD;
    END IF;  -- Disposition Instance is not the same as the Installation Instance
  END IF;  -- Part Change Found, and Part Change Type Check
  CLOSE part_change_csr;
  -- End Changes made by jaramana on August 07, 2007 for the bug 6328554 (FP of 5948917)

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     L_DEBUG_KEY || '.end',
                     'At the end of the procedure ' );
  END IF;
END validate_part_change;

------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Calculate_Status
--  Type        : Private
--  Function    : Derives the status of the disposition
--  Pre-reqs    :
--  Parameters  :
--
--  Calculate_Status Parameters:
--       p_disp_rec    IN  the final disposition record
--	 x_status_code OUT NOCOPY the output of the disposition record
--
--  End of Comments.
PROCEDURE Calculate_Status (
    p_disposition_Rec     IN  AHL_PRD_DISPOSITION_PVT.disposition_rec_type,
    x_status_code         OUT  NOCOPY   VARCHAR2)
IS
--
CURSOR get_disposition_csr (p_disposition_id IN NUMBER) IS
/*
SELECT disp.status_code, disp.trackable_flag,
pc.return_mtl_txn_id mtl_txn_id,
pc.installed_part_change_id install_pc_id,
AHL_PRD_DISP_MTL_TXN_PVT.calculate_txned_qty(disp.disposition_id) mtl_txn_qty
FROM AHL_PRD_DISPOSITIONS_V disp, AHL_PART_CHANGES_V pc
WHERE disp.disposition_id = p_disposition_id
AND disp.part_change_id = pc.part_change_id (+);
*/
-- AnRaj: Changed query, Perf Bug#4908609,Issue#5
SELECT   disp.status_code,
         decode(disp.instance_id, null, decode(disp.path_position_id, null, 'N', 'Y'), 'Y') trackable_flag ,
         pc.return_mtl_txn_id mtl_txn_id,
         pc.installed_part_change_id install_pc_id,
         pc.part_change_type,
         AHL_PRD_DISP_MTL_TXN_PVT.calculate_txned_qty(disp.disposition_id) mtl_txn_qty
FROM     AHL_PRD_DISPOSITIONS_B disp,
         AHL_PART_CHANGES_V pc
WHERE    disp.disposition_id = p_disposition_id
AND      disp.part_change_id = pc.part_change_id (+);

--
CURSOR get_trackable_csr (p_inv_item_id IN NUMBER,
                          p_inv_org_id IN NUMBER) IS
SELECT NVL(MTL.comms_nl_trackable_flag, 'N')  trackable_flag
FROM   MTL_SYSTEM_ITEMS_KFV MTL
WHERE MTL.INVENTORY_ITEM_ID= p_inv_item_id
  AND MTL.organization_id =p_inv_org_id;
--
CURSOR get_part_change_type_csr (p_part_change_id IN NUMBER) IS
SELECT part_change_type
  FROM AHL_PART_CHANGES
 WHERE part_change_id = p_part_change_id;
--
CURSOR get_pos_mandatory_csr(p_instance_id IN NUMBER) IS
SELECT rel.position_necessity_code
FROM AHL_MC_RELATIONSHIPS rel, CSI_II_RELATIONSHIPS CSI
WHERE csi.subject_id = p_instance_id
    AND rel.relationship_id = TO_NUMBER(CSI.position_reference)
    AND CSI.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
    AND TRUNC(nvl(CSI.ACTIVE_START_DATE, sysdate-1)) < TRUNC(sysdate)
    AND TRUNC(nvl(CSI.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate);

--For fixing bug 4085156, added by Jerry on 12/27/2004
CURSOR get_pos_mandatory(c_path_position_id NUMBER) IS
SELECT B.position_necessity_code
FROM ahl_mc_path_position_nodes A,
     ahl_mc_relationships B,
     ahl_mc_headers_b C
WHERE A.path_position_id = c_path_position_id
  and A.sequence = (select max(D.sequence)
                     from ahl_mc_path_position_nodes D
                    group by D.path_position_id
                    having D.path_position_id = c_path_position_id)
  and A.mc_id = C.mc_id
  and A.version_number = C.version_number
  and C.mc_header_id = B.mc_header_id
  and A.position_key = B.position_key;

--
l_disp_dtl_rec  get_disposition_csr%ROWTYPE;
l_pos_mand_flag   VARCHAR2(30);
L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || 'Calculate_Status';

--
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   L_DEBUG_KEY || '.begin',
                   'At the start of the procedure. p_disposition_rec.disposition_id = ' || p_disposition_rec.disposition_id);
  END IF;

  --Fetch existing parameters.
  IF (p_disposition_rec.disposition_id IS NOT NULL) THEN
    OPEN get_disposition_csr(p_disposition_rec.disposition_id);
    FETCH get_disposition_csr into l_disp_dtl_rec;
    CLOSE get_disposition_csr;
  ELSE
     OPEN get_trackable_csr (p_disposition_rec.inventory_item_id,
                             p_disposition_rec.item_org_id);
     FETCH get_trackable_csr into l_disp_dtl_rec.trackable_flag;
     CLOSE get_trackable_csr;
  END IF;

  -- Added by jaramana on August 7, 2007
  IF (l_disp_dtl_rec.part_change_type IS NULL AND p_disposition_rec.part_change_id IS NOT NULL) THEN
    OPEN get_part_change_type_csr(p_disposition_rec.part_change_id);
    FETCH get_part_change_type_csr INTO l_disp_dtl_rec.part_change_type;
    CLOSE get_part_change_type_csr;
  END IF;

  --determine if instance position is mandatory.
  IF (p_disposition_rec.instance_id IS NOT NULL) THEN
    OPEN get_pos_mandatory_csr (p_disposition_rec.instance_id);
    FETCH get_pos_mandatory_csr INTO l_pos_mand_flag;
    CLOSE get_pos_mandatory_csr;
  --For fixing bug 4085156, this ELSIF section was added by Jerry on 12/27/2004
  ELSIF (p_disposition_rec.path_position_id IS NOT NULL) THEN
    OPEN get_pos_mandatory(p_disposition_rec.path_position_id);
    FETCH get_pos_mandatory INTO l_pos_mand_flag;
    CLOSE get_pos_mandatory;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_disposition_rec.immediate_disposition_code = ' || p_disposition_rec.immediate_disposition_code ||
                   ', p_disposition_rec.instance_id = ' || p_disposition_rec.instance_id ||
                   ', p_disposition_rec.part_change_id = ' || p_disposition_rec.part_change_id ||
                   ', l_disp_dtl_rec.part_change_type = ' || l_disp_dtl_rec.part_change_type ||
                   ', l_disp_dtl_rec.trackable_flag = ' || l_disp_dtl_rec.trackable_flag);
  END IF;

  ----dbms_output.put_line( l_disp_dtl_rec.trackable_flag);
  --dbms_output.put_line( p_disposition_rec.quantity||'<>'||l_disp_dtl_rec.mtl_txn_qty);

  --If terminated, can not change status.
  IF (p_disposition_rec.status_code = 'TERMINATED'
     OR l_disp_dtl_rec.status_code = 'TERMINATED') THEN
      x_status_code := 'TERMINATED';

  --secondary disposition required
  ELSIF ((p_disposition_rec.immediate_disposition_code = 'BFS' OR
          p_disposition_rec.immediate_disposition_code = 'NON_CONF') AND
          p_disposition_rec.secondary_disposition_code IS NULL) THEN
       x_status_code := 'SECONDARY_REQD';

  --Added by Jerry Li on 01/18/2005 for fixing bug 4095487 issue 1.
  ELSIF (p_disposition_rec.immediate_disposition_code IN ('NA','NOT_RECEIVED','NOT_REMOVED')
          AND p_disposition_rec.path_position_id IS NOT NULL
          AND l_disp_dtl_rec.trackable_flag = 'Y'
          AND p_disposition_rec.instance_id IS NOT NULL) THEN
        x_status_code := NULL;

  -- Added by jaramana on August 7, 2007 to set the Dispositions created only for
  -- the sake of installation to status COMPLETE as soon as the installation is done.
  ELSIF (p_disposition_rec.immediate_disposition_code NOT IN ('NA','NOT_REMOVED')
          -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 13-Dec-2007
          -- Check for path_position_id as well, so as to cater to disposition for empty position.
          AND (p_disposition_rec.instance_id IS NOT NULL OR p_disposition_rec.path_position_id IS NOT NULL)
          AND p_disposition_rec.part_change_id IS NOT NULL
          AND NVL(l_disp_dtl_rec.part_change_type, 'X') = 'I') THEN
        x_status_code := 'COMPLETE';

  ----Added by Jerry Li on 01/18/2005 for fixing bug 4095487 issue 2a.
  ELSIF (p_disposition_rec.immediate_disposition_code = 'NOT_RECEIVED'
         AND p_disposition_rec.path_position_id IS NULL
         AND l_disp_dtl_rec.trackable_flag <> 'Y'
         AND p_disposition_rec.quantity > NVL(l_disp_dtl_rec.mtl_txn_qty, 0)) THEN
        x_status_code := NULL;

  --Part Removal required, if path position is given and no part change has occurred
  ELSIF (p_disposition_rec.immediate_disposition_code NOT IN ('NA','NOT_RECEIVED','NOT_REMOVED')
          AND NVL(p_disposition_rec.secondary_disposition_code, 'NULL') <> 'REWORK_NR'
          AND p_disposition_rec.path_position_id IS NOT NULL
          AND p_disposition_rec.instance_id IS NOT NULL
          AND p_disposition_rec.part_change_id IS NULL) THEN
        x_status_code := 'PART_CHANGE_REQD';

  -- Non-conformance request required. When tracked instance is in non-serviceable condition
  ELSIF (p_disposition_rec.immediate_disposition_code NOT IN ('NA','NOT_RECEIVED','NOT_REMOVED')
         AND l_disp_dtl_rec.trackable_flag = 'Y'
         AND (p_disposition_rec.condition_id = fnd_profile.value('AHL_MTL_MAT_STATUS_UNSERVICABLE')
            OR p_disposition_rec.condition_id = fnd_profile.value('AHL_MTL_MAT_STATUS_MRB'))
         AND p_disposition_rec.primary_service_request_id IS NULL) THEN
      x_status_code := 'NON_CONF_REQD';

  --Mtl_txn required
 ELSIF (p_disposition_rec.immediate_disposition_code NOT IN ('NA','NOT_REMOVED')
        AND nvl(p_disposition_rec.secondary_disposition_code,'NULL') <> 'HOLD'
        AND (( l_disp_dtl_rec.trackable_flag = 'Y'
              AND p_disposition_rec.part_change_id IS NOT NULL
              AND l_disp_dtl_rec.mtl_txn_id IS NULL)
           OR (l_disp_dtl_rec.trackable_flag = 'Y'
              AND p_disposition_rec.part_change_id IS NULL
              AND p_disposition_rec.quantity > NVL(l_disp_dtl_rec.mtl_txn_qty, 0))
           OR (l_disp_dtl_rec.trackable_flag <> 'Y'
               AND p_disposition_rec.quantity > NVL(l_disp_dtl_rec.mtl_txn_qty, 0)))) THEN
          x_status_code := 'MTL_TXN_REQD';

 --Removal Complete
 ELSIF (p_disposition_rec.immediate_disposition_code NOT IN ('NA','NOT_RECEIVED','NOT_REMOVED')
        AND l_disp_dtl_rec.trackable_flag = 'Y'
        AND p_disposition_rec.path_position_id IS NOT NULL
        AND p_disposition_rec.part_change_id IS NOT NULL
        AND l_disp_dtl_rec.install_pc_id IS NULL) THEN
         x_status_code := 'REMOVAL_COMP';
 --QA collection ID
 ELSIF (p_disposition_rec.immediate_disposition_code NOT IN ('NA','NOT_RECEIVED','NOT_REMOVED')
         AND p_disposition_rec.instance_id IS NOT NULL
         AND p_disposition_rec.condition_id = fnd_profile.value('AHL_MTL_MAT_STATUS_MRB')
         AND p_disposition_rec.collection_id IS NULL)THEN
        x_status_code := 'PENDING_MRB';

  --Install required
  ELSIF  (--p_disposition_rec.instance_id IS NOT NULL and
          --For fixing bug 4085156, the above condition was removed by Jerry on 12/27/2004
          p_disposition_rec.path_position_id IS NOT NULL and
          l_pos_mand_flag = 'MANDATORY' AND
          l_disp_dtl_rec.install_pc_id IS NULL) THEN
          x_status_code := 'INSTALL_REQD';

  --Complete status
  ELSIF (p_disposition_rec.immediate_disposition_code IN ('NA','NOT_REMOVED') OR
         (l_disp_dtl_rec.trackable_flag ='Y'--tracked
         AND ( p_disposition_rec.path_position_id IS NOT NULL    --part change
           AND l_disp_dtl_rec.install_pc_id IS NOT NULL
           AND (l_disp_dtl_rec.mtl_txn_id IS NOT NULL
             OR p_disposition_rec.secondary_disposition_code = 'HOLD')
            OR (p_disposition_rec.path_position_id IS NULL          --no part change
             AND NVL(l_disp_dtl_rec.mtl_txn_qty, 0) >= p_disposition_rec.quantity)))
          OR (l_disp_dtl_rec.trackable_flag <>'Y' -- non-tracked
           AND NVL(l_disp_dtl_rec.mtl_txn_qty, 0) >= p_disposition_rec.quantity
		   AND get_issued_quantity(p_disposition_rec.disposition_id) >= p_disposition_rec.quantity   --add to fix bug 4077106
		)) THEN
         x_status_code := 'COMPLETE';

  ELSE
        x_status_code := null;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   L_DEBUG_KEY || '.end',
                   'At the end of the procedure, x_status_code = ' || x_status_code);
  END IF;

END Calculate_Status;


------------------------------------------------------------------
--  Function name    : Validate_Disposition_Types
--  Type        : Private
--  Function    : Validate the disposition type of the disposition record
--  Pre-reqs    :
--  Parameters  :
--
--  Validate_Disposition_Types parameters:
--       p_disp_rec    IN  the final disposition record
--  End of Comments.

PROCEDURE Validate_Disposition_Types (
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_disposition_rec     IN  AHL_PRD_DISPOSITION_PVT.disposition_rec_type)
IS
--
--
CURSOR check_immed_disp_types_csr (p_disp_code IN VARCHAR2)IS
SELECT 'X'
FROM fnd_lookups
WHERE  lookup_type = 'AHL_IMMED_DISP_TYPE'
AND lookup_code = p_disp_code
AND lookup_code <> 'NULL';
--
CURSOR check_second_disp_types_csr (p_disp_code IN VARCHAR2)IS
SELECT 'X'
FROM fnd_lookups
WHERE  lookup_type = 'AHL_SECND_DISP_TYPE'
AND lookup_code = p_disp_code
AND lookup_code <> 'NULL';
--
CURSOR check_condition_csr (p_condition_id IN NUMBER) IS
SELECT 'X'
FROM mtl_material_statuses
WHERE status_id = p_condition_id
AND enabled_flag = 1;
--
CURSOR get_disp_rec_csr (p_disp_id IN NUMBER) IS
/*
SELECT *
FROM AHL_PRD_DISPOSITIONS_V
WHERE DISPOSITION_ID = p_disp_id;
*/
--AnRaj: Changed query, Perf Bug#4908609,Issue#3
select  B.condition_id,
         COND.STATUS_CODE CONDITION_CODE,
         B.immediate_disposition_code,
         FND1.MEANING IMMEDIATE_TYPE,
         B.secondary_disposition_code,
         FND2.MEANING SECONDARY_TYPE,
         B.part_change_id,
         decode(B.instance_id, null, decode(B.path_position_id, null, 'N', 'Y'), 'Y') TRACKABLE_FLAG
from     AHL_PRD_DISPOSITIONS_B B,
         FND_LOOKUPS FND1,
         FND_LOOKUPS FND2,
         MTL_MATERIAL_STATUSES_VL COND
where    FND1.LOOKUP_TYPE (+) = 'AHL_IMMED_DISP_TYPE'
AND      B.immediate_disposition_code = FND1.LOOKUP_CODE (+)
AND      FND2.LOOKUP_TYPE (+) = 'AHL_SECND_DISP_TYPE'
AND      B.SECONDARY_DISPOSITION_CODE = FND2.LOOKUP_CODE (+)
AND      B.condition_id = COND.status_id (+)
AND      B.disposition_id = p_disp_id;

--
l_dummy VARCHAR2(1);
--l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Validate_Disp_Types';
l_imm_disp_type_tbl   AHL_PRD_DISP_UTIL_PVT.Disp_Type_Tbl_Type;
l_sec_disp_type_tbl   AHL_PRD_DISP_UTIL_PVT.Disp_Type_Tbl_Type;
l_disp_rec      Get_Disp_Rec_Csr%ROWTYPE;
l_match_flag boolean;
l_trackable_flag VARCHAR2(1);
--
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Validate_Disp_Types_Pvt;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Validate that the immediate disposition type is valid
  OPEN check_immed_disp_types_csr (p_disposition_rec.immediate_disposition_code);
  FETCH check_immed_disp_types_csr into l_dummy;
  IF (check_immed_disp_types_csr%NOTFOUND) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DISP_IMMED_TYPE_INV');
    FND_MSG_PUB.ADD;
  END IF;
  CLOSE check_immed_disp_types_csr;

  --Validate that the secondary disposition type is valid
  IF (p_disposition_rec.secondary_disposition_code IS NOT NULL) THEN
   OPEN check_second_disp_types_csr (p_disposition_rec.secondary_disposition_code);
   FETCH check_second_disp_types_csr into l_dummy;
   IF (check_second_disp_types_csr%NOTFOUND) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DISP_SECND_TYPE_INV');
    FND_MSG_PUB.ADD;
   END IF;
   CLOSE check_second_disp_types_csr;
  END IF;

  OPEN check_condition_csr (p_disposition_rec.condition_id);
  FETCH check_condition_csr into l_dummy;
  IF (check_condition_csr%NOTFOUND) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DISP_CONDITION_INV');
    FND_MSG_PUB.ADD;
  END IF;
  CLOSE check_condition_csr;



  --Check that secondary disposition is null for all immediate except BFS,
  -- NonConf dispositions
  IF (p_disposition_rec.immediate_disposition_code = 'BFS' OR
      p_disposition_rec.immediate_disposition_code ='NON_CONF') THEN

      --If RTV/RTC/HOLD/REWORK_RR, condition has to be unserviceable or MRB
      IF (p_disposition_rec.secondary_disposition_code <> 'REWORK_NR' AND
          p_disposition_rec.secondary_disposition_code <> 'SCRAP' AND
          p_disposition_rec.condition_id <> fnd_profile.value('AHL_MTL_MAT_STATUS_UNSERVICABLE') AND
          p_disposition_rec.condition_id <> fnd_profile.value('AHL_MTL_MAT_STATUS_MRB')) THEN
       FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DISP_TYPE_COND_INV');
       FND_MSG_PUB.ADD;
      --If SCRAP, condition has to be MRB
      ELSIF (p_disposition_rec.secondary_disposition_code = 'SCRAP' AND
             p_disposition_rec.condition_id <> fnd_profile.value('AHL_MTL_MAT_STATUS_MRB')) THEN
       FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DISP_TYPE_COND_INV');
       FND_MSG_PUB.ADD;
      END IF;

  ELSE
    --Use_as_is means condition must be serviceable
     IF (p_disposition_rec.immediate_disposition_code = 'USE_AS_IS' AND
         (p_disposition_rec.condition_id=fnd_profile.value('AHL_MTL_MAT_STATUS_UNSERVICABLE') OR
          p_disposition_rec.condition_id=fnd_profile.value('AHL_MTL_MAT_STATUS_MRB'))) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DISP_TYPE_COND_INV');
        FND_MSG_PUB.ADD;
     END IF;
     --SCRAP means condition is MRB
     IF (p_disposition_rec.immediate_disposition_code = 'SCRAP' AND
         p_disposition_rec.condition_id <> fnd_profile.value('AHL_MTL_MAT_STATUS_MRB')) THEN
       FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DISP_TYPE_COND_INV');
       FND_MSG_PUB.ADD;
      END IF;
      --not BFS or NON_CONF, secondary must be null
      IF(p_disposition_rec.secondary_disposition_code IS NOT NULL) THEN
       FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DISP_SECND_TYPE_INV');
       FND_MSG_PUB.ADD;
      END IF;
  END IF;

  --Jerry added the following validation on 02/17/2005 for fixing bug 4189553
  --To determine whether the disposition is for tracked item or non-tracked item
  IF p_disposition_rec.path_position_id IS NOT NULL THEN
    l_trackable_flag := 'Y';
  ELSIF p_disposition_rec.inventory_item_id IS NOT NULL THEN
    SELECT nvl(comms_nl_trackable_flag, 'N') INTO l_trackable_flag
      FROM mtl_system_items_kfv
     WHERE inventory_item_id = p_disposition_rec.inventory_item_id
       AND organization_id = p_disposition_rec.item_org_id;
  ELSIF p_disposition_rec.item_group_id IS NOT NULL THEN
    SELECT decode(type_code, 'TRACKED', 'Y', 'N') INTO l_trackable_flag
      FROM ahl_item_groups_b
     WHERE item_group_id = p_disposition_rec.item_group_id;
  ELSE
    l_trackable_flag := 'N';
  END IF;

  IF (p_disposition_rec.secondary_disposition_code IN ('REWORK_RR', 'REWORK_NR') AND
      l_trackable_flag = 'N') THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DISP_SECND_TYPE_INV');
    FND_MSG_PUB.ADD;
  END IF;

  --Validate against existing state in update case.
  IF (p_disposition_rec.operation_flag = G_OP_UPDATE AND
      p_disposition_rec.disposition_id IS NOT NULL) THEN

      --2a) Fetch the existing state.
      OPEN get_disp_rec_csr (p_disposition_rec.disposition_id);
      FETCH get_disp_rec_csr INTO l_disp_rec;
      IF (get_disp_rec_csr%NOTFOUND) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DISP_ID_INV');
        FND_MESSAGE.Set_Token('DISPOSITION_ID', p_disposition_rec.disposition_id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE get_disp_rec_csr;

      --Validate that condition id flows only 1 way.
      --'MRB' must stay as MRB
      IF (l_disp_rec.condition_id = fnd_profile.value('AHL_MTL_MAT_STATUS_MRB')
        AND p_disposition_rec.condition_id <> fnd_profile.value('AHL_MTL_MAT_STATUS_MRB')) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DISP_COND_CHANGE_INV');
           FND_MESSAGE.Set_Token('OLD_CONDITION', l_disp_rec.condition_code);
           FND_MESSAGE.Set_Token('NEW_CONDITION', p_disposition_rec.condition_meaning);
           FND_MSG_PUB.ADD;
      --Unserviceable cannot become serviceable
      ELSIF (l_disp_rec.condition_id = fnd_profile.value('AHL_MTL_MAT_STATUS_UNSERVICABLE') AND
             p_disposition_rec.condition_id<>fnd_profile.value('AHL_MTL_MAT_STATUS_UNSERVICABLE') AND
             p_disposition_rec.condition_id<>fnd_profile.value('AHL_MTL_MAT_STATUS_MRB')) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DISP_COND_CHANGE_INV');
           FND_MESSAGE.Set_Token('OLD_CONDITION', l_disp_rec.condition_code);
           FND_MESSAGE.Set_Token('NEW_CONDITION', p_disposition_rec.condition_meaning);
           FND_MSG_PUB.ADD;
      END IF;

     --Validate that Disposition Types are defined correctly
     --1) Check that Not Removed and NA are not mapped to Not Received
     IF (l_disp_rec.immediate_disposition_code IS NOT NULL) THEN
       IF ( l_disp_rec.immediate_disposition_code in ('NOT_REMOVED','NA')
         AND p_disposition_rec.immediate_disposition_code = 'NOT_RECEIVED') THEN
         FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DISP_IMMED_CHANGE_ILL');
          FND_MESSAGE.Set_Token('OLD_DISP_TYPE', l_disp_rec.immediate_type);
          FND_MESSAGE.Set_Token('NEW_DISP_TYPE', p_disposition_rec.immediate_disposition);
          FND_MSG_PUB.ADD;
       END IF;

       --2) Check that Not Received, BFS, Non_Conf, SCRAP are not changed
       --IF ( l_disp_rec.immediate_disposition_code in ('NOT_RECEIVED','BFS','NON_CONF','SCRAP')
       --Jerry removed 'NOT_RECEIVED' on 01/17/2005 for fixing bug 4094927
       IF ( l_disp_rec.immediate_disposition_code in ('BFS','NON_CONF','SCRAP')
        AND p_disposition_rec.immediate_disposition_code <> l_disp_rec.immediate_disposition_code) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DISP_IMMED_CHANGE_ILL');
          FND_MESSAGE.Set_Token('OLD_DISP_TYPE', l_disp_rec.immediate_type);
          FND_MESSAGE.Set_Token('NEW_DISP_TYPE', p_disposition_rec.immediate_disposition);
          FND_MSG_PUB.ADD;
       END IF;

     --3) Check that USE_AS_IS, RTV, RTC can not change to NOT_REMOVED,NA, NOT_RECEIVED
      IF ( l_disp_rec.immediate_disposition_code in ('USE_AS_IS','RTV','RTC')
         AND p_disposition_rec.immediate_disposition_code in ('NOT_REMOVED','NA','NOT_RECEIVED')) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DISP_IMMED_CHANGE_ILL');
          FND_MESSAGE.Set_Token('OLD_DISP_TYPE', l_disp_rec.immediate_type);
          FND_MESSAGE.Set_Token('NEW_DISP_TYPE', p_disposition_rec.immediate_disposition);
          FND_MSG_PUB.ADD;
       END IF;
     END IF;

     --Validate secondary dispositions
     --4) Check if secondary is SCRAP then must stay SCRAP
     IF ( l_disp_rec.secondary_disposition_code = 'SCRAP'
        AND p_disposition_rec.secondary_disposition_code <> 'SCRAP') THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DISP_SECND_CHANGE_ILL');
         FND_MESSAGE.Set_Token('OLD_DISP_TYPE', l_disp_rec.secondary_type);
         FND_MESSAGE.Set_Token('NEW_DISP_TYPE', p_disposition_rec.secondary_disposition);
        FND_MSG_PUB.ADD;
     END IF;


     --5) Check REWORK_NR means no part change has or is taking place.
     IF ( p_disposition_rec.secondary_disposition_code = 'REWORK_NR'
         and (l_disp_rec.part_change_id IS NOT NULL
             or p_disposition_rec.part_change_id IS NOT NULL)) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DISP_SECND_CHANGE_ILL');
         FND_MESSAGE.Set_Token('OLD_DISP_TYPE', l_disp_rec.secondary_type);
         FND_MESSAGE.Set_Token('NEW_DISP_TYPE', p_disposition_rec.secondary_disposition);
        FND_MSG_PUB.ADD;
     END IF;

     -- Jerry added the following validation on 02/17/2005 for fixing bug 4189553
     IF ( p_disposition_rec.secondary_disposition_code IN ('REWORK_NR','REWORK_RR')
         AND l_disp_rec.trackable_flag = 'N') THEN
         FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DISP_SECND_CHANGE_ILL');
         FND_MESSAGE.Set_Token('OLD_DISP_TYPE', l_disp_rec.secondary_type);
         FND_MESSAGE.Set_Token('NEW_DISP_TYPE', p_disposition_rec.secondary_disposition);
        FND_MSG_PUB.ADD;
     END IF;

  END IF; --G_UPDATE

  IF FND_MSG_PUB.count_msg > 0 THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to Validate_Disp_Types_Pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Validate_Disp_Types_Pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Validate_Disp_Types_Pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

END Validate_Disposition_Types;

-------------------------------------------------------------------------



FUNCTION workorder_Editable(p_workorder_id IN NUMBER) RETURN BOOLEAN
IS

  CURSOR workorder_status_csr(p_workorder_id IN NUMBER) IS
       SELECT status_code from ahl_workorders where workorder_id = p_workorder_id;

  l_status_code VARCHAR(30);
BEGIN
  OPEN workorder_status_csr(p_workorder_id);
  FETCH workorder_status_csr INTO l_status_code;
  CLOSE workorder_status_csr;
  -- Change made by jaramana on August 8, 2007 for bug 6326065 (FP of 6061600)
  -- Need to allow Disp Txn association for Complete workorders (code 4)
  -- update_disposition is called by AHL_PRD_DISP_MTL_TXN_PVT.Process_Disp_Mtl_Txn
  -- when the Transaction Qty is updated. So allow the Complete status as updateable.
  -- But note that from the Disposition UI, it will still not be possible to create or
  -- update the Disposition when the work order is in status Complete
  -- IF (l_status_code IN ('12', '4', '5', '7'))THEN --CLOSED, COMPLETE, COMPLETE NO CHARGE, CANCELLED
  IF (l_status_code IN ('12', '5', '7')) THEN --CLOSED, COMPLETE NO CHARGE, CANCELLED
     RETURN FALSE;
  END IF;

  RETURN TRUE;
END workorder_editable;

----------------function get_unit_instance_id-------------------------
-- retrieve the instance id of the unit for the job.
----------------------------------------------------------------------
FUNCTION get_unit_instance_id(p_workorder_id IN NUMBER) RETURN NUMBER
IS
  CURSOR task_instance_csr IS
    SELECT VTS.INSTANCE_ID, VTS.VISIT_ID
    FROM AHL_VISIT_TASKS_B VTS, AHL_WORKORDERS WO
    WHERE WO.VISIT_TASK_ID = VTS.VISIT_TASK_ID AND
    WO.WORKORDER_ID = p_workorder_id;

  CURSOR visit_instance_csr (c_visit_id IN NUMBER) IS
    SELECT VST.ITEM_INSTANCE_ID
    FROM AHL_VISITS_B VST
    WHERE VST.VISIT_ID = c_visit_id;

  CURSOR uc_header_instance_csr(p_uc_header_id IN NUMBER) IS
    SELECT csi_item_instance_id FROM ahl_unit_config_headers
    WHERE unit_config_header_id = p_uc_header_id;

  l_task_instance_id NUMBER;
  l_visit_id NUMBER;
  l_visit_instance_id NUMBER;
  l_wo_instance_id NUMBER;
  l_uc_header_id  NUMBER;
  l_unit_instance_id NUMBER;

  L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || 'get_unit_instance_id';


BEGIN
  OPEN task_instance_csr;
  FETCH task_instance_csr into l_task_instance_id, l_visit_id;
  CLOSE task_instance_csr;

  OPEN visit_instance_csr(l_visit_id);
  FETCH visit_instance_csr into l_visit_instance_id;
  CLOSE visit_instance_csr;

  IF l_task_instance_id IS NULL THEN
    l_wo_instance_id := l_visit_instance_id;
  ELSE
    l_wo_instance_id := l_task_instance_id;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'For work order id ' || p_workorder_id || ', wo_instance_id = ' || l_wo_instance_id);
  END IF;

  -- Get the top most unit containing the wo instance
  l_uc_header_id := AHL_UTIL_UC_PKG.get_uc_header_id(l_wo_instance_id);
  IF (l_uc_header_id IS NULL) THEN
    -- The task instance may have been removed from the Unit already.
    -- So, try to get the UC from the visit instance
    IF (l_task_instance_id IS NOT NULL AND l_visit_instance_id IS NOT NULL) THEN
      -- WO instance is the task instance. So try with the visit instance
      l_uc_header_id := AHL_UTIL_UC_PKG.get_uc_header_id(l_visit_instance_id);
    ELSE
      -- WO instance is already the visit instance
      NULL;
    END IF;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'For work order id ' || p_workorder_id || ', uc_header_id = ' || l_uc_header_id);
  END IF;

  IF (l_uc_header_id IS NOT NULL) THEN
    OPEN uc_header_instance_csr(l_uc_header_id);
    FETCH uc_header_instance_csr INTO l_unit_instance_id;
    CLOSE uc_header_instance_csr;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'For work order id ' || p_workorder_id || ', unit_instance_id = ' || l_unit_instance_id);
    END IF;
    RETURN l_unit_instance_id;
  ELSE
    -- IB Tree
    RETURN NULL;
  END IF;

END get_unit_instance_id;

--------------------------------------------------------------------

--Retrieve root instance Id of an instance
FUNCTION get_root_instance_id(p_instance_id IN NUMBER) RETURN NUMBER
IS

 CURSOR get_root_instance_csr(p_instance_id IN NUMBER) IS
     SELECT object_id
      FROM csi_ii_relationships
       START WITH subject_id = p_instance_id
         AND relationship_type_code = 'COMPONENT-OF'
         AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
         AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
       CONNECT BY subject_id = PRIOR object_id
         AND relationship_type_code = 'COMPONENT-OF'
         AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
         AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR is_non_root_csr(p_instance_id NUMBER) IS
  SELECT 'x' FROM csi_ii_relationships
         WHERE subject_id = p_instance_id
         AND relationship_type_code = 'COMPONENT-OF'
         AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
         AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  l_exist VARCHAR2(1);
  l_root_instance_id  NUMBER;
BEGIN
  OPEN is_non_root_csr(p_instance_id);
  FETCH is_non_root_csr INTO l_exist;
  IF is_non_root_csr%NOTFOUND THEN   -- then it is a root instance
    l_root_instance_id := p_instance_id;
  ELSE
    OPEN get_root_instance_csr(p_instance_id);
    LOOP
      FETCH get_root_instance_csr INTO l_root_instance_id;
      EXIT when get_root_instance_csr%NOTFOUND;
    END LOOP;
    CLOSE get_root_instance_csr;
  END IF;
  CLOSE is_non_root_csr;

  RETURN l_root_instance_id;

END get_root_instance_id;
--------------------------------------------------------------------

FUNCTION get_issued_quantity(p_disposition_id IN NUMBER) RETURN NUMBER
IS
Cursor get_issued_quantity_csr(p_disp_id IN NUMBER) IS
SELECT sum (assoc.quantity)
  FROM  AHL_PRD_DISP_MTL_TXNS assoc,
  AHL_WORKORDER_MTL_TXNS mtxn
  WHERE assoc.disposition_id = p_disp_id
  AND assoc.workorder_mtl_txn_id = mtxn.workorder_mtl_txn_id
  AND mtxn.transaction_type_id = WIP_CONSTANTS.ISSCOMP_TYPE
  GROUP BY assoc.disposition_id;

l_quantity NUMBER;
BEGIN
OPEN get_issued_quantity_csr(p_disposition_id);
FETCH get_issued_quantity_csr INTO l_quantity;
IF(get_issued_quantity_csr%NOTFOUND) THEN
  l_quantity := 0;
END IF;
CLOSE get_issued_quantity_csr;

RETURN l_quantity;

END get_issued_quantity;

------------------------------------------------------------------------
-- Added function by rbhavsar on 09/27/2007 for Bug 6411059
FUNCTION root_node_in_uc_headers(p_instance_id IN NUMBER) RETURN BOOLEAN
IS
  CURSOR get_root_node(c_instance_id NUMBER) IS
    SELECT object_id
       FROM csi_ii_relationships
       START WITH subject_id = c_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)

       CONNECT BY subject_id = prior object_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

   CURSOR check_in_headers(c_instance_id NUMBER) IS
   SELECT csi_item_instance_id
     FROM ahl_unit_config_headers
     WHERE csi_item_instance_id = c_instance_id
     AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

 TYPE objectid_tbl IS TABLE OF csi_ii_relationships.object_id%TYPE;
 l_object_id_tbl    objectid_tbl;
 l_instance_id      NUMBER;
 l_unit_instance_id NUMBER;
 l_api_name         CONSTANT VARCHAR2(30) := 'root_node_in_uc_headers';

BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   G_LOG_PREFIX||l_api_name||'.begin',
                   'At the start of the function:  instance_id ='||p_instance_id);
    END IF;

    -- Get the root node instance for the given instance id
    OPEN get_root_node(p_instance_id);
    FETCH get_root_node BULK COLLECT INTO l_object_id_tbl;
    CLOSE get_root_node;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     G_LOG_PREFIX||l_api_name,
                     'Parent hierachy count ' || l_object_id_tbl.count);
    END IF;

    IF (l_object_id_tbl.count > 0) then
        l_instance_id := l_object_id_tbl(l_object_id_tbl.count);
    ELSE
        l_instance_id := p_instance_id;
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     G_LOG_PREFIX||l_api_name,
                     'Root Instance is ' || l_instance_id);
    END IF;

    -- Check if the Root instance is in unit config headers
    OPEN check_in_headers(l_instance_id);
    FETCH check_in_headers INTO l_unit_instance_id;
    IF check_in_headers%NOTFOUND THEN
       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                        G_LOG_PREFIX||l_api_name,
                       'Root Instance  ' || l_instance_id || ' is not in unit config headers ');
       END IF;
       CLOSE check_in_headers;
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                            G_LOG_PREFIX||l_api_name||'.end',
                            'At the end of the procedure returning FALSE');
       END IF;
       RETURN FALSE;
    ELSE
       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                        G_LOG_PREFIX||l_api_name,
                       'Root Instance  ' || l_instance_id || ' is in unit config headers ');
       END IF;
       CLOSE check_in_headers;
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                            G_LOG_PREFIX||l_api_name||'.end',
                            'At the end of the procedure returning TRUE');
       END IF;
       RETURN TRUE;
    END IF;

END root_node_in_uc_headers;

--------------------------------------------------------------

-- Procedure added by jaramana on October 8, 2007 for ER 5854667
-- This procedure gets the WIP Entity Id of the Non-Master Work that is a child of the passed
-- in Work order (Summary WO of the Non Routine)

FUNCTION Get_NonMWO_WIP_Entity_Id(p_workorder_id IN NUMBER) RETURN NUMBER
IS
Cursor get_child_entities IS
SELECT CHILD_OBJECT_ID
  FROM EAM_WO_RELATIONSHIPS
 WHERE PARENT_OBJECT_ID = (SELECT wip_entity_id FROM ahl_workorders WHERE workorder_id = p_workorder_id)
AND PARENT_RELATIONSHIP_TYPE = 1
ORDER BY CHILD_OBJECT_ID;

Cursor get_matching_wo_dtls(c_wip_entity_id IN NUMBER) IS
SELECT WO.WORKORDER_ID, WO.WIP_ENTITY_ID, WO.VISIT_TASK_ID
  FROM AHL_WORKORDERS WO, AHL_VISIT_TASKS_B TSK
 WHERE WIP_ENTITY_ID = c_wip_entity_id AND
       WO.VISIT_TASK_ID = TSK.VISIT_TASK_ID AND
       TSK.TASK_TYPE_CODE <> 'SUMMARY';

Cursor get_non_summary_entity(c_wip_entity_id IN NUMBER) IS
SELECT EAM.CHILD_OBJECT_ID
  FROM EAM_WO_RELATIONSHIPS EAM, AHL_WORKORDERS WO, AHL_VISIT_TASKS_B TSK
 WHERE EAM.CHILD_OBJECT_ID = WO.WIP_ENTITY_ID AND
       TSK.VISIT_TASK_ID = WO.VISIT_TASK_ID AND
       TSK.TASK_TYPE_CODE <> 'SUMMARY'
 START WITH EAM.CHILD_OBJECT_ID = c_wip_entity_id
 CONNECT BY PRIOR CHILD_OBJECT_ID = PARENT_OBJECT_ID AND
            PARENT_RELATIONSHIP_TYPE = 1
 ORDER BY LEVEL, EAM.CHILD_OBJECT_ID;

 l_child_entity_id NUMBER;
 l_first_child_id NUMBER := null;
 l_wo_dtls_rec get_matching_wo_dtls%ROWTYPE;
 l_full_name  CONSTANT VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.'||'Get_NonMWO_WIP_Entity_Id';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_full_name, 'Entering Procedure. p_workorder_id = ' || p_workorder_id);
  END IF;
  OPEN get_child_entities;
  LOOP
    FETCH get_child_entities INTO l_child_entity_id;
    EXIT when get_child_entities%NOTFOUND;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_full_name, 'l_child_entity_id = ' || l_child_entity_id);
    END IF;
    OPEN get_matching_wo_dtls(l_child_entity_id);
    FETCH get_matching_wo_dtls INTO l_wo_dtls_rec;
    CLOSE get_matching_wo_dtls;
    IF (l_wo_dtls_rec.WIP_ENTITY_ID IS NOT NULL) THEN
      CLOSE get_child_entities;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_full_name, 'About to return ' || l_wo_dtls_rec.WIP_ENTITY_ID);
      END IF;
      RETURN l_wo_dtls_rec.WIP_ENTITY_ID;
    END IF;
    IF (l_first_child_id IS NULL) THEN
      l_first_child_id := l_child_entity_id;
    END IF;
  END LOOP;
  CLOSE get_child_entities;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_full_name, 'l_first_child_id = ' || l_first_child_id);
  END IF;
  IF (l_first_child_id IS NOT NULL) THEN
    OPEN get_non_summary_entity(l_first_child_id);
    FETCH get_non_summary_entity INTO l_child_entity_id;
    CLOSE get_non_summary_entity;
  END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_full_name, 'Exiting Procedure. About to return ' || l_child_entity_id);
  END IF;
  RETURN l_child_entity_id;

END Get_NonMWO_WIP_Entity_Id;

--------------------------------------------------------------

-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 12-Dec-2007
-- The API update_item_location and its use has been commented out. Its functionality will
-- now be handled in the API AHL_PRD_NONROUTINE_PVT.process_nonroutine_job.
/*
-- Procedure added by jaramana on February 14, 2007 for ER 5854667
-- This procedure sets the instannce's location as the WIP Job passed in as parameter.
PROCEDURE update_item_location(p_workorder_id  IN         NUMBER,
                               p_instance_id   IN         NUMBER,
                               x_return_status OUT NOCOPY Varchar2)
IS

  l_wip_entity_id            NUMBER;
  l_instance_rec             csi_datastructures_pub.instance_rec;
  l_csi_transaction_rec      CSI_DATASTRUCTURES_PUB.transaction_rec;
  l_extend_attrib_values_tbl csi_datastructures_pub.extend_attrib_values_tbl;
  l_party_tbl                csi_datastructures_pub.party_tbl;
  l_account_tbl              csi_datastructures_pub.party_account_tbl;
  l_pricing_attrib_tbl       csi_datastructures_pub.pricing_attribs_tbl;
  l_org_assignments_tbl      csi_datastructures_pub.organization_units_tbl;
  l_asset_assignment_tbl     csi_datastructures_pub.instance_asset_tbl;
  l_instance_id_lst          csi_datastructures_pub.id_tbl;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);

  l_full_name  CONSTANT VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.'||'Update_item_location';
  l_transaction_type_id NUMBER;
  l_return_val          BOOLEAN;
  l_wo_status_code      AHL_WORKORDERS.STATUS_CODE%TYPE;
  l_temp_wo_id          NUMBER;

  -- For getting the status of the workorder from the wip_entity_id
  CURSOR ahl_wo_status_csr(c_wip_entity_id IN NUMBER) IS
    select workorder_id, status_code
    FROM ahl_workorders
    WHERE wip_entity_id = c_wip_entity_id;

  -- For getting the the updated object_version number from csi_item_isntances
  CURSOR ahl_obj_ver_csr IS
     select object_version_number
     from csi_item_instances
     where instance_id = p_instance_id;

  -- For getting the wip_location_id to populate csi_transaction record
  CURSOR ahl_wip_location_csr IS
     select wip_location_id
     from csi_install_parameters ;

BEGIN

  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_full_name, 'Entering Procedure. p_workorder_id = ' || p_workorder_id || ', p_instance_id = ' || p_instance_id);
  END IF;

  -- Get the Non-Master Workorder's wip_entity_id
  l_wip_entity_id := Get_NonMWO_WIP_Entity_Id(p_workorder_id);
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_full_name, 'Get_NonMWO_WIP_Entity_Id Returned ' || l_wip_entity_id);
  END IF;
  IF (l_wip_entity_id IS NULL) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_full_name, 'Throwing Unexpected Error since Get_NonMWO_WIP_Entity_Id returned null');
    END IF;
    FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_WIP_ENTITY_MISSING');
    FND_MESSAGE.Set_Token('WOID', p_workorder_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    -- Additional check added by jaramana on February 23, 2007 for ER 5854667
    -- Update the instance location only if the work order is in released status
    OPEN ahl_wo_status_csr(l_wip_entity_id);
    FETCH ahl_wo_status_csr INTO l_temp_wo_id, l_wo_status_code;
    CLOSE ahl_wo_status_csr;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_full_name, 'Status of Work order with id ' || l_temp_wo_id || ' is ' || l_wo_status_code);
    END IF;
    IF (l_wo_status_code <> G_WO_RELEASED_STATUS) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_full_name, 'Not changing the location of the instance to the NR WO because the work order is not released.');
      END IF;
    ELSE
      -- Get the object_version number from csi_item_instances
      OPEN ahl_obj_ver_csr;
      FETCH ahl_obj_ver_csr INTO l_instance_rec.object_version_number;
      IF (ahl_obj_ver_csr%NOTFOUND) THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_REMOVED_INSTANCE_INVALID');
        FND_MESSAGE.Set_Token('INST', p_instance_id);
        FND_MSG_PUB.ADD;
        CLOSE ahl_obj_ver_csr;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
        CLOSE ahl_obj_ver_csr;
      END IF;
      -- Populate l_instance_rec
      l_instance_rec.INSTANCE_ID        := p_instance_id;
      l_instance_rec.LOCATION_TYPE_CODE := 'WIP';
      l_instance_rec.WIP_JOB_ID         := l_wip_entity_id;
      l_instance_rec.instance_usage_code := 'IN_WIP';

      -- Get location id
      OPEN ahl_wip_location_csr;
      FETCH ahl_wip_location_csr INTO l_instance_rec.LOCATION_ID ;
      CLOSE ahl_wip_location_csr;

      -- get transaction_type_id .
      AHL_Util_UC_Pkg.GetCSI_Transaction_ID('UC_UPDATE', l_transaction_type_id, l_return_val);
      IF NOT(l_return_val) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      l_csi_transaction_rec.transaction_type_id     := l_transaction_type_id;
      l_csi_transaction_rec.source_transaction_date := sysdate;

      -- Call the CSI API to actually do the update
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_full_name, 'About to call CSI_ITEM_INSTANCE_PUB.UPDATE_ITEM_INSTANCE');
      END IF;

      CSI_ITEM_INSTANCE_PUB.UPDATE_ITEM_INSTANCE(p_api_version           => 1.0
                                                ,p_commit                => fnd_api.g_false
                                                ,p_init_msg_list         => fnd_api.g_false
                                                ,p_validation_level      => fnd_api.g_valid_level_full
                                                ,p_instance_rec          => l_instance_rec
                                                ,p_ext_attrib_values_tbl => l_extend_attrib_values_tbl
                                                ,p_party_tbl             => l_party_tbl
                                                ,p_account_tbl           => l_account_tbl
                                                ,p_pricing_attrib_tbl    => l_pricing_attrib_tbl
                                                ,p_org_assignments_tbl   => l_org_assignments_tbl
                                                ,p_asset_assignment_tbl  => l_asset_assignment_tbl
                                                ,p_txn_rec               => l_csi_transaction_rec
                                                ,x_instance_id_lst       => l_instance_id_lst
                                                ,x_return_status         => x_return_status
                                                ,x_msg_count             => l_msg_count
                                                ,x_msg_data              => l_msg_data);

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_full_name, 'Returned from CSI_ITEM_INSTANCE_PUB.UPDATE_ITEM_INSTANCE. x_return_status = ' || x_return_status);
      END IF;
    END IF;  -- Status is Released or not
  END IF;  -- WIP Entity Id is null or not

  -- Updated by jaramana on October 15, 2007 since the CSI API seems to nullify return params
  IF (x_return_status IS NULL AND NVL(l_msg_count, 0) = 0) THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_full_name, 'Exiting Procedure. x_return_status = ' || x_return_status);
  END IF;

END update_item_location;
*/

END AHL_PRD_DISPOSITION_PVT;

/
