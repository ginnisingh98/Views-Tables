--------------------------------------------------------
--  DDL for Package Body AHL_WIP_JOB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_WIP_JOB_PVT" AS
/* $Header: AHLVWIPB.pls 120.1.12000000.2 2007/08/09 10:42:13 adivenka ship $ */

-- Define Global Type --
  TYPE num_array_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

-- Define Global Variable --
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'AHL_WIP_JOB_PVT';
  G_DEBUG VARCHAR2(1) := NVL(AHL_DEBUG_PUB.is_log_enabled,'N');

-- Define Global Cursors --
  CURSOR job_header_exists(c_group_id NUMBER, c_parent_header_id NUMBER) IS
    SELECT 'X'
    FROM wip_job_schedule_interface
    WHERE group_id = c_group_id
    AND header_id = c_parent_header_id;

  CURSOR get_interface_ids(c_group_id NUMBER, c_header_id NUMBER) IS
    SELECT interface_id
    FROM wip_job_dtls_interface
    WHERE group_id = c_group_id
    AND parent_header_id = c_header_id
    AND interface_id IS NOT NULL;

  CURSOR get_error_msg(c_interface_id NUMBER) IS
    SELECT error
    FROM wip_interface_errors
    WHERE error_type = 1
    AND interface_id = c_interface_id;

  CURSOR get_wip_entity(c_wip_entity_name VARCHAR2, c_organization_id NUMBER) IS
    SELECT wip_entity_id
    FROM wip_entities
    WHERE wip_entity_name = c_wip_entity_name
    AND organization_id = c_organization_id;

-- Declare and define local procedure insert_job_header --
PROCEDURE insert_job_header(
  p_ahl_wo_rec	    IN  AHL_WO_REC_TYPE,
  p_group_id 	    IN  NUMBER,
  p_header_id 	    IN  NUMBER,
  x_group_id 	    OUT	NOCOPY NUMBER,
  x_header_id 	    OUT	NOCOPY NUMBER,
  x_return_status   OUT NOCOPY VARCHAR2
) IS
  l_wip_job_rec     wip_job_schedule_interface%ROWTYPE;
  l_group_id        NUMBER;
  l_header_id       NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Ensure the DML operation for the Job header is only Insert or Update
  IF (p_ahl_wo_rec.dml_type <> 'I' AND p_ahl_wo_rec.dml_type <> 'U') THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_INVALID_JOB_DML_TYPE');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN;
  END IF;

  IF (p_group_id IS NULL AND p_header_id IS NOT NULL) OR
     (p_group_id IS NOT NULL AND p_header_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_GROUP_HEADER_MISMATCH');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN;
  END IF;

  IF p_group_id IS NULL THEN
    SELECT wip_job_schedule_interface_s.NEXTVAL INTO l_group_id FROM dual;
    l_header_id := l_group_id;
  ELSE
    l_group_id := p_group_id;
    l_header_id := p_header_id + 1;
  END IF;

  l_wip_job_rec.process_phase := 2; --validation
  l_wip_job_rec.process_status := 1; --pending
  l_wip_job_rec.group_id := l_group_id;
  l_wip_job_rec.header_id := l_header_id;
  l_wip_job_rec.source_code := 'Service';
  l_wip_job_rec.maintenance_object_source := 2; -- for 'AHL'
  l_wip_job_rec.maintenance_object_type := 3; -- for 'CII'
  l_wip_job_rec.creation_date := SYSDATE;
  l_wip_job_rec.last_update_date := SYSDATE;
  l_wip_job_rec.created_by := fnd_global.user_id;
  l_wip_job_rec.last_updated_by := fnd_global.user_id;
  l_wip_job_rec.last_update_login := fnd_global.login_id;
  --l_wip_job_rec.last_updated_login := fnd_global.conc_login_id;
  l_wip_job_rec.request_id := fnd_global.conc_request_id;
  l_wip_job_rec.program_id := fnd_global.conc_program_id;
  l_wip_job_rec.program_application_id := fnd_global.prog_appl_id;

  IF p_ahl_wo_rec.dml_type = 'I' THEN
    l_wip_job_rec.load_type := 7; --create job
  ELSIF p_ahl_wo_rec.dml_type = 'U' THEN
    l_wip_job_rec.load_type := 8; --update job
  END IF;

  l_wip_job_rec.job_name := p_ahl_wo_rec.wo_name;
  l_wip_job_rec.organization_id := p_ahl_wo_rec.organization_id;
  l_wip_job_rec.status_type := p_ahl_wo_rec.status;
  l_wip_job_rec.first_unit_start_date := p_ahl_wo_rec.scheduled_start;
  l_wip_job_rec.last_unit_start_date := p_ahl_wo_rec.scheduled_start;
  l_wip_job_rec.first_unit_completion_date := p_ahl_wo_rec.scheduled_end;
  l_wip_job_rec.last_unit_completion_date := p_ahl_wo_rec.scheduled_end;
  l_wip_job_rec.completion_subinventory := p_ahl_wo_rec.completion_subinventory;
  l_wip_job_rec.completion_locator_id := p_ahl_wo_rec.completion_locator_id;
  l_wip_job_rec.wip_supply_type := p_ahl_wo_rec.wip_supply_type;
  l_wip_job_rec.firm_planned_flag := p_ahl_wo_rec.firm_planned_flag;
  l_wip_job_rec.project_id := p_ahl_wo_rec.project_id;
  l_wip_job_rec.task_id := p_ahl_wo_rec.prj_task_id;

  IF p_ahl_wo_rec.dml_type = 'I' THEN
    l_wip_job_rec.start_quantity := 1;
  ELSIF p_ahl_wo_rec.dml_type = 'U' THEN
    l_wip_job_rec.start_quantity := NULL;
  END IF;

  IF p_ahl_wo_rec.dml_type = 'I' THEN
    l_wip_job_rec.net_quantity := 1;
  ELSIF p_ahl_wo_rec.dml_type = 'U' THEN
    l_wip_job_rec.net_quantity := 0;
  END IF;

  IF ( p_ahl_wo_rec.dml_type = 'U' AND
       ( p_ahl_wo_rec.inventory_item_id IS NULL OR
         p_ahl_wo_rec.item_instance_id IS NULL OR
         p_ahl_wo_rec.class_code IS NULL )
     ) THEN

    SELECT rebuild_item_id,
           maintenance_object_id,
           class_code
    INTO   l_wip_job_rec.rebuild_item_id,
           l_wip_job_rec.maintenance_object_id,
           l_wip_job_rec.class_code
    FROM   wip_discrete_jobs
    WHERE  wip_entity_id =
           (  SELECT wip_entity_id
              FROM wip_entities
              WHERE wip_entity_name = p_ahl_wo_rec.wo_name );

  ELSE
    l_wip_job_rec.rebuild_item_id := p_ahl_wo_rec.inventory_item_id;
    l_wip_job_rec.maintenance_object_id := p_ahl_wo_rec.item_instance_id;
    l_wip_job_rec.class_code := p_ahl_wo_rec.class_code;
  END IF;

  l_wip_job_rec.priority := p_ahl_wo_rec.priority;
  l_wip_job_rec.owning_department := p_ahl_wo_rec.department_id;
  l_wip_job_rec.manual_rebuild_flag := p_ahl_wo_rec.manual_rebuild_flag;
  l_wip_job_rec.rebuild_serial_number := p_ahl_wo_rec.rebuild_serial_number;
  l_wip_job_rec.description:= p_ahl_wo_rec.description;
  l_wip_job_rec.allow_explosion := 'N';
  l_wip_job_rec.scheduling_method := 3; --default to 'Manual'

  --insert into table WJSI
  BEGIN
    INSERT INTO wip_job_schedule_interface
    ( last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      load_type,
      process_phase,
      process_status,
      group_id,
      header_id,
      source_code,
      allow_explosion,
      maintenance_object_source,
      maintenance_object_type,
      job_name,
      organization_id,
      status_type,
      first_unit_start_date,
      last_unit_completion_date,
      rebuild_item_id,
      maintenance_object_id,
      rebuild_serial_number,
      manual_rebuild_flag,
      completion_subinventory,
      completion_locator_id,
      start_quantity,
      net_quantity,
      wip_supply_type,
      firm_planned_flag,
      project_id,
      task_id,
      class_code,
      priority,
      owning_department,
      scheduling_method,
      description)
    VALUES
    ( l_wip_job_rec.last_update_date,
      l_wip_job_rec.last_updated_by,
      l_wip_job_rec.creation_date,
      l_wip_job_rec.created_by,
      l_wip_job_rec.last_update_login,
      l_wip_job_rec.request_id,
      l_wip_job_rec.program_id,
      l_wip_job_rec.program_application_id,
      l_wip_job_rec.program_update_date,
      l_wip_job_rec.load_type,
      l_wip_job_rec.process_phase,
      l_wip_job_rec.process_status,
      l_wip_job_rec.group_id,
      l_wip_job_rec.header_id,
      l_wip_job_rec.source_code,
      l_wip_job_rec.allow_explosion,
      l_wip_job_rec.maintenance_object_source,
      l_wip_job_rec.maintenance_object_type,
      l_wip_job_rec.job_name,
      l_wip_job_rec.organization_id,
      l_wip_job_rec.status_type,
      l_wip_job_rec.first_unit_start_date,
      l_wip_job_rec.last_unit_completion_date,
      l_wip_job_rec.rebuild_item_id,
      l_wip_job_rec.maintenance_object_id,
      l_wip_job_rec.rebuild_serial_number,
      l_wip_job_rec.manual_rebuild_flag,
      l_wip_job_rec.completion_subinventory,
      l_wip_job_rec.completion_locator_id,
      l_wip_job_rec.start_quantity,
      l_wip_job_rec.net_quantity,
      l_wip_job_rec.wip_supply_type,
      l_wip_job_rec.firm_planned_flag,
      l_wip_job_rec.project_id,
      l_wip_job_rec.task_id,
      l_wip_job_rec.class_code,
      l_wip_job_rec.priority,
      l_wip_job_rec.owning_department,
      l_wip_job_rec.scheduling_method,
      l_wip_job_rec.description);
  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_JOB_HEADER_INSERT_ERR');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE; -- Reraise the exception and its calling procedure's exception handler
             -- will handle it in its OTHERS exception part
  END;
  x_group_id := l_wip_job_rec.group_id;
  x_header_id := l_wip_job_rec.header_id;
  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('Finish: insert_job_header, x_return_status='||x_return_status);
  --dbms_output.put_line('Finish: insert_job_header, x_return_status='||x_return_status);
  END IF;
END insert_job_header;

-- Declare and define local procedure insert_job_operation --
PROCEDURE insert_job_operation(
  p_ahl_wo_op_rec    IN	AHL_WO_OP_REC_TYPE,
  p_group_id 	     IN	NUMBER,
  p_parent_header_id IN	NUMBER,
  x_return_status    OUT NOCOPY VARCHAR2
) IS
  l_wip_job_op_rec  wip_job_dtls_interface%ROWTYPE;
  l_dummy           VARCHAR2(1);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Ensure the DML operation for the Job operation is only Insert or Update
  IF (p_ahl_wo_op_rec.dml_type <> 'I' AND p_ahl_wo_op_rec.dml_type <> 'U') THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_INVALID_OPER_DML_TYPE');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN;
  END IF;

  -- Validate p_group_id and p_parent_header_id
  OPEN job_header_exists(p_group_id, p_parent_header_id);
  FETCH job_header_exists INTO l_dummy;
  IF job_header_exists%NOTFOUND THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_INVALID_JOB_HEADER');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    CLOSE job_header_exists;
    RETURN;
  ELSE
    CLOSE job_header_exists;
  END IF;

  -- Validate p_ahl_wo_op_rec.operation_seq_num, because operation_seq_num is
  -- a NOT NULL column in table wip_job_dtls_interface
  IF p_ahl_wo_op_rec.operation_seq_num IS NULL THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_OPERATION_SEQ_NULL');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN;
  END IF;

  l_wip_job_op_rec.load_type := 3; --loading operation
  l_wip_job_op_rec.process_phase := 2;
  l_wip_job_op_rec.process_status := 1;
  l_wip_job_op_rec.group_id := p_group_id;
  l_wip_job_op_rec.parent_header_id := p_parent_header_id;
  l_wip_job_op_rec.creation_date := SYSDATE;
  l_wip_job_op_rec.last_update_date := SYSDATE;
  l_wip_job_op_rec.created_by := fnd_global.user_id;
  l_wip_job_op_rec.last_updated_by := fnd_global.user_id;
  l_wip_job_op_rec.last_update_login := fnd_global.login_id;
  --l_wip_job_op_rec.last_updated_login := fnd_global.conc_login_id;
  l_wip_job_op_rec.request_id := fnd_global.conc_request_id;
  l_wip_job_op_rec.program_id := fnd_global.conc_program_id;
  l_wip_job_op_rec.program_application_id := fnd_global.prog_appl_id;

  IF p_ahl_wo_op_rec.dml_type = 'I' THEN
    l_wip_job_op_rec.substitution_type := 2; --add operation
  ELSIF p_ahl_wo_op_rec.dml_type = 'U' THEN
    l_wip_job_op_rec.substitution_type := 3; --update operation
  END IF;
  l_wip_job_op_rec.organization_id := p_ahl_wo_op_rec.organization_id;
  l_wip_job_op_rec.operation_seq_num := p_ahl_wo_op_rec.operation_seq_num;
  l_wip_job_op_rec.department_id := p_ahl_wo_op_rec.department_id;
  l_wip_job_op_rec.first_unit_start_date := p_ahl_wo_op_rec.scheduled_start;
  l_wip_job_op_rec.first_unit_completion_date := p_ahl_wo_op_rec.scheduled_end;
  l_wip_job_op_rec.last_unit_start_date := p_ahl_wo_op_rec.scheduled_start;
  l_wip_job_op_rec.last_unit_completion_date := p_ahl_wo_op_rec.scheduled_end;
  --l_wip_job_op_rec.standard_operation_id := l_ahl_wo_op_rec.standard_operation_id;
  l_wip_job_op_rec.description := p_ahl_wo_op_rec.description;
  IF (p_ahl_wo_op_rec.dml_type = 'I' AND p_ahl_wo_op_rec.minimum_transfer_quantity IS NULL) THEN
    l_wip_job_op_rec.minimum_transfer_quantity := 1; --default to 1 during creation
  ELSE
    l_wip_job_op_rec.minimum_transfer_quantity := p_ahl_wo_op_rec. minimum_transfer_quantity;
  END IF;
  IF (p_ahl_wo_op_rec.dml_type = 'I' AND p_ahl_wo_op_rec.count_point_type IS NULL) THEN
    l_wip_job_op_rec.count_point_type := 2; --default to 2 'No -- Autocharge' during creation
  ELSE
    l_wip_job_op_rec.count_point_type := p_ahl_wo_op_rec.count_point_type;
  END IF;
  IF (p_ahl_wo_op_rec.dml_type = 'I' AND p_ahl_wo_op_rec.backflush_flag IS NULL) THEN
    l_wip_job_op_rec.backflush_flag := 2; --default to 2 'No' during creation
  ELSE
    l_wip_job_op_rec.backflush_flag := p_ahl_wo_op_rec.backflush_flag;
  END IF;
  --Insert into table WJDI
  BEGIN
    INSERT INTO wip_job_dtls_interface
    ( last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      load_type,
      process_phase,
      process_status,
      group_id,
      parent_header_id,
      substitution_type,
      organization_id,
      operation_seq_num,
      department_id,
      description,
      minimum_transfer_quantity,
      count_point_type,
      first_unit_start_date,
      first_unit_completion_date,
      last_unit_start_date,
      last_unit_completion_date,
      backflush_flag)
    VALUES
    ( l_wip_job_op_rec.last_update_date,
      l_wip_job_op_rec.last_updated_by,
      l_wip_job_op_rec.creation_date,
      l_wip_job_op_rec.created_by,
      l_wip_job_op_rec.last_update_login,
      l_wip_job_op_rec.request_id,
      l_wip_job_op_rec.program_id,
      l_wip_job_op_rec.program_application_id,
      l_wip_job_op_rec.program_update_date,
      l_wip_job_op_rec.load_type,
      l_wip_job_op_rec.process_phase,
      l_wip_job_op_rec.process_status,
      l_wip_job_op_rec.group_id,
      l_wip_job_op_rec.parent_header_id,
      l_wip_job_op_rec.substitution_type,
      l_wip_job_op_rec.organization_id,
      l_wip_job_op_rec.operation_seq_num,
      l_wip_job_op_rec.department_id,
      l_wip_job_op_rec.description,
      l_wip_job_op_rec.minimum_transfer_quantity,
      l_wip_job_op_rec.count_point_type,
      l_wip_job_op_rec.first_unit_start_date,
      l_wip_job_op_rec.first_unit_completion_date,
      l_wip_job_op_rec.last_unit_start_date,
      l_wip_job_op_rec.last_unit_completion_date,
      l_wip_job_op_rec.backflush_flag);
  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_JOB_OPER_INSERT_ERR');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE;
  END;
  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('Finish: insert_job_operation, x_return_status='||x_return_status);
  --dbms_output.put_line('Finish: insert_job_operation, x_return_status='||x_return_status);
  END IF;
END insert_job_operation;

-- Declare and define local procedure insert_job_resource --
PROCEDURE insert_job_resource(
  p_ahl_wo_res_rec   IN	AHL_WO_RES_REC_TYPE,
  p_group_id 	     IN	NUMBER,
  p_parent_header_id IN	NUMBER,
  x_return_status    OUT NOCOPY VARCHAR2
) IS
  l_wip_job_res_rec  wip_job_dtls_interface%ROWTYPE;
  l_dummy            VARCHAR2(1);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Ensure the DML operation for the Job resource is Insert, Update or Delete
  IF (p_ahl_wo_res_rec.dml_type <> 'I' AND p_ahl_wo_res_rec.dml_type <> 'U'
      AND p_ahl_wo_res_rec.dml_type <> 'D') THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_INVALID_RES_DML_TYPE');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN;
  END IF;

  -- validate p_group_id and p_parent_header_id
  OPEN job_header_exists(p_group_id, p_parent_header_id);
  FETCH job_header_exists INTO l_dummy;
  IF job_header_exists%NOTFOUND THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_INVALID_JOB_HEADER');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    CLOSE job_header_exists;
    RETURN;
  ELSE
    CLOSE job_header_exists;
  END IF;

  l_wip_job_res_rec.load_type := 1; --loading resource
  l_wip_job_res_rec.process_phase := 2;
  l_wip_job_res_rec.process_status := 1;
  l_wip_job_res_rec.group_id := p_group_id;
  l_wip_job_res_rec.parent_header_id := p_parent_header_id;
  l_wip_job_res_rec.creation_date := SYSDATE;
  l_wip_job_res_rec.last_update_date := SYSDATE;
  l_wip_job_res_rec.created_by := fnd_global.user_id;
  l_wip_job_res_rec.last_updated_by := fnd_global.user_id;
  l_wip_job_res_rec.last_update_login := fnd_global.login_id;
  --l_wip_job_res_rec.last_updated_login := fnd_global.conc_login_id;
  l_wip_job_res_rec.request_id := fnd_global.conc_request_id;
  l_wip_job_res_rec.program_id := fnd_global.conc_program_id;
  l_wip_job_res_rec.program_application_id := fnd_global.prog_appl_id;

  IF p_ahl_wo_res_rec.dml_type = 'I' THEN
    l_wip_job_res_rec.substitution_type := 2; --add resource
  ELSIF p_ahl_wo_res_rec.dml_type = 'U' THEN
    l_wip_job_res_rec.substitution_type := 3; --update resource
  ELSIF p_ahl_wo_res_rec.dml_type = 'D' THEN
    l_wip_job_res_rec.substitution_type := 1; --delete resource
  END IF;

  l_wip_job_res_rec.organization_id := p_ahl_wo_res_rec.organization_id;
  l_wip_job_res_rec.operation_seq_num := p_ahl_wo_res_rec.operation_seq_num;
  l_wip_job_res_rec.resource_seq_num := p_ahl_wo_res_rec.resource_seq_num;
  l_wip_job_res_rec.department_id := p_ahl_wo_res_rec.department_id;
  l_wip_job_res_rec.description := p_ahl_wo_res_rec.description;
  l_wip_job_res_rec.schedule_seq_num := p_ahl_wo_res_rec.scheduled_sequence;
  l_wip_job_res_rec.resource_id_new := p_ahl_wo_res_rec.resource_id_new;
  l_wip_job_res_rec.resource_id_old := p_ahl_wo_res_rec.resource_id_old;
  l_wip_job_res_rec.uom_code := p_ahl_wo_res_rec.uom;
  l_wip_job_res_rec.basis_type := p_ahl_wo_res_rec.cost_basis;
  l_wip_job_res_rec.usage_rate_or_amount := p_ahl_wo_res_rec.quantity;
  l_wip_job_res_rec.assigned_units := p_ahl_wo_res_rec.assigned_units;
  l_wip_job_res_rec.scheduled_flag := p_ahl_wo_res_rec.scheduled_flag;
  l_wip_job_res_rec.activity_id := p_ahl_wo_res_rec.activity_id;
  l_wip_job_res_rec.autocharge_type := p_ahl_wo_res_rec.autocharge_type;
  l_wip_job_res_rec.standard_rate_flag := p_ahl_wo_res_rec.standard_rate_flag;
  l_wip_job_res_rec.applied_resource_units := p_ahl_wo_res_rec.applied_resource_units;
  l_wip_job_res_rec.applied_resource_value := p_ahl_wo_res_rec.applied_resource_value;
  l_wip_job_res_rec.start_date := p_ahl_wo_res_rec.start_date;
  l_wip_job_res_rec.completion_date := p_ahl_wo_res_rec.end_date;
  l_wip_job_res_rec.setup_id := p_ahl_wo_res_rec.setup_id;

  --insert into table WJDI
  BEGIN
    INSERT INTO wip_job_dtls_interface
    ( last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      load_type,
      process_phase,
      process_status,
      group_id,
      parent_header_id,
      substitution_type,
      operation_seq_num,
      resource_seq_num,
      organization_id,
      department_id,
      schedule_seq_num,
      resource_id_old,
      resource_id_new,
      uom_code,
      basis_type,
      usage_rate_or_amount,
      assigned_units,
      scheduled_flag,
      activity_id,
      autocharge_type,
      standard_rate_flag,
      applied_resource_units,
      applied_resource_value,
      description,
      start_date,
      completion_date,
      setup_id)
    VALUES
    ( l_wip_job_res_rec.last_update_date,
      l_wip_job_res_rec.last_updated_by,
      l_wip_job_res_rec.creation_date,
      l_wip_job_res_rec.created_by,
      l_wip_job_res_rec.last_update_login,
      l_wip_job_res_rec.request_id,
      l_wip_job_res_rec.program_id,
      l_wip_job_res_rec.program_application_id,
      l_wip_job_res_rec.program_update_date,
      l_wip_job_res_rec.load_type,
      l_wip_job_res_rec.process_phase,
      l_wip_job_res_rec.process_status,
      l_wip_job_res_rec.group_id,
      l_wip_job_res_rec.parent_header_id,
      l_wip_job_res_rec.substitution_type,
      l_wip_job_res_rec.operation_seq_num,
      l_wip_job_res_rec.resource_seq_num,
      l_wip_job_res_rec.organization_id,
      l_wip_job_res_rec.department_id,
      l_wip_job_res_rec.schedule_seq_num,
      l_wip_job_res_rec.resource_id_old,
      l_wip_job_res_rec.resource_id_new,
      l_wip_job_res_rec.uom_code,
      l_wip_job_res_rec.basis_type,
      l_wip_job_res_rec.usage_rate_or_amount,
      l_wip_job_res_rec.assigned_units,
      l_wip_job_res_rec.scheduled_flag,
      l_wip_job_res_rec.activity_id,
      l_wip_job_res_rec.autocharge_type,
      l_wip_job_res_rec.standard_rate_flag,
      l_wip_job_res_rec.applied_resource_units,
      l_wip_job_res_rec.applied_resource_value,
      l_wip_job_res_rec.description,
      l_wip_job_res_rec.start_date,
      l_wip_job_res_rec.completion_date,
      l_wip_job_res_rec.setup_id);
  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_JOB_RES_INSERT_ERR');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE;
  END;
  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('Finish: insert_job_resource, x_return_status='||x_return_status);
  --dbms_output.put_line('Finish: insert_job_resource, x_return_status='||x_return_status);
  END IF;
END insert_job_resource;

-- Declare and define local procedure insert_job_material --
PROCEDURE insert_job_material(
  p_ahl_wo_mtl_rec   IN	AHL_WO_MTL_REC_TYPE,
  p_group_id 	     IN	NUMBER,
  p_parent_header_id IN	NUMBER,
  x_return_status    OUT NOCOPY VARCHAR2
) IS
  l_wip_job_mtl_rec  wip_job_dtls_interface%ROWTYPE;
  l_dummy            VARCHAR2(1);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Ensure the DML operation for the Job material is Insert, Update or Delete
  IF (p_ahl_wo_mtl_rec.dml_type <> 'I' AND p_ahl_wo_mtl_rec.dml_type <> 'U'
      AND p_ahl_wo_mtl_rec.dml_type <> 'D') THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_INVALID_MTL_DML_TYPE');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN;
  END IF;

  -- Validate p_group_id and p_parent_header_id
  OPEN job_header_exists(p_group_id, p_parent_header_id);
  FETCH job_header_exists INTO l_dummy;
  IF job_header_exists%NOTFOUND THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_INVALID_JOB_HEADER');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    CLOSE job_header_exists;
    RETURN;
  ELSE
    CLOSE job_header_exists;
  END IF;

  l_wip_job_mtl_rec.load_type := 2; --loading material
  l_wip_job_mtl_rec.process_phase := 2;
  l_wip_job_mtl_rec.process_status := 1;
  l_wip_job_mtl_rec.group_id := p_group_id;
  l_wip_job_mtl_rec.parent_header_id := p_parent_header_id;
  l_wip_job_mtl_rec.creation_date := SYSDATE;
  l_wip_job_mtl_rec.last_update_date := SYSDATE;
  l_wip_job_mtl_rec.created_by := fnd_global.user_id;
  l_wip_job_mtl_rec.last_updated_by := fnd_global.user_id;
  l_wip_job_mtl_rec.last_update_login := fnd_global.login_id;
  --l_wip_job_mtl_rec.last_updated_login := fnd_global.conc_login_id;
  l_wip_job_mtl_rec.request_id := fnd_global.conc_request_id;
  l_wip_job_mtl_rec.program_id := fnd_global.conc_program_id;
  l_wip_job_mtl_rec.program_application_id := fnd_global.prog_appl_id;

  IF p_ahl_wo_mtl_rec.dml_type = 'I' THEN
    l_wip_job_mtl_rec.substitution_type := 2; --add materila
  ELSIF p_ahl_wo_mtl_rec.dml_type = 'U' THEN
    l_wip_job_mtl_rec.substitution_type := 3; --update material
  ELSIF p_ahl_wo_mtl_rec.dml_type = 'D' THEN
    l_wip_job_mtl_rec.substitution_type := 1; --delete material
  END IF;

  l_wip_job_mtl_rec.organization_id := p_ahl_wo_mtl_rec.organization_id;
  l_wip_job_mtl_rec.operation_seq_num := p_ahl_wo_mtl_rec. operation_seq_num;
  l_wip_job_mtl_rec.inventory_item_id_new := p_ahl_wo_mtl_rec.inventory_item_id_new;
  l_wip_job_mtl_rec.inventory_item_id_old := p_ahl_wo_mtl_rec.inventory_item_id_old;
  l_wip_job_mtl_rec.mrp_net_flag := p_ahl_wo_mtl_rec.mrp_net;
  l_wip_job_mtl_rec.quantity_per_assembly := p_ahl_wo_mtl_rec.quantity_per_assembly;
  l_wip_job_mtl_rec.required_quantity := p_ahl_wo_mtl_rec.required_quantity;
  l_wip_job_mtl_rec.wip_supply_type := p_ahl_wo_mtl_rec.supply_type;
  l_wip_job_mtl_rec.supply_locator_id := p_ahl_wo_mtl_rec.supply_locator_id;
  l_wip_job_mtl_rec.supply_subinventory := p_ahl_wo_mtl_rec.supply_subinventory;
  l_wip_job_mtl_rec.date_required := p_ahl_wo_mtl_rec.date_required;

  --Insert into table WJDI
  BEGIN
    INSERT INTO wip_job_dtls_interface
    ( last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      load_type,
      process_phase,
      process_status,
      group_id,
      parent_header_id,
      substitution_type,
      operation_seq_num,
      organization_id,
      inventory_item_id_old,
      inventory_item_id_new,
      mrp_net_flag,
      quantity_per_assembly,
      required_quantity,
      wip_supply_type,
      supply_locator_id,
      supply_subinventory,
      date_required)
    VALUES
    ( l_wip_job_mtl_rec.last_update_date,
      l_wip_job_mtl_rec.last_updated_by,
      l_wip_job_mtl_rec.creation_date,
      l_wip_job_mtl_rec.created_by,
      l_wip_job_mtl_rec.last_update_login,
      l_wip_job_mtl_rec.request_id,
      l_wip_job_mtl_rec.program_id,
      l_wip_job_mtl_rec.program_application_id,
      l_wip_job_mtl_rec.program_update_date,
      l_wip_job_mtl_rec.load_type,
      l_wip_job_mtl_rec.process_phase,
      l_wip_job_mtl_rec.process_status,
      l_wip_job_mtl_rec.group_id,
      l_wip_job_mtl_rec.parent_header_id,
      l_wip_job_mtl_rec.substitution_type,
      l_wip_job_mtl_rec.operation_seq_num,
      l_wip_job_mtl_rec.organization_id,
      l_wip_job_mtl_rec.inventory_item_id_old,
      l_wip_job_mtl_rec.inventory_item_id_new,
      l_wip_job_mtl_rec.mrp_net_flag,
      l_wip_job_mtl_rec.quantity_per_assembly,
      l_wip_job_mtl_rec.required_quantity,
      l_wip_job_mtl_rec.wip_supply_type,
      l_wip_job_mtl_rec.supply_locator_id,
      l_wip_job_mtl_rec.supply_subinventory,
      l_wip_job_mtl_rec.date_required);
  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_JOB_MTL_INSERT_ERR');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE;
  END;
  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('Finish: insert_job_material, x_return_status='||x_return_status);
  --dbms_output.put_line('Finish: insert_job_material, x_return_status='||x_return_status);
  END IF;
END insert_job_material;

-- Declare and define local procedure submit_wip_load --
PROCEDURE submit_wip_load(
  x_return_status   OUT NOCOPY VARCHAR2,
  p_group_id 	    IN	NUMBER
) IS
  l_dummy           VARCHAR2(1);
  l_targetp         NUMBER;
  l_activep         NUMBER;
  l_targetp1        NUMBER;
  l_activep1        NUMBER;
  l_pmon_method     VARCHAR2(30);
  l_callstat        NUMBER;
  l_req_id          NUMBER;
  l_boolvar         BOOLEAN;
  l_phase           VARCHAR2(80);
  l_status          VARCHAR2(80);
  l_dev_phase       VARCHAR2(80);
  l_dev_status      VARCHAR2(80);
  l_message         VARCHAR2(255);
  CURSOR job_header_exists(c_group_id NUMBER) IS
    SELECT 'X'
    FROM wip_job_schedule_interface
    WHERE group_id = c_group_id;

BEGIN
  -- Validate p_group_id
  OPEN job_header_exists(p_group_id);
  FETCH job_header_exists INTO l_dummy;
  IF job_header_exists%NOTFOUND THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_INVALID_JOB_HEADER');
    FND_MSG_PUB.ADD;
    CLOSE job_header_exists;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN;
  ELSE
    CLOSE job_header_exists;
  END IF;

  -- check whether Internal Concurrent Manager is up
  fnd_concurrent.get_manager_status(applid => 0,
                                    managerid => 1,
                                    targetp => l_targetp1,
                                    activep => l_activep1,
                                    pmon_method => l_pmon_method,
                                    callstat => l_callstat);
  -- check whether Standard Concurrent Manager is up, this is not optional.
  fnd_concurrent.get_manager_status(applid => 0,
                                    managerid => 0,
                                    targetp => l_targetp,
                                    activep => l_activep,
                                    pmon_method => l_pmon_method,
                                    callstat => l_callstat);
  IF (l_activep <= 0 OR l_activep1 <= 0) THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_CM_DOWN');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN;
  END IF;

  -- check whether Concurrent Program is available
  IF NOT fnd_program.program_exists('WICMLP','WIP') THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_NO_WICMLP');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN;
  END IF;

  -- check whether Concurrent Executible is available
  IF NOT fnd_program.executable_exists('WICMLX','WIP') THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_NO_WICMLX');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN;
  END IF;

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('Inside: submit_wip_load, just before calling submit_request');
  --dbms_output.put_line('Inside: submit_wip_load, just before calling submit_request');
  END IF;
  -- submit request of WIP Mass Load
  l_req_id := fnd_request.submit_request('WIP','WICMLP', NULL, NULL, FALSE,
                                       TO_CHAR(p_group_id), 0, 1);

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('When calling submit_request, the group_id is '||to_char(p_group_id));
  --dbms_output.put_line('When calling submit_request, the group_id is '||to_char(p_group_id));
  END IF;
  IF (l_req_id = 0 ) THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WICMLP_SUBMIT_FAILURE');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('Submit request itself failed and the initialized parameters for the application are: ');
    --dbms_output.put_line('Submit request itself failed and the initialized parameters for the application are: ');
      AHL_DEBUG_PUB.debug('user_id='||to_char(fnd_global.user_id)||' resp_id='||to_char(fnd_global.resp_id)||' resp_appl_id='||to_char(fnd_global.resp_appl_id));
    --dbms_output.put_line('user_id='||to_char(fnd_global.user_id)||' resp_id='||to_char(fnd_global.resp_id)||' resp_appl_id='||to_char(fnd_global.resp_appl_id));
      AHL_DEBUG_PUB.debug('user_name='||fnd_global.user_name||' resp_name='||fnd_global.resp_name||' application_name='||fnd_global.application_name);
    --dbms_output.put_line('user_name='||fnd_global.user_name||' resp_name='||fnd_global.resp_name||' application_name='||fnd_global.application_name);
    END IF;
  ELSE
    COMMIT; --This commit is a must;
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('After commit and before waiting for request');
    --dbms_output.put_line('After commit and before waiting for request');
    END IF;
    -- wait for the execution result of WIP Mass Load
    l_boolvar := fnd_concurrent.wait_for_request(
                   request_id => l_req_id,
                   interval => 15,
                   max_wait => 0,
                   phase => l_phase,
                   status => l_status,
                   dev_phase => l_dev_phase,
                   dev_status => l_dev_status,
                   message => l_message);
    IF NOT l_boolvar THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WICMLP_WAIT_FAILURE');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug('Wait for request itself failed');
      --dbms_output.put_line('Wait for request itself failed');
      END IF;
    ELSIF (l_dev_phase = 'COMPLETE' AND l_dev_status = 'NORMAL') THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;
  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('Finish: submit_wip_load, x_return_status='||x_return_status);
  --dbms_output.put_line('Finish: submit_wip_load, x_return_status='||x_return_status);
  END IF;
END submit_wip_load;

-- Define procedure load_wip_job --
PROCEDURE load_wip_job(
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
--  p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_ahl_wo_rec	          IN  ahl_wo_rec_type,
  p_ahl_wo_op_tbl         IN  ahl_wo_op_tbl_type,
  p_ahl_wo_res_tbl        IN  ahl_wo_res_tbl_type,
  p_ahl_wo_mtl_tbl        IN  ahl_wo_mtl_tbl_type,
  x_wip_entity_id         OUT NOCOPY NUMBER
) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  --This API is Autonomous Transaction. We have to explicitly commit or rollback the
  --transactions it or its called procedure contains when it exits. This autonomous
  --transaction doesn't affect the main transaction in its calling API.

  i                       NUMBER;
  l_api_name              CONSTANT VARCHAR2(30) := 'LOAD_WIP_JOB';
  l_api_version           CONSTANT NUMBER       := 1.0;
  l_msg_count             NUMBER;
  l_return_status         VARCHAR2(1);
  l_group_id              NUMBER;
  l_header_id             NUMBER;

  l_interface1_id        NUMBER;
  l_error_msg            VARCHAR2(5000);
  l_interface_ids        num_array_type;
  l_commit_flag          NUMBER;

  CURSOR get_header_interface(c_job_name VARCHAR2, c_organization_id NUMBER,
                              c_group_id NUMBER) IS
    SELECT interface_id, header_id
    FROM wip_job_schedule_interface
    WHERE job_name = c_job_name
    AND organization_id = c_organization_id
    AND group_id = c_group_id;

  CURSOR get_cp_sts(c_group_id NUMBER, c_header_id NUMBER) IS
    SELECT process_phase, process_status
    FROM wip_job_schedule_interface
    WHERE group_id = c_group_id
    AND header_id = c_header_id;
  l_get_cp_sts              get_cp_sts%ROWTYPE;

BEGIN
  --SAVEPOINT LOAD_WIP_JOB_PVT;
  --Savepoint here is not necessary, because we have a commit statement in its called
  --procedure submit_wip_load and it will make this savepoint invalid.
  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.enable_debug;
    AHL_DEBUG_PUB.debug('Begin private API: AHL_WIP_JOB_PVT.LOAD_WIP_JOB');
  END IF;
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version,
                                     l_api_name, G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('Inside: load_wip_job, just before calling insert_job_header');
  --dbms_output.put_line('Inside: load_wip_job, just before calling insert_job_header');
  END IF;
  --insert job header first
  insert_job_header( p_ahl_wo_rec => p_ahl_wo_rec,
                     p_group_id => NULL, --for single job submission
                     p_header_id => NULL,
                     x_group_id => l_group_id,
                     x_header_id => l_header_id,
                     x_return_status => l_return_status );
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('Inside: load_wip_job, just before calling insert_job_operation');
  --dbms_output.put_line('Inside: load_wip_job, just before calling insert_job_operation');
  END IF;
  --insert job operations if they are available
  IF p_ahl_wo_op_tbl.count > 0 THEN
    FOR i IN p_ahl_wo_op_tbl.FIRST..p_ahl_wo_op_tbl.LAST LOOP
      insert_job_operation( p_ahl_wo_op_rec => p_ahl_wo_op_tbl(i),
                            p_group_id => l_group_id,
                            p_parent_header_id => l_header_id,
                            x_return_status => l_return_status );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END LOOP;
  END IF;

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('Inside: load_wip_job, just before calling insert_job_resource');
  --dbms_output.put_line('Inside: load_wip_job, just before calling insert_job_resource');
  END IF;
  --insert resource requirements if they are available
  IF p_ahl_wo_res_tbl.count > 0 THEN
    FOR i IN p_ahl_wo_res_tbl.FIRST..p_ahl_wo_res_tbl.LAST LOOP
      insert_job_resource( p_ahl_wo_res_rec => p_ahl_wo_res_tbl(i),
                           p_group_id => l_group_id,
                           p_parent_header_id => l_header_id,
                           x_return_status => l_return_status );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END LOOP;
  END IF;

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('Inside: load_wip_job, just before calling insert_job_material');
  --dbms_output.put_line('Inside: load_wip_job, just before calling insert_job_material');
  END IF;
  --insert material requirements if they are available
  IF p_ahl_wo_mtl_tbl.count > 0 THEN
    FOR i IN p_ahl_wo_mtl_tbl.FIRST..p_ahl_wo_mtl_tbl.LAST LOOP
      insert_job_material( p_ahl_wo_mtl_rec => p_ahl_wo_mtl_tbl(i),
                           p_group_id => l_group_id,
                           p_parent_header_id => l_header_id,
                           x_return_status => l_return_status );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END LOOP;
  END IF;

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('Inside: load_wip_job, just before calling submit_wip_load');
  --dbms_output.put_line('Inside: load_wip_job, just before calling submit_wip_load');
  END IF;
  --submit WIP Mass Load
  submit_wip_load( p_group_id => l_group_id,
                   x_return_status => l_return_status);

  --check the process_phase and process_status in WJSI
  OPEN get_cp_sts(l_group_id, l_header_id);
  FETCH get_cp_sts INTO l_get_cp_sts;

  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    CLOSE get_cp_sts;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_SUCCESS AND (get_cp_sts%NOTFOUND OR
         (l_get_cp_sts.process_phase = 4 AND l_get_cp_sts.process_status = 4))) THEN
    CLOSE get_cp_sts;
    OPEN get_wip_entity(p_ahl_wo_rec.wo_name, p_ahl_wo_rec.organization_id);
    FETCH get_wip_entity INTO x_wip_entity_id;
    IF get_wip_entity%NOTFOUND THEN
      CLOSE get_wip_entity;
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_NO_WIP_ENTITY_ID');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      CLOSE get_wip_entity;
    END IF;
    --call EAM API to update manual_rebuild_flag because WICMLP can't change it.
    IF (p_ahl_wo_rec.dml_type = 'U' AND p_ahl_wo_rec.manual_rebuild_flag IS NOT NULL) THEN
      eam_workordertransactions_pub.set_manual_reb_flag(
            p_wip_entity_id => x_wip_entity_id,
            p_organization_id => p_ahl_wo_rec.organization_id,
            p_manual_rebuild_flag => p_ahl_wo_rec.manual_rebuild_flag,
            x_return_status => l_return_status);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_PRD_EAM_REBUILD_FLAG_FAIL');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
    --call EAM API to update owning_department_id because WICMLP can't change it.
    IF (p_ahl_wo_rec.dml_type = 'U' AND p_ahl_wo_rec.department_id IS NOT NULL) THEN
      eam_workordertransactions_pub.set_owning_department(
            p_wip_entity_id => x_wip_entity_id,
            p_organization_id => p_ahl_wo_rec.organization_id,
            p_owning_department => p_ahl_wo_rec.department_id,
            x_return_status => l_return_status);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_PRD_EAM_OWN_DEPT_FAIL');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

  ELSE
    CLOSE get_cp_sts;
    OPEN get_header_interface(p_ahl_wo_rec.wo_name, p_ahl_wo_rec.organization_id, l_group_id);
    FETCH get_header_interface INTO l_interface1_id, l_header_id;
    IF get_header_interface%NOTFOUND THEN
      CLOSE get_header_interface;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      CLOSE get_header_interface;
    END IF;

    l_interface_ids(1) := l_interface1_id;
    i := 2;
    FOR l_get_interface_ids IN get_interface_ids(l_group_id, l_header_id) LOOP
      l_interface_ids(i) := l_get_interface_ids.interface_id ;
      i := i + 1;
    END LOOP;

    l_error_msg := '';
    FOR i IN l_interface_ids.FIRST..l_interface_ids.LAST LOOP
      FOR l_get_error_msg IN get_error_msg(l_interface_ids(i)) LOOP
        --l_error_msg := l_error_msg || replace(l_get_error_msg.error,chr(10)||chr(10),chr(10));
        --chr(10)='\n', chr(13)='\r', chr() function will fail in GSCC standards
        l_error_msg := l_error_msg || l_get_error_msg.error;
      END LOOP;
    END LOOP;

    --No deletion for the failed records in debug mode.
    IF fnd_profile.value('MRP_DEBUG') <> 'Y' THEN
      FOR i IN l_interface_ids.FIRST..l_interface_ids.LAST LOOP
        DELETE FROM wip_interface_errors
        WHERE interface_id = l_interface_ids(i);
      END LOOP;

      DELETE FROM wip_job_dtls_interface
      WHERE group_id = l_group_id
      AND parent_header_id = l_header_id;

      DELETE FROM wip_job_schedule_interface
      WHERE group_id = l_group_id
      AND header_id = l_header_id;
    END IF;

    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WICMLP_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR',l_error_msg);
    FND_MSG_PUB.ADD;
    x_msg_count := 1;
    x_msg_data := l_error_msg;
    x_return_status := FND_API.G_RET_STS_ERROR;

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('The concatenated error message is '||x_msg_data);
    --dbms_output.put_line(substr('The concatenated error message is '||x_msg_data, 1, 255));
    END IF;
  END IF;

  COMMIT; --Autonomous Transaction Required

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('End private API: AHL_WIP_JOB_PVT.LOAD_WIP_JOB');
    AHL_DEBUG_PUB.disable_debug;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.log_app_messages(x_msg_count, x_msg_data,
                                    'UNEXPECTED ERROR IN PRIVATE:' );
      AHL_DEBUG_PUB.debug('AHL_WIP_JOB_PVT.LOAD_WIP_JOB');
      AHL_DEBUG_PUB.disable_debug;
    END IF;
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.log_app_messages(x_msg_count, x_msg_data,
                                     'ERROR IN PRIVATE:' );
      AHL_DEBUG_PUB.debug('AHL_WIP_JOB_PVT.LOAD_WIP_JOB');
      AHL_DEBUG_PUB.disable_debug;
    END IF;
  WHEN OTHERS THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg(p_pkg_name       => 'AHL_WIP_JOB_PVT',
                              p_procedure_name => 'LOAD_WIP_JOB');
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data,
                                      'OTHER ERROR IN PRIVATE:' );
      AHL_DEBUG_PUB.debug('AHL_WIP_JOB_PVT.LOAD_WIP_JOB');
      AHL_DEBUG_PUB.disable_debug;
    END IF;

END load_wip_job;

-- Define procedure insert_resource_txn --
PROCEDURE insert_resource_txn(
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_ahl_res_txn_tbl       IN  ahl_res_txn_tbl_type
) IS
  l_api_name              CONSTANT VARCHAR2(30) := 'INSERT_RESOURCE_TXN';
  l_api_version           CONSTANT NUMBER       := 1.0;
  l_msg_count             NUMBER;
  l_return_status         VARCHAR2(1);
  l_wip_cost_txn_rec      wip_cost_txn_interface%ROWTYPE;

  CURSOR get_user_name (c_user_id NUMBER) IS
    SELECT user_name
    FROM fnd_user
    WHERE user_id = c_user_id;
  l_user_name            get_user_name%ROWTYPE;
  CURSOR get_org_code (c_org_id NUMBER) IS
    SELECT organization_code
    FROM mtl_parameters
    WHERE organization_id = c_org_id;
  l_org_code             get_org_code%ROWTYPE;
  CURSOR get_job_attr (c_wip_entity_id NUMBER) IS
    -- fix for bug# 3161312.
    /*SELECT organization_id, wip_entity_name, entity_type
    FROM wip_entities
    WHERE wip_entity_id = c_wip_entity_id;*/

    SELECT WDJ.project_id project_id,
           WDJ.task_id task_id,
           WE.organization_id organization_id,
           WE.wip_entity_name wip_entity_name,
           WE.entity_type entity_type
    FROM   wip_discrete_jobs WDJ,
           wip_entities WE
    WHERE  WDJ.wip_entity_id = WE.wip_entity_id
    AND    WE.wip_entity_id = c_wip_entity_id;

  l_job_attr             get_job_attr%ROWTYPE;
  CURSOR get_employee_num (c_employee_id NUMBER, c_org_id NUMBER) IS
    /* SELECT employee_number,
           instance_id
    FROM bom_resource_employees bre, per_all_people_f pap
    WHERE bre.person_id = pap.person_id
    AND   pap.person_id = c_employee_id; */

    -- bug# 4553747.
    SELECT employee_num employee_number,
           instance_id
    FROM bom_resource_employees bre, mtl_employees_current_view mec
    WHERE bre.person_id = mec.employee_id
    AND   mec.employee_id = c_employee_id
    AND   bre.organization_id = mec.organization_id
    AND   mec.organization_id = c_org_id;

  l_employee_num     get_employee_num%ROWTYPE;
  --Adithya modified the cursor code for Bug # 6326254 - Start
 CURSOR get_instance_sernum (c_department_id NUMBER,
                             c_serial_number VARCHAR2,
                             c_resource_id NUMBER,
                             c_organization_id NUMBER)
  IS
    SELECT instance_id
    FROM bom_dept_res_instances
    WHERE department_id in (
    		   select
  			 distinct nvl(bodres.share_from_dept_id, bodres.department_id)
  		   from
  			 bom_departments bomdep,
  			 bom_department_resources bodres
  		   where
  			 bodres.department_id = bomdep.department_id and
  			 bomdep.department_id = c_department_id and
  			 bomdep.organization_id = c_organization_id
    )
    and   Serial_Number=c_serial_number
    and   Resource_id=c_resource_id;

  -- Changes for bug #  6326254 - Begin

  CURSOR get_operation_dept(c_wip_entity_id NUMBER, c_op_seq_no NUMBER)
  IS
  SELECT
     department_id
  FROM
     WIP_OPERATIONS
  WHERE
     wip_entity_id = c_wip_entity_id and
     operation_seq_num = c_op_seq_no;

  l_op_dept_id NUMBER;

  -- Changes for bug #  6326254 - End

BEGIN
  SAVEPOINT INSERT_RESOURCE_TXN_PVT;
  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.enable_debug;
    AHL_DEBUG_PUB.debug('Begin private API: AHL_WIP_JOB_PVT.INSERT_RESOURCE_TXN');
  END IF;
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version,
                                     l_api_name, G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF p_ahl_res_txn_tbl.count <= 0 THEN
    FND_MESSAGE.set_name('AHL','AHL_PRD_NO_RECORDS_IN_TBL');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  OPEN get_user_name(fnd_global.user_id);
  FETCH get_user_name INTO l_user_name;
  IF get_user_name%NOTFOUND THEN
    FND_MESSAGE.set_name('AHL','AHL_PRD_USER_ID_INVALID');
    FND_MSG_PUB.add;
    CLOSE get_user_name;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE get_user_name;

  FOR i IN p_ahl_res_txn_tbl.FIRST..p_ahl_res_txn_tbl.LAST LOOP
    -- Clear the record before every iteration
    -- Adithya added for Bug # 6326254.
    l_wip_cost_txn_rec := null;

    OPEN get_job_attr(p_ahl_res_txn_tbl(i).wip_entity_id);
    FETCH get_job_attr INTO l_job_attr;
    IF get_job_attr%NOTFOUND THEN
      FND_MESSAGE.set_name('AHL','AHL_PRD_NO_WIP_ENTITY_ID');
      FND_MSG_PUB.add;
      CLOSE get_job_attr;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE get_job_attr;

    OPEN get_org_code(l_job_attr.organization_id);
    FETCH get_org_code INTO l_org_code;
    IF get_org_code%NOTFOUND THEN
      FND_MESSAGE.set_name('AHL','AHL_PRD_ORG_ID_INVALID');
      FND_MSG_PUB.add;
      CLOSE get_org_code;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE get_org_code;

    l_wip_cost_txn_rec.process_phase := 1;  --Resource Validation
    l_wip_cost_txn_rec.process_status := 1; --Pending
    l_wip_cost_txn_rec.source_code := 'Service';

    l_wip_cost_txn_rec.creation_date := sysdate;
    l_wip_cost_txn_rec.last_update_date := sysdate;
    l_wip_cost_txn_rec.created_by := fnd_global.user_id;
    --created_by_name is mandatory, otherwise Cost Manager won't pick it up.
    l_wip_cost_txn_rec.created_by_name := l_user_name.user_name;
    l_wip_cost_txn_rec.last_updated_by := fnd_global.user_id;
    --last_updated_by_name is mandatory, otherwise Cost Manager won't pick it up.
    l_wip_cost_txn_rec.last_updated_by_name := l_user_name.user_name;
    l_wip_cost_txn_rec.last_update_login := fnd_global.login_id;
    --l_wip_cost_txn_rec.last_updated_login := fnd_global.conc_login_id;
    l_wip_cost_txn_rec.request_id := fnd_global.conc_request_id;
    l_wip_cost_txn_rec.program_id := fnd_global.conc_program_id;
    l_wip_cost_txn_rec.program_application_id := fnd_global.prog_appl_id;

    l_wip_cost_txn_rec.wip_entity_id := p_ahl_res_txn_tbl(i).wip_entity_id;
    --wip_entity_name and entity_type are mandatory, otherwise Cost Manager won't pick it up.
    l_wip_cost_txn_rec.wip_entity_name := l_job_attr.wip_entity_name;
    l_wip_cost_txn_rec.entity_type := l_job_attr.entity_type;
    l_wip_cost_txn_rec.project_id := l_job_attr.project_id;
    l_wip_cost_txn_rec.task_id := l_job_attr.task_id;

    l_wip_cost_txn_rec.organization_id := l_job_attr.organization_id;
    --organization_code is mandatory, otherwise Cost Manager won't pick it up.
    l_wip_cost_txn_rec.organization_code := l_org_code.organization_code;


    l_wip_cost_txn_rec.operation_seq_num := p_ahl_res_txn_tbl(i).operation_seq_num;
    l_wip_cost_txn_rec.resource_seq_num := p_ahl_res_txn_tbl(i).resource_seq_num;
    --The column resource_id must be left NULL according to the document
    --l_wip_cost_txn_rec.resource_id := p_ahl_res_txn_tbl(i).resource_id;
    l_wip_cost_txn_rec.resource_id := NULL;
    IF (p_ahl_res_txn_tbl(i).transaction_type IS NULL) THEN
      l_wip_cost_txn_rec.transaction_type := 1; --Resource Transaction
    ELSE
      l_wip_cost_txn_rec.transaction_type := p_ahl_res_txn_tbl(i).transaction_type;
    END IF;
    IF (p_ahl_res_txn_tbl(i).transaction_date IS NULL) THEN
      l_wip_cost_txn_rec.transaction_date := SYSDATE;
    ELSE
      l_wip_cost_txn_rec.transaction_date := p_ahl_res_txn_tbl(i).transaction_date;
    END IF;
    l_wip_cost_txn_rec.transaction_uom := p_ahl_res_txn_tbl(i).transaction_uom;
    l_wip_cost_txn_rec.transaction_quantity := p_ahl_res_txn_tbl(i).transaction_quantity;
    l_wip_cost_txn_rec.employee_id := p_ahl_res_txn_tbl(i).employee_id;
    --If employee_id is not null, then employee_num is also required, otherwise there will
    --be validation error from Cost Manager
    IF (p_ahl_res_txn_tbl(i).employee_id IS NOT NULL) THEN
      OPEN get_employee_num(p_ahl_res_txn_tbl(i).employee_id, l_job_attr.organization_id);
      FETCH get_employee_num INTO l_employee_num;
      IF get_employee_num%NOTFOUND THEN
        FND_MESSAGE.set_name('AHL','AHL_PRD_EMPLOYEE_ID_INVALID');
        FND_MSG_PUB.add;
        CLOSE get_employee_num;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      CLOSE get_employee_num;
      l_wip_cost_txn_rec.employee_num := l_employee_num.employee_number;
      l_wip_cost_txn_rec.instance_id := l_employee_num.instance_id;
				ELSE
      l_wip_cost_txn_rec.employee_num := NULL;

    END IF;

    l_wip_cost_txn_rec.department_id := p_ahl_res_txn_tbl(i).department_id;
    l_wip_cost_txn_rec.activity_id := p_ahl_res_txn_tbl(i).activity_id;
    l_wip_cost_txn_rec.activity_name := p_ahl_res_txn_tbl(i).activity_meaning;
    l_wip_cost_txn_rec.reason_id := p_ahl_res_txn_tbl(i).reason_id;
    l_wip_cost_txn_rec.reason_name := p_ahl_res_txn_tbl(i).reason;
    l_wip_cost_txn_rec.reference := p_ahl_res_txn_tbl(i).reference;

    IF p_ahl_res_txn_tbl(i).serial_number IS NOT NULL
    AND p_ahl_res_txn_tbl(i).serial_number<>FND_API.G_MISS_CHAR
    THEN
        Open get_instance_sernum (p_ahl_res_txn_tbl(i).department_id,
                                  p_ahl_res_txn_tbl(i).serial_number,
                                  p_ahl_res_txn_tbl(i).resource_id,
                                  l_job_attr.organization_id);    --Adithya modified
        FETCH get_instance_sernum INTO l_wip_cost_txn_rec.instance_id;

    	IF get_instance_sernum%NOTFOUND
        THEN
        FND_MESSAGE.set_name('AHL','AHL_PRD_RESTXN_SERNUM_INVALID');
        FND_MESSAGE.SET_TOKEN('SERNUMB',p_ahl_res_txn_tbl(i).serial_number);
        FND_MSG_PUB.ADD;
    	END IF;
        Close get_instance_sernum;
    END IF;
    --insert resource transaction record into table WIP_COST_TXN_INTERFACE
    -- Adithya added code for populating charge_deparment_id if the input deparment
    -- is different from opeartion deparemt.Bug # 6326254

    OPEN get_operation_dept(l_wip_cost_txn_rec.wip_entity_id, l_wip_cost_txn_rec.operation_seq_num);
    FETCH get_operation_dept INTO l_op_dept_id;
    CLOSE get_operation_dept;

    IF l_op_dept_id <> l_wip_cost_txn_rec.department_id
    THEN
        l_wip_cost_txn_rec.charge_department_id := l_wip_cost_txn_rec.department_id;
    END IF;
    --insert resource transaction record into table WIP_COST_TXN_INTERFACE

   BEGIN
      INSERT INTO wip_cost_txn_interface
      ( last_update_date,
        last_updated_by,
        last_updated_by_name,
        creation_date,
        created_by,
        created_by_name,
        last_update_login,
        request_id,
        program_id,
        program_application_id,
        program_update_date,
        process_phase,
        process_status,
        source_code,
        organization_id,
        organization_code,
        wip_entity_id,
        wip_entity_name,
        entity_type,
        project_id,
        task_id,
        operation_seq_num,
        resource_seq_num,
        resource_id,
        transaction_type,
        transaction_date,
        transaction_quantity,
        transaction_uom,
        employee_id,
        employee_num,
        department_id,
        activity_id,
        activity_name,
        reason_id,
	reason_name,
        reference,
        instance_id,
	charge_department_id)
      VALUES
      ( l_wip_cost_txn_rec.last_update_date,
        l_wip_cost_txn_rec.last_updated_by,
        l_wip_cost_txn_rec.last_updated_by_name,
        l_wip_cost_txn_rec.creation_date,
        l_wip_cost_txn_rec.created_by,
        l_wip_cost_txn_rec.created_by_name,
        l_wip_cost_txn_rec.last_update_login,
        l_wip_cost_txn_rec.request_id,
        l_wip_cost_txn_rec.program_id,
        l_wip_cost_txn_rec.program_application_id,
        l_wip_cost_txn_rec.program_update_date,
        l_wip_cost_txn_rec.process_phase,
        l_wip_cost_txn_rec.process_status,
        l_wip_cost_txn_rec.source_code,
        l_wip_cost_txn_rec.organization_id,
        l_wip_cost_txn_rec.organization_code,
        l_wip_cost_txn_rec.wip_entity_id,
        l_wip_cost_txn_rec.wip_entity_name,
        l_wip_cost_txn_rec.entity_type,
        l_wip_cost_txn_rec.project_id,
        l_wip_cost_txn_rec.task_id,
        l_wip_cost_txn_rec.operation_seq_num,
        l_wip_cost_txn_rec.resource_seq_num,
        l_wip_cost_txn_rec.resource_id,
        l_wip_cost_txn_rec.transaction_type,
        l_wip_cost_txn_rec.transaction_date,
        l_wip_cost_txn_rec.transaction_quantity,
        l_wip_cost_txn_rec.transaction_uom,
        l_wip_cost_txn_rec.employee_id,
        l_wip_cost_txn_rec.employee_num,
        l_wip_cost_txn_rec.department_id,
        l_wip_cost_txn_rec.activity_id,
	l_wip_cost_txn_rec.activity_name,
        l_wip_cost_txn_rec.reason_id,
	l_wip_cost_txn_rec.reason_name,
        l_wip_cost_txn_rec.reference,
        l_wip_cost_txn_rec.instance_id,
	l_wip_cost_txn_rec.charge_department_id);
    -- End of changes for bug # 6326254.
    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_PRD_RES_TXN_INSERT_ERR');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;
    END;
  END LOOP;

  IF FND_API.TO_BOOLEAN(p_commit) THEN
    COMMIT;
  END IF;
  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('End private API: AHL_WIP_JOB_PVT.INSERT_RESOURCE_TXN');
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK TO INSERT_RESOURCE_TXN_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.log_app_messages(x_msg_count, x_msg_data,
                                    'UNEXPECTED ERROR IN PRIVATE:' );
      AHL_DEBUG_PUB.debug('AHL_WIP_JOB_PVT.INSERT_RESOURCE_TXN');
      AHL_DEBUG_PUB.disable_debug;
    END IF;
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO INSERT_RESOURCE_TXN_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.log_app_messages(x_msg_count, x_msg_data,
                                     'ERROR IN PRIVATE:' );
      AHL_DEBUG_PUB.debug('AHL_WIP_JOB_PVT.INSERT_RESOURCE_TXN');
      AHL_DEBUG_PUB.disable_debug;
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO INSERT_RESOURCE_TXN_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg(p_pkg_name       => 'AHL_WIP_JOB_PVT',
                              p_procedure_name => 'INSERT_RESOURCE_TXN');
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data,
                                      'OTHER ERROR IN PRIVATE:' );
      AHL_DEBUG_PUB.debug('AHL_WIP_JOB_PVT.INSERT_RESOURCE_TXN');
      AHL_DEBUG_PUB.disable_debug;
    END IF;

END insert_resource_txn;

-- Define function wip_mass_load_pending --
FUNCTION wip_massload_pending(
  p_wip_entity_id         IN  NUMBER
) RETURN BOOLEAN IS
  CURSOR get_job_name(c_wip_entity_id NUMBER) IS
    SELECT wip_entity_name, organization_id
    FROM wip_entities
    WHERE wip_entity_id = c_wip_entity_id;
  l_job_name              get_job_name%ROWTYPE;
  CURSOR get_pending_job(c_wip_entity_name VARCHAR2, c_organization_id NUMBER) IS
    SELECT 'X'
    FROM wip_job_schedule_interface
    WHERE job_name = c_wip_entity_name
    AND organization_id = c_organization_id
    AND (process_status not in (3, 4, 5)); --The successfully loaded records
    --or failed records still remain in job header interface table if in debug mode.
  l_dummy                 VARCHAR2(1);

BEGIN
  OPEN get_job_name (p_wip_entity_id);
  FETCH get_job_name INTO l_job_name;
  IF get_job_name%NOTFOUND THEN
    CLOSE get_job_name;
    RETURN FALSE;
  ELSE
    OPEN get_pending_job(l_job_name.wip_entity_name, l_job_name.organization_id);
    FETCH get_pending_job INTO l_dummy;
    IF get_pending_job%FOUND THEN
      CLOSE get_pending_job;
      FND_MESSAGE.set_name('AHL','AHL_COM_WIP_LOAD_PENDING');
      FND_MSG_PUB.add;
      RETURN TRUE;
    ELSE
      CLOSE get_pending_job;
      RETURN FALSE;
    END IF;
  END IF;
END wip_massload_pending;

PROCEDURE load_wip_batch_jobs(
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  --  p_commit            IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_group_id              IN  NUMBER,
  p_header_id             IN  NUMBER,
  p_submit_flag           IN  VARCHAR2,
  p_ahl_wo_rec	          IN  ahl_wo_rec_type,
  p_ahl_wo_op_tbl         IN  ahl_wo_op_tbl_type,
  p_ahl_wo_res_tbl        IN  ahl_wo_res_tbl_type,
  p_ahl_wo_mtl_tbl        IN  ahl_wo_mtl_tbl_type,
  x_group_id              OUT NOCOPY NUMBER,
  x_header_id             OUT NOCOPY NUMBER,
  x_ahl_wip_job_tbl       OUT NOCOPY ahl_wip_job_tbl_type
) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  --This API is Autonomous Transaction. We have to explicitly commit or rollback the
  --transactions it or its called procedure contains when it exits. This autonomous
  --transaction doesn't affect the main transaction in its calling API.

  i                       NUMBER;
  j                       NUMBER;
  l_api_name              CONSTANT VARCHAR2(30) := 'LOAD_WIP_BATCH_JOBS';
  l_api_version           CONSTANT NUMBER       := 1.0;
  l_msg_count             NUMBER;
  l_return_status         VARCHAR2(1);
  l_group_id              NUMBER;
  l_header_id             NUMBER;

  l_interface1_id        NUMBER;
  l_error_msg            VARCHAR2(5000);
  l_interface_ids        num_array_type;
  l_commit_flag          NUMBER;

  CURSOR get_job_attr(c_group_id NUMBER, c_header_id NUMBER) IS
    SELECT group_id, header_id, interface_id, process_phase, process_status,
           wip_entity_id, job_name, organization_id
    FROM wip_job_schedule_interface
    WHERE group_id = c_group_id
    AND header_id = c_header_id;
  l_get_job_attr            get_job_attr%ROWTYPE;

BEGIN
  --SAVEPOINT LOAD_WIP_JOB_PVT;
  --Savepoint here is not necessary, because we have a commit statement in its called
  --procedure submit_wip_load and it will make this savepoint invalid.
  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.enable_debug;
    AHL_DEBUG_PUB.debug('Begin private API: AHL_WIP_JOB_PVT.LOAD_WIP_BATCH_JOBS');
  END IF;
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version,
                                     l_api_name, G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('Inside: load_wip_batch_jobs, just before calling insert_job_header');
  --dbms_output.put_line('Inside: load_wip_batch_jobs, just before calling insert_job_header');
  END IF;
  --insert job header first
  insert_job_header( p_ahl_wo_rec => p_ahl_wo_rec,
                     p_group_id => p_group_id,
                     p_header_id => p_header_id,
                     x_group_id => l_group_id,
                     x_header_id => l_header_id,
                     x_return_status => l_return_status );
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('Inside: load_wip_batch_jobs, just before calling insert_job_operation');
  --dbms_output.put_line('Inside: load_wip_batch_jobs, just before calling insert_job_operation');
  END IF;
  --insert job operations if they are available
  IF p_ahl_wo_op_tbl.count > 0 THEN
    FOR i IN p_ahl_wo_op_tbl.FIRST..p_ahl_wo_op_tbl.LAST LOOP
      insert_job_operation( p_ahl_wo_op_rec => p_ahl_wo_op_tbl(i),
                            p_group_id => l_group_id,
                            p_parent_header_id => l_header_id,
                            x_return_status => l_return_status );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END LOOP;
  END IF;

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('Inside: load_wip_batch_jobs, just before calling insert_job_resource');
  --dbms_output.put_line('Inside: load_wip_batch_jobs, just before calling insert_job_resource');
  END IF;
  --insert resource requirements if they are available
  IF p_ahl_wo_res_tbl.count > 0 THEN
    FOR i IN p_ahl_wo_res_tbl.FIRST..p_ahl_wo_res_tbl.LAST LOOP
      insert_job_resource( p_ahl_wo_res_rec => p_ahl_wo_res_tbl(i),
                           p_group_id => l_group_id,
                           p_parent_header_id => l_header_id,
                           x_return_status => l_return_status );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END LOOP;
  END IF;

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('Inside: load_wip_batch_jobs, just before calling insert_job_material');
  --dbms_output.put_line('Inside: load_wip_batch_jobs, just before calling insert_job_material');
  END IF;
  --insert material requirements if they are available
  IF p_ahl_wo_mtl_tbl.count > 0 THEN
    FOR i IN p_ahl_wo_mtl_tbl.FIRST..p_ahl_wo_mtl_tbl.LAST LOOP
      insert_job_material( p_ahl_wo_mtl_rec => p_ahl_wo_mtl_tbl(i),
                           p_group_id => l_group_id,
                           p_parent_header_id => l_header_id,
                           x_return_status => l_return_status );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END LOOP;
  END IF;

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('Inside: load_wip_batch_jobs, just before calling submit_wip_load');
  --dbms_output.put_line('Inside: load_wip_batch_jobs, just before calling submit_wip_load');
  END IF;
  --submit WIP Mass Load

  x_header_id := l_header_id;
  x_group_id := l_group_id;
  IF (p_submit_flag = 'Y') THEN
    -- Before submitting request, save the job_name and organization_id for all the jobs
    -- in this group.
    FOR i IN 0..(l_header_id - l_group_id) LOOP
      OPEN get_job_attr(l_group_id, l_group_id + i);
      FETCH get_job_attr INTO l_get_job_attr;
      IF get_job_attr%NOTFOUND THEN
        CLOSE get_job_attr;
        FND_MESSAGE.set_name('AHL','AHL_WIP_ITF_REC_NOT_FOUND');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      x_ahl_wip_job_tbl(i+1).wip_entity_name := l_get_job_attr.job_name;
      x_ahl_wip_job_tbl(i+1).organization_id := l_get_job_attr.organization_id;
      CLOSE get_job_attr;
    END LOOP;

    submit_wip_load( p_group_id => l_group_id,
                     x_return_status => l_return_status);

    -- Check whether wait_for_request fails
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- if wait_for_request returns normally
    FOR i IN 0..(l_header_id - l_group_id) LOOP
      OPEN get_job_attr(l_group_id, l_group_id + i);
      FETCH get_job_attr INTO l_get_job_attr;

      IF (get_job_attr%NOTFOUND OR
           (l_get_job_attr.process_phase = 4 AND l_get_job_attr.process_status = 4)) THEN
        OPEN get_wip_entity(x_ahl_wip_job_tbl(i+1).wip_entity_name,
                            x_ahl_wip_job_tbl(i+1).organization_id);
        FETCH get_wip_entity INTO x_ahl_wip_job_tbl(i+1).wip_entity_id;
        IF get_wip_entity%NOTFOUND THEN
          CLOSE get_wip_entity;
          CLOSE get_job_attr;
          FND_MESSAGE.SET_NAME('AHL','AHL_PRD_NO_WIP_ENTITY_ID');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSE
          CLOSE get_wip_entity;
        END IF;
        x_ahl_wip_job_tbl(i+1).error := NULL;
        CLOSE get_job_attr;

        /* This is for creating job only, so load_type = 7
        --call EAM API to update manual_rebuild_flag because WICMLP can't change it.
        IF (x_ahl_wip_job_tbl(i+1).load_type = 8 AND x_ahl_wip_job_tbl(i+1).manual_rebuild_flag IS NOT NULL) THEN
          eam_workordertransactions_pub.set_manual_reb_flag(
              p_wip_entity_id => x_ahl_wip_job_tbl(i+1).wip_entity_id,
              p_organization_id => x_ahl_wip_job_tbl(i+1).organization_id,
              p_manual_rebuild_flag => x_ahl_wip_job_tbl(i+1).manual_rebuild_flag,
              x_return_status => l_return_status);
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_PRD_EAM_REBUILD_FLAG_FAIL');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;
        --call EAM API to update owning_department_id because WICMLP can't change it.
        IF (x_ahl_wip_job_tbl(i+1).load_type = 8 AND x_ahl_wip_job_tbl(i+1).owning_department IS NOT NULL) THEN
          eam_workordertransactions_pub.set_owning_department(
              p_wip_entity_id => x_ahl_wip_job_tbl(i+1).wip_entity_id,
              p_organization_id => x_ahl_wip_job_tbl(i+1).organization_id,
              p_owning_department => x_ahl_wip_job_tbl(i+1).owning_department,
              x_return_status => l_return_status);
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_PRD_EAM_OWN_DEPT_FAIL');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;
        */
      ELSE
        CLOSE get_job_attr;
        l_interface_ids(1) := l_get_job_attr.interface_id;
        j := 2;
        FOR l_get_interface_ids IN get_interface_ids(
          l_get_job_attr.group_id, l_get_job_attr.header_id) LOOP
          l_interface_ids(j) := l_get_interface_ids.interface_id ;
          j := j + 1;
        END LOOP;

        l_error_msg := '';
        FOR j IN l_interface_ids.FIRST..l_interface_ids.LAST LOOP
          FOR l_get_error_msg IN get_error_msg(l_interface_ids(j)) LOOP
            --l_error_msg := l_error_msg || replace(l_get_error_msg.error,chr(10)||chr(10),chr(10));
            --chr(10)='\n', chr(13)='\r', chr() function won't pass GSCC standard
            l_error_msg := l_error_msg || l_get_error_msg.error;
          END LOOP;
        END LOOP;
        x_ahl_wip_job_tbl(i+1).wip_entity_id := NULL;
        x_ahl_wip_job_tbl(i+1).error := l_error_msg;

        --Keep the failed records in interface tables in debug mode
        IF fnd_profile.value('MRP_DEBUG') <> 'Y' THEN
          FOR j IN l_interface_ids.FIRST..l_interface_ids.LAST LOOP
            DELETE FROM wip_interface_errors
            WHERE interface_id = l_interface_ids(j);
          END LOOP;

          DELETE FROM wip_job_dtls_interface
          WHERE group_id = l_get_job_attr.group_id
          AND parent_header_id = l_get_job_attr.header_id;

          DELETE FROM wip_job_schedule_interface
          WHERE group_id = l_get_job_attr.group_id
          AND header_id = l_get_job_attr.header_id;
        END IF;

        /*
        FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WICMLP_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR',l_error_msg);
        FND_MSG_PUB.ADD;
        */
        x_msg_count := 1;
        x_msg_data := l_error_msg;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('The concatenated error message is '||x_msg_data||' '||i);
        --dbms_output.put_line(substr('The concatenated error message is '||x_msg_data||' '||i, 1, 255));
        END IF;
      END IF;
    END LOOP;
  END IF;

  COMMIT; --Autonomous Transaction Required

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('End private API: AHL_WIP_JOB_PVT.LOAD_WIP_BATCH_JOBS');
    AHL_DEBUG_PUB.disable_debug;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.log_app_messages(x_msg_count, x_msg_data,
                                    'UNEXPECTED ERROR IN PRIVATE:' );
      AHL_DEBUG_PUB.debug('AHL_WIP_JOB_PVT.LOAD_WIP_BATCH_JOBS');
      AHL_DEBUG_PUB.disable_debug;
    END IF;
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.log_app_messages(x_msg_count, x_msg_data,
                                     'ERROR IN PRIVATE:' );
      AHL_DEBUG_PUB.debug('AHL_WIP_JOB_PVT.LOAD_WIP_BATCH_JOBS');
      AHL_DEBUG_PUB.disable_debug;
    END IF;
  WHEN OTHERS THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg(p_pkg_name       => 'AHL_WIP_JOB_PVT',
                              p_procedure_name => 'LOAD_WIP_BATCH_JOBS');
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data,
                                      'OTHER ERROR IN PRIVATE:' );
      AHL_DEBUG_PUB.debug('AHL_WIP_JOB_PVT.LOAD_WIP_BATCH_JOBS');
      AHL_DEBUG_PUB.disable_debug;
    END IF;

END load_wip_batch_jobs;

END AHL_WIP_JOB_PVT; -- Package Body

/
