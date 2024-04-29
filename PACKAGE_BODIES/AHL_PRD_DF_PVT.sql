--------------------------------------------------------
--  DDL for Package Body AHL_PRD_DF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_DF_PVT" AS
/* $Header: AHLVPDFB.pls 120.17.12010000.6 2010/04/05 07:01:17 manisaga ship $ */
  -- Package/App Name
  G_PKG_NAME         CONSTANT  VARCHAR(30) := 'AHL_PRD_DF_PVT';
  G_APP_NAME         CONSTANT  VARCHAR2(3) := 'AHL';

  G_OP_SUBMIT_FOR_APPROVAL BOOLEAN := false;
  G_MODULE_TYPE VARCHAR2(30) := 'JSP';

  -- job statuses
  G_JOB_UNRELEASED      CONSTANT VARCHAR2(30) := '1';
  G_JOB_RELEASED        CONSTANT VARCHAR2(30) := '3';
  G_JOB_CLOSED          CONSTANT VARCHAR2(30) := '12';
  G_JOB_DRAFT           CONSTANT VARCHAR2(30) := '17';
  G_JOB_PARTS_HOLD      CONSTANT VARCHAR2(30) := '19';
  G_JOB_COMPLETE        CONSTANT VARCHAR2(30) := '4';
  G_JOB_COMPLETE_NC     CONSTANT VARCHAR2(30) := '5';
  G_JOB_ON_HOLD         CONSTANT VARCHAR2(30) := '6';
  G_JOB_CANCELLED       CONSTANT VARCHAR2(30) := '7';
  G_JOB_PEND_DFR_APPR   CONSTANT VARCHAR2(30) := '21';
  G_JOB_PEND_QA_APPR    CONSTANT VARCHAR2(20) := '20';
  G_JOB_DELETED         CONSTANT VARCHAR2(30) := '22';

  -- approval actions
  G_DEFERRAL_INITIATED  CONSTANT VARCHAR2(1) := 'I';
  G_DEFERRAL_REJECTED   CONSTANT VARCHAR2(1) := 'R';
  G_DEFERRAL_APPROVED   CONSTANT VARCHAR2(1) := 'A';
  G_DEFERRAL_ERROR      CONSTANT VARCHAR2(1) := 'E';

------------------------------------------------------------------------------------
-- Declare Procedures --
------------------------------------------------------------------------------------
-- Internal procedure that this API uses For procedures defined in specs of this API
------------------------------------------------------------------------------------
PROCEDURE process_df_header(
    p_x_df_header_rec       IN OUT NOCOPY  AHL_PRD_DF_PVT.df_header_rec_type);

PROCEDURE log_df_header(
    p_df_header_rec       IN AHL_PRD_DF_PVT.df_header_rec_type);

PROCEDURE validate_df_header(
    p_df_header_rec       IN AHL_PRD_DF_PVT.df_header_rec_type);

PROCEDURE validate_reason_codes(
    p_defer_reason_code       IN VARCHAR2);

PROCEDURE default_unchanged_df_header(
    p_x_df_header_rec       IN OUT NOCOPY  AHL_PRD_DF_PVT.df_header_rec_type);

PROCEDURE process_df_schedules(
    p_df_header_rec       IN             AHL_PRD_DF_PVT.df_header_rec_type,
    p_x_df_schedules_tbl    IN OUT NOCOPY  AHL_PRD_DF_PVT.df_schedules_tbl_type);

PROCEDURE log_df_schedules(
    p_df_schedules_tbl    IN             AHL_PRD_DF_PVT.df_schedules_tbl_type);

PROCEDURE validate_df_schedules(
    p_df_header_rec       IN             AHL_PRD_DF_PVT.df_header_rec_type,
    p_df_schedules_tbl    IN             AHL_PRD_DF_PVT.df_schedules_tbl_type);

PROCEDURE default_unchanged_df_schedules(
    p_x_df_schedules_tbl    IN OUT NOCOPY  AHL_PRD_DF_PVT.df_schedules_tbl_type);

PROCEDURE validate_deferral_updates(
    p_df_header_rec       IN             AHL_PRD_DF_PVT.df_header_rec_type,
    x_warning_msg_data            OUT NOCOPY VARCHAR2);

/* R12: moved to spec.
PROCEDURE process_approval_initiated (
    p_unit_deferral_id      IN             NUMBER,
    p_object_version_number IN             NUMBER,
    p_new_status            IN             VARCHAR2,
    x_return_status         OUT NOCOPY     VARCHAR2);
*/

PROCEDURE submit_for_approval(
    p_df_header_rec       IN             AHL_PRD_DF_PVT.df_header_rec_type);

FUNCTION valid_for_submission(
    p_unit_effectivity_id   IN             NUMBER) RETURN BOOLEAN;

FUNCTION get_applicable_ue(p_unit_effectivity_id IN NUMBER)RETURN NUMBER;

PROCEDURE process_workorders(
         p_unit_deferral_id      IN             NUMBER,
         p_object_version_number IN             NUMBER,
         p_approval_result_code  IN             VARCHAR2,
         x_return_status         OUT NOCOPY     VARCHAR2);

PROCEDURE process_unit_maint_plan(
         p_unit_deferral_id      IN             NUMBER,
         p_object_version_number IN             NUMBER,
         p_approval_result_code  IN             VARCHAR2,
         p_new_status            IN             VARCHAR2,
         x_return_status         OUT NOCOPY     VARCHAR2);

PROCEDURE process_prior_ump_deferrals(
          p_unit_effectivity_id  IN             NUMBER);

PROCEDURE calculate_due_date(
  x_return_status               OUT NOCOPY VARCHAR2,
  p_csi_item_instance_id 	    IN	NUMBER);


FUNCTION getLastStatus(p_workorder_id IN NUMBER) RETURN VARCHAR2;

FUNCTION isValidStatusUpdate(
         operation_code VARCHAR2,
         status_code    VARCHAR2)RETURN BOOLEAN;

-- function to check if source of deferral is UMP or Production.
FUNCTION Is_UMP_Deferral(p_unit_deferral_id IN NUMBER) RETURN BOOLEAN;


-- ------------------------------------------------------------------------------------------------
--  Procedure name    : process_deferral
--  Type              : private
--  Function          :
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
--  process_deferral Parameters:
--
--
--
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.

PROCEDURE process_deferral(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := NULL,
    p_x_df_header_rec       IN OUT NOCOPY  AHL_PRD_DF_PVT.df_header_rec_type,
    p_x_df_schedules_tbl    IN OUT NOCOPY  AHL_PRD_DF_PVT.df_schedules_tbl_type,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2) IS

    l_api_version      CONSTANT NUMBER := 1.0;
    l_api_name         CONSTANT VARCHAR2(30) := 'process_deferral';
    l_return_status  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_warning_msg_data VARCHAR2(4000);

BEGIN
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.process_deferral.begin',
			'At the start of PLSQL procedure'
		);
  END IF;
  -- Standard start of API savepoint
  SAVEPOINT process_deferral;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version,l_api_name, G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
   -- setting up module type
   G_MODULE_TYPE := p_module_type;
    -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean( p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_deferral',
			'p_init_message_list : ' || p_init_msg_list
		);
        fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_deferral',
			'p_commit : ' || p_commit
		);
        fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_deferral',
			'p_validation_level : ' || p_validation_level
		);
        fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_deferral',
			'p_module_type : ' || p_module_type
		);
  END IF;
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	  fnd_log.string
	  (
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_deferral',
			'Logging deferral header record prior to processing'
	  );
      log_df_header(p_df_header_rec  => p_x_df_header_rec);
  END IF;

  process_df_header(
              p_x_df_header_rec  => p_x_df_header_rec
  );

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	  fnd_log.string
	  (
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_deferral',
			'Logging deferral header record after processing'
	  );
      log_df_header(p_df_header_rec  => p_x_df_header_rec);
  END IF;


  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_deferral',
			'Number of records in schedules : ' || p_x_df_schedules_tbl.count
		);
      fnd_log.string
	  (
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_deferral',
			'Logging deferral schedule records before processing'
	  );
      IF(p_x_df_schedules_tbl.count > 0)THEN
        log_df_schedules(p_df_schedules_tbl  => p_x_df_schedules_tbl);
      END IF;
  END IF;

  -- PROCESS deferral schedules
  IF (p_x_df_schedules_tbl.count > 0 AND p_x_df_header_rec.skip_mr_flag = G_NO_FLAG AND
      (p_x_df_header_rec.operation_flag IS NULL OR
       p_x_df_header_rec.operation_flag IN (G_OP_CREATE,G_OP_UPDATE))) THEN
    process_df_schedules(
        p_df_header_rec    => p_x_df_header_rec,
        p_x_df_schedules_tbl => p_x_df_schedules_tbl
    );
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
	    (
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_deferral',
			'Logging deferral schedule records after processing'
	    );
        log_df_schedules(p_df_schedules_tbl  => p_x_df_schedules_tbl);
     END IF;
  END IF;

  -- validating the updates as a whole
  IF(p_x_df_header_rec.skip_mr_flag = G_NO_FLAG AND (p_x_df_header_rec.operation_flag IS NULL OR
       p_x_df_header_rec.operation_flag IN (G_OP_CREATE,G_OP_UPDATE))) THEN
     validate_deferral_updates(
        p_df_header_rec    => p_x_df_header_rec,
        x_warning_msg_data         => l_warning_msg_data
     );
  END IF;

  IF G_OP_SUBMIT_FOR_APPROVAL THEN
      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)THEN
	      fnd_log.string
		  (
			    fnd_log.level_event,
			    'ahl.plsql.AHL_PRD_DF_PVT.process_deferral',
			    'Submitting for Aprroval Unit Deferral ID : ' || p_x_df_header_rec.unit_deferral_id ||
                ' Object Version Number : ' || p_x_df_header_rec.object_version_number
		  );
     END IF;
     submit_for_approval(
       p_df_header_rec    => p_x_df_header_rec
     );
  END IF;

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
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
  IF(x_msg_count = 0 AND l_warning_msg_data IS NOT NULL)THEN
    x_msg_count := 1;
    x_msg_data := l_warning_msg_data;
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.process_deferral.end',
			'At the end of PLSQL procedure'
		);
  END IF;

 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
   Rollback to process_deferral;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to process_deferral;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    Rollback to process_deferral;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
END process_deferral;

-------------------------------------------------------------------------------------
-- procedure processes the header information
-- handle dml updates to the deferral context information
-- Note : Value to id conversion is done only for unit_effectivity_id and unit_deferral_type to fetch
--        the unit_deferral_id. Hence no validation level check and no sperate procedure for value
--        to id conversion process.
-------------------------------------------------------------------------------------
PROCEDURE process_df_header(
    p_x_df_header_rec       IN OUT NOCOPY  AHL_PRD_DF_PVT.df_header_rec_type)
    IS

    l_rowid               VARCHAR2(30);

    CURSOR unit_deferral_id_csr(p_unit_effectivity_id In NUMBER) IS
    SELECT unit_deferral_id, object_version_number
    from ahl_unit_deferrals_b
    WHERE unit_deferral_type = 'DEFERRAL'
    AND unit_effectivity_id = p_unit_effectivity_id;

    l_unit_deferral_id NUMBER;
    l_object_version_number NUMBER;
    l_input_key_error_flag BOOLEAN := false;

    /*
    *  Application usage code AND condition has been added to resolve all application usage code related issues here
    * in the cursor select of "unit_effectivity_info_csr".
    * Here onwards in this program we dont have to worry about any app usage code related issues.
    */

    CURSOR unit_effectivity_info_csr(p_unit_effectivity_id IN NUMBER) IS
    SELECT mr_header_id,cs_incident_id,repetitive_mr_flag,orig_deferral_ue_id,ue_status_code,
           def_status_code,manually_planned_flag
    FROM ahl_ue_deferral_details_v
    WHERE unit_effectivity_id = p_unit_effectivity_id
    AND APPLICATION_USG_CODE = RTRIM(LTRIM(FND_PROFILE.VALUE('AHL_APPLN_USAGE'))) ;

    l_mr_header_id NUMBER;
    l_incident_id NUMBER;
    l_orig_deferral_ue_id NUMBER;
    l_ue_status_code VARCHAR2(30);
    l_def_status_code VARCHAR2(30);
    l_repetitive_mr_flag VARCHAR2(1);
    l_manually_planned_flag VARCHAR2(1);

    -- to check whether MR or any of its children has resettable counters
    CURSOR reset_counter_csr(p_unit_effectivity_id IN NUMBER) IS
    --SELECT 'x' from csi_cp_counters_v CP, AHL_MR_INTERVALS_V MRI,AHL_MR_EFFECTIVITIES_APP_V  MRE, AHL_UNIT_EFFECTIVITIES_APP_V UE
    /* In R12, modified to use csi_counters_vl instead of csi_cp_counters_v.
    SELECT 'x' from csi_cp_counters_v CP, AHL_MR_INTERVALS_V MRI,AHL_MR_EFFECTIVITIES  MRE, AHL_UNIT_EFFECTIVITIES_B UE
    WHERE CP.customer_product_id = UE.csi_item_instance_id
    AND CP.counter_name = MRI.counter_name
    AND MRI.reset_value IS NOT NULL
    AND MRI.mr_effectivity_id = MRE.mr_effectivity_id
    AND MRE.mr_header_id = UE.mr_header_id
    AND UE.unit_effectivity_id = p_unit_effectivity_id
    UNION
    --SELECT 'x' from csi_cp_counters_v CP,  AHL_MR_INTERVALS_V MRI,  AHL_MR_EFFECTIVITIES_APP_V MRE, AHL_UNIT_EFFECTIVITIES_APP_V UE
    SELECT 'x' from csi_cp_counters_v CP, AHL_MR_INTERVALS_V MRI,AHL_MR_EFFECTIVITIES  MRE, AHL_UNIT_EFFECTIVITIES_B UE
    WHERE CP.customer_product_id = UE.csi_item_instance_id
    AND CP.counter_name = MRI.counter_name
    AND MRI.reset_value IS NOT NULL
    AND MRI.mr_effectivity_id = MRE.mr_effectivity_id
    AND MRE.mr_header_id = UE.mr_header_id
    AND UE.unit_effectivity_id IN
      (

         SELECT     related_ue_id
         FROM       AHL_UE_RELATIONSHIPS
         WHERE      relationship_code = 'PARENT'
         START WITH ue_id = p_unit_effectivity_id
         CONNECT BY ue_id = PRIOR related_ue_id

      );
    */
    SELECT 'x'
    from csi_counter_associations ca, csi_counters_vl CP, AHL_MR_INTERVALS_V MRI,
         AHL_MR_EFFECTIVITIES  MRE, AHL_UNIT_EFFECTIVITIES_B UE
    WHERE CA.source_object_id = UE.csi_item_instance_id
    AND ca.source_object_code = 'CP'
    AND CP.counter_template_name = MRI.counter_name
    AND MRI.reset_value IS NOT NULL
    AND MRI.mr_effectivity_id = MRE.mr_effectivity_id
    AND MRE.mr_header_id = UE.mr_header_id
    AND UE.unit_effectivity_id = p_unit_effectivity_id
    UNION
    SELECT 'x'
    from csi_counter_associations ca, csi_counters_vl CP, AHL_MR_INTERVALS_V MRI,
         AHL_MR_EFFECTIVITIES  MRE, AHL_UNIT_EFFECTIVITIES_B UE
    WHERE CA.source_object_id = UE.csi_item_instance_id
    AND ca.source_object_code = 'CP'
    AND CP.counter_template_name = MRI.counter_name
    AND MRI.reset_value IS NOT NULL
    AND MRI.mr_effectivity_id = MRE.mr_effectivity_id
    AND MRE.mr_header_id = UE.mr_header_id
    AND UE.unit_effectivity_id IN
      (

         SELECT     related_ue_id
         FROM       AHL_UE_RELATIONSHIPS
         WHERE      relationship_code = 'PARENT'
         START WITH ue_id = p_unit_effectivity_id
         CONNECT BY ue_id = PRIOR related_ue_id

      );

    l_exists VARCHAR2(1);


BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.process_df_header.begin',
			'At the start of PLSQL procedure'
		);
    END IF;
    -- initializaing submit for approval flag
    G_OP_SUBMIT_FOR_APPROVAL := false;
    -- value to id conversion based on unit_effectivity_id
    IF( p_x_df_header_rec.unit_effectivity_id IS NULL AND
       (p_x_df_header_rec.unit_deferral_id IS NULL OR p_x_df_header_rec.object_version_number IS NULL))THEN
        l_input_key_error_flag := true;
    ELSIF(p_x_df_header_rec.unit_effectivity_id IS NOT NULL)THEN
        IF(NVL(p_x_df_header_rec.operation_flag,'x') <> G_OP_CREATE)THEN
           OPEN unit_deferral_id_csr(p_x_df_header_rec.unit_effectivity_id);
           FETCH unit_deferral_id_csr INTO p_x_df_header_rec.unit_deferral_id,p_x_df_header_rec.object_version_number;
           IF(unit_deferral_id_csr%NOTFOUND) THEN
              IF(p_x_df_header_rec.operation_flag = G_OP_SUBMIT)THEN
                p_x_df_header_rec.operation_flag := G_OP_CREATE;
                G_OP_SUBMIT_FOR_APPROVAL := TRUE;
              ELSE
               l_input_key_error_flag := true;
              END IF;
           ELSIF(p_x_df_header_rec.operation_flag = G_OP_SUBMIT)THEN
              p_x_df_header_rec.operation_flag := G_OP_UPDATE;
              G_OP_SUBMIT_FOR_APPROVAL := TRUE;
           END IF;
           CLOSE unit_deferral_id_csr;
       END IF;
    END IF;
    -- raise error if input keys are wrong.
    IF(l_input_key_error_flag)THEN
       FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_HREC_KMISS');
       FND_MSG_PUB.ADD;
       IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.process_df_header',
			    'Input Keys are missing or invalid'
		    );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- check whether unit effectivity is valid
    OPEN unit_effectivity_info_csr(p_x_df_header_rec.unit_effectivity_id);
    FETCH unit_effectivity_info_csr INTO l_mr_header_id,
                                         l_incident_id,
                                         l_repetitive_mr_flag,
                                         l_orig_deferral_ue_id,
                                         l_ue_status_code,
                                         l_def_status_code,
                                         l_manually_planned_flag;
    IF(unit_effectivity_info_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_HREC_UE_ID');
       FND_MSG_PUB.ADD;
       IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		       fnd_log.string
		        (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.process_df_header',
			    'unit effectivity record not found'
		        );
       END IF;
       CLOSE unit_effectivity_info_csr;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
       IF(l_orig_deferral_ue_id IS NOT NULL) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_HREC_UE_ID');
          FND_MSG_PUB.ADD;
          IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		       fnd_log.string
		        (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.process_df_header',
			    'unit effectivity record not found'
		        );
          END IF;
          CLOSE unit_effectivity_info_csr;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF((NVL(l_ue_status_code,'x') IN ('ACCOMPLISHED','DEFERRED','EXCEPTION','TERMINATED','CANCELLED','MR-TERMINATE'))
             OR (NVL(l_def_status_code,'x')IN ('DEFERRED','DEFERRAL_PENDING','TERMINATED','CANCELLED')))THEN
         FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_MRSR_STATUS');
         FND_MSG_PUB.ADD;
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_error,
			    'ahl.plsql.AHL_PRD_DF_PVT.process_df_header',
			    'Status of MR or SR is not valid for deferral'
		    );
         END IF;
         CLOSE unit_effectivity_info_csr;
         RAISE FND_API.G_EXC_ERROR;
       ELSE
         -- filling in additional info
         IF(l_mr_header_id IS NULL)THEN
            p_x_df_header_rec.deferral_type := G_DEFERRAL_TYPE_SR;
         ELSE
            p_x_df_header_rec.deferral_type := G_DEFERRAL_TYPE_MR;
         END IF;
         p_x_df_header_rec.mr_repetitive_flag := NVL(l_repetitive_mr_flag,G_NO_FLAG);
         p_x_df_header_rec.manually_planned_flag := NVL(l_manually_planned_flag,G_NO_FLAG);
         p_x_df_header_rec.reset_counter_flag := G_YES_FLAG;
         IF(p_x_df_header_rec.deferral_type = G_DEFERRAL_TYPE_MR)THEN
           OPEN reset_counter_csr(p_x_df_header_rec.unit_effectivity_id);
           FETCH reset_counter_csr INTO l_exists;
           IF(reset_counter_csr%NOTFOUND)THEN
               p_x_df_header_rec.reset_counter_flag := G_NO_FLAG;
           END IF;
           CLOSE reset_counter_csr;
         /*
         ELSE
           p_x_df_header_rec.skip_mr_flag := G_NO_FLAG;
           p_x_df_header_rec.affect_due_calc_flag := G_YES_FLAG;
         */
           IF(p_x_df_header_rec.skip_mr_flag = G_YES_FLAG) THEN
              p_x_df_header_rec.set_due_date := NULL;
              p_x_df_header_rec.affect_due_calc_flag := G_NO_FLAG;
           END IF;
         ELSE
           --Enable SR cancellation for non-serialized items.
           --p_x_df_header_rec.skip_mr_flag := G_NO_FLAG;
           p_x_df_header_rec.affect_due_calc_flag := G_YES_FLAG;
         END IF;
       END IF;
    END IF;
    -- doing defaulting before validation because of future OA needs
    default_unchanged_df_header(p_x_df_header_rec => p_x_df_header_rec);

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_df_header',
			'Dumping deferral header record prior to validating'
		);
        log_df_header(p_df_header_rec  => p_x_df_header_rec);
     END IF;

    IF(p_x_df_header_rec.operation_flag IS NOT NULL) THEN
       validate_df_header(p_df_header_rec => p_x_df_header_rec);
    END IF;

    IF(p_x_df_header_rec.operation_flag = G_OP_DELETE) THEN
        -- delete schedules records
        DELETE AHL_UNIT_THRESHOLDS WHERE UNIT_DEFERRAL_ID = p_x_df_header_rec.unit_deferral_id;
        -- delete header records.
        AHL_UNIT_DEFERRALS_PKG.delete_row(x_unit_deferral_id => p_x_df_header_rec.unit_deferral_id);
    ELSIF(p_x_df_header_rec.operation_flag = G_OP_CREATE) THEN
        --setting object version number for create
        p_x_df_header_rec.object_version_number := 1;
        --setting up user/create/update information
        p_x_df_header_rec.created_by := fnd_global.user_id;
        p_x_df_header_rec.creation_date := SYSDATE;
        p_x_df_header_rec.last_updated_by := fnd_global.user_id;
        p_x_df_header_rec.last_update_date := SYSDATE;
        p_x_df_header_rec.last_update_login := fnd_global.user_id;

        IF(p_x_df_header_rec.skip_mr_flag = G_YES_FLAG)THEN
           p_x_df_header_rec.set_due_date := null;
           p_x_df_header_rec.affect_due_calc_flag := G_NO_FLAG;
        END IF;

        AHL_UNIT_DEFERRALS_PKG.insert_row(
        x_rowid => l_rowid,
        x_unit_deferral_id => p_x_df_header_rec.unit_deferral_id,
        x_object_version_number => p_x_df_header_rec.object_version_number,
        x_created_by => p_x_df_header_rec.created_by,
        x_creation_date => p_x_df_header_rec.creation_date,
        x_last_updated_by => p_x_df_header_rec.last_updated_by,
        x_last_update_date => p_x_df_header_rec.last_update_date,
        x_last_update_login => p_x_df_header_rec.last_update_login,
        x_unit_effectivity_id => p_x_df_header_rec.unit_effectivity_id,
        x_unit_deferral_type => p_x_df_header_rec.unit_deferral_type,
        x_set_due_date => p_x_df_header_rec.set_due_date,
        x_deferral_effective_on => p_x_df_header_rec.deferral_effective_on,
        x_approval_status_code => p_x_df_header_rec.approval_status_code,
        x_defer_reason_code => p_x_df_header_rec.defer_reason_code,
        x_affect_due_calc_flag => p_x_df_header_rec.affect_due_calc_flag,
        x_skip_mr_flag => p_x_df_header_rec.skip_mr_flag,
        x_remarks => p_x_df_header_rec.remarks,
        x_approver_notes => p_x_df_header_rec.approver_notes,
        x_ata_sequence_id => NULL,
        x_user_deferral_type => p_x_df_header_rec.user_deferral_type_code,
        x_attribute_category => p_x_df_header_rec.attribute_category,
        x_attribute1 => p_x_df_header_rec.attribute1,
        x_attribute2 => p_x_df_header_rec.attribute2,
        x_attribute3 => p_x_df_header_rec.attribute3,
        x_attribute4 => p_x_df_header_rec.attribute4,
        x_attribute5 => p_x_df_header_rec.attribute5,
        x_attribute6 => p_x_df_header_rec.attribute6,
        x_attribute7 => p_x_df_header_rec.attribute7,
        x_attribute8 => p_x_df_header_rec.attribute8,
        x_attribute9 => p_x_df_header_rec.attribute9,
        x_attribute10 => p_x_df_header_rec.attribute10,
        x_attribute11 => p_x_df_header_rec.attribute11,
        x_attribute12 => p_x_df_header_rec.attribute12,
        x_attribute13 => p_x_df_header_rec.attribute13,
        x_attribute14 => p_x_df_header_rec.attribute14,
        x_attribute15 => p_x_df_header_rec.attribute15
        );
    ELSIF (p_x_df_header_rec.operation_flag = G_OP_UPDATE) THEN

        -- setting up object version number
        p_x_df_header_rec.object_version_number := p_x_df_header_rec.object_version_number + 1;
        --setting up user/create/update information
        p_x_df_header_rec.last_updated_by := fnd_global.user_id;
        p_x_df_header_rec.last_update_date := SYSDATE;
        p_x_df_header_rec.last_update_login := fnd_global.user_id;

        IF(p_x_df_header_rec.skip_mr_flag = G_YES_FLAG)THEN
           p_x_df_header_rec.set_due_date := null;
           p_x_df_header_rec.affect_due_calc_flag := G_NO_FLAG;
           -- Delete all records in unit thresholds
           DELETE AHL_UNIT_THRESHOLDS WHERE UNIT_DEFERRAL_ID = p_x_df_header_rec.unit_deferral_id;
        END IF;
        p_x_df_header_rec.approval_status_code := 'DRAFT';
        AHL_UNIT_DEFERRALS_PKG.update_row(
        x_unit_deferral_id => p_x_df_header_rec.unit_deferral_id,
        x_object_version_number => p_x_df_header_rec.object_version_number,
        x_last_updated_by => p_x_df_header_rec.last_updated_by,
        x_last_update_date => p_x_df_header_rec.last_update_date,
        x_last_update_login => p_x_df_header_rec.last_update_login,
        x_unit_effectivity_id => p_x_df_header_rec.unit_effectivity_id,
        x_unit_deferral_type => p_x_df_header_rec.unit_deferral_type,
        x_set_due_date => p_x_df_header_rec.set_due_date,
        x_deferral_effective_on => p_x_df_header_rec.deferral_effective_on,
        x_approval_status_code => p_x_df_header_rec.approval_status_code,
        x_defer_reason_code => p_x_df_header_rec.defer_reason_code,
        x_affect_due_calc_flag => p_x_df_header_rec.affect_due_calc_flag,
        x_skip_mr_flag => p_x_df_header_rec.skip_mr_flag,
        x_remarks => p_x_df_header_rec.remarks,
        x_approver_notes => p_x_df_header_rec.approver_notes,
        x_ata_sequence_id => null,
        x_user_deferral_type => p_x_df_header_rec.user_deferral_type_code,
        x_attribute_category => p_x_df_header_rec.attribute_category,
        x_attribute1 => p_x_df_header_rec.attribute1,
        x_attribute2 => p_x_df_header_rec.attribute2,
        x_attribute3 => p_x_df_header_rec.attribute3,
        x_attribute4 => p_x_df_header_rec.attribute4,
        x_attribute5 => p_x_df_header_rec.attribute5,
        x_attribute6 => p_x_df_header_rec.attribute6,
        x_attribute7 => p_x_df_header_rec.attribute7,
        x_attribute8 => p_x_df_header_rec.attribute8,
        x_attribute9 => p_x_df_header_rec.attribute9,
        x_attribute10 => p_x_df_header_rec.attribute10,
        x_attribute11 => p_x_df_header_rec.attribute11,
        x_attribute12 => p_x_df_header_rec.attribute12,
        x_attribute13 => p_x_df_header_rec.attribute13,
        x_attribute14 => p_x_df_header_rec.attribute14,
        x_attribute15 => p_x_df_header_rec.attribute15
        );
    END IF;

    IF(FND_MSG_PUB.count_msg > 0)THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.process_df_header.end',
			'At the end of PLSQL procedure'
		);
    END IF;

END process_df_header;
--------------------------------------------------------------------------------
-- Procedure to dump deferral header record
--------------------------------------------------------------------------------
PROCEDURE log_df_header(
    p_df_header_rec       IN AHL_PRD_DF_PVT.df_header_rec_type) IS

BEGIN
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	    fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_header',
			    'p_x_df_header_rec.operation_flag : ' || p_df_header_rec.operation_flag
		);
        fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_header',
			    'p_x_df_header_rec.unit_deferral_id : ' || p_df_header_rec.unit_deferral_id
		);
        fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_header',
			    'p_x_df_header_rec.object_version_number : ' || p_df_header_rec.object_version_number
		);
        fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_header',
			    'p_x_df_header_rec.unit_effectivity_id : ' || p_df_header_rec.unit_effectivity_id
		);
        fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_header',
			    'p_x_df_header_rec.defer_reason_code : ' || p_df_header_rec.defer_reason_code
		);
        fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_header',
			    'p_x_df_header_rec.remarks : ' || p_df_header_rec.remarks
		);
        fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_header',
			    'p_x_df_header_rec.skip_mr_flag : ' || p_df_header_rec.skip_mr_flag
		);
        fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_header',
			    'p_x_df_header_rec.affect_due_calc_flag : ' || p_df_header_rec.affect_due_calc_flag
		);
        fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_header',
			    'p_x_df_header_rec.set_due_date : ' || p_df_header_rec.set_due_date
		);
        fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_header',
			    'p_x_df_header_rec.deferral_effective_on : ' || p_df_header_rec.deferral_effective_on
		);
        fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_header',
			    'p_x_df_header_rec.deferral_type  : ' || p_df_header_rec.deferral_type
		);
        fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_header',
			    'p_x_df_header_rec.mr_repetitive_flag  : ' || p_df_header_rec.mr_repetitive_flag
		);
        fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_header',
			    'p_x_df_header_rec.reset_counter_flag  : ' || p_df_header_rec.reset_counter_flag
		);
        fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_header',
			    'p_x_df_header_rec.manually_planned_flag  : ' || p_df_header_rec.manually_planned_flag
		);
         fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_header',
			    'user id : ' || FND_GLOBAL.USER_ID()
		);
         fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_header',
			    'resp id : ' || FND_GLOBAL.RESP_ID()
		);
         fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_header',
			    'resp appl id : ' || FND_GLOBAL.resp_appl_id()
		);
    END IF;
END log_df_header;

PROCEDURE validate_df_header(
    p_df_header_rec       IN   AHL_PRD_DF_PVT.df_header_rec_type)IS

    -- check whether any record already exists related to deferral
    CURSOR deferral_rec_exists_csr(p_unit_effectivity_id IN NUMBER) IS
    SELECT 'x' from ahl_unit_deferrals_vl
    WHERE unit_deferral_type = 'DEFERRAL'
    AND unit_effectivity_id = p_unit_effectivity_id;

    -- to check whether ue is in production
    CURSOR valid_deferral_csr(p_unit_effectivity_id IN NUMBER) IS
    SELECT 'x' from ahl_workorder_tasks_v WO,AHL_UNIT_EFFECTIVITIES_B UE --Undid App usage related BLIND changes
    WHERE WO.unit_effectivity_id = UE.unit_effectivity_id
    AND NVL(UE.status_code,'x') NOT IN('ACCOMPLISHED','DEFERRED','EXCEPTION','TERMINATED','CANCELLED','MR-TERMINATE')
    AND UE.unit_effectivity_id = p_unit_effectivity_id;

    -- check whether MR is not terminated
    /*CURSOR valid_mr_csr(p_unit_effectivity_id IN NUMBER) IS
    select 'x' from AHL_MR_HEADERS_APP_V mr, AHL_MR_HEADERS_APP_V def, ahl_unit_effectivities_b UE
    where UE.unit_effectivity_id = p_unit_effectivity_id
    AND def.mr_header_id = UE.mr_header_id
    and def.title = mr.title
    and trunc(sysdate) between trunc(mr.effective_from)
    and trunc(nvl(mr.effective_to, sysdate))
    and mr.version_number >= def.version_number;*/

    -- to check whether this deferral record can be updated or deleted
    CURSOR valid_deferral_up_csr(p_unit_deferral_id IN NUMBER) IS
    SELECT 'x' from ahl_unit_deferrals_b
    WHERE approval_status_code IN ('DRAFT','DEFERRAL_REJECTED')
    AND unit_deferral_type = 'DEFERRAL'
    AND unit_deferral_id = p_unit_deferral_id;

	-- TAMAL -- Begin changes for ER #3356804
	-- This cursor specifically checks whether the UE for an SR with MRs is available for deferral processing
	-- Contrast this with the earlier cursor valid_deferral_csr, which handles SRs with no MRs and plain MRs
	CURSOR valid_sr_deferral_csr (p_ue_id in number)
	IS
		SELECT 	'x'
		FROM 	ahl_workorders WO, ahl_visits_b VS, ahl_visit_tasks_b VST, ahl_unit_effectivities_b UE
		WHERE 	WO.master_workorder_flag = 'Y'
		/* to filter out draft / deleted WOs */
		AND	WO.STATUS_CODE NOT IN ( '17' , '22' )
		/* to check whether visit available in client's organization */
		AND	WO.visit_id = VS.visit_id
		AND	VS.ORGANIZATION_ID IN
                  (SELECT ORGANIZATION_ID FROM org_organization_definitions
                   WHERE NVL (operating_unit, mo_global.get_current_org_id())
                   = mo_global.get_current_org_id())
		AND	VST.visit_id = VS.visit_id
		/* */
		AND	WO.visit_task_id = VST.visit_task_id
		AND 	VST.unit_effectivity_id = UE.unit_effectivity_id
		AND 	VST.mr_id IS NULL
		AND 	NVL(UE.status_code,'x') NOT IN('ACCOMPLISHED','DEFERRED','EXCEPTION','TERMINATED','CANCELLED','MR-TERMINATE')
		AND 	UE.cs_incident_id IS NOT NULL
		AND 	UE.unit_effectivity_id = p_ue_id;
	-- TAMAL -- End changes for ER #3356804

    -- R12: UMP Deferral
    CURSOR valid_ue_csr (p_unit_effectivity_id IN NUMBER) IS
      SELECT 'x'
      FROM AHL_Unit_Effectivities_B UE
      WHERE status_code IS NULL OR status_code = 'INIT-DUE'
        AND unit_effectivity_id = p_unit_effectivity_id
        AND NOT EXISTS (SELECT 'x'
                        FROM ahl_visit_tasks_b vts
                        WHERE vts.unit_effectivity_id = UE.unit_effectivity_id
                          AND NVL(vts.status_code,'x') IN ('PLANNED')
                          AND EXISTS (select 'x'
                                      from  ahl_visits_b vst, ahl_simulation_plans_b sim
                                      where vst.simulation_plan_id = sim.simulation_plan_id(+)
                                        and vst.visit_id = vts.visit_id
                                        and sim.primary_plan_flag(+) = 'Y')
                       );

    -- R12: UMP Deferral.
    -- Validate user deferral type.
    CURSOR validate_user_defer_csr(p_user_defer_type IN VARCHAR2) IS
      SELECT 'x'
      FROM fnd_lookup_values_vl
      WHERE lookup_type = 'AHL_PRD_DEFERRAL_TYPE'
        AND lookup_code = p_user_defer_type
        AND enabled_flag = 'Y'
        AND trunc(sysdate) BETWEEN start_date_active AND nvl(end_date_active, sysdate+1);

    -- SR Cancellation for nonserialized items.
    CURSOR is_orig_ue_nonserial(p_ue_id in number)
    IS
        SELECT cii.serial_number
        FROM ahl_unit_effectivities_b ue, csi_item_instances cii
        WHERE unit_effectivity_id in (select originator_ue_id
                                      from ahl_ue_relationships
                                      where related_ue_id = p_ue_id)
          AND ue.csi_item_instance_id = cii.instance_id
          AND cii.quantity > 1
          AND ue.object_type = 'SR';

    l_exists VARCHAR2(1);
    l_serial_number  csi_item_instances.serial_number%TYPE;

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.validate_df_header.begin',
			'At the start of PLSQL procedure'
		);
    END IF;

    IF(p_df_header_rec.operation_flag IS NOT NULL AND p_df_header_rec.operation_flag NOT IN(G_OP_CREATE,G_OP_UPDATE,G_OP_DELETE))THEN
       FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_HD_OP_FLAG');
       FND_MSG_PUB.ADD;
       IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_unexpected,
			'ahl.plsql.AHL_PRD_DF_PVT.validate_df_header',
			'Operation Flag is invalid in the header record'
		);
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      -- R12: UMP Deferral.
      -- First validate UE ID. If UMP Deferral, then UE must not be in a 'planned' status.
      OPEN valid_ue_csr(p_df_header_rec.unit_effectivity_id);
      FETCH valid_ue_csr INTO l_exists;
      IF (valid_ue_csr%FOUND) THEN
           -- ump deferral.
           CLOSE valid_ue_csr;
      ELSE

         -- Production Validations.
         -- TAMAL -- Begin changes for ER #3356804
         -- This splitting of cursors is needed to handle the case of SRs with MRs v/s SRs without MRs
         -- First check whether the UE corresponds to a SR with MRs that is available for deferral processing
         -- If yes, fine
         -- If no, then check whether the UE corresponds to a SR without MRs or plain MRs that is available for deferral processing
         -- If yes, fine
         -- If no, raise unexpected error
         OPEN valid_sr_deferral_csr (p_df_header_rec.unit_effectivity_id);
         FETCH valid_sr_deferral_csr INTO l_exists;
         IF (valid_sr_deferral_csr%NOTFOUND)
         THEN
             CLOSE valid_sr_deferral_csr;
             OPEN valid_deferral_csr(p_df_header_rec.unit_effectivity_id);
             FETCH valid_deferral_csr INTO l_exists;
             IF(valid_deferral_csr%NOTFOUND)
             THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_MRSR_STATUS');
                FND_MSG_PUB.ADD;
                IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
                THEN
				fnd_log.string
				(
				fnd_log.level_unexpected,
				'ahl.plsql.AHL_PRD_DF_PVT.validate_df_header',
				'invalid mr or sr status invalid for update or delete 1'
				);
		    END IF;
		    CLOSE valid_deferral_csr;
		    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		 ELSE
			CLOSE valid_deferral_csr;
		 END IF;  -- valid_deferral_csr
	   ELSE
		CLOSE valid_sr_deferral_csr;
	   END IF; -- valid_sr_deferral_csr

           -- SR Cancellation - child MR cannot be deferred if originator ue is a SR
           -- based on non-serialized instance.
           IF (p_df_header_rec.skip_mr_flag = G_NO_FLAG) THEN
             OPEN is_orig_ue_nonserial(p_df_header_rec.unit_effectivity_id);
             FETCH is_orig_ue_nonserial INTO l_serial_number;
             IF (is_orig_ue_nonserial%FOUND AND l_serial_number IS NULL) THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_NS_DF_INVALID');
                FND_MSG_PUB.ADD;
                IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string
                    (
                            fnd_log.level_unexpected,
                            'ahl.plsql.AHL_PRD_DF_PVT.validate_df_header',
                            'cannot defer child MR when parent MR is based on non-serial SR'
                    );
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

             END IF;

             CLOSE is_orig_ue_nonserial;
           END IF;

      END IF; -- valid_ue_csr


	/*-- check whether this MR or SR (basically UE) available for deferral processing
	OPEN valid_deferral_csr(p_df_header_rec.unit_effectivity_id);
	FETCH valid_deferral_csr INTO l_exists;
	IF(valid_deferral_csr%NOTFOUND)THEN
	FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_MRSR_STATUS');
	FND_MSG_PUB.ADD;
	IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
	fnd_log.string
	(
	fnd_log.level_unexpected,
	'ahl.plsql.AHL_PRD_DF_PVT.validate_df_header',
	'invalid mr or sr status invalid for update or delete 1'
	);
	END IF;
	CLOSE valid_deferral_csr;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	CLOSE valid_deferral_csr;*/
	-- TAMAL -- End changes for ER #3356804
    END IF;


    IF(p_df_header_rec.operation_flag = G_OP_CREATE) THEN
       ----------------VALIDATION for DEFERRAL RECORD CREATION----------------
       -- check whether any record alreasy exists for the UE, IF yes raise error
       OPEN deferral_rec_exists_csr(p_df_header_rec.unit_effectivity_id);
       FETCH deferral_rec_exists_csr INTO l_exists;
       IF(deferral_rec_exists_csr%FOUND)THEN
         FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_HD_OP_REXIST');
         FND_MSG_PUB.ADD;
         IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.validate_df_header',
			    'Deferral record exist while operation flag is create'
		    );
         END IF;
         CLOSE deferral_rec_exists_csr;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       CLOSE deferral_rec_exists_csr;

       -- check whether status is nothing but draft while creating record for deferral
       IF(p_df_header_rec.approval_status_code <> 'DRAFT')THEN
         FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_APPR_STATUS');
         FND_MSG_PUB.ADD;
         IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.validate_df_header',
			    'approval status is not DRAFT while creating a deferral record'
		    );
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

   -- update and delete validations
   ELSIF (p_df_header_rec.operation_flag IN (G_OP_UPDATE,G_OP_DELETE)) THEN
       -- check whether deferral record can be updated or deleted
       OPEN valid_deferral_up_csr(p_df_header_rec.unit_deferral_id);
       FETCH valid_deferral_up_csr INTO l_exists;
       IF(valid_deferral_up_csr%NOTFOUND)THEN
	     FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_MRSR_STATUS');
         FND_MSG_PUB.ADD;
         IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.validate_df_header',
			    'approval status invalid for update or delete : ue_id : ' || p_df_header_rec.unit_deferral_id
		    );
         END IF;
         CLOSE valid_deferral_up_csr;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       CLOSE valid_deferral_up_csr;
   END IF;

   --Data validation for creates and updates.
   IF (p_df_header_rec.operation_flag IN (G_OP_CREATE, G_OP_UPDATE)) THEN

       /*-- check MR status now
       IF(p_df_header_rec.deferral_type = G_DEFERRAL_TYPE_MR) THEN
          OPEN valid_mr_csr(p_df_header_rec.unit_effectivity_id);
          FETCH valid_mr_csr INTO l_exists;
          IF(valid_mr_csr%NOTFOUND)THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_MR_TERM');
            FND_MSG_PUB.ADD;
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		        fnd_log.string
		        (
			        fnd_log.level_error,
			        'ahl.plsql.AHL_PRD_DF_PVT.validate_df_header',
			        'Associated MR has been terminated in FMP'
		        );
            END IF;
            CLOSE valid_mr_csr;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          CLOSE valid_mr_csr;
       END IF;*/

       -- validate deferral reason codes
       IF(p_df_header_rec.defer_reason_code IS NOT NULL)THEN
          validate_reason_codes(p_df_header_rec.defer_reason_code);
       END IF;
       -- general validations for flags
       IF(p_df_header_rec.skip_mr_flag NOT IN(G_YES_FLAG,G_NO_FLAG))THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_SKIP_FLAG');
          FND_MSG_PUB.ADD;
          IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.validate_df_header',
			    'Skip flag is not Y or N'
		    );
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       IF(p_df_header_rec.affect_due_calc_flag NOT IN(G_YES_FLAG,G_NO_FLAG))THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_AFFDUE_FLAG');
          FND_MSG_PUB.ADD;
          IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.validate_df_header',
			    'Affect Due Calc Flag is not Y or N'
		    );
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       -- Check user deferral type.(R12: UMP Deferral)
       IF (p_df_header_rec.user_deferral_type_code IS NOT NULL AND
           p_df_header_rec.user_deferral_type_code <> FND_API.G_MISS_CHAR) THEN
           OPEN validate_user_defer_csr(p_df_header_rec.user_deferral_type_code);
           FETCH validate_user_defer_csr INTO l_exists;
           IF (validate_user_defer_csr%NOTFOUND) THEN
              FND_MESSAGE.Set_Name('AHL','AHL_UMP_INVALID_DEF_TYPE');
              FND_MESSAGE.Set_token('CODE', p_df_header_rec.user_deferral_type_code);
              FND_MSG_PUB.ADD;
           END IF;
           CLOSE validate_user_defer_csr;
       END IF;

       -- MR/SR specific validations
       IF(p_df_header_rec.deferral_type = G_DEFERRAL_TYPE_MR) THEN
          -- check validity of skip MR flag for MR
          IF(p_df_header_rec.mr_repetitive_flag = G_NO_FLAG AND p_df_header_rec.manually_planned_flag = G_NO_FLAG)THEN
            IF(p_df_header_rec.skip_mr_flag = G_YES_FLAG) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_SKIP_FLAG');
               FND_MSG_PUB.ADD;
               IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		           fnd_log.string
		           (
			         fnd_log.level_unexpected,
			         'ahl.plsql.AHL_PRD_DF_PVT.validate_df_header',
			         'Skip MR flag is Y while MR is not repetitive'
		           );
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            IF(p_df_header_rec.affect_due_calc_flag = G_NO_FLAG AND p_df_header_rec.reset_counter_flag = G_YES_FLAG) THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_AFFDUE_FLAG');
              FND_MSG_PUB.ADD;
            END IF;
          ELSE -- MR is repetitive or manually planned
            IF(p_df_header_rec.skip_mr_flag = G_NO_FLAG) THEN
               IF(p_df_header_rec.affect_due_calc_flag = G_NO_FLAG AND
                  p_df_header_rec.reset_counter_flag = G_YES_FLAG) THEN
                  FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_AFFDUE_FLAG');
                  FND_MSG_PUB.ADD;
                  IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		              fnd_log.string
		              (
			            fnd_log.level_unexpected,
			            'ahl.plsql.AHL_PRD_DF_PVT.validate_df_header',
			            'MR has resettable counters so affect due cal flag cant be N '
		              );
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            ELSE
               IF(p_df_header_rec.affect_due_calc_flag = G_YES_FLAG) THEN
                  FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_AFFDUE_FLAG');
                  FND_MSG_PUB.ADD;
                  IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		              fnd_log.string
		              (
			            fnd_log.level_unexpected,
			            'ahl.plsql.AHL_PRD_DF_PVT.validate_df_header',
			            'MR skip flag is Y so affect due cal flag can not be Y '
		              );
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;
          END IF;
       ELSIF (p_df_header_rec.deferral_type = G_DEFERRAL_TYPE_SR) THEN
          /* SR cancellation allowed for non-serialized items.
          IF(p_df_header_rec.skip_mr_flag = G_YES_FLAG) THEN
             FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_SKIP_FLAG');
             FND_MSG_PUB.ADD;
             IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		         fnd_log.string
		         (
			         fnd_log.level_unexpected,
			         'ahl.plsql.AHL_PRD_DF_PVT.validate_df_header',
			         'For SR, skip flag cant be Y '
		         );
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          */
          IF(p_df_header_rec.affect_due_calc_flag = G_NO_FLAG)THEN
             FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_AFFDUE_FLAG');
             FND_MSG_PUB.ADD;
             IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		         fnd_log.string
		         (
			         fnd_log.level_unexpected,
			         'ahl.plsql.AHL_PRD_DF_PVT.validate_df_header',
			         'For SR, affect due date flag can not be N '
		         );
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;
       -- set due date and  deferral effective on date validations
       -- part of this validation has been moved for post processing
       IF(p_df_header_rec.skip_mr_flag = G_NO_FLAG AND
         (p_df_header_rec.set_due_date IS NOT NULL AND
            trunc(p_df_header_rec.set_due_date) < trunc(SYSDATE))) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_SET_DUE_DT');
          FND_MESSAGE.Set_Token('SET_DUE_DATE',p_df_header_rec.set_due_date);
          FND_MSG_PUB.ADD;
          IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		      fnd_log.string
		      (
			        fnd_log.level_error,
			        'ahl.plsql.AHL_PRD_DF_PVT.validate_df_header',
			        'Set due date cant be null or less than system date '
		      );
          END IF;
      END IF;
      IF(p_df_header_rec.deferral_effective_on IS NULL OR
          p_df_header_rec.deferral_effective_on > SYSDATE) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_DF_EFF_DT');
          FND_MESSAGE.Set_Token('DEFERRAL_EFFECTIVE_ON',p_df_header_rec.deferral_effective_on);
          FND_MSG_PUB.ADD;
          IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		      fnd_log.string
		      (
			        fnd_log.level_error,
			        'ahl.plsql.AHL_PRD_DF_PVT.validate_df_header',
			        'Deferral Effective On Date can not be null or greater than system date '
		      );
         END IF;
      END IF;
    END IF;

    -- raise expected error
    IF(FND_MSG_PUB.count_msg > 0)THEN
         RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.validate_df_header.end',
			'At the end of PLSQL procedure'
		);
    END IF;

END validate_df_header;
--------------------------------------------------------------------------------------------------------
-- Reason code validation
--------------------------------------------------------------------------------------------------------

PROCEDURE validate_reason_codes(
     p_defer_reason_code       IN VARCHAR2) IS

     l_temp1 NUMBER := 1;
     l_temp2 NUMBER;
     l_index NUMBER := 1;
     exit_flag boolean := false;
     l_string VARCHAR2(30);

     CURSOR val_reason_code_csr(p_reason_code IN VARCHAR2) IS
     SELECT 'x' FROM fnd_lookup_values_vl fnd
     WHERE fnd.lookup_code = p_reason_code
     AND fnd.lookup_type = 'AHL_PRD_DF_REASON_TYPES';

     l_exists VARCHAR2(1);

BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.validate_reason_codes.begin',
			'At the start of PLSQL procedure'
		);
    END IF;

    LOOP
      l_temp2 := instr(p_defer_reason_code,G_REASON_CODE_DELIM,1,l_index);
      IF(l_temp2 = 0) THEN
        l_string := substr(p_defer_reason_code,l_temp1);
        OPEN val_reason_code_csr(l_string);
        FETCH val_reason_code_csr INTO l_exists;
        IF(val_reason_code_csr%NOTFOUND) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_RSN_CODE');
           FND_MSG_PUB.ADD;
           IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		         fnd_log.string
		         (
			         fnd_log.level_unexpected,
			         'ahl.plsql.AHL_PRD_DF_PVT.validate_reason_codes',
			         'Reason code is not defined in lookups '
		         );
           END IF;
           CLOSE val_reason_code_csr;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        CLOSE val_reason_code_csr;
        exit_flag := true;
      ELSE
        l_string := substr(p_defer_reason_code,l_temp1,l_temp2 - l_temp1);
        OPEN val_reason_code_csr(l_string);
        FETCH val_reason_code_csr INTO l_exists;
        IF(val_reason_code_csr%NOTFOUND) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_RSN_CODE');
           FND_MSG_PUB.ADD;
           IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		         fnd_log.string
		         (
			         fnd_log.level_unexpected,
			         'ahl.plsql.AHL_PRD_DF_PVT.validate_reason_codes',
			         'Reason code is not defined in lookups '
		         );
           END IF;
           CLOSE val_reason_code_csr;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        CLOSE val_reason_code_csr;
        l_index := l_index + 1;
        l_temp1 := l_temp2 + 1;
      END IF;
      EXIT WHEN exit_flag;
    END LOOP;

    IF(FND_MSG_PUB.count_msg > 0)THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.validate_reason_codes.end',
			'At the end of PLSQL procedure'
		);
    END IF;

END validate_reason_codes;


---------------------------------------------------------------------------------------------------------
-- defaulting values in case of create and update mode
---------------------------------------------------------------------------------------------------------

PROCEDURE default_unchanged_df_header(
    p_x_df_header_rec       IN OUT NOCOPY  AHL_PRD_DF_PVT.df_header_rec_type)IS

   CURSOR df_header_csr(p_unit_deferral_id IN NUMBER, p_object_version_number IN NUMBER) IS
   SELECT  unit_effectivity_id, unit_deferral_type, approval_status_code, defer_reason_code,skip_mr_flag,
        affect_due_calc_flag, set_due_date, deferral_effective_on,remarks,approver_notes,attribute_category, attribute1,
        attribute2, attribute3, attribute4, attribute5, attribute6, attribute7,
        attribute8, attribute9, attribute10, attribute11, attribute12,
        attribute13, attribute14, attribute15
   FROM ahl_unit_deferrals_vl
   WHERE object_version_number= p_object_version_number
   AND unit_deferral_id = p_unit_deferral_id;

l_df_header_rec AHL_PRD_DF_PVT.df_header_Rec_type;

BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.default_unchanged_df_header.begin',
			'At the start of PLSQL procedure'
		);
    END IF;

    IF(p_x_df_header_rec.operation_flag IS NULL OR p_x_df_header_rec.operation_flag = G_OP_UPDATE) THEN
        OPEN df_header_csr(p_x_df_header_rec.unit_deferral_id, p_x_df_header_rec.object_version_number);
        FETCH df_header_csr INTO l_df_header_rec.unit_effectivity_id, l_df_header_rec.unit_deferral_type,
         l_df_header_rec.approval_status_code,l_df_header_rec.defer_reason_code,
         l_df_header_rec.skip_mr_flag,l_df_header_rec.affect_due_calc_flag,l_df_header_rec.set_due_date,
         l_df_header_rec.deferral_effective_on,l_df_header_rec.remarks,l_df_header_rec.approver_notes,
         l_df_header_rec.attribute_category,l_df_header_rec.attribute1,l_df_header_rec.attribute2,
         l_df_header_rec.attribute3, l_df_header_rec.attribute4, l_df_header_rec.attribute5,
         l_df_header_rec.attribute6, l_df_header_rec.attribute7, l_df_header_rec.attribute8,
         l_df_header_rec.attribute9, l_df_header_rec.attribute10, l_df_header_rec.attribute11,
         l_df_header_rec.attribute12, l_df_header_rec.attribute13, l_df_header_rec.attribute14,
         l_df_header_rec.attribute15;
        IF (df_header_csr%NOTFOUND) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INVOP_HREC_MISS');
            FND_MSG_PUB.ADD;
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		         fnd_log.string
		         (
			         fnd_log.level_error,
			         'ahl.plsql.AHL_PRD_DF_PVT.default_unchanged_df_header',
			         'Missing Deferral Header Record'
		         );
            END IF;
        ELSE
            IF (p_x_df_header_rec.unit_effectivity_id IS NULL) THEN
                p_x_df_header_rec.unit_effectivity_id := l_df_header_rec.unit_effectivity_id;
            ELSIF(p_x_df_header_rec.unit_effectivity_id <> l_df_header_rec.unit_effectivity_id ) THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_UE');
                FND_MSG_PUB.ADD;
                IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		           fnd_log.string
		            (
			         fnd_log.level_unexpected,
			         'ahl.plsql.AHL_PRD_DF_PVT.default_unchanged_df_header',
			         'Unit Effectivity ID does not match with deferral header record'
		            );
                END IF;
                CLOSE df_header_csr;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF (p_x_df_header_rec.unit_deferral_type IS NULL) THEN
                p_x_df_header_rec.unit_deferral_type := l_df_header_rec.unit_deferral_type;
            ELSIF(p_x_df_header_rec.unit_deferral_type <> l_df_header_rec.unit_deferral_type) THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_UDF_TYPE');
                FND_MSG_PUB.ADD;
                IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		           fnd_log.string
		            (
			         fnd_log.level_unexpected,
			         'ahl.plsql.AHL_PRD_DF_PVT.default_unchanged_df_header',
			         'Unit Deferral Type does not match with deferral header record'
		            );
                END IF;
                CLOSE df_header_csr;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF (p_x_df_header_rec.approval_status_code IS NULL) THEN
                p_x_df_header_rec.approval_status_code := l_df_header_rec.approval_status_code;
            ELSIF(p_x_df_header_rec.approval_status_code <> l_df_header_rec.approval_status_code) THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_APPR_STATUS');
                FND_MSG_PUB.ADD;
                IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		           fnd_log.string
		            (
			         fnd_log.level_unexpected,
			         'ahl.plsql.AHL_PRD_DF_PVT.default_unchanged_df_header',
			         'Approval status code can not be modified'
		            );
                END IF;
                CLOSE df_header_csr;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF (p_x_df_header_rec.defer_reason_code IS NULL) THEN
                p_x_df_header_rec.defer_reason_code := l_df_header_rec.defer_reason_code;
            ELSIF(p_x_df_header_rec.defer_reason_code = FND_API.G_MISS_CHAR) THEN
                p_x_df_header_rec.defer_reason_code := NULL;
            END IF;

            IF (p_x_df_header_rec.skip_mr_flag IS NULL) THEN
                p_x_df_header_rec.skip_mr_flag := l_df_header_rec.skip_mr_flag;
            ELSIF(p_x_df_header_rec.skip_mr_flag = FND_API.G_MISS_CHAR) THEN
                p_x_df_header_rec.skip_mr_flag := G_NO_FLAG;
            END IF;

            IF (p_x_df_header_rec.affect_due_calc_flag IS NULL) THEN
                p_x_df_header_rec.affect_due_calc_flag := l_df_header_rec.affect_due_calc_flag;
            ELSIF(p_x_df_header_rec.affect_due_calc_flag = FND_API.G_MISS_CHAR) THEN
                p_x_df_header_rec.affect_due_calc_flag := G_NO_FLAG;
            END IF;

            IF (p_x_df_header_rec.set_due_date IS NULL) THEN
                p_x_df_header_rec.set_due_date := l_df_header_rec.set_due_date;
            ELSIF(p_x_df_header_rec.set_due_date = FND_API.G_MISS_DATE) THEN
                p_x_df_header_rec.set_due_date := NULL;
            END IF;

            IF (p_x_df_header_rec.deferral_effective_on IS NULL) THEN
                p_x_df_header_rec.deferral_effective_on := l_df_header_rec.deferral_effective_on;
            ELSIF(p_x_df_header_rec.deferral_effective_on = FND_API.G_MISS_DATE) THEN
                p_x_df_header_rec.deferral_effective_on := NULL;
            END IF;

            IF (p_x_df_header_rec.remarks IS NULL) THEN
                p_x_df_header_rec.remarks := l_df_header_rec.remarks;
            ELSIF(p_x_df_header_rec.remarks = FND_API.G_MISS_CHAR) THEN
                p_x_df_header_rec.remarks := NULL;
            END IF;

            IF (p_x_df_header_rec.approver_notes IS NULL) THEN
                p_x_df_header_rec.approver_notes := l_df_header_rec.approver_notes;
            ELSIF(p_x_df_header_rec.approver_notes <> l_df_header_rec.approver_notes) THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_APPR_NOTES');
                FND_MSG_PUB.ADD;
                IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		           fnd_log.string
		           (
			        fnd_log.level_unexpected,
			        'ahl.plsql.AHL_PRD_DF_PVT.default_unchanged_df_header',
			        'approver notes can not be updated by this API'
		           );
                END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF (p_x_df_header_rec.attribute_category IS NULL) THEN
                p_x_df_header_rec.attribute_category := l_df_header_rec.attribute_category;
            ELSIF(p_x_df_header_rec.attribute_category = FND_API.G_MISS_CHAR) THEN
                p_x_df_header_rec.attribute_category := NULL;
            END IF;

            IF (p_x_df_header_rec.attribute1 IS NULL) THEN
                p_x_df_header_rec.attribute1 := l_df_header_rec.attribute1;
            ELSIF(p_x_df_header_rec.attribute1 = FND_API.G_MISS_CHAR) THEN
                p_x_df_header_rec.attribute1 := NULL;
            END IF;

            IF (p_x_df_header_rec.attribute2 IS NULL) THEN
                p_x_df_header_rec.attribute2 := l_df_header_rec.attribute2;
            ELSIF(p_x_df_header_rec.attribute2 = FND_API.G_MISS_CHAR) THEN
                p_x_df_header_rec.attribute2 := NULL;
            END IF;

            IF (p_x_df_header_rec.attribute3 IS NULL) THEN
                p_x_df_header_rec.attribute3 := l_df_header_rec.attribute3;
            ELSIF(p_x_df_header_rec.attribute3 = FND_API.G_MISS_CHAR) THEN
                p_x_df_header_rec.attribute3 := NULL;
            END IF;

            IF (p_x_df_header_rec.attribute4 IS NULL) THEN
                p_x_df_header_rec.attribute4 := l_df_header_rec.attribute4;
            ELSIF(p_x_df_header_rec.attribute4 = FND_API.G_MISS_CHAR) THEN
                p_x_df_header_rec.attribute4 := NULL;
            END IF;

            IF (p_x_df_header_rec.attribute5 IS NULL) THEN
                p_x_df_header_rec.attribute5 := l_df_header_rec.attribute5;
            ELSIF(p_x_df_header_rec.attribute5 = FND_API.G_MISS_CHAR) THEN
                p_x_df_header_rec.attribute5 := NULL;
            END IF;

            IF (p_x_df_header_rec.attribute6 IS NULL) THEN
                p_x_df_header_rec.attribute6 := l_df_header_rec.attribute6;
            ELSIF(p_x_df_header_rec.attribute6 = FND_API.G_MISS_CHAR) THEN
                p_x_df_header_rec.attribute6 := NULL;
            END IF;

            IF (p_x_df_header_rec.attribute7 IS NULL) THEN
                p_x_df_header_rec.attribute7 := l_df_header_rec.attribute7;
            ELSIF(p_x_df_header_rec.attribute7 = FND_API.G_MISS_CHAR) THEN
                p_x_df_header_rec.attribute7 := NULL;
            END IF;

            IF (p_x_df_header_rec.attribute8 IS NULL) THEN
                p_x_df_header_rec.attribute8 := l_df_header_rec.attribute8;
            ELSIF(p_x_df_header_rec.attribute8 = FND_API.G_MISS_CHAR) THEN
                p_x_df_header_rec.attribute8 := NULL;
            END IF;

            IF (p_x_df_header_rec.attribute9 IS NULL) THEN
                p_x_df_header_rec.attribute9 := l_df_header_rec.attribute9;
            ELSIF(p_x_df_header_rec.attribute9 = FND_API.G_MISS_CHAR) THEN
                p_x_df_header_rec.attribute9 := NULL;
            END IF;

            IF (p_x_df_header_rec.attribute10 IS NULL) THEN
                p_x_df_header_rec.attribute10 := l_df_header_rec.attribute10;
            ELSIF(p_x_df_header_rec.attribute10 = FND_API.G_MISS_CHAR) THEN
                p_x_df_header_rec.attribute10 := NULL;
            END IF;

            IF (p_x_df_header_rec.attribute11 IS NULL) THEN
                p_x_df_header_rec.attribute11 := l_df_header_rec.attribute11;
            ELSIF(p_x_df_header_rec.attribute11 = FND_API.G_MISS_CHAR) THEN
                p_x_df_header_rec.attribute11 := NULL;
            END IF;

            IF (p_x_df_header_rec.attribute12 IS NULL) THEN
                p_x_df_header_rec.attribute12 := l_df_header_rec.attribute12;
            ELSIF(p_x_df_header_rec.attribute12 = FND_API.G_MISS_CHAR) THEN
                p_x_df_header_rec.attribute12 := NULL;
            END IF;

            IF (p_x_df_header_rec.attribute13 IS NULL) THEN
                p_x_df_header_rec.attribute13 := l_df_header_rec.attribute13;
            ELSIF(p_x_df_header_rec.attribute13 = FND_API.G_MISS_CHAR) THEN
                p_x_df_header_rec.attribute13 := NULL;
            END IF;

            IF (p_x_df_header_rec.attribute14 IS NULL) THEN
                p_x_df_header_rec.attribute14 := l_df_header_rec.attribute14;
            ELSIF(p_x_df_header_rec.attribute14 = FND_API.G_MISS_CHAR) THEN
                p_x_df_header_rec.attribute14 := NULL;
            END IF;

            IF (p_x_df_header_rec.attribute15 IS NULL) THEN
                p_x_df_header_rec.attribute15 := l_df_header_rec.attribute15;
            ELSIF(p_x_df_header_rec.attribute15 = FND_API.G_MISS_CHAR) THEN
                p_x_df_header_rec.attribute15 := NULL;
            END IF;

        END IF;
        CLOSE df_header_csr;
    ELSIF (p_x_df_header_rec.operation_flag = G_OP_CREATE) THEN

        IF (p_x_df_header_rec.unit_effectivity_id IS NULL OR
            p_x_df_header_rec.unit_effectivity_id = FND_API.G_MISS_NUM) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_UE');
            FND_MSG_PUB.ADD;
            IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		        fnd_log.string
		        (
			       fnd_log.level_unexpected,
			       'ahl.plsql.AHL_PRD_DF_PVT.default_unchanged_df_header',
			       'Unit effectivity ID can not be null while creating deferral header record'
		        );
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (p_x_df_header_rec.unit_deferral_type IS NULL OR
            p_x_df_header_rec.unit_deferral_type = FND_API.G_MISS_CHAR) THEN
            p_x_df_header_rec.unit_deferral_type := 'DEFERRAL';
        END IF;

        IF(p_x_df_header_rec.approval_status_code IS NULL OR
           p_x_df_header_rec.approval_status_code = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.approval_status_code := 'DRAFT';
        END IF;

        IF(p_x_df_header_rec.defer_reason_code = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.defer_reason_code := NULL;
        END IF;

        IF(p_x_df_header_rec.skip_mr_flag IS NULL OR
           p_x_df_header_rec.skip_mr_flag = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.skip_mr_flag := G_NO_FLAG;
        END IF;

        IF(p_x_df_header_rec.affect_due_calc_flag IS NULL OR
           p_x_df_header_rec.affect_due_calc_flag = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.affect_due_calc_flag := G_YES_FLAG;
        END IF;

        IF(p_x_df_header_rec.set_due_date = FND_API.G_MISS_DATE) THEN
           p_x_df_header_rec.set_due_date := NULL;
        END IF;

        IF(p_x_df_header_rec.deferral_effective_on = FND_API.G_MISS_DATE) THEN
           p_x_df_header_rec.deferral_effective_on := NULL;
        END IF;

        IF(p_x_df_header_rec.remarks = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.remarks := NULL;
        END IF;

        IF(p_x_df_header_rec.approver_notes = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.approver_notes := NULL;
        END IF;

        IF(p_x_df_header_rec.attribute_category = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.attribute_category := NULL;
        END IF;

        IF(p_x_df_header_rec.attribute1 = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.attribute1 := NULL;
        END IF;

        IF(p_x_df_header_rec.attribute2 = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.attribute2 := NULL;
        END IF;

        IF(p_x_df_header_rec.attribute3 = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.attribute3 := NULL;
        END IF;

        IF(p_x_df_header_rec.attribute4 = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.attribute4 := NULL;
        END IF;

        IF(p_x_df_header_rec.attribute5 = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.attribute5 := NULL;
        END IF;

        IF(p_x_df_header_rec.attribute6 = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.attribute6 := NULL;
        END IF;

        IF(p_x_df_header_rec.attribute7 = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.attribute7 := NULL;
        END IF;

        IF(p_x_df_header_rec.attribute8 = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.attribute8 := NULL;
        END IF;

        IF(p_x_df_header_rec.attribute9 = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.attribute9 := NULL;
        END IF;

        IF(p_x_df_header_rec.attribute10 = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.attribute10 := NULL;
        END IF;

        IF(p_x_df_header_rec.attribute11 = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.attribute11 := NULL;
        END IF;

        IF(p_x_df_header_rec.attribute12 = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.attribute12 := NULL;
        END IF;

        IF(p_x_df_header_rec.attribute13 = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.attribute13 := NULL;
        END IF;

        IF(p_x_df_header_rec.attribute14 = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.attribute14 := NULL;
        END IF;

        IF(p_x_df_header_rec.attribute15 = FND_API.G_MISS_CHAR) THEN
           p_x_df_header_rec.attribute15 := NULL;
        END IF;
     END IF;

     -- raise expected error
     IF(FND_MSG_PUB.count_msg > 0)THEN
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.default_unchanged_df_header.end',
			'At the end of PLSQL procedure'
		);
    END IF;

END default_unchanged_df_header;

PROCEDURE process_df_schedules(
    p_df_header_rec       IN             AHL_PRD_DF_PVT.df_header_rec_type,
    p_x_df_schedules_tbl    IN OUT NOCOPY  AHL_PRD_DF_PVT.df_schedules_tbl_type)IS

    CURSOR counter_id_csr(p_counter_name IN VARCHAR2,p_unit_effectivity_id IN NUMBER) IS
    --SELECT CO.counter_id FROM  CSI_CP_COUNTERS_V CO, AHL_UNIT_EFFECTIVITIES_APP_V UE
    SELECT CO.counter_id FROM  CSI_CP_COUNTERS_V CO, AHL_UNIT_EFFECTIVITIES_B UE -- Undid App usage BLIND changes
    WHERE UPPER(co.counter_name) like UPPER(p_counter_name)
    AND co.customer_product_id = ue.csi_item_instance_id
    AND UE.unit_effectivity_id = p_unit_effectivity_id;

    l_counter_id NUMBER;

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.process_df_schedules.begin',
			'At the start of PLSQL procedure'
		);
    END IF;
    -- record dml validations and key requirement validations
    FOR i IN p_x_df_schedules_tbl.FIRST..p_x_df_schedules_tbl.LAST  LOOP
    -- key requirements
    IF(p_x_df_schedules_tbl(i).operation_flag NOT IN (G_OP_CREATE,G_OP_UPDATE,G_OP_DELETE)) THEN
       FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_SCH_INV_OP');
       FND_MSG_PUB.ADD;
       IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_unexpected,
			'ahl.plsql.AHL_PRD_DF_PVT.process_df_schedules',
			'Operation Flag is invalid in the schedule record : ' || i
		);
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF(p_x_df_schedules_tbl(i).operation_flag IN (G_OP_UPDATE,G_OP_DELETE)) THEN
       IF(p_x_df_schedules_tbl(i).unit_threshold_id IS NULL OR
          p_x_df_schedules_tbl(i).object_version_number IS NULL) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_SCH_REC_KEY_MISS');
          FND_MSG_PUB.ADD;
          IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		      fnd_log.string
		        (
			        fnd_log.level_unexpected,
			        'ahl.plsql.AHL_PRD_DF_PVT.process_df_schedules',
			        'Object version number or key missing in  schedule record : ' || i
		        );
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF (p_x_df_schedules_tbl(i).unit_deferral_id IS NOT NULL AND
              p_x_df_schedules_tbl(i).unit_deferral_id <> p_df_header_rec.unit_deferral_id) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_SCH_HDR_MISS');
           FND_MSG_PUB.ADD;
           IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		      fnd_log.string
		        (
			        fnd_log.level_unexpected,
			        'ahl.plsql.AHL_PRD_DF_PVT.process_df_schedules',
			        'Unit Deferral ID does not match in  schedule record : ' || i
		        );
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    ELSIF(p_x_df_schedules_tbl(i).operation_flag = G_OP_CREATE) THEN
       IF(p_x_df_schedules_tbl(i).unit_threshold_id IS NOT NULL OR
          p_x_df_schedules_tbl(i).object_version_number IS NOT NULL) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_SCH_INV_OP');
          FND_MSG_PUB.ADD;
          IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		      fnd_log.string
		        (
			        fnd_log.level_unexpected,
			        'ahl.plsql.AHL_PRD_DF_PVT.process_df_schedules',
			        'For Create Operation, Unit Threshold ID or Object Version Number is not null in schedule record : ' || i
		        );
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       IF(p_x_df_schedules_tbl(i).unit_deferral_id IS NULL OR
          p_x_df_schedules_tbl(i).unit_deferral_id = FND_API.G_MISS_NUM) THEN
          p_x_df_schedules_tbl(i).unit_deferral_id := p_df_header_rec.unit_deferral_id;
       ELSIF(p_x_df_schedules_tbl(i).unit_deferral_id <> p_df_header_rec.unit_deferral_id)THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_SCH_HDR_MISS');
          FND_MSG_PUB.ADD;
          IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		      fnd_log.string
		        (
			        fnd_log.level_unexpected,
			        'ahl.plsql.AHL_PRD_DF_PVT.process_df_schedules',
			        'For Create Operation, Header Unit Deferral ID does not match with same in schedule record : ' || i
		        );
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;
    -- value to id conversion for counter name
    IF(G_MODULE_TYPE = 'JSP' AND p_x_df_schedules_tbl(i).operation_flag IN (G_OP_CREATE,G_OP_UPDATE))THEN
       OPEN counter_id_csr(p_x_df_schedules_tbl(i).counter_name, p_df_header_rec.unit_effectivity_id);
       FETCH counter_id_csr INTO l_counter_id;
       IF(counter_id_csr%NOTFOUND)THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_CNT_NAME');
          FND_MESSAGE.Set_Token('COUNTER_NAME',p_x_df_schedules_tbl(i).counter_name);
          FND_MSG_PUB.ADD;
          IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		      fnd_log.string
		        (
			        fnd_log.level_error,
			        'ahl.plsql.AHL_PRD_DF_PVT.process_df_schedules',
			        'Invalid Counter name for schedule record : ' || i
		        );
          END IF;
       ELSE
          p_x_df_schedules_tbl(i).counter_id := l_counter_id;
       END IF;
       CLOSE counter_id_csr;
    END IF;
    END LOOP;

    -- raise expected error
     IF(FND_MSG_PUB.count_msg > 0)THEN
         RAISE FND_API.G_EXC_ERROR;
     END IF;

    default_unchanged_df_schedules(p_x_df_schedules_tbl => p_x_df_schedules_tbl);

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
	    (
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_df_schedules',
			'Logging deferral schedule records prior to validations'
	    );
        log_df_schedules(p_df_schedules_tbl  => p_x_df_schedules_tbl);
     END IF;

    validate_df_schedules(
       p_df_header_rec    => p_df_header_rec,
       p_df_schedules_tbl => p_x_df_schedules_tbl
    );

    IF(FND_MSG_PUB.count_msg > 0)THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;



    FOR i IN p_x_df_schedules_tbl.FIRST..p_x_df_schedules_tbl.LAST  LOOP
        IF(p_x_df_schedules_tbl(i).operation_flag = G_OP_DELETE) THEN
            AHL_UNIT_THRESHOLDS_PKG.delete_row(p_x_df_schedules_tbl(i).unit_threshold_id);
        END IF;
    END LOOP;

    FOR i IN p_x_df_schedules_tbl.FIRST..p_x_df_schedules_tbl.LAST  LOOP
        IF (p_x_df_schedules_tbl(i).operation_flag = G_OP_UPDATE) THEN

           p_x_df_schedules_tbl(i).object_version_number := p_x_df_schedules_tbl(i).object_version_number + 1;

           p_x_df_schedules_tbl(i).last_updated_by := fnd_global.user_id;
           p_x_df_schedules_tbl(i).last_update_date := SYSDATE;
           p_x_df_schedules_tbl(i).last_update_login := fnd_global.user_id;

           AHL_UNIT_THRESHOLDS_PKG.update_row(
           p_unit_threshold_id => p_x_df_schedules_tbl(i).unit_threshold_id,
           p_object_version_number => p_x_df_schedules_tbl(i).object_version_number,
           p_last_updated_by => p_x_df_schedules_tbl(i).last_updated_by,
           p_last_update_date => p_x_df_schedules_tbl(i).last_update_date,
           p_last_update_login => p_x_df_schedules_tbl(i).last_update_login,
           p_unit_deferral_id => p_x_df_schedules_tbl(i).unit_deferral_id,
           p_counter_id => p_x_df_schedules_tbl(i).counter_id,
           p_counter_value => p_x_df_schedules_tbl(i).counter_value,
           p_ctr_value_type_code => p_x_df_schedules_tbl(i).ctr_value_type_code,
           p_attribute_category => p_x_df_schedules_tbl(i).attribute_category,
           p_attribute1 => p_x_df_schedules_tbl(i).attribute1,
           p_attribute2 => p_x_df_schedules_tbl(i).attribute2,
           p_attribute3 => p_x_df_schedules_tbl(i).attribute3,
           p_attribute4 => p_x_df_schedules_tbl(i).attribute4,
           p_attribute5 => p_x_df_schedules_tbl(i).attribute5,
           p_attribute6 => p_x_df_schedules_tbl(i).attribute6,
           p_attribute7 => p_x_df_schedules_tbl(i).attribute7,
           p_attribute8 => p_x_df_schedules_tbl(i).attribute8,
           p_attribute9 => p_x_df_schedules_tbl(i).attribute9,
           p_attribute10 => p_x_df_schedules_tbl(i).attribute10,
           p_attribute11 => p_x_df_schedules_tbl(i).attribute11,
           p_attribute12 => p_x_df_schedules_tbl(i).attribute12,
           p_attribute13 => p_x_df_schedules_tbl(i).attribute13,
           p_attribute14 => p_x_df_schedules_tbl(i).attribute14,
           p_attribute15 => p_x_df_schedules_tbl(i).attribute15
           );
        END IF;
    END LOOP;
    FOR i IN p_x_df_schedules_tbl.FIRST..p_x_df_schedules_tbl.LAST  LOOP
        IF(p_x_df_schedules_tbl(i).operation_flag = G_OP_CREATE) THEN

           p_x_df_schedules_tbl(i).object_version_number := 1;

           p_x_df_schedules_tbl(i).created_by := fnd_global.user_id;
           p_x_df_schedules_tbl(i).creation_date := SYSDATE;
           p_x_df_schedules_tbl(i).last_updated_by := fnd_global.user_id;
           p_x_df_schedules_tbl(i).last_update_date := SYSDATE;
           p_x_df_schedules_tbl(i).last_update_login := fnd_global.user_id;

           AHL_UNIT_THRESHOLDS_PKG.insert_row(
           p_x_unit_threshold_id => p_x_df_schedules_tbl(i).unit_threshold_id,
           p_object_version_number => p_x_df_schedules_tbl(i).object_version_number,
           p_created_by => p_x_df_schedules_tbl(i).created_by,
           p_creation_date => p_x_df_schedules_tbl(i).creation_date,
           p_last_updated_by => p_x_df_schedules_tbl(i).last_updated_by,
           p_last_update_date => p_x_df_schedules_tbl(i).last_update_date,
           p_last_update_login => p_x_df_schedules_tbl(i).last_update_login,
           p_unit_deferral_id => p_x_df_schedules_tbl(i).unit_deferral_id,
           p_counter_id => p_x_df_schedules_tbl(i).counter_id,
           p_counter_value => p_x_df_schedules_tbl(i).counter_value,
           p_ctr_value_type_code => p_x_df_schedules_tbl(i).ctr_value_type_code,
           p_attribute_category => p_x_df_schedules_tbl(i).attribute_category,
           p_attribute1 => p_x_df_schedules_tbl(i).attribute1,
           p_attribute2 => p_x_df_schedules_tbl(i).attribute2,
           p_attribute3 => p_x_df_schedules_tbl(i).attribute3,
           p_attribute4 => p_x_df_schedules_tbl(i).attribute4,
           p_attribute5 => p_x_df_schedules_tbl(i).attribute5,
           p_attribute6 => p_x_df_schedules_tbl(i).attribute6,
           p_attribute7 => p_x_df_schedules_tbl(i).attribute7,
           p_attribute8 => p_x_df_schedules_tbl(i).attribute8,
           p_attribute9 => p_x_df_schedules_tbl(i).attribute9,
           p_attribute10 => p_x_df_schedules_tbl(i).attribute10,
           p_attribute11 => p_x_df_schedules_tbl(i).attribute11,
           p_attribute12 => p_x_df_schedules_tbl(i).attribute12,
           p_attribute13 => p_x_df_schedules_tbl(i).attribute13,
           p_attribute14 => p_x_df_schedules_tbl(i).attribute14,
           p_attribute15 => p_x_df_schedules_tbl(i).attribute15
           );
        END IF;
    END LOOP;

    IF(FND_MSG_PUB.count_msg > 0)THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.process_df_schedules.end',
			'At the end of PLSQL procedure'
		);
    END IF;

END process_df_schedules;
-----------------------------------------------------------------------------------
-- Procedure to dump deferral schedules records
-----------------------------------------------------------------------------------
PROCEDURE log_df_schedules(
    p_df_schedules_tbl    IN             AHL_PRD_DF_PVT.df_schedules_tbl_type) IS

BEGIN
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    FOR i IN p_df_schedules_tbl.FIRST..p_df_schedules_tbl.LAST  LOOP
	    fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_schedules',
			    'p_df_schedules_tbl('|| i ||').operation_flag : ' || p_df_schedules_tbl(i).operation_flag
		);
        fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_schedules',
			    'p_df_schedules_tbl('|| i ||').unit_threshold_id : ' || p_df_schedules_tbl(i).unit_threshold_id
		);
        fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_schedules',
			    'p_df_schedules_tbl('|| i ||').object_version_number : ' || p_df_schedules_tbl(i).object_version_number
		);
        fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_schedules',
			    'p_df_schedules_tbl('|| i ||').unit_deferral_id : ' || p_df_schedules_tbl(i).unit_deferral_id
		);
        fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_schedules',
			    'p_df_schedules_tbl('|| i ||').counter_id : ' || p_df_schedules_tbl(i).counter_id
		);
        fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_schedules',
			    'p_df_schedules_tbl('|| i ||').counter_name : ' || p_df_schedules_tbl(i).counter_name
		);
        fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_schedules',
			    'p_df_schedules_tbl('|| i ||').ctr_value_type_code : ' || p_df_schedules_tbl(i).ctr_value_type_code
		);
        fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_schedules',
			    'p_df_schedules_tbl('|| i ||').counter_value : ' || p_df_schedules_tbl(i).counter_value
		);
        fnd_log.string
		(
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.log_df_schedules',
			    'p_df_schedules_tbl('|| i ||').unit_of_measure : ' || p_df_schedules_tbl(i).unit_of_measure
		);
    END LOOP;
    END IF;
END log_df_schedules;

PROCEDURE validate_df_schedules(
    p_df_header_rec       IN             AHL_PRD_DF_PVT.df_header_rec_type,
    p_df_schedules_tbl    IN             AHL_PRD_DF_PVT.df_schedules_tbl_type)IS


    CURSOR valid_counter_csr(p_unit_deferral_id IN NUMBER,p_counter_id IN NUMBER) IS
    --SELECT 'x' FROM  CSI_CP_COUNTERS_V CO, AHL_UNIT_EFFECTIVITIES_APP_V UE,AHL_UNIT_DEFERRALS_B UD
    SELECT 'x' FROM  CSI_CP_COUNTERS_V CO, AHL_UNIT_EFFECTIVITIES_B UE,AHL_UNIT_DEFERRALS_B UD -- Undid app usage related blind changes
    WHERE co.customer_product_id = ue.csi_item_instance_id
    AND co.counter_id = p_counter_id
    AND UE.unit_effectivity_id = UD.unit_effectivity_id
    AND UD.unit_deferral_id = p_unit_deferral_id;

    /*CURSOR mr_valid_counter_csr(p_unit_deferral_id IN NUMBER,p_counter_id IN NUMBER) IS
    SELECT 'x' from ahl_unit_effectivities_b UE, ahl_unit_deferrals_b UD,AHL_MR_INTERVALS_V MR,CSI_CP_COUNTERS_V CO
    WHERE UD.unit_deferral_id = p_unit_deferral_id
    AND UE.unit_effectivity_id = UD.unit_effectivity_id
    AND co.customer_product_id = ue.csi_item_instance_id
    AND UE.mr_effectivity_id = MR.mr_effectivity_id
    AND CO.counter_id = p_counter_id
    AND CO.counter_name = MR.counter_name;  */


    CURSOR valid_df_rec_del_csr(p_unit_threshold_id IN NUMBER, p_object_version_number IN NUMBER) IS
    SELECT 'x' FROM ahl_unit_thresholds
    WHERE object_version_number = p_object_version_number
    AND unit_threshold_id = p_unit_threshold_id;

    l_exists VARCHAR2(1);
    --l_current_counter_value NUMBER;

BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.validate_df_schedules.begin',
			'At the start of PLSQL procedure'
		);
    END IF;

    FOR i IN p_df_schedules_tbl.FIRST..p_df_schedules_tbl.LAST  LOOP
    -- not needed when module type is JSP as value to id conversion took care of that
    IF(p_df_schedules_tbl(i).operation_flag IN (G_OP_CREATE,G_OP_UPDATE) AND NVL(G_MODULE_TYPE,'x') <> 'JSP') THEN
       -- validate whether valid items' counter
       OPEN valid_counter_csr(p_df_schedules_tbl(i).unit_deferral_id,p_df_schedules_tbl(i).counter_id);
       FETCH valid_counter_csr INTO l_exists;
       IF(valid_counter_csr%NOTFOUND)THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_CNT_NAME');
          FND_MESSAGE.Set_Token('COUNTER_NAME',p_df_schedules_tbl(i).counter_name);
          FND_MSG_PUB.ADD;
          IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		      fnd_log.string
		        (
			        fnd_log.level_error,
			        'ahl.plsql.AHL_PRD_DF_PVT.validate_df_schedules',
			        'Invalid Counter name for associated item instance in schedule record : ' || i
		        );
          END IF;
       END IF;
       CLOSE valid_counter_csr;
       -- validate whether counter defined for this MR at FMP level
       /*IF(p_df_header_rec.deferral_type = 'MR')THEN
          OPEN mr_valid_counter_csr(p_df_schedules_tbl(i).unit_deferral_id,p_df_schedules_tbl(i).counter_id);
          FETCH mr_valid_counter_csr INTO l_exists;
          IF(mr_valid_counter_csr%NOTFOUND)THEN
             FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_SCH_INV_CNT');
             FND_MSG_PUB.ADD;
          END IF;
          CLOSE mr_valid_counter_csr;
       END IF;*/

    ELSIF(p_df_schedules_tbl(i).operation_flag = G_OP_DELETE) THEN
       -- validate whether record exists for delete
       OPEN  valid_df_rec_del_csr(p_df_schedules_tbl(i).unit_threshold_id,p_df_schedules_tbl(i).object_version_number);
       FETCH valid_df_rec_del_csr INTO l_exists;
       IF(valid_df_rec_del_csr%NOTFOUND) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_SCH_REC_MISS');
          FND_MSG_PUB.ADD;
          IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		      fnd_log.string
		        (
			        fnd_log.level_error,
			        'ahl.plsql.AHL_PRD_DF_PVT.validate_df_schedules',
			        'Record for delete operation not found with keys in schedule record : ' || i
		        );
          END IF;
       END IF;
       CLOSE valid_df_rec_del_csr;
    END IF;
    END LOOP;

    -- raise expected error
     IF(FND_MSG_PUB.count_msg > 0)THEN
         RAISE FND_API.G_EXC_ERROR;
     END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.validate_df_schedules.end',
			'At the end of PLSQL procedure'
		);
    END IF;

END validate_df_schedules;

PROCEDURE default_unchanged_df_schedules(
    p_x_df_schedules_tbl    IN OUT NOCOPY  AHL_PRD_DF_PVT.df_schedules_tbl_type)IS

CURSOR df_schedules_csr(p_unit_threshold_id IN NUMBER, p_object_version_number IN NUMBER) IS
SELECT unit_deferral_id,counter_id,counter_value,ctr_value_type_code,attribute_category, attribute1,attribute2, attribute3, attribute4,
     attribute5, attribute6, attribute7, attribute8, attribute9, attribute10, attribute11,
     attribute12, attribute13, attribute14, attribute15
FROM ahl_unit_thresholds
WHERE object_version_number= p_object_version_number
AND unit_threshold_id = p_unit_threshold_id;

l_df_schedules_rec AHL_PRD_DF_PVT.df_schedules_rec_type;

BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.default_unchanged_df_schedules.begin',
			'At the start of PLSQL procedure'
		);
    END IF;

    FOR i IN p_x_df_schedules_tbl.FIRST..p_x_df_schedules_tbl.LAST  LOOP
    IF(p_x_df_schedules_tbl(i).operation_flag = G_OP_UPDATE) THEN
        OPEN df_schedules_csr(p_x_df_schedules_tbl(i).unit_threshold_id, p_x_df_schedules_tbl(i).object_version_number);
        FETCH df_schedules_csr INTO l_df_schedules_rec.unit_deferral_id,l_df_schedules_rec.counter_id,
         l_df_schedules_rec.counter_value, l_df_schedules_rec.ctr_value_type_code,
         l_df_schedules_rec.attribute_category,l_df_schedules_rec.attribute1,l_df_schedules_rec.attribute2,
         l_df_schedules_rec.attribute3, l_df_schedules_rec.attribute4, l_df_schedules_rec.attribute5,
         l_df_schedules_rec.attribute6, l_df_schedules_rec.attribute7, l_df_schedules_rec.attribute8,
         l_df_schedules_rec.attribute9, l_df_schedules_rec.attribute10, l_df_schedules_rec.attribute11,
         l_df_schedules_rec.attribute12, l_df_schedules_rec.attribute13, l_df_schedules_rec.attribute14, l_df_schedules_rec.attribute15;
        IF (df_schedules_csr%NOTFOUND) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_SCH_REC_MISS');
            FND_MSG_PUB.ADD;
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		         fnd_log.string
		         (
			         fnd_log.level_error,
			         'ahl.plsql.AHL_PRD_DF_PVT.default_unchanged_df_schedules',
			         'Missing Deferral Schedule Record : ' || i
		         );
            END IF;
        ELSE
            IF (p_x_df_schedules_tbl(i).unit_deferral_id IS NULL) THEN
                p_x_df_schedules_tbl(i).unit_deferral_id := l_df_schedules_rec.unit_deferral_id;
            ELSIF(p_x_df_schedules_tbl(i).unit_deferral_id <> l_df_schedules_rec.unit_deferral_id) THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_SCH_HDR_MISS');
                FND_MSG_PUB.ADD;
                IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		           fnd_log.string
		            (
			         fnd_log.level_unexpected,
			         'ahl.plsql.AHL_PRD_DF_PVT.default_unchanged_df_schedules',
			         'Unit Deferral ID does not match with deferral schedule record : ' || i
		            );
                END IF;
                CLOSE df_schedules_csr;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF (p_x_df_schedules_tbl(i).counter_id IS NULL) THEN
                p_x_df_schedules_tbl(i).counter_id := l_df_schedules_rec.counter_id;
            ELSIF(p_x_df_schedules_tbl(i).counter_id = FND_API.G_MISS_NUM) THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_CNT_NAME');
                FND_MESSAGE.Set_Token('COUNTER_NAME',p_x_df_schedules_tbl(i).counter_name);
                IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		            fnd_log.string
		            (
			            fnd_log.level_error,
			            'ahl.plsql.AHL_PRD_DF_PVT.default_unchanged_df_schedules',
			            'Missing counter ID in schedule Record : ' || i
		            );
               END IF;
            END IF;

            IF (p_x_df_schedules_tbl(i).counter_value IS NULL) THEN
                p_x_df_schedules_tbl(i).counter_value := l_df_schedules_rec.counter_value;
            ELSIF(p_x_df_schedules_tbl(i).counter_value = FND_API.G_MISS_NUM OR
                  p_x_df_schedules_tbl(i).counter_value <= 0) THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_CNTVAL');
                FND_MESSAGE.Set_Token('COUNTER_NAME',p_x_df_schedules_tbl(i).counter_name);
                FND_MESSAGE.Set_Token('COUNTER_VALUE',p_x_df_schedules_tbl(i).counter_value);
                FND_MSG_PUB.ADD;
                IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		            fnd_log.string
		            (
			            fnd_log.level_error,
			            'ahl.plsql.AHL_PRD_DF_PVT.default_unchanged_df_schedules',
			            'Missing counter Value in schedule Record : ' || i
		            );
               END IF;
            END IF;

            IF (p_x_df_schedules_tbl(i).ctr_value_type_code IS NULL) THEN
                p_x_df_schedules_tbl(i).ctr_value_type_code := l_df_schedules_rec.ctr_value_type_code;
            ELSIF(p_x_df_schedules_tbl(i).ctr_value_type_code NOT IN(G_DEFER_BY,G_DEFER_TO)) THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_CNTVL_TPCD');
                FND_MSG_PUB.ADD;
                IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		           fnd_log.string
		            (
			         fnd_log.level_unexpected,
			         'ahl.plsql.AHL_PRD_DF_PVT.default_unchanged_df_schedules',
			         'Invalid counter value type code in deferral schedule record : ' || i
		            );
                END IF;
                CLOSE df_schedules_csr;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF (p_x_df_schedules_tbl(i).attribute_category IS NULL) THEN
                p_x_df_schedules_tbl(i).attribute_category := l_df_schedules_rec.attribute_category;
            ELSIF(p_x_df_schedules_tbl(i).attribute_category = FND_API.G_MISS_CHAR) THEN
                p_x_df_schedules_tbl(i).attribute_category := NULL;
            END IF;

            IF (p_x_df_schedules_tbl(i).attribute1 IS NULL) THEN
                p_x_df_schedules_tbl(i).attribute1 := l_df_schedules_rec.attribute1;
            ELSIF(p_x_df_schedules_tbl(i).attribute1 = FND_API.G_MISS_CHAR) THEN
                p_x_df_schedules_tbl(i).attribute1 := NULL;
            END IF;

            IF (p_x_df_schedules_tbl(i).attribute2 IS NULL) THEN
                p_x_df_schedules_tbl(i).attribute2 := l_df_schedules_rec.attribute2;
            ELSIF(p_x_df_schedules_tbl(i).attribute2 = FND_API.G_MISS_CHAR) THEN
                p_x_df_schedules_tbl(i).attribute2 := NULL;
            END IF;

            IF (p_x_df_schedules_tbl(i).attribute3 IS NULL) THEN
                p_x_df_schedules_tbl(i).attribute3 := l_df_schedules_rec.attribute3;
            ELSIF(p_x_df_schedules_tbl(i).attribute3 = FND_API.G_MISS_CHAR) THEN
                p_x_df_schedules_tbl(i).attribute3 := NULL;
            END IF;

            IF (p_x_df_schedules_tbl(i).attribute4 IS NULL) THEN
                p_x_df_schedules_tbl(i).attribute4 := l_df_schedules_rec.attribute4;
            ELSIF(p_x_df_schedules_tbl(i).attribute4 = FND_API.G_MISS_CHAR) THEN
                p_x_df_schedules_tbl(i).attribute4 := NULL;
            END IF;

            IF (p_x_df_schedules_tbl(i).attribute5 IS NULL) THEN
                p_x_df_schedules_tbl(i).attribute5 := l_df_schedules_rec.attribute5;
            ELSIF(p_x_df_schedules_tbl(i).attribute5 = FND_API.G_MISS_CHAR) THEN
                p_x_df_schedules_tbl(i).attribute5 := NULL;
            END IF;

            IF (p_x_df_schedules_tbl(i).attribute6 IS NULL) THEN
                p_x_df_schedules_tbl(i).attribute6 := l_df_schedules_rec.attribute6;
            ELSIF(p_x_df_schedules_tbl(i).attribute6 = FND_API.G_MISS_CHAR) THEN
                p_x_df_schedules_tbl(i).attribute6 := NULL;
            END IF;

            IF (p_x_df_schedules_tbl(i).attribute7 IS NULL) THEN
                p_x_df_schedules_tbl(i).attribute7 := l_df_schedules_rec.attribute7;
            ELSIF(p_x_df_schedules_tbl(i).attribute7 = FND_API.G_MISS_CHAR) THEN
                p_x_df_schedules_tbl(i).attribute7 := NULL;
            END IF;

            IF (p_x_df_schedules_tbl(i).attribute8 IS NULL) THEN
                p_x_df_schedules_tbl(i).attribute8 := l_df_schedules_rec.attribute8;
            ELSIF(p_x_df_schedules_tbl(i).attribute8 = FND_API.G_MISS_CHAR) THEN
                p_x_df_schedules_tbl(i).attribute8 := NULL;
            END IF;

            IF (p_x_df_schedules_tbl(i).attribute9 IS NULL) THEN
                p_x_df_schedules_tbl(i).attribute9 := l_df_schedules_rec.attribute9;
            ELSIF(p_x_df_schedules_tbl(i).attribute9 = FND_API.G_MISS_CHAR) THEN
                p_x_df_schedules_tbl(i).attribute9 := NULL;
            END IF;

            IF (p_x_df_schedules_tbl(i).attribute10 IS NULL) THEN
                p_x_df_schedules_tbl(i).attribute10 := l_df_schedules_rec.attribute10;
            ELSIF(p_x_df_schedules_tbl(i).attribute10 = FND_API.G_MISS_CHAR) THEN
                p_x_df_schedules_tbl(i).attribute10 := NULL;
            END IF;

            IF (p_x_df_schedules_tbl(i).attribute11 IS NULL) THEN
                p_x_df_schedules_tbl(i).attribute11 := l_df_schedules_rec.attribute11;
            ELSIF(p_x_df_schedules_tbl(i).attribute11 = FND_API.G_MISS_CHAR) THEN
                p_x_df_schedules_tbl(i).attribute11 := NULL;
            END IF;

            IF (p_x_df_schedules_tbl(i).attribute12 IS NULL) THEN
                p_x_df_schedules_tbl(i).attribute12 := l_df_schedules_rec.attribute12;
            ELSIF(p_x_df_schedules_tbl(i).attribute12 = FND_API.G_MISS_CHAR) THEN
                p_x_df_schedules_tbl(i).attribute12 := NULL;
            END IF;

            IF (p_x_df_schedules_tbl(i).attribute13 IS NULL) THEN
                p_x_df_schedules_tbl(i).attribute13 := l_df_schedules_rec.attribute13;
            ELSIF(p_x_df_schedules_tbl(i).attribute13 = FND_API.G_MISS_CHAR) THEN
                p_x_df_schedules_tbl(i).attribute13 := NULL;
            END IF;

            IF (p_x_df_schedules_tbl(i).attribute14 IS NULL) THEN
                p_x_df_schedules_tbl(i).attribute14 := l_df_schedules_rec.attribute14;
            ELSIF(p_x_df_schedules_tbl(i).attribute14 = FND_API.G_MISS_CHAR) THEN
                p_x_df_schedules_tbl(i).attribute14 := NULL;
            END IF;

            IF (p_x_df_schedules_tbl(i).attribute15 IS NULL) THEN
                p_x_df_schedules_tbl(i).attribute15 := l_df_schedules_rec.attribute15;
            ELSIF(p_x_df_schedules_tbl(i).attribute15 = FND_API.G_MISS_CHAR) THEN
                p_x_df_schedules_tbl(i).attribute15 := NULL;
            END IF;

        END IF;
        CLOSE df_schedules_csr;
    ELSIF (p_x_df_schedules_tbl(i).operation_flag = G_OP_CREATE) THEN

        IF (p_x_df_schedules_tbl(i).unit_deferral_id IS NULL OR
            p_x_df_schedules_tbl(i).unit_deferral_id = FND_API.G_MISS_NUM) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_UDID');
            FND_MSG_PUB.ADD;
            IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		        fnd_log.string
		        (
			      fnd_log.level_unexpected,
			      'ahl.plsql.AHL_PRD_DF_PVT.default_unchanged_df_schedules',
			      'Missing Unit Deferral ID for create operation in deferral schedule record : ' || i
		        );
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (p_x_df_schedules_tbl(i).counter_id IS NULL OR
            p_x_df_schedules_tbl(i).counter_id = FND_API.G_MISS_NUM) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_CNT_NAME');
            FND_MESSAGE.Set_Token('COUNTER_NAME',p_x_df_schedules_tbl(i).counter_name);
            FND_MSG_PUB.ADD;
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		        fnd_log.string
		        (
			         fnd_log.level_error,
			         'ahl.plsql.AHL_PRD_DF_PVT.default_unchanged_df_schedules',
			         'Missing counter ID in schedule Record : ' || i
		        );
           END IF;
        END IF;

        IF (p_x_df_schedules_tbl(i).counter_value IS NULL OR
            p_x_df_schedules_tbl(i).counter_value = FND_API.G_MISS_NUM OR
            p_x_df_schedules_tbl(i).counter_value <= 0 ) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_CNTVAL');
            FND_MESSAGE.Set_Token('COUNTER_NAME',p_x_df_schedules_tbl(i).counter_name);
            FND_MESSAGE.Set_Token('COUNTER_VALUE',p_x_df_schedules_tbl(i).counter_value);
            FND_MSG_PUB.ADD;
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		        fnd_log.string
		        (
			         fnd_log.level_error,
			         'ahl.plsql.AHL_PRD_DF_PVT.default_unchanged_df_schedules',
			         'Missing or invalid counter Value in schedule Record : ' || i
		        );
           END IF;
        END IF;

        IF (p_x_df_schedules_tbl(i).ctr_value_type_code IS NULL OR
            p_x_df_schedules_tbl(i).ctr_value_type_code NOT IN(G_DEFER_BY,G_DEFER_TO)) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_CNTVL_TPCD');
            FND_MSG_PUB.ADD;
            IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		        fnd_log.string
		        (
			       fnd_log.level_unexpected,
			       'ahl.plsql.AHL_PRD_DF_PVT.default_unchanged_df_schedules',
			       'Invalid counter value type code in deferral schedule record : ' || i
		        );
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (p_x_df_schedules_tbl(i).attribute_category = FND_API.G_MISS_CHAR) THEN
            p_x_df_schedules_tbl(i).attribute_category := NULL;
        END IF;

        IF (p_x_df_schedules_tbl(i).attribute1 = FND_API.G_MISS_CHAR) THEN
            p_x_df_schedules_tbl(i).attribute1 := NULL;
        END IF;

        IF (p_x_df_schedules_tbl(i).attribute2 = FND_API.G_MISS_CHAR) THEN
            p_x_df_schedules_tbl(i).attribute2 := NULL;
        END IF;

        IF (p_x_df_schedules_tbl(i).attribute3 = FND_API.G_MISS_CHAR) THEN
            p_x_df_schedules_tbl(i).attribute3 := NULL;
        END IF;

        IF (p_x_df_schedules_tbl(i).attribute4 = FND_API.G_MISS_CHAR) THEN
            p_x_df_schedules_tbl(i).attribute4 := NULL;
        END IF;

        IF (p_x_df_schedules_tbl(i).attribute5 = FND_API.G_MISS_CHAR) THEN
            p_x_df_schedules_tbl(i).attribute5 := NULL;
        END IF;

        IF (p_x_df_schedules_tbl(i).attribute6 = FND_API.G_MISS_CHAR) THEN
            p_x_df_schedules_tbl(i).attribute6 := NULL;
        END IF;

        IF (p_x_df_schedules_tbl(i).attribute7 = FND_API.G_MISS_CHAR) THEN
            p_x_df_schedules_tbl(i).attribute7 := NULL;
        END IF;

        IF (p_x_df_schedules_tbl(i).attribute8 = FND_API.G_MISS_CHAR) THEN
            p_x_df_schedules_tbl(i).attribute8 := NULL;
        END IF;

        IF (p_x_df_schedules_tbl(i).attribute9 = FND_API.G_MISS_CHAR) THEN
            p_x_df_schedules_tbl(i).attribute9 := NULL;
        END IF;

        IF (p_x_df_schedules_tbl(i).attribute10 = FND_API.G_MISS_CHAR) THEN
            p_x_df_schedules_tbl(i).attribute10 := NULL;
        END IF;

        IF (p_x_df_schedules_tbl(i).attribute11 = FND_API.G_MISS_CHAR) THEN
            p_x_df_schedules_tbl(i).attribute11 := NULL;
        END IF;

        IF (p_x_df_schedules_tbl(i).attribute12 = FND_API.G_MISS_CHAR) THEN
            p_x_df_schedules_tbl(i).attribute12 := NULL;
        END IF;

        IF (p_x_df_schedules_tbl(i).attribute13 = FND_API.G_MISS_CHAR) THEN
            p_x_df_schedules_tbl(i).attribute13 := NULL;
        END IF;

        IF (p_x_df_schedules_tbl(i).attribute14 = FND_API.G_MISS_CHAR) THEN
            p_x_df_schedules_tbl(i).attribute14 := NULL;
        END IF;

        IF (p_x_df_schedules_tbl(i).attribute15 = FND_API.G_MISS_CHAR) THEN
            p_x_df_schedules_tbl(i).attribute15 := NULL;
        END IF;

    END IF;
    END LOOP;

    -- raise expected error
    IF(FND_MSG_PUB.count_msg > 0)THEN
         RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.default_unchanged_df_schedules.end',
			'At the end of PLSQL procedure'
		);
    END IF;

END default_unchanged_df_schedules;
--------------------------------------------------------------------------------
-- Validate deferral record as a whole
--------------------------------------------------------------------------------

PROCEDURE validate_deferral_updates(
    p_df_header_rec       IN             AHL_PRD_DF_PVT.df_header_rec_type,
    x_warning_msg_data            OUT NOCOPY VARCHAR2)IS

    l_count1 NUMBER;
    l_count2 NUMBER;

    CURSOR counter_values_csr(p_unit_deferral_id IN NUMBER) IS
    SELECT UT.counter_id, CO.name, UT.counter_value, UT.ctr_value_type_code,CO.uom_code
    FROM CS_COUNTERS CO,ahl_unit_thresholds UT
    WHERE CO.counter_id = UT.counter_id
    AND UT.unit_deferral_id = p_unit_deferral_id;

    l_counter_id NUMBER;
    l_counter_name VARCHAR2(30);
    l_uom_code VARCHAR2(3);
    l_counter_value NUMBER;
    l_ctr_value_type_code VARCHAR2(30);
    i NUMBER := 0;
    l_defer_due_date DATE;
    l_calc_due_date_flag BOOLEAN := false;
    l_current_counter_value NUMBER := 0;

    l_return_status  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_data       VARCHAR2(4000);
    l_msg_count      NUMBER;

    CURSOR curr_counter_val_csr(p_unit_deferral_id IN NUMBER, p_counter_id IN NUMBER,p_deferral_effective_on IN DATE) IS
    /* Modified to fix bug# 8328818: ignore disabled counter readings.
    SELECT NVL(net_reading, 0) FROM cs_ctr_counter_values_v ctrread, cs_counter_groups_v ctrgrp,
    --                                AHL_UNIT_EFFECTIVITIES_APP_V UE,AHL_UNIT_DEFERRALS_B UD
                                    AHL_UNIT_EFFECTIVITIES_B UE,AHL_UNIT_DEFERRALS_B UD -- Undid app usage related blind changes
    WHERE ctrread.VALUE_TIMESTAMP <= p_deferral_effective_on
    AND ctrread.counter_group_id = ctrgrp.counter_group_id
    AND SOURCE_OBJECT_CODE = 'CP'
    AND SOURCE_OBJECT_ID = UE.csi_item_instance_id
    AND ctrread.counter_id = p_counter_id
    AND UE.unit_effectivity_id = UD.unit_effectivity_id
    AND UD.unit_deferral_id = p_unit_deferral_id
    ORDER BY ctrread.counter_id asc, ctrread.VALUE_TIMESTAMP desc;
    */

    -- Fix for bug# 8328818: ignore disabled counter readings.
    -- rewrote above query as we do not need AHL_UNIT_EFFECTIVITIES_B,
    -- cs_counter_groups_v, AHL_UNIT_DEFERRALS_B tables.
    SELECT * FROM (
                   SELECT CCR.NET_READING
                   FROM CSI_COUNTER_READINGS CCR
                   WHERE CCR.COUNTER_ID = P_COUNTER_ID
                     AND nvl(CCR.disabled_flag,'N') = 'N'
                     AND CCR.VALUE_TIMESTAMP <= p_deferral_effective_on
                   ORDER BY CCR.VALUE_TIMESTAMP DESC
                  )
    WHERE rownum < 2;

    l_counter_values_tbl AHL_UMP_PROCESSUNIT_PVT.counter_values_tbl_type;

    CURSOR whichever_first_code_csr (p_unit_effectivity_id IN NUMBER) IS
    SELECT whichever_first_code
    --FROM AHL_MR_HEADERS_APP_V MR, AHL_UNIT_EFFECTIVITIES_APP_V UE
    FROM AHL_MR_HEADERS_B MR, AHL_UNIT_EFFECTIVITIES_B UE -- Undid blind changes for app_usage code
    WHERE MR.mr_header_id = UE.mr_header_id
    AND UE.unit_effectivity_id = p_unit_effectivity_id;

    l_whichever_first_code ahl_mr_headers_b.whichever_first_code%TYPE;


    CURSOR next_due_date_csr(p_unit_effectivity_id IN NUMBER) IS
    SELECT UE.due_date
    FROM AHL_UNIT_EFFECTIVITIES_B UE
    WHERE UE.mr_header_id = (
    SELECT mr_header_id FROM AHL_UNIT_EFFECTIVITIES_B where unit_effectivity_id = p_unit_effectivity_id)
    AND UE.csi_item_instance_id = (
    SELECT csi_item_instance_id FROM AHL_UNIT_EFFECTIVITIES_B where unit_effectivity_id = p_unit_effectivity_id)
    AND UE.unit_effectivity_id <> p_unit_effectivity_id
    AND ( UE.status_code IS NULL OR UE.status_code = 'INIT-DUE')
    ORDER BY DUE_DATE ASC;

    l_next_due_date DATE;


BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.validate_deferral_updates.begin',
			'At the start of PLSQL procedure'
		);
    END IF;

    -- df schedule validity for the the unit_deferral_id.
    SELECT count(*) INTO l_count1 from (SELECT counter_id FROM ahl_unit_thresholds
                                        WHERE unit_deferral_id = p_df_header_rec.unit_deferral_id);

    SELECT count(*) INTO l_count2 from (SELECT DISTINCT counter_id FROM ahl_unit_thresholds
                                        WHERE unit_deferral_id = p_df_header_rec.unit_deferral_id);
    IF(l_count1 <> l_count2) THEN
       FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_CNT_NAME_REP');
       FND_MSG_PUB.ADD;
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		   fnd_log.string
		   (
			   fnd_log.level_error,
			   'ahl.plsql.AHL_PRD_DF_PVT.validate_deferral_updates',
			   'Counters are repeating in schedules'
		   );
       END IF;
    END IF;

    IF(l_count2 = 0)THEN
      IF(p_df_header_rec.set_due_date IS NULL)THEN
         FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_SET_DUE_MAND');
         FND_MSG_PUB.ADD;
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		     fnd_log.string
		     (
			        fnd_log.level_error,
			        'ahl.plsql.AHL_PRD_DF_PVT.validate_deferral_updates',
			        'Set due date or counter values are mandatory '
		    );
        END IF;
      ELSE
         l_defer_due_date := p_df_header_rec.set_due_date;
      END IF;
    ELSE
      l_calc_due_date_flag := true;
      IF(p_df_header_rec.deferral_effective_on IS NULL OR p_df_header_rec.deferral_effective_on > SYSDATE)THEN
         FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_DF_EFF_DT');
         FND_MESSAGE.Set_Token('DEFERRAL_EFFECTIVE_ON',p_df_header_rec.deferral_effective_on);
         FND_MSG_PUB.ADD;
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		     fnd_log.string
		     (
			        fnd_log.level_error,
			        'ahl.plsql.AHL_PRD_DF_PVT.validate_deferral_updates',
			        'Deferral Effective On Date can not be null or greater than system date '
		     );
        END IF;
      END IF;
    END IF;

    IF(FND_MSG_PUB.count_msg > 0)THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF(l_calc_due_date_flag)THEN
       -- validate counter values and populate table of counter, values to calculate due date
       OPEN counter_values_csr(p_df_header_rec.unit_deferral_id);
       LOOP
          FETCH counter_values_csr INTO l_counter_id,l_counter_name,
                                           l_counter_value,l_ctr_value_type_code,
                                           l_uom_code;
          IF(counter_values_csr%NOTFOUND) THEN
             EXIT;
          END IF;
          OPEN curr_counter_val_csr(p_df_header_rec.unit_deferral_id,l_counter_id,p_df_header_rec.deferral_effective_on);
          FETCH curr_counter_val_csr INTO l_current_counter_value;
          IF(curr_counter_val_csr%NOTFOUND) THEN
            l_current_counter_value := 0;
          END IF;
          CLOSE curr_counter_val_csr;
          IF(l_ctr_value_type_code = G_DEFER_BY) THEN
             l_counter_value := l_current_counter_value + l_counter_value;
          ELSE
             IF(l_counter_value < l_current_counter_value) THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_LS_CNTVAL');
                FND_MESSAGE.Set_Token('COUNTER_NAME',l_counter_name);
                FND_MESSAGE.Set_Token('COUNTER_VALUE',l_counter_value);
                FND_MSG_PUB.ADD;
                IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		            fnd_log.string
		            (
			            fnd_log.level_error,
			            'ahl.plsql.AHL_PRD_DF_PVT.validate_deferral_updates',
			            'Defer to counter value is less than current counter value for counter name : ' || l_counter_name
		            );
                END IF;
             END IF;
          END IF;
          l_counter_values_tbl(i).counter_id    := l_counter_id;
          l_counter_values_tbl(i).counter_name  := l_counter_name;
          l_counter_values_tbl(i).counter_value := l_counter_value;
          l_counter_values_tbl(i).uom_code      := l_uom_code;
          i := i + 1;
       END LOOP;
       CLOSE counter_values_csr;
       -- throw errors if any here and do not proceed.
       IF(FND_MSG_PUB.count_msg > 0)THEN
        RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF((p_df_header_rec.deferral_type = G_DEFERRAL_TYPE_MR) AND
          (p_df_header_rec.mr_repetitive_flag = G_YES_FLAG)) THEN
          -- make a call to calculate due date with the table if mr is repetitive
          AHL_UMP_PROCESSUNIT_PVT.Get_Deferred_Due_Date (
                                 p_unit_effectivity_id    => p_df_header_rec.unit_effectivity_id,
                                 p_deferral_threshold_tbl => l_counter_values_tbl,
                                 x_due_date               => l_defer_due_date,
                                 x_return_status          => l_return_status ,
                                 x_msg_data               => l_msg_data,
                                 x_msg_count              => l_msg_count);
          IF(l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
             FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_DUE_DT_CALC_ERR');
             FND_MSG_PUB.ADD;
             IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		         fnd_log.string
		         (
			            fnd_log.level_unexpected,
			            'ahl.plsql.AHL_PRD_DF_PVT.validate_deferral_updates',
			            'Calculate Due Date API threw Error'
		         );
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          IF(l_defer_due_date IS NOT NULL)THEN
            -- read whicever comes first or last code
            OPEN whichever_first_code_csr(p_df_header_rec.unit_effectivity_id);
            FETCH whichever_first_code_csr INTO l_whichever_first_code;
            IF(whichever_first_code_csr%NOTFOUND)THEN
                l_whichever_first_code := 'FIRST';
            END IF;
            CLOSE whichever_first_code_csr;

            IF(l_whichever_first_code = 'FIRST') THEN
                IF(TRUNC(p_df_header_rec.set_due_date) < TRUNC(l_defer_due_date)) THEN
                    l_defer_due_date := p_df_header_rec.set_due_date;
                END IF;
            ELSE
                IF(TRUNC(p_df_header_rec.set_due_date) > TRUNC(l_defer_due_date)) THEN
                l_defer_due_date := p_df_header_rec.set_due_date;
                END IF;
            END IF;
            -- read next due date if available
            OPEN next_due_date_csr(p_df_header_rec.unit_effectivity_id);
            FETCH next_due_date_csr INTO l_next_due_date;
            IF(next_due_date_csr%NOTFOUND)THEN
                NULL;-- thorw warning here
            ELSIF( TRUNC(l_next_due_date) < TRUNC(l_defer_due_date))THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_DUE_DATE_WARN');
                FND_MESSAGE.SET_TOKEN('DEFER_DUE_DATE',l_defer_due_date,false);
                FND_MESSAGE.SET_TOKEN('NEXT_DUE_DATE',l_next_due_date,false);
                l_msg_data := FND_MESSAGE.get;
            END IF;
            CLOSE next_due_date_csr;
          END IF;

       END IF;
    END IF;
    -- add validations here if needed in future
    -- throw errors if any
    IF(FND_MSG_PUB.count_msg > 0)THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_warning_msg_data := l_msg_data;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.validate_deferral_updates.end',
			'At the end of PLSQL procedure'
		);
    END IF;

END validate_deferral_updates;

PROCEDURE submit_for_approval(
    p_df_header_rec       IN             AHL_PRD_DF_PVT.df_header_rec_type)IS

    l_object                VARCHAR2(30):= G_WORKFLOW_OBJECT_KEY;
    l_approval_type         VARCHAR2(100):='CONCEPT';
    l_active                VARCHAR2(50):= 'N';
    l_process_name          VARCHAR2(50);
    l_item_type             VARCHAR2(50);
    l_return_status         VARCHAR2(50) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

    l_new_status_code   VARCHAR2(30);

BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.submit_for_approval.begin',
			'At the start of PLSQL procedure'
		);
    END IF;

    IF(p_df_header_rec.approval_status_code NOT IN('DRAFT','DEFERRAL_REJECTED'))THEN
       FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_SUB_APPR_STS');
       FND_MSG_PUB.ADD;
       IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
           fnd_log.string
	       (
              fnd_log.level_unexpected,
			  'ahl.plsql.AHL_PRD_DF_PVT.submit_for_approval',
		      'Can not submit for approval because current status is : ' || p_df_header_rec.approval_status_code
           );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF(valid_for_submission( p_df_header_rec.unit_effectivity_id) = FALSE)THEN
       FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_SUB_PRC_STS');
       FND_MSG_PUB.ADD;
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		   fnd_log.string
		   (
			  fnd_log.level_error,
			  'ahl.plsql.AHL_PRD_DF_PVT.submit_for_approval',
			  'Can not submit for approval because a parent or child is in pending deferral approval status'
		   );
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Skip for UMP Deferral
    IF NOT(is_ump_deferral(p_df_header_rec.unit_deferral_id)) THEN

       AHL_PRD_WORKORDER_PVT.validate_dependencies
       (
           p_api_version         => 1.0,
           p_init_msg_list       => FND_API.G_TRUE,
           p_commit              => FND_API.G_FALSE,
           p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
           p_default             => FND_API.G_FALSE,
           p_module_type         => NULL,
           x_return_status       =>l_return_status,
           x_msg_count           =>l_msg_count,
           x_msg_data            =>l_msg_data,
           p_visit_id            => NULL,
           p_unit_effectivity_id =>p_df_header_rec.unit_effectivity_id,
           p_workorder_id        => NULL
       );
    -- if workorders under UE has external dependencies, dont submit for approval, raise error.
       IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		   fnd_log.string
		      (
			    fnd_log.level_error,
			    'ahl.plsql.AHL_PRD_DF_PVT.submit_for_approval',
			    'Can not go ahead with aubmission of approval because Workorder dependencies exists'
		      );
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF; -- l_return_status
    END IF; -- is_ump_deferral.

    ahl_utility_pvt.get_wf_process_name(
                                    p_object       =>l_object,
                                    x_active       =>l_active,
                                    x_process_name =>l_process_name ,
                                    x_item_type    =>l_item_type,
                                    x_return_status=>l_return_status,
                                    x_msg_count    =>l_msg_count,
                                    x_msg_data     =>l_msg_data);
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		   fnd_log.string
		   (
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.submit_for_approval',
			    'Workflow active flag : ' || l_active
		   );
           fnd_log.string
		   (
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.submit_for_approval',
			    'l_process_name : ' || l_process_name
		   );
           fnd_log.string
		   (
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.submit_for_approval',
			    'l_item_type : ' || l_item_type
		   );

    END IF;

    IF((l_return_status <> FND_API.G_RET_STS_SUCCESS) OR
       ( l_active <> G_YES_FLAG))THEN
       /*FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_WF_INACTIVE');
       FND_MSG_PUB.ADD;
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		   fnd_log.string
		      (
			    fnd_log.level_error,
			    'ahl.plsql.AHL_PRD_DF_PVT.submit_for_approval',
			    'Can not submit for approval because workflow is not active for Deferral'
		      );
       END IF;
       RAISE FND_API.G_EXC_ERROR;*/
       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		   fnd_log.string
		      (
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.submit_for_approval',
			    'Workflow is not active so going for automatic approval'
		      );
       END IF;
       l_active := G_NO_FLAG;
    END IF;

    -- make a call to update job status to pending deferral approval and update approval status
    AHL_PRD_DF_PVT.process_approval_initiated(
                         p_unit_deferral_id      => p_df_header_rec.unit_deferral_id,
                         p_object_version_number => p_df_header_rec.object_version_number,
                         p_new_status            => 'DEFERRAL_PENDING',
                         x_return_status         => l_return_status);


    IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		   fnd_log.string
		      (
			    fnd_log.level_error,
			    'ahl.plsql.AHL_PRD_DF_PVT.submit_for_approval',
			    'Can not go ahead with approval because AHL_PRD_DF_PVT.process_approval_initiated threw error'
		      );
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		   fnd_log.string
		   (
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.submit_for_approval',
			    'Workflow active flag : ' || l_active
		   );
    END IF;

    IF(p_df_header_rec.skip_mr_flag = G_YES_FLAG AND p_df_header_rec.manually_planned_flag = G_NO_FLAG)THEN
       l_new_status_code := 'TERMINATED';
    ELSIF(p_df_header_rec.skip_mr_flag = G_YES_FLAG AND p_df_header_rec.manually_planned_flag = G_YES_FLAG)THEN
       l_new_status_code := 'CANCELLED';
    ELSE
       l_new_status_code := 'DEFERRED';
    END IF;

    IF(l_active <> G_NO_FLAG)THEN
       Ahl_generic_aprv_pvt.Start_Wf_Process(
                         P_OBJECT                => l_object,
                         P_APPROVAL_TYPE         => 'CONCEPT',
                         P_ACTIVITY_ID           => p_df_header_rec.unit_deferral_id,--unit_deferral_id
                         P_OBJECT_VERSION_NUMBER => p_df_header_rec.object_version_number,
                         P_ORIG_STATUS_CODE      => p_df_header_rec.approval_status_code,
                         P_NEW_STATUS_CODE       => l_new_status_code ,
                         P_REJECT_STATUS_CODE    => 'DEFERRAL_REJECTED',
                         P_REQUESTER_USERID      => fnd_global.user_id,--1003259,--
                         P_NOTES_FROM_REQUESTER  => '',
                         P_WORKFLOWPROCESS       => 'AHL_GEN_APPROVAL',
                         P_ITEM_TYPE             => 'AHLGAPP');
    ELSE
      -- make a call for automatic approval
      AHL_PRD_DF_PVT.process_approval_approved(
                         p_unit_deferral_id      => p_df_header_rec.unit_deferral_id,
                         p_object_version_number => p_df_header_rec.object_version_number,
                         p_new_status            => l_new_status_code,
                         x_return_status         => l_return_status);
      IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		   fnd_log.string
		      (
			    fnd_log.level_error,
			    'ahl.plsql.AHL_PRD_DF_PVT.submit_for_approval',
			    'Can not go ahead with automatic approval because AHL_PRD_DF_PVT.process_approval_approved threw error'
		      );
       END IF;
       RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- throw errors if any
    IF(FND_MSG_PUB.count_msg > 0)THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.submit_for_approval.end',
			'At the end of PLSQL procedure'
		);
    END IF;

END submit_for_approval;

-------------------------------------------------------------------------
FUNCTION valid_for_submission(
    p_unit_effectivity_id IN             NUMBER) RETURN BOOLEAN IS


    CURSOR status_code_csr(p_unit_effectivity_id IN NUMBER)IS
    SELECT approval_status_code FROM ahl_unit_deferrals_b
    WHERE  unit_effectivity_id = p_unit_effectivity_id
    UNION
    SELECT approval_status_code FROM ahl_unit_deferrals_b
    WHERE unit_effectivity_id IN
       (

         /*SELECT     ue_id
         FROM       AHL_UE_RELATIONSHIPS
         WHERE      relationship_code = 'PARENT'
         START WITH related_ue_id = p_unit_effectivity_id
         CONNECT BY related_ue_id = PRIOR ue_id
         UNION*/--parents are taken care of by now
         SELECT    distinct related_ue_id
         FROM       AHL_UE_RELATIONSHIPS
         WHERE      relationship_code = 'PARENT'
         START WITH ue_id = p_unit_effectivity_id
         CONNECT BY ue_id = PRIOR related_ue_id
       );

    l_approval_status_code VARCHAR2(30);


BEGIN

    OPEN status_code_csr(p_unit_effectivity_id);
    LOOP
        FETCH status_code_csr INTO l_approval_status_code;
        IF(l_approval_status_code = 'DEFERRAL_PENDING')THEN
           CLOSE status_code_csr;
           RETURN FALSE;
        END IF;
    EXIT WHEN status_code_csr%NOTFOUND;
    END LOOP;

    RETURN TRUE;

END valid_for_submission;


PROCEDURE process_approval_initiated (

    p_unit_deferral_id      IN             NUMBER,
    p_object_version_number IN             NUMBER,
    p_new_status            IN             VARCHAR2,
    x_return_status         OUT NOCOPY     VARCHAR2)IS

BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.process_approval_initiated.begin',
			'At the start of PLSQL procedure'
		);
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF NOT(is_ump_deferral(p_unit_deferral_id)) THEN
       process_workorders(
            p_unit_deferral_id      => p_unit_deferral_id,
            p_object_version_number => p_object_version_number,
            p_approval_result_code  => G_DEFERRAL_INITIATED,
            x_return_status         => x_return_status );

       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_approval_initiated',
			'unit_deferral_id : ' || p_unit_deferral_id
		);
           fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_approval_initiated',
			'object_version_number : ' || p_object_version_number
		);
           fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_approval_initiated',
			'Return status after process_workorders API call : ' || x_return_status
		);
       END IF;

       IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
          IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)	THEN
   		   fnd_log.string
		   (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.process_approval_initiated',
			    'process_workorders API API threw error'
		   );
          END IF;
          RETURN;
       END IF;
    END IF; -- ump deferral.

    process_unit_maint_plan(
         p_unit_deferral_id      => p_unit_deferral_id,
         p_object_version_number => p_object_version_number,
         p_approval_result_code  => G_DEFERRAL_INITIATED,
         p_new_status            => NULL,
         x_return_status         => x_return_status);

    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
       IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)	THEN
		   fnd_log.string
		   (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.process_approval_initiated',
			    'process_unit_maint_plan API threw error'
		   );
       END IF;
       RETURN;
    END IF;

    UPDATE ahl_unit_deferrals_b
    SET approval_status_code = p_new_status
    WHERE unit_deferral_id = p_unit_deferral_id
    AND object_version_number = p_object_version_number;--same transaction of caller API and update already happened

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.process_approval_initiated.end',
			'At the end of PLSQL procedure'
		);
    END IF;


END process_approval_initiated;

PROCEDURE process_approval_approved (

    p_unit_deferral_id      IN             NUMBER,
    p_object_version_number IN             NUMBER,
    p_new_status            IN              VARCHAR2,
    x_return_status         OUT NOCOPY     VARCHAR2)IS

    CURSOR csi_item_instance_id_csr(p_unit_deferral_id IN NUMBER)
                                    --,p_object_version_number IN NUMBER)
    IS
    SELECT csi_item_instance_id FROM AHL_UNIT_EFFECTIVITIES_B UE, ahl_unit_deferrals_b UD
    WHERE UE.unit_effectivity_id = UD.unit_effectivity_id
    --AND UD.object_version_number = p_object_version_number
    AND UD.unit_deferral_id = p_unit_deferral_id;

    l_csi_item_instance_id NUMBER;

    -- to check whether MR is not terminated already
    /*CURSOR valid_mr_csr(p_unit_deferral_id IN NUMBER,p_object_version_number IN NUMBER) IS
    SELECT 'x' from AHL_MR_HEADERS_APP_V mr, AHL_MR_HEADERS_APP_V def,
                    ahl_unit_effectivities_b UE,ahl_unit_deferrals_b UD
    WHERE UD.unit_deferral_id = p_unit_deferral_id
    AND UD.object_version_number = p_object_version_number
    AND UE.unit_effectivity_id = UD.unit_effectivity_id
    AND def.mr_header_id = NVL(UE.mr_header_id,def.mr_header_id)
    AND def.title = mr.title
    AND trunc(sysdate) between trunc(mr.effective_from)
    AND trunc(nvl(mr.effective_to, sysdate))
    AND mr.version_number >= def.version_number;

    l_exists VARCHAR2(1);*/


BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.process_approval_approved.begin',
			'At the start of PLSQL procedure'
		);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;


    /*OPEN valid_mr_csr(p_unit_deferral_id ,p_object_version_number);
    FETCH valid_mr_csr INTO l_exists;
    IF(valid_mr_csr%NOTFOUND)THEN
       FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_MR_TERM');
       FND_MSG_PUB.ADD;
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		   fnd_log.string
		   (
			  fnd_log.level_error,
			  'ahl.plsql.AHL_PRD_DF_PVT.process_unit_maint_plan',
			  'Associated MR has been terminated in FMP'
		    );
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       CLOSE valid_mr_csr;
       RETURN;
    END IF;
    CLOSE valid_mr_csr; */
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_approval_approved',
			'unit_deferral_id : ' || p_unit_deferral_id
		);
        fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_approval_approved',
			'object_version_number : ' || p_object_version_number
		);
    END IF;

    IF NOT(is_ump_deferral(p_unit_deferral_id)) THEN
       --update workorders
       process_workorders(
            p_unit_deferral_id      => p_unit_deferral_id,
            p_object_version_number => p_object_version_number,
            p_approval_result_code  => G_DEFERRAL_APPROVED,
            x_return_status         => x_return_status);

       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
           fnd_log.string
   		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_approval_approved',
			'Return status after process_workorders API call : ' || x_return_status
		);
       END IF;

       IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
          IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)	THEN
		   fnd_log.string
		   (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.process_approval_approved',
			    'process_workorders API threw error'
		   );
          END IF;
          RETURN;
       END IF;
    END IF; -- UMP deferral.

    -- copy unit effectivities and update ue status(update unit maintenance plan)
    process_unit_maint_plan(
         p_unit_deferral_id      => p_unit_deferral_id,
         p_object_version_number => p_object_version_number,
         p_approval_result_code  => G_DEFERRAL_APPROVED,
         p_new_status            => p_new_status,
         x_return_status         => x_return_status);

    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN

       IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)	THEN
		   fnd_log.string
		   (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.process_approval_approved',
			    'process_unit_maint_plan API threw error'
		   );
       END IF;
       RETURN;
    END IF;

    -- update unit_effectivity_status
    UPDATE ahl_unit_deferrals_b
    SET approval_status_code = 'DEFERRED',
    object_version_number    = p_object_version_number + 1
    WHERE unit_deferral_id   = p_unit_deferral_id
    AND object_version_number = p_object_version_number;


    IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_event,
			'ahl.plsql.AHL_PRD_DF_PVT.process_approval_approved',
			'Succesfully approved deferral for unit_deferral_id : ' || p_unit_deferral_id
		);
    END IF;

    -- fetch item instance id
    OPEN csi_item_instance_id_csr(p_unit_deferral_id --,p_object_version_number
                                 );
    FETCH csi_item_instance_id_csr INTO l_csi_item_instance_id;
    IF(csi_item_instance_id_csr%NOTFOUND)THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)	THEN
		   fnd_log.string
		   (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.process_approval_approved',
			    'Unit Effectivity record not found when fetching item instance id'
		   );
       END IF;
       CLOSE csi_item_instance_id_csr;
       RETURN;
    ELSE
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)	THEN
		   fnd_log.string
		   (
			    fnd_log.level_statement,
			    'ahl.plsql.AHL_PRD_DF_PVT.process_approval_approved',
			    'p_csi_item_instance_id : ' || l_csi_item_instance_id
		   );
        END IF;
        -- then call due date calc concurrent request
        calculate_due_date(
            x_return_status         => x_return_status ,
           p_csi_item_instance_id 	=> l_csi_item_instance_id
        );

        IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
            IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)	THEN
		        fnd_log.string
		        (
			            fnd_log.level_unexpected,
			            'ahl.plsql.AHL_PRD_DF_PVT.process_approval_approved',
			            'Could not calculate due date'
		        );
            END IF;
            RETURN;
       END IF;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.process_approval_approved.end',
			'At the end of PLSQL procedure'
		);
    END IF;

END process_approval_approved;

PROCEDURE calculate_due_date(
  x_return_status               OUT NOCOPY VARCHAR2,
  p_csi_item_instance_id 	    IN	NUMBER
) IS

  l_targetp         NUMBER;
  l_activep         NUMBER;
  l_targetp1        NUMBER;
  l_activep1        NUMBER;
  l_pmon_method     VARCHAR2(30);
  l_callstat        NUMBER;
  l_req_id          NUMBER;

  l_can_submit_request BOOLEAN := TRUE;
  l_concurrent_request_sucess BOOLEAN := FALSE;

  l_msg_count NUMBER;
  l_msg_data VARCHAR2(4000);

BEGIN
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.calculate_due_date.begin',
			'At the start of PLSQL procedure'
		);
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
    l_can_submit_request := FALSE;
  ELSIF NOT fnd_program.program_exists('AHLUEFF','AHL') THEN
    l_can_submit_request := FALSE;
  ELSIF NOT fnd_program.executable_exists('AHLUEFF','AHL') THEN
    l_can_submit_request := FALSE;
  END IF;

  -- submit request
  --IF(l_can_submit_request)THEN
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)	THEN
      fnd_log.string
	  (
		 fnd_log.level_statement,
		 'ahl.plsql.AHL_PRD_DF_PVT.process_approval_approved',
		 'Submitting concurrent request to calculate due date for p_csi_item_instance_id : ' || p_csi_item_instance_id
	  );
     END IF;
     --l_req_id := fnd_request.submit_request('AHL','AHLUEFF',NULL,NULL,FALSE,NULL,NULL,p_csi_item_instance_id );
     -- modification due to additional parameters added to AHLUEFF
     l_req_id := fnd_request.submit_request('AHL','AHLUEFF',NULL,NULL,FALSE,NULL,NULL,p_csi_item_instance_id,NULL,NULL,1);

     IF (l_req_id = 0 ) THEN
        l_concurrent_request_sucess := FALSE;
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)	THEN
           fnd_log.string
	       (
		     fnd_log.level_statement,
		     'ahl.plsql.AHL_PRD_DF_PVT.process_approval_approved',
		     'Tried to submit concurrent request but failed'
	       );
       END IF;
     ELSE
        l_concurrent_request_sucess := TRUE;
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)	THEN
           fnd_log.string
	       (
		     fnd_log.level_statement,
		     'ahl.plsql.AHL_PRD_DF_PVT.process_approval_approved',
		     'Concurrent request to calculate due date successful'
	       );
        END IF;
     END IF;
  --END IF;

  /* -- launching concurrent program always
  IF NOT (l_concurrent_request_sucess) THEN
     -- submit online request
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)	THEN
           fnd_log.string
	       (
		     fnd_log.level_statement,
		     'ahl.plsql.AHL_PRD_DF_PVT.process_approval_approved',
		     'Calculating due date online'
	       );
     END IF;

     AHL_UMP_PROCESSUNIT_PVT.Process_Unit (
                p_commit                 =>  FND_API.G_FALSE,
                p_init_msg_list          =>  FND_API.G_FALSE,
                x_msg_count              =>  l_msg_count,
                x_msg_data               =>  l_msg_data,
                x_return_status          =>  x_return_status,
                p_csi_item_instance_id   =>  p_csi_item_instance_id,
                p_concurrent_flag        => 'N');

        IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
            IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)	THEN
		        fnd_log.string
		        (
			            fnd_log.level_unexpected,
			            'ahl.plsql.AHL_PRD_DF_PVT.calculate_due_date',
			            'AHL_UMP_PROCESSUNIT_PVT.Process_Unit API threw error'
		        );
            END IF;
            RETURN;
       END IF;
  END IF; */

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.calculate_due_date.end',
			'At the end of PLSQL procedure'
		);
  END IF;

END calculate_due_date;


PROCEDURE process_approval_rejected (

    p_unit_deferral_id      IN             NUMBER,
    p_object_version_number IN             NUMBER,
    p_new_status            IN              VARCHAR2,
    x_return_status         OUT NOCOPY     VARCHAR2)IS
BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.process_approval_rejected.begin',
			'At the start of PLSQL procedure'
		);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- bypass for UMP Deferral
    IF NOT(Is_UMP_Deferral(p_unit_deferral_id)) THEN

       process_workorders(
         p_unit_deferral_id      => p_unit_deferral_id,
         p_object_version_number => p_object_version_number,
         p_approval_result_code  => G_DEFERRAL_REJECTED,
         x_return_status         => x_return_status);

       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_approval_rejected',
			'unit_deferral_id : ' || p_unit_deferral_id
		);
           fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_approval_rejected',
			'object_version_number : ' || p_object_version_number
		);
           fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_approval_rejected',
			'Return status after process_workorders API call : ' || x_return_status
		);
           fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_approval_rejected',
			'New approval status : ' || p_new_status
		);
       END IF;

       IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
          IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)	THEN
		   fnd_log.string
		   (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.process_approval_rejected',
			    'process_workorders API threw error'
		   );
          END IF;
          RETURN;
       END IF; -- x_return_status
    END IF; -- is_ump_deferral.

    -- update unit maintenance plan)
    process_unit_maint_plan(
         p_unit_deferral_id      => p_unit_deferral_id,
         p_object_version_number => p_object_version_number,
         p_approval_result_code  => G_DEFERRAL_REJECTED,
         p_new_status            => NULL,
         x_return_status         => x_return_status);

    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
       IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)	THEN
		   fnd_log.string
		   (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.process_approval_rejected',
			    'process_unit_maint_plan API threw error'
		   );
       END IF;
       RETURN;
    END IF;

    UPDATE ahl_unit_deferrals_b
    SET approval_status_code = p_new_status,
    object_version_number    = p_object_version_number + 1
    WHERE unit_deferral_id = p_unit_deferral_id
    AND object_version_number = p_object_version_number;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.process_approval_rejected.end',
			'At the end of PLSQL procedure'
		);
    END IF;

END process_approval_rejected;


PROCEDURE process_workorders(
         p_unit_deferral_id      IN             NUMBER,
         p_object_version_number IN             NUMBER,
         p_approval_result_code  IN             VARCHAR2,
         x_return_status         OUT NOCOPY     VARCHAR2) IS

    l_prd_workorder_rec AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_REC;
    l_temp_prd_workorder_rec AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_REC;


    l_prd_workoper_tbl  AHL_PRD_WORKORDER_PVT.PRD_WORKOPER_TBL;

    --rroy
    --ACL Changes
    -- Added object_type to query
    CURSOR unit_effectivity_id_csr(p_unit_deferral_id IN NUMBER,
                                   p_object_version_number IN NUMBER)IS
    SELECT UD.unit_effectivity_id, ue.object_type
    from ahl_unit_deferrals_b UD, AHL_UNIT_EFFECTIVITIES_B UE
    WHERE NVL(UE.status_code,'x') NOT IN('ACCOMPLISHED','DEFERRED','EXCEPTION','TERMINATED','CANCELLED','MR-TERMINATE')
    AND UE.unit_effectivity_id = UD.unit_effectivity_id
    AND UD.object_version_number = p_object_version_number
    AND UD.unit_deferral_id = p_unit_deferral_id;
    -- rroy
    -- ACL Changes

    l_unit_effectivity_id NUMBER;
		l_ue_title						VARCHAR2(155);
    -- rroy
    -- ACL Changes
    l_object_type         VARCHAR2(3);
    l_return_status       VARCHAR2(1);
    -- rroy
    -- ACL Changes

    CURSOR validate_approver_privilages(p_unit_effectivity_id IN NUMBER)IS

    /* replaced as this query does not pick up master workorders.
    SELECT WO.workorder_id
    FROM ahl_workorder_tasks_v WO
    WHERE  WO.job_status_code NOT IN ( G_JOB_DRAFT,G_JOB_DELETED)
    AND WO.unit_effectivity_id  = p_unit_effectivity_id;    */

    SELECT WO.workorder_id
    FROM ahl_workorders wo, ahl_visit_tasks_b vts,
      ahl_visits_b vst,
      (SELECT ORGANIZATION_ID FROM INV_ORGANIZATION_INFO_V
       WHERE NVL (operating_unit, mo_global.get_current_org_id()) = mo_global.get_current_org_id()) ORG
    WHERE  wo.visit_task_id = vts.visit_task_id
    AND vts.visit_id = vst.visit_id
    AND vst.organization_id = org.organization_id
    AND WO.status_code NOT IN ( G_JOB_DRAFT,G_JOB_DELETED)
    AND vts.unit_effectivity_id  = p_unit_effectivity_id
    AND vts.task_type_code IN ('SUMMARY','UNASSOCIATED');

    l_workorder_id NUMBER;

    -- rroy
    -- ACL Changes
    -- Added workorder_name to select clause
    CURSOR workorder_csr(p_unit_effectivity_id IN NUMBER)IS
    SELECT WO.workorder_id,
				WO.object_version_number,
				WO.status_code,
				WO.actual_start_date,
				WO.actual_end_date,
				WO.workorder_name
    FROM ahl_workorders WO , ahl_unit_effectivities_b UE, ahl_visit_tasks_b VST
    WHERE  WO.status_code NOT IN ( G_JOB_DRAFT,G_JOB_DELETED)
    AND WO.master_workorder_flag = 'N'
    AND WO.visit_task_id = VST.visit_task_id
    AND VST.unit_effectivity_id = UE.unit_effectivity_id
    AND UE.unit_effectivity_id  = p_unit_effectivity_id
    UNION
    SELECT WO.workorder_id,
				WO.object_version_number,
				WO.status_code,
				WO.actual_start_date,
				WO.actual_end_date,
				WO.workorder_name
    FROM ahl_workorders WO , ahl_unit_effectivities_b UE, ahl_visit_tasks_b VST
    WHERE  WO.status_code NOT IN ( G_JOB_DRAFT,G_JOB_DELETED)
    AND WO.master_workorder_flag = 'N'
    AND WO.visit_task_id = VST.visit_task_id
    AND VST.unit_effectivity_id = UE.unit_effectivity_id
    AND UE.unit_effectivity_id IN
    (

         SELECT     distinct related_ue_id
         FROM       AHL_UE_RELATIONSHIPS
         WHERE      relationship_code = 'PARENT'
         START WITH ue_id = p_unit_effectivity_id
         CONNECT BY ue_id = PRIOR related_ue_id
    );
    -- rroy
    -- ACL Changes

    CURSOR workorder_objver_csr(p_workorder_id IN NUMBER) IS
    SELECT object_version_number from ahl_workorders
    WHERE workorder_id = p_workorder_id;

	--Changes by nsikka for Bug 5324101
	--Cursor added to fetch UE Title to be passed as token

    CURSOR ue_title_csr(p_unit_effectivity_id IN NUMBER) IS
    SELECT title from ahl_unit_effectivities_v
    WHERE UNIT_EFFECTIVITY_ID = p_unit_effectivity_id;

    l_update_flag BOOLEAN := false;
    --l_complete_flag BOOLEAN := false;  /* commented out as  workorder completion is no longer needed. */

    l_msg_count NUMBER;
    l_msg_data VARCHAR2(4000);

    l_temp VARCHAR2(30);

-- fix for bug number 6990380
    CURSOR chk_inst_in_job (p_workorder_id IN NUMBER) IS
       SELECT 'x'
       FROM  CSI_ITEM_INSTANCES CII, AHL_WORKORDERS AWO
       WHERE CII.WIP_JOB_ID = AWO.WIP_ENTITY_ID
         AND AWO.workorder_id = p_workorder_id
         AND ACTIVE_START_DATE <= SYSDATE
         AND ((ACTIVE_END_DATE IS NULL) OR (ACTIVE_END_DATE >= SYSDATE))
         AND LOCATION_TYPE_CODE = 'WIP'
         AND NOT EXISTS (SELECT 'X' FROM CSI_II_RELATIONSHIPS CIR
                         WHERE CIR.SUBJECT_ID = CII.INSTANCE_ID
                           AND CIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
                           AND SYSDATE BETWEEN NVL(ACTIVE_START_DATE,SYSDATE) AND NVL(ACTIVE_END_DATE,SYSDATE));

    l_status_meaning VARCHAR2(80);

BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.process_workorders.begin',
			'At the start of PLSQL procedure'
		);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_workorders',
			'unit_deferral_id : ' || p_unit_deferral_id
		);
        fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_workorders',
			'object_version_number : ' || p_object_version_number
		);
        fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_workorders',
			'Approval Result Code : ' || p_approval_result_code
		);
    END IF;
    -- validating ue and getting it
    OPEN unit_effectivity_id_csr(p_unit_deferral_id, p_object_version_number);
    FETCH unit_effectivity_id_csr INTO l_unit_effectivity_id, l_object_type;
    IF(unit_effectivity_id_csr%NOTFOUND)THEN
       FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INVOP_HREC_MISS');
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)	THEN
		    fnd_log.string
		    (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.process_workorders',
			    'Unit Effectivity Record not found for unit deferral id : ' || p_unit_deferral_id
		    );
       END IF;
    END IF;
    CLOSE unit_effectivity_id_csr;

    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
       RETURN;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_workorders',
			'unit_effectivity_id : ' || l_unit_effectivity_id
		);
    END IF;

    IF (p_approval_result_code IN ( G_DEFERRAL_REJECTED,G_DEFERRAL_APPROVED ))THEN
       OPEN validate_approver_privilages(l_unit_effectivity_id);
       FETCH validate_approver_privilages INTO l_workorder_id;
       IF(validate_approver_privilages%NOTFOUND)THEN
         FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_APPR_SETUP');
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)	THEN
		    fnd_log.string
		    (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.process_workorders',
			    'Approver client information not same as the requester. workorders not found for approver'
		    );
         END IF;
       END IF;
       CLOSE validate_approver_privilages;
    END IF;

    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
       RETURN;
    END IF;

    --OPEN workorder_csr(l_unit_effectivity_id);
    FOR workorder_rec IN workorder_csr(l_unit_effectivity_id) LOOP
        l_update_flag := FALSE;
        --l_complete_flag := FALSE;
        l_prd_workorder_rec := l_temp_prd_workorder_rec;--initialize it
        l_prd_workorder_rec.workorder_id := workorder_rec.workorder_id;
        l_prd_workorder_rec.object_version_number := workorder_rec.object_version_number;
        l_prd_workorder_rec.status_code := workorder_rec.status_code;
        l_prd_workorder_rec.actual_start_date := workorder_rec.actual_start_date;
        l_prd_workorder_rec.actual_end_date := workorder_rec.actual_end_date;

    -- rroy
    -- ACL Changes
    l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => l_prd_workorder_rec.workorder_id,
                                                       p_ue_id => NULL, 																																																										p_visit_id => NULL,
                                                       p_item_instance_id => NULL);


	--nsikka
	--Changes made for Bug 5324101 .
	--tokens passed changed to MR_TITLE

    IF l_return_status = FND_API.G_TRUE THEN
       IF l_object_type IS NOT NULL AND l_object_type = 'SR' THEN
          FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_DFSR_UNTLCKD');
          FND_MESSAGE.Set_Token('WO_NAME', workorder_rec.workorder_name);
          FND_MSG_PUB.ADD;
       ELSE
          OPEN ue_title_csr(l_unit_effectivity_id);
          FETCH ue_title_csr into l_ue_title;
          CLOSE ue_title_csr;
          FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_DFMR_UNTLCKD');
          FND_MESSAGE.Set_Token('MR_TITLE', l_ue_title);
          FND_MSG_PUB.ADD;
       END IF;
       EXIT;
     END IF;
     -- rroy
     -- ACL Changes

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
		    (
			     fnd_log.level_statement,
			     'ahl.plsql.AHL_PRD_DF_PVT.process_workorders',
			     'workorder_id : ' || l_prd_workorder_rec.workorder_id
		    );
            fnd_log.string
		    (
			      fnd_log.level_statement,
			      'ahl.plsql.AHL_PRD_DF_PVT.process_workorders',
			      'object_version_number : ' || l_prd_workorder_rec.object_version_number
		    );
		    fnd_log.string
		    (
			      fnd_log.level_statement,
			      'ahl.plsql.AHL_PRD_DF_PVT.process_workorders',
			      'Current Workorder status : ' || l_prd_workorder_rec.status_code
		    );
        END IF;

        IF(p_approval_result_code = G_DEFERRAL_INITIATED)THEN
           --l_prd_workorder_rec.status_code := G_JOB_UNRELEASED;
           --l_update_flag := TRUE;
           IF(isValidStatusUpdate(G_DEFERRAL_INITIATED, l_prd_workorder_rec.status_code))THEN
              l_update_flag := TRUE;
              l_prd_workorder_rec.status_code := G_JOB_PEND_DFR_APPR;
           END IF;
        ELSIF (p_approval_result_code = G_DEFERRAL_REJECTED)THEN
            IF(isValidStatusUpdate(G_DEFERRAL_REJECTED, l_prd_workorder_rec.status_code))THEN
              l_update_flag := TRUE;
              -- find out the old status and set it here
              l_prd_workorder_rec.status_code := getLastStatus(l_prd_workorder_rec.workorder_id);
            END IF;
        /* sracha: commented out as  workorder completion is no longer needed.*/
        /*ELSIF (p_approval_result_code = G_DEFERRAL_APPROVED)THEN
            -- find out the old status and populate here
            IF(l_prd_workorder_rec.status_code = G_JOB_PEND_DFR_APPR)THEN
               l_prd_workorder_rec.status_code := getLastStatus(l_prd_workorder_rec.workorder_id);
            END IF;
            --IF(isValidStatusUpdate(G_DEFERRAL_APPROVED, l_prd_workorder_rec.status_code))THEN
            --  l_update_flag := TRUE;
            --  l_prd_workorder_rec.status_code := G_JOB_CANCELLED;
            --ELSIF (l_prd_workorder_rec.status_code IN(G_JOB_RELEASED,G_JOB_PARTS_HOLD,G_JOB_ON_HOLD,G_JOB_PEND_QA_APPR))THEN
            --  l_complete_flag := TRUE;
            --END IF;
            IF (l_prd_workorder_rec.status_code IN(G_JOB_UNRELEASED,G_JOB_RELEASED,G_JOB_PARTS_HOLD,G_JOB_ON_HOLD,G_JOB_PEND_QA_APPR))THEN
              l_complete_flag := TRUE;
            END IF; */
        /* sracha - end */
        END IF;

        -- call production API to update job status or complete job
        IF(l_update_flag)THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string
		        (
			      fnd_log.level_statement,
			      'ahl.plsql.AHL_PRD_DF_PVT.process_workorders',
			      'Workorder Update Flag :TRUE '
		        );
                fnd_log.string
		        (
			      fnd_log.level_statement,
			      'ahl.plsql.AHL_PRD_DF_PVT.process_workorders',
			      'new Workorder status/Update : ' || l_prd_workorder_rec.status_code
		        );
            END IF;

            IF (l_prd_workorder_rec.status_code IN (G_JOB_CANCELLED,G_JOB_PEND_DFR_APPR)) THEN
	                  OPEN chk_inst_in_job(l_prd_workorder_rec.workorder_id);
	                  FETCH chk_inst_in_job INTO l_temp;
	                  IF (chk_inst_in_job%FOUND) THEN
	                    --Get status meaning
	                    SELECT meaning INTO l_status_meaning
	    	            FROM fnd_lookup_values_vl
	                    WHERE lookup_type = 'AHL_JOB_STATUS'
	                    AND LOOKUP_CODE = l_prd_workorder_rec.status_code;
	                    FND_MESSAGE.set_name('AHL','AHL_PRD_MAT_NOT_RETURN');
	                    FND_MESSAGE.set_token('WO_STATUS', l_status_meaning);
	                    FND_MESSAGE.set_token('WO_NAME', workorder_rec.workorder_name);
	                    FND_MSG_PUB.add;
	                    x_return_status := FND_API.G_RET_STS_ERROR;
	                  END IF;
	                  CLOSE chk_inst_in_job;
	                END IF;
            IF(x_return_status = FND_API.G_RET_STS_SUCCESS)THEN
              -- call update job API
              AHL_PRD_WORKORDER_PVT.update_job
              (
               p_api_version         => 1.0,
               p_init_msg_list       => FND_API.G_FALSE,
               p_commit              => FND_API.G_FALSE,
               p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
               p_default             => FND_API.G_TRUE,
               p_module_type         => 'API',
               x_return_status       => x_return_status,
               x_msg_count           => l_msg_count,
               x_msg_data            => l_msg_data,
               p_x_prd_workorder_rec => l_prd_workorder_rec,
               p_x_prd_workoper_tbl  => l_prd_workoper_tbl
             );
             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string
		        (
			      fnd_log.level_statement,
			      'ahl.plsql.AHL_PRD_DF_PVT.process_workorders',
			      'Status after AHL_PRD_WORKORDER_PVT.update_job API call : ' || x_return_status
		        );
             END IF;
             IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_UPD_JB_FAIL');
                FND_MSG_PUB.ADD;
                IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string
		            (
			            fnd_log.level_unexpected,
			            'ahl.plsql.AHL_PRD_DF_PVT.process_workorders',
			            'AHL_PRD_WORKORDER_PVT.update_job API returned error '
		            );
                END IF;
                EXIT;
             END IF;
        /* sracha: commented out as  workorder completion is no longer needed. */
        /* ELSIF(l_complete_flag)THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string
		        (
			      fnd_log.level_statement,
			      'ahl.plsql.AHL_PRD_DF_PVT.process_workorders',
			      'Workorder Complete Flag :TRUE '
		        );
                fnd_log.string
		        (
			      fnd_log.level_statement,
			      'ahl.plsql.AHL_PRD_DF_PVT.process_workorders',
			      'new Workorder status/Complete : ' || l_prd_workorder_rec.status_code
		        );
            END IF;
            l_prd_workorder_rec.status_code := G_JOB_RELEASED;

            -- modified 4/24/06 to not pass actual start dates --FP bug# 5114848.
            -- actual dates are not needed if WO is being cancelled.
            --l_prd_workorder_rec.actual_start_date := NVL(l_prd_workorder_rec.actual_start_date,SYSDATE);
            --l_prd_workorder_rec.actual_end_date := NVL(l_prd_workorder_rec.actual_end_date,SYSDATE);

            -- call update job API
            AHL_PRD_WORKORDER_PVT.update_job
             (
               p_api_version         => 1.0,
               p_init_msg_list       => FND_API.G_FALSE,
               p_commit              => FND_API.G_FALSE,
               p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
               p_default             => FND_API.G_TRUE,
               p_module_type         => 'API',
               x_return_status       => x_return_status,
               x_msg_count           => l_msg_count,
               x_msg_data            => l_msg_data,
               p_x_prd_workorder_rec => l_prd_workorder_rec,
               p_x_prd_workoper_tbl  => l_prd_workoper_tbl
             );
             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string
		        (
			      fnd_log.level_statement,
			      'ahl.plsql.AHL_PRD_DF_PVT.process_workorders',
			      'Status after AHL_PRD_WORKORDER_PVT.update_job API call : ' || x_return_status
		        );
             END IF;
             IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_UPD_JB_FAIL');
                FND_MSG_PUB.ADD;
                IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string
		            (
			            fnd_log.level_unexpected,
			            'ahl.plsql.AHL_PRD_DF_PVT.process_workorders',
			            'AHL_PRD_WORKORDER_PVT.update_job API returned error '
		            );
                END IF;
                EXIT;
            END IF; */
            -- sure to find record here
            -- Following code has been commented because we have got an API which will cancel all jobs for us
            -- after approval of deferral.
            -- also in 11.5.10+ we will cancel all workorders inspite of their statuses.
            /*OPEN workorder_objver_csr(l_prd_workorder_rec.workorder_id);
            FETCH workorder_objver_csr INTO l_prd_workorder_rec.object_version_number;
            CLOSE workorder_objver_csr;

            AHL_COMPLETIONS_PVT.defer_workorder
            (
               p_api_version         => 1.0,
               p_init_msg_list       => FND_API.G_FALSE,
               p_commit              => FND_API.G_FALSE,
               p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
               p_default             => FND_API.G_TRUE,
               p_module_type         => 'API',
               x_return_status       => x_return_status,
               x_msg_count           => l_msg_count,
               x_msg_data            => l_msg_data,
               p_workorder_id        => l_prd_workorder_rec.workorder_id,
               p_object_version_no   => l_prd_workorder_rec.object_version_number
             );
             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string
		        (
			      fnd_log.level_statement,
			      'ahl.plsql.AHL_PRD_DF_PVT.process_workorders',
			      'Status after AHL_COMPLETIONS_PVT.defer_workorder API call : ' || x_return_status
		        );
             END IF;
             IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_CMP_JB_FAIL');
                FND_MSG_PUB.ADD;
                IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string
		            (
			            fnd_log.level_unexpected,
			            'ahl.plsql.AHL_PRD_DF_PVT.process_workorders',
			            'AHL_COMPLETIONS_PVT.defer_workorder API returned error '
		            );
                END IF;
                EXIT;
             END IF;*/
          END IF;
        END IF;
    END LOOP;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string
		        (
			      fnd_log.level_statement,
			      'before ahl.plsql.AHL_PRD_WORKORDER_PVT.cancel_visit_jobs',
			      'Workorder Cancel Visits Jobs '
		        );
            END IF;

    -- throw errors if any
    IF(FND_MSG_PUB.count_msg > 0)THEN
        RETURN;
    END IF;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string
		        (
			      fnd_log.level_statement,
			      'ahl.plsql.AHL_PRD_WORKORDER_PVT.cancel_visit_jobs',
			      'Workorder Cancel Visits Jobs '
		        );
            END IF;

    -- if approval was approved, cancel all workorders
    IF (p_approval_result_code = G_DEFERRAL_APPROVED)THEN
        AHL_PRD_WORKORDER_PVT.cancel_visit_jobs
        (
            p_api_version         => 1.0,
            p_init_msg_list       => FND_API.G_TRUE,
            p_commit              => FND_API.G_FALSE,
            p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
            p_default             => FND_API.G_FALSE,
            p_module_type         => 'API',
            x_return_status       => x_return_status,
            x_msg_count           => l_msg_count,
            x_msg_data            => l_msg_data,
            p_visit_id            => NULL,
            p_unit_effectivity_id => l_unit_effectivity_id,
            p_workorder_id        => NULL
        );
        IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
           FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_CMP_JB_FAIL');
           FND_MSG_PUB.ADD;
           IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string
		       (
			       fnd_log.level_unexpected,
			       'ahl.plsql.AHL_PRD_DF_PVT.process_workorders',
			       'AHL_PRD_WORKORDERS_PVT.cancel_visit_jobs API returned error '
		       );
           END IF;
        END IF;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.process_workorders.end',
			'At the end of PLSQL procedure'
		);
    END IF;
END process_workorders;

FUNCTION isValidStatusUpdate(
         operation_code VARCHAR2,
         status_code    VARCHAR2)RETURN BOOLEAN IS

  l_yes_flag boolean := FALSE;

BEGIN
     IF(operation_code = G_DEFERRAL_INITIATED)THEN
       IF(status_code IN (G_JOB_UNRELEASED,G_JOB_RELEASED,G_JOB_PARTS_HOLD,G_JOB_ON_HOLD,G_JOB_PEND_QA_APPR))THEN
          l_yes_flag := TRUE;
       END IF;
     ELSIF(operation_code = G_DEFERRAL_REJECTED)THEN
       IF(status_code = G_JOB_PEND_DFR_APPR)THEN
          l_yes_flag := TRUE;
       END IF;
     /*ELSIF(operation_code = G_DEFERRAL_APPROVED)THEN
       IF(status_code IN (G_JOB_UNRELEASED))THEN
          l_yes_flag := TRUE;
       END IF;*/
     END IF;
     RETURN l_yes_flag;
END isValidStatusUpdate;

FUNCTION getLastStatus(p_workorder_id IN NUMBER) RETURN VARCHAR2 IS

    CURSOR last_status_code_csr(p_workorder_id IN NUMBER) IS
    SELECT status_code,last_update_date FROM ahl_workorder_txns
    WHERE workorder_id = p_workorder_id ORDER BY last_update_date DESC;

    l_junk_date DATE;
    l_last_status_code VARCHAR2(30);
BEGIN
    OPEN last_status_code_csr(p_workorder_id);
    LOOP
       FETCH last_status_code_csr INTO l_last_status_code,l_junk_date;
       IF(last_status_code_csr%NOTFOUND)THEN
          l_last_status_code := G_JOB_UNRELEASED;
          EXIT;
       ELSIF (l_last_status_code <> G_JOB_PEND_DFR_APPR)THEN
          EXIT;
       END IF;
    END LOOP;
    CLOSE last_status_code_csr;
    RETURN l_last_status_code;
END getLastStatus;


PROCEDURE process_unit_maint_plan(
         p_unit_deferral_id      IN             NUMBER,
         p_object_version_number IN             NUMBER,
         p_approval_result_code  IN             VARCHAR2,
         p_new_status            IN             VARCHAR2,
         x_return_status         OUT NOCOPY     VARCHAR2)IS

    -- to fetch unit effectivity id
    CURSOR unit_effectivity_id_csr(p_unit_deferral_id  IN NUMBER,p_object_version_number IN NUMBER) IS
    SELECT UD.unit_effectivity_id from ahl_unit_deferrals_b UD
    WHERE UD.object_version_number = p_object_version_number
    AND UD.unit_deferral_id = p_unit_deferral_id;

    l_unit_effectivity_id NUMBER;

    CURSOR unit_effectivity_csr (p_unit_effectivity_id IN NUMBER) IS
    SELECT
      UNIT_EFFECTIVITY_ID, OBJECT_VERSION_NUMBER, CSI_ITEM_INSTANCE_ID, MR_INTERVAL_ID,
      MR_EFFECTIVITY_ID, MR_HEADER_ID, STATUS_CODE, SET_DUE_DATE, ACCOMPLISHED_DATE,
      DUE_DATE, DUE_COUNTER_VALUE, FORECAST_SEQUENCE, REPETITIVE_MR_FLAG,
      TOLERANCE_FLAG, DATE_RUN, PRECEDING_UE_ID, MESSAGE_CODE, REMARKS,
      SERVICE_LINE_ID, PROGRAM_MR_HEADER_ID, CANCEL_REASON_CODE, EARLIEST_DUE_DATE,
      LATEST_DUE_DATE, DEFER_FROM_UE_ID, CS_INCIDENT_ID, QA_COLLECTION_ID,
      ORIG_DEFERRAL_UE_ID, COUNTER_ID,OBJECT_TYPE,MANUALLY_PLANNED_FLAG,
      LOG_SERIES_CODE,LOG_SERIES_NUMBER,FLIGHT_NUMBER, MEL_CDL_TYPE_CODE,
      POSITION_PATH_ID, ATA_CODE, UNIT_CONFIG_HEADER_ID,
      ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3,
      ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,ATTRIBUTE9,
      ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,ATTRIBUTE15,
      ORIGINATING_WO_ID
    FROM  AHL_UNIT_EFFECTIVITIES_VL UE
    WHERE unit_effectivity_id = p_unit_effectivity_id
    UNION
    SELECT
      UNIT_EFFECTIVITY_ID, OBJECT_VERSION_NUMBER, CSI_ITEM_INSTANCE_ID, MR_INTERVAL_ID,
      MR_EFFECTIVITY_ID, MR_HEADER_ID, STATUS_CODE, SET_DUE_DATE, ACCOMPLISHED_DATE,
      DUE_DATE, DUE_COUNTER_VALUE, FORECAST_SEQUENCE, REPETITIVE_MR_FLAG,
      TOLERANCE_FLAG, DATE_RUN, PRECEDING_UE_ID, MESSAGE_CODE, REMARKS,
      SERVICE_LINE_ID, PROGRAM_MR_HEADER_ID, CANCEL_REASON_CODE, EARLIEST_DUE_DATE,
      LATEST_DUE_DATE, DEFER_FROM_UE_ID, CS_INCIDENT_ID, QA_COLLECTION_ID,
      ORIG_DEFERRAL_UE_ID, COUNTER_ID,OBJECT_TYPE,MANUALLY_PLANNED_FLAG,
      LOG_SERIES_CODE,LOG_SERIES_NUMBER,FLIGHT_NUMBER, MEL_CDL_TYPE_CODE,
      POSITION_PATH_ID, ATA_CODE, UNIT_CONFIG_HEADER_ID,
      ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3,
      ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,ATTRIBUTE9,
      ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,ATTRIBUTE15,
      ORIGINATING_WO_ID
    FROM  AHL_UNIT_EFFECTIVITIES_VL UE
    WHERE unit_effectivity_id IN
       (

         SELECT     distinct related_ue_id
         FROM       AHL_UE_RELATIONSHIPS
         WHERE      relationship_code = 'PARENT'
         START WITH ue_id = p_unit_effectivity_id
         CONNECT BY ue_id = PRIOR related_ue_id
       );
    --FOR UPDATE OF OBJECT_VERSION_NUMBER;

    l_rowid VARCHAR2(80);
    l_new_unit_effectivity_id NUMBER;

    CURSOR ue_relns_csr(p_unit_effectivity_id IN NUMBER)IS
    SELECT distinct ue_id, related_ue_id, originator_ue_id
    FROM   AHL_UE_RELATIONSHIPS
    WHERE  relationship_code = 'PARENT'
    START WITH ue_id = p_unit_effectivity_id
    CONNECT BY ue_id = PRIOR related_ue_id;

    TYPE ue_relns_rec_type IS RECORD(
    ue_id NUMBER,
    related_ue_id NUMBER,
    originator_ue_id NUMBER
    );

    TYPE ue_relns_tbl_type IS TABLE OF ue_relns_rec_type INDEX BY BINARY_INTEGER;

    l_ue_relns_tbl ue_relns_tbl_type;

    i NUMBER := 0;
    l_ue_relationship_id NUMBER;
    l_new_parent_ue_id NUMBER;
    l_orig_deferral_ue_id NUMBER;
    l_update_status VARCHAR2(30);

    -- TAMAL -- Begin changes for ER #3356804
    -- TAMAL -- Adding cursor to retrieve UE and SR details
    CURSOR get_ue_sr_details
    (
        p_ue_id in number
    )
    IS
	SELECT	ue.object_type,
        	sr.incident_id,
        	sr.incident_number,
        	sr.object_version_number
        FROM
        	ahl_unit_effectivities_b ue,
        	cs_incidents_all_b sr
        WHERE
        	ue.cs_incident_id = sr.incident_id (+) and
        	ue.unit_effectivity_id = p_ue_id;

    l_ue_obj_type		VARCHAR2(3);
    l_cs_incident_id		NUMBER;
    l_cs_incident_number	VARCHAR2(64);
    l_cs_incident_ovn		NUMBER;
    l_interaction_id		NUMBER;
    l_return_status		VARCHAR2(1);
    l_msg_count			NUMBER;
    l_msg_data			VARCHAR2(4000);
    -- TAMAL -- End changes for ER #3356804

    -- Support for SR cancellation.
    l_status_id                NUMBER;

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.process_unit_maint_plan.begin',
			'At the start of PLSQL procedure'
		);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN unit_effectivity_id_csr(p_unit_deferral_id ,p_object_version_number);
    FETCH unit_effectivity_id_csr INTO l_unit_effectivity_id;
    IF(unit_effectivity_id_csr%NOTFOUND)THEN
       FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_INV_DF');
       FND_MESSAGE.SET_TOKEN('DEFERRAL_ID',p_unit_deferral_id);
       FND_MSG_PUB.ADD;
       IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		   fnd_log.string
		   (
			        fnd_log.level_unexpected,
			        'ahl.plsql.AHL_PRD_DF_PVT.process_unit_maint_plan',
			        'Deferral record details not found for unit deferral id : ' || p_unit_deferral_id
		   );
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;
    CLOSE unit_effectivity_id_csr;

    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
       RETURN;
    END IF;

    IF(p_approval_result_code = G_DEFERRAL_APPROVED)THEN
      -- clean up prior deferrals
      process_prior_ump_deferrals(l_unit_effectivity_id);
      -- get relationship tree snapshot
      IF(p_new_status = 'DEFERRED')THEN
       FOR ue_relns_rec IN ue_relns_csr(l_unit_effectivity_id) LOOP
           l_ue_relns_tbl(i).ue_id := ue_relns_rec.ue_id;
           l_ue_relns_tbl(i).related_ue_id := ue_relns_rec.related_ue_id;
           l_ue_relns_tbl(i).originator_ue_id := ue_relns_rec.originator_ue_id;
           i := i + 1;
       END LOOP;
      END IF;
      -- Loop through old records.update its status and insert new ones, update ue relationships table
      FOR ue_rec IN unit_effectivity_csr(l_unit_effectivity_id) LOOP

       IF(p_new_status = 'DEFERRED')THEN
        -- copy records here
        l_new_unit_effectivity_id := NULL;
        l_rowid := NULL;

        AHL_UNIT_EFFECTIVITIES_PKG.Insert_Row (
            X_ROWID                 => l_rowid,
            X_UNIT_EFFECTIVITY_ID   => l_new_unit_effectivity_id,
            X_CSI_ITEM_INSTANCE_ID  => ue_rec.csi_item_instance_id,
            X_MR_HEADER_ID          => ue_rec.mr_header_id,
            X_REPETITIVE_MR_FLAG    => ue_rec.repetitive_mr_flag,
            X_REMARKS               => ue_rec.remarks,
            X_SERVICE_LINE_ID       => ue_rec.service_line_id,
            X_PROGRAM_MR_HEADER_ID  => ue_rec.program_mr_header_id,
            X_CS_INCIDENT_ID        => ue_rec.cs_incident_id,
            X_DEFER_FROM_UE_ID      => l_unit_effectivity_id,
            X_ORIG_DEFERRAL_UE_ID   => NULL,
            X_QA_COLLECTION_ID      => NULL, --ue_rec.qa_collection_id,
            X_MR_INTERVAL_ID        => null,
            X_MR_EFFECTIVITY_ID     => null,
            X_STATUS_CODE           => null,
            X_DUE_DATE              => null,
            X_DUE_COUNTER_VALUE     => null,
            X_FORECAST_SEQUENCE     => null,
            X_TOLERANCE_FLAG        => null,
            X_MESSAGE_CODE          => null,
            X_PRECEDING_UE_ID       => null,
            X_DATE_RUN              => null,
            X_SET_DUE_DATE          => null,
            X_ACCOMPLISHED_DATE     => null,
            X_CANCEL_REASON_CODE    => null,
            X_EARLIEST_DUE_DATE     => null,
            X_LATEST_DUE_DATE       => null,
            X_ATTRIBUTE_CATEGORY    => null,
            X_ATTRIBUTE1            => null,
            X_ATTRIBUTE2            => null,
            X_ATTRIBUTE3            => null,
            X_ATTRIBUTE4            => null,
            X_ATTRIBUTE5            => null,
            X_ATTRIBUTE6            => null,
            X_ATTRIBUTE7            => null,
            X_ATTRIBUTE8            => null,
            X_ATTRIBUTE9            => null,
            X_ATTRIBUTE10           => null,
            X_ATTRIBUTE11           => null,
            X_ATTRIBUTE12           => null,
            X_ATTRIBUTE13           => null,
            X_ATTRIBUTE14           => null,
            X_ATTRIBUTE15           => null,
            X_OBJECT_VERSION_NUMBER => 1,
            X_APPLICATION_USG_CODE  => RTRIM(LTRIM(FND_PROFILE.VALUE('AHL_APPLN_USAGE'))),
            X_OBJECT_TYPE           => ue_rec.object_type,
            X_MANUALLY_PLANNED_FLAG => ue_rec.manually_planned_flag,
            X_COUNTER_ID            => ue_rec.counter_id,
            X_LOG_SERIES_CODE       => ue_rec.log_series_code,
            X_LOG_SERIES_NUMBER     => ue_rec.log_series_number,
            X_FLIGHT_NUMBER         => ue_rec.flight_number,
            X_MEL_CDL_TYPE_CODE     => ue_rec.mel_cdl_type_code,
            X_POSITION_PATH_ID      => ue_rec.position_path_id,
            X_ATA_CODE              => ue_rec.ATA_CODE,
            X_UNIT_CONFIG_HEADER_ID => ue_rec.unit_config_header_id,
            X_CREATION_DATE         => sysdate,
            X_CREATED_BY            => fnd_global.user_id,
            X_LAST_UPDATE_DATE      => sysdate,
            X_LAST_UPDATED_BY       => fnd_global.user_id,
            X_LAST_UPDATE_LOGIN     => fnd_global.login_id );

            -- copy originating WO id seperately as table handler does not support it.
            UPDATE ahl_unit_effectivities_b
            SET originating_wo_id = ue_rec.originating_wo_id
            WHERE ROWID = l_rowid;

            IF(ue_rec.unit_effectivity_id = l_unit_effectivity_id)THEN
               l_new_parent_ue_id := l_new_unit_effectivity_id;
            END IF;

            -- update l_ue_relns_tbl with the new unit effectivity id
            IF(l_ue_relns_tbl.count > 0)THEN
               FOR j IN l_ue_relns_tbl.FIRST..l_ue_relns_tbl.LAST  LOOP
                    IF(l_ue_relns_tbl(j).ue_id = ue_rec.unit_effectivity_id)THEN
                       l_ue_relns_tbl(j).ue_id := l_new_unit_effectivity_id;
                    END IF;
                    IF(l_ue_relns_tbl(j).related_ue_id = ue_rec.unit_effectivity_id)THEN
                       l_ue_relns_tbl(j).related_ue_id := l_new_unit_effectivity_id;
                    END IF;
               END LOOP;
            END IF;
          END IF;--

          IF(ue_rec.status_code IS NULL OR ue_rec.status_code IN ('INIT-DUE','DEFERRED','TERMINATED','CANCELLED'))THEN
             l_update_status := p_new_status;
          ELSE
             l_update_status := ue_rec.status_code;
          END IF;
          -- update status here
          AHL_UNIT_EFFECTIVITIES_PKG.update_row(
            x_unit_effectivity_id => ue_rec.UNIT_EFFECTIVITY_ID,
            x_csi_item_instance_id => ue_rec.CSI_ITEM_INSTANCE_ID,
            x_mr_interval_id => ue_rec.MR_INTERVAL_ID,
            x_mr_effectivity_id => ue_rec.MR_EFFECTIVITY_ID,
            x_mr_header_id => ue_rec.MR_HEADER_ID,
            x_status_code => l_update_status,
            x_due_date => ue_rec.DUE_DATE,
            x_due_counter_value => ue_rec.DUE_COUNTER_VALUE,
            x_forecast_sequence => ue_rec.FORECAST_SEQUENCE,
            x_repetitive_mr_flag => ue_rec.REPETITIVE_MR_FLAG,
            x_tolerance_flag => ue_rec.TOLERANCE_FLAG,
            x_remarks => ue_rec.REMARKS,
            x_message_code => ue_rec.MESSAGE_CODE,
            x_preceding_ue_id => ue_rec.PRECEDING_UE_ID,
            x_date_run => ue_rec.DATE_RUN,
            x_set_due_date => ue_rec.set_due_date,
            x_accomplished_date => ue_rec.accomplished_date,
            x_service_line_id   => ue_rec.service_line_id,
            x_program_mr_header_id => ue_rec.program_mr_header_id,
            x_cancel_reason_code   => ue_rec.cancel_reason_code,
            x_earliest_due_date    => ue_rec.earliest_due_date,
            x_latest_due_date      => ue_rec.latest_due_date,
            x_defer_from_ue_id     => ue_rec.defer_from_ue_id,
            x_qa_collection_id     => ue_rec.qa_collection_id,
            x_cs_incident_id       => ue_rec.cs_incident_id,
            x_orig_deferral_ue_id  => ue_rec.orig_deferral_ue_id,
            X_APPLICATION_USG_CODE  => RTRIM(LTRIM(FND_PROFILE.VALUE('AHL_APPLN_USAGE'))),
            X_COUNTER_ID            => ue_rec.counter_id,
            X_OBJECT_TYPE           => ue_rec.object_type,
            X_MANUALLY_PLANNED_FLAG => ue_rec.manually_planned_flag,
            X_LOG_SERIES_CODE       => ue_rec.log_series_code,
            X_LOG_SERIES_NUMBER     => ue_rec.log_series_number,
            X_FLIGHT_NUMBER         => ue_rec.flight_number,
            X_MEL_CDL_TYPE_CODE     => ue_rec.mel_cdl_type_code,
            X_POSITION_PATH_ID      => ue_rec.position_path_id,
            X_ATA_CODE              => ue_rec.ATA_CODE,
            X_UNIT_CONFIG_HEADER_ID  => ue_rec.unit_config_header_id,
            x_attribute_category => ue_rec.ATTRIBUTE_CATEGORY,
            x_attribute1 => ue_rec.ATTRIBUTE1,
            x_attribute2 => ue_rec.ATTRIBUTE2,
            x_attribute3 => ue_rec.ATTRIBUTE3,
            x_attribute4 => ue_rec.ATTRIBUTE4,
            x_attribute5 => ue_rec.ATTRIBUTE5,
            x_attribute6 => ue_rec.ATTRIBUTE6,
            x_attribute7 => ue_rec.ATTRIBUTE7,
            x_attribute8 => ue_rec.ATTRIBUTE8,
            x_attribute9 => ue_rec.ATTRIBUTE9,
            x_attribute10 => ue_rec.ATTRIBUTE10,
            x_attribute11 => ue_rec.ATTRIBUTE11,
            x_attribute12 => ue_rec.ATTRIBUTE12,
            x_attribute13 => ue_rec.ATTRIBUTE13,
            x_attribute14 => ue_rec.ATTRIBUTE14,
            x_attribute15 => ue_rec.ATTRIBUTE15,
            x_object_version_number => ue_rec.OBJECT_VERSION_NUMBER + 1,
            x_last_update_date => sysdate,
            x_last_updated_by => fnd_global.user_id,
            x_last_update_login => fnd_global.login_id
         );

	/* Insert SR update status call here after making sure that object type is 'SR' for p_unit_effectivity_id
	* This call should be made only when p_new_status = 'DEFERRED' as SR can not be terminated
	* IF SR need to be updated even when deferral has been rejected then make the same call in ELSIF
	* statement below
	*/
	-- TAMAL -- Begin changes for ER #3356804
	-- TAMAL -- Get UE and SR details
	OPEN get_ue_sr_details (ue_rec.UNIT_EFFECTIVITY_ID);
	FETCH get_ue_sr_details INTO l_ue_obj_type, l_cs_incident_id, l_cs_incident_number, l_cs_incident_ovn;
	CLOSE get_ue_sr_details;

	-- TAMAL -- Checking for SR type
	-- TAMAL -- Checking for DEFERRED status
        -- Add Cancelled status to support SR cancellation for nonserialized items.
	IF (l_ue_obj_type IS NOT NULL AND l_ue_obj_type = 'SR' AND p_new_status IS NOT NULL
           AND p_new_status IN ('DEFERRED','CANCELLED'))
	THEN
		IF NOT (l_cs_incident_id IS NOT NULL AND l_cs_incident_id > 0)
		THEN
			FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_INVALID_INCIDENT_ID');
			FND_MESSAGE.SET_TOKEN('INCIDENT_ID', l_cs_incident_id);
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
			fnd_log.string
			(
				fnd_log.level_unexpected,
				'ahl.plsql.AHL_PRD_DF_PVT.process_unit_maint_plan',
				'Wrong SR incident id: ' || l_cs_incident_id
			);
			END IF;
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			RETURN;
		END IF;

                -- Support for cancelled SRs.
                IF (p_new_status = 'CANCELLED')  THEN
                    l_status_id := FND_PROFILE.VALUE('AHL_PRD_SR_CANCELLED_STATUS');
                    IF (l_status_id IS NULL) THEN
                      l_status_id := 2; -- closed.
                    END IF;
                ELSE -- Deferred
                    l_status_id := 1; -- open.
                END IF;

-- yazhou 29-Jun-2006 starts
-- bug#5359943
-- Pass p_status_id as 1 (OPEN)

		-- Call SR Update_Status API
		CS_ServiceRequest_PUB.Update_Status
		(
			p_api_version 			=> 2.0,
			p_init_msg_list 		=> FND_API.G_FALSE,
			p_commit 			=> FND_API.G_FALSE,
			p_resp_appl_id 			=> NULL,
			p_resp_id 			=> NULL,
			p_user_id 			=> NULL,
			p_login_id 			=> NULL,
			--p_status_id 			=> 1,   --OPEN
			p_status_id 			=> l_status_id,
			p_closed_date 			=> NULL,
			p_audit_comments 		=> NULL,
			p_called_by_workflow 		=> FND_API.G_FALSE,
			p_workflow_process_id 		=> NULL,
			p_comments 			=> NULL,
			p_public_comment_flag 		=> FND_API.G_FALSE,
			p_validate_sr_closure 		=> 'N',
			p_auto_close_child_entities 	=> 'N',
			p_request_id 			=> NULL,
			p_request_number 		=> l_cs_incident_number,
			x_return_status 		=> l_return_status,
			x_msg_count 			=> l_msg_count,
			x_msg_data 			=> l_msg_data,
			p_object_version_number 	=> l_cs_incident_ovn,
--			p_status 			=> 'OPEN',
			x_interaction_id 		=> l_interaction_id
		);
-- yazhou 29-Jun-2006 ends

		-- Abort if any error in calling the SR Update_Status API...
		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN
			x_return_status := l_return_status;
			RETURN;
		END IF;
	END IF;
	-- TAMAL -- End changes for ER #3356804
      END LOOP;
      -- create tree here
      IF (l_ue_relns_tbl.count > 0 AND p_new_status = 'DEFERRED')THEN
        FOR k IN l_ue_relns_tbl.FIRST..l_ue_relns_tbl.LAST  LOOP
          -- Insert into ahl_ue_relationships.
          AHL_UE_RELATIONSHIPS_PKG.Insert_Row(
            X_UE_RELATIONSHIP_ID => l_ue_relationship_id,
            X_UE_ID              => l_ue_relns_tbl(k).ue_id,
            X_RELATED_UE_ID      => l_ue_relns_tbl(k).related_ue_id,
            X_RELATIONSHIP_CODE  => 'PARENT',
            X_ORIGINATOR_UE_ID   => l_new_parent_ue_id,
            X_ATTRIBUTE_CATEGORY => null,
            X_ATTRIBUTE1 => null,
            X_ATTRIBUTE2 => null,
            X_ATTRIBUTE3 => null,
            X_ATTRIBUTE4 => null,
            X_ATTRIBUTE5 => null,
            X_ATTRIBUTE6 => null,
            X_ATTRIBUTE7 => null,
            X_ATTRIBUTE8 => null,
            X_ATTRIBUTE9 => null,
            X_ATTRIBUTE10 => null,
            X_ATTRIBUTE11 => null,
            X_ATTRIBUTE12 => null,
            X_ATTRIBUTE13 => null,
            X_ATTRIBUTE14 => null,
            X_ATTRIBUTE15 => null,
            X_OBJECT_VERSION_NUMBER => 1,
            X_LAST_UPDATE_DATE => sysdate,
            X_LAST_UPDATED_BY  => fnd_global.user_id,
            X_CREATION_DATE => sysdate,
            X_CREATED_BY  => fnd_global.user_id,
            X_LAST_UPDATE_LOGIN => fnd_global.login_id);
        END LOOP;
      END IF;
      /* Insert SR update status call here after making sure that object type is 'SR' for p_unit_effectivity_id
      * This call should be made only when p_new_status = 'DEFERRED' as SR can not be terminated
      * IF SR need to be updated even when deferral has been rejected then make the same call in ELSIF
      * statement below
      */
    ELSIF(p_approval_result_code IN (G_DEFERRAL_INITIATED,G_DEFERRAL_REJECTED))THEN
      IF(p_approval_result_code = G_DEFERRAL_INITIATED)THEN
         l_orig_deferral_ue_id := l_unit_effectivity_id;
      ELSE
         l_orig_deferral_ue_id := NULL;
      END IF;

      FOR ue_rec IN unit_effectivity_csr(l_unit_effectivity_id) LOOP
         --update applicable unit deferral id for all children
         -- and removing it if deferral got rejected.
         IF(ue_rec.UNIT_EFFECTIVITY_ID <> l_unit_effectivity_id)THEN
            -- update status here
            AHL_UNIT_EFFECTIVITIES_PKG.update_row(
            x_unit_effectivity_id => ue_rec.UNIT_EFFECTIVITY_ID,
            x_csi_item_instance_id => ue_rec.CSI_ITEM_INSTANCE_ID,
            x_mr_interval_id => ue_rec.MR_INTERVAL_ID,
            x_mr_effectivity_id => ue_rec.MR_EFFECTIVITY_ID,
            x_mr_header_id => ue_rec.MR_HEADER_ID,
            x_status_code => ue_rec.status_code,
            x_due_date => ue_rec.DUE_DATE,
            x_due_counter_value => ue_rec.DUE_COUNTER_VALUE,
            x_forecast_sequence => ue_rec.FORECAST_SEQUENCE,
            x_repetitive_mr_flag => ue_rec.REPETITIVE_MR_FLAG,
            x_tolerance_flag => ue_rec.TOLERANCE_FLAG,
            x_remarks => ue_rec.REMARKS,
            x_message_code => ue_rec.MESSAGE_CODE,
            x_preceding_ue_id => ue_rec.PRECEDING_UE_ID,
            x_date_run => ue_rec.DATE_RUN,
            x_set_due_date => ue_rec.set_due_date,
            x_accomplished_date => ue_rec.accomplished_date,
            x_service_line_id   => ue_rec.service_line_id,
            x_program_mr_header_id => ue_rec.program_mr_header_id,
            x_cancel_reason_code   => ue_rec.cancel_reason_code,
            x_earliest_due_date    => ue_rec.earliest_due_date,
            x_latest_due_date      => ue_rec.latest_due_date,
            x_defer_from_ue_id     => ue_rec.defer_from_ue_id,
            x_qa_collection_id     => ue_rec.qa_collection_id,
            x_cs_incident_id       => ue_rec.cs_incident_id,
            x_orig_deferral_ue_id  => l_orig_deferral_ue_id,
            X_APPLICATION_USG_CODE  => RTRIM(LTRIM(FND_PROFILE.VALUE('AHL_APPLN_USAGE'))),
            X_OBJECT_TYPE           => ue_rec.object_type,
            X_MANUALLY_PLANNED_FLAG => ue_rec.manually_planned_flag,
            X_COUNTER_ID            => ue_rec.counter_id,
            X_LOG_SERIES_CODE       => ue_rec.log_series_code,
            X_LOG_SERIES_NUMBER     => ue_rec.log_series_number,
            X_FLIGHT_NUMBER         => ue_rec.flight_number,
            X_MEL_CDL_TYPE_CODE     => ue_rec.mel_cdl_type_code,
            X_POSITION_PATH_ID      => ue_rec.position_path_id,
            X_ATA_CODE              => ue_rec.ATA_CODE,
            X_UNIT_CONFIG_HEADER_ID  => ue_rec.unit_config_header_id,
            x_attribute_category => ue_rec.ATTRIBUTE_CATEGORY,
            x_attribute1 => ue_rec.ATTRIBUTE1,
            x_attribute2 => ue_rec.ATTRIBUTE2,
            x_attribute3 => ue_rec.ATTRIBUTE3,
            x_attribute4 => ue_rec.ATTRIBUTE4,
            x_attribute5 => ue_rec.ATTRIBUTE5,
            x_attribute6 => ue_rec.ATTRIBUTE6,
            x_attribute7 => ue_rec.ATTRIBUTE7,
            x_attribute8 => ue_rec.ATTRIBUTE8,
            x_attribute9 => ue_rec.ATTRIBUTE9,
            x_attribute10 => ue_rec.ATTRIBUTE10,
            x_attribute11 => ue_rec.ATTRIBUTE11,
            x_attribute12 => ue_rec.ATTRIBUTE12,
            x_attribute13 => ue_rec.ATTRIBUTE13,
            x_attribute14 => ue_rec.ATTRIBUTE14,
            x_attribute15 => ue_rec.ATTRIBUTE15,
            x_object_version_number => ue_rec.OBJECT_VERSION_NUMBER + 1,
            x_last_update_date => sysdate,
            x_last_updated_by => fnd_global.user_id,
            x_last_update_login => fnd_global.login_id);
         END IF;
     END LOOP;
   END IF;

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.process_unit_maint_plan.end',
			'At the end of PLSQL procedure'
		);
   END IF;

END process_unit_maint_plan;

-------------------------------------------------------------------------
-------------------------------------------------------------------------
PROCEDURE process_prior_ump_deferrals(
          p_unit_effectivity_id  IN             NUMBER) IS

    CURSOR prior_child_defer_to_ue_csr(p_unit_effectivity_id  IN  NUMBER) IS
    SELECT UE.unit_effectivity_id FROM ahl_unit_effectivities_b UE
    WHERE defer_from_ue_id IS NOT NULL
    --AND NOT EXISTS (Select 'x' from ahl_visit_tasks_b VST where VST.unit_effectivity_id = UE.unit_effectivity_id)
    AND defer_from_ue_id IN (
      SELECT related_ue_id
      FROM   AHL_UE_RELATIONSHIPS
      WHERE  relationship_code = 'PARENT'
      START WITH ue_id = p_unit_effectivity_id
      CONNECT BY ue_id = PRIOR related_ue_id
    );

    CURSOR assigned_to_visit_csr(p_unit_effectivity_id  IN  NUMBER) IS
    SELECT 'x' FROM ahl_visit_tasks_b VST
    WHERE VST.unit_effectivity_id = p_unit_effectivity_id;

    l_exists VARCHAR2(1);

    CURSOR ue_rel_id_csr(p_unit_effectivity_id  IN  NUMBER) IS
    SELECT ue_relationship_id FROM   AHL_UE_RELATIONSHIPS
    WHERE  relationship_code = 'PARENT'
    AND related_ue_id = p_unit_effectivity_id;

    l_ue_relationship_id  NUMBER;

    CURSOR unit_effectivity_csr (p_unit_effectivity_id IN NUMBER) IS
    SELECT
      UNIT_EFFECTIVITY_ID, OBJECT_VERSION_NUMBER, CSI_ITEM_INSTANCE_ID, MR_INTERVAL_ID,
      MR_EFFECTIVITY_ID, MR_HEADER_ID, STATUS_CODE, SET_DUE_DATE, ACCOMPLISHED_DATE,
      DUE_DATE, DUE_COUNTER_VALUE, FORECAST_SEQUENCE, REPETITIVE_MR_FLAG,
      TOLERANCE_FLAG, DATE_RUN, PRECEDING_UE_ID, MESSAGE_CODE, REMARKS,
      SERVICE_LINE_ID, PROGRAM_MR_HEADER_ID, CANCEL_REASON_CODE, EARLIEST_DUE_DATE,
      LATEST_DUE_DATE, DEFER_FROM_UE_ID, CS_INCIDENT_ID, QA_COLLECTION_ID,
      ORIG_DEFERRAL_UE_ID, COUNTER_ID,OBJECT_TYPE,MANUALLY_PLANNED_FLAG,
      LOG_SERIES_CODE,LOG_SERIES_NUMBER,FLIGHT_NUMBER, MEL_CDL_TYPE_CODE,
      POSITION_PATH_ID, ATA_CODE, UNIT_CONFIG_HEADER_ID,
      ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3,
      ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,ATTRIBUTE9,
      ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,ATTRIBUTE15
    FROM  AHL_UNIT_EFFECTIVITIES_VL UE
    WHERE unit_effectivity_id = p_unit_effectivity_id;

    CURSOR redundant_deferral_ue_csr(p_unit_effectivity_id  IN  NUMBER) IS
    SELECT UD.unit_deferral_id FROM ahl_unit_deferrals_b UD
    WHERE UD.unit_deferral_type = 'DEFERRAL'
    AND UD.unit_effectivity_id IN (
      SELECT related_ue_id
      FROM   AHL_UE_RELATIONSHIPS
      WHERE  relationship_code = 'PARENT'
      START WITH ue_id = p_unit_effectivity_id
      CONNECT BY ue_id = PRIOR related_ue_id
    )
    AND NOT EXISTS (
      SELECT 'x' FROM ahl_unit_effectivities_b
      WHERE defer_from_ue_id  = UD.unit_effectivity_id
    );

    CURSOR redundant_threshold_csr(p_unit_deferral_id IN NUMBER) IS
    SELECT unit_threshold_id FROM ahl_unit_thresholds
    WHERE unit_deferral_id = p_unit_deferral_id;


BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.process_prior_ump_deferrals.begin',
			'At the start of PLSQL procedure'
		);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_prior_ump_deferrals',
			'deleting redundant ue, relationships and marking as exception if assigned to visit'
		);
    END IF;

    FOR ue_id_rec IN prior_child_defer_to_ue_csr(p_unit_effectivity_id) LOOP
       -- determine whether assigned to a visit
       OPEN assigned_to_visit_csr(ue_id_rec.unit_effectivity_id);
       FETCH assigned_to_visit_csr INTO l_exists;
       IF(assigned_to_visit_csr%NOTFOUND)THEN
          -- if not assigned to a visit delete the ue rec and relationships
          AHL_UNIT_EFFECTIVITIES_PKG.delete_row(ue_id_rec.unit_effectivity_id);
          OPEN ue_rel_id_csr(ue_id_rec.unit_effectivity_id);
          FETCH ue_rel_id_csr INTO l_ue_relationship_id;
          IF(ue_rel_id_csr%FOUND) THEN
             AHL_UE_RELATIONSHIPS_PKG.delete_row(l_ue_relationship_id);
          END IF;
          CLOSE ue_rel_id_csr;
       ELSE -- assigned to visit -- mark as exception
          FOR ue_rec IN unit_effectivity_csr(ue_id_rec.unit_effectivity_id) LOOP
            -- update status
            AHL_UNIT_EFFECTIVITIES_PKG.update_row(
            x_unit_effectivity_id => ue_rec.UNIT_EFFECTIVITY_ID,
            x_csi_item_instance_id => ue_rec.CSI_ITEM_INSTANCE_ID,
            x_mr_interval_id => ue_rec.MR_INTERVAL_ID,
            x_mr_effectivity_id => ue_rec.MR_EFFECTIVITY_ID,
            x_mr_header_id => ue_rec.MR_HEADER_ID,
            x_status_code => 'EXCEPTION',
            x_due_date => ue_rec.DUE_DATE,
            x_due_counter_value => ue_rec.DUE_COUNTER_VALUE,
            x_forecast_sequence => ue_rec.FORECAST_SEQUENCE,
            x_repetitive_mr_flag => ue_rec.REPETITIVE_MR_FLAG,
            x_tolerance_flag => ue_rec.TOLERANCE_FLAG,
            x_remarks => ue_rec.REMARKS,
            x_message_code => ue_rec.MESSAGE_CODE,
            x_preceding_ue_id => ue_rec.PRECEDING_UE_ID,
            x_date_run => ue_rec.DATE_RUN,
            x_set_due_date => ue_rec.set_due_date,
            x_accomplished_date => ue_rec.accomplished_date,
            x_service_line_id   => ue_rec.service_line_id,
            x_program_mr_header_id => ue_rec.program_mr_header_id,
            x_cancel_reason_code   => ue_rec.cancel_reason_code,
            x_earliest_due_date    => ue_rec.earliest_due_date,
            x_latest_due_date      => ue_rec.latest_due_date,
            x_defer_from_ue_id     => ue_rec.defer_from_ue_id,
            x_qa_collection_id     => ue_rec.qa_collection_id,
            x_cs_incident_id       => ue_rec.cs_incident_id,
            x_orig_deferral_ue_id  => ue_rec.orig_deferral_ue_id,
            X_APPLICATION_USG_CODE  => RTRIM(LTRIM(FND_PROFILE.VALUE('AHL_APPLN_USAGE'))),
            X_OBJECT_TYPE           => ue_rec.object_type,
            X_MANUALLY_PLANNED_FLAG => ue_rec.manually_planned_flag,
            X_COUNTER_ID            => ue_rec.counter_id,
            X_LOG_SERIES_CODE       => ue_rec.log_series_code,
            X_LOG_SERIES_NUMBER     => ue_rec.log_series_number,
            X_FLIGHT_NUMBER         => ue_rec.flight_number,
            X_MEL_CDL_TYPE_CODE     => ue_rec.mel_cdl_type_code,
            X_POSITION_PATH_ID      => ue_rec.position_path_id,
            X_ATA_CODE              => ue_rec.ATA_CODE,
            X_UNIT_CONFIG_HEADER_ID  => ue_rec.unit_config_header_id,
            x_attribute_category => ue_rec.ATTRIBUTE_CATEGORY,
            x_attribute1 => ue_rec.ATTRIBUTE1,
            x_attribute2 => ue_rec.ATTRIBUTE2,
            x_attribute3 => ue_rec.ATTRIBUTE3,
            x_attribute4 => ue_rec.ATTRIBUTE4,
            x_attribute5 => ue_rec.ATTRIBUTE5,
            x_attribute6 => ue_rec.ATTRIBUTE6,
            x_attribute7 => ue_rec.ATTRIBUTE7,
            x_attribute8 => ue_rec.ATTRIBUTE8,
            x_attribute9 => ue_rec.ATTRIBUTE9,
            x_attribute10 => ue_rec.ATTRIBUTE10,
            x_attribute11 => ue_rec.ATTRIBUTE11,
            x_attribute12 => ue_rec.ATTRIBUTE12,
            x_attribute13 => ue_rec.ATTRIBUTE13,
            x_attribute14 => ue_rec.ATTRIBUTE14,
            x_attribute15 => ue_rec.ATTRIBUTE15,
            x_object_version_number => ue_rec.OBJECT_VERSION_NUMBER + 1,
            x_last_update_date => sysdate,
            x_last_updated_by => fnd_global.user_id,
            x_last_update_login => fnd_global.login_id);
          END LOOP;
       END IF;
       CLOSE assigned_to_visit_csr;
    END LOOP;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.process_prior_ump_deferrals',
			'deleting un-necessary deferral records'
		);
    END IF;

    FOR redundant_deferral_rec IN redundant_deferral_ue_csr(p_unit_effectivity_id) LOOP
      FOR redundant_threshold_rec IN redundant_threshold_csr(redundant_deferral_rec.unit_deferral_id) LOOP
        AHL_UNIT_THRESHOLDS_PKG.delete_row(redundant_threshold_rec.unit_threshold_id);
      END LOOP;
      AHL_UNIT_DEFERRALS_PKG.delete_row(redundant_deferral_rec.unit_deferral_id);
    END LOOP;


    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.process_prior_ump_deferrals.end',
			'At the end of PLSQL procedure'
		);
     END IF;
END process_prior_ump_deferrals;



-------------------------------------------------------------------------
-- Procedure to get deferral details attached to any unit effectivity --
--------------------------------------------------------------------------
PROCEDURE get_deferral_details (

    p_init_msg_list          IN          VARCHAR2  := FND_API.G_FALSE,
    p_unit_effectivity_id    IN          NUMBER,
	x_df_header_info_rec     OUT NOCOPY  AHL_PRD_DF_PVT.df_header_info_rec_type,
    x_df_schedules_tbl       OUT NOCOPY  AHL_PRD_DF_PVT.df_schedules_tbl_type,
    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2) IS

    l_api_name         CONSTANT VARCHAR2(30) := 'get_deferral_details';

    l_df_header_info_rec AHL_PRD_DF_PVT.df_header_info_rec_type;
    l_applicable_ue_id NUMBER;

    -- to fecth context information
    CURSOR context_info_csr(p_unit_effectivity_id IN NUMBER) IS
    SELECT due_date, mr_header_id,title,description,repetitive_mr_flag,cs_incident_id,cs_incident_number,
           cs_incident_summary,manually_planned_flag
    FROM ahl_ue_deferral_details_v
    WHERE unit_effectivity_id = p_unit_effectivity_id
    AND APPLICATION_USG_CODE = RTRIM(LTRIM(FND_PROFILE.VALUE('AHL_APPLN_USAGE'))) ;--this takes care of app_usage changes

    -- mr status meaning has to be fecthed seperately because function returns only code
    CURSOR mr_status_meaning_csr(p_status_code IN VARCHAR2)IS
    SELECT meaning FROM FND_LOOKUP_VALUES_VL
    WHERE lookup_code = p_status_code
    AND lookup_type = 'AHL_PRD_MR_STATUS';

    -- to fetch visit info
    CURSOR visit_info_csr(p_unit_effectivity_id IN NUMBER) IS
    SELECT VS.visit_id, VS.visit_number FROM ahl_visits_b VS,ahl_visit_tasks_b VST
    WHERE VST.visit_id = VS.visit_id
    AND VST.unit_effectivity_id = p_unit_effectivity_id;

     -- to check whether MR or any of its children has resettable counters
    CURSOR reset_counter_csr(p_unit_effectivity_id IN NUMBER) IS
    /* In R12, modified to use csi_counters_vl instead of csi_cp_counters_v.
    SELECT 'x' from csi_cp_counters_v CP, AHL_MR_INTERVALS_V MRI, AHL_MR_EFFECTIVITIES MRE, AHL_UNIT_EFFECTIVITIES_B UE
    WHERE CP.customer_product_id = UE.csi_item_instance_id
    AND CP.counter_name = MRI.counter_name
    AND MRI.reset_value IS NOT NULL
    AND MRI.mr_effectivity_id = MRE.mr_effectivity_id
    AND MRE.mr_header_id = UE.mr_header_id
    AND UE.unit_effectivity_id = p_unit_effectivity_id
    UNION
    SELECT 'x' from csi_cp_counters_v CP, AHL_MR_INTERVALS_V MRI, AHL_MR_EFFECTIVITIES MRE, AHL_UNIT_EFFECTIVITIES_B UE
    WHERE CP.customer_product_id = UE.csi_item_instance_id
    AND CP.counter_name = MRI.counter_name
    AND MRI.reset_value IS NOT NULL
    AND MRI.mr_effectivity_id = MRE.mr_effectivity_id
    AND MRE.mr_header_id = UE.mr_header_id
    AND UE.unit_effectivity_id IN
      (

         SELECT     related_ue_id
         FROM       AHL_UE_RELATIONSHIPS
         WHERE      relationship_code = 'PARENT'
         START WITH ue_id = p_unit_effectivity_id
         CONNECT BY ue_id = PRIOR related_ue_id

      );
    */

    SELECT 'x'
    from csi_counter_associations ca, csi_counters_vl CP, AHL_MR_INTERVALS_V MRI,
         AHL_MR_EFFECTIVITIES  MRE, AHL_UNIT_EFFECTIVITIES_B UE
    WHERE CA.source_object_id = UE.csi_item_instance_id
    AND ca.source_object_code = 'CP'
    AND CP.counter_template_name = MRI.counter_name
    AND MRI.reset_value IS NOT NULL
    AND MRI.mr_effectivity_id = MRE.mr_effectivity_id
    AND MRE.mr_header_id = UE.mr_header_id
    AND UE.unit_effectivity_id = p_unit_effectivity_id
    UNION
    SELECT 'x'
    from csi_counter_associations ca, csi_counters_vl CP, AHL_MR_INTERVALS_V MRI,
         AHL_MR_EFFECTIVITIES  MRE, AHL_UNIT_EFFECTIVITIES_B UE
    WHERE CA.source_object_id = UE.csi_item_instance_id
    AND ca.source_object_code = 'CP'
    AND CP.counter_template_name = MRI.counter_name
    AND MRI.reset_value IS NOT NULL
    AND MRI.mr_effectivity_id = MRE.mr_effectivity_id
    AND MRE.mr_header_id = UE.mr_header_id
    AND UE.unit_effectivity_id IN
      (

         SELECT     related_ue_id
         FROM       AHL_UE_RELATIONSHIPS
         WHERE      relationship_code = 'PARENT'
         START WITH ue_id = p_unit_effectivity_id
         CONNECT BY ue_id = PRIOR related_ue_id

      );

    l_exists VARCHAR2(1);

    -- to fetch df_header_rec
    CURSOR df_header_info_csr(p_unit_effectivity_id IN NUMBER) IS
    SELECT unit_deferral_id, object_version_number, approval_status_code,FLV.meaning approval_status_meaning,defer_reason_code,skip_mr_flag,
        affect_due_calc_flag, set_due_date, deferral_effective_on,remarks,approver_notes, user_deferral_type, DTYP.meaning user_deferral_mean,
	/*manisaga: added attributes for DFF Enablement on 22-Jan-2010--start     */
   ahl_unit_deferrals_vl.attribute_category,ahl_unit_deferrals_vl.attribute1,ahl_unit_deferrals_vl.attribute2,ahl_unit_deferrals_vl.attribute3,
   ahl_unit_deferrals_vl.attribute4,ahl_unit_deferrals_vl.attribute5,ahl_unit_deferrals_vl.attribute6,ahl_unit_deferrals_vl.attribute7,
   ahl_unit_deferrals_vl.attribute8,ahl_unit_deferrals_vl.attribute9,ahl_unit_deferrals_vl.attribute10,ahl_unit_deferrals_vl.attribute11,
   ahl_unit_deferrals_vl.attribute12,ahl_unit_deferrals_vl.attribute13,ahl_unit_deferrals_vl.attribute14,ahl_unit_deferrals_vl.attribute15
   /*manisaga: added attributes for DFF Enablement on 22-Jan-2010--end     */

    FROM ahl_unit_deferrals_vl,fnd_lookup_values_vl FLV, fnd_lookup_values_vl DTYP
    WHERE unit_deferral_type = 'DEFERRAL'
    AND unit_effectivity_id = p_unit_effectivity_id
    AND FLV.lookup_code = approval_status_code
    AND FLV.lookup_type = 'AHL_PRD_DF_APPR_STATUS_TYPES'
    AND DTYP.lookup_type(+) = 'AHL_PRD_DEFERRAL_TYPE'
    AND DTYP.lookup_code(+) = user_deferral_type ;

    -- fetch deferral schedule rec
    CURSOR df_schedule_tbl_csr(p_unit_deferral_id IN NUMBER) IS
    SELECT UT.unit_threshold_id,UT.object_version_number,UT.unit_deferral_id, UT.counter_id,
           CO.name, UT.counter_value, UT.ctr_value_type_code,MU.unit_of_measure
    FROM MTL_UNITS_OF_MEASURE_VL MU, CS_COUNTERS CO,ahl_unit_thresholds UT
    WHERE MU.uom_code = CO.uom_code
    AND CO.counter_id = UT.counter_id
    AND UT.unit_deferral_id = p_unit_deferral_id
    ORDER BY CO.name;


    i NUMBER := 0;
    l_df_schedules_tbl       AHL_PRD_DF_PVT.df_schedules_tbl_type;

BEGIN
     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.get_deferral_details.begin',
			'At the start of PLSQL procedure'
		);
     END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean( p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;
     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_PVT.get_deferral_details',
			'Got request for deferral record of Unit effectivity ID : ' || p_unit_effectivity_id
		);
     END IF;

     IF(p_unit_effectivity_id IS NULL OR p_unit_effectivity_id = FND_API.G_MISS_NUM)THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_HREC_KMISS');
        FND_MSG_PUB.ADD;
        IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.get_deferral_details',
			    'Invalid request, Unit Effectivity IS NULL'
		    );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     --get applicable ue id and find out whether deferral record should be shown.
     l_applicable_ue_id := get_applicable_ue(p_unit_effectivity_id);

     -- throw errors if any
     IF(FND_MSG_PUB.count_msg > 0)THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     IF(l_applicable_ue_id IS NULL)THEN
        l_applicable_ue_id := p_unit_effectivity_id;
        /*FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_MRSR_STATUS');
        FND_MSG_PUB.ADD;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		   fnd_log.string
		   (
			  fnd_log.level_error,
			  'ahl.plsql.AHL_PRD_DF_PVT.get_deferral_details',
			  'Status of MR or SR is not valid for deferral'
		   );
        END IF;*/
     END IF;
     l_df_header_info_rec.unit_effectivity_id := l_applicable_ue_id;
     --dbms_output.put_line('l_applicable_ue_id : ' || l_applicable_ue_id  );
     -- fill in context information
     OPEN context_info_csr(l_applicable_ue_id);
     FETCH context_info_csr INTO l_df_header_info_rec.due_date,l_df_header_info_rec.mr_header_id,
                                 l_df_header_info_rec.mr_title,l_df_header_info_rec.mr_description,
                                 l_df_header_info_rec.mr_repetitive_flag,l_df_header_info_rec.incident_id,
                                 l_df_header_info_rec.incident_number,l_df_header_info_rec.summary,
                                 l_df_header_info_rec.manually_planned_flag;

     IF(context_info_csr%NOTFOUND)THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_HREC_UE_ID');
        FND_MSG_PUB.ADD;
        IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.get_deferral_details',
			    'Unit Effectivity record not found'
		    );
        END IF;
        CLOSE context_info_csr;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     CLOSE context_info_csr;


     l_df_header_info_rec.ue_status_code := AHL_COMPLETIONS_PVT.get_mr_status(l_df_header_info_rec.unit_effectivity_id);

     OPEN mr_status_meaning_csr(l_df_header_info_rec.ue_status_code);
     FETCH mr_status_meaning_csr INTO l_df_header_info_rec.ue_status_meaning;
     IF(mr_status_meaning_csr%NOTFOUND)THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_UE_MR');
        FND_MSG_PUB.ADD;
        IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.get_deferral_details',
			        'Invalid unit effectivity record, mr status meaning not found'
		    );
        END IF;
        CLOSE mr_status_meaning_csr;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      CLOSE mr_status_meaning_csr;

     -- fill in visit information
     OPEN visit_info_csr(l_applicable_ue_id);
     FETCH visit_info_csr INTO l_df_header_info_rec.visit_id,l_df_header_info_rec.visit_number;
     /* R12: UMP Deferral.
     IF(visit_info_csr%NOTFOUND)THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_UE_VISIT');
        FND_MSG_PUB.ADD;
        IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.get_deferral_details',
			    'Visit Information not found'
		    );
        END IF;
        CLOSE visit_info_csr;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     */
     CLOSE visit_info_csr;

    -- filling in  mr/sr type and whether mr or its children has restettable counters
    IF(l_df_header_info_rec.mr_header_id IS NOT NULL) THEN
        l_df_header_info_rec.deferral_type := G_DEFERRAL_TYPE_MR;
        l_df_header_info_rec.reset_counter_flag := G_YES_FLAG;
        IF(l_df_header_info_rec.mr_repetitive_flag = G_YES_FLAG)THEN
           OPEN reset_counter_csr(l_applicable_ue_id);
           FETCH reset_counter_csr INTO l_exists;
           IF(reset_counter_csr%NOTFOUND)THEN
              l_df_header_info_rec.reset_counter_flag := G_NO_FLAG;
           END IF;
           CLOSE reset_counter_csr;
        END IF;
    ELSIF l_df_header_info_rec.incident_id IS NOT NULL THEN
        l_df_header_info_rec.deferral_type := G_DEFERRAL_TYPE_SR;
        l_df_header_info_rec.mr_repetitive_flag := G_NO_FLAG;
        l_df_header_info_rec.reset_counter_flag := G_YES_FLAG;
    END IF;

    -- throw errors if any
    IF(FND_MSG_PUB.count_msg > 0)THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- fetch deferral header record
    OPEN df_header_info_csr(l_applicable_ue_id);
    FETCH df_header_info_csr INTO l_df_header_info_rec.unit_deferral_id,
                                  l_df_header_info_rec.object_version_number,
                                  l_df_header_info_rec.approval_status_code,
                                  l_df_header_info_rec.approval_status_meaning,
                                  l_df_header_info_rec.defer_reason_code,
                                  l_df_header_info_rec.skip_mr_flag,
                                  l_df_header_info_rec.affect_due_calc_flag,
                                  l_df_header_info_rec.set_due_date,
                                  l_df_header_info_rec.deferral_effective_on,
                                  l_df_header_info_rec.remarks,
                                  l_df_header_info_rec.approver_notes,
                                  l_df_header_info_rec.user_deferral_type_code,
                                  l_df_header_info_rec.user_deferral_type_mean,
				    /*manisaga: added attributes for DFF Enablement on 22-Jan-2010--start     */
                                  l_df_header_info_rec.attribute_category,
                                  l_df_header_info_rec.attribute1,
                                  l_df_header_info_rec.attribute2,
                                  l_df_header_info_rec.attribute3,
                                  l_df_header_info_rec.attribute4,
                                  l_df_header_info_rec.attribute5,
                                  l_df_header_info_rec.attribute6,
                                  l_df_header_info_rec.attribute7,
                                  l_df_header_info_rec.attribute8,
                                  l_df_header_info_rec.attribute9,
                                  l_df_header_info_rec.attribute10,
                                  l_df_header_info_rec.attribute11,
                                  l_df_header_info_rec.attribute12,
                                  l_df_header_info_rec.attribute13,
                                  l_df_header_info_rec.attribute14,
                                  l_df_header_info_rec.attribute15;
                                  /*manisaga: added attributes for DFF Enablement on 22-Jan-2010--end     */

    IF(df_header_info_csr%NOTFOUND)THEN
       l_df_header_info_rec.skip_mr_flag := G_NO_FLAG;
       l_df_header_info_rec.affect_due_calc_flag := G_YES_FLAG;
       l_df_header_info_rec.approval_status_code := 'DRAFT';
       IF(l_df_header_info_rec.deferral_type = G_DEFERRAL_TYPE_MR AND
          l_df_header_info_rec.reset_counter_flag = G_NO_FLAG)THEN
          l_df_header_info_rec.affect_due_calc_flag := G_NO_FLAG;
       END IF;
       l_df_header_info_rec.deferral_effective_on := SYSDATE;
    ELSIF(l_df_header_info_rec.approval_status_code IN ('DEFERRAL_REJECTED'))THEN --,'DEFERRAL_PENDING','DEFERRED'))THEN
       l_df_header_info_rec.ue_status_code := l_df_header_info_rec.approval_status_code;
       l_df_header_info_rec.ue_status_meaning := l_df_header_info_rec.approval_status_meaning;
    END IF;
    CLOSE df_header_info_csr;

    -- throw errors if any
    IF(FND_MSG_PUB.count_msg > 0)THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- fetch deferral schedule rec
    IF(l_df_header_info_rec.unit_deferral_id IS NOT NULL)THEN
       OPEN df_schedule_tbl_csr(l_df_header_info_rec.unit_deferral_id);
       LOOP
          FETCH df_schedule_tbl_csr INTO
                         l_df_schedules_tbl(i).unit_threshold_id,
                         l_df_schedules_tbl(i).object_version_number,
                         l_df_schedules_tbl(i).unit_deferral_id,
                         l_df_schedules_tbl(i).counter_id,
                         l_df_schedules_tbl(i).counter_name,
                         l_df_schedules_tbl(i).counter_value,
                         l_df_schedules_tbl(i).ctr_value_type_code,
                         l_df_schedules_tbl(i).unit_of_measure;
       EXIT WHEN df_schedule_tbl_csr%NOTFOUND;
        i := i + 1;
       END LOOP;
       CLOSE df_schedule_tbl_csr;
    END IF;

    -- throw errors if any
    IF(FND_MSG_PUB.count_msg > 0)THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_df_header_info_rec := l_df_header_info_rec;
    x_df_schedules_tbl   := l_df_schedules_tbl;


    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_PVT.get_deferral_details.end',
			'At the end of PLSQL procedure'
		);
    END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_df_header_info_rec := l_df_header_info_rec;
   x_df_schedules_tbl := l_df_schedules_tbl;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_df_header_info_rec := l_df_header_info_rec;
   x_df_schedules_tbl := l_df_schedules_tbl;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_df_header_info_rec := l_df_header_info_rec;
    x_df_schedules_tbl := l_df_schedules_tbl;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
END get_deferral_details;

FUNCTION get_applicable_ue(
       p_unit_effectivity_id NUMBER) RETURN NUMBER IS

    -- to fecth context information
    CURSOR  applicable_ue_csr(p_unit_effectivity_id IN NUMBER) IS
    SELECT  orig_deferral_ue_id,ue_status_code,def_status_code
    FROM ahl_ue_deferral_details_v
    WHERE unit_effectivity_id = p_unit_effectivity_id;

    l_orig_deferral_ue_id NUMBER;
    l_ue_status_code VARCHAR2(30);
    l_def_status_code VARCHAR2(30);
    l_applicable_ue_id NUMBER;
BEGIN
    OPEN applicable_ue_csr(p_unit_effectivity_id);
    FETCH applicable_ue_csr INTO l_orig_deferral_ue_id,
                                 l_ue_status_code,
                                 l_def_status_code;
    IF(applicable_ue_csr%NOTFOUND)THEN
       FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_PRD_DF_INV_HREC_UE_ID');
       FND_MSG_PUB.ADD;
       IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_PVT.get_applicable_ue',
			    'Unit Effectivity record not found'
		    );
       END IF;
    ELSE
       l_applicable_ue_id := l_orig_deferral_ue_id;
       IF(l_orig_deferral_ue_id IS NULL)THEN
          IF((NVL(l_def_status_code,'x') IN ('DEFERRAL_PENDING','DEFERRED','TERMINATED','CANCELLED')) OR
              (NVL(l_ue_status_code,'x') IN ('DEFERRED','TERMINATED','CANCELLED')) OR
               l_ue_status_code IS NULL )THEN
             l_applicable_ue_id := p_unit_effectivity_id;
          END IF;
       END IF;
    END IF;
    CLOSE applicable_ue_csr;
    RETURN l_applicable_ue_id;

END get_applicable_ue;

--------------------------------------------------------------------------------
FUNCTION process_deferred_exceptions(p_unit_effectivity_id IN NUMBER) RETURN BOOLEAN IS

    CURSOR unit_deferral_csr(p_unit_effectivity_id IN NUMBER) IS
    SELECT UD.unit_deferral_id FROM ahl_unit_deferrals_b UD
    WHERE UD.unit_deferral_type = 'DEFERRAL'
    AND UD.unit_effectivity_id = p_unit_effectivity_id;

    l_unit_deferral_id NUMBER;

    CURSOR redundant_threshold_csr(p_unit_deferral_id IN NUMBER) IS
    SELECT unit_threshold_id FROM ahl_unit_thresholds
    WHERE unit_deferral_id = p_unit_deferral_id;

BEGIN
    OPEN unit_deferral_csr(p_unit_effectivity_id);
    FETCH unit_deferral_csr INTO l_unit_deferral_id;
    IF(unit_deferral_csr%NOTFOUND)THEN
       RETURN FALSE;
    ELSE
      FOR redundant_threshold_rec IN redundant_threshold_csr(l_unit_deferral_id) LOOP
        AHL_UNIT_THRESHOLDS_PKG.delete_row(redundant_threshold_rec.unit_threshold_id);
      END LOOP;
      AHL_UNIT_DEFERRALS_PKG.delete_row(l_unit_deferral_id);
    END IF;
    RETURN TRUE;
END process_deferred_exceptions;


FUNCTION Is_UMP_Deferral(p_unit_deferral_id IN NUMBER) RETURN BOOLEAN
IS
  CURSOR wo_exists_csr(p_unit_deferral_id IN NUMBER) IS
    /* -- fix for bug# 6849943 (FP for Bug # 6815689).
    SELECT 'x'
    FROM   ahl_workorder_tasks_v wo, ahl_unit_deferrals_b udf
    WHERE  wo.unit_effectivity_id = udf.unit_effectivity_id
      AND  udf.unit_deferral_id = p_unit_deferral_id;
    */

    SELECT 'x'
    FROM   ahl_workorders wo, ahl_unit_deferrals_b udf,
           ahl_visit_tasks_b vts, ahl_visits_b vst,
           (SELECT ORGANIZATION_ID
            FROM INV_ORGANIZATION_INFO_V
            WHERE NVL (operating_unit, mo_global.get_current_org_id()) = mo_global.get_current_org_id()) ORG
    WHERE  WO.VISIT_TASK_ID=VTS.VISIT_TASK_ID
      AND VST.VISIT_ID=VTS.VISIT_ID
      AND VST.ORGANIZATION_ID=ORG.ORGANIZATION_ID
      AND vts.unit_effectivity_id = udf.unit_effectivity_id
      AND udf.unit_deferral_id = p_unit_deferral_id
      AND rownum < 2;

  l_exists  VARCHAR2(1);
  l_found   BOOLEAN;

BEGIN
  OPEN wo_exists_csr(p_unit_deferral_id);
  FETCH wo_exists_csr INTO l_exists;
  IF (wo_exists_csr%FOUND) THEN
    l_found := FALSE;
  ELSE
    l_found := TRUE;
  END IF;
  CLOSE wo_exists_csr;

  RETURN l_found;

END Is_UMP_Deferral;


END AHL_PRD_DF_PVT; -- Package body


/
