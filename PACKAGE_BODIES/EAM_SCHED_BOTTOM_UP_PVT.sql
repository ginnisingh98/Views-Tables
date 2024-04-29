--------------------------------------------------------
--  DDL for Package Body EAM_SCHED_BOTTOM_UP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_SCHED_BOTTOM_UP_PVT" AS
	/* $Header: EAMVSBUB.pls 120.13.12010000.3 2008/10/17 07:57:01 smrsharm ship $ */
	/***************************************************************************
	--
	--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
	--  All rights reserved.
	--
	--  FILENAME
	--
	--      EAMVSBUB.pls
	--
	--  DESCRIPTION
	--
	--
	--  NOTES
	--
	--  HISTORY
	--  120.0 - Initial Creation
	--  120.1 - Modified call to various procedures wherein IN and OUT params were being passed as the same variable.
	--              Added code to write into eAM debug file . Added review comment for updating WHO columns during DML
	--  120.2 - Added procedure update_instance_usage to update instance usage records when updating instance dates.
	--		Also added code to check if record exists in woru when inserting an instance record in woru.
	--		Added code to update usage record in WORU for a resource having multiple rows only when expanding the resource dates.
	--  120.3 - Changes for accounting period cursor check.
	--  120.4 - Accounting period check rectified.
	--  120.5 - Changes for instance usage records. removed commented and debug statements.
	--  120.6 - Changes to support shift work order functionality. Remove all usage records to be updated from database
	--		and re-insert these records again.
	--		Populate first_unit_completion_date and last_unit_start_date in WO table too. Needed for forms lock_row.
	--		Moved code to sync up wori and wor with woru at the end of update_resource_usage procedure.
	--  3/8/2005 Prashant Kathotia Initial Creation
	--  08/15/2006 - Changes for Bug 5408720 - Anju Gupta
	***************************************************************************/

	/*************************************************************************************************************************
			* Procedure     : update_resource
			* Parameters IN :
							p_curr_inst_rec
							p_eam_res_tbl

			* Parameters OUT NOCOPY:
							x_eam_res_tbl
							x_return_status
			* Purpose       : Procedure will propagate changes from instance level to resource level during
						Bottom Up Scheduling.
		  ************************************************************************************************************************/
		procedure update_resource( p_curr_inst_rec	IN EAM_PROCESS_WO_PUB.eam_res_inst_rec_type,
							  p_eam_res_tbl		IN EAM_PROCESS_WO_PUB.eam_res_tbl_type,
							  x_eam_res_tbl		OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type,
							  x_return_status	OUT NOCOPY VARCHAR2 ) IS


			l_resource_rec		EAM_PROCESS_WO_PUB.eam_res_rec_type;
			l_wip_id			NUMBER ;
			l_op_seq_num		NUMBER ;
			l_org_id			NUMBER ;
			l_res_seq_num		NUMBER ;
			l_inst_start_date	DATE ;
			l_inst_end_date		DATE ;
			l_eam_res_tbl		EAM_PROCESS_WO_PUB.eam_res_tbl_type ;
			l_res_rec_found		VARCHAR2(1) ;
			l_change_date		VARCHAR2(1) ;
			l_res_start_date	DATE;
			l_res_end_date		DATE;
			l_return_status		VARCHAR2(1) ;
			l_eam_res_tbl_index	NUMBER;
		BEGIN

			-- Initialize variables
			l_wip_id			:= p_curr_inst_rec.wip_entity_id ;
			l_op_seq_num		:= p_curr_inst_rec.operation_seq_num ;
			l_org_id			:= p_curr_inst_rec.organization_id ;
			l_res_seq_num		:= p_curr_inst_rec.resource_seq_num ;
			l_inst_start_date	:= p_curr_inst_rec.start_date ;
			l_inst_end_date		:= p_curr_inst_rec.completion_date ;
			l_eam_res_tbl		:= p_eam_res_tbl ;
			l_return_status		:= FND_API.G_RET_STS_SUCCESS;

			x_return_status := l_return_status ;

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Inside update_resource ') ; END IF ;

			l_eam_res_tbl_index := l_eam_res_tbl.FIRST;

			WHILE l_eam_res_tbl_index IS NOT NULL LOOP

				IF ( l_eam_res_tbl(l_eam_res_tbl_index).wip_entity_id = l_wip_id AND l_eam_res_tbl(l_eam_res_tbl_index).operation_seq_num = l_op_seq_num AND
						l_eam_res_tbl(l_eam_res_tbl_index).resource_seq_num = l_res_seq_num) THEN

					l_res_rec_found := 'Y';


					IF ( l_inst_start_date < l_eam_res_tbl(l_eam_res_tbl_index).start_date ) THEN
						l_eam_res_tbl(l_eam_res_tbl_index).start_date := l_inst_start_date ;
						l_res_start_date := l_inst_start_date;
						l_res_end_date := l_eam_res_tbl(l_eam_res_tbl_index).completion_date;
						l_change_date := 'Y' ;
					END IF;

					IF ( l_inst_end_date > l_eam_res_tbl(l_eam_res_tbl_index).completion_date ) THEN
						l_eam_res_tbl(l_eam_res_tbl_index).completion_date := l_inst_end_date ;
						l_res_end_date := l_inst_end_date;
						l_res_start_date := l_eam_res_tbl(l_eam_res_tbl_index).start_date;
						l_change_date := 'Y' ;
					END IF;

				END IF;

				l_eam_res_tbl_index := l_eam_res_tbl.NEXT(l_eam_res_tbl_index);

			END LOOP; -- end loop through l_eam_res_tbl

			IF ( NVL( l_res_rec_found, 'N') = 'N' )THEN

				EAM_RES_UTILITY_PVT.Query_Row ( l_wip_id ,
											l_org_id,
											l_op_seq_num,
											l_res_seq_num,
											l_resource_rec,
											l_return_status) ;

				l_resource_rec.wip_entity_id := l_wip_id ;
				l_resource_rec.organization_id := l_org_id ;
				l_resource_rec.operation_seq_num  := l_op_seq_num ;
				l_resource_rec.resource_seq_num  := l_res_seq_num ;

				IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
					RAISE FND_API.G_EXC_ERROR ;
				END IF;

				l_resource_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
				l_eam_res_tbl( l_eam_res_tbl.COUNT+1) := l_resource_rec ;
				l_res_end_date := l_resource_rec.completion_date;
				l_res_start_date := l_resource_rec.start_date;

				IF (  l_res_start_date > l_inst_start_date) THEN
					l_eam_res_tbl( l_eam_res_tbl.LAST).start_date := l_inst_start_date ;
					l_res_start_date := l_inst_start_date;
					l_change_date := 'Y' ;
				END IF;

				IF ( l_res_end_date < l_inst_end_date ) THEN
					l_eam_res_tbl( l_eam_res_tbl.LAST).completion_date := l_inst_end_date;
					l_res_end_date := l_inst_end_date;
					l_change_date := 'Y';
				END IF;

			END IF;

			IF ( NVL( l_change_date, 'N' ) = 'Y' ) THEN

				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Updating WOR ') ; END IF ;

				UPDATE	wip_operation_resources
				      SET	start_date	= l_res_start_date ,
						completion_date = l_res_end_date ,
						last_update_date = sysdate ,
						last_updated_by = FND_GLOBAL.user_id ,
						creation_date = sysdate ,
						created_by = FND_GLOBAL.user_id ,
						last_update_login = FND_GLOBAL.login_id
				 WHERE	wip_entity_id = l_wip_id
				      AND	operation_seq_num = l_op_seq_num
				      AND	resource_seq_num = l_res_seq_num;

				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Updating WORU start date  for resource') ; END IF ;

				UPDATE	wip_operation_resource_usage
				      SET	start_date = l_res_start_date ,
						last_update_date = sysdate ,
						last_updated_by = FND_GLOBAL.user_id ,
						creation_date = sysdate ,
						created_by = FND_GLOBAL.user_id ,
						last_update_login = FND_GLOBAL.login_id
				 WHERE	wip_entity_id = l_wip_id
				      AND	operation_seq_num = l_op_seq_num
				      AND	resource_seq_num = l_res_seq_num
				      AND	start_date = (	SELECT	MIN(start_date)
									  FROM	wip_operation_resource_usage
									WHERE	wip_entity_id = l_wip_id
									     AND	operation_seq_num = l_op_seq_num
									    AND	resource_seq_num = l_res_seq_num
									    AND	instance_id IS NULL
									    AND	serial_number IS NULL)
				      AND	instance_id IS NULL
				      AND	serial_number IS NULL;

				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Updating WORU end date  for resource') ; END IF ;

				UPDATE	wip_operation_resource_usage
				      SET	completion_date = l_res_end_date ,
						last_update_date = sysdate ,
						last_updated_by = FND_GLOBAL.user_id ,
						creation_date = sysdate ,
						created_by = FND_GLOBAL.user_id ,
						last_update_login = FND_GLOBAL.login_id
				 WHERE	wip_entity_id = l_wip_id
				      AND	operation_seq_num = l_op_seq_num
				      AND	resource_seq_num = l_res_seq_num
				      AND	completion_date = (	SELECT	MAX(completion_date)
										  FROM	wip_operation_resource_usage
										WHERE	wip_entity_id = l_wip_id
										     AND	operation_seq_num = l_op_seq_num
										     AND	resource_seq_num = l_res_seq_num
										     AND	instance_id IS NULL
										     AND	serial_number IS NULL)
				      AND	instance_id IS NULL
				      AND	serial_number IS NULL;

			END IF ;

			x_eam_res_tbl := l_eam_res_tbl;
			x_return_status := l_return_status ;

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Exiting update_resource ') ; END IF ;
		EXCEPTION
				WHEN FND_API.G_EXC_ERROR THEN

					x_return_status := l_return_status ;
		END update_resource;


		/*************************************************************************************************************************
			* Procedure     : update_operations
			* Parameters IN :
							p_curr_res_rec
							p_eam_op_tbl

			* Parameters OUT NOCOPY:
							x_eam_op_tbl
							x_return_status

			* Purpose       : Procedure will propagate changes from resource level to operations level during
						Bottom Up Scheduling.
		  ************************************************************************************************************************/


		procedure 	update_operations ( p_curr_res_rec    IN EAM_PROCESS_WO_PUB.eam_res_rec_type,
							       p_eam_op_tbl	IN EAM_PROCESS_WO_PUB.eam_op_tbl_type,
							       x_eam_op_tbl	OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type,
							       x_return_status	OUT NOCOPY VARCHAR2 ) IS

			l_operation_rec		EAM_PROCESS_WO_PUB.eam_op_rec_type ;
			l_wip_id			NUMBER ;
			l_org_id			NUMBER ;
			l_op_seq_num		NUMBER ;
			l_eam_op_tbl		EAM_PROCESS_WO_PUB.eam_op_tbl_type ;
			l_op_rec_found		VARCHAR2(1);
			l_res_start_date	DATE ;
			l_res_end_date		DATE ;
			l_op_start_date		DATE;
			l_op_end_date		DATE;
			l_change_date		VARCHAR2(1);
			l_return_status		VARCHAR2(1) ;
			l_eam_op_tbl_index	NUMBER;

		BEGIN

			-- Initialize variables
			l_wip_id			:= p_curr_res_rec.wip_entity_id ;
			l_org_id			:= p_curr_res_rec.organization_id ;
			l_op_seq_num		:= p_curr_res_rec.operation_seq_num ;
			l_eam_op_tbl		:= p_eam_op_tbl ;

			l_res_start_date	:= p_curr_res_rec.start_date;
			l_res_end_date		:= p_curr_res_rec.completion_date;
			l_return_status		:= FND_API.G_RET_STS_SUCCESS;


			x_return_status := l_return_status;
			l_eam_op_tbl_index := l_eam_op_tbl.FIRST;

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Inside update_operations ') ; END IF ;

			WHILE l_eam_op_tbl_index IS NOT NULL LOOP

				IF ( l_eam_op_tbl(l_eam_op_tbl_index).wip_entity_id = l_wip_id AND l_eam_op_tbl(l_eam_op_tbl_index).operation_seq_num = l_op_seq_num ) THEN

					l_op_rec_found := 'Y';

					IF ( l_res_start_date < l_eam_op_tbl(l_eam_op_tbl_index).start_date ) THEN
						l_eam_op_tbl(l_eam_op_tbl_index).start_date := l_res_start_date ;
						l_op_start_date := l_res_start_date;
						l_op_end_date  := l_eam_op_tbl(l_eam_op_tbl_index).completion_date ;
						l_change_date := 'Y';
					END IF;

					IF ( l_res_end_date > l_eam_op_tbl(l_eam_op_tbl_index).completion_date ) THEN
						l_eam_op_tbl(l_eam_op_tbl_index).completion_date := l_res_end_date ;
						l_op_start_date := l_eam_op_tbl(l_eam_op_tbl_index).start_date ;
						l_op_end_date  := l_res_end_date ;
						l_change_date := 'Y';
					END IF;

				END IF;

				l_eam_op_tbl_index := l_eam_op_tbl.NEXT(l_eam_op_tbl_index);

			END LOOP; -- end loop through l_eam_op_tbl

			IF ( NVL( l_op_rec_found, 'N' ) = 'N' ) THEN

				EAM_OP_UTILITY_PVT.query_row( l_wip_id ,
										   l_org_id ,
										   l_op_seq_num ,
										   l_operation_rec ,
										   l_return_status );

				l_operation_rec.wip_entity_id := l_wip_id ;
				l_operation_rec.organization_id  := l_org_id ;
				l_operation_rec.operation_seq_num := l_op_seq_num ;


				IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
					RAISE FND_API.G_EXC_ERROR ;
				END IF;

				l_operation_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
				l_eam_op_tbl( l_eam_op_tbl.COUNT+1) := l_operation_rec;
				l_op_start_date := l_operation_rec.start_date ;
				l_op_end_date := l_operation_rec.completion_date ;

				IF ( l_op_start_date > l_res_start_date) THEN
					l_eam_op_tbl( l_eam_op_tbl.LAST).start_date := l_res_start_date ;
					l_op_start_date := l_res_start_date;
					l_change_date := 'Y' ;
				END IF;

				IF ( l_op_end_date < l_res_end_date ) THEN
					l_eam_op_tbl( l_eam_op_tbl.LAST).completion_date := l_res_end_date;
					l_op_end_date := l_res_end_date;
					l_change_date := 'Y';
				END IF;

			END IF;

			IF ( NVL( l_change_date, 'N' ) = 'Y' ) THEN

				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Updating Wip_operations ') ; END IF ;

				UPDATE	wip_operations
				      SET	first_unit_start_date = l_op_start_date,
						first_unit_completion_date = l_op_end_date,
						last_unit_start_date = l_op_start_date,
						last_unit_completion_date = l_op_end_date ,
						last_update_date = sysdate ,
						last_updated_by = FND_GLOBAL.user_id ,
						creation_date = sysdate ,
						created_by = FND_GLOBAL.user_id ,
						last_update_login = FND_GLOBAL.login_id
				 WHERE	wip_entity_id = l_wip_id
				      AND	operation_seq_num = l_op_seq_num ;
			END IF ;

			x_eam_op_tbl := l_eam_op_tbl;
			x_return_status := l_return_status ;

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Exiting update_operations ') ; END IF ;
		EXCEPTION
				WHEN FND_API.G_EXC_ERROR THEN
					x_return_status := l_return_status ;
		END update_operations;


		/*************************************************************************************************************************
			* Procedure     : update_workorder
			* Parameters IN :
							p_curr_op_rec
							p_eam_wo_rec

			* Parameters OUT NOCOPY:
							x_eam_wo_rec
							x_return_status

			* Purpose       : Procedure will propagate changes from operations level to work order level during
						Bottom Up Scheduling.
		  ************************************************************************************************************************/



		procedure 	update_workorder( p_curr_op_rec	IN EAM_PROCESS_WO_PUB.eam_op_rec_type,
							     p_eam_wo_rec	IN EAM_PROCESS_WO_PUB.eam_wo_rec_type,
							     x_eam_wo_rec	OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type,
						             x_return_status	OUT NOCOPY VARCHAR2 ) IS

			l_op_start_date		DATE ;
			l_op_end_date		DATE ;
			l_wo_start_date		DATE ;
			l_wo_end_date		DATE ;
			l_eam_wo_rec		EAM_PROCESS_WO_PUB.eam_wo_rec_type ;
			l_wo_date_change	VARCHAR2(1) ;
			l_return_status		VARCHAR2(1);
			--l_wo_req_start_date	DATE ;
			--l_wo_due_date		DATE ;

		BEGIN
			-- Initialize variables
			l_op_start_date		:= p_curr_op_rec.start_date;
			l_op_end_date		:= p_curr_op_rec.completion_date;
			l_eam_wo_rec		:= p_eam_wo_rec;
			l_return_status		:= FND_API.G_RET_STS_SUCCESS;

			x_return_status := l_return_status ;

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Inside update_workorder ') ; END IF ;

			IF ( l_eam_wo_rec.transaction_type IS NULL ) THEN -- query up from DB
				EAM_WO_UTILITY_PVT.Query_Row ( p_curr_op_rec.wip_entity_id ,
											p_curr_op_rec.organization_id ,
											l_eam_wo_rec ,
											l_return_status );

				l_eam_wo_rec.wip_entity_id := p_curr_op_rec.wip_entity_id ;
				l_eam_wo_rec.organization_id := p_curr_op_rec.organization_id ;

			END IF;

			IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
				RAISE FND_API.G_EXC_ERROR ;
			END IF;

			l_wo_start_date := l_eam_wo_rec.scheduled_start_date ;
			l_wo_end_date :=  l_eam_wo_rec.scheduled_completion_date ;

			IF ( l_eam_wo_rec.scheduled_start_date > l_op_start_date ) THEN
				l_wo_start_date := l_op_start_date;
				l_wo_date_change := 'Y';
			END IF ;

			IF ( l_eam_wo_rec.scheduled_completion_date < l_op_end_date ) THEN
				l_wo_end_date := l_op_end_date;
				l_wo_date_change := 'Y';
			END IF ;

			IF ( NVL( l_wo_date_change , 'N' ) = 'Y' ) THEN

				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Updating WDJ') ; END IF ;

				UPDATE	wip_discrete_jobs
				      SET	scheduled_start_date = l_wo_start_date,
						scheduled_completion_date = l_wo_end_date ,
						last_update_date = sysdate ,
						last_updated_by = FND_GLOBAL.user_id ,
						creation_date = sysdate ,
						created_by = FND_GLOBAL.user_id ,
						last_update_login = FND_GLOBAL.login_id
				 WHERE	wip_entity_id = p_curr_op_rec.wip_entity_id
				      AND	organization_id = p_curr_op_rec.organization_id ;


				l_eam_wo_rec.scheduled_start_date := l_wo_start_date;
				l_eam_wo_rec.scheduled_completion_date := l_wo_end_date;
			END IF;

			x_eam_wo_rec := l_eam_wo_rec;
			x_return_status := l_return_status ;
			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Exiting update_workorder') ; END IF ;

		EXCEPTION
				WHEN FND_API.G_EXC_ERROR THEN
					x_return_status := l_return_status ;

		END update_workorder;


		/*************************************************************************************************************************
			* Procedure     : schedule_bottom_up_pvt
			* Parameters IN : 	p_commit
						p_wip_entity_id
                				p_org_id
						p_woru_modified

			* Parameters OUT NOCOPY:

							x_return_status
							x_message_name

			* Purpose       : Procedure will do Bottom Up Scheduling for a firm work order and for
						DS Scheduled work orders

			* History - Anju Gupta -
			            Modified for bug 5408720 - The procedure now only takes in the wip_entity_id and schedules the entire
			            structure of the work order, adjusting each level in a bottom-up fashion
		  ************************************************************************************************************************/


        	procedure schedule_bottom_up_pvt (
			   p_api_version_number      IN  NUMBER
			 , p_commit                  IN  VARCHAR2
			 , p_wip_entity_id           IN  NUMBER
			 , p_org_id                  IN  NUMBER
			 , p_woru_modified           IN  VARCHAR2
			 , x_return_status           OUT NOCOPY VARCHAR2
			 , x_message_name	         OUT NOCOPY VARCHAR2
			 ) IS

			CURSOR	get_opresource_csr( c_wip_entity_id NUMBER) IS
			 SELECT	start_date,
					completion_date,
					operation_seq_num,
					resource_seq_num
			   FROM	wip_operation_resources
			 WHERE	wip_entity_id = c_wip_entity_id;

			CURSOR	get_inst_usage_min_date( c_wip_entity_id NUMBER, c_op_seq_num NUMBER , c_res_seq_num NUMBER ) IS
				SELECT	MIN(start_date) as min_inst_usg_date
		  		FROM	wip_operation_resource_usage
				WHERE	wip_entity_id = c_wip_entity_id
		     	AND	operation_seq_num = c_op_seq_num
		    	AND	resource_seq_num = c_res_seq_num
		    	AND	(instance_id IS NOT NULL OR serial_number IS not NULL) ;

		CURSOR	get_inst_usage_max_date( c_wip_entity_id NUMBER, c_op_seq_num NUMBER , c_res_seq_num NUMBER ) IS
		SELECT	MAX(completion_date) as max_inst_usg_date
		  FROM	wip_operation_resource_usage
		WHERE	wip_entity_id = c_wip_entity_id
		     AND	operation_seq_num = c_op_seq_num
		    AND	resource_seq_num = c_res_seq_num
		     AND	(instance_id is not null OR serial_number IS not NULL) ;

		CURSOR	get_woru_min_date( c_wip_entity_id NUMBER, c_op_seq_num NUMBER , c_res_seq_num NUMBER ,
								c_instance_id NUMBER , c_serial_num VARCHAR2 ) IS
		SELECT	MIN(start_date) as min_inst_usg_date
		  FROM	wip_operation_resource_usage
		WHERE	wip_entity_id = c_wip_entity_id
		     AND	operation_seq_num = c_op_seq_num
		    AND	resource_seq_num = c_res_seq_num
		    AND	instance_id = c_instance_id
		    AND	( serial_number IS NULL OR serial_number = c_serial_num);

		CURSOR	get_woru_max_date( c_wip_entity_id NUMBER, c_op_seq_num NUMBER , c_res_seq_num NUMBER ,
								c_instance_id NUMBER , c_serial_num VARCHAR2 ) IS
		SELECT	MAX(completion_date) as max_inst_usg_date
		  FROM	wip_operation_resource_usage
		WHERE	wip_entity_id = c_wip_entity_id
		     AND	operation_seq_num = c_op_seq_num
		    AND	resource_seq_num = c_res_seq_num
		    AND	instance_id = c_instance_id
		    AND	( serial_number IS NULL OR serial_number = c_serial_num);

		CURSOR	get_res_usage_min_date( c_wip_entity_id NUMBER, c_op_seq_num NUMBER , c_res_seq_num NUMBER ) IS
		SELECT	MIN(start_date) as min_res_usg_date
		  FROM	wip_operation_resource_usage
		WHERE	wip_entity_id = c_wip_entity_id
		     AND	operation_seq_num = c_op_seq_num
		    AND	resource_seq_num = c_res_seq_num
		    AND	instance_id IS NULL
		    AND	serial_number IS NULL ;

		CURSOR	get_res_usage_max_date( c_wip_entity_id NUMBER, c_op_seq_num NUMBER , c_res_seq_num NUMBER ) IS
		SELECT	MAX(completion_date) as max_inst_usg_date
		  FROM	wip_operation_resource_usage
		WHERE	wip_entity_id = c_wip_entity_id
		     AND	operation_seq_num = c_op_seq_num
		    AND	resource_seq_num = c_res_seq_num
		    AND	instance_id IS NULL
		    AND	serial_number IS NULL ;

		    	CURSOR	get_instdates( c_wip_entity_id NUMBER, c_op_seq_num NUMBER , c_res_seq_num NUMBER ) IS
     SELECT	 start_date, completion_date, instance_id, serial_number
	  	FROM wip_operation_resource_usage
	    WHERE	wip_entity_id = c_wip_entity_id
				AND	operation_seq_num = c_op_seq_num
				AND	resource_seq_num = c_res_seq_num;

			CURSOR	get_op_dates_csr( p_wip_entity_id NUMBER) IS
			 SELECT	operation_seq_num, first_unit_start_date,
					last_unit_completion_date
			   FROM	wip_operations
			 WHERE	wip_entity_id = p_wip_entity_id;

			CURSOR	get_wo_dates_csr( p_wip_entity_id NUMBER ) IS
			 SELECT	scheduled_start_date,
					scheduled_completion_date
			   FROM	wip_discrete_jobs
			 WHERE	wip_entity_id = p_wip_entity_id;

			 /* Define local variables */
			 l_return_status varchar2(1);
			 c_resusagemin_date Date;
			 c_resusagemax_date Date;
			 c_instusage_min_date Date;
			 c_instusage_max_date Date;
			 c_instusagemin_date Date;
			 c_instusagemax_date Date;
			 l_min_res_date Date;
			 l_max_res_date Date;
			 l_min_date Date;
			 l_max_date Date;
			 l_scheduled_start_date Date;
			 l_scheduled_completion_date Date;


		BEGIN
			-- Initialize variables

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Entering schedule_bottom_up_pvt ') ; END IF ;

			SAVEPOINT SCHED_BOTTOM_UP;

			l_return_status				:= FND_API.G_RET_STS_SUCCESS;
			x_return_status := l_return_status ;

			--/* Get the various operations and associated resources in the WO
			FOR c_opresource_rec IN get_opresource_csr(p_wip_entity_id) LOOP

				--/* Get WORU Dates for the Resource Usage
				open get_res_usage_min_date( p_wip_entity_id, c_opresource_rec.operation_seq_num , c_opresource_rec.resource_seq_num );
				FETCH get_res_usage_min_date INTO c_resusagemin_date;
				close get_res_usage_min_date;

				open get_res_usage_max_date( p_wip_entity_id, c_opresource_rec.operation_seq_num , c_opresource_rec.resource_seq_num );
				FETCH get_res_usage_max_date INTO c_resusagemax_date;
				close get_res_usage_max_date;

				--/* Get WORU Dates for the Instance Usage
				open  get_inst_usage_min_date( p_wip_entity_id, c_opresource_rec.operation_seq_num , c_opresource_rec.resource_seq_num );
				FETCH get_inst_usage_min_date INTO c_instusage_min_date;
				close get_inst_usage_min_date;

				open  get_inst_usage_max_date( p_wip_entity_id, c_opresource_rec.operation_seq_num , c_opresource_rec.resource_seq_num );
				FETCH get_inst_usage_max_date INTO c_instusage_max_date;
				close get_inst_usage_max_date;

			  IF  p_woru_modified = 'Y' THEN

				--/* Adjust WORU and WORU' dates
				IF c_instusage_min_date < c_resusagemin_date THEN
					UPDATE wip_operation_resource_usage
					SET start_date = c_instusage_min_date
					WHERE wip_entity_id = p_wip_entity_id
		     		AND	operation_seq_num = c_opresource_rec.operation_seq_num
		            AND	resource_seq_num = c_opresource_rec.resource_seq_num
		            AND	instance_id IS NULL
		            AND	serial_number IS NULL
					AND rownum = 1;

				    c_resusagemin_date := c_instusage_min_date;
					--l_resourcemin_expanded = 1;
				END IF;

				IF c_instusage_max_date > c_resusagemax_date THEN
					UPDATE wip_operation_resource_usage
					SET completion_date = c_instusage_max_date
					WHERE wip_entity_id = p_wip_entity_id
		     		AND	operation_seq_num = c_opresource_rec.operation_seq_num
		            AND	resource_seq_num = c_opresource_rec.resource_seq_num
		            AND	instance_id IS NULL
		            AND	serial_number IS NULL
					AND rownum = 1;

					c_resusagemax_date := c_instusage_max_date;
				    --l_resourcemax_expanded = 1;
				END IF;

				--/* Adjust WORU' and WORI dates
				FOR c_instdates_rec IN get_instdates(p_wip_entity_id , c_opresource_rec.operation_seq_num, c_opresource_rec.resource_seq_num )
				LOOP
						open  get_woru_min_date(p_wip_entity_id, c_opresource_rec.operation_seq_num , c_opresource_rec.resource_seq_num,
						                            c_instdates_rec.instance_id, c_instdates_rec.serial_number );
						FETCH get_woru_min_date INTO c_instusagemin_date;
						close get_woru_min_date;

						open  get_woru_max_date(p_wip_entity_id, c_opresource_rec.operation_seq_num , c_opresource_rec.resource_seq_num,
						                            c_instdates_rec.instance_id, c_instdates_rec.serial_number );
						FETCH get_woru_max_date INTO c_instusagemax_date;
						close get_woru_max_date;

						IF c_instusagemin_date < c_instdates_rec.start_date THEN
							UPDATE	wip_op_resource_instances
					      	SET	start_date = c_instusagemin_date,
							last_update_date = sysdate ,
							last_updated_by = FND_GLOBAL.user_id ,
							last_update_login = FND_GLOBAL.login_id
					 		WHERE	wip_entity_id = p_wip_entity_id
					      	AND	operation_seq_num = c_opresource_rec.operation_seq_num
					      	AND	resource_seq_num = c_opresource_rec.resource_seq_num
					      	AND	instance_id = c_instdates_rec.instance_id
					      	AND       (serial_number IS NULL OR (serial_number = c_instdates_rec.serial_number));
						END IF;

						IF c_instusagemax_date > c_instdates_rec.completion_date THEN
							UPDATE	wip_op_resource_instances
					      	SET	completion_date = c_instusagemax_date,
							last_update_date = sysdate ,
							last_updated_by = FND_GLOBAL.user_id ,
							last_update_login = FND_GLOBAL.login_id
					 		WHERE	wip_entity_id = p_wip_entity_id
					      	AND	operation_seq_num = c_opresource_rec.operation_seq_num
					      	AND	resource_seq_num = c_opresource_rec.resource_seq_num
					      	AND	instance_id = c_instdates_rec.instance_id
					      	AND       (serial_number IS NULL OR (serial_number = c_instdates_rec.serial_number));
						END IF;

				END LOOP;


				--/* Adjust WORU and WOR dates
				IF c_resusagemin_date < c_opresource_rec.start_date THEN
					UPDATE	wip_operation_resources
				    SET	start_date = c_resusagemin_date,
					last_update_date = sysdate ,
					last_updated_by = FND_GLOBAL.user_id ,
					last_update_login = FND_GLOBAL.login_id
				 	WHERE	wip_entity_id = p_wip_entity_id
				      AND	operation_seq_num = c_opresource_rec.operation_seq_num
				      AND	organization_id = p_org_id
				      AND	resource_seq_num = c_opresource_rec.resource_seq_num ;


				END IF;

				IF c_resusagemax_date > c_opresource_rec.completion_date THEN
					UPDATE	wip_operation_resources
				    SET	completion_date = c_resusagemax_date,
					last_update_date = sysdate ,
					last_updated_by = FND_GLOBAL.user_id ,
					last_update_login = FND_GLOBAL.login_id
				 	WHERE	wip_entity_id = p_wip_entity_id
				      AND	operation_seq_num = c_opresource_rec.operation_seq_num
				      AND	organization_id = p_org_id
				      AND	resource_seq_num = c_opresource_rec.resource_seq_num ;

				END IF;

			 END IF;

			END LOOP;

			--/* Adjust WOR and WO dates

			FOR	c_operation_rec IN get_op_dates_csr( p_wip_entity_id) LOOP
				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
					EAM_ERROR_MESSAGE_PVT.Write_Debug(' Adjusting operation dates ') ;
					EAM_ERROR_MESSAGE_PVT.Write_Debug(' op date ' || c_operation_rec.last_unit_completion_date) ;
				END IF ;

				select min(start_date), max(completion_date)
				into l_min_res_date, l_max_res_date
				from wip_operation_resources
				where wip_entity_id = p_wip_entity_id
				and operation_seq_num = c_operation_rec.operation_seq_num;

				IF l_min_res_date <> c_operation_rec.first_unit_start_date THEN /*Bug 7336817*/
					UPDATE	wip_operations
				    SET	first_unit_start_date = l_min_res_date,
					last_unit_start_date = l_min_res_date,
					last_update_date = sysdate ,
					last_updated_by = FND_GLOBAL.user_id ,
					last_update_login = FND_GLOBAL.login_id
				 	WHERE	wip_entity_id = p_wip_entity_id
				    AND	operation_seq_num = c_operation_rec.operation_seq_num ;

				END IF;

					IF l_max_res_date <> c_operation_rec.last_unit_completion_date THEN /*Bug 7336817*/
					UPDATE	wip_operations
				    SET	first_unit_completion_date = l_max_res_date ,
					last_unit_completion_date = l_max_res_date ,
					last_update_date = sysdate ,
					last_updated_by = FND_GLOBAL.user_id ,
					last_update_login = FND_GLOBAL.login_id
				 	WHERE	wip_entity_id = p_wip_entity_id
				    AND	operation_seq_num = c_operation_rec.operation_seq_num ;

				END IF;

			END LOOP;

			--/* Adjust WO and WDJ dates
			OPEN get_wo_dates_csr( p_wip_entity_id);
			FETCH get_wo_dates_csr into l_scheduled_start_date, l_scheduled_completion_date;
			CLOSE get_wo_dates_csr;

				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
					EAM_ERROR_MESSAGE_PVT.Write_Debug(' Adjusting WO dates ') ;
				END IF ;

				select min(first_unit_start_date), max(last_unit_completion_date)
				into l_min_date, l_max_date
				from wip_operations
				where wip_entity_id = p_wip_entity_id;

				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
					EAM_ERROR_MESSAGE_PVT.Write_Debug(' op start dates ' || l_min_date) ;
					EAM_ERROR_MESSAGE_PVT.Write_Debug(' op end dates ' || l_max_date) ;
					EAM_ERROR_MESSAGE_PVT.Write_Debug(' wo end dates ' || l_scheduled_completion_date) ;
				END IF ;

				IF l_min_date < l_scheduled_start_date THEN
						UPDATE	wip_discrete_jobs
				        SET	scheduled_start_date = l_min_date,
						last_update_date = sysdate ,
						last_updated_by = FND_GLOBAL.user_id ,
						last_update_login = FND_GLOBAL.login_id
				 		WHERE	wip_entity_id = p_wip_entity_id
				      	AND	organization_id = p_org_id ;

				END IF;

				IF l_max_date > l_scheduled_completion_date THEN
						IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
							EAM_ERROR_MESSAGE_PVT.Write_Debug(' Updating WO completion date ') ;
						END IF ;

						UPDATE	wip_discrete_jobs
				        SET	scheduled_completion_date = l_max_date,
						last_update_date = sysdate ,
						last_updated_by = FND_GLOBAL.user_id ,
						last_update_login = FND_GLOBAL.login_id
				 		WHERE	wip_entity_id = p_wip_entity_id
				      	AND	organization_id = p_org_id ;

				END IF;


		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Exiting schedule_bottom_up_pvt ') ; END IF ;

		EXCEPTION

			WHEN FND_API.G_EXC_ERROR THEN
				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Error occured in schedule_bottom_up_pvt API ') ; END IF ;
				x_return_status	:= FND_API.G_RET_STS_ERROR ;
				x_message_name := ' EAM_SCHED_BOTTOMUP_ERR';

		END schedule_bottom_up_pvt ;


		/*************************************************************************************************************************
			* Procedure		: insert_into_woru
			* Parameters IN		: p_eam_res_usage_rec
			* Parameters OUT	: x_return_status
			* Purpose			: Inserts a resource usage record in wip_operation_resource_usage table
		  ************************************************************************************************************************/

		procedure	 insert_into_woru ( p_eam_res_usage_rec	IN EAM_PROCESS_WO_PUB.eam_res_usage_rec_type,
							     x_return_status		OUT NOCOPY VARCHAR2 ) IS

		CURSOR	res_usage_rec_check_csr	 IS
		 SELECT	1
		   FROM	WIP_OPERATION_RESOURCE_USAGE
		 WHERE	wip_entity_id = p_eam_res_usage_rec.wip_entity_id
		      AND	operation_seq_num = p_eam_res_usage_rec.operation_seq_num
		      AND	resource_seq_num = p_eam_res_usage_rec.resource_seq_num
		      AND	start_date = p_eam_res_usage_rec.start_date
		      AND	completion_date = p_eam_res_usage_rec.completion_date
		      AND	instance_id IS NULL
		      AND	serial_number IS NULL ;

		CURSOR	inst_usage_rec_check_csr	 IS
		 SELECT	1
		   FROM	WIP_OPERATION_RESOURCE_USAGE
		 WHERE	wip_entity_id = p_eam_res_usage_rec.wip_entity_id
		      AND	operation_seq_num = p_eam_res_usage_rec.operation_seq_num
		      AND	resource_seq_num = p_eam_res_usage_rec.resource_seq_num
		      AND	start_date = p_eam_res_usage_rec.start_date
		      AND	completion_date = p_eam_res_usage_rec.completion_date
		      AND	instance_id = p_eam_res_usage_rec.instance_id
		      AND	( serial_number IS NULL OR  serial_number = p_eam_res_usage_rec.serial_number );

		l_rec_exists		NUMBER;
		l_return_status		VARCHAR2(1) ;

		BEGIN

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Inside  insert_into_woru' ) ; END IF ;

			l_return_status := FND_API.G_RET_STS_SUCCESS ;
			x_return_status := l_return_status ;
			l_rec_exists := 2 ;

			IF ( p_eam_res_usage_rec.instance_id IS NULL ) THEN -- ckeck if recource record has already been inserted
				OPEN	 res_usage_rec_check_csr;
				FETCH res_usage_rec_check_csr INTO l_rec_exists;
				IF (res_usage_rec_check_csr%NOTFOUND) THEN
					l_rec_exists := 0;
				END IF;
				CLOSE res_usage_rec_check_csr;
			ELSE
				OPEN	 inst_usage_rec_check_csr;
				FETCH inst_usage_rec_check_csr INTO l_rec_exists;
				IF (inst_usage_rec_check_csr%NOTFOUND) THEN
					l_rec_exists := 0;
				END IF;
				CLOSE inst_usage_rec_check_csr;
			END IF ;

			IF ( l_rec_exists = 0 ) THEN

				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Insert record in WORU ' ) ; END IF ;

				BEGIN
					INSERT INTO WIP_OPERATION_RESOURCE_USAGE
					     (   wip_entity_id
					       , operation_seq_num
					       , resource_seq_num
					       , organization_id
					       , start_date
					       , completion_date
					       , assigned_units
					       , instance_id
					       , serial_number
					       , last_update_date
					       , last_updated_by
					       , creation_date
					       , created_by
					       , last_update_login
					       , request_id
					       , program_application_id
					       , program_id
					       , program_update_date)
					VALUES
					      (  p_eam_res_usage_rec.wip_entity_id
					       , p_eam_res_usage_rec.operation_seq_num
					       , p_eam_res_usage_rec.resource_seq_num
					       , p_eam_res_usage_rec.organization_id
					       , p_eam_res_usage_rec.start_date
					       , p_eam_res_usage_rec.completion_date
					       , NVL( p_eam_res_usage_rec.assigned_units , 1 )
					       , p_eam_res_usage_rec.instance_id
					       , p_eam_res_usage_rec.serial_number
					       , SYSDATE
					       , FND_GLOBAL.user_id
					       , SYSDATE
					       , FND_GLOBAL.user_id
					       , FND_GLOBAL.login_id
					       , p_eam_res_usage_rec.request_id
					       , p_eam_res_usage_rec.program_application_id
					       , p_eam_res_usage_rec.program_id
					       , SYSDATE);

				EXCEPTION WHEN OTHERS THEN
					l_return_status := FND_API.G_RET_STS_ERROR ;
					IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Error occurred ' ||SQLERRM ) ; END IF ;
				END ;

			END IF; -- end of l_rec_exists

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Exiting insert_into_woru with status ' || l_return_status ) ; END IF ;
			x_return_status := l_return_status ;

		END	insert_into_woru;

		/*************************************************************************************************************************
		* Procedure	: update_woru
		* Parameters IN : p_eam_res_usage_rec
		* Purpose		: Table Handler :- Updates a resource usage record in wip_operation_resource_usage table
		  ************************************************************************************************************************/


		procedure	update_woru( p_eam_res_usage_rec	IN EAM_PROCESS_WO_PUB.eam_res_usage_rec_type) IS

		BEGIN
			IF p_eam_res_usage_rec.instance_id IS NULL THEN

				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Inside update_woru: Updating resource record ' ) ; END IF ;

				UPDATE		WIP_OPERATION_RESOURCE_USAGE
				      SET		start_date = p_eam_res_usage_rec.start_date ,
							completion_date = p_eam_res_usage_rec.completion_date ,
							last_update_date = sysdate ,
							last_updated_by = FND_GLOBAL.user_id ,
							creation_date = sysdate ,
							created_by = FND_GLOBAL.user_id ,
							last_update_login = FND_GLOBAL.login_id
				 WHERE		wip_entity_id = p_eam_res_usage_rec.wip_entity_id
				      AND		operation_seq_num = p_eam_res_usage_rec.operation_seq_num
				      AND		organization_id = p_eam_res_usage_rec.organization_id
				      AND		resource_seq_num = p_eam_res_usage_rec.resource_seq_num
				      AND		start_date = p_eam_res_usage_rec.old_start_date
				      AND		completion_date = p_eam_res_usage_rec.old_completion_date
				      AND		instance_id IS NULL ;
			ELSE
				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Inside update_woru: Updating resource Instance record ' ) ; END IF ;

				UPDATE		WIP_OPERATION_RESOURCE_USAGE
				      SET		start_date = p_eam_res_usage_rec.start_date ,
							completion_date = p_eam_res_usage_rec.completion_date ,
							last_update_date = sysdate ,
							last_updated_by = FND_GLOBAL.user_id ,
							creation_date = sysdate ,
							created_by = FND_GLOBAL.user_id ,
							last_update_login = FND_GLOBAL.login_id
				 WHERE		wip_entity_id = p_eam_res_usage_rec.wip_entity_id
				      AND		operation_seq_num = p_eam_res_usage_rec.operation_seq_num
				      AND		organization_id = p_eam_res_usage_rec.organization_id
				      AND		resource_seq_num = p_eam_res_usage_rec.resource_seq_num
				      AND		start_date = p_eam_res_usage_rec.old_start_date
				      AND		completion_date = p_eam_res_usage_rec.old_completion_date
				      AND		instance_id = p_eam_res_usage_rec.instance_id
				      AND               (serial_number IS NULL OR (serial_number = p_eam_res_usage_rec.serial_number));
			END IF;

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Exiting update_woru' ) ; END IF ;
		END	update_woru ;

		/*************************************************************************************************************************
		* Procedure	: delete_from_woru
		* Parameters IN : p_eam_res_usage_rec
		* Purpose		: Table Handler :- Deletes a resource usage record in wip_operation_resource_usage table
		  ************************************************************************************************************************/

		procedure	delete_from_woru( p_eam_res_usage_rec	IN EAM_PROCESS_WO_PUB.eam_res_usage_rec_type ) IS
		l_count                                 NUMBER;
		BEGIN

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Inside delete_from_woru' ) ; END IF ;

				DELETE FROM 		WIP_OPERATION_RESOURCE_USAGE
					  WHERE		wip_entity_id = p_eam_res_usage_rec.wip_entity_id
					       AND		operation_seq_num = p_eam_res_usage_rec.operation_seq_num
					       AND		organization_id = p_eam_res_usage_rec.organization_id
					       AND		resource_seq_num = p_eam_res_usage_rec.resource_seq_num
					       AND		start_date = p_eam_res_usage_rec.start_date
					       AND		completion_date = p_eam_res_usage_rec.completion_date
					       AND		instance_id = p_eam_res_usage_rec.instance_id
					       AND               (serial_number IS NULL OR (serial_number = p_eam_res_usage_rec.serial_number));
		 --check if no records in woru

				SELECT	count(*)
				   INTO	l_count
				FROM	wip_operation_resource_usage
				WHERE	wip_entity_id = p_eam_res_usage_rec.wip_entity_id
				     AND	operation_seq_num =p_eam_res_usage_rec.operation_seq_num
				     AND	organization_id = p_eam_res_usage_rec.organization_id
				     AND	resource_seq_num =  p_eam_res_usage_rec.resource_seq_num
				     AND	instance_id =  p_eam_res_usage_rec.instance_id
				     AND       (serial_number IS NULL OR (serial_number =  p_eam_res_usage_rec.serial_number));



                  -- If there are no rows in WORU for an employee then delete from WORI also

			IF (l_count=0 ) THEN

			               	DELETE FROM	wip_op_resource_instances
					WHERE	wip_entity_id =p_eam_res_usage_rec.wip_entity_id
					      AND	operation_seq_num = p_eam_res_usage_rec.operation_seq_num
					      AND	organization_id = p_eam_res_usage_rec.organization_id
					      AND	resource_seq_num =p_eam_res_usage_rec.resource_seq_num
					      AND	instance_id = p_eam_res_usage_rec.instance_id
					      AND       (serial_number IS NULL OR (serial_number = p_eam_res_usage_rec.serial_number));
		        END IF;

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Exiting delete_from_woru' ) ; END IF ;
		END	delete_from_woru ;


		/*************************************************************************************************************************
		* Procedure		:	update_wori
		* Parameters IN		:	p_eam_res_usage_rec
							p_eam_res_inst_tbl
		* Parameters OUT	:	x_eam_res_inst_tbl
							x_return_status
		* Purpose			:	Updates/Deletes record from wip_op_resource_instances table . Returns changed
							instance records in x_eam_res_inst_tbl.
		  ************************************************************************************************************************/

		procedure 	update_wori ( p_eam_res_usage_rec IN EAM_PROCESS_WO_PUB.eam_res_usage_rec_type
						    ,p_eam_res_inst_tbl     IN EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
						    ,x_eam_res_inst_tbl     OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
						    ,x_return_status	       OUT NOCOPY VARCHAR ) IS

			l_eam_res_inst_tbl		EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type ;
			l_eam_res_inst_rec		EAM_PROCESS_WO_PUB.eam_res_inst_rec_type ;
			l_min_start_date		DATE;
			l_max_completion_date	DATE;
			l_wip_entity_id			NUMBER ;
			l_operation_seq_num		NUMBER ;
			l_res_seq_num			NUMBER ;
			l_instance_id			NUMBER ;
			l_org_id				NUMBER ;
			l_serial_number			VARCHAR2(80);
			l_found				VARCHAR2(1) ;
			l_return_status			VARCHAR2(1) ;
			l_update				VARCHAR2(1) ;
			l_eam_res_inst_tbl_index	NUMBER;
			l_count                         NUMBER;

		BEGIN
			-- Initialize variables
			l_eam_res_inst_tbl		:= p_eam_res_inst_tbl;
			l_wip_entity_id			:= p_eam_res_usage_rec.wip_entity_id;
			l_operation_seq_num		:= p_eam_res_usage_rec.operation_seq_num;
			l_res_seq_num			:= p_eam_res_usage_rec.resource_seq_num;
			l_instance_id			:= p_eam_res_usage_rec.instance_id;
			l_serial_number                 := p_eam_res_usage_rec.serial_number;
			l_org_id				:= p_eam_res_usage_rec.organization_id;
			l_found				:= 'N';
			l_return_status			:= FND_API.G_RET_STS_SUCCESS;

			x_return_status := l_return_status;
			x_eam_res_inst_tbl := l_eam_res_inst_tbl;

-- place check for no rows returned in SELECT .This may occur when last record of woru gets deleted !

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Inside update_wori ' ) ; END IF ;


			SELECT	count(*)
				   INTO	l_count
				FROM	wip_operation_resource_usage
				WHERE	wip_entity_id = p_eam_res_usage_rec.wip_entity_id
				     AND	operation_seq_num =p_eam_res_usage_rec.operation_seq_num
				     AND	organization_id = p_eam_res_usage_rec.organization_id
				     AND	resource_seq_num =  p_eam_res_usage_rec.resource_seq_num
				     AND	instance_id =  p_eam_res_usage_rec.instance_id
				     AND       (serial_number IS NULL OR (serial_number =  p_eam_res_usage_rec.serial_number));

			IF (l_count=0) THEN
			 return;
			END IF;

				SELECT	min(start_date), max(completion_date)
				   INTO	l_min_start_date,l_max_completion_date
				  FROM	wip_operation_resource_usage
				WHERE	wip_entity_id = l_wip_entity_id
				     AND	operation_seq_num = l_operation_seq_num
				     AND	organization_id = l_org_id
				     AND	resource_seq_num = l_res_seq_num
				     AND	instance_id = l_instance_id
				     AND       (serial_number IS NULL OR (serial_number = l_serial_number));


				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Update WORI' ) ; END IF ;


					UPDATE	wip_op_resource_instances
					      SET	start_date = l_min_start_date,
							completion_date = l_max_completion_date ,
							last_update_date = sysdate ,
							last_updated_by = FND_GLOBAL.user_id ,
							creation_date = sysdate ,
							created_by = FND_GLOBAL.user_id ,
							last_update_login = FND_GLOBAL.login_id
					 WHERE	wip_entity_id = l_wip_entity_id
					      AND	operation_seq_num = l_operation_seq_num
					      AND	organization_id = l_org_id
					      AND	resource_seq_num = l_res_seq_num
					      AND	instance_id = l_instance_id
					      AND       (serial_number IS NULL OR (serial_number = l_serial_number));

					-- now update the pl/sql table for instances.

					l_eam_res_inst_tbl_index := l_eam_res_inst_tbl.FIRST;


					WHILE l_eam_res_inst_tbl_index IS NOT NULL LOOP

						IF (	l_eam_res_inst_tbl(l_eam_res_inst_tbl_index).wip_entity_id = l_wip_entity_id AND
							l_eam_res_inst_tbl(l_eam_res_inst_tbl_index).organization_id = l_org_id AND
							l_eam_res_inst_tbl(l_eam_res_inst_tbl_index).operation_seq_num = l_operation_seq_num AND
							l_eam_res_inst_tbl(l_eam_res_inst_tbl_index).resource_seq_num = l_res_seq_num AND
							l_eam_res_inst_tbl(l_eam_res_inst_tbl_index).instance_id = l_instance_id AND
							(l_eam_res_inst_tbl(l_eam_res_inst_tbl_index).serial_number IS NULL
							         OR (l_eam_res_inst_tbl(l_eam_res_inst_tbl_index).serial_number = l_serial_number))
						    ) THEN

							l_found := 'Y';
							l_eam_res_inst_tbl(l_eam_res_inst_tbl_index).start_date := l_min_start_date ;
							l_eam_res_inst_tbl(l_eam_res_inst_tbl_index).completion_date := l_max_completion_date ;
						END IF;

						l_eam_res_inst_tbl_index := l_eam_res_inst_tbl.NEXT( l_eam_res_inst_tbl_index);

					END LOOP;

					IF l_found = 'N' THEN -- query up from DB


						EAM_RES_INST_UTILITY_PVT.Query_Row(  l_wip_entity_id
													     , l_org_id
													     , l_operation_seq_num
													     , l_res_seq_num
													     , l_instance_id
													     , l_serial_number
													     , l_eam_res_inst_rec
													     , l_return_status );

						l_eam_res_inst_rec.wip_entity_id := l_wip_entity_id ;
						l_eam_res_inst_rec.organization_id := l_org_id ;
						l_eam_res_inst_rec.operation_seq_num := l_operation_seq_num ;
						l_eam_res_inst_rec.resource_seq_num := l_res_seq_num  ;
						l_eam_res_inst_rec.instance_id := l_instance_id ;
						l_eam_res_inst_rec.serial_number := l_serial_number;

						IF ( l_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
							l_eam_res_inst_rec.start_date := l_min_start_date;
							l_eam_res_inst_rec.completion_date := l_max_completion_date;
							l_eam_res_inst_tbl( l_eam_res_inst_tbl.COUNT + 1) := l_eam_res_inst_rec;
						ELSE
							RAISE FND_API.G_EXC_ERROR;
						END IF;

					END IF; -- end of check for l_found



			x_return_status := l_return_status;
			x_eam_res_inst_tbl := l_eam_res_inst_tbl;

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Exiting update_wori ' ) ; END IF ;

		EXCEPTION WHEN FND_API.G_EXC_ERROR THEN
			x_return_status := l_return_status;
		END update_wori;

		/*************************************************************************************************************************
		* Procedure		:	update_wor
		* Parameters IN		:	p_eam_res_usage_rec
							p_eam_res_tbl
		* Parameters OUT	:	x_eam_res_tbl
							x_return_status
		* Purpose			:	Updates/Deletes record from wip_op_resource_instances table . Returns changed
							instance records in x_eam_res_tbl.
		  ************************************************************************************************************************/

		procedure 	update_wor ( p_eam_res_usage_rec	IN EAM_PROCESS_WO_PUB.eam_res_usage_rec_type
						    ,p_eam_res_tbl		IN EAM_PROCESS_WO_PUB.eam_res_tbl_type
						    ,x_eam_res_tbl		OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
						    ,x_return_status		OUT NOCOPY VARCHAR ) IS

			l_eam_res_tbl			EAM_PROCESS_WO_PUB.eam_res_tbl_type ;
			l_resource_rec			EAM_PROCESS_WO_PUB.eam_res_rec_type ;
			l_min_start_date		DATE;
			l_max_completion_date	DATE;
			l_wip_entity_id			NUMBER ;
			l_operation_seq_num		NUMBER ;
			l_res_seq_num			NUMBER ;
			l_instance_id			NUMBER ;
			l_org_id				NUMBER ;
			--l_serial_number			NUMBER := p_eam_res_usage_rec.serial_number;
			l_found				VARCHAR2(1) ;
			l_return_status			VARCHAR2(1) ;
			l_update				VARCHAR2(1) ;
			l_eam_res_tbl_index		NUMBER;

		BEGIN
			-- Initialize variables
			l_eam_res_tbl			:= p_eam_res_tbl;
			l_wip_entity_id			:= p_eam_res_usage_rec.wip_entity_id;
			l_operation_seq_num		:= p_eam_res_usage_rec.operation_seq_num;
			l_res_seq_num			:= p_eam_res_usage_rec.resource_seq_num;
			l_org_id				:= p_eam_res_usage_rec.organization_id;
			l_found				:= 'N';
			l_return_status			:= FND_API.G_RET_STS_SUCCESS;

			x_return_status := l_return_status;
			x_eam_res_tbl	:= l_eam_res_tbl;

-- place check for no rows returned in SELECT .This may occur when last record of woru gets deleted !

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Inside update_wor' ) ; END IF ;

			BEGIN

				SELECT	min(start_date), max(completion_date)
				   INTO	l_min_start_date,l_max_completion_date
				  FROM	wip_operation_resource_usage
				WHERE	wip_entity_id = l_wip_entity_id
				     AND	operation_seq_num = l_operation_seq_num
				     AND	organization_id = l_org_id
				     AND	resource_seq_num = l_res_seq_num
				     AND	instance_id IS NULL
				     AND	serial_number IS NULL;

			EXCEPTION WHEN NO_DATA_FOUND THEN
				l_update		:= 'N'	;
			END ;

			IF ( NVL(l_update,'Y') = 'Y' ) THEN

				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Updating dates in from WOR ' ) ; END IF ;

				UPDATE	wip_operation_resources
				      SET	start_date = l_min_start_date,
						completion_date = l_max_completion_date ,
						last_update_date = sysdate ,
						last_updated_by = FND_GLOBAL.user_id ,
						creation_date = sysdate ,
						created_by = FND_GLOBAL.user_id ,
						last_update_login = FND_GLOBAL.login_id
				 WHERE	wip_entity_id = l_wip_entity_id
				      AND	operation_seq_num = l_operation_seq_num
				      AND	organization_id = l_org_id
				      AND	resource_seq_num = l_res_seq_num ;


				-- now update the pl/sql table for resources.

				l_eam_res_tbl_index := l_eam_res_tbl.FIRST;

				WHILE l_eam_res_tbl_index IS NOT NULL LOOP

					IF (	l_eam_res_tbl(l_eam_res_tbl_index).wip_entity_id = l_wip_entity_id AND
						l_eam_res_tbl(l_eam_res_tbl_index).organization_id = l_org_id AND
						l_eam_res_tbl(l_eam_res_tbl_index).operation_seq_num = l_operation_seq_num AND
						l_eam_res_tbl(l_eam_res_tbl_index).resource_seq_num = l_res_seq_num ) THEN

						l_found := 'Y';
						l_eam_res_tbl(l_eam_res_tbl_index).start_date := l_min_start_date ;
						l_eam_res_tbl(l_eam_res_tbl_index).completion_date := l_max_completion_date ;
					END IF;

					l_eam_res_tbl_index := l_eam_res_tbl.NEXT( l_eam_res_tbl_index);

				END LOOP;

				IF l_found = 'N' THEN -- query up from DB

					EAM_RES_UTILITY_PVT.Query_Row ( l_wip_entity_id ,
												l_org_id,
												l_operation_seq_num,
												l_res_seq_num,
												l_resource_rec,
												l_return_status) ;

					l_resource_rec.wip_entity_id := l_wip_entity_id ;
					l_resource_rec.organization_id := l_org_id ;
					l_resource_rec.operation_seq_num  := l_operation_seq_num ;
					l_resource_rec.resource_seq_num  := l_res_seq_num ;

					IF ( l_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
						l_resource_rec.start_date := l_min_start_date;
						l_resource_rec.completion_date := l_max_completion_date;
						l_eam_res_tbl( l_eam_res_tbl.COUNT + 1) := l_resource_rec;
					ELSE
						RAISE FND_API.G_EXC_ERROR;
					END IF;

				END IF; -- end of check for l_found

			END IF ; -- end of l_update

			x_return_status := l_return_status;
			x_eam_res_tbl := l_eam_res_tbl;

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' exiting update_wor ' ) ; END IF ;

		EXCEPTION WHEN FND_API.G_EXC_ERROR THEN
			x_return_status := l_return_status;
		END update_wor;

		/*************************************************************************************************************************
			* Procedure     : update_resource_usage
			* Parameters IN :
							p_eam_res_tbl
							p_eam_res_inst_tbl
							p_eam_res_usage_tbl

			* Parameters OUT NOCOPY:
							x_eam_res_tbl
							x_eam_res_usage_tbl
							x_eam_res_inst_tbl
							x_return_status
							x_message_name

			* Purpose       : Procedure will update Resource Usage table when a resource is added, its dates are changed
					       or usage record is added/updated/deleted. Corresponding changes are also done to WORI
		  ************************************************************************************************************************/

		procedure update_resource_usage(
			   p_eam_res_tbl		IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
			 , p_eam_res_inst_tbl	IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
			 , p_eam_res_usage_tbl	IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
			 , x_eam_res_tbl		OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
			 , x_eam_res_usage_tbl	OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
			 , x_eam_res_inst_tbl	OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
			 , x_return_status		OUT NOCOPY VARCHAR2
			 , x_message_name		OUT NOCOPY VARCHAR2
			)  IS

		CURSOR	get_inst_usage_min_date( c_wip_entity_id NUMBER, c_op_seq_num NUMBER , c_res_seq_num NUMBER ,
								c_instance_id NUMBER , c_serial_num VARCHAR2 ) IS
		SELECT	MIN(start_date) as min_inst_usg_date
		  FROM	wip_operation_resource_usage
		WHERE	wip_entity_id = c_wip_entity_id
		     AND	operation_seq_num = c_op_seq_num
		    AND	resource_seq_num = c_res_seq_num
		    AND	instance_id = c_instance_id
		    AND	( serial_number IS NULL OR serial_number = c_serial_num) ;

		CURSOR	get_inst_usage_max_date( c_wip_entity_id NUMBER, c_op_seq_num NUMBER , c_res_seq_num NUMBER ,
								c_instance_id NUMBER , c_serial_num VARCHAR2 ) IS
		SELECT	MAX(completion_date) as max_inst_usg_date
		  FROM	wip_operation_resource_usage
		WHERE	wip_entity_id = c_wip_entity_id
		     AND	operation_seq_num = c_op_seq_num
		    AND	resource_seq_num = c_res_seq_num
		    AND	instance_id = c_instance_id
		    AND	( serial_number IS NULL OR serial_number = c_serial_num) ;

		CURSOR	get_res_usage_min_date( c_wip_entity_id NUMBER, c_op_seq_num NUMBER , c_res_seq_num NUMBER ) IS
		SELECT	MIN(start_date) as min_res_usg_date
		  FROM	wip_operation_resource_usage
		WHERE	wip_entity_id = c_wip_entity_id
		     AND	operation_seq_num = c_op_seq_num
		    AND	resource_seq_num = c_res_seq_num
		    AND	instance_id IS NULL
		    AND	serial_number IS NULL ;

		CURSOR	get_res_usage_max_date( c_wip_entity_id NUMBER, c_op_seq_num NUMBER , c_res_seq_num NUMBER ) IS
		SELECT	MAX(completion_date) as max_inst_usg_date
		  FROM	wip_operation_resource_usage
		WHERE	wip_entity_id = c_wip_entity_id
		     AND	operation_seq_num = c_op_seq_num
		    AND	resource_seq_num = c_res_seq_num
		    AND	instance_id IS NULL
		    AND	serial_number IS NULL ;

		CURSOR	get_instdates( c_wip_entity_id NUMBER, c_op_seq_num NUMBER , c_res_seq_num NUMBER ) IS
		SELECT	 start_date, completion_date, instance_id, serial_number
		FROM wip_operation_resource_usage
		WHERE	wip_entity_id = c_wip_entity_id
			AND	operation_seq_num = c_op_seq_num
			AND	resource_seq_num = c_res_seq_num;


		l_mesg_token_tbl			EAM_ERROR_MESSAGE_PVT.mesg_token_tbl_type;
		l_return_status				VARCHAR2(1) ;
		l_eam_res_usage_rec			EAM_PROCESS_WO_PUB.eam_res_usage_rec_type;
		l_eam_res_inst_rec			EAM_PROCESS_WO_PUB.eam_res_inst_rec_type;
		l_eam_res_tbl				EAM_PROCESS_WO_PUB.eam_res_tbl_type ;
		l_out_eam_res_tbl			EAM_PROCESS_WO_PUB.eam_res_tbl_type ;
		l_eam_res_usage_tbl			EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type ;
		l_eam_res_inst_tbl			EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type	;
		l_min_found				VARCHAR2(1) ;
		l_max_found				VARCHAR2(1) ;
		l_res_tbl_index				NUMBER;
		l_res_inst_tbl_index			NUMBER;
		l_res_usage_tbl_index		NUMBER;
		l_old_usage_start_date		DATE ;
		l_old_usage_completion_date	DATE ;
		l_wip_entity_id				NUMBER;
		l_op_seq_num				NUMBER;
		l_res_seq_num				NUMBER;
		l_instance_id				NUMBER;
		l_serial_num				VARCHAR2(80);
		l_min_date				DATE ;
		l_max_date				DATE ;
                l_woru_count                            NUMBER;

	       BEGIN
			SAVEPOINT UPDATE_RES_USAGE ;

			-- Initialize variables
			l_return_status				:= FND_API.G_RET_STS_SUCCESS;
			l_eam_res_tbl				:= p_eam_res_tbl;
			l_eam_res_usage_tbl			:= p_eam_res_usage_tbl;
			l_eam_res_inst_tbl			:= p_eam_res_inst_tbl;
			l_min_found				:='N';
			l_max_found				:='N';


			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Entering update_resource_usage ') ; END IF ;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' l_eam_res_tbl.count = '|| l_eam_res_tbl.count) ; END IF ;
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' l_eam_res_inst_tbl.count = '|| l_eam_res_inst_tbl.count) ; END IF ;
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' l_eam_res_usage_tbl.count = '|| l_eam_res_usage_tbl.count) ; END IF ;


			l_res_inst_tbl_index := l_eam_res_inst_tbl.FIRST ;

			WHILE  l_res_inst_tbl_index IS NOT NULL LOOP


				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Processing instance record ' || l_res_inst_tbl_index) ; END IF ;

				IF ( l_eam_res_inst_tbl(l_res_inst_tbl_index).transaction_type = EAM_PROCESS_WO_PUB.G_OPR_CREATE )THEN

					-- when adding a resource add one record into WORU too .

					IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Creating usage record for instance ') ; END IF ;

					l_eam_res_usage_rec.wip_entity_id := l_eam_res_inst_tbl(l_res_inst_tbl_index).wip_entity_id ;
					l_eam_res_usage_rec.organization_id := l_eam_res_inst_tbl(l_res_inst_tbl_index).organization_id ;
					l_eam_res_usage_rec.operation_seq_num := l_eam_res_inst_tbl(l_res_inst_tbl_index).operation_seq_num ;
					l_eam_res_usage_rec.resource_seq_num := l_eam_res_inst_tbl(l_res_inst_tbl_index).resource_seq_num ;
					l_eam_res_usage_rec.start_date := l_eam_res_inst_tbl(l_res_inst_tbl_index).start_date ;
					l_eam_res_usage_rec.completion_date := l_eam_res_inst_tbl(l_res_inst_tbl_index).completion_date ;
					l_eam_res_usage_rec.instance_id := l_eam_res_inst_tbl(l_res_inst_tbl_index).instance_id ;
					l_eam_res_usage_rec.serial_number := l_eam_res_inst_tbl(l_res_inst_tbl_index).serial_number ;
					l_eam_res_usage_rec.transaction_type := l_eam_res_inst_tbl(l_res_inst_tbl_index).transaction_type ;


					-- insert record into the resource usage pl/sql table
					l_eam_res_usage_tbl( l_eam_res_usage_tbl.COUNT + 1) := l_eam_res_usage_rec ;

				ELSIF ( l_eam_res_inst_tbl(l_res_inst_tbl_index).transaction_type = EAM_PROCESS_WO_PUB.G_OPR_UPDATE )THEN

					l_wip_entity_id :=  l_eam_res_inst_tbl(l_res_inst_tbl_index).wip_entity_id ;
					l_op_seq_num := l_eam_res_inst_tbl(l_res_inst_tbl_index).operation_seq_num ;
					l_res_seq_num := l_eam_res_inst_tbl(l_res_inst_tbl_index).resource_seq_num ;
					l_instance_id := l_eam_res_inst_tbl(l_res_inst_tbl_index).instance_id ;
					l_serial_num := l_eam_res_inst_tbl(l_res_inst_tbl_index).serial_number ;

					BEGIN

						IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Updating WORU with start date for instance') ; END IF ;

						OPEN get_inst_usage_min_date( l_wip_entity_id ,l_op_seq_num , l_res_seq_num , l_instance_id , l_serial_num) ;
						FETCH get_inst_usage_min_date INTO l_min_date ;
						CLOSE get_inst_usage_min_date ;

						OPEN get_inst_usage_max_date( l_wip_entity_id ,l_op_seq_num , l_res_seq_num , l_instance_id , l_serial_num) ;
						FETCH get_inst_usage_max_date INTO l_max_date ;
						CLOSE get_inst_usage_max_date ;

						l_res_usage_tbl_index := l_eam_res_usage_tbl.FIRST ;


					 IF l_eam_res_usage_tbl.count >0  THEN

						WHILE  l_res_usage_tbl_index IS NOT NULL LOOP

							IF ( l_eam_res_usage_tbl( l_res_usage_tbl_index ).wip_entity_id = l_wip_entity_id AND
							      l_eam_res_usage_tbl( l_res_usage_tbl_index ).operation_seq_num = l_op_seq_num AND
							      l_eam_res_usage_tbl( l_res_usage_tbl_index ).resource_seq_num = l_res_seq_num AND
							      l_eam_res_usage_tbl( l_res_usage_tbl_index ).instance_id = l_instance_id AND
							      ( l_eam_res_usage_tbl( l_res_usage_tbl_index ).serial_number IS NULL OR
								l_eam_res_usage_tbl( l_res_usage_tbl_index ).serial_number = l_serial_num ) AND
								l_eam_res_usage_tbl( l_res_usage_tbl_index ).old_start_date = l_min_date ) THEN

									l_min_found := 'Y' ;
							END IF ;

							IF ( l_eam_res_usage_tbl( l_res_usage_tbl_index ).wip_entity_id = l_wip_entity_id AND
							      l_eam_res_usage_tbl( l_res_usage_tbl_index ).operation_seq_num = l_op_seq_num AND
							      l_eam_res_usage_tbl( l_res_usage_tbl_index ).resource_seq_num = l_res_seq_num AND
							      l_eam_res_usage_tbl( l_res_usage_tbl_index ).instance_id = l_instance_id AND
							      ( l_eam_res_usage_tbl( l_res_usage_tbl_index ).serial_number IS NULL OR
								l_eam_res_usage_tbl( l_res_usage_tbl_index ).serial_number = l_serial_num ) AND
								l_eam_res_usage_tbl( l_res_usage_tbl_index ).old_completion_date = l_max_date ) THEN

									l_max_found := 'Y' ;
							END IF ;

							 l_res_usage_tbl_index := l_eam_res_usage_tbl.NEXT(l_res_usage_tbl_index);

						END LOOP;

						IF ( l_min_found = 'N' ) THEN

							UPDATE	wip_operation_resource_usage
							      SET	start_date = l_eam_res_inst_tbl(l_res_inst_tbl_index).start_date ,
									last_update_date = sysdate ,
									last_updated_by = FND_GLOBAL.user_id ,
									creation_date = sysdate ,
									created_by = FND_GLOBAL.user_id ,
									last_update_login = FND_GLOBAL.login_id
							 WHERE	wip_entity_id = l_wip_entity_id
							      AND	operation_seq_num = l_op_seq_num
							      AND	resource_seq_num = l_res_seq_num
							      AND	start_date = l_min_date
							      AND	instance_id = l_instance_id
							      AND	( serial_number IS NULL OR serial_number = l_serial_num);
						END IF ;

						IF ( l_max_found = 'N' ) THEN

							UPDATE	wip_operation_resource_usage
							      SET	completion_date = l_eam_res_inst_tbl(l_res_inst_tbl_index).completion_date ,
									last_update_date = sysdate ,
									last_updated_by = FND_GLOBAL.user_id ,
									creation_date = sysdate ,
									created_by = FND_GLOBAL.user_id ,
									last_update_login = FND_GLOBAL.login_id
							 WHERE	wip_entity_id = l_wip_entity_id
							      AND	operation_seq_num = l_op_seq_num
							      AND	resource_seq_num = l_res_seq_num
							      AND	completion_date = l_max_date
							      AND	instance_id = l_instance_id
							      AND	( serial_number IS NULL OR serial_number = l_serial_num);
						END IF ;

					END IF;

					EXCEPTION WHEN NO_DATA_FOUND THEN
						l_return_status := FND_API.G_RET_STS_ERROR ;
						RAISE FND_API.G_EXC_ERROR ;
					END ;

				END IF; -- end of check for l_eam_res_inst_tbl(l_res_inst_tbl_index).transaction_type

				l_res_inst_tbl_index := l_eam_res_inst_tbl.NEXT(l_res_inst_tbl_index);

			END LOOP; -- end looping through l_eam_res_inst_tbl


			l_res_tbl_index := l_eam_res_tbl.FIRST ;

			WHILE  l_res_tbl_index IS NOT NULL LOOP

				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Processing resource record ' || l_res_tbl_index) ; END IF ;

				IF ( l_eam_res_tbl(l_res_tbl_index).transaction_type = EAM_PROCESS_WO_PUB.G_OPR_CREATE )THEN

					IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Creating usage record for resource') ; END IF ;

					-- when adding a resource add one record into WORU too .
					l_eam_res_usage_rec.wip_entity_id := l_eam_res_tbl(l_res_tbl_index).wip_entity_id ;
					l_eam_res_usage_rec.organization_id := l_eam_res_tbl(l_res_tbl_index).organization_id ;
					l_eam_res_usage_rec.operation_seq_num := l_eam_res_tbl(l_res_tbl_index).operation_seq_num ;
					l_eam_res_usage_rec.resource_seq_num := l_eam_res_tbl(l_res_tbl_index).resource_seq_num ;
					l_eam_res_usage_rec.start_date := l_eam_res_tbl(l_res_tbl_index).start_date ;
					l_eam_res_usage_rec.completion_date := l_eam_res_tbl(l_res_tbl_index).completion_date ;
					l_eam_res_usage_rec.instance_id := NULL ;
					l_eam_res_usage_rec.serial_number := NULL ;
					l_eam_res_usage_rec.assigned_units := l_eam_res_tbl(l_res_tbl_index).assigned_units ;
					l_eam_res_usage_rec.transaction_type := l_eam_res_tbl(l_res_tbl_index).transaction_type ;
					l_eam_res_usage_rec.request_id := l_eam_res_tbl(l_res_tbl_index).request_id ;
					l_eam_res_usage_rec.program_application_id := l_eam_res_tbl(l_res_tbl_index).program_application_id ;
					l_eam_res_usage_rec.program_id := l_eam_res_tbl(l_res_tbl_index).program_id ;


					-- insert record into the resource usage pl/sql table
					l_eam_res_usage_tbl( l_eam_res_usage_tbl.COUNT + 1) := l_eam_res_usage_rec ;

				ELSIF ( l_eam_res_tbl(l_res_tbl_index).transaction_type = EAM_PROCESS_WO_PUB.G_OPR_UPDATE )THEN

					l_wip_entity_id :=  l_eam_res_tbl(l_res_tbl_index).wip_entity_id ;
					l_op_seq_num := l_eam_res_tbl(l_res_tbl_index).operation_seq_num ;
					l_res_seq_num := l_eam_res_tbl(l_res_tbl_index).resource_seq_num ;

					select count(*) into l_woru_count
					from wip_operation_resource_usage where
					wip_entity_id = l_wip_entity_id
					AND	operation_seq_num = l_op_seq_num
					AND	resource_seq_num = l_res_seq_num
					AND	instance_id IS NULL
					AND	serial_number IS NULL ;

					BEGIN

						IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Updating WORU with start date for resource') ; END IF ;

						OPEN get_res_usage_min_date( l_wip_entity_id ,l_op_seq_num , l_res_seq_num );
						FETCH get_res_usage_min_date INTO l_min_date ;
						CLOSE get_res_usage_min_date ;

						OPEN get_res_usage_max_date( l_wip_entity_id ,l_op_seq_num , l_res_seq_num ) ;
						FETCH get_res_usage_max_date INTO l_max_date ;
						CLOSE get_res_usage_max_date ;

						l_res_usage_tbl_index := l_eam_res_usage_tbl.FIRST ;

                                                IF l_eam_res_usage_tbl.count =0 AND l_woru_count=1 THEN -- Added for Summary tab.Only for 24 hr resources.

						    UPDATE	wip_operation_resource_usage
							      SET	start_date = l_eam_res_tbl(l_res_tbl_index).start_date ,
									last_update_date = sysdate ,
									last_updated_by = FND_GLOBAL.user_id ,
									creation_date = sysdate ,
									created_by = FND_GLOBAL.user_id ,
									last_update_login = FND_GLOBAL.login_id
							 WHERE	wip_entity_id = l_wip_entity_id
							      AND	operation_seq_num = l_op_seq_num
							      AND	resource_seq_num = l_res_seq_num
							      AND	instance_id IS NULL
							      AND	serial_number IS NULL ;


							UPDATE	wip_operation_resource_usage
							      SET	completion_date = l_eam_res_tbl(l_res_tbl_index).completion_date ,
									last_update_date = sysdate ,
									last_updated_by = FND_GLOBAL.user_id ,
									creation_date = sysdate ,
									created_by = FND_GLOBAL.user_id ,
									last_update_login = FND_GLOBAL.login_id
							 WHERE	wip_entity_id = l_wip_entity_id
							      AND	operation_seq_num = l_op_seq_num
							      AND	resource_seq_num = l_res_seq_num
							      AND	instance_id IS NULL
							      AND	serial_number IS NULL ;

                                                FOR c_instdates_rec IN get_instdates(l_wip_entity_id ,  l_op_seq_num,  l_res_seq_num )
						LOOP
							select count(*) into l_woru_count
							from wip_operation_resource_usage
							where
							wip_entity_id = l_wip_entity_id
							AND	operation_seq_num = l_op_seq_num
							AND	resource_seq_num = l_res_seq_num
							AND	instance_id = c_instdates_rec.instance_id
							AND	( serial_number IS NULL OR serial_number = c_instdates_rec.serial_number);

						IF l_woru_count=1 THEN -- Update WORU rows for instances.Only for 24 hr resources

							UPDATE	wip_operation_resource_usage
							      SET	start_date = l_eam_res_tbl(l_res_tbl_index).start_date ,
									last_update_date = sysdate ,
									last_updated_by = FND_GLOBAL.user_id ,
									creation_date = sysdate ,
									created_by = FND_GLOBAL.user_id ,
									last_update_login = FND_GLOBAL.login_id
							 WHERE	wip_entity_id = l_wip_entity_id
							      AND	operation_seq_num = l_op_seq_num
							      AND	resource_seq_num = l_res_seq_num
							      AND	instance_id = c_instdates_rec.instance_id
							      AND	( serial_number IS NULL OR serial_number = c_instdates_rec.serial_number);

							UPDATE	wip_operation_resource_usage
							      SET	completion_date =l_eam_res_tbl(l_res_tbl_index).completion_date ,
									last_update_date = sysdate ,
									last_updated_by = FND_GLOBAL.user_id ,
									creation_date = sysdate ,
									created_by = FND_GLOBAL.user_id ,
									last_update_login = FND_GLOBAL.login_id
							 WHERE	wip_entity_id = l_wip_entity_id
							      AND	operation_seq_num = l_op_seq_num
							      AND	resource_seq_num = l_res_seq_num
							      AND	instance_id = c_instdates_rec.instance_id
							      AND	( serial_number IS NULL OR serial_number = c_instdates_rec.serial_number);
						END IF;

						END LOOP;

					        END IF;

						IF  l_eam_res_usage_tbl.count >0 THEN

							WHILE  l_res_usage_tbl_index IS NOT NULL LOOP

								IF ( l_eam_res_usage_tbl( l_res_usage_tbl_index ).wip_entity_id = l_wip_entity_id AND
								      l_eam_res_usage_tbl( l_res_usage_tbl_index ).operation_seq_num = l_op_seq_num AND
								      l_eam_res_usage_tbl( l_res_usage_tbl_index ).resource_seq_num = l_res_seq_num AND
								      l_eam_res_usage_tbl( l_res_usage_tbl_index ).instance_id IS NULL AND
								       l_eam_res_usage_tbl( l_res_usage_tbl_index ).serial_number IS NULL  AND
									l_eam_res_usage_tbl( l_res_usage_tbl_index ).old_start_date = l_min_date ) THEN

										l_min_found := 'Y' ;
								END IF ;

								IF ( l_eam_res_usage_tbl( l_res_usage_tbl_index ).wip_entity_id = l_wip_entity_id AND
								      l_eam_res_usage_tbl( l_res_usage_tbl_index ).operation_seq_num = l_op_seq_num AND
								      l_eam_res_usage_tbl( l_res_usage_tbl_index ).resource_seq_num = l_res_seq_num AND
								      l_eam_res_usage_tbl( l_res_usage_tbl_index ).instance_id IS NULL AND
								       l_eam_res_usage_tbl( l_res_usage_tbl_index ).serial_number IS NULL  AND
									l_eam_res_usage_tbl( l_res_usage_tbl_index ).old_completion_date = l_max_date ) THEN

										l_max_found := 'Y' ;
								END IF ;

								l_res_usage_tbl_index := l_eam_res_usage_tbl.NEXT(l_res_usage_tbl_index);
							END LOOP;


						IF (  l_min_found = 'N' ) THEN

							UPDATE	wip_operation_resource_usage
							      SET	start_date = l_eam_res_tbl(l_res_tbl_index).start_date ,
									last_update_date = sysdate ,
									last_updated_by = FND_GLOBAL.user_id ,
									creation_date = sysdate ,
									created_by = FND_GLOBAL.user_id ,
									last_update_login = FND_GLOBAL.login_id
							 WHERE	wip_entity_id = l_wip_entity_id
							      AND	operation_seq_num = l_op_seq_num
							      AND	resource_seq_num = l_res_seq_num
							      AND	start_date = l_min_date
							      AND	instance_id IS NULL
							      AND	serial_number IS NULL ;
						END IF ;

						IF (  l_max_found = 'N' ) THEN

							UPDATE	wip_operation_resource_usage
							      SET	completion_date = l_eam_res_tbl(l_res_tbl_index).completion_date ,
									last_update_date = sysdate ,
									last_updated_by = FND_GLOBAL.user_id ,
									creation_date = sysdate ,
									created_by = FND_GLOBAL.user_id ,
									last_update_login = FND_GLOBAL.login_id
							 WHERE	wip_entity_id = l_wip_entity_id
							      AND	operation_seq_num = l_op_seq_num
							      AND	resource_seq_num = l_res_seq_num
							      AND	completion_date = l_max_date
							      AND	instance_id IS NULL
							      AND	serial_number IS NULL ;
						END IF ;

					END IF;
					EXCEPTION WHEN NO_DATA_FOUND THEN
						l_return_status := FND_API.G_RET_STS_ERROR ;
						RAISE FND_API.G_EXC_ERROR ;
					END ;

				END IF; -- end of check for l_eam_res_tbl(l_res_tbl_index).transaction_type

				l_res_tbl_index := l_eam_res_tbl.NEXT(l_res_tbl_index);

			END LOOP; -- end looping through l_eam_res_tbl

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Purging resource and instance records for update from WORU ' ) ; END IF ;

			IF ( l_eam_res_usage_tbl.count > 0 ) THEN
				FOR i IN l_eam_res_usage_tbl.FIRST..l_eam_res_usage_tbl.LAST LOOP
					IF ( l_eam_res_usage_tbl(i).transaction_type = EAM_PROCESS_WO_PUB.G_OPR_UPDATE ) THEN
						IF ( l_eam_res_usage_tbl(i).instance_id IS NULL ) THEN
							DELETE FROM	wip_operation_resource_usage
								  WHERE	wip_entity_id = l_eam_res_usage_tbl(i).wip_entity_id
								       AND	operation_seq_num = l_eam_res_usage_tbl(i).operation_seq_num
								       AND	resource_seq_num = l_eam_res_usage_tbl(i).resource_seq_num
								       AND	instance_id IS NULL
								       AND	start_date = l_eam_res_usage_tbl(i).old_start_date
								       AND	completion_date = l_eam_res_usage_tbl(i).old_completion_date ;
						ELSE
							DELETE FROM	wip_operation_resource_usage
								  WHERE	wip_entity_id = l_eam_res_usage_tbl(i).wip_entity_id
								       AND	operation_seq_num = l_eam_res_usage_tbl(i).operation_seq_num
								       AND	resource_seq_num = l_eam_res_usage_tbl(i).resource_seq_num
								       AND	instance_id =  l_eam_res_usage_tbl(i).instance_id
								       AND      ( serial_number IS NULL OR serial_number = l_eam_res_usage_tbl(i).serial_number )
								       AND	start_date = l_eam_res_usage_tbl(i).old_start_date
								       AND	completion_date = l_eam_res_usage_tbl(i).old_completion_date ;
						END IF ;
					END IF ;
				END LOOP ;
			END IF ;

			l_res_usage_tbl_index := l_eam_res_usage_tbl.FIRST ;

			WHILE l_res_usage_tbl_index IS NOT NULL LOOP

				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Processing resource usage record ' || l_res_usage_tbl_index) ; END IF ;

				l_eam_res_usage_rec := l_eam_res_usage_tbl(l_res_usage_tbl_index);

				IF ( l_eam_res_usage_rec.transaction_type IN ( EAM_PROCESS_WO_PUB.G_OPR_CREATE , EAM_PROCESS_WO_PUB.G_OPR_UPDATE) ) THEN
						-- call insert usage method
					IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Txn: Create resource usage  ') ; END IF ;

					insert_into_woru( l_eam_res_usage_rec , l_return_status  ) ;

					IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
							RAISE FND_API.G_EXC_ERROR;
					END IF;

				ELSIF ( l_eam_res_usage_rec.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_DELETE ) THEN
						-- call method delete usage and update inst table.

					IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Txn:Delete resource usage  ') ; END IF ;

					delete_from_woru( l_eam_res_usage_rec ) ;

				END IF; -- end of checking l_eam_res_usage_tbl(i).transaction_type

				l_res_usage_tbl_index := l_eam_res_usage_tbl.NEXT(l_res_usage_tbl_index);

			END LOOP; -- end of looping through l_eam_res_usage_tbl

		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Sync up resource and instance records with usage records ') ; END IF ;

			IF ( l_eam_res_usage_tbl.count > 0 ) THEN
				FOR i IN l_eam_res_usage_tbl.FIRST..l_eam_res_usage_tbl.LAST LOOP

					l_eam_res_usage_rec := l_eam_res_usage_tbl(i) ;

					IF ( l_eam_res_usage_rec.instance_id IS NOT NULL ) THEN

						update_wori ( l_eam_res_usage_rec
								     ,p_eam_res_inst_tbl
								     ,l_eam_res_inst_tbl
								     ,l_return_status );

						IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
							RAISE FND_API.G_EXC_ERROR;
						END IF;

					ELSE
							update_wor ( l_eam_res_usage_rec
									    , l_eam_res_tbl
									    , l_out_eam_res_tbl
									    , l_return_status );

							l_eam_res_tbl := l_out_eam_res_tbl;

							IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
								RAISE FND_API.G_EXC_ERROR;
							END IF;
					END IF ;
				END LOOP ;
			END IF ;

			x_eam_res_usage_tbl := l_eam_res_usage_tbl ;
			x_eam_res_inst_tbl  := l_eam_res_inst_tbl ;
			x_eam_res_tbl  := l_eam_res_tbl ;
			x_return_status := l_return_status ;

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Exiting update_resource_usage ') ; END IF ;

		EXCEPTION
			WHEN FND_API.G_EXC_ERROR THEN
				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(' Error occured in update_resource_usage API ') ; END IF ;
				ROLLBACK TO UPDATE_RES_USAGE ;
				x_return_status := l_return_status ;
				x_message_name := ' ' ;

		END update_resource_usage;

	END EAM_SCHED_BOTTOM_UP_PVT ;



/
