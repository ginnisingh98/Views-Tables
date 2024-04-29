--------------------------------------------------------
--  DDL for Package Body AHL_PRD_WO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_WO_PUB" AS
/* $Header: AHLPWOSB.pls 120.0.12010000.6 2009/03/04 00:04:13 sikumar noship $ */

G_PKG_NAME   VARCHAR2(30)  := 'AHL_PRD_WO_PUB';

G_BPEL_USER_ROLE_KEY VARCHAR2(240);

FUNCTION init_user_and_role(p_user_id IN VARCHAR2) RETURN VARCHAR2 IS
PRAGMA AUTONOMOUS_TRANSACTION;

CURSOR get_user_id_csr(p_user_id IN VARCHAR2) IS
select user_id from fnd_user where user_name = p_user_id;

l_user_id NUMBER;
l_resp_id NUMBER;

CURSOR get_resp_id_csr IS
select responsibility_id from fnd_responsibility_vl where responsibility_key = G_BPEL_USER_ROLE_KEY;
BEGIN
   IF(p_user_id IS NOT NULL) THEN
    OPEN get_user_id_csr(p_user_id);
    FETCH get_user_id_csr INTO l_user_id;
    IF get_user_id_csr%NOTFOUND THEN
       FND_MESSAGE.set_name('AHL','AHL_PRD_INV_BPEL_USR');
       FND_MESSAGE.SET_TOKEN('USER_NAME',p_user_id);
       FND_MSG_PUB.ADD;
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE get_user_id_csr;

    FND_GLOBAL.apps_initialize(l_user_id,null,867);

    G_BPEL_USER_ROLE_KEY := FND_PROFILE.VALUE('AHL_BPEL_USER_ROLE');

    OPEN get_resp_id_csr;
    FETCH get_resp_id_csr INTO l_resp_id;
    CLOSE get_resp_id_csr;

    FND_GLOBAL.apps_initialize(l_user_id,l_resp_id,867);
    mo_global.init('AHL');

   END IF;
   COMMIT;
   return Fnd_Api.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK;
    return FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    ROLLBACK;
    return FND_API.G_RET_STS_UNEXP_ERROR;

END init_user_and_role;

FUNCTION get_workorder_id(p_WorkorderNumber IN VARCHAR2) RETURN NUMBER;

FUNCTION get_workorder_operation_id(p_WorkorderId IN NUMBER,p_operation_sequence IN NUMBER) RETURN NUMBER;

FUNCTION get_qa_sql_str(p_plan_id IN NUMBER) RETURN VARCHAR2;



PROCEDURE EXTRACT_SERIAL_NUMBER(p_reference IN OUT NOCOPY VARCHAR2,
                                x_serial_number OUT NOCOPY VARCHAR2);
FUNCTION IS_VALID_RESULT_ATTRIBUTE(p_CharId IN NUMBER, p_QA_PLAN IN QA_PLAN_REC_TYPE) RETURN VARCHAR2;

PROCEDURE get_workorder_details
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2,
 p_userid                IN            VARCHAR2   := NULL,
 p_WorkorderId           IN            NUMBER,
 p_WorkorderNumber       IN            VARCHAR2,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2,
 x_WO_DETAILS_REC        OUT NOCOPY WO_DETAILS_REC_TYPE
) IS

l_api_version      CONSTANT NUMBER := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'get_workorder_details';

CURSOR get_wo_details_csr(p_WorkorderId IN NUMBER)
IS SELECT WO.WORKORDER_ID,
       WO.OBJECT_VERSION_NUMBER,
       WO.JOB_NUMBER,
       WO.JOB_DESCRIPTION,
       WO.ORGANIZATION_NAME,
       WO.DEPARTMENT_NAME,
       WO.JOB_STATUS_CODE,
       WO.JOB_STATUS_MEANING,
       WO.PRIORITY_MEANING,
       WO.SCHEDULED_START_DATE,
       WO.SCHEDULED_END_DATE,
       WO.ACTUAL_START_DATE,
       WO.ACTUAL_END_DATE,
       WO.UNIT_NAME,
       WO.WO_PART_NUMBER,
       WO.SERIAL_NUMBER,
       WO.VISIT_ID,
       WO.VISIT_NUMBER,
       WO.VISIT_NAME,
       WO.VISIT_TASK_ID,
       WO.VISIT_STATUS_CODE,
       AMH.MR_HEADER_ID,
       WO.VISIT_TASK_NUMBER,
       AMH.TITLE MR_TITLE,
       WO.MR_ROUTE_ID,
       WO.ROUTE_ID,
       AR.ROUTE_NO ROUTE_TITLE,
       AR.ROUTE_NO ROUTE_NUMBER,
       PAA.NAME PROJECT_NAME,
       PAT.TASK_NAME PROJECT_TASK_NAME,
       WO.UNIT_EFFECTIVITY_ID,
       WO.LOT_NUMBER,
       WO.UC_HEADER_ID,
       WO.UNIT_QUARANTINE_FLAG,
       WO.ORGANIZATION_ID,
       WO.DEPARTMENT_ID,
       WOS.PLAN_ID,
       VST.start_date_time,
       VST.close_date_time,
       VTS.service_request_id,
       VTS.service_request_id service_request_number,
       WO.HOLD_REASON_CODE,
       WO.HOLD_REASON
FROM AHL_WORKORDER_TASKS_V WO, PA_PROJECTS_ALL PAA, PA_TASKS PAT,
AHL_MR_ROUTES AMR, AHL_MR_HEADERS_B AMH, AHL_ROUTES_B AR, AHL_VISIT_TASKS_B VTS,
AHL_VISITS_B VST,AHL_WORKORDERS WOS
WHERE WO.VISIT_TASK_ID=VTS.VISIT_TASK_ID
AND WO.VISIT_ID=VST.VISIT_ID
AND WO.MR_ROUTE_ID=AMR.MR_ROUTE_ID (+)
AND AMR.MR_HEADER_ID=AMH.MR_HEADER_ID(+)
AND WO.ROUTE_ID=AR.ROUTE_ID (+)
AND VST.PROJECT_ID=PAA.PROJECT_ID (+)
AND VTS.PROJECT_TASK_ID=PAT.TASK_ID (+)
AND WO.WORKORDER_ID = WOS.workorder_id
AND WO.WORKORDER_ID = p_WorkorderId;

l_wo_details get_wo_details_csr%ROWTYPE;
l_workorder_id NUMBER;
l_model                VARCHAR2(30) := 'Model' ;
l_ata_code             VARCHAR2(30) := 'ATA';
l_tail_number          VARCHAR2(30);
l_user_name            VARCHAR2(40);
l_user_lang            VARCHAR2(40);
l_doc_id               VARCHAR2(80) :='docid';


BEGIN
   x_return_status := init_user_and_role(p_userid);
   IF(x_return_status <> Fnd_Api.G_RET_STS_SUCCESS)THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version,l_api_name, G_PKG_NAME ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
   END IF;




   IF(p_WorkorderId IS NULL AND p_WorkorderNumber IS NULL)THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WO_NOT_FOUND');
      FND_MSG_PUB.ADD;
      RAISE  FND_API.G_EXC_ERROR;
   ELSIF (p_WorkorderId IS NULL AND p_WorkorderNumber IS NOT NULL)THEN
      l_workorder_id := get_workorder_id(p_WorkorderNumber);
   ELSE
      l_workorder_id := p_WorkorderId;
   END IF;


   OPEN get_wo_details_csr(l_workorder_id);
   FETCH get_wo_details_csr INTO l_wo_details;
   IF(get_wo_details_csr%NOTFOUND)THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WO_NOT_FOUND');
      FND_MSG_PUB.ADD;
      CLOSE get_wo_details_csr;
      RAISE  FND_API.G_EXC_ERROR;
   ELSE
      x_WO_DETAILS_REC.WorkorderId := l_wo_details.WORKORDER_ID;
      x_WO_DETAILS_REC.ObjectVersionNumber := l_wo_details.OBJECT_VERSION_NUMBER;
      x_WO_DETAILS_REC.WorkorderNumber :=  l_wo_details.JOB_NUMBER;
      x_WO_DETAILS_REC.Description := l_wo_details.JOB_DESCRIPTION;
      x_WO_DETAILS_REC.StatusCode := l_wo_details.JOB_STATUS_CODE;
      x_WO_DETAILS_REC.Status := l_wo_details.JOB_STATUS_MEANING;
      x_WO_DETAILS_REC.Priority := l_wo_details.PRIORITY_MEANING;
      x_WO_DETAILS_REC.OrganizationId := l_wo_details.ORGANIZATION_ID;
      x_WO_DETAILS_REC.OrganizationName := l_wo_details.ORGANIZATION_NAME;
      x_WO_DETAILS_REC.DepartmentId := l_wo_details.DEPARTMENT_ID;
      x_WO_DETAILS_REC.DepartmentName := l_wo_details.DEPARTMENT_NAME;
      x_WO_DETAILS_REC.ScheduledStartDate := l_wo_details.SCHEDULED_START_DATE;
      x_WO_DETAILS_REC.ScheduledEndDate := l_wo_details.SCHEDULED_END_DATE;
      x_WO_DETAILS_REC.ActualStartDate := l_wo_details.ACTUAL_START_DATE;
      x_WO_DETAILS_REC.ActualEndDate := l_wo_details.ACTUAL_END_DATE;
      x_WO_DETAILS_REC.UnitHeaderId := l_wo_details.UC_HEADER_ID;
      x_WO_DETAILS_REC.UnitName := l_wo_details.UNIT_NAME;
      x_WO_DETAILS_REC.WorkorderItemNumber := l_wo_details.WO_PART_NUMBER;
      x_WO_DETAILS_REC.SerialNumber := l_wo_details.SERIAL_NUMBER;
      x_WO_DETAILS_REC.LotNumber := l_wo_details.LOT_NUMBER;
      x_WO_DETAILS_REC.VisitId := l_wo_details.VISIT_ID;
      x_WO_DETAILS_REC.VisitNumber := l_wo_details.VISIT_NUMBER;
      x_WO_DETAILS_REC.VisitTaskId := l_wo_details.VISIT_TASK_ID;
      x_WO_DETAILS_REC.VisitTaskNumber := l_wo_details.VISIT_TASK_NUMBER;
      x_WO_DETAILS_REC.VisitStatusCode := l_wo_details.VISIT_STATUS_CODE;
      x_WO_DETAILS_REC.VisitStartDate := l_wo_details.start_date_time;
      x_WO_DETAILS_REC.VisitEndDate := l_wo_details.close_date_time;
      AHL_ENIGMA_UTIL_PKG.get_enigma_url_params
        (
            p_object_type  => 'WO',
            p_primary_object_id   => l_wo_details.WORKORDER_ID,
            p_secondary_object_id => l_wo_details.WORKORDER_ID,
		    x_model			 => l_model,
			x_ata_code       => l_ata_code,
			x_tail_number    => l_tail_number,
			x_user_name      => l_user_name,
			x_user_lang      => l_user_lang,
			x_doc_id         => l_doc_id
      );
      x_WO_DETAILS_REC.EnigmaDocumentID := l_doc_id;
      x_WO_DETAILS_REC.EnigmaDocumentTitle := l_tail_number;
      x_WO_DETAILS_REC.ATACode := l_ata_code;
      x_WO_DETAILS_REC.Model := l_model;
      x_WO_DETAILS_REC.RoutePublishingDate := SYSDATE;
      x_WO_DETAILS_REC.MrHeaderId := l_wo_details.MR_HEADER_ID;
      x_WO_DETAILS_REC.MrTitle := l_wo_details.MR_TITLE;
      x_WO_DETAILS_REC.MrRouteId := l_wo_details.MR_ROUTE_ID;
      x_WO_DETAILS_REC.RouteId := l_wo_details.ROUTE_ID;
      x_WO_DETAILS_REC.RouteTitle := l_wo_details.ROUTE_TITLE;
      x_WO_DETAILS_REC.RouteNumber := l_wo_details.ROUTE_NUMBER;
      x_WO_DETAILS_REC.ProjectName := l_wo_details.PROJECT_NAME;
      x_WO_DETAILS_REC.ProjectTaskName := l_wo_details.PROJECT_TASK_NAME;
      x_WO_DETAILS_REC.UnitEffectivityId := l_wo_details.UNIT_EFFECTIVITY_ID;
      x_WO_DETAILS_REC.NonRoutineId := l_wo_details.service_request_id;
      x_WO_DETAILS_REC.NonRoutineNumber := to_char(l_wo_details.service_request_number);
      x_WO_DETAILS_REC.HoldReasonCode := l_wo_details.HOLD_REASON_CODE;
      x_WO_DETAILS_REC.HoldReason := l_wo_details.HOLD_REASON;
      x_WO_DETAILS_REC.IsUnitQuarantined := l_wo_details.UNIT_QUARANTINE_FLAG;
      x_WO_DETAILS_REC.IsCompleteEnabled := AHL_COMPLETIONS_PVT.Is_Complete_Enabled(l_wo_details.WORKORDER_ID, NULL, NULL, 'T');
      FND_MSG_PUB.Initialize;
      x_WO_DETAILS_REC.IsPartsChangeEnabled := AHL_PRD_UTIL_PKG.Is_PartChange_Enabled(l_wo_details.WORKORDER_ID,'T');
      FND_MSG_PUB.Initialize;

      IF(x_WO_DETAILS_REC.StatusCode NOT IN ('22','7','12','1','7','4','5') AND x_WO_DETAILS_REC.IsUnitQuarantined = 'F')THEN
        x_WO_DETAILS_REC.IsNonRoutineCreationEnabled := 'T';
      ELSE
        x_WO_DETAILS_REC.IsNonRoutineCreationEnabled := 'F';
      END IF;
      IF(x_WO_DETAILS_REC.IsUnitQuarantined = 'T' OR x_WO_DETAILS_REC.StatusCode IN ('22','7','12','1','7'))THEN
        x_WO_DETAILS_REC.IsUpdateEnabled := 'F';
      ELSE
        x_WO_DETAILS_REC.IsUpdateEnabled := 'T';
      END IF;
      x_WO_DETAILS_REC.IsResTxnEnabled := AHL_PRD_UTIL_PKG.Is_ResTxn_Allowed(l_wo_details.WORKORDER_ID,'T');
      FND_MSG_PUB.Initialize;
      IF(l_wo_details.PLAN_ID IS NULL)THEN
        x_WO_DETAILS_REC.IsQualityEnabled := 'N';
      /*ELSIF(x_WO_DETAILS_REC.StatusCode IN ('22','7','12','1','7','4','5') OR x_WO_DETAILS_REC.IsUnitQuarantined = 'T')THEN
        x_WO_DETAILS_REC.IsQualityEnabled := 'F';*/
      ELSE
        x_WO_DETAILS_REC.IsQualityEnabled := 'T';
      END IF;
   END IF;
   CLOSE get_wo_details_csr;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := FND_MSG_PUB.count_msg;


   x_msg_data := GET_MSG_DATA(x_msg_count);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count := FND_MSG_PUB.count_msg;
   x_msg_data := GET_MSG_DATA(x_msg_count);
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
     x_msg_count := FND_MSG_PUB.count_msg;
     x_msg_data := GET_MSG_DATA(x_msg_count);
END get_workorder_details;

PROCEDURE get_wo_operations_details
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2,
 p_userid                IN            VARCHAR2   := NULL,
 p_WorkorderId           IN            NUMBER,
 p_WorkorderNumber       IN            VARCHAR2,
 p_WoOperationId         IN            NUMBER,
 p_OperationSequence     IN            NUMBER,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2,
 x_Operations            OUT NOCOPY    OP_TBL_TYPE
) IS

l_api_version      CONSTANT NUMBER := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'get_wo_operations_details';

CURSOR get_operations_details_csr(p_WorkorderId IN NUMBER, p_WoOperationId IN NUMBER) IS
SELECT WORKORDER_OPERATION_ID,OBJECT_VERSION_NUMBER,  OPERATION_SEQUENCE_NUM,DESCRIPTION,
       WORKORDER_ID, DEPARTMENT_ID,
       DEPARTMENT_NAME,  OPERATION_ID,  OPERATION_CODE,  OPERATION_TYPE_CODE,
       OPERATION_TYPE,  STATUS_CODE, STATUS,
        SCHEDULED_START_DATE,  SCHEDULED_END_DATE,
        ACTUAL_START_DATE, ACTUAL_END_DATE, PLAN_ID
FROM AHL_WORKORDER_OPERATIONS_V
WHERE  WORKORDER_ID = p_WorkorderId
AND WORKORDER_OPERATION_ID = NVL(p_WoOperationId, WORKORDER_OPERATION_ID)
ORDER BY OPERATION_SEQUENCE_NUM;

l_workorder_id NUMBER;
l_workorder_operation_id NUMBER;
l_op_index NUMBER;

BEGIN

   x_return_status := init_user_and_role(p_userid);
   IF(x_return_status <> Fnd_Api.G_RET_STS_SUCCESS)THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   x_Operations(0) := NULL;
-- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version,l_api_name, G_PKG_NAME ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
   END IF;
  -- Check Error Message stack.
  IF(p_WorkorderId IS NULL AND p_WorkorderNumber IS NULL)THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WO_NOT_FOUND');
      FND_MSG_PUB.ADD;
      RAISE  FND_API.G_EXC_ERROR;
   ELSIF (p_WorkorderId IS NULL AND p_WorkorderNumber IS NOT NULL)THEN
      l_workorder_id := get_workorder_id(p_WorkorderNumber);
   ELSE
      l_workorder_id := p_WorkorderId;
   END IF;

   x_msg_count := FND_MSG_PUB.count_msg;
   IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
   END IF;

   IF(p_WoOperationId IS NULL AND p_OperationSequence IS NULL)THEN
      NULL;
   ELSIF (p_WoOperationId IS NULL AND p_OperationSequence IS NOT NULL)THEN
      l_workorder_operation_id := get_workorder_operation_id(l_workorder_id, p_OperationSequence);
   ELSE
      l_workorder_operation_id := p_WoOperationId;
   END IF;

   x_msg_count := FND_MSG_PUB.count_msg;
   IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
   END IF;

   l_op_index :=0;
   FOR op_details IN get_operations_details_csr(l_workorder_id,l_workorder_operation_id) LOOP
    x_Operations(l_op_index).WorkorderOperationId := op_details.WORKORDER_OPERATION_ID;
    x_Operations(l_op_index).ObjectVersionNumber := op_details.OBJECT_VERSION_NUMBER;
    x_Operations(l_op_index).OperationSequenceNumber := op_details.OPERATION_SEQUENCE_NUM;
    x_Operations(l_op_index).WorkorderId := op_details.WORKORDER_ID;
    x_Operations(l_op_index).OperationCode := op_details.OPERATION_CODE;
    x_Operations(l_op_index).Description := op_details.DESCRIPTION;
    x_Operations(l_op_index).StatusCode := op_details.STATUS_CODE;
    x_Operations(l_op_index).Status := op_details.STATUS;
    x_Operations(l_op_index).OperationTypeCode := op_details.OPERATION_TYPE_CODE;
    x_Operations(l_op_index).OperationType := op_details.OPERATION_TYPE;
    x_Operations(l_op_index).DepartmentId := op_details.DEPARTMENT_ID;
    x_Operations(l_op_index).DepartmentName := op_details.DEPARTMENT_NAME;
    x_Operations(l_op_index).ScheduledStartDate := op_details.SCHEDULED_START_DATE;
    x_Operations(l_op_index).ScheduledEndDate := op_details.SCHEDULED_END_DATE;
    x_Operations(l_op_index).ActualStartDate := op_details.ACTUAL_START_DATE;
    x_Operations(l_op_index).ActualEndDate := op_details.ACTUAL_END_DATE;
    x_Operations(l_op_index).IsUpdateEnabled := AHL_PRD_UTIL_PKG.Is_Op_Updatable(op_details.WORKORDER_ID, op_details.OPERATION_SEQUENCE_NUM);

    x_Operations(l_op_index).IsQualityEnabled := 'N' ;
    IF(op_details.PLAN_ID IS NULL ) THEN
      x_Operations(l_op_index).IsQualityEnabled := 'N' ;
    ELSIF(op_details.PLAN_ID IS NOT NULL AND x_Operations(l_op_index).IsUpdateEnabled = 'T')THEN
       x_Operations(l_op_index).IsQualityEnabled := 'T' ;
    ELSIF(op_details.PLAN_ID IS NOT NULL AND x_Operations(l_op_index).IsUpdateEnabled = 'F')THEN
       x_Operations(l_op_index).IsQualityEnabled := 'F' ;
    END IF;
    l_op_index := l_op_index + 1;
   END LOOP;

  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := FND_MSG_PUB.count_msg;


   x_msg_data := GET_MSG_DATA(x_msg_count);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count := FND_MSG_PUB.count_msg;
   x_msg_data := GET_MSG_DATA(x_msg_count);
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
     x_msg_count := FND_MSG_PUB.count_msg;
     x_msg_data := GET_MSG_DATA(x_msg_count);
END get_wo_operations_details;

PROCEDURE get_wo_mtl_reqmts
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2,
 p_userid                IN            VARCHAR2   := NULL,
 p_WorkorderId           IN            NUMBER,
 p_WorkorderNumber       IN            VARCHAR2,
 p_WoOperationId         IN            NUMBER,
 p_OperationSequence     IN            NUMBER,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2,
 x_MaterialRequirementDetails  OUT NOCOPY MTL_REQMTS_TBL_TYPE
) IS

l_api_version      CONSTANT NUMBER := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'get_wo_mtl_reqmts';

CURSOR get_wo_mtl_reqmts_csr(p_WorkorderId IN NUMBER, p_WoOperationId IN NUMBER) IS
SELECT ASML.operation_sequence,  MSIK.concatenated_segments part_number,MSIK.description Part_Desc, MSIK.primary_unit_of_measure part_uom  ,
WIRO.REQUIRED_QUANTITY required_quantity , WIRO.DATE_REQUIRED required_date,
asml.scheduled_quantity schedule_quantity,asml.scheduled_date schedule_date,
 nvl(ahl_pp_materials_pvt.get_issued_qty(msik.organization_id, asml.inventory_item_id, asml.workorder_operation_id), 0) issued_quantity,
 AWOS.workorder_id,
asml.inventory_item_id,
ASML.organization_id,
ASML.scheduled_material_id
from ahl_workorders AWOS, ahl_schedule_materials ASML, WIP_REQUIREMENT_OPERATIONS WIRO, mtl_system_items_kfv MSIK
WHERE AWOS.visit_task_id = ASML.visit_task_id
and ASML.inventory_item_id = MSIK.inventory_item_id
and ASML.organization_id = MSIK.organization_id
AND AWOS.WIP_ENTITY_ID = WIRO.WIP_ENTITY_ID
AND ASML.OPERATION_SEQUENCE = WIRO.OPERATION_SEQ_NUM
AND ASML.INVENTORY_ITEM_ID = WIRO.INVENTORY_ITEM_ID
AND ASML.ORGANIZATION_ID = WIRO.ORGANIZATION_ID and asml.status = 'ACTIVE'
AND AWOS.WORKORDER_ID = p_WorkorderId
AND ASML.WORKORDER_OPERATION_ID = NVL(p_WoOperationId,ASML.WORKORDER_OPERATION_ID);

l_workorder_id NUMBER;
l_workorder_operation_id NUMBER;
l_mtl_index NUMBER;

BEGIN

   x_return_status := init_user_and_role(p_userid);
   IF(x_return_status <> Fnd_Api.G_RET_STS_SUCCESS)THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   x_MaterialRequirementDetails(0) := NULL;

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version,l_api_name, G_PKG_NAME ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
   END IF;

   -- Check Error Message stack.
  IF(p_WorkorderId IS NULL AND p_WorkorderNumber IS NULL)THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WO_NOT_FOUND');
      FND_MSG_PUB.ADD;
      RAISE  FND_API.G_EXC_ERROR;
   ELSIF (p_WorkorderId IS NULL AND p_WorkorderNumber IS NOT NULL)THEN
      l_workorder_id := get_workorder_id(p_WorkorderNumber);
   ELSE
      l_workorder_id := p_WorkorderId;
   END IF;

   IF(p_WoOperationId IS NULL AND p_OperationSequence IS NULL)THEN
      NULL;
   ELSIF (p_WoOperationId IS NULL AND p_OperationSequence IS NOT NULL)THEN
      l_workorder_operation_id := get_workorder_operation_id(l_workorder_id, p_OperationSequence);
   ELSE
      l_workorder_operation_id := p_WoOperationId;
   END IF;

   x_msg_count := FND_MSG_PUB.count_msg;
   IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
   END IF;

   l_mtl_index :=0;
   FOR mtl_details IN get_wo_mtl_reqmts_csr(l_workorder_id,l_workorder_operation_id) LOOP
    x_MaterialRequirementDetails(l_mtl_index).ScheduledMaterialId := mtl_details.scheduled_material_id;
    x_MaterialRequirementDetails(l_mtl_index).WorkorderId := mtl_details.workorder_id;
    x_MaterialRequirementDetails(l_mtl_index).OperationSequenceNumber := mtl_details.operation_sequence;
    x_MaterialRequirementDetails(l_mtl_index).InventoryItemId := mtl_details.inventory_item_id;
    x_MaterialRequirementDetails(l_mtl_index).ItemNumber := mtl_details.part_number;
    x_MaterialRequirementDetails(l_mtl_index).ItemDescription := mtl_details.Part_Desc;
    x_MaterialRequirementDetails(l_mtl_index).RequiredQuantity := mtl_details.required_quantity;--mtl_details.schedule_quantity;
    x_MaterialRequirementDetails(l_mtl_index).PartUOM := mtl_details.part_uom;
    x_MaterialRequirementDetails(l_mtl_index).RequiredDate := mtl_details.required_date;
    x_MaterialRequirementDetails(l_mtl_index).ScheduledQuantity := mtl_details.required_quantity;
    x_MaterialRequirementDetails(l_mtl_index).ScheduledDate := mtl_details.schedule_date;
    x_MaterialRequirementDetails(l_mtl_index).IssuedQuantity := mtl_details.issued_quantity;
    l_mtl_index := l_mtl_index + 1;
   END LOOP;

 -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := FND_MSG_PUB.count_msg;


   x_msg_data := GET_MSG_DATA(x_msg_count);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count := FND_MSG_PUB.count_msg;
   x_msg_data := GET_MSG_DATA(x_msg_count);
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
     x_msg_count := FND_MSG_PUB.count_msg;
     x_msg_data := GET_MSG_DATA(x_msg_count);
END get_wo_mtl_reqmts;

PROCEDURE get_wo_assoc_documents
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2,
 p_userid                IN            VARCHAR2   := NULL,
 p_WorkorderId           IN            NUMBER,
 p_WorkorderNumber       IN            VARCHAR2,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2,
 x_AssociatedDocuments   OUT NOCOPY ASSOC_DOCS_TBL_TYPE
) IS

l_api_version      CONSTANT NUMBER := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'get_wo_assoc_documents';
l_workorder_id NUMBER;
l_doc_index NUMBER;

CURSOR get_wo_assoc_documents_csr(p_WorkorderId IN NUMBER)IS
SELECT DISTINCT
	  DOC.DOCUMENT_NO,	  DOC.DOCUMENT_TITLE,	  DOC.ASO_OBJECT_TYPE_DESC,	  DOC.REVISION_NO,
	  DOC.CHAPTER,	  DOC.SECTION,	  DOC.SUBJECT,	  DOC.PAGE,	  DOC.FIGURE,	  DOC.NOTE
	FROM
	  AHL_WORKORDERS WO,	  ahl_reference_doc_v DOC,	  AHL_DOC_REVISIONS_B REV
	WHERE
	  WO.ROUTE_ID = DOC.ASO_OBJECT_ID
	  AND WO.WORKORDER_ID = p_WorkorderId
	  AND DOC.ASO_OBJECT_TYPE_CODE = 'ROUTE'
	  AND REV.DOCUMENT_ID(+) = DOC.DOCUMENT_ID
	  AND TRUNC(NVL(REV.OBSOLETE_DATE, SYSDATE + 1)) > TRUNC(SYSDATE)
	UNION ALL
	-- OPERATION DOC ASSOCIATIONS
	SELECT
	  DOC.DOCUMENT_NO,	  DOC.DOCUMENT_TITLE,  	  DOC.ASO_OBJECT_TYPE_DESC,	  DOC.REVISION_NO,
	  DOC.CHAPTER,	  DOC.SECTION,	  DOC.SUBJECT,	  DOC.PAGE,	  DOC.FIGURE,	  DOC.NOTE
	FROM
	  AHL_WORKORDER_OPERATIONS WOP,	  ahl_reference_doc_v DOC,		  AHL_DOC_REVISIONS_B REV
	WHERE
	  WOP.OPERATION_ID = DOC.ASO_OBJECT_ID
	  AND WOP.WORKORDER_ID = p_WorkorderId
 	  AND DOC.ASO_OBJECT_TYPE_CODE = 'OPERATION'
	  AND REV.DOCUMENT_ID(+) = DOC.DOCUMENT_ID
	  AND TRUNC(NVL(REV.OBSOLETE_DATE, SYSDATE + 1)) > TRUNC(SYSDATE)
	UNION ALL
	-- MR DOCUMENT ASSOCIATIONS
	SELECT DISTINCT
	  DOC.DOCUMENT_NO,	  DOC.DOCUMENT_TITLE,	  DOC.ASO_OBJECT_TYPE_DESC,		  DOC.REVISION_NO,
	  DOC.CHAPTER,	  DOC.SECTION,	  DOC.SUBJECT,	  DOC.PAGE,	  DOC.FIGURE,	  DOC.NOTE
	FROM
	  AHL_WORKORDERS WO,	  AHL_VISIT_TASKS_B VST,	  ahl_reference_doc_v DOC,		  AHL_DOC_REVISIONS_B REV
	WHERE
	  WO.VISIT_TASK_ID = VST.VISIT_TASK_ID
	  AND WO.WORKORDER_ID = p_WorkorderId
	  AND VST.MR_ID = DOC.ASO_OBJECT_ID
 	  AND DOC.ASO_OBJECT_TYPE_CODE = 'MR'
  	  AND REV.DOCUMENT_ID(+) = DOC.DOCUMENT_ID
	  AND TRUNC(NVL(REV.OBSOLETE_DATE, SYSDATE + 1)) > TRUNC(SYSDATE)
	UNION ALL
	-- MC DOCUMENT ASSOCIATIONS
	SELECT DISTINCT
	  DOC.DOCUMENT_NO,	  DOC.DOCUMENT_TITLE,	  DOC.ASO_OBJECT_TYPE_DESC,		  DOC.REVISION_NO,
	  DOC.CHAPTER,	  DOC.SECTION,	  DOC.SUBJECT,	  DOC.PAGE,	  DOC.FIGURE,	  DOC.NOTE
	FROM
	  AHL_WORKORDERS WO,	  CSI_II_RELATIONSHIPS CSI,	  AHL_VISIT_TASKS_B VTS,
	  ahl_reference_doc_v DOC,		  AHL_DOC_REVISIONS_B REV
	WHERE
	  WO.VISIT_TASK_ID = VTS.VISIT_TASK_ID
	  AND WO.WORKORDER_ID = p_WorkorderId
	  AND VTS.INSTANCE_ID = CSI.SUBJECT_ID
	  AND CSI.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
	  AND (SYSDATE BETWEEN NVL(CSI.ACTIVE_START_DATE, SYSDATE) AND NVL(CSI.ACTIVE_END_DATE, SYSDATE))
	  AND TO_NUMBER(CSI.POSITION_REFERENCE) = DOC.ASO_OBJECT_ID
 	  AND DOC.ASO_OBJECT_TYPE_CODE = 'MC'
  	  AND REV.DOCUMENT_ID(+) = DOC.DOCUMENT_ID
	  AND TRUNC(NVL(REV.OBSOLETE_DATE, SYSDATE + 1)) > TRUNC(SYSDATE)
	UNION ALL
	-- PC DOC ASSOCIATIONS
	SELECT DISTINCT
	  DOC.DOCUMENT_NO,	  DOC.DOCUMENT_TITLE,	  DOC.ASO_OBJECT_TYPE_DESC,		  DOC.REVISION_NO,
	  DOC.CHAPTER,	  DOC.SECTION,	  DOC.SUBJECT,  DOC.PAGE,	  DOC.FIGURE,	  DOC.NOTE
	FROM
	  AHL_WORKORDERS WO,	  AHL_PC_ASSOCIATIONS PCA,	  AHL_VISIT_TASKS_B VTS,
	  ahl_reference_doc_v DOC,		  AHL_DOC_REVISIONS_B REV
	WHERE
	  WO.VISIT_TASK_ID=VTS.VISIT_TASK_ID
	  AND WO.WORKORDER_ID = p_WorkorderId
	  AND AHL_UTIL_UC_PKG.GET_UC_HEADER_ID(VTS.INSTANCE_ID) = PCA.UNIT_ITEM_ID
	  AND PCA.PC_NODE_ID = DOC.ASO_OBJECT_ID
 	  AND DOC.ASO_OBJECT_TYPE_CODE = 'PC'
  	  AND REV.DOCUMENT_ID(+) = DOC.DOCUMENT_ID
	  AND TRUNC(NVL(REV.OBSOLETE_DATE, SYSDATE + 1)) > TRUNC(SYSDATE);

BEGIN

   x_return_status := init_user_and_role(p_userid);
   IF(x_return_status <> Fnd_Api.G_RET_STS_SUCCESS)THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   x_AssociatedDocuments(0) := NULL;

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version,l_api_name, G_PKG_NAME ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
   END IF;

   -- Check Error Message stack.
   IF(p_WorkorderId IS NULL AND p_WorkorderNumber IS NULL)THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WO_NOT_FOUND');
      FND_MSG_PUB.ADD;
      RAISE  FND_API.G_EXC_ERROR;
   ELSIF (p_WorkorderId IS NULL AND p_WorkorderNumber IS NOT NULL)THEN
      l_workorder_id := get_workorder_id(p_WorkorderNumber);
   ELSE
      l_workorder_id := p_WorkorderId;
   END IF;

   x_msg_count := FND_MSG_PUB.count_msg;
   IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
   END IF;

   l_doc_index := 0;
   FOR assoc_docs IN get_wo_assoc_documents_csr(l_workorder_id ) LOOP
    x_AssociatedDocuments(l_doc_index).DocumentNumber := assoc_docs.DOCUMENT_NO;
    x_AssociatedDocuments(l_doc_index).DocumentTitle := assoc_docs.DOCUMENT_TITLE;
    x_AssociatedDocuments(l_doc_index).AsoObjectTypeDesc := assoc_docs.ASO_OBJECT_TYPE_DESC;
    x_AssociatedDocuments(l_doc_index).RevisionNumber := assoc_docs.REVISION_NO;
    x_AssociatedDocuments(l_doc_index).Chapter := assoc_docs.CHAPTER;
    x_AssociatedDocuments(l_doc_index).Section := assoc_docs.SECTION;
    x_AssociatedDocuments(l_doc_index).Subject := assoc_docs.SUBJECT;
    x_AssociatedDocuments(l_doc_index).Page := assoc_docs.PAGE;
    x_AssociatedDocuments(l_doc_index).Figure := assoc_docs.FIGURE;
    x_AssociatedDocuments(l_doc_index).Note := assoc_docs.NOTE;
    l_doc_index := l_doc_index +1;
   END LOOP;

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
   END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := FND_MSG_PUB.count_msg;


   x_msg_data := GET_MSG_DATA(x_msg_count);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count := FND_MSG_PUB.count_msg;
   x_msg_data := GET_MSG_DATA(x_msg_count);
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
     x_msg_count := FND_MSG_PUB.count_msg;
     x_msg_data := GET_MSG_DATA(x_msg_count);
END get_wo_assoc_documents;

PROCEDURE get_wo_turnover_notes
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2,
 p_userid                IN            VARCHAR2   := NULL,
 p_WorkorderId           IN            NUMBER,
 p_WorkorderNumber       IN            VARCHAR2,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2,
 x_TurnoverNotes         OUT NOCOPY TURNOVER_NOTES_TBL_TYPE
) IS

l_api_version      CONSTANT NUMBER := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'get_wo_turnover_notes';
l_notes_index      NUMBER;
l_workorder_id NUMBER;

CURSOR get_wo_turnover_notes_csr(p_WorkorderId IN NUMBER) IS
Select jtf_note_id,
source_object_id,
source_object_code,
entered_date,
fu.employee_id entered_by,
(Select DISTINCT PF.full_name from mtl_employees_current_view PF where pf.employee_id =fu.employee_id)  entered_by_name,
notes note
from jtf_notes_vl JTF,fnd_user fu
where source_object_code = 'AHL_WO_TURNOVER_NOTES'
and fu.user_id = JTF.entered_by
and source_object_id = p_WorkorderId ORDER BY entered_date DESC;

BEGIN

   x_return_status := init_user_and_role(p_userid);
   IF(x_return_status <> Fnd_Api.G_RET_STS_SUCCESS)THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   x_TurnoverNotes(0) := NULL;

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version,l_api_name, G_PKG_NAME ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
   END IF;

   -- Check Error Message stack.
   IF(p_WorkorderId IS NULL AND p_WorkorderNumber IS NULL)THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WO_NOT_FOUND');
      FND_MSG_PUB.ADD;
      RAISE  FND_API.G_EXC_ERROR;
   ELSIF (p_WorkorderId IS NULL AND p_WorkorderNumber IS NOT NULL)THEN
      l_workorder_id := get_workorder_id(p_WorkorderNumber);
   ELSE
      l_workorder_id := p_WorkorderId;
   END IF;

   x_msg_count := FND_MSG_PUB.count_msg;
   IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
   END IF;

   l_notes_index := 0;
   FOR notes IN get_wo_turnover_notes_csr(l_workorder_id ) LOOP
    x_TurnoverNotes(l_notes_index).JtfNoteId := notes.jtf_note_id ;
    x_TurnoverNotes(l_notes_index).SourceObjectId := notes.source_object_id ;
    x_TurnoverNotes(l_notes_index).SourceObjectCode := notes.source_object_code ;
    x_TurnoverNotes(l_notes_index).EnteredDate := notes.entered_date ;
    x_TurnoverNotes(l_notes_index).EnteredBy := notes.entered_by ;
    x_TurnoverNotes(l_notes_index).EnteredByName := notes.entered_by_name ;
    x_TurnoverNotes(l_notes_index).Notes := notes.note ;
    l_notes_index := l_notes_index +1;
   END LOOP;

 -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := FND_MSG_PUB.count_msg;


   x_msg_data := GET_MSG_DATA(x_msg_count);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count := FND_MSG_PUB.count_msg;
   x_msg_data := GET_MSG_DATA(x_msg_count);
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
     x_msg_count := FND_MSG_PUB.count_msg;
     x_msg_data := GET_MSG_DATA(x_msg_count);
END get_wo_turnover_notes;

PROCEDURE get_wo_res_txns
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2,
 p_userid                IN            VARCHAR2   := NULL,
 p_WorkorderId           IN            NUMBER,
 p_WorkorderNumber       IN            VARCHAR2,
 p_WoOperationId         IN            NUMBER,
 p_OperationSequence     IN            NUMBER,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2,
 x_DefaultResourceTransactions OUT NOCOPY RES_TXNS_TBL_TYPE,
 x_ResourceTransactions        OUT NOCOPY RES_TXNS_TBL_TYPE
) IS
l_api_version      CONSTANT NUMBER := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'get_wo_res_txns';
l_restxns_index      NUMBER;
l_workorder_id NUMBER;
l_operation_sequence NUMBER;

CURSOR get_wo_res_txns_csr(p_WorkorderId IN NUMBER, p_OperationSequence IN NUMBER) IS
SELECT WIP.TRANSACTION_ID,       WIP.WORKORDER_ID,       WIP.JOB_NUMBER,
       WIP.OPERATION_SEQ_NUM,       WIP.RESOURCE_SEQ_NUM,      WIP.EMPLOYEE_ID,       WIP.EMPLOYEE_NUMBER,
       WIP.FULL_NAME,       WIP.RESOURCE_CODE,       WIP.DESCRIPTION,       WIP.RESOURCE_ID,       WIP.DEPARTMENT_ID,
       WIP.DEPT_DESCRIPTION,       WIP.QUANTITY,       WIP.USAGE_RATE_OR_AMOUNT,       WIP.PRIMARY_UOM,
       WIP.UOM_MEANING,       WIP.ACTIVITY_ID,       WIP.ACTIVITY,       WIP.REASON_ID,       WIP.REASON_NAME,
       WIP.REFERENCE,       WIP.TRANSACTION_DATE,
       WIP.TRANSACTION_STATUS,   MFGL.MEANING RESOURCE_TYPE,
       BR.RESOURCE_TYPE RESOURCE_TYPE_CODE, NULL SERIAL_NUMBER
FROM AHL_WIP_RESOURCE_TXNS_V WIP,BOM_RESOURCES BR, MFG_LOOKUPS MFGL
WHERE WORKORDER_ID = p_WorkorderId
AND OPERATION_SEQ_NUM = NVL(p_OperationSequence,OPERATION_SEQ_NUM )
AND BR.resource_id = WIP.resource_id
AND MFGL.LOOKUP_TYPE(+) = 'BOM_RESOURCE_TYPE'
AND MFGL.LOOKUP_CODE(+) = BR.RESOURCE_TYPE;

CURSOR get_operation_sequence_csr(p_WoOperationId IN NUMBER)IS
SELECT OPERATION_SEQUENCE_NUM  FROM ahl_workorder_operations
WHERE WORKORDER_OPERATION_ID = p_WoOperationId;

CURSOR get_operation_sequences_csr(p_WorkorderId IN NUMBER, p_OperationSequence IN NUMBER)
IS
SELECT OPERATION_SEQUENCE_NUM FROM ahl_workorder_operations
WHERE WORKORDER_ID = p_WorkorderId
AND OPERATION_SEQUENCE_NUM = NVL(p_OperationSequence, OPERATION_SEQUENCE_NUM);

l_PRD_RESOURCE_TXNS_TBL AHL_PRD_RESOURCE_TRANX_PVT.PRD_RESOURCE_TXNS_TBL;
BEGIN
   x_return_status := init_user_and_role(p_userid);
   IF(x_return_status <> Fnd_Api.G_RET_STS_SUCCESS)THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   x_ResourceTransactions(0) := NULL;
   x_DefaultResourceTransactions(0) := NULL;


   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version,l_api_name, G_PKG_NAME ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
   END IF;

   -- Check Error Message stack.
   IF(p_WorkorderId IS NULL AND p_WorkorderNumber IS NULL)THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WO_NOT_FOUND');
      FND_MSG_PUB.ADD;
      RAISE  FND_API.G_EXC_ERROR;
   ELSIF (p_WorkorderId IS NULL AND p_WorkorderNumber IS NOT NULL)THEN
      l_workorder_id := get_workorder_id(p_WorkorderNumber);
   ELSE
      l_workorder_id := p_WorkorderId;
   END IF;

   x_msg_count := FND_MSG_PUB.count_msg;
   IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
   END IF;

   IF(p_WoOperationId IS NOT NULL)THEN
     OPEN get_operation_sequence_csr(p_WoOperationId);
     FETCH get_operation_sequence_csr INTO l_operation_sequence;
     IF(get_operation_sequence_csr%NOTFOUND)THEN
       FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WO_NOT_FOUND');
       FND_MSG_PUB.ADD;
       RAISE  FND_API.G_EXC_ERROR;
     END IF;
     CLOSE get_operation_sequence_csr;
   ELSIF (p_WoOperationId IS NULL AND p_OperationSequence IS NOT NULL)THEN
     l_operation_sequence := p_OperationSequence;
   END IF;
  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;


  l_restxns_index := 0;
  FOR res_txns IN get_wo_res_txns_csr(l_workorder_id, l_operation_sequence)LOOP
    x_ResourceTransactions(l_restxns_index).TransactionId := res_txns.TRANSACTION_ID ;
    x_ResourceTransactions(l_restxns_index).WorkorderId := res_txns.WORKORDER_ID ;
    x_ResourceTransactions(l_restxns_index).OperationSequenceNumber := res_txns.OPERATION_SEQ_NUM ;
    x_ResourceTransactions(l_restxns_index).ResourceSequenceNumber := res_txns.RESOURCE_SEQ_NUM ;
    x_ResourceTransactions(l_restxns_index).ResourceId := res_txns.RESOURCE_ID ;
    x_ResourceTransactions(l_restxns_index).ResourceCode := res_txns.RESOURCE_CODE ;
    x_ResourceTransactions(l_restxns_index).ResourceDescription := res_txns.DESCRIPTION ;
    x_ResourceTransactions(l_restxns_index).ResourceType := res_txns.RESOURCE_TYPE ;
    x_ResourceTransactions(l_restxns_index).ResourceTypeCode := res_txns.RESOURCE_TYPE_CODE ;
    x_ResourceTransactions(l_restxns_index).EmployeeId := res_txns.EMPLOYEE_ID ;
    x_ResourceTransactions(l_restxns_index).EmployeeNumber := res_txns.EMPLOYEE_NUMBER ;
    x_ResourceTransactions(l_restxns_index).EmployeeName := res_txns.FULL_NAME ;
    x_ResourceTransactions(l_restxns_index).SerialNumber := res_txns.SERIAL_NUMBER ;
    x_ResourceTransactions(l_restxns_index).StartTime := res_txns.TRANSACTION_DATE ;
    x_ResourceTransactions(l_restxns_index).EndTime := NULL ;
    x_ResourceTransactions(l_restxns_index).Quantity := res_txns.QUANTITY ;
    x_ResourceTransactions(l_restxns_index).UOMCode := res_txns.PRIMARY_UOM ;
    x_ResourceTransactions(l_restxns_index).UOM := res_txns.UOM_MEANING ;
    x_ResourceTransactions(l_restxns_index).UsageRateOrAmount := res_txns.USAGE_RATE_OR_AMOUNT ;
    x_ResourceTransactions(l_restxns_index).ActivityId := res_txns.ACTIVITY_ID ;
    x_ResourceTransactions(l_restxns_index).Activity := res_txns.ACTIVITY ;
    x_ResourceTransactions(l_restxns_index).ReasonId := res_txns.REASON_ID ;
    x_ResourceTransactions(l_restxns_index).Reason := res_txns.REASON_NAME ;
    x_ResourceTransactions(l_restxns_index).Reference := res_txns.REFERENCE ;
    x_ResourceTransactions(l_restxns_index).TransactionDate := res_txns.TRANSACTION_DATE ;
    x_ResourceTransactions(l_restxns_index).TransactionStatus := res_txns.TRANSACTION_STATUS ;
    IF (x_ResourceTransactions(l_restxns_index).Reference IS NOT NULL AND
        x_ResourceTransactions(l_restxns_index).ResourceTypeCode <> 2) THEN
        EXTRACT_SERIAL_NUMBER(
          p_reference => x_ResourceTransactions(l_restxns_index).Reference,
          x_serial_number => x_ResourceTransactions(l_restxns_index).SerialNumber);
    END IF;
    l_restxns_index := l_restxns_index + 1;
  END LOOP;

  l_restxns_index := 0;
  FOR res_txns_defaults IN get_operation_sequences_csr(l_workorder_id, l_operation_sequence)LOOP
    AHL_PRD_RESOURCE_TRANX_PVT.Get_Resource_Txn_Defaults
    (
        p_api_version   => 1.0,
        p_init_msg_list =>  FND_API.G_TRUE,
        p_module_type   =>  NULL,
        x_return_status =>  x_return_status,
        x_msg_count     =>   x_msg_count,
        x_msg_data      =>   x_msg_data,
        p_employee_id	=> FND_GLOBAL.employee_id,
        p_workorder_id	=> l_workorder_id,
        p_operation_seq_num	=> res_txns_defaults.OPERATION_SEQUENCE_NUM,
        p_function_name	  => 'AHL_PRD_TECH_MYWO',
        x_resource_txn_tbl   => l_PRD_RESOURCE_TXNS_TBL
    );
    IF(l_PRD_RESOURCE_TXNS_TBL IS NOT NULL AND l_PRD_RESOURCE_TXNS_TBL.COUNT > 0) THEN
      FOR i IN l_PRD_RESOURCE_TXNS_TBL.FIRST..l_PRD_RESOURCE_TXNS_TBL.LAST LOOP
        x_DefaultResourceTransactions(l_restxns_index).WorkorderId := l_workorder_id ;
        x_DefaultResourceTransactions(l_restxns_index).OperationSequenceNumber := res_txns_defaults.OPERATION_SEQUENCE_NUM ;
        x_DefaultResourceTransactions(l_restxns_index).ResourceId := l_PRD_RESOURCE_TXNS_TBL(i).RESOURCE_ID ;
        x_DefaultResourceTransactions(l_restxns_index).ResourceCode := l_PRD_RESOURCE_TXNS_TBL(i).resource_name ;
        x_DefaultResourceTransactions(l_restxns_index).ResourceType := l_PRD_RESOURCE_TXNS_TBL(i).RESOURCE_TYPE_NAME ;
        x_DefaultResourceTransactions(l_restxns_index).ResourceTypeCode := l_PRD_RESOURCE_TXNS_TBL(i).RESOURCE_TYPE_CODE ;
        x_DefaultResourceTransactions(l_restxns_index).EmployeeId := l_PRD_RESOURCE_TXNS_TBL(i).person_id ;
        x_DefaultResourceTransactions(l_restxns_index).EmployeeNumber := l_PRD_RESOURCE_TXNS_TBL(i).employee_num ;
        x_DefaultResourceTransactions(l_restxns_index).EmployeeName := l_PRD_RESOURCE_TXNS_TBL(i).employee_name ;
        x_DefaultResourceTransactions(l_restxns_index).SerialNumber := l_PRD_RESOURCE_TXNS_TBL(i).SERIAL_NUMBER ;
        x_DefaultResourceTransactions(l_restxns_index).EndTime := SYSDATE ;
        x_DefaultResourceTransactions(l_restxns_index).Quantity := l_PRD_RESOURCE_TXNS_TBL(i).QTY ;
        x_DefaultResourceTransactions(l_restxns_index).UOMCode := l_PRD_RESOURCE_TXNS_TBL(i).UOM_CODE ;
        x_DefaultResourceTransactions(l_restxns_index).UOM := l_PRD_RESOURCE_TXNS_TBL(i).UOM_MEANING ;
        l_restxns_index := l_restxns_index + 1;
      END LOOP;
    END IF;
  END LOOP;

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := FND_MSG_PUB.count_msg;


   x_msg_data := GET_MSG_DATA(x_msg_count);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count := FND_MSG_PUB.count_msg;
   x_msg_data := GET_MSG_DATA(x_msg_count);
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
     x_msg_count := FND_MSG_PUB.count_msg;
     x_msg_data := GET_MSG_DATA(x_msg_count);
END get_wo_res_txns;

PROCEDURE get_qa_plan_results
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2,
 p_userid                IN            VARCHAR2   := NULL,
 p_WorkorderId           IN            NUMBER,
 p_WorkorderNumber       IN            VARCHAR2,
 p_WoOperationId         IN            NUMBER,
 p_OperationSequence     IN            NUMBER,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2,
 x_QaPlan                  OUT NOCOPY QA_PLAN_REC_TYPE,
 x_QaResults               OUT NOCOPY QA_RESULTS_REC_TYPE
) IS

l_api_version      CONSTANT NUMBER := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'get_qa_plan_results';
l_workorder_id NUMBER;
l_workorder_operation_id NUMBER;

CURSOR get_wo_plan_csr(p_WorkorderId IN NUMBER)IS
Select plan_id,collection_id  from ahl_search_workorders_v
WHERE workorder_id = p_WorkorderId;

CURSOR get_op_plan_csr(p_WoOperationId IN NUMBER)IS
Select plan_id,collection_id  from ahl_workorder_operations_v
WHERE workorder_operation_id = p_WoOperationId;



l_plan_id NUMBER;
l_collection_id NUMBER;
l_attribute_index NUMBER;

CURSOR get_plan_attributes_csr(p_plan_id IN NUMBER) IS
SELECT char_id , prompt_sequence
       , prompt, enabled_flag , default_value
       , default_value_id , result_column_name
        , DECODE( NVL( sql_string_flag, 'N' ), 'N', DECODE( hardcoded_column, NULL, 'N', DECODE( QA_SS_LOV_API.get_lov_sql( plan_id, char_id, organization_id, null, null, null, null, null ), NULL, 'N', 'Y' ) ), sql_string_flag )    sql_string_flag
    , values_exist_flag, displayed_flag
    , char_name , datatype , display_length, hardcoded_column
    , developer_name , mandatory_flag
FROM QA_PLAN_CHARS_V WHERE plan_id = p_plan_id ORDER BY prompt_sequence;

CURSOR get_plan_csr(p_plan_id IN NUMBER) IS
SELECT plan_id , organization_id,  name
    , description FROM QA_PLANS_V
WHERE plan_id = p_plan_id;

CURSOR get_op_default_values_csr(p_WoOperationId IN NUMBER)IS
SELECT WO.JOB_NUMBER,
       AMH.TITLE MR_TITLE,
       WOP.OPERATION_SEQUENCE_NUM,
       WOP.STATUS_CODE,
       WO.JOB_STATUS_CODE,
       WO.WO_PART_NUMBER,
       WO.ITEM_INSTANCE_NUMBER,
       WO.LOT_NUMBER,
       WO.SERIAL_NUMBER
FROM AHL_WORKORDER_TASKS_V WO, AHL_WORKORDER_OPERATIONS WOP,
AHL_MR_ROUTES AMR, AHL_MR_HEADERS_B AMH
WHERE WO.MR_ROUTE_ID=AMR.MR_ROUTE_ID (+)
AND AMR.MR_HEADER_ID=AMH.MR_HEADER_ID(+)
AND WO.WORKORDER_ID = WOP.WORKORDER_ID
AND WOP.workorder_operation_id = p_WoOperationId;

op_defaults get_op_default_values_csr%ROWTYPE;

CURSOR get_wo_default_values_csr(p_WorkorderId IN NUMBER)IS
SELECT WO.JOB_NUMBER,
       AMH.TITLE MR_TITLE,
       WO.JOB_STATUS_CODE,
       WO.WO_PART_NUMBER,
       WO.ITEM_INSTANCE_NUMBER,
       WO.LOT_NUMBER,
       WO.SERIAL_NUMBER
FROM AHL_WORKORDER_TASKS_V WO,
AHL_MR_ROUTES AMR, AHL_MR_HEADERS_B AMH
WHERE WO.MR_ROUTE_ID=AMR.MR_ROUTE_ID (+)
AND AMR.MR_HEADER_ID=AMH.MR_HEADER_ID(+)
AND WO.WORKORDER_ID = p_WorkorderId;

wo_defaults get_wo_default_values_csr%ROWTYPE;



l_bindvar_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
-- dynamic cursor
l_cur            AHL_OSP_UTIL_PKG.ahl_search_csr;
l_results_sql_str VARCHAR2(6000);
source_cursor INTEGER;
dummy        INTEGER;
l_occurence  NUMBER;
l_temp VARCHAR2(4000);
l_result_row_index NUMBER;
l_result_column_index NUMBER;


BEGIN
   -- Initialize API return status to success

   x_return_status := init_user_and_role(p_userid);
   IF(x_return_status <> Fnd_Api.G_RET_STS_SUCCESS)THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   x_QaPlan.QA_PLAN_ATR_TBL(0) := NULL;
   x_QaResults.QA_RESULT_TBL(0).QA_PLAN_ATRVAL_TBL(0) := NULL;


   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version,l_api_name, G_PKG_NAME ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
   END IF;

   -- Check Error Message stack.
  IF(p_WorkorderId IS NULL AND p_WorkorderNumber IS NULL)THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WO_NOT_FOUND');
      FND_MSG_PUB.ADD;
      RAISE  FND_API.G_EXC_ERROR;
   ELSIF (p_WorkorderId IS NULL AND p_WorkorderNumber IS NOT NULL)THEN
      l_workorder_id := get_workorder_id(p_WorkorderNumber);
   ELSE
      l_workorder_id := p_WorkorderId;
   END IF;

   x_msg_count := FND_MSG_PUB.count_msg;
   IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
   END IF;

   IF(p_WoOperationId IS NULL AND p_OperationSequence IS NULL)THEN
      l_workorder_operation_id := NULL;
   ELSIF (p_WoOperationId IS NULL AND p_OperationSequence IS NOT NULL)THEN
      l_workorder_operation_id := get_workorder_operation_id(l_workorder_id, p_OperationSequence);
   ELSE
      l_workorder_operation_id := p_WoOperationId;
   END IF;
   --l_workorder_operation_id := NULL;
   x_msg_count := FND_MSG_PUB.count_msg;
   IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
   END IF;

   IF(l_workorder_operation_id IS NOT NULL)THEN
     OPEN get_op_plan_csr(l_workorder_operation_id);
     FETCH get_op_plan_csr INTO l_plan_id, l_collection_id;
     CLOSE get_op_plan_csr;
     OPEN get_op_default_values_csr(l_workorder_operation_id);
     FETCH get_op_default_values_csr INTO op_defaults;
     CLOSE get_op_default_values_csr;
   ELSIF(l_workorder_id IS NOT NULL)THEN
     OPEN get_wo_plan_csr(l_workorder_id);
     FETCH get_wo_plan_csr INTO l_plan_id, l_collection_id;
     CLOSE get_wo_plan_csr;
     OPEN get_wo_default_values_csr(l_workorder_id);
     FETCH get_wo_default_values_csr INTO wo_defaults;
     CLOSE get_wo_default_values_csr;
   END IF;
   --fetch plan
   IF(l_plan_id IS NOT NULL)THEN
      OPEN get_plan_csr(l_plan_id);
      FETCH get_plan_csr INTO x_QaPlan.PlanId,x_QaPlan.OrganizationId ,
                              x_QaPlan.PlanName, x_QaPlan.PlanDescription;
      CLOSE get_plan_csr;
      l_attribute_index :=0;
      FOR qa_plan_attributes IN get_plan_attributes_csr(l_plan_id)LOOP
         x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).CharId := qa_plan_attributes.char_id;
         x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).PromptSequence := qa_plan_attributes.prompt_sequence;
         x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).Prompt := qa_plan_attributes.prompt;
         x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DefaultValue := qa_plan_attributes.default_value;
         IF(qa_plan_attributes.displayed_flag = 1) THEN
           x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).IsDisplayed := 'T';
         ELSE
           x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).IsDisplayed := 'F';
         END IF;
         IF(qa_plan_attributes.mandatory_flag = 1) THEN
           x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).IsMandatory := 'T';
         ELSE
           x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).IsMandatory := 'F';
         END IF;
         IF(qa_plan_attributes.enabled_flag = 1) THEN
           x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).IsReadOnly := 'F';
         ELSE
           x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).IsReadOnly := 'T';
         END IF;
         IF(qa_plan_attributes.sql_string_flag = 'Y'
            AND x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).IsReadOnly = 'F'
            AND x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).IsDisplayed = 'T')THEN
            x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).IsListOfValue := 'T';
         ELSE
            x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).IsListOfValue := 'F';
         END IF;
         x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DisplayLength := qa_plan_attributes.display_length;
         IF(qa_plan_attributes.datatype = 2)THEN
           x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DataType := 'integer';
         ELSIF(qa_plan_attributes.datatype = 3)THEN
           x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DataType := 'date';
         ELSIF(qa_plan_attributes.datatype = 6)THEN
           x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DataType := 'dateTime';
         ELSE
           x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DataType := 'string';
         END IF;

         IF(l_workorder_operation_id IS NOT NULL)THEN
           IF(x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).CharId = 165)THEN
             x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DefaultValue := op_defaults.JOB_NUMBER;
           ELSIF(x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).CharId = 44)THEN
             x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DefaultValue := op_defaults.MR_TITLE;
           ELSIF(x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).CharId = 199)THEN
             x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DefaultValue := op_defaults.OPERATION_SEQUENCE_NUM;
           ELSIF(x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).CharId = 98)THEN
             x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DefaultValue := op_defaults.JOB_STATUS_CODE;
             ELSIF(x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).CharId = 125)THEN
             x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DefaultValue := op_defaults.STATUS_CODE;
           ELSIF(x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).CharId = 10)THEN
             x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DefaultValue := op_defaults.WO_PART_NUMBER;
           ELSIF(x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).CharId = 30)THEN
             x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DefaultValue := op_defaults.ITEM_INSTANCE_NUMBER;
           ELSIF(x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).CharId = 84)THEN
             x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DefaultValue := op_defaults.LOT_NUMBER;
           ELSIF(x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).CharId = 147)THEN
             x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DefaultValue := op_defaults.SERIAL_NUMBER;
           END IF;
         ELSE
           IF(x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).CharId = 165)THEN
             x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DefaultValue := wo_defaults.JOB_NUMBER;
           ELSIF(x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).CharId = 44)THEN
             x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DefaultValue := wo_defaults.MR_TITLE;
           ELSIF(x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).CharId = 98)THEN
             x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DefaultValue := wo_defaults.JOB_STATUS_CODE;
           ELSIF(x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).CharId = 10)THEN
             x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DefaultValue := wo_defaults.WO_PART_NUMBER;
           ELSIF(x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).CharId = 30)THEN
             x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DefaultValue := wo_defaults.ITEM_INSTANCE_NUMBER;
           ELSIF(x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).CharId = 84)THEN
             x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DefaultValue := wo_defaults.LOT_NUMBER;
           ELSIF(x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).CharId = 147)THEN
             x_QaPlan.QA_PLAN_ATR_TBL(l_attribute_index).DefaultValue := wo_defaults.SERIAL_NUMBER;
           END IF;
         END IF;
         l_attribute_index := l_attribute_index+1;
      END LOOP;
   END IF;
   --fetch results
   IF(l_plan_id IS NOT NULL AND l_collection_id IS NOT NULL)THEN
     x_QaResults.PlanId := l_plan_id;
     x_QaResults.CollectionId := l_collection_id;
     l_results_sql_str := get_qa_sql_str(l_plan_id);
     source_cursor := DBMS_sql.open_cursor;
     DBMS_SQL.parse(source_cursor,l_results_sql_str,DBMS_SQL.native);
     DBMS_SQL.BIND_VARIABLE(source_cursor, ':1', l_collection_id);
     DBMS_SQL.DEFINE_COLUMN(source_cursor, 1, l_occurence);

     FOR i IN x_QaPlan.QA_PLAN_ATR_TBL.FIRST..x_QaPlan.QA_PLAN_ATR_TBL.LAST LOOP
      DBMS_SQL.DEFINE_COLUMN(source_cursor, i+2, l_temp,4000);
     END LOOP;
     dummy := DBMS_SQL.EXECUTE(source_cursor);
     l_result_row_index := 0;
     LOOP
       IF DBMS_SQL.FETCH_ROWS(source_cursor)>0 THEN

          DBMS_SQL.COLUMN_VALUE(source_cursor, 1, l_occurence);
          x_QaResults.QA_RESULT_TBL(l_result_row_index).Occurence := l_occurence;

          FOR i IN x_QaPlan.QA_PLAN_ATR_TBL.FIRST..x_QaPlan.QA_PLAN_ATR_TBL.LAST LOOP
            DBMS_SQL.COLUMN_VALUE(source_cursor, i+2, l_temp);
            x_QaResults.QA_RESULT_TBL(l_result_row_index).QA_PLAN_ATRVAL_TBL(i).CharId
                 := x_QaPlan.QA_PLAN_ATR_TBL(i).CharId;
            x_QaResults.QA_RESULT_TBL(l_result_row_index).QA_PLAN_ATRVAL_TBL(i).AttributeValue
                 := l_temp;

          END LOOP;
       ELSE
         EXIT;
       END IF;
       l_result_row_index := l_result_row_index + 1;
     END LOOP;
   END IF;
  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := FND_MSG_PUB.count_msg;


   x_msg_data := GET_MSG_DATA(x_msg_count);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count := FND_MSG_PUB.count_msg;
   x_msg_data := GET_MSG_DATA(x_msg_count);
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
     x_msg_count := FND_MSG_PUB.count_msg;
     x_msg_data := GET_MSG_DATA(x_msg_count);
END get_qa_plan_results;

FUNCTION get_workorder_id(p_WorkorderNumber IN VARCHAR2) RETURN NUMBER
IS

l_workorder_id NUMBER;

CURSOR get_workorder_id_csr(p_workorder_number IN VARCHAR2) IS
Select WORKORDER_ID FROM AHL_WORKORDERS
WHERE WORKORDER_NAME = p_workorder_number;

BEGIN
  OPEN get_workorder_id_csr(p_WorkorderNumber);
  FETCH get_workorder_id_csr INTO l_workorder_id;
  IF(get_workorder_id_csr%NOTFOUND)THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WO_NOT_FOUND');
    FND_MSG_PUB.ADD;
    CLOSE get_workorder_id_csr;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;
  CLOSE get_workorder_id_csr;
  RETURN l_workorder_id;
END get_workorder_id;

FUNCTION get_workorder_operation_id(p_WorkorderId IN NUMBER,p_operation_sequence IN NUMBER) RETURN NUMBER
IS

l_workorder_operation_id NUMBER;

CURSOR get_workorder_operation_id_csr(p_WorkorderId IN NUMBER,p_operation_sequence IN NUMBER) IS
Select WORKORDER_OPERATION_ID FROM AHL_WORKORDER_OPERATIONS
WHERE WORKORDER_ID = p_WorkorderId AND
      OPERATION_SEQUENCE_NUM = p_operation_sequence;

BEGIN
  OPEN get_workorder_operation_id_csr(p_WorkorderId, p_operation_sequence);
  FETCH get_workorder_operation_id_csr INTO l_workorder_operation_id;
  IF(get_workorder_operation_id_csr%NOTFOUND)THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WO_NOT_FOUND');
    FND_MSG_PUB.ADD;
    CLOSE get_workorder_operation_id_csr;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;
  CLOSE get_workorder_operation_id_csr;
  RETURN l_workorder_operation_id;
END get_workorder_operation_id;

PROCEDURE EXTRACT_SERIAL_NUMBER(p_reference IN OUT NOCOPY VARCHAR2,
                                x_serial_number OUT NOCOPY VARCHAR2) IS
BEGIN
   NULL;
END EXTRACT_SERIAL_NUMBER;

FUNCTION get_qa_sql_str(p_plan_id IN NUMBER) RETURN VARCHAR2 IS

CURSOR get_plan_attributes_csr(p_plan_id IN NUMBER) IS
SELECT char_id , prompt_sequence
       , prompt, enabled_flag , default_value
       , default_value_id , result_column_name
        , DECODE( NVL( sql_string_flag, 'N' ), 'N', DECODE( hardcoded_column, NULL, 'N', DECODE( QA_SS_LOV_API.get_lov_sql( plan_id, char_id, organization_id, null, null, null, null, null ), NULL, 'N', 'Y' ) ), sql_string_flag )    sql_string_flag
    , values_exist_flag, displayed_flag
    , char_name , datatype , display_length, hardcoded_column
    , developer_name , mandatory_flag
FROM QA_PLAN_CHARS_V WHERE plan_id = p_plan_id ORDER BY prompt_sequence;

l_sql_string VARCHAR2(6000);
l_result_column VARCHAR2(240);
l_result_column_name VARCHAR2(240);


BEGIN
   l_sql_string := 'SELECT RESULTS.OCCURRENCE ';
   FOR qa_plan_attributes IN get_plan_attributes_csr(p_plan_id)LOOP
     IF(qa_plan_attributes.char_id = 10)THEN -- ITEM NUMBER
        l_result_column := 'CONCATENATED_SEGMENTS';
     ELSIF (qa_plan_attributes.char_id = 15)THEN -- LOCATOR
        l_result_column := 'CONCATENATED_SEGMENTS';
     ELSE
        IF ( qa_plan_attributes.hardcoded_column IS NOT NULL ) THEN
          l_result_column := qa_plan_attributes.developer_name;
        ELSE
          l_result_column := qa_plan_attributes.result_column_name;
        END IF;
     END IF;

     IF ( qa_plan_attributes.char_id = 10 )THEN
          l_result_column_name := 'ITEM.' || l_result_column || ' ';
          l_result_column_name := '(Select ' ||l_result_column_name || ' FROM  MTL_SYSTEM_ITEMS_KFV ITEM '
                        || ' WHERE ITEM.inventory_item_id  = RESULTS.'|| qa_plan_attributes.hardcoded_column
                        || ' AND ITEM.organization_id  = RESULTS.organization_id ) ' || l_result_column;

     ELSIF ( qa_plan_attributes.char_id = 15) THEN
          l_result_column_name := 'LOCATOR.' || l_result_column || ' ';

          l_result_column_name := '(Select ' || l_result_column_name ||' FROM  MTL_ITEM_LOCATIONS_KFV LOCATOR '
                        || ' WHERE LOCATOR.inventory_location_id  = RESULTS.' || qa_plan_attributes.hardcoded_column
                        + ' AND LOCATOR.organization_id  = RESULTS.organization_id ) ' || l_result_column;

     ELSE

          l_result_column_name := 'to_char(RESULTS.' || l_result_column || ')';
     END IF;
     l_sql_string := l_sql_string || ' , ' || l_result_column_name;
   END LOOP;

   l_sql_string := l_sql_string || ' FROM QA_RESULTS_V RESULTS WHERE COLLECTION_ID = :1 ORDER BY RESULTS.OCCURRENCE DESC';
   RETURN l_sql_string;
END get_qa_sql_str;

PROCEDURE process_turnover_notes(
 p_WO_DETAILS_REC        IN            WO_DETAILS_REC_TYPE,
 p_TurnoverNotes         IN            TURNOVER_NOTES_TBL_TYPE,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2
)IS
l_trunover_notes_tbl AHL_PRD_WORKORDER_PVT.turnover_notes_tbl_type;
j INTEGER;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF(p_TurnoverNotes IS NULL OR p_TurnoverNotes.COUNT < 1)THEN
    RETURN;
  END IF;
  j :=0;
  FOR i IN p_TurnoverNotes.FIRST..p_TurnoverNotes.LAST LOOP
    IF(p_TurnoverNotes(i).Notes IS NOT NULL AND p_TurnoverNotes(i).JtfNoteId IS NULL)THEN
       l_trunover_notes_tbl(j).Notes := p_TurnoverNotes(i).Notes;
       l_trunover_notes_tbl(j).source_object_id := p_WO_DETAILS_REC.WorkorderId;
       l_trunover_notes_tbl(j).source_object_code := 'AHL_WO_TURNOVER_NOTES';
       l_trunover_notes_tbl(j).Entered_Date := p_TurnoverNotes(i).EnteredDate;
       --l_trunover_notes_tbl(j).employee_id := p_TurnoverNotes(i).EnteredBy;
       l_trunover_notes_tbl(j).employee_name := p_TurnoverNotes(i).EnteredByName;
       l_trunover_notes_tbl(j).org_id := p_WO_DETAILS_REC.OrganizationId;
       j := j+1;
    END IF;
  END LOOP;

  IF(l_trunover_notes_tbl IS NOT NULL AND l_trunover_notes_tbl.COUNT > 0)THEN
    IF(p_WO_DETAILS_REC.IsUpdateEnabled <> 'T')THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_TRNNTREC_NALWD');
      FND_MSG_PUB.ADD;
      RAISE  FND_API.G_EXC_ERROR;
    END IF;

    AHL_PRD_WORKORDER_PVT.INSERT_TURNOVER_NOTES
    (
        p_api_version          => 1.0 ,
        p_init_msg_list        =>  FND_API.G_TRUE,
        p_commit               =>  FND_API.G_FALSE,
        p_validation_level     =>  FND_API.G_VALID_LEVEL_FULL,
        p_default              =>  FND_API.G_TRUE,
        p_module_type          =>  'OAF',
        x_return_status        => x_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data,
        p_trunover_notes_tbl   => l_trunover_notes_tbl
    );

  END IF;


END process_turnover_notes;

PROCEDURE process_wo_details
(
 p_WO_DETAILS_REC        IN            WO_DETAILS_REC_TYPE,
 p_CURR_WO_DETAILS_REC   IN            WO_DETAILS_REC_TYPE,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2
)IS

l_prd_workorder_rec   AHL_PRD_WORKORDER_PVT.prd_workorder_rec;
l_prd_workoper_tbl    AHL_PRD_WORKORDER_PVT.prd_workoper_tbl;

CURSOR get_status_csr(status VARCHAR)
IS
SELECT lookup_code
FROM fnd_Lookups
WHERE lookup_type = 'AHL_JOB_STATUS'
AND meaning = status;

CURSOR validate_status_csr(c_status_new VARCHAR, c_status_old VARCHAR)
IS
SELECT 1
FROM AHL_STATUS_ORDER_RULES
WHERE  system_status_type = 'AHL_JOB_STATUS'
AND CURRENT_STATUS_CODE = c_status_old
AND NEXT_STATUS_CODE    = c_status_new;

l_status_code VARCHAR2(30);
l_dummy_ctr NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF(p_CURR_WO_DETAILS_REC.IsUpdateEnabled <> 'T')THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WO_UPD_NALWD');
      FND_MSG_PUB.ADD;
      RAISE  FND_API.G_EXC_ERROR;
  END IF;

  l_status_code := p_WO_DETAILS_REC.StatusCode;

  IF p_WO_DETAILS_REC.StatusCode IS NULL AND p_WO_DETAILS_REC.Status IS NOT NULL THEN
      OPEN get_status_csr(p_WO_DETAILS_REC.Status);
      FETCH get_status_csr INTO l_status_code;
      IF get_status_csr%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_PP_JOB_INV_STATUS_JSP');
        FND_MSG_PUB.ADD;
        CLOSE get_status_csr;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        CLOSE get_status_csr;
      END IF;
    END IF;


    IF l_status_code IS NOT NULL AND l_status_code <> '4' THEN
      OPEN validate_status_csr(l_status_code,p_CURR_WO_DETAILS_REC.StatusCode);
      FETCH validate_status_csr INTO l_dummy_ctr;
      IF validate_status_csr%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_UMP_INVALID_STTS_CHNG');
        FND_MESSAGE.SET_TOKEN('FROM_STATUS',p_CURR_WO_DETAILS_REC.StatusCode);
        FND_MESSAGE.SET_TOKEN('TO_STATUS', l_status_code);
        FND_MSG_PUB.ADD;
        CLOSE validate_status_csr;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        CLOSE validate_status_csr;
      END IF;
  END IF;

  IF(l_status_code = '3' AND p_CURR_WO_DETAILS_REC.StatusCode = '1')THEN
    --release Job
    AHL_PRD_WORKORDER_PVT.release_visit_jobs
    (
        p_api_version          => 1.0 ,
        p_init_msg_list        =>  FND_API.G_TRUE,
        p_commit               =>  FND_API.G_FALSE,
        p_validation_level     =>  FND_API.G_VALID_LEVEL_FULL,
        p_default              =>  FND_API.G_TRUE,
        p_module_type          =>  'OAF',
        x_return_status        => x_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data,
        p_visit_id             => NULL,
        p_unit_effectivity_id  => NULL,
        p_workorder_id         => p_CURR_WO_DETAILS_REC.WorkorderId
     );
  ELSIF(l_status_code = '7')THEN
    --cancel job
    AHL_PRD_WORKORDER_PVT.cancel_visit_jobs
    (
        p_api_version          => 1.0 ,
        p_init_msg_list        =>  FND_API.G_TRUE,
        p_commit               =>  FND_API.G_FALSE,
        p_validation_level     =>  FND_API.G_VALID_LEVEL_FULL,
        p_default              =>  FND_API.G_TRUE,
        p_module_type          =>  'OAF',
        x_return_status        => x_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data,
        p_visit_id             => NULL,
        p_unit_effectivity_id  => NULL,
        p_workorder_id         => p_CURR_WO_DETAILS_REC.WorkorderId
     );
  ELSIF(l_status_code = '4')THEN
    IF(p_CURR_WO_DETAILS_REC.IsCompleteEnabled <> 'T')THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WO_COMP_NALWD');
      FND_MSG_PUB.ADD;
      RAISE  FND_API.G_EXC_ERROR;
    END IF;
    -- complete job
    AHL_COMPLETIONS_PVT.complete_workorder
    (
        p_api_version          => 1.0 ,
        p_init_msg_list        =>  FND_API.G_TRUE,
        p_commit               =>  FND_API.G_FALSE,
        p_validation_level     =>  FND_API.G_VALID_LEVEL_FULL,
        p_default              =>  FND_API.G_TRUE,
        p_module_type          =>  'OAF',
        x_return_status        => x_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data,
        p_workorder_id         => p_CURR_WO_DETAILS_REC.WorkorderId,
        p_object_version_no    => p_CURR_WO_DETAILS_REC.ObjectVersionNumber
    );

  ELSE
    l_prd_workorder_rec.WORKORDER_ID := p_CURR_WO_DETAILS_REC.WorkorderId;
    l_prd_workorder_rec.OBJECT_VERSION_NUMBER := p_CURR_WO_DETAILS_REC.ObjectVersionNumber;
    l_prd_workorder_rec.dml_operation := 'U';
    l_prd_workorder_rec.STATUS_CODE := l_status_code;
    l_prd_workorder_rec.STATUS_MEANING := p_WO_DETAILS_REC.Status;
    l_prd_workorder_rec.HOLD_REASON_CODE := p_WO_DETAILS_REC.HoldReasonCode;
    l_prd_workorder_rec.HOLD_REASON := p_WO_DETAILS_REC.HoldReason;
    l_prd_workorder_rec.DEPARTMENT_ID := p_WO_DETAILS_REC.DepartmentId;
    l_prd_workorder_rec.DEPARTMENT_NAME := p_WO_DETAILS_REC.DepartmentName;
    l_prd_workorder_rec.SCHEDULED_START_DATE := p_WO_DETAILS_REC.ScheduledStartDate;
    l_prd_workorder_rec.SCHEDULED_END_DATE := p_WO_DETAILS_REC.ScheduledEndDate;
    l_prd_workorder_rec.ACTUAL_START_DATE := p_WO_DETAILS_REC.ActualStartDate;
    l_prd_workorder_rec.ACTUAL_END_DATE := p_WO_DETAILS_REC.ActualEndDate;
    --AHL_DEBUG_PUB.debug( 'l_prd_workorder_rec.ACTUAL_START_DATE : '||l_prd_workorder_rec.ACTUAL_START_DATE);
    --AHL_DEBUG_PUB.debug( 'l_prd_workorder_rec.ACTUAL_END_DATE : '||l_prd_workorder_rec.ACTUAL_END_DATE);
    AHL_PRD_WORKORDER_PVT.update_job
    (
        p_api_version          => 1.0 ,
        p_init_msg_list        =>  FND_API.G_TRUE,
        p_commit               =>  FND_API.G_FALSE,
        p_validation_level     =>  FND_API.G_VALID_LEVEL_FULL,
        p_default              =>  FND_API.G_TRUE,
        p_module_type          =>  'OAF',
        x_return_status        => x_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data,
        p_wip_load_flag        => 'Y',
        p_x_prd_workorder_rec  => l_prd_workorder_rec,
        p_x_prd_workoper_tbl   => l_prd_workoper_tbl
     );
    -- update job
  END IF;



END process_wo_details;

PROCEDURE process_op_quality
(
 p_OP_DETAILS_REC        IN            OP_DETAILS_REC_TYPE,
 p_OP_QaResults          IN            QA_RESULTS_REC_TYPE,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2
) IS

l_results_tbl AHL_QA_RESULTS_PVT.qa_results_tbl_type;
l_hidden_results_tbl AHL_QA_RESULTS_PVT.qa_results_tbl_type;
l_context_tbl        AHL_QA_RESULTS_PVT.qa_context_tbl_type;
l_occurrence_tbl   AHL_QA_RESULTS_PVT.occurrence_tbl_type;

l_QA_PLAN    QA_PLAN_REC_TYPE;
l_QA_RESULTS QA_RESULTS_REC_TYPE;
results_tbl_index integer;
occurrence_tbl_index integer;
l_rowElementCount integer;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF(p_OP_QaResults.QA_RESULT_TBL IS NULL OR p_OP_QaResults.QA_RESULT_TBL.COUNT < 1)THEN
    RETURN;
  END IF;

  IF(p_OP_DETAILS_REC.IsQualityEnabled <> 'T')THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_OPQASUB_NALWD');
    FND_MSG_PUB.ADD;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  get_qa_plan_results
  (
    p_module_type   => 'BPEL',
    p_WorkorderId    => p_OP_DETAILS_REC.WorkorderId,
    p_WorkorderNumber => NULL,
    p_WoOperationId   => NULL,--p_OP_DETAILS_REC.WorkorderOperationId,
    p_OperationSequence  => p_OP_DETAILS_REC.OperationSequenceNumber,
    x_return_status        => x_return_status,
    x_msg_count            => x_msg_count,
    x_msg_data             => x_msg_data,
    x_QaPlan               => l_QA_PLAN,
    x_QaResults            => l_QA_RESULTS
  );
  --AHL_DEBUG_PUB.debug( 'p_OP_DETAILS_REC.WorkorderOperationId : '||p_OP_DETAILS_REC.WorkorderOperationId);
  --AHL_DEBUG_PUB.debug( 'l_QA_PLAN.PlanId : '||l_QA_PLAN.PlanId);

  l_context_tbl(1).Name := 'operation_id';
  l_context_tbl(1).Value := to_char(p_OP_DETAILS_REC.WorkorderOperationId);

  l_context_tbl(2).Name := 'object_version_no';
  l_context_tbl(2).Value := to_char(p_OP_DETAILS_REC.ObjectVersionNumber);

  results_tbl_index := 1;
  occurrence_tbl_index :=1;
  FOR i IN p_OP_QaResults.QA_RESULT_TBL.FIRST..p_OP_QaResults.QA_RESULT_TBL.LAST LOOP
   l_rowElementCount := 0;
   FOR j IN p_OP_QaResults.QA_RESULT_TBL(i).QA_PLAN_ATRVAL_TBL.FIRST..p_OP_QaResults.QA_RESULT_TBL(i).QA_PLAN_ATRVAL_TBL.LAST LOOP
     IF('T' = IS_VALID_RESULT_ATTRIBUTE(
              p_OP_QaResults.QA_RESULT_TBL(i).QA_PLAN_ATRVAL_TBL(j).CharId,
              l_QA_PLAN))THEN
       l_results_tbl(results_tbl_index).char_id := p_OP_QaResults.QA_RESULT_TBL(i).QA_PLAN_ATRVAL_TBL(j).CharId;
       l_results_tbl(results_tbl_index).result_value  := p_OP_QaResults.QA_RESULT_TBL(i).QA_PLAN_ATRVAL_TBL(j).AttributeValue;
       results_tbl_index := results_tbl_index+1;
       l_rowElementCount := l_rowElementCount+1;
     END IF;
   END LOOP;
   IF(l_rowElementCount > 0)THEN
     l_occurrence_tbl(occurrence_tbl_index).element_count := l_rowElementCount;
     occurrence_tbl_index := occurrence_tbl_index + 1;
   END IF;
  END LOOP;
  IF(results_tbl_index = 1)THEN
    RETURN; -- No attributes passed.
  END IF;

  AHL_QA_RESULTS_PVT.submit_qa_results
  (
    p_api_version        => 1.0,
    p_init_msg_list      => FND_API.G_TRUE,
    p_commit             => FND_API.G_FALSE,
    p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
    p_default            => FND_API.G_FALSE,
    p_module_type        => 'OAF',
    x_return_status      => x_return_status,
    x_msg_count          => x_msg_count,
    x_msg_data           => x_msg_data,
    p_plan_id            => l_QA_PLAN.PlanId,
    p_organization_id    => l_QA_PLAN.OrganizationId,
    p_transaction_no     => 2002,
    p_specification_id   => NULL,
    p_results_tbl        => l_results_tbl,
    p_hidden_results_tbl => l_hidden_results_tbl,
    p_context_tbl        => l_context_tbl,
    p_result_commit_flag => 0,
    p_id_or_value        => 'VALUE',
    p_x_collection_id    => l_QA_RESULTS.CollectionId,
    p_x_occurrence_tbl   => l_occurrence_tbl
  );
END process_op_quality;

PROCEDURE process_op_details
(
 p_WO_DETAILS_REC        IN            WO_DETAILS_REC_TYPE,
 p_Operations            IN            OP_ALL_DETAILS_TBL,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2
)IS


CURSOR get_current_obj_ver_csr(p_WoOperationId IN NUMBER)IS
SELECT object_version_number FROM AHL_WORKORDER_OPERATIONS
WHERE WORKORDER_OPERATION_ID = p_WoOperationId;

l_prd_operation_tbl      AHL_PRD_OPERATIONS_PVT.PRD_OPERATION_TBL;
l_Operations           OP_TBL_TYPE;
j INTEGER;
x_msg_index_out NUMBER;
l_prd_comp_operation_tbl AHL_COMPLETIONS_PVT.operation_tbl_type;


BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 IF(p_Operations IS NULL OR p_Operations.COUNT < 1)THEN
    RETURN;
 END IF;
 j :=1;--keep this as 1 as thats how called package recognize things..
 FOR i IN p_Operations.FIRST..p_Operations.LAST LOOP
    IF(p_Operations(i).WorkorderOperationId IS NULL AND p_Operations(i).OperationSequenceNumber IS NULL)THEN
      EXIT;--empty record not entertained.
    END IF;
    --AHL_DEBUG_PUB.debug( 'p_Operations : '||i);
    --AHL_DEBUG_PUB.debug( 'p_Operations : '||i || ' : ' ||p_Operations(i).OperationSequenceNumber);
    get_wo_operations_details
    (
    p_module_type           => 'BPEL',
    p_WorkorderId           => p_WO_DETAILS_REC.WorkorderId,
    p_WorkorderNumber       => NULL,
    p_WoOperationId         => p_Operations(i).WorkorderOperationId,
    p_OperationSequence     => p_Operations(i).OperationSequenceNumber,
    x_return_status         => x_return_status,
    x_msg_count             => x_msg_count,
    x_msg_data              => x_msg_count,
    x_Operations            => l_Operations
    );
    --DBMS_OUTPUT.put_line('x_return_status :i: ' || x_return_status);
    IF(p_Operations(i).ObjectVersionNumber IS NULL OR
      p_Operations(i).ObjectVersionNumber <> l_Operations(0).ObjectVersionNumber)THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF(l_Operations(0).IsUpdateEnabled <> 'T')THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_OPUPD_NALWD');
      FND_MSG_PUB.ADD;
      RAISE  FND_API.G_EXC_ERROR;
    END IF;
    process_op_quality
       (
        p_OP_DETAILS_REC        => l_Operations(0),
        p_OP_QaResults          => p_Operations(i).QAResults,
        x_return_status        => x_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data
       );
    --DBMS_OUTPUT.put_line('x_return_status :i: ' || x_return_status);
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
       OPEN get_current_obj_ver_csr(l_Operations(0).WorkorderOperationId);
       FETCH get_current_obj_ver_csr INTO l_Operations(0).ObjectVersionNumber;
       CLOSE get_current_obj_ver_csr;
    END IF;

    IF(p_Operations(i).StatusCode IS NOT NULL OR p_Operations(i).Status IS NOT NULL
       OR p_Operations(i).ActualStartDate IS NOT NULL
       OR p_Operations(i).ActualEndDate IS NOT NULL)THEN
       IF(p_Operations(i).StatusCode NOT IN ('1','2'))THEN
         FND_MESSAGE.SET_NAME('AHL','AHL_PRD_OPUPD_NALWD');
         FND_MSG_PUB.ADD;
         RAISE  FND_API.G_EXC_ERROR;
       END IF;
       ----DBMS_OUTPUT.put_line('op :i:statusCode: ' || p_Operations(i).StatusCode);
       l_prd_operation_tbl(j).operation_sequence_num := l_Operations(0).OperationSequenceNumber;
       l_prd_operation_tbl(j).workorder_id := l_Operations(0).WorkorderId;
       l_prd_operation_tbl(j).workorder_operation_id := l_Operations(0).WorkorderOperationId;
       l_prd_operation_tbl(j).department_id := l_Operations(0).DepartmentId;
       l_prd_operation_tbl(j).department_name := l_Operations(0).DepartmentName;
       l_prd_operation_tbl(j).object_version_number := l_Operations(0).ObjectVersionNumber;
       l_prd_operation_tbl(j).scheduled_start_date := l_Operations(0).ScheduledStartDate;
       l_prd_operation_tbl(j).scheduled_end_date := l_Operations(0).ScheduledEndDate;
       l_prd_operation_tbl(j).dml_operation := 'U';
       l_prd_operation_tbl(j).status_code := p_Operations(i).StatusCode;
       l_prd_operation_tbl(j).status_meaning := p_Operations(i).Status;
       l_prd_operation_tbl(j).actual_start_date := p_Operations(i).ActualStartDate;
       l_prd_operation_tbl(j).actual_end_date := p_Operations(i).ActualEndDate;
       IF(p_Operations(i).StatusCode = '1')THEN
        IF(p_Operations(i).ActualStartDate IS NULL AND p_Operations(i).ActualEndDate IS NULL)THEN
         l_prd_operation_tbl(j).actual_start_date := l_Operations(0).ActualStartDate;
         l_prd_operation_tbl(j).actual_end_date := l_Operations(0).ActualEndDate;
         IF(l_prd_operation_tbl(j).actual_start_date IS NULL AND l_prd_operation_tbl(j).actual_end_date IS NULL)THEN
           l_prd_comp_operation_tbl(0).workorder_id := l_Operations(0).WorkorderId;
           l_prd_comp_operation_tbl(0).operation_sequence_num := l_Operations(0).OperationSequenceNumber;
           AHL_COMPLETIONS_PVT.Get_Default_Op_Actual_Dates
           (
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            P_x_operation_tbl  => l_prd_comp_operation_tbl
           );
           IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;
          l_prd_operation_tbl(j).actual_start_date := l_prd_comp_operation_tbl(0).Actual_Start_Date;
          l_prd_operation_tbl(j).actual_end_date := l_prd_comp_operation_tbl(0).Actual_End_Date;
         END IF;
        END IF;
       END IF;
       j := j+1;
    END IF;
  END LOOP;
  IF(l_prd_operation_tbl IS NOT NULL AND l_prd_operation_tbl.COUNT > 0)THEN
    ----DBMS_OUTPUT.put_line('op :i:statusCode: processing operations : ' || l_prd_operation_tbl.COUNT);
    AHL_PRD_OPERATIONS_PVT.PROCESS_OPERATIONS
    (
        p_api_version          => 1.0 ,
        p_init_msg_list        =>  FND_API.G_TRUE,
        p_commit               =>  FND_API.G_FALSE,
        p_validation_level     =>  FND_API.G_VALID_LEVEL_FULL,
        p_default              =>  FND_API.G_TRUE,
        p_module_type          =>  'OAF',
        p_wip_mass_load_flag   => 'Y',
        x_return_status        => x_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data,
        p_x_prd_operation_tbl  => l_prd_operation_tbl
    );
  END IF;

END process_op_details;

PROCEDURE process_mtl_requirements
(
 p_WO_DETAILS_REC        IN            WO_DETAILS_REC_TYPE,
 p_MaterialRequirementDetails  IN      MTL_REQMTS_TBL_TYPE,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2
) IS

l_req_material_tbl AHL_PP_MATERIALS_PVT.Req_Material_Tbl_Type;
j INTEGER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF(p_MaterialRequirementDetails IS NULL OR p_MaterialRequirementDetails.COUNT < 1)THEN
    RETURN;
  END IF;
  j := 1;
  FOR i IN p_MaterialRequirementDetails.FIRST..p_MaterialRequirementDetails.LAST LOOP
      l_req_material_tbl(j).SCHEDULE_MATERIAL_ID := p_MaterialRequirementDetails(i).ScheduledMaterialId;
      --l_req_material_tbl(j).OBJECT_VERSION_NUMBER := p_MaterialRequirementDetails(i).ObjectVersionNumber;
      l_req_material_tbl(j).INVENTORY_ITEM_ID := p_MaterialRequirementDetails(i).InventoryItemId;
      l_req_material_tbl(j).SCHEDULED_DATE := p_MaterialRequirementDetails(i).ScheduledDate;
      l_req_material_tbl(j).CONCATENATED_SEGMENTS := p_MaterialRequirementDetails(i).ItemNumber;
      l_req_material_tbl(j).ITEM_DESCRIPTION := p_MaterialRequirementDetails(i).ItemDescription;
      l_req_material_tbl(j).REQUESTED_QUANTITY := p_MaterialRequirementDetails(i).RequiredQuantity;
      l_req_material_tbl(j).REQUESTED_DATE := p_MaterialRequirementDetails(i).RequiredDate;
      l_req_material_tbl(j).UOM_MEANING := p_MaterialRequirementDetails(i).PartUOM;
      l_req_material_tbl(j).SCHEDULED_QUANTITY := p_MaterialRequirementDetails(i).ScheduledQuantity;
      l_req_material_tbl(j).JOB_NUMBER := p_WO_DETAILS_REC.WorkorderNumber;
      l_req_material_tbl(j).WORKORDER_ID := p_WO_DETAILS_REC.WorkorderId;
      --l_req_material_tbl(j).WIP_ENTITY_ID := p_WO_DETAILS_REC.WipEntityId;
      l_req_material_tbl(j).OPERATION_SEQUENCE := p_MaterialRequirementDetails(i).OperationSequenceNumber;
      IF(p_MaterialRequirementDetails(i).ScheduledMaterialId IS NOT NULL) THEN
        l_req_material_tbl(j).OPERATION_FLAG := 'U';
      ELSE
        l_req_material_tbl(j).OPERATION_FLAG := 'C';
      END IF;
      j := j+1;
    END LOOP;
    AHL_PP_MATERIALS_PVT.Process_Material_Request (
      p_api_version          => 1.0 ,
      p_init_msg_list        =>  FND_API.G_TRUE,
      p_commit               =>  FND_API.G_FALSE,
      p_validation_level     =>  FND_API.G_VALID_LEVEL_FULL,
      p_module_type          =>  'API',
      p_x_req_material_tbl   => l_req_material_tbl,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data
    );
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

END process_mtl_requirements;

PROCEDURE process_wo_quality
(
 p_WO_DETAILS_REC        IN            WO_DETAILS_REC_TYPE,
 p_WO_QaResults          IN            QA_RESULTS_REC_TYPE,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2
) IS

l_results_tbl AHL_QA_RESULTS_PVT.qa_results_tbl_type;
l_hidden_results_tbl AHL_QA_RESULTS_PVT.qa_results_tbl_type;
l_context_tbl        AHL_QA_RESULTS_PVT.qa_context_tbl_type;
l_occurrence_tbl   AHL_QA_RESULTS_PVT.occurrence_tbl_type;

l_QA_PLAN    QA_PLAN_REC_TYPE;
l_QA_RESULTS QA_RESULTS_REC_TYPE;
results_tbl_index integer;
occurrence_tbl_index integer;
l_rowElementCount integer;


BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF(p_WO_QaResults.QA_RESULT_TBL IS NULL OR p_WO_QaResults.QA_RESULT_TBL.COUNT < 1)THEN
    RETURN;
  END IF;
  IF(p_WO_DETAILS_REC.IsQualityEnabled <> 'T')THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WOQASUB_NALWD');
    FND_MSG_PUB.ADD;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  get_qa_plan_results
  (
    p_module_type   => 'BPEL',
    p_WorkorderId    => p_WO_DETAILS_REC.WorkorderId,
    p_WorkorderNumber => NULL,
    p_WoOperationId   => NULL,
    p_OperationSequence  => NULL,
    x_return_status        => x_return_status,
    x_msg_count            => x_msg_count,
    x_msg_data             => x_msg_data,
    x_QaPlan               => l_QA_PLAN,
    x_QaResults            => l_QA_RESULTS
  );

  l_context_tbl(1).Name := 'workorder_id';
  l_context_tbl(1).Value := to_char(p_WO_DETAILS_REC.WorkorderId);

  l_context_tbl(2).Name := 'object_version_no';
  l_context_tbl(2).Value := to_char(p_WO_DETAILS_REC.ObjectVersionNumber);

  results_tbl_index := 1;
  occurrence_tbl_index :=1;
  FOR i IN p_WO_QaResults.QA_RESULT_TBL.FIRST..p_WO_QaResults.QA_RESULT_TBL.LAST LOOP
   l_rowElementCount := 0;
   FOR j IN p_WO_QaResults.QA_RESULT_TBL(i).QA_PLAN_ATRVAL_TBL.FIRST..p_WO_QaResults.QA_RESULT_TBL(i).QA_PLAN_ATRVAL_TBL.LAST LOOP
     IF('T' = IS_VALID_RESULT_ATTRIBUTE(
              p_WO_QaResults.QA_RESULT_TBL(i).QA_PLAN_ATRVAL_TBL(j).CharId,
              l_QA_PLAN))THEN
       l_results_tbl(results_tbl_index).char_id := p_WO_QaResults.QA_RESULT_TBL(i).QA_PLAN_ATRVAL_TBL(j).CharId;
       l_results_tbl(results_tbl_index).result_value  := p_WO_QaResults.QA_RESULT_TBL(i).QA_PLAN_ATRVAL_TBL(j).AttributeValue;
       results_tbl_index := results_tbl_index+1;
       l_rowElementCount := l_rowElementCount+1;
     END IF;
   END LOOP;
   IF(l_rowElementCount > 0)THEN
     l_occurrence_tbl(occurrence_tbl_index).element_count := l_rowElementCount;
     occurrence_tbl_index := occurrence_tbl_index + 1;
   END IF;
  END LOOP;
  IF(results_tbl_index = 1)THEN
    RETURN; -- No attributes passed.
  END IF;

  AHL_QA_RESULTS_PVT.submit_qa_results
  (
    p_api_version        => 1.0,
    p_init_msg_list      => FND_API.G_TRUE,
    p_commit             => FND_API.G_FALSE,
    p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
    p_default            => FND_API.G_FALSE,
    p_module_type        => 'OAF',
    x_return_status      => x_return_status,
    x_msg_count          => x_msg_count,
    x_msg_data           => x_msg_data,
    p_plan_id            => l_QA_PLAN.PlanId,
    p_organization_id    => l_QA_PLAN.OrganizationId,
    p_transaction_no     => 2001,
    p_specification_id   => NULL,
    p_results_tbl        => l_results_tbl,
    p_hidden_results_tbl => l_hidden_results_tbl,
    p_context_tbl        => l_context_tbl,
    p_result_commit_flag => 0,
    p_id_or_value        => 'VALUE',
    p_x_collection_id    => l_QA_RESULTS.CollectionId,
    p_x_occurrence_tbl   => l_occurrence_tbl
  );
END process_wo_quality;



PROCEDURE process_res_txns
(
 p_WO_DETAILS_REC        IN            WO_DETAILS_REC_TYPE,
 p_ResourceTransactions  IN            RES_TXNS_TBL_TYPE,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2
) IS
l_res_txns_tbl AHL_PRD_RESOURCE_TRANX_PVT.PRD_RESOURCE_TXNS_TBL;
j INTEGER;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF(p_ResourceTransactions IS NULL OR p_ResourceTransactions.COUNT < 1)THEN
    RETURN;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  j :=0;
  FOR i IN p_ResourceTransactions.FIRST..p_ResourceTransactions.LAST LOOP
    IF((p_ResourceTransactions(i).StartTime IS NOT NULL OR
       p_ResourceTransactions(i).EndTime IS NOT NULL OR
       p_ResourceTransactions(i).Quantity IS NOT NULL) AND
       (p_ResourceTransactions(i).ResourceId IS NOT NULL OR
       p_ResourceTransactions(i).ResourceCode IS NOT NULL))THEN
       l_res_txns_tbl(j).WORKORDER_ID := p_WO_DETAILS_REC.WorkorderId;
       l_res_txns_tbl(j).OPERATION_SEQUENCE_NUM := p_ResourceTransactions(i).OperationSequenceNumber;
       l_res_txns_tbl(j).RESOURCE_ID := p_ResourceTransactions(i).ResourceId;
       l_res_txns_tbl(j).RESOURCE_NAME := p_ResourceTransactions(i).ResourceCode;
       l_res_txns_tbl(j).Qty := p_ResourceTransactions(i).Quantity;
       l_res_txns_tbl(j).TRANSACTION_DATE := p_ResourceTransactions(i).StartTime ;
       l_res_txns_tbl(j).END_DATE := p_ResourceTransactions(i).EndTime;
       l_res_txns_tbl(j).DML_OPERATION := 'C';
       l_res_txns_tbl(j).employee_name := p_ResourceTransactions(i).EmployeeName;
       l_res_txns_tbl(j).employee_num := p_ResourceTransactions(i).EmployeeNumber;
       l_res_txns_tbl(j).person_id := p_ResourceTransactions(i).EmployeeId;
       l_res_txns_tbl(j).serial_number := p_ResourceTransactions(i).SerialNumber;
       l_res_txns_tbl(j).activity_id := p_ResourceTransactions(i).ActivityId;
       l_res_txns_tbl(j).activity_meaning := p_ResourceTransactions(i).Activity;
       l_res_txns_tbl(j).reason_id := p_ResourceTransactions(i).ReasonId;
       l_res_txns_tbl(j).reason := p_ResourceTransactions(i).Reason;
       l_res_txns_tbl(j).reference := p_ResourceTransactions(i).Reference;
       j := j+1;
    END IF;
  END LOOP;

  IF(l_res_txns_tbl IS NOT NULL AND l_res_txns_tbl.COUNT > 0)THEN
    IF(p_WO_DETAILS_REC.IsUpdateEnabled <> 'T')THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_RES_TXN_NALWD');
      FND_MSG_PUB.ADD;
      RAISE  FND_API.G_EXC_ERROR;
    END IF;
    AHL_PRD_RESOURCE_TRANX_PVT.process_resource_txns
    (
        p_api_version          => 1.0 ,
        p_init_msg_list        =>  FND_API.G_TRUE,
        p_commit               =>  FND_API.G_FALSE,
        p_validation_level     =>  FND_API.G_VALID_LEVEL_FULL,
        p_default              =>  FND_API.G_TRUE,
        p_module_type          =>  'BPEL',
        x_return_status        => x_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data,
        p_x_prd_resrc_txn_tbl  => l_res_txns_tbl
    );
  END IF;
END process_res_txns;

PROCEDURE process_workorder
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2,
 p_userid                IN            VARCHAR2   := NULL,
 p_WO_DETAILS_REC        IN            WO_DETAILS_REC_TYPE,
 p_Operations            IN            OP_ALL_DETAILS_TBL,
 p_TurnoverNotes         IN            TURNOVER_NOTES_TBL_TYPE,
 p_MaterialRequirementDetails  IN      MTL_REQMTS_TBL_TYPE,
 p_WO_QaResults          IN            QA_RESULTS_REC_TYPE,
 p_ResourceTransactions  IN            RES_TXNS_TBL_TYPE,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2
) IS
l_api_version      CONSTANT NUMBER := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'process_workorder';
l_WO_DETAILS_REC   WO_DETAILS_REC_TYPE;

CURSOR get_current_obj_ver_csr(p_WotkorderId IN NUMBER)IS
SELECT object_version_number FROM AHL_WORKORDERS
WHERE WORKORDER_ID = p_WotkorderId;

BEGIN

   SAVEPOINT PROCESS_WORKORDER;

   IF(p_module_type = 'BPEL') THEN
      x_return_status := init_user_and_role(p_userid);
     IF(x_return_status <> Fnd_Api.G_RET_STS_SUCCESS)THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;


   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version,l_api_name, G_PKG_NAME ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
   END IF;
  -- Initialize API return status to success

   --AHL_DEBUG_PUB.debug( 'p_WO_DETAILS_REC.WorkorderId : '||p_WO_DETAILS_REC.WorkorderId);
   --AHL_DEBUG_PUB.debug( 'p_WO_DETAILS_REC.WorkorderNumber : '||p_WO_DETAILS_REC.WorkorderNumber);
   get_workorder_details
  (
    p_module_type           => p_module_type,
    p_WorkorderId           => p_WO_DETAILS_REC.WorkorderId,
    p_WorkorderNumber       => p_WO_DETAILS_REC.WorkorderNumber,
    x_return_status         => x_return_status,
    x_msg_count             => x_msg_count,
    x_msg_data              => x_msg_data,
    x_WO_DETAILS_REC        => l_WO_DETAILS_REC
   );
   --AHL_DEBUG_PUB.debug( 'l_WO_DETAILS_REC.ObjectVersionNumber : '||l_WO_DETAILS_REC.ObjectVersionNumber);
   --AHL_DEBUG_PUB.debug( 'p_WO_DETAILS_REC.ObjectVersionNumber : '||p_WO_DETAILS_REC.ObjectVersionNumber);
   IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF(p_WO_DETAILS_REC.ObjectVersionNumber IS NULL OR
      p_WO_DETAILS_REC.ObjectVersionNumber <> l_WO_DETAILS_REC.ObjectVersionNumber)THEN
      --AHL_DEBUG_PUB.debug( 'Object Version Numbers are not same');
      FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
   process_turnover_notes(
    p_WO_DETAILS_REC        => l_WO_DETAILS_REC,
    p_TurnoverNotes         => p_TurnoverNotes,
    x_return_status         => x_return_status,
    x_msg_count             => x_msg_count,
    x_msg_data              => x_msg_data
   );

   IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   process_mtl_requirements
     (
       p_WO_DETAILS_REC         => l_WO_DETAILS_REC,
       p_MaterialRequirementDetails => p_MaterialRequirementDetails,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data
      );
   IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   process_res_txns(
    p_WO_DETAILS_REC        => l_WO_DETAILS_REC,
    p_ResourceTransactions  => p_ResourceTransactions,
    x_return_status         => x_return_status,
    x_msg_count             => x_msg_count,
    x_msg_data              => x_msg_data
   );
   IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   process_op_details(
    p_WO_DETAILS_REC        => l_WO_DETAILS_REC,
    p_Operations            => p_Operations,
    x_return_status         => x_return_status,
    x_msg_count             => x_msg_count,
    x_msg_data              => x_msg_data
    );
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
     RAISE FND_API.G_EXC_ERROR;
    END IF;

    process_wo_quality(
    p_WO_DETAILS_REC        => l_WO_DETAILS_REC,
    p_WO_QaResults          => p_WO_QaResults,
    x_return_status         => x_return_status,
    x_msg_count             => x_msg_count,
    x_msg_data              => x_msg_data
    );
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
     RAISE FND_API.G_EXC_ERROR;
    ELSE
     OPEN get_current_obj_ver_csr(l_WO_DETAILS_REC.WorkorderId);
     FETCH get_current_obj_ver_csr INTO l_WO_DETAILS_REC.ObjectVersionNumber;
     CLOSE get_current_obj_ver_csr;
    END IF;



    process_wo_details(
    p_WO_DETAILS_REC        => p_WO_DETAILS_REC,
    p_CURR_WO_DETAILS_REC   => l_WO_DETAILS_REC,
    x_return_status         => x_return_status,
    x_msg_count             => x_msg_count,
    x_msg_data              => x_msg_data
    );
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
     RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO PROCESS_WORKORDER;
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := FND_MSG_PUB.count_msg;


   x_msg_data := GET_MSG_DATA(x_msg_count);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO PROCESS_WORKORDER;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count := FND_MSG_PUB.count_msg;
   x_msg_data := GET_MSG_DATA(x_msg_count);
 WHEN OTHERS THEN
    ROLLBACK TO PROCESS_WORKORDER;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
     x_msg_count := FND_MSG_PUB.count_msg;
     x_msg_data := GET_MSG_DATA(x_msg_count);
END process_workorder;


/*PROCEDURE process_workorder_autotxns
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2,
 p_userid                IN            VARCHAR2   := NULL,
 p_WO_DETAILS_REC        IN            WO_DETAILS_REC_TYPE,
 p_Operations            IN            OP_ALL_DETAILS_TBL,
 p_TurnoverNotes         IN            TURNOVER_NOTES_TBL_TYPE,
 p_MaterialRequirementDetails  IN      MTL_REQMTS_TBL_TYPE,
 p_WO_QaResults          IN            QA_RESULTS_REC_TYPE,
 p_ResourceTransactions  IN            RES_TXNS_TBL_TYPE,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2
) IS PRAGMA AUTONOMOUS_TRANSACTION;

l_api_version      CONSTANT NUMBER := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'process_workorder_autotxns';


BEGIN

    -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version,l_api_name, G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   process_workorder_nonautotxns
   (
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => FND_API.G_FALSE,
    p_validation_level => p_validation_level,
    p_default => p_default,
    p_module_type => p_module_type,
    p_userid => p_userid,
    p_WO_DETAILS_REC => p_WO_DETAILS_REC,
    p_Operations => p_Operations,
    p_TurnoverNotes => p_TurnoverNotes,
    p_MaterialRequirementDetails => p_MaterialRequirementDetails,
    p_WO_QaResults => p_WO_QaResults,
    p_ResourceTransactions => p_ResourceTransactions,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
   );

   IF(x_return_status = Fnd_Api.G_RET_STS_SUCCESS)THEN
        COMMIT;
   ELSE
     ROLLBACK;
   END IF;



EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK;
 WHEN OTHERS THEN
    ROLLBACK;
END process_workorder_autotxns;*/

/*PROCEDURE process_workorder
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2,
 p_userid                IN            VARCHAR2   := NULL,
 p_WO_DETAILS_REC        IN            WO_DETAILS_REC_TYPE,
 p_Operations            IN            OP_ALL_DETAILS_TBL,
 p_TurnoverNotes         IN            TURNOVER_NOTES_TBL_TYPE,
 p_MaterialRequirementDetails  IN      MTL_REQMTS_TBL_TYPE,
 p_WO_QaResults          IN            QA_RESULTS_REC_TYPE,
 p_ResourceTransactions  IN            RES_TXNS_TBL_TYPE,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2
) IS
l_api_version      CONSTANT NUMBER := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'process_workorder';

BEGIN

   IF(p_module_type = 'BPEL' AND p_commit = FND_API.G_TRUE)THEN

 process_workorder_autotxns
   (
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_validation_level => p_validation_level,
    p_default => p_default,
    p_module_type => p_module_type,
    p_userid => p_userid,
    p_WO_DETAILS_REC => p_WO_DETAILS_REC,
    p_Operations => p_Operations,
    p_TurnoverNotes => p_TurnoverNotes,
    p_MaterialRequirementDetails => p_MaterialRequirementDetails,
    p_WO_QaResults => p_WO_QaResults,
    p_ResourceTransactions => p_ResourceTransactions,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
   );

   ELSE

   process_workorder_nonautotxns
   (
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_validation_level => p_validation_level,
    p_default => p_default,
    p_module_type => p_module_type,
    p_userid => p_userid,
    p_WO_DETAILS_REC => p_WO_DETAILS_REC,
    p_Operations => p_Operations,
    p_TurnoverNotes => p_TurnoverNotes,
    p_MaterialRequirementDetails => p_MaterialRequirementDetails,
    p_WO_QaResults => p_WO_QaResults,
    p_ResourceTransactions => p_ResourceTransactions,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
   );
    END IF;


END process_workorder;*/


FUNCTION GET_MSG_DATA(p_msg_count IN NUMBER) RETURN VARCHAR2 IS
l_msg_data VARCHAR2(4000);
l_temp_msg_data VARCHAR2(2000);
l_msg_index_out NUMBER;
l_msg_count NUMBER;

BEGIN
  l_msg_count := p_msg_count;
  IF (p_msg_count IS NULL)THEN
    RETURN NULL;
  END IF;
  IF (p_msg_count = 1) then
      FND_MSG_PUB.count_and_get( p_count => l_msg_count,
                               p_data  => l_temp_msg_data,
                               p_encoded => fnd_api.g_false);
     l_msg_data :=  '(' || 1 || ')' || l_temp_msg_data;
  ELSE
   IF (l_msg_count > 0) THEN
     FOR i IN 1..l_msg_count LOOP

      FND_MSG_PUB.get(
               p_encoded       => 'F',
               p_data           => l_temp_msg_data,
               p_msg_index_out  => l_msg_index_out);
       IF(i = 1)THEN
         l_msg_data :=  '(' || i || ')' ||l_msg_data || l_temp_msg_data;
       ELSE
         l_msg_data :=  l_msg_data || '(' || i || ')' || l_temp_msg_data;
       END IF;
     END LOOP;
   END IF;
  END IF;
  RETURN l_msg_data;
END GET_MSG_DATA;

FUNCTION is_valid_result_attribute(p_CharId IN NUMBER, p_QA_PLAN IN QA_PLAN_REC_TYPE) RETURN VARCHAR2
IS
l_addAttribute VARCHAR2(1);
l_enabled_flag VARCHAR2(1);

BEGIN
  l_addAttribute := 'F';
  FOR i IN p_QA_PLAN.QA_PLAN_ATR_TBL.FIRST..p_QA_PLAN.QA_PLAN_ATR_TBL.LAST LOOP
    IF(p_CharId = p_QA_PLAN.QA_PLAN_ATR_TBL(i).CharId) THEN
      IF (p_QA_PLAN.QA_PLAN_ATR_TBL(i).IsReadOnly = 'F')THEN
        l_addAttribute := 'T';
        EXIT;
      END IF;
    END IF;
  END LOOP;
  RETURN l_addAttribute;
END IS_VALID_RESULT_ATTRIBUTE;

END AHL_PRD_WO_PUB;


/
