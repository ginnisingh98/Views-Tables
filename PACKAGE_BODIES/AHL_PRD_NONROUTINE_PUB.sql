--------------------------------------------------------
--  DDL for Package Body AHL_PRD_NONROUTINE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_NONROUTINE_PUB" AS
/* $Header: AHLPPNRB.pls 120.0.12010000.4 2009/03/04 00:03:52 sikumar noship $ */
------------------------------------
-- Common constants and variables --
------------------------------------
l_log_current_level     NUMBER      := fnd_log.g_current_runtime_level;
l_log_statement         NUMBER      := fnd_log.level_statement;
l_log_procedure         NUMBER      := fnd_log.level_procedure;
l_log_error             NUMBER      := fnd_log.level_error;
l_log_unexpected        NUMBER      := fnd_log.level_unexpected;
G_DEBUG                 VARCHAR2(1)  := NVL(AHL_DEBUG_PUB.is_log_enabled,'N');


PROCEDURE POPULATE_CREATE_SR_INPUT_REC(   p_create_nr_input_rec         IN                   NON_ROUTINE_REC_TYPE,
                                          x_sr_task_rec                 OUT   NOCOPY         AHL_PRD_NONROUTINE_PVT.SR_TASK_REC_TYPE);

PROCEDURE POPULATE_CREATE_SR_OUTPUT_REC(  x_create_nr_output_rec        OUT   NOCOPY              NON_ROUTINE_REC_TYPE,
                                          p_sr_task_rec                 IN                   AHL_PRD_NONROUTINE_PVT.SR_TASK_REC_TYPE);

PROCEDURE POPULATE_CREATE_MTRL_INPUT_REC( p_matrl_reqrs_for_nr_tbl      IN                   MATERIAL_REQUIREMENTS_TBL,
                                          p_workorder_id                IN                   NUMBER,
                                          x_req_material_tbl            OUT   NOCOPY         AHL_PP_MATERIALS_PVT.Req_Material_Tbl_Type);

PROCEDURE POPULATE_CREATE_NR_INPUT_REC(   p_create_nr_input_rec         IN                   NON_ROUTINE_REC_TYPE,
                                          x_nr_task_rec                 OUT   NOCOPY         AHL_UMP_NONROUTINES_PVT.NonRoutine_Rec_Type);

PROCEDURE POPULATE_CREATE_NR_OUTPUT_REC(  x_create_nr_output_rec        OUT   NOCOPY               NON_ROUTINE_REC_TYPE,
                                          p_nr_task_rec                 IN                   AHL_UMP_NONROUTINES_PVT.NonRoutine_Rec_Type);


------------------------------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name      : CREATE_NON_ROUTINE
--  Type                : Public
--  Function            : Creates a SR either in the context of WO and adds material reqrs or creates a SR independently
--  Pre-reqs            :
--  PROCESS Parameters:
	--			p_create_non_routine_input_rec   : Parameters needed for the creation of the NR
   --       p_matrl_reqrs_for_nr_tbl         : Material requirements for the NR
	--			x_create_non_routine_output_rec	: Parameters returned after the creation of the NR
--  End of Comments.
------------------------------------------------------------------------------------------------------------------
PROCEDURE CREATE_NON_ROUTINE
   (
  		p_api_version				         IN 					NUMBER		:= 1.0,
		p_init_msg_list       	         IN 					VARCHAR2		:= FND_API.G_FALSE,
		p_commit              	         IN 					VARCHAR2 	:= FND_API.G_FALSE,
		p_validation_level    	         IN 					NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
		p_module_type				         IN						VARCHAR2,
		p_user_id                        IN              VARCHAR2:=NULL,
      p_create_nr_input_rec            IN                NON_ROUTINE_REC_TYPE,
      p_matrl_reqrs_for_nr_tbl         IN                MATERIAL_REQUIREMENTS_TBL,
      x_create_nr_output_rec           OUT      NOCOPY   NON_ROUTINE_REC_TYPE,
		x_return_status       	         OUT 		NOCOPY	VARCHAR2,
		x_msg_count           	         OUT 		NOCOPY	NUMBER,
		x_msg_data            	         OUT 		NOCOPY	VARCHAR2
   )
IS
   -- Declare local variables
   l_api_name      CONSTANT      VARCHAR2(30)      := 'CREATE_NON_ROUTINE';
   l_api_version   CONSTANT      NUMBER            := 1.0;
   l_debug_module  CONSTANT      VARCHAR2(100)     := 'AHL.PLSQL.'||'AHL_NON_ROUTINE_PUB'||'.'||'CREATE_NON_ROUTINE_NONAUTOTXNS';


   p_x_sr_task_tbl               ahl_prd_nonroutine_pvt.sr_task_tbl_type;
   p_sr_task_rec                 ahl_prd_nonroutine_pvt.sr_task_rec_type;
   x_sr_task_rec                 ahl_prd_nonroutine_pvt.sr_task_rec_type;
   x_req_material_tbl            ahl_pp_materials_pvt.req_material_tbl_type;
   x_nr_task_rec                 ahl_ump_nonroutines_pvt.nonroutine_rec_type;

   p_material_req_rec            material_requirement_rec_type;

   x_job_return_status           VARCHAR2(1);
   l_mr_asso_tbl        AHL_PRD_NONROUTINE_PVT.MR_Association_tbl_type;
BEGIN

   -- Standard start of API savepoint
   SAVEPOINT CREATE_NON_ROUTINE_SP;

   IF(p_module_type = 'BPEL') THEN
         x_return_status := AHL_PRD_WO_PUB.init_user_and_role(p_user_id);
        IF(x_return_status <> Fnd_Api.G_RET_STS_SUCCESS)THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
   END IF;


   -- Initialize return status to success before any code logic/validation
   x_return_status:= FND_API.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list = FND_API.G_TRUE
   IF FND_API.TO_BOOLEAN(p_init_msg_list)
   THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;




   -- Log API entry point
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_procedure,l_debug_module||'.begin','At the start of PL SQL procedure ');
   END IF;

   -- If the originator wo id is present
   IF( (p_create_nr_input_rec.ORIGINATOR_WORKORDER_ID IS NOT NULL AND p_create_nr_input_rec.ORIGINATOR_WORKORDER_ID <> FND_API.G_MISS_NUM)
       OR
       (p_create_nr_input_rec.ORIGINATOR_WORKORDER_NUMBER IS NOT NULL AND p_create_nr_input_rec.ORIGINATOR_WORKORDER_NUMBER <> FND_API.G_MISS_CHAR)
      )
   THEN
      -- populate the record to be passed to AHL_PRD_NONROUTINE_PVT
      POPULATE_CREATE_SR_INPUT_REC(p_create_nr_input_rec,x_sr_task_rec);
      p_x_sr_task_tbl(1) := x_sr_task_rec;

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(fnd_log.level_statement,l_debug_module,'Calling AHL_PRD_NONROUTINE_PVT.Process_nonroutine_job');
      END IF;
      -- Call the API to create the SR and workorder
      AHL_PRD_NONROUTINE_PVT.Process_nonroutine_job (
                                                      1.0,
                                                      FND_API.G_TRUE,
                                                      FND_API.G_FALSE,
                                                      FND_API.G_VALID_LEVEL_FULL,
                                                      'JSP',
                                                      x_return_status,
                                                      x_msg_count,
                                                      x_msg_data,
                                                      p_x_sr_task_tbl,
                                                      l_mr_asso_tbl
                                                     );

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(fnd_log.level_statement,l_debug_module,'After AHL_PRD_NONROUTINE_PVT.Process_nonroutine_job');
      END IF;

      IF ( upper(x_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(fnd_log.level_statement,l_debug_module,'Call to AHL_PRD_NONROUTINE_PVT.Process_nonroutine_job, Not Success');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Get the params for output
      p_sr_task_rec :=  p_x_sr_task_tbl(1);
      -- p_sr_task_rec.originating_wo_id := x_sr_task_rec.originating_wo_id;
      POPULATE_CREATE_SR_OUTPUT_REC(x_create_nr_output_rec,p_sr_task_rec);
      /* CREATE NON ROUTINE, CREATE A JOB , RELEASE THE JOB : END */

      IF (p_matrl_reqrs_for_nr_tbl.count > 0) THEN
         p_material_req_rec := p_matrl_reqrs_for_nr_tbl(p_matrl_reqrs_for_nr_tbl.FIRST);
         -- Material Requirements are considered only atleast one of id or name is present
         IF (  (p_material_req_rec.INVENTORY_ITEM_ID IS NOT NULL AND p_material_req_rec.INVENTORY_ITEM_ID <> FND_API.G_MISS_NUM )
            OR
            (p_material_req_rec.ITEM_NUMBER IS NOT NULL AND p_material_req_rec.ITEM_NUMBER <> FND_API.G_MISS_CHAR )
            )
         THEN
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(fnd_log.level_statement,l_debug_module,'Calling POPULATE_CREATE_MTRL_INPUT_REC');
            END IF;
            POPULATE_CREATE_MTRL_INPUT_REC(p_matrl_reqrs_for_nr_tbl,p_sr_task_rec.Nonroutine_wo_id,x_req_material_tbl);
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(fnd_log.level_statement,l_debug_module,'After POPULATE_CREATE_MTRL_INPUT_REC');
            END IF;
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(fnd_log.level_statement,l_debug_module,'Calling AHL_PP_MATERIALS_PVT.Create_Material_Reqst');
            END IF;

            SAVEPOINT CREATE_NON_ROUTINE_MTRLS_SP;

            AHL_PP_MATERIALS_PVT.Create_Material_Reqst (
                                    1.0,
                                    FND_API.G_TRUE,
                                    Fnd_Api.G_FALSE,
                                    FND_API.G_VALID_LEVEL_FULL,
                                    'Y',
                                    x_req_material_tbl,
                                    x_job_return_status,
                                    x_return_status,
                                    x_msg_count,
                                    x_msg_data
                                 );

            IF ( upper(x_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
               IF (l_log_statement >= l_log_current_level) THEN
                  fnd_log.string(fnd_log.level_statement,l_debug_module,'Error after AHL_PP_MATERIALS_PVT.Create_Material_Reqst');
                  ROLLBACK TO CREATE_NON_ROUTINE_MTRLS_SP;
                  FND_MESSAGE.SET_NAME ('AHL','AHL_NR_SUCC_MATRL_FAIL');
                  FND_MSG_PUB.ADD;
               END IF;
               -- RAISE FND_API.G_EXC_ERROR;
            END IF;


         ELSE
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(fnd_log.level_statement,l_debug_module,'No Materials Requirements to be added');
            END IF;
         END IF;
      END IF;
         /* ADD MATERIAL REQUIREMENTS TO THE JOB CREATED : END */
   ELSE

      POPULATE_CREATE_NR_INPUT_REC(p_create_nr_input_rec,x_nr_task_rec);
      AHL_UMP_NONROUTINES_PVT.Create_SR
               (
                  1.0,
                  FND_API.G_TRUE,
                  FND_API.G_FALSE,
                  FND_API.G_VALID_LEVEL_FULL,
                  FND_API.G_FALSE,
                  'JSP',
                  x_return_status,
                  x_msg_count,
                  x_msg_data,
                  x_nr_task_rec
               );
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(fnd_log.level_statement,l_debug_module,'After AHL_UMP_NONROUTINES_PVT.Create_SR');
      END IF;

      IF ( upper(x_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(fnd_log.level_statement,l_debug_module,'AHL_UMP_NONROUTINES_PVT.Create_SR');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      POPULATE_CREATE_NR_OUTPUT_REC(x_create_nr_output_rec,x_nr_task_rec);

      -- Added
      IF FND_API.TO_BOOLEAN(p_commit) THEN
         COMMIT WORK;
      END IF;
   END IF;

   -- Standard check of p_commit
   IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
   END IF;

   IF (G_DEBUG = 'Y') THEN
      AHL_DEBUG_PUB.debug('END - Successfully completion of '||G_PKG_NAME||'.'||l_api_name||' API ');
   END IF;

   -- Count and Get messages
   FND_MSG_PUB.count_and_get
   (  p_encoded	=> fnd_api.g_false,
      p_count	=> x_msg_count,
      p_data      => x_msg_data
   );

   -- Disable debug (if enabled)
   IF (G_DEBUG = 'Y') THEN
      AHL_DEBUG_PUB.disable_debug;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      ROLLBACK TO CREATE_NON_ROUTINE_SP;
      x_msg_count := FND_MSG_PUB.Count_Msg;
      x_msg_data := AHL_PRD_WO_PUB.GET_MSG_DATA(x_msg_count);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO CREATE_NON_ROUTINE_SP;
      x_msg_count := FND_MSG_PUB.Count_Msg;
      x_msg_data := AHL_PRD_WO_PUB.GET_MSG_DATA(x_msg_count);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO CREATE_NON_ROUTINE_SP;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.add_exc_msg
         (
            p_pkg_name     => G_PKG_NAME,
            p_procedure_name  => l_debug_module,
            p_error_text      => SUBSTR(SQLERRM,1,240)
         );
      END IF;
      x_msg_count := FND_MSG_PUB.Count_Msg;
      x_msg_data := AHL_PRD_WO_PUB.GET_MSG_DATA(x_msg_count);
END CREATE_NON_ROUTINE;

------------------------------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name      : POPULATE_CREATE_SR_INPUT_REC
--  Type                : Private
--  Function            : Populates the SR record for creation, from the params that are available
--  Pre-reqs            :
--  PROCESS Parameters:
	--			p_create_nr_input_rec   : Parameters available to CMRO
   --       x_service_request_rec   : Record which contains params that SR api needs for Creation
--  End of Comments.

------------------------------------------------------------------------------------------------------------------
PROCEDURE POPULATE_CREATE_SR_INPUT_REC(   p_create_nr_input_rec   IN     NON_ROUTINE_REC_TYPE,
                                          x_sr_task_rec           OUT NOCOPY     ahl_prd_nonroutine_pvt.sr_task_rec_type
                                 )
IS
   l_debug_module  CONSTANT      VARCHAR2(100)     := 'ahl.plsql.'||'ahl_non_routine_pub'||'.'||'populate_create_sr_input_rec';

BEGIN
   -- Log API entry point
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_procedure,l_debug_module||'.begin','At the start of PL SQL procedure ');
   END IF;

   -- If Workorder ID as well Workorder number are present, honour the id
   IF( (p_create_nr_input_rec.ORIGINATOR_WORKORDER_ID IS NOT NULL AND p_create_nr_input_rec.ORIGINATOR_WORKORDER_ID <> FND_API.G_MISS_NUM)
       and
       (p_create_nr_input_rec.ORIGINATOR_WORKORDER_NUMBER IS NOT NULL AND p_create_nr_input_rec.ORIGINATOR_WORKORDER_NUMBER <> FND_API.G_MISS_CHAR)
      )
   THEN
      x_sr_task_rec.Originating_wo_id := p_create_nr_input_rec.ORIGINATOR_WORKORDER_ID;
      BEGIN
         SELECT   csi.instance_number,vst.visit_number
         INTO     x_sr_task_rec.instance_number,x_sr_task_rec.visit_number
         FROM     ahl_workorders wo,
                  ahl_visits_b   vst,
                  ahl_visit_tasks_b tsk,
                  csi_item_instances csi
         WHERE    wo.visit_task_id  =  tsk.visit_task_id
         AND      vst.visit_id      =  tsk.visit_id
         AND      NVL(tsk.instance_id,vst.item_instance_id)=csi.instance_id
         AND      wo.workorder_id   = p_create_nr_input_rec.ORIGINATOR_WORKORDER_ID;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME ('AHL','AHL_PRD_INVLD_WO');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         WHEN TOO_MANY_ROWS THEN
            FND_MESSAGE.SET_NAME ('AHL','AHL_PRD_INVLD_WO');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
      END;
   ELSIF
      ( (p_create_nr_input_rec.ORIGINATOR_WORKORDER_ID IS NULL OR p_create_nr_input_rec.ORIGINATOR_WORKORDER_ID = FND_API.G_MISS_NUM )
         and
         (p_create_nr_input_rec.ORIGINATOR_WORKORDER_NUMBER IS NOT NULL AND p_create_nr_input_rec.ORIGINATOR_WORKORDER_NUMBER <> FND_API.G_MISS_CHAR)
      )
   THEN
      BEGIN
         SELECT   CSI.INSTANCE_NUMBER,VST.visit_number,WO.workorder_id
         INTO     x_sr_task_rec.instance_number,x_sr_task_rec.visit_number,x_sr_task_rec.Originating_wo_id
         FROM     AHL_WORKORDERS WO,
                  AHL_VISITS_B   VST,
                  AHL_VISIT_TASKS_B TSK,
                  CSI_ITEM_INSTANCES CSI
         WHERE    WO.VISIT_TASK_ID  =  TSK.VISIT_TASK_ID
         AND      VST.VISIT_ID      =  TSK.VISIT_ID
         AND      NVL(TSK.INSTANCE_ID,VST.ITEM_INSTANCE_ID)=CSI.INSTANCE_ID
         AND      WO.WORKORDER_NAME   = p_create_nr_input_rec.ORIGINATOR_WORKORDER_NUMBER;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME ('AHL','AHL_PRD_INVLD_WO');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         WHEN TOO_MANY_ROWS THEN
            FND_MESSAGE.SET_NAME ('AHL','AHL_PRD_INVLD_WO');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
      END;
   ELSE
      FND_MESSAGE.SET_NAME ('AHL','AHL_PRD_INVLD_WO');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- populate the request date
   x_sr_task_rec.request_date := p_create_nr_input_rec.service_request_date;

   -- populate the summary
   x_sr_task_rec.summary := p_create_nr_input_rec.summary;

   -- populate the operation type
   x_sr_task_rec.operation_type := 'CREATE';

   IF p_create_nr_input_rec.service_request_type <> FND_API.G_MISS_CHAR AND p_create_nr_input_rec.service_request_type IS NOT NULL  THEN
      x_sr_task_rec.Type_name := p_create_nr_input_rec.service_request_type;
   END IF;

   IF p_create_nr_input_rec.service_request_status <> FND_API.G_MISS_CHAR AND p_create_nr_input_rec.service_request_type IS NOT NULL  THEN
      x_sr_task_rec.Status_name := p_create_nr_input_rec.service_request_status;
   END IF;

   IF p_create_nr_input_rec.problem_code <> FND_API.G_MISS_CHAR AND p_create_nr_input_rec.problem_code IS NOT NULL  THEN
      x_sr_task_rec.Problem_code := p_create_nr_input_rec.problem_code;
   END IF;

   IF p_create_nr_input_rec.severity_name <> FND_API.G_MISS_CHAR AND p_create_nr_input_rec.severity_name IS NOT NULL  THEN
      x_sr_task_rec.Severity_name := p_create_nr_input_rec.severity_name;
   END IF;

   IF p_create_nr_input_rec.contact_type <> FND_API.G_MISS_CHAR AND p_create_nr_input_rec.contact_type IS NOT NULL  THEN
      x_sr_task_rec.Contact_type := p_create_nr_input_rec.contact_type;
   END IF;

  IF p_create_nr_input_rec.contact_name <> FND_API.G_MISS_CHAR AND p_create_nr_input_rec.contact_name IS NOT NULL  THEN
      x_sr_task_rec.contact_name := p_create_nr_input_rec.contact_name;
  END IF;

  IF p_create_nr_input_rec.resolution_code_meaning <> FND_API.G_MISS_CHAR AND p_create_nr_input_rec.resolution_code_meaning IS NOT NULL  THEN
      x_sr_task_rec.resolution_meaning := p_create_nr_input_rec.resolution_code_meaning;
  END IF;

  IF p_create_nr_input_rec.estimated_duration <> fnd_api.g_miss_num AND p_create_nr_input_rec.estimated_duration IS NOT NULL  THEN
      x_sr_task_rec.duration := p_create_nr_input_rec.estimated_duration;
  END IF;


   -- Log API exit point
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_procedure,l_debug_module||'.end','At the start of PL SQL procedure ');
   END IF;
END   POPULATE_CREATE_SR_INPUT_REC;

-----------------------------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name      : POPULATE_CREATE_MTRL_INPUT_REC
--  Type                : Private
--  Function            : Populates the material requirements
--  Pre-reqs            :
--  PROCESS Parameters:
	--			p_matrl_reqrs_for_nr_tbl  : Material reqrmts to be created
   --       p_workorder_id            : ID of the just created WO
   --       x_req_material_tbl        : Parameters to be passed to the caller
--  End of Comments.
------------------------------------------------------------------------------------------------------------------
PROCEDURE POPULATE_CREATE_MTRL_INPUT_REC( p_matrl_reqrs_for_nr_tbl      IN                   MATERIAL_REQUIREMENTS_TBL,
                                          p_workorder_id                IN                   NUMBER,
                                          x_req_material_tbl            OUT   NOCOPY         AHL_PP_MATERIALS_PVT.Req_Material_Tbl_Type)
IS
   l_debug_module  CONSTANT      VARCHAR2(100)     := 'ahl.plsql.'||'ahl_non_routine_pub'||'.'||'populate_create_mtrl_input_rec';
BEGIN
   -- Log API entry point
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_procedure,l_debug_module||'.Begin','At the start of PL SQL procedure ');
   END IF;
   IF p_matrl_reqrs_for_nr_tbl.COUNT > 0 THEN
      FOR i IN p_matrl_reqrs_for_nr_tbl.FIRST..p_matrl_reqrs_for_nr_tbl.LAST
      LOOP
         x_req_material_tbl(i).WORKORDER_ID        := p_workorder_id;
         x_req_material_tbl(i).OPERATION_SEQUENCE     := 10;
         x_req_material_tbl(i).INVENTORY_ITEM_ID      := NULL;
         x_req_material_tbl(i).CONCATENATED_SEGMENTS  := p_matrl_reqrs_for_nr_tbl(i).ITEM_NUMBER;
         x_req_material_tbl(i).ITEM_DESCRIPTION       := p_matrl_reqrs_for_nr_tbl(i).ITEM_DESCRIPTION;
         x_req_material_tbl(i).REQUESTED_QUANTITY     := p_matrl_reqrs_for_nr_tbl(i).REQUIRED_QUANTITY;
         x_req_material_tbl(i).UOM_CODE               := p_matrl_reqrs_for_nr_tbl(i).PART_UOM;
         x_req_material_tbl(i).REQUESTED_DATE         := p_matrl_reqrs_for_nr_tbl(i).REQUIRED_DATE;
      END LOOP;
   END IF;
   -- Log API exit point
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_procedure,l_debug_module||'.End','At the end of PL SQL procedure ');
   END IF;
END POPULATE_CREATE_MTRL_INPUT_REC;

------------------------------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name      : POPULATE_CREATE_NR_INPUT_REC
--  Type                : Private
--  Function            : Populates the params for Creating a NR
--  Pre-reqs            :
--  PROCESS Parameters:
	--			p_create_nr_input_rec  : Parameters for the creation of NR obtained from the caller
   --       x_nr_task_rec          : Parameters to be passed for the creation of the NR
--  End of Comments.
------------------------------------------------------------------------------------------------------------------
PROCEDURE POPULATE_CREATE_NR_INPUT_REC(   p_create_nr_input_rec   IN             NON_ROUTINE_REC_TYPE,
                                          x_nr_task_rec           OUT  NOCOPY          AHL_UMP_NONROUTINES_PVT.NonRoutine_Rec_Type
                                 )
IS
   l_debug_module  CONSTANT      VARCHAR2(100)     := 'ahl.plsql.'||'ahl_non_routine_pub'||'.'||'POPULATE_CREATE_NR_INPUT_REC';
   l_unit_name          VARCHAR2(80);

   CURSOR get_instance_details(p_unit_name VARCHAR2)
   IS
      SELECT   instance_number,
               serial_number
      FROM     csi_item_instances csi,
               ahl_unit_config_headers uch
      WHERE    uch.name = p_unit_name
      AND      uch.csi_item_instance_id = csi.instance_id;
BEGIN
   -- Log API entry point
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_procedure,l_debug_module||'.begin','At the start of PL SQL procedure ');
   END IF;
   -- populate the request date
   x_nr_task_rec.INCIDENT_DATE   := p_create_nr_input_rec.service_request_date;
   -- populate the summary
   x_nr_task_rec.PROBLEM_SUMMARY := p_create_nr_input_rec.summary;
   -- populate the instance number
   OPEN  get_instance_details(p_create_nr_input_rec.unit_name);
   FETCH get_instance_details INTO x_nr_task_rec.instance_number,x_nr_task_rec.serial_number;
   IF get_instance_details%NOTFOUND THEN
      CLOSE get_instance_details;
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_UNIT_INVALID');
      FND_MESSAGE.Set_Token('NAME',p_create_nr_input_rec.unit_name);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE get_instance_details;

   IF p_create_nr_input_rec.service_request_type <> FND_API.G_MISS_CHAR AND p_create_nr_input_rec.service_request_type IS NOT NULL  THEN
      x_nr_task_rec.TYPE_NAME := p_create_nr_input_rec.service_request_type;
   END IF;

   IF p_create_nr_input_rec.service_request_status <> FND_API.G_MISS_CHAR AND p_create_nr_input_rec.service_request_type IS NOT NULL  THEN
      x_nr_task_rec.status_name := p_create_nr_input_rec.service_request_status;
   END IF;

   IF p_create_nr_input_rec.problem_code <> FND_API.G_MISS_CHAR AND p_create_nr_input_rec.problem_code IS NOT NULL  THEN
      x_nr_task_rec.problem_code := p_create_nr_input_rec.problem_code;
   END IF;

   IF p_create_nr_input_rec.severity_name <> FND_API.G_MISS_CHAR AND p_create_nr_input_rec.severity_name IS NOT NULL  THEN
      x_nr_task_rec.severity_name := p_create_nr_input_rec.severity_name;
   END IF;

   IF p_create_nr_input_rec.contact_type <> FND_API.G_MISS_CHAR AND p_create_nr_input_rec.contact_type IS NOT NULL  THEN
      x_nr_task_rec.contact_type := p_create_nr_input_rec.contact_type;
   END IF;

  IF p_create_nr_input_rec.contact_name <> FND_API.G_MISS_CHAR AND p_create_nr_input_rec.contact_name IS NOT NULL  THEN
      x_nr_task_rec.contact_name := p_create_nr_input_rec.contact_name;
  END IF;

  IF p_create_nr_input_rec.resolution_code_meaning <> FND_API.G_MISS_CHAR AND p_create_nr_input_rec.resolution_code_meaning IS NOT NULL  THEN
      x_nr_task_rec.resolution_meaning := p_create_nr_input_rec.resolution_code_meaning;
  END IF;

   -- Log API exit point
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_procedure,l_debug_module||'.end','At the end of PL SQL procedure ');
   END IF;
END   POPULATE_CREATE_NR_INPUT_REC;


------------------------------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name      : POPULATE_CREATE_NR_OUTPUT_REC
--  Type                : Private
--  Function            : Populates the NR output record
--  Pre-reqs            :
--  PROCESS Parameters:
	--			x_create_nr_output_rec   : Parameters to be passed to the caller
   --       p_nr_task_rec            : Record which contains params obtained after SR creation
--  End of Comments.

------------------------------------------------------------------------------------------------------------------
PROCEDURE POPULATE_CREATE_NR_OUTPUT_REC(  x_create_nr_output_rec        OUT NOCOPY  NON_ROUTINE_REC_TYPE,
                                          p_nr_task_rec                 IN    AHL_UMP_NONROUTINES_PVT.NonRoutine_Rec_Type)
IS
   l_debug_module  CONSTANT      VARCHAR2(100)     := 'ahl.plsql.'||'ahl_non_routine_pub'||'.'||'populate_create_nr_output_rec';
BEGIN
   -- Log API entry point
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_procedure,l_debug_module||'.begin','At the start of PL SQL procedure ');
   END IF;

   -- Populate the OUT params
   x_create_nr_output_rec.SERVICE_REQUEST_ID                := p_nr_task_rec.INCIDENT_ID;
   x_create_nr_output_rec.SUMMARY                           := p_nr_task_rec.PROBLEM_SUMMARY;
   x_create_nr_output_rec.SERVICE_REQUEST_DATE              := p_nr_task_rec.INCIDENT_DATE;

   x_create_nr_output_rec.CONTACT_TYPE                      := p_nr_task_rec.CONTACT_TYPE;
   x_create_nr_output_rec.CONTACT_ID                        := p_nr_task_rec.CONTACT_ID;
   x_create_nr_output_rec.CONTACT_NAME                      := p_nr_task_rec.CONTACT_NAME;
   x_create_nr_output_rec.SERVICE_REQUEST_STATUS            := p_nr_task_rec.STATUS_NAME;
   x_create_nr_output_rec.SEVERITY_ID                       := p_nr_task_rec.SEVERITY_ID;
   x_create_nr_output_rec.SEVERITY_NAME                     := p_nr_task_rec.SEVERITY_NAME;
   x_create_nr_output_rec.URGENCY_ID                        := p_nr_task_rec.URGENCY_ID;
   x_create_nr_output_rec.URGENCY_NAME                      := p_nr_task_rec.URGENCY_NAME;
   x_create_nr_output_rec.ATA_CODE                          := p_nr_task_rec.ATA_CODE;
   x_create_nr_output_rec.UNIT_NAME                         := p_nr_task_rec.UNIT_NAME;
   x_create_nr_output_rec.ITEM_NUMBER                       := p_nr_task_rec.ITEM_NUMBER;
   x_create_nr_output_rec.SERIAL_NUMBER                     := p_nr_task_rec.SERIAL_NUMBER;
   x_create_nr_output_rec.INSTANCE_NUMBER                   := p_nr_task_rec.INSTANCE_NUMBER;
   x_create_nr_output_rec.PARTY_ID                          := p_nr_task_rec.CUSTOMER_ID;
   x_create_nr_output_rec.PARTY_NAME                        := p_nr_task_rec.CUSTOMER_NAME;
   x_create_nr_output_rec.CONTACT_TYPE_CODE                 := p_nr_task_rec.CONTACT_TYPE;

   x_create_nr_output_rec.POSITION                          := NULL;
   x_create_nr_output_rec.POSITION_ID                       := NULL;
   x_create_nr_output_rec.LOT_NUMBER                        := NULL;

   x_create_nr_output_rec.ESTIMATED_DURATION                := NULL;
   x_create_nr_output_rec.ESTIMATED_DURATION_UOM            := NULL;
   x_create_nr_output_rec.REPORT_BY_TYPE                    := NULL;
   x_create_nr_output_rec.REPORT_TYPE_CODE                  := NULL;
   x_create_nr_output_rec.REPORT_TYPE                       := NULL;


      -- Populate the  problem,resolution codes and meanings
   BEGIN
      SELECT   CS.PROBLEM_CODE,FLVT.MEANING,CS.RESOLUTION_CODE ,FLVT1.MEANING
      INTO     x_create_nr_output_rec.problem_code,
               x_create_nr_output_rec.problem_code_meaning,
               x_create_nr_output_rec.resolution_code,
               x_create_nr_output_rec.resolution_code_meaning
      FROM     cs_incidents_all_b CS,
               FND_LOOKUP_VALUES FLVT,
               FND_LOOKUP_VALUES FLVT1
      WHERE    FLVT.LOOKUP_TYPE(+) = 'REQUEST_PROBLEM_CODE'
      AND      FLVT.LOOKUP_CODE(+) = CS.PROBLEM_CODE
      AND      FLVT1.LOOKUP_TYPE(+) = 'REQUEST_RESOLUTION_CODE'
      AND      FLVT1.LOOKUP_CODE(+) = CS.RESOLUTION_CODE
      AND      FLVT.LANGUAGE(+) = userenv('LANG')
      AND      FLVT1.LANGUAGE(+) = userenv('LANG')
      AND      incident_id = p_nr_task_rec.INCIDENT_ID;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

	BEGIN
      SELECT	sts.status_code,sts.name
      INTO	   x_create_nr_output_rec.service_request_status_code,x_create_nr_output_rec.service_request_status
      FROM		cs_incidents_all_b CS,CS_INCIDENT_STATUSES_B sts
      WHERE		cs.incident_id = p_nr_task_rec.INCIDENT_ID
      AND      sts.INCIDENT_STATUS_ID = cs.incident_Status_id;
	EXCEPTION
		WHEN OTHERS THEN
		NULL;
	END;

	BEGIN
      SELECT	name,incident_subtype
      INTO     x_create_nr_output_rec.SERVICE_REQUEST_TYPE,x_create_nr_output_rec.SERVICE_REQUEST_TYPE_CODE
      FROM     cs_incidents_all_b CS,cs_incident_types_vl
      WHERE    cs.incident_id = p_nr_task_rec.INCIDENT_ID
      AND      cs.incident_type_id = cs_incident_types_vl.incident_type_id;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   BEGIN
      SELECT	mtl.concatenated_segments,csi.serial_number
      INTO		x_create_nr_output_rec.item_number,x_create_nr_output_rec.serial_number
      FROm		csi_item_instances csi, mtl_system_items_kfv mtl,cs_incidents_all_b cs
      WHERE		csi.instance_id         = cs.customer_product_id
      and		csi.inventory_item_id   = mtl.inventory_item_id
      and		mtl.organization_id     = csi.inv_master_organization_id
      AND      cs.incident_id          = p_nr_task_rec.incident_id;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   BEGIN
      SELECT   ahl_util_uc_pkg.get_unit_name(cs.customer_product_id)
      INTO     x_create_nr_output_rec.unit_name
      FROM	   cs_incidents_all_b cs
      WHERE    cs.incident_id = p_nr_task_rec.incident_id;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   BEGIN
      SELECT	name
      INTO		x_create_nr_output_rec.SEVERITY_NAME
      FROM		cs_incident_severities_vl
      WHERE		incident_severity_id  = p_nr_task_rec.severity_id;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;
   -- Log API exit point
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_procedure,l_debug_module||'.end','At the end of PL SQL procedure ');
   END IF;
END POPULATE_CREATE_NR_OUTPUT_REC;

------------------------------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name      : POPULATE_CREATE_SR_OUTPUT_REC
--  Type                : Private
--  Function            : Populates the SR output record
--  Pre-reqs            :
--  PROCESS Parameters:
	--			x_create_nr_output_rec   : Parameters to be passed to the caller
   --       p_sr_task_rec            : Record which contains params after SR creation
--  End of Comments.

------------------------------------------------------------------------------------------------------------------
PROCEDURE POPULATE_CREATE_SR_OUTPUT_REC(  x_create_nr_output_rec OUT NOCOPY NON_ROUTINE_REC_TYPE,
                                          p_sr_task_rec          IN  AHL_PRD_NONROUTINE_PVT.SR_TASK_REC_TYPE)
IS
   l_debug_module  CONSTANT      VARCHAR2(100)     := 'ahl.plsql.'||'ahl_non_routine_pub'||'.'||'populate_create_sr_output_rec';
BEGIN
   -- Log API start point
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_procedure,l_debug_module||'.begin','At the start of PL SQL procedure ');
   END IF;

   x_create_nr_output_rec.SERVICE_REQUEST_ID := p_sr_task_rec.Incident_id;
   -- Populate the OUT params
   x_create_nr_output_rec.SERVICE_REQUEST_TYPE              := p_sr_task_rec.type_name;
   x_create_nr_output_rec.SUMMARY                           := p_sr_task_rec.summary;
   x_create_nr_output_rec.CONTACT_TYPE                      := p_sr_task_rec.contact_type;
   x_create_nr_output_rec.CONTACT_ID                        := p_sr_task_rec.contact_id;
   x_create_nr_output_rec.CONTACT_NAME                      := p_sr_task_rec.contact_name;
   x_create_nr_output_rec.SERVICE_REQUEST_DATE              := p_sr_task_rec.request_date;
   x_create_nr_output_rec.SERVICE_REQUEST_STATUS            := p_sr_task_rec.status_name;
   x_create_nr_output_rec.SEVERITY_ID                       := p_sr_task_rec.severity_id;
   x_create_nr_output_rec.URGENCY_ID                        := p_sr_task_rec.urgency_id;
   x_create_nr_output_rec.URGENCY_NAME                      := p_sr_task_rec.urgency_name;
   x_create_nr_output_rec.ATA_CODE                          := NULL;
   x_create_nr_output_rec.INSTANCE_NUMBER                   := p_sr_task_rec.instance_number;
   x_create_nr_output_rec.PARTY_ID                          := p_sr_task_rec.customer_id;
   x_create_nr_output_rec.PARTY_NAME                        := p_sr_task_rec.customer_name;
   x_create_nr_output_rec.CONTACT_TYPE_CODE                 := p_sr_task_rec.contact_type;

   x_create_nr_output_rec.POSITION                          := NULL;
   x_create_nr_output_rec.POSITION_ID                       := NULL;
   x_create_nr_output_rec.LOT_NUMBER                        := NULL;

   x_create_nr_output_rec.ESTIMATED_DURATION                := p_sr_task_rec.Duration;
   x_create_nr_output_rec.ESTIMATED_DURATION_UOM            := NULL;
   x_create_nr_output_rec.REPORT_BY_TYPE                    := NULL;
   x_create_nr_output_rec.REPORT_TYPE_CODE                  := NULL;
   x_create_nr_output_rec.REPORT_TYPE                       := NULL;

   x_create_nr_output_rec.WORKORDER_ID                      := p_sr_task_rec.Nonroutine_wo_id;
   x_create_nr_output_rec.VISIT_ID                          := p_sr_task_rec.visit_id;
   x_create_nr_output_rec.VISIT_NUMBER                      := p_sr_task_rec.visit_number;
   x_create_nr_output_rec.RELEASE_NON_ROUTINE_WORKORDER     := p_sr_task_rec.wo_release_flag;

	x_create_nr_output_rec.originator_workorder_id := p_sr_task_rec.ORIGINATING_WO_ID;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_statement,l_debug_module,'Populating workorder_number, p_sr_task_rec.Nonroutine_wo_id:' || p_sr_task_rec.Nonroutine_wo_id);
   END IF;
	BEGIN
		/*SELECT	workorder_name
		INTO		x_create_nr_output_rec.WORKORDER_NUMBER
		FROM		ahl_workorders
		WHERE		workorder_id = p_sr_task_rec.Nonroutine_wo_id;*/

		SELECT  WO.workorder_id,WO.workorder_name
		INTO    x_create_nr_output_rec.WORKORDER_ID,x_create_nr_output_rec.WORKORDER_NUMBER
		FROM    AHL_WORKORDERS WO,AHL_WORKORDERS WO1,
		        WIP_SCHED_RELATIONSHIPS WOR
		WHERE   WOR.parent_object_id = WO1.wip_entity_id
		AND     WOR.child_object_id = WO.wip_entity_id
		AND     WO.master_workorder_flag = 'N'
		AND     WO.status_code <> '22'
		AND     WOR.parent_object_type_id = 1
		AND     wo1.workorder_id = p_sr_task_rec.Nonroutine_wo_id
                AND rownum < 2;
   EXCEPTION
		WHEN OTHERS THEN
			NULL;
   END;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_statement,l_debug_module,'Populating Originator Details, WO id :' || p_sr_task_rec.ORIGINATING_WO_ID );
   END IF;
   BEGIN
      SELECT   workorder_name,vst.visit_id,visit_number,visit_task_id
      INTO     x_create_nr_output_rec.ORIGINATOR_WORKORDER_NUMBER,
               x_create_nr_output_rec.ORIGINATOR_VISIT_ID,
               x_create_nr_output_rec.ORIGINATOR_VISIT_NUMBER,
               x_create_nr_output_rec.ORIGINATOR_TASK
      FROM     ahl_workorders,
               ahl_visits_b vst
      WHERE    workorder_id = p_sr_task_rec.ORIGINATING_WO_ID
      AND      vst.visit_id =  ahl_workorders.visit_id(+);
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_statement,l_debug_module,'Populating Prob, Res Codes, SERVICE_REQUEST_ID:' || x_create_nr_output_rec.service_request_id );
   END IF;
   -- Populate the  problem,resolution codes and meanings
   BEGIN
      SELECT   CS.PROBLEM_CODE,FLVT.MEANING,CS.RESOLUTION_CODE ,FLVT1.MEANING
      INTO     x_create_nr_output_rec.problem_code,
               x_create_nr_output_rec.problem_code_meaning,
               x_create_nr_output_rec.resolution_code,
               x_create_nr_output_rec.resolution_code_meaning
      FROM     cs_incidents_all_b CS,
               FND_LOOKUP_VALUES FLVT,
               FND_LOOKUP_VALUES FLVT1
      WHERE    FLVT.LOOKUP_TYPE(+) = 'REQUEST_PROBLEM_CODE'
      AND      FLVT.LOOKUP_CODE(+) = CS.PROBLEM_CODE
      AND      FLVT1.LOOKUP_TYPE(+) = 'REQUEST_RESOLUTION_CODE'
      AND      FLVT1.LOOKUP_CODE(+) = CS.RESOLUTION_CODE
      AND      FLVT.LANGUAGE(+) = userenv('LANG')
      AND      FLVT1.LANGUAGE(+) = userenv('LANG')
      AND      incident_id = x_create_nr_output_rec.SERVICE_REQUEST_ID;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_statement,l_debug_module,'Populating status_code, Status_id:' || p_sr_task_rec.Status_id);
   END IF;
   BEGIN
      SELECT	status_code
      INTO		x_create_nr_output_rec.SERVICE_REQUEST_STATUS_CODE
      FROM		CS_INCIDENT_STATUSES_B
      WHERE		INCIDENT_STATUS_ID = p_sr_task_rec.Status_id;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_statement,l_debug_module,'Populating status_code, Status_id:' || p_sr_task_rec.Status_id);
   END IF;
		BEGIN
			SELECT	incident_subtype
			INTO		x_create_nr_output_rec.SERVICE_REQUEST_TYPE_CODE
			FROM		cs_incident_types_vl
			WHERE		incident_Type_id = p_sr_task_rec.type_id;
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_statement,l_debug_module,'Populating ITEM_NUMBER,SERIAL_NUMBER instance_id:' || p_sr_task_rec.instance_id);
   END IF;
   BEGIN
		SELECT	mtl.concatenated_segments,csi.serial_number
		INTO		x_create_nr_output_rec.ITEM_NUMBER,x_create_nr_output_rec.SERIAL_NUMBER
		FROm		csi_item_instances csi, mtl_system_items_kfv mtl
		WHERE		csi.instance_id = p_sr_task_rec.instance_id
		and			csi.inventory_item_id = mtl.inventory_item_id
		and			mtl.organization_id = csi.INV_MASTER_ORGANIZATION_ID;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
	END;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_statement,l_debug_module,'Populating unit_name, instance_id:' || p_sr_task_rec.instance_id);
   END IF;
	BEGIN
		SELECT   AHL_UTIL_UC_PKG.get_unit_name(p_sr_task_rec.instance_id)
	   INTO		x_create_nr_output_rec.UNIT_NAME
		FROM		DUAL;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
	END;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_statement,l_debug_module,'Populating severity_name, severity_id:' || p_sr_task_rec.severity_id);
   END IF;
   BEGIN
      SELECT	name
      INTO		x_create_nr_output_rec.SEVERITY_NAME
      FROM		cs_incident_severities_vl
      WHERE		incident_severity_id  = p_sr_task_rec.severity_id;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_procedure,l_debug_module,'After populating.......');
   END IF;

   -- Log API exit point
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(fnd_log.level_procedure,l_debug_module||'.end','At the end of PL SQL procedure ');
   END IF;
END POPULATE_CREATE_SR_OUTPUT_REC;

/*PROCEDURE CREATE_NON_ROUTINE_AUTOTXNS
   (
  		p_api_version		IN 	NUMBER		:= 1.0,
		p_init_msg_list       	IN 	VARCHAR2		:= FND_API.G_FALSE,
		p_validation_level    	IN 	NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
		p_module_type		IN	VARCHAR2,
		p_user_id              IN       VARCHAR2:=NULL,
                p_create_nr_input_rec            IN       NON_ROUTINE_REC_TYPE,
                p_matrl_reqrs_for_nr_tbl         IN       MATERIAL_REQUIREMENTS_TBL,
                x_create_nr_output_rec           OUT      NOCOPY   NON_ROUTINE_REC_TYPE,
		x_return_status       	         OUT 		NOCOPY	VARCHAR2,
		x_msg_count           	         OUT 		NOCOPY	NUMBER,
		x_msg_data            	         OUT 		NOCOPY	VARCHAR2
   )
IS PRAGMA AUTONOMOUS_TRANSACTION;

l_api_version      CONSTANT NUMBER := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'CREATE_NON_ROUTINE_AUTOTXNS';


BEGIN

       -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version,l_api_name, G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

      CREATE_NON_ROUTINE_NONAUTOTXNS
      (
        p_api_version => p_api_version,
       	p_init_msg_list => p_init_msg_list,
       	p_commit    =>   FND_API.G_FALSE,
       	p_validation_level  => p_validation_level,
       	p_module_type	=> p_module_type,
       	p_user_id   =>  p_user_id,
        p_create_nr_input_rec => p_create_nr_input_rec,
        p_matrl_reqrs_for_nr_tbl =>  p_matrl_reqrs_for_nr_tbl,
        x_create_nr_output_rec  => x_create_nr_output_rec,
        x_return_status   => x_return_status,
       	x_msg_count   => x_msg_count,
	      x_msg_data   => x_msg_data
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
END CREATE_NON_ROUTINE_AUTOTXNS;*/


------------------------------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name      : CREATE_NON_ROUTINE
--  Type                : Public
--  Function            : Creates a SR either in the context of WO and adds material reqrs or creates a SR independently
--  Pre-reqs            :
--  PROCESS Parameters:
	--			p_create_non_routine_input_rec   : Parameters needed for the creation of the NR
   --       p_matrl_reqrs_for_nr_tbl         : Material requirements for the NR
	--			x_create_non_routine_output_rec	: Parameters returned after the creation of the NR
--  End of Comments.
------------------------------------------------------------------------------------------------------------------
/*PROCEDURE CREATE_NON_ROUTINE
   (
  		p_api_version		IN 	NUMBER		:= 1.0,
		p_init_msg_list       	IN 	VARCHAR2		:= FND_API.G_FALSE,
		p_commit              	IN 	VARCHAR2 	:= FND_API.G_FALSE,
		p_validation_level    	IN 	NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
		p_module_type		IN	VARCHAR2,
		p_user_id              IN       VARCHAR2:=NULL,
                p_create_nr_input_rec            IN       NON_ROUTINE_REC_TYPE,
                p_matrl_reqrs_for_nr_tbl         IN       MATERIAL_REQUIREMENTS_TBL,
                x_create_nr_output_rec           OUT      NOCOPY   NON_ROUTINE_REC_TYPE,
		x_return_status       	         OUT 		NOCOPY	VARCHAR2,
		x_msg_count           	         OUT 		NOCOPY	NUMBER,
		x_msg_data            	         OUT 		NOCOPY	VARCHAR2
   )
IS
BEGIN
   IF(p_module_type = 'BPEL' AND p_commit = FND_API.G_TRUE)THEN

    CREATE_NON_ROUTINE_AUTOTXNS
      (
        p_api_version => p_api_version,
       	p_init_msg_list => p_init_msg_list,
       	p_validation_level  => p_validation_level,
       	p_module_type	=> p_module_type,
       	p_user_id   =>  p_user_id,
        p_create_nr_input_rec => p_create_nr_input_rec,
        p_matrl_reqrs_for_nr_tbl =>  p_matrl_reqrs_for_nr_tbl,
        x_create_nr_output_rec  => x_create_nr_output_rec,
        x_return_status   => x_return_status,
       	x_msg_count   => x_msg_count,
	      x_msg_data   => x_msg_data
      );

   ELSE

      CREATE_NON_ROUTINE_NONAUTOTXNS
      (
        p_api_version => p_api_version,
       	p_init_msg_list => p_init_msg_list,
       	p_commit    =>   p_commit,
       	p_validation_level  => p_validation_level,
       	p_module_type	=> p_module_type,
       	p_user_id   =>  p_user_id,
        p_create_nr_input_rec => p_create_nr_input_rec,
        p_matrl_reqrs_for_nr_tbl =>  p_matrl_reqrs_for_nr_tbl,
        x_create_nr_output_rec  => x_create_nr_output_rec,
        x_return_status   => x_return_status,
       	x_msg_count   => x_msg_count,
	      x_msg_data   => x_msg_data
      );
    END IF;

END CREATE_NON_ROUTINE;*/

END AHL_PRD_NONROUTINE_PUB;

/
