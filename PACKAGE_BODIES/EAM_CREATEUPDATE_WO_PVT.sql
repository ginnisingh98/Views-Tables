--------------------------------------------------------
--  DDL for Package Body EAM_CREATEUPDATE_WO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_CREATEUPDATE_WO_PVT" AS
/* $Header: EAMVCUWB.pls 120.20.12010000.5 2010/04/07 10:15:57 vboddapa ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVCUWB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_CREATEUPDATE_WO_PVT
--
--  NOTES
--
--  HISTORY
***************************************************************************/


/*******************************
Procedure to create a workorder from
another workorder.This procedure calls workorder API to copy the workorder
*******************************/
PROCEDURE  COPY_WORKORDER
  (
           p_init_msg_list                 IN VARCHAR2
         , p_commit                        IN VARCHAR2
         , p_wip_entity_id              IN NUMBER
         , p_organization_id         IN NUMBER
         , x_return_status                 OUT NOCOPY  VARCHAR2
	 , x_wip_entity_name           OUT NOCOPY VARCHAR2
	 ,x_wip_entity_id                    OUT NOCOPY NUMBER
  )
 IS
     l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
     l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
     l_eam_op_network_tbl EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
     l_eam_res_tbl EAM_PROCESS_WO_PUB.eam_res_tbl_type;
     l_eam_res_inst_tbl EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
     l_eam_res_usage_tbl EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
     l_eam_mat_req_tbl EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
     l_eam_direct_items_tbl  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
     l_msg_count  NUMBER;

 BEGIN

 SAVEPOINT COPY_WO;

			     EAM_PROCESS_WO_PUB.COPY_WORKORDER
			       (  p_bo_identifier     =>'EAM'
				, p_api_version_number =>1.0
				, p_init_msg_list          => p_init_msg_list
				, p_commit                    => FND_API.G_FALSE
				 , p_wip_entity_id          =>p_wip_entity_id
				, p_organization_id      => p_organization_id
				, x_eam_wo_rec            => l_eam_wo_rec
				, x_eam_op_tbl              => l_eam_op_tbl
				, x_eam_op_network_tbl   => l_eam_op_network_tbl
				, x_eam_res_tbl             => l_eam_res_tbl
				, x_eam_res_inst_tbl    => l_eam_res_inst_tbl
				, x_eam_res_usage_tbl  => l_eam_res_usage_tbl
				, x_eam_mat_req_tbl       => l_eam_mat_req_tbl
				, x_eam_direct_items_tbl  => l_eam_direct_items_tbl
				, x_return_status          => x_return_status
				, x_msg_count            => l_msg_count
				);

               IF(NVL(x_return_status,'U') <> 'S') THEN
		    ROLLBACK TO COPY_WO;
		    RETURN;
		 END IF;

		IF(x_return_status = 'S' ) THEN
	   		    x_wip_entity_name := l_eam_wo_rec.wip_entity_name;
			    x_wip_entity_id := l_eam_wo_rec.wip_entity_id;
			    IF(p_commit = FND_API.G_TRUE) THEN
                        		    COMMIT;
			    END IF;
        	 END IF;

  EXCEPTION
   WHEN OTHERS THEN
       ROLLBACK TO COPY_WO;
       x_return_status := 'U';
 END COPY_WORKORDER;


/*********************************************************
Wrapper procedure on top of WO API.This is used to create/update workorder and its related entities
************************************************/
PROCEDURE CREATE_UPDATE_WO
(
      p_commit                      IN    VARCHAR2      := FND_API.G_FALSE,
      p_eam_wo_tbl		IN			EAM_PROCESS_WO_PUB.eam_wo_tbl_type,
      p_eam_wo_relations_tbl     IN            EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type,
      p_eam_op_tbl               IN                    EAM_PROCESS_WO_PUB.eam_op_tbl_type,
      p_eam_res_tbl              IN                   EAM_PROCESS_WO_PUB.eam_res_tbl_type,
      p_eam_res_inst_tbl     IN			EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type,
      p_eam_res_usage_tbl      IN              EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type,
      p_eam_mat_req_tbl         IN                EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type,
      p_eam_direct_items_tbl    IN             EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type,
      p_eam_request_tbl           IN              EAM_PROCESS_WO_PUB.eam_request_tbl_type,
      p_eam_wo_comp_tbl		 IN		EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type,
      p_eam_meter_reading_tbl   IN		EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type,
      p_eam_counter_prop_tbl    IN	 EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type,
      p_eam_wo_comp_rebuild_tbl	 IN	EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type,
      p_eam_wo_comp_mr_read_tbl	 IN	EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type,
      p_prev_activity_id              IN                NUMBER,
      p_failure_id          IN NUMBER			:= null,
      p_failure_date        IN DATE				:= null,
      p_failure_entry_id    IN NUMBER		 := null,
      p_failure_code        IN VARCHAR2		 := null,
      p_cause_code          IN VARCHAR2		 := null,
      p_resolution_code     IN VARCHAR2		 := null,
      p_failure_comments    IN VARCHAR2		:= null,
      p_failure_code_required     IN VARCHAR2 DEFAULT NULL,
      x_wip_entity_id              OUT NOCOPY       NUMBER,
      x_return_status		OUT NOCOPY	VARCHAR2,
      x_msg_count			OUT NOCOPY	NUMBER
)
IS
      l_eam_wo_tbl					EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
      l_eam_wo_rec					EAM_PROCESS_WO_PUB.eam_wo_rec_type;
      l_import_eam_wo_rec                               EAM_PROCESS_WO_PUB.eam_wo_rec_type; --MSP Project
      l_eam_op_network_tbl				EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
      l_eam_res_tbl					EAM_PROCESS_WO_PUB.eam_res_tbl_type;
      l_eam_sub_res_tbl					EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
      l_eam_wo_quality_tbl				EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
      l_eam_op_comp_tbl					EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
      l_eam_wo_comp_tbl					EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
      l_eam_wo_comp_rec					EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
      l_eam_mat_req_tbl                                 EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
      l_eam_mat_req_rec                                 EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;
      l_eam_direct_items_tbl                            EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
      l_eam_direct_items_rec                            EAM_PROCESS_WO_PUB.eam_direct_items_rec_type;

      l_eam_wo_relations_tbl_out			EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
      l_eam_wo_rec_out					EAM_PROCESS_WO_PUB.eam_wo_rec_type;
      l_eam_wo_tbl_out					EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
      l_eam_op_tbl_out					EAM_PROCESS_WO_PUB.eam_op_tbl_type;
      l_eam_op_network_tbl_out				EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
      l_eam_res_tbl_out					EAM_PROCESS_WO_PUB.eam_res_tbl_type;
      l_eam_res_usage_tbl_out				EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
      l_eam_res_inst_tbl_out				EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
      l_eam_sub_res_tbl_out				EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
      l_eam_mat_req_tbl_out				EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
      l_eam_direct_items_tbl_out			EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
      l_eam_wo_comp_tbl_out				EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
      l_eam_wo_quality_tbl_out				EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
      l_eam_meter_reading_tbl_out			EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
      l_eam_counter_prop_tbl_out			EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
      l_eam_wo_comp_rebuild_tbl_out			EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
      l_eam_wo_comp_mr_read_tbl_out			EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
      l_eam_op_comp_tbl_out				EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
      l_eam_request_tbl_out				EAM_PROCESS_WO_PUB.eam_request_tbl_type;
      l_eam_wo_comp_rec_out				EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;


      l_output_dir                      VARCHAR2(512);

      CURSOR resources
      (l_resource_id NUMBER,l_organization_id NUMBER)
      IS
	      SELECT autocharge_type
	      FROM  BOM_RESOURCES
	      WHERE resource_id = l_resource_id
	      AND organization_id = l_organization_id;

      l_resources resources%ROWTYPE;
      l_wip_entity_id       NUMBER;
      l_asset_group_id     NUMBER;
      l_asset_number       VARCHAR2(30);
      l_rebuild_item_id     NUMBER;
      l_rebuild_serial_number    VARCHAR2(30);

      /* Added for bug#4555609 */
    l_prev_activity_id         NUMBER;
    l_prev_description VARCHAR2(240);
    l_prev_priority NUMBER;
    l_prev_work_order_type  VARCHAR2(30);
    l_prev_shutdown_type VARCHAR2(30);
    l_prev_activity_type VARCHAR2(30);
    l_prev_activity_cause VARCHAR2(30);
    l_prev_activity_source VARCHAR2(30);
    l_prev_attribute_category VARCHAR2(30);
    l_prev_attribute1 VARCHAR2(150);
    l_prev_attribute2 VARCHAR2(150);
    l_prev_attribute3 VARCHAR2(150);
    l_prev_attribute4 VARCHAR2(150);
    l_prev_attribute5 VARCHAR2(150);
    l_prev_attribute6 VARCHAR2(150);
    l_prev_attribute7 VARCHAR2(150);
    l_prev_attribute8 VARCHAR2(150);
    l_prev_attribute9 VARCHAR2(150);
    l_prev_attribute10 VARCHAR2(150);
    l_prev_attribute11 VARCHAR2(150);
    l_prev_attribute12 VARCHAR2(150);
    l_prev_attribute13 VARCHAR2(150);
    l_prev_attribute14 VARCHAR2(150);
    l_prev_attribute15 VARCHAR2(150);
    l_maintenance_object_type NUMBER;
    l_maintenance_object_id NUMBER;
	  /* Added for bug#6053425 Start */
	 	l_prev_project_id  NUMBER;
	 	l_prev_task_id     NUMBER;
	 	/* Added for bug#6053425 End */

     l_eam_failure_entry_record    EAM_Process_Failure_Entry_PUB.eam_failure_entry_record_typ;
     l_eam_failure_codes_tbl       EAM_Process_Failure_Entry_PUB.eam_failure_codes_tbl_typ;
     l_fail_dept_id       NUMBER;
     l_eam_location_id    NUMBER;
     l_eam_failure_code_required varchar2(30);
     l_wo_exists        BOOLEAN;
     l_org_id               NUMBER;
     l_validate             BOOLEAN;
     l_error_segments                        number;
     l_error_message                         varchar2(2000);

--    Added for 8969942

	l_organization_id     NUMBER;
 	l_Operation_Seq_Num    NUMBER;
 	l_inventory_item_id     NUMBER;
 	l_dir_item_seq_id NUMBER;

 	l_prev_mat_attribute_category VARCHAR2(30);
 	l_prev_mat_attribute1 VARCHAR2(150);
 	l_prev_mat_attribute2 VARCHAR2(150);
 	l_prev_mat_attribute3 VARCHAR2(150);
 	l_prev_mat_attribute4 VARCHAR2(150);
 	l_prev_mat_attribute5 VARCHAR2(150);
 	l_prev_mat_attribute6 VARCHAR2(150);
 	l_prev_mat_attribute7 VARCHAR2(150);
 	l_prev_mat_attribute8 VARCHAR2(150);
 	l_prev_mat_attribute9 VARCHAR2(150);
 	l_prev_mat_attribute10 VARCHAR2(150);
 	l_prev_mat_attribute11 VARCHAR2(150);
 	l_prev_mat_attribute12 VARCHAR2(150);
 	l_prev_mat_attribute13 VARCHAR2(150);
 	l_prev_mat_attribute14 VARCHAR2(150);
 	l_prev_mat_attribute15 VARCHAR2(150);

 	l_prev_dir_attribute_category VARCHAR2(30);
 	l_prev_dir_attribute1 VARCHAR2(150);
 	l_prev_dir_attribute2 VARCHAR2(150);
 	l_prev_dir_attribute3 VARCHAR2(150);
 	l_prev_dir_attribute4 VARCHAR2(150);
 	l_prev_dir_attribute5 VARCHAR2(150);
 	l_prev_dir_attribute6 VARCHAR2(150);
 	l_prev_dir_attribute7 VARCHAR2(150);
 	l_prev_dir_attribute8 VARCHAR2(150);
 	l_prev_dir_attribute9 VARCHAR2(150);
 	l_prev_dir_attribute10 VARCHAR2(150);
 	l_prev_dir_attribute11 VARCHAR2(150);
 	l_prev_dir_attribute12 VARCHAR2(150);
 	l_prev_dir_attribute13 VARCHAR2(150);
 	l_prev_dir_attribute14 VARCHAR2(150);
 	l_prev_dir_attribute15 VARCHAR2(150);

BEGIN

      /* get output directory path from database */
   EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

	SAVEPOINT     create_update_wo;
        /*MSP Project addition*/
        IF(p_eam_wo_tbl IS NOT NULL) THEN
         IF(p_eam_wo_tbl.first is not NULL) THEN
           l_import_eam_wo_rec := p_eam_wo_tbl(p_eam_wo_tbl.first);
         END IF;
        END IF;

      IF(l_import_eam_wo_rec.ATTRIBUTE15='import') THEN
          eam_import_workorders.import_workorders(p_commit,
            p_eam_wo_tbl,
            p_eam_wo_relations_tbl,
            p_eam_op_tbl,
            p_eam_res_tbl,
            p_eam_res_inst_tbl,
            p_eam_res_usage_tbl,
            p_eam_mat_req_tbl,
            p_eam_direct_items_tbl,
            p_eam_request_tbl,
            p_eam_wo_comp_tbl,
            p_eam_meter_reading_tbl,
            p_eam_counter_prop_tbl,
            p_eam_wo_comp_rebuild_tbl,
            p_eam_wo_comp_mr_read_tbl,
            x_wip_entity_id,
            x_return_status,
            x_msg_count);
      ELSE          /*MSP code end*/

	l_eam_wo_comp_tbl := p_eam_wo_comp_tbl;

         IF(l_eam_wo_comp_tbl IS NOT NULL AND l_eam_wo_comp_tbl.COUNT>0) THEN

	  l_eam_wo_comp_rec := l_eam_wo_comp_tbl(l_eam_wo_comp_tbl.FIRST);

		/* Failure Analysis Project Start */

		       l_eam_failure_entry_record.failure_id   := p_failure_id;
		       l_eam_failure_entry_record.failure_date := p_failure_date;

		       l_eam_failure_codes_tbl(1).failure_id := p_failure_id;
		       l_eam_failure_codes_tbl(1).failure_entry_id := p_failure_entry_id;
		       l_eam_failure_codes_tbl(1).failure_code     := p_failure_code;
		       l_eam_failure_codes_tbl(1).cause_code       := p_cause_code;
		       l_eam_failure_codes_tbl(1).resolution_code  := p_resolution_code;
		       l_eam_failure_codes_tbl(1).comments         := p_failure_comments;


		       SELECT
			 maintenance_object_type
			,maintenance_object_id
			INTO
                        l_maintenance_object_type
		       ,l_maintenance_object_id
			     FROM WIP_DISCRETE_JOBS
			     WHERE wip_entity_id = l_eam_wo_comp_rec.wip_entity_id;

		--only if asset number/rebuild serial number exists for work order
			IF(l_maintenance_object_type =3) THEN
				 BEGIN

			            --if workorder dept. is null,de fault it from asset's owning dept

					 SELECT OWNING_DEPARTMENT_ID
					   INTO l_fail_dept_id
					   FROM eam_org_maint_defaults
					  WHERE object_id =l_maintenance_object_id
					  AND object_type = 50
					  AND organization_id =l_eam_wo_comp_rec.organization_id;

				     SELECT area_id
				      INTO l_eam_location_id
				      FROM eam_org_maint_defaults
					WHERE object_id = l_maintenance_object_id
                                     AND object_type = 50
                                     AND organization_id = l_eam_wo_comp_rec.organization_id;

				    EXCEPTION
				      WHEN NO_DATA_FOUND THEN
				      NULL;
				    END;
				    END IF;  --end of check for mainteannce_object_type =3


	l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;
	l_eam_failure_entry_record.source_type := 1;
	l_eam_failure_entry_record.source_id := l_eam_wo_comp_rec.wip_entity_id;
	l_eam_failure_entry_record.object_type := l_maintenance_object_type;
	l_eam_failure_entry_record.object_id := l_maintenance_object_id;
	l_eam_failure_entry_record.maint_organization_id := l_eam_wo_comp_rec.organization_id;
	l_eam_failure_entry_record.current_organization_id := l_eam_wo_comp_rec.organization_id;
	l_eam_failure_entry_record.department_id := l_fail_dept_id;
	l_eam_failure_entry_record.area_id := l_eam_location_id;

        l_eam_failure_codes_tbl(1).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;

		IF (l_eam_failure_entry_record.failure_date IS NULL) THEN
			l_eam_failure_entry_record.failure_date := FND_API.G_MISS_DATE;
		END IF;

		IF (l_eam_failure_codes_tbl(1).failure_code IS NULL) THEN
			l_eam_failure_codes_tbl(1).failure_code := FND_API.G_MISS_CHAR;
		END IF;

		IF (l_eam_failure_codes_tbl(1).cause_code IS NULL) THEN
		    l_eam_failure_codes_tbl(1).cause_code := FND_API.G_MISS_CHAR;
		END IF;

		IF (l_eam_failure_codes_tbl(1).resolution_code IS NULL) THEN
		    l_eam_failure_codes_tbl(1).resolution_code := FND_API.G_MISS_CHAR;
		END IF;

		IF (l_eam_failure_codes_tbl(1).comments IS NULL) THEN
		    l_eam_failure_codes_tbl(1).comments := FND_API.G_MISS_CHAR;
		END IF;

		IF(l_eam_failure_entry_record.failure_id IS NOT NULL ) THEN
		  l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;
		ELSE
		   IF(l_eam_failure_entry_record.failure_date = FND_API.G_MISS_DATE) THEN
		      l_eam_failure_entry_record.transaction_type :=null;
		      l_eam_failure_entry_record.failure_date :=null;
		   ELSE
		      l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE ;
		   END IF;
		END IF;

		 IF(l_eam_failure_codes_tbl(1).failure_entry_id IS NOT NULL) THEN
			  l_eam_failure_codes_tbl(1).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;
			  l_eam_wo_comp_rec.eam_failure_codes_tbl(1) := l_eam_failure_codes_tbl(1);

		 ELSE
		   IF( NOT( (l_eam_failure_codes_tbl(1).failure_code = FND_API.G_MISS_CHAR)
			 AND (l_eam_failure_codes_tbl(1).cause_code = FND_API.G_MISS_CHAR)
			 AND (l_eam_failure_codes_tbl(1).resolution_code = FND_API.G_MISS_CHAR)
			 AND (l_eam_failure_codes_tbl(1).comments = FND_API.G_MISS_CHAR)
			)
		     ) THEN
			  l_eam_failure_codes_tbl(1).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE;

			   IF(l_eam_failure_codes_tbl(1).failure_code = FND_API.G_MISS_CHAR) THEN
				l_eam_failure_codes_tbl(1).failure_code := null;
			   END IF;

			   IF(l_eam_failure_codes_tbl(1).cause_code = FND_API.G_MISS_CHAR) THEN
				l_eam_failure_codes_tbl(1).cause_code := NULL;
			   END IF;

			  IF(l_eam_failure_codes_tbl(1).resolution_code = FND_API.G_MISS_CHAR) then
				l_eam_failure_codes_tbl(1).resolution_code := null;
			  END IF;

			  IF(l_eam_failure_codes_tbl(1).comments = FND_API.G_MISS_CHAR) then
				l_eam_failure_codes_tbl(1).comments := null;
			  END IF;
			    l_eam_wo_comp_rec.eam_failure_codes_tbl(1) := l_eam_failure_codes_tbl(1);

			 ELSE
			    l_eam_failure_codes_tbl.delete;
			    l_eam_wo_comp_rec.eam_failure_codes_tbl := l_eam_failure_codes_tbl;

			 END IF;
			END IF;

		     l_eam_wo_comp_rec.eam_failure_entry_record := l_eam_failure_entry_record;
		     l_eam_wo_comp_tbl(l_eam_wo_comp_tbl.FIRST) := l_eam_wo_comp_rec;

		END IF;

		/* Failure Analysis Project End */

       --Set the activity_id to Fnd_Api.G_Miss_Num if we want to delete the activity
       l_eam_wo_tbl := p_eam_wo_tbl;
       IF(l_eam_wo_tbl IS NOT  NULL AND l_eam_wo_tbl.COUNT>0) THEN

				   l_eam_wo_rec := l_eam_wo_tbl(l_eam_wo_tbl.FIRST);

				--set FND_API.G_MISS_xx if any columns are nulled out
		             l_wo_exists := TRUE;    --work order already exists...if no data found exception is thrown then l_wo_exists will be set to FALSE

				BEGIN
				       l_wip_entity_id :=l_eam_wo_rec.wip_entity_id;

				          SELECT       asset_number
					                        ,asset_group_id
								,rebuild_serial_number
				                                ,rebuild_item_id
								,primary_item_id
								,description
								,priority
								,work_order_type
								,shutdown_type
								,activity_type
								,activity_cause
								,activity_source
								,attribute_category
								,attribute1
								,attribute2
								,attribute3
								,attribute4
								,attribute5
								,attribute6
								,attribute7
								,attribute8
								,attribute9
								,attribute10
								,attribute11
								,attribute12
								,attribute13
								,attribute14
								,attribute15
								/* Added for bug#6053425 Start */
								,project_id
								,task_id
								/* Added for bug#6053425 End */
				       INTO             l_asset_number
				                            ,l_asset_group_id
							    ,l_rebuild_serial_number
							    ,l_rebuild_item_id
							    ,l_prev_activity_id
								,l_prev_description
								,l_prev_priority
								,l_prev_work_order_type
								,l_prev_shutdown_type
								,l_prev_activity_type
								,l_prev_activity_cause
								,l_prev_activity_source
								,l_prev_attribute_category
								,l_prev_attribute1
								,l_prev_attribute2
								,l_prev_attribute3
								,l_prev_attribute4
								,l_prev_attribute5
								,l_prev_attribute6
								,l_prev_attribute7
								,l_prev_attribute8
								,l_prev_attribute9
								,l_prev_attribute10
								,l_prev_attribute11
								,l_prev_attribute12
								,l_prev_attribute13
								,l_prev_attribute14
								,l_prev_attribute15
								/* Code Added for bug#6053425 Start */
 	              ,l_prev_project_id
 	              ,l_prev_task_id
 	              /* Code Added for bug#6053425 End */
				       FROM WIP_DISCRETE_JOBS
				       where wip_entity_id = l_wip_entity_id;

				       IF(l_asset_number is NOT NULL and l_eam_wo_rec.asset_number IS NULL) THEN
				                l_eam_wo_rec.asset_number := FND_API.G_MISS_CHAR;
				       END IF;

				       IF(l_rebuild_serial_number is NOT NULL and l_eam_wo_rec.rebuild_serial_number IS NULL) THEN
				                l_eam_wo_rec.rebuild_serial_number := FND_API.G_MISS_CHAR;
				       END IF;

				       IF(l_asset_group_id is NOT NULL and l_eam_wo_rec.asset_group_id IS NULL) THEN
				                l_eam_wo_rec.asset_group_id := FND_API.G_MISS_NUM;
				       END IF;

				       IF(l_rebuild_item_id is NOT NULL and l_eam_wo_rec.rebuild_item_id IS NULL) THEN
				                l_eam_wo_rec.rebuild_item_id:= FND_API.G_MISS_NUM;
				       END IF;

				       IF l_prev_activity_id is not null and l_eam_wo_rec.asset_activity_id is null THEN
						l_eam_wo_rec.asset_activity_id  := FND_API.G_MISS_NUM;
				       END IF;

				      IF l_prev_description is not null and l_eam_wo_rec.description is null THEN
						l_eam_wo_rec.description := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_activity_type is not null and l_eam_wo_rec.activity_type is null THEN
						l_eam_wo_rec.activity_type  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_activity_cause is not null and l_eam_wo_rec.activity_cause is null THEN
						l_eam_wo_rec.activity_cause  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_activity_source is not null and l_eam_wo_rec.activity_source is null THEN
						l_eam_wo_rec.activity_source  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_shutdown_type is not null and l_eam_wo_rec.shutdown_type is null THEN
						l_eam_wo_rec.shutdown_type  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_priority is not null and l_eam_wo_rec.priority is null THEN
						l_eam_wo_rec.priority  := FND_API.G_MISS_NUM;
				      END IF;

				      IF l_prev_work_order_type is not null and l_eam_wo_rec.work_order_type is null THEN
						l_eam_wo_rec.work_order_type  := FND_API.G_MISS_CHAR;
				      END IF;

				       IF l_prev_attribute_category is not null and l_eam_wo_rec.attribute_category is null THEN
						l_eam_wo_rec.attribute_category  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute1 is not null and l_eam_wo_rec.attribute1 is null THEN
						l_eam_wo_rec.attribute1  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute2 is not null and l_eam_wo_rec.attribute2 is null THEN
						l_eam_wo_rec.attribute2  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute3 is not null and l_eam_wo_rec.attribute3 is null THEN
						l_eam_wo_rec.attribute3  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute4 is not null and l_eam_wo_rec.attribute4 is null THEN
						l_eam_wo_rec.attribute4  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute5 is not null and l_eam_wo_rec.attribute5 is null THEN
						l_eam_wo_rec.attribute5  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute6 is not null and l_eam_wo_rec.attribute6 is null THEN
						l_eam_wo_rec.attribute6  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute7 is not null and l_eam_wo_rec.attribute7 is null THEN
						l_eam_wo_rec.attribute7  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute8 is not null and l_eam_wo_rec.attribute8 is null THEN
						l_eam_wo_rec.attribute8  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute9 is not null and l_eam_wo_rec.attribute9 is null THEN
						l_eam_wo_rec.attribute9  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute10 is not null and l_eam_wo_rec.attribute10 is null THEN
						l_eam_wo_rec.attribute10  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute11 is not null and l_eam_wo_rec.attribute11 is null THEN
						l_eam_wo_rec.attribute11  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute12 is not null and l_eam_wo_rec.attribute12 is null THEN
						l_eam_wo_rec.attribute12  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute13 is not null and l_eam_wo_rec.attribute13 is null THEN
						l_eam_wo_rec.attribute13  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute14 is not null and l_eam_wo_rec.attribute14 is null THEN
						l_eam_wo_rec.attribute14  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute15 is not null and l_eam_wo_rec.attribute15 is null THEN
						l_eam_wo_rec.attribute15  := FND_API.G_MISS_CHAR;
				      END IF;

				    /* Added for bug#6053425 Start */

 	          IF l_prev_project_id is not null AND l_eam_wo_rec.project_id is null THEN
 	               l_eam_wo_rec.project_id := FND_API.G_MISS_NUM;
 	          END IF;

 	          IF l_prev_task_id is not null AND l_eam_wo_rec.task_id is null THEN
 	                l_eam_wo_rec.task_id := FND_API.G_MISS_NUM;
 	          END IF;

 	          /* Added for bug#6053425 End */

				EXCEPTION
				     WHEN NO_DATA_FOUND THEN
				         NULL;
				END;


				--Validate descriptive flexfield for workorder
				l_validate :=  EAM_COMMON_UTILITIES_PVT.validate_desc_flex_field(
				                                p_app_short_name              =>        'WIP',
								p_desc_flex_name                =>      'WIP_DISCRETE_JOBS',
								p_attribute_category            =>      l_eam_wo_rec.attribute_category,
								p_attribute1                    =>      l_eam_wo_rec.attribute1,
								p_attribute2                    =>      l_eam_wo_rec.attribute2,
								p_attribute3                    =>      l_eam_wo_rec.attribute3,
								p_attribute4                    =>      l_eam_wo_rec.attribute4,
								p_attribute5                    =>      l_eam_wo_rec.attribute5,
								p_attribute6                    =>      l_eam_wo_rec.attribute6,
								p_attribute7                    =>      l_eam_wo_rec.attribute7,
								p_attribute8                    =>      l_eam_wo_rec.attribute8,
								p_attribute9                    =>      l_eam_wo_rec.attribute9,
								p_attribute10                   =>      l_eam_wo_rec.attribute10,
								p_attribute11                   =>      l_eam_wo_rec.attribute11,
								p_attribute12                   =>      l_eam_wo_rec.attribute12,
								p_attribute13                   =>      l_eam_wo_rec.attribute13,
								p_attribute14                   =>      l_eam_wo_rec.attribute14,
								p_attribute15                   =>      l_eam_wo_rec.attribute15,
								x_error_segments                =>      l_error_segments,
								x_error_message                 =>      l_error_message
								);

								/* Commented for bug 8567361
								IF l_validate <> TRUE THEN
											   fnd_message.set_name
												(  application  => 'EAM'
												 , name         => 'EAM_WO_FLEX_ERROR'
												);

												fnd_message.set_token(token => 'MESG',
															  value => l_error_message,
															  translate => FALSE);


												fnd_msg_pub.add;

												x_wip_entity_id := l_eam_wo_rec.wip_entity_id;
												x_return_status := 'E';
												x_msg_count    :=   1;
												RETURN;
								END IF; */


				l_eam_wo_tbl(l_eam_wo_tbl.FIRST) := l_eam_wo_rec;
	END IF;

	         --Changes for Bug 8969942

 	                l_eam_mat_req_tbl := p_eam_mat_req_tbl;
 	                 IF(l_eam_mat_req_tbl IS NOT  NULL AND l_eam_mat_req_tbl.COUNT>0) THEN
 	                                    l_eam_mat_req_rec := l_eam_mat_req_tbl(l_eam_mat_req_tbl.FIRST);

 	                                 BEGIN
 	                                        l_wip_entity_id := l_eam_mat_req_rec.wip_entity_id;
 	                                        l_organization_id := l_eam_mat_req_rec.ORGANIZATION_ID;
 	                                        l_Operation_Seq_Num := l_eam_mat_req_rec.OPERATION_SEQ_NUM;
 	                                        l_inventory_item_id := l_eam_mat_req_rec.INVENTORY_ITEM_ID;

 	                                           SELECT                attribute_category
 	                                                                 ,attribute1
 	                                                                 ,attribute2
 	                                                                 ,attribute3
 	                                                                 ,attribute4
 	                                                                 ,attribute5
 	                                                                 ,attribute6
 	                                                                 ,attribute7
 	                                                                 ,attribute8
 	                                                                 ,attribute9
 	                                                                 ,attribute10
 	                                                                 ,attribute11
 	                                                                 ,attribute12
 	                                                                 ,attribute13
 	                                                                 ,attribute14
 	                                                                 ,attribute15
 	                                        INTO                        l_prev_mat_attribute_category
 	                                                                 ,l_prev_mat_attribute1
 	                                                                 ,l_prev_mat_attribute2
 	                                                                 ,l_prev_mat_attribute3
 	                                                                 ,l_prev_mat_attribute4
 	                                                                 ,l_prev_mat_attribute5
 	                                                                 ,l_prev_mat_attribute6
 	                                                                 ,l_prev_mat_attribute7
 	                                                                 ,l_prev_mat_attribute8
 	                                                                 ,l_prev_mat_attribute9
 	                                                                 ,l_prev_mat_attribute10
 	                                                                 ,l_prev_mat_attribute11
 	                                                                 ,l_prev_mat_attribute12
 	                                                                 ,l_prev_mat_attribute13
 	                                                                 ,l_prev_mat_attribute14
 	                                                                 ,l_prev_mat_attribute15
 	                                   from WIP_REQUIREMENT_OPERATIONS
 	                                   where wip_entity_id =l_wip_Entity_Id
 	                                   and organization_id = l_organization_id
 	                                   and operation_seq_num= l_Operation_Seq_Num
 	                                   and INVENTORY_ITEM_ID = l_inventory_item_id;
 	                            EXCEPTION
 	                               WHEN NO_DATA_FOUND THEN
 	                                  null;
 	                               When Others then
 	                                  null;
 	                            END;

 	                                       IF l_prev_mat_attribute_category is not null and l_eam_mat_req_rec.attribute_category is null THEN
 	                                                 l_eam_mat_req_rec.attribute_category  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                                  IF l_prev_mat_attribute1 is not null and l_eam_mat_req_rec.attribute1 is null THEN
 	                                                 l_eam_mat_req_rec.attribute1  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute2 is not null and l_eam_mat_req_rec.attribute2 is null THEN
 	                                                 l_eam_mat_req_rec.attribute2  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute3 is not null and l_eam_mat_req_rec.attribute3 is null THEN
 	                                                 l_eam_mat_req_rec.attribute3  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute4 is not null and l_eam_mat_req_rec.attribute4 is null THEN
 	                                                 l_eam_mat_req_rec.attribute4  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute5 is not null and l_eam_mat_req_rec.attribute5 is null THEN
 	                                                 l_eam_mat_req_rec.attribute5  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute6 is not null and l_eam_mat_req_rec.attribute6 is null THEN
 	                                                 l_eam_mat_req_rec.attribute6  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute7 is not null and l_eam_mat_req_rec.attribute7 is null THEN
 	                                                 l_eam_mat_req_rec.attribute7  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute8 is not null and l_eam_mat_req_rec.attribute8 is null THEN
 	                                                 l_eam_mat_req_rec.attribute8  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute9 is not null and l_eam_mat_req_rec.attribute9 is null THEN
 	                                                 l_eam_mat_req_rec.attribute9  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute10 is not null and l_eam_mat_req_rec.attribute10 is null THEN
 	                                                 l_eam_mat_req_rec.attribute10  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute11 is not null and l_eam_mat_req_rec.attribute11 is null THEN
 	                                                 l_eam_mat_req_rec.attribute11  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute12 is not null and l_eam_mat_req_rec.attribute12 is null THEN
 	                                                 l_eam_mat_req_rec.attribute12  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute13 is not null and l_eam_mat_req_rec.attribute13 is null THEN
 	                                                 l_eam_mat_req_rec.attribute13  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute14 is not null and l_eam_mat_req_rec.attribute14 is null THEN
 	                                                 l_eam_mat_req_rec.attribute14  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute15 is not null and l_eam_mat_req_rec.attribute15 is null THEN
 	                                                 l_eam_mat_req_rec.attribute15  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                 --Validate descriptive flexfield for materials - "Component Information"
 	                                 l_validate :=  EAM_COMMON_UTILITIES_PVT.validate_desc_flex_field(
 	                                                                 p_app_short_name              =>        'BOM',
 	                                                                 p_desc_flex_name                =>      'BOM_INVENTORY_COMPONENTS',
 	                                                                 p_attribute_category            =>      l_eam_mat_req_rec.attribute_category,
 	                                                                 p_attribute1                    =>      l_eam_mat_req_rec.attribute1,
 	                                                                 p_attribute2                    =>      l_eam_mat_req_rec.attribute2,
 	                                                                 p_attribute3                    =>      l_eam_mat_req_rec.attribute3,
 	                                                                 p_attribute4                    =>      l_eam_mat_req_rec.attribute4,
 	                                                                 p_attribute5                    =>      l_eam_mat_req_rec.attribute5,
 	                                                                 p_attribute6                    =>      l_eam_mat_req_rec.attribute6,
 	                                                                 p_attribute7                    =>      l_eam_mat_req_rec.attribute7,
 	                                                                 p_attribute8                    =>      l_eam_mat_req_rec.attribute8,
 	                                                                 p_attribute9                    =>      l_eam_mat_req_rec.attribute9,
 	                                                                 p_attribute10                   =>      l_eam_mat_req_rec.attribute10,
 	                                                                 p_attribute11                   =>      l_eam_mat_req_rec.attribute11,
 	                                                                 p_attribute12                   =>      l_eam_mat_req_rec.attribute12,
 	                                                                 p_attribute13                   =>      l_eam_mat_req_rec.attribute13,
 	                                                                 p_attribute14                   =>      l_eam_mat_req_rec.attribute14,
 	                                                                 p_attribute15                   =>      l_eam_mat_req_rec.attribute15,
 	                                                                 x_error_segments                =>      l_error_segments,
 	                                                                 x_error_message                 =>      l_error_message
 	                                                                 );



 	                                 l_eam_mat_req_tbl(l_eam_mat_req_tbl.FIRST) := l_eam_mat_req_rec;
 	         END IF;

 	                                                  l_eam_direct_items_tbl := p_eam_direct_items_tbl;
 	                 IF(l_eam_direct_items_tbl IS NOT  NULL AND l_eam_direct_items_tbl.COUNT>0) THEN
 	                                    l_eam_direct_items_rec := l_eam_direct_items_tbl(l_eam_direct_items_tbl.FIRST);

 	                                 BEGIN
 	                                        l_wip_entity_id := l_eam_direct_items_rec.wip_entity_id;
 	                                        l_organization_id := l_eam_direct_items_rec.ORGANIZATION_ID;
 	                                        l_Operation_Seq_Num := l_eam_direct_items_rec.OPERATION_SEQ_NUM;
 	                                        l_dir_item_seq_id := l_eam_direct_items_rec.Direct_Item_Sequence_Id;

 	                                           SELECT                attribute_category
 	                                                                 ,attribute1
 	                                                                 ,attribute2
 	                                                                 ,attribute3
 	                                                                 ,attribute4
 	                                                                 ,attribute5
 	                                                                 ,attribute6
 	                                                                 ,attribute7
 	                                                                 ,attribute8
 	                                                                 ,attribute9
 	                                                                 ,attribute10
 	                                                                 ,attribute11
 	                                                                 ,attribute12
 	                                                                 ,attribute13
 	                                                                 ,attribute14
 	                                                                 ,attribute15
 	                                        INTO                        l_prev_dir_attribute_category
 	                                                                 ,l_prev_dir_attribute1
 	                                                                 ,l_prev_dir_attribute2
 	                                                                 ,l_prev_dir_attribute3
 	                                                                 ,l_prev_dir_attribute4
 	                                                                 ,l_prev_dir_attribute5
 	                                                                 ,l_prev_dir_attribute6
 	                                                                 ,l_prev_dir_attribute7
 	                                                                 ,l_prev_dir_attribute8
 	                                                                 ,l_prev_dir_attribute9
 	                                                                 ,l_prev_dir_attribute10
 	                                                                 ,l_prev_dir_attribute11
 	                                                                 ,l_prev_dir_attribute12
 	                                                                 ,l_prev_dir_attribute13
 	                                                                 ,l_prev_dir_attribute14
 	                                                                 ,l_prev_dir_attribute15
 	                                   from wip_eam_direct_items
 	                                   where wip_entity_id =l_wip_Entity_Id
 	                                   and organization_id = l_organization_id
 	                                   and operation_seq_num= l_Operation_Seq_Num ;

 	                            EXCEPTION
 	                               WHEN NO_DATA_FOUND THEN
 	                                  null;
 	                               When Others then
 	                                  null;
 	                            END;

 	                                       IF l_prev_dir_attribute_category is not null and l_eam_direct_items_rec.attribute_category is null THEN
 	                                                 l_eam_direct_items_rec.attribute_category  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute1 is not null and l_eam_direct_items_rec.attribute1 is null THEN
 	                                                 l_eam_direct_items_rec.attribute1  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute2 is not null and l_eam_direct_items_rec.attribute2 is null THEN
 	                                                 l_eam_direct_items_rec.attribute2  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute3 is not null and l_eam_direct_items_rec.attribute3 is null THEN
 	                                                 l_eam_direct_items_rec.attribute3  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute4 is not null and l_eam_direct_items_rec.attribute4 is null THEN
 	                                                 l_eam_direct_items_rec.attribute4  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute5 is not null and l_eam_direct_items_rec.attribute5 is null THEN
 	                                                 l_eam_direct_items_rec.attribute5  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute6 is not null and l_eam_direct_items_rec.attribute6 is null THEN
 	                                                 l_eam_direct_items_rec.attribute6  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute7 is not null and l_eam_direct_items_rec.attribute7 is null THEN
 	                                                 l_eam_direct_items_rec.attribute7  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute8 is not null and l_eam_direct_items_rec.attribute8 is null THEN
 	                                                 l_eam_direct_items_rec.attribute8  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute9 is not null and l_eam_direct_items_rec.attribute9 is null THEN
 	                                                 l_eam_direct_items_rec.attribute9  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute10 is not null and l_eam_direct_items_rec.attribute10 is null THEN
 	                                                 l_eam_direct_items_rec.attribute10  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute11 is not null and l_eam_direct_items_rec.attribute11 is null THEN
 	                                                 l_eam_direct_items_rec.attribute11  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute12 is not null and l_eam_direct_items_rec.attribute12 is null THEN
 	                                                 l_eam_direct_items_rec.attribute12  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute13 is not null and l_eam_direct_items_rec.attribute13 is null THEN
 	                                                 l_eam_direct_items_rec.attribute13  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute14 is not null and l_eam_direct_items_rec.attribute14 is null THEN
 	                                                 l_eam_direct_items_rec.attribute14  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute15 is not null and l_eam_direct_items_rec.attribute15 is null THEN
 	                                                 l_eam_direct_items_rec.attribute15  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                 --Validate descriptive flexfield for workorder
 	                                 l_validate :=  EAM_COMMON_UTILITIES_PVT.validate_desc_flex_field(
 	                                                                 p_app_short_name              =>        'EAM',
 	                                                                 p_desc_flex_name                =>      'EAM_DESC_DIR_ITEM',
 	                                                                 p_attribute_category            =>      l_eam_direct_items_rec.attribute_category,
 	                                                                 p_attribute1                    =>      l_eam_direct_items_rec.attribute1,
 	                                                                 p_attribute2                    =>      l_eam_direct_items_rec.attribute2,
 	                                                                 p_attribute3                    =>      l_eam_direct_items_rec.attribute3,
 	                                                                 p_attribute4                    =>      l_eam_direct_items_rec.attribute4,
 	                                                                 p_attribute5                    =>      l_eam_direct_items_rec.attribute5,
 	                                                                 p_attribute6                    =>      l_eam_direct_items_rec.attribute6,
 	                                                                 p_attribute7                    =>      l_eam_direct_items_rec.attribute7,
 	                                                                 p_attribute8                    =>      l_eam_direct_items_rec.attribute8,
 	                                                                 p_attribute9                    =>      l_eam_direct_items_rec.attribute9,
 	                                                                 p_attribute10                   =>      l_eam_direct_items_rec.attribute10,
 	                                                                 p_attribute11                   =>      l_eam_direct_items_rec.attribute11,
 	                                                                 p_attribute12                   =>      l_eam_direct_items_rec.attribute12,
 	                                                                 p_attribute13                   =>      l_eam_direct_items_rec.attribute13,
 	                                                                 p_attribute14                   =>      l_eam_direct_items_rec.attribute14,
 	                                                                 p_attribute15                   =>      l_eam_direct_items_rec.attribute15,
 	                                                                 x_error_segments                =>      l_error_segments,
 	                                                                 x_error_message                 =>      l_error_message
 	                                                                 );

 	                                 l_eam_direct_items_tbl(l_eam_direct_items_tbl.FIRST) := l_eam_direct_items_rec;
 	         END IF;

 	 ----end of changes for 8969942

       --Set the auto_charge type to Manual/POReceipt for newly created workorders
	l_eam_res_tbl := p_eam_res_tbl;
	IF(l_eam_res_tbl IS NOT NULL AND l_eam_res_tbl.COUNT>0) THEN
			FOR i IN  l_eam_res_tbl.FIRST ..  l_eam_res_tbl.LAST LOOP
                                    IF(l_eam_res_tbl(i).transaction_type=EAM_PROCESS_WO_PUB.G_OPR_CREATE AND (l_eam_res_tbl(i).autocharge_type IS NULL)) THEN
							OPEN resources(l_eam_res_tbl(i).resource_id,l_eam_res_tbl(i).organization_id);
							FETCH resources INTO l_resources;
							   IF(resources%FOUND) THEN
								IF(l_resources.autocharge_type=1 OR l_resources.autocharge_type=2) THEN
									l_eam_res_tbl(i).autocharge_type := 2;
								ELSE
									l_eam_res_tbl(i).autocharge_type := 3;
								END IF;
							   END IF;
							CLOSE resources;
				    END IF;
			 END LOOP;
	 END IF;

      --p_failure_code_required will be passed only when failure code information is entered or modified.
      --Make sure that work order record is passed whenever failure entry is passed, as we have some logic on work order related info
	 IF(p_failure_code_required IS NOT NULL) THEN

		/* Failure Analysis Project Start */
		       l_eam_failure_entry_record.failure_id   := p_failure_id;
		       l_eam_failure_entry_record.failure_date := p_failure_date;

		       l_eam_failure_codes_tbl(1).failure_id := p_failure_id;
		       l_eam_failure_codes_tbl(1).failure_entry_id := p_failure_entry_id;
		       l_eam_failure_codes_tbl(1).failure_code     := p_failure_code;
		       l_eam_failure_codes_tbl(1).cause_code       := p_cause_code;
		       l_eam_failure_codes_tbl(1).resolution_code  := p_resolution_code;
		       l_eam_failure_codes_tbl(1).comments         := p_failure_comments;
		     /* Failure Analysis Project End */

		      l_fail_dept_id  := l_eam_wo_rec.owning_department;

                    --ideally work order info should be passed when failure info is passed. But check that workorder is passed
		    IF(l_eam_wo_tbl IS NOT  NULL AND l_eam_wo_tbl.COUNT>0) THEN

		--only if asset number/rebuild serial number exists for work order
			IF(l_maintenance_object_type =3) THEN
				 BEGIN

			            --if workorder dept. is null,de fault it from asset's owning dept
				    IF(l_fail_dept_id IS NULL) THEN
					 SELECT OWNING_DEPARTMENT_ID
					   INTO l_fail_dept_id
					   FROM eam_org_maint_defaults
					  WHERE object_id =l_maintenance_object_id
					  AND object_type = 50
					  AND organization_id =l_eam_wo_comp_rec.organization_id;
				     END IF;

				     SELECT area_id
				      INTO l_eam_location_id
				      FROM eam_org_maint_defaults
					WHERE object_id = l_maintenance_object_id
                                     AND object_type = 50
                                     AND organization_id = l_eam_wo_comp_rec.organization_id;

				    EXCEPTION
				      WHEN NO_DATA_FOUND THEN
				      NULL;
				    END;
				    END IF;  --end of check for mainteannce_object_type =3

						        l_eam_wo_rec.failure_code_required := p_failure_code_required;

			IF(l_wo_exists =  TRUE)  THEN

				l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;
				l_eam_failure_entry_record.source_type := 1;
				l_eam_failure_entry_record.source_id := l_eam_wo_rec.wip_entity_id;
				l_eam_failure_entry_record.object_type := l_eam_wo_rec.maintenance_object_type;
				l_eam_failure_entry_record.object_id := l_eam_wo_rec.maintenance_object_id;
				l_eam_failure_entry_record.maint_organization_id := l_eam_wo_rec.organization_id;
				l_eam_failure_entry_record.current_organization_id := l_eam_wo_rec.organization_id;
				l_eam_failure_entry_record.department_id := l_fail_dept_id;
				l_eam_failure_entry_record.area_id := l_eam_location_id;


				l_eam_failure_codes_tbl(1).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;
				if (l_eam_failure_entry_record.failure_date is null) then
				    l_eam_failure_entry_record.failure_date := FND_API.G_MISS_DATE;
				end if;
				if (l_eam_failure_codes_tbl(1).failure_code is null) then
				     l_eam_failure_codes_tbl(1).failure_code := FND_API.G_MISS_CHAR;
				end if;
				if (l_eam_failure_codes_tbl(1).cause_code is null) then
				    l_eam_failure_codes_tbl(1).cause_code := FND_API.G_MISS_CHAR;
				end if;
				if (l_eam_failure_codes_tbl(1).resolution_code is null) then
				    l_eam_failure_codes_tbl(1).resolution_code := FND_API.G_MISS_CHAR;
				end if;
				if (l_eam_failure_codes_tbl(1).comments is null) then
				    l_eam_failure_codes_tbl(1).comments := FND_API.G_MISS_CHAR;
				end if;
				  if(l_eam_failure_entry_record.failure_id is not null ) then
				  l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;
				 else
				   if(l_eam_failure_entry_record.failure_date = FND_API.G_MISS_DATE) then
				      l_eam_failure_entry_record.transaction_type :=null;
				      l_eam_failure_entry_record.failure_date :=null;
				   else
				      l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE ;
				   end if;
				 end if;

				 if(l_eam_failure_codes_tbl(1).failure_entry_id is not null) then
					  l_eam_failure_codes_tbl(1).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;
					  l_eam_wo_rec.eam_failure_codes_tbl(1) := l_eam_failure_codes_tbl(1);

				 else
						   if( not( (l_eam_failure_codes_tbl(1).failure_code = FND_API.G_MISS_CHAR)
							 and (l_eam_failure_codes_tbl(1).cause_code = FND_API.G_MISS_CHAR)
							 and (l_eam_failure_codes_tbl(1).resolution_code = FND_API.G_MISS_CHAR)
							 and (l_eam_failure_codes_tbl(1).comments = FND_API.G_MISS_CHAR)
							)
						     ) then
									     l_eam_failure_codes_tbl(1).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE;
									     if(l_eam_failure_codes_tbl(1).failure_code = FND_API.G_MISS_CHAR) then
										l_eam_failure_codes_tbl(1).failure_code := null;
									     end if;
									     if(l_eam_failure_codes_tbl(1).cause_code = FND_API.G_MISS_CHAR) then
										l_eam_failure_codes_tbl(1).cause_code := null;
									     end if;
									     if(l_eam_failure_codes_tbl(1).resolution_code = FND_API.G_MISS_CHAR) then
										l_eam_failure_codes_tbl(1).resolution_code := null;
									     end if;
									     if(l_eam_failure_codes_tbl(1).comments = FND_API.G_MISS_CHAR) then
										l_eam_failure_codes_tbl(1).comments := null;
									     end if;
									     l_eam_wo_rec.eam_failure_codes_tbl(1) := l_eam_failure_codes_tbl(1);

						  else
									     l_eam_failure_codes_tbl.delete;
									     l_eam_wo_rec.eam_failure_codes_tbl := l_eam_failure_codes_tbl;

						  end if;
				 end if;
				l_eam_wo_rec.eam_failure_entry_record := l_eam_failure_entry_record;

ELSE    -- work order is getting created

				l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE;
				l_eam_failure_entry_record.source_type := 1;
				l_eam_failure_entry_record.source_id := l_eam_wo_rec.wip_entity_id;
				l_eam_failure_entry_record.object_type := l_eam_wo_rec.maintenance_object_type;
				l_eam_failure_entry_record.object_id := l_eam_wo_rec.maintenance_object_id;
				l_eam_failure_entry_record.maint_organization_id := l_eam_wo_rec.organization_id;
				l_eam_failure_entry_record.current_organization_id := l_eam_wo_rec.organization_id;
				l_eam_failure_entry_record.department_id := l_fail_dept_id;
				l_eam_failure_entry_record.area_id := l_eam_location_id;

				if(l_eam_failure_entry_record.failure_date is null) then
				  l_eam_failure_entry_record.transaction_type :=null;
				end if;
				l_eam_wo_rec.eam_failure_entry_record := l_eam_failure_entry_record;

				l_eam_failure_codes_tbl(1).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE;
				if( not( l_eam_failure_codes_tbl(1).failure_code is null
					 and l_eam_failure_codes_tbl(1).cause_code is null
					 and l_eam_failure_codes_tbl(1).resolution_code is null
					 and l_eam_failure_codes_tbl(1).comments is null
					)
				    ) then
							l_eam_wo_rec.eam_failure_codes_tbl(1) := l_eam_failure_codes_tbl(1);
				else
							l_eam_failure_codes_tbl.delete;
							l_eam_wo_rec.eam_failure_codes_tbl := l_eam_failure_codes_tbl;
				end if;

							END IF;


                                              l_eam_wo_tbl(l_eam_wo_tbl.FIRST) := l_eam_wo_rec;

		     END IF;   --end of check for work order record passed

	 END IF;   --end of check for failure data passed


       x_wip_entity_id := NULL;

       IF(p_eam_wo_relations_tbl IS NOT NULL AND p_eam_wo_relations_tbl.COUNT > 0) THEN

		EAM_PROCESS_WO_PUB.PROCESS_MASTER_CHILD_WO(
		p_bo_identifier			=>'EAM'
		, p_api_version_number    => 1.0
		, p_init_msg_list			=>  TRUE
		, p_eam_wo_relations_tbl    => p_eam_wo_relations_tbl
		, p_eam_wo_tbl			    => l_eam_wo_tbl
		, p_eam_op_tbl			   => p_eam_op_tbl
		, p_eam_op_network_tbl     => l_eam_op_network_tbl
		, p_eam_res_tbl                   => l_eam_res_tbl
		, p_eam_res_inst_tbl          => p_eam_res_inst_tbl
		,p_eam_res_usage_tbl     => p_eam_res_usage_tbl
		, p_eam_sub_res_tbl         => l_eam_sub_res_tbl
		, p_eam_mat_req_tbl          => l_eam_mat_req_tbl
		, p_eam_direct_items_tbl    => l_eam_direct_items_tbl
		, p_eam_wo_comp_tbl         => p_eam_wo_comp_tbl
		 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
		, p_eam_meter_reading_tbl   => p_eam_meter_reading_tbl
		, p_eam_counter_prop_tbl     =>    p_eam_counter_prop_tbl
		, p_eam_wo_comp_rebuild_tbl    => p_eam_wo_comp_rebuild_tbl
		, p_eam_wo_comp_mr_read_tbl   => p_eam_wo_comp_mr_read_tbl
		, p_eam_op_comp_tbl            => l_eam_op_comp_tbl
		, p_eam_request_tbl               => p_eam_request_tbl
		, x_eam_wo_tbl                        => l_eam_wo_tbl_out
		, x_eam_wo_relations_tbl      => l_eam_wo_relations_tbl_out
		, x_eam_op_tbl                         => l_eam_op_tbl_out
		, x_eam_op_network_tbl        => l_eam_op_network_tbl_out
		, x_eam_res_tbl                      => l_eam_res_tbl_out
		, x_eam_res_usage_tbl        =>    l_eam_res_usage_tbl_out
		, x_eam_res_inst_tbl             => l_eam_res_inst_tbl_out
		, x_eam_sub_res_tbl            => l_eam_sub_res_tbl_out
		, x_eam_mat_req_tbl           => l_eam_mat_req_tbl_out
		, x_eam_direct_items_tbl     =>l_eam_direct_items_tbl_out
		, x_eam_wo_comp_tbl         => l_eam_wo_comp_tbl_out
		, x_eam_wo_quality_tbl      => l_eam_wo_quality_tbl_out
		, x_eam_meter_reading_tbl   => l_eam_meter_reading_tbl_out
		, x_eam_counter_prop_tbl        =>    l_eam_counter_prop_tbl_out
		, x_eam_wo_comp_rebuild_tbl    =>  l_eam_wo_comp_rebuild_tbl_out
		, x_eam_wo_comp_mr_read_tbl    => l_eam_wo_comp_mr_read_tbl_out
		, x_eam_op_comp_tbl		 => l_eam_op_comp_tbl_out
		, x_eam_request_tbl			 => l_eam_request_tbl_out
		, x_return_status				 => x_return_status
		, x_msg_count				 => x_msg_count
		, p_commit				=> 'N'
		, p_debug				=> NVL(fnd_profile.value('EAM_DEBUG'), 'N')
		, p_output_dir				 => l_output_dir
		, p_debug_filename			  => 'createupdatewo.log'
		, p_debug_file_mode		 => 'W'
		);

	ELSE
		IF ( l_eam_wo_tbl.COUNT > 0 ) THEN
			l_eam_wo_rec := l_eam_wo_tbl(l_eam_wo_tbl.FIRST);
		END IF;

		IF ( l_eam_wo_comp_tbl.COUNT > 0 ) THEN
			l_eam_wo_comp_rec := l_eam_wo_comp_tbl(l_eam_wo_comp_tbl.FIRST);
		END IF;

		EAM_PROCESS_WO_PUB.PROCESS_WO(
		  p_bo_identifier			=>'EAM'
		, p_api_version_number    => 1.0
		, p_init_msg_list			=>  TRUE
		, p_eam_wo_rec			    => l_eam_wo_rec
		, p_eam_op_tbl			   => p_eam_op_tbl
		, p_eam_op_network_tbl     => l_eam_op_network_tbl
		, p_eam_res_tbl                   => l_eam_res_tbl
		, p_eam_res_inst_tbl          => p_eam_res_inst_tbl
		, p_eam_res_usage_tbl     => p_eam_res_usage_tbl
		, p_eam_sub_res_tbl         => l_eam_sub_res_tbl
		, p_eam_mat_req_tbl          => l_eam_mat_req_tbl
		, p_eam_direct_items_tbl    => l_eam_direct_items_tbl
		, p_eam_wo_comp_rec          => l_eam_wo_comp_rec
		, p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
		, p_eam_meter_reading_tbl   => p_eam_meter_reading_tbl
		, p_eam_counter_prop_tbl     =>    p_eam_counter_prop_tbl
		, p_eam_wo_comp_rebuild_tbl    => p_eam_wo_comp_rebuild_tbl
		, p_eam_wo_comp_mr_read_tbl   => p_eam_wo_comp_mr_read_tbl
		, p_eam_op_comp_tbl            => l_eam_op_comp_tbl
		, p_eam_request_tbl            => p_eam_request_tbl
		, x_eam_wo_rec	               => l_eam_wo_rec_out
		, x_eam_op_tbl                 => l_eam_op_tbl_out
		, x_eam_op_network_tbl         => l_eam_op_network_tbl_out
		, x_eam_res_tbl                => l_eam_res_tbl_out
		, x_eam_res_usage_tbl          => l_eam_res_usage_tbl_out
		, x_eam_res_inst_tbl           => l_eam_res_inst_tbl_out
		, x_eam_sub_res_tbl            => l_eam_sub_res_tbl_out
		, x_eam_mat_req_tbl           => l_eam_mat_req_tbl_out
		, x_eam_direct_items_tbl     => l_eam_direct_items_tbl_out
		, x_eam_wo_comp_rec         => l_eam_wo_comp_rec_out
		, x_eam_wo_quality_tbl      => l_eam_wo_quality_tbl_out
		, x_eam_meter_reading_tbl   => l_eam_meter_reading_tbl_out
		, x_eam_counter_prop_tbl        =>  l_eam_counter_prop_tbl_out
		, x_eam_wo_comp_rebuild_tbl    =>  l_eam_wo_comp_rebuild_tbl_out
		, x_eam_wo_comp_mr_read_tbl    => l_eam_wo_comp_mr_read_tbl_out
		, x_eam_op_comp_tbl	 => l_eam_op_comp_tbl_out
		, x_eam_request_tbl	 => l_eam_request_tbl_out
		, x_return_status	 => x_return_status
		, x_msg_count		 => x_msg_count
		, p_commit			=> 'N'
		, p_debug			=> NVL(fnd_profile.value('EAM_DEBUG'), 'N')
		, p_output_dir			=> l_output_dir
		, p_debug_filename		=> 'createupdatewo.log'
		, p_debug_file_mode		=> 'W'
		);

	END IF;

  END IF; /*MSP IF END*/

	IF(x_return_status='S') THEN
		IF p_commit = FND_API.G_TRUE THEN
			COMMIT WORK;
		end if;
		IF(l_eam_wo_tbl_out IS NOT NULL AND l_eam_wo_tbl_out.COUNT>0) THEN
			x_wip_entity_id := l_eam_wo_tbl_out(l_eam_wo_tbl_out.FIRST).wip_entity_id;
                ELSIF(l_eam_wo_rec_out.wip_entity_id IS NOT NULL) THEN
                        x_wip_entity_id := l_eam_wo_rec_out.wip_entity_id;
		END IF;
	END IF;

	IF(x_return_status <> 'S') THEN
	     ROLLBACK TO create_update_wo;
	END IF;

END CREATE_UPDATE_WO;


/*********************************************************
Wrapper procedure on top of WO API.This is used to create/update workorder with permits
************************************************/
PROCEDURE CREATE_UPDATE_WO
(
      p_commit                      IN    VARCHAR2      := FND_API.G_FALSE,
      p_eam_wo_tbl		IN			EAM_PROCESS_WO_PUB.eam_wo_tbl_type,
      p_eam_wo_relations_tbl     IN            EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type,
      p_eam_op_tbl               IN                    EAM_PROCESS_WO_PUB.eam_op_tbl_type,
      p_eam_res_tbl              IN                   EAM_PROCESS_WO_PUB.eam_res_tbl_type,
      p_eam_res_inst_tbl     IN			EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type,
      p_eam_res_usage_tbl      IN              EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type,
      p_eam_mat_req_tbl         IN                EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type,
      p_eam_direct_items_tbl    IN             EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type,
      p_eam_request_tbl           IN              EAM_PROCESS_WO_PUB.eam_request_tbl_type,
      p_eam_wo_comp_tbl		 IN		EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type,
      p_eam_meter_reading_tbl   IN		EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type,
      p_eam_counter_prop_tbl    IN	 EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type,
      p_eam_wo_comp_rebuild_tbl	 IN	EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type,
      p_eam_wo_comp_mr_read_tbl	 IN	EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type,
      p_eam_permit_tbl           IN  EAM_PROCESS_PERMIT_PUB.eam_wp_tbl_type, -- new param for safety permit
      p_eam_permit_wo_assoc_tbl IN EAM_PROCESS_PERMIT_PUB.eam_wp_association_tbl_type, -- new param for safety permit
      p_prev_activity_id              IN                NUMBER,
      p_failure_id          IN NUMBER			:= null,
      p_failure_date        IN DATE				:= null,
      p_failure_entry_id    IN NUMBER		 := null,
      p_failure_code        IN VARCHAR2		 := null,
      p_cause_code          IN VARCHAR2		 := null,
      p_resolution_code     IN VARCHAR2		 := null,
      p_failure_comments    IN VARCHAR2		:= null,
      p_failure_code_required     IN VARCHAR2 DEFAULT NULL,
      x_wip_entity_id              OUT NOCOPY       NUMBER,
      x_return_status		OUT NOCOPY	VARCHAR2,
      x_msg_count			OUT NOCOPY	NUMBER
)
IS
      l_eam_wo_tbl					EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
      l_eam_wo_rec					EAM_PROCESS_WO_PUB.eam_wo_rec_type;
      l_import_eam_wo_rec                               EAM_PROCESS_WO_PUB.eam_wo_rec_type; --MSP Project
      l_eam_op_network_tbl				EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
      l_eam_res_tbl					EAM_PROCESS_WO_PUB.eam_res_tbl_type;
      l_eam_sub_res_tbl					EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
      l_eam_wo_quality_tbl				EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
      l_eam_op_comp_tbl					EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
      l_eam_wo_comp_tbl					EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
      l_eam_wo_comp_rec					EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
      l_eam_mat_req_tbl                                 EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
      l_eam_mat_req_rec                                 EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;
      l_eam_direct_items_tbl                            EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
      l_eam_direct_items_rec                            EAM_PROCESS_WO_PUB.eam_direct_items_rec_type;

      l_eam_wo_relations_tbl_out			EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
      l_eam_wo_rec_out					EAM_PROCESS_WO_PUB.eam_wo_rec_type;
      l_eam_wo_tbl_out					EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
      l_eam_op_tbl_out					EAM_PROCESS_WO_PUB.eam_op_tbl_type;
      l_eam_op_network_tbl_out				EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
      l_eam_res_tbl_out					EAM_PROCESS_WO_PUB.eam_res_tbl_type;
      l_eam_res_usage_tbl_out				EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
      l_eam_res_inst_tbl_out				EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
      l_eam_sub_res_tbl_out				EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
      l_eam_mat_req_tbl_out				EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
      l_eam_direct_items_tbl_out			EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
      l_eam_wo_comp_tbl_out				EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
      l_eam_wo_quality_tbl_out				EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
      l_eam_meter_reading_tbl_out			EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
      l_eam_counter_prop_tbl_out			EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
      l_eam_wo_comp_rebuild_tbl_out			EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
      l_eam_wo_comp_mr_read_tbl_out			EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
      l_eam_op_comp_tbl_out				EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
      l_eam_request_tbl_out				EAM_PROCESS_WO_PUB.eam_request_tbl_type;
      l_eam_wo_comp_rec_out				EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;


      l_output_dir                      VARCHAR2(512);

      CURSOR resources
      (l_resource_id NUMBER,l_organization_id NUMBER)
      IS
	      SELECT autocharge_type
	      FROM  BOM_RESOURCES
	      WHERE resource_id = l_resource_id
	      AND organization_id = l_organization_id;

      l_resources resources%ROWTYPE;
      l_wip_entity_id       NUMBER;
      l_asset_group_id     NUMBER;
      l_asset_number       VARCHAR2(30);
      l_rebuild_item_id     NUMBER;
      l_rebuild_serial_number    VARCHAR2(30);

      /* Added for bug#4555609 */
    l_prev_activity_id         NUMBER;
    l_prev_description VARCHAR2(240);
    l_prev_priority NUMBER;
    l_prev_work_order_type  VARCHAR2(30);
    l_prev_shutdown_type VARCHAR2(30);
    l_prev_activity_type VARCHAR2(30);
    l_prev_activity_cause VARCHAR2(30);
    l_prev_activity_source VARCHAR2(30);
    l_prev_attribute_category VARCHAR2(30);
    l_prev_attribute1 VARCHAR2(150);
    l_prev_attribute2 VARCHAR2(150);
    l_prev_attribute3 VARCHAR2(150);
    l_prev_attribute4 VARCHAR2(150);
    l_prev_attribute5 VARCHAR2(150);
    l_prev_attribute6 VARCHAR2(150);
    l_prev_attribute7 VARCHAR2(150);
    l_prev_attribute8 VARCHAR2(150);
    l_prev_attribute9 VARCHAR2(150);
    l_prev_attribute10 VARCHAR2(150);
    l_prev_attribute11 VARCHAR2(150);
    l_prev_attribute12 VARCHAR2(150);
    l_prev_attribute13 VARCHAR2(150);
    l_prev_attribute14 VARCHAR2(150);
    l_prev_attribute15 VARCHAR2(150);
    l_maintenance_object_type NUMBER;
    l_maintenance_object_id NUMBER;
	  /* Added for bug#6053425 Start */
	 	l_prev_project_id  NUMBER;
	 	l_prev_task_id     NUMBER;
	 	/* Added for bug#6053425 End */

     l_eam_failure_entry_record    EAM_Process_Failure_Entry_PUB.eam_failure_entry_record_typ;
     l_eam_failure_codes_tbl       EAM_Process_Failure_Entry_PUB.eam_failure_codes_tbl_typ;
     l_fail_dept_id       NUMBER;
     l_eam_location_id    NUMBER;
     l_eam_failure_code_required varchar2(30);
     l_wo_exists        BOOLEAN;
     l_org_id               NUMBER;
     l_validate             BOOLEAN;
     l_error_segments                        number;
     l_error_message                         varchar2(2000);

--    Added for 8969942

	l_organization_id     NUMBER;
 	l_Operation_Seq_Num    NUMBER;
 	l_inventory_item_id     NUMBER;
 	l_dir_item_seq_id NUMBER;

 	l_prev_mat_attribute_category VARCHAR2(30);
 	l_prev_mat_attribute1 VARCHAR2(150);
 	l_prev_mat_attribute2 VARCHAR2(150);
 	l_prev_mat_attribute3 VARCHAR2(150);
 	l_prev_mat_attribute4 VARCHAR2(150);
 	l_prev_mat_attribute5 VARCHAR2(150);
 	l_prev_mat_attribute6 VARCHAR2(150);
 	l_prev_mat_attribute7 VARCHAR2(150);
 	l_prev_mat_attribute8 VARCHAR2(150);
 	l_prev_mat_attribute9 VARCHAR2(150);
 	l_prev_mat_attribute10 VARCHAR2(150);
 	l_prev_mat_attribute11 VARCHAR2(150);
 	l_prev_mat_attribute12 VARCHAR2(150);
 	l_prev_mat_attribute13 VARCHAR2(150);
 	l_prev_mat_attribute14 VARCHAR2(150);
 	l_prev_mat_attribute15 VARCHAR2(150);

 	l_prev_dir_attribute_category VARCHAR2(30);
 	l_prev_dir_attribute1 VARCHAR2(150);
 	l_prev_dir_attribute2 VARCHAR2(150);
 	l_prev_dir_attribute3 VARCHAR2(150);
 	l_prev_dir_attribute4 VARCHAR2(150);
 	l_prev_dir_attribute5 VARCHAR2(150);
 	l_prev_dir_attribute6 VARCHAR2(150);
 	l_prev_dir_attribute7 VARCHAR2(150);
 	l_prev_dir_attribute8 VARCHAR2(150);
 	l_prev_dir_attribute9 VARCHAR2(150);
 	l_prev_dir_attribute10 VARCHAR2(150);
 	l_prev_dir_attribute11 VARCHAR2(150);
 	l_prev_dir_attribute12 VARCHAR2(150);
 	l_prev_dir_attribute13 VARCHAR2(150);
 	l_prev_dir_attribute14 VARCHAR2(150);
 	l_prev_dir_attribute15 VARCHAR2(150);

BEGIN

      /* get output directory path from database */
   EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

	SAVEPOINT     create_update_wo;
        /*MSP Project addition*/
        IF(p_eam_wo_tbl IS NOT NULL) THEN
         IF(p_eam_wo_tbl.first is not NULL) THEN
           l_import_eam_wo_rec := p_eam_wo_tbl(p_eam_wo_tbl.first);
         END IF;
        END IF;

      IF(l_import_eam_wo_rec.ATTRIBUTE15='import') THEN
          eam_import_workorders.import_workorders(p_commit,
            p_eam_wo_tbl,
            p_eam_wo_relations_tbl,
            p_eam_op_tbl,
            p_eam_res_tbl,
            p_eam_res_inst_tbl,
            p_eam_res_usage_tbl,
            p_eam_mat_req_tbl,
            p_eam_direct_items_tbl,
            p_eam_request_tbl,
            p_eam_wo_comp_tbl,
            p_eam_meter_reading_tbl,
            p_eam_counter_prop_tbl,
            p_eam_wo_comp_rebuild_tbl,
            p_eam_wo_comp_mr_read_tbl,
            x_wip_entity_id,
            x_return_status,
            x_msg_count);
      ELSE          /*MSP code end*/

	l_eam_wo_comp_tbl := p_eam_wo_comp_tbl;

         IF(l_eam_wo_comp_tbl IS NOT NULL AND l_eam_wo_comp_tbl.COUNT>0) THEN

	  l_eam_wo_comp_rec := l_eam_wo_comp_tbl(l_eam_wo_comp_tbl.FIRST);

		/* Failure Analysis Project Start */

		       l_eam_failure_entry_record.failure_id   := p_failure_id;
		       l_eam_failure_entry_record.failure_date := p_failure_date;

		       l_eam_failure_codes_tbl(1).failure_id := p_failure_id;
		       l_eam_failure_codes_tbl(1).failure_entry_id := p_failure_entry_id;
		       l_eam_failure_codes_tbl(1).failure_code     := p_failure_code;
		       l_eam_failure_codes_tbl(1).cause_code       := p_cause_code;
		       l_eam_failure_codes_tbl(1).resolution_code  := p_resolution_code;
		       l_eam_failure_codes_tbl(1).comments         := p_failure_comments;


		       SELECT
			 maintenance_object_type
			,maintenance_object_id
			INTO
                        l_maintenance_object_type
		       ,l_maintenance_object_id
			     FROM WIP_DISCRETE_JOBS
			     WHERE wip_entity_id = l_eam_wo_comp_rec.wip_entity_id;

		--only if asset number/rebuild serial number exists for work order
			IF(l_maintenance_object_type =3) THEN
				 BEGIN

			            --if workorder dept. is null,de fault it from asset's owning dept

					 SELECT OWNING_DEPARTMENT_ID
					   INTO l_fail_dept_id
					   FROM eam_org_maint_defaults
					  WHERE object_id =l_maintenance_object_id
					  AND object_type = 50
					  AND organization_id =l_eam_wo_comp_rec.organization_id;

				     SELECT area_id
				      INTO l_eam_location_id
				      FROM eam_org_maint_defaults
					WHERE object_id = l_maintenance_object_id
                                     AND object_type = 50
                                     AND organization_id = l_eam_wo_comp_rec.organization_id;

				    EXCEPTION
				      WHEN NO_DATA_FOUND THEN
				      NULL;
				    END;
				    END IF;  --end of check for mainteannce_object_type =3


	l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;
	l_eam_failure_entry_record.source_type := 1;
	l_eam_failure_entry_record.source_id := l_eam_wo_comp_rec.wip_entity_id;
	l_eam_failure_entry_record.object_type := l_maintenance_object_type;
	l_eam_failure_entry_record.object_id := l_maintenance_object_id;
	l_eam_failure_entry_record.maint_organization_id := l_eam_wo_comp_rec.organization_id;
	l_eam_failure_entry_record.current_organization_id := l_eam_wo_comp_rec.organization_id;
	l_eam_failure_entry_record.department_id := l_fail_dept_id;
	l_eam_failure_entry_record.area_id := l_eam_location_id;

        l_eam_failure_codes_tbl(1).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;

		IF (l_eam_failure_entry_record.failure_date IS NULL) THEN
			l_eam_failure_entry_record.failure_date := FND_API.G_MISS_DATE;
		END IF;

		IF (l_eam_failure_codes_tbl(1).failure_code IS NULL) THEN
			l_eam_failure_codes_tbl(1).failure_code := FND_API.G_MISS_CHAR;
		END IF;

		IF (l_eam_failure_codes_tbl(1).cause_code IS NULL) THEN
		    l_eam_failure_codes_tbl(1).cause_code := FND_API.G_MISS_CHAR;
		END IF;

		IF (l_eam_failure_codes_tbl(1).resolution_code IS NULL) THEN
		    l_eam_failure_codes_tbl(1).resolution_code := FND_API.G_MISS_CHAR;
		END IF;

		IF (l_eam_failure_codes_tbl(1).comments IS NULL) THEN
		    l_eam_failure_codes_tbl(1).comments := FND_API.G_MISS_CHAR;
		END IF;

		IF(l_eam_failure_entry_record.failure_id IS NOT NULL ) THEN
		  l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;
		ELSE
		   IF(l_eam_failure_entry_record.failure_date = FND_API.G_MISS_DATE) THEN
		      l_eam_failure_entry_record.transaction_type :=null;
		      l_eam_failure_entry_record.failure_date :=null;
		   ELSE
		      l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE ;
		   END IF;
		END IF;

		 IF(l_eam_failure_codes_tbl(1).failure_entry_id IS NOT NULL) THEN
			  l_eam_failure_codes_tbl(1).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;
			  l_eam_wo_comp_rec.eam_failure_codes_tbl(1) := l_eam_failure_codes_tbl(1);

		 ELSE
		   IF( NOT( (l_eam_failure_codes_tbl(1).failure_code = FND_API.G_MISS_CHAR)
			 AND (l_eam_failure_codes_tbl(1).cause_code = FND_API.G_MISS_CHAR)
			 AND (l_eam_failure_codes_tbl(1).resolution_code = FND_API.G_MISS_CHAR)
			 AND (l_eam_failure_codes_tbl(1).comments = FND_API.G_MISS_CHAR)
			)
		     ) THEN
			  l_eam_failure_codes_tbl(1).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE;

			   IF(l_eam_failure_codes_tbl(1).failure_code = FND_API.G_MISS_CHAR) THEN
				l_eam_failure_codes_tbl(1).failure_code := null;
			   END IF;

			   IF(l_eam_failure_codes_tbl(1).cause_code = FND_API.G_MISS_CHAR) THEN
				l_eam_failure_codes_tbl(1).cause_code := NULL;
			   END IF;

			  IF(l_eam_failure_codes_tbl(1).resolution_code = FND_API.G_MISS_CHAR) then
				l_eam_failure_codes_tbl(1).resolution_code := null;
			  END IF;

			  IF(l_eam_failure_codes_tbl(1).comments = FND_API.G_MISS_CHAR) then
				l_eam_failure_codes_tbl(1).comments := null;
			  END IF;
			    l_eam_wo_comp_rec.eam_failure_codes_tbl(1) := l_eam_failure_codes_tbl(1);

			 ELSE
			    l_eam_failure_codes_tbl.delete;
			    l_eam_wo_comp_rec.eam_failure_codes_tbl := l_eam_failure_codes_tbl;

			 END IF;
			END IF;

		     l_eam_wo_comp_rec.eam_failure_entry_record := l_eam_failure_entry_record;
		     l_eam_wo_comp_tbl(l_eam_wo_comp_tbl.FIRST) := l_eam_wo_comp_rec;

		END IF;

		/* Failure Analysis Project End */

       --Set the activity_id to Fnd_Api.G_Miss_Num if we want to delete the activity
       l_eam_wo_tbl := p_eam_wo_tbl;
       IF(l_eam_wo_tbl IS NOT  NULL AND l_eam_wo_tbl.COUNT>0) THEN

				   l_eam_wo_rec := l_eam_wo_tbl(l_eam_wo_tbl.FIRST);

				--set FND_API.G_MISS_xx if any columns are nulled out
		             l_wo_exists := TRUE;    --work order already exists...if no data found exception is thrown then l_wo_exists will be set to FALSE

				BEGIN
				       l_wip_entity_id :=l_eam_wo_rec.wip_entity_id;

				          SELECT       asset_number
					                        ,asset_group_id
								,rebuild_serial_number
				                                ,rebuild_item_id
								,primary_item_id
								,description
								,priority
								,work_order_type
								,shutdown_type
								,activity_type
								,activity_cause
								,activity_source
								,attribute_category
								,attribute1
								,attribute2
								,attribute3
								,attribute4
								,attribute5
								,attribute6
								,attribute7
								,attribute8
								,attribute9
								,attribute10
								,attribute11
								,attribute12
								,attribute13
								,attribute14
								,attribute15
								/* Added for bug#6053425 Start */
								,project_id
								,task_id
								/* Added for bug#6053425 End */
				       INTO             l_asset_number
				                            ,l_asset_group_id
							    ,l_rebuild_serial_number
							    ,l_rebuild_item_id
							    ,l_prev_activity_id
								,l_prev_description
								,l_prev_priority
								,l_prev_work_order_type
								,l_prev_shutdown_type
								,l_prev_activity_type
								,l_prev_activity_cause
								,l_prev_activity_source
								,l_prev_attribute_category
								,l_prev_attribute1
								,l_prev_attribute2
								,l_prev_attribute3
								,l_prev_attribute4
								,l_prev_attribute5
								,l_prev_attribute6
								,l_prev_attribute7
								,l_prev_attribute8
								,l_prev_attribute9
								,l_prev_attribute10
								,l_prev_attribute11
								,l_prev_attribute12
								,l_prev_attribute13
								,l_prev_attribute14
								,l_prev_attribute15
								/* Code Added for bug#6053425 Start */
 	              ,l_prev_project_id
 	              ,l_prev_task_id
 	              /* Code Added for bug#6053425 End */
				       FROM WIP_DISCRETE_JOBS
				       where wip_entity_id = l_wip_entity_id;

				       IF(l_asset_number is NOT NULL and l_eam_wo_rec.asset_number IS NULL) THEN
				                l_eam_wo_rec.asset_number := FND_API.G_MISS_CHAR;
				       END IF;

				       IF(l_rebuild_serial_number is NOT NULL and l_eam_wo_rec.rebuild_serial_number IS NULL) THEN
				                l_eam_wo_rec.rebuild_serial_number := FND_API.G_MISS_CHAR;
				       END IF;

				       IF(l_asset_group_id is NOT NULL and l_eam_wo_rec.asset_group_id IS NULL) THEN
				                l_eam_wo_rec.asset_group_id := FND_API.G_MISS_NUM;
				       END IF;

				       IF(l_rebuild_item_id is NOT NULL and l_eam_wo_rec.rebuild_item_id IS NULL) THEN
				                l_eam_wo_rec.rebuild_item_id:= FND_API.G_MISS_NUM;
				       END IF;

				       IF l_prev_activity_id is not null and l_eam_wo_rec.asset_activity_id is null THEN
						l_eam_wo_rec.asset_activity_id  := FND_API.G_MISS_NUM;
				       END IF;

				      IF l_prev_description is not null and l_eam_wo_rec.description is null THEN
						l_eam_wo_rec.description := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_activity_type is not null and l_eam_wo_rec.activity_type is null THEN
						l_eam_wo_rec.activity_type  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_activity_cause is not null and l_eam_wo_rec.activity_cause is null THEN
						l_eam_wo_rec.activity_cause  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_activity_source is not null and l_eam_wo_rec.activity_source is null THEN
						l_eam_wo_rec.activity_source  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_shutdown_type is not null and l_eam_wo_rec.shutdown_type is null THEN
						l_eam_wo_rec.shutdown_type  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_priority is not null and l_eam_wo_rec.priority is null THEN
						l_eam_wo_rec.priority  := FND_API.G_MISS_NUM;
				      END IF;

				      IF l_prev_work_order_type is not null and l_eam_wo_rec.work_order_type is null THEN
						l_eam_wo_rec.work_order_type  := FND_API.G_MISS_CHAR;
				      END IF;

				       IF l_prev_attribute_category is not null and l_eam_wo_rec.attribute_category is null THEN
						l_eam_wo_rec.attribute_category  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute1 is not null and l_eam_wo_rec.attribute1 is null THEN
						l_eam_wo_rec.attribute1  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute2 is not null and l_eam_wo_rec.attribute2 is null THEN
						l_eam_wo_rec.attribute2  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute3 is not null and l_eam_wo_rec.attribute3 is null THEN
						l_eam_wo_rec.attribute3  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute4 is not null and l_eam_wo_rec.attribute4 is null THEN
						l_eam_wo_rec.attribute4  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute5 is not null and l_eam_wo_rec.attribute5 is null THEN
						l_eam_wo_rec.attribute5  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute6 is not null and l_eam_wo_rec.attribute6 is null THEN
						l_eam_wo_rec.attribute6  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute7 is not null and l_eam_wo_rec.attribute7 is null THEN
						l_eam_wo_rec.attribute7  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute8 is not null and l_eam_wo_rec.attribute8 is null THEN
						l_eam_wo_rec.attribute8  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute9 is not null and l_eam_wo_rec.attribute9 is null THEN
						l_eam_wo_rec.attribute9  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute10 is not null and l_eam_wo_rec.attribute10 is null THEN
						l_eam_wo_rec.attribute10  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute11 is not null and l_eam_wo_rec.attribute11 is null THEN
						l_eam_wo_rec.attribute11  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute12 is not null and l_eam_wo_rec.attribute12 is null THEN
						l_eam_wo_rec.attribute12  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute13 is not null and l_eam_wo_rec.attribute13 is null THEN
						l_eam_wo_rec.attribute13  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute14 is not null and l_eam_wo_rec.attribute14 is null THEN
						l_eam_wo_rec.attribute14  := FND_API.G_MISS_CHAR;
				      END IF;

				      IF l_prev_attribute15 is not null and l_eam_wo_rec.attribute15 is null THEN
						l_eam_wo_rec.attribute15  := FND_API.G_MISS_CHAR;
				      END IF;

				    /* Added for bug#6053425 Start */

 	          IF l_prev_project_id is not null AND l_eam_wo_rec.project_id is null THEN
 	               l_eam_wo_rec.project_id := FND_API.G_MISS_NUM;
 	          END IF;

 	          IF l_prev_task_id is not null AND l_eam_wo_rec.task_id is null THEN
 	                l_eam_wo_rec.task_id := FND_API.G_MISS_NUM;
 	          END IF;

 	          /* Added for bug#6053425 End */

				EXCEPTION
				     WHEN NO_DATA_FOUND THEN
				         NULL;
				END;


				--Validate descriptive flexfield for workorder
				l_validate :=  EAM_COMMON_UTILITIES_PVT.validate_desc_flex_field(
				                                p_app_short_name              =>        'WIP',
								p_desc_flex_name                =>      'WIP_DISCRETE_JOBS',
								p_attribute_category            =>      l_eam_wo_rec.attribute_category,
								p_attribute1                    =>      l_eam_wo_rec.attribute1,
								p_attribute2                    =>      l_eam_wo_rec.attribute2,
								p_attribute3                    =>      l_eam_wo_rec.attribute3,
								p_attribute4                    =>      l_eam_wo_rec.attribute4,
								p_attribute5                    =>      l_eam_wo_rec.attribute5,
								p_attribute6                    =>      l_eam_wo_rec.attribute6,
								p_attribute7                    =>      l_eam_wo_rec.attribute7,
								p_attribute8                    =>      l_eam_wo_rec.attribute8,
								p_attribute9                    =>      l_eam_wo_rec.attribute9,
								p_attribute10                   =>      l_eam_wo_rec.attribute10,
								p_attribute11                   =>      l_eam_wo_rec.attribute11,
								p_attribute12                   =>      l_eam_wo_rec.attribute12,
								p_attribute13                   =>      l_eam_wo_rec.attribute13,
								p_attribute14                   =>      l_eam_wo_rec.attribute14,
								p_attribute15                   =>      l_eam_wo_rec.attribute15,
								x_error_segments                =>      l_error_segments,
								x_error_message                 =>      l_error_message
								);

								/* Commented for bug 8567361
								IF l_validate <> TRUE THEN
											   fnd_message.set_name
												(  application  => 'EAM'
												 , name         => 'EAM_WO_FLEX_ERROR'
												);

												fnd_message.set_token(token => 'MESG',
															  value => l_error_message,
															  translate => FALSE);


												fnd_msg_pub.add;

												x_wip_entity_id := l_eam_wo_rec.wip_entity_id;
												x_return_status := 'E';
												x_msg_count    :=   1;
												RETURN;
								END IF; */


				l_eam_wo_tbl(l_eam_wo_tbl.FIRST) := l_eam_wo_rec;
	END IF;

	         --Changes for Bug 8969942

 	                l_eam_mat_req_tbl := p_eam_mat_req_tbl;
 	                 IF(l_eam_mat_req_tbl IS NOT  NULL AND l_eam_mat_req_tbl.COUNT>0) THEN
 	                                    l_eam_mat_req_rec := l_eam_mat_req_tbl(l_eam_mat_req_tbl.FIRST);

 	                                 BEGIN
 	                                        l_wip_entity_id := l_eam_mat_req_rec.wip_entity_id;
 	                                        l_organization_id := l_eam_mat_req_rec.ORGANIZATION_ID;
 	                                        l_Operation_Seq_Num := l_eam_mat_req_rec.OPERATION_SEQ_NUM;
 	                                        l_inventory_item_id := l_eam_mat_req_rec.INVENTORY_ITEM_ID;

 	                                           SELECT                attribute_category
 	                                                                 ,attribute1
 	                                                                 ,attribute2
 	                                                                 ,attribute3
 	                                                                 ,attribute4
 	                                                                 ,attribute5
 	                                                                 ,attribute6
 	                                                                 ,attribute7
 	                                                                 ,attribute8
 	                                                                 ,attribute9
 	                                                                 ,attribute10
 	                                                                 ,attribute11
 	                                                                 ,attribute12
 	                                                                 ,attribute13
 	                                                                 ,attribute14
 	                                                                 ,attribute15
 	                                        INTO                        l_prev_mat_attribute_category
 	                                                                 ,l_prev_mat_attribute1
 	                                                                 ,l_prev_mat_attribute2
 	                                                                 ,l_prev_mat_attribute3
 	                                                                 ,l_prev_mat_attribute4
 	                                                                 ,l_prev_mat_attribute5
 	                                                                 ,l_prev_mat_attribute6
 	                                                                 ,l_prev_mat_attribute7
 	                                                                 ,l_prev_mat_attribute8
 	                                                                 ,l_prev_mat_attribute9
 	                                                                 ,l_prev_mat_attribute10
 	                                                                 ,l_prev_mat_attribute11
 	                                                                 ,l_prev_mat_attribute12
 	                                                                 ,l_prev_mat_attribute13
 	                                                                 ,l_prev_mat_attribute14
 	                                                                 ,l_prev_mat_attribute15
 	                                   from WIP_REQUIREMENT_OPERATIONS
 	                                   where wip_entity_id =l_wip_Entity_Id
 	                                   and organization_id = l_organization_id
 	                                   and operation_seq_num= l_Operation_Seq_Num
 	                                   and INVENTORY_ITEM_ID = l_inventory_item_id;
 	                            EXCEPTION
 	                               WHEN NO_DATA_FOUND THEN
 	                                  null;
 	                               When Others then
 	                                  null;
 	                            END;

 	                                       IF l_prev_mat_attribute_category is not null and l_eam_mat_req_rec.attribute_category is null THEN
 	                                                 l_eam_mat_req_rec.attribute_category  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                                  IF l_prev_mat_attribute1 is not null and l_eam_mat_req_rec.attribute1 is null THEN
 	                                                 l_eam_mat_req_rec.attribute1  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute2 is not null and l_eam_mat_req_rec.attribute2 is null THEN
 	                                                 l_eam_mat_req_rec.attribute2  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute3 is not null and l_eam_mat_req_rec.attribute3 is null THEN
 	                                                 l_eam_mat_req_rec.attribute3  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute4 is not null and l_eam_mat_req_rec.attribute4 is null THEN
 	                                                 l_eam_mat_req_rec.attribute4  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute5 is not null and l_eam_mat_req_rec.attribute5 is null THEN
 	                                                 l_eam_mat_req_rec.attribute5  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute6 is not null and l_eam_mat_req_rec.attribute6 is null THEN
 	                                                 l_eam_mat_req_rec.attribute6  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute7 is not null and l_eam_mat_req_rec.attribute7 is null THEN
 	                                                 l_eam_mat_req_rec.attribute7  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute8 is not null and l_eam_mat_req_rec.attribute8 is null THEN
 	                                                 l_eam_mat_req_rec.attribute8  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute9 is not null and l_eam_mat_req_rec.attribute9 is null THEN
 	                                                 l_eam_mat_req_rec.attribute9  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute10 is not null and l_eam_mat_req_rec.attribute10 is null THEN
 	                                                 l_eam_mat_req_rec.attribute10  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute11 is not null and l_eam_mat_req_rec.attribute11 is null THEN
 	                                                 l_eam_mat_req_rec.attribute11  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute12 is not null and l_eam_mat_req_rec.attribute12 is null THEN
 	                                                 l_eam_mat_req_rec.attribute12  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute13 is not null and l_eam_mat_req_rec.attribute13 is null THEN
 	                                                 l_eam_mat_req_rec.attribute13  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute14 is not null and l_eam_mat_req_rec.attribute14 is null THEN
 	                                                 l_eam_mat_req_rec.attribute14  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_mat_attribute15 is not null and l_eam_mat_req_rec.attribute15 is null THEN
 	                                                 l_eam_mat_req_rec.attribute15  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                 --Validate descriptive flexfield for materials - "Component Information"
 	                                 l_validate :=  EAM_COMMON_UTILITIES_PVT.validate_desc_flex_field(
 	                                                                 p_app_short_name              =>        'BOM',
 	                                                                 p_desc_flex_name                =>      'BOM_INVENTORY_COMPONENTS',
 	                                                                 p_attribute_category            =>      l_eam_mat_req_rec.attribute_category,
 	                                                                 p_attribute1                    =>      l_eam_mat_req_rec.attribute1,
 	                                                                 p_attribute2                    =>      l_eam_mat_req_rec.attribute2,
 	                                                                 p_attribute3                    =>      l_eam_mat_req_rec.attribute3,
 	                                                                 p_attribute4                    =>      l_eam_mat_req_rec.attribute4,
 	                                                                 p_attribute5                    =>      l_eam_mat_req_rec.attribute5,
 	                                                                 p_attribute6                    =>      l_eam_mat_req_rec.attribute6,
 	                                                                 p_attribute7                    =>      l_eam_mat_req_rec.attribute7,
 	                                                                 p_attribute8                    =>      l_eam_mat_req_rec.attribute8,
 	                                                                 p_attribute9                    =>      l_eam_mat_req_rec.attribute9,
 	                                                                 p_attribute10                   =>      l_eam_mat_req_rec.attribute10,
 	                                                                 p_attribute11                   =>      l_eam_mat_req_rec.attribute11,
 	                                                                 p_attribute12                   =>      l_eam_mat_req_rec.attribute12,
 	                                                                 p_attribute13                   =>      l_eam_mat_req_rec.attribute13,
 	                                                                 p_attribute14                   =>      l_eam_mat_req_rec.attribute14,
 	                                                                 p_attribute15                   =>      l_eam_mat_req_rec.attribute15,
 	                                                                 x_error_segments                =>      l_error_segments,
 	                                                                 x_error_message                 =>      l_error_message
 	                                                                 );



 	                                 l_eam_mat_req_tbl(l_eam_mat_req_tbl.FIRST) := l_eam_mat_req_rec;
 	         END IF;

 	                                                  l_eam_direct_items_tbl := p_eam_direct_items_tbl;
 	                 IF(l_eam_direct_items_tbl IS NOT  NULL AND l_eam_direct_items_tbl.COUNT>0) THEN
 	                                    l_eam_direct_items_rec := l_eam_direct_items_tbl(l_eam_direct_items_tbl.FIRST);

 	                                 BEGIN
 	                                        l_wip_entity_id := l_eam_direct_items_rec.wip_entity_id;
 	                                        l_organization_id := l_eam_direct_items_rec.ORGANIZATION_ID;
 	                                        l_Operation_Seq_Num := l_eam_direct_items_rec.OPERATION_SEQ_NUM;
 	                                        l_dir_item_seq_id := l_eam_direct_items_rec.Direct_Item_Sequence_Id;

 	                                           SELECT                attribute_category
 	                                                                 ,attribute1
 	                                                                 ,attribute2
 	                                                                 ,attribute3
 	                                                                 ,attribute4
 	                                                                 ,attribute5
 	                                                                 ,attribute6
 	                                                                 ,attribute7
 	                                                                 ,attribute8
 	                                                                 ,attribute9
 	                                                                 ,attribute10
 	                                                                 ,attribute11
 	                                                                 ,attribute12
 	                                                                 ,attribute13
 	                                                                 ,attribute14
 	                                                                 ,attribute15
 	                                        INTO                        l_prev_dir_attribute_category
 	                                                                 ,l_prev_dir_attribute1
 	                                                                 ,l_prev_dir_attribute2
 	                                                                 ,l_prev_dir_attribute3
 	                                                                 ,l_prev_dir_attribute4
 	                                                                 ,l_prev_dir_attribute5
 	                                                                 ,l_prev_dir_attribute6
 	                                                                 ,l_prev_dir_attribute7
 	                                                                 ,l_prev_dir_attribute8
 	                                                                 ,l_prev_dir_attribute9
 	                                                                 ,l_prev_dir_attribute10
 	                                                                 ,l_prev_dir_attribute11
 	                                                                 ,l_prev_dir_attribute12
 	                                                                 ,l_prev_dir_attribute13
 	                                                                 ,l_prev_dir_attribute14
 	                                                                 ,l_prev_dir_attribute15
 	                                   from wip_eam_direct_items
 	                                   where wip_entity_id =l_wip_Entity_Id
 	                                   and organization_id = l_organization_id
 	                                   and operation_seq_num= l_Operation_Seq_Num ;

 	                            EXCEPTION
 	                               WHEN NO_DATA_FOUND THEN
 	                                  null;
 	                               When Others then
 	                                  null;
 	                            END;

 	                                       IF l_prev_dir_attribute_category is not null and l_eam_direct_items_rec.attribute_category is null THEN
 	                                                 l_eam_direct_items_rec.attribute_category  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute1 is not null and l_eam_direct_items_rec.attribute1 is null THEN
 	                                                 l_eam_direct_items_rec.attribute1  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute2 is not null and l_eam_direct_items_rec.attribute2 is null THEN
 	                                                 l_eam_direct_items_rec.attribute2  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute3 is not null and l_eam_direct_items_rec.attribute3 is null THEN
 	                                                 l_eam_direct_items_rec.attribute3  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute4 is not null and l_eam_direct_items_rec.attribute4 is null THEN
 	                                                 l_eam_direct_items_rec.attribute4  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute5 is not null and l_eam_direct_items_rec.attribute5 is null THEN
 	                                                 l_eam_direct_items_rec.attribute5  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute6 is not null and l_eam_direct_items_rec.attribute6 is null THEN
 	                                                 l_eam_direct_items_rec.attribute6  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute7 is not null and l_eam_direct_items_rec.attribute7 is null THEN
 	                                                 l_eam_direct_items_rec.attribute7  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute8 is not null and l_eam_direct_items_rec.attribute8 is null THEN
 	                                                 l_eam_direct_items_rec.attribute8  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute9 is not null and l_eam_direct_items_rec.attribute9 is null THEN
 	                                                 l_eam_direct_items_rec.attribute9  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute10 is not null and l_eam_direct_items_rec.attribute10 is null THEN
 	                                                 l_eam_direct_items_rec.attribute10  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute11 is not null and l_eam_direct_items_rec.attribute11 is null THEN
 	                                                 l_eam_direct_items_rec.attribute11  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute12 is not null and l_eam_direct_items_rec.attribute12 is null THEN
 	                                                 l_eam_direct_items_rec.attribute12  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute13 is not null and l_eam_direct_items_rec.attribute13 is null THEN
 	                                                 l_eam_direct_items_rec.attribute13  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute14 is not null and l_eam_direct_items_rec.attribute14 is null THEN
 	                                                 l_eam_direct_items_rec.attribute14  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                       IF l_prev_dir_attribute15 is not null and l_eam_direct_items_rec.attribute15 is null THEN
 	                                                 l_eam_direct_items_rec.attribute15  := FND_API.G_MISS_CHAR;
 	                                       END IF;

 	                                 --Validate descriptive flexfield for workorder
 	                                 l_validate :=  EAM_COMMON_UTILITIES_PVT.validate_desc_flex_field(
 	                                                                 p_app_short_name              =>        'EAM',
 	                                                                 p_desc_flex_name                =>      'EAM_DESC_DIR_ITEM',
 	                                                                 p_attribute_category            =>      l_eam_direct_items_rec.attribute_category,
 	                                                                 p_attribute1                    =>      l_eam_direct_items_rec.attribute1,
 	                                                                 p_attribute2                    =>      l_eam_direct_items_rec.attribute2,
 	                                                                 p_attribute3                    =>      l_eam_direct_items_rec.attribute3,
 	                                                                 p_attribute4                    =>      l_eam_direct_items_rec.attribute4,
 	                                                                 p_attribute5                    =>      l_eam_direct_items_rec.attribute5,
 	                                                                 p_attribute6                    =>      l_eam_direct_items_rec.attribute6,
 	                                                                 p_attribute7                    =>      l_eam_direct_items_rec.attribute7,
 	                                                                 p_attribute8                    =>      l_eam_direct_items_rec.attribute8,
 	                                                                 p_attribute9                    =>      l_eam_direct_items_rec.attribute9,
 	                                                                 p_attribute10                   =>      l_eam_direct_items_rec.attribute10,
 	                                                                 p_attribute11                   =>      l_eam_direct_items_rec.attribute11,
 	                                                                 p_attribute12                   =>      l_eam_direct_items_rec.attribute12,
 	                                                                 p_attribute13                   =>      l_eam_direct_items_rec.attribute13,
 	                                                                 p_attribute14                   =>      l_eam_direct_items_rec.attribute14,
 	                                                                 p_attribute15                   =>      l_eam_direct_items_rec.attribute15,
 	                                                                 x_error_segments                =>      l_error_segments,
 	                                                                 x_error_message                 =>      l_error_message
 	                                                                 );

 	                                 l_eam_direct_items_tbl(l_eam_direct_items_tbl.FIRST) := l_eam_direct_items_rec;
 	         END IF;

 	 ----end of changes for 8969942

       --Set the auto_charge type to Manual/POReceipt for newly created workorders
	l_eam_res_tbl := p_eam_res_tbl;
	IF(l_eam_res_tbl IS NOT NULL AND l_eam_res_tbl.COUNT>0) THEN
			FOR i IN  l_eam_res_tbl.FIRST ..  l_eam_res_tbl.LAST LOOP
                                    IF(l_eam_res_tbl(i).transaction_type=EAM_PROCESS_WO_PUB.G_OPR_CREATE AND (l_eam_res_tbl(i).autocharge_type IS NULL)) THEN
							OPEN resources(l_eam_res_tbl(i).resource_id,l_eam_res_tbl(i).organization_id);
							FETCH resources INTO l_resources;
							   IF(resources%FOUND) THEN
								IF(l_resources.autocharge_type=1 OR l_resources.autocharge_type=2) THEN
									l_eam_res_tbl(i).autocharge_type := 2;
								ELSE
									l_eam_res_tbl(i).autocharge_type := 3;
								END IF;
							   END IF;
							CLOSE resources;
				    END IF;
			 END LOOP;
	 END IF;

      --p_failure_code_required will be passed only when failure code information is entered or modified.
      --Make sure that work order record is passed whenever failure entry is passed, as we have some logic on work order related info
	 IF(p_failure_code_required IS NOT NULL) THEN

		/* Failure Analysis Project Start */
		       l_eam_failure_entry_record.failure_id   := p_failure_id;
		       l_eam_failure_entry_record.failure_date := p_failure_date;

		       l_eam_failure_codes_tbl(1).failure_id := p_failure_id;
		       l_eam_failure_codes_tbl(1).failure_entry_id := p_failure_entry_id;
		       l_eam_failure_codes_tbl(1).failure_code     := p_failure_code;
		       l_eam_failure_codes_tbl(1).cause_code       := p_cause_code;
		       l_eam_failure_codes_tbl(1).resolution_code  := p_resolution_code;
		       l_eam_failure_codes_tbl(1).comments         := p_failure_comments;
		     /* Failure Analysis Project End */

		      l_fail_dept_id  := l_eam_wo_rec.owning_department;

                    --ideally work order info should be passed when failure info is passed. But check that workorder is passed
		    IF(l_eam_wo_tbl IS NOT  NULL AND l_eam_wo_tbl.COUNT>0) THEN

		--only if asset number/rebuild serial number exists for work order
			IF(l_maintenance_object_type =3) THEN
				 BEGIN

			            --if workorder dept. is null,de fault it from asset's owning dept
				    IF(l_fail_dept_id IS NULL) THEN
					 SELECT OWNING_DEPARTMENT_ID
					   INTO l_fail_dept_id
					   FROM eam_org_maint_defaults
					  WHERE object_id =l_maintenance_object_id
					  AND object_type = 50
					  AND organization_id =l_eam_wo_comp_rec.organization_id;
				     END IF;

				     SELECT area_id
				      INTO l_eam_location_id
				      FROM eam_org_maint_defaults
					WHERE object_id = l_maintenance_object_id
                                     AND object_type = 50
                                     AND organization_id = l_eam_wo_comp_rec.organization_id;

				    EXCEPTION
				      WHEN NO_DATA_FOUND THEN
				      NULL;
				    END;
				    END IF;  --end of check for mainteannce_object_type =3

						        l_eam_wo_rec.failure_code_required := p_failure_code_required;

			IF(l_wo_exists =  TRUE)  THEN

				l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;
				l_eam_failure_entry_record.source_type := 1;
				l_eam_failure_entry_record.source_id := l_eam_wo_rec.wip_entity_id;
				l_eam_failure_entry_record.object_type := l_eam_wo_rec.maintenance_object_type;
				l_eam_failure_entry_record.object_id := l_eam_wo_rec.maintenance_object_id;
				l_eam_failure_entry_record.maint_organization_id := l_eam_wo_rec.organization_id;
				l_eam_failure_entry_record.current_organization_id := l_eam_wo_rec.organization_id;
				l_eam_failure_entry_record.department_id := l_fail_dept_id;
				l_eam_failure_entry_record.area_id := l_eam_location_id;


				l_eam_failure_codes_tbl(1).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;
				if (l_eam_failure_entry_record.failure_date is null) then
				    l_eam_failure_entry_record.failure_date := FND_API.G_MISS_DATE;
				end if;
				if (l_eam_failure_codes_tbl(1).failure_code is null) then
				     l_eam_failure_codes_tbl(1).failure_code := FND_API.G_MISS_CHAR;
				end if;
				if (l_eam_failure_codes_tbl(1).cause_code is null) then
				    l_eam_failure_codes_tbl(1).cause_code := FND_API.G_MISS_CHAR;
				end if;
				if (l_eam_failure_codes_tbl(1).resolution_code is null) then
				    l_eam_failure_codes_tbl(1).resolution_code := FND_API.G_MISS_CHAR;
				end if;
				if (l_eam_failure_codes_tbl(1).comments is null) then
				    l_eam_failure_codes_tbl(1).comments := FND_API.G_MISS_CHAR;
				end if;
				  if(l_eam_failure_entry_record.failure_id is not null ) then
				  l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;
				 else
				   if(l_eam_failure_entry_record.failure_date = FND_API.G_MISS_DATE) then
				      l_eam_failure_entry_record.transaction_type :=null;
				      l_eam_failure_entry_record.failure_date :=null;
				   else
				      l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE ;
				   end if;
				 end if;

				 if(l_eam_failure_codes_tbl(1).failure_entry_id is not null) then
					  l_eam_failure_codes_tbl(1).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;
					  l_eam_wo_rec.eam_failure_codes_tbl(1) := l_eam_failure_codes_tbl(1);

				 else
						   if( not( (l_eam_failure_codes_tbl(1).failure_code = FND_API.G_MISS_CHAR)
							 and (l_eam_failure_codes_tbl(1).cause_code = FND_API.G_MISS_CHAR)
							 and (l_eam_failure_codes_tbl(1).resolution_code = FND_API.G_MISS_CHAR)
							 and (l_eam_failure_codes_tbl(1).comments = FND_API.G_MISS_CHAR)
							)
						     ) then
									     l_eam_failure_codes_tbl(1).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE;
									     if(l_eam_failure_codes_tbl(1).failure_code = FND_API.G_MISS_CHAR) then
										l_eam_failure_codes_tbl(1).failure_code := null;
									     end if;
									     if(l_eam_failure_codes_tbl(1).cause_code = FND_API.G_MISS_CHAR) then
										l_eam_failure_codes_tbl(1).cause_code := null;
									     end if;
									     if(l_eam_failure_codes_tbl(1).resolution_code = FND_API.G_MISS_CHAR) then
										l_eam_failure_codes_tbl(1).resolution_code := null;
									     end if;
									     if(l_eam_failure_codes_tbl(1).comments = FND_API.G_MISS_CHAR) then
										l_eam_failure_codes_tbl(1).comments := null;
									     end if;
									     l_eam_wo_rec.eam_failure_codes_tbl(1) := l_eam_failure_codes_tbl(1);

						  else
									     l_eam_failure_codes_tbl.delete;
									     l_eam_wo_rec.eam_failure_codes_tbl := l_eam_failure_codes_tbl;

						  end if;
				 end if;
				l_eam_wo_rec.eam_failure_entry_record := l_eam_failure_entry_record;

ELSE    -- work order is getting created

				l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE;
				l_eam_failure_entry_record.source_type := 1;
				l_eam_failure_entry_record.source_id := l_eam_wo_rec.wip_entity_id;
				l_eam_failure_entry_record.object_type := l_eam_wo_rec.maintenance_object_type;
				l_eam_failure_entry_record.object_id := l_eam_wo_rec.maintenance_object_id;
				l_eam_failure_entry_record.maint_organization_id := l_eam_wo_rec.organization_id;
				l_eam_failure_entry_record.current_organization_id := l_eam_wo_rec.organization_id;
				l_eam_failure_entry_record.department_id := l_fail_dept_id;
				l_eam_failure_entry_record.area_id := l_eam_location_id;

				if(l_eam_failure_entry_record.failure_date is null) then
				  l_eam_failure_entry_record.transaction_type :=null;
				end if;
				l_eam_wo_rec.eam_failure_entry_record := l_eam_failure_entry_record;

				l_eam_failure_codes_tbl(1).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE;
				if( not( l_eam_failure_codes_tbl(1).failure_code is null
					 and l_eam_failure_codes_tbl(1).cause_code is null
					 and l_eam_failure_codes_tbl(1).resolution_code is null
					 and l_eam_failure_codes_tbl(1).comments is null
					)
				    ) then
							l_eam_wo_rec.eam_failure_codes_tbl(1) := l_eam_failure_codes_tbl(1);
				else
							l_eam_failure_codes_tbl.delete;
							l_eam_wo_rec.eam_failure_codes_tbl := l_eam_failure_codes_tbl;
				end if;

							END IF;


                                              l_eam_wo_tbl(l_eam_wo_tbl.FIRST) := l_eam_wo_rec;

		     END IF;   --end of check for work order record passed

	 END IF;   --end of check for failure data passed


       x_wip_entity_id := NULL;

       IF(p_eam_wo_relations_tbl IS NOT NULL AND p_eam_wo_relations_tbl.COUNT > 0) THEN

		EAM_PROCESS_WO_PUB.PROCESS_MASTER_CHILD_WO(
		p_bo_identifier			=>'EAM'
		, p_api_version_number    => 1.0
		, p_init_msg_list			=>  TRUE
		, p_eam_wo_relations_tbl    => p_eam_wo_relations_tbl
		, p_eam_wo_tbl			    => l_eam_wo_tbl
		, p_eam_op_tbl			   => p_eam_op_tbl
		, p_eam_op_network_tbl     => l_eam_op_network_tbl
		, p_eam_res_tbl                   => l_eam_res_tbl
		, p_eam_res_inst_tbl          => p_eam_res_inst_tbl
		,p_eam_res_usage_tbl     => p_eam_res_usage_tbl
		, p_eam_sub_res_tbl         => l_eam_sub_res_tbl
		, p_eam_mat_req_tbl          => l_eam_mat_req_tbl
		, p_eam_direct_items_tbl    => l_eam_direct_items_tbl
		, p_eam_wo_comp_tbl         => p_eam_wo_comp_tbl
		 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
		, p_eam_meter_reading_tbl   => p_eam_meter_reading_tbl
		, p_eam_counter_prop_tbl     =>    p_eam_counter_prop_tbl
		, p_eam_wo_comp_rebuild_tbl    => p_eam_wo_comp_rebuild_tbl
		, p_eam_wo_comp_mr_read_tbl   => p_eam_wo_comp_mr_read_tbl
		, p_eam_op_comp_tbl            => l_eam_op_comp_tbl
		, p_eam_request_tbl               => p_eam_request_tbl
		, x_eam_wo_tbl                        => l_eam_wo_tbl_out
		, x_eam_wo_relations_tbl      => l_eam_wo_relations_tbl_out
		, x_eam_op_tbl                         => l_eam_op_tbl_out
		, x_eam_op_network_tbl        => l_eam_op_network_tbl_out
		, x_eam_res_tbl                      => l_eam_res_tbl_out
		, x_eam_res_usage_tbl        =>    l_eam_res_usage_tbl_out
		, x_eam_res_inst_tbl             => l_eam_res_inst_tbl_out
		, x_eam_sub_res_tbl            => l_eam_sub_res_tbl_out
		, x_eam_mat_req_tbl           => l_eam_mat_req_tbl_out
		, x_eam_direct_items_tbl     =>l_eam_direct_items_tbl_out
		, x_eam_wo_comp_tbl         => l_eam_wo_comp_tbl_out
		, x_eam_wo_quality_tbl      => l_eam_wo_quality_tbl_out
		, x_eam_meter_reading_tbl   => l_eam_meter_reading_tbl_out
		, x_eam_counter_prop_tbl        =>    l_eam_counter_prop_tbl_out
		, x_eam_wo_comp_rebuild_tbl    =>  l_eam_wo_comp_rebuild_tbl_out
		, x_eam_wo_comp_mr_read_tbl    => l_eam_wo_comp_mr_read_tbl_out
		, x_eam_op_comp_tbl		 => l_eam_op_comp_tbl_out
		, x_eam_request_tbl			 => l_eam_request_tbl_out
		, x_return_status				 => x_return_status
		, x_msg_count				 => x_msg_count
		, p_commit				=> 'N'
		, p_debug				=> NVL(fnd_profile.value('EAM_DEBUG'), 'N')
		, p_output_dir				 => l_output_dir
		, p_debug_filename			  => 'createupdatewo.log'
		, p_debug_file_mode		 => 'W'
		);

	ELSE
		IF ( l_eam_wo_tbl.COUNT > 0 ) THEN
			l_eam_wo_rec := l_eam_wo_tbl(l_eam_wo_tbl.FIRST);
		END IF;

		IF ( l_eam_wo_comp_tbl.COUNT > 0 ) THEN
			l_eam_wo_comp_rec := l_eam_wo_comp_tbl(l_eam_wo_comp_tbl.FIRST);
		END IF;

		EAM_PROCESS_WO_PUB.PROCESS_WO(
		  p_bo_identifier			=>'EAM'
		, p_api_version_number    => 1.0
		, p_init_msg_list			=>  TRUE
		, p_eam_wo_rec			    => l_eam_wo_rec
		, p_eam_op_tbl			   => p_eam_op_tbl
		, p_eam_op_network_tbl     => l_eam_op_network_tbl
		, p_eam_res_tbl                   => l_eam_res_tbl
		, p_eam_res_inst_tbl          => p_eam_res_inst_tbl
		, p_eam_res_usage_tbl     => p_eam_res_usage_tbl
		, p_eam_sub_res_tbl         => l_eam_sub_res_tbl
		, p_eam_mat_req_tbl          => l_eam_mat_req_tbl
		, p_eam_direct_items_tbl    => l_eam_direct_items_tbl
		, p_eam_wo_comp_rec          => l_eam_wo_comp_rec
		, p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
		, p_eam_meter_reading_tbl   => p_eam_meter_reading_tbl
		, p_eam_counter_prop_tbl     =>    p_eam_counter_prop_tbl
		, p_eam_wo_comp_rebuild_tbl    => p_eam_wo_comp_rebuild_tbl
		, p_eam_wo_comp_mr_read_tbl   => p_eam_wo_comp_mr_read_tbl
 		, p_eam_permit_tbl            =>   p_eam_permit_tbl
 		, p_eam_permit_wo_assoc_tbl => p_eam_permit_wo_assoc_tbl
		, p_eam_op_comp_tbl            => l_eam_op_comp_tbl
		, p_eam_request_tbl            => p_eam_request_tbl
		, x_eam_wo_rec	               => l_eam_wo_rec_out
		, x_eam_op_tbl                 => l_eam_op_tbl_out
		, x_eam_op_network_tbl         => l_eam_op_network_tbl_out
		, x_eam_res_tbl                => l_eam_res_tbl_out
		, x_eam_res_usage_tbl          => l_eam_res_usage_tbl_out
		, x_eam_res_inst_tbl           => l_eam_res_inst_tbl_out
		, x_eam_sub_res_tbl            => l_eam_sub_res_tbl_out
		, x_eam_mat_req_tbl           => l_eam_mat_req_tbl_out
		, x_eam_direct_items_tbl     => l_eam_direct_items_tbl_out
		, x_eam_wo_comp_rec         => l_eam_wo_comp_rec_out
		, x_eam_wo_quality_tbl      => l_eam_wo_quality_tbl_out
		, x_eam_meter_reading_tbl   => l_eam_meter_reading_tbl_out
		, x_eam_counter_prop_tbl        =>  l_eam_counter_prop_tbl_out
		, x_eam_wo_comp_rebuild_tbl    =>  l_eam_wo_comp_rebuild_tbl_out
		, x_eam_wo_comp_mr_read_tbl    => l_eam_wo_comp_mr_read_tbl_out
		, x_eam_op_comp_tbl	 => l_eam_op_comp_tbl_out
		, x_eam_request_tbl	 => l_eam_request_tbl_out
		, x_return_status	 => x_return_status
		, x_msg_count		 => x_msg_count
		, p_commit			=> 'N'
		, p_debug			=> NVL(fnd_profile.value('EAM_DEBUG'), 'N')
		, p_output_dir			=> l_output_dir
		, p_debug_filename		=> 'createupdatewo.log'
		, p_debug_file_mode		=> 'W'
		);

	END IF;

  END IF; /*MSP IF END*/

	IF(x_return_status='S') THEN
		IF p_commit = FND_API.G_TRUE THEN
			COMMIT WORK;
		end if;
		IF(l_eam_wo_tbl_out IS NOT NULL AND l_eam_wo_tbl_out.COUNT>0) THEN
			x_wip_entity_id := l_eam_wo_tbl_out(l_eam_wo_tbl_out.FIRST).wip_entity_id;
                ELSIF(l_eam_wo_rec_out.wip_entity_id IS NOT NULL) THEN
                        x_wip_entity_id := l_eam_wo_rec_out.wip_entity_id;
		END IF;
	END IF;

	IF(x_return_status <> 'S') THEN
	     ROLLBACK TO create_update_wo;
	END IF;

END CREATE_UPDATE_WO;

/********************************************************
Procedure to find the required,assigned and unassigned hours at workorder level
*********************************************************/
PROCEDURE ASSIGNED_HOURS
(
      p_wip_entity_id    IN NUMBER,
      x_required_hours   OUT NOCOPY NUMBER,
      x_assigned_hours   OUT NOCOPY NUMBER,
      x_unassigned_hours OUT NOCOPY NUMBER
)
IS

   l_uom_conv     NUMBER;
   l_hour_uom     VARCHAR2(10);
   l_sysdate          DATE;
   l_next_date       DATE;
   l_inv_item_id    NUMBER;

	 CURSOR get_hours_details_csr IS
	 SELECT ROUND(NVL(wor.usage_rate_or_amount * (1/l_uom_conv) *
			(DECODE (con.conversion_rate,'', 0, '0', 0, con.conversion_rate)),0),2) required_hours,
			 (SELECT ROUND(NVL(SUM((woru.completion_date-woru.start_date)*24) ,0),2)
				 FROM WIP_OPERATION_RESOURCE_USAGE woru
				 WHERE woru.wip_entity_id = wor.wip_entity_id
				 AND woru.organization_id = wor.organization_id
				 AND woru.operation_seq_num  =  wor.operation_seq_num
				 AND woru.resource_seq_num   =  wor.resource_seq_num
				 AND woru.instance_id IS NOT NULL
				 AND woru.serial_number IS NULL) assigned_hours
	FROM WIP_OPERATION_RESOURCES wor,MTL_UOM_CONVERSIONS con,BOM_RESOURCES br
	WHERE wor.wip_entity_id = p_wip_entity_id
	AND wor.resource_id = br.resource_id
	AND br.resource_type =	2						--for person type resources only
	AND con.uom_code = wor. uom_code
	AND NVL(con.disable_date, l_next_date) > l_sysdate
	AND con.inventory_item_id = l_inv_item_id;


BEGIN

     l_hour_uom := fnd_profile.value('BOM:HOUR_UOM_CODE');

     l_sysdate := SYSDATE;
     l_next_date := SYSDATE+1;
     l_inv_item_id := 0;



     x_required_hours := 0;
     x_assigned_hours := 0;
     x_unassigned_hours := 0;


         SELECT CON.CONVERSION_RATE
         INTO l_uom_conv
         FROM MTL_UOM_CONVERSIONS CON
        WHERE CON.UOM_CODE = l_hour_uom
        AND NVL(DISABLE_DATE, l_next_date) > l_sysdate
        AND CON.INVENTORY_ITEM_ID = l_inv_item_id;

	--Required Hours will be 'Usage-Rate-Or-Amount' and assigned hrs will be fetched from WORU
	--Unassigned hours will be added only if Assigned < Required, else it will be treated as 0

        FOR p_hours_row IN get_hours_details_csr
	LOOP
	     x_required_hours :=  x_required_hours + p_hours_row.required_hours;
	     x_assigned_hours :=  x_assigned_hours + p_hours_row.assigned_hours;

	     IF(p_hours_row.required_hours - p_hours_row.assigned_hours > 0) THEN
	          x_unassigned_hours := x_unassigned_hours + (p_hours_row.required_hours - p_hours_row.assigned_hours);
	     END IF;

	END LOOP;

EXCEPTION
WHEN NO_DATA_FOUND THEN
       NULL;
END ASSIGNED_HOURS;

END EAM_CREATEUPDATE_WO_PVT;


/
