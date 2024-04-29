--------------------------------------------------------
--  DDL for Package Body AHL_EAM_JOB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_EAM_JOB_PVT" AS
/* $Header: AHLVEAMB.pls 120.3.12010000.4 2009/05/06 10:59:10 bachandr ship $ */

G_PKG_NAME VARCHAR2(30) := 'AHL_EAM_JOB_PVT';
G_DEBUG    VARCHAR2(1)  := AHL_DEBUG_PUB.is_log_enabled;

--Modified By Srini July 01, 2004
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

-- Procedure for getting appropriate workorder type which corresponds to work_order_type in
-- in WIP and set the workorder name based on profiles.

PROCEDURE get_workorder_details(
  p_visit_task_id         IN  NUMBER,
  p_master_workorder_flag IN VARCHAR2,
  x_workorder_type        OUT NOCOPY VARCHAR2,
  x_workorder_prefix      OUT NOCOPY VARCHAR2)

IS

 -- cursor to get the Unit_eff ID from task ID
 CURSOR get_ue_id_csr (p_task_id IN NUMBER) IS
   SELECT unit_effectivity_id
   FROM ahl_visit_tasks_b vst
   WHERE visit_task_id = p_task_id;


 -- Cursor to get UE details only for a top UE ID.
 CURSOR get_ue_detail_csr(p_ue_id IN NUMBER)
 IS
 SELECT
    cs_incident_id, nvl(manually_planned_flag,'N')
 FROM
    AHL_UNIT_EFFECTIVITIES_B UE
 WHERE
    UE.unit_effectivity_id = p_ue_id
    AND NOT EXISTS (SELECT 'x'
                    FROM AHL_UE_RELATIONSHIPS UER
                    WHERE UER.related_ue_id = UE.unit_effectivity_id
                   );

 -- get originator UE details for a child UE.
 CURSOR get_uer_detail_csr(p_ue_id IN NUMBER)
 IS
 SELECT
    cs_incident_id, nvl(manually_planned_flag,'N')
 FROM
    AHL_UNIT_EFFECTIVITIES_B UE
 WHERE
    UE.unit_effectivity_id IN (SELECT originator_ue_id
                               FROM AHL_UE_RELATIONSHIPS UER
                               WHERE UER.related_ue_id = p_ue_id
                               );

 -- Define local variables here
 l_cs_incident_id         NUMBER;
 l_manually_planned_flag  VARCHAR2(1);
 l_ue_id                  NUMBER;

 --profiles for workorder types.
 l_DEFAULT_WORKORDER_TYPE    VARCHAR2(30)    := fnd_profile.value('AHL_WORKORDER_TYPE_DEFAULT');
 l_NONROUTINE_WORKORDER_TYPE VARCHAR2(30) := fnd_profile.value('AHL_WORKORDER_TYPE_NONROUTINE');
 l_PLANNED_WORKORDER_TYPE    VARCHAR2(30)    := fnd_profile.value('AHL_WORKORDER_TYPE_PLANNED');
 l_UNPLANNED_WORKORDER_TYPE  VARCHAR2(30)  := fnd_profile.value('AHL_WORKORDER_TYPE_UNPLANNED');

 -- profiles for workorder name.
 l_MR_prefix  VARCHAR2(30) := fnd_profile.value('AHL_MR_WORKORDER_PREFIX');
 l_NR_prefix  VARCHAR2(30) := fnd_profile.value('AHL_NR_WORKORDER_PREFIX');

BEGIN
   -- initialize out parameters.
   x_workorder_type := NULL;
   x_workorder_prefix := NULL;

   -- Log Input Values
   IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug('Default Workorder Type profile: ' || l_DEFAULT_WORKORDER_TYPE);
      AHL_DEBUG_PUB.debug('Planned Workorder Type profile: ' || l_PLANNED_WORKORDER_TYPE);
      AHL_DEBUG_PUB.debug('Unplanned Workorder Type profile: ' || l_UNPLANNED_WORKORDER_TYPE);
      AHL_DEBUG_PUB.debug('NonRoutine Workorder Type profile: ' || l_NONROUTINE_WORKORDER_TYPE);

      AHL_DEBUG_PUB.debug('NonRoutine Workorder Prefix profile: ' || l_MR_prefix);
      AHL_DEBUG_PUB.debug('MR workorder prefix profile: ' || l_NR_prefix);


      AHL_DEBUG_PUB.debug('Input Visit Task: ' || p_visit_task_id);
      AHL_DEBUG_PUB.debug('Input Master_workorder_flag: ' || p_master_workorder_flag);

   END IF;

   -- Check whether default profile has been set up or not
   -- throw error "Please set up the profile value for AHL : Default WorkorderType".
   IF l_DEFAULT_WORKORDER_TYPE IS NULL
   THEN
      FND_MESSAGE.set_name('AHL','AHL_PRD_NO_WORKORDER_TYPE');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (p_visit_task_id IS NULL AND p_master_workorder_flag = 'Y' )
   --************************Visit Master Workorder *******************--
   THEN
     x_workorder_type:=  l_DEFAULT_WORKORDER_TYPE;
   ELSE
      -- Get unit effectivity ID for the visit task.
      OPEN get_ue_id_csr(p_visit_task_id);
      FETCH get_ue_id_csr INTO l_ue_id;
      IF (get_ue_id_csr%NOTFOUND) THEN
         CLOSE get_ue_id_csr;
         FND_MESSAGE.set_name('AHL','AHL_PRD_VISIT_TASK_NULL');
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE get_ue_id_csr;

      IF (l_ue_id IS NULL) THEN
          -- unassociated task.
          IF (l_UNPLANNED_WORKORDER_TYPE IS NOT NULL) THEN
             x_workorder_type:= l_UNPLANNED_WORKORDER_TYPE;
          END IF;
      ELSE
          -- planned/unplanned MR /non-routine case.
          -- get unit effectivity details.
          OPEN get_ue_detail_csr (l_ue_id);
          FETCH get_ue_detail_csr INTO l_cs_incident_id, l_manually_planned_flag;
          IF (get_ue_detail_csr%NOTFOUND) THEN
            -- Check for child UE.
            OPEN get_uer_detail_csr(l_ue_id);
            FETCH get_uer_detail_csr INTO l_cs_incident_id, l_manually_planned_flag;
            CLOSE get_uer_detail_csr;
          END IF; -- ahl_ue_detail_csr.
          CLOSE get_ue_detail_csr;

          -- Check non-Routine.
          IF (l_cs_incident_id IS NOT NULL) THEN
            x_workorder_type := l_NONROUTINE_WORKORDER_TYPE;
            -- set workorder prefix.
            IF (p_master_workorder_flag = 'Y') THEN
              x_workorder_prefix := l_NR_prefix;
            END IF;
          ELSIF (l_manually_planned_flag = 'Y') THEN
            x_workorder_type:= l_UNPLANNED_WORKORDER_TYPE;
            -- set workorder prefix.
            IF (p_master_workorder_flag = 'Y') THEN
              x_workorder_prefix := l_MR_prefix;
            END IF;
          ELSIF (l_manually_planned_flag = 'N') THEN
            x_workorder_type:= l_PLANNED_WORKORDER_TYPE;
            IF (p_master_workorder_flag = 'Y') THEN
              x_workorder_prefix := l_MR_prefix;
            END IF;
          END IF;
      END IF;  -- l_ue_id is null.

   END IF; -- p_visit_task_id IS NULL AND p_master_workorder_flag = 'Y'

   -- Check if x_workorder_type is null;
   IF (x_workorder_type IS NULL) THEN
      x_workorder_type := l_DEFAULT_WORKORDER_TYPE;
   END IF;

   IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug('Workorder Type : ' || x_workorder_type);
      AHL_DEBUG_PUB.debug('Workorder Prefix : ' || x_workorder_prefix);
   END IF;

END get_workorder_details;

PROCEDURE map_ahl_eam_wo_rec
(
  p_workorder_rec  IN          AHL_PRD_WORKORDER_PVT.prd_workorder_rec,
  x_eam_wo_rec     OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_rec_type
)
AS

CURSOR Get_Job_Dates_Cur (c_wip_entity_id IN NUMBER)
 IS
SELECT SCHEDULED_START_DATE,
       SCHEDULED_COMPLETION_DATE, DATE_RELEASED
  FROM WIP_DISCRETE_JOBS
WHERE WIP_ENTITY_ID = c_wip_entity_id;
--
Get_Job_Dates_Rec  Get_Job_Dates_Cur%ROWTYPE;
l_workorder_type   VARCHAR2(30);
l_workorder_prefix VARCHAR2(30);

BEGIN

  -- Log Input Values
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( 'dml_operation: ' || p_workorder_rec.dml_operation );
    AHL_DEBUG_PUB.debug( 'batch_id: ' || TO_CHAR( p_workorder_rec.batch_id ) );
    AHL_DEBUG_PUB.debug( 'header_id: ' || TO_CHAR( p_workorder_rec.header_id ) );
    AHL_DEBUG_PUB.debug( 'workorder_id: ' || TO_CHAR( p_workorder_rec.workorder_id ) );
    AHL_DEBUG_PUB.debug( 'organization_id: ' || TO_CHAR( p_workorder_rec.organization_id ) );
    AHL_DEBUG_PUB.debug( 'wip_entity_id: ' || TO_CHAR( p_workorder_rec.wip_entity_id ) );
    AHL_DEBUG_PUB.debug( 'job_number: ' || p_workorder_rec.job_number );
    AHL_DEBUG_PUB.debug( 'job_description: ' || p_workorder_rec.job_description );
    AHL_DEBUG_PUB.debug( 'inventory_item_id: ' || TO_CHAR( p_workorder_rec.inventory_item_id ) );
    AHL_DEBUG_PUB.debug( 'item_instance_id: ' || TO_CHAR( p_workorder_rec.item_instance_id ) );
    AHL_DEBUG_PUB.debug( 'class_code: ' || p_workorder_rec.class_code );
    AHL_DEBUG_PUB.debug( 'status_code: ' || p_workorder_rec.status_code );
    AHL_DEBUG_PUB.debug( 'department_id: ' || TO_CHAR( p_workorder_rec.department_id ) );
    AHL_DEBUG_PUB.debug( 'job_priority: ' || TO_CHAR( p_workorder_rec.job_priority ) );
    AHL_DEBUG_PUB.debug( 'firm_planned_flag: ' || TO_CHAR( p_workorder_rec.firm_planned_flag ) );
    AHL_DEBUG_PUB.debug( 'project_id: ' || TO_CHAR( p_workorder_rec.project_id ) );
    AHL_DEBUG_PUB.debug( 'project_task_id: ' || TO_CHAR( p_workorder_rec.project_task_id ) );
    AHL_DEBUG_PUB.debug( 'wip_supply_type: ' || TO_CHAR( p_workorder_rec.wip_supply_type ) );
    AHL_DEBUG_PUB.debug( 'scheduled_start_date: ' || TO_CHAR( p_workorder_rec.scheduled_start_date, 'DD-MON-YYYY hh24:mi') );
    AHL_DEBUG_PUB.debug( 'scheduled_end_date: ' || TO_CHAR( p_workorder_rec.scheduled_end_date, 'DD-MON-YYYY hh24:mi') );
  END IF;

  get_workorder_details (p_visit_task_id => p_workorder_rec.visit_task_id,
                         p_master_workorder_flag =>  p_workorder_rec.master_workorder_flag,
                         x_workorder_type        =>  l_workorder_type,
                         x_workorder_prefix      =>  l_workorder_prefix);
  -- Populate EAM Record attributes from input record
  x_eam_wo_rec.batch_id := p_workorder_rec.batch_id;
  x_eam_wo_rec.header_id := p_workorder_rec.header_id;
  x_eam_wo_rec.wip_entity_id := p_workorder_rec.wip_entity_id;
  x_eam_wo_rec.organization_id := p_workorder_rec.organization_id;
  x_eam_wo_rec.wip_entity_name := substrb(l_workorder_prefix || p_workorder_rec.job_number,1,80);
  x_eam_wo_rec.description := p_workorder_rec.job_description;
  x_eam_wo_rec.rebuild_item_id := p_workorder_rec.inventory_item_id;
  x_eam_wo_rec.maintenance_object_id := p_workorder_rec.item_instance_id;
  x_eam_wo_rec.class_code := p_workorder_rec.class_code;

  -- CMRO contains more status codes than WIP. Map each status to WIP Status
  IF ( p_workorder_rec.status_code = '19' OR
       p_workorder_rec.status_code = '21' ) THEN
    x_eam_wo_rec.status_type := 6;
  ELSIF ( p_workorder_rec.status_code = '20' ) THEN
    x_eam_wo_rec.status_type := 3;
  ELSIF ( p_workorder_rec.status_code = '22' ) THEN
    x_eam_wo_rec.status_type := 7;
  ELSE
    x_eam_wo_rec.status_type := TO_NUMBER( p_workorder_rec.status_code );
  END IF;

  x_eam_wo_rec.owning_department := p_workorder_rec.department_id;
  x_eam_wo_rec.priority := p_workorder_rec.job_priority;
  x_eam_wo_rec.firm_planned_flag := p_workorder_rec.firm_planned_flag;
  x_eam_wo_rec.project_id := p_workorder_rec.project_id;
  x_eam_wo_rec.task_id := p_workorder_rec.project_task_id;
  x_eam_wo_rec.wip_supply_type := p_workorder_rec.wip_supply_type;
  x_eam_wo_rec.scheduled_start_date := p_workorder_rec.scheduled_start_date;
  x_eam_wo_rec.scheduled_completion_date := p_workorder_rec.scheduled_end_date;

  -- Intialize EAM Record attributes with Constants
  x_eam_wo_rec.maintenance_object_type := 3;
  x_eam_wo_rec.maintenance_object_source := 2;
  x_eam_wo_rec.job_quantity := 1;
  --x_eam_wo_rec.work_order_type := 10;
  x_eam_wo_rec.work_order_type := l_workorder_type;
  x_eam_wo_rec.requested_start_date := NULL;
  x_eam_wo_rec.due_date := NULL;
  x_eam_wo_rec.notification_required := 'N';
  x_eam_wo_rec.tagout_required := 'N';
  x_eam_wo_rec.manual_rebuild_flag := 'Y';

  --Changes made by srini not to create project and task for Draft or Cancelled workorders
  IF p_workorder_rec.status_code IN ('17','22') THEN
  x_eam_wo_rec.project_id := NULL;
  x_eam_wo_rec.task_id := NULL;
  END IF;

  -- Do not pass
  /**
  x_eam_wo_rec.asset_number := NULL;
  x_eam_wo_rec.asset_group_id := NULL;
  x_eam_wo_rec.rebuild_serial_number := NULL;
  x_eam_wo_rec.asset_activity_id := NULL;
  x_eam_wo_rec.activity_type := NULL;
  x_eam_wo_rec.activity_cause := NULL;
  x_eam_wo_rec.activity_source := NULL;
  x_eam_wo_rec.shutdown_type := NULL;
  x_eam_wo_rec.bom_revision_date := NULL;
  x_eam_wo_rec.routing_revision_date := NULL;
  x_eam_wo_rec.alternate_routing_designator := NULL;
  x_eam_wo_rec.alternate_bom_designator := NULL;
  x_eam_wo_rec.routing_revision := NULL;
  x_eam_wo_rec.bom_revision := NULL;
  x_eam_wo_rec.pm_schedule_id := NULL;
  x_eam_wo_rec.material_account := NULL;
  x_eam_wo_rec.material_overhead_account := NULL;
  x_eam_wo_rec.resource_account := NULL;
  x_eam_wo_rec.outside_processing_account := NULL;
  x_eam_wo_rec.material_variance_account := NULL;
  x_eam_wo_rec.resource_variance_account := NULL;
  x_eam_wo_rec.outside_proc_variance_account := NULL;
  x_eam_wo_rec.std_cost_adjustment_account := NULL;
  x_eam_wo_rec.overhead_account := NULL;
  x_eam_wo_rec.overhead_variance_account := NULL;
  x_eam_wo_rec.common_bom_sequence_id := NULL;
  x_eam_wo_rec.common_routing_sequence_id := NULL;
  x_eam_wo_rec.po_creation_time := NULL;
  x_eam_wo_rec.plan_maintenance := ??;
  x_eam_wo_rec.project_costed := ??;
  x_eam_wo_rec.end_item_unit_number := ??;
  x_eam_wo_rec.schedule_group_id := ??;
  x_eam_wo_rec.parent_wip_entity_id := ??;
  x_eam_wo_rec.gen_object_id := ??;
  x_eam_wo_rec.source_line_id := ??;
  x_eam_wo_rec.source_code := ??;
  x_eam_wo_rec.material_issue_by_mo := ??;
  x_eam_wo_rec.user_id := ??;
  x_eam_wo_rec.responsibility_id := ??;
  x_eam_wo_rec.date_released := ??;
  **/

  -- Set the DML Operation for the Job Header Record
  IF ( p_workorder_rec.dml_operation = 'C' ) THEN
    x_eam_wo_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;
  ELSIF ( p_workorder_rec.dml_operation = 'U' ) THEN
    x_eam_wo_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
    --Srini
	OPEN Get_Job_Dates_Cur(x_eam_wo_rec.wip_entity_id);
	FETCH Get_Job_Dates_Cur INTO Get_Job_Dates_Rec;
	CLOSE Get_Job_Dates_Cur;
	-- we need to pass the requested start date for forward scheduling

        -- If the scheduled start date is changed, then pass requested start date
        -- If the scheduled end date is changed, then pass due date
        -- If both are changed then pass requested_start_date because if
        -- both due date and requested start date are passed then EAM throws an error
        IF (Get_Job_Dates_Rec.Scheduled_start_Date <> x_eam_wo_rec.scheduled_start_date) THEN
           x_eam_wo_rec.requested_start_date  := x_eam_wo_rec.scheduled_start_date;
        ELSIF (Get_Job_Dates_Rec.Scheduled_completion_Date <> x_eam_wo_rec.scheduled_completion_date) THEN
           x_eam_wo_rec.due_date := x_eam_wo_rec.scheduled_completion_date;
           --Due date should be passed for backward scheduling
        END IF;

	/*IF (Get_Job_Dates_Rec.Scheduled_completion_Date <> x_eam_wo_rec.scheduled_completion_date
	  AND  Get_Job_Dates_Rec.Scheduled_completion_Date < x_eam_wo_rec.scheduled_completion_date )
	  THEN
	   x_eam_wo_rec.requested_start_date  := x_eam_wo_rec.scheduled_completion_date;
	   --Due date should be passsed for backward scheduling
	 ELSIF  (Get_Job_Dates_Rec.Scheduled_completion_Date <> x_eam_wo_rec.scheduled_completion_date
	  AND  Get_Job_Dates_Rec.Scheduled_completion_Date > x_eam_wo_rec.scheduled_completion_date )
	  THEN
	   x_eam_wo_rec.due_date  := x_eam_wo_rec.scheduled_completion_date;
	END IF;
        */
  END IF;
  -- rroy
		-- workorder backdating fix
		-- set the date_released parameter
		-- of the eam workorder record to
		-- min(scheduled_start_date, sysdate)
		-- if the new status code is 3(Released) or 6 (On Hold)
		-- This is being done for statuses 3 and 6 because
		-- the EAM code updates the p_release_date parameter
		-- for the above statuses in the call to WIP_CHANGE_STATUS.Release
		--
                /*IF p_workorder_rec.status_code IN ('3', '6') THEN
		  x_eam_wo_rec.date_released := least(Get_Job_Dates_Rec.date_released, p_workorder_rec.scheduled_start_date, sysdate);
		END IF;
		*/


  IF ( G_DEBUG = 'Y' ) THEN

    AHL_DEBUG_PUB.debug( 'Requested Start Date: ' || TO_CHAR( x_eam_wo_rec.requested_start_date, 'DD-MON-YYYY hh24:mi') );
    AHL_DEBUG_PUB.debug( 'Due Date: ' || TO_CHAR( x_eam_wo_rec.due_date, 'DD-MON-YYYY hh24:mi') );
  END IF;

  x_eam_wo_rec.return_status := NULL;

END map_ahl_eam_wo_rec;
--

PROCEDURE map_ahl_eam_wo_rel_rec
(
  p_workorder_rel_rec    IN         AHL_PRD_WORKORDER_PVT.prd_workorder_rel_rec,
  x_eam_wo_relations_rec OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type
)
AS

BEGIN

  -- Log Input Values
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( 'dml_operation: ' || p_workorder_rel_rec.dml_operation );
    AHL_DEBUG_PUB.debug( 'batch_id: ' || TO_CHAR( p_workorder_rel_rec.batch_id ) );
    AHL_DEBUG_PUB.debug( 'wo_relationship_id: ' || TO_CHAR( p_workorder_rel_rec.wo_relationship_id ) );
    AHL_DEBUG_PUB.debug( 'parent_header_id: ' || TO_CHAR( p_workorder_rel_rec.parent_header_id ) );
    AHL_DEBUG_PUB.debug( 'parent_wip_entity_id: ' || TO_CHAR( p_workorder_rel_rec.parent_wip_entity_id ) );
    AHL_DEBUG_PUB.debug( 'child_header_id: ' || TO_CHAR( p_workorder_rel_rec.child_header_id ) );
    AHL_DEBUG_PUB.debug( 'child_wip_entity_id: ' || TO_CHAR( p_workorder_rel_rec.child_wip_entity_id ) );
    AHL_DEBUG_PUB.debug( 'relationship_type: ' || TO_CHAR( p_workorder_rel_rec.relationship_type ) );
  END IF;

  -- Populate EAM Record attributes from input record
  x_eam_wo_relations_rec.batch_id := p_workorder_rel_rec.batch_id;
  x_eam_wo_relations_rec.wo_relationship_id := p_workorder_rel_rec.wo_relationship_id;
  x_eam_wo_relations_rec.parent_header_id := p_workorder_rel_rec.parent_header_id;
  x_eam_wo_relations_rec.parent_object_type_id := 1;
  x_eam_wo_relations_rec.parent_object_id := p_workorder_rel_rec.parent_wip_entity_id;
  x_eam_wo_relations_rec.child_header_id := p_workorder_rel_rec.child_header_id;
  x_eam_wo_relations_rec.child_object_type_id := 1;
  x_eam_wo_relations_rec.child_object_id := p_workorder_rel_rec.child_wip_entity_id;
  x_eam_wo_relations_rec.parent_relationship_type := p_workorder_rel_rec.relationship_type;
  x_eam_wo_relations_rec.relationship_status := 0;

  -- Set the DML Operation for the Job Header Record
  IF ( p_workorder_rel_rec.dml_operation = 'C' ) THEN
    x_eam_wo_relations_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;
  ELSIF ( p_workorder_rel_rec.dml_operation = 'D' ) THEN
    x_eam_wo_relations_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_DELETE;
  END IF;

  x_eam_wo_relations_rec.return_status := NULL;

END map_ahl_eam_wo_rel_rec;

PROCEDURE map_ahl_eam_op_rec
(
  p_operation_rec  IN         AHL_PRD_OPERATIONS_PVT.prd_workoperation_rec,
  x_eam_op_rec     OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_rec_type
)
AS

BEGIN

  -- Log Input Values
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( 'dml_operation: ' || p_operation_rec.dml_operation );
    AHL_DEBUG_PUB.debug( 'workorder_id: ' || TO_CHAR( p_operation_rec.workorder_id ) );
    AHL_DEBUG_PUB.debug( 'wip_entity_id: ' || TO_CHAR( p_operation_rec.wip_entity_id ) );
    AHL_DEBUG_PUB.debug( 'organization_id: ' || TO_CHAR( p_operation_rec.organization_id ) );
    AHL_DEBUG_PUB.debug( 'operation_sequence_num: ' || TO_CHAR( p_operation_rec.operation_sequence_num) );
    AHL_DEBUG_PUB.debug( 'department_id: ' || TO_CHAR( p_operation_rec.department_id) );
    AHL_DEBUG_PUB.debug( 'operation_description: ' || p_operation_rec.operation_description );
    AHL_DEBUG_PUB.debug( 'minimum_transfer_quantity: ' || TO_CHAR( p_operation_rec.minimum_transfer_quantity) );
    AHL_DEBUG_PUB.debug( 'count_point_type: ' || TO_CHAR( p_operation_rec.count_point_type) );
    AHL_DEBUG_PUB.debug( 'scheduled_start_date: ' || TO_CHAR( p_operation_rec.scheduled_start_date, 'DD-MON-YYYY hh24:mi') );
    AHL_DEBUG_PUB.debug( 'scheduled_end_date: ' || TO_CHAR( p_operation_rec.scheduled_end_date, 'DD-MON-YYYY hh24:mi') );
  END IF;

  -- Populate EAM Record attributes from input table
  x_eam_op_rec.wip_entity_id := p_operation_rec.wip_entity_id;
  x_eam_op_rec.organization_id := p_operation_rec.organization_id;
  x_eam_op_rec.operation_seq_num := p_operation_rec.operation_sequence_num;
  x_eam_op_rec.department_id := p_operation_rec.department_id;
  x_eam_op_rec.long_description := p_operation_rec.operation_description;
  -- Bug # 8323205 (FP For Bug # 8257536) -- start
  x_eam_op_rec.description := SUBSTRB(RTRIM(p_operation_rec.operation_description),1,240);
  -- Bug # 8323205 (FP For Bug # 8257536) -- end

  IF ( p_operation_rec.dml_operation = 'C' ) THEN
    x_eam_op_rec.minimum_transfer_quantity := 1;
  ELSIF ( p_operation_rec.dml_operation = 'U' ) THEN
    x_eam_op_rec.minimum_transfer_quantity := p_operation_rec.minimum_transfer_quantity;
  END IF;

  IF ( p_operation_rec.dml_operation = 'C' ) THEN
    x_eam_op_rec.count_point_type := 2;
  ELSIF ( p_operation_rec.dml_operation = 'U' ) THEN
    x_eam_op_rec.count_point_type := p_operation_rec.count_point_type;
  END IF;

  -- Missing in AHL
  IF ( p_operation_rec.dml_operation = 'C' ) THEN
    x_eam_op_rec.backflush_flag := 2;
  END IF;

  x_eam_op_rec.start_date := p_operation_rec.scheduled_start_date;
  x_eam_op_rec.completion_date := p_operation_rec.scheduled_end_date;

  -- Do not Pass
  /**
  x_eam_op_rec.standard_operation_id := ??;
  x_eam_op_rec.operation_sequence_id := ??;
  x_eam_op_rec.shutdown_type := ??;
  **/

  -- Set the DML Operation for the Record
  IF ( p_operation_rec.dml_operation = 'C' ) THEN
    x_eam_op_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;
  ELSIF ( p_operation_rec.dml_operation = 'U' ) THEN
    x_eam_op_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
  END IF;

  x_eam_op_rec.return_status := NULL;

END map_ahl_eam_op_rec;

PROCEDURE map_ahl_eam_mat_rec
(
  p_material_req_rec IN         AHL_PP_MATERIALS_PVT.req_material_rec_type,
  x_eam_mat_req_rec  OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
)
AS

BEGIN

  -- Log Input Values
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( 'operation_flag : ' || p_material_req_rec.operation_flag );
    AHL_DEBUG_PUB.debug( 'workorder_id: ' || TO_CHAR( p_material_req_rec.workorder_id ) );
    AHL_DEBUG_PUB.debug( 'wip_entity_id: ' || TO_CHAR( p_material_req_rec.wip_entity_id ) );
    AHL_DEBUG_PUB.debug( 'organization_id: ' || TO_CHAR( p_material_req_rec.organization_id ) );
    AHL_DEBUG_PUB.debug( 'operation_sequence: ' || TO_CHAR( p_material_req_rec.operation_sequence) );
    AHL_DEBUG_PUB.debug( 'inventory_item_id: ' || TO_CHAR( p_material_req_rec.inventory_item_id) );
    AHL_DEBUG_PUB.debug( 'requested_quantity: ' || TO_CHAR( p_material_req_rec.requested_quantity) );
    AHL_DEBUG_PUB.debug( 'department_id: ' || TO_CHAR( p_material_req_rec.department_id) );
    AHL_DEBUG_PUB.debug( 'requested_date: ' || TO_CHAR( p_material_req_rec.requested_date, 'DD-MON-YYYY hh24:mi') );
  END IF;

  -- Populate EAM Record attributes from input table
  x_eam_mat_req_rec.wip_entity_id := p_material_req_rec.wip_entity_id;
  x_eam_mat_req_rec.organization_id := p_material_req_rec.organization_id;
  x_eam_mat_req_rec.operation_seq_num := p_material_req_rec.operation_sequence;
  x_eam_mat_req_rec.inventory_item_id := p_material_req_rec.inventory_item_id;
  x_eam_mat_req_rec.quantity_per_assembly := p_material_req_rec.requested_quantity;
  x_eam_mat_req_rec.department_id := p_material_req_rec.department_id;
  x_eam_mat_req_rec.date_required := p_material_req_rec.requested_date;
  x_eam_mat_req_rec.required_quantity := p_material_req_rec.requested_quantity;
  --x_eam_mat_req_rec.quantity_issued := p_material_req_rec.requested_quantity;
  x_eam_mat_req_rec.mrp_net_flag := p_material_req_rec.mrp_net_flag;

  -- Intialize EAM Record attributes with Constants
  x_eam_mat_req_rec.wip_supply_type := 1;
  -- fix for bug# 7217613. Pass quantity issued to EAM only when creating the requirement.
  IF ( p_material_req_rec.operation_flag = 'C' ) THEN
    x_eam_mat_req_rec.quantity_issued := 0;
  END IF;

  -- Do not Pass
  /**
  x_eam_mat_req_rec.supply_subinventory := ??;
  x_eam_mat_req_rec.supply_locator_id := ??;
  x_eam_mat_req_rec.mps_required_quantity := ??;
  x_eam_mat_req_rec.mps_date_required := ??;
  x_eam_mat_req_rec.component_sequence_id := ??;
  x_eam_mat_req_rec.comments := ??;
  **/

  -- Set the DML Operation for the Record
  IF ( p_material_req_rec.operation_flag = 'C' ) THEN
    x_eam_mat_req_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;
  ELSIF ( p_material_req_rec.operation_flag = 'U' ) THEN
    x_eam_mat_req_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
  ELSIF ( p_material_req_rec.operation_flag = 'D' ) THEN
    x_eam_mat_req_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_DELETE;
  END IF;

  x_eam_mat_req_rec.return_status := NULL;

END map_ahl_eam_mat_rec;

PROCEDURE map_ahl_eam_res_rec
(
  p_resource_req_rec IN       AHL_PP_RESRC_REQUIRE_PVT.resrc_require_rec_type,
  x_eam_res_rec    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_rec_type
)
AS

BEGIN
  -- Log Input Values
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( 'operation_flag : ' || p_resource_req_rec.operation_flag );
    AHL_DEBUG_PUB.debug( 'workorder_id: ' || TO_CHAR( p_resource_req_rec.workorder_id ) );
    AHL_DEBUG_PUB.debug( 'wip_entity_id: ' || TO_CHAR( p_resource_req_rec.wip_entity_id ) );
    AHL_DEBUG_PUB.debug( 'organization_id: ' || TO_CHAR( p_resource_req_rec.organization_id ) );
    AHL_DEBUG_PUB.debug( 'operation_sequence: ' || TO_CHAR( p_resource_req_rec.operation_seq_number) );
    AHL_DEBUG_PUB.debug( 'resource_seq_number: ' || TO_CHAR( p_resource_req_rec.resource_seq_number) );
    AHL_DEBUG_PUB.debug( 'resource_id: ' || TO_CHAR( p_resource_req_rec.resource_id) );
    AHL_DEBUG_PUB.debug( 'uom_code: ' || p_resource_req_rec.uom_code );
    AHL_DEBUG_PUB.debug( 'cost_basis_code: ' || TO_CHAR( p_resource_req_rec.cost_basis_code ) );
    AHL_DEBUG_PUB.debug( 'charge_type_code: ' || TO_CHAR( p_resource_req_rec.charge_type_code) );
    AHL_DEBUG_PUB.debug( 'std_rate_flag_code: ' || TO_CHAR( p_resource_req_rec.std_rate_flag_code) );
    AHL_DEBUG_PUB.debug( 'scheduled_type_code: ' || TO_CHAR( p_resource_req_rec.scheduled_type_code) );
    AHL_DEBUG_PUB.debug( 'applied_num: ' || TO_CHAR( p_resource_req_rec.applied_num) );
    AHL_DEBUG_PUB.debug( 'open_num: ' || TO_CHAR( p_resource_req_rec.open_num) );
    AHL_DEBUG_PUB.debug( 'req_start_date: ' || TO_CHAR( p_resource_req_rec.req_start_date, 'DD-MON-YYYY hh24:mi') );
    AHL_DEBUG_PUB.debug( 'req_end_date: ' || TO_CHAR( p_resource_req_rec.req_end_date, 'DD-MON-YYYY hh24:mi') );
    AHL_DEBUG_PUB.debug( 'quantity: ' || TO_CHAR( p_resource_req_rec.quantity) );
    AHL_DEBUG_PUB.debug( 'duration: ' || TO_CHAR( p_resource_req_rec.duration) );
  END IF;

  -- Populate EAM Record attributes from input table
  x_eam_res_rec.wip_entity_id := p_resource_req_rec.wip_entity_id;
  x_eam_res_rec.organization_id := p_resource_req_rec.organization_id;
  x_eam_res_rec.operation_seq_num := p_resource_req_rec.operation_seq_number;
  x_eam_res_rec.resource_seq_num := p_resource_req_rec.resource_seq_number;
  x_eam_res_rec.resource_id := p_resource_req_rec.resource_id;
  x_eam_res_rec.uom_code := p_resource_req_rec.uom_code;
  x_eam_res_rec.basis_type := p_resource_req_rec.cost_basis_code;
  x_eam_res_rec.autocharge_type := p_resource_req_rec.charge_type_code;
  x_eam_res_rec.standard_rate_flag := p_resource_req_rec.std_rate_flag_code;
  x_eam_res_rec.scheduled_flag := p_resource_req_rec.scheduled_type_code;
  x_eam_res_rec.start_date := p_resource_req_rec.req_start_date;
  x_eam_res_rec.completion_date := p_resource_req_rec.req_end_date;
  x_eam_res_rec.usage_rate_or_amount := p_resource_req_rec.duration;
  x_eam_res_rec.assigned_units := p_resource_req_rec.quantity;
-- JKJAIN US space FP for ER # 6998882 -- start
  x_eam_res_rec.schedule_seq_num := p_resource_req_rec.schedule_seq_num;
-- JKJAIN US space FP for ER # 6998882 -- end
  --  Do not Pass
  /**
  x_eam_res_rec.activity_id := p_resource_req_rec.activity_code;
  x_eam_res_rec.applied_resource_units := p_resource_req_rec.applied_num;
  x_eam_res_rec.applied_resource_value := p_resource_req_rec.open_num;
  x_eam_res_rec.assigned_units := ??
  x_eam_res_rec.substitute_group_num := ??
  x_eam_res_rec.replacement_group_num := ??
  x_eam_res_rec.schedule_seq_num := ??
  **/

  -- Set the DML Operation for the Record
  IF ( p_resource_req_rec.operation_flag = 'C' ) THEN
    x_eam_res_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;
  ELSIF ( p_resource_req_rec.operation_flag = 'U' ) THEN
    x_eam_res_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
  ELSIF ( p_resource_req_rec.operation_flag = 'D' ) THEN
    x_eam_res_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_DELETE;
  END IF;

  x_eam_res_rec.return_status := NULL;

END map_ahl_eam_res_rec;

PROCEDURE map_ahl_eam_res_inst_rec
(
  p_resource_assign_rec IN       AHL_PP_RESRC_ASSIGN_PVT.resrc_assign_rec_type,
  x_eam_res_inst_rec  OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
)
AS

BEGIN
  -- Log Input Values
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( 'operation_flag : ' || p_resource_assign_rec.operation_flag );
    AHL_DEBUG_PUB.debug( 'workorder_id: ' || TO_CHAR( p_resource_assign_rec.workorder_id ) );
    AHL_DEBUG_PUB.debug( 'wip_entity_id: ' || TO_CHAR( p_resource_assign_rec.wip_entity_id ) );
    AHL_DEBUG_PUB.debug( 'organization_id: ' || TO_CHAR( p_resource_assign_rec.organization_id ) );
    AHL_DEBUG_PUB.debug( 'operation_seq_number: ' || TO_CHAR( p_resource_assign_rec.operation_seq_number) );
    AHL_DEBUG_PUB.debug( 'resource_seq_number: ' || TO_CHAR( p_resource_assign_rec.resource_seq_number) );
    AHL_DEBUG_PUB.debug( 'instance_id: ' || TO_CHAR( p_resource_assign_rec.instance_id) );
    AHL_DEBUG_PUB.debug( 'serial_number: ' || p_resource_assign_rec.serial_number );
    AHL_DEBUG_PUB.debug( 'assign_start_date: ' || TO_CHAR( p_resource_assign_rec.assign_start_date, 'DD-MON-YYYY hh24:mi') );
    AHL_DEBUG_PUB.debug( 'assign_end_date: ' || TO_CHAR( p_resource_assign_rec.assign_end_date, 'DD-MON-YYYY hh24:mi') );
  END IF;

  -- Populate EAM Record attributes from input table
  x_eam_res_inst_rec.wip_entity_id := p_resource_assign_rec.wip_entity_id;
  x_eam_res_inst_rec.organization_id := p_resource_assign_rec.organization_id;
  x_eam_res_inst_rec.operation_seq_num := p_resource_assign_rec.operation_seq_number;
  x_eam_res_inst_rec.resource_seq_num := p_resource_assign_rec.resource_seq_number;
  x_eam_res_inst_rec.instance_id := p_resource_assign_rec.instance_id;
  x_eam_res_inst_rec.serial_number := p_resource_assign_rec.serial_number;
  x_eam_res_inst_rec.start_date := p_resource_assign_rec.assign_start_date;
  x_eam_res_inst_rec.completion_date := p_resource_assign_rec.assign_end_date;

  -- Do not Pass
  /**
  x_eam_res_inst_rec.batch_id := ??;
  **/

  -- Set the DML Operation for the Record
  IF ( p_resource_assign_rec.operation_flag = 'C' ) THEN
    x_eam_res_inst_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;
  ELSIF ( p_resource_assign_rec.operation_flag = 'U' ) THEN
    x_eam_res_inst_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
  ELSIF ( p_resource_assign_rec.operation_flag = 'D' ) THEN
    x_eam_res_inst_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_DELETE;
  END IF;

  x_eam_res_inst_rec.return_status := NULL;

END map_ahl_eam_res_inst_rec;

PROCEDURE create_eam_workorder
(
  p_api_version        IN   NUMBER     := 1.0,
  p_init_msg_list      IN   VARCHAR2   := FND_API.G_TRUE,
  p_commit             IN   VARCHAR2   := FND_API.G_FALSE,
  p_validation_level   IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default            IN   VARCHAR2   := FND_API.G_FALSE,
  p_module_type        IN   VARCHAR2   := NULL,
  x_return_status      OUT  NOCOPY  VARCHAR2,
  x_msg_count          OUT  NOCOPY  NUMBER,
  x_msg_data           OUT  NOCOPY  VARCHAR2,
  p_x_workorder_rec    IN OUT NOCOPY AHL_PRD_WORKORDER_PVT.prd_workorder_rec,
  p_operation_tbl      IN   AHL_PRD_OPERATIONS_PVT.prd_operation_tbl,
  p_material_req_tbl   IN   AHL_PP_MATERIALS_PVT.req_material_tbl_type,
  p_resource_req_tbl   IN   AHL_PP_RESRC_REQUIRE_PVT.resrc_require_tbl_type
)
IS

l_api_name                 VARCHAR2(30) := 'create_eam_workorder';

-- Declare EAM API parameters
l_bo_identifier            VARCHAR2(10) := 'AHL';
l_init_msg_list            BOOLEAN := TRUE;
l_debug                    VARCHAR2(1)  := 'N';
l_output_dir               VARCHAR2(80);
l_debug_filename           VARCHAR2(80);
l_debug_file_mode          VARCHAR2(1);
l_return_status            VARCHAR2(1);
l_msg_count                NUMBER;
l_eam_wo_rec               EAM_PROCESS_WO_PUB.eam_wo_rec_type;
l_eam_op_tbl               EAM_PROCESS_WO_PUB.eam_op_tbl_type;
l_eam_op_network_tbl       EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
l_eam_res_tbl              EAM_PROCESS_WO_PUB.eam_res_tbl_type;
l_eam_res_inst_tbl         EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
l_eam_sub_res_tbl          EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
l_eam_res_usage_tbl        EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
l_eam_mat_req_tbl          EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
l_eam_direct_items_tbl     EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
l_out_eam_wo_rec           EAM_PROCESS_WO_PUB.eam_wo_rec_type;
l_out_eam_op_tbl           EAM_PROCESS_WO_PUB.eam_op_tbl_type;
l_out_eam_op_network_tbl   EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
l_out_eam_res_tbl          EAM_PROCESS_WO_PUB.eam_res_tbl_type;
l_out_eam_res_inst_tbl     EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
l_out_eam_sub_res_tbl      EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
l_out_eam_res_usage_tbl    EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
l_out_eam_mat_req_tbl      EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
l_out_eam_direct_items_tbl EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

BEGIN

  -- Enable Debug
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT create_eam_workorder_PVT;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( 'Inputs for API: ' || G_PKG_NAME||'.'||l_api_name );
    AHL_DEBUG_PUB.debug( 'Job Header Record: ' );
  END IF;

  -- Map all input AHL Job Header record attributes to the
  -- corresponding EAM Job Header record attributes.
  map_ahl_eam_wo_rec
  (
    p_workorder_rec    => p_x_workorder_rec,
    x_eam_wo_rec       => l_eam_wo_rec
  );

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( 'Job Header Record Mapping Complete' );
  END IF;

  -- Map all input AHL Operation record attributes to the
  -- corresponding EAM Operation record attributes.
  FOR i IN p_operation_tbl.FIRST..p_operation_tbl.LAST LOOP

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'Inputs for API: ' || G_PKG_NAME||'.'||l_api_name );
      AHL_DEBUG_PUB.debug( 'Operation Record Number : ' || i );
    END IF;

    map_ahl_eam_op_rec
    (
      p_operation_rec    => p_operation_tbl(i),
      x_eam_op_rec       => l_eam_op_tbl(i)
    );

  END LOOP;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( 'Operations Record Mapping Complete' );
  END IF;

  -- Map all input AHL Material Requirement record attributes to the
  -- corresponding EAM Material Requirement record attributes.
  IF ( p_material_req_tbl.COUNT > 0 ) THEN
    FOR i IN p_material_req_tbl.FIRST..p_material_req_tbl.LAST LOOP
      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( 'Inputs for API: ' || G_PKG_NAME||'.'||l_api_name );
        AHL_DEBUG_PUB.debug( 'Material Requirement Record Number : ' || i );
      END IF;

      map_ahl_eam_mat_rec
      (
        p_material_req_rec    => p_material_req_tbl(i),
        x_eam_mat_req_rec     => l_eam_mat_req_tbl(i)
      );

    END LOOP;

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'Material Requirements Record Mapping Complete' );
    END IF;

  END IF;

  -- Map all input AHL Resource Requirement record attributes to the
  -- corresponding EAM Resource Requirement record attributes.
  IF ( p_resource_req_tbl.COUNT > 0 ) THEN
    FOR i IN p_resource_req_tbl.FIRST..p_resource_req_tbl.LAST LOOP

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( 'Inputs for API: ' || G_PKG_NAME||'.'||l_api_name );
        AHL_DEBUG_PUB.debug( 'Resource Requirement Record Number : ' || i );
      END IF;

      map_ahl_eam_res_rec
      (
        p_resource_req_rec    => p_resource_req_tbl(i),
        x_eam_res_rec         => l_eam_res_tbl(i)
      );

    END LOOP;

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'Resource Requirement Record Mapping Complete' );
    END IF;

  END IF;

  -- Set Debug Parameters for the EAM API
  IF ( G_DEBUG = 'Y' ) THEN
    set_eam_debug_params
    (
      x_debug           => l_debug,
      x_output_dir      => l_output_dir,
      x_debug_file_name => l_debug_filename,
      x_debug_file_mode => l_debug_file_mode
    );
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( 'Invoking EAM process_wo API' );
  END IF;

  -- Invoke EAM BO API for Updating the Job
  EAM_PROCESS_WO_PUB.process_wo
  (
    p_bo_identifier             => l_bo_identifier,
    p_api_version_number        => 1.0,
    p_init_msg_list             => l_init_msg_list,
    p_commit                    => FND_API.G_FALSE,
    p_eam_wo_rec                => l_eam_wo_rec,
    p_eam_op_tbl                => l_eam_op_tbl,
    p_eam_op_network_tbl        => l_eam_op_network_tbl,
    p_eam_res_tbl               => l_eam_res_tbl,
    p_eam_res_inst_tbl          => l_eam_res_inst_tbl,
    p_eam_sub_res_tbl           => l_eam_sub_res_tbl,
    p_eam_res_usage_tbl         => l_eam_res_usage_tbl,
    p_eam_mat_req_tbl           => l_eam_mat_req_tbl,
    p_eam_direct_items_tbl      => l_eam_direct_items_tbl,
    x_eam_wo_rec                => l_out_eam_wo_rec,
    x_eam_op_tbl                => l_out_eam_op_tbl,
    x_eam_op_network_tbl        => l_out_eam_op_network_tbl,
    x_eam_res_tbl               => l_out_eam_res_tbl,
    x_eam_res_inst_tbl          => l_out_eam_res_inst_tbl,
    x_eam_sub_res_tbl           => l_out_eam_sub_res_tbl,
    x_eam_res_usage_tbl         => l_out_eam_res_usage_tbl,
    x_eam_mat_req_tbl           => l_out_eam_mat_req_tbl,
    x_eam_direct_items_tbl      => l_out_eam_direct_items_tbl,
    x_return_status             => l_return_status,
    x_msg_count                 => l_msg_count,
    p_debug                     => l_debug,
    p_output_dir                => l_output_dir,
    p_debug_filename            => l_debug_filename,
    p_debug_file_mode           => l_debug_file_mode
  );

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'Error Count from EAM API : ' || l_msg_count );
      AHL_DEBUG_PUB.debug( 'Error Count from Error Stack : ' || FND_MSG_PUB.count_msg );
    END IF;

    RAISE FND_API.G_EXC_ERROR;
  ELSE
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'EAM process_wo API Successful' );
    END IF;

    p_x_workorder_rec.wip_entity_id := l_out_eam_wo_rec.wip_entity_id;

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'New wip_entity_id:' || TO_CHAR( p_x_workorder_rec.wip_entity_id ) );
    END IF;

    -- Perform the Commit (if requested)
    IF FND_API.to_boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
  END IF;

  -- Disable debug (if enabled)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_eam_workorder_PVT;
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
    ROLLBACK TO create_eam_workorder_PVT;
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
    ROLLBACK TO create_eam_workorder_PVT;
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
END create_eam_workorder;

PROCEDURE update_job_operations
(
  p_api_version            IN   NUMBER     := 1.0,
  p_init_msg_list          IN   VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN   VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default                IN   VARCHAR2   := FND_API.G_FALSE,
  p_module_type            IN   VARCHAR2   := NULL,
  x_return_status          OUT  NOCOPY  VARCHAR2,
  x_msg_count              OUT  NOCOPY  NUMBER,
  x_msg_data               OUT  NOCOPY  VARCHAR2,
  p_workorder_rec          IN   AHL_PRD_WORKORDER_PVT.prd_workorder_rec,
  p_operation_tbl          IN   AHL_PRD_OPERATIONS_PVT.prd_operation_tbl,
  p_material_req_tbl       IN   AHL_PP_MATERIALS_PVT.req_material_tbl_type,
  p_resource_req_tbl       IN   AHL_PP_RESRC_REQUIRE_PVT.resrc_require_tbl_type
)
IS

l_api_name                 VARCHAR2(30) := 'update_job_operations';

-- Declare EAM API parameters
l_bo_identifier            VARCHAR2(10) := 'AHL';
l_init_msg_list            BOOLEAN := TRUE;
l_debug                    VARCHAR2(1)  := 'N';
l_output_dir               VARCHAR2(80);
l_debug_filename           VARCHAR2(80);
l_debug_file_mode          VARCHAR2(1);
l_return_status            VARCHAR2(1);
l_msg_count                NUMBER;
l_eam_wo_rec               EAM_PROCESS_WO_PUB.eam_wo_rec_type;
l_eam_op_tbl               EAM_PROCESS_WO_PUB.eam_op_tbl_type;
l_eam_op_network_tbl       EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
l_eam_res_tbl              EAM_PROCESS_WO_PUB.eam_res_tbl_type;
l_eam_res_inst_tbl         EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
l_eam_sub_res_tbl          EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
l_eam_res_usage_tbl        EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
l_eam_mat_req_tbl          EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
l_eam_direct_items_tbl     EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
l_out_eam_wo_rec           EAM_PROCESS_WO_PUB.eam_wo_rec_type;
l_out_eam_op_tbl           EAM_PROCESS_WO_PUB.eam_op_tbl_type;
l_out_eam_op_network_tbl   EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
l_out_eam_res_tbl          EAM_PROCESS_WO_PUB.eam_res_tbl_type;
l_out_eam_res_inst_tbl     EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
l_out_eam_sub_res_tbl      EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
l_out_eam_res_usage_tbl    EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
l_out_eam_mat_req_tbl      EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
l_out_eam_direct_items_tbl EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

BEGIN

  -- Enable Debug
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT update_job_operations_PVT;

  -- Map all input AHL Job Header record attributes to the
  -- corresponding EAM Job Header record attributes.
  IF ( p_workorder_rec.workorder_id IS NOT NULL ) THEN

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'Inputs for API: ' || G_PKG_NAME||'.'||l_api_name );
      AHL_DEBUG_PUB.debug( 'Job Header Record: ' );
    END IF;

    map_ahl_eam_wo_rec
    (
      p_workorder_rec    => p_workorder_rec,
      x_eam_wo_rec       => l_eam_wo_rec
    );

  END IF;

  -- Map all input AHL Operation record attributes to the
  -- corresponding EAM Operation record attributes.
  IF ( p_operation_tbl.COUNT > 0 ) THEN
    FOR i IN p_operation_tbl.FIRST..p_operation_tbl.LAST LOOP

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( 'Inputs for API: ' || G_PKG_NAME||'.'||l_api_name );
        AHL_DEBUG_PUB.debug( 'Operation Record Number : ' || i );
      END IF;

      map_ahl_eam_op_rec
      (
        p_operation_rec    => p_operation_tbl(i),
        x_eam_op_rec       => l_eam_op_tbl(i)
      );

    END LOOP;
  END IF;

  -- Map all input AHL Material Requirement record attributes to the
  -- corresponding EAM Material Requirement record attributes.
  IF ( p_material_req_tbl.COUNT > 0 ) THEN
    FOR i IN p_material_req_tbl.FIRST..p_material_req_tbl.LAST LOOP

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( 'Inputs for API: ' || G_PKG_NAME||'.'||l_api_name );
        AHL_DEBUG_PUB.debug( 'Material Requirement Record Number : ' || i );
      END IF;

      map_ahl_eam_mat_rec
      (
        p_material_req_rec    => p_material_req_tbl(i),
        x_eam_mat_req_rec     => l_eam_mat_req_tbl(i)
      );

    END LOOP;
  END IF;

  -- Map all input AHL Resource Requirement record attributes to the
  -- corresponding EAM Resource Requirement record attributes.
  IF ( p_resource_req_tbl.COUNT > 0 ) THEN
    FOR i IN p_resource_req_tbl.FIRST..p_resource_req_tbl.LAST LOOP

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( 'Inputs for API: ' || G_PKG_NAME||'.'||l_api_name );
        AHL_DEBUG_PUB.debug( 'Resource Requirement Record Number : ' || i );
      END IF;

      map_ahl_eam_res_rec
      (
        p_resource_req_rec    => p_resource_req_tbl(i),
        x_eam_res_rec         => l_eam_res_tbl(i)
      );

    END LOOP;
  END IF;

  -- Set Debug Parameters for the EAM API
  IF ( G_DEBUG = 'Y' ) THEN
    set_eam_debug_params
    (
      x_debug           => l_debug,
      x_output_dir      => l_output_dir,
      x_debug_file_name => l_debug_filename,
      x_debug_file_mode => l_debug_file_mode
    );
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( 'Invoking EAM process_wo API' );
  END IF;

  -- Invoke EAM BO API for Updating the Job
  EAM_PROCESS_WO_PUB.process_wo
  (
    p_bo_identifier             => l_bo_identifier,
    p_api_version_number        => 1.0,
    p_init_msg_list             => l_init_msg_list,
    p_commit                    => FND_API.G_FALSE,
    p_eam_wo_rec                => l_eam_wo_rec,
    p_eam_op_tbl                => l_eam_op_tbl,
    p_eam_op_network_tbl        => l_eam_op_network_tbl,
    p_eam_res_tbl               => l_eam_res_tbl,
    p_eam_res_inst_tbl          => l_eam_res_inst_tbl,
    p_eam_sub_res_tbl           => l_eam_sub_res_tbl,
    p_eam_res_usage_tbl         => l_eam_res_usage_tbl,
    p_eam_mat_req_tbl           => l_eam_mat_req_tbl,
    p_eam_direct_items_tbl      => l_eam_direct_items_tbl,
    x_eam_wo_rec                => l_out_eam_wo_rec,
    x_eam_op_tbl                => l_out_eam_op_tbl,
    x_eam_op_network_tbl        => l_out_eam_op_network_tbl,
    x_eam_res_tbl               => l_out_eam_res_tbl,
    x_eam_res_inst_tbl          => l_out_eam_res_inst_tbl,
    x_eam_sub_res_tbl           => l_out_eam_sub_res_tbl,
    x_eam_res_usage_tbl         => l_out_eam_res_usage_tbl,
    x_eam_mat_req_tbl           => l_out_eam_mat_req_tbl,
    x_eam_direct_items_tbl      => l_out_eam_direct_items_tbl,
    x_return_status             => l_return_status,
    x_msg_count                 => l_msg_count,
    p_debug                     => l_debug,
    p_output_dir                => l_output_dir,
    p_debug_filename            => l_debug_filename,
    p_debug_file_mode           => l_debug_file_mode
  );

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'Error Count from EAM API : ' || l_msg_count );
      AHL_DEBUG_PUB.debug( 'Error Count from Error Stack : ' || FND_MSG_PUB.count_msg );
    END IF;

    RAISE FND_API.G_EXC_ERROR;

  ELSE
    -- Perform the Commit (if requested)
    IF FND_API.to_boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
  END IF;

  -- Disable debug (if enabled)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO update_job_operations_PVT;
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
    ROLLBACK TO update_job_operations_PVT;
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
    ROLLBACK TO update_job_operations_PVT;
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

END update_job_operations;

PROCEDURE process_material_req
(
  p_api_version            IN   NUMBER     := 1.0,
  p_init_msg_list          IN   VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN   VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default                IN   VARCHAR2   := FND_API.G_FALSE,
  p_module_type            IN   VARCHAR2   := NULL,
  x_return_status          OUT  NOCOPY  VARCHAR2,
  x_msg_count              OUT  NOCOPY  NUMBER,
  x_msg_data               OUT  NOCOPY  VARCHAR2,
  p_material_req_tbl       IN   AHL_PP_MATERIALS_PVT.req_material_tbl_type
)
IS

l_api_name                 VARCHAR2(30) := 'process_material_req';

-- Declare EAM API parameters
l_bo_identifier            VARCHAR2(10) := 'AHL';
l_init_msg_list            BOOLEAN := TRUE;
l_debug                    VARCHAR2(1)  := 'N';
l_output_dir               VARCHAR2(80);
l_debug_filename           VARCHAR2(80);
l_debug_file_mode          VARCHAR2(1);
l_return_status            VARCHAR2(1);
l_msg_count                NUMBER;
l_eam_wo_rec               EAM_PROCESS_WO_PUB.eam_wo_rec_type;
l_eam_op_tbl               EAM_PROCESS_WO_PUB.eam_op_tbl_type;
l_eam_op_network_tbl       EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
l_eam_res_tbl              EAM_PROCESS_WO_PUB.eam_res_tbl_type;
l_eam_res_inst_tbl         EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
l_eam_sub_res_tbl          EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
l_eam_res_usage_tbl        EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
l_eam_mat_req_tbl          EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
l_eam_direct_items_tbl     EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
l_out_eam_wo_rec           EAM_PROCESS_WO_PUB.eam_wo_rec_type;
l_out_eam_op_tbl           EAM_PROCESS_WO_PUB.eam_op_tbl_type;
l_out_eam_op_network_tbl   EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
l_out_eam_res_tbl          EAM_PROCESS_WO_PUB.eam_res_tbl_type;
l_out_eam_res_inst_tbl     EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
l_out_eam_sub_res_tbl      EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
l_out_eam_res_usage_tbl    EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
l_out_eam_mat_req_tbl      EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
l_out_eam_direct_items_tbl EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

BEGIN

  -- Enable Debug
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT process_material_req_PVT;

  -- Map all input AHL Material Requirement record attributes to the
  -- corresponding EAM Material Requirement record attributes.
  FOR i IN p_material_req_tbl.FIRST..p_material_req_tbl.LAST LOOP

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'Inputs for API: ' || G_PKG_NAME||'.'||l_api_name );
      AHL_DEBUG_PUB.debug( 'Material Requirement Record Number : ' || i );
    END IF;

    map_ahl_eam_mat_rec
    (
      p_material_req_rec    => p_material_req_tbl(i),
      x_eam_mat_req_rec     => l_eam_mat_req_tbl(i)
    );

  END LOOP;

  -- Set Debug Parameters for the EAM API
  IF ( G_DEBUG = 'Y' ) THEN
    set_eam_debug_params
    (
      x_debug           => l_debug,
      x_output_dir      => l_output_dir,
      x_debug_file_name => l_debug_filename,
      x_debug_file_mode => l_debug_file_mode
    );
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( 'Invoking EAM process_wo API' );
  END IF;

  -- Invoke EAM BO API for Updating the Job
  EAM_PROCESS_WO_PUB.process_wo
  (
    p_bo_identifier             => l_bo_identifier,
    p_api_version_number        => 1.0,
    p_init_msg_list             => l_init_msg_list,
    p_commit                    => FND_API.G_FALSE,
    p_eam_wo_rec                => l_eam_wo_rec,
    p_eam_op_tbl                => l_eam_op_tbl,
    p_eam_op_network_tbl        => l_eam_op_network_tbl,
    p_eam_res_tbl               => l_eam_res_tbl,
    p_eam_res_inst_tbl          => l_eam_res_inst_tbl,
    p_eam_sub_res_tbl           => l_eam_sub_res_tbl,
    p_eam_res_usage_tbl         => l_eam_res_usage_tbl,
    p_eam_mat_req_tbl           => l_eam_mat_req_tbl,
    p_eam_direct_items_tbl      => l_eam_direct_items_tbl,
    x_eam_wo_rec                => l_out_eam_wo_rec,
    x_eam_op_tbl                => l_out_eam_op_tbl,
    x_eam_op_network_tbl        => l_out_eam_op_network_tbl,
    x_eam_res_tbl               => l_out_eam_res_tbl,
    x_eam_res_inst_tbl          => l_out_eam_res_inst_tbl,
    x_eam_sub_res_tbl           => l_out_eam_sub_res_tbl,
    x_eam_res_usage_tbl         => l_out_eam_res_usage_tbl,
    x_eam_mat_req_tbl           => l_out_eam_mat_req_tbl,
    x_eam_direct_items_tbl      => l_out_eam_direct_items_tbl,
    x_return_status             => l_return_status,
    x_msg_count                 => l_msg_count,
    p_debug                     => l_debug,
    p_output_dir                => l_output_dir,
    p_debug_filename            => l_debug_filename,
    p_debug_file_mode           => l_debug_file_mode
  );

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'Error Count from EAM API : ' || l_msg_count );
      AHL_DEBUG_PUB.debug( 'Error Count from Error Stack : ' || FND_MSG_PUB.count_msg );
    END IF;

    RAISE FND_API.G_EXC_ERROR;
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
    ROLLBACK TO process_material_req_PVT;
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
    ROLLBACK TO process_material_req_PVT;
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
    ROLLBACK TO process_material_req_PVT;
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

END process_material_req;

PROCEDURE process_resource_req
(
  p_api_version            IN   NUMBER     := 1.0,
  p_init_msg_list          IN   VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN   VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default                IN   VARCHAR2   := FND_API.G_FALSE,
  p_module_type            IN   VARCHAR2   := NULL,
  x_return_status          OUT  NOCOPY  VARCHAR2,
  x_msg_count              OUT  NOCOPY  NUMBER,
  x_msg_data               OUT  NOCOPY  VARCHAR2,
  p_resource_req_tbl       IN   AHL_PP_RESRC_REQUIRE_PVT.resrc_require_tbl_type
)
IS

l_api_name                 VARCHAR2(30) := 'process_resource_req';

-- Declare EAM API parameters
l_bo_identifier            VARCHAR2(10) := 'AHL';
l_init_msg_list            BOOLEAN := TRUE;
l_debug                    VARCHAR2(1)  := 'N';
l_output_dir               VARCHAR2(80);
l_debug_filename           VARCHAR2(80);
l_debug_file_mode          VARCHAR2(1);
l_return_status            VARCHAR2(1);
l_msg_count                NUMBER;
l_eam_wo_rec               EAM_PROCESS_WO_PUB.eam_wo_rec_type;
l_eam_op_tbl               EAM_PROCESS_WO_PUB.eam_op_tbl_type;
l_eam_op_network_tbl       EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
l_eam_res_tbl              EAM_PROCESS_WO_PUB.eam_res_tbl_type;
l_eam_res_inst_tbl         EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
l_eam_sub_res_tbl          EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
l_eam_res_usage_tbl        EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
l_eam_mat_req_tbl          EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
l_eam_direct_items_tbl     EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
l_out_eam_wo_rec           EAM_PROCESS_WO_PUB.eam_wo_rec_type;
l_out_eam_op_tbl           EAM_PROCESS_WO_PUB.eam_op_tbl_type;
l_out_eam_op_network_tbl   EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
l_out_eam_res_tbl          EAM_PROCESS_WO_PUB.eam_res_tbl_type;
l_out_eam_res_inst_tbl     EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
l_out_eam_sub_res_tbl      EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
l_out_eam_res_usage_tbl    EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
l_out_eam_mat_req_tbl      EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
l_out_eam_direct_items_tbl EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

BEGIN

  -- Enable Debug
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT process_resource_req_PVT;

  -- Map all input AHL Resource Requirement record attributes to the
  -- corresponding EAM Resource Requirement record attributes.
  FOR i IN p_resource_req_tbl.FIRST..p_resource_req_tbl.LAST LOOP

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'Inputs for API: ' || G_PKG_NAME||'.'||l_api_name );
      AHL_DEBUG_PUB.debug( 'Resource Requirement Record Number : ' || i );
    END IF;

    map_ahl_eam_res_rec
    (
      p_resource_req_rec    => p_resource_req_tbl(i),
      x_eam_res_rec         => l_eam_res_tbl(i)
    );

  END LOOP;

  -- Set Debug Parameters for the EAM API
  IF ( G_DEBUG = 'Y' ) THEN
    set_eam_debug_params
    (
      x_debug           => l_debug,
      x_output_dir      => l_output_dir,
      x_debug_file_name => l_debug_filename,
      x_debug_file_mode => l_debug_file_mode
    );
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( 'Invoking EAM process_wo API' );
  END IF;

  -- Invoke EAM BO API for Updating the Job
  EAM_PROCESS_WO_PUB.process_wo
  (
    p_bo_identifier             => l_bo_identifier,
    p_api_version_number        => 1.0,
    p_init_msg_list             => l_init_msg_list,
    p_commit                    => FND_API.G_FALSE,
    p_eam_wo_rec                => l_eam_wo_rec,
    p_eam_op_tbl                => l_eam_op_tbl,
    p_eam_op_network_tbl        => l_eam_op_network_tbl,
    p_eam_res_tbl               => l_eam_res_tbl,
    p_eam_res_inst_tbl          => l_eam_res_inst_tbl,
    p_eam_sub_res_tbl           => l_eam_sub_res_tbl,
    p_eam_res_usage_tbl         => l_eam_res_usage_tbl,
    p_eam_mat_req_tbl           => l_eam_mat_req_tbl,
    p_eam_direct_items_tbl      => l_eam_direct_items_tbl,
    x_eam_wo_rec                => l_out_eam_wo_rec,
    x_eam_op_tbl                => l_out_eam_op_tbl,
    x_eam_op_network_tbl        => l_out_eam_op_network_tbl,
    x_eam_res_tbl               => l_out_eam_res_tbl,
    x_eam_res_inst_tbl          => l_out_eam_res_inst_tbl,
    x_eam_sub_res_tbl           => l_out_eam_sub_res_tbl,
    x_eam_res_usage_tbl         => l_out_eam_res_usage_tbl,
    x_eam_mat_req_tbl           => l_out_eam_mat_req_tbl,
    x_eam_direct_items_tbl      => l_out_eam_direct_items_tbl,
    x_return_status             => l_return_status,
    x_msg_count                 => l_msg_count,
    p_debug                     => l_debug,
    p_output_dir                => l_output_dir,
    p_debug_filename            => l_debug_filename,
    p_debug_file_mode           => l_debug_file_mode
  );

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'Error Count from EAM API : ' || l_msg_count );
      AHL_DEBUG_PUB.debug( 'Error Count from Error Stack : ' || FND_MSG_PUB.count_msg );
    END IF;

    RAISE FND_API.G_EXC_ERROR;
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
    ROLLBACK TO process_resource_req_PVT;
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
    ROLLBACK TO process_resource_req_PVT;
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
    ROLLBACK TO process_resource_req_PVT;
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

END process_resource_req;

PROCEDURE process_resource_assign
(
  p_api_version            IN   NUMBER     := 1.0,
  p_init_msg_list          IN   VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN   VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default                IN   VARCHAR2   := FND_API.G_FALSE,
  p_module_type            IN   VARCHAR2   := NULL,
  x_return_status          OUT  NOCOPY  VARCHAR2,
  x_msg_count              OUT  NOCOPY  NUMBER,
  x_msg_data               OUT  NOCOPY  VARCHAR2,
  p_resource_assign_tbl    IN   AHL_PP_RESRC_ASSIGN_PVT.resrc_assign_tbl_type
)
IS

l_api_name                 VARCHAR2(30) := 'process_resource_assign';

-- Declare EAM API parameters
l_bo_identifier            VARCHAR2(10) := 'AHL';
l_init_msg_list            BOOLEAN := TRUE;
l_debug                    VARCHAR2(1)  := 'N';
l_output_dir               VARCHAR2(80);
l_debug_filename           VARCHAR2(80);
l_debug_file_mode          VARCHAR2(1);
l_return_status            VARCHAR2(1);
l_msg_count                NUMBER;
l_eam_wo_rec               EAM_PROCESS_WO_PUB.eam_wo_rec_type;
l_eam_op_tbl               EAM_PROCESS_WO_PUB.eam_op_tbl_type;
l_eam_op_network_tbl       EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
l_eam_res_tbl              EAM_PROCESS_WO_PUB.eam_res_tbl_type;
l_eam_res_inst_tbl         EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
l_eam_sub_res_tbl          EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
l_eam_res_usage_tbl        EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
l_eam_mat_req_tbl          EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
l_eam_direct_items_tbl     EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
l_out_eam_wo_rec           EAM_PROCESS_WO_PUB.eam_wo_rec_type;
l_out_eam_op_tbl           EAM_PROCESS_WO_PUB.eam_op_tbl_type;
l_out_eam_op_network_tbl   EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
l_out_eam_res_tbl          EAM_PROCESS_WO_PUB.eam_res_tbl_type;
l_out_eam_res_inst_tbl     EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
l_out_eam_sub_res_tbl      EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
l_out_eam_res_usage_tbl    EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
l_out_eam_mat_req_tbl      EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
l_out_eam_direct_items_tbl EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

BEGIN

  -- Enable Debug
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT process_resource_assign_PVT;

  -- Map all input AHL Material Requirement record attributes to the
  -- corresponding EAM Material Requirement record attributes.
  FOR i IN p_resource_assign_tbl.FIRST..p_resource_assign_tbl.LAST LOOP

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'Inputs for API: ' || G_PKG_NAME||'.'||l_api_name );
      AHL_DEBUG_PUB.debug( 'Resource Assignment Record Number : ' || i );
    END IF;

    map_ahl_eam_res_inst_rec
    (
      p_resource_assign_rec    => p_resource_assign_tbl(i),
      x_eam_res_inst_rec       => l_eam_res_inst_tbl(i)
    );

  END LOOP;

  -- Set Debug Parameters for the EAM API
  IF ( G_DEBUG = 'Y' ) THEN
    set_eam_debug_params
    (
      x_debug           => l_debug,
      x_output_dir      => l_output_dir,
      x_debug_file_name => l_debug_filename,
      x_debug_file_mode => l_debug_file_mode
    );
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( 'Invoking EAM process_wo API' );
  END IF;

  -- Invoke EAM BO API for Updating the Job
  EAM_PROCESS_WO_PUB.process_wo
  (
    p_bo_identifier             => l_bo_identifier,
    p_api_version_number        => 1.0,
    p_init_msg_list             => l_init_msg_list,
    p_commit                    => FND_API.G_FALSE,
    p_eam_wo_rec                => l_eam_wo_rec,
    p_eam_op_tbl                => l_eam_op_tbl,
    p_eam_op_network_tbl        => l_eam_op_network_tbl,
    p_eam_res_tbl               => l_eam_res_tbl,
    p_eam_res_inst_tbl          => l_eam_res_inst_tbl,
    p_eam_sub_res_tbl           => l_eam_sub_res_tbl,
    p_eam_res_usage_tbl         => l_eam_res_usage_tbl,
    p_eam_mat_req_tbl           => l_eam_mat_req_tbl,
    p_eam_direct_items_tbl      => l_eam_direct_items_tbl,
    x_eam_wo_rec                => l_out_eam_wo_rec,
    x_eam_op_tbl                => l_out_eam_op_tbl,
    x_eam_op_network_tbl        => l_out_eam_op_network_tbl,
    x_eam_res_tbl               => l_out_eam_res_tbl,
    x_eam_res_inst_tbl          => l_out_eam_res_inst_tbl,
    x_eam_sub_res_tbl           => l_out_eam_sub_res_tbl,
    x_eam_res_usage_tbl         => l_out_eam_res_usage_tbl,
    x_eam_mat_req_tbl           => l_out_eam_mat_req_tbl,
    x_eam_direct_items_tbl      => l_out_eam_direct_items_tbl,
    x_return_status             => l_return_status,
    x_msg_count                 => l_msg_count,
    p_debug                     => l_debug,
    p_output_dir                => l_output_dir,
    p_debug_filename            => l_debug_filename,
    p_debug_file_mode           => l_debug_file_mode
  );

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'Error Count from EAM API : ' || l_msg_count );
      AHL_DEBUG_PUB.debug( 'Error Count from Error Stack : ' || FND_MSG_PUB.count_msg );
    END IF;

    RAISE FND_API.G_EXC_ERROR;
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
    ROLLBACK TO process_resource_assign_PVT;
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
    ROLLBACK TO process_resource_assign_PVT;
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
    ROLLBACK TO process_resource_assign_PVT;
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

END process_resource_assign;

PROCEDURE process_eam_workorders
(
  p_api_version          IN   NUMBER     := 1.0,
  p_init_msg_list        IN   VARCHAR2   := FND_API.G_TRUE,
  p_commit               IN   VARCHAR2   := FND_API.G_FALSE,
  p_validation_level     IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default              IN   VARCHAR2   := FND_API.G_FALSE,
  p_module_type          IN   VARCHAR2   := NULL,
  x_return_status        OUT  NOCOPY  VARCHAR2,
  x_msg_count            OUT  NOCOPY  NUMBER,
  x_msg_data             OUT  NOCOPY  VARCHAR2,
  p_x_eam_wo_tbl         IN OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_tbl_type,
  p_eam_wo_relations_tbl IN    EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type,
  p_eam_op_tbl           IN    EAM_PROCESS_WO_PUB.eam_op_tbl_type,
  p_eam_res_req_tbl      IN    EAM_PROCESS_WO_PUB.eam_res_tbl_type,
  p_eam_mat_req_tbl      IN    EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
)
IS

l_api_name                 VARCHAR2(30) := 'process_eam_workorders';

-- Declare EAM API parameters
l_bo_identifier            VARCHAR2(10) := 'AHL';
l_init_msg_list            BOOLEAN := TRUE;
l_debug                    VARCHAR2(1)  := 'N';
l_output_dir               VARCHAR2(80);
l_debug_filename           VARCHAR2(80);
l_debug_file_mode          VARCHAR2(1);
l_return_status            VARCHAR2(1);
l_msg_count                NUMBER;
l_eam_op_network_tbl       EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
l_eam_res_inst_tbl         EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
l_eam_sub_res_tbl          EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
l_eam_direct_items_tbl     EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
l_out_eam_wo_tbl           EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
l_out_eam_wo_rel_tbl       EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
l_out_eam_op_tbl           EAM_PROCESS_WO_PUB.eam_op_tbl_type;
l_out_eam_op_network_tbl   EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
l_out_eam_res_tbl          EAM_PROCESS_WO_PUB.eam_res_tbl_type;
l_out_eam_res_inst_tbl     EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
l_out_eam_sub_res_tbl      EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
l_out_eam_mat_req_tbl      EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
l_out_eam_direct_items_tbl EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

BEGIN

  -- Enable Debug
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT process_eam_workorders_PVT;

  -- Set Debug Parameters for the EAM API
  IF ( G_DEBUG = 'Y' ) THEN
    set_eam_debug_params
    (
      x_debug           => l_debug,
      x_output_dir      => l_output_dir,
      x_debug_file_name => l_debug_filename,
      x_debug_file_mode => l_debug_file_mode
    );
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( 'Invoking EAM process_master_child_wo API' );

				IF(p_x_eam_wo_tbl.COUNT > 0) THEN
    FOR i IN p_x_eam_wo_tbl.FIRST..p_x_eam_wo_tbl.LAST LOOP
      AHL_DEBUG_PUB.debug( 'Workorder('||i||') batch_id : '||p_x_eam_wo_tbl(i).batch_id );
      AHL_DEBUG_PUB.debug( 'Workorder('||i||') header_id : '||p_x_eam_wo_tbl(i).header_id );
    END LOOP;
				END IF;

    IF ( p_eam_op_tbl.COUNT > 0 ) THEN
      FOR i IN p_eam_op_tbl.FIRST..p_eam_op_tbl.LAST LOOP
        AHL_DEBUG_PUB.debug( 'Operation('||i||') batch_id : '||p_eam_op_tbl(i).batch_id );
        AHL_DEBUG_PUB.debug( 'Operation('||i||') header_id : '||p_eam_op_tbl(i).header_id );
      END LOOP;
    END IF;

    IF ( p_eam_res_req_tbl.COUNT > 0 ) THEN
      FOR i IN p_eam_res_req_tbl.FIRST..p_eam_res_req_tbl.LAST LOOP
        AHL_DEBUG_PUB.debug( 'Resource('||i||') batch_id : '||p_eam_res_req_tbl(i).batch_id );
        AHL_DEBUG_PUB.debug( 'Resource('||i||') header_id : '||p_eam_res_req_tbl(i).header_id );
      END LOOP;
    END IF;

    IF ( p_eam_mat_req_tbl.COUNT > 0 ) THEN
      FOR i IN p_eam_mat_req_tbl.FIRST..p_eam_mat_req_tbl.LAST LOOP
        AHL_DEBUG_PUB.debug( 'Material('||i||') batch_id : '||p_eam_mat_req_tbl(i).batch_id );
        AHL_DEBUG_PUB.debug( 'Material('||i||') header_id : '||p_eam_mat_req_tbl(i).header_id );
      END LOOP;
    END IF;

  END IF;

  EAM_PROCESS_WO_PUB.process_master_child_wo
  (
   p_bo_identifier             => l_bo_identifier,
   p_api_version_number        => 1.0,
   p_init_msg_list             => l_init_msg_list,
   p_eam_wo_relations_tbl      => p_eam_wo_relations_tbl,
   p_eam_wo_tbl                => p_x_eam_wo_tbl,
   p_eam_op_tbl                => p_eam_op_tbl,
   p_eam_op_network_tbl        => l_eam_op_network_tbl,
   p_eam_res_tbl               => p_eam_res_req_tbl,
   p_eam_res_inst_tbl          => l_eam_res_inst_tbl,
   p_eam_sub_res_tbl           => l_eam_sub_res_tbl,
   p_eam_mat_req_tbl           => p_eam_mat_req_tbl,
   p_eam_direct_items_tbl      => l_eam_direct_items_tbl,
   x_eam_wo_tbl                => l_out_eam_wo_tbl,
   x_eam_wo_relations_tbl      => l_out_eam_wo_rel_tbl,
   x_eam_op_tbl                => l_out_eam_op_tbl,
   x_eam_op_network_tbl        => l_out_eam_op_network_tbl,
   x_eam_res_tbl               => l_out_eam_res_tbl,
   x_eam_res_inst_tbl          => l_out_eam_res_inst_tbl,
   x_eam_sub_res_tbl           => l_out_eam_sub_res_tbl,
   x_eam_mat_req_tbl           => l_out_eam_mat_req_tbl,
   x_eam_direct_items_tbl      => l_out_eam_direct_items_tbl,
   x_return_status             => l_return_status,
   x_msg_count                 => l_msg_count,
   p_commit                    => FND_API.G_FALSE,
   p_debug                     => l_debug,
   p_output_dir                => l_output_dir,
   p_debug_filename            => l_debug_filename,
   p_debug_file_mode           => l_debug_file_mode
  );

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'Error Count from EAM API : ' || l_msg_count );
      AHL_DEBUG_PUB.debug( 'Error Count from Error Stack : ' || FND_MSG_PUB.count_msg );
    END IF;

    RAISE FND_API.G_EXC_ERROR;

  ELSE
    --Change made on Nov 17, 2005 by jeli due to bug 4742895.
    --Ignore messages in stack if return status is S after calls to EAM APIs.
    FND_MSG_PUB.initialize;

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'EAM process_master_child_wo API Successful' );
      AHL_DEBUG_PUB.debug( 'Input Workorder Table count : ' || p_x_eam_wo_tbl.COUNT );
      AHL_DEBUG_PUB.debug( 'Output Workorder Table count : ' || l_out_eam_wo_tbl.COUNT );
    END IF;

    FOR i IN 1..l_out_eam_wo_tbl.COUNT LOOP
      IF ( l_out_eam_wo_tbl(i).wip_entity_id IS NULL ) THEN
        FND_MESSAGE.set_name('AHL','AHL_PRD_CREATE_WIP_JOB_FAILED');
        FND_MESSAGE.set_token('HEADER', l_out_eam_wo_tbl(i).header_id );
        FND_MSG_PUB.add;

        IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( 'No wip_entity_id generated for header_id:' || l_out_eam_wo_tbl(i).header_id );
        END IF;
      ELSE

        IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( 'wip_entity_id(' || i || '):' || TO_CHAR( l_out_eam_wo_tbl(i).wip_entity_id ) );
        END IF;

        p_x_eam_wo_tbl(i).wip_entity_id := l_out_eam_wo_tbl(i).wip_entity_id;

      END IF;
    END LOOP;

    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Perform the Commit (if requested)
    IF FND_API.to_boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
  END IF;

  -- Disable debug (if enabled)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO process_eam_workorders_PVT;
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
    ROLLBACK TO process_eam_workorders_PVT;
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
    ROLLBACK TO process_eam_workorders_PVT;
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
END process_eam_workorders;

END AHL_EAM_JOB_PVT;

/
