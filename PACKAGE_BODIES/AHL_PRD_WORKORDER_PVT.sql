--------------------------------------------------------
--  DDL for Package Body AHL_PRD_WORKORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_WORKORDER_PVT" AS
 /* $Header: AHLVPRJB.pls 120.32.12010000.17 2010/04/13 07:04:36 apattark ship $ */

G_PKG_NAME   VARCHAR2(30)  := 'AHL_PRD_WORKORDER_PVT';
G_DEBUG      VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;

-- Operation Statuses
G_OP_STATUS_UNCOMPLETE VARCHAR2(2) := '2'; --Uncomplete
G_OP_STATUS_COMPLETE   VARCHAR2(2) := '1'; --Complete

-- Job Statuses
G_JOB_STATUS_UNRELEASED VARCHAR2(2) := '1'; --Unreleased
G_JOB_STATUS_RELEASED VARCHAR2(2) := '3'; --Released
G_JOB_STATUS_COMPLETE VARCHAR2(2) := '4'; --Complete
G_JOB_STATUS_COMPLETE_NC VARCHAR2(2) := '5'; --Complete No Charges
G_JOB_STATUS_ON_HOLD VARCHAR2(2) := '6'; --On Hold
G_JOB_STATUS_CANCELLED VARCHAR2(2) := '7'; --Cancelled
G_JOB_STATUS_CLOSED VARCHAR2(2) := '12'; --Closed
G_JOB_STATUS_DRAFT VARCHAR2(2) := '17'; --Draft
G_JOB_STATUS_PARTS_HOLD VARCHAR2(2) := '19'; --Parts Hold
G_JOB_STATUS_QA_PENDING VARCHAR2(2) := '20'; --Pending QA Approval
G_JOB_STATUS_DEFERRAL_PENDING VARCHAR2(2) := '21'; --Pending Deferr
G_JOB_STATUS_DELETED VARCHAR2(2) := '22'; --Deleted

-- MR Statuses
G_MR_STATUS_SIGNED_OFF VARCHAR2(30) := 'ACCOMPLISHED'; --Signed Off
G_MR_STATUS_DEFERRED VARCHAR2(30) := 'DEFERRED'; --Deferred
G_MR_STATUS_DEFERRAL_PENDING VARCHAR2(30) := 'DEFERRAL_PENDING'; --Deferral Pending
G_MR_STATUS_TERMINATED VARCHAR2(30) := 'TERMINATED'; --Terminated
G_MR_STATUS_CANCELLED VARCHAR2(30) := 'CANCELLED'; --Cancelled
G_MR_STATUS_JOBS_CANCELLED VARCHAR2(30) := 'ALL_JOBS_CANCELLED'; --All Jobs Cancelled
G_CALLED_FROM VARCHAR2(30) := NULL; --When Called from VWP For Department Change

-- Fix for Bug # 8329755 (FP for Bug # 7697909) -- start
-- Constants added for performance improvement
G_LEVEL_STATEMENT CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_CURRENT_LOG_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
-- Fix for Bug # 8329755 (FP for Bug # 7697909) -- end

FUNCTION get_date_and_time(p_date IN DATE,
                           p_date_hh24 IN VARCHAR2,
                           p_date_mi IN VARCHAR2,
                           p_date_ss IN VARCHAR2) RETURN DATE;

-- added to fix bug# 9130108/9075539
PROCEDURE cancel_visit_validate
(
 p_visit_id            IN  NUMBER,
 p_visit_number        IN  NUMBER,
 x_cancel_flag         OUT NOCOPY VARCHAR2
);

PROCEDURE log_path(
  x_output_dir      OUT NOCOPY VARCHAR2

	  )
	IS
		        l_full_path     VARCHAR2(512);
			l_new_full_path         VARCHAR2(512);
			l_file_dir      VARCHAR2(512);

			fileHandler     UTL_FILE.FILE_TYPE;
			fileName        VARCHAR2(50);

			l_flag          NUMBER;
	BEGIN
	           fileName:='test.log';--this is only a dummy filename to check if directory is valid or not


        	   /* get output directory path from database */
			SELECT value
			INTO   l_full_path
			FROM   v$parameter
			WHERE  name = 'utl_file_dir';

			l_flag := 0;
			--l_full_path contains a list of comma-separated directories
			WHILE(TRUE)
			LOOP
					    --get the first dir in the list
					    SELECT trim(substr(l_full_path, 1, decode(instr(l_full_path,',')-1,
											  -1, length(l_full_path),
											  instr(l_full_path, ',')-1
											 )
								  )
							   )
					    INTO  l_file_dir
					    FROM  dual;

					    -- check if the dir is valid
					    BEGIN
						    fileHandler := UTL_FILE.FOPEN(l_file_dir , filename, 'w');
						    l_flag := 1;
					    EXCEPTION
						    WHEN utl_file.invalid_path THEN
							l_flag := 0;
						    WHEN utl_file.invalid_operation THEN
							l_flag := 0;
					    END;

					    IF l_flag = 1 THEN --got a valid directory
						utl_file.fclose(fileHandler);
						EXIT;
					    END IF;

					    --earlier found dir was not a valid dir,
					    --so remove that from the list, and get the new list
					    l_new_full_path := trim(substr(l_full_path, instr(l_full_path, ',')+1, length(l_full_path)));

					    --if the new list has not changed, there are no more valid dirs left
					    IF l_full_path = l_new_full_path THEN
						    l_flag:=0;
						    EXIT;
					    END IF;
					     l_full_path := l_new_full_path;
			 END LOOP;


			 IF(l_flag=1) THEN --found a valid directory
			     x_output_dir := l_file_dir;

			  ELSE
			      x_output_dir:= null;

			  END IF;
         EXCEPTION
              WHEN OTHERS THEN
                  x_output_dir := null;

	END log_path;
PROCEDURE set_eam_debug_params
(
  x_debug           OUT NOCOPY VARCHAR2,
  x_output_dir      OUT NOCOPY VARCHAR2,
  x_debug_file_name OUT NOCOPY VARCHAR2,
  x_debug_file_mode OUT NOCOPY VARCHAR2
)
AS
l_output_dir  VARCHAR2(512);

BEGIN
  x_debug := 'Y';

--  SELECT trim(substr(VALUE, 1, DECODE( instr( VALUE, ','), 0, length( VALUE), instr( VALUE, ',') -1 ) ) )
--  INTO   x_output_dir
--  FROM   V$PARAMETER
--  WHERE  NAME = 'utl_file_dir';
  --Call log path
 log_path( x_output_dir => l_output_dir);
  --
  x_output_dir := l_output_dir;
  x_debug_file_name := 'EAMDEBUG.log';
  x_debug_file_mode := 'a';

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( 'Debug Log Directory Path:'||x_output_dir );
    AHL_DEBUG_PUB.debug( 'Debug Log File Name:'||x_debug_file_name );
  END IF;

END set_eam_debug_params;
-- End of Modification
PROCEDURE default_missing_attributes
(
  p_x_prd_workorder_rec   IN OUT NOCOPY prd_workorder_rec
)
As

CURSOR get_workorder_rec(c_workorder_id NUMBER)
is
SELECT *
FROM   AHL_ALL_WORKORDERS_V
WHERE  workorder_id=c_workorder_id;

l_prd_workorder_rec   AHL_ALL_WORKORDERS_V%ROWTYPE;

-- added for bug# 8311856
-- In the case the Visit does not have a unit, it is always not guaranteed that the
-- inventory item id and instance id will be derived from the same task id.
-- So adding the inventory item Id derivation here based on instance id.
CURSOR get_inv_item_id (p_instance_id IN NUMBER) IS
SELECT inventory_item_id, serial_number
FROM csi_item_instances csi
WHERE csi.instance_id = p_instance_id;

BEGIN

  p_x_prd_workorder_rec.DML_OPERATION := 'U';

  OPEN  get_workorder_rec(p_x_prd_workorder_rec.workorder_id);
  FETCH get_workorder_rec INTO l_prd_workorder_rec;
  IF get_workorder_rec%NOTFOUND THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WO_NOT_FOUND');
    FND_MSG_PUB.ADD;
    CLOSE get_workorder_rec;
    RETURN;
  END IF;
  CLOSE get_workorder_rec;

  -- added to fix bug# 8311856
  -- for Visit MWO, derive inventory item and serial number from instance_id.
  IF (l_prd_workorder_rec.VISIT_TASK_ID IS NULL AND l_prd_workorder_rec.inventory_item_id IS NULL) THEN
    OPEN get_inv_item_id(l_prd_workorder_rec.ITEM_INSTANCE_ID);
    FETCH get_inv_item_id INTO l_prd_workorder_rec.inventory_item_id, l_prd_workorder_rec.serial_number;
    CLOSE get_inv_item_id;

    IF (G_DEBUG = 'Y') THEN
      AHL_DEBUG_PUB.debug('Update Workorder: Defaulting Inv Item ID for Visit MWO:' || l_prd_workorder_rec.inventory_item_id);
      AHL_DEBUG_PUB.debug('Update Workorder: Defaulting Serial Num for Visit MWO:' || l_prd_workorder_rec.serial_number);
    END IF;
  END IF;

  IF G_CALLED_FROM = 'API' THEN
      p_x_prd_workorder_rec.WIP_ENTITY_ID:=l_prd_workorder_rec.WIP_ENTITY_ID;
      p_x_prd_workorder_rec.JOB_NUMBER:=l_prd_workorder_rec.JOB_NUMBER;
      p_x_prd_workorder_rec.JOB_DESCRIPTION:=l_prd_workorder_rec.JOB_DESCRIPTION;

    ELSE

    IF p_x_prd_workorder_rec.WIP_ENTITY_ID= FND_API.G_MISS_NUM THEN
      p_x_prd_workorder_rec.WIP_ENTITY_ID:=NULL;
    ELSIF p_x_prd_workorder_rec.WIP_ENTITY_ID IS NULL THEN
      p_x_prd_workorder_rec.WIP_ENTITY_ID:=l_prd_workorder_rec.WIP_ENTITY_ID;
    END IF;

    IF p_x_prd_workorder_rec.JOB_NUMBER= FND_API.G_MISS_CHAR THEN
      p_x_prd_workorder_rec.JOB_NUMBER:=NULL;
    ELSIF p_x_prd_workorder_rec.JOB_NUMBER IS NULL THEN
      p_x_prd_workorder_rec.JOB_NUMBER:=l_prd_workorder_rec.JOB_NUMBER;
    END IF;

    IF p_x_prd_workorder_rec.JOB_DESCRIPTION= FND_API.G_MISS_CHAR THEN
      p_x_prd_workorder_rec.JOB_DESCRIPTION:=NULL;
    ELSIF p_x_prd_workorder_rec.JOB_DESCRIPTION IS NULL THEN
      p_x_prd_workorder_rec.JOB_DESCRIPTION:=l_prd_workorder_rec.JOB_DESCRIPTION;
    END IF;
    END IF; --G_Called_from


  IF p_x_prd_workorder_rec.OBJECT_VERSION_NUMBER= FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.OBJECT_VERSION_NUMBER:=NULL;
  ELSIF p_x_prd_workorder_rec.OBJECT_VERSION_NUMBER IS NULL THEN
    p_x_prd_workorder_rec.OBJECT_VERSION_NUMBER:=l_prd_workorder_rec.OBJECT_VERSION_NUMBER;
  END IF;


  IF p_x_prd_workorder_rec.ORGANIZATION_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.ORGANIZATION_ID:=NULL;
  ELSIF p_x_prd_workorder_rec.ORGANIZATION_ID IS NULL THEN
    p_x_prd_workorder_rec.ORGANIZATION_ID:=l_prd_workorder_rec.ORGANIZATION_ID;
  END IF;



  IF p_x_prd_workorder_rec.ORGANIZATION_NAME= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.ORGANIZATION_NAME:=NULL;
  ELSIF p_x_prd_workorder_rec.ORGANIZATION_NAME IS NULL THEN
    p_x_prd_workorder_rec.ORGANIZATION_NAME:=l_prd_workorder_rec.ORGANIZATION_NAME;
  END IF;

  IF p_x_prd_workorder_rec.FIRM_PLANNED_FLAG= FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.FIRM_PLANNED_FLAG:=NULL;
  ELSIF p_x_prd_workorder_rec.FIRM_PLANNED_FLAG IS NULL THEN
    p_x_prd_workorder_rec.FIRM_PLANNED_FLAG:=l_prd_workorder_rec.FIRM_PLANNED_FLAG;
  END IF;

  IF p_x_prd_workorder_rec.CLASS_CODE= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.CLASS_CODE:=NULL;
  ELSIF p_x_prd_workorder_rec.CLASS_CODE IS NULL THEN
    p_x_prd_workorder_rec.CLASS_CODE:=l_prd_workorder_rec.CLASS_CODE;
  END IF;

  IF G_CALLED_FROM = 'API' THEN

    IF p_x_prd_workorder_rec.DEPARTMENT_ID= FND_API.G_MISS_NUM THEN
      p_x_prd_workorder_rec.DEPARTMENT_ID:=NULL;
    ELSIF p_x_prd_workorder_rec.DEPARTMENT_ID IS NULL THEN
      p_x_prd_workorder_rec.DEPARTMENT_ID:=l_prd_workorder_rec.DEPARTMENT_ID;
    END IF;

    ELSE

    IF p_x_prd_workorder_rec.DEPARTMENT_NAME= FND_API.G_MISS_CHAR THEN
      p_x_prd_workorder_rec.DEPARTMENT_NAME:=NULL;
    ELSIF p_x_prd_workorder_rec.DEPARTMENT_NAME IS NULL THEN
      p_x_prd_workorder_rec.DEPARTMENT_NAME:=l_prd_workorder_rec.DEPARTMENT_NAME;
    END IF;

    IF p_x_prd_workorder_rec.DEPARTMENT_ID= FND_API.G_MISS_NUM THEN
      p_x_prd_workorder_rec.DEPARTMENT_ID:=NULL;
    ELSIF p_x_prd_workorder_rec.DEPARTMENT_ID IS NULL THEN
      p_x_prd_workorder_rec.DEPARTMENT_ID:=l_prd_workorder_rec.DEPARTMENT_ID;
    END IF;

    END IF;

  IF p_x_prd_workorder_rec.STATUS_CODE= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.STATUS_CODE:=NULL;
  ELSIF p_x_prd_workorder_rec.STATUS_CODE IS NULL THEN
    p_x_prd_workorder_rec.STATUS_CODE:=l_prd_workorder_rec.job_STATUS_CODE;
  END IF;

  IF p_x_prd_workorder_rec.STATUS_MEANING= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.STATUS_MEANING:=NULL;
  ELSIF p_x_prd_workorder_rec.STATUS_MEANING IS NULL THEN
    p_x_prd_workorder_rec.STATUS_MEANING:=l_prd_workorder_rec.JOB_STATUS_MEANING;
  END IF;

  IF p_x_prd_workorder_rec.SCHEDULED_START_DATE=FND_API.G_MISS_DATE THEN
    p_x_prd_workorder_rec.SCHEDULED_START_DATE:=NULL;
  ELSIF p_x_prd_workorder_rec.SCHEDULED_START_DATE IS NULL THEN
    p_x_prd_workorder_rec.SCHEDULED_START_DATE:=l_prd_workorder_rec.SCHEDULED_START_DATE;
  END IF;

  IF p_x_prd_workorder_rec.SCHEDULED_START_HR=FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.SCHEDULED_START_HR:=NULL;
  ELSIF p_x_prd_workorder_rec.SCHEDULED_START_HR IS NULL THEN
    p_x_prd_workorder_rec.SCHEDULED_START_HR:=l_prd_workorder_rec.SCHEDULED_START_HR;
  END IF;

  IF p_x_prd_workorder_rec.SCHEDULED_START_MI=FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.SCHEDULED_START_MI:=NULL;
  ELSIF p_x_prd_workorder_rec.SCHEDULED_START_MI IS NULL THEN
    p_x_prd_workorder_rec.SCHEDULED_START_MI:=l_prd_workorder_rec.SCHEDULED_START_MI;
  END IF;

  IF p_x_prd_workorder_rec.SCHEDULED_END_DATE=FND_API.G_MISS_DATE THEN
    p_x_prd_workorder_rec.SCHEDULED_END_DATE:=NULL;
  ELSIF p_x_prd_workorder_rec.SCHEDULED_END_DATE IS NULL THEN
    p_x_prd_workorder_rec.SCHEDULED_END_DATE:=l_prd_workorder_rec.SCHEDULED_END_DATE;
  END IF;

  IF p_x_prd_workorder_rec.SCHEDULED_END_HR=FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.SCHEDULED_END_HR:=NULL;
  ELSIF p_x_prd_workorder_rec.SCHEDULED_END_HR IS NULL THEN
    p_x_prd_workorder_rec.SCHEDULED_END_HR:=l_prd_workorder_rec.SCHEDULED_END_HR;
  END IF;

  IF p_x_prd_workorder_rec.SCHEDULED_END_MI=FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.SCHEDULED_END_MI:=NULL;
  ELSIF p_x_prd_workorder_rec.SCHEDULED_END_MI IS NULL THEN
    p_x_prd_workorder_rec.SCHEDULED_END_MI:=l_prd_workorder_rec.SCHEDULED_END_MI;
  END IF;

  IF p_x_prd_workorder_rec.ACTUAL_START_DATE=FND_API.G_MISS_DATE THEN
    p_x_prd_workorder_rec.ACTUAL_START_DATE:=NULL;
  ELSIF p_x_prd_workorder_rec.ACTUAL_START_DATE IS NULL THEN
    p_x_prd_workorder_rec.ACTUAL_START_DATE:=l_prd_workorder_rec.ACTUAL_START_DATE;
  END IF;

  IF p_x_prd_workorder_rec.ACTUAL_START_HR=FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.ACTUAL_START_HR:=NULL;
  ELSIF p_x_prd_workorder_rec.ACTUAL_START_HR IS NULL THEN
    p_x_prd_workorder_rec.ACTUAL_START_HR:=l_prd_workorder_rec.ACTUAL_START_HR;
  END IF;

  IF p_x_prd_workorder_rec.ACTUAL_START_MI=FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.ACTUAL_START_MI:=NULL;
  ELSIF p_x_prd_workorder_rec.ACTUAL_START_MI IS NULL THEN
    p_x_prd_workorder_rec.ACTUAL_START_MI:=l_prd_workorder_rec.ACTUAL_START_MI;
  END IF;

  IF p_x_prd_workorder_rec.ACTUAL_END_DATE=FND_API.G_MISS_DATE THEN
    p_x_prd_workorder_rec.ACTUAL_END_DATE:=NULL;
  ELSIF p_x_prd_workorder_rec.ACTUAL_END_DATE IS NULL THEN
    p_x_prd_workorder_rec.ACTUAL_END_DATE:=l_prd_workorder_rec.ACTUAL_END_DATE;
  END IF;

  IF p_x_prd_workorder_rec.ACTUAL_END_HR=FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.ACTUAL_END_HR:=NULL;
  ELSIF p_x_prd_workorder_rec.ACTUAL_END_HR IS NULL THEN
    p_x_prd_workorder_rec.ACTUAL_END_HR:=l_prd_workorder_rec.ACTUAL_END_HR;
  END IF;

  IF p_x_prd_workorder_rec.ACTUAL_END_MI=FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.ACTUAL_END_MI:=NULL;
  ELSIF p_x_prd_workorder_rec.ACTUAL_END_MI IS NULL THEN
    p_x_prd_workorder_rec.ACTUAL_END_MI:=l_prd_workorder_rec.ACTUAL_END_MI;
  END IF;

  IF p_x_prd_workorder_rec.INVENTORY_ITEM_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.INVENTORY_ITEM_ID:=NULL;
  ELSIF p_x_prd_workorder_rec.INVENTORY_ITEM_ID IS NULL THEN
    p_x_prd_workorder_rec.INVENTORY_ITEM_ID:=l_prd_workorder_rec.INVENTORY_ITEM_ID;
  END IF;

  IF p_x_prd_workorder_rec.ITEM_INSTANCE_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.ITEM_INSTANCE_ID:=NULL;
  ELSIF p_x_prd_workorder_rec.ITEM_INSTANCE_ID IS NULL THEN
    p_x_prd_workorder_rec.ITEM_INSTANCE_ID:=l_prd_workorder_rec.ITEM_INSTANCE_ID;
  END IF;

  IF p_x_prd_workorder_rec.UNIT_NAME= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.UNIT_NAME:=NULL;
  ELSIF p_x_prd_workorder_rec.UNIT_NAME IS NULL THEN
    p_x_prd_workorder_rec.UNIT_NAME:=l_prd_workorder_rec.UNIT_NAME;
  END IF;

  IF p_x_prd_workorder_rec.ITEM_INSTANCE_NUMBER= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.ITEM_INSTANCE_NUMBER:=NULL;
  ELSIF p_x_prd_workorder_rec.ITEM_INSTANCE_NUMBER IS NULL THEN
    p_x_prd_workorder_rec.ITEM_INSTANCE_NUMBER:=l_prd_workorder_rec.ITEM_INSTANCE_NUMBER;
  END IF;

  IF p_x_prd_workorder_rec.QUANTITY= FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.QUANTITY:=NULL;
  ELSIF p_x_prd_workorder_rec.QUANTITY IS NULL THEN
    p_x_prd_workorder_rec.QUANTITY:=l_prd_workorder_rec.QUANTITY;
  END IF;

  IF p_x_prd_workorder_rec.WO_PART_NUMBER= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.WO_PART_NUMBER:=NULL;
  ELSIF p_x_prd_workorder_rec.WO_PART_NUMBER IS NULL THEN
    p_x_prd_workorder_rec.WO_PART_NUMBER:=l_prd_workorder_rec.WO_PART_NUMBER;
  END IF;

  IF p_x_prd_workorder_rec.ITEM_DESCRIPTION= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.ITEM_DESCRIPTION:=NULL;
  ELSIF p_x_prd_workorder_rec.ITEM_DESCRIPTION IS NULL THEN
    p_x_prd_workorder_rec.ITEM_DESCRIPTION:=l_prd_workorder_rec.ITEM_DESCRIPTION;
  END IF;

  IF p_x_prd_workorder_rec.SERIAL_NUMBER= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.SERIAL_NUMBER:=NULL;
  ELSIF p_x_prd_workorder_rec.SERIAL_NUMBER IS NULL THEN
    p_x_prd_workorder_rec.SERIAL_NUMBER:=l_prd_workorder_rec.SERIAL_NUMBER;
  END IF;

  IF p_x_prd_workorder_rec.ITEM_INSTANCE_UOM= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.ITEM_INSTANCE_UOM:=NULL;
  ELSIF p_x_prd_workorder_rec.ITEM_INSTANCE_UOM IS NULL THEN
    p_x_prd_workorder_rec.ITEM_INSTANCE_UOM:=l_prd_workorder_rec.ITEM_INSTANCE_UOM;
  END IF;

  IF p_x_prd_workorder_rec.COMPLETION_SUBINVENTORY= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.COMPLETION_SUBINVENTORY:=NULL;
  ELSIF p_x_prd_workorder_rec.COMPLETION_SUBINVENTORY IS NULL THEN
    p_x_prd_workorder_rec.COMPLETION_SUBINVENTORY:=l_prd_workorder_rec.COMPLETION_SUBINVENTORY;
  END IF;

  IF p_x_prd_workorder_rec.COMPLETION_LOCATOR_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.COMPLETION_LOCATOR_ID:=NULL;
  ELSIF p_x_prd_workorder_rec.COMPLETION_LOCATOR_ID IS NULL THEN
    p_x_prd_workorder_rec.COMPLETION_LOCATOR_ID:=l_prd_workorder_rec.COMPLETION_LOCATOR_ID;
  END IF;

  IF p_x_prd_workorder_rec.VISIT_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.VISIT_ID:=NULL;
  ELSIF p_x_prd_workorder_rec.VISIT_ID IS NULL THEN
    p_x_prd_workorder_rec.VISIT_ID:=l_prd_workorder_rec.VISIT_ID;
  END IF;

  IF p_x_prd_workorder_rec.VISIT_NUMBER= FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.VISIT_NUMBER:=NULL;
  ELSIF p_x_prd_workorder_rec.VISIT_NUMBER IS NULL THEN
    p_x_prd_workorder_rec.VISIT_NUMBER:=l_prd_workorder_rec.VISIT_NUMBER;
  END IF;

  IF p_x_prd_workorder_rec.VISIT_NAME= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.VISIT_NAME:=NULL;
  ELSIF p_x_prd_workorder_rec.VISIT_NAME IS NULL THEN
    p_x_prd_workorder_rec.VISIT_NAME:=l_prd_workorder_rec.VISIT_NAME;
  END IF;

  IF p_x_prd_workorder_rec.MASTER_WORKORDER_FLAG= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.MASTER_WORKORDER_FLAG:=NULL;
  ELSIF p_x_prd_workorder_rec.MASTER_WORKORDER_FLAG IS NULL THEN
    p_x_prd_workorder_rec.MASTER_WORKORDER_FLAG:=l_prd_workorder_rec.MASTER_WORKORDER_FLAG;
  END IF;

  IF p_x_prd_workorder_rec.VISIT_TASK_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.VISIT_TASK_ID:=NULL;
  ELSIF p_x_prd_workorder_rec.VISIT_TASK_ID IS NULL THEN
    p_x_prd_workorder_rec.VISIT_TASK_ID:=l_prd_workorder_rec.VISIT_TASK_ID;
  END IF;

  IF p_x_prd_workorder_rec.MR_HEADER_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.MR_HEADER_ID:=NULL;
  ELSIF p_x_prd_workorder_rec.MR_HEADER_ID IS NULL THEN
    p_x_prd_workorder_rec.MR_HEADER_ID:=l_prd_workorder_rec.MR_HEADER_ID;
  END IF;

  IF p_x_prd_workorder_rec.VISIT_TASK_NUMBER= FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.VISIT_TASK_NUMBER:=NULL;
  ELSIF p_x_prd_workorder_rec.VISIT_TASK_NUMBER IS NULL THEN
    p_x_prd_workorder_rec.VISIT_TASK_NUMBER:=l_prd_workorder_rec.VISIT_TASK_NUMBER;
  END IF;

  IF p_x_prd_workorder_rec.MR_TITLE= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.MR_TITLE:=NULL;
  ELSIF p_x_prd_workorder_rec.MR_TITLE IS NULL THEN
    p_x_prd_workorder_rec.MR_TITLE:=l_prd_workorder_rec.MR_TITLE;
  END IF;

  IF p_x_prd_workorder_rec.SERVICE_ITEM_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.SERVICE_ITEM_ID:=NULL;
  ELSIF p_x_prd_workorder_rec.SERVICE_ITEM_ID IS NULL THEN
    p_x_prd_workorder_rec.SERVICE_ITEM_ID:=l_prd_workorder_rec.SERVICE_ITEM_ID;
  END IF;

  IF p_x_prd_workorder_rec.SERVICE_ITEM_ORG_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.SERVICE_ITEM_ORG_ID:=NULL;
  ELSIF p_x_prd_workorder_rec.SERVICE_ITEM_ORG_ID IS NULL THEN
    p_x_prd_workorder_rec.SERVICE_ITEM_ORG_ID:=l_prd_workorder_rec.SERVICE_ITEM_ORG_ID;
  END IF;

  IF p_x_prd_workorder_rec.SERVICE_ITEM_DESCRIPTION= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.SERVICE_ITEM_DESCRIPTION:=NULL;
  ELSIF p_x_prd_workorder_rec.SERVICE_ITEM_DESCRIPTION IS NULL THEN
    p_x_prd_workorder_rec.SERVICE_ITEM_DESCRIPTION:=l_prd_workorder_rec.SERVICE_ITEM_DESCRIPTION;
  END IF;

  IF p_x_prd_workorder_rec.SERVICE_ITEM_NUMBER= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.SERVICE_ITEM_NUMBER:=NULL;
  ELSIF p_x_prd_workorder_rec.SERVICE_ITEM_NUMBER IS NULL THEN
    p_x_prd_workorder_rec.SERVICE_ITEM_NUMBER:=l_prd_workorder_rec.SERVICE_ITEM_NUMBER;
  END IF;

  IF p_x_prd_workorder_rec.SERVICE_ITEM_UOM= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.SERVICE_ITEM_UOM:=NULL;
  ELSIF p_x_prd_workorder_rec.SERVICE_ITEM_UOM IS NULL THEN
    p_x_prd_workorder_rec.SERVICE_ITEM_UOM:=l_prd_workorder_rec.SERVICE_ITEM_UOM;
  END IF;

  IF p_x_prd_workorder_rec.PROJECT_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.PROJECT_ID:=NULL;
  ELSIF p_x_prd_workorder_rec.PROJECT_ID IS NULL THEN
    p_x_prd_workorder_rec.PROJECT_ID:=l_prd_workorder_rec.PROJECT_ID;
  END IF;

  IF p_x_prd_workorder_rec.PROJECT_TASK_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.PROJECT_TASK_ID:=NULL;
  ELSIF p_x_prd_workorder_rec.PROJECT_TASK_ID IS NULL THEN
    p_x_prd_workorder_rec.PROJECT_TASK_ID:=l_prd_workorder_rec.PROJECT_TASK_ID;
  END IF;

  IF p_x_prd_workorder_rec.INCIDENT_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.INCIDENT_ID:=NULL;
  ELSIF p_x_prd_workorder_rec.INCIDENT_ID IS NULL THEN
    p_x_prd_workorder_rec.INCIDENT_ID:=l_prd_workorder_rec.INCIDENT_ID;
  END IF;

  IF p_x_prd_workorder_rec.UNIT_EFFECTIVITY_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.UNIT_EFFECTIVITY_ID:=NULL;
  ELSIF p_x_prd_workorder_rec.UNIT_EFFECTIVITY_ID IS NULL THEN
    p_x_prd_workorder_rec.UNIT_EFFECTIVITY_ID:=l_prd_workorder_rec.UNIT_EFFECTIVITY_ID;
  END IF;

  IF p_x_prd_workorder_rec.PLAN_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.PLAN_ID:=NULL;
  ELSIF p_x_prd_workorder_rec.PLAN_ID IS NULL THEN
    p_x_prd_workorder_rec.PLAN_ID:=l_prd_workorder_rec.PLAN_ID;
  END IF;

  IF p_x_prd_workorder_rec.COLLECTION_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.COLLECTION_ID:=NULL;
  ELSIF p_x_prd_workorder_rec.COLLECTION_ID IS NULL THEN
    p_x_prd_workorder_rec.COLLECTION_ID:=l_prd_workorder_rec.COLLECTION_ID;
  END IF;

  IF p_x_prd_workorder_rec.JOB_PRIORITY= FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.JOB_PRIORITY:=NULL;
  ELSIF p_x_prd_workorder_rec.JOB_PRIORITY IS NULL THEN
    p_x_prd_workorder_rec.JOB_PRIORITY:=l_prd_workorder_rec.PRIORITY;
  END IF;

  IF p_x_prd_workorder_rec.JOB_PRIORITY_MEANING= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.JOB_PRIORITY_MEANING:=NULL;
  ELSIF p_x_prd_workorder_rec.JOB_PRIORITY_MEANING IS NULL THEN
    p_x_prd_workorder_rec.JOB_PRIORITY_MEANING:=l_prd_workorder_rec.PRIORITY_MEANING;
  END IF;

		IF p_x_prd_workorder_rec.CONFIRM_FAILURE_FLAG = FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.CONFIRM_FAILURE_FLAG :=NULL;
  ELSIF p_x_prd_workorder_rec.CONFIRM_FAILURE_FLAG  IS NULL THEN
    p_x_prd_workorder_rec.CONFIRM_FAILURE_FLAG :=l_prd_workorder_rec.CONFIRM_FAILURE_FLAG;
  END IF;
  IF p_x_prd_workorder_rec.ATTRIBUTE_CATEGORY= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.ATTRIBUTE_CATEGORY:=NULL;
  ELSIF p_x_prd_workorder_rec.ATTRIBUTE_CATEGORY IS NULL THEN
    p_x_prd_workorder_rec.ATTRIBUTE_CATEGORY:=l_prd_workorder_rec.ATTRIBUTE_CATEGORY;
  END IF;

  IF p_x_prd_workorder_rec.ATTRIBUTE1= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.ATTRIBUTE1:=NULL;
  ELSIF p_x_prd_workorder_rec.ATTRIBUTE1 IS NULL THEN
    p_x_prd_workorder_rec.ATTRIBUTE1:=l_prd_workorder_rec.ATTRIBUTE1;
  END IF;

  IF p_x_prd_workorder_rec.ATTRIBUTE2= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.ATTRIBUTE2:=NULL;
  ELSIF p_x_prd_workorder_rec.ATTRIBUTE2 IS NULL THEN
    p_x_prd_workorder_rec.ATTRIBUTE2:=l_prd_workorder_rec.ATTRIBUTE2;
  END IF;

  IF p_x_prd_workorder_rec.ATTRIBUTE3= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.ATTRIBUTE3:=NULL;
  ELSIF p_x_prd_workorder_rec.ATTRIBUTE3 IS NULL THEN
    p_x_prd_workorder_rec.ATTRIBUTE3:=l_prd_workorder_rec.ATTRIBUTE3;
  END IF;

  IF p_x_prd_workorder_rec.ATTRIBUTE4= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.ATTRIBUTE4:=NULL;
  ELSIF p_x_prd_workorder_rec.ATTRIBUTE4 IS NULL THEN
    p_x_prd_workorder_rec.ATTRIBUTE4:=l_prd_workorder_rec.ATTRIBUTE4;
  END IF;

  IF p_x_prd_workorder_rec.ATTRIBUTE5= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.ATTRIBUTE5:=NULL;
  ELSIF p_x_prd_workorder_rec.ATTRIBUTE5 IS NULL THEN
    p_x_prd_workorder_rec.ATTRIBUTE5:=l_prd_workorder_rec.ATTRIBUTE5;
  END IF;

  IF p_x_prd_workorder_rec.ATTRIBUTE6= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.ATTRIBUTE6:=NULL;
  ELSIF p_x_prd_workorder_rec.ATTRIBUTE6 IS NULL THEN
    p_x_prd_workorder_rec.ATTRIBUTE6:=l_prd_workorder_rec.ATTRIBUTE6;
  END IF;

  IF p_x_prd_workorder_rec.ATTRIBUTE7= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.ATTRIBUTE7:=NULL;
  ELSIF p_x_prd_workorder_rec.ATTRIBUTE7 IS NULL THEN
    p_x_prd_workorder_rec.ATTRIBUTE7:=l_prd_workorder_rec.ATTRIBUTE7;
  END IF;

  IF p_x_prd_workorder_rec.ATTRIBUTE8= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.ATTRIBUTE8:=NULL;
  ELSIF p_x_prd_workorder_rec.ATTRIBUTE8 IS NULL THEN
    p_x_prd_workorder_rec.ATTRIBUTE8:=l_prd_workorder_rec.ATTRIBUTE8;
  END IF;

  IF p_x_prd_workorder_rec.ATTRIBUTE9= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.ATTRIBUTE9:=NULL;
  ELSIF p_x_prd_workorder_rec.ATTRIBUTE9 IS NULL THEN
    p_x_prd_workorder_rec.ATTRIBUTE9:=l_prd_workorder_rec.ATTRIBUTE9;
  END IF;

  IF p_x_prd_workorder_rec.ATTRIBUTE10= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.ATTRIBUTE10:=NULL;
  ELSIF p_x_prd_workorder_rec.ATTRIBUTE10 IS NULL THEN
    p_x_prd_workorder_rec.ATTRIBUTE10:=l_prd_workorder_rec.ATTRIBUTE10;
  END IF;

  IF p_x_prd_workorder_rec.ATTRIBUTE11= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.ATTRIBUTE11:=NULL;
  ELSIF p_x_prd_workorder_rec.ATTRIBUTE11 IS NULL THEN
    p_x_prd_workorder_rec.ATTRIBUTE11:=l_prd_workorder_rec.ATTRIBUTE11;
  END IF;

  IF p_x_prd_workorder_rec.ATTRIBUTE12= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.ATTRIBUTE12:=NULL;
  ELSIF p_x_prd_workorder_rec.ATTRIBUTE12 IS NULL THEN
    p_x_prd_workorder_rec.ATTRIBUTE12:=l_prd_workorder_rec.ATTRIBUTE12;
  END IF;

  IF p_x_prd_workorder_rec.ATTRIBUTE13= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.ATTRIBUTE13:=NULL;
  ELSIF p_x_prd_workorder_rec.ATTRIBUTE13 IS NULL THEN
    p_x_prd_workorder_rec.ATTRIBUTE13:=l_prd_workorder_rec.ATTRIBUTE13;
  END IF;

  IF p_x_prd_workorder_rec.ATTRIBUTE14= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.ATTRIBUTE14:=NULL;
  ELSIF p_x_prd_workorder_rec.ATTRIBUTE14 IS NULL THEN
    p_x_prd_workorder_rec.ATTRIBUTE14:=l_prd_workorder_rec.ATTRIBUTE14;
  END IF;

  IF p_x_prd_workorder_rec.ATTRIBUTE15= FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.ATTRIBUTE15:=NULL;
  ELSIF p_x_prd_workorder_rec.ATTRIBUTE15 IS NULL THEN
    p_x_prd_workorder_rec.ATTRIBUTE15:=l_prd_workorder_rec.ATTRIBUTE15;
  END IF;

  IF p_x_prd_workorder_rec.HOLD_REASON_CODE = FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.HOLD_REASON_CODE:=NULL;
  ELSIF p_x_prd_workorder_rec.HOLD_REASON_CODE IS NULL THEN
    p_x_prd_workorder_rec.HOLD_REASON_CODE:=l_prd_workorder_rec.HOLD_REASON_CODE;
  END IF;

END default_missing_attributes;

PROCEDURE convert_values_to_ids
(
  p_x_prd_workorder_rec   IN OUT NOCOPY PRD_WORKORDER_REC
)
AS

CURSOR get_quantity(c_instance_id NUMBER)
IS
SELECT quantity
FROM   CSI_ITEM_INSTANCES
WHERE  instance_id=c_instance_id
AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(ACTIVE_START_DATE,SYSDATE))
                      AND TRUNC(NVL(ACTIVE_END_DATE,SYSDATE));

CURSOR get_department(c_dept VARCHAR2,c_org_id NUMBER)
IS
SELECT department_id
FROM   BOM_DEPARTMENTS
WHERE  UPPER(description) LIKE UPPER(c_dept)
AND    ORganization_id=c_org_id;
-- bug 4143943
CURSOR get_wo_status(c_workorder_id NUMBER)
IS
SELECT STATUS_CODE
FROM AHL_WORKORDERS
WHERE workorder_id = c_workorder_id;

-- Balaji added for Release NR error
CURSOR get_wo_sch_sec(c_wip_entity_id IN NUMBER)
IS
SELECT
   TO_CHAR(scheduled_start_date, 'ss') schedule_start_sec,
   TO_CHAR(scheduled_completion_date, 'ss') schedule_end_sec
FROM
   WIP_DISCRETE_JOBS
WHERE
   WIP_ENTITY_ID = c_wip_entity_id;

-- Balaji added for Release NR error
CURSOR get_wo_act_sec(c_workorder_id IN NUMBER)
IS
SELECT
   TO_CHAR(actual_start_date, 'ss') actual_start_sec,
   TO_CHAR(actual_end_date, 'ss') actual_end_sec
FROM
   AHL_WORKORDERS
WHERE
   WORKORDER_ID = c_workorder_id;

-- FP bug# 7631453
CURSOR get_hold_reason_code_csr(c_hold_reason VARCHAR2)
IS
SELECT Lookup_code
FROM FND_LOOKUPS
WHERE lookup_type = 'AHL_PRD_WO_HOLD_REASON'
AND MEANING = c_hold_reason;
-- End FP bug# 7631453

l_ctr                   NUMBER:=0;
--l_hour                  VARCHAR2(30);
--l_minutes               VARCHAR2(30);
l_sec                   VARCHAR2(30);
--l_date_time             VARCHAR2(30);
l_wo_status             VARCHAR2(30);
l_sch_start_sec         VARCHAR2(30);
l_sch_end_sec           VARCHAR2(30);
l_act_start_sec         VARCHAR2(30);
l_act_end_sec           VARCHAR2(30);


BEGIN
  IF  p_x_prd_workorder_rec.dml_operation='C' THEN

    IF p_x_prd_workorder_rec.QUANTITY IS NULL OR
       p_x_prd_workorder_rec.QUANTITY=FND_API.G_MISS_CHAR THEN
      OPEN  get_quantity(p_x_prd_workorder_rec.ITEM_INSTANCE_ID);
      FETCH get_quantity INTO p_x_prd_workorder_rec.QUANTITY;
      CLOSE get_quantity;
    END IF;

    IF p_x_prd_workorder_rec.STATUS_CODE IS NULL OR
       p_x_prd_workorder_rec.STATUS_CODE=FND_API.G_MISS_CHAR THEN
      p_x_prd_workorder_rec.STATUS_CODE:=G_JOB_STATUS_UNRELEASED;  -- Job_Status_Code '1' UnReleseed
    END IF;

    IF p_x_prd_workorder_rec.job_priority IS NULL OR
       p_x_prd_workorder_rec.job_priority=FND_API.G_MISS_NUM THEN
      p_x_prd_workorder_rec.job_priority:=NULL;
    ELSIF p_x_prd_workorder_rec.job_priority IS not NULL AND
          p_x_prd_workorder_rec.job_priority<>FND_API.G_MISS_NUM THEN

      SELECT COUNT(*) INTO l_ctr
      FROM   MFG_LOOKUPS
      WHERE  lookup_type='WIP_EAM_ACTIVITY_PRIORITY'
      AND    lookup_code=p_x_prd_workorder_rec.job_priority;

      IF l_ctr=0 THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_PRD_PRIORITY_INVALID');
        FND_MSG_PUB.ADD;
      END IF;
    END IF;

  ELSIF  p_x_prd_workorder_rec.dml_operation='U' THEN
    IF p_x_prd_workorder_rec.job_priority IS NULL OR
       p_x_prd_workorder_rec.job_priority=FND_API.G_MISS_NUM THEN
      p_x_prd_workorder_rec.job_priority:=NULL;
    END IF;

    IF p_x_prd_workorder_rec.Department_Name IS not NULL AND
       p_x_prd_workorder_rec.Department_Name<>FND_API.G_MISS_CHAR THEN

      OPEN get_department(p_x_prd_workorder_rec.Department_Name,p_x_prd_workorder_rec.Organization_id);
      FETCH get_department INTO p_x_prd_workorder_rec.department_id;

      IF get_department%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_PRD_DEPT_INVALID');
        FND_MSG_PUB.ADD;
      END IF;
      CLOSE get_department;
    END IF;

  END IF;
-- bug 4143943
		-- if the existing workorder status is 17
		-- that is the workorder is not being updated from the prod UI
		-- but is coming from VWP Push to Prod,
		-- then the scheduled start hr and min fields are not populated
		-- and are already part of the start and end dates
		-- so these should not be converted to 00:00

		OPEN get_wo_status(p_x_prd_workorder_rec.workorder_id);
		FETCH get_wo_status INTO l_wo_status;
		CLOSE get_wo_status;

		IF l_wo_status <> '17' THEN

  -- portion of the code to get workorder seconds from the DB.
  -- These values will be used in case if its not passed from the UI
  OPEN get_wo_sch_sec(p_x_prd_workorder_rec.wip_entity_id);
  FETCH get_wo_sch_sec INTO l_sch_start_sec, l_sch_end_sec;
  CLOSE get_wo_sch_sec;

  IF p_x_prd_workorder_rec.SCHEDULED_START_DATE IS NOT NULL AND
     p_x_prd_workorder_rec.SCHEDULED_START_DATE <> FND_API.G_MISS_DATE
     AND G_CALLED_FROM <> 'OAF' THEN

     -- Fix for error while releasing unreleased workorders
    -- the seconds value needs to be taken into account for workorders, otherwise
    -- this might lead to a discrepancy with the operation dates
    l_sec :=  TO_CHAR(p_x_prd_workorder_rec.SCHEDULED_START_DATE, 'ss');
    IF(l_sec = '00') THEN
       l_sec := l_sch_start_sec;
    END IF;
    p_x_prd_workorder_rec.SCHEDULED_START_DATE :=
                  get_date_and_time
                                  (p_date => p_x_prd_workorder_rec.SCHEDULED_START_DATE,
                                   p_date_hh24 => p_x_prd_workorder_rec.SCHEDULED_START_HR,
                                   p_date_mi => p_x_prd_workorder_rec.SCHEDULED_START_MI,
                                   p_date_ss => l_sec);

  END IF;
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( 'p_x_prd_workorder_rec.SCHEDULED_START_DATE : ' || to_char(p_x_prd_workorder_rec.SCHEDULED_START_DATE,'DD-MON-YY hh24:mi:ss') );
  END IF;

  IF p_x_prd_workorder_rec.SCHEDULED_END_DATE IS NOT NULL AND
     p_x_prd_workorder_rec.SCHEDULED_END_DATE <> FND_API.G_MISS_DATE
     AND G_CALLED_FROM <> 'OAF' THEN

    -- Fix for error while releasing unreleased workorders
    -- the seconds value needs to be taken into account for workorders, otherwise
    -- this might lead to a discrepancy with the operation dates
    l_sec := TO_CHAR(p_x_prd_workorder_rec.SCHEDULED_END_DATE, 'ss');

    IF(l_sec = '00') THEN
       l_sec := l_sch_end_sec;
    END IF;

    p_x_prd_workorder_rec.SCHEDULED_END_DATE :=
                  get_date_and_time
                                  (p_date => p_x_prd_workorder_rec.SCHEDULED_END_DATE,
                                   p_date_hh24 => p_x_prd_workorder_rec.SCHEDULED_END_HR,
                                   p_date_mi => p_x_prd_workorder_rec.SCHEDULED_END_MI,
                                   p_date_ss => l_sec);



  END IF;
  IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'p_x_prd_workorder_rec.SCHEDULED_END_DATE : ' || to_char(p_x_prd_workorder_rec.SCHEDULED_END_DATE,'DD-MON-YY hh24:mi:ss') );
     END IF;
END IF; -- l_wo_status <> '17'

  -- portion of the code to get workorder seconds from the DB.
  -- These values will be used in case if its not passed from the UI
  -- Balaji added for Release NR error
  OPEN get_wo_act_sec(p_x_prd_workorder_rec.workorder_id);
  FETCH get_wo_act_sec INTO l_act_start_sec, l_act_end_sec;
  CLOSE get_wo_act_sec;

  IF p_x_prd_workorder_rec.ACTUAL_START_DATE IS NOT NULL AND
     p_x_prd_workorder_rec.ACTUAL_START_DATE <> FND_API.G_MISS_DATE
     AND G_CALLED_FROM <> 'OAF' THEN

    l_sec := TO_CHAR(p_x_prd_workorder_rec.ACTUAL_START_DATE, 'ss');

    -- Balaji added for Release NR error
    IF(l_sec = '00') THEN
       l_sec := l_act_start_sec;
    END IF;
     p_x_prd_workorder_rec.ACTUAL_START_DATE :=
                  get_date_and_time
                                  (p_date => p_x_prd_workorder_rec.ACTUAL_START_DATE,
                                   p_date_hh24 => p_x_prd_workorder_rec.ACTUAL_START_HR,
                                   p_date_mi => p_x_prd_workorder_rec.ACTUAL_START_MI,
                                   p_date_ss => l_sec);
     IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'p_x_prd_workorder_rec.ACTUAL_START_DATE : ' || to_char(p_x_prd_workorder_rec.ACTUAL_START_DATE,'DD-MON-YY hh24:mi:ss') );
     END IF;

  END IF;

  IF p_x_prd_workorder_rec.ACTUAL_END_DATE IS NOT NULL AND
     p_x_prd_workorder_rec.ACTUAL_END_DATE <> FND_API.G_MISS_DATE
     AND G_CALLED_FROM <> 'OAF' THEN

    l_sec := TO_CHAR(p_x_prd_workorder_rec.ACTUAL_END_DATE, 'ss');

    -- Balaji added for Release NR error
    IF(l_sec = '00') THEN
       l_sec := l_act_end_sec;
    END IF;
    p_x_prd_workorder_rec.ACTUAL_END_DATE :=
                  get_date_and_time
                                  (p_date => p_x_prd_workorder_rec.ACTUAL_END_DATE,
                                   p_date_hh24 => p_x_prd_workorder_rec.ACTUAL_END_HR,
                                   p_date_mi => p_x_prd_workorder_rec.ACTUAL_END_MI,
                                   p_date_ss => l_sec);
     IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'p_x_prd_workorder_rec.ACTUAL_START_DATE : ' || to_char(p_x_prd_workorder_rec.ACTUAL_END_DATE,'DD-MON-YY hh24:mi:ss') );
     END IF;

  END IF;

  -- FP bug# 7631453
  IF (p_x_prd_workorder_rec.HOLD_REASON_CODE IS NULL OR G_CALLED_FROM <> 'API' OR G_CALLED_FROM IS NULL) THEN
     IF p_x_prd_workorder_rec.HOLD_REASON IS NOT NULL AND p_x_prd_workorder_rec.HOLD_REASON <> FND_API.G_MISS_CHAR THEN
       OPEN get_hold_reason_code_csr(p_x_prd_workorder_rec.HOLD_REASON);
       FETCH get_hold_reason_code_csr INTO p_x_prd_workorder_rec.HOLD_REASON_CODE;
       IF get_hold_reason_code_csr%NOTFOUND THEN
          FND_MESSAGE.SET_NAME('AHL','AHL_PP_REASON_INVALID');
          FND_MSG_PUB.ADD;
       END IF;
       CLOSE get_hold_reason_code_csr;
     END IF;
  END IF;

END convert_values_to_ids;

FUNCTION is_wo_updated(p_prd_workorder_rec IN PRD_WORKORDER_REC)
RETURN BOOLEAN
AS

CURSOR get_old_wo_values(c_workorder_id NUMBER)
IS
SELECT AWOS.CONFIRM_FAILURE_FLAG,
       AWOS.ACTUAL_START_DATE,
       AWOS.ACTUAL_END_DATE,
       WIP.SCHEDULED_START_DATE,
       WIP.SCHEDULED_COMPLETION_DATE,
       WIP.OWNING_DEPARTMENT
FROM AHL_WORKORDERS AWOS,
     WIP_DISCRETE_JOBS WIP
WHERE AWOS.WIP_ENTITY_ID = WIP.WIP_ENTITY_ID
AND AWOS.workorder_id = c_workorder_id;

l_old_workorder_rec get_old_wo_values%ROWTYPE;

BEGIN

		OPEN get_old_wo_values(p_prd_workorder_rec.workorder_id);
		FETCH get_old_wo_values INTO l_old_workorder_rec;
		CLOSE get_old_wo_values;

		IF p_prd_workorder_rec.confirm_failure_flag <> l_old_workorder_rec.confirm_failure_flag THEN
				RETURN TRUE;
		ELSIF p_prd_workorder_rec.actual_start_date <> l_old_workorder_rec.actual_start_date THEN
				RETURN TRUE;
		ELSIF p_prd_workorder_rec.actual_end_date <> l_old_workorder_rec.actual_end_date THEN
				RETURN TRUE;
		ELSIF p_prd_workorder_rec.scheduled_start_date <> l_old_workorder_rec.scheduled_start_date THEN
				RETURN TRUE;
		ELSIF p_prd_workorder_rec.scheduled_end_date <> l_old_workorder_rec.scheduled_completion_date THEN
				RETURN TRUE;
		ELSIF p_prd_workorder_rec.department_id <> l_old_workorder_rec.owning_department THEN
				RETURN TRUE;
		END IF;

		RETURN FALSE;


END is_wo_updated;

PROCEDURE validate_workorder
(
  p_prd_workorder_rec            IN      PRD_WORKORDER_REC,
  p_wip_load_flag                IN      VARCHAR2
)
as

CURSOR get_lookup_type_code(c_lookup_code VARCHAR2,c_lookup_type VARCHAR2)
IS
SELECT lookup_code
FROM   FND_LOOKUP_VALUES_VL
WHERE  lookup_code = c_lookup_code
AND    lookup_type = c_lookup_type
AND    SYSDATE BETWEEN NVL(start_date_active,SYSDATE)
               AND NVL(end_date_active,SYSDATE);

CURSOR validate_org(c_org_id NUMBER)
IS

/* Perf. fix for bug# 4949394. Replace ORG_ORGANIZATION_DEFINITIONS
   with INV_ORGANIZATION_NAME_V.
SELECT a.organization_id,
       b.eam_enabled_flag
FROM   ORG_ORGANIZATION_DEFINITIONS a,MTL_PARAMETERS b
WHERE  a.organization_id=b.organization_id
AND    a.organization_id=c_org_id;
*/

SELECT a.organization_id,
       b.eam_enabled_flag
FROM   INV_ORGANIZATION_NAME_V a,MTL_PARAMETERS b
WHERE  a.organization_id=b.organization_id
AND    a.organization_id=c_org_id;

l_org_rec                       validate_org%ROWTYPE;

CURSOR validate_dept(c_dept_id NUMBER,c_org_id NUMBER)
IS
SELECT a.department_id
FROM   BOM_DEPARTMENTS a
WHERE  a.department_id=c_dept_id
AND    a.organization_id=c_org_id;

CURSOR validate_item_instance(c_inv_item_id NUMBER,c_inst_id NUMBER)
IS
SELECT a.instance_id
FROM   CSI_ITEM_INSTANCES a
WHERE  a.inventory_item_id=c_inv_item_id
AND    a.instance_id=c_inst_id;

l_instance_rec           validate_item_instance%ROWTYPE;

CURSOR validate_subinventory(c_org_id NUMBER,c_sub_inv VARCHAR2)
IS
SELECT a.organization_id,
       a.secondary_inventory,
       b.eam_enabled_flag
FROM   MTL_ITEM_SUB_INVENTORIES a,
       MTL_PARAMETERS b
WHERE  a.organization_id=b.organization_id
AND    a.organization_id=c_org_id
AND    a.secondary_inventory=c_sub_inv;

l_subinv_rec    validate_subinventory%ROWTYPE;

CURSOR get_visit_task_name(c_visit_task_id NUMBER)
IS
SELECT visit_task_name
FROM   AHL_VISIT_TASKS_VL
WHERE  visit_task_id=c_visit_task_id;

CURSOR validate_project(C_org_id NUMBER)
IS
SELECT 1
FROM   MTL_PARAMETERS mpr
WHERE  mpr.organization_id=c_org_id
AND    NVL(mpr.project_reference_enabled,2)=1;

CURSOR  get_visit_wo_dates(c_visit_id NUMBER)
IS
SELECT  WDJ.scheduled_start_date,
        WDJ.scheduled_completion_date
FROM    WIP_DISCRETE_JOBS WDJ,
        AHL_WORKORDERS WO
WHERE   WDJ.wip_entity_id = WO.wip_entity_id
AND     WO.visit_task_id IS NULL
AND     WO.master_workorder_flag = 'Y'
AND     WO.visit_id = c_visit_id;

-- bug4393092
CURSOR get_wo_status(c_workorder_id VARCHAR2)
IS
SELECT AWOS.status_code,
       FNDL.meaning
FROM AHL_WORKORDERS AWOS,
     FND_LOOKUP_VALUES_VL FNDL
WHERE AWOS.WORKORDER_ID = c_workorder_id
AND FNDL.lookup_type = 'AHL_JOB_STATUS'
AND FNDL.lookup_code(+) = AWOS.status_code;
-- cursor to retrieve minimum actual start date and maximum actual
-- end date from all the operations within this workorder
-- Balaji added for the bug where actual operation dates fall outside
-- workorder dates
CURSOR c_get_op_actual_dates(c_workorder_id NUMBER)
IS
SELECT MIN(ACTUAL_START_DATE),
MAX(ACTUAL_END_DATE)
FROM AHL_WORKORDER_OPERATIONS
WHERE WORKORDER_ID = c_workorder_id;

-- FP bug# 7631453
Cursor validate_hold_reason_code_csr(c_hold_reason VARCHAR2)
IS
Select 1
FROM FND_LOOKUPS
WHERE lookup_type = 'AHL_PRD_WO_HOLD_REASON'
AND lookup_code = c_hold_reason;

l_dummy_ctr                     NUMBER:=0;
l_lookup_code                   VARCHAR2(30);
l_record_str                    VARCHAR2(80);
l_visit_start_date              DATE;
l_visit_end_date                DATE;

l_return_status                 VARCHAR2(1);
l_wo_status                     VARCHAR2(80);
l_wo_status_code                VARCHAR2(30);
l_op_min_act_start_date         DATE;
l_op_max_act_end_date           DATE;
BEGIN

  IF p_prd_workorder_rec.DML_OPERATION='C' THEN
    IF p_prd_workorder_rec.VISIT_TASK_ID IS NOT NULL THEN
      OPEN  get_visit_task_name(p_prd_workorder_rec.VISIT_TASK_ID);
      FETCH get_visit_task_name INTO l_record_str;
      CLOSE get_visit_task_name;
    ELSE
      l_record_str := p_prd_workorder_rec.VISIT_NAME;
    END IF;
  ELSE
    l_record_str:=p_prd_workorder_rec.JOB_NUMBER;
  END IF;

		IF p_prd_workorder_rec.DML_OPERATION = 'U' THEN
		-- bug 4393092
		IF is_wo_updated(p_prd_workorder_rec) = TRUE THEN
		OPEN get_wo_status(p_prd_workorder_rec.workorder_id);
		FETCH get_wo_status INTO l_wo_status_code, l_wo_status;
		CLOSE get_wo_status;
		IF l_wo_status_code IN ('22','7','12','4','5') THEN
    FND_MESSAGE.set_name('AHL','AHL_PRD_UPD_WO_STS');
				FND_MESSAGE.set_token('WO_STATUS', l_wo_status);
				FND_MSG_PUB.add;
				RAISE FND_API.G_EXC_ERROR;
		END IF;	-- IF l_wo_status_code IN ('22','7','12','4','5') THEN
		END IF; -- IF is_wo_updated = TRUE THEN
		END IF; -- IF p_prd_workorder_rec.DML_OPERATION = 'U' THEN


		 -- rroy
			-- ACL Changes
			l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => NULL,
																																																						p_ue_id => NULL,
																																																						p_visit_id => NULL,
																																																						p_item_instance_id => p_prd_workorder_rec.item_instance_id);
			IF l_return_status = FND_API.G_TRUE THEN
					IF p_prd_workorder_rec.DML_OPERATION='C' THEN
	  				FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_CRT_WO_UNTLCKD');
					ELSE
	  				FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_UPD_WO_UNTLCKD');
					END IF;
					FND_MSG_PUB.ADD;
					RAISE FND_API.G_EXC_ERROR;
			END IF;
			-- rroy
			-- ACL Changes


  SELECT COUNT(*)
  INTO   l_dummy_ctr
  FROM   WIP_EAM_PARAMETERS
  WHERE  organization_id=p_prd_workorder_rec.ORGANIZATION_ID;

  IF l_dummy_ctr=0 THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_EAM_PREFIX_NOTSETUP');
    FND_MESSAGE.SET_TOKEN('ORG',p_prd_workorder_rec.ORGANIZATION_ID,false);
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;
  IF p_prd_workorder_rec.SCHEDULED_START_DATE  IS NULL OR
     p_prd_workorder_rec.SCHEDULED_START_DATE=FND_API.G_MISS_DATE THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_SCHED_ST_DT_NULL');
    FND_MSG_PUB.ADD;
  END IF;

  IF p_prd_workorder_rec.SCHEDULED_END_DATE  IS NULL OR
     p_prd_workorder_rec.SCHEDULED_END_DATE=FND_API.G_MISS_DATE THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_SCHED_END_DT_NULL');
    FND_MSG_PUB.ADD;
  END IF;

  IF p_prd_workorder_rec.SCHEDULED_START_DATE IS NOT NULL AND
     p_prd_workorder_rec.SCHEDULED_START_DATE<>FND_API.G_MISS_DATE AND
     p_prd_workorder_rec.SCHEDULED_END_DATE IS NOT NULL AND
     p_prd_workorder_rec.SCHEDULED_END_DATE<>FND_API.G_MISS_DATE THEN

    IF p_prd_workorder_rec.SCHEDULED_START_DATE > p_prd_workorder_rec.SCHEDULED_END_DATE THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_SCHD_STDT_GT_SCHD_DATE');
      FND_MSG_PUB.ADD;
    END IF;

    IF p_prd_workorder_rec.VISIT_TASK_ID IS NOT NULL AND
       p_wip_load_flag = 'Y' THEN
      OPEN  get_visit_wo_dates( p_prd_workorder_rec.visit_id );
      FETCH get_visit_wo_dates
      INTO  l_visit_start_date,
            l_visit_end_date;
      CLOSE get_visit_wo_dates;

-- as per mail from shailaja dtd tue,21 sep 2004,
-- Re: [Fwd: Re: Reschedule Visit Jobs after Visit Planned Start/End time change]
-- the workorder dates on the production ui's should be compared only with the visit master
-- workorder dates
      IF ( p_prd_workorder_rec.SCHEDULED_START_DATE < l_visit_start_date OR
           p_prd_workorder_rec.SCHEDULED_END_DATE > l_visit_end_date ) THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_PRD_SCHD_DT_EXCEEDS_VISIT');
        FND_MESSAGE.SET_TOKEN('START_DT', TO_CHAR( l_visit_start_date, 'DD-MON-YYYY HH24:MI' ),false);
        FND_MESSAGE.SET_TOKEN('END_DT', TO_CHAR( l_visit_end_date, 'DD-MON-YYYY HH24:MI' ),false);
        FND_MSG_PUB.ADD;
      END IF;
    END IF;

  END IF;

  IF p_prd_workorder_rec.ORGANIZATION_ID IS NULL OR
     p_prd_workorder_rec.ORGANIZATION_ID=FND_API.G_MISS_NUM THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_ORGID_NULL');
    FND_MSG_PUB.ADD;
  ELSE
    OPEN validate_org(p_prd_workorder_rec.ORGANIZATION_ID);
    FETCH validate_org INTO l_org_rec;
    IF validate_org%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_ORG_ID_INVALID');
      FND_MSG_PUB.ADD;
    ELSIF validate_org%FOUND AND l_org_rec.eam_enabled_flag='N' THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_ORG_ID_not_eam_enabled');
      FND_MESSAGE.SET_TOKEN('RECORD',l_record_str,false);
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE validate_org;
  END IF;

  IF p_prd_workorder_rec.DEPARTMENT_ID IS NULL OR
     p_prd_workorder_rec.DEPARTMENT_ID=FND_API.G_MISS_NUM THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_DEPT_ID_NULL');
    FND_MSG_PUB.ADD;
  ELSE
    OPEN  validate_dept(p_prd_workorder_rec.Department_id, p_prd_workorder_rec.Organization_id);
    FETCH validate_dept INTO l_dummy_ctr;
    IF validate_dept%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_DEPTID_INVALID');
      FND_MESSAGE.SET_TOKEN('TASK_JOB',l_record_str,false);
      FND_MESSAGE.SET_TOKEN('ORG',p_prd_workorder_rec.Organization_id,false);
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE validate_dept;
  END IF;

  IF p_prd_workorder_rec.ITEM_INSTANCE_ID IS NULL OR
     p_prd_workorder_rec.ITEM_INSTANCE_ID=FND_API.G_MISS_NUM THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_ITMINSTID_NULL');
    FND_MESSAGE.SET_TOKEN('RECORD',l_record_str,false);
    FND_MSG_PUB.ADD;
  ELSE
    OPEN  validate_item_instance(p_prd_workorder_rec.inventory_item_id, p_prd_workorder_rec.item_instance_id);
    FETCH validate_item_instance INTO l_instance_rec;
    IF    validate_item_instance%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_ITMINSTID_INVALID');
      FND_MESSAGE.SET_TOKEN('RECORD',l_record_str,false);
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE validate_item_instance;
  END IF;

  IF p_prd_workorder_rec.STATUS_CODE IS NULL OR
     p_prd_workorder_rec.STATUS_CODE=FND_API.G_MISS_CHAR THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_STATUS_CODE_INVALID');
    FND_MSG_PUB.ADD;
  ELSE
    OPEN get_lookup_type_code(p_prd_workorder_rec.STATUS_CODE,'AHL_JOB_STATUS');
    FETCH get_lookup_type_code INTO L_LOOKUP_CODE;
    IF get_lookup_type_code%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_STATUS_CODE_INVALID');
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE get_lookup_type_code;
  END IF;

  IF p_prd_workorder_rec.DML_OPERATION='U' THEN

    IF (p_prd_workorder_rec.actual_start_date  IS NULL OR
        p_prd_workorder_rec.actual_start_date=FND_API.G_MISS_DATE) AND
       (p_prd_workorder_rec.actual_end_date<>FND_API.G_MISS_DATE AND
        p_prd_workorder_rec.actual_end_date IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_ACTUAL_START_DT_NULL');
      FND_MESSAGE.SET_TOKEN('RECORD',l_record_str,false);
      FND_MSG_PUB.ADD;
    END IF;

    IF  p_prd_workorder_rec.actual_start_date IS NOT NULL AND
        p_prd_workorder_rec.actual_start_date<>FND_API.G_MISS_DATE AND
        p_prd_workorder_rec.actual_end_date<>FND_API.G_MISS_DATE AND
        p_prd_workorder_rec.actual_end_date IS NOT NULL AND
        p_prd_workorder_rec.actual_start_date > p_prd_workorder_rec.actual_end_date THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_ACTUAL_ST_GT_SCHD_DATE');
      FND_MSG_PUB.ADD;
    END IF;

    IF  p_prd_workorder_rec.actual_end_date<>FND_API.G_MISS_DATE AND
        p_prd_workorder_rec.actual_end_date IS NOT NULL AND
        TRUNC(p_prd_workorder_rec.actual_end_date) > TRUNC( SYSDATE )  THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_ACTUAL_END_GT_SYSDATE');
      FND_MSG_PUB.ADD;
    END IF;

    OPEN c_get_op_actual_dates(p_prd_workorder_rec.workorder_id);
    FETCH c_get_op_actual_dates INTO l_op_min_act_start_date, l_op_max_act_end_date;
    CLOSE c_get_op_actual_dates;

    IF ( p_prd_workorder_rec.actual_start_date IS NOT NULL AND
         p_prd_workorder_rec.actual_start_date <> FND_API.G_MISS_DATE AND
         l_op_min_act_start_date IS NOT NULL AND
         p_prd_workorder_rec.actual_start_date > l_op_min_act_start_date ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_OP_ST_DT' );
      FND_MSG_PUB.add;
    END IF;

    IF ( p_prd_workorder_rec.actual_end_date IS NOT NULL AND
         p_prd_workorder_rec.actual_end_date <> FND_API.G_MISS_DATE AND
         l_op_max_act_end_date IS NOT NULL AND
         p_prd_workorder_rec.actual_end_date < l_op_max_act_end_date ) THEN
       FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_WO_OP_END_DT' );
       FND_MSG_PUB.add;
    END IF;
    IF p_prd_workorder_rec.STATUS_CODE<> G_JOB_STATUS_RELEASED AND
       p_prd_workorder_rec.STATUS_CODE<> G_JOB_STATUS_UNRELEASED AND
       p_prd_workorder_rec.STATUS_CODE<> G_JOB_STATUS_COMPLETE AND
       p_prd_workorder_rec.STATUS_CODE<> G_JOB_STATUS_ON_HOLD AND
       p_prd_workorder_rec.STATUS_CODE<> G_JOB_STATUS_COMPLETE_NC AND
       p_prd_workorder_rec.STATUS_CODE<> G_JOB_STATUS_CLOSED AND
       p_prd_workorder_rec.STATUS_CODE<> G_JOB_STATUS_DRAFT AND
       p_prd_workorder_rec.STATUS_CODE<> G_JOB_STATUS_PARTS_HOLD AND
       p_prd_workorder_rec.STATUS_CODE<> G_JOB_STATUS_QA_PENDING AND
       p_prd_workorder_rec.STATUS_CODE<> G_JOB_STATUS_DEFERRAL_PENDING AND
       p_prd_workorder_rec.STATUS_CODE<> G_JOB_STATUS_DELETED AND
       p_prd_workorder_rec.STATUS_CODE<> G_JOB_STATUS_CANCELLED THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_STATUS_NOT_VALIDINMOD');
      FND_MSG_PUB.ADD;
    END IF;

    IF p_prd_workorder_rec.WORKORDER_ID IS NULL OR
       p_prd_workorder_rec.WORKORDER_ID=FND_API.G_MISS_NUM THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_WORKORDER_ID_NULL');
      FND_MSG_PUB.ADD;
    END IF;

    IF p_prd_workorder_rec.OBJECT_VERSION_NUMBER IS NULL OR
       p_prd_workorder_rec.OBJECT_VERSION_NUMBER=FND_API.G_MISS_NUM THEN
      FND_MESSAGE.SET_NAME('AHL','OBJ_CANNOT_B_NULL');
      FND_MSG_PUB.ADD;
    END IF;
-- apattark Commented to fix fp bug 8945432 . Validation not required for scheduled
-- start date.  Defer validation to EAM/WIP apis.
   /*
    SELECT COUNT(*)
    INTO   l_dummy_ctr
    FROM   ORG_ACCT_PERIODS
    WHERE  organization_id=p_prd_workorder_rec.organization_id
    AND    TRUNC(p_prd_workorder_rec.scheduled_start_date) BETWEEN
           TRUNC(period_start_date) AND TRUNC(NVL(schedule_CLOSE_date,SYSDATE+1));

    IF l_dummy_ctr=0 THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_SCHEDSDTACCTPERIODINV');
      FND_MSG_PUB.ADD;
    END IF;
 */
  ELSIF p_prd_workorder_rec.DML_OPERATION='C' THEN

    IF p_prd_workorder_rec.organization_id IS not NULL AND
       p_prd_workorder_rec.organization_id<>FND_API.G_MISS_NUM THEN
      OPEN  validate_project(p_prd_workorder_rec.organization_id);
      FETCH validate_project INTO l_dummy_ctr;
      IF validate_project%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_PRD_PROJECT_INVALID');
        FND_MESSAGE.SET_TOKEN('ORGID',l_record_str,false);
        FND_MESSAGE.SET_TOKEN('RECORD',l_record_str,false);
        FND_MSG_PUB.ADD;
      ELSIF p_prd_workorder_rec.Project_id  IS not NULL AND
            p_prd_workorder_rec.Project_id<>FND_API.G_MISS_NUM THEN

        -- replace MTL_PROJECT_V with PJM_PROJECTS_ORG_OU_SECURE_V for R12
        -- required for PJM MOAC changes.
        SELECT COUNT(*) INTO l_dummy_ctr
        --SELECT 1 INTO l_dummy_ctr
        -- FROM   MTL_PROJECT_V
        FROM PJM_PROJECTS_ORG_OU_SECURE_V
        WHERE  project_id=p_prd_workorder_rec.PROJECT_ID
          AND  org_id = mo_global.get_current_org_id()
          -- added following filter to fix bug# 8662561 (FP for 8630840)
          AND  inventory_organization_id = p_prd_workorder_rec.organization_id;

        IF l_dummy_ctr=0 THEN
          FND_MESSAGE.SET_NAME('AHL','AHL_PRD_project_id_invalid');
          FND_MESSAGE.SET_TOKEN('RECORD',l_record_str,false);
          FND_MSG_PUB.ADD;
        ELSIF l_dummy_ctr>0 THEN
          IF p_prd_workorder_rec.Project_task_id  IS not NULL AND
             p_prd_workorder_rec.Project_task_id<>FND_API.G_MISS_NUM THEN
            SELECT COUNT(*) INTO l_dummy_ctr
            --SELECT 1 INTO l_dummy_ctr
            FROM   pa_tasks
            WHERE  project_id=p_prd_workorder_rec.project_id
            AND    task_id=p_prd_workorder_rec.project_task_id;

            IF l_dummy_ctr=0 THEN
              FND_MESSAGE.SET_NAME('AHL','AHL_PRD_PROJECT_TASKID_INVALID');
              FND_MESSAGE.SET_TOKEN('RECORD',l_record_str,false);
              FND_MSG_PUB.ADD;
            END IF;
          END IF;
        END IF;
      END IF;
      CLOSE validate_project;
    END IF;

    IF ( p_prd_workorder_rec.Visit_id IS NULL OR
         p_prd_workorder_rec.Visit_id=FND_API.G_MISS_NUM ) THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_VISITID_NULL');
      FND_MESSAGE.SET_TOKEN('RECORD',l_record_str,false);
    END IF;

    IF ( p_prd_workorder_rec.Master_workorder_flag IS NULL OR
         p_prd_workorder_rec.Master_workorder_flag=FND_API.G_MISS_CHAR OR
         p_prd_workorder_rec.Master_workorder_flag NOT IN ( 'Y' , 'N' ) ) THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_MWOFLAG_INVALID');
      FND_MESSAGE.SET_TOKEN('RECORD',l_record_str,false);
    ELSIF ( ( p_prd_workorder_rec.Visit_task_id IS NULL OR
              p_prd_workorder_rec.Visit_task_id=FND_API.G_MISS_NUM ) AND
            p_prd_workorder_rec.Master_workorder_flag = 'N' ) THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_VISITASKID_NULL');
      FND_MESSAGE.SET_TOKEN('RECORD',l_record_str,false);
      FND_MSG_PUB.ADD;
    END IF;

    IF ( p_prd_workorder_rec.Visit_task_id IS NOT NULL AND
         p_prd_workorder_rec.Visit_task_id<>FND_API.G_MISS_NUM ) THEN

      SELECT COUNT(*)
      INTO   l_dummy_ctr
      FROM   AHL_WORKORDERS
      WHERE  visit_task_id=NVL(p_prd_workorder_rec.visit_task_id,0)
      AND    LTRIM(RTRIM(status_code)) NOT IN ( G_JOB_STATUS_CANCELLED, G_JOB_STATUS_DELETED );

      IF l_dummy_ctr >0 THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_PRD_INVAL_CREATE_WORKORDER');
        FND_MESSAGE.SET_TOKEN('RECORD',l_record_str,false);
        FND_MSG_PUB.ADD;
        RETURN;
      END IF;

      SELECT COUNT(*)
      INTO   l_dummy_ctr
      FROM   AHL_VISIT_TASKS_B
      WHERE  visit_task_id=p_prd_workorder_rec.visit_task_id;

      IF l_dummy_ctr=0 THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_PRD_visit_task_invalid');
        FND_MSG_PUB.ADD;
      END IF;

    END IF;

    IF p_prd_workorder_rec.completion_subinventory IS NOT NULL AND
       p_prd_workorder_rec.COMPLETION_SUBINVENTORY<>FND_API.G_MISS_CHAR THEN
      OPEN  validate_subinventory(p_prd_workorder_rec.organization_id, p_prd_workorder_rec.Completion_subinventory);
      FETCH validate_subinventory INTO l_subinv_rec;
      IF validate_subinventory%FOUND AND
         NVL(l_subinv_rec.eam_enabled_flag,'x')='N' THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_PRD_COMPLSUBINV_INVALID');
        FND_MSG_PUB.ADD;
      ELSIF validate_subinventory%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_PRD_COMPLSUBINV_INVALID');
        FND_MSG_PUB.ADD;
      END IF;
      CLOSE validate_subinventory;
    END IF;

    IF p_prd_workorder_rec.Completion_locator_id IS not NULL AND
       p_prd_workorder_rec.Completion_locator_id<>FND_API.G_MISS_CHAR THEN
      SELECT COUNT(*)
      INTO   l_dummy_ctr
      FROM   MTL_ITEM_LOCATIONS
      WHERE inventory_location_id=p_prd_workorder_rec.completion_locator_id;
      IF l_dummy_ctr =0 THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_PRD_COMPLSUBINV_INVALID');
        FND_MSG_PUB.ADD;
      END IF;
    END IF;

    IF p_prd_workorder_rec.Firm_planned_flag  IS NULL OR
       p_prd_workorder_rec.Completion_locator_id=FND_API.G_MISS_NUM THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_FIRM_PLANNED_FLAG_NULL');
      FND_MSG_PUB.ADD;
    ELSIF p_prd_workorder_rec.Firm_planned_flag <1 AND
          p_prd_workorder_rec.Firm_planned_flag >2 THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_FIRM_PLANNED_FLAG_INV');
      FND_MSG_PUB.ADD;
    END IF;

    IF p_prd_workorder_rec.mr_route_id IS not NULL OR
       p_prd_workorder_rec.mr_route_id<>FND_API.G_MISS_NUM THEN
      SELECT COUNT(*)
      INTO   l_dummy_ctr
      FROM   AHL_MR_ROUTES_V   -- Chnaged from AHL_MR_ROUTES to be Application Usage complaint.
      WHERE  mr_route_id=p_prd_workorder_rec.mr_route_id;

      IF NVL(l_dummy_ctr,0)>1 OR NVL(l_dummy_ctr,0)=0 THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_PRD_MR_ROUTE_ID_INVLD');
        FND_MSG_PUB.ADD;
      END IF;
    END IF;

    IF p_prd_workorder_rec.ITEM_INSTANCE_ID IS NULL OR
       p_prd_workorder_rec.ITEM_INSTANCE_ID=FND_API.G_MISS_NUM THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_INSTANCE_ID_NULL');
      FND_MSG_PUB.ADD;
    ELSE
      SELECT COUNT(a.instance_id)
      INTO   l_dummy_ctr
      FROM   CSI_ITEM_INSTANCES  a,
             MTL_SYSTEM_ITEMS b
      WHERE  a.instance_id=p_prd_workorder_rec.item_instance_id
      AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(a.active_start_date,SYSDATE))
                            AND TRUNC(NVL(a.active_end_date,SYSDATE+1))
      AND    a.inventory_item_id=b.inventory_item_id;

      IF NVL(l_dummy_ctr,0)=0 THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_PRD_INVITEM_NOTACTIVE');
        FND_MSG_PUB.ADD;
      END IF;
    END IF;

    IF p_prd_workorder_rec.INVENTORY_ITEM_ID IS NULL OR
       p_prd_workorder_rec.INVENTORY_ITEM_ID=FND_API.G_MISS_NUM THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_INV_ITEM_ID_NULL');
      FND_MSG_PUB.ADD;
    END IF;

  END IF;

  -- nsikka: ER 5846702
  IF p_prd_workorder_rec.hold_reason_code IS NOT NULL AND
     p_prd_workorder_rec.hold_reason_code<>FND_API.G_MISS_CHAR THEN
       OPEN validate_hold_reason_code_csr(p_prd_workorder_rec.hold_reason_code);
        FETCH validate_hold_reason_code_csr INTO l_dummy_ctr;
        IF validate_hold_reason_code_csr%NOTFOUND THEN
          FND_MESSAGE.SET_NAME('AHL','AHL_PP_REASON_INVALID');
          FND_MSG_PUB.ADD;
        END IF;
        CLOSE validate_hold_reason_code_csr;
  END IF;

  IF (p_prd_workorder_rec.status_code = '6' OR p_prd_workorder_rec.status_code = '19' )
      AND p_prd_workorder_rec.hold_reason_code IS NULL THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_PP_REASON_NULL');
        FND_MSG_PUB.ADD;
  END IF;

END validate_workorder;

-- Added for FP bug# 7238868.
PROCEDURE get_Resource_Dept(p_aso_resource_id   IN NUMBER,
                            p_organization_id   IN NUMBER,
                            p_aso_resc_name     IN VARCHAR2,
                            x_department_id     OUT NOCOPY NUMBER,
                            x_department_name   OUT NOCOPY VARCHAR2,
                            x_return_status     OUT NOCOPY VARCHAR2)
IS

-- find out dept. level resource if exists.
CURSOR get_res_dept_csr (p_aso_resource_id   IN NUMBER,
                         p_org_id            IN NUMBER)
IS
  SELECT DISTINCT MAP.department_id, DEPT.description
  FROM   BOM_DEPARTMENT_RESOURCES BD, AHL_RESOURCE_MAPPINGS MAP,
         BOM_RESOURCES BR, BOM_DEPARTMENTS DEPT
  WHERE  BD.resource_id = MAP.bom_resource_id
  AND    BR.resource_id = BD.resource_id
  AND    BR.organization_id = p_org_id
  AND    MAP.aso_resource_id = p_aso_resource_id
  AND    MAP.BOM_org_id = p_org_id
  AND    MAP.department_id = BD.department_id
  AND    BD.department_id = dept.department_id;

l_department_id  NUMBER;
l_department_name bom_departments.description%TYPE;


BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_department_id := NULL;

  OPEN get_res_dept_csr (p_aso_resource_id, p_organization_id);
  FETCH get_res_dept_csr  INTO l_department_id, l_department_name;
  IF (get_res_dept_csr%FOUND) THEN
      x_department_id := l_department_id;
      --x_department_name:= l_department_name;
  END IF;

  -- check if another record exists.
  FETCH get_res_dept_csr  INTO l_department_id, l_department_name;
  IF (get_res_dept_csr%FOUND) THEN
     -- raise error
     FND_MESSAGE.set_name('AHL','AHL_DUPLICATE_DEPT_FOUND');
     FND_MESSAGE.set_token('DESC',p_aso_resc_name);
     FND_MSG_PUB.add;
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  CLOSE get_res_dept_csr;

END get_Resource_Dept;


-- Added for FP bug# 7238868.
PROCEDURE Get_Default_Rt_Op_dept(p_object_id in number,
                                 p_association_type in varchar2,
                                 p_organization_id  in number,
                                 x_return_status    out nocopy varchar2,
                                 x_department_id    out nocopy number,
                                 x_department_name  out nocopy varchar2,
                                 x_object_resource_found out nocopy varchar2)
IS

  -- For Getting Resource Requirements defined for Route or Operation
  CURSOR get_rt_oper_resources(c_object_id NUMBER,
                               c_association_type VARCHAR2)
  IS
  SELECT AR.rt_oper_resource_id,
         AR.aso_resource_id,
         ART.name
  FROM   AHL_RT_OPER_RESOURCES AR, AHL_RESOURCES ART
  WHERE  AR.aso_resource_id = ART.resource_id
  AND    AR.association_type_code=p_association_type
  AND    AR.object_id=p_object_id;


l_rt_oper_resource_rec  get_rt_oper_resources%ROWTYPE;
l_return_status         varchar2(1);
l_final_department_id   NUMBER;
l_final_department_name bom_departments.description%TYPE;
l_department_id         NUMBER;
l_department_name       bom_departments.description%TYPE;


BEGIN

     IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( 'Get_Default_Rt_Op_dept-'|| 'p_object_id:' || p_object_id );
        AHL_DEBUG_PUB.debug( 'Get_Default_Rt_Op_dept-'|| 'p_association_type:' || p_association_type);
        AHL_DEBUG_PUB.debug( 'Get_Default_Rt_Op_dept-'|| 'p_organization_id:' || p_organization_id);
     END IF;

     l_final_department_id := NULL;
     x_object_resource_found := 'N';

     OPEN get_rt_oper_resources( p_object_id, p_association_type);
     LOOP
       FETCH get_rt_oper_resources INTO l_rt_oper_resource_rec;
       EXIT WHEN get_rt_oper_resources%NOTFOUND;

       IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( 'Get_Default_Rt_Op_dept-'|| 'Found Route/Oper Res:' || l_rt_oper_resource_rec.aso_resource_id );
          AHL_DEBUG_PUB.debug( 'Get_Default_Rt_Op_dept-'|| 'Resource Name:' || l_rt_oper_resource_rec.name);
       END IF;

       -- Atleast one Resource Requirement Found for the Route
       x_object_resource_found := 'Y';

       -- Derive Dept from ASO Resource setup.
       get_Resource_Dept(l_rt_oper_resource_rec.aso_resource_id,
                         p_organization_id,
                         l_rt_oper_resource_rec.name,
                         l_department_id,
                         l_department_name,
                         l_return_status);
       IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( 'Get_Default_Rt_Op_dept-'|| 'l_return_status:' || l_return_status );
          AHL_DEBUG_PUB.debug( 'Get_Default_Rt_Op_dept-'|| 'l_department_id:' || l_department_id);
          AHL_DEBUG_PUB.debug( 'Get_Default_Rt_Op_dept-'|| 'l_department_name:' || l_department_name);
          AHL_DEBUG_PUB.debug( 'Get_Default_Rt_Op_dept-'|| 'l_final_department_id:' || l_final_department_id);
       END IF;

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (l_department_id IS NOT NULL) THEN
          IF (l_final_department_id IS NULL) THEN
             l_final_department_id := l_department_id;
             l_final_department_name := l_department_name;
          ELSIF (l_department_id <> l_final_department_id) THEN
             -- raise error.
             x_return_status := FND_API.G_RET_STS_ERROR;
             EXIT;
          END IF;
          l_department_id := NULL;
          l_department_name := NULL;
       END IF;

     END LOOP;

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- only one unique dept. may be found.
     -- or no dept level resource found.

     IF (l_final_department_id IS NOT NULL) THEN
        x_department_id := l_final_department_id;
        x_department_name := l_final_department_name;
     ELSE
        x_department_id := NULL;
        x_department_name := NULL;
     END IF;

END Get_Default_Rt_Op_dept;


PROCEDURE get_op_resource_req
(
  p_workorder_rec  IN            prd_workorder_rec,
  p_operation_tbl  IN            AHL_PRD_OPERATIONS_PVT.prd_operation_tbl,
  p_x_resource_tbl IN OUT NOCOPY AHL_PP_RESRC_REQUIRE_PVT.resrc_require_tbl_type
)
AS

  -- For Getting Resource Requirements defined for Operation
  -- For Getting Resource Requirements defined for Route or Operation
  -- JKJAIN US space FP 7644260 for ER # 6998882 -- start
  -- added schedule_seq_num to the query.
  CURSOR get_oper_resources(c_operation_id NUMBER)
  IS
  SELECT AR.rt_oper_resource_id,
         AR.aso_resource_id,
        (AR.duration * AR.quantity ) duration, --Modified by Srini for Costing ER
         AR.quantity,
         AR.activity_id,
         AR.cost_basis_id,
         AR.scheduled_type_id,
         AR.autocharge_type_id,
         AR.standard_rate_flag,
		 AR.schedule_seq
  FROM   AHL_RT_OPER_RESOURCES AR
  WHERE  AR.association_type_code='OPERATION'
  AND    AR.object_id=c_operation_id;
-- JKJAIN US space FP 7644260 for ER # 6998882 -- end
  l_oper_resource_rec  get_oper_resources%ROWTYPE;

  -- For Getting Alternate Resources for a Resource Requirement
  CURSOR   get_alternate_aso_resources(c_rt_oper_resource_id NUMBER)
  IS
  SELECT   aso_resource_id
  FROM     AHL_ALTERNATE_RESOURCES
  WHERE    rt_oper_resource_id=c_rt_oper_resource_id
  ORDER BY priority;

  -- For Getting the BOM Resource for the ASO Resource and the Visit's
  -- Organization plus Visit Task's Department
  CURSOR get_bom_resource(c_aso_resource_id NUMBER,
                          c_org_id NUMBER,
                          c_dept_id NUMBER)
  IS
  SELECT BR.resource_id,
         BR.resource_code,
         BR.resource_type,
         BR.description,
         BR.unit_of_measure
  FROM   BOM_DEPARTMENT_RESOURCES BDR,
         BOM_RESOURCES BR,
         AHL_RESOURCE_MAPPINGS MAP
  WHERE  BDR.department_id=c_dept_id
  AND    BDR.resource_id=BR.resource_id
  AND    BR.organization_id=c_org_id
  AND    BR.resource_id=MAP.bom_resource_id
  AND    MAP.aso_resource_id=c_aso_resource_id;

  l_bom_resource_rec     get_bom_resource%ROWTYPE;

  l_res_ctr              NUMBER := 0;
  l_res_seq_num          NUMBER := 0;
  l_bom_resource_found   BOOLEAN := FALSE;

 -- cursor for getting task quantity for a given workorder
 -- Begin OGMA Issue # 105 - Balaji
 CURSOR c_get_task_quantity(p_workorder_id NUMBER)
 IS
 SELECT
   nvl(vtsk.quantity, 1)
 FROM
   ahl_visit_tasks_b vtsk,
   ahl_workorders awo
 WHERE
   vtsk.visit_task_id = awo.visit_task_id AND
   awo.workorder_id = p_workorder_id;

 l_task_quantity NUMBER;
-- End OGMA Issue # 105 - Balaji

BEGIN

  -- Process the the Resource Requirements defined for the Operations
  FOR i in p_operation_tbl.FIRST..p_operation_tbl.LAST LOOP

    IF ( p_operation_tbl(i).dml_operation = 'C' AND
         p_operation_tbl(i).operation_id IS NOT NULL AND
         p_operation_tbl(i).operation_id <> FND_API.G_MISS_NUM ) THEN

      -- Get the Resource Requirements defined for the Operation
      OPEN get_oper_resources( p_operation_tbl(i).operation_id );
      LOOP
        FETCH get_oper_resources INTO l_oper_resource_rec;
        EXIT WHEN get_oper_resources%NOTFOUND;

        -- Get the BOM Resource for the ASO Resource and the Visit's
        -- Organization plus Visit Task's Department
        OPEN get_bom_resource( l_oper_resource_rec.aso_resource_id, p_operation_tbl(i).organization_id, p_operation_tbl(i).department_id );
        FETCH get_bom_resource INTO l_bom_resource_rec;
        IF ( get_bom_resource%FOUND ) THEN
          CLOSE get_bom_resource;

          -- BOM Resource Found
          l_bom_resource_found := TRUE;
        ELSE
          CLOSE get_bom_resource;

          -- Since Primary Resource is not Found, Get the Alternate Resources
          -- defined for the Resource Requirement
          FOR alt_res_cursor IN get_alternate_aso_resources( l_oper_resource_rec.rt_oper_resource_id ) LOOP

            -- Get the BOM Resource for the Alternate ASO Resource and the
            -- Visit's Organization plus Visit Task's Department
            OPEN get_bom_resource( alt_res_cursor.aso_resource_id, p_operation_tbl(i).organization_id, p_operation_tbl(i).department_id );
            FETCH get_bom_resource INTO l_bom_resource_rec;
            IF ( get_bom_resource%FOUND ) THEN
              CLOSE get_bom_resource;

              -- BOM Resource Found
              l_bom_resource_found := TRUE;
              EXIT;
            END IF;
            CLOSE get_bom_resource;
          END LOOP;
        END IF;

        -- If a BOM Resource is Found for the Resource Requirement, then,
        -- Add the Resource Requirement to the Corresponding Operation
        IF ( l_bom_resource_found = TRUE ) THEN
          l_res_seq_num := l_res_seq_num + 10;
          l_res_ctr := l_res_ctr + 1;
          l_bom_resource_found := FALSE;

          p_x_resource_tbl(l_res_ctr).operation_resource_id    :=NULL;
          p_x_resource_tbl(l_res_ctr).resource_seq_number      :=l_res_seq_num;
          p_x_resource_tbl(l_res_ctr).operation_seq_number     :=p_operation_tbl(i).operation_sequence_num;
          p_x_resource_tbl(l_res_ctr).workorder_operation_id   :=p_operation_tbl(i).workorder_operation_id;
          p_x_resource_tbl(l_res_ctr).workorder_id             :=p_workorder_rec.workorder_id;
          p_x_resource_tbl(l_res_ctr).wip_entity_id            :=p_workorder_rec.wip_entity_id;
          p_x_resource_tbl(l_res_ctr).organization_id          :=p_workorder_rec.organization_id;
          p_x_resource_tbl(l_res_ctr).department_id            :=p_operation_tbl(i).department_id;
          p_x_resource_tbl(l_res_ctr).department_name          :=p_operation_tbl(i).department_name;
          p_x_resource_tbl(l_res_ctr).oper_start_date          :=p_operation_tbl(i).scheduled_start_date;
          p_x_resource_tbl(l_res_ctr).oper_end_date            :=p_operation_tbl(i).scheduled_end_date;
          p_x_resource_tbl(l_res_ctr).req_start_date           :=p_operation_tbl(i).scheduled_start_date;
          p_x_resource_tbl(l_res_ctr).req_end_date             :=p_operation_tbl(i).scheduled_end_date;
          p_x_resource_tbl(l_res_ctr).resource_type_code       :=l_bom_resource_rec.resource_type;
          p_x_resource_tbl(l_res_ctr).resource_id              :=l_bom_resource_rec.resource_id;
          p_x_resource_tbl(l_res_ctr).uom_code                 :=l_bom_resource_rec.unit_of_measure;
          -- Begin OGMA Issue # 105 - Balaji
          p_x_resource_tbl(l_res_ctr).duration                 := l_oper_resource_rec.duration;
          IF l_oper_resource_rec.cost_basis_id IS NOT NULL AND
             l_oper_resource_rec.cost_basis_id = 1
          THEN

                OPEN c_get_task_quantity(p_workorder_rec.workorder_id);
                FETCH c_get_task_quantity INTO l_task_quantity;
                CLOSE c_get_task_quantity;

                p_x_resource_tbl(l_res_ctr).duration                 := p_x_resource_tbl(l_res_ctr).duration * l_task_quantity;

          END IF;
          -- End OGMA Issue # 105 - Balaji
          --p_x_resource_tbl(l_res_ctr).duration                 :=l_oper_resource_rec.duration;
          p_x_resource_tbl(l_res_ctr).quantity                 :=l_oper_resource_rec.quantity;
          p_x_resource_tbl(l_res_ctr).cost_basis_code          :=l_oper_resource_rec.cost_basis_id;
          p_x_resource_tbl(l_res_ctr).charge_type_code         :=l_oper_resource_rec.autocharge_type_id;
          p_x_resource_tbl(l_res_ctr).std_rate_flag_code       :=l_oper_resource_rec.standard_rate_flag;
          p_x_resource_tbl(l_res_ctr).scheduled_type_code      :=l_oper_resource_rec.scheduled_type_id;
--JKJAIN US space FP for ER # 6998882 -- start
 	           p_x_resource_tbl(l_res_ctr).schedule_seq_num         :=l_oper_resource_rec.schedule_seq;
--JKJAIN US space FP for ER # 6998882 -- end
          --p_x_resource_tbl(l_res_ctr).activity_code          :=l_oper_resource_rec.activity_id;
          p_x_resource_tbl(l_res_ctr).operation_flag         :='C';
        END IF;
      END LOOP;
      CLOSE get_oper_resources;
    END IF;
  END LOOP;

END get_op_resource_req;

PROCEDURE get_rt_resource_req
(
  p_workorder_rec  IN            prd_workorder_rec,
  p_operation_tbl  IN            AHL_PRD_OPERATIONS_PVT.prd_operation_tbl,
  p_x_resource_tbl IN OUT NOCOPY AHL_PP_RESRC_REQUIRE_PVT.resrc_require_tbl_type
)
AS

  -- For Getting Resource Requirements defined for Route or Operation
  -- JKJAIN US space FP 7644260 for ER # 6998882-- start
  -- added schedule_seq_num to the query.
  CURSOR get_rt_oper_resources(c_object_id NUMBER,
                           c_association_type VARCHAR2)
  IS
  SELECT AR.rt_oper_resource_id,
         AR.aso_resource_id,
        (AR.duration * AR.quantity ) duration,
         AR.quantity,
         AR.activity_id,
         AR.cost_basis_id,
         AR.scheduled_type_id,
         AR.autocharge_type_id,
         AR.standard_rate_flag,
		  AR.schedule_seq
  FROM   AHL_RT_OPER_RESOURCES AR
  WHERE  AR.association_type_code=c_association_type
  AND    AR.object_id=c_object_id;
 -- JKJAIN US space FP 7644260 for ER # 6998882 -- end
  l_rt_oper_resource_rec  get_rt_oper_resources%ROWTYPE;

  -- For Getting Alternate Resources for a Resource Requirement
  CURSOR   get_alternate_aso_resources(c_rt_oper_resource_id NUMBER)
  IS
  SELECT   aso_resource_id
  FROM     AHL_ALTERNATE_RESOURCES
  WHERE    rt_oper_resource_id=c_rt_oper_resource_id
  ORDER BY priority;

  -- For Getting the BOM Resource for the ASO Resource and the Visit's
  -- Organization plus Visit Task's Department
  CURSOR get_bom_resource(c_aso_resource_id NUMBER,
                          c_org_id NUMBER,
                          c_dept_id NUMBER)
  IS
  SELECT BR.resource_id,
         BR.resource_code,
         BR.resource_type,
         BR.description,
         BR.unit_of_measure
  FROM   BOM_DEPARTMENT_RESOURCES BDR,
         BOM_RESOURCES BR,
         AHL_RESOURCE_MAPPINGS MAP
  WHERE  BDR.department_id=c_dept_id
  AND    BDR.resource_id=BR.resource_id
  AND    BR.organization_id=c_org_id
  AND    BR.resource_id=MAP.bom_resource_id
  AND    MAP.aso_resource_id=c_aso_resource_id;

  l_bom_resource_rec     get_bom_resource%ROWTYPE;

  l_res_ctr              NUMBER := 0;
  l_res_seq_num          NUMBER := 0;
  l_bom_resource_found   BOOLEAN := FALSE;
  l_route_resource_found BOOLEAN := FALSE;

 -- cursor for getting task quantity for a given workorder
 -- Begin OGMA Issue # 105 - Balaji
 CURSOR c_get_task_quantity(p_workorder_id NUMBER)
 IS
 SELECT
   nvl(vtsk.quantity, 1)
 FROM
   ahl_visit_tasks_b vtsk,
   ahl_workorders awo
 WHERE
   vtsk.visit_task_id = awo.visit_task_id AND
   awo.workorder_id = p_workorder_id;

 l_task_quantity NUMBER;
-- End OGMA Issue # 105 - Balaji

BEGIN

  -- Get the Resource Requirements defined for the Route
  OPEN get_rt_oper_resources( p_workorder_rec.route_id, 'ROUTE' );
  LOOP
    FETCH get_rt_oper_resources INTO l_rt_oper_resource_rec;
    EXIT WHEN get_rt_oper_resources%NOTFOUND;

    -- Atleast one Resource Requirement Found for the Route
    l_route_resource_found := TRUE;

    -- Get the BOM Resource for the ASO Resource and the Visit's
    -- Organization plus Visit Task's Department
    --OPEN get_bom_resource( l_rt_oper_resource_rec.aso_resource_id, p_workorder_rec.organization_id, p_workorder_rec.department_id );
    OPEN get_bom_resource( l_rt_oper_resource_rec.aso_resource_id, p_workorder_rec.organization_id, p_operation_tbl(p_operation_tbl.FIRST).department_id );
    FETCH get_bom_resource INTO l_bom_resource_rec;
    IF ( get_bom_resource%FOUND ) THEN
      CLOSE get_bom_resource;

      -- BOM Resource Found
      l_bom_resource_found := TRUE;
    ELSE
      CLOSE get_bom_resource;

      -- Since Primary Resource is not Found, Get the Alternate Resources
      -- defined for the Resource Requirement
      FOR alt_res_cursor IN get_alternate_aso_resources( l_rt_oper_resource_rec.rt_oper_resource_id ) LOOP

        -- Get the BOM Resource for the Alternate ASO Resource and the Visit's
        -- Organization plus Visit Task's Department
        --OPEN get_bom_resource( alt_res_cursor.aso_resource_id, p_workorder_rec.organization_id, p_workorder_rec.department_id );
        OPEN get_bom_resource( alt_res_cursor.aso_resource_id, p_workorder_rec.organization_id, p_operation_tbl(p_operation_tbl.FIRST).department_id);
        FETCH get_bom_resource INTO l_bom_resource_rec;
        IF ( get_bom_resource%FOUND ) THEN
          CLOSE get_bom_resource;

          -- BOM Resource Found
          l_bom_resource_found := TRUE;
          EXIT;
        END IF;
        CLOSE get_bom_resource;
      END LOOP;
    END IF;

    -- If a BOM Resource is Found for the Resource Requirement, then,
    -- Add the Job Resource Requirement to the First Operation
    IF ( l_bom_resource_found = TRUE ) THEN
      l_res_seq_num := l_res_seq_num + 10;
      l_res_ctr := l_res_ctr + 1;
      l_bom_resource_found := FALSE;

      p_x_resource_tbl(l_res_ctr).operation_resource_id    :=NULL;
      p_x_resource_tbl(l_res_ctr).resource_seq_number      :=l_res_seq_num;
      p_x_resource_tbl(l_res_ctr).operation_seq_number     :=p_operation_tbl(p_operation_tbl.FIRST).operation_sequence_num;
      p_x_resource_tbl(l_res_ctr).workorder_operation_id   :=p_operation_tbl(p_operation_tbl.FIRST).workorder_operation_id;
      p_x_resource_tbl(l_res_ctr).workorder_id             :=p_workorder_rec.workorder_id;
      p_x_resource_tbl(l_res_ctr).organization_id          :=p_workorder_rec.organization_id;
      -- Default from operation -- FP bug# 7238868
      --p_x_resource_tbl(l_res_ctr).department_id            :=p_workorder_rec.department_id;
      --p_x_resource_tbl(l_res_ctr).department_name          :=p_workorder_rec.department_name;
      p_x_resource_tbl(l_res_ctr).department_id            :=p_operation_tbl(p_operation_tbl.FIRST).department_id;
      p_x_resource_tbl(l_res_ctr).department_name          :=p_operation_tbl(p_operation_tbl.FIRST).department_name;

      p_x_resource_tbl(l_res_ctr).oper_start_date          :=p_workorder_rec.scheduled_start_date;
      p_x_resource_tbl(l_res_ctr).oper_end_date            :=p_workorder_rec.scheduled_end_date;
      p_x_resource_tbl(l_res_ctr).req_start_date           :=p_workorder_rec.scheduled_start_date;
      p_x_resource_tbl(l_res_ctr).req_end_date             :=p_workorder_rec.scheduled_end_date;
      p_x_resource_tbl(l_res_ctr).resource_type_code       :=l_bom_resource_rec.resource_type;
      p_x_resource_tbl(l_res_ctr).resource_id              :=l_bom_resource_rec.resource_id;
      p_x_resource_tbl(l_res_ctr).uom_code                 :=l_bom_resource_rec.unit_of_measure;
      p_x_resource_tbl(l_res_ctr).duration                 :=l_rt_oper_resource_rec.duration;
      -- Begin OGMA Issue # 105 - Balaji
      IF l_rt_oper_resource_rec.cost_basis_id IS NOT NULL AND
         l_rt_oper_resource_rec.cost_basis_id = 1
      THEN

        OPEN c_get_task_quantity(p_workorder_rec.workorder_id);
        FETCH c_get_task_quantity INTO l_task_quantity;
        CLOSE c_get_task_quantity;

        p_x_resource_tbl(l_res_ctr).duration                 :=p_x_resource_tbl(l_res_ctr).duration * l_task_quantity;

      END IF;
      -- End OGMA Issue # 105 - Balaji
      p_x_resource_tbl(l_res_ctr).quantity                 :=l_rt_oper_resource_rec.quantity;
      p_x_resource_tbl(l_res_ctr).cost_basis_code          :=l_rt_oper_resource_rec.cost_basis_id;
      p_x_resource_tbl(l_res_ctr).charge_type_code         :=l_rt_oper_resource_rec.autocharge_type_id;
      p_x_resource_tbl(l_res_ctr).std_rate_flag_code       :=l_rt_oper_resource_rec.standard_rate_flag;
      p_x_resource_tbl(l_res_ctr).scheduled_type_code      :=l_rt_oper_resource_rec.scheduled_type_id;
 -- JKJAIN US space FP for ER # 6998882 -- start
 	  p_x_resource_tbl(l_res_ctr).schedule_seq_num         :=l_rt_oper_resource_rec.schedule_seq;
 -- JKJAIN US space FP for ER # 6998882 -- end
     --p_x_resource_tbl(l_res_ctr).activity_code          :=l_rt_oper_resource_rec.activity_id;
      p_x_resource_tbl(l_res_ctr).operation_flag           :='C';
    END IF;
  END LOOP;
  CLOSE get_rt_oper_resources;

  -- If the Route has no Resource Requirement defined, then, process the
  -- the Resource Requirements defined for the Associated Operations
  IF ( l_route_resource_found = FALSE ) THEN

    FOR i in p_operation_tbl.FIRST..p_operation_tbl.LAST LOOP
      l_res_seq_num := 0;

      -- Get the Resource Requirements defined for the Operation
      OPEN get_rt_oper_resources( p_operation_tbl(i).operation_id, 'OPERATION' );
      LOOP
        FETCH get_rt_oper_resources INTO l_rt_oper_resource_rec;
        EXIT WHEN get_rt_oper_resources%NOTFOUND;

        -- Get the BOM Resource for the ASO Resource and the Visit's
        -- Organization plus Visit Task's Department
        --OPEN get_bom_resource( l_rt_oper_resource_rec.aso_resource_id, p_workorder_rec.organization_id, p_workorder_rec.department_id );
        OPEN get_bom_resource( l_rt_oper_resource_rec.aso_resource_id, p_workorder_rec.organization_id, p_operation_tbl(i).department_id );
        FETCH get_bom_resource INTO l_bom_resource_rec;
        IF ( get_bom_resource%FOUND ) THEN
          CLOSE get_bom_resource;

          -- BOM Resource Found
          l_bom_resource_found := TRUE;
        ELSE
          CLOSE get_bom_resource;

          -- Since Primary Resource is not Found, Get the Alternate Resources
          -- defined for the Resource Requirement
          FOR alt_res_cursor IN get_alternate_aso_resources( l_rt_oper_resource_rec.rt_oper_resource_id ) LOOP

            -- Get the BOM Resource for the Alternate ASO Resource and the
            -- Visit's Organization plus Visit Task's Department
            --OPEN get_bom_resource( alt_res_cursor.aso_resource_id, p_workorder_rec.organization_id, p_workorder_rec.department_id );
            OPEN get_bom_resource( alt_res_cursor.aso_resource_id, p_workorder_rec.organization_id, p_operation_tbl(i).department_id );
            FETCH get_bom_resource INTO l_bom_resource_rec;
            IF ( get_bom_resource%FOUND ) THEN
              CLOSE get_bom_resource;

              -- BOM Resource Found
              l_bom_resource_found := TRUE;
              EXIT;
            END IF;
            CLOSE get_bom_resource;
          END LOOP;
        END IF;

        -- If a BOM Resource is Found for the Resource Requirement, then,
        -- Add the Resource Requirement to the Corresponding Operation
        IF ( l_bom_resource_found = TRUE ) THEN
          l_res_seq_num := l_res_seq_num + 10;
          l_res_ctr := l_res_ctr + 1;
          l_bom_resource_found := FALSE;

          p_x_resource_tbl(l_res_ctr).operation_resource_id    :=NULL;
          p_x_resource_tbl(l_res_ctr).resource_seq_number      :=l_res_seq_num;
          p_x_resource_tbl(l_res_ctr).operation_seq_number     :=p_operation_tbl(i).operation_sequence_num;
          p_x_resource_tbl(l_res_ctr).workorder_operation_id   :=p_operation_tbl(i).workorder_operation_id;
          p_x_resource_tbl(l_res_ctr).workorder_id             :=p_workorder_rec.workorder_id;
          p_x_resource_tbl(l_res_ctr).organization_id          :=p_workorder_rec.organization_id;
          -- Default from Operation - FP bug# 7238868
          --p_x_resource_tbl(l_res_ctr).department_id            :=p_workorder_rec.department_id;
          --p_x_resource_tbl(l_res_ctr).department_name          :=p_workorder_rec.department_name;
          p_x_resource_tbl(l_res_ctr).department_id            :=p_operation_tbl(i).department_id;
          p_x_resource_tbl(l_res_ctr).department_name          :=p_operation_tbl(i).department_name;

          p_x_resource_tbl(l_res_ctr).oper_start_date          :=p_operation_tbl(i).scheduled_start_date;
          p_x_resource_tbl(l_res_ctr).oper_end_date            :=p_operation_tbl(i).scheduled_end_date;
          p_x_resource_tbl(l_res_ctr).req_start_date           :=p_operation_tbl(i).scheduled_start_date;
          p_x_resource_tbl(l_res_ctr).req_end_date             :=p_operation_tbl(i).scheduled_end_date;
          p_x_resource_tbl(l_res_ctr).resource_type_code       :=l_bom_resource_rec.resource_type;
          p_x_resource_tbl(l_res_ctr).resource_id              :=l_bom_resource_rec.resource_id;
          p_x_resource_tbl(l_res_ctr).uom_code                 :=l_bom_resource_rec.unit_of_measure;
          p_x_resource_tbl(l_res_ctr).duration                 :=l_rt_oper_resource_rec.duration;
          -- Begin OGMA Issue # 105 - Balaji
          IF l_rt_oper_resource_rec.cost_basis_id IS NOT NULL AND
             l_rt_oper_resource_rec.cost_basis_id = 1
          THEN

             OPEN c_get_task_quantity(p_workorder_rec.workorder_id);
             FETCH c_get_task_quantity INTO l_task_quantity;
             CLOSE c_get_task_quantity;

             p_x_resource_tbl(l_res_ctr).duration              :=p_x_resource_tbl(l_res_ctr).duration * l_task_quantity;

          END IF;
          -- End OGMA Issue # 105 - Balaji
          p_x_resource_tbl(l_res_ctr).quantity                 :=l_rt_oper_resource_rec.quantity;
          p_x_resource_tbl(l_res_ctr).cost_basis_code          :=l_rt_oper_resource_rec.cost_basis_id;
          p_x_resource_tbl(l_res_ctr).charge_type_code         :=l_rt_oper_resource_rec.autocharge_type_id;
          p_x_resource_tbl(l_res_ctr).std_rate_flag_code       :=l_rt_oper_resource_rec.standard_rate_flag;
          p_x_resource_tbl(l_res_ctr).scheduled_type_code      :=l_rt_oper_resource_rec.scheduled_type_id;
 -- JKJAIN US space FP for ER # 6998882 -- start
 	      p_x_resource_tbl(l_res_ctr).schedule_seq_num      :=l_rt_oper_resource_rec.schedule_seq;
 -- JKJAIN US space FP for ER # 6998882 -- end
          --p_x_resource_tbl(l_res_ctr).activity_code          :=l_rt_oper_resource_rec.activity_id;
          p_x_resource_tbl(l_res_ctr).operation_flag         :='C';
        END IF;
      END LOOP;
      CLOSE get_rt_oper_resources;
    END LOOP;
  END IF;

END get_rt_resource_req;

PROCEDURE get_op_material_req
(
  p_workorder_rec  IN            prd_workorder_rec,
  p_operation_tbl  IN            AHL_PRD_OPERATIONS_PVT.prd_operation_tbl,
  p_x_material_tbl IN OUT NOCOPY AHL_PP_MATERIALS_PVT.req_material_tbl_type
)
AS

  -- For Getting the Material Requirements for an Operation
  CURSOR get_oper_materials (c_operation_id NUMBER)
  IS
  SELECT MAT.rt_oper_material_id,
         MAT.inventory_item_id,
         MAT.item_group_id,
         MAT.quantity,
         MAT.uom_code,
         -- Bug # 6377990 - start
         MAT.in_service
         -- Bug # 6377990 - end
  FROM   AHL_RT_OPER_MATERIALS MAT
  WHERE  MAT.association_type_code='OPERATION'
  AND    MAT.object_id=c_operation_id;

  l_material_req_rec   get_oper_materials%ROWTYPE;

  -- For getting the Alternate Items for an Item Group
  CURSOR   get_alternate_items (c_item_group_id NUMBER)
  IS
  SELECT   inventory_item_id
  FROM     AHL_ITEM_ASSOCIATIONS_B
  WHERE    item_group_id=c_item_group_id
  ORDER BY priority;

  -- For Checking whether an Item exisits in an Organization.
  -- ***Incorporate Master Org check***
  CURSOR check_org_item (c_inventory_item_id NUMBER,
                         c_org_id NUMBER)
  IS
  SELECT 'X'
  FROM   MTL_SYSTEM_ITEMS
  WHERE  inventory_item_id=c_inventory_item_id
  AND    organization_id=c_org_id;

  l_mat_ctr            NUMBER := 0;
  l_org_item_found     BOOLEAN := FALSE;
  l_dummy              VARCHAR2(1);
  l_alternate_item_id  NUMBER;

BEGIN

  FOR i in p_operation_tbl.FIRST..p_operation_tbl.LAST LOOP
    IF ( p_operation_tbl(i).dml_operation = 'C' AND
         p_operation_tbl(i).operation_id IS NOT NULL AND
         p_operation_tbl(i).operation_id <> FND_API.G_MISS_NUM ) THEN

      -- Get the Material Requirements defined for the Operation
      OPEN get_oper_materials( p_operation_tbl(i).operation_id );
      LOOP
        FETCH get_oper_materials INTO l_material_req_rec;
        EXIT WHEN get_oper_materials%NOTFOUND;

        -- The Material Requirement is based on an Item
        IF ( l_material_req_rec.inventory_item_id IS NOT NULL ) THEN

          -- Check if the Item is available in the Visit's Organization
          OPEN check_org_item( l_material_req_rec.inventory_item_id, p_operation_tbl(i).organization_id );
          FETCH check_org_item INTO l_dummy;
          IF ( check_org_item%FOUND ) THEN

            -- Organization Item Found
            l_org_item_found := TRUE;
          END IF;
          CLOSE check_org_item;
        ELSE

          -- Since the Material Requirement is Based on a Item Group,
          -- Process all the Alternate Items for the Item Group
          -- based on Priority
          FOR alt_item_cursor IN get_alternate_items( l_material_req_rec.item_group_id ) LOOP

            -- Check if the Alternate Item is available in the
            -- Visit's Organization
            OPEN check_org_item( alt_item_cursor.inventory_item_id, p_operation_tbl(i).organization_id );
            FETCH check_org_item INTO l_dummy;
            IF ( check_org_item%FOUND ) THEN

              -- Organization Item Found
              l_org_item_found := TRUE;
              l_alternate_item_id := alt_item_cursor.inventory_item_id;
              CLOSE check_org_item;
              EXIT;
            END IF;
            CLOSE check_org_item;

          END LOOP;
        END IF;

        -- If an Organization Item is Found for the Material Requirement, then,
        -- Add the Material Requirement to the Corresponding Operation
        IF ( l_org_item_found = TRUE ) THEN
          l_org_item_found := FALSE;
          l_mat_ctr := l_mat_ctr + 1;
          p_x_material_tbl(l_mat_ctr).rt_oper_material_id       :=l_material_req_rec.rt_oper_material_id;
          p_x_material_tbl(l_mat_ctr).inventory_item_id         :=NVL(l_material_req_rec.inventory_item_id, l_alternate_item_id);
          p_x_material_tbl(l_mat_ctr).requested_quantity        :=l_material_req_rec.quantity;
          -- Bug # 6377990 - start
          p_x_material_tbl(l_mat_ctr).repair_item               :=l_material_req_rec.in_service;
          -- Bug # 6377990 - end
          p_x_material_tbl(l_mat_ctr).visit_id                  :=p_workorder_rec.visit_id;
          p_x_material_tbl(l_mat_ctr).visit_task_id             :=p_workorder_rec.visit_task_id;
          p_x_material_tbl(l_mat_ctr).organization_id           :=p_workorder_rec.organization_id;
          p_x_material_tbl(l_mat_ctr).requested_date            :=p_operation_tbl(i).scheduled_start_date;
          p_x_material_tbl(l_mat_ctr).job_number                :=p_workorder_rec.job_number;
          p_x_material_tbl(l_mat_ctr).workorder_id              :=p_workorder_rec.workorder_id;
          p_x_material_tbl(l_mat_ctr).wip_entity_id             :=p_workorder_rec.wip_entity_id;
          p_x_material_tbl(l_mat_ctr).workorder_operation_id    :=p_operation_tbl(i).workorder_operation_id;
          p_x_material_tbl(l_mat_ctr).operation_sequence        :=p_operation_tbl(i).operation_sequence_num;
          p_x_material_tbl(l_mat_ctr).operation_code            :=p_operation_tbl(i).operation_code;
          p_x_material_tbl(l_mat_ctr).operation_flag            :='C';
        END IF;

      END LOOP;
      CLOSE get_oper_materials;
    END IF;
  END LOOP;

END get_op_material_req;

PROCEDURE get_rt_material_req
(
  p_workorder_rec  IN            prd_workorder_rec,
  p_operation_tbl  IN            AHL_PRD_OPERATIONS_PVT.prd_operation_tbl,
  p_x_material_tbl IN OUT NOCOPY AHL_PP_MATERIALS_PVT.req_material_tbl_type
)
AS

  -- For Getting the Material Requirements for a Route or Operation
  CURSOR get_rt_oper_materials (c_object_id NUMBER,
                                c_association_type VARCHAR2)
  IS
  SELECT MAT.rt_oper_material_id,
         MAT.inventory_item_id,
         MAT.item_group_id,
         MAT.quantity,
         MAT.uom_code
  FROM   AHL_RT_OPER_MATERIALS MAT
  WHERE  MAT.association_type_code=c_association_type
  AND    MAT.object_id=c_object_id;

  l_material_req_rec   get_rt_oper_materials%ROWTYPE;

  -- For getting the Alternate Items for an Item Group
  CURSOR   get_alternate_items (c_item_group_id NUMBER)
  IS
  SELECT   inventory_item_id
  FROM     AHL_ITEM_ASSOCIATIONS_B
  WHERE    item_group_id=c_item_group_id
  ORDER BY priority;

  -- For Checking whether an Item exisits in an Organization.
  -- ***Incorporate Master Org check***
  CURSOR check_org_item (c_inventory_item_id NUMBER,
                         c_org_id NUMBER)
  IS
  SELECT 'X'
  FROM   MTL_SYSTEM_ITEMS
  WHERE  inventory_item_id=c_inventory_item_id
  AND    organization_id=c_org_id;

  l_mat_ctr            NUMBER := 0;
  l_route_mat_found    BOOLEAN := FALSE;
  l_org_item_found     BOOLEAN := FALSE;
  l_dummy              VARCHAR2(1);
  l_alternate_item_id  NUMBER;

BEGIN

  -- Get the Material Requirements defined for the Route
  OPEN get_rt_oper_materials( p_workorder_rec.route_id, 'ROUTE' );
  LOOP
    FETCH get_rt_oper_materials INTO l_material_req_rec;
    EXIT WHEN get_rt_oper_materials%NOTFOUND;

    -- Atleast One Material Requirement defined for the Route
    l_route_mat_found := TRUE;

    -- The Material Requirement is based on an Item
    IF ( l_material_req_rec.inventory_item_id IS NOT NULL ) THEN

      -- Check if the Item is available in the Visit's Organization
      OPEN check_org_item( l_material_req_rec.inventory_item_id, p_workorder_rec.organization_id );
      FETCH check_org_item INTO l_dummy;
      IF ( check_org_item%FOUND ) THEN

        -- Organization Item Found
        l_org_item_found := TRUE;
      END IF;
      CLOSE check_org_item;
    ELSE

      -- Since the Material Requirement is Based on a Item Group,
      -- Process all the Alternate Items for the Item Group based on Priority
      FOR alt_item_cursor IN get_alternate_items( l_material_req_rec.item_group_id ) LOOP

        -- Check if the Alternate Item is available in the Visit's Organization
        OPEN check_org_item( alt_item_cursor.inventory_item_id, p_workorder_rec.organization_id );
        FETCH check_org_item INTO l_dummy;
        IF ( check_org_item%FOUND ) THEN

          -- Organization Item Found
          l_org_item_found := TRUE;
          l_alternate_item_id := alt_item_cursor.inventory_item_id;
          CLOSE check_org_item;
          EXIT;
        END IF;
        CLOSE check_org_item;

      END LOOP;
    END IF;

    -- If an Organization Item is Found for the Material Requirement, then,
    -- Add the Job Material Requirement to the First Operation
    IF ( l_org_item_found = TRUE ) THEN
      l_org_item_found := FALSE;
      l_mat_ctr := l_mat_ctr + 1;
      p_x_material_tbl(l_mat_ctr).rt_oper_material_id       :=l_material_req_rec.rt_oper_material_id;
      p_x_material_tbl(l_mat_ctr).inventory_item_id         :=NVL(l_material_req_rec.inventory_item_id, l_alternate_item_id);
      p_x_material_tbl(l_mat_ctr).requested_quantity        :=l_material_req_rec.quantity;
      p_x_material_tbl(l_mat_ctr).visit_id                  :=p_workorder_rec.visit_id;
      p_x_material_tbl(l_mat_ctr).visit_task_id             :=p_workorder_rec.visit_task_id;
      p_x_material_tbl(l_mat_ctr).organization_id           :=p_workorder_rec.organization_id;
      p_x_material_tbl(l_mat_ctr).requested_date            :=p_workorder_rec.scheduled_start_date;
      p_x_material_tbl(l_mat_ctr).job_number                :=p_workorder_rec.job_number;
      p_x_material_tbl(l_mat_ctr).workorder_id              :=p_workorder_rec.workorder_id;
      p_x_material_tbl(l_mat_ctr).workorder_operation_id    :=p_operation_tbl(p_operation_tbl.FIRST).workorder_operation_id;
      p_x_material_tbl(l_mat_ctr).operation_sequence        :=p_operation_tbl(p_operation_tbl.FIRST).operation_sequence_num;
      p_x_material_tbl(l_mat_ctr).operation_code            :=p_operation_tbl(p_operation_tbl.FIRST).operation_code;
      p_x_material_tbl(l_mat_ctr).operation_flag            :='C';
    END IF;

  END LOOP;
  CLOSE get_rt_oper_materials;

  IF ( l_route_mat_found = FALSE ) THEN
    FOR i in p_operation_tbl.FIRST..p_operation_tbl.LAST LOOP

      -- Get the Material Requirements defined for the Operation
      OPEN get_rt_oper_materials( p_operation_tbl(i).operation_id, 'OPERATION' );
      LOOP
        FETCH get_rt_oper_materials INTO l_material_req_rec;
        EXIT WHEN get_rt_oper_materials%NOTFOUND;

        -- The Material Requirement is based on an Item
        IF ( l_material_req_rec.inventory_item_id IS NOT NULL ) THEN

          -- Check if the Item is available in the Visit's Organization
          OPEN check_org_item( l_material_req_rec.inventory_item_id, p_workorder_rec.organization_id );
          FETCH check_org_item INTO l_dummy;
          IF ( check_org_item%FOUND ) THEN

            -- Organization Item Found
            l_org_item_found := TRUE;
          END IF;
          CLOSE check_org_item;
        ELSE

          -- Since the Material Requirement is Based on a Item Group,
          -- Process all the Alternate Items for the Item Group
          -- based on Priority
          FOR alt_item_cursor IN get_alternate_items( l_material_req_rec.item_group_id ) LOOP

            -- Check if the Alternate Item is available in the
            -- Visit's Organization
            OPEN check_org_item( alt_item_cursor.inventory_item_id, p_workorder_rec.organization_id );
            FETCH check_org_item INTO l_dummy;
            IF ( check_org_item%FOUND ) THEN

              -- Organization Item Found
              l_org_item_found := TRUE;
              l_alternate_item_id := alt_item_cursor.inventory_item_id;
              CLOSE check_org_item;
              EXIT;
            END IF;
            CLOSE check_org_item;

          END LOOP;
        END IF;

        -- If an Organization Item is Found for the Material Requirement, then,
        -- Add the Material Requirement to the Corresponding Operation
        IF ( l_org_item_found = TRUE ) THEN
          l_org_item_found := FALSE;
          l_mat_ctr := l_mat_ctr + 1;
          p_x_material_tbl(l_mat_ctr).rt_oper_material_id       :=l_material_req_rec.rt_oper_material_id;
          p_x_material_tbl(l_mat_ctr).inventory_item_id         :=NVL(l_material_req_rec.inventory_item_id, l_alternate_item_id);
          p_x_material_tbl(l_mat_ctr).requested_quantity        :=l_material_req_rec.quantity;
          p_x_material_tbl(l_mat_ctr).visit_id                  :=p_workorder_rec.visit_id;
          p_x_material_tbl(l_mat_ctr).visit_task_id             :=p_workorder_rec.visit_task_id;
          p_x_material_tbl(l_mat_ctr).organization_id           :=p_workorder_rec.organization_id;
          p_x_material_tbl(l_mat_ctr).requested_date            :=p_workorder_rec.scheduled_start_date;
          p_x_material_tbl(l_mat_ctr).job_number                :=p_workorder_rec.job_number;
          p_x_material_tbl(l_mat_ctr).workorder_id              :=p_workorder_rec.workorder_id;
          p_x_material_tbl(l_mat_ctr).workorder_operation_id    :=p_operation_tbl(i).workorder_operation_id;
          p_x_material_tbl(l_mat_ctr).operation_sequence        :=p_operation_tbl(i).operation_sequence_num;
          p_x_material_tbl(l_mat_ctr).operation_code            :=p_operation_tbl(i).operation_code;
          p_x_material_tbl(l_mat_ctr).operation_flag            :='C';
        END IF;

      END LOOP;
      CLOSE get_rt_oper_materials;
    END LOOP;
  END IF;

END get_rt_material_req;

PROCEDURE default_attributes
(
  p_x_prd_workorder_rec   IN OUT NOCOPY prd_workorder_rec
)
AS
  CURSOR get_route_inspection_type(c_route_id NUMBER)
  IS
  SELECT qa_inspection_type
  --FROM   AHL_ROUTES_V --Changed from AHL_ROUTES_B for Application Usage Complaince.
  FROM   AHL_ROUTES_APP_V --Changed from AHL_ROUTES_V for perf bug# 4949394.
  WHERE  route_id=c_route_id;

    --Adithya added for bug# 6830028
     CURSOR get_route_acc_class_code(c_route_id NUMBER)
     IS
     SELECT ACCOUNTING_CLASS_CODE
     FROM   AHL_ROUTES_APP_V
     WHERE  route_id=c_route_id;

     CURSOR validate_acc_class_code( c_wip_acc_class_code VARCHAR2, c_organization_id NUMBER)
     IS
     select 'x'
     from WIP_ACCOUNTING_CLASSES
     where class_code = c_wip_acc_class_code
     and organization_id = c_organization_id
     and class_type = 6;

  l_acc_class_code        VARCHAR2(10);
  l_qa_inspection_type    VARCHAR2(150);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_return_status         VARCHAR2(1);
  -- ER 4460913
  l_project_num           VARCHAR2(25);
  l_visit_name            VARCHAR2(80);
  l_dummy                 VARCHAR2(1);

  -- rroy
  -- replace MTL_PROJECT_V with PJM_PROJECTS_ORG_OU_SECURE_V for R12
  -- required for PJM MOAC changes.
  CURSOR get_project_num(c_project_id NUMBER)
  IS
    SELECT project_number
    --FROM   MTL_PROJECT_V
    FROM PJM_PROJECTS_ORG_OU_SECURE_V
    WHERE  project_id = c_project_id;

  CURSOR get_visit_name(c_visit_id NUMBER)
  IS
    SELECT VISIT_NAME
    FROM AHL_VISITS_TL
    WHERE VISIT_ID = c_visit_id;

--Balaji added for BAE ER # 4462462.
CURSOR c_get_SR_details(p_visit_task_id NUMBER)
IS
SELECT
  CSIA.summary, -- sr summary
  CSIT.name -- sr type attribute
FROM
  AHL_VISIT_TASKS_B VTSK,
  AHL_UNIT_EFFECTIVITIES_B UE,
  CS_INCIDENTS_ALL CSIA,
  CS_INCIDENT_TYPES_VL CSIT
WHERE
  VTSK.visit_task_id = p_visit_task_id AND
  UE.Unit_effectivity_id = VTSK.unit_effectivity_id AND
  UE.manually_planned_flag = 'Y' AND
  UE.cs_incident_id IS NOT NULL AND
  NOT EXISTS (SELECT
                 'X'
              FROM
                  AHL_UE_RELATIONSHIPS UER
              WHERE
                  UER.related_ue_id = UE.Unit_effectivity_id OR
                  UER.ue_id = UE.Unit_effectivity_id) AND
  CSIA.incident_id = UE.cs_incident_id AND
  CSIT.incident_type_id = CSIA.incident_type_id;

  l_sr_summary            VARCHAR2(240);
  l_sr_type               VARCHAR2(30);
BEGIN

  SELECT AHL_WORKORDERS_S.NEXTVAL
  INTO   p_x_prd_workorder_rec.WORKORDER_ID
  FROM   DUAL;

  IF p_x_prd_workorder_rec.MASTER_WORKORDER_FLAG = 'Y' AND p_x_prd_workorder_rec.VISIT_TASK_ID IS NULL THEN
		  -- As per ER 4460913
				-- Visit master workorder name will be <project number> - <visit name>
				OPEN get_project_num(p_x_prd_workorder_rec.PROJECT_ID);
				FETCH get_project_num INTO l_project_num;
				CLOSE get_project_num;

				OPEN get_visit_name(p_x_prd_workorder_rec.VISIT_ID);
				FETCH get_visit_name INTO l_visit_name;
				CLOSE get_visit_name;

    p_x_prd_workorder_rec.JOB_NUMBER := l_project_num || ' - ' || substrb(l_visit_name, 1, 77 - (length(l_project_num)));
		ELSE
  SELECT work_order_prefix,
         default_eam_class
  INTO   p_x_prd_workorder_rec.JOB_NUMBER,
          l_acc_class_code
  FROM   WIP_EAM_PARAMETERS
  WHERE  ORGANIZATION_ID=p_x_prd_workorder_rec.ORGANIZATION_ID;

  SELECT p_x_prd_workorder_rec.JOB_NUMBER||TO_CHAR(AHL_WORKORDER_JOB_S.NEXTVAL)
  INTO   p_x_prd_workorder_rec.JOB_NUMBER
  FROM   DUAL;

        --Adithya added for Accounting class bug#
        IF p_x_prd_workorder_rec.CLASS_CODE is NULL and p_x_prd_workorder_rec.ROUTE_ID IS NOT NULL THEN
           OPEN  get_route_acc_class_code(p_x_prd_workorder_rec.ROUTE_ID);
           FETCH get_route_acc_class_code INTO p_x_prd_workorder_rec.CLASS_CODE;
           CLOSE get_route_acc_class_code;
         IF p_x_prd_workorder_rec.CLASS_CODE IS NOT NULL THEN
           OPEN  validate_acc_class_code(p_x_prd_workorder_rec.CLASS_CODE, p_x_prd_workorder_rec.ORGANIZATION_ID);
           FETCH validate_acc_class_code INTO l_dummy;
           CLOSE validate_acc_class_code;
           IF l_dummy IS NULL THEN
              p_x_prd_workorder_rec.CLASS_CODE := l_acc_class_code;
           END IF;
         END IF;
        END IF;
     END IF;

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_STATEMENT,'ahl.plsql.AHL_PRD_WORKORDER_PVT.default_attributes',
                  'Acc Class code: ' || p_x_prd_workorder_rec.CLASS_CODE);

  END IF;

  --Balaji added for BAE ER # 4462462 - Start.
  -- Default workorder description for NR Workorder in following cases
  -- 1. Non-Routines(NR) created on the shop floor.
  -- 2. Non-Routines with no MRs associated and planned from UMP into a Visit.
  OPEN c_get_SR_details(p_x_prd_workorder_rec.visit_task_id);
  FETCH c_get_SR_details INTO l_sr_summary, l_sr_type;
  CLOSE c_get_SR_details;

  IF l_sr_summary IS NOT NULL AND l_sr_type IS NOT NULL
  THEN
     -- fix for bug# 8641679
     p_x_prd_workorder_rec.job_description := SUBSTRB(l_sr_type || ' - ' ||l_sr_summary, 1, 240);
  END IF;
  --Balaji added for BAE ER # 4462462 - End.
  p_x_prd_workorder_rec.OBJECT_VERSION_NUMBER   :=1;
  p_x_prd_workorder_rec.LAST_UPDATE_DATE        :=SYSDATE;
  p_x_prd_workorder_rec.LAST_UPDATED_BY         :=FND_GLOBAL.user_id;
  p_x_prd_workorder_rec.CREATION_DATE           :=SYSDATE;
  p_x_prd_workorder_rec.CREATED_BY              :=FND_GLOBAL.user_id;
  p_x_prd_workorder_rec.LAST_UPDATE_LOGIN       :=FND_GLOBAL.user_id;
  p_x_prd_workorder_rec.WIP_ENTITY_ID           :=NULL;
  --p_x_prd_workorder_rec.STATUS_CODE             :=G_JOB_STATUS_UNRELEASED; -- Unreleased

  IF p_x_prd_workorder_rec.MASTER_WORKORDER_FLAG IS NULL OR
     p_x_prd_workorder_rec.MASTER_WORKORDER_FLAG = FND_API.G_MISS_CHAR THEN
    p_x_prd_workorder_rec.MASTER_WORKORDER_FLAG := 'N';
  END IF;

  IF p_x_prd_workorder_rec.VISIT_TASK_ID = FND_API.G_MISS_NUM THEN
    p_x_prd_workorder_rec.VISIT_TASK_ID := NULL;
  END IF;

  IF p_x_prd_workorder_rec.MASTER_WORKORDER_FLAG = 'Y' THEN
    l_qa_inspection_type:= NULL;
  ELSIF p_x_prd_workorder_rec.ROUTE_ID IS NULL THEN
    l_qa_inspection_type:= FND_PROFILE.value('AHL_NR_WO_PLAN_TYPE');
  ELSIF p_x_prd_workorder_rec.ROUTE_ID IS NOT NULL THEN
    OPEN  get_route_inspection_type(p_x_prd_workorder_rec.ROUTE_ID);
    FETCH get_route_inspection_type INTO l_qa_inspection_type;
    CLOSE get_route_inspection_type;
  END IF;

  IF l_qa_inspection_type is NOT NULL THEN
    AHL_QA_RESULTS_PVT.get_qa_plan
    (
      p_api_version           => 1.0,
      p_init_msg_list         => FND_API.G_FALSE,
      p_commit                => FND_API.G_FALSE,
      p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
      p_default               => FND_API.G_FALSE,
      p_module_type           => NULL,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data,
      p_organization_id       => p_x_prd_workorder_rec.organization_id,
      p_transaction_number    => 2001,
      p_col_trigger_value     => l_qa_inspection_type,
      x_plan_id               => p_x_prd_workorder_rec.plan_id
    );
  END IF;

  -- Default Job Description from Task Name ( if not passed )

END default_attributes;

PROCEDURE get_operations
(
  p_workorder_rec     IN             prd_workorder_rec,
  p_x_operations_tbl  IN OUT NOCOPY  AHL_PRD_OPERATIONS_PVT.prd_operation_tbl
)
AS
  CURSOR get_route_operations(c_route_id NUMBER)
  IS
  SELECT   RO.operation_id,
           RO.step,
           OP.concatenated_segments,
           OP.operation_type_code,
           OP.description
  FROM     AHL_OPERATIONS_VL OP,
           AHL_ROUTE_OPERATIONS RO
  WHERE    OP.operation_id=RO.operation_id
--  AND      OP.revision_status_code='COMPLETE'
  AND      RO.route_id=c_route_id
  AND      OP.revision_number IN
           ( SELECT MAX(OP1.revision_number)
             FROM   AHL_OPERATIONS_B_KFV OP1
             WHERE  OP1.concatenated_segments=OP.concatenated_segments
             AND    OP1.revision_status_code='COMPLETE'
             AND    TRUNC(SYSDATE) BETWEEN TRUNC(OP1.start_date_active) AND
                                           TRUNC(NVL(OP1.end_date_active,SYSDATE+1))
           )
  ORDER BY RO.step;

  l_count                NUMBER := 1;
  l_blank_operation_txt  FND_NEW_MESSAGES.message_text%TYPE;

  -- Added for FP bug# 7238868
  l_department_id        NUMBER;
  l_department_name       bom_departments.description%TYPE;
  l_route_found          VARCHAR2(1);
  l_oper_found           VARCHAR2(1);
  l_return_status        VARCHAR2(1);

BEGIN
  IF ( p_workorder_rec.ROUTE_ID IS NOT NULL ) THEN
    FOR op_cursor IN get_route_operations( p_workorder_rec.ROUTE_ID ) LOOP
      p_x_operations_tbl( l_count ).operation_sequence_num := op_cursor.step;
      p_x_operations_tbl( l_count ).operation_id := op_cursor.operation_id;
      p_x_operations_tbl( l_count ).operation_code := op_cursor.concatenated_segments;
      p_x_operations_tbl( l_count ).operation_type_code := op_cursor.operation_type_code;
      p_x_operations_tbl( l_count ).operation_description := op_cursor.description;
      p_x_operations_tbl( l_count ).organization_id := p_workorder_rec.organization_id;
      p_x_operations_tbl( l_count ).workorder_id := p_workorder_rec.workorder_id;
      p_x_operations_tbl( l_count ).route_id := p_workorder_rec.route_id;
      p_x_operations_tbl( l_count ).department_id := p_workorder_rec.department_id;
      p_x_operations_tbl( l_count ).scheduled_start_date := p_workorder_rec.scheduled_start_date;
      p_x_operations_tbl( l_count ).scheduled_end_date := p_workorder_rec.scheduled_end_date;
      p_x_operations_tbl( l_count ).status_code := G_OP_STATUS_UNCOMPLETE;
      p_x_operations_tbl( l_count ).propagate_flag := 'N';
      p_x_operations_tbl( l_count ).dml_operation := 'C';

      l_count := l_count + 1;
    END LOOP;
  END IF;

  IF ( p_x_operations_tbl.COUNT = 0 ) THEN
    -- Blank Operation
    p_x_operations_tbl( l_count ).operation_sequence_num := 10;

    p_x_operations_tbl( l_count ).organization_id := p_workorder_rec.organization_id;
    p_x_operations_tbl( l_count ).workorder_id := p_workorder_rec.workorder_id;
    p_x_operations_tbl( l_count ).route_id := p_workorder_rec.route_id;
    p_x_operations_tbl( l_count ).department_id := p_workorder_rec.department_id;
    p_x_operations_tbl( l_count ).scheduled_start_date := p_workorder_rec.scheduled_start_date;
    p_x_operations_tbl( l_count ).scheduled_end_date := p_workorder_rec.scheduled_end_date;
    p_x_operations_tbl( l_count ).status_code := G_OP_STATUS_UNCOMPLETE;
    p_x_operations_tbl( l_count ).propagate_flag := 'N';

    FND_MESSAGE.set_name('AHL','AHL_PRD_BLANK_OPERATION');
    l_blank_operation_txt := FND_MESSAGE.get;
    p_x_operations_tbl( l_count ).operation_description := NVL(SUBSTRB(RTRIM(l_blank_operation_txt),1,80),'Blank Operation');

    p_x_operations_tbl( l_count ).dml_operation := 'C';

  END IF;

  -- Added for FP bug# 7238868
  IF (p_workorder_rec.ROUTE_ID IS NOT NULL ) THEN

        IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( 'Get_Operations'|| ' - Before Get_Default_Rt_Op_dept' );
        END IF;

        -- Get default department from route/oper resources.
        Get_Default_Rt_Op_dept(p_object_id => p_workorder_rec.ROUTE_ID,
                               p_association_type => 'ROUTE',
                               p_organization_id => p_workorder_rec.organization_id,
                               x_return_status => l_return_status,
                               x_department_id => l_department_id,
                               x_department_name => l_department_name,
                               x_object_resource_found => l_route_found);

        IF ( G_DEBUG = 'Y' ) THEN
           AHL_DEBUG_PUB.debug( 'Get_Operations'|| 'l_return_status:' || l_return_status );
           AHL_DEBUG_PUB.debug( 'Get_Operations'|| 'l_department_id:' || l_department_id);
           AHL_DEBUG_PUB.debug( 'Get_Operations'|| 'l_department_name:' || l_department_name);
           AHL_DEBUG_PUB.debug( 'Get_Operations'|| 'l_route_found:' || l_route_found);
        END IF;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (l_route_found = 'Y') THEN
           IF (l_department_id IS NOT NULL) THEN
             -- replace only first operation dept with default dept.
             p_x_operations_tbl(p_x_operations_tbl.FIRST).department_id := l_department_id;
             p_x_operations_tbl(p_x_operations_tbl.FIRST).department_name := l_department_name;
           END IF;

        ELSE
           -- loop each operation and default dept.
           FOR i IN p_x_operations_tbl.FIRST..p_x_operations_tbl.LAST
           LOOP
              -- Get default department from route/oper resources.
              Get_Default_Rt_Op_dept(p_object_id => p_x_operations_tbl(i).operation_id,
                                     p_association_type => 'OPERATION',
                                     p_organization_id => p_workorder_rec.organization_id,
                                     x_return_status => l_return_status,
                                     x_department_id => l_department_id,
                                     x_department_name => l_department_name,
                                     x_object_resource_found => l_oper_found);

              IF ( G_DEBUG = 'Y' ) THEN
                AHL_DEBUG_PUB.debug( 'Get_Operations'|| 'l_return_status:' || l_return_status );
                AHL_DEBUG_PUB.debug( 'Get_Operations'|| 'l_department_id:' || l_department_id);
                AHL_DEBUG_PUB.debug( 'Get_Operations'|| 'l_department_name:' || l_department_name);
                AHL_DEBUG_PUB.debug( 'Get_Operations'|| 'l_oper_found:' || l_oper_found);
              END IF;

              IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 RAISE FND_API.G_EXC_ERROR;
              END IF;

              IF (l_department_id IS NOT NULL) THEN
                 p_x_operations_tbl(i).department_id := l_department_id;
                 p_x_operations_tbl(i).department_name := l_department_name;
              END IF;

           END LOOP;
        END IF; -- l_route_found = 'Y'
  END IF; -- p_workorder_rec.ROUTE_ID

END get_operations;

PROCEDURE create_job
(
  p_api_version          IN            NUMBER     := 1.0,
  p_init_msg_list        IN            VARCHAR2   := FND_API.G_TRUE,
  p_commit               IN            VARCHAR2   := FND_API.G_FALSE,
  p_validation_level     IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default              IN            VARCHAR2   := FND_API.G_FALSE,
  p_module_type          IN            VARCHAR2,
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_count            OUT NOCOPY    NUMBER,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_wip_load_flag        IN            VARCHAR2   := 'Y', -- Change to N
  p_x_prd_workorder_rec  IN OUT NOCOPY prd_workorder_rec,
  x_operation_tbl        OUT NOCOPY    AHL_PRD_OPERATIONS_PVT.prd_operation_tbl,
  x_resource_tbl         OUT NOCOPY    AHL_PP_RESRC_REQUIRE_PVT.resrc_require_tbl_type,
  x_material_tbl         OUT NOCOPY    AHL_PP_MATERIALS_PVT.req_material_tbl_type
)
AS
  l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_JOB';
  l_api_version  CONSTANT NUMBER       := 1.0;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_return_status         VARCHAR2(1);
  l_job_return_status     VARCHAR2(1);

-- Begin OGMA Issue # 105 - Balaji
-- cursor for checking if given task is planned task created form forecasted UE.
CURSOR c_can_update_quantity(p_task_id NUMBER)
IS
SELECT
  'X'
FROM
  ahl_visit_tasks_b vtsk
WHERE
  vtsk.quantity IS NULL AND
  vtsk.status_code <> 'DELETED' AND
  vtsk.visit_task_id = p_task_id

UNION

SELECT
  'X'
FROM
  ahl_visit_tasks_b vtsk,
  ahl_unit_effectivities_b aue
WHERE
  nvl(aue.manually_planned_flag, 'N') = 'N' AND
  vtsk.unit_effectivity_id = aue.unit_effectivity_id AND
  vtsk.status_code <> 'DELETED' AND
  vtsk.visit_task_id = p_task_id;

-- cursor for getting instance quantity for planned tasks.
CURSOR c_get_instance_quantity(p_task_id NUMBER)
IS
SELECT
  csi.quantity
FROM
  csi_item_instances csi,
  ahl_visit_tasks_b vtsk
WHERE
  vtsk.instance_id = csi.instance_id AND
  vtsk.status_code <> 'DELETED' AND
  vtsk.visit_task_id = p_task_id;

l_instance_quantity NUMBER;
l_can_update_quantity VARCHAR2(1);
-- End OGMA Issue # 105 - Balaji

BEGIN
  SAVEPOINT create_job_PVT;

  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status:=FND_API.G_RET_STS_SUCCESS;

  IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- User Hooks
  IF (JTF_USR_HKS.Ok_to_execute('AHL_PRD_WORKORDER_PVT', 'CREATE_JOB', 'B', 'C' )) then
      ahl_prd_workorder_CUHK.create_job_pre(
        p_prd_workorder_rec => p_x_prd_workorder_rec,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data,
        x_return_status => l_return_status);
      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( l_api_name || ' - Before validate_workorder' );
  END IF;

  IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    validate_workorder
    (
      p_prd_workorder_rec            =>p_x_prd_workorder_rec,
      p_wip_load_flag                =>p_wip_load_flag
    );

    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( l_api_name || ' - Before default_attributes' );
  END IF;

  default_attributes
  (
    p_x_prd_workorder_rec            =>p_x_prd_workorder_rec
  );

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( l_api_name || ' - Before Insert into AHL_WORKORDERS' );
  END IF;

  -- Begin OGMA Issue # 105 - Balaji
  -- update VWP planned task quantity current instance quantity
  -- this logic need to be moved to VWP later as per discussion with Shailaja and Jay.
  IF p_x_prd_workorder_rec.visit_task_id IS NOT NULL AND p_x_prd_workorder_rec.STATUS_CODE <> '17'
  THEN

          OPEN c_can_update_quantity(p_x_prd_workorder_rec.visit_task_id);
          FETCH c_can_update_quantity INTO l_can_update_quantity;
          CLOSE c_can_update_quantity;

          IF l_can_update_quantity IS NOT NULL
          THEN

		  OPEN c_get_instance_quantity(p_x_prd_workorder_rec.visit_task_id);
		  FETCH c_get_instance_quantity INTO l_instance_quantity;
		  CLOSE c_get_instance_quantity;

		  UPDATE
		   ahl_visit_tasks_b
		  SET
		   quantity = l_instance_quantity
		  WHERE
		   visit_task_id = p_x_prd_workorder_rec.visit_task_id;
	  END IF;
  END IF;
  -- End OGMA Issue # 105 - Balaji

  INSERT INTO AHL_WORKORDERS
  (
    WORKORDER_ID,
    OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    WORKORDER_NAME,
    WIP_ENTITY_ID,
    VISIT_ID,
    VISIT_TASK_ID,
    STATUS_CODE,
    PLAN_ID,
    COLLECTION_ID,
    ROUTE_ID,
    ACTUAL_START_DATE,
    ACTUAL_END_DATE,
    CONFIRM_FAILURE_FLAG,
    MASTER_WORKORDER_FLAG,
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
    p_x_prd_workorder_rec.WORKORDER_ID,
    p_x_prd_workorder_rec.OBJECT_VERSION_NUMBER,
    p_x_prd_workorder_rec.LAST_UPDATE_DATE,
    p_x_prd_workorder_rec.LAST_UPDATED_BY,
    p_x_prd_workorder_rec.CREATION_DATE,
    p_x_prd_workorder_rec.CREATED_BY,
    p_x_prd_workorder_rec.LAST_UPDATE_LOGIN,
    p_x_prd_workorder_rec.JOB_NUMBER,
    p_x_prd_workorder_rec.WIP_ENTITY_ID,
    p_x_prd_workorder_rec.VISIT_ID,
    p_x_prd_workorder_rec.VISIT_TASK_ID,
    p_x_prd_workorder_rec.STATUS_CODE,
    p_x_prd_workorder_rec.PLAN_ID,
    p_x_prd_workorder_rec.COLLECTION_ID,
    p_x_prd_workorder_rec.ROUTE_ID,
    p_x_prd_workorder_rec.ACTUAL_START_DATE,
    p_x_prd_workorder_rec.ACTUAL_END_DATE,
    p_x_prd_workorder_rec.CONFIRM_FAILURE_FLAG,
    p_x_prd_workorder_rec.MASTER_WORKORDER_FLAG,
    p_x_prd_workorder_rec.ATTRIBUTE_CATEGORY,
    p_x_prd_workorder_rec.ATTRIBUTE1,
    p_x_prd_workorder_rec.ATTRIBUTE2,
    p_x_prd_workorder_rec.ATTRIBUTE3,
    p_x_prd_workorder_rec.ATTRIBUTE4,
    p_x_prd_workorder_rec.ATTRIBUTE5,
    p_x_prd_workorder_rec.ATTRIBUTE6,
    p_x_prd_workorder_rec.ATTRIBUTE7,
    p_x_prd_workorder_rec.ATTRIBUTE8,
    p_x_prd_workorder_rec.ATTRIBUTE9,
    p_x_prd_workorder_rec.ATTRIBUTE10,
    p_x_prd_workorder_rec.ATTRIBUTE11,
    p_x_prd_workorder_rec.ATTRIBUTE12,
    p_x_prd_workorder_rec.ATTRIBUTE13,
    p_x_prd_workorder_rec.ATTRIBUTE14,
    p_x_prd_workorder_rec.ATTRIBUTE15
  );

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( l_api_name || ' - Before Insert into AHL_WORKORDER_TXNS' );
  END IF;

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
    p_x_prd_workorder_rec.OBJECT_VERSION_NUMBER,
    p_x_prd_workorder_rec.LAST_UPDATE_DATE,
    p_x_prd_workorder_rec.LAST_UPDATED_BY,
    p_x_prd_workorder_rec.CREATION_DATE,
    p_x_prd_workorder_rec.CREATED_BY,
    p_x_prd_workorder_rec.LAST_UPDATE_LOGIN,
    p_x_prd_workorder_rec.WORKORDER_ID,
    0,  -- check this transaction type code
    p_x_prd_workorder_rec.STATUS_CODE,
    p_x_prd_workorder_rec.SCHEDULED_START_DATE,
    p_x_prd_workorder_rec.SCHEDULED_END_DATE,
    p_x_prd_workorder_rec.ACTUAL_START_DATE,
    p_x_prd_workorder_rec.ACTUAL_END_DATE,
    NULL,
    p_x_prd_workorder_rec.COMPLETION_SUBINVENTORY,
    p_x_prd_workorder_rec.COMPLETION_LOCATOR_ID,
    p_x_prd_workorder_rec.SECURITY_GROUP_ID,
    p_x_prd_workorder_rec.ATTRIBUTE_CATEGORY,
    p_x_prd_workorder_rec.ATTRIBUTE1,
    p_x_prd_workorder_rec.ATTRIBUTE2,
    p_x_prd_workorder_rec.ATTRIBUTE3,
    p_x_prd_workorder_rec.ATTRIBUTE4,
    p_x_prd_workorder_rec.ATTRIBUTE5,
    p_x_prd_workorder_rec.ATTRIBUTE6,
    p_x_prd_workorder_rec.ATTRIBUTE7,
    p_x_prd_workorder_rec.ATTRIBUTE8,
    p_x_prd_workorder_rec.ATTRIBUTE9,
    p_x_prd_workorder_rec.ATTRIBUTE10,
    p_x_prd_workorder_rec.ATTRIBUTE11,
    p_x_prd_workorder_rec.ATTRIBUTE12,
    p_x_prd_workorder_rec.ATTRIBUTE13,
    p_x_prd_workorder_rec.ATTRIBUTE14,
    p_x_prd_workorder_rec.ATTRIBUTE15
  );

  IF ( p_x_prd_workorder_rec.master_workorder_flag = 'N' ) THEN

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( l_api_name || ' - Before get_operations. Route ID: '|| p_x_prd_workorder_rec.route_id );
    END IF;

    get_operations
    (
      p_workorder_rec      => p_x_prd_workorder_rec,
      p_x_operations_tbl   => x_operation_tbl
    );

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( l_api_name || ' - Before AHL_PRD_OPERATIONS_PVT.process_operations . Total Operations : '|| x_operation_tbl.COUNT );
    END IF;

    AHL_PRD_OPERATIONS_PVT.process_operations
    (
      p_api_version                  => 1.0,
      p_init_msg_list                => FND_API.G_TRUE,
      p_commit                       => FND_API.G_FALSE,
      p_validation_level             => FND_API.G_VALID_LEVEL_FULL,
      p_default                      => FND_API.G_TRUE,
      p_module_type                  => NULL,
      p_wip_mass_load_flag           => 'N',
      x_return_status                => l_return_status,
      x_msg_count                    => l_msg_count,
      x_msg_data                     => l_msg_data,
      p_x_prd_operation_tbl          => x_operation_tbl
    );

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF ( p_x_prd_workorder_rec.route_id IS NOT NULL ) THEN

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( l_api_name || ' - Before get_rt_resource_req' );
      END IF;

      get_rt_resource_req
      (
        p_workorder_rec  => p_x_prd_workorder_rec,
        p_operation_tbl  => x_operation_tbl,
        p_x_resource_tbl => x_resource_tbl
      );

      IF ( x_resource_tbl.COUNT > 0 ) THEN

        IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( l_api_name || ' - Before AHL_PP_RESRC_REQUIRE_PVT.process_resrc_require' );
        END IF;

        AHL_PP_RESRC_REQUIRE_PVT.process_resrc_require
        (
          p_api_version                  => 1.0,
          p_init_msg_list                => FND_API.G_TRUE,
          p_commit                       => FND_API.G_FALSE,
          p_validation_level             => FND_API.G_VALID_LEVEL_FULL,
          p_module_type                  => NULL,
          p_interface_flag               => 'N',
          p_operation_flag               => 'C',
          p_x_resrc_require_tbl          => x_resource_tbl,
          x_return_status                => l_return_status,
          x_msg_count                    => l_msg_count,
          x_msg_data                     => l_msg_data
        );

        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( l_api_name || ' - Before get_rt_material_req' );
      END IF;
   --Code changes made by Srini

  AHL_PP_MATERIALS_PVT.Process_Wo_Op_Materials
      (
        p_api_version          => 1.0,
        p_init_msg_list        => Fnd_Api.G_TRUE,
        p_commit               => Fnd_Api.G_FALSE,
        p_validation_level     => Fnd_Api.G_VALID_LEVEL_FULL,
        p_operation_flag       => 'C',
	    p_prd_wooperation_tbl  => x_operation_tbl,
        x_req_material_tbl     => x_material_tbl,
        x_return_status        => l_return_status,
        x_msg_count            => l_msg_count,
        x_msg_data             => l_msg_data
       );

        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( l_api_name || ' - After AHL_PP_MATERIALS_PVT.Process_Wo_Op_Materials' );
        END IF;

    END IF;

  END IF;

  IF ( p_wip_load_flag = 'Y' ) THEN

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( l_api_name || ' - Before AHL_EAM_JOB_PVT.create_eam_workorder' );
    END IF;

    AHL_EAM_JOB_PVT.create_eam_workorder
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
      p_x_workorder_rec        => p_x_prd_workorder_rec,
      p_operation_tbl          => x_operation_tbl,
      p_material_req_tbl       => x_material_tbl,
      p_resource_req_tbl       => x_resource_tbl
    );

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( l_api_name || ' - Before Update AHL_WORKORDERS with wip_entity_id' );
      END IF;

      UPDATE AHL_WORKORDERS
      SET    wip_entity_id = p_x_prd_workorder_rec.wip_entity_id
      WHERE  workorder_id = p_x_prd_workorder_rec.workorder_id;
    END IF;

  END IF;

  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  -- User Hooks
  IF (JTF_USR_HKS.Ok_to_execute('AHL_PRD_WORKORDER_PVT', 'CREATE_JOB', 'A', 'C' )) then
      ahl_prd_workorder_CUHK.create_job_post(
        p_prd_workorder_rec => p_x_prd_workorder_rec,
        p_operation_tbl =>  x_operation_tbl ,
        p_resource_tbl  =>  x_resource_tbl,
        p_material_tbl  =>  x_material_tbl,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data,
        x_return_status => l_return_status);
      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( l_api_name || ' - Success' );
  END IF;

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_job_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_job_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN OTHERS THEN
    ROLLBACK TO create_job_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg(p_pkg_name        =>g_pkg_name,
                              p_procedure_name  =>l_api_name,
                              p_error_text      => SUBSTRB(SQLERRM,1,240));

    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

END create_job;

PROCEDURE update_job
(
 p_api_version           IN            NUMBER    := 1.0,
 p_init_msg_list         IN            VARCHAR2  := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2  := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2  := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2,
 p_wip_load_flag         IN            VARCHAR2   := 'Y',
 p_x_prd_workorder_rec   IN OUT NOCOPY prd_workorder_rec,
 p_x_prd_workoper_tbl    IN OUT NOCOPY prd_workoper_tbl
)
AS
  l_api_name     CONSTANT VARCHAR2(30) := 'UPDATE_JOB'; -- adithya::Corrected the variable precision
  l_api_version  CONSTANT NUMBER       := 1.0;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_return_status         VARCHAR2(1);
  l_job_return_status     VARCHAR2(1);
  l_prd_workoper_tbl      AHL_PRD_OPERATIONS_PVT.prd_operation_tbl;
  l_resource_tbl          AHL_PP_RESRC_REQUIRE_PVT.resrc_require_tbl_type;
  l_material_tbl          AHL_PP_MATERIALS_PVT.req_material_tbl_type;
  l_parent_workorder_rec  prd_workorder_rec;
  l_parent_workoper_tbl   prd_workoper_tbl;
  l_wo_status             VARCHAR2(80);
  l_wo_status_code        VARCHAR2(30);

  l_debug_module CONSTANT VARCHAR2(100) := 'ahl.plsql.AHL_PRD_WORKORDER_PVT.UPDATE_JOB';
  l_dummy      VARCHAR2(1); -- Fix for Bug 9439418

  -- Bug # 7643668 (FP for Bug # 6493302) -- start
  CURSOR  get_parent_workorders( c_child_wip_entity_id NUMBER )
  IS
  SELECT  WO.workorder_id,
          WO.object_version_number,
          WO.wip_entity_id,
          WO.visit_task_id,
          WO.status_code,
          WIPJ.scheduled_start_date,
          WIPJ.scheduled_completion_date scheduled_end_date,
          WO.actual_start_date,
   	  WO.actual_end_date
  FROM    AHL_WORKORDERS WO,
          WIP_SCHED_RELATIONSHIPS WOR,
          WIP_DISCRETE_JOBS wipj
  WHERE
          WIPJ.wip_entity_id = WO.wip_entity_id
  AND     WO.wip_entity_id = WOR.parent_object_id
  AND     WO.master_workorder_flag = 'Y'
  AND     WO.status_code <> G_JOB_STATUS_DELETED
  AND     WOR.parent_object_type_id = 1
  AND     WOR.relationship_type = 1
  AND     WOR.child_object_type_id = 1
  AND     WOR.child_object_id = c_child_wip_entity_id;
  -- Bug # 7643668 (FP for Bug # 6493302) -- end

  CURSOR  get_child_workorders( c_wip_entity_id NUMBER )
  IS
  SELECT  WDJ.scheduled_start_date scheduled_start_date,
          WDJ.scheduled_completion_date scheduled_end_date,
          WO.actual_start_date actual_start_date,
          WO.actual_end_date actual_end_date,
          WO.status_code status_code
  FROM    WIP_DISCRETE_JOBS WDJ,
          AHL_WORKORDERS WO
  WHERE   WDJ.wip_entity_id = WO.wip_entity_id
  AND     WO.status_code <> G_JOB_STATUS_DELETED
  AND     WO.wip_entity_id in
          (
            SELECT     child_object_id
            FROM       WIP_SCHED_RELATIONSHIPS
            WHERE      parent_object_type_id = 1
            AND        child_object_type_id = 1
            START WITH parent_object_id = c_wip_entity_id
                  AND  relationship_type = 1
            CONNECT BY parent_object_id = PRIOR child_object_id
                  AND  relationship_type = 1
          );
		-- bug4393092
		-- Bug # 6680137 -- begin
		CURSOR get_wo_status(c_workorder_id VARCHAR2)
		IS
		SELECT AWOS.status_code,
		AWOS.workorder_name,
		FNDL.meaning
		FROM AHL_WORKORDERS AWOS,
					FND_LOOKUP_VALUES_VL FNDL
		WHERE AWOS.WORKORDER_ID = c_workorder_id
		AND FNDL.lookup_type = 'AHL_JOB_STATUS'
		AND FNDL.lookup_code(+) = AWOS.status_code;
		-- Bug # 6680137 -- end

  -- Added for R12: Serial Reservation.
  CURSOR get_scheduled_mater_csr (p_workorder_id IN NUMBER) IS
    SELECT scheduled_material_id
    FROM  ahl_job_oper_materials_v
    WHERE workorder_id = p_workorder_id
      AND reserved_quantity > 0;

  -- Added for R12: Tech UI Login/Logout feature.
  -- Logout all employees logged in at all levels when cancelling a workorder.
  CURSOR c_get_login_recs(p_workorder_id NUMBER)
  IS
     SELECT employee_id, operation_seq_num, resource_seq_num
     FROM   ahl_work_login_times
     WHERE  workorder_id = p_workorder_id
     AND LOGOUT_DATE IS NULL;

  -- Fix for bug# 5347560.
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

  -- Cursor added for bug # 6680137
  CURSOR c_wo_vtsk_id(p_wo_id NUMBER)
  IS
  SELECT
    visit_task_id
  FROM
    AHL_WORKORDERS
  WHERE
    workorder_id = p_wo_id;

  -- Bug # 8433227 (FP for Bug # 7453393) -- start
  -- EAM does not validate the emcompassing rule for Unreleased planned work order.
  -- Hence after work order update, visit start and end dates needed to be validated against
  -- work order scheduled start and end dates.

  CURSOR  get_visit_wo_dates(c_visit_id NUMBER)
  IS
  SELECT  WDJ.scheduled_start_date,
          WDJ.scheduled_completion_date
  FROM    WIP_DISCRETE_JOBS WDJ,
          AHL_WORKORDERS WO
  WHERE   WDJ.wip_entity_id = WO.wip_entity_id
    AND     WO.visit_task_id IS NULL
    AND     WO.master_workorder_flag = 'Y'
    AND     WO.visit_id = c_visit_id;

  CURSOR get_wo_sch_dates(p_wip_entity_id NUMBER)
  IS
  SELECT
    WDJ.scheduled_start_date,
    WDJ.scheduled_completion_date
  FROM
    WIP_DISCRETE_JOBS WDJ
  WHERE
    WDJ.wip_entity_id = p_wip_entity_id;



  l_wo_sch_start_date DATE;
  l_wo_sch_end_date DATE;
  l_visit_start_date DATE;
  l_visit_end_date DATE;

  -- Bug # 8433227 (FP for Bug # 7453393) -- end

  l_scheduled_start_date DATE;
  l_scheduled_end_date   DATE;
  l_actual_start_date    DATE;
  l_actual_end_date      DATE;
  l_status_code          VARCHAR2(30);
  l_status_code_multi    VARCHAR2(30) := 'MULTIPLE_STATUSES';

  l_employee_id          NUMBER;
  l_operation_seq_num    NUMBER;
  l_resource_seq_num     NUMBER;
  l_workorder_name       ahl_workorders.workorder_name%TYPE;

-- Begin OGMA Issue # 105 - Balaji
-- cursor for checking if given task is planned task created form forecasted UE.
CURSOR c_can_update_quantity(p_task_id NUMBER)
IS
SELECT
  'X'
FROM
  ahl_visit_tasks_b vtsk
WHERE
  vtsk.quantity IS NULL AND
  vtsk.status_code <> 'DELETED' AND
  vtsk.visit_task_id = p_task_id

UNION

SELECT
  'X'
FROM
  ahl_visit_tasks_b vtsk,
  ahl_unit_effectivities_b aue
WHERE
  nvl(aue.manually_planned_flag, 'N') = 'N' AND
  vtsk.unit_effectivity_id = aue.unit_effectivity_id AND
  vtsk.status_code <> 'DELETED' AND
  vtsk.visit_task_id = p_task_id;

-- cursor for getting instance quantity for planned tasks.
CURSOR c_get_instance_quantity(p_task_id NUMBER)
IS
SELECT
  csi.quantity
FROM
  csi_item_instances csi,
  ahl_visit_tasks_b vtsk
WHERE
  vtsk.instance_id = csi.instance_id AND
  vtsk.status_code <> 'DELETED' AND
  vtsk.visit_task_id = p_task_id;

l_instance_quantity NUMBER;
l_can_update_quantity VARCHAR2(1);

CURSOR c_get_current_WO_status(p_workorder_id NUMBER)
IS
SELECT
  status_code
FROM
  ahl_workorders
WHERE
  workorder_id = p_workorder_id;

l_curr_wo_status VARCHAR2(30);
-- End OGMA Issue # 105 - Balaji

  -- Bug # 6680137 -- start
  l_status_meaning        VARCHAR2(80);
  -- Bug # 6680137 -- end

  -- Added for FP bug# 7238868
  l_department_id        NUMBER;
  l_department_name      bom_departments.description%TYPE;
  l_oper_found           VARCHAR2(1);

  CURSOR get_operation_details(p_operation_code VARCHAR2)
    IS
    SELECT OP.operation_id
    FROM   AHL_OPERATIONS_VL OP
    WHERE  OP.concatenated_segments=p_operation_code
    AND    OP.revision_number IN
           ( SELECT MAX(OP1.revision_number)
             FROM   AHL_OPERATIONS_B_KFV OP1
             WHERE  OP1.concatenated_segments=OP.concatenated_segments
             AND    TRUNC(SYSDATE) BETWEEN TRUNC(OP1.start_date_active) AND
                                           TRUNC(NVL(OP1.end_date_active,SYSDATE+1))
             AND    OP1.revision_status_code='COMPLETE'
           );
  -- End FP bug# 7238868

  -- Fix for Bug # 8329755 (FP for Bug # 7697909) -- start
  CURSOR c_check_planned_wo(c_workorder_id IN NUMBER)
  IS
  SELECT
    WDJ.firm_planned_flag
  FROM
    WIP_DISCRETE_JOBS WDJ,
    AHL_WORKORDERS AWO
  WHERE
    AWO.wip_entity_id = WDJ.wip_entity_id AND
   AWO.workorder_id = c_workorder_id;


  l_plan_flag  NUMBER;
  -- Fix for Bug # 8329755 (FP for Bug # 7697909) -- end

   -- Fix for Bug 9439418
  CURSOR chk_pending_txns (p_wip_entity_id NUMBER) IS
      SELECT 'x'
      FROM WIP_COST_TXN_INTERFACE wict
      WHERE wict.wip_entity_id = p_wip_entity_id
      AND   process_status IN (1,2,3);

BEGIN
  SAVEPOINT update_job_PVT;

  IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                     p_api_version,
                                     l_api_name,G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status:=FND_API.G_RET_STS_SUCCESS;

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( l_api_name || ' - Before default_missing_attributes' );
  END IF;
--Modified by Srini
 /*IF p_module_type = 'API'
 THEN
   G_CALLED_FROM := 'API';
 END IF;*/
 G_CALLED_FROM := p_module_type;

 -- User Hooks
  IF (JTF_USR_HKS.Ok_to_execute('AHL_PRD_WORKORDER_PVT', 'UPDATE_JOB', 'B', 'C' )) THEN
     ahl_prd_workorder_CUHK.update_job_pre(
       p_prd_workorder_rec => p_x_prd_workorder_rec,
       p_prd_workoper_tbl  =>  p_x_prd_workoper_tbl,
       x_msg_count => l_msg_count,
       x_msg_data => l_msg_data,
       x_return_status => l_return_status);
     IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END IF;

  --IF FND_API.to_boolean(p_default) THEN
    default_missing_attributes
    (
      p_x_prd_workorder_rec
    );
  --END IF;

  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( l_api_name || ' - Before convert_values_to_ids' );
    END IF;

    convert_values_to_ids
    (
      p_x_prd_workorder_rec   =>p_x_prd_workorder_rec
    );
  END IF;

  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( l_api_name || ' - Before validate_workorder' );
    END IF;

    validate_workorder
    (
      p_prd_workorder_rec            =>p_x_prd_workorder_rec,
      p_wip_load_flag                =>p_wip_load_flag
    );

    IF  p_x_prd_workoper_tbl.COUNT > 0 THEN
        -- Bug # 6680137 -- begin
	OPEN get_wo_status(p_x_prd_workorder_rec.workorder_id);
	FETCH get_wo_status INTO l_wo_status_code, l_workorder_name, l_wo_status;
	CLOSE get_wo_status;
	-- Bug # 6680137 -- end
	IF l_wo_status_code IN ('22','7','12','4','5') THEN
    		FND_MESSAGE.set_name('AHL','AHL_PRD_UPD_WO_STS');
		FND_MESSAGE.set_token('WO_STATUS', l_wo_status);
		FND_MSG_PUB.add;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
    END IF;


  END IF;

  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- fix for bug# 5347560. In case of cancelling or closing a wo check if
  -- there are any trackable materials in the job.
  IF (p_x_prd_workorder_rec.status_code IN (G_JOB_STATUS_CANCELLED, G_JOB_STATUS_COMPLETE_NC,
                                            G_JOB_STATUS_CLOSED)) THEN
    OPEN chk_inst_in_job(p_x_prd_workorder_rec.workorder_id);
    FETCH chk_inst_in_job INTO l_workorder_name;
    IF (chk_inst_in_job%FOUND) THEN
        -- Bug # 6680137 -- begin
        -- show the right workorder name and status
        OPEN get_wo_status(p_x_prd_workorder_rec.workorder_id);
        FETCH get_wo_status INTO l_wo_status_code, l_workorder_name, l_wo_status;
        CLOSE get_wo_status;

        --Get status meaning
        SELECT meaning INTO l_status_meaning
	   FROM fnd_lookup_values_vl
        WHERE lookup_type = 'AHL_JOB_STATUS'
          AND LOOKUP_CODE = p_x_prd_workorder_rec.status_code;
        -- Bug # 6680137 -- end
        FND_MESSAGE.set_name('AHL','AHL_PRD_MAT_NOT_RETURN');
        FND_MESSAGE.set_token('WO_STATUS', l_status_meaning);
        FND_MESSAGE.set_token('WO_NAME', l_workorder_name);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE chk_inst_in_job;


   -- Fix for Bug 9439418
   --psalgia added for Bug::9439418  start
   OPEN chk_pending_txns(p_x_prd_workorder_rec.wip_entity_id);
   FETCH chk_pending_txns INTO l_dummy;

    IF (chk_pending_txns%FOUND) THEN
         OPEN c_get_login_recs(p_x_prd_workorder_rec.workorder_id);
         FETCH c_get_login_recs INTO l_employee_id, l_operation_seq_num, l_resource_seq_num;
         IF(c_get_login_recs%FOUND) THEN
                -- show the workorder name and status
		OPEN get_wo_status(p_x_prd_workorder_rec.workorder_id);
		FETCH get_wo_status INTO l_wo_status_code, l_workorder_name, l_wo_status;
		CLOSE get_wo_status;

		FND_MESSAGE.SET_NAME('AHL','AHL_PRD_TECH_LOGGED_IN');
                FND_MESSAGE.set_token('WO_NAME', l_workorder_name);
	        FND_MSG_PUB.add;

	 ELSE
		OPEN get_wo_status(p_x_prd_workorder_rec.workorder_id);
		FETCH get_wo_status INTO l_wo_status_code, l_workorder_name, l_wo_status;
		CLOSE get_wo_status;

		FND_MESSAGE.SET_NAME('AHL','AHL_PRD_PENDING_TXNS');
                FND_MESSAGE.set_token('WO_NAME', l_workorder_name);
	        FND_MSG_PUB.add;
	 END IF;
	 CLOSE c_get_login_recs;

         RAISE FND_API.G_EXC_ERROR;
         --psalgia added for Bug::9439418  end

    END IF;
    CLOSE chk_pending_txns;

  END IF;

  -- R12 Tech UI enhancement project.
  -- Log all technicians out of the workorder being cancelled.
  IF (p_x_prd_workorder_rec.status_code IN (G_JOB_STATUS_COMPLETE_NC, G_JOB_STATUS_COMPLETE,
                                            G_JOB_STATUS_CANCELLED)) THEN
      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( l_api_name || ' Before - AHL_PRD_WO_LOGIN_PVT.Workorder_Logout');
        AHL_DEBUG_PUB.debug( 'Workorder Status:' || p_x_prd_workorder_rec.status_code);
      END IF;

      OPEN c_get_login_recs(p_x_prd_workorder_rec.workorder_id);
      LOOP
      FETCH c_get_login_recs INTO l_employee_id, l_operation_seq_num, l_resource_seq_num;
      EXIT WHEN c_get_login_recs%NOTFOUND;
          AHL_PRD_WO_LOGIN_PVT.Workorder_Logout(p_api_version       => 1.0,
                                          p_init_msg_list     => p_init_msg_list,
                                          p_commit            => FND_API.G_FALSE,
                                          p_validation_level  => p_validation_level,
                                          x_return_status     => l_return_status,
                                          x_msg_count         => l_msg_count,
                                          x_msg_data          => l_msg_data,
                                          p_employee_id       => l_employee_id,
                                          p_workorder_id      => p_x_prd_workorder_rec.workorder_id,
                                          p_operation_seq_num => l_operation_seq_num,
                                          p_resource_seq_num  => l_resource_seq_num
                                         );
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            EXIT;
          END IF;
      END LOOP;
      CLOSE c_get_login_recs;

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( l_api_name || ' Before - AHL_PRD_WO_LOGIN_PVT.Workorder_Logout');
        AHL_DEBUG_PUB.debug( 'Return Status:' || l_return_status);
      END IF;

  END IF; -- p_x_prd_workorder_rec.STATUS_CODE

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- hold reason is only for on-hold and parts-hold.
  -- FP Bug# 7631453
  IF p_x_prd_workorder_rec.STATUS_CODE NOT IN ('6', '19') THEN
      p_x_prd_workorder_rec.HOLD_REASON_CODE := NULL;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( l_api_name || ' - Before Updating AHL_WORKORDERS' );
  END IF;

  -- Begin OGMA Issue # 105 - Balaji
  -- update VWP planned task quantity current instance quantity
  -- this logic need to be moved to VWP later as per discussion with Shailaja and Jay.

  OPEN c_get_current_WO_status(p_x_prd_workorder_rec.workorder_id);
  FETCH c_get_current_WO_status INTO l_curr_wo_status;
  CLOSE c_get_current_WO_status;

  IF p_x_prd_workorder_rec.visit_task_id IS NOT NULL AND l_curr_wo_status = '17'
  THEN

          OPEN c_can_update_quantity(p_x_prd_workorder_rec.visit_task_id);
          FETCH c_can_update_quantity INTO l_can_update_quantity;
          CLOSE c_can_update_quantity;

          IF l_can_update_quantity IS NOT NULL
          THEN

		  OPEN c_get_instance_quantity(p_x_prd_workorder_rec.visit_task_id);
		  FETCH c_get_instance_quantity INTO l_instance_quantity;
		  CLOSE c_get_instance_quantity;

		  UPDATE
		   ahl_visit_tasks_b
		  SET
		   quantity = l_instance_quantity
		  WHERE
		   visit_task_id = p_x_prd_workorder_rec.visit_task_id;
	  END IF;
  END IF;
  -- End OGMA Issue # 105 - Balaji

  UPDATE AHL_WORKORDERS SET
    OBJECT_VERSION_NUMBER   =p_x_prd_workorder_rec.OBJECT_VERSION_NUMBER + 1,
    LAST_UPDATE_DATE        =NVL(p_x_prd_workorder_rec.LAST_UPDATE_DATE,SYSDATE),
    LAST_UPDATED_BY         =NVL(p_x_prd_workorder_rec.LAST_UPDATED_BY,FND_GLOBAL.user_id),
    LAST_UPDATE_LOGIN       =NVL(p_x_prd_workorder_rec.LAST_UPDATE_LOGIN,FND_GLOBAL.user_id),
    STATUS_CODE             =p_x_prd_workorder_rec.STATUS_CODE,
    ACTUAL_START_DATE       =p_x_prd_workorder_rec.ACTUAL_START_DATE,
    ACTUAL_END_DATE         =p_x_prd_workorder_rec.ACTUAL_END_DATE,
    CONFIRM_FAILURE_FLAG    =p_x_prd_workorder_rec.CONFIRM_FAILURE_FLAG,
    SECURITY_GROUP_ID       =p_x_prd_workorder_rec.SECURITY_GROUP_ID,
    ATTRIBUTE_CATEGORY      =p_x_prd_workorder_rec.ATTRIBUTE_CATEGORY,
    ATTRIBUTE1              =p_x_prd_workorder_rec.ATTRIBUTE1,
    ATTRIBUTE2              =p_x_prd_workorder_rec.ATTRIBUTE2,
    ATTRIBUTE3              =p_x_prd_workorder_rec.ATTRIBUTE3,
    ATTRIBUTE4              =p_x_prd_workorder_rec.ATTRIBUTE4,
    ATTRIBUTE5              =p_x_prd_workorder_rec.ATTRIBUTE5,
    ATTRIBUTE6              =p_x_prd_workorder_rec.ATTRIBUTE6,
    ATTRIBUTE7              =p_x_prd_workorder_rec.ATTRIBUTE7,
    ATTRIBUTE8              =p_x_prd_workorder_rec.ATTRIBUTE8,
    ATTRIBUTE9              =p_x_prd_workorder_rec.ATTRIBUTE9,
    ATTRIBUTE10             =p_x_prd_workorder_rec.ATTRIBUTE10,
    ATTRIBUTE11             =p_x_prd_workorder_rec.ATTRIBUTE11,
    ATTRIBUTE12             =p_x_prd_workorder_rec.ATTRIBUTE12,
    ATTRIBUTE13             =p_x_prd_workorder_rec.ATTRIBUTE13,
    ATTRIBUTE14             =p_x_prd_workorder_rec.ATTRIBUTE14,
    ATTRIBUTE15             =p_x_prd_workorder_rec.ATTRIBUTE15,
    HOLD_REASON_CODE        =p_x_prd_workorder_rec.HOLD_REASON_CODE
  WHERE WORKORDER_ID=p_x_prd_workorder_rec.WORKORDER_ID
  AND   OBJECT_VERSION_NUMBER=p_x_prd_workorder_rec.OBJECT_VERSION_NUMBER;

  p_x_prd_workorder_rec.OBJECT_VERSION_NUMBER := p_x_prd_workorder_rec.OBJECT_VERSION_NUMBER + 1;

  IF SQL%NOTFOUND THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( l_api_name || ' - Before Inserting into AHL_WORKORDER_TXNS' );
  END IF;

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
    HOLD_REASON_CODE
  ) VALUES
  (
    AHL_WORKORDER_TXNS_S.NEXTVAL,
    NVL(p_x_prd_workorder_rec.OBJECT_VERSION_NUMBER,1),
    NVL(p_x_prd_workorder_rec.LAST_UPDATE_DATE,SYSDATE),
    NVL(p_x_prd_workorder_rec.LAST_UPDATED_BY,FND_GLOBAL.USER_ID),
    NVL(p_x_prd_workorder_rec.CREATION_DATE,SYSDATE),
    NVL(p_x_prd_workorder_rec.CREATED_BY,FND_GLOBAL.USER_ID),
    NVL(p_x_prd_workorder_rec.LAST_UPDATE_LOGIN,FND_GLOBAL.USER_ID),
    p_x_prd_workorder_rec.WORKORDER_ID,
    0,
    p_x_prd_workorder_rec.STATUS_CODE,
    p_x_prd_workorder_rec.SCHEDULED_START_DATE,
    p_x_prd_workorder_rec.SCHEDULED_END_DATE,
    p_x_prd_workorder_rec.ACTUAL_START_DATE,
    p_x_prd_workorder_rec.ACTUAL_END_DATE,
    0,
    p_x_prd_workorder_rec.COMPLETION_SUBINVENTORY,
    p_x_prd_workorder_rec.COMPLETION_LOCATOR_ID,
    p_x_prd_workorder_rec.HOLD_REASON_CODE
  );

  IF p_x_prd_workoper_tbl.COUNT >0 THEN
    FOR i in p_x_prd_workoper_tbl.FIRST..p_x_prd_workoper_tbl.LAST
    LOOP
      l_prd_workoper_tbl(i).WORKORDER_OPERATION_ID :=p_x_prd_workoper_tbl(i).WORKORDER_OPERATION_ID;
      l_prd_workoper_tbl(i).ORGANIZATION_ID        :=p_x_prd_workoper_tbl(i).ORGANIZATION_ID;
      l_prd_workoper_tbl(i).OPERATION_SEQUENCE_NUM :=p_x_prd_workoper_tbl(i).OPERATION_SEQUENCE_NUM;
      l_prd_workoper_tbl(i).OPERATION_DESCRIPTION  :=p_x_prd_workoper_tbl(i).OPERATION_DESCRIPTION;
      l_prd_workoper_tbl(i).WORKORDER_ID           :=p_x_prd_workoper_tbl(i).WORKORDER_ID;
      l_prd_workoper_tbl(i).WIP_ENTITY_ID          :=p_x_prd_workoper_tbl(i).WIP_ENTITY_ID;
      l_prd_workoper_tbl(i).ROUTE_ID               :=p_x_prd_workoper_tbl(i).ROUTE_ID;
      l_prd_workoper_tbl(i).OBJECT_VERSION_NUMBER  :=p_x_prd_workoper_tbl(i).OBJECT_VERSION_NUMBER;
      l_prd_workoper_tbl(i).LAST_UPDATE_DATE       :=p_x_prd_workoper_tbl(i).LAST_UPDATE_DATE;
      l_prd_workoper_tbl(i).LAST_UPDATED_BY        :=p_x_prd_workoper_tbl(i).LAST_UPDATED_BY;
      l_prd_workoper_tbl(i).CREATION_DATE          :=p_x_prd_workoper_tbl(i).CREATION_DATE;
      l_prd_workoper_tbl(i).CREATED_BY             :=p_x_prd_workoper_tbl(i).CREATED_BY;
      l_prd_workoper_tbl(i).LAST_UPDATE_LOGIN      :=p_x_prd_workoper_tbl(i).LAST_UPDATE_LOGIN;
      l_prd_workoper_tbl(i).DEPARTMENT_ID          :=p_x_prd_workoper_tbl(i).DEPARTMENT_ID;
      l_prd_workoper_tbl(i).DEPARTMENT_NAME        :=p_x_prd_workoper_tbl(i).DEPARTMENT_NAME;

      -- For new operations, default operation department based on resources - FP Bug# 7238868
      IF (p_x_prd_workoper_tbl(i).OPERATION_CODE IS NOT NULL
          AND p_x_prd_workoper_tbl(i).DML_OPERATION = 'C' ) THEN  -- route operation.


         -- first find the operation id.
         OPEN get_operation_details(p_x_prd_workoper_tbl(i).OPERATION_CODE);
         FETCH get_operation_details INTO p_x_prd_workoper_tbl(i).operation_id;
         CLOSE get_operation_details;

         IF ( G_DEBUG = 'Y' ) THEN
            AHL_DEBUG_PUB.debug( 'Get_Operations'|| 'dept id:' || p_x_prd_workorder_rec.department_id);
            AHL_DEBUG_PUB.debug( 'Get_Operations'|| 'dept ID(Oper):' || p_x_prd_workoper_tbl(i).DEPARTMENT_ID);
            AHL_DEBUG_PUB.debug( 'Get_Operations'|| 'deptnameD(Oper):' || p_x_prd_workoper_tbl(i).DEPARTMENT_NAME);

         END IF;

         --IF (p_x_prd_workoper_tbl(i).DEPARTMENT_ID = p_x_prd_workorder_rec.department_id) THEN
         IF (p_x_prd_workoper_tbl(i).operation_id IS NOT NULL) THEN
             Get_Default_Rt_Op_dept(p_object_id => p_x_prd_workoper_tbl(i).operation_id,
                                    p_association_type => 'OPERATION',
                                    p_organization_id => p_x_prd_workorder_rec.organization_id,
                                    x_return_status => l_return_status,
                                    x_department_id => l_department_id,
                                    x_department_name => l_department_name,
                                    x_object_resource_found => l_oper_found);

             IF ( G_DEBUG = 'Y' ) THEN
                 AHL_DEBUG_PUB.debug( 'Get_Operations'|| 'l_return_status:' || l_return_status );
                 AHL_DEBUG_PUB.debug( 'Get_Operations'|| 'l_department_id:' || l_department_id);
                 AHL_DEBUG_PUB.debug( 'Get_Operations'|| 'l_oper_found:' || l_oper_found);
             END IF;

             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;

             IF (l_department_id IS NOT NULL) THEN
                 l_prd_workoper_tbl(i).department_id := l_department_id;
                 l_prd_workoper_tbl(i).DEPARTMENT_NAME := l_department_name;
             END IF;
         END IF; -- operation id.

      END IF;

      l_prd_workoper_tbl(i).OPERATION_ID           :=p_x_prd_workoper_tbl(i).OPERATION_ID;
      l_prd_workoper_tbl(i).OPERATION_CODE         :=p_x_prd_workoper_tbl(i).OPERATION_CODE;
      l_prd_workoper_tbl(i).OPERATION_TYPE_CODE    :=p_x_prd_workoper_tbl(i).OPERATION_TYPE_CODE;
      l_prd_workoper_tbl(i).OPERATION_TYPE         :=p_x_prd_workoper_tbl(i).OPERATION_TYPE;
      l_prd_workoper_tbl(i).STATUS_CODE            :=p_x_prd_workoper_tbl(i).STATUS_CODE;
      l_prd_workoper_tbl(i).STATUS_MEANING         :=p_x_prd_workoper_tbl(i).STATUS_MEANING;
      l_prd_workoper_tbl(i).PROPAGATE_FLAG         :=p_x_prd_workoper_tbl(i).PROPAGATE_FLAG;
      l_prd_workoper_tbl(i).SCHEDULED_START_DATE   :=p_x_prd_workoper_tbl(i).SCHEDULED_START_DATE;
      l_prd_workoper_tbl(i).SCHEDULED_START_HR     :=p_x_prd_workoper_tbl(i).SCHEDULED_START_HR;
      l_prd_workoper_tbl(i).SCHEDULED_START_MI     :=p_x_prd_workoper_tbl(i).SCHEDULED_START_MI;
      l_prd_workoper_tbl(i).SCHEDULED_END_DATE     :=p_x_prd_workoper_tbl(i).SCHEDULED_END_DATE;
      l_prd_workoper_tbl(i).SCHEDULED_END_HR       :=p_x_prd_workoper_tbl(i).SCHEDULED_END_HR;
      l_prd_workoper_tbl(i).SCHEDULED_END_MI       :=p_x_prd_workoper_tbl(i).SCHEDULED_END_MI;
      l_prd_workoper_tbl(i).ACTUAL_START_DATE      :=p_x_prd_workoper_tbl(i).ACTUAL_START_DATE;
      l_prd_workoper_tbl(i).ACTUAL_START_HR        :=p_x_prd_workoper_tbl(i).ACTUAL_START_HR;
      l_prd_workoper_tbl(i).ACTUAL_START_MI        :=p_x_prd_workoper_tbl(i).ACTUAL_START_MI;
      l_prd_workoper_tbl(i).ACTUAL_END_DATE        :=p_x_prd_workoper_tbl(i).ACTUAL_END_DATE;
      l_prd_workoper_tbl(i).ACTUAL_END_HR          :=p_x_prd_workoper_tbl(i).ACTUAL_END_HR;
      l_prd_workoper_tbl(i).ACTUAL_END_MI          :=p_x_prd_workoper_tbl(i).ACTUAL_END_MI;
      l_prd_workoper_tbl(i).PLAN_ID                :=p_x_prd_workoper_tbl(i).PLAN_ID;
      l_prd_workoper_tbl(i).COLLECTION_ID          :=p_x_prd_workoper_tbl(i).COLLECTION_ID;
      l_prd_workoper_tbl(i).SECURITY_GROUP_ID      :=p_x_prd_workoper_tbl(i).SECURITY_GROUP_ID;
      l_prd_workoper_tbl(i).ATTRIBUTE_CATEGORY     :=p_x_prd_workoper_tbl(i).ATTRIBUTE_CATEGORY;
      l_prd_workoper_tbl(i).ATTRIBUTE1             :=p_x_prd_workoper_tbl(i).ATTRIBUTE1;
      l_prd_workoper_tbl(i).ATTRIBUTE2             :=p_x_prd_workoper_tbl(i).ATTRIBUTE2;
      l_prd_workoper_tbl(i).ATTRIBUTE3             :=p_x_prd_workoper_tbl(i).ATTRIBUTE3;
      l_prd_workoper_tbl(i).ATTRIBUTE4             :=p_x_prd_workoper_tbl(i).ATTRIBUTE4;
      l_prd_workoper_tbl(i).ATTRIBUTE5             :=p_x_prd_workoper_tbl(i).ATTRIBUTE5;
      l_prd_workoper_tbl(i).ATTRIBUTE6             :=p_x_prd_workoper_tbl(i).ATTRIBUTE6;
      l_prd_workoper_tbl(i).ATTRIBUTE7             :=p_x_prd_workoper_tbl(i).ATTRIBUTE7;
      l_prd_workoper_tbl(i).ATTRIBUTE8             :=p_x_prd_workoper_tbl(i).ATTRIBUTE8;
      l_prd_workoper_tbl(i).ATTRIBUTE9             :=p_x_prd_workoper_tbl(i).ATTRIBUTE9;
      l_prd_workoper_tbl(i).ATTRIBUTE10            :=p_x_prd_workoper_tbl(i).ATTRIBUTE10;
      l_prd_workoper_tbl(i).ATTRIBUTE11            :=p_x_prd_workoper_tbl(i).ATTRIBUTE11;
      l_prd_workoper_tbl(i).ATTRIBUTE12            :=p_x_prd_workoper_tbl(i).ATTRIBUTE12;
      l_prd_workoper_tbl(i).ATTRIBUTE13            :=p_x_prd_workoper_tbl(i).ATTRIBUTE13;
      l_prd_workoper_tbl(i).ATTRIBUTE14            :=p_x_prd_workoper_tbl(i).ATTRIBUTE14;
      l_prd_workoper_tbl(i).ATTRIBUTE15            :=p_x_prd_workoper_tbl(i).ATTRIBUTE15;
      l_prd_workoper_tbl(i).DML_OPERATION          :=p_x_prd_workoper_tbl(i).DML_OPERATION;

    END LOOP;

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( l_api_name || ' - Before AHL_PRD_OPERATIONS_PVT.process_operations' );
    END IF;

    AHL_PRD_OPERATIONS_PVT.process_operations
    (
      p_api_version                  =>1.0,
      p_init_msg_list                =>FND_API.G_TRUE,
      p_commit                       =>FND_API.G_FALSE,
      p_validation_level             =>p_validation_level,
      p_default                      =>p_default,
      p_module_type                  =>p_module_type,
      p_wip_mass_load_flag           =>'N',
      x_return_status                =>l_return_status,
      x_msg_count                    =>l_msg_count  ,
      x_msg_data                     =>l_msg_data,
      p_x_prd_operation_tbl          =>l_prd_workoper_tbl
    );

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF ( p_wip_load_flag = 'Y' ) THEN

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( l_api_name || ' - Before get_op_resource_req' );
      END IF;

      -- Get the Resource Requirements for New Operations
      get_op_resource_req
      (
        p_workorder_rec  => p_x_prd_workorder_rec,
        p_operation_tbl  => l_prd_workoper_tbl,
        p_x_resource_tbl => l_resource_tbl
      );

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( l_api_name || ' - Before AHL_PP_RESRC_REQUIRE_PVT.process_resrc_require' );
      END IF;

      IF ( l_resource_tbl.COUNT > 0 ) THEN
        AHL_PP_RESRC_REQUIRE_PVT.process_resrc_require
        (
          p_api_version                  => 1.0,
          p_init_msg_list                => FND_API.G_TRUE,
          p_commit                       => FND_API.G_FALSE,
          p_validation_level             => FND_API.G_VALID_LEVEL_FULL,
          p_module_type                  => NULL,
          p_interface_flag               => 'N',
          p_operation_flag               => 'C',
          p_x_resrc_require_tbl          => l_resource_tbl,
          x_return_status                => l_return_status,
          x_msg_count                    => l_msg_count,
          x_msg_data                     => l_msg_data
        );

        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( l_api_name || ' - Before get_op_material_req' );
      END IF;

      -- Get the Material Requirements for New Operations
      get_op_material_req
      (
        p_workorder_rec  => p_x_prd_workorder_rec,
        p_operation_tbl  => l_prd_workoper_tbl,
        p_x_material_tbl => l_material_tbl
      );

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( l_api_name || ' - Before AHL_PP_MATERIALS_PVT.create_material_reqst' );
      END IF;

      IF ( l_material_tbl.COUNT > 0 ) THEN
        AHL_PP_MATERIALS_PVT.create_material_reqst
        (
          p_api_version                  => 1.0,
          p_init_msg_list                => FND_API.G_TRUE,
          p_commit                       => FND_API.G_FALSE,
          p_validation_level             => FND_API.G_VALID_LEVEL_FULL,
          p_interface_flag               => 'N',
          p_x_req_material_tbl           => l_material_tbl,
          x_job_return_status            => l_job_return_status,
          x_return_status                => l_return_status,
          x_msg_count                    => l_msg_count,
          x_msg_data                     => l_msg_data
        );

        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

    END IF; -- For WIP Load Flag

  END IF; -- For Operations

  IF ( p_wip_load_flag = 'Y' ) THEN

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( l_api_name || ' - Getting parent_workorders' );
    END IF;

    FOR parent_csr IN get_parent_workorders( p_x_prd_workorder_rec.wip_entity_id ) LOOP
      l_parent_workorder_rec.workorder_id := parent_csr.workorder_id;
      l_parent_workorder_rec.object_version_number := parent_csr.object_version_number;

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( l_api_name || ' - parent workorder_id :' || l_parent_workorder_rec.workorder_id );
      END IF;

      FOR child_csr IN get_child_workorders( parent_csr.wip_entity_id ) LOOP

        IF ( l_status_code IS NULL ) THEN
          l_status_code := child_csr.status_code;
        ELSIF ( l_status_code <> child_csr.status_code ) THEN
          l_status_code := l_status_code_multi;
        END IF;

        IF ( l_scheduled_start_date IS NULL ) THEN
          l_scheduled_start_date := child_csr.scheduled_start_date;
        ELSIF ( NVL(child_csr.scheduled_start_date, l_scheduled_start_date) < l_scheduled_start_date ) THEN
          l_scheduled_start_date := child_csr.scheduled_start_date;
        END IF;

        IF ( l_scheduled_end_date IS NULL ) THEN
          l_scheduled_end_date := child_csr.scheduled_end_date;
        ELSIF ( NVL(child_csr.scheduled_end_date, l_scheduled_end_date) > l_scheduled_end_date ) THEN
          l_scheduled_end_date := child_csr.scheduled_end_date;
        END IF;

        IF ( l_actual_start_date IS NULL ) THEN
          l_actual_start_date := child_csr.actual_start_date;
        ELSIF ( NVL(child_csr.actual_start_date, l_actual_start_date) < l_actual_start_date ) THEN
          l_actual_start_date := child_csr.actual_start_date;
        END IF;

        IF ( l_actual_end_date IS NULL ) THEN
          l_actual_end_date := child_csr.actual_end_date;
        ELSIF ( NVL(child_csr.actual_end_date, l_actual_end_date) > l_actual_end_date ) THEN
          l_actual_end_date := child_csr.actual_end_date;
        END IF;

      END LOOP;

      IF ( parent_csr.visit_task_id IS NOT NULL ) THEN
        IF ( l_scheduled_start_date IS NULL OR
             p_x_prd_workorder_rec.scheduled_start_date < l_scheduled_start_date ) THEN
          l_parent_workorder_rec.scheduled_start_date := p_x_prd_workorder_rec.scheduled_start_date;
          l_parent_workorder_rec.scheduled_start_hr := p_x_prd_workorder_rec.scheduled_start_hr;
          l_parent_workorder_rec.scheduled_start_mi := p_x_prd_workorder_rec.scheduled_start_mi;
        ELSE
          l_parent_workorder_rec.scheduled_start_date := l_scheduled_start_date;
          l_parent_workorder_rec.scheduled_start_hr := TO_NUMBER( TO_CHAR( l_scheduled_start_date, 'HH24' ) );
          l_parent_workorder_rec.scheduled_start_mi := TO_NUMBER( TO_CHAR( l_scheduled_start_date, 'MI' ) );
        END IF;
      END IF;

      IF ( parent_csr.visit_task_id IS NOT NULL ) THEN
        IF ( l_scheduled_end_date IS NULL OR
             p_x_prd_workorder_rec.scheduled_end_date > l_scheduled_end_date ) THEN
          l_parent_workorder_rec.scheduled_end_date := p_x_prd_workorder_rec.scheduled_end_date;
          l_parent_workorder_rec.scheduled_end_hr := p_x_prd_workorder_rec.scheduled_end_hr;
          l_parent_workorder_rec.scheduled_end_mi := p_x_prd_workorder_rec.scheduled_end_mi;
        ELSE
          l_parent_workorder_rec.scheduled_end_date := l_scheduled_end_date;
          l_parent_workorder_rec.scheduled_end_hr := TO_NUMBER( TO_CHAR( l_scheduled_end_date, 'HH24' ) );
          l_parent_workorder_rec.scheduled_end_mi := TO_NUMBER( TO_CHAR( l_scheduled_end_date, 'MI' ) );
        END IF;
      END IF;

      IF ( l_actual_start_date IS NOT NULL ) THEN
        l_parent_workorder_rec.actual_start_date := l_actual_start_date;
        l_parent_workorder_rec.actual_start_hr := TO_NUMBER( TO_CHAR( l_actual_start_date, 'HH24' ) );
        l_parent_workorder_rec.actual_start_mi := TO_NUMBER( TO_CHAR( l_actual_start_date, 'MI' ) );
      END IF;

      IF ( l_actual_end_date IS NOT NULL ) THEN
        l_parent_workorder_rec.actual_end_date := l_actual_end_date;
        l_parent_workorder_rec.actual_end_hr := TO_NUMBER( TO_CHAR( l_actual_end_date, 'HH24' ) );
        l_parent_workorder_rec.actual_end_mi := TO_NUMBER( TO_CHAR( l_actual_end_date, 'MI' ) );
      END IF;

      IF ( l_status_code = l_status_code_multi ) THEN
        IF ( ( p_x_prd_workorder_rec.status_code = G_JOB_STATUS_RELEASED OR
               p_x_prd_workorder_rec.status_code = G_JOB_STATUS_ON_HOLD OR
               p_x_prd_workorder_rec.status_code = G_JOB_STATUS_CANCELLED OR
               p_x_prd_workorder_rec.status_code = G_JOB_STATUS_PARTS_HOLD OR
               p_x_prd_workorder_rec.status_code = G_JOB_STATUS_DEFERRAL_PENDING OR
               p_x_prd_workorder_rec.status_code = G_JOB_STATUS_DELETED ) AND
             ( parent_csr.status_code = G_JOB_STATUS_UNRELEASED OR
               parent_csr.status_code = G_JOB_STATUS_DRAFT ) ) THEN
          l_parent_workorder_rec.status_code := G_JOB_STATUS_RELEASED;
        END IF;
      ELSE
        IF ( parent_csr.visit_task_id IS NULL AND
             parent_csr.status_code = G_JOB_STATUS_DRAFT AND
             p_x_prd_workorder_rec.status_code = G_JOB_STATUS_DELETED ) THEN
              l_parent_workorder_rec.status_code := G_JOB_STATUS_RELEASED;
	      -- auto close should not be allowed
	      -- rroy
	      -- bug 4626717 and Shailaja's Mail dated Mon, 26 Sep 2005
	      -- Subj: [Fwd: proposed change to visit closure process]
		/*
		 * Balaji commented out following portion of code for bug # 5138200
		 * Since master workorder cannot be updated to cancelled status
		 * when child workorder are not already cancelled. The recursive logic
		 * in this API updates parent workorders first and then child workorders.
		 * Cancelling parent workorders will be taken care by Cancel_Visit_Jobs API.
		 *
	ELSIF l_status_code <> G_JOB_STATUS_CLOSED THEN
          l_parent_workorder_rec.status_code := l_status_code;
        */
        END IF;
      END IF;
       -- rroy
       -- validate the status change so that
       -- the sequence of status changes is valid
       -- and eam does not throw errors
       -- the validations are similar to those in
       -- eam_wo_validate_pvt
       IF(l_parent_workorder_Rec.status_code = G_JOB_STATUS_DRAFT AND parent_csr.status_code <> G_JOB_STATUS_DRAFT) THEN
		l_parent_workorder_rec.status_code := parent_csr.status_code;
       ELSIF(parent_csr.status_code = G_JOB_STATUS_COMPLETE_NC AND
            (l_parent_workorder_rec.status_code	 NOT IN (G_JOB_STATUS_COMPLETE_NC, G_JOB_STATUS_CLOSED,
                                                         G_JOB_STATUS_COMPLETE))) THEN
   		l_parent_workorder_rec.status_code := parent_csr.status_code;
      ELSIF (l_parent_workorder_rec.status_code = G_JOB_STATUS_COMPLETE_NC AND
            (parent_csr.status_code NOT IN (G_JOB_STATUS_COMPLETE_NC, G_JOB_STATUS_CLOSED, G_JOB_STATUS_COMPLETE))) THEN
		l_parent_workorder_rec.status_code := parent_csr.status_code;
      END IF;

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( l_api_name || ' - Before update_job for parent workorder' );
        AHL_DEBUG_PUB.debug( l_api_name || ' - parent workorder-status_code: '|| l_parent_workorder_rec.status_code );
        AHL_DEBUG_PUB.debug( l_api_name || ' - parent workorder-scheduled_start_date: '|| TO_CHAR(l_parent_workorder_rec.scheduled_start_date , 'DD-MON-YYYY HH24:MI' ) );
        AHL_DEBUG_PUB.debug( l_api_name || ' - parent workorder-scheduled_end_date: '|| TO_CHAR(l_parent_workorder_rec.scheduled_end_date , 'DD-MON-YYYY HH24:MI' ) );
        AHL_DEBUG_PUB.debug( l_api_name || ' - parent workorder-actual_start_date: '|| TO_CHAR(l_parent_workorder_rec.actual_start_date , 'DD-MON-YYYY HH24:MI' ) );
        AHL_DEBUG_PUB.debug( l_api_name || ' - parent workorder-actual_end_date: '|| TO_CHAR(l_parent_workorder_rec.actual_end_date , 'DD-MON-YYYY HH24:MI' ) );
      END IF;

       -- Bug # 7643668 (FP for Bug # 6493302) -- start
       -- Unless any of scheduled date, actual date or status changes for a
       -- parent work order dont call update_job for Master workorder.
       IF
	(
	 parent_csr.status_code <> l_parent_workorder_rec.status_code OR
	 parent_csr.scheduled_start_date <> l_parent_workorder_rec.scheduled_start_date OR
	 parent_csr.scheduled_end_date <> l_parent_workorder_rec.scheduled_end_date OR
	 TO_NUMBER( TO_CHAR( parent_csr.scheduled_start_date, 'HH24' ) ) <> l_parent_workorder_rec.scheduled_start_hr OR
	 TO_NUMBER( TO_CHAR( parent_csr.scheduled_start_date, 'MI' ) ) <> l_parent_workorder_rec.scheduled_start_mi OR
	 TO_NUMBER( TO_CHAR( parent_csr.scheduled_end_date, 'HH24' ) ) <> l_parent_workorder_rec.scheduled_end_hr OR
	 TO_NUMBER( TO_CHAR( parent_csr.scheduled_end_date, 'MI' ) ) <> l_parent_workorder_rec.scheduled_end_mi OR
	 (
	  (
	   parent_csr.actual_start_date IS NULL AND
	   l_parent_workorder_rec.actual_start_date IS NOT NULL
	  ) OR
	  parent_csr.actual_start_date <> l_parent_workorder_rec.actual_start_date
	 ) OR
	 (
	  (
	   parent_csr.actual_end_date IS NULL AND
	   l_parent_workorder_rec.actual_end_date IS NOT NULL
	  ) OR
	  parent_csr.actual_end_date <> l_parent_workorder_rec.actual_end_date
	 ) OR
	 (
	  parent_csr.actual_start_date IS NOT NULL AND
	  TO_NUMBER( TO_CHAR( parent_csr.actual_start_date, 'HH24' ) ) <> l_parent_workorder_rec.actual_start_hr
	 ) OR
	 (
	  parent_csr.actual_start_date IS NOT NULL AND
	  TO_NUMBER( TO_CHAR( parent_csr.actual_start_date, 'MI' ) ) <> l_parent_workorder_rec.actual_start_mi
	 ) OR
	 (
	  parent_csr.actual_end_date IS NOT NULL AND
	  TO_NUMBER( TO_CHAR( parent_csr.actual_end_date, 'HH24' ) ) <> l_parent_workorder_rec.actual_end_hr
	 ) OR
	 (
	  parent_csr.actual_end_date IS NOT NULL AND
	  TO_NUMBER( TO_CHAR( parent_csr.actual_end_date, 'MI' ) ) <> l_parent_workorder_rec.actual_end_mi
	 )

       )
       THEN
	      update_job
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
		p_wip_load_flag          => p_wip_load_flag            ,
		p_x_prd_workorder_rec    => l_parent_workorder_rec     ,
		p_x_prd_workoper_tbl     => l_parent_workoper_tbl
	      );

	      IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
		RAISE FND_API.G_EXC_ERROR;
	      END IF;

	      IF ( G_DEBUG = 'Y' ) THEN
		AHL_DEBUG_PUB.debug( l_api_name || ' - update_job for parent_workorder successful' );
	      END IF;

        END IF;
        -- Bug # 7643668 (FP for Bug # 6493302) -- end
    END LOOP;

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( l_api_name || ' - Before AHL_EAM_JOB_PVT.update_job_operations' );
    END IF;

    -- Fix for Bug # 8329755 (FP for Bug # 7697909) -- start
    -- Though resource requirements are added in call to AHL_PP_RESRC_REQUIRE_PVT.process_resrc_require
    -- above, EAM API is not called due to p_interface_flag being N.
    -- Hence the MWO dates are not updated correctly. They need expanded and contracted
    -- just before resource addition and after resource addition respectively.
    IF l_resource_tbl.COUNT > 0
    THEN
       FOR l_res_count IN l_resource_tbl.FIRST .. l_resource_tbl.LAST
       LOOP
          AHL_PP_RESRC_REQUIRE_PVT.Expand_Master_Wo_Dates(l_resource_tbl(l_res_count));
       END LOOP;
    END IF;
    -- Fix for Bug # 8329755 (FP for Bug # 7697909) -- end

    AHL_EAM_JOB_PVT.update_job_operations
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
      p_workorder_rec          => p_x_prd_workorder_rec      ,
      p_operation_tbl          => l_prd_workoper_tbl         ,
      p_material_req_tbl       => l_material_tbl             ,
      p_resource_req_tbl       => l_resource_tbl
    );

    -- Fix for Bug # 8329755 (FP for Bug # 7697909) -- start
    IF l_resource_tbl.COUNT > 0
    THEN
       FOR l_res_count IN l_resource_tbl.FIRST .. l_resource_tbl.LAST
       LOOP
              OPEN c_check_planned_wo(l_resource_tbl(l_res_count).workorder_id);
  	      FETCH c_check_planned_wo INTO l_plan_flag;
	      CLOSE c_check_planned_wo;

	      IF l_plan_flag = 2 THEN

		AHL_PRD_WORKORDER_PVT.Update_Master_Wo_Dates(l_resource_tbl(l_res_count).workorder_id);

	      END IF;
       END LOOP;
    END IF;
    -- Fix for Bug # 8329755 (FP for Bug # 7697909) -- end

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( l_api_name || ' - AHL_EAM_JOB_PVT.update_job_operations succesful' );
    END IF;

  END IF; -- For WIP Load Flag

  -- R12: Serial Reservation enhancements.
  -- Delete existing reservations if cancelling or completing a workorder.
  IF (p_x_prd_workorder_rec.status_code IN (G_JOB_STATUS_COMPLETE_NC, G_JOB_STATUS_COMPLETE,
                                            G_JOB_STATUS_CANCELLED, G_JOB_STATUS_DELETED)) THEN
      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( l_api_name || ' Before - AHL_RSV_RESERVATIONS_PVT.Delete_Reservation');
        AHL_DEBUG_PUB.debug( 'Workorder Status:' || p_x_prd_workorder_rec.status_code);
      END IF;

      FOR get_scheduled_mater_rec IN get_scheduled_mater_csr(p_x_prd_workorder_rec.workorder_id)
      LOOP
         -- Call delete reservation API.
         AHL_RSV_RESERVATIONS_PVT.Delete_Reservation (
                                   p_api_version => 1.0,
                                   p_init_msg_list          => FND_API.G_TRUE             ,
                                   p_commit                 => FND_API.G_FALSE            ,
                                   p_validation_level       => FND_API.G_VALID_LEVEL_FULL ,
                                   p_module_type            => NULL,
                                   x_return_status          => l_return_status            ,
                                   x_msg_count              => l_msg_count                ,
                                   x_msg_data               => l_msg_data                 ,
                                   p_scheduled_material_id  => get_scheduled_mater_rec.scheduled_material_id);

         -- Check return status.
         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            IF ( G_DEBUG = 'Y' ) THEN
                 AHL_DEBUG_PUB.debug('Delete_Reservation failed for schedule material ID: '
                         || get_scheduled_mater_rec.scheduled_material_id);
            END IF; -- G_DEBUG.

            EXIT;
         END IF; -- l_return_status

      END LOOP;

      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

  END IF; -- p_x_prd_workorder_rec.status_code

  -- Balaji added following code for bug # 6680137
  -- Material requirements will be updated to status History for work orders
  -- in status cancelled or closed. These requirements will not be moved to
  -- DP history and will not be available in active demand.
  IF  (
        p_x_prd_workorder_rec.status_code IN (
                                              G_JOB_STATUS_CANCELLED,
                                              G_JOB_STATUS_CLOSED,
                                              G_JOB_STATUS_COMPLETE_NC
                                             )
        AND p_x_prd_workorder_rec.master_workorder_flag = 'N'
      )
  THEN

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			l_debug_module,
			'Cancelling Material Requirement for WO # ->'||p_x_prd_workorder_rec.JOB_NUMBER
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			l_debug_module,
			'Work Order status ->'||p_x_prd_workorder_rec.status_code
		);
	END IF;

	-- Retrieve visit task id if its not already present.
	IF (
	   p_x_prd_workorder_rec.VISIT_TASK_ID IS NULL
	   )
	THEN
	        OPEN c_wo_vtsk_id(p_x_prd_workorder_rec.WORKORDER_ID);
	        FETCH c_wo_vtsk_id INTO p_x_prd_workorder_rec.VISIT_TASK_ID;
	        CLOSE c_wo_vtsk_id;
	END IF;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			l_debug_module,
			'Visit Task Id # ->'||p_x_prd_workorder_rec.VISIT_TASK_ID
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			l_debug_module,
			'Before calling AHL_LTP_REQST_MATRL_PVT.Update_Material_Reqrs_status'
		);
	END IF;

	-- Call LTP API to update material requirement status to History.
	AHL_LTP_REQST_MATRL_PVT.Update_Material_Reqrs_status(
	           p_api_version      => 1.0,
	           p_init_msg_list    => FND_API.G_TRUE,
	           p_commit           => FND_API.G_FALSE,
	           p_validation_level => FND_API.G_VALID_LEVEL_FULL,
	           p_module_type      => NULL,
	           p_visit_task_id    => p_x_prd_workorder_rec.VISIT_TASK_ID,
	           x_return_status    => x_return_status,
	           x_msg_count        => x_msg_count,
	           x_msg_data         => x_msg_data
	 );

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			l_debug_module,
			'return status after call to Update_Material_Reqrs_status -> '|| x_return_status
		);
	END IF;

	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
	  RAISE FND_API.G_EXC_ERROR;
	END IF;

  END IF;

    -- Bug # 8433227 (FP for Bug # 7453393) -- start
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
  		fnd_log.string
  		(
  			fnd_log.level_statement,
  			l_api_name,
  			'p_x_prd_workorder_rec.VISIT_TASK_ID -> '|| p_x_prd_workorder_rec.VISIT_TASK_ID
  		);
    END IF;

    IF p_x_prd_workorder_rec.VISIT_TASK_ID IS NOT NULL
    THEN

        OPEN  get_visit_wo_dates( p_x_prd_workorder_rec.visit_id );
        FETCH get_visit_wo_dates
        INTO  l_visit_start_date,
  	    l_visit_end_date;
        CLOSE get_visit_wo_dates;

        OPEN get_wo_sch_dates(p_x_prd_workorder_rec.wip_entity_id);
        FETCH get_wo_sch_dates INTO l_wo_sch_start_date, l_wo_sch_end_date;
        CLOSE get_wo_sch_dates;

  	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
  		fnd_log.string
  		(
  			fnd_log.level_statement,
  			l_api_name,
  			'p_x_prd_workorder_rec.visit_id -> '|| p_x_prd_workorder_rec.visit_id
  		);
  		fnd_log.string
  		(
  			fnd_log.level_statement,
  			l_api_name,
  			'l_visit_start_date -> '|| TO_DATE(l_visit_start_date , 'DD-MM-YYYY :HH24:MI:ss')
  		);
  		fnd_log.string
  		(
  			fnd_log.level_statement,
  			l_api_name,
  			'l_visit_end_date -> '||TO_DATE(l_visit_end_date , 'DD-MM-YYYY :HH24:MI:ss')
  		);
  		fnd_log.string
  		(
  			fnd_log.level_statement,
  			l_api_name,
  			'l_wo_sch_start_date -> '|| TO_DATE(l_wo_sch_start_date , 'DD-MM-YYYY :HH24:MI:ss')
  		);
  		fnd_log.string
  		(
  			fnd_log.level_statement,
  			l_api_name,
  			'l_wo_sch_end_date -> '|| TO_DATE(l_wo_sch_end_date , 'DD-MM-YYYY :HH24:MI:ss')
  		);
  	END IF;

        IF ( l_wo_sch_start_date < l_visit_start_date OR
  	   l_wo_sch_end_date > l_visit_end_date ) THEN

  	FND_MESSAGE.SET_NAME('AHL','AHL_PRD_SCHD_DT_EXCEEDS_VISIT');
  	FND_MESSAGE.SET_TOKEN('START_DT', TO_CHAR( l_visit_start_date, 'DD-MON-YYYY HH24:MI' ),false);
  	FND_MESSAGE.SET_TOKEN('END_DT', TO_CHAR( l_visit_end_date, 'DD-MON-YYYY HH24:MI' ),false);
  	FND_MSG_PUB.ADD;
  	RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;
  -- Bug # 8433227 (FP for Bug # 7453393)-- end

  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  -- User Hooks
  IF (JTF_USR_HKS.Ok_to_execute('AHL_PRD_WORKORDER_PVT', 'UPDATE_JOB', 'A', 'C' )) THEN

      ahl_prd_workorder_CUHK.update_job_post(
        p_prd_workorder_rec => p_x_prd_workorder_rec,
        p_prd_workoper_tbl  =>  p_x_prd_workoper_tbl,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data,
        x_return_status => l_return_status);

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( l_api_name || ' - Success' );
  END IF;

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_job_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO update_job_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN OTHERS THEN
    ROLLBACK TO update_job_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg(p_pkg_name        =>g_pkg_name,
                              p_procedure_name  =>l_api_name,
                              p_error_text      =>SUBSTRB(SQLERRM,1,240));
    END IF;

    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
END update_job;

PROCEDURE process_jobs
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2,
 p_x_prd_workorder_tbl   IN OUT NOCOPY PRD_WORKORDER_TBL,
 p_prd_workorder_rel_tbl IN            PRD_WORKORDER_REL_TBL
)

AS
  l_api_name     CONSTANT VARCHAR2(30) := 'PROCESS_JOBS';
  l_api_version  CONSTANT NUMBER       := 1.0;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_return_status         VARCHAR2(1);
  l_dummy_op_tbl          prd_workoper_tbl;
  l_operation_tbl         AHL_PRD_OPERATIONS_PVT.prd_operation_tbl;
  l_resource_tbl          AHL_PP_RESRC_REQUIRE_PVT.resrc_require_tbl_type;
  l_material_tbl          AHL_PP_MATERIALS_PVT.req_material_tbl_type;
  l_eam_wo_tbl            EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
  l_eam_wo_relations_tbl  EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
  l_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
  l_eam_res_req_tbl       EAM_PROCESS_WO_PUB.eam_res_tbl_type;
  l_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;

  l_wo_rel_rec_found      BOOLEAN      := FALSE;
  total_operations        NUMBER       := 0;
  total_resources         NUMBER       := 0;
  total_materials         NUMBER       := 0;

BEGIN
  SAVEPOINT process_jobs_PVT;

  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status:=FND_API.G_RET_STS_SUCCESS;

  IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.enable_debug;
  END IF;

  FOR i IN p_x_prd_workorder_tbl.FIRST..p_x_prd_workorder_tbl.LAST LOOP

    IF ( p_x_prd_workorder_tbl(i).batch_id IS NULL OR
         p_x_prd_workorder_tbl(i).batch_id = FND_API.G_MISS_NUM ) THEN
      FND_MESSAGE.set_name('AHL','AHL_PRD_BATCH_ID_NULL');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF ( p_x_prd_workorder_tbl(i).header_id IS NULL OR
         p_x_prd_workorder_tbl(i).header_id = FND_API.G_MISS_NUM ) THEN
      FND_MESSAGE.set_name('AHL','AHL_PRD_HEADER_ID_NULL');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'Processing Batch : ' || p_x_prd_workorder_tbl(i).batch_id  || ' Header : ' || p_x_prd_workorder_tbl(i).header_id );
    END IF;
    IF ( p_x_prd_workorder_tbl(i).dml_operation = 'C' ) THEN

      -- Check if atleast one relationship record exists
						IF p_prd_workorder_rel_tbl.COUNT > 0 THEN
      FOR j IN p_prd_workorder_rel_tbl.FIRST..p_prd_workorder_rel_tbl.LAST LOOP
        IF ( p_x_prd_workorder_tbl(i).header_id = p_prd_workorder_rel_tbl(j).parent_header_id OR
             p_x_prd_workorder_tbl(i).header_id = p_prd_workorder_rel_tbl(j).child_header_id ) THEN
          l_wo_rel_rec_found := TRUE;
          EXIT;
        END IF;
      END LOOP;
						END IF;

-- rroy - post 11.5.10
-- visits without any tasks and therefore without any relations
-- should be pushed to prod without errors
      /*IF ( l_wo_rel_rec_found = FALSE ) THEN
        FND_MESSAGE.set_name('AHL','AHL_PRD_WO_REL_NOT_FOUND');
        FND_MESSAGE.set_token('RECORD', p_x_prd_workorder_tbl(i).header_id);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        l_wo_rel_rec_found := FALSE;
      END IF;
*/
      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( 'Invoking create_job API for Workorder ' || i );
      END IF;

      create_job
      (
        p_api_version          => 1.0,
        p_init_msg_list        => FND_API.G_TRUE,
        p_commit               => FND_API.G_FALSE,
        p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
        p_default              => FND_API.G_FALSE,
        p_module_type          => NULL,
        x_return_status        => l_return_status,
        x_msg_count            => l_msg_count,
        x_msg_data             => l_msg_data,
        p_wip_load_flag        => 'N',
        p_x_prd_workorder_rec  => p_x_prd_workorder_tbl(i),
        x_operation_tbl        => l_operation_tbl,
        x_resource_tbl         => l_resource_tbl,
        x_material_tbl         => l_material_tbl
      );

      IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( 'create_job API Success' );
      END IF;

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( 'Mapping Job Header Record Number : ' || i );
      END IF;

      -- Map all input AHL Job Header record attributes to the
      -- corresponding EAM Job Header record attributes.
      AHL_EAM_JOB_PVT.map_ahl_eam_wo_rec
      (
        p_workorder_rec    => p_x_prd_workorder_tbl(i),
        x_eam_wo_rec       => l_eam_wo_tbl(i)
      );

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( 'Job Header Record Mapping Complete' );
      END IF;

      -- Map all input AHL Operation record attributes to the
      -- corresponding EAM Operation record attributes.
      IF ( l_operation_tbl.COUNT > 0 ) THEN
        FOR j IN l_operation_tbl.FIRST..l_operation_tbl.LAST LOOP

          IF ( G_DEBUG = 'Y' ) THEN
            AHL_DEBUG_PUB.debug( 'Mapping Operation Record Number : ' || j );
          END IF;

          total_operations := total_operations + 1;

          AHL_EAM_JOB_PVT.map_ahl_eam_op_rec
          (
            p_operation_rec    => l_operation_tbl(j),
            x_eam_op_rec       => l_eam_op_tbl(total_operations)
          );

          l_eam_op_tbl(total_operations).batch_id := p_x_prd_workorder_tbl(i).batch_id;
          l_eam_op_tbl(total_operations).header_id := p_x_prd_workorder_tbl(i).header_id;

        END LOOP;

        IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( 'Operations Record Mapping Complete' );
        END IF;
      END IF;

      -- Map all input AHL Material Requirement record attributes to the
      -- corresponding EAM Material Requirement record attributes.
      IF ( l_material_tbl.COUNT > 0 ) THEN
        FOR j IN l_material_tbl.FIRST..l_material_tbl.LAST LOOP

          IF ( G_DEBUG = 'Y' ) THEN
            AHL_DEBUG_PUB.debug( 'Mapping Material Requirement Record Number : ' || j );
          END IF;

          total_materials := total_materials + 1;

          AHL_EAM_JOB_PVT.map_ahl_eam_mat_rec
          (
            p_material_req_rec    => l_material_tbl(j),
            x_eam_mat_req_rec     => l_eam_mat_req_tbl(total_materials)
          );

          l_eam_mat_req_tbl(total_materials).batch_id := p_x_prd_workorder_tbl(i).batch_id;
          l_eam_mat_req_tbl(total_materials).header_id := p_x_prd_workorder_tbl(i).header_id;

        END LOOP;

        IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( 'Material Requirements Record Mapping Complete' );
        END IF;

      END IF;

      -- Map all input AHL Resource Requirement record attributes to the
      -- corresponding EAM Resource Requirement record attributes.
      IF ( l_resource_tbl.COUNT > 0 ) THEN
        FOR j IN l_resource_tbl.FIRST..l_resource_tbl.LAST LOOP

          IF ( G_DEBUG = 'Y' ) THEN
            AHL_DEBUG_PUB.debug( 'Mapping Resource Requirement Record Number : ' || j );
          END IF;

          total_resources := total_resources + 1;

          AHL_EAM_JOB_PVT.map_ahl_eam_res_rec
          (
            p_resource_req_rec    => l_resource_tbl(j),
            x_eam_res_rec         => l_eam_res_req_tbl(total_resources)
          );

          l_eam_res_req_tbl(total_resources).batch_id := p_x_prd_workorder_tbl(i).batch_id;
          l_eam_res_req_tbl(total_resources).header_id := p_x_prd_workorder_tbl(i).header_id;

        END LOOP;

        IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( 'Resource Requirement Record Mapping Complete' );
        END IF;

      END IF;

      IF ( l_operation_tbl.COUNT > 0 ) THEN
        l_operation_tbl.DELETE;
      END IF;

      IF ( l_resource_tbl.COUNT > 0 ) THEN
        l_resource_tbl.DELETE;
      END IF;

      IF ( l_material_tbl.COUNT > 0 ) THEN
        l_material_tbl.DELETE;
      END IF;

    ELSIF ( p_x_prd_workorder_tbl(i).dml_operation = 'U' ) THEN

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( 'Invoking update_job API for Workorder ' || i );
      END IF;

      update_job
      (
        p_api_version          => 1.0,
        p_init_msg_list        => FND_API.G_TRUE,
        p_commit               => FND_API.G_FALSE,
        p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
        p_default              => FND_API.G_FALSE,
        p_module_type          => NULL,
        x_return_status        => l_return_status,
        x_msg_count            => l_msg_count,
        x_msg_data             => l_msg_data,
        p_wip_load_flag        => 'N',
        p_x_prd_workorder_rec  => p_x_prd_workorder_tbl(i),
        p_x_prd_workoper_tbl   => l_dummy_op_tbl
      );

      IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( 'update_job API Success' );
      END IF;

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( 'Mapping Job Header Record Number : ' || i );
      END IF;

      -- Map all input AHL Job Header record attributes to the
      -- corresponding EAM Job Header record attributes.
      AHL_EAM_JOB_PVT.map_ahl_eam_wo_rec
      (
        p_workorder_rec    => p_x_prd_workorder_tbl(i),
        x_eam_wo_rec       => l_eam_wo_tbl(i)
      );

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( 'Job Header Record Mapping Complete' );
      END IF;

    END IF;

  END LOOP;

  IF ( p_prd_workorder_rel_tbl.COUNT > 0 ) THEN
    FOR i IN p_prd_workorder_rel_tbl.FIRST..p_prd_workorder_rel_tbl.LAST LOOP

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( 'Mapping WO Relationship Record Number : ' || i );
      END IF;

      -- Map all input AHL Workorder Relationship attributes to the
      -- corresponding EAM Workorder Relationship attributes.
      AHL_EAM_JOB_PVT.map_ahl_eam_wo_rel_rec
      (
       p_workorder_rel_rec    => p_prd_workorder_rel_tbl(i),
       x_eam_wo_relations_rec => l_eam_wo_relations_tbl(i)
      );

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( 'WO Relationship Record Mapping Complete' );
      END IF;
    END LOOP;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( 'Invoking AHL_EAM_JOB_PVT.process_eam_workorders API');
    AHL_DEBUG_PUB.debug( 'Total Workorders : ' || l_eam_wo_tbl.COUNT);
    AHL_DEBUG_PUB.debug( 'Total Operations : ' || l_eam_op_tbl.COUNT);
    AHL_DEBUG_PUB.debug( 'Total Resources : ' || l_eam_res_req_tbl.COUNT);
    AHL_DEBUG_PUB.debug( 'Total Materials : ' || l_eam_mat_req_tbl.COUNT);
    AHL_DEBUG_PUB.debug( 'Total Relationships : ' || l_eam_wo_relations_tbl.COUNT);
  END IF;


  AHL_EAM_JOB_PVT.process_eam_workorders
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
     p_x_eam_wo_tbl           => l_eam_wo_tbl,
     p_eam_wo_relations_tbl   => l_eam_wo_relations_tbl,
     p_eam_op_tbl             => l_eam_op_tbl,
     p_eam_res_req_tbl        => l_eam_res_req_tbl,
     p_eam_mat_req_tbl        => l_eam_mat_req_tbl
  );
 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'AHL_EAM_JOB_PVT.process_eam_workorders API Success' );
    END IF;

    FOR i IN p_x_prd_workorder_tbl.FIRST..p_x_prd_workorder_tbl.LAST LOOP

      IF ( p_x_prd_workorder_tbl(i).dml_operation = 'C' ) THEN
        IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( l_api_name || 'Updating AHL_WORKORDERS with wip_entity_id for Workorder ' || i );
        END IF;

        UPDATE AHL_WORKORDERS
        SET    wip_entity_id = l_eam_wo_tbl(i).wip_entity_id,
	       object_version_number = p_x_prd_workorder_tbl(i).object_version_number + 1,
               last_update_date      = SYSDATE,
               last_updated_by       = Fnd_Global.USER_ID,
               last_update_login     = Fnd_Global.LOGIN_ID

        WHERE  workorder_id = p_x_prd_workorder_tbl(i).workorder_id;

      IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( l_api_name || 'Before calling Create Job Dispostions ' || i );
          AHL_DEBUG_PUB.debug( 'Workorder Id: ' || p_x_prd_workorder_tbl(i).workorder_id );

        END IF;

  --Call disposition API Post 11.5.10 Changes
  AHL_PRD_DISPOSITION_PVT.create_job_dispositions(
            p_api_version          => 1.0,
            p_init_msg_list        => FND_API.G_TRUE,
            p_commit               => FND_API.G_FALSE,
            p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
            x_return_status        => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data             => l_msg_data,
            p_workorder_id         => p_x_prd_workorder_tbl(i).workorder_id);

      IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

	 ELSIF ( p_x_prd_workorder_tbl(i).dml_operation = 'U' ) THEN
        IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( l_api_name || 'Updating AHL_WORKORDERS with status code for Workorder ' || i );
        END IF;
        --
        UPDATE AHL_WORKORDERS
        SET    status_code = l_eam_wo_tbl(i).status_type,
	       object_version_number = p_x_prd_workorder_tbl(i).object_version_number + 1,
               last_update_date      = SYSDATE,
               last_updated_by       = Fnd_Global.USER_ID,
               last_update_login     = Fnd_Global.LOGIN_ID

        WHERE  workorder_id = p_x_prd_workorder_tbl(i).workorder_id;

   END IF;

    END LOOP;

    IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

  END IF;

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO process_jobs_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO process_jobs_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN OTHERS THEN
    ROLLBACK TO process_jobs_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg(p_pkg_name        =>g_pkg_name,
                              p_procedure_name  =>l_api_name,
                              p_error_text      => SUBSTRB(SQLERRM,1,240));

    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

END process_jobs;

PROCEDURE release_visit_jobs
(
  p_api_version         IN   NUMBER    := 1.0,
  p_init_msg_list       IN   VARCHAR2  := FND_API.G_TRUE,
  p_commit              IN   VARCHAR2  := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  p_default             IN   VARCHAR2  := FND_API.G_FALSE,
  p_module_type         IN   VARCHAR2  := NULL,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_visit_id            IN   NUMBER,
  p_unit_effectivity_id IN   NUMBER,
  p_workorder_id        IN   NUMBER
)
AS
  l_api_name     CONSTANT VARCHAR2(30) := 'release_visit_jobs';
  l_api_version  CONSTANT NUMBER       := 1.0;

  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_return_status         VARCHAR2(1);

  l_input_type            VARCHAR2(3);

  l_wo_count              NUMBER := 0;
  l_workorder_tbl         PRD_WORKORDER_TBL;
  l_workorder_rel_tbl     PRD_WORKORDER_REL_TBL;

  l_workorder_id          NUMBER;
  l_object_version_number NUMBER;
  l_wip_entity_id         NUMBER;
  l_status_code           VARCHAR2(30);

  l_wo_id                 NUMBER;
  l_ovn                   NUMBER;
  l_sts_code              VARCHAR2(30);
  l_wip_id                NUMBER;
  l_mwo_flag              VARCHAR2(1);
  l_child_wo_name               VARCHAR2(80);
  l_parent_wo_name               VARCHAR2(80);

		-- rroy
		-- ACL Changes
		l_wo_name															VARCHAR2(80);
		l_master_wo_flag								VARCHAR2(1);
		-- rroy
		-- ACL Changes

  -- To get the Visit Master Workorder
  CURSOR       get_visit_mwo( c_visit_id NUMBER ) IS
    SELECT     workorder_id,
               object_version_number,
               status_code,
               wip_entity_id,
               workorder_name
    FROM       AHL_WORKORDERS
    WHERE      visit_id = c_visit_id
    AND        status_code <> G_JOB_STATUS_DELETED
    AND        visit_task_id IS NULL;
  -- To get a workorder from the wp_entity_id
  -- Fix for connect by issue
  CURSOR       get_wip_wo( c_wip_entity_id NUMBER ) IS
    SELECT     WO.workorder_id workorder_id,
               WO.object_version_number object_version_number,
               WO.wip_entity_id wip_entity_id,
               WO.status_code status_code,
															WO.master_workorder_flag,
															WO.workorder_name
    FROM       AHL_WORKORDERS WO
    WHERE wip_entity_id = c_wip_entity_id
    AND STATUS_CODE <> G_JOB_STATUS_DELETED;

  -- To get the Child Workorders
  -- Top Down for Release workorders
  CURSOR       get_child_wos( c_wip_entity_id NUMBER ) IS
    SELECT     REL.child_object_id
    FROM       WIP_SCHED_RELATIONSHIPS REL
    WHERE      REL.parent_object_type_id = 1
    AND        REL.child_object_type_id = 1
    START WITH REL.parent_object_id = c_wip_entity_id
        AND    REL.relationship_type = 1
    CONNECT BY REL.parent_object_id = PRIOR REL.child_object_id
        AND    REL.relationship_type = 1
    ORDER BY   level;
-- Fix for connect by issue

  -- To get the Parent Workorders
  -- Top Down for Release workorders
  CURSOR       get_parent_wos( c_wip_entity_id NUMBER ) IS
    SELECT     REL.parent_object_id
    FROM       WIP_SCHED_RELATIONSHIPS REL
    WHERE      REL.parent_object_type_id = 1
    AND        REL.child_object_type_id = 1
    START WITH REL.child_object_id = c_wip_entity_id
        AND    REL.relationship_type = 1
    CONNECT BY REL.child_object_id = PRIOR REL.parent_object_id
        AND    REL.relationship_type = 1
    ORDER BY   level DESC;

  -- To get the UE Master Workorder
  CURSOR       get_ue_mwo( c_unit_effectivity_id NUMBER ) IS
    SELECT     WO.workorder_id workorder_id,
               WO.object_version_number object_version_number,
               WO.status_code status_code,
               WO.wip_entity_id wip_entity_id,
															WO.workorder_name workorder_name,
															WO.master_workorder_flag master_workorder_flag
    FROM       AHL_WORKORDERS WO,
               AHL_VISIT_TASKS_B VT
    WHERE      WO.status_code <> G_JOB_STATUS_DELETED
    AND        WO.visit_task_id = VT.visit_task_id
    AND        VT.task_type_code IN ( 'SUMMARY', 'UNASSOCIATED' )
    AND        VT.unit_effectivity_id = c_unit_effectivity_id;

  -- To get the Workorder
  CURSOR       get_wo( c_workorder_id NUMBER ) IS
    SELECT     workorder_id,
               object_version_number,
               status_code,
               wip_entity_id,
															workorder_name
    FROM       AHL_WORKORDERS
    WHERE      workorder_id =p_workorder_id;

BEGIN
  SAVEPOINT release_visit_jobs_PVT;

  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status:=FND_API.G_RET_STS_SUCCESS;

  IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.enable_debug;
  END IF;
  -- Validate Inputs
  IF ( ( p_workorder_id IS NULL OR
         p_workorder_id = FND_API.G_MISS_NUM ) AND
       ( p_unit_effectivity_id IS NULL OR
         p_unit_effectivity_id = FND_API.G_MISS_NUM ) AND
       ( p_visit_id IS NULL OR
         p_visit_id =  FND_API.G_MISS_NUM ) ) THEN
    FND_MESSAGE.set_name('AHL','AHL_PRD_WRONG_ARGUMENTS');
    FND_MESSAGE.set_token('PROC_NAME', l_api_name);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Determine the type of API call
  IF ( p_workorder_id IS NOT NULL AND
       p_workorder_id <> FND_API.G_MISS_NUM ) THEN
    l_input_type := 'WO';
  ELSIF ( p_unit_effectivity_id IS NOT NULL AND
          p_unit_effectivity_id <> FND_API.G_MISS_NUM ) THEN
    l_input_type := 'UE';
  ELSIF ( p_visit_id IS NOT NULL AND
          p_visit_id <>  FND_API.G_MISS_NUM ) THEN
    l_input_type := 'VST';
  END IF;

  -- Process Visit
  IF ( l_input_type = 'VST' ) THEN

    -- Get the Visit Master Workorder
    OPEN  get_visit_mwo( p_visit_id );
    FETCH get_visit_mwo
    INTO  l_workorder_id,
          l_object_version_number,
          l_status_code,
          l_wip_entity_id,
										l_wo_name;

    IF ( get_visit_mwo%NOTFOUND ) THEN
      FND_MESSAGE.set_name('AHL','AHL_PRD_VISIT_MWO_NOT_FOUND');
      FND_MSG_PUB.add;
      CLOSE get_visit_mwo;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    CLOSE get_visit_mwo;

    -- If the visit needs to be Released, Add the Visit WO in the WO Table
    IF ( l_status_code = G_JOB_STATUS_UNRELEASED OR
         l_status_code = G_JOB_STATUS_DRAFT ) THEN
						-- rroy
						-- ACL Changes
						l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => l_workorder_id,
																																																									p_ue_id => NULL,
																																																									p_visit_id => NULL,
																																																									p_item_instance_id => NULL);


						IF l_return_status = FND_API.G_TRUE THEN
								FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_VST_MWO_RLS_UNTLCKD');
								FND_MESSAGE.Set_Token('WO_NAME', l_wo_name);
								FND_MSG_PUB.ADD;
								RAISE FND_API.G_EXC_ERROR;
						END IF;

						-- rroy
						-- ACL Changes

      l_wo_count := l_wo_count + 1;
      l_workorder_tbl(l_wo_count).dml_operation := 'U';
      l_workorder_tbl(l_wo_count).batch_id := l_wip_entity_id;
      l_workorder_tbl(l_wo_count).header_id := l_wip_entity_id;
      l_workorder_tbl(l_wo_count).workorder_id := l_workorder_id;
      l_workorder_tbl(l_wo_count).object_version_number := l_object_version_number;
      l_workorder_tbl(l_wo_count).status_code := G_JOB_STATUS_RELEASED;
    END IF;

    -- Process all the Child Workorders of the Visit
    FOR child_csr IN get_child_wos( l_wip_entity_id ) LOOP
      OPEN get_wip_wo(child_csr.child_object_id);
      FETCH get_wip_wo INTO l_wo_id, l_ovn, l_wip_id,l_sts_code, l_mwo_flag, l_child_wo_name;
      CLOSE get_wip_wo;

      -- If a Child WO needs to be Released add it in the WO Table
      IF ( l_sts_code = G_JOB_STATUS_UNRELEASED OR
           l_sts_code = G_JOB_STATUS_DRAFT ) THEN
								-- rroy
								-- ACL Changes
								l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => l_wo_id,
																																																									p_ue_id => NULL,
																																																									p_visit_id => NULL,
																																																									p_item_instance_id => NULL);

								IF l_return_status = FND_API.G_TRUE THEN
								IF l_mwo_flag <> 'Y' THEN
										FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_VST_WO_RLS_UNTLCKD');
								ELSE
										FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_VST_MWO_RLS_UNTLCKD');
								END IF;
										FND_MESSAGE.Set_Token('WO_NAME', l_child_wo_name);
										FND_MSG_PUB.ADD;
										RAISE FND_API.G_EXC_ERROR;
								END IF;
								-- rroy
								-- ACL Changes

        l_wo_count := l_wo_count + 1;
        l_workorder_tbl(l_wo_count).dml_operation := 'U';
        l_workorder_tbl(l_wo_count).batch_id := l_wip_entity_id;
        l_workorder_tbl(l_wo_count).header_id := child_csr.child_object_id;
        l_workorder_tbl(l_wo_count).workorder_id := l_wo_id;
        l_workorder_tbl(l_wo_count).object_version_number := l_ovn;
        l_workorder_tbl(l_wo_count).status_code := G_JOB_STATUS_RELEASED;

      END IF;

    END LOOP;

  -- Process UE
  ELSIF ( l_input_type = 'UE' ) THEN

    -- Get the UE Master Workorder
    OPEN  get_ue_mwo( p_unit_effectivity_id );
    FETCH get_ue_mwo
    INTO  l_workorder_id,
          l_object_version_number,
          l_status_code,
          l_wip_entity_id,
										l_wo_name,
										l_master_wo_flag;

    IF ( get_ue_mwo%NOTFOUND ) THEN
      FND_MESSAGE.set_name('AHL','AHL_PRD_MR_MWO_NOT_FOUND');
      FND_MSG_PUB.add;
      CLOSE get_ue_mwo;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    CLOSE get_ue_mwo;

    -- Process all the Parent Workorders of the UE
    FOR parent_csr IN get_parent_wos( l_wip_entity_id ) LOOP
      OPEN get_wip_wo(parent_csr.parent_object_id);
      FETCH get_wip_wo INTO  l_wo_id, l_ovn, l_wip_id,l_sts_code, l_mwo_flag, l_parent_wo_name;
      CLOSE get_wip_wo;

      -- If a Parent WO needs to be Released add it in the WO Table
      IF ( l_sts_code = G_JOB_STATUS_UNRELEASED OR
           l_sts_code = G_JOB_STATUS_DRAFT ) THEN
								-- rroy
								-- ACL Changes
								-- skip the check for master workorders
								l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => l_wo_id,
																																																									p_ue_id => NULL,
																																																									p_visit_id => NULL,
																																																									p_item_instance_id => NULL);

								IF l_return_status = FND_API.G_TRUE THEN
								IF l_mwo_flag <> 'Y' THEN
										FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_MR_WO_RLS_UNTLCKD');
								ELSE
										FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_MR_MWO_RLS_UNTLCKD');
								END IF;
										FND_MESSAGE.Set_Token('WO_NAME', l_parent_wo_name);
										FND_MSG_PUB.ADD;
										RAISE FND_API.G_EXC_ERROR;
								END IF;
								-- rroy
								-- ACL Changes


        l_wo_count := l_wo_count + 1;
        l_workorder_tbl(l_wo_count).dml_operation := 'U';
        l_workorder_tbl(l_wo_count).batch_id := l_wip_entity_id;
        l_workorder_tbl(l_wo_count).header_id := parent_csr.parent_object_id;
        l_workorder_tbl(l_wo_count).workorder_id := l_wo_id;
        l_workorder_tbl(l_wo_count).object_version_number := l_ovn;
        l_workorder_tbl(l_wo_count).status_code := G_JOB_STATUS_RELEASED;

      END IF;

    END LOOP;

    -- If the UE needs to be Released, Add the WO in the WO Table
    IF ( l_status_code = G_JOB_STATUS_UNRELEASED OR
         l_status_code = G_JOB_STATUS_DRAFT ) THEN
						-- rroy
						-- ACL Changes
						l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => l_workorder_id,
																																																									p_ue_id => NULL,
																																																									p_visit_id => NULL,
																																																									p_item_instance_id => NULL);

						IF l_return_status = FND_API.G_TRUE THEN
						IF l_master_wo_flag <> 'Y' THEN
								FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_MR_WO_RLS_UNTLCKD');
						ELSE
								FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_MR_MWO_RLS_UNTLCKD');
						END IF;
								FND_MESSAGE.Set_Token('WO_NAME', l_wo_name);
								FND_MSG_PUB.ADD;
								RAISE FND_API.G_EXC_ERROR;
						END IF;
						-- rroy
						-- ACL Changes

      l_wo_count := l_wo_count + 1;
      l_workorder_tbl(l_wo_count).dml_operation := 'U';
      l_workorder_tbl(l_wo_count).batch_id := l_wip_entity_id;
      l_workorder_tbl(l_wo_count).header_id := l_wip_entity_id;
      l_workorder_tbl(l_wo_count).workorder_id := l_workorder_id;
      l_workorder_tbl(l_wo_count).object_version_number := l_object_version_number;
      l_workorder_tbl(l_wo_count).status_code := G_JOB_STATUS_RELEASED;
    END IF;

    -- Process all the Child Workorders of the UE
    FOR child_csr IN get_child_wos( l_wip_entity_id ) LOOP
      OPEN get_wip_wo(child_csr.child_object_id);
      FETCH get_wip_wo INTO  l_wo_id, l_ovn, l_wip_id,l_sts_code, l_mwo_flag, l_child_wo_name;
      CLOSE get_wip_wo;

      -- If a Child WO needs to be Released add it in the WO Table
      IF ( l_sts_code = G_JOB_STATUS_UNRELEASED OR
           l_sts_code = G_JOB_STATUS_DRAFT ) THEN
						-- rroy
						-- ACL Changes
						l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => l_wo_id,
																																																									p_ue_id => NULL,
																																																									p_visit_id => NULL,
																																																									p_item_instance_id => NULL);
						IF l_return_status = FND_API.G_TRUE THEN
						IF l_mwo_flag <> 'Y' THEN
								FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_MR_WO_RLS_UNTLCKD');
						ELSE
								FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_MR_MWO_RLS_UNTLCKD');
						END IF;
								FND_MESSAGE.Set_Token('WO_NAME', l_child_wo_name);
								FND_MSG_PUB.ADD;
								RAISE FND_API.G_EXC_ERROR;
						END IF;
						-- rroy
						-- ACL Changes

        l_wo_count := l_wo_count + 1;
        l_workorder_tbl(l_wo_count).dml_operation := 'U';
        l_workorder_tbl(l_wo_count).batch_id := l_wip_entity_id;
        l_workorder_tbl(l_wo_count).header_id := child_csr.child_object_id;
        l_workorder_tbl(l_wo_count).workorder_id := l_wo_id;
        l_workorder_tbl(l_wo_count).object_version_number := l_ovn;
        l_workorder_tbl(l_wo_count).status_code := G_JOB_STATUS_RELEASED;

      END IF;

    END LOOP;

  -- Process WO
  ELSIF ( l_input_type = 'WO' ) THEN

    -- Get the Workorder
    OPEN  get_wo( p_workorder_id );
    FETCH get_wo
    INTO  l_workorder_id,
          l_object_version_number,
          l_status_code,
          l_wip_entity_id,
										l_wo_name;

    IF ( get_wo%NOTFOUND ) THEN
      FND_MESSAGE.set_name('AHL','AHL_PRD_WO_NOT_FOUND');
      FND_MSG_PUB.add;
      CLOSE get_wo;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    CLOSE get_wo;

    -- Process all the Parent Workorders of the WO
    FOR parent_csr IN get_parent_wos( l_wip_entity_id ) LOOP
      OPEN get_wip_wo(parent_csr.parent_object_id);
      FETCH get_wip_wo INTO  l_wo_id, l_ovn, l_wip_id,l_sts_code, l_mwo_flag, l_parent_wo_name;
      CLOSE get_wip_wo;

      -- If a Parent WO needs to be Released add it in the WO Table
      IF ( l_sts_code = G_JOB_STATUS_UNRELEASED OR
           l_sts_code = G_JOB_STATUS_DRAFT ) THEN
								-- rroy
								-- ACL Changes
								-- skip the check for master workorders
								l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => l_wo_id,
																																																									p_ue_id => NULL,
																																																									p_visit_id => NULL,
																																																									p_item_instance_id => NULL);
								IF l_return_status = FND_API.G_TRUE THEN
								IF l_mwo_flag <> 'Y' THEN
										FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_WO_RLS_UNTLCKD');
								ELSE
										FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_MWO_RLS_UNTLCKD');
								END IF;
										FND_MESSAGE.Set_Token('WO_NAME', l_parent_wo_name);
										FND_MSG_PUB.ADD;
										RAISE FND_API.G_EXC_ERROR;
								END IF;
								-- rroy
								-- ACL Changes

        l_wo_count := l_wo_count + 1;
        l_workorder_tbl(l_wo_count).dml_operation := 'U';
        l_workorder_tbl(l_wo_count).batch_id := l_wip_entity_id;
        l_workorder_tbl(l_wo_count).header_id := parent_csr.parent_object_id;
        l_workorder_tbl(l_wo_count).workorder_id := l_wo_id;
        l_workorder_tbl(l_wo_count).object_version_number := l_ovn;
        l_workorder_tbl(l_wo_count).status_code := G_JOB_STATUS_RELEASED;

      END IF;

    END LOOP;

    -- If the WO needs to be Released, Add the WO in the WO Table
    IF ( l_status_code = G_JOB_STATUS_UNRELEASED OR
         l_status_code = G_JOB_STATUS_DRAFT ) THEN
						-- rroy
						-- ACL Changes
						l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => l_workorder_id,
																																																									p_ue_id => NULL,
																																																									p_visit_id => NULL,
																																																									p_item_instance_id => NULL);
						IF l_return_status = FND_API.G_TRUE THEN
								FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_WO_RLS_UNTLCKD');
								FND_MESSAGE.Set_Token('WO_NAME', l_wo_name);
								FND_MSG_PUB.ADD;
								RAISE FND_API.G_EXC_ERROR;
						END IF;
						-- rroy
						-- ACL Changes

      l_wo_count := l_wo_count + 1;
      l_workorder_tbl(l_wo_count).dml_operation := 'U';
      l_workorder_tbl(l_wo_count).batch_id := l_wip_entity_id;
      l_workorder_tbl(l_wo_count).header_id := l_wip_entity_id;
      l_workorder_tbl(l_wo_count).workorder_id := l_workorder_id;
      l_workorder_tbl(l_wo_count).object_version_number := l_object_version_number;
      l_workorder_tbl(l_wo_count).status_code := G_JOB_STATUS_RELEASED;
    END IF;

  END IF;

  -- Invoke Process Jobs API to perform the Release
  IF ( l_wo_count > 0 ) THEN
    process_jobs
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
      p_x_prd_workorder_tbl    => l_workorder_tbl,
      p_prd_workorder_rel_tbl  => l_workorder_rel_tbl
    );

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_VISIT_RELEASED');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO release_visit_jobs_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO release_visit_jobs_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN OTHERS THEN
    ROLLBACK TO release_visit_jobs_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg(p_pkg_name        =>g_pkg_name,
                              p_procedure_name  =>l_api_name,
                              p_error_text      => SUBSTRB(SQLERRM,1,240));

    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
END release_visit_jobs;

PROCEDURE validate_dependencies
(
  p_api_version         IN   NUMBER    := 1.0,
  p_init_msg_list       IN   VARCHAR2  := FND_API.G_TRUE,
  p_commit              IN   VARCHAR2  := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  p_default             IN   VARCHAR2  := FND_API.G_FALSE,
  p_module_type         IN   VARCHAR2  := NULL,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_visit_id            IN   NUMBER,
  p_unit_effectivity_id IN   NUMBER,
  p_workorder_id        IN   NUMBER
)
AS
  l_api_name     CONSTANT VARCHAR2(30) := 'validate_dependencies';
  l_api_version  CONSTANT NUMBER       := 1.0;

  l_input_type            VARCHAR2(3);
  l_workorder_name        VARCHAR2(80);
  l_wip_entity_id         NUMBER;
  l_wo_count              NUMBER := 0;
  l_match_found           BOOLEAN := FALSE;

  CURSOR       get_visit_child_wos( c_visit_id NUMBER ) IS
    SELECT     workorder_name,
               wip_entity_id
    FROM       AHL_WORKORDERS
    WHERE      visit_id = c_visit_id
    AND        status_code NOT IN ( G_JOB_STATUS_COMPLETE,
                                    G_JOB_STATUS_COMPLETE_NC,
                                    G_JOB_STATUS_CANCELLED,
                                    G_JOB_STATUS_CLOSED,
                                    G_JOB_STATUS_DELETED );

  CURSOR       get_visit_dependencies( c_visit_id NUMBER, c_wip_entity_id NUMBER ) IS
    SELECT     WO.workorder_name workorder_name
    FROM       AHL_WORKORDERS WO,
               WIP_SCHED_RELATIONSHIPS REL
    WHERE      WO.wip_entity_id = REL.parent_object_id
    AND        WO.visit_id <> c_visit_id
    AND        WO.status_code NOT IN ( G_JOB_STATUS_COMPLETE,
                                       G_JOB_STATUS_COMPLETE_NC,
                                       G_JOB_STATUS_CANCELLED,
                                       G_JOB_STATUS_CLOSED,
                                       G_JOB_STATUS_DELETED )
    AND        REL.parent_object_type_id = 1
    AND        REL.child_object_type_id = 1
    AND        REL.child_object_id = c_wip_entity_id
    AND        REL.relationship_type = 2;

  CURSOR       get_ue_mwo( c_unit_effectivity_id NUMBER ) IS
    SELECT     WO.workorder_name workorder_name,
               WO.wip_entity_id wip_entity_id
    FROM       AHL_WORKORDERS WO,
               AHL_VISIT_TASKS_B VT
    WHERE      WO.visit_task_id = VT.visit_task_id
    AND        WO.status_code NOT IN ( G_JOB_STATUS_COMPLETE,
                                       G_JOB_STATUS_COMPLETE_NC,
                                       G_JOB_STATUS_CANCELLED,
                                       G_JOB_STATUS_CLOSED,
                                       G_JOB_STATUS_DELETED )
    AND        VT.task_type_code IN ( 'SUMMARY', 'UNASSOCIATED' )
    AND        VT.unit_effectivity_id = c_unit_effectivity_id;

-- Fix for connect by issue
  CURSOR       get_child_wos( c_wip_entity_id NUMBER ) IS
    SELECT     WO.wip_entity_id wip_entity_id,
               WO.workorder_name workorder_name
    FROM       AHL_WORKORDERS WO
    WHERE      WO.status_code NOT IN ( G_JOB_STATUS_COMPLETE,
                                       G_JOB_STATUS_COMPLETE_NC,
                                       G_JOB_STATUS_CANCELLED,
                                       G_JOB_STATUS_CLOSED,
                                       G_JOB_STATUS_DELETED )
    AND        WO.wip_entity_id IN (SELECT REL.child_object_id
               FROM WIP_SCHED_RELATIONSHIPS REL
               WHERE REL.parent_object_type_id = 1
               AND        REL.child_object_type_id = 1
               START WITH REL.parent_object_id = c_wip_entity_id
               AND    REL.relationship_type = 1
               CONNECT BY REL.parent_object_id = PRIOR REL.child_object_id
               AND    REL.relationship_type = 1);

  TYPE child_wo_rec IS RECORD
  (
    wip_entity_id  NUMBER,
    workorder_name VARCHAR2(80)
  );

  TYPE child_wo_tbl IS TABLE OF child_wo_rec INDEX BY BINARY_INTEGER;

  l_child_wo_tbl child_wo_tbl;

  CURSOR       get_wo_dependencies( c_wip_entity_id NUMBER ) IS
    SELECT     WO.workorder_name workorder_name,
               WO.wip_entity_id wip_entity_id
    FROM       AHL_WORKORDERS WO,
               WIP_SCHED_RELATIONSHIPS REL
    WHERE      WO.wip_entity_id = REL.parent_object_id
    AND        WO.status_code NOT IN ( G_JOB_STATUS_COMPLETE,
                                       G_JOB_STATUS_COMPLETE_NC,
                                       G_JOB_STATUS_CANCELLED,
                                       G_JOB_STATUS_CLOSED,
                                       G_JOB_STATUS_DELETED )
    AND        REL.parent_object_type_id = 1
    AND        REL.child_object_type_id = 1
    AND        REL.child_object_id = c_wip_entity_id
    AND        REL.relationship_type = 2;

  CURSOR       get_wo( c_workorder_id NUMBER ) IS
    SELECT     workorder_name,
               wip_entity_id
    FROM       AHL_WORKORDERS
    WHERE      workorder_id =p_workorder_id
    AND        status_code NOT IN ( G_JOB_STATUS_COMPLETE,
                                    G_JOB_STATUS_COMPLETE_NC,
                                    G_JOB_STATUS_CANCELLED,
                                    G_JOB_STATUS_CLOSED,
                                    G_JOB_STATUS_DELETED );

BEGIN
  SAVEPOINT validate_dependencies_PVT;

  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status:=FND_API.G_RET_STS_SUCCESS;

  IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Validate Inputs
  IF ( ( p_workorder_id IS NULL OR
         p_workorder_id = FND_API.G_MISS_NUM ) AND
       ( p_unit_effectivity_id IS NULL OR
         p_unit_effectivity_id = FND_API.G_MISS_NUM ) AND
       ( p_visit_id IS NULL OR
         p_visit_id =  FND_API.G_MISS_NUM ) ) THEN
    FND_MESSAGE.set_name('AHL','AHL_PRD_WRONG_ARGUMENTS');
    FND_MESSAGE.set_token('PROC_NAME', l_api_name);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Determine the type of API call
  IF ( p_workorder_id IS NOT NULL AND
       p_workorder_id <> FND_API.G_MISS_NUM ) THEN
    l_input_type := 'WO';
  ELSIF ( p_unit_effectivity_id IS NOT NULL AND
          p_unit_effectivity_id <> FND_API.G_MISS_NUM ) THEN
    l_input_type := 'UE';
  ELSIF ( p_visit_id IS NOT NULL AND
          p_visit_id <>  FND_API.G_MISS_NUM ) THEN
    l_input_type := 'VST';
  END IF;

  -- Validate Visit Dependencies
  IF ( l_input_type = 'VST' ) THEN

    FOR visit_csr IN get_visit_child_wos( p_visit_id ) LOOP

      FOR dep_csr IN get_visit_dependencies( p_visit_id, visit_csr.wip_entity_id ) LOOP
        FND_MESSAGE.set_name('AHL','AHL_PRD_DEP_WO_NOT_CMPL');
        FND_MESSAGE.set_token('WO', visit_csr.workorder_name);
        FND_MESSAGE.set_token('DEP_WO', dep_csr.workorder_name);
        FND_MSG_PUB.add;
      END LOOP;

    END LOOP;

  -- Validate UE Dependencies
  ELSIF ( l_input_type = 'UE' ) THEN

    -- Get the UE Master Workorder
    OPEN  get_ue_mwo( p_unit_effectivity_id );
    FETCH get_ue_mwo
    INTO  l_workorder_name,
          l_wip_entity_id;

    IF ( get_ue_mwo%NOTFOUND ) THEN
      CLOSE get_ue_mwo;
      RETURN;
    END IF;
    CLOSE get_ue_mwo;

    OPEN get_child_wos( l_wip_entity_id );
    LOOP
      EXIT WHEN get_child_wos%NOTFOUND;

      l_wo_count := l_wo_count + 1;
      FETCH get_child_wos
      INTO  l_child_wo_tbl( l_wo_count ).wip_entity_id,
            l_child_wo_tbl( l_wo_count ).workorder_name;
    END LOOP;
    CLOSE get_child_wos;
    -- Removing the below check
				-- as part of fix for bug 4094884
				-- The below check is to see if there are any child workorders
				-- which are not complete
				-- but now all child dependencies are being auto-deleted
				-- Note: At present this API is being used by
				-- cancel_visit_jobs API alone
				-- If this API is called from any other API, then the below validations
				-- may need to be added accordingly
    /*
    FOR dep_csr IN get_wo_dependencies( l_wip_entity_id ) LOOP
      FOR j IN l_child_wo_tbl.FIRST..l_child_wo_tbl.LAST LOOP
        IF ( dep_csr.wip_entity_id = l_child_wo_tbl(j).wip_entity_id ) THEN
          l_match_found := TRUE;
          EXIT;
        END IF;
      END LOOP;

      IF ( l_match_found = TRUE ) THEN
        l_match_found := FALSE;
      ELSE
        FND_MESSAGE.set_name('AHL','AHL_PRD_DEP_WO_NOT_CMPL');
        FND_MESSAGE.set_token('WO', l_workorder_name);
        FND_MESSAGE.set_token('DEP_WO', dep_csr.workorder_name);
        FND_MSG_PUB.add;
      END IF;
    END LOOP;
				*/
				-- Removing the below check
				-- as part of fix for bug 4094884
				-- The below check is to see if there are any child workorders
				-- which are not complete
				-- but now all child dependencies are being auto-deleted
				-- Note: At present this API is being used by
				-- cancel_visit_jobs API alone
				-- If this API is called from any other API, then the below validations
				-- may need to be added accordingly

    /*
    IF l_child_wo_tbl.COUNT > 0 THEN
    --
    FOR i IN l_child_wo_tbl.FIRST..l_child_wo_tbl.LAST LOOP
      FOR dep_csr IN get_wo_dependencies( l_child_wo_tbl(i).wip_entity_id ) LOOP

        FOR j IN l_child_wo_tbl.FIRST..l_child_wo_tbl.LAST LOOP
          IF ( dep_csr.wip_entity_id = l_child_wo_tbl(j).wip_entity_id ) THEN
            l_match_found := TRUE;
            EXIT;
          END IF;
        END LOOP;

        IF ( l_match_found = TRUE ) THEN
          l_match_found := FALSE;
        ELSE
          FND_MESSAGE.set_name('AHL','AHL_PRD_DEP_WO_NOT_CMPL');
          FND_MESSAGE.set_token('WO', l_child_wo_tbl(i).workorder_name);
          FND_MESSAGE.set_token('DEP_WO', dep_csr.workorder_name);
          FND_MSG_PUB.add;
        END IF;
      END LOOP;
    END LOOP;

   END IF;
			*/
  -- Validate WO Dependencies
  ELSIF ( l_input_type = 'WO' ) THEN

    -- Get the Workorder
    OPEN  get_wo( p_workorder_id );
    FETCH get_wo
    INTO  l_workorder_name,
          l_wip_entity_id;

    IF ( get_wo%NOTFOUND ) THEN
      CLOSE get_wo;
      RETURN;
    END IF;
    CLOSE get_wo;
    -- removing the below check
				-- since as part of bug fix for bug #4094884
				-- completion dependencies are deleted automatically.
				-- Note: At present this API is being used by
				-- cancel_visit_jobs API alone
				-- If this API is called from any other API, then the below validations
				-- may need to be added accordingly

    /*
    FOR dep_csr IN get_wo_dependencies( l_wip_entity_id ) LOOP
      FND_MESSAGE.set_name('AHL','AHL_PRD_DEP_WO_NOT_CMPL');
      FND_MESSAGE.set_token('WO', l_workorder_name);
      FND_MESSAGE.set_token('DEP_WO', dep_csr.workorder_name);
      FND_MSG_PUB.add;
    END LOOP;
				*/
  END IF;

  x_msg_count := FND_MSG_PUB.count_msg;
  IF ( x_msg_count > 0 ) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO validate_dependencies_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO validate_dependencies_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN OTHERS THEN
    ROLLBACK TO validate_dependencies_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg(p_pkg_name        =>g_pkg_name,
                              p_procedure_name  =>l_api_name,
                              p_error_text      => SUBSTRB(SQLERRM,1,240));

    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
END validate_dependencies;

FUNCTION are_child_wos_cancelled
(
  p_wip_entity_id  IN NUMBER,
  p_workorder_tbl  IN PRD_WORKORDER_TBL
) RETURN BOOLEAN
IS

  l_match_found BOOLEAN := FALSE;

  -- Get Child WOs which are not cancelled
  CURSOR       get_child_wos( c_wip_entity_id NUMBER ) IS
    SELECT     WO.workorder_id workorder_id
    FROM       AHL_WORKORDERS WO,
               WIP_SCHED_RELATIONSHIPS REL
    WHERE      WO.status_code NOT IN ( G_JOB_STATUS_CANCELLED,
                                       G_JOB_STATUS_DELETED )
    AND        WO.wip_entity_id = REL.child_object_id
    AND        REL.parent_object_id = c_wip_entity_id
    AND        REL.parent_object_type_id = 1
    AND        REL.child_object_type_id = 1
    AND        REL.relationship_type = 1;

BEGIN
  FOR child_csr IN get_child_wos( p_wip_entity_id ) LOOP
    FOR i IN p_workorder_tbl.FIRST..p_workorder_tbl.LAST LOOP
      IF ( p_workorder_tbl(i).workorder_id = child_csr.workorder_id ) THEN
        l_match_found := TRUE;
        EXIT;
      END IF;
    END LOOP;

    IF ( l_match_found = FALSE ) THEN
      RETURN FALSE;
    ELSE
      l_match_found := FALSE;
    END IF;
  END LOOP;
  --Modified by srini not to cancel the master workorders, if all the child work orders were cancelled
  RETURN FALSE;

END are_child_wos_cancelled;

PROCEDURE cancel_visit_jobs
(
  p_api_version         IN   NUMBER    := 1.0,
  p_init_msg_list       IN   VARCHAR2  := FND_API.G_TRUE,
  p_commit              IN   VARCHAR2  := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  p_default             IN   VARCHAR2  := FND_API.G_FALSE,
  p_module_type         IN   VARCHAR2  := NULL,
  x_return_status       OUT NOCOPY  VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_visit_id            IN   NUMBER,
  p_unit_effectivity_id IN   NUMBER,
  p_workorder_id        IN   NUMBER
)
AS
  l_api_name     CONSTANT VARCHAR2(30) := 'cancel_visit_jobs';
  l_api_version  CONSTANT NUMBER       := 1.0;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_return_status         VARCHAR2(1);

  l_input_type            VARCHAR2(3);

  l_wo_count              NUMBER := 0;
  l_mwo_count              NUMBER := 0;
  idx                     NUMBER := 0;
  l_count                 NUMBER := 0;

  /* bug 5104519 - start */
  l_mwo_return_status      VARCHAR2(1);
  --l_mwo_flag 		  VARCHAR2(1);
  l_cannot_cancel_child	  NUMBER;

  l_master_workorder_tbl     PRD_WORKORDER_TBL;
  l_copy_mwo_tbl          PRD_WORKORDER_TBL;
  /* bug 5104519 - end */

  l_workorder_tbl         PRD_WORKORDER_TBL;
  l_workorder_rel_tbl     PRD_WORKORDER_REL_TBL;
  l_workorder_rel_cancel_tbl PRD_WORKORDER_REL_TBL;

  l_ue_count              NUMBER := 0;
  l_unit_effectivity_tbl  AHL_UMP_UNITMAINT_PVT.unit_effectivity_tbl_type;
  l_unit_accomplish_tbl   AHL_UMP_UNITMAINT_PVT.unit_accomplish_tbl_type;
  l_unit_threshold_tbl    AHL_UMP_UNITMAINT_PVT.unit_threshold_tbl_type;

  l_workorder_id          NUMBER;
  l_unit_effectivity_id   NUMBER;
  l_object_version_number NUMBER;
  l_wip_entity_id         NUMBER;
  l_ue_wip_entity_id         NUMBER;
  l_status_code           VARCHAR2(30);
  l_status_meaning        VARCHAR2(80);
  l_eam_wo_tbl            EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
  l_eam_wo_relations_tbl  EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
  l_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
  l_eam_res_req_tbl       EAM_PROCESS_WO_PUB.eam_res_tbl_type;
  l_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
  l_rel_found             BOOLEAN := FALSE;

  l_wo_id                 NUMBER;
  l_ovn                   NUMBER;
  l_sts_code              VARCHAR2(30);
  l_wip_id                NUMBER;
  l_mwo_flag              VARCHAR2(1);
  l_child_wo_name         VARCHAR2(80);
  l_parent_wo_name        VARCHAR2(80);

  -- rroy
  -- ACL Changes
  l_wo_name 	          VARCHAR2(80);
  l_master_wo_flag        VARCHAR2(1);
  -- rroy
  -- ACL Changes

  -- To get the Visit Master Workorder
  CURSOR       get_visit_mwo( c_visit_id NUMBER ) IS
    SELECT     awo.workorder_id,
               awo.object_version_number,
               awo.status_code,
               awo.wip_entity_id,
               awo.workorder_name,
               vst.visit_number
    FROM       AHL_WORKORDERS AWO, AHL_VISITS_B VST
    WHERE      awo.visit_id = c_visit_id
    AND        awo.visit_id = vst.visit_id
    AND        awo.status_code NOT IN (G_JOB_STATUS_DELETED,G_JOB_STATUS_CANCELLED)
    AND        awo.visit_task_id IS NULL;

  -- To get the UE Master Workorder
  CURSOR       get_ue_mwo( c_unit_effectivity_id NUMBER ) IS
    SELECT     WO.workorder_id workorder_id,
               WO.object_version_number wo_object_version_number,
               WO.status_code status_code,
               WO.wip_entity_id wip_entity_id,
               WO.workorder_name workorder_name,
               WO.master_workorder_flag master_workorder_flag
    FROM       AHL_WORKORDERS WO,
               AHL_VISIT_TASKS_B VT
    WHERE      WO.status_code <> G_JOB_STATUS_DELETED
    AND        WO.visit_task_id = VT.visit_task_id
    AND        VT.task_type_code IN ( 'SUMMARY', 'UNASSOCIATED' )
    AND        VT.unit_effectivity_id = c_unit_effectivity_id;

  -- bug 4094884
  -- To get the UE Workorder
  CURSOR       get_ue_wo( c_unit_effectivity_id NUMBER ) IS
    SELECT     WO.wip_entity_id wip_entity_id
    FROM       AHL_WORKORDERS WO,
               AHL_VISIT_TASKS_B VT
    WHERE      WO.status_code <> G_JOB_STATUS_DELETED
    AND        WO.visit_task_id = VT.visit_task_id
    AND        VT.task_type_code NOT IN ('SUMMARY')
    AND        VT.unit_effectivity_id = c_unit_effectivity_id;


  -- To get the Workorder
  CURSOR       get_wo( c_workorder_id NUMBER ) IS
    SELECT     workorder_id,
               object_version_number,
               status_code,
               wip_entity_id,
               workorder_name
    FROM       AHL_WORKORDERS
    WHERE      workorder_id =p_workorder_id;

  -- To get the Child Workorders of a Master Workorder
  -- Fix for connect by issue
  -- Balaji added master workorder flag for bug # 5104519
  /* bug 5104519 - start */
  CURSOR       get_wip_wo(c_wip_entity_id NUMBER ) IS
    SELECT     WO.workorder_id workorder_id,
               WO.object_version_number object_version_number,
               WO.status_code status_code,
               WO.wip_entity_id wip_entity_id,
	       WO.master_workorder_flag,
	       WO.workorder_name
    FROM       AHL_WORKORDERS WO
    WHERE      WO.wip_entity_id = c_wip_entity_id;
  /* bug 5104519 - end */
  -- To get the Child Workorders of a Master Workorder
  CURSOR       get_child_wos( c_wip_entity_id NUMBER ) IS
    SELECT     REL.child_object_id
    FROM       WIP_SCHED_RELATIONSHIPS REL
    WHERE      REL.parent_object_type_id = 1
    AND        REL.child_object_type_id = 1
    START WITH REL.parent_object_id = c_wip_entity_id
        AND    REL.relationship_type = 1
    CONNECT BY REL.parent_object_id = PRIOR REL.child_object_id
        AND    REL.relationship_type = 1
    ORDER BY   level DESC;

  -- To get the Parent Workorders of a Workorder
  CURSOR       get_parent_wos( c_wip_entity_id NUMBER ) IS
    SELECT     REL.parent_object_id
    FROM       WIP_SCHED_RELATIONSHIPS REL
    WHERE      REL.parent_object_type_id = 1
    AND        REL.child_object_type_id = 1
    START WITH REL.child_object_id = c_wip_entity_id
        AND    REL.relationship_type = 1
    CONNECT BY REL.child_object_id = PRIOR REL.parent_object_id
        AND    REL.relationship_type = 1
    ORDER BY   level;

  -- To Get the Top Unplanned UEs for a Visit
  /*
   * As per the mail from Shailaja dated 20-Apr-2005, Cancel Visit Jobs and Cancel MR Jobs will
   * not update the UE Status to 'CANCELLED'. Hence Balaji commented out these 4 cursors.
   * Reference bug #s 4095002 and 4094884.
   */
  /*
  CURSOR       get_visit_mrs( c_visit_id NUMBER ) IS
    SELECT     UE.unit_effectivity_id unit_effectivity_id,
               UE.object_version_number object_version_number
    FROM       AHL_UNIT_EFFECTIVITIES_B UE,
               AHL_VISIT_TASKS_B VT
    WHERE      UE.unit_effectivity_id = VT.unit_effectivity_id
    AND        UE.manually_planned_flag = 'Y'
    -- Check added by balaji by balaji for bug # 4095002
    -- As per the update in the bug, for Manually planned UEs of type SR
    -- Status should not be updated to CANCELLED on workorder or MR or Visit
    -- Cancellation. Hence adding the check to filter out UEs based on SRs.
    AND        UE.object_type <> 'SR'
    AND        VT.task_type_code = 'SUMMARY'
    AND        VT.originating_task_id IS NULL
    AND        VT.unit_effectivity_id IS NOT NULL
    AND        VT.visit_id = c_visit_id;

  -- To Get the Unplanned UE Details
  CURSOR       get_ue_details( c_unit_effectivity_id NUMBER ) IS
    SELECT     UE.object_version_number object_version_number
    FROM       AHL_UNIT_EFFECTIVITIES_B UE
    WHERE      UE.unit_effectivity_id = c_unit_effectivity_id
    AND        UE.manually_planned_flag = 'Y'
    -- Check added by balaji by balaji for bug # 4095002
    -- As per the update in the bug, for Manually planned UEs of type SR
    -- Status should not be updated to CANCELLED on workorder or MR or Visit
    -- Cancellation. Hence adding the check to filter out UEs based on SRs.
    AND        UE.object_type <> 'SR';

  -- To get the UnPlanned UE for a given WO
  CURSOR       get_ue_details_for_wo( c_workorder_id NUMBER ) IS
    SELECT     UE.unit_effectivity_id unit_effectivity_id,
               UE.object_version_number object_version_number
    FROM       AHL_UNIT_EFFECTIVITIES_B UE,
               AHL_VISIT_TASKS_B VT,
               AHL_WORKORDERS WO
    WHERE      UE.unit_effectivity_id = VT.unit_effectivity_id
    AND        UE.manually_planned_flag = 'Y'
    -- Check added by balaji by balaji for bug # 4095002
    -- As per the update in the bug, for Manually planned UEs of type SR
    -- Status should not be updated to CANCELLED on workorder or MR or Visit
    -- Cancellation. Hence adding the check to filter out UEs based on SRs.
    AND        UE.object_type <> 'SR'
    AND        VT.visit_task_id = WO.visit_task_id
    AND        WO.workorder_id = c_workorder_id;

  -- To get all the Parent UnPlanned UEs for a given UE
  CURSOR       get_parent_ues( c_unit_effectivity_id NUMBER ) IS
    SELECT     UE.unit_effectivity_id unit_effectivity_id,
               UE.object_version_number object_version_number
    FROM       AHL_UNIT_EFFECTIVITIES_B UE,
               AHL_UE_RELATIONSHIPS REL
    WHERE      UE.unit_effectivity_id = REL.ue_id
    AND        UE.manually_planned_flag = 'Y'
    -- Check added by balaji by balaji for bug # 4095002
    -- As per the update in the bug, for Manually planned UEs of type SR
    -- Status should not be updated to CANCELLED on workorder or MR or Visit
    -- Cancellation. Hence adding the check to filter out UEs based on SRs.
    AND        UE.object_type <> 'SR'
    START WITH REL.related_ue_id = c_unit_effectivity_id
           AND REL.relationship_code = 'PARENT'
    CONNECT BY REL.related_ue_id = PRIOR REL.ue_id
           AND REL.relationship_code = 'PARENT'
    ORDER BY   level;
    */
				-- To get all the workorders for a visit
				-- that are not master workorders
				CURSOR get_visit_wos(c_visit_id NUMBER)
				IS
				SELECT wip_entity_id
				FROM AHL_WORKORDERS
				WHERE visit_id = c_visit_id
				AND master_workorder_flag <> 'Y';

				-- to see if a workorder is a top level workorder
				-- in the completion dependency hierarchy
				CURSOR get_parent_wos_count(c_wip_entity_id NUMBER)
				IS
				SELECT count(*)
				FROM WIP_SCHED_RELATIONSHIPS
				WHERE child_object_id = c_wip_entity_id
				AND   child_object_type_id = 1
				AND   relationship_type = 2;

				-- to get all the child workorders
				-- for a given top level workorder
				-- completion dependencies

				CURSOR     get_completion_dep_wo_all(c_wip_entity_id NUMBER)
				IS
    SELECT     REL.sched_relationship_id,
															REL.parent_object_id,
															REL.child_object_id
				FROM       --AHL_WORKORDERS WO,
               WIP_SCHED_RELATIONSHIPS REL
    WHERE      --WO.wip_entity_id = REL.child_object_id
               REL.parent_object_type_id = 1
    AND        REL.child_object_type_id = 1
				START WITH REL.parent_object_id = c_wip_entity_id
				AND 							REL.relationship_type = 2
				CONNECT BY REL.parent_object_id = PRIOR REL.child_object_id
				AND 							REL.relationship_type = 2
				ORDER BY level DESC;

    -- to get all the parent wos of a ue mwo
				CURSOR     get_ue_completion_parents(c_wip_entity_id NUMBER)
				IS
    SELECT     REL.sched_relationship_id,
															REL.parent_object_id,
															REL.child_object_id
				FROM       WIP_SCHED_RELATIONSHIPS REL
    WHERE      REL.parent_object_type_id = 1
    AND        REL.child_object_type_id = 1
				START WITH REL.child_object_id = c_wip_entity_id
				AND 							REL.relationship_type = 2
				CONNECT BY REL.child_object_id = PRIOR REL.parent_object_id
				AND 							REL.relationship_type = 2
				ORDER BY level;

				-- To get the immediate parent of a ue wo
				CURSOR     get_immediate_ue_parent(c_wip_entity_id NUMBER)
				IS
    SELECT     REL.sched_relationship_id,
															REL.parent_object_id
				FROM       WIP_SCHED_RELATIONSHIPS REL
    WHERE      REL.child_object_id = c_wip_entity_id
    AND        REL.parent_object_type_id = 1
    AND        REL.child_object_type_id = 1
				AND 							REL.relationship_type = 2;

				get_immediate_ue_parent_rec get_immediate_ue_parent%ROWTYPE;

				-- To get all the immediate child workorders of a
				-- particular workorder
				CURSOR     get_completion_dep_wo(c_wip_entity_id NUMBER)
				IS
    SELECT     REL.sched_relationship_id,
															REL.child_object_id
				FROM       WIP_SCHED_RELATIONSHIPS REL
    WHERE      REL.parent_object_id = c_wip_entity_id
    AND        REL.parent_object_type_id = 1
    AND        REL.child_object_type_id = 1
				AND 							REL.relationship_type = 2;

				-- To get all the immediate parent workorders of a
				-- particular workorder
				CURSOR     get_completion_dep_wo_child(c_wip_entity_id NUMBER)
				IS
    SELECT     REL.sched_relationship_id,
															REL.parent_object_id
				FROM       WIP_SCHED_RELATIONSHIPS REL
    WHERE      REL.child_object_id = c_wip_entity_id
    AND        REL.parent_object_type_id = 1
    AND        REL.child_object_type_id = 1
				AND 							REL.relationship_type = 2;

  /* bug 5104519 - start */
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
  l_exists        VARCHAR2(1);
  /* bug 5104519 - end */

  -- added for bug# 9130108
  l_cancel_flag    VARCHAR2 (1);
  l_visit_number   NUMBER;
  VISIT_VALIDATION_ERR  EXCEPTION;

BEGIN
  SAVEPOINT cancel_visit_jobs_PVT;

  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status:=FND_API.G_RET_STS_SUCCESS;

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  --sikumar: added for FP for ER 5571241 -- Check if user has permission to cancel jobs.
  IF AHL_PRD_UTIL_PKG.Is_Wo_Cancel_Allowed = FND_API.G_FALSE THEN
    FND_MESSAGE.set_name('AHL','AHL_PRD_CANCEL_NOT_ALLOWED');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- Validate Inputs
  IF ( ( p_workorder_id IS NULL OR
         p_workorder_id = FND_API.G_MISS_NUM ) AND
       ( p_unit_effectivity_id IS NULL OR
         p_unit_effectivity_id = FND_API.G_MISS_NUM ) AND
       ( p_visit_id IS NULL OR
         p_visit_id =  FND_API.G_MISS_NUM ) ) THEN
    FND_MESSAGE.set_name('AHL','AHL_PRD_WRONG_ARGUMENTS');
    FND_MESSAGE.set_token('PROC_NAME', l_api_name);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- Validate if Completion Dependencies exist
  validate_dependencies
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
    p_visit_id               => p_visit_id,
    p_unit_effectivity_id    => p_unit_effectivity_id,
    p_workorder_id           => p_workorder_id
  );

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Determine the type of API call
  IF ( p_workorder_id IS NOT NULL AND
       p_workorder_id <> FND_API.G_MISS_NUM ) THEN
    l_input_type := 'WO';
  ELSIF ( p_unit_effectivity_id IS NOT NULL AND
          p_unit_effectivity_id <> FND_API.G_MISS_NUM ) THEN
    l_input_type := 'UE';
  ELSIF ( p_visit_id IS NOT NULL AND
          p_visit_id <>  FND_API.G_MISS_NUM ) THEN
    l_input_type := 'VST';
  END IF;

  -- Process Inputs for Cancelling Workorders
  -- Process Visit
  IF ( l_input_type = 'VST' ) THEN

    -- Get the Visit Master Workorder
    OPEN  get_visit_mwo( p_visit_id );
    FETCH get_visit_mwo
    INTO  l_workorder_id,
          l_object_version_number,
          l_status_code,
          l_wip_entity_id,
          l_wo_name,
          l_visit_number;

    IF ( get_visit_mwo%NOTFOUND ) THEN
      FND_MESSAGE.set_name('AHL','AHL_PRD_VISIT_MWO_NOT_FOUND');
      FND_MSG_PUB.add;
      CLOSE get_visit_mwo;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    CLOSE get_visit_mwo;

    -- rroy
    -- ACL Changes
    l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => l_workorder_id,
                                                       p_ue_id => NULL,
                                                       p_visit_id => NULL,
                                                       p_item_instance_id => NULL);
    IF l_return_status = FND_API.G_TRUE THEN
       FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_VST_MWO_CNCL_UNTLCKD');
       FND_MESSAGE.Set_Token('WO_NAME', l_wo_name);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- rroy
    -- ACL Changes

    -- Check if the Visit WO is in a status which can be cancelled
    IF ( l_status_code = G_JOB_STATUS_COMPLETE OR
         l_status_code = G_JOB_STATUS_COMPLETE_NC OR
         l_status_code = G_JOB_STATUS_CANCELLED OR
         l_status_code = G_JOB_STATUS_CLOSED OR
         l_status_code = G_JOB_STATUS_DELETED ) THEN

       --Get status meaning
       SELECT meaning INTO l_status_meaning
	   FROM fnd_lookup_values_vl
        WHERE lookup_type = 'AHL_JOB_STATUS'
          AND LOOKUP_CODE = l_status_code;
		--
      FND_MESSAGE.set_name('AHL','AHL_PRD_CANCEL_VISIT_STATUS');
      FND_MESSAGE.set_token('STATUS', l_status_meaning );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- apattark start for Bug #9075539 to validate for visit cancellation
    cancel_visit_validate
    (
      p_visit_id               => p_visit_id,
      p_visit_number           => l_visit_number,
      x_cancel_flag            => l_cancel_flag
    );
    -- apattark end for Bug #9075539

    IF (l_cancel_flag = 'N') THEN
      -- return validation error status.
      RAISE VISIT_VALIDATION_ERR;

    END IF;

    -- bug 4094884
    -- need to delete all completion dependencies
    -- if the l_input_type = 'VST' (whole visit is cancelled)
    -- so all the completion dependencies need to be deleted
    -- will use process_eam_workorders

    -- 1. Find all the workorders in the visit that are not master wos
    -- 2. Loop through all the workorders and  find the top level wos
    -- 3. get the entire hierarchy of workorders for all top level workorders
    idx := 1;
    FOR visit_wos_rec IN get_visit_wos(p_visit_id) LOOP
      OPEN get_parent_wos_count(visit_wos_rec.wip_entity_id);
      FETCH get_parent_wos_count INTO l_count;
      CLOSE get_parent_wos_count;
      IF l_count = 0 THEN
        -- this is a top level workorder in the completion dependency hierarchy

        FOR com_dep_rec IN get_completion_dep_wo_all(visit_wos_rec.wip_entity_id) LOOP
          l_rel_found := FALSE;
          IF l_workorder_rel_tbl.COUNT > 0 THEN
             FOR i IN l_workorder_rel_tbl.FIRST..l_workorder_rel_tbl.LAST LOOP
               IF l_workorder_rel_tbl(i).wo_relationship_id = com_dep_rec.sched_relationship_id THEN
                  l_rel_found := TRUE;
                  EXIT;
               END IF;
             END LOOP;
          END IF;

          IF l_rel_found = FALSE THEN
            l_workorder_rel_tbl(idx).wo_relationship_id := com_dep_rec.sched_relationship_id;
            l_workorder_rel_tbl(idx).batch_id := p_visit_id;
            l_workorder_rel_tbl(idx).parent_header_id := idx;
            l_workorder_rel_tbl(idx).child_header_id := idx;
            l_workorder_rel_tbl(idx).parent_wip_entity_id := com_dep_rec.parent_object_id;
            l_workorder_rel_tbl(idx).child_wip_entity_id := com_dep_rec.child_object_id;
            l_workorder_rel_tbl(idx).relationship_type := 2;
            l_workorder_rel_tbl(idx).dml_operation := 'D';
            idx := idx + 1;
          END IF;
        END LOOP;
      END IF;
    END LOOP;

    IF ( l_workorder_rel_tbl.COUNT > 0 ) THEN
      FOR i IN l_workorder_rel_tbl.FIRST..l_workorder_rel_tbl.LAST LOOP

         -- Map all input AHL Workorder Relationship attributes to the
         -- corresponding EAM Workorder Relationship attributes.
         AHL_EAM_JOB_PVT.map_ahl_eam_wo_rel_rec
         (
          p_workorder_rel_rec    => l_workorder_rel_tbl(i),
          x_eam_wo_relations_rec => l_eam_wo_relations_tbl(i)
         );

      END LOOP;
    END IF;


    -- Process all the Child Workorders of the Visit
    FOR child_csr IN get_child_wos( l_wip_entity_id ) LOOP
      /* bug 5104519 - start */
      OPEN get_wip_wo(child_csr.child_object_id);
      FETCH get_wip_wo INTO l_wo_id, l_ovn, l_sts_code,l_wip_id, l_mwo_flag, l_child_wo_name;
      CLOSE get_wip_wo;

      -- If a Child WO needs to be Cancelled add it in the WO Table
      IF ( l_sts_code <> G_JOB_STATUS_COMPLETE AND
           l_sts_code <> G_JOB_STATUS_COMPLETE_NC AND
           l_sts_code <> G_JOB_STATUS_CANCELLED AND
           l_sts_code <> G_JOB_STATUS_CLOSED AND
           l_sts_code <> G_JOB_STATUS_DELETED ) THEN
           -- rroy
           -- ACL Changes
           l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => l_wo_id,
                                                              p_ue_id => NULL,
                                                              p_visit_id => NULL,
                                                              p_item_instance_id => NULL);
           IF l_return_status = FND_API.G_TRUE THEN
              IF l_mwo_flag <> 'Y' THEN
                 FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_VST_WO_CNCL_UNTLCKD');
              ELSE
                 FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_VST_MWO_CNCL_UNTLCKD');
              END IF;
              FND_MESSAGE.Set_Token('WO_NAME', l_child_wo_name);
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
           -- rroy
           -- ACL Changes

 	/*
 	 * Balaji added following logic for bug # 5104519(Reopened issue reported by BANARAYA)
 	 * EAM has a validation which doesnt allow master workorder to be cancelled when all child
 	 * workorders are not in status 7(cancelled),12(closed),14(Pending Close),15(Failed Close).
         * Hence master workorders will be post processed after child workorder processing and will
         * be cancelled or closed accordingly.
 	 */
 	/* bug 5104519 - start */
        IF l_mwo_flag = 'N' THEN

                --sikumar: added for FP for ER 5571241 -- Check if user has permission to cancel jobs.
                IF AHL_PRD_UTIL_PKG.Is_Wo_Cancel_Allowed(l_wo_id) = FND_API.G_FALSE THEN
                  FND_MESSAGE.set_name('AHL','AHL_PRD_CANCEL_NOT_ALLOWED');
                  FND_MSG_PUB.add;
                  RAISE FND_API.G_EXC_ERROR;
                END IF;

		l_wo_count := l_wo_count + 1;
		l_workorder_tbl(l_wo_count).dml_operation := 'U';
		l_workorder_tbl(l_wo_count).batch_id := l_wip_entity_id;
		l_workorder_tbl(l_wo_count).header_id := l_wip_id;
		l_workorder_tbl(l_wo_count).workorder_id := l_wo_id;
		l_workorder_tbl(l_wo_count).object_version_number := l_ovn;
                l_workorder_tbl(l_wo_count).hold_reason_code := FND_API.G_MISS_CHAR;

		-- If the Status is Draft, then, Delete else, Cancel
		IF ( l_sts_code = G_JOB_STATUS_DRAFT ) THEN
		  l_workorder_tbl(l_wo_count).status_code := G_JOB_STATUS_DELETED;
		ELSE
		  l_workorder_tbl(l_wo_count).status_code := G_JOB_STATUS_CANCELLED;
		END IF;
	ELSE
		l_mwo_count := l_mwo_count + 1;
		l_master_workorder_tbl(l_mwo_count).dml_operation := 'U';
		l_master_workorder_tbl(l_mwo_count).batch_id := l_wip_entity_id;
		l_master_workorder_tbl(l_mwo_count).header_id := l_wip_id;
		l_master_workorder_tbl(l_mwo_count).workorder_id := l_wo_id;
		l_master_workorder_tbl(l_mwo_count).object_version_number := l_ovn;

		-- Bug # 9075539 -- start
                l_master_workorder_tbl(l_mwo_count).wip_entity_id :=  l_wip_id;
                -- Bug # 9075539 -- end

		-- If the Status is Draft, then, Delete else, Cancel
		IF ( l_sts_code = G_JOB_STATUS_DRAFT ) THEN
		  l_master_workorder_tbl(l_mwo_count).status_code := G_JOB_STATUS_DELETED;
		ELSE
		  l_master_workorder_tbl(l_mwo_count).status_code := G_JOB_STATUS_CANCELLED;
		END IF;
	END IF;
	/* bug 5104519 - end */
      END IF;

    END LOOP;
    /* bug 5104519 - Start */
    -- Add the Visit WO in the WO Table
    l_mwo_count := l_mwo_count + 1;
    l_master_workorder_tbl(l_mwo_count).dml_operation := 'U';
    l_master_workorder_tbl(l_mwo_count).batch_id := l_wip_entity_id;
    l_master_workorder_tbl(l_mwo_count).header_id := l_wip_entity_id;
    l_master_workorder_tbl(l_mwo_count).workorder_id := l_workorder_id;
    l_master_workorder_tbl(l_mwo_count).object_version_number := l_object_version_number;
    -- fix for bug 9075539
    l_master_workorder_tbl(l_mwo_count).wip_entity_id :=  l_wip_entity_id;
    -- end of fix for bug 9075539
    -- If the Status is Draft, then, Delete else, Cancel
    IF ( l_status_code = G_JOB_STATUS_DRAFT ) THEN
      l_master_workorder_tbl(l_mwo_count).status_code := G_JOB_STATUS_DELETED;
    ELSE
      l_master_workorder_tbl(l_mwo_count).status_code := G_JOB_STATUS_CANCELLED;
    END IF;

  -- Process UE
  ELSIF ( l_input_type = 'UE' ) THEN

    -- Get the UE Master Workorder
    OPEN  get_ue_mwo( p_unit_effectivity_id );
    FETCH get_ue_mwo
    INTO  l_workorder_id,
          l_object_version_number,
          l_status_code,
          l_wip_entity_id,
          l_wo_name,
          l_master_wo_flag;

    IF ( get_ue_mwo%NOTFOUND ) THEN
      FND_MESSAGE.set_name('AHL','AHL_PRD_MR_MWO_NOT_FOUND');
      FND_MSG_PUB.add;
      CLOSE get_ue_mwo;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    CLOSE get_ue_mwo;
    -- rroy
    -- ACL Changes
    l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => l_workorder_id,
                                                       p_ue_id => NULL,
                                                       p_visit_id => NULL,
                                                       p_item_instance_id => NULL);
    IF l_return_status = FND_API.G_TRUE THEN
      IF l_master_wo_flag <> 'Y' THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_MR_WO_CNCL_UNTLCKD');
      ELSE
        FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_MR_MWO_CNCL_UNTLCKD');
      END IF;
      FND_MESSAGE.Set_Token('WO_NAME', l_wo_name);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   -- rroy
   -- ACL Changes

    -- Check if the UE WO is in a status which can be cancelled
    IF ( l_status_code = G_JOB_STATUS_COMPLETE OR
         l_status_code = G_JOB_STATUS_COMPLETE_NC OR
         l_status_code = G_JOB_STATUS_CANCELLED OR
         l_status_code = G_JOB_STATUS_CLOSED OR
         l_status_code = G_JOB_STATUS_DELETED ) THEN
       --Get status meaning
       SELECT meaning INTO l_status_meaning
	   FROM fnd_lookup_values_vl
        WHERE lookup_type = 'AHL_JOB_STATUS'
          AND LOOKUP_CODE = l_status_code;

      FND_MESSAGE.set_name('AHL','AHL_PRD_CANCEL_MR_STATUS');
      FND_MESSAGE.set_token('STATUS', l_status_meaning );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Process all the Child Workorders of the UE
    FOR child_csr IN get_child_wos( l_wip_entity_id ) LOOP
      /* bug 5104519 - start */
      OPEN get_wip_wo(child_csr.child_object_id);
      FETCH get_wip_wo INTO l_wo_id, l_ovn, l_sts_code,l_wip_id, l_mwo_flag, l_child_wo_name;
      CLOSE get_wip_wo;

      -- If a Child WO needs to be Cancelled add it in the WO Table
      IF ( l_sts_code <> G_JOB_STATUS_COMPLETE AND
           l_sts_code <> G_JOB_STATUS_COMPLETE_NC AND
           l_sts_code <> G_JOB_STATUS_CANCELLED AND
           l_sts_code <> G_JOB_STATUS_CLOSED AND
           l_sts_code <> G_JOB_STATUS_DELETED ) THEN
            -- rroy
            -- ACL Changes
            l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => l_wo_id,
                                                               p_ue_id => NULL,
                                                               p_visit_id => NULL,
                                                               p_item_instance_id => NULL);
            IF l_return_status = FND_API.G_TRUE THEN
              IF l_mwo_flag <> 'Y' THEN
                FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_MR_WO_CNCL_UNTLCKD');
              ELSE
                FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_MR_MWO_CNCL_UNTLCKD');
              END IF;
              FND_MESSAGE.Set_Token('WO_NAME', l_child_wo_name);
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
            -- rroy
            -- ACL Changes

	/*
	 * Balaji added following logic for bug # 5104519(Reopened issue reported by BANARAYA)
	 * EAM has a validation which doesnt allow master workorder to be cancelled when all child
	 * workorders are not in status 7(cancelled),12(closed),14(Pending Close),15(Failed Close).
         * Hence master workorders will be post processed after child workorder processing and will
         * be cancelled or closed accordingly.
	 */
	/* bug 5104519 - start */
        IF l_mwo_flag = 'N' THEN

         --sikumar: added for FP for ER 5571241 -- Check if user has permission to cancel jobs.
         IF AHL_PRD_UTIL_PKG.Is_Wo_Cancel_Allowed(l_wo_id) = FND_API.G_FALSE THEN
           FND_MESSAGE.set_name('AHL','AHL_PRD_CANCEL_NOT_ALLOWED');
           FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
	   l_wo_count := l_wo_count + 1;
	   l_workorder_tbl(l_wo_count).dml_operation := 'U';
	   l_workorder_tbl(l_wo_count).batch_id := l_wip_entity_id;
	   l_workorder_tbl(l_wo_count).header_id := child_csr.child_object_id;
	   l_workorder_tbl(l_wo_count).workorder_id := l_wo_id;
	   l_workorder_tbl(l_wo_count).wip_entity_id := l_wip_id;
	   l_workorder_tbl(l_wo_count).object_version_number := l_ovn;
           l_workorder_tbl(l_wo_count).hold_reason_code := FND_API.G_MISS_CHAR;

	   -- If the Status is Draft, then, Delete else, Cancel
	   IF ( l_sts_code = G_JOB_STATUS_DRAFT ) THEN
	      l_workorder_tbl(l_wo_count).status_code := G_JOB_STATUS_DELETED;
	   ELSE
	      l_workorder_tbl(l_wo_count).status_code := G_JOB_STATUS_CANCELLED;
	   END IF;
	ELSE
            l_mwo_count := l_mwo_count + 1;
            l_master_workorder_tbl(l_mwo_count).dml_operation := 'U';
            l_master_workorder_tbl(l_mwo_count).batch_id := l_wip_entity_id;
            l_master_workorder_tbl(l_mwo_count).header_id := child_csr.child_object_id;
            l_master_workorder_tbl(l_mwo_count).workorder_id := l_wo_id;
            l_master_workorder_tbl(l_mwo_count).wip_entity_id := l_wip_id;
            l_master_workorder_tbl(l_mwo_count).object_version_number := l_ovn;

            -- If the Status is Draft, then, Delete else, Cancel
            IF ( l_sts_code = G_JOB_STATUS_DRAFT ) THEN
               l_master_workorder_tbl(l_mwo_count).status_code := G_JOB_STATUS_DELETED;
            ELSE
               l_master_workorder_tbl(l_mwo_count).status_code := G_JOB_STATUS_CANCELLED;
            END IF;
	END IF;
	/* bug 5104519 - start */
      END IF;

    END LOOP;

    /* bug 5104519 - start */
    -- Add the UE WO in the WO Table
    l_mwo_count := l_mwo_count + 1;
    l_master_workorder_tbl(l_mwo_count).dml_operation := 'U';
    l_master_workorder_tbl(l_mwo_count).batch_id := l_wip_entity_id;
    l_master_workorder_tbl(l_mwo_count).header_id := l_wip_entity_id;
    l_master_workorder_tbl(l_mwo_count).workorder_id := l_workorder_id;
    l_master_workorder_tbl(l_mwo_count).wip_entity_id := l_wip_entity_id;
    l_master_workorder_tbl(l_mwo_count).object_version_number := l_object_version_number;

    IF ( l_status_code = G_JOB_STATUS_DRAFT OR
         l_status_code = G_JOB_STATUS_UNRELEASED ) THEN

      -- Need to Release Parents if they are DRAFT or UNRELEASED so,
      -- Release the UE WO which will in-turn release the parent WOs
      release_visit_jobs
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
        p_visit_id               => NULL,
        p_unit_effectivity_id    => NULL,
        p_workorder_id           => l_workorder_id
      );

      IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- Release job updates the OVN. Hence requery the record to get the new OVN.
      -- Balaji added the fix as a part of BAE OVN Fix.
      OPEN  get_ue_mwo( p_unit_effectivity_id );
      FETCH get_ue_mwo
      INTO  l_workorder_id,
            l_object_version_number,
            l_status_code,
            l_wip_entity_id,
            l_wo_name,
	    l_master_wo_flag;
      CLOSE get_ue_mwo;

      l_master_workorder_tbl(l_mwo_count).object_version_number := l_object_version_number;

    END IF;

    -- If the Status is Draft, then, Delete else, Cancel
    IF ( l_status_code = G_JOB_STATUS_DRAFT ) THEN
      l_master_workorder_tbl(l_mwo_count).status_code := G_JOB_STATUS_DELETED;
    ELSE
      l_master_workorder_tbl(l_mwo_count).status_code := G_JOB_STATUS_CANCELLED;
    END IF;
    /* bug 5104519 - end */

    -- Process all the Parent Workorders of the UE
    -- Commented following code for not processing the parents any more
    /*Start of commented code*/
    /*FOR parent_csr IN get_parent_wos( l_wip_entity_id ) LOOP
      OPEN get_wip_wo(parent_csr.parent_object_id);
      FETCH get_wip_wo INTO l_wo_id, l_ovn, l_sts_code,l_wip_id, l_mwo_flag, l_parent_wo_name;
      CLOSE get_wip_wo;

      -- Check if the parent WO needs to be Cancelled
      IF ( l_sts_code <> G_JOB_STATUS_COMPLETE AND
           l_sts_code <> G_JOB_STATUS_COMPLETE_NC AND
           l_sts_code <> G_JOB_STATUS_CANCELLED AND
           l_sts_code <> G_JOB_STATUS_CLOSED AND
           l_sts_code <> G_JOB_STATUS_DELETED ) THEN

        -- Parent WO can be cancelled only if all the children are cancelled
        IF ( are_child_wos_cancelled( parent_csr.parent_object_id, l_workorder_tbl ) ) THEN
								-- rroy
								-- ACL Changes
								l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => l_wo_id,
																																																									p_ue_id => NULL,
																																																									p_visit_id => NULL,
																																																									p_item_instance_id => NULL);
								IF l_return_status = FND_API.G_TRUE THEN
								IF l_mwo_flag <> 'Y' THEN
										FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_MR_WO_CNCL_UNTLCKD');
								ELSE
										FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_MR_MWO_CNCL_UNTLCKD');
								END IF;
										FND_MESSAGE.Set_Token('WO_NAME', l_parent_wo_name);
										FND_MSG_PUB.ADD;
										RAISE FND_API.G_EXC_ERROR;
								END IF;
								-- rroy
								-- ACL Changes

          l_wo_count := l_wo_count + 1;
          l_workorder_tbl(l_wo_count).dml_operation := 'U';
          l_workorder_tbl(l_wo_count).batch_id := l_wip_entity_id;
          l_workorder_tbl(l_wo_count).header_id := parent_csr.parent_object_id;
          l_workorder_tbl(l_wo_count).workorder_id := l_wo_id;
          l_workorder_tbl(l_wo_count).object_version_number := l_ovn;
          l_workorder_tbl(l_wo_count).wip_entity_id := l_wip_id;

          -- If the Status is Draft, then, Delete else, Cancel
          IF ( l_sts_code = G_JOB_STATUS_DRAFT ) THEN
            l_workorder_tbl(l_wo_count).status_code := G_JOB_STATUS_DELETED;
          ELSE
            l_workorder_tbl(l_wo_count).status_code := G_JOB_STATUS_CANCELLED;
          END IF;
        ELSE
          -- No more parents can be cancelled
          EXIT;
        END IF;

      END IF;

    END LOOP;*/
    /*End of commented code*/
				-- adding the relationships to be deleted
				-- delete only those relationships which contain
				-- the ue
				-- 1. first, all the child dependencies of the ue mwo need to be deleted
				idx := 1;
				OPEN get_ue_wo(p_unit_effectivity_id);
				FETCH get_ue_wo INTO l_ue_wip_entity_id;
				CLOSE get_ue_wo;

				FOR com_dep_rec IN get_completion_dep_wo_all(l_ue_wip_entity_id) LOOP
								l_workorder_rel_tbl(idx).wo_relationship_id := com_dep_rec.sched_relationship_id;
								l_workorder_rel_tbl(idx).batch_id := l_ue_wip_entity_id;
								l_workorder_rel_tbl(idx).parent_header_id := idx;
								l_workorder_rel_tbl(idx).child_header_id := idx;
								l_workorder_rel_tbl(idx).parent_wip_entity_id := com_dep_rec.parent_object_id;
								l_workorder_rel_tbl(idx).child_wip_entity_id := com_dep_rec.child_object_id;
								l_workorder_rel_tbl(idx).relationship_type := 2;
								l_workorder_rel_tbl(idx).dml_operation := 'D';
								idx := idx + 1;
				END LOOP;

				FOR com_dep_rec IN get_immediate_ue_parent(l_ue_wip_entity_id) LOOP
								l_workorder_rel_tbl(idx).wo_relationship_id := com_dep_rec.sched_relationship_id;
								l_workorder_rel_tbl(idx).batch_id := l_ue_wip_entity_id;
								l_workorder_rel_tbl(idx).parent_header_id := idx;
								l_workorder_rel_tbl(idx).child_header_id := idx;
								l_workorder_rel_tbl(idx).parent_wip_entity_id := com_dep_rec.parent_object_id;
								l_workorder_rel_tbl(idx).child_wip_entity_id := l_ue_wip_entity_id;
								l_workorder_rel_tbl(idx).relationship_type := 2;
								l_workorder_rel_tbl(idx).dml_operation := 'D';

								idx := idx + 1;
				END LOOP;
				-- 2. second, get all the parents of the ue
				FOR ue_parent_rec IN get_ue_completion_parents(l_ue_wip_entity_id) LOOP
				-- 3. for each parent, check if it is in the list of ue wos to be cancelled
				   FOR i in l_workorder_tbl.FIRST..l_workorder_tbl.LAST LOOP
							  IF l_workorder_tbl(i).wip_entity_id = ue_parent_rec.parent_object_id THEN
									-- This parent is in the list of wos to be cancelled
									-- therefore we need to delete all its child dependencies
											FOR com_dep_rec IN get_completion_dep_wo_all(ue_parent_rec.parent_object_id) LOOP
													-- if the relationship id does not exist already, then
													-- add it to the relationships table
													l_rel_found := FALSE;
													IF l_workorder_rel_tbl.COUNT > 0 THEN
													FOR j in l_workorder_rel_tbl.FIRST..l_workorder_rel_tbl.LAST LOOP
													  IF l_workorder_rel_tbl(j).wo_relationship_id = com_dep_rec.sched_relationship_id THEN
															  l_rel_found := TRUE;
																	EXIT;
															END IF;
													END LOOP;
													END IF;
													IF l_rel_found = FALSE THEN
               -- if relationship does not exist
															-- then add it to the relationships table
															l_workorder_rel_tbl(idx).wo_relationship_id := com_dep_rec.sched_relationship_id;
															l_workorder_rel_tbl(idx).batch_id := l_ue_wip_entity_id;
															l_workorder_rel_tbl(idx).parent_header_id := idx;
															l_workorder_rel_tbl(idx).child_header_id := idx;
															l_workorder_rel_tbl(idx).parent_wip_entity_id := com_dep_rec.parent_object_id;
															l_workorder_rel_tbl(idx).child_wip_entity_id := com_dep_rec.child_object_id;
															l_workorder_rel_tbl(idx).relationship_type := 2;
															l_workorder_rel_tbl(idx).dml_operation := 'D';
															idx := idx + 1;
													END IF;
											END LOOP;
											-- after deleting all the child dependencies
											-- delete its immediate parent dependency
											FOR imm_parents_rec IN get_immediate_ue_parent(ue_parent_rec.parent_object_id) LOOP
															l_workorder_rel_tbl(idx).wo_relationship_id := imm_parents_rec.sched_relationship_id;
															l_workorder_rel_tbl(idx).batch_id := l_ue_wip_entity_id;
															l_workorder_rel_tbl(idx).parent_header_id := idx;
															l_workorder_rel_tbl(idx).child_header_id := idx;
															l_workorder_rel_tbl(idx).parent_wip_entity_id := imm_parents_rec.parent_object_id;
															l_workorder_rel_tbl(idx).child_wip_entity_id := ue_parent_rec.parent_object_id;
															l_workorder_rel_tbl(idx).relationship_type := 2;
															l_workorder_rel_tbl(idx).dml_operation := 'D';
															idx := idx + 1;
											END LOOP;

									END IF;
							END LOOP;
				END LOOP;


  				IF ( l_workorder_rel_tbl.COUNT > 0 ) THEN
    		FOR i IN l_workorder_rel_tbl.FIRST..l_workorder_rel_tbl.LAST LOOP

      -- Map all input AHL Workorder Relationship attributes to the
      -- corresponding EAM Workorder Relationship attributes.
      AHL_EAM_JOB_PVT.map_ahl_eam_wo_rel_rec
      (
       p_workorder_rel_rec    => l_workorder_rel_tbl(i),
       x_eam_wo_relations_rec => l_eam_wo_relations_tbl(i)
      );



      END LOOP;
 		 END IF;

  -- Process Workorder
  ELSIF ( l_input_type = 'WO' ) THEN

    -- Get the Workorder
    OPEN  get_wo( p_workorder_id );
    FETCH get_wo
    INTO  l_workorder_id,
          l_object_version_number,
          l_status_code,
          l_wip_entity_id,
										l_wo_name;

    IF ( get_wo%NOTFOUND ) THEN
      FND_MESSAGE.set_name('AHL','AHL_PRD_WO_NOT_FOUND');
      FND_MSG_PUB.add;
      CLOSE get_wo;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
				-- rroy
				-- ACL Changes
				l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => l_workorder_id,
																																																									p_ue_id => NULL,
																																																									p_visit_id => NULL,
																																																									p_item_instance_id => NULL);
				IF l_return_status = FND_API.G_TRUE THEN
						FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_WO_CNCL_UNTLCKD');
						FND_MESSAGE.Set_Token('WO_NAME', l_wo_name);
						FND_MSG_PUB.ADD;
						RAISE FND_API.G_EXC_ERROR;
				END IF;
				-- rroy
				-- ACL Changes

    CLOSE get_wo;

    --sikumar: added for FP for ER 5571241 -- Check if user has permission to cancel jobs.
    IF AHL_PRD_UTIL_PKG.Is_Wo_Cancel_Allowed(p_workorder_id) = FND_API.G_FALSE THEN
       FND_MESSAGE.set_name('AHL','AHL_PRD_CANCEL_NOT_ALLOWED');
       FND_MSG_PUB.add;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Check if the WO is in a status which can be cancelled
    IF ( l_status_code = G_JOB_STATUS_COMPLETE OR
         l_status_code = G_JOB_STATUS_COMPLETE_NC OR
         l_status_code = G_JOB_STATUS_CANCELLED OR
         l_status_code = G_JOB_STATUS_CLOSED OR
         l_status_code = G_JOB_STATUS_DELETED ) THEN
       --Get status meaning
       SELECT meaning INTO l_status_meaning
	   FROM fnd_lookup_values_vl
        WHERE lookup_type = 'AHL_JOB_STATUS'
          AND LOOKUP_CODE = l_status_code;

      FND_MESSAGE.set_name('AHL','AHL_PRD_CANCEL_WO_STATUS');
      FND_MESSAGE.set_token('STATUS', l_status_meaning );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Add the WO in the WO Table
    l_wo_count := l_wo_count + 1;
    l_workorder_tbl(l_wo_count).dml_operation := 'U';
    l_workorder_tbl(l_wo_count).batch_id := l_wip_entity_id;
    l_workorder_tbl(l_wo_count).header_id := l_wip_entity_id;
    l_workorder_tbl(l_wo_count).workorder_id := l_workorder_id;
    l_workorder_tbl(l_wo_count).object_version_number := l_object_version_number;

    IF ( l_status_code = G_JOB_STATUS_DRAFT OR
         l_status_code = G_JOB_STATUS_UNRELEASED ) THEN

      -- Need to Release Parents if they are DRAFT or UNRELEASED so,
      -- Release the WO which will in-turn release the parent WOs
      release_visit_jobs
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
        p_visit_id               => NULL,
        p_unit_effectivity_id    => NULL,
        p_workorder_id           => l_workorder_id
      );

      IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- Release job updates the OVN. Hence requery the record to get the new OVN.
      -- Balaji added the fix as a part of BAE OVN Fix.
      OPEN  get_wo( p_workorder_id );
      FETCH get_wo
      INTO  l_workorder_id,
            l_object_version_number,
            l_status_code,
            l_wip_entity_id,
            l_wo_name;
      CLOSE get_wo;

      l_workorder_tbl(l_wo_count).object_version_number := l_object_version_number;

    END IF;

    -- If the Status is Draft, then, Delete else, Cancel
    IF ( l_status_code = G_JOB_STATUS_DRAFT ) THEN
      l_workorder_tbl(l_wo_count).status_code := G_JOB_STATUS_DELETED;
    ELSE
      l_workorder_tbl(l_wo_count).status_code := G_JOB_STATUS_CANCELLED;
    END IF;

    -- Process all the Parent Workorders of the WO
    -- Commented following code for not processing the parents any more
    /*Start of commented code*/
    /*
    FOR parent_csr IN get_parent_wos( l_wip_entity_id ) LOOP
      OPEN get_wip_wo(parent_csr.parent_object_id);
      FETCH get_wip_wo INTO l_wo_id, l_ovn, l_sts_code,l_wip_id, l_mwo_flag, l_parent_wo_name;
      CLOSE get_wip_wo;

      -- Check if the parent WO needs to be Cancelled
      IF ( l_sts_code <> G_JOB_STATUS_COMPLETE AND
           l_sts_code <> G_JOB_STATUS_COMPLETE_NC AND
           l_sts_code <> G_JOB_STATUS_CANCELLED AND
           l_sts_code <> G_JOB_STATUS_CLOSED AND
           l_sts_code <> G_JOB_STATUS_DELETED ) THEN

        -- Parent WO can be cancelled only if all the children are cancelled
        IF ( are_child_wos_cancelled( parent_csr.parent_object_id, l_workorder_tbl ) ) THEN
								-- rroy
								-- ACL Changes
								l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => l_wo_id,
																																																									p_ue_id => NULL,
																																																									p_visit_id => NULL,
																																																									p_item_instance_id => NULL);
								IF l_return_status = FND_API.G_TRUE THEN
								IF l_mwo_flag <> 'Y' THEN
										FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_WO_CNCL_UNTLCKD');
								ELSE
										FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_MWO_CNCL_UNTLCKD');
								END IF;
										FND_MESSAGE.Set_Token('WO_NAME', l_parent_wo_name);
										FND_MSG_PUB.ADD;
										RAISE FND_API.G_EXC_ERROR;
								END IF;
								-- rroy
								-- ACL Changes

          l_wo_count := l_wo_count + 1;
          l_workorder_tbl(l_wo_count).dml_operation := 'U';
          l_workorder_tbl(l_wo_count).batch_id := l_wip_entity_id;
          l_workorder_tbl(l_wo_count).header_id := parent_csr.parent_object_id;
          l_workorder_tbl(l_wo_count).workorder_id := l_wo_id;
          l_workorder_tbl(l_wo_count).object_version_number := l_ovn;

          -- If the Status is Draft, then, Delete else, Cancel
          IF ( l_sts_code = G_JOB_STATUS_DRAFT ) THEN
            l_workorder_tbl(l_wo_count).status_code := G_JOB_STATUS_DELETED;
          ELSE
            l_workorder_tbl(l_wo_count).status_code := G_JOB_STATUS_CANCELLED;
          END IF;
        ELSE
          -- No more parents can be cancelled
          EXIT;
        END IF;

      END IF;

    END LOOP;*/
    /*End of commented code*/				-- bug 4094884
				-- need to delete all completion dependencies
				-- if the l_input_type = 'WO'
				-- so all the completion dependencies for the
				-- particular workorder need to be cancelled
				  idx := 1;
						-- first get all the relationships where this workorder is the parent
				  FOR com_dep_rec IN get_completion_dep_wo(l_wip_entity_id) LOOP
								l_workorder_rel_tbl(idx).wo_relationship_id := com_dep_rec.sched_relationship_id;
								l_workorder_rel_tbl(idx).batch_id := l_wip_entity_id;
								l_workorder_rel_tbl(idx).parent_header_id := idx;
								l_workorder_rel_tbl(idx).child_header_id := idx;
								l_workorder_rel_tbl(idx).parent_wip_entity_id := l_wip_entity_id;
								l_workorder_rel_tbl(idx).child_wip_entity_id := com_dep_rec.child_object_id;
								l_workorder_rel_tbl(idx).relationship_type := 2;
								l_workorder_rel_tbl(idx).dml_operation := 'D';
								idx := idx + 1;

						END LOOP;
						-- second, get all the relationships where this workorder is the child
						FOR com_dep_rec IN get_completion_dep_wo_child(l_wip_entity_id) LOOP
								l_workorder_rel_tbl(idx).wo_relationship_id := com_dep_rec.sched_relationship_id;
								l_workorder_rel_tbl(idx).batch_id := l_wip_entity_id;
								l_workorder_rel_tbl(idx).parent_header_id := idx;
								l_workorder_rel_tbl(idx).child_header_id := idx;
								l_workorder_rel_tbl(idx).parent_wip_entity_id := com_dep_rec.parent_object_id;
								l_workorder_rel_tbl(idx).child_wip_entity_id := l_wip_entity_id;
								l_workorder_rel_tbl(idx).relationship_type := 2;
								l_workorder_rel_tbl(idx).dml_operation := 'D';
								idx := idx + 1;

						END LOOP;

  				IF ( l_workorder_rel_tbl.COUNT > 0 ) THEN
    		FOR i IN l_workorder_rel_tbl.FIRST..l_workorder_rel_tbl.LAST LOOP

      -- Map all input AHL Workorder Relationship attributes to the
      -- corresponding EAM Workorder Relationship attributes.
      AHL_EAM_JOB_PVT.map_ahl_eam_wo_rel_rec
      (
       p_workorder_rel_rec    => l_workorder_rel_tbl(i),
       x_eam_wo_relations_rec => l_eam_wo_relations_tbl(i)
      );

      END LOOP;
 		 END IF;

  END IF;
		  -- Bug 4094884
				-- Before cancelling the workorders
				-- delete the workorder completion dependencies
				IF l_eam_wo_relations_tbl.COUNT > 0 THEN
				AHL_EAM_JOB_PVT.process_eam_workorders
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
     p_x_eam_wo_tbl           => l_eam_wo_tbl,
     p_eam_wo_relations_tbl   => l_eam_wo_relations_tbl,
     p_eam_op_tbl             => l_eam_op_tbl,
     p_eam_res_req_tbl        => l_eam_res_req_tbl,
     p_eam_mat_req_tbl        => l_eam_mat_req_tbl
  		);

 			IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
    		RAISE FND_API.G_EXC_ERROR;
				END IF;
				END IF;


  -- Invoke Process Jobs API to perform the WO Cancellation
  IF ( l_wo_count > 0 ) THEN
    process_jobs
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
      p_x_prd_workorder_tbl    => l_workorder_tbl,
      p_prd_workorder_rel_tbl  => l_workorder_rel_cancel_tbl
					);

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  /* bug 5104519 - Start */
 /*
  * Balaji added following logic for bug # 5104519(Reopened issue reported by BANARAYA)
  * EAM has a validation which doesnt allow master workorder to be cancelled when all child
  * workorders are not in status 7(cancelled),12(closed),14(Pending Close),15(Failed Close).
  * Hence master workorders will be post processed after child workorder processing and will
  * be cancelled or closed accordingly as below.
  */
  -- All child workorders are processed.Now process parent workorders in order.
  IF l_mwo_count > 0
  THEN
     FOR l_count IN l_master_workorder_tbl.FIRST .. l_master_workorder_tbl.LAST
     LOOP
                OPEN chk_cmplt_wo_exists(l_master_workorder_tbl(l_count).wip_entity_id);
                FETCH chk_cmplt_wo_exists INTO l_exists;
		CLOSE chk_cmplt_wo_exists;
                /*
                 * If All jobs under a MWO are cancelled(or valid statuses after that)
                 * then cancel MWO else complete Master WO.
                 */
                IF l_exists IS NULL THEN
		        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
				fnd_log.string
				(
					fnd_log.level_statement,
					'ahl.AHL_PRD_WORKORDER_PVT.Cancel_Visit_Jobs',
					'cancelling mwo->'||l_master_workorder_tbl(l_count).workorder_id
				);
		        END IF;
		        -- Bug # 6815689 (FP for Bug # 68156890) -- start
		        l_copy_mwo_tbl(1) := null;
		        -- Bug # 6815689 (FP for Bug # 68156890) -- end

		        l_copy_mwo_tbl(1).dml_operation := l_master_workorder_tbl(l_count).dml_operation;
		        l_copy_mwo_tbl(1).batch_id := l_master_workorder_tbl(l_count).batch_id;
		        l_copy_mwo_tbl(1).header_id := l_master_workorder_tbl(l_count).header_id;
		        l_copy_mwo_tbl(1).workorder_id := l_master_workorder_tbl(l_count).workorder_id;
		        l_copy_mwo_tbl(1).wip_entity_id := l_master_workorder_tbl(l_count).wip_entity_id;
		        l_copy_mwo_tbl(1).object_version_number := l_master_workorder_tbl(l_count).object_version_number;
		        l_copy_mwo_tbl(1).status_code := l_master_workorder_tbl(l_count).status_code;

			process_jobs
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
			   p_x_prd_workorder_tbl    => l_copy_mwo_tbl,
			   p_prd_workorder_rel_tbl  => l_workorder_rel_cancel_tbl
			);

			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
				fnd_log.string
				(
					fnd_log.level_statement,
					'ahl.AHL_PRD_WORKORDER_PVT.Cancel_Visit_Jobs',
					'return status after calling complete_master_wo: ' || l_mwo_return_status
				);
			END IF;

			IF l_return_status = FND_API.G_RET_STS_ERROR THEN
				RAISE FND_API.G_EXC_ERROR;
			ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;

		ELSE
		        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
				fnd_log.string
				(
					fnd_log.level_statement,
					'ahl.AHL_PRD_WORKORDER_PVT.Cancel_Visit_Jobs',
					'completing mwo->'||l_master_workorder_tbl(l_count).workorder_id
				);
		         END IF;

			 l_mwo_return_status := AHL_COMPLETIONS_PVT.complete_master_wo(
				 p_visit_id	=>	null,
				 p_workorder_id	=>	l_master_workorder_tbl(l_count).workorder_id,
				 p_ue_id	=>	null
			 );

			 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
				fnd_log.string
				(
					fnd_log.level_statement,
					'ahl.AHL_PRD_WORKORDER_PVT.Cancel_Visit_Jobs',
					'return status after calling complete_master_wo: ' || l_mwo_return_status
				);
			 END IF;

			 IF l_mwo_return_status = FND_API.G_RET_STS_ERROR THEN
				RAISE FND_API.G_EXC_ERROR;
			 ELSIF l_mwo_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			 END IF;

		END IF;
     END LOOP;
  END IF;
  /* bug 5104519 - End */
  -- Post-Process Inputs for Cancelling Un-Planned MRs in UMP
  -- This step is not required while cancelling WOs during Defferal
  /*
   * As per the mail from Shailaja dated 20-Apr-2005, Cancel Visit Jobs and Cancel MR Jobs will
   * not update the UE Status to 'CANCELLED'. Hence Balaji commented following portion of code
   * which updates the UE status. Reference bug #s 4095002 and 4094884.
   */
  /*
  IF ( NVL( p_module_type, 'X' ) <> 'DF' ) THEN

    -- Process Visit
    IF ( l_input_type = 'VST' ) THEN

      -- Get all the Unplanned Top UEs in the Visit
      FOR mr_csr IN get_visit_mrs( p_visit_id ) LOOP

        l_status_code := AHL_COMPLETIONS_PVT.get_mr_status( mr_csr.unit_effectivity_id );
        -- UEs can be cancelled only if all it's WOs are cancelled
        IF ( l_status_code = G_MR_STATUS_JOBS_CANCELLED ) THEN
          l_ue_count := l_ue_count + 1;
          l_unit_effectivity_tbl(l_ue_count).unit_effectivity_id := mr_csr.unit_effectivity_id;
          l_unit_effectivity_tbl(l_ue_count).object_version_number := mr_csr.object_version_number;
          l_unit_effectivity_tbl(l_ue_count).status_code := G_MR_STATUS_CANCELLED;
        END IF;

      END LOOP;

    -- Process UE
    ELSIF ( l_input_type = 'UE' ) THEN

      -- Get the Unplanned UE Details
      OPEN  get_ue_details( p_unit_effectivity_id );
      FETCH get_ue_details
      INTO  l_object_version_number;

      IF ( get_ue_details%FOUND ) THEN
        CLOSE get_ue_details;

        l_status_code := AHL_COMPLETIONS_PVT.get_mr_status( p_unit_effectivity_id );
        -- UEs can be cancelled only if all it's WOs are cancelled
        IF ( l_status_code = G_MR_STATUS_JOBS_CANCELLED ) THEN
          l_ue_count := l_ue_count + 1;
          l_unit_effectivity_tbl(l_ue_count).unit_effectivity_id := p_unit_effectivity_id;
          l_unit_effectivity_tbl(l_ue_count).object_version_number := l_object_version_number;
          l_unit_effectivity_tbl(l_ue_count).status_code := G_MR_STATUS_CANCELLED;
        END IF;

        -- Get the Parent Unplanned UEs for the given UE
        FOR parent_csr IN get_parent_ues( p_unit_effectivity_id ) LOOP
          OPEN get_ue_details(parent_csr.ue_id);
	         FETCH get_ue_details INTO l_ovn;
       	  CLOSE get_ue_details;

          l_status_code := AHL_COMPLETIONS_PVT.get_mr_status( parent_csr.ue_id );

          -- UEs can be cancelled only if all it's WOs are cancelled
          IF ( l_status_code = G_MR_STATUS_JOBS_CANCELLED ) THEN
            l_ue_count := l_ue_count + 1;
            l_unit_effectivity_tbl(l_ue_count).unit_effectivity_id := parent_csr.ue_id;
            l_unit_effectivity_tbl(l_ue_count).object_version_number := l_ovn;
            l_unit_effectivity_tbl(l_ue_count).status_code := G_MR_STATUS_CANCELLED;
          END IF;

        END LOOP;
      ELSE
						  CLOSE get_ue_details;
      END IF;


    -- Process WO
    ELSIF ( l_input_type = 'WO' ) THEN

      -- Get the UE Details for WO
      OPEN  get_ue_details_for_wo( p_workorder_id );
      FETCH get_ue_details_for_wo
      INTO  l_unit_effectivity_id,
            l_object_version_number;

      IF ( get_ue_details_for_wo%FOUND ) THEN
        l_status_code := AHL_COMPLETIONS_PVT.get_mr_status( l_unit_effectivity_id );
        -- UEs can be cancelled only if all it's WOs are cancelled
        IF ( l_status_code = G_MR_STATUS_JOBS_CANCELLED ) THEN
          l_ue_count := l_ue_count + 1;
          l_unit_effectivity_tbl(l_ue_count).unit_effectivity_id := l_unit_effectivity_id;
          l_unit_effectivity_tbl(l_ue_count).object_version_number := l_object_version_number;
          l_unit_effectivity_tbl(l_ue_count).status_code := G_MR_STATUS_CANCELLED;
        END IF;

        -- Get the Parent Unplanned UEs for the UE associated to WO
        FOR parent_csr IN get_parent_ues( l_unit_effectivity_id ) LOOP
          OPEN get_ue_details(parent_csr.ue_id);
	  FETCH get_ue_details INTO l_ovn;
	  CLOSE get_ue_details;

          l_status_code := AHL_COMPLETIONS_PVT.get_mr_status( parent_csr.ue_id );

          -- UEs can be cancelled only if all it's WOs are cancelled
          IF ( l_status_code = G_MR_STATUS_JOBS_CANCELLED ) THEN
            l_ue_count := l_ue_count + 1;
            l_unit_effectivity_tbl(l_ue_count).unit_effectivity_id := parent_csr.ue_id;
            l_unit_effectivity_tbl(l_ue_count).object_version_number := l_ovn;
            l_unit_effectivity_tbl(l_ue_count).status_code := G_MR_STATUS_CANCELLED;
          END IF;

        END LOOP;

      END IF;

      CLOSE get_ue_details_for_wo;

    END IF;

  END IF;

  -- Cancel Unplanned MRs in UMP
  IF ( l_unit_effectivity_tbl.COUNT > 0 ) THEN

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
      -- Add Debug
      IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
      END IF;
    END IF;
  END IF;
  */
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO cancel_visit_jobs_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO cancel_visit_jobs_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN VISIT_VALIDATION_ERR THEN
    ROLLBACK TO cancel_visit_jobs_PVT;
    x_return_status := 'V';
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN OTHERS THEN
    ROLLBACK TO cancel_visit_jobs_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg(p_pkg_name        =>g_pkg_name,
                              p_procedure_name  =>l_api_name,
                              p_error_text      => SUBSTRB(SQLERRM,1,240));

    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
END cancel_visit_jobs;
--
PROCEDURE Reschedule_Visit_Jobs
(
  p_api_version          IN  NUMBER    := 1.0 ,
  p_init_msg_list        IN  VARCHAR2  :=  FND_API.G_TRUE,
  p_commit               IN  VARCHAR2  :=  FND_API.G_FALSE,
  p_validation_level     IN  NUMBER    :=  FND_API.G_VALID_LEVEL_FULL,
  p_default              IN  VARCHAR2   := FND_API.G_FALSE,
  p_module_type          IN  VARCHAR2  := Null,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_visit_id             IN  NUMBER,
  p_x_scheduled_start_date  IN OUT NOCOPY DATE,
  p_x_scheduled_end_date   IN OUT NOCOPY DATE
)

AS

  l_api_name     CONSTANT VARCHAR2(30) := 'Reschedule_Visit_Jobs';
  l_api_version  CONSTANT NUMBER       := 1.0;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_return_status         VARCHAR2(1);
  l_dummy                 NUMBER;
  l_work_order_id         NUMBER;
  l_status_code           NUMBER;
  l_scheduled_start_date  DATE ;
  l_scheduled_end_date    DATE ;

  l_offset                NUMBER ;
  l_offset_direction      NUMBER := 1;
  l_schedule_method       NUMBER := 1;
  l_ignore_firm_flag      VARCHAR2(1) := 'Y';

  l_object_type_id        NUMBER ;

  l_debug                    VARCHAR2(1)  := 'N';
  l_output_dir               VARCHAR2(80);
  l_debug_filename           VARCHAR2(80);
  l_debug_file_mode          VARCHAR2(1);

  l_prd_workorder_tbl         PRD_WORKORDER_TBL;
  l_prd_workorder_rel_tbl     PRD_WORKORDER_REL_TBL;


CURSOR validate_visit(c_visit_id NUMBER)
    IS
 SELECT 1
   FROM   AHL_VISITS_B
  WHERE  VISIT_ID=c_visit_id;

CURSOR check_workorder_exists(c_visit_id NUMBER)
    IS
 SELECT AWO.WORKORDER_ID,
        AWO.OBJECT_VERSION_NUMBER,
        WIP.WIP_ENTITY_ID,
        AWO.STATUS_CODE,
        WIP.SCHEDULED_START_DATE,
        WIP.SCHEDULED_COMPLETION_DATE
  FROM  AHL_WORKORDERS AWO,
        WIP_DISCRETE_JOBS WIP
 WHERE AWO.VISIT_ID=c_visit_id
   AND AWO.VISIT_TASK_ID IS NULL
   AND AWO.MASTER_WORKORDER_FLAG = 'Y'
   AND AWO.WIP_ENTITY_ID = WIP.WIP_ENTITY_ID
   AND AWO.STATUS_CODE NOT IN ('22', '7');

check_workorder_exists_rec check_workorder_exists%rowtype;

CURSOR get_latest_schedule_dates(c_wip_entity_id IN NUMBER)
 IS
SELECT scheduled_start_date,
       scheduled_completion_date
 FROM wip_discrete_jobs
 WHERE wip_entity_id = c_wip_entity_id;

latest_schedule_dates_rec get_latest_schedule_dates%ROWTYPE;

--cursor to get the master work orders hierarchy that has completed work order beneath and needs expanding.
-- If there is enough buffer to expand the masters without violating scheduled
-- end dates of completed work orders, no expansion takes place
CURSOR mwos_for_comp_wos(c_visit_id IN NUMBER,c_offset_direction IN NUMBER,c_offset IN NUMBER) IS
SELECT DISTINCT CWO.workorder_id workorder_id,
           CWO.object_version_number object_version_number,
           CWO.wip_entity_id wip_entity_id,
           CWO.status_code status_code,
           WIP.SCHEDULED_START_DATE,
           WIP.SCHEDULED_COMPLETION_DATE SCHEDULED_END_DATE,
           level
FROM       AHL_WORKORDERS CWO,
           WIP_SCHED_RELATIONSHIPS REL,
           WIP_DISCRETE_JOBS WIP
WHERE      CWO.wip_entity_id = REL.parent_object_id
AND        CWO.wip_entity_id = WIP.WIP_ENTITY_ID
AND        WIP.firm_planned_flag = '1'
AND        CWO.status_code NOT IN ('22','7','4','5','12')
AND CWO.master_workorder_flag = 'Y'
AND        REL.parent_object_type_id = 1
AND        REL.child_object_type_id = 1
START WITH REL.child_object_id IN
(select wos.wip_entity_id from ahl_workorders wos, WIP_DISCRETE_JOBS WIPS
where wos.wip_entity_id = wips.wip_entity_id
and wips.date_completed IS NOT NULL
and exists (Select 'X' from WIP_DISCRETE_JOBS WIPSP,WIP_SCHED_RELATIONSHIPS RELP
where RELP.child_object_id = wips.wip_entity_id
and RELP.parent_object_id = WIPSP.wip_entity_id
and DECODE(c_offset_direction, 1,WIPSP.scheduled_start_date+c_offset,WIPS.scheduled_completion_date + c_offset)
> DECODE(c_offset_direction, 1,WIPS.scheduled_start_date ,WIPSP.scheduled_completion_date))
and wos.visit_id = c_visit_id)
AND        REL.relationship_type = 1
CONNECT BY  REL.child_object_id = PRIOR REL.parent_object_id
AND        REL.relationship_type = 1
ORDER BY   level DESC,workorder_id asc;

l_prev_workorder_id NUMBER;

-- just for logging pre and post mwo expansion
CURSOR log_mwos_for_comp_wos(c_visit_id IN NUMBER) IS
SELECT DISTINCT CWO.workorder_id,
            CWO.workorder_name,
           CWO.wip_entity_id wip_entity_id,
           CWO.status_code status_code,
           WIP.SCHEDULED_START_DATE,
           WIP.SCHEDULED_COMPLETION_DATE
FROM       AHL_WORKORDERS CWO,
           WIP_SCHED_RELATIONSHIPS REL,
           WIP_DISCRETE_JOBS WIP
WHERE      CWO.wip_entity_id = REL.parent_object_id
AND        CWO.wip_entity_id = WIP.WIP_ENTITY_ID
AND        WIP.firm_planned_flag = '1'
AND        CWO.status_code NOT IN ('22','7','4','5','12')
AND CWO.master_workorder_flag = 'Y'
AND        REL.parent_object_type_id = 1
AND        REL.child_object_type_id = 1
START WITH REL.child_object_id IN
(select wos.wip_entity_id from ahl_workorders wos, WIP_DISCRETE_JOBS WIPS
where wos.wip_entity_id = wips.wip_entity_id
and wips.date_completed IS NOT NULL
and wos.visit_id = c_visit_id)
AND        REL.relationship_type = 1
CONNECT BY  REL.child_object_id = PRIOR REL.parent_object_id
AND        REL.relationship_type = 1
ORDER BY   workorder_id asc;

-- to find out minimum and maximum planning dates based on completed work order scheduled dates
CURSOR get_minmax_comp_schedule_dates(c_visit_id IN NUMBER)
 IS
SELECT min(scheduled_start_date) max_start_date,
       max(scheduled_completion_date) min_end_date
 FROM wip_discrete_jobs wips, ahl_workorders wos
 WHERE wips.wip_entity_id  = wos.wip_entity_id
and wips.date_completed IS NOT NULL
and wos.visit_id = c_visit_id
group by wos.visit_id;

get_minmax_comp_schdates_rec get_minmax_comp_schedule_dates%ROWTYPE;

BEGIN

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string(fnd_log.level_procedure,'ahl.plsql.AHL_PRD_WORKORDER_PVT.Reschedule_Visit_Jobs.begin',
			'At the start of PLSQL procedure');
     END IF;
     -- Standard start of API savepoint
     SAVEPOINT Reschedule_Visit_Jobs;
     --
     IF NOT FND_API.compatible_api_call(l_api_version,
                                        p_api_version,
                                        l_api_name,G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
     -- Initialize message list if p_init_msg_list is set to TRUE
      IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;
     -- Initialize API return status to success
      x_return_status:=FND_API.G_RET_STS_SUCCESS;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string ( fnd_log.level_statement, 'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
         'Request for Rescheduling  Workorders for Visit ID : ' || p_visit_id );
      fnd_log.string ( fnd_log.level_statement, 'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
         'Request for Rescheduling  Workorder Schedule Start Date : ' || p_x_scheduled_start_date );
      fnd_log.string ( fnd_log.level_statement, 'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
         'Request for Rescheduling  Workorder Schedule End Date : ' || p_x_scheduled_end_date );
    END IF;

  ---Begin of the Validation
   OPEN validate_visit(p_visit_id)  ;
   FETCH validate_visit into l_dummy ;
   IF (validate_visit%NOTFOUND) THEN
     FND_MESSAGE.Set_Name('AHL','AHL_PRD_VISIT_NOT_FOUND');
     FND_MSG_PUB.ADD;
     CLOSE validate_visit;
     RAISE FND_API.G_EXC_ERROR;
   END IF;
	 CLOSE validate_visit;

   IF ( G_DEBUG = 'Y' ) THEN
    set_eam_debug_params
    (
      x_debug           => l_debug,
      x_output_dir      => l_output_dir,
      x_debug_file_name => l_debug_filename,
      x_debug_file_mode => l_debug_file_mode
    );
   END IF;

   OPEN check_workorder_exists(p_visit_id);
   FETCH check_workorder_exists into check_workorder_exists_rec;
   IF (check_workorder_exists%NOTFOUND) THEN
		  	FND_MESSAGE.Set_Name('AHL','AHL_PRD_VISIT_MWO_NOT_FOUND');
		  	FND_MSG_PUB.ADD;
				CLOSE check_workorder_exists;
		  	RAISE FND_API.G_EXC_ERROR;
   -- can not move visit if visit wo in  4 -> Complete -- 5 -> Complete No Charge  -- 7 -> Cancelled  -- 12 -> Closed
   ELSIF (check_workorder_exists_rec.status_code IN (4, 5, 7, 12) ) THEN
 	    FND_MESSAGE.Set_Name('AHL','AHL_PRD_JOB_STATUS_INVALID');
	    FND_MSG_PUB.ADD;
	    CLOSE check_workorder_exists;
	    RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE check_workorder_exists;

   -- Allow reschedule for Unreleased, Released and Draft Workorders
   /*Balaji commented out the code for the BAE bug # 4615383 which prevents
   the user from re-scheduling the visit when the visit workorder is in
   status other than 1,3 and 17.However this needs to be modified to the end status
   Complete, Cancelled, Closed and Complete No Charge as per the discussion with
   Shailaja. If the master workorder falls in any of these end statuses then
   rescheduling should be prevented.
   Hence removing this validation instead adding following validation.
   IF (check_workorder_exists_rec.status_code NOT IN ( 1,3,17) )
   THEN
 		  FND_MESSAGE.Set_Name('AHL','AHL_PRD_JOB_STATUS_INVALID');
		  	FND_MSG_PUB.ADD;
					close check_workorder_exists;
		  	RAISE FND_API.G_EXC_ERROR;
   END IF;
   */

   -- min and max scheduled dates possible for visit- check
   OPEN get_minmax_comp_schedule_dates(p_visit_id);
   FETCH get_minmax_comp_schedule_dates INTO get_minmax_comp_schdates_rec.max_start_date,
                                             get_minmax_comp_schdates_rec.min_end_date;
   IF(get_minmax_comp_schedule_dates%FOUND)THEN
     IF(get_minmax_comp_schdates_rec.max_start_date < p_x_scheduled_start_date OR
        get_minmax_comp_schdates_rec.min_end_date > p_x_scheduled_end_date)THEN
        FND_MESSAGE.Set_Name('AHL','AHL_PRD_ENCOMP_CWO_INVALID');
        FND_MESSAGE.SET_TOKEN('MAX_START_DATE',to_char(get_minmax_comp_schdates_rec.max_start_date,'DD-MON-YYYY HH24:MI:SS'));
        FND_MESSAGE.SET_TOKEN('MIN_END_DATE',to_char(get_minmax_comp_schdates_rec.min_end_date,'DD-MON-YYYY HH24:MI:SS'));
	      FND_MSG_PUB.ADD;
	      CLOSE get_minmax_comp_schedule_dates;
        RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
   CLOSE get_minmax_comp_schedule_dates;


   -- rroy
   -- reschedule logic:
   -- 1. Reschedule will be done only if
   -- a) the visit start date and planned end date change
   -- b) only the visit start date changes
   -- 2. If only the visit planned end date changes then
   -- the visit master workorder end date will be updated
   -- 3. for all reschedules, the visit master workorder end date will,
   -- after rescheduling, be updated to the visit planned end date
   -- if while carrying out update, the resulting visit master workorder
   -- end date lies before any of the child workorder end dates
   -- then the EAM APIs will throw an error, which will
   -- probably be the scheduling hierarchy error.
   -- 4. All scheduling will always be forward scheduling

   l_offset := p_x_scheduled_start_date - check_workorder_exists_rec.scheduled_start_date;
   l_schedule_method  := 1; -- forward schedule
   IF (l_offset = 0) THEN
   	-- only the planned end date has changed
   	-- so we need to update the master workorder end date
   	-- with a call to update jobs
   	l_prd_workorder_tbl(1).DML_OPERATION := 'U';
   	l_prd_workorder_tbl(1).WORKORDER_ID := check_workorder_exists_rec.workorder_id;
   	l_prd_workorder_tbl(1).OBJECT_VERSION_NUMBER := check_workorder_exists_rec.object_version_number;
   	l_prd_workorder_tbl(1).STATUS_CODE  := check_workorder_exists_rec.status_code;
   	l_prd_workorder_tbl(1).SCHEDULED_START_DATE  := check_workorder_exists_rec.scheduled_start_date;
   	l_prd_workorder_tbl(1).SCHEDULED_END_DATE    := p_x_scheduled_end_date;
   	--l_prd_workorder_tbl(1).BATCH_ID := 1;
   	--l_prd_workorder_tbl(1).HEADER_ID := 0;
    l_prd_workorder_tbl(1).BATCH_ID := check_workorder_exists_rec.wip_entity_id;
    l_prd_workorder_tbl(1).HEADER_ID := check_workorder_exists_rec.wip_entity_id;


     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string(fnd_log.level_statement, 'ahl.plsql.AHL_PRD_WORKORDER_PVT.Reschedule_Visit_Jobs',
		    'Before Calling Process Jobs ');
     END IF;

   	process_jobs
   	(
      	p_api_version            => 1.0,
      	p_init_msg_list          => FND_API.G_TRUE,
      	p_commit                 => FND_API.G_FALSE,
      	p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
      	p_default                => FND_API.G_TRUE,
      	p_module_type            => NULL,
      	x_return_status          => l_return_status,
      	x_msg_count              => l_msg_count,
      	x_msg_data               => l_msg_data,
      	p_x_prd_workorder_tbl    => l_prd_workorder_tbl,
      	p_prd_workorder_rel_tbl  => l_prd_workorder_rel_tbl
    	);

    	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       		RAISE Fnd_Api.g_exc_error;
    	END IF;
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
         fnd_log.string ( fnd_log.level_statement, 'ahl.plsql.AHL_PRD_WORKORDER_PVT.Reschedule_Visit_Jobs',
         'After calling Process Jobs API to reschedule master workorder' );
      END IF;
      IF FND_API.to_boolean(p_commit) THEN
         COMMIT;
      END IF;
   	  RETURN;
   END IF ; -- IF (l_offset = 0) THEN
    /*
      It is just an assumption. As all the CMRO Workorders Type are 1
    */

    l_object_type_id := 1;

	  IF  l_offset > 0    THEN
      l_offset_direction := 1;
    ELSE
       l_offset_direction := -1;
       l_offset       := l_offset * (-1);
    END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
     fnd_log.string ( fnd_log.level_statement, 'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':', 'Rescheduled Wip Entity ID : ' || check_workorder_exists_rec.wip_entity_id );
     fnd_log.string ( fnd_log.level_statement, 'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':', 'Object Type Id : ' || l_object_type_id );
     fnd_log.string ( fnd_log.level_statement, 'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':', 'Offset : ' || l_offset );
     fnd_log.string ( fnd_log.level_statement, 'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':', 'Offset Direction : ' || l_offset_direction );
   END IF;
    -- fix for move visit issues. Bug 9462278
    --logging master work order dates prior to adjustment by CMRO
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
      FOR mwo_rec IN log_mwos_for_comp_wos(p_visit_id) LOOP
          fnd_log.string
       		(
	            fnd_log.level_statement,
       			'ahl.plsql.AHL_PRD_WORKORDER_PVT.Reschedule_Visit_Jobs',
            'Original Scheduled start and completion dates : '
             || '{mwo_rec.workorder_name : ' || mwo_rec.workorder_name || '}'
            || '{mwo_rec.wip_entity_id : ' || mwo_rec.wip_entity_id || '}'
            || '{ mwo_rec.status_code : ' || mwo_rec.status_code || '}'
            || '{ mwo_rec.SCHEDULED_START_DATE : ' || to_char(mwo_rec.SCHEDULED_START_DATE,'DD-MON-YYYY HH24:MI:SS') || '}'
            || '{mwo_rec.SCHEDULED_COMPLETION_DATE : ' || to_char(mwo_rec.SCHEDULED_COMPLETION_DATE,'DD-MON-YYYY HH24:MI:SS') || '}'

       		);
       END LOOP;
   END IF;

   l_dummy :=1;
   l_prd_workorder_tbl.DELETE;
   l_prev_workorder_id := -1;
   FOR mwo_rec IN mwos_for_comp_wos(p_visit_id,l_offset_direction,l_offset) LOOP
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
           fnd_log.string ( fnd_log.level_statement, 'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':', 'l_offset_direction : ' || l_offset_direction );
           fnd_log.string ( fnd_log.level_statement, 'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':', 'mwo_rec.wip_entity_id : ' || mwo_rec.wip_entity_id );
           fnd_log.string ( fnd_log.level_statement, 'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':', 'Offset : ' || l_offset );
           fnd_log.string ( fnd_log.level_statement, 'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':', 'check_workorder_exists_rec.wip_entity_id : ' || check_workorder_exists_rec.wip_entity_id );
      END IF;
      IF(mwo_rec.workorder_id <> l_prev_workorder_id) THEN
       IF(l_offset_direction = 1 AND mwo_rec.wip_entity_id <> check_workorder_exists_rec.wip_entity_id) THEN
        l_prd_workorder_tbl(l_dummy).SCHEDULED_START_DATE  := mwo_rec.scheduled_start_date - l_offset;
        l_prd_workorder_tbl(l_dummy).SCHEDULED_END_DATE    := mwo_rec.scheduled_end_date;
        l_prd_workorder_tbl(l_dummy).BATCH_ID              := check_workorder_exists_rec.wip_entity_id;
        l_prd_workorder_tbl(l_dummy).HEADER_ID             := mwo_rec.wip_entity_id;
        l_prd_workorder_tbl(l_dummy).DML_OPERATION         := 'U';
        l_prd_workorder_tbl(l_dummy).WORKORDER_ID          := mwo_rec.workorder_id;
        l_prd_workorder_tbl(l_dummy).OBJECT_VERSION_NUMBER := mwo_rec.object_version_number;
        l_prd_workorder_tbl(l_dummy).STATUS_CODE           := mwo_rec.status_code;
        l_dummy                                            := l_dummy + 1;
        IF (fnd_log.level_statement                        >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string ( fnd_log.level_statement, 'ahl.plsql.AHL_PRD_WORKORDER_PVT.Reschedule_Visit_Jobs',
          'Expanding master work order{' || mwo_rec.workorder_id || '}{' || TO_CHAR(l_prd_workorder_tbl(l_dummy -1).SCHEDULED_START_DATE,'DD-MON-YYYY HH24:MI:SS')
          || '}{' || TO_CHAR(l_prd_workorder_tbl(l_dummy -1).SCHEDULED_END_DATE,'DD-MON-YYYY HH24:MI:SS') || '}' );
        END IF;
       ELSIF(l_offset_direction = -1) THEN
        l_prd_workorder_tbl(l_dummy).SCHEDULED_START_DATE  := mwo_rec.scheduled_start_date;
   	    l_prd_workorder_tbl(l_dummy).SCHEDULED_END_DATE    := mwo_rec.scheduled_end_date + l_offset;
   	    l_prd_workorder_tbl(l_dummy).BATCH_ID := check_workorder_exists_rec.wip_entity_id;
	      l_prd_workorder_tbl(l_dummy).HEADER_ID := mwo_rec.wip_entity_id;
	      l_prd_workorder_tbl(l_dummy).DML_OPERATION := 'U';
	      l_prd_workorder_tbl(l_dummy).WORKORDER_ID := mwo_rec.workorder_id;
	      l_prd_workorder_tbl(l_dummy).OBJECT_VERSION_NUMBER := mwo_rec.object_version_number;
	      l_prd_workorder_tbl(l_dummy).STATUS_CODE  := mwo_rec.status_code;
	      l_dummy := l_dummy + 1;
        IF (fnd_log.level_statement                        >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string ( fnd_log.level_statement, 'ahl.plsql.AHL_PRD_WORKORDER_PVT.Reschedule_Visit_Jobs',
          'Expanding master work order{' || mwo_rec.workorder_id || '}{' || TO_CHAR(l_prd_workorder_tbl(l_dummy -1).SCHEDULED_START_DATE,'DD-MON-YYYY HH24:MI:SS')
          || '}{' || TO_CHAR(l_prd_workorder_tbl(l_dummy -1).SCHEDULED_END_DATE,'DD-MON-YYYY HH24:MI:SS') || '}' );
        END IF;
       END IF;
      END IF;
      l_prev_workorder_id := mwo_rec.workorder_id;
   END LOOP;
   IF(l_dummy > 1)THEN
       process_jobs
   	   (
      	p_api_version            => 1.0,
      	p_init_msg_list          => FND_API.G_TRUE,
      	p_commit                 => FND_API.G_FALSE,
      	p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
      	p_default                => FND_API.G_TRUE,
      	p_module_type            => NULL,
      	x_return_status          => l_return_status,
     	  x_msg_count              => l_msg_count,
      	x_msg_data               => l_msg_data,
      	p_x_prd_workorder_tbl    => l_prd_workorder_tbl,
      	p_prd_workorder_rel_tbl  => l_prd_workorder_rel_tbl
    	 );

    	 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       		RAISE Fnd_Api.g_exc_error;
    	 END IF;

       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string
       		(
	            fnd_log.level_statement,
       			'ahl.plsql.AHL_PRD_WORKORDER_PVT.Reschedule_Visit_Jobs',
       			'After calling Process Jobs API to reschedule master workorders expansion'
       		);
       END IF;
   END IF;
    -- fix for move visit issues. Bug 9462278

    --logging master work order dates after adjustment by CMRO
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
      FOR mwo_rec IN log_mwos_for_comp_wos(p_visit_id) LOOP
          fnd_log.string
       		(
	            fnd_log.level_statement,
       			'ahl.plsql.AHL_PRD_WORKORDER_PVT.Reschedule_Visit_Jobs',
            'CMRO Updated but prior to EAM move - Scheduled start and completion dates : '
             || '{mwo_rec.workorder_name : ' || mwo_rec.workorder_name || '}'
            || '{mwo_rec.wip_entity_id : ' || mwo_rec.wip_entity_id || '}'
            || '{ mwo_rec.status_code : ' || mwo_rec.status_code || '}'
            || '{ mwo_rec.SCHEDULED_START_DATE : ' || to_char(mwo_rec.SCHEDULED_START_DATE,'DD-MON-YYYY HH24:MI:SS') || '}'
            || '{mwo_rec.SCHEDULED_COMPLETION_DATE : ' || to_char(mwo_rec.SCHEDULED_COMPLETION_DATE,'DD-MON-YYYY HH24:MI:SS') || '}'

       		);
       END LOOP;
   END IF;

    --Call Eam APi TO Move all the workorders
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
     fnd_log.string ( fnd_log.level_statement, 'ahl.plsql.AHL_PRD_WORKORDER_PVT.Reschedule_Visit_Jobs',
     'Before Calling EAM_WO_NETWORK_UTIL_PVT.Move_WO ' );
   END IF;
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
     fnd_log.string ( fnd_log.level_statement, 'ahl.plsql.AHL_PRD_WORKORDER_PVT.Reschedule_Visit_Jobs',
     '{' || TO_CHAR(p_x_scheduled_start_date,'DD-MON-YYYY HH24:MI:SS') || '}{' || TO_CHAR(l_scheduled_end_date,'DD-MON-YYYY HH24:MI:SS') || '}' );
   END IF;

   -- this code will be executed only when offset is > 0
   EAM_WO_NETWORK_UTIL_PVT.Move_WO
        (
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        p_validation_level     => p_validation_level,
        p_work_object_id       =>  check_workorder_exists_rec.wip_entity_id,
        p_work_object_type_id      => l_object_type_id,
        p_offset_days              => l_offset,  -- 1 Day Default
        p_offset_direction         => l_offset_direction, -- Forward
        p_start_date               => latest_schedule_dates_rec.scheduled_start_date,--p_x_scheduled_start_date,
        p_completion_date          => latest_schedule_dates_rec.scheduled_completion_date,--l_scheduled_end_date,
        p_schedule_method          => l_schedule_method,
	      p_ignore_firm_flag		   => l_ignore_firm_flag,
        x_return_status            => l_return_status,
        x_msg_count                => l_msg_count,
        x_msg_data                 => l_msg_data
   );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE Fnd_Api.g_exc_error;
   END IF;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
   fnd_log.string ( fnd_log.level_statement, 'ahl.plsql.AHL_PRD_WORKORDER_PVT.Reschedule_Visit_Jobs', 'After Calling EAM_WO_NETWORK_UTIL_PVT.Move_WO ' ||l_return_status );
  END IF;

  -- after rescheduling,update the visit master workorder start and end scheduled dates

  l_prd_workorder_tbl.DELETE;
  OPEN check_workorder_exists(p_visit_id);
  FETCH check_workorder_exists into check_workorder_exists_rec;
  CLOSE check_workorder_exists;
  l_prd_workorder_tbl(1).DML_OPERATION         := 'U';
  l_prd_workorder_tbl(1).WORKORDER_ID          := check_workorder_exists_rec.workorder_id;
  l_prd_workorder_tbl(1).OBJECT_VERSION_NUMBER := check_workorder_exists_rec.object_version_number;
  l_prd_workorder_tbl(1).STATUS_CODE           := check_workorder_exists_rec.status_code;
  l_prd_workorder_tbl(1).SCHEDULED_START_DATE  := p_x_scheduled_start_date;
  l_prd_workorder_tbl(1).SCHEDULED_END_DATE    := p_x_scheduled_end_date;
  l_prd_workorder_tbl(1).BATCH_ID := check_workorder_exists_rec.wip_entity_id;
  l_prd_workorder_tbl(1).HEADER_ID := check_workorder_exists_rec.wip_entity_id;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string ( fnd_log.level_statement, 'ahl.plsql.AHL_PRD_WORKORDER_PVT.Reschedule_Visit_Jobs.end', 'calling process_jobs' );
  END IF;

  process_jobs
  (
      	p_api_version            => 1.0,
      	p_init_msg_list          => FND_API.G_TRUE,
      	p_commit                 => FND_API.G_FALSE,
      	p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
      	p_default                => FND_API.G_TRUE,
      	p_module_type            => NULL,
      	x_return_status          => l_return_status,
     	x_msg_count              => l_msg_count,
      	x_msg_data               => l_msg_data,
      	p_x_prd_workorder_tbl    => l_prd_workorder_tbl,
      	p_prd_workorder_rel_tbl  => l_prd_workorder_rel_tbl
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
   OPEN get_latest_schedule_dates(check_workorder_exists_rec.wip_entity_id);
   FETCH get_latest_schedule_dates INTO latest_schedule_dates_rec;
   CLOSE get_latest_schedule_dates;
   IF p_x_scheduled_end_date <> latest_schedule_dates_rec.scheduled_completion_date
   THEN
      -- Initialize the message list not to show the EAM Error message
      IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;
	    FND_MESSAGE.Set_Name('AHL','AHL_PRD_PLANNED_DATE_INVALID');
      FND_MESSAGE.SET_TOKEN('DATE',latest_schedule_dates_rec.scheduled_completion_date);
  	  FND_MSG_PUB.ADD;
    END IF;
  	RAISE Fnd_Api.g_exc_error;

  END IF;

  --
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string ( fnd_log.level_procedure, 'ahl.plsql.AHL_PRD_WORKORDER_PVT.Reschedule_Visit_Jobs.end', 'At the end of PLSQL procedure' );
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Reschedule_Visit_Jobs;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Reschedule_Visit_Jobs;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN OTHERS THEN
    ROLLBACK TO Reschedule_Visit_Jobs;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg(p_pkg_name        =>g_pkg_name,
                              p_procedure_name  =>l_api_name,
                              p_error_text      => SUBSTRB(SQLERRM,1,240));

    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

END Reschedule_Visit_Jobs;


PROCEDURE INSERT_TURNOVER_NOTES
(
  p_api_version          IN  NUMBER    := 1.0 ,
  p_init_msg_list        IN  VARCHAR2  :=  FND_API.G_TRUE,
  p_commit               IN  VARCHAR2  :=  FND_API.G_FALSE,
  p_validation_level     IN  NUMBER    :=  FND_API.G_VALID_LEVEL_FULL,
  p_default              IN  VARCHAR2   := FND_API.G_FALSE,
  p_module_type          IN  VARCHAR2  := Null,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_trunover_notes_tbl	 IN OUT NOCOPY	AHL_PRD_WORKORDER_PVT.turnover_notes_tbl_type
) IS

   l_api_version      CONSTANT NUMBER := 1.0;
   l_api_name         CONSTANT VARCHAR2(30) := 'INSERT_TURNOVER_NOTES';

   CURSOR get_user_id_csr(p_emp_name VARCHAR2, p_org_id NUMBER) IS

   /* fix for perf. bug# 4919298.
   SELECT FU.user_id, PF.person_id FROM fnd_user FU,PER_PEOPLE_F PF, HR_ORGANIZATION_UNITS HOU, PER_PERSON_TYPES PEPT, BOM_RESOURCE_EMPLOYEES BRE
   WHERE NVL(PF.CURRENT_EMPLOYEE_FLAG, 'X') = 'Y'
   AND PEPT.PERSON_TYPE_ID = PF.PERSON_TYPE_ID
   AND PEPT.SYSTEM_PERSON_TYPE = 'EMP'
   AND PF.PERSON_ID = BRE.PERSON_ID
   AND (TRUNC(SYSDATE) BETWEEN PF.EFFECTIVE_START_DATE AND PF.EFFECTIVE_END_DATE)
   AND HOU.BUSINESS_GROUP_ID = PF.BUSINESS_GROUP_ID
   AND HOU.ORGANIZATION_ID = NVL(p_org_id,HOU.ORGANIZATION_ID)
   --AND NVL(FU.employee_id,-1) = PF.person_id
   AND FU.employee_id = PF.person_id  -- removed NVL to avoid FTS on fnd_user.
   AND UPPER(PF.FULL_NAME) like UPPER(p_emp_name);
   */

    SELECT DISTINCT bre.person_id, fu.user_id
    FROM  mtl_employees_current_view pf, bom_resource_employees bre, fnd_user fu
    WHERE pf.employee_id=bre.person_id
      and pf.organization_id = bre.organization_id
      and sysdate between BRE.EFFECTIVE_START_DATE and BRE.EFFECTIVE_END_DATE
      and FU.employee_id = pf.employee_id
      and pf.organization_id= p_org_id
      and UPPER(pf.full_name) like UPPER(p_emp_name);


   l_user_id NUMBER;
   l_count NUMBER;
   matchFound BOOLEAN;

BEGIN
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_WORKORDER_PVT.INSERT_TURNOVER_NOTES.begin',
			'At the start of PLSQL procedure'
		);
  END IF;
  -- Standard start of API savepoint
  SAVEPOINT INSERT_TURNOVER_NOTES;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version,l_api_name, G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean( p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_WORKORDER_PVT.INSERT_TURNOVER_NOTES',
			'p_init_message_list : ' || p_init_msg_list
		);
        fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_WORKORDER_PVT.INSERT_TURNOVER_NOTES',
			'p_commit : ' || p_commit
		);
  END IF;
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Insert notes
  FOR i IN p_trunover_notes_tbl.FIRST..p_trunover_notes_tbl.LAST  LOOP
    -- validate source object code
    IF(p_trunover_notes_tbl(i).source_object_code <> 'AHL_WO_TURNOVER_NOTES')THEN
       FND_MESSAGE.Set_Name('AHL','AHL_PRD_WO_NOTES_INV_SOURCE');
       FND_MSG_PUB.ADD;
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
              fnd_log.level_error,
              'ahl.plsql.AHL_PRD_WORKORDER_PVT.INSERT_TURNOVER_NOTES',
              'Invalid source object code for JTF notes' || p_trunover_notes_tbl(i).source_object_code
            );
       END IF;
    END IF;
    -- validate entered data
    IF(p_trunover_notes_tbl(i).entered_date > SYSDATE)THEN
       FND_MESSAGE.Set_Name('AHL','AHL_PRD_WO_NOTES_INV_ENT_DT');
       FND_MESSAGE.Set_Token('ENTERED_DATE',p_trunover_notes_tbl(i).entered_date);
       FND_MSG_PUB.ADD;
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
              fnd_log.level_error,
              'ahl.plsql.AHL_PRD_WORKORDER_PVT.INSERT_TURNOVER_NOTES',
              'Invalid enterded date' || to_char(p_trunover_notes_tbl(i).entered_date)
            );
       END IF;
    END IF;
    -- validate that notes cant not be null
    IF(p_trunover_notes_tbl(i).notes IS NULL)THEN
      FND_MESSAGE.Set_Name('AHL','AHL_PRD_WO_NOTES_INV_NOTES_NLL');
      FND_MSG_PUB.ADD;
      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
              fnd_log.level_error,
              'ahl.plsql.AHL_PRD_WORKORDER_PVT.INSERT_TURNOVER_NOTES',
              'Invalid enterded date' || to_char(p_trunover_notes_tbl(i).entered_date)
            );
      END IF;
    END IF;

    IF p_trunover_notes_tbl(i).employee_name IS NULL THEN
          FND_MESSAGE.set_name('AHL','AHL_PRD_EMP_NULL_TRNTS');
          FND_MSG_PUB.ADD;
          --l_user_id := FND_GLOBAL.user_id;
    ELSE
       matchFound := FALSE;
       FOR emp_rec IN get_user_id_csr(p_trunover_notes_tbl(i).employee_name,
                           p_trunover_notes_tbl(i).org_id) LOOP
           l_count := l_count + 1;
           l_user_id := emp_rec.user_id;
           IF(emp_rec.person_id = p_trunover_notes_tbl(i).employee_id)THEN
             matchFound := TRUE;
             EXIT;
           END IF;
       END LOOP;
       IF NOT(l_count = 1 OR  matchFound)THEN
         -- Invalid or non unique employee
         FND_MESSAGE.set_name('AHL','AHL_PRD_INV_EMP_TRNTS');
         FND_MESSAGE.SET_TOKEN('EMP_NAME',p_trunover_notes_tbl(i).employee_name);
         FND_MSG_PUB.ADD;
       END IF;
    END IF;

    IF(l_user_id IS NULL)THEN
      FND_MESSAGE.set_name('AHL','AHL_PRD_INV_EMP_NUQ_TRNTS');
      FND_MSG_PUB.ADD;
    END IF;


    -- add notes if no messages
    IF(FND_MSG_PUB.count_msg = 0)THEN
       JTF_NOTES_PUB.Create_note
       (
          p_api_version           => 1.0,
          p_init_msg_list         => FND_API.G_FALSE,
          p_commit                => FND_API.G_FALSE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          x_return_status         => x_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data,
          p_source_object_id      => p_trunover_notes_tbl(i).source_object_id,
          p_source_object_code    => p_trunover_notes_tbl(i).source_object_code,
          p_notes                 => p_trunover_notes_tbl(i).notes,
          p_entered_by            => l_user_id,
          p_entered_date          => p_trunover_notes_tbl(i).entered_date,
          x_jtf_note_id           => p_trunover_notes_tbl(i).jtf_note_id
       );
    END IF;
  END LOOP;
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
  IF(x_msg_count > 0 )THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_WORKORDER_PVT.INSERT_TURNOVER_NOTES.end',
			'At the end of PLSQL procedure'
		);
  END IF;

 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
   Rollback to INSERT_TURNOVER_NOTES;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to INSERT_TURNOVER_NOTES;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    Rollback to INSERT_TURNOVER_NOTES;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SUBSTRB(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
END INSERT_TURNOVER_NOTES;

FUNCTION get_date_and_time(p_date IN DATE,
                           p_date_hh24 IN VARCHAR2,
                           p_date_mi IN VARCHAR2,
                           p_date_ss IN VARCHAR2) RETURN DATE IS

l_hour                  VARCHAR2(30);
l_sec                   VARCHAR2(30);
l_minutes               VARCHAR2(30);
l_date_time             VARCHAR2(30);
l_date                  DATE;

BEGIN

    l_sec := TO_CHAR(p_date, 'ss');
    l_hour := TO_CHAR(p_date, 'hh24');
    l_minutes := TO_CHAR(p_date, 'mi');
    l_date := p_date;

    IF ( p_date_hh24 IS NOT NULL AND
         p_date_hh24 <> FND_API.G_MISS_NUM ) THEN
      l_hour := p_date_hh24;
    END IF;

    IF ( p_date_mi IS NOT NULL AND
         p_date_mi <> FND_API.G_MISS_NUM ) THEN
      l_minutes := p_date_mi;
    END IF;

    IF(p_date_ss IS NOT NULL AND
       p_date_ss <> FND_API.G_MISS_NUM) THEN
       l_sec := p_date_ss;
    END IF;

    IF ( l_hour <> '00' OR l_minutes <> '00' OR l_sec <> '00') THEN
      l_date_time := TO_CHAR(p_date, 'DD-MM-YYYY')||' :'|| l_hour ||':'|| l_minutes || ':'|| l_sec;
      l_date := TO_DATE(l_date_time , 'DD-MM-YYYY :HH24:MI:ss');
    END IF;
    RETURN l_date;
END get_date_and_time;

-- Fix for Bug # 8329755 (FP for Bug # 7697909) -- start
--------------------------------------------------------------------------------------------------
-- Procedure added for Bug # 8329755 (FP for Bug # 7697909)
-- This is a supplementary procedure for procedure Update_Master_Wo_Dates.
--------------------------------------------------------------------------------------------------
PROCEDURE default_missing_wo_attributes(

     p_x_prd_workorder_rec    IN OUT NOCOPY AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_REC

)
IS
CURSOR get_workorder_rec(c_workorder_id NUMBER)
IS
SELECT
 WO.WIP_ENTITY_ID,
 WO.WORKORDER_NAME JOB_NUMBER,
 WDJ.DESCRIPTION JOB_DESCRIPTION,
 WO.OBJECT_VERSION_NUMBER,
 VST.ORGANIZATION_ID ORGANIZATION_ID,
 WDJ.FIRM_PLANNED_FLAG FIRM_PLANNED_FLAG,
 WDJ.CLASS_CODE CLASS_CODE,
 WDJ.OWNING_DEPARTMENT DEPARTMENT_ID,
 WO.STATUS_CODE JOB_STATUS_CODE,
 WDJ.SCHEDULED_START_DATE SCHEDULED_START_DATE,
 WDJ.SCHEDULED_COMPLETION_DATE SCHEDULED_END_DATE,
 WO.ACTUAL_START_DATE ACTUAL_START_DATE,
 WO.ACTUAL_END_DATE ACTUAL_END_DATE,
 CSI.INVENTORY_ITEM_ID INVENTORY_ITEM_ID,
 NVL(VTS.INSTANCE_ID,VST.ITEM_INSTANCE_ID) ITEM_INSTANCE_ID,
 WDJ.COMPLETION_SUBINVENTORY COMPLETION_SUBINVENTORY,
 WDJ.COMPLETION_LOCATOR_ID COMPLETION_LOCATOR_ID,
 WO.MASTER_WORKORDER_FLAG MASTER_WORKORDER_FLAG,
 WO.VISIT_TASK_ID VISIT_TASK_ID,
 VST.PROJECT_ID PROJECT_ID,
 VTS.PROJECT_TASK_ID  PROJECT_TASK_ID,
 WDJ.PRIORITY PRIORITY
FROM
 AHL_WORKORDERS WO,
 AHL_VISITS_B VST,
 AHL_VISIT_TASKS_B VTS,
 WIP_DISCRETE_JOBS WDJ,
 CSI_ITEM_INSTANCES CSI
WHERE
     WDJ.WIP_ENTITY_ID  = WO.WIP_ENTITY_ID
 AND WO.VISIT_TASK_ID   = VTS.VISIT_TASK_ID
 AND VST.VISIT_ID       = WO.VISIT_ID
 AND NVL(VTS.INSTANCE_ID,VST.ITEM_INSTANCE_ID) = CSI.INSTANCE_ID
 AND WO.VISIT_TASK_ID IS NOT NULL
 AND WO.STATUS_CODE  <> '22'
 AND WO.workorder_id = c_workorder_id;

l_prd_workorder_rec   get_workorder_rec%ROWTYPE;

BEGIN

    p_x_prd_workorder_rec.DML_OPERATION := 'U';

    OPEN  get_workorder_rec(p_x_prd_workorder_rec.workorder_id);
    FETCH get_workorder_rec INTO l_prd_workorder_rec;
    IF get_workorder_rec%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WO_NOT_FOUND');
      FND_MSG_PUB.ADD;
      CLOSE get_workorder_rec;
      RETURN;
    END IF;
    CLOSE get_workorder_rec;

    p_x_prd_workorder_rec.WIP_ENTITY_ID:=l_prd_workorder_rec.WIP_ENTITY_ID;
    p_x_prd_workorder_rec.JOB_NUMBER:=l_prd_workorder_rec.JOB_NUMBER;
    p_x_prd_workorder_rec.JOB_DESCRIPTION:=l_prd_workorder_rec.JOB_DESCRIPTION;
    p_x_prd_workorder_rec.OBJECT_VERSION_NUMBER:=l_prd_workorder_rec.OBJECT_VERSION_NUMBER;
    p_x_prd_workorder_rec.ORGANIZATION_ID:=l_prd_workorder_rec.ORGANIZATION_ID;

    p_x_prd_workorder_rec.FIRM_PLANNED_FLAG:=l_prd_workorder_rec.FIRM_PLANNED_FLAG;
    p_x_prd_workorder_rec.CLASS_CODE:=l_prd_workorder_rec.CLASS_CODE;
    p_x_prd_workorder_rec.DEPARTMENT_ID:=l_prd_workorder_rec.DEPARTMENT_ID;

    p_x_prd_workorder_rec.STATUS_CODE:=l_prd_workorder_rec.job_STATUS_CODE;

    p_x_prd_workorder_rec.SCHEDULED_START_DATE:=l_prd_workorder_rec.SCHEDULED_START_DATE;
    p_x_prd_workorder_rec.SCHEDULED_END_DATE:=l_prd_workorder_rec.SCHEDULED_END_DATE;
    p_x_prd_workorder_rec.ACTUAL_START_DATE:=l_prd_workorder_rec.ACTUAL_START_DATE;
    p_x_prd_workorder_rec.ACTUAL_END_DATE:=l_prd_workorder_rec.ACTUAL_END_DATE;
    p_x_prd_workorder_rec.INVENTORY_ITEM_ID:=l_prd_workorder_rec.INVENTORY_ITEM_ID;
    p_x_prd_workorder_rec.ITEM_INSTANCE_ID:=l_prd_workorder_rec.ITEM_INSTANCE_ID;
    p_x_prd_workorder_rec.COMPLETION_SUBINVENTORY:=l_prd_workorder_rec.COMPLETION_SUBINVENTORY;
    p_x_prd_workorder_rec.COMPLETION_LOCATOR_ID:=l_prd_workorder_rec.COMPLETION_LOCATOR_ID;
    p_x_prd_workorder_rec.MASTER_WORKORDER_FLAG:=l_prd_workorder_rec.MASTER_WORKORDER_FLAG;
    p_x_prd_workorder_rec.VISIT_TASK_ID:=l_prd_workorder_rec.VISIT_TASK_ID;
    p_x_prd_workorder_rec.PROJECT_ID:=l_prd_workorder_rec.PROJECT_ID;
    p_x_prd_workorder_rec.PROJECT_TASK_ID:=l_prd_workorder_rec.PROJECT_TASK_ID;
    p_x_prd_workorder_rec.JOB_PRIORITY:=l_prd_workorder_rec.PRIORITY;

END default_missing_wo_attributes;

--------------------------------------------------------------------------------------------------
-- Procedure added for Bug # 8329755 (FP for Bug # 7697909)
-- This procedure updates master work order scheduled dates by deriving
-- it from underlying child work orders. This procedure does this logic
-- by only looking at immediate children of any MWO instead of drilling
-- down the entire hierarchy of children as done by update_job API.
--------------------------------------------------------------------------------------------------
PROCEDURE Update_Master_Wo_Dates(

          p_workorder_id IN NUMBER
)
IS

  CURSOR get_curr_wo_details(c_workorder_id NUMBER)
  IS
  SELECT
         AWO.wip_entity_id
  FROM
         ahl_workorders AWO
  WHERE
         awo.workorder_id = c_workorder_id;

  CURSOR  get_parent_workorder( c_child_wip_entity_id NUMBER )
  IS
  SELECT  WO.workorder_id,
          WO.object_version_number,
          WO.wip_entity_id,
          WO.visit_task_id,
          WO.status_code
  FROM    AHL_WORKORDERS WO,
          WIP_SCHED_RELATIONSHIPS WOR
  WHERE   WO.wip_entity_id = WOR.parent_object_id
  AND     WO.master_workorder_flag = 'Y'
  AND     WO.visit_task_id IS NOT NULL
  AND     WO.status_code <> '22'
  AND     WOR.parent_object_type_id = 1
  AND     WOR.relationship_type = 1
  AND     WOR.child_object_type_id = 1
  AND     WOR.child_object_id = c_child_wip_entity_id;

  l_parent_wo_rec get_parent_workorder%ROWTYPE;

  CURSOR  get_child_workorders( c_wip_entity_id NUMBER )
  IS
  SELECT  WDJ.wip_entity_id,
          WDJ.scheduled_start_date scheduled_start_date,
          WDJ.scheduled_completion_date scheduled_end_date,
          WO.actual_start_date actual_start_date,
          WO.actual_end_date actual_end_date,
          WO.status_code status_code
  FROM    WIP_DISCRETE_JOBS WDJ,
          AHL_WORKORDERS WO
  WHERE   WDJ.wip_entity_id = WO.wip_entity_id
  AND     WO.status_code <> '22'
  AND     WO.wip_entity_id in
          (
            SELECT     child_object_id
            FROM       WIP_SCHED_RELATIONSHIPS
            WHERE      parent_object_type_id = 1
                  AND  child_object_type_id = 1
                  AND  parent_object_id = c_wip_entity_id
                  AND  relationship_type = 1
          );

  l_x_prd_workorder_rec   AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_REC;
  l_resource_tbl          AHL_PP_RESRC_REQUIRE_PVT.resrc_require_tbl_type;
  l_material_tbl          AHL_PP_MATERIALS_PVT.req_material_tbl_type;
  l_prd_workoper_tbl      AHL_PRD_OPERATIONS_PVT.prd_operation_tbl;

  l_parent_wo_st_date     DATE;
  l_parent_wo_end_date    DATE;

  l_curr_wip_entity_id    NUMBER;

  l_api_name        CONSTANT VARCHAR2(30) := 'Contract_Master_Wo_Dates';
  l_msg_data              VARCHAR2(2000);
  l_return_status         VARCHAR2(1);
  l_job_return_status     VARCHAR2(1);
  l_msg_count             NUMBER;

BEGIN


             OPEN get_curr_wo_details(p_workorder_id);
             FETCH get_curr_wo_details INTO l_curr_wip_entity_id;
             CLOSE get_curr_wo_details;

	     IF ( G_LEVEL_STATEMENT >= G_CURRENT_LOG_LEVEL)
	     THEN
		fnd_log.string(
		   G_LEVEL_STATEMENT,
		   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
		   'Inside procedure Contract_Master_Wo_Dates first l_curr_wip_entity_id -> '||l_curr_wip_entity_id
		);
	     END IF;

             LOOP

		     OPEN get_parent_workorder(l_curr_wip_entity_id);
		     FETCH get_parent_workorder INTO l_parent_wo_rec;
		     CLOSE get_parent_workorder;

		     IF l_parent_wo_rec.wip_entity_id IS NOT NULL
		     THEN

			  FOR child_wo_rec IN get_child_workorders(l_parent_wo_rec.wip_entity_id)
			  LOOP

			       l_parent_wo_st_date := LEAST(NVL(l_parent_wo_st_date, child_wo_rec.scheduled_start_date), child_wo_rec.scheduled_start_date);
			       l_parent_wo_end_date := GREATEST(NVL(l_parent_wo_end_date, child_wo_rec.scheduled_end_date), child_wo_rec.scheduled_end_date);

			  END LOOP;

			  IF ( G_LEVEL_STATEMENT >= G_CURRENT_LOG_LEVEL)
			  THEN
				fnd_log.string(
				   G_LEVEL_STATEMENT,
				   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				   'l_curr_wip_entity_id -> '||l_curr_wip_entity_id
				);
				fnd_log.string(
				   G_LEVEL_STATEMENT,
				   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				   'l_parent_wo_st_date -> '||TO_CHAR(l_parent_wo_st_date, 'DD-MON-YYYY HH24:MI:SS')
				);
				fnd_log.string(
				   G_LEVEL_STATEMENT,
				   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				   'l_parent_wo_end_date -> '||TO_CHAR(l_parent_wo_end_date, 'DD-MON-YYYY HH24:MI:SS')
				);
			  END IF;

			  l_x_prd_workorder_rec.workorder_id := l_parent_wo_rec.workorder_id;

			  default_missing_wo_attributes( p_x_prd_workorder_rec => l_x_prd_workorder_rec);

			  l_x_prd_workorder_rec.scheduled_start_date := l_parent_wo_st_date;
			  l_x_prd_workorder_rec.scheduled_start_hr := TO_NUMBER( TO_CHAR( l_parent_wo_st_date, 'HH24' ) );
			  l_x_prd_workorder_rec.scheduled_start_mi := TO_NUMBER( TO_CHAR( l_parent_wo_st_date, 'MI' ) );


			  l_x_prd_workorder_rec.scheduled_end_date := l_parent_wo_end_date;
			  l_x_prd_workorder_rec.scheduled_end_hr := TO_NUMBER( TO_CHAR( l_parent_wo_end_date, 'HH24' ) );
			  l_x_prd_workorder_rec.scheduled_end_mi := TO_NUMBER( TO_CHAR( l_parent_wo_end_date, 'MI' ) );


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
			  ) VALUES
			  (
			    AHL_WORKORDER_TXNS_S.NEXTVAL,
			    NVL(l_x_prd_workorder_rec.OBJECT_VERSION_NUMBER,1),
			    NVL(l_x_prd_workorder_rec.LAST_UPDATE_DATE,SYSDATE),
			    NVL(l_x_prd_workorder_rec.LAST_UPDATED_BY,FND_GLOBAL.USER_ID),
			    NVL(l_x_prd_workorder_rec.CREATION_DATE,SYSDATE),
			    NVL(l_x_prd_workorder_rec.CREATED_BY,FND_GLOBAL.USER_ID),
			    NVL(l_x_prd_workorder_rec.LAST_UPDATE_LOGIN,FND_GLOBAL.USER_ID),
			    l_x_prd_workorder_rec.WORKORDER_ID,
			    0,
			    l_x_prd_workorder_rec.STATUS_CODE,
			    l_x_prd_workorder_rec.SCHEDULED_START_DATE,
			    l_x_prd_workorder_rec.SCHEDULED_END_DATE,
			    l_x_prd_workorder_rec.ACTUAL_START_DATE,
			    l_x_prd_workorder_rec.ACTUAL_END_DATE,
			    0,
			    l_x_prd_workorder_rec.COMPLETION_SUBINVENTORY,
			    l_x_prd_workorder_rec.COMPLETION_LOCATOR_ID
			  );

			  AHL_EAM_JOB_PVT.update_job_operations
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
			      p_workorder_rec          => l_x_prd_workorder_rec      ,
			      p_operation_tbl          => l_prd_workoper_tbl         ,
			      p_material_req_tbl       => l_material_tbl             ,
			      p_resource_req_tbl       => l_resource_tbl
			    );

			   IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
			      RAISE FND_API.G_EXC_ERROR;
			   END IF;
		     ELSE

		          EXIT;

		     END IF;

		     l_curr_wip_entity_id   := l_parent_wo_rec.wip_entity_id;
		     l_parent_wo_rec        := NULL;

             END LOOP;

END Update_Master_Wo_Dates;
-- Fix for Bug # 8329755 (FP for Bug # 7697909) -- end

--apattark start for bug #9075539 to validate visit cancellation

PROCEDURE cancel_visit_validate
(
 p_visit_id            IN NUMBER,
 p_visit_number        IN NUMBER,
 x_cancel_flag         OUT NOCOPY VARCHAR2
)
AS
--allow cancelation if wo status is 1, 3 or 7
CURSOR wo_status_csr( c_visit_id NUMBER ) IS
select 'x'
from dual
where exists (select 'x' from ahl_workorders
               where visit_id = c_visit_id
                 and status_code NOT IN ('1','3','7')
             );

--allow cancelation if no operation is complete
CURSOR op_complete_csr( c_visit_id NUMBER ) IS
select 'x'
from dual
where exists (select 'x'
              from ahl_workorders awo, ahl_workorder_operations awop
              where awo.workorder_id = awop.workorder_id
                and awo.visit_id = c_visit_id
                and awop.status_code = '1'
             );

--allow cancelation if no parts change txn
CURSOR part_chg_txn_csr( c_visit_id NUMBER ) IS
select 'x'
from dual
where exists (select 'x'
              from ahl_workorders awo, ahl_workorder_operations awop, ahl_part_changes apc
              where awo.workorder_id = awop.workorder_id
                and awop.workorder_operation_id = apc.workorder_operation_id
                and awo.visit_id = c_visit_id
             );

/* Not required as wo_material_csr and part_chg_txn_csr will cover this
 * validation and wo_material_csr applies across the Visit.
CURSOR tracked_material_csr( c_visit_id NUMBER ) IS
select 'x'
from dual
where exists (select 'x'
                from ahl_workorders awo, csi_item_instances cii
               where awo.wip_entity_id = cii.wip_job_id
                 and cii.location_type_code = 'WIP'
                 and cii.ACTIVE_START_DATE <= SYSDATE
                 and ((cii.ACTIVE_END_DATE IS NULL) OR (cii.ACTIVE_END_DATE >= SYSDATE))
                 and awo.visit_id = c_visit_id
             );
*/

--allow cancelation if no resource txns done
CURSOR resource_txn_csr( c_visit_id NUMBER ) IS
select 'x'
from dual
where exists (select 'x'
              from ahl_workorders awo, wip_transactions wipt
              where awo.wip_entity_id = wipt.wip_entity_id
                and awo.visit_id = c_visit_id
              UNION ALL
              select 'x'
                from ahl_workorders awos, wip_COST_TXN_INTERFACE wict
               where awos.wip_entity_id = wict.wip_entity_id
                 and awos.visit_id = c_visit_id
                 and process_status IN (1,3)
             );

--allow cancelation if no item/serial change txns present.
CURSOR item_chg_txn_csr(c_visit_id NUMBER ) IS
SELECT 'x'
FROM   dual
WHERE  EXISTS
       ( SELECT 'X'
       FROM    csi_transactions cst  ,
               csi_txn_types cstrntyp,
               ahl_workorders awo
       WHERE   cstrntyp.source_transaction_type = 'ITEM_SERIAL_CHANGE'
       AND     cst.transaction_type_id          = cstrntyp.transaction_type_id
       AND     cst.source_line_ref              = 'AHL_PRD_WO'
       AND     cst.source_line_ref_id           = awo.workorder_id
       AND     awo.visit_id                     = c_visit_id
       );

--allow cancelation if material have not been returned.
-- check issue txns with return txns.
CURSOR wo_material_csr(c_visit_id NUMBER ) IS
  SELECT INVENTORY_ITEM_ID, REVISION, LOT_NUMBER, SERIAL_NUMBER, sum(quantity) quantity
    FROM ahl_workorder_mtl_txns amt, ahl_workorder_operations awo, ahl_workorders aw
   WHERE aw.visit_id = c_visit_id
     and aw.workorder_id = awo.workorder_id
     and awo.workorder_operation_id = amt.workorder_operation_id
     and TRANSACTION_TYPE_ID = 35
   group by INVENTORY_ITEM_ID, REVISION, LOT_NUMBER, SERIAL_NUMBER
  MINUS
   SELECT INVENTORY_ITEM_ID, REVISION, LOT_NUMBER, SERIAL_NUMBER, sum(quantity) quantity
   FROM ahl_workorder_mtl_txns amt, ahl_workorder_operations awo, ahl_workorders aw
   WHERE aw.visit_id = c_visit_id
     and aw.workorder_id = awo.workorder_id
     and awo.workorder_operation_id = amt.workorder_operation_id
     and TRANSACTION_TYPE_ID = 43
   group by INVENTORY_ITEM_ID, REVISION, LOT_NUMBER, SERIAL_NUMBER;

mtl_rec          wo_material_csr%ROWTYPE;
l_dummy          VARCHAR2(1);
l_api_name       CONSTANT VARCHAR2(30) := 'cancel_visit_validate';
l_inv_segments   VARCHAR2(500);

BEGIN
    -- initialize
    x_cancel_flag := 'Y';

    -- check workorder statuses
    OPEN wo_status_csr(p_visit_id);
    FETCH wo_status_csr INTO l_dummy;
    IF wo_status_csr%FOUND THEN
      Fnd_Message.SET_NAME('AHL','AHL_PRD_CNT_CANCEL_VST_WOSTA');
      --Visit cancellation is allowed only if the Visit's workorders are in released, unreleased or canceled statuses
      Fnd_Message.Set_Token('VISIT',p_visit_number);
      Fnd_Msg_Pub.ADD;
      x_cancel_flag := 'N';
      CLOSE wo_status_csr;
      RETURN;
    END IF ;
    CLOSE wo_status_csr;

    OPEN op_complete_csr(p_visit_id);
    FETCH op_complete_csr INTO l_dummy;
    IF op_complete_csr%FOUND THEN
      Fnd_Message.SET_NAME('AHL','AHL_PRD_CNT_CANCEL_VST_OPCOM');
      Fnd_Message.Set_Token('VISIT',p_visit_number);
      --At least one operation is complete. Cannot cancel Visit.
      Fnd_Msg_Pub.ADD;
      x_cancel_flag := 'N';
      CLOSE op_complete_csr;
      RETURN;
    END IF ;
    CLOSE op_complete_csr;

    OPEN part_chg_txn_csr(p_visit_id);
    FETCH part_chg_txn_csr INTO l_dummy;
    IF part_chg_txn_csr%FOUND THEN
      Fnd_Message.SET_NAME('AHL','AHL_PRD_CNT_CANCEL_VST_PCHG');
      Fnd_Message.Set_Token('VISIT',p_visit_number);
      --At least one Parts Change transaction found. Cannot cancel Visit
      Fnd_Msg_Pub.ADD;
      x_cancel_flag := 'N';
      CLOSE part_chg_txn_csr;
      RETURN;
    END IF ;
    CLOSE part_chg_txn_csr;

    OPEN wo_material_csr(p_visit_id);
    FETCH wo_material_csr INTO mtl_rec;
    IF wo_material_csr%FOUND THEN
      Fnd_Message.SET_NAME('AHL','AHL_PRD_CNT_CANCEL_VST_WOMTXN');
      --All issued material is not returned. Cannot cancel Visit
      Fnd_Message.Set_Token('VISIT',p_visit_number);
      -- get inv segments.
      BEGIN
        SELECT concatenated_segments INTO l_inv_segments
        FROM mtl_system_items_kfv
        WHERE inventory_item_id = mtl_rec.inventory_item_id
          and rownum < 2;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
      END;

      Fnd_Message.Set_Token('INV_ITEM', l_inv_segments);
      Fnd_Message.Set_Token('INV_LOT', mtl_rec.lot_number);
      Fnd_Message.Set_Token('INV_SERIAL', mtl_rec.serial_number);
      Fnd_Message.Set_Token('INV_REV', mtl_rec.revision);
      Fnd_Message.Set_Token('QTY', mtl_rec.quantity);
      Fnd_Msg_Pub.ADD;
      x_cancel_flag := 'N';
      CLOSE wo_material_csr;
      RETURN;
    END IF ;
    CLOSE wo_material_csr;

    OPEN resource_txn_csr(p_visit_id);
    FETCH resource_txn_csr INTO l_dummy;
    IF resource_txn_csr%FOUND THEN
      Fnd_Message.SET_NAME('AHL','AHL_PRD_CNT_CANCEL_VST_WORTXN');
      --At least one Workorder found with resource transactions. Cannot cancel Visit
      Fnd_Message.Set_Token('VISIT',p_visit_number);
      Fnd_Msg_Pub.ADD;
      x_cancel_flag := 'N';
      CLOSE resource_txn_csr;
      RETURN;
    END IF ;
    CLOSE resource_txn_csr;

    OPEN item_chg_txn_csr(p_visit_id);
    FETCH item_chg_txn_csr INTO l_dummy;
    IF item_chg_txn_csr%FOUND THEN
      Fnd_Message.SET_NAME('AHL','AHL_PRD_CNT_CANCEL_VST_ITEMTXN');
      --At least one Serial Number/ Item Number Change transaction found. Cannot cancel Visit.
      Fnd_Message.Set_Token('VISIT',p_visit_number);
      Fnd_Msg_Pub.ADD;
      x_cancel_flag := 'N';
      CLOSE item_chg_txn_csr;
      RETURN;
    END IF ;
    CLOSE item_chg_txn_csr;

 END cancel_visit_validate;
--apattark end for bug #9075539 to validate visit cancellation

END AHL_PRD_WORKORDER_PVT;

/
