--------------------------------------------------------
--  DDL for Package Body AHL_COMPLETIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_COMPLETIONS_PVT" AS
/* $Header: AHLVPRCB.pls 120.45.12010000.11 2010/04/21 11:18:33 jkjain ship $ */

G_PKG_NAME VARCHAR2(30) := 'AHL_COMPLETIONS_PVT';
G_DEBUG    VARCHAR2(1)  := AHL_DEBUG_PUB.is_log_enabled;

-- Operation Statuses
G_OP_STATUS_UNCOMPLETE VARCHAR2(2) := '2'; --Uncomplete
G_OP_STATUS_COMPLETE VARCHAR2(2) := '1'; --Complete

-- Job Statuses
G_JOB_STATUS_UNRELEASED VARCHAR2(2) := '1'; --Unreleased
G_JOB_STATUS_RELEASED VARCHAR2(2) := '3'; --Released
G_JOB_STATUS_COMPLETE VARCHAR2(2) := '4'; --Complete
G_JOB_STATUS_COMPLETE_NC VARCHAR2(2) := '5'; --Complete No Charges
G_JOB_STATUS_ON_HOLD VARCHAR2(2) := '6'; --On Hold
G_JOB_STATUS_CANCELLED VARCHAR2(2) := '7'; --Cancelled
G_JOB_STATUS_CLOSED VARCHAR2(2) := '12'; --Closed
G_JOB_STATUS_PARTS_HOLD VARCHAR2(2) := '19'; --Parts Hold
G_JOB_STATUS_QA_PENDING VARCHAR2(2) := '20'; --Pending QA Approval
G_JOB_STATUS_DEFERRAL_PENDING VARCHAR2(2) := '21'; --Pending Deferr
G_JOB_STATUS_DELETED VARCHAR2(2) := '22'; --Deleted

-- MR Statuses
G_MR_STATUS_SIGNED_OFF VARCHAR2(30) := 'ACCOMPLISHED'; --Signed Off
G_MR_STATUS_DEFERRED VARCHAR2(30) := 'DEFERRED'; --Deferred
G_MR_STATUS_JOBS_COMPLETE VARCHAR2(30) := 'ALL_JOBS_COMPLETE'; --All Jobs Complete
G_MR_STATUS_JOBS_CANCELLED VARCHAR2(30) := 'ALL_JOBS_CANCELLED'; --All Jobs Cancelled
G_MR_STATUS_INSP_NEEDED VARCHAR2(30) := 'INSPECTION_NEEDED'; --Inspection Needed
G_MR_STATUS_UNRELEASED VARCHAR2(30) := 'UNRELEASED'; --Unreleased
G_MR_STATUS_RELEASED VARCHAR2(30) := 'RELEASED'; --Released
G_MR_STATUS_DEFERRAL_PENDING VARCHAR2(30) := 'DEFERRAL_PENDING'; --Deferral Pending
G_MR_STATUS_JOBS_ON_HOLD VARCHAR2(30) := 'JOBS_ON_HOLD'; --On Hold
G_MR_STATUS_TERMINATED VARCHAR2(30) := 'TERMINATED'; --Terminated
G_MR_STATUS_CANCELLED VARCHAR2(30) := 'CANCELLED'; --Cancelled
G_MR_STATUS_MR_TERMINATED VARCHAR2(30) := 'MR-TERMINATE'; --FP Bug 9096969 JKJain


-- Visit Statuses
G_VISIT_STATUS_RELEASED VARCHAR2(30) := 'RELEASED'; --Released

-- Counter Reading Plan
G_CTR_READING_PLAN_ID NUMBER := FND_PROFILE.value ( 'AHL_WO_CTR_READING_PLAN' );

-- Common Functions / Procedures

--added following procedure for fix of bug number 6467963
PROCEDURE get_mr_details_rec
(
  p_unit_effectivity_id     IN         NUMBER,
  p_object_version_number   IN         NUMBER,
  x_mr_rec                  OUT NOCOPY mr_rec_type
);

-- Function to validate the Inputs of the complete_workorder and defer_workorder APIs
FUNCTION validate_wo_inputs
(
  p_workorder_id           IN   NUMBER,
  p_object_version_no      IN   NUMBER
) RETURN VARCHAR2
IS
BEGIN

  IF ( p_workorder_id IS NULL OR
       p_workorder_id = FND_API.G_MISS_NUM OR
       p_object_version_no IS NULL OR
       p_object_version_no = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_INVALID_WO_INPUTS' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;
END validate_wo_inputs;

-- Function to get the Operation Record
FUNCTION get_operation_rec
(
  p_workorder_operation_id   IN          NUMBER,
  p_object_version_no        IN          NUMBER := NULL,
  x_operation_rec            OUT NOCOPY  operation_rec_type
) RETURN VARCHAR2
IS
-- fix for bug number 7295717 (Sunil)
CURSOR get_op_details(p_workorder_operation_id IN NUMBER) IS
SELECT OP.workorder_operation_id,
         OP.object_version_number,
         OP.workorder_id,
         WO.wip_entity_id,
         OP.operation_sequence_num,
         OP.organization_id,
         OP.description,
         OP.plan_id,
         OP.collection_id,
         OP.actual_start_date,
         OP.actual_end_date,
         OP.status_code,
         OP.status
FROM   AHL_WORKORDERS WO, AHL_WORKORDER_OPERATIONS_V OP
  WHERE  WO.workorder_id = OP.workorder_id
  AND    OP.workorder_operation_id = p_workorder_operation_id;

BEGIN

  /*SELECT OP.workorder_operation_id,
         OP.object_version_number,
         OP.workorder_id,
         WO.wip_entity_id,
         OP.operation_sequence_num,
         OP.organization_id,
         OP.description,
         OP.plan_id,
         OP.collection_id,
         OP.actual_start_date,
         OP.actual_end_date,
         OP.status_code,
         OP.status
  INTO   x_operation_rec.workorder_operation_id,
         x_operation_rec.object_version_number,
         x_operation_rec.workorder_id,
         x_operation_rec.wip_entity_id,
         x_operation_rec.operation_sequence_num,
         x_operation_rec.organization_id,
         x_operation_rec.description,
         x_operation_rec.plan_id,
         x_operation_rec.collection_id,
         x_operation_rec.actual_start_date,
         x_operation_rec.actual_end_date,
         x_operation_rec.status_code,
         x_operation_rec.status
  FROM   AHL_WORKORDERS WO, AHL_WORKORDER_OPERATIONS_V OP
  WHERE  WO.workorder_id = OP.workorder_id
  AND    OP.workorder_operation_id = p_workorder_operation_id;*/
  -- fix for bug number 7295717 (Sunil)
  OPEN get_op_details(p_workorder_operation_id);
  FETCH get_op_details INTO x_operation_rec.workorder_operation_id,
         x_operation_rec.object_version_number,
         x_operation_rec.workorder_id,
         x_operation_rec.wip_entity_id,
         x_operation_rec.operation_sequence_num,
         x_operation_rec.organization_id,
         x_operation_rec.description,
         x_operation_rec.plan_id,
         x_operation_rec.collection_id,
         x_operation_rec.actual_start_date,
         x_operation_rec.actual_end_date,
         x_operation_rec.status_code,
         x_operation_rec.status;
  IF(get_op_details%NOTFOUND)THEN
         FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_OP_NOT_FOUND' );
         FND_MSG_PUB.add;
         CLOSE get_op_details;
         RETURN FND_API.G_RET_STS_ERROR;
  END IF;
  CLOSE get_op_details;


  IF ( p_object_version_no IS NOT NULL AND
       p_object_version_no <> FND_API.G_MISS_NUM ) THEN
    IF ( x_operation_rec.object_version_number <> p_object_version_no ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
      FND_MSG_PUB.add;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;
END get_operation_rec;

-- Function to get the status for
-- use in the error messages
FUNCTIOn get_status
(
  p_status_code 	IN   VARCHAR2,
		p_lookup_type  IN   VARCHAR2
) RETURN VARCHAR2
IS
		CURSOR get_status_csr(c_status_code IN VARCHAR2,
																								c_lookup_type IN VARCHAR2) IS
		SELECT meaning
				FROM fnd_lookup_values_vl
        WHERE lookup_type = c_lookup_type
          AND LOOKUP_CODE = c_status_code;


		l_status_mean VARCHAR2(80);
BEGIN
		OPEN get_status_csr(p_status_code, p_lookup_type);
		FETCH get_status_csr INTO l_status_mean;
		IF get_status_csr%NOTFOUND THEN
				l_status_mean := p_status_code;
		END IF;
		CLOSE get_status_csr;

		RETURN l_status_mean;
EXCEPTION
  WHEN OTHERS THEN
		  -- no exception thrown
				-- just return the status code as the status mean
    RETURN p_status_code;
END get_status;







-- Function to get the Workorder Record
FUNCTION get_workorder_rec
(
  p_workorder_id        IN          NUMBER,
  p_object_version_no   IN          NUMBER := NULL,
  x_workorder_rec       OUT NOCOPY  workorder_rec_type
) RETURN VARCHAR2

IS

--for fix of bug number 6467963/7295717
CURSOR get_wo_dtls_csr(c_workorder_id IN NUMBER) IS
SELECT    WO.workorder_id,
            WO.object_version_number,
            WO.wip_entity_id,
            WDJ.organization_id,
            WO.plan_id,
            WO.collection_id,
            WO.actual_start_date,
            WO.actual_end_date,
            WO.STATUS_CODE,
            MLU.MEANING,
            WO.route_id,
            WDJ.COMPLETION_SUBINVENTORY,
            WDJ.COMPLETION_LOCATOR_ID,
            WO.visit_id,
            WO.visit_task_id
  FROM AHL_WORKORDERS WO, FND_LOOKUP_VALUES_VL MLU,WIP_DISCRETE_JOBS WDJ,
 (SELECT ORGANIZATION_ID FROM INV_ORGANIZATION_INFO_V WHERE
  NVL (operating_unit, mo_global.get_current_org_id()) = mo_global.get_current_org_id()) ORG
  WHERE  WDJ.WIP_ENTITY_ID=WO.WIP_ENTITY_ID
  AND MLU.LOOKUP_TYPE(+)='AHL_JOB_STATUS' AND WO.STATUS_CODE=MLU.LOOKUP_CODE(+)
  AND WDJ.ORGANIZATION_ID = ORG.ORGANIZATION_ID
  AND WO.workorder_id = c_workorder_id;

  l_visit_task_id NUMBER;
  l_visit_id NUMBER;

  CURSOR get_inst_ue_dtls_task(c_visit_task_id IN NUMBER) IS
  SELECT
            UE.unit_effectivity_id,
            UE.object_version_number,
            NVL(VTS.instance_id, VST.item_instance_id),
            CSI.lot_number,
            CSI.serial_number,
            CSI.quantity
  FROM AHL_VISITS_B VST, AHL_VISIT_TASKS_B VTS, CSI_ITEM_INSTANCES CSI,
   AHL_UNIT_EFFECTIVITIES_B UE
  WHERE  VTS.unit_effectivity_id =  UE.unit_effectivity_id
  AND NVL(VTS.instance_id, VST.item_instance_id) = CSI.instance_id
  AND VST.visit_id = VTS.visit_id
  AND VTS.visit_task_id = c_visit_task_id;

  CURSOR get_inst_dtls_visit(c_visit_id IN NUMBER) IS
  SELECT nvl (VST.ITEM_INSTANCE_ID, VTSINST.instance_id ),
       CSI.lot_number,
       CSI.serial_number,
       CSI.quantity
  FROM AHL_VISITS_B VST,CSI_ITEM_INSTANCES CSI,
       (select instance_id from ahl_visit_tasks_b where visit_id = c_visit_id and instance_id IS NOT NULL AND rownum = 1) VTSINST
  WHERE nvl (VST.ITEM_INSTANCE_ID, VTSINST.instance_id )= CSI.INSTANCE_ID
  AND VST.visit_id = c_visit_id;

-- Cursor for getting auto_signoff_flag from mr header. Added for bug # 4078536
/*CURSOR get_signoff_flag_csr(c_workorder_id IN NUMBER) IS
SELECT
	MR.auto_signoff_flag
FROM
	AHL_MR_HEADERS_APP_V MR,
	AHL_VISIT_TASKS_B VT,
	AHL_WORKORDERS WO
WHERE 	MR.MR_HEADER_ID = VT.MR_ID AND
	WO.VISIT_TASK_ID = VT.visit_task_id AND
	WO.workorder_id = c_workorder_id;*/

--for fix of bug number 6467963
CURSOR get_signoff_flag_csr(c_visit_task_id IN NUMBER) IS
SELECT
	MR.auto_signoff_flag
FROM
	AHL_MR_HEADERS_APP_V MR,
	AHL_VISIT_TASKS_B VT
	--AHL_WORKORDERS WO
WHERE 	MR.MR_HEADER_ID = VT.MR_ID AND
	VT.visit_task_id = c_visit_task_id;

BEGIN

   /*SELECT    workorder_id,
												job_number,
            object_version_number,
            wip_entity_id,
            organization_id,
            plan_id,
            collection_id,
            actual_start_date,
            actual_end_date,
            job_status_code,
            job_status_meaning,
            route_id,
            unit_effectivity_id,
            ue_object_version_number,
            --auto_signoff_flag,
            --'Y',
            item_instance_id,
            completion_subinventory,
            completion_locator_id,
            lot_number,
            serial_number,
            quantity
  INTO      x_workorder_rec.workorder_id,
												x_workorder_rec.workorder_name,
            x_workorder_rec.object_version_number,
            x_workorder_rec.wip_entity_id,
            x_workorder_rec.organization_id,
            x_workorder_rec.plan_id,
            x_workorder_rec.collection_id,
            x_workorder_rec.actual_start_date,
            x_workorder_rec.actual_end_date,
            x_workorder_rec.status_code,
            x_workorder_rec.status,
            x_workorder_rec.route_id,
            x_workorder_rec.unit_effectivity_id,
            x_workorder_rec.ue_object_version_number,
            --x_workorder_rec.automatic_signoff_flag,
            x_workorder_rec.item_instance_id,
            x_workorder_rec.completion_subinventory,
            x_workorder_rec.completion_locator_id,
            x_workorder_rec.lot_number,
            x_workorder_rec.serial_number,
            x_workorder_rec.txn_quantity
  FROM      AHL_ALL_WORKORDERS_V
  WHERE     workorder_id = p_workorder_id;*/

  --for fix of bug number 6467963
  OPEN get_wo_dtls_csr(p_workorder_id);
  FETCH get_wo_dtls_csr INTO x_workorder_rec.workorder_id,
            x_workorder_rec.object_version_number,
            x_workorder_rec.wip_entity_id,
            x_workorder_rec.organization_id,
            x_workorder_rec.plan_id,
            x_workorder_rec.collection_id,
            x_workorder_rec.actual_start_date,
            x_workorder_rec.actual_end_date,
            x_workorder_rec.status_code,
            x_workorder_rec.status,
            x_workorder_rec.route_id,
            x_workorder_rec.completion_subinventory,
            x_workorder_rec.completion_locator_id,
            l_visit_id,
            l_visit_task_id;
  IF(get_wo_dtls_csr%NOTFOUND)THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
    FND_MSG_PUB.add;
    CLOSE get_wo_dtls_csr;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;
  CLOSE get_wo_dtls_csr;

  IF ( p_object_version_no IS NOT NULL AND
       p_object_version_no <> FND_API.G_MISS_NUM ) THEN
    IF ( x_workorder_rec.object_version_number <> p_object_version_no ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
      FND_MSG_PUB.add;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  -- Code for getting auto_signoff_flag from the child workorder if parent workorder doesnt have the information.
  -- Balaji added following code to get auto_signoff_flag from mr header intead of hardcoding it to 'Y'
  -- for bug # 4078536
  /*OPEN get_signoff_flag_csr(x_workorder_rec.workorder_id);
  FETCH get_signoff_flag_csr INTO x_workorder_rec.automatic_signoff_flag;
  x_workorder_rec.automatic_signoff_flag := nvl(x_workorder_rec.automatic_signoff_flag, 'N');
  CLOSE get_signoff_flag_csr;*/

  --for fix of bug number 6467963
    IF(l_visit_task_id IS NOT NULL)THEN
       OPEN get_inst_ue_dtls_task(l_visit_task_id);
       FETCH get_inst_ue_dtls_task INTO
              x_workorder_rec.unit_effectivity_id,
              x_workorder_rec.ue_object_version_number,
              x_workorder_rec.item_instance_id,
              x_workorder_rec.lot_number,
              x_workorder_rec.serial_number,
              x_workorder_rec.txn_quantity;
       CLOSE get_inst_ue_dtls_task;

       OPEN get_signoff_flag_csr(l_visit_task_id);
       FETCH get_signoff_flag_csr INTO x_workorder_rec.automatic_signoff_flag;
       x_workorder_rec.automatic_signoff_flag := nvl(x_workorder_rec.automatic_signoff_flag, 'N');
       CLOSE get_signoff_flag_csr;

    ELSE --visit master work order
       OPEN get_inst_dtls_visit(l_visit_id);
       FETCH get_inst_dtls_visit INTO
              x_workorder_rec.item_instance_id,
              x_workorder_rec.lot_number,
              x_workorder_rec.serial_number,
              x_workorder_rec.txn_quantity;
       CLOSE get_inst_dtls_visit;
       x_workorder_rec.automatic_signoff_flag := 'N';
  END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_NOT_FOUND' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;

END get_workorder_rec;

-- Function to validate the given Actual Start and End Dates
FUNCTION validate_actual_dates
(
  p_actual_start_date        IN DATE,
  p_actual_end_date          IN DATE
) RETURN VARCHAR2
IS
BEGIN

  IF ( p_actual_start_date IS NULL OR
       p_actual_end_date IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_ACTUAL_DTS_MISSING' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  IF ( p_actual_start_date > p_actual_end_date ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_ST_DT_END_DT' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  IF ( p_actual_end_date > SYSDATE ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_END_DT_SYSDATE' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;
END validate_actual_dates;

-- Function to validate the given Actual Start and End Dates do not overlap with any of the Open Accounting Period Start Date and Scheduled Close Date.
FUNCTION validate_acct_period
(
  p_organization_id          IN NUMBER,
  p_actual_start_date        IN DATE,
  p_actual_end_date          IN DATE
) RETURN VARCHAR2
IS
  l_period_start_date DATE;
  l_schedule_close_date DATE;

  CURSOR   get_min_period( c_organization_id NUMBER )
  IS
  SELECT   period_start_date
  FROM     ORG_ACCT_PERIODS
  WHERE    open_flag = 'Y'
  AND      organization_id = c_organization_id
  ORDER BY period_start_date;

  CURSOR   get_max_period( c_organization_id NUMBER )
  IS
  SELECT   schedule_close_date
  FROM     ORG_ACCT_PERIODS
  WHERE    open_flag = 'Y'
  AND      organization_id = c_organization_id
  ORDER BY schedule_close_date DESC;

BEGIN

  OPEN  get_min_period( p_organization_id );
  FETCH get_min_period
  INTO  l_period_start_date;

  IF ( get_min_period%NOTFOUND ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_NO_OPEN_ACCT_PERIOD' );
    FND_MSG_PUB.add;
    CLOSE get_min_period;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  IF ( l_period_start_date > p_actual_start_date ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_ST_DT_LESS_ACCT_PERIOD' );
    FND_MSG_PUB.add;
    CLOSE get_min_period;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  CLOSE get_min_period;

  OPEN  get_max_period( p_organization_id );
  FETCH get_max_period
  INTO  l_schedule_close_date;

  IF ( get_max_period%NOTFOUND ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_NO_OPEN_ACT_PERIOD' );
    FND_MSG_PUB.add;
    CLOSE get_max_period;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  IF ( l_schedule_close_date < p_actual_end_date ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_END_DT_LESS_ACT_PERIOD' );
    FND_MSG_PUB.add;
    CLOSE get_max_period;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  CLOSE get_max_period;

  RETURN FND_API.G_RET_STS_SUCCESS;
END validate_acct_period;

-- Function to get the user-enter value 'Operation Status' or 'Workorder Status' QA Plan Element and to check if this value is 'Complete'.
FUNCTION validate_qa_status
(
  p_plan_id                 IN   NUMBER,
  p_char_id                 IN   NUMBER,
  p_collection_id           IN   NUMBER
) RETURN VARCHAR2
IS

  l_result_column_name  VARCHAR2(30) := NULL;
  l_enabled_flag        NUMBER := NULL;
  l_displayed_flag      NUMBER := NULL;
  l_result_sql_stmt     VARCHAR2(200);
  l_result_column_value VARCHAR2(30) := NULL;

BEGIN

  BEGIN
    SELECT     result_column_name,
               enabled_flag,
               displayed_flag
    INTO       l_result_column_name,
               l_enabled_flag,
               l_displayed_flag
    FROM       QA_PLAN_CHARS
    WHERE      plan_id = p_plan_id
    AND        char_id = p_char_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN FND_API.G_RET_STS_SUCCESS;
    WHEN OTHERS THEN
      RETURN FND_API.G_RET_STS_UNEXP_ERROR;
  END;

  IF ( l_result_column_name IS NOT NULL AND
       l_enabled_flag = 1 AND
       l_displayed_flag = 1 ) THEN

    -- Get the user-entered value for the status element
    l_result_sql_stmt := 'SELECT ' || l_result_column_name || ' FROM QA_RESULTS_V WHERE collection_id = :c_collection_id AND occurrence = ( SELECT MAX( occurrence ) FROM QA_RESULTS WHERE collection_id = :c_collection_id )';

    BEGIN
      EXECUTE IMMEDIATE l_result_sql_stmt INTO l_result_column_value USING p_collection_id, p_collection_id;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN FND_API.G_RET_STS_UNEXP_ERROR;
    END;

    -- Operation status
    IF ( p_char_id = 125 AND
         ( l_result_column_value IS NULL OR
           l_result_column_value <> G_OP_STATUS_COMPLETE ) ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_QA_STAT_NOT_COMPL' );
      FND_MSG_PUB.add;
      RETURN FND_API.G_RET_STS_ERROR;

    -- Workorder status
    ELSIF ( p_char_id = 98 AND
            ( l_result_column_value IS NULL OR
              l_result_column_value <> G_JOB_STATUS_COMPLETE ) ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_QA_STAT_NOT_COMPL' );
      FND_MSG_PUB.add;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;
END validate_qa_status;

-- Function to validate whether the actual end date is later than the
-- last workorder transaction date.
FUNCTION validate_ahl_wo_txn_date
(
  p_workorder_id            IN   NUMBER,
  p_actual_end_date         IN   DATE
) RETURN VARCHAR2
IS
  l_transaction_date DATE;

  CURSOR get_ahl_txn_rec( c_workorder_id NUMBER )
  IS
  SELECT MAX ( TXN.creation_date )
  FROM   AHL_WORKORDER_MTL_TXNS TXN, AHL_WORKORDER_OPERATIONS OP
  WHERE  TXN.workorder_operation_id = OP.workorder_operation_id
  AND    OP.workorder_id = c_workorder_id;
BEGIN

  OPEN   get_ahl_txn_rec( p_workorder_id );

  FETCH  get_ahl_txn_rec
  INTO   l_transaction_date;

  IF ( get_ahl_txn_rec%FOUND ) THEN
    -- Ensure that the Actual End date is greater than the last Transaction Date
    IF ( l_transaction_date > p_actual_end_date ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_ENDDT_TXNDT' );
      FND_MSG_PUB.add;
      CLOSE get_ahl_txn_rec;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  CLOSE get_ahl_txn_rec;

  RETURN FND_API.G_RET_STS_SUCCESS;
END validate_ahl_wo_txn_date;

-- Function to check whether the last EAM Workorder Transaction is Completion
-- and to ensure that the actual end date is greater than the
-- last transaction date in EAM.
FUNCTION validate_eam_wo_compl_txn
(
  p_wip_entity_id           IN   NUMBER,
  p_actual_end_date         IN   DATE,
  p_validate_date           IN   VARCHAR2 DEFAULT FND_API.G_TRUE
) RETURN VARCHAR2
IS

  l_transaction_type NUMBER;
  l_transaction_date DATE;

  CURSOR       get_eam_txn_rec( c_wip_entity_id NUMBER )
  IS
  SELECT       transaction_type,
               transaction_date
  FROM         EAM_JOB_COMPLETION_TXNS
  WHERE        wip_entity_id = p_wip_entity_id
  ORDER BY     transaction_date DESC;

BEGIN

  OPEN   get_eam_txn_rec( p_wip_entity_id );

  FETCH  get_eam_txn_rec
  INTO   l_transaction_type,
         l_transaction_date;

  IF ( get_eam_txn_rec%FOUND ) THEN

    -- Ensure that the Transaction Type is not COMPLETE.
    IF ( l_transaction_type = 1 ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_COMP_IN_EAM' );
      FND_MSG_PUB.add;
      CLOSE get_eam_txn_rec;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;

  IF (NVL(p_validate_date, FND_API.G_TRUE) = FND_API.G_TRUE) THEN
    IF ( l_transaction_date > p_actual_end_date ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_ENDDT_EAM_TXNDT' );
      FND_MSG_PUB.add;
      CLOSE get_eam_txn_rec;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;
  END IF;

  CLOSE get_eam_txn_rec;

  RETURN FND_API.G_RET_STS_SUCCESS;
END validate_eam_wo_compl_txn;

-- Function to record the Readings of all the Counters associated to the Item Instance associated to the Workorder.
FUNCTION record_wo_ctr_readings
(
  x_msg_data           OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  p_wip_entity_id      IN  NUMBER,
  p_counter_tbl        IN  counter_tbl_type
) RETURN VARCHAR2
IS

  l_return_status           VARCHAR2(1);
  l_msg_data                VARCHAR2(2000);
  l_msg_count               NUMBER;
  l_results_tbl             AHL_QA_RESULTS_PVT.qa_results_tbl_type;
  l_hidden_results_tbl      AHL_QA_RESULTS_PVT.qa_results_tbl_type;
  l_context_tbl             AHL_QA_RESULTS_PVT.qa_context_tbl_type;
  l_organization_id         NUMBER := NULL;
  l_collection_id           NUMBER := NULL;
  l_result_count            NUMBER := 1;
  l_occurrence_count        NUMBER := 1;
  l_occurrence_tbl          AHL_QA_RESULTS_PVT.occurrence_tbl_type;

BEGIN

  FOR i IN p_counter_tbl.FIRST..p_counter_tbl.LAST LOOP
    IF ( p_counter_tbl(i).counter_value_id IS NOT NULL ) THEN
      l_occurrence_tbl( l_occurrence_count ).element_count := 3;
      l_occurrence_count := l_occurrence_count + 1;

      -- Workorder
      l_results_tbl( l_result_count ).char_id := 165;
      l_results_tbl( l_result_count ).result_id := p_wip_entity_id;
      l_result_count := l_result_count + 1;

      -- Counter
      l_results_tbl( l_result_count ).char_id := 54;
      l_results_tbl( l_result_count ).result_id := p_counter_tbl(i).counter_id;
      l_result_count := l_result_count + 1;

      -- Counter Reading
      l_results_tbl( l_result_count ).char_id := 55;
      l_results_tbl( l_result_count ).result_id := p_counter_tbl(i).counter_value_id;
      l_result_count := l_result_count + 1;
    END IF;

  END LOOP;

  IF ( l_occurrence_count = 1 ) THEN
    RETURN FND_API.G_RET_STS_SUCCESS;
  END IF;

  -- Get the Organization ID of the Counter Reading Plan
  SELECT organization_id
  INTO   l_organization_id
  FROM   QA_PLANS
  WHERE  plan_id = G_CTR_READING_PLAN_ID;

  -- Post the Results for the Counter Reading Plan in Oracle Quality
  -- Note :- The p_commit flag is TRUE because, actions have to fired for
  -- the Counter Reading Plan
  AHL_QA_RESULTS_PVT.submit_qa_results
  (
    p_api_version        => 1.0,
    p_init_msg_list      => FND_API.G_TRUE,
    p_commit             => FND_API.G_TRUE,
    p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
    p_default            => FND_API.G_FALSE,
    p_module_type        => NULL,
    x_return_status      => l_return_status,
    x_msg_count          => l_msg_count,
    x_msg_data           => l_msg_data,
    p_plan_id            => G_CTR_READING_PLAN_ID,
    p_organization_id    => l_organization_id,
    p_transaction_no     => NULL,
    p_specification_id   => NULL,
    p_results_tbl        => l_results_tbl,
    p_hidden_results_tbl => l_hidden_results_tbl,
    p_context_tbl        => l_context_tbl,
    p_result_commit_flag => 1,
    p_id_or_value        => 'ID',
    p_x_collection_id    => l_collection_id,
    p_x_occurrence_tbl   => l_occurrence_tbl
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    x_msg_data := l_msg_data;
    x_msg_count := l_msg_count;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;

END record_wo_ctr_readings;

-- Function to complete the given Workorder in WIP using EAM API
FUNCTION complete_eam_workorder
(
  p_workorder_rec          IN   workorder_rec_type
) RETURN VARCHAR2
IS

l_inventory_item_info EAM_WorkOrderTransactions_PUB.Inventory_Item_Tbl_Type;
l_attribute_rec       EAM_WorkOrderTransactions_PUB.Attributes_Rec_Type;

l_msg_count           NUMBER;
l_return_status       VARCHAR2(1);
l_msg_data            VARCHAR2(2000);
l_app_name            VARCHAR2(30);
l_msg_name            VARCHAR2(30);

BEGIN

  -- Completion Sub-inventory
  -- Note :- We may want to add more validations here to ensure that
  -- the installed base transaction does not fail.
  IF ( p_workorder_rec.completion_subinventory IS NOT NULL ) THEN
    l_inventory_item_info(1).subinventory := p_workorder_rec.completion_subinventory;
    l_inventory_item_info(1).locator := p_workorder_rec.completion_locator_id;
    l_inventory_item_info(1).lot_number := p_workorder_rec.lot_number;
    l_inventory_item_info(1).serial_number := p_workorder_rec.serial_number;
    l_inventory_item_info(1).quantity := p_workorder_rec.txn_quantity;
  END IF;

  -- Invoke the EAM API. Do not Commit.
  EAM_WORKORDERTRANSACTIONS_PUB.complete_work_order
  (
    p_api_version             => 1.0,
    p_init_msg_list           => FND_API.G_TRUE,
    p_commit                  => FND_API.G_FALSE,
    x_return_status           => l_return_status,
    x_msg_count               => l_msg_count,
    x_msg_data                => l_msg_data,
    p_wip_entity_id           => p_workorder_rec.wip_entity_id,
    p_transaction_type        => 1,
    p_transaction_date        => SYSDATE,
    p_instance_id             => p_workorder_rec.item_instance_id,
    p_user_id                 => FND_GLOBAL.user_id,
    p_request_id              => NULL,
    p_application_id          => NULL,
    p_program_id              => NULL,
    p_reconciliation_code     => NULL,
    p_actual_start_date       => p_workorder_rec.actual_start_date,
    p_actual_end_date         => p_workorder_rec.actual_end_date,
    p_actual_duration         => NULL,
    p_shutdown_start_date     => NULL,
    p_shutdown_end_date       => NULL,
    p_shutdown_duration       => NULL,
    p_inventory_item_info     => l_inventory_item_info,
    p_reference               => NULL,
    p_reason                  => NULL,
    p_attributes_rec          => l_attribute_rec
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN

    IF ( l_msg_data IS NULL ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_EAM_WO_CMPL_ERROR' );
      FND_MSG_PUB.add;
    ELSE
      -- Parse the Encoded message returned by the EAM API
      FND_MESSAGE.parse_encoded( l_msg_data, l_app_name, l_msg_name );
      FND_MESSAGE.set_name( l_app_name, l_msg_name );
      FND_MSG_PUB.add;
    END IF;

    RETURN FND_API.G_RET_STS_ERROR;

  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_EAM_WO_CMPL_ERROR' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;

END complete_eam_workorder;

-- Function to record a Workorder Transaction ASO Entities
FUNCTION record_ahl_workorder_txn
(
  p_workorder_rec          IN   workorder_rec_type,
  p_transaction_type_code  IN   NUMBER
) RETURN VARCHAR2
IS
  l_workorder_txn_id  NUMBER;
BEGIN

  SELECT AHL_WORKORDER_TXNS_S.NEXTVAL
  INTO   l_workorder_txn_id
  FROM   DUAL;

  INSERT INTO AHL_WORKORDER_TXNS
  (
   WORKORDER_TXN_ID,
   OBJECT_VERSION_NUMBER,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_LOGIN,
   WORKORDER_ID,
   TRANSACTION_TYPE_CODE,
   STATUS_CODE,
   SCHEDULED_START_DATE,
   SCHEDULED_END_DATE,
   ACTUAL_START_DATE,
   ACTUAL_END_DATE,
   LOT_NUMBER,
   COMPLETION_SUBINVENTORY,
   COMPLETION_LOCATOR_ID
  ) VALUES (
   l_workorder_txn_id,
   1,
   SYSDATE,
   FND_GLOBAL.user_id,
   SYSDATE,
   FND_GLOBAL.user_id,
   FND_GLOBAL.login_id,
   p_workorder_rec.workorder_id,
   p_transaction_type_code,
   p_workorder_rec.status_code,
   p_workorder_rec.actual_start_date,
   p_workorder_rec.actual_end_date,
   p_workorder_rec.actual_start_date,
   p_workorder_rec.actual_end_date,
   p_workorder_rec.lot_number,
   p_workorder_rec.completion_subinventory,
   p_workorder_rec.completion_locator_id
  );

  RETURN FND_API.G_RET_STS_SUCCESS;

END record_ahl_workorder_txn;

-- Function to complete / defer the given Workorder in ASO Entities
FUNCTION update_ahl_workorder
(
  p_workorder_rec          IN   workorder_rec_type,
  p_status_code            IN   VARCHAR2
) RETURN VARCHAR2
IS
  l_transaction_type_code  NUMBER := 1;
  l_return_status          VARCHAR2(1);
BEGIN

  UPDATE   AHL_WORKORDERS
  SET      status_code = p_status_code,
           object_version_number = object_version_number + 1,
           last_update_date = SYSDATE,
           last_updated_by = FND_GLOBAL.user_id,
           last_update_login = FND_GLOBAL.login_id
  WHERE    workorder_id = p_workorder_rec.workorder_id
  AND      object_version_number = p_workorder_rec.object_version_number;

  IF ( SQL%ROWCOUNT = 0 ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_NOT_FOUND' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  -- Set the Transaction Type
  -- CHECK THIS
  l_transaction_type_code := TO_NUMBER( p_status_code );

/*
  IF ( p_status_code = '4' ) THEN
    l_transaction_type_code := TO_NUMBER( p_status_code );
  ELSE
    l_transaction_type_code := 2;
  END IF;
*/

  -- Insert a record in AHL_WORKORDER_TXNS for the Completion / Deferral Transaction.
  l_return_status :=
  record_ahl_workorder_txn
  (
    p_workorder_rec         => p_workorder_rec,
    p_transaction_type_code => l_transaction_type_code
  );

  RETURN FND_API.G_RET_STS_SUCCESS;

END update_ahl_workorder;

-- Function for Validating Complete Operation Inputs
FUNCTION validate_cop_inputs
(
  p_workorder_operation_id   IN   NUMBER,
  p_object_version_no        IN   NUMBER
) RETURN VARCHAR2
IS
BEGIN

  IF ( p_workorder_operation_id IS NULL OR
       p_workorder_operation_id = FND_API.G_MISS_NUM OR
       p_object_version_no IS NULL OR
       p_object_version_no = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_INVALID_COP_INPUTS' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;
END validate_cop_inputs;

-- Function to validate whether the Actual End Date is later than the last Transaction date for the Workorder Operation.
FUNCTION validate_ahl_op_txn_date
(
  p_workorder_operation_id  IN   NUMBER,
  p_actual_end_date         IN   DATE
) RETURN VARCHAR2
IS
  l_transaction_date DATE;

  CURSOR get_ahl_txn_rec( c_workorder_operation_id NUMBER )
  IS
  SELECT MAX ( creation_date )
  FROM   AHL_WORKORDER_MTL_TXNS
  WHERE  workorder_operation_id = c_workorder_operation_id;
BEGIN

  OPEN   get_ahl_txn_rec( p_workorder_operation_id );

  FETCH  get_ahl_txn_rec
  INTO   l_transaction_date;

  IF ( get_ahl_txn_rec%FOUND ) THEN

    -- Ensure that the Actual End date is greater than the last Transaction Date
    IF ( l_transaction_date > p_actual_end_date ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_OP_ENDDT_TXNDT' );
      FND_MSG_PUB.add;
      CLOSE get_ahl_txn_rec;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  CLOSE get_ahl_txn_rec;

  RETURN FND_API.G_RET_STS_SUCCESS;
END validate_ahl_op_txn_date;

-- Function to check whether the last EAM Workorder Transaction is Completion
-- and to ensure that the actual end date is greater than the
-- last transaction date in EAM.
FUNCTION validate_eam_op_compl_txn
(
  p_wip_entity_id                 IN   NUMBER,
  p_operation_sequence_num        IN   NUMBER,
  p_actual_end_date               IN   DATE,
  p_validate_date                 IN   VARCHAR2 DEFAULT FND_API.G_TRUE
) RETURN VARCHAR2
IS

  l_transaction_type NUMBER;
  l_transaction_date DATE;

  CURSOR       get_eam_txn_rec( c_wip_entity_id NUMBER, c_op_seq_num NUMBER )
  IS
  SELECT       transaction_type,
               transaction_date
  FROM         EAM_OP_COMPLETION_TXNS
  WHERE        wip_entity_id = p_wip_entity_id
  AND          operation_seq_num = p_operation_sequence_num
  ORDER BY     transaction_date DESC;

BEGIN

  OPEN   get_eam_txn_rec( p_wip_entity_id, p_operation_sequence_num );

  FETCH  get_eam_txn_rec
  INTO   l_transaction_type,
         l_transaction_date;

  IF ( get_eam_txn_rec%FOUND ) THEN

    -- Ensure that the Transaction Type is not COMPLETE.
    IF ( l_transaction_type = 1 ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_OP_COMP_IN_EAM' );
      FND_MSG_PUB.add;
      CLOSE get_eam_txn_rec;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;

    IF (NVL(p_validate_date, FND_API.G_TRUE) = FND_API.G_TRUE) THEN
    IF ( l_transaction_date > p_actual_end_date ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_OP_ENDDT_EAM_TXNDT' );
      FND_MSG_PUB.add;
      CLOSE get_eam_txn_rec;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;
    END IF;
  END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;
END validate_eam_op_compl_txn;

-- Function to validate the given Operation.
FUNCTION validate_cop_rec
(
  p_operation_rec             IN   operation_rec_type,
  p_workorder_rec             IN   workorder_rec_type,
  p_validate_date             IN   VARCHAR2 DEFAULT FND_API.G_TRUE,
  p_check_unit                IN   VARCHAR2 DEFAULT FND_API.G_TRUE
) RETURN VARCHAR2
IS
  l_return_status VARCHAR2(1);
  l_wip_status    BOOLEAN;
  l_op_status_meaning  VARCHAR2(80);
  l_job_status_meaning  VARCHAR2(80);

BEGIN

  IF ( p_operation_rec.description IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_OP_DESC_NULL' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

		-- rroy
		-- ACL Changes
		IF p_check_unit = FND_API.G_TRUE THEN
		l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_operation_rec.workorder_id, NULL, NULL, NULL);
		IF l_return_status = FND_API.G_TRUE THEN
				FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_OP_COMP_UNTLCKD');
				--FND_MESSAGE.Set_Token('WO_NAME', p_workorder_rec.workorder_name);
				FND_MSG_PUB.ADD;
				RETURN FND_API.G_RET_STS_ERROR;
		END IF;
		END IF;
		-- rroy
		-- ACL Changes

  IF ( G_DEBUG = 'Y' ) THEN
	AHL_DEBUG_PUB.debug( 'before validating actual dates for wo_op_id->'||p_operation_rec.workorder_operation_id);
	AHL_DEBUG_PUB.debug( 'p_operation_rec.actual_start_date->'||TO_CHAR(p_operation_rec.actual_start_date,'DD-MON-YYYY HH24:MI:SS'));
	AHL_DEBUG_PUB.debug( 'p_operation_rec.actual_end_date->'||TO_CHAR(p_operation_rec.actual_end_date,'DD-MON-YYYY HH24:MI:SS'));
  END IF;

  IF (NVL(p_validate_date, FND_API.G_TRUE) = FND_API.G_TRUE) THEN
    l_return_status :=
    validate_actual_dates
    (
      p_actual_start_date          => p_operation_rec.actual_start_date,
      p_actual_end_date            => p_operation_rec.actual_end_date
    );
  END IF;

  IF ( p_operation_rec.status_code <> G_OP_STATUS_UNCOMPLETE ) THEN
    -- Modified by srini to show status meaning
				-- replacing with call to get_status function
				-- so no exceptions are thrown if the
				-- lookup does not exist
				l_op_status_meaning := get_status(p_operation_rec.status_code,
   							          'AHL_OPERATION_STATUS');


	  /*SELECT MEANING INTO l_op_status_meaning
      FROM fnd_lookup_values_vl
     WHERE lookup_type = 'AHL_OPERATION_STATUS'
	   AND lookup_code = p_operation_rec.status_code;
				*/
    --
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_INVALID_OP_STATUS' );
    FND_MESSAGE.set_token( 'STATUS', l_op_status_meaning );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

		IF (NVL(p_validate_date, FND_API.G_TRUE) = FND_API.G_TRUE) THEN
  IF ( p_operation_rec.actual_start_date < p_workorder_rec.actual_start_date ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_OP_WO_ST_DT' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  IF ( p_operation_rec.actual_end_date > p_workorder_rec.actual_end_date ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_OP_WO_END_DT' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;
		END IF;

  IF ( p_workorder_rec.status_code = G_JOB_STATUS_UNRELEASED OR -- fix for bug# 7555681
       p_workorder_rec.status_code = G_JOB_STATUS_COMPLETE OR
       p_workorder_rec.status_code = G_JOB_STATUS_COMPLETE_NC OR
       p_workorder_rec.status_code = G_JOB_STATUS_CANCELLED OR
       p_workorder_rec.status_code = G_JOB_STATUS_CLOSED ) THEN
    -- Modified by srini to show status meaning
				-- replacing with call to get_status function
				-- so no exceptions are thrown if the
				-- lookup does not exist
				l_job_status_meaning := get_status(p_workorder_rec.status_code,
								'AHL_JOB_STATUS');

	/*SELECT MEANING INTO l_job_status_meaning
      FROM fnd_lookup_values_vl
     WHERE lookup_type = 'AHL_JOB_STATUS'
	   AND lookup_code = p_workorder_rec.status_code;
				*/

    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_INVALID_OP_WO_STATUS' );
    FND_MESSAGE.set_token( 'STATUS', l_job_status_meaning );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  /*
  -- Adithya removed below validation for bug # 6326071.
  -- Accounting periods are validated against transaction date
  -- in EAM. To be inline with EAM validations the check of accouting
  -- period against actual start date and end date is removed.
  IF (NVL(p_validate_date, FND_API.G_TRUE) = FND_API.G_TRUE) THEN
  l_return_status :=
  validate_acct_period
  (
    p_organization_id            => p_operation_rec.organization_id,
    p_actual_start_date          => p_operation_rec.actual_start_date,
    p_actual_end_date            => p_operation_rec.actual_end_date
  );
  END IF;
  */

  IF ( p_operation_rec.plan_id IS NOT NULL AND
       p_operation_rec.collection_id IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_OP_NO_QA_RESULTS' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  IF ( p_operation_rec.plan_id IS NOT NULL ) THEN

    l_return_status :=
    validate_qa_status
    (
      p_plan_id                 => p_operation_rec.plan_id,
      p_char_id                 => 125, -- Operation Status Plan Element
      p_collection_id           => p_operation_rec.collection_id
    );
  END IF;

/*
  l_return_status :=
  validate_ahl_op_txn_date
  (
    p_workorder_operation_id    => p_operation_rec.workorder_operation_id,
    p_actual_end_date           => p_operation_rec.actual_end_date
  );
*/

  l_return_status :=
  validate_eam_op_compl_txn
  (
    p_wip_entity_id             => p_operation_rec.wip_entity_id,
    p_operation_sequence_num    => p_operation_rec.operation_sequence_num,
    p_actual_end_date           => p_operation_rec.actual_end_date,
    p_validate_date             => p_validate_date
  );

  RETURN FND_API.G_RET_STS_SUCCESS;

END validate_cop_rec;

FUNCTION complete_eam_wo_operation
(
  p_operation_rec          IN   operation_rec_type
) RETURN VARCHAR2
IS

l_attribute_rec       EAM_WorkOrderTransactions_PUB.Attributes_Rec_Type;

l_msg_count           NUMBER;
l_return_status       VARCHAR2(1);
l_msg_data            VARCHAR2(2000);
l_app_name            VARCHAR2(30);
l_msg_name            VARCHAR2(30);

BEGIN
  EAM_WorkOrderTransactions_PUB.complete_operation
  (
    p_api_version                  => 1.0,
    p_init_msg_list                => FND_API.G_TRUE,
    p_commit                       => FND_API.G_FALSE,
    x_return_status                => l_return_status,
    x_msg_count                    => l_msg_count,
    x_msg_data                     => l_msg_data,
    p_wip_entity_id                => p_operation_rec.wip_entity_id,
    p_operation_seq_num            => p_operation_rec.operation_sequence_num,
    p_transaction_date             => SYSDATE,
    p_transaction_type             => 1,
    p_actual_start_date            => p_operation_rec.actual_start_date,
    p_actual_end_date              => p_operation_rec.actual_end_date,
    p_actual_duration              => NULL,
    p_shutdown_start_date          => NULL,
    p_shutdown_end_date            => NULL,
    p_shutdown_duration            => NULL,
    p_reconciliation_code          => NULL,
    p_attribute_rec                => l_attribute_rec
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    IF ( l_msg_data IS NOT NULL ) THEN
      FND_MESSAGE.parse_encoded( l_msg_data, l_app_name, l_msg_name );
      FND_MESSAGE.set_name( l_app_name, l_msg_name );
      FND_MSG_PUB.add;
    END IF;
    RETURN FND_API.G_RET_STS_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_EAM_WO_OP_CMPL_ERROR' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;
END complete_eam_wo_operation;

-- Function to record a Workorder Operation Completion Transaction ASO Entities
FUNCTION record_ahl_wo_operation_txn
(
  p_operation_rec                IN   operation_rec_type
) RETURN VARCHAR2
IS
  l_wo_operation_txn_id      NUMBER;
  l_transaction_type_code    NUMBER := 1;
  l_load_type_code           NUMBER := 1;
BEGIN

  SELECT AHL_WO_OPERATIONS_TXNS_S.NEXTVAL
  INTO   l_wo_operation_txn_id
  FROM   DUAL;

  INSERT INTO AHL_WO_OPERATIONS_TXNS
  (
   WO_OPERATION_TXN_ID,
   OBJECT_VERSION_NUMBER,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_LOGIN,
   TRANSACTION_TYPE_CODE,
   LOAD_TYPE_CODE,
   WORKORDER_OPERATION_ID,
   OP_ACTUAL_START_DATE,
   OP_ACTUAL_END_DATE
  ) VALUES (
   l_wo_operation_txn_id,
   1,
   SYSDATE,
   FND_GLOBAL.user_id,
   SYSDATE,
   FND_GLOBAL.user_id,
   FND_GLOBAL.login_id,
   p_operation_rec.workorder_operation_id,
   l_transaction_type_code,
   l_load_type_code,
   p_operation_rec.actual_start_date,
   p_operation_rec.actual_end_date
  );

  RETURN FND_API.G_RET_STS_SUCCESS;
END record_ahl_wo_operation_txn;

--Function to complete the given Operation in ASO Entities
FUNCTION complete_ahl_wo_operation
(
  p_operation_rec                IN   operation_rec_type
) RETURN VARCHAR2
IS
  l_return_status  VARCHAR2(1);
BEGIN

  UPDATE   AHL_WORKORDER_OPERATIONS
  SET      status_code = G_OP_STATUS_COMPLETE,
           object_version_number = object_version_number + 1,
           last_update_date = SYSDATE,
           last_updated_by = FND_GLOBAL.user_id,
           last_update_login = FND_GLOBAL.login_id
  WHERE    workorder_operation_id = p_operation_rec.workorder_operation_id
  AND      object_version_number = p_operation_rec.object_version_number;

  IF ( SQL%ROWCOUNT = 0 ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_OP_NOT_FOUND' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  -- Insert a record in AHL_WO_OPERATION_TXNS for the Completion Transaction.
  l_return_status :=
  record_ahl_wo_operation_txn
  (
    p_operation_rec         => p_operation_rec
  );

  RETURN FND_API.G_RET_STS_SUCCESS;

END complete_ahl_wo_operation;

-- Function to get all the operations for the given Workorder.
FUNCTION get_workorder_operations
(
  p_workorder_id           IN          NUMBER,
  p_object_version_no      IN          NUMBER := NULL,
  x_operation_tbl          OUT NOCOPY operation_tbl_type
) RETURN VARCHAR2
IS
  l_count NUMBER := 1;

  CURSOR get_operations ( c_workorder_id NUMBER )
  IS
  SELECT workorder_operation_id,
         actual_start_date,
         actual_end_date,
         status_code,
         status
  FROM   AHL_WORKORDER_OPERATIONS_V
  WHERE  workorder_id = c_workorder_id;

BEGIN

  FOR op_cursor IN get_operations( p_workorder_id ) LOOP
    x_operation_tbl( l_count ).workorder_operation_id := op_cursor.workorder_operation_id;
    x_operation_tbl( l_count ).actual_start_date := op_cursor.actual_start_date;
    x_operation_tbl( l_count ).actual_end_date := op_cursor.actual_end_date;
    x_operation_tbl( l_count ).status_code := op_cursor.status_code;
    x_operation_tbl( l_count ).status := op_cursor.status;

    l_count := l_count + 1;
  END LOOP;

/*
  IF ( x_operation_tbl.COUNT = 0 ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_NO_WO_OPERATIONS' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;
*/

  RETURN FND_API.G_RET_STS_SUCCESS;
END get_workorder_operations;

-- Function for common record validations for Completion and Deferral.
FUNCTION validate_cwo_dwo_rec
(
  p_workorder_rec    IN  workorder_rec_type,
  p_validate_date    IN  VARCHAR2 DEFAULT FND_API.G_TRUE
) RETURN VARCHAR2
IS
  l_return_status VARCHAR2(1);
  l_wip_status BOOLEAN;
BEGIN

IF (NVL(p_validate_date, FND_API.G_TRUE) = FND_API.G_TRUE) THEN
  l_return_status :=
  validate_actual_dates
  (
    p_actual_start_date          => p_workorder_rec.actual_start_date,
    p_actual_end_date            => p_workorder_rec.actual_end_date
  );

  /*
  -- Adithya  removed below validation for bug # 6326071.
  -- Accounting periods are validated against transaction date
  -- in EAM. To be inline with EAM validations the check of accouting
  -- period against actual start date and end date is removed.
  l_return_status :=
  validate_acct_period
  (
    p_organization_id            => p_workorder_rec.organization_id,
    p_actual_start_date          => p_workorder_rec.actual_start_date,
    p_actual_end_date            => p_workorder_rec.actual_end_date
  );
  */
END IF;

		-- moved the below check from this function
		-- since this is not required for deferral
		-- the validation is now being done in
		-- validate_cwo_rec for completion only
		-- bug no 3942950

  /*IF ( p_workorder_rec.plan_id IS NOT NULL AND
       p_workorder_rec.collection_id IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_NO_QA_RESULTS' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;
*/
/*
  l_return_status :=
  validate_ahl_wo_txn_date
  (
    p_workorder_id              => p_workorder_rec.workorder_id,
    p_actual_end_date           => p_workorder_rec.actual_end_date
  );
*/

  l_return_status :=
  validate_eam_wo_compl_txn
  (
    p_wip_entity_id             => p_workorder_rec.wip_entity_id,
    p_actual_end_date           => p_workorder_rec.actual_end_date,
    p_validate_date             => p_validate_date
  );

  RETURN FND_API.G_RET_STS_SUCCESS;
END validate_cwo_dwo_rec;

FUNCTION validate_cwo_rec
(
  p_workorder_rec    IN  workorder_rec_type,
  p_operation_tbl    IN  operation_tbl_type,
  p_validate_date    IN  VARCHAR2 DEFAULT FND_API.G_TRUE,
  p_check_unit       IN  VARCHAR2 DEFAULT FND_API.G_TRUE
) RETURN VARCHAR2
IS

l_return_status VARCHAR2(1);
l_wip_status BOOLEAN;

CURSOR  get_completion_dependencies( c_child_wip_entity_id NUMBER )
IS
SELECT  WO.workorder_name,
        WO.status_code
FROM    AHL_WORKORDERS WO,
        WIP_SCHED_RELATIONSHIPS WOR
WHERE   WO.wip_entity_id = WOR.parent_object_id
AND     WO.master_workorder_flag = 'N'
AND     WO.status_code <> G_JOB_STATUS_DELETED
AND     WOR.parent_object_type_id = 1
AND     WOR.relationship_type = 2
AND     WOR.child_object_type_id = 1
AND     WOR.child_object_id = c_child_wip_entity_id;

l_job_status_meaning VARCHAR2(80);

BEGIN

		-- rroy
		-- ACL Changes
		IF p_check_unit = FND_API.G_TRUE THEN
		l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_rec.workorder_id, NULL, NULL, NULL);
		IF l_return_status = FND_API.G_TRUE THEN
				FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_WO_COMP_UNTLCKD');
				FND_MESSAGE.Set_Token('WO_NAME', p_workorder_rec.workorder_name);
				FND_MSG_PUB.ADD;
				RETURN FND_API.G_RET_STS_ERROR;
		END IF;
		END IF;
		-- rroy
		-- ACL Changes

  l_return_status :=
  validate_cwo_dwo_rec
  (
    p_workorder_rec    => p_workorder_rec,
    p_validate_date    => p_validate_date
  );
  -- Moved the below validation from
		-- validate_cwo_dwo_rec to this function because
		-- this validation is not required for deferral
		-- bug no 3942950
		IF ( p_workorder_rec.plan_id IS NOT NULL AND
       p_workorder_rec.collection_id IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_NO_QA_RESULTS' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;


  IF ( p_workorder_rec.status_code <> G_JOB_STATUS_RELEASED AND
       p_workorder_rec.status_code <> G_JOB_STATUS_QA_PENDING ) THEN
    -- Modified by srini to show status meaning
				-- replacing with call to get_status function
				-- so no exceptions are thrown if the
				-- lookup does not exist
				l_job_status_meaning := get_status(p_workorder_rec.status_code,
															'AHL_JOB_STATUS');

	/*SELECT MEANING INTO l_job_status_meaning
      FROM fnd_lookup_values_vl
     WHERE lookup_type = 'AHL_JOB_STATUS'
	   AND lookup_code = p_workorder_rec.status_code;
*/
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_INVALID_WO_STATUS' );
    FND_MESSAGE.set_token( 'STATUS', l_job_status_meaning );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  IF ( p_operation_tbl.COUNT > 0 ) THEN
    FOR i IN 1..p_operation_tbl.COUNT LOOP
    IF (NVL(p_validate_date, FND_API.G_TRUE) = FND_API.G_TRUE) THEN
      IF ( p_workorder_rec.actual_start_date > p_operation_tbl(i).actual_start_date ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_OP_ST_DT' );
        FND_MSG_PUB.add;
        RETURN FND_API.G_RET_STS_ERROR;
      END IF;

      IF ( p_workorder_rec.actual_end_date < p_operation_tbl(i).actual_end_date ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_OP_END_DT' );
        FND_MSG_PUB.add;
        RETURN FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

      IF ( p_operation_tbl(i).status_code <> G_OP_STATUS_COMPLETE ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_INVALID_WO_OP_STATUS' );
        FND_MSG_PUB.add;
        RETURN FND_API.G_RET_STS_ERROR;
      END IF;

    END LOOP;
  END IF;

  IF ( p_workorder_rec.plan_id IS NOT NULL ) THEN

    l_return_status :=
    validate_qa_status
    (
      p_plan_id                 => p_workorder_rec.plan_id,
      p_char_id                 => 98, -- Workorder Status Plan Element
      p_collection_id           => p_workorder_rec.collection_id
    );
  END IF;

  FOR parent_csr IN get_completion_dependencies( p_workorder_rec.wip_entity_id ) LOOP
    IF ( parent_csr.status_code <> G_JOB_STATUS_COMPLETE AND
         parent_csr.status_code <> G_JOB_STATUS_COMPLETE_NC AND
         parent_csr.status_code <> G_JOB_STATUS_CLOSED AND
         parent_csr.status_code <> G_JOB_STATUS_CANCELLED ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_PRIOR_WO_NOT_COMPLETE' );
      FND_MESSAGE.set_token( 'WO_NAME', parent_csr.workorder_name );
      FND_MSG_PUB.add;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;
  END LOOP;

  RETURN FND_API.G_RET_STS_SUCCESS;
END validate_cwo_rec;

FUNCTION validate_dwo_rec
(
  p_workorder_rec    IN  workorder_rec_type
) RETURN VARCHAR2
IS
  l_return_status VARCHAR2(1);
  l_wip_status BOOLEAN;
  l_job_status_meaning VARCHAR2(80);
BEGIN


		--rroy
		-- ACL Changes
		l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_rec.workorder_id, NULL, NULL, NULL);
		IF l_return_status = FND_API.G_TRUE THEN
				FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_WO_DEFF_UNTLCKD');
				FND_MSG_PUB.ADD;
				RETURN FND_API.G_RET_STS_ERROR;
		END IF;
		--rroy
		-- ACL Changes

  l_return_status :=
  validate_cwo_dwo_rec
  (
    p_workorder_rec    => p_workorder_rec
  );

  IF ( p_workorder_rec.status_code <> G_JOB_STATUS_RELEASED AND
       p_workorder_rec.status_code <> G_JOB_STATUS_ON_HOLD AND
       p_workorder_rec.status_code <> G_JOB_STATUS_PARTS_HOLD AND
       p_workorder_rec.status_code <> G_JOB_STATUS_QA_PENDING AND
       p_workorder_rec.status_code <> G_JOB_STATUS_DEFERRAL_PENDING ) THEN
    --Modified by srini to show the status meaning
				-- replacing with call to get_status function
				-- so no exceptions are thrown if the
				-- lookup does not exist
				l_job_status_meaning := get_status(p_workorder_rec.status_code,
															'AHL_JOB_STATUS');

	/*SELECT MEANING INTO l_job_status_meaning
      FROM fnd_lookup_values_vl
     WHERE lookup_type = 'AHL_JOB_STATUS'
	   AND lookup_code = p_workorder_rec.status_code;
*/
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_INVALID_WO_STATUS' );
    FND_MESSAGE.set_token( 'STATUS', l_job_status_meaning );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;

END validate_dwo_rec;

-- Function to validate the Inputs of the complete_mr_instance API
FUNCTION validate_cmri_inputs
(
  p_mr_rec               IN   mr_rec_type
) RETURN VARCHAR2
IS

l_return_status             VARCHAR2(1);
l_msg_data                  VARCHAR2(2000);

BEGIN

  -- Balaji - changed the code for 11.5.10
  -- API is changed to accept only mr_rec.
  IF (
         p_mr_rec.unit_effectivity_id = FND_API.G_MISS_NUM OR
         p_mr_rec.unit_effectivity_id IS NULL OR
         p_mr_rec.ue_object_version_no = FND_API.G_MISS_NUM OR
         p_mr_rec.ue_object_version_no IS NULL
      ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_INVALID_CMRI_INPUTS' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;
  RETURN FND_API.G_RET_STS_SUCCESS;
END validate_cmri_inputs;

-- Function to default missing attributes of the input MR instance record
-- Added in 11.5.10

FUNCTION default_mr_rec
(
  p_x_mr_rec      IN OUT NOCOPY mr_rec_type
)RETURN VARCHAR2
IS

l_mr_rec  mr_rec_type;

    /*CURSOR get_old_mr_rec(c_unit_effectivity_id NUMBER ,c_ue_object_version_no NUMBER)
    IS
    SELECT csi_item_instance_id,
           mr_header_id,
           cs_incident_id,
           mr_title,
           status_code,
           status,
           qa_inspection_type,
           actual_end_date,
           plan_id,
           collection_id
    FROM   AHL_MR_INSTANCES_V
    WHERE  unit_effectivity_id = c_unit_effectivity_id
    AND    object_version_number = c_ue_object_version_no;*/

BEGIN

   /*OPEN get_old_mr_rec(p_x_mr_rec.unit_effectivity_id,p_x_mr_rec.ue_object_version_no);

   FETCH get_old_mr_rec INTO
     l_mr_rec.item_instance_id,
     l_mr_rec.mr_header_id,
     l_mr_rec.incident_id,
     l_mr_rec.mr_title,
     l_mr_rec.ue_status_code,
     l_mr_rec.ue_status,
     l_mr_rec.qa_inspection_type,
     l_mr_rec.actual_end_date,
     l_mr_rec.qa_plan_id,
     l_mr_rec.qa_collection_id;

   CLOSE get_old_mr_rec;*/
   --for fix of bug number 6467963
   get_mr_details_rec
      (
         p_unit_effectivity_id => p_x_mr_rec.unit_effectivity_id,
         p_object_version_number   => p_x_mr_rec.ue_object_version_no,
         x_mr_rec => l_mr_rec
   );

   -- Convert G_MISS values to NULL and NULL values to Old values
   IF ( p_x_mr_rec.item_instance_id = FND_API.G_MISS_NUM ) THEN
      p_x_mr_rec.item_instance_id := null;
   ELSIF ( p_x_mr_rec.item_instance_id IS NULL ) THEN
      p_x_mr_rec.item_instance_id := l_mr_rec.item_instance_id;
   END IF;

   IF ( p_x_mr_rec.mr_header_id = FND_API.G_MISS_NUM ) THEN
      p_x_mr_rec.mr_header_id := null;
   ELSIF ( p_x_mr_rec.mr_header_id IS NULL ) THEN
      p_x_mr_rec.mr_header_id := l_mr_rec.mr_header_id;
   END IF;

   IF ( p_x_mr_rec.incident_id = FND_API.G_MISS_NUM ) THEN
      p_x_mr_rec.incident_id := null;
   ELSIF ( p_x_mr_rec.incident_id IS NULL ) THEN
      p_x_mr_rec.incident_id := l_mr_rec.incident_id;
   END IF;

   IF ( p_x_mr_rec.mr_title = FND_API.G_MISS_CHAR ) THEN
      p_x_mr_rec.mr_title := null;
   ELSIF ( p_x_mr_rec.mr_title IS NULL ) THEN
      p_x_mr_rec.mr_title := l_mr_rec.mr_title;
   END IF;

   IF ( p_x_mr_rec.ue_status_code = FND_API.G_MISS_CHAR ) THEN
      p_x_mr_rec.ue_status_code := null;
   ELSIF ( p_x_mr_rec.ue_status_code IS NULL ) THEN
      p_x_mr_rec.ue_status_code := l_mr_rec.ue_status_code;
   END IF;

   IF ( p_x_mr_rec.ue_status = FND_API.G_MISS_CHAR ) THEN
      p_x_mr_rec.ue_status := null;
   ELSIF ( p_x_mr_rec.ue_status IS NULL ) THEN
      p_x_mr_rec.ue_status := l_mr_rec.ue_status;
   END IF;

   IF ( p_x_mr_rec.qa_inspection_type = FND_API.G_MISS_CHAR ) THEN
      p_x_mr_rec.qa_inspection_type := null;
   ELSIF ( p_x_mr_rec.qa_inspection_type IS NULL ) THEN
      p_x_mr_rec.qa_inspection_type := l_mr_rec.qa_inspection_type;
   END IF;

   IF ( p_x_mr_rec.actual_end_date = FND_API.G_MISS_DATE ) THEN
      p_x_mr_rec.actual_end_date := null;
   ELSIF ( p_x_mr_rec.actual_end_date IS NULL ) THEN
      p_x_mr_rec.actual_end_date := l_mr_rec.actual_end_date;
   END IF;

   IF ( p_x_mr_rec.qa_plan_id = FND_API.G_MISS_NUM ) THEN
      p_x_mr_rec.qa_plan_id := null;
   ELSIF ( p_x_mr_rec.qa_plan_id IS NULL ) THEN
      p_x_mr_rec.qa_plan_id := l_mr_rec.qa_plan_id;
   END IF;

   IF ( p_x_mr_rec.qa_collection_id = FND_API.G_MISS_NUM ) THEN
      p_x_mr_rec.qa_collection_id := null;
   ELSIF ( p_x_mr_rec.qa_collection_id IS NULL ) THEN
      p_x_mr_rec.qa_collection_id := l_mr_rec.qa_collection_id;
   END IF;

   RETURN FND_API.G_RET_STS_SUCCESS;

END default_mr_rec;

-- Function to check whether the MR/SR is in a status that it can be signed off.
-- Added in 11.5.10
FUNCTION validate_mr_status
(
  p_mr_status_code  IN  VARCHAR2,
  p_mr_status       IN  VARCHAR2,
  p_mr_title        IN  VARCHAR2
)RETURN VARCHAR2
IS

BEGIN

   IF (p_mr_status_code <> G_MR_STATUS_JOBS_COMPLETE) THEN
     FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_INV_SIGNOFF_STATUS');
     FND_MESSAGE.set_token( 'MAINT_REQ', p_mr_title);
     FND_MESSAGE.set_token( 'STATUS', p_mr_status);
     FND_MSG_PUB.add;
     RETURN FND_API.G_RET_STS_ERROR;
   END IF;

   RETURN FND_API.G_RET_STS_SUCCESS;

END validate_mr_status;

-- Function to check whether a MR Instance is Complete
FUNCTION is_mr_complete
(
  p_mr_title             IN   VARCHAR2,
  p_status_code          IN   VARCHAR2,
  p_status               IN   VARCHAR2,
  p_qa_inspection_type   IN   VARCHAR2,
  p_qa_plan_id           IN   NUMBER,
  p_qa_collection_id     IN   NUMBER
) RETURN VARCHAR2
IS

l_return_status       VARCHAR2(1);

BEGIN

  -- Validate Status
  IF  p_status_code = G_MR_STATUS_DEFERRAL_PENDING  THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_INV_SIGNOFF_STATUS');
    FND_MESSAGE.set_token( 'MAINT_REQ', p_mr_title );
    FND_MESSAGE.set_token( 'STATUS', NVL( p_status, p_status_code ) );
    FND_MSG_PUB.add;
  END IF;

  -- Check if inspection type is not null then plan id is also not null
  -- Bug # 6436307 - start
  IF (
     p_qa_inspection_type IS NOT NULL
     AND p_status_code <> G_MR_STATUS_SIGNED_OFF
     AND p_status_code <> G_MR_STATUS_DEFERRED
     AND p_status_code <> G_MR_STATUS_DEFERRAL_PENDING
     AND p_status_code <> G_MR_STATUS_TERMINATED
     AND p_status_code <> G_MR_STATUS_CANCELLED
     ) THEN
    IF (p_qa_plan_id IS NULL) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_MR_QA_PLAN_ID_NULL' );
      FND_MESSAGE.set_token( 'MAINT_REQ', p_mr_title);
      FND_MESSAGE.set_token( 'INSP_TYPE', p_qa_inspection_type );
      FND_MSG_PUB.add;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  -- Check if inspection type is not null then collection id is also not null
  IF (p_qa_inspection_type IS NOT NULL
      AND p_status_code <> G_MR_STATUS_SIGNED_OFF
      AND p_status_code <> G_MR_STATUS_DEFERRED
      AND p_status_code <> G_MR_STATUS_DEFERRAL_PENDING
      AND p_status_code <> G_MR_STATUS_TERMINATED
      AND p_status_code <> G_MR_STATUS_CANCELLED
     ) THEN
     IF (p_qa_collection_id IS NULL) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_MR_QA_COL_ID_NULL' );
      FND_MESSAGE.set_token( 'MAINT_REQ', p_mr_title);
      FND_MSG_PUB.add;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;
  -- Bug # 6436307 - end
  RETURN FND_API.G_RET_STS_SUCCESS;
END is_mr_complete;

-- Function to Check whether all Child MR Instances for a MR Instance
-- are Complete
FUNCTION are_child_mrs_complete
(
  p_mr_rec               IN   mr_rec_type
) RETURN VARCHAR2
IS

l_return_status      VARCHAR2(1);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);

/*CURSOR     get_child_mr_instances( c_unit_effectivity_id NUMBER )
IS
SELECT     mr_header_id,
           unit_effectivity_id,
           status_code
FROM       AHL_UNIT_EFFECTIVITIES_B
WHERE      unit_effectivity_id IN
(
SELECT     related_ue_id
FROM       AHL_UE_RELATIONSHIPS
WHERE      unit_effectivity_id = related_ue_id
START WITH ue_id = c_unit_effectivity_id
       AND relationship_code = 'PARENT'
CONNECT BY ue_id = PRIOR related_ue_id
       AND relationship_code = 'PARENT'
);*/

--for fix of bug number 6467963
CURSOR     get_child_mr_instances( c_unit_effectivity_id NUMBER )
IS
SELECT     mr_header_id,
           unit_effectivity_id,
           status_code
FROM       AHL_UNIT_EFFECTIVITIES_B UE, (
SELECT     related_ue_id
FROM       AHL_UE_RELATIONSHIPS
START WITH ue_id = c_unit_effectivity_id
       AND relationship_code = 'PARENT'
CONNECT BY ue_id = PRIOR related_ue_id
       AND relationship_code = 'PARENT'
)CH
WHERE      UE.unit_effectivity_id = CH.related_ue_id;

BEGIN

  FOR mr_cursor IN get_child_mr_instances( p_mr_rec.unit_effectivity_id ) LOOP
    --Balaji added additional status checks for BAE Bug.
    IF ( mr_cursor.status_code <> G_MR_STATUS_SIGNED_OFF AND
         mr_cursor.status_code <> G_MR_STATUS_DEFERRED AND
         mr_cursor.status_code <> G_MR_STATUS_TERMINATED AND
         mr_cursor.status_code <> G_MR_STATUS_CANCELLED AND
	 mr_cursor.status_code <> G_MR_STATUS_MR_TERMINATED
    ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_CHILD_MRS_NOT_COMPL' );
      FND_MESSAGE.set_token( 'MAINT_REQ', p_mr_rec.mr_title);
      FND_MSG_PUB.add;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;

  END LOOP;

  RETURN FND_API.G_RET_STS_SUCCESS;
END are_child_mrs_complete;

-- Function to get the Counter Readings for an Item Instance
-- Balaji added the parameter p_acccomplish_date for Bug # 6784053 (FP for Bug # 6750836).
-- cursor for retrieving latest counter reading before or equal
-- to the actual workorder date.
FUNCTION get_cp_counters
(
  p_item_instance_id     IN          NUMBER,
  p_wip_entity_id        IN          NUMBER,
  p_actual_date          IN          DATE,
  x_counter_tbl          OUT NOCOPY  counter_tbl_type
) RETURN VARCHAR2
IS

l_ctr_count  NUMBER := 1;

-- Get the Counter Readings
-- R12 changes for CSI_CP_COUNTERS_V. Bug# 6080133.
CURSOR get_counters( c_item_instance_id NUMBER )
IS
SELECT   DISTINCT
         CTR.counter_id counter_id,
         --CTR.counter_group_id counter_group_id,
         CTR.DEFAULTED_GROUP_ID COUNTER_GROUP_ID,
         --CTR.counter_value_id counter_value_id,
         --NVL(CTR.net_reading, 0) net_reading,
         --CTR.type type
         CTR.COUNTER_TYPE type
--FROM     CSI_CP_COUNTERS_V CTR
--WHERE    CTR.customer_product_id = c_item_instance_id
FROM     csi_counter_associations CCA, csi_counters_vl CTR
WHERE    CCA.counter_id = CTR.counter_id
AND      CCA.source_object_id = c_item_instance_id
AND      CCA.source_object_code = 'CP'
ORDER BY CTR.counter_id;

-- Added for R12 bug# 6080133.
-- get readings.
-- Bug # 6750836 -- start
-- cursor replaced to take care of accomplished date in the past.
/*
CURSOR get_readings(c_counter_id NUMBER)
IS
SELECT NVL(CV.net_reading, 0) net_reading, cv.counter_value_id
FROM csi_counter_values_v cv
WHERE cv.counter_id = c_counter_id
ORDER by value_timestamp DESC;
*/
CURSOR c_wo_actual_date(p_wip_entity_id NUMBER)
IS
SELECT
 awo.actual_end_date
FROM
 ahl_workorders awo
WHERE
 awo.wip_entity_id = p_wip_entity_id;

l_wo_actual_date  DATE;
-- cursor for retrieving latest counter reading before or equal
-- to the actual workorder date.
CURSOR get_readings(c_counter_id NUMBER, p_actual_date DATE)
IS
/*
SELECT
      nvl(CCR.NET_READING,0) net_reading,
      ccr.counter_value_id
FROM
      CSI_COUNTERS_VL CC,
      CSI_COUNTER_READINGS CCR
WHERE
          CCR.COUNTER_ID = CC.COUNTER_ID
      AND CC.COUNTER_ID = c_counter_id
      AND CCR.VALUE_TIMESTAMP <= NVL(p_actual_date,CCR.VALUE_TIMESTAMP)
ORDER BY
      CCR.VALUE_TIMESTAMP DESC;
*/

SELECT * FROM (
      SELECT
            nvl(CCR.NET_READING,0) net_reading,
            ccr.counter_value_id
      FROM
            CSI_COUNTER_READINGS CCR
      WHERE
            CCR.COUNTER_ID = c_counter_id
            AND nvl(CCR.disabled_flag,'N') = 'N'
            AND CCR.VALUE_TIMESTAMP <= NVL(p_actual_date,CCR.VALUE_TIMESTAMP)
      ORDER BY
            CCR.VALUE_TIMESTAMP DESC
             )
WHERE ROWNUM < 2;

-- Bug # 6750836 -- end
BEGIN

  l_wo_actual_date := p_actual_date;

  IF p_actual_date IS NULL
  THEN

    OPEN c_wo_actual_date(p_wip_entity_id);
    FETCH c_wo_actual_date INTO l_wo_actual_date;
    CLOSE c_wo_actual_date;

  END IF;

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.string(
                   FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.AHL_COMPLETIONS_PVT.get_cp_counters',
                   'l_wo_actual_date in get_cp_counters -> ' || TO_CHAR(l_wo_actual_date, 'DD-MON-YYYY HH24:MI:SS')
                  );
  END IF;
  FOR ctr_cursor IN get_counters( p_item_instance_id )
  LOOP
    x_counter_tbl( l_ctr_count ).item_instance_id := p_item_instance_id;
    x_counter_tbl( l_ctr_count ).counter_id := ctr_cursor.counter_id;
    x_counter_tbl( l_ctr_count ).counter_group_id := ctr_cursor.counter_group_id;
    -- get reading.
    OPEN get_readings(ctr_cursor.counter_id, l_wo_actual_date);
    FETCH get_readings INTO x_counter_tbl( l_ctr_count ).counter_reading,
                            x_counter_tbl( l_ctr_count ).counter_value_id;
    IF (get_readings%NOTFOUND) THEN
      x_counter_tbl( l_ctr_count ).counter_reading := 0;
      x_counter_tbl( l_ctr_count ).counter_value_id := NULL;
    END IF;
    CLOSE get_readings;

    --x_counter_tbl( l_ctr_count ).counter_value_id := ctr_cursor.counter_value_id;
    --x_counter_tbl( l_ctr_count ).counter_reading := ctr_cursor.net_reading;
    x_counter_tbl( l_ctr_count ).counter_type := ctr_cursor.type;

    l_ctr_count := l_ctr_count + 1;

  END LOOP;

/* Removed for Bug 3310304
  IF ( x_counter_tbl.COUNT < 1 ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_NO_CTRS_FOR_MR' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;
*/

  RETURN FND_API.G_RET_STS_SUCCESS;
END get_cp_counters;

-- Function to get the Reset Counter Readings for an Item Instance for a MR
-- Function to get the Reset Counter Readings for an Item Instance for a MR
FUNCTION get_reset_counters
(
  p_mr_header_id         IN          NUMBER,
  p_item_instance_id     IN          NUMBER,
  p_actual_date          IN          DATE,
  x_counter_tbl          OUT NOCOPY  counter_tbl_type
) RETURN VARCHAR2
IS

l_ctr_count  NUMBER := 1;
l_prev_counter_id NUMBER := -1;

l_appl_mrs_tbl    AHL_FMP_PVT.applicable_mr_tbl_type;
l_return_status   VARCHAR2(1);
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(2000);

-- Get the Counter Readings and Reset Values
-- R12 counter changes for CSI_CP_COUNTERS_V. Bug# 6080133
CURSOR get_counters( c_item_instance_id NUMBER, c_mr_header_id NUMBER, c_mr_eff_id NUMBER )
IS
SELECT   DISTINCT
         CTR.counter_id counter_id,
         --CTR.counter_group_id counter_group_id,
         CTR.DEFAULTED_GROUP_ID COUNTER_GROUP_ID,
         --NVL(CTR.net_reading, 0) net_reading,
         CTR.COUNTER_TYPE type,
         MRI.reset_value reset_value
--FROM     CSI_CP_COUNTERS_V CTR, AHL_MR_INTERVALS_V MRI, AHL_MR_EFFECTIVITIES MRE
FROM     csi_counter_associations CCA, csi_counters_vl CTR, AHL_MR_INTERVALS_V MRI, AHL_MR_EFFECTIVITIES MRE
WHERE    CCA.counter_id = CTR.counter_id
AND      CCA.source_object_id = c_item_instance_id
AND      CCA.source_object_code = 'CP'
--AND      CTR.counter_name = MRI.counter_name
AND      CTR.counter_template_name = MRI.counter_name
AND      MRI.reset_value IS NOT NULL
AND      MRI.mr_effectivity_id = MRE.mr_effectivity_id
AND      MRE.mr_effectivity_id = c_mr_eff_id
AND      MRE.mr_header_id = c_mr_header_id
ORDER BY CTR.counter_id, MRI.reset_value DESC;

-- get readings. Added for R12 bug# 6080133.
-- Bug # 6750836 -- start
CURSOR get_readings(c_counter_id NUMBER, p_actual_date DATE)
IS
/*
SELECT
      nvl(CCR.NET_READING,0) net_reading
FROM
      CSI_COUNTERS_VL CC,
      CSI_COUNTER_READINGS CCR
WHERE
          CCR.COUNTER_ID = CC.COUNTER_ID
      AND CC.COUNTER_ID = c_counter_id
      AND CCR.VALUE_TIMESTAMP <= p_actual_date
ORDER by
      CCR.value_timestamp DESC;
*/

SELECT * FROM (
      SELECT
            nvl(CCR.NET_READING,0) net_reading
      FROM
            CSI_COUNTER_READINGS CCR
      WHERE
            CCR.COUNTER_ID = c_counter_id
            AND nvl(CCR.disabled_flag,'N') = 'N'
            AND CCR.VALUE_TIMESTAMP <= p_actual_date
      ORDER by
            CCR.value_timestamp DESC
             )
WHERE ROWNUM < 2;


-- modified logic to uptake IB changes made in bug# 7374316.
CURSOR get_current_readings(c_counter_id NUMBER)
IS
/*
SELECT
      nvl(CCR.NET_READING,0) net_reading
FROM
      CSI_COUNTERS_VL CC,
      CSI_COUNTER_READINGS CCR
WHERE
          CCR.COUNTER_ID = CC.COUNTER_ID
      AND CC.COUNTER_ID = c_counter_id
ORDER BY
      CCR.VALUE_TIMESTAMP DESC;
*/
SELECT
      nvl(CCR.NET_READING,0) net_reading
FROM
      CSI_COUNTERS_B CC,
      CSI_COUNTER_READINGS CCR
WHERE
      CCR.COUNTER_VALUE_ID = CC.CTR_VAL_MAX_SEQ_NO
      AND nvl(CCR.disabled_flag,'N') = 'N'
      AND CC.COUNTER_ID = c_counter_id;

l_actual_ct_reading NUMBER;
l_cur_ct_reading    NUMBER;
-- Bug # 6750836 -- end

BEGIN

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.string(
                   FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.AHL_COMPLETIONS_PVT.get_reset_counters',
                   'p_actual_date in get_reset_counters -> ' || TO_CHAR(p_actual_date, 'DD-MON-YYYY HH24:MI:SS')
                  );
  END IF;

  -- get applicable effectivities.
  AHL_FMP_PVT.Get_Applicable_MRs(p_api_version => 1.0,
                                 -- added to fix bug# 8861642
                                 p_validation_level       => 20, -- bypass instance validation.
                                 x_return_status          => l_return_status,
                                 x_msg_count              => l_msg_count,
                                 x_msg_data               => l_msg_data,
                                 p_item_instance_id       => p_item_instance_id,
                                 p_mr_header_id           => p_mr_header_id,
                                 p_components_flag        => 'N',
                                 x_applicable_mr_tbl      => l_appl_mrs_tbl) ;

  -- Raise errors if exceptions occur
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Get counters for effectivity.
  IF (l_appl_mrs_tbl.COUNT > 0) THEN
     FOR i IN l_appl_mrs_tbl.FIRST..l_appl_mrs_tbl.LAST LOOP

       FOR ctr_cursor IN get_counters( p_item_instance_id, p_mr_header_id,
                                       l_appl_mrs_tbl(i).mr_effectivity_id )
       LOOP
         IF ( ctr_cursor.counter_id <> l_prev_counter_id ) THEN

            OPEN get_readings(ctr_cursor.counter_id, p_actual_date);
            FETCH get_readings INTO l_actual_ct_reading;
            CLOSE get_readings;

            OPEN get_current_readings(ctr_cursor.counter_id);
            FETCH get_current_readings INTO l_cur_ct_reading;
            CLOSE get_current_readings;

	    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
	    THEN

		fnd_log.string(
			FND_LOG.LEVEL_STATEMENT,
			'ahl.plsql.AHL_COMPLETIONS_PVT.get_reset_counters',
			'counter with id.. -> ' || ctr_cursor.counter_id
			||', l_actual_ct_reading ->' ||l_actual_ct_reading
			||', l_cur_ct_reading ->' ||l_cur_ct_reading
		       );

	    END IF;

            IF l_actual_ct_reading = l_cur_ct_reading THEN

		     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
		     THEN
		         fnd_log.string(
				        FND_LOG.LEVEL_STATEMENT,
				        'ahl.plsql.AHL_COMPLETIONS_PVT.get_reset_counters',
				        'Resetting counter with id.. -> ' || ctr_cursor.counter_id
				       );
		         fnd_log.string(
				        FND_LOG.LEVEL_STATEMENT,
				        'ahl.plsql.AHL_COMPLETIONS_PVT.get_reset_counters',
				        'counter with id.. -> ' || ctr_cursor.counter_id ||', l_actual_ct_reading ->' ||l_actual_ct_reading
				       );
		     END IF;

		     x_counter_tbl( l_ctr_count ).counter_reading := l_actual_ct_reading;
		     x_counter_tbl( l_ctr_count ).item_instance_id := p_item_instance_id;
		     x_counter_tbl( l_ctr_count ).counter_id := ctr_cursor.counter_id;
		     x_counter_tbl( l_ctr_count ).counter_group_id := ctr_cursor.counter_group_id;
		     -- get readings.
		     /*
		     IF (get_readings%NOTFOUND) THEN

			-- Bug # 6750836 -- start
			--x_counter_tbl( l_ctr_count ).counter_reading := 0;
			FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_CN_RESET_ERROR' );
			FND_MSG_PUB.add;
			RETURN FND_API.G_RET_STS_ERROR;
			-- Bug # 6750836 -- end

		     END IF;
		     */
		     x_counter_tbl( l_ctr_count ).counter_type := ctr_cursor.type;
		     x_counter_tbl( l_ctr_count ).reset_value := ctr_cursor.reset_value;

		     l_ctr_count := l_ctr_count + 1;

            END IF;-- l_actual_ct_reading = l_cur_ct_reading

            l_prev_counter_id := ctr_cursor.counter_id;

         END IF; -- ( ctr_cursor.counter_id <> l_prev_counter_id )

       END LOOP;
     END LOOP;
  END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;
END get_reset_counters;

-- Function to Reset the Counter Readings
FUNCTION reset_counters
(
  p_mr_rec            IN              mr_rec_type,
  p_x_counter_tbl     IN OUT NOCOPY   counter_tbl_type,
  p_actual_end_date   IN              DATE,
  x_msg_count         OUT NOCOPY      VARCHAR2,
  x_msg_data          OUT NOCOPY      VARCHAR2
) RETURN VARCHAR2
IS

l_ctr_grp_log_rec CS_CTR_CAPTURE_READING_PUB.ctr_grp_log_rec_type;
l_ctr_rdg_tbl     CS_CTR_CAPTURE_READING_PUB.ctr_rdg_tbl_type;
l_prop_rdg_tbl    CS_CTR_CAPTURE_READING_PUB.prop_rdg_tbl_type;
l_return_status   VARCHAR2(2000);
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(2000);
l_ctr_count       NUMBER := 1;
l_app_name        VARCHAR2(30);
l_msg_name        VARCHAR2(30);
BEGIN

  l_ctr_grp_log_rec.counter_group_id := p_x_counter_tbl(1).counter_group_id;
  l_ctr_grp_log_rec.value_timestamp := p_actual_end_date;
  l_ctr_grp_log_rec.source_transaction_id := p_x_counter_tbl(1).item_instance_id;
  l_ctr_grp_log_rec.source_transaction_code := 'CP';
  FOR i IN 1..p_x_counter_tbl.COUNT
  LOOP

    IF ( p_x_counter_tbl(i).reset_value IS NOT NULL AND
         p_x_counter_tbl(i).counter_type = 'REGULAR' ) THEN
      l_ctr_rdg_tbl(l_ctr_count).counter_id := p_x_counter_tbl(i).counter_id;
      l_ctr_rdg_tbl(l_ctr_count).value_timestamp := p_actual_end_date;
      /* -- IB(Anju) suggested as part of fix for bug#6267502
      --l_ctr_rdg_tbl(l_ctr_count).counter_reading := p_x_counter_tbl(i).reset_value;
      */
      l_ctr_rdg_tbl(l_ctr_count).counter_reading := p_x_counter_tbl(i).reset_value; -- IB(Anju) suggested as part of fix for bug#6267502
      l_ctr_rdg_tbl(l_ctr_count).valid_flag := 'Y';
      l_ctr_rdg_tbl(l_ctr_count).override_valid_flag := 'N';

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( 'Ctr ID:' || TO_CHAR( l_ctr_rdg_tbl(l_ctr_count).counter_id ) || ' Reset Value :' || TO_CHAR( l_ctr_rdg_tbl(l_ctr_count).counter_reading ) );
      END IF;

      IF ( p_x_counter_tbl(i).counter_reading <> 0 ) THEN
        l_ctr_rdg_tbl(l_ctr_count).reset_flag := 'Y';
        l_ctr_rdg_tbl(l_ctr_count).reset_reason := 'ASO Maintenance Requirement Accomplishment. MR-' || TO_CHAR( p_mr_rec.mr_header_id ) || ' UE-' || TO_CHAR( p_mr_rec.unit_effectivity_id );
        /* -- fix for bug number 6267502
        --l_ctr_rdg_tbl(l_ctr_count).pre_reset_last_rdg := p_x_counter_tbl(i).counter_reading;
        --l_ctr_rdg_tbl(l_ctr_count).post_reset_first_rdg := 0;
        --l_ctr_rdg_tbl(l_ctr_count).misc_reading_type := 'ASO_HARD_RESET';
        --l_ctr_rdg_tbl(l_ctr_count).misc_reading := p_x_counter_tbl(i).counter_reading;
        */
        /* start of fix -- IB(Anju) suggested as part of fix for bug#6267502 */
        l_ctr_rdg_tbl(l_ctr_count).pre_reset_last_rdg := p_x_counter_tbl(i).reset_value;
        l_ctr_rdg_tbl(l_ctr_count).post_reset_first_rdg := p_x_counter_tbl(i).reset_value;
        /* end of fix -- IB(Anju) suggested as part of fix for bug#6267502 */
        IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( 'Reset Ctr ID:' || TO_CHAR( l_ctr_rdg_tbl(l_ctr_count).counter_id ) || ' Pre-Reset:' || TO_CHAR( l_ctr_rdg_tbl(l_ctr_count).pre_reset_last_rdg ) || ' Adj:' || TO_CHAR( l_ctr_rdg_tbl(l_ctr_count).misc_reading ) );
        END IF;
      END IF;

      -- Store the Reset Value as the Current Reading ( for UMP )
      p_x_counter_tbl(i).counter_reading := p_x_counter_tbl(i).reset_value;
      l_ctr_count := l_ctr_count + 1;

    END IF;

  END LOOP;

  IF ( l_ctr_rdg_tbl.COUNT > 0 ) THEN
    BEGIN
      CS_CTR_CAPTURE_READING_PUB.capture_counter_reading
      (
          p_api_version_number => 1.0,
          p_init_msg_list      => FND_API.G_TRUE,
          p_commit             => FND_API.G_FALSE,
          p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
          p_ctr_grp_log_rec    => l_ctr_grp_log_rec,
          p_ctr_rdg_tbl        => l_ctr_rdg_tbl,
          p_prop_rdg_tbl       => l_prop_rdg_tbl,
          x_return_status      => l_return_status,
          x_msg_count          => l_msg_count,
          x_msg_data           => l_msg_data
      );
    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_CTR_RESET_API_ERROR' );
        FND_MSG_PUB.add;
        RETURN FND_API.G_RET_STS_ERROR;
    END;

    IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      IF ( l_msg_data IS NULL ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_CTR_RESET_API_ERROR' );
        FND_MSG_PUB.add;
      ELSE
        FND_MESSAGE.parse_encoded( l_msg_data, l_app_name, l_msg_name );
        FND_MESSAGE.set_name( l_app_name, l_msg_name );
        FND_MSG_PUB.add;
      END IF;
      RETURN FND_API.G_RET_STS_ERROR;
    ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_CTR_RESET_API_ERROR' );
      FND_MSG_PUB.add;
      RETURN FND_API.G_RET_STS_ERROR;
    END IF;

  END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;
END reset_counters;

-- Function to Record Accomplishments in UMP
FUNCTION update_ump
(
  p_unit_effectivity_id  IN   NUMBER,
  p_ue_object_version    IN   NUMBER,
  p_actual_end_date      IN   DATE,
  p_counter_tbl          IN   counter_tbl_type,
  x_msg_count            OUT NOCOPY  VARCHAR2,
  x_msg_data             OUT NOCOPY  VARCHAR2
) RETURN VARCHAR2
IS
l_return_status   VARCHAR2(2000);
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(2000);
l_ctr_count       NUMBER := 1;

l_unit_effectivity_tbl   AHL_UMP_UNITMAINT_PVT.unit_effectivity_tbl_type;
l_unit_accomplish_tbl    AHL_UMP_UNITMAINT_PVT.unit_accomplish_tbl_type;
l_unit_threshold_tbl     AHL_UMP_UNITMAINT_PVT.unit_threshold_tbl_type;
BEGIN

  l_unit_effectivity_tbl(1).unit_effectivity_id := p_unit_effectivity_id;
  l_unit_effectivity_tbl(1).object_version_number := p_ue_object_version;
  l_unit_effectivity_tbl(1).status_code := G_MR_STATUS_SIGNED_OFF;
  l_unit_effectivity_tbl(1).accomplished_date := p_actual_end_date;

  IF ( p_counter_tbl.COUNT > 0 ) THEN
    FOR i IN 1..p_counter_tbl.COUNT
    LOOP
      IF ( p_counter_tbl(i).counter_reading IS NOT NULL ) THEN
        l_unit_accomplish_tbl(l_ctr_count).unit_effectivity_id := p_unit_effectivity_id;
        l_unit_accomplish_tbl(l_ctr_count).counter_id := p_counter_tbl(i).counter_id;
        l_unit_accomplish_tbl(l_ctr_count).counter_value := p_counter_tbl(i).counter_reading;
        l_unit_accomplish_tbl(l_ctr_count).operation_flag := 'C';
        l_ctr_count := l_ctr_count + 1;
      END IF;
    END LOOP;
  END IF;

  AHL_UMP_UNITMAINT_PVT.capture_mr_updates
  (
    p_api_version           => 1.0,
    p_init_msg_list         => FND_API.G_TRUE,
    p_commit                => FND_API.G_FALSE,
    p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
    p_default               => FND_API.G_TRUE,
    p_module_type           => NULL,
    p_unit_effectivity_tbl  => l_unit_effectivity_tbl,
    p_x_unit_threshold_tbl  => l_unit_threshold_tbl,
    p_x_unit_accomplish_tbl => l_unit_accomplish_tbl,
    x_return_status         => l_return_status,
    x_msg_count             => l_msg_count,
    x_msg_data              => l_msg_data
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    IF ( l_msg_data IS NULL ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_UMP_API_ERROR' );
      FND_MSG_PUB.add;
    ELSE
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
    END IF;
    RETURN FND_API.G_RET_STS_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    IF ( l_msg_data IS NULL ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_UMP_API_ERROR' );
      FND_MSG_PUB.add;
    ELSE
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
    END IF;
    RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;
END update_ump;

-- Added for R12-Serial Reservation enhancements.
-- We need to delete any reserved serial numbers when a workorder is completed.
PROCEDURE Delete_Serial_Reservations (p_workorder_id  IN NUMBER,
                                      x_return_status OUT NOCOPY VARCHAR2)
IS

  CURSOR get_scheduled_mater_csr (p_workorder_id IN NUMBER) IS
    SELECT scheduled_material_id
    FROM  ahl_job_oper_materials_v
    WHERE workorder_id = p_workorder_id
      AND reserved_quantity > 0;

  l_msg_count  NUMBER;
  l_msg_data   VARCHAR2(2000);

  l_DEBUG_LEVEL       NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_DEBUG_PROC        NUMBER := FND_LOG.LEVEL_PROCEDURE;
  l_DEBUG_STMT        NUMBER := FND_LOG.LEVEL_STATEMENT;

BEGIN


  IF ( l_DEBUG_PROC >= l_DEBUG_LEVEL) THEN
    fnd_log.string(l_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WORKORDER_PVT.delete_serial_reservations.begin',
                   'At the start of procedure for workorder_id:' || p_workorder_id);
  END IF;

  -- Initialize return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR get_scheduled_mater_rec IN get_scheduled_mater_csr(p_workorder_id)
  LOOP
       -- Call delete reservation API.
       AHL_RSV_RESERVATIONS_PVT.Delete_Reservation (
                          p_api_version => 1.0,
                          p_init_msg_list          => FND_API.G_TRUE             ,
                          p_commit                 => FND_API.G_FALSE            ,
                          p_validation_level       => FND_API.G_VALID_LEVEL_FULL ,
                          p_module_type            => NULL,
                          x_return_status          => x_return_status            ,
                          x_msg_count              => l_msg_count                ,
                          x_msg_data               => l_msg_data                 ,
                          p_scheduled_material_id   => get_scheduled_mater_rec.scheduled_material_id );

       IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
          IF (l_DEBUG_STMT >= l_DEBUG_LEVEL) THEN
             fnd_log.string(l_DEBUG_STMT, 'ahl.plsql.AHL_PRD_WORKORDER_PVT.delete_serial_reservations',
                         'AHL_RSV_RESERVATIONS_PVT.Delete_Reservation failed for schedule material ID: '
                         || get_scheduled_mater_rec.scheduled_material_id);
          END IF; -- x_return_status

          EXIT;

       END IF; -- x_return_status

    END LOOP; -- get_scheduled_mater_rec

END Delete_Serial_Reservations;

--------------------------------------------------------------
-- Procedure adde by Balaji for bug # 4757222, FP Bug # 4955278.
--
-- This procedure derives operation actual start and end dates
-- from resource transactions dates.
--------------------------------------------------------------
/* Bug # 4955278 - start */
PROCEDURE Get_Op_Act_from_Res_Txn
(
 p_wip_entity_id     IN NUMBER,
 p_operation_seq_num IN NUMBER,
 x_actual_start_date OUT NOCOPY DATE,
 x_actual_end_date   OUT NOCOPY DATE
)
IS

CURSOR c_get_wop_details(p_wip_entity_id IN NUMBER,
			 p_operation_seq_num IN NUMBER)
IS
SELECT
   WIOP.organization_id
FROM
   WIP_OPERATIONS WIOP
WHERE
   WIOP.wip_entity_id = p_wip_entity_id
   AND WIOP.operation_seq_num = p_operation_seq_num;

-- query to retrieve total hrs transacted for a operation.
CURSOR c_get_txn_dates(p_wip_entity_id     IN NUMBER,
                       p_operation_seq_num IN NUMBER,
                       p_organization_id IN NUMBER)
IS
SELECT
  MIN(WIPT.TRANSACTION_DATE),
  MAX(WIPT.TRANSACTION_DATE + (WIPT.TRANSACTION_QUANTITY/24))
FROM
  WIP_TRANSACTIONS WIPT
WHERE
  WIPT.wip_entity_id = p_wip_entity_id
  AND  WIPT.operation_seq_num = p_operation_seq_num
  AND WIPT.organization_id = p_organization_id;


CURSOR c_get_pending_txn_dates(p_wip_entity_id     IN NUMBER,
                       	       p_operation_seq_num IN NUMBER,
                       	       p_organization_id IN NUMBER)
IS
SELECT MIN(WIPT.TRANSACTION_DATE),
       MAX(WIPT.TRANSACTION_DATE + (WIPT.TRANSACTION_QUANTITY/24))
FROM
    WIP_COST_TXN_INTERFACE WIPT
WHERE
    WIPT.wip_entity_id = p_wip_entity_id
    AND  WIPT.operation_seq_num = p_operation_seq_num
    AND WIPT.organization_id = p_organization_id;

l_min_txn_date DATE;
l_max_txn_date DATE;
l_min_pending_txn_date DATE;
l_max_pending_txn_date DATE;
l_org_id NUMBER;

BEGIN

  OPEN c_get_wop_details(p_wip_entity_id, p_operation_seq_num);
  FETCH c_get_wop_details INTO l_org_id;
  CLOSE c_get_wop_details;

  -- Get min and max transactions dates from already completed transactions.
  OPEN c_get_txn_dates(p_wip_entity_id, p_operation_seq_num,l_org_id);
  FETCH c_get_txn_dates INTO l_min_txn_date, l_max_txn_date;
  CLOSE c_get_txn_dates;

  -- Get min and max transactions dates from pending resource transactions.
  OPEN c_get_pending_txn_dates(p_wip_entity_id, p_operation_seq_num,l_org_id);
  FETCH c_get_pending_txn_dates INTO l_min_pending_txn_date, l_max_pending_txn_date;
  CLOSE c_get_pending_txn_dates;

  IF l_min_txn_date IS NULL AND l_min_pending_txn_date IS NULL
  THEN
       x_actual_start_date := NULL;
  ELSE
       x_actual_start_date := LEAST(NVL(l_min_txn_date, l_min_pending_txn_date), NVL(l_min_pending_txn_date, l_min_txn_date));
  END IF;

  IF l_max_txn_date IS NULL AND l_max_pending_txn_date IS NULL
  THEN
       x_actual_end_date := NULL;
  ELSE
       x_actual_end_date := GREATEST(NVL(l_max_txn_date, l_max_pending_txn_date), NVL(l_max_pending_txn_date, l_max_txn_date));
  END IF;

END Get_Op_Act_from_Res_Txn;
/* Bug # 4955278 - end */

-- BEGIN APIs

-- Procedure to Complete an Operation
PROCEDURE complete_operation
(
  p_api_version            IN   NUMBER     := 1.0,
  p_init_msg_list          IN   VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN   VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default                IN   VARCHAR2   := FND_API.G_FALSE,
  p_module_type            IN   VARCHAR2   := NULL,
  x_return_status          OUT NOCOPY  VARCHAR2,
  x_msg_count              OUT NOCOPY  NUMBER,
  x_msg_data               OUT NOCOPY  VARCHAR2,
  p_workorder_operation_id IN   NUMBER,
  p_object_version_no      IN   NUMBER := NULL
)
IS

l_api_name       VARCHAR2(30) := 'complete_operation';
l_return_status  VARCHAR2(1);
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(2000) := NULL;

l_operation_rec  operation_rec_type;
l_workorder_rec  workorder_rec_type;

-- rroy
-- R12 Tech UIs
l_operation_tbl operation_tbl_type;
l_workorder_id NUMBER;
l_operation_seq_num NUMBER;
l_actual_end_date DATE;
l_actual_start_date DATE;
--l_resource_id NUMBER;
l_resource_seq_num NUMBER;
l_employee_id NUMBER;

-- R12
-- Tech UIs
CURSOR get_op_details(x_wo_op_id NUMBER)
IS
SELECT workorder_id,
Operation_sequence_num,
Actual_start_date,
Actual_end_date
FROM AHL_WORKORDER_OPERATIONS
WHERE workorder_operation_id = x_wo_op_id;

-- R12
-- Tech UIs


-- R12: login/logout feature.
CURSOR c_get_login_recs(p_workorder_id NUMBER,
                        p_operation_seq_num NUMBER)
IS
SELECT employee_id,
       resource_seq_num
FROM   ahl_work_login_times
WHERE  workorder_id = p_workorder_id
AND OPERATION_SEQ_NUM = p_operation_seq_num
AND login_level IN ('O','R')   -- logout only those employees who are logged in at oper, oper-resrc level.
AND LOGOUT_DATE IS NULL;

BEGIN
  -- Enable Debug (optional)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT complete_operation_PVT;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Validate all the inputs of the API
  l_return_status :=
  validate_cop_inputs
  (
    p_workorder_operation_id => p_workorder_operation_id,
    p_object_version_no      => p_object_version_no
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- rroy
  -- R12 Tech UIs
  IF p_default = FND_API.G_TRUE THEN
    -- retrieve the workorder id and the operation sequence number
    OPEN get_op_details(p_workorder_operation_id);
    FETCH get_op_details INTO l_workorder_id, l_operation_seq_num, l_actual_start_date, l_actual_end_date;
    IF get_op_details%NOTFOUND THEN
      CLOSE get_op_details;
      FND_MESSAGE.set_name('AHL', 'AHL_PRD_OP_DEF_ERROR');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE get_op_details;

    l_operation_tbl(1).workorder_id := l_workorder_id;
    l_operation_tbl(1).operation_sequence_num := l_operation_seq_num;

    Get_default_op_actual_dates(x_return_status => l_return_status,
                                x_msg_count     => l_msg_count,
				x_msg_data      => l_msg_data,
                                p_x_operation_tbl => l_operation_tbl);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.set_name('AHL', 'AHL_PRD_OP_DEF_ERROR');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- update the actual dates in the table
    IF l_actual_start_date IS NULL THEN
      UPDATE AHL_WORKORDER_OPERATIONS
      SET ACTUAL_START_DATE = l_operation_tbl(1).actual_start_date,
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
      LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
      WHERE WORKORDER_OPERATION_ID = p_workorder_operation_id;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_OP_DEF_ERROR' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
     END IF; -- IF l_actual_start_date IS NULL THEN
    IF l_actual_end_date IS NULL THEN
      UPDATE AHL_WORKORDER_OPERATIONS
      SET ACTUAL_END_DATE = l_operation_tbl(1).actual_end_date,
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
      LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
      WHERE WORKORDER_OPERATION_ID = p_workorder_operation_id;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_OP_DEF_ERROR' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
     END IF; -- IF l_actual_end_date IS NULL THEN
   END IF; -- IF p_default = FND_API.G_TRUE THEN
   -- rroy
   -- R12 Tech UIs

  --Get the Operation Details
  l_return_status :=
  get_operation_rec
  (
    p_workorder_operation_id => p_workorder_operation_id,
    p_object_version_no      => p_object_version_no,
    x_operation_rec          => l_operation_rec
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Get the Associated Workorder Details
  l_return_status :=
  get_workorder_rec
  (
    p_workorder_id              => l_operation_rec.workorder_id,
    x_workorder_rec             => l_workorder_rec
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Validate the Operation
  l_return_status :=
  validate_cop_rec
  (
    p_operation_rec          => l_operation_rec,
    p_workorder_rec          => l_workorder_rec
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- rroy
  -- R12 Tech UIs
  -- Log all technicians out of the operation being completed only if logged in at operation or resource levels.
  OPEN c_get_login_recs(l_operation_rec.workorder_id, l_operation_rec.operation_sequence_num);
  LOOP

     FETCH c_get_login_recs INTO l_employee_id, --l_resource_id,
                                 l_resource_seq_num;
     EXIT WHEN c_get_login_recs%NOTFOUND;
     -- if login at workorder, then logout these users when workorder is completed/cancelled.
     -- resource txns will post at the time user logs out of the workorder.
     AHL_PRD_WO_LOGIN_PVT.Workorder_Logout(p_api_version       => 1.0,
                                           p_init_msg_list     => p_init_msg_list,
                                           p_commit            => FND_API.G_FALSE,
                                           p_validation_level    => p_validation_level,
                                           p_module_type       => p_module_type,
                                           x_return_status     => l_return_status,
                                           x_msg_count         => l_msg_count,
                                           x_msg_data          => l_msg_data,
                                           p_employee_id       => l_employee_id,
                                           p_workorder_id      => l_operation_rec.workorder_id,
                                           p_operation_seq_num => l_operation_rec.operation_sequence_num,
                                           --p_resource_id       => l_resource_id,
                                           p_resource_seq_num  => l_resource_seq_num
                                          );
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        EXIT;
     END IF;

  END LOOP;
  CLOSE c_get_login_recs;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  --Complete the EAM Workorder Operation
  l_return_status :=
  complete_eam_wo_operation
  (
    p_operation_rec            => l_operation_rec
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Complete the AHL Workorder Operation
  l_return_status :=
  complete_ahl_wo_operation
  (
    p_operation_rec            => l_operation_rec
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --If collection_id is not null, then, Enable and Fire QA Actions if Commit Flag is true
  IF ( l_operation_rec.collection_id IS NOT NULL AND
       FND_API.to_boolean( p_commit ) ) THEN

    QA_SS_RESULTS.wrapper_fire_action
    (
      q_collection_id    => l_operation_rec.collection_id,
      q_return_status    => l_return_status,
      q_msg_count        => l_msg_count,
      q_msg_data         => l_msg_data
    );

    IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      x_msg_data := l_msg_data;
      x_msg_count := l_msg_count;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Re-set the API savepoint because, the wrapper_fire_action commits.
    SAVEPOINT complete_operation_PVT;

  END IF;

  -- Perform the Commit (if requested)
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Disable debug (if enabled)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO complete_operation_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO complete_operation_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN OTHERS THEN
    ROLLBACK TO complete_operation_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.add_exc_msg
      (
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240)
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;
END complete_operation;

PROCEDURE complete_workorder
(
  p_api_version       IN    NUMBER     := 1.0,
  p_init_msg_list     IN    VARCHAR2   := FND_API.G_TRUE,
  p_commit            IN    VARCHAR2   := FND_API.G_FALSE,
  p_validation_level  IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default           IN    VARCHAR2   := FND_API.G_FALSE,
  p_module_type       IN    VARCHAR2   := NULL,
  x_return_status     OUT NOCOPY   VARCHAR2,
  x_msg_count         OUT NOCOPY   NUMBER,
  x_msg_data          OUT NOCOPY   VARCHAR2,
  p_workorder_id      IN    NUMBER,
  p_object_version_no IN    NUMBER     := NULL
)
IS

l_api_name               VARCHAR2(30) := 'complete_workorder';
l_return_status          VARCHAR2(1);
l_msg_count              NUMBER;
l_msg_index_out          NUMBER;
l_msg_data               VARCHAR2(2000) := NULL;

l_operation_tbl          operation_tbl_type;
l_workorder_rec          workorder_rec_type;
l_mr_rec                 mr_rec_type;
l_counter_tbl            counter_tbl_type;

l_child_wos_complete     BOOLEAN := TRUE;
l_prd_workorder_rec      AHL_PRD_WORKORDER_PVT.prd_workorder_rec;
l_prd_workoper_tbl       AHL_PRD_WORKORDER_PVT.prd_workoper_tbl;

l_mr_status              VARCHAR2(30);

CURSOR  get_parent_master_wos( c_child_wip_entity_id NUMBER )
IS
SELECT  WO.workorder_id workorder_id,
        WO.object_version_number object_version_number,
        WO.wip_entity_id wip_entity_id,
        WO.status_code status_code
FROM    AHL_WORKORDERS WO,
        WIP_SCHED_RELATIONSHIPS WOR
WHERE   WO.wip_entity_id = WOR.parent_object_id
AND     WO.master_workorder_flag = 'Y'
AND     WO.status_code <> G_JOB_STATUS_DELETED
AND     WOR.parent_object_type_id = 1
AND     WOR.relationship_type = 1
AND     WOR.child_object_type_id = 1
AND     WOR.child_object_id = c_child_wip_entity_id;

CURSOR  get_child_wo_status( c_master_wip_entity_id NUMBER )
IS
SELECT  DISTINCT WO.status_code status_code
FROM    AHL_WORKORDERS WO,
        WIP_SCHED_RELATIONSHIPS WOR
WHERE   WO.wip_entity_id = WOR.child_object_id
AND     WO.status_code <> G_JOB_STATUS_DELETED
AND     WOR.parent_object_type_id = 1
AND     WOR.relationship_type = 1
AND     WOR.child_object_type_id = 1
AND     WOR.parent_object_id = c_master_wip_entity_id;


/*CURSOR Check_child_exists (c_unit_effectivity_id IN NUMBER)
IS
SELECT  1
FROM       AHL_UE_DEFERRAL_DETAILS_V
WHERE      unit_effectivity_id IN
           (
             SELECT     related_ue_id
             FROM       AHL_UE_RELATIONSHIPS
             WHERE      unit_effectivity_id = related_ue_id
             START WITH ue_id = c_unit_effectivity_id
                    AND relationship_code = 'PARENT'
             CONNECT BY ue_id = PRIOR related_ue_id
                    AND relationship_code = 'PARENT'
           );*/
CURSOR Check_child_exists (c_unit_effectivity_id IN NUMBER)
IS
SELECT  1
FROM       AHL_UNIT_EFFECTIVITIES_B UE,(
SELECT     related_ue_id
FROM       AHL_UE_RELATIONSHIPS
START WITH ue_id = c_unit_effectivity_id
       AND relationship_code = 'PARENT'
CONNECT BY ue_id = PRIOR related_ue_id
       AND relationship_code = 'PARENT'
)CH
WHERE      UE.unit_effectivity_id = CH.related_ue_id;
-- Balaji commented out the order by clause for the issue # 3 in bug #4613940(CMRO)
-- and this fix has reference to bug #3085871(ST) where it is described that order by level
-- should not be used without a reference to "start with.. connect by clause" starting 10g
--ORDER BY   level DESC;

-- rroy
-- R12 Tech UIs
-- cursor to retrieve the workorder actual dates
CURSOR get_wo_dates(x_wo_id NUMBER)
IS
SELECT Actual_start_date,
Actual_end_date,
Workorder_name
FROM AHL_WORKORDERS
WHERE workorder_id = x_wo_id;

-- R12: Login/logout feature.
-- here we pick up all employees logged in at all levels.
CURSOR c_get_login_recs(p_workorder_id NUMBER)
IS
SELECT employee_id, operation_seq_num, resource_seq_num
FROM   ahl_work_login_times
WHERE  workorder_id = p_workorder_id
AND LOGOUT_DATE IS NULL;


l_dummy  NUMBER;
l_actual_end_date DATE;
l_actual_start_date DATE;
l_def_actual_end_date DATE;
l_def_actual_start_date DATE;
l_wo_name  ahl_workorders.workorder_name%TYPE;

l_employee_id  NUMBER;
l_operation_seq_num NUMBER;
l_resource_seq_num  NUMBER;
l_up_workorder_rec  AHL_PRD_WORKORDER_PVT.prd_workorder_rec;
l_up_workoper_tbl   AHL_PRD_WORKORDER_PVT.prd_workoper_tbl;
l_object_version_number NUMBER     := NULL;


BEGIN
  -- Enable Debug (optional)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT complete_workorder_PVT;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  l_object_version_number := p_object_version_no;

  -- Validate all the inputs of the API
  l_return_status :=
  validate_wo_inputs
  (
    p_workorder_id           => p_workorder_id,
    p_object_version_no      => l_object_version_number
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- R12
  -- Tech UIs
  -- default the workorder actual dates
  IF p_default = FND_API.G_TRUE THEN
    -- retrieve the workorder actual dates
    OPEN get_wo_dates(p_workorder_id);
    FETCH get_wo_dates INTO l_actual_start_date, l_actual_end_date, l_wo_name;
    IF get_wo_dates%NOTFOUND THEN
      CLOSE get_wo_dates;
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_DEF_ERROR' );
      -- Error defaulting the actual dates for workorder WO_NAME before completion.
      -- Do we raise an error for this or just ignore the error since this is defaulting code?
      -- Check during UTs
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF; -- IF get_wo_dates%NOTFOUND THEN
    CLOSE get_wo_dates;

    Get_default_wo_actual_dates(p_workorder_id => p_workorder_id,
                                x_return_status => l_return_status,
				x_actual_start_date => l_def_actual_start_date,
				x_actual_end_date => l_def_actual_end_date);
    IF l_return_status <> FND_API. G_RET_STS_SUCCESS THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_DEF_ERROR' );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    /* Start ER # 4757222 */
    l_up_workorder_rec.WORKORDER_ID := p_workorder_id;
    l_up_workorder_rec.ACTUAL_START_DATE := nvl(l_actual_start_date, l_def_actual_start_date);
    l_up_workorder_rec.ACTUAL_END_DATE := nvl(l_actual_end_date, l_def_actual_end_date);

    IF l_up_workorder_rec.ACTUAL_START_DATE IS NOT NULL THEN
    	l_up_workorder_rec.ACTUAL_START_HR := TO_NUMBER(TO_CHAR(l_up_workorder_rec.ACTUAL_START_DATE, 'HH24'));
    	l_up_workorder_rec.ACTUAL_START_MI := TO_NUMBER(TO_CHAR(l_up_workorder_rec.ACTUAL_START_DATE, 'MI'));
    END IF;

    IF l_up_workorder_rec.ACTUAL_END_DATE IS NOT NULL THEN
       l_up_workorder_rec.ACTUAL_END_HR := TO_NUMBER(TO_CHAR(l_up_workorder_rec.ACTUAL_END_DATE, 'HH24'));
       l_up_workorder_rec.ACTUAL_END_MI := TO_NUMBER(TO_CHAR(l_up_workorder_rec.ACTUAL_END_DATE, 'MI'));
    END IF;

    AHL_PRD_WORKORDER_PVT.update_job
      (
        p_api_version            => 1.0                        ,
        p_init_msg_list          => FND_API.G_TRUE             ,
        p_commit                 => FND_API.G_FALSE            ,
        p_validation_level       => FND_API.G_VALID_LEVEL_FULL ,
        p_default                => FND_API.G_TRUE             ,
        p_module_type            => NULL                       ,
        x_return_status          => l_return_status            ,
        x_msg_count              => l_msg_count                ,
        x_msg_data               => l_msg_data                 ,
        p_wip_load_flag          => 'Y'		               ,
        p_x_prd_workorder_rec    => l_up_workorder_rec     ,
        p_x_prd_workoper_tbl     => l_up_workoper_tbl
      );

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_object_version_number := l_up_workorder_rec.object_version_number;

    /*
    -- update the actual dates in the table
    IF l_actual_start_date IS NULL THEN
      UPDATE AHL_WORKORDERS
      SET ACTUAL_START_DATE = l_def_actual_start_date,
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
      LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
      WHERE WORKORDER_ID = p_workorder_id;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_DEF_ERROR' );
   	FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;-- IF l_actual_start_date IS NULL THEN

    -- update the actual dates in the table
    IF l_actual_end_date IS NULL THEN
      UPDATE AHL_WORKORDERS
      SET ACTUAL_END_DATE = l_def_actual_end_date,
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
      LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
      WHERE WORKORDER_ID = p_workorder_id;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_DEF_ERROR' );
   	FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF; -- IF l_actual_end_date IS NULL THEN
    */
    /* End ER # 4757222 */
  END IF; -- IF p_default = FND_API.G_TRUE THEN


  --Get the Workorder Details
  l_return_status :=
  get_workorder_rec
  (
    p_workorder_id           => p_workorder_id,
    p_object_version_no      => l_object_version_number,
    x_workorder_rec          => l_workorder_rec
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Get the Associated Operations
  l_return_status :=
  get_workorder_operations
  (
    p_workorder_id              => p_workorder_id,
    p_object_version_no         => l_object_version_number,
    x_operation_tbl             => l_operation_tbl
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Validate the Workorder
  l_return_status :=
  validate_cwo_rec
  (
    p_workorder_rec          => l_workorder_rec,
    p_operation_tbl          => l_operation_tbl
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- R12: Tech UIs
  -- Log all technicians out of the workorder being completed
  OPEN c_get_login_recs(l_workorder_rec.workorder_id);
  LOOP
  FETCH c_get_login_recs INTO l_employee_id, l_operation_seq_num, l_resource_seq_num;
  EXIT WHEN c_get_login_recs%NOTFOUND;
      AHL_PRD_WO_LOGIN_PVT.Workorder_Logout(p_api_version       => 1.0,
                                      p_init_msg_list     => p_init_msg_list,
                                      p_commit            => FND_API.G_FALSE,
                                      p_validation_level    => p_validation_level,
                                      x_return_status     => l_return_status,
                                      x_msg_count         => l_msg_count,
                                      x_msg_data          => l_msg_data,
                                      p_employee_id       => l_employee_id,
                                      p_workorder_id      => l_workorder_rec.workorder_id,
                                      p_operation_seq_num => l_operation_seq_num,
                                      p_resource_seq_num  => l_resource_seq_num
                                     );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        EXIT;
      END IF;
  END LOOP;
  CLOSE c_get_login_recs;

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
  END IF;

  --Complete the EAM Workorder
  l_return_status :=
  complete_eam_workorder
  (
    p_workorder_rec          => l_workorder_rec
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Complete the AHL Workorder
  l_return_status :=
  update_ahl_workorder
  (
    p_workorder_rec            => l_workorder_rec,
    p_status_code              => G_JOB_STATUS_COMPLETE
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_workorder_rec.object_version_number := l_workorder_rec.object_version_number +1;

  --If l_workorder_rec.collection_id is not null, then, Enable and Fire QA Actions if Commit Flag is true
  IF ( l_workorder_rec.collection_id IS NOT NULL AND
       FND_API.to_boolean( p_commit ) ) THEN
    QA_SS_RESULTS.wrapper_fire_action
    (
      q_collection_id    => l_workorder_rec.collection_id,
      q_return_status    => l_return_status,
      q_msg_count        => l_msg_count,
      q_msg_data         => l_msg_data
    );

    IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      x_msg_data := l_msg_data;
      x_msg_count := l_msg_count;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Re-set the API savepoint because, the wrapper_fire_action commits.
    SAVEPOINT complete_workorder_PVT;

  END IF;

  IF ( G_CTR_READING_PLAN_ID IS NOT NULL AND
       l_workorder_rec.item_instance_id IS NOT NULL AND
       FND_API.to_boolean( p_commit ) ) THEN

    -- Get the Current Counter Readings for all Counters associted with
    -- the Item Instance.
    -- Bug # 6784053 (FP for Bug # 6750836) -- start
    l_return_status :=
    get_cp_counters
    (
      p_item_instance_id  => l_workorder_rec.item_instance_id,
      p_wip_entity_id     => l_workorder_rec.wip_entity_id,
      p_actual_date       => l_workorder_rec.actual_end_date,
      x_counter_tbl       => l_counter_tbl
    );
    -- Bug # 6784053 (FP for Bug # 6750836) -- end

    IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF ( l_counter_tbl.COUNT > 0 ) THEN
      l_return_status :=
      record_wo_ctr_readings
      (
        x_msg_data           => l_msg_data,
        x_msg_count          => l_msg_count,
        p_wip_entity_id      => l_workorder_rec.wip_entity_id,
        p_counter_tbl        => l_counter_tbl
      );

      IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Re-set the API savepoint because, Quality Results submission commits
      IF FND_API.to_boolean( p_commit ) THEN
        SAVEPOINT complete_workorder_PVT;
      END IF;
    END IF;

  END IF;

  -- R12: Serial Reservation enhancements.
  -- Delete remaining reservations.
  Delete_Serial_Reservations (p_workorder_id => p_workorder_id,
                              x_return_status => l_return_status);

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
     RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

/* Commenting out as part of fix for bug 4626717 Issue 5
  FOR parent_csr IN get_parent_master_wos( l_workorder_rec.wip_entity_id ) LOOP
    IF ( parent_csr.status_code <> G_JOB_STATUS_COMPLETE AND
         parent_csr.status_code <> G_JOB_STATUS_COMPLETE_NC AND
         parent_csr.status_code <> G_JOB_STATUS_CLOSED AND
         parent_csr.status_code <> G_JOB_STATUS_CANCELLED ) THEN

      FOR child_csr IN get_child_wo_status( parent_csr.wip_entity_id ) LOOP
        IF ( child_csr.status_code <> G_JOB_STATUS_COMPLETE AND
             child_csr.status_code <> G_JOB_STATUS_COMPLETE_NC AND
             child_csr.status_code <> G_JOB_STATUS_CLOSED AND
             child_csr.status_code <> G_JOB_STATUS_CANCELLED ) THEN
          l_child_wos_complete := FALSE;
          EXIT;
        END IF;
      END LOOP;

      IF ( l_child_wos_complete = TRUE ) THEN

        complete_workorder
        (
          p_api_version        => 1.0,
          p_init_msg_list      => FND_API.G_TRUE,
          p_commit             => p_commit,
          p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
          p_default            => FND_API.G_FALSE,
          p_module_type        => NULL,
          x_return_status      => l_return_status,
          x_msg_count          => l_msg_count,
          x_msg_data           => l_msg_data,
          p_workorder_id       => parent_csr.workorder_id,
          p_object_version_no  => parent_csr.object_version_number
        );

        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Re-set the API savepoint because, complete_workorder commits
        IF FND_API.to_boolean( p_commit ) THEN
          SAVEPOINT complete_workorder_PVT;
        END IF;

      ELSE
        l_child_wos_complete := TRUE;
      END IF;

    END IF;

  END LOOP;
*/
  -- If l_workorder_rec.unit_effectivity_id is not null, then, Attempt to complete the MR Instance ( Ignore Errors )
  IF ( l_workorder_rec.unit_effectivity_id IS NOT NULL AND
       NVL(l_workorder_rec.automatic_signoff_flag , 'N' ) = 'Y' ) THEN

    l_mr_status := get_mr_status( l_workorder_rec.unit_effectivity_id );

    IF ( l_mr_status = G_MR_STATUS_JOBS_COMPLETE ) THEN

     OPEN Check_child_exists(l_workorder_rec.unit_effectivity_id);
     FETCH Check_child_exists INTO l_dummy;
     IF Check_child_exists%NOTFOUND THEN

    l_mr_rec.unit_effectivity_id := l_workorder_rec.unit_effectivity_id;
    l_mr_rec.ue_object_version_no := l_workorder_rec.ue_object_version_number;

    complete_mr_instance
    (
      p_api_version         => 1.0,
      p_init_msg_list       => FND_API.G_TRUE,
      p_commit              => p_commit,
      p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
      p_default             => FND_API.G_FALSE,
      p_module_type         => NULL,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      p_x_mr_rec            => l_mr_rec
    );

    -- Abort for Unexpected errors, but, continue for other errors.
    IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Could Not Complete MR Instance with UE : ' || TO_CHAR( l_workorder_rec.unit_effectivity_id ) || ' associated to Workorder : ' || TO_CHAR( p_workorder_id ) || ' because of...' );
        FOR I IN 1..l_msg_count LOOP
          FND_MSG_PUB.get
          (
            p_msg_index      => i,
            p_encoded        => FND_API.G_FALSE,
            p_data           => l_msg_data,
            p_msg_index_out  => l_msg_index_out
          );

          AHL_DEBUG_PUB.debug(' Error : ' || I || ': ' || l_msg_data);
        END LOOP;
      END IF;

      -- Initialize message list since errors are not reported
      IF FND_API.to_boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
      END IF;

    ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      x_return_status := l_return_status;
      x_msg_data := l_msg_data;
      x_msg_count := l_msg_count;
      RETURN;
    ELSE
      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Completed MR  Instance with UE : ' || TO_CHAR( l_workorder_rec.unit_effectivity_id ) || ' associated to Workorder : ' || TO_CHAR( p_workorder_id ) || ' Successfuly...' );
      END IF;

      -- Re-set the API savepoint because, complete_mr_instance commits
      IF FND_API.to_boolean( p_commit ) THEN
        SAVEPOINT complete_workorder_PVT;
      END IF;
    END IF;
    END IF; --Child checks
   CLOSE Check_child_exists;
   END IF;
  END IF;

  -- Perform the Commit (if requested)
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Disable debug (if enabled)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO complete_workorder_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO complete_workorder_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN OTHERS THEN
    ROLLBACK TO complete_workorder_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.add_exc_msg
      (
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240)
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;
END complete_workorder;

PROCEDURE defer_workorder
(
  p_api_version       IN    NUMBER     := 1.0,
  p_init_msg_list     IN    VARCHAR2   := FND_API.G_TRUE,
  p_commit            IN    VARCHAR2   := FND_API.G_FALSE,
  p_validation_level  IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default           IN    VARCHAR2   := FND_API.G_FALSE,
  p_module_type       IN    VARCHAR2   := NULL,
  x_return_status     OUT NOCOPY   VARCHAR2,
  x_msg_count         OUT NOCOPY   NUMBER,
  x_msg_data          OUT NOCOPY   VARCHAR2,
  p_workorder_id      IN    NUMBER,
  p_object_version_no IN    NUMBER := NULL
)
IS

l_api_name               VARCHAR2(30) := 'defer_workorder';
l_return_status          VARCHAR2(1);
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(2000) := NULL;

l_workorder_rec          workorder_rec_type;
l_counter_tbl            counter_tbl_type;

BEGIN
  -- Enable Debug (optional)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT defer_workorder_PVT;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Validate all the inputs of the API
  l_return_status :=
  validate_wo_inputs
  (
    p_workorder_id           => p_workorder_id,
    p_object_version_no      => p_object_version_no
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Get the Workorder Details
  l_return_status :=
  get_workorder_rec
  (
    p_workorder_id           => p_workorder_id,
    p_object_version_no      => p_object_version_no,
    x_workorder_rec          => l_workorder_rec
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Validate the Workorder
  l_return_status :=
  validate_dwo_rec
  (
    p_workorder_rec          => l_workorder_rec
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --Complete the EAM Workorder
  l_return_status :=
  complete_eam_workorder
  (
    p_workorder_rec          => l_workorder_rec
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Defer the AHL Workorder
  l_return_status :=
  update_ahl_workorder
  (
    p_workorder_rec            => l_workorder_rec,
    p_status_code              => G_JOB_STATUS_COMPLETE
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_workorder_rec.object_version_number := l_workorder_rec.object_version_number +1;

  --If l_workorder_rec.collection_id is not null, then, Enable and Fire QA Actions
  IF ( l_workorder_rec.collection_id IS NOT NULL ) THEN
    QA_SS_RESULTS.wrapper_fire_action
    (
      q_collection_id    => l_workorder_rec.collection_id,
      q_return_status    => l_return_status,
      q_msg_count        => l_msg_count,
      q_msg_data         => l_msg_data
    );

    IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      x_msg_data := l_msg_data;
      x_msg_count := l_msg_count;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Re-set the API savepoint because, the wrapper_fire_action commits.
    SAVEPOINT defer_workorder_PVT;

  END IF;

  IF ( G_CTR_READING_PLAN_ID IS NOT NULL AND
       l_workorder_rec.item_instance_id IS NOT NULL ) THEN

    -- Get the Current Counter Readings for all Counters associted with
    -- the Item Instance.
    -- Bug # 6784053 (FP for Bug # 6750836) -- start
    l_return_status :=
    get_cp_counters
    (
      p_item_instance_id  => l_workorder_rec.item_instance_id,
      p_wip_entity_id       => l_workorder_rec.wip_entity_id,
      p_actual_date       => l_workorder_rec.actual_end_date,
      x_counter_tbl       => l_counter_tbl
    );
    -- Bug # 6784053 (FP for Bug # 6750836) -- end
    IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF ( l_counter_tbl.COUNT > 0 ) THEN
      l_return_status :=
      record_wo_ctr_readings
      (
        x_msg_data           => l_msg_data,
        x_msg_count          => l_msg_count,
        p_wip_entity_id      => l_workorder_rec.wip_entity_id,
        p_counter_tbl        => l_counter_tbl
      );

      IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Re-set the API savepoint because, Quality Results submission commits
      SAVEPOINT defer_workorder_PVT;
    END IF;
  END IF;

  -- Perform the Commit (if requested)
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Disable debug (if enabled)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO defer_workorder_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO defer_workorder_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN OTHERS THEN
    ROLLBACK TO defer_workorder_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.add_exc_msg
      (
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240)
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

END defer_workorder;

-- Procedure to Complete a FMP / UMP MR Instance
PROCEDURE complete_mr_instance
(
  p_api_version          IN   NUMBER      := 1.0,
  p_init_msg_list        IN   VARCHAR2    := FND_API.G_TRUE,
  p_commit               IN   VARCHAR2    := FND_API.G_FALSE,
  p_validation_level     IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
  p_default              IN   VARCHAR2    := FND_API.G_FALSE,
  p_module_type          IN   VARCHAR2    := NULL,
  x_return_status        OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY  NUMBER,
  x_msg_data             OUT NOCOPY  VARCHAR2,
  p_x_mr_rec             IN OUT NOCOPY  mr_rec_type
)
IS

l_api_name               VARCHAR2(30) := 'complete_mr_instance';
l_return_status          VARCHAR2(1);
l_mwo_return_status      VARCHAR2(1);
l_msg_count              NUMBER;
l_msg_index_out          NUMBER;
l_msg_data               VARCHAR2(2000) := NULL;

l_counter_tbl            counter_tbl_type;
l_reset_counter_tbl      counter_tbl_type;
l_parent_mr_rec          mr_rec_type;

CURSOR  get_parent_mrs( c_unit_effectivity_id NUMBER )
IS
SELECT  UE.unit_effectivity_id unit_effectivity_id,
        UE.object_version_number ue_object_version_number
FROM    AHL_MR_HEADERS_B MR,
        AHL_UNIT_EFFECTIVITIES_B UE,
        AHL_UE_RELATIONSHIPS REL
WHERE   MR.mr_header_id = UE.mr_header_id
AND     MR.auto_signoff_flag = 'Y'
AND     UE.unit_effectivity_id = REL.ue_id
AND     REL.related_ue_id = c_unit_effectivity_id
AND     REL.relationship_code = 'PARENT';

BEGIN
  -- Enable Debug (optional)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT complete_mr_instance_PVT;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Validate all the inputs of the API
  l_return_status :=
  validate_cmri_inputs
  (
    p_mr_rec                 => p_x_mr_rec
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

 -- default missing attributes of the input MR Instance Record
 l_return_status :=
 default_mr_rec
 (
   p_x_mr_rec => p_x_mr_rec
 );

 IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
 ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 IF ( G_DEBUG = 'Y' ) THEN
  AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' Inputs:'  );
  AHL_DEBUG_PUB.debug( 'unit_effectivity_id:'  || p_x_mr_rec.unit_effectivity_id );
  AHL_DEBUG_PUB.debug( 'ue_object_version_no:'  || p_x_mr_rec.ue_object_version_no );
  AHL_DEBUG_PUB.debug( 'item_instance_id:'  || p_x_mr_rec.item_instance_id );
  AHL_DEBUG_PUB.debug( 'mr_header_id:'  || p_x_mr_rec.mr_header_id );
  AHL_DEBUG_PUB.debug( 'incident_id:'  || p_x_mr_rec.incident_id );
  AHL_DEBUG_PUB.debug( 'mr_title:'  || p_x_mr_rec.mr_title );
  AHL_DEBUG_PUB.debug( 'ue_status_code:'  || p_x_mr_rec.ue_status_code );
  AHL_DEBUG_PUB.debug( 'qa_inspection_type:'  || p_x_mr_rec.qa_inspection_type );
  AHL_DEBUG_PUB.debug( 'actual_end_date:'  || p_x_mr_rec.actual_end_date );
  AHL_DEBUG_PUB.debug( 'qa_plan_id:'  || p_x_mr_rec.qa_plan_id );
  AHL_DEBUG_PUB.debug( 'qa_collection_id:'  || p_x_mr_rec.qa_collection_id );
 END IF;

 -- Validate the status to check if the MR/SR status is valid for Sign off
 l_return_status :=
 validate_mr_status
 (
   p_mr_status_code  =>  p_x_mr_rec.ue_status_code,
   p_mr_status    =>  p_x_mr_rec.ue_status,
   p_mr_title    =>  p_x_mr_rec.mr_title
 );

 IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
     RAISE FND_API.G_EXC_ERROR;
 ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

  -- Check if the MR/SR Instance is complete
  l_return_status:=
  is_mr_complete
  (
    p_mr_title             => p_x_mr_rec.mr_title,
    p_status_code          => p_x_mr_rec.ue_status_code,
    p_status               => p_x_mr_rec.ue_status,
    p_qa_inspection_type   => p_x_mr_rec.qa_inspection_type,
    p_qa_plan_id           => p_x_mr_rec.qa_plan_id,
    p_qa_collection_id     => p_x_mr_rec.qa_collection_id
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check if all Child MR Instances are complete
  l_return_status :=
  are_child_mrs_complete
  (
    p_mr_rec    => p_x_mr_rec
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || 'Getting Reset Counters'  );
  END IF;

  -- Get the Reset Counter Readings for all Counters associted with
  -- the MR and the Item Instance.
  IF(p_x_mr_rec.mr_header_id IS NOT NULL)THEN
  l_return_status :=
  get_reset_counters
  (
    p_mr_header_id      => p_x_mr_rec.mr_header_id,
    p_item_instance_id  => p_x_mr_rec.item_instance_id,
    p_actual_date       => p_x_mr_rec.actual_end_date,
    x_counter_tbl       => l_reset_counter_tbl
  );
  END IF;

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF ( l_reset_counter_tbl IS NOT NULL AND l_reset_counter_tbl.COUNT > 0 ) THEN

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || 'Resetting Counters'  );
    END IF;

    -- Reset all the Counters with Reset Values specified in FMP
    l_return_status :=
    reset_counters
    (
      p_mr_rec              => p_x_mr_rec,
      p_x_counter_tbl       => l_reset_counter_tbl,
      p_actual_end_date     => p_x_mr_rec.actual_end_date,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data
    );

    IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      IF ( l_msg_data IS NOT NULL ) THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := l_msg_count;
        x_msg_data := l_msg_data;
        RETURN;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || 'Getting CP Counters'  );
  END IF;

  -- Get the Current Counter Readings for all Counters associted with
  -- the Item Instance.
  -- Bug # 6784053 (FP for Bug # 6750836) -- start
  l_return_status :=
  get_cp_counters
  (
    p_item_instance_id  => p_x_mr_rec.item_instance_id,
    p_wip_entity_id     => null,
    p_actual_date       => p_x_mr_rec.actual_end_date,
    x_counter_tbl       => l_counter_tbl
  );
  -- Bug # 6784053 (FP for Bug # 6750836) -- end
  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

/* Removed for Bug 3310304
  IF ( l_counter_tbl.COUNT > 0 ) THEN
*/

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || 'Updating UMP'  );
  END IF;

  -- Record Accomplishment in UMP for UMP MR Instance
  l_return_status :=
  update_ump
  (
      p_unit_effectivity_id  => p_x_mr_rec.unit_effectivity_id,
      p_ue_object_version    => p_x_mr_rec.ue_object_version_no,
      p_actual_end_date      => p_x_mr_rec.actual_end_date,
      p_counter_tbl          => l_counter_tbl,
      x_msg_count            => l_msg_count,
      x_msg_data             => l_msg_data
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    IF ( l_msg_data IS NOT NULL ) THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
      RETURN;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

/* Removed for Bug 3310304
  END IF;
*/

  -- At this point the UE is ready for Sign off. which means following conditions are
  -- satisfied
  -- 1. All workorders associated to the UE MWO are either complete or cancelled or closed.
  -- 2. All Child UE are in either Signed off or Cancelled or deferred or terminated.
  -- 3. All other workorders in the Hierarchy are either complete or cancelled or closed.
  --
  -- As per the issue # 2 in bug # 4626717 the master workorder has to be completed once
  -- the associated UE is signed off.Putting this code here because this is the logical end
  -- of mr signoff and before parent mr check starts.
  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	fnd_log.string
	(
		fnd_log.level_statement,
		'ahl.plsql.AHL_PRD_COMPLETIONS_PVT.complete_mr_instance',
		'p_x_mr_rec.unit_effectivity_id : ' || p_x_mr_rec.unit_effectivity_id
	);
  END IF;

  l_mwo_return_status := complete_master_wo(
	 p_visit_id	=>	null,
	 p_workorder_id	=>	null,
	 p_ue_id	=>	p_x_mr_rec.unit_effectivity_id
  );

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	fnd_log.string
	(
		fnd_log.level_statement,
		'ahl.plsql.AHL_PRD_COMPLETIONS_PVT.complete_mr_instance',
		'return status after calling complete_master_wo: ' || l_mwo_return_status
	);
  END IF;

  IF l_mwo_return_status = FND_API.G_RET_STS_ERROR THEN
  	RAISE FND_API.G_EXC_ERROR;
  ELSIF l_mwo_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
  	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Additional logic added in 11.5.10 for QA Collection
  IF ( p_x_mr_rec.qa_collection_id IS NOT NULL AND
       FND_API.to_boolean( p_commit ) ) THEN

    QA_SS_RESULTS.wrapper_fire_action
    (
      q_collection_id => p_x_mr_rec.qa_collection_id,
      q_return_status => l_return_status,
      q_msg_count     => l_msg_count,
      q_msg_data      => l_msg_data
    );

    IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_QA_ACTION_ERROR' );
      FND_MESSAGE.set_token( 'MAINT_REQ', p_x_mr_rec.mr_title);
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Re-establish the save point because the QA API Commits
    IF FND_API.to_boolean( p_commit ) THEN
      SAVEPOINT complete_mr_instance_PVT;
    END IF;

  END IF;

  -- Get Parent MRs which require automatic Signoff
  FOR parent_csr IN get_parent_mrs( p_x_mr_rec.unit_effectivity_id ) LOOP

    -- Attempt to complete the parent MR Instance ( Ignore Errors )
    l_parent_mr_rec.unit_effectivity_id := parent_csr.unit_effectivity_id;
    l_parent_mr_rec.ue_object_version_no := parent_csr.ue_object_version_number;

    complete_mr_instance
    (
      p_api_version         => 1.0,
      p_init_msg_list       => FND_API.G_TRUE,
      p_commit              => p_commit,
      p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
      p_default             => FND_API.G_FALSE,
      p_module_type         => NULL,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      p_x_mr_rec            => l_parent_mr_rec
    );

    -- Abort for Unexpected errors, but, continue for other errors.
    IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
        ||' : Could Not Complete Parent MR Instance with UE : '
        ||TO_CHAR( parent_csr.unit_effectivity_id )
        || ' associated to UE : ' || TO_CHAR( p_x_mr_rec.unit_effectivity_id )
        || ' because of...' );
        FOR I IN 1..l_msg_count LOOP
          FND_MSG_PUB.get
          (
            p_msg_index      => i,
            p_encoded        => FND_API.G_FALSE,
            p_data           => l_msg_data,
            p_msg_index_out  => l_msg_index_out
          );

          AHL_DEBUG_PUB.debug(' Error : ' || I || ': ' || l_msg_data);
        END LOOP;
      END IF;

      -- Initialize message list since errors are not reported
      IF FND_API.to_boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
      END IF;

    ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      x_return_status := l_return_status;
      x_msg_data := l_msg_data;
      x_msg_count := l_msg_count;
      RETURN;
    ELSE
      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Completed MR  Instance with UE : ' || TO_CHAR( parent_csr.unit_effectivity_id ) || ' associated to UE : ' || TO_CHAR( p_x_mr_rec.unit_effectivity_id ) || ' Successfuly...' );
      END IF;

      -- Re-establish the save point because the complete_mr_instance Commits
      IF FND_API.to_boolean( p_commit ) THEN
        SAVEPOINT complete_mr_instance_PVT;
      END IF;

    END IF;
  END LOOP;

  -- Perform the Commit (if requested)
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Disable debug (if enabled)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO complete_mr_instance_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO complete_mr_instance_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN OTHERS THEN
    ROLLBACK TO complete_mr_instance_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.add_exc_msg
      (
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240)
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;
END complete_mr_instance;

-- Function added in 11.5.10 for getting the status of an MR instance.
FUNCTION get_mr_status
(
   p_unit_effectivity_id  IN NUMBER
) RETURN VARCHAR2

IS
  l_mr_status_code VARCHAR2(30);
  --l_mr_status_count NUMBER := 0;
  l_job_status_complete BOOLEAN := FALSE;
  l_job_status_qa_pending BOOLEAN := FALSE;
  l_job_status_on_hold BOOLEAN := FALSE;
  l_job_status_released BOOLEAN := FALSE;
  l_job_status_cancelled BOOLEAN := FALSE;
  l_job_status_unreleased BOOLEAN := FALSE;

/* CURSOR get_mr_status_ue(c_unit_effectivity_id NUMBER) IS
  SELECT UE.ump_status_code
  FROM AHL_UE_DEFERRAL_DETAILS_V UE
  WHERE UE.unit_effectivity_id = c_unit_effectivity_id;

  CURSOR get_mr_status_wo(c_unit_effectivity_id NUMBER) IS
  SELECT DISTINCT DECODE( WO.status_code,
                          G_JOB_STATUS_CLOSED, G_JOB_STATUS_COMPLETE,
                          G_JOB_STATUS_COMPLETE_NC, G_JOB_STATUS_COMPLETE,
                          G_JOB_STATUS_PARTS_HOLD, G_JOB_STATUS_ON_HOLD,
                          G_JOB_STATUS_DEFERRAL_PENDING,G_JOB_STATUS_ON_HOLD,
                          WO.status_code ) status_code
  FROM  AHL_WORKORDERS WO,
        AHL_VISIT_TASKS_B VT
  WHERE WO.visit_task_id = VT.visit_task_id
  AND   WO.status_code <> G_JOB_STATUS_DELETED
  AND   WO.master_workorder_flag = 'N'
  AND   VT.unit_effectivity_id = c_unit_effectivity_id;
*/

  -- Balaji made following change for checking wip completion dates for
  -- differentiating workorders which are cancelled and then closed from
  -- those workorders which are completed and closed.
  -- For MR status derivation cancelled closed should be considered as cacelled
  -- and completion followed by closure should be considered as complete.

  -- Changed to consider Child MR Jobs statuses for Bug 3406703
  /*  CURSOR get_mr_status_wo(c_unit_effectivity_id NUMBER) IS
    SELECT DISTINCT DECODE( CWO.status_code,
                            G_JOB_STATUS_CLOSED, decode(WIPJ.date_completed, null, G_JOB_STATUS_CANCELLED, G_JOB_STATUS_COMPLETE),
                            G_JOB_STATUS_COMPLETE_NC, G_JOB_STATUS_COMPLETE,
                            G_JOB_STATUS_PARTS_HOLD, G_JOB_STATUS_ON_HOLD,
                            G_JOB_STATUS_DEFERRAL_PENDING,G_JOB_STATUS_ON_HOLD,
                            CWO.status_code ) status_code
    FROM   AHL_WORKORDERS CWO, ahl_visit_tasks_b vst, wip_discrete_jobs WIPJ
    where CWO.visit_task_id = vst.visit_task_id
    AND vst.unit_effectivity_id = c_unit_effectivity_id
    AND CWO.master_workorder_flag = 'N'
    AND CWO.wip_entity_id in (SELECT REL.child_object_id
                              from WIP_SCHED_RELATIONSHIPS REL
    START WITH      REL.parent_object_id IN
                    (
                       SELECT PWO.wip_entity_id
                       FROM   AHL_WORKORDERS PWO,
                              AHL_VISIT_TASKS_B VT,
                              AHL_VISITS_B VS
                       WHERE  PWO.master_workorder_flag = 'Y'
                       AND    PWO.visit_task_id = VT.visit_task_id
                       AND    VS.VISIT_ID = VT.VISIT_ID
                       AND    VS.STATUS_CODE NOT IN ('CLOSED','CANCELLED')
                       AND    VT.unit_effectivity_id = c_unit_effectivity_id
                    )
                    AND             REL.parent_object_type_id = 1
                    AND             REL.relationship_type = 1
    CONNECT BY      REL.parent_object_id = PRIOR REL.child_object_id
    AND             REL.parent_object_type_id = PRIOR REL.child_object_type_id
    AND             REL.relationship_type = 1
  )
  AND WIPJ.wip_entity_id = CWO.wip_entity_id;*/

  -- this cursor will be used when
		-- 1. ue status is null
		-- 2. this is an unassociated task created as a result of
		-- SR creation from Production
  -- Balaji made following change for checking wip completion dates for
  -- differentiating workorders which are cancelled and then closed from
  -- those workorders which are completed and closed.
  -- For MR status derivation cancelled closed should be considered as cacelled
  -- and completion followed by closure should be considered as complete.

  /*CURSOR get_status_unassoc(c_unit_effectivity_id NUMBER) IS
		SELECT  DISTINCT DECODE( CWO.status_code,
                            G_JOB_STATUS_CLOSED, decode(WIPJ.date_completed, null, G_JOB_STATUS_CANCELLED, G_JOB_STATUS_COMPLETE),
                            G_JOB_STATUS_COMPLETE_NC, G_JOB_STATUS_COMPLETE,
                            G_JOB_STATUS_PARTS_HOLD, G_JOB_STATUS_ON_HOLD,
                            G_JOB_STATUS_DEFERRAL_PENDING,G_JOB_STATUS_ON_HOLD,
                            CWO.status_code ) status_code
  FROM   AHL_WORKORDERS CWO, ahl_visit_tasks_b vst, wip_discrete_jobs WIPJ
  where CWO.visit_task_id = vst.visit_task_id
  AND vst.unit_effectivity_id = c_unit_effectivity_id
		AND vst.task_type_code = 'UNASSOCIATED'
  AND WIPJ.wip_entity_id = CWO.wip_entity_id; */

		-- bug 4087041
		-- this bug takes care of the case of
		-- signing of sr with mrs and group mrs
  -- Balaji made following change for checking wip completion dates for
  -- differentiating workorders which are cancelled and then closed from
  -- those workorders which are completed and closed.
  -- For MR status derivation cancelled closed should be considered as cacelled
  -- and completion followed by closure should be considered as complete.

  /*CURSOR get_status_top_level_sr(c_unit_effectivity_id NUMBER) IS
  SELECT DISTINCT DECODE( CWO.status_code,
                            G_JOB_STATUS_CLOSED, decode(WIPJ.date_completed, null, G_JOB_STATUS_CANCELLED, G_JOB_STATUS_COMPLETE),
                            G_JOB_STATUS_COMPLETE_NC, G_JOB_STATUS_COMPLETE,
                            G_JOB_STATUS_PARTS_HOLD, G_JOB_STATUS_ON_HOLD,
                            G_JOB_STATUS_DEFERRAL_PENDING,G_JOB_STATUS_ON_HOLD,
                            CWO.status_code ) status_code
    FROM   AHL_WORKORDERS CWO, ahl_visit_tasks_b vst, wip_discrete_jobs WIPJ
    where CWO.visit_task_id = vst.visit_task_id
    --AND vst.unit_effectivity_id = c_unit_effectivity_id
    AND CWO.master_workorder_flag = 'N'
    AND CWO.wip_entity_id in (SELECT REL.child_object_id
                              from WIP_SCHED_RELATIONSHIPS REL
    START WITH      REL.parent_object_id IN
                    (
                       SELECT PWO.wip_entity_id
                       FROM   AHL_WORKORDERS PWO,
                              AHL_VISIT_TASKS_B VT,
                              AHL_VISITS_B VS
                       WHERE  PWO.master_workorder_flag = 'Y'
                       AND    PWO.visit_task_id = VT.visit_task_id
                       AND    VS.VISIT_ID = VT.VISIT_ID
                       AND    VS.STATUS_CODE NOT IN ('CLOSED','CANCELLED')
                       AND    VT.unit_effectivity_id = c_unit_effectivity_id
                    )
                    AND             REL.parent_object_type_id = 1
                    AND             REL.relationship_type = 1
    CONNECT BY      REL.parent_object_id = PRIOR REL.child_object_id
    AND             REL.parent_object_type_id = PRIOR REL.child_object_type_id
    AND             REL.relationship_type = 1
  )
  AND WIPJ.wip_entity_id = CWO.wip_entity_id;*/

  --to check released/unpleased/qa-pending
  --to check released/unpleased/qa-pending
  CURSOR get_mr_status_csr(c_unit_effectivity_id NUMBER,p_status_code VARCHAR2) IS
  SELECT
    CWO.status_code
    FROM   AHL_WORKORDERS CWO, ahl_visit_tasks_b vst
    where CWO.visit_task_id = vst.visit_task_id
    AND CWO.master_workorder_flag = 'N'
    AND CWO.status_code IN (p_status_code)
    AND vst.unit_effectivity_id IN (select related_ue_id
                                    from ahl_ue_relationships
                                    start with ue_id = c_unit_effectivity_id
                                    AND relationship_code = 'PARENT'
                                    connect by prior related_ue_id = ue_id
                                    AND relationship_code = 'PARENT'
                                    union all
                                    select c_unit_effectivity_id
                                    from dual)
   AND rownum < 2;

  CURSOR is_mr_on_hold_csr(c_unit_effectivity_id NUMBER) IS
  SELECT
    CWO.status_code
    FROM   AHL_WORKORDERS CWO, ahl_visit_tasks_b vst
    where CWO.visit_task_id = vst.visit_task_id
    AND CWO.master_workorder_flag = 'N'
    AND CWO.status_code IN (G_JOB_STATUS_PARTS_HOLD, G_JOB_STATUS_ON_HOLD,
                            G_JOB_STATUS_DEFERRAL_PENDING)
    AND vst.unit_effectivity_id IN (select related_ue_id
                                    from ahl_ue_relationships
                                    start with ue_id = c_unit_effectivity_id
                                    AND relationship_code = 'PARENT'
                                    connect by prior related_ue_id = ue_id
                                    AND relationship_code = 'PARENT'
                                    union all
                                    select c_unit_effectivity_id
                                    from dual)
   AND rownum < 2;

  CURSOR is_mr_complete_csr(c_unit_effectivity_id NUMBER) IS
  SELECT
    CWO.status_code
    FROM   AHL_WORKORDERS CWO, ahl_visit_tasks_b vst, wip_discrete_jobs wipj
    where CWO.visit_task_id = vst.visit_task_id
    AND WIPJ.wip_entity_id = CWO.wip_entity_id
    AND CWO.master_workorder_flag = 'N'
    AND CWO.status_code IN (G_JOB_STATUS_CLOSED, G_JOB_STATUS_COMPLETE_NC, G_JOB_STATUS_COMPLETE)
    AND WIPJ.date_completed IS NOT NULL
    AND vst.unit_effectivity_id IN (select related_ue_id
                                    from ahl_ue_relationships
                                    start with ue_id = c_unit_effectivity_id
                                    AND relationship_code = 'PARENT'
                                    connect by prior related_ue_id = ue_id
                                    AND relationship_code = 'PARENT'
                                    union all
                                    select c_unit_effectivity_id
                                    from dual)
   AND rownum < 2;

  CURSOR is_mr_cancelled_csr(c_unit_effectivity_id NUMBER) IS
  SELECT
    CWO.status_code
    FROM   AHL_WORKORDERS CWO, ahl_visit_tasks_b vst, wip_discrete_jobs wipj
    where CWO.visit_task_id = vst.visit_task_id
    AND WIPJ.wip_entity_id = CWO.wip_entity_id
    --AND vst.unit_effectivity_id = c_unit_effectivity_id
    AND CWO.master_workorder_flag = 'N'
    AND CWO.status_code IN (G_JOB_STATUS_CLOSED, G_JOB_STATUS_CANCELLED)
    AND WIPJ.date_completed IS NULL
    AND vst.unit_effectivity_id IN (select related_ue_id
                                    from ahl_ue_relationships
                                    start with ue_id = c_unit_effectivity_id
                                    AND relationship_code = 'PARENT'
                                    connect by prior related_ue_id = ue_id
                                    AND relationship_code = 'PARENT'
                                    union all
                                    select c_unit_effectivity_id
                                    from dual)
   AND rownum < 2;

BEGIN

   IF ( p_unit_effectivity_id IS NULL OR
        p_unit_effectivity_id = FND_API.G_MISS_NUM ) THEN
     RETURN NULL;
   END IF;

   -- check unit effectivity status first
   /*OPEN get_mr_status_ue(p_unit_effectivity_id);

   FETCH get_mr_status_ue INTO l_mr_status_code;

   IF (l_mr_status_code = G_MR_STATUS_SIGNED_OFF) THEN
     CLOSE get_mr_status_ue;
     RETURN G_MR_STATUS_SIGNED_OFF;
   ELSIF (l_mr_status_code = G_MR_STATUS_DEFERRED) THEN
     CLOSE get_mr_status_ue;
     RETURN G_MR_STATUS_DEFERRED;
   ELSIF (l_mr_status_code = G_MR_STATUS_TERMINATED) THEN
     CLOSE get_mr_status_ue;
     RETURN G_MR_STATUS_TERMINATED;
   ELSIF (l_mr_status_code = G_MR_STATUS_CANCELLED) THEN
     CLOSE get_mr_status_ue;
     RETURN G_MR_STATUS_CANCELLED;
   ELSIF (l_mr_status_code = G_MR_STATUS_DEFERRAL_PENDING) THEN
     CLOSE get_mr_status_ue;
     RETURN G_MR_STATUS_DEFERRAL_PENDING;
   END IF;

   CLOSE get_mr_status_ue; */

   l_mr_status_code := get_ue_mr_status_code(p_unit_effectivity_id);
   IF l_mr_status_code IN (G_MR_STATUS_SIGNED_OFF,G_MR_STATUS_DEFERRED,
      G_MR_STATUS_TERMINATED,G_MR_STATUS_CANCELLED,G_MR_STATUS_DEFERRAL_PENDING,G_MR_STATUS_MR_TERMINATED)THEN
      RETURN l_mr_status_code;
   END IF;

   OPEN get_mr_status_csr(p_unit_effectivity_id, G_JOB_STATUS_QA_PENDING);
   FETCH get_mr_status_csr INTO l_mr_status_code;
   IF(get_mr_status_csr%FOUND)THEN
     CLOSE get_mr_status_csr;
     RETURN G_MR_STATUS_INSP_NEEDED;
   END IF;
   CLOSE get_mr_status_csr;

   OPEN is_mr_on_hold_csr(p_unit_effectivity_id);
   FETCH is_mr_on_hold_csr INTO l_mr_status_code;
   IF(is_mr_on_hold_csr%FOUND)THEN
     CLOSE is_mr_on_hold_csr;
     RETURN G_MR_STATUS_JOBS_ON_HOLD;
   END IF;
   CLOSE is_mr_on_hold_csr;

   OPEN get_mr_status_csr(p_unit_effectivity_id, G_JOB_STATUS_RELEASED);
   FETCH get_mr_status_csr INTO l_mr_status_code;
   IF(get_mr_status_csr%FOUND)THEN
     CLOSE get_mr_status_csr;
     RETURN G_MR_STATUS_RELEASED;
   END IF;
   CLOSE get_mr_status_csr;

   OPEN get_mr_status_csr(p_unit_effectivity_id, G_JOB_STATUS_UNRELEASED);
   FETCH get_mr_status_csr INTO l_mr_status_code;
   IF(get_mr_status_csr%FOUND)THEN
     l_job_status_unreleased := TRUE;
     --CLOSE get_mr_status_csr;
     --RETURN G_MR_STATUS_UNRELEASED;
   END IF;
   CLOSE get_mr_status_csr;

   OPEN is_mr_complete_csr(p_unit_effectivity_id);
   FETCH is_mr_complete_csr INTO l_mr_status_code;
   IF(is_mr_complete_csr%FOUND)THEN
     l_job_status_complete := TRUE;
     --CLOSE is_mr_complete_csr;
     --RETURN G_MR_STATUS_JOBS_COMPLETE;
   END IF;
   CLOSE is_mr_complete_csr;

   IF(l_job_status_unreleased AND l_job_status_complete)THEN
      RETURN G_MR_STATUS_RELEASED;
   END IF;

   OPEN is_mr_cancelled_csr(p_unit_effectivity_id);
   FETCH is_mr_cancelled_csr INTO l_mr_status_code;
   IF(is_mr_cancelled_csr%FOUND)THEN
     l_job_status_cancelled := TRUE;
     --CLOSE is_mr_cancelled_csr;
     --RETURN G_MR_STATUS_JOBS_CANCELLED;
   END IF;
   CLOSE is_mr_cancelled_csr;

   IF(l_job_status_unreleased AND l_job_status_cancelled)THEN
      RETURN G_MR_STATUS_RELEASED;
   END IF;

   IF(NOT l_job_status_unreleased) THEN
      IF(l_job_status_complete) THEN
        RETURN G_MR_STATUS_JOBS_COMPLETE;
      ELSIF(l_job_status_cancelled) THEN
        RETURN G_MR_STATUS_JOBS_CANCELLED;
      END IF;
   ELSE
      RETURN G_MR_STATUS_UNRELEASED;
   END IF;
   RETURN G_MR_STATUS_UNRELEASED;

   /*FOR l_mr_status_rec IN get_mr_status_wo(p_unit_effectivity_id) LOOP
     l_mr_status_code := l_mr_status_rec.status_code;

     IF (l_mr_status_code = G_JOB_STATUS_QA_PENDING) THEN
       l_job_status_qa_pending := TRUE;
     ELSIF (l_mr_status_code = G_JOB_STATUS_ON_HOLD) THEN
       l_job_status_on_hold := TRUE;
     ELSIF (l_mr_status_code = G_JOB_STATUS_RELEASED) THEN
       l_job_status_released := TRUE;
     ELSIF (l_mr_status_code = G_JOB_STATUS_CANCELLED) THEN
       l_job_status_cancelled := TRUE;
     ELSIF (l_mr_status_code = G_JOB_STATUS_COMPLETE) THEN
       l_job_status_complete := TRUE;
     ELSIF (l_mr_status_code = G_JOB_STATUS_UNRELEASED) THEN
       l_job_status_unreleased := TRUE;
     END IF;

     l_mr_status_count := l_mr_status_count + 1;
  END LOOP;

  IF(l_mr_status_count <> 0) THEN
  		IF ( l_mr_status_count = 1 ) THEN
    		IF ( l_job_status_qa_pending = TRUE ) THEN
      		RETURN G_MR_STATUS_INSP_NEEDED;
    		ELSIF (l_job_status_complete = TRUE ) THEN
      		RETURN G_MR_STATUS_JOBS_COMPLETE;
   		 ELSIF (l_job_status_released = TRUE ) THEN
      		RETURN G_MR_STATUS_RELEASED;
    		ELSIF (l_job_status_unreleased = TRUE ) THEN
      		RETURN G_MR_STATUS_UNRELEASED;
   		 ELSIF (l_job_status_cancelled = TRUE ) THEN
      		RETURN G_MR_STATUS_JOBS_CANCELLED;
    		ELSIF (l_job_status_on_hold = TRUE ) THEN
      		RETURN G_MR_STATUS_JOBS_ON_HOLD;
    		ELSE
      		-- Default return status if no match found.
     		 RETURN G_MR_STATUS_RELEASED;
    		END IF;
 		 END IF;

  		IF ( l_job_status_qa_pending = TRUE ) THEN
    		RETURN G_MR_STATUS_INSP_NEEDED;
  		ELSIF ( l_job_status_on_hold = TRUE ) THEN
    		RETURN G_MR_STATUS_JOBS_ON_HOLD;
  		ELSIF ( l_job_status_released = TRUE ) THEN
    		RETURN G_MR_STATUS_RELEASED;
 		 ELSIF ( l_job_status_unreleased = FALSE AND
          l_job_status_complete = TRUE AND
          l_job_status_cancelled = TRUE ) THEN
    		RETURN G_MR_STATUS_JOBS_COMPLETE;
  		ELSE
    		-- Default return status if no match found.
    		RETURN G_MR_STATUS_RELEASED;
 		 END IF;
		ELSE -- l_mr_status_count == 0
		  OPEN get_status_unassoc(p_unit_effectivity_id);
				FETCH get_status_unassoc INTO l_mr_status_code;
				CLOSE get_status_unassoc;

					IF (l_mr_status_code = G_JOB_STATUS_QA_PENDING) THEN
       RETURN G_MR_STATUS_INSP_NEEDED;
     ELSIF (l_mr_status_code = G_JOB_STATUS_COMPLETE) THEN
       RETURN G_MR_STATUS_JOBS_COMPLETE;
     ELSIF (l_mr_status_code = G_JOB_STATUS_RELEASED) THEN
       	RETURN G_MR_STATUS_RELEASED;
					ELSIF (l_mr_status_code = G_JOB_STATUS_UNRELEASED) THEN
       	RETURN G_MR_STATUS_UNRELEASED;
     ELSIF (l_mr_status_code = G_JOB_STATUS_CANCELLED) THEN
       	RETURN G_MR_STATUS_JOBS_CANCELLED;
     ELSIF (l_mr_status_code = G_JOB_STATUS_ON_HOLD) THEN
       RETURN G_MR_STATUS_JOBS_ON_HOLD;
					ELSE
					   OPEN get_status_top_level_sr(p_unit_effectivity_id);
        FETCH  get_status_top_level_sr INTO l_mr_status_code;
								CLOSE get_status_top_level_sr;
								IF (l_mr_status_code = G_JOB_STATUS_QA_PENDING) THEN
       RETURN G_MR_STATUS_INSP_NEEDED;
     ELSIF (l_mr_status_code = G_JOB_STATUS_COMPLETE) THEN
       RETURN G_MR_STATUS_JOBS_COMPLETE;
     ELSIF (l_mr_status_code = G_JOB_STATUS_RELEASED) THEN
       	RETURN G_MR_STATUS_RELEASED;
					ELSIF (l_mr_status_code = G_JOB_STATUS_UNRELEASED) THEN
       	RETURN G_MR_STATUS_UNRELEASED;
     ELSIF (l_mr_status_code = G_JOB_STATUS_CANCELLED) THEN
       	RETURN G_MR_STATUS_JOBS_CANCELLED;
     ELSIF (l_mr_status_code = G_JOB_STATUS_ON_HOLD) THEN
       RETURN G_MR_STATUS_JOBS_ON_HOLD;
					ELSE


     			-- Default return status if no match found.
     		 RETURN G_MR_STATUS_RELEASED;
					END IF;
     END IF;
   END IF;*/

END get_mr_status;
-- Function to validate the Inputs of the signoff_mr_instance API
FUNCTION validate_smri_inputs
(
  p_signoff_mr_rec          IN   signoff_mr_rec_type
) RETURN VARCHAR2
IS

BEGIN

  IF ( p_signoff_mr_rec.unit_effectivity_id = FND_API.G_MISS_NUM OR
       p_signoff_mr_rec.unit_effectivity_id IS NULL OR
       p_signoff_mr_rec.object_version_number = FND_API.G_MISS_NUM OR
       p_signoff_mr_rec.object_version_number IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_INVALID_SMRI_INPUTS' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

  IF ( p_signoff_mr_rec.signoff_child_mrs_flag IS NULL OR
       p_signoff_mr_rec.signoff_child_mrs_flag = FND_API.G_MISS_CHAR OR
       ( p_signoff_mr_rec.signoff_child_mrs_flag <> 'Y' AND
         p_signoff_mr_rec.signoff_child_mrs_flag <> 'N' ) ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_SIGNOFF_CHILD_MR_FLAG' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

  IF ( p_signoff_mr_rec.complete_job_ops_flag IS NULL OR
       p_signoff_mr_rec.complete_job_ops_flag = FND_API.G_MISS_CHAR OR
       ( p_signoff_mr_rec.complete_job_ops_flag <> 'Y' AND
         p_signoff_mr_rec.complete_job_ops_flag <> 'N' ) ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_CMPL_JOB_OPS_FLAG' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

  IF ( p_signoff_mr_rec.transact_resource_flag IS NULL OR
       p_signoff_mr_rec.transact_resource_flag = FND_API.G_MISS_CHAR OR
       ( p_signoff_mr_rec.transact_resource_flag <> 'Y' AND
         p_signoff_mr_rec.transact_resource_flag <> 'N' ) ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_TRANSACT_RES_FLAG' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

  IF ( p_signoff_mr_rec.complete_job_ops_flag = 'Y' AND
       ( p_signoff_mr_rec.default_actual_dates_flag IS NULL OR
         p_signoff_mr_rec.default_actual_dates_flag = FND_API.G_MISS_CHAR OR
         ( p_signoff_mr_rec.default_actual_dates_flag <> 'Y' AND
           p_signoff_mr_rec.default_actual_dates_flag <> 'N' ) ) ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_DEFAULT_ACT_DTS_FLAG' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

  IF ( p_signoff_mr_rec.transact_resource_flag = 'Y' AND
       ( p_signoff_mr_rec.employee_number IS NULL OR
         p_signoff_mr_rec.employee_number = FND_API.G_MISS_CHAR ) AND
       ( p_signoff_mr_rec.serial_number IS NULL OR
         p_signoff_mr_rec.serial_number = FND_API.G_MISS_CHAR ) ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_TRANSACT_RES_INPUTS' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

  IF ( p_signoff_mr_rec.complete_job_ops_flag = 'Y' AND
       p_signoff_mr_rec.default_actual_dates_flag = 'N' AND
       ( p_signoff_mr_rec.actual_start_date IS NULL OR
         p_signoff_mr_rec.actual_start_date = FND_API.G_MISS_DATE OR
         p_signoff_mr_rec.actual_end_date IS NULL OR
         p_signoff_mr_rec.actual_end_date = FND_API.G_MISS_DATE ) ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_ACTUAL_DTS_MISSING' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

  IF ( p_signoff_mr_rec.complete_job_ops_flag = 'Y' AND
       p_signoff_mr_rec.default_actual_dates_flag = 'N' AND
       p_signoff_mr_rec.actual_end_date < p_signoff_mr_rec.actual_start_date ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_ST_DT_END_DT' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

  IF ( p_signoff_mr_rec.complete_job_ops_flag = 'Y' AND
       p_signoff_mr_rec.default_actual_dates_flag = 'N' AND
       p_signoff_mr_rec.actual_end_date > SYSDATE ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_END_DT_SYSDATE' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;
END validate_smri_inputs;

-- Function to validate the Inputs of the close_visit API
FUNCTION validate_cv_inputs
(
  p_close_visit_rec          IN   close_visit_rec_type
) RETURN VARCHAR2
IS
-- rroy
-- ACL Changes
CURSOR get_Wo_details(c_visit_id NUMBER)
IS
SELECT workorder_id,
workorder_name
FROM AHL_WORKORDERS
WHERE visit_id = c_visit_id
AND MASTER_WORKORDER_FLAG = 'N';

CURSOR get_ue_title(p_workorder_id NUMBER)
IS
SELECT
    UE.title
FROM
    ahl_workorders WO,
    ahl_visit_tasks_b VTSK,
    ahl_unit_effectivities_v UE
WHERE
    WO.workorder_id = p_workorder_id
		AND VTSK.visit_task_id = WO.visit_task_id
		AND UE.unit_effectivity_id = VTSK.unit_effectivity_id;
l_return_status VARCHAR2(1);
l_ue_title      VARCHAR2(80);
-- rroy
-- ACL Changes

BEGIN

  IF ( p_close_visit_rec.visit_id = FND_API.G_MISS_NUM OR
       p_close_visit_rec.visit_id IS NULL OR
       p_close_visit_rec.object_version_number = FND_API.G_MISS_NUM OR
       p_close_visit_rec.object_version_number IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_INVALID_CV_INPUTS' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

		-- rroy
		-- ACL Changes
		FOR wo_details IN get_wo_Details(p_close_visit_rec.visit_id) LOOP
				l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(wo_details.workorder_id, NULL, NULL, NULL);
				IF l_return_status = FND_API.G_TRUE THEN
						OPEN get_ue_title(wo_details.workorder_id);
						FETCH get_ue_title INTO l_ue_title;
						CLOSE get_ue_title;
						FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_CV_UNTLCKD');
						FND_MESSAGE.Set_Token('MR_TITLE', l_ue_title);
						FND_MSG_PUB.ADD;
						RETURN FND_API.G_RET_STS_ERROR;
				END IF;
		END LOOP;
		-- rroy
		-- ACL Changes


  IF ( p_close_visit_rec.signoff_mrs_flag IS NULL OR
       p_close_visit_rec.signoff_mrs_flag = FND_API.G_MISS_CHAR OR
       ( p_close_visit_rec.signoff_mrs_flag <> 'Y' AND
         p_close_visit_rec.signoff_mrs_flag <> 'N' ) ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_SIGNOFF_CHILD_MR_FLAG' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

  IF ( p_close_visit_rec.complete_job_ops_flag IS NULL OR
       p_close_visit_rec.complete_job_ops_flag = FND_API.G_MISS_CHAR OR
       ( p_close_visit_rec.complete_job_ops_flag <> 'Y' AND
         p_close_visit_rec.complete_job_ops_flag <> 'N' ) ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_CMPL_JOB_OPS_FLAG' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

  IF ( p_close_visit_rec.transact_resource_flag IS NULL OR
       p_close_visit_rec.transact_resource_flag = FND_API.G_MISS_CHAR OR
       ( p_close_visit_rec.transact_resource_flag <> 'Y' AND
         p_close_visit_rec.transact_resource_flag <> 'N' ) ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_TRANSACT_RES_FLAG' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

  IF ( p_close_visit_rec.complete_job_ops_flag = 'Y' AND
       ( p_close_visit_rec.default_actual_dates_flag IS NULL OR
         p_close_visit_rec.default_actual_dates_flag = FND_API.G_MISS_CHAR OR
         ( p_close_visit_rec.default_actual_dates_flag <> 'Y' AND
           p_close_visit_rec.default_actual_dates_flag <> 'N' ) ) ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_DEFAULT_ACT_DTS_FLAG' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

  IF ( p_close_visit_rec.transact_resource_flag = 'Y' AND
       ( p_close_visit_rec.employee_number IS NULL OR
         p_close_visit_rec.employee_number = FND_API.G_MISS_CHAR ) AND
       ( p_close_visit_rec.serial_number IS NULL OR
         p_close_visit_rec.serial_number = FND_API.G_MISS_CHAR ) ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_TRANSACT_RES_INPUTS' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

  IF ( p_close_visit_rec.complete_job_ops_flag = 'Y' AND
       p_close_visit_rec.default_actual_dates_flag = 'N' AND
       ( p_close_visit_rec.actual_start_date IS NULL OR
         p_close_visit_rec.actual_start_date = FND_API.G_MISS_DATE OR
         p_close_visit_rec.actual_end_date IS NULL OR
         p_close_visit_rec.actual_end_date = FND_API.G_MISS_DATE ) ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_ACTUAL_DTS_MISSING' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

  IF ( p_close_visit_rec.complete_job_ops_flag = 'Y' AND
       p_close_visit_rec.default_actual_dates_flag = 'N' AND
       p_close_visit_rec.actual_end_date < p_close_visit_rec.actual_start_date ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_ST_DT_END_DT' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

  IF ( p_close_visit_rec.complete_job_ops_flag = 'Y' AND
       p_close_visit_rec.default_actual_dates_flag = 'N' AND
       p_close_visit_rec.actual_end_date > SYSDATE ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_END_DT_SYSDATE' );
    FND_MSG_PUB.add;
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;
END validate_cv_inputs;

FUNCTION update_mwo_actual_dates
(
  p_wip_entity_id     IN NUMBER,
  p_default_flag      IN VARCHAR2,
  p_actual_start_date IN DATE,
  p_actual_end_date   IN DATE
) RETURN VARCHAR2
IS

-- To get the Child Workorder Details for a Master WO
CURSOR     get_child_wos( c_wip_entity_id NUMBER ) IS
SELECT     CWO.workorder_id workorder_id,
           CWO.object_version_number object_version_number,
           CWO.workorder_name workorder_name,
           CWO.wip_entity_id wip_entity_id,
           REL.parent_object_id parent_object_id,
           CWO.actual_start_date actual_start_date,
           CWO.actual_end_date actual_end_date,
           CWO.status_code status_code,
           CWO.master_workorder_flag master_workorder_flag
FROM       AHL_WORKORDERS CWO,
           WIP_SCHED_RELATIONSHIPS REL
WHERE      CWO.wip_entity_id = REL.child_object_id
AND        CWO.status_code <> G_JOB_STATUS_DELETED
AND        REL.parent_object_type_id = 1
AND        REL.child_object_type_id = 1
START WITH REL.parent_object_id = c_wip_entity_id
AND        REL.relationship_type = 1
CONNECT BY REL.parent_object_id = PRIOR REL.child_object_id
AND        REL.relationship_type = 1
ORDER BY   level DESC;


TYPE child_wo_rec_type IS RECORD
(
  parent_object_id           NUMBER,
  actual_start_date          DATE,
  actual_end_date            DATE

);

TYPE child_wo_tbl_type IS TABLE OF child_wo_rec_type INDEX BY BINARY_INTEGER;

l_workorder_tbl     child_wo_tbl_type;
l_ctr               NUMBER := 0;

l_api_name               VARCHAR2(30) := 'update_mwo_actual_dates';
l_min               DATE;
l_max               DATE;

BEGIN

  -- Get the Child Workorders for the Visit
  FOR wo_csr IN get_child_wos( p_wip_entity_id ) LOOP

    l_ctr := l_ctr + 1;
    l_workorder_tbl(l_ctr).parent_object_id := wo_csr.parent_object_id;

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Getting ' || l_ctr || ' th WO of Visit - ' || wo_csr.workorder_name );
    END IF;

    -- Check if Incomplete Master Workorder
    IF ( wo_csr.master_workorder_flag = 'Y' AND
         wo_csr.status_code <> G_JOB_STATUS_COMPLETE AND
         wo_csr.status_code <> G_JOB_STATUS_COMPLETE_NC AND
         wo_csr.status_code <> G_JOB_STATUS_CLOSED AND
         wo_csr.status_code <> G_JOB_STATUS_CANCELLED ) THEN

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : This is a Master Workorder ' );
      END IF;

      -- Since Master Workorders are obtained after the child Workorders
      -- It is enough to iterate through these child Workorders obtained
      -- in the previous iterations
      FOR i IN l_workorder_tbl.FIRST..l_workorder_tbl.LAST LOOP

        -- Check if the Master WO is the parent of the current Wo
        IF ( l_workorder_tbl(i).parent_object_id = wo_csr.wip_entity_id ) THEN

          -- Store the Least value of the children in the Actual Start Date
          IF l_workorder_tbl(i).actual_start_date IS NOT NULL
          THEN
            l_workorder_tbl(l_ctr).actual_start_date := LEAST( NVL( l_workorder_tbl(l_ctr).actual_start_date,
          		                                            l_workorder_tbl(i).actual_start_date ),
          		                                            l_workorder_tbl(i).actual_start_date );
          END IF;

	  -- Store the Greatest value of the children in the Actual End Date
	  IF l_workorder_tbl(i).actual_end_date IS NOT NULL
	  THEN
            l_workorder_tbl(l_ctr).actual_end_date := GREATEST( NVL( l_workorder_tbl(l_ctr).actual_end_date,
          		                                             l_workorder_tbl(i).actual_end_date ),
          			                                     l_workorder_tbl(i).actual_end_date );
          END IF;
        END IF;
      END LOOP;

      -- Ensure that the actual start date entered is less than the Master Wo
      /*Start ER # 4757222
      IF ( p_actual_start_date IS NOT NULL AND
           l_workorder_tbl(l_ctr).actual_start_date < p_actual_start_date ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_ACT_ST_DATE_LESS' );
        FND_MESSAGE.set_token( 'WO_NAME', wo_csr.workorder_name );
        FND_MESSAGE.set_token( 'START_DT',
        TO_CHAR( l_workorder_tbl(l_ctr).actual_start_date , 'DD-MON-YYYY HH24:MI' ) );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Ensure the actual end date entered is greater than the Master Wo
      IF ( p_actual_end_date IS NOT NULL AND
           l_workorder_tbl(l_ctr).actual_end_date > p_actual_end_date ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_ACT_END_DATE_GT' );
        FND_MESSAGE.set_token( 'WO_NAME', wo_csr.workorder_name );
        FND_MESSAGE.set_token( 'END_DT',
         TO_CHAR( l_workorder_tbl(l_ctr).actual_end_date , 'DD-MON-YYYY HH24:MI' ) );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      */--End ER # 4757222

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
        || ' : Calculated ACtual Start Date - '
        || to_char( l_workorder_tbl(l_ctr).actual_start_date, 'DD-MON-YYYY HH24:MI' )
        || ' Calculated Actual End Date - '
        || to_char( l_workorder_tbl(l_ctr).actual_end_date, 'DD-MON-YYYY HH24:MI' ) );
      END IF;


      BEGIN

        UPDATE  AHL_WORKORDERS
        SET     object_version_number = object_version_number + 1,
                actual_start_date = l_workorder_tbl(l_ctr).actual_start_date,
                actual_end_date = l_workorder_tbl(l_ctr).actual_end_date
        WHERE   workorder_id = wo_csr.workorder_id
        AND     object_version_number = wo_csr.object_version_number;

        IF ( SQL%ROWCOUNT = 0 ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
          FND_MSG_PUB.add;
          RETURN FND_API.G_RET_STS_ERROR;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
          FND_MSG_PUB.add;
          RETURN FND_API.G_RET_STS_UNEXP_ERROR;
      END;

    ELSE

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Storing ACtual Start Date of Child - ' || to_char( wo_csr.actual_start_date, 'DD-MON-YYYY HH24:MI' ) || ' Actual End Date' || to_char( wo_csr.actual_end_date, 'DD-MON-YYYY HH24:MI' ) );
      END IF;

      -- Store the Child Wo or Complete Master Wo Actual Dates as it is
      l_workorder_tbl(l_ctr).actual_start_date := wo_csr.actual_start_date;
      l_workorder_tbl(l_ctr).actual_end_date := wo_csr.actual_end_date;
    END IF;

  END LOOP;

   /*Start ER # 4757222*/
   --Update master workorder record.If all
   --IF p_default_flag = 'Y' THEN
   -- Master workorder dates will no longer be defaulted from user entered dates as per
   -- the ER # . Master workorder actual dates will be derived from its child workorders
   -- if not present already.
   /*End ER # 4757222*/
     l_min := null;
     l_max := NULL;
     --l_max := sysdate;

     FOR wo_csr IN get_child_wos( p_wip_entity_id ) LOOP
     	IF wo_csr.actual_start_date IS NOT NULL
     	THEN
       		l_min := least(nvl(l_min, wo_csr.actual_start_date), wo_csr.actual_start_date);
       	END IF;

       	IF wo_csr.actual_end_date IS NOT NULL
       	THEN
        	l_max := greatest(nvl(l_max, wo_csr.actual_end_date), wo_csr.actual_end_date);
        END IF;
     END LOOP;

   /*Start ER # 4757222*/
   /*ELSE
   	l_min := p_actual_start_date;
   	l_max := p_actual_end_date;
   END IF;*/
   /*End ER # 4757222*/

   UPDATE  AHL_WORKORDERS
      SET object_version_number = object_version_number + 1,
      actual_start_date = l_min,
      actual_end_date = l_max
   WHERE   wip_entity_id = p_wip_entity_id;


  RETURN FND_API.G_RET_STS_SUCCESS;

END update_mwo_actual_dates;

FUNCTION complete_visit_mr_wos
(
  p_wip_entity_id     IN            NUMBER, -- Visit or MR WO
  p_x_workorder_tbl   IN OUT NOCOPY workorder_tbl_type
) RETURN VARCHAR2
IS

-- To get all the completion dependencies in a Visit
CURSOR  get_visit_dependencies( c_wip_entity_id NUMBER )
IS
SELECT  WO.wip_entity_id parent_we_id,
        WO.workorder_name parent_wo_name,
        DECODE( WO.status_code,
                G_JOB_STATUS_COMPLETE, G_JOB_STATUS_COMPLETE,
                G_JOB_STATUS_COMPLETE_NC, G_JOB_STATUS_COMPLETE,
                G_JOB_STATUS_CLOSED, G_JOB_STATUS_COMPLETE,
                G_JOB_STATUS_CANCELLED, G_JOB_STATUS_COMPLETE,
                G_JOB_STATUS_DELETED, G_JOB_STATUS_COMPLETE,
                WO.status_code ) parent_status_code,
        WOR.child_object_id child_we_id
FROM    AHL_WORKORDERS WO,
        WIP_SCHED_RELATIONSHIPS WOR
WHERE   WO.wip_entity_id = WOR.parent_object_id
AND     WOR.top_level_object_id = c_wip_entity_id
AND     WOR.relationship_type = 2
AND     WOR.parent_object_type_id = 1
AND     WOR.child_object_type_id = 1;

TYPE parent_wo_rec_type IS RECORD
(
  parent_we_id               NUMBER,
  parent_wo_name             VARCHAR2(80),
  parent_status_code         VARCHAR2(30),
  child_we_id                NUMBER
);

TYPE parent_wo_tbl_type IS TABLE OF parent_wo_rec_type INDEX BY BINARY_INTEGER;

-- To hold the completion parent records.
l_parent_wo_tbl  parent_wo_tbl_type;
l_ctr            NUMBER := 0;

-- To hold the number of iterations processed for completing WOs
l_iteration_ctr  NUMBER := 0;

-- To check if a Workorder is within the Visit or MR Hierarchy
l_wo_found       BOOLEAN := FALSE;

-- To check if all the Workorders in a Visit or MR are complete
l_all_wos_cmpl   BOOLEAN := TRUE;

-- To check whether a completion parent is complete or non-existant.
l_parent_wo_cmpl BOOLEAN := TRUE;

l_return_status  VARCHAR2(1);
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(2000);

l_api_name               VARCHAR2(30) := 'complete_visit_mr_wos';
BEGIN

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Getting Visit Dependencies' );
  END IF;

  -- Get all the completion dependencies in a Visit
  FOR parent_csr IN get_visit_dependencies( p_wip_entity_id ) LOOP
    l_ctr := l_ctr + 1;
    l_parent_wo_tbl(l_ctr).parent_we_id := parent_csr.parent_we_id;
    l_parent_wo_tbl(l_ctr).parent_wo_name := parent_csr.parent_wo_name;
    l_parent_wo_tbl(l_ctr).parent_status_code := parent_csr.parent_status_code;
    l_parent_wo_tbl(l_ctr).child_we_id := parent_csr.child_we_id;
  END LOOP;

  -- There are no Completion Dependencies.
  IF ( l_parent_wo_tbl.COUNT = 0 ) THEN

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Completion Dependencies do not exist' );
    END IF;

    -- Complete all Workorders
    FOR i IN p_x_workorder_tbl.FIRST..p_x_workorder_tbl.LAST LOOP

      -- Complete only Child Workorders because
      -- Master Workorders are completed automatically
      IF ( p_x_workorder_tbl(i).master_workorder_flag = 'N' ) THEN

        IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Completing Workorder - ' || p_x_workorder_tbl(i).workorder_name || ' ID - ' || p_x_workorder_tbl(i).workorder_id );
        END IF;

        complete_workorder
        (
          p_api_version            => 1.0,
          p_init_msg_list          => FND_API.G_FALSE,
          p_commit                 => FND_API.G_FALSE,
          p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
          p_default                => FND_API.G_FALSE,
          p_module_type            => NULL,
          x_return_status          => l_return_status,
          x_msg_count              => l_msg_count,
          x_msg_data               => l_msg_data,
          p_workorder_id           => p_x_workorder_tbl(i).workorder_id,
          p_object_version_no      => p_x_workorder_tbl(i).object_version_number
        );

        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
          RETURN l_return_status;
        END IF;

      END IF;

    END LOOP;

  ELSE

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Completion Dependencies exist' );
    END IF;

    -- Since Completion dependencies exist multiple iterations may be
    -- required for completing the Visit or MR Workorders
    -- Break out when all the Wos of the Visit or MR are complete
    WHILE TRUE LOOP

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Begin Iteration - ' || l_iteration_ctr );
      END IF;

      -- Increment Iteration counter
      l_iteration_ctr := l_iteration_ctr + 1;

      -- Reset for Every Iteration of the Input Wo Table
      l_all_wos_cmpl := TRUE;

      -- Process Completion Dependencies
      -- Iterate Through all the Child Wos in the input Wo table
      FOR i IN p_x_workorder_tbl.FIRST..p_x_workorder_tbl.LAST LOOP

        -- Check if a Wo needs to be completed
        -- Ignore Master Workorders since they are completed automatically
        IF ( p_x_workorder_tbl(i).master_workorder_flag = 'N' AND
             NVL(p_x_workorder_tbl(i).status_code,'X') <> NVL(G_JOB_STATUS_COMPLETE,'Y') ) THEN

          IF ( G_DEBUG = 'Y' ) THEN
            AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Need to Complete WO - ' || p_x_workorder_tbl(i).workorder_name );
          END IF;

          -- Reset for Every Iteration of a Child Workorder
          l_parent_wo_cmpl := TRUE;

          -- Iterate through the Parent Workorders
          FOR j IN l_parent_wo_tbl.FIRST..l_parent_wo_tbl.LAST LOOP

            -- Matching Parent
            IF ( l_parent_wo_tbl(j).child_we_id = p_x_workorder_tbl(i).wip_entity_id ) THEN
              -- Parent not Complete
              IF ( l_parent_wo_tbl(j).parent_status_code <> G_JOB_STATUS_COMPLETE ) THEN
                -- Set Parent Wo as not Complete
                l_parent_wo_cmpl := FALSE;

                -- Since the Parent is not Complete more iterations are reqd
                l_all_wos_cmpl := FALSE;

                -- Check if Parent exists in the Hierarchy for first iteration
                IF ( l_iteration_ctr = 1 ) THEN

                  -- Iterate through the Visit or MR Workorders
                  FOR x IN p_x_workorder_tbl.FIRST..p_x_workorder_tbl.LAST LOOP

                    -- Parent exists in the Visit or MR Hierarchy
                    IF ( l_parent_wo_tbl(j).parent_we_id = p_x_workorder_tbl(x).wip_entity_id ) THEN
                      l_wo_found := TRUE;
                      EXIT;
                    END IF;
                  END LOOP;

                  IF ( l_wo_found = TRUE ) THEN
                    l_wo_found := FALSE;
                    EXIT;
                  ELSE

                    -- Error out since the Visit or the MR cannot be completed
                    -- as the Parent is outside the Hierarchy
                    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_PARENT_WO_NOT_CMPL' );
                    FND_MESSAGE.set_token( 'WO', p_x_workorder_tbl(i).workorder_name );
                    FND_MESSAGE.set_token( 'PARENT_WO', l_parent_wo_tbl(j).parent_wo_name );
                    FND_MSG_PUB.add;
                    RETURN FND_API.G_RET_STS_ERROR;
                  END IF; -- Hierarchy check
                END IF; -- First Iteration
              END IF; -- Parent WOs complete check
            END IF; -- Match Parent check

            -- If any Parent is not complete then the Wo cannot be completed
            -- Break out of the iterate parents loop
            IF ( l_parent_wo_cmpl = FALSE ) THEN

              IF ( G_DEBUG = 'Y' ) THEN
                AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Workorder cannot be completed in this iteration because one or more parents are not complete ' );
              END IF;

              EXIT;
            END IF;

          END LOOP; -- Match Iterate Parents Loop;

          -- All the Parents of a child WO are complete
          IF ( l_parent_wo_cmpl = TRUE ) THEN

            IF ( G_DEBUG = 'Y' ) THEN
              AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Workorder can be completed in this iteration because all parents are complete ' );
            END IF;

            -- Complete the Child Workorder
            complete_workorder
            (
              p_api_version            => 1.0,
              p_init_msg_list          => FND_API.G_FALSE,
              p_commit                 => FND_API.G_FALSE,
              p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
              p_default                => FND_API.G_FALSE,
              p_module_type            => NULL,
              x_return_status          => l_return_status,
              x_msg_count              => l_msg_count,
              x_msg_data               => l_msg_data,
              p_workorder_id           => p_x_workorder_tbl(i).workorder_id,
              p_object_version_no      => p_x_workorder_tbl(i).object_version_number
            );

            IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
              RETURN l_return_status;
            END IF;

            -- Set the Workorder status as Complete for next iteration
            p_x_workorder_tbl(i).status_code := G_JOB_STATUS_COMPLETE;

            -- Iterate through the Parents for setting Wo Status as Complete
            FOR y IN l_parent_wo_tbl.FIRST..l_parent_wo_tbl.LAST LOOP
              IF ( l_parent_wo_tbl(y).parent_we_id = p_x_workorder_tbl(i).wip_entity_id ) THEN
                -- Set the Workorder status as Complete wherever it is a Parent
                l_parent_wo_tbl(y).parent_status_code := G_JOB_STATUS_COMPLETE;
              END IF;
            END LOOP; -- Match Update Parent Status Loop

          END IF; -- Match Parent Complete check

        END IF; -- Match Complete Wos check

      END LOOP; -- Match Child Wos Loop

      -- If all the Wos of the Visit or MR are complete in this iteration
      -- Break out of the outermost loop
      IF ( l_all_wos_cmpl = TRUE ) THEN
        IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : All Workorders are completed in this iteration ' );
        END IF;

        EXIT;
      END IF;

    END LOOP; -- Match While loop of outermost Iteration

  END IF; -- Match Completion dependencies existence check

  RETURN FND_API.G_RET_STS_SUCCESS;

END complete_visit_mr_wos;

PROCEDURE signoff_mr_instance
(
  p_api_version      IN         NUMBER        := 1.0,
  p_init_msg_list    IN         VARCHAR2      := FND_API.G_TRUE,
  p_commit           IN         VARCHAR2      := FND_API.G_FALSE,
  p_validation_level IN         NUMBER        := FND_API.G_VALID_LEVEL_FULL,
  p_default          IN         VARCHAR2      := FND_API.G_FALSE,
  p_module_type      IN         VARCHAR2      := NULL,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  p_signoff_mr_rec   IN         signoff_mr_rec_type
)
IS

l_api_name               VARCHAR2(30) := 'signoff_mr_instance';
l_return_status          VARCHAR2(1);
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(2000);
l_status_meaning        VARCHAR2(80);
l_actual_end_date DATE;
l_actual_start_date DATE;
l_wo_name VARCHAR2(80);

-- rroy
-- R12 Tech UIs
-- cursor to retrieve the workorder actual dates
CURSOR get_wo_dates(x_wo_id NUMBER)
IS
SELECT Actual_start_date,
Actual_end_date,
Workorder_name
FROM AHL_WORKORDERS
WHERE workorder_id = x_wo_id;

-- To get the Unit Effectivity Details and it's master workorder details
/*CURSOR     get_ue_details( c_unit_effectivity_id NUMBER ) IS
SELECT     UE.unit_effectivity_id unit_effectivity_id,
           UE.title ue_title,
           UE.object_version_number ue_object_version_number,
           UE.ump_status_code ue_status_code,
           UE.qa_inspection_type_code ue_qa_inspection_type_code,
           UE.qa_plan_id ue_qa_plan_id,
           UE.qa_collection_id ue_qa_collection_id,
           WO.workorder_id workorder_id,
           WIP.organization_id,
           WO.object_version_number wo_object_version_number,
           WO.workorder_name workorder_name,
           WO.wip_entity_id wip_entity_id,
           VWO.wip_entity_id visit_wip_entity_id,
           VT.instance_id item_instance_id,
           WIP.scheduled_start_date scheduled_start_date,
           WIP.scheduled_completion_date scheduled_end_date,
           WO.actual_start_date actual_start_date,
           WO.actual_end_date actual_end_date,
           WO.status_code wo_status_code,
           WO.plan_id wo_plan_id,
           WO.collection_id wo_collection_id,
   	   WO.master_workorder_flag
FROM       WIP_DISCRETE_JOBS WIP,
           AHL_WORKORDERS WO,
           AHL_WORKORDERS VWO,
           AHL_VISIT_TASKS_B VT,
           AHL_UE_DEFERRAL_DETAILS_V UE
WHERE      WIP.wip_entity_id = WO.wip_entity_id
AND        WO.visit_task_id = VT.visit_task_id
AND        VWO.visit_task_id IS NULL
AND        VWO.visit_id = VT.visit_id
AND        VT.task_type_code IN ( 'SUMMARY' , 'UNASSOCIATED' )
AND        VT.unit_effectivity_id = UE.unit_effectivity_id
AND        UE.unit_effectivity_id = c_unit_effectivity_id;*/
--fix for bug number 7295717 (Sunil)
CURSOR     get_ue_details( c_unit_effectivity_id NUMBER ) IS
SELECT     UE.unit_effectivity_id unit_effectivity_id,
           DECODE( UE.Mr_header_id, null,
           (select cit.name || '-' || cs.incident_number from cs_incidents_all_vl cs, cs_incident_types_vl cit WHERE cs.incident_type_id = cit.incident_type_id AND cs.incident_id = UE.Cs_Incident_id),
           (select title from AHL_MR_HEADERS_B MR where MR.mr_header_id = UE.mr_header_id )) ue_title,
           UE.object_version_number ue_object_version_number,
           UE.status_code ue_status_code,
           --UE.qa_inspection_type_code ue_qa_inspection_type_code,
           DECODE( UE.Mr_header_id, null,null,(select QA_INSPECTION_TYPE from AHL_MR_HEADERS_B MR where MR.mr_header_id = UE.mr_header_id ))  ue_qa_inspection_type_code,
           -1 ue_qa_plan_id,
           UE.qa_collection_id ue_qa_collection_id,
           WO.workorder_id workorder_id,
           WIP.organization_id,
           WO.object_version_number wo_object_version_number,
           WO.workorder_name workorder_name,
           WO.wip_entity_id wip_entity_id,
           VWO.wip_entity_id visit_wip_entity_id,
           VT.instance_id item_instance_id,
           WIP.scheduled_start_date scheduled_start_date,
           WIP.scheduled_completion_date scheduled_end_date,
           WO.actual_start_date actual_start_date,
           WO.actual_end_date actual_end_date,
           WO.status_code wo_status_code,
           WO.plan_id wo_plan_id,
           WO.collection_id wo_collection_id,
   	       WO.master_workorder_flag,
   	       WIP.ORGANIZATION_ID org_id
FROM       WIP_DISCRETE_JOBS WIP,
           AHL_WORKORDERS WO,
           AHL_WORKORDERS VWO,
           AHL_VISIT_TASKS_B VT,
           AHL_UNIT_EFFECTIVITIES_APP_V UE
WHERE      WIP.wip_entity_id = WO.wip_entity_id
AND        WO.visit_task_id = VT.visit_task_id
AND        VWO.visit_task_id IS NULL
AND        VWO.visit_id = VT.visit_id
AND        VT.task_type_code IN ( 'SUMMARY' , 'UNASSOCIATED' )
AND        VT.unit_effectivity_id = UE.unit_effectivity_id
AND        UE.unit_effectivity_id = c_unit_effectivity_id;

CURSOR get_qa_plan_id_csr1(p_collection_id IN NUMBER)IS
SELECT qa.plan_id from qa_results qa
where qa.collection_id = p_collection_id and rownum < 2;

CURSOR get_qa_plan_id_csr2(p_org_id IN NUMBER, p_qa_inspection_type IN VARCHAR2)IS
SELECT QP.plan_id FROM QA_PLANS_VAL_V QP, QA_PLAN_TRANSACTIONS QPT, QA_PLAN_COLLECTION_TRIGGERS QPCT
WHERE QP.plan_id = QPT.plan_id AND QPT.plan_transaction_id = QPCT.plan_transaction_id
AND QP.organization_id = p_org_id
AND QPT.transaction_number in (9999,2001)
AND QPCT.collection_trigger_id = 87
AND QPCT.low_value = p_qa_inspection_type
group by qp.plan_id, qpt.transaction_number having transaction_number = MAX(transaction_number);

-- To get the Child Unit Effectivity Details
/*CURSOR     get_child_ue_details( c_unit_effectivity_id NUMBER ) IS
SELECT     unit_effectivity_id,
           object_version_number,
           title,
           ump_status_code,
           qa_inspection_type_code,
           qa_plan_id,
           qa_collection_id
FROM       AHL_UE_DEFERRAL_DETAILS_V
WHERE      unit_effectivity_id IN
           (
             SELECT     related_ue_id
             FROM       AHL_UE_RELATIONSHIPS
             WHERE      unit_effectivity_id = related_ue_id
             START WITH ue_id = c_unit_effectivity_id
                    AND relationship_code = 'PARENT'
             CONNECT BY ue_id = PRIOR related_ue_id
                    AND relationship_code = 'PARENT'
           );*/

CURSOR     get_child_ue_details( c_unit_effectivity_id NUMBER ) IS
SELECT     unit_effectivity_id,
           object_version_number,
           DECODE( UE.Mr_header_id, null,
           (select cit.name || '-' || cs.incident_number from cs_incidents_all_vl cs, cs_incident_types_vl cit WHERE cs.incident_type_id = cit.incident_type_id AND cs.incident_id = UE.Cs_Incident_id),
           (select title from AHL_MR_HEADERS_B MR where MR.mr_header_id = UE.mr_header_id )) title,
           status_code ump_status_code,
           DECODE( UE.Mr_header_id, null,null,(select QA_INSPECTION_TYPE from AHL_MR_HEADERS_B MR where MR.mr_header_id = UE.mr_header_id ))  qa_inspection_type_code,
           -1 qa_plan_id,
           qa_collection_id
FROM       AHL_UNIT_EFFECTIVITIES_B UE,(SELECT     related_ue_id
FROM       AHL_UE_RELATIONSHIPS
  START WITH ue_id = c_unit_effectivity_id
  AND relationship_code = 'PARENT'
  CONNECT BY ue_id = PRIOR related_ue_id
  AND relationship_code = 'PARENT') CH
WHERE      UE.unit_effectivity_id = CH.related_ue_id ORDER BY unit_effectivity_id ASC;

-- rroy
-- Commented out the order by because of
-- error ORA-01788 being thrown on signoff mr page
--ORDER BY   level DESC;

-- To get the Child Workorder Details for a UE
CURSOR     get_ue_workorders( c_wip_entity_id NUMBER ) IS
SELECT     CWO.workorder_id workorder_id,
           CWO.object_version_number object_version_number,
           CWO.workorder_name workorder_name,
           CWO.wip_entity_id wip_entity_id,
           WIP.scheduled_start_date scheduled_start_date,
           WIP.scheduled_completion_date scheduled_end_date,
           CWO.actual_start_date actual_start_date,
           CWO.actual_end_date actual_end_date,
           CWO.status_code status_code,
           CWO.master_workorder_flag master_workorder_flag,
           CWO.plan_id plan_id,
           CWO.collection_id collection_id
FROM       WIP_DISCRETE_JOBS WIP,
           AHL_WORKORDERS CWO,
           WIP_SCHED_RELATIONSHIPS REL
WHERE      WIP.wip_entity_id = CWO.wip_entity_id
AND        CWO.wip_entity_id = REL.child_object_id
AND        CWO.status_code <> G_JOB_STATUS_DELETED
AND        REL.parent_object_type_id = 1
AND        REL.child_object_type_id = 1
START WITH REL.parent_object_id = c_wip_entity_id
AND        REL.relationship_type = 1
CONNECT BY REL.parent_object_id = PRIOR REL.child_object_id
AND        REL.relationship_type = 1
ORDER BY   level DESC;

-- To get all the Child Operation Details for a UE
CURSOR     get_ue_operations( c_wip_entity_id NUMBER ) IS
SELECT     WOP.workorder_operation_id workorder_operation_id,
           WOP.object_version_number object_version_number,
           CWO.workorder_name workorder_name,
           WIP.wip_entity_id wip_entity_id,
           WIP.operation_seq_num operation_seq_num,
           WIP.first_unit_start_date scheduled_start_date,
           WIP.last_unit_completion_date scheduled_end_date,
           WOP.actual_start_date actual_start_date,
           WOP.actual_end_date actual_end_date,
           WOP.status_code status_code,
           WOP.plan_id plan_id,
           WOP.collection_id collection_id
FROM       AHL_WORKORDER_OPERATIONS WOP,
           WIP_OPERATIONS WIP,
           AHL_WORKORDERS CWO
WHERE      WOP.operation_sequence_num = WIP.operation_seq_num
AND        WOP.workorder_id = CWO.workorder_id
AND        WIP.wip_entity_id = CWO.wip_entity_id
--AND        CWO.status_code <> G_JOB_STATUS_DELETED
--Balaji added the check for BAE bug.
AND        CWO.status_code NOT IN
           (
             G_JOB_STATUS_COMPLETE_NC,
             G_JOB_STATUS_COMPLETE,
             G_JOB_STATUS_CLOSED,
             G_JOB_STATUS_CANCELLED,
             G_JOB_STATUS_DELETED
           )
AND        WIP.WIP_ENTITY_ID IN (
             SELECT     CWO.wip_entity_id
FROM       WIP_DISCRETE_JOBS WIP,
           AHL_WORKORDERS CWO,
           WIP_SCHED_RELATIONSHIPS REL
WHERE      WIP.wip_entity_id = CWO.wip_entity_id
AND        CWO.wip_entity_id = REL.child_object_id
AND        CWO.status_code <> G_JOB_STATUS_DELETED
AND        REL.parent_object_type_id = 1
AND        REL.child_object_type_id = 1
START WITH REL.parent_object_id = c_wip_entity_id
AND        REL.relationship_type = 1
CONNECT BY REL.parent_object_id = PRIOR REL.child_object_id
AND        REL.relationship_type = 1);
-- rroy
-- Commented out the order by because of
-- error ORA-01788 being thrown on signoff mr page
--ORDER BY   level DESC;

-- To get operation for UE associated with SR created from Production
CURSOR    get_unassoc_ue_op(c_wip_entity_id NUMBER) IS
SELECT     WOP.workorder_operation_id workorder_operation_id,
           WOP.object_version_number object_version_number,
           CWO.workorder_name workorder_name,
           WIP.wip_entity_id wip_entity_id,
           WIP.operation_seq_num operation_seq_num,
           WIP.first_unit_start_date scheduled_start_date,
           WIP.last_unit_completion_date scheduled_end_date,
           WOP.actual_start_date actual_start_date,
           WOP.actual_end_date actual_end_date,
           WOP.status_code status_code,
           WOP.plan_id plan_id,
           WOP.collection_id collection_id
FROM       AHL_WORKORDER_OPERATIONS WOP,
           WIP_OPERATIONS WIP,
           AHL_WORKORDERS CWO
WHERE      WOP.operation_sequence_num = WIP.operation_seq_num
AND        WOP.workorder_id = CWO.workorder_id
AND        WIP.wip_entity_id = CWO.wip_entity_id
AND        WIP.WIP_ENTITY_ID = c_wip_entity_id
AND        CWO.MASTER_WORKORDER_FLAG = 'N'
--Balaji added the status check for BAE Bug
AND        CWO.status_code NOT IN
           (
             G_JOB_STATUS_COMPLETE_NC,
             G_JOB_STATUS_COMPLETE,
             G_JOB_STATUS_CLOSED,
             G_JOB_STATUS_CANCELLED,
             G_JOB_STATUS_DELETED
           );
-- Balaji commented out the order by clause for the issue # 3 in bug #4613940(CMRO)
-- and this fix has reference to bug #3085871(ST) where it is described that order by level
-- should not be used without a reference to "start with.. connect by clause" starting 10g
-- ORDER BY   level DESC;

-- To get all the Resource Requirements for a UE
CURSOR     get_ue_resource_req( c_wip_entity_id NUMBER ) IS
SELECT     WOR.wip_entity_id wip_entity_id,
           CWO.workorder_name,
           CWO.workorder_id,
           WOP.workorder_operation_id,
           WOR.operation_seq_num operation_seq_num,
           WOR.resource_seq_num resource_seq_num,
           WOR.organization_id organization_id,
           WOR.department_id department_id,
           BOM.resource_code resource_name,
           WOR.resource_id resource_id,
           BOM.resource_type,
           WOR.uom_code uom_code,
           WOR.usage_rate_or_amount usage_rate_or_amount
FROM       BOM_RESOURCES BOM,
           WIP_OPERATION_RESOURCES WOR,
           AHL_WORKORDER_OPERATIONS WOP,
           AHL_WORKORDERS CWO,
           WIP_SCHED_RELATIONSHIPS REL
WHERE      BOM.resource_type IN ( 1 , 2 )
AND        BOM.resource_id = WOR.resource_id
AND        WOR.operation_seq_num = WOP.operation_sequence_num
AND        WOR.wip_entity_id = CWO.wip_entity_id
AND        WOP.status_code <> G_OP_STATUS_COMPLETE
AND        WOP.workorder_id = CWO.workorder_id
AND        CWO.status_code NOT IN
           (
             G_JOB_STATUS_COMPLETE_NC,
             G_JOB_STATUS_COMPLETE,
             G_JOB_STATUS_CLOSED,
             G_JOB_STATUS_CANCELLED,
             G_JOB_STATUS_DELETED
           )
AND        CWO.wip_entity_id = REL.child_object_id
AND        REL.parent_object_type_id = 1
AND        REL.child_object_type_id = 1
START WITH REL.parent_object_id = c_wip_entity_id
AND        REL.relationship_type = 1
CONNECT BY REL.parent_object_id = PRIOR REL.child_object_id
AND        REL.relationship_type = 1;

-- Balaji added this cursor for bug # 4955278.
-- this cursor retrieves res req for operations associated with
-- workorders created out of NR created in Prod floor or from
-- an unassociated task in VWP.
CURSOR     get_unass_ue_resource_req( c_wip_entity_id NUMBER ) IS
SELECT     WOR.wip_entity_id wip_entity_id,
           CWO.workorder_name,
           CWO.workorder_id,
           WOP.workorder_operation_id,
           WOR.operation_seq_num operation_seq_num,
           WOR.resource_seq_num resource_seq_num,
           WOR.organization_id organization_id,
           WOR.department_id department_id,
           BOM.resource_code resource_name,
           WOR.resource_id resource_id,
           BOM.resource_type,
           WOR.uom_code uom_code,
           WOR.usage_rate_or_amount usage_rate_or_amount
FROM       BOM_RESOURCES BOM,
           WIP_OPERATION_RESOURCES WOR,
           AHL_WORKORDER_OPERATIONS WOP,
           AHL_WORKORDERS CWO
WHERE      BOM.resource_type IN ( 1 , 2 )
AND        BOM.resource_id = WOR.resource_id
AND        WOR.operation_seq_num = WOP.operation_sequence_num
AND        WOR.wip_entity_id = CWO.wip_entity_id
AND        WOP.status_code <> G_OP_STATUS_COMPLETE
AND        WOP.workorder_id = CWO.workorder_id
AND        CWO.status_code NOT IN
           (
             G_JOB_STATUS_COMPLETE_NC,
             G_JOB_STATUS_COMPLETE,
             G_JOB_STATUS_CLOSED,
             G_JOB_STATUS_CANCELLED,
             G_JOB_STATUS_DELETED
           )
AND        CWO.wip_entity_id = c_wip_entity_id
AND        CWO.MASTER_WORKORDER_FLAG = 'N';

-- To get the Resource Transactions performed for a Resource Requirement
CURSOR     get_resource_txns( c_wip_entity_id NUMBER,
                              c_operation_seq_num NUMBER,
                              c_resource_seq_num NUMBER ) IS
SELECT     NVL( SUM( transaction_quantity ), 0 )
FROM       WIP_TRANSACTIONS
WHERE      wip_entity_id = c_wip_entity_id
AND        operation_seq_num = c_operation_seq_num
AND        resource_seq_num = c_resource_seq_num;

-- To get the Pending Resource Transactions for a Resource Requirement
-- Confirm
CURSOR     get_pending_resource_txns( c_wip_entity_id NUMBER,
                                      c_operation_seq_num NUMBER,
                                      c_resource_seq_num NUMBER ) IS
SELECT     NVL( SUM( transaction_quantity ), 0 )
FROM       WIP_COST_TXN_INTERFACE
WHERE      wip_entity_id = c_wip_entity_id
AND        operation_seq_num = c_operation_seq_num
AND        resource_seq_num = c_resource_seq_num
AND        process_status = 1;

l_ctr                    NUMBER := 0;
l_wo_actual_start_date      DATE;
l_wo_actual_end_date        DATE;
l_def_actual_start_date  DATE;
l_def_actual_end_date    DATE;
l_transaction_qty        NUMBER := 0;
l_txn_qty                NUMBER := 0;
l_pending_txn_qty        NUMBER := 0;
l_employee_id            NUMBER;
l_ue_status_code         VARCHAR2(30);
l_mr_rec                 get_ue_details%ROWTYPE;
l_child_mr_tbl           mr_tbl_type;
l_workorder_tbl          workorder_tbl_type;
l_operation_tbl          operation_tbl_type;
l_resource_req_tbl       resource_req_tbl_type;
l_counter_tbl            counter_tbl_type;
--l_res_txn_tbl            AHL_WIP_JOB_PVT.ahl_res_txn_tbl_type;
l_job_status_meaning     VARCHAR2(80);
l_unassoc_ue_op_rec      get_unassoc_ue_op%ROWTYPE;
l_default                VARCHAR2(1);
TYPE child_ue_tbl_type IS TABLE OF get_child_ue_details%ROWTYPE INDEX BY BINARY_INTEGER;

l_child_ue_tbl child_ue_tbl_type;
l_ue_ctr NUMBER := 0;

l_op_actual_start_date DATE;
l_op_actaul_end_date DATE;

-- parameters to call process_resource_txns.
l_prd_resrc_txn_tbl     AHL_PRD_RESOURCE_TRANX_PVT.PRD_RESOURCE_TXNS_TBL;

BEGIN

  -- Enable Debug (optional)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT signoff_mr_instance_PVT;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Validating Inputs' );
  END IF;

  -- Validate all the inputs of the API
  l_return_status :=
  validate_smri_inputs
  (
    p_signoff_mr_rec      => p_signoff_mr_rec
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Inputs - p_signoff_mr_rec.unit_effectivity_id - ' || p_signoff_mr_rec.unit_effectivity_id );
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Inputs - p_signoff_mr_rec.object_version_number - ' || p_signoff_mr_rec.object_version_number );
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Inputs - p_signoff_mr_rec.signoff_child_mrs_flag - ' || p_signoff_mr_rec.signoff_child_mrs_flag );
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Inputs - p_signoff_mr_rec.complete_job_ops_flag - ' || p_signoff_mr_rec.complete_job_ops_flag );
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Inputs - p_signoff_mr_rec.default_actual_dates_flag - ' || p_signoff_mr_rec.default_actual_dates_flag );
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Inputs - p_signoff_mr_rec.actual_start_date - ' || p_signoff_mr_rec.actual_start_date );
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Inputs - p_signoff_mr_rec.actual_end_date - ' || p_signoff_mr_rec.actual_end_date );
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Inputs - p_signoff_mr_rec.transact_resource_flag - ' || p_signoff_mr_rec.transact_resource_flag );
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Inputs - p_signoff_mr_rec.employee_number - ' || p_signoff_mr_rec.employee_number );
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Inputs - p_signoff_mr_rec.serial_number - ' || p_signoff_mr_rec.serial_number );
  END IF;

  -- Invoke Complete MR Instance API if this is not a top-down signoff
  IF ( p_signoff_mr_rec.signoff_child_mrs_flag = 'N' AND
       p_signoff_mr_rec.complete_job_ops_flag = 'N' AND
       p_signoff_mr_rec.transact_resource_flag = 'N' ) THEN

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Not Top Down Signoff ' );
    END IF;

    l_ctr := l_ctr + 1;
    l_child_mr_tbl(l_ctr).unit_effectivity_id := p_signoff_mr_rec.unit_effectivity_id;
    l_child_mr_tbl(l_ctr).ue_object_version_no := p_signoff_mr_rec.object_version_number;

    complete_mr_instance
    (
      p_api_version            => 1.0,
      p_init_msg_list          => FND_API.G_FALSE,
      p_commit                 => FND_API.G_TRUE,
      p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
      p_default                => FND_API.G_FALSE,
      p_module_type            => NULL,
      x_return_status          => l_return_status,
      x_msg_count              => l_msg_count,
      x_msg_data               => l_msg_data,
      p_x_mr_rec               => l_child_mr_tbl(l_ctr)
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' After Calling complete_mr_instance, Status =  '||l_return_status );
    END IF;

    IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

--JKJain, Bug 9250614
--    RETURN;

-- Get the UE Details
    OPEN get_ue_details( p_signoff_mr_rec.unit_effectivity_id );
    FETCH get_ue_details INTO l_mr_rec;

    IF ( get_ue_details%NOTFOUND ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_MR_REC_NOT_FOUND' );
      FND_MSG_PUB.add;
      CLOSE get_ue_details;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE get_ue_details;

-- Add the UE Master WO to the Workorder Table of Records  for QCP.
      l_ctr := 0;
      l_ctr := l_ctr + 1;
      l_workorder_tbl(l_ctr).workorder_id := l_mr_rec.workorder_id;
      l_workorder_tbl(l_ctr).wip_entity_id := l_mr_rec.wip_entity_id;
      l_workorder_tbl(l_ctr).actual_end_date := l_mr_rec.actual_end_date;


    IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' Before GOTO  counter_qa_results_label' );
    END IF;

--  GOTO <Label_Name>
    GOTO counter_qa_results_label;

  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Processing UE' );
  END IF;

  -- Get the UE Details
  OPEN  get_ue_details( p_signoff_mr_rec.unit_effectivity_id );
  FETCH get_ue_details
  INTO  l_mr_rec;

  IF(l_mr_rec.ue_qa_inspection_type_code IS NULL)THEN
         l_mr_rec.ue_qa_plan_id := NULL;
      ELSIF(l_mr_rec.ue_qa_collection_id IS NOT NULL)THEN
         OPEN get_qa_plan_id_csr1(l_mr_rec.ue_qa_collection_id);
         FETCH get_qa_plan_id_csr1 INTO l_mr_rec.ue_qa_plan_id;
         CLOSE get_qa_plan_id_csr1;
      ELSE
         OPEN get_qa_plan_id_csr2(l_mr_rec.organization_id,l_mr_rec.ue_qa_inspection_type_code);
         FETCH get_qa_plan_id_csr2 INTO l_mr_rec.ue_qa_plan_id;
         CLOSE get_qa_plan_id_csr2;
  END IF;

  IF ( get_ue_details%NOTFOUND ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_MR_REC_NOT_FOUND' );
    FND_MSG_PUB.add;
    CLOSE get_ue_details;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE get_ue_details;

  -- Validate Object Version Number
  IF ( l_mr_rec.ue_object_version_number <> p_signoff_mr_rec.object_version_number ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Check if this MR is already signed off
  IF ( l_mr_rec.ue_status_code = G_MR_STATUS_SIGNED_OFF ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_INV_SIGNOFF_STATUS');
    FND_MESSAGE.set_token( 'MAINT_REQ', l_mr_rec.ue_title );
				-- replacing with call to get_status function
				-- so no exceptions are thrown if the
				-- lookup does not exist
    l_status_meaning := get_status(l_mr_rec.ue_status_code,
				'AHL_PRD_MR_STATUS');

     /*SELECT meaning INTO l_status_meaning
	   FROM fnd_lookup_values_vl
        WHERE lookup_type = 'AHL_PRD_MR_STATUS'
          AND LOOKUP_CODE = l_mr_rec.ue_status_code;
     */

    FND_MESSAGE.set_token( 'STATUS', l_status_meaning );
    FND_MSG_PUB.add;
  END IF;

  -- Check if the UE is complete
  l_return_status:=
  is_mr_complete
  (
    p_mr_title             => l_mr_rec.ue_title,
    p_status_code          => l_mr_rec.ue_status_code,
    p_status               => NULL,
    p_qa_inspection_type   => l_mr_rec.ue_qa_inspection_type_code,
    p_qa_plan_id           => l_mr_rec.ue_qa_plan_id,
    p_qa_collection_id     => l_mr_rec.ue_qa_collection_id
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Processing Child UEs' );
  END IF;

  -- Balaji added the following loop for the BAE bug.
  -- The cursor get_child_ue_details doesnt UEs at the leaf node first
  -- their parent next, etc., instead it returns Mrs in Top down fashion.
  -- Hence below loop fetches all the child UEs in top down fashion and in
  -- subsequent code the top down will be converted into bottom up to
  -- circumvent the "At least one child Maintenance Requirement is unaccomplished"
  FOR child_ue_rec IN get_child_ue_details( p_signoff_mr_rec.unit_effectivity_id ) LOOP
    l_ue_ctr := l_ue_ctr + 1;
    l_child_ue_tbl(l_ue_ctr) := child_ue_rec;
    -- fix for bug number 7295717 (Sunil)
    IF(l_child_ue_tbl(l_ue_ctr).qa_inspection_type_code IS NULL)THEN
         l_child_ue_tbl(l_ue_ctr).qa_plan_id := NULL;
    ELSIF(l_child_ue_tbl(l_ue_ctr).qa_collection_id IS NOT NULL)THEN
         OPEN get_qa_plan_id_csr1(l_child_ue_tbl(l_ue_ctr).qa_collection_id);
         FETCH get_qa_plan_id_csr1 INTO l_child_ue_tbl(l_ue_ctr).qa_plan_id;
         CLOSE get_qa_plan_id_csr1;
    ELSE
         OPEN get_qa_plan_id_csr2(l_mr_rec.organization_id,l_child_ue_tbl(l_ue_ctr).qa_inspection_type_code);
         FETCH get_qa_plan_id_csr2 INTO l_child_ue_tbl(l_ue_ctr).qa_plan_id;
         CLOSE get_qa_plan_id_csr2;
    END IF;
  END LOOP;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Child UE Table Size '||l_child_ue_tbl.COUNT );
  END IF;
  -- Get the Child UE Details
  IF l_child_ue_tbl.COUNT > 0 THEN

        -- Reverse the order of signing off the Ues. First child UE then its parent
        -- etc.,Balaji modified the code for BAE bug.
	  FOR l_ue_count IN REVERSE l_child_ue_tbl.FIRST..l_child_ue_tbl.LAST LOOP
          IF ( G_DEBUG = 'Y' ) THEN
            AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : l_child_ue_tbl(l_ue_count).title '||l_child_ue_tbl(l_ue_count).title );
            AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : ump_status_code '||l_child_ue_tbl(l_ue_count).ump_status_code );
            AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : l_child_ue_tbl(l_ue_count).qa_collection_id '||l_child_ue_tbl(l_ue_count).qa_collection_id );
          END IF;
	    -- If top down signoff is required for the Child UEs
	    IF ( p_signoff_mr_rec.signoff_child_mrs_flag = 'Y' ) THEN

	      /*-- Check if the Child UE is complete
	      l_return_status:=
	      is_mr_complete
	      (
		p_mr_title             => l_child_ue_tbl(l_ue_count).title,
		p_status_code          => l_child_ue_tbl(l_ue_count).ump_status_code,
		p_status               => NULL,
		p_qa_inspection_type   => l_child_ue_tbl(l_ue_count).qa_inspection_type_code,
		p_qa_plan_id           => l_child_ue_tbl(l_ue_count).qa_plan_id,
		p_qa_collection_id     => l_child_ue_tbl(l_ue_count).qa_collection_id
	      );

	      IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
		RAISE FND_API.G_EXC_ERROR;
	      ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	      END IF;*/

	      -- Store the Child UEs in a table of records for Signing off
	      IF ( NVL(l_child_ue_tbl(l_ue_count).ump_status_code,'X') <> NVL(G_MR_STATUS_SIGNED_OFF,'Y') ) THEN
		-- If the derived status for child UE falls in any of below statuses then block their signoff
		-- B'cos they cannot be signed off really in these status.
		-- Balaji added for a part of Visit Closure BAE Bug.
		l_ue_status_code := get_mr_status( l_child_ue_tbl(l_ue_count).unit_effectivity_id );

		IF (
		      l_ue_status_code <> G_MR_STATUS_DEFERRED AND
		      l_ue_status_code <> G_MR_STATUS_TERMINATED AND
		      l_ue_status_code <> G_MR_STATUS_CANCELLED AND
                      l_ue_status_code <> G_MR_STATUS_MR_TERMINATED

		) THEN
		   -- Check if the Child UE is complete
	      l_return_status:=
	      is_mr_complete
	      (
		    p_mr_title             => l_child_ue_tbl(l_ue_count).title,
		    p_status_code          => l_child_ue_tbl(l_ue_count).ump_status_code,
		    p_status               => NULL,
		    p_qa_inspection_type   => l_child_ue_tbl(l_ue_count).qa_inspection_type_code,
		    p_qa_plan_id           => l_child_ue_tbl(l_ue_count).qa_plan_id,
		    p_qa_collection_id     => l_child_ue_tbl(l_ue_count).qa_collection_id
	      );

	      IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
		     RAISE FND_API.G_EXC_ERROR;
	      ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	      END IF;

			IF ( G_DEBUG = 'Y' ) THEN
			   AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : l_ue_status_code '||l_ue_status_code );
			END IF;

			l_ctr := l_ctr + 1;
			l_child_mr_tbl(l_ctr).unit_effectivity_id := l_child_ue_tbl(l_ue_count).unit_effectivity_id;
			l_child_mr_tbl(l_ctr).ue_object_version_no := l_child_ue_tbl(l_ue_count).object_version_number;
			l_child_mr_tbl(l_ctr).mr_title := l_child_ue_tbl(l_ue_count).title;
			l_child_mr_tbl(l_ctr).qa_collection_id := l_child_ue_tbl(l_ue_count).qa_collection_id;
		END IF;
	      END IF;
	    ELSE

	      -- Child UEs are not required to be signed off
	      -- Validate that the Child UEs are already signed off
	      -- Null check added by balaji for bug # 4078536
	      IF (
	           l_child_ue_tbl(l_ue_count).ump_status_code IS NULL OR
	           (
	            l_child_ue_tbl(l_ue_count).ump_status_code <> G_MR_STATUS_SIGNED_OFF AND
	            l_child_ue_tbl(l_ue_count).ump_status_code <> G_MR_STATUS_DEFERRED AND
	            l_child_ue_tbl(l_ue_count).ump_status_code <> G_MR_STATUS_CANCELLED AND
	            l_child_ue_tbl(l_ue_count).ump_status_code <> G_MR_STATUS_TERMINATED AND
                    l_child_ue_tbl(l_ue_count).ump_status_code <> G_MR_STATUS_MR_TERMINATED
	           )
	         )  THEN
		FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_CHILD_MRS_NOT_COMPL' );
		FND_MESSAGE.set_token( 'MAINT_REQ', l_mr_rec.ue_title);
		FND_MSG_PUB.add;
		RAISE FND_API.G_EXC_ERROR;
	      END IF;
	    END IF;
	  END LOOP;
  END IF;
  -- Add the given UE in the Table of UE Records to be signed Off
  l_ctr := l_ctr + 1;
  l_child_mr_tbl(l_ctr).unit_effectivity_id := l_mr_rec.unit_effectivity_id;
  l_child_mr_tbl(l_ctr).ue_object_version_no := l_mr_rec.ue_object_version_number;
  l_child_mr_tbl(l_ctr).mr_title := l_mr_rec.ue_title;
  l_child_mr_tbl(l_ctr).qa_collection_id := l_mr_rec.ue_qa_collection_id;

  l_ctr := 0;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Processing UE Workorders' );
  END IF;

  -- Get all the Workorders for the UE
  FOR wo_csr IN get_ue_workorders( l_mr_rec.wip_entity_id ) LOOP

    -- Check if Jobs and Operations need to be completed
    IF ( p_signoff_mr_rec.complete_job_ops_flag = 'Y' ) THEN

      -- Check if the Input Actual dates are required
      /*-- Start ER # 4757222
      IF ( p_signoff_mr_rec.default_actual_dates_flag = 'N' ) THEN

        -- Validate if the actual start dates entered is less than any WO
        IF ( wo_csr.actual_start_date IS NOT NULL AND
             wo_csr.actual_start_date < p_signoff_mr_rec.actual_start_date ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_ACT_ST_DATE_LESS' );
          FND_MESSAGE.set_token( 'WO_NAME', wo_csr.workorder_name );
          FND_MESSAGE.set_token( 'START_DT', TO_CHAR( wo_csr.actual_start_date , 'DD-MON-YYYY HH24:MI' ) );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Validate if the actual end dates entered is greater than any WO
        IF ( wo_csr.actual_end_date IS NOT NULL AND
             wo_csr.actual_end_date > p_signoff_mr_rec.actual_end_date ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_ACT_END_DATE_GT' );
          FND_MESSAGE.set_token( 'WO_NAME', wo_csr.workorder_name );
          FND_MESSAGE.set_token( 'END_DT', TO_CHAR( wo_csr.actual_end_date , 'DD-MON-YYYY HH24:MI' ) );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF; -- Check Input Dates are required
      */--End ER # 4757222
      -- Do not process Workorders which are already Complete
      IF ( wo_csr.status_code <> G_JOB_STATUS_COMPLETE AND
           wo_csr.status_code <> G_JOB_STATUS_COMPLETE_NC AND
           wo_csr.status_code <> G_JOB_STATUS_CLOSED AND
           wo_csr.status_code <> G_JOB_STATUS_CANCELLED ) THEN

	-- rroy
	-- ACL Changes
	l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(wo_csr.workorder_id, NULL, NULL, NULL);
	IF l_return_status = FND_API.G_TRUE THEN
  	  FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_SM_UNTLCKD');
	  FND_MESSAGE.Set_Token('MR_TITLE', l_mr_rec.ue_title);
	  FND_MSG_PUB.ADD;
	  RAISE FND_API.G_EXC_ERROR;
	END IF;
	--nsikka
	--Changes made for Bug 5324101 .
	--tokens passed changed to MR_TITLE
	-- rroy
	-- ACL Changes

        -- Validate whether the Workorders can be completed
        IF ( wo_csr.status_code = G_JOB_STATUS_UNRELEASED OR
             wo_csr.status_code = G_JOB_STATUS_ON_HOLD OR
             wo_csr.status_code = G_JOB_STATUS_PARTS_HOLD OR
             wo_csr.status_code = G_JOB_STATUS_DEFERRAL_PENDING ) THEN
        --Modified by Srini
	-- replacing with call to get_status function
	-- so no exceptions are thrown if the
        -- lookup does not exist
	l_job_status_meaning := get_status(wo_csr.status_code,
					'AHL_JOB_STATUS');

     	/*SELECT MEANING INTO l_job_status_meaning
          FROM fnd_lookup_values_vl
         WHERE lookup_type = 'AHL_JOB_STATUS'
	       AND lookup_code = wo_csr.status_code;
						*/
          FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_NOT_ALL_WOS_OPEN' );
          FND_MESSAGE.set_token( 'WO_NAME', wo_csr.workorder_name );
          FND_MESSAGE.set_token( 'STATUS', l_job_status_meaning );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Validate whether Quality Results are Submitted
        IF ( wo_csr.plan_id IS NOT NULL AND
             wo_csr.collection_id IS NULL ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_QA_PENDING' );
          FND_MESSAGE.set_token( 'WO_NAME', wo_csr.workorder_name );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Add the Workorder in the Workorder Records for Completion
        l_ctr := l_ctr + 1;
        l_workorder_tbl(l_ctr).workorder_id := wo_csr.workorder_id;
        l_workorder_tbl(l_ctr).object_version_number := wo_csr.object_version_number;
        l_workorder_tbl(l_ctr).workorder_name := wo_csr.workorder_name;
        l_workorder_tbl(l_ctr).wip_entity_id := wo_csr.wip_entity_id;
        l_workorder_tbl(l_ctr).master_workorder_flag := wo_csr.master_workorder_flag;
        l_workorder_tbl(l_ctr).collection_id := wo_csr.collection_id;
        IF ( wo_csr.master_workorder_flag = 'N' ) THEN
	  l_workorder_tbl(l_ctr).actual_start_date := wo_csr.actual_start_date;
	  l_workorder_tbl(l_ctr).actual_end_date := wo_csr.actual_end_date;
	ELSE
          -- Reset Actual Dates of Master WO
          l_workorder_tbl(l_ctr).actual_start_date := NULL;
          l_workorder_tbl(l_ctr).actual_end_date := NULL;
	END IF;

        -- Store the Actual Dates for Workorders
        -- No need to store actual dates for Master Workorders because it can be
        -- done only after updating the Actual dates of child Workorders
        /*Start ER # 4757222
         -- Balaji commented out the code as per the requirement in the BAE ER # 4757222.
         -- As per the new requirement, Work Order actual dates will be defaulted based
         -- on following logic.
         -- 1. Work Order actual start date is minimum of operation actual start dates.
         -- 2. Work Order actual end date is maximum of operation actual end dates.
        IF ( wo_csr.master_workorder_flag = 'N' ) THEN

          -- Check if Actual Date is already entered
          IF ( wo_csr.actual_start_date IS NULL ) THEN
	    -- R12
            -- Actual dates are no longer defaulted from scheduled dates
	    -- They are defaulted in the Completions API to the res txn dates
	    -- if p_default flag is passed as FND_API.G_TRUE
            /*IF ( p_signoff_mr_rec.default_actual_dates_flag = 'Y' ) THEN
              -- Update Actual Date with Scheduled Date
              l_workorder_tbl(l_ctr).actual_start_date := wo_csr.scheduled_start_date;
            ELSE
              -- Update Actual Date with User Entered Value
              l_workorder_tbl(l_ctr).actual_start_date := p_signoff_mr_rec.actual_start_date;
            END IF;
	    */
            /*IF ( p_signoff_mr_rec.default_actual_dates_flag = 'N' ) THEN
              -- Update Actual Date with User Entered Value
              l_workorder_tbl(l_ctr).actual_start_date := p_signoff_mr_rec.actual_start_date;
            END IF;
          ELSE
            -- Update Actual Date with DB Value if already entered
            l_workorder_tbl(l_ctr).actual_start_date := wo_csr.actual_start_date;
          END IF;

          -- Check if Actual Date is already entered
          IF ( wo_csr.actual_end_date IS NULL ) THEN
	    -- R12
            -- Actual dates are no longer defaulted from scheduled dates
	    -- They are defaulted in the Completions API to the res txn dates
	    -- if p_default flag is passed as FND_API.G_TRUE

            /*IF ( p_signoff_mr_rec.default_actual_dates_flag = 'Y' ) THEN
              -- Update Actual Date with Scheduled Date
              l_workorder_tbl(l_ctr).actual_end_date := LEAST( SYSDATE , wo_csr.scheduled_end_date );
            ELSE
              -- Update Actual Date with User Entered Value
              l_workorder_tbl(l_ctr).actual_end_date := p_signoff_mr_rec.actual_end_date;
            END IF;
	    */
            /*IF ( p_signoff_mr_rec.default_actual_dates_flag = 'N' ) THEN
              -- Update Actual Date with User Entered Value
              l_workorder_tbl(l_ctr).actual_end_date := p_signoff_mr_rec.actual_end_date;
            END IF;
          ELSE
            -- Update Actual Date with DB Value if already entered
            l_workorder_tbl(l_ctr).actual_end_date := wo_csr.actual_end_date;
          END IF;

          IF ( G_DEBUG = 'Y' ) THEN
            AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
            || ' : Wo Name - ' || l_workorder_tbl(l_ctr).workorder_name
            || ' WO ID - ' || l_workorder_tbl(l_ctr).workorder_id
            || ' Actual Start Date - ' || l_workorder_tbl(l_ctr).actual_start_date
            || ' Actual End Date - ' || l_workorder_tbl(l_ctr).actual_end_date );
          END IF;

        ELSIF ( wo_csr.master_workorder_flag = 'Y' ) THEN

          -- Reset Actual Dates of Master WO
          l_workorder_tbl(l_ctr).actual_start_date := NULL;
          l_workorder_tbl(l_ctr).actual_end_date := NULL;

        END IF; -- Check Master Workorder
	*/--End ER # 4757222
      END IF; -- Check Workorder Complete

    ELSE

      -- Since Workorders need not be completed
      -- Validate to ensure that the Workorders are already completed
      -- This validation should not be done for master workorders
      -- since their status is determined internally. Balaji added this
      -- fix for the BAE bug # 4626717.
      IF ( wo_csr.status_code <> G_JOB_STATUS_COMPLETE AND
           wo_csr.status_code <> G_JOB_STATUS_COMPLETE_NC AND
           wo_csr.status_code <> G_JOB_STATUS_CLOSED AND
           wo_csr.status_code <> G_JOB_STATUS_CANCELLED AND
           wo_csr.master_workorder_flag = 'N') THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_MR_WO_NOT_CMPL' );
        FND_MESSAGE.set_token( 'MAINT_REQ', l_mr_rec.ue_title);
        FND_MESSAGE.set_token( 'WO_NAME', wo_csr.workorder_name );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF; -- Check Complete Workorder Flag

  END LOOP; -- Iterate all MR Workorders

  -- Add the UE Workorder for Updates
  -- Do not process UE Workorders if it is already Complete
  IF ( l_mr_rec.wo_status_code <> G_JOB_STATUS_COMPLETE AND
       l_mr_rec.wo_status_code <> G_JOB_STATUS_COMPLETE_NC AND
       l_mr_rec.wo_status_code <> G_JOB_STATUS_CLOSED AND
       l_mr_rec.wo_status_code <> G_JOB_STATUS_CANCELLED ) THEN

-- JKJain, Bug 9250614
    -- Check if Jobs and Operations need to be completed
--    IF ( p_signoff_mr_rec.complete_job_ops_flag = 'Y' ) THEN

      -- Validate Whether Quality Results are submitted for WO
      IF ( l_mr_rec.wo_plan_id IS NOT NULL AND
           l_mr_rec.wo_collection_id IS NULL ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_QA_PENDING' );
        FND_MESSAGE.set_token( 'WO_NAME', l_mr_rec.workorder_name );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Add the UE Master WO to the Workorder Table of Records
      l_ctr := l_ctr + 1;
      l_workorder_tbl(l_ctr).workorder_id := l_mr_rec.workorder_id;
      l_workorder_tbl(l_ctr).object_version_number := l_mr_rec.wo_object_version_number;
      l_workorder_tbl(l_ctr).workorder_name := l_mr_rec.workorder_name;
      l_workorder_tbl(l_ctr).wip_entity_id := l_mr_rec.wip_entity_id;
						-- fix mde for bug 4087041
						-- master_wo_flag cannot be hardcoded to Y in this case because
						-- this may also be an unassociated task created after SR creation from Production
      l_workorder_tbl(l_ctr).master_workorder_flag := l_mr_rec.master_workorder_flag; --'Y';
      l_workorder_tbl(l_ctr).collection_id := l_mr_rec.wo_collection_id;
						-- fix mde for bug 4087041
						-- now since the master_wo_flag may be 'N', we cannot hardcode actual dates to null
						IF l_workorder_tbl(l_ctr).master_workorder_flag = 'N' THEN
						 -- Check if the Input Actual dates are required
       /*Start ER # 4757222
       IF ( p_signoff_mr_rec.default_actual_dates_flag = 'N' ) THEN

        -- Validate if the actual start dates entered is less than any WO
        IF ( l_mr_rec.actual_start_date IS NOT NULL AND
             l_mr_rec.actual_start_date < p_signoff_mr_rec.actual_start_date ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_ACT_ST_DATE_LESS' );
          FND_MESSAGE.set_token( 'WO_NAME', l_mr_rec.workorder_name );
          FND_MESSAGE.set_token( 'START_DT', TO_CHAR( l_mr_rec.actual_start_date , 'DD-MON-YYYY HH24:MI' ) );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Validate if the actual end dates entered is greater than any WO
        IF ( l_mr_rec.actual_end_date IS NOT NULL AND
             l_mr_rec.actual_end_date > p_signoff_mr_rec.actual_end_date ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_ACT_END_DATE_GT' );
          FND_MESSAGE.set_token( 'WO_NAME', l_mr_rec.workorder_name );
          FND_MESSAGE.set_token( 'END_DT', TO_CHAR( l_mr_rec.actual_end_date , 'DD-MON-YYYY HH24:MI' ) );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF; -- Check Input Dates are required
       */--End ER # 4757222
       l_workorder_tbl(l_ctr).actual_start_date := l_mr_rec.actual_start_date;
       l_workorder_tbl(l_ctr).actual_end_date := l_mr_rec.actual_start_date;

 	/*Start ER # 4757222
 									-- Check if Actual Date is already entered
          IF ( l_mr_rec.actual_start_date IS NULL ) THEN
	    -- R12
            -- Actual dates are no longer defaulted from scheduled dates
	    -- They are defaulted in the Completions API to the res txn dates
	    -- if p_default flag is passed as FND_API.G_TRUE

            /*IF ( p_signoff_mr_rec.default_actual_dates_flag = 'Y' ) THEN
              -- Update Actual Date with Scheduled Date
              l_workorder_tbl(l_ctr).actual_start_date := l_mr_rec.scheduled_start_date;
            ELSE
              -- Update Actual Date with User Entered Value
              l_workorder_tbl(l_ctr).actual_start_date := p_signoff_mr_rec.actual_start_date;
            END IF;
	    */
            /*IF ( p_signoff_mr_rec.default_actual_dates_flag = 'N' ) THEN
              -- Update Actual Date with User Entered Value
              l_workorder_tbl(l_ctr).actual_start_date := p_signoff_mr_rec.actual_start_date;
            END IF;
          ELSE
            -- Update Actual Date with DB Value if already entered
            l_workorder_tbl(l_ctr).actual_start_date := l_mr_rec.actual_start_date;
          END IF;

          -- Check if Actual Date is already entered
          IF ( l_mr_rec.actual_end_date IS NULL ) THEN
            IF ( p_signoff_mr_rec.default_actual_dates_flag = 'Y' ) THEN
              -- Update Actual Date with Scheduled Date
              l_workorder_tbl(l_ctr).actual_end_date := LEAST( SYSDATE , l_mr_rec.scheduled_end_date );
            ELSE
              -- Update Actual Date with User Entered Value
              l_workorder_tbl(l_ctr).actual_end_date := p_signoff_mr_rec.actual_end_date;
            END IF;
          ELSE
            -- Update Actual Date with DB Value if already entered
            l_workorder_tbl(l_ctr).actual_end_date := l_mr_rec.actual_end_date;
          END IF;
          */--End ER # 4757222

						 ELSE
      -- Reset Actual Date of UE Master WO
      l_workorder_tbl(l_ctr).actual_start_date := NULL;
      l_workorder_tbl(l_ctr).actual_end_date := NULL;
						END IF;
						-- end of changes for 4087041
-- JKJain, Bug 9250614
--    END IF; -- Check Complet Jobs Flag

  END IF; -- Check Complete UE

  /* Bug # 4955278 - start */
  /*
   * Interchanged resource transaction logic before processing operations
   */
  l_ctr := 0;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
    || ' : Before Processing Resource Transactions' );
  END IF;

  -- Check if Resources need to transacted
  IF ( p_signoff_mr_rec.transact_resource_flag = 'Y' ) THEN

    -- Get all the Resource Requirements for the UE Operations
    FOR res_csr IN get_ue_resource_req( l_mr_rec.wip_entity_id ) LOOP

      -- Validate if Equipment is entered for Machine Type Resource
      IF ( res_csr.resource_type = 1 AND
           ( p_signoff_mr_rec.serial_number IS NULL OR
             p_signoff_mr_rec.serial_number = FND_API.G_MISS_CHAR ) ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_MACH_RES_REQD' );
        FND_MESSAGE.set_token( 'WO_NAME', res_csr.workorder_name );
        FND_MESSAGE.set_token( 'OP_SEQ', res_csr.operation_seq_num );
        FND_MESSAGE.set_token( 'RES_SEQ', res_csr.resource_seq_num );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Validate if Technicain is entered for Person Type Resource
      IF ( res_csr.resource_type = 2 AND
           ( p_signoff_mr_rec.employee_number IS NULL OR
             p_signoff_mr_rec.employee_number = FND_API.G_MISS_CHAR ) ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_EMP_RES_REQD' );
        FND_MESSAGE.set_token( 'WO_NAME', res_csr.workorder_name );
        FND_MESSAGE.set_token( 'OP_SEQ', res_csr.operation_seq_num );
        FND_MESSAGE.set_token( 'RES_SEQ', res_csr.resource_seq_num );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Add the Resource Requirement in a Table for processing transactions
      l_ctr := l_ctr + 1;
      l_resource_req_tbl(l_ctr).wip_entity_id := res_csr.wip_entity_id;
      l_resource_req_tbl(l_ctr).workorder_name := res_csr.workorder_name;
      l_resource_req_tbl(l_ctr).workorder_id  := res_csr.workorder_id;
      l_resource_req_tbl(l_ctr).operation_seq_num := res_csr.operation_seq_num;
      l_resource_req_tbl(l_ctr).workorder_operation_id := res_csr.workorder_operation_id;
      l_resource_req_tbl(l_ctr).resource_seq_num := res_csr.resource_seq_num;
      l_resource_req_tbl(l_ctr).organization_id := res_csr.organization_id;
      l_resource_req_tbl(l_ctr).department_id := res_csr.department_id;
      l_resource_req_tbl(l_ctr).resource_name := res_csr.resource_name;
      l_resource_req_tbl(l_ctr).resource_id := res_csr.resource_id;
      l_resource_req_tbl(l_ctr).resource_type := res_csr.resource_type;
      l_resource_req_tbl(l_ctr).uom_code := res_csr.uom_code;
      l_resource_req_tbl(l_ctr).usage_rate_or_amount := res_csr.usage_rate_or_amount;

    END LOOP; -- Iterate Resource Requirements


    -- Code added by balaji for bug # 4955278
    -- Above loop doesnt fetch res req for operations belonging to
    -- a workorder originated out of NR created in production floor or
    -- a workorder created out of unassociated task which will not have
    -- any related workorders. Hence this need to be processed seperately
    -- as below.
    -- Get all the Resource Requirements for the UE Operations
    IF l_ctr = 0 THEN
	    FOR unass_res_csr IN get_unass_ue_resource_req( l_mr_rec.wip_entity_id ) LOOP

	      -- Validate if Equipment is entered for Machine Type Resource
	      IF ( unass_res_csr.resource_type = 1 AND
		   ( p_signoff_mr_rec.serial_number IS NULL OR
		     p_signoff_mr_rec.serial_number = FND_API.G_MISS_CHAR ) ) THEN
		FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_MACH_RES_REQD' );
		FND_MESSAGE.set_token( 'WO_NAME', unass_res_csr.workorder_name );
		FND_MESSAGE.set_token( 'OP_SEQ', unass_res_csr.operation_seq_num );
		FND_MESSAGE.set_token( 'RES_SEQ', unass_res_csr.resource_seq_num );
		FND_MSG_PUB.add;
		RAISE FND_API.G_EXC_ERROR;
	      END IF;

	      -- Validate if Technicain is entered for Person Type Resource
	      IF ( unass_res_csr.resource_type = 2 AND
		   ( p_signoff_mr_rec.employee_number IS NULL OR
		     p_signoff_mr_rec.employee_number = FND_API.G_MISS_CHAR ) ) THEN
		FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_EMP_RES_REQD' );
		FND_MESSAGE.set_token( 'WO_NAME', unass_res_csr.workorder_name );
		FND_MESSAGE.set_token( 'OP_SEQ', unass_res_csr.operation_seq_num );
		FND_MESSAGE.set_token( 'RES_SEQ', unass_res_csr.resource_seq_num );
		FND_MSG_PUB.add;
		RAISE FND_API.G_EXC_ERROR;
	      END IF;

	      -- Add the Resource Requirement in a Table for processing transactions
	      l_ctr := l_ctr + 1;
	      l_resource_req_tbl(l_ctr).wip_entity_id := unass_res_csr.wip_entity_id;
	      l_resource_req_tbl(l_ctr).workorder_name := unass_res_csr.workorder_name;
	      l_resource_req_tbl(l_ctr).workorder_id  := unass_res_csr.workorder_id;
	      l_resource_req_tbl(l_ctr).operation_seq_num := unass_res_csr.operation_seq_num;
	      l_resource_req_tbl(l_ctr).workorder_operation_id := unass_res_csr.workorder_operation_id;
	      l_resource_req_tbl(l_ctr).resource_seq_num := unass_res_csr.resource_seq_num;
	      l_resource_req_tbl(l_ctr).organization_id := unass_res_csr.organization_id;
	      l_resource_req_tbl(l_ctr).department_id := unass_res_csr.department_id;
	      l_resource_req_tbl(l_ctr).resource_name := unass_res_csr.resource_name;
	      l_resource_req_tbl(l_ctr).resource_id := unass_res_csr.resource_id;
	      l_resource_req_tbl(l_ctr).resource_type := unass_res_csr.resource_type;
	      l_resource_req_tbl(l_ctr).uom_code := unass_res_csr.uom_code;
	      l_resource_req_tbl(l_ctr).usage_rate_or_amount := unass_res_csr.usage_rate_or_amount;

	    END LOOP; -- Iterate Resource Requirements
    END IF;

    l_ctr := 0;

  END IF; -- Check Transact Resource Flag

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
    || ' : Before Calling resource request table:' ||l_resource_req_tbl.COUNT);
  END IF;

  IF ( l_resource_req_tbl.COUNT > 0 ) THEN

    -- Get the Employee ID of Technician
    /* SELECT  person_id
    INTO    l_employee_id
    FROM    PER_PEOPLE_F
    WHERE   employee_number = p_signoff_mr_rec.employee_number
      AND   rownum = 1; */

    BEGIN
       -- Fix for bug# 4553747.
       SELECT employee_id
       INTO l_employee_id
       FROM  mtl_employees_current_view
       WHERE organization_id = l_mr_rec.organization_id
         AND employee_num =   p_signoff_mr_rec.employee_number
         AND rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_EMPLOYEE_NOT_FOUND' );
        FND_MESSAGE.set_token( 'EMP_NUM', p_signoff_mr_rec.employee_number );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
    END;

    /*IF ( SQL%NOTFOUND ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_EMPLOYEE_NOT_FOUND' );
      FND_MESSAGE.set_token( 'EMP_NUM', p_signoff_mr_rec.employee_number );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;*/

    -- Process all Resource Requirements
    FOR i IN l_resource_req_tbl.FIRST..l_resource_req_tbl.LAST LOOP

      -- Get the Resource Transactions performed against a Requirement
      OPEN  get_resource_txns( l_resource_req_tbl(i).wip_entity_id,
                               l_resource_req_tbl(i).operation_seq_num,
                               l_resource_req_tbl(i).resource_seq_num);
      FETCH get_resource_txns
      INTO  l_txn_qty;
      CLOSE get_resource_txns;

      /*
      IF ( l_transaction_qty > 0 ) THEN

        -- Subtract the consumed quantity from the required quantity
        l_resource_req_tbl(i).transaction_quantity := l_resource_req_tbl(i).usage_rate_or_amount - l_transaction_qty;
        l_transaction_qty := 0;
      END IF;
      */
      -- Get the Pending Resource Transactions performed against a Requirement
      OPEN  get_pending_resource_txns( l_resource_req_tbl(i).wip_entity_id,
                                       l_resource_req_tbl(i).operation_seq_num,
                                       l_resource_req_tbl(i).resource_seq_num);
      FETCH get_pending_resource_txns
      INTO  l_pending_txn_qty;
      CLOSE get_pending_resource_txns;

      /*
      IF ( l_transaction_qty > 0 ) THEN
        IF ( l_resource_req_tbl(i).transaction_quantity <> 0 ) THEN

          -- Subtract the consumed quantity from the required quantity
          l_resource_req_tbl(i).transaction_quantity := l_resource_req_tbl(i).transaction_quantity - l_transaction_qty;
        ELSE

          -- Subtract the consumed quantity from the required quantity
          l_resource_req_tbl(i).transaction_quantity := l_resource_req_tbl(i).usage_rate_or_amount - l_transaction_qty;
        END IF;

        l_transaction_qty := 0;
      END IF;
      */

      -- Subtract the consumed quantity from the required quantity
      l_resource_req_tbl(i).transaction_quantity := l_resource_req_tbl(i).usage_rate_or_amount - l_txn_qty - l_pending_txn_qty;

      IF ( G_DEBUG = 'Y' ) THEN
	    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
	    || ' :l_resource_req_tbl(i).usage_rate_or_amount--> :' ||l_resource_req_tbl(i).usage_rate_or_amount);
	     AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
	    || ' :l_txn_qty--> :' ||l_txn_qty);
	     AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
	    || ' :l_txn_qty--> :' ||l_pending_txn_qty);
      END IF;

      -- If the required qty is greater than zero then txn needs to be performed
      IF ( l_resource_req_tbl(i).transaction_quantity > 0 ) THEN

        -- Add a Resource Transaction Record
        l_ctr := l_ctr + 1;

        /*
        l_res_txn_tbl(l_ctr).wip_entity_id := l_resource_req_tbl(i).wip_entity_id;
        --l_res_txn_tbl(l_ctr).organization_id := l_resource_req_tbl(i).organization_id;
        l_res_txn_tbl(l_ctr).department_id := l_resource_req_tbl(i).department_id;
        l_res_txn_tbl(l_ctr).operation_seq_num := l_resource_req_tbl(i).operation_seq_num;
        l_res_txn_tbl(l_ctr).resource_seq_num := l_resource_req_tbl(i).resource_seq_num;
        l_res_txn_tbl(l_ctr).resource_id := l_resource_req_tbl(i).resource_id;
        l_res_txn_tbl(l_ctr).transaction_quantity := l_resource_req_tbl(i).transaction_quantity;
        l_res_txn_tbl(l_ctr).transaction_uom := l_resource_req_tbl(i).uom_code;
        */


        l_prd_resrc_txn_tbl(l_ctr).workorder_id := l_resource_req_tbl(i).workorder_id;
        l_prd_resrc_txn_tbl(l_ctr).organization_id := l_resource_req_tbl(i).organization_id;
        l_prd_resrc_txn_tbl(l_ctr).dml_operation := 'C';
        l_prd_resrc_txn_tbl(l_ctr).operation_sequence_num := l_resource_req_tbl(i).operation_seq_num;
        l_prd_resrc_txn_tbl(l_ctr).workorder_operation_id := l_resource_req_tbl(i).workorder_operation_id;
        l_prd_resrc_txn_tbl(l_ctr).resource_sequence_num := l_resource_req_tbl(i).resource_seq_num;
        l_prd_resrc_txn_tbl(l_ctr).resource_id := l_resource_req_tbl(i).resource_id;
        l_prd_resrc_txn_tbl(l_ctr).resource_name := l_resource_req_tbl(i).resource_name;

        l_prd_resrc_txn_tbl(l_ctr).department_id := l_resource_req_tbl(i).department_id;

        l_prd_resrc_txn_tbl(l_ctr).qty := l_resource_req_tbl(i).transaction_quantity;
        l_prd_resrc_txn_tbl(l_ctr).uom_code := l_resource_req_tbl(i).uom_code;

        -- Pass the Employee ID or the Serial Number
        IF ( l_resource_req_tbl(i).resource_type = 2 ) THEN
          --l_res_txn_tbl(l_ctr).employee_id := l_employee_id;
          l_prd_resrc_txn_tbl(l_ctr).employee_num := p_signoff_mr_rec.employee_number;
        ELSIF ( l_resource_req_tbl(i).resource_type = 1 ) THEN
          --l_res_txn_tbl(l_ctr).serial_number := p_signoff_mr_rec.serial_number;
          l_prd_resrc_txn_tbl(l_ctr).serial_number := p_signoff_mr_rec.serial_number;
        END IF;

      END IF; -- Check Txn Required

    END LOOP; -- Iterate Requirements

    IF ( G_DEBUG = 'Y' ) THEN
	    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
	    || ' : size of l_prd_resrc_txn_tbl is:' ||l_prd_resrc_txn_tbl.COUNT);
    END IF;

    --IF ( l_res_txn_tbl.COUNT > 0 ) THEN
    IF ( l_prd_resrc_txn_tbl.COUNT > 0 ) THEN

      -- Perform the Resource Txns

      /*
      AHL_WIP_JOB_PVT.insert_resource_txn
      (
        p_api_version        => 1.0,
        p_init_msg_list      => FND_API.G_FALSE,
        p_commit             => FND_API.G_FALSE,
        p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,
        p_ahl_res_txn_tbl    => l_res_txn_tbl
      );
      */

      AHL_PRD_RESOURCE_TRANX_PVT.PROCESS_RESOURCE_TXNS
      (
        p_api_version        => 1.0,
        p_init_msg_list      => FND_API.G_FALSE,
        p_commit             => FND_API.G_FALSE,
        p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,
        p_x_prd_resrc_txn_tbl => l_prd_resrc_txn_tbl
      );

      IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

  END IF;
  /* Bug # 4955278 - end */

  l_ctr := 0;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Processing UE Operations' );
  END IF;

  -- Get all the Workorder Operations for the UE
  FOR op_csr IN get_ue_operations( l_mr_rec.wip_entity_id ) LOOP

    -- Check if Operations need to be completed
    IF ( p_signoff_mr_rec.complete_job_ops_flag = 'Y' ) THEN

      -- Do not process Workorder Operations which are already Complete
      IF ( op_csr.status_code <> G_OP_STATUS_COMPLETE ) THEN

        /*Start ER # 4757222*/
        /*
         * Moved this validation here since there is no need to validate
         * the actual dates entered against completed operations. Need to validate dates
         * against only those operations which need to be completed.
         */
      -- Check if the Input Actual dates are required
     /* No need for this validation as the default dates entered by the user should not
     -- be modified. Balaji commented out the code for the ER # 4757222
      IF ( p_signoff_mr_rec.default_actual_dates_flag = 'N' ) THEN

        -- Validate if the actual start dates entered is less than any WO Op
        IF ( op_csr.actual_start_date IS NOT NULL AND
             op_csr.actual_start_date < p_signoff_mr_rec.actual_start_date ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_OP_ACT_ST_DATE_LESS' );
          FND_MESSAGE.set_token( 'WO_NAME', op_csr.workorder_name );
          FND_MESSAGE.set_token( 'OP_SEQ', op_csr.operation_seq_num );
          FND_MESSAGE.set_token( 'START_DT', TO_CHAR( op_csr.actual_start_date, 'DD-MON-YYYY HH24:MI' ) );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Validate if the actual end dates entered is greater than any WO Op
        IF ( op_csr.actual_end_date IS NOT NULL AND
             op_csr.actual_end_date > p_signoff_mr_rec.actual_end_date ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_OP_ACT_END_DATE_GT' );
          FND_MESSAGE.set_token( 'WO_NAME', op_csr.workorder_name );
          FND_MESSAGE.set_token( 'OP_SEQ', op_csr.operation_seq_num );
          FND_MESSAGE.set_token( 'END_DT', TO_CHAR( op_csr.actual_end_date, 'DD-MON-YYYY HH24:MI' ) );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF;
      */
      /*End ER # 4757222*/

        -- Validate whether Quality Results are Submitted
        IF ( op_csr.plan_id IS NOT NULL AND
             op_csr.collection_id IS NULL ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_OP_QA_PENDING' );
          FND_MESSAGE.set_token( 'WO_NAME', op_csr.workorder_name );
          FND_MESSAGE.set_token( 'OP_SEQ', op_csr.operation_seq_num );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Add the Wo Operation record in the table of records for Completion
        l_ctr := l_ctr + 1;
        l_operation_tbl(l_ctr).workorder_operation_id := op_csr.workorder_operation_id;
        l_operation_tbl(l_ctr).object_version_number := op_csr.object_version_number;
        l_operation_tbl(l_ctr).workorder_name := op_csr.workorder_name;
        l_operation_tbl(l_ctr).collection_id := op_csr.collection_id;

	/* Bug # 4955278 - start */
	IF (op_csr.actual_end_date IS NULL OR op_csr.actual_start_date IS NULL)
	   AND
	   (p_signoff_mr_rec.default_actual_dates_flag = 'Y')
	THEN
		-- Derive operation actual dates from res txn dates.
		-- Balaji added this code for R12. Also refer ER # 4955278
   		Get_Op_Act_from_Res_Txn( p_wip_entity_id	=>	op_csr.wip_entity_id,
					 p_operation_seq_num	=>	op_csr.operation_seq_num,
					 x_actual_start_date	=>	l_def_actual_start_date,
					 x_actual_end_date	=>	l_def_actual_end_date
					);

		IF (l_def_actual_start_date IS NULL OR
		    l_def_actual_end_date IS NULL )
		THEN
		  FND_MESSAGE.set_name( 'AHL', 'AHL_OP_DEF_NO_RES_TXN' );
		  FND_MESSAGE.set_token( 'WO_NAME', op_csr.workorder_name );
		  FND_MESSAGE.set_token( 'OP_SEQ', op_csr.operation_seq_num );
		  FND_MSG_PUB.add;
		  RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;
	/* Bug # 4955278 - end */

	/*Start ER # 4757222*/
	-- Changed the order of defaulting to be first end date and then start date for
	-- the ER.
	/* Bug # 4955278 - start */
        -- Update Actual Date only if it is empty
        IF ( op_csr.actual_end_date IS NULL ) THEN
          IF ( p_signoff_mr_rec.default_actual_dates_flag = 'Y' ) THEN
            -- Update with Scheduled End Date or SYSDATE
            l_operation_tbl(l_ctr).actual_end_date := LEAST( SYSDATE , l_def_actual_end_date );
          ELSE
            -- Update with User Entered Value
            l_operation_tbl(l_ctr).actual_end_date := p_signoff_mr_rec.actual_end_date;
          END IF;
        ELSE

          -- Update with DB Value
          l_operation_tbl(l_ctr).actual_end_date := op_csr.actual_end_date;
        END IF;

        -- Update Actual Date only if it is empty
        IF ( op_csr.actual_start_date IS NULL ) THEN
          IF ( p_signoff_mr_rec.default_actual_dates_flag = 'Y' ) THEN
            -- Update with Scheduled Date
            IF ( l_def_actual_start_date < SYSDATE ) THEN
               l_operation_tbl(l_ctr).actual_start_date := l_def_actual_start_date;
            ELSE
               l_operation_tbl(l_ctr).actual_start_date := l_operation_tbl(l_ctr).actual_end_date - (l_def_actual_end_date - l_def_actual_start_date);
            END IF;
          ELSE
            -- Update with User Entered Value
            l_operation_tbl(l_ctr).actual_start_date := p_signoff_mr_rec.actual_start_date;
          END IF;
        ELSE

          -- Update with DB Value
          l_operation_tbl(l_ctr).actual_start_date := op_csr.actual_start_date;
        END IF;
        /*End ER # 4757222*/
	/* Bug # 4955278 - end */
        IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
          || ' : Wo Name - ' || l_operation_tbl(l_ctr).workorder_name
          || ' OP Seq - ' || op_csr.operation_seq_num || ' WO OP ID - '
          || l_operation_tbl(l_ctr).workorder_operation_id || ' Actual Start Date - '
          || TO_CHAR(l_operation_tbl(l_ctr).actual_start_date,'DD-MON-YYYY HH24:MI:SS') || ' Actual End Date - '
          || TO_CHAR(l_operation_tbl(l_ctr).actual_end_date,'DD-MON-YYYY HH24:MI:SS') );
        END IF;

      END IF;
    ELSE

      -- Since Operations are not required to be completed
      -- Validate to ensure that the Workorder Ops are already completed
      IF ( op_csr.status_code <> G_OP_STATUS_COMPLETE ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_MR_WO_OP_NOT_CMPL' );
        FND_MESSAGE.set_token( 'MAINT_REQ', l_mr_rec.ue_title);
        FND_MESSAGE.set_token( 'WO_NAME', op_csr.workorder_name );
        FND_MESSAGE.set_token( 'OP_SEQ', op_csr.operation_seq_num );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF; -- Check Complete Operations

  END LOOP; -- Iterate Operations

  -- for a ue that is assocaited to an Unassocaited Task created as a result of
		-- SR creation from Production
		-- There will not be any child UE operations and we need to
		-- take in the default operation associated with that workorder
  -- bug 4087041
 /*Start ER # 4757222*/
 --An workorder orginating out of unassociated task(either through unassociated task
 --created in production or thorugh the backward flow during NR creation in production)
 -- can have multiple operations in it. previous logic doesnt fetch all operations
 -- Balaji modified the logic for ER #4757222.
 IF l_ctr = 0 THEN
		--OPEN get_unassoc_ue_op(l_mr_rec.wip_entity_id);
		--FETCH get_unassoc_ue_op INTO l_unassoc_ue_op_rec;
		--IF get_unassoc_ue_op%FOUND THEN
		  -- populate the operation table
 			-- Check if Operations need to be completed
    FOR l_unassoc_ue_op_rec IN get_unassoc_ue_op( l_mr_rec.wip_entity_id )
    LOOP

    IF ( G_DEBUG = 'Y' ) THEN
       AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
	|| ' : Wo op id - ' ||l_unassoc_ue_op_rec.workorder_operation_id);
    END IF;

	    IF ( p_signoff_mr_rec.complete_job_ops_flag = 'Y' ) THEN

	      -- Do not process Workorder Operations which are already Complete
	      IF ( l_unassoc_ue_op_rec.status_code <> G_OP_STATUS_COMPLETE ) THEN

		/*Start ER # 4757222*/
		/*
		 * Moved this validation here since there is no need to validate
		 * the actual dates entered against completed operations. Need to validate dates
		 * against only those operations which need to be completed.
		 */
	      -- Check if the Input Actual dates are required
		/* No need for this validation as the default dates entered by the user should not
		-- be modified. Balaji commented out the code for the ER # 4757222

	      IF ( p_signoff_mr_rec.default_actual_dates_flag = 'N' ) THEN

		-- Validate if the actual start dates entered is less than any WO Op
		IF ( l_unassoc_ue_op_rec.actual_start_date IS NOT NULL AND
		     l_unassoc_ue_op_rec.actual_start_date < p_signoff_mr_rec.actual_start_date ) THEN
		  FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_OP_ACT_ST_DATE_LESS' );
		  FND_MESSAGE.set_token( 'WO_NAME', l_unassoc_ue_op_rec.workorder_name );
		  FND_MESSAGE.set_token( 'OP_SEQ', l_unassoc_ue_op_rec.operation_seq_num );
		  FND_MESSAGE.set_token( 'START_DT', TO_CHAR( l_unassoc_ue_op_rec.actual_start_date, 'DD-MON-YYYY HH24:MI' ) );
		  FND_MSG_PUB.add;
		  RAISE FND_API.G_EXC_ERROR;
		END IF;

		-- Validate if the actual end dates entered is greater than any WO Op
		IF ( l_unassoc_ue_op_rec.actual_end_date IS NOT NULL AND
		     l_unassoc_ue_op_rec.actual_end_date > p_signoff_mr_rec.actual_end_date ) THEN
		  FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_OP_ACT_END_DATE_GT' );
		  FND_MESSAGE.set_token( 'WO_NAME', l_unassoc_ue_op_rec.workorder_name );
		  FND_MESSAGE.set_token( 'OP_SEQ', l_unassoc_ue_op_rec.operation_seq_num );
		  FND_MESSAGE.set_token( 'END_DT', TO_CHAR( l_unassoc_ue_op_rec.actual_end_date, 'DD-MON-YYYY HH24:MI' ) );
		  FND_MSG_PUB.add;
		  RAISE FND_API.G_EXC_ERROR;
		     END IF;
		END IF; */
		/*End ER # 4757222*/


		-- Validate whether Quality Results are Submitted
		IF ( l_unassoc_ue_op_rec.plan_id IS NOT NULL AND
		     l_unassoc_ue_op_rec.collection_id IS NULL ) THEN
		  FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_OP_QA_PENDING' );
		  FND_MESSAGE.set_token( 'WO_NAME', l_unassoc_ue_op_rec.workorder_name );
		  FND_MESSAGE.set_token( 'OP_SEQ', l_unassoc_ue_op_rec.operation_seq_num );
		  FND_MSG_PUB.add;
		  RAISE FND_API.G_EXC_ERROR;
		END IF;

		-- Add the Wo Operation record in the table of records for Completion
		l_ctr := l_ctr + 1;
		l_operation_tbl(l_ctr).workorder_operation_id := l_unassoc_ue_op_rec.workorder_operation_id;
		l_operation_tbl(l_ctr).object_version_number := l_unassoc_ue_op_rec.object_version_number;
		l_operation_tbl(l_ctr).workorder_name := l_unassoc_ue_op_rec.workorder_name;
		l_operation_tbl(l_ctr).collection_id := l_unassoc_ue_op_rec.collection_id;

		/* Bug # 4955278 - start */
		IF (l_unassoc_ue_op_rec.actual_end_date IS NULL OR l_unassoc_ue_op_rec.actual_start_date IS NULL)
		   AND
		   (p_signoff_mr_rec.default_actual_dates_flag = 'Y')
		THEN
			-- Derive operation actual dates from res txn dates.
			-- Balaji added this code for R12. Also refer ER # 4955278
			Get_Op_Act_from_Res_Txn( p_wip_entity_id	=>	l_unassoc_ue_op_rec.wip_entity_id,
						 p_operation_seq_num	=>	l_unassoc_ue_op_rec.operation_seq_num,
						 x_actual_start_date	=>	l_def_actual_start_date,
						 x_actual_end_date	=>	l_def_actual_end_date
						);

			IF (l_def_actual_start_date IS NULL OR l_def_actual_end_date IS NULL )
			THEN
			  FND_MESSAGE.set_name( 'AHL', 'AHL_OP_DEF_NO_RES_TXN' );
			  FND_MESSAGE.set_token( 'WO_NAME', l_unassoc_ue_op_rec.workorder_name );
			  FND_MESSAGE.set_token( 'OP_SEQ', l_unassoc_ue_op_rec.operation_seq_num );
			  FND_MSG_PUB.add;
			  RAISE FND_API.G_EXC_ERROR;
			END IF;
		END IF;
		/* Bug # 4955278 - end */

		-- Update Actual Date only if it is empty
		/* Bug # 4955278 - start */
		IF ( l_unassoc_ue_op_rec.actual_end_date IS NULL ) THEN
		  IF ( p_signoff_mr_rec.default_actual_dates_flag = 'Y' ) THEN
		    -- Update with Scheduled End Date or SYSDATE
		    l_operation_tbl(l_ctr).actual_end_date := LEAST( SYSDATE , l_def_actual_end_date );
		  ELSE
		    -- Update with User Entered Value
		    l_operation_tbl(l_ctr).actual_end_date := p_signoff_mr_rec.actual_end_date;
		  END IF;
		ELSE

		  -- Update with DB Value
		  l_operation_tbl(l_ctr).actual_end_date := l_unassoc_ue_op_rec.actual_end_date;
		END IF;

		-- Update Actual Date only if it is empty
		IF ( l_unassoc_ue_op_rec.actual_start_date IS NULL ) THEN
		  IF ( p_signoff_mr_rec.default_actual_dates_flag = 'Y' ) THEN

		    -- Update with Scheduled Date
		    IF ( l_def_actual_start_date < SYSDATE ) THEN
		       l_operation_tbl(l_ctr).actual_start_date := l_def_actual_start_date;
		    ELSE
		       l_operation_tbl(l_ctr).actual_start_date := l_operation_tbl(l_ctr).actual_end_date - (l_def_actual_end_date - l_def_actual_start_date);
		    END IF;
		  ELSE

		    -- Update with User Entered Value
		    l_operation_tbl(l_ctr).actual_start_date := p_signoff_mr_rec.actual_start_date;
		  END IF;
		ELSE

		  -- Update with DB Value
		  l_operation_tbl(l_ctr).actual_start_date := l_unassoc_ue_op_rec.actual_start_date;
		END IF;
		/* Bug # 4955278 - end */

		IF ( G_DEBUG = 'Y' ) THEN
		  AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
		  || ' : Wo Name - ' || l_operation_tbl(l_ctr).workorder_name
		  || ' OP Seq - ' || l_unassoc_ue_op_rec.operation_seq_num || ' WO OP ID - '
		  || l_operation_tbl(l_ctr).workorder_operation_id || ' Actual Start Date - '
		  || l_operation_tbl(l_ctr).actual_start_date || ' Actual End Date - '
		  || l_operation_tbl(l_ctr).actual_end_date );
		END IF;

	      END IF;
	    ELSE

	      -- Since Operations are not required to be completed
	      -- Validate to ensure that the Workorder Ops are already completed
	      IF ( l_unassoc_ue_op_rec.status_code <> G_OP_STATUS_COMPLETE ) THEN
		FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_MR_WO_OP_NOT_CMPL' );
		FND_MESSAGE.set_token( 'MAINT_REQ', l_mr_rec.ue_title);
		FND_MESSAGE.set_token( 'WO_NAME', l_unassoc_ue_op_rec.workorder_name );
		FND_MESSAGE.set_token( 'OP_SEQ', l_unassoc_ue_op_rec.operation_seq_num );
		FND_MSG_PUB.add;
		RAISE FND_API.G_EXC_ERROR;
	      END IF;
	    END IF; -- complete_job_ops_flag
     END LOOP;
   END IF; -- IF l_ctr = 0 THEN
 -- end of changes for bug 4087041

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
    || ' : Before Updating Operations. Total - ' || l_operation_tbl.COUNT );
  END IF;

  -- R12
  -- If the dates are being defaulted, then Operation updates will be performed in the Completions API
  -- otherwise perform the Operation Updates for Actual Dates

  --Balaji remvoed default_actual_dates_flag = 'N' condition for bug # 4955278
  IF ( p_signoff_mr_rec.complete_job_ops_flag = 'Y' )

   -- AND p_signoff_mr_rec.default_actual_dates_flag = 'N' )
  THEN

  IF ( l_operation_tbl.COUNT > 0 ) THEN
    FOR i IN l_operation_tbl.FIRST..l_operation_tbl.LAST LOOP
      UPDATE  AHL_WORKORDER_OPERATIONS
      SET     object_version_number = object_version_number + 1,
              actual_start_date = l_operation_tbl(i).actual_start_date,
              actual_end_date = l_operation_tbl(i).actual_end_date,
              LAST_UPDATE_DATE = SYSDATE,
              LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
              LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
      WHERE   workorder_operation_id = l_operation_tbl(i).workorder_operation_id
      AND     object_version_number = l_operation_tbl(i).object_version_number;

      IF ( SQL%ROWCOUNT = 0 ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --Balaji-debug
      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
        || ' : Actual start date - ' || to_char(l_operation_tbl(i).actual_start_date,'DD-MM-YYYY HH24:MI'));
        AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
        || ' : Actual end date - ' || to_char(l_operation_tbl(i).actual_end_date,'DD-MM-YYYY HH24:MI'));
      END IF;

      l_operation_tbl(i).object_version_number := l_operation_tbl(i).object_version_number + 1;
    END LOOP;
  END IF;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
    || ' : Before Updating Workorders. Total - ' || l_workorder_tbl.COUNT );
  END IF;


  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Completing Operations' );
  END IF;

  -- Invoke Complete Operation API to Complete All Operations
  IF ( l_operation_tbl.COUNT > 0 ) THEN
    FOR i IN l_operation_tbl.FIRST..l_operation_tbl.LAST LOOP

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
        || ' : Before Completing Operation - ' || l_operation_tbl(i).workorder_operation_id );
      END IF;

      -- R12
      -- The actual dates are defaulted from the resource txn dates
      -- instead of the scheduled dates
      -- This is taken care of in the Completions API if the p_default param
      -- is passed as FND_API.G_TRUE
      l_default := FND_API.G_FALSE;
      IF (p_signoff_mr_rec.complete_job_ops_flag = 'Y' AND p_signoff_mr_rec.default_actual_dates_flag = 'Y') THEN
        l_default := FND_API.G_TRUE;
      END IF;

      complete_operation
      (
        p_api_version            => 1.0,
        p_init_msg_list          => FND_API.G_FALSE,
        p_commit                 => FND_API.G_FALSE,
        p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
        p_default                => l_default,
        p_module_type            => NULL,
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data,
        p_workorder_operation_id => l_operation_tbl(i).workorder_operation_id,
        p_object_version_no      => l_operation_tbl(i).object_version_number
      );

      IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END LOOP;
  END IF;

  -- perform the Job Updates for Actual Dates after updating operation actuals and completing operations

  IF ( l_workorder_tbl.COUNT > 0 ) THEN
    FOR i IN l_workorder_tbl.FIRST..l_workorder_tbl.LAST LOOP
     /*Start ER # 4757222*/
     -- Do not update Master Wos because they are post processed separately
     IF ( l_workorder_tbl(i).master_workorder_flag = 'N' AND
          p_signoff_mr_rec.complete_job_ops_flag  = 'Y') THEN
    -- Workorder actual dates need to be defaulted from the resource txn dates
    -- retrieve the workorder actual dates


    OPEN get_wo_dates(l_workorder_tbl(i).workorder_id);
    FETCH get_wo_dates INTO l_wo_actual_start_date, l_wo_actual_end_date, l_wo_name;
    IF get_wo_dates%NOTFOUND THEN
      CLOSE get_wo_dates;
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_DEF_ERROR' );
      -- Error defaulting the actual dates for workorder WO_NAME before completion.
      -- Do we raise an error for this or just ignore the error since this is defaulting code?
      -- Check during UTs
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF; -- IF get_wo_dates %NOTFOUND THEN
    CLOSE get_wo_dates;

    Get_default_wo_actual_dates(x_return_status => l_return_status,
                                p_workorder_id => l_workorder_tbl(i).workorder_id,
				x_actual_start_date => l_def_actual_start_date,
				x_actual_end_date => l_def_actual_end_date
				);
    IF l_return_status <> FND_API. G_RET_STS_SUCCESS THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_DEF_ERROR' );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- update the actual dates in the table
    IF l_wo_actual_start_date IS NULL THEN
      UPDATE AHL_WORKORDERS
      SET OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
      ACTUAL_START_DATE = l_def_actual_start_date,
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
      LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
      WHERE WORKORDER_ID = l_workorder_tbl(i).workorder_id
      AND OBJECT_VERSION_NUMBER = l_workorder_tbl(i).object_version_number;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
	FND_MESSAGE.set_token('WO_NAME', l_wo_name);
   	FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      l_workorder_tbl(i).object_version_number := l_workorder_tbl(i).object_version_number + 1;
    END IF;-- IF l_actual_start_date IS NULL THEN

    -- update the actual dates in the table
    IF l_wo_actual_end_date IS NULL THEN
      UPDATE AHL_WORKORDERS
      SET OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
      ACTUAL_END_DATE = l_def_actual_end_date,
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
      LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
      WHERE WORKORDER_ID = l_workorder_tbl(i).workorder_id
      AND OBJECT_VERSION_NUMBER = l_workorder_tbl(i).object_version_number;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
	FND_MESSAGE.set_token('WO_NAME', l_wo_name);
   	FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      l_workorder_tbl(i).object_version_number := l_workorder_tbl(i).object_version_number + 1;
    END IF; -- IF l_actual_end_date IS NULL THEN
    /*ELSE

        UPDATE  AHL_WORKORDERS
        SET     object_version_number = object_version_number + 1,
                actual_start_date = l_workorder_tbl(i).actual_start_date,
                actual_end_date = l_workorder_tbl(i).actual_end_date,
                LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
        WHERE   workorder_id = l_workorder_tbl(i).workorder_id
        AND     object_version_number = l_workorder_tbl(i).object_version_number;

        IF ( SQL%ROWCOUNT = 0 ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_workorder_tbl(i).object_version_number := l_workorder_tbl(i).object_version_number + 1;*/
    END IF; --IF (complete_job_ops_flag = 'Y' AND default_actual_dates_flag = 'Y') THEN
    --END IF; -- IF ( l_workorder_tbl(i).master_workorder_flag = 'N' ) THEN

    END LOOP;

    -- Check if Workorders need to be completed
    IF (p_signoff_mr_rec.complete_job_ops_flag = 'Y' AND p_signoff_mr_rec.default_actual_dates_flag = 'N') THEN

      l_actual_start_date := p_signoff_mr_rec.actual_start_date;
      l_actual_end_date := p_signoff_mr_rec.actual_end_date;
    END IF;
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Updating Master Workorders' );
    END IF;

    -- Update the Actual Dates for Master Workorders in the Visit
    l_return_status :=
    update_mwo_actual_dates
    (
      p_wip_entity_id     => l_mr_rec.visit_wip_entity_id,
      p_default_flag      => p_signoff_mr_rec.default_actual_dates_flag,
      p_actual_start_date => l_actual_start_date,
      p_actual_end_date   => l_actual_end_date
    );

    IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;


  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Completing WOs' );
  END IF;

  -- Complete All MR Workorders in the Order of Completion Dependencies
  IF ( l_workorder_tbl.COUNT > 0 ) THEN
    l_return_status :=
    complete_visit_mr_wos
    (
      p_wip_entity_id   => l_mr_rec.visit_wip_entity_id,
      p_x_workorder_tbl => l_workorder_tbl
    );

    IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Completing UEs' );
  END IF;

  -- Invoke Complete MR Instance API to Complete All UEs
  IF ( l_child_mr_tbl.COUNT > 0 ) THEN
    FOR i IN l_child_mr_tbl.FIRST..l_child_mr_tbl.LAST LOOP

      -- Check Status again because UE could be completed automatically
      l_ue_status_code := get_mr_status( l_child_mr_tbl(i).unit_effectivity_id );
      IF ( l_ue_status_code <> G_MR_STATUS_SIGNED_OFF ) THEN

        IF ( l_ue_status_code <> G_MR_STATUS_JOBS_COMPLETE ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_INV_SIGNOFF_STATUS');
          FND_MESSAGE.set_token( 'MAINT_REQ', l_child_mr_tbl(i).mr_title);
  	  -- replacing with call to get_status function
	  -- so no exceptions are thrown if the
	  -- lookup does not exist
	  l_status_meaning := get_status(l_ue_status_code,
	                                 'AHL_PRD_MR_STATUS');


	/*SELECT meaning INTO l_status_meaning
	   FROM fnd_lookup_values_vl
        WHERE lookup_type = 'AHL_PRD_MR_STATUS'
          AND LOOKUP_CODE = l_ue_status_code;
        */
          FND_MESSAGE.set_token( 'STATUS', l_status_meaning );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
          || ' : Before Completing MR - ' || l_child_mr_tbl(i).unit_effectivity_id );
        END IF;

        complete_mr_instance
        (
          p_api_version            => 1.0,
          p_init_msg_list          => FND_API.G_FALSE,
          p_commit                 => FND_API.G_FALSE,
          p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
          p_default                => FND_API.G_FALSE,
          p_module_type            => NULL,
          x_return_status          => l_return_status,
          x_msg_count              => l_msg_count,
          x_msg_data               => l_msg_data,
          p_x_mr_rec               => l_child_mr_tbl(i)
        );

        IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

    END LOOP;
  END IF;


--JKJain, Bug 9250614, Define label
<<counter_qa_results_label>>

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Recording Counter Readings, COUNT = '||l_workorder_tbl.COUNT|| ' and Plan_ID = '|| G_CTR_READING_PLAN_ID  );
  END IF;

  -- Record Counter Readings for all WOs
  IF ( l_workorder_tbl.COUNT > 0 AND
       G_CTR_READING_PLAN_ID IS NOT NULL AND
       l_mr_rec.item_instance_id IS NOT NULL ) THEN

    --IF ( l_counter_tbl.COUNT > 0 ) THEN

      -- Record Counter Readings for all the Workorders.
      FOR i IN l_workorder_tbl.FIRST..l_workorder_tbl.LAST LOOP

        -- Get the Current Counter Readings for the Item Instance.
        -- Bug # 6750836 -- Start
        l_return_status :=
        get_cp_counters
        (
          p_item_instance_id  => l_mr_rec.item_instance_id,
          p_wip_entity_id     => l_workorder_tbl(i).wip_entity_id,
          p_actual_date       => l_workorder_tbl(i).actual_end_date,
          x_counter_tbl       => l_counter_tbl
        );

        IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Bug # 6750836 -- end

        IF ( l_counter_tbl.COUNT > 0 ) THEN

		l_return_status :=
		record_wo_ctr_readings
		(
		  x_msg_data           => l_msg_data,
		  x_msg_count          => l_msg_count,
		  p_wip_entity_id      => l_workorder_tbl(i).wip_entity_id,
		  p_counter_tbl        => l_counter_tbl
		);

		IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
		  RAISE FND_API.G_EXC_ERROR;
		ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		-- Re-set the API savepoint because, Quality Results submission commits
		SAVEPOINT signoff_mr_instance_PVT;

        END IF;

      END LOOP;
    --END IF;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
    || ' : Before Firing QA Actions for UE, WO and OP, Count = '||l_child_mr_tbl.COUNT );
  END IF;

  -- Fire QA Actions for all UEs
  IF ( l_child_mr_tbl.COUNT > 0 ) THEN
    FOR i IN l_child_mr_tbl.FIRST..l_child_mr_tbl.LAST LOOP

      IF ( l_child_mr_tbl(i).qa_collection_id IS NOT NULL ) THEN

        QA_SS_RESULTS.wrapper_fire_action
        (
          q_collection_id    => l_child_mr_tbl(i).qa_collection_id,
          q_return_status    => l_return_status,
          q_msg_count        => l_msg_count,
          q_msg_data         => l_msg_data
        );

        IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
          x_msg_data := l_msg_data;
          x_msg_count := l_msg_count;
          RETURN;
        ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Re-set the API savepoint because, the wrapper_fire_action commits.
        SAVEPOINT signoff_mr_instance_PVT;

      END IF;
    END LOOP;
  END IF;

  -- Fire QA Actions for all Operations
  IF ( l_operation_tbl.COUNT > 0 ) THEN
    FOR i IN l_operation_tbl.FIRST..l_operation_tbl.LAST LOOP
      IF ( l_operation_tbl(i).collection_id IS NOT NULL ) THEN

        QA_SS_RESULTS.wrapper_fire_action
        (
          q_collection_id    => l_operation_tbl(i).collection_id,
          q_return_status    => l_return_status,
          q_msg_count        => l_msg_count,
          q_msg_data         => l_msg_data
        );

        IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
          x_msg_data := l_msg_data;
          x_msg_count := l_msg_count;
          RETURN;
        ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Re-set the API savepoint because, the wrapper_fire_action commits.
        SAVEPOINT signoff_mr_instance_PVT;

      END IF;
    END LOOP;
  END IF;

  -- Fire QA Actions for all Workorders
  IF ( l_workorder_tbl.COUNT > 0 ) THEN
    FOR i IN l_workorder_tbl.FIRST..l_workorder_tbl.LAST LOOP
      IF ( l_workorder_tbl(i).collection_id IS NOT NULL ) THEN

        QA_SS_RESULTS.wrapper_fire_action
        (
          q_collection_id    => l_workorder_tbl(i).collection_id,
          q_return_status    => l_return_status,
          q_msg_count        => l_msg_count,
          q_msg_data         => l_msg_data
        );

        IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
          x_msg_data := l_msg_data;
          x_msg_count := l_msg_count;
          RETURN;
        ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Re-set the API savepoint because, the wrapper_fire_action commits.
        SAVEPOINT signoff_mr_instance_PVT;

      END IF;
    END LOOP;
  END IF;

  -- Perform the Commit (if requested)
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Disable debug (if enabled)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO signoff_mr_instance_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO signoff_mr_instance_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN OTHERS THEN
    ROLLBACK TO signoff_mr_instance_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.add_exc_msg
      (
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240)
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;
END signoff_mr_instance;

PROCEDURE close_visit
(
  p_api_version      IN         NUMBER        := 1.0,
  p_init_msg_list    IN         VARCHAR2      := FND_API.G_TRUE,
  p_commit           IN         VARCHAR2      := FND_API.G_FALSE,
  p_validation_level IN         NUMBER        := FND_API.G_VALID_LEVEL_FULL,
  p_default          IN         VARCHAR2      := FND_API.G_FALSE,
  p_module_type      IN         VARCHAR2      := NULL,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  p_close_visit_rec  IN         close_visit_rec_type
)
IS

l_api_name               VARCHAR2(30) := 'close_visit';
l_return_status          VARCHAR2(1);
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(2000);
l_wo_actual_start_date   DATE;
l_wo_actual_end_date     DATE;
l_def_actual_start_date  DATE;
l_def_actual_end_date    DATE;
l_wo_name                VARCHAR2(80);
-- rroy
-- R12 Tech UIs
-- cursor to retrieve the workorder actual dates
CURSOR get_wo_dates(x_wo_id NUMBER)
IS
SELECT Actual_start_date,
Actual_end_date,
Workorder_name
FROM AHL_WORKORDERS
WHERE workorder_id = x_wo_id;

-- To get the Visit and it's master workorder details
CURSOR     get_visit_details( c_visit_id NUMBER ) IS
SELECT     VST.visit_id visit_id,
           VST.visit_number visit_number,
           VST.object_version_number object_version_number,
           VST.status_code status_code,
           WO.workorder_id workorder_id,
           WO.object_version_number wo_object_version_number,
           WO.workorder_name workorder_name,
           WIP.organization_id,
           WO.wip_entity_id wip_entity_id,
           VST.item_instance_id item_instance_id,
           WIP.scheduled_start_date scheduled_start_date,
           WIP.scheduled_completion_date scheduled_end_date,
           WO.actual_start_date actual_start_date,
           WO.actual_end_date actual_end_date,
           WO.status_code wo_status_code,
           WO.plan_id wo_plan_id,
           WO.collection_id wo_collection_id
FROM       WIP_DISCRETE_JOBS WIP,
           AHL_WORKORDERS WO,
           AHL_VISITS_B VST
WHERE      WIP.wip_entity_id = WO.wip_entity_id
AND        WO.visit_task_id IS NULL
AND        WO.master_workorder_flag = 'Y'
AND        WO.visit_id = VST.visit_id
AND        VST.visit_id = c_visit_id;

-- To get the Top Unit Effectivity Details for the Visit
-- altering this so that unassociated tasks that are created
-- as a result of sr creation which have an originating task id
-- are also picked up for signing off
/*
CURSOR     get_visit_ue_details( c_visit_id NUMBER ) IS
SELECT     UE.unit_effectivity_id unit_effectivity_id,
           UE.title title,
           UE.object_version_number object_version_number,
           UE.ump_status_code ump_status_code,
           UE.qa_inspection_type_code qa_inspection_type_code,
           UE.qa_plan_id qa_plan_id,
           UE.qa_collection_id qa_collection_id
FROM       AHL_UE_DEFERRAL_DETAILS_V UE,
           AHL_VISIT_TASKS_B VT
WHERE      UE.unit_effectivity_id = VT.unit_effectivity_id
AND        ((VT.originating_task_id IS NULL
AND        VT.task_type_code = 'SUMMARY')
OR (TASK_TYPE_CODE = 'UNASSOCIATED' ))
AND        VT.visit_id = c_visit_id;
*/
-- Bug # 6815689 start
/*CURSOR     get_visit_ue_details( c_visit_id NUMBER ) IS
SELECT     UE.unit_effectivity_id unit_effectivity_id,
           UE.title title,
           UE.object_version_number object_version_number,
           UE.ump_status_code ump_status_code,
           UE.qa_inspection_type_code qa_inspection_type_code,
           UE.qa_plan_id qa_plan_id,
           UE.qa_collection_id qa_collection_id
FROM       AHL_UE_DEFERRAL_DETAILS_V UE,
           AHL_VISIT_TASKS_B VT,
	   ahl_workorders awo
WHERE      UE.unit_effectivity_id = VT.unit_effectivity_id
AND       ( (VT.task_type_code = 'SUMMARY')
OR (TASK_TYPE_CODE = 'UNASSOCIATED' ) )
AND vt.visit_task_id = awo.visit_task_id
and awo.wip_entity_id in (  SELECT
			  wsch.child_object_id
			FROM
			  wip_sched_relationships wsch,
			  ahl_workorders awo1
			WHERE
			  wsch.parent_object_id = awo1.wip_entity_id
			  and awo1.visit_task_id is null
			  and awo1.master_workorder_flag = 'Y'
			  and awo1.visit_id = c_visit_id
			 );*/
-- Bug # 6815689 end
--fix for bug number 7295717 (Sunil)
CURSOR     get_visit_ue_details( c_visit_id NUMBER ) IS
SELECT     UE.unit_effectivity_id unit_effectivity_id,
           DECODE( UE.Mr_header_id, null,
           (select cit.name || '-' || cs.incident_number from cs_incidents_all_vl cs, cs_incident_types_vl cit WHERE cs.incident_type_id = cit.incident_type_id AND cs.incident_id = UE.Cs_Incident_id),
           (select title from AHL_MR_HEADERS_B MR where MR.mr_header_id = UE.mr_header_id )) title,
           UE.object_version_number object_version_number,
           UE.status_code ump_status_code,
           DECODE( UE.Mr_header_id, null,null,(select QA_INSPECTION_TYPE from AHL_MR_HEADERS_B MR where MR.mr_header_id = UE.mr_header_id ))  qa_inspection_type_code,
           -1 qa_plan_id,
           UE.qa_collection_id qa_collection_id
           FROM AHL_UNIT_EFFECTIVITIES_B UE,
           AHL_VISIT_TASKS_B VT,
	   ahl_workorders awo
WHERE      UE.unit_effectivity_id = VT.unit_effectivity_id
AND       ( (VT.task_type_code = 'SUMMARY')
OR (TASK_TYPE_CODE = 'UNASSOCIATED' ) )
AND vt.visit_task_id = awo.visit_task_id
and awo.wip_entity_id in (  SELECT
			  wsch.child_object_id
			FROM
			  wip_sched_relationships wsch,
			  ahl_workorders awo1
			WHERE
			  wsch.parent_object_id = awo1.wip_entity_id
			  and awo1.visit_task_id is null
			  and awo1.master_workorder_flag = 'Y'
			  and awo1.visit_id = c_visit_id
			 );

CURSOR get_qa_plan_id_csr1(p_collection_id IN NUMBER)IS
SELECT qa.plan_id from qa_results qa
where qa.collection_id = p_collection_id and rownum < 2;

CURSOR get_qa_plan_id_csr2(p_org_id IN NUMBER, p_qa_inspection_type IN VARCHAR2)IS
SELECT QP.plan_id FROM QA_PLANS_VAL_V QP, QA_PLAN_TRANSACTIONS QPT, QA_PLAN_COLLECTION_TRIGGERS QPCT
WHERE QP.plan_id = QPT.plan_id AND QPT.plan_transaction_id = QPCT.plan_transaction_id
AND QP.organization_id = p_org_id
AND QPT.transaction_number in (9999,2001)
AND QPCT.collection_trigger_id = 87
AND QPCT.low_value = p_qa_inspection_type
group by qp.plan_id, qpt.transaction_number having transaction_number = MAX(transaction_number);


-- To get the Child Unit Effectivity Details
/*CURSOR     get_child_ue_details( c_unit_effectivity_id NUMBER ) IS
SELECT     unit_effectivity_id,
           object_version_number,
           title,
           ump_status_code,
           qa_inspection_type_code,
           qa_plan_id,
           qa_collection_id
FROM       AHL_UE_DEFERRAL_DETAILS_V
WHERE      unit_effectivity_id IN
           (
             SELECT     related_ue_id
             FROM       AHL_UE_RELATIONSHIPS
             WHERE      unit_effectivity_id = related_ue_id
             START WITH ue_id = c_unit_effectivity_id
                    AND relationship_code = 'PARENT'
             CONNECT BY ue_id = PRIOR related_ue_id
                    AND relationship_code = 'PARENT'
           );*/
--fix for bug number 7295717 (Sunil)
CURSOR     get_child_ue_details( c_unit_effectivity_id NUMBER ) IS
SELECT     unit_effectivity_id,
           object_version_number,
           DECODE( UE.Mr_header_id, null,
           (select cit.name || '-' || cs.incident_number from cs_incidents_all_vl cs, cs_incident_types_vl cit WHERE cs.incident_type_id = cit.incident_type_id AND cs.incident_id = UE.Cs_Incident_id),
           (select title from AHL_MR_HEADERS_B MR where MR.mr_header_id = UE.mr_header_id )) title,
           status_code ump_status_code,
           DECODE( UE.Mr_header_id, null,null,(select QA_INSPECTION_TYPE from AHL_MR_HEADERS_B MR where MR.mr_header_id = UE.mr_header_id ))  qa_inspection_type_code,
           -1 qa_plan_id,
           qa_collection_id
FROM       AHL_UNIT_EFFECTIVITIES_B UE,(SELECT     related_ue_id
FROM       AHL_UE_RELATIONSHIPS
  START WITH ue_id = c_unit_effectivity_id
  AND relationship_code = 'PARENT'
  CONNECT BY ue_id = PRIOR related_ue_id
  AND relationship_code = 'PARENT') CH
WHERE      UE.unit_effectivity_id = CH.related_ue_id ORDER BY unit_effectivity_id ASC;

-- Balaji commented out the order by clause for the issue # 3 in bug #4613940(CMRO)
-- and this fix has reference to bug #3085871(ST) where it is described that order by level
-- should not be used without a reference to "start with.. connect by clause" starting 10g
--ORDER BY   level DESC;

-- To get the Child Workorder Details for a Visit
CURSOR     get_visit_workorders( c_visit_id NUMBER ) IS
SELECT     WO.workorder_id workorder_id,
           WO.object_version_number object_version_number,
           WO.workorder_name workorder_name,
           WO.wip_entity_id wip_entity_id,
           WIP.scheduled_start_date scheduled_start_date,
           WIP.scheduled_completion_date scheduled_end_date,
           WO.actual_start_date actual_start_date,
           WO.actual_end_date actual_end_date,
           WO.status_code status_code,
           WO.master_workorder_flag master_workorder_flag,
           WO.plan_id plan_id,
           WO.collection_id collection_id
FROM       WIP_DISCRETE_JOBS WIP,
           AHL_WORKORDERS WO
WHERE      WIP.wip_entity_id = WO.wip_entity_id
AND        WO.status_code <> G_JOB_STATUS_DELETED
AND        WO.visit_task_id IS NOT NULL
AND        WO.visit_id = c_visit_id
ORDER BY   WO.master_workorder_flag;

-- To get all the Child Operation Details for a Visit
CURSOR     get_visit_operations( c_visit_id NUMBER ) IS
SELECT     WOP.workorder_operation_id workorder_operation_id,
           WOP.object_version_number object_version_number,
           WO.workorder_name workorder_name,
           WIP.wip_entity_id wip_entity_id,
           WIP.operation_seq_num operation_seq_num,
           WIP.first_unit_start_date scheduled_start_date,
           WIP.last_unit_completion_date scheduled_end_date,
           WOP.actual_start_date actual_start_date,
           WOP.actual_end_date actual_end_date,
           WOP.status_code status_code,
           WOP.plan_id plan_id,
           WOP.collection_id collection_id
FROM       AHL_WORKORDER_OPERATIONS WOP,
           WIP_OPERATIONS WIP,
           AHL_WORKORDERS WO
WHERE      WOP.operation_sequence_num = WIP.operation_seq_num
AND        WOP.workorder_id = WO.workorder_id
AND        WIP.wip_entity_id = WO.wip_entity_id
AND        WO.status_code NOT IN
           (
             G_JOB_STATUS_COMPLETE_NC,
             G_JOB_STATUS_COMPLETE,
             G_JOB_STATUS_CLOSED,
             G_JOB_STATUS_CANCELLED,
             G_JOB_STATUS_DELETED
           )
AND        WO.visit_task_id IS NOT NULL
AND        WO.visit_id = c_visit_id;

-- To get all the Resource Requirements for a Visit
CURSOR     get_visit_resource_req( c_visit_id NUMBER ) IS
SELECT     WOR.wip_entity_id wip_entity_id,
           WO.workorder_name,
           WO.workorder_id,
           WOP.workorder_operation_id,
           WOR.operation_seq_num operation_seq_num,
           WOR.resource_seq_num resource_seq_num,
           WOR.organization_id organization_id,
           WOR.department_id department_id,
           BOM.resource_code resource_name,
           WOR.resource_id resource_id,
           BOM.resource_type,
           WOR.uom_code uom_code,
           WOR.usage_rate_or_amount usage_rate_or_amount
FROM       BOM_RESOURCES BOM,
           WIP_OPERATION_RESOURCES WOR,
           AHL_WORKORDER_OPERATIONS WOP,
           AHL_WORKORDERS WO
WHERE      BOM.resource_type IN ( 1 , 2 )
AND        BOM.resource_id = WOR.resource_id
AND        WOR.operation_seq_num = WOP.operation_sequence_num
AND        WOR.wip_entity_id = WO.wip_entity_id
AND        WOP.status_code <> G_OP_STATUS_COMPLETE
AND        WOP.workorder_id = WO.workorder_id
AND        WO.status_code NOT IN
           (
             G_JOB_STATUS_COMPLETE_NC,
             G_JOB_STATUS_COMPLETE,
             G_JOB_STATUS_CLOSED,
             G_JOB_STATUS_CANCELLED,
             G_JOB_STATUS_DELETED
           )
AND        WO.visit_task_id IS NOT NULL
AND        WO.visit_id = c_visit_id;

-- To get the Resource Transactions performed for a Resource Requirement
CURSOR     get_resource_txns( c_wip_entity_id NUMBER,
                              c_operation_seq_num NUMBER,
                              c_resource_seq_num NUMBER ) IS
SELECT     NVL( SUM( transaction_quantity ), 0 )
FROM       WIP_TRANSACTIONS
WHERE      wip_entity_id = c_wip_entity_id
AND        operation_seq_num = c_operation_seq_num
AND        resource_seq_num = c_resource_seq_num;

-- To get the Pending Resource Transactions for a Resource Requirement
-- Confirm
CURSOR     get_pending_resource_txns( c_wip_entity_id NUMBER,
                                      c_operation_seq_num NUMBER,
                                      c_resource_seq_num NUMBER ) IS
SELECT     NVL( SUM( transaction_quantity ), 0 )
FROM       WIP_COST_TXN_INTERFACE
WHERE      wip_entity_id = c_wip_entity_id
AND        operation_seq_num = c_operation_seq_num
AND        resource_seq_num = c_resource_seq_num
AND        process_status = 1;

l_ctr                    NUMBER := 0;
l_actual_start_date      DATE;
l_actual_end_date        DATE;
l_transaction_qty        NUMBER := 0;
l_txn_qty                NUMBER := 0;
l_pending_txn_qty        NUMBER := 0;
l_cost_session_id        NUMBER;
l_mr_session_id          NUMBER;
l_employee_id            NUMBER;
l_ue_status_code         VARCHAR2(30);
l_visit_rec              get_visit_details%ROWTYPE;
l_child_mr_tbl           mr_tbl_type;
l_workorder_tbl          workorder_tbl_type;
l_operation_tbl          operation_tbl_type;
l_resource_req_tbl       resource_req_tbl_type;
l_counter_tbl            counter_tbl_type;
--l_res_txn_tbl            AHL_WIP_JOB_PVT.ahl_res_txn_tbl_type;
l_status_meaning         VARCHAR2(80);
--JKJain, Bug 9250614
l_signoff_mr_rec         signoff_mr_rec_type;

TYPE child_ue_tbl_type IS TABLE OF get_child_ue_details%ROWTYPE INDEX BY BINARY_INTEGER;

l_child_ue_tbl child_ue_tbl_type;
l_ue_ctr NUMBER := 0;

l_op_actual_start_date DATE;
l_op_actaul_end_date DATE;

-- parameters to call process_resource_txns.
l_prd_resrc_txn_tbl     AHL_PRD_RESOURCE_TRANX_PVT.PRD_RESOURCE_TXNS_TBL;

BEGIN

  -- Enable Debug (optional)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT close_visit_PVT;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Validating Inputs' );
  END IF;

  -- Validate all the inputs of the API
  l_return_status :=
  validate_cv_inputs
  (
    p_close_visit_rec      => p_close_visit_rec
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
    || ' : Inputs - p_close_visit_rec.visit_id - ' || p_close_visit_rec.visit_id );
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
    || ' : Inputs - p_close_visit_rec.object_version_number - ' || p_close_visit_rec.object_version_number );
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
    || ' : Inputs - p_close_visit_rec.signoff_mrs_flag - ' || p_close_visit_rec.signoff_mrs_flag );
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
    || ' : Inputs - p_close_visit_rec.complete_job_ops_flag - ' || p_close_visit_rec.complete_job_ops_flag );
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
    || ' : Inputs - p_close_visit_rec.default_actual_dates_flag - '
    || p_close_visit_rec.default_actual_dates_flag );
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
    || ' : Inputs - p_close_visit_rec.actual_start_date - ' || p_close_visit_rec.actual_start_date );
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
    || ' : Inputs - p_close_visit_rec.actual_end_date - ' || p_close_visit_rec.actual_end_date );
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
    || ' : Inputs - p_close_visit_rec.transact_resource_flag - '
    || p_close_visit_rec.transact_resource_flag );
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
    || ' : Inputs - p_close_visit_rec.employee_number - ' || p_close_visit_rec.employee_number );
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
    || ' : Inputs - p_close_visit_rec.serial_number - ' || p_close_visit_rec.serial_number );
  END IF;

  -- Invoke VWP Close Visit API if this is not a top-down signoff
  IF ( p_close_visit_rec.signoff_mrs_flag = 'N' AND
       p_close_visit_rec.complete_job_ops_flag = 'N' AND
       p_close_visit_rec.transact_resource_flag = 'N' ) THEN

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Not Top Down Signoff ' );
    END IF;

    AHL_VWP_VISITS_PVT.close_visit
    (
      p_api_version            => 1.0,
      p_init_msg_list          => FND_API.G_FALSE,
      p_commit                 => FND_API.G_TRUE,
      p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
      p_module_type            => NULL,
      p_visit_id               => p_close_visit_rec.visit_id,
      p_x_cost_session_id      => l_cost_session_id,
      p_x_mr_session_id        => l_mr_session_id,
      x_return_status          => l_return_status,
      x_msg_count              => l_msg_count,
      x_msg_data               => l_msg_data
    );

   IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' After Calling AHL_VWP_VISITS_PVT.close_visit, Status =  '||l_return_status );
    END IF;

    IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

--JKJain, Bug 9250614
--    RETURN;

-- Get the Visit Details
  OPEN  get_visit_details( p_close_visit_rec.visit_id );
  FETCH get_visit_details
  INTO  l_visit_rec;

  IF ( get_visit_details%NOTFOUND ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_VST_REC_NOT_FOUND' );
    FND_MSG_PUB.add;
    CLOSE get_visit_details;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE get_visit_details;

-- Add the Visit WO to the Workorder Table of Records for QCP
      l_ctr := l_ctr + 1;
      l_workorder_tbl(l_ctr).workorder_id := l_visit_rec.workorder_id;
      l_workorder_tbl(l_ctr).wip_entity_id := l_visit_rec.wip_entity_id;
      l_workorder_tbl(l_ctr).actual_end_date := l_visit_rec.actual_end_date;

    IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' Before GOTO  vmwo_counter_qa_results_label' );
    END IF;

-- GOTO <Label name>
   GOTO vmwo_counter_qa_results_label;

  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Processing Visit' );
  END IF;

  -- Get the Visit Details
  OPEN  get_visit_details( p_close_visit_rec.visit_id );
  FETCH get_visit_details
  INTO  l_visit_rec;

  IF ( get_visit_details%NOTFOUND ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_VST_REC_NOT_FOUND' );
    FND_MSG_PUB.add;
    CLOSE get_visit_details;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE get_visit_details;

  -- Validate Object Version Number
  IF ( l_visit_rec.object_version_number <> p_close_visit_rec.object_version_number ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Validate the status of the Visit for Top-down Closure
  IF ( l_visit_rec.status_code <> G_VISIT_STATUS_RELEASED ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_INV_CLOSE_STATUS');
    FND_MESSAGE.set_token( 'VISIT_NUM', l_visit_rec.visit_number );
    FND_MESSAGE.set_token( 'STATUS', l_visit_rec.status_code );
    FND_MSG_PUB.add;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Processing MRs in the Visit' );
  END IF;

  -- Get all the Top UE Details for the Visit
  FOR mr_csr IN get_visit_ue_details( p_close_visit_rec.visit_id ) LOOP

    -- Initialize child UE counter to 0.
    l_ue_ctr := 0;

    -- Check if MRs in the Visit need to be Signed off
    IF ( p_close_visit_rec.signoff_mrs_flag = 'Y' ) THEN
      -- fix for bug number 7295717 (Sunil)
      IF(mr_csr.qa_inspection_type_code IS NULL)THEN
         mr_csr.qa_plan_id := NULL;
      ELSIF(mr_csr.qa_collection_id IS NOT NULL)THEN
         OPEN get_qa_plan_id_csr1(mr_csr.qa_collection_id);
         FETCH get_qa_plan_id_csr1 INTO mr_csr.qa_plan_id;
         CLOSE get_qa_plan_id_csr1;
      ELSE
         OPEN get_qa_plan_id_csr2(l_visit_rec.organization_id,mr_csr.qa_inspection_type_code);
         FETCH get_qa_plan_id_csr2 INTO mr_csr.qa_plan_id;
         CLOSE get_qa_plan_id_csr2;
      END IF;

      -- Check if the Top UE is complete
      l_return_status:=
      is_mr_complete
      (
        p_mr_title             => mr_csr.title,
        p_status_code          => mr_csr.ump_status_code,
        p_status               => NULL,
        p_qa_inspection_type   => mr_csr.qa_inspection_type_code,
        p_qa_plan_id           => mr_csr.qa_plan_id,
        p_qa_collection_id     => mr_csr.qa_collection_id
      );

      IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Balaji added the following loop for the BAE bug.
      -- The cursor get_child_ue_details doesnt UEs at the leaf node first
      -- their parent next, etc., instead it returns Mrs in Top down fashion.
      -- Hence below loop fetches all the child UEs in top down fashion and in
      -- subsequent code the top down will be converted into bottom up to
      -- circumvent the "At least one child Maintenance Requirement is unaccomplished"
      /*FOR child_ue_rec IN get_child_ue_details( mr_csr.unit_effectivity_id ) LOOP
         l_ue_ctr := l_ue_ctr + 1;
         l_child_ue_tbl(l_ue_ctr) := child_ue_rec;
      END LOOP;*/
      -- fix for bug number 7295717 (Sunil)
      FOR child_ue_rec IN get_child_ue_details( mr_csr.unit_effectivity_id ) LOOP
        l_ue_ctr := l_ue_ctr + 1;
        l_child_ue_tbl(l_ue_ctr) := child_ue_rec;
        IF(l_child_ue_tbl(l_ue_ctr).qa_inspection_type_code IS NULL)THEN
         l_child_ue_tbl(l_ue_ctr).qa_plan_id := NULL;
        ELSIF(l_child_ue_tbl(l_ue_ctr).qa_collection_id IS NOT NULL)THEN
         OPEN get_qa_plan_id_csr1(l_child_ue_tbl(l_ue_ctr).qa_collection_id);
         FETCH get_qa_plan_id_csr1 INTO l_child_ue_tbl(l_ue_ctr).qa_plan_id;
         CLOSE get_qa_plan_id_csr1;
        ELSE
         OPEN get_qa_plan_id_csr2(l_visit_rec.organization_id,l_child_ue_tbl(l_ue_ctr).qa_inspection_type_code);
         FETCH get_qa_plan_id_csr2 INTO l_child_ue_tbl(l_ue_ctr).qa_plan_id;
         CLOSE get_qa_plan_id_csr2;
        END IF;
      END LOOP;

      -- Get the Child UE Details
      IF l_child_ue_tbl.COUNT > 0 THEN
      -- Get the Child UEs for a given UE
  	    -- Reverse the order of signing off the Ues. First child UE then its parent
  	    -- etc.,Balaji modified the code for BAE bug.
	    FOR l_ue_count IN REVERSE l_child_ue_tbl.FIRST..l_child_ue_tbl.LAST LOOP

		-- Check if the Child UE is complete
		/*l_return_status:=
		is_mr_complete
		(
		  p_mr_title             => l_child_ue_tbl(l_ue_count).title,
		  p_status_code          => l_child_ue_tbl(l_ue_count).ump_status_code,
		  p_status               => NULL,
		  p_qa_inspection_type   => l_child_ue_tbl(l_ue_count).qa_inspection_type_code,
		  p_qa_plan_id           => l_child_ue_tbl(l_ue_count).qa_plan_id,
		  p_qa_collection_id     => l_child_ue_tbl(l_ue_count).qa_collection_id
		);

		IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
		  RAISE FND_API.G_EXC_ERROR;
		ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;*/

		-- Store the Child UEs in a table of records for Signing off
		IF ( nvl(l_child_ue_tbl(l_ue_count).ump_status_code,'x') <> nvl(G_MR_STATUS_SIGNED_OFF,'y') ) THEN

          l_ue_status_code := get_mr_status( l_child_ue_tbl(l_ue_count).unit_effectivity_id );

		  IF (
		      l_ue_status_code <> G_MR_STATUS_DEFERRED AND
		      l_ue_status_code <> G_MR_STATUS_TERMINATED AND
		      l_ue_status_code <> G_MR_STATUS_CANCELLED AND
                      l_ue_status_code <> G_MR_STATUS_MR_TERMINATED

		   ) THEN
		   -- Check if the Child UE is complete
	      l_return_status:=
	      is_mr_complete
	      (
		    p_mr_title             => l_child_ue_tbl(l_ue_count).title,
		    p_status_code          => l_child_ue_tbl(l_ue_count).ump_status_code,
		    p_status               => NULL,
		    p_qa_inspection_type   => l_child_ue_tbl(l_ue_count).qa_inspection_type_code,
		    p_qa_plan_id           => l_child_ue_tbl(l_ue_count).qa_plan_id,
		    p_qa_collection_id     => l_child_ue_tbl(l_ue_count).qa_collection_id
	        );

           IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
		     RAISE FND_API.G_EXC_ERROR;
	       ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	       END IF;

			IF ( G_DEBUG = 'Y' ) THEN
			   AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : l_ue_status_code '||l_ue_status_code );
			END IF;
             IF ( G_DEBUG = 'Y' ) THEN
		      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
		       || ' : Child MR needs Signoff - ' || l_child_ue_tbl(l_ue_count).unit_effectivity_id );
		    END IF;
			l_ctr := l_ctr + 1;
		    l_child_mr_tbl(l_ctr).unit_effectivity_id := l_child_ue_tbl(l_ue_count).unit_effectivity_id;
		    l_child_mr_tbl(l_ctr).ue_object_version_no := l_child_ue_tbl(l_ue_count).object_version_number;
		    l_child_mr_tbl(l_ctr).mr_title := l_child_ue_tbl(l_ue_count).title;
		    l_child_mr_tbl(l_ctr).qa_collection_id := l_child_ue_tbl(l_ue_count).qa_collection_id;
		  END IF;
		 END IF;

       END LOOP;
      END IF;

      -- Store the Top UEs in a table of records for Signing off
      IF ( nvl(mr_csr.ump_status_code,'x') <> nvl(G_MR_STATUS_SIGNED_OFF,'y') ) THEN

        IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
          || ' : Top MR needs Signoff - ' || mr_csr.unit_effectivity_id );
        END IF;

        l_ctr := l_ctr + 1;
        l_child_mr_tbl(l_ctr).unit_effectivity_id := mr_csr.unit_effectivity_id;
        l_child_mr_tbl(l_ctr).ue_object_version_no := mr_csr.object_version_number;
        l_child_mr_tbl(l_ctr).mr_title := mr_csr.title;
        l_child_mr_tbl(l_ctr).qa_collection_id := mr_csr.qa_collection_id;
      END IF;

    ELSE
      -- Validate Status of Child UEs
      -- Null check added by balaji for bug # 4078536
      IF (
           mr_csr.ump_status_code IS NULL OR
           (
            mr_csr.ump_status_code <> G_MR_STATUS_SIGNED_OFF AND
            mr_csr.ump_status_code <> G_MR_STATUS_DEFERRED AND
            mr_csr.ump_status_code <> G_MR_STATUS_TERMINATED AND
            mr_csr.ump_status_code <> G_MR_STATUS_CANCELLED AND
            mr_csr.ump_status_code <> G_MR_STATUS_MR_TERMINATED
           )
         ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_VST_MRS_NOT_CMPL' );
        FND_MESSAGE.set_token( 'VISIT_NUM', l_visit_rec.visit_number );
        FND_MESSAGE.set_token( 'MAINT_REQ', mr_csr.title );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  END LOOP;

	l_ctr := 0;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Processing Visit WOs' );
  END IF;

  -- Get all the Workorders for the Visit
  FOR wo_csr IN get_visit_workorders( l_visit_rec.visit_id ) LOOP

    -- Check if Jobs and Operations need to be completed
    IF ( p_close_visit_rec.complete_job_ops_flag = 'Y' ) THEN

      -- Check if User entered Actual Dates need to be used
       /* start ER # 4757222
      IF ( p_close_visit_rec.default_actual_dates_flag = 'N' ) THEN

        -- Ensure that the actual start date entered is less than any WO
        IF ( wo_csr.actual_start_date IS NOT NULL AND
             wo_csr.actual_start_date < p_close_visit_rec.actual_start_date ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_ACT_ST_DATE_LESS' );
          FND_MESSAGE.set_token( 'WO_NAME', wo_csr.workorder_name );
          FND_MESSAGE.set_token( 'START_DT', TO_CHAR( wo_csr.actual_start_date , 'DD-MON-YYYY HH24:MI' ) );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Ensure that the actual end date entered is greater than any WO
        IF ( wo_csr.actual_end_date IS NOT NULL AND
             wo_csr.actual_end_date > p_close_visit_rec.actual_end_date ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_ACT_END_DATE_GT' );
          FND_MESSAGE.set_token( 'WO_NAME', wo_csr.workorder_name );
          FND_MESSAGE.set_token( 'END_DT', TO_CHAR( wo_csr.actual_end_date , 'DD-MON-YYYY HH24:MI' ) );
          FND_MESSAGE.set_token( 'END_DT', wo_csr.actual_end_date );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
      */--end ER # 4757222
      -- Do not process Workorders which are already Complete
      IF ( wo_csr.status_code <> G_JOB_STATUS_COMPLETE AND
           wo_csr.status_code <> G_JOB_STATUS_COMPLETE_NC AND
           wo_csr.status_code <> G_JOB_STATUS_CLOSED AND
           wo_csr.status_code <> G_JOB_STATUS_CANCELLED ) THEN
         --To show jon status meaning instead code modifed by srini
	 -- replacing with call to get_status function
         -- so no exceptions are thrown if the
	 -- lookup does not exist
	 l_status_meaning := get_status(wo_csr.status_code,
	                                'AHL_JOB_STATUS');

         /*SELECT meaning INTO l_status_meaning
		  FROM fnd_lookup_values_vl
		  WHERE lookup_type = 'AHL_JOB_STATUS'
		    AND lookup_code = wo_csr.status_code;
	*/
        --
        -- Validate whether the Workorders can be completed
        IF ( wo_csr.status_code = G_JOB_STATUS_UNRELEASED OR
             wo_csr.status_code = G_JOB_STATUS_ON_HOLD OR
             wo_csr.status_code = G_JOB_STATUS_PARTS_HOLD OR
             wo_csr.status_code = G_JOB_STATUS_DEFERRAL_PENDING ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_NOT_ALL_WOS_OPEN' );
          FND_MESSAGE.set_token( 'WO_NAME', wo_csr.workorder_name );
          FND_MESSAGE.set_token( 'STATUS', l_status_meaning );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Validate whether Quality Results are Submitted
        IF ( wo_csr.plan_id IS NOT NULL AND
             wo_csr.collection_id IS NULL ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_QA_PENDING' );
          FND_MESSAGE.set_token( 'WO_NAME', wo_csr.workorder_name );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
--JKJain, Bug 9250614, Master WO is being tackeled in check for Signoff MR.
	IF (wo_csr.master_workorder_flag = 'N') THEN
        -- Add the Workorder for Completion
        l_ctr := l_ctr + 1;
        l_workorder_tbl(l_ctr).workorder_id := wo_csr.workorder_id;
        l_workorder_tbl(l_ctr).object_version_number := wo_csr.object_version_number;
        l_workorder_tbl(l_ctr).workorder_name := wo_csr.workorder_name;
        l_workorder_tbl(l_ctr).wip_entity_id := wo_csr.wip_entity_id;
        l_workorder_tbl(l_ctr).master_workorder_flag := wo_csr.master_workorder_flag;
        l_workorder_tbl(l_ctr).collection_id := wo_csr.collection_id;

	IF wo_csr.master_workorder_flag = 'N' THEN
	   -- dont default if actual dates for a workorder are already provided.
	   l_workorder_tbl(l_ctr).actual_start_date := wo_csr.actual_start_date;
	   l_workorder_tbl(l_ctr).actual_end_date := wo_csr.actual_end_date;
	ELSE
          -- Do not Update Actual Date of Master WO
          l_workorder_tbl(l_ctr).actual_start_date := NULL;
          l_workorder_tbl(l_ctr).actual_end_date := NULL;
	END IF;

  END IF;
        -- Store the Actual Dates for Workorders
        -- No need to store actual dates for Master Workorders because it can be
        -- done only after updating the Actual dates of child Workorders
        /*Start ER # 4757222
         -- Balaji commented out the code as per the requirement in the BAE ER # 4757222.
         -- As per the new requirement, Work Order actual dates will be defaulted based
         -- on following logic.
         -- 1. Work Order actual start date is minimum of operation actual start dates.
         -- 2. Work Order actual end date is maximum of operation actual end dates.
        IF ( wo_csr.master_workorder_flag = 'N' ) THEN

          -- Check if Actual Date is already entered
          IF ( wo_csr.actual_start_date IS NULL ) THEN


            -- R12
	    -- actual dates should be defaulted from res txn dates
            /*IF ( p_close_visit_rec.default_actual_dates_flag = 'Y' ) THEN

              -- Update Actual Date with Scheduled Date
              l_workorder_tbl(l_ctr).actual_start_date := wo_csr.scheduled_start_date;
            ELSE

              -- Update Actual Date with User Entered Value
              l_workorder_tbl(l_ctr).actual_start_date := p_close_visit_rec.actual_start_date;
            END IF;
	    */
            /*IF ( p_close_visit_rec.default_actual_dates_flag = 'N' ) THEN
              -- Update Actual Date with User Entered Value
              l_workorder_tbl(l_ctr).actual_start_date := p_close_visit_rec.actual_start_date;
            END IF;
          ELSE

            -- Update Actual Date with DB Value if already entered
            l_workorder_tbl(l_ctr).actual_start_date := wo_csr.actual_start_date;
          END IF;

          -- Check if Actual Date is already entered
          IF ( wo_csr.actual_end_date IS NULL ) THEN

            -- R12
	    -- actual dates should be defaulted from res txn dates
            /*IF ( p_close_visit_rec.default_actual_dates_flag = 'Y' ) THEN

              -- Update Actual Date with Scheduled Date
              l_workorder_tbl(l_ctr).actual_end_date := LEAST( SYSDATE , wo_csr.scheduled_end_date );
            ELSE

              -- Update Actual Date with User Entered Value
              l_workorder_tbl(l_ctr).actual_end_date := p_close_visit_rec.actual_end_date;
            END IF;
	    */
            /*IF ( p_close_visit_rec.default_actual_dates_flag = 'N' ) THEN
              -- Update Actual Date with User Entered Value
              l_workorder_tbl(l_ctr).actual_end_date := p_close_visit_rec.actual_end_date;
            END IF;
          ELSE

            -- Update Actual Date with DB Value if already entered
            l_workorder_tbl(l_ctr).actual_end_date := wo_csr.actual_end_date;
          END IF;

        ELSIF ( wo_csr.master_workorder_flag = 'Y' ) THEN

          -- Do not Update Actual Date of Master WO
          l_workorder_tbl(l_ctr).actual_start_date := NULL;
          l_workorder_tbl(l_ctr).actual_end_date := NULL;

        END IF;
        */
	/*End ER # 4757222*/

        IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
          || ' : Wo Name - ' || l_workorder_tbl(l_ctr).workorder_name
          || ' WO ID - ' || l_workorder_tbl(l_ctr).workorder_id
          || ' Actual Start Date - ' || l_workorder_tbl(l_ctr).actual_start_date
          || ' Actual End Date - ' || l_workorder_tbl(l_ctr).actual_end_date );
        END IF;

      END IF;
    ELSE
      -- Validate to ensure that the Workorders are already completed
      -- This check shou
      -- This validation should not be done for master workorders
      -- since their status is determined internally. Balaji added this
      -- fix for the BAE bug # 4626717.
      IF ( wo_csr.status_code <> G_JOB_STATUS_COMPLETE AND
           wo_csr.status_code <> G_JOB_STATUS_COMPLETE_NC AND
           wo_csr.status_code <> G_JOB_STATUS_CLOSED AND
           wo_csr.status_code <> G_JOB_STATUS_CANCELLED AND
           wo_csr.master_workorder_flag = 'N') THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_VST_WO_NOT_CMPL' );
        FND_MESSAGE.set_token( 'VISIT_NUM', l_visit_rec.visit_number );
        FND_MESSAGE.set_token( 'WO_NAME', wo_csr.workorder_name );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  END LOOP;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Processing Visit WO' );
  END IF;

  -- Add the Visit Workorder for Updates
  -- Do not process Visit Workorder if it is already Complete
  IF ( l_visit_rec.wo_status_code <> G_JOB_STATUS_COMPLETE AND
       l_visit_rec.wo_status_code <> G_JOB_STATUS_COMPLETE_NC AND
       l_visit_rec.wo_status_code <> G_JOB_STATUS_CLOSED AND
       l_visit_rec.wo_status_code <> G_JOB_STATUS_CANCELLED ) THEN
-- JKJain, Bug 9250614
--    IF ( p_close_visit_rec.complete_job_ops_flag = 'Y' ) THEN

      -- Validate Whether Quality Results are submitted for WO
      IF ( l_visit_rec.wo_plan_id IS NOT NULL AND
           l_visit_rec.wo_collection_id IS NULL ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_QA_PENDING' );
        FND_MESSAGE.set_token( 'WO_NAME', l_visit_rec.workorder_name );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      /*start ER # 4757222
      IF ( p_close_visit_rec.default_actual_dates_flag = 'N' ) THEN

        -- Validate if the actual start dates entered is less than any WO

        IF ( l_visit_rec.actual_start_date IS NOT NULL AND
             l_visit_rec.actual_start_date < p_close_visit_rec.actual_start_date ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_ACT_ST_DATE_LESS' );
          FND_MESSAGE.set_token( 'WO_NAME', l_visit_rec.workorder_name );
          FND_MESSAGE.set_token( 'START_DT', TO_CHAR( l_visit_rec.actual_start_date , 'DD-MON-YYYY HH24:MI' ) );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Validate if the actual end dates entered is greater than any WO
        IF ( l_visit_rec.actual_end_date IS NOT NULL AND
             l_visit_rec.actual_end_date > p_close_visit_rec.actual_end_date ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_ACT_END_DATE_GT' );
          FND_MESSAGE.set_token( 'WO_NAME', l_visit_rec.workorder_name );
          FND_MESSAGE.set_token( 'END_DT', TO_CHAR( l_visit_rec.actual_end_date , 'DD-MON-YYYY HH24:MI' ) );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
      */--End ER # 4757222
      -- Add the Visit WO to the Workorder Table of Records
      l_ctr := l_ctr + 1;
      l_workorder_tbl(l_ctr).workorder_id := l_visit_rec.workorder_id;
      l_workorder_tbl(l_ctr).object_version_number := l_visit_rec.wo_object_version_number;
      l_workorder_tbl(l_ctr).workorder_name := l_visit_rec.workorder_name;
      l_workorder_tbl(l_ctr).wip_entity_id := l_visit_rec.wip_entity_id;
      l_workorder_tbl(l_ctr).master_workorder_flag := 'Y';
      l_workorder_tbl(l_ctr).collection_id := l_visit_rec.wo_collection_id;
      l_workorder_tbl(l_ctr).actual_start_date := NULL;
      l_workorder_tbl(l_ctr).actual_end_date := NULL;
-- JKJain, Bug 9250614
--    END IF;
  END IF;

  /* Bug # 4955278 - start */
  /*
   * Interchanged resource txn logic before processing operations.
   */
  l_ctr := 0;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Processing Resource Transactions' );
  END IF;

  -- Check if Resource Transactions are required
  IF ( p_close_visit_rec.transact_resource_flag = 'Y' ) THEN

    -- Get all the Resource Requirements for the Visit Operations
    FOR res_csr IN get_visit_resource_req( l_visit_rec.visit_id ) LOOP

      -- Check if Serial Number is entered for Machine Type Resource
      IF ( res_csr.resource_type = 1 AND
           ( p_close_visit_rec.serial_number IS NULL OR
             p_close_visit_rec.serial_number = FND_API.G_MISS_CHAR ) ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_MACH_RES_REQD' );
        FND_MESSAGE.set_token( 'WO_NAME', res_csr.workorder_name );
        FND_MESSAGE.set_token( 'OP_SEQ', res_csr.operation_seq_num );
        FND_MESSAGE.set_token( 'RES_SEQ', res_csr.resource_seq_num );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Check if Employee Number is entered for Machine Type Resource
      IF ( res_csr.resource_type = 2 AND
           ( p_close_visit_rec.employee_number IS NULL OR
             p_close_visit_rec.employee_number = FND_API.G_MISS_NUM ) ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_EMP_RES_REQD' );
        FND_MESSAGE.set_token( 'WO_NAME', res_csr.workorder_name );
        FND_MESSAGE.set_token( 'OP_SEQ', res_csr.operation_seq_num );
        FND_MESSAGE.set_token( 'RES_SEQ', res_csr.resource_seq_num );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Add the Resource Requirement Record for Transaction Processing
      l_ctr := l_ctr + 1;
      l_resource_req_tbl(l_ctr).wip_entity_id := res_csr.wip_entity_id;
      l_resource_req_tbl(l_ctr).workorder_name := res_csr.workorder_name;
      l_resource_req_tbl(l_ctr).workorder_id  := res_csr.workorder_id;
      l_resource_req_tbl(l_ctr).operation_seq_num := res_csr.operation_seq_num;
      l_resource_req_tbl(l_ctr).workorder_operation_id := res_csr.workorder_operation_id;
      l_resource_req_tbl(l_ctr).resource_seq_num := res_csr.resource_seq_num;
      l_resource_req_tbl(l_ctr).organization_id := res_csr.organization_id;
      l_resource_req_tbl(l_ctr).department_id := res_csr.department_id;
      l_resource_req_tbl(l_ctr).resource_name := res_csr.resource_name;
      l_resource_req_tbl(l_ctr).resource_id := res_csr.resource_id;
      l_resource_req_tbl(l_ctr).resource_type := res_csr.resource_type;
      l_resource_req_tbl(l_ctr).uom_code := res_csr.uom_code;
      l_resource_req_tbl(l_ctr).usage_rate_or_amount := res_csr.usage_rate_or_amount;

    END LOOP;

    l_ctr := 0;
  END IF;

  IF ( l_resource_req_tbl.COUNT > 0 ) THEN

   /*
    SELECT  person_id
    INTO    l_employee_id
    FROM    PER_ALL_PEOPLE_F
    WHERE   employee_number = p_close_visit_rec.employee_number
      AND   rownum = 1;


    IF ( SQL%NOTFOUND ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_EMPLOYEE_NOT_FOUND' );
      FND_MESSAGE.set_token( 'EMP_NUM', p_close_visit_rec.employee_number );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    */

    BEGIN
       -- Fix for bug# 4553747.
       SELECT employee_id
       INTO l_employee_id
       FROM  mtl_employees_current_view
       WHERE organization_id = l_visit_rec.organization_id
         AND employee_num =   p_close_visit_rec.employee_number
         AND rownum = 1;

    EXCEPTION
      WHEN no_data_found THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_EMPLOYEE_NOT_FOUND' );
        FND_MESSAGE.set_token( 'EMP_NUM', p_close_visit_rec.employee_number );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
    END;

    -- Iterate through all the Resource Requirements
    FOR i IN l_resource_req_tbl.FIRST..l_resource_req_tbl.LAST LOOP

      -- Get all the Resource Txns performed for a Resource Requirement
      OPEN  get_resource_txns( l_resource_req_tbl(i).wip_entity_id,
                               l_resource_req_tbl(i).operation_seq_num,
                               l_resource_req_tbl(i).resource_seq_num );
      FETCH get_resource_txns
      INTO  l_txn_qty;
      CLOSE get_resource_txns;
      /*
      IF ( l_transaction_qty > 0 ) THEN

        -- Subtract the consumed quantity from the required quantity
        l_resource_req_tbl(i).transaction_quantity := l_resource_req_tbl(i).usage_rate_or_amount - l_transaction_qty;
        l_transaction_qty := 0;
      END IF;
      */
      -- Get all the Pending Resource Txns performed for a Resource Requirement
      OPEN  get_pending_resource_txns( l_resource_req_tbl(i).wip_entity_id,
                                       l_resource_req_tbl(i).operation_seq_num,
                                       l_resource_req_tbl(i).resource_seq_num );
      FETCH get_pending_resource_txns
      INTO  l_pending_txn_qty;
      CLOSE get_pending_resource_txns;
      /*
      IF ( l_transaction_qty > 0 ) THEN
        IF ( l_resource_req_tbl(i).transaction_quantity <> 0 ) THEN

          -- Subtract the consumed quantity from the required quantity
          l_resource_req_tbl(i).transaction_quantity := l_resource_req_tbl(i).transaction_quantity - l_transaction_qty;
        ELSE

          -- Subtract the consumed quantity from the required quantity
          l_resource_req_tbl(i).transaction_quantity := l_resource_req_tbl(i).usage_rate_or_amount - l_transaction_qty;
        END IF;

        l_transaction_qty := 0;
      END IF;
      */
      -- Subtract the consumed quantity from the required quantity
      l_resource_req_tbl(i).transaction_quantity := l_resource_req_tbl(i).usage_rate_or_amount - l_txn_qty - l_pending_txn_qty;

      -- If the required qty is greater than zero then txn needs to be performed
      IF ( l_resource_req_tbl(i).transaction_quantity > 0 ) THEN

        -- Add a Resource Transaction Record
        l_ctr := l_ctr + 1;

        /*
        l_res_txn_tbl(l_ctr).wip_entity_id := l_resource_req_tbl(i).wip_entity_id;
        --l_res_txn_tbl(l_ctr).organization_id := l_resource_req_tbl(i).organization_id;
        l_res_txn_tbl(l_ctr).department_id := l_resource_req_tbl(i).department_id;
        l_res_txn_tbl(l_ctr).operation_seq_num := l_resource_req_tbl(i).operation_seq_num;
        l_res_txn_tbl(l_ctr).resource_seq_num := l_resource_req_tbl(i).resource_seq_num;
        l_res_txn_tbl(l_ctr).resource_id := l_resource_req_tbl(i).resource_id;
        l_res_txn_tbl(l_ctr).transaction_quantity := l_resource_req_tbl(i).transaction_quantity;
        l_res_txn_tbl(l_ctr).transaction_uom := l_resource_req_tbl(i).uom_code;
        */

        l_prd_resrc_txn_tbl(l_ctr).workorder_id := l_resource_req_tbl(i).workorder_id;
        l_prd_resrc_txn_tbl(l_ctr).organization_id := l_resource_req_tbl(i).organization_id;
        l_prd_resrc_txn_tbl(l_ctr).dml_operation := 'C';
        l_prd_resrc_txn_tbl(l_ctr).operation_sequence_num := l_resource_req_tbl(i).operation_seq_num;
        l_prd_resrc_txn_tbl(l_ctr).workorder_operation_id := l_resource_req_tbl(i).workorder_operation_id;
        l_prd_resrc_txn_tbl(l_ctr).resource_sequence_num := l_resource_req_tbl(i).resource_seq_num;
        l_prd_resrc_txn_tbl(l_ctr).resource_id := l_resource_req_tbl(i).resource_id;
        l_prd_resrc_txn_tbl(l_ctr).resource_name := l_resource_req_tbl(i).resource_name;

        l_prd_resrc_txn_tbl(l_ctr).department_id := l_resource_req_tbl(i).department_id;

        l_prd_resrc_txn_tbl(l_ctr).qty := l_resource_req_tbl(i).transaction_quantity;
        l_prd_resrc_txn_tbl(l_ctr).uom_code := l_resource_req_tbl(i).uom_code;

        -- Pass the Employee ID or the Serial Number
        IF ( l_resource_req_tbl(i).resource_type = 2 ) THEN
          --l_res_txn_tbl(l_ctr).employee_id := l_employee_id;
         l_prd_resrc_txn_tbl(l_ctr).employee_num := p_close_visit_rec.employee_number;
        ELSIF ( l_resource_req_tbl(i).resource_type = 1 ) THEN
          --l_res_txn_tbl(l_ctr).serial_number := p_close_visit_rec.serial_number;
          l_prd_resrc_txn_tbl(l_ctr).serial_number := p_close_visit_rec.serial_number;
        END IF;
      END IF;

    END LOOP;

    --IF ( l_res_txn_tbl.COUNT > 0 ) THEN
    IF ( l_prd_resrc_txn_tbl.COUNT > 0 ) THEN

      /*
      -- Perform the Resource Txns
      AHL_WIP_JOB_PVT.insert_resource_txn
      (
        p_api_version        => 1.0,
        p_init_msg_list      => FND_API.G_FALSE,
        p_commit             => FND_API.G_FALSE,
        p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,
        p_ahl_res_txn_tbl    => l_res_txn_tbl
      );
      */


      AHL_PRD_RESOURCE_TRANX_PVT.PROCESS_RESOURCE_TXNS
      (
        p_api_version        => 1.0,
        p_init_msg_list      => FND_API.G_FALSE,
        p_commit             => FND_API.G_FALSE,
        p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,
        p_x_prd_resrc_txn_tbl => l_prd_resrc_txn_tbl
      );

      IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

  END IF;
  /* Bug # 4955278 - end */

  l_ctr := 0;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Processing WO Operations' );
  END IF;

  -- Get all the Workorder Operations for the Visit
  FOR op_csr IN get_visit_operations( l_visit_rec.visit_id ) LOOP

    -- Check if Operations need to be completed
    IF ( p_close_visit_rec.complete_job_ops_flag = 'Y' ) THEN

      -- Do not process Workorder Operations which are already Complete
      IF ( op_csr.status_code <> G_OP_STATUS_COMPLETE ) THEN

        /*Start ER # 4757222*/
        /*
         * Moved this validation here since there is no need to validate
         * the actual dates entered against completed operations. Need to validate dates
         * against only those operations which need to be completed.
         */
        /* No need for this validation as the default dates entered by the user should not
        -- be modified. Balaji commented out the code for the ER # 4757222
        IF ( p_close_visit_rec.default_actual_dates_flag = 'N' ) THEN

        -- Validate if the actual start dates entered is less than any WO Op
        IF ( op_csr.actual_start_date IS NOT NULL AND
             op_csr.actual_start_date < p_close_visit_rec.actual_start_date ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_OP_ACT_ST_DATE_LESS' );
          FND_MESSAGE.set_token( 'WO_NAME', op_csr.workorder_name );
          FND_MESSAGE.set_token( 'OP_SEQ', op_csr.operation_seq_num );
          FND_MESSAGE.set_token( 'START_DT', TO_CHAR( op_csr.actual_start_date, 'DD-MON-YYYY HH24:MI' ) );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Validate if the actual end dates entered is greater than any WO Op
        IF ( op_csr.actual_end_date IS NOT NULL AND
             op_csr.actual_end_date > p_close_visit_rec.actual_end_date ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_OP_ACT_END_DATE_GT' );
          FND_MESSAGE.set_token( 'WO_NAME', op_csr.workorder_name );
          FND_MESSAGE.set_token( 'OP_SEQ', op_csr.operation_seq_num );
          FND_MESSAGE.set_token( 'END_DT', TO_CHAR( op_csr.actual_end_date, 'DD-MON-YYYY HH24:MI' ) );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF;*/

       /*End ER # 4757222*/
        -- Validate whether Quality Results are Submitted
        IF ( op_csr.plan_id IS NOT NULL AND
             op_csr.collection_id IS NULL ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_OP_QA_PENDING' );
          FND_MESSAGE.set_token( 'WO_NAME', op_csr.workorder_name );
          FND_MESSAGE.set_token( 'OP_SEQ', op_csr.operation_seq_num );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_ctr := l_ctr + 1;
        l_operation_tbl(l_ctr).workorder_operation_id := op_csr.workorder_operation_id;
        l_operation_tbl(l_ctr).object_version_number := op_csr.object_version_number;
        l_operation_tbl(l_ctr).workorder_name := op_csr.workorder_name;
        l_operation_tbl(l_ctr).collection_id := op_csr.collection_id;

	IF (op_csr.actual_end_date IS NULL OR op_csr.actual_start_date IS NULL)
	   AND
	   (p_close_visit_rec.default_actual_dates_flag = 'Y')
	THEN
		-- Derive operation actual dates from res txn dates.
		-- Balaji added this code for R12. Also refer ER # 4955278
   		Get_Op_Act_from_Res_Txn( p_wip_entity_id	=>	op_csr.wip_entity_id,
					 p_operation_seq_num	=>	op_csr.operation_seq_num,
					 x_actual_start_date	=>	l_def_actual_start_date,
					 x_actual_end_date	=>	l_def_actual_end_date
					);

		IF (l_def_actual_start_date IS NULL OR l_def_actual_end_date IS NULL )
		THEN
		  FND_MESSAGE.set_name( 'AHL', 'AHL_OP_DEF_NO_RES_TXN' );
		  FND_MESSAGE.set_token( 'WO_NAME', op_csr.workorder_name );
		  FND_MESSAGE.set_token( 'OP_SEQ', op_csr.operation_seq_num );
		  FND_MSG_PUB.add;
		  RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;

	/* Start ER # 4757222 */
        IF ( op_csr.actual_end_date IS NULL ) THEN

         IF ( p_close_visit_rec.default_actual_dates_flag = 'Y' ) THEN

            -- Update Actual Date with Scheduled Date
            l_operation_tbl(l_ctr).actual_end_date := LEAST( SYSDATE , l_def_actual_end_date );
          ELSE
            -- Update Actual Date with User Entered Value
            l_operation_tbl(l_ctr).actual_end_date := p_close_visit_rec.actual_end_date;
          END IF;
        ELSE

          -- Update Actual Date with DB Value if already entered
          l_operation_tbl(l_ctr).actual_end_date := op_csr.actual_end_date;
        END IF;

        -- Check if Actual Date is already entered
        IF ( op_csr.actual_start_date IS NULL ) THEN
          IF ( p_close_visit_rec.default_actual_dates_flag = 'Y' ) THEN
            -- Update Actual Date with Scheduled Date

            -- Update with Scheduled Date
            IF ( l_def_actual_start_date < SYSDATE ) THEN
               l_operation_tbl(l_ctr).actual_start_date := l_def_actual_start_date;
            ELSE
               l_operation_tbl(l_ctr).actual_start_date := l_operation_tbl(l_ctr).actual_end_date - (l_def_actual_end_date - l_def_actual_start_date);
            END IF;


          ELSE
            -- Update Actual Date with User Entered Value
            l_operation_tbl(l_ctr).actual_start_date := p_close_visit_rec.actual_start_date;
          END IF;
        ELSE

          -- Update Actual Date with DB Value if already entered
          l_operation_tbl(l_ctr).actual_start_date := op_csr.actual_start_date;
        END IF;
        /* End ER # 4757222 */

        /* commenting out the code as this was fixed for ER # 4757192
        -- Check if Actual Date is already entered
        IF ( op_csr.actual_start_date IS NULL ) THEN
          -- R12
	  -- actual dates should be defaulted from res txn dates
	  -- commented out
          IF ( p_close_visit_rec.default_actual_dates_flag = 'Y' ) THEN
            -- Update Actual Date with Scheduled Date
            l_operation_tbl(l_ctr).actual_start_date := op_csr.scheduled_start_date;
          ELSE
            -- Update Actual Date with User Entered Value
            l_operation_tbl(l_ctr).actual_start_date := p_close_visit_rec.actual_start_date;
          END IF;
	  -- commented out
	  IF ( p_close_visit_rec.default_actual_dates_flag = 'N' ) THEN
            -- Update Actual Date with User Entered Value
            l_operation_tbl(l_ctr).actual_start_date := p_close_visit_rec.actual_start_date;
          END IF;
        ELSE

          -- Update Actual Date with DB Value if already entered
          l_operation_tbl(l_ctr).actual_start_date := op_csr.actual_start_date;
        END IF;

        -- Check if Actual Date is already entered
        IF ( op_csr.actual_end_date IS NULL ) THEN
          -- R12
	  -- actual dates should be defaulted from res txn dates

          -- commented out
          IF ( p_close_visit_rec.default_actual_dates_flag = 'Y' ) THEN

            -- Update Actual Date with Scheduled Date
            l_operation_tbl(l_ctr).actual_end_date := LEAST( SYSDATE , op_csr.scheduled_end_date );
          ELSE

            -- Update Actual Date with User Entered Value
            l_operation_tbl(l_ctr).actual_end_date := p_close_visit_rec.actual_end_date;
          END IF;
	  -- commented out
          IF ( p_close_visit_rec.default_actual_dates_flag = 'N' ) THEN
            -- Update Actual Date with User Entered Value
            l_operation_tbl(l_ctr).actual_end_date := p_close_visit_rec.actual_end_date;
          END IF;
        ELSE

          -- Update Actual Date with DB Value if already entered
          l_operation_tbl(l_ctr).actual_end_date := op_csr.actual_end_date;
        END IF;
        */

        IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name
          || ' : Wo Name - ' || l_operation_tbl(l_ctr).workorder_name
          || ' OP Seq - ' || op_csr.operation_seq_num || ' WO OP ID - '
          || l_operation_tbl(l_ctr).workorder_operation_id || ' Actual Start Date - '
          || l_operation_tbl(l_ctr).actual_start_date || ' Actual End Date - '
          || l_operation_tbl(l_ctr).actual_end_date );
        END IF;

      END IF;
    ELSE
      -- Validate to ensure that the Workorder Ops are already completed
      IF ( op_csr.status_code <> G_OP_STATUS_COMPLETE ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_VST_WO_OP_NOT_CMPL' );
        FND_MESSAGE.set_token( 'VISIT_NUM', l_visit_rec.visit_number );
        FND_MESSAGE.set_token( 'WO_NAME', op_csr.workorder_name );
        FND_MESSAGE.set_token( 'OP_SEQ', op_csr.operation_seq_num );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  END LOOP;


  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Updating Operation Actual Dates' );
  END IF;

  -- perform the Operation Updates
  -- If the dates are to be defaulted then this will be done in the Completions API itself
  -- if p_default is passed as FND_API.G_TRUE
  --Balaji remvoed p_close_visit_rec.default_actual_dates_flag = 'N' condition for bug # 4955278

  IF ( p_close_visit_rec.complete_job_ops_flag = 'Y' ) THEN
  --AND p_close_visit_rec.default_actual_dates_flag = 'N'

  IF ( l_operation_tbl.COUNT > 0 ) THEN
    FOR i IN l_operation_tbl.FIRST..l_operation_tbl.LAST LOOP
      UPDATE  AHL_WORKORDER_OPERATIONS
      SET     object_version_number = object_version_number + 1,
              actual_start_date = l_operation_tbl(i).actual_start_date,
              actual_end_date = l_operation_tbl(i).actual_end_date,
              LAST_UPDATE_DATE = SYSDATE,
              LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
              LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
      WHERE   workorder_operation_id = l_operation_tbl(i).workorder_operation_id
      AND     object_version_number = l_operation_tbl(i).object_version_number;

      IF ( SQL%ROWCOUNT = 0 ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_operation_tbl(i).object_version_number := l_operation_tbl(i).object_version_number + 1;
    END LOOP;
  END IF;

  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Completing Operations' );
  END IF;

  -- Invoke Complete Operation API to Complete All Operations
  IF ( l_operation_tbl.COUNT > 0 ) THEN
    FOR i IN l_operation_tbl.FIRST..l_operation_tbl.LAST LOOP
      complete_operation
      (
        p_api_version            => 1.0,
        p_init_msg_list          => FND_API.G_FALSE,
        p_commit                 => FND_API.G_FALSE,
        p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
        p_default                => FND_API.G_FALSE,
        p_module_type            => NULL,
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data,
        p_workorder_operation_id => l_operation_tbl(i).workorder_operation_id,
        p_object_version_no      => l_operation_tbl(i).object_version_number
      );

      IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END LOOP;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Updating WO Actual Dates' );
  END IF;

  -- Perform the Workorder Updates
  -- After operation updates and operation completion
  IF ( l_workorder_tbl.COUNT > 0 ) THEN
    FOR i IN l_workorder_tbl.FIRST..l_workorder_tbl.LAST LOOP

     /*Start ER # 4757222*/
     IF ( l_workorder_tbl(i).master_workorder_flag = 'N' AND
          p_close_visit_rec.complete_job_ops_flag  = 'Y') THEN

      -- Derive actual dates for the workorder from operation dates.
      Get_default_wo_actual_dates(x_return_status => l_return_status,
                                p_workorder_id => l_workorder_tbl(i).workorder_id,
				x_actual_start_date => l_def_actual_start_date,
				x_actual_end_date => l_def_actual_end_date
				);

      -- update the actual dates in the table
      IF l_workorder_tbl(i).actual_start_date IS NULL THEN
        UPDATE AHL_WORKORDERS
        SET OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
        ACTUAL_START_DATE = l_def_actual_start_date,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
        WHERE WORKORDER_ID = l_workorder_tbl(i).workorder_id
        AND OBJECT_VERSION_NUMBER = l_workorder_tbl(i).object_version_number;
        IF SQL%ROWCOUNT = 0 THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
	  FND_MESSAGE.set_token('WO_NAME', l_workorder_tbl(i).workorder_name);
     	  FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        l_workorder_tbl(i).object_version_number := l_workorder_tbl(i).object_version_number + 1;
      END IF;-- IF l_actual_start_date IS NULL THEN

      -- update the actual dates in the table
      IF l_workorder_tbl(i).actual_end_date IS NULL THEN
        UPDATE AHL_WORKORDERS
        SET OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
        ACTUAL_END_DATE = l_def_actual_end_date,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
        WHERE WORKORDER_ID = l_workorder_tbl(i).workorder_id
        AND OBJECT_VERSION_NUMBER = l_workorder_tbl(i).object_version_number;
        IF SQL%ROWCOUNT = 0 THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
  	  FND_MESSAGE.set_token('WO_NAME', l_workorder_tbl(i).workorder_name);
   	  FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        l_workorder_tbl(i).object_version_number := l_workorder_tbl(i).object_version_number + 1;
      END IF; -- IF l_actual_end_date IS NULL THEN

     END IF;
     /*End ER # 4757222*/
      /*Start ER # 4757222
      -- Ignore Master Workorders since they are post processed seperately
      IF ( l_workorder_tbl(i).master_workorder_flag = 'N' ) THEN
        UPDATE  AHL_WORKORDERS
        SET     object_version_number = object_version_number + 1,
                actual_start_date = l_workorder_tbl(i).actual_start_date,
                actual_end_date = l_workorder_tbl(i).actual_end_date
        WHERE   workorder_id = l_workorder_tbl(i).workorder_id
        AND     object_version_number = l_workorder_tbl(i).object_version_number;

        IF ( SQL%ROWCOUNT = 0 ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_workorder_tbl(i).object_version_number := l_workorder_tbl(i).object_version_number + 1;
      END IF;
      */
      /*End ER # 4757222*/
    END LOOP;

    -- Check if Workorders need to be completed
    IF ( p_close_visit_rec.complete_job_ops_flag = 'Y' AND
         p_close_visit_rec.default_actual_dates_flag = 'N' ) THEN
      l_actual_start_date := p_close_visit_rec.actual_start_date;
      l_actual_end_date := p_close_visit_rec.actual_end_date;
    END IF;

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Updating Actual Dates for Master WOs in Visit' );
    END IF;

    -- Update the Actual Dates for Master Workorders in the Visit
    l_return_status :=
    update_mwo_actual_dates
    (
      p_wip_entity_id     => l_visit_rec.wip_entity_id,
      p_default_flag      => p_close_visit_rec.default_actual_dates_flag,
      p_actual_start_date => l_actual_start_date,
      p_actual_end_date   => l_actual_end_date
    );

    IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;


  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Completing WOs' );
  END IF;

  -- Complete All Visit Workorders in the Order of Completion Dependencies
  IF ( l_workorder_tbl.COUNT > 0 ) THEN
    l_return_status :=
    complete_visit_mr_wos
    (
      p_wip_entity_id   => l_visit_rec.wip_entity_id,
      p_x_workorder_tbl => l_workorder_tbl
    );

    IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Signing off MRs' );
  END IF;

  -- Invoke Complete MR Instance API to Complete All UEs
  IF ( l_child_mr_tbl.COUNT > 0 ) THEN
    FOR i IN l_child_mr_tbl.FIRST..l_child_mr_tbl.LAST LOOP

      -- Check Status again because MR could be completed automatically
      l_ue_status_code := get_mr_status( l_child_mr_tbl(i).unit_effectivity_id );
      --IF ( l_ue_status_code <> G_MR_STATUS_SIGNED_OFF ) THEN
      -- Balaji added additional MR status checks for BAE Bug
      IF (
	      l_ue_status_code <> G_MR_STATUS_SIGNED_OFF AND
	      l_ue_status_code <> G_MR_STATUS_DEFERRED AND
	      l_ue_status_code <> G_MR_STATUS_TERMINATED AND
	      l_ue_status_code <> G_MR_STATUS_CANCELLED AND
              l_ue_status_code <> G_MR_STATUS_MR_TERMINATED

      ) THEN

        IF ( l_ue_status_code <> G_MR_STATUS_JOBS_COMPLETE ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_INV_SIGNOFF_STATUS');
          FND_MESSAGE.set_token( 'MAINT_REQ', l_child_mr_tbl(i).mr_title);
		-- to be changed
		-- write a global function later
		-- replacing with call to get_status function
				-- so no exceptions are thrown if the
				-- lookup does not exist
				l_status_meaning := get_status(l_ue_status_code,
																																											'AHL_PRD_MR_STATUS');

      /*SELECT meaning INTO l_status_meaning
	   FROM fnd_lookup_values_vl
        WHERE lookup_type = 'AHL_PRD_MR_STATUS'
          AND LOOKUP_CODE = l_ue_status_code;
					*/
          FND_MESSAGE.set_token( 'STATUS', l_status_meaning );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
/*        complete_mr_instance
        (
          p_api_version            => 1.0,
          p_init_msg_list          => FND_API.G_FALSE,
          p_commit                 => FND_API.G_FALSE,
          p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
          p_default                => FND_API.G_FALSE,
          p_module_type            => NULL,
          x_return_status          => l_return_status,
          x_msg_count              => l_msg_count,
          x_msg_data               => l_msg_data,
          p_x_mr_rec               => l_child_mr_tbl(i)
        );
*/
--JKJain, Bug 9250614, To populate QCP, calling Signoff instead of complete_mr_instance.
         l_signoff_mr_rec.unit_effectivity_id := l_child_mr_tbl(i).unit_effectivity_id;
    	 l_signoff_mr_rec.object_version_number := l_child_mr_tbl(i).ue_object_version_no;
	   	 l_signoff_mr_rec.signoff_child_mrs_flag := 'N';
	   	 l_signoff_mr_rec.complete_job_ops_flag := 'N';
	   	 l_signoff_mr_rec.transact_resource_flag := 'N';


         signoff_mr_instance
	  	  (
          p_api_version            => 1.0,
          p_init_msg_list          => FND_API.G_FALSE,
          p_commit                 => FND_API.G_FALSE,
          p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
          p_default                => FND_API.G_FALSE,
          p_module_type            => NULL,
          x_return_status          => l_return_status,
          x_msg_count              => l_msg_count,
          x_msg_data               => l_msg_data,
          p_signoff_mr_rec         => l_signoff_mr_rec
         );

        IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

    END LOOP;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Closing Visit' );
  END IF;

  -- Invoke close_visit API to close the Visit in VWP and Projects
  AHL_VWP_VISITS_PVT.close_visit
  (
    p_api_version            => 1.0,
    p_init_msg_list          => FND_API.G_FALSE,
    p_commit                 => FND_API.G_FALSE,
    p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
    p_module_type            => NULL,
    p_visit_id               => p_close_visit_rec.visit_id,
    p_x_cost_session_id      => l_cost_session_id,
    p_x_mr_session_id        => l_mr_session_id,
    x_return_status          => l_return_status,
    x_msg_count              => l_msg_count,
    x_msg_data               => l_msg_data
  );

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

--JKJain, Bug 9250614, Define label
<<vmwo_counter_qa_results_label>>

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Recording Counter Readings, COUNT = '||l_workorder_tbl.COUNT|| ' and Plan_ID = '|| G_CTR_READING_PLAN_ID  );
  END IF;


  -- Record Counter Readings for all WOs
  IF ( l_workorder_tbl.COUNT > 0 AND
       G_CTR_READING_PLAN_ID IS NOT NULL AND
       l_visit_rec.item_instance_id IS NOT NULL ) THEN

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Getting Counters' );
    END IF;

    -- Bug # 6750836 -- Start

    --IF ( l_counter_tbl.COUNT > 0 ) THEN

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Recording WO Counter Readings' );
      END IF;

      -- Record Counter Readings for all the Workorders.
      FOR i IN l_workorder_tbl.FIRST..l_workorder_tbl.LAST LOOP

        -- Get the Current Counter Readings for the Item Instance.
        l_return_status :=
        get_cp_counters
        (
          p_item_instance_id  => l_visit_rec.item_instance_id,
          p_wip_entity_id     => l_workorder_tbl(i).wip_entity_id,
          p_actual_date       => l_workorder_tbl(i).actual_end_date,
          x_counter_tbl       => l_counter_tbl
        );

        IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF ( l_counter_tbl.COUNT > 0 ) THEN

		l_return_status :=
		record_wo_ctr_readings
		(
		  x_msg_data           => l_msg_data,
		  x_msg_count          => l_msg_count,
		  p_wip_entity_id      => l_workorder_tbl(i).wip_entity_id,
		  p_counter_tbl        => l_counter_tbl
		);

		IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
		  RAISE FND_API.G_EXC_ERROR;
		ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		-- Re-set the API savepoint because, Quality Results submission commits
		SAVEPOINT close_visit_PVT;

        END IF;

      END LOOP;
    --END IF;
    -- Bug # 6750836 -- end
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Before Firing QA Actions' );
  END IF;

  -- Fire QA Actions for all MRs
  IF ( l_child_mr_tbl.COUNT > 0 ) THEN
    FOR i IN l_child_mr_tbl.FIRST..l_child_mr_tbl.LAST LOOP
      IF ( l_child_mr_tbl(i).qa_collection_id IS NOT NULL ) THEN

        QA_SS_RESULTS.wrapper_fire_action
        (
          q_collection_id    => l_child_mr_tbl(i).qa_collection_id,
          q_return_status    => l_return_status,
          q_msg_count        => l_msg_count,
          q_msg_data         => l_msg_data
        );

        IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
          x_msg_data := l_msg_data;
          x_msg_count := l_msg_count;
          RETURN;
        ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Re-set the API savepoint because, the wrapper_fire_action commits.
        SAVEPOINT close_visit_PVT;

      END IF;
    END LOOP;
  END IF;

  -- Fire QA Actions for all Operations
  IF ( l_operation_tbl.COUNT > 0 ) THEN
    FOR i IN l_operation_tbl.FIRST..l_operation_tbl.LAST LOOP
      IF ( l_operation_tbl(i).collection_id IS NOT NULL ) THEN

        QA_SS_RESULTS.wrapper_fire_action
        (
          q_collection_id    => l_operation_tbl(i).collection_id,
          q_return_status    => l_return_status,
          q_msg_count        => l_msg_count,
          q_msg_data         => l_msg_data
        );

        IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
          x_msg_data := l_msg_data;
          x_msg_count := l_msg_count;
          RETURN;
        ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Re-set the API savepoint because, the wrapper_fire_action commits.
        SAVEPOINT close_visit_PVT;

      END IF;
    END LOOP;
  END IF;

  -- Fire QA Actions for all Workorders
  IF ( l_workorder_tbl.COUNT > 0 ) THEN
    FOR i IN l_workorder_tbl.FIRST..l_workorder_tbl.LAST LOOP
      IF ( l_workorder_tbl(i).collection_id IS NOT NULL ) THEN

        QA_SS_RESULTS.wrapper_fire_action
        (
          q_collection_id    => l_workorder_tbl(i).collection_id,
          q_return_status    => l_return_status,
          q_msg_count        => l_msg_count,
          q_msg_data         => l_msg_data
        );

        IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
          x_msg_data := l_msg_data;
          x_msg_count := l_msg_count;
          RETURN;
        ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Re-set the API savepoint because, the wrapper_fire_action commits.
        SAVEPOINT close_visit_PVT;

      END IF;
    END LOOP;
  END IF;

  -- Perform the Commit (if requested)
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Disable debug (if enabled)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO close_visit_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO close_visit_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN OTHERS THEN
    ROLLBACK TO close_visit_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.add_exc_msg
      (
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240)
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;
END close_visit;

------------------------------------------------------------------------------------------------
-- Function to check if the workorder completion operation can be carried out. Following factors
-- determine the same...
-- 1. Unit is quarantined.
-- 2. Workorder is in a status where it can be completed.
-- 3. Status of child workorders.
-- 4. Status of containing operations.
-- 5. Quality collection has been done for the workorder or not.
------------------------------------------------------------------------------------------------

FUNCTION Is_Complete_Enabled(
		p_workorder_id		IN	NUMBER,
		P_operation_seq_num	IN	NUMBER,
		p_ue_id                 IN      NUMBER,
                p_check_unit            IN      VARCHAR2 DEFAULT FND_API.G_TRUE
)
RETURN VARCHAR2
IS

/*
 * Cursor for getting workorder_operation_id from workorder_id and op_seq_no
 */
CURSOR c_get_wo_op_id(p_workorder_id IN NUMBER, p_op_seq_no IN NUMBER)
IS
SELECT
	workorder_operation_id
FROM
	AHL_WORKORDER_OPERATIONS
WHERE
	workorder_id = p_workorder_id AND
	operation_sequence_num = p_op_seq_no;

-- To get the Unit Effectivity Details and it's master workorder details
CURSOR     get_ue_details( c_unit_effectivity_id NUMBER ) IS
SELECT     --UE.unit_effectivity_id unit_effectivity_id,
           --UE.title ue_title,
           --UE.ump_status_code ue_status_code,
           UE.status_code ue_status_code,
           --UE.qa_inspection_type_code ue_qa_inspection_type_code,
           --UE.qa_plan_id ue_qa_plan_id,
           --UE.qa_collection_id ue_qa_collection_id,
           WO.workorder_id workorder_id,
           WO.wip_entity_id wip_entity_id
FROM       AHL_WORKORDERS WO,
           AHL_VISIT_TASKS_B VT,
           --AHL_UE_DEFERRAL_DETAILS_V UE
           AHL_UNIT_EFFECTIVITIES_B UE
WHERE      WO.visit_task_id = VT.visit_task_id
AND        VT.task_type_code IN ( 'SUMMARY' , 'UNASSOCIATED' )
AND        VT.unit_effectivity_id = UE.unit_effectivity_id
AND        UE.unit_effectivity_id = c_unit_effectivity_id;

-- Cursor to get the child ue details
-- fix for bug number 7295717 (Sunil)
/*CURSOR     get_child_ue_details( c_unit_effectivity_id NUMBER ) IS
SELECT     unit_effectivity_id,
           title,
           ump_status_code,
           qa_inspection_type_code,
           qa_plan_id,
           qa_collection_id
FROM       AHL_UE_DEFERRAL_DETAILS_V
WHERE      unit_effectivity_id IN
           (
             SELECT     related_ue_id
             FROM       AHL_UE_RELATIONSHIPS
             WHERE      unit_effectivity_id = related_ue_id
             START WITH ue_id = c_unit_effectivity_id
                    AND relationship_code = 'PARENT'
             CONNECT BY ue_id = PRIOR related_ue_id
                    AND relationship_code = 'PARENT'
           );*/
--ORDER BY   level DESC;

-- To get the Child Workorder Details for a UE
CURSOR     get_ue_workorders( c_wip_entity_id NUMBER ) IS
SELECT     CWO.workorder_id workorder_id
FROM       WIP_DISCRETE_JOBS WIP,
           AHL_WORKORDERS CWO,
           WIP_SCHED_RELATIONSHIPS REL
WHERE      WIP.wip_entity_id = CWO.wip_entity_id
AND        CWO.wip_entity_id = REL.child_object_id
AND        CWO.status_code NOT IN (G_JOB_STATUS_DELETED, G_JOB_STATUS_COMPLETE, G_JOB_STATUS_COMPLETE_NC, G_JOB_STATUS_CANCELLED, G_JOB_STATUS_CLOSED)
AND        REL.parent_object_type_id = 1
AND        REL.child_object_type_id = 1
START WITH REL.parent_object_id = c_wip_entity_id
AND        REL.relationship_type = 1
CONNECT BY REL.parent_object_id = PRIOR REL.child_object_id
AND        REL.relationship_type = 1
ORDER BY   level DESC;

-- To get all the UE Operations
CURSOR     get_ue_operations( c_wip_entity_id NUMBER ) IS
SELECT					WOP.workorder_id workorder_id,
           WIP.operation_seq_num operation_seq_num
FROM       AHL_WORKORDER_OPERATIONS WOP,
           WIP_OPERATIONS WIP,
           AHL_WORKORDERS CWO
WHERE      WOP.operation_sequence_num = WIP.operation_seq_num
AND        WOP.workorder_id = CWO.workorder_id
AND        WIP.wip_entity_id = CWO.wip_entity_id
AND        WIP.WIP_ENTITY_ID IN (
             SELECT     CWO.wip_entity_id
FROM       WIP_DISCRETE_JOBS WIP,
           AHL_WORKORDERS CWO,
           WIP_SCHED_RELATIONSHIPS REL
WHERE      WIP.wip_entity_id = CWO.wip_entity_id
AND        CWO.wip_entity_id = REL.child_object_id
AND        CWO.status_code <> G_JOB_STATUS_DELETED
AND        REL.parent_object_type_id = 1
AND        REL.child_object_type_id = 1
START WITH REL.parent_object_id = c_wip_entity_id
AND        REL.relationship_type = 1
CONNECT BY REL.parent_object_id = PRIOR REL.child_object_id
AND        REL.relationship_type = 1);
--ORDER BY   level DESC;

--declare local variables here
l_mr_rec        get_ue_details%ROWTYPE;
l_workorder_rec AHL_COMPLETIONS_PVT.workorder_rec_type;
l_operation_tbl AHL_COMPLETIONS_PVT.operation_tbl_type;
l_operation_rec AHL_COMPLETIONS_PVT.operation_rec_type;
l_workorder_operation_id NUMBER;
l_object_version_no NUMBER;
l_date_validation VARCHAR2(1);
l_return_status VARCHAR2(1);

BEGIN
	-- If all inputs to the API are null then dont proceed any further.
	IF p_workorder_id IS NULL AND p_operation_seq_num IS NULL AND p_ue_id IS NULL
	THEN
		RETURN FND_API.G_FALSE;
	END IF;

	-- If the unit is locked then workorder or operation cant be completed hence return
	-- false.
        -- rroy
	-- Commenting out the is unit locked check here
	-- since this is being done in the validate_cop_Rec and validate_cwo_rec
	-- functions as well
	-- Hence, this becomes redundant

	/*IF AHL_PRD_UTIL_PKG.Is_Unit_Locked(
			  p_workorder_id 	=> p_workorder_id,
			  P_ue_id		=>	null,
			  P_visit_id		=>	null,
			  P_item_instance_id	=>	null
			 ) = FND_API.G_TRUE
	THEN
		RETURN FND_API.G_FALSE;
	END IF;
	*/

 -- Get workorder record details. This also performs workorder status validation.
	IF p_workorder_id IS NOT NULL THEN
	l_return_status := get_workorder_rec (p_workorder_id		=>	p_workorder_id,
	    				      p_object_version_no	=>	l_object_version_no,
	   				      x_workorder_rec		=>	l_workorder_rec
	     		   );
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS
	THEN
		RETURN FND_API.G_FALSE;
	END IF;
	END IF;

	-- If operation sequence number is passed to this API then the info is for operation completion
	IF p_operation_seq_num IS NOT NULL
	THEN
		-- Get workorder_operation_id.
		OPEN c_get_wo_op_id(p_workorder_id, p_operation_seq_num);
		FETCH c_get_wo_op_id INTO l_workorder_operation_id;
		CLOSE c_get_wo_op_id;

		IF l_workorder_operation_id IS NULL
		THEN
			RETURN FND_API.G_FALSE;
		END IF;

		-- Get workorder operation details rec.
		l_return_status := get_operation_rec(
					p_workorder_operation_id	=>	l_workorder_operation_id,
					p_object_version_no		=>	l_object_version_no,
					x_operation_rec			=>	l_operation_rec
	  			   );

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			RETURN FND_API.G_FALSE;
		END IF;
		-- If p_ue_id is not null
		-- then this is a check to see if mr signoff should be enabled
		-- in that case operation status validations should be skipped
		-- Just assign a dummy Uncomplete status to it so that status validations go thru without errors
		IF p_ue_id IS NOT NULL THEN
		  l_operation_rec.status_code := G_OP_STATUS_UNCOMPLETE;
		END IF;
		-- Validate if the workorder operation can be completed. Skip date validations since
		-- that is required only during completion operation.

		l_return_status := validate_cop_rec(
  					p_operation_rec		=>	l_operation_rec,
  					p_workorder_rec		=>	l_workorder_rec,				     			  	             p_validate_date	     =>	     l_date_validation,
					p_check_unit            =>      p_check_unit
				   );

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			RETURN FND_API.G_FALSE;
		END IF;

	ELSIF p_workorder_id IS NOT NULL THEN
		-- Get workorder and operation details for the given workorder.
		-- Operations will be validated only if the p_ue_id is null,
		-- that is this is not to check that mr signoff is enabled
		IF p_ue_id IS NULL THEN
		l_return_status := get_workorder_operations(
					p_workorder_id		=>	p_workorder_id,
					p_object_version_no	=>	l_object_version_no,
		   	  		x_operation_tbl		=>	l_operation_tbl
 				 );
		IF l_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			RETURN FND_API.G_FALSE;
		END IF;
		ELSE
		-- If p_ue_id is not null
		-- then this is a check to see if mr signoff should be enabled
		-- in that case workorder status validations should be skipped
		-- Just assign a dummy Uncomplete status to it so that status validations go thru without errors
    l_workorder_rec.status_code := G_JOB_STATUS_RELEASED;
		END IF;
		-- Validate if the workorder can be completed. Date validation is not required
		-- in this case and required only during completion operation.

		l_return_status := validate_cwo_rec(
					  p_workorder_rec	=>	l_workorder_rec,
					  p_operation_tbl	=>	l_operation_tbl,
					  p_validate_date	=>	l_date_validation,
				    	  p_check_unit          =>      p_check_unit
				   );

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			RETURN FND_API.G_FALSE;
		END IF;
	ELSIF p_ue_id IS NOT NULL THEN
	-- As of now we dont check for mr signoff enabled
	-- This code to validate if mr signoff is enabled will be added later

	-- Validate the status of this MR
	-- If the status is already signed off, then return false
 OPEN  get_ue_details(p_ue_id);
 FETCH get_ue_details INTO l_mr_rec;
	IF get_ue_details%NOTFOUND THEN
	  CLOSE get_ue_details;
			RETURN FND_API.G_FALSE;
	END IF;
	CLOSE get_ue_details;

	IF (l_mr_rec.ue_status_code = G_MR_STATUS_SIGNED_OFF) THEN
	  RETURN FND_API.G_FALSE;
	END IF;

 /*l_return_status := is_mr_complete(p_mr_title             => l_mr_rec.ue_title,
                                   p_status_code          => l_mr_rec.ue_status_code,
                                   p_status               => NULL,
                                   p_qa_inspection_type   => l_mr_rec.ue_qa_inspection_type_code,
                                   p_qa_plan_id           => l_mr_rec.ue_qa_plan_id,
                                   p_qa_collection_id     => l_mr_rec.ue_qa_collection_id
                                   );
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  RETURN FND_API.G_FALSE;
	END IF;

 FOR child_csr IN get_child_ue_details(p_ue_id) LOOP
   IF (NVL(child_csr.ump_status_code,'X') <> NVL(G_MR_STATUS_SIGNED_OFF, 'Y')) THEN
     -- Check if the Child UE is complete
     l_return_status := is_mr_complete(p_mr_title             => child_csr.title,
                                       p_status_code          => child_csr.ump_status_code,
                                       p_status               => NULL,
                                       p_qa_inspection_type   => child_csr.qa_inspection_type_code,
                                       p_qa_plan_id           => child_csr.qa_plan_id,
                                       p_qa_collection_id     => child_csr.qa_collection_id
                                      );

	    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	      RETURN FND_API.G_FALSE;
	    END IF;
			END IF;
	END LOOP;

	-- Get all the Workorders for the UE
 FOR wo_csr IN get_ue_workorders(l_mr_rec.wip_entity_id) LOOP
   l_return_status := is_complete_enabled(p_workorder_id => wo_csr.workorder_id,
			                                       p_operation_seq_num => NULL,
																																										p_ue_id => p_ue_id,
																																										p_check_unit => FND_API.G_FALSE
																																										);
		 IF l_return_status = FND_API.G_FALSE THEN
			  RETURN FND_API.G_FALSE;
			END IF;
	END LOOP;

	FOR op_csr IN get_ue_operations(l_mr_rec.wip_entity_id) LOOP
   l_return_status := is_complete_enabled(p_workorder_id => op_csr.workorder_id,
			                                       p_operation_seq_num => op_csr.operation_seq_num,
																																										p_ue_id => p_ue_id,
																																										p_check_unit => FND_API.G_FALSE
																																										);
		 IF l_return_status = FND_API.G_FALSE THEN
			  RETURN FND_API.G_FALSE;
			END IF;
	END LOOP;*/

	END IF;

	-- When control reaches here, none of the conditions are violated. Hence return true.
	RETURN FND_API.G_TRUE;

END Is_Complete_Enabled;


/*##################################################################################################*/
--# NAME
--#     PROCEDURE: Get_Default_Op_Actual_Dates
--# PARAMETERS
--# Standard IN Parameters
--#  None
--#
--# Standard OUT Parameters
--#  x_return_status    OUT NOCOPY VARCHAR2
--#  x_msg_count        OUT NOCOPY NUMBER
--#  x_msg_data         OUT NOCOPY VARCHAR2
--#
--# Get_Default_Op_Actual_Dates Parameters
--#  P_x_operation_tbl   IN AHL_COMPLETIONS_PVT.operation_tbl_type - Table holding the operation records
--#
--# DESCRIPTION
--#  This function will be used to default the actual dates before completing operations using the
--#  My Workorders or Update Workorders Uis. Calling APIs need to populate only the workorder_id and
--#  operation_sequence_num Get_Default_Wo_Actual_Datesfields of the operations records.
--#
--# HISTORY
--#   16-Jun-2005   rroy  Created
--###################################################################################################*/

PROCEDURE Get_Default_Op_Actual_Dates
(
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  P_x_operation_tbl  IN OUT NOCOPY AHL_COMPLETIONS_PVT.operation_tbl_type
)
IS
L_workorder_operation_id NUMBER;
L_ovn NUMBER;
L_wip_entity_id NUMBER;
L_scheduled_start_date DATE;
L_scheduled_end_date DATE;
L_min_txn_date DATE;
L_max_txn_date DATE;
L_min_pending_txn_date DATE;
L_max_pending_txn_date DATE;
l_start_date DATE;
l_end_date DATE;

-- cursor to retrieve the relevant operation details from AHL_WORKORDER_OPERATIONS table
CURSOR c_get_op_details(x_workorder_id NUMBER,
                        x_operation_seq_num NUMBER)
IS
SELECT WORKORDER_OPERATION_ID,
       OBJECT_VERSION_NUMBER,
       SCHEDULED_START_DATE,
       SCHEDULED_END_DATE,
       ACTUAL_START_DATE,
       ACTUAL_END_DATE
FROM AHL_WORKORDER_OPERATIONS_V
WHERE WORKORDER_ID = x_workorder_id
AND OPERATION_SEQUENCE_NUM = x_operation_seq_num;

-- cursor to retrieve the wip_entity_id
CURSOR c_get_wo_details(x_workorder_id NUMBER)
IS
SELECT WIP_ENTITY_ID
FROM AHL_WORKORDERS
WHERE WORKORDER_ID = x_workorder_id;

-- cursor to retrieve minimum and maximum resource transactions dates for this
-- operation for resource transactions of type 'Person'
CURSOR c_get_txn_dates(x_wip_entity_id NUMBER,
			                    x_operation_seq_num NUMBER)
IS
SELECT MIN(WIPT.TRANSACTION_DATE),
MAX(WIPT.TRANSACTION_DATE + (WIPT.TRANSACTION_QUANTITY/24))
-- Using the transaction quantity above since we know the
-- transaction uom is in hours
FROM WIP_TRANSACTIONS WIPT,
BOM_RESOURCES BOMR
WHERE WIPT.RESOURCE_ID = BOMR.RESOURCE_ID
AND WIPT.WIP_ENTITY_ID = x_wip_entity_id
AND WIPT.OPERATION_SEQ_NUM = x_operation_seq_num
AND BOMR.RESOURCE_TYPE IN (1,2); -- Person/Machine

-- cursor to retrieve the maximum and minimum transaction dates from
-- pending resource transactions for this operation which are of
-- type 'Person' and are in status 'Pending'.
/*CURSOR c_get_pending_txn_dates(x_wip_entity_id NUMBER,
			                            x_operation_seq_num NUMBER)
IS
SELECT MIN(WIPT.TRANSACTION_DATE),
       MAX(WIPT.TRANSACTION_DATE + (WIPT.TRANSACTION_QUANTITY/24))
FROM WIP_COST_TXN_INTERFACE WIPT
WHERE WIPT.WIP_ENTITY_ID = x_wip_entity_id
AND WIPT.OPERATION_SEQ_NUM = x_operation_seq_num
AND WIPT.RESOURCE_TYPE = 2 -- Person
AND WIPT.PROCESS_STATUS = 1; -- Pending*/

--fix for bug 8516683
CURSOR c_get_pending_txn_dates(x_wip_entity_id NUMBER,
                                                    x_operation_seq_num NUMBER)
IS
SELECT MIN(WIPT.TRANSACTION_DATE),
       MAX(WIPT.TRANSACTION_DATE + (WIPT.TRANSACTION_QUANTITY/24))
FROM WIP_COST_TXN_INTERFACE WIPT,BOM_RESOURCES BOMR, wip_operation_resources WOR
WHERE WOR.RESOURCE_ID = BOMR.RESOURCE_ID
AND WOR.RESOURCE_SEQ_NUM = WIPT.RESOURCE_SEQ_NUM
AND WIPT.WIP_ENTITY_ID = WOR.WIP_ENTITY_ID
AND WIPT.OPERATION_SEQ_NUM = WOR.OPERATION_SEQ_NUM
AND WIPT.WIP_ENTITY_ID = x_wip_entity_id
AND WIPT.OPERATION_SEQ_NUM = x_operation_seq_num
AND BOMR.RESOURCE_TYPE IN (1,2)
AND WIPT.PROCESS_STATUS = 1; -- Pending

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_x_operation_tbl.COUNT > 0 THEN
    FOR i IN p_x_operation_tbl.FIRST..p_x_operation_tbl.LAST LOOP
      -- Get the operation and workorder details
      OPEN c_get_op_details(p_x_operation_tbl (i).workorder_id, p_x_operation_tbl (i).operation_sequence_num);
      FETCH c_get_op_details INTO l_workorder_operation_id, l_ovn, l_scheduled_start_date, l_scheduled_end_date, p_x_operation_tbl(i).actual_start_date, p_x_operation_tbl(i).actual_end_date;
      IF c_get_op_details%NOTFOUND THEN
	CLOSE c_get_op_details;
       	FND_MESSAGE.set_name('AHL', 'AHL_PRD_WO_OP_NOT_FND');
	FND_MSG_PUB.add;
	x_return_status := FND_API.G_RET_STS_ERROR;
	RETURN;
       	--RAISE FND_API.G_RET_STS_ERROR;
      END IF;
      CLOSE c_get_op_details;

      OPEN c_get_wo_details(p_x_operation_tbl (i).workorder_id);
      FETCH c_get_wo_details INTO l_wip_entity_id;
      IF c_get_wo_details%NOTFOUND THEN
        CLOSE c_get_wo_details;
        FND_MESSAGE.set_name('AHL', 'AHL_PRD_WO_NOT_FND');
        FND_MSG_PUB.add;
        X_return_status := FND_API.G_RET_STS_ERROR;
	RETURN;
       	--RAISE FND_API.G_RET_STS_ERROR;
      END IF;
      CLOSE c_get_wo_details;
      -- Get the minimum and maximum transaction dates from the
      -- WIP_TRANSACTIONS and WIP_COST_TXN_INTERFACE tables for the
      -- resource transactions and pending resource transactions
      OPEN c_get_txn_dates(l_wip_entity_id, p_x_operation_tbl(i).operation_sequence_num);
      FETCH c_get_txn_dates INTO l_min_txn_date, l_max_txn_date;
      OPEN c_get_pending_txn_dates(l_wip_entity_id, p_x_operation_tbl(i).operation_sequence_num);
      -- fix for bug# 8516683
      -- FETCH c_get_txn_dates INTO l_min_pending_txn_date, l_max_pending_txn_date;
      FETCH c_get_pending_txn_dates INTO l_min_pending_txn_date, l_max_pending_txn_date;
      -- Balaji added this logic for bug # 5333796 - start
      IF  l_min_txn_date IS NULL AND l_max_txn_date IS NULL AND l_min_pending_txn_date IS NULL AND l_max_pending_txn_date IS NULL THEN

        IF p_x_operation_tbl (i).actual_end_date IS NULL THEN
          p_x_operation_tbl (i).actual_end_date := LEAST(l_scheduled_end_date,SYSDATE);
        END IF;

        IF p_x_operation_tbl (i).actual_start_date IS NULL THEN
          IF l_scheduled_start_date < SYSDATE THEN
          	p_x_operation_tbl (i).actual_start_date:= l_scheduled_start_date;
          ELSE
          	p_x_operation_tbl (i).actual_start_date:= p_x_operation_tbl (i).actual_end_date - (l_scheduled_end_date - l_scheduled_start_date);
          END IF;
        END IF;

      ELSE

        l_end_date:= GREATEST(NVL(l_max_txn_date, l_max_pending_txn_date), NVL(l_max_pending_txn_date, l_max_txn_date));
	l_start_date := LEAST(NVL(l_min_txn_date, l_min_pending_txn_date), NVL(l_min_pending_txn_date, l_min_txn_date));

        IF p_x_operation_tbl (i).actual_end_date IS NULL THEN
          p_x_operation_tbl (i).actual_end_date := LEAST(l_end_date, SYSDATE);
        END IF;

        -- At least one of completed or pending resource transaction dates have been found
        IF p_x_operation_tbl (i).actual_start_date IS NULL THEN
          IF l_start_date < SYSDATE THEN
          	p_x_operation_tbl (i).actual_start_date := l_start_date;
          ELSE
          	p_x_operation_tbl (i).actual_start_date := p_x_operation_tbl (i).actual_end_date - (l_end_date - l_start_date);
          END IF;
        END IF;

      END IF;-- IF c_get_txn_dates%NOTFOUND AND c_get_pending_txn_dates%NOTFOUND THEN
      -- Balaji added this logic for bug # 5333796 - end
      CLOSE c_get_pending_txn_dates;
      CLOSE c_get_txn_dates;

    END LOOP;
  END IF; --IF p_x_operation_tbl.COUNT > 0 THEN

END Get_Default_Op_Actual_Dates;

/*##################################################################################################*/
--# NAME
--#     PROCEDURE: Get_Op_Actual_Dates
--# PARAMETERS
--# Standard IN Parameters
--#  None
--#
--# Standard OUT Parameters
--#  x_return_status    OUT NOCOPY VARCHAR2
--#
--# Get_Op_Actual_Dates Parameters
--#  P_x_operation_tbl   IN AHL_COMPLETIONS_PVT.operation_tbl_type - Table holding the operation records
--#
--# DESCRIPTION
--#  This function will be used to retrieve the current actual dates of operations. This is API
--#  is needed for the defaulting logic of actual dates on the Operations subtab of the
--#  Update Workorders page. Calling APIs need to populate only the workorder_id and
--#  operation_sequence_num fields of the operations records.
--#
--# HISTORY
--#   16-Jun-2005   rroy  Created
--###################################################################################################*/

PROCEDURE Get_Op_Actual_Dates
(
  x_return_status    OUT NOCOPY VARCHAR2,
  p_x_operation_tbl  IN OUT NOCOPY AHL_COMPLETIONS_PVT.operation_tbl_type
)
IS

-- cursor to retrieve the relevant operation details from AHL_WORKORDER_OPERATIONS table
CURSOR c_get_op_details(x_workorder_id NUMBER,
                        x_operation_seq_num NUMBER)
IS
SELECT ACTUAL_START_DATE,
ACTUAL_END_DATE,
WORKORDER_OPERATION_ID
FROM AHL_WORKORDER_OPERATIONS
WHERE WORKORDER_ID = x_workorder_id
AND OPERATION_SEQUENCE_NUM = x_operation_seq_num;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF p_x_operation_tbl.COUNT > 0 THEN
    FOR i IN p_x_operation_tbl.FIRST..p_x_operation_tbl.LAST LOOP
      OPEN c_get_op_details(p_x_operation_tbl (i).workorder_id, p_x_operation_tbl (i).operation_sequence_num);
      FETCH c_get_op_details INTO p_x_operation_tbl(i).actual_start_date, p_x_operation_tbl(i).actual_end_date, p_x_operation_tbl(i).WORKORDER_OPERATION_ID;
      IF c_get_op_details%NOTFOUND THEN
        CLOSE c_get_op_details;
       	FND_MESSAGE.set_name('AHL', 'AHL_PRD_WO_OP_NOT_FND');
       	FND_MSG_PUB.add;
       	x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
       	--RAISE FND_API.G_RET_STS_ERROR;
      END IF; --IF c_get_op_details%NOTFOUND THEN
      CLOSE c_get_op_details;
    END LOOP;
  END IF; -- IF p_x_operation_tbl.COUNT > 0 THEN

END Get_Op_Actual_Dates;

/*##################################################################################################*/
--# NAME
--#     PROCEDURE: Get_Default_Wo_Actual_Dates
--#
--# PARAMETERS
--# Standard IN Parameters
--#  None
--#
--# Standard OUT Parameters
--#  x_return_status    OUT NOCOPY VARCHAR2
--#
--# Get_Default_Wo_Actual_Dates Parameters
--#  p_workorder_id      IN         NUMBER - The workorder id for which the actual dates are retrieved
--#  x_actual_start_date OUT NOCOPY DATE   - Actual workorder start date
--#  x_actual_end_date   OUT NOCOPY DATE   - Actual workorder end date
--#
--# DESCRIPTION
--# 	This function will be used to default the actual dates before completing workorders using
--#  the My Workorders or Update Workorders Uis. Calling APIs need to ensure that they call
--#  this API after updating the operation actual dates.
--#
--# HISTORY
--#   16-Jun-2005   rroy  Created
--###################################################################################################*/

PROCEDURE Get_Default_Wo_Actual_Dates
(
  x_return_status     OUT NOCOPY VARCHAR2,
  p_workorder_id      IN         NUMBER,
  x_actual_start_date OUT NOCOPY DATE,
  x_actual_end_date   OUT NOCOPY DATE
)
IS

-- cursor to retrieve minimum actual start date and maximum actual
-- end date from all the operations within this workorder
CURSOR c_get_wo_actual_dates(x_workorder_id NUMBER)
IS
SELECT MIN(ACTUAL_START_DATE),
MAX(ACTUAL_END_DATE)
FROM AHL_WORKORDER_OPERATIONS
WHERE WORKORDER_ID = x_workorder_id;

CURSOR c_get_mwo_flag(x_workorder_id NUMBER)
IS
SELECT MASTER_WORKORDER_FLAG
FROM AHL_WORKORDERS
WHERE WORKORDER_ID = x_workorder_id;

BEGIN

  OPEN c_get_wo_actual_dates(p_workorder_id);
  FETCH c_get_wo_actual_dates INTO x_actual_start_date, x_actual_end_date;
  CLOSE c_get_wo_actual_dates;

END Get_Default_Wo_Actual_Dates;

FUNCTION get_ue_mr_status_code(p_unit_effectivity_id IN NUMBER) RETURN VARCHAR2
IS

  CURSOR get_mr_status_ue(c_unit_effectivity_id NUMBER) IS
  SELECT ( CASE
   WHEN UE.STATUS_CODE IN ('ACCOMPLISHED', 'DEFERRED', 'TERMINATED','CANCELLED')
                 THEN UE.STATUS_CODE
   WHEN UE.orig_deferral_ue_id IS NOT NULL
                 THEN ORIG_DEF.approval_status_code
   WHEN DEF.APPROVAL_STATUS_CODE IS NOT NULL
                 THEN DEF.APPROVAL_STATUS_CODE
   ELSE UE.STATUS_CODE
   END)UMP_STATUS_CODE
   FROM AHL_UNIT_DEFERRALS_B ORIG_DEF,AHL_UNIT_DEFERRALS_B
DEF,AHL_UNIT_EFFECTIVITIES_APP_V UE
   WHERE UE.orig_deferral_ue_id = orig_def.unit_effectivity_id(+)
   AND orig_def.unit_deferral_type(+) = 'DEFERRAL'
   AND UE.unit_effectivity_id = def.unit_effectivity_id(+)
   AND def.unit_deferral_type(+) = 'DEFERRAL'
   AND UE.unit_effectivity_id = c_unit_effectivity_id;

   l_mr_status_code VARCHAR2(30);

BEGIN
   l_mr_status_code := NULL;
   OPEN get_mr_status_ue(p_unit_effectivity_id);
   FETCH get_mr_status_ue INTO l_mr_status_code;
   CLOSE get_mr_status_ue;
   RETURN l_mr_status_code;
END get_ue_mr_status_code;

-- Wrapper function to complete the visit master workorder
-- If the visit id is passed, then the visit master workorder id queried and completed
-- If the UE Id is passed, then the UE Master workorder is queried and completed
-- If the workorder id is passed, then the workorder is completed.
-- Bug 4626717 - Issue 6
FUNCTION complete_master_wo
(
 p_visit_id              IN            NUMBER,
 p_workorder_id          IN            NUMBER,
 p_ue_id                 IN            NUMBER
) RETURN VARCHAR2
IS
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);

  l_workorder_tbl         AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_TBL;
  l_workorder_rel_tbl     AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_REL_TBL;
  l_wo_count              NUMBER;

  -- cursor to retrieve the visit master workorder
  CURSOR  get_visit_master_wo(c_visit_id NUMBER )
  IS
  SELECT  workorder_id, object_version_number, wip_entity_id
  FROM AHL_WORKORDERS
  WHERE visit_id = c_visit_id
  AND master_workorder_flag = 'Y'
  --AND status_code NOT IN ('7', '22', '4', '12', '5')
  AND VISIT_TASK_ID IS NULL;

  CURSOR get_ue_master_wo(c_ue_id NUMBER)
  IS
  SELECT WO.workorder_id,
         WO.object_version_number, VTS.task_type_code,
         WO.wip_entity_id
  FROM AHL_WORKORDERS WO,
       AHL_VISIT_TASKS_B VTS
  WHERE WO.visit_task_id = VTS.visit_task_id
        AND VTS.unit_effectivity_id = c_ue_id
        --AND WO.status_code NOT IN ('7', '22', '4', '12', '5')
        AND VTS.task_type_code IN ('SUMMARY', 'UNASSOCIATED');

  CURSOR get_wo_ovn(c_workorder_id NUMBER)
  IS
  SELECT object_version_number, wip_entity_id
  FROM AHL_WORKORDERS
  WHERE workorder_id = c_workorder_id;
  --AND status_code NOT IN ('7', '22', '4', '12', '5');

  -- Fix for FP bug# 5138909 (issue#2).
  -- If all workorders in a visit are cancelled then the Visit Master Workorder
  -- needs to be cancelled instead of being completed.

  -- cursor to check if all workorders in a visit are cancelled.
  CURSOR  chk_cmplt_wo_exists(c_wip_entity_id NUMBER )
  IS
    SELECT 'x'
    FROM AHL_WORKORDERS AWO, WIP_DISCRETE_JOBS WDJ
    WHERE awo.wip_entity_id = wdj.wip_entity_id
       AND wdj.date_completed IS NOT NULL
       --AND master_workorder_flag = 'N'
       --AND status_code NOT IN ('7', '22', '12')
       AND VISIT_TASK_ID IS NOT NULL
       AND awo.wip_entity_id IN (SELECT rel.child_object_id
                                FROM wip_sched_relationships rel
                                START WITH REL.parent_object_id = c_wip_entity_id
                                CONNECT BY REL.parent_object_id = PRIOR REL.child_object_id
                                AND REL.parent_object_type_id = PRIOR REL.child_object_type_id
                                AND REL.relationship_type = 1);

  l_workorder_id NUMBER;
  l_ovn          NUMBER;
  l_api_name     VARCHAR2(30) := 'Complete_Master_Wo';
  l_task_type_code VARCHAR2(30);

  -- added for FP bug# 5138909.
  l_wip_entity_id  NUMBER;
  l_junk           VARCHAR2(1);

BEGIN

  IF ( G_DEBUG = 'Y' ) THEN
     AHL_DEBUG_PUB.debug( 'Start complete_master_wo: Input Params:');
     AHL_DEBUG_PUB.debug( 'In complete_master_wo: p_visit_id:' || p_visit_id);
     AHL_DEBUG_PUB.debug( 'In complete_master_wo: p_ue_id:' || p_ue_id);
     AHL_DEBUG_PUB.debug( 'In complete_master_wo: p_workorder_id:' || p_workorder_id);
  END IF;

  IF(p_visit_id IS NOT NULL) THEN
       OPEN get_visit_master_wo(p_visit_id);
       FETCH get_visit_master_wo INTO l_workorder_id, l_ovn, l_wip_entity_id;
       CLOSE get_visit_master_wo;
  ELSIF(p_ue_id IS NOT NULL) THEN
       OPEN get_ue_master_wo(p_ue_id);
       FETCH get_ue_master_wo INTO l_workorder_id, l_ovn, l_task_type_code, l_wip_entity_id;
       CLOSE get_ue_master_wo;
       IF l_task_type_code = 'UNASSOCIATED' THEN
            RETURN FND_API.G_RET_STS_SUCCESS;
       END IF;
  ELSIF(p_workorder_id IS NOT NULL) THEN
       OPEN get_wo_ovn(p_workorder_id);
       FETCH get_wo_ovn INTO l_ovn, l_wip_entity_id;
       CLOSE get_wo_ovn;
       l_workorder_id := p_workorder_id;
  ELSE
       -- All three input params are null
       -- throw an error
       FND_MESSAGE.set_name('AHL','AHL_PRD_WRONG_ARGUMENTS');
       FND_MESSAGE.set_token('PROC_NAME', l_api_name);
        FND_MSG_PUB.add;
        RETURN FND_API.G_RET_STS_ERROR;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
     AHL_DEBUG_PUB.debug( 'In complete_master_wo: workorder_id:ovn:wip_entity_id:' || l_workorder_id
                           || ':' || l_ovn || ':' || l_wip_entity_id);
  END IF;

  -- Check if all workorders are cancelled.
  OPEN chk_cmplt_wo_exists(l_wip_entity_id);
  FETCH chk_cmplt_wo_exists INTO l_junk;
  IF (chk_cmplt_wo_exists%NOTFOUND) THEN
      IF ( G_DEBUG = 'Y' ) THEN
         AHL_DEBUG_PUB.debug('In complete_master_wo: processing for cancelled mwo');
      END IF;

      CLOSE chk_cmplt_wo_exists;
      -- all jobs cancelled.
      -- cancel master workorder.
      IF (p_visit_id IS NOT NULL) THEN
          AHL_PRD_WORKORDER_PVT.cancel_visit_jobs
           (
             p_api_version         => 1.0,
             p_init_msg_list       => FND_API.G_TRUE,
             p_commit              => FND_API.G_FALSE,
             p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
             p_default             => FND_API.G_FALSE,
             p_module_type         => 'API',
             x_return_status       => l_return_status,
             x_msg_count           => l_msg_count,
             x_msg_data            => l_msg_data,
             p_visit_id            => p_visit_id,
             p_unit_effectivity_id => NULL,
             p_workorder_id        => NULL
           );
      ELSIF (p_ue_id IS NOT NULL) THEN
          AHL_PRD_WORKORDER_PVT.cancel_visit_jobs
           (
             p_api_version         => 1.0,
             p_init_msg_list       => FND_API.G_TRUE,
             p_commit              => FND_API.G_FALSE,
             p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
             p_default             => FND_API.G_FALSE,
             p_module_type         => 'API',
             x_return_status       => l_return_status,
             x_msg_count           => l_msg_count,
             x_msg_data            => l_msg_data,
             p_visit_id            => NULL,
             p_unit_effectivity_id => p_ue_id,
             p_workorder_id        => NULL
           );
      ELSIF (p_workorder_id IS NOT NULL) THEN
          AHL_PRD_WORKORDER_PVT.cancel_visit_jobs
           (
             p_api_version         => 1.0,
             p_init_msg_list       => FND_API.G_TRUE,
             p_commit              => FND_API.G_FALSE,
             p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
             p_default             => FND_API.G_FALSE,
             p_module_type         => 'API',
             x_return_status       => l_return_status,
             x_msg_count           => l_msg_count,
             x_msg_data            => l_msg_data,
             p_visit_id            => NULL,
             p_unit_effectivity_id => NULL,
             p_workorder_id        => p_workorder_id
           );
      END IF;  -- p_visit_id IS NOT NULL

  ELSE -- chk_cmplt_wo_exists
     CLOSE chk_cmplt_wo_exists;

     IF l_workorder_id IS NOT NULL AND l_ovn IS NOT NULL THEN
           AHL_COMPLETIONS_PVT.complete_workorder
           (
                    p_api_version            => 1.0,
                    p_init_msg_list          => FND_API.G_TRUE,
                    p_commit                 => FND_API.G_FALSE,
                    p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
                    p_default                => FND_API.G_FALSE,
                    p_module_type            => NULL,
                    x_return_status          => l_return_status,
                    x_msg_count              => l_msg_count,
                    x_msg_data               => l_msg_data,
                    p_workorder_id           => l_workorder_id,
                    p_object_version_no      => l_ovn
           );

         --RETURN l_return_status;
     ELSE
        FND_MESSAGE.SET_NAME('AHL', 'AHL_PP_WORKORDER_NOT_EXISTS');
        FND_MSG_PUB.ADD;
        --RETURN FND_API.G_RET_STS_ERROR;
        l_return_status := FND_API.G_RET_STS_ERROR;

     END IF; -- l_workorder_id IS NOT NULL ..
  END IF;  -- chk_cmplt_wo_exists%NOTFOUND

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug('End complete_master_wo: l_return_status:' || l_return_status);
  END IF;

  RETURN l_return_status;

END complete_master_wo;

------------------------------------------------------------------------------------------------
-- API added for the concurrent program "Close Work Orders".
-- This API is to be used with Concurrent program.
-- Bug # 6991393 (FP for Bug # 6500568)
------------------------------------------------------------------------------------------------
PROCEDURE Close_WorkOrders (
    errbuf                  OUT NOCOPY  VARCHAR2,
    retcode                 OUT NOCOPY  NUMBER,
    p_api_version           IN          NUMBER
)
IS

l_api_name          VARCHAR2(30) := 'Close_WorkOrders';
l_api_version       NUMBER := 1.0;

CURSOR c_get_eligible_wos
IS
SELECT
   AWO.workorder_id,
   AWO.workorder_name,
   AWO.visit_task_id,
   AWO.master_workorder_flag,
   AWO.object_version_number,
   'Y'  valid_for_close,
   WIPJ.scheduled_start_date,
   WIPJ.scheduled_completion_date,
   AWO.actual_start_date,
   AWO.actual_end_date,
   WIPJ.completion_subinventory,
   WIPJ.completion_locator_id,
   AWO.security_group_id,
   AWO.attribute_category,
   AWO.attribute1,
   AWO.attribute2,
   AWO.attribute3,
   AWO.attribute4,
   AWO.attribute5,
   AWO.attribute6,
   AWO.attribute7,
   AWO.attribute8,
   AWO.attribute9,
   AWO.attribute10,
   AWO.attribute11,
   AWO.attribute12,
   AWO.attribute13,
   AWO.attribute14,
   AWO.attribute15
FROM
   AHL_WORKORDERS AWO,
   WIP_DISCRETE_JOBS WIPJ,
   WIP_ENTITIES WIPE
WHERE
	AWO.status_code in (4,5,7)
   AND  AWO.wip_entity_id = WIPJ.wip_entity_id
   AND  WIPE.entity_type = 7
   AND  WIPE.wip_entity_id = WIPJ.wip_entity_id
   AND  WIPJ.status_type = 12;


CURSOR chk_inst_in_job (p_workorder_id IN NUMBER) IS
SELECT
  'x'
FROM
  CSI_ITEM_INSTANCES CII,
  AHL_WORKORDERS AWO
WHERE
  CII.WIP_JOB_ID = AWO.WIP_ENTITY_ID
  AND AWO.workorder_id = p_workorder_id
  AND ACTIVE_START_DATE <= SYSDATE
  AND ((ACTIVE_END_DATE IS NULL) OR (ACTIVE_END_DATE >= SYSDATE))
  AND LOCATION_TYPE_CODE = 'WIP'
  AND NOT EXISTS (SELECT 'X' FROM CSI_II_RELATIONSHIPS CIR
		 WHERE CIR.SUBJECT_ID = CII.INSTANCE_ID
		   AND CIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
		   AND SYSDATE BETWEEN NVL(ACTIVE_START_DATE,SYSDATE) AND NVL(ACTIVE_END_DATE,SYSDATE));

-- actual work order related table definitions
TYPE workorder_id_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE workorder_name_tbl_type IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
TYPE visit_task_id_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE master_workorder_flag_tbl_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
TYPE object_version_number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE valid_for_close_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

l_workorder_id_tbl workorder_id_tbl_type;
l_workorder_name_tbl workorder_name_tbl_type;
l_visit_task_id_tbl visit_task_id_tbl_type;
l_master_workorder_flag_tbl master_workorder_flag_tbl_type;
l_object_version_number_tbl object_version_number_tbl_type;
l_valid_for_close_tbl valid_for_close_type;
-- actual work order related table definitions

-- Txn related table definitions
TYPE l_wo_sch_str_tbl_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE l_wo_sch_end_tbl_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE l_wo_act_str_tbl_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE l_wo_act_end_tbl_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE l_wo_comp_subinv_tbl_type IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
TYPE l_wo_comp_loc_id_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE l_wo_sc_grp_id_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE l_wo_att_category_tbl_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE l_wo_att_1_tbl_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE l_wo_att_2_tbl_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE l_wo_att_3_tbl_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE l_wo_att_4_tbl_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE l_wo_att_5_tbl_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE l_wo_att_6_tbl_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE l_wo_att_7_tbl_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE l_wo_att_8_tbl_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE l_wo_att_9_tbl_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE l_wo_att_10_tbl_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE l_wo_att_11_tbl_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE l_wo_att_12_tbl_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE l_wo_att_13_tbl_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE l_wo_att_14_tbl_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE l_wo_att_15_tbl_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;

l_wo_sch_str_tbl l_wo_sch_str_tbl_type;
l_wo_sch_end_tbl l_wo_sch_end_tbl_type;
l_wo_act_str_tbl l_wo_act_str_tbl_type;
l_wo_act_end_tbl l_wo_act_end_tbl_type;
l_wo_comp_subinv_tbl l_wo_comp_subinv_tbl_type;
l_wo_comp_loc_id_tbl l_wo_comp_loc_id_tbl_type;
l_wo_sc_grp_id_tbl l_wo_sc_grp_id_tbl_type;
l_wo_att_category_tbl l_wo_att_category_tbl_type;
l_wo_att_1_tbl l_wo_att_1_tbl_type;
l_wo_att_2_tbl l_wo_att_2_tbl_type;
l_wo_att_3_tbl l_wo_att_3_tbl_type;
l_wo_att_4_tbl l_wo_att_4_tbl_type;
l_wo_att_5_tbl l_wo_att_5_tbl_type;
l_wo_att_6_tbl l_wo_att_6_tbl_type;
l_wo_att_7_tbl l_wo_att_7_tbl_type;
l_wo_att_8_tbl l_wo_att_8_tbl_type;
l_wo_att_9_tbl l_wo_att_9_tbl_type;
l_wo_att_10_tbl l_wo_att_10_tbl_type;
l_wo_att_11_tbl l_wo_att_11_tbl_type;
l_wo_att_12_tbl l_wo_att_12_tbl_type;
l_wo_att_13_tbl l_wo_att_13_tbl_type;
l_wo_att_14_tbl l_wo_att_14_tbl_type;
l_wo_att_15_tbl l_wo_att_15_tbl_type;
-- Txn related table definitions


l_junk                  VARCHAR2(1);
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_err_msg               VARCHAR2(2000);
l_buffer_limit          NUMBER   := 1000;
l_index                 NUMBER;

BEGIN

    -- Initialize error message stack by default
    FND_MSG_PUB.Initialize;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
        retcode := 2;
        errbuf := FND_MSG_PUB.Get;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- perform validations -- start

    fnd_file.put_line(fnd_file.log, 'At the begining of the process...');

    OPEN c_get_eligible_wos;

    --FOR l_eligible_wos IN c_get_eligible_wos
    LOOP

       SAVEPOINT close_workorders_pvt;

       FETCH c_get_eligible_wos BULK COLLECT INTO l_workorder_id_tbl,
                                                  l_workorder_name_tbl,
                                                  l_visit_task_id_tbl,
                                                  l_master_workorder_flag_tbl,
                                                  l_object_version_number_tbl,
                                                  l_valid_for_close_tbl,
                                                  l_wo_sch_str_tbl,
						  l_wo_sch_end_tbl,
						  l_wo_act_str_tbl,
						  l_wo_act_end_tbl,
						  l_wo_comp_subinv_tbl,
						  l_wo_comp_loc_id_tbl,
						  l_wo_sc_grp_id_tbl,
						  l_wo_att_category_tbl,
						  l_wo_att_1_tbl,
						  l_wo_att_2_tbl,
						  l_wo_att_3_tbl,
						  l_wo_att_4_tbl,
						  l_wo_att_5_tbl,
						  l_wo_att_6_tbl,
						  l_wo_att_7_tbl,
						  l_wo_att_8_tbl,
						  l_wo_att_9_tbl,
						  l_wo_att_10_tbl,
						  l_wo_att_11_tbl,
						  l_wo_att_12_tbl,
						  l_wo_att_13_tbl,
						  l_wo_att_14_tbl,
						  l_wo_att_15_tbl
       LIMIT l_buffer_limit;

       IF l_workorder_id_tbl.COUNT <= 0
       THEN

          CLOSE c_get_eligible_wos;
          EXIT;

       END IF;

       fnd_file.put_line(fnd_file.log, 'Total Work Orders selected for processing -> '||l_workorder_id_tbl.COUNT);

       FOR l_index IN l_workorder_id_tbl.FIRST .. l_workorder_id_tbl.LAST
       LOOP
		-- 1. validate if the Work Order Unit is locked.
		--    If the Unit is locked we cant close the workorder. Skip the Work Order. Log the message and continue
		l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(
								    p_workorder_id     => l_workorder_id_tbl(l_index),
								    p_ue_id            => NULL,
								    p_visit_id         => NULL,
								    p_item_instance_id => NULL
								  );


		IF l_return_status = FND_API.G_TRUE THEN

				FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_LGN_UNTLCKD');
				FND_MESSAGE.set_token('WO_NUM', l_workorder_name_tbl(l_index));
				FND_MSG_PUB.ADD;

				l_valid_for_close_tbl(l_index) := 'N';

				-- log a warning
				fnd_file.put_line(fnd_file.log, 'Work Order -> '||l_workorder_name_tbl(l_index)||' is not closed due to following error(s)');
				fnd_file.put_line(fnd_file.log, FND_MSG_PUB.GET(p_encoded  => FND_API.G_FALSE));
				FND_MSG_PUB.Delete_Msg;

		END IF;



		IF
		  l_valid_for_close_tbl(l_index) IS NULL OR
		  l_valid_for_close_tbl(l_index) <> 'N'
		THEN
			-- 2. Validate if the there are any work order materials.
			--    If so log a message and continue. No need to skip the Work Order
			OPEN chk_inst_in_job(l_workorder_id_tbl(l_index));
			FETCH chk_inst_in_job INTO l_junk;
			CLOSE chk_inst_in_job;

			IF l_junk IS NOT NULL
			THEN
			        -- No need to skip the Work Order but just log a message.
				fnd_file.put_line(fnd_file.log, 'Work Order -> '||l_workorder_name_tbl(l_index)||' is processed but with following warning(s)...');
				fnd_file.put_line(fnd_file.log, 'Work Order '||l_workorder_name_tbl(l_index)||' has material');

			END IF;

			-- 3. Update the status of all materials of the Work Order to History before closing them.
			-- Call LTP API to update material requirement status to History.
			IF l_master_workorder_flag_tbl(l_index) = 'N'
			THEN

				AHL_LTP_REQST_MATRL_PVT.Update_Material_Reqrs_status(
					   p_api_version      => 1.0,
					   p_init_msg_list    => FND_API.G_TRUE,
					   p_commit           => FND_API.G_FALSE,
					   p_validation_level => FND_API.G_VALID_LEVEL_FULL,
					   p_module_type      => NULL,
					   p_visit_task_id    => l_visit_task_id_tbl(l_index),
					   x_return_status    => l_return_status,
					   x_msg_count        => l_msg_count,
					   x_msg_data         => l_msg_data
				 );

				 IF l_return_status <> FND_API.G_RET_STS_SUCCESS
				 THEN
				    l_valid_for_close_tbl(l_index) := 'N';
				    -- log a warning
				    fnd_file.put_line(fnd_file.log, 'Work Order -> '||l_workorder_name_tbl(l_index)||' is not closed due to following error(s)');
				    fnd_file.put_line(fnd_file.log, '---------------------------------------------------------------------------------');

				    LOOP
				       l_err_msg := FND_MSG_PUB.GET;
				       IF l_err_msg IS NULL
				       THEN
					 EXIT;
				       END IF;
				       fnd_file.put_line(fnd_file.log, l_err_msg);
				    END LOOP;

				 END IF;

			 END IF; --l_master_workorder_flag_tbl(l_index) = 'N'

		END IF; -- l_valid_for_close_tbl(l_index) <> 'N'

	    END LOOP; -- l_workorder_id_tbl loop

	    -- Update Eligigble Work Orders
	    BEGIN

		 FORALL l_count IN l_workorder_id_tbl.FIRST .. l_workorder_id_tbl.LAST
                    SAVE EXCEPTIONS
		    UPDATE
		      AHL_WORKORDERS
		    SET
		      status_code = 12,
		      last_update_date = sysdate,
		      last_updated_by = fnd_global.user_id,
		      last_update_login = fnd_global.login_id,
		      object_version_number = object_version_number + 1
		    WHERE
		      workorder_id = l_workorder_id_tbl(l_count)
		      AND object_version_number = l_object_version_number_tbl(l_count)
		      AND l_valid_for_close_tbl(l_count) = 'Y';

	    EXCEPTION

		   WHEN OTHERS THEN

		        fnd_file.put_line(fnd_file.log, 'Following error(s) occured while closing Work Orders..');

                        FOR j IN 1..sql%bulk_exceptions.count
                        LOOP
			    fnd_file.put_line(fnd_file.log,
			    sql%bulk_exceptions(j).error_index || ', ' ||
			    Sqlerrm(-sql%bulk_exceptions(j).error_code) );
                        END LOOP;

			FND_MESSAGE.set_name('AHL', 'AHL_PRD_WO_CANNOT_CLOSE');
			FND_MSG_PUB.add;
			errbuf := FND_MSG_PUB.Get;

			retcode := 2; -- error!!

			ROLLBACK TO close_workorders_pvt;

			RETURN;
	    END;

	    -- Log the transaction. - start
	    -- Work Order transaction logging is done in 2 steps.
	    -- This is to take advantage of batch processing to reduce the overhead.

	    BEGIN

	           -- Step 1. Log all the Work Orders collected.

		    FORALL l_txn_count IN l_workorder_id_tbl.FIRST .. l_workorder_id_tbl.LAST
                    SAVE EXCEPTIONS

			    INSERT INTO AHL_WORKORDER_TXNS
			    (
			      WORKORDER_TXN_ID,
			      OBJECT_VERSION_NUMBER,
			      LAST_UPDATE_DATE,
			      LAST_UPDATED_BY,
			      CREATION_DATE,
			      CREATED_BY,
			      LAST_UPDATE_LOGIN,
			      WORKORDER_ID,
			      TRANSACTION_TYPE_CODE,
			      STATUS_CODE,
			      SCHEDULED_START_DATE,
			      SCHEDULED_END_DATE,
			      ACTUAL_START_DATE,
			      ACTUAL_END_DATE,
			      LOT_NUMBER,
			      COMPLETION_SUBINVENTORY,
			      COMPLETION_LOCATOR_ID,
			      SECURITY_GROUP_ID,
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
			    ) VALUES
			    (
			      AHL_WORKORDER_TXNS_S.NEXTVAL,
			      l_object_version_number_tbl(l_txn_count) + 1,
			      sysdate,
			      fnd_global.user_id,
			      sysdate,
			      fnd_global.user_id,
			      fnd_global.login_id,
			      l_workorder_id_tbl(l_txn_count),
			      0,
			      12, -- this is close workorder. On successful update the Workorder will be in status 12.
			      l_wo_sch_str_tbl(l_txn_count),
			      l_wo_sch_end_tbl(l_txn_count),
			      l_wo_act_str_tbl(l_txn_count),
			      l_wo_act_end_tbl(l_txn_count),
			      NULL,
			      l_wo_comp_subinv_tbl(l_txn_count),
			      l_wo_comp_loc_id_tbl(l_txn_count),
			      l_wo_sc_grp_id_tbl(l_txn_count),
			      l_wo_att_category_tbl(l_txn_count),
			      l_wo_att_1_tbl(l_txn_count),
			      l_wo_att_2_tbl(l_txn_count),
			      l_wo_att_3_tbl(l_txn_count),
			      l_wo_att_4_tbl(l_txn_count),
			      l_wo_att_5_tbl(l_txn_count),
			      l_wo_att_6_tbl(l_txn_count),
			      l_wo_att_7_tbl(l_txn_count),
			      l_wo_att_8_tbl(l_txn_count),
			      l_wo_att_9_tbl(l_txn_count),
			      l_wo_att_10_tbl(l_txn_count),
			      l_wo_att_11_tbl(l_txn_count),
			      l_wo_att_12_tbl(l_txn_count),
			      l_wo_att_13_tbl(l_txn_count),
			      l_wo_att_14_tbl(l_txn_count),
			      l_wo_att_15_tbl(l_txn_count)
			     );

                    -- Step 2. Delete those Work Orders which are not actually updated to closed status

		    FORALL l_txn_del_count IN l_workorder_id_tbl.FIRST .. l_workorder_id_tbl.LAST
                    SAVE EXCEPTIONS

			    DELETE
				 ahl_workorder_txns WOTXNO
			    WHERE
				wotxno.workorder_txn_id = (
						    select
						      MAX(wotxn.workorder_txn_id)
						    from
						      AHL_WORKORDER_TXNS WOTXN
						    WHERE
						      wotxn.workorder_id = l_workorder_id_tbl(l_txn_del_count)
						      AND l_valid_for_close_tbl(l_txn_del_count) = 'N'
						   );
	    EXCEPTION

		   WHEN OTHERS THEN

		        fnd_file.put_line(fnd_file.log, 'Following error(s) occured while closing Work Orders..');

                        FOR j IN 1..sql%bulk_exceptions.count
                        LOOP
			    fnd_file.put_line(fnd_file.log,
			    sql%bulk_exceptions(j).error_index || ', ' ||
			    Sqlerrm(-sql%bulk_exceptions(j).error_code) );
                        END LOOP;

			FND_MESSAGE.set_name('AHL', 'AHL_PRD_WO_CANNOT_CLOSE');
			FND_MSG_PUB.add;
			errbuf := FND_MSG_PUB.Get;

			retcode := 2; -- error!!

			ROLLBACK TO close_workorders_pvt;

			RETURN;
	    END;

	    COMMIT;

    END LOOP; -- blind for loop
    -- perform validations -- end

    retcode := 0;  -- success, since nothing is wrong

    fnd_file.put_line(fnd_file.log, 'End of processing the close Work Orders..');

END Close_WorkOrders;

--for fix of bug number 6467963
PROCEDURE get_mr_details_rec
(
  p_unit_effectivity_id     IN         NUMBER,
  p_object_version_number   IN         NUMBER,
  x_mr_rec                  OUT NOCOPY mr_rec_type
) IS

l_mr_rec mr_rec_type;

CURSOR get_mr_details_csr(p_unit_effectivity_id NUMBER, p_ue_object_version_no NUMBER)
   IS SELECT
   UE.unit_effectivity_id,
   UE.object_version_number,
   UE.csi_item_instance_id,
   UE.mr_header_id,
   UE.cs_incident_id,
   --FL.Lookup_code,
   --FL.Meaning,
   UE.qa_collection_id
   from ahl_unit_effectivities_b UE--, FND_LOOKUP_VALUES_VL FL
   where --FL.Lookup_type = 'AHL_PRD_MR_STATUS'
   --AND FL.Lookup_code = AHL_COMPLETIONS_PVT.get_mr_status( p_unit_effectivity_id ) AND
   UE.unit_effectivity_id = p_unit_effectivity_id
   AND UE.object_version_number = p_ue_object_version_no;

   CURSOR get_mr_status_csr(p_status_code VARCHAR2) IS
   Select FL.Meaning FROM FND_LOOKUP_VALUES_VL FL
   Where FL.Lookup_type = 'AHL_PRD_MR_STATUS'
   AND FL.Lookup_code = p_status_code;

   CURSOR fmp_mr_csr (p_mr_header_id IN NUMBER )
   IS select title, QA_INSPECTION_TYPE from AHL_MR_HEADERS_B MR where MR.mr_header_id = p_mr_header_id;

   CURSOR sr_csr (p_cs_incident_id IN NUMBER )
   IS select cit.name || '-' || cs.incident_number
   from cs_incidents_all_vl cs, cs_incident_types_vl cit
   WHERE cs.incident_type_id = cit.incident_type_id
   AND cs.incident_id = p_cs_incident_id;

   CURSOR visit_task_csr(p_unit_effectivity_id IN NUMBER)IS
   SELECT VST.ORGANIZATION_ID,VT.visit_task_id
   FROM  AHL_VISIT_TASKS_B VT, AHL_VISITS_B VST
   WHERE VT.TASK_TYPE_CODE IN ( 'SUMMARY' ,  'UNASSOCIATED' )
   AND VST.VISIT_ID = VT.VISIT_ID
   AND VT.UNIT_EFFECTIVITY_ID =  p_unit_effectivity_id;

   l_organization_id NUMBER;
   l_visit_task_id NUMBER;

   CURSOR act_end_dt_csr(p_visit_task_id IN NUMBER) IS
   SELECT wo.actual_end_date FROM ahl_workorders WO
   WHERE WO.visit_task_id = p_visit_task_id
   AND master_workorder_flag = 'Y';

   CURSOR get_qa_plan_id_csr1(p_collection_id IN NUMBER)IS
   SELECT qa.plan_id from qa_results qa
   where qa.collection_id = p_collection_id and rownum < 2;

   CURSOR get_qa_plan_id_csr2(p_org_id IN NUMBER, p_qa_inspection_type IN VARCHAR2)IS
   SELECT QP.plan_id FROM QA_PLANS_VAL_V QP, QA_PLAN_TRANSACTIONS QPT, QA_PLAN_COLLECTION_TRIGGERS QPCT
   WHERE QP.plan_id = QPT.plan_id AND QPT.plan_transaction_id = QPCT.plan_transaction_id
   AND QP.organization_id = p_org_id
   AND QPT.transaction_number in (9999,2001)
   AND QPCT.collection_trigger_id = 87
   AND QPCT.low_value = p_qa_inspection_type
   group by qp.plan_id, qpt.transaction_number having transaction_number = MAX(transaction_number);

BEGIN

   OPEN get_mr_details_csr(p_unit_effectivity_id,p_object_version_number);
   FETCH get_mr_details_csr INTO
     l_mr_rec.unit_effectivity_id,
     l_mr_rec.ue_object_version_no,
     l_mr_rec.item_instance_id,
     l_mr_rec.mr_header_id,
     l_mr_rec.incident_id,
     l_mr_rec.qa_collection_id;
   CLOSE get_mr_details_csr;

   OPEN visit_task_csr(l_mr_rec.unit_effectivity_id);
   FETCH visit_task_csr INTO l_organization_id, l_visit_task_id;
   CLOSE visit_task_csr;

   l_mr_rec.ue_status_code := AHL_COMPLETIONS_PVT.get_mr_status( p_unit_effectivity_id );

   OPEN get_mr_status_csr(l_mr_rec.ue_status_code);
   FETCH get_mr_status_csr INTO l_mr_rec.ue_status;
   CLOSE get_mr_status_csr;

   IF(l_mr_rec.ue_status_code IN('ACCOMPLISHED', 'ALL_JOBS_COMPLETE','ALL_JOBS_CLOSED')) THEN
     OPEN act_end_dt_csr(l_visit_task_id);
     FETCH act_end_dt_csr INTO l_mr_rec.actual_end_date;
     CLOSE act_end_dt_csr;
   ELSE
       l_mr_rec.actual_end_date := NULL;
   END IF;

   IF(l_mr_rec.mr_header_id IS NOT NULL)THEN
     OPEN fmp_mr_csr(l_mr_rec.mr_header_id);
     FETCH fmp_mr_csr INTO l_mr_rec.mr_title,l_mr_rec.qa_inspection_type;
     CLOSE fmp_mr_csr;
   ELSIF (l_mr_rec.incident_id IS NOT NULL)THEN
     OPEN sr_csr(l_mr_rec.incident_id);
     FETCH sr_csr INTO l_mr_rec.mr_title;
     CLOSE sr_csr;
   END IF;


   IF(l_mr_rec.qa_inspection_type IS NULL)THEN
      l_mr_rec.qa_plan_id := NULL;
   ELSIF(l_mr_rec.qa_collection_id IS NOT NULL)THEN
      OPEN get_qa_plan_id_csr1(l_mr_rec.qa_collection_id);
      FETCH get_qa_plan_id_csr1 INTO l_mr_rec.qa_plan_id;
      CLOSE get_qa_plan_id_csr1;
   ELSE
      OPEN get_qa_plan_id_csr2(l_organization_id,l_mr_rec.qa_inspection_type);
      FETCH get_qa_plan_id_csr2 INTO l_mr_rec.qa_plan_id;
      CLOSE get_qa_plan_id_csr2;
   END IF;

   x_mr_rec := l_mr_rec;

END get_mr_details_rec;

-- added for FP ER# 6435803
-- Function to test whether all operations for a WO are complete
FUNCTION are_all_operations_complete
(
  p_workorder_id    IN NUMBER
) RETURN VARCHAR2 IS

l_all_operations_complete VARCHAR2(1);


CURSOR all_operations_comp_csr(p_workorder_id    IN NUMBER, p_status_code IN
VARCHAR2) IS
SELECT 'x' from ahl_workorder_operations
WHERE status_code = p_status_code
AND workorder_id = p_workorder_id
AND rownum < 2;
l_junk VARCHAR2(1);

BEGIN
  l_all_operations_complete := 'N';
  OPEN all_operations_comp_csr(p_workorder_id,G_OP_STATUS_UNCOMPLETE);
  FETCH all_operations_comp_csr INTO l_junk;
  IF(all_operations_comp_csr%NOTFOUND)THEN
    l_all_operations_complete := 'Y';
  END IF;
  CLOSE all_operations_comp_csr;
  RETURN l_all_operations_complete;

END are_all_operations_complete;


END AHL_COMPLETIONS_PVT;

/
