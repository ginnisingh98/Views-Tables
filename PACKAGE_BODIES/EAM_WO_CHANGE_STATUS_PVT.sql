--------------------------------------------------------
--  DDL for Package Body EAM_WO_CHANGE_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WO_CHANGE_STATUS_PVT" AS
/* $Header: EAMVWOSB.pls 120.28.12010000.11 2012/03/08 06:32:46 vboddapa ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWOSB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_WO_CHANGE_STATUS_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Amit Mondal     Initial Creation
--  15-Jul-2005    Anju Gupta      Changes for MOAC in R12
***************************************************************************/

G_Pkg_Name      VARCHAR2(30) := 'EAM_WO_CHANGE_STATUS_PVT';

/*************************************************************************************
  -- WIP_JOB_STATUS								     *
  UNRELEASED    :=  1; -- Unreleased - no charges allowed                            *
  SIMULATED     :=  2; -- Simulated						     *
  RELEASED      :=  3; -- Released - charges allowed				     *
  COMP_CHRG     :=  4; -- Complete - charges allowed				     *
  COMP_NOCHRG   :=  5; -- Complete - no charges allowed				     *
  HOLD          :=  6; -- Hold - no charges allowed				     *
  CANCELLED     :=  7; -- Cancelled - no charges allowed			     *
  PEND_BOM      :=  8; -- Pending bill of material load				     *
  FAIL_BOM      :=  9; -- Failed bill of material load				     *
  PEND_ROUT     := 10; -- Pending routing load					     *
  FAIL_ROUT     := 11; -- Failed routing load					     *
  CLOSED        := 12; -- Closed - no charges allowed				     *
  PEND_REPML    := 13; -- Pending - repetitively mass loaded			     *
  PEND_CLOSE    := 14; -- Pending Close						     *
  FAIL_CLOSE    := 15; -- Failed Close						     *
  PEND_SCHED    := 16; -- Pending Scheduling        (FS)			     *
  DRAFT         := 17; -- Draft							     *
  ************************************************************************************/

PROCEDURE change_status (
                 p_api_version        IN       NUMBER
                ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
                ,p_commit             IN       VARCHAR2 := fnd_api.g_false
                ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
                ,p_wip_entity_id      IN       NUMBER
                ,p_organization_id    IN       NUMBER
                ,p_to_status_type     IN       NUMBER   := wip_constants.unreleased
                ,p_user_id            IN       NUMBER   := null
                ,p_responsibility_id  IN       NUMBER   := null
		,p_date_released      IN       DATE    := sysdate
		, p_report_type           IN        NUMBER := null
                   , p_actual_close_date      IN    DATE := sysdate
                   , p_submission_date       IN     DATE  := sysdate
                ,p_work_order_mode    IN       NUMBER  := EAM_PROCESS_WO_PVT.G_OPR_CREATE
                ,x_request_id         OUT NOCOPY      NUMBER
                ,x_return_status      OUT NOCOPY      VARCHAR2
                ,x_msg_count          OUT NOCOPY      NUMBER
                ,x_msg_data           OUT NOCOPY      VARCHAR2
                ,x_Mesg_Token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type)
              IS
                 l_api_name              CONSTANT VARCHAR2(30) := 'change_status';
                 l_api_version           CONSTANT NUMBER       := 1.0;
                 l_full_name             CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;
                 l_wip_entity_id         NUMBER := 0;
                 l_current_status        NUMBER := 0;
                 l_to_status_type        NUMBER := 0;
                 l_organization_id       NUMBER := 0;
                 l_firm_flag             NUMBER := 2;
                 l_final_status          NUMBER := 0; -- this status will be updated in WDJ
                 l_user_id               NUMBER :=0;
                 l_responsibility_id     NUMBER :=0;

                 l_use_finite_scheduler  NUMBER := 0;
                 l_material_constrained  NUMBER := 0;
                 l_horizon_length        NUMBER := 0;
                 l_asset_group_id        NUMBER := 0;
                 l_asset_number          VARCHAR2(30) := '';
                 l_rebuild_item_id       NUMBER := 0;
                 l_rebuild_serial_number  VARCHAR2(80) := '';
                 l_primary_item_id       NUMBER := 0;
                 l_rebuild_flag          VARCHAR2(1);
                 l_valid                 NUMBER := 0;
                 l_class_code            VARCHAR2(10) := '';
                 l_tmp                   NUMBER := 0;
                 l_gid                   NUMBER := 0;
                 l_wip_entity_name       VARCHAR2(240) := '';
                 l_date                  VARCHAR2(100);
                 l_date_completed        DATE;
                 l_date_closed           DATE;
                 l_unclose               NUMBER := 0;
                 l_maintenance_obj_src   NUMBER := 1;
                 l_di_count              NUMBER := 0;
                 l_di_msg_count          NUMBER := 0;
                 l_di_msg_data           VARCHAR2(80) := '';
                 l_di_return_status      VARCHAR2(80) := '';
		 l_po_creation_time      NUMBER;
                 l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;

--fix for bug 3357656.Added following 4 parameters to get the message from eam_workutil_pkg.unrelease
                 l_encoded_message       VARCHAR2(800);
                 l_application_name      VARCHAR2(10);
                 l_mesg_name             VARCHAR2(100);
                 l_token_tbl            EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;

                 l_request_id              NUMBER;
                 l_return_status         VARCHAR2(80);
                 l_msg_count             NUMBER := 0;
                 l_msg_data              varchar2(2000) ;

		 l_relations_count       NUMBER:=0;

                 CHANGE_STATUS_NOT_POSSIBLE    EXCEPTION;
                 CHNGE_ST_FRM_TO_NOT_PSSBLE   EXCEPTION;
                 INVALID_RELEASE       EXCEPTION;
                 INVALID_UNRELEASE     EXCEPTION;

		 l_work_order_name	   VARCHAR2(240);
		 l_asset_ops_msg_count	   NUMBER;
		 l_asset_ops_msg_data	   VARCHAR2(2000);
		 l_asset_ops_return_status VARCHAR2(1);
		 l_maint_obj_id		   NUMBER;
		 l_warning                        VARCHAR2(100);
                 l_closed_status             NUMBER;
                 l_route 					NUMBER;

				 l_date_released_calc    DATE;
				 l_min_open_period_date  DATE;
				 l_wo_sched_start_date   DATE;

		l_po_exists NUMBER := 0;
		g_dummy NUMBER;

              BEGIN

	      -- Standard Start of API savepoint
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('=============================================== '); END IF;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Entering Status Change Package '); END IF;

                 SAVEPOINT change_status;

                 -- Standard call to check for call compatibility.
                 IF NOT fnd_api.compatible_api_call(
                       l_api_version
                      ,p_api_version
                      ,l_api_name
                      ,g_pkg_name) THEN
                    RAISE fnd_api.g_exc_unexpected_error;
                 END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Initializing Message list for Status Change'); END IF;

                 -- Initialize message list if p_init_msg_list is set to TRUE.
                 IF fnd_api.to_boolean(p_init_msg_list) THEN
                    fnd_msg_pub.initialize;
                 END IF;

                 --  Initialize API return status to success
                 x_return_status := fnd_api.g_ret_sts_success;

                 x_mesg_token_tbl := l_mesg_token_tbl;


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Entering Status Change API body'); END IF;

                 /********************************************************************/
                 -- API body

                 l_wip_entity_id     := p_wip_entity_id;
                 l_organization_id := p_organization_id;
                 l_to_status_type := p_to_status_type;
                 l_user_id := p_user_id;
                 l_responsibility_id := p_responsibility_id;

		 SELECT wip_entity_name
		   INTO l_work_order_name
		   FROM wip_entities
		  WHERE wip_entity_id = p_wip_entity_id;

                 -- Validate status_id
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Validating Status'); END IF;

                 IF l_to_status_type NOT IN (WIP_CONSTANTS.UNRELEASED,WIP_CONSTANTS.RELEASED, WIP_CONSTANTS.COMP_CHRG,WIP_CONSTANTS.COMP_NOCHRG, WIP_CONSTANTS.CLOSED,
                                      WIP_CONSTANTS.HOLD, WIP_CONSTANTS.CANCELLED, WIP_CONSTANTS.PEND_SCHED, WIP_CONSTANTS.DRAFT)
                 THEN

                     raise fnd_api.g_exc_unexpected_error;

                 END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Find current work order status'); END IF;

                 -- Get current status of work order

                 BEGIN

                 SELECT nvl(wdj.status_type,1),
                        nvl(wdj.firm_planned_flag,2),
                        wdj.organization_id,
                        nvl(wdj.asset_group_id,0),
                        nvl(wdj.asset_number,''),
                        nvl(wdj.rebuild_item_id,0),
                        nvl(wdj.rebuild_serial_number,''),
                        wdj.primary_item_id,
                        wdj.class_code,
                        we.wip_entity_name,
                        wdj.date_completed,
                        wdj.date_closed,
                        wdj.maintenance_object_source,
			wdj.po_creation_time,
			wdj.maintenance_object_id
                 INTO l_current_status,
                      l_firm_flag,
                      l_organization_id,
                      l_asset_group_id,
                      l_asset_number,
                      l_rebuild_item_id,
                      l_rebuild_serial_number,
                      l_primary_item_id,
                      l_class_code,
                      l_wip_entity_name,
                      l_date_completed,
                      l_date_closed,
                      l_maintenance_obj_src,
		      l_po_creation_time,
		      l_maint_obj_id
                 FROM wip_discrete_jobs wdj, wip_entities we
                         where wdj.wip_entity_id = l_wip_entity_id
                         and we.wip_entity_id = wdj.wip_entity_id
                         and we.organization_id = wdj.organization_id;

                 EXCEPTION
                 WHEN OTHERS THEN
                     l_current_status := 0; -- work order does not exist
                     l_firm_flag := 2;
                 END;
                 l_final_status := l_current_status;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Current WO Status: '||l_current_status||' To Status: '||l_to_status_type); END IF;

                 -- Determine whether it is a rebuild work order
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Checking if this is a rebuild WO'); END IF;

                 IF(l_rebuild_item_id > 0) THEN
                     l_rebuild_flag := 'Y';
                 ELSIF (l_asset_group_id > 0) THEN
                     l_rebuild_flag := 'N';
                 ELSE
                     RAISE fnd_api.g_exc_unexpected_error;
                 END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Is this a rebuild WO : '||l_rebuild_flag ); END IF;

                 -- Get WPS Parameters
                 -- WPS parameters
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Getting WPS parameters'); END IF;

                 IF(WPS_COMMON.Get_Install_Status = 'I') THEN
                     WPS_COMMON.GetParameters(
                     P_Org_Id      => l_organization_id,
                     X_Use_Finite_Scheduler     => l_use_finite_scheduler,
                     X_Material_Constrained     => l_material_constrained,
                     X_Horizon_Length    => l_horizon_length);
                 ELSE
                     l_use_finite_scheduler := 2;
                     l_material_constrained := 2;
                     l_horizon_length := 0;
                 END IF;

                 -- End of WPS Parameters

                 -- Direct Change to Pending Bill Load, Failed Bill Load, Pending Routing Load,
                 -- Failed Routing Load, Pending - Mass Loaded, Pending Close, Failed Close
                 -- Pending Scheduling and Draft not Possible.

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Checking if status change is allowed'); END IF;

                 IF (l_to_status_type in (8,9,10,11,13,14,15,16,17)) THEN
                   IF l_current_status <> l_to_status_type AND l_current_status <> 0 THEN

                       raise CHANGE_STATUS_NOT_POSSIBLE;

                   END IF;
                 END IF;

                 /************************************************/
                  -- Change to Unreleased Status
                 /************************************************/
                 IF (l_to_status_type = 1) THEN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Changing to Unreleased Status'); END IF;


		 IF  p_work_order_mode  <> EAM_PROCESS_WO_PVT.G_OPR_CREATE and
		   p_to_status_type = wip_constants.unreleased
		 THEN
			 EAM_ASSET_LOG_PVT.INSERT_ROW
				 (
					p_api_version		=> 1.0,
					p_event_date		=> sysdate,
					p_event_type		=> 'EAM_SYSTEM_EVENTS',
					p_event_id		=> 7,
					p_organization_id	=> p_organization_id,
					p_instance_id		=> l_maint_obj_id,
					p_comments		=> null,
					p_reference		=> l_work_order_name,
					p_ref_id		=> p_wip_entity_id,
					p_operable_flag		=> null,
					p_reason_code		=> null,
					x_return_status		=> l_asset_ops_return_status,
					x_msg_count		=> l_asset_ops_msg_count,
					x_msg_data		=> l_asset_ops_msg_data
				 );
		  END IF;

		-- Delete data from EAM_WORK_ORDER_ROUTE table

		  DELETE FROM EAM_WORK_ORDER_ROUTE
		        WHERE wip_entity_id  = p_wip_entity_id;

                     IF (l_current_status in (17,3,6,7,9,11,15)) THEN

                         BEGIN
                             EAM_WORKORDER_UTIL_PKG.UNRELEASE(X_Org_Id => l_organization_id,
                             X_Wip_Id => l_wip_entity_id,
                             X_Rep_Id => -1,
                             X_Line_Id => -1,
                             X_Ent_Type=> 6 );

 --Fix for bug 8940736: Adding code to make DATE_RELEASED in WDJ to null when work order status is changed to unreleased
                             update wip_discrete_jobs
                             set date_released = null
                             where wip_entity_id = l_wip_entity_id
                             and organization_id=l_organization_id;


                         EXCEPTION
	                  WHEN OTHERS THEN
                             raise INVALID_UNRELEASE;
                         END;

                         l_final_status := 1;

-- Bug#3499973. removing  check for unlcose work order since cannot change to unreleased from closed.

                     ELSE
                         raise CHNGE_ST_FRM_TO_NOT_PSSBLE;
                     END IF;  -- end of check for l_current_status



                 END IF;  -- end of check for l_to_status_type



                 /********************************************
                 *  Change to Release or On Hold Status      *
                 *********************************************/


        IF (l_to_status_type in (3,6) ) THEN


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Changing to Released or On Hold Status'); END IF;

            IF (l_current_status in (1,17,3,6,7,9,11,15)) THEN

                       IF (l_to_status_type = 3 ) THEN  -- changed check for bug 3681752
                          IF (l_rebuild_flag = 'N') THEN
                             l_valid := EAM_WORKORDER_UTIL_PKG.check_released_onhold_allowed(
                             l_rebuild_flag,
                             l_organization_id,
                             l_asset_group_id,
                             l_asset_number,
                             l_primary_item_id);
                         ELSE
                             l_valid := EAM_WORKORDER_UTIL_PKG.check_released_onhold_allowed(
                             l_rebuild_flag,
                             l_organization_id,
                             l_rebuild_item_id,
                             l_rebuild_serial_number,
                             l_primary_item_id);
                         END IF;  -- end of check for l_rebuild_flag

                         IF (l_valid = 1 ) THEN
                             RAISE INVALID_RELEASE;
                         END IF;
		     END IF; /* end if for l_to_status_type = 3 */


                         -- Call Finite Scheduler

                         -- Finite scheduler has been decommisioned as of 11.5.10
                         -- Hence commenting out the code below and hardcode the
                         -- the value of the l_use_finite_scheduler flag.

                         l_use_finite_scheduler := 2;

                         IF ((l_to_status_type = 3) AND (l_use_finite_scheduler = 1) AND (l_firm_flag =2) ) THEN

                          null;

		         ELSE

                           IF l_to_status_type IN (3) AND
                              l_current_status IN (0,1,6,7,16,17) AND
			      l_to_status_type <> l_current_status THEN
                             --Added for bug 12836690
				            IF l_current_status IN (6,7) THEN
                               BEGIN
							     /*Check if the workorder was previously released in an accounting peroid
								   which is closed now.If it is, dont call WIP_CHANGE_STATUS.Release as
								   INSERT_PEROID_BALANCES throws an exception in such case*/
								 select 1
                                 into   g_dummy
                                 from org_acct_periods
                                 where organization_id = l_organization_id
                                 and trunc(p_date_released)
                                 between period_start_date and schedule_close_date
                                and period_close_date is NULL;

           						WIP_CHANGE_STATUS.Release(
                                l_wip_entity_id,
                                l_organization_id,
                                NULL,
                                NULL,
                                l_class_code,
                                l_current_status,
                                l_to_status_type,
                                l_tmp,
                                nvl(p_date_released,sysdate));

     						 EXCEPTION
                               WHEN NO_DATA_FOUND THEN
                                  NULL;
                             END;
                           ELSE
     			     WIP_CHANGE_STATUS.Release(
                                l_wip_entity_id,
                                l_organization_id,
                                NULL,
                                NULL,
                                l_class_code,
                                l_current_status,
                                l_to_status_type,
                                l_tmp,
                                nvl(p_date_released,sysdate));
                           END IF;

                           END IF;

                           IF l_to_status_type IN (6) AND
                              l_current_status IN (0,1,6,7,16,17) AND
			      l_to_status_type <> l_current_status THEN


				             select scheduled_start_date into
							   l_wo_sched_start_date from wip_discrete_jobs
							   where wip_entity_id = l_wip_entity_id
							   and organization_id = l_organization_id;
                             IF (l_wo_sched_start_date < sysdate) THEN
                               select nvl(min(period_start_date),l_wo_sched_start_date)
                               into l_min_open_period_date from org_acct_periods
                               where organization_id=l_organization_id
                               and open_flag = 'Y' and period_close_date is null;
                               l_date_released_calc := greatest(l_min_open_period_date,l_wo_sched_start_date);
                             ELSE
                               l_date_released_calc := sysdate;
                             END IF;

                              WIP_CHANGE_STATUS.Release(
                                l_wip_entity_id,
                                l_organization_id,
                                NULL,
                                NULL,
                                l_class_code,
                                l_current_status,
                                l_to_status_type,
                                l_tmp,
                                nvl(l_date_released_calc,sysdate));

                           END IF;

			      l_final_status := l_to_status_type;

                         END IF;

                             -- End of Check for Scheduling


                             -- Create Requisitions for OSP
                             IF ((l_to_status_type in (3)) AND (l_current_status in (1,6,17))) THEN

                                   --IF po_creation_time for workorder is at_job_schedule_release then only create requisitions
                                   IF (l_po_creation_time = WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE) THEN
					IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Creating osp req at release and po_creation_time correct'); END IF;
					create_osp_req_at_rel(
						       p_wip_entity_id => l_wip_entity_id,
						       p_organization_id => l_organization_id); -- for Bug 8594830
                                   END IF; --end of check for po_creation_time
                             END IF;

                             -- End of Creating Requisitions

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Creating default operation at released'); END IF;

                 -- Create Default Operation if none exists
                             IF (l_to_status_type = 3) THEN


                                     IF l_maintenance_obj_src <> 2 THEN

                                       EAM_WORKORDER_UTIL_PKG.create_default_operation
                                       (p_organization_id  => l_organization_id
                                       ,p_wip_entity_id  => l_wip_entity_id
                                       );

                                     END IF;

                                     UPDATE wip_requirement_operations
                                        SET   operation_seq_num = (SELECT MIN(operation_seq_num)
                                                                   FROM wip_operations
                                                                  WHERE wip_entity_id   = l_wip_entity_id
                                                                    AND organization_id = l_organization_id)
	                                WHERE wip_entity_id     = l_wip_entity_id
					AND organization_id   = l_organization_id
	                                AND operation_seq_num = 1;

					UPDATE wip_eam_direct_items
                                        SET operation_seq_num = (SELECT MIN(operation_seq_num)
                                                                   FROM wip_operations
                                                                  WHERE wip_entity_id   = l_wip_entity_id
                                                                    AND organization_id = l_organization_id)
	                                WHERE wip_entity_id     = l_wip_entity_id
					AND organization_id   = l_organization_id
	                                AND operation_seq_num = 1;


                             END IF;
                 -- End of Creating Default Operation


    /* Insert the route snapshot, only if it does not already exist */

         BEGIN
         	select count(*)
         	into l_route
         	from EAM_WORK_ORDER_ROUTE
         	where wip_entity_id = l_wip_entity_id;

         	if l_route = 0 then
         		INSERT INTO EAM_WORK_ORDER_ROUTE
				(
					wip_entity_id           ,
					route_asset_seq_id      ,
					instance_id  ,
					last_update_date        ,
					last_updated_by         ,
					creation_date           ,
					created_by              ,
					last_update_login
				)
				SELECT
					wdj.wip_entity_id,
					EAM_WORK_ORDER_ROUTE_S.nextval,
					mena.maintenance_object_id,
					sysdate,
					fnd_global.login_id,
					sysdate,
					fnd_global.user_id,
					fnd_global.login_id
				FROM
					WIP_DISCRETE_JOBS wdj,
					MTL_EAM_NETWORK_ASSETS mena,
					CSI_ITEM_INSTANCES CII,
					MTL_PARAMETERS mp
				WHERE
		        	  mena.network_object_id  = wdj.maintenance_object_id
		  		AND   wdj.organization_id    = p_organization_id
		  		AND   wdj.wip_entity_id      = p_wip_entity_id
		  		AND   mena.maintenance_object_id = cii.instance_id
		  		AND   cii.last_vld_organization_id = mp.organization_id
		  		AND   mp.maint_organization_id = p_organization_id
                AND   nvl(mena.start_date_active, sysdate) <= nvl(wdj.date_released, sysdate)
                AND   nvl(mena.end_date_active, sysdate) >= nvl(wdj.date_released, sysdate);
            end if;

        EXCEPTION
        	When others THEN
		 		null;
        END;

		 IF  p_work_order_mode  <> EAM_PROCESS_WO_PVT.G_OPR_CREATE and
		  (  p_to_status_type = wip_constants.released)
		 THEN
			 EAM_ASSET_LOG_PVT.INSERT_ROW
				 (
					p_api_version		=> 1.0,
					p_event_date		=> sysdate,
					p_event_type		=> 'EAM_SYSTEM_EVENTS',
					p_event_id		=> 6,
					p_organization_id	=> p_organization_id,
					p_instance_id		=> l_maint_obj_id,
					p_comments		=> null,
					p_reference		=> l_work_order_name,
					p_ref_id		=> p_wip_entity_id,
					p_operable_flag		=> null,
					p_reason_code		=> null,
					x_return_status		=> l_asset_ops_return_status,
					x_msg_count		=> l_asset_ops_msg_count,
					x_msg_data		=> l_asset_ops_msg_data
				 );
		  END IF;

		IF (l_to_status_type in (3) ) THEN  -- Added the check for bug 13102446
		  -- create requisitions for direct items.
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Check for Requisition creation'); END IF;

		  -- Bug # 4862404 : Replace eam_direct_item_recs_v by base table

		  BEGIN
		     SELECT 1 INTO l_di_count
		       FROM DUAL
		      WHERE EXISTS
		            (
			     SELECT 1
			       FROM wip_eam_direct_items wedi
			      WHERE wedi.wip_entity_id = l_wip_entity_id
			        AND wedi.organization_id = l_organization_id
                            )
                         OR EXISTS
			    (
                             SELECT 1
	                       FROM wip_requirement_operations wro, mtl_system_items_b msi
		              WHERE wro.wip_entity_id = l_wip_entity_id
				AND wro.organization_id = l_organization_id
				AND wro.inventory_item_id = msi.inventory_item_id
				AND wro.organization_id = msi.organization_id
				AND nvl(msi.stock_enabled_flag, 'N') = 'N'
                            );
                  EXCEPTION
		     WHEN NO_DATA_FOUND THEN
		        l_di_count := 0;
                  END;

                             IF l_di_count > 0 THEN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Creating direct item requisitions at release '); END IF;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Calling EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_wo_rel'); END IF;
                               EAM_PROCESS_WO_UTIL_PVT.create_reqs_at_wo_rel
                                 (  p_api_version          => 1.0
                                   ,p_init_msg_list        => FND_API.G_FALSE
                                   ,p_commit               => FND_API.G_FALSE
                                   ,p_validate_only        => FND_API.G_TRUE
                                   ,x_return_status        => l_di_return_status
                                   ,x_msg_count            => l_di_msg_count
                                   ,x_msg_data             => l_di_msg_data
                                   ,p_user_id              => l_user_id
                                   ,p_responsibility_id    => l_responsibility_id
                                   ,p_wip_entity_id        => l_wip_entity_id
                                   ,p_organization_id      => l_organization_id);

                             END IF;  -- end of check for l_di_count

                             -- end create requisitions for direct items.

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Creating direct item requisitions completed with status '||l_di_return_status); END IF;

                             IF NVL(l_di_return_status,'S') <> 'S' THEN
                               x_return_status := fnd_api.g_ret_sts_error;
                             END IF;
		END IF; -- End of If (l_to_status_type in (3))

			 l_final_status := l_to_status_type;


-- Bug#3499973. removing check for unclose work order since cannot change to released/on-hold from closed.

		ELSE
                     raise CHNGE_ST_FRM_TO_NOT_PSSBLE;
                END IF;
                 -- End of Check for Current Status

           END IF;
                     -- End of Check for Release and On Hold status


              /***********************************************************/
              -- Change to Cancel Status
              /***********************************************************/

		     IF (l_to_status_type = 7) THEN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Chaning to Cancel Status'); END IF;

                         IF (l_current_status in (17,9,1,3,6,15,12)) THEN  -- bug#3499973 included status 12(cancelled) for unclose closed work orders to cancelled.
                             l_final_status := l_to_status_type;
                         ELSE
                             raise CHNGE_ST_FRM_TO_NOT_PSSBLE;
                         END IF;

-- Moved the code to EAMWOMDF.pld as part of fix 3489907

	           --fix for 3572050
		   --fix for 3701696
		      BEGIN
                       SELECT 1
		       INTO l_relations_count
		       FROM eam_wo_relationships
		       WHERE (parent_object_id=l_wip_entity_id
		         OR child_object_id=l_wip_entity_id)
			AND parent_relationship_type =2  AND rownum<=1;
		       EXCEPTION
		          WHEN NO_DATA_FOUND THEN
			    null;
		       END;

			 IF(l_relations_count=1) THEN
			    x_return_status := fnd_api.g_ret_sts_error;
			   l_token_tbl(1).token_name  := 'WORKORDER';
                           l_token_tbl(1).token_value :=  l_wip_entity_id;
                           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
 			      (  p_message_name  => 'EAM_DELINK_CANCELLED'
				   , p_token_tbl     => l_token_tbl
			       , p_mesg_token_tbl     => l_mesg_token_tbl
				 , x_mesg_token_tbl     => x_mesg_token_tbl
			      );
			    return;
			 END IF;

                     END IF;  -- end of check for l_to_status_type

              /***********************************************************/
              -- Change between Complete and Complete No Charge Status
              /***********************************************************/
                     IF (l_to_status_type IN (4,5)) THEN
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Chaning to Complete Status'); END IF;

                         IF (l_current_status in (4,5)) THEN
                             l_final_status := l_to_status_type;

                         ELSIF (l_current_status = 12) AND (l_date_completed is not null) THEN
                             l_unclose := 1;
			     l_final_status := l_to_status_type; -- bug #3499973
                         ELSIF (l_current_status = 15) AND (l_date_completed is not null) THEN
                             l_final_status := l_to_status_type;
                         ELSE
                             raise CHNGE_ST_FRM_TO_NOT_PSSBLE;
                         END IF;

                     END IF;


               /***********************************************************/
               -- Change to Closed Status
               /***********************************************************/

		     IF (l_to_status_type = 12) THEN
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Chaning to Closed Status'); END IF;
                         IF (l_current_status IN (4,5,7)) THEN
							      l_final_status := 14;   --set l_final_status to 14(Pending close)

				BEGIN
                              SELECT 1
                                INTO l_po_exists
                                FROM (
                               SELECT 1
                                 FROM PO_RELEASES_ALL PR,
                                      PO_HEADERS_ALL PH,
                                      PO_DISTRIBUTIONS_ALL PD,
                                      PO_LINE_LOCATIONS_ALL PLL
                                WHERE pd.po_line_id IS NOT NULL
                                  AND pd.line_location_id IS NOT NULL
                                  AND PD.WIP_ENTITY_ID = l_wip_entity_id
                                  AND PD.DESTINATION_ORGANIZATION_ID = l_organization_id
                                  AND PH.PO_HEADER_ID = PD.PO_HEADER_ID
                                  AND PLL.LINE_LOCATION_ID = PD.LINE_LOCATION_ID
                                  AND PR.PO_RELEASE_ID (+) = PD.PO_RELEASE_ID
                                  AND (pll.cancel_flag IS NULL OR
                                       pll.cancel_flag = 'N')
                                 /* AND (
                                   (PLL.QUANTITY_RECEIVED < (PLL.QUANTITY-PLL.QUANTITY_CANCELLED))
                                   OR
                                   (PLL.AMOUNT_RECEIVED < (PLL.AMOUNT-PLL.AMOUNT_CANCELLED))
                                      ) -- ADDED AMOUNT condition for Bug7497877 commented this for bug8297942*/
                                  AND nvl(pll.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED')  --Added CLOSED status:Bug#6142700
                                UNION ALL
                               SELECT 1
                                 FROM PO_REQUISITION_LINES_ALL PRL
                                WHERE PRL.WIP_ENTITY_ID = l_wip_entity_id
                                  AND PRL.DESTINATION_ORGANIZATION_ID = l_organization_id
                                  AND nvl(PRL.cancel_flag, 'N') = 'N'
                                  AND PRL.LINE_LOCATION_ID is NULL
                                  AND nvl(PRL.CLOSED_CODE,'OPEN') NOT IN ('FINALLY CLOSED') /*12392266, FP of 8286428*/
                               UNION ALL
                               SELECT 1
                                 FROM PO_REQUISITIONS_INTERFACE_ALL PRI
                                WHERE PRI.WIP_ENTITY_ID = l_wip_entity_id
                                  AND PRI.DESTINATION_ORGANIZATION_ID = l_organization_id
                                )  ;

                               IF l_po_exists = 1 THEN
                                 x_return_status := fnd_api.g_ret_sts_error;
                                 EAM_ERROR_MESSAGE_PVT.Add_Error_Token
 			                           (  p_message_name   => 'WIP_CANCEL_JOB/SCHED_OPEN_PO'
				                          , p_token_tbl      => l_token_tbl
			                            , p_mesg_token_tbl => l_mesg_token_tbl
				                          , x_mesg_token_tbl => x_mesg_token_tbl
			                           );
			                           return;
                               END IF;

                             EXCEPTION
                               WHEN No_Data_Found THEN
                                 NULL;
                               WHEN TOO_MANY_ROWS THEN
			                          x_return_status := fnd_api.g_ret_sts_error;
                                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
 			                          (  p_message_name   => 'WIP_CANCEL_JOB/SCHED_OPEN_PO'
				                         , p_token_tbl      => l_token_tbl
			                           , p_mesg_token_tbl => l_mesg_token_tbl
				                         , x_mesg_token_tbl => x_mesg_token_tbl
			                          );
			                         return;
                             END;
							     BEGIN
				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Selecting group_id'); END IF;
								 SELECT wip_dj_close_temp_s.nextval
								 INTO l_gid
								 FROM dual;
							     EXCEPTION
							     WHEN OTHERS THEN
								 raise fnd_api.g_exc_unexpected_error;
							     END;

							     BEGIN
				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Insert into WIP_DJ_CLOSE_TEMP'); END IF;
								 INSERT INTO WIP_DJ_CLOSE_TEMP
								  (WIP_ENTITY_ID,
								   ORGANIZATION_ID,
								   WIP_ENTITY_NAME,
								   PRIMARY_ITEM_ID,
								   STATUS_TYPE,
								   actual_close_date,
								   GROUP_ID)
								 VALUES
								  (l_wip_entity_id,
								   l_organization_id,
								   l_wip_entity_name,
								   l_primary_item_id,
								   decode(l_current_status, 16, 1, l_current_status),
								   NVL(p_actual_close_date,SYSDATE),
								   l_gid);

							     EXCEPTION
							      WHEN OTHERS THEN
								 raise fnd_api.g_exc_unexpected_error;
							     END;

				      -- This call to fnd_global.apps_initialize is needed because this is
				      -- part of the WO API which can also be used as a standalone API
				      -- and there needs to be a call to APPS_INITIALIZE before
				      -- concurrent programs are called

							     IF (p_user_id IS NOT NULL AND p_responsibility_id IS NOT NULL) THEN
								 FND_GLOBAL.APPS_INITIALIZE(p_user_id, p_responsibility_id,426,0);
							     END IF;

                                                     IF(l_maintenance_obj_src =1 ) THEN  --for EAM invoke online WIP close API

								 EAM_JOBCLOSE_PRIV.EAM_CLOSE_WO
									(p_submission_date         =>   p_submission_date,
									   p_organization_id            =>  l_organization_id,
									   p_group_id                        =>    l_gid,
									   p_select_jobs                    =>   2,
									   p_report_type                    =>   NVL(p_report_type,'4'),
									   x_request_id                     =>   l_request_id
									  );

									 UPDATE EAM_WORK_ORDER_DETAILS
                                                                                             SET user_defined_status_id = l_closed_status,
                                                                                                     last_update_date  = SYSDATE,
                                                                                                     last_updated_by   =  fnd_global.user_id,
                                                                                                     last_update_login    =   fnd_global.login_id
                                                                                             WHERE wip_entity_id = l_wip_entity_id;


						     ELSE --for other prodcuts like CMRO invoke normal conc. program.

				l_request_id := fnd_request.submit_request('WIP', 'WICDCL', NULL,
															NULL,
															FALSE,
															p_organization_id,'','','','','','','','','',
															'','','',l_gid,2,'','','','1','',
															chr(0),'','','','','','','','','',
															'','','','','','','','','','',
															'','','','','','','','','','',
															'','','','','','','','','','',
															'','','','','','','','','','',
															'','','','','','','','','','',
															'','','','','','','','','','',
															'','','','','','','','','','');




						     END IF;

                         ELSE
                             raise CHNGE_ST_FRM_TO_NOT_PSSBLE;
                         END IF;  -- end of check for l_current_status

                     END IF;  -- End of Close Status


         /******************************************************/
         -- Update WIP_DISCRETE_JOBS with the changed job status
         /******************************************************/

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Updating WO with status'); END IF;

                 BEGIN

						     UPDATE  WIP_DISCRETE_JOBS
						     SET STATUS_TYPE = l_final_status
						     WHERE   ORGANIZATION_ID = l_organization_id
						     AND  WIP_ENTITY_ID = l_wip_entity_id;

                 EXCEPTION
						 WHEN OTHERS THEN
						     raise fnd_api.g_exc_unexpected_error;
                 END;


                 /*******************************************/
                 -- Unclose a Job
                 /*******************************************/

                 IF (l_unclose = 1) THEN
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Unclosing WO'); END IF;

                     IF WIP_CLOSE_UTILITIES.Unclose_Job(l_wip_entity_id,
                                   l_organization_id,
                                   l_class_code) = 1 THEN

								 BEGIN

											     UPDATE  WIP_ENTITIES
											     SET ENTITY_TYPE = 6
											     WHERE   ORGANIZATION_ID = l_organization_id
											     AND  WIP_ENTITY_ID = l_wip_entity_id;

											       /*Code Added for bug#4760468 Start*/
												UPDATE wip_discrete_jobs
												   SET date_closed = NULL
												 WHERE organization_id = l_organization_id
												   AND WIP_ENTITY_ID = l_wip_entity_id;
											       /*Code added for bug#4760468 End*/


								 EXCEPTION
								 WHEN OTHERS THEN
								     raise fnd_api.g_exc_unexpected_error;
								END;

                    ELSE

									BEGIN

									    UPDATE  WIP_ENTITIES
									    SET ENTITY_TYPE = 7
									    WHERE   ORGANIZATION_ID = l_organization_id
									    AND  WIP_ENTITY_ID = l_wip_entity_id;

									EXCEPTION
									WHEN OTHERS THEN
									    raise fnd_api.g_exc_unexpected_error;
									END;

                    END IF; -- end of check for WIP_CLOSE_UTILITIES.Unclose_Job

                END IF;  -- end of check for l_unclose

        /***********************************************************/
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Exiting Status Change API'); END IF;

                 -- Standard call to get message count and if count is 1, get message info.
                 fnd_msg_pub.count_and_get(
                    p_count => x_msg_count
                   ,p_data => x_msg_data);

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.change_status: Schedule change request id '||l_request_id); END IF;

                 x_request_id  := l_request_id;

              EXCEPTION
                 WHEN fnd_api.g_exc_error THEN
                    ROLLBACK TO change_status;
                    x_return_status := fnd_api.g_ret_sts_error;
                    fnd_msg_pub.count_and_get(
                       p_count => x_msg_count
                      ,p_data => x_msg_data);

                 WHEN  CHANGE_STATUS_NOT_POSSIBLE THEN
                       x_msg_count := 1;
                       x_msg_data := 'Change to ' || l_to_status_type || ' is not possible';
                    x_return_status := fnd_api.g_ret_sts_error;

                 WHEN  CHNGE_ST_FRM_TO_NOT_PSSBLE THEN

                       x_msg_count := 1;
                       x_msg_data := 'Change from ' || l_current_status || ' to ' || l_to_status_type || ' is not possible';
                    x_return_status := fnd_api.g_ret_sts_error;

                 WHEN  INVALID_RELEASE THEN
                       x_msg_count := 1;
                       x_msg_data := 'Work Order Cannot be Released';
                    x_return_status := fnd_api.g_ret_sts_error;

                 WHEN  INVALID_UNRELEASE THEN
 --Start of fix for 3357656.Get the message name from message stack and populate the token table
                   x_return_status := fnd_api.g_ret_sts_error;
                   l_encoded_message := fnd_message.get_encoded();
                   fnd_message.parse_encoded(l_encoded_message,
                                             l_application_name,
                                             l_mesg_name);
                   EAM_ERROR_MESSAGE_PVT.Add_Error_Token
 			      (  p_message_name  => l_mesg_name
				   , p_token_tbl     => l_token_tbl
			       , p_mesg_token_tbl     => l_mesg_token_tbl
				 , x_mesg_token_tbl     => x_mesg_token_tbl
			      );
--end of fix for 33575656
                 WHEN fnd_api.g_exc_unexpected_error THEN
                    ROLLBACK TO change_status;
                    x_return_status := fnd_api.g_ret_sts_unexp_error;

                    fnd_msg_pub.count_and_get(
                       p_count => x_msg_count
                      ,p_data => x_msg_data);

                 WHEN OTHERS THEN
                    ROLLBACK TO change_status;
                    x_return_status := fnd_api.g_ret_sts_unexp_error;
                    IF fnd_msg_pub.check_msg_level(
                          fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                       fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
                    END IF;

                    fnd_msg_pub.count_and_get(
                       p_count => x_msg_count
                      ,p_data => x_msg_data);

 END change_status;


/*Procedure to create osp requisitions at workorder release
     This procedure will check if there are any existing requisitions for each operation.
     If reqs. are not there then osp requisitions will be created for such operations
 */
PROCEDURE create_osp_req_at_rel (
		         p_wip_entity_id     IN   NUMBER,
			 p_organization_id   IN   NUMBER
			 )
IS
     CURSOR Cdisc IS
	    SELECT WOR.OPERATION_SEQ_NUM,
		   WOR.RESOURCE_SEQ_NUM
	      FROM WIP_OPERATION_RESOURCES WOR,
		   WIP_OPERATIONS WO
	     WHERE WO.WIP_ENTITY_ID = p_wip_entity_id
	       AND WO.ORGANIZATION_ID = p_organization_id
	       AND WOR.WIP_ENTITY_ID = WO.WIP_ENTITY_ID
	       AND WOR.ORGANIZATION_ID = WO.ORGANIZATION_ID
	       AND WOR.OPERATION_SEQ_NUM = WO.OPERATION_SEQ_NUM
	       AND WOR.AUTOCHARGE_TYPE = WIP_CONSTANTS.PO_RECEIPT
               AND WO.COUNT_POINT_TYPE <> WIP_CONSTANTS.NO_DIRECT;
  l_call_req_import VARCHAR2(10);
  l_request_id   number;
  l_ou_id number;
  l_wip_error_flag Number := 0; /*Added for FP 6814440*/
  l_message varchar2(1000); /*6814440*/
  l_status boolean;
  errbuf varchar2(2000);
  l_str_application_id VARCHAR2(30);
BEGIN
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('===============EAM_WO_CHANGE_STATUS_PVT.create_osp_req_at_rel============= '); END IF;
SAVEPOINT create_osp_req_at_rel;

  l_call_req_import := 'NO';

  FOR cdis_rec in Cdisc LOOP
	  IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.create_osp_req_at_rel'); END IF;
	  IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' req for osp op : '||cdis_rec.OPERATION_SEQ_NUM||' osp resource : '||cdis_rec.RESOURCE_SEQ_NUM); END IF;
	    --start for Bug 8594830
	    --if  requisitions are not already created then only create now
	      IF ( NOT PO_REQ_EXISTS(
					  p_wip_entity_id => p_wip_entity_id,
					  p_rep_sched_id  => null,
					  p_organization_id => p_organization_id,
					  p_op_seq_num => cdis_rec.OPERATION_SEQ_NUM,
					  p_res_seq_num => cdis_rec.RESOURCE_SEQ_NUM,
					  p_entity_type => 6)) THEN -- end for Bug 8594830
				  l_call_req_import := 'YES';   --Do not call Req Import, if the status change is from hold to release and Requisition already exists

			    IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.create_osp_req_at_rel: create req for osp resource now '); END IF;
                              BEGIN
					  WIP_OSP.CREATE_REQUISITION(
					    P_Wip_Entity_Id  => p_wip_entity_id,
					    P_Organization_Id => p_organization_id,
					    P_Repetitive_Schedule_Id => null,
					    P_Operation_Seq_Num => cdis_rec.OPERATION_SEQ_NUM,
					    P_Resource_Seq_Num => cdis_rec.RESOURCE_SEQ_NUM);
                              EXCEPTION
                                    WHEN OTHERS THEN   /*Added for FP 6814440*/
                                       l_wip_error_flag :=1;
                                       l_message := SUBSTR(FND_MESSAGE.get,1,500);
                                       FND_MESSAGE.SET_NAME('WIP', 'WIP_RELEASE_PO_MOVE');
                                       fnd_msg_pub.add;
                                       EAM_ERROR_MESSAGE_PVT.Add_Message
                                      (  p_mesg_text          => l_message
                                       , p_entity_id          => 1
                                       , p_entity_index       => 1
                                       , p_message_type       => 'E'
                                      );
                                       APP_EXCEPTION.RAISE_EXCEPTION;
                              END;
	  	END IF; --end of check if reqs exist or not --for 8594830
   END LOOP;

   IF (l_call_req_import = 'YES') THEN -- if req import has to be callled
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.create_osp_req_at_rel: invoking req import program'); END IF;

    BEGIN
	 select to_number(ho.ORG_INFORMATION3)
         into l_ou_id
         from hr_organization_information ho
         where ho.organization_id = p_organization_id
         and ho.ORG_INFORMATION_CONTEXT = 'Accounting Information';
    EXCEPTION
    	 WHEN NO_DATA_FOUND THEN
    	 	ROLLBACK TO create_osp_req_at_rel;
    	 	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||'EAM_WO_CHANGE_STATUS_PVT.create_osp_req_at_rel: No operating unit found'); END IF;
    END;

         fnd_request.set_org_id(l_ou_id);

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.create_osp_req_at_rel: user_id:'||fnd_global.user_id || 'resp_id:'||fnd_global.resp_id||' appl id:'||FND_GLOBAL.PROG_APPL_ID);
	END IF;

	l_status := fnd_request.set_options(datagroup => 'Standard');
	 IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.create_osp_req_at_rel: set_options is set '); END IF;

        l_str_application_id := fnd_profile.value('RESP_APPL_ID');

	if (fnd_global.user_id is not null and fnd_global.resp_id is not null and l_str_application_id is not null) then
		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
			EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.create_osp_req_at_rel: calling FND_GLOBAL.APPS_INITIALIZE ');
		END IF;

                FND_GLOBAL.APPS_INITIALIZE(fnd_global.user_id, fnd_global.resp_id, to_number(l_str_application_id),0);
      end if;

	  IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug(' EAM_WO_CHANGE_STATUS_PVT.create_osp_req_at_rel: user_id:'||fnd_global.user_id || 'resp_id:'||fnd_global.resp_id||' appl id:'||FND_GLOBAL.PROG_APPL_ID||' Strappid:'||l_str_application_id);
	END IF;

        l_request_id := fnd_request.submit_request(
        'PO', 'REQIMPORT', NULL, NULL, FALSE,'WIP', NULL, 'ITEM',
        NULL ,'N', 'Y' , chr(0), NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
        ) ;
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||'EAM_WO_CHANGE_STATUS_PVT.create_osp_req_at_rel: Launced req import program for osp resource : request id : '||l_request_id); END IF;
 errbuf := fnd_message.get;
  IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||'EAM_WO_CHANGE_STATUS_PVT.create_osp_req_at_rel: Error msg: '||errbuf); END IF;

   END IF; --end of check for req import to be called or not

EXCEPTION

     WHEN OTHERS THEN
         ROLLBACK TO create_osp_req_at_rel;
	 IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||'EAM_WO_CHANGE_STATUS_PVT.create_osp_req_at_rel: error creating reqs for osp at rel '); END IF;
         IF (l_wip_error_flag = 1) THEN /*Added for FP 6814440*/
            APP_EXCEPTION.RAISE_EXCEPTION;
         END IF;
END create_osp_req_at_rel;

--Added for 8594830
FUNCTION PO_REQ_EXISTS (p_wip_entity_id    in NUMBER,
 	                           p_rep_sched_id     in NUMBER,
 	                           p_organization_id  in NUMBER,
 	                           p_op_seq_num       in NUMBER default NULL,
 	                           p_res_seq_num in NUMBER,
 	                           p_entity_type      in NUMBER
 	                          ) RETURN BOOLEAN IS

 	   CURSOR disc_check_po_req_cur IS
 	     SELECT 'PO/REQ Linked'
      FROM PO_REQUISITION_LINES_ALL PRL,
         PO_REQUISITION_HEADERS_ALL PRH
     WHERE PRL.requisition_header_id = PRH.requisition_header_id(+)
     AND upper(NVL(PRH.authorization_status, 'APPROVED') ) not in ('CANCELLED', 'REJECTED','SYSTEM_SAVED')
     AND PRL.WIP_ENTITY_ID = p_wip_entity_id
       AND PRL.DESTINATION_ORGANIZATION_ID = p_organization_id
       AND (p_op_seq_num is NULL OR
            PRL.WIP_OPERATION_SEQ_NUM = p_op_seq_num)
       AND (p_res_seq_num is NULL OR
            PRL.WIP_RESOURCE_SEQ_NUM = p_res_seq_num)
       AND nvl(PRL.cancel_flag, 'N') = 'N'
       --AND PRL.LINE_LOCATION_ID is NULL
   UNION ALL
    SELECT 'PO/REQ Linked'
      FROM PO_REQUISITIONS_INTERFACE_ALL PRI
     WHERE PRI.WIP_ENTITY_ID = p_wip_entity_id
       AND PRI.DESTINATION_ORGANIZATION_ID = p_organization_id
       AND (p_op_seq_num is NULL OR PRI.WIP_OPERATION_SEQ_NUM = p_op_seq_num)
       AND (p_res_seq_num is NULL OR PRI.WIP_RESOURCE_SEQ_NUM = p_res_seq_num)
       AND ((PRI.process_flag is null) or (Upper(Trim(PRI.process_flag)) = 'IN PROCESS'));


 	   po_req_exist VARCHAR2(20);

 	   begin
		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
	                EAM_ERROR_MESSAGE_PVT.Write_Debug('===============EAM_WO_CHANGE_STATUS_PVT.PO_REQ_EXISTS ============= ');
		END IF;

 	     /*FOR DISCRETE, OSFM, AND EAM*/
 	     OPEN disc_check_po_req_cur;
 	     FETCH disc_check_po_req_cur INTO po_req_exist;

 	     IF (disc_check_po_req_cur%FOUND) THEN
 	       CLOSE disc_check_po_req_cur;
		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
			EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.PO_REQ_EXISTS : Yes ');
		END IF;

 	       return TRUE;
 	     ELSE
 	       CLOSE disc_check_po_req_cur;
		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
			EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_WO_CHANGE_STATUS_PVT.PO_REQ_EXISTS : No');
		END IF;
 	       return FALSE;
 	     END IF;

 	  END PO_REQ_EXISTS;

 END EAM_WO_CHANGE_STATUS_PVT; -- package body


/
